<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetSelectionView.aspx.cs" Inherits="PMS.AssetSelectionView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="width:100%;">
        <tr class="col-lg-1 col-md-1 col-sm-1">
            <td class="col-lg-1 col-md-1 col-sm-1">
                <asp:Button Text="Add New" ID="Button1" CssClass="btn-primry" runat="server" PostBackUrl="~/Modules/Administrator/AssetSelection.aspx" CausesValidation="false" />
            </td>
        </tr>
         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Asset_Selection_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Asset_Selection_ID","~/Modules/Administrator/AssetSelection.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Asset_Selection_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />   
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Asset_Selection_ID" DataFieldName="Asset_Selection_ID" Header-Text="ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Branch" DataFieldName="Branch" Header-Text="Branch"></ig:BoundDataField>
                                <ig:BoundDataField Key="Category_Name" DataFieldName="Category_Name" Header-Text="Asset Category"></ig:BoundDataField>
                                <ig:BoundDataField Key="SubCategory_Name" DataFieldName="SubCategory_Name" Header-Text="Asset SubCategory"></ig:BoundDataField>
                                <ig:BoundDataField Key="Item_Serial" DataFieldName="Item_Serial" Header-Text="Item Serial"></ig:BoundDataField>
                                <ig:BoundDataField Key="Company_Name" DataFieldName="Company_Name" Header-Text="Company"></ig:BoundDataField>
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
