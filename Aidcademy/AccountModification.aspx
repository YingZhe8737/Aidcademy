<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccountModification.aspx.cs" Inherits="Aidcademy.WebForm2" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="~/Styles/CustomAdmin.css" />

</head>
<body>
    <form id="form1" runat="server">
        <div class="signup-container">
            <div class="signup-card">

                <h1>Create New account</h1>
                <p class="subtitle">Create account for another new admin or new instructor</p>

                <div class="form-group">
                    <label>Full Name</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input" 
                        placeholder="Your full name"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" 
                        placeholder="Choose a username"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Email</label>
                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" 
                        TextMode="Email" placeholder="your.email@example.com"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Role</label>
                    <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-input">
                        <asp:ListItem Text="Select Role" Value="" />
                        <asp:ListItem Text="Admin" Value="Admin" />
                        <asp:ListItem Text="Instructor" Value="Instructor" />
                        <asp:ListItem Text="Member" Value="Member" />
                    </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input"
                        TextMode="Password" placeholder="Create a strong password"></asp:TextBox>
                </div>

                <div class="form-group">
                    <label>Confirm Password</label>
                    <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-input"
                        TextMode="Password" placeholder="Please Re-enter your password"></asp:TextBox>
                </div>

                <asp:Button ID="btnCreate" runat="server" Text="Create Account"
                    CssClass="btn-create" OnClick="btnCreate_Click" />
                <asp:Label ID="lblMessage" runat="server" CssClass="form-input" EnableViewState="false"></asp:Label>

                <script>
                    window.onload = function () {
                        var msg = document.getElementById('<%= lblMessage.ClientID %>');
                        if (msg && msg.innerText.trim() !== '') {
                            setTimeout(function () {
                                msg.style.transition = 'opacity 0.5s ease';
                                msg.style.opacity = '0';
                                setTimeout(function () { msg.style.display = 'none'; }, 500);
                            }, 3000);
                        }
                    };
                </script>

            </div>
        </div>
    </form>
</body>
</html>
