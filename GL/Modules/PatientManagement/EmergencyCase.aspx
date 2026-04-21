<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyCase.aspx.cs" Inherits="PMS.EmergencyCase" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
  
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Emergency.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
        <style type="text/css">
            .file-upload-wrapper {
                display: flex;
                align-items: center;
                flex-wrap: wrap;
                gap: 0.5rem;
            }
        </style>
  <script type="text/javascript">
      document.addEventListener("DOMContentLoaded", function () {
          var textBox = document.getElementById("<%= txtCallToDoctor.ClientID %>");

         if (textBox) {
             // Add initial bullet if textbox is empty on focus
             textBox.addEventListener("focus", function () {
                 if (this.value.trim() === "") {
                     this.value = "• ";
                 }
             });

             textBox.addEventListener("keydown", function (e) {
                 if (e.key === "Enter") {
                     e.preventDefault(); // Prevent default newline

                     var start = this.selectionStart;
                     var end = this.selectionEnd;
                     var value = this.value;

                     // Get current line content before cursor
                     var beforeCursor = value.substring(0, start);
                     var lastNewline = beforeCursor.lastIndexOf("\n");
                     var currentLine = beforeCursor.substring(lastNewline + 1);

                     // Check if current line already has a bullet
                     var hasBullet = currentLine.trim().startsWith("•");

                     // If line has content (not just bullet), add new bullet on next line
                     var lineContent = currentLine.replace(/^•\s*/, "").trim();

                     if (lineContent.length > 0 || (hasBullet && currentLine.trim() === "•")) {
                         // Add newline with bullet
                         this.value = value.substring(0, start) + "\n• " + value.substring(end);
                         this.selectionStart = this.selectionEnd = start + 3; // Move cursor after bullet and space
                     } else {
                         // Just add newline without bullet if line is empty
                         this.value = value.substring(0, start) + "\n" + value.substring(end);
                         this.selectionStart = this.selectionEnd = start + 1;
                     }
                 }
             });
         }
     });
  </script>
    <script type="text/javascript">
        var btnVal = '';
        localStorage.IsDischarge = 0;

        $(document).ready(function () {
            $('#OtherDetails').hide();
            $('#deathtab').hide();

            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtCNIC'),
                format: '_____-_______-_',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMobileNo'),
                format: '____-_______',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtBP'),
                format: '___/___',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtBPDischarge'),
                format: '___/___',
                separator: '-'
            });
            // Reference the elements
            var txtEOR = document.getElementById('ctl00_MainContent_ctl00_MainContent_txtEOR');
            var txtMR = document.getElementById('ctl00_MainContent_txtMR');
            var txtVR = document.getElementById('ctl00_MainContent_txtVR');
            var txtAcc = document.getElementById('ctl00_MainContent_txtAcc');

            // Set default values
            if (txtEOR) txtEOR.value = '4/4';
            if (txtMR) txtMR.value = '5/5';
            if (txtVR) txtVR.value = '6/6';
            if (txtAcc) txtAcc.value = '15/15';
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_ctl00_MainContent_txtEOR'),
                format: '_/4',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMR'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtVR'),
                format: '_/6',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtAcc'),
                format: '_/15',
                separator: '/'
            });

            $('#txt_cnic').attr('placeholder', '_____-_______-_');

            MaskedInput({
                elm: document.getElementById('txt_cnic'),
                format: '_____-_______-_',
                separator: '-'

            });

            var Reg_ID = '<%= Request.QueryString["Reg_ID"] %>';

            if (Reg_ID && Reg_ID !== "undefined" && Reg_ID.trim() !== "") {
                $('#hdfPatient_ID').val(Reg_ID);

                setTimeout(function () {
                    selectPatient(Reg_ID);

                }, 1000);
            }
            else {

            }
            var Emergency_id = '<%= Request.QueryString["ID"] %>';
            if (Emergency_id != "") {
                AllowEmergencyEdit();
            }
            if (Reg_ID == "" && Emergency_id == "") {
                OpenModal()
            }

            AllowDiscountEdit();
            fillmartial();
            fillgender();
            AllowEMRGTabs();
            LoadInvestigationDoctor();
            LoadTemplate();
            LoadTemplateForTest();
            LoadDischargeTemplate();




            //jQuery(function ($) {

            //    MaskedInput({
            //        elm: document.getElementById('txtSearch'),
            //        format: '+92__________',
            //        separator: '-'
            //    });

            //    var phoneInput = document.getElementById('txtSearch');
            //    phoneInput.addEventListener("focus", function () {
            //        if (!this.value.startsWith("+92")) {
            //            this.value = "+92";
            //        }
            //        this.setSelectionRange(3, 3);
            //    });

            //    phoneInput.addEventListener("keydown", function (e) {
            //        if (this.selectionStart <= 3 && (e.key === "Backspace" || e.key === "Delete")) {
            //            e.preventDefault();
            //        }
            //        if (this.selectionStart < 3) {
            //            this.setSelectionRange(3, 3);
            //        }
            //    });

            //});

            $("#txtSearch").keyup(function (event) {
                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillPatientsList();
            });

            $("#ctl00_MainContent_ddlDeathCertifiedbyDr1").select2();
            $("#ctl00_MainContent_ddlDeathCertifiedbyDr2").select2();
            $("#ctl00_MainContent_ddlDoctor").select2();
            $("#ddlInvestigationDoctor").select2();
            $("#ctl00_MainContent_ddlCallToDoctor").select2();
            $("#ctl00_MainContent_ddlDischarge_By").select2();
            $("#ctl00_MainContent_ddl_Department").select2();
            $("#ctl00_MainContent_txtSaturation").focusin(function () {

                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtsaturationDis").focusin(function () {

                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen2").focusin(function () {

                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen2_desc").focusin(function () {

                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation,#ctl00_MainContent_txtSaturation_Oxygen2").focusout(function () {

                if ($(this).val() == " %") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " %");
                }
            });
            $("#ctl00_MainContent_txtsaturationDis,#ctl00_MainContent_txtSaturation_Oxygen2_desc").focusout(function () {

                if ($(this).val() == " %") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " %");
                }
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen1").focusin(function () {

                var textOxygen = $(this).val().replace(" L/Min", "");
                $(this).val(textOxygen);
            });
            $("#ctl00_MainContent_txtOxygen1").focusin(function () {

                var textOxygen = $(this).val().replace(" L/Min", "");
                $(this).val(textOxygen);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen1").focusout(function () {

                if ($(this).val() == " L/Min") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " L/Min");
                }
            });
            $("#ctl00_MainContent_txtOxygen1").focusout(function () {

                if ($(this).val() == " L/Min") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " L/Min");
                }
            });


            $("#ctl00_MainContent_ddlPatientCondition").on("change", function myfunction() {


                var Min = $(this).children(":selected").attr('name');
                if (typeof (Min) != "undefined") {




                    var Minutes = parseInt(Min, 10);

                    //var datetime = '<% = DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt")%>';

                    var datetime = new Date();
                    var time = moment(datetime);
                    var newTime = moment(time).add('m', Minutes);
                    var date = moment(newTime).format("M/DD/YYYY LTS");
                    $("#ctl00_MainContent_txtTreatmentTime").val(date);
                    $("#ctl00_MainContent_cb_death").val(date);


                }
            });
            setTimeout(function () {
                var er_id = '<%= Request.QueryString["ID"]%>';
                debugger;
                if (er_id !== "") {
                    debugger;

              <% if (PatientDischargeStatus == true)
        { %>

                    $("#btnDischargeSummary").removeAttr("disabled");
                    $("#btnBasePrintPrint").removeAttr("disabled");
                    $("#btnSave").attr("disabled", true);

                 <% } %>


                }
            }, 1500);
            LoadCategory();


            $("#txtSearch").keyup(function (event) {

                var SearchString = $('#txtSearch').val();
                event.preventDefault();

                PageMethods.AddPatient(SearchString, OnFilterPatients, OnFailPatients);

            });

            if ($('#txtPharmacyItem').length > 0) {
            $('#txtPharmacyItem').select2({
            width: '100%',
            placeholder: 'Select Medicine',
            allowClear: true
               });

        // 2. Attach the event listener to load template on selection
        $('#txtPharmacyItem').on('select2:select', function (e) {
            getTemplate();
        });
    }

        });

        function getTemplate() {
    var item_id = $('#txtPharmacyItem').val();
    
    // Validate if a valid item is selected
    if (!item_id || item_id === "0" || item_id === "") {
        return;
    }

    PageMethods.loadtemplate(item_id, function (resp) {
        try {
            var data = JSON.parse(resp);
            if (data && data.length > 0) {
                var templateData = data[0];
                
                // Use helper function to set dropdowns by text match
                setDropdownText('#ddlDosage_Qty', templateData.Dosage_Qty);
                setDropdownText('#ddlDosage_From', templateData.Dosage_From);
                setDropdownText('#txtRecomended_Dosage', templateData.Frequency);
                setDropdownText('#Routes', templateData.Oral);
                
                // Set text inputs directly
                $('#txtInjection').val(templateData.Injections || '');
                $('#AttendingParamedicalStaff').val(templateData.AttendingParamedical_Staff || '');
                setDropdownText('#ddlOther_Instruction', templateData.Other_Instruction);
            }
        } catch (e) {
            console.error("Error parsing template data", e);
        }
    }, function (error) {
        console.error("Error loading template", error.get_message ? error.get_message() : error);
    });
}

function setDropdownText(selector, text) {
    var dropdown = $(selector);
    if (!text) return;

    var matchFound = false;
    dropdown.find('option').each(function () {
        if ($(this).text().trim().toLowerCase() === text.trim().toLowerCase()) {
            dropdown.val($(this).val()).trigger('change');
            matchFound = true;
            return false; 
        }
    });
    if (!matchFound) {
    }
}

        var tabsEmr;
        function AllowEMRGTabs() {
            debugger;
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/checkEMRG_tabs",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    tabsEmr = data.d;

                    if (tabsEmr == "true") {
                        $('#ui-id-1').hide();
                        $('#ui-id-11').show();
                        $('#ui-id-2').hide();
                        $('#ui-id-3').hide();
                        $('#ui-id-4').hide();
                        $('#ui-id-5').hide();
                        $('#ui-id-6').hide();
                        $('#ui-id-7').hide();
                        $('#ui-id-8').hide();
                        $('#ui-id-9').hide();
                        $('#ui-id-10').hide();
                    }
                    else {
                        $('#ui-id-1').hide();
                        $('#ui-id-2').show();
                        $('#ui-id-3').show();
                        $('#ui-id-4').show();
                        $('#ui-id-5').show();
                        $('#ui-id-6').show();
                        $('#ui-id-7').show();
                        $('#ui-id-8').show();
                        $('#ui-id-9').show();
                        $('#ui-id-10').show();
                        $('#ui-id-11').show();
                    }

                },
                failure: function () {
                    alert(bi);
                }
            });
        }
        var originalFee;
        function Calc_Discount() {
            debugger;

            var disc_perc = $('#ctl00_MainContent_txtDiscount').val();
            var currentFee = $('#ctl00_MainContent_txtadmissionfee').val();


            if (!originalFee) {
                originalFee = Number(currentFee);
            }

            if (disc_perc && !isNaN(disc_perc) && originalFee && !isNaN(originalFee)) {

                var discountAmount = (Number(disc_perc) / 100) * originalFee;
                var discountedFee = originalFee - discountAmount;

                $('#ctl00_MainContent_txtadmissionfee').val(discountedFee.toFixed(0));
            } else {
                $('#ctl00_MainContent_txtadmissionfee').val(originalFee.toFixed(0));
            }
        }

        function showdeathtab() {
            debugger;
            var chck_death = $("#ctl00_MainContent_cb_death").prop('checked')
            if (chck_death == true) {
                $('#deathtab').show();
            }
            else {
                $('#deathtab').hide();
            }
        }
        function ROPFunction() {
            if ($("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0] > 0 && $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0] <= 4) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');

                return true;
            }
            else {
                alert('Please input a number between 1 and 4:');
                return $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val('_/4');

            }
        }
        function MRFunction() {
            if ($("#ctl00_MainContent_txtMR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtMR").val().split('/')[0] <= 5) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');
                return true;
            }
            else {
                alert('Please input a number between 1 and 5:');
                return $("#ctl00_MainContent_txtMR").val('_/5');
            }
        }
        function VRFunction() {

            if ($("#ctl00_MainContent_txtVR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtVR").val().split('/')[0] <= 6) {
                var first_integer = $("#ctl00_MainContent_ctl00_MainContent_txtEOR").val().split('/')[0];
                var Second_integer = $("#ctl00_MainContent_txtMR").val().split('/')[0];
                var Third_integer = $("#ctl00_MainContent_txtVR").val().split('/')[0];
                if (first_integer == "_") first_integer = 0;
                if (Second_integer == "_") Second_integer = 0;
                if (Third_integer == "_") Third_integer = 0;
                var sum = parseInt(first_integer) + parseInt(Second_integer) + parseInt(Third_integer);
                $("#ctl00_MainContent_txtAcc").val('' + sum + '/15');
                return true;
            }
            else {

                alert('Please input a number between 1 and 6:');
                return $("#ctl00_MainContent_txtVR").val('_/6');
            }
        }

        function Get_Doctor_Info(callback) {

            var Doctor_Val = document.getElementById('<%= ddl_Department.ClientID%>').value;
            if (Doctor_Val == 0) {
                $('#ctl00_MainContent_ddlCallToDoctor').val('');
                if (typeof callback === 'function') {
                    callback();
                }
            }
            else {
                var department_Id = $('#ctl00_MainContent_ddl_Department').val();
                $.ajax({
                    type: "POST",
                    url: "EmergencyCase.aspx/Get_Doctor",
                    data: JSON.stringify({
                        "department_Id": department_Id
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        var options = '<option value="0">Please Select </option>';
                        var Parsed_Data = JSON.parse(response.d);
                        $.each(Parsed_Data, function (key, value) {

                            options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                        });
                        $('#ctl00_MainContent_ddlCallToDoctor').html(options);
                        $("#ctl00_MainContent_ddlCallToDoctor").select2();

                        if (typeof callback === 'function') {
                            callback();
                        }

                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
        }
        function PrintBaseRecord() {
            var emergency_id = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            window.open('ReportViewer.aspx?ReportName=EmergencyReferdPrint&ReportTitle=Emergency Base Print&Emergency_ID=' + emergency_id);
        }

        function DotcorCallUnit() {
            var emergency_id = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            window.open('ReportViewer.aspx?ReportName=DotcorCallUnit&ReportTitle=Discharge Smmary Print&Emergency_ID=' + emergency_id);
        }

        function Get_Doctor_MobileInfo() {

            var doctor = document.getElementById('<%= ddlCallToDoctor.ClientID%>').value;
            var EmployeeId = $('#ctl00_MainContent_ddlCallToDoctor').val();
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/Get_Doctor_Mobile",
                data: JSON.stringify({
                    "DoctorId": EmployeeId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    if (response.d == "") {
                        alert("Mobile no. of Selected Doctor is not Available !");
                        $("#ctl00_MainContent_txtMobileNo").val("____-_______");
                    }
                    else {
                        $("#ctl00_MainContent_txtMobileNo").val(response.d);
                    }

                },
                failure: function (response) {
                    alert(response.d);
                    console.log(response.responseJSON.Message);
                }
            });
        }

        function saveprint() {

            $('#loadingimage').show();
            CheckExistInOutPatient();
        }
        function prints() {


            var id = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            if (id != null) {
                window.open('ReportViewer.aspx?ReportName=EmergencyPrint&ReportTitle=Department Of Pathology&Emergency_ID=' + id);
            }
        }


        function PrintAdmisionDetails(response) {

            PATID = $('#<%=txtPatient_ID.ClientID%>').val();
            InPAtID = response;
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {


                    $('#lblName').text(response.d.Full_Name);
                    $('#lblAge').text(response.d.Age_years);
                    $('#lblAGender').text(response.d.Gender);
                    $('#lblAFatherName').text(response.d.FatherName);
                    if (response.d.Department != null) {
                        $('#lblDept').text(response.d.Department);
                    }
                    else {
                        $('#lblDept').text("");
                    }

                    var finaldate = response.d.Created_Time;
                    $('#lblAdmissionDate').text(finaldate);

                    if (response.d.Referring_Doctor != null) {
                        $('#lblAttendingDoctorrpt').text(response.d.Referring_Doctor);
                    }
                    else {
                        $('#lblAttendingDoctorrpt').text("");
                    }
                    if (response.d.Permanent_Address == "")
                        $('#lblAddress').text("");
                    else
                        $('#lblAddress').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                    if (response.d.NIC == "") {
                        $('#lblCNIC').text(".");
                    }
                    else {
                        $('#lblCNIC').text(response.d.NIC);
                    }

                    if (response.d.Admission_Fee == "") {
                        $('#lblAdmissionFeeRpt').text(".");
                    }
                    else {
                        $('#lblAdmissionFeeRpt').text(response.d.Admission_Fee);
                    }
                    if (response.d.ContectNo == "") {
                        $('#lblContact').text("");
                    }
                    else {
                        $('#lblContact').text(response.d.ContectNo);
                    }
                    $('#lblMRNo').text(response.d.MR_No);


                    $('#lblWard').text(response.d.Ward_Name);
                    $('#lblBedNo').text(response.d.Bed_No);
                    $('#lblInPatientAdmitCatagory').text(response.d.Patient_Discount_Type);
                    $('#lblDoctorname').text(response.d.Referring_Doctor);
                    $('#lbloperator').text(response.d.Operator);

                    if (response.d.Room_Name != "") {
                        $('#lblRooms').text(response.d.Room_Name);
                    }

                    PrintInPatientsAdmisionReport();


                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }
        function Abdomin_CheckedChangedFlat() {

            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", false);
        }
        function Abdomin_CheckedChangedDistended() {
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", false);
        }
        function Abdomin_CheckedChangedScaphoid() {
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", false);
        }

        function Anterioropen_CheckedChangedOpen() {

            $("#ctl00_MainContent_rdbPeads_Anterioropen").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_AnteriorClose").prop("checked", false);

        }
        function Anterioropen_CheckedChangedClose() {
            $("#ctl00_MainContent_rdbPeads_Anterioropen").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_AnteriorClose").prop("checked", true);

        }
        function Antenatal_CheckedChangedBooked() {

            $("#ctl00_MainContent_rdbPeads_Booked").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_UnBooked").prop("checked", false);

        }
        function Antenatal_CheckedChangedUnBooked() {
            $("#ctl00_MainContent_rdbPeads_Booked").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_UnBooked").prop("checked", true);

        }
        function Natal_CheckedChangedSVD() {

            $("#ctl00_MainContent_rdbPeads_SVD").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_LSCS").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", false);
            $('#TDPeadsEmergency').hide();
            $('#TDPeadsElective').hide();
        }
        function Natal_CheckedChangedLSCS() {

            $("#ctl00_MainContent_rdbPeads_SVD").prop("checked", false);
            var check = $("#ctl00_MainContent_rdbPeads_LSCS").prop("checked", true);
            if (check = "True") {
                $('#TDPeadsEmergency').show();
                $('#TDPeadsElective').show();
            }

        }
        function Natal_CheckedChangedEmergency() {
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", false);

        }
        function Natal_CheckedChangedElective() {
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", true);


        }
        function ShowPeadsModel() {
            $('#ModelPeads').modal({
                backdrop: 'static'
            });

        }
        function PrintMedicationList(InPAtID) {
            PageMethods.PrintMedicationList(InPAtID, function (res) {
                var Test = JSON.parse(res);
                rows = '';
                var SrNo = 0;
                $('#MediocationBilltbody tr').remove();
                $.each(Test, function (key, value) {
                    SrNo += 1

                    rows += '<tr><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey;text-align:center">' + SrNo + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Medicine_Name + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Recomended_Dosage + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:left"> ' + value.Frequency + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:left">' + value.Oral + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:left;">' + value.DoctorName + '</td><</tr>';

                });
                $('#MediocationBilltbody').html(rows);
                PrintRecommendedMaecieneReport();


            });
        }


        function PrintRecommendedMaecieneReport() {
            var contents = $("#PrintRecommendedMaecieneReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function PrintAllRecommendedMecicationDetail() {

            PATID = $('#<%=txtPatient_ID.ClientID%>').val();
            InPAtID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {


                    $('#lblTMName').text(response.d.Full_Name);
                    $('#lblTMAAge').text(response.d.Age_years);
                    $('#lblTMAGender').text(response.d.Gender);
                    if (response.d.Department != null) {
                        $('#lblTMDept').text(response.d.Department);
                    }
                    else {
                        $('#lblTMDept').text("");
                    }

                    var finaldate = response.d.Created_Time;
                    $('#lblTMAdmissionDate').text(finaldate);

                    if (response.d.Referring_Doctor != null) {
                        $('#lblTMAttendingDoctorrpt').text(response.d.Referring_Doctor);
                    }
                    else {
                        $('#lblTMAttendingDoctorrpt').text("");
                    }
                    if (response.d.Permanent_Address == "")
                        $('#lblTMAddress').text("");
                    else
                        $('#lblAddress').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                    if (response.d.NIC == "") {
                        $('#lblTMCNIC').text(".");
                    }
                    else {
                        $('#lblTMCNIC').text(response.d.NIC);
                    }

                    if (response.d.ContectNo == "") {
                        $('#lblTMContact').text("");
                    }
                    else {
                        $('#lblTMContact').text(response.d.ContectNo);
                    }
                    $('#lblTMMRNo').text(response.d.MR_No);


                    $('#lblTMWard').text(response.d.Ward_Name);
                    $('#lblTMBedNo').text(response.d.Bed_No);
                    $('#lblTMInPatientAdmitCatagory').text(response.d.Patient_Discount_Type);
                    $('#lblTMDoctorname').text(response.d.Referring_Doctor);

                    if (response.d.Room_Name != "") {
                        $('#lblTMRooms').text(response.d.Room_Name);
                    }
                    PrintMedicationList(InPAtID);





                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }
        function PrintAllRecommendedTestDetail() {

            PATID = $('#<%=txtPatient_ID.ClientID%>').val();
            InPAtID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    $('#lblTName').text(response.d.Full_Name);
                    $('#lblTAAge').text(response.d.Age_years);
                    $('#lblTAGender').text(response.d.Gender);
                    if (response.d.Department != null) {
                        $('#lblTDept').text(response.d.Department);
                    }
                    else {
                        $('#lblTDept').text("");
                    }

                    var finaldate = response.d.Created_Time;
                    $('#lblTAdmissionDate').text(finaldate);

                    if (response.d.Referring_Doctor != null) {
                        $('#lblTAttendingDoctorrpt').text(response.d.Referring_Doctor);
                    }
                    else {
                        $('#lblTAttendingDoctorrpt').text("");
                    }
                    if (response.d.Permanent_Address == "")
                        $('#lblTAddress').text("");
                    else
                        $('#lblAddress').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                    if (response.d.NIC == "") {
                        $('#lblTCNIC').text(".");
                    }
                    else {
                        $('#lblTCNIC').text(response.d.NIC);
                    }

                    if (response.d.ContectNo == "") {
                        $('#lblTContact').text("");
                    }
                    else {
                        $('#lblTContact').text(response.d.ContectNo);
                    }
                    $('#lblTMRNo').text(response.d.MR_No);


                    $('#lblTWard').text(response.d.Ward_Name);
                    $('#lblTBedNo').text(response.d.Bed_No);
                    $('#lblTInPatientAdmitCatagory').text(response.d.Patient_Discount_Type);
                    $('#lblTDoctorname').text(response.d.Referring_Doctor);

                    if (response.d.Room_Name != "") {
                        $('#lblTRooms').text(response.d.Room_Name);
                    }
                    PrintTestList(InPAtID);



                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }
        function PrintTestList(InPAtID) {
            PageMethods.PrintTestList(InPAtID, function (res) {
                var Test = JSON.parse(res);
                rows = '';
                var SrNo = 0;
                $('#testBilltbody tr').remove();
                $.each(Test, function (key, value) {
                    SrNo += 1
                    if (value.Test_Name != null) {
                        rows += '<tr><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey;text-align:center">' + SrNo + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Test_Name + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right"> ' + value.Area_Of_Interest + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;display:none;text-align:right">' + value.Special_Tests + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:left;">' + value.DoctorName + '</td><</tr>';
                    }
                    else {
                        rows += '<tr><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey;text-align:center">' + SrNo + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Group_Name + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right"> ' + value.Area_Of_Interest + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;display:none;text-align:right">' + value.Special_Tests + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:left;">' + value.DoctorName + '</td><</tr>';

                    }

                });
                $('#testBilltbody').html(rows);
                PrintRecommendedTestDetail();


            });
        }

        function PrintRecommendedTestDetail() {
            var contents = $("#PrintRecommendedTestReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }

        function PrintRecommendedMaecieneReport() {
            var contents = $("#PrintRecommendedMaecieneReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function PrintInPatientsAdmisionReport() {
            var contents = $("#PrintInPatientsAdmisionReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function PrintInPatientsReport() {
            var contents = $("#PrintInPatientsReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function callTabaftertime() {

            setInterval(function () {
                TabFunction();

            }, 2000);
        }
        function PrintAdmisionDetail() {

            PATID = $('#<%=txtPatient_ID.ClientID%>').val();
            InPAtID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {


                    $('#lblName').text(response.d.Full_Name);
                    $('#lblAge').text(response.d.Age_years);
                    $('#lblAGender').text(response.d.Gender);
                    $('#lblAFatherName').text(response.d.FatherName);
                    if (response.d.Department != null) {
                        $('#lblDept').text(response.d.Department);
                    }
                    else {
                        $('#lblDept').text("");
                    }

                    var finaldate = response.d.Created_Time;
                    $('#lblAdmissionDate').text(finaldate);
                    $('#lblAdmissionFeeRpt').text(response.d.Admission_Fee);

                    if (response.d.Referring_Doctor != null) {
                        $('#lblAttendingDoctorrpt').text(response.d.Referring_Doctor);
                    }
                    else {
                        $('#lblAttendingDoctorrpt').text("");
                    }
                    if (response.d.Permanent_Address == "")
                        $('#lblAddress').text("");
                    else
                        $('#lblAddress').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                    if (response.d.NIC == "") {
                        $('#lblCNIC').text(".");
                    }
                    else {
                        $('#lblCNIC').text(response.d.NIC);
                    }
                    if (response.d.ContectNo == "") {
                        $('#lblContact').text("");
                    }
                    else {
                        $('#lblContact').text(response.d.ContectNo);
                    }
                    $('#lblMRNo').text(response.d.MR_No);


                    $('#lblWard').text(response.d.Ward_Name);
                    $('#lblBedNo').text(response.d.Bed_No);
                    $('#lblInPatientAdmitCatagory').text(response.d.Patient_Discount_Type);
                    $('#lblDoctorname').text(response.d.Referring_Doctor);
                    $('#lbloperator').text(response.d.Operator);

                    if (response.d.Room_Name != "") {
                        $('#lblRooms').text(response.d.Room_Name);
                    }

                    PrintInPatientsAdmisionReport();


                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }

        function select3(anchor) {

            var rows = $(anchor).parents('tr')[0];
            var OPD = $($(rows).find('td')[0]).val();
            var MedicineName = $($(rows).find('td')[1]).text();
            var Dosage = $($(rows).find('td')[2]).text();
            if (Dosage.trim() == "null") Dosage = '';
            var Frequency = $($(rows).find('td')[3]).text();
            var Routes = $($(rows).find('td')[4]).text();
            var Duration = $($(rows).find('td')[5]).text();
            var date = $($(rows).find('td')[0]).text().trim();
            var row = '<tr><td>' + date + '</td><td>' + MedicineName + '</td><td>' + Dosage + '</td><td>' + Frequency + '</td><td> ' + Routes + '</td><td style="display:none"> ' + Duration + '</td><td> <input type="text" disabled id="txtNurseName" name="txtNurseName" value=' + '<%= AppConfig.UserName %>' + ' style="width:100px !important;"/></td><td><input type="text"  id="txtremarks" name="txtremarks" style="width: 115px!important;"/></td><td style="display:none;"><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteMedicine(this)">Delete</a></td></tr>';
            $('#tblMedicinesListNursing').append(row);
            $(anchor).parents('tr').remove();

        }

        function PrintInpatientReceipt() {
            debugger
            var txtNext_Visit = $('#ctl00_MainContent_txtNext_Visit').val();
            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            if (dischargechk == false) {
                alert("First Discharge The Patient")
                return false;
            }

            else {

                ID = $('#<%=txtPatient_ID.ClientID%>').val();
                oUTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "EmergencyCase.aspx/PrintInPatientReceipt",
                    data: JSON.stringify({
                        'InPatientID': ID,
                        'OUTPatientID': oUTID
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#ctl00_MainContent_lblNamerpt').text(response.d.Full_Name);
                        $('#lblAgerpt').text(response.d.Age_years);
                        $('#lblGenderrpt').text(response.d.Gender);
                        if (response.d.Department != null) {
                            $('#lblDepartmentrpt').text(response.d.Department);
                        }
                        else {
                            $('#lblDepartmentrpt').text("");
                        }
                        if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                            $('#lblTyperpt').text(response.d.Patient_Type);
                        }
                        else {
                            $('#lblTyperpt').text(".");
                        }
                        var finaldate = response.d.Created_Time;
                        $('#lblDateTimerpt').text(finaldate);

                        if (response.d.Referring_Doctor != null) {
                            $('#lblAttendingDoctorrpt').text(response.d.Referring_Doctor);
                        }
                        else {
                            $('#lblAttendingDoctorrpt').text("");
                        }
                        if (response.d.Permanent_Address == "")
                            $('#lblAddressrpt').text("");
                        $('#lblAddressrpt').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                        if (response.d.NIC == "") {
                            $('#lblCNICrpt').text(".");
                        }
                        else {
                            $('#lblCNICrpt').text(response.d.NIC);
                        }
                        if (response.d.ContectNo == "") {
                            $('#lblContactrpt').text("");
                        }
                        else {
                            $('#lblContactrpt').text(response.d.ContectNo);
                        }
                        $('#lblOPDNorpt').text(response.d.MR_No);
                        if (response.d.Prisentation != null) {
                            $('#lblPresentationrpt').text(response.d.Prisentation);
                        }
                        else
                            $('#lblPresentationrpt').text(".");
                        $('#txtProcedureDetailrpt').text(response.d.Procedure_Detail);
                        $('#txtProcedurerpt').text(response.d.Procedure_Operation);
                        $('#txtDignosisrpt').text(response.d.Diagonosis);
                        if (txtNext_Visit != '') {
                            $('#urdulineshow').show();
                            var dateFollowup = $('#ctl00_MainContent_txtNext_Visit').val();
                            var finaldateFollowup = moment(dateFollowup).format('L');
                            $('#txtNext_Visit').text(finaldateFollowup);
                        }

                        else {
                            $('#txtFollowDate').text('');
                            $('#urdulineshow').hide();
                        }
                        $('#txtAdvicerpt').text(response.d.Advice);
                        $('#lblWardrpt').text(response.d.Ward_Name);
                        $('#lblBedNorpt').text(response.d.Bed_No);

                        if (response.d.Room_Name != "") {
                            $('#lblRoomsrpt').text(response.d.Room_Name);
                        }
                        else
                            $('#lblRoomsrpt').text(".");
                        $('#spanExamrpt').text(response.d.CNS + ',' + response.d.CVS + ',' + response.d.RESP + ',' + response.d.GIT + ',' + response.d.GYNAE + ',' + response.d.Mucculor + ',' + response.d.Local);
                        var DischargeOn = ".";
                        if (response.d.Discharge_On != "") {
                            DischargeOn = response.d.Discharge_On;
                            DischargeOn = moment(DischargeOn).format('L');
                        }
                        $('#lblDischargedaterpt').text(DischargeOn);

                        ID = $('#<%=txtPatient_ID.ClientID%>').val();
                        UTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
                        PageMethods.LoadMedicinesForHistoryrpt(ID, oUTID, function (res) {
                            var Medicines = JSON.parse(res);
                            var rows = '';
                            $('#tblMedicenerpt').text("");
                            $.each(Medicines, function (key, value) {
                                rows += '<td><h6>*</h6></td><td><h6>' + value.Medicine_Name + ',' + '</h6></td>';
                            });
                            $('#Madicenrow').html(rows);
                            LoadDischargeMedicinesrpt();
                        });
                    },
                    Error: function (x, e) {
                        alert(e)
                    }
                });
            }
        }
        var editrights;
        function AllowEmergencyEdit() {
            debugger;
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/CheckEditRights",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    editrights = data.d;

                    if (editrights == "true") {

                        $('#btnSave').attr('disabled', false);
                    }
                    else {
                        $('#btnSave').attr('disabled', true);
                    }

                },
                failure: function () {
                    alert("Error");
                }
            });


        }




        var editdiscount;
        function AllowDiscountEdit() {
            debugger;
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/CheckDiscountRights",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    editdiscount = data.d;

                    if (editdiscount == "true") {

                        $('#ctl00_MainContent_txtDiscount').attr('disabled', false);
                    }
                    else {
                        $('#ctl00_MainContent_txtDiscount').attr('disabled', true);
                    }

                },
                failure: function () {
                    alert("Error");
                }
            });


        }
        function LoadDischargeMedicinesrpt(PatientID) {
            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            PageMethods.LoadDischargeMedicinesrpt(ID, oUTID, function (res) {
                var Medicines = JSON.parse(res);
                var rows = '';
                $('#tblTestrpt tr').remove();
                $.each(Medicines, function (key, value) {
                    rows += '<tr><td>*</td><td>' + value.Medicine_Name + '</td> <td> ' + value.Frequency + '</td><td style="width:1px">??</td><td>' + value.Injections + ' </td></tr>';
                });
                $('#tblTestrpt').html(rows);
                LoadExamrpt();
            });
        }

        function FillProcedure(deptID) {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetProcedure(deptID, function (item) {
                $.each(JSON.parse(item), function (key, value) {

                    options += '<option value="' + value.TestID + '" >' + value.TestName + '</option>';
                });

                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();

            });
        }

        function LoadExamrpt(PatientID) {
            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            PageMethods.LoadExamrpt(oUTID, function (res) {

                var Examrpt = JSON.parse(res);
                var rows = '';
                $('#tblPresentingComplaintsrpt tr').remove();
                $.each(Examrpt, function (key, value) {
                    rows += '<tr>  <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + '&nbsp&nbsp' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td> </tr>';
                });
                $('#tblPresentingComplaintsrpt').html(rows);
                LoadLabResultrptDischarge();
            });
        }
        function LoadLabResultrptDischarge(PatientID) {
            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            PageMethods.LoadLabResultrptDetail(oUTID, function (res) {

                var Medicines = JSON.parse(res);
                var rows = '';
                $('#tblLabResultrpt td').remove();
                $.each(Medicines, function (key, value) {
                    rows += '<td>*</td><td>' + value.Lab_Resultrpt + '-' + value.Lab_Resultrpt_Name + '</td>';
                });
                $('#tblLabResultrpt').html(rows);
                PrintInPatientsReport();
            });
        }

        function SaveEyeList() {
            var table = $('#tblEyes');
            var list = [];
            table.find('tbody tr').each(function (key, value) {
                var RightEye = $($(value).find('td')[2]).text();
                var LeftEye = $($(value).find('td')[3]).text();
                var EyeMainTypeID = $(value).find('td input[name=txtEyeMainTypeID]').val();
                var EyeSubTypeID = $(value).find('td input[name=txtEyeSubTypeID]').val();
                list.push({ 'EyeMainTypeID': EyeMainTypeID, 'EyeSubTypeID': EyeSubTypeID, 'RightEye': RightEye, 'LeftEye': LeftEye });
            });
            //var TransactionID = $("#<%= txtIn_Patient_ID.ClientID %>").val();
            var TransactionID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (TransactionID == '(New)' || TransactionID == '')
                TransactionID = 0;
            var data = { 'TransactionID': TransactionID, 'EyeDetails': list };
            PageMethods.SaveEyeList(JSON.stringify(data), function (res) {
                SaveHistoryTab();
            });
        }

        function LoadEyeList() {
            var patientID = $("#<%= txtIn_Patient_ID.ClientID %>").val();
            if (patientID != "(New)") {
                var rows = '';
                PageMethods.GetEyeList(patientID, function (res) {
                    var list = JSON.parse(res);
                    $.each(list, function (key, value) {
                        var timeStamp = '<%= DateTime.Now%>'
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        rows += '<tr><td><input type="hidden" name="txtEyeUUID" value="' + uuid() + '" /> <input type="hidden" name="txtEyeMainTypeID" value=' + value.EyeMainTypeID + ' /><input type="hidden" name="txtEyeSubTypeID" value=' + value.EyeSubTypeID + ' /> ' + value.EyeMainTypeName + '</td><td>' + value.EyeSubTypeName + '</td><td>' + value.RightEye + '</td><td>' + value.LeftEye + '</td> <td>  <a href="javascript:void(0)" onclick=EditEyeRow(this) style="display:none;">Edit</a> <a href="javascript:void(0)" onclick=DeleteEyeRow(this)>Delete</a></td></tr>';
                    });

                    $('#tblEyes tbody').html(rows);
                });
            }
        }
        function LoadEyeListHistory(PatientID) {
            if (PatientID != "(New)") {
                var rows = '';
                PageMethods.GetEyeListHistory(PatientID, function (res) {
                    var list = JSON.parse(res);
                    $.each(list, function (key, value) {
                        var timeStamp = '<%= DateTime.Now%>'
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr><td>' + value.Status + '</td><td><input type="hidden" name="txtEyeUUID" value="' + uuid() + '" /> <input type="hidden" name="txtEyeMainTypeID" value=' + value.EyeMainTypeID + ' /><input type="hidden" name="txtEyeSubTypeID" value=' + value.EyeSubTypeID + ' /> ' + value.EyeMainTypeName + '</td><td>' + value.EyeSubTypeName + '</td><td>' + value.RightEye + '</td><td>' + value.LeftEye + '</td> </tr>';



                    });
                    $('#tblEyesHistory tbody').html(rows);
                });
            }
        }
        function FillEyeSubTypeOnchangeOfEyeMainType() {

            $('#ddlEyeMainType').change(function () {
                PageMethods.GetEyeSubType(ddlEyeMainType.value, function (data) {
                    options = '';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlEyeSubType option').remove()
                    $('#ddlEyeSubType').html(options);
                });
            });
        }

        function EditEyeRow(AnchorTag) {
            var row = $(AnchorTag).parents('tr')[0];
            $('#ddlEyeMainType').val($($(row).find('td input[name=txtEyeMainTypeID]')).val());
            $('#ddlEyeSubType').val($($(row).find('td input[name=txtEyeSubTypeID]')).val());
            $('#txtRightEye').val($($(row).find('td')[2]).text());
            $('#txtLeftEye').val($($(row).find('td')[3]).text());
            localStorage.uuidEyeTable = $($(row).find('td input[name=txtEyeUUID]')).val();
        }
        function DeleteEyeRow(row) {
            $($(row).parents('tr')[0]).remove();
        }

        function AddEyeRow() {
            if ($('#btnAddEye').val() == 'Add') {
                var html = '<tr><td><input type="hidden" name="txtEyeUUID" value="' + uuid() + '" /> <input type="hidden" name="txtEyeMainTypeID" value=' + ddlEyeMainType.value + ' /><input type="hidden" name="txtEyeSubTypeID" value=' + ddlEyeSubType.value + ' /> ' + $('#ddlEyeMainType option:selected').text() + '</td><td>' + $('#ddlEyeSubType option:selected').text() + '</td><td>' + txtRightEye.value + '</td><td>' + txtLeftEye.value + '</td> <td>  <a href="javascript:void(0)" onclick=EditEyeRow(this) style="display:none;">Edit</a> <a href="javascript:void(0)" onclick=DeleteEyeRow(this)>Delete</a></td></tr>';

                $('#tblEyes tbody').append(html);
            }
            else if ($('#btnAddEye').val() == 'Update') {


            }

        }

        function FillEyeMainTypesAndSubTypes() {

            var options = '';

            PageMethods.GetEyeMainType(function (data) {
                options = '';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlEyeMainType option').remove()
                $('#ddlEyeMainType').html(options);

            });
        }

        function saveAllRecord() {
            debugger;

            var btnsave = $('#btnSave').val();
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            // var txtAdmission_Date = $('#ctl00_MainContent_txtAdmission_Date').val();
            //var ddlDepartment = $('#ctl00_MainContent_ddlDepartment').val();
            //var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
            var ddlCallToDoctor = $('#ctl00_MainContent_ddlCallToDoctor').val();

            var ReferToOPD = $('#<%= ReferToOPD.ClientID %>').is(':checked');

            /*var ReferToOPD = $('#ReferToOPD').is(':checked');*/
            var txtHealth_Complaints = "";
            // var ddlIssuance_Of = $('#ctl00_MainContent_ddlIssuance_Of').val();
            //var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();

            var patienttype = $("#ctl00_MainContent_vLbl_Patient_Type").text();

            ////
            //var patientcateg = $("#ctl00_MainContent_ddlCategory").val();

            //var txtBed_No = $('#ctl00_MainContent_txtBed_No').val();

            var BP_mm_Hg = $('#ctl00_MainContent_txtBP').val();
            var Temp_C = $('#ctl00_MainContent_txtTemp').val();
            var Respiration_Min = $('#ctl00_MainContent_txtRespiration').val();

            var txtRN_Special_Instruction = $('#ctl00_MainContent_txtRN_Special_Instruction').val();

            var txtReceiving_Date = $('#ctl00_MainContent_txtReceiving_Date').val();

            var Provisional_Diagnosis = $('#ctl00_MainContent_txtProvisionalDiagnosis').val();
            var Refer_To_Hospital = $('#ctl00_MainContent_txtRefer_To_Hospital').val();
            var Reffer_To = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
            if (Reffer_To == 0)
                Reffer_To = "";

            var HistoryOfPeresentIllness = $('#ctl00_MainContent_txtHistoryOfPeresentIllness').val();
            var HistoryOfFamily = $('#ctl00_MainContent_txtHistoryOfFamily').val();
            var HistoryOfPastIllness = $('#ctl00_MainContent_txtHistoryOfPastIllness').val();

            var SocioEconomicHistory = $('#ctl00_MainContent_txtSocioEconomicHistory').val();



            var Birth_History = $('#ctl00_MainContent_txtBirthHistory').val();

            var Reffer_No = $('#ctl00_MainContent_txtRefferNote').val();
            var Drug_History = $('#ctl00_MainContent_txtDrugHistory').val();
            var Personal_History = $('#ctl00_MainContent_txtPersonalHistory').val();

            var ObstetricHistory = $('#ctl00_MainContent_txtObstetricHistory').val();
            var AllergiesHistory = $('#ctl00_MainContent_txtAllergiesHistory').val();
            var TreatmentHistory = $('#ctl00_MainContent_txtTreatmentHistory').val();
            var VaccinationHistory = $('#ctl00_MainContent_txtVaccinationHistory').val();
            var AnyOtherHistory = $('#ctl00_MainContent_txtAnyOtherHistory').val();

            var ENT_Throat_IDL = $('#ctl00_MainContent_txtmidl').val();
            if (ENT_Throat_IDL == null)
                ENT_Throat_IDL = "";
            var ENT_Throat_Nose = $('#ctl00_MainContent_txtmNose').val();
            if (ENT_Throat_Nose == null)
                ENT_Throat_Nose = "";
            var ENT_Ear_Right = $('#ctl00_MainContent_txtmRight').val();
            if (ENT_Ear_Right == null)
                ENT_Ear_Right = "";
            var Ent_Ear_Left = $('#ctl00_MainContent_txtmLeft').val();
            if (Ent_Ear_Left == null)
                Ent_Ear_Left = "";

            var ENT_Rinnes_Right_PosNeg = document.getElementById('ctl00_MainContent_mchkRightPos').checked;
            var ENT_Rinnes_Lft_PosNeg = document.getElementById('ctl00_MainContent_mchkLeftPos').checked;
            var ENT_Rinnes_Right_FalseNeg = document.getElementById('ctl00_MainContent_mchkRightF').checked;
            var ENT_Rinnes_Lft_FalseNeg = document.getElementById('ctl00_MainContent_mchkLeftF').checked;

            var ENT_Webber_Central = document.getElementById('ctl00_MainContent_mchkcentral').checked;
            var ENT_Webber_Lateralized = document.getElementById('ctl00_MainContent_mchkLateralized').checked;

            var ENT_Investigation_PTA = document.getElementById('ctl00_MainContent_mchkPTA').checked;
            var ENT_Investigation_Tympanometry = document.getElementById('ctl00_MainContent_mchkTympanometry').checked;

            var ENT_Rinnes_Right_Neg = document.getElementById('ctl00_MainContent_mchkRightNeg').checked;
            var ENT_Rinnes_Lft_Neg = document.getElementById('ctl00_MainContent_mchkLeftNeg').checked;
            var ENT_Rinnes_Right_FNeg = document.getElementById('ctl00_MainContent_mchkRightFNeg').checked;
            var ENT_Rinnes_Lft_FNeg = document.getElementById('ctl00_MainContent_mchkLeftFNeg').checked;
            var txtInformant = $('#ctl00_MainContent_txtInformant').val();

            var txtSourceOfReferral = $('#ctl00_MainContent_txtSourceOfReferral').val();
            var chkNeckHolding = document.getElementById("ctl00_MainContent_chkNeckHolding").checked;
            var chkWalking = document.getElementById('ctl00_MainContent_chkWalking').checked;
            var chkTalking = document.getElementById('ctl00_MainContent_chkTalking').checked;
            var chkOthers = document.getElementById('ctl00_MainContent_chkOthers').checked;
            var txtMenarche = $('#ctl00_MainContent_txtMenarche').val();
            var txtMenstrual = $('#ctl00_MainContent_txtMenstrual').val();
            var txtAttachmentSeparationfromParents = $('#ctl00_MainContent_txtAttachmentSeparationfromParents').val();
            var txtHealth = $('#ctl00_MainContent_txtHealth').val();
            var chkNailBiting = document.getElementById('ctl00_MainContent_chkNailBiting').checked;
            var chkTemperTantrums = document.getElementById('ctl00_MainContent_chkTemperTantrums').checked;
            var chkBedWetting = document.getElementById('ctl00_MainContent_chkBedWetting').checked;
            var txtAcademics = $('#ctl00_MainContent_txtAcademics').val();

            var txtPeerRelationship = $('#ctl00_MainContent_txtPeerRelationship').val();
            var txtBehaviour = $('#ctl00_MainContent_txtBehaviour').val();
            var txtOccupationalHistory = $('#ctl00_MainContent_txtOccupationalHistory').val();
            var txtMaritalRelationshipSexualHistory = $('#ctl00_MainContent_txtMaritalRelationshipSexualHistory').val();
            var txtSubstanceUse = $('#ctl00_MainContent_txtSubstanceUse').val();
            var txtForensicUse = $('#ctl00_MainContent_txtForensicUse').val();
            var txtRelationship = $('#ctl00_MainContent_txtRelationship').val();
            var txtLeisureActivities = $('#ctl00_MainContent_txtLeisureActivities').val();
            var txtAttitudetoSelfandStandards = $('#ctl00_MainContent_txtAttitudetoSelfandStandards').val();
            var txtPrevallingMood = $('#ctl00_MainContent_txtPrevallingMood').val();
            var txtReactionPattrentoStress = $('#ctl00_MainContent_txtReactionPattrentoStress').val();
            var txtReligiousPracticesAttitute = $('#ctl00_MainContent_txtReligiousPracticesAttitute').val();
            var txtFather = $('#ctl00_MainContent_txtFather').val();
            var txtMother = $('#ctl00_MainContent_txtMother').val();
            var txtSiblings = $('#ctl00_MainContent_txtSiblings').val();

            var txtHomeAtmosphererelationshipsocialclass = $('#ctl00_MainContent_txtHomeAtmosphererelationshipsocialclass').val();
            var txtFamilialIllness = $('#ctl00_MainContent_txtFamilialIllness').val();
            var txtActualandapparentage = $('#ctl00_MainContent_txtActualandapparentage').val();
            var txtRace = $('#ctl00_MainContent_txtRace').val();
            var txtTattoosbodypiercingandscars = $('#ctl00_MainContent_txtTattoosbodypiercingandscars').val();
            var txtBodyHabitus = $('#ctl00_MainContent_txtBodyHabitus').val();
            var txtDress = $('#ctl00_MainContent_txtDress').val();
            var txtHygiene = $('#ctl00_MainContent_txtHygiene').val();
            var txtPsychomotorActivity = $('#ctl00_MainContent_txtPsychomotorActivity').val();
            var txtInvoluntarymovements = $('#ctl00_MainContent_txtInvoluntarymovements').val();
            var txtDystoniaEPS = $('#ctl00_MainContent_txtDystoniaEPS').val();
            var txtTardivedyskinesia = $('#ctl00_MainContent_txtTardivedyskinesia').val();

            var txtTics = $('#ctl00_MainContent_txtTics').val();
            var txtTremors = $('#ctl00_MainContent_txtTremors').val();
            var txtAttentivenesstointerview = $('#ctl00_MainContent_txtAttentivenesstointerview').val();
            var txtEyeContact = $('#ctl00_MainContent_txtEyeContact').val();
            var txtLevelofConsciousness = $('#ctl00_MainContent_txtLevelofConsciousness').val();
            var txtRate = $('#ctl00_MainContent_txtRate').val();
            var txtRhythm = $('#ctl00_MainContent_txtRhythm').val();
            var txtVolume = $('#ctl00_MainContent_txtVolume').val();
            var txtTone = $('#ctl00_MainContent_txtTone').val();
            var txtModulationvar = $('#ctl00_MainContent_txtModulationvar').val();
            var txtDepressed = $('#ctl00_MainContent_txtDepressed').val();
            var txtElated = $('#ctl00_MainContent_txtElated').val();

            var txtIrritable = $('#ctl00_MainContent_txtIrritable').val();
            var txtLabile = $('#ctl00_MainContent_txtLabile').val();
            var txtIncongruent = $('#ctl00_MainContent_txtIncongruent').val();
            var txtbluntingflatteningapathy = $('#ctl00_MainContent_txtBluntingFlatteningApathy').val();
            var txtThinkingPremeditation = $('#ctl00_MainContent_txtThinkingPremeditation').val();
            var txtPlans = $('#ctl00_MainContent_txtPlans').val();
            var txtActions = $('#ctl00_MainContent_txtActions').val();
            var txtPreservative = $('#ctl00_MainContent_txtPreservative').val();
            var txtLoosAssociation = $('#ctl00_MainContent_txtLoosAssociation').val();
            var txtTangentiaility = $('#ctl00_MainContent_txtTangentiaility').val();
            var txtCircumstantiality = $('#ctl00_MainContent_txtCircumstantiality').val();
            var txtFlightofIdeas = $('#ctl00_MainContent_txtFlightofIdeas').val();
            var txtThoughtInsertion = $('#ctl00_MainContent_txtThoughtInsertion').val();
            var txtThoughtWithdrawal = $('#ctl00_MainContent_txtThoughtWithdrawal').val();
            var txtThoughBroadcasting = $('#ctl00_MainContent_txtThoughBroadcasting').val();
            var txtThoughControl = $('#ctl00_MainContent_txtThoughControl').val();
            var txtDellusion = $('#ctl00_MainContent_txtDellusion').val();
            var txtovervaluedideas = $('#ctl00_MainContent_txtovervaluedideas').val();
            var txtDepresonalization = $('#ctl00_MainContent_txtDepresonalization').val();
            var txtDerealization = $('#ctl00_MainContent_txtDerealization').val();
            var txtthrougObsession = $('#ctl00_MainContent_txtthrougObsession').val();
            var txtthrougPhobies = $('#ctl00_MainContent_txtthrougPhobies').val();
            var txtthrougHomocidialIdeas = $('#ctl00_MainContent_txtthrougHomocidialIdeas').val();
            var txtillusion = $('#ctl00_MainContent_txtillusion').val();

            var txtHallucinationAuditoryVisualOlfactoryGustatoryTactile = $('#ctl00_MainContent_txtHallucinationAuditoryVisualOlfactoryGustatoryTactile').val();
            var txtorientationtime = $('#ctl00_MainContent_txtorientationtime').val();
            var txtplace = $('#ctl00_MainContent_txtplace').val();
            var txtperson = $('#ctl00_MainContent_txtperson').val();
            var txtAttentionConcentrationSerial7Test = $('#ctl00_MainContent_txtAttentionConcentrationSerial7Test').val();
            var txtOrDaysOfWeekReverseOrder = $('#ctl00_MainContent_txtOrDaysOfWeekReverseOrder').val();
            var txtImmediatememory = $('#ctl00_MainContent_txtImmediatememory').val();
            var txtshorttermrecentevents = $('#ctl00_MainContent_txtshorttermrecentevents').val();
            var txtadressrecallafter2minutes = $('#ctl00_MainContent_txtadressrecallafter2minutes').val();
            var txtlongtermremoteevents = $('#ctl00_MainContent_longtermremoteevents').val();
            var txtadressrecallafter5minues = $('#ctl00_MainContent_txtadressrecallafter5minues').val();
            var txtgeneralknowledgequestion = $('#ctl00_MainContent_txtgeneralknowledgequestion').val();
            var txtsimplearthemeticcalculation = $('#ctl00_MainContent_txtsimplearthemeticcalculation').val();
            var txtabstrationconcertethinking = $('#ctl00_MainContent_txtabstrationconcertethinking').val();
            var txtinsight = $('#ctl00_MainContent_txtinsight').val();


            var DermaFace = $('#ctl00_MainContent_txtDermaFace').val();
            if (DermaFace == null)
                DermaFace = "";
            var DermaNeck = $('#ctl00_MainContent_txtDermaNeck').val();
            if (DermaNeck == null)
                DermaNeck = "";
            var DermaTrunk = $('#ctl00_MainContent_txtDermaTrunk').val();
            if (DermaTrunk == null)
                DermaTrunk = "";
            var DermaUpperLimb = $('#ctl00_MainContent_txtDermaUpperLimb').val();
            if (DermaUpperLimb == null)
                DermaUpperLimb = "";
            var DermaLowerLimb = $('#ctl00_MainContent_txtDermaLowerLimb').val();
            if (DermaLowerLimb == null)
                DermaLowerLimb = "";
            var DermaFlexures = $('#ctl00_MainContent_txtDermaFlexures').val();
            if (DermaFlexures == null)
                DermaFlexures = "";
            var DermaGenitalias = $('#ctl00_MainContent_txtDermaGenitalias').val();
            if (DermaGenitalias == null)
                DermaGenitalias = "";
            var DermaHair = $('#ctl00_MainContent_txtDermaHair').val();
            if (DermaHair == null)
                DermaHair = "";
            var DermaNail = $('#ctl00_MainContent_txtDermaNail').val();
            if (DermaNail == null)
                DermaNail = "";
            var DermaMucousMembrane = $('#ctl00_MainContent_txtDermaMucousMembrane').val();
            if (DermaMucousMembrane == null)
                DermaMucousMembrane = "";
            var DermaEyes = $('#ctl00_MainContent_txtDermaEyes').val();
            if (DermaEyes == null)
                DermaEyes = "";
            var DermaEars = $('#ctl00_MainContent_txtDermaEars').val();
            if (DermaEars == null)
                DermaEars = "";
            var DermaNose = $('#ctl00_MainContent_txtDermaNose').val();
            if (DermaNose == null)
                DermaNose = "";
            var DermaLips = $('#ctl00_MainContent_txtDermaLips').val();
            if (DermaLips == null)
                DermaLips = "";
            var PE_Pluse = $('#ctl00_MainContent_txtPE_Pluse').val();
            var PE_BP = $('#ctl00_MainContent_txtPE_BP').val();
            var PE_Temperature = $('#ctl00_MainContent_txtPE_Temperature').val();
            var PE_Weight = $('#ctl00_MainContent_txtPE_Weight').val();
            var PE_RespiratoryRate = $('#ctl00_MainContent_txtPE_RespiratoryRate').val();
            var PE_Jaundice = $('#ctl00_MainContent_txtPE_Jaundice').val();
            var PE_Anemia = $('#ctl00_MainContent_txtPE_Anemia').val();
            var PE_Cyanosis = $('#ctl00_MainContent_txtPE_Cyanosis').val();
            var PE_Clubbing = $('#ctl00_MainContent_txtPE_Clubbing').val();
            var PE_JVP = $('#ctl00_MainContent_txtPE_JVP').val();
            var PE_LymphNodes = $('#ctl00_MainContent_txtPE_LymphNodes').val();
            var PE_Edema = $('#ctl00_MainContent_txtPE_Edema').val();
            var PE_Respiratory = $('#ctl00_MainContent_txtPE_Respiratory').val();
            var PE_Cardiovascular = $('#ctl00_MainContent_txtPE_Cardiovascular').val();
            var PE_Gastro_Intestinal = $('#ctl00_MainContent_txtPE_Gastro_Intestinal').val();
            var PE_Observation = $('#ctl00_MainContent_txtPE_Observation').val();
            var PE_Cranial_Nerves = $('#ctl00_MainContent_txtPE_Cranial_Nerves').val();
            var PE_Limb_Strength = $('#ctl00_MainContent_txtPE_Limb_Strength').val();
            var PE_Spasticity = $('#ctl00_MainContent_txtPE_Spasticity').val();
            var PE_Position = $('#ctl00_MainContent_txtPE_Position').val();
            var PE_Vibration = $('#ctl00_MainContent_txtPE_Vibration').val();
            var PE_Stereognosis = $('#ctl00_MainContent_txtPE_Stereognosis').val();
            var PE_Pain = $('#ctl00_MainContent_txtPE_Pain').val();
            var PE_Biceps = $('#ctl00_MainContent_txtPE_Biceps').val();
            var PE_Triceps = $('#ctl00_MainContent_txtPE_Triceps').val();
            var PE_Brachioradialis = $('#ctl00_MainContent_txtPE_Brachioradialis').val();
            var PE_Quadriceps = $('#ctl00_MainContent_txtPE_Quadriceps').val();
            var PE_Patellar = $('#ctl00_MainContent_txtPE_Patellar').val();
            var PE_Achilles = $('#ctl00_MainContent_txtPE_Achilles').val();
            var PE_Extensor = $('#ctl00_MainContent_txtPE_Extensor').val();
            var PE_Frontal = $('#ctl00_MainContent_txtPE_Frontal').val();
            var PE_Finger = $('#ctl00_MainContent_txtPE_Finger').val();
            var PE_Heel = $('#ctl00_MainContent_txtPE_Heel').val();
            var PE_Movements = $('#ctl00_MainContent_txtPE_Movements').val();
            var PE_Gait = $('#ctl00_MainContent_txtPE_Gait').val();
            var HBM_Problem = $('#ctl00_MainContent_txtHBM_Problem').val();
            var HBM_Caused = $('#ctl00_MainContent_txtHBM_Caused').val();
            var HBM_Started = $('#ctl00_MainContent_txtHBM_Started').val();
            var HBM_Course = $('#ctl00_MainContent_txtHBM_Course').val();
            var HBM_Treatment = $('#ctl00_MainContent_txtHBM_Treatment').val();
            var HBM_Effects = $('#ctl00_MainContent_txtHBM_Effects').val();
            var PE_Neck_Rigidity = document.getElementById('ctl00_MainContent_chkPE_Neck_Rigidity').checked;
            var PE_Kerning_Sign = document.getElementById('ctl00_MainContent_chkPE_Kerning_Sign').checked;
            var PE_Brudzinki_Sign = document.getElementById('ctl00_MainContent_chkPE_Brudzinki_Sign').checked;

            var For_Summary = $('#ctl00_MainContent_txtFor_Summary').val();
            var For_Diagnosis = $('#ctl00_MainContent_txtFor_Diagnosis').val();
            var For_AxisI = $('#ctl00_MainContent_txtFor_AxisI').val();
            var For_AxisII = $('#ctl00_MainContent_txtFor_AxisII').val();
            var For_AxisIII = $('#ctl00_MainContent_txtFor_AxisIII').val();
            var For_AxisIV = $('#ctl00_MainContent_txtFor_AxisIV').val();
            var For_AxisV = $('#ctl00_MainContent_txtFor_AxisV').val();
            var For_PredisposingFactors = $('#ctl00_MainContent_txtFor_PredisposingFactors').val();
            var For_PrecipitatingFactors = $('#ctl00_MainContent_txtFor_PrecipitatingFactors').val();
            var For_PrepetuatingFactors = $('#ctl00_MainContent_txtFor_PrepetuatingFactors').val();
            var For_Investigation = $('#ctl00_MainContent_txtFor_Investigation').val();
            var For_Medical = $('#ctl00_MainContent_txtFor_Medical').val();
            var For_Psychological = $('#ctl00_MainContent_txtFor_Psychological').val();
            var For_Major_Issues = $('#ctl00_MainContent_txtFor_Major_Issues').val();
            var For_Strengths = $('#ctl00_MainContent_txtFor_Strengths').val();
            var For_Goals = $('#ctl00_MainContent_txtFor_Goals').val();
            var For_Strategies = $('#ctl00_MainContent_txtFor_Strategies').val();

            var txtPeads_weight = $('#ctl00_MainContent_txtPeads_weight').val();
            var txtPeads_Length = $('#ctl00_MainContent_txtPeads_Length').val();
            var txtPeads_HC = $('#ctl00_MainContent_txtPeads_HC').val();
            var txtPeads_General_Appearance = $('#ctl00_MainContent_txtPeads_General_Appearance').val();
            var chkPeads_Cyanosis = document.getElementById('ctl00_MainContent_chkPeads_Cyanosis').checked;
            var chkPeads_Jaundice = document.getElementById('ctl00_MainContent_chkPeads_Jaundice').checked;
            var chkPeads_Lethargy = document.getElementById('ctl00_MainContent_chkPeads_Rash').checked;
            var chkPeads_Rash = document.getElementById('ctl00_MainContent_chkPeads_Rash').checked;
            var txtPeads_Others = $('#ctl00_MainContent_txtPeads_Others').val();
            var chkPeads_Caput = document.getElementById('ctl00_MainContent_chkPeads_Caput').checked;
            var chkPeads_Cephalhematoma = document.getElementById('ctl00_MainContent_chkPeads_Cephalhematoma').checked;
            var rdbPeads_Anterioropen = document.getElementById('ctl00_MainContent_rdbPeads_Anterioropen').checked;
            var rdbPeads_AnteriorClose = document.getElementById('ctl00_MainContent_rdbPeads_AnteriorClose').checked;
            var chkPeads_Dextrocardia = document.getElementById('ctl00_MainContent_chkPeads_Dextrocardia').checked;
            var chkPeads_Bulging = document.getElementById('ctl00_MainContent_chkPeads_Bulging').checked;
            var chkPeads_Murmur = document.getElementById('ctl00_MainContent_chkPeads_Murmur').checked;
            var txtPeads_HeartSound = $('#ctl00_MainContent_txtPeads_HeartSound').val();
            var chkPeads_Nasal = document.getElementById('ctl00_MainContent_chkPeads_Nasal').checked;
            var chkPeads_Recessions = document.getElementById('ctl00_MainContent_chkPeads_Recessions').checked;
            var txtPeads_AddedSounds = $('#ctl00_MainContent_txtPeads_AddedSounds').val();
            var rdbPeads_Flat = document.getElementById('ctl00_MainContent_rdbPeads_Flat').checked;
            var rdbPeads_Distended = document.getElementById('ctl00_MainContent_rdbPeads_Distended').checked;
            var rdbPeads_Scaphoid = document.getElementById('ctl00_MainContent_rdbPeads_Scaphoid').checked;
            var chkPeads_Liver = document.getElementById('ctl00_MainContent_chkPeads_Liver').checked;
            var chkPeads_Spleen = document.getElementById('ctl00_MainContent_chkPeads_Spleen').checked;
            var txtPeads_GITOthers = $('#ctl00_MainContent_txtPeads_GITOthers').val();
            var chkPeads_Sucking = document.getElementById('ctl00_MainContent_chkPeads_Sucking').checked;
            var chkPeads_Rooting = document.getElementById('ctl00_MainContent_chkPeads_Rooting').checked;
            var chkPeads_Moro = document.getElementById('ctl00_MainContent_chkPeads_Moro').checked;
            var txtPeads_CNSOthers = $('#ctl00_MainContent_txtPeads_CNSOthers').val();
            var chkPeads_FullTerm = document.getElementById('ctl00_MainContent_chkPeads_FullTerm').checked;
            var chkPeads_PreTerm = document.getElementById('ctl00_MainContent_chkPeads_PreTerm').checked;
            var txtPeads_DateOfDelivery = $('#ctl00_MainContent_txtPeads_DateOfDelivery').val();
            var txtPeads_TimeOfDelivery = $('#ctl00_MainContent_txtPeads_TimeOfDelivery').val();
            var rdbPeads_Booked = document.getElementById('ctl00_MainContent_rdbPeads_Booked').checked;
            var rdbPeads_UnBooked = document.getElementById('ctl00_MainContent_rdbPeads_UnBooked').checked;
            var chkPeads_DAIHandling = document.getElementById('ctl00_MainContent_chkPeads_DAIHandling').checked;
            var chkPeads_ANTURash = document.getElementById('ctl00_MainContent_chkPeads_ANTURash').checked;
            var chkPeads_PIH = document.getElementById('ctl00_MainContent_chkPeads_PIH').checked;
            var chkPeads_GDM = document.getElementById('ctl00_MainContent_chkPeads_GDM').checked;
            var chkPeads_Vacinated = document.getElementById('ctl00_MainContent_chkPeads_Vacinated').checked;
            var txtPeads_ANTOthers = $('#ctl00_MainContent_txtPeads_ANTOthers').val();
            var rdbPeads_SVD = document.getElementById('ctl00_MainContent_rdbPeads_SVD').checked;
            var rdbPeads_LSCS = document.getElementById('ctl00_MainContent_rdbPeads_LSCS').checked;
            var rdbPeads_Emergency = document.getElementById('ctl00_MainContent_rdbPeads_Emergency').checked;
            var rdbPeads_Elective = document.getElementById('ctl00_MainContent_rdbPeads_Elective').checked;
            var txtPeads_PlaceOfDelivery = $('#ctl00_MainContent_txtPeads_PlaceOfDelivery').val();
            var txtPeads_IndicationForLSCS = $('#ctl00_MainContent_txtPeads_IndicationForLSCS').val();
            var Peads_apgerScore1min = $('#ctl00_MainContent_ddlPeads_apgerScore1min').val();
            if (Peads_apgerScore1min == 0)
                Peads_apgerScore1min = "";
            var Peads_apgerScore5min = $('#ctl00_MainContent_ddlPeads_apgerScore5min').val();
            if (Peads_apgerScore5min == 0)
                Peads_apgerScore5min = "";
            var chkPeads_Resuscitation = document.getElementById('ctl00_MainContent_chkPeads_Resuscitation').checked;
            var txtPeads_NatalOthers = $('#ctl00_MainContent_txtPeads_NatalOthers').val();
            var chkPeads_Moaning = document.getElementById('ctl00_MainContent_chkPeads_Moaning').checked;
            var chkPeads_RespDistress = document.getElementById('ctl00_MainContent_chkPeads_RespDistress').checked;
            var chkPeads_PostNATALCyanosis = document.getElementById('ctl00_MainContent_chkPeads_PostNATALCyanosis').checked;
            var chkPeads_Fits = document.getElementById('ctl00_MainContent_chkPeads_Fits').checked;
            var chkPeads_ReluctanceToFeed = document.getElementById('ctl00_MainContent_chkPeads_ReluctanceToFeed').checked;
            var txtPeads_PostNatalOthers = $('#ctl00_MainContent_txtPeads_PostNatalOthers').val();

            var ddlDischarge_By = $('#ctl00_MainContent_ddlDischarge_By').val();
            var txtDischarge_On = $('#ctl00_MainContent_txtDischarge_On').val();
            var txtNext_Visit = $('#ctl00_MainContent_txtNext_Visit').val();
            //var ddlPatientCondition = $("#ctl00_MainContent_ddlPatientCondition").val();
            //if (ddlPatientCondition == "0" || ddlPatientCondition == 'undefined' || ddlPatientCondition == " " || ddlPatientCondition == null) {
            //    ddlPatientCondition = "01";
            //}


            if (txtNext_Visit == "")
                txtNext_Visit = null;
            var txtAdvice = $('#ctl00_MainContent_txtPrevention_Precaution').val();
            var chkdischarge = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;


            if (ReferToOPD === true && chkdischarge === false) {
                alert("Discharge Patient First If want to Reffer");
                return;
            }
            var RateBeats = $("#ctl00_MainContent_txtRateBeats").val();
            var txtbsr = $("#ctl00_MainContent_txtbsr").val();
            var Saturation = $("#ctl00_MainContent_txtSaturation").val();
            var OthersRN = $("#ctl00_MainContent_txtOthersRcvNote").val();
            var DischargeStatus = $("#ctl00_MainContent_ddlDischargeStatus").val();
            var ddlEmrgRhythm = $('#ctl00_MainContent_ddlRhythm').val();
            var ddlEmrgVolume = $('#ctl00_MainContent_ddlVolume').val();
            var Procedure_Recommended = $("#ctl00_MainContent_txtProcedureRecommended").val();
            var IdentificationMarks = $("#ctl00_MainContent_txtIdentificationMarks").val();
            var Diagnosis = $("#ctl00_MainContent_txtDiagnosis").val();
            var DateOfDeath = $("#ctl00_MainContent_txtDateofDeath").val();
            var TimeOfDeath = $("#ctl00_MainContent_txtTimeOfDeath").val();
            var PlaceOfDeath = $("#ctl00_MainContent_ddlPlaceOfDeath").val();
            var CauseOfDeath = $("#ctl00_MainContent_txtCause_Of_Death").val();
            var IssuingOfficerName = $("#ctl00_MainContent_txtIssuingOfficerName").val();
            var DeathCertifiedby1 = $("#ctl00_MainContent_ddlDeathCertifiedbyDr1").val();
            var DeathCertifiedby2 = $("#ctl00_MainContent_ddlDeathCertifiedbyDr2").val();
            var BodyHandedOverTo = $("#ctl00_MainContent_txtBodyHandedOverTo").val();
            var FamilyPersonName = $("#ctl00_MainContent_txtFamilyPersonName").val();
            var CNIC = $("#ctl00_MainContent_txtCNIC").val();
            var RelationWithDeceased = $("#ctl00_MainContent_txtRelationWithDeceased").val();
            var CMO_Police = $("#ctl00_MainContent_txtCMO_Police").val();

            var TreatmentGiven = $("#ctl00_MainContent_txtTreatmentGiven").val();
            var PhysicalFinding = $("#ctl00_MainContent_txtPhysicalFinding").val();
            var GeneralPhysicalExamination = $("#ctl00_MainContent_txtGeneralPhysicalExamination").val();
            var ClinicalSummary = $("#ctl00_MainContent_txtClinicalSummary").val();
            var TreatmentAtDischarge = $("#ctl00_MainContent_txtTreatmentAtDischarge").val();
            var FollowUpPlanInstructions = $("#ctl00_MainContent_txtFollowUpPlanInstructions").val();
            var CauseOfReferral = $("#ctl00_MainContent_txtCauseOfReferral").val();
            var ReferredTo = $("#ctl00_MainContent_ddlReferredTo").val();
            // var TreatmentTime = $("#ctl00_MainContent_txtTreatmentTime").val();

            var CallingDoctorDepartment = $("#ctl00_MainContent_ddl_Department").val();
            var CallingDoctorMobile = $("#ctl00_MainContent_txtMobileNo").val();
            var O2_Saturation_Oxygen1 = $("#ctl00_MainContent_txtSaturation_Oxygen1").val();
            var O2_Saturation_Oxygen2 = $("#ctl00_MainContent_txtSaturation_Oxygen2").val();


            var HMFIntact = $("input[name='ctl00$MainContent$HMFIntact']:checked").val();
            if (typeof HMFIntact === 'undefined')
                HMFIntact = null;
            else HMFIntact = (JSON.parse(HMFIntact.toLowerCase()));


            var CranialNerves = $("input[name='ctl00$MainContent$CranialNerves']:checked").val();
            if (typeof CranialNerves === 'undefined') CranialNerves = null;
            else CranialNerves = (JSON.parse(CranialNerves.toLowerCase()));

            var SignsOfMeningism = $("input[name='ctl00$MainContent$SignsOfMeningism']:checked").val();
            if (typeof SignsOfMeningism === 'undefined') SignsOfMeningism = null;
            else SignsOfMeningism = (JSON.parse(SignsOfMeningism.toLowerCase()));

            var HeartSound = $("input[name='ctl00$MainContent$HeartSound']:checked").val();
            if (typeof HeartSound === 'undefined') HeartSound = null;
            else HeartSound = (JSON.parse(HeartSound.toLowerCase()));

            var Arrhythmias = $("input[name='ctl00$MainContent$Arrhythmias']:checked").val();
            if (typeof Arrhythmias === 'undefined') Arrhythmias = null;
            else Arrhythmias = (JSON.parse(Arrhythmias.toLowerCase()));

            var AnyOtherAddedSound = $("input[name='ctl00$MainContent$AnyOtherAddedSound']:checked").val();
            if (typeof AnyOtherAddedSound === 'undefined') AnyOtherAddedSound = null;
            else AnyOtherAddedSound = (JSON.parse(AnyOtherAddedSound.toLowerCase()));

            var AnyOtherFindings = $("input[name='ctl00$MainContent$AnyOtherFindings']:checked").val();
            if (typeof AnyOtherFindings === 'undefined') AnyOtherFindings = null;
            else AnyOtherFindings = (JSON.parse(AnyOtherFindings.toLowerCase()));

            var NVB_Right = $("input[name='ctl00$MainContent$NVB_Right']:checked").val();
            if (typeof NVB_Right === 'undefined') NVB_Right = null;
            else NVB_Right = (JSON.parse(NVB_Right.toLowerCase()));

            var NVB_Left = $("input[name='ctl00$MainContent$NVB_Left']:checked").val();
            if (typeof NVB_Left === 'undefined') NVB_Left = null;
            else NVB_Left = (JSON.parse(NVB_Left.toLowerCase()));

            var Crepitation_Right = $("input[name='ctl00$MainContent$Crepitation_Right']:checked").val();
            if (typeof Crepitation_Right === 'undefined') Crepitation_Right = null;
            else Crepitation_Right = (JSON.parse(Crepitation_Right.toLowerCase()));

            var Crepitation_Left = $("input[name='ctl00$MainContent$Crepitation_Left']:checked").val();
            if (typeof Crepitation_Left === 'undefined') Crepitation_Left = null;
            else Crepitation_Left = (JSON.parse(Crepitation_Left.toLowerCase()));

            var Wheeze = $("input[name='ctl00$MainContent$Wheeze']:checked").val();
            if (typeof Wheeze === 'undefined') Wheeze = null;
            else Wheeze = (JSON.parse(Wheeze.toLowerCase()));

            var Ranchi = $("input[name='ctl00$MainContent$Ranchi']:checked").val();
            if (typeof Ranchi === 'undefined') Ranchi = null;
            else Ranchi = (JSON.parse(Ranchi.toLowerCase()));

            var AnyOtherSound = $("input[name='ctl00$MainContent$AnyOtherSound']:checked").val();
            if (typeof AnyOtherSound === 'undefined') AnyOtherSound = null;
            else AnyOtherSound = (JSON.parse(AnyOtherSound.toLowerCase()));

            var AbdomenSoft = $("input[name='ctl00$MainContent$AbdomenSoft']:checked").val();
            if (typeof AbdomenSoft === 'undefined') AbdomenSoft = null;
            else AbdomenSoft = (JSON.parse(AbdomenSoft.toLowerCase()));

            var Tenderness = $("input[name='ctl00$MainContent$Tenderness']:checked").val();
            if (typeof Tenderness === 'undefined') Tenderness = null;
            else Tenderness = (JSON.parse(Tenderness.toLowerCase()));

            var Guarding = $("input[name='ctl00$MainContent$Guarding']:checked").val();
            if (typeof Guarding === 'undefined') Guarding = null;
            else Guarding = (JSON.parse(Guarding.toLowerCase()));

            var BowelSound = $("input[name='ctl00$MainContent$BowelSound']:checked").val();
            if (typeof BowelSound === 'undefined') BowelSound = null;
            else BowelSound = (JSON.parse(BowelSound.toLowerCase()));

            var Distention = $("input[name='ctl00$MainContent$Distention']:checked").val();
            if (typeof Distention === 'undefined') Distention = null;
            else Distention = (JSON.parse(Distention.toLowerCase()));

            var FluidThrill = $("input[name='ctl00$MainContent$FluidThrill']:checked").val();
            if (typeof FluidThrill === 'undefined') FluidThrill = null;
            else FluidThrill = (JSON.parse(FluidThrill.toLowerCase()));

            var ShiftingDullness = $("input[name='ctl00$MainContent$ShiftingDullness']:checked").val();
            if (typeof ShiftingDullness === 'undefined') ShiftingDullness = null;
            else ShiftingDullness = (JSON.parse(ShiftingDullness.toLowerCase()));

            var EpigastriaDiscomfort = $("input[name='ctl00$MainContent$EpigastriaDiscomfort']:checked").val();
            if (typeof EpigastriaDiscomfort === 'undefined') EpigastriaDiscomfort = null;
            else EpigastriaDiscomfort = (JSON.parse(EpigastriaDiscomfort.toLowerCase()));

            var RetrosternalBurning = $("input[name='ctl00$MainContent$RetrosternalBurning']:checked").val();
            if (typeof RetrosternalBurning === 'undefined') RetrosternalBurning = null;
            else RetrosternalBurning = (JSON.parse(RetrosternalBurning.toLowerCase()));

            var Jondus = $("input[name='ctl00$MainContent$Jondus']:checked").val();
            if (typeof Jondus === 'undefined') Jondus = null;
            else Jondus = (JSON.parse(Jondus.toLowerCase()));

            var Pallor = $("input[name='ctl00$MainContent$Pallor']:checked").val();
            if (typeof Pallor === 'undefined') Pallor = null;
            else Pallor = (JSON.parse(Pallor.toLowerCase()));

            var Dehydration = $("input[name='ctl00$MainContent$Dehydration']:checked").val();
            if (typeof Dehydration === 'undefined') Dehydration = null;
            else Dehydration = (JSON.parse(Dehydration.toLowerCase()));

            var GCSOrientation = $("input[name='ctl00$MainContent$GCSOrientation']:checked").val();
            if (typeof GCSOrientation === 'undefined') GCSOrientation = null;
            else GCSOrientation = (JSON.parse(GCSOrientation.toLowerCase()));

            var ConsciousOrientely = $("input[name='ctl00$MainContent$ConsciousOrientely']:checked").val();
            if (typeof ConsciousOrientely === 'undefined') ConsciousOrientely = null;
            else ConsciousOrientely = (JSON.parse(ConsciousOrientely.toLowerCase()));

            var Murmur = $("input[name='ctl00$MainContent$Murmur']:checked").val();
            if (typeof Murmur === 'undefined') Murmur = null;
            else Murmur = JSON.parse(Murmur.toLowerCase());

            var FurtherExplanation = $("#ctl00_MainContent_txtFurtherExplanation").val();
            var TextBoxCns = $("#ctl00_MainContent_TextBoxCns").val();
            var TextBoxCvs = $("#ctl00_MainContent_TextBoxCvs").val();
            var TextBoxResp = $("#ctl00_MainContent_TextBoxResp").val();
            var TextBoxGit = $("#ctl00_MainContent_TextBoxGit").val();
            var TextBoxGpe = $("#ctl00_MainContent_TextBoxGpe").val();

            var eye_response = $('#ctl00_MainContent_ctl00_MainContent_txtEOR').val();
            var motor_response = $('#ctl00_MainContent_txtMR').val();
            var verbal_Response = $('#ctl00_MainContent_txtVR').val();
            var accumulated_response = $('#ctl00_MainContent_txtAcc').val();

            var PulseRate = $('#ctl00_MainContent_txtPulseRate').val();
            var BPDischarge = $('#ctl00_MainContent_txtBPDischarge').val();
            var Rhythmdischarge = $('#ctl00_MainContent_ddlRhythmdischarge').val();
            var Tempdisch = $('#ctl00_MainContent_txtTempdisch').val();
            var volumedisc = $('#ctl00_MainContent_ddlvolumedisc').val();
            var RespRateDesc = $('#ctl00_MainContent_txtRespRateDesc').val();
            var Oxygen2_desc = $('#ctl00_MainContent_txtSaturation_Oxygen2_desc').val();
            var saturationDis = $('#ctl00_MainContent_txtsaturationDis').val();
            var Oxygen1 = $('#ctl00_MainContent_txtOxygen1').val();
            var otherecdesc = $('#ctl00_MainContent_txtotherecdesc').val();
            var Special_Instruction_Desc = $('#ctl00_MainContent_txtRN_Special_Instruction_Desc').val();
            var Receiving_DateDesc = $('#ctl00_MainContent_txttxtReceiving_DateDesc').val();
            var remrks_call_to_doc = $('#ctl00_MainContent_txtCallToDoctor').val();
            var emer_doc_id = $('#hdnEmergencyDocId').val();
            //var discount = $('#ctl00_MainContent_txtDiscount').val();
            //var Remarks = $('#ctl00_MainContent_txt_remarks').val();


            // TreatmentTime,txtAdmission_Date, ddlDepartment, ddlDoctor, ddlWard_No, txtBed_No, discount,patientcateg, Remarks,ddlIssuance_Of,ddlPatientCondition,

            var ID = '<%= Request.QueryString["ID"]%>';
            PageMethods.SaveRecord(Patient_ID, btnsave, ddlCallToDoctor, txtHealth_Complaints, RateBeats, txtbsr, BP_mm_Hg, Temp_C, Respiration_Min, txtRN_Special_Instruction, txtReceiving_Date, Provisional_Diagnosis, Reffer_To, HistoryOfPeresentIllness, HistoryOfFamily, HistoryOfPastIllness, SocioEconomicHistory, Birth_History, Reffer_No, Drug_History, Personal_History, ObstetricHistory, AllergiesHistory, TreatmentHistory, VaccinationHistory, AnyOtherHistory, ENT_Throat_IDL, ENT_Throat_Nose, ENT_Ear_Right, Ent_Ear_Left, ENT_Rinnes_Right_PosNeg, ENT_Rinnes_Lft_PosNeg, ENT_Rinnes_Right_FalseNeg, ENT_Rinnes_Lft_FalseNeg, ENT_Webber_Central, ENT_Webber_Lateralized, ENT_Investigation_PTA, ENT_Investigation_Tympanometry, ENT_Rinnes_Right_Neg, ENT_Rinnes_Lft_Neg, ENT_Rinnes_Right_FNeg, ENT_Rinnes_Lft_FNeg, txtInformant, txtSourceOfReferral, chkNeckHolding, chkWalking, chkTalking, chkOthers, txtMenarche, txtMenstrual, txtAttachmentSeparationfromParents, txtHealth, chkNailBiting, chkTemperTantrums, chkBedWetting, txtAcademics, txtPeerRelationship, txtBehaviour, txtOccupationalHistory, txtMaritalRelationshipSexualHistory, txtSubstanceUse, txtForensicUse, txtRelationship, txtLeisureActivities, txtAttitudetoSelfandStandards, txtPrevallingMood, txtReactionPattrentoStress, txtReligiousPracticesAttitute, txtFather, txtMother, txtSiblings, txtHomeAtmosphererelationshipsocialclass, txtFamilialIllness, txtActualandapparentage, txtRace, txtTattoosbodypiercingandscars, txtBodyHabitus, txtDress, txtHygiene, txtPsychomotorActivity, txtInvoluntarymovements, txtDystoniaEPS, txtTardivedyskinesia, txtTics, txtTremors, txtAttentivenesstointerview, txtEyeContact, txtLevelofConsciousness, txtRate, txtRhythm, txtVolume, txtTone, txtModulationvar, txtDepressed, txtElated, txtIrritable, txtLabile, txtIncongruent, txtbluntingflatteningapathy, txtThinkingPremeditation, txtPlans, txtActions, txtPreservative, txtLoosAssociation, txtTangentiaility, txtCircumstantiality, txtFlightofIdeas, txtThoughtInsertion, txtThoughtWithdrawal, txtThoughBroadcasting, txtThoughControl, txtDellusion, txtovervaluedideas, txtDepresonalization, txtDerealization, txtthrougObsession, txtthrougPhobies, txtthrougHomocidialIdeas, txtillusion, txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, txtorientationtime, txtplace, txtperson, txtAttentionConcentrationSerial7Test, txtOrDaysOfWeekReverseOrder, txtImmediatememory, txtshorttermrecentevents, txtadressrecallafter2minutes, txtlongtermremoteevents, txtadressrecallafter5minues, txtgeneralknowledgequestion, txtsimplearthemeticcalculation, txtabstrationconcertethinking, txtinsight, DermaFace, DermaNeck, DermaTrunk, DermaUpperLimb, DermaLowerLimb, DermaFlexures, DermaGenitalias, DermaHair, DermaNail, DermaMucousMembrane, DermaEyes, DermaEars, DermaNose, DermaLips, HBM_Problem, HBM_Caused, HBM_Started, HBM_Course, HBM_Treatment, HBM_Effects, PE_Pluse, PE_BP, PE_Temperature, PE_Weight, PE_RespiratoryRate, PE_Jaundice, PE_Anemia, PE_Cyanosis, PE_Clubbing, PE_JVP, PE_LymphNodes, PE_Edema, PE_Respiratory, PE_Cardiovascular, PE_Gastro_Intestinal, PE_Observation, PE_Cranial_Nerves, PE_Limb_Strength, PE_Spasticity, PE_Position, PE_Vibration, PE_Stereognosis, PE_Pain, PE_Biceps, PE_Triceps, PE_Brachioradialis, PE_Quadriceps, PE_Patellar, PE_Achilles, PE_Extensor, PE_Frontal, PE_Finger, PE_Heel, PE_Movements, PE_Gait, PE_Neck_Rigidity, PE_Kerning_Sign, PE_Brudzinki_Sign, For_Summary, For_Diagnosis, For_AxisI, For_AxisII, For_AxisIII, For_AxisIV, For_AxisV, For_PredisposingFactors, For_PrecipitatingFactors, For_PrepetuatingFactors, For_Investigation, For_Medical, For_Psychological, For_Major_Issues, For_Strengths, For_Goals, For_Strategies, txtPeads_weight, txtPeads_Length, txtPeads_HC, txtPeads_General_Appearance, chkPeads_Cyanosis, chkPeads_Jaundice, chkPeads_Lethargy, chkPeads_Rash, txtPeads_Others, chkPeads_Caput, chkPeads_Cephalhematoma, rdbPeads_Anterioropen, rdbPeads_AnteriorClose, chkPeads_Dextrocardia, chkPeads_Bulging, chkPeads_Murmur, txtPeads_HeartSound, chkPeads_Nasal, chkPeads_Recessions, txtPeads_AddedSounds, rdbPeads_Flat, rdbPeads_Distended, rdbPeads_Scaphoid, chkPeads_Liver, chkPeads_Spleen, txtPeads_GITOthers, chkPeads_Sucking, chkPeads_Rooting, chkPeads_Moro, txtPeads_CNSOthers, chkPeads_FullTerm, chkPeads_PreTerm, txtPeads_DateOfDelivery, txtPeads_TimeOfDelivery, rdbPeads_Booked, rdbPeads_UnBooked, chkPeads_DAIHandling, chkPeads_ANTURash, chkPeads_PIH, chkPeads_GDM, chkPeads_Vacinated, txtPeads_ANTOthers, rdbPeads_SVD, rdbPeads_LSCS, rdbPeads_Emergency, rdbPeads_Elective, txtPeads_PlaceOfDelivery, txtPeads_IndicationForLSCS, Peads_apgerScore1min, Peads_apgerScore5min, chkPeads_Resuscitation, txtPeads_NatalOthers, chkPeads_Moaning, chkPeads_RespDistress, chkPeads_PostNATALCyanosis, chkPeads_Fits, chkPeads_ReluctanceToFeed, txtPeads_PostNatalOthers, txtDischarge_On, ddlDischarge_By, txtNext_Visit, txtAdvice, chkdischarge, patienttype, Saturation, OthersRN, DischargeStatus, ddlEmrgRhythm, ddlEmrgVolume, Procedure_Recommended, IdentificationMarks, Diagnosis, DateOfDeath, TimeOfDeath, PlaceOfDeath, CauseOfDeath, IssuingOfficerName, DeathCertifiedby1, DeathCertifiedby2, BodyHandedOverTo, FamilyPersonName, CNIC, RelationWithDeceased, CMO_Police, TreatmentGiven, PhysicalFinding, GeneralPhysicalExamination, ClinicalSummary, TreatmentAtDischarge, FollowUpPlanInstructions, CauseOfReferral, ReferredTo, CallingDoctorDepartment, CallingDoctorMobile, O2_Saturation_Oxygen1, O2_Saturation_Oxygen2, HMFIntact, CranialNerves, SignsOfMeningism, HeartSound, Arrhythmias, Murmur, AnyOtherAddedSound, AnyOtherFindings, NVB_Right, NVB_Left, Crepitation_Right, Crepitation_Left, Wheeze, Ranchi, AnyOtherSound, AbdomenSoft, Tenderness, Guarding, BowelSound, Distention, FluidThrill, ShiftingDullness, EpigastriaDiscomfort, RetrosternalBurning, Jondus, Pallor, Dehydration, GCSOrientation, ConsciousOrientely, FurtherExplanation, ID, TextBoxCns, TextBoxCvs, TextBoxResp, TextBoxGit, TextBoxGpe, eye_response, motor_response, verbal_Response, accumulated_response, PulseRate, BPDischarge, Rhythmdischarge, Tempdisch, volumedisc, RespRateDesc, Oxygen2_desc, saturationDis, Oxygen1, otherecdesc, Special_Instruction_Desc, Receiving_DateDesc, remrks_call_to_doc, emer_doc_id, ReferToOPD,
                function (response) {
                    debugger;

                    if (btnVal == 'btnSave') {
                        debugger;
                        sendFileEmer(response);
                        alert('Data Successfully Saved');
                        window.location = "EmergencyCase.aspx?ID=" + response;
                        $('#btnSave').val("Update");
                    }
                    else if (btnVal == 'btnsaveprint') {
                        PrintAdmisionDetails(response);
                        $('#btnSave').val("Update");
                    }

                });
        }
        function sendFileEmer(ID) {
            var data = new FormData();
            data.append('file', $('#ctl00_MainContent_file_upload')[0].files[0]);
            data.append('ID', ID);
            $.ajax({
                type: 'POST',
                url: '<%= ResolveUrl("~/upload/UploadEmergency.ashx") %>',  // ? FIXED HERE
                data: data,
                processData: false,
                contentType: false,
                success: function (status) {
                    console.log("Upload Successful:", status);
                },
                error: function (xhr, status, error) {
                    alert("Error: " + xhr.status + " - " + error);
                }
            });
        }

        function ShowDermaModel() {
            $('#myModalDerma').modal({
                backdrop: 'static'
            });
        }
        function ShowOrthoModel() {
            $('#myModalOrtho').modal({
                backdrop: 'static'
            });
        }
        function ShowEyeModel() {
            $('#EyeModel').modal({
                backdrop: 'static'
            });
        }

        function ShowPsychiatryModel() {
            $('#PsychiatryModel').modal({
                backdrop: 'static'
            });
        }


        function ShowEntModel() {
            $('#myModalENT').modal({
                backdrop: 'static'
            });
        }
        function GotoinPatientMoi() {

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            window.location = "InPatientMonitoring.aspx";

        }
        function GetInvestigationTab() {
            var doctor = $('#ddlInvestigationDoctor').val();
            if (doctor == "0" || doctor == null) {
                alert("Please Select Doctor Name..")
            }
            else {

                $('#ctl00_MainContent_chkdoctor').prop('checked', true);

                var chkPallor = document.getElementById("ctl00_MainContent_chkdoctor").checked;
                localStorage.DoctorNoteTab = "true";

                $("#tabs").tabs("option", "active", 3);
            }

        }



        function InsertLabResult() {

            var dis = document.getElementById('ctl00_MainContent_cbDicharg_Slip').checked;
            if (dis == true) {


                return false;
            }

            var ResultrptVal = $('#ctl00_MainContent_ddlLabResult').find('option:selected').val();
            var ResultrptName = $('#ctl00_MainContent_ddlLabResult').find('option:selected').text();
            if (ResultrptVal != "0") {
                var Date = '<%= DateTime.Now %>';
                var rows;
                rows += '<tr> <td><input type="hidden" name ="txtLabResultrpt" value="' + ResultrptVal + '"> ' + ResultrptName
                    + ' </td><td><input type="text" name ="txtResultName" style="width: 159px !important;"> </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td> </tr>';

                $('#tblResultrpt tbody').append(rows);
                $('#ctl00_MainContent_ddlLabResult').val("0");
            }
        }

        function InsertDoctorNote() {

            var doctor = $('#ddlInvestigationDoctor').val();
            if (doctor == "0" || doctor == null) {
                alert("Please Select Doctor Name..")
            }
            else {
                var Date = $('#ctl00_MainContent_txtMo_Date').val();
                var doctorVal = $('#ddlInvestigationDoctor').find('option:selected').val();
                var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').find('option:selected').text();
                var DoctorStatusVal = $('#ctl00_MainContent_ddlMO_Doctor_Status').find('option:selected').val();
                var DoctorStatus = $('#ctl00_MainContent_ddlMO_Doctor_Status').find('option:selected').text();
                var ProgressNote = $('#ctl00_MainContent_txtMo_Progress_Note').val();
                var Mo_Instruction = $('#ctl00_MainContent_txtMo_Instruction').val();
                var rows;
                var countDoctorNotes = tblDOctorNotes.rows.length;
                rows += '<tr> <input type="hidden" name ="DoctorNotesID" value="' + countDoctorNotes + '"> <td> ' + Date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="' + DoctorStatusVal + '"> ' + DoctorStatus
                    + ' </td> <td><input type="hidden" name ="txtDoctorValue" value="' + doctorVal + '"> ' + doctor
                    + ' </td> <td> ' + ProgressNote + ' </td> <td>' + Mo_Instruction + '</td><td><a href="javascript:void(0)" onclick="deleteInstruction(this)">Delete</a></td> </tr>';
                $('#tblDOctorNotes tbody').append(rows);

                $('#ctl00_MainContent_txtMo_Progress_Note').val("");
                $('#ctl00_MainContent_txtMo_Instruction').val("");
                var countIns = tblInstruction.rows.length;
                var row = "";
                if (Mo_Instruction != "") {
                    row += '<tr>  <td> ' + Date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="' + DoctorStatusVal + '"> ' + doctor
                        + ',' + DoctorStatus
                        + ' <input type="hidden" name ="txtDoctorValue" value="' + doctorVal + '"> <td>' + Mo_Instruction + '</td><td><input type="checkbox" name="chekInstruction"></td></tr>';
                    $('#tblInstruction tbody').append(row);
                }

            }
        }
        function PrintRecord() {
            var emergency_id = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            window.open('ReportViewer.aspx?ReportName=EmergencyBasePrint&ReportTitle=Emergency Base Print&Emergency_ID=' + emergency_id);
        }
        function FillInstruction() {

            var doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
            var doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();
            var Date = $('#ctl00_MainContent_txtReceiving_Date').val();
            var Instruction = $('#ctl00_MainContent_txtRN_Special_Instruction').val();
            var DOcInstruction = $('#ctl00_MainContent_txtMo_Instruction').val();
            var rows;
            rows += '<tr> <td> ' + Date + ' </td> <td><input type="hidden" name ="txtDoctorValue" value="' + doctorVal + '"> ' + doctor
                + ' </td> <td> ' + Instruction + ',' + DOcInstruction + ' </td> <td><input type="checkbox" name="chekInstruction"></td> </tr>';
            $('#tblInstruction tbody').append(rows);
        }
        function GetLastMediceineTab() {
            var doctor = $('#ddlInvestigationDoctor').val();
            if (doctor == "0" || doctor == null) {
                alert("Please Select Doctor Name..")
            }
            else {
                $('#ctl00_MainContent_chkMedDoctor').prop('checked', true);

                $("#tabs").tabs("option", "active", 4);
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
                $('#txtMedicen').hide();
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();

                localStorage.DoctorNoteTab = "true";


            }

        }
        function AddDischageMedication(row) {
            debugger;
            button_text_name = $(row).attr('id');
            $("#btnSaveMedicine").val('Save');
            localStorage.IsDischarge = 1;
            var dis = document.getElementById('ctl00_MainContent_cbDicharg_Slip').checked;
            if (dis == true) {


            }

            if (button_text_name == "btnAddMedicine") {

                $('#spnFreq').hide();
                $('#spndur').hide();
            }
            else {
                $('#spnFreq').show();
                $('#spndur').show();

            }



            var doctor = $('#ctl00_MainContent_ddlDischarge_By').val();
            if (doctor == "0") {
                alert("Please Select Doctor Name..")
            }
            else {
                $('#ctl00_MainContent_chkDischargeMedication').prop('checked', true);
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
                $('#txtMedicen').hide();
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();
            }
        }
        function tblDischargeNote(PatientID) {
            $('#tblHistoryHeader').html('<h2>Loading Previous History Please Wait...</h2>')
            PageMethods.LoadDischargeNoteHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var timeStamp = "";
                    var TrnsDateRec = "";

                    if (value.Discharge_On != null) {
                        timeStamp = parseInt(value.Discharge_On.substr(6, 10));

                        timeStamp = moment.unix(timeStamp).format("MM/DD/YYYY LTS");
                    }
                    if (value.Next_Visit != null) {
                        TrnsDateRec = parseInt(value.Next_Visit.substr(6, 10));
                        TrnsDateRec = moment.unix(TrnsDateRec).format('M/D/YYYY h:m:s A');
                    }
                    if (value.DoctorName == null)
                        value.DoctorName = "";
                    if (value.Reffer_To == null)
                        value.Reffer_To = "";

                    rows += '<tr><td> ' + value.DoctorName +
                        ' </td><td> ' + timeStamp +
                        ' </td><td> ' + value.Prevention_Precaution +
                        ' </td><td> ' + value.TreatmentAtDischarge +
                        ' </td><td> ' + value.Procedure_Recommended +
                        ' </td><td> ' + value.CauseOfReferral +
                        ' </td><td> ' + value.Reffer_To +
                        ' </td><td> ' + value.FollowUpPlanInstructions +
                        ' </td><td> ' + value.Discharge_Status +

                        ' </td></tr>';
                });
                $('#tblDischargeNote tbody tr').remove();
                $('#tblDischargeNote tbody').html(rows);
                $('#tblHistoryHeader').html('<h2>Previous History</h2>');
            }, function (e) { });
        }

        function LoadExaminationTabHistory(PatientID) {

            $('#tblExaminationHistoryHeader').html('<h2 class="heading">Loading Previous History Please Wait...</h2>');

            PageMethods.LoadExaminationHistory(PatientID, function (res) {

                var Data = JSON.parse(res);

                var rows = "";
                $.each(Data, function (key, value) {

                    rows = "<tr><td>" + Data[key].HMFIntact +
                        "</td><td>" + value.CranialNerves +
                        "</td><td>" + value.SignsOfMeningism +
                        "</td><td>" + value.HeartSound +
                        "</td><td>" + value.Arrhythmias +
                        "</td><td>" + value.Murmur +
                        "</td><td>" + value.AnyOtherAddedSound +
                        "</td><td>" + value.AnyOtherFindings +
                        "</td><td>" + value.Wheeze +
                        "</td><td>" + value.Ranchi +
                        "</td><td>" + value.AnyOtherSound +
                        "</td><td>" + value.AbdomenSoft +
                        "</td><td>" + value.Tenderness +
                        "</td><td>" + value.Guarding +
                        "</td><td>" + value.BowelSound +
                        "</td><td>" + value.Distention +
                        "</td><td>" + value.FluidThrill +
                        "</td><td>" + value.ShiftingDullness +
                        "</td><td>" + value.EpigastriaDiscomfort +
                        "</td><td>" + value.RetrosternalBurning +
                        "</td><td>" + value.Jondus +
                        "</td><td>" + value.Pallor +
                        "</td><td>" + value.Dehydration +
                        "</td><td>" + value.GCSOrientation +
                        "</td><td>" + value.Conscious_Orientely +
                        "</td><td>" + value.NVB_Right +
                        "</td><td>" + value.NVB_Left +
                        "</td><td>" + value.Crepitation_Right +
                        "</td><td>" + value.Crepitation_Left +
                        "</td><td>" + value.FurtherExplanation +
                        "</td></tr>";
                });

                $("#tblExaminationHistory tbody tr").remove();
                $("#tblExaminationHistory tbody").html(rows);
                $('#tblExaminationHistoryHeader').html('<h2 class="heading">Previous History</h2>');

            }, function (e) { });

        }

        function LoadVitalParametersHistoryDicharge(PatientID) {

            if (PatientID != "(New)") {
                PageMethods.LoadVitalParametersHistoryDicharge(PatientID, function (res) {
                    var Data = JSON.parse(res);
                    var rows = '';
                    var gcs = "";
                    $.each(Data, function (key, value) {
                        if (value.GCS == null) {

                            GCS = "";
                        }
                        else {
                            gcs = value.GCS;
                        }

                        var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));
                        var retdateRec = moment.unix(TrnsDateRec).format('M/D/YYYY h:m:s A');
                        rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.Rate_Beats
                            + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.BSR + ' </td> <td> ' + value.Rhythm + ' </td><td> ' + value.Volume + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td> ' + value.OthersRcvNote + ' </td> <td> ' + value.Respiration_Min + ' </td><td> ' + value.RN_Special_Instruction + ' </td><td> ' + value.O2_Saturation + ' </td><td>' + value.O2_Saturation_Oxygen1 + '</td><td>' + value.O2_Saturation_Oxygen2 + '</td><td>' + value.user + '</td></tr>';
                    });
                    $('#tblVitalParametersHistoryDesc tbody tr').remove();
                    $('#tblVitalParametersHistoryDesc tbody').html(rows);
                });
            }
        }
        debugger;
        function LoadVitalParametersHistory(PatientID) {
            debugger;
            if (PatientID != "(New)") {
                PageMethods.LoadVitalParametersHistory(PatientID, function (res) {
                    var Data = JSON.parse(res);
                    var rows = '';
                    var gcs = "";
                    $.each(Data, function (key, value) {
                        if (value.GCS == null) {

                            GCS = "";
                        }
                        else {
                            gcs = value.GCS;
                        }

                        var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));
                        var retdateRec = moment.unix(TrnsDateRec).format('M/D/YYYY h:m:s A');
                        console.log(rows);
                        rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.Rate_Beats
                            + ' </td> <td> ' + value.Temp_C + ' </td><td> ' + value.BSR + ' </td> <td> ' + value.Rhythm + ' </td><td> ' + value.Volume + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td> ' + value.OthersRcvNote + ' </td> <td> ' + value.Respiration_Min + ' </td><td> ' + value.RN_Special_Instruction + ' </td><td> ' + value.O2_Saturation + ' </td><td>' + value.O2_Saturation_Oxygen1 + '</td><td>' + value.O2_Saturation_Oxygen2 + '</td><td>' + value.user + '</td></tr>';
                    });
                    $('#tblVitalParametersHistory tbody tr').remove();
                    $('#tblVitalParametersHistory tbody').html(rows);
                    $('#tblHistoryHeader').html('<h2>Previous History</h2>')

                    $("#ctl00_MainContent_txtRateBeats").val("");
                    $("#ctl00_MainContent_txtbsr").val("");
                    //$("#ctl00_MainContent_ddlRhythm").val("");
                    //$("#ctl00_MainContent_ddlVolume").val("");
                    $("#ctl00_MainContent_txtOthersRcvNote").val("");

                    $("#ctl00_MainContent_txtBP").val("");
                    $("#ctl00_MainContent_txtBPDischarge").val("");

                    $("#ctl00_MainContent_txtTemp").val("");
                    $("#ctl00_MainContent_txtRespiration").val("");
                    $("#ctl00_MainContent_txtSaturation").val("");
                    $("#ctl00_MainContent_txtRN_Special_Instruction").val("");
                    $("#ctl00_MainContent_txtSaturation_Oxygen1").val("");
                    $("#ctl00_MainContent_txtSaturation_Oxygen2").val("");
                }, function (e) { });
            }
        }

        function FillRotations() {
            var options = '';
            PageMethods.GetRotations(function (GetRotations) {
                $.each(JSON.parse(GetRotations), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlRotation').html(options);
                $('#ddlRotation').select2();
            });
        }
        function FillTestsByCategory(CategoryID) {

            var options = '<option value="0" >Please Select</option>';

            if (CategoryID == '002') {
                $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').show();

                PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            else if (CategoryID == '004') {
                $("#btnCTscan").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');

                $('#divRotation').show();

                PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove();
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }


            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
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

            PageMethods.FillWardBeds($('#ctl00_MainContent_ddlWard_No').find('option:selected')[0].value, function (res) {
                var WardBeds = JSON.parse(res);
                var rows = '';
                debugger;
                $.each(WardBeds, function (key, value) {
                    let blinkClass = "";
                    let admDate = ParseDate(value.AdmissionDate);

                    if (admDate) {
                        let hoursDiff = (new Date() - admDate) / (1000 * 60 * 60);
                        if (hoursDiff > 8) {
                            blinkClass = "blink";
                        }
                    }

                    if (value.PatientNo == 0) {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td> <a href="#" onclick="SelectBed(' + value.WardID + ',' + value.BedNo + ')" style="color:Green"> ' + value.BedNo + ' </a> </td></tr>';
                    }
                    else {
                        rows += '<tr> <td class="' + blinkClass + '">' + value.PatientNo + ' </td><td class="' + blinkClass + '"><font color="red"> ' + value.BedNo + '</font></td></tr>';
                    }
                });
                $('#tblWards tbody tr').remove();
                $('#tblWards tbody').html(rows);
            });
        }
        function LoadFee() {
            var category = $("#ctl00_MainContent_ddlCategory").val();
            if (category == "01" || category == "02") {
                $("#ctl00_MainContent_txtDiscount").val(0);
            }
            else {
                $("#ctl00_MainContent_txtDiscount").val(100);
                $("#ctl00_MainContent_txtDiscount").atrr('disabled', true);
            }
        }
        function ParseDate(dateString) {
            if (dateString && dateString.startsWith("/Date(")) {
                return new Date(parseInt(dateString.substr(6)));
            }
            return null;
        }


        function FillWardBedsRefer_0() {
            PageMethods.FillWardBeds($('#ctl00_MainContent_ddlwards').find('option:selected')[0].value, function (res) {
                var WardBeds = JSON.parse(res);
                var rows = '';
                $.each(WardBeds, function (key, value) {
                    if (value.PatientNo == 0) {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td> <a href="#" onclick="SelectBedRefer(' + value.WardID + ',' + value.BedNo + ')" style="color:Green"> ' + value.BedNo + ' </a> </td></tr>';
                    }
                    else {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td ><font color="red"> ' + value.BedNo + '</font></td></tr>';
                    }
                });
                $('#tblBed tbody tr').remove();
                $('#tblBed tbody').html(rows);
            });
        }
        function uuid() {
            var uuid = "", i, random;
            for (i = 0; i < 32; i++) {
                random = Math.random() * 16 | 0;
                if (i == 8 || i == 12 || i == 16 || i == 20) {
                    uuid += "-"
                }
                uuid += (i == 12 ? 4 : (i == 16 ? (random & 3 | 8) : random)).toString(16);
            }
            return uuid;
        }

        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value=""> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Routes').html(options);

            });
        }
        function LoadMedicationHistoryNursing(PatientID) {
            if (PatientID != '(New)') {
                PageMethods.LoadMedicinesForHistoryNursing(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td style="display:none"> ' + value.Injections + ' </td> <td>' + value.DoctorName + '</td> <td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                    });
                    $('#tblHistoryMedicationNursing tbody tr').remove();
                    $('#tblHistoryMedicationNursing tbody').html(rows);
                });
            }
        }

        function LoadMedicationHistory(PatientID) {

            if (PatientID != '(New)') {
                $('#HeaderHistoryMedication').html('<h2 class="heading">Loading Previous History Please Wait....</h2>')
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr>' + '<td><input type="checkbox" class="row-checkbox" /></td>' + '<td>' + newdate + '</td>' + '<td>' + value.Status + '</td>' + '<td>' + value.Medicine_Name + '</td>' +
                            '<td>' + value.Dosage_From + ' ' + value.Dosage_Qty + '</td>' + '<td>' + value.Frequency + '</td>' + '<td>' + (value.Oral || '') + ' ' + (value.Injections || '') + '</td>' +
                            '<td>' + value.Other_Instruction + '</td>' + '<td style="display:none;">' + value.AttendingParamedical_Staff + '</td>' + '</tr>';
                        if (value.Medicine_Name.length > 0)
                            $('#dvHistoryMedication').show();
                        else
                            $('#dvHistoryMedication').hide();
                    });
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                    $('#HeaderHistoryMedication').html('<h2 style="text-align: Center;" class="heading">Previous History</h2>');
                });
            }
        }

        function FillFrequency() {
            PageMethods.FillFrequencyDropDown(function (Frequency) {
                var options = '<option value=""> Select Frequency  </option>'
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + "-" + value.Segment1 + ' </option>';
                });
                $('#txtRecomended_Dosage').html(options);

            });

        }
        function FillMedicine() {
            PageMethods.FillMedicineDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#txtMedicineName').html(options);

            });
        }
        var skipClear = false;
        function getAndDisablePharmacyItem(itemID) {
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/getallpharmacyitems",  
                data: JSON.stringify({ itemID: itemID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    // Parse the JSON string returned by the WebMethod
                    var data = JSON.parse(response.d);

                    if (data && data.length > 0) {
                        var value = data[0]; // Get the first item
                        var $select = $('#txtPharmacyItem');

                        // 1. Set the flag to true to skip the Cleardrpdwn logic
                        skipClear = true;

                        // 2. Append the option using your preferred string format
                        $select.append('<option value="' + value.Item_ID + '">' + value.Description + '</option>');

                        // 3. Set the value and trigger change to update the Select2 UI
                        $select.val(value.Item_ID).trigger('change');

                        // 4. Disable the select to prevent further user interaction
                        $select.prop('disabled', true);

                        // 5. Reset the flag so future manual changes (if any) work normally
                        skipClear = false;
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: " + error);
                }
            });
        }
        function editMedicine(AnchorTag) {

            var table_name = $(AnchorTag).parents('table').attr('id');
            if (table_name == "tblDischargeMedication") {

                button_text_name = "btnDischarge";
                localStorage.IsDischarge = 1;
                $('#spnFreq').show();
                $('#spndur').show();

            }
            else if (table_name == "tblMedicinesList") {
                localStorage.IsDischarge = 0;
                button_text_name = "btnAddMedicine";

                $('#spnFreq').hide();
                $('#spndur').hide();
            }

            $('#MedicationModel').modal({
                backdrop: 'static'
            });

            $('#txtMedicineName').val('');
            $('#txtDosage').val('');
            $('#txtRecomended_Dosage').val('');
            $('#txtOral').val('');
            $('#txtInjection').val('');

            $('#btnSaveMedicine').val('Update');
            var row = $(AnchorTag).parents('tr')[0];
            var Medicine_Id = $($(row).find('td')[10]).text();
            var dosage_qty = $($(row).find('td')[7]).text().trim();
            var dosage_form = $($(row).find('td')[6]).text().trim();
            var frequency = $($(row).find('td')[2]).text().trim();
            var routes = $($(row).find('td')[3]).text().trim();
            var duration = $($(row).find('td')[4]).text().trim();
            var special_instruction = $($(row).find('td')[5]).text().trim();
            var other_instruction = $($(row).find('td')[8]).text().trim();
            skipClear = true;
            getAndDisablePharmacyItem(Medicine_Id);
            $("#ddlDosage_Qty").find('option:contains(' + dosage_qty + ')')[0].selected = true;
            $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
            $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;
            $('#ddlOther_Instruction').find('option:contains(' + other_instruction + ')')[0].selected = true;
            $('#txtMedicineName').val($($(row).find('td')[1]).text());
            if (Medicine_Id == '') {
                $('#txtMedicen').show();
                $('#txtMedicen').val($($(row).find('td')[1]).text());

            }
            else {
                $('#txtMedicen').hide();
                $('#txtMedicen').val('');

            }


            $('#txtInjection').val(duration);
            $('#AttendingParamedicalStaff').val(special_instruction);
            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());

        }

        function deleteMedicine(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();

        }

        function FillOtherInstruction() {
            PageMethods.FillOtherInstruction(function (Dosage) {
                var options = '<option value="0"> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlOther_Instruction').html(options);
            });
        }
        function LoadDischargeMedicines() {

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadDischageMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Oral.trim() == "Select Routes") value.Oral = '';
                        if (value.Dosage_Qty.trim() == "Select") value.Dosage_Qty = '';
                        if (value.Dosage_From.trim() == "Select") value.Dosage_From = '';
                        if (value.Other_Instruction.trim() == "Select") value.Other_Instruction = '';
                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td>  <td style="display:none;">' + value.Item_Code + '</td></tr>';
                    });
                    $('#tblDischargeMedication tbody').html(rows);
                });
            }
        }


        function LoadMedicines() {

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);

                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Oral.trim() == "Select Routes") value.Oral = '';
                        if (value.Dosage_Qty.trim() == "Select") value.Dosage_Qty = '';
                        if (value.Dosage_From.trim() == "Select") value.Dosage_From = '';
                        if (value.Other_Instruction.trim() == "Select") value.Other_Instruction = '';
                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td>  <td style="display:none;">' + value.Item_Code + '</td></tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                });
            }
        }

        function LoadLabResultrpt() {

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadLabResultrptDetail($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        rows += '<tr>  <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Lab_Resultrpt_ID + '"> ' + value.Lab_Resultrpt
                            + ' </td> <td><input type="text" name ="txtResultName" style="width: 159px !important;" value="' + value.Lab_Resultrpt_Name + ' "> </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td> </tr>';

                    });
                    $('#tblResultrpt tbody').append(rows);
                });
            }
        }

        function LoadDoctorNote() {

            if ($('#<%= hdfPatient_ID.ClientID%>').val() != '(New)') {
                $('#DoctorHistoryHeader').html('<h2 class="heading">Loading Previous History Please Wait...</h2>');
                PageMethods.LoadDoctorNoteDetail($('#<%= hdfPatient_ID.ClientID%>').val(), function (res) {
                    var doctorNotes = JSON.parse(res);
                    var rows = '';
                    $('#tblDoctorNotes tbody tr').remove();
                    $.each(doctorNotes, function (key, value) {

                        rows += "<tr><td>" + (value.DepartmentName || '') + "</td><td> " + (value.DoctorName || '') + "</td> \
                                     <td>" + (value.DoctorMobile || '') + "</td><td style='text-align: left;'>" + (value.DoctorNotes || '') + "</td> \
                                     <td style='display:none;'>" + (value.DepartmentValue || '') + "</td> \
                                     <td style='display:none;'>" + (value.DoctorToCallValue || '') + "</td> \
                                     <td style='display:none;'>" + (value.EmergencyDocId || '') + "</td> \
                                     <td><input type='button' class='btn btn-primry' value='Edit' onclick='EditDoctorNote(this)' /></td></tr>";



                    });

                    $('#tblDoctorNotes tbody').append(rows);
                    $('#DoctorHistoryHeader').html('<h2 class="heading">Previous History</h2>');
                });
            }
        }

        function EditDoctorNote(anchor) {
            var row = $(anchor).closest('tr');
            var departmentVal = $.trim($(row).find('td:eq(4)').text());
            var doctorVal = $.trim($(row).find('td:eq(5)').text());
            var emergencyDocId = $.trim($(row).find('td:eq(6)').text());
            var mobileNo = $.trim($(row).find('td:eq(2)').text());
            var doctorNotes = $.trim($(row).find('td:eq(3)').text());

            $('#ctl00_MainContent_ddl_Department').val(departmentVal).trigger('change');
            Get_Doctor_Info(function () {
                $('#ctl00_MainContent_ddlCallToDoctor').val(doctorVal).trigger('change');
            });

            $('#ctl00_MainContent_txtMobileNo').val(mobileNo);
            $('#ctl00_MainContent_txtCallToDoctor').val(doctorNotes);
            $('#hdnEmergencyDocId').val(emergencyDocId);
        }

        function NewDoctorNote() {
            $('#hdnEmergencyDocId').val('');
            $('#ctl00_MainContent_ddl_Department').val('0').trigger('change');
            $('#ctl00_MainContent_ddlCallToDoctor').val('0').trigger('change');
            $('#ctl00_MainContent_txtMobileNo').val('____-_______');
            $('#ctl00_MainContent_txtCallToDoctor').val('');
        }

        function SaveHistoryTab() {

            var SymtomsList = [];

            $.each($('#tblSymtoms tbody tr'), function (key, value) {
                var dayYearMonthText = $($(value).find('td')[4]).text();
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                var dayYearMonthID = $('#ddlDaysMonthsYears').find('option:contains(' + dayYearMonthText + ')')[0].value;

                SymtomsList.push({ 'SymtomID': $($(value).find('td')[1]).text(), 'Duration': $($(value).find('td')[3]).text(), 'DayYearMonth': dayYearMonthID, 'Remarks': $($(value).find('td')[5]).text() });
            });

            var SymtomsList = {
                Emergency_Patient_ID: ($('#ctl00_MainContent_txtIn_Patient_ID').val() != "(New)") ? $('#ctl00_MainContent_txtIn_Patient_ID').val() : "0",
                SymtomsList: SymtomsList
            }
            PageMethods.SaveSymtoms(JSON.stringify(SymtomsList), function (response) {
                SaveOrtho();

            });

        }

        function LoadInstruction() {

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {

                PageMethods.GetInstruction($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Instruction = JSON.parse(res);
                    var rows = '';
                    $.each(Instruction, function (key, value) {
                        var timeStamp = parseInt(value.Instruction_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.DoctorStatus == null)
                            value.DoctorStatus = "";
                        if (value.Doctor_Instruction != " ,") {
                            rows += '<tr> <td> ' + date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Doctor_Status + '">  ' + value.DoctorName
                                + ',' + value.DoctorStatus
                                + '<input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> </td>  <td>' + value.Doctor_Instruction + '</td><td><input type="checkbox" name="chekInstruction"  ' + (value.IsLatest ? 'checked' : '') + '/></td> </tr>';
                        }


                    });
                    $('#tblInstruction tbody').html(rows);
                });
            }
        }

        function deleteInstruction(crow) {

            var row = $(crow).parents('tr')[0];

            var DoctorNotesID = $($(row).find('td')[4]).text();
            row.remove();
            var tblInstruction = document.getElementById("tblInstructionbody")
            var ttl;
            var rows;

            for (var i = 0; row = tblInstruction.rows[i]; i++) {
                rows = tblInstruction.rows[i];

                for (var j = 0; col = rows.cells[j]; j++) {

                    var value = col.firstChild.nodeValue;
                    if (DoctorNotesID == value) {
                        rows.remove();
                        return false;
                    }
                }
            }
            row.romove();

        }
        function deleteTest(crow) {
            var row = $(crow).parents('tr')[0];

            row.remove();


        }
        function Delete_Symtom(row) {
            $($(row).parents('tr')[0]).remove();
        }
        function LoadTestsHistory(PatientID) {

            if (PatientID != '(New)') {
                PageMethods.GetTestListForHistory(PatientID, function (res) {

                    var test = JSON.parse(res);
                    var rows = '';

                    $.each(test, function (key, value) {

                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var Result = 'Pendding';
                        var Sample = 'No';
                        if (value.Is_Result == true) {
                            Result = "View Result";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == false) {
                            Result = "Waiting";
                            Sample = "Yes";
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                            }
                            else {

                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                                }

                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';

                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td><td>' + value.Status + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                        }
                        //tibit changes
                        $('#tblHistoryTests tbody').append(row);
                    });
                });
            }
        }
        function EditResultInPatient(anchor) {


            var row = $(anchor).parents('tr')[0];
            var CatagoryID = $($(row).find('td input[name=txtGroupCategory]')[0]).val();
            var txtRecievedID = $($(row).find('td input[name=txtRecievedID]')[0]).val();
            var TestDetailID = $($(row).find('td input[name=TestDetailID]')[0]).val();
            var LabTestID = $($(row).find('td input[name=LabTestID]')[0]).val();
            var valuetype = $($(row).find('td input[name=txtValueType]')[0]).val();
            var ID = "";
            var labTestID = "";
            if (CatagoryID != 0) {
                PageMethods.LoadAllTestResultCatagory(txtRecievedID, CatagoryID, function (data) {

                    var alldata = JSON.parse(data);
                    $.each(alldata, function (key, value) {
                        ID += value.Lab_Test_Detail_ID + ',';
                        labTestID = value.Lab_Test_ID
                    });

                    showImage(labTestID);
                    $('#IDtest').val(ID);
                    $('#type').val(valuetype);
                    $('#myResultModal').modal({
                        backdrop: 'static'
                    });
                }, function (error) { })
            }
            else {
                $('#IDtest').val(txtRecievedID);

                $('#type').val(valuetype);
                showImage(txtRecievedID);
                $('#myResultModal').modal({
                    backdrop: 'static'
                });
            }
        }
        function ShowReport() {
            var table_tds = $('.test-table tr:not(:first)').find('#valuetype[value=table]').closest('tr').find('td:nth-child(3)');
            var fixed_tds = $('.test-table tr:not(:first)').find('#valuetype[value=fixed]').closest('tr').find('td:nth-child(3)');
            var valueType = $('#type').val();
            var tids = $('#IDtest').val();
            tids = tids.replace(/,+$/g, '');
            if (valueType == "table") {

                window.open('ReportViewer.aspx?ReportName=TestResult&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }

            if (valueType == "fixed") {

                window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }
        }
        function showImage(testDetailID) {

            PageMethods.LoadimagesDetail(testDetailID, function (res) {

                if (res == null || res == "[]" || res == "undefined") {
                    $("#errorMsg").show();
                }
                else { $("#errorMsg").hide(); }
                var test = JSON.parse(res);
                var rows = '';
                var dvPreview = $("#dvPreview");
                dvPreview.html("");
                $.each(test, function (key, value) {


                    var img = $("<img onclick='window.open(this.src)'/>");
                    img.attr("style", "height:60px;width: 60px");


                    var dd = "LabTestImg\\" + value.Image_path;
                    img.attr("src", dd);
                    dvPreview.append(img);

                    if (value.Image_path == null || value.Image_path == "" || value.Image_path == "undefined") {
                        $("#errorMsg").show();
                    }
                    else { $("#errorMsg").hide(); }

                });

            });
        }

        function LoadTestList() {

            var patientID = $('#<%= hdfPatient_ID.ClientID %>').val();

            if (patientID != "(New)") {
                PageMethods.GetTestList(patientID, function (res) {

                    var test = JSON.parse(res);

                    var rows = '';
                    $.each(test, function (key, value) {
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        var Result = 'Pendding';
                        var Sample = 'No';
                        if (value.Is_Result == true) {
                            Result = "View Result";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == true) {
                            Result = "View Result";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == null) {
                            value.Is_Result = ""
                        }
                        if (value.Recieved_ID == null) {
                            value.Recieved_ID = ""
                        }
                        if (value.IsBilled == null) {
                            value.IsBilled = ""
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        }
                        $('.tests-table').append(row);
                    });

                });
            }
        }

        function SaveDischargeMedicines() {
            var Dtable = $('#tblDischargeMedication');
            var MedicinesDList = [];
            Dtable.find('tbody tr').each(function (key, value) {

                MedicinesDList.push({ 'Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Recomended_Dosage': $($(value).find('td')[2]).text(), 'Frequency': $($(value).find('td')[3]).text(), 'Oral': $($(value).find('td')[4]).text(), 'Injection': $($(value).find('td')[5]).text(), 'Doctor_ID': $(value).find('td input[name=txtDoctor]').val(), 'chkDiccharge': $(value).find('td input[name=chkdischargevalue]')[0].checked });

            });

            var InPatID = $("#<%= txtPatient_ID.ClientID %>").val();
            var MedicineDetails = { PatientID: InPatID == '(New)' ? 0 : InPatID, MedicineDList: MedicinesDList }

            PageMethods.SaveDischargeMedicines(JSON.stringify(MedicineDetails), function (response) { SaveDoctoreNote(); });
        }

        function LoadOrtho() {
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadOrthoDetail($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        rows += '<tr>  <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Organ_Name + '"> ' + value.Organ_Name
                            + ' </td> <td> ' + value.Organ_Side + ' </td> <td> ' + value.Ortho_History + ' </td> <td>' + value.DM + '</td><td> ' + value.Ortho_History + ' </td> <td>' + value.IHD + '</td><td> ' + value.Look + ' </td> <td>' + value.Feel + '</td><td> ' + value.Move + ' </td> <td>' + value.Special_Tests + '</td><td> ' + value.Sensory + ' </td> <td>' + value.Motor + '</td> <td> ' + value.Reflexes + ' </td> <td>' + value.Vascular_Status + '</td> <td> ' + value.Others + ' </td></tr>';
                    });

                    $('#tblOrtho tbody').append(rows);
                });
            }
        }

        function SaveOrtho() {
            var table = $('#tblOrtho');
            var OrthoList = [];
            table.find('tbody tr').each(function (key, value) {

                OrthoList.push({ 'Organ_Name': $($(value).find('td')[0]).text(), 'Organ_Side': $($(value).find('td')[1]).text(), 'Ortho_History': $($(value).find('td')[2]).text(), 'DM': $($(value).find('td')[3]).text(), 'HTN': $($(value).find('td')[4]).text(), 'IHD': $($(value).find('td')[5]).text(), 'Look': $($(value).find('td')[6]).text(), 'Feel': $($(value).find('td')[7]).text(), 'Move': $($(value).find('td')[8]).text(), 'Special_Tests': $($(value).find('td')[9]).text(), 'Sensory': $($(value).find('td')[10]).text(), 'Motor': $($(value).find('td')[11]).text(), 'Reflexes': $($(value).find('td')[12]).text(), 'Vascular_Status': $($(value).find('td')[13]).text(), 'Others': $($(value).find('td')[14]).text() });

            });
            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var OrthoDetails = { Pat: PatID, PatientID: OutPatID, OrthoList: OrthoList }

            PageMethods.SaveOrthoDetail(btnsave, JSON.stringify(OrthoDetails), function (response) { SaveEmergencyServices(); });

        }
        debugger;
        function SaveEmergencyServices() {

            var table = $("#tblServices");
            var ProcedureList = [];
            var btnSave = $('#btnSave').val();
            table.find("tbody tr").each(function (key, value) {

                ProcedureList.push({
                    'ServiceDate': $($(value).find("td")[0]).text(),
                    'Service_ProcedureName': $($(value).find("td")[1]).text().trim(),
                    "ServiceItemId": $($(value).find("td")[1]).find("input[name=hdnItemID]").val(),
                    "ServiceItemAmount": $($(value).find("td")[1]).find("input[name=hdnNet_Amount]").val(),
                    "ServiceItemType": $($(value).find("td")[1]).find("input[name=hdnItemType]").val(),
                    "PatientType": $($(value).find("td")[1]).find("input[name=hdnPageType]").val(),
                    "UserName": $($(value).find("td")[2]).text()
                });
            });

            var patID = $('#<%= txtPatient_ID.ClientID%>').val();

            var emergencyID = $('#<%= txtIn_Patient_ID .ClientID%>').val();

            var ServiceDetails = { PatId: patID, EmergencyId: emergencyID, ServicesList: ProcedureList };

            PageMethods.SaveServicesDetail(btnSave, JSON.stringify(ServiceDetails), function (response) { saveAllRecord(); });

        }

        function LoadEmergencyServices(PatientId) {

            if ($("#<%= txtIn_Patient_ID.ClientID%>").val() !== "(New)") {
                $('#ServicesHistoryHeader').html('<h2 style="text-align: Center; color: White!important">Loading Previous History Please Wait...</h2>');
                PageMethods.LoadServicesDetail(PatientId, $('#<%= txtIn_Patient_ID.ClientID%>').val(), function (response) {


                    var Services = JSON.parse(response);
                    var rows = "";
                    var rowsHistory = "";

                    $.each(Services, function (key, value) {

                        var timeStamp = parseInt(value.ServiceDate.substr(6, 10));

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");

                        var entryDate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td><td style="text-align: left;"> <a href="#" onclick="DeleteRow(this)">Delete</a> </td> </tr>';

                        rowsHistory += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td></tr>';

                    });

                    $('#tblServices tbody').append(rows);
                    $('#tblServicesHistory tbody').append(rowsHistory);
                    $("#ServicesHistoryHeader").html("<h2 style='text-align:Center;color:White !important'>Previous History</h2>");

                });

            }
        }

        function SaveMedicines() {

            var table = $('#tblMedicinesList');
            var table2 = $('#tblMedicinesListNursing');
            var MedicinesList = [];
            var MedicinesList2 = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>';
                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
                });

            });
            table2.find('tbody tr').each(function (key, value) {

                var date = '<%= DateTime.Now%>';
                MedicinesList2.push({ 'Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Recomended_Dosage': $($(value).find('td')[2]).text(), 'Frequency': $($(value).find('td')[3]).text(), 'Oral': $($(value).find('td')[4]).text(), 'Injection': $($(value).find('td')[5]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[6]).text(), 'Nurse_Name': $(value).find('td input[name=txtNurseName]').val(), 'Remarks': $(value).find('td input[name=txtremarks]').val() });


            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }

            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { SaveMedicinesMonitoring(); });

        }

        function LoadMedicinesMonitoring() {
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicinesMonitoring($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td style="display:none"> ' + value.Injections + ' </td><td> <input type="text"  id="txtNurseName" disabled name="txtNurseName" style="width:100px !important;" value="' + value.Nurse_Name + '"/></td><td><input type="text"  id="txtremarks" name="txtremarks"  value="' + value.Remarks + '" style="width: 115px!important;"/></td><td style="display:none;"> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblMedicinesListNursing tbody').html(rows);

                });
            }
        }
        function SaveMedicinesMonitoring() {


            var table2 = $('#tblMedicinesListNursing');

            var MedicineList = [];

            table2.find('tbody tr').each(function (key, value) {

                var date = '<%= DateTime.Now%>';
                MedicineList.push({ 'Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Recomended_Dosage': $($(value).find('td')[2]).text(), 'Frequency': $($(value).find('td')[3]).text(), 'Oral': $($(value).find('td')[4]).text(), 'Injection': $($(value).find('td')[5]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[6]).text(), 'Nurse_Name': $(value).find('td input[name=txtNurseName]').val(), 'Remarks': $(value).find('td input[name=txtremarks]').val() });


            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicineList }

            PageMethods.SaveMedicinesMonitoring(JSON.stringify(MedicineDetails), function (response) { SaveDischargeMedicines(); });

        }
        function SaveDischargeMedicines() {

            var Dtable = $('#tblDischargeMedication');
            var MedicinesList = [];
            Dtable.find('tbody tr').each(function (key, value) {


                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
                });
            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }

            PageMethods.SaveDischargeMedicines(JSON.stringify(MedicineDetails), function (response) { saveTests(); });
        }

        function DischargeSummary() {
            var emergency_id = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            window.open('ReportViewer.aspx?ReportName=DischargeSmmary&ReportTitle=Discharge Smmary Print&Emergency_ID=' + emergency_id);

        }

        function saveTests() {
            debugger;
            var table = $('.tests-table tbody');
            var test_list = [];
            table.find('tr').each(function (key, value) {
                test_list.push({ 'Date': $(value).find('td input[name=testDate]').val(), 'TestID': $(value).find('td input[name=testID]').val(), 'Catagory_ID': $(value).find('td input[name=txtGroupCategory]').val(), 'Dept_ID': $(value).find('td input[name=txtDeptID]').val(), 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'Doctor': $(value).find('td input[name=Docid]').val(), 'Area_Of_Interest': $(value).find('td input[name=txtArea_Of_Interest]').val(), 'Special_Tests': $(value).find('td input[name=txtSpecial_Test]').val(), 'RecievedID': $(value).find('td input[name=txtRecievedID]').val(), 'Is_Result': $(value).find('td input[name=txtIs_Result]').val(), 'IsBIllied': $(value).find('td input[name=txtIsBIllied]').val() });
            });
            //var patientID = $('#<%= txtIn_Patient_ID.ClientID %>').val();
            var patientID = $("#<%= txtPatient_ID.ClientID %>").val();
            if (patientID == '(New)' || patientID == '')
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list };
            PageMethods.SaveTest(JSON.stringify(labTest), function (res) {
                SaveHistoryTab();
            });
        }

        function SaveLabResult() {
            var table = $('#tblResultrpt');
            var tblResultrpt = [];
            table.find('tbody tr').each(function (key, value) {
                tblResultrpt.push({ 'Result_ID': $(value).find('td input[name=txtLabResultrpt]').val(), 'Result_Name': $(value).find('td input[name=txtResultName]').val() });
            });

            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var EmergencyPatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (EmergencyPatientID == '(New)' || EmergencyPatientID == '')
                EmergencyPatientID = 0;
            var ResulttrptDetail = { Pat: PatID, EmergencyPatientID: EmergencyPatientID, Resulttrpt: tblResultrpt }

            PageMethods.SaveLabResultrpt(btnsave, JSON.stringify(ResulttrptDetail), function (response) { SaveInstructionDetail(); });

        }

        function SaveDoctoreNote() {

            var table = $('#tblDOctorNotes');
            var DoctorNoteList = [];
            table.find('tbody tr').each(function (key, value) {

                DoctorNoteList.push({ 'Doctor_Note_Date': $($(value).find('td')[0]).text(), 'Doctor_Status': $(value).find('td input[name=txtDoctorStatus]').val(), 'Doctor_ID': $(value).find('td input[name=txtDoctorValue]').val(), 'Progress_Note': $($(value).find('td ')[3]).text(), 'Instruction': $($(value).find('td')[4]).text() });

            });

            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var EmergencyPatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (EmergencyPatientID == '(New)' || EmergencyPatientID == '')
                EmergencyPatientID = 0;
            var NoteDetails = { Pat: PatID, EmergencyPatientID: EmergencyPatientID, NoteList: DoctorNoteList }

            PageMethods.InsertDoctorNoteDetail(btnsave, JSON.stringify(NoteDetails), function (response) { SaveLabResult() });

        }

        function SaveInstructionDetail() {

            var table = $('#tblInstruction');
            var InstructionList = [];
            table.find('tbody tr').each(function (key, value) {

                InstructionList.push({ 'Instruction_Date': $($(value).find('td')[0]).text(), 'Doctor_Status': $(value).find('td input[name=txtDoctorStatus]').val(), 'Doctor_ID': $(value).find('td input[name=txtDoctorValue]').val(), 'Doctor_Instruction': $($(value).find('td')[2]).text(), 'ChekInstruction': $(value).find('td input[name=chekInstruction]')[0].checked });

            });

            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var EmergencyPatientID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (EmergencyPatientID == '(New)' || EmergencyPatientID == '')
                EmergencyPatientID = 0;
            var IntructionDetails = { Pat: PatID, EmergencyPatientID: EmergencyPatientID, ListIns: InstructionList }

            PageMethods.InsertInstuctionDetail(btnsave, JSON.stringify(IntructionDetails), function (response) {
                SaveEyeList();

            });

        }

        function SaveWard() {

            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            //var EmergencyID = $("#<%= txtPatient_ID.ClientID %>").val();

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;

            var EmergencyID = InPatID;

            var refer_To = $("#ctl00_MainContent_ddlReferTo").val();
            if (refer_To != "0") {
                var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();

                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var txtBed_No = $('#ctl00_MainContent_txtBed_No').val();

                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
                if (DichargChk == "undefined") {
                    DichargChk = false;
                }

                PageMethods.SaveWardInformation(btnsave, PatID, EmergencyID, ddlWard_No, txtBed_No, ddlDoctor, DichargChk, function (response) {

                });
            }
            else {

                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();
                var txtBed_No = $('#ctl00_MainContent_txtBed_No').val();
                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

                PageMethods.SaveWardInformation(btnsave, PatID, EmergencyID, ddlWard_No, txtBed_No, ddlDoctor, DichargChk, function (response) {
                    SaveMedicines();
                });

            }

        }

        function SaveRoom() {

            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;
            var refer_To = $("#ctl00_MainContent_ddlReferTo").val();
            if (refer_To != "0") {
                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var ddlRoom_No = $('#ctl00_MainContent_ddlroom').val();
                var txtRoom_Type = $('#ctl00_MainContent_ddlRoomType').val();
                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();

                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
                PageMethods.SaveRoomInformation(btnsave, PatID, InPatID, ddlRoom_No, txtRoom_Type, txtExpected_Discharge_Date, ddlDoctor, DichargChk, function (response) {
                    SaveMedicines();
                });
            }
            else {
                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var ddlRoom_No = $('#ctl00_MainContent_ddlRoom_No').val();
                var txtRoom_Type = $('#ctl00_MainContent_txtRoom_Type').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
                PageMethods.SaveRoomInformation(btnsave, PatID, InPatID, ddlRoom_No, txtRoom_Type, txtExpected_Discharge_Date, ddlDoctor, DichargChk, function (response) {
                    SaveMedicines();
                });


            }
        }

        function CheckExistInOutPatient() {
            var patient_Id = $("#<%= hdfPatient_ID.ClientID %>").val();

            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/CheckExistOutPatient",
                data: JSON.stringify({ "Patient_ID": patient_Id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;

                    var data = response.d;  // e.g., "OPD", "IPD", or ""

                    if (data == "OPD") {
                        alert("First Discharge Patient from OPD");
                    }
                    else if (data == "IPD") {
                        alert("First Discharge from IPD");
                    }
                    else {
                        var Doctor = $('#ctl00_MainContent_ddlDoctor').val();
                        var Complain = $('#ctl00_MainContent_txtHealth_Complaints').val();

                        if (Complain == "") {
                            alert("Please Enter Health Complaint");
                            return false;
                        }

                        var ddlIssuance_Of = $('#ctl00_MainContent_ddlIssuance_Of').val();
                        var refer_to = $('#ctl00_MainContent_ddlReferTo').val();
                        var opd_pat = $('#ctl00_MainContent_ddlPatientCondition').val();
                        opd_pat = opd_pat ? opd_pat.trim() : "";

                        if (ddlIssuance_Of == "0") {
                            alert("Please First Create Admission");
                            return false;
                        }

                        if (ddlIssuance_Of == "001") {
                            if (opd_pat == "006") {
                                console.log("Skipping SaveWard for opd_pat = 006");
                                saveAllRecord();
                            } else {
                                var bedNo = $('#ctl00_MainContent_txtBed_No').val();
                                bedNo = bedNo ? bedNo.trim() : "";

                                //if (bedNo == "") {
                                //    alert("Please Select Bed No");
                                //    return false;
                                //}
                                SaveWard();
                                SaveMedicines();
                            }
                        }
                        else if (ddlIssuance_Of == "002") {
                            var roomNo = $('#ctl00_MainContent_ddlRoom_No').val();
                            //if (roomNo == "0" || roomNo == "") {
                            //    alert("Please Select Room No");
                            //    return false;
                            //}
                            SaveRoom();
                            SaveMedicines();// Make sure this is called only when valid
                        }
                        else {
                            // Handle unexpected ddlIssuance_Of values
                            return false;
                        }

                        // Save to localStorage only if we passed validation
                        localStorage.SelectedTabID = $("#tabs").tabs("option", "active");
                        localStorage.DoctorID = $("#ctl00_MainContent_ddlMo_Doctor_Name").val();
                        localStorage.DesignationID = $("#ctl00_MainContent_ddlMO_Doctor_Status").val();
                    }
                },
                failure: function (response) {
                    alert("Failure");
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    alert("An error occurred while checking patient status.");
                }
            });
        }



        debugger;
        function PrintoutPatient() {
            debugger;
            var Emergency_ID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            var url = '../../ReportViewer.aspx?ReportName=Emergencypatient&Title=Emergency Patient Report&Emergency_ID=' + Emergency_ID;
            window.open(url, '_blank');
        }
        function SaveInPatientAllRecord() {

            if (!ValidateDiscountFields()) {
                return false;
            }

            $('#loadingimage').show();
            $("#btnSave").attr("disabled", "disabled");
            CheckExistInOutPatient();



        }

        function ValidateDiscountFields() {
            var discount = $('#ctl00_MainContent_txtDiscount').val().trim();
            var remarks = $('#ctl00_MainContent_txt_remarks').val().trim();
            var fileUpload = $('#ctl00_MainContent_file_upload')[0].files.length;

            if (discount !== "" && parseFloat(discount) > 0) {
                if (remarks === "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please enter Remarks because Discount is applied.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $('#ctl00_MainContent_txt_remarks').focus();
                    return false;
                }
                if (fileUpload === 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please attach a file because Discount is applied.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return false;
                }
            }
            return true;
        }

        function LoadHistory() {

            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;;
            if (dischargechk == true) {
                $('#btnDischargePrint').attr('disabled', false);
            }
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != undefined) {
                debugger;
                LoadPsychiatryHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPsychiatryHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadVitalParametersHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadVitalParametersHistoryDicharge($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicationHistoryNursing($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadTestsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadHistoryTabHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadExaminationTabHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadSymtompsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadENTHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadEyeListHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDermaHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadRoomsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadWardHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDoctorNote();
                LoadDoctorNoteHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                tblDischargeNote($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadOrtho($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadEmergencyServices($("#<%= hdfPatient_ID.ClientID%>").val());
                LoadPeadsHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPeadsHistory($('#<%= hdfPatient_ID.ClientID%>').val());

            }
        }
        function LoadPeadsHistory(PatientID) {
            PageMethods.LoadPeadsHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var DelivryDate = ""
                    if (value.Peads_DateOfDelivery != null) {
                        DelivryDate = new Date(parseInt(value.Peads_DateOfDelivery.substr(6)));
                        DeliveryDate = moment(DelivryDate).format('DD/MM/YYYY');
                    }
                    else
                        DelivryDate = "";

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>OutPatient</td><td> ' + value.Peads_FullTerm + ' </td><td> ' + value.Peads_PreTerm + ' </td><td> ' + DelivryDate + ' </td><td> ' + value.Peads_TimeOfDelivery + ' </td><td> ' + value.Peads_Booked + ' </td><td> ' + value.Peads_UnBooked + ' </td><td> ' + value.Peads_DAIHandling + ' </td><td> ' + value.Peads_ANTURash + ' </td><td> ' + value.Peads_PIH + ' </td><td> ' + value.Peads_GDM + ' </td><td> ' + value.Peads_Vacinated + ' </td><td> ' + value.Peads_ANTOthers + ' </td><td> ' + value.Peads_SVD + ' </td><td> ' + value.Peads_LSCS + ' </td><td> ' + value.Peads_Emergency + ' </td><td> ' + value.Peads_Elective + ' </td><td> ' + value.Peads_PlaceOfDelivery + ' </td><td> ' + value.Peads_IndicationForLSCS + ' </td><td> ' + value.Peads_apgerScore1min + ' </td><td> ' + value.Peads_apgerScore5min + ' </td><td> ' + value.Peads_Resuscitation + ' </td><td> ' + value.Peads_NatalOthers + ' </td><td> ' + value.Peads_Moaning + ' </td><td> ' + value.Peads_RespDistress + ' </td><td> ' + value.Peads_PostNATALCyanosis + ' </td><td> ' + value.Peads_Fits + ' </td><td> ' + value.Peads_ReluctanceToFeed + ' </td><td> ' + value.Peads_PostNatalOthers + ' </td> <td> ' + value.Peads_weight + ' </td><td> ' + value.Peads_Length + ' </td><td> ' + value.Peads_HC + ' </td><td> ' + value.Peads_General_Appearance + '</td><td> ' + value.Peads_Cyanosis + ' </td><td> ' + value.Peads_Jaundice + ' </td><td> ' + value.Peads_Lethargy + ' </td><td> ' + value.Peads_Rash + ' </td><td> ' + value.Peads_Others + ' </td><td> ' + value.Peads_Caput + ' </td><td> ' + value.Peads_Cephalhematoma + ' </td><td> ' + value.Peads_Anterioropen + ' </td><td> ' + value.Peads_AnteriorClose + ' </td><td> ' + value.Peads_Dextrocardia + ' </td><td> ' + value.Peads_Bulging + ' </td><td> ' + value.Peads_Murmur + ' </td><td> ' + value.Peads_HeartSound + ' </td><td> ' + value.Peads_Nasal + ' </td><td> ' + value.Peads_Recessions + ' </td><td> ' + value.Peads_AddedSounds + ' </td><td> ' + value.Peads_Flat + ' </td><td> ' + value.Peads_Distended + ' </td><td> ' + value.Peads_Scaphoid + ' </td><td> ' + value.Peads_Liver + ' </td><td> ' + value.Peads_Spleen + ' </td><td> ' + value.Peads_GITOthers + ' </td><td> ' + value.Peads_Sucking + ' </td><td> ' + value.Peads_Rooting + ' </td><td> ' + value.Peads_Moro + ' </td><td> ' + value.Peads_CNSOthers + ' </td> </tr> ';

                    $('#tblPeadsHistory tbody').append(rows);
                });
                $('#tblPeadsHeader').html('<h2>Peads History</h2>')
            });
        }
        function LoadPeadsHistoryInpat(PatientID) {


            PageMethods.LoadPeadsHistoryInpat(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var DelivryDate = ""
                    if (value.Peads_DateOfDelivery != null) {
                        DelivryDate = new Date(parseInt(value.Peads_DateOfDelivery.substr(6)));
                        DeliveryDate = moment(DelivryDate).format('DD/MM/YYYY');
                    }
                    else
                        DelivryDate = "";
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>InPatient</td><td> ' + value.Peads_FullTerm + ' </td><td> ' + value.Peads_PreTerm + ' </td><td> ' + DelivryDate + ' </td><td> ' + value.Peads_TimeOfDelivery + ' </td><td> ' + value.Peads_Booked + ' </td><td> ' + value.Peads_UnBooked + ' </td><td> ' + value.Peads_DAIHandling + ' </td><td> ' + value.Peads_ANTURash + ' </td><td> ' + value.Peads_PIH + ' </td><td> ' + value.Peads_GDM + ' </td><td> ' + value.Peads_Vacinated + ' </td><td> ' + value.Peads_ANTOthers + ' </td><td> ' + value.Peads_SVD + ' </td><td> ' + value.Peads_LSCS + ' </td><td> ' + value.Peads_Emergency + ' </td><td> ' + value.Peads_Elective + ' </td><td> ' + value.Peads_PlaceOfDelivery + ' </td><td> ' + value.Peads_IndicationForLSCS + ' </td><td> ' + value.Peads_apgerScore1min + ' </td><td> ' + value.Peads_apgerScore5min + ' </td><td> ' + value.Peads_Resuscitation + ' </td><td> ' + value.Peads_NatalOthers + ' </td><td> ' + value.Peads_Moaning + ' </td><td> ' + value.Peads_RespDistress + ' </td><td> ' + value.Peads_PostNATALCyanosis + ' </td><td> ' + value.Peads_Fits + ' </td><td> ' + value.Peads_ReluctanceToFeed + ' </td><td> ' + value.Peads_PostNatalOthers + ' </td> <td> ' + value.Peads_weight + ' </td><td> ' + value.Peads_Length + ' </td><td> ' + value.Peads_HC + ' </td><td> ' + value.Peads_General_Appearance + '</td><td> ' + value.Peads_Cyanosis + ' </td><td> ' + value.Peads_Jaundice + ' </td><td> ' + value.Peads_Lethargy + ' </td><td> ' + value.Peads_Rash + ' </td><td> ' + value.Peads_Others + ' </td><td> ' + value.Peads_Caput + ' </td><td> ' + value.Peads_Cephalhematoma + ' </td><td> ' + value.Peads_Anterioropen + ' </td><td> ' + value.Peads_AnteriorClose + ' </td><td> ' + value.Peads_Dextrocardia + ' </td><td> ' + value.Peads_Bulging + ' </td><td> ' + value.Peads_Murmur + ' </td><td> ' + value.Peads_HeartSound + ' </td><td> ' + value.Peads_Nasal + ' </td><td> ' + value.Peads_Recessions + ' </td><td> ' + value.Peads_AddedSounds + ' </td><td> ' + value.Peads_Flat + ' </td><td> ' + value.Peads_Distended + ' </td><td> ' + value.Peads_Scaphoid + ' </td><td> ' + value.Peads_Liver + ' </td><td> ' + value.Peads_Spleen + ' </td><td> ' + value.Peads_GITOthers + ' </td><td> ' + value.Peads_Sucking + ' </td><td> ' + value.Peads_Rooting + ' </td><td> ' + value.Peads_Moro + ' </td><td> ' + value.Peads_CNSOthers + ' </td> </tr> ';

                    $('#tblPeadsHistory tbody').append(rows);
                });
                $('#tblPeadsHeader').html('<h2>Peads History</h2>')
            });
        }
        function LoadSymtomps() {
            var outPatID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            if (outPatID != '(New)') {
                if (outPatID != '') {
                    PageMethods.LoadSymtomps(outPatID, function (res) {
                        var Symtomps = JSON.parse(res);
                        var rows = '';
                        $.each(Symtomps, function (key, value) {
                            var rowID = uuid();
                            rows += '<tr> <td style="display:none;"> ' + rowID + ' </td> <td style="display:none;"> ' + value.Symtom_ID + ' </td> <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + ' </td> <td> ' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td> <td> <a href="#" onclick="Edit_Symtom(this)">Edit</a>|<a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

                        });
                        $('#tblSymtoms tbody').html(rows);
                    });
                }
            }
        }

        function LoadSymtompsHistory(PatID) {


            if (PatID != '(New)') {
                if (PatID != '') {

                    PageMethods.LoadSymtompsHistory(PatID, function (res) {
                        var Symtomps = JSON.parse(res);
                        var rows = '';
                        $.each(Symtomps, function (key, value) {


                            var rowID = uuid();
                            rows += '<tr> <td style="display:none;"> ' + value.Symtom_ID + ' </td><td>' + value.Status + '</td> <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + ' </td> <td> ' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td></tr>';

                            if (value.Symtom_ID.length > 0)
                                $('#dvSyptomHistory').show();
                            else
                                $('#dvSyptomHistory').hide();

                        });
                        $('#tblSymptomHistory tbody').html(rows);
                    });
                }
            }
        }
        function BackToList() {
            window.location = "EmergencyCaseView.aspx";
        }
        function LoadHistoryTabHistory(PatientID) {

            $('#tblHistoryTabHistoryHeader').html('<h2 class="heading" >Loading Previous History Please Wait...</h2>');
            if (PatientID != "(New)") {
                PageMethods.LoadHistoryTabHistory(PatientID, function (res) {

                    var Data = JSON.parse(res);
                    var rows = '';
                    $.each(Data, function (key, value) {
                        var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));

                        var retdate = moment(TrnsDate).format('LLLL');

                        if (value.Mucculor == null) {
                            value.Mucculor = "";

                        }
                        if (value.Local == null) {
                            value.Local = "";

                        }

                        rows += '<tr> <td> ' + retdate + ' </td><td>' + value.Status + '</td> <td> ' + value.HistoryOfPeresentIllness
                            + ' </td> <td> ' + value.HistoryOfPastIllness + ' </td> <td> ' + value.HistoryOfFamily + ' </td><td> ' + value.SocioEconomicHistory + ' </td> <td> ' + value.Birth_History + ' </td> <td> ' + value.Drug_History + ' </td> <td> ' + value.Personal_History + ' </td> <td> ' + value.ObstetricHistory + ' </td><td> ' + value.AllergiesHistory + ' </td><td> ' + value.TreatmentHistory + ' </td><td> ' + value.Vaccination_History + ' </td> <td> ' + value.Other_History + ' </td> </tr>';

                    });
                    $('#tblHistoryTabHistory tbody tr').remove();
                    $('#tblHistoryTabHistory tbody').html(rows);
                    $('#tblHistoryTabHistoryHeader').html('<h2 class="heading">Previous History</h2>');
                }, function (e) { });
            }
        }

        function LoadPsychiatryHistoryInpat(PatientID) {

            PageMethods.LoadPsychiatryHistoryInpat(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>InPatient</td> <td> ' + value.Psychiatry_Informant + ' </td> <td> ' + value.Psychiatry_Source_Referral
                        + ' </td> <td> ' + value.Psychiatry_Neck_Holding + ' </td> <td> ' + value.Psychiatry_Walking +
                        ' </td><td> ' + value.Psychiatry_Talking + ' </td> <td> ' + value.Psychiatry_Others +
                        ' </td> <td> ' + value.Psychiatry_Menarche + ' </td> <td> ' + value.Psychiatry_Menstrual +
                        ' </td> <td> ' + value.Psychiatry_Attachment_Separation + ' </td><td> ' + value.Psychiatry_Health +
                        ' </td><td> ' + value.Psychiatry_Nail_Biting + ' </td><td> ' + value.Psychiatry_Temper_Tantrums +
                        ' </td><td> ' + value.Psychiatry_Bed_Wetting + ' </td><td> ' + value.Psychiatry_Academics + ' </td>'

                        + ' </td> <td> ' + value.Psychiatry_Peer_Relationship + ' </td> <td> ' + value.Psychiatry_Behaviour +
                        ' </td><td> ' + value.Psychiatry_Occupational_History + ' </td> <td> ' + value.Psychiatry_Sexual_History +
                        ' </td> <td> ' + value.Psychiatry_Substance_Use + ' </td> <td> ' + value.Psychiatry_Forensic_Use +
                        ' </td> <td> ' + value.Psychiatry_Relationship + ' </td><td> ' + value.Psychiatry_Leisure_Activities +
                        ' </td><td> ' + value.Psychiatry_Attitude_Standards + ' </td><td> ' + value.Psychiatry_Prevalling_Mood +
                        ' </td><td> ' + value.Psychiatry_Reaction_Stress + ' </td><td> ' + value.Psychiatry_Religious_Practices +

                        ' </td><td> ' + value.Psychiatry_Father + ' </td> <td> ' + value.Psychiatry_Mother +
                        ' </td><td> ' + value.Psychiatry_Siblings + ' </td> <td> ' + value.Psychiatry_Familial_Illness +
                        ' </td> <td> ' + value.Psychiatry_Home_Atmosphere + ' </td> <td> ' + value.Psychiatry_Actual_age +
                        ' </td> <td> ' + value.Psychiatry_Race + ' </td><td> ' + value.Psychiatry_Tattoos_body_scars +
                        ' </td><td> ' + value.Psychiatry_Body_Habitus + ' </td><td> ' + value.Psychiatry_Dress +
                        ' </td><td> ' + value.Psychiatry_Hygiene + ' </td><td> ' + value.Psychiatry_Psychomotor_Activity +

                        ' </td><<td> ' + value.Psychiatry_Involuntary_movements + ' </td><td> ' + value.Psychiatry_Dystonia_EPS + ' </td><td> ' + value.Psychiatry_Tardive_dyskinesia + ' </td><td> ' + value.Psychiatry_Tics + ' </td><td> ' + value.Psychiatry_Tremors + ' </td><td> ' + value.Psychiatry_Attentiveness_interview + ' </td><td> ' + value.Psychiatry_Eye_Contact + ' </td><td> ' + value.Psychiatry_Level_Consciousness + ' </td><td> ' + value.Psychiatry_Rate + ' </td><td> ' + value.Psychiatry_Rhythm + ' </td><td> ' + value.Psychiatry_Volume + ' </td><td> ' + value.Psychiatry_Tone + ' </td><td> ' + value.Psychiatry_Modulation + ' </td><td> ' + value.Psychiatry_Depressed + ' </td><td> ' + value.Psychiatry_Elated + ' </td><td> ' + value.Psychiatry_Irritable + ' </td><td> ' + value.Psychiatry_Labile + ' </td><td> ' + value.Psychiatry_Incongruent + ' </td><td> ' + value.Psychiatry_Blunting_Flattening_Apathy + ' </td><td> ' + value.Psychiatry_Thinking + ' </td><td> ' + value.Psychiatry_Plans + ' </td><td> ' + value.Psychiatry_Actions + ' </td><td> ' + value.Psychiatry_Preservative + ' </td><td> ' + value.Psychiatry_LoosAssociation + ' </td><td> ' + value.Psychiatry_Tangentiaility + ' </td><td> ' + value.Psychiatry_Circumstantiality + ' </td><td> ' + value.Psychiatry_Flight_Ideas + ' </td><td> ' + value.Psychiatry_Thought_Insertion + ' </td><td> ' + value.Psychiatry_Thought_Withdrawal + ' </td><td> ' + value.Psychiatry_Thought_Broadcasting + ' </td><td> ' + value.Psychiatry_Thought_Control + ' </td><td> ' + value.Psychiatry_Dellusion + ' </td><td> ' + value.Psychiatry_Overvalued_Ideas + ' </td><td> ' + value.Psychiatry_Depresonalization + ' </td><td> ' + value.Psychiatry_Derealization + ' </td><td> ' + value.Psychiatry_Obsession + ' </td><td> ' + value.Psychiatry_Phobies + ' </td><td> ' + value.Psychiatry_Homocidial_Ideas + ' </td><td> ' + value.Psychiatry_Illusion + ' </td><td> ' + value.Psychiatry_Hallucination + ' </td><td> ' + value.Psychiatry_Orientation_Time + ' </td><td> ' + value.Psychiatry_Place + ' </td><td> ' + value.Psychiatry_Person + ' </td><td> ' + value.Psychiatry_Attention_Concentration + ' </td><td> ' + value.Psychiatry_Days_Week + ' </td><td> ' + value.Psychiatry_Immediate_Memory + ' </td><td> ' + value.Psychiatry_Recent_Events + ' </td><td> ' + value.Psychiatry_Remote_Events + ' </td><td> ' + value.Psychiatry_Adress_Recall_Two + ' </td><td> ' + value.Psychiatry_Adress_Recall_Five + ' </td><td> ' + value.Psychiatry_General_knowledge + ' </td><td> ' + value.Psychiatry_Arthemetic_Calculation + ' </td> <td> ' + value.Psychiatry_Abstraction + ' </td><td>' + value.Psychiatry_Insight + ' </td> <td>' + value.Psychiatry_HBM_Problem + ' </td> <td>' + value.Psychiatry_HBM_Caused + ' </td> <td>' + value.Psychiatry_HBM_Started + ' </td> <td>' + value.Psychiatry_HBM_Course + ' </td> <td>' + value.Psychiatry_HBM_Treatment + ' </td><td>' + value.Psychiatry_HBM_Effects + ' </td><td>' + value.Psychiatry_PE_Pluse + ' </td><td>' + value.Psychiatry_PE_BP + ' </td> <td>' + value.Psychiatry_PE_Temperature + ' </td><td>' + value.Psychiatry_PE_Weight + ' </td><td>' + value.Psychiatry_PE_RespiratoryRate + ' </td><td>' + value.Psychiatry_PE_Jaundice + ' </td> <td>' + value.Psychiatry_PE_Anemia + ' </td> <td>' + value.Psychiatry_PE_Cyanosis + ' </td><td>' + value.Psychiatry_PE_Clubbing + ' </td><td>' + value.Psychiatry_PE_JVP + ' </td><td>' + value.Psychiatry_PE_LymphNodes + ' </td><td>' + value.Psychiatry_PE_Edema + ' </td><td>' + value.Psychiatry_PE_Respiratory + ' </td><td>' + value.Psychiatry_PE_Cardiovascular + ' </td> <td>' + value.Psychiatry_PE_Gastro_Intestinal + ' </td><td>' + value.Psychiatry_PE_Observation + ' </td> <td>' + value.Psychiatry_PE_Cranial_Nerves + ' </td> <td>' + value.Psychiatry_PE_Limb_Strength + ' </td> <td>' + value.Psychiatry_PE_Spasticity + ' </td> <td>' + value.Psychiatry_PE_Position + ' </td>  <td>' + value.Psychiatry_PE_Vibration + ' </td> <td>' + value.Psychiatry_PE_Stereognosis + ' </td> <td>' + value.Psychiatry_PE_Pain + ' </td> <td>' + value.Psychiatry_PE_Biceps + ' </td> <td>' + value.Psychiatry_PE_Triceps + ' </td> <td>' + value.Psychiatry_PE_Brachioradialis + ' </td> <td>' + value.Psychiatry_PE_Quadriceps + ' </td> <td>' + value.Psychiatry_PE_Patellar + ' </td> <td>' + value.Psychiatry_PE_Achilles + ' </td><td>' + value.Psychiatry_PE_Extensor + ' </td> <td>' + value.Psychiatry_PE_Frontal + ' </td><td>' + value.Psychiatry_PE_Finger + ' </td> <td>' + value.Psychiatry_PE_Heel + ' </td> <td>' + value.Psychiatry_PE_Movements + ' </td> <td>' + value.Psychiatry_PE_Gait + ' </td> <td>' + value.Psychiatry_PE_Neck_Rigidity + ' </td>  <td>' + value.Psychiatry_PE_Kerning_Sign + ' </td> <td>' + value.Psychiatry_PE_Brudzinki_Sign + ' </td> <td>' + value.Psychiatry_For_Summary + ' </td> <td>' + value.Psychiatry_For_Diagnosis + ' </td> <td>' + value.Psychiatry_For_AxisI + ' </td> <td>' + value.Psychiatry_For_AxisII + ' </td> <td>' + value.Psychiatry_For_AxisIII + ' </td> <td>' + value.Psychiatry_For_AxisIV + ' </td> <td>' + value.Psychiatry_For_AxisV + ' </td> <td>' + value.Psychiatry_For_PredisposingFactors + ' </td> <td>' + value.Psychiatry_For_PrecipitatingFactors + ' </td> <td>' + value.Psychiatry_For_PrepetuatingFactors + ' </td>  <td>' + value.Psychiatry_For_Investigation + ' </td> <td>' + value.Psychiatry_For_Medical + ' </td> <td>' + value.Psychiatry_For_Psychological + ' </td> <td>' + value.Psychiatry_Major_Issues + ' </td> <td>' + value.Psychiatry_For_Strengths + ' </td><td>' + value.Psychiatry_For_Goals + ' </td> <td>' + value.Psychiatry_For_Strategies + ' </td> </tr> ';
                    $('#tblPsychiatryHistory tbody').append(rows);

                });

            });
        }
        function LoadPsychiatryHistory(PatientID) {
            PageMethods.LoadPsychiatryHistory(PatientID, function (res) {

                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>OutPatient</td> <td> ' + value.Psychiatry_Informant + ' </td> <td> ' + value.Psychiatry_Source_Referral
                        + ' </td> <td> ' + value.Psychiatry_Neck_Holding + ' </td> <td> ' + value.Psychiatry_Walking +
                        ' </td><td> ' + value.Psychiatry_Talking + ' </td> <td> ' + value.Psychiatry_Others +
                        ' </td> <td> ' + value.Psychiatry_Menarche + ' </td> <td> ' + value.Psychiatry_Menstrual +
                        ' </td> <td> ' + value.Psychiatry_Attachment_Separation + ' </td><td> ' + value.Psychiatry_Health +
                        ' </td><td> ' + value.Psychiatry_Nail_Biting + ' </td><td> ' + value.Psychiatry_Temper_Tantrums +
                        ' </td><td> ' + value.Psychiatry_Bed_Wetting + ' </td><td> ' + value.Psychiatry_Academics + ' </td>'

                        + ' </td> <td> ' + value.Psychiatry_Peer_Relationship + ' </td> <td> ' + value.Psychiatry_Behaviour +
                        ' </td><td> ' + value.Psychiatry_Occupational_History + ' </td> <td> ' + value.Psychiatry_Sexual_History +
                        ' </td> <td> ' + value.Psychiatry_Substance_Use + ' </td> <td> ' + value.Psychiatry_Forensic_Use +
                        ' </td> <td> ' + value.Psychiatry_Relationship + ' </td><td> ' + value.Psychiatry_Leisure_Activities +
                        ' </td><td> ' + value.Psychiatry_Attitude_Standards + ' </td><td> ' + value.Psychiatry_Prevalling_Mood +
                        ' </td><td> ' + value.Psychiatry_Reaction_Stress + ' </td><td> ' + value.Psychiatry_Religious_Practices +

                        ' </td><td> ' + value.Psychiatry_Father + ' </td> <td> ' + value.Psychiatry_Mother +
                        ' </td><td> ' + value.Psychiatry_Siblings + ' </td> <td> ' + value.Psychiatry_Familial_Illness +
                        ' </td> <td> ' + value.Psychiatry_Home_Atmosphere + ' </td> <td> ' + value.Psychiatry_Actual_age +
                        ' </td> <td> ' + value.Psychiatry_Race + ' </td><td> ' + value.Psychiatry_Tattoos_body_scars +
                        ' </td><td> ' + value.Psychiatry_Body_Habitus + ' </td><td> ' + value.Psychiatry_Dress +
                        ' </td><td> ' + value.Psychiatry_Hygiene + ' </td><td> ' + value.Psychiatry_Psychomotor_Activity +

                        ' </td><<td> ' + value.Psychiatry_Involuntary_movements + ' </td><td> ' + value.Psychiatry_Dystonia_EPS + ' </td><td> ' + value.Psychiatry_Tardive_dyskinesia + ' </td><td> ' + value.Psychiatry_Tics + ' </td><td> ' + value.Psychiatry_Tremors + ' </td><td> ' + value.Psychiatry_Attentiveness_interview + ' </td><td> ' + value.Psychiatry_Eye_Contact + ' </td><td> ' + value.Psychiatry_Level_Consciousness + ' </td><td> ' + value.Psychiatry_Rate + ' </td><td> ' + value.Psychiatry_Rhythm + ' </td><td> ' + value.Psychiatry_Volume + ' </td><td> ' + value.Psychiatry_Tone + ' </td><td> ' + value.Psychiatry_Modulation + ' </td><td> ' + value.Psychiatry_Depressed + ' </td><td> ' + value.Psychiatry_Elated + ' </td><td> ' + value.Psychiatry_Irritable + ' </td><td> ' + value.Psychiatry_Labile + ' </td><td> ' + value.Psychiatry_Incongruent + ' </td><td> ' + value.Psychiatry_Blunting_Flattening_Apathy + ' </td><td> ' + value.Psychiatry_Thinking + ' </td><td> ' + value.Psychiatry_Plans + ' </td><td> ' + value.Psychiatry_Actions + ' </td><td> ' + value.Psychiatry_Preservative + ' </td><td> ' + value.Psychiatry_LoosAssociation + ' </td><td> ' + value.Psychiatry_Tangentiaility + ' </td><td> ' + value.Psychiatry_Circumstantiality + ' </td><td> ' + value.Psychiatry_Flight_Ideas + ' </td><td> ' + value.Psychiatry_Thought_Insertion + ' </td><td> ' + value.Psychiatry_Thought_Withdrawal + ' </td><td> ' + value.Psychiatry_Thought_Broadcasting + ' </td><td> ' + value.Psychiatry_Thought_Control + ' </td><td> ' + value.Psychiatry_Dellusion + ' </td><td> ' + value.Psychiatry_Overvalued_Ideas + ' </td><td> ' + value.Psychiatry_Depresonalization + ' </td><td> ' + value.Psychiatry_Derealization + ' </td><td> ' + value.Psychiatry_Obsession + ' </td><td> ' + value.Psychiatry_Phobies + ' </td><td> ' + value.Psychiatry_Homocidial_Ideas + ' </td><td> ' + value.Psychiatry_Illusion + ' </td><td> ' + value.Psychiatry_Hallucination + ' </td><td> ' + value.Psychiatry_Orientation_Time + ' </td><td> ' + value.Psychiatry_Place + ' </td><td> ' + value.Psychiatry_Person + ' </td><td> ' + value.Psychiatry_Attention_Concentration + ' </td><td> ' + value.Psychiatry_Days_Week + ' </td><td> ' + value.Psychiatry_Immediate_Memory + ' </td><td> ' + value.Psychiatry_Recent_Events + ' </td><td> ' + value.Psychiatry_Remote_Events + ' </td><td> ' + value.Psychiatry_Adress_Recall_Two + ' </td><td> ' + value.Psychiatry_Adress_Recall_Five + ' </td><td> ' + value.Psychiatry_General_knowledge + ' </td><td> ' + value.Psychiatry_Arthemetic_Calculation + ' </td> <td> ' + value.Psychiatry_Abstraction + ' </td><td>' + value.Psychiatry_Insight + ' </td>  <td>' + value.Psychiatry_HBM_Problem + ' </td> <td>' + value.Psychiatry_HBM_Caused + ' </td> <td>' + value.Psychiatry_HBM_Started + ' </td> <td>' + value.Psychiatry_HBM_Course + ' </td> <td>' + value.Psychiatry_HBM_Treatment + ' </td><td>' + value.Psychiatry_HBM_Effects + ' </td><td>' + value.Psychiatry_PE_Pluse + ' </td><td>' + value.Psychiatry_PE_BP + ' </td> <td>' + value.Psychiatry_PE_Temperature + ' </td><td>' + value.Psychiatry_PE_Weight + ' </td><td>' + value.Psychiatry_PE_RespiratoryRate + ' </td><td>' + value.Psychiatry_PE_Jaundice + ' </td> <td>' + value.Psychiatry_PE_Anemia + ' </td> <td>' + value.Psychiatry_PE_Cyanosis + ' </td><td>' + value.Psychiatry_PE_Clubbing + ' </td><td>' + value.Psychiatry_PE_JVP + ' </td><td>' + value.Psychiatry_PE_LymphNodes + ' </td><td>' + value.Psychiatry_PE_Edema + ' </td><td>' + value.Psychiatry_PE_Respiratory + ' </td><td>' + value.Psychiatry_PE_Cardiovascular + ' </td> <td>' + value.Psychiatry_PE_Gastro_Intestinal + ' </td><td>' + value.Psychiatry_PE_Observation + ' </td> <td>' + value.Psychiatry_PE_Cranial_Nerves + ' </td> <td>' + value.Psychiatry_PE_Limb_Strength + ' </td> <td>' + value.Psychiatry_PE_Spasticity + ' </td> <td>' + value.Psychiatry_PE_Position + ' </td>  <td>' + value.Psychiatry_PE_Vibration + ' </td> <td>' + value.Psychiatry_PE_Stereognosis + ' </td> <td>' + value.Psychiatry_PE_Pain + ' </td> <td>' + value.Psychiatry_PE_Biceps + ' </td> <td>' + value.Psychiatry_PE_Triceps + ' </td> <td>' + value.Psychiatry_PE_Brachioradialis + ' </td> <td>' + value.Psychiatry_PE_Quadriceps + ' </td> <td>' + value.Psychiatry_PE_Patellar + ' </td> <td>' + value.Psychiatry_PE_Achilles + ' </td><td>' + value.Psychiatry_PE_Extensor + ' </td> <td>' + value.Psychiatry_PE_Frontal + ' </td><td>' + value.Psychiatry_PE_Finger + ' </td> <td>' + value.Psychiatry_PE_Heel + ' </td> <td>' + value.Psychiatry_PE_Movements + ' </td> <td>' + value.Psychiatry_PE_Gait + ' </td> <td>' + value.Psychiatry_PE_Neck_Rigidity + ' </td>  <td>' + value.Psychiatry_PE_Kerning_Sign + ' </td> <td>' + value.Psychiatry_PE_Brudzinki_Sign + ' </td> <td>' + value.Psychiatry_For_Summary + ' </td> <td>' + value.Psychiatry_For_Diagnosis + ' </td> <td>' + value.Psychiatry_For_AxisI + ' </td> <td>' + value.Psychiatry_For_AxisII + ' </td> <td>' + value.Psychiatry_For_AxisIII + ' </td> <td>' + value.Psychiatry_For_AxisIV + ' </td> <td>' + value.Psychiatry_For_AxisV + ' </td> <td>' + value.Psychiatry_For_PredisposingFactors + ' </td> <td>' + value.Psychiatry_For_PrecipitatingFactors + ' </td> <td>' + value.Psychiatry_For_PrepetuatingFactors + ' </td>  <td>' + value.Psychiatry_For_Investigation + ' </td> <td>' + value.Psychiatry_For_Medical + ' </td> <td>' + value.Psychiatry_For_Psychological + ' </td> <td>' + value.Psychiatry_Major_Issues + ' </td> <td>' + value.Psychiatry_For_Strengths + ' </td><td>' + value.Psychiatry_For_Goals + ' </td> <td>' + value.Psychiatry_For_Strategies + ' </td> </tr> ';
                    $('#tblPsychiatryHistory tbody').append(rows);

                });

            });
        }
        function LoadDermaHistory(PatientID) {

            if (PatientID != "(New)") {
                PageMethods.LoadDermaHistory(PatientID, function (res) {
                    var Data = JSON.parse(res);
                    var rows = '';
                    $.each(Data, function (key, value) {
                        var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                        var retdate = moment(TrnsDate).format('LLLL');
                        rows += '<tr> <td> ' + retdate + '</td><td>' + value.Status + '</td> <td> ' + value.DermaFace + ' </td> <td> ' + value.DermaNeck
                            + ' </td> <td> ' + value.DermaTrunk + ' </td> <td> ' + value.DermaUpperLimb +
                            ' </td><td> ' + value.DermaLowerLimb + ' </td> <td> ' + value.DermaFlexures +
                            ' </td> <td> ' + value.DermaGenitalias + ' </td> <td> ' + value.DermaHair +
                            ' </td> <td> ' + value.DermaNail + ' </td><td> ' + value.DermaMucousMembrane +
                            ' </td><td> ' + value.DermaEyes + ' </td><td> ' + value.DermaEars +
                            ' </td><td> ' + value.DermaNose + ' </td><td> ' + value.DermaLips + ' </td></tr> ';

                    });
                    $('#tblDermaHistory tbody tr').remove();
                    $('#tblDermaHistory tbody').html(rows);
                    $('#tblDermaHistoryHeader').html('<h2>Derma History</h2>')
                }, function (e) { });
            }
        }

        function insertOrtho() {
            var rows;
            // var Date=<%=DateTime.Now%>
            rows += '<tr><td> <input type="hidden" name="txtddlOrthoType" value="' + $('#ctl00_MainContent_ddlOrthoType').val() + '" />' + $('#ctl00_MainContent_ddlOrthoType option:selected').text() + '</td> <td> ' + $('#ctl00_MainContent_ddlOrthoSide').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtHistory').val()
                + ' </td> <td> ' + $('#ctl00_MainContent_txtDM').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtHTN').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtIHD').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtLook').val() +
                ' </td> <td> ' + $('#ctl00_MainContent_txtFeel').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtMove').val() +
                ' </td> <td> ' + $('#ctl00_MainContent_txtSpecial_Tests').val() + ' </td><td> ' + $('#ctl00_MainContent_txtSensory').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtMotor').val() + ' </td><td> ' + $('#ctl00_MainContent_txtReflexes').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtVascularStatus').val() + ' </td><td> ' + $('#ctl00_MainContent_txtOthers').val() +
                '</td></tr> ';
            $('#tblOrtho tbody').append(rows);
            $('#ctl00_MainContent_ddlOrthoSide').val('0');
            $('#ctl00_MainContent_ddlOrthoType').val('0');
            $('#ctl00_MainContent_txtVascularStatus').val('');
            $('#ctl00_MainContent_txtHistory').val('');
            $('#ctl00_MainContent_txtDM').val('');
            $('#ctl00_MainContent_txtHTN').val('');
            $('#ctl00_MainContent_txtIHD').val('');
            $('#ctl00_MainContent_txtLook').val('');
            $('#ctl00_MainContent_txtFeel').val('');
            $('#ctl00_MainContent_txtMove').val('');
            $('#ctl00_MainContent_txtSpecial_Tests').val('');
            $('#ctl00_MainContent_txtSensory').val('');
            $('#ctl00_MainContent_txtMotor').val('');
            $('#ctl00_MainContent_txtReflexes').val('');
            $('#ctl00_MainContent_txtVascularStatus').val('');
            $('#ctl00_MainContent_txtOthers').val('');
        }

        function LoadENTHistory(PatientID) {

            if (PatientID != "(New)") {
                PageMethods.LoadENTHistory(PatientID, function (res) {
                    var Data = JSON.parse(res);
                    var rows = '';
                    $.each(Data, function (key, value) {
                        var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                        var retdate = moment(TrnsDate).format('LLLL');

                        rows += '<tr> <td> ' + retdate + '</td><td>' + value.Status + '</td> <td> ' + value.ENT_Throat_IDL + ' </td> <td> ' + value.ENT_Throat_Nose
                            + ' </td> <td> ' + value.ENT_Ear_Right + ' </td> <td> ' + value.Ent_Ear_Left +
                            ' </td><td> ' + value.ENT_Rinnes_Right_PosNeg + ' </td> <td> ' + value.ENT_Rinnes_Right_Neg +
                            ' </td> <td> ' + value.ENT_Rinnes_Right_FalseNeg + ' </td> <td> ' + value.ENT_Rinnes_Right_FNeg +
                            ' </td> <td> ' + value.ENT_Rinnes_Lft_PosNeg + ' </td><td> ' + value.ENT_Rinnes_Lft_Neg +
                            ' </td><td> ' + value.ENT_Rinnes_Lft_FalseNeg + ' </td><td> ' + value.ENT_Rinnes_Lft_FNeg +
                            ' </td><td> ' + value.ENT_Webber_Central + ' </td><td> ' + value.ENT_Webber_Lateralized +
                            ' </td><td> ' + value.ENT_Investigation_PTA + ' </td><td> ' + value.ENT_Investigation_Tympanometry + ' </td></tr> ';

                    });

                    $('#tblENTHistory tbody tr').remove();
                    $('#tblENTHistory tbody').html(rows);
                    $('#tblENTHistoryHeader').html('<h2>ENT History</h2>')
                }, function (e) { });
            }
        }

        function LoadDoctorNoteHistory(PatientID) {

            if (PatientID != "(New)") {

                PageMethods.LoadDoctorNoteForHistory(PatientID, function (res) {

                    var Rooms = JSON.parse(res);
                    var rows = '';
                    $.each(Rooms, function (key, value) {

                        var timeStamp = parseInt(value.Doctor_Note_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.DoctorStatus == null)
                            value.DoctorStatus = "";

                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.DoctorStatus + ' </td> <td> ' + value.DoctorName + ' </td><td> ' + value.Progress_Note + ' </td> <td> ' + value.Doctor_Instruction + ' </td> </tr>';

                    });
                    $('#tblDoctorNoteHistroy tbody tr').remove();
                    $('#tblDoctorNoteHistroy tbody').html(rows);

                });
            }
        }
        function Add_SymtomRow() {
            var checksymtomadded = false;
            $(".symtopclass").each(function () {
                var symtomid = $(this).val();
                if (symtomid == localStorage.SymtomID) {
                    checksymtomadded = true;
                }
            });

            if (checksymtomadded === false) {


                $("#btnAddHistory").removeClass("btn-info").addClass("btn-danger");

                var rowID = uuid();
                var html = '<tr> <td style="display:none;"> <input type="hidde" class="symtopclass" value="' + localStorage.SymtomID + '" />' + rowID + ' </td> <td style="display:none;"> ' + localStorage.SymtomID + ' </td> <td> ' + localStorage.SymtomName + ' </td> <td> ' + $('#txtDuration').val() + ' </td> <td> ' + $('#ddlDaysMonthsYears').find('option:selected').text() + ' </td> <td> ' + $('#txtRemarks').val() + ' </td> <td> <a href="#" onclick="Edit_Symtom(this)">Edit</a>|<a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

                $('#tblSymtoms tbody').append(html);
                $('#txtSymtom').tokenInput('clear');
                $('#txtDuration').val("");
                $('#ddlDaysMonthsYears').val("001");
                $('#txtRemarks').val("");
                $('#txtNewSymptom').hide();
                $('#btnaddsym').hide();
            } else { alert('Symptom already added'); }
        }

        function Edit_Symtom(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            $('#txtDuration').val($($(row).find('td')[3]).text());
            $('#ddlDaysMonthsYears').find('option:contains(' + $(row).find('td')[4].innerText + ')')[0].selected = true;
            $('#txtRemarks').val($($(row).find('td')[5]).text());
            localStorage.SymtomID = $($(row).find('td')[1]).text();
            localStorage.SymtomName = $($(row).find('td')[2]).text();
            localStorage.rowID = $($(row).find('td')[0]).text();
            LoadTokenInputForSymtoms();
        }
        function LoadTokenInputForSymtoms() {

            $('#txtSymtom').tokenInput('clear');

            var SymtomID = localStorage.SymtomID;

            if (SymtomID != '') {

                SymtomID = "";

                for (var i = 0; i < localStorage.SymtomID.length; i++) {
                    if (i == 0) {

                    }
                    else {
                        SymtomID += localStorage.SymtomID[i];
                    }
                }


                var tokenData = httpGet("../../json.aspx?Table=Symtoms&Mode=Edit&q=" + SymtomID);

                var parsedData = JSON.parse(tokenData);

                $('#txtSymtom').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
            }
        }
        function SymptomInsert() {


            var syptum = $('#txtNewSymptom').val();
            PageMethods.SyptumNew(syptum, On_Sypyum_Success);
        }
        function new_value() {

            $('#txtNewSymptom').show();
            $('#btnaddsym').show();
            var syptum = $('#txtNewSymptom').val();
            if (syptum != "") {
                $('#txtNewSymptom').hide();
                $('#btnaddsym').hide();
            }
        }
        function On_Sypyum_Success() {

            LoadTokenInputForSymtoms();
            $('#txtNewSymptom').hide();
            $('#btnaddsym').hide();
            $('#txtNewSymptom').val("");
            $('#txtSymtom').tokenInput('clear');
        }

        function AddServiceOrItem() {

            var User_Name = '<%= AppConfig.UserName %>';
            var Item_Id = $('#ctl00_MainContent_txtService').val();
            var entryDate = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt") %>';
            setTimeout(function () {

                if ($('#ctl00_MainContent_txtService').val() === "")
                    return false;

                var rows = '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + localStorage.SelectedItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /> <input type="hidden" name="hdnPageType" value="Emergency" />' + localStorage.SelectedItemName + '</td><td style="text-align:left;">' + User_Name + '</td> <td style="text-align: left;"><a href="javascript:void(0)" onclick="DeleteRow(this)">Delete</a> </td> </tr>';

                $('#tblServices tbody').append(rows);
                $('#ctl00_MainContent_txtService').tokenInput('clear');

            }, 300);


        }

        function DeleteRow(anchor) {
            var row = $(anchor).parents('tr')[0];
            row.remove();
        }

        function LoadWardHistory(PatientID) {

            if (PatientID != '(New)') {

                PageMethods.LoadWardForHistory(PatientID, function (res) {

                    var Wards = JSON.parse(res);
                    var rows = '';
                    var Discharge_On = '';
                    var TrnsDateRec = '';

                    $.each(Wards, function (key, value) {
                        var timeStampEx;

                        var timeStamp = parseInt(value.Admission_Date.substr(6, 10)) * 1000;
                        var date = moment(timeStamp).format('DD/MM/YYYY h:mm:ss A');

                        if (value.To_TimeDate != null) {
                            if (value.Discharge_On != null) {
                                timeStampEx = parseInt(value.Discharge_On.substr(6, 10));
                                timeStampEx = moment.unix(timeStampEx).format('DD/MM/YYYY h:mm:ss A');
                            }
                            else {
                                timeStampEx = '';
                            }
                        }


                        Discharge_On = null;
                        if (value.Discharge_On != null) {
                            TrnsDateRec = parseInt(value.Discharge_On.substr(6, 10));
                            Discharge_On = moment.unix(TrnsDateRec).format('DD/MM/YYYY h:mm:ss A');
                        }
                        var department = value.DepartmentName;
                        Discharge_On = null;
                        if (value.department == null) {
                            department = '';
                        }

                        if (value.To_TimeDate == null)
                            timeStampEx = "";

                        rows += '<tr> <td> ' + date + ' </td><td> ' + department + ' </td> <td> ' + value.DoctorName + ' </td><td> ' + value.Emergency_Pat_Condition + ' </td> <td> ' + Discharge_On  /*timeStampEx*/ + ' </td><td> ' + value.Ward_No + ' </td> <td> ' + value.Bed_No_Assigned + ' </td> </tr>';

                    }
                    );
                    $('#dvHistoward tbody tr').remove();
                    $('#dvHistoward tbody').append(rows);

                });
            }
        }

        function LoadRoomsHistory(PatientID) {

            if (PatientID != "(New)") {

                PageMethods.LoadRoomsForHistory(PatientID, function (res) {
                    var Rooms = JSON.parse(res);
                    var rows = '';

                    $.each(Rooms, function (key, value) {
                        var date = "";
                        var dateEx = "";
                        if (value.From_Date != null) {
                            date = parseInt(value.From_Date.substr(6, 10));
                            date = moment.unix(date).format('M/D/YYYY h:m:s A');
                        }

                        if (value.To_Date != null) {
                            dateEx = parseInt(value.To_Date.substr(6, 10));
                            dateEx = moment.unix(dateEx).format('M/D/YYYY h:m:s A');
                        }
                        if (value.RoomType == null)
                            value.RoomType = "";
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.DepartmentName + ' </td> <td> ' + value.DoctorName + ' </td><td> ' + value.Health_Complaints + ' </td> <td> ' + dateEx + ' </td><td> ' + value.RoomNo + ' </td> <td> ' + value.RoomType + ' </td> </tr>';
                    });

                    $('#tblRoomsHistory tbody').html(rows);
                });
            }
        }

        function FillDropDowns() {
            PageMethods.FillDays_Years_MonthsDropDown(function (data) {
                var options = '';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value=' + value.DataValue_Name + '> ' + value.DataValue_Description + '</option>';
                });
                $('#ddlDaysMonthsYears').html(options);
            }, function (error) { })
        }

        function checkOPDTrasfer() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkOPDTrasfer(patID, function (data) {
                ;

                if (data == "[]") {

                    $('#tblRoomsHistory').show();
                    $('#tblWardHistory').show();
                }
                else {
                    $.each(JSON.parse(data), function (key, value) {
                        rows += '<tr> <td> ' + value.pulse_Min + '</td> <td> ' + value.Temp_C + ' </td> <td> ' + value.BP_mm_Hg
                            + ' </td> <td> ' + value.Respiration_Min + ' </td> <td> ' + value.Height_Cm +
                            ' </td><td> ' + value.ma + ' </td> <td> ' + value.DermaFlexures +
                            ' </td> <td> ' + value.DermaGenitalias + ' </td> <td> ' + value.DermaHair +
                            ' </td> <td> ' + value.DermaNail + ' </td><td> ' + value.DermaMucousMembrane +
                            ' </td><td> ' + value.DermaEyes + ' </td><td> ' + value.DermaEars +
                            ' </td><td> ' + value.DermaNose + ' </td><td> ' + value.DermaLips + ' </td></tr> ';

                        $('@tblVitalParametersHistory').html(rows)
                    });
                }

            }, function (error) { })
        }
        function checkRepeat() {

            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeat(patID, function (data) {


                if (data == 0) {
                    loadAjax();
                    $("#tabs").tabs("option", "active", 0);
                    checkRooms();
                    LoadHistory();
                    $('#tblRoomsHistory').show();
                    $('#tblWardHistory').show();
                    $('#ui-id-15').hide();
                    $('#Tab-5').hide();
                }
                else {
                    checkRepeateRecord = true;
                    window.location = "EmergencyCase.aspx?ID=" + data;
                }

            }, function (error) { })
        }

        function checkRooms() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeatRooms(patID, function (data) {

                $.each(JSON.parse(data), function (key, value) {

                    window.location = "EmergencyCase.aspx?ID=" + value.In_Patient_ID;
                    $('#btnSave').val("Update");

                });

            }, function (error) { })
        }

        $(function () {
            var beforePrint = function () {
                alert('Functionality to run before printing.');
            };
            var afterPrint = function () {
                alert('Functionality to run after printing');
            };

            if (window.matchMedia) {
                var mediaQueryList = window.matchMedia('print');
                mediaQueryList.addListener(function (mql) {
                    if (mql.matches) {
                        beforePrint();
                    } else {
                        afterPrint();
                    }
                });
            }

            window.onbeforeprint = beforePrint;
            window.onafterprint = afterPrint;
        }());
        function FillMainTestDepartment() {

            var options = '<option value="0" >Select Main Department</option>';

            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainTestDepartment').html(options);

            });
        }
        function FillLabTests() {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function LoadCategory() {
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/Load_Category",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var doctor = JSON.parse(response.d);
                    var options = '<option value=""> Please Select </option>';

                    $.each(doctor, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });

                    $('#ctl00_MainContent_ddlCategory').html(options);
                    $('#ctl00_MainContent_ddlCategory').select2();



                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });

        }
        function LoadInvestigationDoctor() {
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/GetInvestigationDoctor",
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

                    $('#ddlInvestigationDoctor').html(options);
                    $('#ddlInvestigationDoctor').select2();



                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });

        }
        function AddBloodTest() {

            var test = $('#ddlTestList').find('option:selected').text();

            PageMethods.GetBBDDLDetails(test, function (res) {

                var doctorVal;
                var doctor;
                $.each(JSON.parse(res), function (key, value) {

                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    doctorVal = $('#ddlInvestigationDoctor').find('option:selected').val();
                    doctor = $('#ddlInvestigationDoctor').find('option:selected').text();

                    if (doctorVal == 0 || doctorVal == undefined) {
                        alert("Please Select Doctor")
                        return false;
                    }
                    if (value.Test_ID != 0) {

                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '"/></td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '"/></td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }
                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");

                });

            }, function (err) { });

        }



        function AddLabTest() {

            var test = $('#ddlTestList').find('option:selected').text();
            PageMethods.GetLabTestDDLDetails(test, function (res) {

                $.each(JSON.parse(res), function (key, value) {

                    var Result = 'Result';
                    var test = $('#ddlTestList').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var doctorVal;
                    var doctor;

                    doctorVal = $('#ddlInvestigationDoctor').find('option:selected').val();
                    doctor = $('#ddlInvestigationDoctor').find('option:selected').text();


                    if (doctorVal == 0 || doctorVal == undefined) {
                        alert("Please Select Doctor")
                        return false;
                    }

                    if (value.Test_ID != 0) {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIsBIllied"/> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td>  <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }
                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");

                });
            }, function (err) { });
        }

        function AddRadialogyTest() {

            $("#btnXray").removeClass("btn-danger").addClass("btn-info");
            $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
            $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
            var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
            var ddl_XRayLF_Name = $('#ddlXRayLF option:selected').text();
            var ddlXRayLF_Namevalue = ',' + ddl_XRayLF_Name;

            var Result = 'Result';
            var test = $('#ddlTestList').val();
            var date = '<%= DateTime.Now %>';
            var IsRotationShow = $('#divRotation').is(":visible");
            var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
            var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";

            $.ajax({
                type: "POST",

                url: "EmergencyCase.aspx/GetTestMainDepartmentDetails",
                data: JSON.stringify({ TestID: test }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {


                    var MainDeptName = JSON.parse(data.d);
                    TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                    MainDepartmentName = MainDeptName[0].estMainDepartmen;
                    if (MainDepartmentName != "003") {
                        ddlXRayLF_Namevalue = "";
                        ddl_XRayLF_Name = "";
                    }
                    var doctorVal;
                    var doctor;


                    doctorVal = $('#ddlInvestigationDoctor').find('option:selected').val();
                    doctor = $('#ddlInvestigationDoctor').find('option:selected').text();


                    if (doctorVal == 0 || doctorVal == undefined) {
                        alert("Please Select Doctor")
                        return false;
                    }
                    var areaOfIntrest = $('#ctl00_MainContent_txtAreaOfInterest').val();
                    var SpecialTest = "";
                    var row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '">' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Namevalue + '</td><td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtSpecial_Test" value="' + SpecialTest + '"/><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfIntrest + '"/> ' + areaOfIntrest + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");

                },
                failure: function (response) {
                    alert(response.d);
                }

            });

        }

        function AddProcedureTest() {
            var Result = 'Result';
            var Procedure = $('#ddlTestList').val();
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
            var dateValue = '<%= DateTime.Now%>';
            var doctorVal;
            var doctor;
            var chkPallor = document.getElementById("ctl00_MainContent_chkdoctor").checked;
            if (chkPallor == true) {
                doctorVal = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
                doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').find('option:selected').text();
            }
            else {
                doctorVal = $('#ddlInvestigationDoctor').find('option:selected').val();
                doctor = $('#ddlInvestigationDoctor').find('option:selected').text();
            }

            if (doctorVal == 0 || doctorVal == undefined) {
                alert("Please Select Doctor")
                return false;
            }

            var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td><td><input type="hidden" name="testID" value="' + Procedure + '" /> <input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"> ' + $('#ddlTestList').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value=""/> </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

            $('.tests-table').append(row);
            $("#ctl00_MainContent_txtAreaOfInterest").val("");

        }

        function AddAllTest() {

            var maindpt = $('#ddlMainTestDepartment').val();
            var CheckTest = $('#ddlTestList').val();

            if (CheckTest != 0 || CheckTest != null) {
                if (maindpt == "001") {
                    AddLabTest();

                }
                else if (maindpt == "002") {
                    AddRadialogyTest();

                }
                else if (maindpt == "003") {
                    AddRadialogyTest();

                }
                else if (maindpt == "004") {
                    AddRadialogyTest();

                }
                else if (maindpt == "005") {

                    AddBloodTest();


                    $('#divRotation').hide();
                }
                else if (maindpt == "006") {

                    FillProcedure("006");

                    $('#divRotation').hide();
                }
                else if (maindpt == "007") {

                    FillProcedure("007");
                    $('#ddlXRayLF').hide();
                    $('#divRotation').hide();
                }
            }
            else {

            }
        }

        function LoadTestByDepartment() {

            var maindpt = $('#ddlMainTestDepartment').val();
            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            if (maindpt == "001") {
                FillLabTests();
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();

            }
            else if (maindpt == "002") {
                FillTestsByCategory('002');
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "003") {
                FillTestsByCategory('003');
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "004") {
                FillTestsByCategory('004');
                $('#ddlXRayLF').hide();

            }
            else if (maindpt == "005") {

                FillProcedure("005");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "006") {

                FillProcedure("006");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "007") {

                FillProcedure("007");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
        }

        $(document).on('keyup', '.select2-search__field', function () {
          var searchString = $(this).val();
    
                if (searchString.length < 2) {
                    return;
                }

              $.ajax({
              url: 'EmergencyCase.aspx/getpharmacyitems',
            method: 'POST',
           contentType: 'application/json',
             data: JSON.stringify({ searchString: searchString }),
            success: function (response) {
            try {
                var pharmacyItems = JSON.parse(response.d);
                var $select = $('#txtPharmacyItem');
                
                $.each(pharmacyItems, function (key, value) {
                    var optionExists = $select.find('option[value="' + value.Item_ID + '"]').length > 0;
                    if (!optionExists) {
                        $select.append('<option value="' + value.Item_ID + '">' + value.Description + '</option>');
                    }
                });
                
                $select.trigger('change');
                
            } catch (error) {
                console.error('Error parsing response:', error);
            }
        },
        error: function (xhr, status, error) {
            console.error('Error fetching data:', error);
        }
    });
});

        function FillPharmacyItem() {
            PageMethods.FillPharmacyItemDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.Item_ID + '"> ' + value.Description + ' </option>';
                });

                $('#txtPharmacyItem').html(options);
                $('#txtPharmacyItem').select2();

                $('#txtPharmacyItem').select2({
                    width: '100%',
                    dropdownAutoWidth: false,
                    minimumResultsForSearch: 0,
                    dropdownParent: $('#MedicationModel'),
                    placeholder: 'Select Medicine',
                    allowClear: true
                });


            });
        }
        var checkRepeateRecord = false;
        function loadtokenInputsDefaultPRNo() {

            $('#txtMedicineName').tokenInput("../../json.aspx?Table=INV_ItemsForPharmacy",
                {

                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {

                            $("#txtMedicineName").val(item.name);
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
        }

        function event() { }

        function loadTokenInputsDefaultForServices() {

            $("#ctl00_MainContent_txtService").tokenInput("../../json.aspx?Table=INV_ItemsForBilling",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {

                        try {

                            localStorage.SelectedItemID = item.id;
                            localStorage.SelectedItemType = item.Type;
                            localStorage.SelectedItemName = item.name;
                            localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);

                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
        }


        function GetQS() {

            var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            if (url[0].includes('=')) {
                var QS = url[0].split('=')[1];
                $('#queryString').val(QS);

            }
        }
        var button_text_name = "";

        $(document).ready(function () {

            //$('#Add_Unlisted_Medicine').attr('disabled', true);

            $('#ctl00_MainContent_ctl00_MainContent_txtEOR').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd > 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_txtMR').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) && ((this.selectionEnd > 1) ||
                    ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_txtVR').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd > 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });



            $('#btnDischargePrint').attr('disabled', true);
            $("#txtMedicineName").hide();
            $("#lblMed").hide();
            $("#ctl00_MainContent_ddlMO_Doctor_Status").on('change', function () {
                var status = $(this).val();
                PageMethods.GetDoctorsAgainstMO(status, function (Medicine) {
                    var options = '<option value=""> Select Medicine  </option>'
                    $.each(JSON.parse(Medicine), function (key, value) {
                        options += '<option value="' + value.Emp_ID + '"> ' + value.Emp_Name + ' </option>';
                    });

                    $('#ctl00_MainContent_ddlMo_Doctor_Name').html(options);
                    $('#ctl00_MainContent_ddlMo_Doctor_Name').select2();



                });
            });
            $('input[type="button"]').click(function (e) {
                btnVal = e.target.id;
            });
            $("#tabs").click(function () {
                $("#btnSave").addClass("red");

            });

            if (document.getElementById('ctl00_MainContent_rdbPeads_LSCS').checked) {
                $('#TDPeadsEmergency').show();
                $('#TDPeadsElective').show();
            }
            else {
                $('#TDPeadsEmergency').hide();
                $('#TDPeadsElective').hide();
            }
            Combination();
            $('#ctl00_MainContent_ddlLabResult').select2();
            $('#txtSymtom').tokenInput("../../json.aspx?Table=Symtoms",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            localStorage.SymtomName = item.name;
                            localStorage.SymtomID = item.id;
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
            $("#ctl00_MainContent_txtPeads_DateOfDelivery").datepicker();
            FillMainTestDepartment();
            PendingAdmisionPatients();
            LoadMedicinesMonitoring();

            ChangePanel();

            FillPharmacyItem();
            var btnsave = $("#btnSave").val();

            var chk = '<%= Request.QueryString["ID"]%>';
            debugger;
            if (chk !== "") {



                chkIssuance_Of_Select();
                chkrefer_Of_Select();
                loadReferenceInformation();
                $('#loadingimage').hide();
                $("#ctl00_MainContent_ddlMo_Doctor_Name").val(localStorage.DoctorID);
                $("#ctl00_MainContent_ddlMO_Doctor_Status").val(localStorage.DesignationID);
            }

            if ($('#ctl00_MainContent_txtIn_Patient_ID').val() != '(New)') {

                LoadMedicines();
                LoadTestList();
                LoadHistory();
                LoadEyeList();
                LoadSymtomps();
                LoadLabResultrpt();

                LoadInstruction();

                LoadDischargeMedicines();
            }

            FillRotations();
            FillEyeSubTypeOnchangeOfEyeMainType();
            FillEyeMainTypesAndSubTypes();
            FillDropDowns();
            FillMedicine();
            FillRoutes();
            FillDosage();
            FillFrequency();
            FillDosageQty();
            FillOtherInstruction();
            if (chk != "") {

                if (localStorage.DoctorNoteTab == "true") {

                    $("#tabs").tabs("option", "active", 7);
                    localStorage.DoctorNoteTab = "False";
                }
                loadTokenInputsDefaultForServices();
            }

            var OPD_Patient = $('#<%=txtPatient_ID.ClientID%>').val();

            $('#<%= txtPatient_ID.ClientID%>').change(function () {



                checkRepeat();

            });
            <%if (Request.QueryString["ID"] != null)
        {%>

            $('#btnSave').val("Update");

            <%}%>
            FillWardBeds();

            $('#add-new-Othertest').click(function () {


                var Result = 'Result';
                var test = $('#ddlOtherTest').val();
                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';

                var doctorVal;
                var doctor;
                var chkPallor = document.getElementById("ctl00_MainContent_chkdoctor").checked;
                if (chkPallor == true) {
                    doctorVal = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
                    doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').find('option:selected').text();
                }
                else {
                    doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
                    doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();
                }
                if (doctorVal == 0 || doctorVal == undefined) {
                    alert("Please Select Doctor")
                    return false;
                }

                var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"><input type="hidden" name="txtDeptID" value="0"/> ' + $('#ddlOtherTest').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value=""/> </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';


                var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');
                if (test_array.length > 0) {
                    alert('This test already added!');
                } else {
                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");
                }
            });

            $('#btnAddMedicine').on("click", function (e) {

                var name = e.delegateTarget.attributes.id.value;
                button_text_name = name;
                localStorage.IsDischarge = 0;

                $("#btnSaveMedicine").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
                $('#txtMedicen').hide();
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');

                $('#txtMedicineName').focus();
                if (button_text_name == "btnAddMedicine") {

                    $('#spnFreq').hide();
                    $('#spndur').hide();
                }
                else {
                    $('#spnFreq').show();
                    $('#spndur').show();

                }
            });

            $('#btnSaveMedicine').on("click", function () {

                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");
                    $('#txtInjection').val("0");
                    $('#AttendingParamedicalStaff').val("0");

                }

                if ($('#txtPharmacyItem').val() == 'Select Medicine' || $('#txtPharmacyItem').val() == null) {
                    $('#txtPharmacyItem').val('');
                }

                if ($('#txtMedicen').val() != '' && $('#txtPharmacyItem').val() != '') {
                    alert("Please Eneter One Name");
                    return false;
                }
                if ($('#txtMedicen').val() == '' && $('#txtPharmacyItem').val() == '') {
                    alert("Please Enter Name");
                    return false;
                }
                var UnListedMed = $('#txtMedicen').val();

                if ($('#txtPharmacyItem').val() != '')
                    var pharmacyITem = $('#txtPharmacyItem').find('option:selected').text()
                else {
                    var pharmacyITem = $('#txtMedicen').val()
                }


                var Dose = $('#txtDosage').val();
                if (Dose == "") {
                    alert("Please Select Dose ");
                    return false;
                }
                if (button_text_name == "btnAddMedicine") {


                }
                else {
                    var Frequency = $('#txtRecomended_Dosage').val();
                    if (Frequency == "" || Frequency == "0" || Frequency == null) {
                        alert("Please Select Frequency ")
                        return false;
                    }
                }
                var DosageFrom = $('#ddlDosage_From').val();
                if (DosageFrom == 'Select') DosageFrom = '';

                var Route = $('#Routes').val();
                if (Route == "Select Routes") Route = '';
                if (Route == "" || Route == "0") {

                }
                if (button_text_name == "btnAddMedicine") {


                }
                else {
                    var Duration = $('#txtInjection').val();
                    if (Duration == "") {
                        alert("Please Select Duration ");
                        return false;
                    }
                }
                var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy h:m:s A")%>';
                var datetimeValue = '<%= DateTime.Now%>';
                var dosage_from = $('#ddlDosage_From').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_From').find('option:selected').text();
                var dosage_Qty = $('#ddlDosage_Qty').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_Qty').find('option:selected').text();
                var routes = $('#Routes').find('option:selected').text().trim() == 'Select Routes' ? '' : $('#Routes').find('option:selected').text();
                var other_Instruction = $('#ddlOther_Instruction').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlOther_Instruction').find('option:selected').text();
                var Freuqency = $('#txtRecomended_Dosage').find('option:selected').text().trim() == "Select Frequency" ? '' : $('#txtRecomended_Dosage').find('option:selected').text().trim();
                if ($(this).val() == 'Save') {

                    var medicine = ''
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    if (medicine == '') {

                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td> <td> ' + Freuqency + ' </td> <td> ' + routes + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                    }
                    else {

                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td> <input type="hidden" name="hdnItemCode" value="' + pharmacyItem + '"> ' + pharmacyITem + '</td> <td> ' + Freuqency + ' </td> <td> ' + '</td><td> ' + routes + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + itemCode + '</td></tr>';
                    }

                    if (localStorage.IsDischarge == 0) {
                        var table = $('#tblMedicinesList tbody');
                        table.append(row);
                    }
                    else if (localStorage.IsDischarge == 1) {
                        var table = $('#tblDischargeMedication tbody');
                        table.append(row);

                    }
                }
                else if ($(this).val() == 'Update') {

                    var tid = $('#MedicationModel input[name=uurowid]').val();
                    var row = '';
                    if (localStorage.IsDischarge == 0) {
                        row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                    }
                    else if (localStorage.IsDischarge == 1) {
                        row = $('#tblDischargeMedication tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                    }


                    $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                    $(row).find('td')[2].innerText = $('#txtRecomended_Dosage').find('option:selected').text().trim() == "Select Frequency" ? '' : $('#txtRecomended_Dosage').find('option:selected').text().trim();

                    $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text().trim() == "Select Routes" ? '' : $('#MedicationModel select[name=Routes]').find('option:selected').text().trim();
                    $(row).find('td')[4].innerText = $('#MedicationModel input[name=txtInjection]').val();
                    $(row).find('td')[5].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();
                    $(row).find('td')[7].innerText = $('#ddlDosage_Qty').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_Qty').find('option:selected').text().trim();
                    $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim() == "Select" ? '' : $('#ddlOther_Instruction').find('option:selected').text().trim();
                    var medicine_id = $(row).find('td')[10].innerText;
                    if (medicine_id == '') {
                        $(row).find('td')[1].innerText = $('#txtMedicen').val();
                    }

                    $(row).find('td')[10].innerText = $('#txtPharmacyItem').val();
                    '<a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
                }
                $('#txtMedicen').hide();
                $('#txtMedicen').val('');
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlOther_Instruction').val('');
                $('#txtPharmacyItem').val('0').trigger('change');
            });




            $('#btnSaveDischargeMedicine').on("click", function () {
                var datetime = '<%= DateTime.Now%>';
                if ($(this).val() == 'Save') {

                    var doctorVal;
                    var doctor;
                    var chkPallor = document.getElementById("ctl00_MainContent_chkMedDoctor").checked;
                    if (chkPallor == true) {
                        doctdoctorValor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
                        doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').find('option:selected').text();
                    }
                    else {
                        doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
                        doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();

                    }

                    var row = '<tr> <td> ' + datetime + ' </td><td> ' + $('#txtMedicineName').find('option:selected').text() + '</td> <td> ' + $('#txtDosage').val() + ' </td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#txtInjection').val() + '</td><td><input type="hidden" name="txtDoctor" value="' + doctorVal + '" />' + doctor + '</td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';

                    var table = $('#tblDischargeMedication tbody');
                    table.append(row);
                }
                else if ($(this).val() == 'Update') {

                    var tid = $('#MedicationModel input[name=uurowid]').val();

                    var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];

                    $(row).find('td')[1].innerText = $('#MedicationModel select[name=txtMedicineName]').find('option:selected').text();
                    $(row).find('td')[2].innerText = $('#MedicationModel input[name=txtDosage]').val();
                    $(row).find('td')[3].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                    $(row).find('td')[4].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                    $(row).find('td')[5].innerText = $('#MedicationModel input[name=txtInjection]').val();
                }
                $('#MedicationModel').modal('hide');
            });
        });


        function Combination() {
            TabFunction();
            bindControls();
            bindDate();

        }

        function bindDate() {
            $("#ctl00_MainContent_txtExpected_Discharge_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtNext_Visit").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtDischarge_On").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtMo_Time").datetimepicker({ datepicker: false, format: 'H:i:s' });
            $("#ctl00_MainContent_txtMo_Operation_Date").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtMo_Next_Visit").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtLMP").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtDateofDeath").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtTimeOfDeath").datetimepicker({ datepicker: false, format: 'H:i:s' });

        }

        function chkIssuance_Of_Select() {
            $('#tblWards tbody tr').remove();
            $('#tblRooms tbody tr').remove();

            var Issuance_Of = document.getElementById('<%= ddlIssuance_Of.ClientID%>').value;
            if (Issuance_Of == 0) {

                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;



                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;


                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";


            }
            else if (Issuance_Of == '001') {


                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = false;

                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroudWhite";
            }
            else {

                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;
                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;
                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";
            }
        }
        function chkrefer_Of_Select() {
            $('#tblBed tbody tr').remove();
            $('#tblRoom tbody tr').remove();


        }
        function PendingAdmisionPatients() {

            PageMethods.PendingAdmisionPatients(function (res) {

                var patients = JSON.parse(res);

                if (patients != "") {
                    var rows = '';
                    $.each(patients, function (key, value) {

                        rows = '<tr><td><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><a  href="javascript:void(0)" style="color:blue" onclick=selectPatient(' + value.Patient_ID + ')>' + value.Patient_No + '</a> </td><td>' + value.Department + '</td></tr>';


                    });

                }

            });
        }

        function selectPatient(Patient_ID) {

            $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
            var parsedData = JSON.parse(tokenData);
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });


            $('#<%= txtPatient_ID.ClientID%>').val(Patient_ID);
            $('#<%= hdfPatient_ID.ClientID%>').val(Patient_ID);
            checkRepeat();
            loadAjax();
            $('#btnSave').val("Save");
            $('#ctl00_MainContent_txtIn_Patient_ID').val("(New)");
            LoadHistory();
            checkpatient()
        }
        function checkpatient() {
            var pat_id = $('#<%= txtPatient_ID.ClientID%>').val();

            //kcd
        }
        function hideResults() {
            searchResults.classList.remove('active');
        }
        document.addEventListener('DOMContentLoaded', function () {
            const searchInput = document.getElementById('searchInput');
            const searchResults = document.getElementById('searchResults');

            let searchTimeout;
            let currentXHR = null;
            let highlightedIndex = -1;

            function hideResults() {
                searchResults.classList.remove('active');
            }

            searchInput.addEventListener('input', function (e) {
                const query = e.target.value.trim();
                clearTimeout(searchTimeout);

                if (currentXHR && currentXHR.readyState !== 4) {
                    currentXHR.abort();
                }

                searchTimeout = setTimeout(() => {
                    showLoading();
                    searchPatients(query);
                }, 300);
            });

            // Keyboard navigation
            searchInput.addEventListener('keydown', function (e) {
                const items = searchResults.querySelectorAll('.result-item');
                if (items.length === 0) return;

                if (e.key === 'ArrowDown') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex + 1) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'ArrowUp') {
                    e.preventDefault();
                    highlightedIndex = (highlightedIndex - 1 + items.length) % items.length;
                    updateHighlight(items);
                } else if (e.key === 'Enter') {
                    e.preventDefault();
                    if (highlightedIndex >= 0) {
                        items[highlightedIndex].click();
                    } else if (items.length > 0) {
                        items[0].click();
                    }
                    hideResults();
                }
            });

            function updateHighlight(items) {
                items.forEach(item => item.classList.remove('highlighted'));
                if (highlightedIndex >= 0) {
                    items[highlightedIndex].classList.add('highlighted');
                    items[highlightedIndex].scrollIntoView({ block: "nearest" });
                }
            }

            function searchPatients(searchValue) {
                currentXHR = $.ajax({
                    type: "POST",
                    url: "EmergencyCase.aspx/GetPatients",
                    data: JSON.stringify({ searchValue: searchValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        try {
                            const patients = JSON.parse(response.d);
                            if (patients.error) {
                                showError(patients.error);
                            } else {
                                highlightedIndex = -1;
                                showResults(patients, searchValue);
                            }
                        } catch (e) {
                            showError('Error parsing response: ' + e.message);
                        }
                    },
                    error: function (xhr, status, error) {
                        showError('Server error: ' + error);
                    }
                });
            }

            function showResults(patients, query) {
                if (!patients || patients.length === 0) {
                    searchResults.innerHTML = `
                <div class="no-results">
                    No patients found for "${query}"
                </div>`;
                } else {
                    searchResults.innerHTML = patients.map(patient => {
                        const displayText = `${patient.PatientNo}-${patient.FullName}`;
                        return `
                    <div class="result-item" 
                         onclick="selectPatient('${patient.RegID}'); document.getElementById('searchResults').classList.remove('active');">
                        <div>${highlightText(displayText, query)}</div>
                    </div>`;
                    }).join('');
                }
                searchResults.classList.add('active');
            }

            function showLoading() {
                searchResults.innerHTML = `
            <div class="no-results">
                <div style="display: flex; align-items: center; justify-content: center; gap: 10px;">
                    <div class="loading-spinner"></div>
                    Searching patients...
                </div>
            </div>`;
                searchResults.classList.add('active');
            }

            function showError(errorMessage) {
                searchResults.innerHTML = `
            <div class="no-results" style="color: #ff6b6b;">
                ?? Error: ${errorMessage}
            </div>`;
                searchResults.classList.add('active');
            }

            function highlightText(text, query) {
                if (!query) return text;
                const regex = new RegExp(`(${escapeRegExp(query)})`, 'gi');
                return text.replace(regex, '<strong style="background: rgba(102, 126, 234, 0.2); border-radius: 3px; padding: 0 2px;">$1</strong>');
            }

            function escapeRegExp(string) {
                return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
            }

            searchInput.addEventListener('focus', function () {
                if (this.value.trim().length >= 2) {
                    const query = this.value.trim();
                    showLoading();
                    searchPatients(query);
                }
            });

            // ? Hide results if click happens outside input or results
            document.addEventListener('click', function (e) {
                if (!searchInput.contains(e.target) && !searchResults.contains(e.target)) {
                    hideResults();
                }
            });
        });

        function ClearAll() {

            $('#tabs').find('input:text').each(function () {

                $('select option:nth-child(1)').attr('selected', 'selected');
                $(':text, textarea').val('');
                $('input:checkbox').removeAttr('checked');
                $('#tblSymtoms tbody tr').remove();
                $('#tblVitalParametersHistory tbody tr').remove();
                $('#tblHistoryTabHistory tbody tr').remove();
                $('#tblENTHistory tbody tr').remove();
                $('#tblSymptomHistory tbody tr').remove();
                $('#tblMedicinesList tbody tr').remove();
                $('#tblHistoryMedication tbody tr').remove();
                $('.tests-table tbody tr').remove();
                $('#tblHistoryTests tbody tr').remove();
                $('#tblControlHistory tbody tr').remove();
                $('#ctl00_MainContent_btnSave').val('Save');
                var today = new Date();
                var dd = today.getDate();
                var mm = today.getMonth() + 1;
                var yyyy = today.getFullYear();
                if (dd < 10) {
                    dd = '0' + dd
                }
                if (mm < 10) {
                    mm = '0' + mm
                }
                today = dd + '/' + mm + '/' + yyyy;

                var datetime = '<% = DateTime.Now.Date.ToString(AppConfig.DateFormat)%>';
                $('#ctl00_MainContent_txtAdmission_Date').val(datetime);
                $('#ctl00_MainContent_txtExpected_Discharge_Date').val(today);
                $('#ctl00_MainContent_txtReceiving_Date').val(today);
                $('#ctl00_MainContent_txttxtReceiving_DateDesc').val(today);

                $('#ctl00_MainContent_txtMo_Date').val(today);
                $('#ctl00_MainContent_txtDischarge_On').val(today);
            });
        }
        function FillRoomsRefer() {

            var RoomType = $('#ctl00_MainContent_ddlRoomType').val();
            PageMethods.FillRooms(RoomType, function (res) {

                var item = JSON.parse(res);
                if (item != "") {
                    var rows = '';
                    var result;
                    $.each(item, function (key, value) {

                        var rows;
                        if (value.PatientNmae == null)
                            value.PatientNmae = 0;
                        if (value.PatientNmae == 0) {
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/                             ><a href="#" onclick="SelectroomRefer(this)" style="color:green"> ' + value.Room_No + ' </a> </td></tr>';
                        }
                        else {
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/                              ><font color="red">' + value.Room_No + '</font></td></tr>';
                        }
                        $('#tblRoom').append(rows);
                    });
                }
                else {
                    $('#tblRoom tbody tr').remove();
                }
            });

        }

        function ChangePanel() {

            var type = $('#ctl00_MainContent_ddlPatientType').val();
            if (type == "10") {
                $('#ctl00_MainContent_lblPanelCompany').show();
                $('#ctl00_MainContent_ddlPanelCompany').show();
            }
            else {
                $('#ctl00_MainContent_lblPanelCompany').hide();
                $('#ctl00_MainContent_ddlPanelCompany').hide();
            }


        }

        function Selectroom(anchor) {
            var row = $(anchor).parents('tr')[0];
            var ID = $($(row).find('td input[name=ID]')[0]).val();
            var Type = $($(row).find('td input[name=Type]')[0]).val();
            $('#ctl00_MainContent_ddlRoom_No').val(ID);
        }
        function SelectroomRefer(anchor) {
            var row = $(anchor).parents('tr')[0];
            var ID = $($(row).find('td input[name=ID]')[0]).val();
            var Type = $($(row).find('td input[name=Type]')[0]).val();
            $('#ctl00_MainContent_ddlroom').val(ID);
        }


        function TabFunction() {
            $("#tabs").tabs();
            $("#PsychiatryTabs").tabs();
            $('#PeadsTabs').tabs();
            GetLastSelectedTab();
        };

        function GetLastSelectedTab() {

            $("#tabs").tabs("option", "active", localStorage.SelectedTabID);
        }
        function chkBedAvailability() {

        }
        function bindControls() {
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = $("#hdfPatient_ID").val();
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
                loadTokenInputsDefaultForServices();
            }
        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function NewWindow() {
            window.location = "EmergencyCase.aspx";
        }
        function Chk_Doctor_Info() {
            var Doctor_Val = document.getElementById('<%= ddlDepartment.ClientID%>').value;

            if (Doctor_Val == 0) {
                $('#ctl00_MainContent_ddlDoctor').val('');
            }
            else {
                var button = document.getElementById('<%= btnGet_Doctor.ClientID%>');
                button.click();
            }

        }

        function loadtokenInputsDefault() {

            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Emergency_Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#hdfPatient_ID").val(item.id);

                            loadAjax();
                            loadReferenceInformation();
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
        }

        function loadReferenceInformation() {
            //regid
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();

            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/loadReferenceInformation",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccessReference,
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        debugger;
        function OnSuccessReference(response) {
            debugger;
            var onsuccessreference = JSON.parse(response.d);
            if (onsuccessreference != null) {
                $('#txtdprevDepart').val(onsuccessreference.Reffer_To);

                var room_type = onsuccessreference.Room_Type;
                var ward_id = onsuccessreference.Ward_ID;
                var bed_no = onsuccessreference.Bed_No;
                var room_id = onsuccessreference.Room_ID;
                var room_no = onsuccessreference.Room_No;
                var Description = onsuccessreference.Description;
                if (Description.includes("Execute")) Description = "0";
                if (room_no.includes("Execute")) room_no = "0";
                var Ward_Complete = (Description == null ? "0" : Description) + '-' + (bed_no == null ? "0" : bed_no);
                var room_complete = (room_type == null ? "0" : room_type) + '-' + (room_no == null ? "0" : room_no);
                $('#txtWardBed').val(Ward_Complete);
                $('#txtRoomBed').val(room_complete);
            }
            else {

            }

        }

        function loadAjax() {

            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/GetDetail",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function FillDosage() {
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_From').html(options);
            });
        }
        function FillDosageQty() {
            PageMethods.FillDosageQty(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_Qty').html(options);
            });
        }
        function OnSuccess(data) {
            debugger;
            if (data.d != '') {

                if (data.d.PatientType == null)
                    data.d.PatientType = "";

                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vLbl_Patient_Type.ClientID %>').text(data.d.PatientType);
                $('#<%= vLbl_Patient_AdmitCatagory.ClientID %>').text(data.d.Type);
                var status = data.d.Admitted_Status
                if (status == "Admitted") {
                    $("#Tab-15").show()
                    $('#ui-id-11').hide();
                    $('#ui-id-10').hide();
                }
                else {
                    $("#Tab-15").hide()
                    $('#ui-id-11').hide();
                    $('#ui-id-10').hide();
                }
            }
        }
        function loadtokenInputs(data) {

            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=Emergency_Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {

                        $("#hdfPatient_ID").val(item.id);
                        loadAjax();
                    }
                });
        }
        
        function Cleardrpdwn() {
            if (skipClear) return;
            FillMedicine();
        }
        function CleardrpdwnItem() {

            FillPharmacyItem()
        }
        function NewMedicine() {
            debugger;
            $('#txtPharmacyItem').val(0).trigger('change');
            $('#txtMedicen').show();
            var medicine = $('#txtMedicen').val();
            if (medicine != "") {
                $('#txtMedicen').hide();
                $('#txtMedicen').val("");

            }
        }
        function MedicenInsert() {

            var medicine = $('#txtMedicen').val();
            PageMethods.GeMedicineNew(medicine, On_Success);
        }

        function On_Success() {
            FillMedicine();
        }

        $(".js-example-responsive").select2({
            width: 'resolve'
        });


        function OpenModal() {
            debugger;
            $('#PatientsSearchModel').modal({
                backdrop: 'static'
            });
            FillPatientsList();
            $('#srchpat').text("Search Your Patients:");
            $('#txtSearch').unmask();
            $('#txtSearch').val('');
            $('#ClosePatientsSearchModel').show();
        }

        function FillPatientsList() {
            debugger;
            $('#tblPatientsResult tbody').empty();
            var SearchString = '';
            PageMethods.AddPatient(SearchString, OnFilterPatients, OnFailPatients);
        }
        function OnFilterPatients(data) {

            ClearPatientResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Emergency_No, data[i].Full_Name, data[i].Father_Name, data[i].NIC, data[i].Mobile1, data[i].Admitted_Status, data[i].Emer_id);
            }
        }

        function ClearPatientResults() {
            while (tblPatientsResult.rows.length > 1) {
                tblPatientsResult.deleteRow(1);
            }
        }

        function OnFailPatients(exc) {
            alert(exc.get_message());
        }

        function AddPatientsResult(Reg_Patient_ID, Patient_No, Emergency_No, Full_Name, Father_Name, NIC, Mobile1, Admitted_Status, Emer_id) {
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
            cell.innerHTML = '<span class="HRcontent">' + Emergency_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Admitted_Status + '</span>';
            cell = row.insertCell(-1);
            var actions = ''
            actions += '<a style="color:#438eb9 ;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i></a>&nbsp;|&nbsp;&nbsp;';
            actions += '<a style="color:#FDC303;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-pencil-square-o"></i></a>';
            cell.innerHTML = actions;
        }

        function AddPatientDetail(Reg_Patient_ID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "EmergencyCase.aspx?Reg_ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }
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
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Complete Mobile Number First',
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
            $('#ClosePatientsSearchModel').click();
            //fillmrnos();
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
            var Mobile = $('#txt_mobile').val();
            var PreFix_DOB = $('#ddl_dob').val();

            if (PreFix_DOB == "Undefined") {
                PreFix_DOB = "";
            }
            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();
            var CNIC = $('#txt_cnic').val();
            var Address = $('#txt_Address').val();
            var martail_status = $('#ddl_status').val();
            if ((PatientName == "")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Patient Name',
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
            var data = JSON.stringify({
                "Full_Name": Full_Name,
                "RelationType": RelationType,
                "Relation": Relation,
                "Gender": Gender,
                "Mobile": Mobile,
                "Date_Of_Birth": Date_Of_Birth,
                "CNIC": CNIC,
                "Address": Address,
                "PatientID": PatientID,
                "martail_status": martail_status,
                "Age": Age,

            });
            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/SavePatientDetail",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var Reg_Patient_ID = data.d;
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Your Record Save and Load Successfully',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#PatientModel').modal('hide');
                    AddPatientDetail(Reg_Patient_ID)
                },
                error: function (response) {
                    alert("Error");
                }
            });
        }

        function CalculateDateOfBirth() {
            var ageInput = $('#txt_dob').val();
            var unit = $('#PrefixAge').val();

            var amount = parseInt(ageInput, 10);

            if (isNaN(amount) || amount <= 0 || amount > 1500) {
                $('#txtAge_yearss').val('');
                return;
            }

            var now = moment();
            var dob;
            if (unit === "Year") {
                dob = now.clone().subtract(amount, 'years');
            } else if (unit === "Month") {
                dob = now.clone().subtract(amount, 'months');
            } else if (unit === "Day") {
                dob = now.clone().subtract(amount, 'days');
            } else {
                $('#txtAge_yearss').val('');
                return;
            }

            var finalDate = dob.format("DD/MM/YYYY");

            var $input = $('#txtAge_yearss');
            if (!$input.hasClass('hasDatepicker')) {
                $input.datepicker({
                    changeMonth: true,
                    changeYear: true,
                    yearRange: "-100:+0",
                    dateFormat: "dd/mm/yy"
                });
            }

            $input.datepicker('setDate', dob.toDate());
            $input.unmask().mask("99/99/9999");
        }

        function EditPatientDetail(id) {
            var Patient_ID = $('#hdfPatient_ID').val();
            $('#CloseSearchModel').click(function () {
                window.location.href = "EmergencyCase.aspx";
            });
            $('#CloseSearchModels').click();
            $("#SavePatient_Data").hide();
            $("#PatientsSearchModel").hide();
            $("#ReferredPatientsModal").hide();
            $('#updatePatient_Data').show();
            $("#SavePatient_Data").hide();
            $('#RevistPat').show();
            $('#updatePatient_Data').show();
            $('#PatientModel').modal({
                backdrop: 'static'
            });
            var ajaxFn = function () {
                $.ajax({
                    type: "POST",
                    url: "EmergencyCase.aspx/GetEditPatientDetails",
                    data: "{'Reg_Patient_ID':" + id + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccessEdit,
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            setTimeout(ajaxFn, 3000);
        }

        var inPatientID;
        var Discharged;
        debugger;
        function OnSuccessEdit(data) {
            debugger;
            if (data.d != '') {
                debugger;
                inPatientID = data.d.Inpat;
                Discharged = data.d.Discharged;
                $("#txt_Mrno").val(data.d.Mr_No);
                $("#txt_name").val(data.d.Name);
                $("#ddl_Gender").val(data.d.Gender).change();
                var newValue = data.d.Age.replace('Y', '');
                $("#txt_dob").val(newValue);
                $("#ddl_status").val(data.d.MaritalStatus);
                $("#ddl_ctgry").val(data.d.Patient_Type).change();
                $("#ddl_Doc").val(data.d.DocID).change();
                $('#ddl_pnl_cpy').hide();
                //if (data.d.DOB != null) {
                //    stDate = new Date(parseInt(data.d.DOB.substr(6)));
                //    stDate = moment(stDate).format('L');
                //}

                if (data.d.Age != null) {
                    setTimeout(function () {
                        var age = parseInt(data.d.Age.replace(/\D/g, ''));

                        var dob = moment().subtract(age, 'years');
                        var formattedDOB = dob.format('YYYY-MM-DD');

                        $("#txt_dob").val(age);
                        $("#txtAge_yearss").val(formattedDOB);
                    }, 300);
                }



                $("#ddltest_main_dpt").val(data.d.department).change();
                $('#ddlRelation').val(data.d.Relation).trigger('change');
                $('#ddl_name').val(data.d.Title).trigger('change');
                $("#txt_relation").val(data.d.FatherName);
                $("#txt_mobile").val(data.d.Mobile);
                $("#txt_cnic").val(data.d.CNIC);
                $("#txt_Address").val(data.d.Address);
                $("#ddl_bld_grp").val(data.d.Blood_Group).change();
                $("#ddlRhFactor").val(data.d.Rh_Factor);
                if (data.d.Patient_Type == "02") {
                    $("#ddl_pnl_cpy").val(data.d.PanelComany).change();
                    $("#txt_Emp").val(data.d.TxtEmp);
                    $("#txt_Ref").val(data.d.TxtRef);
                }
                $('#hdfPatient_ID').val(data.d.Reg_PatientID);
            }

        }

        function checkPatientCondition(ddl) {
            var selectedVal = ddl.value;
            var selectedText = ddl.options[ddl.selectedIndex].text;
            var doctor = document.getElementById("<%= ddlDoctor.ClientID %>");
            var ward = document.getElementById("<%= ddlWard_No.ClientID %>");
            var bedNo = document.getElementById("<%= txtBed_No.ClientID %>");
            var referOPD = document.getElementById("<%= ReferToOPD.ClientID %>");

            if (selectedVal === "006" || selectedText === "OPD") {
                if (doctor) doctor.disabled = true;
                if (ward) ward.disabled = true;
                if (bedNo) bedNo.disabled = true;
                if (referOPD) referOPD.disabled = true;
            } else {
                if (doctor) doctor.disabled = false;
                if (ward) ward.disabled = false;
                if (bedNo) bedNo.disabled = false;
                if (referOPD) referOPD.disabled = false;
            }
        }



        function OpenReferredModal() {
            $('#ReferredPatientsModal').modal({
                backdrop: 'static'
            });
            FillReferredPatientsList();
        }

        function FillReferredPatientsList() {
            var SearchString = $('#txtReferredSearch').val().trim();
            $('#tblReferredPatients tbody').empty();
            PageMethods.GetReferredPatients(SearchString, OnReferredPatientsSuccess, OnFailPatients);
        }

        function OnReferredPatientsSuccess(data) {
            ClearReferredPatientResults();
            for (var i = 0; i < data.length; i++) {
                AddReferredPatientRow(
                    data[i].Reg_Patient_ID,
                    data[i].Patient_No,
                    data[i].Full_Name,
                    data[i].NIC,
                    data[i].Mobile1,
                    data[i].Father_Name
                );
            }
        }

        function ClearReferredPatientResults() {
            $('#tblReferredPatients tbody').empty();
        }

        function AddReferredPatientRow(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
            var row = document.getElementById('iReferredPatientsBody').insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span>' + Reg_Patient_ID + '</span>';
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
            actions += '<a style="color:#438eb9;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick="AddPatientDetail(' + Reg_Patient_ID + ')"><i class="fa fa-plus-circle"></i></a>&nbsp;|&nbsp;&nbsp;';
            actions += '<a style="color:#FDC303;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick="EditPatientDetail(' + Reg_Patient_ID + ')"><i class="fa fa-pencil-square-o"></i></a>';
            cell.innerHTML = actions;
        }


        function NewEMR() {
            var regId = $('#<%= hdfPatient_ID.ClientID %>').val();
            var url = '<%= ResolveUrl("~/Modules/Dashboards/NewEMR.aspx") %>';
            if (regId && regId != '(New)' && regId != '') {
                url += "?RegID=" + regId;
            }
            window.open(url, '_blank');
        }

        function PerformPatientSearch() {
            var searchString = $('#txtSearch').val();
            if (window.searchTimeout) {
                clearTimeout(window.searchTimeout);
            }

            window.searchTimeout = setTimeout(function () {
                PageMethods.AddPatient(searchString, OnFilterPatients, OnFailPatients);
            }, 300);
        }

        function LoadTemplate() {
            var options = '<option value="0" >Select Template</option>';
            PageMethods.GetTemplate(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                });
                $('#ddlTemplate').html(options);
                $('#ddlTemplate').select2();
            });
        }

        function LoadTemplateMedicine() {
            debugger;
            var Templateid = $('#ddlTemplate').val()
            PageMethods.GetTemplateMedicine(Templateid, function (res) {
                debugger;
                var Medicines = JSON.parse(res);
                var rows = '';
                $.each(Medicines, function (key, value) {
                    debugger;
                    var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    var datearray = date.split("/");
                    var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                    debugger;
                    rows += '<tr> <td><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> <a href="#" onclick="editMedicine(this)">Edit</a> |  <a href="#" onclick="deleteMedicine(this)"> Delete </a></td> <td style="display:none;">' + value.Item_Code + '</td></tr>';
                });
                $('#tblMedicinesList tbody').append(rows);
            })
        }


        function LoadTemplate() {
            var options = '<option value="0" >Select Template</option>';
            PageMethods.GetTemplate(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                });
                $('#ddlTemplate').html(options);
                $('#ddlTemplate').select2();
            });
        }

        function LoadTemplateForTest() {
            var options = '<option value="0">Select Template</option>';
            PageMethods.GetTemplate(function (Tests) {
                try {
                    var templates = JSON.parse(Tests);
                    $.each(templates, function (key, value) {
                        options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                    });
                    $('#ddlTemplateTest').html(options);
                    if ($.fn.select2) {
                        $('#ddlTemplateTest').select2();
                    }
                    console.log("Templates loaded:", templates.length);
                } catch (e) {
                    console.error("Error loading templates:", e);
                }
            }, function (error) {
                console.error("Failed to load templates:", error);
            });
        }

            function LoadtepmlateTest() {
            var Templateid = $('#ddlTemplateTest').val();
            if (!Templateid || Templateid == "0") return;
            PageMethods.GetTemplateTest(Templateid, function (res) {
                try {
                    var test = res.d || res;
            
                    console.log("Tests received:", test);
            
                    if (!test || test.length === 0) {
                        alert("No tests found in this template");
                        return;
                    }
            
                    $.each(test, function (key, value) {
                        AddTemplateTest(value.Department_id, value.Test_Name, value.Rotation_Id, value.Test_Id);
                    });
                } catch (e) {
                    console.error("Error:", e);
                    alert("Error loading template tests: " + e.message);
                }
            }, function (error) {
                console.error("AJAX error:", error);
                alert("Failed to load template tests");
            });
        }

        function AddTemplateTest(Dep_id, Test, Rot_id, Testid) {
            debugger;
            var maindpt = Dep_id;
            var CheckTest = Test;

            console.log("Adding template test - Dept:", maindpt, "Test:", Test, "TestID:", Testid);

            if (CheckTest != 0 && CheckTest != null && CheckTest != "") {
                if (maindpt == "001") {
                    AddTemLabTest(maindpt, CheckTest);
                }
                else if (maindpt == "002" || maindpt == "003" || maindpt == "004") {
                    AddTempRadialogyTest(CheckTest, Testid);
                }
                else if (maindpt == "005") {
                    AddTempBloodTest(Testid, CheckTest);
                    $('#divRotation').hide();
                }
                else if (maindpt == "006") {
                    FillTemProcedure(CheckTest, Testid);
                    $('#divRotation').hide();
                }
                else if (maindpt == "007") {
                    FillProcedure("007");
                    $('#ddlXRayLF').hide();
                    $('#divRotation').hide();
                }
                else if (maindpt == "008") {
                    AddCardioTest(maindpt, CheckTest);
                }
                else {
                    console.log("Unknown department ID:", maindpt);
                }
            } else {
                console.log("Invalid test data");
            }
        }

        function AddTemLabTest(maindpt, CheckTest) {
    debugger;
    var test = CheckTest;
    console.log("Adding Lab Test:", test);
    
    // ? FIXED: Only pass 'test' parameter, then callbacks
    PageMethods.GetLabTestDDLDetails(test, function (res) {
        try {
            console.log("Lab test response:", res);
            var labTests = JSON.parse(res);
            console.log("Parsed lab tests:", labTests);
            
            $.each(labTests, function (key, value) {
                debugger;
                var Result = 'Result';
                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';
                var row;
                
                var specialTestsVal = $('#ctl00_MainContent_txtSpecialTests').val() || "";
                var areaOfInterestVal = $('#ctl00_MainContent_txtAreaOfInterest').val() || "";
                
                if (value.Test_ID != 0) {
                    row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                    '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                    '<input type="hidden" name="txtRotation" value="0">' +
                    '<input type="hidden" name="txtGroupCategory" value="0">' +
                    '<input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' +
                    (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>' +
                    '<td>No</td><td>' + Result + '</td>' +
                    '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                    '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                    '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                } else {
                    row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                    '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                    '<input type="hidden" name="txtRotation" value="0">' +
                    '<input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/>' +
                    '<input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' +
                    (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>' +
                    '<td>No</td><td>' + Result + '</td>' +
                    '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                    '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                    '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                }
                
                var tableBody = $('.tests-table tbody');
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest tbody');
                }
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest');
                }
                
                console.log("Appending row to table:", tableBody);
                tableBody.append(row);
            });
            
            $("#ctl00_MainContent_txtSpecialTests").val("");
            $("#ctl00_MainContent_txtAreaOfInterest").val("");
            console.log("Lab tests added successfully");
        } catch (e) {
            console.error("Error in AddTemLabTest:", e);
            alert("Error adding lab test: " + e.message);
        }
    }, function (err) {
        console.error("Error calling GetLabTestDDLDetails:", err);
        alert("Failed to load lab test details");
    });
}

        function AddTempRadialogyTest(CheckTest, Testid) {
            debugger;
            var Result = 'Result';
            var test = Testid;
            var testname = CheckTest;
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
            var dateValue = '<%= DateTime.Now%>';
            var IsRotationShow = $('#divRotation').is(":visible");
            var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
            var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";

            if (Rotation_Name == "Select" || Rotation_ID == 0) {
                Rotation_ID = "";
                Rotation_Name = "";
            }

            var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
            var ddl_XRayLF_Name = IsRotationShow ? $('#ddlXRayLF option:selected').text() : " ";
            var ddlXRayLF_Name = ',' + ddl_XRayLF_Name;

            console.log("Adding Radiology Test:", testname, "TestID:", test);

            $.ajax({
                type: "POST",
                url: "EmergencyCase.aspx/GetTestMainDepartmentDetails",
                data: JSON.stringify({ TestID: test }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    try {
                        var MainDeptName = JSON.parse(data.d);
                        TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                        MainDepartmentName = MainDeptName[0].estMainDepartmen;

                        var specialTestsVal = $('#ctl00_MainContent_txtSpecialTests').val() || "";
                        var areaOfInterestVal = $('#ctl00_MainContent_txtAreaOfInterest').val() || "";

                        var row;
                        if (MainDepartmentName == "003") {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + test + '" />' +
                                '<input type="hidden" name="txtRotation" value="' + Rotation_ID + '">' +
                                '<input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '">' +
                                '<input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' +
                                TestMainDepartmentName + ', ' + testname + ', ' + Rotation_Name + ddlXRayLF_Name + '</td>' +
                                '<td>No</td><td>' + Result + '</td>' +
                                '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                                '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                                '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + test + '" />' +
                                '<input type="hidden" name="txtRotation" value="' + Rotation_ID + '">' +
                                '<input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' +
                                TestMainDepartmentName + ', ' + testname + ', ' + Rotation_Name + '</td>' +
                                '<td>No</td><td>' + Result + '</td>' +
                                '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                                '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                                '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        }

                        var tableBody = $('.tests-table tbody');
                        if (tableBody.length == 0) {
                            tableBody = $('#tblLabtest tbody');
                        }
                        if (tableBody.length == 0) {
                            tableBody = $('#tblLabtest');
                        }

                        console.log("Appending radiology row to table");
                        tableBody.append(row);
                        $('#ddlXRayLF option:selected').val("0");
                        $("#ctl00_MainContent_txtSpecialTests").val("");
                        $("#ctl00_MainContent_txtAreaOfInterest").val("");
                        console.log("Radiology test added successfully");
                    } catch (e) {
                        console.error("Error in AddTempRadialogyTest:", e);
                    }
                },
                failure: function (response) {
                    console.error("Failure in AddTempRadialogyTest:", response);
                    alert(response.d);
                }
            });
        }

        function AddTempBloodTest(Testid, CheckTest) {
            var test = CheckTest;
            console.log("Adding Blood Test:", test);

            PageMethods.GetBBDDLDetails(test, function (res) {
                try {
                    var bloodTests = JSON.parse(res);
                    console.log("Blood tests:", bloodTests);

                    $.each(bloodTests, function (key, value) {
                        var Result = 'Result';
                        var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';
                var row;

                var specialTestsVal = $('#ctl00_MainContent_txtSpecialTests').val() || "";
                var areaOfInterestVal = $('#ctl00_MainContent_txtAreaOfInterest').val() || "";

                if (value.Test_ID != 0) {
                    row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                        '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                        '<input type="hidden" name="txtRotation" value="0">' +
                        '<input type="hidden" name="txtGroupCategory" value="0">' +
                        '<input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' +
                        (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' +
                        (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>' +
                        '<td>No</td><td>' + Result + '</td>' +
                        '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                        '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                        '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                }
                else {
                    row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                        '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                        '<input type="hidden" name="txtRotation" value="0">' +
                        '<input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/>' +
                        '<input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' +
                        (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>' +
                        '<td>No</td><td>' + Result + '</td>' +
                        '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                        '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                        '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                }

                var tableBody = $('.tests-table tbody');
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest tbody');
                }
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest');
                }

                tableBody.append(row);
            });

            $("#ctl00_MainContent_txtSpecialTests").val("");
            $("#ctl00_MainContent_txtAreaOfInterest").val("");
            console.log("Blood tests added successfully");
        } catch (e) {
            console.error("Error in AddTempBloodTest:", e);
        }
    }, function (err) {
        console.error("Error calling GetBBDDLDetails:", err);
    });
        }

        function FillTemProcedure(CheckTest, Testid) {
            debugger;
            console.log("Filling Procedure:", CheckTest);

            PageMethods.GetTemProcedure(CheckTest, function (item) {
                try {
                    var procedures = JSON.parse(item);
                    console.log("Procedures:", procedures);

                    $.each(procedures, function (key, value) {
                        var Result = 'Result';
                        var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';
                var row;
                var TestMainDepartmentName = value.Main_Department_Name;

                var specialTestsVal = $('#ctl00_MainContent_txtSpecialTests').val() || "";
                var areaOfInterestVal = $('#ctl00_MainContent_txtAreaOfInterest').val() || "";

                row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                    '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                    '<input type="hidden" name="txtRotation" value="0">' +
                    '<input type="hidden" name="txtGroupCategory" value="0">' +
                    '<input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' +
                    (TestMainDepartmentName == null ? '' : TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' +
                    (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>' +
                    '<td>No</td><td>' + Result + '</td>' +
                    '<td><input type="hidden" name="txtSpecial_Test" value="' + specialTestsVal + '"/> ' + specialTestsVal + '  </td>' +
                    '<td><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfInterestVal + '"/> ' + areaOfInterestVal + ' </td>' +
                    '<td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                var tableBody = $('.tests-table tbody');
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest tbody');
                }
                if (tableBody.length == 0) {
                    tableBody = $('#tblLabtest');
                }

                tableBody.append(row);
            });

            console.log("Procedures added successfully");
        } catch (e) {
            console.error("Error in FillTemProcedure:", e);
        }
    });
        }



        function LoadDischargeTemplate() {
            var options = '<option value="0" >Select Template</option>';
            PageMethods.GetTemplate(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                });
                $('#ddlDischargeTemplate').html(options);
                if ($.fn.select2) {
                    $('#ddlDischargeTemplate').select2();
                }
            });
        }

        function LoadDischargeTemplateMedicine() {
            var Templateid = $('#ddlDischargeTemplate').val();
            if (!Templateid || Templateid == "0") return;

            PageMethods.GetTemplateMedicine(Templateid, function (res) {
                var Medicines = JSON.parse(res);
                var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy h:m:s A")%>';
            var datetimeValue = '<%= DateTime.Now%>';

            $.each(Medicines, function (key, value) {
                var dosage_from = value.Dosage_From || '';
                var dosage_Qty = value.Dosage_Qty || '';
                var routes = value.Oral || ''; 
                var other_Instruction = value.Other_Instruction || '';
                var frequency = value.Frequency || '';
                var row = '<tr> ' +
                    '<td><input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + '</td>' +
                    '<td><input type="hidden" name="hdnItemCode" value="' + value.Item_Code + '"> ' + value.Medicine_Name + '</td> ' +
                    '<td>' + frequency + '</td> ' +
                    '<td>' + routes + '</td> ' +
                    '<td>' + value.Injections + '</td> ' + 
                    '<td>' + value.AttendingParamedical_Staff + '</td> ' + 
                    '<td>' + dosage_from + '</td> ' +
                    '<td>' + dosage_Qty + '</td> ' +
                    '<td>' + other_Instruction + '</td> ' +
                    '<td><a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' /></td>' +
                    '<td style="display:none;">' + value.Item_Code + '</td>' +
                    '</tr>';

                $('#tblDischargeMedication tbody').append(row);
            });
        });
       }


    </script>

    <style type="text/css">
        .mgTab {
            padding-left: 80px;
        }

        .mg {
            padding-left: 30px;
        }

        .header-center {
            text-align: center;
        }

        .dropdownBackgroud {
            background-color: #f5f5f5 !important;
        }

        .dropdownBackgroudWhite {
            background-color: #fff !important;
        }

        .Error {
            color: #f00;
        }

        .Success {
            color: #4800ff;
        }

        .Checking {
            color: #00ff21;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-8 col-md-6 col-sm-12">
            <div class="row">
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <input type="button" value="Queue" id="btnSearchPatient" onclick="OpenModal()" class="btn-primry" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <input type="button" value="Refer Admissions" id="btnReferAdmissions" onclick="OpenReferredModal()" class="btn-primry" style="display:none" />
                </div>
                <div class="col-lg-1 col-md-3 col-sm-3"></div>
                <div class="col-lg-4">
                    <div class="search-container">
                        <div class="search-input-wrapper">
                            <input
                                type="text"
                                class="search-input"
                                placeholder="Search for anything..."
                                id="searchInput"
                                autocomplete="off"
                                style="height: 45px; width: 100% !important; padding: 16px 50px 16px 20px !important; border: 1.5px solid #ccc !important; border-radius: 25px !important; background: rgba(255, 255, 255, 0.1) !important; backdrop-filter: blur(10px) !important; color: black !important; font-size: 16px !important; box-shadow: none !important" />
                            <div class="search-icon">??</div>
                        </div>
                        <div class="search-results" id="searchResults"></div>
                    </div>
                </div>
                <div class="col-lg-3"></div>
            </div>
        </div>
    </div>

    
    <div id="PatientsSearchModel" data-backdrop="static" class="modal fade-in" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -78px; height: 604px; position: relative;">
            <fieldset style="padding-top: 20px; padding-left: 14px;">
                <div class="row" style="margin-bottom: 15px;">
                    <div class="col-lg-4 col-md-8 col-sm-8">
                        <label id="srchpat" style="font-weight:bold; font-size: 16px;">Search Your Patients (Name, CNIC, Mobile): </label>
                        <input type="text" id="txtSearch" style="margin-left: 10px; width: 60%; padding: 5px;" autocomplete="off" onkeyup="PerformPatientSearch()" placeholder="Type to search..." />
                    </div>
                    <div class="col-lg-4 col-md-4 col-sm-4" style="display:none">
                        <label></label>
                        <input type="button" class="btn btn-primry" id="addNewbtn" onclick="addfunc()" value="Add New Patient" />
                    </div>
                </div>
                <h2>Emergency Patient List</h2>
            </fieldset>
            <div style="overflow: scroll; height: 460px; padding: 10px;">
                <table class="table table-hover table-striped table-bordered" id="tblPatientsResult" style="overflow: scroll; height: auto;">
                    <thead id="Thead1">
                        <tr>
                            <th style="display: none;">Patient ID</th>
                            <th>MR No</th>
                            <th>EMR No</th>
                            <th>Patient Name</th>
                            <th>Father Name</th>
                            <th>CNIC</th>
                            <th>Contact No</th>
                            <th>Admint Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>

                    <tbody id="iPatientsBody">
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <input type="button" style="width:13% !important" id="ClosePatientsSearchModel" class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
            </div>

        </div>

    </div>

</div>


<div id="ReferredPatientsModal" data-backdrop="static" class="modal fade" role="dialog" style="display:none" >
    <div class="modal-dialog">
        <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -78px; height: 604px; position: relative;">
            <fieldset style="padding-top: 20px; padding-left: 14px;">
                <div class="col-lg-3 col-md-4 col-sm-6">                           
                    <label id="lblReferredSearch">Referred Patients:</label>
                    <input type="text" id="txtReferredSearch" style="margin-left: 2px;"  autocomplete="off"
                        placeholder="Search by MR No, Name, CNIC, or Contact..."  oninput="FillReferredPatientsList()" />
                </div>
            </fieldset>
            <div style="overflow: scroll; height: 460px; padding: 10px;">
                <table class="table table-hover table-striped table-bordered" id="tblReferredPatients" style="width:100%;">
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
                    <tbody id="iReferredPatientsBody">
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <input type="button" style="width:13% !important" class="btn-gray" value="Close" data-dismiss="modal" />
            </div>
        </div>
    </div>
</div>


      <div id="PatientModel" class="modal fade-in" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content modalSize" style="width: 1104px; margin-left: -77px; height: 308px; margin-top: 117px; /* 316px */">

            <form>
                <div class="container-fluid">
                    <div class="row" style="margin-top: 40px!important;">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>MR No</label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="text" tabindex="1" id="txt_Mrno" value="New" disabled style="width: 232px !important;" />
                        </div>


                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-2 col-md-3 col-sm-4"></div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>Gender</label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <select id="ddl_Gender" tabindex="5" style="width: 197px;">
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Name<span style="color:red;">*</span></label>
                        </div>

                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <select class="impo-drop1 fcux" tabindex="3" name="name" id="ddl_name">
                                <option value="Mr.">Mr.</option>
                                <option value="Mrs.">Mrs.</option>
                                <option value="Ms.">Ms.</option>
                                <option value="B/O.">B/O.</option>
                            </select>
                        </div>


                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input name="dob"  type="text" id="txt_name" tabindex="4" style="margin-left: -12px !important" />
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4"></div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>Martial Status</label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <select  tabindex="6" id="ddl_status"  style="width: 197px;">
                                <option></option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Relation</label>
                        </div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <select class="impo-drop fcux" tabindex="7" name="name" id="ddlRelation">
                                <option value="S/O">S/O</option>
                                <option value="W/O">W/O</option>
                                <option value="D/O">D/O</option>
                            </select>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="text" id="txt_relation" tabindex="8" style="margin-left: -12px !important" />
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4"></div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>Mobile</label>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="text" tabindex="9" id="txt_mobile" style="width: 197px !important;" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Age/DOB</label>
                        </div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <select name="name" tabindex="10" id="PrefixAge" >
                                <option value="Year">Year</option>
                                <option value="Month">Month</option>
                                <option value="Day">Day</option>
                            </select>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="text" id="txt_dob" tabindex="11" style="width: 35% !important; margin-left: -15px!important" onchange="CalculateDateOfBirth();" />
                            <input class="fcux" type="text" id="txtAge_yearss" style="display: inline; width: 65% !important" placeholder="mm ddyy" />
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4"></div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>CNIC</label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input tabindex="12"  type="text" id="txt_cnic" style="width: 200px !important" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Address</label>
                        </div>

                        <div class="col-lg-6 col-md-3 col-sm-4">
                            <input type="text" tabindex="13" id="txt_Address"  />
                        </div>
                    </div>
                </div>
            </form>


            <div class="modal-footer" style="margin-top: 6%;">
                <input type="button"  id="SavePatient_Data" class="btn btn-primry" tabindex="13" name="savePatient_Data" value="Save" style="width:10% !important" onclick="SavePatient();" />
                <%-- <input type="button" id="RevistPat" name="RevistPat" value="Revist" onclick="SaveRevist_Patient();" />--%>
                <input type="button" id="updatePatient_Data" class="btn btn-primry"  name="updatePatient_Data" style="text-transform: capitalize;width:10% !important" value="Update" onclick="SavePatient();" tabindex="23" />
                <input type="button" id="CloseSearchModel" class="btn-gray" style="width:10% !important" name="saveENT" value="Close" data-dismiss="modal" />
            </div>
        </div>
    </div>
</div>

   <div id="MedicationModel" class="modal fade" role="dialog">
        <div class="modal-dialog">

            <div class="modal-content" style="width: 824px; margin-left: 133px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Medicine</h4>
                </div>

                <div class="modal-body">
                    <fieldset>
                        <legend>Medication Details</legend>
                        <table id="tblMedicines" class="add-test">
                            <tr>
                                <td style="width: 110px">
                                    <span id="lblMed">Medicine Name</span>
                                    
                                </td>
                                <td style="width: 234px" id="MedicineName" >
                                    <div>
                                    <select id="txtMedicineName" name="txtMedicineName" class="js-example-responsive" style="width: 334px" onchange="CleardrpdwnItem()">
                                    </select>
                                    </div>
                                </td>

                                <td style="width: 110px">
                                    <span id="pitem" style="margin-left: -346px;">Medicine Name</span>
                                    <span class="RedStar">*</span>
                                </td>
                                <td style="width: 234px">
                                    <div style="margin-left: -544px;  margin-bottom: 12px; " >                                   
                                        <select style="width: 48% !important" id="txtPharmacyItem" name="txtPharmacyItem" style="margin-left: -93px;margin-left: -176px;" onchange="Cleardrpdwn()">
                                    </select>
                                        </div>

                                </td>
                            </tr>
                            <tr>
                                <td style="width: 110px"><span>Dose</span><span class="RedStar"></span></td>
                                <td>
                                <select style="width: 80px !important;float: left !important; margin-right:10px;" id="ddlDosage_Qty" name="DosageQty">
                                    <option value="">Select</option>
                                </select>   
                                 <select style="width: 80px !important;float: left !important;" id="ddlDosage_From" name="DosageFrom">
                                   <option value="">Select</option>
                                </select> 
                                </td>
                                
                                <td></td>
                            </tr>
                            <tr>
                                <td><span>Frequency </span><span class="RedStar" id="spnFreq">*</span></td>
                                <td>
                                    <select id="txtRecomended_Dosage" name="RecomendedDosage" tabindex="3" style="width: 176px !important">

                                    </select>
                                </td>
                               

                            </tr>
                      
                            <tr>
                                <td><span>Route </span><span class="RedStar"></span></td>
                                <td>
                                    <select id="Routes" name="Routes" tabindex="4" style="width: 176px !important">
                                    </select>
                                </td>
                                <td><span style="font-size:17px; padding-left: 106px; font-family: -webkit-body;">Other Instructions </span></td>
                            </tr>
                            <tr>
                                <td style="width: 161px;"><span style="width:135px;">Duration (Days/Hours)</span><span class="RedStar" id="spndur">*</span></td>
                                <td>
                                    <input type="text" id="txtInjection" name="txtInjection" placeholder="Duration" tabindex="5" style="width: 176px !important" />
                                </td>
                                <td>
                                      <select style="margin-left: 112px; width: 205px !important;"  id="ddlOther_Instruction" name="OtherInstruction">
                                        <option>Please Select</option>
                                    </select>
                                </td>
                                <td>
                                  
                                </td>
                            </tr>
                            <tr>
                                <td><span>Special Instructions </span><span class="RedStar"></span></td>
                                <td>
                                    <input type="text" name="AttendingParamedicalStaff" id="AttendingParamedicalStaff" tabindex="6" style="width: 176px !important" />
                                </td>
                                
                                <td>

                                    <input type="text" id="txtMedicen" visible="false" style="margin-left: 113px;" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <input type="button" class="btn btn-primry" id="btnSaveMedicine" name="btnSaveMedicine" value="Save" tabindex="7" />
                                </td>
                                 <td>
                                    <input type="button" id="Add_Unlisted_Medicine" class="btn btn-primry" value="Add Unlisted Medicine" style="margin-left: 110px;width:67% !important; color:white !important;" onclick="NewMedicine()" />
                                        </td>
                                <td></td>
                            </tr>
                        </table>
                    </fieldset>
                    <input type="hidden" name="uurowid" value="" />
                </div>
                <div class="modal-footer">
                    <input type="button" style="width:12% !important;"  class="btn-gray" value="Done"  data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>

    <asp:UpdatePanel runat="server" ID="UpdatePanel6" UpdateMode="Conditional">
        <Triggers>          
        </Triggers>
        <ContentTemplate>

    <div class="row">
     <!-- Left Card -->
        <div class="col-lg-5 col-md-6 col-sm-12">
       <div class="card">
        <div class="card-body">
            <div class="row mb-2">
                <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                    <div class="image-container">
                        <img src="~../../../../wwwroot/ASsiratTheme/images/dashboard_Icons/Emergency.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                    </div>
                </div>
                    <div class="row mb-2"  style="display:none">
                        <div class="col-lg-5 col-md-5 col-sm-6 detail" >
                            <asp:Label ID="lblPatient_Name" runat="server" style="display:none" Text="Patient Name :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 detail">
                            <asp:Label ID="vlblPatients_Name"  style="display:none" runat="server"></asp:Label>
                        </div>
                    </div>
                <div class="col-lg-8 col-md-7 col-sm-6">
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :"></asp:Label>
                            <span style="color:red;"> *</span>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                            <asp:HiddenField ID="hdfPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                        </div>
                    </div>
                
                    <div class="row mb-2 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 detail">
                            <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-2 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 detail">
                            <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                        </div>
                    </div>
                      <div class="row mb-2 mtt">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                    </div>
                </div>
                </div>
            </div>
        </div>
    </div>
</div>


    <!-- Right Card -->
    <div class="col-lg-5 col-md-6 col-sm-12">
        <div class="card">
            <div class="card-body">
                 <div class="row mb-2">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="LblIn_Patient_ID" runat="server" Text="Emergency No"></asp:Label>                     
                    </div>
                     <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                          <asp:TextBox ID="txtIn_Patient_ID" runat="server" Text="(New)" ReadOnly="True"></asp:TextBox>
                     </div>
                </div>
                <div class="row mb-2">
                    <div class="col-lg-5 col-md-5 col-sm-6">
                        <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6">
                        <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                    </div>
                </div>
                <div class="row mb-2">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                    </div>
                </div>
                <div class="row mb-2">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="Label36" runat="server" Text="Patient Type:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6">
                        <asp:Label ID="vLbl_Patient_Type" runat="server" style="background-color: silver;"></asp:Label>
                    </div>
                </div>
              
                <div class="row mb-2 formrgn">
                    <div class="col-lg-12">
                        <asp:Label ID="vLbl_Patient_AdmitCatagory" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>



            <div>
                <div id="tabs" >
                    <ul>
                        <li style="display: none" id="Admissiontab"><a href="#Tab-1">Admission</a></li>
                        <li><a href="#Tab-2" >Receiving Note</a></li>
                        <li><a href="#Tab-8">History</a></li>
                        <li><a href="#Tab-9">Examination</a></li>
                        <li><a href="#Tab-6">Investigation</a></li>
                        <li><a href="#Tab-13">Services / Procedure</a></li>
                        <li><a href="#Tab-4">Medication</a></li>
                        <li style="background: #8a2be273;"><a href="#Tab-16">Nursing</a></li>
                        <li><a href="#Tab-12">Call To Doctor </a></li>
                      <li class="moveleft"><a href="#Tab-15">Vitals Discharge</a></li>
                        <li class="moveleft"><a href="#Tab-5">Discharge Details</a></li>
                        <li class="moveleft" id="deathtab"><a href="#Tab-11">Death Details</a></li>
                      <li><a href="#Tab-3" style="display: none">Operations</a></li>                     
                    </ul>

<div id="Tab-1" class="container-fluid" >
    <div id="OtherDetails">
        <div class="row">
            <h2 class="Heading">Admission Details:</h2>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">               
            <asp:Label ID="lblPatientCondition" runat="server" Text="Triage Area"></asp:Label>
                <asp:UpdatePanel ID="UpdatePanel1"  runat="server">
                    <ContentTemplate><asp:DropDownList ID="ddlPatientCondition" runat="server" AppendDataBoundItems="true"   onchange="checkPatientCondition(this)" ></asp:DropDownList></ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label runat="server" ID="lblTreatmentTime" Text="Treatment Time"></asp:Label>
                <asp:TextBox runat="server" ID="txtTreatmentTime" ReadOnly="true"></asp:TextBox>
            </div>
             <div class="col-lg-1 col-md-4 col-sm-6"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="LblAdmission_Date" runat="server" Text="Admission Date"></asp:Label>
                <asp:TextBox ID="txtAdmission_Date" runat="server" ReadOnly="true"></asp:TextBox>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <asp:UpdatePanel ID="UpdatePanel8" runat="server" UpdateMode="Always">
                    <ContentTemplate><asp:Label ID="vlblCurrent_Allocated_Room_Ward" runat="server" /></ContentTemplate>
                </asp:UpdatePanel>
                <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                    <ContentTemplate><asp:Button ID="btnAllocatedRoomWardChkTriggerBtn" Style="display: none;" Text="Chk Allocated Room" runat="server" OnClick="btnAllocatedRoomWardChkTriggerBtn_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="LblDepartment" runat="server" Text="Department"></asp:Label>
                <asp:DropDownList ID="ddlDepartment" TabIndex="1" runat="server" class="form-control" AppendDataBoundItems="true" onchange="" Enabled="false"></asp:DropDownList>
                <asp:UpdatePanel ID="UpdatePanel12" runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:Button ID="btnGet_Doctor" Style="display: none" class="d-none" Text="" runat="server" OnClick="btnGet_Doctor_Click" CausesValidation="false" />
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>            
        </div>

        <div class="row">
             <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="LblDoctor" runat="server" Text="Doctor"></asp:Label>
                <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel13">
                    <Triggers>
                        <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                    </Triggers>
                    <ContentTemplate>
                        <asp:DropDownList ID="ddlDoctor" runat="server" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
           
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblIssuance_Of" runat="server" Text="Admit To"></asp:Label>&nbsp;&nbsp;<span class="text-danger">*</span>
                <asp:UpdatePanel ID="UpdatePanel9"  runat="server">
                    <ContentTemplate>
                        <asp:DropDownList ID="ddlIssuance_Of" runat="server" AppendDataBoundItems="true" onChange="chkIssuance_Of_Select()" Enabled="false"></asp:DropDownList>
                    </ContentTemplate>
                </asp:UpdatePanel>
                <asp:RequiredFieldValidator ID="rfvIssuance_Of" ControlToValidate="ddlIssuance_Of" InitialValue="0" runat="server" ErrorMessage="Select Admit To" Text="*"></asp:RequiredFieldValidator>
            </div>          
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="LblBed_No" runat="server" Text="Bed No"></asp:Label>
                <asp:TextBox ID="txtBed_No" runat="server" Enabled="true" class="form-control"></asp:TextBox>
            </div>        
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblWard_No" runat="server" Text="Ward"></asp:Label>&nbsp;&nbsp;<span class="text-danger">*</span>
                <asp:UpdatePanel ID="UpdatePanel11"  runat="server" UpdateMode="Always">
                    <ContentTemplate>
                        <asp:DropDownList ID="ddlWard_No" runat="server" AppendDataBoundItems="true" OnChange="FillWardBeds()" class="form-control"></asp:DropDownList>
                    </ContentTemplate>
                </asp:UpdatePanel>
            </div>
        </div>     
        <div class="row">
             <div class="col-lg-1 col-md-4 col-sm-6">
                  <asp:Label ID="lblcategory" runat="server" Text="PatientCategory"></asp:Label>
                  <asp:DropDownList ID="ddlCategory" runat="server" AppendDataBoundItems="true" OnChange="LoadFee()" class="form-control"></asp:DropDownList>
                
               </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
             <asp:Label ID="lblfee" runat="server" Text="Admission Fee"></asp:Label>
             <asp:TextBox ID="txtadmissionfee" ReadOnly="true" runat="server" Enabled="true" class="form-control"></asp:TextBox>
                 </div>
        
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Label ID="lbldiscount" runat="server" Text="Discount %"></asp:Label>
                    <asp:TextBox ID="txtDiscount" onchange="Calc_Discount()" runat="server" ></asp:TextBox>
                 </div>
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
             <div class="col-lg-2 col-md-4 col-sm-6">
                 <asp:Label ID="lblremarks" runat="server" Text="Remarks"></asp:Label>
                 <asp:TextBox ID="txt_remarks"  runat="server" ></asp:TextBox>
            </div>
             <div class="col-lg-1 col-md-4 col-sm-6"></div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                       <div class="file-upload-wrapper">
                   <asp:FileUpload ID="file_upload" runat="server" CssClass="form-control form-control-sm" Style="flex: 1;" />
                   <asp:HyperLink ID="hlExistingFile" runat="server"
                       Text="View Attached File"
                       Target="_blank"
                       Visible="false"
                       CssClass="btn btn-sm btn-outline-secondary" />
                    </div>
                </div>
        </div>
        <div class="row">
      <div class="col-lg-9 col-md-12 col-sm-2">
    <div class="table-responsive">
        <table class="table" id="dvHistoward">
            <thead>
                <tr>
                    <td colspan="7">
                            <h2 class="heading">Ward Previous History</h2>
                    </td>
                </tr>
                <tr>
                    <th>Admission Date</th>
                    <th>Department</th>
                    <th>Admitting Doctor</th>
                    <th>Triage Area</th>
                    <th>Discharge Date</th>
                    <th>Ward</th>
                    <th>Bed No</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
        </div>       
        </div>
              <div class="col-lg-3 col-md-4 col-sm-4"> 
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
            </div>
         </div>
       </div>

   <div id="Tab-2" class="container-fluid">
       <div class="row">
           <div class="col-lg-12 col-md-4 col-sm-6">
                 <h2 class="Heading">Receiving Note:</h2>
           </div>
       </div>
       <div class="row">
           <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="lblRateBeats" runat="server" Text="Plus Rate (Beats per Min)"></asp:Label>
                <asp:TextBox ID="txtRateBeats" runat="server" TabIndex="1" CssClass="form-control" ></asp:TextBox>
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="LblBP" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
               <asp:TextBox ID="txtBP" runat="server" TabIndex="2" CssClass="form-control"></asp:TextBox>
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
                 <asp:Label ID="lblRhythm" runat="server" Text="Rhythm"></asp:Label>
                 <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythm" CssClass="form-control"></asp:DropDownList>
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="LblTemp" runat="server" Text="Temperature (°F)"></asp:Label>
                <asp:TextBox ID="txtTemp" runat="server" TabIndex="3" CssClass="form-control" ></asp:TextBox>
           </div>
           </div>
       <div class="row">
           <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="lblVolume" runat="server" Text="Volume"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlVolume" AppendDataBoundItems="true" CssClass="form-control"></asp:DropDownList>
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
               <asp:Label ID="LblRespiration" runat="server" Text="Respiration Rate (/min)"></asp:Label>
               <asp:TextBox ID="txtRespiration" runat="server" TabIndex="4" CssClass="form-control"></asp:TextBox>
           </div>
            <div class="col-lg-1 col-md-4 col-sm-6"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblSaturation" runat="server" Text="O2 Saturation"></asp:Label>
                <asp:TextBox ID="txtSaturation_Oxygen2" runat="server" TabIndex="5" CssClass="form-control"></asp:TextBox>
            </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
         <div class="col-lg-2 col-md-4 col-sm-6">
             <asp:Label ID="lblbsr" runat="server" Text="BSR"></asp:Label>
              <asp:TextBox ID="txtbsr" runat="server" CssClass="form-control" ></asp:TextBox>
         </div>
        
           </div>
       <div class="row">
           <div class="col-lg-1 col-md-4 col-sm-6">
               <label>Percentage</label>
               <asp:TextBox ID="txtSaturation" runat="server" TabIndex="7" CssClass="form-control" />
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6">
               <label>Liters Per Minutes</label>
               <asp:TextBox ID="txtSaturation_Oxygen1" runat="server" TabIndex="8" CssClass="form-control" />
           </div>
           <div class="col-lg-1 col-md-4 col-sm-6"></div>
           <div class="col-lg-1 col-md-4 col-sm-6">
               <label>Room Air</label>
               <asp:CheckBox runat="server" Class="CHKK"  ID="chk_OnRoomAir" />
           </div>

           <div class="col-lg-1 col-md-4 col-sm-6 mt-2">
               <label>With O2</label>
               <asp:CheckBox  runat="server" Class="CHKK" ID="chk_WithOxygen"  />
           </div>
           <div class="col-lg-1 col-md-4 co-sm-6"></div>
           <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Label ID="lblRecieving_Time" runat="server" Text="Receiving Date & Time"></asp:Label>
                 <asp:TextBox ID="txtReceiving_Date" runat="server" ReadOnly="true" CssClass="form-control"></asp:TextBox>
           </div>
              <div class="col-lg-1 col-md-4 col-sm-6"></div>
              <div class="col-lg-2 col-md-4 col-sm-6">
       <asp:Label ID="lblOthersReceiveNote" runat="server" Text="Others"></asp:Label>
       <asp:TextBox ID="txtOthersRcvNote" runat="server" TabIndex="6" CssClass="form-control"></asp:TextBox>
   </div>
          
           </div>
       <div class="row">
          
 <div class="col-lg-2 col-md-4 co-sm-6">
     <asp:Label ID="lblRN_Special_Instruction" runat="server" Text="Special Instruction"></asp:Label>
     <asp:TextBox ID="txtRN_Special_Instruction" runat="server" TabIndex="9" TextMode="MultiLine" CssClass="form-control" onchange="FillInstruction()"></asp:TextBox>
 </div>
       </div>
       <div>
        <div class="col-12">
            <div class="table-responsive">
                <table class="table table-bordered" id="tblVitalParametersHistory">
                    <thead>
                        <tr>
                            <td colspan="15  ">
                                <h2 class="heading">Previous History</h2>
                            </td>
                        </tr>
                        <tr>
                            <th>Receiving Date & Time</th>
                            <th>Status</th>
                            <th>Rate_Beats</th>
                            <th>Temperature</th>
                            <th>BSR</th>
                            <th>Rhythm</th>
                            <th>Volume</th>
                            <th>Blood Pressure</th>
                            <th>Others</th>
                            <th>Respiration</th>
                            <th>Instruction</th>
                            <th>O2 Saturation</th>
                            <th>O2 Saturation_Oxygen1</th>
                            <th>O2 Saturation_Oxygen2</th>
                            <th>Username</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>



                    <div id="Tab-3">

    <div id="Operations" class="table-responsive">
        <table class="table table-bordered table-striped">
            <thead>            
            </thead>
            <tbody>
                <tr>
                    <td>
                        <asp:Label ID="lblOperation_No" runat="server" Text="Operation No."></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtOperation_No" runat="server" class="form-control"></asp:TextBox>
                    </td>
                    <td>
                        <asp:Label ID="lblPerformed_By" runat="server" Text="Performed By"></asp:Label>
                    </td>
                    <td>
                        <asp:DropDownList ID="ddlPerformed_By" runat="server" class="form-select" AppendDataBoundItems="true"></asp:DropDownList>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblBrief_Description" runat="server" Text="Brief Description"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtBrief_Description" runat="server" TextMode="MultiLine" class="form-control"></asp:TextBox>
                    </td>
                    <td>
                        <asp:Label ID="lblSurgeon_Note" runat="server" Text="Surgeon Note"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtSurgeon_Note" runat="server" TextMode="MultiLine" class="form-control"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblMedication_Precautions" runat="server" Text="Medication And Precautions"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtMedication_Precautions" runat="server" class="form-control"></asp:TextBox>
                    </td>
                    <td>
                        <asp:Label ID="lblPost_Operative_Care" runat="server" Text="Post Operative Care"></asp:Label>
                    </td>
                    <td>
                        <asp:TextBox ID="txtPost_Operative_Care" runat="server" class="form-control"></asp:TextBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblShifted_To_ICU" runat="server" Text="Shifted To ICU"></asp:Label>
                    </td>
                    <td>
                        <asp:CheckBox ID="cbShifted_To_ICU" runat="server" class="form-check-input"></asp:CheckBox>
                    </td>
                    <td>
                        <asp:Label ID="lblShifted_To_CCU" runat="server" Text="Shifted To CCU"></asp:Label>
                    </td>
                    <td>
                        <asp:CheckBox ID="cbShifted_To_CCU" runat="server" class="form-check-input"></asp:CheckBox>
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblShifted_Observation_Room" runat="server" Text="Shifted To Observation Room"></asp:Label>
                    </td>
                    <td>
                        <asp:CheckBox ID="cbShifted_To_Observation_Room" runat="server" class="form-check-input"></asp:CheckBox>
                    </td>
                </tr>
            </tbody>
        </table>
    </div>
</div>

                    <div id="Tab-4">
                         <div id="Medication">
                    <h2>Medication :</h2>                 
                            <div class="row align-items-center mb-3">
                                <div class="col-lg-2 col-md-4 col-sm-12">
                                    <select id="ddlTemplate" class="form-select" onchange="LoadTemplateMedicine()">
                                        <option value="">Select Template</option>
                                    </select>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-12">                               
                                    <input type="button" class="btn-primry"  value="Add Medicine" id="btnAddMedicine" />
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-12 mt-2 d-flex align-items-center">
                                    <label >No Medicine</label>
                                    </div>
                                <div class="col-lg-1 col-md-4 col-sm-12" style="margin-left:-3%">
                                    <asp:CheckBox class="Chkbox" ID="chkNo_Medicine"  runat="server"  />
                                </div>
                            </div>

                                                  
                                <div style="height: 280px;">
                               <div class="table-container">
                                         <div class="table-responsive" style="overflow:auto;height:273px">
                                       <table class="table table-bordered" id="tblMedicinesList">
                                           <thead>
                                               <tr style="position: sticky; top: 0px; z-index: 10;">
                                                   <th>Date</th>
                                                   <th>Medicine Name</th>
                                                   <th>Frequency</th>
                                                   <th>Routes</th>
                                                   <th>Duration</th>
                                                   <th>Special Instructions</th>
                                                   <th>Dosage Form</th>
                                                   <th>Dosage Qty</th>
                                                   <th>Other Instructions</th>
                                                   <th>Edit</th>
                                               </tr>
                                           </thead>
                                           <tbody>
                                           </tbody>
                                       </table>
                                   </div>
                               </div>
                                </div>


                      <div class="table-container" id="dvHistoryMedication">
                  <table class="table" id="tblHistoryMedication">
                      <thead>
                          <tr>
                              <td colspan="12">
                                  <div id="HeaderHistoryMedication">
                                      <h2 class="heading">Previous History</h2>
                                  </div>
                              </td>
                          </tr>
                          <tr>
                              <th><input type="checkbox" id="select-all-checkbox" /></th>
                              <th>Date </th>
                              <th>Status </th>
                              <th>Medicine Name</th>
                              <th>Dosage</th>
                              <th>Frequency  </th>
                              <th>Routes </th>
                              <th>Other Instruction</th>
                            <th style="display:none;">Attending Paramedical Staff </th>
                          </tr>
                      </thead>
                      <tbody>
                      </tbody>
                  </table>
             
                       <div class="row">
                           <div class="col-lg-2 col-md-4 col-sm-6">
                           <input  type="button" class="btn btn-primry" value="Load Medicine" id="load_previous_Med" onclick="Appendintable()" />
                       </div>   
                        </div>
  </div>
                    
               </div>
                    </div>

                    <div id="Tab-12">
                        <div id="CallToDoctor">
                            <div class="row">
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <asp:Label ID="lbl_Department" runat="server" Text="Department"></asp:Label>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel10" style="outline: none;">
                                        <ContentTemplate>
                                            <asp:DropDownList ID="ddl_Department" runat="server"  onchange="Get_Doctor_Info();" AppendDataBoundItems="true"></asp:DropDownList>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <div class="row" style="margin-top:1%" >
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lblCallToDoctor" Text="Select Doctor To Call"></asp:Label>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel4" style="outline: none;">
                                        <Triggers>
                                        </Triggers>
                                        <ContentTemplate>
                                            <asp:DropDownList ID="ddlCallToDoctor" runat="server" onchange="Get_Doctor_MobileInfo();" AppendDataBoundItems="true"></asp:DropDownList>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                            </div>
                            <div class="row" style="margin-top:1%">
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lblMobileNo" Text="Mobile No"></asp:Label>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:TextBox runat="server" ID="txtMobileNo"></asp:TextBox>
                            </div>
                                </div>
                            <div class="row">
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <asp:Label ID="lblSmsToDoctor" runat="server" Text="SMS To Doctor"></asp:Label>
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <input type="button" value="Send" class="btn btn-primry" id="btnPrintAdmisionDetail" onclick="" />
                                    </div>
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <input type="button" class="btn-gray" onclick="DotcorCallUnit()" value="Print"  />
                                </div>                               
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <input type="button" class="btn btn-primry" value="New Doctor Note" onclick="NewDoctorNote()" />
                                </div>
                                </div>
                                 </div>
                                  <div style="position: relative; top: -200px; left: 25%; width: 500px;">
                            <h2 style="text-align:left;">Doctor Notes</h2>
                            <asp:TextBox TextMode="MultiLine" runat="server" id="txtCallToDoctor" style="height: 139px; font-size: 18px; font-weight: Bold;"></asp:TextBox>
                            <input type="hidden" id="hdnEmergencyDocId" value="" />
                        </div>


                        <div style="margin-left: 0px; margin-top: -130px; width: 1214px; overflow: scroll; height: 210px; max-height: 400px !important;">
                            <table id="tblDoctorNotes" class="table" style="width: 100% !important;">
                                <thead>
                                    <tr>
                                        <td colspan="12">
                                            <div id="DoctorHistoryHeader">
                                                <h2 class="heading">Previous History</h2>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th style="width: 158px">Department</th>
                                        <th style="width: 110px;">Doctor To Call</th>
                                        <th style="width: 135px">Doctor Mobile #</th>
                                        <th>Doctor Notes</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>


                    <div id="Tab-5">
                        <div id="Discharge_Detail" style="width: 100%;">
                            <table style="width: 100% !important">
                                <tr>
                                    <td>
                                        <table style="width: 100% !important">
                                            <tr>
                                                <td colspan="4">
                                                    <h2>Discharge Details : </h2>
                                                </td>
                                            </tr>
                                            <tr>
                                           
                                                <td style="width:20%;padding:5px;">
                                                    <asp:Label ID="lblDischarge_By" runat="server" Text="Advise By"></asp:Label>
                                                      <asp:UpdatePanel runat="server" ID="UpdatePanel2">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:DropDownList ID="ddlDischarge_By" runat="server" Width="167px" AppendDataBoundItems="true" ></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                                </td>
                                           
                                                <td style="width:20%;padding:5px;">
                                                    <asp:Label ID="lblDischarge_On" runat="server" Text="Discharged Date "></asp:Label>
                                                    <asp:TextBox ID="txtDischarge_On" runat="server" disabled="disabled"></asp:TextBox>
                                                </td>
                                                <td style="width:20%;padding:5px;">
                                                      <asp:label runat="server" ID="lblDiagnosis" Text="Diagnosis"></asp:label>
                                                    <asp:TextBox runat="server" style="width: 100% !important;height: 35px !important;" ID="txtDiagnosis" TextMode="MultiLine"></asp:TextBox>
                                                </td>
                                                   <td style="width:20%;padding:5px;">
                                                     <asp:Label ID="lblPrevention_Precaution" runat="server" Text="Advice "></asp:Label>
                                                    <asp:TextBox ID="txtPrevention_Precaution"  style="width: 100% !important;height: 35px !important;" runat="server" TextMode="MultiLine"  ></asp:TextBox>
                                                </td>
                                                   <td style="width:20%;padding:5px;">
                                                    <asp:Label ID="Label6" runat="server" Text="Follow Up"></asp:Label>
                                                    <asp:TextBox ID="txtNext_Visit" runat="server" ></asp:TextBox>
                                                </td>
                                            </tr>
                                         
                                            <tr>
                                          
                                                <td  style="width:20%;padding:5px;">
                                                     <asp:Label ID="lblTreatmentAtDischarge" runat="server" Text="Treatment At Discharge"></asp:Label>
                                                    <asp:TextBox ID="txtTreatmentAtDischarge" runat="server" style="width: 100% !important;height: 35px !important;"  TextMode="MultiLine" ></asp:TextBox>
                                                </td>

                                                <td  style="width:20%;padding:5px;">
                                                    <asp:Label ID="lblFollowUpPlanInstructions" runat="server" Text="Follow Up Plan & Instructions"></asp:Label>
                                                    <asp:TextBox  ID="txtFollowUpPlanInstructions" style="width: 100% !important;height: 35px !important;"  runat="server" TextMode="MultiLine"></asp:TextBox>
                                                </td >
                                                    <td  style="width:20%;padding:5px;">
                                                     <asp:Label ID="lblProcRecommended" runat="server" Text="Procedure Recommended"></asp:Label>
                                                    <asp:TextBox ID="txtProcedureRecommended" style="width: 100% !important;height: 35px !important;"  runat="server" TextMode="MultiLine"  ></asp:TextBox>
                                                </td>

                                                <td  style="width:20%;padding:5px;">
                                                      <asp:Label ID="lblDischargeStatus" runat="server" Text="Discharge Status"></asp:Label>
                                                    <asp:DropDownList runat="server" ID="ddlDischargeStatus" AppendDataBoundItems="true"></asp:DropDownList>
                                                </td>
                                                            
                                                <td  style="width:20%;padding:5px;">
                                                      <asp:Label runat="server" ID="lblCauseOfReferral" Text="Cause Of Referral"></asp:Label>
                                                    <asp:TextBox  runat="server" style="width: 100% !important;height: 35px !important;" ID="txtCauseOfReferral" TextMode="MultiLine"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                 <td style="width: 20%; padding: 5px;">
                                                    <asp:Label ID="lblDischargeTemplate" runat="server" Text="Template"></asp:Label>
                                                    <select id="ddlDischargeTemplate" class="form-select" onchange="LoadDischargeTemplateMedicine()" style="width: 100%;">
                                                        <option value="">Select Template</option>
                                                    </select>
                                                </td>
                                                <td style="width:20%;padding:5px;">
                                                     <asp:Label ID="lblReferredTo" runat="server" Text="Referred To"></asp:Label>
                                                    <asp:DropDownList runat="server" ID="ddlReferredTo" AppendDataBoundItems="true"></asp:DropDownList>
                                                </td>
                                                 <td>
                                                   <asp:Label ID="Label10" runat="server" Text="Discharge Slip" ></asp:Label>
                                                    <asp:CheckBox ID="cbDicharg_Slip" style="margin-top: 9px;width: 58px !important;" runat="server"  ></asp:CheckBox>
                                                </td>
                                                <td>
                                                    <asp:Label ID="lbldeath" runat="server" Text="Death" ></asp:Label>
                                                      <input type="checkbox" style="margin-top: 9px;width: 58px !important;" ID="cb_death"  runat="server" onchange="showdeathtab();" />
                                                </td>
                                                <td>
                                                    <label class="form-check-label" for="ReferOPD" style="margin-bottom: -21px;">Refer To OPD</label>
                                                    <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="ReferToOPD" ClientIDMode="Static" />
                                                </td>
                                            </tr>
                                            <tr>
                         
                                            
                                                <td class="mgTab">
                                                    <asp:Label ID="lblDeath_Certificate" runat="server" Text="Death Certificate" style="display:none"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="cbDeath_Certificate" runat="server" style="display:none"></asp:CheckBox>
                                                </td>
                                            </tr>
                                        
                                            <tr>
                                   
                                                <td>
                                                    <input type="button" class="btn btn-primry" value="Add Medicine" id="btnDischarge" onclick="AddDischageMedication(this)" style="width:55% !important" /> &nbsp   
                                                    </td>  
                                                <td>
                                                    <input type="button" id="btnDischargeSummary" class="btn-gray" value="Print" name="name" onclick="DischargeSummary();" style="width:55% !important"  disabled="disabled" /> 
                                                    </td>
                                            </tr>
                                            <tr>
                                               
                                                 <td><input type="button" id="btnDischargePrint"  value="Discharge Print" name="name" onclick="PrintInpatientReceipt();" style="width: 120px;display:none;" /></td>
                                                <td>
                                                </td>
                                             
                                                <caption>
                                                    &nbsp;
                                                </caption>
                             

                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                      
                                    </td>
                                </tr>
                            </table>
                        
                            <div>
                                <!-- Medication on Discharge Table -->
                                <div class="table-responsive" style="overflow: scroll; height: 280px;">
                                    <table class="table table-bordered" id="tblDischargeMedication">
                                        <thead>
                                            <tr>
                                                <td colspan="12">
                                                    <div id="Div7">
                                                        <h2 class="heading">Medication on Discharge</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Date</th>
                                                <th>Medicine Name</th>
                                                <th>Frequency</th>
                                                <th>Routes</th>
                                                <th>Duration</th>
                                                <th>Special Instructions</th>
                                                <th>Dosage From</th>
                                                <th>Dosage Qty</th>
                                                <th>Other Instruction</th>
                                                <th>Edit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Previous History Table -->
                                <div class="table-responsive" style="width: 100%; margin-top: 10px;">
                                    <table class="table table-bordered" id="tblDischargeNote">
                                        <thead>
                                            <tr>
                                                <td colspan="12">
                                                    <div id="Div5">
                                                        <h2 class="heading">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th style="width: 15%;">Discharge By</th>
                                                <th style="width: 14%;">Discharged Date</th>
                                                <th>Advice</th>
                                                <th>Treatment At Discharge</th>
                                                <th>Procedure Recommended</th>
                                                <th>Cause Of Referral</th>
                                                <th>Referred To</th>
                                                <th>Follow Up Instructions</th>
                                                <th>Discharge Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div id="Tab-11">                        
                        <div id="Death_Details">
                            <table style="width: 80%; margin-left: 1%;">
                                <tr>
                                    <td>
                                        <asp:label runat="server" ID="lblIdentificationMarks" Text="Identification Marks"></asp:label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtIdentificationMarks" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lblDeathCertifiedBy1" Text="">Death Certified By &nbsp;&nbsp;&nbsp;&nbsp;  1 -</asp:Label>
                                    </td>
                                    <td>                                        
                                        <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDeathCertifiedbyDr1"></asp:DropDownList>
                                    </td>                                    
                                </tr>

                                <tr>
                             
                                    <td></td>
                                    <td></td>
                                    <td>
                                        <asp:Label runat="server" ID="lblDeathCertifiedBy2" Text=""> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 2 -
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList runat="server" ID="ddlDeathCertifiedbyDr2" AppendDataBoundItems="true"></asp:DropDownList>
                                    </td> 
                                </tr>

                                <tr>
                                   <td>
                                        <asp:label runat="server" ID="lblDateofDeath" Text="Date Of Death"></asp:label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtDateofDeath"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lblBodyHandedOverTo" Text="Body Handed Over To"> 
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtBodyHandedOverTo"></asp:TextBox>
                                    </td> 
                                </tr>

                                <tr>
                                   <td>
                                        <asp:label runat="server" ID="lblTimeOfDeath" Text="Time Of Death"></asp:label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtTimeOfDeath"></asp:TextBox>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lblFamilyPersonName" Text="Family Person (Name)"> 
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtFamilyPersonName"></asp:TextBox>
                                    </td> 
                                </tr>

                                 <tr>
                                   <td>
                                        <asp:label runat="server" ID="lblPlaceOfDeath" Text="Place Of Death"></asp:label>
                                    </td>
                                    <td>
                                       <asp:DropDownList ID="ddlPlaceOfDeath" AppendDataBoundItems="true" runat="server"></asp:DropDownList>
                                    </td>
                                    <td>
                                        <asp:Label runat="server" ID="lbl_CNIC" Text="CNIC"> 
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtCNIC"></asp:TextBox>
                                    </td> 
                                </tr>

                                 <tr>
                                   <td>
                                        <asp:label runat="server" ID="lblCauseOfDeath" Text="Cause Of Death"></asp:label>
                                    </td>
                                    <td>
                                       <asp:TextBox ID="txtCause_Of_Death" runat="server" Style=""></asp:TextBox>
                                    </td>
                                       <td>
                                        <asp:Label runat="server" ID="lblRelationWithDeceased" Text="Relation with Deceased"> 
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtRelationWithDeceased"></asp:TextBox>
                                    </td>
                                   
                                </tr>

                                <tr>
                                    <td>
                                        <asp:Label runat="server" ID="lblIssuingOfficerName" Text="Issuing Officer Name"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtIssuingOfficerName"></asp:TextBox>
                                    </td>
                                     <td>
                                        <asp:Label runat="server" ID="lblCMO_Police" Text="C.M.O / Police"> 
                                        </asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox runat="server" ID="txtCMO_Police"></asp:TextBox>
                                    </td>                                   
                                </tr>
                                <tr>
                                    <td> <input type="button" style="width:50% !important" id="btnPrint" class="btn-gray" value="Print" onclick="prints();" /></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    


                    <div id="Tab-6">
                   <h2>Main Tests Department:</h2>
                <div class="row mb-3">
                    <div class="col-md-2">
                    <select id="ddlTemplateTest" class="form-select" onchange="LoadtepmlateTest()">
                        <option value="">Select Template</option>
                    </select>
                        </div>
                    <div class="col-md-2">
                        <select id="ddlMainTestDepartment" onchange="LoadTestByDepartment()" class="form-control">
                            <option value="">Select Department</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <select id="ddlTestList" class="form-control">
                        </select>
                        <div id="divRotation" style="display:none;">
                            <select id="ddlRotation" class="form-control" style="display: none;">
                            </select>
                        </div>
                        <div id="divX_Ray">
                            <select id="ddlXRayLF" class="form-control" style="display: none; margin-top: 10px;">
                                <option value="0"></option>
                                <option value="L">Left</option>
                                <option value="R">Right</option>
                            </select>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <select id="ddlInvestigationDoctor" class="form-control">
                        </select>
                    </div>
                    <div class="col-md-2">
                        <asp:TextBox ID="txtAreaOfInterest" Style="width: 100% !important; height: 35px !important" placeholder="Area of Intrest" runat="server" TextMode="MultiLine" class="form-control"></asp:TextBox>
                    </div>
                    <div class="col-md-2">
                        <input type="button" value="Add Test" class="btn btn-primry w-100" id="btnAddAllTest" onclick="AddAllTest();" />
                    </div>
                </div>
         
                
                    <div style="overflow: scroll; height: 280px;">
                        <table id="tblLabtest" class="table table-bordered table-custom tests-table">
                            <thead>
                                <tr style="position: sticky; top: 0px; z-index: 10;">
                                    <th style="width: 163px">Date</th>
                                    <th style="width: 418px;">Test Name</th>
                                    <th style="width: 71px;">Sample Received</th>
                                    <th>Result</th>
                                    <th>Area Of Interest</th>
                                    <th>Doctor Name</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="loadtest"></tbody>
                        </table>

                    </div>
                    <div style="width: 100%; overflow: scroll; height: 280px;">
                        <table class="table" id="dvHistoryTests">
                            <tr>
                                <td>
                                    <table class="table" id="tblHistoryTests">
                                        <thead>
                                            <tr>
                                                <td colspan="12">
                                                    <div id="HeaderTests">
                                                        <h2 class="heading">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Date</th>
                                               <th style="width: 84px;">Status</th>
                                                <th style="width: 418px;">Test Name</th>
                                                <th style="width: 71px;">Sample Received</th>
                                                <th>Result</th>
                                                <th>Special Tests</th>
                                                <th>Area Of Interest</th>
                                                <th>Doctor Name</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
                    
                <div id="Tab-13">
                    <h2 style="margin-left: 60px;"> Services / Procedures</h2>
                    <div class="row align-items-center mb-3">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label>Services</label>
                            <input type="text" id="txtService" name="txtService" runat="server" class="form-control" placeholder="Enter service" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6" style="margin-top:6px">
                            <label></label>
                            <input type="button" id="btnAddService" class="btn btn-primry" name="btnAddService" onclick="AddServiceOrItem()" value="Add Service" />
                        </div>
                    </div>

                    
               <div style="margin-bottom: 30px; width: 100%; overflow: scroll; height: 250px !important;">
                   <table class="table"  id="tblServices">
                       <thead>
                           <tr>
                            <th style="text-align: left;">Date Time</th>
                            <th style="text-align: left;">Services / Procedure</th>
                            <th style="text-align: left;">User Name</th>
                            <th style="text-align: left;">Actions</th>
                           </tr>
                       </thead>
                       <tbody>
                       </tbody>
                   </table>
               </div> 
                           
            <div style="width: 100%; overflow: scroll; height: 300px !important;">
                <table class="table" id="tblServicesHistory">
                    <thead>
                        <tr>
                            <td colspan="12">
                                <div id="ServicesHistoryHeader">
                                    <h2 class="heading">Previous History</h2>
                                </div>
                            </td>
                        </tr>
                        <tr>                            
                            <th style="text-align: left;">Date Time</th>
                            <th style="text-align: left;">Services / Procedure</th>
                            <th style="text-align: left;">User Name</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
               </div>

               <div id="Tab-9">
                        <h2>Examination Details : </h2>
                        <div class="row">
                            <div class="col-lg-4 col-md-4 col-sm-6">
                                    <table class="table table-bordered" style="width: 100%;border: 1px solid #ccc; margin-top: 10px;">
                                        <tr>
                                            <td colspan="3">
                                                <h4>CVS:</h4>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblHeartSound" Text="Heart Sound"></asp:Label>
                                            </td>
                                            <td  style="white-space: nowrap;">
                                                 <label id="Label12" for="ctl00_MainContent_HeartSound1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                                <input type="radio" id="HeartSound1" runat="server" style="vertical-align: middle;" name="HeartSound" value="True" />
                                               
                                            </td>
                                            <td  style="white-space: nowrap;">
                                                  <label id="Label16" for="ctl00_MainContent_HeartSound2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                <input type="radio" id="HeartSound2" runat="server" style="vertical-align: middle;" name="HeartSound" value="False" />
                                              
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblArrhythmias" Text="Arrhythmias"></asp:Label>
                                            </td>
                                            <td  style="white-space: nowrap;">
                                                 <label id="Label18" for="ctl00_MainContent_Arrhythmias1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                                <input type="radio" id="Arrhythmias1" runat="server" style="vertical-align: middle;" name="Arrhythmias" value="True" />
                                               
                                            </td>
                                            <td  style="white-space: nowrap;">
                                                  <label id="Label20" for="ctl00_MainContent_Arrhythmias2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                <input type="radio" id="Arrhythmias2" style="vertical-align: middle;" runat="server" name="Arrhythmias" value="False" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblMurmur" Text="Murmur"></asp:Label>
                                            </td>
                                            <td style="white-space: nowrap;">
                                                <label id="Label34" for="ctl00_MainContent_Murmur1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                                <input type="radio" id="Murmur1" runat="server" style="vertical-align: middle;" name="Murmur" value="True" />
                                                
                                            </td>
                                            <td style="white-space: nowrap;">
                                                 <label id="Label35" for="ctl00_MainContent_Murmur2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                <input type="radio" id="Murmur2" runat="server" name="Murmur" style="vertical-align: middle;" value="False" />
                                               
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblAnyOtherAddedSound" Text="Any Other Added Sound"></asp:Label>
                                            </td>
                                            <td style="white-space: nowrap;">
                                                 <label id="Label37" for="ctl00_MainContent_AnyOtherAddedSound1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                                <input type="radio" id="AnyOtherAddedSound1" runat="server" style="vertical-align: middle;" name="AnyOtherAddedSound" value="True" />
                                               
                                            </td>
                                            <td style="white-space: nowrap;">
                                                    <label id="Label38" for="ctl00_MainContent_AnyOtherAddedSound2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                <input type="radio" id="AnyOtherAddedSound2" runat="server" style="vertical-align: middle;" name="AnyOtherAddedSound" value="False" />
                                            
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <asp:Label runat="server" ID="lblAnyOtherFindings" Text="Any Other Findings"></asp:Label>
                                            </td>
                                            <td style="white-space: nowrap;">
                                                <label id="Label39" for="ctl00_MainContent_AnyOtherFindings1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                <input type="radio" id="AnyOtherFindings1" runat="server" name="AnyOtherFindings" style="vertical-align: middle;" value="True" />
                                                
                                            </td>
                                            <td style="white-space: nowrap;">
                                                 <label id="Label42" for="ctl00_MainContent_AnyOtherFindings2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                <input type="radio" id="AnyOtherFindings2" runat="server" style="vertical-align: middle;" name="AnyOtherFindings" value="False" />
                                               
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <asp:TextBox ID="TextBoxCvs" Style="height:146px" runat="server" TextMode="MultiLine" class="form-control"></asp:TextBox>
                                            </td>                                           
                                        </tr>
                                    </table>
                            </div>
                            <div class="col-lg-4 col-md-4 col-sm-6">
                            <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td colspan="3">
                                            <h4>GCS:</h4>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label1" runat="server" Text="Eye Opening Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="ctl00_MainContent_txtEOR" runat="server" TabIndex="1" onchange="ROPFunction()" Style="width: 100%;"></asp:TextBox>
                                        </td>
                                        <td style="text-align: center;">
                                            <!-- This could be for validation or additional actions -->
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label2" runat="server" Text="Motor Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtMR" runat="server" TabIndex="2" onchange="MRFunction()" Style="width: 100%;"></asp:TextBox>
                                        </td>
                                        <td style="text-align: center;">
                                            <!-- This could be for validation or additional actions -->
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label4" runat="server" Text="Verbal Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtVR" runat="server" TabIndex="3" onchange="VRFunction()" Style="width: 100%;"></asp:TextBox>
                                        </td>
                                        <td style="text-align: center;">
                                            <!-- This could be for validation or additional actions -->
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label89" runat="server" Text="Accumulated" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtAcc" runat="server" TabIndex="4" disabled="disabled" Style="width: 100%;"></asp:TextBox>
                                        </td>
                                        <td style="text-align: center;">
                                            <!-- This could be for validation or additional actions -->
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblCranialNerves" Text="Cranial Nerves"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_CranialNerves1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                            <input type="radio" id="CranialNerves1" runat="server" name="CranialNerves" value="True" style="vertical-align: middle;" />
                                           
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_CranialNerves2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                            <input type="radio" id="CranialNerves2" runat="server" name="CranialNerves" value="False" style="vertical-align: middle;" />
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblSignsOfMeningism" Text="Signs Of Meningism" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                              <label for="ctl00_MainContent_SignsOfMeningism1" style="vertical-align: middle;" runat="server" title="True">y</label>
                                            <input type="radio" id="SignsOfMeningism1" runat="server" name="SignsOfMeningism" value="True" style="vertical-align: middle;" />
                                          
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_SignsOfMeningism2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="SignsOfMeningism2" runat="server" name="SignsOfMeningism" value="False" style="vertical-align: middle;" />
                                           
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <asp:TextBox runat="server" ID="txtFurtherExplanation" TextMode="MultiLine" Style="width: 100%; height: 60px;"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>

                       </div>  
                            <div class="col-lg-4 col-md-4 col-sm-6">
                             <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td colspan="3">
                                            <h4>General Physical Examination:</h4>
                                        </td>
                                    </tr>
    
                                    <!-- Jaundice -->
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblJondus" runat="server" Text="Jaundice"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_Jondus1" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Jondus1" runat="server" name="Jondus" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_Jondus2" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Jondus2" runat="server" name="Jondus" value="False" style="vertical-align: middle;" />
                                           
                                        </td>
                                    </tr>

                                    <!-- Pallor -->
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblPallor" runat="server" Text="Pallor"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_Pallor1" title="True">Y</label>
                                            <input type="radio" id="Pallor1" style="vertical-align: middle;" runat="server" name="Pallor" value="True"  />
                                           
                                        </td>
                                        <td style="white-space: nowrap;">
                                                <label for="ctl00_MainContent_Pallor2" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Pallor2" runat="server" name="Pallor" value="False" style="vertical-align: middle;" />
                                        
                                        </td>
                                    </tr>

                                    <!-- Dehydration -->
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblDehydration" runat="server" Text="Dehydration"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                               <label for="ctl00_MainContent_Dehydration1" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Dehydration1" runat="server" name="Dehydration" value="True" style="vertical-align: middle;" />
                                         
                                        </td>
                                        <td style="white-space: nowrap;">
                                              <label for="ctl00_MainContent_Dehydration2" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Dehydration2" runat="server" name="Dehydration" value="False" style="vertical-align: middle;" />
                                          
                                        </td>
                                    </tr>

                                    <!-- GCS Oriented -->
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblGCSOrientation" runat="server" Text="GCS Oriented"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_GCSOrientation1" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="GCSOrientation1" runat="server" name="GCSOrientation" value="True" style="vertical-align: middle;" />
                                           
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_GCSOrientation2" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="GCSOrientation2" runat="server" name="GCSOrientation" value="False" style="vertical-align: middle;" />
                                           
                                        </td>
                                    </tr>

                                    <!-- Conscious / Oriented -->
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblConsciousOrientely" runat="server" Text="Conscious / Oriented"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_ConsciousOrientely1" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="ConsciousOrientely1" runat="server" name="ConsciousOrientely" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label for="ctl00_MainContent_ConsciousOrientely2" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="ConsciousOrientely2" runat="server" name="ConsciousOrientely" value="False" style="vertical-align: middle;" />
                                           
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <asp:TextBox ID="TextBoxGpe" runat="server" TextMode="MultiLine" Style="height:144px" placeholder="Enter GPE Details" ></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                           
                        </div>
                   <div class="row">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                                <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                     <tr>
                                        <td><h4>RESP:</h4></td>
                                    </tr>
                                    <%-- NVB starts--%>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblNVB" Text="NVB"></asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label ID="Label43" runat="server" Text="R"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_NVB_Right1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="NVB_Right1" runat="server" name="NVB_Right" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_NVB_Right2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="NVB_Right2" runat="server" name="NVB_Right" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>

                                    <tr>
                                        <td>
                                            &nbsp;
                                        </td>
                                        <td>
                                            <asp:Label ID="Label46" runat="server" Text="L"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label47" for="ctl00_MainContent_NVB_Left1" runat="server" title="True" style="vertical-align: middle;">Y</label>                                           
                                            <input type="radio" id="NVB_Left1" runat="server" name="NVB_Left" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">                                           
                                            <label id="Label48" for="ctl00_MainContent_NVB_Left2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="NVB_Left2" runat="server" name="NVB_Left" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>


                                    <%-- Crepitation starts--%>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblCrepitation" Text="Crepitation"></asp:Label>
                                            &nbsp;
                                        </td>
                                        <td>
                                            <asp:Label ID="Label49" runat="server" Text="R"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label50" for="ctl00_MainContent_Crepitation_Right1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Crepitation_Right1" runat="server" name="Crepitation_Right" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label51" for="ctl00_MainContent_Crepitation_Right2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="Crepitation_Right2" runat="server" name="Crepitation_Right" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>

                                   
                                    <tr>
                                        <td>&nbsp;
                                        </td>
                                        <td>
                                            <asp:Label ID="Label52" runat="server" Text="L"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label53" for="ctl00_MainContent_Crepitation_Left1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Crepitation_Left1" runat="server" name="Crepitation_Left" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label54" for="ctl00_MainContent_Crepitation_Left2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="Crepitation_Left2" runat="server" name="Crepitation_Left" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>

                             
                                     <%-- Crepitation ends--%>

                                    <tr>
                                        <td>
                                            <asp:Label ID="lblWheeze" runat="server" Text="Wheeze"></asp:Label>
                                        </td>
                                        <td>

                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label55" for="ctl00_MainContent_Wheeze1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Wheeze1" runat="server" name="Wheeze" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label56" for="ctl00_MainContent_Wheeze2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="Wheeze2" runat="server" name="Wheeze" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                

                                    <tr>
                                        <td>
                                            <asp:Label ID="lblRanchi" runat="server" Text="Ranchi"></asp:Label>
                                        </td>
                                           <td>

                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label57" for="ctl00_MainContent_Ranchi1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Ranchi1" runat="server" name="Ranchi" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label58" for="ctl00_MainContent_Ranchi2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="Ranchi2" runat="server" name="Ranchi" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>



                                    <tr>
                                        <td>
                                            <asp:Label ID="lblAnyOtherSound" runat="server" Text="Any Other Sound"></asp:Label>
                                        </td>
                                           <td>

                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label59" for="ctl00_MainContent_AnyOtherSound1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="AnyOtherSound1" runat="server" name="AnyOtherSound" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label60" for="ctl00_MainContent_AnyOtherSound2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                            <input type="radio" id="AnyOtherSound2" runat="server" name="AnyOtherSound" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>

                                     <tr>
                                        <td colspan="4"> <asp:TextBox ID="TextBoxResp" Style="height:140px" runat="server" TextMode="MultiLine"></asp:TextBox> </td>
                                    </tr>
                               
                                </table>

                                    </div>
                               <div class="col-lg-4 col-md-4 col-sm-6">
                                   <table  class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                       <tr>
                                                <td>
                                                    <h4>GIT:</h4>
                                                </td>
                                            </tr>
                                        <tr>
                                        <td>
                                            <asp:Label ID="lblAbdomenSoft" runat="server" Text="Abdomen Soft"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                               <label id="Label61" for="ctl00_MainContent_AbdomenSoft1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                             <input type="radio" id="AbdomenSoft1" runat="server" name="AbdomenSoft" value="True" style="vertical-align: middle;" />
                                                 
                                        </td>
                                        <td style="white-space: nowrap;">
                                              <label id="Label62" for="ctl00_MainContent_AbdomenSoft2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                              <input type="radio" id="AbdomenSoft2" runat="server" name="AbdomenSoft" value="False" style="vertical-align: middle;" />
                                                  
                                        </td>
                                    </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblTenderness" runat="server" Text="Tenderness"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label63" for="ctl00_MainContent_Tenderness1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                                    <input type="radio" id="Tenderness1" runat="server" name="Tenderness" value="True" style="vertical-align: middle;" />
                                                   
                                                </td>
                                                <td  style="white-space: nowrap;">
                                                    <label id="Label64" for="ctl00_MainContent_Tenderness2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                                    <input type="radio" id="Tenderness2" runat="server" name="Tenderness" value="False" style="vertical-align: middle;" />
                                                    
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblGuarding" runat="server" Text="Guarding"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                         <label id="Label65" for="ctl00_MainContent_Guarding1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                    <input type="radio" id="Guarding1" runat="server" name="Guarding" value="True" style="vertical-align: middle;" />
                                               
                                                </td>
                                                <td style="white-space: nowrap;">
                                                       <label id="Label66" for="ctl00_MainContent_Guarding2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                                    <input type="radio" id="Guarding2" runat="server" name="Guarding" value="False" style="vertical-align: middle;" />
                                                 
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblBowelSound" runat="server" Text="Bowel Sound"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                      <label id="Label67" for="ctl00_MainContent_BowelSound1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                    <input type="radio" id="BowelSound1" runat="server" name="BowelSound" value="True" style="vertical-align: middle;" />
                                                  
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label68" for="ctl00_MainContent_BowelSound2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                                    <input type="radio" id="BowelSound2" runat="server" name="BowelSound" value="False" style="vertical-align: middle;" />
                                                   
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDistention" runat="server" Text="Distention"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                    <label id="Label69" for="ctl00_MainContent_Distention1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                    <input type="radio" id="Distention1" runat="server" name="Distention" value="True" style="vertical-align: middle;" />
                                                    
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label70" for="ctl00_MainContent_Distention2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                                    <input type="radio" id="Distention2" runat="server" name="Distention" value="False" style="vertical-align: middle;" />
                                                   
                                                </td>
                                            </tr>

                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblFluidThrill" runat="server" Text="Fluid Thrill"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label71" for="ctl00_MainContent_FluidThrill1" runat="server"  style="vertical-align: middle;"  title="True">Y</label>
                                                    <input type="radio" id="FluidThrill1" runat="server" name="FluidThrill" value="True"  style="vertical-align: middle;"  />
                                                   
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label72" for="ctl00_MainContent_FluidThrill2" runat="server"  style="vertical-align: middle;"  title="False">N</label>
                                                    <input type="radio" id="FluidThrill2" runat="server" name="FluidThrill" value="False"  style="vertical-align: middle;"  />
                                                   
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblShiftingDullness" runat="server" Text="Shifting Dullness"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                       <label id="Label73" for="ctl00_MainContent_ShiftingDullness1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                    <input type="radio" id="ShiftingDullness1" runat="server" name="ShiftingDullness" value="True" style="vertical-align: middle;" />
                                                 
                                                </td >
                                                <td style="white-space: nowrap;">
                                                        <label id="Label74" for="ctl00_MainContent_ShiftingDullness2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                                    <input type="radio" id="ShiftingDullness2" runat="server" name="ShiftingDullness" value="False" style="vertical-align: middle;" />
                                                
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblEpigastriaDiscomfort" runat="server" Text="Epigastria Discomfort"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                    <label id="Label75" for="ctl00_MainContent_EpigastriaDiscomfort1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                                    <input id="EpigastriaDiscomfort1" type="radio" runat="server" name="EpigastriaDiscomfort" value="True" style="vertical-align: middle;" />
                                                    
                                                </td>
                                                <td style="white-space: nowrap;">
                                                     <label id="Label76" for="ctl00_MainContent_EpigastriaDiscomfort2" style="vertical-align: middle;" runat="server" title="False">N</label>
                                                    <input id="EpigastriaDiscomfort2" type="radio" runat="server" name="EpigastriaDiscomfort" value="False" style="vertical-align: middle;" />
                                                   
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblRetrosternalBurning" runat="server" Text="Retrosternal Burning"></asp:Label>
                                                </td>
                                                <td style="white-space: nowrap;">
                                                       <label id="Label77" for="ctl00_MainContent_RetrosternalBurning1" runat="server"  style="vertical-align: middle;" title="True">Y</label>
                                                    <input type="radio" id="RetrosternalBurning1" runat="server" name="RetrosternalBurning" value="True" style="vertical-align: middle;" />
                                                 
                                                </td>
                                                <td style="white-space: nowrap;">
                                                      <label id="Label78" for="ctl00_MainContent_RetrosternalBurning2" runat="server"  style="vertical-align: middle;" title="False">N</label>
                                                    <input type="radio" id="RetrosternalBurning2" runat="server" name="RetrosternalBurning" value="False"  style="vertical-align: middle;" />
                                                  
                                                </td>
                                            </tr>

                                            <tr>
                                
                                                        <td colspan="3"> <asp:TextBox ID="TextBoxGit" runat="server" TextMode="MultiLine"></asp:TextBox> </td>
                                       
                                            </tr>

                           </table>
                       </div> 
                       <div class="col-lg-4 col-md-4 col-sm-6">
                            <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                <tr>
                                    <td colspan="3">
                                        <h4>CNS</h4>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label runat="server" ID="lblHMFIntact" Text="HMF Intact"></asp:Label>
                                    </td>
                                    <td style="white-space: nowrap;">
                                         <label for="ctl00_MainContent_HMFIntact1" style="vertical-align: middle;" title="True">Y</label>
                                        <input type="radio" id="HMFIntact1"  runat="server" name="HMFIntact" value="True" style="vertical-align: middle;" />
                                       
                                    </td>
                                    <td style="white-space: nowrap;">
                                         <label for="ctl00_MainContent_HMFIntact2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                        <input type="radio" runat="server" id="HMFIntact2" name="HMFIntact" value="False" style="vertical-align: middle;" />
                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="3">
                                        <asp:TextBox ID="TextBoxCns" runat="server" TextMode="MultiLine" ></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                       </div>
                   </div>

                    <div>
                        <table class="table" id="tblExaminationHistory" style="display: block; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <td colspan="31">
                                                <div id="tblExaminationHistoryHeader" style="text-align:center;">
                                                    <h2 class="heading">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>HMF Intact</th>
                                            <th>Cranial Nerves</th>
                                            <th>Signs Of Meningism</th>                                   
                                            <th>Heart Sound</th>
                                            <th>Arrhythmias</th>
                                            <th>Murmur</th>                                   
                                            <th>Any Other Added Sound</th>
                                            <th>Any Other Findings</th>
                                            <th>Wheeze</th>
                                            <th>Ranchi</th>
                                            <th>Any Other Sound</th>
                                            <th>Abdomen Soft</th>
                                            <th>Tenderness</th>                                              
                                            <th>Guarding</th>                                   
                                            <th>Bowel Sound</th>
                                            <th>Distention</th>
                                            <th>Fluid Thrill</th>                                   
                                            <th>Shifting Dullness</th>
                                            <th>Epigastria Discomfort</th>
                                            <th>Retrosternal Burning</th>
                                            <th>Jondus</th>
                                            <th>Pallor</th>
                                            <th>Dehydration</th>                                   
                                            <th>GCS Orientation</th>
                                            <th>Conscious / Orientely</th>
                                            <th>NVB Right</th>                                   
                                            <th>NVB Left</th>
                                            <th>Crepitation Right</th>
                                            <th>Crepitation Left</th>
                                            <th>Further Explanation</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                    </div>                   
                    <div id="Tab-8">
                        <h2>Presenting Complaints : </h2>
                        <div id="Patientdetail" style="width: 100%">
                            <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-12">
                                 <label>Symptom</label>
                                <input type="text" name="txtSymtom" id="txtSymtom"  />
                            </div>
                                <div class="col-lg-1 col-md-4 col-sm-12">   
                                    <label>Duration</label>
                                <input type="text" name="txtDuration" id="txtDuration"  />
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-12">
                                     <label>Duration</label>                                    
                                    <select id="ddlDaysMonthsYears"></select>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-12">
                                    <label>Remarks</label>
                                    <textarea name="txtRemarks"  style="width:100%;height:33px;" id="txtRemarks" ></textarea>
                                </div>
                                <div class="col-lg-1 col-md-6 col-sm-12" style="margin-top:23px">
                                    <input type="button" id="btnAddHistory" class="btn btn-primry" value="Add" onclick="Add_SymtomRow()" />
                                    <%--<button type="button" id="btnAddHistory" class="btn btn-primry" onclick="Add_SymtomRow()">Add</button>--%>
                                </div>
                                <div class="col-lg-5 col-md-6 col-sm-12">
                                    <div id="dvtblSymtomps">
                                        <table class="table"  id="tblSymtoms">
                                            <thead>
                                                <tr>
                                                    <th style="display: none;">Row ID</th>
                                                    <th style="display: none;">Symtom ID</th>
                                                    <th >Symptom </th>
                                                    <th >Dur </th>
                                                    <th >D/M/Y</th>
                                                    <th >Remarks </th>
                                                    <th >Edit</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                                </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-6 col-sm-12">
                                    <div id="tr-heading">
                                        <a href="javascript:void(0)" onclick="new_value()" style="text-decoration: underline; color: #438eb9 ; font-size: 14px;">Add New</a>
                                    </div>
                                </div>
                            </div>
                            <div>                              
                                <div  id="Div2">
                                    <input type="text" id="txtNewSymptom" style="width: 15% !important; display: none" />
                                   <%--<button type="button" id="btnaddsym" class="btn btn-info" onclick="SymptomInsert()" style="margin-top: -6px; display: none"">Save</button>--%> 
                                    <input type="button" id="btnaddsym" class="btn btn-primry" onclick="SymptomInsert()"   style="width:7% !important; display: none" value="Save" />
                                    <div>                                       
                                    </div>
                                </div>
                            </div>

                                                     
                                <table style="margin-top: 25px; display:none;">
                                    <tbody>
                                        <tr>
                                            <td style="width: 208px;">
                                                <asp:Label ID="lblTreatmentGiven" Text="Treatment Given" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtTreatmentGiven" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                            <td style="width: 197px;">
                                                <asp:Label ID="lblClinicalSummary" Text="Clinical Summary" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtClinicalSummary" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                        </tr>
                                         <tr>
                                            <td style="width: 208px;">
                                                <asp:Label ID="lblPhysicalFinding" Text="Physical Finding" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtPhysicalFinding" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                            <td style="width: 197px;">
                                                <asp:Label ID="lblProvisionalDiagnosis" Text="Provisional Diagnosis" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtProvisionalDiagnosis" TextMode="MultiLine"></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td style="width: 208px;">
                                                <asp:Label ID="lblGeneralPhysicalExamination" Text="General Physical Examination" runat="server"></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" ID="txtGeneralPhysicalExamination" TextMode="MultiLine"></asp:TextBox>
                                            </td>                                           
                                        </tr>
                                    </tbody>
                                </table>
                            
                            <table id="tblHistory ">
                                <tr>
                                    <td colspan="2">
                                        <b>
                                            <h2>History</h2>
                                        </b>
                                    </td>
                                    <td colspan="2">
                                        <h3 style="display:none;">Referred To </h3>
                                    </td>
                                    <td>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Label ID="lbl" runat="server" Text="History Of Present Illness"></asp:Label>
                                        <asp:TextBox ID="txtHistoryOfPeresentIllness" TextMode="MultiLine" runat="server" TabIndex="1"></asp:TextBox>
                                    </td>
                                     <td colspan="2">
                                        <asp:Label ID="Label40" runat="server" Text="Vaccination History "></asp:Label>
                                          <asp:TextBox ID="txtVaccinationHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                    </td>                                                                   
                                    <td style="display:none;">
                                        <asp:Label ID="Label13" runat="server" Text="Referred To"></asp:Label>
                                         <asp:DropDownList ID="ddlPatient_Main_Category" style="display:inline-block; margin-left: 22px;" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                        </asp:DropDownList>
                                    </td>
                                    <td style="display:none;">
                                        <asp:Label ID="Label14" runat="server" Text="Referral Note"></asp:Label>
                                        <asp:TextBox ID="txtRefferNote" style="margin-left:22px;" TextMode="SingleLine" runat="server" TabIndex="22"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="d" runat="server" Text="Past Medical/Surgical History"></asp:Label>
                                        <asp:TextBox ID="txtHistoryOfPastIllness" runat="server" TextMode="MultiLine" TabIndex="2"></asp:TextBox>
                                    </td>
                                     <td colspan="2">
                                        <asp:Label ID="Label41" runat="server" Text="Any Other History "></asp:Label>
                                        <asp:TextBox ID="txtAnyOtherHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>                                                                        
                                   
                                    <td colspan="2">
                                        <asp:Label ID="Label3" runat="server" Text="Family History"></asp:Label>
                                        <asp:TextBox ID="txtHistoryOfFamily" runat="server" TextMode="MultiLine" TabIndex="3"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label5" runat="server" Text="SocioEconomic History"></asp:Label>
                                        <asp:TextBox ID="txtSocioEconomicHistory" runat="server" TextMode="MultiLine" TabIndex="4"></asp:TextBox>
                                    </td>
                                     <td colspan="2">
                                        <asp:Label ID="Label15" runat="server" Text="Birth History"></asp:Label>
                                        <asp:TextBox ID="txtBirthHistory" runat="server" TextMode="MultiLine" TabIndex="5"></asp:TextBox>
                                    </td>  
                                    <td colspan="2">
                                        <asp:Label ID="Label8" runat="server" Text="Drug History"></asp:Label>
                                        <asp:TextBox ID="txtDrugHistory" runat="server" TextMode="MultiLine" TabIndex="6"></asp:TextBox>
                                    </td>
                                </tr>                                                           
                                <tr>
                                      <td colspan="2">
                                        <asp:Label ID="Label7" runat="server" Text="Obstetric History"></asp:Label>
                                         <asp:TextBox ID="txtObstetricHistory" runat="server" TextMode="MultiLine" TabIndex="7"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label9" runat="server" Text="Allergies History"></asp:Label>
                                        <asp:TextBox ID="txtAllergiesHistory" runat="server" TextMode="MultiLine" TabIndex="9"></asp:TextBox>
                                    </td>  
                                    <td colspan="2">
                                        <asp:Label ID="Label11" runat="server" Text="Treatment History"></asp:Label>
                                        <asp:TextBox ID="txtTreatmentHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label17" runat="server" Text="Personal History"></asp:Label>
                                        <asp:TextBox ID="txtPersonalHistory" runat="server" TextMode="MultiLine" TabIndex="7"></asp:TextBox>
                                    </td>
                                </tr>                                                                           
                                <tr>
                                </tr>
                            </table>

                    

                            <div>
                                <table class="table" id="tblHistoryTabHistory" style="overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <td colspan="26">
                                                <div id="tblHistoryTabHistoryHeader">
                                                    <h2 class="heading">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date & Time</th>
                                            <th>Status</th>
                                            <th>History Of Present Illness</th>
                                            <th>Past Medical/Surgical History</th>
                                            <th>Family History </th>
                                            <th>SocioEconomic History </th>
                                            <th>Birth History</th>
                                            <th>Drug History</th>
                                            <th>Personal History</th>
                                            <th>Obstetric History </th>
                                            <th>Allergies History </th>
                                            <th>Treatment History</th>
                                            <th>Vaccination History</th>
                                            <th>Any Other History</th>
                                          
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                           
                         
                            <table style="width:100%">
                                <tr>
                                    <td>
                                      <div id="dvSyptomHistory">
                                <table class="table" id="tblSymptomHistory">
                                    <thead>
                                        <tr>
                                            <td colspan="6">
                                                <div id="Div8">
                                                    <h2 class="heading">Symptom History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th style="display: none;">Symtom ID</th>
                                            <th>Status</th>
                                            <th style="width: 183px  !important;">Symptom </th>
                                            <th>Duration </th>
                                            <th>D / M / Y</th>
                                            <th>Remarks </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                                        </td>
                                    <td>
                          
                                        </td>
                                    </tr> 
                            </table>
                         
                            <div id="dvPsychiatryHistory" style="margin: 0 auto; margin-top: 0px;display:none;">
                                <table class="table" id="tblPsychiatryHistory" style="display: block; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <td colspan="160">
                                                <div id="tblPsychiatryHeader">
                                                    <h2 style="float: left; ">Psychiatry History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date & Time</th>
                                            <th>Status</th>
                                            <th>Informant(s) </th>
                                            <th>Source Of Referral</th>
                                            <th>Neck Holding </th>
                                            <th>Walking </th>
                                            <th>Talking</th>
                                            <th>Others</th>
                                            <th>Menarche</th>
                                            <th>Menstrual</th>
                                            <th>Attachment/ Separation from Parents</th>
                                            <th>Health</th>
                                            <th>Nail Biting</th>
                                            <th>Temper Tantrums</th>
                                            <th>Bed Wetting</th>
                                            <th>Academics</th>
                                            <th>Peer Relationship</th>
                                            <th>Behaviour</th>
                                            <th>History</th>
                                            <th>Sexual History</th>
                                            <th>Substance Use</th>
                                            <th>Forensic Use</th>
                                            <th>Relationship</th>
                                            <th>Leisure Activities </th>
                                            <th>Attitude</th>
                                            <th>Prevalling Mood</th>
                                            <th>Reaction Pattren to Stress </th>
                                            <th>Religious Practices</th>
                                            <th>Father</th>
                                            <th>Mother </th>
                                            <th>Siblings</th>
                                            <th>Familial Illness</th>
                                            <th>Home Atmosphere, relationship, social class </th>
                                            <th>Actual Age</th>
                                            <th>Race</th>
                                            <th>Tattoos, body piercing and scars:</th>
                                            <th>Body Habitus</th>
                                            <th>Dress</th>
                                            <th>Hygiene </th>
                                            <th>Psychomotor Activity:</th>
                                            <th>Involuntary movements</th>
                                            <th>Dystonia &amp; EPS</th>
                                            <th>Tardive dyskinesia</th>
                                            <th>Tics</th>
                                            <th>Tremors </th>
                                            <th>Attentiveness to interview</th>
                                            <th>Eye Contact</th>
                                            <th>Level of Consciousness</th>
                                            <th>Rate</th>
                                            <th>Rhythm</th>
                                            <th>Volume </th>
                                            <th>Tone</th>
                                            <th>Modulation</th>
                                            <th>Depressed</th>
                                            <th>Elated</th>
                                            <th>Irritable</th>
                                            <th>Labile</th>
                                            <th>Incongruent</th>
                                            <th>Blunting/ Flattening/ Apathy </th>
                                            <th>Thinking/ Premeditation</th>
                                            <th>Plans</th>
                                            <th>Actions</th>
                                            <th>Preservative</th>
                                            <th>LoosAssociation</th>
                                            <th>Tangentiaility</th>
                                            <th>Circumstantiality</th>
                                            <th>Flight Ideas </th>
                                            <th>Thought Insertion</th>
                                            <th>Thought Withdrawal</th>
                                            <th>Thought Broadcasting</th>
                                            <th>Thought Control</th>
                                            <th>Dellusion</th>
                                            <th>Overvalued Ideas</th>
                                            <th>Depresonalization</th>
                                            <th>Derealization </th>
                                            <th>Obsession</th>
                                            <th>Phobies</th>
                                            <th>Homocidial Ideas</th>
                                            <th>Illusion</th>
                                            <th>Hallucination </th>
                                            <th>Orientation:Time</th>
                                            <th>Place</th>
                                            <th>Person </th>
                                            <th>Attention &amp; Concentration</th>
                                            <th>Days Of Week</th>
                                            <th>Immediate Memory</th>
                                            <th>Short Term:Recent Events</th>
                                            <th>Long Term :Remote Events</th>
                                            <th>Adress Recall After 2 Minutes</th>
                                            <th>Adress Recall After 5 Minutes</th>
                                            <th>General knowledge Questions </th>
                                            <th>Simple Arthemetic Calculation</th>
                                            <th>Abstraction /Concrete Thinking</th>
                                            <th>Insight</th>
                                             <th> Health problem</th>
                                    <th>Health caused  </th>
                                    <th>problem started</th>
                                    <th>Health course </th>
                                    <th>Health treatment </th>
                                    <th>Health effects </th>
                                    <th>PLUSE</th>
                                    <th>B.P  </th>
                                    <th>TEMPERATURE</th>
                                    <th>Weight </th>
                                    <th>Respiratory Rate</th>
                                    <th>JAUNDICE</th>
                                    <th>ANEMIA </th>
                                    <th>CYANOSIS</th>
                                    <th>CLUBBING </th>
                                    <th>JVP</th>
                                    <th>LYMPH NODES </th>
                                    <th>EDEMA </th>
                                    <th>Respiratory</th>
                                    <th>Cardiovascular</th>
                                     <th>Gastro-Intestinal: </th>
                                    <th>Observation:(Involuntary Movements / Gestures / Mannerism / Mobility)</th> 
                                    <th>Cranial Nerves: </th> 
                                    <th>Limb strength: </th> 
                                    <th>Spasticity, Flaccidity, or Fasciculations:</th> 
                                    <th>Position</th>
                                    <th>Vibration</th>
                                    <th>Stereognosis</th>
                                    <th>Pain</th>
                                    <th>Biceps</th>
                                    <th>Triceps</th>
                                    <th>Brachioradialis</th>
                                    <th>Quadriceps</th>
                                    <th>Patellar</th>
                                    <th>Achilles</th>
                                    <th>Extensor Plantar Response </th>
                                    <th>Frontal Release Reflexes </th>
                                    <th>Finger_to_nose Test </th>
                                    <th>Heel-to-shin Test </th>
                                    <th>Rapid Alternating Movements </th>
                                    <th>Gait</th>
                                    <th>Neck Rigidity</th>
                                    <th>Kerning's Sign</th>
                                    <th>Brudzinki's Sign</th>
                                    <th>Assessment Summary</th>
                                    <th>Diagnosis</th>
                                    <th>Axis I: </th>
                                    <th>Axis II: </th>
                                    <th>Axis III: </th>
                                    <th>Axis IV: </th>
                                    <th>Axis V: </th>
                                    <th>Predisposing Factors:</th>
                                    <th>Precipitating Factors: </th>
                                    <th>Prepetuating Factors: </th>
                                    <th>Investigation</th>
                                    <th>Medical</th>
                                    <th>Psychological</th>
                                    <th>Major Issues: </th>
                                    <th>Strengths and Weaknesses: </th>
                                    <th>Management Goals: </th>
                                    <th>Strategies and Interventions: </th>
                                        </tr>

                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                           
                        </div>
                    </div>
                    <div id="Tab-15">
                            <table style="width: 100%; border-collapse: collapse;">
                                <tr>
                                    <td colspan="4" style="text-align: left; padding: 10px;">
                                        <h2 style="color: red;">Discharge Note:</h2>
                                    </td>
                                </tr>
                             <tr>
                            <td  style="padding: 5px; width: 20%;">
                                <asp:Label ID="Label90" runat="server" Text="Plus Rate (Beats per Min)"></asp:Label>
                                <asp:TextBox ID="txtPulseRate" runat="server" TabIndex="1" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
                            </td>
                            <td style="padding: 5px; width: 20%;">
                                <asp:Label ID="Label91" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
                                <asp:TextBox ID="txtBPDischarge" runat="server" TabIndex="2" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
                            </td>
                            <td style="padding: 5px; width: 20%;">
                                <asp:Label ID="Label92" runat="server" Text="Rhythm"></asp:Label>
                                <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythmdischarge" Style="width: 100%; box-sizing: border-box;"></asp:DropDownList>
                            </td>
                            <td style="padding: 5px; width: 20%;">
                                <asp:Label ID="Label93" runat="server" Text="Temperature (°F)"></asp:Label>
                                <asp:TextBox ID="txtTempdisch" runat="server" TabIndex="3" Style="width: 100%; box-sizing: border-box;"></asp:TextBox>
                            </td>
                        </tr>
                                <tr>

                                    <td style="padding: 5px;width: 20%;"">
                                        <asp:label ID="Label94" runat="server" Text="Volume"></asp:label>
                                        <asp:DropDownList runat="server" ID="ddlvolumedisc" AppendDataBoundItems="true" Style="width: 100%;"></asp:DropDownList>
                                    </td>
              
                                    <td style="padding: 5px;width: 20%;"">
                                        <asp:Label ID="Label95" runat="server" Text="Respiration Rate (/min)"></asp:Label>
                                        <asp:TextBox ID="txtRespRateDesc" runat="server" TabIndex="4" Style="width: 100%;"></asp:TextBox>
                                    </td>
                                    
                                    <td style="padding: 5px;width: 20%;"">
                                        <asp:Label ID="Label96" runat="server" Text="O2 Saturation"></asp:Label>
                                        <asp:TextBox ID="txtSaturation_Oxygen2_desc" runat="server" TabIndex="2" Style="width: 100%;"></asp:TextBox>
                                    </td>
                             
                                    <td style="padding: 5px;width: 20%;"">
                                         <asp:Label ID="Label97" runat="server" Text="Others"></asp:Label>
                                        <asp:TextBox ID="txtotherecdesc" runat="server" TabIndex="2" Style="width: 100%;"></asp:TextBox>
                                    </td>
                                </tr>
                          
                                <tr>
                                      <td style="padding: 5px;">
                                          <asp:Label ID="Label98" runat="server" Text="Receiving Date & Time"></asp:Label>
                                        <asp:TextBox ID="txttxtReceiving_DateDesc" runat="server" ReadOnly="true" Style="width: 100%;"></asp:TextBox>
                                    </td>
                                  
                                    <td style="padding: 5px;">
                                         <asp:Label ID="Label99" runat="server" Text="Special Instruction"></asp:Label>
                                        <asp:TextBox ID="txtRN_Special_Instruction_Desc" runat="server" TabIndex="9" TextMode="MultiLine" Style="width: 100%; height: 35px;"></asp:TextBox>
                                    </td>
                                  <td style="padding: 5px;">
                                         <asp:TextBox ID="txtsaturationDis" runat="server" TabIndex="2" Style="width: 137px !important;  margin-left:12px;"></asp:TextBox>
                                    <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="chk_OnRoomAirDesc" Text="" />
                                    <label for="chk_OnRoomAirDesc">On Room Air</label>
                                </td>
                                <td style="padding: 5px;">
                                        <asp:TextBox ID="txtOxygen1" runat="server" TabIndex="2" Style="width: 137px !important; margin-left:12px;"></asp:TextBox>
                                    <asp:CheckBox runat="server" style="margin-top: 9px;width: 58px !important;" ID="chk_WithOxygenDesc" Text="" />
                                    <label for="chk_WithOxygenDesc">With Oxygen</label>
                                </td>
                                  
                                </tr>
                           
                            </table>

                        <table style="margin-left: -18px; margin-top: 10px;">

                            <tr>
                                <td>
                                    <table class="table" id="tblVitalParametersHistoryDesc" >
                                        <thead>
                                            <tr>
                                                <td colspan="14">
                                                    <div id="tblHistoryHeaderDesc">
                                                        <h2 class="heading">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Receiving Date & Time </th>
                                                <th style="width: 84px;">Status</th>
                                                <th>Rate_Beats</th>
                                                <th>Temperature</th>
                                                <th>BSR</th>
                                                <th>Rhythm</th>
                                                <th>Volume</th>
                                                <th>Blood Pressure</th>
                                                <th>Others </th>                                                
                                                <th>Respiration </th>
                                                <th>Instruction </th>
                                                <th>O2 Saturation</th>                                                
                                                <th>O2 Saturation_Oxygen1</th>
                                                <th>O2 Saturation_Oxygen2</th>
                                                 <th>Username</th>
                                               
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>



                    </div>
                             <div id="Tab-16" style="display: none">
                <div id="tabMedication" style="width: 100%;">
                    <div id="divHistoryMedicationNursing" style="height: 207px; overflow: scroll; width: 100%;">
                        <table class="table" style="overflow: scroll;"
                            id="tblHistoryMedicationNursing">
                            <thead>
                                <tr>
                                    <th style="width: 160px;">Date </th>
                                    <th style="width: 170px;">Medicine Name </th>
                                    <th>Dosage</th>
                                    <th>Frequency  </th>
                                    <th>Routes </th>
                                    <th style="display:none">Duration </th>
                                    <th>Doctor Name</th>
                                    <th style="WIDTH: 100PX;">Action</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <table id="tblMedicinesNursing" class="add-test" style="display: none;">
                        <tr>
                            <td style="width: 110px"><span>Medicine Name</span></td>
                            <td style="width: 234px">
                                <select id="txtMedicineName" name="txtMedicineName">
                                </select>
                            </td>
                            <td style="width: 110px"><span>Dosage</span></td>
                            <td style="width: 234px">
                            </td>
                            <td style="width: 110px"><span>Frequency </span></td>
                            <td style="width: 234px">
                           
                            </td>
                        </tr>

                        <tr>
                            <td><span>Route </span></td>
                            <td>
                           
                            </td>
                            <td><span>Duration(Days) </span></td>
                            <td>
                            </td>
                            <td style="width: 200px;"><span>Attending Paramedical Staff</span></td>
                            <td>
                            </td>
                        </tr>
                    </table>
                     <div id="Div5" style="height: 207px; overflow: scroll; width: 100%;">
                    <table style="width: 100%;">
                        <tr>
                            <td>
                                <table class="table" id="tblMedicinesListNursing">
                                    <thead>
                                        <tr>
                                            <th style="width: 160px;">Date </th>
                                            <th style="width: 170px;">Medicine Name </th>
                                            <th>Dosage</th>
                                            <th>Frequency  </th>
                                            <th>Routes </th>
                                            <th style="display:none">Duration </th>
                                            <th>Nurse Name</th>
                                              <th>Remarks</th>
                                            <th style="WIDTH: 100PX;display:none;">Edit</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </td>
                        </tr>
                    </table>
                         </div>
                </div>
            </div>
                    
                </div>
                <div class="row">
                    <div class="col-lg-1 col-md-3 col-sm-6">
                    </div> <div class="col-lg-1 col-md-3 col-sm-6">
                   </div>
                </div>
                <div style="padding-top: 20px;">
                    <div class =" col-lg-9">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" class="btn-primry"  onclick="SaveInPatientAllRecord();" value="Save" id="btnSave" /> 
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" class="btn btn-yellow" value="New" name="btnName" onclick="NewWindow()" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">                            
                        <input type="button" class="btn-gray" id="btnBackList" value="View" onclick="BackToList()" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" class="btn-primry" id="btnNewEMR" value="EMR" onclick="NewEMR()" />
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6">                   
                             <input type="button" class="btn-primry" value="Prescription" name="name" onclick="PrintoutPatient();" style="width: 200px !important" />
                        </div>
                        
                    </div>
                        </div>
                    <table>
                        <tr>
                            <td>
                              <div id="loadingimage" style="display:none">
                              <%--<asp:Image ID="image" ImageUrl="~../../../../wwwroot/images/loading.gif" runat="server" Width="32px" />--%>
                              </div>
                            </td>
                            <td>                                                                               
                                   <input type="button" id="btnBasePrint" value="Print" onclick="PrintRecord();" style="display:none;" />                                  
                            </td>
                            <td>                                 
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="BulletList" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label  ID="lblMessage" runat="server" style="display:none;" ></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>
     <div id="myModalENT" class="modal fade" role="dialog" style="margin-left: -135px;">

        <div class="modal-dialog">

            <div class="modal-content" style="width: 1217px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;pe="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">ENT</h4>
                </div>
                <div class="modal-body">
                    <h4>Throat</h4>
                    <table>
                        <tr>
                            <td>
                                <table class="test-table">
                                    <tbody>
                                        <tr>
                                            <td width="195px">IDL
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" type="text" ID="txtmidl" /></td>


                                        </tr>
                                        <tr>
                                            <td>Nose
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" type="text" ID="txtmNose" />
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>
                                                <h4>Ear</h4>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Right
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" type="text" ID="txtmRight" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>Left
                                            </td>
                                            <td>
                                                <asp:TextBox runat="server" type="text" ID="txtmLeft" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <h3>Tuning Fork Test</h3>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <h4>Rinnes</h4>
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                                <table>

                                    <tbody>
                                        <tr>
                                            <td width="50px">
                                                <h5>Right Ear</h5>
                                            </td>
                                            <td width="150 px"></td>
                                            <td width="52px">
                                                <h5>Left Ear</h5>
                                            </td>
                                            <td></td>
                                        </tr>
                                        <tr>
                                            <td>+ve
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkRightPos" />
                                            </td>
                                            <td>+ve  
                                            </td>

                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkLeftPos" />
                                            </td>

                                        </tr>
                                        <tr>
                                            <td>-ve
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkRightNeg" />

                                            </td>
                                            <td>-ve  
                                            </td>

                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkLeftNeg" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>False 
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkRightF" />
                                            </td>
                                            <td>False
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkLeftF" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>-ve
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkRightFNeg" />
                                            </td>

                                            <td>-ve  
                                            </td>

                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkLeftFNeg" />
                                            </td>

                                        </tr>
                                        <tr>
                                            <td>
                                                <h4>Webber's</h4>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>Central
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkcentral" />
                                            </td>
                                            <td>Lateralized  
                                            </td>

                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkLateralized" />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td>
                                                <h4>Investigation</h4>
                                            </td>
                                        </tr>

                                        <tr>
                                            <td>PTA
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkPTA" />
                                            </td>
                                            <td>Tympanometry  
                                            </td>
                                            <td>
                                                <asp:CheckBox runat="server" type="checkbox" ID="mchkTympanometry" />
                                            </td>
                                        </tr>
                                    </tbody>
                                </table>
                            </td>
                            <td></td>
                        </tr>
                    </table>
                     <div id="dvENTHistory" style="margin: 0 auto; margin-top: 0px;overflow :scroll">
                                <table class="table" style=" height: 30px; overflow: scroll;" id="tblENTHistory">
                                    <thead>
                                        <tr>
                                            <td colspan="20">
                                                <div id="tblENTHistoryHeader">
                                                    <h2>ENT History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date</th>
                                            <th>Status</th>
                                            <th>IDL </th>
                                            <th>Nose</th>
                                            <th>Ear Right </th>
                                            <th>Ear Left </th>
                                            <th>Rinnes Right Ear +ve</th>
                                            <th>Rinnes Right Ear -ve</th>
                                            <th>Rinnes Right Ear False</th>
                                            <th>Rinnes Right Ear -ve</th>
                                            <th>Rinnes Left Ear +ve</th>
                                            <th>Rinnes Left Ear -ve</th>
                                            <th>Rinnes Left Ear False</th>
                                            <th>Rinnes Left Ear -ve</th>
                                            <th>Webber&#39;s Central</th>
                                            <th>Webber&#39;s Lateralized</th>
                                            <th>Investigation PTA</th>
                                            <th>Tympanometry</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                </div>

                <div class="modal-footer">
                    <input type="button" id="Button1" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>

        </div>
    </div>


     <div id="PsychiatryModel" class="modal fade" role="dialog" style="width: 1080px; overflow-y: overaly; margin-left: 95px;">
        <div class="modal-dialog">

            <div class="modal-content" style="width: 1060px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Psychiatry</h4>
                </div>
                <div class="modal-body">

                    <table style="padding: 15px; width: 960px;">
                        <tr>
                            <td colspan="6">

                                <h2>Assessment History & Examination </h2>
                            </td>
                        </tr>
                    </table>
                    <div id="PsychiatryTabs">
                        <ul>
                            <li><a href="#PsychiatryTab-1">Personal History</a></li>
                            <li><a href="#PsychiatryTab-2">Pre-Morbid Personality</a></li>
                            <li><a href="#PsychiatryTab-3">Family History</a></li>
                            <li><a href="#PsychiatryTab-4">Mental State Examination</a></li>
                            <li><a href="#PsychiatryTab-5">Physical Examination</a></li>
                            <li><a href="#PsychiatryTab-6">Formulation</a></li>
                        </ul>
                        <div id="PsychiatryTab-1">
                            <table style="width: 860px; margin-top: 40px;">
                                <tr>
                                    <td>Informant(s):
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtInformant" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>Source Of Referral
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtSourceOfReferral" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4"><b>
                                        <h2>Personal History</h2>
                                    </b></td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Early Development Milestones: </h3>
                                    </td>
                                </tr>
                                <tr>

                                    <td>(a:) &nbsp; 
                                        <asp:CheckBox ID="chkNeckHolding" Text="Neck Holding" runat="server" />
                                        &nbsp;(b:) &nbsp;
                                        <asp:CheckBox ID="chkWalking" runat="server" Text="Walking" />
                                    </td>
                                    <td>(c:) &nbsp;
                                        <asp:CheckBox ID="chkTalking" runat="server" Text="Talking" />
                                        &nbsp;(d:) &nbsp;
                                        <asp:CheckBox ID="chkOthers" runat="server" Text="Others" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Menarche
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtMenarche" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>Menstrual
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtMenstrual" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Early Childhood: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;      Attachment/ Separation from Parents
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtAttachmentSeparationfromParents" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(b:) &nbsp;      Health(Serious Illness, Severe Fever, Operation)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtHealth" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Neurotic Traits:</h3>
                                    </td>
                                    <td>Nail Biting:
                                         <asp:CheckBox ID="chkNailBiting" runat="server"></asp:CheckBox>
                                        &nbsp; Temper Tantrums:
                                         <asp:CheckBox ID="chkTemperTantrums" runat="server"></asp:CheckBox>
                                        &nbsp; Bed Wetting:
                                         <asp:CheckBox ID="chkBedWetting" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Schooling: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;                    Academics
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtAcademics" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Peer Relationship
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeerRelationship" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Behaviour
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBehaviour" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Occupational: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;                    History
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtOccupationalHistory" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;                    Marital/ Relationship/ Sexual History:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtMaritalRelationshipSexualHistory" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>

                                <tr>
                                    <td>(c:) &nbsp;                    Substance Use:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtSubstanceUse" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;                    Forensic Use:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtForensicUse" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>

                            </table>
                        </div>

                        <div id="PsychiatryTab-2">
                            <table style="width: 860px;">
                                <tr>
                                    <td colspan="4">
                                        <h2>Pre-Morbid Personality: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Relationship:</td>
                                    <td>
                                        <asp:TextBox ID="txtRelationship" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Leisure Activities:</td>
                                    <td>
                                        <asp:TextBox ID="txtLeisureActivities" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Attitude to Self and Standards:</td>
                                    <td>
                                        <asp:TextBox ID="txtAttitudetoSelfandStandards" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Prevalling Mood:</td>
                                    <td>
                                        <asp:TextBox ID="txtPrevallingMood" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Reaction Pattren to Stress:</td>
                                    <td>
                                        <asp:TextBox ID="txtReactionPattrentoStress" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Religious Practices/ Attitute:</td>
                                    <td>
                                        <asp:TextBox ID="txtReligiousPracticesAttitute" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="PsychiatryTab-3">
                            <table style="width: 860px;">
                                <tr>
                                    <td colspan="4">
                                        <h2>Family History: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Father:</td>
                                    <td>
                                        <asp:TextBox ID="txtFather" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Mother:</td>
                                    <td>
                                        <asp:TextBox ID="txtMother" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Siblings:</td>
                                    <td>
                                        <asp:TextBox ID="txtSiblings" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Home Atmosphere, relationship, social class:</td>
                                    <td>
                                        <asp:TextBox ID="txtHomeAtmosphererelationshipsocialclass" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Familial Illness:</td>
                                    <td>
                                        <asp:TextBox ID="txtFamilialIllness" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                </tr>
                            </table>
                        </div>

                       <div id="PsychiatryTab-4">
                            <table style="width: 860px;">
                                <tr>
                                    <td colspan="4">
                                        <h2>MentalStateExamination: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Appearance: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Actual and apparent age:</td>
                                    <td>
                                        <asp:TextBox ID="txtActualandapparentage" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Race:</td>
                                    <td>
                                        <asp:TextBox ID="txtRace" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Tattoos, body piercing and scars:</td>
                                    <td>
                                        <asp:TextBox ID="txtTattoosbodypiercingandscars" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Body Habitus:</td>
                                    <td>
                                        <asp:TextBox ID="txtBodyHabitus" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Dress:</td>
                                    <td>
                                        <asp:TextBox ID="txtDress" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Hygiene:</td>
                                    <td>
                                        <asp:TextBox ID="txtHygiene" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Behaviour: </h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Psychomotor Activity:</td>
                                    <td>
                                        <asp:TextBox ID="txtPsychomotorActivity" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Involuntary movements:</td>
                                    <td>
                                        <asp:TextBox ID="txtInvoluntarymovements" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Dystonia & EPS:</td>
                                    <td>
                                        <asp:TextBox ID="txtDystoniaEPS" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Tardive dyskinesia:</td>
                                    <td>
                                        <asp:TextBox ID="txtTardivedyskinesia" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Tics:</td>
                                    <td>
                                        <asp:TextBox ID="txtTics" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Tremors:</td>
                                    <td>
                                        <asp:TextBox ID="txtTremors" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Co-operation: </h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Attentiveness to interview:</td>
                                    <td>
                                        <asp:TextBox ID="txtAttentivenesstointerview" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Eye Contact:</td>
                                    <td>
                                        <asp:TextBox ID="txtEyeContact" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Level of Consciousness:</td>
                                    <td>
                                        <asp:TextBox ID="txtLevelofConsciousness" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Speech of Talk: </h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Rate:</td>
                                    <td>
                                        <asp:TextBox ID="txtRate" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Rhythm:</td>
                                    <td>
                                        <asp:TextBox ID="txtRhythm" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Volume:</td>
                                    <td>
                                        <asp:TextBox ID="txtVolume" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Tone:</td>
                                    <td>
                                        <asp:TextBox ID="txtTone" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp; Modulation:</td>
                                    <td>
                                        <asp:TextBox ID="txtModulationvar" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Mood: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>(Usual Affect, Variation in Moods, Subjective/ Objective Mood) </h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Depressed:</td>
                                    <td>
                                        <asp:TextBox ID="txtDepressed" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Elated:</td>
                                    <td>
                                        <asp:TextBox ID="txtElated" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Irritable:</td>
                                    <td>
                                        <asp:TextBox ID="txtIrritable" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Labile:</td>
                                    <td>
                                        <asp:TextBox ID="txtLabile" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Incongruent:</td>
                                    <td>
                                        <asp:TextBox ID="txtIncongruent" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Blunting/ Flattening/ Apathy:</td>
                                    <td>
                                        <asp:TextBox ID="txtBluntingFlatteningApathy" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Suicidal Risk: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;      Thinking/ Premeditation:</td>
                                    <td>
                                        <asp:TextBox ID="txtThinkingPremeditation" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Plans:</td>
                                    <td>
                                        <asp:TextBox ID="txtPlans" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Actions:</td>
                                    <td>
                                        <asp:TextBox ID="txtActions" runat="server" TextMode="MultiLine"></asp:TextBox>

                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h2>Thoughts: </h2>
                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h2>Thought Process: </h2>
                                        <br />
                                        (Usual Pattren of Thinkng; Views about Self, World and Others)
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;      Preservative:</td>
                                    <td>
                                        <asp:TextBox ID="txtPreservative" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    
                                    </td>
                                    <td>(b:) &nbsp;      LoosAssociation:</td>
                                    <td>
                                        <asp:TextBox ID="txtLoosAssociation" runat="server" TextMode="MultiLine"></asp:TextBox>
                                
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Tangentiaility:</td>
                                    <td>
                                        <asp:TextBox ID="txtTangentiaility" runat="server" TextMode="MultiLine"></asp:TextBox>
                            
                                    </td>
                                    <td>(d:) &nbsp;      Circumstantiality:</td>
                                    <td>
                                        <asp:TextBox ID="txtCircumstantiality" runat="server" TextMode="MultiLine"></asp:TextBox>
                                   
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Flight of Ideas:</td>
                                    <td>
                                        <asp:TextBox ID="txtFlightofIdeas" runat="server" TextMode="MultiLine"></asp:TextBox>
                                   
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Thought Content:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Thought Insertion
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughtInsertion" runat="server" TextMode="MultiLine"></asp:TextBox>
                             
                                    </td>
                                    <td>(b:)&nbsp;Thought Withdrawal
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughtWithdrawal" runat="server" TextMode="MultiLine"></asp:TextBox>
                   
                                    </td>

                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Thought Broadcasting
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughBroadcasting" runat="server" TextMode="MultiLine"></asp:TextBox>
                     
                                    </td>
                                    <td>(d:)&nbsp;Thought Control
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughControl" runat="server" TextMode="MultiLine"></asp:TextBox>
                 
                                    </td>

                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;Dellusion:(Persecutory /Dellusion of refrence, Dellusion of control,Jealous, Erotomanic, Somatic, Grandious, Nihilistic,Bizarre, Sexual or amrous)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDellusion" runat="server" TextMode="MultiLine"></asp:TextBox>
              
                                    </td>


                                    <td>(f:)&nbsp;Overvalued Ideas
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtovervaluedideas" runat="server" TextMode="MultiLine"></asp:TextBox>
           
                                    </td>
                                </tr>
                                <tr>
                                    <td>(g:)&nbsp;Depresonalization
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDepresonalization" runat="server" TextMode="MultiLine"></asp:TextBox>
                     
                                    </td>

                                    <td>(h:)&nbsp;Derealization
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDerealization" runat="server" TextMode="MultiLine"></asp:TextBox>

                                    </td>
                                </tr>
                                <tr>
                                    <td>(i:)&nbsp;Obsession
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougObsession" runat="server" TextMode="MultiLine"></asp:TextBox>
            
                                    </td>



                                    <td>(j:)&nbsp;Phobies
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougPhobies" runat="server" TextMode="MultiLine"></asp:TextBox>
             
                                    </td>

                                </tr>
                                <tr>
                                    <td>(k:)&nbsp;Homocidial Ideas
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougHomocidialIdeas" runat="server" TextMode="MultiLine"></asp:TextBox>
                           
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Perception:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Illusion</td>
                                    <td>
                                        <asp:TextBox ID="txtillusion" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:)&nbsp;Hallucination (Auditory, Visual, Olfactory, Gustatory, Tactile)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtHallucinationAuditoryVisualOlfactoryGustatoryTactile" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Cognitive Status: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Orientation:Time
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtorientationtime" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>


                                    <td>(b:)&nbsp;Place
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtplace" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Person
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtperson" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:)&nbsp;Attention & Concentration:Serial-7 Test
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtAttentionConcentrationSerial7Test" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;Or Days Of Week:(Reverse Order)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtOrDaysOfWeekReverseOrder" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p>Memory:</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp; Immediate Memory
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtImmediatememory" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                    <td>(b:)&nbsp;Short Term:Recent Events
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtshorttermrecentevents" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>


                                </tr>
                                <tr>

                                    <td>(c:)&nbsp;Adress Recall After 2 Minutes
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtadressrecallafter2minutes" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                    <td>(d:)&nbsp; Long Term :Remote Events
                                    </td>
                                    <td>
                                        <asp:TextBox ID="longtermremoteevents" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(e:)&nbsp; Adress Recall After 5 Minutes
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtadressrecallafter5minues" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p><i>General Infomation / Intelligence</i></p>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;General knowledge Questions
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtgeneralknowledgequestion" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:)&nbsp;Simple Arthemetic Calculation
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtsimplearthemeticcalculation" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Abstraction /Concrete Thinking
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtabstrationconcertethinking" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>(a:)&nbsp;Insight:</h3>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtinsight" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Health Belief Model:</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;What name you give to your problem?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Problem" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(b:)&nbsp;What you think what caused your problem?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Caused" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;What you think how it started?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Started" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(d:)&nbsp;What you think about the course the disease will take?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Course" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;What type of treatment you prefer to take?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Treatment" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(f:)&nbsp;What will be effects of your disease on others around you?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Effects" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                            </table>
                        </div>

                        <div id="PsychiatryTab-5">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;">PLUSE</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_Pluse" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">B.P</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_BP" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">TEMPERATURE</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_Temperature" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Weight</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Weight" runat="server"></asp:TextBox></td>
                                    <td>Respiratory Rate</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_RespiratoryRate" runat="server"></asp:TextBox></td>
                                    <td>JAUNDICE</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Jaundice" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>ANEMIA</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Anemia" runat="server"></asp:TextBox></td>
                                    <td>CYANOSIS</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cyanosis" runat="server"></asp:TextBox></td>
                                    <td>CLUBBING</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Clubbing" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>JVP</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_JVP" runat="server"></asp:TextBox></td>
                                    <td>LYMPH NODES</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_LymphNodes" runat="server"></asp:TextBox></td>
                                    <td>EDEMA</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Edema" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>SYSTEMATIC EXAMINATION:</h2>
                                    </td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Respiratory:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Respiratory" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Cardiovascular:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cardiovascular" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Gastro-Intestinal:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Gastro_Intestinal" runat="server" TextMode="MultiLine"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>Cns Examiniation:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Observation:(Involuntary Movements / Gestures / Mannerism / Mobility)</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Observation" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Cranial Nerves:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cranial_Nerves" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td colspan="6">
                                        <h3>Motor System:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Limb strength:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Limb_Strength" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Spasticity, Flaccidity, or Fasciculations:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Spasticity" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>SENSORY SYSTEM:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Position</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Position" runat="server"></asp:TextBox></td>
                                    <td>Vibration</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Vibration" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Stereognosis</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Stereognosis" runat="server"></asp:TextBox></td>
                                    <td>Pain</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Pain" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>REFLEXES:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Biceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Biceps" runat="server"></asp:TextBox></td>
                                    <td>Triceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Triceps" runat="server"></asp:TextBox></td>
                                    <td>Brachioradialis</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Brachioradialis" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Quadriceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Quadriceps" runat="server"></asp:TextBox></td>
                                    <td>Patellar</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Patellar" runat="server"></asp:TextBox></td>
                                    <td>Achilles</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Achilles" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Extensor Plantar Response</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Extensor" runat="server"></asp:TextBox></td>
                                    <td>Frontal Release Reflexes</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Frontal" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>CEREBELLAR SYSTEM:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Finger_to_nose Test</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Finger" runat="server"></asp:TextBox></td>
                                    <td>Heel-to-shin Test</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Heel" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Rapid Alternating Movements</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Movements" runat="server"></asp:TextBox></td>
                                    <td>Gait</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Gait" runat="server"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td colspan="6">
                                        <h2>SIGNS OF MENINGEAL IRRITATION:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp; 
                                        <asp:CheckBox ID="chkPE_Neck_Rigidity" Text="Neck Rigidity" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>(b:) &nbsp; 
                                        <asp:CheckBox ID="chkPE_Kerning_Sign" Text="Kerning's Sign" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp; 
                                        <asp:CheckBox ID="chkPE_Brudzinki_Sign" Text="Brudzinki's Sign" runat="server" />
                                    </td>
                                </tr>

                            </table>
                        </div>

                        <div id="PsychiatryTab-6">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 200px;">
                                        <h4>Summary:</h4>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Summary" runat="server" TextMode="MultiLine" Width="400px" Height="80px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>
                                        <h4>Diagnosis:</h4>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Diagnosis" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis I:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisI" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Axis II:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisII" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis III:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisIII" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis IV:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisIV" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Axis V:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisV" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>
                                        <h4>Causation:</h4>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Predisposing Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PredisposingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Precipitating Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PrecipitatingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Prepetuating Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PrepetuatingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <h3>MANAGEMENT PLAN:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Investigation:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Investigation" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Treatment Plan:</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Medical:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Medical" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Psychological:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Psychological" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <h3>Psychosocial Management:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Major Issues:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Major_Issues" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Strengths and Weaknesses:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Strengths" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Management Goals:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Goals" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Strategies and Interventions:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Strategies" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>

                            </table>
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <input type="button" id="Button4" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
    <div id="EyeModel" class="modal fade" role="dialog" style="margin-left: 267px;">

        <div class="modal-dialog">


            <div class="modal-content" style="width: 729px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h2 class="modal-title">Eye</h2>
                </div>
                <div class="modal-body">

                    <div>
                        <table style="width: 586px;">
                            <tr>
                                <td>Eye Main Type
                                </td>
                                <td>Eye Sub Type
                                </td>
                                <td>Right  Eye 
                                </td>
                                <td>Left Eye  
                                </td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>
                                    <select id="ddlEyeMainType"></select>
                                </td>
                                <td>
                                    <select id="ddlEyeSubType"></select>
                                </td>
                                <td>
                                    <input type="text" id="txtRightEye" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtLeftEye" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="button" value="Add" id="btnAddEye" style="margin-top: -3px; width: 60px !important;" onclick="AddEyeRow()" />
                                </td>
                            </tr>
                        </table>
                        <div id="Div9" style=" overflow:scroll;width: 703px;">
                        <table class="table" id="tblEyes">
                            <thead>
                                <th>Eye Main Type</th>
                                <th>Eye Sub Type</th>
                                <th>Right Eye</th>
                                <th>Left Eye</th>
                                <th>Actions</th>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                            </div>

                          <div id="dvEyeHistory" style=" overflow:scroll;width: 703px;">
                                <table class="table" style="width: 688px; height: 30px; overflow: scroll;" id="tblEyesHistory">
                                    <thead>
                                        <tr>
                                            <td colspan="21">
                                                <div id="EyeHistoryHeader">
                                                    <h2>Eye History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                             <th>Status</th>
                                            <th>Eye Main Type</th>
                                            <th>Eye Sub Type</th>
                                            <th>Right Eye</th>
                                            <th>Left Eye</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                    </div>


                </div>
                <div class="modal-footer">
                    <input type="button" id="Button3" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>

        </div>
    </div>
    <div id="myModalDerma" class="modal fade" role="dialog" style="margin-left:-135px;">

        <div class="modal-dialog">

            <div class="modal-content" style="width: 1293px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Derma</h4>
                </div>
                <div class="modal-body">
                    <h4>Skin</h4>
                   

                    <table class="test-table">
                        <tbody>
                            <tr>
                                <td width="100px"></td>
                                <td width="120px">Face
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaFace" /></td>


                            </tr>
                            <tr>
                                <td></td>
                                <td>Neck
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNeck" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Trunk
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaTrunk" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Upper Limb
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaUpperLimb" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Lower Limb
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaLowerLimb" />
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp  </td>
                                <td>&nbsp   </td>
                                <td>&nbsp   </td>
                            </tr>
                            <tr>
                                <td>&nbsp  </td>
                                <td>&nbsp   </td>
                                <td>&nbsp   </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>

                        <tbody>
                            <tr>
                                <td width="90px">Flexures
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaFlexures" />
                                </td>
                            </tr>
                            <tr>
                                <td>Genitalias
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaGenitalias" />
                                </td>
                            </tr>
                            <tr>
                                <td>Hair
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaHair" />
                                </td>
                            </tr>
                            <tr>
                                <td>Nail
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNail" />
                                </td>
                            </tr>
                            <tr>
                                <td>Mucous Membrane
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaMucousMembrane" />
                                </td>
                            </tr>
                            <tr>
                                <td>Eyes
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaEyes" />
                                </td>
                            </tr>
                            <tr>
                                <td>Ears
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaEars" />
                                </td>
                            </tr>
                            <tr>
                                <td>Nose
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNose" />
                                </td>
                            </tr>
                            <tr>
                                <td>Lips
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaLips" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                     <div id="dvDermaHistory" style="margin: 0 auto; margin-top: 0px;">
                                <table class="table" id="tblDermaHistory" style="display: block; overflow: scroll;     height: 305px;">
                                    <thead>
                                        <tr>
                                            <td colspan="20">
                                                <div id="tblDermaHistoryHeader">
                                                    <h2 style="margin-left: -244px;">Derma History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date</th>
                                            <th>Status</th>
                                            <th>DermaFace </th>
                                            <th>DermaNeck</th>
                                            <th>DermaTrunk </th>
                                            <th>DermaUpperLimb </th>
                                            <th>DermaLowerLimb</th>
                                            <th>DermaFlexures</th>
                                            <th>DermaGenitalias</th>
                                            <th>DermaHair</th>
                                            <th>DermaNail</th>
                                            <th>DermaMucousMembrane</th>
                                            <th>DermaEyes</th>
                                            <th>DermaEars</th>
                                            <th>DermaNose</th>
                                            <th>DermaLips</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>


                </div>

                <div class="modal-footer">
                    <input type="button" id="Button2" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>

        </div>
    </div>
  
      <div id="PrintRecommendedMaecieneReport" style="display: none;">
      
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
                <%--<img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Teaching  Hospital    <br />
                    35KM Ferozepur Rd Lahore  phone: 0492 45109-6 <br />
                   
                   

                </div>
            </div>

        </div>
          
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PATIENT TEST DETAIL</b>
        </div>
        <table class="printtable">
            <tr>
                 <td style="width:150px;"><strong>MR No.</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTMMRNo"></span></div></td>  
              
                     <td style="width:150px;"><strong>Name</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMName"></span></div></td>  
             
                 <td style="width:150px;"><strong>Age</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMAAge"></span></div></td>  
            </tr>
            <tr>
                 <td style="width:150px;"><strong>Gender</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTMAGender"></span></div></td>  
                
       
                <td style="width:150px;"><strong>Contact</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMContact"></span></div></td>  

                 <td style="width:150px;"><strong>CNIC</strong></td>
                <td style="width:300px;"> <div class="underline"><span id="lblTMCNIC"></span></div></td>  

            </tr>
            <tr> 
                <td style="width:100px;"><strong>Address</strong></td>
                <td style="width:300px;" colspan="3"><div class="underline"><span id="lblTMAddress"></span></div></td>  
                <td style="width:200px;"><strong>Patient Type</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTMInPatientAdmitCatagory"></span></div></td> 
            </tr>
            <tr>
                 <td style="width:100px;"><strong>Admission</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTMAdmissionDate"></span></div></td>  

                <td style="width:100px;"><strong>Dept</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMDept"></span></div></td> 

                 <td style="width:150px;"><strong>Ward</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMWard"></span></div></td> 

               
            </tr>
            <tr>
                 <td style="width:100px;"><strong>Bed No.</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTMBedNo"></span></div></td> 
            </tr>

        </table>
          <div style="border: 2px solid black; border-collapse: collapse; border-color: gray;margin-top: -2px; margin-left: 15px; width: 820px;min-height:566px" cellpadding="5" cellspacing="5"">
          <table class="table" style="overflow: scroll;width: 821px;margin-top: -5px;font-family:Calibri;" id="tblMediocationBilling">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Sr. </th>
                    <th style="width: 400px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Test Name </th>
                    <th style="width: 100px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Dosage</th>
                    <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Frequency</th>
                    <th style="width: 160px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Routes</th>
                    <th style="width: 176px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Doctor Name </th>
                </tr>
            </thead>
            <tbody id="MediocationBilltbody" class="table">
            </tbody>
        </table>
            </div>
    </div>
    
<div id="PrintRecommendedTestReport" style="display: none;">
      
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
                <%--<img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">.
                     Arif Memorial Teaching  Hospital
                    <br />

                </div>
            </div>

        </div>
          
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PATIENT TEST DETAIL</b>
        </div>
        <table class="printtable">
            <tr>
                 <td style="width:150px;"><strong>MR No.</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTMRNo"></span></div></td>  
              
                     <td style="width:150px;"><strong>Name</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTName"></span></div></td>  
             
                 <td style="width:150px;"><strong>Age</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTAAge"></span></div></td>  
            </tr>
            <tr>
                 <td style="width:150px;"><strong>Gender</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTAGender"></span></div></td>  
                
             
                <td style="width:150px;"><strong>Contact</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTContact"></span></div></td>  
               
                 <td style="width:150px;"><strong>CNIC</strong></td>
                <td style="width:300px;"> <div class="underline"><span id="lblTCNIC"></span></div></td>  
             
            </tr>
            <tr> 
                <td style="width:100px;"><strong>Address</strong></td>
                <td style="width:300px;" colspan="3"><div class="underline"><span id="lblTAddress"></span></div></td>  
                <td style="width:200px;"><strong>Patient Type</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTInPatientAdmitCatagory"></span></div></td> 
            </tr>
            <tr>
                 <td style="width:100px;"><strong>Admission</strong></td>
                <td style="width:350px;"><div class="underline"><span id="lblTAdmissionDate"></span></div></td>  
               
                <td style="width:100px;"><strong>Dept</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTDept"></span></div></td> 
             
                 <td style="width:150px;"><strong>Ward</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTWard"></span></div></td> 
              
                
                
               
            </tr>
            <tr>
                 <td style="width:100px;"><strong>Bed No.</strong></td>
                <td style="width:300px;"><div class="underline"><span id="lblTBedNo"></span></div></td> 
            </tr>
         
        </table>
          <div style="border: 2px solid black; border-collapse: collapse; border-color: gray;margin-top: -2px; margin-left: 15px; width: 820px;min-height:566px" cellpadding="5" cellspacing="5"">
          <table class="table" style="overflow: scroll;width: 821px;margin-top: -5px;font-family:Calibri;" id="tblTestBilling">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Sr. </th>

                    <th style="width: 400px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Test Name </th>
                    <th style="width: 160px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Area Of Interest</th>
 
                    
                    <th style="width: 76px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Doctor Name </th>
                    
                </tr>
            </thead>
            <tbody id="testBilltbody" class="table">
            </tbody>
        </table>
            </div>
    </div>

    <div id="PrintInPatientsAdmisionReport" style="display: none;">
      
        <div style="height: 130px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
                <%--<img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 125px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Teaching  Hospital<br />
                    35 Km Ferozpur Road Lahore <br />
                    Phone: 0492 45109-6 
                    <br />

                </div>
            </div>

        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PATIENT DETAIL</b>
        </div>
       
        <table class="printtable">
            <tr>
                <td style="width:100px;"><strong>MR No.</strong></td>
                <td><div class="underline"><span id="lblMRNo"></span></div></td>
                <td><strong>Name</strong></td>
                <td><div class="underline"><span id="lblName"></span></div></td>
                <td><strong>Father Name</strong></td>
                <td><div class="underline"><span id="lblAFatherName"></span></div></td>
                <td style="width:70px;" ><strong>Age</strong></td>
                <td><div class="underline"><span id="lblAge"></span></div></td>
            </tr>
            <tr>
                <td><strong>Address</strong></td>
                <td colspan="5"><div class="underline"><span id="lblAddress"></span></div></td>
                <td><strong>Contact</strong></td>
                <td><div class="underline" style="width:150px;"><span id="lblContact"></span></div></td>
            </tr>
            <tr>
                <td><strong>Gender</strong></td>
                <td><div class="underline"><span id="lblAGender"></span></div></td>
                <td><strong>CNIC</strong></td>
                <td><div class="underline" style="width:150px;"><span id="lblCNIC"></span></div></td>
                <td><strong>Admission Fee</strong></td>
                <td><div class="underline" style="width:150px;"><span id="lblAdmissionFeeRpt"></span></div></td>
                <td colspan="4">&nbsp;</td>
            </tr>
            <tr><td colspan="8"></td></tr>
            <tr><td colspan="8"></td></tr>
            <tr>
                <td colspan="8"><h2><center>ADMISION DETAILS</center></h2></td>
            </tr>
            <tr><td colspan="8"></td></tr>
            </table>
            <table class="printtable">
            <tr>
                <td style="width:130px;"><div class="tdtitle">Admision Date</div></td>
                <td><div class="underline"><span id="lblAdmissionDate"></span></div></td>
            </tr>
            <tr><td colspan="8"></td></tr>
            <tr>
                <td><div class="tdtitle">Department</div></td>
                <td><div class="underline"><span id="lblDept"></span></div></td>
            </tr> 
            <tr><td colspan="8"></td></tr>
            <tr>
                <td><div class="tdtitle">Ward</div></td>
                <td><div class="underline"><span id="lblWard"></span></div></td>
            </tr> 
            <tr><td colspan="8"></td></tr> 
            <tr>
                <td><div class="tdtitle">Bed No.</div></td>
                <td><div class="underline"><span id="lblBedNo"></span></div></td>
            </tr>
            <tr><td colspan="8"></td></tr>
            <tr>
                <td><div class="tdtitle">Doctor</div></td>
                <td><div class="underline"><span id="lblDoctorname"></span></div></td>
            </tr>
            <tr><td colspan="8"></td></tr>
            <tr>
                <td><div class="tdtitle">Patient Type</div></td>
                <td><div class="underline"><span id="lblInPatientAdmitCatagory"></span></div></td>
            </tr>
        </table>
      
           <footer>
        <table style="margin-top:225px; margin-left:100px; font-family:Calibri;font-weight:bold">
            <tr>
                
                <td style="width: 50px">
                    <span style="font-family:Calibri;"><b>Operator</b></span>
                </td>
                <td style="width: 50px">

                     <div class="underline" style="width: 149px;padding-left: 23px !important;"><span id="lbloperator"></span></div>
                </td>
                <td></td><td style="min-width:200px"></td>
                <td >
                    <span><b>Patient Signature:</b></span>
                </td>
                <td style="border-bottom: 1px dotted black; width: 140px"></td>
            </tr>
        </table>
   </footer>
      
    </div>
    <div id="PrintInPatientsReport" style="display:none;">
        <div style="background-color: sandybrown; height: 125px; -webkit-print-color-adjust: exact; width: 830px; margin: 0 auto;">
            <div style="padding: 5px;">
                <%--<img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="background-color: #5c93bb; width: 350px; height: 125px; margin-top: -112px; margin-left: 177px;">

                <div style="padding-top: 30px; font-size: 20px; color: white; font-weight: bold; text-align: center;">
                     Arif Memorial Teaching  Hospital  <br />
                     35 Km Ferozpur Road Lahore <br />
                     Phone: 0492 45109-6 
                    <br />
                    (Discharge Slip)
                </div>
            </div>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 1px; margin: 0 auto; height: 200px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px">Name</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -40px; margin-top: 0px; font-size: 14px">
                        <span id="ctl00_MainContent_lblNamerpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 50px; text-align: left; font-size: 20px; font-size: 14px">Age</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -15px; margin-top: 0px; font-size: 14px">
                        <span id="lblAgerpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -2px;">Gender</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; font-size: 40px; margin-left: -30px; margin-top: 0px; font-size: 14px">
                        <span id="lblGenderrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: 0px; font-size: 14px">CNIC</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: left; margin-top: 0px; font-size: 14px; line-height: 14px;">
                        <span id="lblCNICrpt"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 130px; text-align: left; margin-top: -20px; font-size: 14px">Address</h6>
                </td>
                <td colspan="3">
                    <h6 style="border-bottom: 1px dotted #000; width: 331px; text-align: left; margin-left: -40px; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="lblAddressrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -20px; font-size: 14px">Contact</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -30px; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="lblContactrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="font-size: 14px; margin-top: -20px; width: 50px;">Presentaion</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="lblPresentationrpt"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -20px; font-size: 14px">MR No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -40px; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="lblOPDNorpt"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 70px; text-align: left; margin-top: -20px; font-size: 14px">Dept</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -15px; margin-top: -20px; font-size: 14px">
                        <span id="lblDepartmentrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; margin-top: -20px; font-size: 14px">Ward</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: center; width: 125px; margin-left: -30px; margin-top: -20px; line-height: 14px; font-size: 14px;">
                        <span id="lblWardrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -20px; font-size: 14px">Bed No.</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="lblBedNorpt"></span>
                    </h6>
                </td>

            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">AdmissionDate</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-top: -20px; margin-left: -30px; font-size: 14px">
                        <span id="lblDateTimerpt"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -20px; font-size: 14px">DischargeDate</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-top: -18px; line-height: 14px; font-size: 14px;">
                        <span id="lblDischargedaterpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">Rooms</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -30px; margin-top: -18px; font-size: 14px; line-height: 14px;">
                        <span id="lblRoomsrpt"></span>
                    </h6>
                </td>
            </tr>
        </table>
        <hr style="margin-top: -20px;" />
        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; font-size: 14px">Dignosis</h6>
        <table style="margin-top: -15px;">
            <tr>
                <td></td>
                <td>
                    <h6 style="width: 740px; margin-top: -20px; font-size: 14px; color: darkgrey"><span id="txtDignosisrpt"></span></h6>
                </td>
            </tr>
        </table>
        <hr style="margin-top: -23px;" />
        <h6 style="width: 350px; margin-top: 10px; font-size: 14px;">Presenting  Complaints</h6>
        <table style="margin-top: -25px; border: 1px solid black; border-collapse: collapse; width: 810px;" cellpadding="5" cellspacing="5" id="tblPresentingComplaintsrpt">
        </table>
        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; font-size: 14px">Examination Finding </h6>
        <table style="margin-top: -15px;">
            <tr>
                <td></td>
                <td>
                    <h6 style="width: 740px; font-size: 14px; margin-top: -20px; color: darkgrey"><span id="spanExamrpt"></span></h6>
                </td>
            </tr>
        </table>
        <hr style="margin-top: -23px;" />
        <h6 style="width: 350px; margin-top: 10px; font-size: 14px;">Lab Results</h6>
        <table style="margin-top: -25px;">
            </table>
        <hr style="margin-top: -23px;" />
        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; font-size: 14px">Procedure Operation</h6>
        <table style="margin-top: -15px;">
            <tr>
                <td></td>
                <td>
                    <h6 style="width: 740px; font-size: 14px; margin-top: -20px; color: darkgrey"><span id="txtProcedurerpt"></span></h6>
                </td>
            </tr>
        </table>
        <hr style="margin-top: -23px;" />
        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; font-size: 14px">Procedure Detail</h6>
        <table style="margin-top: -15px;">
            <tr>
                <td></td>
                <td>
                    <h6 style="width: 740px; font-size: 14px; margin-top: -20px; color: darkgrey"><span id="txtProcedureDetailrpt"></span></h6>
                </td>
            </tr>
        </table>
        <hr style="margin-top: -23px;" />
        <h6 style="width: 350px; margin-top: 10px; font-size: 14px;">Treatment in Hospital </h6>
        <table style="margin-top: -25px;">
            </table>
        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; font-size: 14px">Advice</h6>
        <table style="margin-top: -15px;">
            <tr>
                <td>
                    <h6 style="width: 740px; font-size: 14px; margin-top: -20px; color: darkgrey"><span id="txtAdvicerpt"></span></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: -20px;"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: -20px;"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: -20px;"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: -20px;"></h6>
                </td>
            </tr>
        </table>
        <hr />
        <h6 style="width: 350px; margin-top: 0px; font-size: 14px;">Medication on Discharge </h6>
        <table style="margin-top: -25px; border: 1px solid black; border-collapse: collapse; width: 810px;" cellpadding="5" cellspacing="5" id="tblTestrpt">
        </table>
        <table style="margin-top: 30px; margin-left: 60px;" id="urdulineshow">
            <tr>
                <td>?????</td>
                <td>?????      
                </td>
                <td>???</td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>
                    <span>OPD</span>
                </td>
                <td>??</td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td><span id="txtFollowDate"></span> <span id="txtNext_Visit"></span></td>
                <td></td>
                <td ></td>
                <td></td>
                <td>??????</td>
            </tr>
        </table>
        <h6 style="width: 500px; margin-top: 300px; font-size: 14px; margin-left: 70px;">This is a Computer Generated Image and does not require Signature </h6>
    </div>
    <div id="myModalOrtho" class="modal fade" role="dialog">
        <div class="modal-dialog">

            <div class="modal-content" style="width: 1082px; margin-left: -73px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Ortho</h4>
                </div>
                <div class="modal-body">
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <asp:Label ID="Label19" runat="server" Text="Organ Name"></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlOrthoType" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <asp:Label ID="Label21" runat="server" Text="Organ Side"></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlOrthoSide" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <h2>History</h2>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtHistory" TextMode="MultiLine" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px"></td>
                                <td>
                                    <asp:Label ID="Label22" runat="server" Text="DM"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDM" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label23" runat="server" Text="HTN"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtHTN" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label24" runat="server" Text="IHD"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtIHD" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <h2>Examination</h2>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px"></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label25" runat="server" Text="Look"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtLook" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label26" runat="server" Text="Feel"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtFeel" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label27" runat="server" Text="Move"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtMove" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label28" runat="server" Text="Special Tests"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtSpecial_Tests" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <h3>Neurology</h3>
                                </td>
                                <td></td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px"></td>
                                <td style="width: 100px"></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label29" runat="server" Text="Sensory"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtSensory" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label30" runat="server" Text="Motor"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtMotor" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label31" runat="server" Text="Reflexes"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtReflexes" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px"></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label32" runat="server" Text="Vascular Status"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtVascularStatus" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label33" runat="server" Text="Others"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtOthers" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <input type="button" id="btnAddOrtho" name="btnAddOrtho" value="Add" onclick="insertOrtho()" /></td>
                            </tr>
                        </tbody>
                    </table>
                    <table class="table" id="tblOrtho" style="display: block; width: 1040px;">
                        <thead>
                            <tr>
                                <th>Organ Name</th>
                                <th>Organ Side</th>
                                <th>DM </th>
                                <th>HTN</th>
                                <th>IHD</th>
                                <th>Look</th>
                                <th>Feel</th>
                                <th>Move</th>
                                <th>Special Tests</th>
                                <th>Treatment History</th>
                                <th>Sensory</th>
                                <th>Motor</th>
                                <th>Reflexes</th>
                                <th>Vascular Status</th>
                                <th>Others</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" id="Button5" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
     <div id="myResultModal" class="modal fade" role="dialog">

            <div class="modal-dialog">


                <div class="modal-content" style="width: 414px; margin-left: 296px;">
                    <div class="modal-header">
                        <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">View Test Images and Report</h4>
                    </div>
                    <div class="modal-body">
                        <table>
                            <tr>
                                <td>
                                    <input type="hidden" id="type" />
                                    <input type="hidden" id="IDtest" />
                                </td>
                                <td>
                                    <div style="margin-top: -15px; margin-left: 38px;">
                                        <table border="0" cellpadding="0" cellspacing="5">
                                            <tr>
                                                <td>
                                                    <div id="errorMsg" class="formLabel" style="color: red; display: none">No Image Uploaded.</div>
                                                    <div id="dvPreview" style="white-space: nowrap; overflow-x: visible; overflow-y: hidden; width: 260px;">
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                        <input type="button" style="width: 123px; margin-left: 45px;" id="btnResultPrint" value="View Print Report" onclick="ShowReport()" />
                                        <input type="hidden" id="hdnNewFiles" />
                                    </div>
                                </td>
                            </tr>
                        </table>

                    </div>
                </div>
            </div>
        </div>

       <div id="ModelPeads" class="modal fade" role="dialog" style="width: 1080px; overflow-y: overaly; margin-left: 95px;">
        <div class="modal-dialog">

        
            <div class="modal-content" style="width: 1060px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Peads</h4>
                </div>
                <div class="modal-body">
                    <div id="PeadsTabs">
                        <ul>
                            <li><a href="#PeadsTab-2">NICU</a></li>
                            <li><a href="#PeadsTab-1">Examination</a></li>
                        </ul>
                        <div id="PeadsTab-1">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;">Weight(kg)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_weight" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">Length(cm)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_Length" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">H.C(cm)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_HC" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>General Appearance:</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_General_Appearance" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Cyanosis" Text="Cyanosis" runat="server" />
                                    </td>
                                    <td>(b:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Jaundice" Text="Jaundice" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Lethargy" Text="Lethargy" runat="server" />
                                    </td>
                                    <td>(d:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Rash" Text="Rash" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Others:</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_Others" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>Heads:</h2>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Caput" Text="Caput" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Cephalhematoma" Text="Cephalhematoma" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">Anterior Fontanelle:
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Anterioropen" Text="Open" runat="server" Checked="false" onchange="Anterioropen_CheckedChangedOpen()" />
                                        <asp:RadioButton ID="rdbPeads_AnteriorClose" Text="Closed" runat="server" Checked="false" onchange="Anterioropen_CheckedChangedClose()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>CVS:</h2>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Dextrocardia" Text="Dextrocardia" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Bulging" Text="Bulging Precordium" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Murmur" Text="Murmur" runat="server" />
                                    </td>
                                    <td>Heart Sounds
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_HeartSound" runat="server"></asp:TextBox>
                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>RESP:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Nasal" Text="Nasal Flaring" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Recessions" Text="Recessions" runat="server" />
                                    </td>
                                    <td>Added Sounds
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_AddedSounds" runat="server"></asp:TextBox>
                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>GIT:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">Abdomin:
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Flat" Text="Flat" runat="server" Checked="false" onchange="Abdomin_CheckedChangedFlat()" />
                                        </td>
                                        
                                    <td><asp:RadioButton ID="rdbPeads_Distended" Text="Distended" runat="server" Checked="false" onchange="Abdomin_CheckedChangedDistended()" /></td>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Scaphoid" Text="Scaphoid" runat="server" Checked="false" onchange="Abdomin_CheckedChangedScaphoid()" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Liver" Text="Liver: >3cm" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Spleen" Text="Spleen: >2cm" runat="server" />
                                    </td>
                                    </tr>
                                    <tr>
                                    <td>Others
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_GITOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>CNS:</h2>EmpID
                                    </td>
                                </tr>
                                 <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Sucking" Text="Sucking" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Rooting" Text="Rooting" runat="server" />
                                    </td>
                                     <td>
                                        <asp:CheckBox ID="chkPeads_Moro" Text="Moro" runat="server" />
                                    </td>
                                    <td>Others
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_CNSOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                </tr>
                            </table>
                        </div>


                          <div id="PeadsTab-2">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;"> <h3>ANTENATAL</h3></td>
                                    <td style="width: 200px;"></td>
                                       
                                    <td style="width: 110px;"></td>
                                    <td style="width: 200px;"> </td>
                                    <td style="width: 110px;"></td>
                                    <td style="width: 200px;"></td>

                                </tr>
                                <tr>
                                    <td> (i:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_FullTerm" Text="Full Term" runat="server" /></td>
                                    <td>
                                        (ii:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_PreTerm" Text="Pre Term" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Date of Delivery</td>
                                    <td><asp:TextBox ID="txtPeads_DateOfDelivery" runat="server" ></asp:TextBox></td>
                                    <td>Time of Delivery</td>
                                    <td><asp:TextBox ID="txtPeads_TimeOfDelivery" runat="server" ></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td> <asp:RadioButton ID="rdbPeads_Booked" Text="Booked" runat="server" Checked="false" onchange="Antenatal_CheckedChangedBooked()" />
                                        
                                    </td>
                                    <td><asp:RadioButton ID="rdbPeads_UnBooked" Text="UnBooked" runat="server" Checked="false" onchange="Antenatal_CheckedChangedUnBooked()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td><asp:CheckBox ID="chkPeads_DAIHandling" Text="DAI Handling" runat="server" /></td>
                                    <td><asp:CheckBox ID="chkPeads_ANTURash" Text="Rash" runat="server" /></td>
                                    <td><asp:CheckBox ID="chkPeads_PIH" Text="PIH" runat="server" /></td>
                                    <td><asp:CheckBox ID="chkPeads_GDM" Text="GDM" runat="server" /></td>
                                    <td><asp:CheckBox ID="chkPeads_Vacinated" Text="Vacinated" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Others</td>
                                    <td><asp:TextBox ID="txtPeads_ANTOthers" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td>
                                       <h3>NATAL</h3>
                                    </td>
                                    <td>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Mode of Delivery</td>
                                    <td> <asp:RadioButton ID="rdbPeads_SVD" Text="SVD" runat="server" Checked="false" onchange="Natal_CheckedChangedSVD()"  />
                                        
                                    </td>
                                    <td><asp:RadioButton ID="rdbPeads_LSCS" Text="LSCS" runat="server" Checked="false" onchange="Natal_CheckedChangedLSCS()" />
                                    </td>
                                    <td id="TDPeadsEmergency" style="display:none;"> <asp:RadioButton ID="rdbPeads_Emergency" Text="Emergency" runat="server" Checked="false"  onchange="Natal_CheckedChangedEmergency()"  />
                                    </td>
                                    <td id="TDPeadsElective" style="display:none;"><asp:RadioButton ID="rdbPeads_Elective" Text="Elective" runat="server" Checked="false"  onchange="Natal_CheckedChangedElective()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Place Of Delivery</td>
                                    <td><asp:TextBox ID="txtPeads_PlaceOfDelivery" runat="server"></asp:TextBox></td>
                                     <td>Indication For LSCS</td>
                                    <td><asp:TextBox ID="txtPeads_IndicationForLSCS" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td>Apger Score:</td>
                                </tr>
                                <tr>
                                    <td>1 Min</td>
                                    <td> <asp:DropDownList ID="ddlPeads_apgerScore1min" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                </asp:DropDownList></td>
                                    <td>5 Min</td>
                                    <td> <asp:DropDownList ID="ddlPeads_apgerScore5min" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                </asp:DropDownList></td>
                                    <td >
                                        <asp:CheckBox ID="chkPeads_Resuscitation" Text="Resuscitation" runat="server" />
                                    </td>
                                </tr>
                                
                                <tr>
                                    <td>Others</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_NatalOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                     <td>
                                       <h3>Post NATAL</h3>
                                    </td>
                                    <td>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Moaning" Text="Moaning" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_RespDistress" Text="Resp. Distress" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_PostNATALCyanosis" Text="Cyanosis" runat="server" />
                                    </td>
                                    
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Fits" Text="Fits" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_ReluctanceToFeed" Text="Reluctance To Feed" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Others</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_PostNatalOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                               <div id="dvPeadsHistory" style="margin: 0 auto; margin-top: 0px;">
                        <table class="table" id="tblPeadsHistory" style="display: block; overflow: scroll;">
                            <thead>
                                <tr>
                                    <td colspan="160">
                                        <div id="tblPeadsHeader">
                                            <h2 style="float: left; ">Peads History</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr> 
                                     <th>Date</th>
                                    <th>Status</th>  
                                    <th>Full Term</th>
                                    <th>Pre Term</th>
                                    <th>Date Of Delivery</th>
                                    <th>Time Of Delivery,</th>
                                    <th>Booked</th>
                                    <th>Un Booked</th>
                                    <th>DAI Handling</th>
                                    <th>Rash</th>
                                    <th>PIH</th>
                                    <th>GDM</th>
                                    <th>Vacinated</th>
                                    <th>Antenatal Others</th>
                                    <th>SVD</th>
                                    <th>LSCS</th>
                                    <th>Emergency</th>
                                    <th>Elective</th>
                                    <th>Place Of Delivery</th>
                                    <th>Indication For LSCS</th>
                                    <th>Apgar Score 1min</th>
                                    <th>Apgar Score 5min</th>
                                    <th>Resuscitation Needed</th>
                                    <th>Other Natal</th>
                                    <th>Moaning</th>
                                    <th>Resp. Distress</th>
                                    <th>Cyanosis</th>
                                    <th>Fits</th>
                                    <th>Reluctance To Feed</th>
                                    <th>Other Post Natal</th>
                                    <th>Weight(kg)</th>
                                    <th>Length(cm)</th>
                                    <th>H.C(cm)</th>
                                    <th>General Appearance</th>
                                    <th>Cyanosis</th>
                                    <th>Jaundice</th>
                                    <th>Lethargy</th>
                                    <th>Rash</th>
                                    <th>Others</th>
                                    <th>Caput</th>
                                    <th>Cephalhematoma</th>
                                    <th>Anterior Fontanelle Open</th>
                                    <th>Anterior Fontanelle Close</th>
                                    <th>Dextrocardia</th>
                                    <th>Bulging Precordium</th>
                                    <th>Murmur</th>
                                    <th>Heart Sound</th>
                                    <th>Nasal Flaring</th>
                                    <th>Recessions</th>
                                     <th>Added Sounds</th>
                                    <th>Abdomin Flat</th> 
                                    <th>Abdomin Distended</th> 
                                    <th>Abdomin Scaphoid</th> 
                                    <th>Liver: >3cm</th> 
                                    <th>Spleen:>2cm</th>
                                    <th>Others</th>
                                    <th>Sucking</th>
                                    <th>Rooting</th>
                                    <th>Moro</th>
                                    <th>Others</th>
                                    
                                </tr>

                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                        </div>
                         


                    </div>
                </div>
                <div class="modal-footer">
                    <input type="button" id="Button6" name="saveENT" value="Save" data-dismiss="modal" />
                </div>


            </div>
            <asp:HiddenField ID="queryString" runat="server"/>
        </div>
    </div>
     <div id="confirm">
         <div class="message">This is a warning message.</div>
         <button class="yes">OK</button>
      </div>
</asp:Content>

