<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SetOfBookView.aspx.cs" Inherits="PMS.SetOfBookView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table>
        <tr>
            <td>
                <asp:Button Text="Add New" ID="btnSave" runat="server" PostBackUrl="~/SetOfBooks.aspx" CausesValidation="false" />
                <br />
                <br />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="50%"
                            Width="100%" DataSourceID="whdsList" DataKeyFields="Book_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
                            <GroupingSettings EnableColumnGrouping="True">
                            </GroupingSettings>
                            <Behaviors>
                                <ig:ColumnMoving Enabled="true"></ig:ColumnMoving>
                                <ig:Filtering Enabled="true"></ig:Filtering>
                                <ig:Paging EnableInheritance="True" PagerMode="NumericFirstLast" PageSize="20">
                                </ig:Paging>
                                <ig:Sorting Enabled="true" SortingMode="Single"></ig:Sorting>
                            </Behaviors>
                            <Columns>
                                <ig:TemplateDataField Key="Edit" Width="80px">
                                    <ItemTemplate>
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Book_ID","~/SetOfBooks.aspx?ID={0}") %>' Text="Edit" />
                                        &nbsp;  &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Book_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Name" DataFieldName="Name" Header-Text="Name"></ig:BoundDataField>
                            </Columns>
                        </ig:WebHierarchicalDataGrid>
                        <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:WebHierarchicalDataSource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                        <%--  <asp:GridView runat="server" ID="grdBookList" AutoGenerateColumns="false" AllowPaging="true" PageSize="20" OnPageIndexChanging="grdBookList_PageIndexChanging" OnRowCommand="grdBookList_RowCommand"
                            GridLines="Both" Width="300px" HeaderStyle-BackColor="#5D7B9D" HeaderStyle-ForeColor="White" AlternatingRowStyle-BackColor="#F7F6F3" AlternatingRowStyle-ForeColor="#333333"
                            RowStyle-BackColor="White" RowStyle-ForeColor="#284775">
                            <Columns>
                                <asp:TemplateField HeaderStyle-Width="35px">
                                    <ItemTemplate>
                                        <asp:HyperLink Text="Edit" ID="hlEdit" NavigateUrl='<%# Eval("Book_ID","~/SetOfBooks.aspx?ID={0}") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField HeaderStyle-Width="35px">
                                    <ItemTemplate>
                                        <asp:LinkButton Text="Delete" ID="HyperLink1" CommandName="Remove" CommandArgument='<%# Eval("Book_ID") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Name" HeaderText="Book Name" />
                            </Columns>
                        </asp:GridView>--%>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>
    </table>
</asp:Content>
