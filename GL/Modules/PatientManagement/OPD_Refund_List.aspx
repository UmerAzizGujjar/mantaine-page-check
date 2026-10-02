<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Refund_List.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Refund_List" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .opd-date-filter { display: flex; flex-wrap: wrap; align-items: center; gap: 10px 14px; margin-bottom: 10px; }
        .opd-date-filter label.fl { margin: 0; font-weight: 600; }
        .opd-date-filter input[type=date] { width: 160px; display: inline-block; }
        .opd-switch { position: relative; display: inline-block; width: 44px; height: 24px; margin: 0; }
        .opd-switch input { opacity: 0; width: 0; height: 0; }
        .opd-slider { position: absolute; cursor: pointer; inset: 0; background: #ccc; border-radius: 24px; transition: .2s; }
        .opd-slider:before { content: ""; position: absolute; height: 18px; width: 18px; left: 3px; top: 3px; background: #fff; border-radius: 50%; transition: .2s; }
        .opd-switch input:checked + .opd-slider { background: #2e7d32; }
        .opd-switch input:checked + .opd-slider:before { transform: translateX(20px); }
    </style>

    <script type="text/javascript">
    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        initDateFilter();   // default: current month, filter ON
        LoadPage();

        $(document).on('change', '#header-check', function () {
            var isChecked = $(this).prop('checked');
            $('#tblOPDRefund tbody .refund-checkbox').prop('checked', isChecked);
        });

        $(document).on('change', '.refund-checkbox', function () {
            var allChecked = $('#tblOPDRefund tbody .refund-checkbox:checked').length ===
                $('#tblOPDRefund tbody .refund-checkbox').length;
            $('#header-check').prop('checked', allChecked);
        });
    });
  

   
        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "OPD_Refund_List.aspx/GetUserColumnPreferences",
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

            const table = $("#tblOPDRefund").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'OPD_Refund.aspx';
                        }
                    },
                    {
                        text: '<i class="fa fa-check"></i> Approve',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function (e, dt, node, config) {
                            var selected = [];
                            $('#tblOPDRefund tbody .refund-checkbox:checked:not(:disabled)').each(function () {
                                selected.push($(this).val());
                            });

                            if (selected.length === 0) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'No Selection',
                                    text: 'Please select at least one OPD refund to approve.',
                                    confirmButtonColor: '#3085d6'
                                });
                                return;
                            }

                            Swal.fire({
                                title: 'Confirm Approval',
                                text: 'Are you sure you want to approve ' + selected.length + ' record(s)?',
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
                                        didOpen: () => {
                                            Swal.showLoading();
                                        }
                                    });

                                    // Pass the comma-separated string
                                    PageMethods.ApproveOPDRefunds(selected.join(','), function (response) {
                                        try {
                                            // IMPORTANT: Parse response directly, not response.d
                                            var result = JSON.parse(response);

                                            if (result.Success) {
                                                let messageHtml = `<div style="text-align: left;">
                                <p><strong>Total Records:</strong> ${result.TotalRecords}</p>
                                <p><strong>Approved:</strong> ${result.ApprovedCount}</p>
                                <p><strong>Failed:</strong> ${result.FailedCount}</p>
                            </div>`;

                                                if (result.Details && result.Details.length > 0) {
                                                    messageHtml += `<hr><div style="max-height: 200px; overflow-y: auto;">`;
                                                    for (var i = 0; i < result.Details.length; i++) {
                                                        var detail = result.Details[i];
                                                        if (detail.Success) {
                                                            messageHtml += `<p style="color: green;">✅ Refund #${detail.RefundID}: ${detail.Message}</p>`;
                                                        } else {
                                                            messageHtml += `<p style="color: red;">❌ Refund #${detail.RefundID}: ${detail.Message}</p>`;
                                                        }
                                                    }
                                                    messageHtml += `</div>`;
                                                }

                                                Swal.fire({
                                                    icon: 'success',
                                                    title: 'Approval Complete!',
                                                    html: messageHtml,
                                                    confirmButtonColor: '#28a745'
                                                }).then(() => {
                                                    if (result.ApprovedCount > 0) {
                                                        $('#tblOPDRefund').DataTable().ajax.reload();
                                                        $('#header-check').prop('checked', false);
                                                    }
                                                });
                                            } else {
                                                Swal.fire({
                                                    icon: 'error',
                                                    title: 'Approval Failed',
                                                    text: result.Message || 'Unknown error occurred',
                                                    confirmButtonColor: '#d33'
                                                });
                                            }
                                        } catch (e) {
                                            console.error("Parse error:", e);
                                            console.log("Raw response:", response);
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Error',
                                                text: 'Invalid response from server: ' + e.message,
                                                confirmButtonColor: '#d33'
                                            });
                                        }
                                    }, function (error) {
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Error',
                                            text: error.get_message ? error.get_message() : 'An error occurred',
                                            confirmButtonColor: '#d33'
                                        });
                                    });
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
                        url: "OPD_Refund_List.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            fromDate: $('#txtFromDate').val() || '',
                            toDate: $('#txtToDate').val() || ''
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
                            if (full.isCancelled === true) {
                                return '<input type="checkbox" class="refund-checkbox" value="' + full.Refund_ID + '" disabled />';
                            }
                            return '<input type="checkbox" class="refund-checkbox" value="' + full.Refund_ID + '" />';
                        },
                        "createdCell": function (td, cellData, rowData, row, col) {
                            $(td).css('text-align', 'center');
                        }
                    },
                    { "data": "Refund_ID", "visible": false, "width": "0%" },
                    { "data": "OPD_No", "name": "OPD_No", "width": "10%", "orderable": true },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    {
                        "data": "Refund_Date", "name": "Refund_Date",
                        "render": function (data, type, full) {
                            var date = full.Refund_Date;
                            return moment(date).format('DD-MMM-YYYY');
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    { "data": "Refund_Amount", "width": "10%", className: "text-right", "orderable": false },
                    { "data": "Hospital_Refund", "name": "Hospital_Refund", "width": "10%", "orderable": false },
                    { "data": "Doctor_Refund", "width": "10%", "orderable": false },
                    {
                        "data": "Remarks",
                        "width": "10%",
                        "orderable": false
                    },
                    {
                        "data": "Status",
                        "width": "8%",
                        "orderable": true,
                        "render": function (data, type, full) {
                            if (data === "Approved") {
                                return '<span class="badge badge-success" style="background-color: #28a745; padding: 5px 10px; border-radius: 4px; color: white;">Approved</span>';
                            } else if (data === "Rejected") {
                                return '<span class="badge badge-danger" style="background-color: #dc3545; padding: 5px 10px; border-radius: 4px; color: white;">Rejected</span>';
                            } else {
                                return '<span class="badge badge-warning" style="background-color: #ffc107; padding: 5px 10px; border-radius: 4px; color: #333;">Created</span>';
                            }
                        }
                    },
                    {
                        render: function (data, type, full) {
                            if (full.isCancelled === true) {
                                return '<span style="color:#dc3545; font-weight:bold;">Cancelled</span>';
                            }
                            // Only show Edit/Delete button if status is not Approved
                            var editBtn = '';
                            var Del = '';
                            if (full.Status !== "Approved") {
                                editBtn = '<a href="#" onclick="EditOPDRefund(' + full.Refund_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                                Del = '<a href="#" class="delListBtn" onclick="cancelRefund(' + full.Refund_ID + ')" style="border-radius: 4px; margin-left: 4px; color: white; background-color: red; padding: 5px 8px; text-decoration: none;"><i class="fa fa-trash"></i></a>';
                            }
                            return editBtn + Del;
                        },
                        "width": "10%",
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    if (data.isCancelled === true) {
                        $(row).css('background-color', '#f8d7da');
                        $(row).find('td').css('color', '#721c24');
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
                    var lengthContainer = document.querySelector('#tblOPDRefund_length');
                    var lengthDropdown = document.querySelector('#tblOPDRefund_length select');
                    var label = document.querySelector('#tblOPDRefund_length label');

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
        }

        function EditOPDRefund(RefundID) {
            window.open("OPD_Refund.aspx?RefundID=" + RefundID);
        }


        function cancelRefund(RefundID) {
            Swal.fire({
                title: 'Are you sure?',
                text: 'Do you want to cancel this OPD Refund?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, cancel it!',
                cancelButtonText: 'No, keep it',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "OPD_Refund_List.aspx/CancelRefund",
                        data: JSON.stringify({ RefundID: RefundID }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var resultText = response.d;
                            if (resultText && resultText.startsWith("Error")) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Failed!',
                                    text: resultText,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            } else {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Canceled!',
                                    text: 'The OPD Refund has been canceled.',
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                $('#tblOPDRefund').DataTable().ajax.reload();
                            }
                        },
                        error: function (xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'AJAX call failed. Check console.',
                                timer: 2000
                            });
                            console.error("Cancel Refund error:", error, xhr.responseText);
                        }
                    });
                }
            });
        }

    /* ---------- Start / End date filter (default = current month) ---------- */
        function pad2(n) { return n < 10 ? '0' + n : '' + n; }
        function fmtYMD(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }

        function setCurrentMonthDates() {
            var now = new Date();
            $('#txtFromDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth(), 1)));
            $('#txtToDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth() + 1, 0)));
        }

        function reloadList() {
            if ($.fn.DataTable.isDataTable('#tblOPDRefund')) {
                $('#tblOPDRefund').DataTable().ajax.reload();
            }
        }

        function initDateFilter() {
            setCurrentMonthDates();
            $('#chkDateFilter').prop('checked', true);
            $('#lblDateFilterState').text('Current month');

            // Toggle: ON = date filter (current month), OFF = clear dates and show all data
            $('#chkDateFilter').on('change', function () {
                if (this.checked) {
                    setCurrentMonthDates();
                    $('#txtFromDate, #txtToDate').prop('disabled', false);
                    $('#lblDateFilterState').text('Current month');
                } else {
                    $('#txtFromDate, #txtToDate').val('').prop('disabled', true);
                    $('#lblDateFilterState').text('All data');
                }
                reloadList();
            });

            $('#txtFromDate, #txtToDate').on('change', function () {
                var f = $('#txtFromDate').val(), t = $('#txtToDate').val();
                if (f && t && f > t) {
                    Swal.fire({ icon: 'warning', title: 'Invalid Date Range', text: 'Start date cannot be after end date.' });
                    return;
                }
                $('#lblDateFilterState').text('Custom range');
                reloadList();
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 opd-date-filter">
            <label class="fl" for="txtFromDate">Start Date</label>
            <input type="date" id="txtFromDate" class="form-control" />
            <label class="fl" for="txtToDate">End Date</label>
            <input type="date" id="txtToDate" class="form-control" />
            <label class="fl" for="chkDateFilter">Date Filter</label>
            <label class="opd-switch" title="Off = clear dates and show all data">
                <input type="checkbox" id="chkDateFilter" checked="checked" />
                <span class="opd-slider"></span>
            </label>
            <span id="lblDateFilterState" class="text-muted">Current month</span>
        </div>
    </div>

    <div>
   <table id="tblOPDRefund" class="table table-hover table-striped table-bordered">
    <thead>
        <tr>
            <th style="text-align:center;"><input type="checkbox" id="header-check" /></th>
            <th>Refund_ID</th>
            <th>OPD No</th>
            <th>Full_Name</th>
            <th>Refund Date</th>
            <th>Refund_Amount</th>
            <th>Hospital Refund</th>
            <th>Doctor Refund</th>
            <th>Remarks</th>
            <th>Status</th>
            <th>Action</th>
        </tr>
    </thead>
</table>
</div>

</asp:Content>
