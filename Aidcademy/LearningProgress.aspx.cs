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
            if (!SessionHelper.IsUserLoggedIn())
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
                        (SELECT COUNT(*) FROM Lessons WHERE CourseID = c.CourseID) AS TotalLessons,
                        (SELECT COUNT(*)
                         FROM LessonProgress lp
                         INNER JOIN Lessons l ON lp.LessonID = l.LessonID
                         WHERE l.CourseID = c.CourseID
                           AND lp.UserID  = e.UserID
                           AND lp.Status  = 'Completed') AS CompletedLessons
                    FROM Enrollments e
                    INNER JOIN Courses c ON e.CourseID = c.CourseID
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

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}
