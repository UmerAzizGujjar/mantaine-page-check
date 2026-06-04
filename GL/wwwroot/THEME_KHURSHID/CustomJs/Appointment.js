$(document).ready(function () {
    debugger;

    filldepartment();
    fillProvince();
    fillCity();
    fillCountry();
    fillArea();

    $('#ddlsubdepartment').select2();
    $('#btnSave').on('click', function () {
        debugger;
        verifydoctoravail(function (result) {
            debugger;

            if (result === 'OnDay') {
                save = $('#btnSave').val();
                SaveAllRecord();
            } else if (result === 'OffDay') {
                return false;
            }
        });

    });
    debugger;
    $("#txtSearch").keypress(function (event) {

        var SearchString = $('#txtSearch').val();
        if (event.which == 13) {
            {

                event.preventDefault();

                if (SearchString != '') {

                    PageMethods.SearchPatients((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterPatients, OnFailPatients);
                }
            }
            if (SearchString === '') {
                FillPatientsList();
            }
        }

    });
    $("#txtSearch").keyup(function (event) {

        var SearchString = $('#txtSearch').val();
        event.preventDefault();
        if (SearchString === '')
            FillPatientsList();
    });
    $('#txt_date').change(function () {
        LoadPage();
    });

    $('#btnSaveMessage').on('click', function () {
        verifydoctoravail(function (result) {
            debugger;

            if (result === 'OnDay') {
                save = $('#btnSave').val();
                SaveAllRecord();
            } else if (result === 'OffDay') {
                return false;
            }
        });

    });


    debugger;
  


    fillgender();
    fillmartial();
    fillType();


    debugger;
  
    $('#ctl00_MainContent_ddlPrefixDrp').on('select', function () {
        debugger;


        setTimeout(function () {
            $('#txt_pt_name').focus();
        }, 5);



    });
    $('#ddlsubdepartment').on('change', function () {
        debugger;


        setTimeout(function () {
            $('#ddlServices').focus();
        }, 5);



    });
    $('#ddlServices').on('change', function () {
        debugger;


        setTimeout(function () {
            $('#txtRemarks').focus();
        }, 5);



    });
    MaskedInput({
        elm: document.getElementById('txt_phone_no'),
        format: '___________',
        separator: '-'

    });

    LoadDetailDoctor();
    LoadPage();
    getpage();



    $('#ddl_colstnt').select2();

    $('#chk_Doc').select2();

    $('#txt_pt_name').attr('disabled', true);
    $('#txt_phone_no').attr('disabled', true);
    $('#txt_age').attr('disabled', true);
    $('#btnSearch').click(function () {
        getpage();


    });
    setTimeout(function () {
        $('#ctl00_MainContent_ddlPrefixDrp').focus();
    }, 5000);
    debugger;
   
});
function GetSubDepartmentByDoctor(doctor_Id) {
    PageMethods.GetSubDepartmentByDoctor(doctor_Id, function (data) {
        var options = '';
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.Department + '" >' + value.Departments + '</option>';
        });
        $('#ddlsubdepartment').html(options);
        $('#ddlsubdepartment').select2();
    },
        function (error) {
            alert(error.get_message());
        });
}


function addfunc() {
    debugger;


    var maskedValue = $('#txtSearch').val();
    var unmaskedValue = maskedValue.replace(/_/g, '');


    var Ph_sNOs = unmaskedValue.length;


    if (Ph_sNOs === 13) {
        $('#addNewbtn').attr("disabled", false);
        AddNewPatient();
    }
    else {
        alert("Please Enter Complete Mobile Number First");
        return;
    }




    debugger;

    $('#ClosePatientsSearchModel').click();
    fillmrno();
    setTimeout(function () {
        $('#txt_mobile').val(unmaskedValue);
    }, 100);
    $('#txt_name').focus();
}
function fillmrno() {
    var data = {};

    $.ajax({
        type: "POST",
        url: "Appointment.aspx/Getmr",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            debugger;
            var max_mr = data.d;
            $('#txt_Mrnos').val(max_mr);
        },
        error: function (xhr, status, error) {
            console.error("AJAX request failed:", status, error);
        }
    });
}


