<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainPage.aspx.cs" Inherits="Aidcademy.MainPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href = "Styles/MainPage.css" rel = "stylesheet" />
</head>
<body>
    <form id="form1" runat="server">

        <div class="header">
            <img src="Image/Logo.jpg" style="height:120px; width:191px;" />
            <div class="nav">
            <asp:Button ID="btnAbout" runat="server" Text="About" 
                CssClass="nav-btn" PostBackUrl="About.aspx" />
            <asp:Button ID="btnResearch" runat="server" Text="Research" 
                CssClass="nav-btn" PostBackUrl="Research.aspx" />
            <asp:Button ID="btnLogin" runat="server" Text="Login"      
                CssClass="nav-btn login-btn" PostBackUrl="Login_Signup.aspx" />

            </div>
        </div>
        <div class="main">
        </div>

    </form>
</body>
</html>
