$(document).ready(function () {

   
    MaskedInput({
        elm: document.getElementById('StdCntct_No'),
        format: '+92 ___ _______',
        separator: '+92 -'

    });
    MaskedInput({
        elm: document.getElementById('Fcntc_No'),
        format: '+92 ___ _______',
        separator: '+92 -'
    });
    $('#apply-form input').blur(function () {
        if ($('input:text').is(":empty")) {
            $(this).parents('p').addClass('warning');
        }
    })

    debugger;
    GetStudentprogram();
    GetStudentClass();
    GetBloodGroup();
    GetBatch();
    GetGroup();
    GetGl_Code();
});
$(function () {
    $("#fileupload").change(function (event) {
        var x = URL.createObjectURL(event.target.files[0]);
        $("#upload-img").attr("src", x);
        console.log(event);
    });
})
function listopen() {
    debugger;
    window.location.href = "StudentsList.aspx";

}
function FormOpen() {
    debugger;
    window.location.href = "AddStudent.aspx";
}

function GetStudentprogram() {
    var Getprgrm = '';
    $.ajax({
        url: 'AddStudent.aspx/GetPrograms',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            Getprgrm = '<option value="0">Please Select</option>';
            debugger;
            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                Getprgrm += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
            });
            $('#ddlProgram').html(Getprgrm);

        },
    });
}

function GetGl_Code() {
    var GetGl = '';
    $.ajax({
        url: 'AddStudent.aspx/GetGl_Accounts',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            GetGl = '<option value="0">Select</option>';
            debugger;
            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                GetGl += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
            });
            $('#ddlGlAccount').html(GetGl);
            $('#ddlGlAccount').select2();

        },

    });
}

function GetStudentClass() {
    var GetClass = '';
    $.ajax({
        url: 'AddStudent.aspx/GetStudentClass',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            GetClass = '<option value="0">Select</option>';
            debugger;
            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                GetClass += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
            });
            $('#ddlClass').html(GetClass);

        },

    });
}
function GetBloodGroup() {
    var GetbldGroup = '';
    $.ajax({
        url: 'AddStudent.aspx/BloodGroup',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            GetbldGroup = '<option value="0">Select</option>';

            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                GetbldGroup += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
            });
            $('#Bld_group').html(GetbldGroup);
        },
    });
}
function GetBatch() {
    var GetBatch = '';
    $.ajax({
        url: 'AddStudent.aspx/StudentBatch',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            GetBatch = '<option value="0">Select</option>';

            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                GetBatch += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
            });
            $('#ddlBatch').html(GetBatch);
        },
    });
}
function GetGroup() {
    var GetGroup = '';
    $.ajax({
        url: 'AddStudent.aspx/StudentGroup',
        type: 'post',
        contentType: 'application/json;charset=utf-8',
        dataType: 'json',
        success: function (data) {
            debugger;
            GetGroup = '<option value="0">Select</option>';

            $.each(JSON.parse(data.d), function (key, value) {
                debugger;

                GetGroup += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
            });
            $('#ddlGroup').html(GetGroup);
        },
    });
}
function LoadStudentData(Stu_ID) {
    debugger;
    PageMethods.LoadStudentData(Stu_ID, function (resp) {
        var studata = JSON.parse(resp);
        debugger;
        $('#btnSave').val('Update');
        var stDate = '';
        if (studata.DOB != null) {
            stDate = new Date(parseInt(studata.DOB.substr(6)));
            stDate = moment(stDate).format('L');
        }
        debugger;
        var admDate = '';
        if (studata.AdmissionDate != null) {
            debugger;
            admDate = new Date(parseInt(studata.AdmissionDate.substr(6)));
            admDate = moment(admDate).format('L');
        }
        debugger;
        $('#Student_Id').val(studata.Student_Id);
        $('#Rollnum').val(studata.Roll_No);
        $('#admission').val(studata.Admission);
        $('#fullname').val(studata.Full_Name);
        $('#Father_Name').val(studata.Father_Name);
        $('#Guard_Name').val(studata.Guardian_Name);
        $('#Cust_Address').val(studata.Current_Adress);
        $('#StdCntct_No').val(studata.Student_Contact_No);
        $('#Fcntc_No').val(studata.Father_Contact_No);
        $('#Per_Address').val(studata.Permanent_Address);
        $('#EmailAdrr').val(studata.Email_Adress);
        $('#txt_Date').val(stDate);
        debugger;
        $('#txtadmDate').val(admDate)
        $('#St_CNIC').val(studata.Student_CNIC);
        setTimeout(function () {

            $('#ddlGlAccount').val(studata.Account_id).trigger('change');
        }, 2500);
        setTimeout(function () {
            $('#Bld_group').val(studata.BloodGroup).trigger('change');
        }, 2000);
        $('#Domicile').val(studata.Domicile);
        $('#Ft_CNIC').val(studata.Father_CNIC);
        $('#txtDisease_alergy').val(studata.Chronic_disease_Allergy);
        $('#Std_Status').val(studata.Studies_Status);
        setTimeout(function () {
            $('#ddlProgram').val(studata.Program).trigger('change');
        }, 2500);
       

        setTimeout(function () {
            $('#ddlBatch').val(studata.Batch).trigger('change');
        }, 2500);

        setTimeout(function () {
            $('#ddlGroup').val(studata.Groups).trigger('change');
        }, 2500);

        $('#txt_WholeClass').val(studata.Whole_Class);
        if (studata.Whole_Class == 1) {
            $("#txt_WholeClass").prop('checked', true);
        }

        $('#Is_Active').val(studata.Is_Active);
        if (studata.Is_Active == 1) {
            $("#Is_Active").prop('checked', true);
        }
        setTimeout(function () {
            $('#ddlClass').val(studata.Class).trigger('change');
        }, 2500);
        $('#txtSession').val(studata.Sesion);

        var pic = studata.Picture;
        var img = pic.slice(2);
        $('#upload-img').attr('src', img);


    })
}
function Selectfunc() {
    debugger;
    var currentYear = (new Date).getFullYear();

    var slct_value = $("#ddlProgram").val();

    if (slct_value == 02) {
        var yearmbbs = currentYear + 5;
        $('#txtSession').val(currentYear + '-' + yearmbbs);
        $($('#ddlClass').find('option')[1]).show();
        $($('#ddlClass').find('option')[2]).show();
        $($('#ddlClass').find('option')[3]).show();
        $($('#ddlClass').find('option')[4]).show();
        $($('#ddlClass').find('option')[5]).show();
    }
    else if (slct_value == 01) {
        var yearhealth = currentYear + 2;
        $('#txtSession').val(currentYear + '-' + yearhealth)
        $($('#ddlClass').find('option')[2]).hide();
        $($('#ddlClass').find('option')[3]).hide();
        $($('#ddlClass').find('option')[4]).hide();
        $($('#ddlClass').find('option')[5]).hide();
    }
    else if (slct_value == 03) {
        var yearBds = currentYear + 1;
        $('#txtSession').val(currentYear + '-' + yearBds)
        $($('#ddlClass').find('option')[1]).show();
        $($('#ddlClass').find('option')[2]).show();
        $($('#ddlClass').find('option')[3]).show();
        $($('#ddlClass').find('option')[4]).show();
        $($('#ddlClass').find('option')[5]).hide();
    }
}