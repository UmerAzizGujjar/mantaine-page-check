<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserRolesView.aspx.cs" Inherits="PMS.Account.UserRolesView" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <br />
    <%-- <asp:Button Text="Assign Role To User" runat="server" PostBackUrl="~/Account/ManageRoles.aspx" />
    <br />
    <br />--%>
    <asp:GridView runat="server" ID="gvRoles" AutoGenerateColumns="False" OnRowEditing="gvRoles_RowEditing"
        OnRowDataBound="gvRoles_RowDataBound" OnRowUpdating="gvRoles_RowUpdating" OnRowCancelingEdit="gvRoles_RowCancelingEdit"
        OnRowCommand="gvRoles_RowCommand" DataKeyNames="UserID">
        <Columns>
            <%-- <asp:TemplateField ShowHeader="False">
                <EditItemTemplate>
                    <asp:LinkButton ID="lblUpdate" runat="server" Text="Update" CommandName="Update" OnClick="lblUpdate_Click"></asp:LinkButton>
                    &nbsp;
                        <asp:LinkButton ID="lblCancelUpdate" runat="server" Text="Cancel" CausesValidation="False" CommandName="Cancel"></asp:LinkButton>
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="false" CommandName="Edit" Text="Edit"></asp:LinkButton>
                </ItemTemplate>
                <ControlStyle ForeColor="Blue" />
            </asp:TemplateField>--%>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:HyperLink ID="hlEdit" Text="Edit Role" ToolTip="Edit Role" NavigateUrl='<%# Eval("UserId","~/Account/ManageRoles.aspx?UserID={0}") %>' runat="server" />
                    <asp:LinkButton ID="lbtnRemoveRoles" runat="server" CommandArgument='<%# Eval("UserId") %>' CausesValidation="false" CommandName="Remove" Text="Remove Role" ToolTip="Remove Role"
                        OnClientClick="javascript:return confirm('Are you sure, you want to remove role(s) for this user?');"></asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="User Id">
                <EditItemTemplate>
                    <asp:Label ID="lblUserId" Text='<%# Eval("UserId") %>' runat="server" />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="lblUserId" Text='<%# Eval("UserId") %>' runat="server" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="User Name">
                <EditItemTemplate>
                    <asp:Label runat="server" ID="lblUserName" Text='<%# Eval("UserName") %>' />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label runat="server" ID="lblUserName" Text='<%# Eval("UserName") %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Email">
                <EditItemTemplate>
                    <asp:Label ID="Label3" Text='<%# Eval("Email") %>' runat="server" />
                </EditItemTemplate>
                <ItemTemplate>
                    <%# Eval("Email") %>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Application Role">
                <EditItemTemplate>
                    <%--  <asp:DropDownList ID="ddlRole" runat="server" DataTextField="RoleName" DataValueField="RoleId">
                    </asp:DropDownList>--%>
                    <asp:Label ID="lblRole" runat="server" />
                </EditItemTemplate>
                <ItemTemplate>
                    <asp:Label ID="lblRole" runat="server" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
    <asp:Label ID="lblMessage" runat="server" CssClass="errorMessage" />
</asp:Content>

