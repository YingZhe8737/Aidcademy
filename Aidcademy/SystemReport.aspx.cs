using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using Aidcademy.Utilities;
using Aidcademy.App_Code_Logic;

namespace Aidcademy
{
    public partial class SystemReport : System.Web.UI.Page
    {
        admin adminCS = new admin();

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!SessionHelper.IsUserLoggedIn() || !SessionHelper.IsAdmin())
            {
                Response.Redirect("~/Login_signup.aspx");
                return;
            }
            if (!IsPostBack)
            {
                LoadTraffic();
            }
        }

        private void LoadTraffic()
        {
            string search = txtSearch.Text.Trim();
            string startDate = txtStartDate.Text;
            string endDate = txtEndDate.Text;

            gvTraffic.DataSource = adminCS.GetTraffic(search, startDate, endDate);
            gvTraffic.DataBind();

            lblTotalMembers.Text =
                adminCS.GetTotalMembersFiltered(search, startDate, endDate).ToString();

            lblTotalVisitors.Text =
                adminCS.GetTotalVisitorsFiltered(search, startDate, endDate).ToString();
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadTraffic();
        }
    }
}