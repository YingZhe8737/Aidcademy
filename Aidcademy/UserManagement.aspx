<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UserManagement.aspx.cs" Inherits="Aidcademy.UserManagement" %>

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
            <div class="nav-logo">
                <i class="fa-solid fa-truck-medical"></i> AIDCADEMY
            </div>
            <ul class="navbar-nav">
                <li class="nav-item"><a class="nav-link active" href="AdminDashboard.aspx">Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="SystemReport.aspx">System Report</a></li>
                <li class="nav-item"><a class="nav-link" href="UserManagement.aspx">User Management</a></li>
                <li class="nav-item"><a class="nav-link" href="ContentManagement.aspx">Content Management</a></li>
                <li class="nav-item"><a class="nav-link" href="Logout.aspx">Logout</a></li>
            </ul>
        </div>


    <div class="user-management-container">



        <!-- Summary Cards -->
        <div class="summary-cards">
            <div class="summary-card total">
                <h3>Total Users</h3>
                <asp:Label ID="lblTotalMembers" runat="server" style="font-size: 32px; font-weight: bold;"></asp:Label>
            </div>

            <div class="summary-card active">
                <h3>Active</h3>
                <asp:Label ID="lblTotalActive" runat="server" style="font-size: 32px; font-weight: bold;"></asp:Label>
            </div>

            <div class="summary-card suspended">
                <h3>Suspended</h3>
                <asp:Label ID="LblTotalSuspended" runat="server" style="font-size: 32px; font-weight: bold;"></asp:Label>
            </div>

            <div class="summary-card deactivated">
                <h3>Deactivated</h3>
                <asp:Label ID="LblTotalDeactivated" runat="server" style="font-size: 32px; font-weight: bold;"></asp:Label>
            </div>
        </div>

        <!-- Filters Section -->
        <div class="filter-section">
            <asp:TextBox ID="txtSearch" runat="server" placeholder="Search by username or email" AutoPostBack="true" Width="400px" OnTextChanged="Filter_Changed"/>

            <asp:DropDownList ID="ddlRole" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                <asp:ListItem>All Roles</asp:ListItem>
                <asp:ListItem>Member</asp:ListItem>
                <asp:ListItem>Instructor</asp:ListItem>
                <asp:ListItem>Admin</asp:ListItem>
            </asp:DropDownList>

            <asp:DropDownList ID="ddlStatus" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                <asp:ListItem>All Status</asp:ListItem>
                <asp:ListItem>Active</asp:ListItem>
                <asp:ListItem>Suspended</asp:ListItem>
                <asp:ListItem>Deactivated</asp:ListItem>
            </asp:DropDownList>

            <a href="AccountModification.aspx" class="add-user-btn">Account Modification</a>

        </div>

        <!-- Users Table -->
        <div class="table-container">
            <asp:GridView ID="gvUsers" runat="server"  AutoGenerateColumns="False" CssClass="user-table"  OnRowCommand="gvUsers_RowCommand" OnSelectedIndexChanged="gvUsers_SelectedIndexChanged">
                <Columns>

                    <asp:BoundField DataField="UserID" HeaderText="UserID" />
                    <asp:BoundField DataField="Username" HeaderText="Username" />
                    <asp:BoundField DataField="Email" HeaderText="Email" />
                    <asp:BoundField DataField="Role" HeaderText="Role" />
                    <asp:BoundField DataField="Status" HeaderText="Status" />
                    <asp:BoundField DataField="CreatedDate" HeaderText="Created" 
                        DataFormatString="{0:dd/MM/yyyy}" />

                    <asp:TemplateField HeaderText="Actions">
                        <ItemTemplate>

                            <asp:Button ID="btnStatus" runat="server"
                                Text="Change Status"
                                CssClass="suspend"
                                CommandName="ChangeStatus"
                                CommandArgument='<%# Eval("UserID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>

                </Columns>
            </asp:GridView>
        </div>
    </div>



    </form>
</body>
</html>
