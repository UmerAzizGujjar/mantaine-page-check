<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/EmergencyForm.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            MaskedInput({
                elm: document.getElementById('txt_mobile'),
                format: '+92__________',
                separator: '+92 -'

            }); 

            
            showhide();
            $('#btnsearchpatlist').click(function () {
                $("#PatientsSearchModel").modal('show');
                FillPatientsList();
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


            FillModePresentation();
            FillUserAccount();
            $('#ddlPatient_Type').off('change').on('change', function () {
                loaddata();
            });
            var reg_id = '<%= Request.QueryString["ID"] %>';
            var added = '<%= Request.QueryString["isAdd"] %>';
            var EMERID = '<%= Request.QueryString["EMERID"] %>'
            debugger;
            $("#hdn_EmergencyFormId").val(EMERID);
            if (EMERID != "") {

                loadPatientDetail(EMERID);


            }
            if (reg_id != "" && added == "true") {
                debugger;
                Get_Pat_Info(reg_id);

                $('#ddlPatient_Type').attr('disabled', false);
                //$('#ddlcashier').attr('disabled', true);
            }
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
                    $element.prop('disabled', false);
                    const deptHandler = function () {
                        loaddoctor();  // This will now check type === "03" and skip getGeneralFee
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

                $('#txtReferEmergencySearch').off('input').on('input', function () {
                    FillReferPatientsList();
                });

                var Reffered_id_opd = '<%= Request.QueryString["Reffered_id_opd"] %>';
                var refferopd_id = '<%= Request.QueryString["opd_id"] %>';
                var added = '<%= Request.QueryString["isAdd"] %>';

                if (Reffered_id_opd != "" && added == "true") {
                    debugger;
                    $("#hdn_emer_reffered").val(Reffered_id_opd);
                    $("#hdn_opdId").val(refferopd_id);
                    $('#ddlPatient_Type').attr('disabled', false);

                    if (typeof Get_Pat_Info_Reffer === 'function') {
                        Get_Pat_Info_Reffer(Reffered_id_opd);
                    } else {
                        Get_Pat_Info(Reffered_id_opd);
                    }
                }

               
                
                $(document).on('change', '#ddl_name', function () {
                    autoSelectGender();
                });

                $('#PatientModel').on('shown.bs.modal', function () {
                    setTimeout(function () {
                        var $gender = $('#ddl_Gender');
                        if ($gender.find('option').length <= 1) {
                            $gender.trigger('focus');
                            setTimeout(autoSelectGender, 600);
                        } else {
                            autoSelectGender();
                        }
                    }, 300);
                });

            });
        });
        function loadFee() {
            debugger;

            var Doc = $('#ddldoctor').val();
            var opdid = $('#hdn_EmergencyFormId').val();
            var selectedPatientType = $('#ddlPatient_Type').val();
            var emer_reffered = $("#hdn_emer_reffered").val();

            if (emer_reffered !== "") {
              
                $('#txtfees').val("0");
                return;
            }
            if (selectedPatientType == '03') {
                $('#txtfees').val("0");
                return;
            }

            if (!Doc) return;
            checkDoctorBlockStatus(Doc, selectedPatientType, function (isBlocked) {
                if (isBlocked) {
                    return;
                }

                if (selectedPatientType == '11') {
                    getspecialfees(Doc);
                } else {
                    if (opdid == "") {
                        $.ajax({
                            type: "POST",
                            url: "EmergencyForm.aspx/loadRegistrationFees",
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
        function checkDoctorBlockStatus(Doc, selectedPatientType, callback) {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetDoctorBlockInfo",
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
        function getspecialfees(Doc) {
            debugger
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/loadSpecialFees",
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
        function autoSelectGender() {
            var prefix = $('#ddl_name').val();
            var $gender = $('#ddl_Gender');
            var MALE_VALUE = 'M';
            var FEMALE_VALUE = 'F';

            var targetValue = '';

            if (prefix === 'Mr.') {
                targetValue = MALE_VALUE;
            } else if (prefix === 'Mrs.' || prefix === 'Ms.') {
                targetValue = FEMALE_VALUE;
            }
            if (!targetValue || $gender.length === 0) return;

            if ($gender.find('option').length <= 1) {
                console.log("Gender list not loaded yet. Triggering focus to load...");
                $gender.trigger('focus');
                setTimeout(autoSelectGender, 500);
                return;
            }
            $gender.val(targetValue).trigger('change');
            if ($gender.hasClass('select2-hidden-accessible')) {
                $gender.trigger('select2:select');
            }

            console.log("Gender set to: " + targetValue);
        }

        function AllowOPdEdit() {
            debugger;
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/checlkeditRights",
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
        function loaddata() {
            debugger;
            var Category = $('#ddlPatient_Type').val();

            $('#txtfees').val('');
            $('#txtactualfee').val('');
            $('#hdnDocshare').val('');
            $('#hdnhospShare').val('');
            $('#txtdiscount').val('').attr('disabled', false);
            $('#ddlDepartment').val('0').trigger('change');
            $('#ddldoctor').val('0').trigger('change');

            if (Category == "0") {

            }
            else if (Category == "01") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').hide();
                $('#balance').hide();
                $('#ddlDepartment').attr('disabled', false);
                $('#pnlcompany').hide();
                $('#employee').hide();

                $('#discount').show();
            }
            else if (Category == "02") {
                $('#fees').show();
                $('#department').show();
                $('#doctor').show();
                $('#balance').hide();

                $('#ddlDepartment').attr('disabled', false);
                $('#ddldoctor').attr('disabled', false);
                $('#pnlcompany').hide();
                $('#employee').hide();

                $('#discount').show();
            }
            else if (Category == "03") {
                // Show Panel Company, Department, and Doctor
                $('#fees').show();
                $('#department').show();      // ← CHANGE: Show department (was hidden)
                $('#ddlDepartment').show();   // ← Make sure department dropdown is visible
                $('#doctor').hide();
                $('#ddldoctor').show();
                $('#balance').show();
                $('#pnlcompany').show();
                $('#employee').show();

                // Enable dropdowns
                $('#ddlDepartment').attr('disabled', false);
                $('#ddldoctor').attr('disabled', false);
                $('#ddlpanel').attr('disabled', false);

                // Hide discount for panel patients
                $('#discount').hide();

                // Clear any existing fees
                $('#txtfees').val('');
                $('#txtactualfee').val('');

                // Load all departments (not filtered by panel)
                // Make sure fillDropdown loads all departments for category 03
                if ($('#ddlDepartment').find('option').length <= 1) {
                    fillDropdown($('#ddlDepartment'), 'GetDepartment');
                }
            }
            else if (Category == "06") {
                $('#department').hide();
                $('#ddldoctor').hide();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#discount').show();
                $('#txtdiscount').val("100");
                $('#txtdiscount').attr('disabled', true);
                $('#txtfees').val("0");
            }
            else if (Category == "04") {
                $('#department').hide();
                $('#ddldoctor').hide();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#discount').show();
                $('#txtdiscount').val("100");
                $('#txtdiscount').attr('disabled', true);
                $('#txtfees').val("0");
            }
            else if (Category == "05") {
                $('#department').hide();
                $('#ddldoctor').hide();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#discount').show();
                $('#txtdiscount').val("100");
                $('#txtdiscount').attr('disabled', true);
                $('#txtfees').val("0");
            }
            else if (Category == "10") {
                $('#department').show();      
                $('#ddldoctor').hide();
                $('#doctor').hide();
                $('#pnlcompany').hide();
                $('#employee').hide();
                $('#discount').show();
                $('#txtdiscount').val("100");
                $('#txtdiscount').attr('disabled', true);
                $('#txtfees').val("0");
            }
        }

      
     
        function loadPatientDetail(EMERID) {
            debugger;
            $('#btnsave').val('Update');
            $('#btnsave').attr('disabled', true);
            AllowOPdEdit();
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetPatientDetail",
                data: JSON.stringify({ EMERID: EMERID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    var stat = data.status;
                    //if (stat == "Approved") {
                    //    $('#divapprove').hide();
                    //    $('#divvoucher').show();
                    //}
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
                    $('#chckfreecheck').prop('checked', data.free_check).attr('disabled', true);
                    $('#txtdiscount').val(data.discount_amt).attr('disabled', true);
                    $('#txtdependent').val(data.Dependent).attr('disabled', true);
                    $('#txtemployee').val(data.Employee_Name).attr('disabled', true);
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
                    //if (stat != "Approved") {
                    //    $('#divapprove').show();
                    //    $('#divvoucher').hide();
                    //}
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
        function AddPatientDetail(reg_id) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "EmergencyForm.aspx?ID=" + reg_id + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

        }
        function OnFailPatients(exc) {
            alert(exc.get_message());
        }
        function FillPatientsList() {
            debugger;
            $('#tblPatientsResult tbody').empty();

            var SearchString = '';

            PageMethods.SearchPatients(SearchString, OnFilterPatients, OnFailPatients);
        }
        function ClearPatientResults() {
            while (tblPatientsResult.rows.length > 1) {
                tblPatientsResult.deleteRow(1);
            }
        }
        function OnFilterPatients(data) {

            ClearPatientResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
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

        function Get_Pat_Info(reg_id) {

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetBasicInfo",
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
                url: 'EmergencyForm.aspx/ModePresentation',
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
            var emer_reffered = $("#hdn_emer_reffered").val();
            var type = $("#ddlPatient_Type").val();
            var type_text = $('#ddlPatient_Type option:selected').text().trim();

            // ⭐ ADD THIS CHECK - For Panel category, don't load fees from department
            if (type === "03") {
                $('#txtfees').val("");
                $('#txtactualfee').val("");
                $('#hdnDocshare').val("");
                $('#hdnhospShare').val("");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            if (emer_reffered !== "") {
                $('#txtfees').val("0");
                $('#hdnDocshare').val("0");
                $('#hdnhospShare').val("0");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            // ... rest of your existing getGeneralFee code ...
        }
        function fillDropdown($dropdown, methodName) {
            if ($dropdown.data('filled')) return;

            $dropdown.data('filled', false);

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/" + methodName,  // Changed from OPD.aspx to EmergencyOPD.aspx
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
        function loaddoctor() {
            debugger;
            var dpt = $('#ddlDepartment').val();
            var type = $('#ddlPatient_Type').val();

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/LoadDoctor",
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

                    // ⭐ For Panel category (03), don't call getGeneralFee
                    if (type != "03") {
                        getGeneralFee();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });
        }


        //function loadalldoctor() {
        //    debugger;
        //    $.ajax({
        //        type: "POST",
        //        url: "EmergencyForm.aspx/LoadEmplData",
        //        data: '{}',  // Empty object, no parameters
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
        //            debugger;
        //            var doctors = JSON.parse(response.d);  // Now this will be an array
        //            var options = '<option value=""> Please Select </option>';

        //            // Check if doctors is an array and has items
        //            if (doctors && doctors.length > 0) {
        //                $.each(doctors, function (key, value) {
        //                    options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
        //                });
        //            }

        //            $('#ddldoctor').html(options);
        //            var type = $('#ddlPatient_Type').val();

        //            // Only call getGeneralFee for categories other than 03 (Panel)
        //            if (type == "02" || type == "01") {
        //                getGeneralFee();
        //            } else if (type == "03") {
        //                $('#txtfees').val("0");
        //            }
        //        },
        //        error: function (xhr, status, error) {
        //            console.log("Error: " + error);
        //        }
        //    });
        //}
        function showhide() {
            $('.show').show();
            $('#fees').hide();
            $('#department').hide();
            $('#field_Clinic').hide();
            $('#doctor').hide();
            $('#pnlcompany').hide();
            $('#employee').hide();
         
            $('#discount').hide();
            $('#balance').hide();
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
       
        function FillUserAccount() {
            var options;

            $.ajax({
                url: 'EmergencyForm.aspx/GetUserAccount',
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
                url: "EmergencyForm.aspx/Getmr",
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
                url: "EmergencyForm.aspx/SavePatientDetail",
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
                window.location.href = "EmergencyForm.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

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

            var regid = $('#hdn_regid').val();
            var emer_id = $('#hdn_EmergencyFormId').val();
            var patient_no = $('#txtPatientNo').val();
            var modeof_presentation = $('#ddlMode_Of_Registration').val();
            var pat_category = $('#ddlPatient_Type').val();
            var hdnDepartment = $('#ddlDepartment').val();
            var employee = $('#txtemployee').val();
            var employee_id_raw = $('#Employe_id').val();
            var employee_id = employee_id_raw === "" || !employee_id_raw ? null : parseInt(employee_id_raw);
            var EmployeeName = $('#empname').val();
            var EmployeeDept = $('#EmpDept').val();
            var StudentName = $('#txtStdName').val();
            var Fees = parseFloat($('#txtfees').val()) || 0;
            var Actual_Fees = parseFloat($('#txtactualfee').val()) || 0;
            var discount = $('#txtdiscount').val() || "0";
            var txtblnc = $('#txtbalance').val() || "0";
            var Doc_Share = parseFloat($('#hdnDocshare').val()) || 0;
            var Hosp_share = parseFloat($('#hdnhospShare').val()) || 0;
            var rollno = $('#ddlrollno').val();
            var Class = $('#ddlclass').val();
            var accountid = $('#ddlCashInHand').val();
            var Remarks = $('#txtremarks').val() || "";
            var hfAntiForgery = $('#ctl00_MainContent_hfAntiForgery').val();

            // Panel and Private fields
            var panel = $('#ddlpanel').val();
            var doctor = $('#ddldoctor').val();

            // Validations
        // Only validate fee for non-panel categories
            if (pat_category != "03") {
                if (discount < 100.0 && Fees == 0.0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Fee Should Not be Zero',
                        showConfirmButton: false,
                        timer: 2000
                    });
                    return;
                }
            }
            if (!patient_no || patient_no === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a Patient.', showConfirmButton: false, timer: 2000 });
                return;
            }
            if (!pat_category || pat_category === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a patient category.', showConfirmButton: false, timer: 2000 });
                return;
            }

            // Category specific validations
            if (pat_category === "03" && (!panel || panel === "0")) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a panel company.', showConfirmButton: false, timer: 2000 });
                return;
            }

            if ((pat_category === "02" ) && (!doctor || doctor === "0")) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a doctor.', showConfirmButton: false, timer: 2000 });
                return;
            }
          
            if ((pat_category === "01" || ["02"].includes(pat_category)) && (!hdnDepartment || hdnDepartment === "0")) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a department.', showConfirmButton: false, timer: 2000 });
                return;
            }

            if (!accountid || accountid === "0") {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a Cash In Hand.', showConfirmButton: false, timer: 2000 });
                return;
            }

            var data = {
                regid: regid,
                emer_id: emer_id,
                patient_no: patient_no,
                modeof_presentation: modeof_presentation,
                pat_category: pat_category,
                hdnDepartment: hdnDepartment,
                employee: employee,
                employee_id: employee_id,
                EmployeeName: EmployeeName,
                EmployeeDept: EmployeeDept,
                StudentName: StudentName,
                Fees: Fees,
                Actual_Fees: Actual_Fees,
                discount: discount,
                txtblnc: txtblnc,
                Doc_Share: Doc_Share,
                Hosp_share: Hosp_share,
                rollno: rollno,
                Class: Class,
                accountid: accountid,
                Remarks: Remarks,
                AntiForgeryToken: hfAntiForgery,
                panel: panel,
                doctor: doctor
            };

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/SaveEmergencyData",
                data: JSON.stringify({ data: data, emer_id: emer_id }),
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

                    var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print&Title=Emergency Print&Emergency_Id=' + patientID;
                    window.open(url, '_blank');
                    window.location.href = "Emergency_View.aspx";
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
        function Print() {
            debugger;
            var Emer_id = '<%= Request.QueryString["EMERID"] %>'
            var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print&Title=Emergency Print&Emergency_Id=' + Emer_id;
            window.open(url, '_blank');

        }
        function PrintLTR() {
            debugger;
            var Emer_id = '<%= Request.QueryString["EMERID"] %>'
            var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print_LTR&Title=Emergency Print&Emergency_Id=' + Emer_id;
            window.open(url, '_blank');

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
                    'href="#" onclick="AddReferPatientDetail(\'' + pat.Reg_Patient_ID + '\', \'' + pat.OPDID + '\')">' +
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
        function getpanelRate() {
            var panelid = $('#ddlpanel').val();
            var type = $('#ddlPatient_Type').val();

            // Only proceed if category is 03 (Panel)
            if (type !== "03") return;

            if (!panelid || panelid === "0") {
                $('#txtbalance').val("");
                $('#txtfees').val("");
                return;
            }

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/LoadPanelInfo",
                data: JSON.stringify({ panelid: panelid }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);

                    $('#txtbalance').val(data.Fees);
                    $('#txtbalance').attr('disabled', true);
                    $('#txtfees').val("0");
                    $('#txtfees').attr('disabled', true);
                    $('#txtactualfee').val(data.Fees); // Store actual fee
                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        function AddReferPatientDetail(reg_id, OPDID) {
            try {
                var isAdd = true;
                window.location.href = "EmergencyForm.aspx?Reffered_id_opd=" + reg_id + "&isAdd=" + isAdd + "&opd_id=" + OPDID;
            } catch (err) {
                alert(err.message);
            }
        }

        function Get_Pat_Info_Reffer(reg_id) {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetBasicInfoOFReffer",
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
                    $('#txtnic').val(data.CNIC_Masked);
                    $('#txtmobile').val(data.Mobile);
                    $('#txtAdrress').val(data.PermanentAdrress);
                    $('#hdn_regid').val(data.Reg_PatientID);
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
    <!-- Anti-CSRF Token -->
    <input type="hidden" id="hfAntiForgery" runat="server" />
    <input type="text " id="hdfPatient_ID" style="display: none;" />
    <input type="text" id="hdn_regid" style="display: none;" />
    <input type="text" id="hdn_EmergencyFormId" style="display: none;" />
    <input type="text" id="hdnDocshare" style="display: none;" />
    <input type="text" id="hdnhospShare" style="display: none;" />
    <input type="text" id="hdn_emer_reffered" style="display: none;" />
    <input type="text" id="hdn_dep_id" style="display: none;" />
    <div class="row">





        <div class="col-lg-9 col-md-9 col-sm-12 fields">
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
                <span style="margin-left: 5px !important; font-weight: bold; font-size: 24px;" id="lbltotpat" runat="server"></span>

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
                        <label>EmergencyForm No *</label>
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
                    <div class="col-lg-3 col-md-6 col-sm-12 fields" id="field_Services" style="display: none;">
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

                <div class="col-lg-12 col-md-12 col-sm-12" id="discount">
                    <label>Discount %</label>
                    <input type="text" id="txtdiscount" onchange="Calc_Discount()" class="form-control" />
                </div>
                <div class="col-lg-12 col-md-12 col-sm-12" id="balance">
                    <label>balance Amount </label>
                    <input type="text" id="txtbalance"  class="form-control" />
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
                    <input type="button" class="btn btn-yellow " id="btnNew" value="New" onclick="window.location = 'EmergencyForm.aspx'" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input type="button" class="btn btn-gray " id="btnView" value="View" onclick="window.location = 'Emergency_View.aspx'" />
                </div>

                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdprint">
                    <input type="button" class="btn-primry " id="btnPrint" value="Print" onclick="Print()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdprint1">
                    <input type="button" class="btn-primry " id="btnPrint2" value="Print-1" onclick="PrintLTR()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="btn-opdFormprint" style="display: none; position: absolute;">
                    <input type="hidden" class="btn-primry " id="btnOPDFormPrint" value="OPD Form" onclick="OPD_Form_Print()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6" id="divvoucher" style="display: none;">
                    <input type="button" class="btn-primry " id="btnPrintVoucher" value="Voucher" onclick="PrintVoucher();" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4" id="divapprove" style="display: none;">
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
                        <div class="col-lg-2 col-md-4 col-sm-6" style="display: none">
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

    <div id="SearchEmergencyFormPatients" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="form-row">
                            <div class="col-md-6">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtEmergencyFormSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                        </div>
                    </fieldset>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblEmergencyFormResult">
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
                            <tbody id="EmergencyFormPatientsBody">
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

