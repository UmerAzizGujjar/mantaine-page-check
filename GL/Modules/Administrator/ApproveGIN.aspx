<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveGIN.aspx.cs" Inherits="PMS.ApproveGIN" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <style>
  #ctl00_MainContent_GridView1 tbody tr td table {
font-size:20px ;
    border-collapse: separate;
    border-spacing: 20px; /* Space between inner <td>s */
}
</style>
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
            <asp:TemplateField HeaderText="Store ID" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblStore_ID" runat="server" Text='<%# Bind("Store_Issue_Id") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtStore_ID" runat="server" Text='<%# Bind("Store_Issue_Id") %>'></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="Store_Issue_No" HeaderText="Store Issue No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
            <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
            <asp:BoundField DataField="Status" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <asp:BoundField DataField="Approve_By" HeaderText="Approve By" ItemStyle-Width="180px" />
            <asp:TemplateField>
                <HeaderTemplate>
                    <div style="width: 100px; text-align: center;">
                        Actions
                    </div>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../Inventory/GoodsIssuanceNote.aspx?SI_ID="+ Eval("Store_Issue_Id")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
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
                    <asp:Button ID="btnApprove" Text="Approve Selected GIN" CssClass="btn btn-primry" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-4">


                    <asp:Button ID="btnCancel" Text="Reject Selected GIN" runat="server" CssClass="btn btn-primry" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
                </div>
            </div>
        </div>
    </div>


</asp:Content>
