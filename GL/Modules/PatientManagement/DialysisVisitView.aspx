<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisVisitView.aspx.cs" Inherits="PMS.DialysisVisitView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/DialysisVisit.aspx" CausesValidation="false" />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Dialysis_Visit_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Dialysis_Visit_ID","~/DialysisVisit.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Dialysis_Visit_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Dialysis_Visit_ID" DataFieldName="Dialysis_Visit_ID" Header-Text="ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Dialysis_Case" DataFieldName="Dialysis_Case" Header-Text="Dialysis Case"></ig:BoundDataField>
                                <ig:BoundDataField Key="Doctor" DataFieldName="Doctor" Header-Text="Doctor"></ig:BoundDataField>
                                <ig:BoundDataField Key="Dialysis_Type" DataFieldName="Dialysis_Type" Header-Text="Dialysis Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Dialyzer" DataFieldName="Dialyzer" Header-Text="Dialyzer"></ig:BoundDataField>

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
