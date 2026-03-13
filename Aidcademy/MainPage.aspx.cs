using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

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



        protected void btnTryFree_Click(object sender, EventArgs e)
        {
            Response.Redirect("LearningCourse.aspx");
        }
        protected void btnFeedback_Click(object sender, EventArgs e)
        {
            Response.Redirect("Feedback.aspx");
        }
        protected void btnAboutUs(object sender, EventArgs e)
        {
            Response.Redirect("About.aspx");
        }

        private void TrackSiteVisit()
        {
            string sessionID = Session.SessionID;
            string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Insert a new visit record for every page load
                string insertQuery = @"
            INSERT INTO SiteTraffic (SessionID, VisitDate, IsRegisteredUser)
            VALUES (@SessionID, @VisitDate, @IsRegisteredUser)";

                using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@SessionID", sessionID);
                    cmd.Parameters.AddWithValue("@VisitDate", DateTime.Now);
                    cmd.Parameters.AddWithValue("@IsRegisteredUser", false); // default: visitor
                    cmd.ExecuteNonQuery();
                }
            }
        }
    }
}