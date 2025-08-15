$(document).ready(function () {


    clearPatient();
 
    
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
    //$('#ddl_Gender').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetGender');
    //});

    //$('#ddlCountry').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetCountry');
    //});
    //$('#ddl_status').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetMartailStatus');
    //});
    //$('#txtarea').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetArea');
    //});
    //$('#txtcity').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetCity');
    //});
    //$('#ddl_bloodGroup').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetBloodBank');
    //});
    //$('#ddlstate').select2().on('select2:open', function () {
    //    fillDropdown($(this), 'GetProvince');
    //});

    var  dropdowns = [
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
    });
 
});
function fillDropdown($dropdown, methodName) {
    if ($dropdown.data('filled')) return;

    $dropdown.data('filled', false);

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



function fillArea() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetArea(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#txtarea').html(options);
      /*  $('#txtarea').select2();*/

    });
    return options;
}
function fillCity() {
    var options = '<option value="0">Please Select</option>';
    PageMethods.GetCity(function (data) {
        $.each(JSON.parse(data), function (key, value) {
            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
        });
        $('#txtcity').html(options);
        //$('#txtcity').select2();

    });
    return options;
}
function fillBloodBank() {
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'RegisterPatient.aspx/GetBloodBank',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#ddl_bloodGroup').html(options);
            //$('#ddl_bloodGroup').select2();

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
        url: 'RegisterPatient.aspx/GetProvince',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
            });
            $('#ddlstate').html(options);
            //$('#ddlstate').select2();

        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });

    return options;
}



function CalculateDateOfBirth() {
    
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


function SavePatient() {
  
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
    var Address = $('#txt_Address').val();
    var city = $('#txtcity :selected').text();
    var area = $('#txtarea :selected').text();
    var city_val = $('#txtcity').val();
    var area_val = $('#txtarea').val();
    var martail_status = $('#ddl_status').val();
    var Blood_Group = $('#ddl_bloodGroup').val();
    var State = $('#ddlstate').val();
    var Country = $('#ddlCountry :selected').val();

    if (PatientName === "") {
        $('#firstname-error').show();
        valid = false;
       
    }
    if (Mobile == "+92__________") {
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
    if ((PatientName == "" || Mobile == "+92__________" || Age == "" || Relation == "0" || Address == "0")) {
        
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

    });
    console.log(data);
    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/SavePatientDetail",
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (data) {
            
            var ini_patientID = data.d;

            toasterMessage(false, "Data Saved Successfully");
            window.location.reload();
            var url = "../../ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + ini_patientID;
            window.open(url, '_blank');

        },
        error: function (response) {
            alert("Error");
        }
    });
}
function toasterMessage(isError = false, title, message) {
    
    toastr.options = {
        "closeButton": true,
        "debug": false,
        "preventDuplicates": false,
        "positionClass": "toast-center-screen", // Custom class for center
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
            $('#ddl_Gender').val(data.Gender);
            $('#ddl_bloodGroup').val(data.BloodGroup);
            $('#ddlRelation').val(data.Relation);
            $('#txt_relation').val(data.FatherName);
            $('#txt_dob').val(data.Age);
            
            var dobString = data.DOB;

            var timestamp = parseInt(dobString.match(/\d+/)[0]);
            var finalDate = moment(timestamp).format("DD/MM/YYYY");
           
            $('#txtAge_yearss').val(finalDate);

            $('#txt_mobile').val(data.Mobile);
            $('#txt_Address').val(data.Address);
            $('#txt_cnic').val(data.CNIC);
            $('#ddl_status').append(
                $('<option>', {
                    value: data.MaritalStatus,  
                    text: data.MaritalStatus_text 
                })
            );
            $('#hdn_regid').val(reg_id);
            $('#ddlCountry').val(data.Country);
            $('#ddlstate').val(data.state);
            $('#txtcity').val(data.ValCity);
            $('#txtarea').val(data.ValArea).trigger('change');
        
        },
        error: function (response) {
            alert("Error: " + response.responseText);
            console.error("AJAX Error: ", response);
        }
    });
}