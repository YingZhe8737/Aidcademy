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
                int currentInstructorId = Convert.ToInt32(Session["UserID"]);
                BindCoursesDropdown(currentInstructorId);
                if (Request.QueryString["LessonID"] != null)
                {
                    LoadLessonData(Convert.ToInt32(Request.QueryString["LessonID"]));
                }
                BindGlobalCategories();
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
            int currentInstructorId = Convert.ToInt32(Session["UserID"]);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // SECURE QUERY: Joins the Course table to prove Ownership!
                string query = @"SELECT l.CourseID, l.Title, l.ContentBody, l.SequenceOrder 
                         FROM Lessons l
                         INNER JOIN Courses c ON l.CourseID = c.CourseID
                         WHERE l.LessonID = @LessonID AND c.UserID = @InstructorID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    cmd.Parameters.AddWithValue("@InstructorID", currentInstructorId);
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
                        else
                        {
                            // IDOR BLOCKED! The lesson either doesn't exist, or they don't own it.
                            Response.Redirect("InstructorManageContent.aspx");
                        }
                    }
                }
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            ProcessUpdate("Draft");
        }

        protected void btnPublishAdmin_Click(object sender, EventArgs e)
        {
            ProcessUpdate("Pending Admin");
        }

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
                    // 1. Handle Course Logic
                    if (isNewCourse)
                    {
                        string finalCategory = ddlNewCourseCategory.SelectedValue == "Other" ? txtCustomCategory.Text.Trim() : ddlNewCourseCategory.SelectedValue;
                        string courseQuery = "INSERT INTO Courses (UserID, Title, Category, ApprovalStatus) VALUES (@UserID, @Title, @Category, @Status); SELECT SCOPE_IDENTITY();";
                        using (SqlCommand cmd = new SqlCommand(courseQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserID", Convert.ToInt32(Session["UserID"]));
                            cmd.Parameters.AddWithValue("@Title", txtNewCourseTitle.Text.Trim());
                            cmd.Parameters.AddWithValue("@Category", finalCategory);
                            cmd.Parameters.AddWithValue("@Status", status);
                            finalCourseId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                    else
                    {
                        finalCourseId = Convert.ToInt32(ddlCourses.SelectedValue);
                        using (SqlCommand cmdStatus = new SqlCommand("UPDATE Courses SET ApprovalStatus = @Status WHERE CourseID = @CourseID", conn, transaction))
                        {
                            cmdStatus.Parameters.AddWithValue("@Status", status);
                            cmdStatus.Parameters.AddWithValue("@CourseID", finalCourseId);
                            cmdStatus.ExecuteNonQuery();
                        }
                    }

                    // 2. Update Lesson
                    string lessonQuery = "UPDATE Lessons SET CourseID = @CourseID, Title = @Title, ContentBody = @ContentBody, SequenceOrder = @SequenceOrder WHERE LessonID = @LessonID";
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
        // --- NEW COURSE EDIT/DELETE LOGIC ---

        protected void btnEditCoursePrompt_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue)) return;

            // Fetch current course details and display them in the edit boxes
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT Title, Category FROM Courses WHERE CourseID = @CourseID", conn);
                cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtEditCourseTitle.Text = reader["Title"].ToString();
                        txtEditCourseCategory.Text = reader["Category"].ToString();
                        pnlEditCourse.Visible = true; // Reveal the panel
                    }
                }
            }
        }

        protected void btnCancelCourseEdit_Click(object sender, EventArgs e)
        {
            pnlEditCourse.Visible = false; // Hide the panel
        }

        protected void btnSaveCourseEdit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue) || string.IsNullOrEmpty(txtEditCourseTitle.Text)) return;

            // Update the database with the new name/category
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("UPDATE Courses SET Title = @Title, Category = @Category WHERE CourseID = @CourseID", conn);
                cmd.Parameters.AddWithValue("@Title", txtEditCourseTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@Category", txtEditCourseCategory.Text.Trim());
                cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlEditCourse.Visible = false;
            BindCoursesDropdown(1); // Refresh the dropdown

            lblMessage.Text = "Course details updated successfully!";
            lblMessage.CssClass = "d-block mb-3 fw-bold text-success";
        }

        protected void btnDeleteCourse_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue)) return;
            int courseId = Convert.ToInt32(ddlCourses.SelectedValue);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction tx = conn.BeginTransaction();
                try
                {
                    // 1. Delete Quiz Questions attached to the lessons in this course
                    string q1 = "DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @CourseID))";
                    using (SqlCommand cmd = new SqlCommand(q1, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 2. Delete Quizzes attached to the lessons
                    string q2 = "DELETE FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @CourseID)";
                    using (SqlCommand cmd = new SqlCommand(q2, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 3. Delete the Lessons
                    string q3 = "DELETE FROM Lessons WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(q3, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 4. Finally, delete the Course itself
                    string q4 = "DELETE FROM Courses WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(q4, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    tx.Commit();
                    lblMessage.Text = "Course and all related lessons deleted successfully.";
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-success";

                    BindCoursesDropdown(1);
                    pnlEditCourse.Visible = false;
                }
                catch (Exception ex)
                {
                    tx.Rollback();
                    lblMessage.Text = "Error deleting course: " + ex.Message;
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                }
            }
        }

        private void BindGlobalCategories()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT DISTINCT Category FROM Courses WHERE Category IS NOT NULL AND Category != ''";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        ddlNewCourseCategory.Items.Clear();
                        ddlNewCourseCategory.Items.Add(new ListItem("Category", ""));
                        while (reader.Read())
                        {
                            string cat = reader["Category"].ToString();
                            ddlNewCourseCategory.Items.Add(new ListItem(cat, cat));
                        }
                        ddlNewCourseCategory.Items.Add(new ListItem("Other...", "Other"));
                    }
                }
            }
        }
    }
}