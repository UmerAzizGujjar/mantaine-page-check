<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CompanyView.aspx.cs" Inherits="PMS.CompanyView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="btnNew" runat="server" PostBackUrl="~/Company.aspx" CausesValidation="false" />
                <br />
                <br />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList" DataKeyFields="Company_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                <ig:TemplateDataField Key="Edit" Width="40px">
                                    <ItemTemplate>
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Company_ID","~/Company.aspx?ID={0}") %>' Text="Edit" />
                                        <%--  &nbsp;  &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Company_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        --%>
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Company_Name" DataFieldName="Company_Name" Header-Text="Name" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Company_Address" DataFieldName="Company_Address" Header-Text="Address"></ig:BoundDataField>
                                <ig:BoundDataField Key="Company_Email" DataFieldName="Company_Email" Header-Text="Email"></ig:BoundDataField>
                                <ig:BoundDataField Key="Company_Phone1" DataFieldName="Company_Phone1" Header-Text="Phone No." Width="100px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Name" DataFieldName="Name" Header-Text="Book" Width="100px"></ig:BoundDataField>
                            </Columns>
                        </ig:WebHierarchicalDataGrid>
                        <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:WebHierarchicalDataSource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                        <%--<asp:GridView runat="server" ID="grdCompanyList" AutoGenerateColumns="false" OnRowCommand="grdCompanyList_RowCommand" OnRowDataBound="grdCompanyList_RowDataBound"
                            GridLines="Both" HeaderStyle-BackColor="#5D7B9D" HeaderStyle-ForeColor="White" AlternatingRowStyle-BackColor="#F7F6F3" AlternatingRowStyle-ForeColor="#333333"
                            RowStyle-BackColor="White" RowStyle-ForeColor="#284775">
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HyperLink Text="Edit" ID="hlEdit" NavigateUrl='<%# Eval("Company_ID","~/Company.aspx?ID={0}") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton Text="Delete" ID="HyperLink1" CommandName="Remove" CommandArgument='<%# Eval("Company_ID") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Company_Name" HeaderText="Company Name" />
                                <asp:BoundField DataField="Company_Address" HeaderText="Company Address" />
                                <asp:BoundField DataField="Company_Email" HeaderText="Company Email" />
                                <asp:BoundField DataField="Company_Phone1" HeaderText="Company Phone" />
                                <asp:TemplateField HeaderText="Set Of Book">
                                    <ItemTemplate>
                                        <asp:Label Text='<%# Eval("Book_ID") %>' ID="lblSetOfBookID" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                            </Columns>
                        </asp:GridView>--%>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>
    </table>
</asp:Content>
