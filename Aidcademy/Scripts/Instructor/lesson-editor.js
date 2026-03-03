// Global variables
var glbContentBodyId = '';
var glbIsNewCourseId = '';
var glbCustomCategoryId = '';

function initLessonSystem(contentBodyId, isNewCourseId, customCategoryId, existingHtml) {
    glbContentBodyId = contentBodyId;
    glbIsNewCourseId = isNewCourseId;
    glbCustomCategoryId = customCategoryId;

    var BlockEmbed = Quill.import('blots/block/embed');

    // 1. REGISTER NATIVE FLIP CARD BLOT
    class FlipCardBlot extends BlockEmbed {
        static create(value) {
            let node = super.create();
            node.setAttribute('class', 'aidcademy-custom-flipcard');
            node.setAttribute('data-img', value.imgUrl || '');
            node.setAttribute('data-front', value.frontText || '');
            node.setAttribute('data-back', value.backText || '');
            node.setAttribute('contenteditable', 'false');

            let imgHtml = value.imgUrl ? `<img src="${value.imgUrl}" style="max-height: 150px; border-radius: 4px; border: 1px solid #ccc; margin-bottom:10px;" />` : '';

            node.innerHTML = `
                <div style="background: #f8f9fa; border: 2px dashed #c9242b; padding: 15px; margin: 15px 0; border-radius: 8px; font-family: sans-serif;">
                    <div style="margin-bottom: 10px;">
                        ${imgHtml}
                        <div style="font-size: 12px; color: #c9242b; font-weight: bold; margin-bottom: 5px;">FLIP CARD FRONT:</div>
                        <h4 style="margin: 0; color: #333; font-weight: bold;">${value.frontText}</h4>
                    </div>
                    <div style="padding-top: 15px; border-top: 1px solid #ccc;">
                        <div style="font-size: 12px; color: #c9242b; font-weight: bold; margin-bottom: 5px;">FLIP CARD BACK:</div>
                        <span style="color: #555;">${value.backText}</span>
                    </div>
                </div>`;
            return node;
        }
        static value(node) {
            return { imgUrl: node.getAttribute('data-img'), frontText: node.getAttribute('data-front'), backText: node.getAttribute('data-back') };
        }
    }
    FlipCardBlot.blotName = 'flipcard';
    FlipCardBlot.tagName = 'div';
    FlipCardBlot.className = 'aidcademy-custom-flipcard';
    Quill.register(FlipCardBlot);

    // 2. REGISTER NATIVE ACCORDION BLOT
    class AccordionBlot extends BlockEmbed {
        static create(value) {
            let node = super.create();
            node.setAttribute('class', 'aidcademy-custom-accordion');
            node.setAttribute('data-title', value.title || '');
            node.setAttribute('data-content', value.content || '');
            node.setAttribute('contenteditable', 'false');

            node.innerHTML = `
                <div style="background: #ffffff; border: 1px solid #dee2e6; border-left: 4px solid #343a40; border-radius: 6px; margin: 15px 0; padding: 15px; font-family: sans-serif; box-shadow: 0 2px 4px rgba(0,0,0,0.02);">
                    <div style="font-weight: bold; color: #c9242b; font-size: 1.1rem; border-bottom: 1px dashed #dee2e6; padding-bottom: 10px; margin-bottom: 10px;">
                        &#9654; ${value.title}
                    </div>
                    <div style="color: #495057; line-height: 1.6;">${value.content}</div>
                </div>`;
            return node;
        }
        static value(node) {
            return { title: node.getAttribute('data-title'), content: node.getAttribute('data-content') };
        }
    }
    AccordionBlot.blotName = 'accordion';
    AccordionBlot.tagName = 'div';
    AccordionBlot.className = 'aidcademy-custom-accordion';
    Quill.register(AccordionBlot);

    // 3. INITIALIZE QUILL
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
                    ['flipcard', 'accordion']
                ],
                handlers: {
                    'flipcard': function () {
                        var m = document.getElementById('flipCardModal');
                        (bootstrap.Modal.getInstance(m) || new bootstrap.Modal(m)).show();
                    },
                    'accordion': function () {
                        var m = document.getElementById('accordionModal');
                        (bootstrap.Modal.getInstance(m) || new bootstrap.Modal(m)).show();
                    }
                }
            }
        }
    });

    document.querySelector('.ql-flipcard').title = "Insert Interactive Flip Card";
    document.querySelector('.ql-accordion').title = 'Insert Interactive Accordion';

    // 4. LOCAL STORAGE BACKUP RECOVERY (Only triggers on empty Upload page)
    var isUploadPage = window.location.href.toLowerCase().includes("upload");
    if (isUploadPage && (!existingHtml || existingHtml.trim() === "")) {
        var localBackup = localStorage.getItem('aidcademy_upload_backup');
        if (localBackup) {
            existingHtml = localBackup;
            document.getElementById(glbContentBodyId).value = localBackup; // Sync to ASP.NET hidden field
        }
    }

    // 5. LOAD DATA INTO EDITOR
    if (existingHtml && existingHtml.trim() !== "") {
        window.quill.root.innerHTML = existingHtml;
    }

    // 6. CONTINUOUS SYNC (Protects against Dropdown PostBacks!)
    window.quill.on('text-change', function () {
        var currentHtml = window.quill.root.innerHTML;
        document.getElementById(glbContentBodyId).value = currentHtml; // Protects against ASP.NET PostBacks

        if (isUploadPage) {
            localStorage.setItem('aidcademy_upload_backup', currentHtml); // Protects against closed tabs
        }
    });
}

