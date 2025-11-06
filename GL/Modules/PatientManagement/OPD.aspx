<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script src="../../wwwroot/Tibbit_theme/CustomJs/OPD.js" type="text/javascript"></script>
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/OPD.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">
      
        $(document).ready(function () {

     
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
                if (reg_id != "" && added == "true") {
                    Get_Pat_Info(reg_id);
               
                    $('#ddlPatient_Type').attr('disabled', false);
                    $('#ddlcashier').attr('disabled', true);
                }
     
                if (apt_Id != "" && apdAdd == "true") {
                    Get_Pat_Info_Apt(reg_id, apt_Id);
           
                    $('#ddlPatient_Type').attr('disabled', false);
                    $('#ddlcashier').attr('disabled', true);
                }
            debugger;
            if (Reffered_id != "" && added == "true") {
                debugger;
                $("#hdn_emer_reffered").val(Reffered_id);
                console.log(Reffered_id);
                    Get_Pat_Info(Reffered_id);
                    
                    $('#ddlPatient_Type').attr('disabled', false);
                    $('#ddlcashier').attr('disabled', true);
                }
            

        });
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
            "field_Clinic": "FilterClinic"
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
            $('#ddlPatient_Type').attr('disabled', true);
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
                $('#fees').show();
                $('#department').show();
                $('#doctor').show();
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
        }
        function Approve() {
            var pat_id = '<% =Request.QueryString["OPDID"] %>';
            var Pat_Category = $('#ddlPatient_Type').val();

            PageMethods.approvepatient(pat_id, Pat_Category, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
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
        //Print
        function OPD_Print() {
            debugger;
            var ID = '<%= Request.QueryString["OPDID"]%>';
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=" + ID;
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=OPD_Patient_Print&Title=OPD Patient Print &OPD_ID=" + ID;
            }
            window.open(url, '_blank');
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
                    var url = "ReportViewer.aspx?ReportName=PrintPatientBackCard&ReportTitle=Patient Registration Card&MrNo=" + Patient_ID;
                    window.open(url);
                }


        function PrintVoucher() {
            var id = '<% =Request.QueryString["OPDID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OJV Voucher&TransID=' + id + '&TransType=OJV';
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OJV Voucher&TransID=' + id + '&TransType=OJV';
            }
            window.open(url, '_blank');
        }

        function loaddoctor() {
            debugger;
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

                        if (type != "02") {

                            getGeneralFee();
                        }

                    },
                    error: function (xhr, status, error) {
                        console.log("Error: " + error);
                    }
                });
            }
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

                        $('#txtactualfee').val(code);
                        
          
                        if (
                            (type === "04" && type_text === "Employee") ||
                            (type === "05" && type_text === "Student") ||
                            (type === "06" && type_text === "Refer")
                        )
                        {
                            $('#txtdiscount').val(100);
                            $('#txtactualfee').val(code);
                            $('#txtdiscount').attr('disabled', true); 
                            $('#txtfees').val(0);                 
                            $('#hdnDocshare').val(dShare);
                            $('#hdnhospShare').val(hShare);
                        }
                        else {
                           
                            $('#txtdiscount').val("");           
                            $('#txtdiscount').attr('disabled', false); 
                            $('#txtfees').val(code);
                            $('#txtactualfee').val(code);
                            $('#hdnDocshare').val(dShare);
                            $('#hdnhospShare').val(hShare);
                        }
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
                        if (type != "02") {

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
            var emer_reffered = $("#hdn_emer_reffered").val();
            if (emer_reffered != "") {
                $('#txtfees').val("0");
            }

            else {
                if (opdid != "" || opdid != "") {

                } else {
                    $.ajax({
                        type: "POST",
                        url: "OPD.aspx/loadRegistrationFees",
                        data: JSON.stringify({ Doc: Doc }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            debugger;
                            var res = JSON.parse(response.d);
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

                                var fee = res.fee;
                                var disper = res.discount_percentage           
                                var afterdiscountfee = fee - ((fee * disper) / 100)

                                $('#txtfees').val(afterdiscountfee);
                                $('#txtactualfee').val(res.fee);
                                $('#txtdiscount').val(res.discount_percentage);
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

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
    <!-- Anti-CSRF Token -->
<input type="hidden" id="hfAntiForgery" runat="server" />
    <input type="text " id="hdfPatient_ID" style="display: none;" />
    <input type="text" id="hdn_aptid" style="display: none;" />
    <input type="text" id="hdn_regid" style="display: none;" />
    <input type="text" id="hdn_opdId" style="display: none;" />
    <input type="text" id="hdnDocshare" style="display: none;" />
    <input type="text" id="hdnhospShare" style="display: none;" />
    <input type="text" id="hdn_emer_reffered" style="display: none;" />
    <input type="text" id="hdn_dep_id" style="display: none;" />
    <div class="row">
        <%--<div class="col-lg-9 col-md-9 col-sm-12 card" style="width: 73%; margin-left: 13px;">
            <div class="col-lg-3 col-md-4 col-sm-12" onclick="addfunc()" style="cursor: pointer;">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Register Icon" width="32" height="32">
                    <span><a class="anchorOnOPD">Register a new patient</a></span>
                </div>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" style="cursor: pointer" id="btnSearchApp_Patient" onclick="SearchPop_App()">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/appointmenticon.png" width="32" height="32">
                    <span><a class="anchorOnOPD">Search in appointment</a></span>
                </div>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" style="cursor: pointer" id="btnsearchpatlist">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/existingpaticon.png" alt="Search" h="32" height="32">
                    <span><a class="anchorOnOPD">Search an existing patient</a></span>
                </div>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" style="cursor: pointer" id="btnsearchEmergencylist">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/existingpaticon.png" alt="Search" h="32" height="32">
                    <span><a class="anchorOnOPD">Emergency Refer Patient</a></span>
                </div>
            </div>
        </div>--%>




        <div class="col-lg-9 col-md-9 col-sm-12" style="width: 73%; margin-left: 13px;">
    <!-- Quick Actions row: four equal, high-contrast cards -->
    <div class="row" style="margin: 8px;">
        <!-- Card 1 -->
        <div class="col-lg-3 col-md-3 col-sm-6 mb-3">
            <div id="card-register" role="button" tabindex="0"
                 onclick="addfunc()"
                 onkeypress="if(event.key==='Enter'){ addfunc(); }"
                 class="d-flex flex-column justify-content-center align-items-start"
                 style="background:#EFA63E; color:#000; border-radius:8px; padding:12px; height:70px; cursor:pointer;">
                <div class="d-flex align-items-center">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Register Icon" width="48" height="48" style="margin-right:10px;">
                    <div>
                        <div style="font-weight:700; font-size:1.5rem;">Register a new patient</div>
                        <div style="font-size:0.95rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">Create a new patient record</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 2 -->
        <div class="col-lg-3 col-md-3 col-sm-6 mb-3">
            <div id="card-search-appointment" role="button" tabindex="0"
                 onclick="SearchPop_App()"
                 onkeypress="if(event.key==='Enter'){ SearchPop_App(); }"
                 class="d-flex flex-column justify-content-center align-items-start"
                 style="background:#EFA63E; color:#000; border-radius:8px; padding:12px; height:70px; cursor:pointer;">
                <div class="d-flex align-items-center">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/appointmenticon.png" alt="Search Appointment Icon" width="48" height="48" style="margin-right:10px;">
                    <div>
                        <div style="font-weight:700; font-size:1.5rem;">Search in appointment</div>
                        <div style="font-size:0.95rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">Find patient appointments</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 3 -->
        <div class="col-lg-3 col-md-3 col-sm-6 mb-3">
            <div id="btnsearchpatlist" role="button" tabindex="0"
                 onclick="/* add search patient function here, e.g. openPatientSearch() */"
                 onkeypress="if(event.key==='Enter'){ /* openPatientSearch(); */ }"
                 class="d-flex flex-column justify-content-center align-items-start"
                 style="background:#EFA63E; color:#000; border-radius:8px; padding:12px; height:70px; cursor:pointer;">
                <div class="d-flex align-items-center">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Search Patient Icon" width="48" height="48" style="margin-right:10px;">
                    <div>
                        <div style="font-weight:700; font-size:1.5rem;">Search an existing patient</div>
                        <div style="font-size:0.95rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">Lookup patient details</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Card 4 -->
        <div class="col-lg-3 col-md-3 col-sm-6 mb-3">
            <div id="btnsearchEmergencylist" role="button" tabindex="0"
                 onclick="/* add emergency refer function here, e.g. referToEmergency() */"
                 onkeypress="if(event.key==='Enter'){ /* referToEmergency(); */ }"
                 class="d-flex flex-column justify-content-center align-items-start"
                 style="background:#EFA63E; color:#000; border-radius:8px; padding:12px; height:70px; cursor:pointer;">
                <div class="d-flex align-items-center">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Emergency Refer Icon" width="48" height="48" style="margin-right:10px;">
                    <div>
                        <div style="font-weight:700; font-size:1.5rem;">Emergency Refer Patient</div>
                        <div style="font-size:0.95rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">Refer patient to emergency</div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <div class="card3">
                <span style="font-size: 15px;">Total OPD</span>
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lbltotpat" class="blink" runat="server"></span>

          

                <span style="font-size: 15px;">Recent Visit</span>
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="Span2" class="blink" runat="server"></span>


                <span style="font-size: 15px;">Previous Visit </span>
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="Span6" class="blink" runat="server"></span>
                  </div>
        </div>
    </div>

    <div class="row mtop">
        <div class="col-lg-9 col-md-8 sm-12">
            <div class="card">
                <div class="row show g-3">

                    <input type="text" id="txt_reg_patno" style="display: none" />
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_mr_no">
                        <label>MR No</label>
                        <input type="text" runat="server" id="txtPatient_ID" style="display: none" />
                        <input type="text" id="txtpatient_no" style="display: none" />
                        <input type="text" id="txtPatientNo" value="New" readonly="readonly" />
                        <input type="hidden" id="hdnPatientID" runat="server" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Patient_name">
                        <label>Name *</label>
                        <input type="text" id="txt_patname" value="" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Last_name">
                        <label>Last Name *</label>
                        <input type="text" id="txt_F_Name" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_OPD_No">
                        <label>OpdNo *</label>
                        <input type="text" id="txt_opd_no" value="New" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Mode_Reg">
                        <label>Mode Of Presentation</label>
                        <select id="ddlMode_Of_Registration" readonly="readonly"></select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Mobile">
                        <label>Mobile *</label>
                        <input type="text" id="txtmobile" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_CNIC">
                        <label>CNIC *</label>
                        <input type="text" id="txtnic" value="" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Category">
                        <label>Patient Category</label>
                        <select id="ddlPatient_Type" disabled>
                            <option value="0">Select Category</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Martial_Status">
                        <label>Martial Status</label>
                        <select id="ddlmartialstatus" disabled>
                             <option value="0">Select Status</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_age">
                        <label>Age</label>
                        <input type="text" id="txtage" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Gender">
                        <label>Gender</label>
                        <select id="ddlGender" disabled >
                             <option value="0">Select Gender</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Fee">
                        <label>Fee</label>
                        <input type="text" id="txtfees" readonly="readonly" class="form-control" />
                        <input type="text" id="txtactualfee" style="display:none;"  class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Services">
                        <label>Services</label>
                        <select id="ddlServices">
                            <option value="0">Select Service</option>
                        </select>
                    </div>

                    <div class="col-lg-12 col-md-12 col-sm-12" id="field_Address">
                        <label>Address</label>
                        <input type="text" id="txtAdrress" readonly="readonly" />
                    </div>

                </div>





            </div>


        </div>

        <div class="col-lg-3 col-md-4" id="right-section">
            <div class="row card2">
                <!-- Other form elements -->
                <div class="col-lg-12 col-md-12 col-sm-12" id="department">
                    <label>Department</label>
                    <select id="ddlDepartment"  class="form-control">
                        <option value="0">Select Department</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="field_Clinic">
                    <label>Filter Clinic</label>
                    <select id="ddlFilterClnic" class="form-control">
                        <option value="0">Select Clinic</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="doctor">
                    <label>Doctor</label>
                    <select id="ddldoctor"  class="form-control">
                        <option value="0">Select Doctor</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="pnlcompany">
                    <label>Panel company</label>
                    <select id="ddlpanel" onchange="getpanelRate();" class="form-control">
                        <option value="0">Select panel</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="employee">
                    <label>Employee ID</label>
                    <input type="text" id="txtemployee" class="form-control" />
                </div>
                  <div class="col-lg-12 col-md-12 col-sm-12" id="EmployeeName">
                    <label>Employee Name</label>
                    <input type="text" id="empname" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="EmpDep">
                    <label>Employee Department</label>
                    <input type="text" id="EmpDept" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="refference">
                    <label>Reference #</label>
                    <input type="text" id="txtreferenceno" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="discount">
                    <label>Discount %</label>
                    <input type="text" id="txtdiscount" onchange="Calc_Discount()" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="StdName">
                    <label>Student Name</label>
                    <input type="text" id="txtStdName" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="rollno">
                    <label>Roll No</label>
                    <select id="ddlrollno" class="form-control">
                        <option value="0">Select</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="class">
                    <label>Class</label>
                    <select id="ddlclass" class="form-control">
                        <option value="0">Select</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="section">
                    <label>Section</label>
                    <select id="ddlsection" class="form-control">
                        <option value="0">Select</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" style="display: none">
                    <label>Cashier</label>
                    <select id="ddlcashier" class="form-control"></select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="Field-CIH">
                    <label>Cash In Hand</label>
                    <select id="ddlCashInHand">
                    </select>
                </div>

                <!-- Checkboxes Section -->
                <div class="row " style="width: 100%;" id="Field_Card">
                    <div class="col-lg-5 col-md-4 col-sm-6 d-flex align-items-center mtop mleft">
                        <label for="chckcardissue" class="ml-2">Card</label>
                        <input type="checkbox" id="chckcardissue" runat="server" class="custom-checkbox" onclick="DisableCardPrint()" />
                    </div>

                    <div class="col-lg-5 col-md-4 col-sm-6 d-flex align-items-center mtop" id="Field_freeCheck">
                        <label for="chckfreecheck" class="ml-2 wdth">Free Check</label>
                        <input type="checkbox" id="chckfreecheck" class="custom-checkbox " />
                    </div>
                </div>
                <div class="row" style="width: 100%;" id="Follow_Up">
                    <div class="col-lg-5 col-md-4 col-sm-6 d-flex align-items-center mtop" id="Field_FollowUP">
                        <label for="lblfollowup" class="ml-2">Follow Up</label>
                        <span id="follow_up"></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row mtop">
        <div class=" col-lg-8">
            <div class="row">
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
                    <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCardBack" onclick="getcardAmount()" value="Back Card" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdprint">
                    <input type="button" class="btn-primry " id="btnPrint" value="Print" onclick="OPD_Print()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdFormprint" style="display: none;">
                    <input type="hidden" class="btn-primry " id="btnOPDFormPrint" value="OPD Form" onclick="OPD_Form_Print()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6" id="divvoucher">
                    <input type="button" class="btn-primry " id="btnPrintVoucher" value="Voucher" onclick="PrintVoucher();" style="display: none;" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divapprove">
                    <input type="button" class="btn-primry " id="btnapprove" value="Approve" onclick="Approve()" style="display: none;" />
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
                            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                            <input type="text" id="txt_mobile" class="form-control" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                            <select id="ddl_status" class="form-control">
                                  <option value="0">Select Marial</option>
                            </select>
                        </div>
                        <div class="col-lg-2 colmd-4 col-sm-6">
                            <label>Country</label>
                            <select id="ddlCountry" class="form-control">
                                  <option value="0">Select Country</option>
                            </select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Province</label>
                            <select id="ddl_Province" class="form-control">
                                  <option value="0">Select Province</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label for="txtcity">City</label>
                            <select id="txtcity" class="form-control">
                                  <option value="0">Select City</option> 
                            </select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtarea">Area</label>
                            <select id="txtarea" class="form-control">
                                 <option value="0">Select Area</option>  
                            </select>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <label for="txt_house">Address</label>
                            <input type="text" id="txt_house" class="form-control" />
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
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>Appointment No</th>
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
</asp:Content>
