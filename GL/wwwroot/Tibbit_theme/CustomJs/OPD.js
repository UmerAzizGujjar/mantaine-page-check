
$(document).ready(function () {
    debugger;

    $('.show').show();
    $('#divcard').hide();
    $('#divapprove').hide();
    $('#btn-opdprint').hide();
    $('#divvoucher').hide();
    $("#tabs").on('click', 'li', function () {
        debugger;
        var activeTab = $(this).find('a').html();
        if (activeTab == "Contact Information") $("#ctl00_MainContent_txtTemporary_Address").focus();

    });
    debugger;

    $('#btnsearchpatlist').click(function () {
        $("#PatientsSearchModel").modal('show');
        FillPatientsList();
    });

    $('#btnsearchEmergencylist').click(function () {
        $("#SearchEmergencyPatients").modal('show');
        FillEmergencyPatientsList();
    });
    $("#txtSearch").keypress(function (event) {
        debugger;
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

    $("#txtSearchmodal").keypress(function (event) {
        debugger;
        var SearchString = $('#txtSearchmodal').val();
        if (event.which == 13) {
            {

                event.preventDefault();

                if (SearchString != '') {

                    PageMethods.SearchAppointment((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilter, OnFail);
                }
            }
            if (SearchString === '') {
                FillList();
            }
        }
    });
    var dropdowns = [
        { id: '#ddlMode_Of_Registration', method: 'ModePresentation' },
        { id: '#ddlPatient_Type', method: 'PatientType' },
        { id: '#ddl_Gender', method: 'GetGender' },
        { id: '#ddlrollno', method: 'GetRollNo' },
        { id: '#ddl_status', method: 'GetMartailStatus' },
        { id: '#ddlCountry', method: 'GetCountry' },
        { id: '#ddl_Province', method: 'GetProvince' },
        { id: '#txtarea', method: 'GetArea' },
        { id: '#txtcity', method: 'GetCity' },
        { id: '#ddlFilterClnic', method: 'GetClinics' },
        { id: '#ddlServices', method: 'GetServices' },
        { id: '#ddlDepartment', method: 'GetDepartment' },
        { id: '#ddldoctor', method: 'GetDoctor' },
        { id: '#ddlpanel', method: 'GetPanel' }

    ];

    dropdowns.forEach(item => {

        const $element = $(item.id);
        $element.select2();
        $element.off('select2:open').on('select2:open', function () {
            fillDropdown($element, item.method);
        });


        if (item.id === '#ddlPatient_Type') {
            $element.prop('disabled', false);
            $element.off('select2:select').on('select2:select', function () {
                loaddata();
                $(this).prop('disabled', true);
            });
        }

        if (item.id === '#ddlDepartment') {
            $element.prop('disabled', false);
            $element.off('select2:select').on('select2:select', function () {
                loaddoctor();
            });
        }

        if (item.id === '#ddldoctor') {

            $element.off('select2:select');

            $element.on('select2:select', function (e) {
                var selectedVal = $(this).val();
                if (selectedVal) {
                    loadFee();
                }
            });

            $element.off('select2:open');
        }


    });

    showhide();
    FillModePresentation();
    get_totalpatient();
    FillUserAccount();

});
function fillDropdown($dropdown, methodName) {
    if ($dropdown.data('filled')) return;

    $dropdown.data('filled', false);

    $.ajax({
        type: "POST",
        url: "OPD.aspx/" + methodName,
        data: '{}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            try {
                const data = JSON.parse(response.d);
                var options = '<option value="0">Please Select</option>';

                $.each(data, function (key, value) {
                    options += `<option value="${value.DataValue_Name}">
                                    ${value.DataValue_Description}
                                </option>`;
                }); 

                $dropdown.html(options)
                    .data('filled', true)
                    .trigger('change');
                if ($dropdown.hasClass('select2-hidden-accessible')) {
                    $dropdown.select2('close').select2('open');
                }
            } catch (e) {
                console.error(`Error parsing data from ${methodName}:`, e);
                $dropdown.data('filled', false);
            }
        },
        error: function (xhr, status, error) {
            console.error(`Error fetching ${methodName}:`, error);
            $dropdown.data('filled', false);
        }
    });
}
var selected_tabs = 1;
$(function () {
    var tabs = $("#tabs").tabs({
        select: function (e, i) {
            selected_tabs = i.index;
        }
    });
});



function showhide() {
    $('.show').show();
    $('#fees').hide();
    $('#department').hide();
    $('#field_Clinic').hide();
    $('#doctor').hide();
    $('#pnlcompany').hide();
    $('#employee').hide();
    $('#refference').hide();
    $('#discount').hide();
    $('#empname').hide();
    $('#designation').hide();
    $('#rollno').hide();
    $('#class').hide();
    $('#section').hide();
    $('#dependent').hide();
    $('#emp_id').hide();
    $('#EmployeeName').hide();
    $('#EmpDep').hide();
    $('#StdName').hide();
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
function Get_Pat_Info_Apt(reg_id, apt_Id) {
    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetBasicInfo_Apt",
        data: JSON.stringify({ reg_id: reg_id, apt_Id: apt_Id }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            debugger;
            var data = JSON.parse(resp.d);
            $('#txtPatientNo').val(data.Mr_No);
            $('#txtpatient_no').val(data.pat_no);
            $('#txt_patname').val(data.Name);
            $('#txt_F_Name').val(data.FatherName);
            $('#txtage').val(data.Age);
            $('#txtnic').val(data.CNIC_Masked); // 👈 Updated!
            $('#txtmobile').val(data.Mobile);
            $('#txtAdrress').val(data.PermanentAdrress);
            $('#hdn_regid').val(data.Reg_PatientID);
            $('#hdn_aptid').val(apt_Id);
            $('#ctl00_MainContent_lblNoOfDays').html(data.DaysSinceLatestVisit);
            $('#ctl00_MainContent_lblNoOfDays2').html(data.DaysSinceSecondLatestVisit);

            debugger;

            $('#ddlmartialstatus').html(
                $('<option>', {
                    value: data.MaritalStatus,
                    text: data.MaritalStatus_text
                })
            );
            $('#ddlGender').html(
                $('<option>', {
                    value: data.Gender,
                    text: data.Gender_text
                })
            );
            $('#ddlDepartment').html(
                $('<option>', {
                    value: data.departmentid,
                    text: data.department_Text
                })
            );

            $('#ddlPatient_Type').html(
                $('<option>', {
                    value: data.pat_type_Val,
                    text: data.pat_type_text
                })
            ); loaddata();

            var $select = $('#ddldoctor');


            $select.empty().append(
                $('<option>', {
                    value: data.doctorId,
                    text: data.DoctorName
                })
            );


            var $select = $('#ddldoctor');

            $select.empty().append(
                new Option(data.DoctorName, data.doctorId, true, true) // creates selected option
            );


            $select.trigger({
                type: 'select2:select',
                params: {
                    data: { id: data.doctorId, text: data.DoctorName }
                }
            });


        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}
function Get_Pat_Info(reg_id) {
    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetBasicInfo",
        data: JSON.stringify({ reg_id: reg_id }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            debugger;
            var data = JSON.parse(resp.d);
           
            $('#txtPatientNo').val(data.Mr_No);
            $('#txtpatient_no').val(data.pat_no);
            $('#txt_patname').val(data.Name);
            $('#txt_F_Name').val(data.FatherName);
            $('#txtage').val(data.Age);
            $('#txtnic').val(data.CNIC_Masked); // 👈 Updated!
            $('#txtmobile').val(data.Mobile);
            $('#ctl00_MainContent_lblNoOfDays').html(data.DaysSinceLatestVisit);
            $('#ctl00_MainContent_lblNoOfDays2').html(data.DaysSinceSecondLatestVisit);
            $('#txtAdrress').val(data.Address);
            $('#hdn_regid').val(data.Reg_PatientID);
            $('#follow_up').text(data.opdCount);
            $('#ddlmartialstatus').html(
                $('<option>', {
                    value: data.MaritalStatus,
                    text: data.MaritalStatus_text
                })
            );
            $('#ddlGender').html(
                $('<option>', {
                    value: data.Gender,
                    text: data.Gender_text
                })
            );




        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}


function addfunc() {
    debugger;

    AddNewPatient();




    debugger;

    $('#ClosePatientsSearchModel').click();
    fillmrno();
    setTimeout(function () {
        $('#txt_mobile').val(unmaskedValue);
    }, 100);
    $('#txt_name').focus();
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
    MaskedInput({
        elm: document.getElementById('txt_cnic'),
        format: '_____-_______-_',
        separator: '-'

    });
}
function clearPatient() {

    $('#txt_name').val("");
    $('#txt_relation').val("");
    $('#txt_dob').val("");
    $('#txt_cnic').val("");
    $('#txt_Address').val('');

    $('#updatePatient_Data').hide();
    $('#RevistPat').hide();
}
function ClearPatientResults() {
    while (tblPatientsResult.rows.length > 1) {
        tblPatientsResult.deleteRow(1);
    }
}
function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
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
    var actions = '';
    actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;display:flex;justify-content:center;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
    actions += '<a class="tooltips" style="color:#FDC303;font-size:16px;display:none" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-pencil-square-o"></i><span class="tooltiptxt">Edit</span></a>';
    cell.innerHTML = actions;


}

function AddPatientDetail(reg_id) {
    debugger;
    try {
        isAdd = true;
        window.location.href = "OPD.aspx?ID=" + reg_id + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}



function SearchPop_App() {
    debugger;
    $('#SearchModel_App').modal({
        backdrop: 'static'
    });

    $('#PatientsSearchModel').hide();
    FillList();
}


function FillList() {
    debugger;
    $('#tblResult tbody').empty();
    debugger;
    var SearchString = '';

    PageMethods.SearchAppointment(SearchString, OnFilter, OnFail);
}


function OnFilter(data) {

    ClearResults();

    for (var i = 0; i < data.length; i++) {
        AddResult_Appointment(data[i].Appointment_ID, data[i].Appointment_No, data[i].Patient_Name, data[i].Emp_name, data[i].Age, data[i].Phone, data[i].pat_id);
    }
}
var reg_id;
function AddResult_Appointment(Appointment_ID, Appointment_No, Patient_Name, Emp_name, Age, Phone, pat_id) {
    debugger;
    reg_id = pat_id;
    $('#hdnAptId').val(Appointment_ID);
    tblLength = tblResult.rows.length;

    var row = ibody.insertRow(-1);
    var cell;

    cell = row.insertCell(-1);
    cell.innerHTML = '<span spnPatID' + tblLength + '>' + Appointment_ID + '</span>';
    cell.className = "hide";

    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Appointment_No + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Patient_Name + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Emp_name + '</span>';
    cell = row.insertCell(-1);
    cell.innerHTML = '<span class="HRcontent">' + Age + '</span>';
    cell = row.insertCell(-1);

    cell.innerHTML = '<span class="HRcontent">' + Phone + '</span>';
    cell = row.insertCell(-1);


    var actions = ''
    actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;" href="#" onclick=AddDetail(' + Appointment_ID + ',' + reg_id + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
    cell.innerHTML = actions;
}
function OnFail(exc) {
    alert(exc.get_message());
}
function ClearResults() {
    while (tblResult.rows.length > 1) {
        tblResult.deleteRow(1);
    }
}
var appointment_id;
var reg_ids;
function AddDetail(id, reg_id) {
    debugger;
    Swal.fire({
        icon: 'success',
        title: 'Success!',
        text: 'Patient Proceed',
        showConfirmButton: false,
        timer: 2500,
        customClass: {
            popup: 'swal-big-popup',
            title: 'swal-big-title',
            htmlContainer: 'swal-big-text'
        }
    });
    appointment_id = id;
    reg_ids = reg_id;
    $('#CloseSearchModel_apt').click();
    $('#CloseSearchModel_apt').hide();
    $('#modal-backdrop in').hide();
    $('#hdn_aptid').attr('value', id);
    $('#hdn_aptid').val(appointment_id);
    $('#hdn_regid').val(reg_ids);
    debugger;
    AddPatientDetail_apt();


}

var isAdds = false;
function AddPatientDetail_apt() {
    debugger;
    try {
        isAdds = true;
        var apt_id = appointment_id;
        window.location.href = "OPD.aspx?ID=" + reg_ids + "&isAdd_apt=" + isAdds + "&apt_id=" + apt_id;

    } catch (err) {
        alert(err.message);
    }

}
function FillModePresentation() {
    var options = '<option value="0">Please Select</option>';

    $.ajax({
        url: 'OPD.aspx/ModePresentation',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;

            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#ddlMode_Of_Registration').html(options);
            $('#ddlMode_Of_Registration').val('01');
            $('#ddlMode_Of_Registration').attr('disabled', true);
        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}



function FillUserAccount() {
    var options;

    $.ajax({
        url: 'OPD.aspx/GetUserAccount',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
            });
            $('#ddlCashInHand').html(options);


        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}


var originalFee;

function Calc_Discount() {
    debugger;

    var disc_perc = $('#txtdiscount').val();
    var currentFee = $('#txtfees').val();
    var actualfees = $('#txtactualfee').val(currentFee);

    if (!originalFee) {
        originalFee = Number(currentFee);
    }

    if (disc_perc && !isNaN(disc_perc) && originalFee && !isNaN(originalFee)) {

        var discountAmount = (Number(disc_perc) / 100) * originalFee;
        var discountedFee = originalFee - discountAmount;

        $('#txtfees').val(discountedFee.toFixed(0));
    } else {
        $('#txtfees').val(originalFee.toFixed(0));
    }
}


function getGeneralFee() {
    $.ajax({
        url: 'OPD.aspx/GetFees',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (resp) {
            debugger;
            var data = JSON.parse(resp.d);
            var Category = $('#ddlPatient_Type').val();
            if (Category == "06") {
                $('#txtfees').val("0")
            }
            else {
                $('#txtfees').val(data.Code);
            }


        },
        error: function (response) {
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: response.responseText,
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });

            console.error("AJAX Error: ", response);
        }
    });

}




function fillArea() {
    var options = '<option value="0">Please Select</option>';

    $.ajax({
        url: 'OPD.aspx/GetArea',
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
var editrights;
function AllowOPdEdit() {
    debugger;
    $.ajax({
        type: "POST",
        url: "OPD.aspx/checlkeditRights",
        data: "",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (data) {
            debugger;
            editrights = data.d;

            if (editrights == "true") {
                console.log(editrights);
                $('#btnsave').attr('disabled', false);
            }
            else {
                $('#btnsave').attr('disabled', false);
            }

        },
        failure: function () {
            alert("Error");
        }
    });


}







debugger;
function CalculateDateOfBirth() {
    debugger;
    var now = moment();
    var year = $('#txt_dob').val();
    var calculateDate = now.subtract(year, 'years');
    var finalDate = calculateDate.format("DD/MM/YYYY");
    var $datepicker = $('#txtAge_yearss');

    $datepicker.datepicker({
        changeMonth: true,
        changeYear: true,
        yearRange: "-50:+50",
        dateFormat: "dd/mm/yy"
    });

    $('#txtAge_yearss').unmask("99/99/9999");
    $datepicker.datepicker('setDate', finalDate);
    $('#txtAge_yearss').unmask("99/99/9999");
    $("#txtAge_yearss").mask("99/99/9999");
}
function fillmrno() {
    var data = {};

    $.ajax({
        type: "POST",
        url: "OPD.aspx/Getmr",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            debugger;
            var max_mr = data.d;
            $('#txt_Mrno').val('New');
        },
        error: function (xhr, status, error) {
            console.error("AJAX request failed:", status, error);
        }
    });
}
function SavePatient() {
    debugger;
    var Prefix_PatientName = $('#ddl_name').val();
    var PatientName = $('#txt_name').val();
    var PatientID = $('#hdfPatient_ID').val();
    var Full_Name = Prefix_PatientName + PatientName;
    var RelationType = $('#ddlRelation').val();
    var Relation = $('#txt_relation').val();
    var Gender = $('#ddl_Gender').val();
    var Mobile = $('#txt_mobile').val();
    var Age = $('#txt_dob').val();
    var Date_Of_Birth = $('#txtAge_yearss').val();
    var CNIC = $('#txt_cnic').val();
    var Address = $('#txt_Address').val();
    var houseno = $('#txt_house').val();
    var stno = $('#txtstrm').val();
    var city = $('#txtcity :selected').text();
    var area = $('#txtarea :selected').text();
    var city_val = $('#txtcity').val();
    var area_val = $('#txtarea').val();
    var martail_status = $('#ddl_status').val();
    var Country = $('#ddlCountry :selected').val();
    var Province = $('#ddl_Province :selected').val();

    if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || houseno == "" || city_val == "0" || area_val == "0")) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please Enter compulsory Fields',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        $('#SavePatient_Data').attr('disabled', false);
        return;
    }

    var data = {
        Full_Name: Full_Name,
        RelationType: RelationType,
        Relation: Relation,
        Gender: Gender,
        Mobile: Mobile,
        Date_Of_Birth: Date_Of_Birth,
        CNIC: CNIC,
        Address: Address,
        houseno: houseno,
        stno: stno,
        city: city,
        city_val: city_val,
        area_val: area_val,
        area: area,
        PatientID: PatientID,
        martail_status: martail_status,
        Age: Age,
        "Country": Country,
        "Province": Province,
    };

    console.log(data);

    $.ajax({
        type: "POST",
        url: "OPD.aspx/SavePatientDetail",
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            debugger;
            var ini_patientID = response.d;

            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'Your Record Saved Successfully.',
                showConfirmButton: false,
                timer: 2500,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            get_pat_initial_info(ini_patientID);
        },
        error: function (xhr, status, error) {
            console.error("Error: ", error);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Error while saving data. Please try again',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
        }
    });
} function SaveData() {
    debugger;

    var regid = $('#hdn_regid').val();
    var appid = $('#hdn_aptid').val();
    var opdid = $('#hdn_opdId').val();
    var patient_no = $('#txtPatientNo').val();
    var pat_no = $('#txtpatient_no').val();
    var Full_Name = $('#txt_patname').val();
    var modeof_presentation = $('#ddlMode_Of_Registration').val();
    var pat_category = $('#ddlPatient_Type').val();
    var Father_name = $('#txt_F_Name').val();
    var Age = $('#txtage').val();
    var Gender = $('#ddlGender').val();
    var NIC = $('#txtnic').val();
    var MobileNo = $('#txtmobile').val();
    var Martial_Status = $('#ddlmartialstatus').val();
    var Address = $('#txtAdrress').val();
    var Department = $('#ddlDepartment').val();
    var hdnDepartment = $("#hdn_dep_id").val();
    var doctor = $('#ddldoctor').val();
    var employee = $('#txtemployee').val();
    var employee_id_raw = $('#Employe_id').val();
    var employee_id = employee_id_raw === "" || !employee_id_raw ? null : parseInt(employee_id_raw);
    var panel = $('#ddlpanel').val();
    var reffer_no = $('#txtreferenceno').val();
    var EmployeeName = $('#empname').val();
    var EmployeeDept = $('#EmpDept').val();
    var StudentName = $('#txtStdName').val();
    var Fees = parseFloat($('#txtfees').val()) || 0;
    var Actual_Fees = parseFloat($('#txtactualfee').val()) || 0;

    var discount = parseFloat($('#txtdiscount').val()) || 0;
    var Doc_Share = parseFloat($('#hdnDocshare').val()) || 0;
    var Hosp_share = parseFloat($('#hdnhospShare').val()) || 0;
    var dependent = $('#txtdependent').val();
    var rollno = $('#ddlrollno').val();
    var Class = $('#ddlclass').val();
    var section = $('#ddlsection').val();
    var FilterClinic = $('#ddlFilterClnic').val();
    var Services = $('#ddlServices').val();
    var Cashier = $('#ddlcashier').val();
    var accountid = $('#ddlCashInHand').val();
    var IssueCard = $('#chckcardissue').prop('checked');
    var FreeCheck = $('#chckfreecheck').prop('checked');

    // ✅ CORRECT: Get VALUE of hidden field
    var hfAntiForgery = $('#ctl00_MainContent_hfAntiForgery').val();

    // 🚨 VALIDATIONS (unchanged)
    if (!patient_no || patient_no === "0") {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a Patient.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }
    if (!pat_category || pat_category === "0") {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a patient category.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }
    if ((pat_category === "01" || ["02", "04", "05"].includes(pat_category)) && (!Department || Department === "0")) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a department for the selected patient category.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }

    if (["02", "03"].includes(pat_category) && (!doctor || doctor === "0")) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a doctor for the selected patient category.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }

    if (pat_category === "03" && (!panel || panel === "0")) {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a panel for the selected patient category.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }

    if (!accountid || accountid === "0") {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select a Cash In Hand.',
            showConfirmButton: false,
            timer: 2000,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        return;
    }

    // ✅ FIXED: Send token under CORRECT property name → "AntiForgeryToken"
    var data = {
        regid: regid,
        appid: appid,
        patient_no: patient_no,
        pat_no: pat_no,
        Full_Name: Full_Name,
        modeof_presentation: modeof_presentation,
        pat_category: pat_category,
        Father_name: Father_name,
        Age: Age,
        Gender: Gender,
        NIC: NIC,
        MobileNo: MobileNo,
        Martial_Status: Martial_Status,
        Address: Address,
        Department: Department,
        hdnDepartment: hdnDepartment,
        doctor: doctor,
        employee: employee,
        employee_id: employee_id,
        panel: panel,
        reffer_no: reffer_no,
        Fees: Fees,
        Actual_Fees: Actual_Fees,
        discount: discount,
        Doc_Share: Doc_Share,
        Hosp_share: Hosp_share,
        dependent: dependent,
        rollno: rollno,
        Class: Class,
        section: section,
        FilterClinic: FilterClinic,
        Services: Services,
        Cashier: Cashier,
        accountid: accountid,
        IssueCard: IssueCard,
        FreeCheck: FreeCheck,
        AntiForgeryToken: hfAntiForgery, // ✅ THIS WAS THE BUG — NOW FIXED
        EmployeeName: EmployeeName,
        EmployeeDept: EmployeeDept,
        StudentName: StudentName
    };

    // 👇 Optional: Log to verify
    console.log("AntiForgeryToken being sent:", data.AntiForgeryToken);
    console.log("Data being sent:", data);

    $.ajax({
        type: "POST",
        url: "OPD.aspx/SaveOpdData",
        data: JSON.stringify({ data: data, opdid: opdid }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            debugger;
            var patientID = response.d;
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'Your Record Saved Successfully',
                showConfirmButton: false,
                timer: 2500,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            var url = "../../ReportViewer.aspx?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=" + patientID;
            window.open(url, '_blank');
            window.location.href = "OPDView.aspx";
        },
        error: function (xhr, status, error) {
            console.error("Error: ", error);
            console.log("Response Text: ", xhr.responseText);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Error while saving data. Please try again.',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
        }
    });
}
function get_pat_initial_info(ini_patientID) {
    debugger;
    try {
        isAdd = true;
        window.location.href = "OPD.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}

function loadDepartment(Doc) {
    var opdid = $('#hdn_opdId').val()
    if (opdid != "" || opdid != "") {

    }
    else {
        $.ajax({
            type: "POST",
            url: "OPD.aspx/LoadDepartment",
            data: JSON.stringify({ Doc: Doc }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (resp) {
                debugger;
                var data = JSON.parse(resp.d);
                $('#ddlDepartment').val(data.Department);
                $('#ddlDepartment').attr('disabled', true);

            },
            error: function (response) {
                alert("Error: " + response.responseText);
                console.error("AJAX Error: ", response);
            }
        });
    }

}
function loadEmpData() {
    var employeeid = $('#Employe_id').val();
    var opdid = $('#hdn_opdId').val()
    if (opdid != "" || opdid != "") {

    } else {
        $.ajax({
            type: "POST",
            url: "OPD.aspx/LoadEmplData",
            data: JSON.stringify({ employeeid: employeeid }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (resp) {
                debugger;
                var data = JSON.parse(resp.d);

                $('#txtdependent').val(data.Dependent);
                $('#txtdependent').attr('disabled', true);

            },
            error: function (response) {
                alert("Error: " + response.responseText);
                console.error("AJAX Error: ", response);
            }
        });
    }

}
function get_totalpatient() {
    debugger;
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'OPD.aspx/GetCount',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            debugger;
            var data = response.d ? JSON.parse(response.d) : response;

            $('#ctl00_MainContent_lbltotpat').html(data);


        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;

}
function getpanelRate() {
    var panelid = $('#ddlpanel').val();
    $.ajax({
        type: "POST",
        url: "OPD.aspx/LoadPanelInfo",
        data: JSON.stringify({ panelid: panelid }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            debugger;
            var data = JSON.parse(resp.d);

            $('#txtfees').val(data.Fees);
            $('#txtfees').attr('disabled', true);
        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}

function loadPatientDetail(OPDID) {
    $('#btnsave').val('Update');
    $('#btnsave').attr('disabled', true);
    AllowOPdEdit();

    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetPatientDetail",
        data: JSON.stringify({ OPDID: OPDID }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            debugger;
            var data = JSON.parse(resp.d);
            var stat = data.status;
            if (stat == "Approved") {
                $('#divapprove').hide();
                $('#divvoucher').show();
            }
            console.log(data);
            $('#txtPatientNo').val(data.mr_no_sequence).attr('disabled', true);
            $('#hdn_opdId').val(data.opdid);
            $('#txt_opd_no').val(data.Opd_No).attr('disabled', true);
            $('#txt_patname').val(data.Name).attr('disabled', true);
            $('#txt_F_Name').val(data.Father_Name).attr('disabled', true);
            $('#ddlMode_Of_Registration').val(data.Mode_Of_Registration).attr('disabled', true);
            $('#txtage').val(data.Age_years).attr('disabled', true);

            $('#txtnic').val(data.CNIC_Masked).attr('disabled', true);
            $('#EmpDept').val(data.EmployeeDept).attr('disabled', true);
            $('#txtmobile').val(data.Mobile1).attr('disabled', true);
            $('#txtStdName').val(data.StudentName).attr('disabled', true);

            $('#txtAdrress').val(data.Permanent_Address).attr('disabled', true);
            $('#chckcardissue').prop('checked', data.Card_Issued).attr('disabled', true);
            $('#chckfreecheck').prop('checked', data.free_check).attr('disabled', true);
            $('#txtdiscount').val(data.discount_amt).attr('disabled', true);
            $('#txtdependent').val(data.Dependent).attr('disabled', true);
            $('#txtemployee').val(data.Employee_Name).attr('disabled', true);
            $('#txtreferenceno').val(data.Refference_No).attr('disabled', true);







            $('#ddlmartialstatus').html(
                $('<option>', {
                    value: data.MaritalStatus,
                    text: data.MaritalStatus_text
                })
            ).attr('disabled', true);

            $('#ddlGender').html(
                $('<option>', {
                    value: data.Gender,
                    text: data.Gender_text
                })
            ).attr('disabled', true);

            $('#ddlFilterClnic').html(
                $('<option>', {
                    value: data.FilterClinic,
                    text: data.Clinic_text
                })
            ).attr('disabled', true);

            $('#ddlServices').html(
                $('<option>', {
                    value: data.Service_id,
                    text: data.Service_text
                })
            ).attr('disabled', true);

            $('#ddlPatient_Type').html(
                $('<option>', {
                    value: data.Patient_Type,
                    text: data.Type_text
                })
            ).attr('disabled', true);

            $('#ddlPatient_Type').off('change').on('change', function () {
                loaddata();
            });


            loaddata();
            $('#ddlDepartment').html(
                $('<option>', {
                    value: data.Patient_Main_Category,
                    text: data.Category_text
                })
            ).attr('disabled', true);
            $('#ddldoctor').html(
                $('<option>', {
                    value: data.PanelCompany,
                    text: data.Doc_text
                })
            ).attr('disabled', true);
            $('#ddlpanel').html(
                $('<option>', {
                    value: data.PanelCompany,
                    text: data.PanelCompany_text
                })
            ).attr('disabled', true);

            $('#Employe_id').html(
                $('<option>', {
                    value: data.employee_ID,
                    text: data.employee_text
                })
            ).attr('disabled', true);
            $('#ddlrollno').val(data.RollNo).trigger('change').attr('disabled', true);
            $('#ddlclass').val(data.Class).trigger('change').attr('disabled', true);
            $('#ddlsection').val(data.Section).trigger('change').attr('disabled', true);
            $('#ddlCashInHand').val(data.account_id).trigger('change').attr('disabled', true);




            $('#txtfees').val(data.Receipt_Amount).attr('disabled', true);
            $('#txtactualfee').val(data.Actual_amount);
            debugger;
            if (stat != "Approved") {
                $('#divapprove').show();
            }

        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}


$(document).ready(function () {
    MaskedInput({
        elm: document.getElementById('txt_mobile'),
        format: '+92__________',
        separator: '+92 -'
    });

});



function FillEmergencyPatientsList() {
    debugger;
    $('#tblEmergencyResult tbody').empty();

    var SearchString = '';

    PageMethods.SearchEmergencyPatients(SearchString, OnFilterEmergencyPatients, OnFailEmergencyPatients);
}

function OnFilterEmergencyPatients(data) {

    ClearEmergencyPatientResults();
    for (var i = 0; i < data.length; i++) {
        AddEmergencyPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].Father_Name, data[i].NIC, data[i].Mobile1);
    }
}



function OnFailEmergencyPatients(exc) {
    alert(exc.get_message());
}

function ClearEmergencyPatientResults() {
    $('#tblEmergencyResult tbody').empty();
}

function AddEmergencyPatientsResult(Patient_ID, Patient_No, Full_Name, Father_Name, NIC, Mobile1) {
    var tblLength = tblEmergencyResult.rows.length;
    var row = EmergencyPatientsBody.insertRow(-1);
    var cell;

    cell = row.insertCell(-1);
    cell.innerHTML = '<span id="spnPatID' + tblLength + '">' + Patient_ID + '</span>';
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
    var actions = '';
    actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;display:flex;justify-content:center;" href="#" onclick=AddEmergencyPatientDetail(' + Patient_ID + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
    actions += '<a class="tooltips" style="color:#FDC303;font-size:16px;display:none" href="#" onclick=EditEmergencyPatientDetail(' + Patient_ID + ')><i class="fa fa-pencil-square-o"></i><span class="tooltiptxt">Edit</span></a>';
    cell.innerHTML = actions;
}

function AddEmergencyPatientDetail(reg_id) {
    debugger;
    try {
        isAdd = true;
        window.location.href = "OPD.aspx?Reffered_id=" + reg_id + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}


