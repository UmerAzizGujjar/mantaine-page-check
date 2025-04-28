<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CustomerView.aspx.cs" Inherits="PMS.CustomerView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <br />
    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="btnNew" runat="server" PostBackUrl="~/AR/Customer.aspx" CausesValidation="false" />
                <br />
                <br />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList" DataKeyFields="Customer_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Customer_ID","~/AR/Customer.aspx?ID={0}") %>' Text="Edit" />
                                        &nbsp;  &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Customer_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Customer_Name" DataFieldName="Customer_Name" Header-Text="Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Father_Name" DataFieldName="Father_Name" Header-Text="Father Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Customer_CNIC" DataFieldName="Customer_CNIC" Header-Text="CNIC"></ig:BoundDataField>
                                <ig:BoundDataField Key="Custoemer_Office_Number" DataFieldName="Custoemer_Office_Number" Header-Text="Office Number"></ig:BoundDataField>
                                <ig:BoundDataField Key="Customer_Occupation" DataFieldName="Customer_Occupation" Header-Text="Occupation"></ig:BoundDataField>
                                <ig:BoundDataField Key="Customer_Email" DataFieldName="Customer_Email" Header-Text="Email"></ig:BoundDataField>
                                <ig:BoundDataField Key="City" DataFieldName="City" Header-Text="City"></ig:BoundDataField>
                            </Columns>
                        </ig:WebHierarchicalDataGrid>
                        <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:WebHierarchicalDataSource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                        <%--  <asp:GridView runat="server" ID="grdCustomerList" AutoGenerateColumns="False" AllowPaging="true" PageSize="20" OnPageIndexChanging="grdCustomerList_PageIndexChanging" OnRowCommand="grdCustomerList_RowCommand" OnRowDataBound="grdCustomerList_RowDataBound" HeaderStyle-BackColor="#5D7B9D" HeaderStyle-ForeColor="White" AlternatingRowStyle-BackColor="#F7F6F3" AlternatingRowStyle-ForeColor="#333333"
                            RowStyle-BackColor="White" RowStyle-ForeColor="#284775" EmptyDataText="No record." Width="100%">
                            <AlternatingRowStyle BackColor="#F7F6F3" ForeColor="#333333" />
                            <Columns>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:HyperLink Text="Edit" ID="hlEdit" NavigateUrl='<%# Eval("Customer_ID","~/Customer.aspx?ID={0}") %>' runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:TemplateField>
                                    <ItemTemplate>
                                        <asp:LinkButton Text="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Customer_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </asp:TemplateField>
                                <asp:BoundField DataField="Customer_Name" HeaderText="Customer Name" HeaderStyle-Width="150px"/>
                                <asp:BoundField DataField="Father_Name" HeaderText="Father Name" />
                                <asp:BoundField DataField="Customer_CNIC" HeaderText="Customer CNIC" />
                                <asp:BoundField DataField="Custoemer_Office_Number" HeaderText="Office Number" />
                                <asp:BoundField DataField="Customer_Occupation" HeaderText="Customer Occupation" />

                                <asp:BoundField DataField="Customer_Email" HeaderText="Customer Email" />
                                <asp:BoundField DataField="Customer_Address" HeaderText="Customer Address" />
                                <asp:TemplateField HeaderText="City">
                                    <ItemTemplate>
                                        <asp:Label Text='<%# Eval("City") %>' ID="lblCity" runat="server" />
                                    </ItemTemplate>
                                </asp:TemplateField>

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
