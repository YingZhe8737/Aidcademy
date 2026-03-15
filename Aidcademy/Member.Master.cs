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

        protected string GetMemberName()
        {
            string name = SessionHelper.GetUsername();
            if (!string.IsNullOrWhiteSpace(name))
            {
                return name;
            }

            name = Session["Name"]?.ToString();
            if (!string.IsNullOrWhiteSpace(name))
            {
                return name;
            }

            return "Member";
        }

        protected string GetMemberInitial()
        {
            string name = GetMemberName().Trim();
            return name.Length > 0 ? name.Substring(0, 1).ToUpperInvariant() : "M";
        }

        // Helper used in Master markup to highlight the active nav link
        protected bool IsActivePage(string pageName)
        {
            string path = Request.Url.AbsolutePath ?? string.Empty;
            return path.IndexOf(pageName, StringComparison.OrdinalIgnoreCase) >= 0;
        }
    }
}
