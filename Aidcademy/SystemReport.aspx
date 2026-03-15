<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemReport.aspx.cs" Inherits="Aidcademy.SystemReport" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">System Report — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        .stats-row { display:grid; grid-template-columns:repeat(2,1fr); gap:16px; margin-bottom:28px; max-width:600px; }

        .sr-stat {
            background:white; border-radius:16px; padding:22px 20px; border:1px solid #ebebeb;
            display:flex; align-items:center; gap:16px; position:relative; overflow:hidden;
            transition:transform 0.2s,box-shadow 0.2s;
        }
        .sr-stat::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .sr-stat.c-blue::before  { background:#3b82f6; }
        .sr-stat.c-green::before { background:#10b981; }
        .sr-stat:hover { transform:translateY(-4px); box-shadow:0 12px 32px rgba(0,0,0,0.08); }
        .sr-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.2rem; flex-shrink:0; }
        .c-blue  .sr-icon { background:#dbeafe; color:#2563eb; }
        .c-green .sr-icon { background:#d1fae5; color:#059669; }
        .sr-value { font-size:1.9rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .sr-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }

        .filter-card { background:white; border-radius:14px; border:1px solid #ebebeb; padding:18px 22px; margin-bottom:22px; display:flex; align-items:center; gap:14px; flex-wrap:wrap; }
        .filter-card label { font-size:0.82rem; font-weight:700; color:#888; white-space:nowrap; }
        .filter-card .form-control {
            font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:600;
            border:1.5px solid #e0e0e0; border-radius:9px; padding:8px 14px;
        }
        .filter-card .form-control:focus { border-color:#c9242b; box-shadow:none; outline:none; }

        .table-card { background:white; border-radius:16px; border:1px solid #ebebeb; overflow:hidden; }
        .table-card-head { padding:16px 22px; border-bottom:1px solid #f5f5f5; font-size:0.95rem; font-weight:900; color:#1a1a2e; }

        .traffic-table { width:100%; border-collapse:collapse; font-size:0.88rem; }
        .traffic-table th { padding:12px 16px; background:#f9f9f9; font-size:0.75rem; font-weight:800; color:#888; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid #f0f0f0; text-align:left; }
        .traffic-table td { padding:13px 16px; border-bottom:1px solid #f5f5f5; color:#333; font-weight:600; }
        .traffic-table tr:last-child td { border-bottom:none; }
        .traffic-table tr:hover td { background:#fafafa; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <div class="page-header">
        <h2><i class="fa-solid fa-chart-line" style="color:#c9242b;margin-right:8px;"></i>System Report</h2>
        <p>View platform traffic, member visits, and visitor activity.</p>
    </div>

    <!-- SUMMARY STATS -->
    <div class="stats-row">
        <div class="sr-stat c-blue">
            <div class="sr-icon"><i class="fa-solid fa-users"></i></div>
            <div><div class="sr-value"><asp:Label ID="lblTotalMembers" runat="server" Text="—"></asp:Label></div><div class="sr-label">Members Visited</div></div>
        </div>
        <div class="sr-stat c-green">
            <div class="sr-icon"><i class="fa-solid fa-eye"></i></div>
            <div><div class="sr-value"><asp:Label ID="lblTotalVisitors" runat="server" Text="—"></asp:Label></div><div class="sr-label">Visitors Visited</div></div>
        </div>
    </div>

    <!-- FILTERS -->
    <div class="filter-card">
        <label><i class="fa-solid fa-magnifying-glass me-1"></i> Session:</label>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" AutoPostBack="true" OnTextChanged="Filter_Changed" style="width:220px;" />
        <label><i class="fa-solid fa-calendar me-1"></i> From:</label>
        <asp:TextBox ID="txtStartDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="Filter_Changed" />
        <label>To:</label>
        <asp:TextBox ID="txtEndDate" runat="server" CssClass="form-control" TextMode="Date" AutoPostBack="true" OnTextChanged="Filter_Changed" />
    </div>

    <!-- TRAFFIC TABLE -->
    <div class="table-card">
        <div class="table-card-head"><i class="fa-solid fa-table-list" style="color:#c9242b;margin-right:8px;"></i>Traffic Log</div>
        <asp:GridView ID="gvTraffic" runat="server" AutoGenerateColumns="false" CssClass="traffic-table">
            <Columns>
                <asp:BoundField DataField="TrafficID"  HeaderText="Traffic ID" />
                <asp:BoundField DataField="SessionID"  HeaderText="Session ID" />
                <asp:BoundField DataField="VisitDate"  HeaderText="Visit Date" DataFormatString="{0:yyyy-MM-dd HH:mm}" />
                <asp:TemplateField HeaderText="User Type">
                    <ItemTemplate>
                        <%# Convert.ToBoolean(Eval("IsRegisteredUser")) ? "Member" : "Visitor" %>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

</asp:Content>
