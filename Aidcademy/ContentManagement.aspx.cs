using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class ContentManagement : System.Web.UI.Page
    {
        // ── DB connection string from Web.config ──────────────────────────────
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        // ── Stores the active filter across postbacks via ViewState ───────────
        private string ActiveFilter
        {
            get { return ViewState["ActiveFilter"] as string ?? "All"; }
            set { ViewState["ActiveFilter"] = value; }
        }


        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                BindDashboardStats();   // fill the 4 stat cards
                BindCourses();          // fill the course + lesson repeaters
            }
        }



        protected string GetStatusBadgeClassSimple(string status)
        {
            switch (status)
            {
                case "Pending Admin": return "Pending";
                case "Published": return "Published";
                case "Rejected": return "Rejected";
                default: return "Draft";
            }
        }

  
        protected string GetStatusCssClass(string status)
        {
            switch (status)
            {
                case "Pending Admin": return "status-Pending";
                case "Published": return "status-Published";
                case "Rejected": return "status-Rejected";
                default: return "status-Draft";
            }
        }

        protected string GetStatusBadgeClass(string status)
        {
            switch (status)
            {
                case "Pending Admin": return "bg-warning text-dark";
                case "Published": return "bg-success";
                case "Rejected": return "bg-danger";
                default: return "bg-secondary";
            }
        }


        private void BindDashboardStats()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                // Total lessons across all courses
                lblTotal.Text = ScalarQuery(conn,
                    "SELECT COUNT(*) FROM Lessons");

                // Lessons waiting for admin review
                lblPending.Text = ScalarQuery(conn,
                    "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Pending Admin'");

                // Lessons already approved and visible to members
                lblPublished.Text = ScalarQuery(conn,
                    "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Published'");

                // Lessons sent back to the instructor
                lblRejected.Text = ScalarQuery(conn,
                    "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Rejected'");
            }
        }

        private string ScalarQuery(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar().ToString();
        }


        private void BindCourses()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Join Users so we can show the instructor's name on each course heading
                string query = @"
                    SELECT  c.CourseID,
                            c.Title                         AS CourseTitle,
                            ISNULL(c.Category, 'General')   AS Category,
                            ISNULL(u.Username, 'Unknown')   AS InstructorName
                    FROM    Courses c
                    LEFT JOIN Users u ON c.UserID = u.UserID
                    ORDER BY c.CourseID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                {
                    DataTable dt = new DataTable();
                    sda.Fill(dt);
                    rptCourses.DataSource = dt;
                    rptCourses.DataBind();
                }
            }
        }


        protected void rptCourses_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {

            if (e.Item.ItemType != ListItemType.Item &&
                e.Item.ItemType != ListItemType.AlternatingItem) return;

            int courseId = Convert.ToInt32(DataBinder.Eval(e.Item.DataItem, "CourseID"));
            Repeater rptLessons = (Repeater)e.Item.FindControl("rptLessons");

            using (SqlConnection conn = new SqlConnection(connString))
            {

                string filterClause = (ActiveFilter == "All")
                    ? ""
                    : " AND l.ApprovalStatus = @StatusFilter";


                string query = $@"
                    SELECT  l.LessonID,
                            l.Title,
                            l.SequenceOrder,
                            ISNULL(l.ApprovalStatus, 'Draft') AS ApprovalStatus
                    FROM    Lessons l
                    WHERE   l.CourseID = @CourseID
                    {filterClause}
                    ORDER BY l.SequenceOrder ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseID", courseId);

                    if (ActiveFilter != "All")
                        cmd.Parameters.AddWithValue("@StatusFilter", ActiveFilter);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptLessons.DataSource = dt;
                        rptLessons.DataBind();
                    }
                }
            }
        }


        protected void btnFilter_Click(object sender, EventArgs e)
        {
            // CommandArgument is set in the .aspx:
            //   "All" | "Pending Admin" | "Published" | "Rejected"
            ActiveFilter = ((LinkButton)sender).CommandArgument;
            BindDashboardStats();
            BindCourses();
        }

        protected void btnViewLesson_Click(object sender, EventArgs e)
        {
            // Redirects to a detail/approval page, passing the LessonID.
            // TODO: replace "AdminLessonDetail.aspx" with your actual page name.
            int lessonId = Convert.ToInt32(((LinkButton)sender).CommandArgument);
            Response.Redirect("ViewLesson.aspx?LessonID=" + lessonId);
        }
    }
}
