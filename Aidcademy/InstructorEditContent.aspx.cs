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
                // Load Lesson Data
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

                // Load Attached Quiz Data
                string quizQuery = @"SELECT top 1 qq.* FROM QuizQuestions qq 
                                     INNER JOIN Quizzes q ON qq.QuizID = q.QuizID 
                                     WHERE q.LessonID = @LessonID";
                using (SqlCommand cmdQuiz = new SqlCommand(quizQuery, conn))
                {
                    cmdQuiz.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataReader reader = cmdQuiz.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            txtQuizQuestion.Text = reader["QuestionText"].ToString();
                            txtOptA.Text = reader["OptionA"].ToString();
                            txtOptB.Text = reader["OptionB"].ToString();
                            txtOptC.Text = reader["OptionC"].ToString();
                            txtOptD.Text = reader["OptionD"].ToString();
                            if (ddlCorrectAnswer.Items.FindByValue(reader["CorrectAnswer"].ToString()) != null)
                                ddlCorrectAnswer.SelectedValue = reader["CorrectAnswer"].ToString();
                        }
                    }
                }
            }
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
                        string courseQuery = "INSERT INTO Courses (UserID, Title, Category, ApprovalStatus) VALUES (1, @Title, @Category, @Status); SELECT SCOPE_IDENTITY();";
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

                    // 3. Update or Insert Quiz
                    if (!string.IsNullOrEmpty(txtQuizQuestion.Text) && !string.IsNullOrEmpty(txtOptA.Text))
                    {
                        // Check if a quiz already exists for this lesson
                        int existingQuizId = 0;
                        using (SqlCommand checkQuiz = new SqlCommand("SELECT QuizID FROM Quizzes WHERE LessonID = @LessonID", conn, transaction))
                        {
                            checkQuiz.Parameters.AddWithValue("@LessonID", lessonId);
                            object result = checkQuiz.ExecuteScalar();
                            if (result != null) existingQuizId = Convert.ToInt32(result);
                        }

                        if (existingQuizId == 0)
                        {
                            // Did not exist before, Insert it
                            using (SqlCommand cmd = new SqlCommand("INSERT INTO Quizzes (LessonID, Title) VALUES (@LessonID, @QuizTitle); SELECT SCOPE_IDENTITY();", conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@LessonID", lessonId);
                                cmd.Parameters.AddWithValue("@QuizTitle", "Knowledge Check: " + txtLessonTitle.Text.Trim());
                                existingQuizId = Convert.ToInt32(cmd.ExecuteScalar());
                            }
                            string insertQ = "INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer) VALUES (@QuizID, @Q, @A, @B, @C, @D, @Ans)";
                            using (SqlCommand cmd = new SqlCommand(insertQ, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@QuizID", existingQuizId);
                                cmd.Parameters.AddWithValue("@Q", txtQuizQuestion.Text.Trim());
                                cmd.Parameters.AddWithValue("@A", txtOptA.Text.Trim());
                                cmd.Parameters.AddWithValue("@B", txtOptB.Text.Trim());
                                cmd.Parameters.AddWithValue("@C", txtOptC.Text.Trim());
                                cmd.Parameters.AddWithValue("@D", txtOptD.Text.Trim());
                                cmd.Parameters.AddWithValue("@Ans", ddlCorrectAnswer.SelectedValue);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            // Existed, Update it
                            string updateQ = "UPDATE QuizQuestions SET QuestionText=@Q, OptionA=@A, OptionB=@B, OptionC=@C, OptionD=@D, CorrectAnswer=@Ans WHERE QuizID=@QuizID";
                            using (SqlCommand cmd = new SqlCommand(updateQ, conn, transaction))
                            {
                                cmd.Parameters.AddWithValue("@QuizID", existingQuizId);
                                cmd.Parameters.AddWithValue("@Q", txtQuizQuestion.Text.Trim());
                                cmd.Parameters.AddWithValue("@A", txtOptA.Text.Trim());
                                cmd.Parameters.AddWithValue("@B", txtOptB.Text.Trim());
                                cmd.Parameters.AddWithValue("@C", txtOptC.Text.Trim());
                                cmd.Parameters.AddWithValue("@D", txtOptD.Text.Trim());
                                cmd.Parameters.AddWithValue("@Ans", ddlCorrectAnswer.SelectedValue);
                                cmd.ExecuteNonQuery();
                            }
                        }
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
    }
}