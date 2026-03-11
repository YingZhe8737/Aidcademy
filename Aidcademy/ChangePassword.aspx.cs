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

                // Verify current password
                string checkQuery = "SELECT PasswordHash FROM Users WHERE UserID = @UserID";
                SqlParameter[] checkParams = { new SqlParameter("@UserID", userID) };

                string storedHash = DatabaseHelper.ExecuteScalar(checkQuery, checkParams)?.ToString();

                bool isPasswordCorrect = false;
                if (!string.IsNullOrEmpty(storedHash))
                {
                    try
                    {
                        isPasswordCorrect = BCrypt.Net.BCrypt.Verify(currentPassword, storedHash);
                    }
                    catch (BCrypt.Net.SaltParseException)
                    {
                        // Fallback to SHA if user hasn't migrated yet
                        isPasswordCorrect = (storedHash == SecurityHelper.HashPassword(currentPassword));
                    }
                }

                if (!isPasswordCorrect)
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
                ShowMessage("An error occurred. Please try again. (" + ex.Message + ")", false);
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
