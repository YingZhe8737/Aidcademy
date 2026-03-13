using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.IO;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class InstructorEditContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsInstructor())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int currentInstructorId = Convert.ToInt32(Session["UserID"]);
                BindCoursesDropdown(currentInstructorId);
                BindGlobalCategories();

                // CATCH THE REDIRECT AND LOAD THE LESSON
                if (Request.QueryString["LessonID"] != null)
                {
                    int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
                    LoadLessonData(lessonId);
                }
            }
        }

        private string SaveThumbnail(FileUpload fu)
        {
            if (fu.HasFile)
            {
                string ext = Path.GetExtension(fu.FileName).ToLower();
                if (ext == ".jpg" || ext == ".jpeg" || ext == ".png")
                {
                    string fileName = Guid.NewGuid().ToString() + ext;
                    string relativePath = "~/Uploads/Thumbnails/" + fileName;
                    string physicalPath = Server.MapPath("~/Uploads/Thumbnails/");
                    if (!Directory.Exists(physicalPath)) Directory.CreateDirectory(physicalPath);
                    fu.SaveAs(Server.MapPath(relativePath));
                    return relativePath;
                }
            }
            return null;
        }
        private void LoadLessonData(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = "SELECT CourseID, Title, Description, ContentBody, SequenceOrder FROM Lessons WHERE LessonID = @LessonID";
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ddlCourses.SelectedValue = reader["CourseID"].ToString();
                            txtLessonTitle.Text = reader["Title"].ToString();
                            txtLessonDescription.Text = reader["Description"].ToString();
                            txtSequenceOrder.Text = reader["SequenceOrder"].ToString();
                            hfContentBody.Value = reader["ContentBody"].ToString();
                            // lesson-editor.js will automatically read hfContentBody and unpack it into Quill!
                        }
                    }
                }
                string simQuery = "SELECT SimulationType, SimulationData FROM LessonSimulations WHERE LessonID = @LessonID";
                using (SqlCommand simCmd = new SqlCommand(simQuery, conn))
                {
                    simCmd.Parameters.AddWithValue("@LessonID", lessonId);
                    using (SqlDataReader simReader = simCmd.ExecuteReader())
                    {
                        if (simReader.Read())
                        {
                            hfSimulationType.Value = simReader["SimulationType"].ToString();
                            hfSimulationData.Value = simReader["SimulationData"].ToString();
                        }
                        else
                        {
                            // Clear them out if no game exists
                            hfSimulationType.Value = "";
                            hfSimulationData.Value = "";
                        }
                    }
                }
            }
        }

        // Handle the Save/Publish buttons on the Edit Page
        protected void btnSaveDraft_Click(object sender, EventArgs e) { UpdateLesson("Draft"); }
        protected void btnPublishAdmin_Click(object sender, EventArgs e) { UpdateLesson("Pending Admin"); }

        private void UpdateLesson(string status)
        {
            if (Request.QueryString["LessonID"] == null) return;
            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);

            // Call the helper method to save the image (if one was uploaded)
            string newThumbPath = SaveThumbnail(fuLessonThumbnail);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string updateQuery = @"UPDATE Lessons 
                                       SET CourseID = @CourseID, Title = @Title, Description = @Description, ContentBody = @ContentBody, 
                                           SequenceOrder = @SequenceOrder, ApprovalStatus = @ApprovalStatus ";

                if (newThumbPath != null) updateQuery += ", ThumbnailPath = @ThumbnailPath ";
                updateQuery += " WHERE LessonID = @LessonID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue);
                    cmd.Parameters.AddWithValue("@Title", txtLessonTitle.Text.Trim());
                    cmd.Parameters.AddWithValue("@Description", txtLessonDescription.Text.Trim());
                    cmd.Parameters.AddWithValue("@ContentBody", hfContentBody.Value.Trim());
                    cmd.Parameters.AddWithValue("@SequenceOrder", txtSequenceOrder.Text.Trim());
                    cmd.Parameters.AddWithValue("@ApprovalStatus", status);
                    if (newThumbPath != null) cmd.Parameters.AddWithValue("@ThumbnailPath", newThumbPath);
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }

                // SIMULATION SAVE/UPDATE/DELETE LOGIC
                if (!string.IsNullOrEmpty(hfSimulationType.Value) && !string.IsNullOrEmpty(hfSimulationData.Value))
                {
                    string simQuery = @"
                        IF EXISTS (SELECT 1 FROM LessonSimulations WHERE LessonID = @LID)
                            UPDATE LessonSimulations SET SimulationType = @Type, SimulationData = @Data WHERE LessonID = @LID
                        ELSE
                            INSERT INTO LessonSimulations (LessonID, SimulationType, SimulationData) VALUES (@LID, @Type, @Data)";

                    using (SqlCommand simCmd = new SqlCommand(simQuery, conn))
                    {
                        simCmd.Parameters.AddWithValue("@LID", lessonId);
                        simCmd.Parameters.AddWithValue("@Type", hfSimulationType.Value);
                        simCmd.Parameters.AddWithValue("@Data", hfSimulationData.Value);
                        simCmd.ExecuteNonQuery();
                    }
                }
                else
                {
                    string delQuery = "DELETE FROM LessonSimulations WHERE LessonID = @LID";
                    using (SqlCommand delCmd = new SqlCommand(delQuery, conn))
                    {
                        delCmd.Parameters.AddWithValue("@LID", lessonId);
                        delCmd.ExecuteNonQuery();
                    }
                }
            }

            lblMessage.Text = $"Success! Lesson updated and marked as '{status}'.";
            lblMessage.CssClass = "d-block mb-3 fw-bold text-success";
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

        protected void btnEditCoursePrompt_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue)) return;

            // Fetch current course details and display them in the edit boxes
            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand("SELECT Title, Category, Description FROM Courses WHERE CourseID = @CourseID", conn);
                cmd.Parameters.AddWithValue("@CourseID", ddlCourses.SelectedValue);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtEditCourseTitle.Text = reader["Title"].ToString();
                        txtEditCourseCategory.Text = reader["Category"].ToString();
                        txtEditCourseDescription.Text = reader["Description"].ToString();
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
            string newThumbPath = SaveThumbnail(fuEditCourseThumbnail);
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string updateQ = "UPDATE Courses SET Title = @Title, Category = @Category, Description = @Desc ";
                if (newThumbPath != null) updateQ += ", ThumbnailPath = @Thumb ";
                updateQ += " WHERE CourseID = @CourseID";

                SqlCommand cmd = new SqlCommand(updateQ, conn);
                cmd.Parameters.AddWithValue("@Title", txtEditCourseTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@Category", txtEditCourseCategory.Text.Trim());
                cmd.Parameters.AddWithValue("@Desc", txtEditCourseDescription.Text.Trim());
                if (newThumbPath != null) cmd.Parameters.AddWithValue("@Thumb", newThumbPath);
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
                    // 1. Delete Quiz Questions attached to the lessons
                    string q1 = "DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @CourseID))";
                    using (SqlCommand cmd = new SqlCommand(q1, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 2. Delete Quizzes attached to the lessons
                    string q2 = "DELETE FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @CourseID)";
                    using (SqlCommand cmd = new SqlCommand(q2, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 3. Delete the Lessons
                    string q3 = "DELETE FROM Lessons WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(q3, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    // 4. Finally, delete the Course
                    string q4 = "DELETE FROM Courses WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(q4, conn, tx)) { cmd.Parameters.AddWithValue("@CourseID", courseId); cmd.ExecuteNonQuery(); }

                    tx.Commit();
                    lblMessage.Text = "Course and all related lessons deleted successfully.";
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-success";

                    // Refresh dropdown and clear UI
                    BindCoursesDropdown(Convert.ToInt32(Session["UserID"]));
                    txtLessonTitle.Text = "";
                    hfContentBody.Value = "";
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