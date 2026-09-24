<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IssueMedicineList.aspx.cs" Inherits="PMS.IssueMedicineList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .pharma-action-btn {
            display: inline-block;
            min-width: 28px;
            height: 28px;
            line-height: 28px;
            padding: 0 8px;
            margin: 0 2px;
            border-radius: 4px;
            color: #ffffff !important;
            text-align: center;
            vertical-align: middle;
            font-size: 12px;
            cursor: pointer;
            text-decoration: none;
            transition: all 0.15s ease;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
        }

        .pharma-action-btn i {
            color: #ffffff !important;
            font-size: 12px;
            line-height: 1;
        }

        .pharma-action-btn:hover {
            text-decoration: none;
            color: #ffffff !important;
            transform: translateY(-1px);
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.18);
        }

        .pharma-btn-upload {
            background-color: #2563EB;
        }

        .pharma-btn-upload:hover {
            background-color: #1D4ED8;
        }

        .pharma-btn-print {
            background-color: #10B981;
        }

        .pharma-btn-print:hover {
            background-color: #059669;
        }

        .pharma-btn-voucher {
            background-color: #F59E0B;
        }

        .pharma-btn-voucher:hover {
            background-color: #D97706;
        }

        .pharma-btn-label {
            background-color: #8B5CF6;
        }

        .pharma-btn-label:hover {
            background-color: #7C3AED;
        }

        #tbl a.pharma-action-btn {
            color: #ffffff !important;
        }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadWarehouseDropdown();
            LoadPage();

            $(document).on('change', '#header-check', function () {
                var isChecked = $(this).prop('checked');
                $('#tbl tbody .issue-checkbox:not(:disabled)').prop('checked', isChecked);
            });

            $(document).on('change', '.issue-checkbox', function () {
                var totalCheckboxes = $('#tbl tbody .issue-checkbox:not(:disabled)').length;
                var checkedCheckboxes = $('#tbl tbody .issue-checkbox:checked:not(:disabled)').length;
                $('#header-check').prop('checked', totalCheckboxes > 0 && totalCheckboxes === checkedCheckboxes);
            });
        });
        function LoadWarehouseDropdown() {
            $.ajax({
                type: "POST",
                url: "IssueMedicineList.aspx/GetWarehouses",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        var data = JSON.parse(response.d);
                        var options = '<option value="0">All Warehouses</option>';
                        $.each(data, function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlWarehouse').html(options);
                        $('#ddlWarehouse').select2();
                    } catch (e) {
                        console.error("Error parsing warehouses: ", e);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load warehouses: ", error);
                }
            });
        }
        function IncrementReprintCount(billId) {
            if (!billId || billId == '0' || billId == '') return;

            $.ajax({
                type: "POST",
                url: "IssueMedicineList.aspx/IncrementReprintCount", 
                data: JSON.stringify({ 'Bill_ID': parseInt(billId) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Reprint count updated for Bill ID: " + billId);
                },
                error: function (err) {
                    console.error("Failed to update reprint count", err);
                }
            });
        }
        function PrintBill(Bill_ID) {
            IncrementReprintCount(Bill_ID);
            var url = '../../ReportViewer.aspx?ReportName=PharmacySlip&ReportTitle=PharmacySlip&Bill_ID=' + Bill_ID;
            window.open(url, '_blank');

        }
        function PrintMedicineLabel(Bill_ID) {
            var url = '../../ReportViewer.aspx?ReportName=MedicineLabel&ReportTitle=MedicineLabel&Bill_ID=' + Bill_ID;
            window.open(url, '_blank');
        }
        function PrintVoucher(Bill_ID) {
            var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=PharmacySlip&TransID=' + Bill_ID + '&TransType=PSV';
            window.open(url, '_blank');
        }
        function PrintInvoice(key) {
            debugger;
            IncrementReprintCount(key);
            //var BillId = $('#BillId' + key).val();
            window.open('../../ReportViewer.aspx?ReportName=PharmacySlip&ReportTitle=PharmacySlip&Bill_ID=' + key);

        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "IssueMedicineList.aspx/GetUserColumnPreferences",
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
            $("#tbl").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'IssueMedicine.aspx';
                        }
                    },
                    {
                        text: '<i class="fa fa-check"></i> Approve Selected',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            var selectedIds = [];
                            $('#tbl tbody .issue-checkbox:checked:not(:disabled)').each(function () {
                                selectedIds.push($(this).val());
                            });

                            if (selectedIds.length === 0) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'No Selection',
                                    text: 'Please select at least one record to approve (only Created records can be approved).',
                                    confirmButtonColor: '#3085d6'
                                });
                                return;
                            }

                            Swal.fire({
                                title: 'Confirm Approval',
                                text: 'Are you sure you want to approve ' + selectedIds.length + ' record(s)?',
                                icon: 'question',
                                showCancelButton: true,
                                confirmButtonColor: '#28a745',
                                cancelButtonColor: '#d33',
                                confirmButtonText: 'Yes, Approve!',
                                cancelButtonText: 'Cancel'
                            }).then((result) => {
                                if (result.isConfirmed) {
                                    Swal.fire({
                                        title: 'Processing...',
                                        text: 'Please wait',
                                        allowOutsideClick: false,
                                        showConfirmButton: false,
                                        didOpen: () => { Swal.showLoading(); }
                                    });

                                    var successCount = 0;
                                    var failedCount = 0;
                                    var processed = 0;
                                    var failedDetails = [];

                                    selectedIds.forEach(function (billId) {
                                        $.ajax({
                                            type: "POST",
                                            url: "IssueMedicine.aspx/ApprovePhramcy",
                                            data: JSON.stringify({ billid: billId }),
                                            contentType: "application/json; charset=utf-8",
                                            dataType: "json",
                                            success: function (response) {
                                                processed++;
                                                try {
                                                    var resultData = JSON.parse(response);
                                                    if (resultData && resultData.length > 0) {
                                                        var first = resultData[0];
                                                        if (first.Approved === true || first.approved === true || first.IsApproved === true) {
                                                            successCount++;
                                                        } else {
                                                            failedCount++;
                                                            failedDetails.push('Bill #' + billId + ': ' + (first.Message || first.message || 'Unknown response'));
                                                        }
                                                    } else {
                                                        successCount++;
                                                    }
                                                } catch (e) {
                                                    successCount++;
                                                }
                                                finalizeApproval();
                                            },
                                            error: function (xhr, status, error) {
                                                processed++;
                                                failedCount++;
                                                var errMsg = xhr.responseText || error || 'Unknown error';
                                                failedDetails.push('Bill #' + billId + ': ' + errMsg);
                                                finalizeApproval();
                                            }
                                        });
                                    });

                                    function finalizeApproval() {
                                        if (processed === selectedIds.length) {
                                            var html = '<div style="text-align: left;">' +
                                                '<p><strong>Total Selected:</strong> ' + selectedIds.length + '</p>' +
                                                '<p style="color: green;"><strong>Approved:</strong> ' + successCount + '</p>' +
                                                '<p style="color: red;"><strong>Failed:</strong> ' + failedCount + '</p>';
                                            if (failedDetails.length > 0) {
                                                html += '<hr><div style="max-height: 150px; overflow-y: auto; font-size: 12px;">';
                                                for (var i = 0; i < failedDetails.length; i++) {
                                                    html += '<p style="color: red;">' + failedDetails[i] + '</p>';
                                                }
                                                html += '</div>';
                                            }
                                            html += '</div>';

                                            Swal.fire({
                                                icon: successCount > 0 ? 'success' : 'error',
                                                title: 'Approval Complete',
                                                html: html,
                                                confirmButtonColor: '#28a745'
                                            }).then(() => {
                                                $('#tbl').DataTable().ajax.reload();
                                                $('#header-check').prop('checked', false);
                                            });
                                        }
                                    }
                                }
                            });
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
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "IssueMedicineList.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            warehouseId: ($('#ddlWarehouse').val() || '0')
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
                        "width": "5%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            if (full.Status === "Approved") {
                                return '<input type="checkbox" class="issue-checkbox" disabled />';
                            }
                            return '<input type="checkbox" class="issue-checkbox" value="' + full.Bill_ID + '" />';
                        },
                        "createdCell": function (td, cellData, rowData, row, col) {
                            $(td).css('text-align', 'center');
                        }
                    },
                    { "data": "Bill_ID", "visible": false, "width": "0%" },
                    {
                        "data": "Invoice_Date", "name": "Invoice_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Invoice_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "6%", "orderable": true
                    },
                    { "data": "BillNo", "width": "7%", "orderable": false },
                    { "data": "FBR_Number", "width": "7%", "orderable": false }, 
                    { "data": "Customer_Name", "width": "10%", "orderable": false },
                    { "data": "Patient_ID", "name": "Patient_ID", "width": "7%", "orderable": true },                    
                    { "data": "Referred_By_value", "width": "7%", "orderable": false },                  
                    { "data": "pharmacy_Department", "width": "7%", "orderable": false },                  
                    {
                        "data": "Pharma_trans_Type",
                        "width": "7%",
                        "orderable": false,
                        "render": function (data) {
                            if (!data || data.trim() === "") {
                                return "Walk In";
                            }
                            return data;
                        }
                    },                  
                    { "data": "Total_Amount", "width": "6%", "orderable": false },
                    { "data": "Discount_Amount", "width": "6%", "orderable": false },
                    { "data": "Received_Amount", "width": "6%", "orderable": false },
                    { "data": "Balance_Amount", "width": "6%", "orderable": false },
                    { "data": "WareHouse", "width": "9%", "orderable": false },
                    {
                        "data": "Status",
                        "width": "8%",
                        "orderable": true,
                        "render": function (data) {
                            if (data === "Approved") {
                                return '<span style="background-color: #28a745; padding: 4px 8px; border-radius: 4px; color: white; font-size: 11px; font-weight: bold;">Approved</span>';
                            } else {
                                return '<span style="background-color: #ffc107; padding: 4px 8px; border-radius: 4px; color: #333; font-size: 11px; font-weight: bold;">Created</span>';
                            }
                        }
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="pharma-action-btn pharma-btn-upload" onclick="PrintInvoice(' + full.Bill_ID + ')" title="Upload Slip"><i class="fa fa-upload"></i></a>';

                            var print = '<a class="pharma-action-btn pharma-btn-print" href="#" onclick="PrintBill(' + full.Bill_ID + ')" id="btnprint" title="Print Bill"><i class="fa fa-print"></i></a>';
                            var label = '<a class="pharma-action-btn pharma-btn-label" href="#" onclick="PrintMedicineLabel(' + full.Bill_ID + ')" id="btnlabelprint" title="Print Medicine Labels"><i class="fa fa-tag"></i></a>';
                            var voucher = '<a class="pharma-action-btn pharma-btn-voucher" href="#" onclick="PrintVoucher(' + full.Bill_ID + ')" id="btnvoucherprint" title="Print Voucher"><i class="fa fa-file-text-o"></i></a>';
                            var result;
                            result = res + print + label + voucher;
                            return result;
                        }, "width": "15%", "orderable": false
                    }
                ],
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

                    var lengthContainer = document.querySelector('#tbl_length');
                    var lengthDropdown = document.querySelector('#tbl_length select');
                    var label = document.querySelector('#tbl_length label');

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

            $('#ddlWarehouse').on('change', function () {
                $('#tbl').DataTable().ajax.reload();
            });
        }
        


    </script>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
        <div class="table-container">
            <div class="row">
                <div class="col-lg-2">
                    <label for="ddlWarehouse" style="font-weight: bold;">Ware House</label>
                    <select id="ddlWarehouse"></select>
                </div>
            </div>
            <table id="tbl" class="table table-bordered table-hover table-striped">
                <thead id="ihead">
                    <tr>
                        <th style="text-align:center;"><input type="checkbox" id="header-check" /></th>
                        <th style="display:none;">Bill_ID</th>
                        <th>Invoice Date</th>
                        <th>Inv No</th>
                        <th>FBR Number</th>
                        <th>Walking Customer</th>
                        <th>MrNo.</th>
                        <th>ReferBy</th>
                        <th>Main Department</th>
                        <th>Patient Type</th>
                        <th>Total</th>
                        <th>Discount Amount</th>
                        <th>Received Amount</th>
                        <th>Balance Amount</th>
                        <th>Ware House</th>
                        <th>Status</th>
                        <th>View</th>
                    </tr>
                </thead>
                <tbody id="tbody">
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
