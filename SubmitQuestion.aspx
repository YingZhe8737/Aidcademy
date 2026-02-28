<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SubmitQuestion.aspx.cs" Inherits="Aidcademy.SubmitQuestion" %>

    <!DOCTYPE html>
    <html>

    <head runat="server">
        <title>Submit Question - Aidcademy</title>
        <style>
            * {
                margin: 0;
                padding: 0;
                box-sizing: border-box;
            }

            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                background: linear-gradient(to bottom right, #fef2f2 0%, #ffffff 50%, #eff6ff 100%);
                min-height: 100vh;
            }

            .navbar {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                padding: 15px 30px;
                color: white;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .navbar h1 {
                font-size: 24px;
            }

            .navbar a {
                color: white;
                text-decoration: none;
                padding: 8px 15px;
            }

            .container {
                max-width: 1000px;
                margin: 30px auto;
                padding: 0 20px;
            }

            .page-header {
                text-align: center;
                margin-bottom: 40px;
            }

            .submit-card {
                background: white;
                border-radius: 12px;
                padding: 30px;
                margin-bottom: 30px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }

            .form-group {
                margin-bottom: 20px;
            }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
            }

            .form-group select,
            .form-group textarea {
                width: 100%;
                padding: 12px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-family: inherit;
            }

            .form-group textarea {
                min-height: 120px;
                resize: vertical;
            }

            .btn {
                padding: 12px 30px;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                color: white;
                border: none;
                border-radius: 8px;
                font-size: 16px;
                font-weight: 600;
                cursor: pointer;
            }

            .btn:hover {
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
            }

            .question-list {
                background: white;
                border-radius: 12px;
                padding: 30px;
                box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            }

            .question-item {
                border-left: 4px solid #667eea;
                padding: 20px;
                background: #f8f9fa;
                margin-bottom: 15px;
                border-radius: 0 8px 8px 0;
            }

            .question-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 10px;
                flex-wrap: wrap;
            }

            .question-course {
                color: #667eea;
                font-weight: 600;
            }

            .question-status {
                padding: 5px 12px;
                border-radius: 15px;
                font-size: 12px;
                font-weight: 600;
            }

            .status-pending {
                background: #fff3cd;
                color: #856404;
            }

            .status-answered {
                background: #d4edda;
                color: #155724;
            }

            .question-text {
                color: #333;
                margin-bottom: 10px;
                line-height: 1.6;
            }

            .question-meta {
                color: #666;
                font-size: 14px;
            }

            .response-box {
                margin-top: 15px;
                padding: 15px;
                background: white;
                border-left: 4px solid #28a745;
                border-radius: 0 8px 8px 0;
            }

            .response-label {
                color: #28a745;
                font-weight: 600;
                margin-bottom: 8px;
            }

            .message {
                padding: 12px;
                border-radius: 8px;
                margin-bottom: 20px;
                text-align: center;
            }

            .message.success {
                background: #d4edda;
                color: #155724;
            }

            .message.error {
                background: #f8d7da;
                color: #721c24;
            }

            .empty-state {
                text-align: center;
                padding: 40px;
                color: #666;
            }
        </style>
    </head>

    <body>
        <form id="form1" runat="server">
            <div class="navbar">
                <h1>🏥 AIDCADEMY</h1>
                <div>
                    <asp:HyperLink runat="server" NavigateUrl="~/MemberDashboard.aspx">Dashboard</asp:HyperLink>
                    <asp:HyperLink runat="server" NavigateUrl="~/MemberProfile.aspx">Profile</asp:HyperLink>
                </div>
            </div>

            <div class="container">
                <div class="page-header">
                    <h1>Ask a Question</h1>
                    <p>Get help from instructors about your courses</p>
                </div>

                <div class="submit-card">
                    <h2 style="margin-bottom: 20px; color: #333;">Submit New Question</h2>

                    <asp:Panel ID="pnlMessage" runat="server" Visible="false" CssClass="message">
                        <asp:Label ID="lblMessage" runat="server"></asp:Label>
                    </asp:Panel>

                    <div class="form-group">
                        <label>Select Course *</label>
                        <asp:DropDownList ID="ddlCourses" runat="server"></asp:DropDownList>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="ddlCourses" InitialValue="0"
                            ErrorMessage="Please select a course" ForeColor="Red" Display="Dynamic"
                            ValidationGroup="Question" />
                    </div>

                    <div class="form-group">
                        <label>Your Question *</label>
                        <asp:TextBox ID="txtQuestion" runat="server" TextMode="MultiLine"
                            placeholder="Type your question here..."></asp:TextBox>
                        <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestion"
                            ErrorMessage="Please enter your question" ForeColor="Red" Display="Dynamic"
                            ValidationGroup="Question" />
                    </div>

                    <asp:Button ID="btnSubmitQuestion" runat="server" Text="Submit Question" CssClass="btn"
                        OnClick="btnSubmitQuestion_Click" ValidationGroup="Question" />
                </div>

                <div class="question-list">
                    <h2 style="margin-bottom: 20px; color: #333;">My Questions</h2>

                    <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false" CssClass="empty-state">
                        <div style="font-size: 48px; margin-bottom: 15px;">❓</div>
                        <p>You haven't asked any questions yet</p>
                    </asp:Panel>

                    <asp:Repeater ID="rptQuestions" runat="server">
                        <ItemTemplate>
                            <div class="question-item">
                                <div class="question-header">
                                    <span class="question-course">
                                        <%# Eval("CourseName") %>
                                    </span>
                                    <span
                                        class='question-status <%# "status-" + Eval("Status").ToString().ToLower() %>'>
                                        <%# Eval("Status") %>
                                    </span>
                                </div>
                                <p class="question-text"><strong>Q:</strong>
                                    <%# Eval("QuestionText") %>
                                </p>
                                <p class="question-meta">Status: <strong>
                                        <%# Eval("Status") %>
                                    </strong></p>

                                <%# Eval("InstructorResponse") !=DBNull.Value &&
                                    !string.IsNullOrEmpty(Eval("InstructorResponse").ToString())
                                    ? "<div class='response-box'><div class='response-label'>Instructor Response:</div><p>"
                                    + Eval("InstructorResponse") + "</p>" + (Eval("ResponseDate") !=DBNull.Value
                                    ? "<p class='question-meta'>Responded on " +
                                    Convert.ToDateTime(Eval("ResponseDate")).ToString("MMM dd, yyyy") + "</p>" : "" )
                                    + "</div>" : "" %>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </form>
    </body>

    </html>