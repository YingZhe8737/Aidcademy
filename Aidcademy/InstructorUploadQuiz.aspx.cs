using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class InstructorUploadQuiz : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        private int currentInstructorId
        {
            get { return Convert.ToInt32(Session["UserID"]); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsInstructor())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            if (!IsPostBack)
            {
                BindCourses();

                // If they clicked "Add Quiz" from a specific lesson on the dashboard
                if (Request.QueryString["LessonID"] != null)
                {
                    AutoSelectLesson(Convert.ToInt32(Request.QueryString["LessonID"]));
                }
            }
        }

        private void BindCourses()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT CourseID, Title FROM Courses WHERE UserID = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", currentInstructorId);
                    conn.Open();
                    ddlCourses.DataSource = cmd.ExecuteReader();
                    ddlCourses.DataTextField = "Title";
                    ddlCourses.DataValueField = "CourseID";
                    ddlCourses.DataBind();
                }
            }
            ddlCourses.Items.Insert(0, new ListItem("-- Select a Course --", ""));
        }

        protected void ddlCourses_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (!string.IsNullOrEmpty(ddlCourses.SelectedValue))
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT LessonID, 'Step ' + CAST(SequenceOrder AS VARCHAR) + ': ' + Title AS LessonTitle FROM Lessons WHERE CourseID = @CID ORDER BY SequenceOrder", conn))
                    {
                        cmd.Parameters.AddWithValue("@CID", ddlCourses.SelectedValue);
                        conn.Open();
                        ddlLessons.DataSource = cmd.ExecuteReader();
                        ddlLessons.DataTextField = "LessonTitle";
                        ddlLessons.DataValueField = "LessonID";
                        ddlLessons.DataBind();
                    }
                }
                ddlLessons.Items.Insert(0, new ListItem("-- Select a Lesson --", ""));
                ddlLessons.Enabled = true;
            }
            else
            {
                ddlLessons.Items.Clear();
                ddlLessons.Enabled = false;
            }
            pnlQuizSetup.Visible = false;
            pnlQuestionBuilder.Visible = false;
        }

        protected void ddlLessons_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadQuizData();
        }

        private void AutoSelectLesson(int lessonId)
        {
            // Logic to auto-select dropdowns if passed via URL from dashboard
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT CourseID FROM Lessons WHERE LessonID = @LID", conn))
                {
                    cmd.Parameters.AddWithValue("@LID", lessonId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        ddlCourses.SelectedValue = result.ToString();
                        ddlCourses_SelectedIndexChanged(null, null);
                        ddlLessons.SelectedValue = lessonId.ToString();
                        LoadQuizData();
                    }
                }
            }
        }

        private void LoadQuizData()
        {
            if (string.IsNullOrEmpty(ddlLessons.SelectedValue)) return;

            pnlQuizSetup.Visible = true;
            hfQuizID.Value = "0";
            txtQuizTitle.Text = "";
            pnlQuestionBuilder.Visible = false;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT QuizID, Title FROM Quizzes WHERE LessonID = @LID", conn))
                {
                    cmd.Parameters.AddWithValue("@LID", ddlLessons.SelectedValue);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            hfQuizID.Value = reader["QuizID"].ToString();
                            txtQuizTitle.Text = reader["Title"].ToString();
                            pnlQuestionBuilder.Visible = true;
                        }
                    }
                }
            }

            if (hfQuizID.Value != "0") BindQuestions();
        }

        protected void btnSaveQuizTitle_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(txtQuizTitle.Text.Trim()) || string.IsNullOrEmpty(ddlLessons.SelectedValue)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                if (hfQuizID.Value == "0")
                {
                    using (SqlCommand cmd = new SqlCommand("INSERT INTO Quizzes (LessonID, Title) VALUES (@LID, @Title); SELECT SCOPE_IDENTITY();", conn))
                    {
                        cmd.Parameters.AddWithValue("@LID", ddlLessons.SelectedValue);
                        cmd.Parameters.AddWithValue("@Title", txtQuizTitle.Text.Trim());
                        hfQuizID.Value = cmd.ExecuteScalar().ToString();
                        lblMessage.Text = "Quiz created! Now add your questions below.";
                        lblMessage.CssClass = "text-success d-block mb-4 fw-bold";
                    }
                }
                else
                {
                    using (SqlCommand cmd = new SqlCommand("UPDATE Quizzes SET Title = @Title WHERE QuizID = @QID", conn))
                    {
                        cmd.Parameters.AddWithValue("@Title", txtQuizTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@QID", hfQuizID.Value);
                        cmd.ExecuteNonQuery();
                        lblMessage.Text = "Quiz title updated!";
                        lblMessage.CssClass = "text-success d-block mb-4 fw-bold";
                    }
                }
            }
            pnlQuestionBuilder.Visible = true;
            BindQuestions();
        }

        protected void btnAddQuestion_Click(object sender, EventArgs e)
        {
            if (hfQuizID.Value == "0" || string.IsNullOrEmpty(txtNewQuestion.Text)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // If hfEditQuestionID is "0", we INSERT a new question
                if (hfEditQuestionID.Value == "0")
                {
                    string insertQuery = @"INSERT INTO QuizQuestions (QuizID, QuestionText, OptionA, OptionB, OptionC, OptionD, CorrectAnswer) 
                                           VALUES (@QID, @Q, @A, @B, @C, @D, @Ans)";
                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", hfQuizID.Value);
                        cmd.Parameters.AddWithValue("@Q", txtNewQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@A", txtOptA.Text.Trim());
                        cmd.Parameters.AddWithValue("@B", txtOptB.Text.Trim());
                        cmd.Parameters.AddWithValue("@C", txtOptC.Text.Trim());
                        cmd.Parameters.AddWithValue("@D", txtOptD.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ddlCorrectAnswer.SelectedValue);
                        cmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "Question added successfully!";
                }
                // If it has an ID, we UPDATE the existing question
                else
                {
                    string updateQuery = @"UPDATE QuizQuestions 
                                           SET QuestionText = @Q, OptionA = @A, OptionB = @B, OptionC = @C, OptionD = @D, CorrectAnswer = @Ans 
                                           WHERE QuestionID = @QuestionID";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@QuestionID", hfEditQuestionID.Value);
                        cmd.Parameters.AddWithValue("@Q", txtNewQuestion.Text.Trim());
                        cmd.Parameters.AddWithValue("@A", txtOptA.Text.Trim());
                        cmd.Parameters.AddWithValue("@B", txtOptB.Text.Trim());
                        cmd.Parameters.AddWithValue("@C", txtOptC.Text.Trim());
                        cmd.Parameters.AddWithValue("@D", txtOptD.Text.Trim());
                        cmd.Parameters.AddWithValue("@Ans", ddlCorrectAnswer.SelectedValue);
                        cmd.ExecuteNonQuery();
                    }
                    lblMessage.Text = "Question updated successfully!";
                }
            }

            ResetQuestionForm();
            lblMessage.CssClass = "text-success d-block mb-4 fw-bold";
            BindQuestions();
        }

        protected void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int questionId = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "DeleteQ")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("DELETE FROM QuizQuestions WHERE QuestionID = @QID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", questionId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
                lblMessage.Text = "Question deleted.";
                lblMessage.CssClass = "text-danger d-block mb-4 fw-bold";
                BindQuestions();
            }
            else if (e.CommandName == "EditQ")
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    using (SqlCommand cmd = new SqlCommand("SELECT * FROM QuizQuestions WHERE QuestionID = @QID", conn))
                    {
                        cmd.Parameters.AddWithValue("@QID", questionId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                // Populate the form with the question data
                                txtNewQuestion.Text = reader["QuestionText"].ToString();
                                txtOptA.Text = reader["OptionA"].ToString();
                                txtOptB.Text = reader["OptionB"].ToString();
                                txtOptC.Text = reader["OptionC"].ToString();
                                txtOptD.Text = reader["OptionD"].ToString();
                                ddlCorrectAnswer.SelectedValue = reader["CorrectAnswer"].ToString();

                                // Switch UI to "Edit Mode"
                                hfEditQuestionID.Value = questionId.ToString();
                                lblFormTitle.Text = "Edit Question";
                                btnAddQuestion.Text = "Update Question";
                                btnAddQuestion.CssClass = "btn btn-primary fw-bold";
                                btnCancelEdit.Visible = true;

                                // Clear message and scroll to top
                                lblMessage.Text = "";
                            }
                        }
                    }
                }
            }
        }

        protected void btnCancelEdit_Click(object sender, EventArgs e)
        {
            ResetQuestionForm();
            lblMessage.Text = "Edit cancelled.";
            lblMessage.CssClass = "text-muted d-block mb-4 fw-bold";
        }

        private void ResetQuestionForm()
        {
            txtNewQuestion.Text = "";
            txtOptA.Text = "";
            txtOptB.Text = "";
            txtOptC.Text = "";
            txtOptD.Text = "";
            ddlCorrectAnswer.SelectedIndex = 0;

            hfEditQuestionID.Value = "0";
            lblFormTitle.Text = "Add a Question";
            btnAddQuestion.Text = "+ Add Question to Quiz";
            btnAddQuestion.CssClass = "btn btn-warning fw-bold";
            btnCancelEdit.Visible = false;
        }

        private void BindQuestions()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT * FROM QuizQuestions WHERE QuizID = @QID ORDER BY QuestionID ASC", conn))
                {
                    cmd.Parameters.AddWithValue("@QID", hfQuizID.Value);
                    conn.Open();
                    rptQuestions.DataSource = cmd.ExecuteReader();
                    rptQuestions.DataBind();
                }
            }
        }
    }
}