<%@ Page Title="Instructor Dashboard" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorManageContent.aspx.cs" Inherits="Aidcademy.InstructorManageContent" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <link href="Styles/Instructor.css" rel="stylesheet" type="text/css" />
    <style>
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 12px 24px rgba(201, 36, 43, 0.3) !important;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5 mb-5">
        
        <div class="card welcome-card shadow-sm p-4 mb-5">
            <h3 class="fw-bold">Welcome to Instructor Dashboard 👋</h3>
            <p class="text-muted mb-4">Manage your first aid learning materials and member interactions.</p>
            <div class="row g-4 mb-5">
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card shadow-sm">
                        <div class="stat-icon-box">
                            <i class="fa-solid fa-book-open"></i>
                        </div>
                        <div class="stat-text">
                            <span class="stat-label">Total Lessons</span>
                            <span class="stat-value"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></span>
                        </div>
                    </div>
                </div>
            
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card shadow-sm">
                        <div class="stat-icon-box">
                            <i class="fa-solid fa-clock-rotate-left"></i>
                        </div>
                        <div class="stat-text">
                            <span class="stat-label">Pending Admin</span>
                            <span class="stat-value"><asp:Label ID="lblPending" runat="server" Text="0"></asp:Label></span>
                        </div>
                    </div>
                </div>
            
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card shadow-sm">
                        <div class="stat-icon-box">
                            <i class="fa-solid fa-clipboard-check"></i>
                        </div>
                        <div class="stat-text">
                            <span class="stat-label">Published</span>
                            <span class="stat-value"><asp:Label ID="lblPublished" runat="server" Text="0"></asp:Label></span>
                        </div>
                    </div>
                </div>
            
                <div class="col-md-6 col-lg-3">
                    <div class="card stat-card shadow-sm">
                        <div class="stat-icon-box">
                            <i class="fa-solid fa-comments"></i> </div>
                        <div class="stat-text">
                            <span class="stat-label">Unanswered Queries</span>
                            <span class="stat-value"><asp:Label ID="lblQueries" runat="server" Text="0"></asp:Label></span>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-4 mt-5">
            <h5 class="fw-bold text-danger m-0"><i class="fa-solid fa-folder-tree me-2"></i>Course Curriculum</h5>
            
            <div class="dropdown">
                <button class="btn btn-danger fw-bold dropdown-toggle shadow-sm" type="button" data-bs-toggle="dropdown">
                    <i class="fa-solid fa-plus me-1"></i> Create
                </button>
                <ul class="dropdown-menu dropdown-menu-end shadow">
                    <li><a class="dropdown-item fw-bold text-dark py-2" href="InstructorUploadLesson.aspx"><i class="fa-solid fa-file-lines text-danger me-2"></i> New Lesson / Course</a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><a class="dropdown-item fw-bold text-dark py-2" href="InstructorUploadQuiz.aspx"><i class="fa-solid fa-clipboard-question text-warning me-2"></i> Manage Quizzes</a></li>
                </ul>
            </div>
        </div>

        <asp:Repeater ID="rptCourses" runat="server" OnItemDataBound="rptCourses_ItemDataBound">
            <ItemTemplate>
                <div class="category-group mb-5">
                    
                    <h4 class="fw-bold border-bottom pb-2 text-danger mb-3">
                        <i class="fa-solid fa-book-medical me-2"></i><%# Eval("CourseTitle") %> 
                        <span class="badge bg-secondary fs-6 ms-2 align-middle"><i class="fa-solid fa-tag me-1"></i><%# Eval("Category") %></span>
                    </h4>
                    
                    <div class="row g-4">
                        <asp:Repeater ID="rptLessons" runat="server">
                            <ItemTemplate>
                                <div class="col-md-4 col-lg-3">
                                    <div class='card lesson-card shadow-sm h-100 <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "status-Draft" : (Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "status-Pending" : "status-Published") %>'>
                                        
                                        <div class="card-body p-4 d-flex flex-column">
                                            
                                            <div class="d-flex justify-content-between align-items-start mb-3">
                                                <span class="badge bg-light text-secondary border px-2 py-1">
                                                    <i class="fa-solid fa-list-ol me-1"></i>Step <%# Eval("SequenceOrder") %>
                                                </span>
                                                
                                                <span class='badge <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "bg-secondary" : (Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "bg-warning text-dark" : "bg-success") %>'>
                                                    <%# Eval("ApprovalStatus") %>
                                                </span>
                                            </div>

                                            <h5 class="fw-bold text-dark mb-4 lh-base"><%# Eval("LessonTitle") %></h5>
                                            
                                            <div class="mt-auto d-flex justify-content-end gap-2 border-top pt-3">
                                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary" 
                                                    CommandArgument='<%# Eval("LessonID") %>' OnClick="btnEditLesson_Click" ToolTip="Edit Lesson">
                                                    <i class="fa-solid fa-pen"></i> Edit
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger" 
                                                    CommandArgument='<%# Eval("LessonID") %>' OnClick="btnDeleteLesson_Click"
                                                    data-lesson-title='<%# Eval("LessonTitle") %>'
                                                    OnClientClick="return confirmLessonDelete(this);" ToolTip="Delete Lesson">
                                                    <i class="fa-solid fa-trash"></i>
                                                </asp:LinkButton>
                                            </div>

                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
        
    </div>

    <script>
        function confirmLessonDelete(btn) {
            var lessonName = btn.getAttribute('data-lesson-title');
            var input = prompt("To delete this lesson, type its name exactly: " + lessonName.trim());
            if (input === null) return false;

            if (input !== lessonName.trim()) {
                alert("Delete Cancelled: The lesson name you entered did not match.");
                return false;
            }
            return true;
            return input === lessonName.trim();
        }
    </script>
</asp:Content>