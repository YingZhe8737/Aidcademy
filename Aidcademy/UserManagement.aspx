<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="Aidcademy.UserManagement" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">User Management — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        .stats-row { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:28px; }
        @media(max-width:1100px){ .stats-row{grid-template-columns:repeat(2,1fr);} }

        .um-stat {
            background:white; border-radius:16px; padding:22px 20px; border:1px solid #ebebeb;
            display:flex; align-items:center; gap:16px; position:relative; overflow:hidden;
            transition:transform 0.2s,box-shadow 0.2s;
        }
        .um-stat::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .um-stat.c-red::before    { background:#c9242b; }
        .um-stat.c-green::before  { background:#10b981; }
        .um-stat.c-amber::before  { background:#f59e0b; }
        .um-stat.c-gray::before   { background:#9ca3af; }
        .um-stat:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .um-stat-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .c-red   .um-stat-icon { background:#fde8e9; color:#c9242b; }
        .c-green .um-stat-icon { background:#d1fae5; color:#059669; }
        .c-amber .um-stat-icon { background:#fef3c7; color:#d97706; }
        .c-gray  .um-stat-icon { background:#f3f4f6; color:#6b7280; }
        .um-stat-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .um-stat-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        .filter-card { background:white; border-radius:14px; border:1px solid #ebebeb; padding:18px 22px; margin-bottom:22px; display:flex; align-items:center; gap:14px; flex-wrap:wrap; }
        .filter-card .form-control, .filter-card .form-select {
            font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:600;
            border:1.5px solid #e0e0e0; border-radius:9px; padding:8px 14px;
        }
        .filter-card .form-control:focus, .filter-card .form-select:focus { border-color:#c9242b; box-shadow:none; outline:none; }
        .filter-card .form-control { min-width:260px; }
        .btn-mod {
            display:inline-flex; align-items:center; gap:7px;
            background:#c9242b; color:white; border:none; font-family:'Nunito',sans-serif;
            font-size:0.85rem; font-weight:700; padding:9px 18px; border-radius:10px;
            cursor:pointer; text-decoration:none; transition:background 0.18s; white-space:nowrap;
        }
        .btn-mod:hover { background:#a01c22; color:white; }

        .table-card { background:white; border-radius:16px; border:1px solid #ebebeb; overflow:hidden; }
        .table-card-head { padding:16px 22px; border-bottom:1px solid #f5f5f5; font-size:0.95rem; font-weight:900; color:#1a1a2e; }

        .user-table { width:100%; border-collapse:collapse; font-size:0.88rem; }
        .user-table th { padding:12px 16px; background:#f9f9f9; font-size:0.75rem; font-weight:800; color:#888; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid #f0f0f0; text-align:left; }
        .user-table td { padding:13px 16px; border-bottom:1px solid #f5f5f5; color:#333; font-weight:600; }
        .user-table tr:last-child td { border-bottom:none; }
        .user-table tr:hover td { background:#fafafa; }

        .btn-status {
            padding:5px 13px; border-radius:8px; font-size:0.78rem; font-weight:700;
            font-family:'Nunito',sans-serif; cursor:pointer; border:1.5px solid #c9242b;
            color:#c9242b; background:white; transition:all 0.18s;
        }
        .btn-status:hover { background:#c9242b; color:white; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-users" style="color:#c9242b;margin-right:8px;"></i>User Management</h2>
        <p>View, filter, and manage all platform users.</p>
    </div>

    <!-- STAT CARDS -->
    <div class="stats-row">
        <div class="um-stat c-red">
            <div class="um-stat-icon"><i class="fa-solid fa-users"></i></div>
            <div><div class="um-stat-value"><asp:Label ID="lblTotalMembers" runat="server" Text="0"></asp:Label></div><div class="um-stat-label">Total Users</div></div>
        </div>
        <div class="um-stat c-green">
            <div class="um-stat-icon"><i class="fa-solid fa-circle-check"></i></div>
            <div><div class="um-stat-value"><asp:Label ID="lblTotalActive" runat="server" Text="0"></asp:Label></div><div class="um-stat-label">Active</div></div>
        </div>
        <div class="um-stat c-amber">
            <div class="um-stat-icon"><i class="fa-solid fa-circle-pause"></i></div>
            <div><div class="um-stat-value"><asp:Label ID="LblTotalSuspended" runat="server" Text="0"></asp:Label></div><div class="um-stat-label">Suspended</div></div>
        </div>
        <div class="um-stat c-gray">
            <div class="um-stat-icon"><i class="fa-solid fa-circle-xmark"></i></div>
            <div><div class="um-stat-value"><asp:Label ID="LblTotalDeactivated" runat="server" Text="0"></asp:Label></div><div class="um-stat-label">Deactivated</div></div>
        </div>
    </div>

    <!-- FILTERS -->
    <div class="filter-card">
        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Search by username or email…" AutoPostBack="true" OnTextChanged="Filter_Changed" />
        <asp:DropDownList ID="ddlRole" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" style="width:160px;">
            <asp:ListItem>All Roles</asp:ListItem>
            <asp:ListItem>Member</asp:ListItem>
            <asp:ListItem>Instructor</asp:ListItem>
            <asp:ListItem>Admin</asp:ListItem>
        </asp:DropDownList>
        <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed" style="width:160px;">
            <asp:ListItem>All Status</asp:ListItem>
            <asp:ListItem>Active</asp:ListItem>
            <asp:ListItem>Suspended</asp:ListItem>
            <asp:ListItem>Deactivated</asp:ListItem>
        </asp:DropDownList>
        <a href="AccountModification.aspx" class="btn-mod"><i class="fa-solid fa-user-plus"></i> Create Account</a>
    </div>

    <!-- TABLE -->
    <div class="table-card">
        <div class="table-card-head"><i class="fa-solid fa-table-list" style="color:#c9242b;margin-right:8px;"></i>All Users</div>
        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="user-table"
            OnRowCommand="gvUsers_RowCommand" OnSelectedIndexChanged="gvUsers_SelectedIndexChanged">
            <Columns>
                <asp:BoundField DataField="UserID"      HeaderText="ID" />
                <asp:BoundField DataField="Username"    HeaderText="Username" />
                <asp:BoundField DataField="Email"       HeaderText="Email" />
                <asp:BoundField DataField="Role"        HeaderText="Role" />
                <asp:BoundField DataField="Status"      HeaderText="Status" />
                <asp:BoundField DataField="CreatedDate" HeaderText="Created" DataFormatString="{0:dd/MM/yyyy}" />
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <asp:Button ID="btnStatus" runat="server" Text="Change Status"
                            CssClass="btn-status" CommandName="ChangeStatus"
                            CommandArgument='<%# Eval("UserID") %>' />
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

</asp:Content>
