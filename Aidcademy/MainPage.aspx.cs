using System;
using System.Configuration;
using System.Data.SqlClient;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class MainPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) TrackSiteVisit();
        }

        protected void btnTryFree_Click(object sender, EventArgs e) { Response.Redirect("LearningCourse.aspx"); }
        protected void btnFeedback_Click1(object sender, EventArgs e) { Response.Redirect("FeedbackForm.aspx"); }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/MainPage.aspx");
        }

        private void TrackSiteVisit()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString))
                {
                    conn.Open();
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO SiteTraffic (SessionID, VisitDate, IsRegisteredUser) VALUES (@SID, @VD, @IU)", conn))
                    {
                        cmd.Parameters.AddWithValue("@SID", Session.SessionID);
                        cmd.Parameters.AddWithValue("@VD", DateTime.Now);
                        cmd.Parameters.AddWithValue("@IU", Session["UserID"] != null);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }
        }
    }
}
