<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InvoiceView.aspx.cs" Inherits="PMS.InvoiceView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    
            <br />
            <table style="width:100%;">
                <tr>
                    <td colspan="2">
                        <asp:Button Text="Add New" ID="btnNew" runat="server" CausesValidation="false" OnClick="btnNew_Click"   />
                        <br />
                        <br />
                    </td>
                </tr>
                <%--<tr>
                    <td width="150px">Voucher Month
                    </td>
                    <td>
                        <asp:DropDownList runat="server" ID="ddlPeriod" AppendDataBoundItems="true" AutoPostBack="true" OnSelectedIndexChanged="ddlPeriod_SelectedIndexChanged">
                        </asp:DropDownList>
                    </td>
                </tr>--%>
                <tr>
                    <td colspan="2">
                        <br />
                    <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                        <ContentTemplate>
                        <ig:WebHierarchicalDataGrid ID="whdgList" AutoGenerateColumns="false" runat="server" Height="100%"
                            Width="100%" DataSourceID="whdsList"
                             DataKeyFields="Invoice_ID" OnItemCommand="whdgList_ItemCommand" OnRowIslandsPopulating="whdgList_RowIslandsPopulating" >
                            <GroupingSettings EnableColumnGrouping="True">
                            </GroupingSettings>
                            <Behaviors>
                                <ig:ColumnMoving Enabled="true"></ig:ColumnMoving>
                                <ig:Filtering Enabled="true"></ig:Filtering>
 <%--                               <ig:Paging EnableInheritance="True" PagerMode="NumericFirstLast"  QuickPages="10" FirstPageText="First" LastPageText="Last" PageSize="20">
                                </ig:Paging>--%>
                                <ig:Sorting Enabled="true" SortingMode="Single"></ig:Sorting>
                            </Behaviors>
                            <Columns>
                                <ig:TemplateDataField Key="Edit" Width="80px">
                                    <ItemTemplate>
                                        <%--<asp:LinkButton Text="Preview" runat="server" ToolTip="Preview" ID="lbPreviewVoucher" CommandName="Preview" CommandArgument='<%# Eval("Voucher_ID") %>' />--%>
                                        <%--<asp:HyperLink ToolTip="Edit" ID="hlPreviewVoucher" runat="server" NavigateUrl='<%# "Voucher.aspx?ID=" + Eval("Voucher_ID")+"&VoucherType=" + Eval("Voucher_Type")%>' Text="Preview" />--%>
                                         &nbsp;
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "~/AR/Invoice.aspx?ID=" + Eval("Invoice_ID")%>' Text="Edit" />
                                         &nbsp;
                                        <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Invoice_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />
                                    </ItemTemplate>
                                </ig:TemplateDataField>
                                <ig:BoundDataField Key="Invoice_No" DataFieldName="Invoice_No" Header-Text="Invoice No." Width="100px"></ig:BoundDataField>
                                <ig:BoundDataField Key="Invoice_Date" DataFieldName="Invoice_Date" Header-Text="Invoice Date" Width="150px" DataFormatString="{0:dd.MM.yyyy}"></ig:BoundDataField>
                               <ig:BoundDataField Key="Ref_No" DataFieldName="Ref_No" Header-Text="Ref No"></ig:BoundDataField>
                                 <ig:BoundDataField Key="Invoice_Status" DataFieldName="Invoice_Status" Header-Text="Invoice Status"></ig:BoundDataField>
                                <ig:BoundDataField Key="Customer_Name" DataFieldName="Customer_Name" Header-Text="Customer Name"></ig:BoundDataField>
                                <ig:BoundDataField Key="Remarks" DataFieldName="Remarks" Header-Text="Remarks"></ig:BoundDataField>
                                  <ig:BoundDataField Key="Invoice_Amount" DataFieldName="Invoice_Amount" Header-Text="Invoice Amount"></ig:BoundDataField>
                                <%-- <ig:BoundDataField Key="Voucher_Status" DataFieldName="Voucher_Status" Header-Text="Status" Width="70px"></ig:BoundDataField>--%>
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
