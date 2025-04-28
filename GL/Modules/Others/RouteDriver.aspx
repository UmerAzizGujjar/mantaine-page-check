<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RouteDriver.aspx.cs" Inherits="PMS.RouteDriver" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div style="width: 90%">
        <table style="padding: 20px; width: 350px;">
            <tr>
                <td style="padding-left: 20px;">
                    <asp:Label ID="lblRoute_Name" runat="server" Text="Route *"></asp:Label>
                </td>
                <td style="width: 205px;">
                    <asp:DropDownList ID="ddlRoute_Name" runat="server" AppendDataBoundItems="true"></asp:DropDownList>

                </td>
                <td>
                    <asp:RequiredFieldValidator ID="rvValidator2" InitialValue="0" runat="server" ControlToValidate="ddlRoute_Name" Text="*"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td style="padding-left: 20px;">
                    <asp:Label ID="lblDriver" runat="server" Text="Driver *"></asp:Label>
                </td>
                <td style="width: 205px;">
                    <asp:DropDownList ID="ddlDriver" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                </td>
                <td>
                    <asp:RequiredFieldValidator ID="rvValidator1" InitialValue="0" runat="server" ControlToValidate="ddlDriver" Text="*"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td style="padding-left: 20px;">
                    <asp:Label ID="lblHelper" runat="server" Text="Helper *"></asp:Label>
                </td>
                <td style="width: 205px;">
                    <asp:DropDownList ID="ddlHelper" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                </td>
                <td>
                    <asp:RequiredFieldValidator ID="rfvHelper" InitialValue="0" runat="server" ControlToValidate="ddlHelper" Text="*"></asp:RequiredFieldValidator>
                </td>
            </tr>
            <tr>
                <td colspan="3" style="padding-left: 20px; padding-top: 15px;">
                    <asp:Button ID="btnBack" Width="97px" runat="server" Text="Back" CausesValidation="false" PostBackUrl="~/RouteDriverView.aspx" />
                    &nbsp;
                     <asp:Button ID="btnSave" Width="97px" runat="server" Text="Assign" OnClick="btnSave_Click" />
                    &nbsp;
                     <asp:Button ID="btnClear" Width="97px" runat="server" Text="Reset" CausesValidation="false" OnClick="btnClear_Click" />
                </td>
            </tr>
            <tr>
                <td colspan="3" style="padding-left: 20px; padding-top: 15px;">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                </td>
            </tr>
        </table>
    </div>
</asp:Content>
