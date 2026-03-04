<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewLesson.aspx.cs" Inherits="Aidcademy.ViewLesson" %>

<!DOCTYPE html>
<html>
<head runat="server">
    <title>View Lesson - Aidcademy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="Instructor.css" rel="stylesheet" type="text/css" />
    <style>
        /* Apply your new theme color */
        body {
            background-color: #FFFBF1 !important;
        }

        /* ------------------------------------------- */
        /* SIDEBAR & NAVBAR CSS                        */
        /* ------------------------------------------- */
        .top-navbar {
            background-color: #c9242b;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }

        .sidebar-wrapper {
            background-color: #ffffff;
            min-height: calc(100vh - 60px); /* Fill the screen under navbar */
            border-right: 2px solid #f0e6d2;
        }

        .sidebar-link {
            color: #495057;
            text-decoration: none;
            padding: 10px 15px;
            display: block;
            border-radius: 8px;
            margin-bottom: 5px;
            font-weight: 500;
            transition: all 0.2s ease-in-out;
        }

        .sidebar-link:hover {
            background-color: #f8f9fa;
            color: #c9242b;
            transform: translateX(3px);
        }

        /* Highlight the lesson they are currently looking at */
        .sidebar-link.active-lesson {
            background-color: #f8d7da;
            color: #c9242b;
            font-weight: bold;
            border-left: 4px solid #c9242b;
        }

        /* ------------------------------------------- */
        /* 1. THE 3D FLIP CARD CSS FOR MEMBERS         */
        /* ------------------------------------------- */
        .actual-3d-flip-card {
            background-color: transparent;
            width: 100%;
            max-width: 400px;
            height: 250px;
            perspective: 1000px; 
            margin: 25px auto;
        }

        .flip-card-inner {
            position: relative;
            width: 100%;
            height: 100%;
            text-align: center;
            transition: transform 0.6s cubic-bezier(0.4, 0.2, 0.2, 1);
            transform-style: preserve-3d;
            box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1);
            border-radius: 12px;
        }

        .actual-3d-flip-card:hover .flip-card-inner { transform: rotateY(180deg); }

        .flip-card-front, .flip-card-back {
            position: absolute;
            width: 100%;
            height: 100%;
            -webkit-backface-visibility: hidden;
            backface-visibility: hidden;
            border-radius: 12px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .flip-card-front {
            background-color: #f8f9fa;
            color: #333;
            border: 2px solid #c9242b;
        }

        .flip-card-front img {
            max-height: 100px;
            margin-bottom: 15px;
            border-radius: 8px;
        }

        .flip-card-back {
            background-color: #c9242b;
            color: white;
            transform: rotateY(180deg);
            border: 2px solid #a31c22;
        }

        /* ------------------------------------------- */
        /* 2. THE INTERACTIVE ACCORDION FOR MEMBERS    */
        /* ------------------------------------------- */
        .member-accordion {
            background-color: #ffffff;
            border: 1px solid #e0e0e0;
            border-left: 5px solid #c9242b;
            border-radius: 8px;
            padding: 15px 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
            transition: box-shadow 0.2s ease-in-out;
        }

        .member-accordion:hover {
            box-shadow: 0 6px 12px rgba(0,0,0,0.06);
        }

        .member-accordion summary {
            cursor: pointer;
            list-style: none; /* Hides default browser arrow */
            outline: none;
        }

        .transition-icon {
            transition: transform 0.2s ease-in-out;
        }

        .member-accordion[open] summary .transition-icon {
            transform: rotate(90deg);
        }

/* ------------------------------------------- */
        /* 3. GENERAL LESSON TYPOGRAPHY                */
        /* ------------------------------------------- */
        .lesson-content {
            font-family: 'Segoe UI', Tahoma, sans-serif;
            font-size: 1.1rem;
            line-height: 1.8;
            color: #333;
        }

        .lesson-content img {
            max-width: 100%;
            height: auto;
            border-radius: 8px;
            margin: 15px 0;
        }

        /* NEW: Force all Quill videos into a perfect 16:9 ratio */
        .lesson-content iframe.ql-video {
            width: 100%;
            aspect-ratio: 16 / 9;
            height: auto;
            border-radius: 8px;
            margin: 15px 0;
            border: none;
            box-shadow: 0 4px 6px rgba(0,0,0,0.1);
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        
        <nav class="navbar navbar-expand-lg navbar-dark top-navbar sticky-top">
            <div class="container-fluid px-4">
                <a class="navbar-brand fw-bold fs-4" href="#">
                    <i class="fa-solid fa-house-medical me-2 text-white"></i>Aidcademy
                </a>
                <div class="d-flex align-items-center">
                    <span class="text-light fw-bold me-3"><i class="fa-solid fa-book-open-reader me-2"></i>Lesson Viewer</span>
                </div>
            </div>
        </nav>

        <div class="container-fluid">
            <div class="row">
                
                <div class="col-md-4 col-lg-3 p-0 sidebar-wrapper shadow-sm d-none d-md-block">
                    <div class="p-4">
                        <h5 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-list text-danger me-2"></i>Course Curriculum</h5>
                        
                        <asp:Repeater ID="rptSidebarCourses" runat="server" OnItemDataBound="rptSidebarCourses_ItemDataBound">
                            <ItemTemplate>
                                <div class="mb-4">
                                    <h6 class="fw-bold text-secondary text-uppercase border-bottom pb-2 mb-3" style="letter-spacing: 1px; font-size: 0.85rem;">
                                        <%# Eval("CourseTitle") %>
                                    </h6>
                                    
                                    <asp:Repeater ID="rptSidebarLessons" runat="server">
                                        <ItemTemplate>
                                            <a href='ViewLesson.aspx?LessonID=<%# Eval("LessonID") %>' 
                                               class='sidebar-link <%# Eval("LessonID").ToString() == Request.QueryString["LessonID"] ? "active-lesson" : "" %>'>
                                                <i class="fa-regular fa-circle-play me-2 text-muted"></i>
                                                Step <%# Eval("SequenceOrder") %>: <%# Eval("LessonTitle") %>
                                            </a>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <div class="col-md-8 col-lg-9 p-4 p-lg-5">
                    
                    <a href="javascript:history.back()" class="btn btn-outline-secondary rounded-pill shadow-sm fw-bold mb-4 px-4">
                        <i class="fa-solid fa-arrow-left me-2"></i> Back
                    </a>

                    <div class="row justify-content-center">
                        <div class="col-xl-10">

                            <div class="mb-4 border-bottom border-danger border-2 pb-3">
                                <h1 class="fw-bold text-dark mb-2">
                                    <asp:Label ID="lblTitle" runat="server"></asp:Label>
                                </h1>
                                <span class="badge bg-danger fs-6 px-3 py-2 rounded-pill shadow-sm">
                                    Step <asp:Label ID="lblSequence" runat="server"></asp:Label>
                                </span>
                            </div>

                            <div class="lesson-content bg-white p-4 p-md-5 rounded-4 shadow-sm border border-light">
                                <asp:Literal ID="litLessonContent" runat="server"></asp:Literal>
                            </div>

                            <asp:Panel ID="pnlQuiz" runat="server" Visible="false"
                                CssClass="mt-5 p-4 p-md-5 bg-white rounded-4 shadow-sm border-top border-warning border-4">
                                <h4 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-clipboard-question text-warning me-2 fs-3"></i>Knowledge Check</h4>

                                <asp:Repeater ID="rptQuiz" runat="server" OnItemDataBound="rptQuiz_ItemDataBound">
                                    <ItemTemplate>
                                        <div class="mb-4 pb-4 border-bottom border-light">
                                            <p class="fs-5 fw-bold text-dark mb-3">
                                                <%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %>
                                            </p>
                                            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="form-check fs-5" CellSpacing="10"></asp:RadioButtonList>
                                            <asp:HiddenField ID="hfCorrectAnswer" runat="server" Value='<%# Eval("CorrectAnswer") %>' />
                                            <asp:Label ID="lblFeedback" runat="server" CssClass="d-block mt-2"></asp:Label>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>

                                <asp:HiddenField ID="hfQuizID" runat="server" />
                                <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Answers" CssClass="btn btn-warning fw-bold px-5 py-2 fs-5 mt-3 shadow-sm rounded-pill" OnClick="btnSubmitQuiz_Click" />
                                <asp:Label ID="lblQuizScore" runat="server" CssClass="d-block mt-3"></asp:Label>
                            </asp:Panel>

                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        // =========================================================================
        // THE UNPACKING SCRIPT
        // =========================================================================
        window.onload = function () {

            // 1. UNPACK FLIP CARDS
            document.querySelectorAll('.aidcademy-custom-flipcard').forEach(function (card) {
                let front = card.getAttribute('data-front');
                let back = card.getAttribute('data-back');
                let img = card.getAttribute('data-img');
                let imgHtml = img ? `<img src="${img}" alt="Card Image" />` : '';

                card.innerHTML = `
                <div class="flip-card-inner">
                    <div class="flip-card-front shadow-sm">
                        ${imgHtml}
                        <h3 class="fw-bold m-0">${front}</h3>
                        <small class="text-danger mt-3 fw-bold text-uppercase" style="letter-spacing: 1px;"><i class="fa-solid fa-hand-pointer me-1"></i> Hover to reveal</small>
                    </div>
                    <div class="flip-card-back shadow-sm">
                        <p class="fs-5 m-0 px-2">${back}</p>
                    </div>
                </div>`;

                card.className = 'actual-3d-flip-card';
                card.removeAttribute('style');
                card.removeAttribute('contenteditable');
            });

            // 2. UNPACK ACCORDIONS
            document.querySelectorAll('.aidcademy-custom-accordion').forEach(function (acc) {
                let title = acc.getAttribute('data-title');
                let content = acc.getAttribute('data-content');

                acc.innerHTML = `
                <details class="member-accordion my-4">
                    <summary class="fw-bold fs-5 text-dark">
                        <i class="fa-solid fa-chevron-right me-3 text-danger transition-icon"></i>${title}
                    </summary>
                    <div class="mt-3 pt-3 border-top text-secondary fs-6">
                        ${content}
                    </div>
                </details>`;

                acc.className = '';
                acc.removeAttribute('style');
                acc.removeAttribute('contenteditable');
            });
        };
    </script>
</body>
</html>