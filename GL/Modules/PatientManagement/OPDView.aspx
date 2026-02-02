 <%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPDView.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPDView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/Tibbit_theme/CustomJs/OPDView.js" type="text/javascript"></script>
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <style>
        .column-visibility-panel {
    background-color: #f8f9fa;
    padding: 15px;
    border-radius: 8px;
    margin-bottom: 15px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.column-visibility-panel label {
    font-weight: normal;
    margin-right: 20px;
    cursor: pointer;
}

.column-visibility-panel label:hover {
    color: #007bff;
}

.column-visibility-panel input[type="checkbox"] {
    margin-right: 5px;
}
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        var table = null;

        function editOpen(id) {
            Swal.fire({
                title: 'Are you sure?',
                text: `You are about to edit patient`,
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
                            window.open("OPD.aspx?OPDID=" + id, "_blank");
                        }
                    });
                }
            });
        }

        function cancelPatient(patid, patname) {
            debugger;
            var PatID = patid;
            var PatNo = patname;

            Swal.fire({
                title: 'Are you sure?',
                text: 'Are you sure want to Cancel:- ' + PatNo,
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, cancel it!',
                cancelButtonText: 'No, keep it',
                reverseButtons: true
            }).then((result) => {
                if (result.isConfirmed) {
                    PageMethods.CancelPatient(PatID, function (msg) {
                        if (msg == "Allowdlt") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Permission Denied',
                                text: 'You have no right to Cancel.'
                            });
                        }
                        else if (msg == "success") {
                            if (typeof row !== 'undefined' && row && typeof row.remove === 'function') {
                                row.remove();
                            }
                            window.location.href = "OPDView.aspx";
                        }
                        else {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Cancel Failed',
                                text: 'Unable to Cancel this patient, because this patient has uncanceled Reciept and Bills'
                            });
                        }
                    });
                }
            });
        }

        function toggleColumn(columnIndex) {
            if (table) {
                var column = table.column(columnIndex);
                var isVisible = column.visible();
                column.visible(!isVisible);

                // Save column visibility state to localStorage
                saveColumnVisibility();
            }
        }

        function saveColumnVisibility() {
            if (table) {
                var visibilityState = [];
                table.columns().every(function (index) {
                    visibilityState.push({
                        index: index,
                        visible: this.visible()
                    });
                });
                localStorage.setItem('opdTableColumnVisibility', JSON.stringify(visibilityState));
            }
        }

        function loadColumnVisibility() {
            var savedState = localStorage.getItem('opdTableColumnVisibility');
            if (savedState) {
                try {
                    var visibilityState = JSON.parse(savedState);
                    visibilityState.forEach(function (state) {
                        if (table && state.index < table.columns().count()) {
                            table.column(state.index).visible(state.visible);
                        }
                    });
                } catch (e) {
                    console.error('Error loading column visibility:', e);
                }
            }
        }

        function resetColumnVisibility() {
            if (table) {
                table.columns().every(function (index) {
                    // Skip the first column (Sr#) and last column (Actions) from being hidden by default
                    if (index === 0 || index === table.columns().count() - 1) {
                        this.visible(true);
                    } else {
                        this.visible(true);
                    }
                });
                localStorage.removeItem('opdTableColumnVisibility');
                Swal.fire({
                    icon: 'success',
                    title: 'Columns Reset',
                    text: 'All columns have been restored to default visibility.',
                    timer: 1500,
                    showConfirmButton: false
                });
            }
        }

        function LoadPage() {
            debugger;
            table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'OPD.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
                    {
                        extend: 'colvis',
                        text: 'Column Visibility',
                        className: 'btn-primary',
                        columns: ':not(:first-child):not(:last-child)' // Exclude Sr# and Actions
                    }
                ],
                "filter": true,
                "pageLength": 25, // Increased default page size for better performance
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]], // Added more options
                "deferRender": true, // Defer rendering for better performance
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "OPDView.aspx/ViewList",
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
                        "width": "4%",
                        "orderable": false,
                        "render": function (data, type, full, meta) {
                            return meta.settings._iDisplayStart + meta.row + 1;
                        }
                    },
                    { "data": "Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "Opd_No", "name": "Opd_No", "width": "5%", "orderable": false },
                    { "data": "Full_Name", "width": "13%", "orderable": false },
                    { "data": "Patient_Type", "width": "6%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
                    { "data": "NIC", "width": "8%", "orderable": false },
                    { "data": "Mobile1", "width": "8%", "orderable": false },
                    { "data": "Age", "name": "Age", "width": "8%" },
                    { "data": "Doctor_Id", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            var date = full.Created_Time;
                            return moment(date).format('DD-MMM-YYYY');
                        }, "width": "9%"
                    },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(' + full.Patient_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Patient_ID + '" onclick="cancelPatient(' + full.Patient_ID + ', \'' + full.Full_Name + '\')"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.Patient_ID + ')"><i class="fa fa-print"></i></a>';
                            return res + Del + print;
                        },
                        "width": "17%",
                        "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }

                    // Load saved column visibility
                    loadColumnVisibility();

                    // Add column visibility control buttons
                    addColumnVisibilityControls();
                },
                "drawCallback": function (settings) {
                    // Save column visibility after each draw
                    saveColumnVisibility();
                }
            });
        }

        function addColumnVisibilityControls() {
            // Create column visibility control panel
            var controlPanel = $('<div class="column-visibility-panel" style="margin-bottom: 10px; padding: 10px; background: #f8f9fa; border-radius: 5px;"></div>');

            var toggleButton = $('<button class="btn btn-sm btn-info" style="margin-right: 10px;" onclick="toggleAllColumns(true)"><i class="fa fa-eye"></i> Show All</button>');
            var hideButton = $('<button class="btn btn-sm btn-warning" style="margin-right: 10px;" onclick="toggleAllColumns(false)"><i class="fa fa-eye-slash"></i> Hide All</button>');
            var resetButton = $('<button class="btn btn-sm btn-danger" onclick="resetColumnVisibility()"><i class="fa fa-refresh"></i> Reset</button>');

            controlPanel.append(toggleButton).append(hideButton).append(resetButton);

            // Add individual column toggle buttons
            var columnToggles = $('<div style="margin-top: 10px;"></div>');
            table.columns().every(function (index) {
                var column = table.column(index);
                var title = $(column.header()).text().trim();

                // Skip Sr# and Actions columns from individual toggles
                if (index === 0 || index === table.columns().count() - 1 || title === '') return;

                var checkbox = $('<label class="checkbox-inline" style="margin-right: 15px; margin-bottom: 5px;"><input type="checkbox" ' + (column.visible() ? 'checked' : '') + ' onclick="toggleColumn(' + index + ')"> ' + title + '</label>');
                columnToggles.append(checkbox);
            });

            controlPanel.append(columnToggles);

            // Insert control panel before the table
            $('#tblResult').parent().prepend(controlPanel);
        }

        function toggleAllColumns(show) {
            table.columns().every(function (index) {
                // Skip Sr# and Actions columns
                if (index === 0 || index === table.columns().count() - 1) {
                    this.visible(true);
                } else {
                    this.visible(show);
                }
            });
            saveColumnVisibility();
            Swal.fire({
                icon: 'success',
                title: 'Columns Updated',
                text: show ? 'All columns are now visible.' : 'All columns (except Sr# and Actions) are now hidden.',
                timer: 1500,
                showConfirmButton: false
            });
        }

        function Print(Patient_ID) {
            // Implement your print functionality here
            window.open("PrintOPD.aspx?Patient_ID=" + Patient_ID, "_blank");
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   
    <div id="POdetails" style="margin-top: 15px;">
            <div class="row">
                <div class="table-container col-lg-12 col-md-12 col-sm-10">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                  <thead id="ihead">
                    <tr>
                        <th style="width:2% !important;">Sr#</th>                 <!-- 1st: Sr# -->
                        <th style="display: none;">Patient ID</th>      <!-- 2nd: Hidden -->
                        <th style="width: 8%;">MR No.</th>
                        <th style="width: 5%;">OPD</th>
                        <th style="width: 13%;">Name</th>
                        <th style="width: 10%;">Category</th>
                        <th style="width: 10%;">Department</th>
                        <th style="width: 10%;">CNIC</th>
                        <th style="width: 10%;">Mobile</th>
                        <th style="width: 5%;">Age</th>
                        <th style="width: 10%;">Doctor</th>
                        <th style="width: 9%;">Date</th>
                        <th style="width: 20% !important;">Actions</th>
                    </tr>
                </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>
            </div>
    </div>
</asp:Content>
