using System;
using System.Configuration;
using System.Data.SqlClient;
using Aidcademy.App_Code_Logic;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            LoadUserSummary();
            LoadSystemSummary();
            LoadContentSummary();
        }

        // ── USER MANAGEMENT ──────────────────────────────────────────────────
        private void LoadUserSummary()
        {
            admin adminCS = new admin();

            lblActiveMembers.Text = "Active: " + adminCS.GetUserCount("Member", "Active");
            lblSuspendedMembers.Text = "Suspended: " + adminCS.GetUserCount("Member", "Suspended");
            lblDeactivatedMembers.Text = "Deactivated: " + adminCS.GetUserCount("Member", "Deactivated");

            lblActiveInstructors.Text = "Active: " + adminCS.GetUserCount("Instructor", "Active");
            lblSuspendedInstructors.Text = "Suspended: " + adminCS.GetUserCount("Instructor", "Suspended");
            lblDeactivatedInstructors.Text = "Deactivated: " + adminCS.GetUserCount("Instructor", "Deactivated");

            // Top strip: total users = all members + instructors
            int total = adminCS.GetTotalUsers();
            lblTotalUsersStrip.Text = total.ToString();
        }

        // ── SYSTEM REPORT ────────────────────────────────────────────────────
        private void LoadSystemSummary()
        {
            admin adminCS = new admin();

            int members = adminCS.GetTotalMembersFiltered("", "", "");
            int visitors = adminCS.GetTotalVisitorsFiltered("", "", "");

            lblTotalMembersSystem.Text = members.ToString();
            lblTotalVisitorsSystem.Text = visitors.ToString();
            lblTotalVisitorsStrip.Text = visitors.ToString();
        }

        // ── CONTENT MANAGEMENT ───────────────────────────────────────────────
        private void LoadContentSummary()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                conn.Open();

                string total = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons");
                string pending = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Pending Admin'");
                string published = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Approved'");
                string rejected = ScalarQuery(conn, "SELECT COUNT(*) FROM Lessons WHERE ApprovalStatus = 'Rejected'");

                lblContentTotal.Text = total;
                lblContentPending.Text = pending;
                lblContentPublished.Text = published;
                lblContentRejected.Text = rejected;

                // Top strip
                lblTotalLessonsStrip.Text = total;
                lblPendingStrip.Text = pending;
            }
        }

        private string ScalarQuery(SqlConnection conn, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, conn))
                return cmd.ExecuteScalar().ToString();
        }

        // ── REDIRECT ─────────────────────────────────────────────────────────
        protected void User_Management2(object sender, EventArgs e)
        {
            Response.Redirect("UserManagement.aspx");
        }
    }
}