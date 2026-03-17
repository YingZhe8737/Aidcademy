<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReviewManagement.aspx.cs" Inherits="Aidcademy.ReviewManagement" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">Reviews — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        .stats-row { display:grid; grid-template-columns:repeat(3,1fr); gap:16px; margin-bottom:28px; }
        @media(max-width:900px){ .stats-row{grid-template-columns:repeat(2,1fr);} }
        .rv-stat {
            background:white; border-radius:16px; padding:22px 20px; border:1px solid #ebebeb;
            display:flex; align-items:center; gap:16px; position:relative; overflow:hidden;
            transition:transform 0.2s,box-shadow 0.2s;
        }
        .rv-stat::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .rv-stat.c-red::before    { background:#c9242b; }
        .rv-stat.c-blue::before   { background:#3b82f6; }
        .rv-stat.c-amber::before  { background:#f59e0b; }
        .rv-stat:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .rv-stat-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .c-red   .rv-stat-icon { background:#fde8e9; color:#c9242b; }
        .c-blue  .rv-stat-icon { background:#dbeafe; color:#2563eb; }
        .c-amber .rv-stat-icon { background:#fef3c7; color:#d97706; }
        .rv-stat-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .rv-stat-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        /* Filter bar */
        .filter-card { background:white; border-radius:14px; border:1px solid #ebebeb; padding:16px 20px; margin-bottom:22px; display:flex; align-items:center; gap:12px; flex-wrap:wrap; }
        .filter-card .form-control, .filter-card .form-select { font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:600; border:1.5px solid #e0e0e0; border-radius:9px; padding:8px 14px; }
        .filter-card .form-control:focus, .filter-card .form-select:focus { border-color:#c9242b; box-shadow:none; outline:none; }

        /* Cards grid */
        .reviews-grid { display:grid; grid-template-columns:repeat(auto-fill, minmax(320px,1fr)); gap:16px; }

        .review-card {
            background:white; border-radius:16px; border:1px solid #ebebeb;
            padding:20px; transition:transform 0.22s, box-shadow 0.22s;
            display:flex; flex-direction:column; gap:12px;
            position:relative; overflow:hidden;
            border-left:4px solid #ebebeb;
        }
        .review-card.cat-resources { border-left-color:#3b82f6; }
        .review-card.cat-webdesign { border-left-color:#10b981; }
        .review-card.cat-bug       { border-left-color:#f43f5e; }
        .review-card.cat-general   { border-left-color:#f59e0b; }
        .review-card:hover { transform:translateY(-4px); box-shadow:0 16px 40px rgba(0,0,0,0.08); }

        .review-card-head { display:flex; align-items:center; justify-content:space-between; }
        .cat-badge-rv { display:inline-flex; align-items:center; gap:5px; padding:4px 12px; border-radius:20px; font-size:0.75rem; font-weight:800; background:white; border:1.5px solid; }
        .cat-resources { border-color:#3b82f6; color:#1e40af; }
        .cat-webdesign { border-color:#10b981; color:#065f46; }
        .cat-bug       { border-color:#f43f5e; color:#9f1239; }
        .cat-general   { border-color:#f59e0b; color:#92400e; }

        .review-id { font-size:0.75rem; color:#bbb; font-weight:700; }
        .review-message { font-size:0.9rem; color:#444; line-height:1.65; font-weight:600; flex:1; }
        .review-meta { font-size:0.75rem; color:#bbb; font-weight:700; display:flex; align-items:center; gap:5px; }

        /* Empty state */
        .empty-state { text-align:center; padding:60px 20px; background:white; border-radius:16px; border:1.5px dashed #e0e0e0; }
        .empty-state i { font-size:2.5rem; color:#e0e0e0; margin-bottom:14px; display:block; }
        .empty-state p { font-size:1rem; font-weight:700; color:#bbb; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-star" style="color:#c9242b;margin-right:8px;"></i>Reviews &amp; Feedback</h2>
        <p>All user-submitted feedback from the platform.</p>
    </div>

    <!-- STAT CARDS -->
    <div class="stats-row">
        <div class="rv-stat c-red">
            <div class="rv-stat-icon"><i class="fa-solid fa-envelope-open-text"></i></div>
            <div><div class="rv-stat-value"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></div><div class="rv-stat-label">Total Feedback</div></div>
        </div>
        <div class="rv-stat c-blue">
            <div class="rv-stat-icon"><i class="fa-solid fa-book-open-reader"></i></div>
            <div><div class="rv-stat-value"><asp:Label ID="lblResources" runat="server" Text="0"></asp:Label></div><div class="rv-stat-label">Resources / Module</div></div>
        </div>
        <div class="rv-stat c-amber">
            <div class="rv-stat-icon"><i class="fa-solid fa-bug"></i></div>
            <div><div class="rv-stat-value"><asp:Label ID="lblBugs" runat="server" Text="0"></asp:Label></div><div class="rv-stat-label">Bug Reports</div></div>
        </div>
    </div>

    <!-- FILTER -->
    <div class="filter-card">
        <i class="fa-solid fa-filter" style="color:#c9242b;"></i>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search feedback…" AutoPostBack="true" OnTextChanged="Filter_Changed" style="min-width:260px;" />
        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" style="width:200px;">
            <asp:ListItem Text="All Categories" Value="" />
            <asp:ListItem Text="Resources / Module" Value="Resources" />
            <asp:ListItem Text="Web Design"          Value="WebDesign" />
            <asp:ListItem Text="Bug Report"          Value="Bug" />
            <asp:ListItem Text="General"             Value="General" />
        </asp:DropDownList>
    </div>

    <!-- REVIEW CARDS -->
    <asp:Repeater ID="rptReviews" runat="server">
        <HeaderTemplate><div class="reviews-grid"></HeaderTemplate>
        <ItemTemplate>
            <div class='review-card cat-<%# Eval("Category").ToString().ToLower().Replace(" ","").Replace("/","") %>'>
                <div class="review-card-head">
                    <span class='cat-badge-rv cat-<%# Eval("Category").ToString().ToLower().Replace(" ","").Replace("/","") %>'>
                        <i class='fa-solid <%# GetCategoryIcon(Eval("Category").ToString()) %>'></i>
                        <%# Eval("Category") %>
                    </span>
                    <span class="review-id">#<%# Eval("FeedbackID") %></span>
                </div>
                <div class="review-message"><%# System.Web.HttpUtility.HtmlEncode(Eval("MessageText").ToString()) %></div>
                <div class="review-meta">
                    <i class="fa-regular fa-clock"></i>
                    <%# Eval("SubmittedAt") != DBNull.Value ? Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy, HH:mm") : "Unknown date" %>
                </div>
            </div>
        </ItemTemplate>
        <FooterTemplate></div></FooterTemplate>
    </asp:Repeater>

    <asp:Panel ID="pnlEmpty" runat="server" Visible="false">
        <div class="empty-state">
            <i class="fa-solid fa-inbox"></i>
            <p>No feedback found.</p>
        </div>
    </asp:Panel>

</asp:Content>
