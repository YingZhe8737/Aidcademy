<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FeedbackForm.aspx.cs" Inherits="Aidcademy.WebForm3" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link rel="stylesheet" href="~/Styles/CustomAdmin.css" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="signup-container">
            <div class="signup-card">

                <h1>We Appreciate Your Feedback!</h1>
                <p class="subtitle">Send us feedback for future improvement!</p>

                <div class="form-group">
                    <label>Category</label>
                      <asp:DropDownList ID="DropDownList1" runat="server" CssClass="form-input">
                      <asp:ListItem Text="Select Category" Value="" />
                      <asp:ListItem Text="Resources / Module" Value="Admin" />
                      <asp:ListItem Text="Web Design" Value="Instructor" />
                  </asp:DropDownList>
                </div>

                <div class="form-group">
                    <label>Feedback</label>
                    <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input" 
                        placeholder="Type Here..."></asp:TextBox>
                </div>

              

                <asp:Button ID="btnSubmit" runat="server" Text="Submit"
                    CssClass="btn-create" OnClick="btnSubmit_Click" />
                <asp:Label ID="lblMessage" runat="server" CssClass="form-input" EnableViewState="false"></asp:Label>

                <script>
                    window.onload = function () {
                        var msg = document.getElementById('<%= lblMessage.ClientID %>');
                        if (msg && msg.innerText.trim() !== '') {
                            setTimeout(function () {
                                msg.style.transition = 'opacity 0.5s ease';
                                msg.style.opacity = '0';
                                setTimeout(function () { msg.style.display = 'none'; }, 500);
                            }, 3000);
                        }
                    };
                </script>

            </div>
        </div>
    </form>
</body>
</html>
