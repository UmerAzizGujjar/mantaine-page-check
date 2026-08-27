<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PostVouchers.aspx.cs" Inherits="PMS.GL.PostVouchers" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var table = $('#<%= GridView1.ClientID %>');
            var hasDataRows = table.find('tbody tr td:not([colspan])').length > 0;

            if (hasDataRows) {
                table.DataTable({
                    order: [],
                    columnDefs: [
                        { orderable: false, targets: 0 },
                        { searchable: false, targets: 3 }
                    ],
                    pageLength: 10
                });
            }
        });

        // Preview Voucher function
        function PreviewVoucher() {
            var selected = [];
            var grid = document.getElementById('<%= GridView1.ClientID %>');
            if (!grid) {
                alert('Grid not found.');
                return false;
            }

            var rows = grid.getElementsByTagName('tr');

            // Loop through rows (skip header row)
            for (var i = 1; i < rows.length; i++) {
                var row = rows[i];
                // Checkbox is in the first cell
                var chk = row.cells[0].getElementsByTagName('input')[0];
                if (chk && chk.checked) {
                    // Get Voucher_ID from the hidden label (second cell)
                    var lblVoucher = row.cells[1].getElementsByTagName('span')[0];
                    var voucherId = lblVoucher ? lblVoucher.innerText || lblVoucher.textContent : '';
                    // Get Voucher_Type from the fourth cell (index 3)
                    var voucherType = row.cells[3] ? row.cells[3].innerText.trim() : '';
                    if (voucherId && voucherType) {
                        selected.push({ id: voucherId, type: voucherType });
                    }
                }
            }

            if (selected.length === 0) {
                alert('Please select a voucher to preview.');
                return false;
            }
            if (selected.length > 1) {
                alert('Please select only one voucher.');
                return false;
            }

            var vid = selected[0].id;
            var vtype = selected[0].type;
            // Redirect to Voucher.aspx with the selected voucher parameters
            window.location.href = 'Voucher.aspx?VID=' + encodeURIComponent(vid) + '&VoucherType=' + encodeURIComponent(vtype);
            return false; // prevent postback
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Un-posted Vouchers List</h1>
    <div style="overflow-x:auto; overflow-y:auto; max-height:500px; width:100%;">
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" 
            EnableModelValidation="True" CssClass="table table-hover table-striped table-bordered dataTable no-footer"
            OnRowCreated="GridView1_RowCreated">
            <EmptyDataTemplate>
                <tr>
                    <td colspan="5" style="text-align: center; padding: 20px; color: #666;">
                        No vouchers with status "Created" found for approval.
                    </td>
                </tr>
            </EmptyDataTemplate>
            <Columns>
                <asp:TemplateField>
                    <ItemTemplate>
                        <asp:CheckBox ID="chkSelect" Text="" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Voucher ID">
                    <ItemTemplate>
                        <asp:Label ID="lblVoucher_ID" runat="server" Text='<%# Bind("Voucher_ID") %>' Style="display:none;"></asp:Label>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="Voucher_No" HeaderText="Voucher No." />
                <asp:BoundField DataField="Voucher_Type" HeaderText="Voucher Type" />
                <asp:BoundField DataField="Voucher_Date" HeaderText="Voucher Date" DataFormatString="{0: dd MMM yyyy}" />
                <asp:BoundField DataField="Remarks" HeaderText="Remarks">
                    <ItemStyle Width="550px" />
                </asp:BoundField>
            </Columns>
        </asp:GridView>
        <br />
    </div>

    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Button ID="btnApprove" CssClass="btn btn-primry" Text="Approve Vouchers" runat="server"
                        OnClick="btnApprove_Click" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Button ID="btnCancel" CssClass="btn btn-primry" Text="Delete Vouchers" runat="server"
                        OnClick="btnCancel_Click" />
                </div>
                <!-- NEW PREVIEW BUTTON -->
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Button ID="btnPreview" CssClass="btn btn-primry" Text="Preview Voucher" runat="server"
                        OnClientClick="return PreviewVoucher();" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>