// ---------------------------------------------------------
// UI TOGGLES & VALIDATION
// ---------------------------------------------------------

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
        existingDiv.style.display = 'none'; newDiv.style.display = 'block';
        btnToggle.innerHTML = '<i class="fa-solid fa-list"></i> Select Existing';
        btnToggle.classList.replace('text-danger', 'text-secondary'); hfIsNew.value = "1";
    } else {
        existingDiv.style.display = 'block'; newDiv.style.display = 'none';
        btnToggle.innerHTML = '<i class="fa-solid fa-plus"></i> New Course';
        btnToggle.classList.replace('text-secondary', 'text-danger'); hfIsNew.value = "0";
    }
}

function validateLessonForm(btnElement) {
    let isValid = true;
    document.querySelectorAll('.is-invalid').forEach(el => el.classList.remove('is-invalid'));
    let isNewCourse = document.getElementById(glbIsNewCourseId).value === "1";

    let title = document.querySelector('input[id*="txtLessonTitle"]');
    let sequence = document.querySelector('input[id*="txtSequenceOrder"]');

    if (!title.value.trim()) { title.classList.add('is-invalid'); isValid = false; }
    if (!sequence.value.trim()) { sequence.classList.add('is-invalid'); isValid = false; }

    if (isNewCourse) {
        let newTitle = document.querySelector('input[id*="txtNewCourseTitle"]');
        let newCat = document.querySelector('select[id*="ddlNewCourseCategory"]');
        if (!newTitle.value.trim()) { newTitle.classList.add('is-invalid'); isValid = false; }
        if (newCat.value === "") { newCat.classList.add('is-invalid'); isValid = false; }
    } else {
        let existingCourse = document.querySelector('select[id*="ddlCourses"]');
        if (existingCourse && existingCourse.value === "") { existingCourse.classList.add('is-invalid'); isValid = false; }
    }

    let editorContent = window.quill.getText().trim();
    if (editorContent.length === 0 && !window.quill.root.innerHTML.includes('aidcademy-custom')) {
        document.getElementById('editor-container').classList.add('border-danger', 'border-2');
        isValid = false;
    } else {
        document.getElementById('editor-container').classList.remove('border-danger', 'border-2');
        document.getElementById(glbContentBodyId).value = window.quill.root.innerHTML;
    }

    if (!isValid) {
        alert("Please fill in all required fields highlighted in red.");
        return false;
    }

    // CRITICAL: Clear the browser backup now that we successfully submitted it!
    localStorage.removeItem('aidcademy_upload_backup');

    return true;
}

// ---------------------------------------------------------
// INSERT EMBEDS NATIVELY
// ---------------------------------------------------------

function insertFlipCard() {
    var elImg = document.getElementById('fcImageUrl'), elFront = document.getElementById('fcFront'), elBack = document.getElementById('fcBack');
    var imgUrl = elImg ? elImg.value.trim() : '', frontText = elFront ? elFront.value.trim() : '', backText = elBack ? elBack.value.trim().replace(/\n/g, '<br>') : '';

    if (frontText === '' || backText === '') { alert("Please enter both front and back text."); return; }

    var range = window.quill.getSelection(true);
    var insertIndex = range ? range.index : window.quill.getLength();

    window.quill.insertEmbed(insertIndex, 'flipcard', { imgUrl: imgUrl, frontText: frontText, backText: backText }, Quill.sources.USER);
    window.quill.setSelection(insertIndex + 1, Quill.sources.SILENT);

    if (elImg) elImg.value = ''; if (elFront) elFront.value = ''; if (elBack) elBack.value = '';
    var closeBtn = document.getElementById('closeFlipModalBtn'); if (closeBtn) closeBtn.click();
}

function insertAccordion() {
    var elTitle = document.getElementById('accTitle'), elContent = document.getElementById('accContent');
    var title = elTitle ? elTitle.value.trim() : '', content = elContent ? elContent.value.trim().replace(/\n/g, '<br>') : '';

    if (title === '' || content === '') { alert("Please enter a title and content."); return; }

    var range = window.quill.getSelection(true);
    var insertIndex = range ? range.index : window.quill.getLength();

    window.quill.insertEmbed(insertIndex, 'accordion', { title: title, content: content }, Quill.sources.USER);
    window.quill.setSelection(insertIndex + 1, Quill.sources.SILENT);

    if (elTitle) elTitle.value = ''; if (elContent) elContent.value = '';
    var closeBtn = document.getElementById('closeAccModalBtn'); if (closeBtn) closeBtn.click();
}