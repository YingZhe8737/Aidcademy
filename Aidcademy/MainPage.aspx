<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainPage.aspx.cs" Inherits="Aidcademy.MainPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href = "Styles/MainPage.css?v=1" rel = "stylesheet" />
</head>

<body>
    <form id="form1" runat="server">

        <div class="header">
            <div class="brand">
                <img src="image/Logo.jpeg" alt="Aidcademy Logo">
                <span class="brand-text">Aidcademy</span>
            </div>
            <div class="nav">
            <asp:Button ID="btnAbout" runat="server" Text="About" 
                CssClass="nav-btn" OnClick="btnAboutUs" />
            <asp:Button ID="btnCourse" runat="server" Text="Course"
                CssClass="nav-btn" PostBackUrl="LearningCourse.aspx" />
            <asp:Button ID="btnLogin" runat="server" Text="Login"      
                CssClass="nav-btn login-btn" PostBackUrl="Login_Signup.aspx" />
            </div>
        </div>
        <div class="main">
            <div class="hero-text">
                <h1>Learn First Aid Skills Today</h1>
                <p>
                    <h3>Join Aidcademy and start learning life-saving skills.</h3>
                </p>
                <p>
                    <h3>Try our basic course for free and be prepared for emergencies.</h3>
                </p>
            </div>

            <!-- RIGHT BOTTOM BUTTON -->
            <div class="hero-button">
                <asp:Button ID="btnTryFree" runat="server" Text="Try For Free" CssClass="learn-btn" OnClick="btnTryFree_Click" />
            </div>
        </div>

        <div class="slider">

           <div class="slides">
               <img class="slide active" src="image/5.jpg" />
               <img class="slide" src="image/6.jpg" />
               <img class="slide" src="image/7.jpg" />
            </div>

            <button type="button" class="arrow left" onclick="prevSlide()">&#10094;</button>
            <button type="button" class="arrow right" onclick="nextSlide()">&#10095;</button>

            <div class="dots">
                <span class="dot active" onclick="goToSlide(0)"></span>
                <span class="dot" onclick="goToSlide(1)"></span>
                <span class="dot" onclick="goToSlide(2)"></span>
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

    
<script>
    let currentIndex = 0;
    const slides = document.querySelectorAll(".slide");
    const dots = document.querySelectorAll(".dot");

    function showSlide(index) {
        slides.forEach((slide, i) => {
            slide.classList.remove("active");
            dots[i].classList.remove("active");
        });

        slides[index].classList.add("active");
        dots[index].classList.add("active");
        currentIndex = index;
    }

    function nextSlide() {
        let newIndex = (currentIndex + 1) % slides.length;
        showSlide(newIndex);
    }

    function prevSlide() {
        let newIndex = (currentIndex - 1 + slides.length) % slides.length;
        showSlide(newIndex);
    }

    function goToSlide(index) {
        showSlide(index);
    }

    setInterval(nextSlide, 3000);
</script>

</html>
