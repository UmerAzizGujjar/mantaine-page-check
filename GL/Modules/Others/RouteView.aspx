<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RouteView.aspx.cs" Inherits="PMS.RouteView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     

    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/AddRoute.aspx" CausesValidation="false" />
            <br />
                <br />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Route_ID" OnItemCommand="whdgList_ItemCommand" >
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Route_ID","~/AddRoute.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Route_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        
                                        
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Route_ID" DataFieldName="Route_ID" Header-Text="Route ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Route_Name" DataFieldName="Route_Name" Header-Text="Route Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Destination" DataFieldName="Destination" Header-Text="Destination Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Route_Type" DataFieldName="Route_Type" Header-Text="Route Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Start_Time" DataFieldName="Start_Time" Header-Text="Start Time"></ig:BoundDataField>
                                <ig:BoundDataField Key="End_Time" DataFieldName="End_Time" Header-Text="End Time"></ig:BoundDataField>
                                <%--<ig:BoundDataField Key="From_Date" DataFieldName="From_Date" Header-Text="Start Date"></ig:BoundDataField>
                                <ig:BoundDataField Key="To_Date" DataFieldName="To_Date" Header-Text="End Date"></ig:BoundDataField>
                                <ig:BoundDataField Key="Remark" DataFieldName="Remark" Header-Text="Remarks"></ig:BoundDataField>--%>

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
