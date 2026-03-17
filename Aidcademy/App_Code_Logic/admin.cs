using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Web;

namespace Aidcademy.App_Code_Logic
{
    public class admin
    {
        private string connStr = ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;

        public int GetUserCount(string role, string status)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users WHERE Role = @Role AND Status = @Status";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Role", role);
                    cmd.Parameters.AddWithValue("@Status", status);

                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public int GetTotalByStatus(string status)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users WHERE Status = @Status";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", status);
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public int GetTotalUsers()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public int GetTotalActiveMembers()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users WHERE Status = 'Active'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public int GetTotalSuspendedAccount()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users WHERE Status = 'Suspended'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public int GetTotalDeactivatedAccount()
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT COUNT(*) FROM Users WHERE Status = 'Deactivated'";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public class UserModel
        {
            public int UserID { get; set; }
            public string Username { get; set; }
            public string Email { get; set; }
            public string Role { get; set; }
            public string Status { get; set; }
            public DateTime CreatedDate { get; set; }
        }

        public List<UserModel> GetAllUsers()
        {
            List<UserModel> users = new List<UserModel>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = "SELECT * FROM Users";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    SqlDataReader reader = cmd.ExecuteReader();

                    while (reader.Read()) /* move to next record */
                    {
                        users.Add(new UserModel
                        {
                            UserID = Convert.ToInt32(reader["UserID"]), Username = reader["Username"].ToString(),Email = reader["Email"].ToString(),Role = reader["Role"].ToString(),Status = reader["Status"].ToString(),CreatedDate = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return users;
        }


        public void ChangeUserStatus(int userId)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                // First, get the current status
                string getStatus = "SELECT Status FROM Users WHERE UserID = @UserID";
                string currentStatus;

                using (SqlCommand cmd = new SqlCommand(getStatus, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    currentStatus = cmd.ExecuteScalar().ToString();
                }

                // Determine next status
                string newStatus;
                if (currentStatus == "Active")
                    newStatus = "Suspended";
                else if (currentStatus == "Suspended")
                    newStatus = "Deactivated";
                else
                    newStatus = "Active"; // Deactivated → back to Active

                string updateQuery = "UPDATE Users SET Status = @Status WHERE UserID = @UserID";

                using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@Status", newStatus);
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        public List<UserModel> GetFilteredUsers(string search, string role, string status)
        {
            List<UserModel> users = new List<UserModel>();

            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"SELECT * FROM Users WHERE 
                        (@Search = '' OR Username LIKE @Search OR Email LIKE @Search) AND
                        (@Role = 'All Roles' OR Role = @Role) AND
                        (@Status = 'All Status' OR Status = @Status)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Search", "%" + search + "%");
                    cmd.Parameters.AddWithValue("@Role", role);
                    cmd.Parameters.AddWithValue("@Status", status);

                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        users.Add(new UserModel
                        {
                            UserID = Convert.ToInt32(reader["UserID"]),
                            Username = reader["Username"].ToString(),
                            Email = reader["Email"].ToString(),
                            Role = reader["Role"].ToString(),
                            Status = reader["Status"].ToString(),
                            CreatedDate = Convert.ToDateTime(reader["CreatedAt"])
                        });
                    }
                }
            }

            return users;
        }

        public int GetTotalMembersFiltered(string search, string startDate, string endDate)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"SELECT COUNT(*) FROM SiteTraffic
                         WHERE IsRegisteredUser = 1
                         AND (@search = '' OR SessionID LIKE '%' + @search + '%')
                         AND (@startDate = '' OR VisitDate >= @startDate)
                         AND (@endDate = '' OR VisitDate <= @endDate)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@search", search);
                    cmd.Parameters.AddWithValue("@startDate", startDate);
                    cmd.Parameters.AddWithValue("@endDate", endDate);

                    return (int)cmd.ExecuteScalar();
                }
            }
        }


        public int GetTotalVisitorsFiltered(string search, string startDate, string endDate)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"SELECT COUNT(*) FROM SiteTraffic
                         WHERE IsRegisteredUser = 0
                         AND (@search = '' OR SessionID LIKE '%' + @search + '%')
                         AND (@startDate = '' OR VisitDate >= @startDate)
                         AND (@endDate = '' OR VisitDate <= @endDate)";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@search", search);
                    cmd.Parameters.AddWithValue("@startDate", startDate);
                    cmd.Parameters.AddWithValue("@endDate", endDate);

                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        public DataTable GetTraffic(string search, string startDate, string endDate)
        {
            using (SqlConnection conn = new SqlConnection(connStr))
            {
                conn.Open();

                string query = @"SELECT * FROM SiteTraffic
                         WHERE (@search = '' OR SessionID LIKE '%' + @search + '%')
                         AND (@startDate = '' OR VisitDate >= @startDate)
                         AND (@endDate = '' OR VisitDate <= @endDate)
                         ORDER BY VisitDate DESC";

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@search", search);
                    cmd.Parameters.AddWithValue("@startDate", startDate);
                    cmd.Parameters.AddWithValue("@endDate", endDate);

                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    return dt;
                }
            }
        }

        public string GetUserRole(int userId)
        {
            string query = "SELECT Role FROM Users WHERE UserID = @UserID";
            using (SqlConnection conn = new SqlConnection(connStr))
            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                cmd.Parameters.AddWithValue("@UserID", userId);
                conn.Open();
                object result = cmd.ExecuteScalar();
                return result != null ? result.ToString() : "";
            }
        }

    }
}
