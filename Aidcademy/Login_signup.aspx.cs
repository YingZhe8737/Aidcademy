using System;
using System.Data.SqlClient;
using System.Text.RegularExpressions;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Login_signup : Page
    {
        private readonly string connectionString =
            System.Configuration.ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Already fully logged in → go to dashboard
                if (SessionHelper.IsUserLoggedIn())
                    RedirectByRole(SessionHelper.GetRole());
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // LOGIN — Step 1: validate credentials, then send OTP
        // ─────────────────────────────────────────────────────────────────
        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string login    = txtLoginEmail.Text.Trim();
            string password = txtLoginPassword.Text.Trim();

            if (string.IsNullOrEmpty(login) || string.IsNullOrEmpty(password))
            {
                ShowMessage("Please enter your email/username and password.", false);
                return;
            }

            string hashedPassword = SecurityHelper.HashPassword(password);

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT u.UserID, u.Email, u.Role, u.Status, p.FullName
                        FROM Users u
                        LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                        WHERE (u.Email = @Login OR u.Username = @Login)
                          AND u.PasswordHash = @PasswordHash";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Login", login);
                        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string status = reader["Status"].ToString();
                                if (status == "Suspended")
                                {
                                    ShowMessage("Your account has been suspended. Please contact support.", false);
                                    return;
                                }
                                if (status == "Deactivated")
                                {
                                    ShowMessage("Your account is not active. Please contact support.", false);
                                    return;
                                }

                                int    userID   = Convert.ToInt32(reader["UserID"]);
                                string role     = reader["Role"].ToString();
                                string email    = reader["Email"].ToString();
                                string fullName = reader["FullName"] != DBNull.Value
                                                  ? reader["FullName"].ToString()
                                                  : "Member";
                                reader.Close();

                                // Store pending session (NOT fully logged in yet)
                                Session["PendingUserID"] = userID;
                                Session["PendingRole"]   = role;
                                Session["PendingName"]   = fullName;
                                Session["PendingEmail"]  = email;

                                // Generate OTP and email it
                                string otp = OtpHelper.SaveOtp(userID, "Login");
                                string errMsg;

                                if (!EmailHelper.SendOtpEmail(email, otp, "Login", out errMsg))
                                {
                                    ShowMessage("Could not send verification email. Please try again or contact support. (" + errMsg + ")", false);
                                    return;
                                }

                                // Redirect to OTP verification page
                                Response.Redirect("~/VerifyOtp.aspx?purpose=Login");
                            }
                            else
                            {
                                ShowMessage("Invalid email/username or password. Please try again.", false);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Login error: " + ex.Message, false);
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // SIGNUP
        // ─────────────────────────────────────────────────────────────────
        protected void btnSignup_Click(object sender, EventArgs e)
        {
            string fullName = txtSignupFullName.Text.Trim();
            string username = txtSignupUsername.Text.Trim();
            string email    = txtSignupEmail.Text.Trim();
            string password = txtSignupPassword.Text.Trim();
            string confirm  = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email)    || string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(confirm))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (password != confirm)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            string pwdError;
            if (!SecurityHelper.IsPasswordValid(password, out pwdError))
            {
                ShowMessage(pwdError, false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check for duplicates
                    string checkQuery = "SELECT COUNT(*) FROM Users WHERE Email = @Email OR Username = @Username";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, conn))
                    {
                        checkCmd.Parameters.AddWithValue("@Email",    email);
                        checkCmd.Parameters.AddWithValue("@Username", username);
                        if ((int)checkCmd.ExecuteScalar() > 0)
                        {
                            ShowMessage("Email or username already exists. Please choose another.", false);
                            return;
                        }
                    }

                    // Insert the new user account
                    string insertUser = @"
                        INSERT INTO Users (Username, Email, PasswordHash, Role, Status, CreatedAt)
                        OUTPUT INSERTED.UserID
                        VALUES (@Username, @Email, @PasswordHash, 'Member', 'Active', GETDATE())";

                    int newUserID;
                    using (SqlCommand insertCmd = new SqlCommand(insertUser, conn))
                    {
                        insertCmd.Parameters.AddWithValue("@Username",     username);
                        insertCmd.Parameters.AddWithValue("@Email",        email);
                        insertCmd.Parameters.AddWithValue("@PasswordHash", SecurityHelper.HashPassword(password));
                        newUserID = (int)insertCmd.ExecuteScalar();
                    }

                    // Save full name to UserProfiles
                    string insertProfile = "INSERT INTO UserProfiles (UserID, FullName) VALUES (@UserID, @FullName)";
                    using (SqlCommand profileCmd = new SqlCommand(insertProfile, conn))
                    {
                        profileCmd.Parameters.AddWithValue("@UserID",   newUserID);
                        profileCmd.Parameters.AddWithValue("@FullName", fullName);
                        profileCmd.ExecuteNonQuery();
                    }

                    // Create a Leaderboard entry
                    string insertLb = "INSERT INTO Leaderboard (UserID, TotalPoints, DailyStreak) VALUES (@UserID, 0, 0)";
                    using (SqlCommand lbCmd = new SqlCommand(insertLb, conn))
                    {
                        lbCmd.Parameters.AddWithValue("@UserID", newUserID);
                        lbCmd.ExecuteNonQuery();
                    }

                    ShowMessage("Account created successfully! You can now log in.", true);
                    ClearSignupForm();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Registration error: " + ex.Message, false);
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // Helpers
        // ─────────────────────────────────────────────────────────────────
        private void RedirectByRole(string role)
        {
            if (role == "Admin")
                Response.Redirect("~/Admin/AdminDashboard.aspx");
            else if (role == "Instructor")
                Response.Redirect("~/Instructor/InstructorDashboard.aspx");
            else
                Response.Redirect("~/MemberDashboard.aspx");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            lblMessage.Text    = message;
            lblMessage.CssClass = isSuccess ? "message success" : "message error";
        }

        private void ClearSignupForm()
        {
            txtSignupFullName.Text  = "";
            txtSignupUsername.Text  = "";
            txtSignupEmail.Text     = "";
            txtSignupPhone.Text     = "";
            txtSignupPassword.Text  = "";
            txtConfirmPassword.Text = "";
        }
    }
}