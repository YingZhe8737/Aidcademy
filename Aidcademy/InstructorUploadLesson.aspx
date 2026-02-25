<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InstructorUploadLesson.aspx.cs" Inherits="Aidcademy.InstructorUploadLesson" ValidateRequest="false" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Create Interactive Lesson - Aidcademy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="https://cdn.quilljs.com/1.3.6/quill.snow.css" rel="stylesheet" />

    <style>
        .creator-card { border-radius: 12px; border: 1px solid #e0e0e0; }
        .publish-bar { background-color: #fff; border-top: 1px solid #e0e0e0; position: sticky; bottom: 0; z-index: 1000; padding: 15px 0; }
        #editor-container { height: 500px; font-family: 'Segoe UI', Tahoma, sans-serif; font-size: 16px; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; }
        .ql-toolbar { border-top-left-radius: 8px; border-top-right-radius: 8px; background-color: #f8f9fa; }
        
        /* Custom Icons for Quill Toolbar */
        .ql-flipcard::after { content: "\f022"; font-family: "FontAwesome"; font-size: 16px; }
        .ql-accordion::after { content: "\f0ca"; font-family: "FontAwesome"; font-size: 16px; }

        /* THE EDITOR TRICK: Make Flip Cards flat and editable INSIDE the editor only */
        .ql-editor .flip-card { background: #f8f9fa; border: 2px dashed #c9242b; padding: 15px; margin: 15px 0; border-radius: 8px; }
        .ql-editor .flip-card-front::before { content: "FLIP CARD FRONT:"; font-size: 12px; color: #c9242b; font-weight: bold; display: block; margin-bottom: 5px; }
        .ql-editor .flip-card-back { margin-top: 15px; padding-top: 15px; border-top: 1px solid #ccc; }
        .ql-editor .flip-card-back::before { content: "FLIP CARD BACK:"; font-size: 12px; color: #c9242b; font-weight: bold; display: block; margin-bottom: 5px; }
    </style>
</head>
<body class="bg-light">
    <form id="form1" runat="server">
        
        <nav class="navbar navbar-expand-lg bg-brand-red py-3 shadow-sm">
            <div class="container">
                <a class="navbar-brand text-white" href="#">
                    <i class="fa-solid fa-truck-medical me-2"></i>AIDCADEMY
                </a>
                <div class="collapse navbar-collapse justify-content-end">
                    <ul class="navbar-nav">
                        <li class="nav-item"><a class="nav-link" href="InstructorManageContent.aspx">Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link fw-bold active" href="InstructorUploadLesson.aspx">Upload Content</a></li>
                        <li class="nav-item"><a class="nav-link" href="RespondQuestions.aspx">Q&A</a></li>
                        <li class="nav-item"><a class="nav-link" href="InstructorProfile.aspx">Profile</a></li>
                        <li class="nav-item"><a class="nav-link" href="Login_signup.aspx">Logout</a></li>
                    </ul>
                </div>
            </div>
        </nav>

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
                                        <asp:TextBox ID="txtNewCourseTitle" runat="server" CssClass="form-control border-0 bg-light fw-bold" placeholder="Type new course name..."></asp:TextBox>
                                        <asp:DropDownList ID="ddlNewCourseCategory" runat="server" CssClass="form-select border-0 bg-light fw-bold" style="max-width: 150px;">
                                            <asp:ListItem Text="Category" Value=""></asp:ListItem>
                                            <asp:ListItem Text="General" Value="General"></asp:ListItem>
                                            <asp:ListItem Text="CPR" Value="CPR"></asp:ListItem>
                                            <asp:ListItem Text="Trauma" Value="Trauma"></asp:ListItem>
                                        </asp:DropDownList>
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
    </form>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.quilljs.com/1.3.6/quill.js"></script>
    
    <script>
        // 1. ADD COURSE TOGGLE LOGIC
        function toggleNewCourse() {
            var existingDiv = document.getElementById('existingCourseDiv');
            var newDiv = document.getElementById('newCourseDiv');
            var btnToggle = document.getElementById('btnToggleCourse');
            var hfIsNew = document.getElementById('<%= hfIsNewCourse.ClientID %>');

            if (hfIsNew.value === "0") {
                // Switch to "New Course" mode
                existingDiv.style.display = 'none';
                newDiv.style.display = 'block';
                btnToggle.innerHTML = '<i class="fa-solid fa-list"></i> Select Existing';
                btnToggle.classList.replace('text-danger', 'text-secondary');
                hfIsNew.value = "1";
            } else {
                // Switch back to "Existing Course" mode
                existingDiv.style.display = 'block';
                newDiv.style.display = 'none';
                btnToggle.innerHTML = '<i class="fa-solid fa-plus"></i> New Course';
                btnToggle.classList.replace('text-secondary', 'text-danger');
                hfIsNew.value = "0";
            }
        }

        // 2. REGISTER CUSTOM QUILL BLOT FOR FLIP CARDS
        var BlockEmbed = Quill.import('blots/block/embed');
        class FlipCardBlot extends BlockEmbed {
            static create(value) {
                let node = super.create();
                node.setAttribute('class', 'aidcademy-flipcard-data');
                node.setAttribute('data-img', value.imgUrl);
                node.setAttribute('data-front', value.frontText);
                node.setAttribute('data-back', value.backText);
                node.setAttribute('contenteditable', 'false');

                let imgHtml = value.imgUrl ? `<img src="${value.imgUrl}" style="max-height: 50px; margin-right: 15px; border-radius: 4px; border: 1px solid #ccc;" />` : '';
                node.innerHTML = `
                    <div style="background: #fff3f3; border: 2px dashed #c9242b; padding: 15px; margin: 15px 0; border-radius: 8px; font-family: sans-serif;">
                        <span style="background: #c9242b; color: white; padding: 3px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; margin-bottom: 10px; display: inline-block;"><i class="fa-solid fa-cube me-1"></i> INTERACTIVE FLIP CARD</span>
                        <div style="display: flex; align-items: center; margin-bottom: 10px;">
                            ${imgHtml}
                            <h5 style="margin: 0; color: #333; font-weight: bold;">${value.frontText}</h5>
                        </div>
                        <div style="background: white; padding: 10px; border: 1px solid #ddd; border-radius: 4px;">
                            <small style="color: #c9242b; font-weight: bold; display: block; margin-bottom: 5px;">BACK TEXT:</small>
                            <span style="color: #333;">${value.backText}</span>
                        </div>
                    </div>
                `;
                return node;
            }
            static value(node) {
                return {
                    imgUrl: node.getAttribute('data-img'),
                    frontText: node.getAttribute('data-front'),
                    backText: node.getAttribute('data-back')
                };
            }
        }

        FlipCardBlot.blotName = 'flipcard';
        FlipCardBlot.tagName = 'div';
        Quill.register(FlipCardBlot);

        // 3. INITIALIZE QUILL
        var toolbarOptions = {
            container: [
                [{ 'header': [1, 2, 3, false] }],
                ['bold', 'italic', 'underline'],
                [{ 'list': 'ordered' }, { 'list': 'bullet' }],
                ['image', 'video'],
                ['flipcard']
            ],
            handlers: {
                'flipcard': function () {
                    var modal = new bootstrap.Modal(document.getElementById('flipCardModal'));
                    modal.show();
                }
            }
        };

        var quill = new Quill('#editor-container', {
            theme: 'snow',
            placeholder: 'Write your instructions or insert interactive elements...',
            modules: { toolbar: toolbarOptions }
        });

        // Add tooltips
        function addQuillTooltips() {
            document.querySelector('.ql-flipcard').title = "Insert Interactive Flip Card";
            document.querySelector('.ql-bold').title = 'Bold';
            document.querySelector('.ql-italic').title = 'Italic';
            document.querySelector('.ql-underline').title = 'Underline';
            document.querySelector('.ql-list[value="ordered"]').title = 'Numbered List';
            document.querySelector('.ql-list[value="bullet"]').title = 'Bullet Point List';
            document.querySelector('.ql-header').title = 'Heading Style';
            document.querySelector('.ql-image').title = 'Upload Image';
            document.querySelector('.ql-video').title = 'Embed YouTube Video';
        }
        addQuillTooltips();

        // 4. INSERT BLOT
        function insertFlipCard() {
            var fileInput = document.getElementById('fcImageFile');
            var imgUrl = document.getElementById('fcImageUrl').value.trim();
            var frontText = document.getElementById('fcFront').value.trim();
            var backText = document.getElementById('fcBack').value.trim();

            if (frontText === "" || backText === "") {
                alert("Please fill in both the Front Text and Back Text.");
                return;
            }

            var insertIntoEditor = function (finalImgUrl) {
                var range = quill.getSelection(true);
                quill.insertEmbed(range.index, 'flipcard', {
                    imgUrl: finalImgUrl,
                    frontText: frontText,
                    backText: backText
                });
                quill.setSelection(range.index + 1, Quill.sources.SILENT);
                bootstrap.Modal.getInstance(document.getElementById('flipCardModal')).hide();
                document.getElementById('fcImageFile').value = '';
                document.getElementById('fcImageUrl').value = '';
                document.getElementById('fcFront').value = '';
                document.getElementById('fcBack').value = '';
            };

            if (fileInput.files && fileInput.files[0]) {
                var reader = new FileReader();
                reader.onload = function (e) { insertIntoEditor(e.target.result); };
                reader.readAsDataURL(fileInput.files[0]);
            } else {
                insertIntoEditor(imgUrl);
            }
        }

        // 5. SAVE HTML
        function saveQuillHtml() {
            document.getElementById('<%= hfContentBody.ClientID %>').value = document.querySelector('.ql-editor').innerHTML;
        }
    </script>
</body>
</html>