using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Admin : System.Web.UI.MasterPage
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
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
                                string displayName = reader["DisplayName"].ToString();
                                lblSidebarName.Text = string.IsNullOrEmpty(displayName)
                                    ? reader["Username"].ToString()
                                    : displayName;

                                string photo = reader["ProfilePhoto"] != DBNull.Value
                                    ? reader["ProfilePhoto"].ToString() : "";

                                imgSidebarProfile.ImageUrl = !string.IsNullOrEmpty(photo)
                                    ? "~/Uploads/ProfilePhotos/" + photo
                                    : "~/images/default-avatar.png";
                            }
                        }
                    }
                }
            }
            catch
            {
                lblSidebarName.Text = Session["Username"] != null
                    ? Session["Username"].ToString() : "Admin";
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
