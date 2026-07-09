$(document).ready(function () {


    clearPatient();
    isCNICValidationRequired();


    MaskedInput({
        elm: document.getElementById('txt_mobile'),
        format: '+92__________',
        separator: '+92 -'

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

    $('#txt_mobile, #txt_cnic').on('click', function (e) {
        e.preventDefault();
        this.setSelectionRange(0, 0);
    });

    $('#txt_mobile').on('click', function (e) {
        e.preventDefault();
        this.setSelectionRange(3, 3);
    });


    var dropdowns = [
        { id: '#ddl_Gender', method: 'GetGender' },
        { id: '#ddlCountry', method: 'GetCountry' },
        { id: '#ddl_status', method: 'GetMartailStatus' },
        { id: '#txtarea', method: 'GetArea' },
        { id: '#txtcity', method: 'GetCity' },
        { id: '#ddl_bloodGroup', method: 'GetBloodBank' },
        { id: '#ddlstate', method: 'GetProvince' }
    ];

    dropdowns.forEach(item => {
        const $element = $(item.id);
        $element.select2();
        $element.off('select2:open').on('select2:open', function () {
            fillDropdown($element, item.method);
        });
        $element.off('select2:select').on('select2:select', function () {
            setTimeout(() => {
                var $currentSelection = $(this).siblings('.select2').find('.select2-selection');
                var $tabbable = $(':input:visible:enabled, .select2-selection:visible')
                    .not('[type="hidden"]')
                    .not(':disabled');

                var currentIndex = $tabbable.index($currentSelection);
                var $next = $tabbable.eq(currentIndex + 1);

                if ($next.length) {
                    if ($next.hasClass('select2-selection')) {
                        $next.attr('tabindex', '0').focus();
                    } else {
                        $next.focus();
                    }
                }
            }, 50);
        });
    });

    const staticDropdowns = ['#ddl_name', '#ddlRelation', '#PrefixAge'];
    staticDropdowns.forEach(id => {
        const $el = $(id);
        $el.select2();
        $el.off('select2:select').on('select2:select', function () {
            setTimeout(() => {
                var $currentSelection = $(this).siblings('.select2').find('.select2-selection');
                var $tabbable = $(':input:visible:enabled, .select2-selection:visible')
                    .not('[type="hidden"]')
                    .not(':disabled');
                var idx = $tabbable.index($currentSelection);
                var $next = $tabbable.eq(idx + 1);
                if ($next.length) {
                    if ($next.hasClass('select2-selection')) {
                        $next.attr('tabindex', '0').focus();
                    } else {
                        $next.focus();
                    }
                }
            }, 50);
        });
    });

    const defaultValues = {
        '#ddlCountry': '01',
        '#ddlstate': '01',
        '#txtcity': '0001',
        '#txtarea': '001'
    };

    function setDefaultDropdownValue(selector, defaultValue) {
        const $el = $(selector);
        if ($el.length === 0) return;

        const methodMap = {
            '#ddlCountry': 'GetCountry',
            '#ddlstate': 'GetProvince',
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

    if (!$('#txtAge_yearss').hasClass('hasDatepicker')) {
        $('#txtAge_yearss').datepicker({
            changeMonth: true,
            changeYear: true,
            yearRange: "-100:+0",
            dateFormat: "dd/mm/yy",
            onSelect: function (dateText) {
                var selectedDate = $(this).datepicker('getDate');
                if (selectedDate) {
                    var today = new Date();
                    var ageYears = today.getFullYear() - selectedDate.getFullYear();
                    var ageMonths = today.getMonth() - selectedDate.getMonth();
                    var ageDays = today.getDate() - selectedDate.getDate();

                    if (ageMonths < 0 || (ageMonths === 0 && ageDays < 0)) {
                        ageYears--;
                    }

                    if (ageYears > 0) {
                        $('#txt_dob').val(ageYears);
                        $('#PrefixAge').val('Year').trigger('change');
                    } else {
                        var monthDiff = (today.getMonth() - selectedDate.getMonth()) +
                            (12 * (today.getFullYear() - selectedDate.getFullYear()));
                        if (monthDiff > 0) {
                            $('#txt_dob').val(monthDiff);
                            $('#PrefixAge').val('Month').trigger('change');
                        } else {
                            var dayDiff = Math.floor((today - selectedDate) / (1000 * 60 * 60 * 24));
                            if (dayDiff > 0) {
                                $('#txt_dob').val(dayDiff);
                                $('#PrefixAge').val('Day').trigger('change');
                            }
                        }
                    }
                }
            }
        });
    }

    $('#txtAge_yearss').off('click').on('click', function () {
        if ($(this).datepicker('widget').is(':visible')) {
            return;
        }
        $(this).datepicker('show');
    });

});
function fillDropdown($dropdown, methodName, callback = null) {
    if ($dropdown.data('filled')) {
        if (callback) callback();
        return;
    }

    var currentValue = $dropdown.val();
    var currentText = $dropdown.find('option:selected').text();

    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/" + methodName,
        data: '{}',
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            try {
                const data = JSON.parse(response.d);
                var options = '<option value="0">Please Select</option>';
                var valueFound = false;

                $.each(data, function (key, value) {
                    var isSelected = (value.DataValue_Name == currentValue);
                    if (isSelected) valueFound = true;

                    options += `<option value="${value.DataValue_Name}" ${isSelected ? 'selected="selected"' : ''}>
                            ${value.DataValue_Description}
                        </option>`;
                });

                $dropdown.html(options)
                    .data('filled', true)
                    .trigger('change');

                if (currentValue && currentValue !== "0" && !valueFound) {
                    $dropdown.prepend(`<option value="${currentValue}" selected="selected">
                            ${currentText}
                        </option>`);
                    $dropdown.trigger('change');
                }

                if ($dropdown.hasClass('select2-hidden-accessible') && $dropdown.select2('isOpen')) {
                    $dropdown.select2('close').select2('open');
                }

                if (callback) callback();
            } catch (e) {
                $dropdown.data('filled', false);
                if (callback) callback();
            }
        },
        error: function (xhr, status, error) {
            $dropdown.data('filled', false);
            if (callback) callback();
        }
    });
}



function clearPatient() {

    $('#txt_name').val("");
    $('#txt_relation').val("");
    $('#txt_mobile').val("");
    $('#txt_dob').val("");
    $('#txt_cnic').val("");
    $('#txt_Address').val('');

    $('#updatePatient_Data').hide();
    $('#RevistPat').hide();
}
function fillmrno() {
    var data = {};

    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/Getmr",
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






function CalculateDateOfBirth() {
    var ageValue = $('#txt_dob').val();
    var unit = $('#PrefixAge').val();

    if (!ageValue || isNaN(ageValue) || parseInt(ageValue) <= 0) {
        $('#txtAge_yearss').val('');
        return;
    }

    var now = moment();
    var momentUnit = unit === "Year" ? "years" :
        unit === "Month" ? "months" :
            unit === "Day" ? "days" : "years";

    var dob = now.clone().subtract(parseInt(ageValue, 10), momentUnit);
    var finalDate = dob.format("DD/MM/YYYY");

    var $input = $('#txtAge_yearss');
    if (!$input.hasClass('hasDatepicker')) {
        $input.datepicker({
            changeMonth: true,
            changeYear: true,
            yearRange: "-100:+0",
            dateFormat: "dd/mm/yy",
            onSelect: function (dateText) {
                var selectedDate = $(this).datepicker('getDate');
                if (selectedDate) {
                    var today = new Date();
                    var ageYears = today.getFullYear() - selectedDate.getFullYear();
                    var ageMonths = today.getMonth() - selectedDate.getMonth();
                    var ageDays = today.getDate() - selectedDate.getDate();

                    if (ageMonths < 0 || (ageMonths === 0 && ageDays < 0)) {
                        ageYears--;
                    }

                    if (ageYears > 0) {
                        $('#txt_dob').val(ageYears);
                        $('#PrefixAge').val('Year').trigger('change');
                    } else {
                        var monthDiff = (today.getMonth() - selectedDate.getMonth()) +
                            (12 * (today.getFullYear() - selectedDate.getFullYear()));
                        if (monthDiff > 0) {
                            $('#txt_dob').val(monthDiff);
                            $('#PrefixAge').val('Month').trigger('change');
                        } else {
                            var dayDiff = Math.floor((today - selectedDate) / (1000 * 60 * 60 * 24));
                            if (dayDiff > 0) {
                                $('#txt_dob').val(dayDiff);
                                $('#PrefixAge').val('Day').trigger('change');
                            }
                        }
                    }
                }
            }
        });
    }

    $input.datepicker('setDate', dob.toDate());
}


function SavePatient() {
    debugger;
    $('#SavePatient_Data').attr('disabled', true);
    $('.span_txt').hide();
    var Prefix_PatientName = $('#ddl_name').val();
    var PatientName = $('#txt_name').val();
    var PatientID = $('#hdn_regid').val();
    var Full_Name = Prefix_PatientName + PatientName;
    var RelationType = $('#ddlRelation').val();
    var Relation = $('#txt_relation').val();
    var Gender = $('#ddl_Gender').val();
    var Mobile = $('#txt_mobile').val();
    var Age = $('#txt_dob').val();
    var Date_Of_Birth = $('#txtAge_yearss').val();
    var CNIC = $('#txt_cnic').val();
    var OtherCnic = $('#txt_OtherCnic').val();
    var Address = $('#txt_Address').val();
    var city = $('#txtcity :selected').text();
    var area = $('#txtarea :selected').text();
    var city_val = $('#txtcity').val();
    var area_val = $('#txtarea').val();
    var martail_status = $('#ddl_status').val();
    var Blood_Group = $('#ddl_bloodGroup').val();
    var State = $('#ddlstate').val();
    var Country = $('#ddlCountry :selected').val();
    var cardfee = $('#txtCardFee').val();
    var Monitoring = $('#chkMonitoring').is(':checked');
    var AntiForgeryToken = $('#ctl00_MainContent_hfAntiForgery').val();
    var bank_cash = $('#ddlbankcash').val();
    var bank_account_id = $('#ddlbank').val();

    var valid = true;var valid = true;

    if (PatientName === "") {
        $('#firstname-error').show();
        valid = false;

    }
    if (Mobile === "" || Mobile == "+92__________") {
        $('#mobile-error').show();
        valid = false;

    }

    if (Age === "") {
        $('#age-error').show();
        valid = false;

    }

    if (Relation === "") {
        $('#relation-error').show();
        valid = false;

    }
    if (Address === "") {
        $('#address-error').show();
        valid = false;

    }
    if (Gender === "" || Gender === "0") {
        valid = false;
    }
    if (martail_status === "" || martail_status === "0") {
        valid = false;
    }
    if (cardfee === "" || isNaN(cardfee) || parseFloat(cardfee) < 0) {
        valid = false;
    }

    if (bank_cash === "02" && (!bank_account_id || bank_account_id === "")) {
        Swal.fire({
            icon: 'warning',
            title: 'Bank Account Required!',
            text: 'Please select a bank account for Bank payment.',
            confirmButtonText: 'OK',
            confirmButtonColor: '#3085d6'
        });
        $('#SavePatient_Data').attr('disabled', false);
        return;
    }

    var isCNICRequired = isCNICValidationRequired();
    if (isCNICRequired) {
        var isCNICEmpty = !CNIC || CNIC === "" || CNIC === "_____-_______-_";
        var isOtherCNICEmpty = !OtherCnic || OtherCnic === "" || OtherCnic === "_____-_______-_";

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
            if (!isOtherCNICEmpty && OtherCnic !== "_____-_______-_") {
                var otherCnicPattern = /^\d{5}-\d{7}-\d$/;
                if (!otherCnicPattern.test(OtherCnic)) {
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
    if (!valid) {
        Swal.fire({
            icon: 'error',
            title: 'Validation Error',
            text: 'Please fill all required fields.',
            confirmButtonText: 'OK',
            confirmButtonColor: '#3085d6'
        });
        $('#SavePatient_Data').attr('disabled', false);
        return;
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
        "city": city,
        "city_val": city_val,
        "area_val": area_val,
        "area": area,
        "PatientID": PatientID,
        "martail_status": martail_status,
        "Age": Age,
        "Blood_Group": Blood_Group,
        "State": State,
        "Country": Country,
        "cardfee": cardfee,
        "OtherCnic": OtherCnic,
        "Monitoring": Monitoring,
        "AntiForgeryToken": AntiForgeryToken,
        "bank_cash": bank_cash,
        "bank_account_id": bank_account_id,

    });
    console.log(data);
    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/SavePatientDetail",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
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

            if (data.d.startsWith("ERROR:")) {
                toasterMessage(true, "Validation Failed", data.d.replace("ERROR: ", ""));
                $('#SavePatient_Data').attr('disabled', false);
                return;
            }
            debugger;
            var ini_patientID = data.d;
            toasterMessage(false, "Success", "Data Saved Successfully");
            Approve(ini_patientID)
            window.location.reload();
            var url = "../../ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + ini_patientID;
            window.open(url, '_blank');
        },
        error: function (xhr, status, error) {
            toasterMessage(true, "Request Failed", "An unexpected error occurred.");
            $('#SavePatient_Data').attr('disabled', false);
        }
    });
}
function Approve(pat_id) {
    PageMethods.approvepatient(pat_id, function (Tests) {
        debugger
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
            location.reload();
        }
    });
}
function toasterMessage(isError = false, title, message) {

    toastr.options = {
        "closeButton": true,
        "debug": false,
        "preventDuplicates": false,
        "positionClass": "toast-center-screen",
        "onclick": null,
        "showDuration": "551500",
        "hideDuration": "2000",
        "timeOut": "4000",
        "extendedTimeOut": "1000",
        "showEasing": "swing",
        "hideEasing": "linear",
        "showMethod": "fadeIn",
        "hideMethod": "fadeOut",
        onclick: function () {
            $('#right-sidebar').toggleClass('sidebar-open');
        }
    };

    if (isError)
        toastr.error(message, title);
    else
        toastr.success(message, title);
}

