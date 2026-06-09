<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePR.aspx.cs" Inherits="PMS.ApprovePR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Approvepr.css" rel="stylesheet" />
    <script type="text/javascript">        
        $(document).ready(function () {
            highlightPendingRows();

            $('#txt_search').keyup(function (e) {
                var searchText = $('#txt_search').val().toLowerCase();
                var tbl = document.getElementById('<%= GridView1.ClientID %>');
        
        if (!tbl) return;

        for (var i = 1; i < tbl.rows.length; i++) {
            var row = tbl.rows[i];
            
            // Fix column indices (0-based)
            var prnum = row.cells[1] ? row.cells[1].innerText.toLowerCase() : "";      // PR No.
            var prdate = row.cells[2] ? row.cells[2].innerText.toLowerCase() : "";      // PR Date
            var creator = row.cells[3] ? row.cells[3].innerText.toLowerCase() : "";     // Creator
            var remarks = row.cells[4] ? row.cells[4].innerText.toLowerCase() : "";     // Remarks (index 4)
            var status = row.cells[5] ? row.cells[5].innerText.toLowerCase() : "";      // Status (index 5)
            var approveBy = row.cells[6] ? row.cells[6].innerText.toLowerCase() : "";   // Approve By (index 6)
            // Department is at index 8 but it's visible false, so it won't be in the DOM
            // Decision remarks is at index 7 but it's a TextBox

            if (searchText.trim() === '' ||
                prnum.includes(searchText) ||
                prdate.includes(searchText) ||
                creator.includes(searchText) ||
                remarks.includes(searchText) ||
                status.includes(searchText) ||
                approveBy.includes(searchText)
            ) {
                row.style.display = '';
            } else {
                row.style.display = 'none';
            }
        }
    });
});

function highlightPendingRows() {
    var tbl = document.getElementById('<%= GridView1.ClientID %>');
    if (!tbl) return;

    for (var i = 1; i < tbl.rows.length; i++) {
        var row = tbl.rows[i];
        var statusCell = row.cells[5];

        if (statusCell) {
            var statusText = statusCell.innerText.trim().toLowerCase();
            if (statusText === "pending") {
                row.style.backgroundColor = "#ffe066";
            }
        }
    }
}
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-8">
            <div class="col-lg-2">

                <input type="text" id="txt_search" name="txt_search" placeholder="Search..." />
            </div>
            <div class="col-lg-2">

                <asp:Button ID="btnApprove" class="btn btn-primry" Text="Approve Selected PR" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />

            </div>
            <div class="col-lg-2">

                <asp:Button ID="btnCancel" class="btn btn-primry" Text="Reject Selected PR" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />

            </div>
        </div>
    </div>
    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
        AllowPaging="True" PageSize="10"
        CssClass="gridview-style"
        PagerStyle-CssClass="pagination-container"
        PagerSettings-Mode="Numeric"
        OnPageIndexChanging="GridView1_PageIndexChanging"
        OnRowCommand="GridView1_RowCommand">
     
        <Columns>
            <asp:TemplateField HeaderStyle-Width="30px">
                <ItemTemplate>
                    <asp:CheckBox ID="chkSelect" Text="" runat="server" ItemStyle-HorizontalAlign="Center" />
                    <asp:Button ID="btnBypass" runat="server" Text="Bypass" CssClass="btn-primry btn" Visible="false" CommandName="Bypass" CommandArgument='<%# Eval("PR_Id") %>' OnClientClick="var r = prompt('Enter Bypass Remarks:'); if (r == null || r.trim() == '') return false; $(this).closest('tr').find('.approval-remarks-textbox').val(r); return true;" />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="PR ID" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblPR_ID" runat="server" Text='<%# Bind("PR_Id") %>'></asp:Label>
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtPR_ID" runat="server" Text='<%# Bind("PR_Id") %>'></asp:TextBox>
                </EditItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="PR_Num" HeaderText="PR No." ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="70px" ItemStyle-Width="70px" />
            <asp:BoundField DataField="PRDate" HeaderText="PR Date" HeaderStyle-Width="100px" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:d}" ItemStyle-Width="100px" />
            <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
            <asp:TemplateField HeaderText="Remarks">
                <ItemTemplate>
                    <asp:Label ID="lblRemarks"  runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
                </ItemTemplate>
                <ItemStyle Width="550px" />
            </asp:TemplateField>
            <asp:BoundField DataField="Status" HeaderStyle-Width="100px" HeaderStyle-HorizontalAlign="Center" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <%--<asp:BoundField DataField="Approve_By" HeaderText="Approve By" ItemStyle-Width="180px" />--%>
            <asp:TemplateField HeaderStyle-HorizontalAlign="Center" HeaderText="Approve By">
                <ItemTemplate>
                    <div style="white-space: nowrap; overflow: auto; max-width: 180px;">
                        <asp:Label ID="lblApproveBy" runat="server" Text='<%# Eval("Approve_By") %>'></asp:Label>
                    </div>
                </ItemTemplate>
                <ItemStyle Width="180px" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Decision Remarks" HeaderStyle-Width="120px">
                <ItemTemplate>
                    <asp:TextBox ID="txtApproval_RejectionRemarks" runat="server" Width="100px" TextMode="MultiLine" CssClass="approval-remarks-textbox"></asp:TextBox>
                </ItemTemplate>
                <ItemStyle Width="300px" />
            </asp:TemplateField>
            <asp:TemplateField HeaderStyle-Width="80px">
                <HeaderTemplate>
                    Actions
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# ResolveUrl("~/Modules/AP/PurchaseRequistion.aspx?ID=" + Eval("PR_Id").ToString()) %>'
                        Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
                </ItemTemplate>
                <HeaderStyle CssClass="header-center-align" />
            </asp:TemplateField>
            <asp:BoundField DataField="Department" HeaderText="Department" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" />
            <asp:BoundField DataField="TotalPRAmount" HeaderText="TotalPRAmt" HeaderStyle-Width="100px" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <asp:BoundField DataField="TotalBudget" HeaderText="TotalBudget" HeaderStyle-Width="100px" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <asp:BoundField DataField="RemainingAmount" HeaderText="Balance" HeaderStyle-Width="100px" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
            <asp:TemplateField HeaderText="RemainingAmount" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblRemainingAmount" runat="server" Text='<%# Bind("RemainingAmount") %>'></asp:Label>
                </ItemTemplate>
             </asp:TemplateField>
             <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblPRAmount" runat="server" Text='<%# Bind("PRAmount") %>'></asp:Label>
                </ItemTemplate>
             </asp:TemplateField>
             <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblUserApprovalLimit" runat="server" Text='<%# Bind("UserApprovalLimit") %>'></asp:Label>
                </ItemTemplate>
             </asp:TemplateField>
             <asp:TemplateField Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblCanApprove" runat="server" Text='<%# Bind("CanApprove") %>'></asp:Label>
                </ItemTemplate>
             </asp:TemplateField>
        </Columns>
        <HeaderStyle CssClass="gridview-header" />
    </asp:GridView>
    <br />
  

</asp:Content>
