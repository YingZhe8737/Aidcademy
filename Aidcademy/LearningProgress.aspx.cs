using System;
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

        // Build star HTML for the rating widget
        protected string BuildStars(object courseIdObj, object ratingObj)
        {
            int current = ratingObj != null && ratingObj != DBNull.Value ? Convert.ToInt32(ratingObj) : 0;
            var sb = new StringBuilder();
            for (int i = 1; i <= 5; i++)
            {
                string filled = i <= current ? " filled" : "";
                string color  = i <= current ? "color:#f59e0b;" : "color:#ddd;";
                sb.Append($"<button type='button' class='star-btn{filled}' style='{color}' title='Rate {i} star'>&#9733;</button>");
            }
            return sb.ToString();
        }

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId);
            return ResolveUrl("~/LearningCourse.aspx");
        }

        protected void rptProgress_ItemCommand(object source, System.Web.UI.WebControls.RepeaterCommandEventArgs e)
        {
            // Placeholder for future repeater commands
        }
    }
}
