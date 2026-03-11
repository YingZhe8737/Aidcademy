<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberDashboard.aspx.cs" Inherits="Aidcademy.MemberDashboard" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Member Dashboard - Aidcademy</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
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

                .navbar-menu a:hover,
                .navbar-menu .navbar-btn:hover {
                    background: rgba(255, 255, 255, 0.2);
                }

        .navbar-btn {
            color: white;
            background: none;
            border: none;
            font-size: 1rem;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
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
                <a href="MainPage.aspx" style="color: white; text-decoration: none; display: flex; align-items: center;">
                    <img src="Image/logo2.jpeg" alt="Aidcademy Logo" style="height: 40px; margin-right: 10px; border-radius: 5px;" />
                    AIDCADEMY
                </a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/MemberDashboard.aspx" CssClass="fw-bold text-white"><i class="fas fa-chart-line"></i> Dashboard</asp:HyperLink>
                <asp:HyperLink ID="lnkCourses" runat="server" NavigateUrl="~/LearningCourse.aspx"><i class="fas fa-book"></i> Courses</asp:HyperLink>
                <asp:HyperLink ID="lnkProgress" runat="server" NavigateUrl="~/LearningProgress.aspx"><i class="fas fa-chart-pie"></i> My Progress</asp:HyperLink>
                <asp:HyperLink ID="lnkAskQuestion" runat="server" NavigateUrl="~/SubmitQuestion.aspx"><i class="fas fa-comments"></i> Ask Question</asp:HyperLink>
                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/MemberProfile.aspx"><i class="fas fa-user"></i> Profile</asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="navbar-btn"><i class="fas fa-sign-out-alt"></i> Logout</asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <!-- Welcome Section -->
            <div class="welcome-section">
                <div class="welcome-header">
                    <div class="user-info">
                        <h1>Welcome back,
                            <asp:Label ID="lblMemberName" runat="server"></asp:Label>!</h1>
                        <p>Continue your first aid learning journey</p>
                    </div>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <i class="fas fa-fire" style="color: orange;"></i>
                        <h3>
                            <asp:Label ID="lblDailyStreak" runat="server">0</asp:Label>
                        </h3>
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
                        <h3>
                            <asp:Label ID="lblEnrolledCourses" runat="server">0</asp:Label>
                        </h3>
                        <p>Enrolled Courses</p>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-check-circle" style="color: #4CAF50;"></i>
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
                                            NavigateUrl='<%# GetContinueUrl(Eval("NextLessonID")) %>'
                                            CssClass="btn btn-primary">
                                                Continue &rarr;
                                        </asp:HyperLink>
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
                                <div class="course-image" style="background: #e8f5e9; color: #4CAF50; position: relative;">
                                    <span class="position-absolute top-0 end-0 m-2 badge bg-success fs-6 shadow">&check; Completed</span>
                                    <i class="fas fa-certificate"></i>
                                </div>
                                <div class="course-content">
                                    <h3 class="course-title"><%# Eval("CourseName") %></h3>
                                    <div class="course-footer">
                                        <span style="color: #666; font-size: 0.9em;"><i class="fa-regular fa-calendar-check me-1"></i>Enrolled: <%# Convert.ToDateTime(Eval("EnrollmentDate")).ToString("MMM dd, yyyy") %></span>
                                        <asp:HyperLink runat="server" NavigateUrl="~/LearningProgress.aspx" CssClass="btn btn-outline-success border border-success text-success">Review <i class="fa-solid fa-arrow-right ms-1"></i></asp:HyperLink>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </asp:Panel>

            <!-- Leaderboard Section -->
            <div class="leaderboard-section mt-5">
                <h2 class="section-title">Leaderboard</h2>
                <div class="table-responsive">
                    <asp:GridView ID="gvLeaderboard" runat="server" AutoGenerateColumns="False" CssClass="table table-bordered table-striped custom-grid" OnRowDataBound="gvLeaderboard_RowDataBound" DataKeyNames="UserID">
                        <Columns>
                            <asp:TemplateField HeaderText="Rank">
                                <ItemTemplate>
                                    <strong><%# Container.DataItemIndex + 1 %></strong>
                                </ItemTemplate>
                            </asp:TemplateField>
                            <asp:BoundField DataField="FullName" HeaderText="Name" />
                            <asp:BoundField DataField="LastSolved" HeaderText="Recent Activity Date" DataFormatString="{0:MMM dd, yyyy HH:mm}" />
                            <asp:BoundField DataField="WeeklyPoints" HeaderText="Weekly Total Points" />
                            <asp:BoundField DataField="TotalPoints" HeaderText="Entire Total Points" />
                        </Columns>
                        <EmptyDataTemplate>
                            <div class="empty-state" style="padding: 30px; text-align: center; color: #888;">
                                <i class="fas fa-trophy" style="font-size: 40px; color: #ddd; display: block; margin-bottom: 10px;"></i>
                                No scores yet - complete a quiz to appear on the leaderboard!
                            </div>
                        </EmptyDataTemplate>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </form>
</body>

</html>
