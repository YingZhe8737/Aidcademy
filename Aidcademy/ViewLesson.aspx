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
        /* ------------------------------------------- */
        /* 1. THE 3D FLIP CARD CSS FOR MEMBERS         */
        /* ------------------------------------------- */
        .actual-3d-flip-card {
            background-color: transparent;
            width: 100%;
            max-width: 400px;
            height: 250px;
            perspective: 1000px; /* Gives the 3D depth */
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
    </style>
</head>

<body class="bg-light">
    <form id="form1" runat="server">
        <div class="container mt-5 mb-5">
            <div class="row justify-content-center">
                <div class="col-lg-8">

                    <div class="mb-4 border-bottom pb-3">
                        <h1 class="fw-bold text-danger">
                            <asp:Label ID="lblTitle" runat="server"></asp:Label>
                        </h1>
                        <span class="badge bg-secondary">Step <asp:Label ID="lblSequence" runat="server"></asp:Label></span>
                    </div>

                    <div class="lesson-content bg-white p-5 rounded shadow-sm">
                        <asp:Literal ID="litLessonContent" runat="server"></asp:Literal>
                    </div>

                    <asp:Panel ID="pnlQuiz" runat="server" Visible="false"
                        CssClass="mt-5 p-4 bg-white rounded shadow-sm border-top border-warning border-4">
                        <h4 class="fw-bold mb-4"><i class="fa-solid fa-clipboard-question text-warning me-2"></i>Knowledge Check</h4>

                            <asp:Repeater ID="rptQuiz" runat="server" OnItemDataBound="rptQuiz_ItemDataBound">
                                <ItemTemplate>
                                    <div class="mb-4 pb-3 border-bottom">
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

                        <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Quiz" CssClass="btn btn-warning fw-bold px-4 fs-5 mt-2" OnClick="btnSubmitQuiz_Click" />
                        
                        <asp:Label ID="lblQuizScore" runat="server" CssClass="d-block mt-3"></asp:Label>
                    </asp:Panel>

                </div>
            </div>
        </div>
    </form>

    <script>
        // =========================================================================
        // THE UNPACKING SCRIPT
        // Transforms the static Editor blocks into highly interactive Student blocks
        // =========================================================================
        window.onload = function () {

            // 1. UNPACK FLIP CARDS
            document.querySelectorAll('.aidcademy-custom-flipcard').forEach(function (card) {
                // Grab the hidden data saved by Quill
                let front = card.getAttribute('data-front');
                let back = card.getAttribute('data-back');
                let img = card.getAttribute('data-img');

                let imgHtml = img ? `<img src="${img}" alt="Card Image" />` : '';

                // Overwrite the block with actual 3D animation HTML
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

                // Strip the old editor class and apply the 3D member class
                card.className = 'actual-3d-flip-card';
                card.removeAttribute('style');
                card.removeAttribute('contenteditable');
            });

            // 2. UNPACK ACCORDIONS
            document.querySelectorAll('.aidcademy-custom-accordion').forEach(function (acc) {
                // Grab the hidden data saved by Quill
                let title = acc.getAttribute('data-title');
                let content = acc.getAttribute('data-content');

                // Overwrite the block with native HTML5 interactive Accordion
                acc.innerHTML = `
                <details class="member-accordion my-4">
                    <summary class="fw-bold fs-5 text-dark">
                        <i class="fa-solid fa-chevron-right me-3 text-danger transition-icon"></i>${title}
                    </summary>
                    <div class="mt-3 pt-3 border-top text-secondary fs-6">
                        ${content}
                    </div>
                </details>`;

                // Strip editor styles
                acc.className = '';
                acc.removeAttribute('style');
                acc.removeAttribute('contenteditable');
            });

        };
    </script>
</body>
</html>