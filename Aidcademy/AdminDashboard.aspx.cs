using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.App_Code_Logic;


namespace Aidcademy
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadUserSummary();
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