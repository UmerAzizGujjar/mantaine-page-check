<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IssueToLaundary.aspx.cs" Inherits="PMS.IssueToLaundary" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {
            $("#ctl00_MainContent_txtDate").datepicker({ dateFormat: 'mm/dd/yy' });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 835px;">
        <tr>
            <td style="width: 75px;">
                <asp:Label ID="lblIssue_To_Laundary_ID" runat="server" Text="Issuance ID"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox runat="server" ID="txtIssue_To_Laundary_ID" ReadOnly="true" Text="(New)" />
            </td>
            <td style="width: 67px;"></td>
            <td style="width: 103px;">
                <asp:Label ID="lblLaundary_Item" runat="server" Text="Laundary Item *"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:DropDownList ID="ddlLaundary_Item" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvLaundary_Item" ControlToValidate="ddlLaundary_Item" InitialValue="0" runat="server" ErrorMessage="Select Laundary Item" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblQuantity" runat="server" Text="Quantity *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtQuantity" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvQuantity" ControlToValidate="txtQuantity" runat="server" ErrorMessage="Enter Quantity" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngQuantity" Type="Integer" runat="server" MinimumValue="0" MaximumValue="99999999" ControlToValidate="txtQuantity" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
            </td>
            <td>
                <asp:Label ID="lblDate" runat="server" Text="Date *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtDate" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvDate" ControlToValidate="txtDate" runat="server" ErrorMessage="Enter Date" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/IssueToLaundaryView.aspx" />
                &nbsp;
                <asp:Button Text="Save" Width="95px" runat="server" ID="btnSave" OnClick="btnSave_Click" />
            </td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </td>
        </tr>

    </table>
</asp:Content>