function load_Initial_Pat_Data(reg_pat) {
    var reg_id = reg_pat;
    $('#PatientsSearchModel').close;
    debugger;
    $.ajax({
        type: "POST",
        url: "Appointment.aspx/loadApp_data",
        data: JSON.stringify({
            'reg_id': reg_id

        }),

        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            debugger;
            var dataaa = JSON.parse(data.d);

            $('#txt_pt_name').val(dataaa.Full_Name);
            $('#txt_phone_no').val(dataaa.Age);
            $('#txt_age').val(dataaa.Age_years);
            $('#txt_phone_no').val(dataaa.Mobile1);
            $('#hdfreg_ini_id').val(dataaa.pat_id);
            $('#txt_apt_no').val('');
            $('#ClosePatientsSearchModel').click();



        },
        error: function (x, e) {
            alert(e)
        }
    });
}
function SearchPatients() {
    debugger;
    $('#PatientsSearchModel').modal({
        backdrop: 'static'

    });
    FillPatientsList();
    $('#addNewbtn').hide();
    $('#srchpat').text("Search Your Patients:");
    $('#txtSearch').unmask();
    $('#ClosePatientsSearchModel').show();

}
function AddNewPatient() {
    debugger;
    $('#ddl_pnl_cpy').next(".select2-container").hide();

    clearPatient();
    $('#hdfPatient_ID').val('(New)');

    $('#PatientModel').modal({
        backdrop: 'static'
    });
    $("#ddl_name").focus();
    $("#ddl_name").focus();
    MaskedInput({
        elm: document.getElementById('txt_cnic'), // select only by id
        format: '_____-_______-_',
        separator: '-'

    });
}
function FillPatientsList() {
    debugger;
    $('#tblPatientsResult tbody').empty();

    var SearchString = '';

    PageMethods.SearchPatients(SearchString, OnFilterPatients, OnFailPatients);
}

function OnFilterPatients(data) {

    ClearPatientResults();

    for (var i = 0; i < data.length; i++) {
        AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
    }
}
function OnFailPatients(exc) {
    alert(exc.get_message());
}
function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
    debugger;
    tblLength = tblPatientsResult.rows.length;

    var row = iPatientsBody.insertRow(-1);
    var cell;

    cell = row.insertCell(-1);
    cell.innerHTML = '<span spnPatID' + tblLength + '>' + Reg_Patient_ID + '</span>';
    cell.className = "hide";

    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
    cell = row.insertCell(-1);
    var actions = ''
    actions += '<a  class="fa fa-plus" style="color:#15ab02db;font-size:16px;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')></a>';
    cell.innerHTML = actions;
}
function ClearPatientResults() {
    while (tblPatientsResult.rows.length > 1) {
        tblPatientsResult.deleteRow(1);
    }
}
var isAdd = false;
function AddPatientDetail(Reg_Patient_ID) {
    debugger;
    try {
        isAdd = true;
        window.location.href = "Appointment.aspx?ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}
function LoadPage() {
    debugger;
    var stDate;
    var endDate;
    var doc_id = $('#ddl_colstnt').val();
    if (stDate == null) {
        var getstDate = $('#txt_datefrom').val();
        stDate = getstDate;
    } else {
        stDate = stDate;
    }
    if (endDate == null) {
        endDate = $('#txt_dateto').val();
    } else {
        endDate = endDate;
    }
    var specificDate = $('#txt_date').val();
    $.ajax({
        type: "POST",
        url: "Appointment.aspx/ViewLists",
        data: JSON.stringify({ doc_id: doc_id, specificDate: specificDate }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var responseData = JSON.parse(response.d);
            var doctorData = responseData.DoctorData;
            var appointments = responseData.Appointments;

            if (!doctorData) {
                console.error("Doctor is not available that day");
                $('#tblRes tbody').html('<tr><td colspan="3">Doctor is not available that day</td></tr>');
                $('#txt_time').val('');

                return;
            }

            var slotsList = doctorData.Slots;

            var rows = '';
            debugger;
            slotsList.forEach(function (slot) {
                debugger;
                var formattedItem1 = moment(slot.Item1).format('hh:mm A');
                var formattedItem2 = moment(slot.Item2).format('hh:mm A');


                var overlap = appointments.some(function (appointment) {
                    var appointmentTime = moment(appointment.StartTime).format('hh:mm A');
                    return (formattedItem1 === appointmentTime);
                });


                var bgColor = overlap ? 'rgb(245, 86, 86)' : 'rgb(119, 245, 119)';
                var textColor = overlap ? 'black' : 'black';
                var lastCellContent = bgColor === 'rgb(245, 86, 86)' ? '<strong>Booked</strong>' : '<a href="#" onclick="selectRow(\'' + formattedItem1 + '\')" style="border-radius: 4px; background-color: #449777db; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;" class="">Select</a>';


                rows += '<tr style="background-color:' + bgColor + '; color:' + textColor + '"><td><span id="item1">' + formattedItem1 + '</span></td><td><span class="item2">' + formattedItem2 + '</span></td><td>' + lastCellContent + '</td></tr>';


            });
            debugger;

            $('#tblRes tbody').html(rows);
            $('#txt_time').val(formattedItem1)
        },
        error: function (xhr, status, error) {
            debugger;
            console.error("Error fetching data from the backend:", error);
        }
    });

    return false;
}
var appendtime;
function selectRow(appendtime) {
    debugger;
    $('#txt_time').val(appendtime);
}
function fillgender() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetGender(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#ddl_Gender').html(options);

    });
    return options;
}
function fillCountry() {
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'Appointment.aspx/GetCountry',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#ddlCountry').html(options);

        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}
