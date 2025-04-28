<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HouseKeeping.aspx.cs" Inherits="PMS.HouseKeeping" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">

        $(document).ready(function () {
            $("#ctl00_MainContent_txtFrom_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtTo_Date").datepicker({ dateFormat: 'mm/dd/yy' });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 835px;">
        <tr>
            <td style="width:111px;">
                <asp:Label ID="lblHouse_Keeping_ID" runat="server" Text="House Keeping ID"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox runat="server" ID="txtHouse_Keeping_ID" ReadOnly="true" Text="(New)" />
            </td>
            <td style="width:67px;"></td>
            <td style="width:99px;">
                <asp:Label ID="lblHouse_Keeper" runat="server" Text="House Keeper *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlHouse_Keeper" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvHouse_Keeper" ControlToValidate="ddlHouse_Keeper" InitialValue="0" runat="server" ErrorMessage="Select House Keeper" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblHouse_Keeping_Work_Type" runat="server" Text="Work Type *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlHouse_Keeping_Work_Type" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvHouse_Keeping_Work_Type" ControlToValidate="ddlHouse_Keeping_Work_Type" InitialValue="0" runat="server" ErrorMessage="Select Work Type" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblShift" runat="server" Text="Shift *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlShift" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvShift" ControlToValidate="ddlShift" InitialValue="0" runat="server" ErrorMessage="Select Shift" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblFrom_Date" runat="server" Text="From Date *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtFrom_Date" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFrom_Date" ControlToValidate="txtFrom_Date" runat="server" ErrorMessage="Enter From Date" Text="*"></asp:RequiredFieldValidator>
                <%--<asp:RangeValidator ID="rngFrom_Date" Type="Date" runat="server" ControlToValidate="txtFrom_Date" ErrorMessage="Enter proper format of From Date"  Text="*"></asp:RangeValidator>--%>
            </td>
            <td>
                <asp:Label ID="lblTo_Date" runat="server" Text="To Date *"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtTo_Date" runat="server" />
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvTo_Date" ControlToValidate="txtTo_Date" runat="server" ErrorMessage="Enter To Date" Text="*"></asp:RequiredFieldValidator>
                <%--<asp:RangeValidator ID="rngTo_Date" Type="Date" runat="server" ControlToValidate="txtTo_Date" ErrorMessage="Enter proper format of To Date"  Text="*"></asp:RangeValidator>--%>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblWorking_Area" runat="server" Text="Areas *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlWorking_Area" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvWorking_Area" ControlToValidate="ddlWorking_Area" InitialValue="0" runat="server" ErrorMessage="Select Working Area" Text="*"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblSupervisor" runat="server" Text="Supervisor *"></asp:Label>
            </td>
            <td>
                <asp:DropDownList ID="ddlSupervisor" runat="server" AppendDataBoundItems="true"  ></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvSupervisor" ControlToValidate="ddlSupervisor" InitialValue="0" runat="server" ErrorMessage="Select Supervisor" Text="*"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Height="75" />
            </td>
            <td>
                
            </td>
            <td>
                
            </td>
            <td>
                
            </td>
            <td>
                
            </td>
        </tr>

        <tr>
            <td></td>
            <td>
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/HouseKeepingView.aspx" />
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
