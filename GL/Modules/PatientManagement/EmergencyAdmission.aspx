<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyAdmission.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyAdmission" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .card {
            border: 1px solid #C4C4C4;
            background-color: #f9f9f9;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            width: 100%;
            overflow: hidden;
        }

        .top {
            margin-top: 4px;
        }

        .formrgn {
            margin-top: 10px;
        }



    </style>
    <script type="text/javascript">
        var currentEmergencyID = 0;
        var currentPatientID = 0;
        var currentEmergencyPatientID = 0;

        $(document).ready(function () {
           
            // Initialize date and time fields with current date/time
            var now = new Date();
            var dateStr = now.toISOString().split('T')[0];
            var timeStr = now.toLocaleTimeString('en-US', { hour12: false });

            $('#<%= txtAdmission_Date.ClientID %>').val(dateStr);
            $('#<%= txtTreatmentTime.ClientID %>').val(timeStr);

            // Load all dropdowns
            populateAllDropdowns();

            // Check if Emergency_ID is in URL for edit mode
            var urlParams = new URLSearchParams(window.location.search);
            var emergencyPatientID = urlParams.get('Emergency_ID');
            if (emergencyPatientID) {
                loadAdmissionForEdit(parseInt(emergencyPatientID));
            }
            else {
                openEmergencyWaitingListModal()
            }

            var searchTimer;
            $('#SearchEmergencyWaitingList').on('keyup', function () {
                clearTimeout(searchTimer);
                var value = $(this).val();
                searchTimer = setTimeout(function () {
                    fillEmergencyWaitingList(value);
                }, 300); 
            });
        });

        function populateAllDropdowns() {
            // Load Triage Areas
            PageMethods.GetTriageAreas(function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    console.error('Error loading triage areas:', data.error);
                    return;
                }
                var ddl = $('#<%= ddlPatientCondition.ClientID %>');
                ddl.empty();
                ddl.append('<option value="0">Please Select</option>');
                $.each(data, function (i, item) {
                    ddl.append($('<option></option>').val(item.DataValue_Name).text(item.DataValue_Description));
                });
            }, function (error) {
                console.error('Error:', error);
            });

            // Load Departments
            PageMethods.GetDepartments(function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    console.error('Error loading departments:', data.error);
                    return;
                }
                var ddl = $('#<%= ddlDepartment.ClientID %>');
                ddl.empty();
                ddl.append('<option value="0">Please Select</option>');
                $.each(data, function (i, item) {
                    ddl.append($('<option></option>').val(item.DataValue_Name).text(item.DataValue_Description));
                });
                ddl.prop('disabled', false);
            }, function (error) {
                console.error('Error:', error);
            });

            // Load Admit To options
            PageMethods.GetAdmitToOptions(function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    console.error('Error loading admit to options:', data.error);
                    return;
                }
                var ddl = $('#<%= ddlIssuance_Of.ClientID %>');
                ddl.empty();
                ddl.append('<option value="0">Please Select</option>');
                $.each(data, function (i, item) {
                    ddl.append($('<option></option>').val(item.DataValue_Name).text(item.DataValue_Description));
                });
                ddl.prop('disabled', false);
            }, function (error) {
                console.error('Error:', error);
            });

            // Load Wards
            PageMethods.GetWards(function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    console.error('Error loading wards:', data.error);
                    return;
                }
                var ddl = $('#<%= ddlWard_No.ClientID %>');
                ddl.empty();
                ddl.append('<option value="0">Please Select</option>');
                $.each(data, function (i, item) {
                    ddl.append($('<option></option>').val(item.Ward_ID).text(item.Ward_Type));
                });
            }, function (error) {
                console.error('Error:', error);
            });

            populateRoomTypes();
            // Setup department change event to load doctors
            $('#<%= ddlDepartment.ClientID %>').on('change', function () {
                var deptID = $(this).val();
                if (deptID && deptID != '0') {
                    PageMethods.GetDoctors(deptID, function (response) {
                        var data = JSON.parse(response);
                        if (data.error) {
                            console.error('Error loading doctors:', data.error);
                            return;
                        }
                        var ddl = $('#<%= ddlDoctor.ClientID %>');
                        ddl.empty();
                        ddl.append('<option value="0">Please Select</option>');
                        $.each(data, function (i, item) {
                            ddl.append($('<option></option>').val(item.Emp_ID).text(item.Emp_Name));
                        });
                    }, function (error) {
                        console.error('Error:', error);
                    });
                } else {
                    $('#<%= ddlDoctor.ClientID %>').empty().append('<option value="0">Please Select</option>');
                }
            });


        }

        function openEmergencyWaitingListModal() {
            $('#EmergencyWaitingListModal').modal('show');
            fillEmergencyWaitingList();
        }

        function fillEmergencyWaitingList(searchText) {
            var searchValue = searchText || '';

            PageMethods.GetEmergencyWaitingList(searchValue, function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    Swal.fire('Error', 'Error loading waiting list: ' + data.error, 'error');
                    return;
                }

                var tbody = $('#tblEmergencyWaitingList tbody');
                tbody.empty();

                if (data.length === 0) {
                    tbody.append('<tr><td colspan="7" class="text-center">No records found</td></tr>');
                    return;
                }

                $.each(data, function (i, item) {
                    var createdTime = new Date(parseInt(item.Created_Time.substr(6)));
                    var formattedTime = createdTime.toLocaleString();

                    var statusClass = '';
                    if (item.Status === 'Admitted') statusClass = 'text-success';
                    else if (item.Status === 'NotAdmitted') statusClass = 'text-danger';
                    else statusClass = 'text-warning';

                    var selectDropdown = '';
                    if (item.Status === 'Admitted') {
                        selectDropdown = '<select class="form-control form-control-sm status-select" data-emergency-id="' + item.Emergency_ID + '" data-patient-id="' + item.Patient_ID + '" disabled>' +
                            '<option value="Pending">Pending</option>' +
                            '<option value="Admitted" selected>Admitted</option>' +
                            '<option value="NotAdmitted">Not Admitted</option>' +
                            '</select>';
                    } else {
                        selectDropdown = '<select class="form-control form-control-sm status-select" data-emergency-id="' + item.Emergency_ID + '" data-patient-id="' + item.Patient_ID + '" onchange="handleStatusChange(this)">' +
                            '<option value="Pending" ' + (item.Status === 'Pending' ? 'selected' : '') + '>Pending</option>' +
                            '<option value="Admitted">Admitted</option>' +
                            '<option value="NotAdmitted" ' + (item.Status === 'NotAdmitted' ? 'selected' : '') + '>Not Admitted</option>' +
                            '</select>';
                    }

                    var row = '<tr>' +
                        '<td>' + item.Emergency_No + '</td>' +
                        '<td>' + item.MR_No + '</td>' +
                        '<td>' + item.Patient_Name + '</td>' +
                        '<td>' + item.Age + '</td>' +
                        '<td>' + formattedTime + '</td>' +
                        '<td><span class="' + statusClass + '">' + item.Status + '</span></td>' +
                        '<td>' + selectDropdown + '</td>' +
                        '</tr>';

                    tbody.append(row);
                });
            }, function (error) {
                Swal.fire('Error', 'Error loading waiting list', 'error');
                console.error(error);
            });
        }


        function handleStatusChange(selectElement) {
            debugger;


            var status = $(selectElement).val();
            var emergencyID = $(selectElement).data('emergency-id');
            var patientID = $(selectElement).data('patient-id');

            currentEmergencyID = emergencyID;
            currentPatientID = patientID;
            $('#hiddenPatientID').val(patientID);

            // Always load patient info
            PageMethods.GetPatientInfo(emergencyID, function (response) {

                var patientData = JSON.parse(response);

                if (patientData.error) {
                    Swal.fire('Error', 'Error loading patient info: ' + patientData.error, 'error');
                    return;
                }

                // Populate patient card
                $('#<%= vlblPatients_Name.ClientID %>').text(patientData.Patient_Name || '');
                     $('#<%= Label200.ClientID %>').text(patientData.MR_No || '');
                     $('#<%= Label1.ClientID %>').text(patientData.Emergency_No || '');
                     $('#<%= vLbl_Age.ClientID %>').text(patientData.Age || '');
                     $('#<%= vLbl_Contact.ClientID %>').text(patientData.Contact || '');

                     // Status logic
                     if (status === 'Admitted') {

                         $('#EmergencyWaitingListModal').modal('hide');
                         $("#btnSave").prop("disabled", false);

                         Swal.fire('Success', 'Patient selected for admission', 'success');

                     } else if (status === 'NotAdmitted') {
                         $('#EmergencyWaitingListModal').modal('hide');
                         $("#btnSave").attr("disabled", true);

                         PageMethods.UpdateEmergencyStatus(emergencyID, 'NotAdmitted', function (response) {

                             if (response.indexOf('Success') >= 0) {
                                 Swal.fire('Info', 'Patient info loaded but cannot save because patient is Not Admitted', 'info');
                             } else {
                                 Swal.fire('Error', response, 'error');
                             }

                         }, function (error) {
                             Swal.fire('Error', 'Error updating status', 'error');
                             console.error(error);
                         });
                     }

                 }, function (error) {
                     Swal.fire('Error', 'Error loading patient info', 'error');
                     console.error(error);
                 });
        }

