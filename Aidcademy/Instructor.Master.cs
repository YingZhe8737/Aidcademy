using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Instructor : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserID"] == null)
            {
                Response.Redirect("Login_signup.aspx");
            }
            
            if (Session["Role"] != null && Session["Role"].ToString() != "Instructor") 
            { 
                Response.Redirect("Login_signup.aspx"); 
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}