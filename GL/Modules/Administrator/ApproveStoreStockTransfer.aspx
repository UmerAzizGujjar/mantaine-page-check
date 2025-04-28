<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveStoreStockTransfer.aspx.cs" Inherits="PMS.ApproveStoreStockTransfer" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <div class="table-container" style="overflow: scroll; height: 400px;">
                    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" EnableModelValidation="True" PageSize="15" AllowPaging="true" OnPageIndexChanging="GridView1_PageIndexChanging">
    <Columns>
        <asp:TemplateField>
            <ItemTemplate>
                <asp:CheckBox ID="chkSelect" Text="" runat="server" />
            </ItemTemplate>
        </asp:TemplateField>
        <asp:TemplateField HeaderText="Stock Transfer ID" Visible="False">
            <ItemTemplate>
                <asp:Label ID="lblStock_Transfer_ID" runat="server" Text='<%# Bind("Stock_Transfer_ID") %>'></asp:Label>
            </ItemTemplate>
            <EditItemTemplate>
                <asp:TextBox ID="txtStock_Transfer_ID" runat="server" Text='<%# Bind("Stock_Transfer_ID") %>'></asp:TextBox>
            </EditItemTemplate>
        </asp:TemplateField>
        <asp:BoundField DataField="Stock_Transfer_No" HeaderText="Stock Transfer No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" /> 
          <asp:BoundField DataField="Stock_Transfer_Date" HeaderText="Transfer Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="120px" />
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
            <HeaderTemplate >
                <div style="width: 100px; text-align: center;">
                    Actions
                </div>
            </HeaderTemplate>
            <ItemTemplate>
                <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../Inventory/StoreStockTransfer.aspx?stID="+ Eval("Stock_Transfer_ID")%>' Text="Preview" Target="_blank" style="display: block; width: 100%; text-align: center;" />
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
       <div class="row">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-3 col-md-3 col-sm-4">
                          <asp:Button ID="btnApprove" CssClass="btn btn-primry" Text="Approve Selected StockTransfer" runat="server" SkinID="btnAutoWidth" onclick="btnApprove_Click" />
                        </div>
                        <div class="col-lg-3 col-md-3 col-sm-4">
<asp:Button ID="btnCancel" CssClass="btn btn-primry" Text="Reject Selected StockTransfer" runat="server" SkinID="btnAutoWidth" onclick="btnCancel_Click" />
                        </div>
                    </div>
                </div>
            </div>



</asp:Content>
