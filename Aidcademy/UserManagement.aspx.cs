using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
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



        private void totalMember()
        {
            lblTotalMembers.Text = adminCS.GetTotalUsers().ToString();
        }

        private void totalActiveMember()
        {
            lblTotalActive.Text = adminCS.GetTotalActiveMembers().ToString();
        }

        private void totalSuspended()
        {
            LblTotalSuspended.Text = adminCS.GetTotalSuspendedAccount().ToString();
        }

        private void totalDeactivated()
        {
            LblTotalDeactivated.Text = adminCS.GetTotalDeactivatedAccount().ToString();
        }

        private void LoadUsers()
        {


            gvUsers.DataSource = adminCS.GetAllUsers();
            gvUsers.DataBind();
        }

        protected void gvUsers_RowCommand(object sender, GridViewCommandEventArgs e)
        {

            if (e.CommandName == "ChangeStatus")
            {
                int userId = Convert.ToInt32(e.CommandArgument);
                if ( userId != 1)
                {
                    adminCS.ChangeUserStatus(userId);
                }

                

                totalMember();
                totalActiveMember();
                totalSuspended();
                totalDeactivated();
                LoadUsers();
            }
        }

        protected void gvUsers_SelectedIndexChanged(object sender, EventArgs e)
        {

        }


        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadFilter();
        }
        private void LoadFilter()
        {
            string search = txtSearch.Text.Trim();
            string role = ddlRole.SelectedValue;
            string status = ddlStatus.SelectedValue;

            gvUsers.DataSource = adminCS.GetFilteredUsers(search, role, status);
            gvUsers.DataBind();
        }
    }
}