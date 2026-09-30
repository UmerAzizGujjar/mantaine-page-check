
$(document).ready(function () {
    isCNICValidationRequired();
    $('.show').show();
    $('#divcard').hide();
    $('#divapprove').hide();
    $('#btn-opdprint').hide();
    /*  $('#divvoucher').hide();*/
    $("#tabs").on('click', 'li', function () {
        var activeTab = $(this).find('a').html();
        if (activeTab == "Contact Information") $("#ctl00_MainContent_txtTemporary_Address").focus();

    });

    $('#btnsearchpatlist').click(function () {
        $("#PatientsSearchModel").modal('show');
        FillPatientsList();
    });

    $('#btnsearchEmergencylist').click(function () {
        $("#SearchEmergencyPatients").modal('show');
        FillEmergencyPatientsList();
    });

    $('#txtReferEmergencySearch').off('input').on('input', function () {
        FillReferPatientsList();
    });
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

    $("#txtSearchmodal").keypress(function (event) {
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
        { id: '#ddlpanel', method: 'GetPanel' },
        { id: '#ddlcashier', method: 'GetCasher' }

    ];

    dropdowns.forEach(item => {
        const $element = $(item.id);

        const isInsideModal = $element.closest('#PatientModel').length > 0;

        if (!isInsideModal) {
            // Non-modal: use Select2 as before
            $element.select2();
            $element.off('select2:open').on('select2:open', function () {
                fillDropdown($element, item.method);
            });
        } else {
            // ? MODAL: Use native 'focus' to load data ONCE
            $element.off('focus.fill').on('focus.fill', function () {
                if (!$element.data('filled')) {
                    fillDropdown($element, item.method);
                }
            });
        }

        // ?? Keep ALL your existing logic exactly as before
        if (item.id === '#ddlPatient_Type') {
            $element.prop('disabled', false);
            // Since modal uses native select, bind to 'change', not 'select2:select'
            const changeHandler = function () {
                loaddata();
                //$(this).prop('disabled', true);
            };
            if (!isInsideModal) {
                $element.off('select2:select').on('select2:select', changeHandler);
            } else {
                $element.off('change').on('change', changeHandler);
            }
        }

        if (item.id === '#ddlDepartment') {
            $element.prop('disabled', false);
            const deptHandler = function () {
                var selectedDept = $('#ddlDepartment').val();
                loadCostCentersByDepartment(selectedDept);
                checkOutPatientDischarge(selectedDept, function(hasActiveOPD) {
                    if (!hasActiveOPD) {
                        loaddoctor();
                    }
                });
            };
            if (!isInsideModal) {
                $element.off('select2:select').on('select2:select', deptHandler);
            } else {
                $element.off('change').on('change', deptHandler);
            }
        }

        if (item.id === '#ddldoctor') {
            const doctorHandler = function (e) {
                var selectedVal = $(this).val();
                if (selectedVal) {
                    loadFee();
                }
            };
            if (!isInsideModal) {
                $element.off('select2:select').on('select2:select', doctorHandler);
                $element.off('select2:open');
            } else {
                $element.off('change').on('change', doctorHandler);
            }
        }


    });

    $('#txt_mobile').on('focus', function () {
        var input = this;
        setTimeout(function () {
            if (input.setSelectionRange) {
                input.setSelectionRange(3, 3);
            } else if (input.createTextRange) {
                var range = input.createTextRange();
                range.collapse(true);
                range.moveEnd('character', 3);
                range.moveStart('character', 3);
                range.select();
            }
        }, 0);
    });

    MaskedInput({
        elm: document.getElementById('txt_cnic'),
        format: '_____-_______-_',
        separator: '-'

    });

    MaskedInput({
        elm: document.getElementById('txt_OtherCnic'),
        format: '_____-_______-_',
        separator: '-'

    });


    $('#txt_OtherCnic').attr('placeholder', '_____-_______-_');

    $('#txt_cnic').attr('placeholder', '_____-_______-_');

    $('#txt_cnic').on('focus', function () {
        var input = this;
        setTimeout(function () {
            if (input.setSelectionRange) {
                input.setSelectionRange(0, 0);
            } else if (input.createTextRange) {
                var range = input.createTextRange();
                range.collapse(true);
                range.moveEnd('character', 0);
                range.moveStart('character', 0);
                range.select();
            }
        }, 0);
    });

    $('#txt_OtherCnic').on('focus', function () {
        var input = this;
        setTimeout(function () {
            if (input.setSelectionRange) {
                input.setSelectionRange(0, 0);
            } else if (input.createTextRange) {
                var range = input.createTextRange();
                range.collapse(true);
                range.moveEnd('character', 0);
                range.moveStart('character', 0);
                range.select();
            }
        }, 0);
    });



    const defaultValues = {
        '#ddlCountry': '01',
        '#ddl_Province': '01',
        '#txtcity': '0001',
        '#txtarea': '001'
    };

    function setDefaultDropdownValue(selector, defaultValue) {
        const $el = $(selector);
        if ($el.length === 0) return;

        const methodMap = {
            '#ddlCountry': 'GetCountry',
            '#ddl_Province': 'GetProvince',
            '#txtcity': 'GetCity',
            '#txtarea': 'GetArea'
        };

        const method = methodMap[selector];
        if (!method) return;

        fillDropdown($el, method, function () {
            $el.val(defaultValue).trigger('change');
            if ($el.hasClass('select2-hidden-accessible')) {
                $el.trigger('change.select2');
            }
        });
    }

    Object.keys(defaultValues).forEach(selector => {
        setDefaultDropdownValue(selector, defaultValues[selector]);
    });

    showhide();
    FillModePresentation();
    get_totalpatient();
    FillUserAccount();
    FillCashier();

});
function fillDropdown($dropdown, methodName, callback = null) {
    if ($dropdown.data('filled')) {
        if (callback) callback();
        return;
    }

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

                if ($dropdown.hasClass('select2-hidden-accessible') && $dropdown.select2('isOpen')) {
                    $dropdown.select2('close').select2('open');
                }

                if (callback) callback();
            } catch (e) {
                console.error(`Error parsing data from ${methodName}:`, e);
                $dropdown.data('filled', false);
                if (callback) callback();
            }
        },
        error: function (xhr, status, error) {
            console.error(`Error fetching ${methodName}:`, error);
            $dropdown.data('filled', false);
            if (callback) callback();
        }
    });
}

