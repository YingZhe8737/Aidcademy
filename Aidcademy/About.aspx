<%@ Page Title="About" Language="C#"  AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Aidcademy.About" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>About Us - Aidcademy</title>
    <link href="Styles/AboutUs.css?v=1" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <div class="header">
        <a href="MainPage.aspx" class="brand">
            <img src="image/Logo.jpeg" alt="Aidcademy Logo">    
            <span class="brand-text">Aidcademy</span>
        </a>
        <div class="nav">
            <asp:Button ID="btnAbout" runat="server" Text="About" 
                CssClass="nav-btn" OnClick="btnAboutUs" />
            <asp:Button ID="btnCourse" runat="server" Text="Course" 
                CssClass="nav-btn" PostBackUrl="Course.aspx" />
            <asp:Button ID="btnLogin" runat="server" Text="Login"      
                CssClass="nav-btn login-btn" PostBackUrl="Login_Signup.aspx" />
        </div>
    </div>

        <div class="hero">
            <div class="hero-text">
            <h1>About Aidcademy</h1>
            <p><h3>Empowering member with simple and accessible medical learning tools.</h3></p>
            </div>
        </div>

        <div class="section">
            <div class="card">
                <h2>Our Mission</h2>
                <p>
                    Aidcademy aims to develop an interactive learning platform on first-aid education for first-aid enthusiasts by providing interactive courses and step-by-step walkthroughs to enhance understanding, encourages continuous learning and confidence in handling real-life emergency situations.
                </p>
            </div>

            <div class="card">
                <h2>Our Objective</h2>
                <p>
                    The objective of this project is to develop an interactive learning platform on first-aid education.
                </p>
            </div>
        </div>

        <div class="features">
            <h2>What We Offer</h2>

            <div class="feature-box">
                <div>📚 Learning Materials</div>
                <div>🧠 Interactive Quizzes</div>
                <div>📊 Progress Tracking</div>
                <div>💬 Member Support</div>
            </div>
        </div>

        <div class="contact">
            <h2>Contact Us</h2>
            <p>Email: support@aidcademy.com</p>
            <p>Phone: +60 12-345 6789</p>

            <asp:Button ID="btnFeedback" runat="server" 
                Text="Send Feedback" CssClass="btn-feedback" />
        </div>

    </form>
</body>
</html>
