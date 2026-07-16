<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegList.aspx.cs" Inherits="PMS.RegList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" /> 
    <style>
        .log-changed-row { background-color: #fff3cd !important; }
        .log-changed-row td:first-child { border-left: 3px solid #ffc107; }
        #historyModal .table th { background: #f5f5f5; }
    </style>
    <script type="text/javascript">

        var allowPrint = false;
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            checkPrintPermission();
            LoadPage();
        });

        function checkPrintPermission() {
            $.ajax({
                type: "POST",
                url: "RegList.aspx/checkeditPrintRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    allowPrint = JSON.parse(response.d);
                    console.log("Print permission:", allowPrint);
                },
                error: function (error) {
                    console.error("Failed to check print permission:", error);
                    allowPrint = false;
                }
            });
        }

        //function PrintReceipt(pat_id) {
        //    var locationInfo = window.location;
        //    var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;

        //    if (!locationInfo.origin.includes('localhost')) {
        //        var urlInfo = window.location.href.split('/');
        //        var ip = urlInfo[2];
        //        var foldername = urlInfo[3];
        //        url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;
        //    }
        //    window.open(url, '_blank');
        //}

        function PrintReceipt(pat_id) {
            $.ajax({
                type: "POST",
                url: "RegList.aspx/IncrementReprintCount",
                data: JSON.stringify({ pat_id: pat_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true, 
                success: function (response) {
                    if (response.d === "Success") {
                        console.log("Reprint count incremented for Patient: " + pat_id);
                    } else {
                        console.warn("Failed to increment reprint count: " + response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error updating reprint count:", error);
                }
            });

            
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;

            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                
                var pathPrefix = foldername ? '/' + foldername : '';
                url = 'http://' + ip + pathPrefix + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + pat_id;
            }

            window.open(url, '_blank');
        }
        function editOpen(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: `You are about to edit this patient`,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, edit it!',
                cancelButtonText: 'Cancel',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    PageMethods.EditPatient(id, function (msg) {
                        if (msg === "NotAllowed") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Access Denied',
                                text: 'You do not have permission to edit this patient.'
                            });
                        } else if (msg === "Allowed") {
                            window.open("RegisterPatient.aspx?Reg_id=" + id, "_blank");
                        }
                    });
                }
            });
        }

        var logLabelMap = {
            Patient_No: 'Patient No',
            mr_no_sequence: 'MR No',
            CreationDate: 'Creation Date',
            Full_Name: 'Full Name',
            Father_Name: 'Father Name',
            Gender: 'Gender',
            Mobile1: 'Mobile',
            Age_years: 'Age',
            NIC: 'NIC',
            Permanent_Address: 'Address',
            Martial_Status: 'Martial Status',
            Relation_prefix: 'Relation',
            walkin: 'Walk-in',
            city: 'City',
            val_city: 'Val City',
            val_area: 'Val Area',
            area: 'Area',
            Country: 'Country',
            Province: 'Province',
            Card_fee: 'Card Fee',
            other_cnic: 'Other CNIC',
            DOB: 'DOB'
        };

        var allLogsData = [];
        var currentPatientData = null;

        function formatLogValue(key, val) {
            if (val === null || val === undefined) return '-';
            if (key === 'CreationDate' || key === 'DOB') {
                if (typeof val === 'string' && val.indexOf('/Date(') === 0) {
                    var ms = parseInt(val.replace(/\/Date\((\d+)\)\//, '$1'));
                    return moment(ms).format('DD-MMM-YYYY');
                }
                if (typeof val === 'string') return moment(val).format('DD-MMM-YYYY');
                return val;
            }
            if (key === 'walkin') return val ? 'Yes' : 'No';
            if (key === 'Card_fee') return parseFloat(val).toFixed(2);
            return val;
        }

        function formatLogTime(dateStr) {
            if (!dateStr) return '-';
            return moment(dateStr).format('DD-MMM-YYYY hh:mm A');
        }

        function renderChangedTables(oldData, newData) {
            var changedKeys = [];
            $.each(logLabelMap, function (key) {
                var oldVal = formatLogValue(key, oldData[key]);
                var newVal = formatLogValue(key, newData[key]);
                if (oldVal !== newVal) {
                    changedKeys.push(key);
                }
            });

            var oldBody = $('#oldLogTableBody');
            var newBody = $('#newLogTableBody');
            oldBody.empty();
            newBody.empty();

            if (changedKeys.length === 0) {
                var msg = '<tr><td colspan="2" class="text-center" style="color:#999;">No changes in this log</td></tr>';
                oldBody.append(msg);
                newBody.append(msg);
                return;
            }

            $.each(changedKeys, function (i, key) {
                var label = logLabelMap[key];
                var oldVal = formatLogValue(key, oldData[key]);
                var newVal = formatLogValue(key, newData[key]);
                oldBody.append('<tr class="log-changed-row"><td style="font-weight:600;width:180px;">' + label + '</td><td>' + oldVal + '</td></tr>');
                newBody.append('<tr><td style="font-weight:600;width:180px;">' + label + '</td><td>' + newVal + '</td></tr>');
            });
        }

        function onLogChange() {
            var selLogId = $('#logSelect').val();
            if (!selLogId || !currentPatientData) return;
            for (var i = 0; i < allLogsData.length; i++) {
                if (allLogsData[i].Log_Id == selLogId) {
                    var log = allLogsData[i];
                    var oldData = typeof log.Updated_data === 'string' ? JSON.parse(log.Updated_data) : log.Updated_data;
                    renderChangedTables(oldData, currentPatientData);
                    $('#oldLogInfo').html('<i class="fa fa-user"></i> ' + log.UserName + ' &nbsp;|&nbsp; <i class="fa fa-clock-o"></i> ' + formatLogTime(log.Loged_Time));
                    break;
                }
            }
        }

        function openHistoryModal(pat_id) {
            try {
                Swal.fire({ icon: 'info', title: 'Loading', text: 'Fetching logs for patient #' + pat_id });
            } catch (e) {
                alert('Error: ' + e.message);
            }

            $.ajax({
                type: "POST",
                url: "RegList.aspx/GetPatientLogs",
                data: JSON.stringify({ pat_id: pat_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (logsResp) {
                    var logsData = JSON.parse(logsResp.d);
                    if (!logsData || logsData.length === 0) {
                        $('#historyModalBody').hide();
                        $('#noLogsMsg').show();
                        $('#historyModal').modal('show');
                        return;
                    }

                    $.ajax({
                        type: "POST",
                        url: "RegList.aspx/GetCurrentPatientData",
                        data: JSON.stringify({ pat_id: pat_id }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (currResp) {
                            var currData = JSON.parse(currResp.d);
                            allLogsData = logsData;
                            currentPatientData = currData;

                            if (!currData) {
                                $('#historyModalBody').hide();
                                $('#noLogsMsg').show();
                                $('#historyModal').modal('show');
                                return;
                            }

                            $('#newLogInfo').html('<i class="fa fa-user"></i> Current &nbsp;|&nbsp; <i class="fa fa-clock-o"></i> ' + moment().format('DD-MMM-YYYY hh:mm A'));

                            var lastLog = logsData[logsData.length - 1];
                            var lastData = JSON.parse(lastLog.Updated_data);
                            renderChangedTables(lastData, currData);
                            $('#oldLogInfo').html('<i class="fa fa-user"></i> ' + lastLog.UserName + ' &nbsp;|&nbsp; <i class="fa fa-clock-o"></i> ' + formatLogTime(lastLog.Loged_Time));

                            var $select = $('#logSelect');
                            $select.empty();
                            for (var i = 0; i < logsData.length; i++) {
                                var log = logsData[i];
                                $select.append('<option value="' + log.Log_Id + '">Log #' + log.Log_Id + ' - ' + formatLogTime(log.Loged_Time) + '</option>');
                            }
                            $select.val(lastLog.Log_Id);

                            $('#historyModalBody').show();
                            $('#historyModal').modal('show');
                        },
                        error: function (xhr) {
                            Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load patient data. Status: ' + xhr.status });
                        }
                    });
                },
                error: function (xhr) {
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load logs. Status: ' + xhr.status });
                }
            });
        }

        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "RegList.aspx/GetUserColumnPreferences",
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

            var table = $("#example").DataTable({
                processing: true,
                serverSide: true,
                destroy: true,
                dom: 'lBfrtip',
                lengthChange: true,
                columnDefs: savedVisibility ? [] : [
                    { targets: [0], visible: false },
                    { targets: [8], className: "noVis" }
                ],

                buttons: [
                    {
                        text: '<i class="fa fa-plus"></i> Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'RegisterPatient.aspx';
                        }
                    },
                    {
                        extend: 'copy',
                        text: '<i class="fa fa-copy"></i> Copy',
                        className: 'dt-button buttons-copy'
                    },
                    {
                        extend: 'excel',
                        text: '<i class="fa fa-file-excel"></i> Excel',
                        className: 'dt-button buttons-excel'
                    },
                    {
                        extend: 'pdf',
                        text: '<i class="fa fa-file-pdf"></i> PDF',
                        className: 'dt-button buttons-pdf'
                    },
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],

                order: [[1, "asc"]],

                ajax: function (data, callback) {
                    $.ajax({
                        type: "POST",
                        url: "RegList.aspx/ViewList",
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
                        }
                    });
                },

                columns: [
                    { data: "pat_id", visible: false, orderable: false },
                    { data: "MRNO", name: "MRNO" },
                    { data: "Full_Name" },
                    { data: "Age_years", name: "Age_years" },
                    {
                        data: "Created_time",
                        name: "Created_time",
                        render: function (data) {
                            return moment(data).format('DD-MMM-YYYY');
                        }
                    },
                    { data: "NIC" },
                    { data: "Mobile1" },
                    { data: "Permanent_Address" },
                    {
                        data: null,
                        orderable: false,
                        searchable: false,
                        render: function (data, type, full) {
                            var editButton = `<a href="#" onclick="editOpen(${full.pat_id})" class="editListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" title="Edit">
                                  <i class="fa fa-pencil" style="color: #667eea;"></i>
                              </a>`;

                            var historyButton = `<a href="#" onclick="openHistoryModal(${full.pat_id})" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" title="History">
                                  <i class="fa fa-history" style="color: #667eea;"></i>
                              </a>`;

                            var printButton = '';
                            if (allowPrint) {
                                printButton = `<a href="#" class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" onclick="PrintReceipt(${full.pat_id})" title="Print">
                                   <i class="fa fa-print"></i>
                               </a>`;
                            }

                            return editButton + historyButton + printButton;
                        }
                    }
                ],

                initComplete: function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                if (index === 0) {
                                    this.visible(false); 
                                } else if (index === 8) {
                                    this.visible(true); 
                                } else {
                                    this.visible(savedVisibility[index]);
                                }
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
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

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
                },

                drawCallback: function () {
                    var api = this.api();
                    updateColumnHeaders(api);
                }
            });

            table.on('column-visibility.dt', function (e, settings, column, state) {
                setTimeout(function () {
                    updateColumnHeaders(table);
                }, 100);
            });
        }

        function updateColumnHeaders(table) {
            var api = table;
            var headers = api.columns().header();

            api.columns().every(function (index) {
                var column = api.column(index);
                var header = $(headers[index]);
                var isVisible = column.visible();

                if (isVisible) {
                    header.removeClass('hidden-col');
                } else {
                    header.addClass('hidden-col');
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
  
    <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display" style="width:100%">
                <thead>
                    <tr>
                        <th>Pat ID</th>
                        <th>MR No.</th>
                        <th>Name</th>
                        <th>Age</th>
                        <th>Created Date</th>
                        <th>CNIC</th>
                        <th>Phone Number</th>
                        <th>Address</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="historyModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog custom-modal-width" style="width:90%;max-width:1200px;" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title"><i class="fa fa-history"></i> Logs</h4>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="margin-top:-11px">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="row" id="historyModalBody">
                        <div class="col-lg-6 col-md-6 col-sm-12" id="oldLogPanel">
                            <h5 style="border-bottom:2px solid #667eea;padding-bottom:8px;">Old Data</h5>
                            <div class="form-group">
                                <label>Log Number</label>
                                <select id="logSelect" class="form-control" onchange="onLogChange()"></select>
                            </div>
                            <div id="oldLogInfo" style="margin-bottom:10px;font-size:12px;color:#666;"></div>
                            <table class="table table-bordered table-striped" style="border:1px solid #ddd;">
                                <thead><tr><th>Label</th><th>Value</th></tr></thead>
                                <tbody id="oldLogTableBody"></tbody>
                            </table>
                        </div>
                        <div class="col-lg-6 col-md-6 col-sm-12" id="newLogPanel">
                            <h5 style="border-bottom:2px solid #28a745;padding-bottom:8px;">New Data</h5>
                            <div style="height:58px;"></div>
                            <div id="newLogInfo" style="margin-bottom:10px;font-size:12px;color:#666;"></div>
                            <table class="table table-bordered table-striped" style="border:1px solid #ddd;">
                                <thead><tr><th>Label</th><th>Value</th></tr></thead>
                                <tbody id="newLogTableBody"></tbody>
                            </table>
                        </div>
                    </div>
                    <div id="noLogsMsg" class="text-center" style="display:none;padding:40px;color:#999;">
                        <i class="fa fa-info-circle fa-3x"></i>
                        <p style="margin-top:10px;">No history available for this patient.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>