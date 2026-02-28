<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentManagement.aspx.cs" Inherits="Aidcademy.ContentManagement" %>

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

    </form>
</body>
</html>
