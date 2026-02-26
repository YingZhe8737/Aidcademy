using System;
using System.Data.SqlClient;
using System.Web.UI;

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
                if (Session["MemberID"] != null)
                    RedirectByRole(Session["Role"]?.ToString() ?? "Member");
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

            string hashedPassword = HashPassword(password);

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string query = @"
                        SELECT MemberID, FirstName, LastName, Email, Role, Status
                        FROM Members
                        WHERE (Email = @Login OR Username = @Login)
                          AND Password = @Password";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Login",    login);
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string status = reader["Status"].ToString();
                                if (status == "Suspended" || status == "Deactivated")
                                {
                                    ShowMessage("Your account has been " + status.ToLower() + ". Please contact support.", false);
                                    return;
                                }

                                // Store session
                                Session["MemberID"]  = reader["MemberID"].ToString();
                                Session["FirstName"] = reader["FirstName"].ToString();
                                Session["LastName"]  = reader["LastName"].ToString();
                                Session["Email"]     = reader["Email"].ToString();
                                Session["Role"]      = reader["Role"].ToString();

                                string role = reader["Role"].ToString();
                                reader.Close();

                                RedirectByRole(role);
                            }
                            else
                            {
                                ShowMessage("Invalid email/username or password.", false);
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
                    string checkEmail = "SELECT COUNT(*) FROM Members WHERE Email = @Email";
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
                    string checkUsername = "SELECT COUNT(*) FROM Members WHERE Username = @Username";
                    using (SqlCommand cmdCheck = new SqlCommand(checkUsername, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Username", username);
                        if ((int)cmdCheck.ExecuteScalar() > 0)
                        {
                            ShowMessage("This username is already taken.", false);
                            return;
                        }
                    }

                    // Insert new member
                    string insertQuery = @"
                        INSERT INTO Members (FirstName, LastName, Username, Email, Phone, Password, Role, Status, RegistrationDate, DailyStreak, TotalPoints)
                        VALUES (@FirstName, @LastName, @Username, @Email, @Phone, @Password, 'Member', 'Active', GETDATE(), 0, 0)";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@FirstName", firstName);
                        cmd.Parameters.AddWithValue("@LastName",  lastName);
                        cmd.Parameters.AddWithValue("@Username",  username);
                        cmd.Parameters.AddWithValue("@Email",     email);
                        cmd.Parameters.AddWithValue("@Phone",     string.IsNullOrEmpty(phone) ? (object)DBNull.Value : phone);
                        cmd.Parameters.AddWithValue("@Password",  HashPassword(password));

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                        {
                            ShowMessage("Account created successfully! Please login.", true);
                            ClearSignupForm();
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

        private string HashPassword(string password)
        {
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                var sb = new System.Text.StringBuilder();
                foreach (byte b in bytes) sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
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
}