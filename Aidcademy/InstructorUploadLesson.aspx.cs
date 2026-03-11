using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class InstructorUploadLesson : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int currentInstructorId = Convert.ToInt32(Session["UserID"]);
                BindCoursesDropdown(currentInstructorId);
                BindGlobalCategories();

                if (ddlCourses.Items.Count > 1)
                {
                    ddlCourses.SelectedIndex = 1; 
                    CalculateNextStep(); 
                }
                else
                {
                    txtSequenceOrder.Text = "1";
                }
            }
        }

        private void CalculateNextStep()
        {
            if (!string.IsNullOrEmpty(ddlCourses.SelectedValue))
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ISNULL(MAX(SequenceOrder), 0) + 1 FROM Lessons WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue);
                        conn.Open();
                        txtSequenceOrder.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            else
            {
                txtSequenceOrder.Text = "1";
            }
        }

        protected void ddlCourses_SelectedIndexChanged(object sender, EventArgs e)
        {
            CalculateNextStep();
        }

        private void BindCoursesDropdown(int instructorId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT CourseID, Title FROM Courses WHERE UserID = @InstructorID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", instructorId);
                    conn.Open();
                    ddlCourses.DataSource = cmd.ExecuteReader();
                    ddlCourses.DataTextField = "Title";
                    ddlCourses.DataValueField = "CourseID";
                    ddlCourses.DataBind();
                }
            }
            ddlCourses.Items.Insert(0, new ListItem("-- Choose a Course --", ""));
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            ProcessSubmission("Draft");
        }

        // Changed this name to match the HTML!
        protected void btnPublishAdmin_Click(object sender, EventArgs e)
        {
            ProcessSubmission("Pending Admin");
        }

        private void ProcessSubmission(string status)
        {
            bool isNewCourse = hfIsNewCourse.Value == "1";

            if ((!isNewCourse && string.IsNullOrEmpty(ddlCourses.SelectedValue)) ||
                (isNewCourse && (string.IsNullOrEmpty(txtNewCourseTitle.Text) || string.IsNullOrEmpty(ddlNewCourseCategory.SelectedValue))) ||
                string.IsNullOrEmpty(txtLessonTitle.Text) ||
                string.IsNullOrEmpty(txtSequenceOrder.Text) ||
                string.IsNullOrEmpty(hfContentBody.Value))
            {
                lblMessage.Text = "Please fill in all required fields.";
                lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                return;
            }

            int currentInstructorId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
            int finalCourseId = 0;
            int finalLessonId = 0;
            bool isSuccess = false; // NEW: A flag to track if the transaction worked

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    if (isNewCourse)
                    {
                        string finalCategory = ddlNewCourseCategory.SelectedValue == "Other" ? txtCustomCategory.Text.Trim() : ddlNewCourseCategory.SelectedValue;
                        string courseQuery = @"INSERT INTO Courses (UserID, Title, Description, Category) 
                                               VALUES (@UserID, @Title, 'Instructor generated course', @Category);
                                               SELECT SCOPE_IDENTITY();";

                        using (SqlCommand cmd = new SqlCommand(courseQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                            cmd.Parameters.AddWithValue("@Title", txtNewCourseTitle.Text.Trim());
                            cmd.Parameters.AddWithValue("@Category", finalCategory);
                            finalCourseId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                    else
                    {
                        finalCourseId = Convert.ToInt32(ddlCourses.SelectedValue);
                    }

                    string lessonQuery = @"INSERT INTO Lessons (CourseID, Title, ContentBody, SequenceOrder, ApprovalStatus) 
                                           VALUES (@CourseID, @Title, @ContentBody, @SequenceOrder, @ApprovalStatus);
                                           SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(lessonQuery, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", finalCourseId);
                        cmd.Parameters.AddWithValue("@Title", txtLessonTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@ContentBody", hfContentBody.Value.Trim());
                        cmd.Parameters.AddWithValue("@SequenceOrder", Convert.ToInt32(txtSequenceOrder.Text));
                        cmd.Parameters.AddWithValue("@ApprovalStatus", status);

                        finalLessonId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Save the Simulation if the instructor created one!
                    if (!string.IsNullOrEmpty(hfSimulationType.Value) && !string.IsNullOrEmpty(hfSimulationData.Value))
                    {
                        string simQuery = "INSERT INTO LessonSimulations (LessonID, SimulationType, SimulationData) VALUES (@LID, @Type, @Data)";
                        using (SqlCommand simCmd = new SqlCommand(simQuery, conn, transaction))
                        {
                            simCmd.Parameters.AddWithValue("@LID", finalLessonId);
                            simCmd.Parameters.AddWithValue("@Type", hfSimulationType.Value);
                            simCmd.Parameters.AddWithValue("@Data", hfSimulationData.Value);
                            simCmd.ExecuteNonQuery();
                        }
                    }
                    transaction.Commit();
                    isSuccess = true; // The transaction finished perfectly!
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblMessage.Text = "Database Error: " + ex.Message;
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                }
            }

            // REDIRECT SAFELY OUTSIDE THE TRY-CATCH BLOCK
            if (isSuccess)
            {
                Response.Redirect("InstructorEditContent.aspx?LessonID=" + finalLessonId);
            }
        }

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
                // Notice there is NO "WHERE UserID = @InstructorID" here! 
                // This grabs every unique category ever created across the whole platform.
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