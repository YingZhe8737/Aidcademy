<%@ Page Title="My Progress" Language="C#" MasterPageFile="~/Member.Master" AutoEventWireup="true" CodeBehind="LearningProgress.aspx.cs" Inherits="Aidcademy.LearningProgress" %>

<asp:Content ID="TitleContent" ContentPlaceHolderID="TitleContent" runat="server">
    My Progress - Aidcademy
</asp:Content>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .container { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
        .page-header { text-align: center; margin-bottom: 40px; }
        .page-header h1 { color: #333; font-size: 32px; margin-bottom: 10px; }

        /* Progress Card */
        .progress-card { background: white; border-radius: 14px; padding: 28px; margin-bottom: 24px; box-shadow: 0 2px 12px rgba(0,0,0,0.09); position: relative; overflow: hidden; }
        .progress-card::before { content: ''; position: absolute; top: 0; left: 0; width: 5px; height: 100%; background: linear-gradient(to bottom, #dc2626, #fca5a5); border-radius: 14px 0 0 14px; }
        .progress-card.completed-card { border: 2px solid #28a745; }
        .progress-card.completed-card::before { background: linear-gradient(to bottom, #28a745, #86efac); }

        .progress-header { display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 16px; flex-wrap: wrap; gap: 10px; }
        .course-name { font-size: 21px; font-weight: 700; color: #222; }
        .status-badge { padding: 5px 16px; border-radius: 20px; font-size: 12px; font-weight: 700; text-transform: uppercase; letter-spacing: .5px; white-space: nowrap; }
        .status-completed { background: #d4edda; color: #155724; }
        .status-progress  { background: #cce5ff; color: #004085; }

        /* Info grid */
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(155px, 1fr)); gap: 14px; margin-top: 18px; }
        .info-item { background: #f8f9fa; border-radius: 10px; padding: 14px; text-align: center; }
        .info-value { font-size: 22px; font-weight: 700; color: #dc2626; }
        .info-label { font-size: 12px; color: #777; margin-top: 4px; }
        .info-item.highlight { background: linear-gradient(135deg,#fff5f5,#fee2e2); border: 1px solid #fca5a5; }

        /* Progress bar */
        .prog-bar-wrap { margin: 16px 0 4px; }
        .prog-bar-track { background: #e9ecef; height: 14px; border-radius: 7px; overflow: hidden; }
        .prog-bar-fill { background: linear-gradient(90deg,#dc2626,#b91c1c); height: 100%; transition: width .5s ease-in-out; border-radius: 7px; }
        .prog-pct { text-align: right; font-size: 13px; font-weight: 700; color: #dc2626; margin-top: 4px; }

        /* Rating stars */
        .rating-section { margin-top: 18px; padding-top: 16px; border-top: 1px solid #f0f0f0; }
        .rating-section h6 { font-weight: 700; color: #555; margin-bottom: 8px; font-size: 0.9rem; }
        .stars { display: flex; gap: 4px; }
        .star-btn { background: none; border: none; cursor: pointer; font-size: 1.6rem; color: #ddd; transition: color .15s; padding: 0; line-height: 1; }
        .star-btn.filled { color: #f59e0b; }
        .star-btn:hover, .star-btn:hover ~ .star-btn { color: #f59e0b; }

        /* Action buttons */
        .card-actions { margin-top: 18px; display: flex; gap: 10px; flex-wrap: wrap; }
        .btn-action { padding: 9px 22px; border-radius: 8px; font-weight: 600; font-size: 0.9rem; text-decoration: none; border: none; cursor: pointer; transition: all .2s; }
        .btn-continue-learning { background: linear-gradient(to right,#dc2626,#b91c1c); color: white; }
        .btn-continue-learning:hover { color: white; box-shadow: 0 4px 12px rgba(220,38,38,.4); }
        .btn-review { background: #f1f5ff; color: #3b5bdb; border: 1.5px solid #3b5bdb; }
        .btn-review:hover { background: #3b5bdb; color: white; }

        /* Empty state */
        .empty-state { text-align: center; padding: 60px 20px; background: white; border-radius: 14px; }
        .empty-state i { font-size: 64px; color: #ddd; margin-bottom: 20px; display: block; }

        @media(max-width:768px) {
            .progress-header { flex-direction: column; }
            .info-grid { grid-template-columns: 1fr 1fr; }
        }
    </style>
</asp:Content>

<asp:Content ID="MainContent" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <div class="page-header">
            <h1><i class="fas fa-chart-pie me-2 text-danger"></i>My Learning Progress</h1>
            <p style="color:#666;">Track your journey through first aid courses</p>
        </div>

        <asp:Panel ID="pnlNoProgress" runat="server" Visible="false" CssClass="empty-state">
            <i class="fas fa-book"></i>
            <h3>No Enrolled Courses Yet</h3>
            <p style="color:#666; margin:15px 0;">Start learning by enrolling in a course</p>
            <a href="LearningCourse.aspx" class="btn-action btn-continue-learning">Browse Courses</a>
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

                    <!-- Progress bar -->
                    <div class="prog-bar-wrap">
                        <div class="prog-bar-track">
                            <div class="prog-bar-fill" style='<%# String.Format("width:{0}%", Eval("ProgressPercentage")) %>'></div>
                        </div>
                    </div>
                    <div class="prog-pct"><%# Eval("ProgressPercentage", "{0:F0}")%>% Complete</div>

                    <!-- Info grid -->
                    <div class="info-grid">
                        <div class="info-item highlight">
                            <div class="info-value"><%# Eval("EnrollmentDate", "{0:MMM dd, yyyy}")%></div>
                            <div class="info-label">Enrolled Date</div>
                        </div>
                        <div class="info-item highlight">
                            <div class="info-value" style="font-size:14px;"><%# Eval("EnrollmentDate", "{0:hh:mm tt}")%></div>
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
                            ? "<div class='info-item highlight'><div class='info-value' style='font-size:14px;color:#28a745;'>" + Convert.ToDateTime(Eval("CompletionDate")).ToString("MMM dd, yyyy") + "</div><div class='info-label'>Completed On</div></div>"
                            : "" %>
                    </div>

                    <!-- Rating -->
                    <div class="rating-section">
                        <h6><i class="fas fa-star me-1 text-warning"></i>Rate This Course</h6>
                        <div class="stars" data-courseid='<%# Eval("CourseID") %>'>
                            <%# BuildStars(Eval("CourseID"), Eval("MyRating")) %>
                        </div>
                        <div id="ratingMsg_<%# Eval("CourseID") %>" style="font-size:0.8rem; color:#28a745; margin-top:4px; min-height:18px;"></div>
                    </div>

                    <!-- Actions -->
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
        // Star rating via AJAX-style fetch
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.stars').forEach(function (starsDiv) {
                var courseId = starsDiv.getAttribute('data-courseid');
                var btns = starsDiv.querySelectorAll('.star-btn');

                // Hover preview
                btns.forEach(function (btn, idx) {
                    btn.addEventListener('mouseenter', function () {
                        btns.forEach(function (b, i) { b.style.color = i <= idx ? '#f59e0b' : '#ddd'; });
                    });
                    btn.addEventListener('mouseleave', function () {
                        btns.forEach(function (b) { b.style.color = b.classList.contains('filled') ? '#f59e0b' : '#ddd'; });
                    });
                    btn.addEventListener('click', function () {
                        var rating = idx + 1;
                        // Submit rating
                        var form = new FormData();
                        form.append('CourseID', courseId);
                        form.append('Rating', rating);

                        fetch('SaveCourseRating.ashx', { method: 'POST', body: form })
                            .then(function (r) { return r.text(); })
                            .then(function () {
                                btns.forEach(function (b, i) {
                                    b.classList.toggle('filled', i < rating);
                                    b.style.color = i < rating ? '#f59e0b' : '#ddd';
                                });
                                var msg = document.getElementById('ratingMsg_' + courseId);
                                if (msg) { msg.innerText = 'Thanks for your rating!'; setTimeout(function(){msg.innerText='';}, 3000); }
                            })
                            .catch(function () { /* silently ignore if handler not deployed yet */ });
                    });
                });
            });
        });
    </script>
</asp:Content>
