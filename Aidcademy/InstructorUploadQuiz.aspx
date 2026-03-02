<%@ Page Title="Manage Quiz" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorUploadQuiz.aspx.cs" Inherits="Aidcademy.InstructorUploadQuiz" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .quiz-container { max-width: 900px; margin: 40px auto; }
        .builder-card { background: #fff; border-radius: 12px; border: 1px solid #e0e0e0; padding: 30px; margin-bottom: 25px; box-shadow: 0 4px 6px rgba(0,0,0,0.02); }
        .step-badge { background: #c9242b; color: white; width: 30px; height: 30px; display: inline-flex; align-items: center; justify-content: center; border-radius: 50%; font-weight: bold; margin-right: 10px; }
        
        .question-item { background: #f8f9fa; border: 1px solid #e0e0e0; border-radius: 8px; padding: 20px; margin-bottom: 15px; position: relative; }
        .correct-answer-highlight { background-color: #d1e7dd; border-color: #badbcc; font-weight: bold; color: #0f5132; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="quiz-container">
        
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h3 class="fw-bold m-0"><i class="fa-solid fa-clipboard-question text-danger me-2"></i>Quiz Builder</h3>
            <a href="InstructorManageContent.aspx" class="btn btn-outline-secondary btn-sm"><i class="fa-solid fa-arrow-left me-1"></i>Back to Dashboard</a>
        </div>

        <asp:Label ID="lblMessage" runat="server" CssClass="d-block mb-4 fw-bold"></asp:Label>

        <div class="builder-card">
            <h5 class="fw-bold border-bottom pb-3 mb-4"><span class="step-badge">1</span>Select Target Lesson</h5>
            
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold text-muted small text-uppercase">1. Select Course</label>
                    <asp:DropDownList ID="ddlCourses" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlCourses_SelectedIndexChanged"></asp:DropDownList>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label fw-bold text-muted small text-uppercase">2. Select Lesson</label>
                    <asp:DropDownList ID="ddlLessons" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlLessons_SelectedIndexChanged" Enabled="false">
                        <asp:ListItem Text="-- Select Course First --" Value=""></asp:ListItem>
                    </asp:DropDownList>
                </div>
            </div>
        </div>

        <asp:Panel ID="pnlQuizSetup" runat="server" Visible="false" CssClass="builder-card border-danger border-2">
            <h5 class="fw-bold border-bottom pb-3 mb-4"><span class="step-badge">2</span>Quiz Details</h5>
            <div class="input-group mb-3">
                <span class="input-group-text bg-light fw-bold">Quiz Title</span>
                <asp:TextBox ID="txtQuizTitle" runat="server" CssClass="form-control" placeholder="e.g., Knowledge Check: Infant CPR"></asp:TextBox>
                <asp:Button ID="btnSaveQuizTitle" runat="server" Text="Save Quiz Title" CssClass="btn btn-danger fw-bold px-4" OnClick="btnSaveQuizTitle_Click" />
            </div>
            <asp:HiddenField ID="hfQuizID" runat="server" Value="0" />
        </asp:Panel>
        <asp:Panel ID="pnlQuestionBuilder" runat="server" Visible="false">
            
            <asp:HiddenField ID="hfEditQuestionID" runat="server" Value="0" />

            <div class="builder-card bg-light border-warning">
                <h5 class="fw-bold border-bottom pb-3 mb-4"><span class="step-badge bg-warning text-dark">3</span><asp:Label ID="lblFormTitle" runat="server" Text="Add a Question"></asp:Label></h5>
                
                <div class="mb-3">
                    <label class="form-label fw-bold">Question Text</label>
                    <asp:TextBox ID="txtNewQuestion" runat="server" CssClass="form-control shadow-none border-secondary" placeholder="What is the correct ratio of compressions to breaths?"></asp:TextBox>
                </div>
                
                <div class="row g-3 mb-3">
                    <div class="col-md-6">
                        <div class="input-group"><span class="input-group-text fw-bold">A</span><asp:TextBox ID="txtOptA" runat="server" CssClass="form-control"></asp:TextBox></div>
                    </div>
                    <div class="col-md-6">
                        <div class="input-group"><span class="input-group-text fw-bold">B</span><asp:TextBox ID="txtOptB" runat="server" CssClass="form-control"></asp:TextBox></div>
                    </div>
                    <div class="col-md-6">
                        <div class="input-group"><span class="input-group-text fw-bold">C</span><asp:TextBox ID="txtOptC" runat="server" CssClass="form-control"></asp:TextBox></div>
                    </div>
                    <div class="col-md-6">
                        <div class="input-group"><span class="input-group-text fw-bold">D</span><asp:TextBox ID="txtOptD" runat="server" CssClass="form-control"></asp:TextBox></div>
                    </div>
                </div>

                <div class="d-flex justify-content-between align-items-center mt-4 border-top pt-3">
                    <div class="d-flex align-items-center gap-2">
                        <label class="fw-bold text-success mb-0"><i class="fa-solid fa-check-circle me-1"></i>Correct Answer:</label>
                        <asp:DropDownList ID="ddlCorrectAnswer" runat="server" CssClass="form-select border-success text-success fw-bold w-auto">
                            <asp:ListItem Value="A">Option A</asp:ListItem>
                            <asp:ListItem Value="B">Option B</asp:ListItem>
                            <asp:ListItem Value="C">Option C</asp:ListItem>
                            <asp:ListItem Value="D">Option D</asp:ListItem>
                        </asp:DropDownList>
                    </div>
                    <div>
                        <asp:Button ID="btnCancelEdit" runat="server" Text="Cancel" CssClass="btn btn-secondary fw-bold me-2" OnClick="btnCancelEdit_Click" Visible="false" />
                        <asp:Button ID="btnAddQuestion" runat="server" Text="+ Add Question to Quiz" CssClass="btn btn-warning fw-bold" OnClick="btnAddQuestion_Click" />
                    </div>
                </div>
            </div>

            <h5 class="fw-bold mb-3 mt-5"><i class="fa-solid fa-list-check me-2 text-danger"></i>Questions in this Quiz</h5>
            <asp:Repeater ID="rptQuestions" runat="server" OnItemCommand="rptQuestions_ItemCommand">
                <ItemTemplate>
                    <div class="question-item shadow-sm">
                        
                        <div class="position-absolute top-0 end-0 m-3">
                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditQ" CommandArgument='<%# Eval("QuestionID") %>' 
                                CssClass="btn btn-sm btn-outline-primary me-1" ToolTip="Edit Question">
                                <i class="fa-solid fa-pen"></i>
                            </asp:LinkButton>
                            
                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteQ" CommandArgument='<%# Eval("QuestionID") %>' 
                                CssClass="btn btn-sm btn-outline-danger" OnClientClick="return confirm('Delete this question?');" ToolTip="Delete Question">
                                <i class="fa-solid fa-trash"></i>
                            </asp:LinkButton>
                        </div>
                        
                        <h5 class="fw-bold mb-3 pe-5"><%# Container.ItemIndex + 1 %>. <%# Eval("QuestionText") %></h5>
                        <ul class="list-group list-group-flush">
                            <li class='list-group-item <%# Eval("CorrectAnswer").ToString() == "A" ? "correct-answer-highlight" : "" %>'><strong>A)</strong> <%# Eval("OptionA") %></li>
                            <li class='list-group-item <%# Eval("CorrectAnswer").ToString() == "B" ? "correct-answer-highlight" : "" %>'><strong>B)</strong> <%# Eval("OptionB") %></li>
                            <li class='list-group-item <%# Eval("CorrectAnswer").ToString() == "C" ? "correct-answer-highlight" : "" %>'><strong>C)</strong> <%# Eval("OptionC") %></li>
                            <li class='list-group-item <%# Eval("CorrectAnswer").ToString() == "D" ? "correct-answer-highlight" : "" %>'><strong>D)</strong> <%# Eval("OptionD") %></li>
                        </ul>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

        </asp:Panel>
    </div>
</asp:Content>