function fillArea() {
    var options = '<option value="0">Please Select</option>';

    $.ajax({
        url: 'Appointment.aspx/GetArea',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#txtarea').html(options);

        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;

}
function fillCity() {
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'Appointment.aspx/GetCity',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#txtcity').html(options);

        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}
function fillProvince() {
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'Appointment.aspx/GetProvince',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#ddl_Province').html(options);

        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}
function fillType() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetPAtType(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#ddlPatient_Type').html(options);
        $('#ddlPatient_Type').attr('disabled', true);
        $('#ddlPatient_Type').val('02');

    });
    return options;
}
function getpage() {

    var stDate;
    var endDate;
    if (stDate == null) {


        var getstDate = $('#txt_datefrom').val();
        stDate = getstDate;

    }

    else {
        stDate = stDate;
    }
    if (endDate == null) {
        endDate = $('#txt_dateto').val();
    }

    else {
        endDate = endDate;
    }

    var Statusddl = $('#chk_status').find('option:selected').text();


    if (Statusddl == "All" && abc == true) {


        stDate = "";
        endDate = "";
    }


    var DocChk = $('#chk_Doc').find('option:selected').text();


    if (DocChk == "Select Doctor" && acc == true) {


        stDate = "";
        endDate = "";


    }


    PageMethods.getlist(stDate, endDate, function (data) {
        debugger;
        if (data.length === 0) {

            $("#table_res tbody").empty();
            return false;
        }
        else {
            debugger;
            abc = false;
            //var table;
            var Priority = '';

            var length = $("#table_res tr:gt(0)").length;
            debugger;
            if (data != '') {
                var data = JSON.parse(data);
                var rows = '';
                debugger;
                $.each(data, function (i, item) {
                    debugger;
                    var App_Date = moment(data[i].App_Date).format('LL');
                    var time = moment(data[i].Time).format('h:mm a');
                    var cancel = data[i].cancelAppointment;
                    var status = data[i].Status;
                    if (cancel == true) {
                        status = 'Cancelled'
                    }
                    debugger;

                    rows += '<tr><td>' + (i + 1) + '</td><td>' + data[i].Appointment_No + '</td><td>' + toTitleCase(data[i].Patient_Name.replace("_", " ")) + '</td><td>' + data[i].emp_name + '</td><td>' + data[i].Phone + '</td> <td>' + App_Date + '</td> <td>' + time + '</td>  <td>' + status + '</td><td style="display:none;" name="cancelAppointment">' + data[i].cancelAppointment + '</td><td style="width: 250px";><a href="#" onclick="Edit(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #428bca; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;">Change  Schedule</a><a href="#" onclick="CancelAppointment(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #ea0000; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;">Cancel</a></td></tr>';


                });
                debugger;
                $('#t_body').html(rows);

                $('#table_res tbody:eq(1) tr').each(function (key, value) {
                    debugger;
                    var Status = $(this).find('td:eq(7)').text();
                    var app_date = $(this).find('td:eq(5)').text();
                    var currentDate = moment().format('LL');
                    var cancel = $(this).find('td[name="cancelAppointment"]').text();

                    if (Status == "Visited") {
                        $(this).css('background-color', '#77f577');
                        $(this).find('td:last a').hide();
                    } else if (Status == "Booked") {
                        $(this).css('background-color', '#ffdc86');
                    }

                    if (cancel == "true") {
                        $(this).css('background-color', '#FF6060');


                        $(this).find('td:last a').hide();
                    }
                });





            }
        }

    });


    return false;
}
function CancelAppointment(appointmentId) {
    debugger;
    if (confirm("Are you sure you want to cancel this appointment?")) {
        $.ajax({
            type: "POST",
            url: "Appointment.aspx/CancelAppointment",
            data: JSON.stringify({ appointmentId: appointmentId }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {

                alert('Appointment canceled successfully');

                location.reload();

            },
            error: function (xhr, status, error) {

                alert('Failed to cancel the appointment. Please try again.');
            }
        });
    }
}


debugger;
function loadappt(appID) {
    debugger;
    PageMethods.loadAppData(appID, function (resp) {
        debugger;
        if (appID != "") {
            $('#btnSave').val('Update');
        }
        var data = JSON.parse(resp);
        var patientTitle = data.Patient_Name.split("_");
        var agePrefix = data.Age.split(" ");

        if (patientTitle.length > 1) {

            $("#ctl00_MainContent_ddlPrefixDrp option:contains(" + patientTitle[0] + ")").attr("selected", true);
        }
        $('#ddl_colstnt').val(data.Consultant_ID).change();
        $('#txt_ID').val(data.Appointment_ID);
        $('#txt_pt_name').val(patientTitle[patientTitle.length - 1]);
        $("#ctl00_MainContent_ddlPrefixDrp")
        $('#txt_phone_no').val(data.Phone);
        $('#ctl00_MainContent_ddlPrefixAge').val(agePrefix[0]).change();
        $('#txt_age').val(agePrefix[1]);
        $('#txtRemarks').val(data.Remarks);
        $('#txt_age').val(data.Age);
        $('#txt_apt_no').val(data.Appointment_No);
        $('#hdfreg_ini_id').val(data.Reg_id);

        $('#txt_time').val(data.Time);

        $("#txt_date").datepicker({
            dateFormat: 'MM d,yy',
            minDate: 0
        }).attr('readonly', 'readonly');

        date = moment(date).format('LL');
        $("#txt_date").val(date);

        setTimeout(function () {
            debugger;

            $('#ddlsubdepartment').val(data.Sub_Department).change();

            $('#ddlServices').val(data.Item_Id).change();

        }, 1500);

    },

        function (error) {
            alert(error.get_message());
        });
}


function loadapptEdit(App_id) {

    PageMethods.loadAppData_edit(App_id, function (resp) {

        if (App_id != "") {
            $('#btnSave').val('Update');
        }
        var data = JSON.parse(resp);
        var patientTitle = data.Patient_Name.split("_");
        var agePrefix = data.Age.split(" ");

        $('#ddl_colstnt').val(data.Consultant_ID).change();
        $('#txt_ID').val(data.Appointment_ID);
        $('#txt_pt_name').val(data.Patient_Name);

        $('#txt_phone_no').val(data.Phone);
        $('#txt_age').val(data.Age);
        $('#txtRemarks').val(data.Remarks);
        $('#txt_apt_no').val(data.Appointment_No);
        $('#hdfreg_ini_id').val(data.Reg_id);
        $('#txt_time').val(data.Time);
        $('#txt_time').val(data.Time);

        $('#txt_date').attr('readonly', false);
        var date = $.datepicker.formatDate('M/D/Y', new Date(parseInt(data.app_date.substring(6, 19))));
        date = moment(data.app_date).format('LL');
        $('#txt_date').val(date);
        $('#txt_date').attr('readonly', true);
        setTimeout(function () {


            $('#ddlsubdepartment').val(data.Sub_Department).change();

            $('#ddlServices').val(data.Item_Id).change();

        }, 1500);

    },

        function (error) {
            alert(error.get_message());
        });
    $('#ClosePatientsSearchModel').click();
}



function Edit(aID) {
    debugger;
    window.location.href = "Appointment.aspx?aID=" + aID;

}


//first form id increment
function GetAppNo() {
    PageMethods.GetAppNo(function (resp) {
        $('#txt_ID').val(resp);
    },
        function (error) {
            alert(error.get_message());
        });

}

debugger;
function GetAppointmentTime() {
    debugger;
    var doctorID = $('#ddl_colstnt').val();
    debugger;
    PageMethods.GetAppointmentTime(doctorID, function (resp) {
        debugger;

        $("#txt_time").val(resp);
    },
        function (error) {
            alert(error.get_message());
        });

}
function fillmartial() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetMartailStatus(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#ddl_status').html(options);

    });
    return options;
}

