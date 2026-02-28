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

namespace Aidcademy
{
    public partial class GoogleCallback : Page
    {
        // ── Web.config keys ──────────────────────────────────────────────
        private static string ClientId     => ConfigurationManager.AppSettings["GoogleClientId"];
        private static string ClientSecret => ConfigurationManager.AppSettings["GoogleClientSecret"];
        private static string RedirectUri  => ConfigurationManager.AppSettings["GoogleRedirectUri"];

        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // ── Case 1: OAuth error returned by Google ───────────────────
            string error = Request.QueryString["error"];
            if (!string.IsNullOrEmpty(error))
            {
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
                return;
            }

            // ── Case 2: OAuth code returned by Google (the callback) ─────
            string code  = Request.QueryString["code"];
            string state = Request.QueryString["state"];

            if (!string.IsNullOrEmpty(code))
            {
                HandleCallback(code, state);
                return;
            }

            // ── Case 3: Initiate the Google OAuth redirect ───────────────
            string action = Request.QueryString["action"] ?? "login";
            Session["GoogleAction"] = action;

            // Generate a CSRF state token
            string csrfState = Guid.NewGuid().ToString("N");
            Session["GoogleCsrfState"] = csrfState;

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

        // ─────────────────────────────────────────────────────────────────
        // Handle the OAuth callback from Google
        // ─────────────────────────────────────────────────────────────────
        private void HandleCallback(string code, string returnedState)
        {
            // CSRF check
            string expectedState = Session["GoogleCsrfState"]?.ToString();
            if (string.IsNullOrEmpty(expectedState) || returnedState != expectedState)
            {
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
                return;
            }
            Session.Remove("GoogleCsrfState");

            try
            {
                // 1. Exchange code for tokens
                string tokenJson = ExchangeCodeForToken(code);
                JObject tokens   = JObject.Parse(tokenJson);
                string accessToken = tokens["access_token"]?.ToString();

                if (string.IsNullOrEmpty(accessToken))
                {
                    Response.Redirect("~/Login_signup.aspx?msg=google_error");
                    return;
                }

                // 2. Fetch Google user info
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

                // 3. Find or create user in our database
                int userId;
                string role;
                string fullName;
                FindOrCreateGoogleUser(googleId, googleEmail, googleName, out userId, out role, out fullName);

                // 4. Generate OTP and redirect to verify page
                string otp = Aidcademy.Utilities.OtpHelper.SaveOtp(userId, "Login");
                string errMsg;
                Aidcademy.Utilities.EmailHelper.SendOtpEmail(googleEmail, otp, "Login", out errMsg);

                Session["PendingUserID"] = userId;
                Session["PendingEmail"]  = googleEmail;
                Session["PendingName"]   = fullName;
                Session["PendingRole"]   = role;

                Response.Redirect("~/VerifyOtp.aspx?purpose=Login");
            }
            catch (Exception ex)
            {
                // Log and fall back to login page
                System.Diagnostics.Debug.WriteLine("GoogleCallback error: " + ex.Message);
                Response.Redirect("~/Login_signup.aspx?msg=google_error");
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // Exchange OAuth code for tokens via Google's token endpoint
        // ─────────────────────────────────────────────────────────────────
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

        // ─────────────────────────────────────────────────────────────────
        // Fetch user's profile from Google's userinfo endpoint
        // ─────────────────────────────────────────────────────────────────
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

        // ─────────────────────────────────────────────────────────────────
        // Look up existing user by GoogleID or email; create if not found
        // ─────────────────────────────────────────────────────────────────
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
                // Build a safe username from the email's local part
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

                // Insert profile row
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

        // ─────────────────────────────────────────────────────────────────
        // Make sure the chosen username doesn't already exist
        // ─────────────────────────────────────────────────────────────────
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
