<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForgotPassword.aspx.cs" Inherits="Aidcademy.ForgotPassword" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Forgot Password - Aidcademy</title>
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
                justify-content: center;
                align-items: center;
                padding: 20px;
            }

            .container {
                background: white;
                border-radius: 20px;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                padding: 50px;
                width: 100%;
                max-width: 500px;
            }

            .logo {
                text-align: center;
                margin-bottom: 30px;
            }

            .logo h1 {
                color: #667eea;
                font-size: 32px;
                font-weight: bold;
                margin-bottom: 10px;
            }

            .logo p {
                color: #666;
                font-size: 14px;
                line-height: 1.6;
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
                font-size: 14px;
            }

            .form-group input {
                width: 100%;
                padding: 12px 15px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-size: 14px;
                transition: all 0.3s;
            }

            .form-group input:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }

            .btn-primary {
                width: 100%;
                padding: 14px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
                transition: transform 0.2s;
                margin-top: 10px;
            }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
            }

            .back-to-login {
                text-align: center;
                margin-top: 20px;
                color: #666;
                font-size: 14px;
            }

            .back-to-login a {
                color: #667eea;
                text-decoration: none;
                font-weight: 600;
            }

            .back-to-login a:hover {
                text-decoration: underline;
            }

            .message {
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
            }

            .message.success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .message.error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }

            .info-box {
                background-color: #e7f3ff;
                border-left: 4px solid #667eea;
                padding: 15px;
                border-radius: 8px;
                margin-bottom: 20px;
                font-size: 14px;
                color: #555;
                line-height: 1.6;
            }

            @media (max-width: 768px) {
                .container {
                    padding: 30px 20px;
                }

                .logo h1 {
                    font-size: 28px;
                }
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
            <div class="container">
                <div class="logo">
                    <h1>🚑 Aidcademy</h1>
                </div>

                <!-- Message Panel -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                </asp:Panel>

                <!-- Email Form Panel -->
                <asp:Panel ID="pnlEmailForm" runat="server">
                    <div class="logo" style="margin-bottom: 20px;">
                        <p style="font-size: 24px; color: #333; font-weight: 600; margin-bottom: 10px;">Forgot Password?
                        </p>
                        <p>No worries! Enter your email address and we'll send you a link to reset your password.</p>
                    </div>

                    <div class="form-group">
                        <label for="txtEmail">Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email"
                            placeholder="your.email@example.com" />
                    </div>

                    <asp:Button ID="btnSubmit" runat="server" Text="Send Reset Link" CssClass="btn-primary"
                        OnClick="btnSubmit_Click" />

                    <div class="back-to-login">
                        <a href="Login_signup.aspx">← Back to Login</a>
                    </div>
                </asp:Panel>

                <!-- Reset Password Form Panel -->
                <asp:Panel ID="pnlResetForm" runat="server" Visible="false">
                    <div class="logo" style="margin-bottom: 20px;">
                        <p style="font-size: 24px; color: #333; font-weight: 600; margin-bottom: 10px;">Reset Password
                        </p>
                        <p>Enter your new password below.</p>
                    </div>

                    <div class="info-box">
                        <strong>Password Requirements:</strong><br />
                        • At least 8 characters long<br />
                        • Contains uppercase and lowercase letters<br />
                        • Contains at least one number
                    </div>

                    <div class="form-group">
                        <label for="txtNewPassword">New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                            placeholder="Enter new password" />
                    </div>

                    <div class="form-group">
                        <label for="txtConfirmNewPassword">Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password"
                            placeholder="Re-enter new password" />
                    </div>

                    <asp:Button ID="btnReset" runat="server" Text="Reset Password" CssClass="btn-primary"
                        OnClick="btnReset_Click" />

                    <div class="back-to-login">
                        <a href="Login_signup.aspx">← Back to Login</a>
                    </div>
                </asp:Panel>
            </div>
        </form>
    </body>

    </html>