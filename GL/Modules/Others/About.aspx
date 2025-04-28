<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="About.aspx.cs" Inherits="PMS.About" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
</asp:Content>
<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <script src="http://localhost:10129/Scripts/jquery.validate.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            $("#ctl00_MainContent_LinkButton1").click(function () {
             ("#aspnetForm").validate();
           //     alert("test");
            });
        });
    </script>

    <h2>
        About
    </h2>
    <p>
        Put content here.
    </p>
    <asp:TextBox ID="TextBox1" runat="server" CssClass="required"></asp:TextBox>
    <br />
    <asp:LinkButton ID="LinkButton1" runat="server">LinkButton</asp:LinkButton>
</asp:Content>
