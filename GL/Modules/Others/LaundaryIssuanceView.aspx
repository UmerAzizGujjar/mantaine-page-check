<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaundaryIssuanceView.aspx.cs" Inherits="PMS.LaundaryIssuanceView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/LaundaryIssuance.aspx" CausesValidation="false" />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Laundary_Issuance_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Laundary_Issuance_ID","~/LaundaryIssuance.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Laundary_Issuance_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Laundary_Issuance_ID" DataFieldName="Laundary_Issuance_ID" Header-Text="ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Issue_To" DataFieldName="Issue_To" Header-Text="Issue To"></ig:BoundDataField>
                                <ig:BoundDataField Key="Room_No" DataFieldName="Room_No" Header-Text="Room No."></ig:BoundDataField>
                                <ig:BoundDataField Key="Ward_No" DataFieldName="Ward_No" Header-Text="Ward No."></ig:BoundDataField>
                                <ig:BoundDataField Key="Laundary_Item" DataFieldName="Laundary_Item" Header-Text="Laundary Item"></ig:BoundDataField>
                                <ig:BoundDataField Key="Quantity" DataFieldName="Quantity" Header-Text="Quantity"></ig:BoundDataField>
                                <ig:BoundDataField Key="Issue_Date" DataFieldName="Issue_Date" Header-Text="Issue Date"></ig:BoundDataField>

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
