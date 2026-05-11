<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApproveGIR.aspx.cs" Inherits="PMS.ApproveGIR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- Optional: If you have a shared CSS file like Approvepr.css, link it -->
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Approvepr.css" rel="stylesheet" />

    


    <script type="text/javascript">
        $(document).ready(function () {

            highlightPendingRows();

            $('#txt_search').keyup(function (e) {
                var searchText = $(this).val().toLowerCase();
                var tbl = document.getElementById('<%= GridView1.ClientID %>');
                if (!tbl) return;

                for (var i = 1; i < tbl.rows.length; i++) {
                    var row = tbl.rows[i];
                    // Adjust cell indices based on visible columns
                    var requestNo = row.cells[1]?.innerText?.toLowerCase() || '';
                    var girDate = row.cells[2]?.innerText?.toLowerCase() || '';
                    var department = row.cells[3]?.innerText?.toLowerCase() || '';
                    var creator = row.cells[4]?.innerText?.toLowerCase() || '';
                    var remarks = row.cells[5]?.innerText?.toLowerCase() || '';
                    var status = row.cells[6]?.innerText?.toLowerCase() || '';

                    if (searchText.trim() === '' ||
                        requestNo.includes(searchText) ||
                        girDate.includes(searchText) ||
                        department.includes(searchText) ||
                        creator.includes(searchText) ||
                        remarks.includes(searchText) ||
                        status.includes(searchText)
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
                var statusCell = row.cells[6];

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
                <input type="text" id="txt_search" name="txt_search" placeholder="Search..." class="form-control" />
            </div>
            <div class="col-lg-2">
                <asp:Button ID="btnApprove" CssClass="btn btn-primry" Text="Approve Selected GIR" runat="server" OnClick="btnApprove_Click" />
            </div>
            <div class="col-lg-2">
                <asp:Button ID="btnCancel" CssClass="btn btn-primry" Text="Reject Selected GIR" runat="server" OnClick="btnCancel_Click" />
            </div>
        </div>
    </div>

    <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
        AllowPaging="True" PageSize="10"
        CssClass="gridview-style"
        PagerStyle-CssClass="pagination-container"
        PagerSettings-Mode="Numeric"
        OnPageIndexChanging="GridView1_PageIndexChanging">

        <Columns>
            <asp:TemplateField HeaderStyle-Width="30px">
                <ItemTemplate>
                    <asp:CheckBox ID="chkSelect" runat="server" />
                </ItemTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Material ID" Visible="False">
                <ItemTemplate>
                    <asp:Label ID="lblMAT_ID" runat="server" Text='<%# Bind("MaterialRequest_Id") %>'></asp:Label>
                </ItemTemplate>
            </asp:TemplateField>

            <asp:BoundField DataField="Request_No" HeaderText="Request No." ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px" ItemStyle-Width="100px" />

            <asp:BoundField DataField="MIRDate" HeaderText="GIR Date" DataFormatString="{0:d}" 
                ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px" ItemStyle-Width="100px" />

            <asp:BoundField DataField="Department" HeaderText="Department" 
                ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="150px" ItemStyle-Width="150px" />

            <asp:BoundField DataField="Creator" HeaderText="Creator" 
                ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="120px" ItemStyle-Width="120px" />

            <asp:TemplateField HeaderText="Remarks">
                <ItemTemplate>
                    <asp:Label ID="lblRemarks" runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
                </ItemTemplate>
                <ItemStyle Width="550px" />
            </asp:TemplateField>

            <asp:BoundField DataField="Status" HeaderText="Status" 
                ItemStyle-HorizontalAlign="Center" HeaderStyle-Width="100px" ItemStyle-Width="100px" />

            <asp:TemplateField HeaderText="Approve By" HeaderStyle-HorizontalAlign="Center">
                <ItemTemplate>
                    <div style="white-space: nowrap; overflow: auto; max-width: 180px;">
                        <asp:Label ID="lblApproveBy" runat="server" Text='<%# Eval("Approve_By") %>'></asp:Label>
                    </div>
                </ItemTemplate>
                <ItemStyle Width="180px" />
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Decision Remarks" HeaderStyle-Width="120px">
                <ItemTemplate>
                    <asp:TextBox ID="txtApproval_RejectionRemarks" runat="server" 
                        TextMode="MultiLine" CssClass="approval-remarks-textbox" Width="150px" Rows="2"></asp:TextBox>
                </ItemTemplate>
                <ItemStyle Width="150px" />
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Actions" HeaderStyle-Width="80px" HeaderStyle-HorizontalAlign="Center">
                <HeaderTemplate>Actions</HeaderTemplate>
                <ItemTemplate>
                    <asp:HyperLink ID="LinkButton3" runat="server" 
                        NavigateUrl='<%# ResolveUrl("~/Modules/Inventory/GoodsIssuanceRequest.aspx?ID=" + Eval("MaterialRequest_Id").ToString()) %>'
                        Text="Preview" Target="_blank" 
                        Style="display: block; width: 100%; text-align: center;" />
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
            <HeaderStyle CssClass="gridview-header" />
</asp:GridView>
<br />


</asp:Content>