<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Emergency.aspx.cs" Inherits="PMS.Modules.PatientManagement.Emergency" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/Tibbit_theme/css/CustomCss/OPD.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            showhide();
            FillModePresentation();
            FillUserAccount();
            $('#ddlPatient_Type').off('change').on('change', function () {
                loaddata();
            });
            var reg_id = '<%= Request.QueryString["ID"] %>';
            var added = '<%= Request.QueryString["isAdd"] %>';
            if (reg_id != "" && added == "true") {
                debugger;
                Get_Pat_Info(reg_id);

                $('#ddlPatient_Type').attr('disabled', false);
                //$('#ddlcashier').attr('disabled', true);
            }
            var dropdowns = [
               /* { id: '#ddlMode_Of_Registration', method: 'ModePresentation' },*/
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
                    // ✅ MODAL: Use native 'focus' to load data ONCE
                    $element.off('focus.fill').on('focus.fill', function () {
                        if (!$element.data('filled')) {
                            fillDropdown($element, item.method);
                        }
                    });
                }

                // 👇 Keep ALL your existing logic exactly as before
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
                    // Since modal uses native select, bind to 'change', not 'select2:select'
                    const deptChangeHandler = function () {
                        if (typeof getGeneralFee === 'function') {
                            getGeneralFee();
                        }
                    };

                    if (!isInsideModal) {
                        // Non-modal: Select2 uses custom event
                        $element.off('select2:select.dept').on('select2:select.dept', deptChangeHandler);
                    } else {
                        // Modal: Native select uses standard 'change'
                        $element.off('change.dept').on('change.dept', deptChangeHandler);
                    }
                }
             

               


            });
        });
        function Get_Pat_Info(reg_id) {

            $.ajax({
                type: "POST",
                url: "Emergency.aspx/GetBasicInfo",
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
                    checkcardvalidation();



                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        function FillModePresentation() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'Emergency.aspx/ModePresentation',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;

                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlMode_Of_Registration').html(options);
                    $('#ddlMode_Of_Registration').val('02');
                    $('#ddlMode_Of_Registration').attr('disabled', true);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function getGeneralFee() {
            debugger;

            var Department_id = $('#ddlDepartment').val();
          
            var type = $("#ddlPatient_Type").val();
            var type_text = $('#ddlPatient_Type option:selected').text().trim();

          

            if (!Department_id || Department_id === "") {
                $('#txtfees').val("0");
                $('#hdnDocshare').val("0");
                $('#hdnhospShare').val("0");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            $.ajax({
                url: 'Emergency.aspx/GetFees',
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
        function fillDropdown($dropdown, methodName) {
            if ($dropdown.data('filled')) return;

            $dropdown.data('filled', false);

            $.ajax({
                type: "POST",
                url: "Emergency.aspx/" + methodName,
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
        function loaddata() {
            debugger;
            var Category = $('#ddlPatient_Type').val();
            // $('#ddlPatient_Type').attr('disabled', true);
            debugger;
            if (Category == "0") {

                $('.show').show();
                $('#fees').hide();
                $('#department').hide();
           /*     showIfAllowed('field_Clinic', false);*/

           
            }
            else if (Category == "01") {
                $('#fees').show();
                $('#department').show();
               
            }
          
        }
        function FillUserAccount() {
            var options;

            $.ajax({
                url: 'Emergency.aspx/GetUserAccount',
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
        function fillmrno() {
            var data = {};

            $.ajax({
                type: "POST",
                url: "Emergency.aspx/Getmr",
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

            if ((PatientName == "" || Mobile == "")) {
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
                "cardfee": cardfee,
            };


            $.ajax({
                type: "POST",
                url: "Emergency.aspx/SavePatientDetail",
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
                    //Approve(ini_patientID)
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
        function get_pat_initial_info(ini_patientID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "Emergency.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

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
        function SaveData() {
            debugger;

            // ✅ Collect ONLY defined variables
            var regid = $('#hdn_regid').val();
            var appid = $('#hdn_aptid').val();
            var emer_id = $('#hdn_emergencyId').val();
            var patient_no = $('#txtPatientNo').val();
            var modeof_presentation = $('#ddlMode_Of_Registration').val();
            var pat_category = $('#ddlPatient_Type').val();
            var hdnDepartment = $("#hdn_dep_id").val(); // ✅ Use this, not "Department"
            var employee = $('#txtemployee').val();
            var employee_id_raw = $('#Employe_id').val();
            var employee_id = employee_id_raw === "" || !employee_id_raw ? null : parseInt(employee_id_raw);
            var EmployeeName = $('#empname').val();

            var StudentName = $('#txtStdName').val();
            var Fees = parseFloat($('#txtfees').val()) || 0;
            var Actual_Fees = parseFloat($('#txtactualfee').val()) || 0;
            var discount = parseFloat($('#txtdiscount').val()) || 0;
            var Doc_Share = parseFloat($('#hdnDocshare').val()) || 0;
            var Hosp_share = parseFloat($('#hdnhospShare').val()) || 0;
            var rollno = $('#ddlrollno').val();
            var Class = $('#ddlclass').val();
            var accountid = $('#ddlCashInHand').val();
            var Remarks = $('#txtremarks').val() || "";
            var hfAntiForgery = $('#ctl00_MainContent_hfAntiForgery').val(); // ✅ Anti-forgery token

            // ✅ Validation: Use hdnDepartment (not undefined "Department")
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

            if (!patient_no || patient_no === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a Patient.', showConfirmButton: false, timer: 2000 });
                return;
            }
            if (!pat_category || pat_category === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a patient category.', showConfirmButton: false, timer: 2000 });
                return;
            }
            // ✅ Fixed: Use hdnDepartment instead of undefined "Department"
            if ((pat_category === "01" || ["02", "04", "05"].includes(pat_category)) && (!hdnDepartment || hdnDepartment === "0")) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a department for the selected patient category.', showConfirmButton: false, timer: 2000 });
                return;
            }
            if (!accountid || accountid === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a Cash In Hand.', showConfirmButton: false, timer: 2000 });
                return;
            }

            // ✅ ONLY include variables that are ACTUALLY DEFINED above
            var data = {
                regid: regid,
                appid: appid,
                opdid: opdid,               // ✅ Included (was missing earlier)
                patient_no: patient_no,
                modeof_presentation: modeof_presentation,
                pat_category: pat_category,
                hdnDepartment: hdnDepartment, // ✅ Use correct variable name
                employee: employee,
                employee_id: employee_id,
                EmployeeName: EmployeeName,
                StudentName: StudentName,
                Fees: Fees,
                Actual_Fees: Actual_Fees,
                discount: discount,
                Doc_Share: Doc_Share,
                Hosp_share: Hosp_share,
                rollno: rollno,
                Class: Class,
                accountid: accountid,
                Remarks: Remarks,
                AntiForgeryToken: hfAntiForgery
            };

            console.log("Data being sent:", data);

            $.ajax({
                type: "POST",
                url: "Emergency.aspx/SaveEmergencyData",
                data: JSON.stringify({ data: data, opdid: opdid }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d && response.d.startsWith("ERROR:")) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Validation Failed',
                            text: response.d.replace("ERROR: ", ""),
                            showConfirmButton: false,
                            timer: 3000
                        });
                        return;
                    }

                    var patientID = response.d;
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Your Record Saved Successfully',
                        showConfirmButton: false,
                        timer: 2500
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
                        timer: 2000
                    });
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
    <input type="text" id="hdn_regid" style="display: none;" />
    <input type="text" id="hdn_emergencyId" style="display: none;" />
    <input type="text" id="hdnDocshare" style="display: none;" />
    <input type="text" id="hdnhospShare" style="display: none;" />
    <input type="text" id="hdn_emer_reffered" style="display: none;" />
    <input type="text" id="hdn_dep_id" style="display: none;" />
    <div class="row">
      




        <div class="col-lg-9 col-md-9 col-sm-12 fields" >
            <!-- Quick Actions row: four equal, high-contrast cards -->
            <div class="row">
                <!-- Card 1 -->
                <div class="col-lg-3 col-md-3 col-sm-6 mb-3 fields">
                    <div class="quick-actions" id="card-register" role="button" tabindex="0"
                        onclick="addfunc()"
                        onkeypress="if(event.key==='Enter'){ addfunc(); }"
                        class="d-flex flex-column justify-content-center align-items-start">
                        <div class="d-flex align-items-center">
                            <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Register Icon" width="48" height="48" style="margin-right: 10px;">
                            <div>
                                <div style="font-weight: 700; font-size: 1.5rem;">Register a new patient</div>
                                <div style="font-size: 0.95rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Create a new patient record</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Card 2 -->
          

                <!-- Card 3 -->
                <div class="col-lg-3 col-md-3 col-sm-6 mb-3 fields">
                    <div id="btnsearchpatlist" role="button" tabindex="0" onclick="/* add search patient function here, e.g. openPatientSearch() */" onkeypress="if(event.key==='Enter'){ /* openPatientSearch(); */ }"
                        class="d-flex flex-column justify-content-center align-items-start quick-actions">
                        <div class="d-flex align-items-center">
                            <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png" alt="Search Patient Icon" width="48" height="48" style="margin-right: 10px;">
                            <div>
                                <div style="font-weight: 700; font-size: 1.5rem;">Search an existing patient</div>
                                <div style="font-size: 0.95rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Lookup patient details</div>
                            </div>
                        </div>
                    </div>
                </div>

          
                <div class="col-lg-3 col-md-3 col-sm-6 mb-3 fields" id="RefferdBy">
                    <div id="btnsearchReferlist" role="button" tabindex="0" onclick="openReferPatientModal()" onkeypress="if(event.key==='Enter'){ openReferPatientModal(); }"
                        class="d-flex flex-column justify-content-center align-items-start quick-actions" style="cursor: pointer;">
                        <div class="d-flex align-items-center">
                            <img src="~~../../../../wwwroot/Tibbit_theme/images/HMIS_Icons/adduser.png"
                                alt="Refer Patient Icon" width="48" height="48" style="margin-right: 10px;">
                            <div>
                                <div style="font-weight: 700; font-size: 1.5rem;">Refer Patient</div>
                                <div style="font-size: 0.95rem; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                    Refer an existing patient
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

            </div>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4 fields">
            <div class="card3">
                <span style="font-size: 15px;">Total Emergecny </span>
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lbltotpat"  runat="server"></span>

            </div>
           
        </div>
    </div>

    <div class="row mtop">
        <div class="col-lg-9 col-md-8 sm-12 fields">
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
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Patient_name">
                        <label>Name *</label>
                        <input type="text" id="txt_patname" value="" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Last_name">
                        <label>Last Name *</label>
                        <input type="text" id="txt_F_Name" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_OPD_No">
                        <label>Emergency No *</label>
                        <input type="text" id="txt_opd_no" value="New" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Mode_Reg">
                        <label>Mode Of Presentation</label>
                        <select id="ddlMode_Of_Registration" readonly="readonly"></select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Mobile">
                        <label>Mobile *</label>
                        <input type="text" id="txtmobile" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_CNIC">
                        <label>CNIC *</label>
                        <input type="text" id="txtnic" value="" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Category">
                        <label>Patient Category</label>
                        <select id="ddlPatient_Type" disabled>
                            <option value="0">Select Category</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Martial_Status">
                        <label>Martial Status</label>
                        <select id="ddlmartialstatus" disabled>
                            <option value="0">Select Status</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_age">
                        <label>Age</label>
                        <input type="text" id="txtage" readonly="readonly" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Gender">
                        <label>Gender</label>
                        <select id="ddlGender" disabled>
                            <option value="0">Select Gender</option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Fee">
                        <label>Fee</label>
                        <input type="text" id="txtfees" readonly="readonly" class="form-control" />
                        <input type="text" id="txtactualfee" style="display: none;" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Services" style="display:none;">
                        <label>Services</label>
                        <select id="ddlServices">
                            <option value="0">Select Service</option>
                        </select>
                    </div>

                    <div class="col-lg-6 col-md-12 col-sm-12" id="field_Address">
                        <label>Address</label>
                        <input type="text" id="txtAdrress" readonly="readonly" />
                    </div>
                    
                    <div class="col-lg-3 col-md-8 col-sm-8" id="remarks">
                        <label>Remarks</label>
                        <input type="text" id="txtremarks" />
                    </div>
                </div>





            </div>


        </div>

        <div class="col-lg-3 col-md-4 mtop" id="right-section">
            <div class="row card2">
                <!-- Other form elements -->
                <div class="col-lg-12 col-md-12 col-sm-12" id="department">
                    <label>Department</label>
                    <select id="ddlDepartment" class="form-control">
                        <option value="0">Select Department</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="field_Clinic">
                    <label>Filter Clinic</label>
                    <select id="ddlFilterClnic" class="form-control" disabled="disabled">
                        <option value="0">Select Clinic</option>
                    </select>
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="doctor">
                    <label>Doctor</label>
                    <select id="ddldoctor" class="form-control">
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
             
                <div class="col-lg-12 col-md-12 col-sm-12" id="Field-CIH">
                    <label>Cash In Hand</label>
                    <select id="ddlCashInHand">
                    </select>
                </div>

                <!-- Checkboxes Section -->
               
                
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
                    <input type="button" class="btn btn-yellow " id="btnNew" value="New" onclick="window.location = 'Emergency.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input type="button" class="btn btn-gray " id="btnView" value="View" onclick="window.location = 'OPDView.aspx'" />
                </div>
              
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdprint">
                    <input type="button" class="btn-primry " id="btnPrint" value="Print" onclick="OPD_Print('<%= Request.QueryString["OPDID"] %>', '<%= AppConfig.Company_Name %>')" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdFormprint" style="display: none; position: absolute;">
                    <input type="hidden" class="btn-primry " id="btnOPDFormPrint" value="OPD Form" onclick="OPD_Form_Print()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6" id="divvoucher" style="display:none;">
                    <input type="button" class="btn-primry " id="btnPrintVoucher" value="Voucher" onclick="PrintVoucher();" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divapprove" style="display:none;">
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

