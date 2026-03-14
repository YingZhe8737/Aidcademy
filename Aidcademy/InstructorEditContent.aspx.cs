using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;
using System.IO;

namespace Aidcademy
{
    public partial class InstructorEditContent : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ctrlCourseSelector.InstructorId = Convert.ToInt32(Session["UserID"]);
                ctrlCourseSelector.LoadCourses();

                if (Request.QueryString["LessonID"] != null)
                {
                    int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);
                    LoadLessonData(lessonId);
                }
            }
        }

        // Fires when instructor picks a different course from the dropdown
        protected void ctrlCourseSelector_CourseChanged(object sender, EventArgs e)
        {
            // Nothing needed here for the edit page — the lesson is already loaded
        }

        // Fires after a course is deleted — clear the lesson fields since the course is gone
        protected void ctrlCourseSelector_CourseDeleted(object sender, EventArgs e)
        {
            txtLessonTitle.Text = "";
            txtLessonDescription.Text = "";
            txtSequenceOrder.Text = "";
            hfContentBody.Value = "";
            hfSimulationType.Value = "";
            hfSimulationData.Value = "";
            lblMessage.Text = "Course deleted. All lesson data has been cleared.";
            lblMessage.CssClass = "d-block mb-3 fw-bold text-success";
        }

        private string SaveLessonThumbnail(FileUpload fu)
        {
            if (!fu.HasFile) return null;
            string ext = Path.GetExtension(fu.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png") return null;
            string fileName = Guid.NewGuid().ToString() + ext;
            string relativePath = "~/Uploads/Thumbnails/" + fileName;
            string physicalPath = Server.MapPath("~/Uploads/Thumbnails/");
            if (!Directory.Exists(physicalPath)) Directory.CreateDirectory(physicalPath);
            fu.SaveAs(Server.MapPath(relativePath));
            return relativePath;
        }

        private void LoadLessonData(int lessonId)
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"SELECT l.CourseID, l.Title, l.Description, l.ContentBody, l.SequenceOrder
                                 FROM Lessons l
                                 INNER JOIN Courses c ON l.CourseID = c.CourseID
                                 WHERE l.LessonID = @LessonID AND c.UserID = @InstructorID";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@LessonID", lessonId);
                    cmd.Parameters.AddWithValue("@InstructorID", Convert.ToInt32(Session["UserID"]));
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            ctrlCourseSelector.SetSelectedCourse(reader["CourseID"].ToString());
                            txtLessonTitle.Text = reader["Title"].ToString();
                            txtLessonDescription.Text = reader["Description"].ToString();
                            txtSequenceOrder.Text = reader["SequenceOrder"].ToString();
                            hfContentBody.Value = reader["ContentBody"].ToString();
                        }
                        else
                        {
                            // Lesson not found or belongs to another instructor — redirect away
                            Response.Redirect("InstructorManageContent.aspx");
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
                            hfSimulationType.Value = "";
                            hfSimulationData.Value = "";
                        }
                    }
                }
            }
        }

        protected void btnSaveDraft_Click(object sender, EventArgs e) { UpdateLesson("Draft"); }
        protected void btnPublishAdmin_Click(object sender, EventArgs e) { UpdateLesson("Pending Admin"); }

        private void UpdateLesson(string status)
        {
            if (Request.QueryString["LessonID"] == null) return;
            int lessonId = Convert.ToInt32(Request.QueryString["LessonID"]);

            string newThumbPath = SaveLessonThumbnail(fuLessonThumbnail);

            using (SqlConnection conn = new SqlConnection(connString))
            {
                string updateQuery = @"UPDATE Lessons 
                                       SET CourseID = @CourseID, Title = @Title, Description = @Description,
                                           ContentBody = @ContentBody, SequenceOrder = @SequenceOrder,
                                           ApprovalStatus = @ApprovalStatus";

                if (newThumbPath != null) updateQuery += ", ThumbnailPath = @ThumbnailPath";
                updateQuery += " WHERE LessonID = @LessonID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseID", ctrlCourseSelector.SelectedCourseId);
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

            lblMessage.Text = $"Lesson updated and marked as '{status}'.";
            lblMessage.CssClass = "d-block mb-3 fw-bold text-success";
        }
    }
}