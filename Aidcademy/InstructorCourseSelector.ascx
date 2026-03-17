<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="InstructorCourseSelector.ascx.cs" Inherits="Aidcademy.InstructorCourseSelector" %>
<style>
    .ics-label{font-size:.72rem;font-weight:800;color:#888;text-transform:uppercase;letter-spacing:.5px;margin-bottom:6px;display:flex;align-items:center;justify-content:space-between;}
    .ics-toggle-link{font-size:.78rem;font-weight:800;color:#c9242b;text-decoration:none;display:inline-flex;align-items:center;gap:4px;}
    .ics-toggle-link:hover{opacity:.75;color:#c9242b;}
    .ics-select-row{display:flex;gap:6px;align-items:center;}
    .ics-select{flex:1;padding:10px 14px;border-radius:10px;border:1.5px solid #e0e0e0;font-family:'Nunito',sans-serif;font-size:.9rem;font-weight:700;color:#333;outline:none;transition:border-color .18s;background:white;}
    .ics-select:focus{border-color:#c9242b;}
    .ics-icon-btn{width:38px;height:38px;border-radius:9px;border:1.5px solid #e0e0e0;background:white;display:flex;align-items:center;justify-content:center;cursor:pointer;font-size:.85rem;transition:all .18s;flex-shrink:0;}
    .ics-icon-btn.edit{color:#3b82f6;}.ics-icon-btn.edit:hover{background:#dbeafe;border-color:#3b82f6;}
    .ics-icon-btn.del{color:#c9242b;}.ics-icon-btn.del:hover{background:#fde8e9;border-color:#c9242b;}
    .ics-panel{margin-top:12px;background:#f9f9f9;border-radius:12px;border:1px solid #ebebeb;padding:16px;}
    .ics-panel h6{font-size:.82rem;font-weight:900;color:#1a1a2e;margin-bottom:12px;display:flex;align-items:center;gap:6px;}
    .ics-panel.new-panel h6 i{color:#c9242b;} .ics-panel.edit-panel h6 i{color:#f59e0b;}
    .ics-fg{margin-bottom:10px;}
    .ics-fg label{display:block;font-size:.7rem;font-weight:800;color:#aaa;text-transform:uppercase;letter-spacing:.4px;margin-bottom:4px;}
    .ics-inp{width:100%;padding:9px 12px;border-radius:9px;border:1.5px solid #e0e0e0;font-family:'Nunito',sans-serif;font-size:.88rem;font-weight:600;color:#333;outline:none;transition:border-color .18s;box-sizing:border-box;}
    .ics-inp:focus{border-color:#c9242b;}
    .ics-row2{display:grid;grid-template-columns:1fr 1fr;gap:10px;}
    .ics-actions{display:flex;gap:8px;justify-content:flex-end;margin-top:12px;}
    .ics-btn{padding:7px 16px;border-radius:9px;font-family:'Nunito',sans-serif;font-size:.82rem;font-weight:800;cursor:pointer;border:none;transition:all .18s;}
    .ics-btn.cancel{background:#f3f4f6;color:#666;}.ics-btn.cancel:hover{background:#e5e7eb;}
    .ics-btn.save{background:#f59e0b;color:white;}.ics-btn.save:hover{background:#d97706;}
    .ics-msg{display:block;padding:9px 13px;border-radius:9px;font-size:.83rem;font-weight:700;margin-bottom:10px;}
    .ics-msg-s{background:#d1fae5;color:#065f46;} .ics-msg-e{background:#fde8e9;color:#9f1239;}
</style>

<asp:Label ID="lblCourseMessage" runat="server" Visible="false" CssClass="ics-msg"></asp:Label>

<%-- EXISTING COURSE --%>
<div id="ics-existing">
    <div class="ics-label">
        <span>Course</span>
        <a href="javascript:void(0);" onclick="icsToggleNew()" id="icsBtnToggle" class="ics-toggle-link">
            <i class="fa-solid fa-plus"></i> New Course
        </a>
    </div>
    <div class="ics-select-row">
        <asp:DropDownList ID="ddlCourses" runat="server" CssClass="ics-select"
            AutoPostBack="true" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged">
        </asp:DropDownList>
        <asp:LinkButton ID="btnEditCoursePrompt" runat="server" CssClass="ics-icon-btn edit"
            OnClick="btnEditCoursePrompt_Click" CausesValidation="false" ToolTip="Edit course">
            <i class="fa-solid fa-pen"></i>
        </asp:LinkButton>
        <asp:LinkButton ID="btnDeleteCourse" runat="server" CssClass="ics-icon-btn del"
            OnClientClick="return confirmCourseDelete();" OnClick="btnDeleteCourse_Click"
            CausesValidation="false" ToolTip="Delete course">
            <i class="fa-solid fa-trash"></i>
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlEditCourse" runat="server" Visible="false">
        <div class="ics-panel edit-panel">
            <h6><i class="fa-solid fa-pen-to-square"></i>Edit Course Details</h6>
            <div class="ics-fg"><label>Title</label><asp:TextBox ID="txtEditCourseTitle" runat="server" CssClass="ics-inp" /></div>
            <div class="ics-fg"><label>Category</label><asp:TextBox ID="txtEditCourseCategory" runat="server" CssClass="ics-inp" /></div>
            <div class="ics-fg"><label>Description</label><asp:TextBox ID="txtEditCourseDescription" runat="server" CssClass="ics-inp" TextMode="MultiLine" Rows="2" /></div>
            <div class="ics-fg"><label>Thumbnail</label><asp:FileUpload ID="fuEditCourseThumbnail" runat="server" accept=".png,.jpg,.jpeg" style="font-family:'Nunito',sans-serif;font-size:.85rem;" /></div>
            <div class="ics-actions">
                <asp:Button ID="btnCancelCourseEdit" runat="server" Text="Cancel" CssClass="ics-btn cancel" OnClick="btnCancelCourseEdit_Click" CausesValidation="false" />
                <asp:Button ID="btnSaveCourseEdit" runat="server" Text="Update Course" CssClass="ics-btn save" OnClick="btnSaveCourseEdit_Click" CausesValidation="false" />
            </div>
        </div>
    </asp:Panel>
</div>

<%-- NEW COURSE --%>
<div id="ics-new" style="display:none;">
    <div class="ics-label">
        <span>New Course</span>
        <a href="javascript:void(0);" onclick="icsToggleNew()" class="ics-toggle-link">
            <i class="fa-solid fa-arrow-left"></i> Use existing
        </a>
    </div>
    <div class="ics-panel new-panel">
        <h6><i class="fa-solid fa-folder-plus"></i>New Course Details</h6>
        <div class="ics-fg"><label>Title <span style="color:#c9242b">*</span></label><asp:TextBox ID="txtNewCourseTitle" runat="server" CssClass="ics-inp" placeholder="Course name..." /></div>
        <div class="ics-row2">
            <div class="ics-fg">
                <label>Category <span style="color:#c9242b">*</span></label>
                <asp:DropDownList ID="ddlNewCourseCategory" runat="server" CssClass="ics-inp" onchange="icsToggleCustomCat(this)"></asp:DropDownList>
            </div>
            <div class="ics-fg" id="ics-custom-wrap" style="display:none;">
                <label>Custom Category</label>
                <asp:TextBox ID="txtCustomCategory" runat="server" CssClass="ics-inp" placeholder="Type here..." />
            </div>
        </div>
        <div class="ics-fg"><label>Description</label><asp:TextBox ID="txtNewCourseDescription" runat="server" CssClass="ics-inp" TextMode="MultiLine" Rows="2" placeholder="What will learners achieve?" /></div>
        <div class="ics-fg"><label>Thumbnail</label><asp:FileUpload ID="fuNewCourseThumbnail" runat="server" accept=".png,.jpg,.jpeg" style="font-family:'Nunito',sans-serif;font-size:.85rem;" /></div>
    </div>
</div>

<asp:HiddenField ID="hfIsNewCourse" runat="server" Value="0" />

<script>
    function icsToggleNew() {
        var ex = document.getElementById('ics-existing'), nw = document.getElementById('ics-new'), hf = document.getElementById('<%= hfIsNewCourse.ClientID %>');
        var isNew=(nw.style.display==='none');
        nw.style.display=isNew?'block':'none'; ex.style.display=isNew?'none':'block'; hf.value=isNew?'1':'0';
    }
    function icsToggleCustomCat(sel){
        var w=document.getElementById('ics-custom-wrap'); w.style.display=(sel.value==='Other')?'block':'none';
    }
    function toggleNewCourse(){icsToggleNew();}
    function toggleCustomCategory(sel){icsToggleCustomCat(sel);}
    function confirmCourseDelete(){
        var ddl=document.getElementById('<%= ddlCourses.ClientID %>');
        var name = ddl.options[ddl.selectedIndex].text;
        if (!name || name === '-- Choose a Course --') return false;
        var input = prompt("WARNING: This will delete ALL lessons in this course!\n\nType the course name to confirm:\n'" + name.trim() + "'");
        if (input === null) return false;
        if (input !== name.trim()) { alert("Cancelled: name did not match."); return false; }
        return true;
    }
</script>