<%--        function handleStatusChange(selectElement) {
            var status = $(selectElement).val();
            var emergencyID = $(selectElement).data('emergency-id');
            var patientID = $(selectElement).data('patient-id');

            if (status === 'Admitted') {
                // Close modal
                $('#EmergencyWaitingListModal').modal('hide');

                // Load patient info and populate patient card
                currentEmergencyID = emergencyID;
                currentPatientID = patientID;
                $('#hiddenPatientID').val(patientID);

                PageMethods.GetPatientInfo(emergencyID, function (response) {
                    var patientData = JSON.parse(response);
                    if (patientData.error) {
                        Swal.fire('Error', 'Error loading patient info: ' + patientData.error, 'error');
                        return;
                    }

                    // Populate patient card
                    $('#<%= vlblPatients_Name.ClientID %>').text(patientData.Patient_Name || '');
                    $('#<%= Label200.ClientID %>').text(patientData.MR_No || '');
                    $('#<%= Label1.ClientID %>').text(patientData.Emergency_No || '');
                    $('#<%= vLbl_Age.ClientID %>').text(patientData.Age || '');
                    $('#<%= vLbl_Contact.ClientID %>').text(patientData.Contact || '');

                    Swal.fire('Success', 'Patient selected for admission', 'success');
                }, function (error) {
                    Swal.fire('Error', 'Error loading patient info', 'error');
                    console.error(error);
                });

            } else if (status === 'NotAdmitted') {
                // Update status in Emergency table only
                PageMethods.UpdateEmergencyStatus(emergencyID, 'NotAdmitted', function (response) {
                    if (response.indexOf('Success') >= 0) {
                        Swal.fire('Success', 'Status updated to Not Admitted', 'success');
                        fillEmergencyWaitingList();
                    } else {
                        Swal.fire('Error', response, 'error');
                    }
                }, function (error) {
                    Swal.fire('Error', 'Error updating status', 'error');
                    console.error(error);
                });
            }
        }--%>



