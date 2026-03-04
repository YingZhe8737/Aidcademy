<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="Aidcademy.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/CustomAdmin.css" rel="stylesheet" type="text/css" />
</head>


<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
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
                <li class="nav-item"><a class="nav-link" href="Login_signup.aspx">Logout</a></li>
            </ul>
        </div>

    </div>


    <!-- MAIN DASHBOARD -->
    <div class="dashboard-container">

        <!-- SYSTEM REPORT -->
        <div class="card">
            <h3><i class="fa-solid fa-chart-line"></i> System Overview</h3>
            <p>Monitor platform performance, usage, and system health.</p>
        </div>

        <!-- CONTENT -->
        <div class="card">
            <h3><i class="fa-solid fa-book"></i> Content Summary</h3>
            <p>Track learning material, access frequency and engagement.</p>
        </div>

        <!-- USER -->
        <div class="card">
            <h3><i class="fa-solid fa-users"></i> User Management</h3>

            <div class="stats">
                <div>
                    <h4>Members</h4>
                    <asp:Label ID="lblActiveMembers" runat="server" CssClass="stat"></asp:Label>
                    <asp:Label ID="lblSuspendedMembers" runat="server" CssClass="stat"></asp:Label>
                    <asp:Label ID="lblDeactivatedMembers" runat="server" CssClass="stat"></asp:Label>
                </div>

                <div>
                    <h4>Instructors</h4>
                    <asp:Label ID="lblActiveInstructors" runat="server" CssClass="stat"></asp:Label>
                    <asp:Label ID="lblSuspendedInstructors" runat="server" CssClass="stat"></asp:Label>
                    <asp:Label ID="lblDeactivatedInstructors" runat="server" CssClass="stat"></asp:Label>
                </div>
            </div>

            <asp:Button runat="server" CssClass="primary-btn" 
                Text="View Details" 
                OnClick="User_Management2" />
        </div>

    </div>

</form>
</body>
</html>
