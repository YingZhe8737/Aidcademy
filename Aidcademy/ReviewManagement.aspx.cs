using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class ReviewManagement : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
            if (!IsPostBack)
                LoadReviews();
        }

        private void LoadReviews()
        {
            string search = txtSearch.Text.Trim();
            string category = ddlCategory.SelectedValue;

            using (SqlConnection conn = new SqlConnection(connString))
            {
                // Stat counts
                lblTotal.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Feedback");
                lblResources.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Feedback WHERE Category = 'Resources'");
                lblBugs.Text = ScalarQuery(conn, "SELECT COUNT(*) FROM Feedback WHERE Category = 'Bug'");

                // Build filter query
                string where = "WHERE 1=1";
                if (!string.IsNullOrEmpty(search)) where += " AND MessageText LIKE @Search";
                if (!string.IsNullOrEmpty(category)) where += " AND Category = @Category";

                // Check whether the DateSubmitted column exists in the Feedback table
                bool hasDateCol = false;
                if (conn.State != ConnectionState.Open) conn.Open();
                using (SqlCommand chk = new SqlCommand(
                    "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Feedback' AND COLUMN_NAME='DateSubmitted'", conn))
                {
                    hasDateCol = (chk.ExecuteScalar() != null);
                }

                // Build SELECT — alias the date column as SubmittedAt to match .aspx Eval("SubmittedAt")
                string dateExpr = hasDateCol ? "DateSubmitted AS SubmittedAt" : "NULL AS SubmittedAt";
                string query = $@"SELECT FeedbackID, Category, MessageText, {dateExpr}
                                  FROM Feedback {where} ORDER BY FeedbackID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (!string.IsNullOrEmpty(search)) cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
                    if (!string.IsNullOrEmpty(category)) cmd.Parameters.AddWithValue("@Category", category);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);
                        rptReviews.DataSource = dt;
                        rptReviews.DataBind();
                        pnlEmpty.Visible = (dt.Rows.Count == 0);
                    }
                }
            }
        }

        protected void Filter_Changed(object sender, EventArgs e) => LoadReviews();

        private string ScalarQuery(SqlConnection conn, string sql)
        {
            if (conn.State != ConnectionState.Open) conn.Open();
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            {
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "0";
            }
        }

        // Called from .aspx via <%# GetCategoryIcon(...) %>
        protected string GetCategoryIcon(string category)
        {
            switch (category)
            {
                case "Resources": return "fa-book-open-reader";
                case "WebDesign": return "fa-palette";
                case "Bug": return "fa-bug";
                default: return "fa-comment";
            }
        }
    }
}
