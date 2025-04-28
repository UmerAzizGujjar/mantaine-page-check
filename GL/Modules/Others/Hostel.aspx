<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Hostel.aspx.cs" Inherits="PMS.Hospital" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <table style="padding: 20px; width: 700px; height: 204px;">
        <tr>
            <td>
                <asp:Label ID="lblHostel_ID" runat="server" Text="Hostel ID"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtHostel_ID" runat="server" ReadOnly="true"></asp:TextBox>
            </td>
            <td style="width:70px;"></td>
            <td></td>
            <td style="width:204px;"></td>
            <td></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblHostel_No" runat="server" Text="Hostel No. *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtHostel_No" runat="server"></asp:TextBox>
            </td>
            <td style="width:70px;">
                <asp:RequiredFieldValidator ID="rfvHostel_No" runat="server" ControlToValidate="txtHostel_No" Display="Dynamic" ErrorMessage="Hostel No. is Required" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngHostel_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtHostel_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
            <td>
                <asp:Label ID="lblName" runat="server" Text="Name"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtName" runat="server"></asp:TextBox>
            </td>
            <td></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblBuilding_Type" runat="server" Text="Building Type"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlBuildingType" runat="server" AppendDataBoundItems="true" Width="167px">
                </asp:DropDownList>
            </td>
            <td style="width:70px;"></td>
            <td>
                <asp:Label ID="lblHostelType" runat="server" Text="Hostel Type"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlHostelType" runat="server" AppendDataBoundItems="true" Width="167px">
                </asp:DropDownList>
            </td>
            <td></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblFloor" runat="server" Text="No. of Floors *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtFloor" runat="server"></asp:TextBox>
            </td>
            <td style="width:70px;">
                <asp:RequiredFieldValidator ID="rfvFloor" runat="server" ControlToValidate="txtFloor" Display="Dynamic" Text="*" ErrorMessage="No. of Floors Required"></asp:RequiredFieldValidator>
            </td>
            <td>
                <asp:Label ID="lblRooms" runat="server" Text="No. of Rooms *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtRooms" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvRooms" runat="server" ControlToValidate="txtRooms" Display="Dynamic" Text="*" ErrorMessage="No. of Rooms Required"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rngRooms" runat="server" MinimumValue="0" MaximumValue="9999999999999999999999" Display="Dynamic" ControlToValidate="txtRooms" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblLocation" runat="server" Text="Location"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:TextBox ID="txtLocation" runat="server"></asp:TextBox>
            </td>
            <td style="width:70px;"></td>
            <td>
                <asp:Label ID="lblWarden" runat="server" Text="Warden *"></asp:Label>
            </td>
            <td style="width:204px;">
                <asp:DropDownList ID="ddlWarden" runat="server" AppendDataBoundItems="true" Width="167px">
                </asp:DropDownList>   
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvWarden" runat="server" ControlToValidate="ddlWarden" Display="Dynamic" InitialValue="0" Text="*" ErrorMessage="Select Warden Name"></asp:RequiredFieldValidator>
            </td>
        </tr>
        <tr>
            <td></td>
            <td style="width:204px;">
                <br />
                <asp:Button ID="btnBack" Width="95px" runat="server" Text="Back" CausesValidation="false" OnClick="btnBack_Click" />
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
    </table>

</asp:Content>
