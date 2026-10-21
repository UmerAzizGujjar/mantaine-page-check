<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovePO.aspx.cs" Inherits="PMS.ApprovePO" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css?v=<%= ((PMS.SiteMaster)Master).Ver("~/wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css") %>" rel="stylesheet" />
    <style type="text/css">
        /* below laptop width the fixed-layout grid would squeeze every column to a few pixels:
           keep it readable and scroll it sideways inside its own box instead */
        @media screen and (max-width: 1199px) {
            .main div:has(> .custom-gridview) {
                overflow-x: auto;
            }

            .main .custom-gridview {
                min-width: 1100px;
            }
        }

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
            // Call highlight function when page loads
            setTimeout(function () {
                highlightPendingRows();
        }, 100);

            $('#<%= GridView1.ClientID %>').on('change', 'input[type="checkbox"][id*="chkSelect"]', function () {
                var anyChecked = $('#<%= GridView1.ClientID %> input[type="checkbox"][id*="chkSelect"]:checked').length > 0;
                $('#btnSaveCheckbox').prop('disabled', anyChecked);
            });

            $('#txt_search').keyup(function (e) {
            var searchText = $('#txt_search').val().toLowerCase();
            var tbl = document.getElementById('<%= GridView1.ClientID %>');
            var getCellText = function (row, index) {
                var cell = row.cells[index];
                return cell ? cell.innerText.toLowerCase() : '';
            };

            for (var i = 1; i < tbl.rows.length; i++) {
                var row = tbl.rows[i];
                var ponum = getCellText(row, 1);
                var podate = getCellText(row, 2);
                var poamount = getCellText(row, 3);
                var creator = getCellText(row, 4);
                var remarks = getCellText(row, 5);
                var status = getCellText(row, 6);
                var approveBy = getCellText(row, 7);
                var actions = getCellText(row, 8);

                if (searchText.trim() === '' ||
                    ponum.includes(searchText) ||
                    podate.includes(searchText) ||
                    poamount.includes(searchText) ||
                    creator.includes(searchText) ||
                    remarks.includes(searchText) ||
                    status.includes(searchText) ||
                    approveBy.includes(searchText) ||
                    actions.includes(searchText)
                ) {
                    row.style.display = '';
                    // Re-apply highlighting after search
                    if (status === 'pending') {
                        row.style.backgroundColor = "#ffe066";
                    } else {
                        // Reset background for non-pending rows
                        if (row.style.backgroundColor === "rgb(255, 224, 102)" || row.style.backgroundColor === "#ffe066") {
                            row.style.backgroundColor = "";
                        }
                    }
                } else {
                    row.style.display = 'none';
                }
            }
        });

        function highlightPendingRows() {
            var tbl = document.getElementById('<%= GridView1.ClientID %>');
            if (!tbl) return;

            console.log("GridView found, rows count: " + tbl.rows.length);

            for (var i = 1; i < tbl.rows.length; i++) {
                var row = tbl.rows[i];
            var statusCell = row.cells[6];

            console.log("Row " + i + " - Status cell text: " + (statusCell ? statusCell.innerText : "null"));

            if (statusCell) {
                    var statusText = statusCell.innerText.trim().toLowerCase();
            // Check for "pending" (case-insensitive)
            if (statusText === "pending") {
                row.style.backgroundColor = "#ffe066";
            console.log("Row " + i + " highlighted as pending");
                    } else {
                // Reset background for rows that are not pending
                row.style.backgroundColor = "";
                    }
                }
            }
        }

            // Make the function available globally for postbacks
            window.highlightPendingRows = highlightPendingRows;
            });


        function saveEditableCheckboxes() {
            var selectedIds = [];
            var checkValues = [];

            var tbl = document.getElementById('<%= GridView1.ClientID %>');
            if (!tbl) {
                alert('Grid not found');
                return;
            }

            var hasPending = false;

            for (var i = 1; i < tbl.rows.length; i++) {
                var row = tbl.rows[i];

                // Find the PO ID - read from the hidden field in the row
                var hf = row.querySelector('input[type="hidden"][id*="hfPO_ID"]');
                if (!hf) {
                    console.log('Row ' + i + ' - No PO ID found');
                    continue;
                }
                var poId = hf.value;
                poId = poId.trim();
                console.log('Row ' + i + ' - PO ID: "' + poId + '"');

                // Get Status - at index 6
                var statusCell = row.cells[6];
                if (!statusCell) {
                    console.log('Row ' + i + ' - No status cell at index 6');
                    continue;
                }
                var status = statusCell.innerText.trim().toLowerCase();
                console.log('Row ' + i + ' - Status: "' + status + '"');

                // Check for 'pending' OR 'created'
                if (status === 'pending' || status === 'created') {
                    hasPending = true;

                    // Find the editable checkbox
                    var checkboxes = row.querySelectorAll('input[type="checkbox"]');
                    var editableCheckbox = null;

                    // Look for checkbox with 'chkEditableAfterApproval' in the ID
                    for (var c = 0; c < checkboxes.length; c++) {
                        var chk = checkboxes[c];
                        if (chk.id && chk.id.indexOf('chkEditableAfterApproval') !== -1) {
                            editableCheckbox = chk;
                            break;
                        }
                    }

                    // If not found, use the last checkbox in the row (fallback)
                    if (!editableCheckbox && checkboxes.length > 1) {
                        editableCheckbox = checkboxes[checkboxes.length - 1];
                    }

                    if (editableCheckbox) {
                        selectedIds.push(poId);
                        checkValues.push(editableCheckbox.checked ? 'true' : 'false');
                        console.log('Row ' + i + ' - Added PO ' + poId + ' with value: ' + editableCheckbox.checked);
                    } else {
                        console.log('Row ' + i + ' - No editable checkbox found');
                    }
                }
            }

            console.log('Selected IDs: ' + selectedIds.join(', '));
            console.log('Check Values: ' + checkValues.join(', '));

            if (!hasPending) {
                alert('No pending or created PO rows found on this page.');
                return;
            }

            if (selectedIds.length === 0) {
                alert('No checkboxes found to save. Please make sure the "Editable After Approval" column is added.');
                return;
            }

            $('#btnSaveCheckbox').prop('disabled', true).val('Saving...');

            $.ajax({
                type: "POST",
                url: "ApprovePO.aspx/SaveEditableSettings",
                data: JSON.stringify({
                    poIds: selectedIds.join(','),
                    checkValues: checkValues.join(',')
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    $('#btnSaveCheckbox').prop('disabled', false).val('Save Checkbox');
                    if (response.d === "Success") {
                        alert('Editable settings saved successfully for ' + selectedIds.length + ' PO(s)!');
                        location.reload();
                    } else {
                        alert('Error: ' + response.d);
                    }
                },
                error: function (xhr, status, error) {
                    $('#btnSaveCheckbox').prop('disabled', false).val('Save Checkbox');
                    alert('Error saving checkbox settings: ' + error);
                }
            });
        }
    </script>
    <script type="text/javascript">
        // Show the PO grid as a DataTable. Display only: the GridView, its server paging, the search box
        // and the approve / reject / save code above all keep working on the same rows and cells.
        $(document).ready(function () {
            var tbl = document.getElementById('<%= GridView1.ClientID %>');
            if (!tbl || !$.fn.DataTable || $.fn.DataTable.isDataTable(tbl)) return;

            // GridView writes its header row into <tbody>; DataTables needs it in <thead>
            var body = tbl.tBodies[0];
            if (!tbl.tHead && body && body.rows.length && body.rows[0].cells.length && body.rows[0].cells[0].tagName === 'TH') {
                tbl.createTHead().appendChild(body.rows[0]);
            }
            if (!tbl.tHead) return;

            // the numeric pager is a single colspan row inside the table: move it just below the table (its links still post back)
            var cols = tbl.tHead.rows[0].cells.length;
            $(tbl.tBodies[0].rows).filter(function () { return this.cells.length === 1 && this.cells[0].colSpan === cols; }).each(function () {
                var pager = $('<div class="pager-style"></div>').append($(this.cells[0]).children());
                $(this).remove();
                pager.insertAfter(tbl);
            });

            $(tbl).DataTable({
                paging: false,      // the GridView pages on the server
                searching: false,   // the page has its own search box (#txt_search)
                info: false,
                autoWidth: false,
                order: [],          // keep the server's row order until a header is clicked
                columnDefs: [{ targets: [0, -2, -1], orderable: false }]
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
        <div class="col-lg-2">
            <input type="button" id="btnSaveCheckbox" class="btn btn-primry" value="Save Checkbox" onclick="saveEditableCheckboxes()" style="background-color: #17a2b8; color: white; border-color: #17a2b8;" />
        </div>
    </div>
</div>



    
   <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False"
    AllowPaging="True" PageSize="10"
    CssClass="custom-gridview"
    PagerStyle-CssClass="pagination-container"
    PagerSettings-Mode="Numeric"
    OnPageIndexChanging="GridView1_PageIndexChanging"
    OnRowDataBound="GridView1_RowDataBound">
        <PagerSettings Mode="NumericFirstLast" NextPageText="Next »" PreviousPageText="« Previous"
            FirstPageText="« First" LastPageText="Last »" />

       <PagerStyle HorizontalAlign="Right" CssClass="pager-style" />
        <Columns>
            <asp:TemplateField HeaderStyle-Width="30px">
                <ItemTemplate>
                    <asp:CheckBox ID="chkSelect" Text="" runat="server" Width="30px" />
                    <asp:HiddenField ID="hfPO_ID" runat="server" Value='<%# Eval("PO_ID") %>' />
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
            <asp:BoundField DataField="PO_Amount" HeaderText="PO Amount" ItemStyle-HorizontalAlign="Center" DataFormatString="{0:N2}" ItemStyle-Width="120px" />
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
                    <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# ResolveUrl("~/Modules/AP/PurchaseOrder.aspx?PO_ID=" + Eval("PO_ID").ToString()) %>'
                        Text="Preview" Target="_blank" Style="display: block; width: 100%; text-align: center;" />
                </ItemTemplate>
                <HeaderStyle CssClass="header-center-align" />
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Editable After Approval" ItemStyle-Width="150px" ItemStyle-HorizontalAlign="Center">
                <HeaderTemplate>
                    <div style="text-align: center; font-weight: bold; font-size: 11px;">Editable After<br />
                        Approval</div>
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:CheckBox ID="chkEditableAfterApproval" runat="server"
                        Checked='<%# Eval("IsEditableAfterApproval") != DBNull.Value && Convert.ToBoolean(Eval("IsEditableAfterApproval")) %>'
                        Enabled='<%# Eval("Status") != null && Eval("Status").ToString().ToLower() == "pending" %>' />
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="Department" HeaderText="Department" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" />
            <asp:BoundField DataField="WareHouse" HeaderText="Warehouse" Visible="False" ItemStyle-HorizontalAlign="Center" ItemStyle-Width="150px" />
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
