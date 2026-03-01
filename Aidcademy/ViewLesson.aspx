<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ViewLesson.aspx.cs" Inherits="Aidcademy.ViewLesson" %>

<!DOCTYPE html>
<style>
    /* Forces Quill Videos to be beautiful 16:9 widescreen */
    .ql-video { width: 100%; height: 400px; border-radius: 8px; }
</style>
<html>
<head runat="server">
    <title>View Lesson - Aidcademy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    
    <style>
        .ql-align-center { text-align: center; }
        .ql-align-right { text-align: right; }
        .ql-align-justify { text-align: justify; }

        /* 1. THE 3D FLIP CARD CSS FOR MEMBERS */
        .actual-3d-flip-card {
            background-color: transparent;
            width: 100%;
            max-width: 400px;
            height: 250px;
            perspective: 1000px; /* Gives the 3D depth */
            margin: 20px auto;
        }

        .flip-card-inner {
            position: relative;
            width: 100%;
            height: 100%;
            text-align: center;
            transition: transform 0.6s;
            transform-style: preserve-3d;
            box-shadow: 0 4px 8px 0 rgba(0,0,0,0.2);
            border-radius: 12px;
        }

        /* Trigger the flip on hover */
        .actual-3d-flip-card:hover .flip-card-inner {
            transform: rotateY(180deg);
        }

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
        }

        /* 2. GENERAL LESSON TYPOGRAPHY */
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
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container mt-5 mb-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    
                    <div class="mb-4 border-bottom pb-3">
                        <h1 class="fw-bold text-danger"><asp:Label ID="lblTitle" runat="server"></asp:Label></h1>
                        <span class="badge bg-secondary">Step <asp:Label ID="lblSequence" runat="server"></asp:Label></span>
                    </div>

                    <div class="lesson-content bg-white p-5 rounded shadow-sm">
                        <asp:Literal ID="litLessonContent" runat="server"></asp:Literal>
                    </div>
                    <asp:Panel ID="pnlQuiz" runat="server" Visible="false" CssClass="mt-5 p-4 bg-white rounded shadow-sm border-top border-warning border-4">
                        <h4 class="fw-bold mb-3"><i class="fa-solid fa-clipboard-question text-warning me-2"></i>Knowledge Check</h4>
                        
                        <p class="fs-5 mb-4"><asp:Label ID="lblQuestionText" runat="server"></asp:Label></p>
                        
                        <div class="mb-4">
                            <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="form-check fs-5" CellSpacing="10">
                            </asp:RadioButtonList>
                        </div>
                        
                        <asp:Button ID="btnSubmitAnswer" runat="server" Text="Check Answer" CssClass="btn btn-warning fw-bold px-4" OnClick="btnSubmitAnswer_Click" />
                        <asp:Label ID="lblQuizResult" runat="server" CssClass="d-block mt-3 fw-bold fs-5"></asp:Label>
                        <asp:HiddenField ID="hfCorrectAnswer" runat="server" />
                    </asp:Panel>

                </div>
            </div>
        </div>
    </form>

    <script>
        // THE UNPACKING SCRIPT
        // This runs instantly when the member opens the page.
        // It finds the Instructor's "Red Dashed Box", reads the hidden data, and turns it into a real 3D card!
        window.onload = function () {
            document.querySelectorAll('.aidcademy-flipcard-data').forEach(function(card) {
                
                // 1. Grab the hidden data we saved in the Instructor Edit Page
                let front = card.getAttribute('data-front');
                let back = card.getAttribute('data-back');
                let img = card.getAttribute('data-img');
                
                let imgHtml = img ? `<img src="${img}" alt="Card Image" />` : '';

                // 2. Overwrite the red dashed box with the real 3D structure
                card.innerHTML = `
                    <div class="flip-card-inner">
                        <div class="flip-card-front">
                            ${imgHtml}
                            <h3 class="fw-bold m-0">${front}</h3>
                            <small class="text-muted mt-2"><i class="fa-solid fa-hand-pointer me-1"></i> Hover to reveal</small>
                        </div>
                        <div class="flip-card-back">
                            <p class="fs-5 m-0">${back}</p>
                        </div>
                    </div>
                `;
                
                // 3. Swap the CSS class
                card.className = 'actual-3d-flip-card';
            });
        };
    </script>
</body>
</html>