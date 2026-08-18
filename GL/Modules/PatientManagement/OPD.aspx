<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/OPD.js" type="text/javascript"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/OPD.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            LoadClinicCard();
            loadCardfee();
        
            var urlParams = new URLSearchParams(window.location.search);
            var patId = urlParams.get('ID');
            if (patId) {
                getVisitDays(parseInt(patId));
            }

            loadPermissions(function () {
                for (var fieldId in fieldPermissionMapping) {
                    showIfAllowed(fieldId, true);
                }
            });
            DisableCardPrint();

            var reg_id = '<%= Request.QueryString["ID"] %>'
            var apt_Id = '<%= Request.QueryString["apt_id"] %>'
            var added = '<%= Request.QueryString["isAdd"] %>'
            var apdAdd = '<%= Request.QueryString["isAdd_apt"] %>'
            var OPDID = '<%= Request.QueryString["OPDID"] %>'
            var Reffered_id = '<%= Request.QueryString["Reffered_id"] %>'
            var refferopd_id = '<%= Request.QueryString["opd_id"] %>'
            var Reffered_id_opd = '<%= Request.QueryString["Reffered_id_opd"] %>'


            $("#hdn_opdId").val(OPDID);
            if (OPDID != "") {

                loadPatientDetail(OPDID);
                $('#btn-opdprint').show();
                $('#btn-opdFormprint').show();

            }
            else {
                $('#ddlGender').select2();
                $('#ddlpanel').select2();
                $('#ddlemployee').select2();
                $('#ddldoctor').select2();
                $('#ddlDepartment').select2();
                $('#ddlFilterClnic').select2();
                $('#ddlServices').select2();
            }
            $('#ddlbankcash').select2();
            $('#ddlbank').select2();
            if (reg_id != "" && added == "true") {
                Get_Pat_Info(reg_id);

                $('#ddlPatient_Type').attr('disabled', false);
                //$('#ddlcashier').attr('disabled', true);
            }

            if (apt_Id != "" && apdAdd == "true") {
                Get_Pat_Info_Apt(reg_id, apt_Id);

                $('#ddlPatient_Type').attr('disabled', false);
                //$('#ddlcashier').attr('disabled', true);
            }
            debugger;
            if (Reffered_id != "" && added == "true") {
                debugger;

                $("#hdn_emer_reffered").val(Reffered_id);
                console.log(Reffered_id);


                $('#ddlPatient_Type').attr('disabled', false);
                Get_Pat_Info(Reffered_id);
                //$('#ddlcashier').attr('disabled', true);
            }
            if (refferopd_id != "" && Reffered_id_opd != "") {
                Get_Pat_Info_Reffer(Reffered_id_opd);
            }

            LoadBankAccounts($('#ddlbankcash').val());
        });
        var cardvalidation;
        var isSaving = false;
        function checkcardvalidation() {

            $.ajax({
                type: "POST",
                url: "OPD.aspx/Getcardvalidation",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    debugger;
                    cardvalidation = JSON.parse(response.d);
                    if (cardvalidation == '01') {
                        var reg_id = '<%= Request.QueryString["ID"] %>'
                        var reffered_id = '<%= Request.QueryString["Reffered_id"] %>'

                        if (reffered_id == "") {
                            checkcardfee(reg_id);
                        }

                    }

                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function LoadClinicCard() {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/AllowClinicCard", 
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d; 

                    if (result === "01") {
                       
                        $("#filtercard").show();

                        
                    } else {
                      
                        $("#filtercard").hide();
                    }
                },
                error: function (err) {
                    console.log("Error: " + err);
                    $("#filtercard").hide(); // Hide on error
                }
            });
        }
        function checkcardfee(reg_id) {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/CheckCardFee",
                data: JSON.stringify({ reg_id: reg_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);

                    if (!data.hasCardFee) {
                        Swal.fire({
                            title: 'No Card Fee Found',
                            text: 'This patient has no card fee. Would you like to charge one?',
                            icon: 'info',
                            showCancelButton: true,
                            confirmButtonText: 'Yes, Charge Fee',
                            cancelButtonText: 'Cancel',
                            reverseButtons: true,
                            allowOutsideClick: false, // 👈 Prevent closing on backdrop click
                            allowEscapeKey: false     // 👈 Optional: also prevent Esc key dismissal
                        }).then((result) => {
                            if (result.isConfirmed) {
                                chargeCardFee(reg_id);
                            } else {
                                // Any dismissal (cancel, backdrop, esc) → disable save
                                $('#btnsave').prop('disabled', true);
                                Swal.fire({
                                    icon: 'info',
                                    title: 'Action Required',
                                    text: 'Card fee must be charged for first time register.',
                                    timer: 2000,
                                    showConfirmButton: false,
                                    allowOutsideClick: false
                                });
                            }
                        });
                    } else {
                        $('#btnsave').prop('disabled', false);
                        Swal.fire({
                            icon: 'success',
                            title: 'Card Fee Exists',
                            text: 'Card fee is already charged for this patient.',
                            timer: 2500,
                            showConfirmButton: false,
                            allowOutsideClick: false
                        });
                    }
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: xhr.responseText || 'Failed to check card fee.',
                        showConfirmButton: false,
                        timer: 2000,
                        allowOutsideClick: false,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                }
            });
        }

        // Example placeholder for charging logic
        function chargeCardFee(reg_id) {

            Approveviasysparams(reg_id);
            $.ajax({
                type: "POST",
                url: "OPD.aspx/ChargeCardFee", // ← Replace with your actual page name
                data: JSON.stringify({ reg_id: reg_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;

                    if (data.success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: data.message,
                            timer: 2000,
                            showConfirmButton: false
                        });


                    }
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Network Error!',
                        text: 'Failed to connect to server.',
                        timer: 2500,
                        showConfirmButton: false
                    });
                }
            });


        }
        function Approveviasysparams(pat_id) {
            PageMethods.ApproveRegpatient(pat_id, function (Tests) {
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

                }
            });
        }
        function DisableCardPrint() {
            var chkStatus = document.getElementById('<%=chckcardissue.ClientID%>');
            if (chkStatus.checked) {
                $('#divcardfront').show();
                $('#divcardback').show();
                $('#btnPrintCardFront').show()
                $('#btnPrintCardBack').show()
            }
            else {
                $('#divcardfront').hide();
                $('#divcardback').hide();
                $('#btnPrintCardFront').hide()
                $('#btnPrintCardBack').hide()
            }
        }
        var selectedClinic = null; // Add this near your other globals
        var permissions = {};
        var fieldPermissionMapping = {
            "field_mr_no": "mr_no",
            "field_Patient_name": "patient_name",
            "field_Last_name": "last_name",
            "field_OPD_No": "opd_no",
            "Field-CIH": "cash_in_hand",
            "field_Mode_Reg": "mode_presentation",
            "field_Mobile": "mobile",
            "field_CNIC": "cnic",
            "field_Category": "patient_category",
            "field_Martial_Status": "marital_status",
            "field_age": "age",
            "field_Gender": "gender",
            "field_Fee": "fee",
            "field_Address": "address",
            "Field_Card": "card",
            "Field_FollowUP": "follow_up",
            "Field_freeCheck": "Free_Check",
            "field_Services": "Services",
            "field_Clinic": "FilterClinic",
            "RefferdBy": "RefferedBy",
            "EmerRefferedBy": "EmerRefferedBy",
            "cashier": "cashier",
            "remarks": "remarks",
            "PaymentMethod": "PaymentMethod",
            "bank": "bank",
        };

        function loadPermissions(callback) {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/GetCompanyOPDPermissions",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    permissions = response.d || {};


                    if (typeof callback === 'function') {
                        callback();
                    }
                },
                error: function (xhr, status, error) {

                    alert("Could not load permissions.");
                }
            });
        }

        function showIfAllowed(fieldId, conditionToShow) {
            var permissionKey = fieldPermissionMapping[fieldId];
            if (!permissions || $.isEmptyObject(permissions)) {

                return;
            }

            if (!permissionKey) {

                $('#' + fieldId).hide();
                return;
            }

            var permissionValue = null;
            var matchedKey = null;

            for (var key in permissions) {
                if (key.toLowerCase() === permissionKey.toLowerCase()) {
                    permissionValue = permissions[key];
                    matchedKey = key;
                    break;
                }
            }

            if (permissionValue === true) {
                if (conditionToShow) {
                    $('#' + fieldId).show();

                } else {
                    $('#' + fieldId).hide();

                }
            } else {

                $('#' + fieldId).hide();
            }
        }

        function loaddata() {
            debugger;
            var Category = $('#ddlPatient_Type').val();
            // $('#ddlPatient_Type').attr('disabled', true);
            debugger;
            if (Category == "0") {

                $('.show').show();
                $('#fees').hide();
                $('#department').hide();
                showIfAllowed('field_Clinic', false);

                $('#field_Clinic').hide();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#txtfees').val('');
                $('#txtactualfee').val('');
                $('#discount').hide();
                $('#empname').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#emp_id').hide();
            }
            else if (Category == "01") {
                $('#fees').show();
                $('#department').show();
                $('#ddlFilterClnic').attr('disabled', false);
                showIfAllowed('field_Clinic', true);
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#dependent').hide();
                $('#emp_id').hide();
            }
            else if (Category == "02") {
                var apt_Id = '<%= Request.QueryString["apt_id"] %>'
                var apdAdd = '<%= Request.QueryString["isAdd_apt"] %>'
                var OPDID = '<%= Request.QueryString["OPDID"] %>'
                var Reffered_id_opd = '<%= Request.QueryString["Reffered_id_opd"] %>';
                $('#fees').show();
                $('#department').show();
                $('#doctor').show();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#field_Clinic').hide();
                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#emp_id').hide();
                if (apt_Id != "" && apdAdd == "true") {

                }
                else if (OPDID != "") {

                }
                else if (Reffered_id_opd != "") {

                }
                else {
                    LoadDoc();
                }


            }
            else if (Category == "03") {
                $('#fees').show();
                $('#department').hide();
                $('#doctor').show();
                $('#pnlcompany').show();
                $('#employee').show();
                $('#refference').show();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#discount').hide();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#emp_id').hide();
                LoadDoc();


            }
            else if (Category == "04") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#discount').show();
                $('#empname').show();
                $('#EmployeeName').show();
                $('#emp_id').hide();
                $('#designation').show();
                $('#dependent').show();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#EmpDep').show();


            }
            else if (Category == "05") {
                $('#fees').hide();
                $('#department').show();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#rollno').show();
                $('#class').hide();
                $('#section').hide();

                $('#emp_id').hide();
                $('#StdName').show();
            }
            else if (Category == "06") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();

                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#dependent').hide();

                $('#emp_id').hide();


            }
            else if (Category == "11") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();

                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#emp_id').hide();
            }
            else if (Category == "12") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();

                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#emp_id').hide();
            }
            else if (Category == "52") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').show();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#refference').hide();
                $('#field_Clinic').hide();
                $('#discount').show();
                $('#empname').hide();
                $('#designation').hide();
                $('#dependent').hide();
                $('#rollno').hide();
                $('#class').hide();
                $('#section').hide();
                $('#emp_id').hide();

            }
        }
        function ApproveOPD() {
            var pat_id = '<% =Request.QueryString["OPDID"] %>';
            var Pat_Category = $('#ddlPatient_Type').val();

            PageMethods.approvepatient(pat_id, Pat_Category, function (Tests) {
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
        function getcardAmount() {
            var Pat_feeforCard = $('#ctl00_MainContent_chckcardissue').prop('checked');
            if (Pat_feeforCard == true) {
                var Pat_idforCard = $('#hdn_opdId').val();
                PageMethods.CardFee(Pat_idforCard, function (Tests) {
                    debugger;
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Card Has Been Issued.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                });
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Issue Card CheckBox',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            debugger;
            PrintPatientCard();


        }


        function OPD_Form_Print() {
            debugger;
            var ID = '<%= Request.QueryString["OPDID"]%>';
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=OPDForm&Title=OPD FORM &OPD_ID=" + ID;
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=OPDForm&Title=OPD FORM &OPD_ID=" + ID;
            }
            window.open(url, '_blank');
        }
        debugger
        function PrintPatientCard() {
            debugger
            $('#ctl00_MainContent_chckcardissue').attr('disabled', true);

            var ID = '<%= Request.QueryString["OPDID"]%>';
            debugger
            $.ajax({
                type: "POST",
                url: "OPD.aspx/CardFee",
                data: JSON.stringify({ 'PatID': ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    if (msg.d == "success")
                        debugger;
                    console.log(msg.d);
                    var url = "../../ReportViewer.aspx?ReportName=PrintPatientCard&ReportTitle=OPD Patient Card&MrNo=" + ID;

                    window.open(url, '_blank');
                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }
        function PrintPatientBackCard() {
            $('#ctl00_MainContent_chckPatientCard').attr('disabled', true);
            Patient_ID =  '<%= Request.QueryString["OPDID"]%>';
            var url = "/ReportViewer.aspx?ReportName=PrintPatientBackCard&ReportTitle=Patient Registration Card&MrNo=" + Patient_ID;
            window.open(url);
        }





        function PrintVoucher() {
            debugger;
            var id = '<% =Request.QueryString["OPDID"] %>';
            var locationInfo = window.location;
            var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPD';
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPD';
            }
            window.open(url, '_blank');
        }

        //function loaddoctor() {
        //    debugger;
        //    var appointmentid = $("#hdn_aptid").val();
        //    var opdid = $('#hdn_opdId').val();

        //    if (appointmentid != "" || opdid != "") {

        //    }
        //    else {
        //        debugger;
        //        var dpt = $('#ddlDepartment').val();

        //        $.ajax({
        //            type: "POST",
        //            url: "OPD.aspx/LoadDoctor",
        //            data: JSON.stringify({ dpt: dpt }),
        //            contentType: "application/json; charset=utf-8",
        //            dataType: "json",
        //            success: function (response) {
        //                debugger;
        //                var doctor = JSON.parse(response.d);
        //                var options = '<option value=""> Please Select </option>';

        //                $.each(doctor, function (key, value) {
        //                    options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
        //                });
        //                debugger;

        //                $('#ddldoctor').html(options);
        //                var type = $('#ddlPatient_Type').val();

        //                if (type != "02" ) {
        //                    debugger;

        //                    getGeneralFee();
        //                }
        //                if (type != "52") {
        //                    getGeneralFee();
        //                }
        //            },
        //            error: function (xhr, status, error) {
        //                console.log("Error: " + error);
        //            }
        //        });
        //    }
        //}
        function LoadDoc() {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/LoadAllDoctor",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var doctor = JSON.parse(response.d);
                    var options = '<option value=""> Please Select </option>';

                    $.each(doctor, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });

                    $('#ddldoctor').html(options);



                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });

        }
        function LoadBankAccounts(selectedId) {
    var $bank = $('#ddlbank');
    var paymentType = $('#ddlbankcash').val();

    $bank.select2('destroy');

    if (paymentType === "01") { // Cash
        $bank.empty().append('<option value="">Select Account</option>')
             .prop('disabled', true);
        $bank.select2();
        return;
    }

    // Bank – disable initially while loading
    $bank.empty().append('<option value="">Select Account</option>')
         .prop('disabled', true);
    $bank.select2();

    $.ajax({
        type: "POST",
        url: "OPD.aspx/GetBankAccounts",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var accounts = JSON.parse(response.d);
            $bank.select2('destroy');
            $bank.empty().append('<option value="">Select Account</option>');
            if (accounts && accounts.length) {
                $.each(accounts, function (i, acc) {
                    $bank.append('<option value="' + acc.id + '">' + acc.name + '</option>');
                });
            }
            $bank.prop('disabled', false);
            $bank.select2();
            if (selectedId) {
                $bank.val(selectedId).trigger('change');
            }
        },
        error: function () {
            $bank.select2('destroy')
                .empty().append('<option value="">Error loading accounts</option>')
                .prop('disabled', false);
            $bank.select2();
        }
    });
}

        function getGeneralFee() {
            debugger;

            var Department_id = $('#ddlDepartment').val();
            var emer_reffered = $("#hdn_emer_reffered").val();
            var type = $("#ddlPatient_Type").val();
            var type_text = $('#ddlPatient_Type option:selected').text().trim();

            if (emer_reffered !== "") {
                $('#txtfees').val("0");
                $('#hdnDocshare').val("0");
                $('#hdnhospShare').val("0");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            if (!Department_id || Department_id === "") {
                $('#txtfees').val("0");
                $('#hdnDocshare').val("0");
                $('#hdnhospShare').val("0");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            $.ajax({
                url: 'OPD.aspx/GetFees',
                type: 'POST',
                data: JSON.stringify({ Department_id: Department_id }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (resp) {
                    debugger;

                    try {
                        var data = JSON.parse(resp.d);
                        var code = data && data.Code !== undefined ? data.Code : 0;
                        var dShare = data && data.D_Share !== undefined ? data.D_Share : 0;
                        var hShare = data && data.H_Share !== undefined ? data.H_Share : 0;
                        var Discount_Percentage = data &&
                            data.Discount_Percentage !== undefined &&
                            data.Discount_Percentage !== null
                            ? data.Discount_Percentage
                            : 0;
                        var Receipt_fee = data && data.Receipt_fee !== undefined ? data.Receipt_fee : 0;
                        debugger;
                        $('#txtactualfee').val(code);


                        if (
                            (type === "04" && type_text === "Employee") ||
                            (type === "05" && type_text === "Student") ||
                            (type === "11" && type_text === "CAMP") ||
                            (type === "12" ) ||
                            (type === "06" && type_text === "Refer")
                        ) {
                            $('#txtdiscount').val(100);
                            $('#txtactualfee').val(code);
                            $('#txtdiscount').attr('disabled', true);
                            $('#txtfees').val(0);
                            $('#hdnDocshare').val(dShare);
                            $('#hdnhospShare').val(hShare);
                        }
                        else {
                            debugger;
                            $('#txtdiscount').val(Discount_Percentage);
                            $('#txtdiscount').attr('disabled', false);
                            $('#txtfees').val(Receipt_fee.toFixed(2));
                            $('#txtactualfee').val(code);
                            $('#hdnDocshare').val(dShare);
                            $('#hdnhospShare').val(hShare);
                        }
                        debugger;
                        if (parseFloat(code) === 0) {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Policy Not Defined',
                                text: 'Policy is not defined against this department.',
                                timer: 2000,
                                showConfirmButton: false,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }

                    } catch (e) {
                        console.error("Error parsing fee data:", e);
                        $('#txtfees').val("0");
                        $('#hdnDocshare').val("0");
                        $('#hdnhospShare').val("0");
                        $('#txtdiscount').val("");
                        $('#txtdiscount').attr('disabled', false);

                        Swal.fire({
                            icon: 'warning',
                            title: 'Data Error',
                            text: 'Invalid fee data received.',
                            timer: 2000,
                            showConfirmButton: false,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error, xhr.responseText);

                    Swal.fire({
                        icon: 'error',
                        title: 'Request Failed',
                        text: 'Could not retrieve fee information.',
                        timer: 2000,
                        showConfirmButton: false,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    debugger;
                    $('#txtfees').val("0");
                    $('#hdnDocshare').val("0");
                    $('#hdnhospShare').val("0");
                    $('#txtdiscount').val("");
                    $('#txtdiscount').attr('disabled', false);
                }
            });
        }
        function loaddoctor() {
            debugger;
            var dept_gnl = $('#ddlDepartment').val();
            var appointmentid = $("#hdn_aptid").val();
            var opdid = $('#hdn_opdId').val();

            if (appointmentid != "" || opdid != "") {

            }
            else {
                var dpt = $('#ddlDepartment').val();

                $.ajax({
                    type: "POST",
                    url: "OPD.aspx/LoadDoctor",
                    data: JSON.stringify({ dpt: dpt }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var doctor = JSON.parse(response.d);
                        var options = '<option value=""> Please Select </option>';

                        $.each(doctor, function (key, value) {
                            options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                        });

                        $('#ddldoctor').html(options);
                        var type = $('#ddlPatient_Type').val();
                        if (type != "02" && type != "52") {
                            debugger;
                            getGeneralFee();
                        }
                      
                    },
                    error: function (xhr, status, error) {
                        console.log("Error: " + error);
                    }
                });
                $("#hdn_dep_id").val(dept_gnl);
            }
        }



        function loadFee() {
            debugger;

            var Doc = $('#ddldoctor').val();
            var opdid = $('#hdn_opdId').val();
            var selectedPatientType = $('#ddlPatient_Type').val();
            var emer_reffered = $("#hdn_emer_reffered").val();

            if (emer_reffered !== "") {
                $('#txtfees').val("0");
                return;
            }

            if (!Doc) return;
            checkDoctorBlockStatus(Doc, selectedPatientType, function (isBlocked) {
                if (isBlocked) {
                    return;
                }

                if (selectedPatientType == '52') {
                    getspecialfees(Doc);
                } else {
                    if (opdid == "") {
                        $.ajax({
                            type: "POST",
                            url: "OPD.aspx/loadRegistrationFees",
                            data: JSON.stringify({ Doc: Doc }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                debugger;
                                var res = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;

                                if (!res.success) {
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Error!',
                                        text: res.message,
                                        showConfirmButton: false,
                                        timer: 2000,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });
                                } else {
                                    debugger;
                                    var fee = parseFloat(res.fee) || 0;
                                    var disper = parseFloat(res.discount_percentage) || 0;
                                    var afterdiscountfee = fee - ((fee * disper) / 100);

                                    $('#txtfees').val(afterdiscountfee.toFixed(2));
                                    $('#txtactualfee').val(res.fee);
                                    $('#txtdiscount').val(res.discount_percentage);
                                    if (disper == 0) {
                                        $('#txtdiscount').attr('disabled', false);
                                    }
                                    else {
                                        $('#txtdiscount').attr('disabled', true);
                                    }
                                  
                                    $('#hdnhospShare').val(res.Hospital_Share);
                                    $('#hdnDocshare').val(res.Doctor_Share);
                                }
                            },
                            error: function (xhr, status, error) {
                                console.log("Error: " + error);
                            }
                        });
                    }
                    loadDepartment(Doc);
                }
            });
        }


        debugger;
        function getspecialfees(Doc) {
            debugger
            $.ajax({
                type: "POST",
                url: "OPD.aspx/loadSpecialFees",
                data: JSON.stringify({ Doc: Doc }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var res = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;

                    if (!res) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Special Fee not found.',
                            timer: 2000,
                            showConfirmButton: false
                        });
                        return;
                    }
                    $('#txtactualfee').val(res.Consultant_Charges);
                    $('#txtfees').val(res.Consultant_Charges);
                    $('#txtdiscount').val(0);

                    $('#hdnhospShare').val(res.Hospital_Amount);
                    $('#hdnDocshare').val(res.Doctor_Amount);
                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });
        }

        function checkDoctorBlockStatus(Doc, selectedPatientType, callback) {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/GetDoctorBlockInfo",
                data: JSON.stringify({ Doc: Doc }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var blockInfo = JSON.parse(response.d);

                    if (blockInfo && blockInfo.error) {
                        console.error("Block info error:", blockInfo.error);
                        callback(false);
                        return;
                    }
                    if (blockInfo.offDays && blockInfo.offDays !== "" && blockInfo.Block_category === true && blockInfo.Patient_Type === selectedPatientType) {
                        debugger;
                        let offDays = blockInfo.offDays.toLowerCase().split(',').map(x => x.trim());
                        let today = new Date();
                        let todayDay = today.toLocaleString("en-US", { weekday: 'short' }).toLowerCase();
                        todayDay = todayDay.substring(0, 3);
                        if (offDays.includes(todayDay)) {

                            Swal.fire({
                                icon: 'warning',
                                title: 'Doctor Off-Day',
                                text: 'This Category is Blocked by the Admin.',
                                timer: 2500,
                                showConfirmButton: false,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                            $('#txtfees').val("0");
                            $('#txtactualfee').val("0");
                            $('#txtdiscount').val("");
                            $('#ddldoctor').val("");

                            callback(true);
                            return;
                        }
                    }

                    if (blockInfo.Block_category === true && blockInfo.Patient_Type === selectedPatientType) {

                        const now = new Date();

                        const parseLocalDate = (str) => {
                            const [y, m, d] = str.split('-').map(Number);
                            return new Date(y, m - 1, d);
                        };

                        const stDate = parseLocalDate(blockInfo.st_day);
                        const endDate = parseLocalDate(blockInfo.end_day);

                        const [startHour, startMin] = (blockInfo.Timings_In || "00:00").split(':').map(Number);
                        const [endHour, endMin] = (blockInfo.Timings_Out || "23:59").split(':').map(Number);

                        stDate.setHours(startHour, startMin, 0, 0);
                        endDate.setHours(endHour, endMin, 0, 0);

                        const isWithinWindow = now >= stDate && now <= endDate;

                        if (isWithinWindow) {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Access Denied',
                                text: 'This category is blocked by the admin.',
                                timer: 2500,
                                showConfirmButton: false,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                            $('#txtfees').val("0");
                            $('#txtactualfee').val("0");
                            $('#txtdiscount').val("");
                            $('#ddldoctor').val("");

                            callback(true);
                            return;
                        }
                    }

                    callback(false);
                },
                error: function (xhr, status, error) {
                    console.error("Failed to fetch block info:", error);
                    callback(false);
                }
            });
        }

        function loadCardfee() {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/GetCardFee",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d !== null && !isNaN(response.d)) {
                        $('#txtCardFee').val(response.d);
                        $('#txtCardFee').attr('disabled', true);
                    } else {
                        console.error("Invalid fee received:", response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error loading card fee:", error);
                }
            });
        }

        function checkOutPatientDischarge(department, callback) {
            var regid = $('#hdn_regid').val();
            var opdid = $('#hdn_opdId').val();
            
            // Only check for NEW OPD
            if (opdid !== "" || !regid || !department || department === "0") {
                callback(false);
                return;
            }
            
            $.ajax({
                type: "POST",
                url: "OPD.aspx/CheckOutPatientDischarge",
                data: JSON.stringify({ regPatId: parseInt(regid), department: department }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var result = JSON.parse(response.d);
                    if (result.hasActiveOPD) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Active OPD Found',
                            text: 'Patient has active OPD already in last 24 hrs.',
                            confirmButtonText: 'OK',
                            confirmButtonColor: '#3085d6',
                            allowOutsideClick: false,
                            allowEscapeKey: false
                        });
                        
                        // Reset department dropdown
                        $('#ddlDepartment').val('').trigger('change');
                        
                        callback(true);
                    } else {
                        callback(false);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error checking OPD discharge status:", error);
                    callback(false);
                }
            });
        }
       


        

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
    <!-- Anti-CSRF Token -->
    <input type="hidden" id="hfAntiForgery" runat="server" />
    <input type="text " id="hdfPatient_ID" style="display: none;" />
    <input type="hidden" id="hdnAppointmentType" />
    <input type="text" id="hdn_aptid" style="display: none;" />
    <input type="text" id="hdn_regid" style="display: none;" />
    <input type="text" id="hdn_opdId" style="display: none;" />
    <input type="text" id="hdnDocshare" style="display: none;" />
    <input type="text" id="hdnhospShare" style="display: none;" />
    <input type="text" id="hdn_emer_reffered" style="display: none;" />
    <input type="text" id="hdn_dep_id" style="display: none;" />
<div class="opd-page">

    <!-- ============ META BAR ============ -->
    <div class="opd-meta-bar">
        <div class="opd-meta-title">
            <i class="fa fa-stethoscope"></i>
            <span>OPD - Patient Registration</span>
            <span class="opd-meta-meta-badge" id="opdStatusBadge">New</span>
        </div>
        <div class="opd-meta-actions">
            <span class="opd-meta-meta-badge"><i class="fa fa-calendar"></i> <%= DateTime.Now.ToString("dd MMM yyyy") %></span>
        </div>
    </div>

    <!-- ============ TOP SECTION: QUICK ACTIONS + STATS ============ -->
    <div class="opd-layout">

        <!-- Quick Actions -->
        <div class="opd-bento opd-bento--5">
            <div class="opd-quick-action" id="card-register" role="button" tabindex="0"
                onclick="addfunc()" onkeypress="if(event.key==='Enter'){ addfunc(); }">
                <div class="opd-quick-action-icon">
                    <i class="fa fa-user-plus"></i>
                </div>
                <div class="opd-quick-action-text">
                    <div class="opd-quick-action-title">Register a new patient</div>
                    <div class="opd-quick-action-subtitle">Create a new patient record</div>
                </div>
            </div>

            <div class="opd-quick-action" id="card-search-appointment" role="button" tabindex="0"
                onclick="SearchPop_App()" onkeypress="if(event.key==='Enter'){ SearchPop_App(); }">
                <div class="opd-quick-action-icon">
                    <i class="fa fa-calendar-check-o"></i>
                </div>
                <div class="opd-quick-action-text">
                    <div class="opd-quick-action-title">Search in appointment</div>
                    <div class="opd-quick-action-subtitle">Find patient appointments</div>
                </div>
            </div>

            <div class="opd-quick-action" id="btnsearchpatlist" role="button" tabindex="0"
                onclick="/* openPatientSearch() */" onkeypress="if(event.key==='Enter'){ /* openPatientSearch(); */ }">
                <div class="opd-quick-action-icon">
                    <i class="fa fa-search"></i>
                </div>
                <div class="opd-quick-action-text">
                    <div class="opd-quick-action-title">Search an existing patient</div>
                    <div class="opd-quick-action-subtitle">Lookup patient details</div>
                </div>
            </div>

            <div class="opd-quick-action" id="EmerRefferedBy">
                <div id="btnsearchEmergencylist" role="button" tabindex="0"
                    onclick="/* referToEmergency() */" onkeypress="if(event.key==='Enter'){ /* referToEmergency(); */ }"
                    style="display:flex;align-items:center;gap:10px;width:100%;">
                    <div class="opd-quick-action-icon">
                        <i class="fa fa-ambulance"></i>
                    </div>
                    <div class="opd-quick-action-text">
                        <div class="opd-quick-action-title">Emergency Refer</div>
                        <div class="opd-quick-action-subtitle">Refer to emergency</div>
                    </div>
                </div>
            </div>

            <div class="opd-quick-action" id="RefferdBy">
                <div id="btnsearchReferlist" role="button" tabindex="0"
                    onclick="openReferPatientModal()" onkeypress="if(event.key==='Enter'){ openReferPatientModal(); }"
                    style="display:flex;align-items:center;gap:10px;width:100%;cursor:pointer;">
                    <div class="opd-quick-action-icon">
                        <i class="fa fa-share-square-o"></i>
                    </div>
                    <div class="opd-quick-action-text">
                        <div class="opd-quick-action-title">Refer Patient</div>
                        <div class="opd-quick-action-subtitle">Refer an existing patient</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Stats Card -->
        <div class="opd-stats" id="filtercard">
            <div class="opd-stats-header">
                <i class="fa fa-bar-chart"></i>
                <span>OPD Stats</span>
            </div>
            <div class="opd-stats-grid">
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-users"></i> Total</span>
                    <span class="opd-stats-value opd-stats-value--primary" id="lbltotpat" runat="server">0</span>
                </div>
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-circle-o"></i> G-31</span>
                    <span class="opd-stats-value" id="lblg31" runat="server">0</span>
                </div>
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-circle-o"></i> G-30</span>
                    <span class="opd-stats-value" id="lblg30" runat="server">0</span>
                </div>
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-circle-o"></i> G-29</span>
                    <span class="opd-stats-value" id="lblg29" runat="server">0</span>
                </div>
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-clock-o"></i> Recent</span>
                    <span class="opd-stats-value opd-stats-value--blink" id="Span2" runat="server" clientidmode="Static">0</span>
                </div>
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-history"></i> Previous</span>
                    <span class="opd-stats-value opd-stats-value--blink" id="Span6" runat="server" clientidmode="Static">0</span>
                </div>
            </div>
        </div>
    </div>

    <!-- ============ MAIN FORM: PATIENT INFO + DEPARTMENT/DOCTOR ============ -->
    <div class="opd-form-layout">

        <!-- Patient Info Card -->
        <div class="opd-card">
            <div class="opd-card-header">
                <i class="fa fa-user"></i>
                <span>Patient Information</span>
                <span class="opd-card-badge" id="opdPatientBadge">New Patient</span>
            </div>
            <div class="opd-card-body">
                <input type="text" id="txt_reg_patno" style="display: none" />
                <input type="text" runat="server" id="txtPatient_ID" style="display: none" />
                <input type="text" id="txtpatient_no" style="display: none" />
                <input type="hidden" id="hdnPatientID" runat="server" />

                <div class="opd-form-row opd-form-row--4">
                    <div class="opd-field" id="field_mr_no">
                        <label class="opd-label">MR No</label>
                        <input type="text" id="txtPatientNo" value="New" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_Patient_name">
                        <label class="opd-label">Name <span class="opd-required">*</span></label>
                        <input type="text" id="txt_patname" value="" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_Last_name">
                        <label class="opd-label">Last Name <span class="opd-required">*</span></label>
                        <input type="text" id="txt_F_Name" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_OPD_No">
                        <label class="opd-label">OPD No <span class="opd-required">*</span></label>
                        <input type="text" id="txt_opd_no" value="New" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                </div>

                <div class="opd-form-row opd-form-row--4">
                    <div class="opd-field" id="field_Mode_Reg">
                        <label class="opd-label">Mode Of Presentation</label>
                        <select id="ddlMode_Of_Registration" readonly="readonly" class="opd-select"></select>
                    </div>
                    <div class="opd-field" id="field_Mobile">
                        <label class="opd-label">Mobile <span class="opd-required">*</span></label>
                        <input type="text" id="txtmobile" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_CNIC">
                        <label class="opd-label">CNIC <span class="opd-required">*</span></label>
                        <input type="text" id="txtnic" value="" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_Category">
                        <label class="opd-label">Patient Category</label>
                        <select id="ddlPatient_Type" disabled class="opd-select">
                            <option value="0">Select Category</option>
                        </select>
                    </div>
                </div>

                <div class="opd-form-row opd-form-row--4">
                    <div class="opd-field" id="field_Martial_Status">
                        <label class="opd-label">Marital Status</label>
                        <select id="ddlmartialstatus" disabled class="opd-select">
                            <option value="0">Select Status</option>
                        </select>
                    </div>
                    <div class="opd-field" id="field_age">
                        <label class="opd-label">Age</label>
                        <input type="text" id="txtage" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="field_Gender">
                        <label class="opd-label">Gender</label>
                        <select id="ddlGender" disabled class="opd-select">
                            <option value="0">Select Gender</option>
                        </select>
                    </div>
                    <div class="opd-field" id="field_Fee">
                        <label class="opd-label">Fee</label>
                        <input type="text" id="txtfees" readonly="readonly" class="opd-input opd-input--readonly" />
                        <input type="text" id="txtactualfee" style="display: none;" class="opd-input" />
                    </div>
                </div>

                <div class="opd-form-row opd-form-row--4">
                    <div class="opd-field" id="field_Services">
                        <label class="opd-label">Services</label>
                        <select id="ddlServices" class="opd-select">
                            <option value="0">Select Service</option>
                        </select>
                    </div>
                    <div class="opd-field" id="cashier">
                        <label class="opd-label">Cashier</label>
                        <select id="ddlcashier" class="opd-select">
                            <option value="0">Select Cashier</option>
                        </select>
                    </div>
                    <div class="opd-field" id="PaymentMethod">
                        <label class="opd-label" for="ddlbankcash">Payment</label>
                        <select id="ddlbankcash" onchange="LoadBankAccounts();" class="opd-select" name="payment">
                            <option value="02">Bank</option>
                            <option value="01" selected>Cash</option>
                        </select>
                    </div>
                    <div class="opd-field" id="bank">
                        <label class="opd-label" for="ddlbank">Bank</label>
                        <select id="ddlbank" class="opd-select"></select>
                    </div>
                    <div class="opd-field" id="field_Address">
                        <label class="opd-label">Address</label>
                        <input type="text" id="txtAdrress" readonly="readonly" class="opd-input opd-input--readonly" />
                    </div>
                    <div class="opd-field" id="remarks">
                        <label class="opd-label">Remarks</label>
                        <input type="text" id="txtremarks" class="opd-input" />
                    </div>
                </div>

                <div class="opd-form-row opd-form-row--4">
                    
                    
                </div>

                <div class="opd-field" id="field_Dept_Token" style="display:none;">
                    <label class="opd-label">Dept Token No</label>
                    <input type="text" id="txtDeptToken" readonly="readonly" class="opd-input opd-input--readonly" />
                </div>
            </div>
        </div>

        <!-- Department / Doctor Card -->
        <div id="right-section">
            <div class="opd-card">
                <div class="opd-card-header">
                    <i class="fa fa-hospital-o"></i>
                    <span>Visit Details</span>
                </div>
                <div class="opd-card-body">
                    <div class="opd-field" id="department">
                        <label class="opd-label">Department</label>
                        <select id="ddlDepartment" class="opd-select">
                            <option value="0">Select Department</option>
                        </select>
                    </div>
                    <div class="opd-field" id="field_Clinic">
                        <label class="opd-label">Filter Clinic</label>
                        <select id="ddlFilterClnic" class="opd-select" disabled="disabled">
                            <option value="0">Select Clinic</option>
                        </select>
                    </div>
                    <div class="opd-field" id="doctor">
                        <label class="opd-label">Doctor</label>
                        <select id="ddldoctor" class="opd-select">
                            <option value="0">Select Doctor</option>
                        </select>
                    </div>
                    <div class="opd-field" id="pnlcompany">
                        <label class="opd-label">Panel Company</label>
                        <select id="ddlpanel" onchange="getpanelRate();" class="opd-select">
                            <option value="0">Select panel</option>
                        </select>
                    </div>
                    <div class="opd-field" id="discount">
                        <label class="opd-label">Discount %</label>
                        <input type="text" id="txtdiscount" onchange="Calc_Discount()" class="opd-input" />
                    </div>
                    <div class="opd-field" id="Field-CIH">
                        <label class="opd-label">Cash In Hand</label>
                        <select id="ddlCashInHand" class="opd-select"></select>
                    </div>

                    <div class="opd-field" id="employee">
                        <label class="opd-label">Employee ID</label>
                        <input type="text" id="txtemployee" class="opd-input" />
                    </div>
                    <div class="opd-field" id="EmployeeName">
                        <label class="opd-label">Employee Name</label>
                        <input type="text" id="empname" class="opd-input" />
                    </div>
                    <div class="opd-field" id="EmpDep">
                        <label class="opd-label">Employee Department</label>
                        <input type="text" id="EmpDept" class="opd-input" />
                    </div>
                    <div class="opd-field" id="refference">
                        <label class="opd-label">Reference #</label>
                        <input type="text" id="txtreferenceno" class="opd-input" />
                    </div>
                    <div class="opd-field" id="StdName">
                        <label class="opd-label">Student Name</label>
                        <input type="text" id="txtStdName" class="opd-input" />
                    </div>
                    <div class="opd-field" id="rollno">
                        <label class="opd-label">Roll No</label>
                        <select id="ddlrollno" class="opd-select">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="opd-field" id="class">
                        <label class="opd-label">Class</label>
                        <select id="ddlclass" class="opd-select">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="opd-field" id="section">
                        <label class="opd-label">Section</label>
                        <select id="ddlsection" class="opd-select">
                            <option value="0">Select</option>
                        </select>
                    </div>

                    <!-- Checkboxes Section -->
                    <div class="opd-check-row" id="Field_Card">
                        <label class="opd-check">
                            <input type="checkbox" id="chckcardissue" runat="server" class="custom-checkbox" onclick="DisableCardPrint()" />
                            <span class="opd-check-label">Card</span>
                        </label>
                        <label class="opd-check" id="Field_freeCheck">
                            <input type="checkbox" id="chckfreecheck" class="custom-checkbox" />
                            <span class="opd-check-label">Is Revisit</span>
                        </label>
                    </div>
                    <div class="opd-check-row" id="Follow_Up">
                        <span class="opd-check-label" id="Field_FollowUP">
                            <i class="fa fa-refresh" style="color:var(--opd-primary);"></i> Follow Up
                            <span id="follow_up" class="opd-check-value"></span>
                        </span>
                    </div>
                </div>
            </div>
        </div>
    </div>

</div>

    <div class="row">
        <div class=" col-lg-8">
            <div class="row mtop2">
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input type="button" class="btn-primry " id="btnsave" value="Save&Print" onclick="SaveData()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-4">
                    <input type="button" class="btn btn-yellow " id="btnNew" value="New" onclick="window.location = 'OPD.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input type="button" class="btn btn-gray " id="btnView" value="View" onclick="window.location = 'OPDView.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divcardfront">
                    <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCardFront" onclick="getcardAmount()" value="Front Card" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divcardback">
                    <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCardBack" onclick="PrintPatientBackCard()" value="Back Card" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdprint">
                    <input type="button" class="btn-primry " id="btnPrint" value="Print" onclick="OPD_Print('<%= Request.QueryString["OPDID"] %>', '<%= AppConfig.Company_Name %>')" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdFormprint" style="display: none; position: absolute;">
                    <input type="hidden" class="btn-primry " id="btnOPDFormPrint" value="OPD Form" onclick="OPD_Form_Print()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6" id="divvoucher">
                    <input type="button" class="btn-primry " id="btnPrintVoucher" value="Voucher" onclick="PrintVoucher();" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divapprove">
                    <input type="button" class="btn-primry " id="btnapprove" value="Approve" onclick="ApproveOPD()" />
                </div>
            </div>
        </div>
    </div>

    <%--patient modal--%>
    <div id="PatientModel" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Patient Details</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    <div class=" row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txt_Mrno">MR No</label>
                            <input type="text" id="txt_Mrno" class="form-control" disabled />
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6">
                            <label for="ddl_name">Name<span style="color: red;">*</span></label>
                            <select id="ddl_name" class="form-control" style="width: 137%">
                                <option value="Mr.">Mr.</option>
                                <option value="Mrs.">Mrs.</option>
                                <option value="Ms.">Ms.</option>
                                <option value="B/O.">B/O.</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px">
                            <label></label>
                            <input name="dob" type="text" id="txt_name" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                            <select id="ddlRelation" class="form-control">
                                <option value="S/O">S/O</option>
                                <option value="W/O">W/O</option>
                                <option value="D/O">D/O</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label></label>
                            <input type="text" id="txt_relation" class="form-control" style="margin-top: 5px" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="PrefixAge">Age/DOB<span style="color: red;">*</span></label>
                            <select id="PrefixAge" class="form-control">
                                <option value="Year">Year</option>
                                <option value="Month">Month</option>
                                <option value="Day">Day</option>
                            </select>
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6" style="margin-top: 8px;">
                            <label></label>
                            <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" style="width: 137% !important" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px;">
                            <label></label>
                            <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd mmyy" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddl_Gender">Gender<span style="color: red;">*</span></label>
                            <select id="ddl_Gender" class="form-control">
                                <option value="0">Select Gender</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_cnic">CNIC<span style="color: red;">*</span></label>
                            <input type="text" id="txt_cnic" class="form-control" />
                        </div>
                        
                    </div>

                    <div class="row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_OtherCnic">Other CNIC</label>
                            <input type="text" id="txt_OtherCnic" class="form-control" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                            <input type="text" id="txt_mobile" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                            <select id="ddl_status" class="form-control">
                                <option value="0">Select Marial</option>
                            </select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Country</label>
                            <select id="ddlCountry" class="form-control">
                                <option value="0">Select Country</option>
                            </select>
                        </div>                      
                    </div>

                    <div class="row">
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Province</label>
                            <select id="ddl_Province" class="form-control">
                                <option value="0">Select Province</option>
                            </select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label for="txtcity">City</label>
                            <select id="txtcity" class="form-control">
                                <option value="0">Select City</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txtarea">Area</label>
                            <select id="txtarea" class="form-control">
                                <option value="0">Select Area</option>
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_house">Address</label>
                            <input type="text" id="txt_house" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6" style="display:none">
                            <label for="lblfee">Fee<span style="color: red;">*</span></label>
                            <input type="text" tabindex="17" id="txtCardFee" class="form-control" />
                        </div>
                        
                    </div>
                    <div class="form-group row" style="display: none;">
                        <label for="txt_Address" class="col-sm-3 col-form-label">Address<span style="color: red;">*</span></label>
                        <div class="col-sm-9">
                            <input type="text" id="" class="form-control" />
                        </div>
                        <div class="col-lg-6 col-md-4 col-sm-6" style="display: none">
                            <label for="txtstrm">St#/Mh#/Rd#/<span style="color: red;">*</span></label>
                            <input type="text" id="txtstrm" class="form-control" />
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primry" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                    <button type="button" class="btn btn-secondary" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <div id="PatientsSearchModel" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblPatientsResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Contact No</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="iPatientsBody">
                                <!-- Dynamic rows go here -->
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
    <div id="SearchModel_App" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <label for="txtSearchmodal">Search Your Patients:</label>
                                <input type="text" id="txtSearchmodal" class="form-control" autocomplete="off" placeholder="Enter search text" />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive" id="scrollable-table-container">
                        <table class="table table-hover table-striped table-bordered" id="tblResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>App No</th>
                                    <th>App Date</th>
                                    <th>Patient Name</th>
                                    <th>Doctor Name</th>
                                    <th>Age</th>
                                    <th>Mobile</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="ibody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <div id="SearchEmergencyPatients" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtEmergencySearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblEmergencyResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Contact No</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="EmergencyPatientsBody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>

    <div id="SearchReferPatients" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtReferEmergencySearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="ReferEmergencyResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Doctor</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="ReferPatientsBody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
