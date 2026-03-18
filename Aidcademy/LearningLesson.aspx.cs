using System;
using System.Data;
using System.Data.SqlClient;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class LearningLesson : System.Web.UI.Page
    {
        private bool isMember;
        private int userID;
        private int courseID;

        protected void Page_Load(object sender, EventArgs e)
        {
            string role = (Session["UserRole"] ?? Session["Role"] ?? string.Empty).ToString();
            isMember = Session["UserID"] != null &&
                       role.Equals("Member", StringComparison.OrdinalIgnoreCase);
            userID = isMember ? Convert.ToInt32(Session["UserID"]) : 0;

            if (!int.TryParse(Request.QueryString["CourseID"], out courseID) || courseID <= 0)
            {
                Response.Redirect("~/LearningCourse.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadCourseTitle();
                LoadLessons();
            }
        }

        protected bool IsMemberView
        {
            get { return isMember; }
        }

        // uses shared SessionHelper.GetDisplayName() 
        protected string GetMemberName()  { return SessionHelper.GetDisplayName(); }
        protected string GetMemberInitial() { return SessionHelper.GetInitial(); }

        private void LoadCourseTitle()
        {
            string query = "SELECT TOP 1 Title FROM Courses WHERE CourseID = @CourseID";
            SqlParameter[] parameters = { new SqlParameter("@CourseID", courseID) };
            object title = DatabaseHelper.ExecuteScalar(query, parameters);

            if (title == null || title == DBNull.Value)
            {
                Response.Redirect("~/LearningCourse.aspx");
                return;
            }

            lblCourseTitle.Text = Convert.ToString(title);
        }

        private void LoadLessons()
        {
            try
            {
                DataTable dt;

                if (isMember)
                {
                    string query = @"
                        SELECT l.LessonID, l.Title, l.Description, l.SequenceOrder,
                               ISNULL(l.ThumbnailPath,'') AS LessonPhoto,
                               CASE WHEN lp.Status = 'Completed' THEN 1 ELSE 0 END AS IsCompleted,
                               1 AS IsMember,
                               0 AS IsFreeLesson
                        FROM Lessons l
                        LEFT JOIN LessonProgress lp ON l.LessonID = lp.LessonID AND lp.UserID = @UserID
                        WHERE l.CourseID = @CourseID AND l.ApprovalStatus = 'Approved'
                        ORDER BY l.SequenceOrder";

                    SqlParameter[] parameters =
                    {
                        new SqlParameter("@CourseID", courseID),
                        new SqlParameter("@UserID", userID)
                    };
                    dt = DatabaseHelper.ExecuteQuery(query, parameters);
                }
                else
                {
                    string query = @"
                        SELECT v.LessonID, v.Title, v.Description, v.SequenceOrder,
                               v.LessonPhoto,
                               0 AS IsCompleted,
                               0 AS IsMember,
                               CASE
                                   WHEN v.LessonID = (
                                       SELECT TOP 1 l3.LessonID
                                       FROM Lessons l3
                                       WHERE l3.CourseID = v.CourseID
                                         AND l3.ApprovalStatus = 'Approved'
                                         AND (
                                             l3.Title LIKE '%CPR%' OR l3.Description LIKE '%CPR%'
                                             OR l3.Title LIKE '%AED%' OR l3.Description LIKE '%AED%'
                                         )
                                       ORDER BY l3.SequenceOrder, l3.LessonID
                                   ) THEN 1
                                   ELSE 0
                               END AS IsFreeLesson
                        FROM (
                            SELECT l.LessonID, l.CourseID, l.Title, l.Description, l.SequenceOrder,
                                   ISNULL(l.ThumbnailPath,'') AS LessonPhoto,
                                   ROW_NUMBER() OVER (PARTITION BY l.CourseID ORDER BY l.SequenceOrder, l.LessonID) AS rn
                            FROM Lessons l
                            WHERE l.CourseID = @CourseID AND l.ApprovalStatus = 'Approved'
                        ) v
                        INNER JOIN Courses c ON c.CourseID = v.CourseID
                        ORDER BY v.SequenceOrder";

                    SqlParameter[] parameters = { new SqlParameter("@CourseID", courseID) };
                    dt = DatabaseHelper.ExecuteQuery(query, parameters);
                }

                rptLessons.DataSource = dt;
                rptLessons.DataBind();
                pnlNoLessons.Visible = dt.Rows.Count == 0;
            }
            catch
            {
                pnlNoLessons.Visible = true;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        protected string GetLessonImageUrl(object lessonPhotoObj, object sequenceOrderObj)
        {
            string lessonPhoto = lessonPhotoObj == null || lessonPhotoObj == DBNull.Value
                ? string.Empty
                : Convert.ToString(lessonPhotoObj);

            if (!string.IsNullOrWhiteSpace(lessonPhoto))
                return ResolveUrl(lessonPhoto);

            int sequenceOrder = 0;
            if (sequenceOrderObj != null && sequenceOrderObj != DBNull.Value)
                sequenceOrder = Convert.ToInt32(sequenceOrderObj);

            string mappedPhoto = GetMappedThumbnailBySequence(sequenceOrder);
            if (!string.IsNullOrEmpty(mappedPhoto))
                return ResolveUrl(mappedPhoto);

            return ResolveUrl("~/Images/default-lesson.png");
        }

        private static string GetMappedThumbnailBySequence(int sequenceOrder)
        {
            switch (sequenceOrder)
            {
                case 1:
                    return "~/Uploads/Thumbnails/3c32796e-ad74-4ef0-b6b4-83a4095e329d.jpg";
                case 2:
                    return "~/Uploads/Thumbnails/7587ab03-4062-42f7-8b7b-bd83b854fc15.jpg";
                case 3:
                    return "~/Uploads/Thumbnails/4eab017b-9fc6-43e3-9272-cc0c4aad3d45.jpg";
                case 4:
                    return "~/Uploads/Thumbnails/048212d1-bc83-4b4e-8b57-2e6f952fd947.jpg";
                case 5:
                    return "~/Uploads/Thumbnails/9c1947ce-f903-432b-94de-78db69810191.jpg";
                default:
                    return string.Empty;
            }
        }
    }
}
