<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingView.aspx.cs" Inherits="PMS.BillingView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/Billing.aspx" CausesValidation="false" />
            </td>
        </tr>

         <tr>
            <td>
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"  DataKeyFields="Patient_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating">
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
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Patient_ID","~/Billing.aspx?ID={0}") %>' Text="View" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Patient_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Patient_ID" DataFieldName="Patient_ID" Header-Text="Patient ID" Width="120px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Full_Name" DataFieldName="Full_Name" Header-Text="Patient Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Patient_Total_Bill" DataFieldName="Patient_Total_Bill" Header-Text="Total Bill"></ig:BoundDataField>

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
