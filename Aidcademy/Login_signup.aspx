<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Login_signup.aspx.cs" Inherits="Aidcademy.Login_signup" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <title>Login &amp; Signup - Aidcademy</title>
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
        .container {
            background: white;
            border-radius: 1rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            overflow: hidden;
            width: 100%;
            max-width: 900px;
            display: flex;
            min-height: 600px;
        }

        .form-container { flex: 1; padding: 40px 50px; display: none; }
        .form-container.active { display: block; }

        .logo { text-align: center; margin-bottom: 30px; }
        .logo h1 { color: #111827; font-size: 24px; font-weight: 700; margin-bottom: 8px; font-family: 'Nunito', sans-serif; }
        .logo p { color: #4b5563; font-size: 16px; margin-bottom: 24px; }

        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; color: #374151; font-weight: 500; font-size: 14px; }
        .form-group input { width: 100%; padding: 12px 16px; border: 1px solid #d1d5db; border-radius: 0.5rem; font-size: 14px; transition: all 0.2s; font-family: 'Nunito', sans-serif; }
        .form-group input:focus { outline: none; border-color: #ef4444; box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2); }

        .btn-primary {
            width: 100%; padding: 12px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white; border: none; border-radius: 0.5rem;
            font-size: 16px; font-weight: 600; font-family: 'Nunito', sans-serif;
            cursor: pointer; transition: all 0.2s; margin-top: 10px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }
        .btn-primary:hover { transform: translateY(-2px); background: linear-gradient(to right, #b91c1c, #991b1b); box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04); }

        .switch-form { text-align: center; margin-top: 24px; color: #4b5563; font-size: 14px; }
        .switch-form a { color: #dc2626; text-decoration: none; font-weight: 500; cursor: pointer; }
        .switch-form a:hover { color: #b91c1c; }

        .message { padding: 12px 16px; border-radius: 8px; margin-bottom: 20px; font-size: 14px; word-wrap: break-word; overflow-wrap: break-word; line-height: 1.5; }
        .message.success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .message.error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        .password-requirements { font-size: 12px; color: #6b7280; margin-top: 5px; line-height: 1.5; }

        .forgot-password { text-align: right; margin-top: 10px; margin-bottom: 10px; }
        .forgot-password a { color: #dc2626; text-decoration: none; font-size: 14px; font-weight: 500; }
        .forgot-password a:hover { color: #b91c1c; }

        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; }

        @media (max-width: 768px) {
            .container { max-width: 500px; }
            .form-container { padding: 40px 30px; }
            .form-row { grid-template-columns: 1fr; gap: 0; }
            .logo h1 { font-size: 28px; }
        }

        .tabs {
            display: flex; background-color: #f3f4f6; border-radius: 0.5rem;
            padding: 0.25rem; margin: 2rem 2rem 2rem;
        }
        .tab { flex: 1; text-align: center; padding: 0.5rem 1rem; cursor: pointer; color: #4b5563; font-weight: 500; font-family: 'Nunito', sans-serif; border-radius: 0.375rem; transition: all 0.2s; }
        .tab.active { background-color: white; color: #dc2626; box-shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05); }
        .tab:hover:not(.active) { color: #111827; }

        .btn-google {
            width: 100%; padding: 11px; background: #ffffff; color: #3c4043;
            border: 1px solid #dadce0; border-radius: 0.5rem; font-size: 15px; font-weight: 500;
            cursor: pointer; transition: all 0.2s; margin-top: 12px;
            display: flex; align-items: center; justify-content: center; gap: 10px; text-decoration: none;
        }
        .btn-google:hover { background: #f8f9fa; border-color: #c6c6c6; box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1); }

        .divider { display: flex; align-items: center; margin: 18px 0; color: #9ca3af; font-size: 13px; }
        .divider::before, .divider::after { content: ''; flex: 1; height: 1px; background: #e5e7eb; }
        .divider span { padding: 0 12px; }
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
        <div class="logo" style="margin-top: 10px; margin-bottom: 20px;">
            <h1 style="display: flex; align-items: center; justify-content: center; gap: 10px; color: #111827; font-size: 28px; font-weight: bold; font-family: 'Nunito', sans-serif;">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="none"
                    stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
                    style="fill: #dc2626;">
                    <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
                </svg>
                Aidcademy
            </h1>
        </div>
        <div class="container">
            <div style="flex: 1;">
                <div class="tabs">
                    <div class="tab active" id="tabLogin" onclick="showLogin()">Login</div>
                    <div class="tab" id="tabSignup" onclick="showSignup()">Sign Up</div>
                </div>

                <!-- Message Panel -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <div style="padding: 0 50px;">
                        <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                    </div>
                </asp:Panel>

                <!-- Login Form -->
                <div id="loginForm" class="form-container active">
                    <div style="margin-bottom: 24px;">
                        <h2 style="font-size: 24px; font-weight: bold; color: #111827; font-family: 'Nunito', sans-serif;">Welcome back!</h2>
                        <p style="color: #4b5563; margin-top: 8px;">Please enter your credentials to access your account</p>
                    </div>

                    <div class="form-group">
                        <label>Email or Username</label>
                        <asp:TextBox ID="txtLoginEmail" runat="server" placeholder="Please enter your email or username" />
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <asp:TextBox ID="txtLoginPassword" runat="server" TextMode="Password" placeholder="Please enter your password" />
                    </div>

                    <div class="forgot-password" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; font-size: 14px;">
                        <label style="display: flex; align-items: center; gap: 8px; font-weight: normal; color: #4b5563; margin-bottom: 0;">
                            <input type="checkbox" style="width: auto; margin: 0; accent-color: #dc2626;" />
                            Remember me
                        </label>
                        <a href="ForgotPassword.aspx">Forgot password?</a>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn-primary" OnClick="btnLogin_Click" />

                    <div class="divider"><span>or continue with</span></div>

                    <a href="GoogleCallback.aspx?action=login" class="btn-google">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 48 48">
                            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" />
                            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" />
                            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" />
                            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" />
                            <path fill="none" d="M0 0h48v48H0z" />
                        </svg>
                        Sign in with Google
                    </a>
                </div>

                <!-- Signup Form -->
                <div id="signupForm" class="form-container">
                    <div style="margin-bottom: 24px;">
                        <h2 style="font-size: 24px; font-weight: bold; color: #111827; font-family: 'Nunito', sans-serif;">Create your account</h2>
                        <p style="color: #4b5563; margin-top: 8px;">Start your journey to becoming a first aid expert</p>
                    </div>

                    <div class="form-group">
                        <label>Full Name</label>
                        <asp:TextBox ID="txtSignupFullName" runat="server" placeholder="Your full name" />
                    </div>

                    <div class="form-group">
                        <label>Username</label>
                        <asp:TextBox ID="txtSignupUsername" runat="server" placeholder="Choose a username" />
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <asp:TextBox ID="txtSignupEmail" runat="server" TextMode="Email" placeholder="your.email@example.com" />
                    </div>

                    <div class="form-group">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtSignupPhone" runat="server" placeholder="Your phone number (optional)" />
                    </div>

                    <div class="form-group">
                        <label>Password</label>
                        <asp:TextBox ID="txtSignupPassword" runat="server" TextMode="Password" placeholder="Create a strong password" />
                        <div class="password-requirements">Password must be at least 8 characters with uppercase, lowercase, and numbers.</div>
                    </div>

                    <div class="form-group">
                        <label>Confirm Password</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" placeholder="Please Re-enter your password" />
                    </div>

                    <asp:Button ID="btnSignup" runat="server" Text="Create Account" CssClass="btn-primary" OnClick="btnSignup_Click" />

                    <div class="divider"><span>or sign up with</span></div>

                    <a href="GoogleCallback.aspx?action=signup" class="btn-google">
                        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 48 48">
                            <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z" />
                            <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z" />
                            <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z" />
                            <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z" />
                            <path fill="none" d="M0 0h48v48H0z" />
                        </svg>
                        Sign up with Google
                    </a>

                    <div class="switch-form" style="margin-top: 24px;">
                        Already have an account? <a onclick="showLogin()">Login</a>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        function showLogin() {
            document.getElementById('loginForm').classList.add('active');
            document.getElementById('signupForm').classList.remove('active');
            document.getElementById('tabLogin').classList.add('active');
            document.getElementById('tabSignup').classList.remove('active');
        }

        function showSignup() {
            document.getElementById('signupForm').classList.add('active');
            document.getElementById('loginForm').classList.remove('active');
            document.getElementById('tabSignup').classList.add('active');
            document.getElementById('tabLogin').classList.remove('active');
        }
    </script>
</body>

</html>
