<%@ Page Title="Create Lesson" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorUploadLesson.aspx.cs" Inherits="Aidcademy.InstructorUploadLesson" ValidateRequest="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .creator-card { border-radius: 12px; border: 1px solid #e0e0e0; }
        .publish-bar { background-color: #fff; border-top: 1px solid #e0e0e0; position: sticky; bottom: 0; z-index: 1000; padding: 15px 0; }
        #editor-container { height: 500px; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 16px; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; }
        .ql-toolbar { border-top-left-radius: 8px; border-top-right-radius: 8px; background-color: #f8f9fa; }
        .ql-flipcard::after { content: "\f022"; font-family: "FontAwesome"; font-size: 16px; }
        .ql-editor .flip-card { background: #f8f9fa; border: 2px dashed #c9242b; padding: 15px; margin: 15px 0; border-radius: 8px; }
        .ql-editor .flip-card-front::before { content: "FLIP CARD FRONT:"; font-size: 12px; color: #c9242b; font-weight: bold; display: block; margin-bottom: 5px; }
        .ql-editor .flip-card-back { margin-top: 15px; padding-top: 15px; border-top: 1px solid #ccc; }
        .ql-editor .flip-card-back::before { content: "FLIP CARD BACK:"; font-size: 12px; color: #c9242b; font-weight: bold; display: block; margin-bottom: 5px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-4 mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-9">
                
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
                                <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select border-0 bg-light fw-bold"></asp:DropDownList>
                            </div>
                            
                            <div id="newCourseDiv" style="display:none;">
                                <div class="input-group">
                                    <asp:TextBox ID="txtNewCourseTitle" runat="server" CssClass="form-control border-0 bg-light fw-bold" placeholder="New course name..."></asp:TextBox>
                                    
                                    <asp:DropDownList ID="ddlNewCourseCategory" runat="server" CssClass="form-select border-0 bg-light fw-bold" onchange="toggleCustomCategory(this)" style="max-width: 130px;">
                                        <asp:ListItem Text="Category" Value=""></asp:ListItem>
                                        <asp:ListItem Text="General" Value="General"></asp:ListItem>
                                        <asp:ListItem Text="CPR" Value="CPR"></asp:ListItem>
                                        <asp:ListItem Text="Trauma" Value="Trauma"></asp:ListItem>
                                        <asp:ListItem Text="Other..." Value="Other"></asp:ListItem>
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

                <div class="card creator-card shadow-sm p-4 mb-4 border-warning">
                    <h5 class="fw-bold"><i class="fa-solid fa-clipboard-question text-warning me-2"></i>Attach Knowledge Check (Optional)</h5>
                    <p class="text-muted small">Add a quick question at the end of this lesson to test the member's understanding.</p>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Question Text</label>
                        <asp:TextBox ID="txtQuizQuestion" runat="server" CssClass="form-control" placeholder="e.g., What is the correct compression depth for an adult CPR?"></asp:TextBox>
                    </div>
                    <div class="row">
                        <div class="col-md-6 mb-2"><asp:TextBox ID="txtOptA" runat="server" CssClass="form-control" placeholder="Option A"></asp:TextBox></div>
                        <div class="col-md-6 mb-2"><asp:TextBox ID="txtOptB" runat="server" CssClass="form-control" placeholder="Option B"></asp:TextBox></div>
                        <div class="col-md-6 mb-2"><asp:TextBox ID="txtOptC" runat="server" CssClass="form-control" placeholder="Option C"></asp:TextBox></div>
                        <div class="col-md-6 mb-2"><asp:TextBox ID="txtOptD" runat="server" CssClass="form-control" placeholder="Option D"></asp:TextBox></div>
                    </div>
                    <div class="mt-2">
                        <label class="form-label fw-bold me-2">Correct Answer:</label>
                        <asp:DropDownList ID="ddlCorrectAnswer" runat="server" CssClass="form-select w-auto d-inline-block">
                            <asp:ListItem Value="A">A</asp:ListItem>
                            <asp:ListItem Value="B">B</asp:ListItem>
                            <asp:ListItem Value="C">C</asp:ListItem>
                            <asp:ListItem Value="D">D</asp:ListItem>
                        </asp:DropDownList>
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
                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save as Draft" CssClass="btn btn-outline-secondary fw-bold px-4 me-2" OnClientClick="saveQuillHtml();" OnClick="btnSaveDraft_Click" />
                        <asp:Button ID="btnSubmitLesson" runat="server" Text="Publish to Admin" CssClass="btn btn-danger fw-bold px-4" OnClientClick="saveQuillHtml();" OnClick="btnSubmitLesson_Click" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="flipCardModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header bg-brand-red text-white">
                    <h5 class="modal-title"><i class="fa-solid fa-cube me-2"></i>Insert Flip Card</h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3 p-3 bg-light border rounded">
                        <label class="form-label text-muted small fw-bold text-uppercase"><i class="fa-solid fa-image me-1"></i> Front Image (Optional)</label>
                        <div class="input-group mb-2">
                            <span class="input-group-text bg-white"><i class="fa-solid fa-upload"></i></span>
                            <input type="file" id="fcImageFile" class="form-control" accept=".jpg,.jpeg,.png,.gif" />
                        </div>
                        <div class="text-center small text-muted fw-bold my-1">OR</div>
                        <div class="input-group">
                            <span class="input-group-text bg-white"><i class="fa-solid fa-link"></i></span>
                            <input type="text" id="fcImageUrl" class="form-control" placeholder="Paste an image URL..." />
                        </div>
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold text-uppercase">Front Text (Title)</label>
                        <input type="text" id="fcFront" class="form-control" placeholder="e.g., R.I.C.E. Method" />
                    </div>
                    <div class="mb-3">
                        <label class="form-label text-muted small fw-bold text-uppercase">Back Text (Explanation)</label>
                        <textarea id="fcBack" class="form-control" rows="3" placeholder="e.g., Rest, Ice, Compress, Elevate"></textarea>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-danger" onclick="insertFlipCard()">Insert into Lesson</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="ScriptContent" runat="server">
    <script src="Scripts/Instructor/lesson-editor.js"></script>
    
    <script>
        window.onload = function () {
            // Find the ASP.NET IDs on this specific page
            var contentBodyId = '<%= hfContentBody.ClientID %>';
            var isNewCourseId = '<%= hfIsNewCourse.ClientID %>';
            var customCategoryId = '<%= txtCustomCategory.ClientID %>';

            // Read the hidden field. (It will be empty on the Upload page, but full of data on the Edit page!)
            var existingHtml = document.getElementById(contentBodyId).value;

            // Launch the shared logic!
            initLessonSystem(contentBodyId, isNewCourseId, customCategoryId, existingHtml);
        };
    </script>
</asp:Content>