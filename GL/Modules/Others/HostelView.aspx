<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HostelView.aspx.cs" Inherits="PMS.HostelsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/Hostel.aspx" CausesValidation="false" />
            <br />
                <br />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Hostel_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Hostel_ID","~/Hostel.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Hostel_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        
                                        
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Hostel_ID" DataFieldName="Hostel_ID" Header-Text="Hostel ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Hostel_No" DataFieldName="Hostel_No" Header-Text="Hostel No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Name" DataFieldName="Name" Header-Text="Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Building_Type" DataFieldName="Building_Type" Header-Text="Building Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Hostel_Type" DataFieldName="Hostel_Type" Header-Text="Hostel Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="No_of_Floors" DataFieldName="No_of_Floors" Header-Text="No of Floors"></ig:BoundDataField>
                                <ig:BoundDataField Key="No_of_Rooms" DataFieldName="No_of_Rooms" Header-Text="No of Rooms"></ig:BoundDataField>
                                <ig:BoundDataField Key="Location" DataFieldName="Location" Header-Text="Location"></ig:BoundDataField>
                                <ig:BoundDataField Key="Warden" DataFieldName="Warden" Header-Text="Warden"></ig:BoundDataField>

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
