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
        private bool isViewingOther = false;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            int currentUserId = Convert.ToInt32(Session["UserID"]);

            // Check if a different UserID is being requested 
            if (Request.QueryString["UserID"] != null)
            {
                int requestedId = Convert.ToInt32(Request.QueryString["UserID"]);
                string role = Session["Role"] != null ? Session["Role"].ToString() : "Member";

                // Only Instructors and Admins can view other users' profiles
                if (requestedId != currentUserId && (role == "Instructor" || role == "Admin"))
                {
                    userID = requestedId;
                    isViewingOther = true;
                }
                else
                {
                    userID = currentUserId;
                }
            }
            else
            {
                userID = currentUserId;
            }

            if (!IsPostBack)
            {
                if (isViewingOther)
                    LoadReadOnlyProfile();
                else
                    LoadOwnProfile();
            }
        }

        //  Read-only view of another user 
        private void LoadReadOnlyProfile()
        {
            pnlViewOnlyBanner.Visible = true;
            pnlReadOnly.Visible = true;
            pnlEdit.Visible = false;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"SELECT u.Username, u.Email, u.Role,
                                            ISNULL(p.FullName, u.Username) AS FullName,
                                            p.PhoneNumber, p.ProfilePhoto, p.Bio
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
                                string fullName = reader["FullName"].ToString();
                                string role = reader["Role"].ToString();
                                string photo = reader["ProfilePhoto"] != DBNull.Value
                                                  ? reader["ProfilePhoto"].ToString() : "";

                                lblProfileName.Text = string.IsNullOrEmpty(fullName) ? reader["Username"].ToString() : fullName;
                                lblProfileRole.Text = role + " Account";
                                lblROUsername.Text = reader["Username"].ToString();
                                lblROEmail.Text = reader["Email"].ToString();
                                lblROFullName.Text = fullName;
                                lblROPhone.Text = reader["PhoneNumber"] != DBNull.Value ? reader["PhoneNumber"].ToString() : "—";
                                lblROBio.Text = reader["Bio"] != DBNull.Value && !string.IsNullOrEmpty(reader["Bio"].ToString())
                                                       ? reader["Bio"].ToString() : "No bio provided.";

                                imgProfile.ImageUrl = !string.IsNullOrEmpty(photo)
                                                       ? "~/Uploads/ProfilePhotos/" + photo
                                                       : "~/image/default-avatar.png";
                            }
                            else
                            {
                                Response.Redirect("~/Login_signup.aspx");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadReadOnlyProfile error: " + ex.Message);
                ShowMessage("Could not load this profile.", false);
            }
        }

        // Editable own profile 
        private void LoadOwnProfile()
        {
            pnlViewOnlyBanner.Visible = false;
            pnlReadOnly.Visible = false;
            pnlEdit.Visible = true;

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    string query = @"SELECT u.Username, u.Email, u.Role,
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
                                string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "";
                                string photo = reader["ProfilePhoto"] != DBNull.Value ? reader["ProfilePhoto"].ToString() : "";

                                lblProfileName.Text = string.IsNullOrEmpty(fullName) ? reader["Username"].ToString() : fullName;
                                lblProfileRole.Text = reader["Role"].ToString() + " Account";
                                txtUsername.Text = reader["Username"].ToString();
                                txtEmail.Text = reader["Email"].ToString();

                                string[] parts = fullName.Split(new[] { ' ' }, 2);
                                txtFirstName.Text = parts.Length > 0 ? parts[0] : "";
                                txtLastName.Text = parts.Length > 1 ? parts[1] : "";
                                txtPhone.Text = reader["PhoneNumber"] != DBNull.Value ? reader["PhoneNumber"].ToString() : "";
                                txtBio.Text = reader["Bio"] != DBNull.Value ? reader["Bio"].ToString() : "";

                                if (!string.IsNullOrEmpty(photo))
                                {
                                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                }
                                else
                                {
                                    imgProfile.ImageUrl = "~/image/default-avatar.png";
                                    imgProfilePreview.ImageUrl = "~/image/default-avatar.png";
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadOwnProfile error: " + ex.Message);
                ShowMessage("Could not load your profile. Please try again later.", false);
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            if (isViewingOther) return; // Safety — cannot save someone else's profile

            try
            {
                string photoFileName = null;

                if (fuProfilePhoto != null && fuProfilePhoto.HasFile)
                {
                    string ext = Path.GetExtension(fuProfilePhoto.FileName).ToLower();
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
                    if (!Directory.Exists(folder)) Directory.CreateDirectory(folder);
                    photoFileName = userID + "_" + DateTime.Now.Ticks + ext;
                    fuProfilePhoto.SaveAs(Path.Combine(folder, photoFileName));
                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                }

                string fullName = (txtFirstName.Text.Trim() + " " + txtLastName.Text.Trim()).Trim();

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("UPDATE Users SET Email = @Email WHERE UserID = @UserID", conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        cmd.ExecuteNonQuery();
                    }
                    string updateProfile = @"UPDATE UserProfiles SET FullName=@FN, PhoneNumber=@PH, Bio=@Bio" +
                        (photoFileName != null ? ", ProfilePhoto=@PP" : "") + " WHERE UserID=@UserID";
                    using (SqlCommand cmd = new SqlCommand(updateProfile, conn))
                    {
                        cmd.Parameters.AddWithValue("@FN", fullName);
                        cmd.Parameters.AddWithValue("@PH", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bio", txtBio.Text.Trim());
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        if (photoFileName != null) cmd.Parameters.AddWithValue("@PP", photoFileName);
                        int rows = cmd.ExecuteNonQuery();
                        if (rows > 0) Session["UserName"] = fullName;
                    }
                }

                string current = txtCurrentPassword.Text.Trim();
                string newPwd = txtNewPassword.Text.Trim();
                string confirm = txtConfirmNewPassword.Text.Trim();

                if (!string.IsNullOrEmpty(current) || !string.IsNullOrEmpty(newPwd) || !string.IsNullOrEmpty(confirm))
                {
                    if (string.IsNullOrEmpty(current) || string.IsNullOrEmpty(newPwd) || string.IsNullOrEmpty(confirm))
                    { ShowMessage("Profile saved. Fill in all three password fields to change your password.", false); return; }
                    if (newPwd != confirm)
                    { ShowMessage("Profile saved, but new passwords do not match.", false); return; }

                    string errMsg;
                    if (!SecurityHelper.IsPasswordValid(newPwd, out errMsg))
                    { ShowMessage("Profile saved, but password not changed: " + errMsg, false); return; }

                    string storedHash = DatabaseHelper.ExecuteScalar(
                        "SELECT PasswordHash FROM Users WHERE UserID = @UserID",
                        new[] { new SqlParameter("@UserID", userID) })?.ToString();

                    if (!SecurityHelper.VerifyStoredPassword(current, storedHash))
                    { ShowMessage("Profile saved, but current password is incorrect.", false); return; }

                    string newHash = BCrypt.Net.BCrypt.HashPassword(newPwd);
                    DatabaseHelper.ExecuteNonQuery(
                        "UPDATE Users SET PasswordHash=@PH WHERE UserID=@UID",
                        new[] { new SqlParameter("@PH", newHash), new SqlParameter("@UID", userID) });

                    txtCurrentPassword.Text = txtNewPassword.Text = txtConfirmNewPassword.Text = "";
                    ShowMessage("Profile and password updated successfully!", true);
                    return;
                }

                // Refresh the name in the header
                lblProfileName.Text = string.IsNullOrEmpty(fullName)
                    ? txtUsername.Text : fullName;

                ShowMessage("Your profile has been updated successfully!", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("UpdateProfile error: " + ex.Message);
                ShowMessage("Could not update profile. Please try again later.", false);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            pnlMessage.CssClass = isSuccess ? "message success" : "message error";
        }
    }
}
