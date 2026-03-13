using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class SystemReport : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
        }

       
    }
}