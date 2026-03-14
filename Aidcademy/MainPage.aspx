<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MainPage.aspx.cs" Inherits="Aidcademy.MainPage" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Aidcademy - Learn First Aid Skills</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700;800;900&display=swap" rel="stylesheet" />
    <style>
        :root {
            --red: #c9242b;
            --red-dark: #a01c22;
            --red-light: #f8d7da;
            --cream: #FFFBF1;
            --dark: #1a1a2e;
        }

        * { box-sizing: border-box; margin: 0; padding: 0; }

        html, body { font-family: 'Nunito', sans-serif; overflow-x: hidden; background: var(--cream); }

        /* ── NAVBAR ── */
        .top-navbar {
            background-color: var(--red);
            padding: 12px 0;
            position: sticky;
            top: 0;
            z-index: 1000;
            box-shadow: 0 2px 20px rgba(201,36,43,0.4);
        }
        .navbar-brand-custom {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }
        .navbar-brand-custom img {
            height: 42px;
            width: 42px;
            border-radius: 50%;
            object-fit: cover;
            border: 2px solid rgba(255,255,255,0.5);
        }
        .navbar-brand-custom span {
            font-size: 1.4rem;
            font-weight: 900;
            color: white;
            letter-spacing: 1px;
        }
        .nav-links { display: flex; align-items: center; gap: 8px; }
        .nav-links .nav-btn {
            background: transparent;
            border: none;
            color: rgba(255,255,255,0.85);
            font-size: 0.95rem;
            font-weight: 600;
            font-family: 'Nunito', sans-serif;
            padding: 8px 16px;
            border-radius: 6px;
            cursor: pointer;
            transition: all 0.2s;
        }
        .nav-links .nav-btn:hover { background: rgba(255,255,255,0.15); color: white; }
        .nav-links .login-btn {
            border: 2px solid rgba(255,255,255,0.7);
            color: white;
            font-weight: 700;
            border-radius: 25px;
            padding: 7px 20px;
        }
        .nav-links .login-btn:hover { background: white; color: var(--red); }

        /* ── HERO ── */
        .hero-section {
            position: relative;
            min-height: 92vh;
            background-image: url('image/4.jpg');
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
        }
        .hero-overlay {
            position: absolute;
            inset: 0;
            background: linear-gradient(135deg, rgba(26,26,46,0.85) 0%, rgba(201,36,43,0.5) 100%);
        }
        .hero-content {
            position: relative;
            z-index: 2;
            animation: fadeUp 0.9s ease both;
        }
        .hero-badge {
            display: inline-block;
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.3);
            color: white;
            font-size: 0.82rem;
            font-weight: 700;
            padding: 6px 16px;
            border-radius: 20px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            margin-bottom: 20px;
            backdrop-filter: blur(4px);
        }
        .hero-title {
            font-size: clamp(2.2rem, 5vw, 3.8rem);
            font-weight: 900;
            color: white;
            line-height: 1.15;
            margin-bottom: 20px;
        }
        .hero-title span { color: #ff8080; }
        .hero-subtitle {
            font-size: 1.15rem;
            color: rgba(255,255,255,0.85);
            max-width: 520px;
            line-height: 1.7;
            margin-bottom: 36px;
        }
        .hero-cta { display: flex; gap: 14px; flex-wrap: wrap; }
        .btn-hero-primary {
            background: var(--red);
            border: none;
            color: white;
            font-size: 1rem;
            font-weight: 700;
            font-family: 'Nunito', sans-serif;
            padding: 14px 32px;
            border-radius: 30px;
            cursor: pointer;
            transition: all 0.25s;
            box-shadow: 0 6px 20px rgba(201,36,43,0.45);
        }
        .btn-hero-primary:hover { background: var(--red-dark); transform: translateY(-2px); box-shadow: 0 10px 28px rgba(201,36,43,0.5); }
        .btn-hero-secondary {
            background: rgba(255,255,255,0.12);
            border: 2px solid rgba(255,255,255,0.5);
            color: white;
            font-size: 1rem;
            font-weight: 700;
            font-family: 'Nunito', sans-serif;
            padding: 14px 32px;
            border-radius: 30px;
            cursor: pointer;
            transition: all 0.25s;
            backdrop-filter: blur(4px);
            text-decoration: none;
        }
        .btn-hero-secondary:hover { background: white; color: var(--red); border-color: white; }
        .hero-stats {
            display: flex;
            gap: 40px;
            margin-top: 56px;
            flex-wrap: wrap;
        }
        .hero-stat { text-align: left; }
        .hero-stat-num { font-size: 2rem; font-weight: 900; color: white; line-height: 1; }
        .hero-stat-label { font-size: 0.82rem; color: rgba(255,255,255,0.7); font-weight: 600; text-transform: uppercase; letter-spacing: 0.5px; margin-top: 3px; }

        /* ── FEATURES STRIP ── */
        .features-strip {
            background: white;
            padding: 60px 0;
        }
        .section-label {
            font-size: 0.78rem;
            font-weight: 800;
            color: var(--red);
            letter-spacing: 2px;
            text-transform: uppercase;
            margin-bottom: 10px;
        }
        .section-title {
            font-size: 2rem;
            font-weight: 900;
            color: var(--dark);
            line-height: 1.2;
        }
        .feature-card {
            background: var(--cream);
            border-radius: 16px;
            padding: 32px 24px;
            text-align: center;
            transition: all 0.3s;
            border: 1.5px solid transparent;
            animation: fadeUp 0.6s ease both;
        }
        .feature-card:hover { border-color: var(--red-light); transform: translateY(-6px); box-shadow: 0 16px 40px rgba(201,36,43,0.1); }
        .feature-icon {
            width: 64px;
            height: 64px;
            background: var(--red-light);
            border-radius: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
            font-size: 1.6rem;
            color: var(--red);
            transition: all 0.3s;
        }
        .feature-card:hover .feature-icon { background: var(--red); color: white; }
        .feature-card h5 { font-size: 1.05rem; font-weight: 800; color: var(--dark); margin-bottom: 10px; }
        .feature-card p { font-size: 0.9rem; color: #666; line-height: 1.6; margin: 0; }

        /* ── SLIDER SECTION ── */
        .slider-section { background: var(--cream); padding: 70px 0; }
        .slider-wrap {
            position: relative;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.15);
            max-width: 900px;
            margin: 0 auto;
        }
        .slide { display: none; width: 100%; }
        .slide img { width: 100%; height: 480px; object-fit: cover; display: block; }
        .slide.active { display: block; animation: fadeIn 0.6s ease; }
        .slider-arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            background: rgba(255,255,255,0.9);
            border: none;
            width: 44px;
            height: 44px;
            border-radius: 50%;
            font-size: 1rem;
            color: var(--red);
            cursor: pointer;
            z-index: 10;
            transition: all 0.2s;
        }
        .slider-arrow:hover { background: var(--red); color: white; }
        .slider-arrow.left { left: 16px; }
        .slider-arrow.right { right: 16px; }
        .slider-dots { text-align: center; margin-top: 20px; }
        .dot { display: inline-block; width: 10px; height: 10px; background: #ccc; border-radius: 50%; margin: 0 5px; cursor: pointer; transition: all 0.2s; }
        .dot.active { background: var(--red); transform: scale(1.3); }

        /* ── CONTACT ── */
        .contact-section {
            background: var(--dark);
            padding: 80px 0;
            position: relative;
            overflow: hidden;
        }
        .contact-section::before {
            content: '';
            position: absolute;
            top: -80px;
            right: -80px;
            width: 300px;
            height: 300px;
            background: rgba(201,36,43,0.15);
            border-radius: 50%;
        }
        .contact-section h2 { font-size: 2.2rem; font-weight: 900; color: white; margin-bottom: 10px; }
        .contact-section p { color: rgba(255,255,255,0.7); margin-bottom: 8px; }
        .btn-feedback {
            background: var(--red);
            border: none;
            color: white;
            font-family: 'Nunito', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            padding: 13px 32px;
            border-radius: 30px;
            cursor: pointer;
            margin-top: 24px;
            transition: all 0.25s;
        }
        .btn-feedback:hover { background: var(--red-dark); transform: translateY(-2px); }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp { from { opacity: 0; transform: translateY(28px); } to { opacity: 1; transform: translateY(0); } }
        @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
        .reveal { opacity: 0; transform: translateY(30px); transition: opacity 0.6s ease, transform 0.6s ease; }
        .reveal.visible { opacity: 1; transform: translateY(0); }
    </style>
</head>
<body>
<form id="form1" runat="server">

    <!-- NAVBAR -->
    <nav class="top-navbar">
        <div class="container d-flex justify-content-between align-items-center">
            <a href="MainPage.aspx" class="navbar-brand-custom">
                <img src="image/aidcademylogo.png" alt="Aidcademy Logo" />
                <span>AIDCADEMY</span>
            </a>
            <div class="nav-links">
                <asp:Button ID="btnAbout" runat="server" Text="About" CssClass="nav-btn" PostBackUrl="About.aspx" />
                <asp:Button ID="btnCourse" runat="server" Text="Courses" CssClass="nav-btn" PostBackUrl="LearningCourse.aspx" />
                <asp:Button ID="btnLogin" runat="server" Text="Login" CssClass="nav-btn login-btn" PostBackUrl="Login_Signup.aspx" />
            </div>
        </div>
    </nav>

    <!-- HERO -->
    <section class="hero-section">
        <div class="hero-overlay"></div>
        <div class="container">
            <div class="hero-content" style="max-width:620px;">
                <div class="hero-badge"><i class="fa-solid fa-shield-heart me-2"></i>First Aid Education Platform</div>
                <h1 class="hero-title">Learn Life-Saving Skills <span>Anytime</span>, Anywhere</h1>
                <p class="hero-subtitle">Join Aidcademy and master first-aid through interactive lessons, quizzes, and simulations designed for real-world emergencies.</p>
                <div class="hero-cta">
                    <asp:Button ID="btnTryFree" runat="server" Text="Try For Free →" CssClass="btn-hero-primary" OnClick="btnTryFree_Click" />
                    <a href="About.aspx" class="btn-hero-secondary">Learn More</a>
                </div>
                <div class="hero-stats">
                    <div class="hero-stat"><div class="hero-stat-num">100%</div><div class="hero-stat-label">Free to Start</div></div>
                    <div class="hero-stat"><div class="hero-stat-num">5+</div><div class="hero-stat-label">First Aid Topics</div></div>
                    <div class="hero-stat"><div class="hero-stat-num">24/7</div><div class="hero-stat-label">Learn Anytime</div></div>
                </div>
            </div>
        </div>
    </section>

    <!-- FEATURES -->
    <section class="features-strip">
        <div class="container">
            <div class="text-center mb-5 reveal">
                <div class="section-label">Why Aidcademy</div>
                <h2 class="section-title">Everything You Need to Be Prepared</h2>
            </div>
            <div class="row g-4">
                <div class="col-md-6 col-lg-3">
                    <div class="feature-card reveal" style="animation-delay:0.1s">
                        <div class="feature-icon"><i class="fa-solid fa-book-open-reader"></i></div>
                        <h5>Structured Lessons</h5>
                        <p>Step-by-step first aid lessons built by qualified instructors.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="feature-card reveal" style="animation-delay:0.2s">
                        <div class="feature-icon"><i class="fa-solid fa-brain"></i></div>
                        <h5>Interactive Quizzes</h5>
                        <p>Test your knowledge after each lesson with instant feedback.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="feature-card reveal" style="animation-delay:0.3s">
                        <div class="feature-icon"><i class="fa-solid fa-gamepad"></i></div>
                        <h5>Simulations</h5>
                        <p>Practice real scenarios with our built-in emergency simulations.</p>
                    </div>
                </div>
                <div class="col-md-6 col-lg-3">
                    <div class="feature-card reveal" style="animation-delay:0.4s">
                        <div class="feature-icon"><i class="fa-solid fa-chart-line"></i></div>
                        <h5>Progress Tracking</h5>
                        <p>Track your learning streak and course completion at a glance.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- SLIDER -->
    <section class="slider-section">
        <div class="container">
            <div class="text-center mb-4 reveal">
                <div class="section-label">Gallery</div>
                <h2 class="section-title">First Aid in Action</h2>
            </div>
            <div class="slider-wrap reveal">
                <div class="slide active"><img src="image/5.jpg" alt="First Aid 1" /></div>
                <div class="slide"><img src="image/6.jpg" alt="First Aid 2" /></div>
                <div class="slide"><img src="image/7.jpg" alt="First Aid 3" /></div>
                <button type="button" class="slider-arrow left" onclick="prevSlide()"><i class="fa-solid fa-chevron-left"></i></button>
                <button type="button" class="slider-arrow right" onclick="nextSlide()"><i class="fa-solid fa-chevron-right"></i></button>
            </div>
            <div class="slider-dots">
                <span class="dot active" onclick="goToSlide(0)"></span>
                <span class="dot" onclick="goToSlide(1)"></span>
                <span class="dot" onclick="goToSlide(2)"></span>
            </div>
        </div>
    </section>

    <!-- CONTACT -->
    <section class="contact-section">
        <div class="container text-center position-relative" style="z-index:1">
            <div class="reveal">
                <i class="fa-solid fa-envelope-open-text fa-2x text-danger mb-3"></i>
                <h2>Get in Touch</h2>
                <p class="mt-3"><i class="fa-solid fa-envelope me-2 text-danger"></i>support@aidcademy.com</p>
                <p><i class="fa-solid fa-phone me-2 text-danger"></i>+60 12-345 6789</p>
                <asp:Button ID="btnFeedback" runat="server" Text="Send Feedback" CssClass="btn-feedback" OnClick="btnFeedback_Click1" />
            </div>
        </div>
    </section>

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Slider
    let currentIndex = 0;
    const slides = document.querySelectorAll('.slide');
    const dots = document.querySelectorAll('.dot');

    function showSlide(index) {
        slides.forEach((s, i) => { s.classList.remove('active'); dots[i].classList.remove('active'); });
        slides[index].classList.add('active');
        dots[index].classList.add('active');
        currentIndex = index;
    }
    function nextSlide() { showSlide((currentIndex + 1) % slides.length); }
    function prevSlide() { showSlide((currentIndex - 1 + slides.length) % slides.length); }
    function goToSlide(i) { showSlide(i); }
    setInterval(nextSlide, 4000);

    // Scroll reveal
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); } });
    }, { threshold: 0.12 });
    document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
</script>
</body>
</html>
