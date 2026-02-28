using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using Aidcademy.Utilities;

namespace Aidcademy
{
    public partial class MemberDashboard : System.Web.UI.Page
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                if (Session["UserID"] == null)
                {
                    Response.Redirect("~/Login_signup.aspx");
                    return;
                }
                LoadDashboardData();
            }
        }

        private void LoadDashboardData()
        {
            int userID = Convert.ToInt32(Session["UserID"]);

            // Display name from session (set at login)
            lblMemberName.Text = Session["UserName"]?.ToString() ?? "Member";

            try
            {
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get streak and points from Leaderboard
                    string queryStats = @"
                        SELECT
                            ISNULL(lb.DailyStreak, 0) AS DailyStreak,
                            ISNULL(lb.TotalPoints, 0) AS TotalPoints
                        FROM Leaderboard lb
                        WHERE lb.UserID = @UserID";

                    using (SqlCommand cmd = new SqlCommand(queryStats, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                lblDailyStreak.Text = reader["DailyStreak"].ToString();
                                lblTotalPoints.Text = reader["TotalPoints"].ToString();
                            }
                            else
                            {
                                lblDailyStreak.Text = "0";
                                lblTotalPoints.Text = "0";
                            }
                        }
                    }

                    // Count enrolled courses
                    string queryEnrolled = "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID";
                    using (SqlCommand cmd = new SqlCommand(queryEnrolled, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblEnrolledCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Count completed courses
                    string queryCompleted = "SELECT COUNT(*) FROM Enrollments WHERE UserID = @UserID AND IsCompleted = 1";
                    using (SqlCommand cmd = new SqlCommand(queryCompleted, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        lblCompletedCourses.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Load in-progress courses
                    string queryCourses = @"
                        SELECT c.CourseID, c.Title AS CourseName, e.ProgressPercentage
                        FROM Enrollments e
                        INNER JOIN Courses c ON e.CourseID = c.CourseID
                        WHERE e.UserID = @UserID AND e.IsCompleted = 0
                        ORDER BY e.EnrollmentDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryCourses, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptEnrolledCourses.DataSource = dt;
                        rptEnrolledCourses.DataBind();
                        pnlNoCourses.Visible = dt.Rows.Count == 0;
                    }

                    // Load recent lesson activity
                    string queryActivity = @"
                        SELECT TOP 5
                            l.Title      AS LessonTitle,
                            c.Title      AS CourseName,
                            lp.LastAccessedDate
                        FROM LessonProgress lp
                        INNER JOIN Lessons l  ON lp.LessonID = l.LessonID
                        INNER JOIN Courses c  ON l.CourseID  = c.CourseID
                        WHERE lp.UserID = @UserID
                        ORDER BY lp.LastAccessedDate DESC";

                    using (SqlCommand cmd = new SqlCommand(queryActivity, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserID", userID);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);
                        rptRecentActivity.DataSource = dt;
                        rptRecentActivity.DataBind();
                        pnlNoActivity.Visible = dt.Rows.Count == 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine("Dashboard error: " + ex.Message);
            }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            SessionHelper.SignOut();
            Response.Redirect("~/Login_signup.aspx");
        }
    }
}