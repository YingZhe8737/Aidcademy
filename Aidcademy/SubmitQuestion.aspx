<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Member.Master" CodeBehind="SubmitQuestion.aspx.cs" Inherits="Aidcademy.SubmitQuestion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">Ask a Question - Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="member-container" style="max-width:1000px;">
        <div class="page-header centered">
            <h1><i class="fas fa-comments" style="color:#dc2626;"></i> Ask a Question</h1>
            <p>Get help from instructors about your courses</p>
        </div>

        <div class="submit-card">
            <h2 style="margin-bottom:20px; color:#1f2937; font-size:1.2rem; font-weight:700;">Submit New Question</h2>

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
                    placeholder="Type your question here..." Rows="5"></asp:TextBox>
                <asp:RequiredFieldValidator runat="server" ControlToValidate="txtQuestion"
                    ErrorMessage="Please enter your question" ForeColor="Red" Display="Dynamic"
                    ValidationGroup="Question" />
            </div>

            <asp:Button ID="btnSubmitQuestion" runat="server" Text="Submit Question" CssClass="btn-submit"
                OnClick="btnSubmitQuestion_Click" ValidationGroup="Question" />
        </div>

        <div class="question-list">
            <h2 style="margin-bottom:20px; color:#1f2937; font-size:1.2rem; font-weight:700;">My Questions</h2>

            <asp:Panel ID="pnlNoQuestions" runat="server" Visible="false" CssClass="empty-state">
                <i class="fas fa-question-circle"></i>
                <p>You haven't asked any questions yet</p>
            </asp:Panel>

            <asp:Repeater ID="rptQuestions" runat="server">
                <ItemTemplate>
                    <div class="question-item">
                        <div class="question-header">
                            <span class="question-course"><%# Eval("CourseName") %></span>
                            <span class='question-status <%# "status-" + Eval("Status").ToString().ToLower() %>'>
                                <%# Eval("Status") %>
                            </span>
                        </div>
                        <p class="question-text">
                            <strong>Q:</strong> <%# Eval("QuestionText") %>
                        </p>
                        <p class="question-meta">
                            Status: <strong><%# Eval("Status") %></strong>
                        </p>

                        <%# Eval("InstructorResponse") != DBNull.Value &&
                                !string.IsNullOrEmpty(Eval("InstructorResponse").ToString())
                                ? "<div class='response-box'><div class='response-label'>Instructor Response:</div><p>"
                                + Eval("InstructorResponse") + "</p>" + (Eval("ResponseDate") != DBNull.Value
                                ? "<p class='question-meta'>Responded on " +
                                Convert.ToDateTime(Eval("ResponseDate")).ToString("MMM dd, yyyy") + "</p>" : "")
                                + "</div>" : "" %>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>
</asp:Content>
