<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" Inherits="Aidcademy.MemberDashboard" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    Member Dashboard - Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .container { max-width: 1200px; margin: 30px auto; padding: 0 20px; }
        .welcome-section { background: white; border-radius: 15px; padding: 30px; margin-bottom: 30px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .welcome-header { display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px; }
        .user-info h1 { color: #333; font-size: 28px; margin-bottom: 5px; }
        .user-info p { color: #666; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-top: 20px; }
        .stat-card { background: linear-gradient(to right, #dc2626, #b91c1c); color: white; padding: 20px; border-radius: 10px; text-align: center; }
        .stat-card i { font-size: 32px; margin-bottom: 10px; }
        .stat-card h3 { font-size: 28px; margin-bottom: 5px; }
        .stat-card p { font-size: 14px; opacity: 0.9; }
        .section-title { color: #333; font-size: 22px; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 3px solid #dc2626; }
        .course-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .course-card { background: white; border-radius: 10px; overflow: hidden; box-shadow: 0 2px 10px rgba(0,0,0,0.1); transition: transform 0.3s, box-shadow 0.3s; }
        .course-card:hover { transform: translateY(-5px); box-shadow: 0 5px 20px rgba(0,0,0,0.15); }
        .course-image { width: 100%; height: 180px; background: linear-gradient(to right, #dc2626, #b91c1c); display: flex; align-items: center; justify-content: center; color: white; font-size: 48px; overflow: hidden; }
        .course-image img { width: 100%; height: 100%; object-fit: cover; }
        .course-content { padding: 20px; }
        .course-title { color: #333; font-size: 18px; font-weight: 600; margin-bottom: 10px; }
        .progress-bar-bg { background: #e0e0e0; height: 8px; border-radius: 4px; overflow: hidden; margin: 10px 0; }
        .progress-fill { background: linear-gradient(90deg, #dc2626 0%, #b91c1c 100%); height: 100%; transition: width 0.3s; }
        .course-footer { display: flex; justify-content: space-between; align-items: center; margin-top: 15px; }
        .btn-continue { padding: 10px 20px; border-radius: 5px; text-decoration: none; font-weight: 500; background: linear-gradient(to right, #dc2626, #b91c1c); color: white; display: inline-block; border: none; cursor: pointer; transition: all 0.3s; }
        .btn-continue:hover { transform: translateY(-2px); color: white; }
        .empty-state { text-align: center; padding: 40px; color: #666; background: white; border-radius: 10px; }
        .empty-state i { font-size: 64px; color: #ddd; display: block; margin-bottom: 20px; }

        /* Leaderboard (nice cards) */
        .leaderboard-card { background: white; border-radius: 14px; box-shadow: 0 4px 18px rgba(0,0,0,0.08); overflow: hidden; margin-top: 10px; }
        .lb-header { background: linear-gradient(to right, #dc2626, #b91c1c); color: white; padding: 16px 24px; font-size: 1rem; font-weight: 700; display: flex; justify-content: space-between; align-items: center; }
        .lb-row { display: grid; grid-template-columns: 52px 1fr 1fr 120px; align-items: center; padding: 14px 20px; border-bottom: 1px solid #f3f3f3; transition: background 0.15s; gap: 10px; }
        .lb-row:last-child { border-bottom: none; }
        .lb-row:hover { background: #fff8f8; }
        .lb-row.me-row { background: #fff3cd; font-weight: 700; }
        .lb-row.podium-gold { background: linear-gradient(90deg, #fff8cc 0%, #ffe89a 100%); border-left: 6px solid #f59e0b; }
        .lb-row.podium-silver { background: linear-gradient(90deg, #f6f8fb 0%, #e5ebf2 100%); border-left: 6px solid #94a3b8; }
        .lb-row.podium-bronze { background: linear-gradient(90deg, #fff2e8 0%, #ffd8bf 100%); border-left: 6px solid #b45309; }
        .lb-row.podium-gold:hover { background: linear-gradient(90deg, #fff4b8 0%, #ffdf80 100%); }
        .lb-row.podium-silver:hover { background: linear-gradient(90deg, #eef2f7 0%, #d8e1eb 100%); }
        .lb-row.podium-bronze:hover { background: linear-gradient(90deg, #ffe8d7 0%, #ffcfae 100%); }
        .lb-rank { font-size: 1.3rem; font-weight: 800; text-align: center; }
        .rank-gold   { color: #f59e0b; }
        .rank-silver { color: #94a3b8; }
        .rank-bronze { color: #b45309; }
        .rank-other  { color: #999; }
        .lb-avatar { width: 38px; height: 38px; border-radius: 50%; background: linear-gradient(135deg,#dc2626,#fca5a5); color: white; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 1rem; flex-shrink: 0; }
        .lb-name { display: flex; align-items: center; gap: 10px; font-weight: 600; color: #222; }
        .lb-pts { text-align: right; }
        .lb-weekly { color: #16a34a; font-weight: 700; font-size: 0.9rem; }
        .lb-total  { color: #c9242b; font-weight: 800; font-size: 1.05rem; }
        .lb-date   { color: #888; font-size: 0.8rem; margin-top: 2px; }

        @media (max-width: 768px) {
            .welcome-header { flex-direction: column; align-items: flex-start; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
            .course-grid { grid-template-columns: 1fr; }
            .lb-row { grid-template-columns: 42px 1fr 80px; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <!-- Welcome Section -->
        <div class="welcome-section">
            <div class="welcome-header">
                <div class="user-info">
                    <h1>Welcome back, <asp:Label ID="lblMemberName" runat="server"></asp:Label>!</h1>
                    <p>Continue your first aid learning journey</p>
                </div>
            </div>

            <div class="stats-grid">
                <div class="stat-card">
                    <i class="fas fa-fire" style="color: orange;"></i>
                    <h3><asp:Label ID="lblDailyStreak" runat="server">0</asp:Label></h3>
                    <p>Day Streak</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-trophy" style="color: yellow;"></i>
                    <h3>
                        <asp:Label ID="lblTotalPoints" runat="server">0</asp:Label>
                        <asp:Label ID="lblBadge" runat="server"></asp:Label>
                    </h3>
                    <p>Total Points</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-book"></i>
                    <h3><asp:Label ID="lblEnrolledCourses" runat="server">0</asp:Label></h3>
                    <p>Enrolled Courses</p>
                </div>
                <div class="stat-card">
                    <i class="fas fa-check-circle" style="color: #4CAF50;"></i>
                    <h3><asp:Label ID="lblCompletedCourses" runat="server">0</asp:Label></h3>
                    <p>Completed</p>
                </div>
            </div>
        </div>

        <!-- Continue Learning Section -->
        <div>
            <h2 class="section-title">Continue Learning</h2>
            <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="empty-state">
                <i class="fas fa-graduation-cap"></i>
                <h3>No Courses Yet</h3>
                <p>Start your first aid journey by enrolling in a course!</p>
                <asp:HyperLink ID="lnkBrowseCourses" runat="server" NavigateUrl="~/LearningCourse.aspx"
                    CssClass="btn-continue" Style="margin-top: 20px;">Browse Courses</asp:HyperLink>
            </asp:Panel>

            <div class="course-grid">
                <asp:Repeater ID="rptEnrolledCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card">
                            <div class="course-image">
                                <%# !string.IsNullOrEmpty(Eval("PhotoPath") as string)
                                    ? "<img src='" + Eval("PhotoPath") + "' alt='Course' />"
                                    : "<i class='fas fa-heart-pulse'></i>" %>
                            </div>
                            <div class="course-content">
                                <h3 class="course-title"><%# Eval("CourseName") %></h3>
                                <div class="progress-bar-bg">
                                    <div class="progress-fill" style='<%# "width:" + Eval("ProgressPercentage") + "%" %>'></div>
                                </div>
                                <div class="course-footer">
                                    <span style="color:#666;"><%# Eval("ProgressPercentage", "{0:F0}")%>% Complete</span>
                                    <a href='<%# GetContinueUrl(Eval("NextLessonID")) %>' class="btn-continue">Continue &rarr;</a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Recently Completed Section -->
        <asp:Panel ID="pnlCompletedSection" runat="server" Visible="false">
            <h2 class="section-title mt-5">Recently Completed</h2>
            <div class="course-grid">
                <asp:Repeater ID="rptCompletedCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card" style="border: 2px solid #4CAF50;">
                            <div class="course-image" style="background:#e8f5e9; color:#4CAF50; position:relative;">
                                <span class="position-absolute top-0 end-0 m-2 badge bg-success fs-6 shadow">&check; Completed</span>
                                <i class="fas fa-certificate"></i>
                            </div>
                            <div class="course-content">
                                <h3 class="course-title"><%# Eval("CourseName") %></h3>
                                <div class="course-footer">
                                    <span style="color:#666; font-size:0.9em;"><i class="fa-regular fa-calendar-check me-1"></i>Enrolled: <%# Convert.ToDateTime(Eval("EnrollmentDate")).ToString("MMM dd, yyyy") %></span>
                                    <a href="LearningProgress.aspx" class="btn btn-outline-success border border-success text-success" style="padding:6px 14px; border-radius:6px; text-decoration:none; font-weight:600;">Review <i class="fa-solid fa-arrow-right ms-1"></i></a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </asp:Panel>

        <!-- Leaderboard Section -->
        <div class="mt-5 mb-5">
            <h2 class="section-title">
                <i class="fas fa-trophy text-warning me-2"></i>Leaderboard
                <small class="text-muted fw-normal fs-6 ms-2">Top 10 learners this week</small>
            </h2>
            <div class="leaderboard-card">
                <div class="lb-header">
                    <span><i class="fas fa-medal me-2"></i>Rankings</span>
                    <span class="fw-normal opacity-75" style="font-size:0.85rem;">Based on quiz XP earned</span>
                </div>

                <asp:Repeater ID="rptLeaderboard" runat="server">
                    <ItemTemplate>
                        <div class='<%# "lb-row "
                            + (Container.ItemIndex == 0 ? "podium-gold" : Container.ItemIndex == 1 ? "podium-silver" : Container.ItemIndex == 2 ? "podium-bronze" : "")
                            + (Convert.ToInt32(Eval("UserID")) == Convert.ToInt32(Session["UserID"] ?? 0) ? " me-row" : "") %>'>
                            <div class='lb-rank <%# Container.ItemIndex == 0 ? "rank-gold" : Container.ItemIndex == 1 ? "rank-silver" : Container.ItemIndex == 2 ? "rank-bronze" : "rank-other" %>'>
                                <%# Container.ItemIndex == 0 ? "&#129351;" : Container.ItemIndex == 1 ? "&#129352;" : Container.ItemIndex == 2 ? "&#129353;" : (Container.ItemIndex + 1).ToString() %>
                            </div>
                            <div class="lb-name">
                                <div class="lb-avatar"><%# (Eval("FullName").ToString() + "?").Substring(0,1).ToUpper() %></div>
                                <div>
                                    <div><%# Eval("FullName") %><%# Convert.ToInt32(Eval("UserID")) == Convert.ToInt32(Session["UserID"] ?? 0) ? " <span class='badge bg-warning text-dark ms-1' style='font-size:0.7rem;'>YOU</span>" : "" %></div>
                                    <div class="lb-date"><%# Eval("LastSolved") != DBNull.Value ? Convert.ToDateTime(Eval("LastSolved")).ToString("MMM dd, HH:mm") : "-" %></div>
                                </div>
                            </div>
                            <div class="lb-pts">
                                <div class="lb-weekly">+<%# Eval("WeeklyPoints") %> this week</div>
                                <div class="lb-total"><i class="fas fa-star me-1" style="font-size:0.75rem;"></i><%# Eval("TotalPoints") %> XP</div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        <asp:Panel ID="pnlNoLeaderboard" runat="server">
                        </asp:Panel>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmptyLeaderboard" runat="server" Visible="false"
                    Style="text-align:center; padding:40px; color:#888;">
                    <i class="fas fa-trophy" style="font-size:40px; color:#ddd; display:block; margin-bottom:10px;"></i>
                    No scores yet - complete a quiz to appear on the leaderboard!
                </asp:Panel>
            </div>
        </div>

    </div>
</asp:Content>
