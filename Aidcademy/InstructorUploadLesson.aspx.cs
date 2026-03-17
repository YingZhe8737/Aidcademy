using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.IO;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class InstructorUploadLesson : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsInstructor())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            // FIX: Save the current selection BEFORE DataBind clears it, restore it after.
            // DataBind() in LoadCourses resets ddlCourses.SelectedValue every time it runs.
            string savedCourseId = IsPostBack ? ctrlCourseSelector.SelectedCourseId : null;

            ctrlCourseSelector.InstructorId = Convert.ToInt32(Session["UserID"]);
            ctrlCourseSelector.LoadCourses();

            // Restore the selection the user had before the postback
            if (IsPostBack && !string.IsNullOrEmpty(savedCourseId))
                ctrlCourseSelector.SetSelectedCourse(savedCourseId);

            if (!IsPostBack)
            {
                if (!string.IsNullOrEmpty(ctrlCourseSelector.SelectedCourseId))
                {
                    CalculateNextStep();
                }
                else
                {
                    txtSequenceOrder.Text = "1";
                }
            }
        }

        // Fires when instructor picks a different course from the dropdown
        protected void ctrlCourseSelector_CourseChanged(object sender, EventArgs e)
        {
            CalculateNextStep();
        }

        // Fires after a course is deleted — nothing to clear on this page since no lesson is loaded
        protected void ctrlCourseSelector_CourseDeleted(object sender, EventArgs e)
        {
            txtSequenceOrder.Text = "1";
        }

        private void CalculateNextStep()
        {
            if (!string.IsNullOrEmpty(ctrlCourseSelector.SelectedCourseId))
            {
                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string query = "SELECT ISNULL(MAX(SequenceOrder), 0) + 1 FROM Lessons WHERE CourseID = @CourseID";
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", ctrlCourseSelector.SelectedCourseId);
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

        private string SaveLessonThumbnail(FileUpload fu)
        {
            if (!fu.HasFile) return null;
            string ext = Path.GetExtension(fu.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png") return null;
            string fileName = Guid.NewGuid().ToString() + ext;
            string relativePath = "~/Uploads/Thumbnails/" + fileName;
            string physicalPath = Server.MapPath("~/Uploads/Thumbnails/");
            if (!System.IO.Directory.Exists(physicalPath)) System.IO.Directory.CreateDirectory(physicalPath);
            fu.SaveAs(Server.MapPath(relativePath));
            return relativePath;
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e)
        {
            ProcessSubmission("Draft");
        }

        protected void btnPublishAdmin_Click(object sender, EventArgs e)
        {
            ProcessSubmission("Pending Admin");
        }

        private void ProcessSubmission(string status)
        {
            // Validate required fields
            if ((!ctrlCourseSelector.IsNewCourse && string.IsNullOrEmpty(ctrlCourseSelector.SelectedCourseId)) ||
                (ctrlCourseSelector.IsNewCourse && (string.IsNullOrEmpty(ctrlCourseSelector.NewCourseTitle) || string.IsNullOrEmpty(ctrlCourseSelector.NewCourseCategory))) ||
                string.IsNullOrEmpty(txtLessonTitle.Text) ||
                string.IsNullOrEmpty(txtSequenceOrder.Text) ||
                string.IsNullOrEmpty(hfContentBody.Value))
            {
                lblMessage.Text = "Please fill in all required fields.";
                lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                return;
            }

            int currentInstructorId = Convert.ToInt32(Session["UserID"]);
            int finalCourseId = 0;
            int finalLessonId = 0;
            bool isSuccess = false;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();
                SqlTransaction transaction = conn.BeginTransaction();

                try
                {
                    if (ctrlCourseSelector.IsNewCourse)
                    {
                        string courseThumb = ctrlCourseSelector.SaveNewCourseThumbnail();

                        string courseQuery = @"INSERT INTO Courses (UserID, Title, Description, Category, ThumbnailPath) 
                                               VALUES (@UserID, @Title, @Description, @Category, @ThumbnailPath);
                                               SELECT SCOPE_IDENTITY();";

                        using (SqlCommand cmd = new SqlCommand(courseQuery, conn, transaction))
                        {
                            cmd.Parameters.AddWithValue("@UserID", currentInstructorId);
                            cmd.Parameters.AddWithValue("@Title", ctrlCourseSelector.NewCourseTitle);
                            cmd.Parameters.AddWithValue("@Description", ctrlCourseSelector.NewCourseDescription);
                            cmd.Parameters.AddWithValue("@Category", ctrlCourseSelector.NewCourseCategory);
                            cmd.Parameters.AddWithValue("@ThumbnailPath", (object)courseThumb ?? DBNull.Value);
                            finalCourseId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                    }
                    else
                    {
                        finalCourseId = Convert.ToInt32(ctrlCourseSelector.SelectedCourseId);
                    }

                    string lessonThumb = SaveLessonThumbnail(fuLessonThumbnail);

                    string lessonQuery = @"INSERT INTO Lessons (CourseID, Title, Description, ContentBody, SequenceOrder, ApprovalStatus, ThumbnailPath) 
                                           VALUES (@CourseID, @Title, @Description, @ContentBody, @SequenceOrder, @ApprovalStatus, @ThumbnailPath);
                                           SELECT SCOPE_IDENTITY();";

                    using (SqlCommand cmd = new SqlCommand(lessonQuery, conn, transaction))
                    {
                        cmd.Parameters.AddWithValue("@CourseID", finalCourseId);
                        cmd.Parameters.AddWithValue("@Title", txtLessonTitle.Text.Trim());
                        cmd.Parameters.AddWithValue("@Description", txtLessonDescription.Text.Trim());
                        cmd.Parameters.AddWithValue("@ContentBody", hfContentBody.Value.Trim());
                        cmd.Parameters.AddWithValue("@SequenceOrder", txtSequenceOrder.Text.Trim());
                        cmd.Parameters.AddWithValue("@ApprovalStatus", status);
                        cmd.Parameters.AddWithValue("@ThumbnailPath", (object)lessonThumb ?? DBNull.Value);
                        finalLessonId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

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
                    isSuccess = true;
                }
                catch (Exception ex)
                {
                    transaction.Rollback();
                    lblMessage.Text = "Database Error: " + ex.Message;
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                }
            }

            if (isSuccess)
            {
                Response.Redirect("InstructorEditContent.aspx?LessonID=" + finalLessonId);
            }
        }
    }
}