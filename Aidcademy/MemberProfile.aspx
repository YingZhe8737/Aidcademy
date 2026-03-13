<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Member.Master" CodeBehind="MemberProfile.aspx.cs" Inherits="Aidcademy.MemberProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">My Profile - Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .profile-container {
            max-width: 900px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .profile-card {
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
        }
    </style>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-container">
        <div class="profile-card">
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
    </div>
</asp:Content>
