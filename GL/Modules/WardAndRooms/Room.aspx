<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Room.aspx.cs" Inherits="PMS.Room" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .mg {
            padding-left: 53px;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table style="padding: 20px; width: 695px; height: 204px;">
        <tr>
            <td style="width:87px;">
                <asp:Label ID="lblRoom_ID" runat="server" Text="Room ID" Visible="false"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtRoom_ID" runat="server" ReadOnly="true" Visible="false"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                
            </td>
            <td style="width: 205px;">
                
            </td>
            <td style="width: 45px;">
                
            </td>
        </tr>
        
        <tr>
            <td>
                <asp:Label ID="lblRoom_No" runat="server" Text="Room No. *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtRoom_No" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvRoom_No" runat="server" ControlToValidate="txtRoom_No" Display="Dynamic" Text="*" ErrorMessage="Room No. is Required"></asp:RequiredFieldValidator>

                <asp:RangeValidator ID="rngRoom_No" runat="server" MinimumValue="0" MaximumValue="99999999999999999999" Display="Dynamic" ControlToValidate="txtRoom_No" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
            <td class="mg">
                <asp:Label ID="lblName" runat="server" Text="Room Name"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtName" runat="server"></asp:TextBox>

            </td>
            <td></td>
        </tr>
        <tr>
            
            <td>
                <asp:Label ID="lblBuilding_Type" runat="server" Text="Building Type"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:DropDownList ID="ddlBuildingType" runat="server" AppendDataBoundItems="true" Width="167px">
                </asp:DropDownList>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblFloor_No" runat="server" Text="Floor No. *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtFloorNo" runat="server"></asp:TextBox>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvFloor_No" runat="server" ControlToValidate="txtFloorNo" Text="*" Display="Dynamic" ErrorMessage="Floor No. Required"></asp:RequiredFieldValidator>

                <asp:RangeValidator ID="rngFloor_No" runat="server" MinimumValue="0" MaximumValue="999999999999999999999999" Display="Dynamic" ControlToValidate="txtFloorNo" Text="*" ErrorMessage="Only Enter Integer Value"></asp:RangeValidator>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblRoom_Type" runat="server" Text="Room Type *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:DropDownList ID="ddlRoomType" runat="server" AppendDataBoundItems="true" AutoPostBack="true" OnSelectedIndexChanged="ddlRoomType_SelectedIndexChanged" Width="167px">
                </asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvRoomType" runat="server" ControlToValidate="ddlRoomType" Display="Dynamic" InitialValue="0" Text="*" ErrorMessage="Select Room Type"></asp:RequiredFieldValidator>
            </td>
            <td class="mg">
                <asp:Label ID="LblRoom_Charges" runat="server" Text="Charges/Day *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:UpdatePanel ID="upCharges" runat="server" UpdateMode="Conditional">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlRoomType" EventName="SelectedIndexChanged" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:TextBox ID="txtRoom_Charges" runat="server"></asp:TextBox>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" runat="server" ControlToValidate="txtRoom_Charges" ErrorMessage="Enter Charges" Text="*"></asp:RequiredFieldValidator>
                <asp:RangeValidator ID="rvRoom_Charges" runat="server" ControlToValidate="txtRoom_Charges" MinimumValue="0" MaximumValue="999999999" ErrorMessage="Only enter integer values." Text="*"></asp:RangeValidator>
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <div class="loadingimage">
                            <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" /></div>
                    </ProgressTemplate>
                </asp:UpdateProgress>
            </td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblLocation" runat="server" Text="Location"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:TextBox ID="txtLocation" runat="server"></asp:TextBox>
            </td>
            <td></td>
            <td class="mg">
                <asp:Label ID="lblWarden" runat="server" Text="Warden *"></asp:Label>
            </td>
            <td style="width: 205px;">
                <asp:DropDownList ID="ddlWarden" runat="server" AppendDataBoundItems="true" Width="167px">
                </asp:DropDownList>
            </td>
            <td>
                <asp:RequiredFieldValidator ID="rfvWarden" runat="server" ControlToValidate="ddlWarden" Display="Dynamic" InitialValue="0" Text="*" ErrorMessage="Select Warden Name"></asp:RequiredFieldValidator>
            </td>
        </tr>
        
        <tr>
            <td></td>
            <td style="width: 205px;">
                <br />
                <asp:Button ID="btnBack" Width="95px" runat="server" Text="List View" CausesValidation="false" OnClick="btnBack_Click" />
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
                <asp:ValidationSummary ID="ValidationSummary1" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" runat="server" />
            </td>
        </tr>
    </table>

</asp:Content>
