using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class About : Page
    {
        protected void btnAboutUs(object sender, EventArgs e)
        {
            Response.Redirect("About.aspx");
        }
    }
}