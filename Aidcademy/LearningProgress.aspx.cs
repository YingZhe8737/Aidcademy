using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class LearningProgress : System.Web.UI.Page
    {
        private int userID;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsMember())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            userID = SessionHelper.GetUserID();

            if (!IsPostBack)
            {
                LoadSummaryStats();
                LoadCourseProgress();
                LoadQuizHistory();
                BuildActivityHeatmap();
                LoadXpLevel();
            }
        }

        // ── Section A: Summary Stat Cards ──────────────────────────
        private void LoadSummaryStats()
        {
            try
            {
                string query = @"
                    SELECT
                        (SELECT COUNT(*) FROM Enrollments WHERE UserID = @UID AND IsCompleted = 0) AS ActiveCourses,
                        (SELECT COUNT(*) FROM LessonProgress WHERE UserID = @UID AND Status = 'Completed') AS LessonsDone,
                        (SELECT AVG(CAST(Score AS FLOAT)) FROM QuizResults WHERE UserID = @UID) AS AvgScore,
                        (SELECT COUNT(*) FROM Enrollments WHERE UserID = @UID AND IsCompleted = 1) AS CompletedCourses";

                SqlParameter[] p = { new SqlParameter("@UID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);

                if (dt.Rows.Count > 0)
                {
                    DataRow r = dt.Rows[0];
                    lblActiveCourses.Text = r["ActiveCourses"].ToString();
                    lblLessonsDone.Text = r["LessonsDone"].ToString();
                    lblCompletedCourses.Text = r["CompletedCourses"].ToString();

                    if (r["AvgScore"] != DBNull.Value)
                        lblAvgScore.Text = Convert.ToDouble(r["AvgScore"]).ToString("F0") + "%";
                    else
                        lblAvgScore.Text = "N/A";
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadSummaryStats error: " + ex.Message);
            }
        }

        // ── Section B: Course Completion Cards ─────────────────────
        private void LoadCourseProgress()
        {
            try
            {
                string query = @"
                    SELECT
                        c.CourseID,
                        c.Title AS CourseName,
                        ISNULL(c.ThumbnailPath, '') AS ThumbnailPath,
                        e.ProgressPercentage,
                        CASE WHEN e.IsCompleted = 1 THEN 'Completed' ELSE 'In Progress' END AS Status,
                        e.CompletionDate,
                        (SELECT COUNT(*) FROM Lessons WHERE CourseID = c.CourseID AND ApprovalStatus = 'Approved') AS TotalLessons,
                        (SELECT COUNT(*) FROM LessonProgress lp
                           INNER JOIN Lessons l ON lp.LessonID = l.LessonID
                           WHERE l.CourseID = c.CourseID AND lp.UserID = e.UserID
                             AND lp.Status = 'Completed') AS CompletedLessons,
                        ISNULL(q.AvgScore, -1) AS AvgQuizScore,
                        (SELECT TOP 1 l.LessonID
                           FROM Lessons l
                           WHERE l.CourseID = c.CourseID
                             AND l.ApprovalStatus = 'Approved'
                             AND l.LessonID NOT IN (
                                 SELECT lp.LessonID FROM LessonProgress lp
                                 WHERE lp.UserID = @UID AND lp.Status = 'Completed')
                           ORDER BY l.SequenceOrder, l.LessonID) AS NextLessonID
                    FROM Enrollments e
                    INNER JOIN Courses c ON e.CourseID = c.CourseID
                    LEFT JOIN (
                        SELECT ls.CourseID, AVG(CAST(qr.Score AS FLOAT)) AS AvgScore
                        FROM QuizResults qr
                        INNER JOIN Quizzes qz ON qr.QuizID = qz.QuizID
                        INNER JOIN Lessons ls ON qz.LessonID = ls.LessonID
                        WHERE qr.UserID = @UID
                        GROUP BY ls.CourseID
                    ) q ON q.CourseID = c.CourseID
                    WHERE e.UserID = @UID
                    ORDER BY e.IsCompleted ASC, e.EnrollmentDate DESC";

                SqlParameter[] p = { new SqlParameter("@UID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
                pnlNoCourses.Visible = dt.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadCourseProgress error: " + ex.Message);
                pnlNoCourses.Visible = true;
            }
        }

        // ── Section C-Left: Quiz History ───────────────────────────
        private void LoadQuizHistory()
        {
            try
            {
                // Score is stored as XP (correct * 100 first try, correct * 50 retry)
                // TotalMarks = questionCount * 100 (max possible first-try XP)
                string query = @"
                    SELECT TOP 5
                        qr.Score,
                        qr.DateTaken,
                        l.Title AS LessonName,
                        c.Title AS CourseName,
                        (SELECT COUNT(*) FROM QuizQuestions qq WHERE qq.QuizID = qz.QuizID) * 100 AS TotalMarks
                    FROM QuizResults qr
                    INNER JOIN Quizzes qz ON qr.QuizID = qz.QuizID
                    INNER JOIN Lessons l  ON qz.LessonID = l.LessonID
                    INNER JOIN Courses c  ON l.CourseID = c.CourseID
                    WHERE qr.UserID = @UID
                    ORDER BY qr.DateTaken DESC";

                SqlParameter[] p = { new SqlParameter("@UID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                rptQuizHistory.DataSource = dt;
                rptQuizHistory.DataBind();
                pnlNoQuizzes.Visible = dt.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadQuizHistory error: " + ex.Message);
                pnlNoQuizzes.Visible = true;
            }
        }

        // ── Section C-Right: Activity Heatmap ──────────────────────
        private void BuildActivityHeatmap()
        {
            try
            {
                // Get distinct active dates from last 35 days
                string query = @"
                    SELECT DISTINCT CAST(ActiveDate AS DATE) AS ActiveDate FROM (
                        SELECT DateTaken AS ActiveDate FROM QuizResults WHERE UserID = @UID
                            AND DateTaken >= DATEADD(DAY, -35, GETDATE())
                        UNION
                        SELECT LastAccessedDate FROM LessonProgress WHERE UserID = @UID
                            AND LastAccessedDate >= DATEADD(DAY, -35, GETDATE())
                    ) combined";

                SqlParameter[] p = { new SqlParameter("@UID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);

                var activeDates = new HashSet<string>();
                foreach (DataRow r in dt.Rows)
                {
                    if (r["ActiveDate"] != DBNull.Value)
                        activeDates.Add(Convert.ToDateTime(r["ActiveDate"]).ToString("yyyy-MM-dd"));
                }

                // Build 5 weeks × 7 days grid (Mon-Sun)
                var sb = new StringBuilder();
                DateTime today = DateTime.Today;

                // Find the Monday of 4 weeks ago
                int daysBack = ((int)today.DayOfWeek + 6) % 7; // days since last Monday
                DateTime startMonday = today.AddDays(-(daysBack + 28)); // 4 weeks before this Monday

                string[] dayLabels = { "Mon", "", "Wed", "", "Fri", "", "Sun" };

                sb.Append("<div class='lp-heatmap-grid'>");

                // Day labels column
                sb.Append("<div class='lp-heatmap-labels'>");
                foreach (string label in dayLabels)
                    sb.AppendFormat("<div class='lp-heatmap-label'>{0}</div>", label);
                sb.Append("</div>");

                // 5 week columns
                for (int week = 0; week < 5; week++)
                {
                    sb.Append("<div class='lp-heatmap-col'>");
                    for (int day = 0; day < 7; day++)
                    {
                        DateTime cellDate = startMonday.AddDays(week * 7 + day);
                        bool isActive = activeDates.Contains(cellDate.ToString("yyyy-MM-dd"));
                        bool isFuture = cellDate > today;
                        string cls = isFuture ? "lp-hm-cell future" : (isActive ? "lp-hm-cell active" : "lp-hm-cell");
                        string tooltip = cellDate.ToString("MMM dd");
                        sb.AppendFormat("<div class='{0}' title='{1}'></div>", cls, tooltip);
                    }
                    sb.Append("</div>");
                }

                sb.Append("</div>");

                litHeatmap.Text = sb.ToString();

                // Streak from Leaderboard
                string streakQuery = "SELECT ISNULL(DailyStreak, 0) FROM Leaderboard WHERE UserID = @UID";
                object streakObj = DatabaseHelper.ExecuteScalar(streakQuery, new[] { new SqlParameter("@UID", userID) });
                int streak = streakObj != null && streakObj != DBNull.Value ? Convert.ToInt32(streakObj) : 0;
                lblStreak.Text = streak.ToString();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("BuildActivityHeatmap error: " + ex.Message);
                litHeatmap.Text = "<div class='text-muted small'>Activity data unavailable.</div>";
                lblStreak.Text = "0";
            }
        }

        // ── Section D: XP & Level Banner ───────────────────────────
        private void LoadXpLevel()
        {
            try
            {
                // Use SUM(QuizResults.Score) as single source of truth (matches leaderboard display)
                string query = "SELECT ISNULL(SUM(Score), 0) FROM QuizResults WHERE UserID = @UID";
                object xpObj = DatabaseHelper.ExecuteScalar(query, new[] { new SqlParameter("@UID", userID) });
                int totalXP = xpObj != null && xpObj != DBNull.Value ? Convert.ToInt32(xpObj) : 0;

                int level;
                int currentMin;
                int nextMin;
                string levelTitle;
                GetLevelInfo(totalXP, out level, out currentMin, out nextMin, out levelTitle);

                lblTotalXP.Text = totalXP.ToString("N0");
                lblLevel.Text = level.ToString();
                lblLevelTitle.Text = levelTitle;

                int progressInLevel = totalXP - currentMin;
                int levelRange = nextMin - currentMin;
                int xpPct = levelRange > 0 ? (int)Math.Min(100, (progressInLevel * 100.0 / levelRange)) : 100;
                lblXpToNext.Text = (nextMin - totalXP).ToString("N0");
                lblXpPct.Text = xpPct.ToString();
                xpBarFill.Style["width"] = xpPct + "%";
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadXpLevel error: " + ex.Message);
                lblTotalXP.Text = "0";
                lblLevel.Text = "1";
                lblLevelTitle.Text = "Beginner";
                lblXpToNext.Text = "500";
                lblXpPct.Text = "0";
                xpBarFill.Style["width"] = "0%";
            }
        }

        private void GetLevelInfo(int xp, out int level, out int currentMin, out int nextMin, out string title)
        {
            // Level tiers
            if (xp >= 4000)      { level = 5; currentMin = 4000; nextMin = 6000; title = "First Aid Expert"; }
            else if (xp >= 2000) { level = 4; currentMin = 2000; nextMin = 4000; title = "Advanced Responder"; }
            else if (xp >= 1000) { level = 3; currentMin = 1000; nextMin = 2000; title = "Skilled Learner"; }
            else if (xp >= 500)  { level = 2; currentMin = 500;  nextMin = 1000; title = "Active Learner"; }
            else                 { level = 1; currentMin = 0;    nextMin = 500;  title = "Beginner"; }
        }

        // ── Helpers ────────────────────────────────────────────────
        protected string GetThumbnailUrl(object path)
        {
            string s = path?.ToString() ?? "";
            if (string.IsNullOrWhiteSpace(s))
                return ResolveUrl("~/Image/logo.jpeg");
            return ResolveUrl("~/" + s.TrimStart('~', '/'));
        }

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId);
            return ResolveUrl("~/LearningCourse.aspx");
        }

        protected string GetQuizBadge(object scoreObj, object totalObj)
        {
            if (scoreObj == null || scoreObj == DBNull.Value) return "<span class='lp-quiz-badge retry'>N/A</span>";
            double score = Convert.ToDouble(scoreObj);
            double total = totalObj != null && totalObj != DBNull.Value ? Convert.ToDouble(totalObj) : 100;
            double pct = total > 0 ? (score / total) * 100 : 0;
            return pct >= 50
                ? "<span class='lp-quiz-badge pass'><i class='fas fa-check me-1'></i>Pass</span>"
                : "<span class='lp-quiz-badge retry'><i class='fas fa-redo me-1'></i>Retry</span>";
        }

        protected string GetScorePercent(object scoreObj, object totalObj)
        {
            if (scoreObj == null || scoreObj == DBNull.Value) return "0";
            double score = Convert.ToDouble(scoreObj);
            double total = totalObj != null && totalObj != DBNull.Value ? Convert.ToDouble(totalObj) : 100;
            return total > 0 ? ((score / total) * 100).ToString("F0") : "0";
        }
    }
}
