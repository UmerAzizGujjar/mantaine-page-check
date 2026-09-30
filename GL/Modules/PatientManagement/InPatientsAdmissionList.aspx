<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientsAdmissionList.aspx.cs" Inherits="PMS.InPatientsAdmissionList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server"> 
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadLocationFilter();
            LoadPage();
            $(document).on('change', '#select-all', function () {
                var checked = $(this).is(':checked');
                $('.select-row').prop('checked', checked);
            });
        });

        function LoadLocationFilter() {
            $.ajax({
                type: "POST",
                url: "InPatientsAdmissionList.aspx/GetWardsAndRooms",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        var items = JSON.parse(response.d);
                        var $ddl = $('#ddlLocationFilter');
                        $ddl.empty().append('<option value="all">All Wards/Rooms</option>');
                        if (items && items.length > 0) {
                            $.each(items, function (i, item) {
                                $ddl.append(new Option(item.Name, item.Id));
                            });
                        }
                        if ($.fn.select2) {
                            $ddl.select2({
                                width: '100%',
                                placeholder: 'Filter by Ward/Room',
                                allowClear: true
                            });
                        }
                    } catch (e) {
                        console.error("Error parsing wards/rooms: ", e);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Failed to load wards/rooms: ", error);
                }
            });
        }


        function PrintSlip(In_Patient_ID) {
            var url = '../../ReportViewer.aspx?ReportName=AdminissionSlip&ReportTitle=Admission Slip Report&Inpatient_ID=' + In_Patient_ID;
            window.open(url, '_blank');
            
        }
        function PrintBirthCertificate(In_Patient_ID) {
            var url = '../../ReportViewer.aspx?ReportName=Birth_Certificate&ReportTitle=Admission Slip Report&Inpatient_ID=' + In_Patient_ID;
            window.open(url, '_blank');
            
        }

        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "InPatientsAdmissionList.aspx/GetUserColumnPreferences",
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
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5 btn-primary',
                        action: function () {
                            window.location = 'InPatientsAdmission.aspx';
                        }
                    },
                    {
                        text: 'Discharge',
                        className: 'dt-button buttons-copy buttons-html5 btn-warning',
                        action: function () {
                            dischargeSelected();
                        }
                    },
                    'copy', 'excel', 'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                "columnDefs": savedVisibility ? [] : undefined, 
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "InPatientsAdmissionList.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            locationFilter: $('#ddlLocationFilter').val() || 'all'
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
                        "orderable": false,
                        "className": "dt-checkbox",
                        "render": function (data, type, full) {
                            return '<input type="checkbox" class="select-row" value="' + full.In_Patient_ID + '" />';
                        },
                        "width": "3%"
                    },
                    { "data": "In_Patient_ID", "visible": false, "width": "0%" },
                    {
                        "data": "Admission_Date", "name": "Admission_Date",
                        "render": function (data, type, full) {
                            return moment(full.Admission_Date).format('DD-MMM-YYYY');
                        }, "width": "7%", "orderable": true
                    },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "Father_Name", "width": "10%", "orderable": false },
                    { "data": "Patient_Type", "name": "Patient_Type", "width": "10%", "orderable": true },
                    { "data": "Department", "name": "Department", "width": "10%", "orderable": true },
                    //{
                    //    "data": "Discharge_ON",
                    //    "render": function (data, type, full) {
                    //        return data ? moment(data).format('DD-MMM-YYYY') : '';
                    //    },
                    //    "width": "10%", "orderable": false
                    //},
                    { "data": "Created_by", "name": "Created_by", "width": "10%", "orderable": true },
                    {
                        "data": null,
                        "name": "Location",
                        "width": "10%",
                        "orderable": true,
                        "render": function (data, type, row) {
                            if (row.Ward_Name) {
                                return row.Ward_Name + " - Bed: " + (row.Bed_No || "N/A");
                            } else if (row.Room_Name) {
                                return "Room " + row.Room_Name + " - Bed: " + (row.Bed_No || "N/A");
                            } else {
                                return "Not Assigned";
                            }
                        }
                    },
                    { "data": "AdmitDays", "name": "AdmitDays", "width": "10%", "orderable": true },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(' + full.In_Patient_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px;color:white;padding: 5px 8px;" onclick="deleteConfirm(this)"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color:white;padding: 5px 8px;" href="#" onclick="PrintSlip(' + full.In_Patient_ID + ')"><i class="fa fa-print"></i></a>';
                            if (full.Birth_Date) {
                                printBtn = '<a class="printListBtn" href="#" style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px;" onclick="PrintBirthCertificate(' + full.In_Patient_ID + ')"><i class="fa fa-print"></i></a>';
                            }
                            return res + Del + print + printBtn;
                        },
                        "width": "13%", "orderable": false
                    }
                ],
                "createdRow": function (row, data, dataIndex) {
                    if (data.AdmitDays >= 10 && (data.Discharge_ON == null || data.Discharge_ON === "")) {
                        $(row).css({
                            "background-color": "#f8d7da",
                            "color": "#721c24",            
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

            $('#ddlLocationFilter').on('change', function () {
                $('#tblResult').DataTable().ajax.reload();
            });
        }

        function editOpen(id) {
            window.open("InPatientsAdmission.aspx?ID=" + id, "_blank");
        }

       
        function deleteConfirm(anchorTag) {
            var table = $('#tblResult').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var In_PatientID = rowData.In_Patient_ID;

            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(In_PatientID, function (msg) {
                    if (msg === "Delete") {
                        alert("Record deleted successfully!");
                        table.row(row).remove().draw();
                    } else if (msg === "DischargePending") {
                        alert("Patient must be discharged before deletion.");
                    } else if (msg === "BillingPending") {
                        alert("This Patient is in the billing process.");
                    } else {
                        alert("An unexpected error occurred: " + msg);
                    }
                });
            }
        }

        let pendingDischargeIds = [];

        function dischargeSelected() {
            var selectedIds = $('.select-row:checked').map(function () {
                return parseInt($(this).val());
            }).get();

            if (selectedIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Selection',
                    text: 'Please select at least one patient to discharge.',
                    confirmButtonText: 'OK'
                });
                return;
            }

            pendingDischargeIds = selectedIds;
            $('#selectedPatientsCount').text(pendingDischargeIds.length);
            loadDoctorsDropdown();
            $('#dischargeModal').modal('show');
        }

        function loadDoctorsDropdown() {
            const $ddl = $('#ddlDischargeDoctor');
            if ($ddl.data('select2')) {
                $ddl.select2('destroy');
            }
            $ddl.select2({
                placeholder: 'Search and select a doctor...',
                allowClear: true,
                width: '100%',
                dropdownParent: $('#dischargeModal'),
                language: {
                    noResults: function () {
                        return "No doctor found";
                    },
                    searching: function () {
                        return "Searching...";
                    }
                }
            });
            $ddl.prop('disabled', true);
            $ddl.empty().append(new Option('Loading doctors...', '', true, true));

            $.ajax({
                type: "POST",
                url: "InPatientsAdmissionList.aspx/GetDoctor",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    $ddl.empty().append(new Option('Select Doctor', '', true, true));
                    let doctors = (typeof response.d === 'string') ? JSON.parse(response.d) : response.d;

                    $.each(doctors, function (i, doc) {
                        let option = new Option(doc.Emp_Name, doc.Emp_ID, false, false);
                        $ddl.append(option);
                    });
                    $ddl.trigger('change');
                    $ddl.prop('disabled', false);
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    $ddl.empty().append(new Option('Error loading doctors', '', true, true));
                    $ddl.trigger('change');
                    Swal.fire('Error', 'Could not load doctors list.', 'error');
                }
            });
        }

        $(document).on('click', '#btnConfirmDischarge', function () {
            const doctorId = $('#ddlDischargeDoctor').val();

            if (!doctorId) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Doctor Required',
                    text: 'Please select a doctor.',
                    confirmButtonText: 'OK'
                });
                return;
            }

            Swal.fire({
                title: 'Confirm Discharge',
                text: `Discharge ${pendingDischargeIds.length} patient(s) by Dr. ${$('#ddlDischargeDoctor option:selected').text()}?`,
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Discharge',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Processing...',
                        allowOutsideClick: false,
                        didOpen: () => Swal.showLoading()
                    });

                    $.ajax({
                        type: "POST",
                        url: "InPatientsAdmissionList.aspx/DischargePatientsWithDoctor",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        data: JSON.stringify({
                            patientIds: pendingDischargeIds,
                            dischargeDoctorId: parseInt(doctorId)
                        }),
                        success: function (response) {
                            Swal.close();
                            $('#dischargeModal').modal('hide');

                            if (response.d && response.d.success) {
                                Swal.fire('Success!', response.d.message, 'success').then(() => {
                                    if ($.fn.DataTable.isDataTable('#tblResult')) {
                                        $('#tblResult').DataTable().ajax.reload(null, false);
                                    } else {
                                        location.reload();
                                    }
                                });
                            } else if (response.d && !response.d.success) {
                                Swal.fire('Failed', response.d.message, 'error');
                            }
                        },
                        error: function (xhr, status, error) {
                            Swal.close();
                            console.error("AJAX Error:", xhr.responseText);
                            Swal.fire('Error', 'An unexpected error occurred: ' + error, 'error');
                        }
                    });
                }
            });
        });


        $(document).on('hidden.bs.modal', '#dischargeModal', function () {
            $('#ddlDischargeDoctor').val('');
            pendingDischargeIds = [];
        });


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="POdetails" style="margin-top: 15px;">
        <div>
            <div class="row" style="margin-bottom: 10px;">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddlLocationFilter" style="font-weight: 600; font-size: 13px;">Filter by Ward/Room:</label>
                    <select id="ddlLocationFilter" style="width: 100%;">
                        <option value="all">All Wards/Rooms</option>
                    </select>
                </div>
            </div>
       <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow:scroll; height:auto;">
            <thead id="ihead">
                <tr>
                    <th><input type="checkbox" id="select-all" /></th>
                    <th>In Patient ID</th>
                    <th>Admission Date</th>
                    <th>MR No.</th>
                    <th>Patient Name</th> 
                    <th>Father/Husband Name</th> 
                    <th>Patient Category</th> 
                    <th>Dept.</th>                      
                    <th>Admitted By</th>                             
                    <th>Ward/Room</th>                          
                    <th>Days Occupied</th>                             
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
 </div>

        
<div class="modal fade" id="dischargeModal" tabindex="-1" role="dialog" aria-labelledby="dischargeModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="dischargeModalLabel">Confirm Discharge</h5>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    <span aria-hidden="true">&times;</span>
                </button>
            </div>
            <div class="modal-body">
                <p>Selected Patients: <strong id="selectedPatientsCount">0</strong></p>
                <div class="form-group">
                    <label for="ddlDischargeDoctor">Discharging Doctor:</label>
                    <select id="ddlDischargeDoctor" class="form-control" required="required">
                        <option value="">-- Select Doctor --</option>
                    </select>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancel</button>
                <button type="button" class="btn btn-primary" id="btnConfirmDischarge">Confirm Discharge</button>
            </div>
        </div>
    </div>
</div>
         </div>
</asp:Content>

