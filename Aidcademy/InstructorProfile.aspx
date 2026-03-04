<%@ Page Title="Instructor Profile" Language="C#" MasterPageFile="~/Instructor.Master" AutoEventWireup="true" CodeBehind="InstructorProfile.aspx.cs" Inherits="Aidcademy.InstructorProfile" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/aidcademy-theme.css" rel="stylesheet" type="text/css" />
    <style>
        .profile-container {
            max-width: 900px;
            margin: 40px auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
            overflow: hidden;
            border: 1px solid #e0e0e0;
        }

        .profile-header {
            background-color: #c9242b; /* Aidcademy Red */
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
            border: 4px solid white;
            object-fit: cover;
            box-shadow: 0 4px 10px rgba(0, 0, 0, 0.2);
            background-color: white;
        }

        .profile-header h2 { font-size: 28px; margin-bottom: 5px; font-weight: bold; }
        .profile-header p { opacity: 0.9; font-size: 16px; margin: 0; }

        .profile-content { padding: 40px; }

        .section-title {
            font-size: 18px;
            font-weight: bold;
            color: #333;
            margin-bottom: 25px;
            padding-bottom: 10px;
            border-bottom: 2px solid #f0f0f0;
            text-transform: uppercase;
            letter-spacing: 1px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }

        .form-group { margin-bottom: 20px; }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: bold;
            font-size: 13px;
            text-transform: uppercase;
        }

        .form-group input, .form-group textarea {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
            transition: border-color 0.3s;
        }

        .form-group input:focus, .form-group textarea:focus {
            outline: none;
            border-color: #c9242b;
            box-shadow: 0 0 0 3px rgba(201, 36, 43, 0.1);
        }

        .form-group input:disabled { background-color: #f9f9f9; cursor: not-allowed; }

        .btn-update {
            padding: 14px 30px;
            background-color: #c9242b;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            transition: background-color 0.2s;
            width: 100%;
        }

        .btn-update:hover { background-color: #a71d24; }

        .alert-box { padding: 15px; border-radius: 8px; margin-bottom: 25px; font-weight: bold; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-danger { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }

        @media (max-width: 768px) {
            .form-row { grid-template-columns: 1fr; }
            .profile-content { padding: 25px; }
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="profile-container">
        
        <div class="profile-header">
            <div class="profile-image-container">
                <asp:Image ID="imgProfile" runat="server" CssClass="profile-image" ImageUrl="~/images/default-avatar.png" />
            </div>
            <h2>Instructor Settings</h2>
            <p><i class="fa-solid fa-user-doctor me-1"></i> Manage your public educator profile</p>
        </div>

        <div class="profile-content">
            
            <asp:Panel ID="pnlMessage" runat="server" Visible="false">
                <asp:Label ID="lblMessage" runat="server" CssClass="alert-box d-block"></asp:Label>
            </asp:Panel>

            <div class="section-title"><i class="fa-solid fa-camera me-2 text-danger"></i>Profile Photo</div>
            <div class="form-group d-flex align-items-center gap-3 mb-4">
                <asp:Image ID="imgProfilePreview" runat="server" CssClass="profile-image" ImageUrl="~/images/default-avatar.png" style="width:70px; height:70px; border:2px solid #e0e0e0;" />
                <div>
                    <asp:FileUpload ID="fuProfilePhoto" runat="server" accept=".jpg,.jpeg,.png,.gif" CssClass="form-control form-control-sm w-auto" />
                    <small class="text-muted d-block mt-1">JPG, PNG or GIF. Max size 2MB.</small>
                </div>
            </div>

            <div class="section-title"><i class="fa-solid fa-lock me-2 text-danger"></i>Account Details</div>
            <div class="form-row">
                <div class="form-group">
                    <label>Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" Enabled="false" />
                    <small class="text-muted" style="font-size: 11px;">Cannot be changed</small>
                </div>
                <div class="form-group">
                    <label>Email Address</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" />
                </div>
            </div>

            <div class="section-title mt-4"><i class="fa-solid fa-address-card me-2 text-danger"></i>Public Identity</div>
            <div class="form-row">
                <div class="form-group">
                    <label>First Name</label>
                    <asp:TextBox ID="txtFirstName" runat="server" placeholder="Dr. John" />
                </div>
                <div class="form-group">
                    <label>Last Name</label>
                    <asp:TextBox ID="txtLastName" runat="server" placeholder="Doe" />
                </div>
            </div>
            
            <div class="form-group">
                <label>Phone Number (Optional)</label>
                <asp:TextBox ID="txtPhone" runat="server" placeholder="+60 12-345 6789" />
            </div>

            <div class="form-group">
                <label>Instructor Bio / Credentials</label>
                <asp:TextBox ID="txtBio" runat="server" TextMode="MultiLine" Rows="4" placeholder="Briefly describe your medical background and teaching experience..." />
                <small class="text-muted" style="font-size: 11px;">This will be visible to members taking your courses.</small>
            </div>

            <div class="mt-4">
                <asp:Button ID="btnUpdateProfile" runat="server" Text="Save Instructor Profile" CssClass="btn-update" OnClick="btnUpdateProfile_Click" />
            </div>
        </div>
    </div>
</asp:Content>