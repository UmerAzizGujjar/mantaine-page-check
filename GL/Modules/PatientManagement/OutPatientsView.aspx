<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OutPatientsView.aspx.cs" Inherits="PMS.WebForm12" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css?v=<%= ((PMS.SiteMaster)Master).Ver("~/wwwroot/THEME_TIBBIT/CustomCSS/responsive-pages.css") %>" rel="stylesheet" />

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

        function PrintoutPatient(Out_Patient_ID) {
            var url = '../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + Out_Patient_ID;
            window.open(url, '_blanks');
        }


        function Edit(id) {
            var newWin = window.open('', '_blank');
            $.ajax({
                type: "POST",
                url: "OutPatientsView.aspx/GetOutPatientNewFormRedirectPermission",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    var url = result.useNewForm
                        ? "NewOutPatient.aspx?ID=" + id
                        : "OutPatients.aspx?ID=" + id;
                    if (newWin) {
                        newWin.location.href = url;
                    } else {
                        window.open(url, '_blank');
                    }
                },
                error: function () {
                    if (newWin) newWin.close();
                    window.open("NewOutPatient.aspx?ID=" + id + "");
                }
            });
        }

        function deleteConfirm(anchorTag) {
            var row = $(anchorTag).parents('tr')[0];
            var OutPatientID = $(anchorTag).data('id');

            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(OutPatientID, function (msg) {
                    if (msg === "Delete") {
                        $(row).remove();
                    } else {
                        alert("This Patient is in Billing Process");
                    }
                }, function (error) {
                    console.error(error);
                    alert("An error occurred while deleting the record.");
                });
            }
        }


        function PrintVoucher(id) {

            var locationInfo = window.location;
            var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPDShare';

            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername +
                    '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' +
                    id + '&TransType=OPDShare';
            }

            window.open(url, '_blank');
        }



        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "OutPatientsView.aspx/GetUserColumnPreferences",
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
            const table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = '/Modules/PatientManagement/NewOutPatient.aspx';
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
                        url: "OutPatientsView.aspx/ViewList",
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
                    { "data": "Out_Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%" },
                    { "data": "Full_Name", "width": "15%", "orderable": false },
                    { "data": "Father_Name", "width": "15%", "orderable": false },
                    { "data": "Category", "width": "20%", "orderable": false },
                    { "data": "Mobile1", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            var date = full.Created_Time;
                            return moment(date).format('DD-MMM-YYYY');
                        },
                        "width": "10%"
                    },
                    {
                        render: function (data, type, full) {

                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Out_Patient_ID + ')" style="border-radius:4px;margin-right:4px;padding:5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" href="#" data-id="' + full.Out_Patient_ID + '" onclick="deleteConfirm(this)" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" href="#" onclick="PrintoutPatient(' + full.Out_Patient_ID + ')" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;"><i class="fa fa-print"></i></a>';
                            var voucher = "";
                            if (full.Status === "Approved") {
                                voucher = '<a class="printListBtn" href="#" onclick="PrintVoucher(' + full.Out_Patient_ID + ')" title="Print Voucher" style="border-radius:4px;margin-left:4px;color:black;padding:5px 8px;"><i class="fa fa-money"></i></a>';
                            }
                            return res + Del + print + voucher;
                        },
                        "width": "10%",
                        "orderable": false
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

                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        label.innerHTML = 'Show entries ';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '15px';

                        lengthDropdown.style.marginLeft = '5px';
                        lengthDropdown.style.marginTop = '-13px';

                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
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
    <div id="OutPatdetails" >

        <div class="row">
            
            <div class="table-container col-lg-12 col-md-12 col-sm-10" style="margin-top: 15px;">
                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                    <thead id="ihead">
                        <tr>
                            <th style="display: none; width: 0%;">OPD ID</th>
                            <th>MR No.</th>
                            <th>Full_Name</th>
                            <th>Father_Name</th>
                            <th>Category</th>
                            <th>Mobile#</th>
                            <th>Created_Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
