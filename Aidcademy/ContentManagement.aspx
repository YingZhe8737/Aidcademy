<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentManagement.aspx.cs" Inherits="Aidcademy.ContentManagement" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">Content Management — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:28px; }
        @media(max-width:1100px){ .stats-row{grid-template-columns:repeat(2,1fr);} }

        .cm-stat {
            background:white; border-radius:16px; padding:22px 20px; border:1px solid #ebebeb;
            display:flex; align-items:center; gap:16px; position:relative; overflow:hidden;
            transition:transform 0.2s,box-shadow 0.2s;
        }
        .cm-stat::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .cm-stat.c-red::before    { background:#c9242b; }
        .cm-stat.c-amber::before  { background:#f59e0b; }
        .cm-stat.c-green::before  { background:#10b981; }
        .cm-stat.c-rose::before   { background:#f43f5e; }
        .cm-stat:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .cm-stat-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .c-red   .cm-stat-icon { background:#fde8e9; color:#c9242b; }
        .c-amber .cm-stat-icon { background:#fef3c7; color:#d97706; }
        .c-green .cm-stat-icon { background:#d1fae5; color:#059669; }
        .c-rose  .cm-stat-icon { background:#ffe4e6; color:#e11d48; }
        .cm-stat-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .cm-stat-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        /* Filter bar */
        .filter-bar { display:flex; align-items:center; justify-content:space-between; margin-bottom:18px; flex-wrap:wrap; gap:10px; }
        .filter-bar h5 { font-size:1.05rem; font-weight:900; color:#1a1a2e; margin:0; display:flex; align-items:center; gap:8px; }
        .filter-bar h5 i { color:#c9242b; }
        .filter-tabs { display:flex; gap:6px; flex-wrap:wrap; }
        .filter-tab-btn {
            padding:5px 14px; border-radius:20px; font-size:0.8rem; font-weight:700;
            border:1.5px solid #e0e0e0; background:white; color:#888; cursor:pointer;
            transition:all 0.18s; font-family:'Nunito',sans-serif; text-decoration:none;
            display:inline-flex; align-items:center; gap:5px;
        }
        .filter-tab-btn:hover { border-color:#c9242b; color:#c9242b; }

        /* Course & Lesson cards */
        .course-group { margin-bottom:28px; }
        .course-heading {
            background:white; border-radius:14px; border:1px solid #ebebeb;
            padding:16px 20px; margin-bottom:14px; display:flex; align-items:center; gap:10px;
            position:relative; overflow:hidden; font-size:1rem; font-weight:900; color:#1a1a2e;
        }
        .course-heading::before { content:''; position:absolute; top:0; left:0; width:5px; height:100%; background:#c9242b; }
        .cat-badge { background:#fde8e9; color:#c9242b; font-size:0.75rem; font-weight:800; padding:3px 10px; border-radius:20px; display:inline-flex; align-items:center; gap:4px; }
        .instructor-name { font-size:0.82rem; font-weight:600; color:#888; margin-left:auto; }

        .lessons-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:14px; }
        .lesson-card {
            background:white; border-radius:14px; border:1px solid #ebebeb; overflow:hidden;
            transition:transform 0.22s,box-shadow 0.22s; display:flex; flex-direction:column;
        }
        .lesson-card:hover { transform:translateY(-5px); box-shadow:0 16px 40px rgba(0,0,0,0.09); }

        /* Status-based top stripe */
        .lesson-card.status-Draft     { border-top:4px solid #9ca3af; }
        .lesson-card.status-Pending   { border-top:4px solid #f59e0b; }
        .lesson-card.status-Published { border-top:4px solid #10b981; }
        .lesson-card.status-Rejected  { border-top:4px solid #f43f5e; }

        .lesson-card-body { padding:16px; display:flex; flex-direction:column; flex:1; }
        .card-top-row { display:flex; align-items:center; justify-content:space-between; margin-bottom:10px; }
        .step-badge { font-size:0.72rem; font-weight:800; color:#bbb; text-transform:uppercase; letter-spacing:0.5px; }
        .status-badge { font-size:0.72rem; font-weight:800; padding:3px 9px; border-radius:20px; }
        .status-badge.Draft     { background:#f3f4f6; color:#6b7280; }
        .status-badge.Pending   { background:#fef3c7; color:#92400e; }
        .status-badge.Published { background:#d1fae5; color:#065f46; }
        .status-badge.Rejected  { background:#ffe4e6; color:#9f1239; }

        .lesson-title { font-size:0.95rem; font-weight:800; color:#1a1a2e; line-height:1.4; flex:1; }
        .card-footer-row { margin-top:14px; }
        .view-btn {
            display:inline-flex; align-items:center; gap:6px;
            background:#c9242b; color:white; border:none; font-family:'Nunito',sans-serif;
            font-size:0.8rem; font-weight:700; padding:7px 14px; border-radius:8px;
            cursor:pointer; text-decoration:none; transition:background 0.18s;
        }
        .view-btn:hover { background:#a01c22; color:white; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-book-open" style="color:#c9242b;margin-right:8px;"></i>Content Management</h2>
        <p>Review and approve instructor-submitted lessons before they go live.</p>
    </div>

    <!-- STAT CARDS -->
    <div class="stats-row">
        <div class="cm-stat c-red">
            <div class="cm-stat-icon"><i class="fa-solid fa-book-open"></i></div>
            <div><div class="cm-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0" /></div><div class="cm-stat-label">Total Lessons</div></div>
        </div>
        <div class="cm-stat c-amber">
            <div class="cm-stat-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
            <div><div class="cm-stat-value"><asp:Label ID="lblPending" runat="server" Text="0" /></div><div class="cm-stat-label">Pending Review</div></div>
        </div>
        <div class="cm-stat c-green">
            <div class="cm-stat-icon"><i class="fa-solid fa-clipboard-check"></i></div>
            <div><div class="cm-stat-value"><asp:Label ID="lblPublished" runat="server" Text="0" /></div><div class="cm-stat-label">Published</div></div>
        </div>
        <div class="cm-stat c-rose">
            <div class="cm-stat-icon"><i class="fa-solid fa-circle-xmark"></i></div>
            <div><div class="cm-stat-value"><asp:Label ID="lblRejected" runat="server" Text="0" /></div><div class="cm-stat-label">Rejected</div></div>
        </div>
    </div>

    <!-- FILTER BAR -->
    <div class="filter-bar">
        <h5><i class="fa-solid fa-folder-tree"></i>Course Curriculum</h5>
        <div class="filter-tabs">
            <asp:LinkButton runat="server" CssClass="filter-tab-btn" CommandArgument="All"           OnClick="btnFilter_Click"><i class="fa-solid fa-list"></i>All</asp:LinkButton>
            <asp:LinkButton runat="server" CssClass="filter-tab-btn" CommandArgument="Pending Admin" OnClick="btnFilter_Click"><i class="fa-solid fa-clock" style="color:#f59e0b;"></i>Pending</asp:LinkButton>
            <asp:LinkButton runat="server" CssClass="filter-tab-btn" CommandArgument="Published"     OnClick="btnFilter_Click"><i class="fa-solid fa-check" style="color:#10b981;"></i>Published</asp:LinkButton>
            <asp:LinkButton runat="server" CssClass="filter-tab-btn" CommandArgument="Rejected"      OnClick="btnFilter_Click"><i class="fa-solid fa-circle-xmark" style="color:#f43f5e;"></i>Rejected</asp:LinkButton>
        </div>
    </div>

    <!-- COURSES → LESSONS -->
    <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
        <ItemTemplate>
            <div class="course-group">
                <div class="course-heading">
                    <i class="fa-solid fa-book-medical" style="color:#c9242b;"></i>
                    <%# Eval("CourseTitle") %>
                    <span class="cat-badge"><i class="fa-solid fa-tag"></i><%# Eval("Category") %></span>
                    <span class="instructor-name"><i class="fa-solid fa-user-tie" style="margin-right:4px;"></i><%# Eval("InstructorName") %></span>
                </div>
                <div class="lessons-grid">
                    <asp:Repeater ID="rptLessons" runat="server">
                        <ItemTemplate>
                            <div class='lesson-card <%# GetStatusCssClass(Eval("ApprovalStatus").ToString()) %>'>
                                <div class="lesson-card-body">
                                    <div class="card-top-row">
                                        <span class="step-badge">Step <%# Eval("SequenceOrder") %></span>
                                        <span class='status-badge <%# GetStatusBadgeClassSimple(Eval("ApprovalStatus").ToString()) %>'><%# Eval("ApprovalStatus") %></span>
                                    </div>
                                    <div class="lesson-title"><%# Eval("Title") %></div>
                                    <div class="card-footer-row">
                                        <asp:LinkButton ID="btnView" runat="server" CssClass="view-btn"
                                            CommandArgument='<%# Eval("LessonID") %>' OnClick="btnViewLesson_Click">
                                            <i class="fa-solid fa-eye"></i> View Details
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

</asp:Content>
