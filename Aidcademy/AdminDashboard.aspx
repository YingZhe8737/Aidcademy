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
        <!-- Navigation bar at the very top -->
    <div class="admin-nav">

        <div class="nav-welcome">
          <h2> <i class="fa-solid fa-truck-medical me-2"></i> AIDCADEMY </h2>  
        </div>

        <div>
            <asp:Button runat="server" CssClass="nav-btn" Text="Home" OnClick="Home_Click" />
            <asp:Button runat="server" CssClass="nav-btn" Text="System Report" OnClick="SystemReport_Click" />
            <asp:Button runat="server" CssClass="nav-btn" Text="User Management" OnClick="UserManagement_Click" />
            <asp:Button runat="server" CssClass="nav-btn" Text="Content Management" OnClick="ContentManagement_Click" />
            <asp:Button runat="server" CssClass="nav-btn" Text="Logout" OnClick="Logout_Click" />
        </div>

    </div>





    <div class="admin-general-contents">

        <!-- box left -->
        <div class="general-box">
            <div class="color-h2-white"> <h2>System Report</h2> </div>
            <p>Summary of system performance.</p>
        </div>

        <!-- box middle -->

        <div class="general-box">
            <div class="color-h2-white"><h2>Content-Summary</h2></div>
            <p>Summary of Accessed Content.</p>
        </div>

         <!-- box right -->

      <div class="general-box">
          <div class="color-h2-white"> <h2>User-Management</h2> </div>
                  <!-- Member Overview -->
          <div class="user-box">
              <div class="user-section">
                  <h4>Member Overview</h4>
                  <asp:Label ID="lblActiveMembers" runat="server" CssClass="stat"></asp:Label>
                  <asp:Label ID="lblSuspendedMembers" runat="server" CssClass="stat"></asp:Label>
                  <asp:Label ID="lblDeactivatedMembers" runat="server" CssClass="stat"></asp:Label>
              </div>

              <div class="user-section">
                  <h4>Instructor Overview</h4>
                  <asp:Label ID="lblActiveInstructors" runat="server" CssClass="stat"></asp:Label>
                  <asp:Label ID="lblSuspendedInstructors" runat="server" CssClass="stat"></asp:Label>
                  <asp:Label ID="lblDeactivatedInstructors" runat="server" CssClass="stat"></asp:Label>
              </div>
              <asp:Button runat="server" CssClass="nav-btn" Text="View Details" OnClick="User_Management2" />
            </div>
    </div>



    </form>
</body>
</html>