<%--        function handleStatusChange(selectElement) {
            var status = $(selectElement).val();
            var emergencyID = $(selectElement).data('emergency-id');
            var patientID = $(selectElement).data('patient-id');



            PageMethods.UpdateEmergencyStatus(emergencyID, status, function (response) {
                if (response.indexOf('Success') >= 0) {
                    Swal.fire('Success', 'Status updated to Not Admitted', 'success');
                    PageMethods.GetPatientInfo(emergencyID, function (response) {
                        var patientData = JSON.parse(response);
                        if (patientData.error) {
                            Swal.fire('Error', 'Error loading patient info: ' + patientData.error, 'error');
                            return;
                        }

                        // Populate patient card
                         $('#<%= vlblPatients_Name.ClientID %>').text(patientData.Patient_Name || '');
                         $('#<%= Label200.ClientID %>').text(patientData.MR_No || '');
                         $('#<%= Label1.ClientID %>').text(patientData.Emergency_No || '');
                         $('#<%= vLbl_Age.ClientID %>').text(patientData.Age || '');
                         $('#<%= vLbl_Contact.ClientID %>').text(patientData.Contact || '');

                       // Swal.fire('Success', 'Selected Patient Data Loaded  ', 'success');

                        if (status === 'Admitted') {
                            
                            $('#EmergencyWaitingListModal').modal('hide');
                            Swal.fire('Success', 'Selected Patient Data Loaded  ', 'success');
                            // Load patient info and populate patient card
                            currentEmergencyID = emergencyID;
                            currentPatientID = patientID;
                            $('#hiddenPatientID').val(patientID);



                        } else if (status === 'NotAdmitted') {
                            // Update status in Emergency table only
                            Swal.fire('Success', 'Selected Patient Data Loaded But You can t Save As The Patient Not Admit ', 'success');
                            $("#btnSave").attr("disabled", true);
                        }

                     }, function (error) {
                         Swal.fire('Error', 'Error loading patient info', 'error');
                         console.error(error);
                     });
                } else {
                    Swal.fire('Error', response, 'error');
                }
            }, function (error) {
                Swal.fire('Error', 'Error updating status', 'error');
                console.error(error);
            });
        }--%>

        function SaveAdmission() {
            $('#btnSave').attr('disabled', true);
            var doctor = $('#ctl00_MainContent_ddlDoctor').val();
            if (currentEmergencyID === 0) {
                $('#btnSave').attr('disabled', false);
                Swal.fire('Warning', 'Please select a patient from the waiting list', 'warning');
                return;
            }
            if (doctor === "0" || doctor === null) {
                $('#btnSave').attr('disabled', false);
                Swal.fire('Warning', 'Please select a Doctor', 'warning');
                return;
            }

            // ✅ Validate Ward & Bed OR Room
            var admitTo = $('#<%= ddlIssuance_Of.ClientID %>').val();
            var wardNo = $('#<%= ddlWard_No.ClientID %>').val();
            var bedNo = $('#<%= txtBed_No.ClientID %>').val();
            var roomType = $('#<%= ddlRoom_Type.ClientID %>').val();
            var roomNo = $('#<%= ddlRoom_No.ClientID %>').val();

            if (admitTo === '001' && (wardNo === '0' || wardNo === '')) {
                $('#btnSave').attr('disabled', false);
                Swal.fire('Warning', 'Please select Ward', 'warning');
                return;
            }
            if (admitTo === '002' && (roomType === '0' || roomType === '' || roomNo === '0' || roomNo === '')) {
                $('#btnSave').attr('disabled', false);
                Swal.fire('Warning', 'Please select Room Type and Room No', 'warning');
                return;
            }

            var admissionData = {
                Emergency_Patient_ID: currentEmergencyPatientID,
                Emergency_ID: currentEmergencyID,
                Patient_ID: currentPatientID,
                btnAction: $('#btnSave').val(),
                ddlPatientCondition: $('#<%= ddlPatientCondition.ClientID %>').val(),
        txtTreatmentTime: $('#<%= txtTreatmentTime.ClientID %>').val(),
        txtAdmission_Date: $('#<%= txtAdmission_Date.ClientID %>').val(),
        txtadmissionfee: $('#<%= txtadmissionfee.ClientID %>').val(),
        ddlDepartment: $('#<%= ddlDepartment.ClientID %>').val(),
        ddlDoctor: $('#<%= ddlDoctor.ClientID %>').val(),
        ddlIssuance_Of: $('#<%= ddlIssuance_Of.ClientID %>').val(),
        ddlWard_No: wardNo,
        txtBed_No: bedNo,
        // NEW: Room fields
        ddlRoom_Type: roomType,
        ddlRoom_No: roomNo,
                txtRoomBed_No: $('#<%= txtRoomBed_No.ClientID %>').val()
            };

            $.ajax({
                type: "POST",
                url: "EmergencyAdmission.aspx/SaveAdmission",
                data: JSON.stringify({ data: admissionData }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    if (result.indexOf('Error') >= 0) {
                        $('#btnSave').attr('disabled', false);
                        Swal.fire('Error', result, 'error');
                    } else {
                        var actionText = admissionData.btnAction === 'Save' ? 'saved' : 'updated';
                        Swal.fire('Success', 'Admission ' + actionText + ' successfully', 'success').then(function () {
                            window.location.href = 'EmergencyAdmission.aspx';
                        });
                    }
                },
                error: function (xhr, status, error) {
                    $('#btnSave').attr('disabled', false);
                    Swal.fire('Error', 'Error saving admission: ' + error, 'error');
                }
            });
        }


        function loadAdmissionForEdit(emergencyPatientID) {
            currentEmergencyPatientID = emergencyPatientID;
            $('#btnSave').val('Update');
            PageMethods.GetAdmissionData(emergencyPatientID, function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    Swal.fire('Error', 'Error loading admission data: ' + data.error, 'error');
                    return;
                }

                // Populate patient card
                currentEmergencyID = data.Emergency_ID;
                currentPatientID = data.Patient_ID;
                $('#hiddenPatientID').val(data.Patient_ID);
                $('#<%= vlblPatients_Name.ClientID %>').text(data.Patient_Name || '');
        $('#<%= Label200.ClientID %>').text(data.MR_No || '');
        $('#<%= Label1.ClientID %>').text(data.Emergency_No || '');
        $('#<%= vLbl_Age.ClientID %>').text(data.Age || '');
        $('#<%= vLbl_Contact.ClientID %>').text(data.Contact || '');

        // Populate form fields
        if (data.ddlPatientCondition) {
            setTimeout(function () {
                $('#<%= ddlPatientCondition.ClientID %>').val(data.ddlPatientCondition);
            }, 500);
        }
        if (data.txtTreatmentTime) {
            var treatmentTime = new Date(parseInt(data.txtTreatmentTime.substr(6)));
            $('#<%= txtTreatmentTime.ClientID %>').val(treatmentTime.toLocaleTimeString('en-US', { hour12: false }));
        }
        if (data.txtAdmission_Date) {
            var admissionDate = new Date(parseInt(data.txtAdmission_Date.substr(6)));
            $('#<%= txtAdmission_Date.ClientID %>').val(admissionDate.toISOString().split('T')[0]);
        }
        if (data.txtadmissionfee) {
            $('#<%= txtadmissionfee.ClientID %>').val(data.txtadmissionfee);
        }
        setTimeout(function () {
            if (data.ddlDepartment) {
                $('#<%= ddlDepartment.ClientID %>').val(data.ddlDepartment).trigger('change');
                setTimeout(function () {
                    if (data.ddlDoctor) {
                        $('#<%= ddlDoctor.ClientID %>').val(data.ddlDoctor);
                    }
                }, 500);
            }
            if (data.ddlIssuance_Of) {
                $('#<%= ddlIssuance_Of.ClientID %>').val(data.ddlIssuance_Of);
                chkIssuance_Of_Select(); // Trigger visibility logic
            }
            if (data.ddlWard_No) {
                $('#<%= ddlWard_No.ClientID %>').val(data.ddlWard_No);
                FillWardBeds();
            }
            if (data.txtBed_No) {
                $('#<%= txtBed_No.ClientID %>').val(data.txtBed_No);
            }
            // NEW: Load Room data
            if (data.ddlRoom_Type) {
                $('#<%= ddlRoom_Type.ClientID %>').val(data.ddlRoom_Type);
            }
            if (data.ddlRoom_No) {
                $('#<%= ddlRoom_No.ClientID %>').val(data.ddlRoom_No);
                FillRooms();
            }
            if (data.txtRoomBed_No) {
                $('#<%= txtRoomBed_No.ClientID %>').val(data.txtRoomBed_No);
            }
        }, 1000);
    }, function (error) {
        Swal.fire('Error', 'Error loading admission data', 'error');
        console.error(error);
    });
        }
        function SelectBed(WardID, BedNo) {
            $('#ctl00_MainContent_txtBed_No').val("");
            $('#ctl00_MainContent_txtBed_No').val(BedNo);
        }

        function SelectBedRefer(WardID, BedNo) {
            $('#ctl00_MainContent_txtBedno').val("");
            $('#ctl00_MainContent_txtBedno').val(BedNo);
        }

        function FillWardBeds() {
            var wardID = $('#<%= ddlWard_No.ClientID %>').val();
                    if (!wardID || wardID === '0') {
                        $('#tblWards tbody').empty();
                        return;
                    }

                    PageMethods.FillWardBeds(parseInt(wardID), function (response) {
                        var beds = JSON.parse(response);
                        if (beds.error) {
                            console.error('Error loading beds:', beds.error);
                            return;
                        }

                        var tbody = $('#tblWards tbody');
                        tbody.empty();

                        $.each(beds, function (i, bed) {
                            var mrNo = bed.PatientNo == "0" ? 'Available' : bed.PatientNo;
                            var rowClass = bed.PatientNo == "0" ? 'table-success' : 'table-danger';
                            var bedColor = bed.PatientNo == "0" ? 'Green' : 'red';

                            // Build the bed cell content
                            var bedCell;
                            if (bed.PatientNo == "0") {
                                // Available bed → clickable link
                                bedCell = '<a onclick="SelectBed(' + bed.WardID + ',' + bed.BedNo + ')" style="color:' + bedColor + '">' + bed.BedNo + '</a>';
                            } else {
                                // Occupied bed → plain text, not clickable
                                bedCell = '<span style="color:' + bedColor + '">' + bed.BedNo + '</span>';
                            }

                            var row = '<tr class="' + rowClass + '">' +
                                '<td>' + mrNo + (bed.PatientNo != "0" ? ' - ' + bed.Full_Name : '') + '</td>' +
                                '<td>' + bedCell + '</td>' +
                                '</tr>';
                            tbody.append(row);
                        });
                    }, function (error) {
                        console.error('Error:', error);
                    });
                }

            
      

        function checkPatientCondition(element) {
        }

        function chkIssuance_Of_Select() {
        }

        function populateRoomTypes() {
            PageMethods.GetRoomTypes(function (response) {
                var data = JSON.parse(response);
                if (data.error) {
                    console.error('Error loading room types:', data.error);
                    return;
                }
                var ddl = $('#<%= ddlRoom_Type.ClientID %>');
        ddl.empty();
        ddl.append('<option value="0">Please Select</option>');
        $.each(data, function (i, item) {
            ddl.append($('<option></option>').val(item.DataValue_Name).text(item.DataValue_Description));
        });
    }, function (error) {
        console.error('Error:', error);
    });
        }

        function chkIssuance_Of_Select() {
            var issuanceOf = $('#<%= ddlIssuance_Of.ClientID %>').val();

            // Show/Hide Ward controls
            if (issuanceOf == '001') {
                $('#<%= ddlWard_No.ClientID %>').prop('disabled', false);
        $('#<%= txtBed_No.ClientID %>').prop('disabled', true);
        $('#tblWards').show();
        $('#divRoomType').hide();
        $('#divRoomNo').hide();
        $('#divRoomBed').hide();
        $('#divRoomsTable').hide();
        $('#<%= ddlRoom_Type.ClientID %>').val('0');
        $('#<%= ddlRoom_No.ClientID %>').val('0');
        $('#<%= txtRoomBed_No.ClientID %>').val('');
    }
    // Show/Hide Room controls
    else if (issuanceOf == '002') {
        $('#<%= ddlWard_No.ClientID %>').prop('disabled', true);
        $('#<%= ddlWard_No.ClientID %>').val('0');
        $('#<%= txtBed_No.ClientID %>').prop('disabled', true);
        $('#<%= txtBed_No.ClientID %>').val('');
        $('#tblWards').hide();
        $('#divRoomType').show();
        $('#divRoomNo').show();
        $('#divRoomBed').show();
        $('#divRoomsTable').show();
        FillRooms();
    }
    else {
        $('#<%= ddlWard_No.ClientID %>').prop('disabled', true);
                $('#<%= txtBed_No.ClientID %>').prop('disabled', true);
                $('#tblWards').hide();
                $('#divRoomType').hide();
                $('#divRoomNo').hide();
                $('#divRoomBed').hide();
                $('#divRoomsTable').hide();
            }
        }


        function FillRooms() {
            var roomType = $('#<%= ddlRoom_Type.ClientID %>').val();
            if (!roomType || roomType === '0') {
                $('#tblRooms tbody').empty();
                return;
            }
            PageMethods.FillRooms(roomType, function (response) {
                var rooms = JSON.parse(response);
                if (rooms.error) {
                    console.error('Error loading rooms:', rooms.error);
                    return;
                }
                var tbody = $('#tblRooms tbody');
                tbody.empty();
                $.each(rooms, function (i, room) {
                    var mrNo = room.PatientNmae == "0" || room.PatientNmae == null ? 'Available' : room.PatientNmae;
                    var rowClass = room.PatientNmae == "0" || room.PatientNmae == null ? 'table-success' : 'table-danger';
                    var roomColor = room.PatientNmae == "0" || room.PatientNmae == null ? 'Green' : 'red';
                    var row = '<tr class="' + rowClass + '">' +
                        '<td>' + mrNo + '</td>' +
                        '<td><a onclick="SelectRoom(' + room.Room_ID + ',' + room.Room_No + ')" style="color:' + roomColor + '">' + room.Room_No + '</a></td>' +
                        '</tr>';
                    tbody.append(row);
                });
            }, function (error) {
                console.error('Error:', error);
            });
        }

        // Select Room function
        function SelectRoom(RoomID, RoomNo) {
            $('#<%= ddlRoom_No.ClientID %>').val(RoomID);
            $('#<%= txtRoomBed_No.ClientID %>').val(RoomNo);
        }

    </script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-12">
            <div class="row">
                <div class="col-lg-2">
                    <input type="button" class="btn btn-primry" value="WaitingList" onclick="openEmergencyWaitingListModal()" />
                </div>

            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-5">
            <div class="card">
                <div class="card-bodyy">
                    <div class="row">
                        <div class="col-lg-3 col-md-3 col-sm-4 text-center">
                            <div class="row">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient Image" class="img-fluid patient-image" />
                                </div>
                            </div>
                            <div class="row">
                            </div>

                        </div>
                        <div class="col-lg-9 col-md-9 col-sm-8">
                            <div class="row mb-3">
                                <div class="col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblPatient_Name" CssClass="labels" runat="server" Text="Patient Name:"></asp:Label>
                                </div>
                                <div class="col-md-7 col-sm-6 top">
                                    <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblPatien_No" CssClass="labels" runat="server" Text="MR No:"></asp:Label>
                                </div>
                                <div class="col-md-7 col-sm-6 top">
                                    <asp:Label ID="Label200" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblPatien_ID" CssClass="labels" runat="server" Text="Emergency No:"></asp:Label>
                                </div>
                                <div class="col-md-7 col-sm-6">
                                    <asp:Label ID="Label1" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblAge_Years" CssClass="labels" runat="server" Text="Age (Years):"></asp:Label>
                                </div>
                                <div class="col-md-7 col-sm-6">
                                    <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>

                            <div class="row mb-3">
                                <div class="col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblContactNo" CssClass="labels" runat="server" Text="Contact No:"></asp:Label>
                                </div>
                                <div class="col-md-7 col-sm-6">
                                    <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <hr />
    </div>
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" ID="lblPatientCondition" runat="server" Text="Triage Area"></asp:Label>
            <asp:UpdatePanel ID="UpdatePanel1" TabIndex="6" runat="server">
                <ContentTemplate>
                    <asp:DropDownList ID="ddlPatientCondition" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onchange="checkPatientCondition(this)"></asp:DropDownList>
                </ContentTemplate>
            </asp:UpdatePanel>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" runat="server" ID="lblTreatmentTime" Text="Treatment Time"></asp:Label>
            <asp:TextBox runat="server" CssClass="form-control-custom readonly" ID="txtTreatmentTime" ReadOnly="true"></asp:TextBox>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" ID="LblAdmission_Date" runat="server" Text="Admission Date"></asp:Label>
            <asp:TextBox ID="txtAdmission_Date" CssClass="form-control-custom readonly" runat="server" ReadOnly="true"></asp:TextBox>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" ID="lblfee" runat="server" Text="Admission Fee"></asp:Label>
            <asp:TextBox ID="txtadmissionfee" CssClass="form-control-custom readonly" ReadOnly="true" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" ID="LblDepartment" runat="server" Text="Department"></asp:Label>
            <asp:DropDownList ID="ddlDepartment" CssClass="form-control-custom" TabIndex="1" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <asp:Label CssClass="form-label" ID="Label26" runat="server" Text="Doctor"></asp:Label>
            <asp:DropDownList ID="ddlDoctor" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
        </div>
    </div>
    <div class="row">
    <div class="col-lg-2 col-md-4 col-sm-12">
        <asp:Label ID="lblIssuance_Of" runat="server" Text="Admit To"></asp:Label>&nbsp;&nbsp;<span class="text-danger">*</span>
        <asp:DropDownList ID="ddlIssuance_Of" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onChange="chkIssuance_Of_Select()"></asp:DropDownList>
        <asp:RequiredFieldValidator ID="rfvIssuance_Of" ControlToValidate="ddlIssuance_Of" InitialValue="0" runat="server" ErrorMessage="Select Admit To" Text="*"></asp:RequiredFieldValidator>
    </div>
    <div class="col-lg-2 col-md-4 col-sm-12">
        <asp:Label CssClass="form-label" ID="LblBed_No" runat="server" Text="Bed No"></asp:Label>
        <asp:TextBox ID="txtBed_No" CssClass="form-control-custom" TabIndex="8" runat="server" Enabled="false"></asp:TextBox>
    </div>
    <div class="col-lg-2 col-md-4 col-sm-12">
        <asp:Label CssClass="form-label required" ID="lblWard_No" runat="server" Text="Ward"></asp:Label>
        <asp:DropDownList ID="ddlWard_No" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onChange="FillWardBeds()"></asp:DropDownList>
    </div>
    <!-- NEW: Room Controls -->
    <div class="col-lg-2 col-md-4 col-sm-12" id="divRoomType" style="display:none;">
        <asp:Label CssClass="form-label" ID="lblRoom_Type" runat="server" Text="Room Type"></asp:Label>
        <asp:DropDownList ID="ddlRoom_Type" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true" onChange="FillRooms()"></asp:DropDownList>
    </div>
    <div class="col-lg-2 col-md-4 col-sm-12" id="divRoomNo" style="display:none;">
        <asp:Label CssClass="form-label" ID="lblRoom_No" runat="server" Text="Room No"></asp:Label>
        <asp:DropDownList ID="ddlRoom_No" CssClass="form-control-custom" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
    </div>
    <div class="col-lg-2 col-md-4 col-sm-12" id="divRoomBed" style="display:none;">
        <asp:Label CssClass="form-label" ID="lblRoomBed_No" runat="server" Text="Room Bed"></asp:Label>
        <asp:TextBox ID="txtRoomBed_No" CssClass="form-control-custom" runat="server" Enabled="false"></asp:TextBox>
    </div>
