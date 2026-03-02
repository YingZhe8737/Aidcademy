using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI.WebControls;

namespace Aidcademy
{
    public partial class RespondQuestions : System.Web.UI.Page
    {
        string connString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        private int currentInstructorId
        {
            get
            {
                if (Session["UserID"] != null) return Convert.ToInt32(Session["UserID"]);
                else return 1;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadAllQuestions();
            }
        }

        private void LoadAllQuestions()
        {
            using (SqlConnection conn = new SqlConnection(connString))
            {
                string query = @"SELECT cq.QuestionID, cq.UserID AS UserID, u.Username AS MemberUsername, 
                                        cq.QuestionText, cq.InstructorResponse, cq.Status, cq.ResponseDate, c.Title AS CourseTitle 
                                 FROM CourseQuestions cq
                                 INNER JOIN Courses c ON cq.CourseID = c.CourseID
                                 INNER JOIN Users u ON cq.UserID = u.UserID
                                 WHERE c.UserID = @InstructorID
                                 ORDER BY CASE WHEN cq.Status = 'Open' THEN 1 ELSE 2 END, cq.QuestionID DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@InstructorID", currentInstructorId);

                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        DataTable dt = new DataTable();
                        sda.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptQuestions.DataSource = dt;
                            rptQuestions.DataBind();
                            rptQuestions.Visible = true;
                            pnlNoQuestions.Visible = false;
                        }
                        else
                        {
                            rptQuestions.Visible = false;
                            pnlNoQuestions.Visible = true;
                        }
                    }
                }
            }
        }

        protected void rptQuestions_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "SubmitReply")
            {
                int questionId = Convert.ToInt32(e.CommandArgument);

                TextBox txtReply = (TextBox)e.Item.FindControl("txtReply");
                string answerText = txtReply.Text.Trim();

                if (string.IsNullOrEmpty(answerText))
                {
                    lblMessage.Text = "Reply cannot be empty.";
                    lblMessage.CssClass = "d-block mb-3 fw-bold text-danger";
                    return;
                }

                using (SqlConnection conn = new SqlConnection(connString))
                {
                    string updateQuery = @"UPDATE CourseQuestions 
                                           SET InstructorResponse = @Response, 
                                               ResponseDate = GETDATE(), 
                                               Status = 'Answered' 
                                           WHERE QuestionID = @QuestionID";

                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@Response", answerText);
                        cmd.Parameters.AddWithValue("@QuestionID", questionId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                lblMessage.Text = "Reply published successfully!";
                lblMessage.CssClass = "d-block mb-3 fw-bold text-success";

                LoadAllQuestions();
            }
        }
    }
}