<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyCaseView.aspx.cs" Inherits="PMS.EmergencyCaseView" %>

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


        });


        /* ---------- Start / End date filter (default = current month) ---------- */
        function pad2(n) { return n < 10 ? '0' + n : '' + n; }
        function fmtYMD(d) { return d.getFullYear() + '-' + pad2(d.getMonth() + 1) + '-' + pad2(d.getDate()); }

        function setCurrentMonthDates() {
            var now = new Date();
            $('#txtFromDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth(), 1)));
            $('#txtToDate').val(fmtYMD(new Date(now.getFullYear(), now.getMonth() + 1, 0)));
        }

        function reloadList() {
            if ($.fn.DataTable.isDataTable('#tblResult')) {
                $('#tblResult').DataTable().ajax.reload();
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

        function PrintEmergencyPatient(Emergency_ID) {
          
            var url = '../../ReportViewer.aspx?ReportName=Emergencypatient&Title=Emergency Patient Report&Emergency_ID=' + Emergency_ID;
             window.open(url, '_blank');
        }
        function PrintEmergencyPatientCertificate(Emergency_ID) {
            var url = '../../ReportViewer.aspx?ReportName=EmergencyPrint&Title=Emergency Patient Report&Emergency_ID=' + Emergency_ID;
             window.open(url, '_blank');
        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "EmergencyCaseView.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                        }
                    }
                }
            });

            var table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'EmergencyCase.aspx';
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
                        url: "EmergencyCaseView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterStatus: $('#filterStatus').val(),
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
                    { "data": "Emergency_ID", "name": "Emergency_ID", "width": "0%", "visible": false },
                    { "data": "isCancelled", "visible": false, "orderable": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "7%" },
                    { "data": "Full_Name", "width": "8%", "orderable": false },
                    { "data": "Father_Name", "width": "8%", "orderable": false },
                    {
                        "data": "Admission_Date",
                        "name": "Admission_Date",
                        "render": function (data, type, full) {
                            var date = full.Admission_Date;
                            return (date && moment(date).isValid())
                                ? moment(date).format('DD-MMM-YYYY hh:mm:ss A')
                                : "";
                        },
                        "width": "8%",
                        "orderable": false
                    },
                    {
                        "data": "Discharge_On",
                        "name": "Discharge_On",
                        "render": function (data, type, full) {
                            var date = full.Discharge_On;
                            if (!date) return "";
                            return moment(date).format('DD-MMM-YYYY hh:mm:ss A');
                        },
                        "width": "8%"
                    },
                    { "data": "AdmitDays", "width": "8%", "orderable": false },
                    {
                        "data": "Patinet_Condition",
                        "width": "8%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            if (data === "Immediate") return "Short Stay";
                            else if (data === "OPD") return "OPD";
                            else return data;
                        }
                    },
                    { "data": "CreatedBy", "width": "8%", "orderable": false },
                    {
                        "data": "Created_time",
                        "width": "8%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            return (data && moment(data).isValid())
                                ? moment(data).format('DD-MMM-YYYY hh:mm:ss A')
                                : "";
                        }
                    },
                    { "data": "updatedBy", "width": "8%", "orderable": false },
                    {
                        "data": "updated_time",
                        "width": "8%",
                        "orderable": false,
                        "render": function (data, type, full) {
                            return (data && moment(data).isValid())
                                ? moment(data).format('DD-MMM-YYYY hh:mm:ss A')
                                : "";
                        }
                    },
                    {
                        render: function (data, type, full) {
                            if (full.isCancelled === true) {
                                return '<span style="color:#721c24; font-weight:bold;">Cancelled</span>';
                            }
                            var res = '<a href="#" onclick="editOpen(' + full.Emergency_ID + ')" class="editListBtn" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintEmergencyPatient(' + full.Emergency_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var printBtn = '';
                            if (full.DateOfDeath) {
                                printBtn = '<a class="printListBtn" href="#" style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px;" onclick="PrintEmergencyPatientCertificate(' + full.Emergency_ID + ')"><i class="fa fa-print"></i></a>';
                            }
                            return res + Del + print + printBtn;
                        },
                        "width": "8%",
                        "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    if (data.isCancelled === true) {
                        $(row).css({
                            "background-color": "#f8d7da",
                            "color": "#721c24",
                            "font-weight": "bold"
                        });
                    } else if (data.AdmitDays >= 1 && (data.Discharge_ON == null || data.Discharge_ON === "")) {
                        $(row).css({
                            "background-color": "#f8d7da",
                            "font-weight": "bold"
                        });
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
                            function () { },
                            function (error) { }
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

            $('#filterStatus').on('change', function () {
                table.ajax.reload();
            });
        }



        function editOpen(id) {
            window.open("EmergencyCase.aspx?ID=" + id + "");
        }

        function deleteConfirm(anchorTag) {
            var table = $('#tblResult').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var Emergency_PatientID = rowData.Emergency_ID;
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(Emergency_PatientID, function (msg) {
                    if (msg == "Delete") {
                        table.row(row).remove().draw();
                    } else {
                        alert("This Patient is in Billing Process");
                    }
                });
            }
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
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
    <select id="filterStatus" class="form-control" >
        <option value="">All</option>
        <option value="Admitted">Admitted</option>
        <option value="Discharged">Discharged</option>
    </select>
            </div>
        </div>
    <div class="row">
         <div class="col-lg-12 col-md-12 col-sm-12">
    <table style="width: 100%;">
        <tr>
            <td>
                <div id="POdetails" style="margin-top: 15px;">
                    <div>
                        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                            <thead id="ihead">
                                 <tr>
                                     <th style="display:none;">Emergency ID</th>
                                     <th style="display:none;">Is Cancel</th>
                                     <th>MR No.</th>
                                    <th>Patient Name</th>
                                    <th>Father/Husband Name</th>
                                    <th>Admission Date</th>
                                    <th>Discharge Date</th>
                                    <th>No Of Days</th>
                                    <th>Patient Type</th>
                                    <th>Created By</th>
                                    <th>Created Time</th>
                                    <th>Updated By</th>
                                    <th>Updated Time</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="ibody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
        </div>
        </div>
</asp:Content>
