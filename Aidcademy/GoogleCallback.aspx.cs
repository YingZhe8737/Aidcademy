using System;
using System.Collections.Specialized;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json.Linq;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class GoogleCallback : Page
    {
        private static string ClientId     => ConfigurationManager.AppSettings["GoogleClientId"];
        private static string ClientSecret => ConfigurationManager.AppSettings["GoogleClientSecret"];
        private static string RedirectUri  => ConfigurationManager.AppSettings["GoogleRedirectUri"];

        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            string error = Request.QueryString["error"];
            if (!string.IsNullOrEmpty(error))
            {
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
                return;
            }

            string code  = Request.QueryString["code"];
            string state = Request.QueryString["state"];

            if (!string.IsNullOrEmpty(code))
            {
                HandleCallback(code, state);
                return;
            }

            string action = Request.QueryString["action"] ?? "login";
            Session["GoogleAction"] = action;

            string csrfState = Guid.NewGuid().ToString("N");
            var stateCookie = new HttpCookie("g_oauth_state", csrfState)
            {
                HttpOnly = true,
                Secure   = Request.IsSecureConnection,
                Expires  = DateTime.Now.AddMinutes(10)
            };
            Response.Cookies.Set(stateCookie);

            string googleAuthUrl =
                "https://accounts.google.com/o/oauth2/v2/auth" +
                "?client_id="     + Uri.EscapeDataString(ClientId) +
                "&redirect_uri="  + Uri.EscapeDataString(RedirectUri) +
                "&response_type=code" +
                "&scope="         + Uri.EscapeDataString("openid email profile") +
                "&state="         + Uri.EscapeDataString(csrfState) +
                "&access_type=offline" +
                "&prompt=select_account";

            Response.Redirect(googleAuthUrl);
        }

        // Handle the OAuth callback from Google
        private void HandleCallback(string code, string returnedState)
        {
            string expectedState = Request.Cookies["g_oauth_state"]?.Value;
            var expireCookie = new HttpCookie("g_oauth_state", "") { Expires = DateTime.Now.AddYears(-1) };
            Response.Cookies.Set(expireCookie);

            if (!string.IsNullOrEmpty(expectedState) && returnedState != expectedState)
            {
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
                return;
            }

            try
            {
                string tokenJson = ExchangeCodeForToken(code);
                JObject tokens   = JObject.Parse(tokenJson);
                string accessToken = tokens["access_token"]?.ToString();

                if (string.IsNullOrEmpty(accessToken))
                {
                    Response.Redirect("~/Login_signup.aspx?msg=google_error");
                    return;
                }

                string userInfoJson  = FetchUserInfo(accessToken);
                JObject userInfo     = JObject.Parse(userInfoJson);
                string googleId      = userInfo["sub"]?.ToString();
                string googleEmail   = userInfo["email"]?.ToString();
                string googleName    = userInfo["name"]?.ToString() ?? googleEmail;

                if (string.IsNullOrEmpty(googleId) || string.IsNullOrEmpty(googleEmail))
                {
                    Response.Redirect("~/Login_signup.aspx?msg=google_error");
                    return;
                }

                int userId;
                string role;
                string fullName;
                FindOrCreateGoogleUser(googleId, googleEmail, googleName, out userId, out role, out fullName);

                // Use the shared session helper so all session keys match the rest of the app
                SessionHelper.SetLoginSession(userId, role, fullName, googleEmail);

                if (role == "Admin")
                    Response.Redirect("~/AdminDashboard.aspx");
                else if (role == "Instructor")
                    Response.Redirect("~/InstructorManageContent.aspx");
                else
                    Response.Redirect("~/MemberDashboard.aspx");
            }
            catch (System.Threading.ThreadAbortException)
            {
                throw; 
            }
            catch (Exception ex)
            {
                // Store real error message so login page can display it
                Session["GoogleError"] = ex.Message + (ex.InnerException != null ? " | " + ex.InnerException.Message : "");
                System.Diagnostics.Debug.WriteLine("GoogleCallback error: " + ex.ToString());
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
            }
        }

        private string ExchangeCodeForToken(string code)
        {
            string tokenUrl = "https://oauth2.googleapis.com/token";

            string postData =
                "code="          + Uri.EscapeDataString(code) +
                "&client_id="    + Uri.EscapeDataString(ClientId) +
                "&client_secret="+ Uri.EscapeDataString(ClientSecret) +
                "&redirect_uri=" + Uri.EscapeDataString(RedirectUri) +
                "&grant_type=authorization_code";

            byte[] data = Encoding.UTF8.GetBytes(postData);

            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(tokenUrl);
            req.Method        = "POST";
            req.ContentType   = "application/x-www-form-urlencoded";
            req.ContentLength = data.Length;

            using (Stream stream = req.GetRequestStream())
                stream.Write(data, 0, data.Length);

            using (HttpWebResponse resp = (HttpWebResponse)req.GetResponse())
            using (StreamReader reader  = new StreamReader(resp.GetResponseStream()))
                return reader.ReadToEnd();
        }

        // Fetch the user's profile from Google
        private string FetchUserInfo(string accessToken)
        {
            string url = "https://www.googleapis.com/oauth2/v3/userinfo";
            HttpWebRequest req = (HttpWebRequest)WebRequest.Create(url);
            req.Method = "GET";
            req.Headers.Add("Authorization", "Bearer " + accessToken);

            using (HttpWebResponse resp = (HttpWebResponse)req.GetResponse())
            using (StreamReader reader  = new StreamReader(resp.GetResponseStream()))
                return reader.ReadToEnd();
        }

        // Find user by GoogleID or email; create new account if not found
        private void FindOrCreateGoogleUser(
            string googleId, string email, string name,
            out int userId, out string role, out string fullName)
        {
            userId   = 0;
            role     = "Member";
            fullName = name;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Try to find by GoogleID first
                string findByGoogle = @"
                    SELECT u.UserID, u.Role, p.FullName
                    FROM   Users u
                    LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                    WHERE  u.GoogleID = @GoogleID";

                using (SqlCommand cmd = new SqlCommand(findByGoogle, conn))
                {
                    cmd.Parameters.AddWithValue("@GoogleID", googleId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            userId   = Convert.ToInt32(r["UserID"]);
                            role     = r["Role"].ToString();
                            fullName = r["FullName"]?.ToString() ?? name;
                            return;
                        }
                    }
                }

                // Try to find by email (link existing account)
                string findByEmail = @"
                    SELECT u.UserID, u.Role, p.FullName
                    FROM   Users u
                    LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                    WHERE  u.Email = @Email";

                using (SqlCommand cmd = new SqlCommand(findByEmail, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (r.Read())
                        {
                            userId   = Convert.ToInt32(r["UserID"]);
                            role     = r["Role"].ToString();
                            fullName = r["FullName"]?.ToString() ?? name;
                            r.Close();

                            // Link GoogleID to the existing account
                            string update = "UPDATE Users SET GoogleID = @GoogleID WHERE UserID = @UserID";
                            using (SqlCommand upd = new SqlCommand(update, conn))
                            {
                                upd.Parameters.AddWithValue("@GoogleID", googleId);
                                upd.Parameters.AddWithValue("@UserID",   userId);
                                upd.ExecuteNonQuery();
                            }
                            return;
                        }
                    }
                }

                // No existing account — create a new one
                string baseUsername = email.Split('@')[0];
                string username     = EnsureUniqueUsername(conn, baseUsername);

                string insertUser = @"
                    INSERT INTO Users (Username, Email, PasswordHash, GoogleID, Role, Status, CreatedAt)
                    VALUES (@Username, @Email, '', @GoogleID, 'Member', 'Active', GETDATE());
                    SELECT SCOPE_IDENTITY();";

                using (SqlCommand cmd = new SqlCommand(insertUser, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Email",    email);
                    cmd.Parameters.AddWithValue("@GoogleID", googleId);

                    object newIdObj = cmd.ExecuteScalar();
                    if (newIdObj == null || !int.TryParse(newIdObj.ToString(), out userId))
                        throw new Exception("Failed to create user account via Google Sign-In.");
                }

                string insertProfile = @"
                    INSERT INTO UserProfiles (UserID, FullName)
                    VALUES (@UserID, @FullName)";

                using (SqlCommand cmd = new SqlCommand(insertProfile, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID",   userId);
                    cmd.Parameters.AddWithValue("@FullName", name);
                    cmd.ExecuteNonQuery();
                }

                fullName = name;
                role     = "Member";
            }
        }

        private string EnsureUniqueUsername(SqlConnection conn, string baseUsername)
        {
            string candidate = baseUsername;
            int suffix       = 1;

            while (true)
            {
                string check = "SELECT COUNT(*) FROM Users WHERE Username = @Username";
                using (SqlCommand cmd = new SqlCommand(check, conn))
                {
                    cmd.Parameters.AddWithValue("@Username", candidate);
                    int count = (int)cmd.ExecuteScalar();
                    if (count == 0)
                        return candidate;
                }
                candidate = baseUsername + suffix.ToString();
                suffix++;
            }
        }
    }
}
