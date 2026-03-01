<%@ Page Title="Instructor Dashboard" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorManageContent.aspx.cs" Inherits="Aidcademy.InstructorManageContent" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .welcome-card { border-radius: 12px; border: 1px solid #e0e0e0; }
        .stat-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.05) !important; }
        .section-header { font-weight: bold; margin-bottom: 20px; color: #333; text-transform: uppercase; font-size: 14px; letter-spacing: 1px; }
        
        .lesson-card { 
            border-radius: 10px; 
            border: 1px solid #e0e0e0; 
            background: #fff;
            transition: all 0.2s ease-in-out;
        }
        .lesson-card:hover {
            box-shadow: 0 8px 15px rgba(0,0,0,0.05) !important;
            transform: translateY(-3px);
        }
        /* Dynamic Left Borders based on status */
        .status-Draft { border-left: 5px solid #6c757d; }
        .status-Pending { border-left: 5px solid #ffc107; }
        .status-Published { border-left: 5px solid #198754; }

        .stat-card { 
            border-radius: 12px; 
            border: none !important; 
            background: linear-gradient(135deg, #d32f2f 0%, #c9242b 100%) !important; 
            color: white !important;
            padding: 25px 20px; 
            transition: transform 0.2s; 
            display: flex;
            flex-direction: column; 
            align-items: center;    
            justify-content: center;
            text-align: center;     
            gap: 12px;              
            box-shadow: 0 4px 10px rgba(201, 36, 43, 0.2) !important;
        }
        .stat-card:hover { 
            transform: translateY(-4px); 
            box-shadow: 0 12px 24px rgba(201, 36, 43, 0.3) !important; 
        }
        
        .stat-icon-box { 
            width: 55px; 
            height: 55px; 
            border-radius: 12px; 
            display: flex; 
            align-items: center; 
            justify-content: center; 
            font-size: 1.6rem; 
            background-color: rgba(255, 255, 255, 0.15); 
            color: white;
        }
        
        .stat-text { 
            display: flex; 
            flex-direction: column; 
            align-items: center; 
        }
        .stat-label { 
            color: rgba(255, 255, 255, 0.85); 
            font-size: 0.8rem; 
            font-weight: 700; 
            text-transform: uppercase; 
            letter-spacing: 0.5px; 
            margin-bottom: 5px; 
        }
        .stat-value { 
            color: #ffffff; 
            font-size: 2rem; 
            font-weight: 900; 
            line-height: 1; 
        }
        </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container mt-5 mb-5">
        
        <div class="card welcome-card shadow-sm p-4 mb-5">
            <h3 class="fw-bold">Welcome to Instructor Dashboard 👋</h3>
            <p class="text-muted mb-4">Manage your first aid learning materials and student interactions.</p>
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
                            <span class="stat-label">Student Queries</span>
                            <span class="stat-value"><asp:Label ID="lblQueries" runat="server" Text="0"></asp:Label></span>
                        </div>
                    </div>
                </div>

            </div>
        </div>

<h5 class="section-header"><i class="fa-solid fa-folder-tree me-2 text-danger"></i>Course Curriculum</h5>

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
                                                    OnClientClick="return confirm('Are you sure you want to delete this lesson?');" ToolTip="Delete Lesson">
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
</asp:Content>