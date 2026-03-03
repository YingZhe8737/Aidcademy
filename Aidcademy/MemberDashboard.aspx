<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" Inherits="Aidcademy.MemberDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Member Dashboard - Aidcademy</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #FFFBF1;
        }

        /* Navigation Bar */
        .navbar {
            background: linear-gradient(to right, #dc2626, #b91c1c);
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .navbar-brand {
            font-size: 24px;
            font-weight: bold;
        }

        .navbar-menu {
            display: flex;
            gap: 20px;
            align-items: center;
        }

            .navbar-menu a {
                color: white;
                text-decoration: none;
                padding: 8px 15px;
                border-radius: 5px;
                transition: background 0.3s;
            }

                .navbar-menu a:hover {
                    background: rgba(255, 255, 255, 0.2);
                }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .welcome-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .welcome-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }

        .user-info h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 5px;
        }

        .user-info p {
            color: #666;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-top: 20px;
        }

        .stat-card {
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white;
            padding: 20px;
            border-radius: 10px;
            text-align: center;
        }

            .stat-card i {
                font-size: 32px;
                margin-bottom: 10px;
            }

            .stat-card h3 {
                font-size: 28px;
                margin-bottom: 5px;
            }

            .stat-card p {
                font-size: 14px;
                opacity: 0.9;
            }

        .section-title {
            color: #333;
            font-size: 22px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 3px solid #dc2626;
        }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .course-card {
            background: white;
            border-radius: 10px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

            .course-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
            }

        .course-image {
            width: 100%;
            height: 180px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 48px;
        }

        .course-content {
            padding: 20px;
        }

        .course-title {
            color: #333;
            font-size: 18px;
            font-weight: 600;
            margin-bottom: 10px;
        }

        .progress-bar {
            background: #e0e0e0;
            height: 8px;
            border-radius: 4px;
            overflow: hidden;
            margin: 10px 0;
        }

        .progress-fill {
            background: linear-gradient(90deg, #dc2626 0%, #b91c1c 100%);
            height: 100%;
            transition: width 0.3s;
        }

        .course-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 5px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s;
            display: inline-block;
            border: none;
            cursor: pointer;
        }

        .btn-primary {
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white;
        }

            .btn-primary:hover {
                transform: translateY(-2px);
                background: linear-gradient(to right, #b91c1c, #991b1b);
                box-shadow: 0 5px 15px rgba(220, 38, 38, 0.4);
            }

        .recent-activity {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .activity-list {
            list-style: none;
        }

        .activity-item {
            padding: 15px;
            border-left: 3px solid #dc2626;
            background: #f8f9fa;
            margin-bottom: 10px;
            border-radius: 0 5px 5px 0;
        }

            .activity-item .title {
                font-weight: 600;
                color: #333;
                margin-bottom: 5px;
            }

            .activity-item .meta {
                color: #666;
                font-size: 14px;
            }

        .empty-state {
            text-align: center;
            padding: 40px;
            color: #666;
        }

            .empty-state i {
                font-size: 64px;
                color: #ddd;
                margin-bottom: 20px;
            }

        @media (max-width: 768px) {
            .welcome-header {
                flex-direction: column;
                align-items: flex-start;
            }

            .stats-grid {
                grid-template-columns: 1fr 1fr;
            }

            .course-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <!-- Navigation Bar -->
        <div class="navbar">
            <div class="navbar-brand">
                <a href="MainPage.aspx" style="color: white; text-decoration: none;">🏥
                        AIDCADEMY</a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/MemberDashboard.aspx">Dashboard
                </asp:HyperLink>
                <asp:HyperLink ID="lnkCourses" runat="server" NavigateUrl="~/LearningCourse.aspx">Courses
                </asp:HyperLink>
                <asp:HyperLink ID="lnkProgress" runat="server" NavigateUrl="~/LearningProgress.aspx">My Progress
                </asp:HyperLink>
                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/MemberProfile.aspx">Profile
                </asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click">Logout</asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <div class="welcome-header">
                    <div class="user-info">
                        <h1>Welcome back,
                            <asp:Label ID="lblMemberName" runat="server"></asp:Label>! 👋</h1>
                        <p>Continue your first aid learning journey</p>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <i class="fas fa-fire"></i>
                        <h3>
                            <asp:Label ID="lblDailyStreak" runat="server">0</asp:Label>
                        </h3>
                        <p>Day Streak</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-trophy"></i>
                        <h3>
                            <asp:Label ID="lblTotalPoints" runat="server">0</asp:Label>
                        </h3>
                        <p>Total Points</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-book"></i>
                        <h3>
                            <asp:Label ID="lblEnrolledCourses" runat="server">0</asp:Label>
                        </h3>
                        <p>Enrolled Courses</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-check-circle"></i>
                        <h3>
                            <asp:Label ID="lblCompletedCourses" runat="server">0</asp:Label>
                        </h3>
                        <p>Completed</p>
                    </div>
                </div>
            </div>

            <!-- Continue Learning Section -->
            <div>
                <h2 class="section-title">Continue Learning</h2>

                <!-- Empty state panel when no courses -->
                <asp:Panel ID="pnlNoCourses" runat="server" Visible="false" CssClass="empty-state"
                    Style="background: white; border-radius: 10px;">
                    <i class="fas fa-graduation-cap"></i>
                    <h3>No Courses Yet</h3>
                    <p>Start your first aid journey by enrolling in a course!</p>
                    <asp:HyperLink ID="lnkBrowseCourses" runat="server" NavigateUrl="~/LearningCourse.aspx"
                        CssClass="btn btn-primary" Style="margin-top: 20px;">Browse Courses</asp:HyperLink>
                </asp:Panel>

                <!-- Course grid -->
                <div class="course-grid">
                    <asp:Repeater ID="rptEnrolledCourses" runat="server">
                        <ItemTemplate>
                            <div class="course-card">
                                <div class="course-image">
                                    <i class="fas fa-heart-pulse"></i>
                                </div>
                                <div class="course-content">
                                    <h3 class="course-title">
                                        <%# Eval("CourseName") %>
                                    </h3>
                                    <div class="progress-bar">
                                        <div class="progress-fill"
                                            style='<%# String.Format("width:{0}%", Eval("ProgressPercentage")) %>'>
                                        </div>
                                    </div>
                                    <div class="course-footer">
                                        <span style="color: #666;">
                                            <%# Eval("ProgressPercentage", "{0:F0}" ) %>% Complete
                                        </span>
                                        <asp:HyperLink runat="server"
                                            NavigateUrl='<%# "~/LearningContent.aspx?courseId=" + Eval("CourseID") %>'
                                            CssClass="btn btn-primary">
                                                Continue →
                                        </asp:HyperLink>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- Recent Activity Section -->
            <div class="recent-activity">
                <h2 class="section-title">Recent Activity</h2>

                <!-- Empty state panel when no activity -->
                <asp:Panel ID="pnlNoActivity" runat="server" Visible="false" CssClass="empty-state">
                    <i class="fas fa-clock"></i>
                    <p>No recent activity</p>
                </asp:Panel>

                <!-- Activity list -->
                <ul class="activity-list">
                    <asp:Repeater ID="rptRecentActivity" runat="server">
                        <ItemTemplate>
                            <li class="activity-item">
                                <div class="title">
                                    <%# Eval("LessonTitle") %>
                                </div>
                                <div class="meta">
                                    <i class="fas fa-book"></i>
                                    <%# Eval("CourseName") %> •
                                            <i class="fas fa-clock"></i>
                                    <%# Eval("LastAccessedDate", "{0:MMM dd, yyyy}" ) %>
                                </div>
                            </li>
                        </ItemTemplate>
                    </asp:Repeater>
                </ul>
            </div>
        </div>
    </form>
</body>

</html>
