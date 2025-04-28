<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WebForm3.aspx.cs" Inherits="PMS.WebForm3" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <asp:Button Text="Add" runat="server" ID="btnAdd" OnClick="btnAdd_Click" />
        <asp:GridView runat="server" AutoGenerateColumns="False" BackColor="White" BorderColor="#999999"
            BorderStyle="None" BorderWidth="1px" CellPadding="3" EnableModelValidation="True"
            GridLines="Vertical" ID="gv" OnRowCommand="gv_RowCommand" OnRowCancelingEdit="gv_RowCancelingEdit"
            OnRowEditing="gv_RowEditing" OnRowUpdating="gv_RowUpdating">
            <AlternatingRowStyle BackColor="#DCDCDC" />
            <Columns>
                <asp:TemplateField ShowHeader="false">
                    <ItemTemplate>
                        <asp:LinkButton Text="Edit" runat="server" CommandName="Edit" ID="lbEdit" CausesValidation="false" />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="lbUpdate" Text="Update" runat="server" CausesValidation="false"
                            CommandName="Update" />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:LinkButton Text="Cancel" runat="server" CausesValidation="false" 
                            CommandName="AddNewCancel" ID="lbCancel" />
                    </FooterTemplate>
                </asp:TemplateField>
                <asp:TemplateField ShowHeader="false">
                    <ItemTemplate>
                        <asp:LinkButton Text="Delete" runat="server" CommandName="Delete" ID="lbDelete" CausesValidation="false" />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:LinkButton ID="lblCancel" runat="server" CommandName="Update Cancel">Cancel</asp:LinkButton>
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:LinkButton ID="LinkButton3" Text="Save" runat="server" CausesValidation="false"
                            CommandName="Add New" />
                    </FooterTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Children_ID" Visible="False">
                    <ItemTemplate>
                        <asp:Label ID="lblChildren_ID" runat="server" Text='<%# Bind("Children_ID") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtChildren_ID" runat="server" Text='<%# Bind("Children_ID") %>' />
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Children_Name">
                    <ItemTemplate>
                        <asp:Label ID="lblChildren_Name" runat="server" Text='<%# Bind("Children_Name") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtChildren_Name" runat="server" Text='<%# Bind("Children_Name") %>' />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="txtNewChildren_Name" runat="server" />
                    </FooterTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Age">
                    <ItemTemplate>
                        <asp:Label ID="lblAge" runat="server" Text='<%# Bind("Age") %>' />
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtAge" runat="server" Text='<%# Bind("Age") %>' />
                    </EditItemTemplate>
                    <FooterTemplate>
                        <asp:TextBox ID="txtNewAge" runat="server" />
                    </FooterTemplate>
                </asp:TemplateField>
            </Columns>
            <EmptyDataTemplate>
                <table border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td>
                            Children Name:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNewChildren_Name" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            Age:
                        </td>
                        <td>
                            <asp:TextBox ID="txtNewAge" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button ID="btnChildren_Save" runat="server" OnClick="btnChildren_Save_Click"
                                Text="Save" />
                        </td>
                    </tr>
                </table>
            </EmptyDataTemplate>
            <FooterStyle BackColor="#CCCCCC" ForeColor="Black" />
            <HeaderStyle BackColor="#000084" Font-Bold="True" ForeColor="White" />
            <PagerStyle BackColor="#999999" ForeColor="Black" HorizontalAlign="Center" />
            <RowStyle BackColor="#EEEEEE" ForeColor="Black" />
            <SelectedRowStyle BackColor="#008A8C" Font-Bold="True" ForeColor="White" />
        </asp:GridView>
    </div>
</asp:Content>
