<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ChangePassword.aspx.cs" Inherits="Aidcademy.ChangePassword" %>

<!DOCTYPE html>
<html>

<head runat="server">
    <title>Change Password - Aidcademy</title>
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #FFFBF1;
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
            max-width: 500px;
            width: 100%;
        }

        .logo {
            text-align: center;
            margin-bottom: 30px;
        }

            .logo h1 {
                color: #667eea;
                font-size: 32px;
                font-weight: bold;
            }

        h2 {
            text-align: center;
            color: #333;
            margin-bottom: 10px;
        }

        .description {
            text-align: center;
            color: #666;
            margin-bottom: 30px;
        }

        .form-group {
            margin-bottom: 20px;
        }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
            }

            .form-group input {
                width: 100%;
                padding: 12px 15px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-size: 14px;
            }

                .form-group input:focus {
                    outline: none;
                    border-color: #667eea;
                }

            .form-group .error {
                color: #e74c3c;
                font-size: 12px;
                margin-top: 5px;
            }

        .btn {
            width: 100%;
            padding: 14px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-bottom: 15px;
        }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 20px rgba(102, 126, 234, 0.4);
            }

        .message {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            text-align: center;
        }

            .message.success {
                background: #d4edda;
                color: #155724;
            }

            .message.error {
                background: #f8d7da;
                color: #721c24;
            }

        .back-link {
            text-align: center;
            margin-top: 20px;
        }

            .back-link a {
                color: #667eea;
                text-decoration: none;
            }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="container">
            <div class="logo">
                <h1>🏥 AIDCADEMY</h1>
            </div>

            <h2>Change Password</h2>
            <p class="description">Update your account password</p>

            <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="message">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </asp:Panel>

            <div class="form-group">
                <label>Current Password *</label>
                <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password"
                    placeholder="Enter current password"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtCurrentPassword"
                    ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="ChangePassword" />
            </div>

            <div class="form-group">
                <label>New Password *</label>
                <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password"
                    placeholder="Enter new password"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                    ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="ChangePassword" />
                <small style="color: #666; font-size: 12px;">At least 8 characters with uppercase, lowercase, and
                        numbers</small>
            </div>

            <div class="form-group">
                <label>Confirm New Password *</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password"
                    placeholder="Confirm new password"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtConfirmPassword"
                    ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="ChangePassword" />
                <asp:CompareValidator runat="server" ControlToValidate="txtConfirmPassword"
                    ControlToCompare="txtNewPassword" ErrorMessage="Passwords do not match" CssClass="error"
                    Display="Dynamic" ValidationGroup="ChangePassword" />
            </div>

            <asp:Button ID="btnChangePassword" runat="server" Text="Change Password" CssClass="btn"
                OnClick="btnChangePassword_Click" ValidationGroup="ChangePassword" />

            <div class="back-link">
                <asp:HyperLink runat="server" NavigateUrl="~/MemberProfile.aspx">← Back to Profile</asp:HyperLink>
            </div>
        </div>
    </form>
</body>

</html>
