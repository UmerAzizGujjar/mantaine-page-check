<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ManageRoles.aspx.cs" Inherits="PMS.Account.ManageRoles" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
  <style type="text/css">
      input {
          width:7% !important;
          
      }
  </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <h3>Manage User Roles</h3>
    <br />
    <asp:UpdatePanel runat="server" ID="upForm" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Panel runat="server" ID="pnlForm" DefaultButton="btnSave">
                <table cellspacing="7">
                    <tr>
                        <td>
                            <asp:Label Text="User *" ID="lblUser" runat="server" />
                        </td>
                        <td>
                            <asp:DropDownList runat="server" AppendDataBoundItems="true" AutoPostBack="true" ID="ddlUsers">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="User is required." InitialValue="0" SetFocusOnError="true" Display="Dynamic" ControlToValidate="ddlUsers" runat="server" />
                        </td>
                    </tr>
                    <tr valign="top">
                        <td>
                            <asp:Label Text="Roles" runat="server" />
                        </td>
                        <td>
                            <asp:CheckBoxList ID="cbRolesList" runat="server">
                            </asp:CheckBoxList>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label Text="Company" ID="lblCompany" runat="server" />
                        </td>
                    </tr>
                    <tr valign="top">

                        <td>
                            <asp:CheckBox Text="All Company" ID="cbAllCompany" runat="server" AutoPostBack="true" OnCheckedChanged="cbAllCompany_CheckedChanged" />

                            <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlCompany" Enabled="false">
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="rfvCompany" ErrorMessage="Company is required." InitialValue="0"
                                SetFocusOnError="true" Display="Dynamic" ControlToValidate="ddlCompany" runat="server" Enabled="false" />
                        </td>
                    </tr>

                    <tr>
                    </tr>
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:Button Text="View" CssClass="btn btn-gray" runat="server" CausesValidation="false" Style="width:100% !important" PostBackUrl="~/Modules/Accounts/RoleAssignment.aspx" />
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:Button Text="Save" ID="btnSave" CssClass="btn-primry" runat="server" Style="width:100% !important" OnClick="btnSave_Click" />
                                </div>
                            </div>
                        </div>
                    </div>
                    <tr>
                        <td colspan="2">
                            <asp:Label ID="lblMessage" runat="server" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
