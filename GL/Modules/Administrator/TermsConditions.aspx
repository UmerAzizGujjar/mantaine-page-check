<%@ Page Title="" ValidateRequest="false" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TermsConditions.aspx.cs" Inherits="PMS.TermsConditions" %>

<%@ Register Assembly="CKEditor.NET" Namespace="CKEditor.NET" TagPrefix="CKEditor" %>

<%--<%@ Register Assembly="Infragistics4.WebUI.WebHtmlEditor.v12.1, Version=12.1.20121.2236, Culture=neutral, PublicKeyToken=7dd5c3163f2cd0cb" Namespace="Infragistics.WebUI.WebHtmlEditor" TagPrefix="ighedit" %>--%>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server"> </asp:Content>
 
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 
<script src="<%= Page.ResolveClientUrl("~/Scripts/ckeditor/ckeditor.js")%>" type="text/javascript"></script>
    
<script type="text/javascript">

    $(function () {

        CKEDITOR.replace('<%=txtTerm_Description.ClientID %>', { filebrowserImageUploadUrl: '/Upload.ashx' });

    });

</script>


    <table border="0" cellpadding="0" cellspacing="4">

        <tr>
            <td>ID
            </td>
            <td>
                <asp:TextBox runat="server" ID="txtTerm_ID" ReadOnly="true" Text="(New)" />
            </td>
        </tr>


        <tr>
            <td>Name
            </td>
            <td>
                <asp:TextBox ID="txtTerm_Name" runat="server" />
                <asp:RequiredFieldValidator ErrorMessage="Name is required." ControlToValidate="txtTerm_Name" CssClass="validation"
                    ID="rfvTerm_Name" SetFocusOnError="true" runat="server" Display="Dynamic" />
            </td>
        </tr>

        <tr></tr>

        <tr>
            <td>
                <p><asp:Label ID="Label1" runat="server" Text="Description"></asp:Label></p>
            </td>
            <td>
               
            <CKEditor:CKEditorControl ID="txtTerm_Description" BasePath="/ckeditor/" runat="server"></CKEditor:CKEditorControl>

            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/TermsConditionsView.aspx" />
                &nbsp;&nbsp;&nbsp;
                 <asp:Button Text="Save" runat="server" ID="btnSave" OnClick="btnSave_Click" />
            </td>
        </tr>

       <tr>
            <td colspan="2">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>

    </table>

</asp:Content>
