<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemReport.aspx.cs" Inherits="Aidcademy.SystemReport" MasterPageFile="~/Admin.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">System Report — Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .page-header { margin-bottom:28px; }
        .page-header h2 { font-size:1.65rem; font-weight:900; color:#1a1a2e; margin-bottom:4px; }
        .page-header p  { font-size:0.92rem; color:#888; font-weight:600; margin:0; }

        /* ── Overview row: doughnut + metric cards ── */
        .overview-row { display:grid; grid-template-columns:320px 1fr; gap:20px; margin-bottom:28px; }
        @media(max-width:900px){ .overview-row{grid-template-columns:1fr;} }

        .chart-panel { background:white; border-radius:16px; border:1px solid #ebebeb; padding:28px; display:flex; flex-direction:column; align-items:center; }
        .chart-panel-title { font-size:0.9rem; font-weight:900; color:#1a1a2e; margin-bottom:20px; align-self:flex-start; display:flex; align-items:center; gap:8px; }
        .chart-panel-title i { color:#c9242b; }
        .donut-wrap { position:relative; width:200px; height:200px; }
        .donut-center { position:absolute; inset:0; display:flex; flex-direction:column; align-items:center; justify-content:center; pointer-events:none; }
        .donut-total  { font-size:2.2rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .donut-label  { font-size:0.75rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.5px; margin-top:4px; }
        .chart-legend { display:flex; gap:16px; margin-top:20px; flex-wrap:wrap; justify-content:center; }
        .legend-item { display:flex; align-items:center; gap:7px; font-size:0.82rem; font-weight:700; color:#555; }
        .legend-dot  { width:12px; height:12px; border-radius:3px; flex-shrink:0; }

        .metrics-panel { display:flex; flex-direction:column; gap:16px; }
        .metric-card { background:white; border-radius:16px; border:1px solid #ebebeb; padding:22px 24px; flex:1; position:relative; overflow:hidden; transition:transform 0.2s,box-shadow 0.2s; }
        .metric-card::before { content:''; position:absolute; top:0; left:0; width:4px; height:100%; }
        .metric-card.c-blue::before  { background:#3b82f6; }
        .metric-card.c-green::before { background:#10b981; }
        .metric-card.c-red::before   { background:#c9242b; }
        .metric-card:hover { transform:translateY(-3px); box-shadow:0 10px 28px rgba(0,0,0,0.07); }
        .metric-row { display:flex; align-items:center; gap:16px; }
        .metric-icon { width:50px; height:50px; border-radius:13px; display:flex; align-items:center; justify-content:center; font-size:1.3rem; flex-shrink:0; }
        .c-blue  .metric-icon { background:#dbeafe; color:#2563eb; }
        .c-green .metric-icon { background:#d1fae5; color:#059669; }
        .c-red   .metric-icon { background:#fde8e9; color:#c9242b; }
        .metric-value { font-size:2.2rem; font-weight:900; color:#1a1a2e; line-height:1; }
        .metric-label { font-size:0.78rem; font-weight:700; color:#aaa; text-transform:uppercase; letter-spacing:0.4px; margin-top:4px; }
        .metric-bar-wrap { margin-top:14px; }
        .metric-bar-track { height:8px; background:#f0f0f0; border-radius:4px; overflow:hidden; }
        .metric-bar-fill  { height:100%; border-radius:4px; transition:width 1s ease; }
        .c-blue  .metric-bar-fill  { background:#3b82f6; }
        .c-green .metric-bar-fill  { background:#10b981; }
        .metric-bar-label { font-size:0.75rem; color:#aaa; font-weight:700; margin-top:6px; }

        /* ── Filter ── */
        .filter-card { background:white; border-radius:14px; border:1px solid #ebebeb; padding:18px 22px; margin-bottom:22px; display:flex; align-items:center; gap:14px; flex-wrap:wrap; }
        .filter-card label { font-size:0.82rem; font-weight:700; color:#888; white-space:nowrap; }
        .filter-card .form-control { font-family:'Nunito',sans-serif; font-size:0.88rem; font-weight:600; border:1.5px solid #e0e0e0; border-radius:9px; padding:8px 14px; }
        .filter-card .form-control:focus { border-color:#c9242b; box-shadow:none; outline:none; }

        /* ── Table ── */
        .table-card { background:white; border-radius:16px; border:1px solid #ebebeb; overflow:hidden; }
        .table-card-head { padding:16px 22px; border-bottom:1px solid #f5f5f5; font-size:0.95rem; font-weight:900; color:#1a1a2e; }
        .traffic-table { width:100%; border-collapse:collapse; font-size:0.88rem; }
        .traffic-table th { padding:12px 16px; background:#f9f9f9; font-size:0.75rem; font-weight:800; color:#888; text-transform:uppercase; letter-spacing:0.5px; border-bottom:1px solid #f0f0f0; text-align:left; }
        .traffic-table td { padding:13px 16px; border-bottom:1px solid #f5f5f5; color:#333; font-weight:600; }
        .traffic-table tr:last-child td { border-bottom:none; }
        .traffic-table tr:hover td { background:#fafafa; }
        .type-badge { display:inline-flex; align-items:center; gap:5px; padding:3px 10px; border-radius:20px; font-size:0.75rem; font-weight:800; }
        .type-member  { background:#dbeafe; color:#1d4ed8; }
        .type-visitor { background:#f3f4f6; color:#6b7280; }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Hidden fields inside MainContent (inside form tag) --%>
    <asp:HiddenField ID="hfChartMembers"  runat="server" Value="0" />
    <asp:HiddenField ID="hfChartVisitors" runat="server" Value="0" />

    <div class="page-header">
        <h2><i class="fa-solid fa-chart-line" style="color:#c9242b;margin-right:8px;"></i>System Report</h2>
        <p>View platform traffic, member visits, and visitor activity.</p>
    </div>

    <!-- OVERVIEW: doughnut + metric cards -->
    <div class="overview-row">
        <!-- Doughnut chart -->
        <div class="chart-panel">
            <div class="chart-panel-title"><i class="fa-solid fa-chart-pie"></i>Visit Distribution</div>
            <div class="donut-wrap">
                <canvas id="donutChart"></canvas>
                <div class="donut-center">
                    <div class="donut-total" id="donutTotal">0</div>
                    <div class="donut-label">Total</div>
                </div>
            </div>
            <div class="chart-legend">
                <div class="legend-item"><div class="legend-dot" style="background:#3b82f6;"></div>Members</div>
                <div class="legend-item"><div class="legend-dot" style="background:#10b981;"></div>Visitors</div>
            </div>
        </div>

        <!-- Metric cards with progress bars -->
        <div class="metrics-panel">
            <div class="metric-card c-blue">
                <div class="metric-row">
                    <div class="metric-icon"><i class="fa-solid fa-users"></i></div>
                    <div>
                        <div class="metric-value"><asp:Label ID="lblTotalMembers" runat="server" Text="0"></asp:Label></div>
                        <div class="metric-label">Members Visited</div>
                    </div>
                </div>
                <div class="metric-bar-wrap">
                    <div class="metric-bar-track"><div class="metric-bar-fill" id="barMembers" style="width:0%"></div></div>
                    <div class="metric-bar-label" id="barMembersLabel">0% of total traffic</div>
                </div>
            </div>
            <div class="metric-card c-green">
                <div class="metric-row">
                    <div class="metric-icon"><i class="fa-solid fa-eye"></i></div>
                    <div>
                        <div class="metric-value"><asp:Label ID="lblTotalVisitors" runat="server" Text="0"></asp:Label></div>
                        <div class="metric-label">Guest Visitors</div>
                    </div>
                </div>
                <div class="metric-bar-wrap">
                    <div class="metric-bar-track"><div class="metric-bar-fill" id="barVisitors" style="width:0%"></div></div>
                    <div class="metric-bar-label" id="barVisitorsLabel">0% of total traffic</div>
                </div>
            </div>
        </div>
    </div>

    <!-- FILTERS -->
    <div class="filter-card">
        <label><i class="fa-solid fa-magnifying-glass" style="margin-right:4px;"></i>Session:</label>
        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" AutoPostBack="true" OnTextChanged="Filter_Changed" style="width:220px;" />
        <label><i class="fa-solid fa-calendar" style="margin-right:4px;"></i>From:</label>
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
                        <span class='type-badge <%# Convert.ToBoolean(Eval("IsRegisteredUser")) ? "type-member" : "type-visitor" %>'>
                            <i class='fa-solid <%# Convert.ToBoolean(Eval("IsRegisteredUser")) ? "fa-user" : "fa-eye" %>'></i>
                            <%# Convert.ToBoolean(Eval("IsRegisteredUser")) ? "Member" : "Visitor" %>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>

</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="ScriptContent" runat="server">
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
<script>
    (function () {
        var members  = parseInt(document.getElementById('<%= hfChartMembers.ClientID %>').value)  || 0;
        var visitors = parseInt(document.getElementById('<%= hfChartVisitors.ClientID %>').value) || 0;
        var total = members + visitors;

        // Update total in donut center
        document.getElementById('donutTotal').textContent = total;

        // Doughnut chart
        var ctx = document.getElementById('donutChart').getContext('2d');
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Members', 'Visitors'],
                datasets: [{
                    data: total > 0 ? [members, visitors] : [1, 1],
                    backgroundColor: total > 0
                        ? ['rgba(59,130,246,0.85)', 'rgba(16,185,129,0.85)']
                        : ['#f0f0f0', '#f0f0f0'],
                    borderColor: total > 0 ? ['#3b82f6', '#10b981'] : ['#e0e0e0', '#e0e0e0'],
                    borderWidth: 2,
                    hoverOffset: 8
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: true,
                cutout: '72%',
                plugins: {
                    legend: { display: false },
                    tooltip: {
                        enabled: total > 0,
                        backgroundColor: '#1a1a2e',
                        titleFont: { family: 'Nunito', weight: '800', size: 13 },
                        bodyFont: { family: 'Nunito', size: 13 },
                        padding: 12, cornerRadius: 8,
                        callbacks: {
                            label: function (ctx) {
                                var pct = total > 0 ? Math.round(ctx.parsed / total * 100) : 0;
                                return ' ' + ctx.parsed + ' visits (' + pct + '%)';
                            }
                        }
                    }
                },
                animation: { duration: 900, easing: 'easeOutQuart' }
            }
        });

        // Progress bars
        if (total > 0) {
            var mPct = Math.round(members / total * 100);
            var vPct = Math.round(visitors / total * 100);
            setTimeout(function () {
                document.getElementById('barMembers').style.width = mPct + '%';
                document.getElementById('barVisitors').style.width = vPct + '%';
                document.getElementById('barMembersLabel').textContent = mPct + '% of total traffic';
                document.getElementById('barVisitorsLabel').textContent = vPct + '% of total traffic';
            }, 100);
        }
    })();
</script>
</asp:Content>
