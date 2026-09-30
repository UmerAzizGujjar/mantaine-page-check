<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OperationBooking.aspx.cs" Inherits="PMS.OperationBooking" EnableEventValidation="false" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <%-- <script type="../../text/javascript" src="Scripts/upload.js"></script>--%>
    <script src="../../wwwroot/lib/timepicki/timepicki.js"></script>
      <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/timepicki.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/OT.css" rel="stylesheet" />
    <script type="text/javascript">


        $(document).ready(function () {
            $('#lblTotalhr').hide();
            $('#TotalTimehr').hide();
            $('#btnPrintConsent').hide();
            $('#btnPrint').hide();
            $('#btnAddPatient').hide();

            MaskedInput({
                elm: document.getElementById('txt_cnic'),
                format: '_____-_______-_',
                separator: '-'
            });
            MaskedInput({
                elm: document.getElementById('txt_mobile'),
                format: '___________',
                separator: '-'

            });
            $("#txtSearch").keypress(function (event) {
                var SearchString = $('#txtSearch').val();
                if (event.which == 13) {
                    {

                        event.preventDefault();

                        if (SearchString != '') {

                            PageMethods.Search((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilter, OnFail);
                        }
                    }
                    if (SearchString === '') {
                        FillPatientsList();
                    }
                }
            });
            var chk = '<%= Request.QueryString["ID"]%>';

            Combination();


            preparedPatients();


            FillWardBedsRefer();
            FillRoomsRefer();
            FillPharmacyItem();
            FillRoutes();
            FillDosage();
            FillDosageQty();
            FillPanel();

            if (chk != "") {
                $('#lblTotalhr').show();
                $('#TotalTimehr').show();
                LoadMedicationHistory(chk);
                LoadConsentFormImages(chk);
                chkrefer_Of_Select();
                loadReferenceInformation();
                $('#loadingimage').hide();
                $("#ctl00_MainContent_ddlMo_Doctor_Name").val(localStorage.DoctorID);
                $("#ctl00_MainContent_ddlMO_Doctor_Status").val(localStorage.DesignationID);
                $('#btnAddPatient').hide();
              
            }

            $('#btnAddMedicine').on("click", function () {

                $("#btnSaveMedicine").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });

                $("#txtPharmacyItem").val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#ddlDosage_From').val('');


            });

            $('#btnSaveMedicine').on("click", function () {
                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");


                }


                if ($('#txtPharmacyItem').val() == '' || $('#txtPharmacyItem').val() == 'Select Medicine' || $('#txtPharmacyItem').val() == null) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Medicine Name',
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

                if ($('#txtPharmacyItem').val() != '')
                    var pharmacyITem = $('#txtPharmacyItem').find('option:selected').text()


                var Dosage_Qty = $('#ddlDosage_Qty').val();
                if (Dosage_Qty == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Dosage Quantity',
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

                var DosageFrom = $('#ddlDosage_From').val();
                if (DosageFrom == "") {

                    alert("Please Select Complete Dosage");
                    return false;
                }
                var Route = $('#Routes').val();
                if (Route == "0" || Route == "") {
                    alert("Please Select Route ");
                    return false;
                }

                var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
                var datetimeValue = '<%= DateTime.Now%>';


                datetime = moment().format("DD/MM/YYYY h:mm:ss A");


                if ($(this).val() == 'Save') {
                    var medicine = ''
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    if (medicine == '') {
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetime + '">' + datetime + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td> <td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td>' + $('#ddlDosage_Qty').find('option:selected').text() + '</td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a>  |  <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' /> </td></tr>';
                    }
                    else {
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetime + '">' + datetime + ' </td><td> <input type="hidden" name="hdnItemCode" value="' + pharmacyItem + '"> ' + pharmacyITem + '</td> <td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td> ' + $('#ddlDosage_Qty').find('option:selected').text() + '</td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' /> </td> </tr>';
                    }

                    var table = $('#tblMedicinesList tbody');
                    table.append(row);
                }
                else if ($(this).val() == 'Update') {
                    var tid = $('#MedicationModel input[name=uurowid]').val();

                    var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                    $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                    $(row).find('td')[2].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                    $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim();
                    $(row).find('td')[4].innerText = $('#ddlDosage_Qty').find('option:selected').text().trim();

                }


                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $("#txtPharmacyItem").val('').change();
                $('#MedicationModel').modal('hide');

            });

            $('#ddl_ctgry').on('change', function () {
                var $this = $(this).val();
                if ($this == '01') {
                    $('.forPanel').hide();
                    $('#ddl_pnl_cpy').next(".select2-container").hide();
                }
                else if ($this == '0') {
                    $('.forPanel').hide();
                    $('#ddl_pnl_cpy').next(".select2-container").hide();
                }
                else {
                    $('.forPanel').show();
                    $('#ddl_pnl_cpy').next(".select2-container").show().children().find("[role=combobox]").addClass('impo fcux');

                }

            });

            $("#ctl00_MainContent_ddlProcedureNames").on("change", function () {
                var val = $(this).val();

                if (val !== "0") {
                    $("#ctl00_MainContent_txtOTHealth_Complaints").attr("disabled", true);
                }
                else {
                    $("#ctl00_MainContent_txtOTHealth_Complaints").attr("disabled", false);
                }
            });

            $("#ctl00_MainContent_txtOTHealth_Complaints").on("change", function () {
                var text = $(this).val();
                if (text !== "") {
                    $("#ctl00_MainContent_ddlProcedureNames").attr("disabled", true);
                }
                else {

                    $("#ctl00_MainContent_ddlProcedureNames").attr("disabled", false);
                }

            });



        });

        function AddNewPatient() {
            $('#ddl_pnl_cpy').next(".select2-container").hide();
            $('#hdfPatient_ID').val('(New)');
            clearPatient();
            FillGender();
            FillMarital_Status();
            FillPatientType();
            FillBloodGroup();
            FillRhFactor();
            FillDepartment();
            $('.forPanel').hide();
            $('#SavePatient_Data').show();
            $('#ddl_pnl_cpy').next(".select2-container").hide();


            $('#PatientModel').modal({
                backdrop: 'static'
            });
        }

        function clearPatient() {
            $('#txt_name').val("");
            $('#txt_relation').val("");
            $('#txt_mobile').val("");
            $('#txt_dob').val("");
            $('#txt_cnic').val("");
            $('#txt_Address').val('');
            $('#updatePatient_Data').hide();
        }
        function FillGender() {
            var options = '';
            PageMethods.getGender(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Gender').html(options);
            });
            return options;
        }

        function FillMarital_Status() {
            var options = '<option value="0">Select Status</option>';
            PageMethods.GetMarital_Status(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_status').html(options);

            });
            return options;
        }
        var OpCount = 0;
        var ATCount = 0;

        function FillPatientType() {

            var options = '';
            PageMethods.GetPatient_Type(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_ctgry').html(options);

            });
            return options;
        }

        function FillBloodGroup() {
            var options = '<option value="0">Select Blood Group</option>';
            PageMethods.GetBloodgroup(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_bld_grp').html(options);

            });
            return options;

        }

        function FillRhFactor() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.FillRhFactor(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlRhFactor').html(options);

            });
            return options;

        }


        function FillDepartment() {

            var options2 = '';

            var options = '<option value="0" >Select Main Department</option>';

            PageMethods.GetDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Department_ID == 'All_Departments') {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';

                        $('#ddltest_main_dpt').html(options);

                    }

                    else {
                        options2 += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        $('#ddltest_main_dpt').html(options2);
                        $('#ddltest_main_dpt').val(value.DataValue_Name);

                    }



                });

            });

            return options;
        }

        function FillSubDepartment() {
            var options = '<option value="0">Select Sub Department</option>';
            PageMethods.GetSubDepartment(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Sub_Department').html(options);
                $('#ddl_Sub_Department').select2();

            });
            return options;
        }

        function FillPanel() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetPanel(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Panel_ID + '" >' + value.Company_Name + '</option>';
                });
                $('#ddl_pnl_cpy').html(options);
                $('#ddl_pnl_cpy').select2();
                $('#ddl_pnl_cpy').next(".select2-container").hide();

            });
            return options;
        }


        function SearchPop() {

            $('#SearchModel').modal({
                backdrop: 'static'
            });
            FillList();
        }


        function FillList() {
            $('#tblResult tbody').empty();

            var SearchString = '';

            PageMethods.Search(SearchString, OnFilter, OnFail);
        }
       
        function ClearResults() {
            while (tblResult.rows.length > 1) {
                tblResult.deleteRow(1);
            }
        }
      


        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
            }
        }



        function OnFail(exc) {
            alert(exc.get_message());
        }







        function AddResult(Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
            tblLength = tblResult.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Patient_ID + '</span>';
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
            actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;display:flex;justify-content:center;" href="#" onclick=AddDetail(' + Patient_ID + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
            cell.innerHTML = actions;
        }





        function AddDetail(id) {

            toastr.success('Patient Proceed');
            $('#hdfPatient_ID').val(id);
            $('#CloseSearchModels').click();
            $('#CloseSearchModel').click();
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("clear");

            var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + id);

            $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });  //

        }






        function EditPatientDetail(id) {


            $('#CloseSearchModel').click();
            $('#CloseSearchModels').click();
            $("#SavePatient_Data").hide();

            $('#updatePatient_Data').show();
            clearPatient();
            FillGender();
            FillPanel();
            FillBloodGroup();
            FillRhFactor();
            FillMarital_Status();
            FillPatientType();
            FillDocName();

            FillDepartment();

            $("#SavePatient_Data").hide();

            $('#updatePatient_Data').show();
            $('#PatientModel').modal({
                backdrop: 'static'
            });

            var ajaxFn = function () {
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetEditPatientDetails",
                    data: "{'PatientID':" + id + "}",
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


        function OnSuccessEdit(data) {

            if (data.d != '') {
                $("#txt_name").val(data.d.Name);
                $("#ddl_Gender").val(data.d.Gender).change();
                var newValue = data.d.Age.replace('Y', '');

                $("#txt_dob").val(newValue);
                $("#ddl_status").val(data.d.MaritalStatus);
                $("#ddl_ctgry").val(data.d.Patient_Type).change();
                $("#ddl_Doc").val(data.d.DocID).change();
                $('#ddl_pnl_cpy').hide();


                $("#ddltest_main_dpt").val(data.d.department).change();

                $('#ddlRelation').val(data.d.Relation).change();
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
                $('#hdfPatient_ID').val(data.d.PatientID);



            }

        }





        function ObPrint() {
            var Op_Booking = $("#ctl00_MainContent_txtPatient_ID").val();
            if (Op_Booking == "") {
                alert("Please select MR No first");
                return false;
            }
            window.location.href = ("../../ReportViewer.aspx?ReportName=OperationTheater&ReportTitle=Operation Booking&Operation_Booking_ID=" + Op_Booking + "");
        }
        function PrintConsultant() {
            var Patient_ID = $('#hdfPatient_ID').val();
            if (Patient_ID != null || Patient_ID != "null") {
                var url = '../../ReportViewer.aspx?ReportName=consent_slip&ReportTitle=Conset Slip' + '&In_Patient_ID=' + Patient_ID;
                window.open(url, '_blank');
            }
        }
        function SavePatient() {
            $('#SavePatient_Data').attr('disabled', true);
            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();

            var Full_Name = Prefix_PatientName + PatientName;
            var PatientID = $('#hdfPatient_ID').val();
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();
            var panel = $('#ddl_pnl_cpy').val();


            var Mobile = $('#txt_mobile').val();
            var PreFix_DOB = $('#ddl_dob').val();
            var DOB = $('#txt_dob').val();
            var Date_Of_Birth = DOB + PreFix_DOB;
            var CNIC = $('#txt_cnic').val();
            var Mertial_Status = $('#ddl_status').val();

            var Patient_type = $('#ddl_ctgry').val();

            if (Patient_type == "02" && panel == "0") {
                alert("Please select Panel company");
                $('#SavePatient_Data').attr('disabled', false);
                return;
            }

            var BloodGroup = $('#ddl_bld_grp').val();
            var rhFActor = $('#ddlRhFactor').val();
            var Department = $('#ddltest_main_dpt').val();
            var Address = $('#txt_Address').val();
            if ((Patient_type == "01") && (panel == "")) {
                alert("Please Enter compulsory Fields");
                $('#SavePatient_Data').attr('disabled', false);
                return;
            }
            if ((PatientName == "" || Patient_type == "0" || Department == "0" || Mobile == "" || Department == null || Department == 'null')) {

                alert("Please Enter compulsory Fields");
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
                "Mertial_Status": Mertial_Status,
                "Patient_type": Patient_type,
                "BloodGroup": BloodGroup,
                "Department": Department,
                "Address": Address,
                "panel": panel,
                "PatientID": PatientID,
                "rhFActor": rhFActor
            });
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/SavePatientDetail",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var patientID = data.d;
                    toastr.success('Your Record Save and Load Successfully');
                    $('#PatientModel').modal('hide');
                    $('#ClosepatientModel').click();
                    $('#btnAddPatient').prop('disabled', true);
                    $('#btnSearchPatient').prop('disabled', true);
                    var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + patientID);



                    $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });

                    LoadPatientDetails();
                },
                error: function (response) {
                    alert("Error");
                }
            });
        }

        function LoadPatientDetails() {
            var Patient_ID = $('#hdfPatient_ID').val();

            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess1,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function OnSuccess1(data) {
            if (data.d != '') {

                if (data.d.Patient_Discount_Type == null)
                    data.d.Patient_Discount_Type = "";
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();

                if (data.d.AdmissionDate == null) {
                    AdmDate = "New";
                }
                else {
                    var AdmDate = new Date(parseInt(data.d.AdmissionDate.substr(6)));
                    AdmDate = moment(AdmDate).format('DD MMM YYYY');
                }
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                var age = data.d.Age;
                if (age.includes('D')) {
                    $('#lbltextyear').text('Day|')
                }
                else if (age.includes('M')) {
                    $('#lbltextyear').text('Month|');
                }
                else if (age.includes('Y')) {
                    $('#lbltextyear').text('Year|');
                }
                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#txtdoctorname').text(ReplaceNullWith_Space(data.d.DoctorName));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
                $('#lblPatientDiscountType').text(ReplaceNullWith_Space(data.d.Patient_Discount_Type));
                $('#lblMrNo').text(ReplaceNullWith_Space(data.d.Mr_No));
                $('#lblAdmitDate').val(AdmDate);
                PanelID = ReplaceNullWith_Space(data.d.PanelID);
                var lblPatientCategory = $('#lblPatientCategory').text();
                if (lblPatientCategory == "Panel") {
                    $('#PanelCompany').show();
                    $('#lblPanel_Company').text(ReplaceNullWith_Space(data.d.PanelComany));
                }


            }

        }

        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
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

        function LoadConsentFormImages(patientId) {
            var Op_Booking_Id = $("#<%=txtOperation_Booking_ID.ClientID%>").val();

            PageMethods.LoadConsentImages(patientId, Op_Booking_Id, function (res) {
                var container = '';
                container = $('#containerOP');
                if (res == null || res == "[]" || res == "undefined") {
                    $("#errorMsg").show();
                    container.html('');
                }
                else { $("#errorMsg").hide(); }

                var test = JSON.parse(res);

                if ((typeof test.Image_path_OP === "undefined" || test.Image_path_OP === null) && (typeof test.Image_path_AT === "undefined" || test.Image_path_AT === null)) {
                    container.html('');
                    $('#containerAT').html('');
                    return;
                }
                if (typeof test.Image_path_OP !== "undefined" && test.Image_path_OP !== null) {
                    var rows = '';

                    container.innerHTML = "";
                    container.html('');



                    var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)"></a>');
                    img.attr("style", "height:82px;width: 82px");
                    var dd = 'Operation_Booking_Images/' + test.Image_path_OP;

                    img.attr("src", dd);
                    img.attr("data-id", "op");

                    container.append(img);


                    if (typeof test.Image_path_OP_1 !== "undefined" && test.Image_path_OP_1 !== null) {

                        var img1 = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)"></a>');
                        img1.attr("style", "height:82px;width: 82px");
                        var dd1 = 'Operation_Booking_Images/' + test.Image_path_OP_1;

                        img1.attr("src", dd1);
                        img1.attr("data-id", "op");

                        container.append(img1);
                    }
                    if (typeof test.Image_path_OP_2 !== "undefined" && test.Image_path_OP_2 !== null) {

                        var img2 = $('<img onclick="window.open(this.src)" src=""/><a href="#"  style="display:none"onclick="deleteImage(this)"></a>');
                        img2.attr("style", "height:82px;width: 82px");
                        var dd2 = 'Operation_Booking_Images/' + test.Image_path_OP_2;

                        img2.attr("src", dd2);
                        img2.attr("data-id", "op");

                        container.append(img2);
                    }

                    if (typeof test.Image_path_OP_3 !== "undefined" && test.Image_path_OP_3 !== null) {

                        var img3 = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)"></a>');
                        img3.attr("style", "height:82px;width: 82px");
                        var dd3 = 'Operation_Booking_Images/' + test.Image_path_OP_3;

                        img3.attr("src", dd3);
                        img3.attr("data-id", "op");

                        container.append(img3);
                    }


                    if (typeof test.Image_path_OP_4 !== "undefined" && test.Image_path_OP_4 !== null) {

                        var img4 = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)"></a>');
                        img4.attr("style", "height:82px;width: 82px");
                        var dd4 = 'Operation_Booking_Images/' + test.Image_path_OP_4;

                        img4.attr("src", dd4);
                        img4.attr("data-id", "op");

                        container.append(img4);

                    }

                }


                if (typeof test.Image_path_AT !== "undefined" && test.Image_path_AT !== null) {

                    container = $('#containerAT');

                    container.innerHTML = "";
                    container.html('');



                    var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)"></a>');
                    img.attr("style", "height:82px;width: 82px");
                    var dd = 'Operation_Booking_Images/' + test.Image_path_AT;

                    img.attr("src", dd);
                    img.attr("data-id", "at");

                    container.append(img);




                    if (typeof test.Image_path_AT_1 !== "undefined" && test.Image_path_AT_1 !== null) {

                        var img1 = $('<img onclick="window.open(this.src)" src=""/><a href="#"  onclick="deleteImage(this)"></a>');
                        img1.attr("style", "height:82px;width: 82px");
                        var dd1 = 'Operation_Booking_Images/' + test.Image_path_AT_1;

                        img1.attr("src", dd1);
                        img1.attr("data-id", "at");

                        container.append(img1);
                    }
                    if (typeof test.Image_path_AT_2 !== "undefined" && test.Image_path_AT_2 !== null) {

                        var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)">Delete</a>');
                        var img2 = $('<img onclick="window.open(this.src)" src=""/><a href="#"  onclick="deleteImage(this)"></a>');
                        img2.attr("style", "height:82px;width: 82px");
                        var dd2 = 'Operation_Booking_Images/' + test.Image_path_AT_2;

                        img2.attr("src", dd2);
                        img2.attr("data-id", "at");

                        container.append(img2);
                    }

                    if (typeof test.Image_path_AT_3 !== "undefined" && test.Image_path_AT_3 !== null) {

                        var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)">Delete</a>');
                        var img3 = $('<img onclick="window.open(this.src)" src=""/><a href="#"  onclick="deleteImage(this)"></a>');
                        img3.attr("style", "height:82px;width: 82px");
                        var dd3 = 'Operation_Booking_Images/' + test.Image_path_AT_3;

                        img3.attr("src", dd3);
                        img3.attr("data-id", "at");

                        container.append(img3);
                    }


                    if (typeof test.Image_path_AT_4 !== "undefined" && test.Image_path_AT_4 !== null) {

                        var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" style="display:none" onclick="deleteImage(this)">Delete</a>');
                        var img4 = $('<img onclick="window.open(this.src)" src=""/><a href="#"  onclick="deleteImage(this)"></a>');
                        img4.attr("style", "height:82px;width: 82px");
                        var dd4 = 'Operation_Booking_Images/' + test.Image_path_AT_4;

                        img4.attr("src", dd4);
                        img4.attr("data-id", "at");

                        container.append(img4);

                    }

                }



            });

        }

        function deleteImage(imageURL) {
            var imageSRC = $($(imageURL)[0]).attr('src');
            var CF_Type = $($(imageURL)[0]).attr('data-id');
            var Op_Booking_Id = $("#<%=txtOperation_Booking_ID.ClientID%>").val();
            var patientId = $("#<%=hdfPatient_ID.ClientID%>").val();
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/DeleteImage",
                data: JSON.stringify({ "imagSrc": imageSRC, "Op_Booking_Id": Op_Booking_Id, "patientId": patientId, "CF_Type": CF_Type }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d == "Success_op") {

                        $("#containerOP").html('');
                        return;
                    }
                    if (data.d == "Success_at") {
                        $("#containerAT").html('');
                        return;
                    }
                }
                , error: function () {

                }


            });
        }

        function Save() {
            PageMethods.Save(JSON.stringify(OpCount), JSON.stringify(ATCount), function (res) {
            });
        }

        function SaveMedicines() {
            var table = $('#tblMedicinesList');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(),
                    'Medicine_Name': $($(value).find('td')[1]).text().trim(),
                    'Oral': $($(value).find('td')[2]).text().trim(),
                    'Dosage_From': $($(value).find('td')[3]).text().trim(),
                    'Dosage_Qty': $($(value).find('td')[4]).text().trim(),
                    'Doctor_Id': $('#ctl00_MainContent_ddlSurgeon_Name').val()
                });

            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();



            var MedicineDetails = { PatientID: PatID, MedicineList: MedicinesList };
            Save();
            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) {


            });
        }

        function LoadMedicationHistory(PatientID) {
            $('#dvHistoryMedication').hide();
            if (PatientID != '(New)') {
                $('#HeaderHistoryMedication').html('<h2>Loading Previous History Please Wait....</h2>')
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr><td> <input type="hidden" name="testDate" value="' + newdate + '"> ' + newdate + ' </td><td>' + value.Medicine_Name + '</td><td> ' + value.Oral + ' </td><td> ' + value.Dosage_From + ' </td> <td> ' + value.Dosage_Qty + ' </td><td disabled="disabled"></td></tr>';

                        if (value.Medicine_Name.length > 0)
                            $('#dvHistoryMedication').show();
                        else
                            $('#dvHistoryMedication').hide();
                    });
                    $('#tblMedicinesList tbody tr').remove();
                    $('#tblMedicinesList tbody').html(rows);
                    $('#HeaderHistoryMedication').html('<h2>Previous History</h2>');

                });

            }
        }

        function FillPharmacyItem() {
            PageMethods.FillPharmacyItemDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.Item_Code + '"> ' + value.Description + ' </option>';
                });

                $('#txtPharmacyItem').html(options);
                $('#txtPharmacyItem').select2();


            });
        }

        function Cleardrpdwn() {
            FillMedicine();
        }

        function editMedicine(AnchorTag) {
            $('#MedicationModel').modal({
                backdrop: 'static'
            });


            $('#txtDosage').val('');


            $('#btnSaveMedicine').val('Update');
            var row = $(AnchorTag).parents('tr')[0];


            var dosage_qty = $($(row).find('td')[4]).text().trim();
            var dosage_form = $($(row).find('td')[3]).text().trim();

            var routes = $($(row).find('td')[2]).text().trim();


            $("#txtPharmacyItem").find('option:contains(' + $(row).find('td')[1].innerText + ')')[0].selected = true;

            $("#ddlDosage_Qty").find('option:contains(' + dosage_qty + ')')[0].selected = true;
            $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;


            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());



            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
        }

        function deleteMedicine(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
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

        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value="0"> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Routes').html(options);

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

        function FillDosage() {
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_From').html(options);
            });
        }


        function readIMGsingle(input) {

            var container = ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_OP") ? "#containerOP" : "#containerAT";
            var CF_Type = ($(input)[0].id == "ctl00_MainContent_fileUpload_CF_OP") ? "op" : "at";
            $(container).html('');


            var countFiles = $(input)[0].files.length;

            if (CF_Type == "op") {
                OpCount = countFiles;
            }

            if (CF_Type == "at") {
                ATCount = countFiles;
            }

            var imgPath = $(input)[0].value;
            var extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
            if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {
                if (typeof (FileReader) != "undefined") {

                    for (var i = 0; i < countFiles; i++) {

                        var reader = new FileReader();
                        reader.onload = function (e) {

                            var img = $('<img />').attr({
                                'id': 'myImage' + i + "_" + CF_Type,
                                'src': e.target.result,
                                'alt': 'JSFiddle logo',
                                'title': 'JSFiddle logo',
                                'width': 40,
                                'onclick': 'viewLargeImage(this.id)'
                            }).appendTo(container);


                        }

                        reader.readAsDataURL($(input)[0].files[i]);

                    }
                } else {
                    alert("This browser does not support FileReader.");
                }
            } else {
                alert("Please select only images !");
            }
        }

        function viewLargeImage(id) {
            var newTab = window.open();
            var path = $("#" + id + "").attr("src");
            newTab.document.body.innerHTML = '<img src="' + path + '" width="1101px" height="881px">';
        }

        function triggerFileUpload() {
            document.getElementById("<%=fileUpload_CF_OP.ClientID%>").click();
        }

        function triggerATFileUpload() {

            document.getElementById("<%=fileUpload_CF_AT.ClientID%>").click();
        }

        function SaveTransferDetails() {
            var referTo = $("#ctl00_MainContent_ddlReferTo").val();
            if (referTo == "0") {
                alert("Please select Ward or Room !");
                return;
            }

            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            var PreviousDepartment = $("#txtdprevDepart").val();
            var PreviousWard_Bed = $("#txtWardBed").val();
            var PreviousRoom_Bed = $("#txtRoomBed").val();

            var Ward_No = "";
            var Ward_BedNo = "";
            var Room_No = "";
            var Room_Type = "";

            if (referTo == "001") {
                Ward_No = $("#ctl00_MainContent_ddlwards").val();
                Ward_BedNo = $("#ctl00_MainContent_txtBedno").val();
            }
            else {
                Room_No = $("#ctl00_MainContent_ddlroom").val();
                Room_Type = $("#ctl00_MainContent_ddlRoomType").val();
            }

            var data = JSON.stringify({
                "PatientID": Patient_ID,
                "PreviousDepartment": PreviousDepartment,
                "PreviousWard_Bed": PreviousWard_Bed,
                "PreviousRoom_Bed": PreviousRoom_Bed,
                "referTo": referTo,
                "Ward_No": Ward_No,
                "Ward_BedNo": Ward_BedNo,
                "Room_No": Room_No,
                "Room_Type": Room_Type
            });

            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/SaveTransferDetails",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    alert(data.d);

                },
                error: function (response) {
                    alert("Error !");
                    console.log(response.responseJSON.Message);
                }
            });

        }

        function OT() {
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/OT",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    var optionsList = "<option value=0>Please Select</option>";
                    $(result).each(function (key, index) {
                        optionsList += '<option value=' + result[key].ValueSet_ID + '>' + result[key].ValueSet_Name + ' </option>';
                    })

                    $('#ctl00_MainContent_ddlOperationTherter option').remove()
                    $('#ctl00_MainContent_ddlOperationTherter').html(optionsList);
                }, error: function () {


                }

            });
        }
        function Department() {
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/Department",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    var optionsList = "<option value=0>Please Select</option>";
                    $(result).each(function (key, index) {

                    })
                    $(result).each(function (key, index) {
                        optionsList += '<option value=' + result[key].DataValue_Name + '>' + result[key].DataValue_Description + ' </option>';
                    })
                    $('#ctl00_MainContent_ddlDepartment option').remove()
                    $('#ctl00_MainContent_ddlDepartment').html(optionsList);
                }, error: function () {


                }

            });
        }
        function Surgeon() {
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/Surgeon",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    var optionsList = "<option value=0>Please Select</option>";
                    $(result).each(function (key, index) {
                        optionsList += '<option value=' + result[key].Emp_ID + '>' + result[key].Emp_Name + ' </option>';
                    })

                    $('#ctl00_MainContent_ddlSurgeon_Name option').remove()
                    $('#ctl00_MainContent_ddlSurgeon_Name').html(optionsList);
                }, error: function () {


                }

            });
        }

        function preparedPatients() {
            $.ajax
                ({
                    type: "POST",
                    url: "OperationBooking.aspx/preparedPatients",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        var parsed_data = JSON.parse(data.d);
                        var row = '';
                        var rowColor = "red";
                        var InPatientNo = "";
                        var File_No = "";

                        $.each(parsed_data, function (key, index) {

                            rowColor = parsed_data[key].OperationStatus == "pending" ? "#ef4343" : "#5bca2dfa";
                            InPatientNo = parsed_data[key].In_Patient_ID == "There is no row at position 0." ? 0 : parsed_data[key].In_Patient_ID;
                            File_No = parsed_data[key].File_No == "There is no row at position 0." ? 0 : parsed_data[key].File_No;

                            row += '<tr style="background-color:' + rowColor + '"><td style="display:none;">' + parsed_data[key].pat_id + '</td><td>' + parsed_data[key].Patient_No + '</td><td>' + parsed_data[key].Full_Name + '</td><td>' + parsed_data[key].PatientType + '</td><td>' + parsed_data[key].DoctorName + '</td><td style="width: 25%; text-align: center;">' + parsed_data[key].ProcedureName + '</td><td>' + File_No + '</td><td>' + InPatientNo + '</td><td>' + parsed_data[key].Age_years + '</td><td>' + parsed_data[key].Gender + '</td><td>' + parsed_data[key].OperationStatus + '</td><td><a href="#" onclick="Select(this)">Select</a></td></tr>';

                        });
                        $('#patientOT tr:gt(0)').remove();
                        $('#patientOT tbody').append(row);
                    }, error: function () {


                    }
                });
        }

        function Select(row) {
            $(row).click(event.preventDefault);
            var patient_id = $($(row).closest('tr')[0]).find('td:eq(0)').text();
            window.location.href = "OperationBooking.aspx?ID=" + patient_id;

        }



        function Combination() {
            TabFunction();
            bindControls();
            bindDate();

        }
        var Total_OT_Time;
        function bindDate() {
            $("#ctl00_MainContent_txtDate_Operation").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtDate_Of_Approval").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#ctl00_MainContent_txtOperationDate").datepicker({ dateFormat: 'mm/dd/yy' });

            $('#<%=txtTimeOfFinishOperation.ClientID%>').timepicki({
                show_meridian: false,
                min_hour_value: 0,
                max_hour_value: 23,
                overflow_minutes: true,
                increase_direction: 'up',
                disable_keyboard_mobile: true
            });

            $('#<%= txtTimeOfStartOperation.ClientID%>').timepicki({
                show_meridian: false,
                min_hour_value: 0,
                max_hour_value: 23,
                overflow_minutes: true,
                increase_direction: 'up',
                disable_keyboard_mobile: true
            });

            $("#<%= txtOperationTime.ClientID%>").timepicki({
                show_meridian: false,
                min_hour_value: 0,
                max_hour_value: 23,
                overflow_minutes: true,
                increase_direction: 'up',
                disable_keyboard_mobile: true
            });


            var start = $('#ctl00_MainContent_txtTimeOfStartOperation').val();
            var end = $('#ctl00_MainContent_txtTimeOfFinishOperation').val();

            s = start.split(':');
            e = end.split(':');

            min = e[1] - s[1];
            hour_carry = 0;
            if (min < 0) {
                min += 60;
                hour_carry += 1;
            }
            hour = e[0] - s[0] - hour_carry;
            Total_OT_Time = diff = hour + ":" + min;

            $('#TotalTimehr').text(Total_OT_Time);

        }





        function TabFunction() {
            $("#tabs").tabs();
        };

        function bindControls() {

            var Op_Booking = $("#<%=txtOperation_Booking_ID.ClientID%>").val();

            if (Op_Booking != "(New)") {



                var Patient_ID = $("#hdfPatient_ID").val();
                var Patient_no = $("#hdfPatoentNo").val();
                var Full_name = $("#hdnFullName").val();

                var tokendata = [{ "id": Patient_ID, "name": Patient_no + '-' + Full_name }];



                loadtokenInputs(tokendata);

            }
            else {
                loadtokenInputsDefault();
            }
        };

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function loadtokenInputsDefault() {

            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Patients",
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
        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/GetDetail",
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
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatient_Name.ClientID %>').text(data.d.Name);
                $('#<%= vlblAge_Year.ClientID %>').text(data.d.Age);
                $('#<%= vlblGender.ClientID %>').text(data.d.Gender);
                $('#<%= vlblEntry_Date.ClientID %>').text(dateR);
                $('#<%= vlblAdress.ClientID %>').text(data.d.Address);
                $('#<%= vlblContact.ClientID %>').text(data.d.Mobile);

            }
        }

        function loadReferenceInformation() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "OperationBooking.aspx/loadReferenceInformation",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccessReference,
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function OnSuccessReference(response) {
            if (onsuccessreference != null) {

                var onsuccessreference = JSON.parse(response.d);

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

        function SelectBed(WardID, BedNo) {
            $('#ctl00_MainContent_txtBed_No').val("");
            $('#ctl00_MainContent_txtBed_No').val(BedNo);
        }

        function SelectBedRefer(WardID, BedNo) {
            $('#ctl00_MainContent_txtBedno').val("");
            $('#ctl00_MainContent_txtBedno').val(BedNo);
        }

        function loadtokenInputs(data) {

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

        function FillWardBedsRefer() {
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

        function PrintVoucher() {

            var Op_Booking = $("#<%=txtOperation_Booking_ID.ClientID%>").val();
            window.open('ReportViewer.aspx ? ReportName = OperationBooking & ReportTitle=Operation Booking Print&Booking_ID=' + Op_Booking);
        }



        function Print() {

            var Op_Booking = $("#<%=txtOperation_Booking_ID.ClientID%>").val();
            window.open('ReportViewer.aspx?ReportName=PrintConsent&ReportTitle=Operation Booking Print Consent&Booking_ID=' + Op_Booking);
        }
      
        function chkrefer_Of_Select() {
            $('#tblBed tbody tr').remove();
            $('#tblRoom tbody tr').remove();

            var Issuance_Of = document.getElementById('<%= ddlReferTo.ClientID%>').value;
            if (Issuance_Of == 0) {
                document.getElementById('<%= ddlroom.ClientID%>').value = 0;
                document.getElementById('<%= ddlRoomType.ClientID%>').value = 0;
                document.getElementById('<%= ddlwards.ClientID%>').value = 0;
             

                document.getElementById('<%= ddlroom.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomType.ClientID%>').disabled = true;
                document.getElementById('<%= ddlwards.ClientID%>').disabled = true;
               

                document.getElementById('<%= ddlroom.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlwards.ClientID%>').className = "dropdownBackgroud";


            }
            else if (Issuance_Of == '001') {

                document.getElementById('<%= ddlroom.ClientID%>').value = 0;
                document.getElementById('<%= ddlRoomType.ClientID%>').value = 0;
                document.getElementById('<%= ddlwards.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroom.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomType.ClientID%>').disabled = true;

                document.getElementById('<%= ddlroom.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlwards.ClientID%>').className = "dropdownBackgroudWhite";
            }
            else {

                document.getElementById('<%= ddlwards.ClientID%>').value = 0;
                document.getElementById('<%= ddlwards.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomType.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroom.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroom.ClientID%>').className = "dropdownBackgroudWhite";
                document.getElementById('<%= ddlwards.ClientID%>').className = "dropdownBackgroud";
            }
        }

    </script>

    
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


     <div id="SearchModel" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px;height:505px;">
                <div class="row">
                    <div class="col-lg-3 col-md-4 col-sm-6" style="padding-top: 20px;margin-left:1%">
                        <label>Search Your Patients: </label>
                        <input type="text" id="txtSearch" style="margin-left: 2px;" autocomplete="off" />
                    </div>
                </div>
                <div style="overflow: scroll; height: auto;">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                        <thead id="ihead">
                            <tr>
                                <th style="display: none;">Patient ID</th>
                                <th>MR No</th>
                                <th>Patient Name</th>
                                <th>Father Name</th>
                                <th>CNIC</th>
                                <th>Contact No</th>
                                <th>Action</th>
                                </tr>
                                </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>
                </div>


                <div class="modal-footer">
                    <input type="button" class="col-lg-2 col-md-4 col-sm-6 btn btn-primry"  id="CloseSearchModels" name="saveENT" value="Close" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
    <div >
            <div class="row flex">
    <!-- Left Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                        <div class="image-container">
                            <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/ot.jpg" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-7 col-sm-6">
                        <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" style="display:none;"></asp:TextBox>

                        <div class="row mb-3">
                    <div class="col-lg-4 formrgn">
                       <asp:Label ID="lblPatien_ID" runat="server" Text="MR No : * "></asp:Label>
                    </div>
                    <div class="col-lg-8">
                    <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                    <asp:HiddenField ID="hdfPatient_ID" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfPatoentNo" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdnFullName" runat="server" ClientIDMode="Static" />
                          <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ErrorMessage="Enter Patient ID" Text="*" ControlToValidate="txtPatient_ID" ForeColor="Red"></asp:RequiredFieldValidator>
                    </div>
                </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                 <asp:Label ID="LblGender" runat="server" Text="Gender : "></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                       <asp:Label ID="vlblGender" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="LblAge_Years" runat="server" Text="Age (Yrs.) : "></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                 <asp:Label ID="vlblAge_Year" runat="server" ReadOnly="True"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                 <asp:Label ID="LblEntry_Date" runat="server" Text="Entry Date : "></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                    <asp:Label ID="vlblEntry_Date" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="Label10" runat="server" Text="Category:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="lblPatient_Category" CssClass="md" runat="server"></asp:Label>
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
                <div class="row mb-3 mtt">
                            <div class="col-lg-8 col-md-5 col-sm-6">
                                  <input type="button" value="Add New Patient" id="btnAddPatient" name="btnAddPatient" onclick="AddNewPatient();" style="border-radius: 28em; width: 205px !important; height: 45px; font-size: 18px; left: 20px; top: -1px;" />
                               
                            </div>
                            <div class="col-lg-4 col-md-7 col-sm-6 top">
                                <input type="button" class="btn-primry" value="Search" id="btnSearchPatient" onclick="SearchPop()" />
                            </div>
                        </div>

                <div class="row mb-3">
                    <div class="col-lg-4 formrgn">
                           <asp:Label ID="LblPatient_Name" runat="server" Text="Patient Name : "></asp:Label>
                    </div>
                    <div class="col-lg-8">
                            <asp:Label ID="vlblPatient_Name" runat="server"></asp:Label>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-4 formrgn">
                   <asp:Label ID="LblContact" runat="server" Text="Contact No : "></asp:Label>
                    </div>
                    <div class="col-lg-8 detail">
                       <asp:Label ID="vlblContact" runat="server"></asp:Label>
                    </div>
             
            </div>  
                <div class="row mb-3">
                    <div class="col-lg-4 formrgn">
                      <asp:Label ID="LblAddress" runat="server" Text="Address : "></asp:Label>
                    </div>
                    <div class="col-lg-8 detail">
                      <asp:Label ID="vlblAdress" runat="server"></asp:Label>
                    </div>
             
            </div>
            </div>
        </div>
    </div>
          <div class="col-lg-2 col-md-2 col-sm-2 cnter">
               <label id="lblTotalhr">Operation Time :</label>
        <label id="TotalTimehr"></label>
          </div>

</div>
    </div>
  

    <div>
        <div id="tabs">

            <ul>
                <li><a href="#Tab-12">Patients</a></li>
                <li><a href="#Tab-4">Prepared Patients</a></li>
                <li><a href="#Tab-2">Relative Approval</a></li>
                <li><a href="#Tab-1">Operation Details</a></li>
                <li><a href="#Tab-9">Post Of Orders</a> </li>
                <li><a href="#Tab-10">Recovery</a></li>
                <li><a href="#Tab-11">Transfer</a></li>
              
            </ul>


            <div id="Tab-12">
                <div id="Patients" style="width: 90%;">
                    <div class="row">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                            <h2>Patient Details :</h2>
                        </div>
                    </div>
                  
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblOperationDate" runat="server" Text="Operation Date"></asp:Label>
                            <asp:TextBox ID="txtOperationDate" runat="server"></asp:TextBox>
                    </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblOperationTime" runat="server" Text="Operation Time"></asp:Label>
                            <asp:TextBox runat="server" ID="txtOperationTime"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblProcedureName" runat="server" Text="Procedure Name"></asp:Label>
                            <asp:DropDownList ID="ddlProcedureNames" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblDoctorName" Text="Doctor Name" runat="server"></asp:Label>
                            <asp:DropDownList ID="ddlDoctors" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="LblHealth_Complaints" runat="server" Text="Procedure"></asp:Label>
                            <asp:TextBox ID="txtOTHealth_Complaints" Style="width:100%;height:40%" TabIndex="3" runat="server" TextMode="MultiLine"></asp:TextBox>
                        </div>
                     </div>
                 </div>
            </div>


            <div id="Tab-2">
                <div id="RelativeApproval" style="width: 95%">
                    <div class="row">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                            <h2>Relative Approval : </h2>
                        </div>
                    </div>
                    
                    <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="lblRelative_Approval" runat="server" Text="Relative Approval"></asp:Label>
                        <asp:DropDownList ID="ddlRelative_Approval" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                    </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblDate_Of_Approval" runat="server" Text="Approval Date"></asp:Label>
                            <asp:TextBox ID="txtDate_Of_Approval" runat="server"></asp:TextBox>
                         </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="lblRelation_With_Patient" runat="server" Text="Relation to Patient"></asp:Label>
                            <asp:TextBox ID="txtRelation_With_Patient" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label></label>
                            <input id="Button2" class="btn btn-primry" type="button" onclick="triggerFileUpload()" value="Upload Consent Operation" title="Upload Image File Only for Operation" />
                            <asp:FileUpload ID="fileUpload_CF_OP" Style="visibility: hidden;" onchange="readIMGsingle(this)" runat="server" multiple="multiple" AllowMultiple="true" />
                            <div id="containerOP"></div>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label></label>
                            <input id="Button1" type="button"  class="btn btn-primry" onclick="triggerATFileUpload()" value="Upload Consent Anesthesia" title="Upload Image File Only for Anesthesia"  />
                            <asp:FileUpload ID="fileUpload_CF_AT" Style="visibility: hidden;" onchange="readIMGsingle(this)" runat="server" multiple="multiple" AllowMultiple="true" />
                            <div id="containerAT"></div>
                        </div> 
                         <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button"  class="btn btn-primry" id="btnPrints" onclick="PrintConsultant()" value="Consent Print" />
                           </div>
                        </div>



                    <table style="width: 100%">                                             
                        <tr>                         
                            <td style="width: 135px"></td>
                            <td>
                                <input type="button"  style="width: 165px; padding-left: 6px;" value="Print Consent Form OP" title="Print Consent Form Operation" id="btnPrintConsent" onclick="Print()" />
                            </td>
                            <td>
                                <input type="button" style="width: 163px; margin-left: 11px; padding-left: 6px;" value="Print Consent Form AT" title="Print Consent Form Anesthesia" id="btnPrint" onclick="PrintVoucher()" />
                            </td>
                            <td style="padding-top: 25px;">                               
                            </td>                          
                        </tr>
                    </table>
                </div>
            </div>


            <div id="Tab-1">
                <div id="OperationDetails" style="width: 100%">
                    <table id="tbl">
                       <tr>                        
                            <td style="width: 135px"></td>
                            <td class="mg"></td>
                            <td style="width: 203px"></td>
                            <td></td>
                        </tr>

                        <tr style="display: none;">
                            <td>
                                <asp:Label ID="Label3" runat="server" Text="Operation Bk ID"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtOperation_Booking_ID" runat="server" ReadOnly="True"></asp:TextBox>
                            </td>
                            <td style="width: 135px"></td>
                            <td class="mg"></td>
                            <td style="width: 203px"></td>
                            <td></td>
                        </tr>
                    </table>


                    <table  id="tbl">
                        <tr>
                            <td>
                                <h2>Operation Details : </h2>
                            </td>
                        </tr>
                        <tr>
                           
                            <td>
                                <asp:Label ID="Label2" runat="server" Text="Operation / Procedure Name" ToolTip="Operation Name / Procedure Name"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtProcedure" runat="server"></asp:TextBox>
                            </td>
                            <td style="width: 135px"></td>
                            <td class="mg">
                                <asp:Label ID="lblDate_Operation" runat="server" Text="Operation Date"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtDate_Operation" runat="server"></asp:TextBox>
                            </td>

                            <td></td>
                        </tr>
                        <tr>
                            
                            <td class="mg">
                                <asp:Label ID="Label4" runat="server" Text="Time Of Start Operation"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtTimeOfStartOperation" runat="server"></asp:TextBox>
                            </td>

                            <td></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblOperation_Theater_No" runat="server" Text="Operation Theater *"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:DropDownList ID="ddlOperationTherter" runat="server" AppendDataBoundItems="true" OnSelectedIndexChanged="ddlOperationTherter_SelectedIndexChanged"></asp:DropDownList>
                            </td>
                            <td style="width: 135px">
                                <asp:RequiredFieldValidator ID="rfvOperation_Theater" runat="server" ErrorMessage="Enter Operation Theater" Text="*" ControlToValidate="ddlOperationTherter" ForeColor="Red"></asp:RequiredFieldValidator>
                            </td>
                            <td class="mg">
                                <asp:Label ID="Label5" runat="server" Text="Time Of Finish Operation"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtTimeOfFinishOperation" runat="server"></asp:TextBox>
                            </td>
                            <td></td>
                        </tr>

                        <tr runat="server" id="trOperationTheaterRoomNo" visible="false">
                            <td>
                                <asp:Label ID="Label7" runat="server" Text="Oprtn Thtr Rm No *"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:DropDownList ID="ddlOperationTheaterRoomNo" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                            </td>
                            <td style="width: 135px">
                               
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="Label1" runat="server" Text="Department"></asp:Label>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlDepartment" AppendDataBoundItems="true" runat="server"></asp:DropDownList>
                            </td>
                            <td style="width: 135px"></td>
                            <td class="mg">
                                <asp:Label ID="lblAnesthetist" runat="server" Text="Anesthetist"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtAnesthetist" runat="server"></asp:TextBox>
                            </td>

                            <td></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblSurgeon_Name" runat="server" Text="Surgeon Name *"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:DropDownList ID="ddlSurgeon_Name" runat="server" AppendDataBoundItems="false"></asp:DropDownList>
                            </td>
                            <td style="width: 135px">
                                <asp:RequiredFieldValidator ID="rfvSurgeon_Name" SetFocusOnError="true" runat="server" InitialValue="0" ErrorMessage="Enter Surgeon Name" Text="*" ControlToValidate="ddlSurgeon_Name" ForeColor="Red"></asp:RequiredFieldValidator>
                            </td>

                            <td class="mg">
                                <asp:Label ID="lblAssistantAnesthetist" runat="server" Text="Assistant Anesthetist"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtAssistantAnesthetist" runat="server"></asp:TextBox>
                            </td>

                            <td></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblAssistant_Surgeon" runat="server" Text="First Assistant"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtAssistant_Surgeon" runat="server"></asp:TextBox>
                            </td>
                            <td style="width: 135px"></td>
                            <td class="mg">
                                <asp:Label ID="lblScrubNurse" runat="server" Text="Scrub Nurse"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtStaffNurse" runat="server"></asp:TextBox>
                            </td>
                            <td></td>
                        </tr>
                        <tr>
                           
                            <td>
                                <asp:Label ID="Label6" runat="server" Text="Second Assistant"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtSecondAssistant" runat="server"></asp:TextBox>
                            </td>
                            <td></td>
                            <td class="mg">
                                <asp:Label ID="lbltxtJuniorAssistantStaff" runat="server" Text="Junior Assistant Staff"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:TextBox ID="txtJuniorAssistantStaff" runat="server"></asp:TextBox>
                            </td>
                            <td></td>
                        </tr>
                    </table>
                </div>
            </div>



            <div id="Tab-3" style="display: none;">
                <div id="OperatedBy" style="width: 90%">
                    <table style="padding: 20px">
                        <tr>
                            <td colspan="6">
                                <h2>Operated By : </h2>
                            </td>
                        </tr>

                    </table>
                </div>
            </div>

            <div id="Tab-4">
                <div id="divOT" style="width: 100%">
                    <table id="patientOT" class="table">
                        <tr>
                            <th style="display: none;">Patient ID</th>
                            <th>Mr No</th>
                            <th style="text-align: center; width: 11%">Patient Name</th>
                            <th style="width: 9%;">Patient Type</th>
                            <th style="width: 12%;">Consultant Doctor</th>
                            <th style="text-align: center;">Operation Procedure Name</th>
                            <th style="width: 7%;">File No #</th>
                            <th style="width: 10%;">In Patient No</th>
                            <th>Age</th>
                            <th>Gender</th>
                            <th>Operation Status</th>
                            <th>Actions</th>
                        </tr>
                    </table>
                </div>
            </div>

            <div id="Tab-5">
                <div id="OperativeProcedure" style="width: 90%">
                </div>
            </div>

            <div id="Tab-6">
                <div id="RePostOperativeNotesmark" style="width: 90%">
                </div>
            </div>

           

            <div id="Tab-9">
                <div id="PostOfOrders" style="width: 90%">                 
                    <div class="container">
                        <div class="row">
                            <h2>Post Of Order Details : </h2>
                        </div>
                        <div class="row">
                            <div class="col-md-2">
                                <label>Findings:</label>
                            </div>
                            <div class="col-md-10">
                               
                                <asp:TextBox ID="txtFindings" runat="server" Columns="10" Rows="5" Style="width: 60%;" TextMode="MultiLine"></asp:TextBox>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-2">
                                <label>Procedure:</label>
                            </div>
                            <div class="col-md-10">
                                <asp:TextBox ID="txtProcedure_PO" runat="server" Columns="10" Rows="5" Style="width: 60%;" TextMode="MultiLine"></asp:TextBox>
                            </div>
                        </div>

                        <div class="row ddl_row" style="margin-top: 25px;">
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label>Drain</label>
                                <asp:DropDownList ID="ddlDrain" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvDrain" SetFocusOnError="true" runat="server" InitialValue="0" ErrorMessage="Select Drain Name" Text="*" ControlToValidate="ddlDrain" ForeColor="Red"></asp:RequiredFieldValidator>
                            </div>

                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label>Suture Used</label>
                                <asp:DropDownList ID="ddlSutureUsed" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvSutureUsed" SetFocusOnError="true" runat="server" InitialValue="0" ErrorMessage="Select Suture Name" Text="*" ControlToValidate="ddlSutureUsed" ForeColor="Red"></asp:RequiredFieldValidator>
                            </div>
                           
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label>Implant</label>
                                <asp:DropDownList ID="ddlImplant" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvddlImplant" SetFocusOnError="true" runat="server" InitialValue="0" ErrorMessage="Select Implant Name" Text="*" ControlToValidate="ddlImplant" ForeColor="Red"></asp:RequiredFieldValidator>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label>Condition</label>
                                <asp:DropDownList ID="ddlPO_Condition" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvddlPO_Condition" SetFocusOnError="true" runat="server" InitialValue="0" ErrorMessage="Select PO Condition Name" Text="*" ControlToValidate="ddlPO_Condition" ForeColor="Red"></asp:RequiredFieldValidator>
                            </div>
                        </div>

                        <div class="row oders-row" style="margin-top: 25px;">
                            <h4>Post-op Orders:</h4>
                            <div class="col-md-1">
                                <label>NPO</label>
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6" style="display:inline-flex">
                                <label for="ctl00_MainContent_rdbNpo_Yes" title="Yes">Yes</label>
                                <input id="rdbNpo_Yes" runat="server" type="radio" name="NPO" value="True" />
                                <label for="ctl00_MainContent_rdbNpo_No" title="No">No</label>
                                <input id="rdbNpo_No" runat="server" type="radio" name="NPO" value="False" />
                            </div>
                        </div>

                        <table >
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <input type="button" value="Add Medicine" class="btn btn-primry" id="btnAddMedicine" />
                                </div>
                            </div>
                            <tr>
                                <td>
                                    
                                    <div style="height: 280px;">
                                        <table class="table table-bordered table-responsive" id="tblMedicinesList">
                                            <thead>
                                                <tr>
                                                    <th>Date</th>
                                                    <th>Medicine Name</th>
                                                    <th>Routes</th>
                                                    <th>Dosage Form</th>
                                                    <th>Dosage Qty</th>
                                                    <th>Edit</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>

                                    </div>
                                </td>
                            </tr>
                        </table>

                       

                        <div class="row">
                            <div class="col-md-2">
                                <label>Special Instruction:</label>
                            </div>
                            <div class="col-md-10">
                                <asp:TextBox ID="txtSpecialInstruction" runat="server" Columns="10" Rows="5" Style="width: 60%;" TextMode="MultiLine"></asp:TextBox>
                            </div>
                        </div>

                        <div class="row row-fill" style="margin-top: 25px;display:inline;">
                            <h4><u>Fill By Scrub Nurse:</u></h4>

                            <div class="col-md-6">
                                <p>a. Estimated Blood Loose</p>
                                <p>b. Intra Operative IV Fluid / Blood Transfused </p>
                                <p>c. Intra Operative Urine Output (If Catheterized)</p>
                                <p>d. Whether Swab and Instrument Count was Complete </p>
                            </div>

                            <div class="col-md-6">
                                <div class="row">
                                    <input type="checkbox" runat="server" id="chk_Bloodloose" name="Blood Loose" />
                                </div>
                                <div class="row">
                                    <input type="checkbox" runat="server" id="chk_Bloodtrans" name="Blood Transfused" />
                                </div>
                                <div class="row">
                                    <input type="checkbox" runat="server" id="chk_Urine" name="Operative Urine" />
                                </div>
                                <div class="row">
                                    <input type="checkbox" runat="server" id="chk_Swab_Instrument" name="swab Instrument" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>


            <div id="Tab-10">
                <div id="Recovery" style="width: 100%">
                    <table>
                        <tr>
                            <td colspan="6">
                                <h2>Recovery Details : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td>Recovery Details</td>
                            <td>
                                <asp:TextBox ID="txtRecoveryDetails" Width="600px" runat="server" Columns="10" Rows="5" TextMode="MultiLine"></asp:TextBox>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>


            <div id="Tab-11">
                <div id="Transfer">
                    <table style="width: 100% !important;">
                        <tr>
                            <td colspan="6">
                                <h2>Transfer Details : </h2>
                                
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <label>Previous Dept.</label></td>
                            <td>
                                <input type="text" id="txtdprevDepart" disabled /></td>
                            <td>
                                <label>Previous Ward / Bed</label></td>
                            <td>
                                <input type="text" id="txtWardBed" style="width: 223px!important;" disabled /></td>
                            <td>
                                <label>Previous Room / Bed</label></td>
                            <td>
                                <input type="text" id="txtRoomBed" disabled /></td>
                        </tr>
                        <tr>
                            <td style="width: 143px; padding-left: 45px;">
                                <asp:Label ID="lblreferto" runat="server" Text="Transfer To *"></asp:Label>
                            </td>
                            <td style="width: 203px">
                                <asp:UpdatePanel ID="UpdatePanel4" TabIndex="6" runat="server">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlReferTo" runat="server" AppendDataBoundItems="true" onChange="chkrefer_Of_Select();"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>

                        </tr>
                        <tr>
                            <td>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="ddlReferTo" InitialValue="0" runat="server" ErrorMessage="Select Refer To" Text="*"></asp:RequiredFieldValidator>
                            </td>
                            <td>
                                <asp:UpdatePanel ID="UpdatePanel10" runat="server" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:Label ID="Label43" runat="server" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:UpdatePanel ID="UpdatePanel14" runat="server">
                                    <ContentTemplate>
                                <asp:Button ID="btnAllocatedRoomwardCheckRefer" Style="display: none;" Text="Chk Allocated Room" runat="server" OnClick="btnAllocatedRoomwardCheckRefer_Click" CausesValidation="false" />
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 45px;">
                                <asp:Label ID="lblWards" runat="server" Text="Ward *"></asp:Label>
                            </td>
                            <td>
                                <asp:UpdatePanel ID="UpdatePanel15" TabIndex="7" runat="server" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlwards" runat="server" AppendDataBoundItems="true" OnChange="FillWardBedsRefer()" disabled="disabled"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 45px;">
                                <asp:Label ID="lblBedno" runat="server" Text="Bed No"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBedno" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
                            </td>

                            <td>
                     <asp:RangeValidator ID="RangeValidator1" Type="Integer" runat="server" MinimumValue="0" MaximumValue="999999999" ControlToValidate="txtBedno" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 45px;">
                                <asp:Label ID="lblRoom" runat="server" Text="Room_No *"></asp:Label>
                            </td>
                            <td>
                                <asp:DropDownList ID="ddlroom" TabIndex="9" runat="server" AppendDataBoundItems="true" AutoPostBack="true" disabled="disabled"></asp:DropDownList>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 45px;">
                                <asp:Label ID="lblroomtype" runat="server" Text="Room Type"></asp:Label>
                            </td>
                            <td>
                                <asp:UpdatePanel ID="UpdatePanel16" TabIndex="10" runat="server">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlRoomType" runat="server" AppendDataBoundItems="true" AutoPostBack="true" onChange="FillRoomsRefer()"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td style="padding-left: 141px; padding-top: 20px;" colspan="2">
                                <input type="button" class="btn btn-primry" id="btnTransfer" onclick="SaveTransferDetails();" value="Save Transfer"  />
                            </td>
                        </tr>

                    </table>
                    <div style="margin-left: 497px; margin-top: -240px; width: 20%; overflow: scroll; height: 250px; max-height: 400px !important;">
                        <table id="tblBed" class="table" style="width: 100% !important;">
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
                    <div style="margin-left: 902px; margin-top: -250px;overflow: scroll; height: 250px; max-height: 400px !important;">
                        <table id="tblRoom" class="table" style="width: 100% !important;">
                            <thead>
                                <tr>
                                    <th>MR No.</th>
                                    <th>Room No</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
        </div>

        <div id="MedicationModel" class="modal fade" role="dialog">
            <div class="modal-dialog">
                <!-- Modal content-->
                <div class="modal-content" <%--style="width: 824px; margin-left: -100px;"--%>>
                    <div class="modal-header">
                        <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">Add Medicine</h4>
                    </div>

                    <div class="modal-body">
                        <fieldset>
                            <legend>Medication Details</legend>
                            <table id="tblMedicines" class="add-test">
                                <tr>
                                    <td style="width: 120px">
                                        <span id="lblMed">Medicine Name</span>
                                        <span class="RedStar">&nbsp;&nbsp;*</span>
                                    </td>                                 
                                    <td style="width: 234px">
                                        <div style="margin-bottom: 12px;">
                                            <select id="txtPharmacyItem" name="txtPharmacyItem" style="width: 100% !important;" onchange="Cleardrpdwn()">
                                            </select>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 110px"><span>Dose</span><span class="RedStar"> &nbsp;&nbsp;*</span></td>
                                    <td>                                   
                                        <select style="width: 80px !important; float: left !important; margin-right: 10px;" id="ddlDosage_Qty" name="DosageQty">
                                            <option value="">Select</option>
                                        </select>
                                        <select style="width: 61% !important; float: left !important;" id="ddlDosage_From" name="DosageFrom">
                                            <option value="">Select</option>
                                        </select>
                                    </td>
                                    <td></td>
                                </tr>

                                
                                <tr>
                                    <td><span>Route </span><span class="RedStar">&nbsp;&nbsp;*</span></td>
                                    <td>
                                        <select id="Routes" name="Routes" tabindex="4" ></select>
                                    </td>
                                </tr>


                                <tr>
                                    <td></td>
                                    <td>
                                        <input type="button" id="btnSaveMedicine"  class="btn btn-primry" name="btnSaveMedicine" value="Save" tabindex="7" />
                                    </td>



                                </tr>
                            </table>
                        </fieldset>
                        <input type="hidden" name="uurowid" value="" />
                    </div>
                    <div class="modal-footer">
                        <input type="button" style="width:14% !important" class="btn-gray" value="Done" data-dismiss="modal" />


                    </div>
                </div>
            </div>
        </div>
       
         <div class="row" style="margin-top:1%">
             <div class="col-lg-8">
                 <div class="row">
     <div class="col-lg-2 col-md-4 col-sm-6">
         <asp:Button Text="View" CssClass="btn btn-gray" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/OT/OperationTheaterList.aspx" />
     </div>
     <div class="col-lg-2 col-md-4 col-sm-6">
           <asp:Button ID="btnSave" CssClass="btn btn-primry"  runat="server" Text="Save" OnClientClick="SaveMedicines()" OnClick="btnSave_Click" CausesValidation="false" />
 </div>
     <div class="col-lg-2 col-md-4 col-sm-6">
       <asp:Button Text="New"  ID="btn3" CssClass="btn btn-yellow" runat="server" PostBackUrl="~/Modules/OT/OperationBooking.aspx" CausesValidation="false" />         
     </div>

    <%-- <div class="col-lg-2 col-md-4 col-sm-6">
         <input type="button" name="btnPrint" class="btn btn-primry" id="btnPrints" onclick="PrintConsultant()" value="Consent Print" />
     </div>--%>
     </div>
             </div>
        </div>
        <div style="padding-left: 70px; padding-top: 20px;">
           
            <table>
                <tr>
                    <td>
                        <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                            ShowSummary="true" DisplayMode="List" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblMessage" runat="server"></asp:Label>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <%--Code for new Patient add--%>

    <div id="PatientModel" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content modalSize" style="width: 1000px; margin-left: -270px; height: 319px; /* 316px */">

                <table class="Add_new_test" style="width: 80%;">
                    <tbody>
                        <tr>
                            <td>
                                <label>Name</label>
                                <label class="star">*</label>
                                <select class="impo-drop fcux" name="name" id="ddl_name">
                                    <option value="Mr.">Mr.</option>
                                    <option value="Mrs.">Mrs.</option>
                                    <option value="Ms.">Ms.</option>
                                    <option value="B/O.">B/O.</option>
                                </select>
                            </td>

                            <td class="txt-impo">
                                <input class="impo fcux" name="dob" type="text" id="txt_name" />
                            </td>

                            <td>

                                <label>Relation</label>
                                <select class="impo-drop fcux" name="name" id="ddlRelation" style="border: 1px solid #d5d5d5 !important;">
                                    <option value="S/O">S/O</option>
                                    <option value="W/O">W/O</option>
                                    <option value="D/O">D/O</option>
                                </select>
                            </td>
                            <td class="txt-impo">
                                <input class=" fcux" type="text" id="txt_relation" />
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <label>Gender</label>
                                <label class="star">*</label>
                            </td>
                            <td>
                                <select id="ddl_Gender" class="impo fcux">
                                    <option></option>

                                </select>
                            </td>
                            <td>
                                <label>Mobile</label>
                                <label class="star">*</label>
                                <td>
                                    <input class="fcux" type="text" id="txt_mobile" />
                                </td>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <label>Age</label>

                                <select class="impo-drop fcux" name="DOB" id="ddl_dob" style="border: 1px solid #d5d5d5 !important;">
                                    <option value="Y">Year</option>
                                    <option value="M">Month</option>
                                    <option value="D">Day</option>
                                </select>
                            </td>

                            <td class="txt-impo">
                                <input class=" fcux" name="dob" type="text" id="txt_dob" />
                            </td>

                            <td>
                                <label>CNIC</label>
                                <td>
                                    <input class="fcux" type="text" id="txt_cnic" />
                                </td>
                            </td>
                        </tr>

                        <tr>
                            <td>
                                <label>Martial Status</label>
                                <td>
                                    <select class="fcux" id="ddl_status">
                                        <option></option>
                                    </select>
                                </td>
                            </td>

                            <td>
                                <label>Address</label>
                                <td>
                                    <input class="fcux" type="text" id="txt_Address" />
                                </td>
                            </td>

                        </tr>
                        <tr>
                            <td>
                                <label>Patient Category</label>
                                <label class="star">*</label>
                                <td>
                                    <select id="ddl_ctgry" class="impo fcux">
                                        <option></option>
                                    </select>
                                </td>
                            </td>

                            <td class="forPanel">
                                <label>Panel Company</label>
                                <label class="star">*</label>
                            </td>
                            <td>
                                <select class="impo fcux" id="ddl_pnl_cpy">
                                    <option></option>
                                </select>
                            </td>
                        </tr>


                        <tr>
                            <td>
                                <label>Main Department</label>
                                <label class="star">*</label>
                            </td>
                            <td>
                                <select class="impo fcux" id="ddltest_main_dpt">
                                    <option></option>
                                </select>
                            </td>

                            <td>
                                <label>Blood Group</label>
                                <td>
                                    <select class="fcux" id="ddl_bld_grp">
                                        <option></option>
                                    </select>
                                </td>
                            </td>
                            <td>Rh Factor :
                                <select class="fcux" id="ddlRhFactor">
                                    <option></option>
                                </select>
                            </td>
                        </tr>
                    </tbody>
                </table>

                <div class="modal-footer">
                    <input type="button" id="SavePatient_Data" name="savePatient_Data" value="Save" onclick="SavePatient();" />
                    <input type="button" id="updatePatient_Data" name="updatePatient_Data" style="text-transform: capitalize;" value="Update" onclick="SavePatient();" tabindex="23" />
                    <input type="button" id="CloseSearchModel" name="saveENT" value="Close" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>

</asp:Content>
