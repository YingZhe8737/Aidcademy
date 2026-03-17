<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AccountModification.aspx.cs" Inherits="Aidcademy.WebForm2" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">Create Account — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        /* ── Centered form wrapper ── */
        .form-center-wrap {
            display: flex;
            justify-content: center;
            align-items: flex-start;
            padding-top: 8px;
        }

        .form-card {
            background: white;
            border-radius: 20px;
            border: 1px solid #ebebeb;
            padding: 40px 44px;
            width: 100%;
            max-width: 540px;
            box-shadow: 0 4px 28px rgba(0,0,0,0.05);
        }

        .form-card-icon {
            width: 60px; height: 60px; border-radius: 16px;
            background: #fde8e9; color: #c9242b;
            display: flex; align-items: center; justify-content: center;
            font-size: 1.6rem; margin-bottom: 18px;
        }

        .form-card h3 { font-size: 1.3rem; font-weight: 900; color: #1a1a2e; margin-bottom: 4px; }
        .form-card .subtitle { font-size: 0.88rem; color: #aaa; font-weight: 600; margin-bottom: 28px; }

        .form-group { margin-bottom: 18px; }
        .form-group label {
            display: block; font-size: 0.78rem; font-weight: 800; color: #888;
            text-transform: uppercase; letter-spacing: 0.5px; margin-bottom: 6px;
        }
        .form-input {
            width: 100%; padding: 11px 14px; border-radius: 10px;
            border: 1.5px solid #e0e0e0; font-family: 'Nunito', sans-serif;
            font-size: 0.9rem; font-weight: 600; color: #333;
            transition: border-color 0.18s; outline: none; box-sizing: border-box;
        }
        .form-input:focus { border-color: #c9242b; }
        select.form-input { background: white; }

        .form-divider { height: 1px; background: #f0f0f0; margin: 24px 0; }

        .btn-create-acc {
            width: 100%; padding: 13px; background: #c9242b; border: none; color: white;
            font-family: 'Nunito', sans-serif; font-size: 1rem; font-weight: 800;
            border-radius: 12px; cursor: pointer; transition: background 0.18s, transform 0.18s;
            margin-top: 6px; display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .btn-create-acc:hover { background: #a01c22; transform: translateY(-1px); }

        .success-message {
            display: block; margin-top: 16px; padding: 12px 16px;
            background: #d1fae5; color: #065f46;
            border-radius: 10px; font-size: 0.88rem; font-weight: 700;
        }
        .error-message {
            display: block; margin-top: 16px; padding: 12px 16px;
            background: #fde8e9; color: #9f1239;
            border-radius: 10px; font-size: 0.88rem; font-weight: 700;
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-user-plus" style="color:#c9242b;margin-right:8px;"></i>Create Account</h2>
        <p>Provision a new Instructor, or Member account.</p>
    </div>

    <div class="form-center-wrap">
        <div class="form-card">
            <div class="form-card-icon"><i class="fa-solid fa-user-plus"></i></div>
            <h3>New Account</h3>
            <p class="subtitle">Fill in the details below to create a new platform account.</p>

            <div class="form-group">
                <label>Full Name</label>
                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input" placeholder="Enter full name" />
            </div>
            <div class="form-group">
                <label>Username</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" placeholder="Choose a username" />
            </div>
            <div class="form-group">
                <label>Email</label>
                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" TextMode="Email" placeholder="email@example.com" />
            </div>
            <div class="form-group">
                <label>Role</label>
                <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-input">
                    <asp:ListItem Text="Select Role" Value="" />
                    <asp:ListItem Text="Instructor"  Value="Instructor" />
                    <asp:ListItem Text="Member"      Value="Member" />
                </asp:DropDownList>
            </div>

            <div class="form-divider"></div>

            <div class="form-group">
                <label>Password</label>
                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input" TextMode="Password" placeholder="Create a strong password" />
            </div>
            <div class="form-group">
                <label>Confirm Password</label>
                <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-input" TextMode="Password" placeholder="Re-enter your password" />
            </div>

            <asp:Button ID="btnCreate" runat="server" CssClass="btn-create-acc" Text="Create Account" OnClick="btnCreate_Click">
            </asp:Button>
            <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    (function () {
        var msg = document.getElementById('<%= lblMessage.ClientID %>');
        if (msg && msg.innerText.trim() !== '') {
            setTimeout(function () {
                msg.style.transition = 'opacity 0.5s ease';
                msg.style.opacity = '0';
                setTimeout(function () { msg.style.display = 'none'; }, 500);
            }, 3000);
        }
    })();
</script>
</asp:Content>
