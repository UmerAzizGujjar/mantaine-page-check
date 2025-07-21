<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePO.aspx.cs" Inherits="PMS.ApprovePO" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <style>
  #ctl00_MainContent_GridView1 tbody tr td table {
font-size:20px ;
    border-collapse: separate;
    border-spacing: 20px; /* Space between inner <td>s */
}
</style>

    <script type="text/javascript">        
        $(document).ready(function () {
            debugger
            $('#txt_search').keyup(function (e) {
                debugger
                var searchText = $('#txt_search').val().toLowerCase();
                var tbl = document.getElementById('ctl00_MainContent_GridView1');
                debugger
                for (var i = 1; i < tbl.rows.length; i++) {
                    var row = tbl.rows[i];
                    var ponum = row.cells[1].innerText.toLowerCase();
                    var podate = row.cells[2].innerText.toLowerCase();
                    var department = row.cells[3].innerText.toLowerCase();
                    var remarks = row.cells[5].innerText.toLowerCase();
                    var status = row.cells[6].innerText.toLowerCase();


                    if (searchText.trim() === '' ||
                        ponum.includes(searchText) ||
                        podate.includes(searchText) ||
                        remarks.includes(searchText) ||
                        status.includes(searchText) ||
                        department.includes(searchText)
                    ) {
                        row.style.display = '';
                    } else {
                        row.style.display = 'none';
                    }
                }
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="text" id="txt_search" style="width: 357px!important;" name="txt_search" placeholder="Search..." />
    <div class="table-container" style="overflow: scroll; height: 400px;">
        <asp:GridView ID="GridView1" CssClass="custom-gridview" runat="server" AutoGenerateColumns="False" EnableModelValidation="True">
            <Columns>
                <asp:TemplateField HeaderStyle-Width="30px">
                    <ItemTemplate>
                        <asp:CheckBox ID="chkSelect" Text="" runat="server" Width="30px" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="PO ID" Visible="False">
                    <ItemTemplate>
                        <asp:Label ID="lblPO_ID" runat="server" Text='<%# Bind("PO_ID") %>'></asp:Label>
                    </ItemTemplate>
                    <EditItemTemplate>
                        <asp:TextBox ID="txtPO_ID" runat="server" Text='<%# Bind("PO_ID") %>'></asp:TextBox>
                    </EditItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="PO_No" HeaderText="PO No." ItemStyle-HorizontalAlign="Center" ItemStyle-Width="70px" />
                <asp:BoundField DataField="PO_Date" HeaderText="PO Date" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="100px" />
                <asp:BoundField DataField="Department" HeaderText="Department" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" />
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
                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "~/Modules/AP/PurchaseOrder.aspx?PO_ID="+ Eval("PO_ID")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
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
                    <asp:Button ID="btnApprove" Text="Approve Selected PO" CssClass="btn btn-primry" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-4">
                    <asp:Button ID="btnCancel" Text="Reject Selected PO" CssClass="btn btn-primry" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />
                </div>
            </div>
        </div>
    </div>


</asp:Content>
