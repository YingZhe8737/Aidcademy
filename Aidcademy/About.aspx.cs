using System;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class About : System.Web.UI.Page
    {
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/MainPage.aspx");
        }
    }
}
