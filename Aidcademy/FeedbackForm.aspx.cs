using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class WebForm3 : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }
        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            string category = DropDownList1.SelectedValue;
            string messageText = txtUsername.Text.Trim();

            // Validation
            if (string.IsNullOrEmpty(category))
            {
                lblMessage.Text = "Please select a category.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }

            if (string.IsNullOrEmpty(messageText))
            {
                lblMessage.Text = "Please enter your feedback.";
                lblMessage.ForeColor = System.Drawing.Color.Red;
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["YourConnectionString"].ConnectionString;

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                string query = "INSERT INTO Feedback (Category, MessageText) VALUES (@Category, @MessageText)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Category", category);
                    cmd.Parameters.AddWithValue("@MessageText", messageText);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            lblMessage.Text = "Feedback submitted successfully!";
            lblMessage.ForeColor = System.Drawing.Color.Green;

            // Clear fields
            DropDownList1.SelectedIndex = 0;
            txtUsername.Text = "";
        }

    }
}