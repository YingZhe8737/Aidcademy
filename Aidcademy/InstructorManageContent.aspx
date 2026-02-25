<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InstructorManageContent.aspx.cs" Inherits="Aidcademy.InstructorManageContent" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Instructor Dashboard - Aidcademy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        
        <nav class="navbar navbar-expand-lg bg-brand-red py-3 shadow-sm">
            <div class="container">
                <a class="navbar-brand text-white" href="#">
                    <i class="fa-solid fa-truck-medical me-2"></i>AIDCADEMY
                </a>
                <div class="collapse navbar-collapse justify-content-end">
                    <ul class="navbar-nav">
                        <li class="nav-item"><a class="nav-link fw-bold" href="InstructorManageContent.aspx">Dashboard</a></li>
                        <li class="nav-item"><a class="nav-link" href="InstructorUploadLesson.aspx">Upload Content</a></li>
                        <li class="nav-item"><a class="nav-link" href="RespondQuestions.aspx">Q&A</a></li>
                        <li class="nav-item"><a class="nav-link" href="InstructorProfile.aspx">Profile</a></li>
                        <li class="nav-item"><a class="nav-link" href="Login_signup.aspx">Logout</a></li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="container mt-5">
            <div class="card welcome-card shadow-sm p-4 mb-5">
                <h3 class="fw-bold">Welcome back, Ying Zhe! 👋</h3>
                <p class="text-muted mb-4">Manage your first aid learning materials and student interactions.</p>

                <div class="row text-center g-3">
                    <div class="col-md-3">
                        <div class="card stat-card shadow-sm p-3">
                            <i class="fa-solid fa-book-medical stat-icon"></i>
                            <h4 class="mb-0 fw-bold"><asp:Label ID="lblTotal" runat="server" Text="0"></asp:Label></h4>
                            <small>Total Lessons</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card shadow-sm p-3">
                            <i class="fa-solid fa-clock-rotate-left stat-icon"></i>
                            <h4 class="mb-0 fw-bold"><asp:Label ID="lblPending" runat="server" Text="0"></asp:Label></h4>
                            <small>Pending Approval</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card shadow-sm p-3">
                            <i class="fa-solid fa-circle-check stat-icon"></i>
                            <h4 class="mb-0 fw-bold"><asp:Label ID="lblPublished" runat="server" Text="0"></asp:Label></h4>
                            <small>Published Content</small>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card stat-card shadow-sm p-3">
                            <i class="fa-solid fa-comments stat-icon"></i>
                            <h4 class="mb-0 fw-bold"><asp:Label ID="lblQueries" runat="server" Text="0"></asp:Label></h4>
                            <small>Member Queries</small>
                        </div>
                    </div>
                </div>
            </div>

            <h5 class="section-header">Manage Content</h5>
            
            <div class="row g-4">
                <div class="col-md-3">
                    <div class="card lesson-card shadow-sm">
                        <div class="lesson-card-top">
                            <i class="fa-solid fa-heart-pulse"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-bold">Basic CPR Steps</h6>
                            <p class="text-muted small mb-2">Category: Cardiac</p>
                            
                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <span class="badge bg-success">Approved</span>
                                <div>
                                    <asp:LinkButton ID="btnEdit1" runat="server" CssClass="btn btn-sm btn-outline-danger"><i class="fa-solid fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton ID="btnDel1" runat="server" CssClass="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-3">
                    <div class="card lesson-card shadow-sm">
                        <div class="lesson-card-top" style="background-color: #e0a800;">
                            <i class="fa-solid fa-bandage"></i>
                        </div>
                        <div class="card-body">
                            <h6 class="fw-bold">Wound Dressing</h6>
                            <p class="text-muted small mb-2">Category: Trauma</p>
                            
                            <div class="d-flex justify-content-between align-items-center mt-3">
                                <span class="badge bg-warning text-dark">Pending Admin</span>
                                <div>
                                    <asp:LinkButton ID="btnEdit2" runat="server" CssClass="btn btn-sm btn-outline-danger"><i class="fa-solid fa-pen"></i></asp:LinkButton>
                                    <asp:LinkButton ID="btnDel2" runat="server" CssClass="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-trash"></i></asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
    </form>
    
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>