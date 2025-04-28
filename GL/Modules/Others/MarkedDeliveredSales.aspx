<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MarkedDeliveredSales.aspx.cs" Inherits="PMS.MarkedDeliveredSales" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">
        <ContentTemplate>
            <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                Width="100%" DataSourceID="whdsList" DataKeyFields="Sales_ID">
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
                    <ig:TemplateDataField Key="Select">
                        <ItemTemplate>
                            <asp:CheckBox ID="cbSelect" Text="" runat="server" />
                            <asp:Label ID="lblSales_ID" runat="server" Text='<%# Eval("Sales_ID") %>' Visible="false"></asp:Label>
                        </ItemTemplate>
                    </ig:TemplateDataField>
                    <ig:BoundDataField Key="Customer_ID" DataFieldName="Customer_ID" Header-Text="Vendor"></ig:BoundDataField>
                    <ig:BoundDataField Key="Sales_Date" DataFieldName="Sales_Date" Header-Text="Purchase Date" DataFormatString="{0: dd MMM yyyy}" />
                    <ig:BoundDataField Key="Remarks" DataFieldName="Remarks" Header-Text="Remarks" Width="550px" />
                </Columns>
            </ig:WebHierarchicalDataGrid>
        </ContentTemplate>
    </asp:UpdatePanel>
    <ig:WebHierarchicalDataSource ID="whdsList" runat="server">
        <DataViews>
            <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
        </DataViews>
    </ig:WebHierarchicalDataSource>
    <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
    <%--<asp:GridView ID="gvUnDeliveredSales" runat="server" AutoGenerateColumns="False" 
        EnableModelValidation="True" AllowPaging="true" OnPageIndexChanging="gvUnDeliveredSales_PageIndexChanging">
        <Columns>
            <asp:TemplateField>
                <ItemTemplate>
                    <asp:CheckBox ID="cbSelect" Text="" runat="server" />
                    <asp:Label ID="lblSales_ID" runat="server" Text='<%# Bind("Sales_ID") %>' Visible="false"></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Customer">
                <ItemTemplate>
                    <asp:Label ID="lblCustomer_ID" runat="server" Text='<%# Bind("Customer_ID") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Sales_Date" HeaderText="Sales Date" DataFormatString="{0: dd MMM yyyy}" />
            <asp:TemplateField HeaderText="Sector">
                <ItemTemplate>
                    <asp:Label ID="lblSector" runat="server" Text='<%# Bind("Sector") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Remarks" HeaderText="Remarks">
                <ItemStyle Width="550px" />
            </asp:BoundField>
        </Columns>
    </asp:GridView>--%>
    <br />
    <asp:Button ID="btnApprove" Text="Mark as Delivered" runat="server"
        SkinID="btnAutoWidth" onclick="btnApprove_Click" />
    <asp:Button ID="btnCancel" Text="Cancel Selected Sales" runat="server"
        SkinID="btnAutoWidth" onclick="btnCancel_Click" Visible="false"/>
</asp:Content>
