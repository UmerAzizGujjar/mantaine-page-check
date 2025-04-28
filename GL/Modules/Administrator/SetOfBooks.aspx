<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetOfBooks.aspx.cs" Inherits="PMS.SetOfBooks" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel runat="server" ID="pnlForm">
        <table style="padding: 20px; width: 450px; ">
            <tr>
                <td style="width: 100px; padding-left: 20px;">
                    <asp:Label Text="Book_ID" ID="lblBook_ID" runat="server" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtBook_ID" ReadOnly="true" />
                </td>
                <td></td>
            </tr>
            <tr>
                <td style="width: 100px; padding-left: 20px;">
                    <asp:Label Text="Name *" runat="server" ID="lblName" />
                </td>
                <td>
                    <asp:TextBox runat="server" ID="txtName" />
                </td>
                <td>
                    <asp:RequiredFieldValidator ErrorMessage="Name is required." ID="rfvName" SetFocusOnError="true" Display="Dynamic" CssClass="validation" ControlToValidate="txtName" runat="server" />
                </td>
            </tr>
            <tr style="width: 100px; padding-left: 20px;">
                <td></td>
                <td>
                     <br />
                    <asp:Button Text="Back" runat="server" Width="95px" ID="btnBack" CausesValidation="false" PostBackUrl="~/SetOfBookView.aspx" />
                    &nbsp;&nbsp;
                    <asp:Button Text="Save" ID="btnSave" Width="95px" runat="server" OnClick="btnSave_Click" />
                </td>
                <td></td>
            </tr>
            <tr>
                <td colspan="3">
                    <asp:Label ID="lblMessage" runat="server" />
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>
