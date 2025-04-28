<%@ Page Title="" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="VoucherType.aspx.cs" Inherits="PMS.GL.VoucherType" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div>

<%--    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>--%>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                <ProgressTemplate>
                    <img src="~/images/loading.gif" alt="loading" />
                </ProgressTemplate>
            </asp:UpdateProgress>
            <p style="margin: 4px 0px 4px 0px; padding: 4px 0px 4px 0px;">
                [<asp:LinkButton ID="btnAddnew" runat="server" Text="Add New" OnClick="btnAddnew_Click" />]</p>
            <asp:GridView ID="gvVouchertype" runat="server" AutoGenerateColumns="False" BackColor="#DEBA84"
                BorderColor="#DEBA84" BorderStyle="None" BorderWidth="1px" CellPadding="3" CellSpacing="2"
                OnRowEditing="gvVouchertype_RowEditing" OnRowUpdating="gvVouchertype_RowUpdating"
                OnRowCancelingEdit="gvVouchertype_RowCancelingEdit" OnRowDeleting="gvVouchertype_RowDeleting"
                OnRowCommand="gvVouchertype_RowCommand">
                <Columns>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="False" CommandName="Edit"
                                Text="Edit"></asp:LinkButton>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:LinkButton ID="LinkButton1" runat="server" CausesValidation="True" CommandName="Update"
                                Text="Update"></asp:LinkButton>
                            &nbsp;<asp:LinkButton ID="LinkButton2" runat="server" CausesValidation="False" CommandName="Cancel"
                                Text="Cancel"></asp:LinkButton>
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:LinkButton ID="lbCancel" runat="server" CausesValidation="False" CommandName="addnewcancel"
                                Text="Cancel"></asp:LinkButton>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:LinkButton ID="lbDelete" runat="server" CausesValidation="False" CommandName="Delete"
                                Text="Delete"></asp:LinkButton>
                        </ItemTemplate>
                        <FooterTemplate>
                            <asp:LinkButton ID="lbSave" runat="server" CausesValidation="False" CommandName="addnew"
                                Text="Save"></asp:LinkButton>
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Voucher Type">
                        <ItemTemplate>
                            <asp:Label ID="lblVouchertype" runat="server" Text='<%# Bind("Voucher_Type") %>' />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtVouchertype" runat="server" Text='<%# Bind("Voucher_Type") %>' />
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtVouchertype" runat="server" />
                        </FooterTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Description">
                        <ItemTemplate>
                            <asp:Label ID="lblDescription" runat="server" Text='<%# Bind("[Voucher_Name]") %>' />
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtDescription" runat="server" Text='<%# Bind("[Voucher_Name]") %>' />
                        </EditItemTemplate>
                        <FooterTemplate>
                            <asp:TextBox ID="txtDescription" runat="server" />
                        </FooterTemplate>
                    </asp:TemplateField>
                </Columns>
                <EmptyDataTemplate>
                    <%--<asp:LinkButton ID="lbCancel" runat="server" CausesValidation="False" CommandName="addnewcancel"
                Text="Cancel"></asp:LinkButton>--%>
                    <asp:LinkButton ID="lbSave" runat="server" CausesValidation="False" CommandName="emptyaddnew"
                        Text="Save"></asp:LinkButton>
                    <asp:Label ID="Label1" runat="server" Text="Voucher Type:"></asp:Label>
                    <asp:TextBox ID="txtVouchertype" runat="server" />
                    <asp:Label ID="Label2" runat="server" Text="Description:"></asp:Label>
                    <asp:TextBox ID="txtDescription" runat="server" />
                </EmptyDataTemplate>
                <FooterStyle BackColor="#F7DFB5" ForeColor="#8C4510" />
                <HeaderStyle BackColor="#A55129" Font-Bold="True" ForeColor="White" />
                <PagerStyle ForeColor="#8C4510" HorizontalAlign="Center" />
                <RowStyle BackColor="#FFF7E7" ForeColor="#8C4510" />
                <SelectedRowStyle BackColor="#738A9C" Font-Bold="True" ForeColor="White" />
                <SortedAscendingCellStyle BackColor="#FFF1D4" />
                <SortedAscendingHeaderStyle BackColor="#B95C30" />
                <SortedDescendingCellStyle BackColor="#F1E5CE" />
                <SortedDescendingHeaderStyle BackColor="#93451F" />
                <SortedAscendingCellStyle BackColor="#FFF1D4"></SortedAscendingCellStyle>
                <SortedAscendingHeaderStyle BackColor="#B95C30"></SortedAscendingHeaderStyle>
                <SortedDescendingCellStyle BackColor="#F1E5CE"></SortedDescendingCellStyle>
                <SortedDescendingHeaderStyle BackColor="#93451F"></SortedDescendingHeaderStyle>
            </asp:GridView>
            <asp:Label ID="lblMessage" ForeColor="Red" CssClass="labalstyle" runat="server" />
        </ContentTemplate>
    </asp:UpdatePanel>
    </div>
</asp:Content>
