using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class MainPage : System.Web.UI.Page
    {
        protected void btnTryFree_Click(object sender, EventArgs e)
        {
            Response.Redirect("Register.aspx");
        }
        protected void btnFeedback_Click(object sender, EventArgs e)
        {
            Response.Redirect("Feedback.aspx");
        }
        protected void btnAboutUs(object sender, EventArgs e)
        {
            Response.Redirect("About.aspx");
        }
    }
}