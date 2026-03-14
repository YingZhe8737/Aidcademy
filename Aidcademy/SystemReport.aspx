<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SystemReport.aspx.cs" Inherits="Aidcademy.SystemReport" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/CustomAdmin.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <!-- Navigation bar at the very top -->
    <div class="admin-nav">

        <div class="nav-welcome">
          <h2> <i class="fa-solid fa-truck-medical me-2"></i> AIDCADEMY </h2>  
        </div>

        <div = "navbar-nav flex-row">
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link fw-bold" href="AdminDashboard.aspx">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="SystemReport.aspx">System Report</a></li>
                <li class="nav-item"><a class="nav-link" href="UserManagement.aspx">User Management</a></li>
                <li class="nav-item"><a class="nav-link" href="ContentManagement.aspx">Content Management</a></li>
                <li class="nav-item"><a class="nav-link" href="Logout.aspx">Logout</a></li>
            </ul>
        </div>

    </div>

    <div class="user-management-container">

        <!-- FILTER -->
        <div class="filter-bar">

            Search Session:
            <asp:TextBox ID="txtSearch" runat="server" AutoPostBack="true"
                OnTextChanged="Filter_Changed"></asp:TextBox>

            From:
            <asp:TextBox ID="txtStartDate" runat="server" TextMode="Date"
                AutoPostBack="true" OnTextChanged="Filter_Changed"></asp:TextBox>

            To:
            <asp:TextBox ID="txtEndDate" runat="server" TextMode="Date"
                AutoPostBack="true" OnTextChanged="Filter_Changed"></asp:TextBox>

        </div>


        <!-- SUMMARY -->
        <div class="summary-cards system-margin">

            <div class="summary-card visitor">
                <h3>Total Member Visited:</h3>
                <asp:Label ID="lblTotalMembers" runat="server"
                    style="font-size:32px;font-weight:bold;"></asp:Label>
            </div>

            <div class="summary-card member">
                <h3>Total Visitor Visited:</h3>
                <asp:Label ID="lblTotalVisitors" runat="server"
                    style="font-size:32px;font-weight:bold;"></asp:Label>
            </div>

        </div>


        <!-- GRID -->
        <asp:GridView ID="gvTraffic" runat="server" AutoGenerateColumns="false"
            CssClass="table">

            <Columns>

                <asp:BoundField DataField="TrafficID" HeaderText="Traffic ID" />

                <asp:BoundField DataField="SessionID" HeaderText="Session ID" />

                <asp:BoundField DataField="VisitDate" HeaderText="Visit Date"
                    DataFormatString="{0:yyyy-MM-dd HH:mm}" />

                <asp:TemplateField HeaderText="User Type">
                    <ItemTemplate>
                        <%# Convert.ToBoolean(Eval("IsRegisteredUser")) ? "Member" : "Visitor" %>
                    </ItemTemplate>
                </asp:TemplateField>

            </Columns>

        </asp:GridView>

    </div>


    </form>
</body>
</html>
