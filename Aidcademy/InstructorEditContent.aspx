<%@ Page Title="Edit Lesson" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorEditContent.aspx.cs" Inherits="Aidcademy.InstructorEditContent" ValidateRequest="false" %>
<%@ Register Src="~/InstructorCourseSelector.ascx" TagName="InstructorCourseSelector" TagPrefix="uc" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="Styles/Instructor.css" rel="stylesheet" type="text/css" />
    <style>
        :root { --red:#c9242b; --red-dark:#a01c22; --red-light:#fde8e9; --dark:#1a1a2e; }

        .il-wrap { max-width: 860px; margin: 0 auto; padding-bottom: 90px; }

        .il-topbar { display:flex; align-items:center; justify-content:space-between; margin-bottom:24px; }
        .il-topbar h3 { font-size:1.4rem; font-weight:900; color:var(--dark); margin:0; display:flex; align-items:center; gap:9px; }
        .il-topbar h3 i { color:var(--red); }
        .il-back { display:inline-flex; align-items:center; gap:6px; background:white; border:1.5px solid #e0e0e0; color:#666; font-family:'Nunito',sans-serif; font-size:.85rem; font-weight:700; padding:8px 16px; border-radius:10px; text-decoration:none; transition:all .18s; }
        .il-back:hover { border-color:var(--red); color:var(--red); }

        .il-msg { display:block; padding:11px 15px; border-radius:10px; font-size:.88rem; font-weight:700; margin-bottom:18px; }

        .il-card { background:white; border-radius:16px; border:1px solid #ebebeb; margin-bottom:14px; overflow:hidden; }
        .il-card-head { padding:14px 20px; border-bottom:1px solid #f5f5f5; display:flex; align-items:center; gap:10px; }
        .il-step { width:26px; height:26px; border-radius:50%; background:var(--red-light); color:var(--red); font-size:.75rem; font-weight:900; display:flex; align-items:center; justify-content:center; flex-shrink:0; }
        .il-card-label { font-size:.9rem; font-weight:900; color:var(--dark); }
        .il-card-sublabel { font-size:.78rem; font-weight:600; color:#bbb; margin-left:4px; }
        .il-card-body { padding:18px 20px; }

        .il-field { margin-bottom:13px; }
        .il-lbl { display:block; font-size:.7rem; font-weight:800; color:#999; text-transform:uppercase; letter-spacing:.5px; margin-bottom:5px; }
        .il-inp { width:100%; padding:10px 13px; border-radius:10px; border:1.5px solid #e0e0e0; font-family:'Nunito',sans-serif; font-size:.9rem; font-weight:600; color:#333; outline:none; transition:border-color .18s; box-sizing:border-box; background:white; }
        .il-inp:focus { border-color:var(--red); }
        textarea.il-inp { resize:vertical; min-height:72px; }
        .il-title { width:100%; padding:10px 0; border:none; border-bottom:2.5px solid #e8e8e8; font-family:'Nunito',sans-serif; font-size:1.5rem; font-weight:900; color:var(--dark); outline:none; background:transparent; transition:border-color .18s; }
        .il-title:focus { border-color:var(--red); }
        .il-title::placeholder { color:#d0d0d0; }
        .il-grid2 { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
        @media(max-width:620px) { .il-grid2 { grid-template-columns:1fr; } }

        .il-sim-row { display:flex; align-items:center; justify-content:space-between; gap:16px; background:#f0f9ff; border:1.5px solid #bae6fd; border-radius:12px; padding:14px 18px; }
        .il-sim-info h6 { font-size:.88rem; font-weight:900; color:#0369a1; margin:0 0 3px; }
        .il-sim-info p { font-size:.76rem; color:#64748b; margin:0; }
        .il-sim-btn { flex-shrink:0; display:inline-flex; align-items:center; gap:6px; background:#0ea5e9; color:white; border:none; font-family:'Nunito',sans-serif; font-size:.82rem; font-weight:800; padding:9px 18px; border-radius:9px; cursor:pointer; transition:background .18s; white-space:nowrap; }
        .il-sim-btn:hover { background:#0284c7; }
        #simulationStatus { margin-top:10px; color:#059669; font-size:.82rem; font-weight:700; display:none; }

        .il-bar { position:sticky; bottom:0; background:white; border-top:1px solid #ebebeb; padding:13px 20px; display:flex; align-items:center; justify-content:space-between; z-index:50; box-shadow:0 -4px 14px rgba(0,0,0,.06); }
        .il-bar-hint { font-size:.78rem; color:#aaa; font-weight:600; display:flex; align-items:center; gap:5px; }
        .il-bar-hint i { color:#f59e0b; }
        .il-bar-btns { display:flex; gap:10px; }
        .il-btn-draft { display:inline-flex; align-items:center; gap:6px; background:white; border:2px solid #e0e0e0; color:#555; font-family:'Nunito',sans-serif; font-size:.88rem; font-weight:800; padding:9px 20px; border-radius:10px; cursor:pointer; transition:all .18s; }
        .il-btn-draft:hover { border-color:var(--red); color:var(--red); }
        .il-btn-publish { display:inline-flex; align-items:center; gap:6px; background:var(--red); border:none; color:white; font-family:'Nunito',sans-serif; font-size:.88rem; font-weight:800; padding:9px 20px; border-radius:10px; cursor:pointer; transition:all .18s; }
        .il-btn-publish:hover { background:var(--red-dark); transform:translateY(-1px); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="il-wrap">

    <div class="il-topbar">
        <h3><i class="fa-solid fa-pen-to-square"></i>Editing Lesson</h3>
        <a href="InstructorManageContent.aspx" class="il-back">
            <i class="fa-solid fa-arrow-left"></i> Back to Dashboard
        </a>
    </div>

    <asp:Label ID="lblMessage" runat="server" CssClass="il-msg"></asp:Label>

    <%-- STEP 1: Course & Step --%>
    <div class="il-card">
        <div class="il-card-head">
            <div class="il-step">1</div>
            <span class="il-card-label">Course &amp; Step</span>
        </div>
        <div class="il-card-body">
            <div class="il-grid2">
                <div>
                    <uc:InstructorCourseSelector ID="ctrlCourseSelector" runat="server"
                        OnCourseChanged="ctrlCourseSelector_CourseChanged"
                        OnCourseDeleted="ctrlCourseSelector_CourseDeleted" />
                </div>
                <div class="il-field">
                    <label class="il-lbl">Step Number</label>
                    <asp:TextBox ID="txtSequenceOrder" runat="server" CssClass="il-inp" TextMode="Number" placeholder="e.g. 1"></asp:TextBox>
                </div>
            </div>
        </div>
    </div>

    <%-- STEP 2: Lesson Details --%>
    <div class="il-card">
        <div class="il-card-head">
            <div class="il-step">2</div>
            <span class="il-card-label">Lesson Details</span>
        </div>
        <div class="il-card-body">
            <div class="il-field">
                <label class="il-lbl">Lesson Title</label>
                <asp:TextBox ID="txtLessonTitle" runat="server" CssClass="il-title" placeholder="Lesson title..."></asp:TextBox>
            </div>
            <div class="il-grid2">
                <div class="il-field">
                    <label class="il-lbl">Short Description</label>
                    <asp:TextBox ID="txtLessonDescription" runat="server" CssClass="il-inp" TextMode="MultiLine" Rows="3" placeholder="What will learners achieve in this lesson?"></asp:TextBox>
                </div>
                <div class="il-field">
                    <label class="il-lbl">Lesson Thumbnail</label>
                    <asp:FileUpload ID="fuLessonThumbnail" runat="server" CssClass="form-control form-control-sm mt-1" accept=".png,.jpg,.jpeg" />
                    <small style="color:#bbb;font-size:.73rem;font-weight:600;display:block;margin-top:5px;">Leave blank to keep existing thumbnail</small>
                </div>
            </div>
        </div>
    </div>

    <%-- STEP 3: Content Editor (Quill) --%>
    <div class="il-card">
        <div class="il-card-head">
            <div class="il-step">3</div>
            <span class="il-card-label">Lesson Content</span>
        </div>
        <div style="padding-bottom:0;">
            <div id="editor-container"></div>
        </div>
    </div>
    <asp:HiddenField ID="hfContentBody" runat="server" />

    <%-- STEP 4: Interactive Simulation --%>
    <div class="il-card">
        <div class="il-card-head">
            <div class="il-step">4</div>
            <span class="il-card-label">Interactive Simulation</span>
            <span class="il-card-sublabel">(optional)</span>
        </div>
        <div class="il-card-body">
            <div class="il-sim-row">
                <div class="il-sim-info">
                    <h6><i class="fa-solid fa-gamepad" style="margin-right:6px;"></i>Attach a Mini-Game</h6>
                    <p>Learners can practice the skill with an interactive scenario.</p>
                </div>
                <button type="button" class="il-sim-btn" data-bs-toggle="modal" data-bs-target="#simulationModal">
                    <i class="fa-solid fa-wrench"></i> Configure Game
                </button>
            </div>
            <div id="simulationStatus">
                <i class="fa-solid fa-check-circle me-1"></i> Simulation Attached!
            </div>
        </div>
    </div>

    <asp:HiddenField ID="hfSimulationType" runat="server" />
    <asp:HiddenField ID="hfSimulationData" runat="server" />

    <%-- Simulation Modal — identical to UploadLesson --%>
    <div class="modal fade" id="simulationModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header" style="background:var(--red);">
                    <h5 class="modal-title fw-bold text-white"><i class="fa-solid fa-wrench me-2"></i>Game Builder</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="fw-bold text-muted small">Select Game Engine</label>
                        <select id="ddlGameEngine" class="form-select border-2" onchange="toggleGameSettings()">
                            <option value="">-- No Game --</option>
                            <option value="DragDropSequence">Drag & Drop Sequence (DRSABCD)</option>
                            <option value="RhythmCPR">CPR Simulator: Hand Placement & Rhythm</option>
                            <option value="ChokingCombo">Choking: Grip & Action Combo</option>
                            <option value="BleedingTriage">Severe Bleeding (D.E.I. Protocol)</option>
                            <option value="StrokeFAST">Medical Emergencies (Stroke & Asthma)</option>
                        </select>
                    </div>
                    <div id="settingsDragDrop" style="display:none;" class="p-3 bg-light rounded border">
                        <h6 class="fw-bold text-primary"><i class="fa-solid fa-list-ol me-1"></i> Sequence Settings</h6>
                        <div class="mb-2">
                            <label class="small fw-bold">Correct Sequence (Comma Separated)</label>
                            <textarea id="txtSequenceItems" class="form-control" rows="3">Danger, Response, Send for help, Airway, Breathing, CPR, Defibrillation</textarea>
                            <small class="text-muted">Type the items in the EXACT correct order.</small>
                        </div>
                    </div>
                    <div id="settingsRhythmCPR" style="display:none;" class="p-3 bg-light rounded border">
                        <h6 class="fw-bold text-danger"><i class="fa-solid fa-heart-pulse me-1"></i> CPR Settings</h6>
                        <div class="mb-2">
                            <label class="small fw-bold">Target Beats Per Minute (BPM)</label>
                            <input type="number" id="txtCprBpm" class="form-control" value="110" />
                        </div>
                        <div class="mb-2">
                            <label class="small fw-bold">Survival Time (Seconds)</label>
                            <input type="number" id="txtCprTime" class="form-control" value="30" />
                        </div>
                    </div>
                    <div id="settingsChoking" style="display:none;" class="p-3 bg-light rounded border">
                        <h6 class="fw-bold text-warning"><i class="fa-solid fa-lungs-virus me-1"></i> Choking Emergency Settings</h6>
                        <div class="mb-2">
                            <label class="small fw-bold">Survival Time (Seconds)</label>
                            <input type="number" id="txtChokingTime" class="form-control" value="30" />
                            <small class="text-muted">How long they have to successfully complete the 5-and-5 cycles.</small>
                        </div>
                        <div class="mb-2">
                            <label class="small fw-bold">Cycles to clear airway</label>
                            <input type="number" id="txtChokingCycles" class="form-control" value="2" />
                            <small class="text-muted">Number of full 5-and-5 cycles required to win.</small>
                        </div>
                    </div>
                    <div id="settingsBleeding" style="display:none;" class="p-3 bg-light rounded border">
                        <h6 class="fw-bold text-danger"><i class="fa-solid fa-droplet me-1"></i> Severe Bleeding Settings</h6>
                        <div class="mb-2">
                            <label class="small fw-bold">Bleed-Out Time (Seconds)</label>
                            <input type="number" id="txtBleedTime" class="form-control" value="45" />
                            <small class="text-muted">How long the patient has before blood volume reaches 0%.</small>
                        </div>
                    </div>
                    <div id="settingsStroke" style="display:none;" class="p-3 bg-light rounded border">
                        <h6 class="fw-bold text-primary"><i class="fa-solid fa-brain me-1"></i> Stroke Diagnostic Settings</h6>
                        <div class="mb-2">
                            <label class="small fw-bold">Emergency Reaction Time (Seconds)</label>
                            <input type="number" id="txtStrokeTime" class="form-control" value="10" />
                            <small class="text-muted">How many seconds the student has to call for help AFTER identifying all 3 symptoms.</small>
                        </div>
                    </div>
                </div>
                <div class="modal-footer d-flex justify-content-between">
                    <button type="button" class="btn btn-outline-danger" onclick="clearSimulation()" data-bs-dismiss="modal">Remove Game</button>
                    <button type="button" class="btn btn-danger fw-bold" onclick="saveSimulation()" data-bs-dismiss="modal">Attach Game</button>
                </div>
            </div>
        </div>
    </div>

    <%-- PUBLISH BAR --%>
    <div class="il-bar">
        <div class="il-bar-hint">
            <i class="fa-solid fa-clock-rotate-left"></i> Don't lose your progress
        </div>
        <div class="il-bar-btns">
            <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft"
                CssClass="il-btn-draft"
                OnClientClick="markAsSaving(); return validateLessonForm(this);"
                OnClick="btnSaveDraft_Click" />
            <asp:Button ID="btnPublishAdmin" runat="server" Text="Publish to Admin"
                CssClass="il-btn-publish"
                OnClientClick="markAsSaving(); return validateLessonForm(this);"
                OnClick="btnPublishAdmin_Click" />
        </div>
    </div>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="Scripts/Instructor/lesson-editor.js"></script>

    <script>
        window.onload = function () {
            var contentBodyId = '<%= hfContentBody.ClientID %>';
            var isNewCourseId = '<%= ctrlCourseSelector.IsNewCourseClientId %>';
            var customCategoryId = '<%= ctrlCourseSelector.CustomCategoryClientId %>';
            var existingHtml = document.getElementById(contentBodyId).value;

            initLessonSystem(contentBodyId, isNewCourseId, customCategoryId, existingHtml);

            // UNPACK SAVED SIMULATION INTO THE MODAL (EditContent only)
            let existingSimType = document.getElementById('<%= hfSimulationType.ClientID %>').value;
            let existingSimData = document.getElementById('<%= hfSimulationData.ClientID %>').value;

            if (existingSimType) {
                let readableTitle = existingSimType;
                if (existingSimType === "RhythmCPR") readableTitle = "CPR Simulator: Hand Placement & Rhythm";
                if (existingSimType === "DragDropSequence") readableTitle = "Drag & Drop Sequence (DRSABCD)";
                if (existingSimType === "ChokingCombo") readableTitle = "Choking: Grip & Action Combo";
                if (existingSimType === "BleedingTriage") readableTitle = "Severe Bleeding (D.E.I. Protocol)";
                if (existingSimType === "StrokeFAST") readableTitle = "F.A.S.T. Stroke Identifier";

                document.getElementById("simulationStatus").style.display = "block";
                document.getElementById("simulationStatus").innerHTML = `<i class="fa-solid fa-check-circle me-1"></i> ${readableTitle} Attached!`;

                let dropdown = document.getElementById("ddlGameEngine");
                if (dropdown) {
                    dropdown.value = existingSimType;
                    toggleGameSettings();
                }

                if (existingSimData) {
                    let parsedData = JSON.parse(existingSimData);
                    if (existingSimType === "RhythmCPR") {
                        if (parsedData.bpm) document.getElementById("txtCprBpm").value = parsedData.bpm;
                        if (parsedData.targetTime) document.getElementById("txtCprTime").value = parsedData.targetTime;
                    }
                    else if (existingSimType === "DragDropSequence") {
                        if (parsedData.items) document.getElementById("txtSequenceItems").value = parsedData.items.join(', ');
                    }
                    else if (existingSimType === "ChokingCombo") {
                        if (parsedData.targetTime) document.getElementById("txtChokingTime").value = parsedData.targetTime;
                        if (parsedData.cycles) document.getElementById("txtChokingCycles").value = parsedData.cycles;
                    }
                    else if (existingSimType === "BleedingTriage") {
                        if (parsedData.targetTime) document.getElementById("txtBleedTime").value = parsedData.targetTime;
                    }
                    else if (existingSimType === "StrokeFAST") {
                        if (parsedData.targetTime) document.getElementById("txtStrokeTime").value = parsedData.targetTime;
                    }
                }
            }
        };
    </script>

    <script>
        // Fixed: toggleGameSettings now reads from the dropdown, not undefined existingSimType
        function toggleGameSettings() {
            let engine = document.getElementById("ddlGameEngine").value;
            document.getElementById("settingsRhythmCPR").style.display = (engine === "RhythmCPR") ? "block" : "none";
            document.getElementById("settingsDragDrop").style.display = (engine === "DragDropSequence") ? "block" : "none";
            document.getElementById("settingsChoking").style.display = (engine === "ChokingCombo") ? "block" : "none";
            document.getElementById("settingsBleeding").style.display = (engine === "BleedingTriage") ? "block" : "none";
            document.getElementById("settingsStroke").style.display = (engine === "StrokeFAST") ? "block" : "none";
        }

        function saveSimulation() {
            let engine = document.getElementById("ddlGameEngine").value;
            if (!engine) return;

            let gameData = {};
            let readableTitle = engine;

            if (engine === "RhythmCPR") {
                gameData = {
                    bpm: document.getElementById("txtCprBpm").value,
                    targetTime: document.getElementById("txtCprTime").value
                };
                readableTitle = "CPR Simulator: Hand Placement & Rhythm";
            }
            else if (engine === "DragDropSequence") {
                let rawText = document.getElementById("txtSequenceItems").value;
                gameData = {
                    items: rawText.split(',').map(item => item.trim()).filter(item => item !== "")
                };
                readableTitle = "Drag & Drop Sequence (DRSABCD)";
            }
            else if (engine === "ChokingCombo") {
                gameData = {
                    targetTime: document.getElementById("txtChokingTime").value,
                    cycles: document.getElementById("txtChokingCycles").value
                };
                readableTitle = "Choking: Grip & Action Combo";
            }
            else if (engine === "BleedingTriage") {
                gameData = { targetTime: document.getElementById("txtBleedTime").value };
                readableTitle = "Severe Bleeding (D.E.I. Protocol)";
            }
            else if (engine === "StrokeFAST") {
                gameData = { targetTime: document.getElementById("txtStrokeTime").value };
                readableTitle = "F.A.S.T. Stroke Identifier";
            }

            document.getElementById('<%= hfSimulationType.ClientID %>').value = engine;
            document.getElementById('<%= hfSimulationData.ClientID %>').value = JSON.stringify(gameData);

            document.getElementById("simulationStatus").style.display = "block";
            document.getElementById("simulationStatus").innerHTML = `<i class="fa-solid fa-check-circle me-1"></i> ${readableTitle} Attached!`;
        }

        function clearSimulation() {
            document.getElementById('<%= hfSimulationType.ClientID %>').value = "";
            document.getElementById('<%= hfSimulationData.ClientID %>').value = "";
            document.getElementById("simulationStatus").style.display = "none";
            document.getElementById("ddlGameEngine").value = "";
            toggleGameSettings();
        }
    </script>

    <script>
        let hasUnsavedChanges = false;
        let isSaving = false;

        window.addEventListener('load', function () {
            if (window.quill) {
                window.quill.on('text-change', function () { hasUnsavedChanges = true; });
            }
            const titleBox = document.getElementById('<%= txtLessonTitle.ClientID %>');
            const seqBox   = document.getElementById('<%= txtSequenceOrder.ClientID %>');
            if (titleBox) titleBox.addEventListener('input', () => hasUnsavedChanges = true);
            if (seqBox) seqBox.addEventListener('input', () => hasUnsavedChanges = true);
        });

        window.addEventListener('beforeunload', function (e) {
            if (hasUnsavedChanges && !isSaving) {
                e.preventDefault();
                e.returnValue = '';
            }
        });

        document.addEventListener("DOMContentLoaded", function () {
            const backBtn = document.querySelector('a[href="InstructorManageContent.aspx"]');
            if (backBtn) {
                backBtn.addEventListener('click', function (e) {
                    if (hasUnsavedChanges && !isSaving) {
                        const confirmLeave = confirm("You have unsaved changes!\n\nClick OK to discard them and leave.\nClick Cancel to stay and Save as Draft.");
                        if (!confirmLeave) { e.preventDefault(); }
                    }
                });
            }
        });

        function markAsSaving() { isSaving = true; }
    </script>

</asp:Content>
