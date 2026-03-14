<%@ Page Title="Create Lesson" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorUploadLesson.aspx.cs" Inherits="Aidcademy.InstructorUploadLesson" ValidateRequest="false" %>
<%@ Register Src="~/InstructorCourseSelector.ascx" TagName="InstructorCourseSelector" TagPrefix="uc" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="Styles/Instructor.css" rel="stylesheet" type="text/css" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h3 class="fw-bold m-0"><i class="fa-solid fa-cloud-arrow-up text-danger me-2"></i>Upload New Lesson</h3>
                    <a href="InstructorManageContent.aspx" class="btn btn-outline-secondary btn-sm fw-bold"><i class="fa-solid fa-arrow-left me-1"></i>Back to Dashboard</a>
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
                    <div class="mb-3">
                        <div id="editor-container"></div>
                    </div>
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

            var existingHtml = document.getElementById(contentBodyId).value;

            initLessonSystem(contentBodyId, isNewCourseId, customCategoryId, existingHtml);
        };
    </script>

    <script>
        let hasUnsavedChanges = false;
        let isSaving = false;

        // 1. Detect typing in the editor or ANY textboxes
        window.addEventListener('load', function () {
            if (window.quill) {
                window.quill.on('text-change', function () {
                    hasUnsavedChanges = true;
                });
            }

            // Watch all text inputs (Title, Sequence, New Course Name, etc.)
            const textInputs = document.querySelectorAll('input[type="text"]');
            textInputs.forEach(input => {
                input.addEventListener('input', () => hasUnsavedChanges = true);
            });
        });

        // 2. The Browser's Native Warning (For Refreshing or Tab Closing)
        window.addEventListener('beforeunload', function (e) {
            // THE FIX: Check what caused the page to reload. 
            // If they just clicked the Dropdown, stay quiet and let the AutoPostBack happen!
            const activeElement = document.activeElement;
            const isDropdownReload = activeElement && activeElement.tagName.toLowerCase() === 'select';

            if (hasUnsavedChanges && !isSaving && !isDropdownReload) {
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
                        const confirmLeave = confirm("You have unsaved changes!\n\nAre you sure you want to discard them and leave?");
                        if (!confirmLeave) {
                            e.preventDefault(); // Stop them from leaving
                        }
                    }
                });
            }
        });

        // 4. Disable the warning when they actually submit
        function markAsSaving() {
            isSaving = true;
        }
    </script>

    <script>
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

            if (engine === "RhythmCPR") {
                gameData = {
                    bpm: document.getElementById("txtCprBpm").value,
                    targetTime: document.getElementById("txtCprTime").value
                };
            }
            else if (engine === "DragDropSequence") {
                // Split the comma-separated string into a clean Array!
                let rawText = document.getElementById("txtSequenceItems").value;
                gameData = {
                    items: rawText.split(',').map(item => item.trim()).filter(item => item !== "")
                };
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
            document.getElementById("simulationStatus").innerHTML = `<i class="fa-solid fa-check-circle me-1"></i> ${engine} Attached!`;
        }

        function clearSimulation() {
            document.getElementById('<%= hfSimulationType.ClientID %>').value = "";
            document.getElementById('<%= hfSimulationData.ClientID %>').value = "";
            document.getElementById("simulationStatus").style.display = "none";
            document.getElementById("ddlGameEngine").value = "";
            toggleGameSettings();
        }
    </script>
</asp:Content>