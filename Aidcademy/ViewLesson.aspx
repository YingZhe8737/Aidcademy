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
        body { background-color: #FFFBF1 !important; }

        /* NAVBAR & DYNAMIC SIDEBAR CSS */
        .top-navbar { background-color: #c9242b; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        #wrapper { overflow-x: hidden; }
        #sidebar-wrapper {
            min-height: calc(100vh - 60px);
            width: 320px;
            margin-left: 0;
            transition: margin 0.3s ease-out;
            background-color: #ffffff;
            border-right: 2px solid #f0e6d2;
            flex-shrink: 0; 
        }
        #sidebar-wrapper.collapsed { margin-left: -320px; }
        #page-content-wrapper { width: 100%; transition: all 0.3s ease-out; }
        
        .sidebar-link { color: #495057; text-decoration: none; padding: 10px 15px; display: block; border-radius: 8px; margin-bottom: 5px; font-weight: 500; transition: all 0.2s ease-in-out; }
        .sidebar-link:hover { background-color: #f8f9fa; color: #c9242b; transform: translateX(3px); }
        .sidebar-link.active-lesson { background-color: #f8d7da; color: #c9242b; font-weight: bold; border-left: 4px solid #c9242b; }

        /* MEMBER COMPONENTS */
        .actual-3d-flip-card { background-color: transparent; width: 100%; max-width: 400px; height: 250px; perspective: 1000px; margin: 25px auto; }
        .flip-card-inner { position: relative; width: 100%; height: 100%; text-align: center; transition: transform 0.6s cubic-bezier(0.4, 0.2, 0.2, 1); transform-style: preserve-3d; box-shadow: 0 6px 12px rgba(0, 0, 0, 0.1); border-radius: 12px; }
        .actual-3d-flip-card:hover .flip-card-inner { transform: rotateY(180deg); }
        .flip-card-front, .flip-card-back { position: absolute; width: 100%; height: 100%; -webkit-backface-visibility: hidden; backface-visibility: hidden; border-radius: 12px; display: flex; flex-direction: column; justify-content: center; align-items: center; padding: 20px; }
        .flip-card-front { background-color: #f8f9fa; color: #333; border: 2px solid #c9242b; }
        .flip-card-front img { max-height: 100px; margin-bottom: 15px; border-radius: 8px; }
        .flip-card-back { background-color: #c9242b; color: white; transform: rotateY(180deg); border: 2px solid #a31c22; }

        .member-accordion { background-color: #ffffff; border: 1px solid #e0e0e0; border-left: 5px solid #c9242b; border-radius: 8px; padding: 15px 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); transition: box-shadow 0.2s ease-in-out; }
        .member-accordion:hover { box-shadow: 0 6px 12px rgba(0,0,0,0.06); }
        .member-accordion summary { cursor: pointer; list-style: none; outline: none; }
        .transition-icon { transition: transform 0.2s ease-in-out; }
        .member-accordion[open] summary .transition-icon { transform: rotate(90deg); }

        .lesson-content { font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 1.1rem; line-height: 1.8; color: #333; }
        .lesson-content img { max-width: 100%; height: auto; border-radius: 8px; margin: 15px 0; }
        .lesson-content iframe.ql-video { width: 100%; aspect-ratio: 16 / 9; height: auto; border-radius: 8px; margin: 15px 0; border: none; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        
        <nav class="navbar navbar-expand-lg navbar-dark top-navbar sticky-top">
            <div class="container-fluid px-4">
                <a class="navbar-brand fw-bold fs-4 m-0" href="MainPage.aspx">
                    <i class="fa-solid fa-house-medical me-2 text-white"></i>Aidcademy
                </a>
                
                <div class="d-flex align-items-center">
                    
                    <asp:Panel ID="pnlNavVisitor" runat="server" Visible="false">
                        <a href="Login_signup.aspx" class="btn btn-light fw-bold text-danger btn-sm rounded-pill px-3 shadow-sm">Login / Sign Up</a>
                    </asp:Panel>
                    
                    <asp:Panel ID="pnlNavMember" runat="server" Visible="false">
                        <a href="MemberDashboard.aspx" class="text-light fw-bold text-decoration-none me-3"><i class="fa-solid fa-gauge me-1"></i> My Dashboard</a>
                    </asp:Panel>

                    <asp:Panel ID="pnlNavInstructor" runat="server" Visible="false">
                        <a href="InstructorManageContent.aspx" class="text-light fw-bold text-decoration-none me-3"><i class="fa-solid fa-chalkboard-user me-1"></i> Instructor Panel</a>
                    </asp:Panel>

                    <asp:Panel ID="pnlNavAdmin" runat="server" Visible="false">
                        <a href="AdminDashboard.aspx" class="text-light fw-bold text-decoration-none me-3"><i class="fa-solid fa-shield-halved me-1"></i> Admin Console</a>
                    </asp:Panel>

                    <span class="text-light fw-bold border-start border-light ps-3 ms-2 opacity-75"><i class="fa-solid fa-book-open-reader me-2"></i>Lesson Viewer</span>
                </div>
            </div>
        </nav>

        <div class="d-flex" id="wrapper">
            
            <div id="sidebar-wrapper" class="shadow-sm">
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

            <div id="page-content-wrapper" class="p-4 p-lg-5">
                
                <div class="d-flex align-items-center mb-4">
                    <button class="btn btn-danger rounded-circle me-3 shadow-sm d-flex align-items-center justify-content-center" id="sidebarToggle" type="button" style="width: 45px; height: 45px;">
                        <i class="fa-solid fa-bars fs-5"></i>
                    </button>
                    <asp:HyperLink ID="hlBackBtn" runat="server" CssClass="btn btn-outline-secondary rounded-pill shadow-sm fw-bold px-4">
                        <i class="fa-solid fa-arrow-left me-2"></i> Back
                    </asp:HyperLink>
                </div>

                <div class="row justify-content-center">
                    <div class="col-xl-10">
                        <div class="mb-4 border-bottom border-danger border-2 pb-3">
                            <h1 class="fw-bold text-dark mb-2"><asp:Label ID="lblTitle" runat="server"></asp:Label></h1>
                            <span class="badge bg-danger fs-6 px-3 py-2 rounded-pill shadow-sm">
                                Step <asp:Label ID="lblSequence" runat="server"></asp:Label>
                            </span>
                        </div>

                        <div class="lesson-content bg-white p-4 p-md-5 rounded-4 shadow-sm border border-light">
                            <asp:Literal ID="litLessonContent" runat="server"></asp:Literal>
                        </div>

                        <div id="simulationContainer" class="mt-5" style="display:none;"></div>
                        <asp:HiddenField ID="hfLoadedSimType" runat="server" />
                        <asp:HiddenField ID="hfLoadedSimData" runat="server" />

                        <asp:Panel ID="pnlQuiz" runat="server" Visible="false" CssClass="mt-5 p-4 p-md-5 bg-white rounded-4 shadow-sm border-top border-warning border-4">
                            <h4 class="fw-bold mb-4 text-dark"><i class="fa-solid fa-clipboard-question text-warning me-2 fs-3"></i>Knowledge Check</h4>
                            <asp:Repeater ID="rptQuiz" runat="server" OnItemDataBound="rptQuiz_ItemDataBound">
                                <ItemTemplate>
                                    <div class="mb-4 pb-4 border-bottom border-light">
                                        <p class="fs-5 fw-bold text-dark mb-3"><%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %></p>
                                        <asp:RadioButtonList ID="rblOptions" runat="server" CssClass="form-check fs-5" CellSpacing="10"></asp:RadioButtonList>
                                        <asp:HiddenField ID="hfCorrectAnswer" runat="server" Value='<%# Eval("CorrectAnswer") %>' />
                                        <asp:Label ID="lblFeedback" runat="server" CssClass="d-block mt-2"></asp:Label>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                            <asp:HiddenField ID="hfQuizID" runat="server" />
                            
                            <asp:Button ID="btnSubmitQuiz" runat="server" Text="Submit Answers" CssClass="btn btn-warning fw-bold px-5 py-2 fs-5 mt-3 shadow-sm rounded-pill" OnClick="btnSubmitQuiz_Click" />
                            <asp:Label ID="lblVisitorQuizWarning" runat="server" CssClass="text-danger fw-bold ms-3" Visible="false"><i class="fa-solid fa-lock me-1"></i> Log in to submit quizzes and earn XP!</asp:Label>
                            
                            <asp:Label ID="lblQuizScore" runat="server" CssClass="d-block mt-3"></asp:Label>
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <script>
        window.onload = function () {
            // HAMBURGER TOGGLE LOGIC
            document.getElementById("sidebarToggle").addEventListener("click", function (e) {
                e.preventDefault();
                document.getElementById("sidebar-wrapper").classList.toggle("collapsed");
            });

            // UNPACK FLIP CARDS & ACCORDIONS
            document.querySelectorAll('.aidcademy-custom-flipcard').forEach(function (card) {
                let front = card.getAttribute('data-front'), back = card.getAttribute('data-back'), img = card.getAttribute('data-img');
                card.innerHTML = `<div class="flip-card-inner"><div class="flip-card-front shadow-sm">${img ? `<img src="${img}" />` : ''}<h3 class="fw-bold m-0">${front}</h3><small class="text-danger mt-3 fw-bold text-uppercase" style="letter-spacing: 1px;"><i class="fa-solid fa-hand-pointer me-1"></i> Hover to reveal</small></div><div class="flip-card-back shadow-sm"><p class="fs-5 m-0 px-2">${back}</p></div></div>`;
                card.className = 'actual-3d-flip-card'; card.removeAttribute('style'); card.removeAttribute('contenteditable');
            });

            document.querySelectorAll('.aidcademy-custom-accordion').forEach(function (acc) {
                let title = acc.getAttribute('data-title'), content = acc.getAttribute('data-content');
                acc.innerHTML = `<details class="member-accordion my-4"><summary class="fw-bold fs-5 text-dark"><i class="fa-solid fa-chevron-right me-3 text-danger transition-icon"></i>${title}</summary><div class="mt-3 pt-3 border-top text-secondary fs-6">${content}</div></details>`;
                acc.className = ''; acc.removeAttribute('style'); acc.removeAttribute('contenteditable');
            });

            // THE GAME ENGINE BOOTSTRAPPER
            let simType = document.getElementById('<%= hfLoadedSimType.ClientID %>').value;
            let simData = document.getElementById('<%= hfLoadedSimData.ClientID %>').value;

            if (simType && simData) {
                let parsedData = JSON.parse(simData);
                document.getElementById('simulationContainer').style.display = "block";

                if (simType === "RhythmCPR") {
                    bootCprRhythmGame(parsedData);
                } else if (simType === "DragDropSequence") {
                    bootSequenceGame(parsedData);
                } else if (simType === "ChokingCombo") {
                    bootChokingGame(parsedData);
                } else if (simType === "BleedingTriage") {
                    bootBleedingGame(parsedData);
                } else if (simType === "StrokeFAST") {
                    bootStrokeGame(parsedData); 
                }
            }
            function bootCprRhythmGame(config) {
                let container = document.getElementById('simulationContainer');
                let bpm = parseInt(config.bpm) || 110;
                let targetTime = parseInt(config.targetTime) || 30;
                let msPerBeat = 60000 / bpm;

                // 1. Draw the UI
                container.innerHTML = `
                    <div class="card bg-white text-dark rounded-4 shadow-lg border-2 border-danger overflow-hidden">
                        <div class="card-header bg-danger text-white text-center py-3 fw-bold fs-5 d-flex justify-content-between px-4">
                            <span><i class="fa-solid fa-heart-pulse me-2"></i> CPR Simulator</span>
                            <span id="cprTimer" style="display: none;">00:${targetTime < 10 ? '0' + targetTime : targetTime}</span>
                        </div>
                        
                        <div id="phase1" class="card-body text-center p-4">
                            <h5 class="mb-4 text-danger fw-bold text-uppercase">Phase 1: Hand Placement</h5>
                            
                            <div class="alert alert-light border-secondary border-start border-4 mb-4 shadow-sm text-start">
                                <h6 class="fw-bold text-dark mb-2">Build the correct adult CPR hand position. Drag the bottom hand to the chest, then drag the correct top hand over it to interlock.</h6>
                            </div>
                            
                            <div class="row g-4 justify-content-center">
                                <div class="col-md-5 d-flex flex-column gap-4">
                                    <div>
                                        <h6 class="fw-bold text-muted border-bottom pb-2 text-uppercase small">1. Bottom Hand Options</h6>
                                        <div id="bottomHandBank" class="d-flex flex-wrap gap-2 p-2 border border-2 border-dashed border-secondary rounded bg-light min-vh-25"></div>
                                    </div>
                                    <div>
                                        <h6 class="fw-bold text-muted border-bottom pb-2 text-uppercase small">2. Top Hand Options</h6>
                                        <div id="topHandBank" class="d-flex flex-wrap gap-2 p-2 border border-2 border-dashed border-secondary rounded bg-light min-vh-25"></div>
                                    </div>
                                </div>
                                
                                <div class="col-md-7">
                                    <h6 class="fw-bold text-muted mb-3 border-bottom pb-2 text-uppercase small">The Patient's Chest</h6>
                                    <div id="handStage" class="d-flex align-items-center justify-content-center border border-2 border-dashed border-danger rounded bg-light mx-auto shadow-inner position-relative" 
                                         style="width: 100%; max-width: 320px; height: 350px;">
                                        
                                        <div class="position-absolute text-muted opacity-50 d-flex flex-column align-items-center" style="pointer-events: none;">
                                            <i class="fa-solid fa-crosshairs fs-1 mb-2"></i>
                                            <span class="fw-bold">Lower Sternum</span>
                                        </div>

                                        <div id="correctInterlockResult" class="card bg-success text-white fw-bold p-3 rounded-4 position-absolute top-50 start-50 translate-middle shadow-lg" 
                                             style="display: none; z-index: 10; width: 80%;">
                                            <i class="fa-solid fa-check-circle fs-2 mb-2"></i><br>Correct!<br>Heel on sternum, fingers interlocked.
                                        </div>
                                    </div>
                                    <div id="phase1Status" class="mt-4 fs-6 fw-bold text-danger text-center px-3" style="min-height: 40px;"></div>
                                </div>
                            </div>
                        </div>

                        <div id="phase2" class="card-body text-center p-4" style="display: none;">
                            <h5 class="mb-4 text-danger fw-bold text-uppercase">Phase 2: CPR Compressions</h5>
                            <h5 class="mb-3 text-dark">Target: <strong class="text-danger">${bpm} BPM</strong> | Ratio: <strong class="text-info">30:2</strong></h5>
                            
                            <div class="progress mb-3 shadow-sm" style="height: 25px; border-radius: 12px; background-color: #e9ecef;">
                                <div id="oxyBar" class="progress-bar bg-success progress-bar-striped progress-bar-animated text-dark fw-bold" style="width: 50%">Patient Oxygen</div>
                            </div>

                            <div class="d-flex justify-content-center gap-4 mb-3 fw-bold fs-5 text-dark">
                                <div id="statCompressions" class="text-danger">Compressions: <span id="valCompressions">0</span>/30</div>
                                <div id="statBreaths" class="text-info opacity-50">Breaths: <span id="valBreaths">0</span>/2</div>
                            </div>
                            
                            <div id="actionIcon" class="text-danger mb-4" style="font-size: 70px; transition: transform 0.1s; height: 80px;">
                                <i class="fa-solid fa-heart"></i>
                            </div>

                            <div id="breathContainer" class="progress mb-4 mx-auto shadow-sm" style="height: 30px; border-radius: 15px; background-color: #e9ecef; width: 60%; display: none;">
                                <div id="breathBar" class="progress-bar bg-info text-dark fw-bold" style="width: 0%; transition: none !important;">Lung Volume</div>
                            </div>
                            
                            <button type="button" id="btnAction" class="btn btn-light text-danger fw-bold rounded-circle shadow-lg d-flex align-items-center justify-content-center mx-auto" 
                                oncontextmenu="return false;"
                                style="width: 160px; height: 160px; border: 8px solid #c9242b; font-size: 1.4rem; cursor: pointer; transition: all 0.15s ease-in-out; user-select: none; touch-action: none;">
                                START
                            </button>
                            
                            <div id="cprStatus" class="mt-4 fs-5 fw-bold text-muted">Click START to begin</div>
                            
                            <button type="button" id="btnRetry" class="btn btn-danger text-white rounded-pill mt-3 px-4 py-2 fw-bold shadow-sm" style="display: none;">
                                <i class="fa-solid fa-rotate-right me-1"></i> Try Again
                            </button>
                        </div>
                    </div>
                `;

                let phase1 = document.getElementById('phase1');
                let phase2 = document.getElementById('phase2');
                let bottomBank = document.getElementById('bottomHandBank');
                let topBank = document.getElementById('topHandBank');
                let handStage = document.getElementById('handStage');
                let phase1Status = document.getElementById('phase1Status');
                let correctResult = document.getElementById('correctInterlockResult');
                let cprTimer = document.getElementById('cprTimer'); // NEW: Grab the timer element

                let currentBottomCardID = null;
                let selectedElement = null;

                const handVisuals = {
                    // BOTTOM HAND OPTIONS
                    bot_correct: { id: 'bot_correct', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Flat Hand<br>(Heel Down)</span></div>' },
                    bot_wrong_heelup: { id: 'bot_wrong_heelup', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-regular fa-hand fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Flat Hand<br>(Heel Up)</span></div>' },
                    bot_wrong_fist: { id: 'bot_wrong_fist', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand-back-fist fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Closed Fist</span></div>' },

                    // TOP HAND OPTIONS
                    top_interlock: { id: 'top_interlock', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hands fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Interlocked<br>Fingers</span></div>' },
                    top_wrong_flat: { id: 'top_wrong_flat', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Flat Hand<br>(No Lock)</span></div>' },
                    top_wrong_fist: { id: 'top_wrong_fist', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand-back-fist fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Closed Fist</span></div>' }
                };

                Object.values(handVisuals).forEach(h => {
                    let card = document.createElement('div');
                    card.className = "drag-hand-card p-1 bg-white border border-2 border-secondary rounded shadow-sm text-center user-select-none";
                    card.style.cursor = "grab";
                    card.style.flex = "1 1 calc(50% - 0.5rem)";
                    card.style.height = "85px";
                    card.innerHTML = h.html;
                    card.dataset.text = h.id;

                    card.draggable = true;
                    card.addEventListener('dragstart', function (e) {
                        selectedElement = this;
                        this.style.opacity = '0.5';
                        e.dataTransfer.effectAllowed = 'move';
                        e.dataTransfer.setData('text/plain', this.dataset.text);
                    });
                    card.addEventListener('dragend', function () { this.style.opacity = '1'; selectedElement = null; });
                    card.onclick = () => handleCardClick(card);

                    if (h.id.startsWith('bot')) bottomBank.appendChild(card);
                    else topBank.appendChild(card);
                });

                handStage.addEventListener('dragover', e => { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; });
                handStage.addEventListener('drop', function (e) {
                    e.preventDefault();
                    if (selectedElement) {
                        let textId = e.dataTransfer.getData('text/plain');
                        placeHandOnStage(selectedElement, textId);
                    }
                });

                function handleCardClick(card) {
                    if (card.parentElement === handStage) {
                        card.style.position = "static";
                        card.style.transform = "none";
                        card.style.width = "auto";
                        card.style.height = "85px";
                        card.style.zIndex = "1";
                        card.classList.replace('border-danger', 'border-secondary');
                        card.classList.replace('border-primary', 'border-secondary');

                        if (card.dataset.text.startsWith('bot')) {
                            bottomBank.appendChild(card);
                            currentBottomCardID = null;
                        } else {
                            topBank.appendChild(card);
                        }
                        phase1Status.innerText = "";
                        return;
                    }
                    placeHandOnStage(card, card.dataset.text);
                }

                function placeHandOnStage(card, textId) {
                    if (!currentBottomCardID) {
                        if (textId.startsWith('bot')) {
                            currentBottomCardID = textId;
                            handStage.appendChild(card);
                            applyPlacementVfx(card, 'bot');
                            phase1Status.innerText = "";
                        } else {
                            phase1Status.innerText = "Place the bottom hand on the chest first!";
                        }
                    } else {
                        if (textId.startsWith('top')) {
                            if (currentBottomCardID === 'bot_correct' && textId === 'top_interlock') {
                                handStage.appendChild(card);
                                applyPlacementVfx(card, 'top_correct');
                                phase1Status.className = "mt-4 fs-6 fw-bold text-success text-center px-3";
                                phase1Status.innerText = "Perfect! Transitioning to rhythm simulator...";
                                transitionToPhase2();
                            } else if (textId === 'top_interlock' && currentBottomCardID !== 'bot_correct') {
                                handStage.appendChild(card);
                                applyPlacementVfx(card, 'top_wrong');
                                phase1Status.innerText = "Interlocked fingers is correct, but your bottom hand is wrong (e.g. don't use a fist). Tap to remove them and try again.";
                            } else {
                                handStage.appendChild(card);
                                applyPlacementVfx(card, 'top_wrong');
                                phase1Status.innerText = "Incorrect top hand. You must interlock your fingers to keep them off the ribs!";
                            }
                        } else {
                            phase1Status.innerText = "Bottom hand is already set. Choose a top hand.";
                        }
                    }
                }

                function applyPlacementVfx(card, type) {
                    card.style.position = "absolute";
                    card.style.width = "140px";
                    card.style.height = "100px";
                    card.style.left = "50%";
                    card.style.transform = "translateX(-50%)";

                    if (type === 'bot') {
                        card.style.bottom = "30%";
                        card.style.zIndex = "2";
                        card.classList.replace('border-secondary', 'border-danger');
                    } else if (type === 'top_correct') {
                        card.style.bottom = "40%";
                        card.style.zIndex = "3";
                        card.classList.replace('border-secondary', 'border-success');
                        correctResult.style.display = "block";
                    } else if (type === 'top_wrong') {
                        card.style.bottom = "40%";
                        card.style.zIndex = "3";
                        card.classList.replace('border-secondary', 'border-danger');
                    }
                }

                function transitionToPhase2() {
                    document.querySelectorAll('.drag-hand-card').forEach(c => c.draggable = false);
                    setTimeout(() => {
                        phase1.style.display = "none";
                        phase2.style.display = "block";
                        cprTimer.style.display = "inline"; // NEW: Show the timer
                        initAudio();
                        // FIX: Removed 'playing = true;' so the START button works!
                    }, 2000);
                }

                let oxyLevel = 50;
                let playing = false;
                let lastBeatTime = 0;
                let timer = targetTime;
                let gameLoop, visualPulse;
                let cycleState = 'compressions';
                let compressCount = 0;
                let breathCount = 0;
                let breathInterval;
                let lungVolume = 0;
                let isLungFull = false;

                let audioCtx;
                let breatheGain, breatheOsc;

                function initAudio() {
                    if (!audioCtx) audioCtx = new (window.AudioContext || window.webkitAudioContext)();
                    if (audioCtx.state === 'suspended') audioCtx.resume();
                }

                function playTick() {
                    if (!audioCtx) return;
                    const osc = audioCtx.createOscillator();
                    const gain = audioCtx.createGain();
                    osc.type = 'sine';
                    osc.frequency.setValueAtTime(1000, audioCtx.currentTime);
                    gain.gain.setValueAtTime(0.15, audioCtx.currentTime);
                    gain.gain.exponentialRampToValueAtTime(0.001, audioCtx.currentTime + 0.05);
                    osc.connect(gain);
                    gain.connect(audioCtx.destination);
                    osc.start();
                    osc.stop(audioCtx.currentTime + 0.05);
                }

                function startBreatheSound() {
                    if (!audioCtx) return;
                    breatheOsc = audioCtx.createOscillator();
                    breatheGain = audioCtx.createGain();
                    breatheOsc.type = 'triangle';
                    breatheOsc.frequency.setValueAtTime(150, audioCtx.currentTime);
                    breatheGain.gain.setValueAtTime(0.01, audioCtx.currentTime);
                    breatheGain.gain.linearRampToValueAtTime(0.3, audioCtx.currentTime + 1.5);
                    breatheOsc.connect(breatheGain);
                    breatheGain.connect(audioCtx.destination);
                    breatheOsc.start();
                }

                function stopBreatheSound() {
                    if (breatheGain) {
                        breatheGain.gain.linearRampToValueAtTime(0.01, audioCtx.currentTime + 0.2);
                        setTimeout(() => { if (breatheOsc) breatheOsc.stop(); }, 200);
                    }
                }

                let oxyBar = document.getElementById('oxyBar');
                let actionIcon = document.getElementById('actionIcon');
                let status = document.getElementById('cprStatus');
                let btn = document.getElementById('btnAction');
                let btnRetry = document.getElementById('btnRetry');
                let timerDisp = document.getElementById('cprTimer');
                let valComp = document.getElementById('valCompressions');
                let valBreaths = document.getElementById('valBreaths');
                let statComp = document.getElementById('statCompressions');
                let statBreaths = document.getElementById('statBreaths');
                let breathContainer = document.getElementById('breathContainer');
                let breathBar = document.getElementById('breathBar');

                btnRetry.addEventListener('click', resetGame);

                function startGame() {
                    initAudio();
                    playing = true;
                    status.innerText = "Keep the rhythm!";
                    status.className = "mt-4 fs-5 fw-bold text-info";
                    btn.innerText = "COMPRESS";

                    visualPulse = setInterval(() => {
                        if (cycleState === 'compressions') {
                            playTick();
                            actionIcon.style.transform = "scale(1.2)";
                            setTimeout(() => actionIcon.style.transform = "scale(1)", 150);
                        }
                    }, msPerBeat);

                    gameLoop = setInterval(() => {
                        timer--;
                        timerDisp.innerText = `00:${timer < 10 ? '0' + timer : timer}`;
                        oxyLevel -= 10;
                        updateOxy();
                        if (timer <= 0) winGame();
                        else if (oxyLevel <= 0) loseGame();
                    }, 1000);
                }

                btn.addEventListener('mousedown', handlePointerDown);
                btn.addEventListener('touchstart', (e) => { e.preventDefault(); handlePointerDown(); });
                window.addEventListener('mouseup', handlePointerUp);
                window.addEventListener('touchend', handlePointerUp);

                function handlePointerDown() {
                    if (!playing) {
                        startGame();
                        lastBeatTime = Date.now();
                        applyBtnVfx();
                        return;
                    }
                    if (cycleState === 'compressions') {
                        applyBtnVfx();
                        doCompression();
                    } else if (cycleState === 'breaths') {
                        applyBtnVfx();
                        startBreath();
                    }
                }

                function handlePointerUp() {
                    btn.style.transform = "scale(1)";
                    btn.style.boxShadow = "0 0.5rem 1rem rgba(0, 0, 0, 0.15)";
                    if (cycleState === 'breaths') stopBreath();
                }

                function applyBtnVfx() {
                    if (cycleState === 'compressions') {
                        btn.style.transform = "scale(0.85)";
                        btn.style.boxShadow = "0 0 25px rgba(201, 36, 43, 0.8)";
                    } else {
                        btn.style.transform = "scale(1.1)";
                        btn.style.boxShadow = "0 0 35px rgba(13, 202, 240, 0.9)";
                    }
                }

                function doCompression() {
                    let now = Date.now();
                    let diff = now - lastBeatTime;
                    lastBeatTime = now;
                    actionIcon.style.transform = "scale(0.8)";
                    setTimeout(() => actionIcon.style.transform = "scale(1)", 100);

                    if (diff > (msPerBeat - 250) && diff < (msPerBeat + 250)) {
                        oxyLevel += 8;
                        status.innerText = "Perfect rhythm!";
                        status.className = "mt-4 fs-5 fw-bold text-success";
                    } else if (diff <= (msPerBeat - 250)) {
                        oxyLevel -= 5;
                        status.innerText = "Too Fast!";
                        status.className = "mt-4 fs-5 fw-bold text-danger";
                    } else {
                        oxyLevel += 2;
                        status.innerText = "Too Slow!";
                        status.className = "mt-4 fs-5 fw-bold text-warning";
                    }

                    updateOxy();
                    compressCount++;
                    valComp.innerText = compressCount;
                    if (compressCount >= 30) switchToBreaths();
                }

                function startBreath() {
                    if (breathCount >= 2 || isLungFull) return;
                    startBreatheSound();
                    actionIcon.style.transform = "scale(1.2)";
                    status.innerText = "Breathe in...";
                    status.className = "mt-4 fs-5 fw-bold text-info";

                    clearInterval(breathInterval);
                    breathInterval = setInterval(() => {
                        lungVolume += 5;
                        breathBar.style.width = lungVolume + "%";
                        if (lungVolume >= 100) {
                            lungVolume = 100;
                            clearInterval(breathInterval);
                            stopBreatheSound();
                            isLungFull = true;
                            status.innerText = "Lungs full! Release to exhale.";
                            status.className = "mt-4 fs-5 fw-bold text-success";
                        }
                    }, 50);
                }

                function stopBreath() {
                    stopBreatheSound();
                    clearInterval(breathInterval);
                    if (isLungFull) {
                        isLungFull = false;
                        lungVolume = 0;
                        breathBar.style.width = "0%";
                        breathCount++;
                        valBreaths.innerText = breathCount;
                        oxyLevel += 20;
                        updateOxy();

                        if (breathCount >= 2) {
                            status.innerText = "2 Breaths given! Back to compressions!";
                            status.className = "mt-4 fs-5 fw-bold text-success";
                            setTimeout(switchToCompressions, 1000);
                        } else {
                            status.innerText = "Good breath! Give one more.";
                        }
                    } else if (lungVolume > 0 && lungVolume < 100) {
                        lungVolume = 0;
                        breathBar.style.width = "0%";
                        status.innerText = "Hold longer to give a full breath!";
                        status.className = "mt-4 fs-5 fw-bold text-danger";
                    }
                    actionIcon.style.transform = "scale(1)";
                }

                function switchToBreaths() {
                    cycleState = 'breaths';
                    btn.innerText = "HOLD TO BREATHE";
                    btn.style.borderColor = "#0dcaf0";
                    btn.classList.replace('text-danger', 'text-info');
                    actionIcon.innerHTML = '<i class="fa-solid fa-lungs"></i>';
                    actionIcon.classList.replace('text-danger', 'text-info');
                    statComp.classList.add('opacity-50');
                    statBreaths.classList.remove('opacity-50');
                    breathContainer.style.display = "flex";
                    status.innerText = "30 Compressions done! Give 2 Breaths.";
                    status.className = "mt-4 fs-5 fw-bold text-warning";
                }

                function switchToCompressions() {
                    cycleState = 'compressions';
                    compressCount = 0;
                    breathCount = 0;
                    valComp.innerText = "0";
                    valBreaths.innerText = "0";
                    btn.innerText = "COMPRESS";
                    btn.style.borderColor = "#c9242b";
                    btn.classList.replace('text-info', 'text-danger');
                    actionIcon.innerHTML = '<i class="fa-solid fa-heart"></i>';
                    actionIcon.classList.replace('text-info', 'text-danger');
                    statComp.classList.remove('opacity-50');
                    statBreaths.classList.add('opacity-50');
                    breathContainer.style.display = "none";
                    lastBeatTime = Date.now();
                }

                function updateOxy() {
                    if (oxyLevel > 100) oxyLevel = 100;
                    oxyBar.style.width = oxyLevel + "%";
                    if (oxyLevel > 60) oxyBar.className = "progress-bar bg-success";
                    else if (oxyLevel > 30) oxyBar.className = "progress-bar bg-warning";
                    else oxyBar.className = "progress-bar bg-danger";
                }

                function winGame() {
                    clearInterval(gameLoop);
                    clearInterval(visualPulse);
                    btn.disabled = true;
                    btn.style.pointerEvents = "none";
                    status.innerText = "Patient Stabilized! You Win!";
                    status.className = "mt-4 fs-3 fw-bold text-success";
                    btnRetry.style.display = "inline-block";
                }

                function loseGame() {
                    clearInterval(gameLoop);
                    clearInterval(visualPulse);
                    btn.disabled = true;
                    btn.style.pointerEvents = "none";
                    oxyBar.style.width = "0%";
                    status.innerText = "Oxygen depleted. Patient lost.";
                    status.className = "mt-4 fs-5 fw-bold text-danger";
                    btnRetry.style.display = "inline-block";
                }

                function resetGame() {
                    // FIX: Reset variables properly
                    oxyLevel = 50;
                    playing = false;
                    timer = targetTime;
                    cycleState = 'compressions';
                    compressCount = 0;
                    breathCount = 0;
                    lungVolume = 0;
                    isLungFull = false;

                    clearInterval(gameLoop);
                    clearInterval(visualPulse);
                    clearInterval(breathInterval);
                    stopBreatheSound();

                    // Restore Phase 2 UI
                    timerDisp.innerText = `00:${timer < 10 ? '0' + timer : timer}`;
                    valComp.innerText = "0";
                    valBreaths.innerText = "0";
                    btn.innerText = "START";
                    btn.disabled = false;
                    btn.style.pointerEvents = "auto";
                    btn.style.borderColor = "#c9242b";
                    btn.classList.replace('text-info', 'text-danger');
                    btn.style.transform = "scale(1)";
                    actionIcon.innerHTML = '<i class="fa-solid fa-heart"></i>';
                    actionIcon.classList.replace('text-info', 'text-danger');
                    actionIcon.style.transform = "scale(1)";
                    statComp.classList.remove('opacity-50');
                    statBreaths.classList.add('opacity-50');
                    breathContainer.style.display = "none";
                    breathBar.style.width = "0%";
                    status.innerText = "Click START to begin";
                    status.className = "mt-4 fs-5 fw-bold text-muted";
                    btnRetry.style.display = "none";
                    updateOxy();

                    // Restore Phase 1 UI
                    phase2.style.display = "none";
                    phase1.style.display = "block";
                    cprTimer.style.display = "none"; // FIX: Hide timer again
                    currentBottomCardID = null;
                    phase1Status.innerText = "";
                    phase1Status.className = "mt-4 fs-6 fw-bold text-danger text-center px-3";
                    correctResult.style.display = "none";

                    // Send cards back
                    handStage.querySelectorAll('.drag-hand-card').forEach(card => {
                        card.style.position = "static";
                        card.style.transform = "none";
                        card.style.width = "auto";
                        card.style.height = "85px";
                        card.style.zIndex = "1";
                        card.draggable = true;
                        card.classList.replace('border-danger', 'border-secondary');
                        card.classList.replace('border-success', 'border-secondary');

                        if (card.dataset.text.startsWith('bot')) bottomBank.appendChild(card);
                        else topBank.appendChild(card);
                    });
                }
            }

            function bootSequenceGame(config) {
                let container = document.getElementById('simulationContainer');
                let correctSequence = config.items || [];

                // Shuffle the array for the bank
                let shuffledItems = [...correctSequence].sort(() => Math.random() - 0.5);

                // 1. Draw the Red-Themed UI with Scenario
                container.innerHTML = `
                    <div class="card bg-white rounded-4 shadow-sm border-2 border-danger overflow-hidden">
                        <div class="card-header bg-danger text-white text-center py-3 fw-bold fs-5">
                            <i class="fa-solid fa-layer-group me-2"></i> Sequence Check: Emergency Response
                        </div>
                        <div class="card-body p-4 p-md-5 bg-light">
                            
                            <div class="alert alert-danger bg-opacity-10 border-danger mb-4 shadow-sm">
                                <h5 class="alert-heading fw-bold text-danger mb-2"><i class="fa-solid fa-truck-medical me-2"></i> Scenario</h5>
                                <p class="mb-0 text-dark">You arrive at the scene and find a person collapsed on the ground. They appear unresponsive. Drag and drop the first aid steps below into the exact chronological order to save them!</p>
                            </div>

                            <div class="row g-4">
                                <div class="col-md-6">
                                    <h6 class="fw-bold text-secondary mb-3 border-bottom pb-2">Step Bank (Drag or Tap)</h6>
                                    <div id="itemBank" class="d-flex flex-wrap gap-2 p-3 border border-2 border-dashed border-secondary rounded bg-white min-vh-50"></div>
                                </div>
                                
                                <div class="col-md-6">
                                    <h6 class="fw-bold text-secondary mb-3 border-bottom pb-2">Correct Order</h6>
                                    <div id="dropZone" class="d-flex flex-column gap-2"></div>
                                </div>
                            </div>
                            
                            <div class="text-center mt-5">
                                <button type="button" id="btnCheckSequence" class="btn btn-warning fw-bold px-5 py-2 fs-5 rounded-pill shadow-sm">
                                    <i class="fa-solid fa-clipboard-check me-2"></i> Check Answer
                                </button>
                                <div id="seqStatus" class="mt-3 fs-5 fw-bold text-center"></div>
                            </div>
                        </div>
                    </div>
                `;

                let bank = document.getElementById('itemBank');
                let dropZone = document.getElementById('dropZone');
                let btnCheck = document.getElementById('btnCheckSequence');
                let status = document.getElementById('seqStatus');

                let selectedElement = null;

                // 2. Generate Draggable Cards
                shuffledItems.forEach((text, index) => {
                    let card = document.createElement('div');
                    card.className = "drag-card p-2 bg-white border border-2 border-secondary rounded shadow-sm fw-bold text-center user-select-none";
                    card.style.cursor = "grab";
                    card.style.flex = "1 1 calc(50% - 1rem)";
                    card.innerText = text;
                    card.dataset.text = text;

                    // Enable HTML5 Drag
                    card.draggable = true;
                    card.addEventListener('dragstart', dragStart);
                    card.addEventListener('dragend', dragEnd);

                    // Enable Mobile Click-to-Move
                    card.onclick = () => handleCardClick(card);

                    bank.appendChild(card);
                });

                // 3. Generate Drop Slots
                correctSequence.forEach((_, index) => {
                    let slot = document.createElement('div');
                    slot.className = "drop-slot p-2 border border-2 border-dashed border-danger rounded bg-white text-muted d-flex align-items-center";
                    slot.style.minHeight = "60px";
                    slot.style.transition = "all 0.2s";
                    slot.innerHTML = `<span class="badge bg-danger me-3 fs-6">${index + 1}</span> <span class="slot-text">Drop or Tap here</span>`;

                    // Enable HTML5 Drop
                    slot.addEventListener('dragover', allowDrop);
                    slot.addEventListener('dragenter', dragEnter);
                    slot.addEventListener('dragleave', dragLeave);
                    slot.addEventListener('drop', dropTarget);

                    // Enable Mobile Click-to-Place
                    slot.onclick = () => handleSlotClick(slot);

                    dropZone.appendChild(slot);
                });

                // ENGINE A: HTML5 MOUSE DRAG AND DROP
                let draggedCard = null;

                function dragStart(e) {
                    draggedCard = this;
                    setTimeout(() => this.style.opacity = '0.5', 0);
                    e.dataTransfer.effectAllowed = 'move';
                    e.dataTransfer.setData('text/plain', this.dataset.text);
                }

                function dragEnd() {
                    this.style.opacity = '1';
                    draggedCard = null;
                    document.querySelectorAll('.drop-slot').forEach(s => s.classList.remove('bg-danger', 'bg-opacity-10'));
                    checkSlots();
                }

                function allowDrop(e) { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; }

                function dragEnter(e) {
                    e.preventDefault();
                    if (this.classList.contains('drop-slot')) this.classList.add('bg-danger', 'bg-opacity-10');
                }

                function dragLeave() {
                    if (this.classList.contains('drop-slot')) this.classList.remove('bg-danger', 'bg-opacity-10');
                }

                function dropTarget(e) {
                    e.preventDefault();
                    this.classList.remove('bg-danger', 'bg-opacity-10');
                    if (draggedCard) {
                        // If slot already has a card, bump it back to the bank first
                        let existingCard = this.querySelector('.drag-card');
                        if (existingCard) bank.appendChild(existingCard);

                        this.appendChild(draggedCard);
                        checkSlots();
                    }
                }

                // Allow dropping items back into the bank area!
                bank.addEventListener('dragover', allowDrop);
                bank.addEventListener('drop', function (e) {
                    e.preventDefault();
                    if (draggedCard) {
                        this.appendChild(draggedCard);
                        checkSlots();
                    }
                });

                // ENGINE B: MOBILE CLICK-TO-MOVE (BUG FIXED)
                function handleCardClick(card) {
                    // BUG FIX: Check if it's inside a slot using .closest()
                    if (card.closest('.drop-slot')) {
                        bank.appendChild(card); // Send back to bank
                        checkSlots();
                        return;
                    }

                    // Deselect previous
                    if (selectedElement) selectedElement.classList.remove('border-warning', 'bg-warning', 'text-dark');

                    if (selectedElement === card) {
                        selectedElement = null; // Tapped again, deselect
                    } else {
                        // Select new
                        selectedElement = card;
                        selectedElement.classList.add('border-warning', 'bg-warning', 'text-dark');
                    }
                }

                function handleSlotClick(slot) {
                    if (!selectedElement) return;

                    // Swap out existing card
                    let existingCard = slot.querySelector('.drag-card');
                    if (existingCard) bank.appendChild(existingCard);

                    // Move selected item into the slot
                    selectedElement.classList.remove('border-warning', 'bg-warning', 'text-dark');
                    slot.appendChild(selectedElement);
                    selectedElement = null;
                    checkSlots();
                }

                function checkSlots() {
                    // Clean up sizing when moving between bank and slots
                    document.querySelectorAll('.drag-card').forEach(card => {
                        if (card.closest('.drop-slot')) {
                            card.style.flex = "1";
                            card.style.margin = "0";
                            card.classList.replace('border-secondary', 'border-danger');
                        } else {
                            card.style.flex = "1 1 calc(50% - 1rem)";
                            card.classList.replace('border-danger', 'border-secondary');
                        }
                    });

                    // Hide/Show placeholder text
                    document.querySelectorAll('.drop-slot').forEach(slot => {
                        let textNode = slot.querySelector('.slot-text');
                        textNode.style.display = slot.querySelector('.drag-card') ? 'none' : 'inline';
                    });
                }

                // VERIFICATION LOGIC
                btnCheck.onclick = function () {
                    let currentAnswers = [];
                    let allFilled = true;

                    document.querySelectorAll('.drop-slot').forEach(slot => {
                        let card = slot.querySelector('.drag-card');
                        if (card) currentAnswers.push(card.dataset.text);
                        else allFilled = false;
                    });

                    if (!allFilled) {
                        status.innerHTML = "<i class='fa-solid fa-triangle-exclamation'></i> Please fill all the slots first!";
                        status.className = "mt-3 fs-5 fw-bold text-danger text-center";
                        return;
                    }

                    let isCorrect = true;
                    for (let i = 0; i < correctSequence.length; i++) {
                        if (currentAnswers[i] !== correctSequence[i]) {
                            isCorrect = false;
                            break;
                        }
                    }

                    if (isCorrect) {
                        status.innerHTML = "<i class='fa-solid fa-check-circle'></i> Perfect! You executed the correct chronological response.";
                        status.className = "mt-3 fs-5 fw-bold text-success text-center";
                        btnCheck.disabled = true;
                    } else {
                        // Added more narrative feedback
                        status.innerHTML = "<i class='fa-solid fa-skull-crossbones'></i> Incorrect sequence! A mistake here could cost a life. Move the cards and try again.";
                        status.className = "mt-3 fs-5 fw-bold text-danger text-center";
                    }
                };
            }

            function bootChokingGame(config) {
                let container = document.getElementById('simulationContainer');
                let targetTime = parseInt(config.targetTime) || 30;
                let targetCycles = parseInt(config.cycles) || 2;

                // 1. Draw the UI
                // 1. Draw the UI
                container.innerHTML = `
                    <div class="card bg-white text-dark rounded-4 shadow-lg border-2 border-warning overflow-hidden">
                        <div class="card-header bg-warning text-dark text-center py-3 fw-bold fs-5 d-flex justify-content-between px-4">
                            <span><i class="fa-solid fa-lungs-virus me-2"></i> Choking Emergency</span>
                            <span id="chkTimer" style="display: none;">00:${targetTime < 10 ? '0' + targetTime : targetTime}</span>
                        </div>
                        
                        <div id="phase1" class="card-body text-center p-4">
                            <h5 class="mb-4 text-warning fw-bold text-uppercase">Phase 1: Hand Placement</h5>
                            
                            <div class="alert alert-light border-secondary border-start border-4 mb-4 shadow-sm text-start">
                                <h6 class="fw-bold text-dark mb-2">Build the correct Abdominal Thrust grip. Drag the base hand to the abdomen (above navel), then drag the securing hand over it.</h6>
                            </div>
                            
                            <div class="row g-4 justify-content-center">
                                <div class="col-md-5 d-flex flex-column gap-4">
                                    <div>
                                        <h6 class="fw-bold text-muted border-bottom pb-2 text-uppercase small">1. Base Hand</h6>
                                        <div id="bottomHandBank" class="d-flex flex-wrap gap-2 p-2 border border-2 border-dashed border-secondary rounded bg-light min-vh-25"></div>
                                    </div>
                                    <div>
                                        <h6 class="fw-bold text-muted border-bottom pb-2 text-uppercase small">2. Securing Hand</h6>
                                        <div id="topHandBank" class="d-flex flex-wrap gap-2 p-2 border border-2 border-dashed border-secondary rounded bg-light min-vh-25"></div>
                                    </div>
                                </div>
                                
                                <div class="col-md-7">
                                    <h6 class="fw-bold text-muted mb-3 border-bottom pb-2 text-uppercase small">The Patient's Torso</h6>
                                    
                                    <div id="handStage" class="d-flex align-items-center justify-content-center border border-2 border-warning rounded mx-auto shadow-inner position-relative" 
                                         style="width: 100%; max-width: 320px; height: 350px; background-color: #fadcc4;">
                                        
                                        <div class="position-absolute d-flex flex-column align-items-center" style="top: 20%; pointer-events: none; color: #a37252; opacity: 0.8;">
                                            <i class="fa-solid fa-xmark fs-3 mb-1"></i><span class="small fw-bold">Chest</span>
                                        </div>
                                        
                                        <div class="position-absolute text-danger opacity-75 d-flex flex-column align-items-center" style="top: 60%; pointer-events: none;">
                                            <i class="fa-solid fa-crosshairs fs-2 mb-1"></i><span class="fw-bold">Above Navel</span>
                                        </div>

                                        <div id="correctInterlockResult" class="card bg-success text-white fw-bold p-3 rounded-4 position-absolute top-50 start-50 translate-middle shadow-lg" 
                                             style="display: none; z-index: 10; width: 85%;">
                                            <i class="fa-solid fa-check-circle fs-2 mb-2"></i><br>Grip Secured!<br>Ready for inward & upward "J" thrusts.
                                        </div>
                                    </div>
                                    <div id="phase1Status" class="mt-4 fs-6 fw-bold text-danger text-center px-3" style="min-height: 40px;"></div>
                                </div>
                            </div>
                        </div>

                        <div id="phase2" class="card-body text-center p-4" style="display: none;">
                            <h5 class="mb-3 text-dark">Clear Airway: <strong class="text-danger">5 Back Blows</strong> then <strong class="text-warning">5 Thrusts</strong></h5>
                            
                            <div class="d-flex justify-content-center align-items-center gap-5 mb-4 bg-light py-4 rounded-4 border shadow-sm" style="min-height: 220px;">
                                
                                <div id="viewBack" class="position-relative text-center" style="width: 130px;">
                                    <h6 class="text-danger fw-bold mb-2 small text-uppercase">Patient (Back)</h6>
                                    <i class="fa-solid fa-person" style="font-size: 140px; line-height: 1; color: #e9c1ab;"></i>
                                    <div id="vfxBack" class="position-absolute bg-danger rounded-circle" style="width: 50px; height: 50px; top: 40px; left: 50%; transform: translateX(-50%); opacity: 0; transition: opacity 0.2s; filter: blur(3px);"></div>
                                </div>

                                <div id="viewFront" class="position-relative text-center" style="width: 130px; display: none;">
                                    <h6 class="text-warning fw-bold mb-2 small text-uppercase">Patient (Front)</h6>
                                    <i class="fa-solid fa-person" style="font-size: 140px; line-height: 1; color: #e9c1ab;"></i>
                                    <div id="vfxAbdomen" class="position-absolute bg-warning rounded-circle" style="width: 50px; height: 50px; top: 85px; left: 50%; transform: translateX(-50%); opacity: 0; transition: opacity 0.2s; filter: blur(3px);"></div>
                                </div>

                                <div class="d-flex flex-column align-items-center">
                                    <h6 class="text-muted fw-bold mb-2 small text-uppercase">Airway</h6>
                                    <div class="border border-4 border-dark rounded-pill position-relative bg-white shadow-inner" style="width: 45px; height: 140px; overflow: hidden;">
                                        <div id="blockageItem" class="bg-danger rounded-circle shadow-sm" style="width: 33px; height: 33px; position: absolute; bottom: 10%; left: 50%; transform: translateX(-50%); transition: bottom 0.2s ease-out;"></div>
                                    </div>
                                </div>

                            </div>

                            <h6 class="text-muted fw-bold mb-3">Cycles Cleared: <span id="valCycles" class="text-success fs-5">0</span> / ${targetCycles}</h6>

                            <div class="row g-3 justify-content-center mb-4">
                                <div class="col-6 col-sm-5">
                                    <div class="card border-3 border-danger h-100 shadow-sm" id="cardBackBlow">
                                        <div class="card-body py-2">
                                            <h6 class="fw-bold text-danger m-0">BACK BLOWS</h6>
                                            <div class="fs-2 fw-bold text-dark"><span id="valBB">0</span><span class="text-muted fs-5">/5</span></div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-6 col-sm-5">
                                    <div class="card border-3 border-secondary opacity-50 h-100 shadow-sm" id="cardThrust">
                                        <div class="card-body py-2">
                                            <h6 class="fw-bold text-warning m-0">THRUSTS</h6>
                                            <div class="fs-2 fw-bold text-dark"><span id="valThrust">0</span><span class="text-muted fs-5">/5</span></div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="row justify-content-center">
                                <div class="col-6 text-center">
                                    <button type="button" id="btnBB" class="btn btn-danger text-white fw-bold rounded shadow py-3 w-100" style="font-size: 1.1rem; touch-action: none; transition: transform 0.1s;">
                                        STRIKE BACK<br><small class="fw-normal">(Tap)</small>
                                    </button>
                                </div>
                                <div class="col-6 text-center position-relative">
                                    <div id="powerContainer" class="progress position-absolute w-100 shadow-sm border border-secondary" style="height: 12px; top: -18px; left: 0; display: none; background-color: #333;">
                                        <div id="powerBar" class="progress-bar bg-warning" style="width: 0%; transition: none !important;"></div>
                                    </div>
                                    <button type="button" id="btnThrust" class="btn btn-warning text-dark fw-bold rounded shadow py-3 w-100" style="font-size: 1.1rem; touch-action: none; transition: transform 0.1s;">
                                        "J" THRUST<br><small class="fw-normal">(Hold & Release)</small>
                                    </button>
                                </div>
                            </div>
                            
                            <div id="chkStatus" class="mt-4 fs-5 fw-bold text-danger" style="min-height: 30px;">Commence 5 Back Blows!</div>
                            
                            <button type="button" id="btnRetry" class="btn btn-danger text-white rounded-pill mt-3 px-4 py-2 fw-bold shadow-sm" style="display: none;">
                                <i class="fa-solid fa-rotate-right me-1"></i> Try Again
                            </button>
                        </div>
                    </div>
                `;

                // ==========================================
                // PHASE 1 LOGIC (Remains the same as before)
                // ==========================================
                let phase1 = document.getElementById('phase1');
                let phase2 = document.getElementById('phase2');
                let bottomBank = document.getElementById('bottomHandBank');
                let topBank = document.getElementById('topHandBank');
                let handStage = document.getElementById('handStage');
                let phase1Status = document.getElementById('phase1Status');
                let correctResult = document.getElementById('correctInterlockResult');
                let chkTimer = document.getElementById('chkTimer');

                let currentBottomCardID = null;
                let selectedElement = null;

                const handVisuals = {
                    bot_correct: { id: 'bot_correct', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand-fist fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Fist<br>(Thumb Side)</span></div>' },
                    bot_wrong1: { id: 'bot_wrong1', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Flat Hand</span></div>' },
                    bot_wrong2: { id: 'bot_wrong2', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand-pointer fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Two Fingers</span></div>' },
                    top_correct: { id: 'top_correct', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hands-holding fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Grip Fist</span></div>' },
                    top_wrong1: { id: 'top_wrong1', html: '<div class="d-flex flex-column align-items-center justify-content-center h-100"><i class="fa-solid fa-hand fs-2 text-dark mb-1"></i><span class="small lh-sm fw-bold">Flat Hand</span></div>' }
                };

                Object.values(handVisuals).forEach(h => {
                    let card = document.createElement('div');
                    card.className = "drag-hand-card p-1 bg-white border border-2 border-secondary rounded shadow-sm text-center user-select-none";
                    card.style.cursor = "grab";
                    card.style.flex = "1 1 calc(50% - 0.5rem)";
                    card.style.height = "85px";
                    card.innerHTML = h.html;
                    card.dataset.text = h.id;

                    card.draggable = true;
                    card.addEventListener('dragstart', function (e) {
                        selectedElement = this;
                        this.style.opacity = '0.5';
                        e.dataTransfer.effectAllowed = 'move';
                        e.dataTransfer.setData('text/plain', this.dataset.text);
                    });
                    card.addEventListener('dragend', function () { this.style.opacity = '1'; selectedElement = null; });
                    card.onclick = () => handleCardClick(card);

                    if (h.id.startsWith('bot')) bottomBank.appendChild(card);
                    else topBank.appendChild(card);
                });

                handStage.addEventListener('dragover', e => { e.preventDefault(); e.dataTransfer.dropEffect = 'move'; });
                handStage.addEventListener('drop', function (e) {
                    e.preventDefault();
                    if (selectedElement) placeHandOnStage(selectedElement, e.dataTransfer.getData('text/plain'));
                });

                function handleCardClick(card) {
                    if (card.parentElement === handStage) {
                        card.style.position = "static";
                        card.style.transform = "none";
                        card.style.width = "auto";
                        card.style.height = "85px";
                        card.style.zIndex = "1";
                        card.classList.remove('border-danger', 'border-warning', 'border-success', 'border-primary');
                        card.classList.add('border-secondary');

                        if (card.dataset.text.startsWith('bot')) {
                            bottomBank.appendChild(card);
                            currentBottomCardID = null;
                        } else topBank.appendChild(card);

                        phase1Status.innerText = "";
                        return;
                    }
                    placeHandOnStage(card, card.dataset.text);
                }

                function placeHandOnStage(card, textId) {
                    if (!currentBottomCardID) {
                        if (textId.startsWith('bot')) {
                            currentBottomCardID = textId;
                            handStage.appendChild(card);
                            applyPlacementVfx(card, 'bot');
                            phase1Status.innerText = "";
                        } else phase1Status.innerText = "Place the base fist on the abdomen first!";
                    } else {
                        if (textId.startsWith('top')) {
                            handStage.appendChild(card);
                            if (currentBottomCardID === 'bot_correct' && textId === 'top_correct') {
                                applyPlacementVfx(card, 'top_correct');
                                phase1Status.className = "mt-4 fs-6 fw-bold text-success text-center px-3";
                                phase1Status.innerText = "Grip Secured! Transitioning...";
                                transitionToPhase2();
                            } else {
                                applyPlacementVfx(card, 'top_wrong');
                                phase1Status.innerText = "Incorrect grip. You need a fist (thumb side in) covered firmly by the other hand.";
                            }
                        } else phase1Status.innerText = "Base hand is already set. Choose a securing hand.";
                    }
                }

                function applyPlacementVfx(card, type) {
                    card.style.position = "absolute";
                    card.style.width = "140px";
                    card.style.height = "100px";
                    card.style.left = "50%";
                    card.style.transform = "translateX(-50%)";

                    if (type === 'bot') {
                        card.style.top = "55%";
                        card.style.zIndex = "2";
                        card.classList.replace('border-secondary', 'border-warning');
                    } else if (type === 'top_correct') {
                        card.style.top = "55%";
                        card.style.zIndex = "3";
                        card.classList.replace('border-secondary', 'border-success');
                        correctResult.style.display = "block";
                    } else if (type === 'top_wrong') {
                        card.style.top = "55%";
                        card.style.zIndex = "3";
                        card.classList.replace('border-secondary', 'border-danger');
                    }
                }

                function transitionToPhase2() {
                    document.querySelectorAll('.drag-hand-card').forEach(c => c.draggable = false);
                    setTimeout(() => {
                        phase1.style.display = "none";
                        phase2.style.display = "block";
                        chkTimer.style.display = "inline";
                        startPhase2Timer();
                    }, 2000);
                }

                // ==========================================
                // PHASE 2 LOGIC: PHYSICS & POWER ENGINE
                // ==========================================
                let timer = targetTime;
                let gameLoop;
                let activeAction = 'bb';
                let bbCount = 0;
                let thrustCount = 0;
                let cyclesCompleted = 0;

                // Physics Variables
                let currentBlockagePos = 10; // Start at 10%
                let maxBlockagePos = 90;     // Shoots out at 90%
                let totalDistance = maxBlockagePos - currentBlockagePos;

                // Calculate how much it moves per action to perfectly reach 90% exactly when cycles are done
                let totalBBsNeeded = targetCycles * 5;
                let totalThrustsNeeded = targetCycles * 5;

                // Let's say Thrusts do 75% of the work, BBs do 25% of the work.
                let bbStepSize = (totalDistance * 0.25) / totalBBsNeeded;
                let thrustStepSize = (totalDistance * 0.75) / totalThrustsNeeded;

                // Power Variables
                let isCharging = false;
                let powerLevel = 0;
                let chargeInterval;

                let btnBB = document.getElementById('btnBB');
                let btnThrust = document.getElementById('btnThrust');
                let powerContainer = document.getElementById('powerContainer');
                let powerBar = document.getElementById('powerBar');

                let valBB = document.getElementById('valBB');
                let valThrust = document.getElementById('valThrust');
                let valCycles = document.getElementById('valCycles');
                let cardBB = document.getElementById('cardBackBlow');
                let cardThrust = document.getElementById('cardThrust');
                let chkStatus = document.getElementById('chkStatus');
                let blockageItem = document.getElementById('blockageItem');

                let viewBack = document.getElementById('viewBack');
                let viewFront = document.getElementById('viewFront');
                let vfxBack = document.getElementById('vfxBack');
                let vfxAbdomen = document.getElementById('vfxAbdomen');

                let btnRetry = document.getElementById('btnRetry');
                let timerDisp = document.getElementById('chkTimer');

                btnRetry.addEventListener('click', resetGame);

                function startPhase2Timer() {
                    gameLoop = setInterval(() => {
                        timer--;
                        timerDisp.innerText = `00:${timer < 10 ? '0' + timer : timer}`;
                        if (timer <= 0) loseGame("Time ran out! The patient lost consciousness.");
                    }, 1000);
                }

                // --- ACTION 1: BACK BLOW (CLICK) ---
                btnBB.addEventListener('mousedown', (e) => { e.preventDefault(); processBackBlow(); });
                btnBB.addEventListener('touchstart', (e) => { e.preventDefault(); processBackBlow(); });

                function processBackBlow() {
                    if (timer <= 0 || cyclesCompleted >= targetCycles) return;

                    btnBB.style.transform = "scale(0.9)";
                    setTimeout(() => btnBB.style.transform = "scale(1)", 100);

                    if (activeAction !== 'bb') {
                        penaltyBreak("Wrong action! You must finish the thrusts first.");
                        return;
                    }

                    // Visual feedback
                    vfxBack.style.opacity = "0.8";
                    setTimeout(() => vfxBack.style.opacity = "0", 200);

                    // Move Blockage Slightly!
                    currentBlockagePos += bbStepSize;
                    blockageItem.style.bottom = currentBlockagePos + "%";

                    bbCount++;
                    valBB.innerText = bbCount;
                    chkStatus.innerText = `Good strike! (${bbCount}/5)`;
                    chkStatus.className = "mt-4 fs-5 fw-bold text-danger";

                    if (bbCount === 5) {
                        activeAction = 'thrust';
                        switchUI('thrust');
                    }
                }

                // --- ACTION 2: ABDOMINAL THRUST (HOLD FOR POWER) ---
                btnThrust.addEventListener('mousedown', (e) => { e.preventDefault(); startCharge(); });
                btnThrust.addEventListener('touchstart', (e) => { e.preventDefault(); startCharge(); });

                // Use global mouseup to catch releases that drag off the button
                window.addEventListener('mouseup', releaseThrust);
                window.addEventListener('touchend', releaseThrust);

                function startCharge() {
                    if (timer <= 0 || cyclesCompleted >= targetCycles) return;

                    if (activeAction !== 'thrust') {
                        btnThrust.style.transform = "scale(0.9)";
                        setTimeout(() => btnThrust.style.transform = "scale(1)", 100);
                        penaltyBreak("Wrong action! You must do 5 Back Blows first.");
                        return;
                    }

                    isCharging = true;
                    powerLevel = 0;
                    powerContainer.style.display = "flex";
                    btnThrust.style.transform = "scale(0.95)";

                    chargeInterval = setInterval(() => {
                        powerLevel += 5; 
                        if (powerLevel > 100) powerLevel = 100;
                        powerBar.style.width = powerLevel + "%";

                        if (powerLevel >= 75) powerBar.className = "progress-bar bg-success";
                        else powerBar.className = "progress-bar bg-warning";
                    }, 30); 
                }

                function releaseThrust() {
                    if (!isCharging) return;
                    isCharging = false;
                    clearInterval(chargeInterval);
                    btnThrust.style.transform = "scale(1)";
                    powerContainer.style.display = "none";

                    // Evaluate Power!
                    if (powerLevel >= 75) {
                        // STRONG THRUST!
                        vfxAbdomen.style.opacity = "0.9";
                        setTimeout(() => vfxAbdomen.style.opacity = "0", 200);

                        // Move Blockage a lot!
                        currentBlockagePos += thrustStepSize;
                        blockageItem.style.bottom = currentBlockagePos + "%";

                        thrustCount++;
                        valThrust.innerText = thrustCount;
                        chkStatus.innerText = `Strong "J" Thrust! (${thrustCount}/5)`;
                        chkStatus.className = "mt-4 fs-5 fw-bold text-success";

                        if (thrustCount === 5) {
                            cyclesCompleted++;
                            valCycles.innerText = cyclesCompleted;

                            if (cyclesCompleted >= targetCycles) {
                                // Final push out of the throat
                                blockageItem.style.bottom = "120%";
                                winGame();
                            } else {
                                activeAction = 'bb';
                                bbCount = 0;
                                thrustCount = 0;
                                valBB.innerText = "0";
                                valThrust.innerText = "0";
                                switchUI('bb');
                                chkStatus.innerText = "Cycle complete! Immediately return to Back Blows.";
                                chkStatus.className = "mt-4 fs-5 fw-bold text-primary";
                            }
                        }
                    } else {
                        // WEAK THRUST (Does not count, wastes time)
                        vfxAbdomen.style.opacity = "0.3"; // Weak flash
                        setTimeout(() => vfxAbdomen.style.opacity = "0", 200);

                        // Jiggle but drop back
                        let tempPos = currentBlockagePos + 2;
                        blockageItem.style.bottom = tempPos + "%";
                        setTimeout(() => { if (cyclesCompleted < targetCycles) blockageItem.style.bottom = currentBlockagePos + "%"; }, 200);

                        chkStatus.innerHTML = `<i class="fa-solid fa-arrow-down"></i> Weak thrust! Hold longer for more power!`;
                        chkStatus.className = "mt-4 fs-5 fw-bold text-warning";
                    }
                    powerLevel = 0;
                    powerBar.style.width = "0%";
                }

                function penaltyBreak(msg) {
                    bbCount = 0;
                    thrustCount = 0;
                    valBB.innerText = "0";
                    valThrust.innerText = "0";
                    activeAction = 'bb';
                    switchUI('bb');

                    timer -= 3;
                    if (timer < 0) timer = 0;
                    timerDisp.innerText = `00:${timer < 10 ? '0' + timer : timer}`;
                    timerDisp.classList.add('text-danger');
                    setTimeout(() => timerDisp.classList.remove('text-danger'), 500);

                    chkStatus.innerHTML = `<i class="fa-solid fa-triangle-exclamation"></i> ${msg} Time penalty! Start cycle over.`;
                    chkStatus.className = "mt-4 fs-5 fw-bold text-danger";
                }

                function switchUI(toPhase) {
                    if (toPhase === 'bb') {
                        cardBB.classList.remove('border-secondary', 'opacity-50');
                        cardBB.classList.add('border-danger');
                        cardThrust.classList.remove('border-warning');
                        cardThrust.classList.add('border-secondary', 'opacity-50');

                        viewBack.style.display = "block";
                        viewFront.style.display = "none";
                    } else {
                        cardThrust.classList.remove('border-secondary', 'opacity-50');
                        cardThrust.classList.add('border-warning');
                        cardBB.classList.remove('border-danger');
                        cardBB.classList.add('border-secondary', 'opacity-50');

                        viewBack.style.display = "none";
                        viewFront.style.display = "block";

                        chkStatus.innerText = "Switch to 5 Abdominal Thrusts! (Hold for Power)";
                        chkStatus.className = "mt-4 fs-5 fw-bold text-warning";
                    }
                }

                function winGame() {
                    clearInterval(gameLoop);
                    chkStatus.innerText = "Item dislodged! You saved their life!";
                    chkStatus.className = "mt-4 fs-3 fw-bold text-success";
                    btnRetry.style.display = "inline-block";
                }

                function loseGame(msg) {
                    clearInterval(gameLoop);
                    chkStatus.innerText = msg;
                    chkStatus.className = "mt-4 fs-4 fw-bold text-danger";
                    btnRetry.style.display = "inline-block";
                }

                function resetGame() {
                    clearInterval(gameLoop);
                    timer = targetTime;
                    activeAction = 'bb';
                    bbCount = 0;
                    thrustCount = 0;
                    cyclesCompleted = 0;

                    currentBlockagePos = 10;
                    blockageItem.style.bottom = "10%";

                    valBB.innerText = "0";
                    valThrust.innerText = "0";
                    valCycles.innerText = "0";
                    timerDisp.innerText = `00:${timer < 10 ? '0' + timer : timer}`;

                    switchUI('bb');
                    chkStatus.innerText = "Commence 5 Back Blows!";
                    chkStatus.className = "mt-4 fs-5 fw-bold text-danger";
                    btnRetry.style.display = "none";

                    // Phase 1 Reset
                    phase2.style.display = "none";
                    phase1.style.display = "block";
                    chkTimer.style.display = "none";
                    currentBottomCardID = null;
                    phase1Status.innerText = "";
                    correctResult.style.display = "none";

                    handStage.querySelectorAll('.drag-hand-card').forEach(card => {
                        card.style.position = "static";
                        card.style.transform = "none";
                        card.style.width = "auto";
                        card.style.height = "85px";
                        card.style.zIndex = "1";
                        card.draggable = true;

                        card.classList.remove('border-danger', 'border-warning', 'border-success', 'border-primary');
                        card.classList.add('border-secondary');

                        if (card.dataset.text.startsWith('bot')) bottomBank.appendChild(card);
                        else topBank.appendChild(card);
                    });
                }
            }

            function bootBleedingGame(config) {
                let container = document.getElementById('simulationContainer');
                let bleedTime = parseInt(config.targetTime) || 45;

                // Blood physics
                let bloodVolume = 100;
                let baseRate = 100 / bleedTime;
                let bleedRate = baseRate * 2.5;
                let gameLoop;
                let currentPhase = 1;
                let isPlaying = false;

                if (!document.getElementById('bleedStyles')) {
                    let style = document.createElement('style');
                    style.id = 'bleedStyles';
                    style.innerHTML = `
                        @keyframes bloodPulse { 0% { transform: scale(1); opacity: 1; } 100% { transform: scale(1.8); opacity: 0; } }
                        @keyframes throb { 0% { transform: scale(1); } 50% { transform: scale(1.1); } 100% { transform: scale(1); } }
                        @keyframes bloodDrip { 0% { transform: translateY(0) scale(1); opacity: 1; } 80% { transform: translateY(90px) scale(0.8); opacity: 0.8; } 100% { transform: translateY(110px) scale(0); opacity: 0; } }
                        .bleed-pulse { animation: bloodPulse 0.6s infinite; }
                        .pulse-anim { animation: throb 1s infinite; }
                        .drip { animation: bloodDrip 1s infinite ease-in; }
                        .drip-delay-1 { animation-delay: 0.3s; }
                        .drip-delay-2 { animation-delay: 0.6s; }
                        .skin-tone { background-color: #fadcc4; }
                    `;
                    document.head.appendChild(style);
                }

                // 1. Draw the Master UI
                container.innerHTML = `
                    <div class="card bg-white text-dark rounded-4 shadow-lg border-2 border-danger overflow-hidden">
                        <div class="card-header bg-danger text-white text-center py-3 fw-bold fs-5">
                            <i class="fa-solid fa-droplet me-2"></i> Severe Bleeding Triage
                        </div>
                        
                        <div class="card-body p-4">
                            <div class="mb-4">
                                <div class="d-flex justify-content-between mb-1 fw-bold">
                                    <span class="text-danger"><i class="fa-solid fa-droplet me-1"></i> Blood Volume</span>
                                    <span id="bloodText" class="text-danger fs-5">100%</span>
                                </div>
                                <div class="progress shadow-sm border border-danger" style="height: 25px; background-color: #f8d7da;">
                                    <div id="bloodBar" class="progress-bar bg-danger progress-bar-striped progress-bar-animated" style="width: 100%; transition: width 0.5s linear;"></div>
                                </div>
                            </div>

                            <div id="triageStage" class="border border-2 border-secondary rounded bg-white position-relative overflow-hidden shadow-inner mx-auto" style="height: 400px; max-width: 600px;">
                                
                                <div id="startOverlay" class="position-absolute w-100 h-100 flex-column justify-content-center align-items-center" style="display: flex; background-color: rgba(0,0,0,0.85); z-index: 100; top: 0; left: 0;">
                                    <h4 class="text-white fw-bold mb-2">Severe Bleeding Detected!</h4>
                                    <p class="text-light mb-4 text-center px-4">The patient is losing blood rapidly.<br>Use the D.E.I. protocol to save them.</p>
                                    <button type="button" id="btnStartGame" class="btn btn-danger btn-lg fw-bold rounded-pill shadow-lg px-5 py-3 pulse-anim">
                                        <i class="fa-solid fa-play me-2"></i> START SIMULATION
                                    </button>
                                </div>

                                <div id="bloodPool" class="rounded-circle position-absolute opacity-75" style="background-color: #8b0000; bottom: -50px; left: 50%; transform: translateX(-50%); width: 0px; height: 0px; transition: width 1s, height 1s; filter: blur(3px);"></div>

                                <div id="phaseAlert" class="position-absolute top-0 w-100 bg-danger text-white text-center py-2 fw-bold" style="z-index: 20; --bs-bg-opacity: .9;">
                                    PHASE 1: Direct Pressure
                                </div>

                                <div id="heartLine" class="position-absolute w-100 border-top border-3 border-danger" style="top: 35%; display: none; border-style: dashed !important; z-index: 1;">
                                    <span class="badge bg-danger position-absolute" style="top: -12px; right: 10px;">Heart Level</span>
                                </div>

                                <div class="position-absolute skin-tone shadow-sm" style="width: 90px; height: 100px; left: -30px; top: 20px; border-radius: 50px; border: 2px solid #e9c1ab; z-index: 9;"></div>

                                <div class="position-absolute bg-secondary rounded-end shadow" style="width: 90px; height: 260px; left: 0; top: 60%; transform: translateY(-50%); z-index: 10; border-right: 2px solid #5c636a; border-top: 2px solid #5c636a; border-bottom: 2px solid #5c636a;">
                                    <div class="text-white text-center mt-5 fw-bold opacity-50" style="writing-mode: vertical-rl; text-orientation: upright; letter-spacing: 5px;">TORSO</div>
                                </div>
                                
                                <div class="position-absolute bg-dark shadow-sm" style="width: 75px; height: 160px; left: 10px; top: 340px; border-radius: 35px; border: 2px solid #212529; transform: rotate(15deg); z-index: 8;"></div>

                                <div id="armContainer" class="position-absolute d-flex align-items-center" style="left: 80px; top: 60%; transform-origin: left center; transform: translateY(-50%) rotate(0deg); transition: transform 0.1s linear; z-index: 15;">
                                    
                                    <div class="skin-tone position-relative" style="width: 140px; height: 60px; border: 2px solid #e9c1ab; border-left: none; border-radius: 0 10px 10px 0;">
                                        
                                        <div id="brachialBandage" class="position-absolute bg-white shadow-sm" style="width: 40px; height: 64px; left: 40%; top: -2px; transform: translateX(-50%); display: none; z-index: 49; border-radius: 5px; border: 2px solid #ccc; background-image: repeating-linear-gradient(45deg, transparent, transparent 3px, rgba(0,0,0,0.1) 3px, rgba(0,0,0,0.1) 6px);"></div>

                                        <div class="pressure-point position-absolute bg-danger rounded-circle pulse-anim shadow" data-type="brachial" style="width: 30px; height: 30px; left: 40%; top: 50%; transform: translate(-50%, -50%); display: none; cursor: crosshair; border: 2px solid white; z-index: 50;">
                                            <div class="badge bg-dark text-white position-absolute shadow rounded-pill p-2" style="top: 35px; left: -25px; width: 80px; white-space: normal;">Brachial Artery</div>
                                        </div>
                                    </div>
                                    
                                    <div class="skin-tone" style="width: 20px; height: 50px; border-top: 2px solid #e9c1ab; border-bottom: 2px solid #e9c1ab;"></div>
                                    
                                    <div class="skin-tone position-relative" style="width: 160px; height: 50px; border: 2px solid #e9c1ab; border-right: none; border-radius: 10px 0 0 10px;">
                                        <div class="pressure-point position-absolute bg-danger rounded-circle pulse-anim shadow" data-type="radial" style="width: 25px; height: 25px; right: 20px; top: 50%; transform: translate(0, -50%); display: none; cursor: crosshair; border: 2px solid white; z-index: 50;">
                                            <div class="badge bg-dark text-white position-absolute shadow rounded-pill p-2" style="top: -40px; left: -20px; width: 70px; white-space: normal;">Radial Artery</div>
                                        </div>

                                        <div id="theWound" class="position-absolute rounded-pill d-flex align-items-center justify-content-center shadow-sm" style="width: 35px; height: 15px; top: 50%; left: 40%; transform: translate(-50%, -50%); cursor: pointer; z-index: 50; background-color: #8b0000;">
                                            <div id="woundPulse" class="bg-danger rounded-pill w-100 h-100 bleed-pulse position-absolute" style="transform-origin: center;"></div>
                                            
                                            <div id="bloodDrips" class="position-absolute" style="top: 10px; left: 50%; transform: translateX(-50%); width: 10px; height: 120px; pointer-events: none;">
                                                <div class="drip position-absolute bg-danger rounded-circle" style="width: 7px; height: 12px; left: 1px;"></div>
                                                <div class="drip drip-delay-1 position-absolute bg-danger rounded-circle" style="width: 6px; height: 10px; left: 2px;"></div>
                                                <div class="drip drip-delay-2 position-absolute bg-danger rounded-circle" style="width: 7px; height: 11px; left: 1px;"></div>
                                            </div>
                                        </div>

                                        <i id="pressureHand" class="fa-solid fa-bandage text-white fs-1 position-absolute shadow" style="top: 50%; left: 40%; transform: translate(-50%, -50%) rotate(-15deg); display: none; z-index: 51; filter: drop-shadow(0px 4px 2px rgba(0,0,0,0.5));"></i>
                                    </div>
                                    
                                    <i class="fa-solid fa-hand skin-tone border-0 p-0 m-0" style="font-size: 65px; color: #fadcc4; transform: rotate(90deg) translateY(5px);"></i>
                                </div>

                            </div>

                            <div id="elevationControl" class="mt-4 bg-light p-3 rounded border border-secondary shadow-sm" style="display: none;">
                                <label class="fw-bold text-dark mb-3 d-flex justify-content-between">
                                    <span><i class="fa-solid fa-arrow-up me-1 text-danger"></i> Lift Arm Slider</span>
                                    <span class="small text-muted">Drag to elevate above heart level</span>
                                </label>
                                <input type="range" class="form-range w-100" id="armSlider" min="0" max="100" value="0" style="height: 25px; cursor: pointer;">
                            </div>

                            <div id="triageStatus" class="mt-4 fs-5 text-center text-dark" style="min-height: 60px;">
                                <i class="fa-solid fa-triangle-exclamation pulse-anim d-inline-block text-danger me-1"></i> <strong>Severe bleed detected!</strong> Click the wound to apply a Gauze Pad!
                            </div>

                            <div class="text-center">
                                <button type="button" id="btnRetry" class="btn btn-danger text-white rounded-pill mt-3 px-5 py-2 fw-bold shadow-sm" style="display: none;">
                                    <i class="fa-solid fa-rotate-right me-1"></i> Restart Scenario
                                </button>
                            </div>
                        </div>
                    </div>
                `;

                // Logic Variables
                let bloodBar = document.getElementById('bloodBar');
                let bloodText = document.getElementById('bloodText');
                let bloodPool = document.getElementById('bloodPool');
                let phaseAlert = document.getElementById('phaseAlert');
                let triageStatus = document.getElementById('triageStatus');

                let theWound = document.getElementById('theWound');
                let woundPulse = document.getElementById('woundPulse');
                let bloodDrips = document.getElementById('bloodDrips');
                let pressureHand = document.getElementById('pressureHand');
                let brachialBandage = document.getElementById('brachialBandage');

                let armContainer = document.getElementById('armContainer');
                let heartLine = document.getElementById('heartLine');
                let elevationControl = document.getElementById('elevationControl');
                let armSlider = document.getElementById('armSlider');
                let btnRetry = document.getElementById('btnRetry');

                let startOverlay = document.getElementById('startOverlay');
                let btnStartGame = document.getElementById('btnStartGame');

                // ==========================================
                // BOOT ENGINE
                // ==========================================
                btnStartGame.onclick = function (e) {
                    e.stopPropagation();
                    if (isPlaying) return;

                    startOverlay.style.display = "none";
                    startGame();
                };

                function startGame() {
                    clearInterval(gameLoop);
                    isPlaying = true;
                    bloodVolume = 100;
                    bleedRate = baseRate * 2.5;
                    currentPhase = 1;

                    gameLoop = setInterval(() => {
                        bloodVolume -= bleedRate;
                        if (bloodVolume <= 0) {
                            bloodVolume = 0;
                            loseGame();
                        }

                        bloodBar.style.width = bloodVolume + "%";
                        bloodText.innerText = Math.floor(bloodVolume) + "%";

                        let poolSize = (100 - bloodVolume) * 4.5;
                        bloodPool.style.width = poolSize + "px";
                        bloodPool.style.height = (poolSize / 3) + "px";
                    }, 500);
                }

                // ==========================================
                // PENALTY CATCHER (Background Clicks)
                // ==========================================
                document.getElementById('triageStage').onmousedown = function (e) {
                    if (!isPlaying) return;

                    if (e.target.closest('#theWound') || e.target.closest('.pressure-point') || e.target.closest('#startOverlay')) return;

                    if (currentPhase === 1) {
                        triggerPenalty("You missed! Click directly on the bleeding wound!");
                    } else if (currentPhase === 3) {
                        triggerPenalty("Wrong spot! Click the labeled artery.");
                    }
                };

                // ==========================================
                // PHASE 1: DIRECT PRESSURE 
                // ==========================================
                theWound.onmousedown = function (e) {
                    e.stopPropagation();
                    if (currentPhase !== 1 || !isPlaying) return;

                    woundPulse.style.display = "none";
                    bloodDrips.style.display = "none";
                    pressureHand.style.display = "block";
                    theWound.style.backgroundColor = "#dc3545";

                    bleedRate = baseRate;

                    triageStatus.innerHTML = "<strong>Gauze applied!</strong> Blood loss slowed. Now we must elevate the limb.";
                    triageStatus.className = "mt-4 fs-5 text-center text-dark";

                    currentPhase = 2;
                    setTimeout(initPhase2, 1500);
                };
                theWound.ontouchstart = theWound.onmousedown;

                // ==========================================
                // PHASE 2: ELEVATION
                // ==========================================
                function initPhase2() {
                    phaseAlert.innerText = "PHASE 2: Elevation";

                    heartLine.style.display = "block";
                    elevationControl.style.display = "block";

                    triageStatus.innerHTML = "Use the slider to physically <strong class='text-danger'>lift the bleeding arm</strong> above heart level!";

                    armSlider.addEventListener('input', function () {
                        if (currentPhase !== 2 || !isPlaying) return;

                        let val = parseInt(this.value);
                        let rotation = val * 0.45;
                        armContainer.style.transform = `translateY(-50%) rotate(-${rotation}deg)`;

                        if (val > 65) {
                            armSlider.disabled = true;
                            bleedRate = baseRate * 0.5;

                            triageStatus.innerHTML = "<strong>Limb elevated!</strong> Gravity is helping, but it's still bleeding. Moving to Indirect Pressure.";

                            currentPhase = 3;
                            setTimeout(initPhase3, 2000);
                        }
                    });
                }

                // ==========================================
                // PHASE 3: INDIRECT PRESSURE
                // ==========================================
                function initPhase3() {
                    phaseAlert.innerText = "PHASE 3: Indirect Pressure";
                    elevationControl.style.display = "none";

                    triageStatus.innerHTML = "Find the <strong class='text-decoration-underline'>Brachial Artery</strong>. Click it to compress the artery against the bone and stop the bleed!";

                    document.querySelectorAll('.pressure-point').forEach(pt => {
                        pt.style.display = "block";

                        pt.onmousedown = function (e) {
                            e.stopPropagation();
                            if (currentPhase !== 3 || !isPlaying) return;

                            if (this.dataset.type === 'brachial') {
                                isPlaying = false;
                                clearInterval(gameLoop);
                                bleedRate = 0;

                                // Hide the red dot target and show the visual Wrap!
                                this.style.display = "none";
                                brachialBandage.style.display = "block";

                                triageStatus.innerHTML = "<strong>Brachial Artery compressed!</strong> Bleeding is controlled, and advise the patient for immediate transfer to a hospital.";
                                triageStatus.className = "mt-4 fs-5 text-center text-success";
                                btnRetry.style.display = "inline-block";
                            } else {
                                triggerPenalty("Wrong artery! Radial artery cannot be compressed!");
                            }
                        };
                        pt.ontouchstart = pt.onmousedown;
                    });
                }

                // ==========================================
                // UTILITIES
                // ==========================================
                function triggerPenalty(msg) {
                    bloodVolume -= 8;
                    if (bloodVolume < 0) bloodVolume = 0;

                    document.getElementById('triageStage').style.backgroundColor = "#f8d7da";
                    setTimeout(() => document.getElementById('triageStage').style.backgroundColor = "#fff", 150);

                    let oldText = triageStatus.innerHTML;
                    let oldClass = triageStatus.className;

                    triageStatus.innerHTML = `<strong>${msg}</strong>`;
                    triageStatus.className = "mt-4 fs-5 text-center text-danger pulse-anim";

                    setTimeout(() => {
                        if (bloodVolume > 0 && isPlaying) {
                            triageStatus.innerHTML = oldText;
                            triageStatus.className = oldClass;
                        }
                    }, 1500);
                }

                function loseGame() {
                    isPlaying = false;
                    clearInterval(gameLoop);
                    armSlider.disabled = true;

                    bloodBar.style.width = "0%";
                    bloodText.innerText = "0%";

                    triageStatus.innerHTML = "<strong>Critical blood volume lost.</strong> The patient did not survive.";
                    triageStatus.className = "mt-4 fs-4 text-center text-danger pulse-anim";
                    btnRetry.style.display = "inline-block";
                }

                btnRetry.onclick = function () {
                    currentPhase = 1;
                    isPlaying = false;

                    phaseAlert.innerText = "PHASE 1: Direct Pressure";

                    heartLine.style.display = "none";
                    elevationControl.style.display = "none";
                    armSlider.value = 0;
                    armSlider.disabled = false;
                    armContainer.style.transform = "translateY(-50%) rotate(0deg)";

                    bloodPool.style.width = "0px";
                    bloodPool.style.height = "0px";

                    woundPulse.style.display = "block";
                    bloodDrips.style.display = "block";
                    pressureHand.style.display = "none";
                    brachialBandage.style.display = "none";
                    theWound.style.backgroundColor = "#8b0000";

                    document.querySelectorAll('.pressure-point').forEach(pt => {
                        pt.style.display = "none";
                    });

                    bloodBar.style.width = "100%";
                    bloodText.innerText = "100%";

                    btnRetry.style.display = "none";

                    triageStatus.innerHTML = '<i class="fa-solid fa-triangle-exclamation pulse-anim d-inline-block text-danger me-1"></i> <strong>Severe bleed detected!</strong> Click the wound to apply a Gauze Pad!';
                    triageStatus.className = "mt-4 fs-5 text-center text-dark";

                    startOverlay.style.display = "flex";
                };
            }

            function bootStrokeGame(config) {
                let container = document.getElementById('simulationContainer');
                let targetTime = parseInt(config.targetTime) || 10;

                if (!document.getElementById('medicalStyles')) {
                    let style = document.createElement('style');
                    style.id = 'medicalStyles';
                    style.innerHTML = `
                        @keyframes panicPulse { 0% { transform: scale(1); box-shadow: 0 0 0 rgba(220,53,69, 0.7); } 50% { transform: scale(1.05); box-shadow: 0 0 20px rgba(220,53,69, 0); } 100% { transform: scale(1); box-shadow: 0 0 0 rgba(220,53,69, 0); } }
                        @keyframes wheeze { 0% { transform: scale(1); opacity: 0.8; } 50% { transform: scale(0.9); opacity: 0.4; } 100% { transform: scale(1); opacity: 0.8; } }
                        @keyframes puffCloud { 0% { transform: translate(-50%, -50%) scale(0.5); opacity: 1; } 100% { transform: translate(-50%, -100px) scale(2); opacity: 0; } }
                        @keyframes shakeBtn { 0% { transform: translateX(0); } 25% { transform: translateX(-5px) rotate(-2deg); } 50% { transform: translateX(5px) rotate(2deg); } 75% { transform: translateX(-5px) rotate(-2deg); } 100% { transform: translateX(0); } }
                        
                        .fast-target { cursor: crosshair; transition: all 0.2s; border: 2px dashed transparent; }
                        .fast-target:hover { border-color: #dc3545; background-color: rgba(220, 53, 69, 0.1); }
                        .fast-found { border-color: #198754 !important; background-color: rgba(25, 135, 84, 0.2) !important; pointer-events: none; }
                        
                        .skin-tone { background-color: #fadcc4; border: 2px solid #e9c1ab; }
                        .btn-panic { animation: panicPulse 0.8s infinite; }
                        .lung-wheeze { animation: wheeze 0.6s infinite ease-in-out; }
                        .inhaler-puff { animation: puffCloud 0.8s ease-out forwards; position: absolute; background: rgba(255,255,255,0.8); border-radius: 50%; filter: blur(3px); z-index: 20; }
                        .shake-anim { animation: shakeBtn 0.4s ease-in-out; }
                    `;
                    document.head.appendChild(style);
                }

                // 1. Draw the Master UI
                container.innerHTML = `
                    <div class="card bg-white text-dark rounded-4 shadow-lg border-2 border-danger overflow-hidden w-100 mx-auto" style="max-width: 900px;">
                        
                        <div id="simHeader" class="card-header bg-danger text-white text-center py-3 fw-bold fs-5">
                            <i class="fa-solid fa-truck-medical me-2"></i> Medical Emergencies
                        </div>
                        
                        <div class="card-body p-4 bg-light position-relative" style="min-height: 550px; overflow-x: hidden;">
                            
                            <div id="phaseStroke" class="w-100 position-relative" style="transition: transform 0.5s ease-in-out;">
                                <h5 class="fw-bold text-danger mb-3 border-bottom border-danger pb-2">Scenario 1: F.A.S.T. Stroke Check</h5>
                                
                                <div class="alert alert-danger bg-opacity-10 border-danger mb-4 shadow-sm text-center">
                                    <h6 class="fw-bold text-danger m-0"><i class="fa-solid fa-magnifying-glass me-2"></i> Investigate the patient. Click on any physical anomalies you spot.</h6>
                                </div>

                                <div class="row g-4 align-items-center">
                                    <div class="col-md-6 text-center">
                                        <div class="position-relative mx-auto mt-4 mb-2" style="width: 240px; height: 300px;">
                                            
                                            <div id="targetS" class="fast-target position-absolute p-3 bg-white rounded-4 shadow-sm" style="top: -40px; left: 110px; width: 160px; z-index: 10;">
                                                <p class="m-0 small fw-bold text-dark fst-italic">"I-I can't... m-my words feel heavy..."</p>
                                                <div class="position-absolute bg-white" style="width: 15px; height: 15px; bottom: -7px; left: 20px; transform: rotate(45deg);"></div>
                                            </div>
                                            
                                            <div id="targetF" class="fast-target position-absolute skin-tone rounded-circle" style="width: 100px; height: 110px; top: 20px; left: 50%; transform: translateX(-50%); z-index: 5;">
                                                <div class="position-absolute bg-dark rounded-circle" style="width: 10px; height: 10px; top: 35px; left: 25px;"></div>
                                                <div class="position-absolute bg-dark rounded-circle" style="width: 10px; height: 10px; top: 35px; right: 25px;"></div>
                                                <div class="position-absolute border-bottom border-dark" style="width: 45px; height: 15px; top: 65px; left: 25px; border-width: 3px !important; border-radius: 0 0 50% 50%;"></div>
                                                <div class="position-absolute bg-dark" style="width: 3px; height: 12px; top: 78px; right: 28px; transform: rotate(-25deg);"></div>
                                            </div>

                                            <div class="position-absolute rounded-4 shadow-sm" style="width: 130px; height: 150px; top: 130px; left: 50%; transform: translateX(-50%); z-index: 4; background-color: #6c757d;"></div>

                                            <div class="position-absolute rounded-pill skin-tone" style="width: 30px; height: 110px; top: 140px; left: 15px; transform-origin: top center; transform: rotate(145deg); z-index: 3;">
                                                <i class="fa-solid fa-hand position-absolute" style="color: #fadcc4; font-size: 35px; bottom: -15px; left: -2px; transform: rotate(180deg);"></i>
                                            </div>

                                            <div id="targetA" class="fast-target position-absolute rounded-pill skin-tone p-1" style="width: 30px; height: 110px; top: 140px; right: 15px; transform-origin: top center; transform: rotate(-25deg); z-index: 3;">
                                                <i class="fa-solid fa-hand position-absolute opacity-75" style="color: #fadcc4; font-size: 35px; bottom: -15px; left: -2px; transform: rotate(180deg);"></i>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="card border-2 border-danger shadow bg-white rounded-4 overflow-hidden">
                                            <div class="card-header bg-danger text-white fw-bold text-center py-3 fs-5">
                                                <i class="fa-solid fa-clipboard-list me-2"></i> Medical Assessment
                                            </div>
                                            <div class="card-body p-0">
                                                <ul class="list-group list-group-flush fs-5">
                                                    <li id="checkF" class="list-group-item py-3 text-muted"><i class="fa-regular fa-square me-3 fs-4"></i> <strong>F</strong> <span class="ms-2">- Face Drooping</span></li>
                                                    <li id="checkA" class="list-group-item py-3 text-muted"><i class="fa-regular fa-square me-3 fs-4"></i> <strong>A</strong> <span class="ms-2">- Arm Weakness</span></li>
                                                    <li id="checkS" class="list-group-item py-3 text-muted"><i class="fa-regular fa-square me-3 fs-4"></i> <strong>S</strong> <span class="ms-2">- Speech Difficulty</span></li>
                                                    <li id="checkT" class="list-group-item py-3 text-muted bg-light"><i class="fa-regular fa-clock me-3 fs-4"></i> <strong>T</strong> <span class="ms-2">- Time to Call</span></li>
                                                </ul>
                                            </div>
                                        </div>
                                        
                                        <div id="emergencyPanel" class="mt-4 text-center" style="display: none;">
                                            <h5 class="fw-bold text-danger mb-3 pulse-anim">STROKE IDENTIFIED! <span id="fastTimer" class="badge bg-danger ms-2">${targetTime}s</span></h5>
                                            <button type="button" id="btnCall911" class="btn btn-danger btn-lg w-100 fw-bold py-3 fs-4 rounded-pill shadow-lg btn-panic text-white">
                                                <i class="fa-solid fa-phone-volume me-2"></i> CALL EMERGENCY SERVICES
                                            </button>
                                        </div>
                                    </div>
                                </div>

                                <div id="fastStatus" class="mt-4 fs-5 fw-bold text-center text-secondary" style="min-height: 30px;">
                                    Awaiting Diagnosis...
                                </div>
                                
                                <div class="text-center">
                                    <button type="button" id="btnNextEmergency" class="btn btn-danger text-white rounded-pill mt-3 px-5 py-3 fw-bold shadow-lg" style="display: none; font-size: 1.1rem;">
                                        Proceed to Next Emergency <i class="fa-solid fa-arrow-right ms-2"></i>
                                    </button>
                                </div>
                            </div>

                            <div id="phaseAsthma" class="w-100 position-absolute" style="top: 0; left: 100%; transition: left 0.5s ease-in-out; padding: 1.5rem;">
                                <h5 class="fw-bold text-danger mb-3 border-bottom border-danger pb-2">Scenario 2: Asthma Attack</h5>
                                
                                <div class="row g-4 align-items-center mt-2">
                                    
                                    <div class="col-md-6 text-center">
                                        <div class="position-relative mx-auto mt-3" style="width: 200px; height: 280px;">
                                            <div class="position-absolute skin-tone rounded-pill shadow-sm" style="width: 30px; height: 100px; bottom: 5px; left: 25px; transform: rotate(60deg); z-index: 1;"></div>
                                            <div class="position-absolute skin-tone rounded-pill shadow-sm" style="width: 30px; height: 100px; bottom: 5px; right: 25px; transform: rotate(-60deg); z-index: 1;"></div>

                                            <div id="asthmaUpperBody" class="position-absolute w-100" style="height: 200px; top: 40px; transform-origin: bottom center; transform: rotate(-20deg); transition: transform 0.5s ease-out; z-index: 5;">
                                                <div class="position-absolute skin-tone rounded-circle shadow-sm" style="width: 80px; height: 90px; top: -30px; left: 50%; transform: translateX(-50%); z-index: 6;">
                                                    <div class="position-absolute bg-dark rounded-circle" style="width: 8px; height: 8px; top: 35px; left: 20px;"></div>
                                                    <div class="position-absolute bg-dark rounded-circle" style="width: 8px; height: 8px; top: 35px; right: 20px;"></div>
                                                    <div class="position-absolute bg-dark rounded-pill" style="width: 20px; height: 25px; top: 55px; left: 50%; transform: translateX(-50%);"></div>
                                                </div>
                                                
                                                <div class="position-absolute rounded-4 shadow-sm bg-secondary d-flex flex-column align-items-center" style="width: 120px; height: 140px; top: 50px; left: 50%; transform: translateX(-50%); z-index: 5;">
                                                    <div class="bg-dark opacity-25 rounded-pill mt-2" style="width: 10px; height: 20px;"></div>
                                                    <div class="d-flex justify-content-center gap-2 mt-1">
                                                        <div id="lungLeft" class="lung-wheeze shadow-inner" style="width: 35px; height: 70px; background-color: #ff6b6b; border-radius: 40% 40% 50% 50%;"></div>
                                                        <div id="lungRight" class="lung-wheeze shadow-inner" style="width: 35px; height: 70px; background-color: #ff6b6b; border-radius: 40% 40% 50% 50%;"></div>
                                                    </div>
                                                </div>
                                                
                                                <div id="asthmaArmLeft" class="position-absolute skin-tone rounded-pill shadow-sm" style="width: 25px; height: 120px; top: 60px; left: 20px; transform-origin: top center; transform: rotate(40deg); transition: transform 0.5s ease-out; z-index: 4;"></div>
                                                <div id="asthmaArmRight" class="position-absolute skin-tone rounded-pill shadow-sm" style="width: 25px; height: 120px; top: 60px; right: 20px; transform-origin: top center; transform: rotate(-40deg); transition: transform 0.5s ease-out; z-index: 4;"></div>
                                                
                                                <div id="mouthTarget" class="position-absolute" style="top: 25px; left: 50%; width: 10px; height: 10px; z-index: 10;"></div>
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-6">
                                        <div class="card border-2 border-danger shadow bg-white rounded-4 overflow-hidden h-100">
                                            <div class="card-header bg-danger text-white fw-bold text-center py-3 fs-5">
                                                <i class="fa-solid fa-lungs me-2"></i> Asthma Protocol
                                            </div>
                                            <div class="card-body p-4 d-flex flex-column gap-3 justify-content-center">
                                                
                                                <button type="button" id="btnSitUp" class="btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm position-relative overflow-hidden transition-all">
                                                    <span class="position-relative z-index-1"><i class="fa-solid fa-person-arrow-up-from-line me-3 fs-4"></i> 1. Sit Upright</span>
                                                </button>

                                                <button type="button" id="btnPrepare" class="btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm disabled position-relative overflow-hidden transition-all">
                                                    <span class="position-relative z-index-1"><i class="fa-solid fa-pump-medical me-3 fs-4"></i> 2. Shake & Uncap</span>
                                                </button>

                                                <button type="button" id="btnInhaler" class="btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm disabled position-relative overflow-hidden transition-all">
                                                    <div id="puffProgress" class="position-absolute bg-danger h-100 top-0 left-0" style="width: 0%; opacity: 0.25;"></div>
                                                    <span id="inhalerText" class="position-relative z-index-1"><i class="fa-solid fa-spray-can me-3 fs-4" id="inhalerIcon"></i> 3. Administer Puff (<span id="puffCount">0</span>/4)</span>
                                                </button>
                                                
                                                <div class="alert alert-light border-danger mt-1 small m-0 text-danger text-center">
                                                    <strong>Protocol:</strong> Sit upright, prepare inhaler, exhale, puff, hold breath for 5s. Rinse mouth afterward.
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div id="asthmaStatus" class="mt-4 fs-5 fw-bold text-center text-danger" style="min-height: 30px;">
                                    Patient is hunched and struggling to breathe!
                                </div>
                                
                                <div id="asthmaEndButtons" class="d-none text-center justify-content-center mt-3">
                                    <button type="button" id="btnRetryAll" class="btn btn-outline-danger rounded-pill px-5 py-3 fw-bold shadow-sm" style="font-size: 1.1rem;">
                                        <i class="fa-solid fa-rotate-left me-2"></i> Restart Entire Simulation
                                    </button>
                                </div>
                            </div>

                        </div>
                    </div>
                `;

                // ==========================================
                // PHASE 1: STROKE LOGIC
                // ==========================================
                let targetF = document.getElementById('targetF');
                let targetA = document.getElementById('targetA');
                let targetS = document.getElementById('targetS');
                let checkF = document.getElementById('checkF');
                let checkA = document.getElementById('checkA');
                let checkS = document.getElementById('checkS');
                let checkT = document.getElementById('checkT');

                let emergencyPanel = document.getElementById('emergencyPanel');
                let btnCall911 = document.getElementById('btnCall911');
                let fastTimer = document.getElementById('fastTimer');
                let fastStatus = document.getElementById('fastStatus');
                let btnNextEmergency = document.getElementById('btnNextEmergency');

                let foundF = false; let foundA = false; let foundS = false;
                let strokeTimer = targetTime;
                let strokeLoop;
                let phase1Active = true;

                targetF.onclick = function () {
                    if (foundF || !phase1Active) return;
                    foundF = true;
                    this.classList.add('fast-found');
                    checkF.innerHTML = `<i class="fa-solid fa-square-check text-success me-3 fs-4"></i> <strong class="text-dark">F</strong> <span class="ms-2 text-dark">- Face Drooping Detected</span>`;
                    checkF.classList.replace('text-muted', 'bg-success'); checkF.classList.add('bg-opacity-10');
                    evaluateDiagnosis();
                };

                targetA.onclick = function () {
                    if (foundA || !phase1Active) return;
                    foundA = true;
                    this.classList.add('fast-found');
                    checkA.innerHTML = `<i class="fa-solid fa-square-check text-success me-3 fs-4"></i> <strong class="text-dark">A</strong> <span class="ms-2 text-dark">- Arm Weakness Detected</span>`;
                    checkA.classList.replace('text-muted', 'bg-success'); checkA.classList.add('bg-opacity-10');
                    evaluateDiagnosis();
                };

                targetS.onclick = function () {
                    if (foundS || !phase1Active) return;
                    foundS = true;
                    this.classList.add('fast-found');
                    checkS.innerHTML = `<i class="fa-solid fa-square-check text-success me-3 fs-4"></i> <strong class="text-dark">S</strong> <span class="ms-2 text-dark">- Speech Difficulty Detected</span>`;
                    checkS.classList.replace('text-muted', 'bg-success'); checkS.classList.add('bg-opacity-10');
                    evaluateDiagnosis();
                };

                function evaluateDiagnosis() {
                    let totalFound = [foundF, foundA, foundS].filter(Boolean).length;
                    if (totalFound === 3) {
                        fastStatus.innerText = "All signs confirm a stroke. Time is brain!";
                        fastStatus.className = "mt-4 fs-5 fw-bold text-center text-danger";
                        startStrokeTimer();
                    } else {
                        fastStatus.innerText = `Diagnosis in progress... ${totalFound}/3 critical signs identified.`;
                    }
                }

                function startStrokeTimer() {
                    checkT.innerHTML = `<i class="fa-solid fa-triangle-exclamation text-danger pulse-anim me-3 fs-4"></i> <strong class="text-danger">T</strong> <span class="ms-2 text-danger fw-bold">- TIME TO ACT!</span>`;
                    checkT.classList.replace('text-muted', 'bg-danger'); checkT.classList.add('bg-opacity-10');
                    emergencyPanel.style.display = "block";

                    strokeLoop = setInterval(() => {
                        strokeTimer--;
                        fastTimer.innerText = strokeTimer + "s";
                        if (strokeTimer <= 0) { clearInterval(strokeLoop); loseStroke(); }
                    }, 1000);
                }

                btnCall911.onclick = function () {
                    if (!phase1Active || strokeTimer <= 0) return;
                    clearInterval(strokeLoop);
                    phase1Active = false;

                    btnCall911.classList.remove('btn-panic', 'btn-danger');
                    btnCall911.classList.add('btn-success', 'disabled');
                    btnCall911.innerHTML = `<i class="fa-solid fa-truck-medical me-2"></i> AMBULANCE DISPATCHED`;

                    fastStatus.innerHTML = "<strong>Incredible work!</strong> You rapidly identified a stroke and called for help.";
                    fastStatus.className = "mt-4 fs-4 fw-bold text-center text-success";

                    btnNextEmergency.style.display = "inline-block";
                };

                function loseStroke() {
                    phase1Active = false;
                    btnCall911.disabled = true; btnCall911.classList.remove('btn-panic');
                    fastStatus.innerHTML = "<strong>Time expired.</strong> In a stroke emergency, you must call for help instantly.";
                    fastStatus.className = "mt-4 fs-4 fw-bold text-center text-danger";
                    // If they lose, we let them proceed anyway to learn Asthma, or they restart at end.
                    btnNextEmergency.style.display = "inline-block";
                }

                function resetStrokePhase() {
                    clearInterval(strokeLoop);
                    strokeTimer = targetTime; phase1Active = true;
                    foundF = false; foundA = false; foundS = false;

                    emergencyPanel.style.display = "none";
                    fastTimer.innerText = targetTime + "s";
                    btnCall911.disabled = false;
                    btnCall911.className = "btn btn-danger btn-lg w-100 fw-bold py-3 fs-4 rounded-pill shadow-lg btn-panic text-white";
                    btnCall911.innerHTML = `<i class="fa-solid fa-phone-volume me-2"></i> CALL EMERGENCY SERVICES`;

                    fastStatus.innerText = "Awaiting Diagnosis...";
                    fastStatus.className = "mt-4 fs-5 fw-bold text-center text-secondary";
                    btnNextEmergency.style.display = "none";

                    [targetF, targetA, targetS].forEach(t => t.classList.remove('fast-found'));
                    checkF.className = "list-group-item py-3 text-muted"; checkF.innerHTML = `<i class="fa-regular fa-square me-3 fs-4"></i> <strong>F</strong> <span class="ms-2">- Face Drooping</span>`;
                    checkA.className = "list-group-item py-3 text-muted"; checkA.innerHTML = `<i class="fa-regular fa-square me-3 fs-4"></i> <strong>A</strong> <span class="ms-2">- Arm Weakness</span>`;
                    checkS.className = "list-group-item py-3 text-muted"; checkS.innerHTML = `<i class="fa-regular fa-square me-3 fs-4"></i> <strong>S</strong> <span class="ms-2">- Speech Difficulty</span>`;
                    checkT.className = "list-group-item py-3 text-muted bg-light"; checkT.innerHTML = `<i class="fa-regular fa-clock me-3 fs-4"></i> <strong>T</strong> <span class="ms-2">- Time to Call</span>`;
                }

                // ==========================================
                // TRANSITION LOGIC
                // ==========================================
                let phaseStroke = document.getElementById('phaseStroke');
                let phaseAsthma = document.getElementById('phaseAsthma');

                btnNextEmergency.onclick = function () {
                    phaseStroke.style.position = "absolute";
                    phaseStroke.style.transform = "translateX(-120%)";

                    phaseAsthma.style.left = "0";
                    phaseAsthma.style.position = "relative";
                };

                // ==========================================
                // PHASE 2: ASTHMA LOGIC (Detailed Sequence)
                // ==========================================
                let asthmaUpperBody = document.getElementById('asthmaUpperBody');
                let asthmaArmLeft = document.getElementById('asthmaArmLeft');
                let asthmaArmRight = document.getElementById('asthmaArmRight');
                let lungLeft = document.getElementById('lungLeft');
                let lungRight = document.getElementById('lungRight');
                let mouthTarget = document.getElementById('mouthTarget');

                let btnSitUp = document.getElementById('btnSitUp');
                let btnPrepare = document.getElementById('btnPrepare');
                let btnInhaler = document.getElementById('btnInhaler');
                let inhalerText = document.getElementById('inhalerText');
                let puffProgress = document.getElementById('puffProgress');
                let asthmaStatus = document.getElementById('asthmaStatus');
                let asthmaEndButtons = document.getElementById('asthmaEndButtons');
                let btnRetryAll = document.getElementById('btnRetryAll');

                let currentPuffs = 0;
                let isUpright = false;
                let isPrepared = false;
                let isPuffing = false;

                // Action 1: Sit Upright
                btnSitUp.onclick = function () {
                    if (isUpright) return;
                    isUpright = true;

                    asthmaUpperBody.style.transform = "rotate(0deg)";
                    asthmaArmLeft.style.transform = "rotate(15deg)";
                    asthmaArmRight.style.transform = "rotate(-15deg)";

                    this.classList.replace('btn-outline-danger', 'btn-success');
                    this.classList.add('text-white', 'disabled');
                    this.innerHTML = `<i class="fa-solid fa-check text-white me-3 fs-4"></i> 1. Patient is upright`;

                    btnPrepare.classList.remove('disabled');

                    asthmaStatus.innerText = "Airways opened slightly. Now prepare the inhaler!";
                    asthmaStatus.className = "mt-4 fs-5 fw-bold text-center text-danger";
                };

                // Action 2: Prepare Inhaler
                btnPrepare.onclick = function () {
                    if (isPrepared || !isUpright) return;
                    isPrepared = true;

                    // Trigger physical shake animation on the button
                    this.classList.add('shake-anim');

                    setTimeout(() => {
                        this.classList.replace('btn-outline-danger', 'btn-success');
                        this.classList.add('text-white', 'disabled');
                        this.innerHTML = `<i class="fa-solid fa-check text-white me-3 fs-4"></i> 2. Inhaler Prepared`;

                        btnInhaler.classList.remove('disabled');
                        asthmaStatus.innerText = "Inhaler ready. Instruct patient to exhale fully, then administer puff.";
                    }, 400); // Wait for shake to finish
                };

                // Action 3: Administer & Hold Breath Time Mechanics
                btnInhaler.onclick = function () {
                    if (!isPrepared || currentPuffs >= 4 || isPuffing) return;
                    isPuffing = true;
                    currentPuffs++;

                    // Trigger puff VFX
                    let puff = document.createElement('div');
                    puff.className = 'inhaler-puff';
                    puff.style.width = '60px'; puff.style.height = '60px';
                    mouthTarget.appendChild(puff);
                    setTimeout(() => puff.remove(), 800);

                    // Morph button to simulate the 5 second holding breath!
                    this.classList.add('disabled');
                    inhalerText.innerHTML = `<i class="fa-solid fa-stopwatch me-3 fs-4"></i> Holding Breath...`;

                    // Sweep progress bar smoothly to visually show time passing
                    puffProgress.style.transition = "width 2s linear";
                    puffProgress.style.width = "100%";

                    asthmaStatus.innerText = `Puff ${currentPuffs} administered. Patient is holding breath...`;

                    // After 2 seconds simulated holding...
                    setTimeout(() => {
                        if (currentPuffs < 4) {
                            // Reset button for next puff
                            this.classList.remove('disabled');
                            puffProgress.style.transition = "none";
                            puffProgress.style.width = "0%";

                            // Small delay before re-enabling transition so it doesn't animate backwards
                            setTimeout(() => puffProgress.style.transition = "width 2s linear", 50);

                            inhalerText.innerHTML = `<i class="fa-solid fa-spray-can me-3 fs-4"></i> 3. Administer Puff (<span id="puffCount">${currentPuffs}</span>/4)`;
                            asthmaStatus.innerText = `Patient exhaled. Ready for Puff ${currentPuffs + 1}.`;
                            isPuffing = false;
                        } else {
                            // WIN ASTHMA PHASE
                            puffProgress.style.opacity = "0";
                            this.classList.replace('btn-outline-danger', 'btn-success');
                            this.classList.add('text-white');
                            inhalerText.innerHTML = `<i class="fa-solid fa-check text-white me-3 fs-4"></i> 3. 4 Puffs Complete`;

                            lungLeft.classList.remove('lung-wheeze'); lungRight.classList.remove('lung-wheeze');

                            asthmaStatus.innerHTML = "<strong>Protocol Complete!</strong> Wait 4 minutes. Reminder: Have patient rinse their mouth.";
                            asthmaStatus.className = "mt-4 fs-4 fw-bold text-center text-success";

                            asthmaEndButtons.classList.remove('d-none');
                            asthmaEndButtons.classList.add('d-flex');
                        }
                    }, 2000);
                };

                // MASTER RESTART BUTTON
                btnRetryAll.onclick = function () {
                    // 1. Reset Asthma Logic
                    currentPuffs = 0;
                    isUpright = false;
                    isPrepared = false;
                    isPuffing = false;

                    asthmaUpperBody.style.transform = "rotate(-20deg)";
                    asthmaArmLeft.style.transform = "rotate(40deg)";
                    asthmaArmRight.style.transform = "rotate(-40deg)";
                    lungLeft.classList.add('lung-wheeze');
                    lungRight.classList.add('lung-wheeze');

                    btnSitUp.className = "btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm position-relative overflow-hidden transition-all";
                    btnSitUp.innerHTML = `<span class="position-relative z-index-1"><i class="fa-solid fa-person-arrow-up-from-line me-3 fs-4"></i> 1. Sit Upright</span>`;

                    btnPrepare.className = "btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm disabled position-relative overflow-hidden transition-all";
                    btnPrepare.innerHTML = `<span class="position-relative z-index-1"><i class="fa-solid fa-pump-medical me-3 fs-4"></i> 2. Shake & Uncap</span>`;

                    btnInhaler.className = "btn btn-outline-danger btn-lg fw-bold py-2 text-start shadow-sm disabled position-relative overflow-hidden transition-all";
                    btnInhaler.innerHTML = `<div id="puffProgress" class="position-absolute bg-danger h-100 top-0 left-0" style="width: 0%; opacity: 0.25; transition: width 0.3s, opacity 0.3s;"></div><span id="inhalerText" class="position-relative z-index-1"><i class="fa-solid fa-spray-can me-3 fs-4" id="inhalerIcon"></i> 3. Administer Puff (<span id="puffCount">0</span>/4)</span>`;

                    // Rebind dynamic elements
                    inhalerText = document.getElementById('inhalerText');
                    puffProgress = document.getElementById('puffProgress');

                    asthmaEndButtons.classList.remove('d-flex');
                    asthmaEndButtons.classList.add('d-none');

                    asthmaStatus.innerText = "Patient is hunched and struggling to breathe!";
                    asthmaStatus.className = "mt-4 fs-5 fw-bold text-center text-danger";

                    // 2. Reset Stroke Logic
                    resetStrokePhase();

                    // 3. Slide the UI backwards!
                    phaseAsthma.style.position = "absolute";
                    phaseAsthma.style.left = "100%";

                    phaseStroke.style.position = "relative";
                    phaseStroke.style.transform = "translateX(0)";
                };
            }
        };
    </script>
</body>
</html>