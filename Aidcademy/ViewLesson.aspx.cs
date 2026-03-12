using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class ViewLesson : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // 1. Determine User Role
            string role = Session["Role"] != null ? Session["Role"].ToString() : "Visitor";

            // 2. Setup Top Navbar depending on Role (Toggles the ASP.NET Panels)
            pnlNavVisitor.Visible = (role == "Visitor");
            pnlNavMember.Visible = (role == "Member");
            pnlNavInstructor.Visible = (role == "Instructor");
            pnlNavAdmin.Visible = (role == "Admin");

            // 3. Set dynamic back button URL
            string backUrl = "MainPage.aspx";
            if (role == "Member") backUrl = "MemberDashboard.aspx";
            else if (role == "Instructor") backUrl = "InstructorManageContent.aspx";
            else if (role == "Admin") backUrl = "AdminDashboard.aspx";

            hlBackBtn.NavigateUrl = backUrl;

            // 4. Disable Quiz Submissions for Visitors
            if (role == "Visitor")
            {
                btnSubmitQuiz.Enabled = false;
                lblVisitorQuizWarning.Visible = true;
            }

            if (!IsPostBack)
            {
                // Show the admin action bar only if the logged-in user is an admin
                pnlAdminActions.Visible = SessionHelper.IsAdmin();

                if (Request.QueryString["LessonID"] != null)
                {
                    int currentLessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
                    BindSidebar(currentLessonId);
                    LoadLesson(currentLessonId);
                }
            }
        }

        private void LoadLesson(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Load lesson content
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT Title, ContentBody, SequenceOrder FROM Lessons WHERE LessonID = @LessonID", conn))
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

                // 2. Load ALL Quiz Questions
                string quizQuery = @"SELECT qq.* FROM QuizQuestions qq INNER JOIN Quizzes q ON qq.QuizID = q.QuizID WHERE q.LessonID = @LessonID";
                using (SqlCommand cmd = new SqlCommand(quizQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
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

                // 3. Load Simulation Data (if it exists)
                using (SqlCommand cmd = new SqlCommand("SELECT SimulationType, SimulationData FROM LessonSimulations WHERE LessonID = @LessonID", conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataReader rdr = cmd.ExecuteReader())
                    {
                        if (rdr.Read())
                        {
                            hfLoadedSimType.Value = rdr["SimulationType"].ToString();
                            hfLoadedSimData.Value = rdr["SimulationData"].ToString();
                        }
                    }
                }
            }
        }

        protected void rptQuiz_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                RadioButtonList rbl = (RadioButtonList)e.Item.FindControl("rblOptions");
                DataRowView row = (DataRowView)e.Item.DataItem;

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

            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 1;
            int quizId = Convert.ToInt32(hfQuizID.Value);
            int newStreak = 1;
            int pointsToAdd = 0;
            DateTime lastActivity;
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // A. Capture previous last activity BEFORE this submission
                lastActivity = DateTime.MinValue;
                string lastActivityQuery = "SELECT ISNULL(MAX(DateTaken), '2000-01-01') FROM QuizResults WHERE UserID = @UserID";
                using (SqlCommand cmd = new SqlCommand(lastActivityQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                        lastActivity = Convert.ToDateTime(res);
                }

                string checkQuery = "SELECT Score FROM QuizResults WHERE UserID = @UserID AND QuizID = @QuizID";
                int? existingScore = null;

                using (SqlCommand cmd = new SqlCommand(checkQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@QuizID", quizId);
                    object result = cmd.ExecuteScalar();
                    if (result != null) existingScore = Convert.ToInt32(result);
                }

                int earnedXP;
                bool isFirstAttempt = !existingScore.HasValue;

                if (isFirstAttempt)
                {
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
                    earnedXP = score * 50;
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

                int currentStreak = 0;
                string getStreakQuery = "SELECT ISNULL(DailyStreak, 0) FROM Leaderboard WHERE UserID = @UserID";
                using (SqlCommand cmd = new SqlCommand(getStreakQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                    {
                        currentStreak = Convert.ToInt32(res);
                    }
                }

                // Calculate new streak
                using (SqlCommand cmd = new SqlCommand(getStreakQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    object res = cmd.ExecuteScalar();
                    if (res != null && res != DBNull.Value)
                        currentStreak = Convert.ToInt32(res);
                }

                DateTime today = DateTime.Today;
                if (lastActivity.Date == today)
                {
                    // Already played today — keep streak as-is
                    newStreak = currentStreak == 0 ? 1 : currentStreak;
                }
                else if (lastActivity.Date == today.AddDays(-1))
                {
                    // Played yesterday — extend streak
                    newStreak = currentStreak + 1;
                }
                else
                {
                    // Missed a day or brand new — reset to 1
                    newStreak = 1;
                }

                // D. Upsert Leaderboard (TotalPoints + DailyStreak)
                string upsertQuery = @"
                                    IF EXISTS (SELECT 1 FROM Leaderboard WHERE UserID = @UserID)
                                        UPDATE Leaderboard
                                        SET TotalPoints = TotalPoints + @Points,
                                            DailyStreak = @Streak
                                        WHERE UserID = @UserID
                                    ELSE
                                        INSERT INTO Leaderboard (UserID, TotalPoints, DailyStreak)
                                        VALUES (@UserID, @Points, @Streak)";

                using (SqlCommand cmd = new SqlCommand(upsertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@Points", pointsToAdd);
                    cmd.Parameters.AddWithValue("@Streak", newStreak);
                    cmd.ExecuteNonQuery();
                }


                if (score == totalQuestions)
                {
                    lblQuizScore.CssClass = "d-block mt-4 p-3 bg-success text-white rounded fw-bold fs-5 text-center shadow-sm";
                    btnSubmitQuiz.Enabled = false;
                }
                else
                {
                    lblQuizScore.CssClass = "d-block mt-4 p-3 bg-danger text-white rounded fw-bold fs-5 text-center shadow-sm";
                }

                // Show streak modal with the live streak count
                string streakScript = $"document.getElementById('streakModalMessage').innerText = 'You are on a {newStreak}-day streak! Keep it up!'; showStreakModal();";
                Page.ClientScript.RegisterStartupScript(this.GetType(), "StreakPopup", streakScript, true);
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsAdmin()) return; // extra server-side guard

            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
            UpdateStatus(lessonId, "Published");

            lblActionResult.Text = "✅ Lesson has been approved and published.";
            lblActionResult.CssClass = "d-block mt-3 fw-bold text-center text-success";

            // Disable both buttons after action
            btnApprove.Enabled = false;
        }

        // ════════════════════════════════════════════════════════════════════
        // ADMIN: REJECT  (comment comes from hfRejectComment hidden field)
        // ════════════════════════════════════════════════════════════════════
        protected void btnReject_Click(object sender, EventArgs e)
        {
            if (!SessionHelper.IsAdmin()) return; // extra server-side guard

            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
            string comment = hfRejectComment.Value;

            UpdateStatus(lessonId, "Rejected", comment);

            lblActionResult.Text = "❌ Lesson has been rejected. The instructor has been notified.";
            lblActionResult.CssClass = "d-block mt-3 fw-bold text-center text-danger";

            btnApprove.Enabled = false;
        }


        // ── Shared status updater ─────────────────────────────────────────────
        protected void UpdateStatus(int lessonId, string newStatus, string comment = null)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Update the lesson approval status
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE Lessons SET ApprovalStatus = @Status WHERE LessonID = @LessonID", conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    cmd.ExecuteNonQuery();
                }


                if (!string.IsNullOrEmpty(comment))
                {
                    using (SqlCommand cmd = new SqlCommand(
                        "UPDATE Lessons SET StatusComment = @Comment WHERE LessonID = @LessonID", conn))
                    {
                        cmd.Parameters.AddWithValue("@Comment", comment);
                        cmd.Parameters.AddWithValue("@LessonID", lessonId);
                        cmd.ExecuteNonQuery();
                    }
                }
            } 
        }

        private void BindSidebar(int currentLessonId)
        {
            string role = Session["Role"] != null ? Session["Role"].ToString() : "Visitor";
            int userId = Session["UserID"] != null ? Convert.ToInt32(Session["UserID"]) : 0;
            int currentCourseId = 0;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // First, find out which Course this specific Lesson belongs to
                using (SqlCommand cmd = new SqlCommand("SELECT CourseID FROM Lessons WHERE LessonID = @LessonID", conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", currentLessonId);
                    conn.Open();
                    object result = cmd.ExecuteScalar();
                    if (result != null) currentCourseId = Convert.ToInt32(result);
                    conn.Close();
                }

                string query = "";

                if (role == "Visitor")
                {
                    // For Visitors: Only show the Course they clicked on
                    query = @"SELECT CourseID, Title AS CourseTitle 
                              FROM Courses 
                              WHERE CourseID = @CurrentCourseID";
                }
                else if (role == "Member")
                {
                    // For Members: Show ALL published courses they are enrolled in
                    query = @"SELECT DISTINCT c.CourseID, c.Title AS CourseTitle 
                              FROM Courses c
                              INNER JOIN Enrollments e ON c.CourseID = e.CourseID
                              INNER JOIN Lessons l ON c.CourseID = l.CourseID
                              WHERE l.ApprovalStatus = 'Published' AND e.UserID = @UserID
                              ORDER BY c.Title";
                }
                else
                {
                    // For Admin & Instructors: Show ALL published courses platform-wide
                    query = @"SELECT DISTINCT c.CourseID, c.Title AS CourseTitle 
                              FROM Courses c
                              INNER JOIN Lessons l ON c.CourseID = l.CourseID
                              WHERE l.ApprovalStatus = 'Published'
                              ORDER BY c.Title";
                }

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (role == "Member") cmd.Parameters.AddWithValue("@UserID", userId);
                    if (role == "Visitor") cmd.Parameters.AddWithValue("@CurrentCourseID", currentCourseId);

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

        public void rptSidebarCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            if (e.Item.ItemType == ListItemType.Item || e.Item.ItemType == ListItemType.AlternatingItem)
            {
                DataRowView drv = (DataRowView)e.Item.DataItem;
                int courseId = Convert.ToInt32(drv["CourseID"]);
                Repeater rptSidebarLessons = (Repeater)e.Item.FindControl("rptSidebarLessons");

                string role = Session["Role"] != null ? Session["Role"].ToString() : "Visitor";
                int currentLessonId = Convert.ToInt32(Request.QueryString["LessonID"]);

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "";

                    if (role == "Visitor")
                    {
                        // Visitors: Only show the specific lesson they are on
                        query = @"SELECT LessonID, Title AS LessonTitle, SequenceOrder 
                                  FROM Lessons 
                                  WHERE LessonID = @CurrentLessonID";
                    }
                    else
                    {
                        // Others: Show all published lessons for the course
                        query = @"SELECT LessonID, Title AS LessonTitle, SequenceOrder 
                                  FROM Lessons 
                                  WHERE CourseID = @CourseID AND ApprovalStatus = 'Published' 
                                  ORDER BY SequenceOrder";
                    }

                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        if (role == "Visitor")
                        {
                            cmd.Parameters.AddWithValue("@CurrentLessonID", currentLessonId);
                        }
                        else
                        {
                            cmd.Parameters.AddWithValue("@CourseID", courseId);
                        }

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

        private void LoadLessonNavigation(int lessonId, SqlConnection conn)
        {
            int courseId = 0;
            int sequenceOrder = 0;
            string qInfo = "SELECT CourseID, SequenceOrder FROM Lessons WHERE LessonID = @LessonID";
            using (SqlCommand cmd = new SqlCommand(qInfo, conn))
            {
                cmd.Parameters.AddWithValue("@LessonID", lessonId);
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        courseId = Convert.ToInt32(reader["CourseID"]);
                        sequenceOrder = Convert.ToInt32(reader["SequenceOrder"]);
                    }
                }
            }

            if (courseId > 0)
            {
                string navQuery = @"
                    SELECT 
                        (SELECT TOP 1 LessonID FROM Lessons WHERE CourseID = @CourseID AND ApprovalStatus = 'Published' AND SequenceOrder < @Seq ORDER BY SequenceOrder DESC) as PrevID,
                        (SELECT TOP 1 LessonID FROM Lessons WHERE CourseID = @CourseID AND ApprovalStatus = 'Published' AND SequenceOrder > @Seq ORDER BY SequenceOrder ASC) as NextID";
                using (SqlCommand cmd = new SqlCommand(navQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    cmd.Parameters.AddWithValue("@Seq", sequenceOrder);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            if (reader["PrevID"] != DBNull.Value)
                            {
                                ViewState["PrevLessonID"] = reader["PrevID"].ToString();
                                btnPrevLesson.Visible = true;
                            }
                            else
                            {
                                btnPrevLesson.Visible = false;
                            }

                            if (reader["NextID"] != DBNull.Value)
                            {
                                ViewState["NextLessonID"] = reader["NextID"].ToString();
                                btnNextLesson.Visible = true;
                            }
                            else
                            {
                                btnNextLesson.Visible = false;
                            }
                        }
                    }
                }
                ViewState["CourseID"] = courseId.ToString();
            }
        }

        protected void btnPrevLesson_Click(object sender, EventArgs e)
        {
            if (ViewState["PrevLessonID"] != null)
                Response.Redirect("~/ViewLesson.aspx?LessonID=" + ViewState["PrevLessonID"]);
        }

        protected void btnNextLesson_Click(object sender, EventArgs e)
        {
            if (ViewState["NextLessonID"] != null)
                Response.Redirect("~/ViewLesson.aspx?LessonID=" + ViewState["NextLessonID"]);
        }

        protected void btnMarkComplete_Click(object sender, EventArgs e)
        {
            if (Session["UserID"] == null || Request.QueryString["LessonID"] == null)
                return;

            int userId = Convert.ToInt32(Session["UserID"]);
            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
            int courseId = ViewState["CourseID"] != null ? Convert.ToInt32(ViewState["CourseID"]) : 0;

            if (courseId == 0) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // 1. Mark lesson as complete
                string upsertQuery = @"
                    IF NOT EXISTS (SELECT 1 FROM LessonProgress WHERE UserID = @UserID AND LessonID = @LessonID)
                    BEGIN
                        INSERT INTO LessonProgress (UserID, LessonID, CourseID, IsCompleted, CompletionDate)
                        VALUES (@UserID, @LessonID, @CourseID, 1, GETDATE())
                    END";

                using (SqlCommand cmd = new SqlCommand(upsertQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    cmd.ExecuteNonQuery();
                }

                // 2. Recalculate Course Progress Percentage
                string pctQuery = @"
                    DECLARE @Total INT = (SELECT COUNT(LessonID) FROM Lessons WHERE CourseID = @CourseID AND ApprovalStatus = 'Published');
                    DECLARE @Completed INT = (SELECT COUNT(LessonID) FROM LessonProgress WHERE CourseID = @CourseID AND UserID = @UserID AND IsCompleted = 1);
                    DECLARE @Pct INT = 0;
                    IF @Total > 0 SET @Pct = (@Completed * 100) / @Total;

                    UPDATE Enrollments 
                    SET ProgressPercentage = @Pct,
                        IsCompleted = CASE WHEN @Pct = 100 THEN 1 ELSE 0 END
                    WHERE CourseID = @CourseID AND UserID = @UserID;
                ";

                using (SqlCommand cmd = new SqlCommand(pctQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    cmd.ExecuteNonQuery();
                }
            }

            btnMarkComplete.Text = "Completed ✓";
            btnMarkComplete.Enabled = false;
            btnMarkComplete.CssClass = "btn btn-secondary rounded-pill fw-bold px-4 shadow-sm";
        }
    }
}
