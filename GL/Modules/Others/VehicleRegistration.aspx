<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VehicleRegistration.aspx.cs" Inherits="PMS.VehicleRegistration" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .mg {
            padding-left: 80px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="padding: 20px; width: 720px; height: 204px;">
        <tr>
            <td>
                <asp:Label ID="lblVehicle_Code" runat="server" Text="Vehicle Code *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtVehicle_Code" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator1" runat="server" ControlToValidate="txtVehicle_Code" Text="*" ErrorMessage="Enter Vehicle Code"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblVIN" runat="server" Text="VIN *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtVIN" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator2" runat="server" ControlToValidate="txtVIN" Text="*" ErrorMessage="Enter Vehicle Insurance No."></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblRegistration_No" runat="server" Text="Registration No *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtRegistration_No" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator3" runat="server" ControlToValidate="txtRegistration_No" Text="*" ErrorMessage="Enter Reg. No."></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblRegistration_State" runat="server" Text="Registration State *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtRegistration_State" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator4" runat="server" ControlToValidate="txtRegistration_State" Text="*" ErrorMessage="Enter Reg. State"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblEngine_No" runat="server" Text="Engine No *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtEngin_No" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator5" runat="server" ControlToValidate="txtEngin_No" Text="*" ErrorMessage="Enter Engine No."></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblColor" runat="server" Text="Color *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtColor" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator10" runat="server" ControlToValidate="txtColor" Text="*" ErrorMessage="Enter Color"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblVehicle_Type" runat="server" Text="Vehicle Type *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:DropDownList ID="ddlVehicle_Type" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator6" runat="server" InitialValue="0" ControlToValidate="ddlVehicle_Type" Text="*" ErrorMessage="Select Vehicle Type"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblTotal_Seats" runat="server" Text="Total Seats *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtTotal_Seats" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator7" runat="server" ControlToValidate="txtTotal_Seats" Text="*" ErrorMessage="Enter Total Seats"></asp:RequiredFieldValidator>
                <asp:RegularExpressionValidator ID="reValidator1" ControlToValidate="txtTotal_Seats" runat="server" ValidationExpression="^\d+$" Text="*" ErrorMessage="Enter Valid No."></asp:RegularExpressionValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblMake" runat="server" Text="Make *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtMake" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator8" runat="server" ControlToValidate="txtMake" Text="*" ErrorMessage="Enter Make"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblModel" runat="server" Text="Model *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtModel" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rvValidator9" runat="server" ControlToValidate="txtModel" Text="*" ErrorMessage="Enter Model"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblImage" runat="server" Text="Image"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:FileUpload ID="img_Upload" Width="205px" runat="server" />
            </td>
            <td>

            </td>
            <td class="mg">
                
            </td>
            <td style="width: 205px;">
                
            </td>
            <td></td>
        </tr>


        <tr>
            <td></td>
            <td style="width: 205px;">
                <br />
                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/VehicleView.aspx" />
                <%--&nbsp;&nbsp;
                <asp:Button ID="btnClear" runat="server" Text="Reset" CausesValidation="false" OnClick="btnClear_Click" />--%>
                &nbsp;
                <asp:Button ID="btnSave" Width="95px" runat="server" Text="Save" OnClick="btnSave_Click" />
            </td>
            <td></td>
            <td class="mg"></td>
            <td style="width: 205px;"></td>
            <td></td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" runat="server"></asp:Label>
            </td>
        </tr>
        <tr>
            <td colspan="6">
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </td>
        </tr>
    </table>
</asp:Content>
