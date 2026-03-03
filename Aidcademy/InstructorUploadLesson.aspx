<%@ Page Title="Create Lesson" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorUploadLesson.aspx.cs" Inherits="Aidcademy.InstructorUploadLesson" ValidateRequest="false" %>

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
                            <div class="d-flex justify-content-between align-items-end mb-1">
                                <label class="text-muted small fw-bold text-uppercase mb-0">Select Course</label>
                                <a href="javascript:void(0);" onclick="toggleNewCourse()" id="btnToggleCourse" class="small text-danger fw-bold text-decoration-none">
                                    <i class="fa-solid fa-plus"></i> New Course
                                </a>
                            </div>
                            
                            <div id="existingCourseDiv">
                                <div class="input-group">
                                    <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select border-0 bg-light fw-bold" AutoPostBack="true" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged"></asp:DropDownList>
        
                                    <asp:LinkButton ID="btnEditCoursePrompt" runat="server" CssClass="btn btn-secondary" OnClick="btnEditCoursePrompt_Click" CausesValidation="false" ToolTip="Edit Course Details">
                                        <i class="fa-solid fa-pen"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton ID="btnDeleteCourse" runat="server" CssClass="btn btn-danger" OnClientClick="return confirmCourseDelete();" OnClick="btnDeleteCourse_Click" CausesValidation="false" ToolTip="Delete Course">
                                        <i class="fa-solid fa-trash"></i>
                                    </asp:LinkButton>
                                </div>

                                <asp:Panel ID="pnlEditCourse" runat="server" Visible="false" CssClass="p-3 mt-2 bg-white border border-warning rounded shadow-sm">
                                    <h6 class="fw-bold text-warning"><i class="fa-solid fa-pen-to-square me-1"></i> Edit Course Details</h6>
                                    <div class="mb-2">
                                        <label class="small text-muted fw-bold">Course Title</label>
                                        <asp:TextBox ID="txtEditCourseTitle" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                                    </div>
                                    <div class="mb-2">
                                        <label class="small text-muted fw-bold">Category</label>
                                        <asp:TextBox ID="txtEditCourseCategory" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
                                    </div>
                                    <div class="text-end mt-2">
                                        <asp:Button ID="btnCancelCourseEdit" runat="server" Text="Cancel" CssClass="btn btn-sm btn-light" OnClick="btnCancelCourseEdit_Click" CausesValidation="false" />
                                        <asp:Button ID="btnSaveCourseEdit" runat="server" Text="Update Course" CssClass="btn btn-sm btn-warning fw-bold" OnClick="btnSaveCourseEdit_Click" CausesValidation="false" />
                                    </div>
                                </asp:Panel>
                            </div>
                            
                            <div id="newCourseDiv" style="display:none;">
                                <div class="input-group">
                                    <asp:TextBox ID="txtNewCourseTitle" runat="server" CssClass="form-control border-0 bg-light fw-bold" placeholder="New course name..."></asp:TextBox>
                                    
                                    <asp:DropDownList ID="ddlNewCourseCategory" runat="server" CssClass="form-select border-0 bg-light fw-bold" onchange="toggleCustomCategory(this)" style="max-width: 130px;">
                                    </asp:DropDownList>
                                    
                                    <asp:TextBox ID="txtCustomCategory" runat="server" CssClass="form-control border-0 bg-light fw-bold" style="display:none; max-width: 150px;" placeholder="Type category..."></asp:TextBox>
                                </div>
                            </div>
                            <asp:HiddenField ID="hfIsNewCourse" runat="server" Value="0" />
                        </div>

                        <div class="col-md-4">
                            <label class="text-muted small fw-bold text-uppercase">Step Number</label>
                            <asp:TextBox ID="txtSequenceOrder" runat="server" CssClass="form-control border-0 bg-light fw-bold" TextMode="Number"></asp:TextBox>
                        </div>
                    </div>

                    <div class="mb-4">
                        <asp:TextBox ID="txtLessonTitle" runat="server" CssClass="form-control border-0 px-0 shadow-none fs-2 fw-bold" placeholder="Lesson Title..."></asp:TextBox>
                    </div>

                    <div class="mb-3">
                        <div id="editor-container"></div>
                    </div>
                    <asp:HiddenField ID="hfContentBody" runat="server" />
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
            var isNewCourseId = '<%= hfIsNewCourse.ClientID %>';
            var customCategoryId = '<%= txtCustomCategory.ClientID %>';

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
        function confirmCourseDelete() {
            var ddl = document.getElementById('<%= ddlCourses.ClientID %>');
            var courseName = ddl.options[ddl.selectedIndex].text;

            if (courseName === '-- Choose a Course --' || courseName === '') return false;

            var input = prompt("WARNING: Deleting this course will also delete ALL lessons inside it!\n\nTo confirm, type the course name exactly: '" + courseName.trim() + "'");

            if (input === null) return false;

            if (input !== courseName.trim()) {
                alert("Delete Cancelled: The course name you entered did not match.");
                return false;
            }
            return true;
        }
    </script>
</asp:Content>