function clearPatient() {

    $('#txt_name').val("");
    $('#txt_relation').val("");
    $('#txt_mobile').val("");
    $('#txt_dob').val("");
    $('#txt_cnic').val("");
    $('#txt_Address').val('');
    //   $('#ddltest_main_dpt').val(0);
    $('#updatePatient_Data').hide();
    $('#RevistPat').hide();
}
function GetServices() {
    debugger;
    var options = '<option value="0">Select Services</option>';
    PageMethods.GetServices(function (data) {
        $.each(JSON.parse(data), function (key, value) {

            if (key >= 0) {
                options += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
            }
        });
        $('#ddlServices').html(options);
        $('#ddlServices').select2();


    });

}

debugger;
function SavePatient() {
    debugger;
    $('#SavePatient_Data').attr('disabled', true);
    var Prefix_PatientName = $('#ddl_name').val();
    var PatientName = $('#txt_name').val();
    var PatientID = $('#hdfPatient_ID').val();

    var Full_Name = Prefix_PatientName + PatientName;
    debugger;
    var RelationType = $('#ddlRelation').val();
    var Relation = $('#txt_relation').val();
    var Gender = $('#ddl_Gender').val();
    var reg_pat_id = $('#hdfreg_ini_id').val();

    var Mobile = $('#txt_mobile').val();

    var PreFix_DOB = $('#ddl_dob').val();
    var Age = $('#txt_dob').val();
    var Date_Of_Birth = $('#txtAge_yearss').val();

    var CNIC = $('#txt_cnic').val();
    var Address = $('#txt_Address').val();
    var martail_status = $('#ddl_status').val();

    var houseno = $('#txt_house').val();
    var stno = $('#txtstrm').val();
    var city = $('#txtcity :selected').text();
    var area = $('#txtarea :selected').text();

    var city_val = $('#txtcity').val();
    var area_val = $('#txtarea').val();

    if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || houseno == "" || city_val == "0" || area_val == "0")) {


        alert("Please Enter compulsory Fields");
        $('#SavePatient_Data').attr('disabled', false);
        return;
        // }
    }

    var data = JSON.stringify({
        "Full_Name": Full_Name,
        "RelationType": RelationType,
        "Relation": Relation,
        "Gender": Gender,
        "Mobile": Mobile,
        "Date_Of_Birth": Date_Of_Birth,
        "CNIC": CNIC,
        "Address": Address,
        "houseno": houseno,
        "stno": stno,
        "city": city,
        "city_val": city_val,
        "area_val": area_val,
        "area": area,
        "PatientID": PatientID,
        "martail_status": martail_status,
        "reg_pat_id": reg_pat_id,
        "Age": Age,

    });
    $.ajax({
        type: "POST",
        url: "Appointment.aspx/SavePatientDetails",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            debugger;
            var ini_patientID = data.d;

            alert('Your Record Save and Load Successfully');
            $('#PatientModel').modal('hide');

            get_pat_initial_info(ini_patientID);



        },
        error: function (response) {
            alert("Error");
        }
    });
}
function get_pat_initial_info(ini_patientID) {
    debugger;
    try {
        isAdd = true;
        window.location.href = "Appointment.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}


function LoadDetailDoctor() {
    debugger;
    var options = '<option value="0">Select Doctor</option>';
    PageMethods.GetDoctors(function (data) {
        $.each(JSON.parse(data), function (key, value) {

            if (key >= 0) {
                options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
            }
        });
        $('#ddl_colstnt').html(options);

        $('#chk_Doc').html(options);

    });

}


var abc = false;
function testddlchange() {
    debugger;



    var Statusddl = $('#chk_status').find('option:selected').text();

    if (Statusddl == "All") {
        abc = true;
        LoadPage();
    }
    else {
        var tbl = document.getElementById('table_res');
        if (Statusddl.trim() != '') {

            for (var i = 1; i < tbl.rows.length; i++) {
                if (tbl.rows[i].cells[7].innerText != Statusddl) {
                    var row = tbl.rows[i];
                    row.style.display = 'none';
                }
                else {
                    var row = tbl.rows[i];
                    row.style.display = '';
                }
            }
        }
        else {
            for (var i = 1; i < tbl.rows.length; i++) {
                var row = tbl.rows[i];
                row.style.display = '';
            }
        }
    }

}


var acc = false;
function toTitleCase(str) {
    return str.replace(/[^a-zA-Z0-9]+(.)/g, function (match) {
        return match.toUpperCase();
    });
}

function ddldocchange() {
    debugger;



    var DocChk = $('#chk_Doc').find('option:selected').text();

    if (DocChk == "Select Doctor") {
        acc = true;
        LoadPage();
    }
    else {
        var tbl = document.getElementById('table_res');
        if (DocChk.trim() != '') {

            for (var i = 1; i < tbl.rows.length; i++) {
                if (tbl.rows[i].cells[3].innerText != DocChk) {
                    var row = tbl.rows[i];
                    row.style.display = 'none';
                }
                else {
                    var row = tbl.rows[i];
                    row.style.display = '';
                }
            }
        }
        else {
            for (var i = 1; i < tbl.rows.length; i++) {
                var row = tbl.rows[i];
                row.style.display = '';
            }
        }
    }

}
function CalculateDateOfBirth() {
    debugger;
    var now = moment();
    var year = $('#txt_dob').val();
    var calcualteDate = now.subtract('years', year);
    var finalDate = calcualteDate.format("M/D/YYYY");
    var $datepicker = $('#txtAge_yearss');
    $datepicker.datepicker();
    $('#txtAge_yearss').unmask("99/99/9999");
    $datepicker.datepicker('setDate', finalDate);
    $('#txtAge_yearss').unmask("99/99/9999");
    $("#txtAge_yearss").mask("99/99/9999");


}
function filldepartment() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetDepartment(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#ddlsubdepartment').html(options);

    });
    return options;
} debugger;

