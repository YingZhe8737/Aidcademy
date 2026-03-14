<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningLesson.aspx.cs" Inherits="Aidcademy.LearningLesson" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Lessons - Aidcademy</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <style>
        body { font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; background-color:#FFFBF1; min-height:100vh; }
        .top-nav { background: linear-gradient(to right,#dc2626,#b91c1c); padding:14px 28px; display:flex; justify-content:space-between; align-items:center; color:white; box-shadow:0 2px 10px rgba(0,0,0,0.12); flex-wrap:wrap; gap:10px; }
        .nav-brand { font-size:22px; font-weight:700; color:white; text-decoration:none; display:flex; align-items:center; gap:10px; }
        .nav-links { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
        .nav-links a, .nav-links button { color:white; text-decoration:none; padding:7px 14px; border-radius:6px; font-weight:500; transition:background .2s; background:none; border:none; font-size:1rem; cursor:pointer; }
        .nav-links a:hover, .nav-links button:hover { background:rgba(255,255,255,0.2); }
        .nav-links .active-nav { background:rgba(255,255,255,0.22); font-weight:700; }
        .nav-links .btn-signup { background:rgba(255,255,255,0.2); border:1.5px solid rgba(255,255,255,0.5); border-radius:20px; }
        .container { max-width:1100px; margin:28px auto; padding:0 18px; }
        .page-header { margin-bottom:24px; }
        .page-header h1 { color:#2f2f2f; font-size:30px; margin-bottom:6px; }
        .page-header .sub { color:#666; }
        .back-link { text-decoration:none; color:#c9242b; font-weight:600; display:inline-flex; align-items:center; gap:8px; margin-bottom:16px; }
        .lesson-list { display:grid; grid-template-columns:1fr; gap:16px; }
        .lesson-card { background:#fff; border-radius:12px; box-shadow:0 2px 10px rgba(0,0,0,0.08); border:1px solid #f1ece2; padding:18px; }
        .lesson-top { display:flex; justify-content:space-between; align-items:flex-start; gap:12px; flex-wrap:wrap; }
        .lesson-seq { font-size:.86rem; color:#b91c1c; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }
        .lesson-title { font-size:1.2rem; color:#222; margin:2px 0 8px; font-weight:700; }
        .lesson-desc { color:#555; line-height:1.55; margin:0; }
        .lesson-media { width:88px; height:66px; border-radius:9px; overflow:hidden; background:linear-gradient(to right,#fca5a5,#ef4444); display:flex; align-items:center; justify-content:center; color:#fff; flex-shrink:0; }
        .lesson-media img { width:100%; height:100%; object-fit:cover; }
        .lesson-footer { margin-top:14px; display:flex; justify-content:space-between; align-items:center; gap:12px; flex-wrap:wrap; }
        .badge-completed { background:#d4edda; color:#155724; padding:5px 10px; border-radius:999px; font-size:.8rem; font-weight:700; }
        .badge-pending { background:#e2e3e5; color:#41464b; padding:5px 10px; border-radius:999px; font-size:.8rem; font-weight:700; }
        .btn-learn { background:linear-gradient(to right,#dc2626,#b91c1c); color:white; text-decoration:none; border-radius:8px; padding:9px 16px; font-weight:700; }
        .btn-learn:hover { color:white; box-shadow:0 4px 14px rgba(220,38,38,.35); }
        .btn-login-access { background:#6c757d; color:white; text-decoration:none; border-radius:8px; padding:9px 16px; font-weight:700; }
        .btn-login-access:hover { background:#5a6268; color:white; }
        .empty-box { background:#fff; border:1px dashed #ddd; border-radius:12px; padding:22px; text-align:center; color:#666; }
        @media(max-width:768px){
            .page-header h1 { font-size:26px; }
            .lesson-media { width:74px; height:56px; }
        }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <div class="top-nav">
        <a href="MainPage.aspx" class="nav-brand">
            <img src="Image/Logo.jpeg" alt="Aidcademy" style="height:36px;border-radius:5px;" />
            AIDCADEMY
        </a>
        <div class="nav-links">
            <asp:Panel ID="pnlMemberNav" runat="server" Visible="false">
                <a href="MemberDashboard.aspx"><i class="fas fa-chart-line me-1"></i>Dashboard</a>
                <a href="LearningCourse.aspx" class="active-nav"><i class="fas fa-book me-1"></i>Courses</a>
                <a href="LearningProgress.aspx"><i class="fas fa-chart-pie me-1"></i>My Progress</a>
                <a href="SubmitQuestion.aspx"><i class="fas fa-comments me-1"></i>Ask Question</a>
                <a href="MemberProfile.aspx"><i class="fas fa-user me-1"></i>Profile</a>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CausesValidation="false"><i class="fas fa-sign-out-alt me-1"></i>Logout</asp:LinkButton>
            </asp:Panel>
            <asp:Panel ID="pnlVisitorNav" runat="server" Visible="false">
                <a href="LearningCourse.aspx" class="active-nav"><i class="fas fa-book me-1"></i>Courses</a>
                <a href="Login_signup.aspx" class="btn-signup"><i class="fas fa-sign-in-alt me-1"></i>Login / Sign Up</a>
            </asp:Panel>
        </div>
    </div>

    <div class="container">
        <a href="LearningCourse.aspx" class="back-link"><i class="fas fa-arrow-left"></i>Back to Courses</a>

        <div class="page-header">
            <h1><i class="fas fa-list-check text-danger me-2"></i><asp:Label ID="lblCourseTitle" runat="server" Text="Course Lessons"></asp:Label></h1>
            <p class="sub">Choose a lesson and start learning.</p>
        </div>

        <asp:Panel ID="pnlNoLessons" runat="server" Visible="false" CssClass="empty-box">
            No approved lessons are available for this course yet.
        </asp:Panel>

        <div class="lesson-list">
            <asp:Repeater ID="rptLessons" runat="server">
                <ItemTemplate>
                    <div class="lesson-card">
                        <div class="lesson-top">
                            <div style="flex:1;min-width:220px;">
                                <div class="lesson-seq">Lesson <%# Eval("SequenceOrder") %></div>
                                <h3 class="lesson-title"><%# Eval("Title") %></h3>
                                <p class="lesson-desc"><%# Eval("Description") %></p>
                            </div>
                            <div class="lesson-media">
                                <img src='<%# GetLessonImageUrl(Eval("LessonPhoto"), Eval("SequenceOrder")) %>' alt='Lesson' />
                            </div>
                        </div>

                        <div class="lesson-footer">
                            <div>
                                <%# Convert.ToBoolean(Eval("IsMember"))
                                    ? (Convert.ToInt32(Eval("IsCompleted")) == 1
                                        ? "<span class='badge-completed'><i class='fas fa-check-circle me-1'></i>Completed</span>"
                                        : "<span class='badge-pending'><i class='fas fa-hourglass-half me-1'></i>Not Completed</span>")
                                    : "" %>
                            </div>
                            <div>
                                <%# Convert.ToBoolean(Eval("IsMember")) || Convert.ToInt32(Eval("IsFreeLesson")) == 1
                                    ? "<a class='btn-learn' href='ViewLesson.aspx?LessonID=" + Eval("LessonID") + "'><i class='fas fa-play me-1'></i>Learn</a>"
                                    : "<a class='btn-login-access' href='Login_signup.aspx'><i class='fas fa-lock me-1'></i>Login to Access</a>" %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</form>
</body>
</html>
