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
            if (!IsPostBack)
                LoadDashboardData();
        }

        private void LoadDashboardData()
        {
            int userID = SessionHelper.GetUserID();

            lblMemberName.Text = SessionHelper.GetUsername().Length > 0
                ? SessionHelper.GetUsername()
                : "Member";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Stats
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT ISNULL(lb.DailyStreak,0) AS DailyStreak, ISNULL(lb.TotalPoints,0) AS TotalPoints
                          FROM Leaderboard lb WHERE lb.UserID = @UserID", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader r = cmd.ExecuteReader())
                        {
                            if (r.Read())
                            {
                                int pts = Convert.ToInt32(r["TotalPoints"]);
                                lblDailyStreak.Text = r["DailyStreak"].ToString();
                                lblTotalPoints.Text = pts.ToString();
                                if (pts >= 1000)
                                    lblBadge.Text = "<span class='badge bg-warning text-dark shadow-sm ms-2'>🥇 Gold</span>";
                                else if (pts >= 500)
                                    lblBadge.Text = "<span class='badge bg-secondary shadow-sm ms-2'>🥈 Silver</span>";
                                else if (pts >= 100)
                                    lblBadge.Text = "<span class='badge ms-2 shadow-sm' style='background-color:#cd7f32;'>🥉 Bronze</span>";
                            }
                            else
                            {
                                lblDailyStreak.Text = "0";
                                lblTotalPoints.Text = "0";
                            }
                        }
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Enrollments WHERE UserID=@UserID", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblEnrolledCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Enrollments WHERE UserID=@UserID AND IsCompleted=1", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblCompletedCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // In-progress courses
                    string queryCourses = @"
                        SELECT c.CourseID, c.Title AS CourseName, e.ProgressPercentage,
                            ISNULL(c.ThumbnailPath,'') AS PhotoPath,
                            (SELECT TOP 1 l.LessonID FROM Lessons l
                             WHERE l.CourseID = c.CourseID
                               AND l.ApprovalStatus = 'Approved'
                               AND l.LessonID NOT IN (
                                   SELECT lp.LessonID FROM LessonProgress lp
                                   WHERE lp.UserID = @UserID AND lp.Status = 'Completed')
                             ORDER BY l.SequenceOrder, l.LessonID) AS NextLessonID
                        FROM Enrollments e
                        INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 0
                        ORDER BY e.EnrollmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryCourses, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        rptEnrolledCourses.DataSource = dt;
                        rptEnrolledCourses.DataBind();
                        pnlNoCourses.Visible = dt.Rows.Count == 0;
                    }

                    // Recently completed
                    string queryCompleted = @"
                        SELECT TOP 3 c.CourseID, c.Title AS CourseName, e.EnrollmentDate
                        FROM Enrollments e INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 1
                        ORDER BY e.EnrollmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryCompleted, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        rptCompletedCourses.DataSource = dt;
                        rptCompletedCourses.DataBind();
                        pnlCompletedSection.Visible = dt.Rows.Count > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard error: " + ex.Message);
            }

            // Leaderboard
            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();
                    string q = @"
                        SELECT TOP 10
                            p.UserID,
                            ISNULL(NULLIF(p.FullName,''),'Anonymous') AS FullName,
                            MAX(qr.DateTaken) AS LastSolved,
                            ISNULL(SUM(CASE WHEN qr.DateTaken >= DATEADD(day,-7,GETDATE()) THEN qr.Score ELSE 0 END),0) AS WeeklyPoints,
                            ISNULL(SUM(qr.Score),0) AS TotalPoints
                        FROM UserProfiles p
                        LEFT JOIN QuizResults qr ON p.UserID = qr.UserID
                        GROUP BY p.UserID, p.FullName
                        HAVING ISNULL(SUM(qr.Score),0) > 0
                        ORDER BY ISNULL(SUM(qr.Score),0) DESC";

                    using (SqlCommand cmd = new SqlCommand(q, conn))
                    {
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        rptLeaderboard.DataSource = dt;
                        rptLeaderboard.DataBind();
                        pnlEmptyLeaderboard.Visible = dt.Rows.Count == 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Leaderboard error: " + ex.Message);
            }
        }

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId);
            return ResolveUrl("~/LearningProgress.aspx");
        }

        protected string GetRankClass(int index)
        {
            if (index == 0) return "rank-gold";
            if (index == 1) return "rank-silver";
            if (index == 2) return "rank-bronze";
            return "rank-other";
        }

        protected string GetRankIcon(int index)
        {
            if (index == 0) return "🥇";
            if (index == 1) return "🥈";
            if (index == 2) return "🥉";
            return (index + 1).ToString();
        }
    }
}
