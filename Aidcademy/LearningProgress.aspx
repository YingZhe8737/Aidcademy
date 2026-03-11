<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningProgress.aspx.cs"
    Inherits="Aidcademy.LearningProgress" %>

<!DOCTYPE html>
<html>

<head runat="server">
    <title>My Progress - Aidcademy</title>
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
            min-height: 100vh;
        }

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
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .page-header {
            text-align: center;
            margin-bottom: 40px;
        }

            .page-header h1 {
                color: #333;
                font-size: 32px;
                margin-bottom: 10px;
            }

        .progress-card {
            background: white;
            border-radius: 12px;
            padding: 25px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .progress-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
            flex-wrap: wrap;
        }

        .course-name {
            font-size: 20px;
            font-weight: 600;
            color: #333;
        }

        .status-badge {
            padding: 5px 15px;
            border-radius: 15px;
            font-size: 12px;
            font-weight: 600;
        }

        .status-completed {
            background: #d4edda;
            color: #155724;
        }

        .status-progress {
            background: #cce5ff;
            color: #004085;
        }

        .progress-bar {
            background: #e0e0e0;
            height: 12px;
            border-radius: 6px;
            overflow: hidden;
            margin: 15px 0;
        }

        .progress-fill {
            background: linear-gradient(90deg, #dc2626 0%, #b91c1c 100%);
            height: 100%;
            transition: width 0.3s;
        }

        .progress-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
            gap: 15px;
            margin-top: 15px;
        }

        .stat-item {
            text-align: center;
            padding: 15px;
            background: #f8f9fa;
            border-radius: 8px;
        }

        .stat-value {
            font-size: 24px;
            font-weight: 600;
            color: #dc2626;
        }

        .stat-label {
            font-size: 12px;
            color: #666;
            margin-top: 5px;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
        }

            .empty-state i {
                font-size: 64px;
                color: #ddd;
                margin-bottom: 20px;
            }

        @media (max-width: 768px) {
            .progress-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="navbar">
            <div class="navbar-brand">
                <a href="MainPage.aspx" style="color: white; text-decoration: none; display: flex; align-items: center;">
                    <img src="Image/logo2.jpeg" alt="Aidcademy Logo" style="height: 40px; margin-right: 10px; border-radius: 5px;" />
                    AIDCADEMY
                </a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/MemberDashboard.aspx"><i class="fas fa-chart-line"></i> Dashboard</asp:HyperLink>
                <asp:HyperLink ID="lnkCourses" runat="server" NavigateUrl="~/LearningCourse.aspx"><i class="fas fa-book"></i> Courses</asp:HyperLink>
                <asp:HyperLink ID="lnkProgress" runat="server" NavigateUrl="~/LearningProgress.aspx" CssClass="fw-bold text-white font-weight-bold"><i class="fas fa-chart-pie"></i> My Progress</asp:HyperLink>
                <asp:HyperLink ID="lnkAskQuestion" runat="server" NavigateUrl="~/SubmitQuestion.aspx"><i class="fas fa-comments"></i> Ask Question</asp:HyperLink>
                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/MemberProfile.aspx"><i class="fas fa-user"></i> Profile</asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="navbar-btn"><i class="fas fa-sign-out-alt"></i> Logout</asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <h1>My Learning Progress</h1>
                <p>Track your journey through first aid courses</p>
            </div>

            <asp:Panel ID="pnlNoProgress" runat="server" Visible="false" CssClass="empty-state">
                <div style="font-size: 64px;">📚</div>
                <h3>No Enrolled Courses Yet</h3>
                <p style="color: #666; margin: 15px 0;">Start learning by enrolling in a course</p>
                <asp:HyperLink runat="server" NavigateUrl="~/LearningCourse.aspx"
                    Style="display: inline-block; padding: 10px 20px; background: linear-gradient(to right, #dc2626, #b91c1c); color: white; text-decoration: none; border-radius: 5px; margin-top: 20px; font-weight: 500; transition: all 0.3s;">
                        Browse Courses</asp:HyperLink>
            </asp:Panel>

            <asp:Repeater ID="rptProgress" runat="server">
                <ItemTemplate>
                    <div class="progress-card position-relative" style='<%# Eval("Status").ToString() == "Completed" ? "border: 2px solid #28a745;" : "" %>'>
                        <%# Eval("Status").ToString() == "Completed" ? "<span class=\"position-absolute top-0 start-50 translate-middle badge rounded-pill bg-success px-3 py-2 fs-6 shadow\"><i class=\"fa-solid fa-check-circle me-1\"></i> Course Completed</span>" : "" %>
                        <div class="progress-header mt-2">
                            <h3 class="course-name">
                                <%# Eval("CourseName") %>
                                </h3>
                            <span
                                class='status-badge <%# Eval("Status").ToString() == "Completed" ? "status-completed" : "status-progress" %>'>
                                <%# Eval("Status") %>
                                </span>
                        </div>

                        <div class="progress-bar">
                            <div class="progress-fill"
                                style='<%# String.Format("width:{0}%", Eval("ProgressPercentage")) %>'>
                            </div>
                        </div>

                        <div style="text-align: center; color: #666; margin-bottom: 15px;">
                            <strong style="color: #667eea; font-size: 18px;">
                                <%# Eval("ProgressPercentage", "{0:F0}" ) %>%
                                </strong>Complete
                            <%# Eval("Status").ToString() != "Completed" ? "<a href='" + GetContinueUrl(Eval("NextLessonID")) + "' class='btn btn-sm btn-outline-primary ms-3 rounded-pill fw-bold'>Continue Learning <i class='fa-solid fa-arrow-right ms-1'></i></a>" : "" %>
                        </div>

                        <div class="progress-stats">
                            <div class="stat-item">
                                <div class="stat-value">
                                    <%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %>
                                </div>
                                <div class="stat-label">Lessons Completed</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">
                                    <%# Eval("EnrollmentDate", "{0:MMM dd, yyyy}" ) %>
                                </div>
                                <div class="stat-label">Enrolled On</div>
                            </div>
                            <div class="stat-item">
                                <div class="stat-value">
                                    <%# Convert.ToInt32(Eval("AvgQuizScore")) == -1 ? "N/A" : Eval("AvgQuizScore", "{0:F0}") %> 
                                </div>
                                <div class="stat-label">Avg Quiz Score</div>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </form>
</body>

</html>
