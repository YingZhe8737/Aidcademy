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
            background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
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
                box-shadow: 0 5px 20px rgba(220, 38, 38, 0.4);
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
                <img src="Image/logo2.jpeg" alt="Aidcademy Logo" style="height: 60px; border-radius: 8px; margin-bottom: 10px;" />
                <h1 style="color: #c9242b;">AIDCADEMY</h1>
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
                    placeholder="Enter new password" oninput="checkStrength()"></asp:TextBox>
                <div style="height: 4px; background: #e0e0e0; margin-top: 8px; border-radius: 2px;">
                    <div id="strengthBar" style="height: 100%; width: 0%; border-radius: 2px; transition: 0.3s;"></div>
                </div>
                <div id="strengthText" style="font-size: 12px; margin-top: 4px; font-weight: bold; text-align: right;"></div>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtNewPassword"
                    ErrorMessage="Required" CssClass="error" Display="Dynamic" ValidationGroup="ChangePassword" />
                <small style="color: #666; font-size: 12px; display: block; margin-top: 4px;">At least 8 characters with uppercase, lowercase, and
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
    <script>
        function checkStrength() {
            var pwd = document.getElementById('<%= txtNewPassword.ClientID %>').value;
            var strengthText = document.getElementById('strengthText');
            var strengthBar = document.getElementById('strengthBar');
            
            var strength = 0;
            if (pwd.length >= 8) strength += 1;
            if (pwd.match(/[a-z]+/)) strength += 1;
            if (pwd.match(/[A-Z]+/)) strength += 1;
            if (pwd.match(/[0-9]+/)) strength += 1;
            if (pwd.match(/[@$!%*?&]+/)) strength += 1;

            switch(strength) {
                case 0:
                case 1:
                case 2:
                    strengthBar.style.width = '33%';
                    strengthBar.style.backgroundColor = '#e74c3c';
                    strengthText.innerText = 'Weak';
                    strengthText.style.color = '#e74c3c';
                    break;
                case 3:
                case 4:
                    strengthBar.style.width = '66%';
                    strengthBar.style.backgroundColor = '#f1c40f';
                    strengthText.innerText = 'Fair';
                    strengthText.style.color = '#f1c40f';
                    break;
                case 5:
                    strengthBar.style.width = '100%';
                    strengthBar.style.backgroundColor = '#28a745';
                    strengthText.innerText = 'Strong';
                    strengthText.style.color = '#28a745';
                    break;
            }
            
            if (pwd.length === 0) {
                strengthBar.style.width = '0%';
                strengthText.innerText = '';
            }
        }
    </script>
</body>

</html>
