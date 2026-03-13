using System;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class Member : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Auth guard: member pages require a logged-in Member session
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsMember())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }

        // Helper used in Master markup to highlight the active nav link
        protected bool IsActivePage(string pageName)
        {
            return Request.Url.AbsolutePath.IndexOf(pageName, StringComparison.OrdinalIgnoreCase) >= 0;
        }
    }
}
