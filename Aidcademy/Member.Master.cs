using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Member : System.Web.UI.MasterPage
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsMember())
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
                                    ? reader["Username"].ToString() : displayName;

                                string photo = reader["ProfilePhoto"] != DBNull.Value
                                    ? reader["ProfilePhoto"].ToString() : "";

                                imgSidebarAvatar.ImageUrl = !string.IsNullOrEmpty(photo)
                                    ? "~/Uploads/ProfilePhotos/" + photo
                                    : "~/images/default-avatar.png";
                            }
                        }
                    }
                }
            }
            catch
            {
                lblSidebarName.Text = SessionHelper.GetUsername() ?? "Member";
                imgSidebarAvatar.ImageUrl = "~/images/default-avatar.png";
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        // Kept for compatibility with pages that still call these helpers
        protected string GetMemberName()
        {
            string name = SessionHelper.GetUsername();
            if (!string.IsNullOrWhiteSpace(name)) return name;
            name = Session["Name"]?.ToString();
            if (!string.IsNullOrWhiteSpace(name)) return name;
            return "Member";
        }

        protected string GetMemberInitial()
        {
            string name = GetMemberName().Trim();
            return name.Length > 0 ? name.Substring(0, 1).ToUpperInvariant() : "M";
        }

        protected bool IsActivePage(string pageName)
        {
            string path = Request.Url.AbsolutePath ?? string.Empty;
            return path.IndexOf(pageName, StringComparison.OrdinalIgnoreCase) >= 0;
        }
    }
}
