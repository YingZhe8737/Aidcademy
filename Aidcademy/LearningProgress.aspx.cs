using System;
using System.Data;
using System.Data.SqlClient;
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
                LoadProgress();
            }
        }

        private void LoadProgress()
        {
            try
            {
                string query = @"
                    SELECT
                        c.CourseID,
                        c.Title                        AS CourseName,
                        e.ProgressPercentage,
                        e.EnrollmentDate,
                        CASE WHEN e.IsCompleted = 1 THEN 'Completed' ELSE 'In Progress' END AS Status,
                        (SELECT TOP 1 l.LessonID
                            FROM Lessons l
                            WHERE l.CourseID = c.CourseID
                            AND l.LessonID NOT IN (
                                SELECT lp.LessonID FROM LessonProgress lp
                                WHERE lp.UserID = @UserID AND lp.Status = 'Completed'
                            )
                            ORDER BY l.SequenceOrder, l.LessonID) AS NextLessonID,
                        (SELECT COUNT(*) FROM Lessons WHERE CourseID = c.CourseID) AS TotalLessons,
                        (SELECT COUNT(*)
                         FROM LessonProgress lp
                         INNER JOIN Lessons l ON lp.LessonID = l.LessonID
                         WHERE l.CourseID = c.CourseID
                           AND lp.UserID  = e.UserID
                           AND lp.Status  = 'Completed') AS CompletedLessons,
                        ISNULL(q.AvgScore, -1) AS AvgQuizScore
                    FROM Enrollments e
                    INNER JOIN Courses c ON e.CourseID = c.CourseID
                    LEFT JOIN (
                        SELECT ls.CourseID, AVG(qr.Score) as AvgScore 
                        FROM QuizResults qr
                        INNER JOIN Quizzes qz ON qr.QuizID = qz.QuizID
                        INNER JOIN Lessons ls ON qz.LessonID = ls.LessonID
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

        protected string GetContinueUrl(object lessonId)
        {
            if (lessonId != null && lessonId != DBNull.Value)
                return ResolveUrl("~/ViewLesson.aspx?LessonID=" + lessonId.ToString());
            return ResolveUrl("~/LearningCourse.aspx");
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}
