using System;
using System.Web.UI;
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

            int members = adminCS.GetTotalMembersFiltered(search, startDate, endDate);
            int visitors = adminCS.GetTotalVisitorsFiltered(search, startDate, endDate);

            lblTotalMembers.Text = members.ToString();
            lblTotalVisitors.Text = visitors.ToString();

            // Pass values to the Chart.js hidden fields
            hfChartMembers.Value = members.ToString();
            hfChartVisitors.Value = visitors.ToString();
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            LoadTraffic();
        }
    }
}
