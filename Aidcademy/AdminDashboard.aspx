<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Aidcademy.WebForm1" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">Admin Dashboard — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom: 28px; }
        .page-header h2 { font-size: 1.65rem; font-weight: 900; color: #1a1a2e; margin-bottom: 4px; }
        .page-header p  { font-size: 0.92rem; color: #888; font-weight: 600; margin: 0; }

        /* ── Top stat strip ── */
        .stat-strip { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; margin-bottom: 32px; }
        @media(max-width:1100px){ .stat-strip{ grid-template-columns:repeat(2,1fr); } }
        @media(max-width:600px) { .stat-strip{ grid-template-columns:1fr; } }

        .strip-card {
            background: white; border-radius: 16px; padding: 22px 20px; border: 1px solid #ebebeb;
            display: flex; align-items: center; gap: 16px;
            transition: transform 0.2s, box-shadow 0.2s; position: relative; overflow: hidden;
        }
        .strip-card::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .strip-card.c-red::before    { background:#c9242b; }
        .strip-card.c-blue::before   { background:#3b82f6; }
        .strip-card.c-amber::before  { background:#f59e0b; }
        .strip-card.c-purple::before { background:#8b5cf6; }
        .strip-card:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .strip-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.25rem; flex-shrink:0; }
        .c-red    .strip-icon { background:#fde8e9; color:#c9242b; }
        .c-blue   .strip-icon { background:#dbeafe; color:#2563eb; }
        .c-amber  .strip-icon { background:#fef3c7; color:#d97706; }
        .c-purple .strip-icon { background:#ede9fe; color:#7c3aed; }
        .strip-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .strip-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        /* ── Section cards ── */
        .dash-section {
            background: white; border-radius: 16px; border: 1px solid #ebebeb;
            margin-bottom: 24px; overflow: hidden;
        }
        .dash-section-head {
            padding: 18px 24px; border-bottom: 1px solid #f5f5f5;
            display: flex; align-items: center; justify-content: space-between;
        }
        .dash-section-title { font-size: 1rem; font-weight: 900; color: #1a1a2e; display: flex; align-items: center; gap: 10px; }
        .dash-section-title i { color: #c9242b; }
        .dash-section-body { padding: 20px 24px; }
        .section-cta { padding: 14px 24px; border-top: 1px solid #f5f5f5; }
        .sec-btn {
            display: inline-flex; align-items: center; gap: 7px;
            background: #c9242b; color: white; border: none;
            font-family: 'Nunito', sans-serif; font-size: 0.85rem; font-weight: 700;
            padding: 9px 20px; border-radius: 10px; cursor: pointer;
            text-decoration: none; transition: background 0.18s, transform 0.18s;
        }
        .sec-btn:hover { background: #a01c22; transform: translateY(-1px); color: white; }

        /* ── User pills ── */
        .user-roles-row { display: flex; gap: 40px; flex-wrap: wrap; }
        .user-role-group {}
        .user-role-label { font-size: 0.78rem; font-weight: 800; color: #aaa; text-transform: uppercase; letter-spacing: 1px; margin-bottom: 10px; }
        .user-pill-row { display: flex; gap: 8px; flex-wrap: wrap; }
        .upill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 14px; border-radius: 20px; font-size: 0.82rem; font-weight: 700;
        }
        .upill-dot { width: 7px; height: 7px; border-radius: 50%; }
        .upill-active     { background: #d1fae5; color: #065f46; }
        .upill-active .upill-dot     { background: #10b981; }
        .upill-suspended  { background: #fef3c7; color: #92400e; }
        .upill-suspended .upill-dot  { background: #f59e0b; }
        .upill-deactivated{ background: #f3f4f6; color: #4b5563; }
        .upill-deactivated .upill-dot{ background: #9ca3af; }
        .role-divider { width: 1px; background: #f0f0f0; align-self: stretch; }

        /* ── System metrics ── */
        .system-metrics { display: flex; gap: 20px; flex-wrap: wrap; }
        .sys-metric-box {
            flex: 1; min-width: 180px; background: #f9f9f9; border-radius: 12px;
            padding: 20px; display: flex; align-items: center; gap: 14px; border: 1px solid #ebebeb;
        }
        .sys-metric-icon { width: 44px; height: 44px; border-radius: 11px; display: flex; align-items: center; justify-content: center; font-size: 1.15rem; }
        .sys-icon-blue   { background: #dbeafe; color: #2563eb; }
        .sys-icon-green  { background: #d1fae5; color: #059669; }
        .sys-metric-num  { font-size: 1.7rem; font-weight: 900; color: #1a1a2e; line-height: 1; }
        .sys-metric-lbl  { font-size: 0.78rem; color: #aaa; font-weight: 700; text-transform: uppercase; letter-spacing: 0.4px; margin-top: 4px; }

        /* ── Content stat boxes ── */
        .content-stat-row { display: grid; grid-template-columns: repeat(4,1fr); gap: 14px; }
        @media(max-width:900px){ .content-stat-row{ grid-template-columns:repeat(2,1fr); } }
        .content-stat-box { border-radius: 12px; padding: 20px; text-align: center; }
        .csb-total     { background: #f0f4ff; }
        .csb-pending   { background: #fffbeb; }
        .csb-published { background: #f0fdf4; }
        .csb-rejected  { background: #fff1f2; }
        .csb-num  { font-size: 2rem; font-weight: 900; color: #1a1a2e; }
        .csb-label{ font-size: 0.78rem; font-weight: 700; color: #888; text-transform: uppercase; letter-spacing: 0.4px; margin-top: 6px; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-gauge-high" style="color:#c9242b;margin-right:8px;"></i>Admin Dashboard</h2>
        <p>Platform overview — users, traffic, and content at a glance.</p>
    </div>

    <!-- TOP STAT STRIP -->
    <div class="stat-strip">
        <div class="strip-card c-red">
            <div class="strip-icon"><i class="fa-solid fa-users"></i></div>
            <div><div class="strip-value"><asp:Label ID="lblTotalUsersStrip" runat="server" Text="—"></asp:Label></div><div class="strip-label">Total Users</div></div>
        </div>
        <div class="strip-card c-blue">
            <div class="strip-icon"><i class="fa-solid fa-eye"></i></div>
            <div><div class="strip-value"><asp:Label ID="lblTotalVisitorsStrip" runat="server" Text="—"></asp:Label></div><div class="strip-label">Total Visitors</div></div>
        </div>
        <div class="strip-card c-amber">
            <div class="strip-icon"><i class="fa-solid fa-book-open"></i></div>
            <div><div class="strip-value"><asp:Label ID="lblTotalLessonsStrip" runat="server" Text="—"></asp:Label></div><div class="strip-label">Total Lessons</div></div>
        </div>
        <div class="strip-card c-purple">
            <div class="strip-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
            <div><div class="strip-value"><asp:Label ID="lblPendingStrip" runat="server" Text="—"></asp:Label></div><div class="strip-label">Pending Review</div></div>
        </div>
    </div>

    <!-- USER MANAGEMENT -->
    <div class="dash-section">
        <div class="dash-section-head">
            <div class="dash-section-title"><i class="fa-solid fa-users"></i>User Management</div>
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
            <asp:Button ID="btnUserMgmt" runat="server" CssClass="sec-btn" Text="Manage Users →" OnClick="User_Management2" />
        </div>
    </div>

    <!-- SYSTEM REPORT -->
    <div class="dash-section">
        <div class="dash-section-head">
            <div class="dash-section-title"><i class="fa-solid fa-chart-line"></i>System Report</div>
        </div>
        <div class="dash-section-body">
            <div class="system-metrics">
                <div class="sys-metric-box">
                    <div class="sys-metric-icon sys-icon-blue"><i class="fa-solid fa-users"></i></div>
                    <div><div class="sys-metric-num"><asp:Label ID="lblTotalMembersSystem" runat="server" Text="—"></asp:Label></div><div class="sys-metric-lbl">Members Visited</div></div>
                </div>
                <div class="sys-metric-box">
                    <div class="sys-metric-icon sys-icon-green"><i class="fa-solid fa-eye"></i></div>
                    <div><div class="sys-metric-num"><asp:Label ID="lblTotalVisitorsSystem" runat="server" Text="—"></asp:Label></div><div class="sys-metric-lbl">Visitors Visited</div></div>
                </div>
            </div>
        </div>
        <div class="section-cta">
            <a href="SystemReport.aspx" class="sec-btn"><i class="fa-solid fa-arrow-right"></i> View Full Report</a>
        </div>
    </div>

    <!-- CONTENT MANAGEMENT -->
    <div class="dash-section">
        <div class="dash-section-head">
            <div class="dash-section-title"><i class="fa-solid fa-book-open"></i>Content Management</div>
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

</asp:Content>
