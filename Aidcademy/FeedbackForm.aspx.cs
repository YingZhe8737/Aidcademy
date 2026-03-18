using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

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

            if (string.IsNullOrEmpty(category))
            {
                lblMessage.Text = "Please select a category.";
                lblMessage.CssClass = "msg-error";
                return;
            }

            if (string.IsNullOrEmpty(messageText))
            {
                lblMessage.Text = "Please enter your feedback.";
                lblMessage.CssClass = "msg-error";
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

            try
            {
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

                lblMessage.Text = "Feedback submitted successfully! Thank you.";
                lblMessage.CssClass = "msg-success";

                DropDownList1.SelectedIndex = 0;
                txtUsername.Text = "";
            }
            catch (Exception ex)
            {
                lblMessage.Text = "Could not submit feedback. Please try again. (" + ex.Message + ")";
                lblMessage.CssClass = "msg-error";
            }
        }
    }
}
