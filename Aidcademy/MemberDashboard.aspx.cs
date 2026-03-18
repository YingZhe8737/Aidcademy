using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Text;
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

            string name = SessionHelper.GetDisplayName();
            lblMemberName.Text = name;
            lblUserInitial.Text = SessionHelper.GetInitial();

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // streak, points
                    // leaderboard table display
                    string queryStats = @"
                        SELECT
                            ISNULL(lb.DailyStreak, 0) AS DailyStreak,
                            ISNULL((SELECT SUM(Score) FROM QuizResults WHERE UserID = @UserID), 0) AS TotalPoints
                        FROM Leaderboard lb
                        WHERE lb.UserID = @UserID";

                    int dailyStreak = 0;
                    int totalPoints = 0;

                    using (SqlCommand cmd = new SqlCommand(queryStats, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                dailyStreak = Convert.ToInt32(reader["DailyStreak"]);
                                totalPoints = Convert.ToInt32(reader["TotalPoints"]);
                            }
                            else
                            {
                                // No Leaderboard row yet — still calculate points from QuizResults
                                reader.Close();
                                using (SqlCommand cmd2 = new SqlCommand("SELECT ISNULL(SUM(Score), 0) FROM QuizResults WHERE UserID = @UserID", conn))
                                {
                                    cmd2.Parameters.AddWithValue("@UserID", userID);
                                    totalPoints = Convert.ToInt32(cmd2.ExecuteScalar());
                                }
                            }
                        }
                    }

                    lblDailyStreak.Text = dailyStreak.ToString();
                    lblTotalPoints.Text = totalPoints.ToString("N0");

                    // Personal best streak
                    lblPersonalBest.Text = dailyStreak.ToString();

                    // Monthly points
                    string queryMonthly = @"
                        SELECT ISNULL(SUM(qr.Score), 0)
                        FROM QuizResults qr
                        WHERE qr.UserID = @UserID
                          AND qr.DateTaken >= DATEADD(day, -30, GETDATE())";
                    using (SqlCommand cmd = new SqlCommand(queryMonthly, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblMonthlyPoints.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                    }

                    // Enrolled & completed counts
                    int enrolled = 0, completed = 0;
                    using (SqlCommand cmd = new SqlCommand(
                        @"SELECT COUNT(*) AS Enrolled,
                                 SUM(CASE WHEN IsCompleted = 1 THEN 1 ELSE 0 END) AS Completed
                          FROM Enrollments WHERE UserID = @UserID", conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader rdr = cmd.ExecuteReader())
                        {
                            if (rdr.Read())
                            {
                                enrolled = Convert.ToInt32(rdr["Enrolled"]);
                                completed = rdr["Completed"] != DBNull.Value ? Convert.ToInt32(rdr["Completed"]) : 0;
                            }
                        }
                        lblEnrolledCourses.Text = enrolled.ToString();
                        lblCompletedCourses.Text = completed.ToString();
                    }

                    // Leaderboard rank
                    string queryRank = @"
                        SELECT COUNT(*) + 1
                        FROM (
                            SELECT p2.UserID, ISNULL(SUM(qr2.Score), 0) AS Pts
                            FROM UserProfiles p2
                            LEFT JOIN QuizResults qr2 ON p2.UserID = qr2.UserID
                            GROUP BY p2.UserID
                            HAVING ISNULL(SUM(qr2.Score), 0) > 0
                        ) ranked
                        WHERE ranked.Pts > (
                            SELECT ISNULL(SUM(Score), 0)
                            FROM QuizResults WHERE UserID = @UserID
                        )";
                    using (SqlCommand cmd = new SqlCommand(queryRank, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        int rank = Convert.ToInt32(cmd.ExecuteScalar());
                        lblLeaderboardRank.Text = totalPoints > 0 ? rank.ToString() : "-";

                        // Percentile
                        if (totalPoints > 0)
                        {
                            string queryTotal = "SELECT COUNT(*) FROM UserProfiles";
                            using (SqlCommand cmdTotal = new SqlCommand(queryTotal, conn))
                            {
                                int totalUsers = Convert.ToInt32(cmdTotal.ExecuteScalar());
                                if (totalUsers > 0)
                                {
                                    int percentile = (int)Math.Round((1.0 - (double)(rank - 1) / totalUsers) * 100);
                                    lblRankPercentile.Text = "Top " + Math.Max(1, Math.Min(100, percentile)) + "%";
                                }
                            }
                        }
                    }

                    // Overall progress
                    if (enrolled > 0)
                    {
                        string queryOverall = "SELECT ISNULL(AVG(ProgressPercentage), 0) FROM Enrollments WHERE UserID = @UserID";
                        using (SqlCommand cmd = new SqlCommand(queryOverall, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserID", userID);
                            lblOverallProgress.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString();
                        }
                    }

                    // Quizzes passed
                    string queryQuizzes = @"
                        SELECT
                            (SELECT COUNT(*) FROM QuizResults WHERE UserID = @UserID AND Score > 0) AS Passed,
                            (SELECT COUNT(DISTINCT qz.QuizID)
                             FROM Quizzes qz
                             INNER JOIN Lessons l ON qz.LessonID = l.LessonID
                             INNER JOIN Enrollments e ON l.CourseID = e.CourseID AND e.UserID = @UserID) AS Total";
                    using (SqlCommand cmd = new SqlCommand(queryQuizzes, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblQuizzesPassed.Text = reader["Passed"] + "/" + reader["Total"];
                            }
                        }
                    }

                    // Weekly streak days
                    BuildStreakDays(conn, userID, dailyStreak);

                    // Load in-progress courses
                    string queryCourses = @"
                        SELECT c.CourseID,
                               c.Title AS CourseName,
                               ISNULL(c.Category, 'General') AS Category,
                               ISNULL(c.Description, '') AS CourseDescription,
                               ISNULL(NULLIF(c.ThumbnailPath, ''), 'image/Logo.jpeg') AS PhotoPath,
                               e.ProgressPercentage,
                               'Aidcademy' AS InstructorName,
                            (SELECT COUNT(*) FROM Lessons l WHERE l.CourseID = c.CourseID AND l.ApprovalStatus = 'Approved') AS TotalLessons,
                            (SELECT COUNT(*) FROM LessonProgress lp
                             INNER JOIN Lessons l ON lp.LessonID = l.LessonID
                             WHERE l.CourseID = c.CourseID AND lp.UserID = @UserID AND lp.Status = 'Completed') AS CompletedLessons,
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
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);
                        rptEnrolledCourses.DataSource = dt;
                        rptEnrolledCourses.DataBind();
                        pnlNoCourses.Visible = dt.Rows.Count == 0;
                    }

                    // Recently completed
                    string queryRecentCompleted = @"
                        SELECT TOP 3 c.CourseID, c.Title AS CourseName, e.EnrollmentDate
                        FROM Enrollments e
                        INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 1
                        ORDER BY e.EnrollmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryRecentCompleted, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);
                        rptCompletedCourses.DataSource = dt;
                        rptCompletedCourses.DataBind();
                        if (dt.Rows.Count > 0)
                            pnlCompletedSection.Visible = true;
                    }

                    // Filter Role='Member' so admins/instructors are excluded
                    string queryLeaderboard = @"
                        SELECT
                            u.UserID,
                            ISNULL(p.FullName, u.Username)    AS FullName,
                            ISNULL(MAX(lb.DailyStreak), 0)    AS DailyStreak,
                            ISNULL(SUM(qr.Score), 0)          AS TotalPoints,
                            (SELECT COUNT(*) FROM Enrollments e WHERE e.UserID = u.UserID) AS CourseCount
                        FROM Users u
                        LEFT JOIN UserProfiles p  ON p.UserID  = u.UserID
                        LEFT JOIN QuizResults  qr ON qr.UserID = u.UserID
                        LEFT JOIN Leaderboard  lb ON lb.UserID = u.UserID
                        WHERE u.Role = 'Member'
                          AND u.Status = 'Active'
                        GROUP BY u.UserID, p.FullName, u.Username
                        HAVING ISNULL(SUM(qr.Score), 0) > 0
                        ORDER BY ISNULL(SUM(qr.Score), 0) DESC";

                    using (SqlCommand cmd = new SqlCommand(queryLeaderboard, conn))
                    {
                        DataTable dt = new DataTable();
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                            da.Fill(dt);

                        BuildPodium(dt);

                        if (dt.Rows.Count > 3)
                        {
                            DataTable tableData = dt.Clone();
                            for (int i = 3; i < dt.Rows.Count; i++)
                                tableData.ImportRow(dt.Rows[i]);
                            rptLeaderboard.DataSource = tableData;
                            rptLeaderboard.DataBind();
                        }

                        pnlEmptyLeaderboard.Visible = dt.Rows.Count == 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard error: " + ex.Message);
            }
        }

        private void BuildStreakDays(SqlConnection conn, int userID, int dailyStreak)
        {
            string[] dayNames = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };
            int todayIndex = ((int)DateTime.Now.DayOfWeek + 6) % 7; 

            var sb = new StringBuilder();
            for (int i = 0; i < 7; i++)
            {
                bool isActive = i <= todayIndex && dailyStreak > (todayIndex - i);
                sb.Append("<div class='streak-day'>");
                sb.AppendFormat("<div class='fire-icon {0}'>", isActive ? "active" : "inactive");
                sb.Append("<i class='fas fa-fire'></i></div>");
                sb.AppendFormat("<span class='day-label'>{0}</span>", dayNames[i]);
                sb.Append("</div>");
            }
            litStreakDays.Text = sb.ToString();
        }

        private void BuildPodium(DataTable dt)
        {
            if (dt.Rows.Count == 0)
            {
                pnlPodium.Visible = false;
                return;
            }

            string[] avatarBgs = { "avatar-gold", "avatar-silver", "avatar-brown" };
            string[] trophies = { "&#129351;", "&#129352;", "&#129353;" };
            int[] order = dt.Rows.Count >= 3 ? new[] { 1, 0, 2 } :
                          dt.Rows.Count == 2 ? new[] { 1, 0 } : new[] { 0 };

            var sb = new StringBuilder();
            foreach (int idx in order)
            {
                if (idx >= dt.Rows.Count) continue;
                DataRow row = dt.Rows[idx];
                string name = row["FullName"].ToString();
                string initials = name.Length > 0 ? name.Substring(0, 1).ToUpper() : "?";
                // Try to get second initial from last name
                string[] parts = name.Split(' ');
                if (parts.Length > 1 && parts[1].Length > 0)
                    initials += parts[1].Substring(0, 1).ToUpper();

                bool isFirst = idx == 0;
                string[] itemClasses = { "podium-item first", "podium-item second", "podium-item third" };
                string itemClass = itemClasses[idx];

                sb.AppendFormat("<div class='{0}'>", itemClass);
                if (isFirst)
                    sb.Append("<div class='podium-crown'>&#128081;</div>");
                sb.AppendFormat("<div class='podium-avatar {0}'>{1}</div>", avatarBgs[idx], initials);
                sb.Append("<div class='podium-card'>");
                sb.AppendFormat("<div class='podium-trophy'>{0}</div>", trophies[idx]);
                sb.AppendFormat("<div class='podium-name'>{0}</div>", Server.HtmlEncode(name));
                sb.AppendFormat("<div class='podium-pts'>{0:N0}</div>", Convert.ToInt32(row["TotalPoints"]));
                sb.Append("<div class='podium-pts-label'>pts</div>");
                sb.Append("</div></div>");
            }
            litPodium.Text = sb.ToString();
        }

        public string GetAvatarColor(int index)
        {
            string[] colors = { "avatar-purple", "avatar-orange", "avatar-pink", "avatar-teal", "avatar-blue", "avatar-green", "avatar-red" };
            return colors[index % colors.Length];
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
