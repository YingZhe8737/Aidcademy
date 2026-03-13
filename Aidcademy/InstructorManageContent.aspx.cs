using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class InstructorManageContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        private int currentInstructorId
        {
            get
            {
                if (Session["UserID"] != null) return Convert.ToInt32(Session["UserID"]);
                else return 1;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses();
                BindDashboardStats();
            }
        }

        private void BindDashboardStats()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Total Lessons
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons l INNER JOIN Courses c ON l.CourseID = c.CourseID WHERE c.UserID = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblTotal.Text = cmd.ExecuteScalar().ToString();
                }

                // Pending Lessons (Updated to check the 'l.ApprovalStatus' on the Lessons table!)
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons l INNER JOIN Courses c ON l.CourseID = c.CourseID WHERE c.UserID = @ID AND l.ApprovalStatus = 'Pending Admin'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblPending.Text = cmd.ExecuteScalar().ToString();
                }

                // Published Lessons (Updated to check the 'l.ApprovalStatus' on the Lessons table!)
                using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Lessons l INNER JOIN Courses c ON l.CourseID = c.CourseID WHERE c.UserID = @ID AND l.ApprovalStatus = 'Published'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblPublished.Text = cmd.ExecuteScalar().ToString();
                }

                // Open Q&A
                try
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM CourseQuestions cq INNER JOIN Courses c ON cq.CourseID = c.CourseID WHERE c.UserID = @ID AND cq.Status = 'Open'", conn))
                    {
                        cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                        lblQueries.Text = cmd.ExecuteScalar().ToString();
                    }
                }
                catch { lblQueries.Text = "0"; }
            }
        }

        private void BindCourses()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // UPDATED: Added CourseDescription and CourseThumbnailPath to the SELECT statement
                string query = @"SELECT CourseID, 
                                        Title AS CourseTitle, 
                                        ISNULL(Category, 'General') AS Category, 
                                        Description AS CourseDescription, 
                                        ThumbnailPath AS CourseThumbnailPath 
                                 FROM Courses 
                                 WHERE UserID = @InstructorID 
                                 ORDER BY CourseID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", currentInstructorId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptCourses.DataSource = dt;
                        rptCourses.DataBind();
                    }
                }
            }
        }

        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                int courseId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "CourseID"));
                Repeater rptLessons = (Repeater)e.Item.FindControl("rptLessons");

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    // UPDATED: Added LessonDescription and LessonThumbnailPath
                    string query = @"SELECT l.LessonID, 
                                            l.Title AS LessonTitle, 
                                            l.SequenceOrder, 
                                            ISNULL(l.ApprovalStatus, 'Draft') AS ApprovalStatus,
                                            l.Description AS LessonDescription,
                                            l.ThumbnailPath AS LessonThumbnailPath
                                     FROM Lessons l 
                                     INNER JOIN Courses c ON l.CourseID = c.CourseID 
                                     WHERE l.CourseID = @CourseID
                                     ORDER BY l.SequenceOrder ASC";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", courseId);
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
        }

        protected void btnEditLesson_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            Response.Redirect("InstructorEditContent.aspx?LessonID=" + btn.CommandArgument);
        }

        protected void btnDeleteLesson_Click(object sender, EventArgs e)
        {
            LinkButton btn = (LinkButton)sender;
            int lessonId = Convert.ToInt32(btn.CommandArgument);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                new SqlCommand($"DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID = {lessonId})", conn).ExecuteNonQuery();
                new SqlCommand($"DELETE FROM Quizzes WHERE LessonID = {lessonId}", conn).ExecuteNonQuery();
                new SqlCommand($"DELETE FROM Lessons WHERE LessonID = {lessonId}", conn).ExecuteNonQuery();
            }
            BindCourses();
            BindDashboardStats();
        }
    }
}