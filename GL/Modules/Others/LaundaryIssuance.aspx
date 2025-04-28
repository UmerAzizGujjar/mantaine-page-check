<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaundaryIssuance.aspx.cs" Inherits="PMS.LaundaryIssuance" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript">

        $(document).ready(function () {
            $("#ctl00_MainContent_txtIssue_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtIssue_Time").ptTimeSelect({});
            chkIssueTo_Select();
        });

        function chkIssueTo_Select() {
            var Issue_To = document.getElementById('<%= ddlIssue_To.ClientID%>').value;

            if (Issue_To == 0) {
                document.getElementById('<%= ddlRoom_No.ClientID%>').value = 0;
                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;

                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = true;
                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;

                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";

                var roomValidation = document.getElementById('<%= rfvRoom_No.ClientID %>');
                ValidatorEnable(roomValidation, false);
                var wardValidation = document.getElementById('<%= rfvWard_No.ClientID %>');
                ValidatorEnable(wardValidation, false);
            }
            else if (Issue_To == '001') {
                document.getElementById('<%= ddlRoom_No.ClientID%>').value = 0;

                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = false;
                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = true;

                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroudWhite";

                var roomValidation = document.getElementById('<%= rfvRoom_No.ClientID %>');
                ValidatorEnable(roomValidation, false);
                var wardValidation = document.getElementById('<%= rfvWard_No.ClientID %>');
                ValidatorEnable(wardValidation, true);
            }
            else {
                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;

                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = false;
                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;

                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroudWhite";
                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";

                var roomValidation = document.getElementById('<%= rfvRoom_No.ClientID %>');
                ValidatorEnable(roomValidation, true);
                var wardValidation = document.getElementById('<%= rfvWard_No.ClientID %>');
                ValidatorEnable(wardValidation, false);
            }
        }
    </script>
    <style>
        .dropdownBackgroud {
            background-color:#f5f5f5 !important;
        }
        .dropdownBackgroudWhite {
            background-color:#fff !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 835px;">
        <tr>
            <td style="width:103px;">
                <asp:Label ID="lblLaundary_Issuance_ID" runat="server" Text="Issuance ID"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox runat="server" ID="txtLaundary_Issuance_ID" ReadOnly="true" Text="(New)" />
            </td>
            <td style="width:67px;"></td>
            <td style="width:83px;">
                <asp:Label ID="lblIssue_To" runat="server" Text="Issue To *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlIssue_To" runat="server" AppendDataBoundItems="true" onChange="chkIssueTo_Select()" ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvIssue_To" ControlToValidate="ddlIssue_To" InitialValue="0" runat="server" ErrorMessage="Select Issue To" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRoom_No" runat="server" Text="Room_No *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlRoom_No" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvRoom_No" ControlToValidate="ddlRoom_No" InitialValue="0" runat="server" ErrorMessage="Select Room No." Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblWard_No" runat="server" Text="Ward_No *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlWard_No" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvWard_No" ControlToValidate="ddlWard_No" InitialValue="0" runat="server" ErrorMessage="Select Ward No." Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblLaundary_Item" runat="server" Text="Laundary Item *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlLaundary_Item" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvLaundary_Item" ControlToValidate="ddlLaundary_Item" InitialValue="0" runat="server" ErrorMessage="Select Laundary Item" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblQuantity" runat="server" Text="Quantity *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtQuantity" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvQuantity" ControlToValidate="txtQuantity" runat="server" ErrorMessage="Enter Quantity" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngQuantity" Type="Integer" runat="server" MinimumValue="0" MaximumValue="999999999" ControlToValidate="txtQuantity" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblIssue_Date" runat="server" Text="Issue Date *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtIssue_Date" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvIssue_Date" ControlToValidate="txtIssue_Date" runat="server" ErrorMessage="Enter Issue Date" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblIssue_Time" runat="server" Text="Issue Time *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtIssue_Time" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvIssue_Time" ControlToValidate="txtIssue_Time" runat="server" ErrorMessage="Enter Issue Time" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/LaundaryIssuanceView.aspx" />
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
