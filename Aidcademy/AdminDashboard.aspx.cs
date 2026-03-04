using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.App_Code_Logic;
using Aidcademy.Utilities;


namespace Aidcademy
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }

            LoadUserSummary();
        }

        protected void Home_Click(object sender, EventArgs e)
        {
            Response.Redirect("AdminDashboard.aspx");
        }

        protected void SystemReport_Click(object sender, EventArgs e)
        {
            Response.Redirect("SystemReport.aspx");
        }

        protected void UserManagement_Click(object sender, EventArgs e)
        {
            Response.Redirect("UserManagement.aspx");
        }

        protected void ContentManagement_Click(object sender, EventArgs e)
        {
            Response.Redirect("ContentManagement.aspx");
        }

        protected void Logout_Click(object sender, EventArgs e)
        {

        }


        private void LoadUserSummary()
        {
            admin adminCS = new admin();

            // MEMBER
            lblActiveMembers.Text = "Active: " + adminCS.GetUserCount("Member", "Active");
            lblSuspendedMembers.Text = "Suspended: " + adminCS.GetUserCount("Member", "Suspended");
            lblDeactivatedMembers.Text = "Deactivated: " + adminCS.GetUserCount("Member", "Deactivated");

            // INSTRUCTOR
            lblActiveInstructors.Text = "Active: " + adminCS.GetUserCount("Instructor", "Active");
            lblSuspendedInstructors.Text = "Suspended: " + adminCS.GetUserCount("Instructor", "Suspended");
            lblDeactivatedInstructors.Text = "Deactivated: " + adminCS.GetUserCount("Instructor", "Deactivated");
        }





        protected void User_Management2(object sender, EventArgs e)
        {
            Response.Redirect("UserManagement.aspx");
        }
    }
}