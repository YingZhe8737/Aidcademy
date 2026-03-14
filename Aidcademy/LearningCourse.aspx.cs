using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class LearningCourse : System.Web.UI.Page
    {
        private bool isMember;
        private int userID;

        protected void Page_Load(object sender, EventArgs e)
        {
            isMember = SessionHelper.IsUserLoggedIn() && SessionHelper.IsMember();
            userID = isMember ? SessionHelper.GetUserID() : 0;

            // Adaptive navbar
            pnlMemberNav.Visible = isMember;
            pnlVisitorNav.Visible = !isMember;

            // Visitor info banner
            pnlVisitorNote.Visible = !isMember;

            if (!IsPostBack)
                LoadCourses();
        }

        private void LoadCourses()
        {
            try
            {
                if (isMember)
                {
                    string query = @"
                        SELECT
                            c.CourseID,
                            c.Title         AS CourseName,
                            c.Description   AS CourseDescription,
                            ISNULL(c.ThumbnailPath,'') AS PhotoPath,
                            c.Category,
                            ISNULL(e.ProgressPercentage, 0) AS ProgressPercentage,
                            CASE WHEN e.EnrollmentID IS NOT NULL THEN 1 ELSE 0 END AS IsEnrolled,
                            1 AS IsMember,
                            NULL AS FreeLessonID,
                            (SELECT TOP 1 l.LessonID FROM Lessons l
                             WHERE l.CourseID = c.CourseID AND l.ApprovalStatus = 'Approved'
                               AND l.LessonID NOT IN (
                                   SELECT lp.LessonID FROM LessonProgress lp
                                   WHERE lp.UserID = @UserID AND lp.Status = 'Completed')
                             ORDER BY l.SequenceOrder, l.LessonID) AS NextLessonID
                        FROM Courses c
                        LEFT JOIN Enrollments e ON c.CourseID = e.CourseID AND e.UserID = @UserID
                        ORDER BY c.Title";

                    SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                    DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                }
                else
                {
                    // Visitor: show all courses; only CPR course gets a free lesson entry
                    string query = @"
                        SELECT
                            c.CourseID,
                            c.Title         AS CourseName,
                            c.Description   AS CourseDescription,
                            ISNULL(c.ThumbnailPath,'') AS PhotoPath,
                            c.Category,
                            0 AS ProgressPercentage,
                            0 AS IsEnrolled,
                            0 AS IsMember,
                            CASE
                                WHEN (c.Title LIKE '%CPR%' OR c.Category LIKE '%CPR%' OR c.Description LIKE '%CPR%') THEN
                                    (SELECT q.LessonID
                                     FROM (
                                         SELECT l.LessonID,
                                                ROW_NUMBER() OVER (ORDER BY l.SequenceOrder, l.LessonID) AS rn
                                         FROM Lessons l
                                         WHERE l.CourseID = c.CourseID
                                           AND l.ApprovalStatus = 'Approved'
                                     ) q
                                     WHERE q.rn = 2)
                                ELSE NULL
                            END AS FreeLessonID,
                            NULL AS NextLessonID
                        FROM Courses c
                        ORDER BY c.Title";

                    DataTable dt = DatabaseHelper.ExecuteQuery(query);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load courses. (" + ex.Message + ")", false);
            }
        }

        protected void btnEnroll_Command(object sender, CommandEventArgs e)
        {
            if (!isMember)
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            try
            {
                int courseID = Convert.ToInt32(e.CommandArgument);
                string checkQuery = "SELECT COUNT(*) FROM Enrollments WHERE UserID=@UserID AND CourseID=@CourseID";
                SqlParameter[] checkP = {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@CourseID", courseID)
                };

                if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkP)) > 0)
                {
                    Response.Redirect("~/LearningLesson.aspx?CourseID=" + courseID, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                string enrollQuery = @"
                    INSERT INTO Enrollments (UserID, CourseID, EnrollmentDate, ProgressPercentage, IsCompleted)
                    VALUES (@UserID, @CourseID, GETDATE(), 0, 0)";

                SqlParameter[] enrollP = {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@CourseID", courseID)
                };

                DatabaseHelper.ExecuteNonQuery(enrollQuery, enrollP);
                Response.Redirect("~/LearningLesson.aspx?CourseID=" + courseID, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not enrol. (" + ex.Message + ")", false);
            }
        }

        protected string GetContinueUrl(object courseId)
        {
            if (courseId != null && courseId != DBNull.Value)
                return ResolveUrl("~/LearningLesson.aspx?CourseID=" + courseId);
            return ResolveUrl("~/LearningProgress.aspx");
        }

        protected string GetProgressMarkup(object isEnrolledObj, object progressObj)
        {
            bool isEnrolled = isEnrolledObj != null && isEnrolledObj != DBNull.Value && Convert.ToBoolean(isEnrolledObj);
            if (!isEnrolled)
                return string.Empty;

            decimal pct = 0;
            if (progressObj != null && progressObj != DBNull.Value)
                pct = Convert.ToDecimal(progressObj);

            string pctText = string.Format("{0:F0}", pct);
            return "<div class='progress mb-2' style='height:6px;'><div class='progress-bar bg-success' style='width:" + pctText + "%;'></div></div>"
                 + "<div class='text-end text-muted mb-2' style='font-size:.8em;'>" + pctText + "% Complete</div>";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "msg",
                string.Format("alert('{0}');", message.Replace("'", "\\'")), true);
        }
    }
}
