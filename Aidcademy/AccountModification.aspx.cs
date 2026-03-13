using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class WebForm2 : System.Web.UI.Page
    {
        private string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {

              string fullName = txtFullName.Text.Trim();
            string username = txtUsername.Text.Trim();
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirm = txtConfirmPassword.Text.Trim();
            string role = ddlRole.SelectedValue;

            // ===============================
            // Validation
            // ===============================
            if (string.IsNullOrEmpty(fullName) ||
                string.IsNullOrEmpty(username) ||
                string.IsNullOrEmpty(email) ||
                string.IsNullOrEmpty(password) ||
                string.IsNullOrEmpty(role))
            {
                ShowMessage("Please fill all required fields.", false);
                return;
            }

            if (password != confirm)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            // Ensure role is valid (extra backend protection)
            if (role != "Admin" && role != "Instructor" && role != "Member")
            {
                ShowMessage("Invalid role selected.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Hash password
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                    // ===============================
                    // Insert into Users table
                    // ===============================
                    string insertUser = @"
                INSERT INTO Users (Username, Email, PasswordHash, Role, Status, CreatedAt)
                VALUES (@Username, @Email, @PasswordHash, @Role, 'Active', GETDATE());
                SELECT SCOPE_IDENTITY();";

                    int newUserId;

                    using (SqlCommand cmd = new SqlCommand(insertUser, conn))
                    {
                        cmd.Parameters.AddWithValue("@Username", username);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@PasswordHash", hashedPassword);
                        cmd.Parameters.AddWithValue("@Role", role);

                        newUserId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // ===============================
                    // Insert into UserProfiles table
                    // ===============================
                    string insertProfile = @"
                INSERT INTO UserProfiles (UserID, FullName, PhoneNumber)
                VALUES (@UserID, @FullName, NULL);";

                    using (SqlCommand profileCmd = new SqlCommand(insertProfile, conn))
                    {
                        profileCmd.Parameters.AddWithValue("@UserID", newUserId);
                        profileCmd.Parameters.AddWithValue("@FullName", fullName);

                        profileCmd.ExecuteNonQuery();
                    }
                }

                ShowMessage("Account created successfully!", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Registration error: " + ex.Message, false);
            }
        }
        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;

            if (isSuccess)
                lblMessage.CssClass = "success-message";
            else
                lblMessage.CssClass = "error-message";
        }


    }
}