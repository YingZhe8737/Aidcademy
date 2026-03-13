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
                    
                    <div class="card border-0 shadow-sm mb-4 mt-3 position-relative overflow-hidden rounded-4">
                        <div class="position-absolute top-0 start-0 h-100 bg-danger" style="width: 8px; z-index: 5;"></div>
                        
                        <div class="card-body p-4 d-flex align-items-center bg-white ms-2">
                            <img src='<%# Eval("CourseThumbnailPath") != DBNull.Value && !string.IsNullOrEmpty(Eval("CourseThumbnailPath").ToString()) ? ResolveUrl(Eval("CourseThumbnailPath").ToString()) : "Images/default-course.png" %>' class="rounded-3 shadow-sm me-4" style="width: 100px; height: 100px; object-fit: cover; border: 1px solid #dee2e6;" />
                            <div>
                                <h3 class="fw-bold text-dark mb-2">
                                    <%# Eval("CourseTitle") %> 
                                    <span class="badge bg-danger bg-opacity-10 text-danger border border-danger fs-6 ms-2 align-middle px-2 py-1"><i class="fa-solid fa-tag me-1"></i><%# Eval("Category") %></span>
                                </h3>
                                <p class="text-muted mb-0" style="font-size: 1rem; max-width: 900px;"><%# Eval("CourseDescription") %></p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="row g-4">
                        <asp:Repeater ID="rptLessons" runat="server">
                            <ItemTemplate>
                                <div class="col-md-4 col-lg-3 d-flex align-items-stretch">
                                    
                                    <div class='card lesson-card shadow-sm w-100 overflow-hidden border-0 border-start border-4 <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "border-secondary" : (Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "border-warning" : "border-success") %>'>
                                        
                                        <div class="bg-light position-relative" style="height: 180px;">
                                            <img src='<%# Eval("LessonThumbnailPath") != DBNull.Value && !string.IsNullOrEmpty(Eval("LessonThumbnailPath").ToString()) ? ResolveUrl(Eval("LessonThumbnailPath").ToString()) : "Images/default-lesson.png" %>' class="w-100 h-100 border-bottom" style="object-fit: cover;" alt="Lesson Thumbnail" />
                                        </div>

                                        <div class="card-body p-4 d-flex flex-column bg-white">
                                            <div class="d-flex justify-content-between align-items-start mb-3">
                                                <span class="badge bg-light text-dark border px-2 py-1 fw-bold">
                                                    <i class="fa-solid fa-list-ol me-1"></i>Step <%# Eval("SequenceOrder") %>
                                                </span>
                                                <span class='badge shadow-sm <%# Convert.ToString(Eval("ApprovalStatus")) == "Draft" ? "bg-secondary" : (Convert.ToString(Eval("ApprovalStatus")) == "Pending Admin" ? "bg-warning text-dark" : "bg-success") %>'>
                                                    <%# Eval("ApprovalStatus") %>
                                                </span>
                                            </div>

                                            <h5 class="fw-bold text-dark mb-2 lh-base" style="display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; min-height: 48px;">
                                                <%# Eval("LessonTitle") %>
                                            </h5>
                                            
                                            <p class="text-muted small mb-0 flex-grow-1" style="display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;"><%# Eval("LessonDescription") %></p>
                                        </div>

                                        <div class="card-footer bg-light border-top p-3 d-flex justify-content-end gap-2 mt-auto">
                                            <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn btn-sm btn-outline-primary fw-bold px-3" 
                                                CommandArgument='<%# Eval("LessonID") %>' OnClick="btnEditLesson_Click" ToolTip="Edit Lesson">
                                                <i class="fa-solid fa-pen me-1"></i> Edit
                                            </asp:LinkButton>
                                            
                                            <asp:LinkButton ID="btnDel" runat="server" CssClass="btn btn-sm btn-outline-danger fw-bold px-3" 
                                                CommandArgument='<%# Eval("LessonID") %>' OnClick="btnDeleteLesson_Click"
                                                data-lesson-title='<%# Eval("LessonTitle") %>'
                                                OnClientClick="return confirmLessonDelete(this);" ToolTip="Delete Lesson">
                                                <i class="fa-solid fa-trash"></i>
                                            </asp:LinkButton>
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