</div>
<div class="row">
    <div class="col-lg-4 col-md-6 col-sm-12">
        <div style="overflow-y: scroll; max-height: 150px;">
            <table id="tblWards" class="table table-responsive" style="float: right;">
                <thead>
                    <tr>
                        <th>MR No</th>
                        <th>Bed No</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
    <!-- NEW: Room Table -->
    <div class="col-lg-4 col-md-6 col-sm-12" id="divRoomsTable" style="display:none;">
        <div style="overflow-y: scroll; max-height: 150px;">
            <table id="tblRooms" class="table table-responsive" style="float: right;">
                <thead>
                    <tr>
                        <th>MR No</th>
                        <th>Room No</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
</div>

    <div class="row">
        <div class="col-lg-8 col-md-8 co-sm-12">
            <div class="row">
                <div class="col-lg-2 col-md-4 co-sm-6">
                    <input id="btnSave" type="button" class="btn btn-primry" value="Save" onclick="SaveAdmission()" />
                </div>
                <div class="col-lg-2">
                    <input type="button" class="btn btn-primry" value="View" onclick="window.location='OutPatientsView.aspx'" />
                </div>
                <div class="col-lg-2">
                    <input type="button" class="btn btn-primry" value="Print" onclick="window.location='OutPatientsView.aspx'" />
                </div>
            </div>
        </div>
    </div>

    <div id="EmergencyWaitingListModal" class="modal fade scrollable-modal" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="EmergencyWaitingList">
                        <div class="row" style="margin-bottom: 15px">

                            <div class="col-lg-3">
                                <input type="text" class="form-control" id="SearchEmergencyWaitingList" placeholder="Search..." />
                            </div>

                            <div class="col-lg-2">
                                <a onclick="fillEmergencyWaitingList()" style="cursor: pointer;">
                                    <i class="fa fa-refresh fa-2x"></i>
                                </a>
                            </div>

                        </div>


                        <div class="table-responsive previewTable" style="max-height: 400px; overflow-y: auto;">
                            <table class="table table-bordered table-custom" id="tblEmergencyWaitingList">
                                <thead id="ihead">
                                    <tr>
                                        <th>Emergency No</th>
                                        <th>MR No</th>
                                        <th>Patient Name</th>
                                        <th>Age</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Status</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <input style="display: none" type="text" id="hiddenPatientID" />
    <input style="display: none" type="text" id="hiddenEmergencyID" />
</asp:Content>
