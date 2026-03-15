<%@ Page Language="C#" AutoEventWireup="true" MasterPageFile="~/Member.Master" CodeBehind="Profile.aspx.cs" Inherits="Aidcademy.MemberProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="TitleContent" runat="server">My Profile - Aidcademy</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-container">
        <div class="profile-card">
            <!-- Profile Header -->
            <div class="profile-header-section">
                <div style="margin-bottom:20px;">
                    <asp:Image ID="imgProfile" runat="server" CssClass="profile-image"
                        ImageUrl="~/images/default-avatar.png" AlternateText="Profile Photo" />
                </div>
                <h2 style="font-size:28px; margin-bottom:5px;">My Profile</h2>
                <p style="opacity:0.9; font-size:16px;">Manage your personal information</p>
            </div>

            <!-- Profile Content -->
            <div class="profile-content">
                <!-- Message Panel -->
                <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                    <asp:Label ID="lblMessage" runat="server" CssClass="message"></asp:Label>
                </asp:Panel>

                <!-- Profile Photo Upload -->
                <div class="section-title">Profile Photo</div>
                <div class="form-group" style="display:flex; align-items:center; gap:20px; flex-wrap:wrap;">
                    <asp:Image ID="imgProfilePreview" runat="server" CssClass="profile-image"
                        ImageUrl="~/images/default-avatar.png" AlternateText="Profile Photo"
                        Style="width:80px; height:80px; border-radius:50%; object-fit:cover; border:3px solid #dc2626;" />
                    <div>
                        <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png,.gif" />
                        <br />
                        <small style="color:#9ca3af; font-size:12px;">JPG, PNG or GIF - Max 2 MB</small>
                    </div>
                </div>

                <!-- Account Information -->
                <div class="section-title">Account Information</div>

                <div class="form-group">
                    <label>Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" Enabled="false" />
                    <small style="color:#9ca3af; font-size:12px;">Username cannot be changed</small>
                </div>

                <div class="form-group">
                    <label>Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                </div>

                <!-- Personal Information -->
                <div class="section-title" style="margin-top:36px;">Personal Information</div>

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
                    <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" placeholder="Tell us a little about yourself..." />
                </div>

                <!-- Change Password -->
                <div class="section-title" style="margin-top:36px;">Change Password</div>

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
                <div style="margin-top:30px;">
                    <asp:Button ID="btnUpdateProfile" runat="server" Text="Save Changes" CssClass="btn-primary-custom"
                        OnClick="btnUpdateProfile_Click" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
