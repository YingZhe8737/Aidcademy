using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class WebForm1 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

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
    }
}