function loadCostCentersByDepartment(department) {
    var $cc = $('#ddlCostCenter');
    if (!$cc.length) return;

    if (!department || department === '0' || department === '') {
        $cc.html('<option value="0">Select Cost Center</option>');
        if ($cc.hasClass('select2-hidden-accessible')) { $cc.trigger('change'); }
        return;
    }

    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetCostCenterByDepartment",
        data: JSON.stringify({ department: department }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var data = [];
            try { data = JSON.parse(response.d); } catch (e) { data = []; }
            var options = '<option value="0">Select Cost Center</option>';
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $cc.html(options);
            var realOptions = $cc.find('option').filter(function () { return $(this).val() !== '0'; });
            if (realOptions.length === 1) {
                $cc.val(realOptions.val());
            } else {
                $cc.val('0');
            }
            if ($cc.hasClass('select2-hidden-accessible')) { $cc.trigger('change'); }
        },
        error: function (xhr, status, error) {
            console.error("Error loading cost centers by department:", error);
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
function Get_Pat_Info_Reffer(reg_id) {
    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetBasicInfoOFReffer",
        data: JSON.stringify({ reg_id: reg_id }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            var data = JSON.parse(resp.d);
            $('#txtPatientNo').val(data.Mr_No);
            $('#txtpatient_no').val(data.pat_no);
            $('#txt_patname').val(data.Name);
            $('#txt_F_Name').val(data.FatherName);
            $('#txtage').val(data.Age);
            $('#txtnic').val(data.CNIC_Masked);
            $('#txtmobile').val(data.Mobile);
            $('#txtAdrress').val(data.PermanentAdrress);
            $('#hdn_regid').val(data.Reg_PatientID);
            $('#ctl00_MainContent_lblNoOfDays').html(data.DaysSinceLatestVisit);
            $('#ctl00_MainContent_lblNoOfDays2').html(data.DaysSinceSecondLatestVisit);


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
function FillPatientsList() {
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
            var data = JSON.parse(resp.d);
            $('#txtPatientNo').val(data.Mr_No);
            $('#txtpatient_no').val(data.pat_no);
            $('#txt_patname').val(data.Name);
            $('#txt_F_Name').val(data.FatherName);
            $('#txtage').val(data.Age);
            $('#txtnic').val(data.CNIC_Masked);
            $('#txtmobile').val(data.Mobile);
            $('#txtAdrress').val(data.PermanentAdrress);
            $('#hdn_regid').val(data.Reg_PatientID);
            $('#hdn_aptid').val(apt_Id);
            $('#hdnAppointmentType').val(data.AppointmentType);
            $('#ctl00_MainContent_lblNoOfDays').html(data.DaysSinceLatestVisit);
            $('#ctl00_MainContent_lblNoOfDays2').html(data.DaysSinceSecondLatestVisit);


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
            var data = JSON.parse(resp.d);

            $('#txtPatientNo').val(data.Mr_No);
            $('#txtpatient_no').val(data.pat_no);
            $('#txt_patname').val(data.Name);
            $('#txt_F_Name').val(data.FatherName);
            $('#txtage').val(data.Age);
            $('#txtnic').val(data.CNIC_Masked); // ?? Updated!
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

            checkcardvalidation();


        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}


function addfunc() {

    AddNewPatient();





    $('#ClosePatientsSearchModel').click();
    fillmrno();
    setTimeout(function () {
        $('#txt_mobile').val(unmaskedValue);
    }, 100);
    $('#txt_name').focus();
}
function AddNewPatient() {
    $('#ddl_pnl_cpy').next(".select2-container").hide();

    clearPatient();
    $('#hdfPatient_ID').val('(New)');

    $('#PatientModel').modal({
        backdrop: 'static'
    });
    $("#ddl_name").focus();
    
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
    actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;display:flex;justify-content:center;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i></a>';
    actions += '<a class="tooltips" style="color:#FDC303;font-size:16px;display:none" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-pencil-square-o"></i><span class="tooltiptxt">Edit</span></a>';
    cell.innerHTML = actions;


}

function AddPatientDetail(reg_id) {
    try {
        isAdd = true;
        window.location.href = "OPD.aspx?ID=" + reg_id + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}



function SearchPop_App() {
    $('#SearchModel_App').modal({
        backdrop: 'static'
    });

    $('#PatientsSearchModel').hide();
    FillList();
}


function FillList() {
    $('#tblResult tbody').empty();
    var SearchString = '';

    PageMethods.SearchAppointment(SearchString, OnFilter, OnFail);
}


function FillList() {
    $('#tblResult tbody').empty();
    var SearchString = '';

    PageMethods.SearchAppointment(SearchString, OnFilter, OnFail);
}


function OnFilter(data) {

    ClearResults();

    for (var i = 0; i < data.length; i++) {
        AddResult_Appointment(data[i].Appointment_ID, data[i].Appointment_No, data[i].App_Date, data[i].Patient_Name, data[i].Emp_name, data[i].Age, data[i].Phone, data[i].pat_id);
    }
}
var reg_id;
function AddResult_Appointment(Appointment_ID, Appointment_No, App_Date, Patient_Name, Emp_name, Age, Phone, pat_id) {
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
    cell.innerHTML = '<span class="HRcontent">' + App_Date + '</span>';
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
    AddPatientDetail_apt();


}

var isAdds = false;
function AddPatientDetail_apt() {
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

function FillCashier() {

    $.ajax({
        url: 'OPD.aspx/GetCasher',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {

            var data = response.d ? JSON.parse(response.d) : response;
            var options = '';

            if (data.length > 0) {
                $.each(data, function (i, value) {
                    options += '<option value="' + value.Cashier_ID + '" selected>'
                        + value.Cashier_Name +
                        '</option>';
                });

                $('#ddlcashier').html(options).prop('disabled', true);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error fetching cashier:', error);
        }
    });
}


var originalFee;

function Calc_Discount() {

    var disc_perc = $('#txtdiscount').val();
    var actualFee = $('#txtactualfee').val();
    if (!actualFee || actualFee == 0) {
        actualFee = $('#txtfees').val();
        $('#txtactualfee').val(actualFee);
    }

    if (disc_perc && !isNaN(disc_perc) && disc_perc !== "" && actualFee && !isNaN(actualFee) && parseFloat(actualFee) > 0) {
        var discountPercent = parseFloat(disc_perc);
        var originalFee = parseFloat(actualFee);
        if (discountPercent > 100) {
            discountPercent = 100;
            $('#txtdiscount').val(100);
        }

        var discountAmount = (discountPercent / 100) * originalFee;
        var discountedFee = originalFee - discountAmount;
        discountedFee = Math.round(discountedFee * 100) / 100;

        $('#txtfees').val(discountedFee.toFixed(2));
    } else if (actualFee && !isNaN(actualFee)) {
        $('#txtfees').val(parseFloat(actualFee).toFixed(2));
    } else {
        $('#txtfees').val('0');
    }
}


function getGeneralFee() {
    $.ajax({
        url: 'OPD.aspx/GetFees',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (resp) {
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
    $.ajax({
        type: "POST",
        url: "OPD.aspx/checlkeditRights",
        data: "",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: true,
        success: function (data) {
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







function CalculateDateOfBirth() {
    var Numbers = $('#PrefixAge').val();
    var CalDob = $('#txt_dob').val();

    if (!CalDob || isNaN(CalDob) || CalDob <= 0) {
        $('#txtAge_yearss').val('');
        return;
    }

    var now = moment();
    var dob;

    if (Numbers === "Year") {
        dob = now.subtract(CalDob, 'years');
    } else if (Numbers === "Month") {
        dob = now.subtract(CalDob, 'months');
    } else if (Numbers === "Day") {
        dob = now.subtract(CalDob, 'days');
    } else {
        $('#txtAge_yearss').val('');
        return;
    }

    var finalDate = dob.format("DD/MM/YYYY");

    var $datepicker = $('#txtAge_yearss');
    if (!$datepicker.hasClass('hasDatepicker')) {
        $datepicker.datepicker({
            changeMonth: true,
            changeYear: true,
            yearRange: "-100:+0",
            dateFormat: "dd/mm/yy"
        });
    }

    $datepicker.datepicker('setDate', dob.toDate());

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
            var max_mr = data.d;
            $('#txt_Mrno').val('New');
        },
        error: function (xhr, status, error) {
            console.error("AJAX request failed:", status, error);
        }
    });
}
function SavePatient() {
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
    var OtherCNIC = $('#txt_OtherCnic').val();
    var Address = $('#txt_house').val();
    var stno = $('#txtstrm').val();
    var city = $('#txtcity :selected').text();
    var area = $('#txtarea :selected').text();
    var city_val = $('#txtcity').val();
    var area_val = $('#txtarea').val();
    var martail_status = $('#ddl_status').val();
    var Country = $('#ddlCountry :selected').val();
    var Province = $('#ddl_Province :selected').val();
    var cardfee = $('#txtCardFee').val();

    if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || city_val == "0")) {
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

    var isCNICRequired = isCNICValidationRequired();
    if (isCNICRequired) {
        var isCNICEmpty = !CNIC || CNIC === "" || CNIC === "_____-_______-_";
        var isOtherCNICEmpty = !OtherCNIC || OtherCNIC === "" || OtherCNIC === "_____-_______-_";

        if (isCNICEmpty && isOtherCNICEmpty) {
            Swal.fire({
                icon: 'warning',
                title: 'CNIC Required!',
                text: 'Please enter  CNIC or Other CNIC',
                confirmButtonText: 'OK',
                confirmButtonColor: '#3085d6'
            });
            $('#SavePatient_Data').attr('disabled', false);
            return;
        } else {
            if (!isCNICEmpty && CNIC !== "_____-_______-_") {
                var cnicPattern = /^\d{5}-\d{7}-\d$/;
                if (!cnicPattern.test(CNIC)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid CNIC Format!',
                        text: 'Please enter valid CNIC format (XXXXX-XXXXXXX-X)',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#d33'
                    });
                    $('#SavePatient_Data').attr('disabled', false);
                    return;
                }
            }
            if (!isOtherCNICEmpty && OtherCNIC !== "_____-_______-_") {
                var otherCnicPattern = /^\d{5}-\d{7}-\d$/;
                if (!otherCnicPattern.test(OtherCNIC)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid Other CNIC Format!',
                        text: 'Please enter valid CNIC format (XXXXX-XXXXXXX-X)',
                        confirmButtonText: 'OK',
                        confirmButtonColor: '#d33'
                    });
                    $('#SavePatient_Data').attr('disabled', false);
                    return;
                }
            }
        }
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
        "OtherCNIC": OtherCNIC,
        "cardfee": cardfee,
    };


    $.ajax({
        type: "POST",
        url: "OPD.aspx/SavePatientDetail",
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d === "CNIC_EXISTS") {
                Swal.fire({
                    title: 'CNIC Already Exists!',
                    text: 'A patient with this CNIC is already registered.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                }).then(function () {
                    $('#SavePatient_Data').attr('disabled', false);
                });
                return;
            }
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
            Approve(ini_patientID)
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
}

function Approve(pat_id) {
    PageMethods.approvepatient(pat_id, function (Tests) {
        var message = JSON.parse(Tests);
        if (message[0].Message != null || message[0].Message != "") {
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: message[0].Message,
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


function SaveData() {

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
    var CostCenter = $('#ddlCostCenter').val();

    var hdnDepartment = $("#hdn_dep_id").val();
    var doctor = $('#ddldoctor').val();
    var employee = $('#txtemployee').val();
    var employee_id_raw = $('#Employe_id').val();
    var employee_id = employee_id_raw === "" || !employee_id_raw ? null : parseInt(employee_id_raw);
    var panel = $('#ddlpanel').val();
    var reffer_no = $('#txtreferenceno').val();
    var hdnAppointmentType = $('#hdnAppointmentType').val();
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
    var Remarks = $('#txtremarks').val() || "";
    var bank_cash = $('#ddlbankcash').val();
    var bank_account_id = $('#ddlbank').val();

    if (discount > 0 && (!Remarks || Remarks.trim() === "")) {
        Swal.fire({
            icon: 'error',
            title: 'Remarks Required',
            text: 'Please enter remarks when discount is given.',
            showConfirmButton: false,
            timer: 2500,
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        });
        $('#txtremarks').focus();
        return;
    }

    if (discount < 100.0 && Fees == 0.0) {

        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Fee Should Not be Zero',
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

    if (Department == "101" && FilterClinic == "0") {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'Please select Filter Clinic.',
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


    // ? CORRECT: Get VALUE of hidden field
    var hfAntiForgery = $('#ctl00_MainContent_hfAntiForgery').val();

    // ?? VALIDATIONS (unchanged)
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

    if (bank_cash === '02' && (!bank_account_id || bank_account_id === '')) {
        Swal.fire({
            icon: 'warning',
            title: 'Bank Account Required!',
            text: 'Please select a bank account for Bank payment.',
            confirmButtonText: 'OK',
            confirmButtonColor: '#3085d6'
        });
        return;
    }

    var isPatientAdmitted = false;

    $.ajax({
        type: "POST",
        url: "OPD.aspx/OPDSlip",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            var validationCode = JSON.parse(response.d);

            if (validationCode === "01") {

                $.ajax({
                    type: "POST",
                    url: "OPD.aspx/CheckPatientAdmissionStatus",
                    data: JSON.stringify({ regPatId: parseInt(regid) }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (admissionResponse) {
                        var statusData = JSON.parse(admissionResponse.d);

                        if (statusData.isAdmitted) {
                            isPatientAdmitted = true;
                            Swal.fire({
                                icon: 'warning',
                                title: 'Patient Admitted',
                                text: 'This patient is currently admitted in ' + statusData.location + ' since ' + statusData.admissionDate + '. You cannot save this OPD form.',
                                confirmButtonText: 'OK'
                            });
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Admission check failed", error);
                    }
                });
            }
        },
        error: function (xhr, status, error) {
            console.error("Validation check failed", error);
        }
    });


    if (isPatientAdmitted) {
        return;
    }

    // ? FIXED: Send token under CORRECT property name ? "AntiForgeryToken"
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
        CostCenter: CostCenter,
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
        hdnAppointmentType: hdnAppointmentType,
        Services: Services,
        Cashier: Cashier,
        accountid: accountid,
        IssueCard: IssueCard,
        FreeCheck: FreeCheck,
        AntiForgeryToken: hfAntiForgery, // ? THIS WAS THE BUG � NOW FIXED
        EmployeeName: EmployeeName,
        EmployeeDept: EmployeeDept,
        StudentName: StudentName,
        Remarks: Remarks,
        bank_cash: bank_cash,
        bank_account_id: bank_account_id
    };

    // ?? Optional: Log to verify
    console.log("AntiForgeryToken being sent:", data.AntiForgeryToken);
    console.log("Data being sent:", data);

    $.ajax({
        type: "POST",
        url: "OPD.aspx/SaveOpdData",
        data: JSON.stringify({ data: data, opdid: opdid }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            if (response.d.startsWith("ERROR:")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Validation Failed',
                    text: response.d.replace("ERROR: ", ""),
                    showConfirmButton: false,
                    timer: 3000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

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
            var url1 = "../../ReportViewer.aspx?ReportName=OPD_Patient_Print_Slip&Title=OPD Patient Print &OPD_ID=" + patientID;
            window.open(url, '_blank');
            window.open(url1, '_blank');
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
            success: function (response) {
                var data = JSON.parse(response.d);

                $('#ddlDepartment').html(
                    $('<option>', {
                        value: data.Department,
                        text: data.Department_text
                    })
                ).attr('disabled', true);


                $("#hdn_dep_id").val(data.Department);


            },
            error: function (xhr, status, error) {
                console.log("Error: " + error);
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
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'OPD.aspx/GetCount',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
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
            $('#txtremarks').val(data.Remarks).attr('disabled', true);







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

            var bankCash = data.bank_cash || "01";
            $('#ddlbankcash').val(bankCash).trigger('change.select2');
            LoadBankAccounts(data.bank_account_id);


            $('#txtfees').val(data.Receipt_Amount).attr('disabled', true);
            $('#txtactualfee').val(data.Actual_amount);
            if (stat != "Approved") {
                $('#divapprove').show();
            }
            //if (data.Patient_Type != "01") {
            //    $('#field_Clinic').hide();
            //}

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
    actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;display:flex;justify-content:center;" href="#" onclick=AddEmergencyPatientDetail(' + Patient_ID + ')><i class="fa fa-plus-circle"></i></a>';
    actions += '<a class="tooltips" style="color:#FDC303;font-size:16px;display:none" href="#" onclick=EditEmergencyPatientDetail(' + Patient_ID + ')><i class="fa fa-pencil-square-o"></i><span class="tooltiptxt">Edit</span></a>';
    cell.innerHTML = actions;
}

function AddEmergencyPatientDetail(reg_id) {
    try {
        isAdd = true;
        window.location.href = "OPD.aspx?Reffered_id=" + reg_id + "&isAdd=" + isAdd;

    } catch (err) {
        alert(err.message);
    }

}



function openReferPatientModal() {
    $('#SearchReferPatients').modal('show');
    FillReferPatientsList();
}

function FillReferPatientsList() {
    var search = $('#txtReferEmergencySearch').val().trim();
    $('#ReferPatientsBody').empty();
    PageMethods.SearchPatients_Rff(search, OnFilterReferPatients, OnFailReferPatients);
}

function OnFilterReferPatients(data) {
    var tbody = $('#ReferPatientsBody');
    tbody.empty();

    if (!data || data.length === 0) {
        tbody.append('<tr><td colspan="7" class="text-center">No patients found.</td></tr>');
        return;
    }

    $.each(data, function (i, pat) {
        var row = '<tr>' +
            '<td style="display:none;">' + pat.Reg_Patient_ID + '</td>' +
            '<td>' + pat.Patient_No + '</td>' +
            '<td>' + pat.Full_Name + '</td>' +
            '<td>' + pat.Father_Name + '</td>' +
            '<td>' + pat.NIC + '</td>' +
            '<td>' + pat.Mobile1 + '</td>' +
            '<td>' +
            '<a class="tooltips" style="color:#438eb9; font-size:16px; display:flex; justify-content:center;" ' +
            'href="#" onclick="AddReferPatientDetail(\'' + pat.Reg_Patient_ID + '\')">' +
            '<i class="fa fa-plus-circle"></i>' +
            '<span class="tooltiptxt">Select</span>' +
            '</a>' +
            '</td>' +
            '</tr>';
        tbody.append(row);
    });
}

function OnFailReferPatients(error) {
    console.error("Refer patient search failed:", error);
    Swal.fire({
        icon: 'error',
        title: 'Error',
        text: 'Failed to load referred patients.',
        timer: 2000,
        showConfirmButton: false
    });
}

$('#txtReferEmergencySearch').off('input').on('input', function () {
    FillReferPatientsList();
});

function AddReferPatientDetail(reg_id) {
    try {
        var isAdd = true;
        window.location.href = "OPD.aspx?Reffered_id=" + reg_id + "&isAdd=" + isAdd;
    } catch (err) {
        alert(err.message);
    }
}

// OPD.js
function OPD_Print(OPD_ID, company_name) {
    if (!OPD_ID) {
        console.error("OPD_ID is missing");
        return;
    }

    var locationInfo = window.location;

    if (company_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx';
    }

    var url = "/ReportViewer.aspx?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=" + OPD_ID;
    var url1 = "/ReportViewer.aspx?ReportName=OPD_Patient_Print_Slip&Title=OPD Patient Print &OPD_ID=" + OPD_ID;

    if (locationInfo.hostname !== "localhost") {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];
        url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=' + OPD_ID;
        url1 = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=OPD_Patient_Print_Slip&Title=OPD Patient Print &OPD_ID=' + OPD_ID;
    }

    window.open(url, '_blank');
    window.open(url1, '_blank');
}

function getVisitDays(regPatId) {
    if (!regPatId || regPatId <= 0) return;

    $.ajax({
        url: 'OPD.aspx/GetVisitDays',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        data: JSON.stringify({ regPatId: regPatId }),
        dataType: 'json',
        success: function (response) {

            var data = response.d ? JSON.parse(response.d) : response;

            if (data.recentVisitDays !== null && data.recentVisitDays !== undefined) {
                $('#Span2').text(data.recentVisitDays);
            } else {
                $('#Span2').text('');
            }

            if (data.previousVisitDays !== null && data.previousVisitDays !== undefined) {
                $('#Span6').text(data.previousVisitDays);
            } else {
                $('#Span6').text('');
            }
        },
        error: function (xhr, status, error) {
            console.error('Error fetching visit days:', error);
            $('#Span2').text('');
            $('#Span6').text('');
        }
    });
}


function isCNICValidationRequired() {
    var result = false;
    $.ajax({
        type: "POST",
        url: "OPD.aspx/CNICValidation",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async: false,
        success: function (response) {
            if (response.d === "01") {
                result = true;
            }
        },
        error: function (xhr, status, error) {
            console.error("Error checking CNIC validation:", error);
            result = false;
        }
    });
    return result;
}