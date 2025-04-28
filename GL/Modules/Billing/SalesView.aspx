<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SalesView.aspx.cs" Inherits="PMS.SalesView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table>
        <tr>
            <td>
                <asp:Button Text="Add New" ID="btnNew" runat="server" PostBackUrl="~/Sales.aspx" CausesValidation="false" />
                <br />
                <br />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList" DataKeyFields="Sales_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
                            <GroupingSettings EnableColumnGrouping="True">
                            </GroupingSettings>
                            <Behaviors>
                                <ig:ColumnMoving Enabled="true"></ig:ColumnMoving>
                                <ig:Filtering Enabled="true"></ig:Filtering>
                                <ig:Paging EnableInheritance="True" PagerMode="NumericFirstLast" QuickPages="10" FirstPageText="First" LastPageText="Last" PageSize="20">
                                </ig:Paging>
                                <ig:Sorting Enabled="true" SortingMode="Single"></ig:Sorting>
                            </Behaviors>
                            <Columns>
                                <ig:TemplateDataField Key="Edit" Width="100px">
                                    <ItemTemplate>
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Sales_ID","~/Sales.aspx?ID={0}") %>' Text="Edit" />
                                        &nbsp;  &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Sales_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Invoice_No" DataFieldName="Invoice_No" Header-Text="Invoice No."></ig:BoundDataField>
                                <ig:BoundDataField Key="Voucher_Info" DataFieldName="Voucher_Info" Header-Text="Voucher  No."></ig:BoundDataField>
                                <ig:BoundDataField Key="Customer_Name" DataFieldName="Customer_Name" Header-Text="Customer Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Sales_Date" DataFieldName="Sales_Date" Header-Text="Sales Date" DataFormatString="{0:dd MMM yyy}"></ig:BoundDataField>
                                <ig:BoundDataField Key="Sales_Amount" DataFieldName="Sales_Amount" Header-Text="Sales Amount" DataFormatString="{0:n2}"></ig:BoundDataField>
                                <ig:BoundDataField Key="Salesman" DataFieldName="Salesman" Header-Text="Salesman"></ig:BoundDataField>
                                <ig:BoundDataField Key="Sales_Status" DataFieldName="Sales_Status" Header-Text="Status" Width="80px"></ig:BoundDataField>
                            </Columns>
                        </ig:WebHierarchicalDataGrid>
                        <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:WebHierarchicalDataSource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                        <%-- <asp:GridView runat="server" ID="grdSalesList" AllowPaging="true" PageSize="20" OnPageIndexChanging="grdSalesList_PageIndexChanging" AutoGenerateColumns="False"
                            OnRowCommand="grdSalesList_RowCommand" OnRowDataBound="grdSalesList_RowDataBound"
                            HeaderStyle-BackColor="#5D7B9D" HeaderStyle-ForeColor="White" AlternatingRowStyle-BackColor="#F7F6F3" AlternatingRowStyle-ForeColor="#333333"
                            RowStyle-BackColor="White" RowStyle-ForeColor="#284775" EnableTheming="true" EmptyDataText="No record">
                            <AlternatingRowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HyperLink Text="Edit" ID="hlEdit" NavigateUrl='<%# Eval("Sales_ID","~/Sales.aspx?ID={0}") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton Text="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Sales_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Sales_ID" HeaderText="Sales No" />
                                <asp:TemplateField HeaderText="Customer">
                                    <ItemTemplate>
                                        <asp:Label Text='<%# Eval("Customer_ID") %>' ID="lblCustomer_ID" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Sales_Date" HeaderText="Sales Date" DataFormatString="{0:dd MMM yyy}" />
                                <asp:BoundField DataField="Sales_Status" HeaderText="Status" />
                                <asp:BoundField DataField="Sales_Amount" HeaderText="Sales Amount" DataFormatString="{0:n2}" ItemStyle-HorizontalAlign="Right" />
                            </Columns>
                            <HeaderStyle BackColor="#5D7B9D" ForeColor="White" />
                            <RowStyle BackColor="White" ForeColor="#284775" />
                        </asp:GridView>--%>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>
    </table>
</asp:Content>
