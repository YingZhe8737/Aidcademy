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
            string role = (Session["UserRole"] ?? Session["Role"] ?? string.Empty).ToString();
            isMember = Session["UserID"] != null &&
                       role.Equals("Member", StringComparison.OrdinalIgnoreCase);
            userID = isMember ? Convert.ToInt32(Session["UserID"]) : 0;
            if (!IsPostBack) LoadCourses();
        }

        protected bool IsMemberView => isMember;
        protected string GetMemberName() => SessionHelper.GetDisplayName();
        protected string GetMemberInitial() => SessionHelper.GetInitial();

        private string _memberPhotoUrl;
        protected string GetMemberPhotoUrl()
        {
            if (_memberPhotoUrl != null) return _memberPhotoUrl;
            if (!isMember) { _memberPhotoUrl = ""; return ""; }
            try
            {
                string q = "SELECT ProfilePhoto FROM UserProfiles WHERE UserID = @UserID";
                SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                object r = DatabaseHelper.ExecuteScalar(q, p);
                _memberPhotoUrl = (r != null && r != DBNull.Value && !string.IsNullOrEmpty(r.ToString()))
                    ? ResolveUrl("~/Uploads/ProfilePhotos/" + r.ToString())
                    : "";
            }
            catch { _memberPhotoUrl = ""; }
            return _memberPhotoUrl;
        }

        private void LoadCourses()
        {
            try
            {
                if (isMember)
                {
                    string query = @"
                        SELECT c.CourseID,
                               c.Title                              AS CourseName,
                               c.Description                        AS CourseDescription,
                               ISNULL(c.ThumbnailPath,'')           AS CourseThumbnailPath,
                               ISNULL(c.Category,'General')         AS Category,
                               'Aidcademy'                          AS InstructorName,
                               'Beginner'                           AS DifficultyLevel,
                               NULL                                  AS BadgeType,
                               0                                    AS IsFreeFlag,
                               0.0                                  AS Rating,
                               ISNULL(e.ProgressPercentage,0)       AS ProgressPercentage,
                               CASE WHEN e.EnrollmentID IS NOT NULL THEN 1 ELSE 0 END AS IsEnrolled,
                               1                                    AS IsMember,
                               NULL                                  AS FreeLessonID,
                               (SELECT COUNT(*) FROM Lessons l WHERE l.CourseID = c.CourseID
                                AND l.ApprovalStatus IN ('Approved','Published'))  AS LessonCount,
                               0                                    AS TotalDuration,
                               (SELECT COUNT(*) FROM Enrollments en WHERE en.CourseID = c.CourseID) AS StudentCount
                        FROM   Courses c
                        LEFT JOIN Enrollments e ON c.CourseID = e.CourseID AND e.UserID = @UserID
                        WHERE  EXISTS (
                                   SELECT 1 FROM Lessons lx
                                   WHERE  lx.CourseID = c.CourseID
                                   AND    lx.ApprovalStatus IN ('Approved','Published')
                               )
                        ORDER BY c.Title";

                    SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                    DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                    lblCourseCount.Text = dt.Rows.Count.ToString();
                }
                else
                {
                    string query = @"
                        SELECT c.CourseID,
                               c.Title                              AS CourseName,
                               c.Description                        AS CourseDescription,
                               ISNULL(c.ThumbnailPath,'')           AS CourseThumbnailPath,
                               ISNULL(c.Category,'General')         AS Category,
                               'Aidcademy'                          AS InstructorName,
                               'Beginner'                           AS DifficultyLevel,
                               NULL                                  AS BadgeType,
                               0                                    AS IsFreeFlag,
                               0.0                                  AS Rating,
                               0                                    AS ProgressPercentage,
                               0                                    AS IsEnrolled,
                               0                                    AS IsMember,
                               (SELECT COUNT(*) FROM Lessons l WHERE l.CourseID = c.CourseID
                                AND l.ApprovalStatus IN ('Approved','Published'))  AS LessonCount,
                               0                                    AS TotalDuration,
                               (SELECT COUNT(*) FROM Enrollments en WHERE en.CourseID = c.CourseID) AS StudentCount,
                               CASE
                                   WHEN EXISTS (
                                       SELECT 1 FROM Lessons lx
                                       WHERE  lx.CourseID = c.CourseID
                                       AND    lx.ApprovalStatus IN ('Approved','Published')
                                       AND    (lx.Title LIKE '%CPR%' OR lx.Description LIKE '%CPR%'
                                               OR lx.Title LIKE '%AED%' OR lx.Description LIKE '%AED%')
                                   ) THEN (
                                       SELECT TOP 1 l.LessonID
                                       FROM   Lessons l
                                       WHERE  l.CourseID = c.CourseID
                                       AND    l.ApprovalStatus IN ('Approved','Published')
                                       AND    (l.Title LIKE '%CPR%' OR l.Description LIKE '%CPR%'
                                               OR l.Title LIKE '%AED%' OR l.Description LIKE '%AED%')
                                       ORDER BY l.SequenceOrder, l.LessonID)
                                   ELSE NULL
                               END AS FreeLessonID
                        FROM   Courses c
                        WHERE  EXISTS (
                                   SELECT 1 FROM Lessons lx
                                   WHERE  lx.CourseID = c.CourseID
                                   AND    lx.ApprovalStatus IN ('Approved','Published')
                               )
                        ORDER BY c.Title";

                    DataTable dt = DatabaseHelper.ExecuteQuery(query);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                    lblCourseCount.Text = dt.Rows.Count.ToString();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("LoadCourses error: " + ex.Message);
                ShowMessage("Could not load courses. Please try again later.", false);
            }
        }

        protected void btnEnroll_Command(object sender, CommandEventArgs e)
        {
            if (!isMember) { Response.Redirect("~/Login_signup.aspx"); return; }
            try
            {
                int courseID = Convert.ToInt32(e.CommandArgument);
                string checkQuery = "SELECT COUNT(*) FROM Enrollments WHERE UserID=@UserID AND CourseID=@CourseID";
                SqlParameter[] checkP = { new SqlParameter("@UserID", userID), new SqlParameter("@CourseID", courseID) };
                if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkP)) > 0)
                {
                    Response.Redirect("~/LearningLesson.aspx?CourseID=" + courseID, false);
                    Context.ApplicationInstance.CompleteRequest(); return;
                }
                string enrollQuery = @"INSERT INTO Enrollments (UserID,CourseID,EnrollmentDate,ProgressPercentage,IsCompleted)
                                       VALUES (@UserID,@CourseID,GETDATE(),0,0)";
                SqlParameter[] enrollP = { new SqlParameter("@UserID", userID), new SqlParameter("@CourseID", courseID) };
                DatabaseHelper.ExecuteNonQuery(enrollQuery, enrollP);
                Response.Redirect("~/LearningLesson.aspx?CourseID=" + courseID, false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Enroll error: " + ex.Message);
                ShowMessage("Could not enrol. Please try again later.", false);
            }
        }

        protected string GetContinueUrl(object courseId) =>
            (courseId != null && courseId != DBNull.Value)
                ? ResolveUrl("~/LearningLesson.aspx?CourseID=" + courseId)
                : ResolveUrl("~/LearningProgress.aspx");

        protected string GetBadgeClass(object badgeType)
        {
            if (badgeType == null || badgeType == DBNull.Value) return "";
            string b = badgeType.ToString().ToLower();
            if (b.Contains("popular")) return "popular";
            if (b.Contains("trending")) return "trending";
            if (b.Contains("new")) return "new-badge";
            return "";
        }

        protected string FormatDuration(object totalMinutes)
        {
            if (totalMinutes == null || totalMinutes == DBNull.Value) return "N/A";
            int mins = Convert.ToInt32(totalMinutes);
            if (mins <= 0) return "N/A";
            int h = mins / 60, m = mins % 60;
            if (h > 0 && m > 0) return h + "h " + m + "m";
            return h > 0 ? h + "h" : m + "m";
        }

        protected string GetEnrolledMarkup(object progressObj, object courseId)
        {
            decimal pct = (progressObj != null && progressObj != DBNull.Value) ? Convert.ToDecimal(progressObj) : 0;
            string t = string.Format("{0:F0}", pct);
            return "<div class='card-enrolled-badge' style='margin-bottom:8px;'><i class='fas fa-check me-1'></i>Enrolled</div>"
                 + "<div class='card-progress-bar'><div class='fill' style='width:" + t + "%;'></div></div>"
                 + "<div style='text-align:right;color:#6b7280;font-size:.8rem;margin-bottom:8px;'>" + t + "% Complete</div>";
        }

        protected string GetProgressMarkup(object isEnrolledObj, object progressObj)
        {
            if (isEnrolledObj == null || isEnrolledObj == DBNull.Value || !Convert.ToBoolean(isEnrolledObj)) return string.Empty;
            decimal pct = (progressObj != null && progressObj != DBNull.Value) ? Convert.ToDecimal(progressObj) : 0;
            string t = string.Format("{0:F0}", pct);
            return "<div class='card-progress-bar'><div class='fill' style='width:" + t + "%;'></div></div>"
                 + "<div style='text-align:right;color:#6b7280;font-size:.8rem;margin-bottom:8px;'>" + t + "% Complete</div>";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        private void ShowMessage(string msg, bool isSuccess) =>
            ScriptManager.RegisterStartupScript(this, GetType(), "msg",
                string.Format("alert('{0}');", msg.Replace("'", "\\'")), true);
    }
}
