using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Instructor : System.Web.UI.MasterPage
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsInstructor())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            LoadSidebarProfile();
        }

        private void LoadSidebarProfile()
        {
            int userId = Convert.ToInt32(Session["UserID"]);

            try
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"SELECT u.Username,
                                            ISNULL(p.FullName, u.Username) AS DisplayName,
                                            p.ProfilePhoto
                                     FROM Users u
                                     LEFT JOIN UserProfiles p ON u.UserID = p.UserID
                                     WHERE u.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Set the display name
                                string displayName = reader["DisplayName"].ToString();
                                lblSidebarName.Text = string.IsNullOrEmpty(displayName)
                                    ? reader["Username"].ToString()
                                    : displayName;

                                // Set the profile photo or fallback to default
                                string photo = reader["ProfilePhoto"] != DBNull.Value
                                    ? reader["ProfilePhoto"].ToString()
                                    : "";

                                if (!string.IsNullOrEmpty(photo))
                                    imgSidebarProfile.ImageUrl = "~/Uploads/ProfilePhotos/" + photo;
                                else
                                    imgSidebarProfile.ImageUrl = "~/images/default-avatar.png";
                            }
                        }
                    }
                }
            }
            catch
            {
                // Fallback silently — sidebar will show default
                lblSidebarName.Text = Session["Username"] != null
                    ? Session["Username"].ToString()
                    : "Instructor";
                imgSidebarProfile.ImageUrl = "~/images/default-avatar.png";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}
