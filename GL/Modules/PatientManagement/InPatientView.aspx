<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientView.aspx.cs" Inherits="PMS.InPatientView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();
            $(document).on('change', '#select-all', function () {
                var checked = $(this).is(':checked');
                $('.select-row').prop('checked', checked);
            });

            $('#dischargeModal').on('hidden.bs.modal', function () {
                $('#ddlDischargeDoctor').val('');
                pendingDischargeIds = [];
            });
        });

        function PrintInPatient(IN_Patient_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=InpatientDetail&Title=In Patient Detail Print&InPatient_ID=' + IN_Patient_ID;
            window.open(url, '_blank');

        }
        function PrintInPatientDeathCertificate(IN_Patient_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=Certificate_In_Patient&Title=In Patient Detail Print&In_Patient_ID=' + IN_Patient_ID;
            window.open(url, '_blank');

        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "InPatientView.aspx/GetUserColumnPreferences",
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
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'InPatientsCase.aspx';
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
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "InPatientView.aspx/ViewList",
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
                        "orderable": false,
                        "className": "dt-checkbox",
                        "render": function (data, type, full) {
                            var id = full.IN_Patient_ID;
                            return '<input type="checkbox" class="select-row" value="' + id + '" />';
                        },
                        "width": "3%"
                    },
                    { "data": "IN_Patient_ID", "name": "IN_Patient_Id", "visible": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "MRNO", "width": "10%", "orderable": true },
                    { "data": "Full_Name", "width": "15%", "orderable": true },
                    { "data": "Father_Name", "width": "10%", "orderable": false },
                    { "data": "Department", "width": "10%", "orderable": false },
             
                    {
                        "data": "Admission_Date", "name": "Admission_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Admission_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="editOpen(' + full.IN_Patient_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a href="#" class="delListBtn" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintInPatient(' + full.IN_Patient_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var printBtn = '';
                            if (full.Death_Date)
                            {
                                var printBtn = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintInPatientDeathCertificate(' + full.IN_Patient_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            }
                            var result;
                            result = res + Del + print + printBtn;
                            return result;

                        }, "width": "10%", "orderable": false
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

        function editOpen(id) {

            window.open("InPatientsCase.aspx?ID=" + id + "");

        }


        function deleteConfirm(anchorTag) {
            debugger;
            var table = $('#tblResult').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var InPatientID = rowData.IN_Patient_ID;

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(InPatientID, function (msg) {
                    if (msg == "Delete") {
                        table.row(row).remove().draw();
                    }
                    else {
                        alert("This Patient is in Billing Process");
                    }
                });
            }
        }

        let pendingDischargeIds = []; 

        function dischargeSelected() {
            var table = $('#tblResult').DataTable();
            var selectedRows = table.rows(function (idx, data, node) {
                return $(node).find('.select-row').is(':checked');
            });
            var selectedData = selectedRows.data().toArray();
            pendingDischargeIds = selectedData.map(function (item) {
                if (item && item.IN_Patient_ID) {
                    return parseInt(item.IN_Patient_ID);
                }
                return null;
            }).filter(function (id) {
                return id !== null && !isNaN(id);
            });

            if (pendingDischargeIds.length === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Selection',
                    text: 'Please select at least one patient to discharge.',
                    confirmButtonText: 'OK'
                });
                return;
            }

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
                url: "InPatientView.aspx/GetDoctor",
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
            debugger;
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
                        url: "InPatientView.aspx/DischargePatientsWithDoctor",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        data: JSON.stringify({
                            patientIds: pendingDischargeIds,
                            dischargeDoctorId: parseInt(doctorId)
                        }),
                        success: function (response) {
                            debugger;
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

        

       
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="POdetails" style="margin-top: 15px;">
        <div>

            <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                <thead id="ihead">
                    <tr>
                        <th><input type="checkbox" id="select-all" /></th>
                        <th>IN_Patient_ID</th>
                        <th>MR No.</th>
                        <th>Patient Name</th>
                        <th>Father/Husband Name</th>
                        <th>Dept.</th>   
                       <th>Admission Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>

            <!-- Doctor Selection Modal for Discharge -->
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
                    <select id="ddlDischargeDoctor" class="form-control" required>
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
    </div>
</asp:Content>
