using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
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
                    BindSidebar();
                    LoadLesson(Convert.ToInt32(Request.QueryString["LessonID"]));
                }
            }
        }

        private void LoadLesson(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // 1. Load the Content
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

                // 2. Load ALL Quiz Questions (Removed 'top 1')
                string quizQuery = @"SELECT qq.* FROM QuizQuestions qq INNER JOIN Quizzes q ON qq.QuizID = q.QuizID WHERE q.LessonID = @LessonID";
                using (SqlCommand cmd = new SqlCommand(quizQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        System.Data.DataTable dt = new System.Data.DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            pnlQuiz.Visible = true;

                            hfQuizID.Value = dt.Rows[0]["QuizID"].ToString();

                            rptQuiz.DataSource = dt;
                            rptQuiz.DataBind();
                        }
                    }
                }
            }
        }

        // Automatically builds the Radio Buttons for each question in the Repeater
        protected void rptQuiz_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");
                System.Data.DataRowView row = (System.Data.DataRowView)e.Item.DataItem;

                rbl.Items.Add(new ListItem(" A) " + row["OptionA"].ToString(), "A"));
                rbl.Items.Add(new ListItem(" B) " + row["OptionB"].ToString(), "B"));
                rbl.Items.Add(new ListItem(" C) " + row["OptionC"].ToString(), "C"));
                rbl.Items.Add(new ListItem(" D) " + row["OptionD"].ToString(), "D"));
            }
        }

        protected void btnSubmitQuiz_Click(object sender, EventArgs e)
        {
            int score = 0;
            int totalQuestions = rptQuiz.Items.Count;

            // 1. Grade the Quiz
            foreach (RepeaterItem item in rptQuiz.Items)
            {
                RadioButtonList rbl = (RadioButtonList)item.FindControl("rblOptions");
                HiddenField hfCorrect = (HiddenField)item.FindControl("hfCorrectAnswer");
                Label lblFeedback = (Label)item.FindControl("lblFeedback");

                if (rbl.SelectedValue == hfCorrect.Value)
                {
                    score++;
                    lblFeedback.Text = "✅ Correct!";
                    lblFeedback.CssClass = "text-success fw-bold d-block mt-2";
                }
                else
                {
                    lblFeedback.Text = $"❌ Incorrect. The correct answer was {hfCorrect.Value}.";
                    lblFeedback.CssClass = "text-danger fw-bold d-block mt-2";
                }
            }

            // 2. The Gamification XP Logic
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
            int quizId = Convert.ToInt32(hfQuizID.Value);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Check if they have taken this quiz before
                string checkQuery = "SELECT Score FROM QuizResults WHERE UserID = @UserID AND QuizID = @QuizID";
                int? existingScore = null;

                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@QuizID", quizId);
                    object result = cmd.ExecuteScalar();
                    if (result != null)
                    {
                        existingScore = Convert.ToInt32(result);
                    }
                }

                int earnedXP = 0;
                bool isFirstAttempt = !existingScore.HasValue;

                if (isFirstAttempt)
                {
                    // FIRST TRY: 100 XP per correct answer
                    earnedXP = score * 100;

                    string insertQuery = "INSERT INTO QuizResults (UserID, QuizID, Score) VALUES (@UserID, @QuizID, @Score)";
                    using (SqlCommand cmd = new SqlCommand(insertQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userId);
                        cmd.Parameters.AddWithValue("@QuizID", quizId);
                        cmd.Parameters.AddWithValue("@Score", earnedXP);
                        cmd.ExecuteNonQuery();
                    }

                    lblQuizScore.Text = $"You scored {score} out of {totalQuestions}! (+{earnedXP} XP First Try Bonus!)";
                }
                else
                {
                    // RETRY: 50 XP per correct answer
                    earnedXP = score * 50;

                    // Only update the database if their retry XP is higher than their old XP 
                    if (earnedXP > existingScore.Value)
                    {
                        string updateQuery = "UPDATE QuizResults SET Score = @Score, DateTaken = GETDATE() WHERE UserID = @UserID AND QuizID = @QuizID";
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@UserID", userId);
                            cmd.Parameters.AddWithValue("@QuizID", quizId);
                            cmd.Parameters.AddWithValue("@Score", earnedXP);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    int highestSaved = Math.Max(earnedXP, existingScore.Value);
                    lblQuizScore.Text = $"You scored {score} out of {totalQuestions}. (Retry earned {earnedXP} XP. Highest saved: {highestSaved} XP)";
                }
            }

            if (score == totalQuestions)
            {
                lblQuizScore.CssClass = "d-block mt-4 p-3 bg-success text-white rounded fw-bold fs-5 text-center shadow-sm";
                btnSubmitQuiz.Enabled = false; // Stop them from clicking submit again
            }
            else
            {
                lblQuizScore.CssClass = "d-block mt-4 p-3 bg-danger text-white rounded fw-bold fs-5 text-center shadow-sm";
            }
        }

        private void BindSidebar()
        {
            string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Fetch only courses that have published lessons to keep the sidebar clean
                string query = @"SELECT DISTINCT c.CourseID, c.Title AS CourseTitle 
                                 FROM Courses c
                                 INNER JOIN Lessons l ON c.CourseID = l.CourseID
                                 WHERE l.ApprovalStatus = 'Published'
                                 ORDER BY c.Title";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        rptSidebarCourses.DataSource = dt;
                        rptSidebarCourses.DataBind();
                    }
                }
            }
        }

        protected void rptSidebarCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            // Check if the item being bound is an actual data row
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                // 1. Get the CourseID of the current row being generated
                DataRowView drv = (DataRowView)e.Item.DataItem;
                int courseId = Convert.ToInt32(drv["CourseID"]);

                // 2. Find the inner Repeater on the HTML page
                Repeater rptSidebarLessons = (Repeater)e.Item.FindControl("rptSidebarLessons");

                // 3. Fetch and bind the lessons for THIS specific course
                string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = @"SELECT LessonID, Title AS LessonTitle, SequenceOrder 
                                     FROM Lessons 
                                     WHERE CourseID = @CourseID AND ApprovalStatus = 'Published' 
                                     ORDER BY SequenceOrder";

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", courseId);
                        using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            sda.Fill(dt);

                            rptSidebarLessons.DataSource = dt;
                            rptSidebarLessons.DataBind();
                        }
                    }
                }
            }
        }
    }
}