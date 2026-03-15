<%@ Page Title="About Us - Aidcademy" Language="C#" AutoEventWireup="true" CodeBehind="About.aspx.cs" Inherits="Aidcademy.About" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>About Us - Aidcademy</title>
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
        .navbar-brand-custom { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .navbar-brand-custom img { height: 42px; width: 42px; border-radius: 50%; object-fit: cover; border: 2px solid rgba(255,255,255,0.5); }
        .navbar-brand-custom span { font-size: 1.4rem; font-weight: 900; color: white; letter-spacing: 1px; }
        .nav-links { display: flex; align-items: center; gap: 8px; }
        .nav-links .nav-btn {
            background: transparent; border: none; color: rgba(255,255,255,0.85);
            font-size: 0.95rem; font-weight: 600; font-family: 'Nunito', sans-serif;
            padding: 8px 16px; border-radius: 6px; cursor: pointer; transition: all 0.2s;
        }
        .nav-links .nav-btn:hover { background: rgba(255,255,255,0.15); color: white; }
        .nav-links .login-btn { border: 2px solid rgba(255,255,255,0.7); color: white; font-weight: 700; border-radius: 25px; padding: 7px 20px; }
        .nav-links .login-btn:hover { background: white; color: var(--red); }

        /* ── HERO ── */
        .hero-section {
            position: relative;
            min-height: 60vh;
            background-image: url('image/aboutus.jpg');
            background-size: cover;
            background-position: center;
            display: flex;
            align-items: center;
        }
        .hero-overlay { position: absolute; inset: 0; background: linear-gradient(135deg, rgba(26,26,46,0.82) 0%, rgba(201,36,43,0.45) 100%); }
        .hero-content { position: relative; z-index: 2; animation: fadeUp 0.9s ease both; }
        .hero-badge {
            display: inline-block; background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.3);
            color: white; font-size: 0.82rem; font-weight: 700; padding: 6px 16px; border-radius: 20px;
            letter-spacing: 1.5px; text-transform: uppercase; margin-bottom: 18px; backdrop-filter: blur(4px);
        }
        .hero-title { font-size: clamp(2rem, 5vw, 3.2rem); font-weight: 900; color: white; line-height: 1.2; margin-bottom: 14px; }
        .hero-title span { color: #ff8080; }
        .hero-subtitle { font-size: 1.1rem; color: rgba(255,255,255,0.85); max-width: 480px; line-height: 1.7; }

        /* ── SHARED SECTION ── */
        .section-label { font-size: 0.78rem; font-weight: 800; color: var(--red); letter-spacing: 2px; text-transform: uppercase; margin-bottom: 10px; }
        .section-title { font-size: 2rem; font-weight: 900; color: var(--dark); line-height: 1.2; }

        /* ── MISSION / OBJECTIVE CARDS ── */
        .mission-section { background: white; padding: 80px 0; }
        .mission-card {
            background: var(--cream);
            border-radius: 20px;
            padding: 40px 32px;
            height: 100%;
            border: 1.5px solid transparent;
            transition: all 0.35s;
            position: relative;
            overflow: hidden;
        }
        .mission-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 4px;
            background: var(--red);
            transform: scaleX(0);
            transform-origin: left;
            transition: transform 0.35s;
        }
        .mission-card:hover::before { transform: scaleX(1); }
        .mission-card:hover { border-color: var(--red-light); transform: translateY(-6px); box-shadow: 0 20px 50px rgba(201,36,43,0.1); }
        .mission-icon { width: 60px; height: 60px; background: var(--red-light); border-radius: 14px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; color: var(--red); margin-bottom: 20px; transition: all 0.3s; }
        .mission-card:hover .mission-icon { background: var(--red); color: white; }
        .mission-card h3 { font-size: 1.25rem; font-weight: 800; color: var(--dark); margin-bottom: 12px; }
        .mission-card p { font-size: 0.95rem; color: #555; line-height: 1.75; margin: 0; }

        /* ── FEATURES ── */
        .features-section { background: var(--cream); padding: 80px 0; }
        .feature-pill {
            display: flex; align-items: center; gap: 14px;
            background: white; border-radius: 12px; padding: 20px 24px;
            box-shadow: 0 2px 12px rgba(0,0,0,0.06); transition: all 0.3s;
        }
        .feature-pill:hover { box-shadow: 0 8px 24px rgba(201,36,43,0.12); transform: translateX(5px); }
        .feature-pill-icon { width: 46px; height: 46px; background: var(--red-light); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: var(--red); font-size: 1.2rem; flex-shrink: 0; }
        .feature-pill span { font-size: 1rem; font-weight: 700; color: var(--dark); }

        /* ── TEAM SECTION ── */
        .team-section { background: white; padding: 90px 0; }
        .team-card {
            background: var(--cream);
            border-radius: 20px;
            overflow: hidden;
            transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            border: 1.5px solid transparent;
            height: 100%;
        }
        .team-card:hover { transform: translateY(-10px); border-color: var(--red-light); box-shadow: 0 24px 60px rgba(201,36,43,0.12); }
        .team-photo-wrap {
            position: relative;
            background: linear-gradient(135deg, var(--red-dark), var(--red));
            padding: 32px 32px 0;
            text-align: center;
        }
        .team-photo {
            width: 120px; height: 120px; border-radius: 50%; object-fit: cover;
            border: 4px solid white;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            background: #ddd;
            display: block; margin: 0 auto;
        }
        .team-photo-placeholder {
            width: 120px; height: 120px; border-radius: 50%;
            border: 4px solid white;
            box-shadow: 0 8px 24px rgba(0,0,0,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 2.2rem; font-weight: 900; color: var(--red);
            background: white;
            margin: 0 auto;
        }
        .team-body { padding: 24px; text-align: center; }
        .team-name { font-size: 1.15rem; font-weight: 900; color: var(--dark); margin-bottom: 4px; }
        .team-role {
            display: inline-block; background: var(--red-light); color: var(--red);
            font-size: 0.78rem; font-weight: 800; padding: 4px 14px; border-radius: 20px;
            letter-spacing: 0.5px; margin-bottom: 14px;
        }
        .team-desc { font-size: 0.88rem; color: #666; line-height: 1.65; margin: 0; }
        .team-card .team-socials { display: flex; justify-content: center; gap: 10px; margin-top: 16px; }
        .team-social-btn {
            width: 34px; height: 34px; border-radius: 8px; background: var(--red-light);
            display: flex; align-items: center; justify-content: center;
            color: var(--red); font-size: 0.85rem; text-decoration: none; transition: all 0.2s;
        }
        .team-social-btn:hover { background: var(--red); color: white; }

        /* ── CONTACT ── */
        .contact-section { background: var(--dark); padding: 80px 0; position: relative; overflow: hidden; }
        .contact-section::before { content: ''; position: absolute; top: -80px; right: -80px; width: 300px; height: 300px; background: rgba(201,36,43,0.15); border-radius: 50%; }
        .contact-section h2 { font-size: 2.2rem; font-weight: 900; color: white; margin-bottom: 10px; }
        .contact-section p { color: rgba(255,255,255,0.7); margin-bottom: 8px; }
        .btn-feedback {
            background: var(--red); border: none; color: white;
            font-family: 'Nunito', sans-serif; font-size: 1rem; font-weight: 700;
            padding: 13px 32px; border-radius: 30px; cursor: pointer; margin-top: 24px; transition: all 0.25s;
        }
        .btn-feedback:hover { background: var(--red-dark); transform: translateY(-2px); }

        /* ── ANIMATIONS ── */
        @keyframes fadeUp { from { opacity: 0; transform: translateY(28px); } to { opacity: 1; transform: translateY(0); } }
        .reveal { opacity: 0; transform: translateY(30px); transition: opacity 0.65s ease, transform 0.65s ease; }
        .reveal.visible { opacity: 1; transform: translateY(0); }
        .reveal-left { opacity: 0; transform: translateX(-30px); transition: opacity 0.65s ease, transform 0.65s ease; }
        .reveal-left.visible { opacity: 1; transform: translateX(0); }
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
            <div class="hero-content">
                <div class="hero-badge"><i class="fa-solid fa-users me-2"></i>About Us</div>
                <h1 class="hero-title">Empowering Everyone to Be a <span>First Responder</span></h1>
                <p class="hero-subtitle">Aidcademy is a first-aid learning platform built to make life-saving skills accessible, engaging, and practical for everyone.</p>
            </div>
        </div>
    </section>

    <!-- MISSION & OBJECTIVE -->
    <section class="mission-section">
        <div class="container">
            <div class="text-center mb-5 reveal">
                <div class="section-label">Our Purpose</div>
                <h2 class="section-title">What Drives Us</h2>
            </div>
            <div class="row g-4">
                <div class="col-md-4 reveal" style="transition-delay:0.1s">
                    <div class="mission-card">
                        <div class="mission-icon"><i class="fa-solid fa-bullseye"></i></div>
                        <h3>Our Mission</h3>
                        <p>To develop an interactive learning platform on first-aid education, providing interactive courses and step-by-step walkthroughs that encourage continuous learning and build confidence in handling real-life emergencies.</p>
                    </div>
                </div>
                <div class="col-md-4 reveal" style="transition-delay:0.2s">
                    <div class="mission-card">
                        <div class="mission-icon"><i class="fa-solid fa-flag-checkered"></i></div>
                        <h3>Our Objective</h3>
                        <p>To develop a feature-rich, accessible, and interactive first-aid education platform that equips users with practical knowledge and skills they can rely on in critical moments.</p>
                    </div>
                </div>
                <div class="col-md-4 reveal" style="transition-delay:0.3s">
                    <div class="mission-card">
                        <div class="mission-icon"><i class="fa-solid fa-eye"></i></div>
                        <h3>Our Vision</h3>
                        <p>A world where every person has access to life-saving first-aid knowledge and the confidence to act quickly and correctly when it matters most.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FEATURES -->
    <section class="features-section">
        <div class="container">
            <div class="text-center mb-5 reveal">
                <div class="section-label">Platform Features</div>
                <h2 class="section-title">What We Offer</h2>
            </div>
            <div class="row g-3">
                <div class="col-md-6 reveal" style="transition-delay:0.1s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-book-open-reader"></i></div>
                        <span>Structured Learning Materials</span>
                    </div>
                </div>
                <div class="col-md-6 reveal" style="transition-delay:0.15s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-brain"></i></div>
                        <span>Interactive Quizzes &amp; Assessments</span>
                    </div>
                </div>
                <div class="col-md-6 reveal" style="transition-delay:0.2s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-chart-line"></i></div>
                        <span>Progress Tracking &amp; XP System</span>
                    </div>
                </div>
                <div class="col-md-6 reveal" style="transition-delay:0.25s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-gamepad"></i></div>
                        <span>Emergency Simulations</span>
                    </div>
                </div>
                <div class="col-md-6 reveal" style="transition-delay:0.3s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-comments"></i></div>
                        <span>Member Q&amp;A Support</span>
                    </div>
                </div>
                <div class="col-md-6 reveal" style="transition-delay:0.35s">
                    <div class="feature-pill">
                        <div class="feature-pill-icon"><i class="fa-solid fa-fire"></i></div>
                        <span>Daily Learning Streaks</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- TEAM SECTION -->
    <section class="team-section">
        <div class="container">
            <div class="text-center mb-5 reveal">
                <div class="section-label">The Team</div>
                <h2 class="section-title">Meet the Developers</h2>
                <p class="text-muted mt-2" style="font-size:1rem;">The passionate team behind Aidcademy.</p>
            </div>
            <div class="row g-4 justify-content-center">

                <!-- Developer 1 — Replace placeholder text with your real info -->
                <div class="col-sm-6 col-lg-3 reveal" style="transition-delay:0.1s">
                    <div class="team-card">
                        <div class="team-photo-wrap">
                            <img class="team-photo" src="image/yyz.png" alt="Yeo Ying Zhe" />
                        </div>
                        <div class="team-body">
                            <div class="team-name">Yeo Ying Zhe</div>
                            <div class="team-role">Team Leader / Instructor Module</div>
                            <p class="team-desc">Responsible for instructor dashboard, lesson and quiz management, course content upload, interactive simulation builder, and platform oversight.</p>
                        </div>
                    </div>
                </div>

                <!-- Developer 2 -->
                <div class="col-sm-6 col-lg-3 reveal" style="transition-delay:0.2s">
                    <div class="team-card">
                        <div class="team-photo-wrap">
                            <img class="team-photo" src="image/tay.jpg" alt="Tay Jia Zan" />
                        </div>
                        <div class="team-body">
                            <div class="team-name">Tay Jia Zan</div>
                            <div class="team-role">Member Module</div>
                            <p class="team-desc">Responsible for the member dashboard, course enrolment, lesson viewing, progress tracking, and XP reward system.</p>
                        </div>
                    </div>
                </div>

                <!-- Developer 3 -->
                <div class="col-sm-6 col-lg-3 reveal" style="transition-delay:0.3s">
                    <div class="team-card">
                        <div class="team-photo-wrap">
                            <img class="team-photo" src="image/akio.jpg" alt="Akio Niko Caldino" />
                        </div>
                        <div class="team-body">
                            <div class="team-name">Akio Niko Caldino</div>
                            <div class="team-role">Admin Module</div>
                            <p class="team-desc">Responsible for the admin dashboard, user management, content approval, and site analytics.</p>
                        </div>
                    </div>
                </div>

                <!-- Developer 4 -->
                <div class="col-sm-6 col-lg-3 reveal" style="transition-delay:0.4s">
                    <div class="team-card">
                        <div class="team-photo-wrap">
                            <img class="team-photo" src="image/goh.jpg" alt="Goh Jun Guan" />
                        </div>
                        <div class="team-body">
                            <div class="team-name">Goh Jun Guan</div>
                            <div class="team-role">Visitor</div>
                            <p class="team-desc">Responsible for the visitor landing page.</p>
                        </div>
                    </div>
                </div>

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
                <asp:Button ID="btnFeedback" runat="server" Text="Send Feedback" CssClass="btn-feedback" PostBackUrl="FeedbackForm.aspx" />
            </div>
        </div>
    </section>

</form>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) {
                e.target.classList.add('visible');
            }
        });
    }, { threshold: 0.1 });
    document.querySelectorAll('.reveal, .reveal-left').forEach(el => observer.observe(el));
</script>
</body>
</html>
