<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="HR_Shifts_View.aspx.cs" Inherits="PMS.Shifts_View" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/HR_Shifts.aspx" CausesValidation="false" />
            <br />
                <br />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Shift_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Shift_ID","~/HR_Shifts.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Shift_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        
                                        
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Shift_ID" DataFieldName="Shift_ID" Header-Text="Shift ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Shift_Name" DataFieldName="Shift_Name" Header-Text="Shift Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Time_From" DataFieldName="Time_From" Header-Text="Shift Time From"></ig:BoundDataField>
                                <ig:BoundDataField Key="Time_To" DataFieldName="Time_To" Header-Text="Shift Time To"></ig:BoundDataField>
                                <ig:BoundDataField Key="Break_Time_From" DataFieldName="Break_Time_From" Header-Text="Break Time From"></ig:BoundDataField>
                                <ig:BoundDataField Key="Break_Time_To" DataFieldName="Break_Time_To" Header-Text="Break Time To"></ig:BoundDataField>
                                <ig:BoundDataField Key="Shift_Next_Day" DataFieldName="Shift_Next_Day" Header-Text="Shift Next Day"></ig:BoundDataField>

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
