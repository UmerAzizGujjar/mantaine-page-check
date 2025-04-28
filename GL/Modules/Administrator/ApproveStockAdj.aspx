<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveStockAdj.aspx.cs" Inherits="PMS.ApproveStockAdj" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container" style="overflow: scroll; height: 400px;">
        <div class="col-lg-12 col-md-12 col-sm-12">
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" EnableModelValidation="True" PageSize="15" AllowPaging="true" OnPageIndexChanging="GridView1_PageIndexChanging">
                <Columns>
                    <asp:TemplateField>
                        <ItemTemplate>
                            <asp:CheckBox ID="chkSelect" Text="" runat="server" />
                        </ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Adjustment ID" Visible="False">
                        <ItemTemplate>
                            <asp:Label ID="lblAdjustment_ID" runat="server" Text='<%# Bind("Adjustment_ID") %>'></asp:Label>
                        </ItemTemplate>
                        <EditItemTemplate>
                            <asp:TextBox ID="txtAdjustment_ID" runat="server" Text='<%# Bind("Adjustment_ID") %>'></asp:TextBox>
                        </EditItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="Adjustment_No" HeaderText="Adj No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
                    <asp:BoundField DataField="Adjustment_Date" HeaderText="Adjustment Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="120px" />
                    <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
                    <asp:TemplateField HeaderText="Remarks">
                        <ItemTemplate>
                            <asp:Label ID="lblRemarks" runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
                        </ItemTemplate>
                        <ItemStyle Width="550px" />
                    </asp:TemplateField>
                    <asp:BoundField DataField="Status" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
                    <asp:BoundField DataField="Approve_By" HeaderText="Approve By" ItemStyle-Width="180px" />
                    <asp:TemplateField>
                        <HeaderTemplate>
                            <div style="width: 100px; text-align: center;">
                                Actions
                            </div>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../Inventory/StockAdjustment.aspx?ID="+ Eval("Adjustment_ID")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
                        </ItemTemplate>
                        <HeaderStyle CssClass="header-center-align" />
                    </asp:TemplateField>
                </Columns>
                <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" />
                <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
                <HeaderStyle BackColor="#438eb9 " ForeColor="White" Font-Size="14px" />
                <RowStyle CssClass="gridview-row" />
                <AlternatingRowStyle CssClass="gridview-alt-row" />
            </asp:GridView>
           



        </div>

    </div>
             <div class="row">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-3 col-md-3 col-sm-4">
                            <asp:Button ID="btnApprove"  CssClass="btn btn-primry" Text="Approve Selected StockAdj" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
                        </div>
                        <div class="col-lg-3 col-md-3 col-sm-4">


                            <asp:Button ID="btnCancel"  CssClass="btn btn-primry" Text="Reject Selected StockAdj" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
                        </div>
                    </div>
                </div>
            </div>

</asp:Content>
