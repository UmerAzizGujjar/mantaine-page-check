<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Assign_Hostel_Room.aspx.cs" Inherits="PMS.Assign_Hostel_Room" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">

        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtFrom_Date").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtTo_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 700px; height: 204px;">
        <tr>
            <td>
                <asp:Label ID="lblRoom_Assigned_ID" runat="server" Text="Allocation No."></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtRoom_Assigned_ID" runat="server" ReadOnly="true"></asp:TextBox>
            </td>
            <td style="width:70px;"></td>
            <td></td>
            <td style="width:204px;"></td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblHostel_ID" runat="server" Text="Hostel No. *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlHostel_ID" runat="server" AppendDataBoundItems="true" Width="167px"></asp:DropDownList>
            </td>
            <td style="width:70px;">
                <asp:RequiredFieldValidator ErrorMessage="Hostel No. is required." Text="*" ControlToValidate="ddlHostel_ID" ID="rfvHostel_ID" InitialValue="0" runat="server" />
            </td>
            <td>
                <asp:Label ID="lblFloor_No" runat="server" Text="Floor No. *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtFloor_No" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFloor_No" runat="server" ControlToValidate="txtFloor_No" Display="Dynamic" ErrorMessage="Floor No. is Required" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngFloor_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtFloor_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRoom_No" runat="server" Text="Room No. *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtRoom_No" runat="server"></asp:TextBox>
            </td>
            <td style="width:70px;">
                <asp:RequiredFieldValidator ID="rfvRoom_No" runat="server" ControlToValidate="txtRoom_No" Display="Dynamic" ErrorMessage="Room No. is Required" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngRoom_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtRoom_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
            <td>
                <asp:Label ID="lblAssigned_Employee" runat="server" Text="Assign to Employee *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlAssigned_Employee" runat="server" AppendDataBoundItems="true" Width="167px"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ErrorMessage="Employee is required." Text="*" ControlToValidate="ddlAssigned_Employee" ID="rfvAssigned_Employee" InitialValue="0" runat="server" />
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblFrom_Date" runat="server" Text="From"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtFrom_Date" runat="server"></asp:TextBox>
            </td>
            <td style="width:70px;"></td>
            <td>
                <asp:Label ID="lblTo_Date" runat="server" Text="To"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtTo_Date" runat="server"></asp:TextBox>
            </td>
            <td></td>
        </tr>
        
        <tr>
            <td></td>
            <td style="width:204px;">
                <br />
                <asp:Button ID="btnBack" Width="95px" runat="server" Text="Back" CausesValidation="false" PostBackUrl="~/Assign_Hostel_Room_View.aspx" />
                &nbsp;
                <asp:Button ID="btnSave" Width="95px" runat="server" Text="Save" OnClick="btnSave_Click" />
            </td>
            <td style="width:70px;"></td>
            <td></td>
            <td style="width:204px;"></td>
            <td></td>
        </tr>

        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                    ShowSummary="true" DisplayMode="List" />
            </td>
        </tr>
        <tr>
                <td colspan="6" style="width:100px;">
                    <asp:Label ID="lblMessage" Text="" runat="server" />
                </td>
            </tr>
    </table>
</asp:Content>
