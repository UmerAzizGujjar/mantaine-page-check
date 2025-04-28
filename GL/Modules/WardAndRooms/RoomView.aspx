<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RoomView.aspx.cs" Inherits="PMS.RoomView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/Room.aspx" CausesValidation="false" />
            <br />
                <br />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Room_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Room_ID","~/Room.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Room_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        
                                        
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Room_ID" DataFieldName="Room_ID" Header-Text="Room ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Room_No" DataFieldName="Room_No" Header-Text="Room No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Name" DataFieldName="Name" Header-Text="Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Building_Type" DataFieldName="Building_Type" Header-Text="Building Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Room_Type" DataFieldName="Room_Type" Header-Text="Room Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Floor_No" DataFieldName="Floor_No" Header-Text="Floor No"></ig:BoundDataField>
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
