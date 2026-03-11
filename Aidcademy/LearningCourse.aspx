<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LearningCourse.aspx.cs" Inherits="Aidcademy.LearningCourse" %>

<!DOCTYPE html>
<html>

<head runat="server">
    <title>Courses - Aidcademy</title>
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
                <a href="MainPage.aspx" style="color: white; text-decoration: none; display: flex; align-items: center;">
                    <img src="Image/logo2.jpeg" alt="Aidcademy Logo" style="height: 40px; margin-right: 10px; border-radius: 5px;" />
                    AIDCADEMY
                </a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/MemberDashboard.aspx"><i class="fas fa-chart-line"></i> Dashboard</asp:HyperLink>
                <asp:HyperLink ID="lnkCourses" runat="server" NavigateUrl="~/LearningCourse.aspx" CssClass="fw-bold text-white font-weight-bold"><i class="fas fa-book"></i> Courses</asp:HyperLink>
                <asp:HyperLink ID="lnkProgress" runat="server" NavigateUrl="~/LearningProgress.aspx"><i class="fas fa-chart-pie"></i> My Progress</asp:HyperLink>
                <asp:HyperLink ID="lnkAskQuestion" runat="server" NavigateUrl="~/SubmitQuestion.aspx"><i class="fas fa-comments"></i> Ask Question</asp:HyperLink>
                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/MemberProfile.aspx"><i class="fas fa-user"></i> Profile</asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="navbar-btn"><i class="fas fa-sign-out-alt"></i> Logout</asp:LinkButton>
            </div>
        </div>

        <div class="container">
            <div class="page-header">
                <h1>Available Courses</h1>
                <p>Enroll in courses to start your first aid learning journey</p>
                <div class="mt-4" style="max-width: 500px; margin: 0 auto;">
                    <input type="text" id="txtSearch" class="form-control rounded-pill text-center shadow-sm py-2" placeholder="Search courses by name..." oninput="filterCourses()" />
                </div>
            </div>

            <div class="course-grid">
                <asp:Repeater ID="rptCourses" runat="server">
                    <ItemTemplate>
                        <div class="course-card">
                            <div class="course-image"><i class="fas fa-hospital" style="font-size:56px;"></i></div>
                            <div class="course-content">
                                <h3 class="course-title">
                                    <%# Eval("CourseName") %>
                                </h3>
                                
                                <div class="course-description-container" style="margin-bottom: 15px;">
                                    <p class="course-description m-0" style="display:inline;">
                                        <%# Eval("CourseDescription").ToString().Length > 100 ? Eval("CourseDescription").ToString().Substring(0, 100) + "..." : Eval("CourseDescription") %>
                                    </p>
                                    <%# Eval("CourseDescription").ToString().Length > 100 ? 
                                        "<span class='full-desc d-none'>" + Eval("CourseDescription") + "</span><a href='#' class='text-primary fw-bold ms-1' style='text-decoration:none; font-size:0.9em;' onclick='toggleDesc(this, event)'>Read more &#9660;</a>"
                                        : "" %>
                                </div>

                                <div style="margin-bottom: 15px;">
                                    <span class="course-category">
                                        <%# Eval("Category") %>
                                    </span>
                                    <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                                ? "<span class='badge-enrolled'>&check; Enrolled</span>" : "" %>
                                </div>
                                
                                <%# Convert.ToBoolean(Eval("IsEnrolled")) ? 
                                    "<div class='progress mb-3' style='height: 6px;'><div class='progress-bar bg-success' style='width: " + Eval("ProgressPercentage") + "%;'></div></div><div class='text-end text-muted' style='font-size:0.8em; margin-top:-10px; margin-bottom:10px;'>" + String.Format("{0:F0}", Eval("ProgressPercentage")) + "% Complete</div>"
                                    : "" %>

                                <%# Convert.ToBoolean(Eval("IsEnrolled"))
                                                ? "<a href='" + GetContinueUrl(Eval("NextLessonID")) + "' class='btn-enrolled-view'>Continue Learning &#x2192;</a>"
                                                : "" %>

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

    <script>
        function filterCourses() {
            var search = document.getElementById("txtSearch").value.toLowerCase();
            var cards = document.querySelectorAll(".course-card");
            cards.forEach(function (card) {
                var title = card.querySelector(".course-title").innerText.toLowerCase();
                if (title.includes(search)) {
                    card.style.display = "block";
                } else {
                    card.style.display = "none";
                }
            });
        }

        function toggleDesc(btn, e) {
            e.preventDefault();
            var container = btn.parentElement;
            var shortP = container.querySelector(".course-description");
            var fullSpan = container.querySelector(".full-desc");

            if (fullSpan.classList.contains("d-none")) {
                shortP.style.display = "none";
                fullSpan.classList.remove("d-none");
                btn.innerText = "Show less (^)";
            } else {
                shortP.style.display = "inline";
                fullSpan.classList.add("d-none");
                btn.innerText = "Read more (v)";
            }
        }
    </script>
</body>

</html>
