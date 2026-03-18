using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.Security;

namespace Aidcademy.Utilities
{
    // Handles all database
    public static class DatabaseHelper
    {
        private static string ConnectionString
        {
            get
            {
                return ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString;
            }
        }

        // Run a SELECT query and return the results as a DataTable
        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            DataTable dt = new DataTable();

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    using (SqlDataAdapter adapter = new SqlDataAdapter(cmd))
                    {
                        conn.Open();
                        adapter.Fill(dt);
                    }
                }
            }

            return dt;
        }

        // Run INSERT, UPDATE, or DELETE. Returns the number of rows affected.
        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            int rowsAffected = 0;

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    conn.Open();
                    rowsAffected = cmd.ExecuteNonQuery();
                }
            }

            return rowsAffected;
        }

        // Run a query that returns a single value
        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            object result = null;

            using (SqlConnection conn = new SqlConnection(ConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    if (parameters != null)
                        cmd.Parameters.AddRange(parameters);

                    conn.Open();
                    result = cmd.ExecuteScalar();
                }
            }

            return result;
        }

        // Test if the database connection works
        public static bool TestConnection()
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnectionString))
                {
                    conn.Open();
                    return true;
                }
            }
            catch
            {
                return false;
            }
        }
    }


    // Password hashing and validation
    public static class SecurityHelper
    {
        // Hash a password using SHA256
        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder builder = new StringBuilder();
                foreach (byte b in bytes)
                    builder.Append(b.ToString("x2"));
                return builder.ToString();
            }
        }

        // Check if the given password matches the stored hash
        public static bool VerifyPassword(string password, string hash)
        {
            return HashPassword(password).Equals(hash, StringComparison.OrdinalIgnoreCase);
        }

        /// Verify a plaintext password against a stored hash.
        public static bool VerifyStoredPassword(string plainPassword, string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash)) return false;
            try
            {
                return BCrypt.Net.BCrypt.Verify(plainPassword, storedHash);
            }
            catch (BCrypt.Net.SaltParseException)
            {
                return VerifyPassword(plainPassword, storedHash);
            }
        }

        // Generate a random token for password reset 
        public static string GenerateResetToken()
        {
            return Guid.NewGuid().ToString("N") + DateTime.Now.Ticks.ToString("x");
        }

        // Validate password strength 
        public static bool IsPasswordValid(string password, out string errorMessage)
        {
            errorMessage = string.Empty;

            if (string.IsNullOrWhiteSpace(password))
            {
                errorMessage = "Password cannot be empty";
                return false;
            }
            if (password.Length < 8)
            {
                errorMessage = "Password must be at least 8 characters long";
                return false;
            }
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[A-Z]"))
            {
                errorMessage = "Password must contain at least one uppercase letter";
                return false;
            }
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[a-z]"))
            {
                errorMessage = "Password must contain at least one lowercase letter";
                return false;
            }
            if (!System.Text.RegularExpressions.Regex.IsMatch(password, @"[0-9]"))
            {
                errorMessage = "Password must contain at least one digit";
                return false;
            }

            return true;
        }
    }

    // OTP METHODS- generate, save, and verify passwords
    public static class OtpHelper
    {
        private static readonly Random _rng = new Random();

        public static string GenerateNumericOtp()
        {
            return GenerateOtp();
        }

        public static string HmacOtp(string otp, string secret)
        {
            using (var hmac = new HMACSHA256(Encoding.UTF8.GetBytes(secret)))
            {
                byte[] hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(otp));
                return Convert.ToBase64String(hash);
            }
        }

        public static void SaveOtpToDb(int userId, string otpHash, DateTime expiresAt)
        {
            using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString))
            {
                conn.Open();
                string insert = "INSERT INTO OtpCodes (UserID, OtpCode, Purpose, ExpiresAt) VALUES (@UserID, @OtpCode, 'Login', @ExpiresAt)";
                using (SqlCommand cmd = new SqlCommand(insert, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userId);
                    cmd.Parameters.AddWithValue("@OtpCode", otpHash);
                    cmd.Parameters.AddWithValue("@ExpiresAt", expiresAt);
                    cmd.ExecuteNonQuery();
                }
            }
        }


        /// Generate a random 7-digit OTP string.
        public static string GenerateOtp()
        {
            using (var rng = new RNGCryptoServiceProvider())
            {
                byte[] data = new byte[4];
                rng.GetBytes(data);
                int value = Math.Abs(BitConverter.ToInt32(data, 0)) % 10000000;
                return value.ToString("D7"); // always 7 digits
            }
        }


        public static string SaveOtp(int userID, string purpose)
        {
            string code = GenerateOtp();
            int expiryMinutes = 10;
            int.TryParse(ConfigurationManager.AppSettings["OtpExpiryMinutes"], out expiryMinutes);
            DateTime expiresAt = DateTime.Now.AddMinutes(expiryMinutes);

            using (SqlConnection conn = new SqlConnection(
                ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString))
            {
                conn.Open();

                string invalidate = @"
                    UPDATE OtpCodes SET IsUsed = 1
                    WHERE UserID = @UserID AND Purpose = @Purpose AND IsUsed = 0";
                using (SqlCommand cmd = new SqlCommand(invalidate, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.Parameters.AddWithValue("@Purpose", purpose);
                    cmd.ExecuteNonQuery();
                }

                // Hash the OTP with BCrypt 
                string hashedCode = BCrypt.Net.BCrypt.HashPassword(code);

                // Insert new OTP 
                string insert = @"
                    INSERT INTO OtpCodes (UserID, OtpCode, Purpose, ExpiresAt)
                    VALUES (@UserID, @OtpCode, @Purpose, @ExpiresAt)";
                using (SqlCommand cmd = new SqlCommand(insert, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.Parameters.AddWithValue("@OtpCode", hashedCode);
                    cmd.Parameters.AddWithValue("@Purpose", purpose);
                    cmd.Parameters.AddWithValue("@ExpiresAt", expiresAt);
                    cmd.ExecuteNonQuery();
                }
            }

            return code;
        }

        /// Verify that the supplied OTP code is correct, unused, and unexpired.
        public static bool VerifyOtp(int userID, string code, string purpose, out string errorMessage)
        {
            errorMessage = string.Empty;
            string trimmedCode = code.Trim();

            using (SqlConnection conn = new SqlConnection(
                ConfigurationManager.ConnectionStrings["AidcademyDB"].ConnectionString))
            {
                conn.Open();

                // Fetch all unused OTPs for this user+purpose (cannot match hashed value in SQL)
                string query = @"
                    SELECT OtpID, OtpCode, ExpiresAt
                    FROM OtpCodes
                    WHERE UserID  = @UserID
                      AND Purpose = @Purpose
                      AND IsUsed  = 0
                    ORDER BY CreatedAt DESC";

                var candidates = new System.Collections.Generic.List<Tuple<int, string, DateTime>>();

                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@UserID", userID);
                    cmd.Parameters.AddWithValue("@Purpose", purpose);

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            candidates.Add(Tuple.Create(
                                Convert.ToInt32(reader["OtpID"]),
                                reader["OtpCode"].ToString(),
                                Convert.ToDateTime(reader["ExpiresAt"])));
                        }
                    }
                }

                if (candidates.Count == 0)
                {
                    errorMessage = "Invalid OTP code. Please try again.";
                    return false;
                }

                // Check each candidate using BCrypt
                foreach (var candidate in candidates)
                {
                    int otpID = candidate.Item1;
                    string hashedOtp = candidate.Item2;
                    DateTime expiresAt = candidate.Item3;

                    if (!BCrypt.Net.BCrypt.Verify(trimmedCode, hashedOtp))
                        continue;

                    // Match found — check expiry
                    if (DateTime.Now > expiresAt)
                    {
                        errorMessage = "OTP has expired. Please request a new one.";
                        return false;
                    }

                    // Mark as used
                    string markUsed = "UPDATE OtpCodes SET IsUsed = 1 WHERE OtpID = @OtpID";
                    using (SqlCommand cmdMark = new SqlCommand(markUsed, conn))
                    {
                        cmdMark.Parameters.AddWithValue("@OtpID", otpID);
                        cmdMark.ExecuteNonQuery();
                    }

                    return true;
                }

                errorMessage = "Invalid OTP code. Please try again.";
                return false;
            }
        }
    }


    // Sends emails via SMTP (configured in Web.config)
    public static class EmailHelper
    {
        public static bool SendEmail(string toEmail, string subject, string body, out string errorMessage)
        {
            errorMessage = string.Empty;

            try
            {
                string smtpServer   = ConfigurationManager.AppSettings["SmtpServer"];
                int smtpPort        = int.Parse(ConfigurationManager.AppSettings["SmtpPort"]);
                string smtpUsername = ConfigurationManager.AppSettings["SmtpUsername"];
                string smtpPassword = ConfigurationManager.AppSettings["SmtpPassword"];
                bool enableSSL      = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSSL"]);
                string emailFrom    = ConfigurationManager.AppSettings["EmailFrom"];

                MailMessage mail = new MailMessage
                {
                    From       = new MailAddress(emailFrom, "Aidcademy"),
                    Subject    = subject,
                    Body       = body,
                    IsBodyHtml = true
                };
                mail.To.Add(toEmail);

                SmtpClient smtp = new SmtpClient(smtpServer, smtpPort)
                {
                    Credentials = new NetworkCredential(smtpUsername, smtpPassword),
                    EnableSsl   = enableSSL
                };

                // DEVELOPMENT MOCK 
                if (smtpPassword == "your-app-password")
                {
                    string logPath = HttpContext.Current.Server.MapPath("~/App_Data/MockEmails.txt");
                    string logEntry = $"[{DateTime.Now}] MOCK EMAIL TO: {toEmail}\r\nSUBJECT: {subject}\r\nBODY: {body}\r\n========================================\r\n\r\n";
                    System.IO.File.AppendAllText(logPath, logEntry);
                    return true;
                }

                smtp.Send(mail);
                return true;
            }
            catch (Exception ex)
            {
                errorMessage = ex.Message;
                return false;
            }
        }


        /// Send a 7-digit OTP email
        /// "Login" or "ForgotPassword"
        public static bool SendOtpEmail(string toEmail, string otp, string purpose, out string errorMessage)
        {
            string subject = purpose == "ForgotPassword"
                ? "Your Aidcademy Password Reset OTP"
                : "Your Aidcademy Login Verification Code";

            string purposeLabel = purpose == "ForgotPassword"
                ? "reset your password"
                : "complete your login";

            int expiryMinutes = 10;
            int.TryParse(ConfigurationManager.AppSettings["OtpExpiryMinutes"], out expiryMinutes);

            string body = $@"
                <html>
                <body style='font-family:Segoe UI,Arial,sans-serif; color:#333;'>
                    <div style='max-width:480px;margin:0 auto;padding:30px;border:1px solid #e0e0e0;border-radius:12px;'>
                        <h2 style='color:#dc2626;'>&#10084;&#65039; AIDCADEMY</h2>
                        <p>Hi there,</p>
                        <p>Use the verification code below to {purposeLabel}:</p>
                        <div style='text-align:center;margin:30px 0;'>
                            <span style='font-size:40px;font-weight:bold;letter-spacing:12px;
                                         background:#fff0f0;padding:16px 28px;border-radius:10px;
                                         color:#dc2626;border:2px solid #fca5a5;'>{otp}</span>
                        </div>
                        <p style='color:#888;font-size:13px;'>This code expires in <strong>{expiryMinutes} minutes</strong>.
                        If you did not request this, you can safely ignore this email.</p>
                        <hr style='border:none;border-top:1px solid #eee;margin:20px 0;'/>
                        <p style='font-size:12px;color:#aaa;'>AIDCADEMY &mdash; First Aid Learning Platform</p>
                    </div>
                </body>
                </html>";

            return SendEmail(toEmail, subject, body, out errorMessage);
        }

        // password reset
        public static bool SendPasswordResetEmail(string toEmail, string resetLink, out string errorMessage)
        {
            string subject = "Password Reset - Aidcademy";
            string body = $@"
                <html><body>
                    <h2>Password Reset Request</h2>
                    <p>Dear User,</p>
                    <p>Click the link below to reset your password:</p>
                    <p><a href='{resetLink}'>Reset Password</a></p>
                    <p>This link will expire in 24 hours.</p>
                    <p>If you did not request this password reset, please ignore this email.</p>
                    <br/><p>Best regards,<br/>Aidcademy Team</p>
                </body></html>";

            return SendEmail(toEmail, subject, body, out errorMessage);
        }
    }


    // Session FormsAuthentication
    public static class SessionHelper
    {
        /// Call this after OTP is verified to fully log the user in.
        public static void SetLoginSession(int userID, string role, string fullName, string email)
        {
            var context = HttpContext.Current;
            context.Session["UserID"]   = userID;
            context.Session["UserRole"] = role;
            context.Session["UserName"] = fullName;
            context.Session["Email"]    = email;

            // Legacy keys used by some older pages/master files
            context.Session["Role"] = role;
            context.Session["Name"] = fullName;

            // Create a Forms Auth ticket that carries the role as UserData
            // User.IsInRole() can be wired up in Global.asax if needed
            FormsAuthenticationTicket ticket = new FormsAuthenticationTicket(
                version:     1,
                name:        userID.ToString(),
                issueDate:   DateTime.Now,
                expiration:  DateTime.Now.AddMinutes(30),
                isPersistent: false,
                userData:    role,
                cookiePath:  FormsAuthentication.FormsCookiePath
            );

            string encryptedTicket = FormsAuthentication.Encrypt(ticket);
            var cookie = new HttpCookie(FormsAuthentication.FormsCookieName, encryptedTicket)
            {
                HttpOnly = true,
                Expires  = DateTime.Now.AddMinutes(30)
            };
            context.Response.Cookies.Add(cookie);
        }


        /// Log the user out: clear the Forms Auth cookie and abandon the session.
        public static void SignOut()
        {
            FormsAuthentication.SignOut();
            HttpContext.Current.Session.Clear();
            HttpContext.Current.Session.Abandon();

            // Expire the auth cookie immediately
            var cookie = new HttpCookie(FormsAuthentication.FormsCookieName)
            {
                Expires  = DateTime.Now.AddYears(-1),
                HttpOnly = true
            };
            HttpContext.Current.Response.Cookies.Add(cookie);
        }

        public static bool IsUserLoggedIn()
        {
            return GetUserID() > 0;
        }

        public static bool IsMember()
        {
            return string.Equals(GetRole(), "Member", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsAdmin()
        {
            return string.Equals(GetRole(), "Admin", StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsInstructor()
        {
            return string.Equals(GetRole(), "Instructor", StringComparison.OrdinalIgnoreCase);
        }

        public static int GetUserID()
        {
            if (HttpContext.Current.Session["UserID"] != null)
                return Convert.ToInt32(HttpContext.Current.Session["UserID"]);

            // Fallback: restore from auth ticket when session is missing
            try
            {
                if (HttpContext.Current.Request.IsAuthenticated)
                {
                    FormsIdentity id = HttpContext.Current.User?.Identity as FormsIdentity;
                    string ticketName = id?.Ticket?.Name;
                    int parsed;
                    if (int.TryParse(ticketName, out parsed))
                        return parsed;
                }
            }
            catch { }

            return 0;
        }

        public static string GetUsername()
        {
            return HttpContext.Current.Session["UserName"]?.ToString() ?? "";
        }

        public static string GetRole()
        {
            string role = (HttpContext.Current.Session["UserRole"]?.ToString() ?? "").Trim();
            if (!string.IsNullOrEmpty(role))
                return role;

            // Legacy key fallback
            role = (HttpContext.Current.Session["Role"]?.ToString() ?? "").Trim();
            if (!string.IsNullOrEmpty(role))
                return role;

            // Fallback from auth ticket UserData
            try
            {
                if (HttpContext.Current.Request.IsAuthenticated)
                {
                    FormsIdentity id = HttpContext.Current.User?.Identity as FormsIdentity;
                    role = (id?.Ticket?.UserData ?? "").Trim();
                    if (!string.IsNullOrEmpty(role))
                        return role;
                }
            }
            catch { }

            return "";
        }


        /// Redirect to the correct dashboard based on role.
        public static void RedirectByRole(string role)
        {
            var ctx = HttpContext.Current;
            if (role == "Admin")
                ctx.Response.Redirect("~/AdminDashboard.aspx");
            else if (role == "Instructor")
                ctx.Response.Redirect("~/InstructorManageContent.aspx");
            else
                ctx.Response.Redirect("~/MemberDashboard.aspx");
        }


        /// Get a display name for the logged-in user 
        public static string GetDisplayName()
        {
            string name = GetUsername();
            if (!string.IsNullOrWhiteSpace(name)) return name;

            name = HttpContext.Current.Session["Name"]?.ToString();
            if (!string.IsNullOrWhiteSpace(name)) return name;

            return "Member";
        }


        /// Get the first letter of the user's display name 
        public static string GetInitial()
        {
            string name = GetDisplayName().Trim();
            return name.Length > 0 ? name.Substring(0, 1).ToUpperInvariant() : "M";
        }

        public static void ClearSession()
        {
            SignOut();
        }
    }

    public static class ValidationHelper
    {
        // Check if the email address format is valid
        public static bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        public static bool IsValidPhoneNumber(string phoneNumber)
        {
            phoneNumber = phoneNumber.Replace(" ", "").Replace("-", "");
            return System.Text.RegularExpressions.Regex.IsMatch(
                phoneNumber, @"^(\+?6?01[0-9]-?[0-9]{7,8}|0[0-9]-?[0-9]{7,8})$");
        }
    }
}
