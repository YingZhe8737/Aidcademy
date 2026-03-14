<%@ Page Title="Edit Lesson" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorEditContent.aspx.cs" Inherits="Aidcademy.InstructorEditContent" ValidateRequest="false" %>
<%@ Register Src="~/InstructorCourseSelector.ascx" TagName="InstructorCourseSelector" TagPrefix="uc" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="Styles/Instructor.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h4 class="fw-bold m-0"><i class="fa-solid fa-pen-to-square me-2 text-danger"></i>Editing Lesson</h4>
                    <a href="InstructorManageContent.aspx" class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-arrow-left me-1"></i> Back to Dashboard</a>
                </div>

                <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-3"></asp:Label>

                <div class="card creator-card shadow-sm p-4 mb-4">
                    <div class="row mb-4">
                        <div class="col-md-8">
                            <uc:InstructorCourseSelector ID="ctrlCourseSelector" runat="server"
                                OnCourseChanged="ctrlCourseSelector_CourseChanged"
                                OnCourseDeleted="ctrlCourseSelector_CourseDeleted" />
                        </div>
                        <div class="col-md-4">
                            <label class="text-muted small fw-bold text-uppercase">Step Number</label>
                            <asp:TextBox ID="txtSequenceOrder" runat="server" CssClass="form-control border-0 bg-light fw-bold" TextMode="Number"></asp:TextBox>
                        </div>
                    </div>

                    <div class="mb-4">
                        <asp:TextBox ID="txtLessonTitle" runat="server" CssClass="form-control border-0 px-0 shadow-none fs-2 fw-bold" placeholder="Lesson Title..."></asp:TextBox>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-8">
                            <asp:TextBox ID="txtLessonDescription" runat="server" CssClass="form-control border-0 px-3 py-2 shadow-sm bg-light" placeholder="Short description of this lesson..." TextMode="MultiLine" Rows="2"></asp:TextBox>
                        </div>
                        <div class="col-md-4">
                            <label class="small text-muted fw-bold">Lesson Thumbnail</label>
                            <asp:FileUpload ID="fuLessonThumbnail" runat="server" CssClass="form-control form-control-sm border-0 shadow-sm bg-light" accept=".png,.jpg,.jpeg" />
                        </div>
                    </div>
                    <div class="mb-3"><div id="editor-container"></div></div>
                    <asp:HiddenField ID="hfContentBody" runat="server" />
                    <div class="mt-4 p-4 border rounded bg-light border-info border-2">
                        <div class="d-flex justify-content-between align-items-center">
                            <div>
                                <h5 class="fw-bold text-info m-0"><i class="fa-solid fa-gamepad me-2"></i>Interactive Simulation</h5>
                                <small class="text-muted">Attach a playable mini-game to this lesson.</small>
                            </div>
                            <button type="button" class="btn btn-info text-white fw-bold" data-bs-toggle="modal" data-bs-target="#simulationModal">
                                Configure Game
                            </button>
                        </div>
                        <div id="simulationStatus" class="mt-3 text-success fw-bold" style="display:none;">
                            <i class="fa-solid fa-check-circle me-1"></i> Simulation Attached!
                        </div>
                    </div>

                    <asp:HiddenField ID="hfSimulationType" runat="server" />
                    <asp:HiddenField ID="hfSimulationData" runat="server" />

                    <div class="modal fade" id="simulationModal" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header bg-info text-white">
                                    <h5 class="modal-title fw-bold"><i class="fa-solid fa-wrench me-2"></i>Game Builder</h5>
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

                                <div class="modal-footer d-flex justify-content-between">
                                    <button type="button" class="btn btn-outline-danger" onclick="clearSimulation()" data-bs-dismiss="modal">Remove Game</button>
                                    <button type="button" class="btn btn-info text-white fw-bold" onclick="saveSimulation()" data-bs-dismiss="modal">Attach Game</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="publish-bar shadow-lg">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-9 d-flex justify-content-between align-items-center">
                    <span class="text-muted small"><i class="fa-solid fa-clock-rotate-left me-1"></i> Don't lose your progress</span>
                    <div>
                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft" CssClass="btn btn-outline-secondary fw-bold px-4 me-2" OnClientClick="markAsSaving(); return validateLessonForm(this);" OnClick="btnSaveDraft_Click" />
                        <asp:Button ID="btnPublishAdmin" runat="server" Text="Publish to Admin" CssClass="btn btn-danger fw-bold px-4" OnClientClick="markAsSaving(); return validateLessonForm(this);" OnClick="btnPublishAdmin_Click" />    
                    </div>
                </div>
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

            // UNPACK SAVED SIMULATION INTO THE MODAL
            let existingSimType = document.getElementById('<%= hfSimulationType.ClientID %>').value;
            let existingSimData = document.getElementById('<%= hfSimulationData.ClientID %>').value;
            if (existingSimType) {
                // Map raw DB names to readable titles!
                let readableTitle = existingSimType;
                if (existingSimType === "RhythmCPR") readableTitle = "Rhythm Clicker (CPR Simulator)";
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

        function toggleGameSettings() {
            let engine = document.getElementById("ddlGameEngine").value;
            if (existingSimType === "RhythmCPR") readableTitle = "CPR Simulator: Hand Placement & Rhythm";
            if (existingSimType === "DragDropSequence") readableTitle = "Drag & Drop Sequence (DRSABCD)";
            if (existingSimType === "ChokingCombo") readableTitle = "Choking: Grip & Action Combo";
            if (existingSimType === "BleedingTriage") readableTitle = "Severe Bleeding (D.E.I. Protocol)";
            if (existingSimType === "StrokeFAST") readableTitle = "F.A.S.T. Stroke Identifier";
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

            // Save to hidden fields
            document.getElementById('<%= hfSimulationType.ClientID %>').value = engine;
            document.getElementById('<%= hfSimulationData.ClientID %>').value = JSON.stringify(gameData);

            // Show success text
            document.getElementById("simulationStatus").style.display = "block";
            // Now using readableTitle instead of the raw engine ID!
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

        // 1. Detect any typing in the editor or the textboxes
        window.addEventListener('load', function () {
            // Watch Quill Editor for changes
            if (window.quill) {
                window.quill.on('text-change', function () {
                    hasUnsavedChanges = true;
                });
            }

            // Watch Title and Sequence boxes for changes
            const titleBox = document.getElementById('<%= txtLessonTitle.ClientID %>');
            const seqBox = document.getElementById('<%= txtSequenceOrder.ClientID %>');

            if (titleBox) titleBox.addEventListener('input', () => hasUnsavedChanges = true);
            if (seqBox) seqBox.addEventListener('input', () => hasUnsavedChanges = true);
        });

        // 2. The Browser's Native Warning (For Refreshing or Closing the Tab)
        window.addEventListener('beforeunload', function (e) {
            // Note: Browsers do not allow custom text here for security reasons. 
            // It will show the browser's default "Changes you made may not be saved" popup.
            if (hasUnsavedChanges && !isSaving) {
                e.preventDefault();
                e.returnValue = '';
            }
        });

        // 3. Custom Warning for your "Back to Dashboard" button
        document.addEventListener("DOMContentLoaded", function () {
            const backBtn = document.querySelector('a[href="InstructorManageContent.aspx"]');
            if (backBtn) {
                backBtn.addEventListener('click', function (e) {
                    if (hasUnsavedChanges && !isSaving) {
                        const confirmLeave = confirm("You have unsaved changes!\n\nClick OK to discard them and leave.\nClick Cancel to stay and Save as Draft.");
                        if (!confirmLeave) {
                            e.preventDefault(); // Stop them from leaving
                        }
                    }
                });
            }
        });

        // 4. Disable the warning when they actually click your Save/Publish buttons!
        function markAsSaving() {
            isSaving = true;
        }
    </script>

</asp:Content>