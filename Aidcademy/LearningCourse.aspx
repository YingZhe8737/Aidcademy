<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningCourse.aspx.cs" Inherits="Aidcademy.LearningCourse" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Courses - Aidcademy</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <link rel="stylesheet" href="~/Styles/Member.css" />
    <style>
        :root { --red:#c9242b; --red-dark:#a01c22; --red-light:#fde8e9; --cream:#FFFBF1; --dark:#1a1a2e; --nav-h:60px; }
        * { box-sizing: border-box; }
        body { font-family: 'Nunito', 'Segoe UI', sans-serif; overflow-x: hidden; margin: 0; padding: 0; }
        /* ══ TOP NAVBAR — exact MainPage / Member.Master ══ */
        .top-navbar { position: fixed; top: 0; left: 0; right: 0; height: var(--nav-h); background: var(--red); display: flex; align-items: center; justify-content: space-between; padding: 0 24px; z-index: 200; box-shadow: 0 2px 16px rgba(201,36,43,0.35); }
        .navbar-brand-custom { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .navbar-brand-custom img { height: 38px; width: 38px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.45); }
        .navbar-brand-custom span { font-size: 1.25rem; font-weight: 900; color: white; letter-spacing: 1px; }
        .nav-right { display: flex; align-items: center; gap: 6px; }
        .nav-top-btn { display: inline-flex; align-items: center; gap: 7px; background: transparent; border: none; color: rgba(255,255,255,0.85); font-family: 'Nunito', sans-serif; font-size: 0.88rem; font-weight: 700; padding: 7px 14px; border-radius: 8px; cursor: pointer; transition: background 0.18s, color 0.18s; text-decoration: none; }
        .nav-top-btn:hover, .nav-top-btn.active-nav { background: rgba(255,255,255,0.18); color: white; }
        .nav-top-btn.outline-btn { border: 2px solid rgba(255,255,255,0.55); border-radius: 22px; padding: 6px 18px; }
        .nav-top-btn.outline-btn:hover { background: white; color: var(--red); }
        /* ══ LAYOUT SHELL ══ */
        .layout-shell { display: flex; padding-top: var(--nav-h); min-height: 100vh; }
        /* ══ GUEST SHELL (no sidebar) ══ */
        .guest-shell { padding-top: var(--nav-h); min-height: 100vh; background: var(--cream); }
        /* ══ SIDEBAR ══ */
        .sidebar { position: fixed; top: var(--nav-h); left: 0; bottom: 0; width: 240px; background: white; border-right: 1px solid #ebebeb; display: flex; flex-direction: column; transition: width 0.25s cubic-bezier(0.4,0,0.2,1); z-index: 100; overflow: hidden; }
        .sidebar.collapsed { width: 68px; }
        .sidebar-header { display: flex; align-items: center; justify-content: flex-end; padding: 14px 12px; border-bottom: 1px solid #f0f0f0; flex-shrink: 0; }
        .sidebar-toggle { width: 30px; height: 30px; border-radius: 50%; border: 1.5px solid #e0e0e0; background: white; display: flex; align-items: center; justify-content: center; cursor: pointer; color: #888; font-size: 0.75rem; transition: all 0.2s; flex-shrink: 0; }
        .sidebar-toggle:hover { border-color: var(--red); color: var(--red); background: var(--red-light); }
        .sidebar-section-label { font-size: 0.68rem; font-weight: 800; color: #bbb; letter-spacing: 1.5px; text-transform: uppercase; padding: 14px 16px 5px; white-space: nowrap; overflow: hidden; transition: opacity 0.2s; flex-shrink: 0; }
        .sidebar.collapsed .sidebar-section-label { opacity: 0; }
        .sidebar-nav { flex: 1; padding: 4px 10px; overflow-y: auto; }
        .sidebar-nav::-webkit-scrollbar { width: 4px; }
        .sidebar-nav::-webkit-scrollbar-thumb { background: #e0e0e0; border-radius: 4px; }
        .sidebar-item { display: flex; align-items: center; gap: 12px; padding: 9px 12px; border-radius: 10px; color: #555; text-decoration: none; font-size: 0.88rem; font-weight: 700; white-space: nowrap; transition: all 0.18s; position: relative; margin-bottom: 2px; width: 100%; }
        .sidebar-item:hover { background: #f5f5f5; color: #222; text-decoration: none; }
        .sidebar-item.active { background: var(--red-light); color: var(--red); }
        .sidebar-icon { width: 36px; height: 36px; border-radius: 9px; display: flex; align-items: center; justify-content: center; font-size: 1rem; flex-shrink: 0; background: #f5f5f5; color: #666; transition: all 0.18s; }
        .sidebar-item:hover .sidebar-icon, .sidebar-item.active .sidebar-icon { background: var(--red-light); color: var(--red); }
        .sidebar-label { transition: opacity 0.2s, width 0.2s; overflow: hidden; white-space: nowrap; }
        .sidebar.collapsed .sidebar-label { opacity: 0; width: 0; }
        .sidebar.collapsed .sidebar-item:hover::after { content: attr(data-label); position: absolute; left: 68px; background: var(--dark); color: white; font-size: 0.8rem; font-weight: 700; padding: 6px 12px; border-radius: 8px; white-space: nowrap; pointer-events: none; box-shadow: 0 4px 12px rgba(0,0,0,0.2); z-index: 999; }
        .sidebar-divider { height: 1px; background: #f0f0f0; margin: 6px 10px; flex-shrink: 0; }
        .sidebar-footer { padding: 10px 10px 14px; border-top: 1px solid #f0f0f0; flex-shrink: 0; }
        .sidebar-profile-link { display: flex; align-items: center; gap: 10px; padding: 10px 12px; border-radius: 10px; text-decoration: none; transition: all 0.22s; position: relative; }
        .sidebar-profile-link:hover { background: var(--red-light); transform: translateY(-1px); box-shadow: 0 4px 12px rgba(201,36,43,0.12); }
        .sidebar-profile-link:hover .sidebar-user-name { color: var(--red); }
        .sidebar-profile-link:hover .sidebar-avatar { border-color: var(--red); }
        .sidebar-profile-link::after { content: 'View Profile \2192'; position: absolute; bottom: calc(100% + 6px); left: 12px; background: var(--dark); color: white; font-size: 0.72rem; font-weight: 700; padding: 5px 10px; border-radius: 6px; white-space: nowrap; opacity: 0; pointer-events: none; transition: opacity 0.2s; }
        .sidebar-profile-link:hover::after { opacity: 1; }
        .sidebar.collapsed .sidebar-profile-link::after { display: none; }
        .sidebar-avatar { width: 38px; height: 38px; border-radius: 50%; background: var(--red); color: white; display: flex; align-items: center; justify-content: center; font-size: 1rem; font-weight: 800; flex-shrink: 0; border: 2px solid #ebebeb; overflow: hidden; transition: border-color 0.22s; }
        .sidebar-avatar img { width: 100%; height: 100%; object-fit: cover; border-radius: 50%; }
        .sidebar-user-info { overflow: hidden; }
        .sidebar-user-name { font-size: 0.88rem; font-weight: 800; color: #222; white-space: nowrap; transition: color 0.22s; }
        .sidebar-user-role { font-size: 0.72rem; color: #999; font-weight: 600; white-space: nowrap; }
        .sidebar.collapsed .sidebar-user-info { opacity: 0; width: 0; overflow: hidden; }
        .main-content { margin-left: 240px; flex: 1; transition: margin-left 0.25s cubic-bezier(0.4,0,0.2,1); min-width: 0; }
        .main-content.expanded { margin-left: 68px; }
        @media(max-width:991px) {
            .sidebar { position: relative; top: 0; width: 100% !important; height: auto; border-right: none; border-bottom: 1px solid #ebebeb; }
            .sidebar-nav { flex-direction: row; flex-wrap: wrap; padding: 8px; }
            .sidebar-item { width: auto; }
            .sidebar-footer { display: none; }
            .main-content { margin-left: 0 !important; }
            .sidebar-section-label { display: none; }
        }

        /* Continue / View Course button */
        .view-course-link {
            display: inline-flex; align-items: center; gap: 6px;
            background: var(--red); color: white !important; text-decoration: none !important;
            font-family: 'Nunito', sans-serif; font-size: 0.85rem; font-weight: 700;
            padding: 8px 18px; border-radius: 8px; transition: background 0.18s;
        }
        .view-course-link:hover { background: var(--red-dark); color: white !important; }
        .page-body { padding: 32px 32px 60px; }
        .guest-body .page-body { padding: 32px 32px 60px; background: var(--cream); }
    </style>
</head>
<body>
<form id="form1" runat="server">

<% if (IsMemberView) { %>
    <nav class="top-navbar">
        <a href="MainPage.aspx" class="navbar-brand-custom">
            <img src="image/aidcademylogo.png" alt="Aidcademy" />
            <span>AIDCADEMY</span>
        </a>
        <div class="nav-right">
            <a href="MemberDashboard.aspx" class="nav-top-btn">
                <i class="fa-solid fa-chart-line"></i> Dashboard
            </a>
            <a href="About.aspx" class="nav-top-btn">
                <i class="fa-solid fa-circle-info"></i> About
            </a>
            <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click"
                CssClass="nav-top-btn outline-btn" CausesValidation="false">
                <i class="fa-solid fa-right-from-bracket"></i> Logout
            </asp:LinkButton>
        </div>
    </nav>
    <div class="layout-shell">
    <aside class="sidebar" id="memberSidebar">
        <div class="sidebar-header">
            <button class="sidebar-toggle" id="sidebarToggle" type="button" onclick="toggleMemberSidebar()" title="Toggle sidebar">
                <i class="fa-solid fa-chevron-left" id="toggleIcon"></i>
            </button>
        </div>
        <div class="sidebar-section-label">Main Menu</div>
        <nav class="sidebar-nav">
            <a href="MemberDashboard.aspx" data-label="Dashboard" class="sidebar-item">
                <div class="sidebar-icon"><i class="fa-solid fa-chart-line"></i></div>
                <span class="sidebar-label">Dashboard</span>
            </a>
            <div class="sidebar-divider"></div>
            <div class="sidebar-section-label">Learning</div>
            <a href="LearningCourse.aspx" data-label="My Courses" class="sidebar-item active">
                <div class="sidebar-icon"><i class="fa-solid fa-book-open"></i></div>
                <span class="sidebar-label">My Courses</span>
            </a>
            <a href="LearningProgress.aspx" data-label="Progress" class="sidebar-item">
                <div class="sidebar-icon"><i class="fa-solid fa-chart-pie"></i></div>
                <span class="sidebar-label">Progress</span>
            </a>
            <div class="sidebar-divider"></div>
            <div class="sidebar-section-label">Community</div>
            <a href="SubmitQuestion.aspx" data-label="Q&amp;A" class="sidebar-item">
                <div class="sidebar-icon"><i class="fa-solid fa-comments"></i></div>
                <span class="sidebar-label">Q&amp;A</span>
            </a>
        </nav>
        <div class="sidebar-footer">
            <a href="Profile.aspx" class="sidebar-profile-link" title="View Profile">
                <div class="sidebar-avatar"><%= GetMemberInitial() %></div>
                <div class="sidebar-user-info">
                    <div class="sidebar-user-name"><%= GetMemberName() %></div>
                    <div class="sidebar-user-role">Member &middot; View Profile</div>
                </div>
            </a>
        </div>
    </aside>
        <main class="main-content" id="memberMainContent">
            <div class="page-body">
<% } else { %>
    <nav class="top-navbar">
        <a href="MainPage.aspx" class="navbar-brand-custom">
            <img src="image/aidcademylogo.png" alt="Aidcademy" />
            <span>AIDCADEMY</span>
        </a>
        <div class="nav-right">
            <a href="About.aspx" class="nav-top-btn">
                <i class="fa-solid fa-circle-info"></i> About
            </a>
            <a href="LearningCourse.aspx" class="nav-top-btn">
                <i class="fa-solid fa-book-open"></i> Courses
            </a>
            <a href="Login_Signup.aspx" class="nav-top-btn outline-btn">
                <i class="fa-solid fa-right-to-bracket"></i> Login
            </a>
        </div>
    </nav>
    <div class="guest-shell">
        <div class="page-body">
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
                            <img src='<%# Eval("CourseThumbnailPath") != DBNull.Value && !string.IsNullOrEmpty(Eval("CourseThumbnailPath").ToString()) ? ResolveUrl(Eval("CourseThumbnailPath").ToString()) : "image/default-course.png" %>' alt="Course" />

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
            </div>
        </main>
    </div>
<% } else { %>
        </div>
    </div>
<% } %>

</form>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>

    var sidebarCollapsed = false;
    function toggleMemberSidebar() {
        sidebarCollapsed = !sidebarCollapsed;
        document.getElementById('memberSidebar').classList.toggle('collapsed', sidebarCollapsed);
        document.getElementById('memberMainContent').classList.toggle('expanded', sidebarCollapsed);
        document.getElementById('toggleIcon').className = sidebarCollapsed ? 'fa-solid fa-chevron-right' : 'fa-solid fa-chevron-left';
        localStorage.setItem('memberSidebarCollapsed', sidebarCollapsed);
    }
    (function () {
        if (localStorage.getItem('memberSidebarCollapsed') === 'true') {
            sidebarCollapsed = true;
            document.getElementById('memberSidebar').classList.add('collapsed');
            document.getElementById('memberMainContent').classList.add('expanded');
            document.getElementById('toggleIcon').className = 'fa-solid fa-chevron-right';
        }
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
