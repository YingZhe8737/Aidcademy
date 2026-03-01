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
        int currentInstructorId = 1; // Testing ID

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCourses(); // Updated to call BindCourses
            }
        }

        // 1. Bind the Outer Repeater (Courses)
        private void BindCourses()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT CourseID, Title AS CourseTitle, Category FROM Courses WHERE UserID = @InstructorID ORDER BY CourseID DESC";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", currentInstructorId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        // Using the new rptCourses ID!
                        rptCourses.DataSource = dt;
                        rptCourses.DataBind();
                    }
                }
            }
        }

        // 2. Bind the Inner Repeater (Lessons per Course)
        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                int courseId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "CourseID"));
                Repeater rptLessons = (Repeater)e.Item.FindControl("rptLessons");

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"SELECT l.LessonID, l.Title AS LessonTitle, l.SequenceOrder, c.ApprovalStatus 
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

        // 3. Button Click Handlers
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
                // Delete associated quizzes first to prevent constraint errors
                new SqlCommand($"DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID = {lessonId})", conn).ExecuteNonQuery();
                new SqlCommand($"DELETE FROM Quizzes WHERE LessonID = {lessonId}", conn).ExecuteNonQuery();
                new SqlCommand($"DELETE FROM Lessons WHERE LessonID = {lessonId}", conn).ExecuteNonQuery();
            }

            BindCourses(); // Refreshes the new Course list!
        }
    }
}