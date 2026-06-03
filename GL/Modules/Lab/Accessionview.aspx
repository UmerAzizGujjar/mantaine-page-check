<%@ Page Title="Accession View" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccessionView.aspx.cs" Inherits="PMS.AccessionView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <style>
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block;
        }
        .status-Collected { background: #d4edda; color: #155724; }
        .status-Pending { background: #fff3cd; color: #856404; }
        .status-Processing { background: #cce5ff; color: #004085; }
        .status-Completed { background: #d1ecf1; color: #0c5460; }
        .status-Dispatched { background: #d4edda; color: #155724; }
        
        .dispatch-btn {
            background: #28a745;
            color: white;
            border: none;
            padding: 4px 12px;
            border-radius: 4px;
            cursor: pointer;
        }
        .dispatch-btn:hover { background: #218838; }
        .dispatch-all-btn {
            background: #007bff;
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            margin-right: 10px;
            cursor: pointer;
        }
        .action-bar {
            background: white;
            padding: 15px;
            margin-bottom: 20px;
            border-radius: 5px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            display: flex;
            align-items: center;
            gap: 15px;
        }
        .accession-number {
            font-family: monospace;
            font-weight: bold;
            color: #0066cc;
            font-size: 14px;
        }
        .selected-row {
            background-color: #e3f2fd !important;
        }
        .dt-button {
            margin: 0 2px;
        }
        /* Prevent form submission */
        form {
            margin: 0;
            padding: 0;
        }
    </style>
    <script type="text/javascript">
        // Prevent any form submission
        $(document).ready(function () {
            // Disable any form submission on enter key
            $(document).on('keypress', 'form input[type="text"]', function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    return false;
                }
            });

            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function PrintSample(sample_id) {
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=LabSlip&Title=Sample Report&Lab_ID=" + sample_id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=LabSlip&Title=Sample Report&Lab_ID=" + sample_id;
            }
            window.open(url, '_blank');
            return false;
        }

        function editSample(id) {
            window.location.href = "SampleCollectionFrom.aspx?SampleId=" + id;
            return false;
        }

        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "AccessionView.aspx/GetUserColumnPreferences",
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
                order: [[2, "asc"]],
                pageLength: 25,

                buttons: [
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

                ajax: function (data, callback) {
                    $.ajax({
                        type: "POST",
                        url: "AccessionView.aspx/GetAccessionList",
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
                            console.error("AJAX Error:", error);
                            callback({
                                draw: 0,
                                recordsTotal: 0,
                                recordsFiltered: 0,
                                data: []
                            });
                        }
                    });
                },

                columns: [
                    {
                        data: null,
                        orderable: false,
                        searchable: false,
                        width: "30px",
                        render: function (data, type, full) {
                            if (full.dispatch_status !== "Dispatched") {
                                return '<input type="checkbox" class="select-row" data-id="' + full.Sample_Detail_ID + '" data-accession="' + full.Accession_No + '">';
                            }
                            return '<input type="checkbox" class="select-row" disabled data-id="' + full.Sample_Detail_ID + '" data-accession="' + full.Accession_No + '">';
                        }
                    },
                    { data: "Sample_Detail_ID", visible: false, name: "Sample_Detail_ID" },
                    { data: "Accession_No", name: "Accession_No", className: "accession-number" },
                    { data: "Sample_No", name: "Sample_No" },
                    {
                        data: "Sample_Collected_Date",
                        name: "Sample_Collected_Date",
                        render: function (data) {
                            return data ? moment(data).format('DD-MMM-YYYY') : '';
                        }
                    },
                    { data: "MR_No", name: "MR_No" },
                    { data: "Full_Name", name: "Full_Name" },
                    { data: "Test_Name", name: "Test_Name" },
                    { data: "Mobile1", name: "Mobile1" },
                    { data: "OutSource", name: "OutSource" },
                    {
                        data: "dispatch_status",
                        name: "dispatch_status",
                        render: function (data) {
                            if (data === "Dispatched") {
                                return '<span class="status-badge status-Dispatched">Dispatched</span>';
                            }
                            return '<span class="status-badge status-Pending">Pending</span>';
                        }
                    },
                    {
                        data: "dispatch_date",
                        name: "dispatch_date",
                        render: function (data) {
                            return data ? moment(data).format('DD-MMM-YYYY HH:mm') : '-';
                        }
                    },
                    { data: "Dispatched_By", name: "Dispatched_By" },
                    {
                        data: null,
                        orderable: false,
                        searchable: false,
                        render: function (data, type, full) {
                            if (full.dispatch_status !== "Dispatched") {
                                return '<button type="button" class="dispatch-btn btn btn-primry" onclick="dispatchSingle(' + full.Sample_Detail_ID + ', ' + full.Accession_No + '); return false;">Dispatch</button>';
                            }
                            return '<button type="button" class="dispatch-btn" style="background:#6c757d;" disabled>Dispatched</button>';
                        }
                    }
                ],

                initComplete: function (settings, json) {
                    addActionBar();

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

                        $.ajax({
                            type: "POST",
                            url: "AccessionView.aspx/SaveUserColumnPreferences",
                            data: JSON.stringify({ preferences: JSON.stringify(currentVis) }),
                            contentType: "application/json; charset=utf-8",
                            success: function () { console.log("Column preferences saved"); },
                            error: function (error) { console.error("Failed to save preferences:", error); }
                        });
                    });
                },

                drawCallback: function () {
                    // Re-attach row selection styling
                    $('.select-row').off('change').on('change', function (e) {
                        e.stopPropagation();
                        if ($(this).is(':checked')) {
                            $(this).closest('tr').addClass('selected-row');
                        } else {
                            $(this).closest('tr').removeClass('selected-row');
                        }
                        updateSelectedCount();
                    });
                }
            });

            // Store table reference globally
            window.accessionTable = table;
        }

        function addActionBar() {
            if ($('.action-bar').length === 0) {
                var actionBar = '<div class="action-bar">' +
                    '<div><input type="checkbox" id="selectAll"> <label for="selectAll">Select All</label></div>' +
                    //'<div>Selected: <span id="selectedCount">0</span> items</div>' +
                    '<button type="button" id="dispatchSelectedBtn" class="dispatch-all-btn  btn btn-primry">Dispatch Selected</button>' +
                    '</div>';
                $('#example_wrapper').before(actionBar);

                $('#selectAll').off('change').on('change', function (e) {
                    var isChecked = $(this).is(':checked');
                    $('.select-row:not(:disabled)').prop('checked', isChecked).trigger('change');
                });

                $('#dispatchSelectedBtn').off('click').on('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    dispatchSelected();
                    return false;
                });
            }
        }

        function updateSelectedCount() {
            var count = $('.select-row:checked').length;
            $('#selectedCount').text(count);
            var totalSelectable = $('.select-row:not(:disabled)').length;
            $('#selectAll').prop('checked', count === totalSelectable && totalSelectable > 0);
        }

        function dispatchSingle(sampleDetailId, accessionNo) {
            // Prevent any default behavior
            if (event) {
                event.preventDefault();
                event.stopPropagation();
            }

            Swal.fire({
                title: 'Confirm Dispatch',
                text: 'Are you sure you want to dispatch accession #' + accessionNo + '?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Dispatch',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading
                    Swal.fire({
                        title: 'Processing...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    $.ajax({
                        type: "POST",
                        url: "AccessionView.aspx/DispatchAccession",
                        data: JSON.stringify({ sampleDetailIds: [sampleDetailId] }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d === "Success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Dispatched!',
                                    text: 'Accession #' + accessionNo + ' has been dispatched.',
                                    timer: 1500,
                                    showConfirmButton: false
                                });
                                // Reload the DataTable and keep current page
                                setTimeout(function () {
                                    if (window.accessionTable) {
                                        window.accessionTable.ajax.reload(null, false);
                                    } else {
                                        $('#example').DataTable().ajax.reload(null, false);
                                    }
                                }, 1500);
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: response.d
                                });
                            }
                        },
                        error: function (xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Failed to dispatch. Please try again.'
                            });
                        }
                    });
                }
            });
            return false;
        }

        function dispatchSelected() {
            var selectedIds = [];
            $('.select-row:checked').each(function () {
                selectedIds.push($(this).data('id'));
            });

            if (selectedIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please select at least one item to dispatch'
                });
                return;
            }

            Swal.fire({
                title: 'Confirm Bulk Dispatch',
                text: 'Are you sure you want to dispatch ' + selectedIds.length + ' selected item(s)?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Dispatch All',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#28a745',
                cancelButtonColor: '#6c757d'
            }).then((result) => {
                if (result.isConfirmed) {
                    // Show loading
                    Swal.fire({
                        title: 'Processing...',
                        text: 'Please wait',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });

                    $.ajax({
                        type: "POST",
                        url: "AccessionView.aspx/DispatchAccession",
                        data: JSON.stringify({ sampleDetailIds: selectedIds }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d === "Success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Dispatched!',
                                    text: selectedIds.length + ' item(s) have been dispatched.',
                                    timer: 1500,
                                    showConfirmButton: false
                                });
                                // Reload the DataTable and keep current page
                                setTimeout(function () {
                                    if (window.accessionTable) {
                                        window.accessionTable.ajax.reload(null, false);
                                    } else {
                                        $('#example').DataTable().ajax.reload(null, false);
                                    }
                                }, 1500);
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: response.d
                                });
                            }
                        },
                        error: function () {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Failed to dispatch selected items'
                            });
                        }
                    });
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
                        <th><input type="checkbox" id="selectAllHeader" style="display:none;"></th>
                        <th>Sample Detail ID</th>
                        <th>Accession No</th>
                        <th>Sample No</th>
                        <th>Collection Date</th>
                        <th>MR No</th>
                        <th>Patient Name</th>
                        <th>Test Name</th>
                        <th>Mobile</th>
                        <th>Outsource Lab</th>
                        <th>Dispatch Status</th>
                        <th>Dispatch Date</th>
                        <th>Dispatch By</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</asp:Content>