<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningCourse.aspx.cs" Inherits="Aidcademy.LearningCourse" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <title>Courses - Aidcademy</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <style>
        body { font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif; background-color:#FFFBF1; min-height:100vh; }
        /* Nav */
        .top-nav { background: linear-gradient(to right,#dc2626,#b91c1c); padding:14px 28px; display:flex; justify-content:space-between; align-items:center; color:white; box-shadow:0 2px 10px rgba(0,0,0,0.12); flex-wrap:wrap; gap:10px; }
        .nav-brand { font-size:22px; font-weight:700; color:white; text-decoration:none; display:flex; align-items:center; gap:10px; }
        .nav-links { display:flex; gap:6px; align-items:center; flex-wrap:wrap; }
        .nav-links a, .nav-links button { color:white; text-decoration:none; padding:7px 14px; border-radius:6px; font-weight:500; transition:background .2s; background:none; border:none; font-size:1rem; cursor:pointer; }
        .nav-links a:hover, .nav-links button:hover { background:rgba(255,255,255,0.2); }
        .nav-links .active-nav { background:rgba(255,255,255,0.22); font-weight:700; }
        .nav-links .btn-signup { background:rgba(255,255,255,0.2); border:1.5px solid rgba(255,255,255,0.5); border-radius:20px; }
        /* Layout */
        .container { max-width:1200px; margin:30px auto; padding:0 20px; }
        .page-header { text-align:center; margin-bottom:40px; }
        .page-header h1 { color:#333; font-size:32px; margin-bottom:10px; }
        /* Cards */
        .course-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(350px,1fr)); gap:25px; }
        .course-card { background:white; border-radius:12px; overflow:hidden; box-shadow:0 2px 10px rgba(0,0,0,0.1); transition:transform .3s,box-shadow .3s; }
        .course-card:hover { transform:translateY(-5px); box-shadow:0 5px 20px rgba(0,0,0,0.15); }
        .course-image { height:180px; display:flex; align-items:center; justify-content:center; color:white; font-size:56px; overflow:hidden; position:relative; background:linear-gradient(to right,#dc2626,#b91c1c); }
        .course-image img { width:100%; height:100%; object-fit:cover; position:absolute; top:0; left:0; }
        .course-image .icon-overlay { position:relative; z-index:1; }
        .course-content { padding:22px; }
        .course-title { font-size:19px; font-weight:600; color:#333; margin-bottom:8px; }
        .course-description { color:#666; line-height:1.6; margin-bottom:12px; font-size:0.95rem; }
        .course-category { display:inline-block; padding:4px 12px; background:#fee2e2; color:#c9242b; border-radius:12px; font-size:12px; font-weight:600; margin-bottom:12px; }
        .badge-enrolled { display:inline-block; padding:4px 12px; background:#cce5ff; color:#004085; border-radius:12px; font-size:12px; font-weight:600; margin-left:6px; }
        .badge-free { display:inline-block; padding:4px 10px; background:#d4edda; color:#155724; border-radius:12px; font-size:12px; font-weight:600; margin-left:6px; }
        .btn-enroll { width:100%; padding:11px; background:linear-gradient(to right,#dc2626,#b91c1c); color:white; border:none; border-radius:8px; font-size:14px; font-weight:600; cursor:pointer; transition:all .3s; }
        .btn-enroll:hover { box-shadow:0 5px 15px rgba(220,38,38,.4); }
        .btn-enrolled-view { display:block; width:100%; padding:11px; background:#28a745; color:white; border-radius:8px; font-size:14px; font-weight:600; text-align:center; text-decoration:none; }
        .btn-enrolled-view:hover { background:#218838; color:white; }
        .btn-free-lesson { display:block; width:100%; padding:11px; background:#fff; color:#dc2626; border:2px solid #dc2626; border-radius:8px; font-size:14px; font-weight:600; text-align:center; text-decoration:none; margin-bottom:8px; }
        .btn-free-lesson:hover { background:#fff5f5; }
        .btn-login-enroll { display:block; width:100%; padding:11px; background:#6c757d; color:white; border-radius:8px; font-size:14px; font-weight:600; text-align:center; text-decoration:none; }
        .btn-login-enroll:hover { background:#5a6268; color:white; }
        .visitor-note { background:#fff3cd; border:1px solid #ffc107; border-radius:10px; padding:14px 20px; margin-bottom:28px; color:#856404; font-size:.95rem; }
        @media(max-width:768px){.course-grid{grid-template-columns:1fr;}}
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- Adaptive Navbar -->
    <div class="top-nav">
        <a href="MainPage.aspx" class="nav-brand">
            <img src="Image/Logo.jpeg" alt="Aidcademy" style="height:36px;border-radius:5px;" />
            AIDCADEMY
        </a>
        <div class="nav-links">
            <!-- Member links -->
            <asp:Panel ID="pnlMemberNav" runat="server" Visible="false">
                <a href="MemberDashboard.aspx"><i class="fas fa-chart-line me-1"></i>Dashboard</a>
                <a href="LearningCourse.aspx" class="active-nav"><i class="fas fa-book me-1"></i>Courses</a>
                <a href="LearningProgress.aspx"><i class="fas fa-chart-pie me-1"></i>My Progress</a>
                <a href="SubmitQuestion.aspx"><i class="fas fa-comments me-1"></i>Ask Question</a>
                <a href="MemberProfile.aspx"><i class="fas fa-user me-1"></i>Profile</a>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CausesValidation="false"><i class="fas fa-sign-out-alt me-1"></i>Logout</asp:LinkButton>
            </asp:Panel>
            <!-- Visitor links -->
            <asp:Panel ID="pnlVisitorNav" runat="server" Visible="false">
                <a href="LearningCourse.aspx" class="active-nav"><i class="fas fa-book me-1"></i>Courses</a>
                <a href="Login_signup.aspx" class="btn-signup"><i class="fas fa-sign-in-alt me-1"></i>Login / Sign Up</a>
            </asp:Panel>
        </div>
    </div>

    <div class="container">
        <div class="page-header">
            <h1><i class="fas fa-book-open me-2 text-danger"></i>Available Courses</h1>
            <p>Try the CPR course for free - lesson 2 preview included, no login needed</p>
            <div class="mt-4" style="max-width:500px;margin:0 auto;">
                <input type="text" id="txtSearch" class="form-control rounded-pill text-center shadow-sm py-2"
                    placeholder="Search courses by name..." oninput="filterCourses()" />
            </div>
        </div>

        <asp:Panel ID="pnlVisitorNote" runat="server" Visible="false" CssClass="visitor-note">
            <i class="fas fa-info-circle me-2"></i>
            You are browsing as a <strong>Visitor</strong>.
            The <strong>CPR course</strong> is available for free - <span class="badge bg-success">Lesson 2 Free</span> included, no login required.
            <a href="Login_signup.aspx" class="fw-bold ms-2">Login or Sign Up</a> to unlock all lessons and access more courses.
        </asp:Panel>

        <div class="course-grid">
            <asp:Repeater ID="rptCourses" runat="server">
                <ItemTemplate>
                    <div class="course-card">
                        <div class="course-image">
                            <%# !string.IsNullOrEmpty(Eval("PhotoPath") as string)
                                ? "<img src='" + Eval("PhotoPath") + "' alt='Course' /><span class='icon-overlay' style='display:none'></span>"
                                : "<span class='icon-overlay'><i class='fas fa-hospital' style='font-size:52px;'></i></span>" %>
                        </div>
                        <div class="course-content">
                            <h3 class="course-title mb-2">
                                <a href='LearningLesson.aspx?CourseID=<%# Eval("CourseID") %>' style='color:inherit;text-decoration:none;'>
                                    <%# Eval("CourseName") %>
                                </a>
                            </h3>

                            <div class="course-description-container" style="margin-bottom:12px;">
                                <p class="course-description m-0" style="display:inline;">
                                    <%# Eval("CourseDescription").ToString().Length > 120
                                        ? Eval("CourseDescription").ToString().Substring(0,120) + "..."
                                        : Eval("CourseDescription") %>
                                </p>
                                <%# Eval("CourseDescription").ToString().Length > 120
                                    ? "<span class='full-desc d-none'>" + Eval("CourseDescription") + "</span><a href='#' class='text-primary fw-bold ms-1' style='text-decoration:none;font-size:.9em;' onclick='toggleDesc(this,event)'>Read more &#9660;</a>"
                                    : "" %>
                            </div>

                            <div style="margin-bottom:14px;">
                                <span class="course-category"><%# Eval("Category") %></span>
                                <%# Convert.ToBoolean(Eval("IsEnrolled")) ? "<span class='badge-enrolled'>&check; Enrolled</span>" : "" %>
                                <%# !Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled")) && Eval("FreeLessonID") != DBNull.Value
                                    ? "<span class='badge-free'><i class='fas fa-unlock me-1'></i>Lesson 2 Free</span>" : "" %>
                            </div>

                            <!-- Progress bar for enrolled members -->
                            <%# GetProgressMarkup(Eval("IsEnrolled"), Eval("ProgressPercentage")) %>

                            <!-- Continue button (enrolled member) -->
                            <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                ? "<a href='" + GetContinueUrl(Eval("CourseID")) + "' class='btn-enrolled-view'>Continue Learning &#x2192;</a>"
                                : "" %>

                            <!-- Free lesson (visitor) -->
                            <%# !Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled")) && Eval("FreeLessonID") != DBNull.Value
                                ? "<a href='LearningLesson.aspx?CourseID=" + Eval("CourseID") + "' class='btn-free-lesson'><i class='fas fa-play-circle me-2'></i>Try Free Lesson </a>"
                                : "" %>

                            <!-- Enroll button (logged-in member) -->
                            <asp:LinkButton runat="server"
                                Visible='<%# Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled")) %>'
                                CommandName="Enroll" CommandArgument='<%# Eval("CourseID") %>'
                                OnCommand="btnEnroll_Command" CssClass="btn-enroll">
                                <i class="fas fa-plus-circle me-1"></i> Enroll Now
                            </asp:LinkButton>

                            <!-- Login to enroll (visitor, after free lesson prompt) -->
                            <%# !Convert.ToBoolean(Eval("IsMember")) && !Convert.ToBoolean(Eval("IsEnrolled"))
                                ? "<a href='Login_signup.aspx' class='btn-login-enroll mt-2'><i class='fas fa-sign-in-alt me-1'></i>Login to Enroll &amp; Access All Lessons</a>"
                                : "" %>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function filterCourses() {
        var s = document.getElementById("txtSearch").value.toLowerCase();
        document.querySelectorAll(".course-card").forEach(function (c) {
            var t = c.querySelector(".course-title").innerText.toLowerCase();
            c.style.display = t.includes(s) ? "" : "none";
        });
    }
    function toggleDesc(btn, e) {
        e.preventDefault();
        var box = btn.parentElement;
        var short = box.querySelector(".course-description");
        var full = box.querySelector(".full-desc");
        if (full.classList.contains("d-none")) {
            short.style.display = "none"; full.classList.remove("d-none"); btn.innerHTML = "Show less &#9650;";
        } else {
            short.style.display = "inline"; full.classList.add("d-none"); btn.innerHTML = "Read more &#9660;";
        }
    }
</script>
</body>
</html>
