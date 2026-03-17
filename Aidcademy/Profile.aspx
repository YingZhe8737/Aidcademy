<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Profile.aspx.cs" Inherits="Aidcademy.MemberProfile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Profile - Aidcademy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <style>
        :root { --red:#c9242b; --red-dark:#a01c22; --red-light:#fde8e9; --cream:#FFFBF1; --dark:#1a1a2e; }
        * { box-sizing:border-box; margin:0; padding:0; }
        html,body { font-family:'Nunito',sans-serif; background:var(--cream); overflow-x:hidden; }

        .top-navbar { background:var(--red); padding:0 24px; height:60px; position:sticky; top:0; z-index:1000; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 16px rgba(201,36,43,0.35); }
        .navbar-brand-custom { display:flex; align-items:center; gap:10px; text-decoration:none; }
        .navbar-brand-custom img { height:38px; width:38px; border-radius:50%; object-fit:cover; border:2px solid rgba(255,255,255,0.45); }
        .navbar-brand-custom span { font-size:1.25rem; font-weight:900; color:white; letter-spacing:1px; }
        .nav-right { display:flex; align-items:center; gap:6px; }
        .nav-top-btn { display:inline-flex; align-items:center; gap:7px; background:transparent; border:none; color:rgba(255,255,255,0.85); font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:700; padding:7px 14px; border-radius:8px; cursor:pointer; transition:all 0.18s; text-decoration:none; }
        .nav-top-btn:hover { background:rgba(255,255,255,0.18); color:white; }
        .nav-top-btn.outline-btn { border:2px solid rgba(255,255,255,0.55); border-radius:22px; padding:6px 18px; }
        .nav-top-btn.outline-btn:hover { background:white; color:var(--red); }

        .page-wrap { max-width:760px; margin:40px auto; padding:0 20px 60px; }
        .back-link { display:inline-flex; align-items:center; gap:7px; color:#888; font-size:0.85rem; font-weight:700; text-decoration:none; margin-bottom:24px; transition:color 0.18s; }
        .back-link:hover { color:var(--red); }

        .profile-card { background:white; border-radius:20px; border:1px solid #ebebeb; overflow:hidden; box-shadow:0 4px 24px rgba(0,0,0,0.04); }
        .profile-header-section { background:linear-gradient(135deg,var(--red-dark),var(--red)); padding:36px 40px; text-align:center; color:white; position:relative; }
        .profile-image { width:100px; height:100px; border-radius:50%; object-fit:cover; border:4px solid rgba(255,255,255,0.6); display:block; margin:0 auto 16px; }
        .profile-header-section h2 { font-size:1.5rem; font-weight:900; margin-bottom:4px; }
        .profile-header-section p  { font-size:0.9rem; opacity:0.85; margin:0; }

        /* View-only banner */
        .view-only-banner { background:#fef3c7; border-left:4px solid #f59e0b; padding:12px 20px; display:flex; align-items:center; gap:10px; font-size:0.88rem; font-weight:700; color:#92400e; }

        .profile-content { padding:32px 40px; }
        @media(max-width:600px){ .profile-content{ padding:24px 20px; } }

        .message { display:block; padding:12px 16px; border-radius:10px; font-size:0.88rem; font-weight:700; margin-bottom:20px; }
        .success { background:#d1fae5; color:#065f46; }
        .error   { background:#fde8e9; color:#9f1239; }

        .section-title { font-size:0.75rem; font-weight:800; color:var(--red); text-transform:uppercase; letter-spacing:1.5px; margin:28px 0 14px; padding-bottom:8px; border-bottom:2px solid var(--red-light); }
        .section-title:first-of-type { margin-top:0; }

        .form-row { display:grid; grid-template-columns:1fr 1fr; gap:16px; }
        @media(max-width:580px){ .form-row{grid-template-columns:1fr;} }

        .form-group { margin-bottom:16px; }
        .form-group label { display:block; font-size:0.78rem; font-weight:800; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:6px; }
        .form-group input,
        .form-group textarea { width:100%; padding:10px 14px; border-radius:10px; border:1.5px solid #e0e0e0; font-family:'Nunito',sans-serif; font-size:0.9rem; font-weight:600; color:#333; transition:border-color 0.18s; outline:none; box-sizing:border-box; }
        .form-group input:focus,
        .form-group textarea:focus { border-color:var(--red); }
        .form-group input:disabled,
        .form-group textarea:disabled { background:#f9f9f9; color:#888; cursor:default; border-color:#f0f0f0; }
        .form-group small { font-size:0.75rem; color:#bbb; margin-top:4px; display:block; }
        textarea { resize:vertical; min-height:100px; }

        .photo-row { display:flex; align-items:center; gap:20px; flex-wrap:wrap; margin-bottom:16px; }
        .photo-preview { width:70px; height:70px; border-radius:50%; object-fit:cover; border:3px solid var(--red); flex-shrink:0; }

        /* Read-only info display (for viewing other profiles) */
        .info-row { display:flex; align-items:flex-start; gap:12px; padding:12px 0; border-bottom:1px solid #f5f5f5; }
        .info-row:last-child { border-bottom:none; }
        .info-icon { width:36px; height:36px; border-radius:9px; background:var(--red-light); color:var(--red); display:flex; align-items:center; justify-content:center; font-size:0.9rem; flex-shrink:0; margin-top:2px; }
        .info-label { font-size:0.75rem; font-weight:800; color:#bbb; text-transform:uppercase; letter-spacing:0.5px; }
        .info-value { font-size:0.95rem; font-weight:700; color:#333; margin-top:2px; }

        .btn-save { display:inline-flex; align-items:center; gap:8px; background:var(--red); border:none; color:white; font-family:'Nunito',sans-serif; font-size:1rem; font-weight:800; padding:13px 32px; border-radius:12px; cursor:pointer; transition:all 0.18s; margin-top:10px; }
        .btn-save:hover { background:var(--red-dark); transform:translateY(-1px); }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <nav class="top-navbar">
        <a href="MainPage.aspx" class="navbar-brand-custom">
            <asp:Image ID="imgNavLogo" runat="server" ImageUrl="~/image/aidcademylogo.png" AlternateText="Aidcademy" style="height:38px;width:38px;border-radius:50%;object-fit:cover;border:2px solid rgba(255,255,255,0.45);" />
            <span>AIDCADEMY</span>
        </a>
        <div class="nav-right">
            <%
                string role    = Session["Role"] != null ? Session["Role"].ToString() : "";
                string dashUrl = role == "Instructor" ? "InstructorManageContent.aspx"
                               : role == "Admin"      ? "AdminDashboard.aspx"
                               :                       "MemberDashboard.aspx";
            %>
            <a href="<%= dashUrl %>" class="nav-top-btn">
                <i class="fa-solid fa-chart-line"></i> Dashboard
            </a>
            <asp:LinkButton ID="btnLogout" runat="server" CssClass="nav-top-btn outline-btn" OnClick="btnLogout_Click" CausesValidation="false">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </asp:LinkButton>
        </div>
    </nav>

    <div class="page-wrap">
        <a href="<%= dashUrl %>" class="back-link">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>

        <div class="profile-card">
            <div class="profile-header-section">
                <asp:Image ID="imgProfile" runat="server" CssClass="profile-image" ImageUrl="~/images/default-avatar.png" AlternateText="Profile" />
                <h2><asp:Label ID="lblProfileName" runat="server" Text="Profile"></asp:Label></h2>
                <p><asp:Label ID="lblProfileRole" runat="server" Text=""></asp:Label></p>
            </div>

            <%-- View-only banner (hidden for own profile) --%>
            <asp:Panel ID="pnlViewOnlyBanner" runat="server" Visible="false">
                <div class="view-only-banner">
                    <i class="fa-solid fa-eye"></i>
                    You are viewing this profile in read-only mode.
                </div>
            </asp:Panel>

            <div class="profile-content">

                <!-- Message -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                </asp:Panel>

                <%-- ══ READ-ONLY VIEW (viewing another user's profile) ══ --%>
                <asp:Panel ID="pnlReadOnly" runat="server" Visible="false">
                    <div class="section-title">Account Information</div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-user"></i></div>
                        <div><div class="info-label">Username</div><div class="info-value"><asp:Label ID="lblROUsername" runat="server" Text="—"></asp:Label></div></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-envelope"></i></div>
                        <div><div class="info-label">Email</div><div class="info-value"><asp:Label ID="lblROEmail" runat="server" Text="—"></asp:Label></div></div>
                    </div>
                    <div class="section-title">Personal Information</div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-id-card"></i></div>
                        <div><div class="info-label">Full Name</div><div class="info-value"><asp:Label ID="lblROFullName" runat="server" Text="—"></asp:Label></div></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-phone"></i></div>
                        <div><div class="info-label">Phone</div><div class="info-value"><asp:Label ID="lblROPhone" runat="server" Text="—"></asp:Label></div></div>
                    </div>
                    <div class="info-row">
                        <div class="info-icon"><i class="fa-solid fa-align-left"></i></div>
                        <div><div class="info-label">Bio</div><div class="info-value"><asp:Label ID="lblROBio" runat="server" Text="No bio provided."></asp:Label></div></div>
                    </div>
                </asp:Panel>

                <%-- ══ EDIT VIEW (own profile) ══ --%>
                <asp:Panel ID="pnlEdit" runat="server" Visible="false">
                    <div class="section-title">Profile Photo</div>
                    <div class="photo-row">
                        <asp:Image ID="imgProfilePreview" runat="server" CssClass="photo-preview" ImageUrl="~/images/default-avatar.png" AlternateText="Preview" />
                        <div>
                            <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png,.gif" />
                            <small>JPG, PNG or GIF — max 2 MB</small>
                        </div>
                    </div>

                    <div class="section-title">Account Information</div>
                    <div class="form-group">
                        <label>Username</label>
                        <asp:TextBox ID="txtUsername" runat="server" Enabled="false" />
                        <small>Username cannot be changed.</small>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                    </div>

                    <div class="section-title">Personal Information</div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>First Name</label>
                            <asp:TextBox ID="txtFirstName" runat="server" placeholder="First name" />
                        </div>
                        <div class="form-group">
                            <label>Last Name</label>
                            <asp:TextBox ID="txtLastName" runat="server" placeholder="Last name" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Phone Number</label>
                        <asp:TextBox ID="txtPhone" runat="server" placeholder="+60 12-345 6789" />
                    </div>
                    <div class="form-group">
                        <label>About Me (Bio)</label>
                        <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" placeholder="Tell us a little about yourself..." />
                    </div>

                    <div class="section-title">Change Password</div>
                    <div class="form-group">
                        <label>Current Password</label>
                        <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" placeholder="Enter current password" />
                    </div>
                    <div class="form-row">
                        <div class="form-group">
                            <label>New Password</label>
                            <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" placeholder="New password" />
                        </div>
                        <div class="form-group">
                            <label>Confirm New Password</label>
                            <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" placeholder="Confirm new password" />
                        </div>
                    </div>

                    <asp:Button ID="btnUpdateProfile" runat="server" Text="Save Changes"
                        CssClass="btn-save" OnClick="btnUpdateProfile_Click" />
                </asp:Panel>

            </div>
        </div>
    </div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
