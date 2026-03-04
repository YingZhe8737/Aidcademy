<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentManagement.aspx.cs" Inherits="Aidcademy.ContentManagement" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Admin - Content Management</title>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/CustomAdmin.css" rel="stylesheet" type="text/css" />
    <style>


    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- NAV -->
    <div class="admin-nav">
        <div class="nav-logo">
            <i class="fa-solid fa-truck-medical"></i> AIDCADEMY
        </div>
        <ul class="navbar-nav">
            <li><a href="AdminDashboard.aspx">Dashboard</a></li>
            <li><a href="SystemReport.aspx">System Report</a></li>
            <li><a href="UserManagement.aspx">User Management</a></li>
            <li><a href="ContentManagement.aspx" class="active">Content Management</a></li>
            <li><a href="Login_signup.aspx">Logout</a></li>
        </ul>
    </div>

    <!-- PAGE CONTENT -->
    <div class="page-content">

        <!-- WELCOME + STATS -->
        <div class="welcome-card">
            <h3>Content Management &#x1F6E1;&#xFE0F;</h3>
            <p>Review and approve instructor-submitted lessons before they go live.</p>

            <div class="stat-row">
                <div class="stat-card">
                    <div class="stat-icon-box"><i class="fa-solid fa-book-open"></i></div>
                    <div>
                        <span class="stat-label">Total Lessons</span>
                        <span class="stat-value"><asp:Label ID="lblTotal" runat="server" Text="0" /></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-box"><i class="fa-solid fa-clock-rotate-left"></i></div>
                    <div>
                        <span class="stat-label">Pending Review</span>
                        <span class="stat-value"><asp:Label ID="lblPending" runat="server" Text="0" /></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-box"><i class="fa-solid fa-clipboard-check"></i></div>
                    <div>
                        <span class="stat-label">Published</span>
                        <span class="stat-value"><asp:Label ID="lblPublished" runat="server" Text="0" /></span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-box"><i class="fa-solid fa-circle-xmark"></i></div>
                    <div>
                        <span class="stat-label">Rejected</span>
                        <span class="stat-value"><asp:Label ID="lblRejected" runat="server" Text="0" /></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- SECTION HEADER + FILTER -->
        <div class="section-header">
            <h5><i class="fa-solid fa-folder-tree" style="margin-right:8px;"></i>Course Curriculum</h5>
            <div class="filter-wrapper">
                <button type="button" class="filter-btn">
                    <i class="fa-solid fa-filter" style="margin-right:6px;"></i>Filter ▾
                </button>
                <div class="filter-dropdown">
                    <asp:LinkButton runat="server" CommandArgument="All"           OnClick="btnFilter_Click"><i class="fa-solid fa-list"         style="margin-right:8px;color:#999;"></i>All Lessons</asp:LinkButton>
                    <asp:LinkButton runat="server" CommandArgument="Pending Admin" OnClick="btnFilter_Click"><i class="fa-solid fa-clock"        style="margin-right:8px;color:#ffc107;"></i>Pending Only</asp:LinkButton>
                    <asp:LinkButton runat="server" CommandArgument="Published"     OnClick="btnFilter_Click"><i class="fa-solid fa-check"        style="margin-right:8px;color:#198754;"></i>Published Only</asp:LinkButton>
                    <asp:LinkButton runat="server" CommandArgument="Rejected"      OnClick="btnFilter_Click"><i class="fa-solid fa-circle-xmark" style="margin-right:8px;color:#dc3545;"></i>Rejected Only</asp:LinkButton>
                </div>
            </div>
        </div>

        <!-- COURSES → LESSONS REPEATER -->
        <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
            <ItemTemplate>
                <div class="course-group">

                    <div class="course-heading">
                        <i class="fa-solid fa-book-medical" style="margin-right:8px;"></i><%# Eval("CourseTitle") %>
                        <span class="cat-badge"><i class="fa-solid fa-tag" style="margin-right:4px;"></i><%# Eval("Category") %></span>
                        <span class="instructor-name">by <i class="fa-solid fa-user-tie" style="margin-right:4px;"></i><%# Eval("InstructorName") %></span>
                    </div>

                    <div class="lessons-grid">
                        <asp:Repeater ID="rptLessons" runat="server">
                            <ItemTemplate>
                                <div class='lesson-card <%# GetStatusCssClass(Eval("ApprovalStatus").ToString()) %>'>
                                    <div class="lesson-card-body">

                                        <div class="card-top-row">
                                            <span class="step-badge">
                                                <i class="fa-solid fa-list-ol" style="margin-right:4px;"></i>Step <%# Eval("SequenceOrder") %>
                                            </span>
                                            <span class='status-badge <%# GetStatusBadgeClassSimple(Eval("ApprovalStatus").ToString()) %>'>
                                                <%# Eval("ApprovalStatus") %>
                                            </span>
                                        </div>

                                        <div class="lesson-title"><%# Eval("Title") %></div>

                                        <div class="card-footer-row">
                                            <asp:LinkButton ID="btnView" runat="server"
                                                CssClass="view-btn"
                                                CommandArgument='<%# Eval("LessonID") %>'
                                                OnClick="btnViewLesson_Click">
                                                <i class="fa-solid fa-eye" style="margin-right:6px;"></i>View Details
                                            </asp:LinkButton>
                                        </div>

                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                </div>
            </ItemTemplate>
        </asp:Repeater>

    </div>

</form>
</body>
</html>
