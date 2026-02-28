using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class InstructorEditContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindCoursesDropdown(1); // 1 = Test Instructor ID
                if (Request.QueryString["LessonID"] != null)
                {
                    LoadLessonData(Convert.ToInt32(Request.QueryString["LessonID"]));
                }
            }
        }

        private void BindCoursesDropdown(int instructorId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT CourseID, Title FROM Courses WHERE UserID = @InstructorID", conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", instructorId);
                    conn.Open();
                    ddlCourses.DataSource = cmd.ExecuteReader();
                    ddlCourses.DataTextField = "Title";
                    ddlCourses.DataValueField = "CourseID";
                    ddlCourses.DataBind();
                }
            }
        }

        private void LoadLessonData(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT CourseID, Title, ContentBody, SequenceOrder FROM Lessons WHERE LessonID = @LessonID", conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ddlCourses.SelectedValue = reader["CourseID"].ToString();
                            txtLessonTitle.Text = reader["Title"].ToString();
                            txtSequenceOrder.Text = reader["SequenceOrder"].ToString();
                            hfContentBody.Value = reader["ContentBody"].ToString();
                        }
                    }
                }
            }
        }

        // --- THE TWO BUTTON EVENTS ---
        protected void btnSaveDraft_Click(object sender, EventArgs e) { ProcessUpdate("Draft"); }
        protected void btnPublishAdmin_Click(object sender, EventArgs e) { ProcessUpdate("Pending Admin"); }

        private void ProcessUpdate(string status)
        {
            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
            bool isNewCourse = hfIsNewCourse.Value == "1";
            int finalCourseId = 0;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    // 1. Check if they created a new course
                    if (isNewCourse)
                    {
                        // Logic for Custom Category
                        string finalCategory = ddlNewCourseCategory.SelectedValue;
                        if (finalCategory == "Other") { finalCategory = txtCustomCategory.Text.Trim(); }

                        string courseQuery = @"INSERT INTO Courses (UserID, Title, Description, Category, ApprovalStatus) 
                                               VALUES (1, @Title, 'Instructor generated', @Category, @Status);
                                               SELECT SCOPE_IDENTITY();";
                        using (SqlCommand cmd = new SqlCommand(courseQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@Title", txtNewCourseTitle.Text.Trim());
                            cmd.Parameters.AddWithValue("@Category", finalCategory);
                            cmd.Parameters.AddWithValue("@Status", status);
                            finalCourseId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                    else
                    {
                        finalCourseId = Convert.ToInt32(ddlCourses.SelectedValue);

                        // If attaching to an existing course, update the status of the course so Admin sees it!
                        using (SqlCommand cmdStatus = new SqlCommand("UPDATE Courses SET ApprovalStatus = @Status WHERE CourseID = @CourseID", conn, transaction))
                        {
                            cmdStatus.Parameters.AddWithValue("@Status", status);
                            cmdStatus.Parameters.AddWithValue("@CourseID", finalCourseId);
                            cmdStatus.ExecuteNonQuery();
                        }
                    }

                    // 2. Update the actual Lesson
                    string lessonQuery = @"UPDATE Lessons SET CourseID = @CourseID, Title = @Title, ContentBody = @ContentBody, SequenceOrder = @SequenceOrder WHERE LessonID = @LessonID";
                    using (SqlCommand cmd = new SqlCommand(lessonQuery, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", finalCourseId);
                        cmd.Parameters.AddWithValue("@Title", txtLessonTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@ContentBody", hfContentBody.Value.Trim());
                        cmd.Parameters.AddWithValue("@SequenceOrder", Convert.ToInt32(txtSequenceOrder.Text));
                        cmd.Parameters.AddWithValue("@LessonID", lessonId);
                        cmd.ExecuteNonQuery();
                    }

                    transaction.Commit();

                    lblMessage.Text = $"Success! Lesson updated and marked as '{status}'.";
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-success";
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblMessage.Text = "Error: " + ex.Message;
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                }
            }
        }
    }
}