<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Birthcertificate.aspx.cs" Inherits="PMS.Modules.PatientManagement.Birthcertificate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ipdadmission.css" rel="stylesheet" />
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
            $('#txtBirthTime').ptTimeSelect({
                onClose: function () {
                    $('#txtBirthTime').focus();
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
            debugger;
            var BC_ID = '<%= Request.QueryString["BC_ID"]%>';
            if (BC_ID != "") {
                debugger;
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
        debugger;
        function bindControls() {
            debugger;
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
                    debugger;
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
            debugger;
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Patients",
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
            debugger;
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=Patients",
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
            debugger;
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
            debugger;
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
            debugger;
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
            debugger;
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
            debugger;
            $('#PatientsSearchModel').modal({
                backdrop: 'static'
            });
            FillPatientsList();
            $('#srchpat').text("Search Your Patients:");
            $('#txtSearch').unmask();
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
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
            }
        }
        var btnVal = '';
        debugger;
        function SavePatient() {
            debugger;
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
                    debugger;

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
        debugger;
        function fillmrnos() {
            debugger;
            var data = {};
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/Getmr_noss",
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
        function OnFailPatients(exc) {
            alert(exc.get_message());
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
        function NewWindow() {

            window.location = "Birthcertificate.aspx";
        }
        function BackToList() {

            window.open("BirthCertificateView.aspx", '_blank');
        }
        function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
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
           // fillmrnos();
            setTimeout(function () {
                $('#txt_mobile').val(unmaskedValue);
            }, 100);
            $('#txt_name').focus();
            CheckAndLoadWalkinPatientRegFee();
        }
        function CheckAndLoadWalkinPatientRegFee() {
            debugger;
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/IsWalkinPatientRegFeeActive",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
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
            debugger;
            $.ajax({
                type: "POST",
                url: "Birthcertificate.aspx/GetWalkinPatientRegFee",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
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
            debugger;
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
            debugger;
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

        function SaveAllRecords() {
            debugger;
            var btnsave = $('#btnsave').val();
            var Patient_ID = $("#hdfPatient_ID").val();
           
            var BC_ID = '<%= Request.QueryString["BC_ID"]%>';
            if (BC_ID == "") {
                debugger;
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

                        return;
                    }

                    // Success
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Successfully Saved',
                        showConfirmButton: false,
                        timer: 2500
                    });

                    $('#btnsave').val("Update");

                    // Saved ID
                    console.log("Saved ID:", response);

                },

                function (error) {

                    console.log(error);

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

        <div class="col-lg-8 col-md-10 col-sm-12">
        <div class="row">
            <div class="col-md-2 text-end">
                <input type="button" value="Add Patient" id="btnSearchPatient" onclick="OpenModal()" class="btn-primry" />
            </div>
        </div>
    </div>
      
<div id="PatientsSearchModel" data-backdrop="static" class="modal fade-in" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -78px; height: 604px; position: relative;">
            <fieldset style="padding-top: 20px; padding-left: 14px;">
                <div class="col-lg-3 col-md-4 col-sm-6">                           
                <label id="srchpat">Search Your Patients: </label>
                    <input type="text" id="txtSearch" style="margin-left: 2px;" autocomplete="off" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label></label>
                    <input type="button" class="btn btn-primry" id="addNewbtn" onclick="addfunc()" value="Add New" />
                </div>
                
            </fieldset>
            <div style="overflow: scroll; height: 460px; padding: 10px;">
                <table class="table table-hover table-striped table-bordered" id="tblPatientsResult" style="overflow: scroll; height: auto;">
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
            <div class="modal-footer">
                <input type="button" style="width:13% !important" id="ClosePatientsSearchModel" class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
            </div>

        </div>

    </div>

</div>
<%--patient modal here--%>
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
                            <label>Gender<span style="color:red;">*</span></label>
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
                            <label>Martial Status<span style="color:red;">*</span></label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <select  tabindex="6" id="ddl_status" style="width: 197px;">
                                <option></option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Relation<span style="color:red;">*</span></label>
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
                            <label>Mobile<span style="color:red;">*</span></label>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input type="text" tabindex="9" id="txt_mobile" style="width: 197px !important;" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Age/DOB<span style="color:red;">*</span></label>
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
                            <label>CNIC<span style="color:red;">*</span></label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input tabindex="12"  type="text" id="txt_cnic" style="width: 200px !important" />
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-1 col-md-3 col-sm-4"></div>
                        <div class="col-lg-1 col-md-3 col-sm-4">
                            <label>Address<span style="color:red;">*</span></label>
                        </div>

                        <div class="col-lg-5 col-md-3 col-sm-4">
                            <input type="text"  tabindex="13" id="txt_Address"  />
                        </div>
                        
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>Other CNIC</label>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input tabindex="12" type="text" id="txt_Othercnic" style="width: 200px !important" />
                        </div>
                                <div class="col-lg-2 col-md-3 col-sm-4" >
                            <label id="lblfees">Fees<span style="color:red;">*</span></label>
                        </div>

                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <input tabindex="9"  type="text" disabled="disabled" style="display:none" id="txtfees" />
                        </div>
                    </div>
                </div>
            </form>


            <div class="modal-footer" style="margin-top: 6%;">
                <input type="button"  id="SavePatient_Data" class="btn btn-primry" tabindex="10" name="savePatient_Data" value="Save" style="width:10% !important" onclick="SavePatient();" />
                <input type="button" id="updatePatient_Data" class="btn btn-primry"  name="updatePatient_Data" style="text-transform: capitalize;width:10% !important" value="Update" onclick="SavePatient();" tabindex="23" />
                <input type="button" id="CloseSearchModel" class="btn-gray" style="width:10% !important" name="saveENT" value="Close" data-dismiss="modal" />
            </div>
        </div>
    </div>
</div>

            <div class="row">
<!-- Left Card -->
<div class="col-lg-5 col-md-5 col-sm-12">
    <div class="card">
        <div class="card-body">
            <div class="row">
                <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                    <div class="image-container">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/IpdAdmissions.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                    </div>
                </div>
                <div class="col-lg-8 col-md-7 col-sm-6">
                    <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :*"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6">
                            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                              <asp:HiddenField ID="hdfPatient_IDs" runat="server" Value="(New)" ClientIDMode="Static" />
                            <input type="hidden" id ="hdfPatient_ID" value="(New)" />
                            <input type="hidden" id ="hdfBC_ID"  />
                              <%--<asp:HiddenField ID="hdfPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />--%>
                            <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                    <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 ">
                            <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6 ">
                             <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                             <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                            <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                            <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-3 mtt">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                           <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
 </div>
            <!-- Right Card -->
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="LblIn_Patient_ID" runat="server" Text="In Patient No"></asp:Label>
                            </div>
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                 <asp:TextBox ID="txtIn_Patient_ID" runat="server" Text="(New)" ReadOnly="True"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 top">
                                  <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                            </div>
                        </div>
                         </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                             <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                             <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                             <asp:Label ID="Label36" runat="server" Text="Patient Type:"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                           <asp:Label ID="vLbl_Patient_Type" runat="server" style="background-color: silver;"></asp:Label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                           <asp:Label ID="Label35" runat="server" Text="InPatient Admit Catagory :"></asp:Label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                             <asp:Label ID="vLbl_Patient_AdmitCatagory" runat="server" ></asp:Label>
                        </div>
                    </div>
                        </div>
                    </div>                    
               </div>
        <style type="text/css">
                .cnic-input {
    width: 250px !important;
    margin: 0 auto;   /* center it */
    display: block;
}
        .mgTab {
            padding-left: 100px;
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
        /* Birth Certificate Tab Styles */
        .compact-card {
            margin-bottom: 15px;
            border: 1px solid #999999;
            border-radius: 6px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

            .compact-card .card-header {
                background-color: #f8f9fa;
                padding: 8px 15px;
                border-bottom: 1px solid #b9b9b9;
                border-radius: 6px 6px 0 0;
            }

                .compact-card .card-header h4 {
                    margin: 0;
                    font-size: 16px;
                    font-weight: 600;
                    color: #2c3e50;
                }

            .compact-card .card-body {
                padding: 12px 15px;
            }

        .compact-row {
            margin: 0 -8px;
        }

            .compact-row [class*="col-"] {
                padding: 0 8px;
                margin-bottom: 10px;
            }

        .compact-card label {
            font-size: 12px;
            font-weight: 500;
            margin-bottom: 3px;
            color: #555;
            display: block;
        }

        .compact-card input,
        .compact-card select,
        .compact-card textarea {
            font-size: 13px;
            padding: 4px 8px;
            height: 30px;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .compact-card textarea {
            height: 60px;
            resize: vertical;
        }

        .compact-card hr {
            margin: 8px 0;
        }

        .compact-card .form-group {
            margin-bottom: 0;
        }

        /* Remove extra spacing from parent containers */
        #Tab-14 .mt {
            margin-top: 0 !important;
        }

        #Tab-14 .row {
            margin-bottom: 0;
        }

        .section-divider {
            margin: 0 0 10px 0;
            border-top: 1px solid #eee;
        }
        #Tab-14{
            border:1px solid;
                padding: 15px;
    border-radius: 10px;
    border-color: gainsboro;
        }
    </style>
     <%--    <div id="Tab-14" >
         <div class="row compact-row">
        <!-- Child Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-child"></i> Child Information</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthChildName" runat="server" Text="Child's Full Name *"></asp:Label>
                            <asp:TextBox ID="txtBirthChildName" runat="server" placeholder="Enter child's full name"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthGender" runat="server" Text="Gender *"></asp:Label>
                            <asp:DropDownList ID="ddlBirthGender" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthDate" runat="server" Text="Date of Birth *"></asp:Label>
                            <asp:TextBox ID="txtBirthDate" runat="server" placeholder="mm/dd/yyyy"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthTime" runat="server" Text="Time of Birth"></asp:Label>
                            <asp:TextBox ID="txtBirthTime" runat="server" placeholder="hh:mm AM/PM"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthPlace" runat="server" Text="Place of Birth *"></asp:Label>
                            <asp:TextBox ID="txtBirthPlace" runat="server" placeholder="City/District"></asp:TextBox>
                        </div>
                    </div>
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthWeight" runat="server" Text="Birth Weight (kg)"></asp:Label>
                            <asp:TextBox ID="txtBirthWeight" runat="server" placeholder="e.g., 3.2"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthType" runat="server" Text="Type of Birth"></asp:Label>
                                <asp:DropDownList ID="ddlBirthType" runat="server" AppendDataBoundItems="true">
                                    <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthOrder" runat="server" Text="Birth Order"></asp:Label>
                            <asp:TextBox ID="txtBirthOrder" runat="server" placeholder="1st, 2nd, etc."></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Father's Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-male"></i> Father's Information</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthFatherName" runat="server" Text="Father's Full Name *"></asp:Label>
                            <asp:TextBox ID="txtBirthFatherName" runat="server" placeholder="Enter father's full name"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthFatherCNIC" runat="server" Text="Father's CNIC *"></asp:Label>
                            <asp:TextBox ID="txtBirthFatherCNIC" runat="server" placeholder="XXXXX-XXXXXXX-X"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthFatherOccupation" runat="server" Text="Occupation"></asp:Label>
                            <asp:TextBox ID="txtBirthFatherOccupation" runat="server" placeholder="Occupation"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthFatherNationality" runat="server" Text="Nationality"></asp:Label>
                            <asp:DropDownList ID="txtBirthFatherNationality" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Mother's Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-female"></i> Mother's Information</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthMotherName" runat="server" Text="Mother's Full Name *"></asp:Label>
                            <asp:TextBox ID="txtBirthMotherName" runat="server" placeholder="Enter mother's full name"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthMotherCNIC" runat="server" Text="Mother's CNIC *"></asp:Label>
                            <asp:TextBox ID="txtBirthMotherCNIC" runat="server" placeholder="XXXXX-XXXXXXX-X"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthMotherOccupation" runat="server" Text="Occupation"></asp:Label>
                            <asp:TextBox ID="txtBirthMotherOccupation" runat="server" placeholder="Occupation"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthMotherNationality" runat="server" Text="Nationality"></asp:Label>
                            <asp:DropDownList ID="txtBirthMotherNationality" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Registration Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-registered"></i> Registration Information</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthRegNumber" runat="server" Text="Registration Number"></asp:Label>
                            <asp:TextBox ID="txtBirthRegNumber" runat="server" placeholder="Auto-generated" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthRegDate" runat="server" Text="Registration Date"></asp:Label>
                            <asp:TextBox ID="txtBirthRegDate" runat="server" ReadOnly="true"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthRegistrar" runat="server" Text="Registrar Name"></asp:Label>
                            <asp:TextBox ID="txtBirthRegistrar" runat="server" placeholder="Registrar name"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthUnionCouncil" runat="server" Text="Union Council"></asp:Label>
                            <asp:TextBox ID="txtBirthUnionCouncil" runat="server" placeholder="Union Council"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Permanent Address Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-home"></i> Permanent Address</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-4 col-md-4 col-sm-12">
                            <asp:Label ID="lblBirthAddress" runat="server" Text="Address"></asp:Label>
                            <asp:TextBox ID="txtBirthAddress" runat="server" placeholder="House No., Street, Area"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthCity" runat="server" Text="City/District"></asp:Label>
                            <asp:TextBox ID="txtBirthCity" runat="server" placeholder="City/District"></asp:TextBox>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthProvince" runat="server" Text="Province"></asp:Label>
                            <asp:DropDownList ID="ddlBirthProvince" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthPostalCode" runat="server" Text="Postal Code"></asp:Label>
                            <asp:TextBox ID="txtBirthPostalCode" runat="server" placeholder="Postal code"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Additional Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-info-circle"></i> Additional Information</h4>
                </div>
                <div class="card-body">
                    <div class="row compact-row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthReligion" runat="server" Text="Religion"></asp:Label>
                            <asp:DropDownList ID="ddlBirthReligion" runat="server" AppendDataBoundItems="true">
                                <asp:ListItem Text="Select" Value="0"></asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <asp:Label ID="lblBirthAttendant" runat="server" Text="Birth Attendant"></asp:Label>
                            <asp:TextBox ID="txtBirthAttendant" runat="server" placeholder="Doctor/Nurse/Midwife"></asp:TextBox>
                        </div>
                        <div class="col-lg-6 col-md-8 col-sm-12">
                            <asp:Label ID="lblBirthRemarks" runat="server" Text="Remarks"></asp:Label>
                            <asp:TextBox ID="txtBirthRemarks" runat="server" TextMode="MultiLine" Rows="2" placeholder="Any additional remarks"></asp:TextBox>
                        </div>
                    </div>
                </div>
            </div>
        </div>
                        <div class="row">

                            
                                       <div class="col-lg-2 col-md-4 col-sm-6" id="GenrateCertificate">
              <input value="Generate" class="btn-primry" id="genrateCerti" type="button" onclick="GenrateCertificate()"/>
           </div>
                            <div class="col-lg-2 col-md-4 col-sm-6" id="Printbirth">
                                <input value="Print Certificate" class="btn-primry" id="Printbirthcertificate" type="button" onclick="PrintGenrateCertificate()" />
                            </div>
                        </div>
    </div>
</div>--%>


    <div id="Tab-14">
    <div class="row compact-row">

        <!-- Child Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">
                <div class="card-header">
                    <h4><i class="fa fa-child"></i> Child Information</h4>
                    <input type="hidden" id="Birth_Id" />
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthChildName">Child's Full Name *</label>
                            <input type="text" id="txtBirthChildName" placeholder="Enter child's full name" />
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddlBirthGender">Gender *</label>
                            <select id="ddlBirthGender">
                                <option value="0">Select</option>
                            </select>
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txtBirthDate">Date of Birth *</label>
                            <input type="text" id="txtBirthDate" placeholder="mm/dd/yyyy" />
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txtBirthTime">Time of Birth</label>
                            <input type="text" id="txtBirthTime" placeholder="hh:mm AM/PM" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthPlace">Place of Birth *</label>
                            <input type="text" id="txtBirthPlace" placeholder="City/District" />
                        </div>

                    </div>

                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthWeight">Birth Weight (kg)</label>
                            <input type="text" id="txtBirthWeight" placeholder="e.g., 3.2" />
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="ddlBirthType">Type of Birth</label>
                            <select id="ddlBirthType">
                                <option value="0">Select</option>
                            </select>
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txtBirthOrder">Birth Order</label>
                            <input type="text" id="txtBirthOrder" placeholder="1st, 2nd, etc." />
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Father's Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">

                <div class="card-header">
                    <h4><i class="fa fa-male"></i> Father's Information</h4>
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthFatherName">Father's Full Name *</label>
                            <input type="text" id="txtBirthFatherName" placeholder="Enter father's full name" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthFatherCNIC">Father's CNIC *</label>
                            <input type="text" id="txtBirthFatherCNIC" placeholder="XXXXX-XXXXXXX-X" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthFatherOccupation">Occupation</label>
                            <input type="text" id="txtBirthFatherOccupation" placeholder="Occupation" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthFatherNationality">Nationality</label>
                            <select id="txtBirthFatherNationality">
                                <option value="0">Select</option>
                            </select>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Mother's Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">

                <div class="card-header">
                    <h4><i class="fa fa-female"></i> Mother's Information</h4>
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthMotherName">Mother's Full Name *</label>
                            <input type="text" id="txtBirthMotherName" placeholder="Enter mother's full name" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthMotherCNIC">Mother's CNIC *</label>
                            <input type="text" id="txtBirthMotherCNIC" placeholder="XXXXX-XXXXXXX-X" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthMotherOccupation">Occupation</label>
                            <input type="text" id="txtBirthMotherOccupation" placeholder="Occupation" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthMotherNationality">Nationality</label>
                            <select id="txtBirthMotherNationality">
                                <option value="0">Select</option>
                            </select>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Registration Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">

                <div class="card-header">
                    <h4><i class="fa fa-registered"></i> Registration Information</h4>
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthRegNumber">Registration Number</label>
                            <input type="text" id="txtBirthRegNumber" placeholder="Auto-generated" readonly />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthRegDate">Registration Date</label>
                            <input type="text" id="txtBirthRegDate" readonly />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthRegistrar">Registrar Name</label>
                            <input type="text" id="txtBirthRegistrar" placeholder="Registrar name" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthUnionCouncil">Union Council</label>
                            <input type="text" id="txtBirthUnionCouncil" placeholder="Union Council" />
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Permanent Address Card -->
        <div class="col-lg-12">
            <div class="compact-card">

                <div class="card-header">
                    <h4><i class="fa fa-home"></i> Permanent Address</h4>
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-4 col-md-4 col-sm-12">
                            <label for="txtBirthAddress">Address</label>
                            <input type="text" id="txtBirthAddress" placeholder="House No., Street, Area" />
                        </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label for="txtBirthCity">City/District</label>
                            <input type="text" id="txtBirthCity" placeholder="City/District" />
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="ddlBirthProvince">Province</label>
                            <select id="ddlBirthProvince">
                                <option value="0">Select</option>
                            </select>
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthPostalCode">Postal Code</label>
                            <input type="text" id="txtBirthPostalCode" placeholder="Postal code" />
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Additional Information Card -->
        <div class="col-lg-12">
            <div class="compact-card">

                <div class="card-header">
                    <h4><i class="fa fa-info-circle"></i> Additional Information</h4>
                </div>

                <div class="card-body">
                    <div class="row compact-row">

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="ddlBirthReligion">Religion</label>
                            <select id="ddlBirthReligion">
                                <option value="0">Select</option>
                            </select>
                        </div>

                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label for="txtBirthAttendant">Birth Attendant</label>
                            <input type="text" id="txtBirthAttendant" placeholder="Doctor/Nurse/Midwife" />
                        </div>

                        <div class="col-lg-6 col-md-8 col-sm-12">
                            <label for="txtBirthRemarks">Remarks</label>
                            <textarea id="txtBirthRemarks" rows="2" placeholder="Any additional remarks"></textarea>
                        </div>

                    </div>
                </div>
            </div>
        </div>

        <!-- Buttons -->
        <div class="row">

            <div class="col-lg-2 col-md-4 col-sm-6" id="GenrateCertificate">
                <input value="Generate"
                       class="btn-primry"
                       id="genrateCerti"
                       type="button"
                       onclick="GenrateCertificate()" />
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6" id="Printbirth">
                <input value="Print Certificate"
                       class="btn-primry"
                       id="Printbirthcertificate"
                       type="button"
                       onclick="PrintGenrateCertificate()" />
            </div>

        </div>

    </div>
</div>
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
        <input type="button" class="btn-primry" id="btnsave" value="Save" onclick="SaveAllRecords();" />
            </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-yellow" value="New" name="btnName" onclick="NewWindow()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-gray" id="btnBackList" value="View " onclick="BackToList()" />
            </div>

    </div>
</asp:Content>
