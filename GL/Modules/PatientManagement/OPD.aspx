<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript" src="../../wwwroot/Tibbit_theme/CustomJs/OPD.js"></script>
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/OPD.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            loadOPDPermissions();
            DisableCardPrint();

            var reg_id = '<%= Request.QueryString["ID"] %>'
            var apt_Id = '<%= Request.QueryString["apt_id"] %>'
            var added = '<%= Request.QueryString["isAdd"] %>'
            var apdAdd = '<%= Request.QueryString["isAdd_apt"] %>'
            var OPDID = '<%= Request.QueryString["OPDID"] %>'
            $("#hdn_opdId").val(OPDID);
            if (OPDID != "") {

                loadPatientDetail(OPDID);
                $('#btn-opdprint').show();
                $('#btn-opdFormprint').show();

            }
            else {

                $('#ddl_Gender').select2();
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
          
            

        });
        function DisableCardPrint() {
            var chkStatus = document.getElementById('<%=chckcardissue.ClientID%>');
            if (chkStatus.checked) {
                $('#divcard').show();
                $('#btnPrintBackCard').show()
            }
            else {
                $('#divcard').hide();
                $('#btnPrintBackCard').hide()
            }
        }


        function loadOPDPermissions() {
            $.ajax({
                type: "POST",
                url: "OPD.aspx/GetCompanyOPDPermissions",  // Correct page name
                data: "{}",  // ← Required even for no parameters
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    
                    var permissions = response.d;

                    var fieldContainers = {
                        "mr_no": "field_mr_no",
                        "patient_name": "field_Patient_name",
                        "last_name": "field_Last_name",
                        "opd_no": "field_OPD_No",
                        "cash_in_hand": "Field-CIH",
                        "mode_presentation": "field_Mode_Reg",
                        "mobile": "field_Mobile",
                        "cnic": "field_CNIC",
                        "patient_category": "field_Category",
                        "marital_status": "field_Martial_Status",
                        "age": "field_age",
                        "gender": "field_Gender",
                        "fee": "field_Fee",
                        "address": "field_Address",
                        "card": "Field_Card",
                        "follow_up": "Field_FollowUP",
                        "Services": "field_Services",
                        "FilterClinic": "field_Clinic",
                    };

                    for (var dbField in fieldContainers) {
                        
                        var containerId = fieldContainers[dbField];
                        var $container = $("#" + containerId);

                        if ($container.length > 0) {
                            if (permissions[dbField] === true) {
                                $container.show();
                            } else {
                                $container.hide();
                            }
                        }
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    console.error("Response:", xhr.responseText);
                    alert("Could not load form settings.");
                }
            });
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

            console.log(ID);
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
            var Department_id = $('#ddlDepartment').val();

            $.ajax({
                url: 'OPD.aspx/GetFees',
                type: 'POST',
                data: JSON.stringify({ Department_id: Department_id }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    $('#txtfees').val(data.Code);
                    //sharing if private()
                    $('#hdnDocshare').val(data.D_Share);
                    $('#hdnhospShare').val(data.H_Share);

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
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />

    <input type="text " id="hdfPatient_ID" style="display: none;" />
    <input type="text" id="hdn_aptid" style="display: none;" />
    <input type="text" id="hdn_regid" style="display: none;" />
    <input type="text" id="hdn_opdId" style="display: none;" />
    <input type="text" id="hdnDocshare" style="display: none;" />
    <input type="text" id="hdnhospShare" style="display: none;" />
    <div class="row">
        <div class="col-lg-9 col-md-9 col-sm-12 card" style="width: 73%; margin-left: 13px;">
            <div class="col-lg-4 col-md-4 col-sm-12" onclick="addfunc()" style="cursor: pointer;">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Register Icon" width="32" height="32">
                    <span><a class="anchorOnOPD">Register a new patient</a></span>
                </div>
            </div>
            <div class="col-lg-4 col-md-4 col-sm-12" style="cursor: pointer" id="btnSearchApp_Patient" onclick="SearchPop_App()">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/appointmenticon.png" width="32" height="32">
                    <span><a class="anchorOnOPD">Search in appointment</a></span>
                </div>
            </div>
            <div class="col-lg-4 col-md-4 col-sm-12" style="cursor: pointer" id="btnsearchpatlist">
                <div class="icon-text">
                    <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/existingpaticon.png" alt="Search" h="32" height="32">
                    <span><a class="anchorOnOPD">Search an existing patient</a></span>
                </div>
            </div>
        </div>

        <div class="col-lg-3 col-md-3 col-sm-4">
            <div class="card3">
                <span style="font-size: 15px;">Total OPD</span>
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lbltotpat" class="blink" runat="server"></span>
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
                        <select id="ddlmartialstatus">
                             <option value="0">Select Status</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_age">
                        <label>Age</label>
                        <input type="text" id="txtage" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Gender">
                        <label>Gender</label>
                        <select id="ddlGender">
                             <option value="0">Select Gender</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Fee">
                        <label>Fee</label>
                        <input type="text" id="txtfees" readonly="readonly" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Services">
                        <label>Services</label>
                        <select id="ddlServices">
                            <option value="0">Select Service</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12" id="field_Clinic">
                        <label>Filter Clinic</label>
                        <select id="ddlFilterClnic">
                            <option value="0">Select Clinic</option>
                        </select>
                    </div>
                    <div class="col-lg-12 col-md-12 col-sm-12" id="field_Address">
                        <label>Address *</label>
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
                <div class="col-lg-12 col-md-12 col-sm-12" id="refference">
                    <label>Reference #</label>
                    <input type="text" id="txtreferenceno" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="discount">
                    <label>Discount %</label>
                    <input type="text" id="txtdiscount" onchange="Calc_Discount()" class="form-control" />
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
                    <div class="col-lg-5 col-md-4 col-sm-6 d-flex align-items-center mtop" id="Field_FollowUP">
                        <label for="lblfollowup" class="ml-2">Follow Up</label>
                        <span id="follow_up"></span>
                    </div>

                </div>
                <div class="row" style="display: none">
                    <div class="col-lg-7 col-md-4 col-sm-6 d-flex align-items-center mtop" style="display: none">
                        <label for="chckfreecheck" class="ml-2 wdth">Free Check</label>
                        <input type="checkbox" id="chckfreecheck" class="custom-checkbox " />
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
                <div class="col-lg-2 col-md-3 col-sm-4" id="divcard">
                    <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCard" onclick="getcardAmount()" value="Card" />
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
                            <select id="ddl_status" class="form-control"></select>
                        </div>
                        <div class="col-lg-2 colmd-4 col-sm-6">
                            <label>Country</label>
                            <select id="ddlCountry" class="form-control"></select>
                        </div>
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label>Province</label>
                            <select id="ddl_Province" class="form-control"></select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-3 colmd-4 col-sm-6">
                            <label for="txtcity">City</label>
                            <select id="txtcity" class="form-control"></select>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtarea">Area</label>
                            <select id="txtarea" class="form-control"></select>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <label for="txt_house">Address</label>
                            <input type="text" id="txt_house" class="form-control" />
                        </div>
                    </div>
                    <div class="form-group row" style="display: none;">
                        <label for="txt_Address" class="col-sm-3 col-form-label">Address<span style="color: red;">*</span></label>
                        <div class="col-sm-9">
                            <input type="text" id="txt_Address" class="form-control" />
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
</asp:Content>
