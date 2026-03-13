using System;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class VerifyOtp : Page
    {
        private string Purpose => Request.QueryString["purpose"] ?? "Login";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Must have a pending user to verify
                if (Purpose == "Login" && Session["PendingUserID"] == null)
                {
                    Response.Redirect("~/Login_signup.aspx");
                    return;
                }
                if (Purpose == "ForgotPassword" && Session["ResetPendingUserID"] == null)
                {
                    Response.Redirect("~/ForgotPassword.aspx");
                    return;
                }

                // Adjust subtitle based on purpose
                if (Purpose == "ForgotPassword")
                    lblSubtitle.Text = "We've sent a <strong>6-digit verification code</strong> to your email. " +
                                       "Enter it below to reset your password. The code expires in <strong>10 minutes</strong>.";
            }
        }

        // Verify OTP button
        protected void btnVerify_Click(object sender, EventArgs e)
        {
            string code = txtOtp.Value?.Trim() ?? "";

            if (code.Length != 6)
            {
                ShowMessage("Please enter all 6 digits of the OTP.", false);
                return;
            }

            try
            {
                if (Purpose == "Login")
                    HandleLoginVerification(code);
                else
                    HandleForgotPasswordVerification(code);
            }
            catch (Exception ex)
            {
                ShowMessage("Verification error: " + ex.Message, false);
            }
        }

        // Resend OTP button
        protected void btnResend_Click(object sender, EventArgs e)
        {
            try
            {
                int    userID;
                string email;

                if (Purpose == "Login")
                {
                    if (Session["PendingUserID"] == null)
                    {
                        Response.Redirect("~/Login_signup.aspx");
                        return;
                    }
                    userID = Convert.ToInt32(Session["PendingUserID"]);
                    email  = Session["PendingEmail"]?.ToString() ?? "";
                }
                else // ForgotPassword
                {
                    if (Session["ResetPendingUserID"] == null)
                    {
                        Response.Redirect("~/ForgotPassword.aspx");
                        return;
                    }
                    userID = Convert.ToInt32(Session["ResetPendingUserID"]);
                    email  = Session["ResetPendingEmail"]?.ToString() ?? "";
                }

                string newOtp = OtpHelper.SaveOtp(userID, Purpose);
                string errMsg;

                if (!EmailHelper.SendOtpEmail(email, newOtp, Purpose, out errMsg))
                {
                    ShowMessage("Could not resend OTP. Please check your email address or try again later. (" + errMsg + ")", false);
                    return;
                }

                ShowMessage("A new OTP has been sent to your email. Please check your inbox.", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Could not resend OTP: " + ex.Message, false);
            }
        }

        // Private helpers
        private void HandleLoginVerification(string code)
        {
            int userID = Convert.ToInt32(Session["PendingUserID"]);
            string role     = Session["PendingRole"]?.ToString()  ?? "Member";
            string fullName = Session["PendingName"]?.ToString()  ?? "Member";
            string email    = Session["PendingEmail"]?.ToString() ?? "";

            string errMsg;
            if (!OtpHelper.VerifyOtp(userID, code, "Login", out errMsg))
            {
                ShowMessage(errMsg, false);
                return;
            }

            // OTP valid - promote to full session
            Session.Remove("PendingUserID");
            Session.Remove("PendingRole");
            Session.Remove("PendingName");
            Session.Remove("PendingEmail");

            SessionHelper.SetLoginSession(userID, role, fullName, email);

            // Redirect by role
            if (role == "Admin")
                Response.Redirect("~/AdminDashboard.aspx");
            else if (role == "Instructor")
                Response.Redirect("~/InstructorManageContent.aspx");
            else
                Response.Redirect("~/MemberDashboard.aspx");
        }

        private void HandleForgotPasswordVerification(string code)
        {
            int userID = Convert.ToInt32(Session["ResetPendingUserID"]);

            string errMsg;
            if (!OtpHelper.VerifyOtp(userID, code, "ForgotPassword", out errMsg))
            {
                ShowMessage(errMsg, false);
                return;
            }

            // OTP valid - let the reset-password form show
            Session["ResetVerifiedUserID"] = userID;
            Session.Remove("ResetPendingUserID");
            Session.Remove("ResetPendingEmail");

            Response.Redirect("~/ForgotPassword.aspx?step=reset");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible    = true;
            lblMessage.Text       = message;
            lblMessage.CssClass   = isSuccess ? "message success" : "message error";
        }
    }
}
