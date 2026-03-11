<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MemberProfile.aspx.cs" Inherits="Aidcademy.MemberProfile" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>My Profile - Aidcademy</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />
    <link rel="stylesheet" href="~/Styles/aidcademy-theme.css" />
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #FFFBF1;
            min-height: 100vh;
        }

        .navbar {
            background: linear-gradient(to right, #dc2626, #b91c1c);
            padding: 15px 30px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            color: white;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }

        .navbar-brand {
            font-size: 24px;
            font-weight: bold;
        }

        .navbar-menu {
            display: flex;
            gap: 20px;
            align-items: center;
        }

            .navbar-menu a {
                color: white;
                text-decoration: none;
                padding: 8px 15px;
                border-radius: 5px;
                transition: background 0.3s;
            }

                .navbar-menu a:hover,
                .navbar-menu .navbar-btn:hover {
                    background: rgba(255, 255, 255, 0.2);
                }

        .navbar-btn {
            color: white;
            background: none;
            border: none;
            font-size: 1rem;
            padding: 8px 15px;
            border-radius: 5px;
            cursor: pointer;
            transition: background 0.3s;
        }

        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }

        .profile-header {
            background: linear-gradient(to right, #dc2626, #b91c1c);
            padding: 40px;
            text-align: center;
            color: white;
        }

        .profile-image-container {
            margin-bottom: 20px;
        }

        .profile-image {
            width: 120px;
            height: 120px;
            border-radius: 50%;
            border: 5px solid white;
            object-fit: cover;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.2);
        }

        .profile-header h2 {
            font-size: 28px;
            margin-bottom: 5px;
        }

        .profile-header p {
            opacity: 0.9;
            font-size: 16px;
        }

        .profile-content {
            padding: 40px;
        }

        .section-title {
            font-size: 20px;
            color: #333;
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 2px solid #dc2626;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group {
            margin-bottom: 20px;
        }

            .form-group label {
                display: block;
                margin-bottom: 8px;
                color: #555;
                font-weight: 500;
                font-size: 14px;
            }

            .form-group input,
            .form-group textarea {
                width: 100%;
                padding: 12px 15px;
                border: 2px solid #e0e0e0;
                border-radius: 8px;
                font-size: 14px;
                transition: all 0.3s;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

                .form-group input:focus,
                .form-group textarea:focus {
                    outline: none;
                    border-color: #dc2626;
                    box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
                }

                .form-group input:disabled {
                    background-color: #f5f5f5;
                    cursor: not-allowed;
                }

        .btn-primary {
            padding: 14px 30px;
            background: linear-gradient(to right, #dc2626, #b91c1c);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
            width: 100%;
        }

            .btn-primary:hover {
                transform: translateY(-2px);
                box-shadow: 0 10px 20px rgba(220, 38, 38, 0.3);
            }

        .message {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 14px;
        }

            .message.success {
                background-color: #d4edda;
                color: #155724;
                border: 1px solid #c3e6cb;
            }

            .message.error {
                background-color: #f8d7da;
                color: #721c24;
                border: 1px solid #f5c6cb;
            }

        @media (max-width: 768px) {
            .form-row {
                grid-template-columns: 1fr;
            }

            .profile-content {
                padding: 20px;
            }

            .navbar {
                flex-direction: column;
                text-align: center;
                gap: 15px;
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <!-- Navigation Bar -->
        <div class="navbar">
            <div class="navbar-brand">
                <a href="MainPage.aspx" style="color: white; text-decoration: none; display: flex; align-items: center;">
                    <img src="Image/logo2.jpeg" alt="Aidcademy Logo" style="height: 40px; margin-right: 10px; border-radius: 5px;" />
                    AIDCADEMY
                </a>
            </div>
            <div class="navbar-menu">
                <asp:HyperLink ID="lnkDashboard" runat="server" NavigateUrl="~/MemberDashboard.aspx"><i class="fas fa-chart-line"></i> Dashboard</asp:HyperLink>
                <asp:HyperLink ID="lnkCourses" runat="server" NavigateUrl="~/LearningCourse.aspx"><i class="fas fa-book"></i> Courses</asp:HyperLink>
                <asp:HyperLink ID="lnkProgress" runat="server" NavigateUrl="~/LearningProgress.aspx"><i class="fas fa-chart-pie"></i> My Progress</asp:HyperLink>
                <asp:HyperLink ID="lnkAskQuestion" runat="server" NavigateUrl="~/SubmitQuestion.aspx"><i class="fas fa-comments"></i> Ask Question</asp:HyperLink>
                <asp:HyperLink ID="lnkProfile" runat="server" NavigateUrl="~/MemberProfile.aspx" CssClass="fw-bold text-white font-weight-bold"><i class="fas fa-user"></i> Profile</asp:HyperLink>
                <asp:LinkButton ID="btnLogout" runat="server" OnClick="btnLogout_Click" CssClass="navbar-btn"><i class="fas fa-sign-out-alt"></i> Logout</asp:LinkButton>
            </div>
        </div>
        <div class="container">
            <!-- Profile Header -->
            <div class="profile-header">
                <div class="profile-image-container">
                    <asp:Image ID="imgProfile" runat="server" CssClass="profile-image"
                        ImageUrl="~/images/default-avatar.png" AlternateText="Profile Photo" />
                </div>
                <h2>My Profile</h2>
                <p>Manage your personal information</p>
            </div>

            <!-- Profile Content -->
            <div class="profile-content">
                <!-- Message Panel -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                </asp:Panel>

                <!-- Profile Photo Upload -->
                <div class="section-title">Profile Photo</div>
                <div class="form-group" style="display: flex; align-items: center; gap: 20px; flex-wrap: wrap;">
                    <asp:Image ID="imgProfilePreview" runat="server" CssClass="profile-image"
                        ImageUrl="~/images/default-avatar.png" AlternateText="Profile Photo"
                        Style="width: 80px; height: 80px; border-radius: 50%; object-fit: cover; border: 3px solid #667eea;" />
                    <div>
                        <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png,.gif" />
                        <br />
                        <small style="color: #999; font-size: 12px;">JPG, PNG or GIF - Max 2 MB</small>
                    </div>
                </div>

                <!-- Account Information -->
                <div class="section-title">Account Information</div>

                <div class="form-group">
                    <label>Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" Enabled="false" />
                    <small style="color: #999; font-size: 12px;">Username cannot be changed</small>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                </div>

                <!-- Personal Information -->
                <div class="section-title" style="margin-top: 40px;">Personal Information</div>

                <div class="form-row">
                    <div class="form-group">
                        <label>First Name</label>
                        <asp:TextBox ID="txtFirstName" runat="server" placeholder="First name" />
                    </div>

                    <div class="form-group">
                        <label>Last Name</label>
                        <asp:TextBox ID="txtLastName" runat="server" placeholder="Last name" />
                    </div>
                </div>

                <div class="form-group">
                    <label>Phone Number</label>
                    <asp:TextBox ID="txtPhone" runat="server" placeholder="+60 12-345 6789" />
                </div>

                <div class="form-group">
                    <label>About Me (Bio)</label>
                    <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" placeholder="Tell us a little about yourself..." CssClass="form-control" />
                </div>

                <!-- Change Password -->
                <div class="section-title" style="margin-top: 40px;">Change Password</div>

                <div class="form-group">
                    <label>Current Password</label>
                    <asp:TextBox ID="txtCurrentPassword" runat="server" TextMode="Password" placeholder="Enter current password" />
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label>New Password</label>
                        <asp:TextBox ID="txtNewPassword" runat="server" TextMode="Password" placeholder="New password" />
                    </div>
                    <div class="form-group">
                        <label>Confirm New Password</label>
                        <asp:TextBox ID="txtConfirmNewPassword" runat="server" TextMode="Password" placeholder="Confirm new password" />
                    </div>
                </div>

                <!-- Action Buttons -->
                <div style="margin-top: 30px;">
                    <asp:Button ID="btnUpdateProfile" runat="server" Text="Save Changes" CssClass="btn-primary"
                        OnClick="btnUpdateProfile_Click" />
                </div>
            </div>
        </div>
    </form>
</body>

</html>
