<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ShiftAssign.aspx.cs" Inherits="PMS.ShiftAssign" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>

    <script type="text/javascript">
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtFrom_Date").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#ctl00_MainContent_txtTo_Date").datepicker({ dateFormat: 'mm/dd/yy' });

                var n_charges = document.getElementById('<%= txtNursing_Charges.ClientID %>').value;
                var room_n = document.getElementById('<%= txtRoom_No.ClientID %>').value;
                var patient = document.getElementById('<%= txtPatient_No.ClientID %>').value;

                if (n_charges != "" || room_n != "" || patient != "") {
                    rdo_false();
                }
                else
                {
                    rdo_true();
                }

            });
        });

        function enabledisable() {
            var value = document.getElementById('<%= ddlAssigned_To.ClientID %>').selectedIndex;
            if (value == "1") {
                
                rdo_false();
            }

            if (value == "0") {
                rdo_true();
            }
        }

        function rdo_true() {
            document.getElementById('<%= txtNursing_Charges.ClientID %>').readOnly = true;
            document.getElementById('<%= txtNursing_Charges.ClientID %>').value = "";

            document.getElementById('<%= txtRoom_No.ClientID %>').readOnly = true;
            document.getElementById('<%= txtRoom_No.ClientID %>').value = "";

            document.getElementById('<%= txtPatient_No.ClientID %>').readOnly = true;
            document.getElementById('<%= txtPatient_No.ClientID %>').value = "";
        }

        function rdo_false() {
            document.getElementById('<%= txtNursing_Charges.ClientID %>').readOnly = false;
            document.getElementById('<%= txtRoom_No.ClientID %>').readOnly = false;
            document.getElementById('<%= txtPatient_No.ClientID %>').readOnly = false;
        }

    </script>

    <style type="text/css">
        .mg {
            padding-left: 35px;
           
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table style="padding: 20px; width: 670px; height: 204px;">

        <tr>
            <td>
                <asp:Label ID="lblShift_Assign_ID" runat="server" Text="Nurse Shift ID"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtShift_Assign_ID" runat="server" ReadOnly="true" Text="(New)"></asp:TextBox>
            </td>
            <td>
            </td>
            <td class="mg">
                <asp:Label ID="lblDuty_Type" runat="server" Text="Duty Type"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:DropDownList ID="ddlDuty_Type" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblFrom_Date" runat="server" Text="From Date *"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtFrom_Date" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFrom_Date" runat="server" ControlToValidate="txtFrom_Date" Text="*" ErrorMessage="Enter From Date"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblTo_Date" runat="server" Text="To Date *"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtTo_Date" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvTo_Date" runat="server" ControlToValidate="txtTo_Date" Text="*" ErrorMessage="Enter To Date"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblEmployee" runat="server" Text="Nurse *"></asp:Label>

            </td>
            <td style="width: 204px;">
                <asp:DropDownList ID="ddlEmployee" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvEmployee" runat="server" InitialValue="0" ControlToValidate="ddlEmployee" Text="*" ErrorMessage="Select Employee"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblShiftName" runat="server" Text="Shift *"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:DropDownList ID="ddlShiftName" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvShiftName" runat="server" InitialValue="0" ControlToValidate="ddlShiftName" Text="*" ErrorMessage="Select Shift Name"></asp:RequiredFieldValidator>
            </td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblAssigned_To" runat="server" Text="Assigned To"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:DropDownList ID="ddlAssigned_To" runat="server" onchange="enabledisable();" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblNursing_Charges" runat="server" Text="Nursing Charges"></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtNursing_Charges" runat="server"></asp:TextBox>
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRoom_No" runat="server" Text="Room No."></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtRoom_No" runat="server"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblPatient_No" runat="server" Text="Patient No."></asp:Label>
            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtPatient_No" runat="server"></asp:TextBox>
            </td>
            <td></td>
        </tr>

        <tr>
            <td>
                <asp:Label ID="lblRemark" runat="server" Text="Remark "></asp:Label>

            </td>
            <td style="width: 204px;">
                <asp:TextBox ID="txtRemark" TextMode="MultiLine" runat="server"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg"></td>
            <td style="width: 204px;"></td>
            <td></td>
        </tr>
        <tr>
            <td></td>
            <td style="width: 204px;">
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/ShiftView.aspx" />
                &nbsp;
                <asp:Button ID="btnSave" Width="95px" runat="server" Text="Save" OnClick="btnSave_Click" />
            </td>
            <td></td>
            <td class="mg"></td>
            <td style="width: 204px;"></td>
            <td></td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </td>
        </tr>
    </table>

</asp:Content>
