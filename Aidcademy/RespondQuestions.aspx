<%@ Page Title="Student Q&A" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="RespondQuestions.aspx.cs" Inherits="Aidcademy.RespondQuestions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <style>
        .qa-container {
            max-width: 900px;
            margin: 40px auto;
        }

        .page-header {
            border-bottom: 2px solid #e0e0e0;
            padding-bottom: 15px;
            margin-bottom: 30px;
        }

        .question-card {
            background: #fff;
            border-radius: 12px;
            border: 1px solid #e0e0e0;
            margin-bottom: 20px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.02);
            overflow: hidden;
        }

        .question-header {
            background-color: #f8f9fa;
            padding: 15px 20px;
            border-bottom: 1px solid #e0e0e0;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .question-body {
            padding: 20px;
        }

        .course-badge {
            font-size: 0.8rem;
            background-color: #e0f2fe;
            color: #0284c7;
            padding: 5px 10px;
            border-radius: 6px;
            font-weight: bold;
        }

        .reply-box {
            background-color: #fef2f2;
            border: 1px solid #fecaca;
            border-radius: 8px;
            padding: 15px;
            margin-top: 15px;
        }

        .empty-state {
            text-align: center;
            padding: 50px 20px;
            color: #6c757d;
        }

            .empty-state i {
                font-size: 3rem;
                color: #dee2e6;
                margin-bottom: 15px;
            }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="qa-container">

        <div class="page-header d-flex justify-content-between align-items-end">
            <div>
                <h3 class="fw-bold text-dark m-0"><i class="fa-solid fa-comments text-danger me-2"></i>Q&A</h3>
                <p class="text-muted m-0 mt-1">Respond to questions from members taking your courses.</p>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-3 fw-bold"></asp:Label>

        <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand">
            <ItemTemplate>

                <div class='card mb-4 shadow-sm <%# Eval("Status").ToString() == "Open" ? "border-danger border-2" : "border-light border-1 opacity-75" %>'>

                    <div class="card-header bg-white d-flex justify-content-between align-items-center py-3">
                        <div>
                            <span class="badge bg-light text-dark border me-2"><i class="fa-solid fa-book-medical text-danger me-1"></i><%# Eval("CourseTitle") %></span>

                            <small class="fw-bold">
                                <a href='Profile.aspx?UserID=<%# Eval("UserID") %>' class="text-secondary text-decoration-none border-bottom border-secondary pb-1">
                                    <i class="fa-solid fa-user me-1"></i><%# Eval("MemberUsername") %>
                                </a>
                            </small>
                        </div>

                        <span class='badge <%# Eval("Status").ToString() == "Open" ? "bg-danger" : "bg-success" %>'>
                            <%# Eval("Status").ToString() == "Open" ? "Action Required" : "Answered" %>
                        </span>
                    </div>

                    <div class="card-body p-4">
                        <h5 class='mb-3 <%# Eval("Status").ToString() == "Open" ? "fw-bold text-dark" : "text-muted" %>'>Q: <%# Eval("QuestionText") %>
                        </h5>

                        <asp:Panel ID="pnlReplyForm" runat="server" Visible='<%# Eval("Status").ToString().Trim().ToUpper() == "OPEN" %>'>
                            <div class="bg-light p-3 rounded border mt-4">
                                <label class="form-label fw-bold text-danger"><i class="fa-solid fa-reply me-1"></i>Draft Your Reply</label>
                                <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control mb-3 shadow-none" placeholder="Type your expert explanation here..."></asp:TextBox>

                                <div class="text-end">
                                    <asp:Button ID="btnSubmitReply" runat="server" Text="Publish Reply" CssClass="btn btn-danger fw-bold px-4"
                                        CommandName="SubmitReply" CommandArgument='<%# Eval("QuestionID") %>' />
                                </div>
                            </div>
                        </asp:Panel>

                        <asp:Panel ID="pnlAnswerHistory" runat="server" Visible='<%# Eval("Status").ToString() == "Answered" %>'>
                            <div class="bg-success bg-opacity-10 border border-success border-opacity-25 p-3 rounded mt-3">
                                <div class="d-flex justify-content-between mb-2">
                                    <span class="fw-bold text-success"><i class="fa-solid fa-check-double me-1"></i>Instructor Reply</span>
                                    <small class="text-success"><%# Eval("ResponseDate", "{0:MMM dd, yyyy 'at' hh:mm tt}") %></small>
                                </div>
                                <p class="mb-0 text-dark"><%# Eval("InstructorResponse") %></p>
                            </div>
                        </asp:Panel>

                    </div>
                </div>

            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false" CssClass="empty-state">
            <i class="fa-solid fa-mug-hot"></i>
            <h4 class="fw-bold text-dark">You're all caught up!</h4>
            <p>There are currently no unanswered questions from your members.</p>
        </asp:Panel>

    </div>
</asp:Content>
