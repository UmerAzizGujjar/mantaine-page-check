<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Birthcertificate.aspx.cs" Inherits="PMS.Modules.PatientManagement.Birthcertificate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/birth-certificate.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            MaskedInput({
                elm: document.getElementById('txtCNIC'),
                format: '_____-_______-_',
                separator: '-'
            });
            // 1. Initialize Date Picker
            $('#txtBirthDate').datepicker({
                changeMonth: true,
                changeYear: true,
                dateFormat: "dd/mm/yy",
                yearRange: "-100:+0"
            });

            // Mask it so users can type manually if they want
            $('#txtBirthDate').mask("99/99/9999");

            // 2. Initialize Time Picker
            // Note: Standard jQuery UI doesn't have a timepicker. 
            // This assumes you have a plugin like 'jquery-timepicker' included in your Site.Master
            $('#txtBirthTime').ptTimeSelect();

            $(document).on('mousedown', function (e) {
                var $popup = $('.ui-timepicker-div, .ptTimeSelectContainer');
                var $input = $('#txtBirthTime');
                if ($popup.length && !$popup.is(e.target) && $popup.has(e.target).length === 0 && !$input.is(e.target)) {
                    $input.blur();
                    $popup.remove();
                }
            });



            $('#txt_cnic').attr('placeholder', '_____-_______-_');
            $('#txt_Othercnic').attr('placeholder', '_____-_______-_');
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

            jQuery(function ($) {
                MaskedInput({
                    elm: document.getElementById('txtSearch'), // select only by id
                    format: '+92__________',
                    separator: '-'
                });
                var phoneInput = document.getElementById('txtSearch');
                var cursorPosition = 3;
                phoneInput.setSelectionRange(cursorPosition, cursorPosition);
            });
            var BC_ID = '<%= Request.QueryString["BC_ID"]%>';
            if (BC_ID != "") {
                LoadBirthCertificate(BC_ID);
                $("#btnsave").val("Update")
            }
            
            fillgender();
            fillmartial();
            fillmrnos();
            fillNationality();
            fillProvince();
            fillReligion();
            fillBirthType();
            fillBirthGender();
            $("#txtSearch").keypress(function (event) {
                var SearchString = $('#txtSearch').val();
                if (event.which == 13) {
                    {
                        event.preventDefault();
                        if (SearchString != '') {
                            PageMethods.AddPatient((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterPatients, OnFailPatients);
                        }
                    }
                    if (SearchString === '') {
                        FillPatientsList();
                    }
                }

            });
            $("#txtSearch").keyup(function (event) {
                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillPatientsList();
            });
            setTimeout(function () {
                bindControls();

            }, 1000)
           
            var Reg_ID = '<%= Request.QueryString["Reg_ID"]%>';
            
            $('#hdfPatient_ID').val(Reg_ID);
            if (Reg_ID != "") {
                setTimeout(function () {
                    //FillTokenInputForMRNo();
                    selectPatient(Reg_ID)

                }, 1000)

            }
            
        });

        function fillBirthGender() {
            var options = '<option value="0">Select</option>';
            PageMethods.GetGender(function (data) {
                if (data) {
                    var genderList = JSON.parse(data);
                    $.each(genderList, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlBirthGender').html(options);
                }
            });
        }

        function fillBirthType() {
            var options = '<option value="0">Select</option>';
            PageMethods.GetBirthType(function (data) {
                if (data) {
                    var typeList = JSON.parse(data);
                    $.each(typeList, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlBirthType').html(options);
                }
            });
        }

        function fillReligion() {
            var options = '<option value="0">Select</option>';
            PageMethods.GetReligion(function (data) {
                if (data) {
                    var religionList = JSON.parse(data);
                    $.each(religionList, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlBirthReligion').html(options);
                }
            });
        }

        function fillProvince() {
            var options = '<option value="0">Select</option>';
            PageMethods.GetProvince(function (data) {
                if (data) {
                    var provinceList = JSON.parse(data);
                    $.each(provinceList, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlBirthProvince').html(options);
                }
            });
        }
        
        function fillNationality() {
            var options = '<option value="0">Select</option>';
            PageMethods.GetNationality(function (data) {
                if (data) {
                    var nationalityList = JSON.parse(data);
                    $.each(nationalityList, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#txtBirthFatherNationality').html(options);
                    $('#txtBirthMotherNationality').html(options);
                }
            });
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function bindControls() {
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "") {
                var Patient_ID = $("#hdfPatient_ID").val();
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                //loadtokenInputs(JSON.parse(tokendata));
                loadAjax();
            }
            else {
                loadtokenInputsDefault();
            }
        }
        function LoadBirthCertificate(Birth_Certificate_ID) {

            $.ajax({
                type: "POST",
                url: "BirthCertificate.aspx/GetBirthCertificate",
                data: JSON.stringify({
                    Birth_Certificate_ID: Birth_Certificate_ID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {

                    var data = JSON.parse(response.d);
                    if (data != null) {

                        $('#hdfPatient_ID').val(data.Patient_ID);
                        $('#hdfBC_ID').val(data.Birth_Certificate_ID);
                        $('#txtBirthChildName').val(data.Child_Name);
                        $('#ctl00_MainContent_txtIn_Patient_ID').val(data.Birth_Certificate_No);
                        $('#ddlBirthGender').val(data.Gender);
                        $('#txtBirthDate').val(data.Date_of_Birth);
                        $('#txtBirthTime').val(data.Time_of_Birth);
                        $('#txtBirthPlace').val(data.Place_of_Birth);
                        $('#txtBirthWeight').val(data.Birth_Weight);
                        $('#ddlBirthType').val(data.Birth_Type);
                        $('#txtBirthOrder').val(data.Birth_Order);

                        // Father
                        $('#txtBirthFatherName').val(data.Father_Name);
                        $('#txtBirthFatherCNIC').val(data.Father_CNIC);
                        $('#txtBirthFatherOccupation').val(data.Father_Occupation);
                        $('#txtBirthFatherNationality').val(data.Father_Nationality);

                        // Mother
                        $('#txtBirthMotherName').val(data.Mother_Name);
                        $('#txtBirthMotherCNIC').val(data.Mother_CNIC);
                        $('#txtBirthMotherOccupation').val(data.Mother_Occupation);
                        $('#txtBirthMotherNationality').val(data.Mother_Nationality);

                        // Registration
                        $('#txtBirthRegNumber').val(data.Registration_Number);
                        $('#txtBirthRegDate').val(data.Registration_Date);
                        $('#txtBirthRegistrar').val(data.Registrar_Name);
                        $('#txtBirthUnionCouncil').val(data.Union_Council);

                        // Address
                        $('#txtBirthAddress').val(data.Address);
                        $('#txtBirthCity').val(data.City);
                        $('#ddlBirthProvince').val(data.Province);
                        $('#txtBirthPostalCode').val(data.Postal_Code);

                        // Additional
                        $('#ddlBirthReligion').val(data.Religion);
                        $('#txtBirthAttendant').val(data.Birth_Attendant);
                        $('#txtBirthRemarks').val(data.Remarks);
                        //loadAjax()
                    }
                },

                error: function (xhr) {
                    alert(xhr.responseText);
                }
            });

        }
        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=PatientsForBirthCertificate",
                {

                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#hdfPatient_ID").val(item.id);

                            loadAjax();

                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                }
            );
        }
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=PatientsForBirthCertificate",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {

                        $("#hdfPatient_ID").val(item.id);
                        loadAjax();
                    }
                });
        }

        function loadAjax() {
            var Patient_ID = $("#hdfPatient_ID").val();
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/GetDetail",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function OnSuccess(data) {
            if (data.d != '') {

                if (data.d.PatientType == null)
                    data.d.PatientType = "";

                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID%>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID%>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID%>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID%>').text(dateR);
                $('#<%= vLbl_Adress.ClientID%>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID%>').text(data.d.Mobile);

                $('#<%= vLbl_Patient_Type.ClientID%>').text(data.d.PatientType);


                $('#<%= vLbl_Patient_AdmitCatagory.ClientID%>').text(data.d.Type);

                var NIC = data.d.NIC;
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
                                PatientMonitoring();
                            }
                        });
                    }

                }


            }
        }

        function selectPatient(Patient_ID) {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
            var parsedData = JSON.parse(tokenData);
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

            $('#<%= txtPatient_ID.ClientID%>').val(Patient_ID);
            $('#<%= hdfPatient_IDs.ClientID%>').val(Patient_ID);
          //  checkRepeat();
            loadAjax();
            $('#btnSave').val("Save");
            $('#ctl00_MainContent_txtIn_Patient_ID').val("(New)");
            //LoadHistory();
        }
       <%--function selectPatient(Patient_ID) {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
            var parsedData = JSON.parse(tokenData);
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

            $('#<%= txtPatient_ID.ClientID%>').val(Patient_ID);

            loadAjax();
            $('#btnSave').val("Save");
            $('#txtIn_Patient_ID').val("(New)");
        }--%>
        function OpenModal() {
            $('#PatientsSearchModel').modal({
                backdrop: 'static'
            });
            FillPatientsList();
            $('#srchpat').text("Search Your Patients:");
            $('#txtSearch').unmask();
            $('#ClosePatientsSearchModel').show();
        }
        function FillPatientsList() {
            $('#tblPatientsResult tbody').empty();
            var SearchString = '';
            PageMethods.AddPatient(SearchString, OnFilterPatients, OnFailPatients);
        }
        function OnFilterPatients(data) {

            ClearPatientResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
            }
        }
        var btnVal = '';
        function SavePatient() {
            $('#SavePatient_Data').attr('disabled', true);
            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();
            var PatientID = $('#hdfPatient_ID').val();
            var Full_Name = Prefix_PatientName + PatientName;
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();
            var Mobile = $('#txt_mobile').val();
            var PreFix_DOB = $('#ddl_dob').val();
            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();
            var CNIC = $('#txt_cnic').val();
            var OtherCNIC = $('#txt_Othercnic').val();
            var Address = $('#txt_Address').val();
            var martail_status = $('#ddl_status').val();
            var txtfees = $('#txtfees').val();

            if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || Address == "")) {
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

            var data = JSON.stringify({
                "Full_Name": Full_Name,
                "RelationType": RelationType,
                "Relation": Relation,
                "Gender": Gender,
                "Mobile": Mobile,
                "Date_Of_Birth": Date_Of_Birth,
                "CNIC": CNIC,
                "OtherCNIC": OtherCNIC,
                "Address": Address,
                "PatientID": PatientID,
                "martail_status": martail_status,
                "Age": Age,
                "txtfees": txtfees,
            });

            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/SavePatientDetail",
                data: data,
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
                        }).then(function () {
                            $('#SavePatient_Data').attr('disabled', false);
                        });
                        return;
                    }

                    // Check for other errors
                    if (response.d && response.d.startsWith("ERROR:")) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: response.d.replace("ERROR:", ""),
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        }).then(function () {
                            $('#SavePatient_Data').attr('disabled', false);
                        });
                        return;
                    }

                    var Reg_Patient_ID = response.d;
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
                    AddPatientDetail(Reg_Patient_ID);
                    $('#SavePatient_Data').attr('disabled', false);
                },
                error: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Error while saving data. Please try again',
                        confirmButtonText: 'OK',
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    }).then(function () {
                        $('#SavePatient_Data').attr('disabled', false);
                    });
                }
            });
        }

        function isCNICValidationRequired() {
            var result = false;
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/CNICValidation",
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
        function ClearPatientResults() {
            while (tblPatientsResult.rows.length > 1) {
                tblPatientsResult.deleteRow(1);
            }
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

            var $input = $('#txtBirthDate');
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
        function fillmrnos() {
            var data = {};
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/Getmr_noss",
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
        function OnFailPatients(exc) {
            alert(exc.get_message());
        }
        function AddNewPatient() {
            $('#ddl_pnl_cpy').next(".select2-container").hide();
            clearPatient();
            $('#hdfPatient_ID').val('(New)');
            $('#PatientModel').modal({
                backdrop: 'static'
            });
            $("#ddl_name").focus();

        }
        function NewWindow() {

            window.location = "Birthcertificate.aspx";
        }
        function BackToList() {

            window.open("BirthCertificateView.aspx", '_blank');
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
            var actions = ''
            actions += '<a style="color:#438eb9 ;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i></a>&nbsp;|&nbsp;&nbsp;';
            actions += '<a style="color:#FDC303;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-pencil-square-o"></i></a>';
            cell.innerHTML = actions;
        }
        function addfunc() {
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
           // fillmrnos();
            setTimeout(function () {
                $('#txt_mobile').val(unmaskedValue);
            }, 100);
            $('#txt_name').focus();
            CheckAndLoadWalkinPatientRegFee();
        }
        function CheckAndLoadWalkinPatientRegFee() {
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/IsWalkinPatientRegFeeActive",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var isActive = response.d;

                    if (isActive == "01") {

                        $('#txtfees').show();
                        $('#lblfees').show();


                        // Now get the actual fee amount
                        GetWalkinPatientRegFee();
                    } else {
                        // Hide the txtfees field
                        $('#txtfees').hide(); // or $('#feesRow').hide();
                        $('#lblfees').hide(); // or $('#feesRow').hide();
                        $('#txtfees').val('0');
                        $('#txtfees').prop('disabled', true);
                    }
                },
                error: function (error) {
                    console.error("Error checking registration fee status:", error);
                    $('#txtfees').hide();
                }
            });
        }

        function GetWalkinPatientRegFee() {
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/GetWalkinPatientRegFee",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var fee = response.d;
                    if (fee && fee != '0' && fee != 'null' && fee != '') {
                        fee = fee.replace(/["']/g, '');
                        $('#txtfees').val(fee);
                    } else {
                        $('#txtfees').val('0');
                    }
                },
                error: function (error) {
                    console.error("Error fetching registration fee:", error);
                    $('#txtfees').val('0');
                }
            });
        }
        var isAdd = false;
        function AddPatientDetail(Reg_Patient_ID) {
            try {
                isAdd = true;
                window.location.href = "Birthcertificate.aspx?Reg_ID=" + Reg_Patient_ID;

            } catch (err) {
                alert(err.message);
            }
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
        function EditPatientDetail(id) {
            // First check permission
            PageMethods.EditPatient(id, function (msg) {
                if (msg === "NotAllowed") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Access Denied',
                        text: 'You do not have permission to edit this patient.',
                        confirmButtonColor: '#d33'
                    });
                } else if (msg === "Allowed") {
                    // Permission granted, proceed with edit
                    var Patient_ID = $('#hdfPatient_ID').val();

                    $('#CloseSearchModel').click(function () {
                        window.location.href = "Birthcertificate.aspx";
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
                            url: "Birthcertificate.aspx/GetEditPatientDetails",
                            data: "{'Reg_Patient_ID':" + id + "}",
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: OnSuccessEdit,
                            failure: function (response) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: response.d
                                });
                            }
                        });
                    }
                    setTimeout(ajaxFn, 3000);
                }
            });
        }
        var inPatientID;
        var Discharged;
        function OnSuccessEdit(data) {
            if (data.d != '') {

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
                //    $('#txtAge_yearss').val(stDate);
                //}

                if (data.d.DOB) {
                    $('#txtAge_yearss').val(data.d.DOB);
                }

                $("#ddltest_main_dpt").val(data.d.department).change();

                $('#ddlRelation').val(data.d.Relation).trigger('change');
                $('#ddl_name').val(data.d.Title).trigger('change');
                $("#txt_relation").val(data.d.FatherName);
                $("#txt_mobile").val(data.d.Mobile);
                $("#txt_cnic").val(data.d.CNIC);
                $("#txt_Othercnic").val(data.d.OtherCNIC);
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
        //var isCertificateGenrate = false;
        function GenrateCertificate() {
            var inPatientID = $('#ctl00_MainContent_txtIn_Patient_ID').val();



            // Validate required fields
            var childName  = $('#txtBirthChildName').val();
            var fatherName = $('#txtBirthFatherName').val();
            var motherName = $('#txtBirthMotherName').val();
            var fatherCNIC = $('#txtBirthFatherCNIC').val();
            var motherCNIC = $('#txtBirthMotherCNIC').val();

            if (!childName || !fatherName || !motherName) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Incomplete Information',
                    text: 'Please fill Child Name, Father Name, and Mother Name first.',
                    confirmButtonText: 'OK'
                });
                return;
            }

            if (!fatherCNIC || !motherCNIC) {
                Swal.fire({
                    icon: 'warning',
                    title: 'CNIC Required',
                    text: 'Father and Mother CNIC are required for NADRA registration.',
                    confirmButtonText: 'OK'
                });
                return;
            }
            window.isCertificateGenrate = true;

            // Just call save - don't show loading here
            SaveAllRecords();
        }

        function PrintGenrateCertificate(Birth_Certificate_ID)
        {
            var url = '../../ReportViewer.aspx?ReportName=Birth_Certificate&ReportTitle=Admission Slip Report&Inpatient_ID=' + Birth_Certificate_ID;
            window.open(url, '_blank');

        }

        function SaveAllRecords() {
            $('#btnsave').attr('disabled', true);
            var btnsave = $('#btnsave').val();
            var Patient_ID = $("#hdfPatient_ID").val();
           
            var BC_ID = '<%= Request.QueryString["BC_ID"]%>';
            if (BC_ID == "") {
                var Birth_Id = 0;
            }
            else {
                var Birth_Id = $("#hdfBC_ID").val();
            }
            // Birth Certificate Fields
            var BirthChildName = $('#txtBirthChildName').val();
            var BirthGender = $('#ddlBirthGender').val();
            var BirthDate = $('#txtBirthDate').val();
            var BirthTime = $('#txtBirthTime').val();
            var BirthPlace = $('#txtBirthPlace').val();
            var BirthWeight = $('#txtBirthWeight').val();
            var BirthType = $('#ddlBirthType').val();
            var BirthOrder = $('#txtBirthOrder').val();
            var BirthFatherName = $('#txtBirthFatherName').val();
            var BirthFatherCNIC = $('#txtBirthFatherCNIC').val();
            var BirthFatherOccupation = $('#txtBirthFatherOccupation').val();
            var BirthFatherNationality = $('#txtBirthFatherNationality').val();
            var BirthMotherName = $('#txtBirthMotherName').val();
            var BirthMotherCNIC = $('#txtBirthMotherCNIC').val();
            var BirthMotherOccupation = $('#txtBirthMotherOccupation').val();
            var BirthMotherNationality = $('#txtBirthMotherNationality').val();
            var BirthRegNumber = $('#txtBirthRegNumber').val();
            var BirthRegDate = $('#txtBirthRegDate').val();
            var BirthRegistrar = $('#txtBirthRegistrar').val();
            var BirthUnionCouncil = $('#txtBirthUnionCouncil').val();
            var BirthAddress = $('#txtBirthAddress').val();
            var BirthCity = $('#txtBirthCity').val();
            var BirthProvince = $('#ddlBirthProvince').val();
            var BirthPostalCode = $('#txtBirthPostalCode').val();
            var BirthReligion = $('#ddlBirthReligion').val();
            var BirthAttendant = $('#txtBirthAttendant').val();
            var BirthRemarks = $('#txtBirthRemarks').val();
            var isCertificateGenrate = window.isCertificateGenrate || false;

            PageMethods.SaveAllRecord(
                Patient_ID, Birth_Id, btnsave,
                BirthChildName, BirthGender, BirthDate, BirthTime, BirthPlace, BirthWeight,
                BirthType, BirthOrder, BirthFatherName, BirthFatherCNIC, BirthFatherOccupation,
                BirthFatherNationality, BirthMotherName, BirthMotherCNIC, BirthMotherOccupation,
                BirthMotherNationality, BirthRegNumber, BirthRegDate, BirthRegistrar,
                BirthUnionCouncil, BirthAddress, BirthCity, BirthProvince, BirthPostalCode,
                BirthReligion, BirthAttendant, BirthRemarks, isCertificateGenrate,
                function (response) {

                    console.log(response);

                    // Handle backend error
                    if (response && response.toString().startsWith("ERROR:")) {

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: response.replace("ERROR:", ""),
                            confirmButtonText: 'OK'
                        });
                        $('#btnsave').attr('disabled', false);
                        return;
                    }

                    // Success
                    var savedId = response;

                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Successfully Saved',
                        showConfirmButton: false,
                        timer: 1500
                    });

                    $('#btnsave').val("Update");

                    setTimeout(function () {
                        window.location.href = 'Birthcertificate.aspx?BC_ID=' + savedId;
                    }, 1600);

                },

                function (error) {

                    console.log(error);
                    $('#btnsave').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Server Error!',
                        text: 'Unable to save record.'
                    });

                }
            );
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="bc-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="bc-badge"><span class="bc-badge-label">Patient</span><span class="bc-badge-value" id="badgeBcPatient">---</span></div>
                <div class="bc-badge"><span class="bc-badge-label">In Patient</span><span class="bc-badge-value" id="badgeBcIpd">New</span></div>
                <div class="bc-badge"><span class="bc-badge-label">Reg #</span><span class="bc-badge-value" id="badgeBcReg">---</span></div>
            </div>
        </div>

        <!-- Patient + admission -->
        <div class="bc-layout2">
            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-user-circle"></i> Patient Information
                    <input type="button" value="Add Patient" id="btnSearchPatient" onclick="OpenModal()" class="btn-primry bc-title-btn" />
                </h5>
                <div class="bc-patient">
                    <div class="bc-avatar">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/IpdAdmissions.png" alt="Patient Image" />
                    </div>
                    <div class="bc-who">
                        <div class="bc-field">
                            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :*" CssClass="bc-lbl"></asp:Label>
                            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                            <asp:HiddenField ID="hdfPatient_IDs" runat="server" Value="(New)" ClientIDMode="Static" />
                            <input type="hidden" id="hdfPatient_ID" value="(New)" />
                            <input type="hidden" id="hdfBC_ID" />
                            <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                </div>
                <dl class="bc-info">
                    <div class="bc-span-2"><dt><asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label></dt><dd><asp:Label ID="vlblPatients_Name" runat="server"></asp:Label></dd></div>
                    <div><dt><asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label></dt><dd><asp:Label ID="vLbl_Contact" runat="server"></asp:Label></dd></div>
                    <div><dt><asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label></dt><dd><asp:Label ID="vLbl_Age" runat="server"></asp:Label></dd></div>
                    <div><dt><asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label></dt><dd><asp:Label ID="vLbl_Gender" runat="server"></asp:Label></dd></div>
                </dl>
            </section>

            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-hospital-o"></i> Admission</h5>
                <div class="bc-grid">
                    <div class="bc-field">
                        <asp:Label ID="LblIn_Patient_ID" runat="server" Text="In Patient No" CssClass="bc-lbl"></asp:Label>
                        <asp:TextBox ID="txtIn_Patient_ID" runat="server" Text="(New)" ReadOnly="True"></asp:TextBox>
                    </div>
                </div>
                <dl class="bc-info" style="margin-top: 14px;">
                    <div><dt><asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label></dt><dd><asp:Label ID="vLbl_RegDate" runat="server"></asp:Label></dd></div>
                    <div><dt><asp:Label ID="Label36" runat="server" Text="Patient Type:"></asp:Label></dt><dd><asp:Label ID="vLbl_Patient_Type" runat="server" style="background-color: silver;"></asp:Label></dd></div>
                    <div class="bc-span-2"><dt><asp:Label ID="Label35" runat="server" Text="InPatient Admit Catagory :"></asp:Label></dt><dd><asp:Label ID="vLbl_Patient_AdmitCatagory" runat="server"></asp:Label></dd></div>
                    <div class="bc-span-2"><dt><asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label></dt><dd><asp:Label ID="vLbl_Adress" runat="server"></asp:Label></dd></div>
                </dl>
            </section>
        </div>

        <!-- Birth certificate details -->
        <div id="Tab-14" class="bc-col">

            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-child"></i> Child Information</h5>
                <input type="hidden" id="Birth_Id" />
                <div class="bc-grid">
                    <div class="bc-field bc-span-2">
                        <label for="txtBirthChildName">Child's Full Name *</label>
                        <input type="text" id="txtBirthChildName" class="bc-input" placeholder="Enter child's full name" />
                    </div>
                    <div class="bc-field">
                        <label for="ddlBirthGender">Gender *</label>
                        <select id="ddlBirthGender" class="bc-input">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthDate">Date of Birth *</label>
                        <input type="text" id="txtBirthDate" class="bc-input" placeholder="mm/dd/yyyy" />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthTime">Time of Birth</label>
                        <input type="text" id="txtBirthTime" class="bc-input" placeholder="hh:mm AM/PM" />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthPlace">Place of Birth *</label>
                        <input type="text" id="txtBirthPlace" class="bc-input" placeholder="City/District" />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthWeight">Birth Weight (kg)</label>
                        <input type="text" id="txtBirthWeight" class="bc-input" placeholder="e.g., 3.2" />
                    </div>
                    <div class="bc-field">
                        <label for="ddlBirthType">Type of Birth</label>
                        <select id="ddlBirthType" class="bc-input">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthOrder">Birth Order</label>
                        <input type="text" id="txtBirthOrder" class="bc-input" placeholder="1st, 2nd, etc." />
                    </div>
                </div>
            </section>

            <div class="bc-layout2">
                <section class="bc-card">
                    <h5 class="bc-card-title"><i class="fa fa-male"></i> Father's Information</h5>
                    <div class="bc-grid">
                        <div class="bc-field">
                            <label for="txtBirthFatherName">Father's Full Name *</label>
                            <input type="text" id="txtBirthFatherName" class="bc-input" placeholder="Enter father's full name" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthFatherCNIC">Father's CNIC *</label>
                            <input type="text" id="txtBirthFatherCNIC" class="bc-input" placeholder="XXXXX-XXXXXXX-X" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthFatherOccupation">Occupation</label>
                            <input type="text" id="txtBirthFatherOccupation" class="bc-input" placeholder="Occupation" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthFatherNationality">Nationality</label>
                            <select id="txtBirthFatherNationality" class="bc-input">
                                <option value="0">Select</option>
                            </select>
                        </div>
                    </div>
                </section>

                <section class="bc-card">
                    <h5 class="bc-card-title"><i class="fa fa-female"></i> Mother's Information</h5>
                    <div class="bc-grid">
                        <div class="bc-field">
                            <label for="txtBirthMotherName">Mother's Full Name *</label>
                            <input type="text" id="txtBirthMotherName" class="bc-input" placeholder="Enter mother's full name" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthMotherCNIC">Mother's CNIC *</label>
                            <input type="text" id="txtBirthMotherCNIC" class="bc-input" placeholder="XXXXX-XXXXXXX-X" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthMotherOccupation">Occupation</label>
                            <input type="text" id="txtBirthMotherOccupation" class="bc-input" placeholder="Occupation" />
                        </div>
                        <div class="bc-field">
                            <label for="txtBirthMotherNationality">Nationality</label>
                            <select id="txtBirthMotherNationality" class="bc-input">
                                <option value="0">Select</option>
                            </select>
                        </div>
                    </div>
                </section>
            </div>

            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-registered"></i> Registration Information</h5>
                <div class="bc-grid">
                    <div class="bc-field">
                        <label for="txtBirthRegNumber">Registration Number</label>
                        <input type="text" id="txtBirthRegNumber" class="bc-input" placeholder="Auto-generated" readonly />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthRegDate">Registration Date</label>
                        <input type="text" id="txtBirthRegDate" class="bc-input" readonly />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthRegistrar">Registrar Name</label>
                        <input type="text" id="txtBirthRegistrar" class="bc-input" placeholder="Registrar name" />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthUnionCouncil">Union Council</label>
                        <input type="text" id="txtBirthUnionCouncil" class="bc-input" placeholder="Union Council" />
                    </div>
                </div>
            </section>

            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-home"></i> Permanent Address</h5>
                <div class="bc-grid">
                    <div class="bc-field bc-span-2">
                        <label for="txtBirthAddress">Address</label>
                        <input type="text" id="txtBirthAddress" class="bc-input" placeholder="House No., Street, Area" />
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthCity">City/District</label>
                        <input type="text" id="txtBirthCity" class="bc-input" placeholder="City/District" />
                    </div>
                    <div class="bc-field">
                        <label for="ddlBirthProvince">Province</label>
                        <select id="ddlBirthProvince" class="bc-input">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthPostalCode">Postal Code</label>
                        <input type="text" id="txtBirthPostalCode" class="bc-input" placeholder="Postal code" />
                    </div>
                </div>
            </section>

            <section class="bc-card">
                <h5 class="bc-card-title"><i class="fa fa-info-circle"></i> Additional Information</h5>
                <div class="bc-grid">
                    <div class="bc-field">
                        <label for="ddlBirthReligion">Religion</label>
                        <select id="ddlBirthReligion" class="bc-input">
                            <option value="0">Select</option>
                        </select>
                    </div>
                    <div class="bc-field">
                        <label for="txtBirthAttendant">Birth Attendant</label>
                        <input type="text" id="txtBirthAttendant" class="bc-input" placeholder="Doctor/Nurse/Midwife" />
                    </div>
                    <div class="bc-field bc-span-all">
                        <label for="txtBirthRemarks">Remarks</label>
                        <textarea id="txtBirthRemarks" class="bc-input" rows="2" placeholder="Any additional remarks"></textarea>
                    </div>
                </div>

                <!-- Certificate buttons -->
                <div class="bc-actions bc-actions-inner">
                    <div id="GenrateCertificate">
                        <input value="Generate" class="btn-primry" id="genrateCerti" type="button" onclick="GenrateCertificate()" />
                    </div>
                    <div id="Printbirth">
                        <input value="Print Certificate" class="btn-primry" id="Printbirthcertificate" type="button" onclick="PrintGenrateCertificate($('#hdfBC_ID').val())" />
                    </div>
                </div>
            </section>
        </div>

        <div class="bc-actions">
            <div>
                <input type="button" class="btn-primry" id="btnsave" value="Save" onclick="SaveAllRecords();" />
            </div>
            <div>
                <input type="button" class="btn btn-yellow" value="New" name="btnName" onclick="NewWindow()" />
            </div>
            <div>
                <input type="button" class="btn btn-gray" id="btnBackList" value="View " onclick="BackToList()" />
            </div>
        </div>

    </div>

    <script type="text/javascript">
        // title-line badges follow the form (the page script fills the fields in after loading)
        function syncBirthBadges() {
            $('#badgeBcPatient').text($.trim($('#<%= vlblPatients_Name.ClientID %>').text()) || '---');
            $('#badgeBcIpd').text($('#<%= txtIn_Patient_ID.ClientID %>').val() || 'New');
            $('#badgeBcReg').text($('#txtBirthRegNumber').val() || '---');
        }
        $(function () {
            syncBirthBadges();
            setInterval(syncBirthBadges, 600);
        });
    </script>

    <!-- patient search window -->
    <div id="PatientsSearchModel" data-backdrop="static" class="modal fade-in bc-modal" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="srchpat">Search Your Patients</h4>
                </div>
                <div class="modal-body">
                    <div class="bc-search-row">
                        <div class="bc-field">
                            <label for="txtSearch">Name or MR No.</label>
                            <input type="text" id="txtSearch" class="bc-input" autocomplete="off" />
                        </div>
                        <input type="button" class="btn btn-primry" id="addNewbtn" onclick="addfunc()" value="Add New" />
                    </div>
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblPatientsResult">
                            <thead id="Thead1">
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
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <input type="button" id="ClosePatientsSearchModel" class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>

    <%--patient modal here--%>
    <div id="PatientModel" class="modal fade-in bc-modal" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content modalSize">
                <div class="modal-header">
                    <h4 class="modal-title">Patient Details</h4>
                </div>
                <form>
                    <div class="modal-body">
                        <div class="bc-grid bc-modal-grid">
                            <div class="bc-field">
                                <label>MR No</label>
                                <input type="text" tabindex="1" id="txt_Mrno" class="bc-input" value="New" disabled />
                            </div>
                            <div class="bc-field">
                                <label>Gender<span class="bc-req">*</span></label>
                                <select id="ddl_Gender" tabindex="5" class="bc-input">
                                </select>
                            </div>
                            <div class="bc-field">
                                <label>Martial Status<span class="bc-req">*</span></label>
                                <select tabindex="6" id="ddl_status" class="bc-input">
                                    <option></option>
                                </select>
                            </div>

                            <div class="bc-field bc-span-2">
                                <label>Name<span class="bc-req">*</span></label>
                                <div class="bc-inline">
                                    <select tabindex="3" name="name" id="ddl_name" class="bc-input bc-inline-sel">
                                        <option value="Mr.">Mr.</option>
                                        <option value="Mrs.">Mrs.</option>
                                        <option value="Ms.">Ms.</option>
                                        <option value="B/O.">B/O.</option>
                                    </select>
                                    <input name="dob" type="text" id="txt_name" tabindex="4" class="bc-input" />
                                </div>
                            </div>
                            <div class="bc-field">
                                <label>Mobile<span class="bc-req">*</span></label>
                                <input type="text" tabindex="9" id="txt_mobile" class="bc-input" />
                            </div>

                            <div class="bc-field bc-span-2">
                                <label>Relation<span class="bc-req">*</span></label>
                                <div class="bc-inline">
                                    <select tabindex="7" name="name" id="ddlRelation" class="bc-input bc-inline-sel">
                                        <option value="S/O">S/O</option>
                                        <option value="W/O">W/O</option>
                                        <option value="D/O">D/O</option>
                                    </select>
                                    <input type="text" id="txt_relation" tabindex="8" class="bc-input" />
                                </div>
                            </div>
                            <div class="bc-field">
                                <label>CNIC<span class="bc-req">*</span></label>
                                <input tabindex="12" type="text" id="txt_cnic" class="bc-input" />
                            </div>

                            <div class="bc-field bc-span-2">
                                <label>Age/DOB<span class="bc-req">*</span></label>
                                <div class="bc-inline">
                                    <select name="name" tabindex="10" id="PrefixAge" class="bc-input bc-inline-sel">
                                        <option value="Year">Year</option>
                                        <option value="Month">Month</option>
                                        <option value="Day">Day</option>
                                    </select>
                                    <input type="text" id="txt_dob" tabindex="11" class="bc-input" onchange="CalculateDateOfBirth();" />
                                    <input class="bc-input" type="text" id="txtAge_yearss" placeholder="mm ddyy" />
                                </div>
                            </div>
                            <div class="bc-field">
                                <label>Other CNIC</label>
                                <input tabindex="12" type="text" id="txt_Othercnic" class="bc-input" />
                            </div>

                            <div class="bc-field bc-span-2">
                                <label>Address<span class="bc-req">*</span></label>
                                <input type="text" tabindex="13" id="txt_Address" class="bc-input" />
                            </div>
                            <div class="bc-field">
                                <label id="lblfees">Fees<span class="bc-req">*</span></label>
                                <input tabindex="9" type="text" disabled="disabled" style="display:none" id="txtfees" class="bc-input" />
                            </div>
                        </div>
                    </div>
                </form>
                <div class="modal-footer">
                    <input type="button" id="SavePatient_Data" class="btn btn-primry" tabindex="10" name="savePatient_Data" value="Save" onclick="SavePatient();" />
                    <input type="button" id="updatePatient_Data" class="btn btn-primry" name="updatePatient_Data" style="text-transform: capitalize;" value="Update" onclick="SavePatient();" tabindex="23" />
                    <input type="button" id="CloseSearchModel" class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
