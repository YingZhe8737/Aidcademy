<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Aidcademy.WebForm1" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Aidcademy — Admin Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/CustomAdmin.css" rel="stylesheet" type="text/css" />
    <style>
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
    <div class="admin-nav">
        <div class="nav-logo">
            <i class="fa-solid fa-truck-medical"></i> AIDCADEMY
        </div>
        <ul class="navbar-nav">
            <li class="nav-item"><a class="nav-link active" href="AdminDashboard.aspx">Dashboard</a></li>
            <li class="nav-item"><a class="nav-link" href="SystemReport.aspx">System Report</a></li>
            <li class="nav-item"><a class="nav-link" href="UserManagement.aspx">User Management</a></li>
            <li class="nav-item"><a class="nav-link" href="ContentManagement.aspx">Content Management</a></li>
            <li class="nav-item"><a class="nav-link" href="Login_signup.aspx">Logout</a></li>
        </ul>
    </div>

    <div class="dash-page">

        <!-- WELCOME + TOP STAT STRIP -->
        <div class="dash-welcome-card">
            <h2><i class="fa-solid fa-gauge-high" style="color:#c9242b"></i> Admin Dashboard</h2>
            <p>Platform overview — users, traffic, and content at a glance.</p>
            <div class="dash-stat-strip">
                <div class="dash-stat-item">
                    <div class="dash-stat-icon"><i class="fa-solid fa-users"></i></div>
                    <div>
                        <div class="dash-stat-label">Total Users</div>
                        <div class="dash-stat-value"><asp:Label ID="lblTotalUsersStrip" runat="server" Text="—"></asp:Label></div>
                    </div>
                </div>
                <div class="dash-stat-item">
                    <div class="dash-stat-icon"><i class="fa-solid fa-eye"></i></div>
                    <div>
                        <div class="dash-stat-label">Total Visitors</div>
                        <div class="dash-stat-value"><asp:Label ID="lblTotalVisitorsStrip" runat="server" Text="—"></asp:Label></div>
                    </div>
                </div>
                <div class="dash-stat-item">
                    <div class="dash-stat-icon"><i class="fa-solid fa-book-open"></i></div>
                    <div>
                        <div class="dash-stat-label">Total Lessons</div>
                        <div class="dash-stat-value"><asp:Label ID="lblTotalLessonsStrip" runat="server" Text="—"></asp:Label></div>
                    </div>
                </div>
                <div class="dash-stat-item">
                    <div class="dash-stat-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
                    <div>
                        <div class="dash-stat-label">Pending Review</div>
                        <div class="dash-stat-value"><asp:Label ID="lblPendingStrip" runat="server" Text="—"></asp:Label></div>
                    </div>
                </div>
            </div>
        </div>

        <!-- USER MANAGEMENT -->
        <div class="dash-section">
            <div class="dash-section-header">
                <div class="dash-section-title">
                    <i class="fa-solid fa-users"></i> User Management
                </div>
            </div>
            <div class="dash-section-body">
                <div class="user-roles-row">
                    <div class="user-role-group">
                        <div class="user-role-label">Members</div>
                        <div class="user-pill-row">
                            <span class="upill upill-active"><span class="upill-dot"></span><asp:Label ID="lblActiveMembers" runat="server" Text="Active: —"></asp:Label></span>
                            <span class="upill upill-suspended"><span class="upill-dot"></span><asp:Label ID="lblSuspendedMembers" runat="server" Text="Suspended: —"></asp:Label></span>
                            <span class="upill upill-deactivated"><span class="upill-dot"></span><asp:Label ID="lblDeactivatedMembers" runat="server" Text="Deactivated: —"></asp:Label></span>
                        </div>
                    </div>
                    <div class="role-divider"></div>
                    <div class="user-role-group">
                        <div class="user-role-label">Instructors</div>
                        <div class="user-pill-row">
                            <span class="upill upill-active"><span class="upill-dot"></span><asp:Label ID="lblActiveInstructors" runat="server" Text="Active: —"></asp:Label></span>
                            <span class="upill upill-suspended"><span class="upill-dot"></span><asp:Label ID="lblSuspendedInstructors" runat="server" Text="Suspended: —"></asp:Label></span>
                            <span class="upill upill-deactivated"><span class="upill-dot"></span><asp:Label ID="lblDeactivatedInstructors" runat="server" Text="Deactivated: —"></asp:Label></span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="section-cta">
                <asp:Button ID="btnUserMgmt" runat="server" CssClass="sec-btn" Text="Manage Users" OnClick="User_Management2" />
            </div>
        </div>

        <!-- SYSTEM REPORT -->
        <div class="dash-section">
            <div class="dash-section-header">
                <div class="dash-section-title">
                    <i class="fa-solid fa-chart-line"></i> System Report
                </div>
            </div>
            <div class="dash-section-body">
                <div class="system-metrics">
                    <div class="sys-metric-box">
                        <div class="sys-metric-icon sys-icon-blue"><i class="fa-solid fa-users"></i></div>
                        <div>
                            <div class="sys-metric-num"><asp:Label ID="lblTotalMembersSystem" runat="server" Text="—"></asp:Label></div>
                            <div class="sys-metric-lbl">Total Member Visited</div>
                        </div>
                    </div>
                    <div class="sys-metric-box">
                        <div class="sys-metric-icon sys-icon-green"><i class="fa-solid fa-eye"></i></div>
                        <div>
                            <div class="sys-metric-num"><asp:Label ID="lblTotalVisitorsSystem" runat="server" Text="—"></asp:Label></div>
                            <div class="sys-metric-lbl">Total Visitor Visited</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="section-cta">
                <a href="SystemReport.aspx" class="sec-btn"><i class="fa-solid fa-arrow-right"></i> View Full Report</a>
            </div>
        </div>

        <!-- CONTENT MANAGEMENT -->
        <div class="dash-section">
            <div class="dash-section-header">
                <div class="dash-section-title">
                    <i class="fa-solid fa-book-open"></i> Content Management
                </div>
            </div>
            <div class="dash-section-body">
                <div class="content-stat-row">
                    <div class="content-stat-box csb-total">
                        <div class="csb-num"><asp:Label ID="lblContentTotal" runat="server" Text="—"></asp:Label></div>
                        <div class="csb-label">Total Lessons</div>
                    </div>
                    <div class="content-stat-box csb-pending">
                        <div class="csb-num"><asp:Label ID="lblContentPending" runat="server" Text="—"></asp:Label></div>
                        <div class="csb-label">Pending Review</div>
                    </div>
                    <div class="content-stat-box csb-published">
                        <div class="csb-num"><asp:Label ID="lblContentPublished" runat="server" Text="—"></asp:Label></div>
                        <div class="csb-label">Published</div>
                    </div>
                    <div class="content-stat-box csb-rejected">
                        <div class="csb-num"><asp:Label ID="lblContentRejected" runat="server" Text="—"></asp:Label></div>
                        <div class="csb-label">Rejected</div>
                    </div>
                </div>
            </div>
            <div class="section-cta">
                <a href="ContentManagement.aspx" class="sec-btn"><i class="fa-solid fa-arrow-right"></i> Review Content</a>
            </div>
        </div>

    </div>
</form>
</body>
</html>
