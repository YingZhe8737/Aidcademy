using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class InstructorManageContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int currentInstructorId = 1; // Your testing ID
                BindDashboardCards(currentInstructorId);
                // You can also write a quick method here to count Total Lessons for your top stat cards!
            }
        }

        private void BindDashboardCards(int instructorId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Join Lessons and Courses to get all the info for the card
                string query = @"SELECT l.LessonID, l.Title AS LessonTitle, c.Category, c.ApprovalStatus 
                                 FROM Lessons l 
                                 INNER JOIN Courses c ON l.CourseID = c.CourseID 
                                 WHERE c.UserID = @InstructorID
                                 ORDER BY l.LessonID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", instructorId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptLessons.DataSource = dt;
                        rptLessons.DataBind();
                    }
                }
            }
        }

        // This handles what happens when an instructor clicks Edit or Delete
        protected void rptLessons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int lessonId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditLesson")
            {
                // Redirect to the Edit page, attaching the ID to the URL
                Response.Redirect("InstructorEditContent.aspx?LessonID=" + lessonId);
            }
            else if (e.CommandName == "DeleteLesson")
            {
                // Write your DELETE SQL command here using the lessonId
                // BindDashboardCards(1); // Refresh the page after deleting
            }
        }
    }
}