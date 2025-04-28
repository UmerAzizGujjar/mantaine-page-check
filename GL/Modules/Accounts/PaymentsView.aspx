<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentsView.aspx.cs" Inherits="PMS.PaymentsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <table width="100%">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="btnNew" runat="server" PostBackUrl="~/Payments.aspx" CausesValidation="false" />
                <br />
                <br />
            </td>
        </tr>
        <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <asp:Label ID="lblMessage" runat="server" />
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList" DataKeyFields="Payment_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Payment_ID","~/Payments.aspx?ID={0}") %>' Text="Edit" />
                                        &nbsp;  &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Payment_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Payment_ID" DataFieldName="Payment_ID" Header-Text="Payment ID."></ig:BoundDataField>
                                <ig:BoundDataField Key="Payment_Date" DataFieldName="Payment_Date" Header-Text="Payment Date" DataFormatString="{0:dd MMM yyy}"></ig:BoundDataField>
                                <ig:BoundDataField Key="Vendor_Name" DataFieldName="Vendor_Name" Header-Text="Vendor Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Ref_No" DataFieldName="Ref_No" Header-Text="Reference No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Remarks" DataFieldName="Remarks" Header-Text="Remarks"></ig:BoundDataField>
                                <ig:BoundDataField Key="Account_Name" DataFieldName="Account_Name" Header-Text="Account Name"></ig:BoundDataField>

                            </Columns>
                        </ig:WebHierarchicalDataGrid>
                        <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:WebHierarchicalDataSource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>
    </table>
</asp:Content>
