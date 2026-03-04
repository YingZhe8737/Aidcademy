using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class MemberDashboard : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsMember())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int userID = Convert.ToInt32(Session["UserID"]);

            // Display name
            lblMemberName.Text = Session["UserName"]?.ToString() ?? "Member";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    string queryStats = @"
                        SELECT
                            ISNULL(lb.DailyStreak, 0) AS DailyStreak,
                            ISNULL(lb.TotalPoints, 0) AS TotalPoints
                        FROM Leaderboard lb
                        WHERE lb.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(queryStats, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblDailyStreak.Text = reader["DailyStreak"].ToString();
                                lblTotalPoints.Text = reader["TotalPoints"].ToString();
                            }
                            else
                            {
                                lblDailyStreak.Text = "0";
                                lblTotalPoints.Text = "0";
                            }
                        }
                    }

                    string queryEnrolled = "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(queryEnrolled, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblEnrolledCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    string queryCompleted = "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND IsCompleted = 1";
                    using (SqlCommand cmd = new SqlCommand(queryCompleted, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblCompletedCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Load in-progress courses
                    string queryCourses = @"
                        SELECT c.CourseID, c.Title AS CourseName, e.ProgressPercentage,
                            (SELECT TOP 1 l.LessonID
                             FROM Lessons l
                             WHERE l.CourseID = c.CourseID
                               AND l.LessonID NOT IN (
                                   SELECT lp.LessonID FROM LessonProgress lp
                                   WHERE lp.UserID = @UserID AND lp.Status = 'Completed'
                               )
                             ORDER BY l.SequenceOrder, l.LessonID) AS NextLessonID
                        FROM Enrollments e
                        INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 0
                        ORDER BY e.EnrollmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryCourses, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptEnrolledCourses.DataSource = dt;
                        rptEnrolledCourses.DataBind();
                        pnlNoCourses.Visible = dt.Rows.Count == 0;
                    }

                    string queryActivity = @"
                        SELECT TOP 5
                            l.Title      AS LessonTitle,
                            c.Title      AS CourseName,
                            lp.LastAccessedDate
                        FROM LessonProgress lp
                        INNER JOIN Lessons l  ON lp.LessonID = l.LessonID
                        INNER JOIN Courses c  ON l.CourseID  = c.CourseID
                        WHERE lp.UserID = @UserID
                        ORDER BY lp.LastAccessedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryActivity, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptRecentActivity.DataSource = dt;
                        rptRecentActivity.DataBind();
                        pnlNoActivity.Visible = dt.Rows.Count == 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard error: " + ex.Message);
            }
        }

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId.ToString());
            return ResolveUrl("~/LearningProgress.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}