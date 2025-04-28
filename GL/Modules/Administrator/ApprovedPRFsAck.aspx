<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovedPRFsAck.aspx.cs" Inherits="PMS.ApprovedPRFsAck" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   
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
                var prnum = row.cells[1].innerText.toLowerCase();
                var prdate = row.cells[2].innerText.toLowerCase();
                var department = row.cells[3].innerText.toLowerCase();
                var remarks = row.cells[5].innerText.toLowerCase();
                var status = row.cells[6].innerText.toLowerCase();
              

                if (searchText.trim() === '' ||
                    prnum.includes(searchText) ||
                    prdate.includes(searchText) ||
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
                <asp:CheckBox ID="chkSelect" Text="" runat="server" />
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
         <asp:BoundField DataField="Department" HeaderText="Department" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" /> 
        <asp:BoundField DataField="Creator" HeaderText="Creator" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="120px" />
        <asp:TemplateField HeaderText="Remarks">
            <ItemTemplate>
                <asp:Label ID="lblRemarks" runat="server" Text='<%# Eval("Remarks") %>' CssClass="remarks-label"></asp:Label>
            </ItemTemplate>
            <ItemStyle Width="550px" />
        </asp:TemplateField>
        <asp:BoundField DataField="Status" HeaderStyle-Width="100px" HeaderStyle-HorizontalAlign="Center" HeaderText="Status" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="100px" />
        <asp:BoundField DataField="Approve_By" HeaderText="Approve By" ItemStyle-Width="180px" />
        <asp:TemplateField HeaderStyle-Width="80px">
            <HeaderTemplate>
                Actions
            </HeaderTemplate>
            <ItemTemplate>
                <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "../AP/PurchaseRequistion.aspx?ID="+ Eval("PR_Id")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
            </ItemTemplate>
            <HeaderStyle CssClass="header-center-align" />
        </asp:TemplateField>       
    </Columns>
    <HeaderStyle CssClass="gridview-header" />
</asp:GridView>
  </div>
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-4">
                  <asp:Button ID="btnPRNotify" CssClass="btn btn-primry" Text="PR Notify" runat="server" SkinID="btnAutoWidth" OnClick="btnPRNotify_Click" />
                </div>
              
            </div>
        </div>
    </div>
   
</asp:Content>
