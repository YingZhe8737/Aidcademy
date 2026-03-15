<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningLesson.aspx.cs" Inherits="Aidcademy.LearningLesson" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Lessons - Aidcademy</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <link rel="stylesheet" href="~/Styles/Member.css" />
</head>
<body class="<%= IsMemberView ? "member-shell-page" : "member-page" %>">
<form id="form1" runat="server">

    <% if (IsMemberView) { %>
    <nav class="navbar navbar-expand-lg member-shell-topbar py-2">
        <div class="container-fluid px-4">
            <a class="navbar-brand" href="MainPage.aspx">
                <img src="Image/logo.jpeg" alt="Aidcademy" />
                AIDCADEMY
            </a>
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#memberLessonNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="memberLessonNavbar">
                <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1">
                    <li class="nav-item"><a class="nav-link" href="MemberDashboard.aspx">Dashboard</a></li>
                    <li class="nav-item"><a class="nav-link" href="About.aspx">About</a></li>
                    <li class="nav-item ms-lg-2">
                        <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="btn-logout" CausesValidation="false">Logout</asp:LinkButton>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="member-shell-layout">
        <aside class="member-shell-sidebar">
            <button type="button" class="member-shell-toggle" onclick="toggleMemberShellSidebar()" aria-label="Toggle sidebar">
                <i class="fas fa-chevron-left"></i>
            </button>

            <div class="member-profile">
                <div class="profile-avatar"><%= GetMemberInitial() %></div>
                <div class="profile-info">
                    <h6><%= GetMemberName() %></h6>
                    <p>Member</p>
                </div>
            </div>

            <nav class="member-shell-nav">
                <a href="MemberDashboard.aspx">
                    <i class="fas fa-chart-line"></i><span class="member-nav-label">Dashboard</span>
                </a>
                <a href="LearningCourse.aspx" class="active-side">
                    <i class="fas fa-book"></i><span class="member-nav-label">My Courses</span>
                </a>
                <a href="LearningProgress.aspx">
                    <i class="fas fa-chart-pie"></i><span class="member-nav-label">Progress</span>
                </a>
                <a href="SubmitQuestion.aspx">
                    <i class="fas fa-comments"></i><span class="member-nav-label">Q&amp;A</span>
                </a>
                <a href="MemberProfile.aspx">
                    <i class="fas fa-user"></i><span class="member-nav-label">Profile</span>
                </a>
            </nav>
        </aside>

        <main class="member-shell-main">
    <% } else { %>
    <div class="top-nav">
        <a href="MainPage.aspx" class="nav-brand">
            <img src="Image/Logo.jpeg" alt="Aidcademy" style="height:36px;border-radius:5px;" />
            AIDCADEMY
        </a>
        <div class="nav-links">
            <a href="MainPage.aspx">Home</a>
            <a href="About.aspx">About</a>
            <a href="LearningCourse.aspx" class="active-nav"><i class="fas fa-book me-1"></i>Courses</a>
            <a href="Login_signup.aspx" class="btn-signup"><i class="fas fa-sign-in-alt me-1"></i>Login / Sign Up</a>
        </div>
    </div>
    <% } %>

    <div class="member-container">
        <a href="LearningCourse.aspx" class="back-link"><i class="fas fa-arrow-left"></i>Back to Courses</a>

        <div class="page-header">
            <h1><i class="fas fa-list-check" style="color:#dc2626;"></i> <asp:Label ID="lblCourseTitle" runat="server" Text="Course Lessons"></asp:Label></h1>
            <p>Choose a lesson and start learning.</p>
        </div>

        <asp:Panel ID="pnlNoLessons" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-book"></i>
            <p>No approved lessons are available for this course yet.</p>
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

    <% if (IsMemberView) { %>
        </main>
    </div>
    <% } %>
</form>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        var storageKey = 'aidcademy-member-sidebar-collapsed';

        window.toggleMemberShellSidebar = function () {
            if (window.innerWidth <= 991) {
                return;
            }

            document.body.classList.toggle('sidebar-collapsed');
            try {
                localStorage.setItem(storageKey, document.body.classList.contains('sidebar-collapsed') ? '1' : '0');
            } catch (e) { }
        };

        try {
            if (document.body.classList.contains('member-shell-page') && window.innerWidth > 991 && localStorage.getItem(storageKey) === '1') {
                document.body.classList.add('sidebar-collapsed');
            }
        } catch (e) { }

        window.addEventListener('resize', function () {
            if (window.innerWidth <= 991) {
                document.body.classList.remove('sidebar-collapsed');
            }
        });
    })();
</script>
</body>
</html>
