using System;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class InstructorProfile : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        private int currentInstructorId
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsInstructor())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfile();
            }
        }

        private void LoadProfile()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"
                        SELECT u.Username, u.Email,
                               p.FullName, p.PhoneNumber, p.ProfilePhoto, p.Bio
                        FROM Users u
                        LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                        WHERE u.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                txtUsername.Text = reader["Username"].ToString();
                                txtEmail.Text = reader["Email"].ToString();
                                txtBio.Text = reader["Bio"] != DBNull.Value ? reader["Bio"].ToString() : "";
                                txtPhone.Text = reader["PhoneNumber"] != DBNull.Value ? reader["PhoneNumber"].ToString() : "";

                                string fullName = reader["FullName"] != DBNull.Value ? reader["FullName"].ToString() : "";
                                string[] nameParts = fullName.Split(new[] { ' ' }, 2);
                                txtFirstName.Text = nameParts.Length > 0 ? nameParts[0] : "";
                                txtLastName.Text = nameParts.Length > 1 ? nameParts[1] : "";

                                string photo = reader["ProfilePhoto"] != DBNull.Value ? reader["ProfilePhoto"].ToString() : "";
                                if (!string.IsNullOrEmpty(photo))
                                {
                                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load profile data: " + ex.Message, false);
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            try
            {
                string photoFileName = null;

                if (fuProfilePhoto.HasFile)
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

                    photoFileName = "Instructor_" + currentInstructorId + "_" + DateTime.Now.Ticks + ext;
                    fuProfilePhoto.SaveAs(Path.Combine(folder, photoFileName));

                    imgProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                    imgProfilePreview.ImageUrl = "~/Uploads/ProfilePhotos/" + photoFileName;
                }

                string fullName = (txtFirstName.Text.Trim() + " " + txtLastName.Text.Trim()).Trim();

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    conn.Open();

                    // Update Email
                    using (SqlCommand cmd = new SqlCommand("UPDATE Users SET Email = @Email WHERE UserID = @UserID", conn))
                    {
                        cmd.Parameters.AddWithValue("@Email", txtEmail.Text.Trim());
                        cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                        cmd.ExecuteNonQuery();
                    }

                    // Check if UserProfile exists
                    int profileCount = 0;
                    using (SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM UserProfiles WHERE UserID = @UserID", conn))
                    {
                        cmdCheck.Parameters.AddWithValue("@UserID", currentInstructorId);
                        profileCount = Convert.ToInt32(cmdCheck.ExecuteScalar());
                    }

                    string profileQuery = "";
                    if (profileCount == 0)
                    {
                        profileQuery = "INSERT INTO UserProfiles (UserID, FullName, PhoneNumber, Bio, ProfilePhoto) VALUES (@UserID, @FullName, @PhoneNumber, @Bio, @ProfilePhoto)";
                    }
                    else
                    {
                        profileQuery = photoFileName != null
                            ? "UPDATE UserProfiles SET FullName=@FullName, PhoneNumber=@PhoneNumber, Bio=@Bio, ProfilePhoto=@ProfilePhoto WHERE UserID=@UserID"
                            : "UPDATE UserProfiles SET FullName=@FullName, PhoneNumber=@PhoneNumber, Bio=@Bio WHERE UserID=@UserID";
                    }

                    using (SqlCommand cmd = new SqlCommand(profileQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@PhoneNumber", txtPhone.Text.Trim());
                        cmd.Parameters.AddWithValue("@Bio", txtBio.Text.Trim());

                        if (profileCount == 0 && photoFileName == null)
                            cmd.Parameters.AddWithValue("@ProfilePhoto", DBNull.Value);
                        else if (photoFileName != null)
                            cmd.Parameters.AddWithValue("@ProfilePhoto", photoFileName);

                        cmd.ExecuteNonQuery();
                    }

                    Session["UserName"] = fullName;
                    ShowMessage("Instructor profile updated successfully!", true);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error saving profile: " + ex.Message, false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            pnlMessage.Visible = true;
            lblMessage.Text = message;
            lblMessage.CssClass = isSuccess ? "alert-box alert-success d-block" : "alert-box alert-danger d-block";
        }
    }
}