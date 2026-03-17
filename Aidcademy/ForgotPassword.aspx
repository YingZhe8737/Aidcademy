<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="Aidcademy.ForgotPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Forgot Password - Aidcademy</title>
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Nunito', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #FFFBF1;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding: 80px 20px 20px; /* 60px navbar + 20px gap */
        }

        /* ══ TOP NAVBAR — exact MainPage.aspx ══ */
        .top-navbar {
            position: fixed; top: 0; left: 0; right: 0; height: 60px;
            background: #c9242b; display: flex; align-items: center;
            justify-content: space-between; padding: 0 24px;
            z-index: 200; box-shadow: 0 2px 16px rgba(201,36,43,0.35);
        }
        .navbar-brand-custom { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .navbar-brand-custom img { height: 38px; width: 38px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.45); }
        .navbar-brand-custom span { font-size: 1.25rem; font-weight: 900; color: white; letter-spacing: 1px; font-family: 'Nunito', sans-serif; }
        .nav-right { display: flex; align-items: center; gap: 6px; }
        .nav-top-btn {
            display: inline-flex; align-items: center; gap: 7px; background: transparent; border: none;
            color: rgba(255,255,255,0.85); font-family: 'Nunito', sans-serif; font-size: 0.88rem; font-weight: 700;
            padding: 7px 14px; border-radius: 8px; cursor: pointer; transition: background 0.18s, color 0.18s; text-decoration: none;
        }
        .nav-top-btn:hover { background: rgba(255,255,255,0.18); color: white; }
        .nav-top-btn.outline-btn { border: 2px solid rgba(255,255,255,0.55); border-radius: 22px; padding: 6px 18px; }
        .nav-top-btn.outline-btn:hover { background: white; color: #c9242b; }

        /* ══ Original page styles — UNCHANGED ══ */
        .container { background: white; border-radius: 20px; box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3); padding: 50px; width: 100%; max-width: 500px; }

        .logo { text-align: center; margin-bottom: 30px; }
        .logo h1 { color: #111827; font-size: 28px; font-weight: bold; margin-bottom: 10px; display: flex; align-items: center; justify-content: center; gap: 10px; font-family: 'Nunito', sans-serif; }
        .logo p { color: #666; font-size: 14px; line-height: 1.6; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #333; font-weight: 500; font-size: 14px; }
        .form-group input { width: 100%; padding: 12px 15px; border: 2px solid #e0e0e0; border-radius: 8px; font-size: 14px; transition: all 0.3s; font-family: 'Nunito', sans-serif; }
        .form-group input:focus { outline: none; border-color: #ef4444; box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2); }

        .btn-primary {
            width: 100%; padding: 12px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white; border: none; border-radius: 0.5rem;
            font-size: 16px; font-weight: 600; font-family: 'Nunito', sans-serif;
            cursor: pointer; transition: all 0.2s; margin-top: 10px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
        }
        .btn-primary:hover { transform: translateY(-2px); background: linear-gradient(to right, #b91c1c, #991b1b); box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1); }

        .back-to-login { text-align: center; margin-top: 20px; color: #666; font-size: 14px; }
        .back-to-login a { color: #dc2626; text-decoration: none; font-weight: 600; }
        .back-to-login a:hover { color: #b91c1c; }

        .message { padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; font-family: 'Nunito', sans-serif; }
        .message.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        .info-box { background-color: #fff5f5; border-left: 4px solid #dc2626; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; color: #555; line-height: 1.6; font-family: 'Nunito', sans-serif; }

        @media (max-width: 768px) {
            .container { padding: 30px 20px; }
            .logo h1 { font-size: 28px; }
        }
    </style>
</head>

<body>
    <!-- TOP NAVBAR — exact MainPage.aspx guest navbar -->
    <nav class="top-navbar">
        <a href="MainPage.aspx" class="navbar-brand-custom">
            <img src="image/aidcademylogo.png" alt="Aidcademy" />
            <span>AIDCADEMY</span>
        </a>
        <div class="nav-right">
            <a href="About.aspx" class="nav-top-btn">
                <i class="fa-solid fa-circle-info"></i> About
            </a>
            <a href="LearningCourse.aspx" class="nav-top-btn">
                <i class="fa-solid fa-book-open"></i> Courses
            </a>
            <a href="Login_Signup.aspx" class="nav-top-btn outline-btn">
                <i class="fa-solid fa-right-to-bracket"></i> Login
            </a>
        </div>
    </nav>

    <form id="form1" runat="server">
        <div class="container">
            <div class="logo">
                <h1>
                    <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24"
                        fill="#dc2626" stroke="#dc2626" stroke-width="2" stroke-linecap="round"
                        stroke-linejoin="round">
                        <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
                    </svg>
                    Aidcademy
                </h1>
            </div>

            <!-- Message Panel -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            </asp:Panel>

            <!-- Email Form Panel -->
            <asp:Panel ID="pnlEmailForm" runat="server">
                <div class="logo" style="margin-bottom: 20px;">
                    <p style="font-size: 24px; color: #333; font-weight: 600; margin-bottom: 10px; font-family: 'Nunito', sans-serif;">
                        Forgot Password?
                    </p>
                    <p>No worries! Please enter your email address and we'll send you a link to reset your password.</p>
                </div>

                <div class="form-group">
                    <label for="txtEmail">Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" placeholder="your.email@example.com" />
                </div>

                <asp:Button ID="btnSubmit" runat="server" Text="Send Reset Link" CssClass="btn-primary" OnClick="btnSubmit_Click" />

                <div class="back-to-login">
                    <a href="Login_signup.aspx">&larr; Back to Login</a>
                </div>
            </asp:Panel>

            <!-- Reset Password Form Panel -->
            <asp:Panel ID="pnlResetForm" runat="server" Visible="false">
                <div class="logo" style="margin-bottom: 20px;">
                    <p style="font-size: 24px; color: #333; font-weight: 600; margin-bottom: 10px; font-family: 'Nunito', sans-serif;">
                        Reset Password
                    </p>
                    <p>Please enter your new password below.</p>
                </div>

                <div class="info-box">
                    <strong>Password Requirements:</strong><br />
                    &bull; At least 8 characters long<br />
                    &bull; Contains uppercase and lowercase letters<br />
                    &bull; Contains at least one number
                </div>

                <div class="form-group">
                    <label for="txtNewPassword">New Password</label>
                    <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                        ClientIDMode="Static" placeholder="Enter new password" />
                    <div style="height:10px; background:#e0e0e0; margin-top:10px; border-radius:6px; overflow:hidden;">
                        <div id="strengthBar" style="height:100%; width:0%; border-radius:6px; transition:width 0.4s ease, background-color 0.4s ease;"></div>
                    </div>
                    <div id="strengthText" style="font-size:13px; margin-top:6px; font-weight:700; text-align:right; letter-spacing:0.5px;"></div>
                </div>

                <div class="form-group">
                    <label for="txtConfirmNewPassword">Confirm New Password</label>
                    <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" placeholder="Re-enter new password" />
                </div>

                <asp:Button ID="btnReset" runat="server" Text="Reset Password" CssClass="btn-primary" OnClick="btnReset_Click" />

                <div class="back-to-login">
                    <a href="Login_signup.aspx">&larr; Back to Login</a>
                </div>
            </asp:Panel>
        </div>
    </form>

    <script>
        function checkStrength() {
            var input = document.getElementById('txtNewPassword');
            if (!input) return;
            var pwd = input.value;
            var strengthText = document.getElementById('strengthText');
            var strengthBar = document.getElementById('strengthBar');

            if (pwd.length === 0) { strengthBar.style.width = '0%'; strengthText.innerHTML = ''; return; }
            var score = 0;
            if (pwd.length >= 8) score++;
            if (pwd.match(/[a-z]/)) score++;
            if (pwd.match(/[A-Z]/)) score++;
            if (pwd.match(/[0-9]/)) score++;
            if (pwd.match(/[@$!%*?&##+]/)) score++;

            if (score <= 2) {
                strengthBar.style.width = '33%'; strengthBar.style.backgroundColor = '#e74c3c';
                strengthText.innerHTML = '<span style="color:#e74c3c;">&#9679; Weak</span>';
            } else if (score <= 4) {
                strengthBar.style.width = '66%'; strengthBar.style.backgroundColor = '#f39c12';
                strengthText.innerHTML = '<span style="color:#f39c12;">&#9679; Fair</span>';
            } else {
                strengthBar.style.width = '100%'; strengthBar.style.backgroundColor = '#27ae60';
                strengthText.innerHTML = '<span style="color:#27ae60;">&#9679; Strong</span>';
            }
        }
        window.addEventListener('load', function () {
            var input = document.getElementById('txtNewPassword');
            if (input) input.addEventListener('input', checkStrength);
        });
    </script>
</body>

</html>
