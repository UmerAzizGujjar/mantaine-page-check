<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="CustomError.aspx.cs" Inherits="PMS.Modules.Others.CustomError" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Oops! Something went wrong</title>
    <style>
        body { font-family: Arial; text-align: center; padding: 50px; }
        h2 { color: #d9534f; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>We're sorry!</h2>
        <p>An unexpected error occurred. Please try again later.</p>
        <p><a href="~../../../../Modules/Dashboards/ShortCuts.aspx">Go back to homepage</a></p>
    </form>
</body>
</html>