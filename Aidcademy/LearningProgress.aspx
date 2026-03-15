<%@ Page Title="My Progress" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="LearningProgress.aspx.cs" Inherits="Aidcademy.LearningProgress" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    My Progress - Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="lp-container">

        <!-- Page Header -->
        <div class="lp-page-header">
            <h1><i class="fas fa-chart-pie"></i> My Learning Progress</h1>
            <p>Track your journey through first aid courses</p>
        </div>

        <!-- ═══ Section A: Summary Stat Cards ═══ -->
        <div class="lp-stats-grid">
            <div class="lp-stat-card blue">
                <div class="lp-stat-icon"><i class="fas fa-book-open"></i></div>
                <div class="lp-stat-info">
                    <div class="lp-stat-value"><asp:Label ID="lblActiveCourses" runat="server" Text="0" /></div>
                    <div class="lp-stat-label">Courses Active</div>
                </div>
            </div>
            <div class="lp-stat-card green">
                <div class="lp-stat-icon"><i class="fas fa-check-circle"></i></div>
                <div class="lp-stat-info">
                    <div class="lp-stat-value"><asp:Label ID="lblLessonsDone" runat="server" Text="0" /></div>
                    <div class="lp-stat-label">Lessons Done</div>
                </div>
            </div>
            <div class="lp-stat-card purple">
                <div class="lp-stat-icon"><i class="fas fa-star-half-alt"></i></div>
                <div class="lp-stat-info">
                    <div class="lp-stat-value"><asp:Label ID="lblAvgScore" runat="server" Text="N/A" /></div>
                    <div class="lp-stat-label">Avg. Score</div>
                </div>
            </div>
            <div class="lp-stat-card orange">
                <div class="lp-stat-icon"><i class="fas fa-trophy"></i></div>
                <div class="lp-stat-info">
                    <div class="lp-stat-value"><asp:Label ID="lblCompletedCourses" runat="server" Text="0" /></div>
                    <div class="lp-stat-label">Completed</div>
                </div>
            </div>
        </div>

        <!-- ═══ Section B: Course Completion Cards ═══ -->
        <div class="lp-section-title"><i class="fas fa-graduation-cap me-2"></i>Course Progress</div>

        <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="lp-empty-state">
            <i class="fas fa-book"></i>
            <h3>No Enrolled Courses Yet</h3>
            <p>Start learning by enrolling in a course</p>
            <a href="LearningCourse.aspx" class="btn-action btn-continue-learning" style="display:inline-block; margin-top:16px;">Browse Courses</a>
        </asp:Panel>

        <asp:Repeater ID="rptCourses" runat="server">
            <ItemTemplate>
                <div class='lp-course-card <%# Eval("Status").ToString() == "Completed" ? "completed" : "" %>'>
                    <div class="lp-course-thumb">
                        <img src='<%# GetThumbnailUrl(Eval("ThumbnailPath")) %>' alt='<%# Eval("CourseName") %>' />
                    </div>
                    <div class="lp-course-body">
                        <div class="lp-course-top">
                            <div class="lp-course-info">
                                <h4><%# Eval("CourseName") %></h4>
                                <span class="lp-course-lessons">
                                    <i class="fas fa-layer-group me-1"></i><%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %> lessons
                                </span>
                                <%# Convert.ToInt32(Eval("AvgQuizScore")) != -1
                                    ? "<span class='lp-course-quiz'><i class='fas fa-pen me-1'></i>Quiz avg: " + Eval("AvgQuizScore", "{0:F0}") + " XP</span>"
                                    : "" %>
                            </div>
                            <div class="lp-course-ring-wrap">
                                <div class="lp-course-ring" data-pct='<%# Eval("ProgressPercentage", "{0:F0}") %>'>
                                    <svg viewBox="0 0 36 36">
                                        <path class="lp-ring-bg" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"/>
                                        <path class="lp-ring-fill" stroke-dasharray="<%# Eval("ProgressPercentage", "{0:F0}") %>, 100" d="M18 2.0845 a 15.9155 15.9155 0 0 1 0 31.831 a 15.9155 15.9155 0 0 1 0 -31.831"/>
                                    </svg>
                                    <span class="lp-ring-text"><%# Eval("ProgressPercentage", "{0:F0}") %>%</span>
                                </div>
                            </div>
                        </div>
                        <div class="lp-course-bar-wrap">
                            <div class="lp-course-bar-track">
                                <div class="lp-course-bar-fill" data-progress='<%# Eval("ProgressPercentage", "{0:F0}") %>' style="width:0;"></div>
                            </div>
                        </div>
                        <div class="lp-course-bottom">
                            <span class='lp-status-badge <%# Eval("Status").ToString() == "Completed" ? "badge-completed" : "badge-progress" %>'>
                                <%# Eval("Status").ToString() == "Completed" ? "<i class='fas fa-check-circle me-1'></i>" : "<i class='fas fa-spinner me-1'></i>" %><%# Eval("Status") %>
                            </span>
                            <%# Eval("CompletionDate") != DBNull.Value
                                ? "<span class='lp-completion-date'><i class='fas fa-calendar-check me-1'></i>Completed " + Convert.ToDateTime(Eval("CompletionDate")).ToString("MMM dd, yyyy") + "</span>"
                                : "" %>
                            <a href='<%# Eval("Status").ToString() != "Completed" ? GetContinueUrl(Eval("NextLessonID")) : ResolveUrl("~/LearningCourse.aspx") %>'
                               class='lp-course-action <%# Eval("Status").ToString() == "Completed" ? "browse" : "" %>'>
                                <%# Eval("Status").ToString() != "Completed"
                                    ? "Continue <i class='fas fa-arrow-right ms-1'></i>"
                                    : "Browse More <i class='fas fa-book ms-1'></i>" %>
                            </a>
                        </div>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <!-- ═══ Section C: Quiz History + Activity Heatmap ═══ -->
        <div class="lp-two-col">

            <!-- Left: Quiz History -->
            <div class="lp-panel">
                <div class="lp-panel-header">
                    <h5><i class="fas fa-history me-2"></i>Recent Quiz Results</h5>
                </div>
                <asp:Panel ID="pnlNoQuizzes" runat="server" Visible="false">
                    <div class="lp-empty-mini"><i class="fas fa-pen"></i> No quizzes taken yet.</div>
                </asp:Panel>
                <asp:Repeater ID="rptQuizHistory" runat="server">
                    <ItemTemplate>
                        <div class="lp-quiz-row">
                            <div class="lp-quiz-score-ring">
                                <span><%# GetScorePercent(Eval("Score"), Eval("TotalMarks")) %>%</span>
                            </div>
                            <div class="lp-quiz-details">
                                <div class="lp-quiz-lesson"><%# Eval("LessonName") %></div>
                                <div class="lp-quiz-course"><%# Eval("CourseName") %></div>
                                <div class="lp-quiz-date"><%# Eval("DateTaken", "{0:MMM dd, yyyy}") %></div>
                            </div>
                            <div class="lp-quiz-badge-wrap">
                                <%# GetQuizBadge(Eval("Score"), Eval("TotalMarks")) %>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Right: Activity Heatmap -->
            <div class="lp-panel">
                <div class="lp-panel-header">
                    <h5><i class="fas fa-fire me-2"></i>Activity</h5>
                    <div class="lp-streak-badge">
                        <i class="fas fa-fire-alt"></i>
                        <asp:Label ID="lblStreak" runat="server" Text="0" /> day streak
                    </div>
                </div>
                <div class="lp-heatmap-wrap">
                    <asp:Literal ID="litHeatmap" runat="server" />
                </div>
                <div class="lp-heatmap-legend">
                    <span>Less</span>
                    <div class="lp-hm-cell"></div>
                    <div class="lp-hm-cell active"></div>
                    <span>More</span>
                </div>
            </div>
        </div>

        <!-- ═══ Section D: XP & Level Banner ═══ -->
        <div class="lp-xp-banner">
            <div class="lp-xp-left">
                <div class="lp-xp-level-circle">
                    <span>Lv</span>
                    <strong><asp:Label ID="lblLevel" runat="server" Text="1" /></strong>
                </div>
                <div class="lp-xp-info">
                    <h4><asp:Label ID="lblLevelTitle" runat="server" Text="Beginner" /></h4>
                    <p><asp:Label ID="lblTotalXP" runat="server" Text="0" /> XP earned</p>
                </div>
            </div>
            <div class="lp-xp-right">
                <div class="lp-xp-bar-label">
                    <span><asp:Label ID="lblXpToNext" runat="server" Text="500" /> XP to next level</span>
                </div>
                <div class="lp-xp-bar-track">
                    <div class="lp-xp-bar-fill" id="xpBarFill" runat="server"></div>
                </div>
                <asp:Label ID="lblXpPct" runat="server" Text="0" CssClass="d-none" />
            </div>
        </div>

    </div>
</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Animate progress bars
            document.querySelectorAll('.lp-course-bar-fill').forEach(function (bar) {
                var pct = parseInt(bar.getAttribute('data-progress') || '0', 10);
                if (pct < 0) pct = 0;
                if (pct > 100) pct = 100;
                setTimeout(function () { bar.style.width = pct + '%'; }, 150);
            });

            // Animate XP bar
            var xpFill = document.getElementById('<%= xpBarFill.ClientID %>');
            if (xpFill) {
                var xpPct = xpFill.style.width || '0%';
                xpFill.style.width = '0%';
                setTimeout(function () { xpFill.style.width = xpPct; }, 300);
            }
        });
    </script>
</asp:Content>
