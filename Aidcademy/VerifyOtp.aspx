<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="VerifyOtp.aspx.cs" Inherits="Aidcademy.VerifyOtp" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Verify OTP - Aidcademy</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(to bottom right, #fef2f2 0%, #ffffff 50%, #eff6ff 100%);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
                justify-content: center;
                align-items: center;
                padding: 20px;
            }

            /* Logo header — same as login page */
            .logo-header {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                color: #111827;
                font-size: 28px;
                font-weight: bold;
                margin-bottom: 24px;
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
            }

            .subtitle {
                color: #4b5563;
                font-size: 14px;
                line-height: 1.7;
                margin-bottom: 30px;
            }

            /* OTP digit boxes */
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
            }

            .otp-digit:focus {
                border-color: #ef4444;
                box-shadow: 0 0 0 2px rgba(239, 68, 68, 0.2);
            }

            /* Buttons */
            .btn-primary {
                width: 100%;
                padding: 12px;
                background: linear-gradient(to right, #dc2626, #b91c1c);
                color: white;
                border: none;
                border-radius: 0.5rem;
                font-size: 16px;
                font-weight: 600;
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

            .back-link a:hover {
                color: #b91c1c;
            }

            @media (max-width: 480px) {
                .card {
                    padding: 35px 20px;
                }

                .otp-digit {
                    width: 42px;
                    height: 50px;
                    font-size: 20px;
                }
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">

            <!-- Logo — identical to Login page -->
            <div class="logo-header">
                <svg xmlns="http://www.w3.org/2000/svg" width="32" height="32" viewBox="0 0 24 24" fill="#dc2626"
                    stroke="#dc2626" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path
                        d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7Z" />
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
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d1"
                        autocomplete="off" />
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d2"
                        autocomplete="off" />
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d3"
                        autocomplete="off" />
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d4"
                        autocomplete="off" />
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d5"
                        autocomplete="off" />
                    <input class="otp-digit" maxlength="1" type="text" inputmode="numeric" pattern="[0-9]" id="d6"
                        autocomplete="off" />
                </div>

                <!-- Hidden field passed to server -->
                <asp:HiddenField ID="txtOtp" runat="server" />

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
        </script>
    </body>

    </html>