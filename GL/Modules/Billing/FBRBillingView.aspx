<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FBRBillingView.aspx.cs" Inherits="PMS.FBRBillingView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
         <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
      <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
    <style>
        .filter-container {
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
            flex-wrap: wrap;
        }
        .filter-container label {
            margin-bottom: 0;
            font-weight: 600;
        }
        .table-container {
            overflow-x: hidden  !important;
        }
        .detail-row {
            background-color: #f9f9f9;
            border-left: 3px solid #007bff;
        }
        .detail-container {
            padding: 15px;
        }
        .category-section {
            margin-bottom: 15px;
        }
        .category-title {
            font-weight: bold;
            background-color: #e9ecef;
            padding: 8px;
            margin-bottom: 5px;
        }
        .item-row {
            padding: 5px 10px;
            border-bottom: 1px solid #dee2e6;
        }
        .item-checkbox {
            margin-right: 10px;
        }
        .post-fbr-btn {
            margin-top: 10px;
            padding: 8px 20px;
            background-color: #28a745;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .post-fbr-btn:hover {
            background-color: #218838;
        }
        .clickable-row {
            cursor: pointer;
        }
        .clickable-row:hover {
            background-color: #f0f8ff;
        }
        .posted-row {
            background-color: #d4edda !important;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "FBRBillingView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });

            var table = $("#tbloutPatients").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    'copy',
                    'excel',
                    'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    var startDate = $('#txtStartDate').val();
                    var endDate = $('#txtEndDate').val();

                    $.ajax({
                        type: "POST",
                        url: "FBRBillingView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            startDate: startDate,
                            endDate: endDate
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Bill_ID", "visible": false, "width": "0%" },
                    { "data": "Bill_No", "name": "Bill_No", "width": "5%", "orderable": true },
                    { "data": "BillType", "name": "BillType", "width": "8%", "orderable": false },
                    {
                        "data": "Bill_Date", "name": "Bill_Date",
                        "render": function (data, type, full) {
                            var date = full.Bill_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "7%", "orderable": true
                    },
                    { "data": "MrNo", "name": "MrNo", "width": "7%", "orderable": true },
                    { "data": "Full_Name", "width": "15%", "orderable": false },
                    { "data": "Total_Amount", "width": "10%", "orderable": false },
                    { "data": "Discount_Percentage", "width": "10%", "orderable": false },
                    { "data": "Discount_Amount", "width": "10%", "orderable": false },
                    { "data": "Net_Amount", "width": "8%", "orderable": false },
                    { "data": "Received_Amount", "name": "Received_Amount", "width": "10%", "orderable": false },
                    { "data": "Balance_Amount", "width": "8%", "orderable": false },
                    { "data": "Operator", "visible": false, "width": "8%", "orderable": false }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-bill-id', data.Bill_ID);
                    if (data.IsPosted) {
                        $(row).addClass('posted-row');
                    }
                },
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

                    var lengthContainer = document.querySelector('#tbloutPatients_length');
                    var lengthDropdown = document.querySelector('#tbloutPatients_length select');
                    var label = document.querySelector('#tbloutPatients_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        var labelText = document.createElement('span');
                        labelText.textContent = 'Show entries ';
                        labelText.style.marginTop = '10px';
                        labelText.style.display = 'inline-block';

                        lengthDropdown.style.width = '60px';
                        label.innerHTML = '';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '17px';
                        label.appendChild(labelText);
                        label.appendChild(lengthDropdown);
                    }
                }
            });

            // Row click event
            $('#tbloutPatients tbody').on('click', 'tr.clickable-row', function () {
                var tr = $(this);
                var row = table.row(tr);
                var rowData = row.data();
                var billId = tr.attr('data-bill-id');
                var isPosted = rowData && rowData.IsPosted;

                if (row.child.isShown()) {
                    row.child.hide();
                    tr.removeClass('shown');
                } else {
                    // Close any open rows
                    table.rows().every(function () {
                        if (this.child.isShown()) {
                            this.child.hide();
                            $(this.node()).removeClass('shown');
                        }
                    });

                    // Show loading message
                    row.child('<div style="padding:20px;text-align:center;">Loading...</div>').show();
                    tr.addClass('shown');

                    // Load bill details
                    var qrPath = rowData && rowData.QrCode_path ? rowData.QrCode_path : '';
                    var fbrNo = rowData && rowData.FBR_No ? rowData.FBR_No : '';
                    LoadBillDetails(billId, row, tr, isPosted, qrPath, fbrNo);
                }
            });

            // Post to FBR button (delegated so it works inside DataTables child rows)
            $(document).on('click', '.post-fbr-btn', function (e) {
                e.preventDefault();
                e.stopPropagation();
                PostToFBR($(this).attr('data-bill-id'), this);
            });

            $('#btnApplyDateFilter').on('click', function () {
                table.ajax.reload();
            });
        }

        function LoadBillDetails(billId, row, tr, isPosted, qrPath, fbrNo) {
            $.ajax({
                type: "POST",
                url: "FBRBillingView.aspx/GetBillDetails",
                data: JSON.stringify({ billId: billId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var details = JSON.parse(response.d);
                        var html = BuildDetailsHTML(details, billId, isPosted, qrPath, fbrNo);
                        row.child(html).show();
                    }
                },
                error: function (xhr, status, error) {
                    row.child('<div style="padding:20px;color:red;">Error loading details</div>').show();
                    console.log(xhr.responseText);
                }
            });
        }

        function BuildDetailsHTML(details, billId, isPosted, qrPath, fbrNo) {
            var html = '<div class="detail-container">';

            // Group by category
            var categories = {
                'Services': [],
                'Lab Tests': [],
                'Radiology': [],
                'Pharmacy': [],
                'Consultation': [],
                'Other': []
            };

            details.forEach(function (item) {
                var category = 'Other';
                if (item.Item_Type === 'Services') {
                    category = 'Services';
                } else if (item.Item_Type === 'Test') {
                    if (item.Test_Main_Department === '001') {
                        category = 'Lab Tests';
                    } else {
                        category = 'Radiology';
                    }
                } else if (item.Item_Type === 'Pharmacy') {
                    category = 'Pharmacy';
                } else if (item.Item_Type === 'Consultation') {
                    category = 'Consultation';
                }
                categories[category].push(item);
            });

            // Start Table Structure
            html += '<table class="details-table" style="width: 100%; border-collapse: collapse; text-align: left; font-family: sans-serif;">';

            // Table Headers
            html += '<thead>';
            html += '<tr style="background-color: #f4f4f4; border-bottom: 2px solid #ddd;">';
            html += '<th style="padding: 10px; width: 3%;">Select</th>';
            html += '<th style="padding: 10px; width: 25%;">Item Name</th>';
            html += '<th style="padding: 10px; width: 5%;">Amount</th>';
            html += '<th style="padding: 10px; width:5%;">Discount</th>';
            html += '<th style="padding: 10px; width: 5%;">Net Amount</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            // Build HTML for each category
            for (var cat in categories) {
                if (categories[cat].length > 0) {
                    // Category Row (spans across all columns)
                    html += '<tr class="category-section" style="background-color: #e9ecef;">';
                    html += '<td colspan="5" class="category-title" style="padding: 8px 10px; font-weight: bold;">' + cat + '</td>';
                    html += '</tr>';

                    // Item Rows
                    categories[cat].forEach(function (item) {
                        var itemName = item.Item_Name || item.Description || 'N/A';
                        var amount = (item.Amount || 0).toFixed(2);
                        var discount = (item.Discount_Amount || 0).toFixed(2);
                        var net = (item.Net_Amount || 0).toFixed(2);

                        html += '<tr class="item-row" style="border-bottom: 1px solid #eee;">';
                        var isChecked = isPosted ? (item.IsFBRPosted ? 'checked' : '') : (item.Is_Fbr ? 'checked' : '');
                        var isDisabled = isPosted ? 'disabled' : '';
                        html += '<td style="padding: 10px;"><input type="checkbox" class="item-checkbox" ' + isChecked + ' ' + isDisabled + ' data-detail-id="' + item.Bill_Detail_ID + '" /></td>';
                        html += '<td style="padding: 10px;">' + itemName + '</td>';
                        html += '<td style="padding: 10px;">' + amount + '</td>';
                        html += '<td style="padding: 10px;">' + discount + '</td>';
                        html += '<td style="padding: 10px;">' + net + '</td>';
                        html += '</tr>';
                    });
                }
            }

            html += '</tbody>';
            html += '</table>';

            // Button Container (Aligned to the right)
            if (!isPosted) {
                html += '<div style="text-align: right; margin-top: 15px; padding-top: 10px;">';
                html += '<button type="button" class="post-fbr-btn" data-bill-id="' + billId + '" style="padding: 8px 16px; cursor: pointer;">Post to FBR</button>';
                html += '</div>';
            } else if (qrPath) {
                var normalizedQrPath = qrPath.replace('~', '');
                html += '<div style="text-align: right; margin-top: 15px; padding-top: 10px;">';
                if (fbrNo) {
                    html += '<div style="margin-bottom:6px;font-weight:600;">FBR Invoice No: ' + fbrNo + '</div>';
                }
                html += '<img src="' + normalizedQrPath + '" alt="QR Code" style="width: 120px; height: 120px; border: 1px solid #ddd; padding: 4px; background: #fff;" />';
                html += '</div>';
            }

            html += '</div>'; // End detail-container

            return html;
        }
        function PostToFBR(billId, btn) {
            console.log('PostToFBR called, billId=', billId);
            if (typeof Swal === 'undefined') {
                alert('SweetAlert is not loaded. billId=' + billId);
                return;
            }
            Swal.fire({
                icon: 'question',
                title: 'Post to FBR?',
                text: 'Are you sure you want to post the selected item(s) of this bill to FBR?',
                showCancelButton: true,
                confirmButtonText: 'Yes, Post',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#28a745'
            }).then(function (confirmResult) {
                if (!confirmResult.isConfirmed) {
                    return;
                }

                // Get selected items
                var selectedItems = [];
                $('input.item-checkbox:checked').each(function () {
                    selectedItems.push($(this).attr('data-detail-id'));
                });

                if (selectedItems.length === 0) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'No Items Selected',
                        text: 'Please select at least one item to post to FBR.'
                    });
                    return;
                }

                // Show loading
                $(btn).prop('disabled', true).text('Processing...');

                $.ajax({
                    type: "POST",
                    url: "FBRBillingView.aspx/PostToFBR",
                    data: JSON.stringify({
                        billId: billId,
                        selectedDetailIds: selectedItems
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var result = null;
                        try {
                            result = JSON.parse(response.d);
                        } catch (e) {
                            result = { success: false, message: response.d };
                        }

                        if (result.success) {
                            Swal.fire({
                                icon: 'success',
                                title: 'Posted to FBR',
                                text: result.message,
                                confirmButtonText: 'OK'
                            }).then(function () {
                                location.reload();
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'FBR Posting Failed',
                                text: result.message || 'Unknown error occurred.',
                                confirmButtonText: 'OK'
                            });
                            $(btn).prop('disabled', false).text('Post to FBR');
                        }
                    },
                    error: function (xhr, status, error) {
                        var msg = error;
                        if (xhr && xhr.responseText) {
                            msg = xhr.responseText;
                        }
                        Swal.fire({
                            icon: 'error',
                            title: 'FBR Posting Failed',
                            text: msg,
                            confirmButtonText: 'OK'
                        });
                        $(btn).prop('disabled', false).text('Post to FBR');
                    }
                });
            });
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <div class="row">
     <div class="filter-container">
         <label for="txtStartDate">Start Date</label>
         <input type="date" id="txtStartDate" class="form-control" style="max-width:220px;" />
         <label for="txtEndDate">End Date</label>
         <input type="date" id="txtEndDate" class="form-control" style="max-width:220px;" />
         <button type="button" id="btnApplyDateFilter" class="btn btn-primary">Apply</button>
     </div>
     <div class="table-container">
         <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
             <thead id="ihead">
                 <tr>
                     <th class="hide">Bill ID</th>
                     <th>Bill No</th>
                     <th>Bill Type</th>
                     <th>Bill Date</th>
                     <th>MR No</th>
                     <th>Name</th>
                     <th>Total Amount</th>
                     <th>Discount Percentage</th>
                     <th>Discount Amount</th>
                     <th>Net Amount</th>
                     <th>Received Amount</th>
                     <th>Balance Amount</th>
                     <th>Operator</th>
                 </tr>
             </thead>
             <tbody id="ibody">
             </tbody>
         </table>
     </div>
 </div>
</asp:Content>
