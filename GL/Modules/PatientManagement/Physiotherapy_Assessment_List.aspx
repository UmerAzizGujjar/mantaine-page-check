<%@ Page Title="Physiotherapy Assessment List" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Physiotherapy_Assessment_List.aspx.cs" Inherits="PMS.Modules.PatientManagement.Physiotherapy_Assessment_List" %>

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
            initDateFilter();   // default: current month, filter ON
            $('#tblList').DataTable({
                processing: true,
                serverSide: true,
                dom: 'lBfrtip',
                lengthChange: true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'Physiotherapy_Assessment.aspx'; }
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
                ajax: function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "Physiotherapy_Assessment_List.aspx/GetAssessmentList",
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
                        error: function (xhr) { console.log(xhr.responseText); }
                    });
                },
                columns: [
                    { data: 'MR', name: 'MR', width: '10%' },
                    { data: 'PatientName', name: 'PatientName', width: '20%' },
                    {
                        data: 'AssessmentDate', name: 'AssessmentDate', width: '12%',
                        render: function (data, type, full) {
                            return full.AssessmentDate || '';
                        }
                    },
                    { data: 'Department', name: 'Department', width: '15%' },
                    {
                        data: null, width: '14%', orderable: false, searchable: false,
                        render: function (data, type, full) {
                            return '<a href="#" onclick="window.open(\'Physiotherapy_Assessment.aspx?ID=' + full.OutPatientId + '\',\'_blank\')" class="editListBtn" style="border-radius:4px;padding:5px 8px"><i class="fa fa-pencil"></i></a>' +
                                   '<a href="#" onclick="window.open(\'Physiotherapy_Assessment.aspx?ID=' + full.OutPatientId + '&print=1\',\'_blank\')" class="printListBtn" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px"><i class="fa fa-print"></i></a>';
                        }
                    }
                ]
            });
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
            if ($.fn.DataTable.isDataTable('#tblList')) {
                $('#tblList').DataTable().ajax.reload();
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

    <div id="POdetails" style="margin-top: 15px;">
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblList" style="overflow: scroll; height: auto;">
                    <thead>
                        <tr>
                            <th>MR #</th>
                            <th>Patient Name</th>
                            <th>Date</th>
                            <th>Department</th>
                            <th style="width:14%">Actions</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
