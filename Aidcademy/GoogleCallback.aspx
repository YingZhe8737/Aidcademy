<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="GoogleCallback.aspx.cs" Inherits="Aidcademy.GoogleCallback" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <meta charset="UTF-8" />
    <title>Signing in... - Aidcademy</title>
    <style>
        body {
            font-family: 'Segoe UI', sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            background: linear-gradient(to bottom right, #fef2f2, #ffffff, #eff6ff);
        }

        .spinner-box {
            text-align: center;
            color: #4b5563;
        }

        .spinner {
            width: 48px;
            height: 48px;
            border: 5px solid #f3f3f3;
            border-top: 5px solid #dc2626;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 20px;
        }

        @keyframes spin {
            to {
                transform: rotate(360deg);
            }
        }
    </style>
</head>

<body>
    <form id="form1" runat="server">
        <div class="spinner-box">
            <div class="spinner"></div>
            <p>Please wait, signing you in with Google...</p>
        </div>
    </form>
</body>

</html>
