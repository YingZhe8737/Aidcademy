using System;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class MemberProfile : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;
        private int userID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            userID = Convert.ToInt32(Session["UserID"]);

            if (!IsPostBack)
                LoadProfile();
        }

        private void LoadProfile()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"
                        SELECT u.Username, u.Email,
                               p.FullName, p.PhoneNumber, p.ProfilePhoto, p.Bio
                        FROM Users u
                        LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                        WHERE u.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtUsername.Text = reader["Username"].ToString();
                                txtEmail.Text = reader["Email"].ToString();

                                // Split full name into first and last for the UI fields
                                string fullName = reader["FullName"] != DBNull.Value
                                                  ? reader["FullName"].ToString()
                                                  : "";
                                string[] nameParts = fullName.Split(new[] { ' ' }, 2);
                                txtFirstName.Text = nameParts.Length > 0 ? nameParts[0] : "";
                                txtLastName.Text = nameParts.Length > 1 ? nameParts[1] : "";

                                txtPhone.Text = reader["PhoneNumber"] != DBNull.Value
                                                ? reader["PhoneNumber"].ToString()
                                                : "";

                                string photo = reader["ProfilePhoto"] != DBNull.Value
                                               ? reader["ProfilePhoto"].ToString()
                                               : "";

                                if (!string.IsNullOrEmpty(photo))
                                {
                                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                }
                                else
                                {
                                    imgProfile.ImageUrl = "~/images/default-avatar.png";
                                    imgProfilePreview.ImageUrl = "~/images/default-avatar.png";
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load your profile. (" + ex.Message + ")", false);
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            try
            {
                string photoFileName = null;

                if (fuProfilePhoto != null && fuProfilePhoto.HasFile)
                {
                    string ext = System.IO.Path.GetExtension(fuProfilePhoto.FileName).ToLower();
                    if (ext != ".jpg" && ext != ".jpeg" && ext != ".png" && ext != ".gif")
                    {
                        ShowMessage("Please upload a valid image file (JPG, PNG, GIF).", false);
                        return;
                    }
                    if (fuProfilePhoto.PostedFile.ContentLength > 2 * 1024 * 1024)
                    {
                        ShowMessage("Profile photo must be smaller than 2 MB.", false);
                        return;
                    }

                    string folder = Server.MapPath("~/Uploads/ProfilePhotos/");
                    if (!Directory.Exists(folder))
                        Directory.CreateDirectory(folder);

                    photoFileName = userID + "_" + DateTime.Now.Ticks + ext;
                    fuProfilePhoto.SaveAs(Path.Combine(folder, photoFileName));

                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                }

                string fullName = (txtFirstName.Text.Trim() + " " + txtLastName.Text.Trim()).Trim();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Update email in Users table
                    string updateUser = "UPDATE Users SET Email = @Email WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(updateUser, conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        cmd.ExecuteNonQuery();
                    }

                    // Update profile details in UserProfiles
                    string updateProfile;
                    if (photoFileName != null)
                    {
                        updateProfile = @"UPDATE UserProfiles SET
                                            FullName     = @FullName,
                                            PhoneNumber  = @PhoneNumber,
                                            ProfilePhoto = @ProfilePhoto
                                          WHERE UserID = @UserID";
                    }
                    else
                    {
                        updateProfile = @"UPDATE UserProfiles SET
                                            FullName    = @FullName,
                                            PhoneNumber = @PhoneNumber
                                          WHERE UserID = @UserID";
                    }

                    using (SqlCommand cmd = new SqlCommand(updateProfile, conn))
                    {
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@PhoneNumber", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        if (photoFileName != null)
                            cmd.Parameters.AddWithValue("@ProfilePhoto", photoFileName);

                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0)
                            Session["UserName"] = fullName;
                    }
                }

                // --- Password change (only if any password field is filled) ---
                string current = txtCurrentPassword.Text.Trim();
                string newPwd  = txtNewPassword.Text.Trim();
                string confirm = txtConfirmNewPassword.Text.Trim();

                if (!string.IsNullOrEmpty(current) || !string.IsNullOrEmpty(newPwd) || !string.IsNullOrEmpty(confirm))
                {
                    if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(newPwd) || string.IsNullOrEmpty(confirm))
                    {
                        ShowMessage("Profile saved. Please fill in all three password fields to change your password.", false);
                        return;
                    }

                    if (newPwd != confirm)
                    {
                        ShowMessage("Profile saved, but new passwords do not match.", false);
                        return;
                    }

                    string errMsg;
                    if (!SecurityHelper.IsPasswordValid(newPwd, out errMsg))
                    {
                        ShowMessage("Profile saved, but password not changed: " + errMsg, false);
                        return;
                    }

                    string currentHash = SecurityHelper.HashPassword(current);
                    string checkQuery  = "SELECT PasswordHash FROM Users WHERE UserID = @UserID";
                    SqlParameter[] checkParams = { new SqlParameter("@UserID", userID) };
                    string storedHash = DatabaseHelper.ExecuteScalar(checkQuery, checkParams)?.ToString();

                    if (storedHash == null || storedHash != currentHash)
                    {
                        ShowMessage("Profile saved, but current password is incorrect.", false);
                        return;
                    }

                    string newHash     = SecurityHelper.HashPassword(newPwd);
                    string updatePwdQ  = "UPDATE Users SET PasswordHash = @PasswordHash WHERE UserID = @UserID";
                    SqlParameter[] pwdParams =
                    {
                        new SqlParameter("@PasswordHash", newHash),
                        new SqlParameter("@UserID", userID)
                    };
                    DatabaseHelper.ExecuteNonQuery(updatePwdQ, pwdParams);

                    txtCurrentPassword.Text    = "";
                    txtNewPassword.Text        = "";
                    txtConfirmNewPassword.Text = "";
                    ShowMessage("Profile and password updated successfully!", true);
                    return;
                }

                ShowMessage("Your profile has been updated successfully!", true);
            }
            catch (Exception ex)
            {
                ShowMessage("Could not update profile. (" + ex.Message + ")", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = isSuccess ? "message success" : "message error";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}