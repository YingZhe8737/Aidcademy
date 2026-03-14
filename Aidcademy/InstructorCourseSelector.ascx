<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="InstructorCourseSelector.ascx.cs" Inherits="Aidcademy.InstructorCourseSelector" %>

<asp:Label ID="lblCourseMessage" runat="server" CssClass="d-block mb-2"></asp:Label>

<div class="d-flex justify-content-between align-items-end mb-1">
    <label class="text-muted small fw-bold text-uppercase mb-0">Select Course</label>
    <a href="javascript:void(0);" onclick="toggleNewCourse()" id="btnToggleCourse" class="small text-danger fw-bold text-decoration-none">
        <i class="fa-solid fa-plus"></i> New Course
    </a>
</div>

<div id="existingCourseDiv">
    <div class="input-group">
        <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select border-0 bg-light fw-bold"
            AutoPostBack="true" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged">
        </asp:DropDownList>
        <asp:LinkButton ID="btnEditCoursePrompt" runat="server" CssClass="btn btn-secondary"
            OnClick="btnEditCoursePrompt_Click" CausesValidation="false" ToolTip="Edit Course Details">
            <i class="fa-solid fa-pen"></i>
        </asp:LinkButton>
        <asp:LinkButton ID="btnDeleteCourse" runat="server" CssClass="btn btn-danger"
            OnClientClick="return confirmCourseDelete();" OnClick="btnDeleteCourse_Click"
            CausesValidation="false" ToolTip="Delete Course">
            <i class="fa-solid fa-trash"></i>
        </asp:LinkButton>
    </div>

    <asp:Panel ID="pnlEditCourse" runat="server" Visible="false"
        CssClass="p-3 mt-2 bg-white border border-warning rounded shadow-sm">
        <h6 class="fw-bold text-warning"><i class="fa-solid fa-pen-to-square me-1"></i> Edit Course Details</h6>
        <div class="mb-2">
            <label class="small text-muted fw-bold">Course Title</label>
            <asp:TextBox ID="txtEditCourseTitle" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
        </div>
        <div class="mb-2">
            <label class="small text-muted fw-bold">Category</label>
            <asp:TextBox ID="txtEditCourseCategory" runat="server" CssClass="form-control form-control-sm"></asp:TextBox>
        </div>
        <div class="mb-2">
            <label class="small text-muted fw-bold">Course Description</label>
            <asp:TextBox ID="txtEditCourseDescription" runat="server" CssClass="form-control form-control-sm"
                TextMode="MultiLine" Rows="2"></asp:TextBox>
        </div>
        <div class="mb-2">
            <label class="small text-muted fw-bold">Course Thumbnail</label>
            <asp:FileUpload ID="fuEditCourseThumbnail" runat="server" CssClass="form-control form-control-sm"
                accept=".png,.jpg,.jpeg" />
        </div>
        <div class="text-end mt-2">
            <asp:Button ID="btnCancelCourseEdit" runat="server" Text="Cancel"
                CssClass="btn btn-sm btn-light" OnClick="btnCancelCourseEdit_Click" CausesValidation="false" />
            <asp:Button ID="btnSaveCourseEdit" runat="server" Text="Update Course"
                CssClass="btn btn-sm btn-warning fw-bold" OnClick="btnSaveCourseEdit_Click" CausesValidation="false" />
        </div>
    </asp:Panel>
</div>

<div id="newCourseDiv" style="display:none;" class="p-3 border rounded bg-light">
    <div class="input-group mb-2">
        <asp:TextBox ID="txtNewCourseTitle" runat="server" CssClass="form-control border-0 fw-bold"
            placeholder="New course name..."></asp:TextBox>
        <asp:DropDownList ID="ddlNewCourseCategory" runat="server" CssClass="form-select border-0 fw-bold"
            onchange="toggleCustomCategory(this)" style="max-width: 130px;"></asp:DropDownList>
        <asp:TextBox ID="txtCustomCategory" runat="server" CssClass="form-control border-0 fw-bold"
            style="display:none; max-width: 150px;" placeholder="Type category..."></asp:TextBox>
    </div>
    <div class="mb-2">
        <asp:TextBox ID="txtNewCourseDescription" runat="server" CssClass="form-control border-0"
            placeholder="Course Description..." TextMode="MultiLine" Rows="2"></asp:TextBox>
    </div>
    <div>
        <label class="small text-muted fw-bold">Course Thumbnail</label>
        <asp:FileUpload ID="fuNewCourseThumbnail" runat="server" CssClass="form-control form-control-sm border-0"
            accept=".png,.jpg,.jpeg" />
    </div>
</div>

<asp:HiddenField ID="hfIsNewCourse" runat="server" Value="0" />

<script>
    function toggleNewCourse() {
        var existing = document.getElementById('existingCourseDiv');
        var newDiv = document.getElementById('newCourseDiv');
        var btn = document.getElementById('btnToggleCourse');
        if (newDiv.style.display === 'none') {
            newDiv.style.display = 'block';
            existing.style.display = 'none';
            document.getElementById('<%= hfIsNewCourse.ClientID %>').value = '1';
            btn.innerHTML = '<i class="fa-solid fa-arrow-left"></i> Back to existing';
        } else {
            newDiv.style.display = 'none';
            existing.style.display = 'block';
            document.getElementById('<%= hfIsNewCourse.ClientID %>').value = '0';
            btn.innerHTML = '<i class="fa-solid fa-plus"></i> New Course';
        }
    }

    function toggleCustomCategory(sel) {
        var custom = document.getElementById('<%= txtCustomCategory.ClientID %>');
        custom.style.display = (sel.value === 'Other') ? 'inline-block' : 'none';
    }

    function confirmCourseDelete() {
        var ddl = document.getElementById('<%= ddlCourses.ClientID %>');
        var courseName = ddl.options[ddl.selectedIndex].text;
        if (!courseName || courseName === '-- Choose a Course --') return false;
        var input = prompt("WARNING: Deleting this course will also delete ALL lessons inside it!\n\nTo confirm, type the course name exactly: '" + courseName.trim() + "'");
        if (input === null) return false;
        if (input !== courseName.trim()) {
            alert("Delete Cancelled: The course name you entered did not match.");
            return false;
        }
        return true;
    }
</script>