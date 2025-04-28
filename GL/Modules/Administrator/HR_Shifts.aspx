<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HR_Shifts.aspx.cs" Inherits="PMS.HR_Shift" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript">



        $(document).ready(function () {
            $("#ctl00_MainContent_txtFromShift").ptTimeSelect({
                //popupImage: 'Select Time'
            });
            $("#ctl00_MainContent_txtToShift").ptTimeSelect({});
            $("#ctl00_MainContent_txtFromBreak").ptTimeSelect({});
            $("#ctl00_MainContent_txtToBreak").ptTimeSelect({});
        });




    </script>

    <style type="text/css">
        .mg {
            padding-left: 20px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table class="ui-accordion">
        <tr>
            <td>
                <asp:Label ID="Label1" runat="server" Text="Shift ID"></asp:Label>
            </td>
            <td style="width:220px;">
                <asp:TextBox ID="txtShift__ID" runat="server" ReadOnly="true"></asp:TextBox>
            </td>
            <td class="mg">
                <asp:Label ID="Label2" runat="server" Text="Shift Name *"></asp:Label>
            </td>
            <td style="width:202px;">
                <asp:TextBox ID="txtShiftName" runat="server"></asp:TextBox>
            </td>
            <td style="width:95px;">
                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" Display="Dynamic" Text="*" ErrorMessage="Shift Name Required" ControlToValidate="txtShiftName"></asp:RequiredFieldValidator>
            </td>
            <td class="mg"></td>
            <td></td>
            <td class="mg"></td>
            <td></td>
        </tr>
        <tr>
            <td colspan="9">
                <br />
            </td>
        </tr>
        <tr>
            <td></td>
            <td style="width:220px;">
                <asp:Label ID="Label3" runat="server" Font-Bold="True" Text="Shift Timing" Font-Size="Medium"></asp:Label>
            </td>
            <td class="mg"></td>
            <td style="width:202px;"></td>
            <td style="width:95px;"></td>
            <td class="mg"></td>
            <td>
                <asp:Label ID="Label8" runat="server" Text="Break Timing" Font-Bold="True" Font-Size="Medium"></asp:Label>
            </td>
            <td class="mg"></td>
            <td></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="Label4" runat="server" Text="From"></asp:Label>
            </td>
            <td style="width:220px;">
                <asp:TextBox ID="txtFromShift" runat="server"></asp:TextBox>
            </td>
            <td class="mg" align="right" style="padding-right:15px;">
                <asp:Label ID="Label5" runat="server" Text="To"></asp:Label>
            </td>
            <td style="width:202px;">
                <asp:TextBox ID="txtToShift" runat="server"></asp:TextBox>
            </td>
            <td style="width:95px;"></td>
            <td class="mg">
                <asp:Label ID="Label6" runat="server" Text="From"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtFromBreak" runat="server"></asp:TextBox>
            </td>
            <td class="mg">
                <asp:Label ID="Label7" runat="server" Text="To"></asp:Label>
            </td>
            <td>
                <asp:TextBox ID="txtToBreak" runat="server"></asp:TextBox>
            </td>
        </tr>
        <tr>
            <td></td>
            <td style="width:220px;">
                <br />
                <br />
                <asp:Button ID="btnBack" Width="95px" runat="server" Text="Back" CausesValidation="false" OnClick="btnBack_Click" />
                &nbsp;&nbsp;
                <asp:Button ID="btnSave" Width="95px" runat="server" Text="Save" OnClick="btnSave_Click" />
            </td>
            <td class="mg"></td>
            <td style="width:202px;">
                <asp:CheckBox ID="CheckBox1" runat="server" Text="Next Day Shift Out" />
            </td>
            <td style="width:95px;"></td>
            <td class="mg"></td>
            <td></td>
            <td class="mg"></td>
            <td></td>
        </tr>
        <tr>
            <td colspan="9">
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </td>
        </tr>
    </table>
</asp:Content>
