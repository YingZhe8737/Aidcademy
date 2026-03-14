using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Aidcademy
{
    public partial class MainPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                TrackSiteVisit();
            }
        }

        // "Try For Free" button → goes to LearningCourse.aspx
        protected void btnTryFree_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearningCourse.aspx");
        }

        // "Send Feedback" button → goes to FeedbackForm.aspx
        protected void btnFeedback_Click1(object sender, EventArgs e)
        {
            Response.Redirect("FeedbackForm.aspx");
        }

        private void TrackSiteVisit()
        {
            string sessionID = Session.SessionID;
            string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                string insertQuery = @"
                    INSERT INTO SiteTraffic (SessionID, VisitDate, IsRegisteredUser)
                    VALUES (@SessionID, @VisitDate, @IsRegisteredUser)";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@SessionID", sessionID);
                    cmd.Parameters.AddWithValue("@VisitDate", DateTime.Now);
                    cmd.Parameters.AddWithValue("@IsRegisteredUser", false);
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