debugger;
function convertTo24Hour(time) {
    debugger;
    var hours = parseInt(time.substr(0, 2));
    var minutes = time.substr(3, 2);
    var period = time.substr(6, 2).toUpperCase();

    if (period === 'PM' && hours < 12) {
        hours = hours + 12;
    }
    if (period === 'AM' && hours === 12) {
        hours = hours - 12;
    }

    var hoursStr = hours < 10 ? '0' + hours : hours; // Pad with zero if single digit
    return hoursStr + ':' + minutes;
}

debugger;
function verifydoctoravail(callback) {
    debugger;
    var ddl_colstnts = $('#ddl_colstnt').val();
    var time_appointment = $('#txt_time').val();
    var date = $('#txt_date').val();

    $.ajax({
        type: "POST",
        url: "Appointment.aspx/CheckDays",
        data: JSON.stringify({
            'ddl_colstnts': ddl_colstnts,
            'date': date
        }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            debugger;
            var dataaa = JSON.parse(data.d);





            debugger;
            if (dataaa && dataaa.Off_Days_Names && dataaa.Off_Days_Names.includes) {
                var dateObject = new Date(date);
                var options = { weekday: 'short' };
                var dayNameShort = dateObject.toLocaleDateString('en-US', options);

                if (dataaa.Off_Days_Names.includes(dayNameShort)) {
                    alert('Doctor Not Available Today');
                    callback('OffDay');
                } else {
                    callback('OnDay');
                }
            } else {
                callback('OnDay');
            }
        },
        error: function (x, e) {
            alert(e);
        }
    });
}


function convertToMinutes(timeString) {
    var [time, period] = timeString.split(' ');
    var [hours, minutes] = time.split(':');
    hours = parseInt(hours, 10);
    minutes = parseInt(minutes, 10);

    if (period === 'PM' && hours !== 12) {
        hours += 12;
    } else if (period === 'AM' && hours === 12) {
        hours = 0;
    }

    return hours * 60 + minutes;
}

function setFocus() {
    document.getElementById("txtSearch").focus();
    $("#txtSearch").focus();
}
document.addEventListener("DOMContentLoaded", setFocus);
