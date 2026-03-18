<%@ Page Title="Instructor Dashboard" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorManageContent.aspx.cs" Inherits="Aidcademy.InstructorManageContent" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:32px; }
        @media(max-width:1100px){ .stats-row{grid-template-columns:repeat(2,1fr);} }
        @media(max-width:600px) { .stats-row{grid-template-columns:1fr;} }

        .imc-stat-card { background:white; border-radius:16px; padding:22px 20px; border:1px solid #ebebeb; display:flex; align-items:center; gap:16px; transition:transform 0.2s,box-shadow 0.2s; position:relative; overflow:hidden; }
        .imc-stat-card::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .imc-stat-card.c-red::before    { background:#c9242b; }
        .imc-stat-card.c-amber::before  { background:#f59e0b; }
        .imc-stat-card.c-green::before  { background:#10b981; }
        .imc-stat-card.c-purple::before { background:#8b5cf6; }
        .imc-stat-card:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .imc-stat-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.25rem; flex-shrink:0; }
        .c-red    .imc-stat-icon { background:#fde8e9; color:#c9242b; }
        .c-amber  .imc-stat-icon { background:#fef3c7; color:#d97706; }
        .c-green  .imc-stat-icon { background:#d1fae5; color:#059669; }
        .c-purple .imc-stat-icon { background:#ede9fe; color:#7c3aed; }
        .imc-stat-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .imc-stat-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        .section-bar { display:flex; align-items:center; justify-content:space-between; margin-bottom:18px; flex-wrap:wrap; gap:12px; }
        .section-bar-left { display:flex; align-items:center; gap:14px; flex-wrap:wrap; }
        .section-bar h5 { font-size:1.05rem; font-weight:900; color:#1a1a2e; margin:0; }

        .filter-tabs { display:flex; gap:6px; flex-wrap:wrap; }
        .imc-filter-tab { padding:5px 14px; border-radius:20px; font-size:0.8rem; font-weight:700; border:1.5px solid #e0e0e0; background:white; color:#888; cursor:pointer; transition:all 0.18s; font-family:'Nunito',sans-serif; display:inline-flex; align-items:center; gap:6px; }
        .imc-filter-tab:hover { border-color:#c9242b; color:#c9242b; }
        .imc-filter-tab.f-active-all       { background:#c9242b; border-color:#c9242b; color:white; }
        .imc-filter-tab.f-active-draft     { background:#6b7280; border-color:#6b7280; color:white; }
        .imc-filter-tab.f-active-pending   { background:#f59e0b; border-color:#f59e0b; color:white; }
        .imc-filter-tab.f-active-published { background:#10b981; border-color:#10b981; color:white; }
        .imc-filter-tab.f-active-rejected  { background:#f43f5e; border-color:#f43f5e; color:white; }

        .btn-create-drop { background:#c9242b; border:none; color:white; font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:800; padding:9px 18px; border-radius:10px; cursor:pointer; display:flex; align-items:center; gap:7px; transition:background 0.18s,transform 0.18s; }
        .btn-create-drop:hover { background:#a01c22; transform:translateY(-1px); }
        .create-menu { display:none; position:absolute; right:0; top:calc(100% + 8px); background:white; border:1px solid #ebebeb; border-radius:12px; box-shadow:0 12px 32px rgba(0,0,0,0.1); min-width:220px; z-index:50; overflow:hidden; }
        .create-menu.open { display:block; }
        .create-menu a { display:flex; align-items:center; gap:10px; padding:12px 16px; font-size:0.88rem; font-weight:700; color:#333; text-decoration:none; transition:background 0.15s; }
        .create-menu a:hover { background:#f9f9f9; }
        .m-icon { width:32px; height:32px; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:0.9rem; }

        /* Course header with enrollment badge */
        .course-header { background:white; border-radius:14px; border:1px solid #ebebeb; padding:18px 20px; margin-bottom:16px; display:flex; align-items:center; gap:16px; position:relative; overflow:hidden; }
        .course-header::before { content:''; position:absolute; top:0; left:0; width:5px; height:100%; background:#c9242b; }
        .course-header img { width:72px; height:72px; border-radius:12px; object-fit:cover; flex-shrink:0; border:1px solid #ebebeb; }
        .course-header-info { flex:1; }
        .course-header h4 { font-size:1.05rem; font-weight:900; color:#1a1a2e; margin-bottom:5px; }
        .cat-badge { display:inline-flex; align-items:center; gap:5px; background:#fde8e9; color:#c9242b; font-size:0.75rem; font-weight:800; padding:3px 10px; border-radius:20px; }
        .course-desc { font-size:0.85rem; color:#888; margin-top:5px; line-height:1.5; }
        .enrolled-badge { display:inline-flex; align-items:center; gap:6px; background:#dbeafe; color:#1e40af; font-size:0.78rem; font-weight:800; padding:5px 12px; border-radius:10px; white-space:nowrap; flex-shrink:0; }

        .lesson-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(220px,1fr)); gap:16px; margin-bottom:32px; }
        .imc-lesson-card { background:white; border-radius:14px; border:1px solid #ebebeb; overflow:hidden; transition:transform 0.22s,box-shadow 0.22s; display:flex; flex-direction:column; }
        .imc-lesson-card:hover { transform:translateY(-5px); box-shadow:0 16px 40px rgba(0,0,0,0.09); }

        .lesson-stripe { height:4px; width:100%; }
        .stripe-draft     { background:#9ca3af; }
        .stripe-pending   { background:#f59e0b; }
        .stripe-published { background:#10b981; }
        .stripe-rejected  { background:#f43f5e; }

        .lesson-thumb-wrap { height:150px; background:#f5f5f5; overflow:hidden; position:relative; }
        .lesson-thumb-wrap img { width:100%; height:100%; object-fit:cover; display:block; }
        .lesson-status-badge { position:absolute; top:8px; right:8px; font-size:0.7rem; font-weight:800; padding:3px 8px; border-radius:20px; display:inline-flex; align-items:center; gap:4px; }
        .badge-draft     { background:#f3f4f6; color:#6b7280; }
        .badge-pending   { background:#fef3c7; color:#92400e; }
        .badge-published { background:#d1fae5; color:#065f46; }
        .badge-rejected  { background:#ffe4e6; color:#9f1239; }

        /* Completion stat on lesson card */
        .lesson-completion { position:absolute; bottom:8px; left:8px; font-size:0.68rem; font-weight:800; padding:2px 8px; border-radius:10px; background:rgba(0,0,0,0.55); color:white; display:inline-flex; align-items:center; gap:4px; }

        .lesson-body { padding:14px 16px; flex:1; display:flex; flex-direction:column; }
        .lesson-step  { font-size:0.72rem; font-weight:800; color:#bbb; text-transform:uppercase; letter-spacing:0.5px; margin-bottom:5px; }
        .lesson-title { font-size:0.95rem; font-weight:800; color:#1a1a2e; line-height:1.4; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; }
        .lesson-desc  { font-size:0.8rem; color:#aaa; line-height:1.5; margin-top:7px; display:-webkit-box; -webkit-line-clamp:2; -webkit-box-orient:vertical; overflow:hidden; flex:1; }
        .lesson-footer { padding:10px 14px; border-top:1px solid #f5f5f5; display:flex; gap:8px; justify-content:flex-end; }
        .btn-card-action { display:inline-flex; align-items:center; gap:5px; padding:6px 13px; border-radius:8px; font-size:0.8rem; font-weight:700; font-family:'Nunito',sans-serif; cursor:pointer; transition:all 0.18s; border:1.5px solid; text-decoration:none; background:white; }
        .btn-card-edit  { border-color:#3b82f6; color:#3b82f6; }
        .btn-card-edit:hover { background:#3b82f6; color:white; }
        .btn-card-del   { border-color:#c9242b; color:#c9242b; }
        .btn-card-del:hover { background:#c9242b; color:white; }

        /* Empty state */
        .empty-state { text-align:center; padding:64px 24px; background:white; border-radius:16px; border:1.5px dashed #e0e0e0; }
        .empty-state-icon { width:80px; height:80px; background:#fde8e9; border-radius:20px; display:flex; align-items:center; justify-content:center; font-size:2rem; color:#c9242b; margin:0 auto 20px; }
        .empty-state h4 { font-size:1.2rem; font-weight:900; color:#1a1a2e; margin-bottom:8px; }
        .empty-state p  { font-size:0.9rem; color:#aaa; margin-bottom:24px; }
        .btn-empty-cta { display:inline-flex; align-items:center; gap:8px; background:#c9242b; border:none; color:white; font-family:'Nunito',sans-serif; font-size:0.95rem; font-weight:800; padding:12px 28px; border-radius:12px; cursor:pointer; text-decoration:none; transition:all 0.18s; }
        .btn-empty-cta:hover { background:#a01c22; transform:translateY(-1px); color:white; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2>Instructor Dashboard 👋</h2>
        <p>Manage your first aid learning materials and member interactions.</p>
    </div>

    <div class="stats-row">
        <div class="imc-stat-card c-red">
            <div class="imc-stat-icon"><i class="fa-solid fa-book-open"></i></div>
            <div><div class="imc-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></div><div class="imc-stat-label">Total Lessons</div></div>
        </div>
        <div class="imc-stat-card c-amber">
            <div class="imc-stat-icon"><i class="fa-solid fa-clock-rotate-left"></i></div>
            <div><div class="imc-stat-value"><asp:Label ID="lblPending" runat="server" Text="0"></asp:Label></div><div class="imc-stat-label">Pending Approval</div></div>
        </div>
        <div class="imc-stat-card c-green">
            <div class="imc-stat-icon"><i class="fa-solid fa-clipboard-check"></i></div>
            <div><div class="imc-stat-value"><asp:Label ID="lblPublished" runat="server" Text="0"></asp:Label></div><div class="imc-stat-label">Published</div></div>
        </div>
        <div class="imc-stat-card c-purple">
            <div class="imc-stat-icon"><i class="fa-solid fa-comments"></i></div>
            <div><div class="imc-stat-value"><asp:Label ID="lblQueries" runat="server" Text="0"></asp:Label></div><div class="imc-stat-label">Unanswered Queries</div></div>
        </div>
    </div>

    <div class="section-bar">
        <div class="section-bar-left">
            <h5><i class="fa-solid fa-folder-tree" style="color:#c9242b;margin-right:8px;"></i>Course Curriculum</h5>
            <div class="filter-tabs">
                <button type="button" class="imc-filter-tab f-active-all" id="tab-All"       onclick="filterLessons('All')"><i class="fa-solid fa-list"></i> All</button>
                <button type="button" class="imc-filter-tab"              id="tab-Draft"     onclick="filterLessons('Draft')"><i class="fa-solid fa-pencil" style="color:#9ca3af;"></i> Draft</button>
                <button type="button" class="imc-filter-tab"              id="tab-Pending"   onclick="filterLessons('Pending Admin')"><i class="fa-solid fa-clock" style="color:#f59e0b;"></i> Pending</button>
                <button type="button" class="imc-filter-tab"              id="tab-Published" onclick="filterLessons('Published')"><i class="fa-solid fa-check-circle" style="color:#10b981;"></i> Published</button>
                <button type="button" class="imc-filter-tab"              id="tab-Rejected"  onclick="filterLessons('Rejected')"><i class="fa-solid fa-circle-xmark" style="color:#f43f5e;"></i> Rejected</button>
            </div>
        </div>
        <div style="position:relative;">
            <button type="button" class="btn-create-drop" onclick="toggleCreateMenu()">
                <i class="fa-solid fa-plus"></i> Create <i class="fa-solid fa-chevron-down" style="font-size:0.7rem;"></i>
            </button>
            <div class="create-menu" id="createMenu">
                <a href="InstructorUploadLesson.aspx"><div class="m-icon" style="background:#fde8e9;color:#c9242b;"><i class="fa-solid fa-file-lines"></i></div>New Lesson / Course</a>
                <hr style="margin:0;border-color:#f0f0f0;" />
                <a href="InstructorUploadQuiz.aspx"><div class="m-icon" style="background:#fef3c7;color:#d97706;"><i class="fa-solid fa-clipboard-question"></i></div>Manage Quizzes</a>
            </div>
        </div>
    </div>

    <%-- COURSES REPEATER --%>
    <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
        <ItemTemplate>
            <div class="category-group">
                <div class="course-header">
                    <img src='<%# Eval("CourseThumbnailPath") != DBNull.Value && !string.IsNullOrEmpty(Eval("CourseThumbnailPath").ToString()) ? ResolveUrl(Eval("CourseThumbnailPath").ToString()) : "image/default-course.png" %>' alt="Course" />
                    <div class="course-header-info">
                        <h4><%# Eval("CourseTitle") %> <span class="cat-badge"><i class="fa-solid fa-tag"></i><%# Eval("Category") %></span></h4>
                        <div class="course-desc"><%# Eval("CourseDescription") %></div>
                    </div>
                    <%-- Enrolled member count --%>
                    <div class="enrolled-badge">
                        <i class="fa-solid fa-users"></i>
                        <%# Eval("EnrolledCount") %> enrolled
                    </div>
                </div>

                <div class="lesson-grid">
                    <asp:Repeater ID="rptLessons" runat="server">
                        <ItemTemplate>
                            <div class="imc-lesson-card">
                                <%-- Color stripe: Draft=gray, Pending=amber, Rejected=red, Approved/Published=green --%>
                                <div class='lesson-stripe <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "stripe-draft" : Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "stripe-pending" : Convert.ToString(Eval("ApprovalStatus")) == "Rejected" ? "stripe-rejected" : "stripe-published" %>'></div>
                                <div class="lesson-thumb-wrap">
                                    <img src='<%# Eval("LessonThumbnailPath") != DBNull.Value && !string.IsNullOrEmpty(Eval("LessonThumbnailPath").ToString()) ? ResolveUrl(Eval("LessonThumbnailPath").ToString()) : "image/default-lesson.png" %>' alt="Lesson" />
                                    <%-- Status badge — normalise "Approved" → "Published" in display --%>
                                    <span class='lesson-status-badge <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "badge-draft" : Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "badge-pending" : Convert.ToString(Eval("ApprovalStatus")) == "Rejected" ? "badge-rejected" : "badge-published" %>'>
                                        <i class='fa-solid <%# Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "fa-clock" : (Convert.ToString(Eval("ApprovalStatus")) == "Published" || Convert.ToString(Eval("ApprovalStatus")) == "Approved") ? "fa-check-circle" : Convert.ToString(Eval("ApprovalStatus")) == "Rejected" ? "fa-circle-xmark" : "fa-pencil" %>'></i>
                                        <%# (Convert.ToString(Eval("ApprovalStatus")) == "Approved") ? "Published" : Eval("ApprovalStatus") %>
                                    </span>
                                    <%-- Member completion count — must use <%# %> not <% %> --%>
                                    <%# Convert.ToInt32(Eval("CompletedCount")) > 0
                                        ? "<span class='lesson-completion'><i class='fa-solid fa-users'></i> " + Eval("CompletedCount") + " completed</span>"
                                        : "" %>
                                </div>
                                <div class="lesson-body">
                                    <div class="lesson-step">Step <%# Eval("SequenceOrder") %></div>
                                    <div class="lesson-title"><%# Eval("LessonTitle") %></div>
                                    <div class="lesson-desc"><%# Eval("LessonDescription") %></div>
                                </div>
                                <div class="lesson-footer">
                                    <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-card-action btn-card-edit" CommandArgument='<%# Eval("LessonID") %>' OnClick="btnEditLesson_Click" ToolTip="Edit Lesson"><i class="fa-solid fa-pen"></i> Edit</asp:LinkButton>
                                    <asp:LinkButton ID="btnDel"  runat="server" CssClass="btn-card-action btn-card-del"  CommandArgument='<%# Eval("LessonID") %>' OnClick="btnDeleteLesson_Click" data-lesson-title='<%# Eval("LessonTitle") %>' OnClientClick="return confirmLessonDelete(this);" ToolTip="Delete Lesson"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <%-- EMPTY STATE — shown via JS after page load if no category-group divs found --%>
    <div id="emptyState" style="display:none;">
        <div class="empty-state">
            <div class="empty-state-icon"><i class="fa-solid fa-folder-open"></i></div>
            <h4>No Courses Yet</h4>
            <p>You haven't created any courses or lessons. Start building your first aid curriculum!</p>
            <a href="InstructorUploadLesson.aspx" class="btn-empty-cta">
                <i class="fa-solid fa-plus"></i> Create Your First Lesson
            </a>
        </div>
    </div>

</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
<script>
    // Show empty state if no courses rendered
    (function () {
        var groups = document.querySelectorAll('.category-group');
        if (groups.length === 0) {
            document.getElementById('emptyState').style.display = 'block';
        }
    })();

    function toggleCreateMenu() {
        document.getElementById('createMenu').classList.toggle('open');
    }
    document.addEventListener('click', function (e) {
        var btn = document.querySelector('.btn-create-drop');
        var menu = document.getElementById('createMenu');
        if (menu && btn && !btn.parentElement.contains(e.target)) menu.classList.remove('open');
    });

    function filterLessons(status) {
        var cls = {
            'All': 'f-active-all',
            'Draft': 'f-active-draft',
            'Pending Admin': 'f-active-pending',
            'Published': 'f-active-published',
            'Rejected': 'f-active-rejected'
        };
        var ids = {
            'All': 'tab-All',
            'Draft': 'tab-Draft',
            'Pending Admin': 'tab-Pending',
            'Published': 'tab-Published',
            'Rejected': 'tab-Rejected'
        };
        document.querySelectorAll('.imc-filter-tab').forEach(function (b) { b.className = 'imc-filter-tab'; });
        var el = document.getElementById(ids[status]);
        if (el) el.classList.add(cls[status]);

        // FIX: hide/show the CARD itself, not card.parentElement (.lesson-grid)
        document.querySelectorAll('.imc-lesson-card').forEach(function (card) {
            if (status === 'All') { card.style.display = ''; return; }
            var badge = card.querySelector('.lesson-status-badge');
            var badgeText = badge ? badge.textContent.trim() : '';
            // "Published" filter matches both "Published" and "Approved" DB values
            if (status === 'Published') {
                card.style.display = (badgeText === 'Published' || badgeText === 'Approved') ? '' : 'none';
            } else {
                card.style.display = (badgeText === status) ? '' : 'none';
            }
        });
        // Hide course group if ALL its lesson cards are hidden
        document.querySelectorAll('.category-group').forEach(function (group) {
            var all = group.querySelectorAll('.imc-lesson-card');
            var hidden = Array.from(all).filter(function (c) { return c.style.display === 'none'; });
            group.style.display = (status !== 'All' && hidden.length === all.length) ? 'none' : '';
        });
    }

    function confirmLessonDelete(btn) {
        var name = btn.getAttribute('data-lesson-title');
        var input = prompt('To delete this lesson, type its name exactly:\n' + name.trim());
        if (input === null) return false;
        if (input !== name.trim()) { alert('Delete Cancelled: The name did not match.'); return false; }
        return true;
    }
</script>
</asp:Content>
