<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePO.aspx.cs" Inherits="PMS.ApprovePO" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .custom-gridview {
            table-layout: fixed;
            word-wrap: break-word;
            width: 100%;
            border-collapse: collapse;
        }

            .custom-gridview .gridview-header {
                background-color: #449777;
                color: white;
                font-weight: bold;
                padding: 10px;
                align-items: center;
                text-align: center;
            }

            .custom-gridview th, .custom-gridview td {
                white-space: nowrap;
                overflow: hidden;
                text-overflow: ellipsis;
                padding: 8px;
/*                border: 1px solid #ddd;*/
            }

            .custom-gridview tr:nth-child(even) {
                background-color: #f2f2f2;
            }

            .custom-gridview tr:hover {
/*                background-color: #ddd;*/
            }

            .custom-gridview .actions-column {
                width: 100px;
                text-align: center;
            }

            .custom-gridview a {
                color: #308667;
                text-decoration: none;
            }

                .custom-gridview a:hover {
                    text-decoration: none;
                }

        .remarks-label {
            display: block;
            white-space: normal;
            word-wrap: break-word;
        }
      .pager-style {
      text-align: center;
      margin-top: 15px;
  }

      .pager-style table {
          margin: auto;
      }

      .pager-style td {
          padding: 5px 0px;
          font-size: 16px;
      }

      .pager-style a,
      .pager-style span {
          display: inline-block;
          padding: 8px 12px;
          margin: 0 5px;
/*          border-radius: 5px;*/
/*          border: 1px solid #ddd;*/
          background-color: #f8f8f8;
          color: #333;
          font-size: 14px;
          text-decoration: none;
          transition: all 0.3s ease;
      }

          .pager-style a:hover {
              background-color: #449777;
              color: white;
          }

      .pager-style span {
          background-color: #449777;
          color: white;
          font-weight: bold;
/*          border: 1px solid #449777;*/
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
                    var remarks = row.cells[4].innerText.toLowerCase();
                    var status = row.cells[5].innerText.toLowerCase();
                    var department = row.cells[8].innerText.toLowerCase();

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
     <div class="row">
     <div class="col-lg-8">
         <div class="col-lg-2">

            <input type="text" id="txt_search"  name="txt_search" placeholder="Search..." />
         </div>
         <div class="col-lg-2">
               <asp:Button ID="btnApprove" class="btn btn-primry" Text="Approve Selected PO" runat="server" SkinID="btnAutoWidth" OnClick="btnApprove_Click" />
           
         </div>
         <div class="col-lg-2">
              <asp:Button ID="btnCancel" class="btn btn-primry" Text="Reject Selected PO" runat="server" SkinID="btnAutoWidth" OnClick="btnCancel_Click" />


         </div>
     </div>
 </div>



    
   <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
    AllowPaging="True" PageSize="10"
    CssClass="custom-gridview"
    PagerStyle-CssClass="pagination-container"
    PagerSettings-Mode="Numeric"
    OnPageIndexChanging="GridView1_PageIndexChanging">
        <PagerSettings Mode="NumericFirstLast" NextPageText="Next »" PreviousPageText="« Previous"
            FirstPageText="« First" LastPageText="Last »" />

       <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
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
                    <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# "./AP/PurchaseOrder.aspx?PO_ID="+ Eval("PO_ID")%>' Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
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
        </Columns>
        <PagerSettings Mode="NumericFirstLast" FirstPageText="First" LastPageText="Last" />
        <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
        <HeaderStyle BackColor="#449777" ForeColor="White" Font-Size="14px" />
        <RowStyle CssClass="gridview-row" />
        <AlternatingRowStyle CssClass="gridview-alt-row" />
    </asp:GridView>
    <br />
  
   
</asp:Content>
