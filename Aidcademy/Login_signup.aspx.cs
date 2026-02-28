using System;
using System.Data.SqlClient;
using System.Web.UI;
using BCrypt.Net;

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
                if (Session["UserID"] != null)
                    RedirectByRole(Session["UserRole"]?.ToString() ?? "Member");
            }
        }

        // ─────────────────────────────────────────────────────────────────
        // LOGIN
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

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT u.UserID, p.FullName, u.Email, u.Role, u.Status, u.PasswordHash
                        FROM Users u
                        LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                        WHERE (u.Email = @Login OR u.Username = @Login)";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Login", login);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string storedHash = reader["PasswordHash"].ToString();
                                
                                bool isPasswordValid = false;

                                try
                                {
                                    // Verify password with BCrypt
                                    isPasswordValid = BCrypt.Net.BCrypt.Verify(password, storedHash);
                                }
                                catch (SaltParseException)
                                {
                                    // Fallback: The hash in the DB is likely the old SHA256 format.
                                    if (Aidcademy.Utilities.SecurityHelper.VerifyPassword(password, storedHash))
                                    {
                                        isPasswordValid = true;

                                        // Upgrade their hash to BCrypt for future logins
                                        var pm = new PasswordManager();
                                        string newBcryptHash = pm.HashPassword(password);
                                        
                                        using (SqlConnection updateConn = new SqlConnection(connectionString))
                                        {
                                            updateConn.Open();
                                            string updateQuery = "UPDATE Users SET PasswordHash = @NewHash WHERE UserID = @UserID";
                                            using (SqlCommand updateCmd = new SqlCommand(updateQuery, updateConn))
                                            {
                                                updateCmd.Parameters.AddWithValue("@NewHash", newBcryptHash);
                                                updateCmd.Parameters.AddWithValue("@UserID", reader["UserID"]);
                                                updateCmd.ExecuteNonQuery();
                                            }
                                        }
                                    }
                                }

                                if (!isPasswordValid)
                                {
                                    ShowMessage("❌ Incorrect password. Please try again.", false);
                                    return;
                                }
                                string status = reader["Status"].ToString();
                                if (status == "Suspended" || status == "Deactivated")
                                {
                                    ShowMessage("Your account has been " + status.ToLower() + ". Please contact support.", false);
                                    return;
                                }

                                // Credentials valid — send OTP before creating a full session
                                string sessionRole  = reader["Role"].ToString();
                                string sessionName  = reader["FullName"]?.ToString() ?? "";
                                string sessionEmail = reader["Email"].ToString();
                                int sessionUserId   = Convert.ToInt32(reader["UserID"]);

                                reader.Close();

                                // Generate & save OTP
                                string otp = Aidcademy.Utilities.OtpHelper.SaveOtp(sessionUserId, "Login");

                                // Email the OTP
                                string errMsg;
                                Aidcademy.Utilities.EmailHelper.SendOtpEmail(sessionEmail, otp, "Login", out errMsg);

                                // Store pending login info in session
                                Session["PendingUserID"] = sessionUserId;
                                Session["PendingEmail"]  = sessionEmail;
                                Session["PendingName"]   = sessionName;
                                Session["PendingRole"]   = sessionRole;

                                // Redirect to OTP verification
                                Response.Redirect("VerifyOtp.aspx?purpose=Login");
                            }
                            else
                            {
                                ShowMessage("❌ No account found with that email or username.", false);
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
            int spaceIndex  = fullName.IndexOf(' ');
            string firstName = spaceIndex >= 0 ? fullName.Substring(0, spaceIndex).Trim() : fullName;
            string lastName  = spaceIndex >= 0 ? fullName.Substring(spaceIndex + 1).Trim() : "";

            string username       = txtSignupUsername.Text.Trim();
            string email          = txtSignupEmail.Text.Trim();
            string phone          = txtSignupPhone.Text.Trim();
            string password       = txtSignupPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email)    || string.IsNullOrEmpty(password))
            {
                ShowMessage("Please fill in all required fields.", false);
                return;
            }

            if (password != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            if (!ValidatePassword(password))
            {
                ShowMessage("Password must be at least 8 characters with uppercase, lowercase, and numbers.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Check if email already exists
                    string checkEmail = "SELECT COUNT(*) FROM Users WHERE Email = @Email";
                    using (SqlCommand cmdCheck = new SqlCommand(checkEmail, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Email", email);
                        if ((int)cmdCheck.ExecuteScalar() > 0)
                        {
                            ShowMessage("This email is already registered.", false);
                            return;
                        }
                    }

                    // Check if username already exists
                    string checkUsername = "SELECT COUNT(*) FROM Users WHERE Username = @Username";
                    using (SqlCommand cmdCheck = new SqlCommand(checkUsername, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Username", username);
                        if ((int)cmdCheck.ExecuteScalar() > 0)
                        {
                            ShowMessage("This username is already taken.", false);
                            return;
                        }
                    }

                    // Insert new user and profile
                    string insertQuery = @"
                        INSERT INTO Users (Username, Email, PasswordHash, Role, Status, CreatedAt)
                        VALUES (@Username, @Email, @Password, 'Member', 'Active', GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        // Use PasswordManager as per LAB instructions
                        var passwordManager = new PasswordManager();
                        string hashedPassword = passwordManager.HashPassword(password);

                        cmd.Parameters.AddWithValue("@Username",  username);
                        cmd.Parameters.AddWithValue("@Email",     email);
                        cmd.Parameters.AddWithValue("@Password",  hashedPassword);

                        object newUserIdObj = cmd.ExecuteScalar();

                        if (newUserIdObj != null && int.TryParse(newUserIdObj.ToString(), out int newUserId))
                        {
                            string insertProfile = @"
                                INSERT INTO UserProfiles (UserID, FullName, PhoneNumber)
                                VALUES (@UserID, @FullName, @Phone)";

                            using (SqlCommand profCmd = new SqlCommand(insertProfile, conn))
                            {
                                profCmd.Parameters.AddWithValue("@UserID", newUserId);
                                profCmd.Parameters.AddWithValue("@FullName", fullName);
                                profCmd.Parameters.AddWithValue("@Phone", string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                                profCmd.ExecuteNonQuery();
                            }

                            // ===== OTP PART =====
                            string otp = Aidcademy.Utilities.OtpHelper.GenerateNumericOtp();
                            string secret = System.Configuration.ConfigurationManager.AppSettings["OtpSecret"];
                            string otpHash = Aidcademy.Utilities.OtpHelper.HmacOtp(otp, secret);

                            // Save OTP into EmailOtp table (OtpCodes)
                            Aidcademy.Utilities.OtpHelper.SaveOtpToDb(newUserId, otpHash, DateTime.UtcNow.AddMinutes(10));

                            // Send OTP email
                            string errMsg;
                            Aidcademy.Utilities.EmailHelper.SendOtpEmail(email, otp, "Login", out errMsg);

                            // Set Session pending variables for VerifyOtp
                            Session["PendingUserID"] = newUserId;
                            Session["PendingEmail"]  = email;
                            Session["PendingName"]   = fullName;
                            Session["PendingRole"]   = "Member";

                            // Redirect to OTP verification page
                            Response.Redirect("VerifyOtp.aspx?purpose=Login");
                        }
                        else
                        {
                            ShowMessage("Failed to create account. Please try again.", false);
                        }
                    }
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
                Response.Redirect("~/AdminDashboard.aspx");
            else if (role == "Instructor")
                Response.Redirect("~/InstructorManageContent.aspx");
            else
                Response.Redirect("~/MemberDashboard.aspx");
        }

        private bool ValidatePassword(string password)
        {
            if (password.Length < 8) return false;
            bool hasUpper = false, hasLower = false, hasDigit = false;
            foreach (char c in password)
            {
                if (char.IsUpper(c)) hasUpper = true;
                if (char.IsLower(c)) hasLower = true;
                if (char.IsDigit(c)) hasDigit = true;
            }
            return hasUpper && hasLower && hasDigit;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible  = true;
            lblMessage.Text     = message;
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

    public class PasswordManager
    {
        // Method to hash the password exactly as specified in the lab instruction
        public string HashPassword(string plainTextPassword)
        {
            string hashedPassword = BCrypt.Net.BCrypt.HashPassword(plainTextPassword);
            return hashedPassword;
        }
    }
}