<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" Inherits="Aidcademy.MemberDashboard" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard - Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="member-container">

        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="user-info">
                <h1>Welcome back, <asp:Label ID="lblMemberName" runat="server"></asp:Label>!</h1>
                <p>Keep up the great work on your learning journey.</p>
            </div>
            <div class="welcome-actions">
                <div class="user-avatar">
                    <asp:Label ID="lblUserInitial" runat="server"></asp:Label>
                </div>
            </div>
        </div>

        <!-- Stats Grid -->
        <div class="stats-grid">
            <div class="stat-card">
                <div class="stat-icon blue"><i class="fas fa-book-open"></i></div>
                <div class="stat-value"><asp:Label ID="lblEnrolledCourses" runat="server">0</asp:Label></div>
                <div class="stat-label">Courses Enrolled</div>
                <div class="stat-sub"><asp:Label ID="lblCompletedCourses" runat="server">0</asp:Label> completed</div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange"><i class="fas fa-fire"></i></div>
                <div class="stat-value"><asp:Label ID="lblDailyStreak" runat="server">0</asp:Label></div>
                <div class="stat-label">Day Streak</div>
                <div class="stat-sub">Personal best: <asp:Label ID="lblPersonalBest" runat="server">0</asp:Label></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon purple"><i class="fas fa-medal"></i></div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalPoints" runat="server">0</asp:Label>
                </div>
                <div class="stat-label">Points Earned</div>
                <div class="stat-sub">This month: +<asp:Label ID="lblMonthlyPoints" runat="server">0</asp:Label></div>
            </div>
            <div class="stat-card">
                <div class="stat-icon gold"><i class="fas fa-trophy"></i></div>
                <div class="stat-value">#<asp:Label ID="lblLeaderboardRank" runat="server">-</asp:Label></div>
                <div class="stat-label">Leaderboard Rank</div>
                <div class="stat-sub"><asp:Label ID="lblRankPercentile" runat="server"></asp:Label></div>
            </div>
        </div>

        <!-- Dashboard 2-Column Grid -->
        <div class="dashboard-grid">
            <!-- Left: My Courses -->
            <div class="dashboard-main">
                <div class="section-header">
                    <h2>My Courses</h2>
                    <a href="LearningCourse.aspx" class="browse-link">Browse more <i class="fas fa-chevron-right"></i></a>
                </div>

                <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="empty-state">
                    <i class="fas fa-graduation-cap"></i>
                    <h3>No Courses Yet</h3>
                    <p>Start your first aid journey by enrolling in a course!</p>
                    <a href="LearningCourse.aspx" class="btn-action btn-continue-learning" style="display:inline-block; margin-top:16px;">Browse Courses</a>
                </asp:Panel>

                <div class="my-courses-list">
                    <asp:Repeater ID="rptEnrolledCourses" runat="server">
                        <ItemTemplate>
                            <div class="my-course-item">
                                <div class="course-thumb">
                                    <img src='<%# ResolveUrl("~/" + Eval("PhotoPath").ToString().TrimStart('~','/')) %>' alt='Course'
                                         onerror="this.onerror=null;this.src='image/Logo.jpeg';" />
                                </div>
                                <div class="course-info">
                                    <h4><%# Eval("CourseName") %></h4>
                                    <div class="course-author"><%# Eval("InstructorName") != DBNull.Value && !string.IsNullOrEmpty(Eval("InstructorName").ToString()) ? Eval("InstructorName") : "Aidcademy" %></div>
                                    <div class="course-progress-row">
                                        <span class="course-progress-text"><%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %> lessons</span>
                                        <div class="progress-track">
                                            <div class="progress-fill" data-progress='<%# Eval("ProgressPercentage", "{0:F0}") %>' style="width:0;"></div>
                                        </div>
                                        <span class="progress-pct"><%# Eval("ProgressPercentage", "{0:F0}") %>%</span>
                                    </div>
                                </div>
                                <a href='<%# GetContinueUrl(Eval("NextLessonID")) %>' class="play-btn">
                                    <i class="fas fa-play"></i>
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Recently Completed -->
                <asp:Panel ID="pnlCompletedSection" runat="server" Visible="false">
                    <div class="section-header" style="margin-top:30px;">
                        <h2>Recently Completed</h2>
                    </div>
                    <div class="my-courses-list">
                        <asp:Repeater ID="rptCompletedCourses" runat="server">
                            <ItemTemplate>
                                <div class="my-course-item" style="border-color:#bbf7d0;">
                                    <div class="course-thumb" style="background:#dcfce7;">
                                        <i class="fas fa-check-circle" style="color:#22c55e; font-size:1.5rem;"></i>
                                    </div>
                                    <div class="course-info">
                                        <h4><%# Eval("CourseName") %></h4>
                                        <div class="course-author" style="color:#16a34a;">
                                            <i class="fas fa-check me-1"></i>Completed on <%# Convert.ToDateTime(Eval("EnrollmentDate")).ToString("MMM dd, yyyy") %>
                                        </div>
                                    </div>
                                    <a href="LearningProgress.aspx" class="play-btn" style="background:#dcfce7; color:#22c55e;">
                                        <i class="fas fa-arrow-right"></i>
                                    </a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </div>

            <!-- Right Sidebar Widgets -->
            <div class="dashboard-sidebar">
                <!-- Weekly Streak -->
                <div class="streak-widget">
                    <h3><i class="fas fa-fire" style="color:#f97316;"></i> Weekly Streak</h3>
                    <div class="streak-days">
                        <asp:Literal ID="litStreakDays" runat="server"></asp:Literal>
                    </div>
                    <p class="streak-prompt">Answer a daily quiz to keep your streak alive!</p>
                </div>

                <!-- Learning Progress -->
                <div class="progress-widget">
                    <h3><i class="fas fa-chart-line"></i> Learning Progress</h3>
                    <div class="progress-stat">
                        <span class="label">Overall Progress</span>
                        <span class="value"><asp:Label ID="lblOverallProgress" runat="server">0</asp:Label>%</span>
                    </div>
                    <div class="progress-stat">
                        <span class="label">Quizzes Passed</span>
                        <span class="value"><asp:Label ID="lblQuizzesPassed" runat="server">0/0</asp:Label></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- Leaderboard Section -->
        <div class="leaderboard-section">
            <div class="section-header">
                <h2><i class="fas fa-trophy" style="color:#f59e0b;"></i> Leaderboard</h2>
            </div>

            <!-- Podium -->
            <asp:Panel ID="pnlPodium" runat="server">
                <div class="podium-container">
                    <asp:Literal ID="litPodium" runat="server"></asp:Literal>
                </div>
            </asp:Panel>

            <!-- Leaderboard Table -->
            <div class="lb-table">
                <div class="lb-table-header">
                    <div>RANK</div>
                    <div>LEARNER</div>
                    <div>POINTS</div>
                    <div>STREAK</div>
                    <div>COURSES</div>
                </div>
                <asp:Repeater ID="rptLeaderboard" runat="server">
                    <ItemTemplate>
                        <div class='lb-table-row <%# Convert.ToInt32(Eval("UserID")) == Convert.ToInt32(Session["UserID"] ?? 0) ? "me-row" : "" %>'>
                            <div class="lb-rank-num">#<%# Container.ItemIndex + 4 %></div>
                            <div class="lb-learner">
                                <div class='lb-avatar <%# GetAvatarColor(Container.ItemIndex) %>'>
                                    <%# (Eval("FullName").ToString() + "?").Substring(0,1).ToUpper() %>
                                </div>
                                <span class="lb-name">
                                    <%# Eval("FullName") %>
                                    <%# Convert.ToInt32(Eval("UserID")) == Convert.ToInt32(Session["UserID"] ?? 0) ? "<span class='badge bg-warning text-dark ms-1' style='font-size:0.7rem;'>YOU</span>" : "" %>
                                </span>
                            </div>
                            <div class="lb-points"><strong><%# Eval("TotalPoints") %></strong> <span>pts</span></div>
                            <div class="lb-streak"><i class="fas fa-fire"></i> <%# Eval("DailyStreak") %></div>
                            <div class="lb-courses-count"><%# Eval("CourseCount") %></div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlEmptyLeaderboard" runat="server" Visible="false" CssClass="empty-state" Style="margin-top:20px;">
                <i class="fas fa-trophy"></i>
                <p>No scores yet - complete a quiz to appear on the leaderboard!</p>
            </asp:Panel>
        </div>

    </div>
</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.progress-fill[data-progress]').forEach(function (bar) {
                var pct = parseInt(bar.getAttribute('data-progress') || '0', 10);
                if (isNaN(pct)) pct = 0;
                if (pct < 0) pct = 0;
                if (pct > 100) pct = 100;
                setTimeout(function () { bar.style.width = pct + '%'; }, 100);
            });
        });
    </script>
</asp:Content>
