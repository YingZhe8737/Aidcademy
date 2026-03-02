using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class SubmitQuestion : System.Web.UI.Page
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
                LoadEnrolledCourses();
                LoadMyQuestions();
            }
        }

        private void LoadEnrolledCourses()
        {
            try
            {
                string query = @"
                    SELECT DISTINCT c.CourseID, c.Title AS CourseName
                    FROM Courses c
                    INNER JOIN Enrollments e ON c.CourseID = e.CourseID
                    WHERE e.UserID = @UserID
                    ORDER BY c.Title";

                SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                ddlCourses.DataSource = dt;
                ddlCourses.DataTextField = "CourseName";
                ddlCourses.DataValueField = "CourseID";
                ddlCourses.DataBind();
                ddlCourses.Items.Insert(0, new ListItem("-- Select a Course --", "0"));
            }
            catch (Exception ex)
            {
                ShowMessage("Could not load courses. (" + ex.Message + ")", false);
            }
        }

        private void LoadMyQuestions()
        {
            try
            {
                string query = @"
                    SELECT
                        cq.QuestionID, cq.QuestionText, cq.Status,
                        c.Title             AS CourseName,
                        cq.InstructorResponse,
                        cq.ResponseDate
                    FROM CourseQuestions cq
                    INNER JOIN Courses c ON cq.CourseID = c.CourseID
                    WHERE cq.UserID = @UserID
                    ORDER BY cq.QuestionID DESC";

                SqlParameter[] p = { new SqlParameter("@UserID", userID) };
                DataTable dt = DatabaseHelper.ExecuteQuery(query, p);
                rptQuestions.DataSource = dt;
                rptQuestions.DataBind();
                pnlNoQuestions.Visible = dt.Rows.Count == 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Questions error: " + ex.Message);
                pnlNoQuestions.Visible = true;
            }
        }

        protected void btnSubmitQuestion_Click(object sender, EventArgs e)
        {
            try
            {
                int courseID = Convert.ToInt32(ddlCourses.SelectedValue);
                string question = txtQuestion.Text.Trim();

                if (courseID == 0)
                {
                    ShowMessage("Please select a course before submitting your question.", false);
                    return;
                }
                if (string.IsNullOrEmpty(question))
                {
                    ShowMessage("Please type your question.", false);
                    return;
                }

                string query = @"
                    INSERT INTO CourseQuestions (CourseID, UserID, QuestionText, Status)
                    VALUES (@CourseID, @UserID, @QuestionText, 'Open')";

                SqlParameter[] p =
                {
                    new SqlParameter("@CourseID", courseID),
                    new SqlParameter("@UserID", userID),
                    new SqlParameter("@QuestionText", question)
                };

                DatabaseHelper.ExecuteNonQuery(query, p);
                ShowMessage("Your question has been submitted! An instructor will respond soon.", true);
                txtQuestion.Text = string.Empty;
                ddlCourses.SelectedIndex = 0;
                LoadMyQuestions();
            }
            catch (Exception ex)
            {
                ShowMessage("Could not submit. (" + ex.Message + ")", false);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            lblMessage.Text = message;
            pnlMessage.Visible = true;
            pnlMessage.CssClass = isSuccess ? "message success" : "message error";
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}