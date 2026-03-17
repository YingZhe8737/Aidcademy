using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class InstructorManageContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        private int currentInstructorId
        {
            get { return Convert.ToInt32(Session["UserID"]); }
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

                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT COUNT(*) FROM Lessons l
                      INNER JOIN Courses c ON l.CourseID = c.CourseID
                      WHERE c.UserID = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblTotal.Text = cmd.ExecuteScalar().ToString();
                }

                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT COUNT(*) FROM Lessons l
                      INNER JOIN Courses c ON l.CourseID = c.CourseID
                      WHERE c.UserID = @ID AND l.ApprovalStatus = 'Pending Admin'", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblPending.Text = cmd.ExecuteScalar().ToString();
                }

                // Count both "Published" and "Approved" as published
                using (SqlCommand cmd = new SqlCommand(
                    @"SELECT COUNT(*) FROM Lessons l
                      INNER JOIN Courses c ON l.CourseID = c.CourseID
                      WHERE c.UserID = @ID AND l.ApprovalStatus IN ('Published','Approved')", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    lblPublished.Text = cmd.ExecuteScalar().ToString();
                }

                try
                {
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(*) FROM CourseQuestions cq
                          INNER JOIN Courses c ON cq.CourseID = c.CourseID
                          WHERE c.UserID = @ID AND cq.Status = 'Open'", conn))
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
                string query = @"SELECT c.CourseID,
                                        c.Title          AS CourseTitle,
                                        ISNULL(c.Category,'General') AS Category,
                                        c.Description    AS CourseDescription,
                                        c.ThumbnailPath  AS CourseThumbnailPath,
                                        (SELECT COUNT(*) FROM Enrollments e WHERE e.CourseID = c.CourseID) AS EnrolledCount
                                 FROM Courses c
                                 WHERE c.UserID = @InstructorID
                                 ORDER BY c.CourseID DESC";

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
                    // Count lesson completions — defensive: checks whether IsCompleted column exists
                    // Falls back to simple COUNT(*) from LessonProgress if column is missing
                    string completedExpr;
                    try
                    {
                        using (SqlCommand chk = new SqlCommand(
                            "SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='LessonProgress' AND COLUMN_NAME='IsCompleted'", conn))
                        {
                            conn.Open();
                            int exists = (int)chk.ExecuteScalar();
                            completedExpr = exists > 0
                                ? "(SELECT COUNT(DISTINCT lp.UserID) FROM LessonProgress lp WHERE lp.LessonID = l.LessonID AND lp.IsCompleted = 1)"
                                : "(SELECT COUNT(DISTINCT lp.UserID) FROM LessonProgress lp WHERE lp.LessonID = l.LessonID)";
                        }
                    }
                    catch
                    {
                        completedExpr = "0";
                        if (conn.State != ConnectionState.Open) conn.Open();
                    }

                    if (conn.State != ConnectionState.Open) conn.Open();

                    string query = $@"SELECT l.LessonID,
                                             l.Title        AS LessonTitle,
                                             l.SequenceOrder,
                                             ISNULL(l.ApprovalStatus,'Draft') AS ApprovalStatus,
                                             l.Description  AS LessonDescription,
                                             l.ThumbnailPath AS LessonThumbnailPath,
                                             {completedExpr} AS CompletedCount
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
                foreach (string sql in new[] {
                    "DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID=@LID)",
                    "DELETE FROM Quizzes WHERE LessonID=@LID",
                    "DELETE FROM LessonSimulations WHERE LessonID=@LID",
                    "DELETE FROM LessonProgress WHERE LessonID=@LID",
                    "DELETE FROM Lessons WHERE LessonID=@LID"
                })
                {
                    using (SqlCommand cmd = new SqlCommand(sql, conn))
                    { cmd.Parameters.AddWithValue("@LID", lessonId); cmd.ExecuteNonQuery(); }
                }
            }
            BindCourses();
            BindDashboardStats();
        }
    }
}
