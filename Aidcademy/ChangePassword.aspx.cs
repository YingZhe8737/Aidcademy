using System;
using System.Data.SqlClient;
using Aidcademy.Utilities;
using System.Web.UI;

namespace Aidcademy
{
    public partial class ChangePassword : System.Web.UI.Page
    {
        private int userID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
            userID = SessionHelper.GetUserID();
        }

        protected void btnChangePassword_Click(object sender, EventArgs e)
        {
            try
            {
                string currentPassword = txtCurrentPassword.Text.Trim();
                string newPassword = txtNewPassword.Text.Trim();
                string confirmPassword = txtConfirmPassword.Text.Trim();

                if (string.IsNullOrEmpty(currentPassword) || string.IsNullOrEmpty(newPassword) || string.IsNullOrEmpty(confirmPassword))
                {
                    ShowMessage("Please fill in all fields.", false);
                    return;
                }

                if (newPassword != confirmPassword)
                {
                    ShowMessage("New passwords do not match.", false);
                    return;
                }

                string errorMessage;
                if (!SecurityHelper.IsPasswordValid(newPassword, out errorMessage))
                {
                    ShowMessage(errorMessage, false);
                    return;
                }

                // Verify current password using shared helper (BCrypt + SHA fallback)
                string storedHash = DatabaseHelper.ExecuteScalar(
                    "SELECT PasswordHash FROM Users WHERE UserID = @UserID",
                    new[] { new SqlParameter("@UserID", userID) })?.ToString();

                if (!SecurityHelper.VerifyStoredPassword(currentPassword, storedHash))
                {
                    ShowMessage("Your current password is incorrect.", false);
                    return;
                }

                // Save new password
                string newHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
                string updateQuery = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID";
                SqlParameter[] updateParams =
                {
                    new SqlParameter("@PasswordHash", newHash),
                    new SqlParameter("@UserID", userID)
                };

                DatabaseHelper.ExecuteNonQuery(updateQuery, updateParams);
                ShowMessage("Password changed successfully!", true);
                ClearForm();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("ChangePassword error: " + ex.Message);
                ShowMessage("An error occurred. Please try again later.", false);
            }
        }

        private void ClearForm()
        {
            txtCurrentPassword.Text = string.Empty;
            txtNewPassword.Text = string.Empty;
            txtConfirmPassword.Text = string.Empty;
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "message success" : "message error";
        }
    }
}
