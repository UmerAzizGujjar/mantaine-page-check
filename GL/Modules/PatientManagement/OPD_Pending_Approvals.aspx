<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Pending_Approvals.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Pending_Approvals" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css?v=<%= ((PMS.SiteMaster)Master).Ver("~/wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css") %>" rel="stylesheet" />
    <style type="text/css">
        /* tablet/laptop: the Approve column grows to fit its button instead of the button running past the screen edge */
        @media screen and (max-width: 1199px) {
            .main [class*="col-"]:has(> #btnApproved) {
                width: auto;
                min-width: 16.66666667%;
            }
        }
    </style>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        var oTable = null;
        var selectedRows = {};

        $(document).ready(function () {
            FillPatientType();
            FillCostCenter();
            InitDateFilters();
            GetOPDToApproveList();

            $('#ddlpatientType').on('change', function () {
                GetOPDToApproveList();
                if ($(this).val() !== '0') {
                    DisablePatientType();
                }
            });

            $('#ddlCostCenter').on('change', function () {
                GetOPDToApproveList();
            });

            $(document).on('change', '#header-check', function () {
                var isChecked = $(this).prop('checked');
                if (!oTable) return;

                var allMode = ($('#ddlpatientType').val() === '0');
                var skipped = 0;
                oTable.rows().every(function () {
                    var rowNode = $(this.node());
                    var data = this.data();
                    var isPrivate = data && data.Patient_Type === '02';
                    var cb = rowNode.find('.chckrow');
                    if (isChecked && allMode && isPrivate) {
                        skipped++;
                        cb.prop('checked', false).trigger('change');
                    } else {
                        cb.prop('checked', isChecked).trigger('change');
                    }
                });
                UpdateHeaderCheck();

                if (isChecked && skipped > 0) {
                    Swal.fire({
                        icon: 'info',
                        title: 'General Only Selected',
                        text: skipped + ' Private patient(s) excluded. Select Private from Patient Type filter to approve Private.',
                        timer: 3000,
                        showConfirmButton: false
                    });
                }
            });

            $(document).on('change', '.chckrow', function () {
                var id = $(this).val();
                var rowData = oTable ? oTable.row($(this).closest('tr')).data() : null;
                var isPrivate = rowData && rowData.Patient_Type === '02';
                var allMode = ($('#ddlpatientType').val() === '0');

                if ($(this).is(':checked')) {
                    if (isPrivate && allMode) {
                        $(this).prop('checked', false);
                        Swal.fire({
                            icon: 'info',
                            title: 'Private Excluded',
                            text: 'Select Private from Patient Type filter to approve Private patients.',
                            timer: 2500,
                            showConfirmButton: false
                        });
                        return;
                    }
                    if (rowData) selectedRows[id] = rowData;
                } else {
                    delete selectedRows[id];
                }
                UpdateHeaderCheck();
                UpdateTotals();
            });

            $('#btnApproved').on('click', function () {
                var ids = Object.keys(selectedRows);
                if (ids.length === 0) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'No Selection',
                        text: 'Please select at least one patient to approve.',
                        confirmButtonColor: '#3085d6'
                    });
                    return;
                }

                Swal.fire({
                    title: 'Confirm Approval',
                    text: 'Approve ' + ids.length + ' selected patient(s)?',
                    icon: 'question',
                    showCancelButton: true,
                    confirmButtonColor: '#28a745',
                    cancelButtonColor: '#d33',
                    confirmButtonText: 'Yes, Approve!',
                    cancelButtonText: 'Cancel'
                }).then((result) => {
                    if (!result.isConfirmed) return;

                    Swal.fire({
                        title: 'Processing...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        showConfirmButton: false,
                        didOpen: () => { Swal.showLoading(); }
                    });

                    var patMode = $('#ddlpatientType').val();
                    if (patMode === '02') {
                        ApprovePrivateSequence(ids, 0, 0);
                    } else {
                        PageMethods.ApproveBulkOPD(ids.join(','), function (response) {
                        try {
                            var res = JSON.parse(response);
                            if (res && res.length > 0 && res[0].Voucher_ID > 0) {
                                var v = res[0];
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Voucher Posted',
                                    html: 'Voucher No: <strong>' + v.Voucher_ID + '</strong>' +
                                        '<br/>Patients: ' + v.Patient_Count +
                                        '<br/>Gross: ' + v.Gross_Amount +
                                        '<br/>Discount: ' + v.Discount_Amount +
                                        '<br/>Receipt: ' + v.Receipt_Amount,
                                    confirmButtonColor: '#28a745'
                                }).then(function () {
                                    window.location.href = 'OPD_Pending_Approvals.aspx';
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Approval Failed',
                                    text: res[0].Message || 'Unknown error',
                                    confirmButtonColor: '#d33'
                                });
                            }
                        } catch (e) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Invalid response from server.',
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
            });
        });

        function ApprovePrivateSequence(ids, idx, successCount) {
            if (idx >= ids.length) {
                Swal.fire({
                    icon: successCount > 0 ? 'success' : 'error',
                    title: successCount > 0 ? 'Vouchers Posted' : 'Approval Failed',
                    text: successCount + ' of ' + ids.length + ' Private patient voucher(s) posted successfully.',
                    confirmButtonColor: successCount > 0 ? '#28a745' : '#d33'
                }).then(function () {
                    window.location.href = 'OPD_Pending_Approvals.aspx';
                });
                return;
            }

            PageMethods.ApproveSingleOPD(ids[idx], '02', function (response) {
                try {
                    var res = JSON.parse(response);
                    if (res && res.length > 0 && res[0].Voucher_ID > 0) {
                        successCount++;
                    }
                } catch (e) {
                }
                ApprovePrivateSequence(ids, idx + 1, successCount);
            }, function (error) {
                ApprovePrivateSequence(ids, idx + 1, successCount);
            });
        }

        function DisablePatientType() {
            var $ddl = $('#ddlpatientType');
            $ddl.prop('disabled', true);
            var $container = $ddl.data('select2') ? $ddl.data('select2').$container : $ddl.next('.select2-container');
            if ($container && $container.length) {
                $container.addClass('select2-container--disabled');
                $container.find('.select2-selection').css({
                    'background-color': '#e9ecef',
                    'pointer-events': 'none',
                    'cursor': 'not-allowed'
                });
            }
        }

        function pad2(n) { return n < 10 ? '0' + n : '' + n; }

        function fmtDateTime(d) {
            return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()) +
                ' ' + pad2(d.getHours()) + ':' + pad2(d.getMinutes());
        }

        function InitDateFilters() {
            var now = new Date();
            var start = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0);
            var end = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59);

            $('#txtStartDate').val(fmtDateTime(start)).datetimepicker({
                format: 'Y-m-d H:i',
                step: 5,
                onChangeDateTime: function () { GetOPDToApproveList(); }
            });

            $('#txtEndDate').val(fmtDateTime(end)).datetimepicker({
                format: 'Y-m-d H:i',
                step: 5,
                onChangeDateTime: function () { GetOPDToApproveList(); }
            });
        }

        function GetOPDToApproveList() {
            var pat_type = $('#ddlpatientType').val();
            if (!pat_type) pat_type = '0';
            var cost_center = $('#ddlCostCenter').val();
            if (!cost_center) cost_center = '0';
            var start_date = $('#txtStartDate').val() || '';
            var end_date = $('#txtEndDate').val() || '';

            if (start_date && end_date && new Date(start_date.replace(' ', 'T')) > new Date(end_date.replace(' ', 'T'))) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Invalid Range',
                    text: 'Start date/time cannot be later than end date/time.',
                    confirmButtonColor: '#d33'
                });
                return;
            }

            $.ajax({
                url: 'OPD_Pending_Approvals.aspx/LoadPatientsToApprove_OPD',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ "pat_type": pat_type, "search": "", "cost_center": cost_center, "start_date": start_date, "end_date": end_date }),
                success: function (_data) {
                    var data = JSON.parse(_data.d);
                    selectedRows = {};
                    $('#header-check').prop('checked', false);
                    UpdateTotals();

                    if (!oTable) {
                        BuildDataTable(data);
                    } else {
                        oTable.clear();
                        oTable.rows.add(data);
                        oTable.draw();
                    }
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

        function BuildDataTable(data) {
            oTable = $('#tblPendingOPD').DataTable({
                "dom": 'lBfrtip',
                "buttons": [
                    'copy', 'excel', 'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "data": data,
                "paging": true,
                "pageLength": 25,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                "ordering": true,
                "columns": [
                    {
                        "data": null,
                        "width": "4%",
                        "orderable": false,
                        "searchable": false,
                        "className": "text-center",
                        "render": function (data, type, full) {
                            return '<input type="checkbox" class="chckrow" name="Getrow" value="' + full.Patient_ID + '" />';
                        }
                    },
                    { "data": "Patient_ID", "visible": false, "searchable": false },
                    { "data": "mr_no_sequence", "width": "3%" },
                    { "data": "Opd_No", "width": "3%", "className": "text-center" },
                    { "data": "Full_Name", "width": "15%" },
                    { "data": "Pat_type", "width": "4%" },
                    { "data": "DeptName", "width": "5%" },
                    { "data": "CostCenter", "width": "8%", "defaultContent": "" },
                    { "data": "Status", "width": "3%" },
                    {
                        "data": "Actual_Amount", "width": "5%",
                        "type": "num-fmt",
                        "className": "text-right",
                        "render": function (d) { return (parseFloat(d) || 0).toFixed(2); }
                    },
                    {
                        "data": "Receipt_Amount", "width": "5%",
                        "type": "num-fmt",
                        "className": "text-right",
                        "render": function (d) { return (parseFloat(d) || 0).toFixed(2); }
                    },
                
                  
                    {
                        "data": "Discount_Amount", "width": "5%",
                        "type": "num-fmt",
                        "className": "text-right",
                        "render": function (d) { return (parseFloat(d) || 0).toFixed(2); }
                    },
                    {
                        "data": "Hospital_Share", "width": "4%",
                        "type": "num-fmt",
                        "className": "text-right",
                        "render": function (d) { return (parseFloat(d) || 0).toFixed(2); }
                    },
                    {
                        "data": "Doctor_Share", "width": "4%",
                        "type": "num-fmt",
                        "className": "text-right",
                        "render": function (d) { return (parseFloat(d) || 0).toFixed(2); }
                    },

                ],
                "language": {
                    "search": "",
                    "searchPlaceholder": "Search..."
                },
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblPendingOPD_length');
                    var lengthDropdown = document.querySelector('#tblPendingOPD_length select');
                    var label = document.querySelector('#tblPendingOPD_length label');
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

        function UpdateHeaderCheck() {
            var total = 0, checkedCount = 0;
            if (oTable) {
                oTable.rows().every(function () {
                    var cb = $(this.node()).find('.chckrow');
                    total++;
                    if (cb.is(':checked')) checkedCount++;
                });
            }
            $('#header-check').prop('checked', total > 0 && total === checkedCount);
        }

        function UpdateTotals() {
            var recTotal = 0, discTotal = 0, actualTotal = 0;
            Object.keys(selectedRows).forEach(function (id) {
                var r = selectedRows[id];
                actualTotal += parseFloat(r.Actual_Amount) || 0;
                recTotal += parseFloat(r.Receipt_Amount) || 0;
                discTotal += parseFloat(r.Discount_Amount) || 0;
            });
            $('#txtTotalActual').val(actualTotal.toFixed(2));
            $('#txtTotalReceipt').val(recTotal.toFixed(2));
            $('#txtTotalDiscount').val(discTotal.toFixed(2));
        }

        function FillPatientType() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'OPD_Pending_Approvals.aspx/PatientType',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlpatientType').html(options).select2();
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });
        }

        function FillCostCenter() {
            var options = '<option value="0">All Cost Centers</option>';

            $.ajax({
                url: 'OPD_Pending_Approvals.aspx/CostCenter',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlCostCenter').html(options).select2();
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching cost center data:', error);
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row" style="margin-bottom: 10px;">
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>Start Date / Time</label>
            <input type="text" id="txtStartDate" class="form-control" readonly="readonly" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-6">
            <label>End Date / Time</label>
            <input type="text" id="txtEndDate" class="form-control" readonly="readonly" />
        </div>
    </div>

    <div class="row" style="margin-bottom: 10px;">
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>Patient Type</label>
            <select id="ddlpatientType"></select>
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>Cost Center</label>
            <select id="ddlCostCenter"></select>
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>Actual Amount</label>
            <input type="text" id="txtTotalActual" class="form-control" readonly="readonly" style="text-align: right;" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>Receipt Amount</label>
            <input type="text" id="txtTotalReceipt" class="form-control" readonly="readonly" style="text-align: right;" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>Discount Amount</label>
            <input type="text" id="txtTotalDiscount" class="form-control" readonly="readonly" style="text-align: right;" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4">
            <label>&nbsp;</label>
            <input type="button" value="Approve Selected Patients" class="btn btn-primry" id="btnApproved" style="width: 100%;" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-4"></div>
    </div>

    <div class="row">
        <div class="col-lg-12" style="overflow-x: auto;">
            <table id="tblPendingOPD" class="table table-hover table-striped table-bordered" style="width: 100%;">
                <thead>
                    <tr>
                        <th style="text-align: center;">
                            <input type="checkbox" id="header-check" /></th>
                        <th style="display: none;">Pat ID</th>
                        <th>MR No</th>
                        <th>OPD No</th>
                        <th>Patient Name</th>
                        <th>PatientType</th>
                        <th>Department</th>
                        <th>Cost Center</th>
                        <th>Bill Status</th>
                           <th>Actual Amount</th>
                        <th>Receipt Amount</th>
                        <th>Discount Amount</th>
                      <th>Hospital Share</th>
                      <th>Doctor Share</th>
                    </tr>
                </thead>
            </table>
        </div>
    </div>

</asp:Content>
