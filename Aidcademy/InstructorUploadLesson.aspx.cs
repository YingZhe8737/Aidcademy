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
                int currentInstructorId = 1; // Testing ID
                BindCoursesDropdown(currentInstructorId);
            }
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

        protected void btnSubmitLesson_Click(object sender, EventArgs e)
        {
            ProcessSubmission("Pending Admin");
        }

        private void ProcessSubmission(string status)
        {
            bool isNewCourse = hfIsNewCourse.Value == "1";

            // Basic Validation
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

            int currentInstructorId = 1; // Testing ID
            int finalCourseId = 0;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    // 1. Handle New Course Creation
                    if (isNewCourse)
                    {
                        // Logic for Custom Category
                        string finalCategory = ddlNewCourseCategory.SelectedValue;
                        if (finalCategory == "Other")
                        {
                            finalCategory = txtCustomCategory.Text.Trim();
                        }

                        string courseQuery = @"INSERT INTO Courses (UserID, Title, Description, Category, ApprovalStatus) 
                                               VALUES (@UserID, @Title, 'Instructor generated course', @Category, @CourseStatus);
                                               SELECT SCOPE_IDENTITY();";

                        using (SqlCommand cmd = new SqlCommand(courseQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                            cmd.Parameters.AddWithValue("@Title", txtNewCourseTitle.Text.Trim());
                            cmd.Parameters.AddWithValue("@Category", finalCategory);
                            cmd.Parameters.AddWithValue("@CourseStatus", status);

                            finalCourseId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                    else
                    {
                        finalCourseId = Convert.ToInt32(ddlCourses.SelectedValue);
                    }

                    // 2. Save the Lesson
                    string lessonQuery = @"INSERT INTO Lessons (CourseID, Title, ContentBody, MediaURL, SequenceOrder) 
                                           VALUES (@CourseID, @Title, @ContentBody, '', @SequenceOrder);
                                           SELECT SCOPE_IDENTITY();";

                    int finalLessonId = 0;
                    using (SqlCommand cmd = new SqlCommand(lessonQuery, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", finalCourseId);
                        cmd.Parameters.AddWithValue("@Title", txtLessonTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@ContentBody", hfContentBody.Value.Trim());
                        cmd.Parameters.AddWithValue("@SequenceOrder", Convert.ToInt32(txtSequenceOrder.Text));

                        finalLessonId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // 3. Attach the Knowledge Check Quiz (if provided)
                    if (!string.IsNullOrEmpty(txtQuizQuestion.Text) && !string.IsNullOrEmpty(txtOptA.Text))
                    {
                        string quizQuery = "INSERT INTO Quizzes (LessonID, Title) VALUES (@LessonID, @QuizTitle); SELECT SCOPE_IDENTITY();";
                        int finalQuizId = 0;
                        using (SqlCommand cmd = new SqlCommand(quizQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@LessonID", finalLessonId);
                            cmd.Parameters.AddWithValue("@QuizTitle", "Knowledge Check: " + txtLessonTitle.Text.Trim());
                            finalQuizId = Convert.ToInt32(cmd.ExecuteScalar());
                        }

                        string questionQuery = @"INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer)
                                                 VALUES (@QuizID, @QuestionText, @OptA, @OptB, @OptC, @OptD, @CorrectAns)";
                        using (SqlCommand cmd = new SqlCommand(questionQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@QuizID", finalQuizId);
                            cmd.Parameters.AddWithValue("@QuestionText", txtQuizQuestion.Text.Trim());
                            cmd.Parameters.AddWithValue("@OptA", txtOptA.Text.Trim());
                            cmd.Parameters.AddWithValue("@OptB", txtOptB.Text.Trim());
                            cmd.Parameters.AddWithValue("@OptC", txtOptC.Text.Trim());
                            cmd.Parameters.AddWithValue("@OptD", txtOptD.Text.Trim());
                            cmd.Parameters.AddWithValue("@CorrectAns", ddlCorrectAnswer.SelectedValue);

                            cmd.ExecuteNonQuery();
                        }
                    }

                    transaction.Commit();

                    lblMessage.Text = isNewCourse
                        ? $"Success! New course created and lesson saved as '{status}'."
                        : $"Success! Lesson attached to existing course and saved as '{status}'.";
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-success";

                    // Reset User Interface
                    txtLessonTitle.Text = "";
                    txtSequenceOrder.Text = "";
                    txtNewCourseTitle.Text = "";
                    txtCustomCategory.Text = "";
                    ddlNewCourseCategory.SelectedIndex = 0;
                    txtQuizQuestion.Text = "";
                    txtOptA.Text = ""; txtOptB.Text = ""; txtOptC.Text = ""; txtOptD.Text = "";
                    ddlCorrectAnswer.SelectedIndex = 0;

                    if (isNewCourse)
                    {
                        BindCoursesDropdown(currentInstructorId);
                        hfIsNewCourse.Value = "0";
                    }
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblMessage.Text = "Database Error: " + ex.Message;
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                }
            }
        }
    }
}