using System;
using System.Data;
using System.Data.SqlClient;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
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
            hfCurrentUserId.Value = userID.ToString();

            if (!IsPostBack)
                LoadProgress();
        }

        private void LoadProgress()
        {
            try
            {
                string query = @"
                    SELECT
                        c.CourseID,
                        c.Title                                                         AS CourseName,
                        e.ProgressPercentage,
                        e.EnrollmentDate,
                        CASE WHEN e.IsCompleted = 1 THEN 'Completed' ELSE 'In Progress' END AS Status,
                        NULL                                                            AS CompletionDate,
                        (SELECT TOP 1 l.LessonID
                           FROM Lessons l
                           WHERE l.CourseID = c.CourseID
                             AND l.ApprovalStatus = 'Approved'
                             AND l.LessonID NOT IN (
                                 SELECT lp.LessonID FROM LessonProgress lp
                                 WHERE lp.UserID = @UserID AND lp.Status = 'Completed')
                           ORDER BY l.SequenceOrder, l.LessonID)                        AS NextLessonID,
                        (SELECT COUNT(*) FROM Lessons WHERE CourseID = c.CourseID AND ApprovalStatus = 'Approved')
                                                                                        AS TotalLessons,
                        (SELECT COUNT(*) FROM LessonProgress lp
                           INNER JOIN Lessons l ON lp.LessonID = l.LessonID
                           WHERE l.CourseID = c.CourseID AND lp.UserID = e.UserID
                             AND lp.Status = 'Completed')                               AS CompletedLessons,
                        ISNULL(q.AvgScore, -1)                                          AS AvgQuizScore,
                        0                                                               AS MyRating
                    FROM Enrollments e
                    INNER JOIN Courses c ON e.CourseID = c.CourseID
                    LEFT JOIN (
                        SELECT ls.CourseID, AVG(CAST(qr.Score AS FLOAT)) AS AvgScore
                        FROM QuizResults qr
                        INNER JOIN Quizzes qz  ON qr.QuizID  = qz.QuizID
                        INNER JOIN Lessons ls  ON qz.LessonID = ls.LessonID
                        WHERE qr.UserID = @UserID
                        GROUP BY ls.CourseID
                    ) q ON q.CourseID = c.CourseID
                    WHERE e.UserID = @UserID
                    ORDER BY e.EnrollmentDate DESC";

                SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                rptProgress.DataSource = dt;
                rptProgress.DataBind();
                pnlNoProgress.Visible = dt.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Progress error: " + ex.Message);
                pnlNoProgress.Visible = true;
            }
        }

        private static string NormalizeLessonTitle(string title)
        {
            if (string.IsNullOrWhiteSpace(title))
                return "Untitled Lesson";

            // Remove duplicated prefixes like: "Step 1: Lesson 1: ..."
            string normalized = Regex.Replace(title, @"^\s*Step\s*\d+\s*:\s*", "", RegexOptions.IgnoreCase).Trim();
            return normalized;
        }

        protected string BuildLessonRatings(object courseIdObj)
        {
            if (courseIdObj == null || courseIdObj == DBNull.Value)
                return "<div class='text-muted small'>No lessons available yet.</div>";

            try
            {
            int courseId = Convert.ToInt32(courseIdObj);
            string query = @"
                SELECT TOP 5
                    l.LessonID,
                    l.SequenceOrder,
                    l.Title,
                    0 AS CurrentRating
                FROM Lessons l
                WHERE l.CourseID = @CourseID
                  AND l.ApprovalStatus = 'Approved'
                ORDER BY SequenceOrder, LessonID";

            DataTable lessons = DatabaseHelper.ExecuteQuery(query, new[]
            {
                new SqlParameter("@CourseID", courseId),
                new SqlParameter("@UserID", userID)
            });
            if (lessons.Rows.Count == 0)
                return "<div class='text-muted small'>No lessons available yet.</div>";

            var sb = new StringBuilder();
            sb.Append("<div class='lesson-rating-list'>");

            foreach (DataRow row in lessons.Rows)
            {
                int lessonId = Convert.ToInt32(row["LessonID"]);
                int sequence = row["SequenceOrder"] != DBNull.Value ? Convert.ToInt32(row["SequenceOrder"]) : 0;
                int currentRating = row["CurrentRating"] != DBNull.Value ? Convert.ToInt32(row["CurrentRating"]) : 0;
                string title = NormalizeLessonTitle(row["Title"]?.ToString() ?? string.Empty);

                sb.Append("<div class='lesson-rating-item'>");
                sb.Append("<div class='lesson-rating-title'>");
                sb.Append(HttpUtility.HtmlEncode(sequence > 0 ? $"Lesson {sequence}: {title}" : title));
                sb.Append("</div>");

                sb.Append("<div class='lesson-rating-right'>");
                sb.Append($"<div class='stars lesson-stars' data-lessonid='{lessonId}'>");
                for (int i = 1; i <= 5; i++)
                {
                    string filled = i <= currentRating ? " filled" : "";
                    string color = i <= currentRating ? " style='color:#f59e0b;'" : "";
                    sb.Append($"<button type='button' class='star-btn small-star{filled}'{color} title='Rate lesson {i} star'>&#9733;</button>");
                }
                sb.Append("</div>");
                sb.Append($"<div class='lesson-rating-msg' id='lessonRatingMsg_{lessonId}'></div>");
                sb.Append("</div>");

                sb.Append("</div>");
            }

            sb.Append("</div>");
            return sb.ToString();
            }
            catch
            {
                return "<div class='text-muted small'>Rating not available.</div>";
            }
        }

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId);
            return ResolveUrl("~/LearningCourse.aspx");
        }

        protected string GetProgressWidthStyle(object progressPercentage)
        {
            double pct = 0;
            if (progressPercentage != null && progressPercentage != DBNull.Value)
                pct = Convert.ToDouble(progressPercentage);

            if (pct < 0) pct = 0;
            if (pct > 100) pct = 100;
            return "width:" + pct.ToString("0.##") + "%";
        }

        protected void rptProgress_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            // Placeholder for future repeater commands
        }
    }
}
