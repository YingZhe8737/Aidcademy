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
                LoadCourses();
            }
        }

        private void LoadCourses()
        {
            try
            {
                string query = @"
                    SELECT
                        c.CourseID, c.Title AS CourseName, c.Description AS CourseDescription,
                        c.Category,
                        CASE WHEN e.EnrollmentID IS NOT NULL THEN 1 ELSE 0 END AS IsEnrolled
                    FROM Courses c
                    LEFT JOIN Enrollments e
                        ON c.CourseID = e.CourseID AND e.UserID = @UserID
                    ORDER BY c.Title";

                SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                rptCourses.DataSource = dt;
                rptCourses.DataBind();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load courses. (" + ex.Message + ")", false);
            }
        }

        protected void btnEnroll_Command(object sender, CommandEventArgs e)
        {
            try
            {
                int courseID = Convert.ToInt32(e.CommandArgument);

                string checkQuery = "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND CourseID = @CourseID";
                SqlParameter[] checkP =
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@CourseID", courseID)
                };

                if (Convert.ToInt32(DatabaseHelper.ExecuteScalar(checkQuery, checkP)) > 0)
                {
                    ShowMessage("You are already enrolled in this course!", false);
                    return;
                }

                string enrollQuery = @"
                    INSERT INTO Enrollments (UserID, CourseID, EnrollmentDate, ProgressPercentage, IsCompleted)
                    VALUES (@UserID, @CourseID, GETDATE(), 0, 0)";

                SqlParameter[] enrollP =
                {
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@CourseID", courseID)
                };

                DatabaseHelper.ExecuteNonQuery(enrollQuery, enrollP);
                ShowMessage("You have successfully enrolled. Happy learning!", true);
                LoadCourses();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not enrol. (" + ex.Message + ")", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            ScriptManager.RegisterStartupScript(this, GetType(), "msg",
                string.Format("alert('{0}');", message.Replace("'", "\\'")), true);
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}