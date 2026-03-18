<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyOtp.aspx.cs" Inherits="Aidcademy.VerifyOtp" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Verify OTP - Aidcademy</title>
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }

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

        body {
            font-family: 'Nunito', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #FFFBF1;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            justify-content: flex-start;
            align-items: center;
            padding: 80px 20px 20px; /* 60px navbar + 20px gap */
        }

        .logo-header {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            color: #111827;
            font-size: 28px;
            font-weight: bold;
            margin-bottom: 24px;
            font-family: 'Nunito', sans-serif;
        }

        .card {
            background: white;
            border-radius: 1rem;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
            padding: 48px 50px;
            width: 100%;
            max-width: 480px;
            text-align: center;
        }

        .card h2 {
            font-size: 24px;
            font-weight: bold;
            color: #111827;
            margin-bottom: 10px;
            font-family: 'Nunito', sans-serif;
        }

        .subtitle {
            color: #4b5563;
            font-size: 14px;
            line-height: 1.7;
            margin-bottom: 30px;
        }

        .otp-row {
            display: flex;
            justify-content: center;
            gap: 10px;
            margin-bottom: 28px;
        }

        .otp-digit {
            width: 52px;
            height: 60px;
            border: 1px solid #d1d5db;
            border-radius: 0.5rem;
            font-size: 26px;
            font-weight: 700;
            text-align: center;
            color: #111827;
            outline: none;
            transition: border-color 0.2s, box-shadow 0.2s;
            font-family: 'Nunito', sans-serif;
        }

        .otp-digit:focus {
            border-color: #ef4444;
            box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2);
        }

        .btn-primary {
            width: 100%;
            padding: 12px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white;
            border: none;
            border-radius: 0.5rem;
            font-size: 16px;
            font-weight: 600;
            font-family: 'Nunito', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 12px;
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            background: linear-gradient(to right, #b91c1c, #991b1b);
        }

        .btn-secondary {
            width: 100%;
            background: none;
            border: 1px solid #d1d5db;
            color: #374151;
            border-radius: 0.5rem;
            padding: 11px;
            font-size: 14px;
            font-weight: 500;
            font-family: 'Nunito', sans-serif;
            cursor: pointer;
            transition: all 0.2s;
            margin-bottom: 20px;
        }

        .btn-secondary:hover {
            border-color: #dc2626;
            color: #dc2626;
            background: #fff5f5;
        }

        .message {
            display: block;
            padding: 14px 16px;
            border-radius: 0.5rem;
            margin-top: 16px;
            margin-bottom: 16px;
            font-size: 14px;
            text-align: left;
            word-wrap: break-word;
            overflow-wrap: break-word;
            line-height: 1.5;
        }

        .message.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }

        .message.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }

        .back-link {
            font-size: 13px;
            color: #6b7280;
        }

        .back-link a {
            color: #dc2626;
            text-decoration: none;
            font-weight: 500;
        }

        .back-link a:hover { color: #b91c1c; }

        @media (max-width: 480px) {
            .card { padding: 35px 20px; }
            .otp-digit { width: 42px; height: 50px; font-size: 20px; }
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

        <div class="logo-header">
            <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#dc2626"
                stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
            </svg>
            Aidcademy
        </div>

        <div class="card">
            <h2>Verify Your Code</h2>

            <asp:Label ID="lblSubtitle" runat="server" CssClass="subtitle">
                    We've sent a <strong>6-digit verification code</strong> to your email address.
                    Enter it below. The code expires in <strong>10 minutes</strong>.
            </asp:Label>

            <!-- Message panel — appears after subtitle, before OTP inputs -->
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
            </asp:Panel>

            <!-- Six digit inputs -->
            <div class="otp-row" id="otpRow">
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d1" autocomplete="off" />
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d2" autocomplete="off" />
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d3" autocomplete="off" />
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d4" autocomplete="off" />
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d5" autocomplete="off" />
                <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d6" autocomplete="off" />
            </div>

            <!-- Hidden field passed to server -->
            <asp:HiddenField ID="txtOtp" runat="server" />

            <div id="countdownTimer" style="font-size: 16px; font-weight: bold; color: #dc2626; margin-bottom: 20px; font-family: 'Nunito', sans-serif;">
                Code expires in: <span id="timeDisplay">10:00</span>
            </div>

            <asp:Button ID="btnVerify" runat="server" Text="Verify Code" CssClass="btn-primary"
                OnClick="btnVerify_Click" OnClientClick="return aggregateOtp();" />

            <asp:Button ID="btnResend" runat="server" Text="Resend OTP" CssClass="btn-secondary"
                OnClick="btnResend_Click" CausesValidation="false" />

            <div class="back-link">
                <a href="Login_signup.aspx">&larr; Back to Login</a>
            </div>
        </div>
    </form>

    <script type="text/javascript">
        var digits = document.querySelectorAll('.otp-digit');

        digits.forEach(function (input, index) {
            input.addEventListener('keyup', function (e) {
                if (this.value.length === 1 && index < digits.length - 1)
                    digits[index + 1].focus();
                if (e.key === 'Backspace' && index > 0)
                    digits[index - 1].focus();
            });
            input.addEventListener('input', function () {
                this.value = this.value.replace(/[^0-9]/g, '');
            });
        });

        // Paste support — spread digits across boxes
        digits[0].addEventListener('paste', function (e) {
            e.preventDefault();
            var pasted = (e.clipboardData || window.clipboardData).getData('text').replace(/\D/g, '');
            for (var i = 0; i < digits.length && i < pasted.length; i++)
                digits[i].value = pasted[i];
            if (pasted.length >= digits.length)
                digits[digits.length - 1].focus();
        });

        // Collect all 6 digits into the hidden field before postback
        function aggregateOtp() {
            var code = '';
            digits.forEach(function (d) { code += d.value; });
            document.getElementById('<%= txtOtp.ClientID %>').value = code;
            return true;
        }

        // Countdown Timer
        var timeLeft = 600; // 10 minutes
        var timerDisplay = document.getElementById("timeDisplay");
        var resendBtn = document.getElementById('<%= btnResend.ClientID %>');
        var verifyBtn = document.getElementById('<%= btnVerify.ClientID %>');

        function updateTimer() {
            var minutes = Math.floor(timeLeft / 60);
            var seconds = timeLeft % 60;
            if (seconds < 10) seconds = "0" + seconds;
            timerDisplay.innerText = minutes + ":" + seconds;

            if (timeLeft <= 0) {
                clearInterval(timerInterval);
                timerDisplay.innerText = "0:00";
                resendBtn.disabled = false;
                resendBtn.style.opacity = "1";
                verifyBtn.disabled = true;
                verifyBtn.style.opacity = "0.5";
            } else {
                timeLeft--;
            }
        }

        resendBtn.disabled = true;
        resendBtn.style.opacity = "0.5";
        var timerInterval = setInterval(updateTimer, 1000);
    </script>
</body>

</html>
