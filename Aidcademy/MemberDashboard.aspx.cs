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

            // Display name — UserName is set by SessionHelper.SetLoginSession
            lblMemberName.Text = SessionHelper.GetUsername().Length > 0
                ? SessionHelper.GetUsername()
                : Session["Name"]?.ToString() ?? "Member";

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
                                int totalPts = Convert.ToInt32(reader["TotalPoints"]);
                                lblDailyStreak.Text = reader["DailyStreak"].ToString();
                                lblTotalPoints.Text = totalPts.ToString();

                                if (totalPts >= 1000)
                                    lblBadge.Text = "<span class='badge bg-warning text-dark shadow-sm ms-2'>🥇 Gold</span>";
                                else if (totalPts >= 500)
                                    lblBadge.Text = "<span class='badge bg-secondary shadow-sm ms-2'>🥈 Silver</span>";
                                else if (totalPts >= 100)
                                    lblBadge.Text = "<span class='badge ms-2 shadow-sm' style='background-color:#cd7f32;'>🥉 Bronze</span>";
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

                    // Load recently completed courses
                    string queryRecentCompleted = @"
                        SELECT TOP 3 c.CourseID, c.Title, e.EnrolmentDate
                        FROM Enrollments e
                        INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 1
                        ORDER BY e.EnrolmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryRecentCompleted, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptCompletedCourses.DataSource = dt;
                        rptCompletedCourses.DataBind();
                        if (dt.Rows.Count > 0)
                            pnlCompletedSection.Visible = true;
                    }

                    // Load Leaderboard Data — derived from QuizResults so it works even if the Leaderboard table is empty
                    string queryLeaderboard = @"
                        SELECT TOP 10
                            p.UserID,
                            p.FullName,
                            MAX(qr.DateTaken) AS LastSolved,
                            ISNULL(SUM(CASE WHEN qr.DateTaken >= DATEADD(day, -7, GETDATE()) THEN qr.Score ELSE 0 END), 0) AS WeeklyPoints,
                            ISNULL(SUM(qr.Score), 0) AS TotalPoints
                        FROM UserProfiles p
                        LEFT JOIN QuizResults qr ON p.UserID = qr.UserID
                        GROUP BY p.UserID, p.FullName
                        HAVING ISNULL(SUM(qr.Score), 0) > 0
                        ORDER BY ISNULL(SUM(qr.Score), 0) DESC";

                    using (SqlCommand cmd = new SqlCommand(queryLeaderboard, conn))
                    {
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        gvLeaderboard.DataSource = dt;
                        gvLeaderboard.DataBind();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard error: " + ex.Message);
            }
        }

        protected void gvLeaderboard_RowDataBound(object sender, System.Web.UI.WebControls.GridViewRowEventArgs e)
        {
            if (e.Row.RowType == System.Web.UI.WebControls.DataControlRowType.DataRow)
            {
                int rowUserId = Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "UserID"));
                if (Session["UserID"] != null && rowUserId == Convert.ToInt32(Session["UserID"]))
                {
                    e.Row.CssClass = "table-warning fw-bold";
                }
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