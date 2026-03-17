using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.App_Code_Logic;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class UserManagement : System.Web.UI.Page
    {
        admin adminCS = new admin();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            if (!IsPostBack)
            {
                totalMember();
                totalActiveMember();
                totalSuspended();
                totalDeactivated();
                LoadUsers();
            }
        }

        private void totalMember() { lblTotalMembers.Text = adminCS.GetTotalUsers().ToString(); }
        private void totalActiveMember() { lblTotalActive.Text = adminCS.GetTotalActiveMembers().ToString(); }
        private void totalSuspended() { LblTotalSuspended.Text = adminCS.GetTotalSuspendedAccount().ToString(); }
        private void totalDeactivated() { LblTotalDeactivated.Text = adminCS.GetTotalDeactivatedAccount().ToString(); }

        private void LoadUsers()
        {
            gvUsers.DataSource = adminCS.GetAllUsers();
            gvUsers.DataBind();
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (e.CommandName == "ChangeStatus")
            {
                int targetUserId = Convert.ToInt32(e.CommandArgument);
                int currentAdminId = Convert.ToInt32(Session["UserID"]);

                // Block: cannot change your own account
                if (targetUserId == currentAdminId)
                {
                    ShowError("You cannot change your own account status.");
                    return;
                }

                // Block: cannot change another admin's account status
                string targetRole = adminCS.GetUserRole(targetUserId);
                if (targetRole == "Admin")
                {
                    ShowError("Admin accounts cannot have their status changed.");
                    return;
                }

                adminCS.ChangeUserStatus(targetUserId);

                totalMember();
                totalActiveMember();
                totalSuspended();
                totalDeactivated();
                LoadUsers();
            }
        }

        private void ShowError(string message)
        {
            // Surface the error — add a label in the .aspx if you want a visible panel,
            // or just use a JS alert via RegisterStartupScript
            System.Web.UI.ScriptManager.RegisterStartupScript(
                this, GetType(), "statusErr",
                $"alert('{message}');", true);
        }

        protected void gvUsers_SelectedIndexChanged(object sender, EventArgs e) { }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            string search = txtSearch.Text.Trim();
            string role = ddlRole.SelectedValue;
            string status = ddlStatus.SelectedValue;

            gvUsers.DataSource = adminCS.GetFilteredUsers(search, role, status);
            gvUsers.DataBind();
        }
    }
}
