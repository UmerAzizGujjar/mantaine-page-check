<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyForm.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyForm" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/EmergencyForm.css" rel="stylesheet" />
    <script type="text/javascript">
        
        $(document).ready(function () {
            CheckCNICUpdateonCondition();
            CheckEmerDocTokenCondition();
            LoadERAutoDepartment();
            MaskedInput({
                elm: document.getElementById('txt_mobile'),
                format: '+92__________',
                separator: '+92 -'

            }); 

            isCNICValidationRequired();

            MaskedInput({
                elm: document.getElementById('txt_cnic'),
                format: '_____-_______-_',
                separator: '-'
            });

            MaskedInput({
                elm: document.getElementById('txt_Othercnic'), 
                format: '_____-_______-_',
                separator: '-'
            });

            
            $('#txt_cnic').attr('placeholder', '_____-_______-_');
            $('#txt_Othercnic').attr('placeholder', '_____-_______-_');

            showhide();
            $('#btnsearchpatlist').click(function () {
                $("#PatientsSearchModel").modal('show');
                FillPatientsList();
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


            FillModePresentation();
            FillUserAccount();
            $('#ddlPatient_Type').off('change').on('change', function () {
                loaddata();
            });
            var reg_id = '<%= Request.QueryString["ID"] %>';
            var added = '<%= Request.QueryString["isAdd"] %>';
            var EMERID = '<%= Request.QueryString["EMERID"] %>'
            $("#hdn_EmergencyFormId").val(EMERID);
            if (EMERID != "") {

                loadPatientDetail(EMERID);


            }
            if (reg_id != "" && added == "true") {
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
                { id: '#ddlEmerDoctor', method: 'GetDoctor' },
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
                        loadCostCentersByDepartment($('#ddlDepartment').val());
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
                    // Force load gender options if not already loaded
                    var $gender = $('#ddl_Gender');
                    if ($gender.find('option').length <= 1) {
                        fillDropdown($gender, 'GetGender');
                    }

                    // Wait for options to load then auto-select
                    setTimeout(function () {
                        autoSelectGender();
                    }, 500);
                });

            });

            $('#ddlCostCenter').select2();
        });

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
                url: "EmergencyForm.aspx/GetCostCenterByDepartment",
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
        function loadFee() {

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
                    var blockInfo = JSON.parse(response.d);

                    if (blockInfo && blockInfo.error) {
                        console.error("Block info error:", blockInfo.error);
                        callback(false);
                        return;
                    }
                    if (blockInfo.offDays && blockInfo.offDays !== "" && blockInfo.Block_category === true && blockInfo.Patient_Type === selectedPatientType) {
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
            var optionsCount = $gender.find('option').length;

            if (optionsCount <= 1) {
                console.log("Gender list not loaded yet. Waiting for data...");
                var checkInterval = setInterval(function () {
                    var newOptionsCount = $gender.find('option').length;
                    if (newOptionsCount > 1) {
                        clearInterval(checkInterval);
                        $gender.val(targetValue).trigger('change');
                        if ($gender.hasClass('select2-hidden-accessible')) {
                            $gender.trigger('select2:select');
                        }
                        console.log("Gender set to: " + targetValue);
                    }
                }, 100);
                setTimeout(function () {
                    clearInterval(checkInterval);
                }, 5000);
                return;
            }

            $gender.val(targetValue).trigger('change');
            if ($gender.hasClass('select2-hidden-accessible')) {
                $gender.trigger('select2:select');
            }

            console.log("Gender set to: " + targetValue);
        }

        function AllowOPdEdit() {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/checlkeditRights",
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
        function loaddata() {
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

                applyERAutoDepartment();
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
                    $('#ddlCostCenter').html(
                        $('<option>', {
                            value: data.Cost_Center,
                            text: data.Cost_Center_text
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
                    var NIC = data.CNIC_Masked;
                    if (CNICs == '01') {
                        if (NIC == '') {
                            Swal.fire({
                                icon: 'warning',
                                title: 'CNIC Not Entered',
                                text: 'Do you want to enter CNIC?',
                                showCancelButton: true,
                                confirmButtonText: 'Yes',
                                cancelButtonText: 'No'
                            }).then((result) => {

                                if (result.isConfirmed) {

                                    Swal.fire({
                                        title: 'Enter CNIC',
                                        input: 'text',
                                        inputPlaceholder: '12345-1234567-1',
                                        showCancelButton: true,
                                        confirmButtonText: 'Save',
                                        customClass: {
                                            input: 'cnic-input'
                                        },

                                        didOpen: () => {
                                            const input = Swal.getInput();

                                            // Apply your MaskedInput here
                                            MaskedInput({
                                                elm: input,
                                                format: '_____-_______-_',
                                                separator: '-'
                                            });
                                            setTimeout(() => {
                                                input.focus();
                                                input.setSelectionRange(0, 0);
                                            }, 0);
                                        },

                                        inputValidator: (value) => {
                                            /*  if (!value) return 'CNIC is required!';*/
                                            if (value.includes('_')) return 'Complete CNIC first!';
                                        }

                                    }).then((res) => {
                                        if (res.isConfirmed) {
                                            let enteredCNIC = res.value;

                                            SaveCNIC(enteredCNIC);
                                            $('#txtCNIC').val(enteredCNIC);
                                        }
                                    });

                                }
                                else if (result.isDismissed) {
                                    // 👇 User clicked "No"
                                    PatientMonitoring();
                                }
                            });
                        }

                     
                    }

                    checkcardvalidation();

                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        var cardvalidation;
        function checkcardvalidation() {

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/Getcardvalidation",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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
        function checkcardfee(reg_id) {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/CheckCardFee",
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
        function chargeCardFee(reg_id) {

            Approveviasysparams(reg_id);
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/ChargeCardFee", // ← Replace with your actual page name
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
        var erAutoDeptCode = "";
        function LoadERAutoDepartment() {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetERAutoDepartment",
                data: "{}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try { erAutoDeptCode = JSON.parse(response.d) || ""; } catch (e) { erAutoDeptCode = ""; }
                    if (erAutoDeptCode && $('#ddlPatient_Type').val() === "01") {
                        applyERAutoDepartment();
                    }
                },
                error: function () { erAutoDeptCode = ""; }
            });
        }
        function applyERAutoDepartment() {
            if (!erAutoDeptCode) return;
            if ($('#ddlPatient_Type').val() !== "01") return;
            if ($('#hdn_EmergencyFormId').val() !== "" || $('#hdn_emer_reffered').val() !== "") return;

            var $dept = $('#ddlDepartment');
            var selectER = function () {
                $('#ddlDepartment').val(erAutoDeptCode).trigger('change');
                if ($('#ddlDepartment').hasClass('select2-hidden-accessible')) {
                    $('#ddlDepartment').trigger('select2:select');
                    $('#ddlDepartment').select2('close');
                }
            };

            if ($dept.find('option').length <= 1) {
                fillDropdown($dept, 'GetDepartment', selectER);
            } else {
                selectER();
            }
        }
        var CNICs;
        function CheckCNICUpdateonCondition() {

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/CNICUpdateCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var CNICss = JSON.parse(response.d);
                    if (CNICss == '01') {
                        CNICs = true;
                    }
                    else {
                        CNICs = false;
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function CheckEmerDocTokenCondition() {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/EmerDocTokenCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var val = JSON.parse(response.d);
                    if (val === '02') {
                        $('#emerDoctor').show();
                    } else {
                        $('#emerDoctor').hide();
                    }
                },
                error: function (error) {
                    console.error("Error checking token condition", error);
                    $('#emerDoctor').hide();
                }
            });
        }

        function SaveCNIC(enteredCNIC) {
            var Patient_ID = $('#hdn_regid').val();
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/SaveCNIC",
                data: JSON.stringify({
                    'Patient_ID': Patient_ID,
                    'enteredCNIC': enteredCNIC
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var doctorIds = JSON.parse(response.d);

                },
                error: function (err) {
                    alert("Could not Save CNIC.");
                }
            });
        }
        function PatientMonitoring() {
            var Patient_ID = $('#hdn_regid').val();
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/PatientMonitoring",
                data: JSON.stringify({
                    'Patient_ID': Patient_ID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var doctorIds = JSON.parse(response.d);

                },
                error: function (err) {
                    alert("Could not Save CNIC.");
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

            var Department_id = $('#ddlDepartment').val();
            var emer_reffered = $("#hdn_emer_reffered").val();
            var type = $("#ddlPatient_Type").val();
            var type_text = $('#ddlPatient_Type option:selected').text().trim();

            // For Panel category, don't load fees from department
            if (type === "03") {
                $('#txtfees').val("");
                $('#txtactualfee').val("");
                $('#hdnDocshare').val("");
                $('#hdnhospShare').val("");
                $('#txtdiscount').val("");
                $('#txtdiscount').attr('disabled', false);
                return;
            }

            // For category 02, don't load general fees (will load from doctor instead)
            if (type === "02") {
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

            $.ajax({
                url: 'EmergencyForm.aspx/GetFees',
                type: 'POST',
                data: JSON.stringify({ Department_id: Department_id }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (resp) {

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
                            $('#txtdiscount').val(Discount_Percentage);
                            $('#txtdiscount').attr('disabled', false);
                            $('#txtfees').val(Receipt_fee.toFixed(2));
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
                                showConfirmButton: false
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
                            showConfirmButton: false
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
                        showConfirmButton: false
                    });

                    $('#txtfees').val("0");
                    $('#hdnDocshare').val("0");
                    $('#hdnhospShare').val("0");
                    $('#txtdiscount').val("");
                    $('#txtdiscount').attr('disabled', false);
                }
            });
        }  // ← This closing brace was missing!
     
        function fillDropdown($dropdown, methodName, onDone) {
            if ($dropdown.data('filled')) {
                autoSelectGender();
                if (typeof onDone === 'function') onDone();
                return;
            }

            $dropdown.data('filled', false);

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/" + methodName,
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

                        if ($dropdown.attr('id') === 'ddl_Gender') {
                            autoSelectGender();
                        }

                        if (typeof onDone === 'function') onDone();
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
            var dpt = $('#ddlDepartment').val();
            var type = $('#ddlPatient_Type').val();

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/LoadDoctor",
                data: JSON.stringify({ dpt: dpt }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var doctor = JSON.parse(response.d);
                    var options = '<option value=""> Please Select </option>';

                    $.each(doctor, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });

                    $('#ddldoctor').html(options);
                    var selectedPatientType = $('#ddlPatient_Type').val();

                    // For category "02", don't call getGeneralFee - fees will load from doctor selection
                    if (selectedPatientType === "02") {
                        // Clear fees initially
                        $('#txtfees').val('');
                        $('#txtactualfee').val('');
                        $('#txtdiscount').val('');
                        return;
                    }

                    // For other categories (01, etc.), load general fee
                    if (selectedPatientType !== "03" && selectedPatientType !== "02") {
                        getGeneralFee();
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });
        }  // ← This closing brace was missing!


        //function loadalldoctor() {
        //    $.ajax({
        //        type: "POST",
        //        url: "EmergencyForm.aspx/LoadEmplData",
        //        data: '{}',  // Empty object, no parameters
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
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
            CheckAndLoadWalkinPatientRegFee();

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
                    var max_mr = data.d;
                    $('#txt_Mrno').val('New');
                },
                error: function (xhr, status, error) {
                    console.error("AJAX request failed:", status, error);
                }
            });
        }
        function SavePatient() {

            // Disable the save button immediately to prevent multiple clicks
            $('#SavePatient_Data').attr('disabled', true);

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
            var OtherCNIC = $('#txt_Othercnic').val();
            var Address = $('#txt_house').val();
            var stno = $('#txtstrm').val();
            var city = $('#txtcity :selected').text();
            var area = $('#txtarea :selected').text();
            var city_val = $('#txtcity').val();
            var area_val = $('#txtarea').val();
            var martail_status = $('#ddl_status').val();
            var Country = $('#ddlCountry :selected').val();
            var Province = $('#ddl_Province :selected').val();
            var cardfee = $('#txtcardfees').val();

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

            var isCNICRequired = isCNICValidationRequired();
            if (isCNICRequired) {
                var isCNICEmpty = !CNIC || CNIC === "" || CNIC === "_____-_______-_";
                var isOtherCNICEmpty = !OtherCNIC || OtherCNIC === "" || OtherCNIC === "_____-_______-_";

                if (isCNICEmpty && isOtherCNICEmpty) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'CNIC Required!',
                        text: 'Please enter CNIC or Other CNIC',
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
                url: "EmergencyForm.aspx/SavePatientDetail",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    // Check if CNIC already exists
                    if (response.d === "CNIC_EXISTS") {
                        Swal.fire({
                            icon: 'warning',
                            title: 'CNIC Already Exists!',
                            text: 'A patient with this CNIC is already registered.',
                            confirmButtonText: 'OK',
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $('#SavePatient_Data').attr('disabled', false);
                        return;
                    }

                    // Check for other errors
                    if (response.d && response.d.startsWith("ERROR:")) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: response.d.replace("ERROR:", ""),
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

                    var ini_patientID = response.d;
                    alert('Your Record Saved and Loaded Successfully');
                  

                    // Button stays disabled during this time
                    // Re-enable after a short delay to ensure no double clicks during the success message
                    setTimeout(function () {
                        $('#SavePatient_Data').attr('disabled', false);
                    }, 2600); // Slightly longer than the success message timer

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
                    // Re-enable the button on error
                    $('#SavePatient_Data').attr('disabled', false);
                }
            });
        }
        function get_pat_initial_info(ini_patientID) {
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
            $('#btnsave').attr('disabled', true);

            var regid = $('#hdn_regid').val();
            var emer_id = $('#hdn_EmergencyFormId').val();
            var patient_no = $('#txtPatientNo').val();
            var modeof_presentation = $('#ddlMode_Of_Registration').val();
            var pat_category = $('#ddlPatient_Type').val();
            var hdnDepartment = $('#ddlDepartment').val();
            var CostCenter = $('#ddlCostCenter').val();
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
            var emerDoctor = $('#ddlEmerDoctor').val();

            // Validations
        // Only validate fee for non-panel categories
            if (pat_category != "03") {
                if (discount < 100.0 && Fees == 0.0) {
                    $('#btnsave').attr('disabled', false);
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
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a Patient.', showConfirmButton: false, timer: 2000 });
                return;
            }
            if (!pat_category || pat_category === "0") {
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a patient category.', showConfirmButton: false, timer: 2000 });
                return;
            }

            // Category specific validations
            if (pat_category === "03" && (!panel || panel === "0")) {
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a panel company.', showConfirmButton: false, timer: 2000 });
                return;
            }

            if ((pat_category === "02" ) && (!doctor || doctor === "0")) {
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a doctor.', showConfirmButton: false, timer: 2000 });
                return;
            }

            if ($('#emerDoctor').is(':visible') && (!emerDoctor || emerDoctor === "0")) {
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select an emergency doctor.', showConfirmButton: false, timer: 2000 });
                return;
            }
          
            if ((pat_category === "01" || ["02"].includes(pat_category)) && (!hdnDepartment || hdnDepartment === "0")) {
                $('#btnsave').attr('disabled', false);
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select a department.', showConfirmButton: false, timer: 2000 });
                return;
            }

            if (!accountid || accountid === "0") {
                $('#btnsave').attr('disabled', false);
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
                CostCenter: CostCenter,
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
                doctor: doctor,
                emer_doctor: emerDoctor
            };

            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/SaveEmergencyData",
                data: JSON.stringify({ data: data, emer_id: emer_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d && response.d.startsWith("ERROR:")) {
                        $('#btnsave').attr('disabled', false);
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
                    $('#btnsave').attr('disabled', false);
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
            var Emer_id = '<%= Request.QueryString["EMERID"] %>'
            var url = '../../ReportViewer.aspx?ReportName=Emergency_Patient_Print&Title=Emergency Print&Emergency_Id=' + Emer_id;
            window.open(url, '_blank');

        }
        function PrintLTR() {
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
        function CheckAndLoadWalkinPatientRegFee() {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/IsWalkinPatientRegFeeActive",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var isActive = response.d;

                    if (isActive == "01") {

                        $('#txtcardfees').show();
                        $('#lblfee').show();


                        // Now get the actual fee amount
                        GetWalkinPatientRegFee();
                    } else {
                        // Hide the txtfees field
                        $('#txtcardfees').hide(); // or $('#feesRow').hide();
                        $('#lblfee').hide(); // or $('#feesRow').hide();
                        $('#txtcardfees').val('0');
                        $('#txtcardfees').prop('disabled', true);
                    }
                },
                error: function (error) {
                    console.error("Error checking registration fee status:", error);
                    $('#txtcardfees').hide();
                }
            });
        }

        function GetWalkinPatientRegFee() {
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/GetWalkinPatientRegFee",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var fee = response.d;
                    if (fee && fee != '0' && fee != 'null' && fee != '') {
                        fee = fee.replace(/["']/g, '');
                        $('#txtcardfees').val(fee);
                    } else {
                        $('#txtcardfees').val('0');
                    }
                },
                error: function (error) {
                    console.error("Error fetching registration fee:", error);
                    $('#txtcardfees').val('0');
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

        function isCNICValidationRequired() {
            var result = false;
            $.ajax({
                type: "POST",
                url: "EmergencyForm.aspx/CNICValidation",
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
<div class="opd-page">

    <!-- ============ META BAR ============ -->
    <div class="opd-meta-bar">
        <div class="opd-meta-title">
            <i class="fa fa-stethoscope"></i>
            <span>Emergency - Patient Registration</span>
            <span class="opd-meta-meta-badge" id="emerStatusBadge">New</span>
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
                <span>Emergency Stats</span>
            </div>
            <div class="opd-stats-grid">
                <div class="opd-stats-row">
                    <span class="opd-stats-label"><i class="fa fa-users"></i> Total</span>
                    <span class="opd-stats-value opd-stats-value--primary" id="lbltotpat" runat="server">0</span>
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
                <span class="opd-card-badge" id="emerPatientBadge">New Patient</span>
            </div>
            <div class="opd-card-body">
                <input type="text" id="txt_reg_patno" style="display:none" />
                <input type="text" runat="server" id="txtPatient_ID" style="display:none" />
                <input type="text" id="txtpatient_no" style="display:none" />
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
                        <label class="opd-label">Emergency No <span class="opd-required">*</span></label>
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
                        <input type="text" id="txtactualfee" style="display:none" class="opd-input" />
                    </div>
                </div>

                <div class="opd-form-row opd-form-row--4">
                    <div class="opd-field" id="field_Services" style="display:none;">
                        <label class="opd-label">Services</label>
                        <select id="ddlServices" class="opd-select">
                            <option value="0">Select Service</option>
                        </select>
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
                    <div class="opd-field" id="costcenter" style="display:none;">
                        <label class="opd-label">Cost Center</label>
                        <select id="ddlCostCenter" class="opd-select">
                            <option value="0">Select Cost Center</option>
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
                    <div class="opd-field" id="emerDoctor" style="display:none;">
                        <label class="opd-label">Token Doctor</label>
                        <select id="ddlEmerDoctor" class="opd-select">
                            <option value="0">Select Doctor</option>
                        </select>
                    </div>
                    <div class="opd-field" id="pnlcompany">
                        <label class="opd-label">Panel Company</label>
                        <select id="ddlpanel" onchange="getpanelRate();" class="opd-select">
                            <option value="0">Select panel</option>
                        </select>
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
                    <div class="opd-field" id="discount">
                        <label class="opd-label">Discount %</label>
                        <input type="text" id="txtdiscount" onchange="Calc_Discount()" class="opd-input" />
                    </div>
                    <div class="opd-field" id="balance">
                        <label class="opd-label">Balance Amount</label>
                        <input type="text" id="txtbalance" class="opd-input" />
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
                    <div class="opd-field" id="Field-CIH">
                        <label class="opd-label">Cash In Hand</label>
                        <select id="ddlCashInHand" class="opd-select"></select>
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
                            <label for="txt_Othercnic">Other CNIC</label>
                            <input type="text" id="txt_Othercnic" class="form-control" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                            <input type="text" id="txt_mobile" class="form-control" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                            <select id="ddl_status" class="form-control">
                                <option value="0">Select Marital</option>
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
                        <div class="col-lg-3 col-md-4 col-sm-6" >
                            <label for="lblfee" id="lblfee">Fee</label>
                            <input type="text" disabled="disabled" tabindex="17" id="txtcardfees" class="form-control" />
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

