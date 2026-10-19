<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RadiologyResultsPreview.aspx.cs" Inherits="PMS.RadiologyResultsPreview" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .select2-search--dropdown .select2-search__field {
            padding: 4px;
            width: 100% !important;
            box-sizing: border-box;
        }

        .orthanc-spinner {
            display: inline-block;
            width: 14px;
            height: 14px;
            border: 2px solid #d9d9d9;
            border-top: 2px solid #007bff;
            border-radius: 50%;
            animation: orthancSpin 0.8s linear infinite;
        }

        @keyframes orthancSpin {
            to {
                transform: rotate(360deg);
            }
        }

        #tblradilogy tbody tr {
            cursor: pointer;
        }

        .series-table {
            width: 100%;
        }

    </style>
    <script type="text/javascript">
        var doctorsList = [];
        var orthancBaseUrl = '';
        var orthancStudyCache = {};
        var radiologyTable = null;

        $(document).ready(function () {
            loadDoctors();
            loadDoctorsforFilter();
            loadRadiologyAcknowledgment();
            FillMainTestDepartment();

            $('#mainDepartmentFilter, #ddlDoctorFilter, #ddlMainTestDepartment').on('change', function () {
                $('#tblradilogy').DataTable().ajax.reload();
            });

            $('#tblradilogy tbody').on('click', 'tr', function (e) {
                if ($(e.target).closest('a, button').length) {
                    return;
                }

                toggleRowExpansion(this);
            });

            $('#tblradilogy tbody').on('click', '.btn-delete-series', function () {
                alert('Delete Series endpoint is not exposed in current WebMethod contract.');
            });
        });

        function loadDoctors() {
            $.ajax({
                type: "POST",
                url: "RadiologyResultsPreview.aspx/GetDoctors",
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    // Safely parse in case it's already an object
                    doctorsList = typeof response.d === "string" ? JSON.parse(response.d) : response.d;
                },
                error: function (xhr) {
                    console.log(xhr.responseText);
                }
            });
        }

        function loadRadiologyAcknowledgment() {
            radiologyTable = $("#tblradilogy").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "ajax": function (data, callback, settings) {

                    $.ajax({
                        type: "POST",
                        url: "RadiologyResultsPreview.aspx/GetRadiologyAcknowledgment",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            mainDepartmentFilter: $('#mainDepartmentFilter').val() || 'All',
                            statusFilter: 'All',
                            ddlDoctorFilter: $('#ddlDoctorFilter').val() || '0',
                            mainTestDepartmentFilter: $('#ddlMainTestDepartment').val() || 'All'
                        }),
                        contentType: "application/json; charset=utf-8",
                        success: function (response) {
                            // Fix: Ensure we parse the data if ASP.NET returned a string
                            var resultData = typeof response.d === "string" ? JSON.parse(response.d) : response.d;

                            callback({
                                draw: resultData.draw,
                                recordsTotal: resultData.recordsTotal,
                                recordsFiltered: resultData.recordsFiltered,
                                data: resultData.data
                            });
                        },
                        error: function (xhr) {
                            console.error("DataTable AJAX Error:", xhr.responseText);
                            // Fix: Tell DataTables to stop loading on error!
                            callback({
                                draw: data.draw,
                                recordsTotal: 0,
                                recordsFiltered: 0,
                                data: []
                            });
                        }
                    });
                },
                "columns": [
                    {
                        "data": "Bill_Date", "width": "10%", "name": "Bill_Date",
                        "render": function (data) {
                            // Ensure moment.js is loaded in your Master Page or this will crash!
                            return data ? moment(data).format("DD-MMM-YYYY") : "";
                        }
                    },
                    { "data": "mr_no_sequence", "width": "10%", "name": "mr_no_sequence" },
                    { "data": "Full_Name", "width": "10%" },
                    { "data": "Item_Name", "width": "10%" },
                    { "data": "Lab_Test_Detail_ID", "width": "10%", "name": "Lab_Test_Detail_ID" },
                    { "data": "Main_Test_Departments", "width": "10%" },
              
                    {
                        "data": "DoctorID", "width": "10%",
                        "name": "DoctorID",
                        "orderable": false,
                        "render": function (data, type, row) {
                             var labTestDoctorId = row.LabTest_DoctorID || 0;
                            var billingDoctorId = row.Billing_DoctorID || 0;
                            var selectedId = labTestDoctorId !== 0 ? labTestDoctorId : billingDoctorId;

                             var doctor = doctorsList.find(function (d) {
                                return d.Emp_ID == selectedId;
                            });

                             return doctor ? doctor.Emp_Name : '<span class="text-muted">Not Assigned</span>';
                        }
                    },
                    {
                        "data": null,
                        "width": "12%",
                        "name": "ScanDateTime",
                        "orderable": false,
                        "render": function (data, type, row) {
                            var accession = row.Lab_Test_Detail_ID || '';
                            return '<div class="scan-date-time" data-accession="' + accession + '"><span class="orthanc-spinner"></span></div>';
                        }
                    },
                    {
                        "data": null,
                        "width": "10%",
                        "name": "OrthancActions",
                        "orderable": false,
                        "render": function (data, type, row) {
                            var accession = row.Lab_Test_Detail_ID || '';
                            return '<div class="orthanc-actions" data-accession="' + accession + '"><span class="orthanc-spinner"></span></div>';
                        }
                    }
                ],
                "drawCallback": function () {
                    lazyLoadOrthancActions();
                },
                "initComplete": function () {
                    lazyLoadOrthancActions();
                }
            });
        }

        function lazyLoadOrthancActions() {
            if (!radiologyTable) return;

            var accessionNumbers = [];
            var seen = {};

            radiologyTable.rows({ page: 'current' }).every(function () {
                var row = this.data();
                var accession = row && row.Lab_Test_Detail_ID ? row.Lab_Test_Detail_ID.toString() : '';
                if (!accession || seen[accession]) {
                    return;
                }

                seen[accession] = true;
                accessionNumbers.push(accession);
            });

            if (!accessionNumbers.length) return;

            $.ajax({
                type: "POST",
                url: "RadiologyResultsPreview.aspx/CheckOrthancStudiesBatch",
                data: JSON.stringify({ accessionNumbers: accessionNumbers }),
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    var result = typeof response.d === "string" ? JSON.parse(response.d) : response.d;
                    var studies = result && result.Studies ? result.Studies : {};
                    orthancBaseUrl = result && result.BaseUrl ? result.BaseUrl : orthancBaseUrl;

                    $.each(studies, function (accession, info) {
                        orthancStudyCache[accession] = info;
                    });

                    updateActionsCells();
                },
                error: function () {
                    updateActionsCells();
                }
            });
        }

        function updateActionsCells() {
            if (!radiologyTable) return;

                radiologyTable.rows({ page: 'current' }).every(function () {
                    var row = this.data();
                    var accession = row && row.Lab_Test_Detail_ID ? row.Lab_Test_Detail_ID.toString() : '';
                    var info = accession ? orthancStudyCache[accession] : null;
                    var actionCell = $(this.node()).find('.orthanc-actions');
                    var scanCell = $(this.node()).find('.scan-date-time');

                    if (scanCell.length) {
                        if (info && info.Exists && info.OrthancStudyId) {
                            var scanDateTime = formatDicomDateTime(info.StudyDate, info.StudyTime);
                            scanCell.html(scanDateTime || '<span class="text-muted">No Scan</span>');
                        } else {
                            scanCell.html('<span class="text-muted">No Scan</span>');
                        }
                    }

                    if (!actionCell.length) return;

                    if (info && info.Exists && info.OrthancStudyId) {
                        actionCell.html(buildOrthancButtons(info.StudyInstanceUID, info.OrthancStudyId));
                    } else {
                        actionCell.html('<span class="text-muted">No Scan</span>');
                    }
                });
        }

        function loadDoctorsforFilter() {
            PageMethods.loadDoctorsforFilter(
                function (data) {
                    var parsedData = typeof data === "string" ? JSON.parse(data) : data;
                    var options = '<option value="0" >Please Select</option>';
                    $.each(parsedData, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '" >' + value.name + '</option>';
                    });
                    $('#ddlDoctorFilter').html(options).select2();
                },
                function (error) {
                    alert(error.get_message());
                }
            );
        }

        function buildOrthancButtons(studyUid, orthancId) {
            var viewUrl = orthancBaseUrl + '/ohif/viewer?StudyInstanceUIDs=' + encodeURIComponent(studyUid);
            var segmentationUrl = orthancBaseUrl + '/ohif/segmentation?StudyInstanceUIDs=' + encodeURIComponent(studyUid);
            var downloadUrl = orthancBaseUrl + '/studies/' + encodeURIComponent(orthancId) + '/archive';

            var radiantButton = '';
            if (studyUid) {
                radiantButton = '<a class="btn btn-primry d-inline-flex align-items-center ms-1" href="LaunchRadiAnt.aspx?uid='
                    + encodeURIComponent(studyUid) + '" target="_blank" rel="noopener noreferrer" title="Open in RadiAnt">'
                    + '<i class="fa fa-external-link me-1"></i></a>';
            }

            return `
    <div class="d-flex flex-nowrap">
        <a class="btn btn-primry d-inline-flex align-items-center" href="${viewUrl}" target="_blank" rel="noopener noreferrer">
            <i class="fa fa-eye me-1"></i>
        </a>
        <a class="btn btn-primry d-inline-flex align-items-center ms-1" href="${segmentationUrl}" target="_blank" rel="noopener noreferrer">
            <i class="fa fa-cube me-1"></i>
        </a>
        <a class="btn btn-primry d-inline-flex align-items-center ms-1" href="${downloadUrl}" target="_blank" rel="noopener noreferrer">
            <i class="fa fa-download me-1"></i>
        </a>
        ${radiantButton}
    </div>
`;
        }

        function toggleRowExpansion(rowNode) {
            if (!radiologyTable) return;

            var row = radiologyTable.row(rowNode);
            var rowData = row.data();

            if (!rowData) return;

            if (row.child.isShown()) {
                row.child.hide();
                $(rowNode).removeClass('shown');
                return;
            }

            radiologyTable.rows().every(function () {
                if (this.node() !== rowNode && this.child.isShown()) {
                    this.child.hide();
                    $(this.node()).removeClass('shown');
                }
            });

            row.child('<div style="padding:10px;"><span class="orthanc-spinner"></span> Loading study details...</div>').show();
            $(rowNode).addClass('shown');

            var accession = rowData.Lab_Test_Detail_ID ? rowData.Lab_Test_Detail_ID.toString() : '';
            var info = accession ? orthancStudyCache[accession] : null;

            if (!info || !info.Exists || !info.OrthancStudyId) {
                row.child('<div class="text-muted" style="padding:10px;">No scan available for this accession.</div>').show();
                return;
            }

            $.ajax({
                type: "POST",
                url: "RadiologyResultsPreview.aspx/GetStudyDetailsAndSeries",
                data: JSON.stringify({ orthancStudyId: info.OrthancStudyId }),
                contentType: "application/json; charset=utf-8",
                success: function (response) {
                    var result = typeof response.d === "string" ? JSON.parse(response.d) : response.d;
                    if (!result || !result.Success) {
                        row.child('<div class="text-danger" style="padding:10px;">Unable to load study details.</div>').show();
                        return;
                    }

                    row.child(buildExpandedContent(result, rowData)).show();
                },
                error: function () {
                    row.child('<div class="text-danger" style="padding:10px;">Unable to load study details.</div>').show();
                }
            });
        }

        function buildExpandedContent(result, rowData) {
            var study = result.Study || {};
            var series = result.Series || [];
            var details = '<div class="row" style="padding:10px; background:#fafafa;">'
                + '<div class="col-md-2"><strong>Study Date:</strong> ' + (formatDicomDate(study.StudyDate) || '-') + '</div>'
                + '<div class="col-md-2"><strong>Study Time:</strong> ' + (formatDicomTime(study.StudyTime) || '-') + '</div>'
                + '<div class="col-md-2"><strong>Accession:</strong> ' + (study.AccessionNumber || rowData.Lab_Test_Detail_ID || '-') + '</div>'
                + '<div class="col-md-3"><strong>Physician:</strong> ' + (study.RequestingPhysicianName || '-') + '</div>'
                + '<div class="col-md-3"><strong>Description:</strong> ' + (study.StudyDescription || '-') + '</div>'
                + '</div>';

            var rows = '';
            $.each(series, function (_, item) {
                var seriesId = item.OrthancSeriesId || '';
                var downloadUrl = result.BaseUrl + '/series/' + encodeURIComponent(seriesId) + '/archive';
                var niftiUrl = result.BaseUrl + '/series/' + encodeURIComponent(seriesId) + '/nifti';
                var volViewUrl = buildVolViewUrl(result.BaseUrl, seriesId);

                rows += '<tr>'
                    + '<td>' + (item.SeriesNumber || '-') + '</td>'
                    + '<td>' + (item.SeriesDescription || '-') + '</td>'
                    + '<td>' + (item.InstancesCount || 0) + '</td>'
                    + '<td>' + (item.BodyPartExamined || '-') + '</td>'
                    + '<td>'
                    + '<a class="btn btn-xs btn-primry" title="Download ZIP" href="' + downloadUrl + '" target="_blank" rel="noopener noreferrer"><i class="fa fa-download"></i></a> '
                    + '<button type="button" class="btn btn-xs btn-primry" title="Delete Series" data-series-id="' + seriesId + '"><i class="fa fa-trash"></i></button> '
                    + '<a class="btn btn-xs btn-primry" title="Export to NIfTI" href="' + niftiUrl + '" target="_blank" rel="noopener noreferrer"><i class="fa fa-file"></i></a> '
                    + '<a class="btn btn-xs btn-primry" title="View in VolView" href="' + volViewUrl + '" target="_blank" rel="noopener noreferrer"><i class="fa fa-eye"></i></a>'
                    + '</td>'
                    + '</tr>';
            });

            if (!rows) {
                rows = '<tr><td colspan="5" class="text-muted">No series found.</td></tr>';
            }

            var tableHtml = '<div style="padding:10px;">'
                + '<table class="table table-condensed table-bordered series-table">'
                + '<thead><tr><th>Series Number</th><th>Description</th><th># Instances</th><th>Body Part Examined</th><th>Actions</th></tr></thead>'
                + '<tbody>' + rows + '</tbody>'
                + '</table>'
                + '</div>';

            return details + tableHtml;
        }

        function buildVolViewUrl(baseUrl, orthancSeriesId) {
            var names = encodeURIComponent('[archive.zip]');
            var urls = encodeURIComponent('[../series/' + orthancSeriesId + '/archive]');
            return baseUrl + '/volview/index.html?names=' + names + '&urls=' + urls;
        }

        function formatDicomDate(value) {
            if (!value || value.length !== 8) return value;
            return value.substring(6, 8) + '-' + value.substring(4, 6) + '-' + value.substring(0, 4);
        }

        function formatDicomTime(value) {
            if (!value || value.length < 6) return value;
            return value.substring(0, 2) + ':' + value.substring(2, 4) + ':' + value.substring(4, 6);
        }

        function formatDicomDateTime(dateValue, timeValue) {
            if (!dateValue && !timeValue) return '';

            var formattedDate = formatDicomDate(dateValue) || '';
            var normalizedTime = timeValue ? timeValue.split('.')[0] : '';
            var formattedTime = formatDicomTime(normalizedTime) || '';

            if (formattedDate && formattedTime) return formattedDate + ' ' + formattedTime;
            return formattedDate || formattedTime;
        }

        function FillMainTestDepartment() {
            var options = '<option value="All" >All</option>';
            PageMethods.FillTestMainDepartment(
                function (Tests) {
                    var parsedTests = typeof Tests === "string" ? JSON.parse(Tests) : Tests;
                    $.each(parsedTests, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlMainTestDepartment').html(options);
                },
                function (error) {
                    console.log(error);
                }
            );
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
            <div style="margin-bottom: 15px;">
                <div class="row">
                    <div class="col-md-3">
                        <label>Main Department:</label>
                        <select id="mainDepartmentFilter" class="form-control">
                            <option value="All">All</option>
                            <option value="WalkIn">Walk In</option>
                            <option value="OutPatient">Out Patient</option>
                            <option value="InPatient">In Patient</option>
                            <option value="Emergency">Emergency</option>
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Doctor:</label>
                        <select id="ddlDoctorFilter" class="form-control">
                        </select>
                    </div>
                    <div class="col-md-3">
                        <label>Main Test Department:</label>
                        <select id="ddlMainTestDepartment" class="form-control">
                            <option value="All">All</option>
                        </select>
                    </div>
                </div>
            </div>
            <table style="width: 100%;">
                <tr>
                    <td>
                        <div id="POdetails" style="margin-top: 15px;">
                            <div>
                                <table class="table table-hover table-striped table-bordered" id="tblradilogy" style="overflow: scroll; height: auto;">
                                    <thead id="ihead">
                                        <tr>
                                            <th>Bill Date</th>
                                             <th>MR No</th>
                                            <th>Name</th>
                                            <th>Test Name</th>
                                            <th>Accession Number</th>
                                            <th>Main Test Department</th>
                                            <th>Doctor</th>
                                             <th>Scan Date Time</th>
                                             <th>Actions</th>

                                        </tr>
                                    </thead>
                                    <tbody id="tbl_tbody_radiology">
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
