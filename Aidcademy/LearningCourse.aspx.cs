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

            if (!IsPostBack)
                LoadCourses();
        }

        protected bool IsMemberView
        {
            get { return isMember; }
        }

        protected string GetMemberName()
        {
            string name = SessionHelper.GetUsername();
            if (!string.IsNullOrWhiteSpace(name))
            {
                return name;
            }

            name = Session["Name"]?.ToString();
            if (!string.IsNullOrWhiteSpace(name))
            {
                return name;
            }

            return "Member";
        }

        protected string GetMemberInitial()
        {
            string name = GetMemberName().Trim();
            return name.Length > 0 ? name.Substring(0, 1).ToUpperInvariant() : "M";
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
                            ISNULL(c.Category, 'General') AS Category,
                            'Aidcademy' AS InstructorName,
                            'Beginner' AS DifficultyLevel,
                            NULL AS BadgeType,
                            0 AS IsFreeFlag,
                            0.0 AS Rating,
                            ISNULL(e.ProgressPercentage, 0) AS ProgressPercentage,
                            CASE WHEN e.EnrollmentID IS NOT NULL THEN 1 ELSE 0 END AS IsEnrolled,
                            1 AS IsMember,
                            NULL AS FreeLessonID,
                            (SELECT COUNT(*) FROM Lessons l WHERE l.CourseID = c.CourseID AND l.ApprovalStatus = 'Approved') AS LessonCount,
                            0 AS TotalDuration,
                            (SELECT COUNT(*) FROM Enrollments en WHERE en.CourseID = c.CourseID) AS StudentCount
                        FROM Courses c
                        LEFT JOIN Enrollments e ON c.CourseID = e.CourseID AND e.UserID = @UserID
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
                        SELECT
                            c.CourseID,
                            c.Title         AS CourseName,
                            c.Description   AS CourseDescription,
                            ISNULL(c.ThumbnailPath,'') AS PhotoPath,
                            ISNULL(c.Category, 'General') AS Category,
                            'Aidcademy' AS InstructorName,
                            'Beginner' AS DifficultyLevel,
                            NULL AS BadgeType,
                            0 AS IsFreeFlag,
                            0.0 AS Rating,
                            0 AS ProgressPercentage,
                            0 AS IsEnrolled,
                            0 AS IsMember,
                            (SELECT COUNT(*) FROM Lessons l WHERE l.CourseID = c.CourseID AND l.ApprovalStatus = 'Approved') AS LessonCount,
                            0 AS TotalDuration,
                            (SELECT COUNT(*) FROM Enrollments en WHERE en.CourseID = c.CourseID) AS StudentCount,
                            CASE
                                WHEN EXISTS (
                                    SELECT 1
                                    FROM Lessons lx
                                    WHERE lx.CourseID = c.CourseID
                                      AND lx.ApprovalStatus = 'Approved'
                                      AND (
                                          lx.Title LIKE '%CPR%' OR lx.Description LIKE '%CPR%'
                                          OR lx.Title LIKE '%AED%' OR lx.Description LIKE '%AED%'
                                      )
                                ) THEN
                                    (SELECT TOP 1 l.LessonID
                                     FROM Lessons l
                                     WHERE l.CourseID = c.CourseID
                                       AND l.ApprovalStatus = 'Approved'
                                       AND (
                                           l.Title LIKE '%CPR%' OR l.Description LIKE '%CPR%'
                                           OR l.Title LIKE '%AED%' OR l.Description LIKE '%AED%'
                                       )
                                     ORDER BY l.SequenceOrder, l.LessonID)
                                ELSE NULL
                            END AS FreeLessonID
                        FROM Courses c
                        ORDER BY c.Title";

                    DataTable dt = DatabaseHelper.ExecuteQuery(query);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                    lblCourseCount.Text = dt.Rows.Count.ToString();
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

        protected string GetBadgeClass(object badgeType)
        {
            if (badgeType == null || badgeType == DBNull.Value) return "";
            string badge = badgeType.ToString().ToLower();
            if (badge.Contains("popular")) return "popular";
            if (badge.Contains("trending")) return "trending";
            if (badge.Contains("new")) return "new-badge";
            return "";
        }

        protected string FormatDuration(object totalMinutes)
        {
            if (totalMinutes == null || totalMinutes == DBNull.Value) return "N/A";
            int mins = Convert.ToInt32(totalMinutes);
            if (mins <= 0) return "N/A";
            int hours = mins / 60;
            int remaining = mins % 60;
            if (hours > 0 && remaining > 0) return hours + "h " + remaining + "m";
            if (hours > 0) return hours + "h";
            return remaining + "m";
        }

        protected string GetEnrolledMarkup(object progressObj, object courseId)
        {
            decimal pct = 0;
            if (progressObj != null && progressObj != DBNull.Value)
                pct = Convert.ToDecimal(progressObj);
            string pctText = string.Format("{0:F0}", pct);

            return "<div class='card-enrolled-badge' style='margin-bottom:8px;'><i class='fas fa-check me-1'></i>Enrolled</div>"
                 + "<div class='card-progress-bar'><div class='fill' style='width:" + pctText + "%;'></div></div>"
                 + "<div style='text-align:right;color:#6b7280;font-size:.8rem;margin-bottom:8px;'>" + pctText + "% Complete</div>";
        }

        protected string GetProgressMarkup(object isEnrolledObj, object progressObj)
        {
            bool isEnrolled = isEnrolledObj != null && isEnrolledObj != DBNull.Value && Convert.ToBoolean(isEnrolledObj);
            if (!isEnrolled) return string.Empty;

            decimal pct = 0;
            if (progressObj != null && progressObj != DBNull.Value)
                pct = Convert.ToDecimal(progressObj);
            string pctText = string.Format("{0:F0}", pct);

            return "<div class='card-progress-bar'><div class='fill' style='width:" + pctText + "%;'></div></div>"
                 + "<div style='text-align:right;color:#6b7280;font-size:.8rem;margin-bottom:8px;'>" + pctText + "% Complete</div>";
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
