using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class ForgotPassword : System.Web.UI.Page
    {
        private readonly string connectionString =
            ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string step = Request.QueryString["step"];

                if (step == "reset")
                {
                    // OTP was already verified 
                    if (Session["ResetVerifiedUserID"] == null)
                    {
                        Response.Redirect("~/ForgotPassword.aspx");
                        return;
                    }
                    pnlEmailForm.Visible = false;
                    pnlResetForm.Visible = true;
                }
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string email = txtEmail.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowMessage("Please enter your email address.", false);
                return;
            }

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string query = "SELECT UserID FROM Users WHERE Email = @Email AND Status = 'Active'";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", email);
                        object result = cmd.ExecuteScalar();

                        if (result == null)
                        {
                            ShowMessage("If that email is registered, you'll receive a code shortly.", true);
                            return;
                        }

                        int userID = Convert.ToInt32(result);

                        Session["ResetPendingUserID"] = userID;
                        Session["ResetPendingEmail"]  = email;

                        // Generate and email the OTP
                        string otp = OtpHelper.SaveOtp(userID, "ForgotPassword");
                        string errMsg;

                        if (!EmailHelper.SendOtpEmail(email, otp, "ForgotPassword", out errMsg))
                        {
                            ShowMessage($"OTP generated (dev mode - code: {otp}). Configure SMTP to receive by email.", true);
                        }

                        Response.Redirect("~/VerifyOtp.aspx?purpose=ForgotPassword");
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred. Please try again. (" + ex.Message + ")", false);
            }
        }

        protected void btnReset_Click(object sender, EventArgs e)
        {
            if (Session["ResetVerifiedUserID"] == null)
            {
                ShowMessage("Session expired. Please start over.", false);
                return;
            }

            string newPassword     = txtNewPassword.Text.Trim();
            string confirmPassword = txtConfirmNewPassword.Text.Trim();

            if (newPassword != confirmPassword)
            {
                ShowMessage("Passwords do not match.", false);
                return;
            }

            string pwdError;
            if (!SecurityHelper.IsPasswordValid(newPassword, out pwdError))
            {
                ShowMessage(pwdError, false);
                return;
            }

            try
            {
                int userID = Convert.ToInt32(Session["ResetVerifiedUserID"]);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string updatePassword =
                        "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(updatePassword, conn))
                    {
                        string newHash = BCrypt.Net.BCrypt.HashPassword(newPassword);
                        cmd.Parameters.AddWithValue("@PasswordHash", newHash);
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        cmd.ExecuteNonQuery();
                    }
                }

                // Clear the reset session key
                Session.Remove("ResetVerifiedUserID");

                ShowMessage("Password reset successfully! Redirecting to login...", true);
                Response.AddHeader("REFRESH", "3;URL=Login_signup.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred. Please try again. (" + ex.Message + ")", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text       = message;
            pnlMessage.Visible    = true;
            pnlMessage.CssClass   = isSuccess ? "message success" : "message error";
        }
    }
}