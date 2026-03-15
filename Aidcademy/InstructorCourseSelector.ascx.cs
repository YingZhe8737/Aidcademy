using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class InstructorCourseSelector : System.Web.UI.UserControl
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        // Set this before calling LoadCourses()
        public int InstructorId { get; set; }

        // Read these from the parent page when saving a lesson
        public string SelectedCourseId => ddlCourses.SelectedValue;
        public bool IsNewCourse => hfIsNewCourse.Value == "1";
        public string NewCourseTitle => txtNewCourseTitle.Text.Trim();
        public string NewCourseDescription => txtNewCourseDescription.Text.Trim();
        // Automatically resolves "Other" to the custom typed value
        public string NewCourseCategory => ddlNewCourseCategory.SelectedValue == "Other"
            ? txtCustomCategory.Text.Trim()
            : ddlNewCourseCategory.SelectedValue;

        // Expose client IDs so parent pages can pass them to lesson-editor.js
        public string IsNewCourseClientId => hfIsNewCourse.ClientID;
        public string CustomCategoryClientId => txtCustomCategory.ClientID;

        // Called by InstructorEditContent to pre-select the course after loading lesson data
        public void SetSelectedCourse(string courseId)
        {
            ddlCourses.SelectedValue = courseId;
        }

        // Called by InstructorUploadLesson when creating a new course during lesson save
        public string SaveNewCourseThumbnail()
        {
            return SaveCourseThumbnail(fuNewCourseThumbnail);
        }

        // Fires when the instructor picks a different course from the dropdown
        public event EventHandler CourseChanged;

        // Fires after a course is deleted so the parent page can clear its lesson fields
        public event EventHandler CourseDeleted;

        public void LoadCourses()
        {
            BindCoursesDropdown(InstructorId);
            BindGlobalCategories();
        }

        private void BindCoursesDropdown(int instructorId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT CourseID, Title FROM Courses WHERE UserID = @ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", instructorId);
                conn.Open();
                ddlCourses.DataSource = cmd.ExecuteReader();
                ddlCourses.DataTextField = "Title";
                ddlCourses.DataValueField = "CourseID";
                ddlCourses.DataBind();
            }
            ddlCourses.Items.Insert(0, new ListItem("-- Choose a Course --", ""));
        }

        private void BindGlobalCategories()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT DISTINCT Category FROM Courses WHERE Category IS NOT NULL AND Category != ''", conn))
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

        private string SaveCourseThumbnail(FileUpload fu)
        {
            if (!fu.HasFile) return null;
            string ext = Path.GetExtension(fu.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png") return null;
            string fileName = Guid.NewGuid().ToString() + ext;
            string physical = Server.MapPath("~/Uploads/Thumbnails/");
            if (!Directory.Exists(physical)) Directory.CreateDirectory(physical);
            fu.SaveAs(physical + fileName);
            return "~/Uploads/Thumbnails/" + fileName;
        }

        protected void ddlCourses_SelectedIndexChanged(object sender, EventArgs e)
        {
            CourseChanged?.Invoke(this, EventArgs.Empty);
        }

        protected void btnEditCoursePrompt_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue)) return;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                SqlCommand cmd = new SqlCommand(
                    "SELECT Title, Category, Description FROM Courses WHERE CourseID = @ID", conn);
                cmd.Parameters.AddWithValue("@ID", ddlCourses.SelectedValue);
                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        txtEditCourseTitle.Text = reader["Title"].ToString();
                        txtEditCourseCategory.Text = reader["Category"].ToString();
                        txtEditCourseDescription.Text = reader["Description"].ToString();
                        pnlEditCourse.Visible = true;
                    }
                }
            }
        }

        protected void btnCancelCourseEdit_Click(object sender, EventArgs e)
        {
            pnlEditCourse.Visible = false;
        }

        protected void btnSaveCourseEdit_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrEmpty(ddlCourses.SelectedValue) ||
                string.IsNullOrEmpty(txtEditCourseTitle.Text)) return;

            string thumb = SaveCourseThumbnail(fuEditCourseThumbnail);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string q = "UPDATE Courses SET Title = @T, Category = @C, Description = @D"
                           + (thumb != null ? ", ThumbnailPath = @Th" : "")
                           + " WHERE CourseID = @ID";
                SqlCommand cmd = new SqlCommand(q, conn);
                cmd.Parameters.AddWithValue("@T", txtEditCourseTitle.Text.Trim());
                cmd.Parameters.AddWithValue("@C", txtEditCourseCategory.Text.Trim());
                cmd.Parameters.AddWithValue("@D", txtEditCourseDescription.Text.Trim());
                if (thumb != null) cmd.Parameters.AddWithValue("@Th", thumb);
                cmd.Parameters.AddWithValue("@ID", ddlCourses.SelectedValue);
                conn.Open();
                cmd.ExecuteNonQuery();
            }

            pnlEditCourse.Visible = false;
            BindCoursesDropdown(InstructorId);

            lblCourseMessage.Text = "Course updated successfully!";
            lblCourseMessage.CssClass = "d-block mb-2 fw-bold text-success";
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
                    string q1 = "DELETE FROM QuizQuestions WHERE QuizID IN (SELECT QuizID FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @ID))";
                    using (SqlCommand cmd = new SqlCommand(q1, conn, tx))
                    { cmd.Parameters.AddWithValue("@ID", courseId); cmd.ExecuteNonQuery(); }

                    string q2 = "DELETE FROM Quizzes WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @ID)";
                    using (SqlCommand cmd = new SqlCommand(q2, conn, tx))
                    { cmd.Parameters.AddWithValue("@ID", courseId); cmd.ExecuteNonQuery(); }

                    string q3 = "DELETE FROM LessonSimulations WHERE LessonID IN (SELECT LessonID FROM Lessons WHERE CourseID = @ID)";
                    using (SqlCommand cmd = new SqlCommand(q3, conn, tx))
                    { cmd.Parameters.AddWithValue("@ID", courseId); cmd.ExecuteNonQuery(); }

                    string q4 = "DELETE FROM Lessons WHERE CourseID = @ID";
                    using (SqlCommand cmd = new SqlCommand(q4, conn, tx))
                    { cmd.Parameters.AddWithValue("@ID", courseId); cmd.ExecuteNonQuery(); }

                    string q5 = "DELETE FROM Courses WHERE CourseID = @ID";
                    using (SqlCommand cmd = new SqlCommand(q5, conn, tx))
                    { cmd.Parameters.AddWithValue("@ID", courseId); cmd.ExecuteNonQuery(); }

                    tx.Commit();

                    BindCoursesDropdown(InstructorId);
                    lblCourseMessage.Text = "Course and all related content deleted.";
                    lblCourseMessage.CssClass = "d-block mb-2 fw-bold text-success";

                    CourseDeleted?.Invoke(this, EventArgs.Empty);
                }
                catch (Exception ex)
                {
                    tx.Rollback();
                    lblCourseMessage.Text = "Error deleting course: " + ex.Message;
                    lblCourseMessage.CssClass = "d-block mb-2 fw-bold text-danger";
                }
            }
        }
    }
}