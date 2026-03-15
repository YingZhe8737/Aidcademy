<%@ Page Title="My Progress" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="LearningProgress.aspx.cs" Inherits="Aidcademy.LearningProgress" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    My Progress - Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="member-container">
        <asp:HiddenField ID="hfCurrentUserId" runat="server" />
        <div class="page-header centered">
            <h1><i class="fas fa-chart-pie" style="color:#dc2626;"></i> My Learning Progress</h1>
            <p>Track your journey through first aid courses</p>
        </div>

        <asp:Panel ID="pnlNoProgress" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-book"></i>
            <h3>No Enrolled Courses Yet</h3>
            <p>Start learning by enrolling in a course</p>
            <a href="LearningCourse.aspx" class="btn-action btn-continue-learning" style="display:inline-block; margin-top:16px;">Browse Courses</a>
        </asp:Panel>

        <asp:Repeater ID="rptProgress" runat="server" OnItemCommand="rptProgress_ItemCommand">
            <ItemTemplate>
                <div class='progress-card <%# Eval("Status").ToString() == "Completed" ? "completed-card" : "" %>'>

                    <%# Eval("Status").ToString() == "Completed"
                        ? "<span class='position-absolute top-0 end-0 m-3 badge bg-success px-3 py-2 shadow-sm'><i class='fa-solid fa-check-circle me-1'></i>Completed!</span>" : "" %>

                    <div class="progress-header mt-1">
                        <h3 class="course-name"><%# Eval("CourseName") %></h3>
                        <span class='status-badge <%# Eval("Status").ToString() == "Completed" ? "status-completed" : "status-progress" %>'>
                            <%# Eval("Status") %>
                        </span>
                    </div>

                    <div class="prog-bar-wrap">
                        <div class="prog-bar-track">
                            <div class="prog-bar-fill" data-progress='<%# Eval("ProgressPercentage", "{0:F0}") %>' style="width:0;"></div>
                        </div>
                    </div>
                    <div class="prog-pct"><%# Eval("ProgressPercentage", "{0:F0}")%>% Complete</div>

                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-value"><%# Eval("EnrollmentDate", "{0:MMM dd, yyyy}")%></div>
                            <div class="info-label">Enrolled Date</div>
                        </div>
                        <div class="info-item">
                            <div class="info-value time"><%# Eval("EnrollmentDate", "{0:hh:mm tt}")%></div>
                            <div class="info-label">Enrolled Time</div>
                        </div>
                        <div class="info-item">
                            <div class="info-value"><%# Eval("CompletedLessons") %>/<%# Eval("TotalLessons") %></div>
                            <div class="info-label">Lessons Done</div>
                        </div>
                        <div class="info-item">
                            <div class="info-value"><%# Convert.ToInt32(Eval("AvgQuizScore")) == -1 ? "N/A" : Eval("AvgQuizScore", "{0:F0}") %></div>
                            <div class="info-label">Avg Quiz XP</div>
                        </div>
                        <%# Eval("CompletionDate") != DBNull.Value
                            ? "<div class='info-item'><div class='info-value' style='font-size:14px;color:#22c55e;'>" + Convert.ToDateTime(Eval("CompletionDate")).ToString("MMM dd, yyyy") + "</div><div class='info-label'>Completed On</div></div>"
                            : "" %>
                    </div>

                    <div class="rating-section">
                        <h6><i class="fas fa-star me-1" style="color:#f59e0b;"></i>Rate Lessons (up to 5)</h6>
                        <%# BuildLessonRatings(Eval("CourseID")) %>
                    </div>

                    <div class="card-actions">
                        <%# Eval("Status").ToString() != "Completed"
                            ? "<a href='" + GetContinueUrl(Eval("NextLessonID")) + "' class='btn-action btn-continue-learning'><i class='fas fa-arrow-right me-1'></i>Continue Learning</a>"
                            : "<a href='LearningCourse.aspx' class='btn-action btn-review'><i class='fas fa-book me-1'></i>Browse More Courses</a>" %>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Content>

<asp:Content ID="ScriptContent" ContentPlaceHolderID="ScriptContent" runat="server">
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.prog-bar-fill').forEach(function (bar) {
                var pct = parseInt(bar.getAttribute('data-progress') || '0', 10);
                if (isNaN(pct)) pct = 0;
                if (pct < 0) pct = 0;
                if (pct > 100) pct = 100;
                setTimeout(function () { bar.style.width = pct + '%'; }, 100);
            });

            var userId = document.getElementById('<%= hfCurrentUserId.ClientID %>').value || '0';

            function paint(btns, rating) {
                btns.forEach(function (b, i) {
                    b.classList.toggle('filled', i < rating);
                    b.style.color = i < rating ? '#f59e0b' : '#d1d5db';
                });
            }

            document.querySelectorAll('.lesson-stars').forEach(function (starsDiv) {
                var lessonId = starsDiv.getAttribute('data-lessonid');
                var storageKey = 'aidcademy.lesson.rating.' + userId + '.' + lessonId;
                var btns = starsDiv.querySelectorAll('.star-btn');

                var saved = parseInt(localStorage.getItem(storageKey) || '0', 10);
                if (saved > 0) paint(btns, saved);

                btns.forEach(function (btn, idx) {
                    btn.addEventListener('mouseenter', function () {
                        btns.forEach(function (b, i) { b.style.color = i <= idx ? '#f59e0b' : '#d1d5db'; });
                    });
                    btn.addEventListener('mouseleave', function () {
                        btns.forEach(function (b) { b.style.color = b.classList.contains('filled') ? '#f59e0b' : '#d1d5db'; });
                    });
                    btn.addEventListener('click', function () {
                        var rating = idx + 1;
                        localStorage.setItem(storageKey, String(rating));
                        paint(btns, rating);
                        var msg = document.getElementById('lessonRatingMsg_' + lessonId);
                        if (msg) { msg.innerText = 'Saved'; setTimeout(function () { msg.innerText = ''; }, 1800); }
                    });
                });
            });
        });
    </script>
</asp:Content>
