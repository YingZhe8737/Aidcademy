using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class ViewLesson : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Request.QueryString["LessonID"] != null)
                {
                    LoadLesson(Convert.ToInt32(Request.QueryString["LessonID"]));
                }
            }
        }

        private void LoadLesson(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // 1. Load the Content (Your existing code)
                using (SqlCommand cmd = new SqlCommand("SELECT Title, ContentBody, SequenceOrder FROM Lessons WHERE LessonID = @LessonID", conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            lblTitle.Text = reader["Title"].ToString();
                            lblSequence.Text = reader["SequenceOrder"].ToString();
                            litLessonContent.Text = reader["ContentBody"].ToString();
                        }
                    }
                }

                // 2. Load the Quiz!
                string quizQuery = @"SELECT top 1 qq.* FROM QuizQuestions qq INNER JOIN Quizzes q ON qq.QuizID = q.QuizID WHERE q.LessonID = @LessonID";
                using (SqlCommand cmd = new SqlCommand(quizQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            pnlQuiz.Visible = true; // Show the panel
                            lblQuestionText.Text = reader["QuestionText"].ToString();

                            // Populate the radio buttons
                            rblOptions.Items.Add(new ListItem(" A) " + reader["OptionA"].ToString(), "A"));
                            rblOptions.Items.Add(new ListItem(" B) " + reader["OptionB"].ToString(), "B"));
                            rblOptions.Items.Add(new ListItem(" C) " + reader["OptionC"].ToString(), "C"));
                            rblOptions.Items.Add(new ListItem(" D) " + reader["OptionD"].ToString(), "D"));

                            hfCorrectAnswer.Value = reader["CorrectAnswer"].ToString();
                        }
                    }
                }
            }
        }

        // 3. Let the member check their answer
        protected void btnSubmitAnswer_Click(object sender, EventArgs e)
        {
            if (rblOptions.SelectedValue == hfCorrectAnswer.Value)
            {
                lblQuizResult.Text = "✅ Correct! Great job.";
                lblQuizResult.CssClass = "d-block mt-3 fw-bold fs-5 text-success";
            }
            else
            {
                lblQuizResult.Text = "❌ Incorrect. Please review the lesson and try again.";
                lblQuizResult.CssClass = "d-block mt-3 fw-bold fs-5 text-danger";
            }
        }
    }
}