<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VehicleView.aspx.cs" Inherits="PMS.VehicleView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     

    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/VehicleRegistration.aspx" CausesValidation="false" />
            <br />
                <br />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="VID" OnItemCommand="whdgList_ItemCommand" >
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("VID","~/VehicleRegistration.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("VID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                        
                                        
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="V_Code" DataFieldName="V_Code" Header-Text="Vehicle Code" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="VIN" DataFieldName="VIN" Header-Text="VIN"></ig:BoundDataField>
                                <ig:BoundDataField Key="Reg_No" DataFieldName="Reg_No" Header-Text="Reg. No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Reg_State" DataFieldName="Reg_State" Header-Text="Reg. State"></ig:BoundDataField>
                                <ig:BoundDataField Key="Engine_No" DataFieldName="Engine_No" Header-Text="Engine No"></ig:BoundDataField>
                                <ig:BoundDataField Key="V_Type" DataFieldName="V_Type" Header-Text="Vehicle Type"></ig:BoundDataField>
                                <ig:BoundDataField Key="Total_Seats" DataFieldName="Total_Seats" Header-Text="Total Seats"></ig:BoundDataField>
                                <ig:BoundDataField Key="Make" DataFieldName="Make" Header-Text="Make"></ig:BoundDataField>
                                <ig:BoundDataField Key="Model" DataFieldName="Model" Header-Text="Model"></ig:BoundDataField>
                                <ig:BoundDataField Key="Color" DataFieldName="Color" Header-Text="Color"></ig:BoundDataField>

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
