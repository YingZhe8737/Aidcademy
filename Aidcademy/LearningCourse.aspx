<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningCourse.aspx.cs" Inherits="Aidcademy.LearningCourse" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Courses - Aidcademy</title>
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
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#memberCourseNavbar">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="memberCourseNavbar">
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
        <!-- Search & Count -->
        <div class="course-catalog-header">
            <div class="search-bar">
                <input type="text" id="txtSearch" class="search-input"
                    placeholder="Search courses..." oninput="filterCourses()" />
            </div>
            <div class="courses-count">
                <asp:Label ID="lblCourseCount" runat="server"></asp:Label> courses found
            </div>
        </div>

        <% if (!IsMemberView) { %>
        <div class="visitor-note">
            <i class="fas fa-info-circle me-2"></i>
            You are browsing as a <strong>Visitor</strong>.
            You can still view the full course catalog as a visitor.
            The <strong>CPR course</strong> includes a free preview lesson.
            <a href="Login_signup.aspx" class="fw-bold ms-2">Login or Sign Up</a> to enrol and track progress.
        </div>
        <% } %>

        <!-- Course Grid -->
        <div class="course-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <div class="card-image">
                            <%# !string.IsNullOrEmpty(Eval("PhotoPath") as string)
                                ? "<img src='" + Eval("PhotoPath") + "' alt='Course' onerror=\"this.onerror=null;this.src='image/Logo.jpeg';\" />"
                                : "<img src='image/Logo.jpeg' alt='Course' />" %>

                            <!-- Badges -->
                            <div class="card-badges">
                                <%# !string.IsNullOrEmpty(Eval("BadgeType") as string)
                                    ? "<span class='card-badge " + GetBadgeClass(Eval("BadgeType")) + "'>" + Eval("BadgeType") + "</span>" : "" %>
                            </div>

                            <%# Convert.ToBoolean(Eval("IsFreeFlag"))
                                ? "<span class='card-free-badge'>FREE</span>"
                                : (!Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled"))
                                    ? "<span class='card-lock'><i class='fas fa-lock'></i></span>" : "") %>

                            <!-- Tags -->
                            <div class="card-tags">
                                <span class="card-tag"><%# Eval("DifficultyLevel") ?? "Beginner" %></span>
                                <span class="card-tag"><%# Eval("Category") %></span>
                            </div>
                        </div>

                        <div class="card-body">
                            <h3 class="card-title">
                                <a href='LearningLesson.aspx?CourseID=<%# Eval("CourseID") %>' style='color:inherit;text-decoration:none;'>
                                    <%# Eval("CourseName") %>
                                </a>
                            </h3>
                            <p class="card-desc"><%# Eval("CourseDescription") %></p>
                            <div class="card-author">By <%# !string.IsNullOrEmpty(Eval("InstructorName") as string) ? Eval("InstructorName") : "Aidcademy" %></div>

                            <div class="card-meta">
                                <span><i class="fas fa-book-open"></i> <%# Eval("LessonCount") %> lessons</span>
                                <span><i class="fas fa-clock"></i> <%# FormatDuration(Eval("TotalDuration")) %></span>
                                <span><i class="fas fa-users"></i> <%# Eval("StudentCount") %></span>
                            </div>

                            <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                ? GetEnrolledMarkup(Eval("ProgressPercentage"), Eval("CourseID"))
                                : "" %>

                            <div class="card-footer">
                                <div class="card-rating">
                                    <i class="fas fa-star"></i>
                                    <%# Eval("Rating") != DBNull.Value && Convert.ToDecimal(Eval("Rating")) > 0
                                        ? "<strong>" + string.Format("{0:F1}", Eval("Rating")) + "</strong> <span class='rating-text'>/5.0</span>"
                                        : "<span class='rating-text'>New</span>" %>
                                </div>

                                <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                    ? "<a href='" + GetContinueUrl(Eval("CourseID")) + "' class='view-course-link'>Continue <i class='fas fa-chevron-right'></i></a>"
                                    : Convert.ToBoolean(Eval("IsMember"))
                                        ? ""
                                        : "<a href='LearningLesson.aspx?CourseID=" + Eval("CourseID") + "' class='view-course-link'>View Course <i class='fas fa-chevron-right'></i></a>" %>
                            </div>

                            <!-- Enroll button (logged-in member, not enrolled) -->
                            <asp:LinkButton runat="server"
                                Visible='<%# Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled")) %>'
                                CommandName="Enroll" CommandArgument='<%# Eval("CourseID") %>'
                                OnCommand="btnEnroll_Command" CssClass="btn-enroll" Style="margin-top:12px;">
                                <i class="fas fa-plus-circle me-1"></i> Enroll Now
                            </asp:LinkButton>

                            <%# !Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled")) && Eval("FreeLessonID") != DBNull.Value
                                ? "<a href='LearningLesson.aspx?CourseID=" + Eval("CourseID") + "' class='btn-free-lesson' style='margin-top:12px;'><i class='fas fa-play-circle me-2'></i>Try Free Lesson</a>"
                                : "" %>

                            <%# !Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled"))
                                ? "<a href='Login_signup.aspx' class='btn-login-enroll' style='margin-top:8px;'><i class='fas fa-sign-in-alt me-1'></i>Login to Enroll</a>"
                                : "" %>
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

    function filterCourses() {
        var s = document.getElementById("txtSearch").value.toLowerCase();
        document.querySelectorAll(".course-card").forEach(function (c) {
            var t = c.querySelector(".card-title").innerText.toLowerCase();
            c.style.display = t.includes(s) ? "" : "none";
        });
    }
</script>
</body>
</html>
