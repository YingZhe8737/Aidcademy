using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class ContentManagement : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        public string ActiveFilter
        {
            get { return ViewState["ActiveFilter"] as string ?? "All"; }
            set { ViewState["ActiveFilter"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
            if (!IsPostBack)
            {
                BindDashboardStats();
                BindCourses();
            }
        }

        // PreRender fires AFTER all event handlers (including btnFilter_Click),
        // so ActiveFilter already has the newly selected value at this point.
        protected void Page_PreRender(object sender, EventArgs e)
        {
            SetActiveFilterTab();
        }

        private void SetActiveFilterTab()
        {
            btnAll.CssClass = "filter-tab-btn";
            btnPending.CssClass = "filter-tab-btn";
            btnPublished.CssClass = "filter-tab-btn";
            btnRejected.CssClass = "filter-tab-btn";

            switch (ActiveFilter)
            {
                case "Pending Admin": btnPending.CssClass += " tab-active-pending"; break;
                case "Published": btnPublished.CssClass += " tab-active-published"; break;
                case "Rejected": btnRejected.CssClass += " tab-active-rejected"; break;
                default: btnAll.CssClass += " tab-active-all"; break;
            }
        }

        protected string GetStatusBadgeClassSimple(string status)
        {
            switch (status)
            {
                case "Pending Admin": return "Pending";
                case "Published": case "Approved": return "Published";
                case "Rejected": return "Rejected";
                default: return "Draft";
            }
        }

        protected string GetStatusCssClass(string status)
        {
            switch (status)
            {
                case "Pending Admin": return "status-Pending";
                case "Published": case "Approved": return "status-Published";
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
                lblTotal.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons");
                lblPending.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Pending Admin'");
                // Count both "Published" and "Approved" as equivalent published states
                lblPublished.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus IN ('Published', 'Approved')");
                lblRejected.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Rejected'");
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
                string query = @"SELECT c.CourseID,
                                        c.Title                       AS CourseTitle,
                                        ISNULL(c.Category, 'General') AS Category,
                                        ISNULL(u.Username, 'Unknown') AS InstructorName
                                 FROM   Courses c
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
                // Handle both "Published" and "Approved" when filtering for Published tab
                string filterClause = "";
                if (ActiveFilter != "All")
                {
                    if (ActiveFilter == "Published")
                        filterClause = " AND l.ApprovalStatus IN ('Published', 'Approved')";
                    else
                        filterClause = " AND l.ApprovalStatus = @StatusFilter";
                }

                // Column aliased as ThumbnailPath — matches Eval("ThumbnailPath") in .aspx
                string query = $@"SELECT l.LessonID,
                                         l.Title,
                                         l.SequenceOrder,
                                         ISNULL(l.ApprovalStatus, 'Draft') AS ApprovalStatus,
                                         l.ThumbnailPath
                                  FROM   Lessons l
                                  WHERE  l.CourseID = @CourseID
                                  {filterClause}
                                  ORDER BY l.SequenceOrder ASC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@CourseID", courseId);
                    if (ActiveFilter != "All" && ActiveFilter != "Published")
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
            ActiveFilter = ((LinkButton)sender).CommandArgument;
            BindDashboardStats();
            BindCourses();
        }

        protected void btnViewLesson_Click(object sender, EventArgs e)
        {
            int lessonId = Convert.ToInt32(((LinkButton)sender).CommandArgument);
            Response.Redirect("ViewLesson.aspx?LessonID=" + lessonId);
        }
    }
}
