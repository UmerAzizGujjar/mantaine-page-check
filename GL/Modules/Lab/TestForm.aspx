<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TestForm.aspx.cs" Inherits="PMS.TestForm" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <script type="text/javascript" src="Scripts/jquery-1.9.1.min.js"></script>

</head>
<body>
    <form id="form1" runat="server">
        <asp:TextBox runat="server" ID="txtPassword" /><asp:PasswordRecovery ID="PasswordRecovery1" runat="server">
            <MailDefinition>
                
            </MailDefinition>
                                                       </asp:PasswordRecovery>
        <asp:Button Text="Get Password" ID="btnGetPassword" OnClick="btnGetPassword_Click" runat="server" />
    </form>
</body>
</html>