function Get_Pat_Info(reg_id) {
    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/GetRegData",
        data: JSON.stringify({ reg_id: reg_id }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (resp) {
            var data = JSON.parse(resp.d);

            $('#txt_Mrno').val(data.Mr_No);
            $('#txt_name').val(data.Name);
            $('#ddlRelation').val(data.Relation);
            $('#txt_relation').val(data.FatherName);
            $('#txt_dob').val(data.Age);
            $('#txt_mobile').val(data.Mobile);
            $('#txt_Address').val(data.Address);
            $('#hdn_regid').val(data.Reg_PatientID);
            $('#txt_cnic').val(data.CNIC_Masked);
            $('#txt_OtherCnic').val(data.other_cnic);
            $('#txtAge_yearss').val(data.DOB);
            $('#txtCardFee').val(data.Card_fee);
            var bankCash = data.bank_cash || "01";
            $('#ddlbankcash').val(bankCash).trigger('change.select2');
            if (bankCash === "02") {
                $.ajax({
                    type: "POST",
                    url: "RegisterPatient.aspx/GetBankAccounts",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        var accts = JSON.parse(resp.d);
                        var $bank = $('#ddlbank');
                        $bank.select2('destroy');
                        $bank.empty().append('<option value="">Select Account</option>');
                        if (accts && accts.length) {
                            $.each(accts, function (i, a) {
                                $bank.append('<option value="' + a.id + '">' + a.name + '</option>');
                            });
                        }
                        $bank.prop('disabled', false);
                        $bank.select2();
                        if (data.bank_account_id) {
                            $bank.val(data.bank_account_id).trigger('change');
                        }
                    }
                });
            } else {
                var $bank = $('#ddlbank');
                $bank.select2('destroy');
                $bank.empty().append('<option value="">Select Account</option>').prop('disabled', true);
                $bank.select2();
            }
            //dob
            if (data.Monitoring === true) {
                $('#chkMonitoring').prop('checked', true).trigger('change');
            } else {
                $('#chkMonitoring').prop('checked', false).trigger('change');
            }
            if (data.MaritalStatus_text)
                $('#ddl_status').html($('<option>', { value: '', text: data.MaritalStatus_text }).prop('selected', true));
            if (data.Country_text)
                $('#ddlCountry').html($('<option>', { value: '', text: data.Country_text }).prop('selected', true));
            if (data.BloodGroup_text)
                $('#ddl_bloodGroup').html($('<option>', { value: '', text: data.BloodGroup_text }).prop('selected', true));
            if (data.Area_text)
                $('#txtarea').html($('<option>', { value: '', text: data.Area_text }).prop('selected', true));
            if (data.Gender_text)
                $('#ddl_Gender').html($('<option>', { value: '', text: data.Gender_text }).prop('selected', true));
            if (data.State_text)
                $('#ddlstate').html($('<option>', { value: '', text: data.State_text }).prop('selected', true));
            if (data.City_text)
                $('#txtcity').html($('<option>', { value: '', text: data.City_text }).prop('selected', true));

            $('#SavePatient_Data').val('Update');
            $('#btnPrint').show();
        },
        error: function (response) {
            alert("Error loading patient data.");
            console.error("AJAX Error: ", response);
        }
    });
}


function isCNICValidationRequired() {
    var result = false;
    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/CNICValidation",
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