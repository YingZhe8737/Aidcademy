<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningCourse.aspx.cs" Inherits="Aidcademy.LearningCourse" %>

<!DOCTYPE html>
<html>

<head runat="server">
    <title>Courses - Aidcademy</title>
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
            max-width: 1200px;
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

            .page-header p {
                color: #666;
            }

        .course-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 25px;
        }

        .course-card {
            background: white;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            transition: transform 0.3s, box-shadow 0.3s;
        }

            .course-card:hover {
                transform: translateY(-5px);
                box-shadow: 0 5px 20px rgba(0, 0, 0, 0.15);
            }

        .course-image {
            height: 160px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 56px;
        }

        .course-content {
            padding: 25px;
        }

        .course-title {
            font-size: 20px;
            font-weight: 600;
            color: #333;
            margin-bottom: 10px;
        }

        .course-description {
            color: #666;
            line-height: 1.6;
            margin-bottom: 15px;
        }

        .course-category {
            display: inline-block;
            padding: 4px 12px;
            background: #fee2e2;
            color: #c9242b;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .badge-enrolled {
            display: inline-block;
            padding: 4px 12px;
            background: #cce5ff;
            color: #004085;
            border-radius: 12px;
            font-size: 12px;
            font-weight: 600;
            margin-left: 8px;
        }

        .btn-enroll {
            width: 100%;
            padding: 12px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

            .btn-enroll:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(220, 38, 38, 0.4);
            }

        .btn-enrolled-view {
            display: block;
            width: 100%;
            padding: 12px;
            background: #28a745;
            color: white;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            text-align: center;
            text-decoration: none;
        }

        .empty-state {
            text-align: center;
            padding: 60px 20px;
            background: white;
            border-radius: 12px;
        }

        @media (max-width: 768px) {
            .course-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="navbar">
            <div class="navbar-brand">
                <a href="MainPage.aspx" style="color: white; text-decoration: none;">🏥
                        AIDCADEMY</a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink runat="server" NavigateUrl="~/MemberDashboard.aspx">Dashboard</asp:HyperLink>
                <asp:HyperLink runat="server" NavigateUrl="~/LearningCourse.aspx">Courses</asp:HyperLink>
                <asp:HyperLink runat="server" NavigateUrl="~/LearningProgress.aspx">My Progress</asp:HyperLink>
                <asp:HyperLink runat="server" NavigateUrl="~/SubmitQuestion.aspx">Ask Question</asp:HyperLink>
                <asp:HyperLink runat="server" NavigateUrl="~/MemberProfile.aspx">Profile</asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="navbar-btn">Logout</asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <h1>Available Courses</h1>
                <p>Enroll in courses to start your first aid learning journey</p>
            </div>

            <div class="course-grid">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card">
                            <div class="course-image">🏥</div>
                            <div class="course-content">
                                <h3 class="course-title">
                                    <%# Eval("CourseName") %>
                                    </h3>
                                <p class="course-description">
                                    <%# Eval("CourseDescription") %>
                                </p>

                                <%-- Category badge (from new schema: Category column) --%>
                                <div style="margin-bottom: 15px;">
                                    <span class="course-category">
                                        <%# Eval("Category") %>
                                            </span>
                                    <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                                ? "<span class='badge-enrolled'>✓ Enrolled</span>" : "" %>
                                </div>

                                <%-- Enroll button OR View Course link based on enrollment status --%>
                                <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                                ? "<a href='LearningProgress.aspx' class='btn-enrolled-view'>View My Progress →</a>"
                                                : "" %>

                                <%-- asp:Button for enroll — must be a server control, not inside inline
                                                    string --%>
                                <asp:LinkButton runat="server"
                                    Visible='<%# !Convert.ToBoolean(Eval("IsEnrolled")) %>'
                                    CommandName="Enroll" CommandArgument='<%# Eval("CourseID") %>'
                                    OnCommand="btnEnroll_Command" CssClass="btn-enroll">
                                                        Enroll Now
                                                    </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </form>
</body>

</html>
