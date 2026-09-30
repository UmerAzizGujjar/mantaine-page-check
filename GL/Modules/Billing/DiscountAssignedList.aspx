<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountAssignedList.aspx.cs" Inherits="PMS.Modules.Billing.DiscountAssignedList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .detail-container {
            padding: 15px;
        }

        .clickable-row {
            cursor: pointer;
        }

            .clickable-row:hover {
                background-color: #f0f8ff;
            }
        
        .details-table {
            width: 100%;
            border-collapse: collapse;
            font-family: sans-serif;
        }
        
        .details-table th {
            background-color: #f4f4f4;
            padding: 10px;
            border-bottom: 2px solid #ddd;
            text-align: left;
        }
        
        .details-table td {
            padding: 10px;
            border-bottom: 1px solid #eee;
        }
        
        .category-header {
            background-color: #e9ecef;
            font-weight: bold;
        }
        
        .category-header td {
            padding: 8px 10px;
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
                url: "DiscountAssignedList.aspx/GetUserColumnPreferences",
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

            let hasPermission = false;
            $.ajax({
                type: "POST",
                url: "DiscountAssignedList.aspx/GetUserDiscountPermission",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    hasPermission = response.d;
                }
            });

            const buttons = [];
            if (hasPermission) {
                buttons.push({
                    text: '<i class="fa fa-columns"></i> Approve',
                    className: 'dt-button buttons-colvis',
                    action: function (e, dt, node, config) {
                        approveSelectedDiscounts();
                    }
                });
            }
            buttons.push(
                {
                    text: 'Add',
                    className: 'dt-button buttons-copy buttons-html5',
                    action: function () {
                        window.location = 'DiscountAssigned.aspx';
                    }
                },
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
            );

            const table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": buttons,
                "columnDefs": savedVisibility ? [] : undefined,
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "DiscountAssignedList.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
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
                    {
                        "data": null,
                        "width": "3%",
                        "orderable": false,
                        "render": (data, type, full, meta) => {
                            return `<input type="checkbox" class="row-checkbox" data-id="${full.Discount_Assign_ID}" data-bill-id="${full.Bill_ID || ''}" />`;
                        }
                    },
                    { "data": null, "width": "3%", "orderable": false, "render": (data, type, full, meta) => meta.settings._iDisplayStart + meta.row + 1 },
                    { "data": "Discount_Assign_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "7%", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "width": "5%", "orderable": false },
                    { "data": "NIC", "name": "NIC", "width": "5%", "orderable": false },
                    {
                        "data": "Discount_Date", "name": "Discount_Date",
                        "render": (data, type, full) => moment(full.Discount_Date).format('DD-MMM-YYYY'),
                        "width": "9%"
                    },
                    { "data": "Total_Discount", "name": "Total_Discount", "width": "5%", "orderable": false },
                    { "data": "Created_By", "name": "Created_By", "width": "5%", "orderable": false },
                    {
                        "render": (data, type, full) => {
                            let res = `<a href="#" onclick="editOpen(${full.Discount_Assign_ID})" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>`;
                            let Del = `<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="cancelPatient(${full.Discount_Assign_ID}, '${full.Full_Name.replace(/'/g, "\\'")}')"><i class="fa fa-trash"></i></a>`;
                            let print = `<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px;" href="#" onclick="Print(${full.Discount_Assign_ID})"><i class="fa fa-print"></i></a>`;
                            return res + Del + print;
                        },
                        "width": "14%",
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    $(row).addClass('clickable-row');
                    $(row).attr('data-discount-id', data.Discount_Assign_ID);
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
                    if (!hasPermission) {
                        api.column(0).visible(false);
                        $('#header-checkbox').closest('th').hide();
                    }
                    $('#header-checkbox').off('change').on('change', function () {
                        const isChecked = $(this).prop('checked');
                        api.rows({ page: 'current' }).nodes().each(function (row) {
                            $(row).find('.row-checkbox').prop('checked', isChecked);
                        });
                        updateHeaderCheckboxState(api);
                    });
                    $('#tblResult tbody').on('change', '.row-checkbox', function () {
                        updateHeaderCheckboxState(api);
                    });
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

                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

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

            $('#tblResult tbody').on('click', 'tr.clickable-row', function (e) {
                if ($(e.target).closest('a,button,input').length > 0) {
                    return;
                }

                var tr = $(this);
                var row = table.row(tr);
                var discountId = tr.attr('data-discount-id');

                if (row.child.isShown()) {
                    row.child.hide();
                    tr.removeClass('shown');
                } else {
                    table.rows().every(function () {
                        if (this.child.isShown()) {
                            this.child.hide();
                            $(this.node()).removeClass('shown');
                        }
                    });

                    row.child('<div style="padding:20px;text-align:center;">Loading...</div>').show();
                    tr.addClass('shown');
                    LoadDiscountDetails(discountId, row);
                }
            });
        }

        function approveSelectedDiscounts() {
            const selectedBillIds = [];
            const selectedDiscountIds = [];

            $('#tblResult tbody .row-checkbox:checked').each(function () {
                const discountId = $(this).data('id');
                const billId = $(this).data('bill-id');
                if (billId) {
                    selectedBillIds.push(billId);
                    selectedDiscountIds.push(discountId);
                }
            });

            if (selectedBillIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Selection',
                    text: 'Please select at least one discount to approve.',
                    confirmButtonText: 'OK',
                    confirmButtonColor: '#3085d6'
                });
                return;
            }

            Swal.fire({
                title: 'Confirm Approval',
                text: `Are you sure you want to approve ${selectedBillIds.length} selected discount(s)?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Approve!',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#d33',
                reverseButtons: true,
                focusConfirm: false
            }).then((result) => {
                if (!result.isConfirmed) {
                    return;
                }

                const originalBtnText = $('.buttons-approve').html();
                $('.buttons-approve').prop('disabled', true).html('<i class="fa fa-spinner fa-spin"></i> Processing...');

                PageMethods.ApproveDiscountsBulk(
                    JSON.stringify(selectedBillIds),
                    function (response) {
                        $('.buttons-approve').prop('disabled', false).html(originalBtnText);

                        if (response === "Success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Approved!',
                                text: 'Selected discounts have been approved successfully.',
                                confirmButtonText: 'Great!',
                                confirmButtonColor: '#28a745',
                                timer: 2000,
                                timerProgressBar: true
                            }).then(() => {
                                $('#header-checkbox').prop('checked', false).prop('indeterminate', false);
                                $('#tblResult tbody .row-checkbox').prop('checked', false);
                                $('#tblResult').DataTable().ajax.reload(null, false);
                            });
                        } else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Approval Failed',
                                text: 'Error: ' + response,
                                confirmButtonText: 'Try Again',
                                confirmButtonColor: '#d33'
                            });
                        }
                    },
                    function (error) {
                        $('.buttons-approve').prop('disabled', false).html(originalBtnText);
                        Swal.fire({
                            icon: 'error',
                            title: 'Connection Error',
                            text: 'Failed to process approval. Please check your connection and try again.',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#d33'
                        });
                        console.error(error);
                    }
                );
            });
        }

        function updateHeaderCheckboxState(api) {
            const checkboxes = $('#tblResult tbody .row-checkbox');
            const checkedCount = checkboxes.filter(':checked').length;
            const totalCount = checkboxes.length;
            const headerCheckbox = $('#header-checkbox');

            if (totalCount === 0) {
                headerCheckbox.prop('checked', false).prop('indeterminate', false);
            } else if (checkedCount === 0) {
                headerCheckbox.prop('checked', false).prop('indeterminate', false);
            } else if (checkedCount === totalCount) {
                headerCheckbox.prop('checked', true).prop('indeterminate', false);
            } else {
                headerCheckbox.prop('checked', false).prop('indeterminate', true);
            }
        }

        function LoadDiscountDetails(discountId, row) {
            $.ajax({
                type: "POST",
                url: "DiscountAssignedList.aspx/GetDiscountDetails",
                data: JSON.stringify({ discountAssignId: discountId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        var details = JSON.parse(response.d);
                        var html = BuildDetailsHTML(details);
                        row.child(html).show();
                    }
                },
                error: function (xhr, status, error) {
                    row.child('<div style="padding:20px;color:red;">Error loading details</div>').show();
                    console.log(xhr.responseText);
                }
            });
        }

        function BuildDetailsHTML(details) {
            var html = '<div class="detail-container">';
            html += '<table class="details-table">';
            html += '<thead>';
            html += '<tr>';
            html += '<th>Item ID</th>';
            html += '<th>Item Name</th>';
            html += '<th>Item Type</th>';
            html += '<th>Original Amount</th>';
            html += '<th>Discount %</th>';
            html += '<th>Discount Amount</th>';
            html += '<th>Net Amount</th>';
            html += '</tr>';
            html += '</thead>';
            html += '<tbody>';

            details.forEach(function (item) {
                html += '<tr>';
                html += '<td>' + (item.Item_ID || 'N/A') + '</td>';
                html += '<td>' + (item.Item_Name || 'N/A') + '</td>';
                html += '<td>' + (item.Item_Type || 'N/A') + '</td>';
                html += '<td>' + parseFloat(item.Original_Amount || 0).toFixed(2) + '</td>';
                html += '<td>' + parseFloat(item.Discount_Percentage || 0).toFixed(2) + '%</td>';
                html += '<td>' + parseFloat(item.Discount_Amount || 0).toFixed(2) + '</td>';
                html += '<td>' + parseFloat(item.Net_Amount || 0).toFixed(2) + '</td>';
                html += '</tr>';
            });

            html += '</tbody>';
            html += '</table>';
            html += '</div>';
            return html;
        }

        function editOpen(id) {
            window.location.href = "DiscountAssigned.aspx?Discount_Assign_ID=" + id;
        }

        

        function Print(id) {
            // Add your print functionality here
            alert('Print functionality for Discount ID: ' + id);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container col-lg-12 col-md-12 col-sm-10">
        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
      <thead id="ihead">
        <tr>
             <th><input type="checkbox" id="header-checkbox" title="Select All" /></th>
            <th>Sr#</th>                
            <th style="display: none;">Discount ID</th>    
            <th>MR No.</th>
            <th>Name</th>
            <th>CNIC</th>
            <th>Discount Date</th>
            <th>Total Discount</th>
            <th>Created By</th>       
            <th style="width: 20% !important;">Actions</th>
        </tr>
    </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>