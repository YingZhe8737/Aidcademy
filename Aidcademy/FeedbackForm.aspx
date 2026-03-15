<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FeedbackForm.aspx.cs" Inherits="Aidcademy.WebForm3" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Send Feedback — Aidcademy</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <style>
        :root { --red:#c9242b; --red-dark:#a01c22; --red-light:#fde8e9; --cream:#FFFBF1; --dark:#1a1a2e; }
        * { box-sizing:border-box; margin:0; padding:0; }
        html,body { font-family:'Nunito',sans-serif; background:var(--cream); overflow-x:hidden; }

        /* ── NAVBAR (matches MainPage/About) ── */
        .top-navbar { background:var(--red); padding:0 24px; height:60px; position:sticky; top:0; z-index:1000; display:flex; align-items:center; justify-content:space-between; box-shadow:0 2px 16px rgba(201,36,43,0.35); }
        .navbar-brand-custom { display:flex; align-items:center; gap:10px; text-decoration:none; }
        .navbar-brand-custom img { height:38px; width:38px; border-radius:50%; object-fit:cover; border:2px solid rgba(255,255,255,0.45); }
        .navbar-brand-custom span { font-size:1.25rem; font-weight:900; color:white; letter-spacing:1px; }
        .nav-right { display:flex; align-items:center; gap:6px; }
        .nav-top-btn { display:inline-flex; align-items:center; gap:7px; background:transparent; border:none; color:rgba(255,255,255,0.85); font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:700; padding:7px 14px; border-radius:8px; cursor:pointer; transition:background 0.18s,color 0.18s; text-decoration:none; }
        .nav-top-btn:hover { background:rgba(255,255,255,0.18); color:white; }
        .nav-top-btn.outline-btn { border:2px solid rgba(255,255,255,0.55); border-radius:22px; padding:6px 18px; }
        .nav-top-btn.outline-btn:hover { background:white; color:var(--red); }

        /* ── PAGE ── */
        .page-wrap { min-height:calc(100vh - 60px); display:flex; align-items:center; justify-content:center; padding:48px 20px; }

        .form-card {
            background:white; border-radius:24px; border:1px solid #ebebeb;
            padding:44px 48px; max-width:520px; width:100%;
            box-shadow:0 8px 40px rgba(0,0,0,0.06);
        }
        .form-icon { width:64px; height:64px; background:var(--red-light); border-radius:16px; display:flex; align-items:center; justify-content:center; font-size:1.8rem; color:var(--red); margin-bottom:20px; }
        .form-card h2 { font-size:1.6rem; font-weight:900; color:var(--dark); margin-bottom:6px; }
        .form-card .subtitle { font-size:0.9rem; color:#aaa; font-weight:600; margin-bottom:28px; }

        .form-group { margin-bottom:18px; }
        .form-group label { display:block; font-size:0.78rem; font-weight:800; color:#888; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:6px; }
        .form-input {
            width:100%; padding:11px 14px; border-radius:10px;
            border:1.5px solid #e0e0e0; font-family:'Nunito',sans-serif;
            font-size:0.9rem; font-weight:600; color:#333;
            transition:border-color 0.18s; outline:none;
        }
        .form-input:focus { border-color:var(--red); }
        textarea.form-input { resize:vertical; min-height:120px; }
        select.form-input { background:white; }

        .btn-submit {
            width:100%; padding:13px; background:var(--red); border:none; color:white;
            font-family:'Nunito',sans-serif; font-size:1rem; font-weight:800;
            border-radius:12px; cursor:pointer; transition:background 0.18s,transform 0.18s; margin-top:6px;
        }
        .btn-submit:hover { background:var(--red-dark); transform:translateY(-1px); }

        .msg-success { display:block; margin-top:14px; padding:12px 16px; background:#d1fae5; color:#065f46; border-radius:10px; font-size:0.88rem; font-weight:700; }
        .msg-error   { display:block; margin-top:14px; padding:12px 16px; background:#fde8e9; color:#9f1239; border-radius:10px; font-size:0.88rem; font-weight:700; }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
    <nav class="top-navbar">
        <a href="MainPage.aspx" class="navbar-brand-custom">
            <img src="image/aidcademylogo.png" alt="Aidcademy Logo" />
            <span>AIDCADEMY</span>
        </a>
        <div class="nav-right">
            <% if (Session["UserID"] != null) {
                   string role = Session["Role"] != null ? Session["Role"].ToString() : "Member";
                   string dashUrl = role == "Instructor" ? "InstructorManageContent.aspx" : (role == "Admin" ? "AdminDashboard.aspx" : "MemberDashboard.aspx"); %>
                <a href="<%= dashUrl %>" class="nav-top-btn"><i class="fa-solid fa-chart-line"></i> Dashboard</a>
                <a href="About.aspx" class="nav-top-btn"><i class="fa-solid fa-circle-info"></i> About</a>
            <% } else { %>
                <a href="MainPage.aspx" class="nav-top-btn"><i class="fa-solid fa-house"></i> Home</a>
                <a href="About.aspx" class="nav-top-btn"><i class="fa-solid fa-circle-info"></i> About</a>
                <a href="Login_Signup.aspx" class="nav-top-btn outline-btn"><i class="fa-solid fa-right-to-bracket"></i> Login</a>
            <% } %>
        </div>
    </nav>

    <div class="page-wrap">
        <div class="form-card">
            <div class="form-icon"><i class="fa-solid fa-envelope-open-text"></i></div>
            <h2>We'd Love Your Feedback</h2>
            <p class="subtitle">Help us improve Aidcademy — your input goes directly to the team.</p>

            <div class="form-group">
                <label>Category</label>
                <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-input">
                    <asp:ListItem Text="Select a Category" Value="" />
                    <asp:ListItem Text="Resources / Module"  Value="Resources" />
                    <asp:ListItem Text="Web Design"          Value="WebDesign" />
                    <asp:ListItem Text="Bug Report"          Value="Bug" />
                    <asp:ListItem Text="General"             Value="General" />
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label>Your Feedback</label>
                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" TextMode="MultiLine" Rows="5" placeholder="Tell us what you think…" />
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit Feedback" CssClass="btn-submit" OnClick="btnSubmit_Click" />
            <asp:Label ID="lblMessage" runat="server" EnableViewState="false"></asp:Label>
        </div>
    </div>

</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    window.onload = function () {
        var msg = document.getElementById('<%= lblMessage.ClientID %>');
        if (msg && msg.innerText.trim() !== '') {
            msg.className = msg.innerText.includes('success') ? 'msg-success' : 'msg-error';
            setTimeout(function () {
                msg.style.transition = 'opacity 0.5s ease';
                msg.style.opacity = '0';
                setTimeout(function () { msg.style.display = 'none'; }, 500);
            }, 3000);
        }
    };
</script>
</body>
</html>
