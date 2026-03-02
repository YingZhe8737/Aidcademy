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
            <img src="image/Logo.jpg" style="height:120px; width:191px;" />
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

        <div class="slider">

           <div class="slides">
               <img class="slide active" src="image/1.jpg" />
               <img class="slide" src="image/2.jpg" />
               <img class="slide" src="image/3.jpg" />
            </div>

            <button type="button" class="arrow left" onclick="prevSlide()">&#10094;</button>
            <button type="button" class="arrow right" onclick="nextSlide()">&#10095;</button>

            <div class="dots">
                <span class="dot active" onclick="goToSlide(0)"></span>
                <span class="dot" onclick="goToSlide(1)"></span>
                <span class="dot" onclick="goToSlide(2)"></span>
            </div>

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
