using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;

namespace Aidcademy
{
    public partial class Login_signup : System.Web.UI.Page
    {
        // Connection string from Web.config
        string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user is already logged in
                if (Session["MemberID"] != null)
                {
                    // Redirect based on role
                    if (Session["Role"] != null && Session["Role"].ToString() == "Admin")
                    {
                        Response.Redirect("AdminDashboard.aspx");
                    }
                    else if (Session["Role"] != null && Session["Role"].ToString() == "Instructor")
                    {
                        Response.Redirect("InstructorDashboard.aspx");
                    }
                    else
                    {
                        Response.Redirect("MemberDashboard.aspx");
                    }
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string emailOrUsername = txtLoginEmail.Text.Trim();
            string password = txtLoginPassword.Text.Trim();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    // Query to check login credentials
                    string query = @"
                        SELECT MemberID, FirstName, LastName, Email, Role, Status 
                        FROM Members 
                        WHERE (Email = @EmailOrUsername OR Username = @EmailOrUsername) 
                        AND Password = @Password";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@EmailOrUsername", emailOrUsername);
                        // In production, use hashed password comparison
                        cmd.Parameters.AddWithValue("@Password", HashPassword(password));

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Check account status
                                string status = reader["Status"].ToString();
                                if (status == "Suspended" || status == "Deactivated")
                                {
                                    ShowMessage("Your account has been " + status.ToLower() + ". Please contact support.", false);
                                    return;
                                }

                                // Store session variables
                                Session["MemberID"] = reader["MemberID"].ToString();
                                Session["FirstName"] = reader["FirstName"].ToString();
                                Session["LastName"] = reader["LastName"].ToString();
                                Session["Email"] = reader["Email"].ToString();
                                Session["Role"] = reader["Role"].ToString();

                                // Redirect based on role
                                string role = reader["Role"].ToString();
                                if (role == "Admin")
                                {
                                    Response.Redirect("AdminDashboard.aspx");
                                }
                                else if (role == "Instructor")
                                {
                                    Response.Redirect("InstructorDashboard.aspx");
                                }
                                else
                                {
                                    Response.Redirect("MemberDashboard.aspx");
                                }
                            }
                            else
                            {
                                ShowMessage("Invalid email/username or password.", false);
                            }
                        }
                    }
                }
                catch (Exception)
                {
                    ShowMessage("An error occurred during login. Please try again later.", false);
                }
            }
        }

        protected void btnSignup_Click(object sender, EventArgs e)
        {
            string fullName = txtSignupFullName.Text.Trim();
            // Split full name into first and last (everything after first space is last name)
            int spaceIndex = fullName.IndexOf(' ');
            string firstName = spaceIndex >= 0 ? fullName.Substring(0, spaceIndex).Trim() : fullName;
            string lastName  = spaceIndex >= 0 ? fullName.Substring(spaceIndex + 1).Trim() : "";
            string username = txtSignupUsername.Text.Trim();
            string email = txtSignupEmail.Text.Trim();
            string phone = txtSignupPhone.Text.Trim();
            string password = txtSignupPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            // Validate password match
            if (password != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            // Validate password strength
            if (!ValidatePassword(password))
            {
                ShowMessage("Password must be at least 8 characters with uppercase, lowercase, and numbers.", false);
                return;
            }

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                try
                {
                    conn.Open();

                    // Check if email already exists
                    string checkEmail = "SELECT COUNT(*) FROM Members WHERE Email = @Email";
                    using (SqlCommand cmdCheck = new SqlCommand(checkEmail, conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@Email", email);
                        int emailCount = (int)cmdCheck.ExecuteScalar();

                        if (emailCount > 0)
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
                        int usernameCount = (int)cmdCheck.ExecuteScalar();

                        if (usernameCount > 0)
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
                        cmd.Parameters.AddWithValue("@LastName", lastName);
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@Password", HashPassword(password));

                        int rowsAffected = cmd.ExecuteNonQuery();

                        if (rowsAffected > 0)
                        {
                            ShowMessage("Account created successfully! Please login.", true);
                            // Clear signup form
                            ClearSignupForm();
                        }
                        else
                        {
                            ShowMessage("Failed to create account. Please try again.", false);
                        }
                    }
                }
                catch (Exception)
                {
                    ShowMessage("An error occurred during registration. Please try again later.", false);
                }
            }
        }

        private bool ValidatePassword(string password)
        {
            // Check length
            if (password.Length < 8)
                return false;

            // Check for uppercase
            bool hasUpper = false;
            bool hasLower = false;
            bool hasDigit = false;

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
            // In production, use BCrypt, Argon2, or PBKDF2
            // This is a simplified example using SHA256
            using (var sha256 = System.Security.Cryptography.SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(System.Text.Encoding.UTF8.GetBytes(password));
                return Convert.ToBase64String(bytes);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "message success" : "message error";
        }

        private void ClearSignupForm()
        {
            txtSignupFullName.Text = "";
            txtSignupUsername.Text = "";
            txtSignupEmail.Text = "";
            txtSignupPhone.Text = "";
            txtSignupPassword.Text = "";
            txtConfirmPassword.Text = "";
        }
    }
}