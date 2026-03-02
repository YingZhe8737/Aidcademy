// Global variables to hold the specific ASP.NET control IDs for whatever page is currently open
var glbContentBodyId = '';
var glbIsNewCourseId = '';
var glbCustomCategoryId = '';

function initLessonSystem(contentBodyId, isNewCourseId, customCategoryId, existingHtml) {
    glbContentBodyId = contentBodyId;
    glbIsNewCourseId = isNewCourseId;
    glbCustomCategoryId = customCategoryId;

    // 1. REGISTER CUSTOM QUILL BLOT FOR FLIP CARDS
    var BlockEmbed = Quill.import('blots/block/embed');
    class FlipCardBlot extends BlockEmbed {
        static create(value) {
            let node = super.create();
            node.setAttribute('class', 'aidcademy-flipcard-data');
            node.setAttribute('data-img', value.imgUrl || '');
            node.setAttribute('data-front', value.frontText || '');
            node.setAttribute('data-back', value.backText || '');
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

    // 2. INITIALIZE QUILL
    window.quill = new Quill('#editor-container', {
        theme: 'snow',
        placeholder: 'Write your instructions or insert interactive elements...',
        modules: {
            toolbar: {
                container: [
                    [{ 'header': [1, 2, 3, false] }],
                    ['bold', 'italic', 'underline'],
                    [{ 'align': [] }], 
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
            }
        }
    });

    // Add Tooltips
    document.querySelector('.ql-flipcard').title = "Insert Interactive Flip Card";
    document.querySelector('.ql-bold').title = 'Bold';
    document.querySelector('.ql-italic').title = 'Italic';
    document.querySelector('.ql-underline').title = 'Underline';
    document.querySelector('.ql-image').title = 'Upload Image';
    document.querySelector('.ql-video').title = 'Embed YouTube Video';

    // 3. LOAD EXISTING DATA (For the Edit Page)
    if (existingHtml && existingHtml.trim() !== "") {
        window.quill.root.innerHTML = existingHtml;
    }
}

function toggleCustomCategory(dropdown) {
    var customInput = document.getElementById(glbCustomCategoryId);
    if (dropdown.value === "Other") {
        customInput.style.display = "block";
        customInput.focus();
    } else {
        customInput.style.display = "none";
        customInput.value = "";
    }
}

function toggleNewCourse() {
    var existingDiv = document.getElementById('existingCourseDiv');
    var newDiv = document.getElementById('newCourseDiv');
    var btnToggle = document.getElementById('btnToggleCourse');
    var hfIsNew = document.getElementById(glbIsNewCourseId);

    if (hfIsNew.value === "0") {
        existingDiv.style.display = 'none';
        newDiv.style.display = 'block';
        btnToggle.innerHTML = '<i class="fa-solid fa-list"></i> Select Existing';
        btnToggle.classList.replace('text-danger', 'text-secondary');
        hfIsNew.value = "1";
    } else {
        existingDiv.style.display = 'block';
        newDiv.style.display = 'none';
        btnToggle.innerHTML = '<i class="fa-solid fa-plus"></i> New Course';
        btnToggle.classList.replace('text-secondary', 'text-danger');
        hfIsNew.value = "0";
    }
}

function insertFlipCard() {
    var frontText = document.getElementById('fcFront').value;
    var backText = document.getElementById('fcBack').value.replace(/\n/g, '<br>');
    var fileInput = document.getElementById('fcImageFile');
    var imgUrl = document.getElementById('fcImageUrl').value.trim();

    if (frontText === "" || backText === "") {
        alert("Please fill in both the Front Text and Back Text.");
        return;
    }

    var insertIntoEditor = function (finalImgUrl) {
        var range = window.quill.getSelection(true);
        window.quill.insertEmbed(range.index, 'flipcard', {
            imgUrl: finalImgUrl,
            frontText: frontText,
            backText: backText
        });
        window.quill.setSelection(range.index + 1, Quill.sources.SILENT);
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

// Add this to lesson-editor.js
function validateLessonForm(btnElement) {
    let isValid = true;

    // 1. Remove old red outlines
    document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));

    // 2. Define the inputs to check based on whether it's a new course or existing
    let isNewCourse = document.getElementById(glbIsNewCourseId).value === "1";

    // Title & Sequence are always required
    let title = document.querySelector('input[id*="txtLessonTitle"]');
    let sequence = document.querySelector('input[id*="txtSequenceOrder"]');

    if (!title.value.trim()) { title.classList.add('is-invalid'); isValid = false; }
    if (!sequence.value.trim()) { sequence.classList.add('is-invalid'); isValid = false; }

    // Course Validation
    if (isNewCourse) {
        let newTitle = document.querySelector('input[id*="txtNewCourseTitle"]');
        let newCat = document.querySelector('select[id*="ddlNewCourseCategory"]');
        if (!newTitle.value.trim()) { newTitle.classList.add('is-invalid'); isValid = false; }
        if (newCat.value === "") { newCat.classList.add('is-invalid'); isValid = false; }
    } else {
        let existingCourse = document.querySelector('select[id*="ddlCourses"]');
        if (existingCourse && existingCourse.value === "") { existingCourse.classList.add('is-invalid'); isValid = false; }
    }

    // Editor Validation (Quill)
    let editorContent = window.quill.getText().trim();
    if (editorContent.length === 0 && !window.quill.root.innerHTML.includes('<img')) {
        document.getElementById('editor-container').classList.add('border-danger', 'border-2');
        isValid = false;
    } else {
        document.getElementById('editor-container').classList.remove('border-danger', 'border-2');
        saveQuillHtml(); // Save HTML to hidden field if valid
    }

    if (!isValid) {
        alert("Please fill in all required fields highlighted in red.");
        return false; // Stops the button from submitting to the C# backend
    }

    return true; // Allows the C# code to run
}

function saveQuillHtml() {
    document.getElementById(glbContentBodyId).value = document.querySelector('.ql-editor').innerHTML;
}