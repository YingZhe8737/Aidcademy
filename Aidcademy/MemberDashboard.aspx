<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" Inherits="Aidcademy.MemberDashboard" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard — Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        /* ── Nunito already loaded by Member.Master — just dashboard component CSS ── */
        :root {
            --red: #c9242b;
            --red-dark: #a01c22;
            --red-light: #fde8e9;
            --cream: #FFFBF1;
            --dark: #1a1a2e;
        }

        /* ── Page header ── */
        .page-header {
            margin-bottom: 28px;
        }

            .page-header h2 {
                font-size: 1.65rem;
                font-weight: 900;
                color: var(--dark);
                margin-bottom: 4px;
                font-family: 'Nunito', sans-serif;
            }

            .page-header p {
                font-size: 0.92rem;
                color: #888;
                font-weight: 600;
                margin: 0;
            }

        /* ── Stat strip ── */
        .stats-row {
            display: grid;
            grid-template-columns: repeat(4,1fr);
            gap: 16px;
            margin-bottom: 32px;
        }

        @media(max-width:1100px) {
            .stats-row {
                grid-template-columns: repeat(2,1fr);
            }
        }

        @media(max-width:600px) {
            .stats-row {
                grid-template-columns: 1fr;
            }
        }

        .stat-card {
            background: white;
            border-radius: 16px;
            padding: 22px 20px;
            border: 1px solid #ebebeb;
            display: flex;
            align-items: center;
            gap: 16px;
            transition: transform 0.2s, box-shadow 0.2s;
            position: relative;
            overflow: hidden;
        }

            .stat-card::before {
                content: '';
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                height: 4px;
            }

            .stat-card.c-red::before {
                background: var(--red);
            }

            .stat-card.c-orange::before {
                background: #f97316;
            }

            .stat-card.c-purple::before {
                background: #8b5cf6;
            }

            .stat-card.c-gold::before {
                background: #f59e0b;
            }

            .stat-card:hover {
                transform: translateY(-4px);
                box-shadow: 0 12px 32px rgba(0,0,0,0.08);
            }

        .stat-icon {
            width: 50px;
            height: 50px;
            border-radius: 13px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            flex-shrink: 0;
        }

        .c-red .stat-icon {
            background: var(--red-light);
            color: var(--red);
        }

        .c-orange .stat-icon {
            background: #fff7ed;
            color: #f97316;
        }

        .c-purple .stat-icon {
            background: #ede9fe;
            color: #7c3aed;
        }

        .c-gold .stat-icon {
            background: #fffbeb;
            color: #d97706;
        }

        .stat-value {
            font-size: 1.9rem;
            font-weight: 900;
            color: var(--dark);
            line-height: 1;
            font-family: 'Nunito', sans-serif;
        }

        .stat-label {
            font-size: 0.78rem;
            font-weight: 700;
            color: #aaa;
            margin-top: 4px;
            font-family: 'Nunito', sans-serif;
        }

        .stat-sub {
            font-size: 0.78rem;
            color: #bbb;
            font-weight: 600;
            margin-top: 3px;
            font-family: 'Nunito', sans-serif;
        }

        /* ── Two-col layout ── */
        .dashboard-grid {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 20px;
            margin-bottom: 32px;
        }

        @media(max-width:1200px) {
            .dashboard-grid {
                grid-template-columns: 1fr;
            }
        }

        /* ── Section cards ── */
        .section-card {
            background: white;
            border-radius: 16px;
            border: 1px solid #ebebeb;
            overflow: hidden;
        }

        .section-card-head {
            padding: 18px 22px;
            border-bottom: 1px solid #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .section-card-title {
            font-size: 1rem;
            font-weight: 900;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .section-card-title i {
                color: var(--red);
            }

        .section-card-body {
            padding: 0;
        }

        .browse-link {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--red);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 4px;
        }

            .browse-link:hover {
                color: var(--red-dark);
            }

        /* ── Course items ── */
        .my-course-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 16px 20px;
            border-bottom: 1px solid #f5f5f5;
            transition: background 0.15s;
        }

            .my-course-item:last-child {
                border-bottom: none;
            }

            .my-course-item:hover {
                background: #fafafa;
            }

        .course-thumb {
            width: 60px;
            height: 60px;
            border-radius: 12px;
            overflow: hidden;
            flex-shrink: 0;
            background: #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: center;
        }

            .course-thumb img {
                width: 100%;
                height: 100%;
                object-fit: cover;
            }

        .course-info {
            flex: 1;
            min-width: 0;
        }

            .course-info h4 {
                font-size: 0.95rem;
                font-weight: 800;
                color: var(--dark);
                margin: 0 0 3px;
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
            }

        .course-author {
            font-size: 0.78rem;
            color: #aaa;
            font-weight: 600;
            margin-bottom: 8px;
        }

        .progress-row {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .progress-text {
            font-size: 0.75rem;
            font-weight: 700;
            color: #888;
            white-space: nowrap;
        }

        .progress-track {
            flex: 1;
            height: 6px;
            background: #f0f0f0;
            border-radius: 3px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            background: var(--red);
            border-radius: 3px;
            transition: width 0.8s ease;
        }

        .progress-pct {
            font-size: 0.75rem;
            font-weight: 800;
            color: var(--red);
            white-space: nowrap;
        }

        .play-btn {
            width: 38px;
            height: 38px;
            border-radius: 50%;
            background: var(--red-light);
            color: var(--red);
            display: flex;
            align-items: center;
            justify-content: center;
            text-decoration: none;
            flex-shrink: 0;
            transition: all 0.18s;
            font-size: 0.85rem;
        }

            .play-btn:hover {
                background: var(--red);
                color: white;
                transform: scale(1.08);
            }

        .my-course-item.completed .course-thumb {
            background: #d1fae5;
        }

        .my-course-item.completed .play-btn {
            background: #d1fae5;
            color: #059669;
        }

            .my-course-item.completed .play-btn:hover {
                background: #059669;
                color: white;
            }

        .empty-state {
            text-align: center;
            padding: 48px 24px;
        }

            .empty-state i {
                font-size: 2.5rem;
                color: #e0e0e0;
                margin-bottom: 14px;
                display: block;
            }

            .empty-state h3 {
                font-size: 1.1rem;
                font-weight: 800;
                color: #999;
                margin-bottom: 6px;
            }

            .empty-state p {
                font-size: 0.88rem;
                color: #bbb;
                margin-bottom: 18px;
            }

        .btn-browse {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            background: var(--red);
            color: white;
            border: none;
            font-family: 'Nunito', sans-serif;
            font-size: 0.88rem;
            font-weight: 800;
            padding: 10px 22px;
            border-radius: 10px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.18s;
        }

            .btn-browse:hover {
                background: var(--red-dark);
                color: white;
                transform: translateY(-1px);
            }

        /* ── Widgets ── */
        .widget-stack {
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .widget-card {
            background: white;
            border-radius: 16px;
            border: 1px solid #ebebeb;
            overflow: hidden;
        }

        .widget-head {
            padding: 16px 18px;
            border-bottom: 1px solid #f5f5f5;
            font-size: 0.95rem;
            font-weight: 900;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .widget-head i {
                color: var(--red);
            }

        .widget-body {
            padding: 16px 18px;
        }

        /* ── Weekly Streak — 2 rows (grid 4 cols) ── */
        .streak-days {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 6px;
            margin-bottom: 10px;
        }

        .streak-day {
            border-radius: 8px;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 2px;
            padding: 7px 0;
            font-size: 0.6rem;
            font-weight: 800;
            text-transform: uppercase;
            border: 1.5px solid #e0e0e0;
            color: #ccc;
            background: white;
        }

            .streak-day i {
                font-size: 0.85rem;
            }

            .streak-day.active {
                background: var(--red);
                color: white;
                border-color: var(--red);
            }

            .streak-day.done {
                background: #d1fae5;
                color: #059669;
                border-color: #a7f3d0;
            }

        .streak-prompt {
            font-size: 0.8rem;
            color: #bbb;
            font-weight: 600;
            margin: 0;
        }

        /* ── Progress widget ── */
        .progress-stat {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 14px;
        }

            .progress-stat:last-child {
                margin-bottom: 0;
            }

        .progress-stat-label {
            font-size: 0.82rem;
            font-weight: 700;
            color: #888;
        }

        .progress-stat-value {
            font-size: 0.92rem;
            font-weight: 900;
            color: var(--dark);
        }

        .mini-bar-track {
            width: 100%;
            height: 7px;
            background: #f0f0f0;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 6px;
        }

        .mini-bar-fill {
            height: 100%;
            border-radius: 4px;
            background: var(--red);
            transition: width 1s ease;
        }

        /* ── Leaderboard ── */
        .leaderboard-section {
            background: white;
            border-radius: 16px;
            border: 1px solid #ebebeb;
            overflow: hidden;
        }

        .lb-header {
            padding: 18px 22px;
            border-bottom: 1px solid #f5f5f5;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .lb-title {
            font-size: 1rem;
            font-weight: 900;
            color: var(--dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }

            .lb-title i {
                color: #f59e0b;
            }

        .podium-wrap {
            padding: 28px 22px 0;
        }

        .podium-container {
            display: flex;
            justify-content: center;
            align-items: flex-end;
            gap: 16px;
        }

        .podium-item {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }

        .podium-avatar {
            width: 52px;
            height: 52px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            font-weight: 900;
            color: white;
            border: 3px solid white;
            box-shadow: 0 4px 16px rgba(0,0,0,0.15);
        }

            .podium-avatar.gold {
                background: linear-gradient(135deg,#f59e0b,#d97706);
            }

            .podium-avatar.silver {
                background: linear-gradient(135deg,#9ca3af,#6b7280);
            }

            .podium-avatar.bronze {
                background: linear-gradient(135deg,#f97316,#c2410c);
            }

        .podium-name {
            font-size: 0.76rem;
            font-weight: 800;
            color: var(--dark);
            text-align: center;
            max-width: 80px;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .podium-pts {
            font-size: 0.7rem;
            font-weight: 700;
            color: #999;
        }

        .podium-bar {
            border-radius: 10px 10px 0 0;
            width: 72px;
            display: flex;
            align-items: flex-start;
            justify-content: center;
            padding-top: 10px;
        }

            .podium-bar.gold {
                height: 96px;
                background: linear-gradient(180deg,#fef3c7,#fde68a);
            }

            .podium-bar.silver {
                height: 68px;
                background: linear-gradient(180deg,#f3f4f6,#e5e7eb);
            }

            .podium-bar.bronze {
                height: 50px;
                background: linear-gradient(180deg,#fff7ed,#fed7aa);
            }

        .podium-medal {
            font-size: 1.5rem;
        }

        .lb-table {
            width: 100%;
        }

        .lb-table-head {
            display: grid;
            grid-template-columns: 48px 1fr 88px 64px 60px;
            padding: 10px 20px;
            background: #f9f9f9;
            font-size: 0.68rem;
            font-weight: 800;
            color: #aaa;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-top: 1px solid #f0f0f0;
        }

        .lb-table-row {
            display: grid;
            grid-template-columns: 48px 1fr 88px 64px 60px;
            padding: 11px 20px;
            border-top: 1px solid #f5f5f5;
            align-items: center;
            transition: background 0.15s;
        }

            .lb-table-row:hover {
                background: #fafafa;
            }

            .lb-table-row.me-row {
                background: var(--red-light);
            }

        .lb-rank-num {
            font-size: 0.85rem;
            font-weight: 900;
            color: #888;
        }

        .lb-learner {
            display: flex;
            align-items: center;
            gap: 8px;
            overflow: hidden;
        }

        .lb-avatar {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.82rem;
            font-weight: 800;
            color: white;
            flex-shrink: 0;
        }

        .lb-av-red {
            background: var(--red);
        }

        .lb-av-blue {
            background: #3b82f6;
        }

        .lb-av-green {
            background: #10b981;
        }

        .lb-av-amber {
            background: #f59e0b;
        }

        .lb-av-purple {
            background: #8b5cf6;
        }

        .lb-name {
            font-size: 0.85rem;
            font-weight: 700;
            color: var(--dark);
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .lb-points {
            font-size: 0.85rem;
            font-weight: 900;
            color: var(--dark);
        }

            .lb-points span {
                font-size: 0.7rem;
                color: #aaa;
                font-weight: 600;
            }

        .lb-streak i {
            color: #f97316;
            margin-right: 3px;
        }

        .lb-streak {
            font-size: 0.8rem;
            font-weight: 700;
            color: #555;
        }

        .lb-courses-count {
            font-size: 0.8rem;
            font-weight: 700;
            color: #888;
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- PAGE HEADER -->
    <div class="page-header">
        <h2>Welcome back,
            <asp:Label ID="lblMemberName" runat="server"></asp:Label>! 👋</h2>
        <p>Keep up the great work on your learning journey.</p>
    </div>

    <!-- STAT CARDS -->
    <div class="stats-row">
        <div class="stat-card c-red">
            <div class="stat-icon"><i class="fa-solid fa-book-open"></i></div>
            <div>
                <div class="stat-value">
                    <asp:Label ID="lblEnrolledCourses" runat="server">0</asp:Label>
                </div>
                <div class="stat-label">Courses Enrolled</div>
                <div class="stat-sub">
                    <asp:Label ID="lblCompletedCourses" runat="server">0</asp:Label>
                    completed
                </div>
            </div>
        </div>
        <div class="stat-card c-orange">
            <div class="stat-icon"><i class="fa-solid fa-fire"></i></div>
            <div>
                <div class="stat-value">
                    <asp:Label ID="lblDailyStreak" runat="server">0</asp:Label>
                </div>
                <div class="stat-label">Day Streak</div>
                <div class="stat-sub">
                    Best:
                    <asp:Label ID="lblPersonalBest" runat="server">0</asp:Label>
                </div>
            </div>
        </div>
        <div class="stat-card c-purple">
            <div class="stat-icon"><i class="fa-solid fa-medal"></i></div>
            <div>
                <div class="stat-value">
                    <asp:Label ID="lblTotalPoints" runat="server">0</asp:Label>
                </div>
                <div class="stat-label">Points Earned</div>
                <div class="stat-sub">
                    +<asp:Label ID="lblMonthlyPoints" runat="server">0</asp:Label>
                    this month
                </div>
            </div>
        </div>
        <div class="stat-card c-gold">
            <div class="stat-icon"><i class="fa-solid fa-trophy"></i></div>
            <div>
                <div class="stat-value">#<asp:Label ID="lblLeaderboardRank" runat="server">-</asp:Label></div>
                <div class="stat-label">Leaderboard Rank</div>
                <div class="stat-sub">
                    <asp:Label ID="lblRankPercentile" runat="server"></asp:Label>
                </div>
            </div>
        </div>
    </div>

    <!-- TWO-COLUMN GRID -->
    <div class="dashboard-grid">

        <!-- LEFT: My Courses -->
        <div>
            <div class="section-card">
                <div class="section-card-head">
                    <div class="section-card-title"><i class="fa-solid fa-book-open"></i>My Courses</div>
                    <a href="LearningCourse.aspx" class="browse-link">Browse more <i class="fa-solid fa-chevron-right"></i></a>
                </div>
                <div class="section-card-body">

                    <asp:Panel ID="pnlNoCourses" runat="server" Visible="false">
                        <div class="empty-state">
                            <i class="fa-solid fa-graduation-cap"></i>
                            <h3>No Courses Yet</h3>
                            <p>Start your first aid journey by enrolling in a course!</p>
                            <a href="LearningCourse.aspx" class="btn-browse"><i class="fa-solid fa-search"></i>Browse Courses</a>
                        </div>
                    </asp:Panel>

                    <asp:Repeater ID="rptEnrolledCourses" runat="server">
                        <ItemTemplate>
                            <div class="my-course-item">
                                <div class="course-thumb">
                                    <img src='<%# ResolveUrl("~/" + Eval("PhotoPath").ToString().TrimStart('~','/')) %>'
                                        alt="Course" onerror="this.onerror=null;this.src='image/Logo.jpeg';" />
                                </div>
                                <div class="course-info">
                                    <h4><%# Eval("CourseName") %></h4>
                                    <div class="course-author">
                                        <i class="fa-solid fa-chalkboard-user" style="margin-right: 4px; color: #c9242b;"></i>
                                        <%# Eval("InstructorName") != DBNull.Value && !string.IsNullOrEmpty(Eval("InstructorName").ToString()) ? Eval("InstructorName") : "Aidcademy" %>
                                    </div>
                                    <div class="progress-row">
                                        <span class="progress-text"><%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %></span>
                                        <div class="progress-track">
                                            <div class="progress-fill" data-progress='<%# Eval("ProgressPercentage", "{0:F0}") %>' style="width: 0;"></div>
                                        </div>
                                        <span class="progress-pct"><%# Eval("ProgressPercentage", "{0:F0}") %>%</span>
                                    </div>
                                </div>
                                <a href='<%# GetContinueUrl(Eval("NextLessonID")) %>' class="play-btn" title="Continue">
                                    <i class="fa-solid fa-play"></i>
                                </a>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Recently Completed -->
            <asp:Panel ID="pnlCompletedSection" runat="server" Visible="false">
                <div class="section-card" style="margin-top: 16px;">
                    <div class="section-card-head">
                        <div class="section-card-title"><i class="fa-solid fa-circle-check" style="color: #10b981;"></i>Recently Completed</div>
                    </div>
                    <div class="section-card-body">
                        <asp:Repeater ID="rptCompletedCourses" runat="server">
                            <ItemTemplate>
                                <div class="my-course-item completed">
                                    <div class="course-thumb">
                                        <i class="fa-solid fa-check-circle" style="color: #059669; font-size: 1.4rem;"></i>
                                    </div>
                                    <div class="course-info">
                                        <h4><%# Eval("CourseName") %></h4>
                                        <div class="course-author" style="color: #059669;">
                                            <i class="fa-solid fa-check" style="margin-right: 4px;"></i>
                                            Completed <%# Convert.ToDateTime(Eval("EnrollmentDate")).ToString("MMM dd, yyyy") %>
                                        </div>
                                    </div>
                                    <a href="LearningProgress.aspx" class="play-btn" title="View Progress">
                                        <i class="fa-solid fa-arrow-right"></i>
                                    </a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </asp:Panel>
        </div>

        <!-- RIGHT: Widgets -->
        <div class="widget-stack">

            <!-- Weekly Streak -->
            <div class="widget-card">
                <div class="widget-head"><i class="fa-solid fa-fire" style="color: #f97316;"></i>Weekly Streak</div>
                <div class="widget-body">
                    <div class="streak-days">
                        <asp:Literal ID="litStreakDays" runat="server"></asp:Literal>
                    </div>
                    <p class="streak-prompt">Answer a daily quiz to keep your streak alive!</p>
                </div>
            </div>

            <!-- Learning Progress -->
            <div class="widget-card">
                <div class="widget-head"><i class="fa-solid fa-chart-line"></i>Learning Progress</div>
                <div class="widget-body">
                    <div class="progress-stat">
                        <div>
                            <div class="progress-stat-label">Overall Progress</div>
                            <div class="mini-bar-track" style="width: 180px;">
                                <div class="mini-bar-fill" id="overallBar" style="width: 0%;"></div>
                            </div>
                        </div>
                        <div class="progress-stat-value">
                            <asp:Label ID="lblOverallProgress" runat="server">0</asp:Label>%
                        </div>
                    </div>
                    <div class="progress-stat">
                        <div class="progress-stat-label">Quizzes Passed</div>
                        <div class="progress-stat-value">
                            <asp:Label ID="lblQuizzesPassed" runat="server">0/0</asp:Label>
                        </div>
                    </div>
                    <div style="margin-top: 14px;">
                        <a href="LearningProgress.aspx" style="display: inline-flex; align-items: center; gap: 6px; font-size: 0.82rem; font-weight: 700; color: #c9242b; text-decoration: none;">View full progress <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- LEADERBOARD -->
    <div class="leaderboard-section">
        <div class="lb-header">
            <div class="lb-title"><i class="fa-solid fa-trophy"></i>Leaderboard</div>
        </div>

        <!-- Podium top-3 -->
        <asp:Panel ID="pnlPodium" runat="server">
            <div class="podium-wrap">
                <div class="podium-container">
                    <asp:Literal ID="litPodium" runat="server"></asp:Literal>
                </div>
            </div>
        </asp:Panel>

        <!-- Table rows 4+ -->
        <div class="lb-table-head">
            <div>Rank</div>
            <div>Learner</div>
            <div>Points</div>
            <div>Streak</div>
            <div>Courses</div>
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
                            <%# Convert.ToInt32(Eval("UserID")) == Convert.ToInt32(Session["UserID"] ?? 0)
                                ? "<span class='badge' style='background:#fde8e9;color:#c9242b;font-size:0.68rem;font-weight:800;padding:2px 8px;border-radius:10px;margin-left:4px;'>YOU</span>"
                                : "" %>
                        </span>
                    </div>
                    <div class="lb-points"><strong><%# Eval("TotalPoints") %></strong> <span>pts</span></div>
                    <div class="lb-streak"><i class="fa-solid fa-fire"></i><%# Eval("DailyStreak") %></div>
                    <div class="lb-courses-count"><%# Eval("CourseCount") %></div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmptyLeaderboard" runat="server" Visible="false">
            <div class="empty-state" style="padding: 32px 24px;">
                <i class="fa-solid fa-trophy"></i>
                <p>No scores yet — complete a quiz to appear on the leaderboard!</p>
            </div>
        </asp:Panel>
    </div>

    <%-- Hidden field for overall progress bar animation --%>
    <input type="hidden" id="hfOverallPct" value='<%# lblOverallProgress.Text %>' />
    <%-- Dummy label to avoid DataBind warning — lblUserInitial is no longer in markup but still bound in .cs --%>
    <asp:Label ID="lblUserInitial" runat="server" Style="display: none;"></asp:Label>

</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            // Course progress bars
            document.querySelectorAll('.progress-fill[data-progress]').forEach(function (bar) {
                var pct = parseInt(bar.getAttribute('data-progress') || '0', 10);
                if (isNaN(pct) || pct < 0) pct = 0;
                if (pct > 100) pct = 100;
                setTimeout(function () { bar.style.width = pct + '%'; }, 120);
            });

            // Overall progress mini-bar
            var hf = document.getElementById('hfOverallPct');
            if (hf) {
                var pct = parseInt(hf.value || '0', 10);
                if (!isNaN(pct)) {
                    setTimeout(function () {
                        var bar = document.getElementById('overallBar');
                        if (bar) bar.style.width = pct + '%';
                    }, 200);
                }
            }
        });
    </script>
</asp:Content>
