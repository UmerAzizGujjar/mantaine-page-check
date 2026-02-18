<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientsCase.aspx.cs" Inherits="PMS.InPatientsCase" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/ipdcase.css" rel="stylesheet" />

    <script type="text/javascript">
        (function ($) {
           
            jQuery.ptTimeSelect.setTime = function () {

                var tSel = jQuery('#ptTimeSelectUserSelHr').text()
                    + ":"
                    + jQuery('#ptTimeSelectUserSelMin').text()
                    + " "
                    + jQuery('#ptTimeSelectUserSelAmPm').text();
                jQuery(".isPtTimeSelectActive").val(tSel);
                this.closeCntr();
                if (TimePicker == "txtStopTime") {
                    var stop_Date = $('#txtStopDateTime').val();
                    if (stop_Date == "") {
                        debugger;
                        var start_Date = $('#txtStartDate').val();
                        var start_Time = $('#txtStartTime').val();
                        var complete = start_Date + ' ' + start_Time;
                        var stop_Date = $('#txtStartDate').val();
                        var stop_Time = $('#txtStopTime').val();
                        var completeStop = stop_Date + ' ' + stop_Time;


                        var oldDate = new Date(complete)
                        var newDate = new Date(completeStop)
                        var time = newDate - oldDate;
                        var seconds = moment.duration(time).seconds();
                        var minutes = moment.duration(time).minutes();
                        var hours = moment.duration(time).hours();
                        var days = moment.duration(time).days();
                        $('#txtDurationInfusion').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
                    }
                    else {
                        debugger;
                        var start_Date = $('#txtStartDate').val();
                        var start_Time = $('#txtStartTime').val();
                        var complete = start_Date + ' ' + start_Time;
                        var stop_Date = $('#txtStartDate').val();
                        var stop_Time = $('#txtStopTime').val();
                        var completeStop = stop_Date + ' ' + stop_Time;


                        var oldDate = new Date(complete)
                        var newDate = new Date(completeStop)
                        var time = newDate - oldDate;
                        var seconds = moment.duration(time).seconds();
                        var minutes = moment.duration(time).minutes();
                        var hours = moment.duration(time).hours();
                        var days = moment.duration(time).days();
                        if (time < 0) {

                        }
                        else {
                            $('#txtDurationInfusion').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
                        }
                    }
                }
                else {
                    var stop_Date = $('#txtStopD').val();
                    if (stop_Date == "") {
                        debugger;
                        var start_Date = $('#txtStartD').val();
                        var start_Time = $('#txtStartT').val();
                        var complete = start_Date + ' ' + start_Time;
                        var stop_Date = $('#txtStartD').val();
                        var stop_Time = $('#txtStopT').val();
                        var completeStop = stop_Date + ' ' + stop_Time;


                        var oldDate = new Date(complete)
                        var newDate = new Date(completeStop)
                        var time = newDate - oldDate;
                        var seconds = moment.duration(time).seconds();
                        var minutes = moment.duration(time).minutes();
                        var hours = moment.duration(time).hours();
                        var days = moment.duration(time).days();
                        $('#txtInjection').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
                    }
                    else {
                        debugger;
                        var start_Date = $('#txtStartD').val();
                        var start_Time = $('#txtStartT').val();
                        var complete = start_Date + ' ' + start_Time;
                        var stop_Date = $('#txtStopD').val();
                        var stop_Time = $('#txtStopT').val();
                        var completeStop = stop_Date + ' ' + stop_Time;


                        var oldDate = new Date(complete)
                        var newDate = new Date(completeStop)
                        var time = newDate - oldDate;
                        var seconds = moment.duration(time).seconds();
                        var minutes = moment.duration(time).minutes();
                        var hours = moment.duration(time).hours();
                        var days = moment.duration(time).days();
                        if (time < 0) {

                        }
                        else {
                            $('#txtInjection').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
                        }
                    }
                }

            };
        })(jQuery);
        var btnVal = '';
        localStorage.IsDischarge = 0;

        $(document).on('keyup', '.select2-search__field', function () {
            var searchString = $(this).val();

            var options;
            $.ajax({
                url: 'InPatientsCase.aspx/getpharmacyitems',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchString }),
                success: function (response) {
                    var options = '';
                    try {
                        var pharmacyItems = JSON.parse(response.d);
                        $.each(pharmacyItems, function (key, value) {
                            options += '<option value="' + value.Item_Code + '"> ' + value.Description + ' </option>';
                        });
                        $('#txtPharmacyItem').append(options).trigger('change');
                    } catch (error) {
                        console.error('Error parsing response:', error);
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching data:', error);
                }
            });
        });

        $(document).on('keydown', '.select2-search__field', function (event) {
            if (event.keyCode === 13) {
                $('#txtPharmacyItem').select2('close');
            }
        });

        $(document).ready(function () {
            debugger;
            $("#tabs").tabs();
            CheckReferIPDPermission();
            

            $('#ctl00_MainContent_ctl00_MainContent_txtEOR').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_txtMR').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_txtVR').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_TxtR_Upper').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_TxtL_Upper').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_TxtR_Lower').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });
            $('#ctl00_MainContent_TxtL_Lower').on('focus click', function () {
                $(this)[0].setSelectionRange(0, 0);
            });






            $('#Addmedicine').attr('disabled', true);



            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtCNIC'),
                format: '_____-_______-_',
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




            MaskedInput({

                elm: document.getElementById('ctl00_MainContent_ctl00_MainContent_txtEOR'),
                format: '_/4',
                separator: '/',

            });

            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtMR'),
                format: '_/6',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtVR'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_txtAcc'),
                format: '_/15',
                separator: '/'
            });

            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_TxtR_Upper'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_TxtL_Upper'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_TxtR_Lower'),
                format: '_/5',
                separator: '/'
            });
            MaskedInput({
                elm: document.getElementById('ctl00_MainContent_TxtL_Lower'),
                format: '_/5',
                separator: '/'
            });

            $("#ctl00_MainContent_ddlDeathCertifiedbyDr1").select2({
                placeholder: "Select a doctor",
                allowClear: true
            });
            $("#ctl00_MainContent_ddlDeathCertifiedbyDr2").select2({
                placeholder: "Select a doctor",
                allowClear: true
            });
            $("#ctl00_MainContent_ddlDoctorClinicalSummary").select2({
                placeholder: "Select a doctor",
                allowClear: true
            });

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

            $('#ctl00_MainContent_ctl00_MainContent_txtEOR').on('keypress, keydown', function (event) {
                debugger;
                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_txtMR').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) && ((this.selectionEnd >= 1) ||
                    ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });

            $('#ctl00_MainContent_txtVR').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });



            $('#ctl00_MainContent_TxtR_Upper').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_TxtL_Upper').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });

            $('#ctl00_MainContent_TxtR_Lower').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });


            $('#ctl00_MainContent_TxtL_Lower').on('keypress, keydown', function (event) {

                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd >= 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });

            

            var id = '<%=Request.QueryString["ID"]%>';
            if (id == "") {
                RemoveExtraDepts();
            }
                
                
            
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                setTimeout(function () {

                }, 1000);
            }
            else {
                fillPendingPatientsList();
                setTimeout(function () {
                    $("#ctl00_MainContent_ddlDepartments").val(0);

                }, 1000);
            }
            $('#ctl00_MainContent_ddlDepartments').on("change", function () {
                localStorage.DeptID = $('#ctl00_MainContent_ddlDepartments').find('option:selected')[0].value;
                fillPendingPatientsList();
            });

        });
        function check() {
            debugger;
            if ($("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PSYCHIATRY") {
                $("#ctl00_MainContent_lblNextPlan").show();
                $("#ctl00_MainContent_txtNextPlan").show();
            }
            else {
                $("#ctl00_MainContent_lblNextPlan").hide();
                $("#ctl00_MainContent_txtNextPlan").hide();
            }
            if ($("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "MEDICINE UNIT-II" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "MEDICINE UNIT-I" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS MEDICINE" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS SURGERY" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS CAMP") {
                if ($("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS MEDICINE" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS SURGERY" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "PAEDS CAMP") {
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').hide();
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').hide();
                    $("#ctl00_MainContent_Label34").hide();
                    $("#ctl00_MainContent_txtedd").hide();
                    $("#ctl00_MainContent_txtMUAC").show();
                    $("#ctl00_MainContent_txtOFC").show();
                    $("#ctl00_MainContent_lblMUAC").show();
                    $("#ctl00_MainContent_lblOFC").show();
                }
                else {
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').show();
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').show();
                    $("#ctl00_MainContent_Label34").show();
                    $("#ctl00_MainContent_txtedd").show();
                    $("#ctl00_MainContent_txtMUAC").hide();
                    $("#ctl00_MainContent_txtOFC").hide();
                    $("#ctl00_MainContent_lblMUAC").hide();
                    $("#ctl00_MainContent_lblOFC").hide();
                }

                $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').hide();
                $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').hide();

                $("#ctl00_MainContent_Label34").hide();
                $("#ctl00_MainContent_txtedd").hide();
                $("#tblPsychiatryHistory").hide();
                $("#ctl00_MainContent_txtBirthHistory").hide();
                $("#ctl00_MainContent_Label15").hide();
                $('#ui-id-20').hide();
                $('#ui-id-21').hide();
                $('#ui-id-19').hide();
                $("#tabGO").show();
            }
            else {

                $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').show();
                $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').show();
                $("#ctl00_MainContent_Label34").show();
                $("#ctl00_MainContent_txtedd").show();
                $("#tblPsychiatryHistory").show();
                $("#ctl00_MainContent_txtMUAC").hide();
                $("#ctl00_MainContent_txtOFC").hide();
                $("#ctl00_MainContent_lblMUAC").hide();
                $("#ctl00_MainContent_lblOFC").hide();
            }
            if ($("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "SURGERY-I" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "SURGERY-II" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "GYNAE UNIT-I" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "GYNAE UNIT-II") {

                $("#ctl00_MainContent_txtBirthHistory").hide();
                $("#ctl00_MainContent_Label15").show();
                $("#ctl00_MainContent_txtGIT").show();
                $("#ctl00_MainContent_Label50").show();
                $("#ctl00_MainContent_txtAbdomin").show();
                $("#ctl00_MainContent_lblAbdomin").show();
                $("#tblPeExam").find('tr:nth-child(3)').show();
                $("#tblPeExam").find('tr:nth-child(2)').show();
                if ($("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "GYNAE UNIT-I" || $("#ctl00_MainContent_ddlDepartments :selected").text().trim() == "GYNAE UNIT-II") {
                    $("#ctl00_MainContent_txtCVS").show();
                    $("#ctl00_MainContent_Label6").show();
                    $("#ctl00_MainContent_txtRESP").show();
                    $("#ctl00_MainContent_Label2").show();
                    $("#tabGO").show();
                    $('#ui-id-19').show();
                    $('#ui-id-20').show();
                    $('#ui-id-21').show();
                    $("#ctl00_MainContent_txtBirthHistory").hide();
                    $("#ctl00_MainContent_Label15").hide();
                    $("#ctl00_MainContent_txtGYNAE").show();
                    $("#ctl00_MainContent_Label16").show();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').show();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').show();
                }
                else {
                    $("#ctl00_MainContent_txtCVS").show();
                    $("#ctl00_MainContent_Label6").show();
                    $("#ctl00_MainContent_txtRESP").show();
                    $("#ctl00_MainContent_Label2").show();
                    $('#ui-id-20').hide();
                    $('#ui-id-21').hide();
                    $("#tabGO").show();
                    $('#ui-id-19').hide();
                    $("#ctl00_MainContent_txtGYNAE").hide();
                    $("#ctl00_MainContent_Label16").hide();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').hide();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').hide();
                }
            }
            else {
                $("#ctl00_MainContent_txtGIT").show();
                $("#ctl00_MainContent_Label50").show();
                $("#ctl00_MainContent_txtAbdomin").show();
                $("#ctl00_MainContent_lblAbdomin").show();
                $('#ui-id-20').hide();
                $('#ui-id-21').hide();
                $("#tabGO").show();
                $('#ui-id-19').hide();
                $("#ctl00_MainContent_txtBirthHistory").show();
                $("#ctl00_MainContent_Label15").show();
                $("#tblPeExam").find('tr:nth-child(3)').hide();
                $("#tblPeExam").find('tr:nth-child(2)').hide();
                $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').hide();
                $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').hide();
            }
        }
        $(function () {
            $("#ctl00_MainContent_ddlDepartments").change(function () {
                check();
            });
        });

        function PrintMecicationDetail() {
            debugger;
            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=Medication&ReportTitle=In Patient Medication Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function PrintMecicationDetailPRN() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=MedicationPRN&ReportTitle=In Patient Medication PRN Print' + '&In_Patient_ID=' + In_Patient_ID);
        } PrintMecicationDetail

        function PrintMecicationDetailSTAT() {
            debugger;
            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=MedicationSTAT&ReportTitle=In Patient Medication STAT Print' + '&In_Patient_ID=' + In_Patient_ID);
        }

        function InfusionPrint() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=Infusion&ReportTitle=In Patient Infustion Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function PrintVitalMedicationDetail() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=Medication&ReportTitle=In Patient Vital Discharge Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        debugger;
        function PrintInPatient() {
            debugger;
            var id = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            if (id != "") {
                window.open('../../ReportViewer.aspx?ReportName=InpatientDetail&Title=In Patient Detail Print&InPatient_ID=' + id);
            }
        }

        function PrintConsultant() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=Clinical_Summary&ReportTitle=In Patient Clinical Print' + '&In_Patient_ID=' + In_Patient_ID);
        }

        function AddPrint() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=In_Patient_History&ReportTitle=In Patient History Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function AdPrint() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=In_Patient_VitalSigns&ReportTitle=In Patient Vital Sign Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function PrintVitals() {
            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=PrintIPDVitals&ReportTitle=In Patient Doctor Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function ProgressNote() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=ProgressNote&ReportTitle=In Patient Doctor Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function PrintS() {

            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=Certificate_In_Patient&ReportTitle=In Patient Death Certificate Print' + '&In_Patient_ID=' + In_Patient_ID);
        }

        function saveprint() {

            $('#loadingimage').show();
            CheckExistInOutPatient();
        }

        

        var tabsEmr;
        function CheckReferIPDPermission() {
            $.ajax({
                type: "POST",
                url: "InPatientsCase.aspx/CheckReferIPDRights",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    tabsEmr = data.d;
                    $('#ui-id-12').show();

                    if (tabsEmr == '"True"') {
                        $('#ui-id-1').show();
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
                        $('#ui-id-13').show();
                        $('#ui-id-15').show();
                        $('#Tab-19').show();
                    } else {
                        $('#ui-id-1').hide();
                        $('#ui-id-2').hide();
                        $('#ui-id-3').hide();
                        $('#ui-id-4').hide();
                        $('#ui-id-5').hide();
                        $('#ui-id-6').hide();
                        $('#ui-id-7').hide();
                        $('#ui-id-8').hide();
                        $('#ui-id-9').hide();
                        $('#ui-id-10').hide();
                        $('#ui-id-11').hide();
                        $('#ui-id-13').hide();
                        $('#ui-id-15').hide();
                        $('#Tab-19').hide();

                        var referIndex = $("#tabs ul li a[href='#Tab-12']").closest('li').index();
                        if (referIndex >= 0) {
                            $("#tabs").tabs("option", "active", referIndex);
                        }
                    }
                },
                failure: function () {
                    alert("bi");
                }
            });
        }

        function AddServiceOrItem() {

            var User_Name = '<%= AppConfig.UserName %>';
            var Item_Id = $('#ctl00_MainContent_txtService').val();
            var entryDate = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt") %>';
            setTimeout(function () {

                if ($('#ctl00_MainContent_txtService').val() === "")
                    return false;




                var rows = '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + localStorage.SelectedItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /> <input type="hidden" name="hdnPageType" value="IPD" />' + localStorage.SelectedItemName + '</td><td style="text-align:left;">' + User_Name + '</td> <td style="text-align: left;"><a href="javascript:void(0)" onclick="DeleteRow(this)" >Delete</a> </td> </tr>';

                $('#tblServices tbody').append(rows);
                $('#ctl00_MainContent_txtService').tokenInput('clear');

            }, 300);


        }

        function DeleteRow(anchor) {
            var row = $(anchor).parents('tr')[0];
            row.remove();

        }

        function PrintAdmisionDetails(response) {

            PATID = $('#<%=txtPatient_ID.ClientID%>').val();

            InPAtID = response;
            $.ajax({
                type: "POST",
                url: "InPatientsCase.aspx/PrintInPatientReceipt",
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
                url: "InPatientsCase.aspx/PrintInPatientReceipt",
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
                url: "InPatientsCase.aspx/PrintInPatientReceipt",
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
                url: "InPatientsCase.aspx/PrintInPatientReceipt",
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



        function PrintInpatientReceipt() {

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
                    url: "InPatientsCase.aspx/PrintInPatientReceipt",
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

        function AddBloodTest() {
            debugger;

            var test = $('#ddlTestList').find('option:selected').text();


            PageMethods.GetBBDDLDetails(test, function (res) {

                var doctorVal;
                var doctor;
                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy h:m:s A")%>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;


                    doctorVal = $('#tblDOctorNotes').find('tbody').find('td input[name=txtDoctorValue]').val();


                    doctor = $('#tblDOctorNotes').find('tbody').find('td input[name=txtDoctorName]').val();

                    if (doctor == "" || doctor == undefined || doctor == null || doctor == "NULL" || doctor == "null") {
                        doctor = "-";
                    }


                    if (doctorVal == 0 || doctorVal == undefined) {
                        doctorVal = "";

                    }


                    if (value.Test_ID != 0) {

                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '"/></td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '"/></td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }


                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);
                        $('#ctl00_MainContent_txtAreaOfInterest').val('');

                    }
                });

            }, function (err) { });

        }

        function LoadVitalParametersHistoryDischarge(PatientID) {

            if (PatientID != "(New)") {
                PageMethods.LoadVitalParametersHistoryDischarge(PatientID, function (res) {
                    var Data = JSON.parse(res);
                    var rows = '';
                    var gcs = "";
                    $.each(Data, function (key, value) {

                        if (value.RateBeats == "" && value.Emergency_Rhythm == null && value.Emergency_Volume == null && (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.BP_mm_Hg == "___/___" && value.O2_Saturation == "" && value.O2_Saturation_Oxygen1 == "" && value.O2_Saturation_Oxygen2 == "" && (value.RN_Special_Instruction == "<li></li>" || value.RN_Special_Instruction == "") && (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.Temp_C == "") {

                        }
                        else {
                            if (value.GCS == null) {

                                GCS = "";
                            }
                            else {
                                gcs = value.GCS;
                            }
                            if (value.Emergency_Rhythm == null) value.Emergency_Rhythm = "";
                            if (value.Emergency_Volume == null) value.Emergency_Volume = "";

                            var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));

                            var retdateRec = moment.unix(TrnsDateRec).format('MM/DD/YYYY hh:mm:ss A');
                            rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.RateBeats
                                + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Emergency_Rhythm + ' </td><td> ' + value.Emergency_Volume + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td> ' + value.OthersRecieveNote + ' </td> <td> ' + value.Respiration_Min + ' </td><td> ' + value.RN_Special_Instruction + ' </td><td> ' + value.O2_Saturation + ' </td><td>' + value.O2_Saturation_Oxygen1 + '</td><td>' + value.O2_Saturation_Oxygen2 + '</td><td>' + value.Blood_Suger + '</td><td>' + value.BMI + '</td><td>' + value.Weight_Kg + '</td><td>' + value.Height_cm + '</td><td>' + value.User_Name + '</td></tr>';
                        }
                    });

                    $('#tblVitalParametersHistoryDesc tbody tr').remove();
                    $('#tblVitalParametersHistoryDesc tbody').html(rows);
                });
            }
        }

        function LoadDischargeMedicinesrpt(PatientID) {
            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            PageMethods.LoadDischargeMedicinesrpt(ID, oUTID, function (res) {
                var Medicines = JSON.parse(res);
                var rows = '';
                $('#tblTestrpt tr').remove();
                $.each(Medicines, function (key, value) {
                    rows += '<tr><td>*</td><td>' + value.Medicine_Name + '</td> <td> ' + value.Frequency + '</td><td style="width:1px">دن</td><td>' + value.Injections + ' </td></tr>';
                });
                $('#tblTestrpt').html(rows);
                LoadExamrpt();
            });
        }

        function FillProcedure(deptID) {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetProcedure(deptID, function (item) {
                $.each(JSON.parse(item), function (key, value) {

                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
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
            var TransactionID = $("#<%= txtIn_Patient_ID.ClientID%>").val();
            if (TransactionID == '(New)' || TransactionID == '')
                TransactionID = 0;
            var data = { 'TransactionID': TransactionID, 'EyeDetails': list };
            PageMethods.SaveEyeList(JSON.stringify(data), function (res) {
                SaveHistoryTab();
            });
        }
        function LoadEyeList() {
            var patientID = $("#<%= txtIn_Patient_ID.ClientID%>").val();
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

        function ROPFunction() {
            debugger;
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
            if ($("#ctl00_MainContent_txtMR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtMR").val().split('/')[0] <= 6) {
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
                return $("#ctl00_MainContent_txtMR").val('_/6');
            }
        }

        function VRFunction() {

            if ($("#ctl00_MainContent_txtVR").val().split('/')[0] > 0 && $("#ctl00_MainContent_txtVR").val().split('/')[0] <= 5) {
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
                return $("#ctl00_MainContent_txtVR").val('_/5');
            }
        }

        function saveAllRecord() {

            debugger;
            var btnsave = $('#btnSave').val();
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            var txtAdmission_Date = $('#ctl00_MainContent_txtAdmission_Date').val();

            var txtHealth_Complaints = $('#ctl00_MainContent_txtHealth_Complaints').val();
            var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();

            var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();

            var patienttype = $("#ctl00_MainContent_vLbl_Patient_Type").text();
            var pulse_Min = $('#ctl00_MainContent_txtPuls').val();

            var BP_mm_Hg = $('#ctl00_MainContent_txtBP').val();
            var Temp_C = $('#ctl00_MainContent_txtTemp').val();
            var BMI = $('#ctl00_MainContent_txtBMI').val();
            var Weight = $('#ctl00_MainContent_txtWeight').val();
            var Height = $('#ctl00_MainContent_txtHeight').val();
            var BSR = $('#ctl00_MainContent_txtBSR').val();
            var Respiration_Min = $('#ctl00_MainContent_txtRespiration').val();
            var txtRN_Special_Instruction = toHtml('#ctl00_MainContent_txtRN_Special_Instruction');
            var txtReceiving_Date = $('#ctl00_MainContent_txtReceiving_Date').val();

            var Provisional_Diagnosis = toHtml('#ctl00_MainContent_txtProvisionalDiagnosis');
            var Provisional_Diagnosis_Examination = toHtml('#ctl00_MainContent_txtProDiagExami');
            var Refer_To_Hospital = $('#ctl00_MainContent_txtRefer_To_Hospital').val();
            var Reffer_To = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
            if (Reffer_To == 0)
                Reffer_To = "";

            var HistoryOfPeresentIllness = toHtml('#ctl00_MainContent_txtHistoryOfPeresentIllness');
            var HistoryOfFamily = toHtml('#ctl00_MainContent_txtHistoryOfFamily');
            var HistoryOfPastIllness = toHtml('#ctl00_MainContent_txtHistoryOfPastIllness');
            var SocioEconomicHistory = toHtml('#ctl00_MainContent_txtSocioEconomicHistory');
            var Birth_History = toHtml('#ctl00_MainContent_txtBirthHistory');

            var Reffer_No = $('#ctl00_MainContent_txtRefferNote').val();
            var Drug_History = toHtml('#ctl00_MainContent_txtDrugHistory');
            var Personal_History = toHtml('#ctl00_MainContent_txtPersonalHistory');

            var ObstetricHistory = toHtml('#ctl00_MainContent_txtObstetricHistory');
            var AllergiesHistory = toHtml('#ctl00_MainContent_txtAllergiesHistory');
            var TreatmentHistory = toHtml('#ctl00_MainContent_txtTreatmentHistory');
            var VaccinationHistory = toHtml('#ctl00_MainContent_txtVaccinationHistory');
            var AnyOtherHistory = toHtml('#ctl00_MainContent_txtAnyOtherHistory');
            /*------ENT RECORD start-----*/

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
            var txtProcedure_Operation = $('#ctl00_MainContent_txtProcedure_Operation').val();
            var txtDignosis = $('#ctl00_MainContent_txtMedication').val();
            var txtProcedure_Detail = $('#ctl00_MainContent_txtBilling').val();
            var ddlDischarge_By = $('#ctl00_MainContent_ddlDischarge_By').val();
            var txtDischarge_On = $('#ctl00_MainContent_txtDischarge_On').val();
            var txtNext_Visit = $('#ctl00_MainContent_txtNext_Visit').val();
            var referto = $("#ctl00_MainContent_ddlReferTo").val();
            var referward = $("#ctl00_MainContent_ddlwards").val();
            var referbed_no = $("#ctl00_MainContent_txtBedno").val();
            var referroomno = $("#ctl00_MainContent_ddlroom").val();
            var referroomtype = $("#ctl00_MainContent_ddlRoomType").val();

            var RateBeats = $("#ctl00_MainContent_txtRateBeats").val();

            var Saturation = $("#ctl00_MainContent_txtSaturation").val();
            if (Saturation == " %") Saturation = "";
            var OthersRN = toHtml("#ctl00_MainContent_txtOthersRcvNote");

            var ddlEmrgRhythm = $('#ctl00_MainContent_ddlRhythm').val();
            var ddlEmrgVolume = $('#ctl00_MainContent_ddlVolume').val();
            var O2_Saturation_Oxygen1 = $("#ctl00_MainContent_txtSaturation_Oxygen1").val();
            if (O2_Saturation_Oxygen1 == " L/Min") O2_Saturation_Oxygen1 = "";
            var O2_Saturation_Oxygen2 = $("#ctl00_MainContent_txtSaturation_Oxygen2").val();
            if (O2_Saturation_Oxygen2 == " %") O2_Saturation_Oxygen2 = "";

            var TextBoxCns = $("#ctl00_MainContent_TextBoxCns").val();
            var TextBoxCvs = $("#ctl00_MainContent_TextBoxCvs").val();
            var TextBoxResp = $("#ctl00_MainContent_TextBoxResp").val();
            var TextBoxGit = $("#ctl00_MainContent_TextBoxGit").val();
            var TextBoxGpe = $("#ctl00_MainContent_TextBoxGpe").val();
            var FurtherExplanation = $("#ctl00_MainContent_txtFurtherExplanation").val();

            var eye_response = $('#ctl00_MainContent_ctl00_MainContent_txtEOR').val();
            var motor_response = $('#ctl00_MainContent_txtMR').val();
            var verbal_Response = $('#ctl00_MainContent_txtVR').val();
            var accumulated_response = $('#ctl00_MainContent_txtAcc').val();

            if (txtNext_Visit == "")
                txtNext_Visit = null;
            var txtAdvice = $('#ctl00_MainContent_txtPrevention_Precaution').val();
            var chkdischarge = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

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


            var JVP = $("input[name='ctl00$MainContent$JVP']:checked").val();
            if (typeof JVP === 'undefined') JVP = null;
            else JVP = (JSON.parse(JVP.toLowerCase()));

            var Edema = $("input[name='ctl00$MainContent$Edema']:checked").val();
            if (typeof Edema === 'undefined') Edema = null;
            else Edema = (JSON.parse(Edema.toLowerCase()));

            var Cyanosis = $("input[name='ctl00$MainContent$Cyanosis']:checked").val();
            if (typeof Cyanosis === 'undefined') Cyanosis = null;
            else Cyanosis = (JSON.parse(Cyanosis.toLowerCase()));

            var Murmur = $("input[name='ctl00$MainContent$Murmur']:checked").val();
            if (typeof Murmur === 'undefined') Murmur = null;
            else Murmur = JSON.parse(Murmur.toLowerCase());

            var SULR = $("input[name='ctl00$MainContent$SUL_RY']:checked").val();
            if (typeof SULR === 'undefined') SULR = null;
            else SULR = JSON.parse(SULR.toLowerCase());

            var SULL = $("input[name='ctl00$MainContent$SUL_LY']:checked").val();
            if (typeof SULL === 'undefined') SULL = null;
            else SULL = JSON.parse(SULL.toLowerCase());

            var SLLR = $("input[name='ctl00$MainContent$SLL_RY']:checked").val();
            if (typeof SLLR === 'undefined') SLLR = null;
            else SLLR = JSON.parse(SLLR.toLowerCase());
            var SLLL = $("input[name='ctl00$MainContent$SLL_LY']:checked").val();
            if (typeof SLLL === 'undefined') SLLL = null;
            else SLLL = JSON.parse(SLLL.toLowerCase());

            var PULR = $('#ctl00_MainContent_TxtR_Upper').val();
            var PULL = $('#ctl00_MainContent_TxtL_Upper').val();
            var PLLR = $('#ctl00_MainContent_TxtR_Lower').val();
            var PLLL = $('#ctl00_MainContent_TxtL_Lower').val();
            var Torso = toHtml('#ctl00_MainContent_txtTorsoTruck');

            var PulseRate = $('#ctl00_MainContent_txtPulseRate').val();
            var BPDischarge = $('#ctl00_MainContent_txtBPDischarge').val();

            var WeightDischarge = $('#ctl00_MainContent_txtWeightDischarge').val();
            var HeightDischarge = $('#ctl00_MainContent_txtHeightDischarge').val();
            var BMIDischarge = $('#ctl00_MainContent_txtBMIDischarge').val();
            var BSRDischarge = $('#ctl00_MainContent_txtBSRDischarge').val();


            var Rhythmdischarge = $('#ctl00_MainContent_ddlRhythmdischarge').val();
            var volumedisc = $('#ctl00_MainContent_ddlvolumedisc').val();
            var Tempdisch = $('#ctl00_MainContent_txtTempdisch').val();
            var RespRateDesc = $('#ctl00_MainContent_txtRespRateDesc').val();
            var Oxygen2_desc = $('#ctl00_MainContent_txtSaturation_Oxygen2_desc').val();
            
            var saturationDis = $('#ctl00_MainContent_txtsaturationDis').val();
            var Oxygen1 = $('#ctl00_MainContent_txtOxygen1').val();
            var otherecdesc = toHtml('#ctl00_MainContent_txtotherecdesc');
            var Special_Instruction_Desc = $('#ctl00_MainContent_txtRN_Special_Instruction_Desc').val();
            var Receiving_Date_Discharge = $('#ctl00_MainContent_txttxtReceiving_DateDesc').val();


            var IdentificationMarks = $("#ctl00_MainContent_txtIdentificationMarks").val();
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
            var clinical_Notes = toHtml('#ctl00_MainContent_txtAreaClinicalNotes');
            var doc = $('#ctl00_MainContent_ddlDoctorClinicalSummary').val();
            var Doctor_Notes = toHtml('#ctl00_MainContent_txtDoctoNotes');
            var ID = '<%= Request.QueryString["ID"]%>';
            debugger;
            var Discharge_Request = $("#ctl00_MainContent_DischargeRequest").val()
            var ddlDischarge_Type = $('#ctl00_MainContent_ddlDischarge_Type').val();
            if (Discharge_Request == 'false') {
                Discharge_Request = false
            }
            else {
                Discharge_Request = true
            }



            PageMethods.SaveRecord(Patient_ID, btnsave, txtAdmission_Date, ddlWard_No, txtHealth_Complaints, BP_mm_Hg, Temp_C, BMI, Weight, Height, BSR, Respiration_Min, txtRN_Special_Instruction, Provisional_Diagnosis, Reffer_To, HistoryOfPeresentIllness, HistoryOfFamily, HistoryOfPastIllness, SocioEconomicHistory, Birth_History, Reffer_No, Drug_History, Personal_History, ObstetricHistory, AllergiesHistory, TreatmentHistory, VaccinationHistory, AnyOtherHistory, ENT_Throat_IDL, ENT_Throat_Nose, ENT_Ear_Right, Ent_Ear_Left, ENT_Rinnes_Right_PosNeg, ENT_Rinnes_Lft_PosNeg, ENT_Rinnes_Right_FalseNeg, ENT_Rinnes_Lft_FalseNeg, ENT_Webber_Central, ENT_Webber_Lateralized, ENT_Investigation_PTA, ENT_Investigation_Tympanometry, ENT_Rinnes_Right_Neg, ENT_Rinnes_Lft_Neg, ENT_Rinnes_Right_FNeg, ENT_Rinnes_Lft_FNeg, txtInformant, txtSourceOfReferral, chkNeckHolding, chkWalking, chkTalking, chkOthers, txtMenarche, txtMenstrual, txtAttachmentSeparationfromParents, txtHealth, chkNailBiting, chkTemperTantrums, chkBedWetting, txtAcademics, txtPeerRelationship, txtBehaviour, txtOccupationalHistory, txtMaritalRelationshipSexualHistory, txtSubstanceUse, txtForensicUse, txtRelationship, txtLeisureActivities, txtAttitudetoSelfandStandards, txtPrevallingMood, txtReactionPattrentoStress, txtReligiousPracticesAttitute, txtFather, txtMother, txtSiblings, txtHomeAtmosphererelationshipsocialclass, txtFamilialIllness, txtActualandapparentage, txtRace, txtTattoosbodypiercingandscars, txtBodyHabitus, txtDress, txtHygiene, txtPsychomotorActivity, txtInvoluntarymovements, txtDystoniaEPS, txtTardivedyskinesia, txtTics, txtTremors, txtAttentivenesstointerview, txtEyeContact, txtLevelofConsciousness, txtRate, txtRhythm, txtVolume, txtTone, txtModulationvar, txtDepressed, txtElated, txtIrritable, txtLabile, txtIncongruent, txtbluntingflatteningapathy, txtThinkingPremeditation, txtPlans, txtActions, txtPreservative, txtLoosAssociation, txtTangentiaility, txtCircumstantiality, txtFlightofIdeas, txtThoughtInsertion, txtThoughtWithdrawal, txtThoughBroadcasting, txtThoughControl, txtDellusion, txtovervaluedideas, txtDepresonalization, txtDerealization, txtthrougObsession, txtthrougPhobies, txtthrougHomocidialIdeas, txtillusion, txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, txtorientationtime, txtplace, txtperson, txtAttentionConcentrationSerial7Test, txtOrDaysOfWeekReverseOrder, txtImmediatememory,
                txtshorttermrecentevents, txtadressrecallafter2minutes, txtlongtermremoteevents, txtadressrecallafter5minues, txtgeneralknowledgequestion, txtsimplearthemeticcalculation, txtabstrationconcertethinking, txtinsight, DermaFace, DermaNeck, DermaTrunk, DermaUpperLimb, DermaLowerLimb,
                DermaFlexures, DermaGenitalias, DermaHair, DermaNail, DermaMucousMembrane,
                DermaEyes, DermaEars, DermaNose, DermaLips, HBM_Problem, HBM_Caused, HBM_Started, HBM_Course, HBM_Treatment, HBM_Effects, PE_Pluse, PE_BP, PE_Temperature, PE_Weight, PE_RespiratoryRate, PE_Jaundice, PE_Anemia, PE_Cyanosis, PE_Clubbing, PE_JVP, PE_LymphNodes, PE_Edema, PE_Respiratory, PE_Cardiovascular, PE_Gastro_Intestinal, PE_Observation, PE_Cranial_Nerves, PE_Limb_Strength, PE_Spasticity, PE_Position, PE_Vibration, PE_Stereognosis, PE_Pain, PE_Biceps, PE_Triceps, PE_Brachioradialis, PE_Quadriceps, PE_Patellar, PE_Achilles, PE_Extensor, PE_Frontal, PE_Finger, PE_Heel, PE_Movements, PE_Gait, PE_Neck_Rigidity, PE_Kerning_Sign, PE_Brudzinki_Sign, For_Summary, For_Diagnosis, For_AxisI, For_AxisII, For_AxisIII, For_AxisIV, For_AxisV, For_PredisposingFactors, For_PrecipitatingFactors, For_PrepetuatingFactors, For_Investigation, For_Medical, For_Psychological, For_Major_Issues, For_Strengths, For_Goals, For_Strategies, txtPeads_weight, txtPeads_Length, txtPeads_HC, txtPeads_General_Appearance, chkPeads_Cyanosis, chkPeads_Jaundice, chkPeads_Lethargy, chkPeads_Rash, txtPeads_Others, chkPeads_Caput, chkPeads_Cephalhematoma, rdbPeads_Anterioropen, rdbPeads_AnteriorClose, chkPeads_Dextrocardia, chkPeads_Bulging, chkPeads_Murmur, txtPeads_HeartSound, chkPeads_Nasal, chkPeads_Recessions, txtPeads_AddedSounds, rdbPeads_Flat, rdbPeads_Distended, rdbPeads_Scaphoid, chkPeads_Liver, chkPeads_Spleen, txtPeads_GITOthers, chkPeads_Sucking, chkPeads_Rooting, chkPeads_Moro, txtPeads_CNSOthers, chkPeads_FullTerm, chkPeads_PreTerm, txtPeads_DateOfDelivery, txtPeads_TimeOfDelivery, rdbPeads_Booked, rdbPeads_UnBooked, chkPeads_DAIHandling, chkPeads_ANTURash, chkPeads_PIH, chkPeads_GDM, chkPeads_Vacinated, txtPeads_ANTOthers, rdbPeads_SVD, rdbPeads_LSCS, rdbPeads_Emergency, rdbPeads_Elective, txtPeads_PlaceOfDelivery, txtPeads_IndicationForLSCS, Peads_apgerScore1min, Peads_apgerScore5min, chkPeads_Resuscitation, txtPeads_NatalOthers, chkPeads_Moaning, chkPeads_RespDistress, chkPeads_PostNATALCyanosis, chkPeads_Fits, chkPeads_ReluctanceToFeed, txtPeads_PostNatalOthers, txtProcedure_Operation, txtProcedure_Detail, txtDignosis, txtDischarge_On, ddlDischarge_By, txtNext_Visit, txtAdvice, chkdischarge, patienttype, referto, referward, referbed_no, referroomno, referroomtype, RateBeats, ddlEmrgRhythm, ddlEmrgVolume, OthersRN, O2_Saturation_Oxygen1, O2_Saturation_Oxygen2, Saturation, HMFIntact, CranialNerves, SignsOfMeningism, HeartSound, Arrhythmias, AnyOtherAddedSound, AnyOtherFindings, NVB_Right, NVB_Left, Crepitation_Right, Crepitation_Left, Wheeze, Ranchi, AnyOtherSound, AbdomenSoft, Tenderness, Guarding, BowelSound, Distention, FluidThrill, ShiftingDullness, EpigastriaDiscomfort, RetrosternalBurning, Jondus, Pallor, Dehydration, GCSOrientation, ConsciousOrientely, Murmur, TextBoxCns, TextBoxCvs, TextBoxResp, TextBoxGit, TextBoxGpe, eye_response, motor_response, verbal_Response, accumulated_response, FurtherExplanation, PulseRate, BPDischarge, WeightDischarge, HeightDischarge, BMIDischarge, BSRDischarge, Tempdisch, volumedisc, RespRateDesc, Rhythmdischarge, Oxygen2_desc, saturationDis, Oxygen1, otherecdesc, Special_Instruction_Desc, Receiving_Date_Discharge, IdentificationMarks, DateOfDeath, TimeOfDeath, PlaceOfDeath, CauseOfDeath, IssuingOfficerName, DeathCertifiedby1, DeathCertifiedby2, BodyHandedOverTo, FamilyPersonName, CNIC, RelationWithDeceased, CMO_Police, ID, SULR, SULL, SLLR, SLLL, PULR, PULL, PLLR, PLLL, Torso, clinical_Notes, Doctor_Notes, Provisional_Diagnosis_Examination, doc, JVP, Edema, Cyanosis, Discharge_Request, ddlDischarge_Type,
                function (response) {
                    debugger;

                    var btn = btnVal;

                    if (btn == 'btnSave' || btn == 'btnDischargeRequest') {
                        alert('Data Successfully Save');
                        window.location = "InPatientsCase.aspx?ID=" + response;
                        //window.open('../../ReportViewer.aspx?ReportName=InpatientDetail&Title=In Patient Detail Report&In_Patient_ID=' + response);
                        $('#btnSave').val("Update");
                    }
                    else if (btn == 'btnsaveprint') {
                        PrintAdmisionDetails(response);
                        $('#btnSave').val("Update");

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
            debugger;
            var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
            var status = $('#ctl00_MainContent_ddlMO_Doctor_Status').val();

            if (doctor == "0" || doctor == null || doctor == "" || doctor == '') {
                alert("Please Select Doctor Name..")
            }
            else {

                $('#ctl00_MainContent_chkdoctor').prop('checked', true);

                var chkPallor = document.getElementById("ctl00_MainContent_chkdoctor").checked;
                localStorage.DoctorNoteTab = "true";
                debugger;
                $("#tabs").tabs("option", "active", 4);

                $('#ctl00_MainContent_DocStatus').val(status).change();



                setTimeout(function () {
                    $('#ctl00_MainContent_DdlDocName').val(doctor).trigger('change');

                }, 1000);
                $('#ctl00_MainContent_DocStatus').attr("disabled", true);
                $('#ctl00_MainContent_DdlDocName').attr("disabled", true);

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
                var Date = '<%= DateTime.Now%>';
                var rows;
                rows += '<tr> <td><input type="hidden" name ="txtLabResultrpt" value="' + ResultrptVal + '"> ' + ResultrptName
                    + ' </td><td><input type="text" name ="txtResultName" style="width: 159px !important;"> </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td> </tr>';

                $('#tblResultrpt tbody').append(rows);
                $('#ctl00_MainContent_ddlLabResult').val("0");
            }

        }
        function InsertDoctorNote() {

            var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
            if (doctor == "0" || doctor == null) {
                alert("Please Select Doctor Name..")
            }
            else {
                var Date = $('#ctl00_MainContent_txtMo_Date').val();
                var doctorVal = $('#ctl00_MainContent_ddlMo_Doctor_Name').find('option:selected').val();
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
            var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
            if (doctor == "0" || doctor == null) {
                alert("Please Select Doctor Name..")
            }
            else {
                localStorage.IsDischarge = 0;
                localStorage.IsRegular = 1;
                localStorage.IsPRN = 0;
                localStorage.IsStat = 0;
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
            button_text_name = $(row).attr('id');
            $('#chkRegular').prop('checked', true);
            localStorage.IsDischarge = 1;
            var dis = document.getElementById('ctl00_MainContent_cbDicharg_Slip').checked;
            if (dis == true) {


                return false;
            }



            localStorage.IsRegular = 1;
            localStorage.IsPRN = 0;
            localStorage.IsStat = 0;


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
        function tblDischargeNote(PatientID) {
            $('#tblHistoryHeader').html('<h2 class="color">Loading Previous History Please Wait....</h2>')
            PageMethods.LoadDischargeNoteHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var timeStamp = "";
                    var TrnsDateRec = "";

                    if (value.Discharge_On != null) {
                        timeStamp = parseInt(value.Discharge_On.substr(6, 10));
                        timeStamp = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    }
                    if (value.Next_Visit != null) {
                        TrnsDateRec = parseInt(value.Next_Visit.substr(6, 10));
                        TrnsDateRec = moment.unix(TrnsDateRec).format('M/D/YYYY h:m:s A');
                    }
                    if (value.DoctorName == null)
                        value.DoctorName = "";

                    rows += '<tr><td>' + value.DoctorName + '</td> <td> ' + timeStamp + ' </td> <td> ' + value.Prevention_Precaution
                        + ' </td> <td> ' + value.Diagonosis + ' </td> <td> ' + value.Procedure_Operation + ' </td><td> ' + value.Procedure_Detail + ' </td><td> ' + TrnsDateRec + ' </td></tr>';
                });
                $('#tblDischargeNote tbody tr').remove();
                $('#tblDischargeNote tbody').html(rows);
                $('#tblHistoryHeader').html('<h2 class="color" >Previous History</h2>')
            }, function (e) { });
        }

        function LoadVitalParametersHistory(PatientID) {

            if (PatientID != "(New)") {
                PageMethods.LoadVitalParametersHistory(PatientID, function (res) {

                    var Data = JSON.parse(res);
                    var rows = '';
                    var gcs = "";
                    $.each(Data, function (key, value) {
                        ;
                        if (value.RateBeats == "" && value.Emergency_Rhythm == null && value.Emergency_Volume == null && (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.BP_mm_Hg == "___/___" && value.O2_Saturation == "" && value.O2_Saturation_Oxygen1 == "" && value.O2_Saturation_Oxygen2 == "" && (value.RN_Special_Instruction == "<li></li>" || value.RN_Special_Instruction == "") && (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.Temp_C == "") {

                        }
                        else {
                            if (value.GCS == null) {

                                GCS = "";
                            }
                            else {
                                gcs = value.GCS;
                            }
                            if (value.Emergency_Rhythm == null) value.Emergency_Rhythm = "";
                            if (value.Emergency_Volume == null) value.Emergency_Volume = "";

                            var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));
                            var retdateRec = moment.unix(TrnsDateRec).format('M/D/YYYY h:m:s A');
                            rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.Temp_C
                                + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Emergency_Rhythm + ' </td><td> ' + value.Emergency_Volume + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td> ' + value.OthersRecieveNote + ' </td> <td> ' + value.RespirationRate + ' </td><td> ' + value.RN_Special_Instruction + ' </td><td> ' + value.O2_Saturation + ' </td><td>' + value.O2_Saturation_Oxygen1 + '</td><td>' + value.O2_Saturation_Oxygen2 + '</td><td>' + value.Blood_Suger + '</td><td>' + value.BMI + '</td><td>' + value.Weight_Kg + '</td><td>' + value.Height_cm + '</td><td>' + value.User_Name + '</td></tr>';
                        }
                    });

                    $('#tblVitalParametersHistory tbody tr').remove();
                    $('#tblVitalParametersHistory tbody').html(rows);

                    $('#tblHistoryHeader').html('<h2 class="color">Previous History</h2>');

                    $("#ctl00_MainContent_txtRateBeats").val("");
                    $("#ctl00_MainContent_ddlRhythm").val("");
                    $("#ctl00_MainContent_ddlVolume").val("");
                    $("#ctl00_MainContent_txtOthersRcvNote").val("");


                    $("#ctl00_MainContent_txtTemp").val("");
                    $("#ctl00_MainContent_txtRespiration").val("");
                    $("#ctl00_MainContent_txtSaturation").val("");
                    $("#ctl00_MainContent_txtRN_Special_Instruction").val("");
                    $("#ctl00_MainContent_txtSaturation_Oxygen1").val("");
                    $("#ctl00_MainContent_txtSaturation_Oxygen2").val("");
                }, function (e) { });
            }
        }
        function calculateBMI() {
            var height_in_cm = parseFloat($('#ctl00_MainContent_txtHeight').val());
            var weight_kg = parseFloat($('#ctl00_MainContent_txtWeight').val());


            if (isNaN(height_in_cm) || isNaN(weight_kg)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter valid height and weight.',
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

            var height_m = height_in_cm / 100;
            var calcBMI = weight_kg / (height_m * height_m);

            $('#ctl00_MainContent_txtBMI').val(calcBMI.toFixed(2));
        }
        function calculateBMIDisharge() {
            var height_in_cm = parseFloat($('#ctl00_MainContent_txtHeightDischarge').val());
            var weight_kg = parseFloat($('#ctl00_MainContent_txtWeightDischarge').val());


            if (isNaN(height_in_cm) || isNaN(weight_kg)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter valid height and weight.',
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

            var height_m = height_in_cm / 100;
            var calcBMI = weight_kg / (height_m * height_m);

            $('#ctl00_MainContent_txtBMIDischarge').val(calcBMI.toFixed(2));
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
                $.each(WardBeds, function (key, value) {
                    if (value.PatientNo == 0) {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td> <a href="#" onclick="SelectBed(' + value.WardID + ',' + value.BedNo + ')" style="color:Green"> ' + value.BedNo + ' </a> </td></tr>';
                    }
                    else {
                        rows += '<tr> <td> ' + value.PatientNo + ' </td><td ><font color="red"> ' + value.BedNo + '</font></td></tr>';
                    }
                });
                $('#tblWards tbody tr').remove();
                $('#tblWards tbody').html(rows);
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

        function LoadMedicationHistory(PatientID) {
            debugger;
            if (PatientID != '(New)') {
                $('#HeaderHistoryMedication').html('<h2 class="color">Loading Previous History Please Wait....</h2>')
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    debugger;
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var type = '';

                        if (value.Regular == true) {
                            type = "REGULAR";
                        }

                        if (value.STAT == true) {
                            type = "STAT";
                        }

                        if (value.PRN == true) {
                            type = "PRN";
                        }

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr> <td> ' + newdate + ' </td><td>' + value.Status + '</td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td></tr>';

                        if (value.Medicine_Name.length > 0)
                            $('#dvHistoryMedication').show();
                        else
                            $('#dvHistoryMedication').hide();
                    });
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                    $('#HeaderHistoryMedication').html('<h2 class="color">Previous History</h2>');
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

        function editMedicine(AnchorTag) {

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
            $('#txtMedicineName').val($($(row).find('td')[1]).text());
            $('#txtDosage').val($($(row).find('td')[2]).text());
            $('#txtRecomended_Dosage').val($($(row).find('td')[3]).text());


            $('#Routes').find('option:contains(' + $(row).find('td')[4].innerText + ')')[0].selected = true;

            $('#txtInjection').val($($(row).find('td')[5]).text());
            $('#AttendingParamedicalStaff').val($($(row).find('td')[6]).text());
            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
        }

        function editMedicine(AnchorTag) {

            var table_name = $(AnchorTag).parents('table').attr('id');
            if (table_name == "tblDischargeMedication") {

                button_text_name = "btnDischarge";
                localStorage.IsDischarge = 1;


            }
            else if (table_name == "tblMedicinesList") {
                localStorage.IsDischarge = 0;
                button_text_name = "btnAddMedicine";


            }
            else if (table_name == "tblMedicinesListRegular") {
                button_text_name = "btnRegularMedicine";
                localStorage.IsDischarge = 0;
                localStorage.IsRegular = 1;
                localStorage.IsPRN = 0;
                localStorage.IsStat = 0;
                $('#RiskMed').show();
                $('#StopMed').show();
                $('#trduration').show();
                $('#trIns').hide();

            }
            else if (table_name == "tblMedicinesListSTAT") {
                localStorage.IsDischarge = 0;
                localStorage.IsPRN = 0;
                localStorage.IsStat = 1;
                localStorage.IsRegular = 0;
                button_text_name = "btnSTATMedicine";
                $('#RiskMed').hide();
                $('#StopMed').hide();
                $('#trduration').hide();
                $('#trIns').hide();
            }
            else if (table_name == "tblMedicinesListPRN") {
                localStorage.IsDischarge = 0;
                localStorage.IsStat = 0;
                localStorage.IsRegular = 0;
                localStorage.IsPRN = 1;
                button_text_name = "btnPRNMedicine";
                $('#RiskMed').hide();
                $('#StopMed').hide();
                $('#trduration').hide();
            }
            $('#MedicationModel').modal({
                backdrop: 'static'
            });
            setTimeout(function () {
                debugger;
                $('#txtMedicineName').val('');
                $('#txtDosage').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtOral').val('');
                $('#txtInjection').val('');
                $('#btnSaveMedicine').val('Update');
                var row = $(AnchorTag).parents('tr')[0];
                $('#txtMedicineName').val($($(row).find('td')[1]).text());
                var Medicine_Id = $($(row).find('td')[1]).text();
                var dosage_qty = $($(row).find('td')[2]).text().trim();
                var dosage_form = $($(row).find('td')[3]).text().trim();
                var frequency = $($(row).find('td')[5]).text().trim();
                var routes = $($(row).find('td')[6]).text().trim();
                var duration = $($(row).find('td')[4]).text().trim();
                var special_instruction = $($(row).find('td')[5]).text().trim();
                var other_instruction = $($(row).find('td')[8]).text().trim();
                if (localStorage.IsRegular == 1) {
                    special_instruction = $($(row).find('td')[10]).text().trim();
                    other_instruction = $($(row).find('td')[9]).text().trim();
                    var Stop_Date = $($(row).find('td')[7]).text().split(' ')[0];
                    var Stop_Time = $($(row).find('td')[7]).text().split(' ')[1];
                    frequency = $($(row).find('td')[4]).text().trim();
                    duration = $($(row).find('td')[5]).text().trim();
                    $('#txtStopD').val(Stop_Date);
                    $('#txtStopT').val(Stop_Time);
                    debugger;
                    var high_risk = $($(row).find('td')[8]).text().trim();
                    if (high_risk == "No") {
                        $('#rdRiskN').prop('checked', true);
                    }
                    else { $('#rdRiskY').prop('checked', true); }
                }
                if (localStorage.IsPRN == 1) {
                    other_instruction = $($(row).find('td')[8]).text().trim();
                    special_instruction = $($(row).find('td')[9]).text().trim();
                    frequency = $($(row).find('td')[4]).text().trim();
                    duration = $($(row).find('td')[5]).text().trim();
                    var Max_Prn_Dose = $($(row).find('td')[7]).text().trim();
                    $('#txtPrnDose').val(Max_Prn_Dose);
                }
                if (localStorage.IsStat == 1) {
                    frequency = $($(row).find('td')[4]).text().trim();
                    duration = $($(row).find('td')[5]).text().trim();
                    other_instruction = $($(row).find('td')[7]).text().trim();
                    special_instruction = $($(row).find('td')[8]).text().trim();
                }

                debugger;

                var s = medicine.filter(x => x.Description == $(row).find('td')[1].innerText);
                $('#txtPharmacyItem').val(s[0].Item_Code).trigger('change');

                $("#ddlDosage_Qty").val(dosage_qty);

                $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
                $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;
                $('#ddlOther_Instruction').find('option:contains(' + other_instruction + ')')[0].selected = true;
                $('#txtMedicineName').val($($(row).find('td')[1]).text());
                $('#txtInjection').val(duration);
                $('#AttendingParamedicalStaff').val(special_instruction);
                $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
                $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            }, 3000);

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
            debugger;
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadDischageMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> ' + value.Regular + ' </td><td> ' + value.STAT + ' </td><td> ' + value.PRN + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblDischargeMedication tbody').html(rows);
                });
            }
        }

        function LoadInfusion() {
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.Load_Infusion($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);

                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var timeStamp = parseInt(value.Create_Time.substr(6, 10));

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        var s1 = parseInt(value.Start_Date_time.substr(6, 10));
                        var Start_Date = moment.unix(s1).format('MM/DD/YYYY hh:mm:ss A');
                        if (value.Infusion_Stop_time == null) {
                            var Stop_Date = "";
                        }
                        else {
                            var s2 = parseInt(value.Infusion_Stop_time.substr(6, 10));
                            var Stop_Date = moment.unix(s2).format('MM/DD/YYYY hh:mm:ss A');

                        }

                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Infusion_Type + '</td><td> ' + Start_Date + '</td> <td> ' + value.Infusion_Fluid + ' </td> <td> ' + value.Infusion_Volume + '</td><td> ' + value.Infusion_Rate + ' </td> <td> ' + value.Infusion_Hours + '</td><td> ' + value.Additive + ' </td> <td> ' + value.Additive_Dose + ' </td><td style="display:none;">' + value.Route + '</td> <td>' + value.Infusion_Side + '</td> <td>' + Stop_Date + '</td> <td>' + value.Username + '</td><td><a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#t_body').append(rows);
                });
            }
        }
        function LoadMedicines() {
            debugger;
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    debugger;
                    var rowmodalAppendload = '';
                    var rowsRegular = '';
                    var rowsPRN = '';
                    var rowsStat = '';
                    var role;
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var Username = '<%= AppConfig.UserName%>';
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        role = value.userrole;

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        var s1 = parseInt(value.Start_Date_Time.substr(6, 10));
                        var Start_Date = moment.unix(s1).format('MM/DD/YYYY hh:mm:ss A');
                        debugger;
                        if (value.Regular == true || value.Regular == "1") {
                            if (value.Stop_Date_Time == null) {
                                Stop_Date = '';
                            }
                            else {
                                var s2 = parseInt(value.Stop_Date_Time.substr(6, 10));
                                var Stop_Date = moment.unix(s2).format('MM/DD/YYYY hh:mm:ss A');
                            }
                            rowsRegular += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td>' + Stop_Date + '</td> <td> ' + value.Other_Instruction + ' </td>' + '<td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td><input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;"></td></tr>';

                        }
                        else if (value.PRN == true) {
                            rowsPRN += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td style="background-color: red;"> ' + value.Max_PRN_Dose + ' </td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td><input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;"></td></tr>';

                        }
                        else if (value.STAT == true) {

                            rowsStat += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> ' + value.Other_Instruction + '</td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td>' + '<td>' + value.Username + '</td><td><input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;"></td></tr>';

                        }

                        rowmodalAppendload += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td>' + value.Other_Instruction + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td> </td></tr>';



                    });
                    setTimeout(function () {

                        $('#tblDischargeMedication tbody').html(rowmodalAppendload);
                        $('#tblMedicinesListRegular tbody').html(rowsRegular);
                        $('#tblMedicinesListSTAT tbody').html(rowsStat);
                        $('#tblMedicinesListPRN tbody').html(rowsPRN);



                    }, 6000)


                    if (role == 'administrator' || role == "administrator") {
                        $('.eddit').show();
                    }
                    else {
                        $('.eddit').show();
                    }

                });
            }
        }

        function LoadDischargeMedicines() {

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadDischargeMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);

                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> ' + value.Regular + ' </td><td> ' + value.STAT + ' </td><td> ' + value.PRN + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblDischargeMedication tbody').html(rows);
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

            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadDoctorNoteDetail($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        var timeStamp = parseInt(value.Doctor_Note_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.DoctorStatus == null)
                            value.DoctorStatus = "";


                        rows += '<tr> <input type="hidden" name ="DoctorNotesID" value="' + value.Doctor_ID + '"> <td> ' + date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Doctor_Status + '"> ' + value.DoctorStatus
                            + ' </td> <td><input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> ' + value.DoctorName
                            + ' </td> <td> ' + value.Progress_Note + ' </td> <td>' + value.Doctor_Instruction + '</td><td><a style="display:none;" href="javascript:void(0)" onclick="deleteInstruction(this)">Delete</a></td> </tr>';

                    });
                    $('#tblDOctorNotes tbody').append(rows);
                });
            }
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
                In_Patient_ID: ($('#ctl00_MainContent_txtIn_Patient_ID').val() != "(New)") ? $('#ctl00_MainContent_txtIn_Patient_ID').val() : "0",
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
            row.remove();

        }

        var ArrLabTestID = [];

        function deleteTest(crow) {
            debugger;
            var row = $(crow).parents('tr')[0];


            var LabTestDet = $(row).find('input[name="LabtestDtID"]').val();
            ArrLabTestID.push({ 'LabTestDet': LabTestDet });

            row.remove();


        }
        function Delete_Symtom(row) {
            $($(row).parents('tr')[0]).remove();
        }

        function LoadTestsHistory(PatientID) {
            if (PatientID != '(New)') {
                $('#tblHistoryTests tbody tr').remove();
                PageMethods.GetTestListForHistory(PatientID, function (res) {
                    debugger;
                    var test = JSON.parse(res);
                    var rows = '';
                    var Sample = 'No';
                    $.each(test, function (key, value) {
                        debugger;
                        var Result = 'Pending';
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Is_Result == true) {
                            Result = "Resulted";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == false) {
                            Result = "Waiting";
                            Sample = "No";
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td>' + value.Status + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> </tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="' + value.DataValue_Name + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> </tr>';
                        }
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
        var docfromNotes;
        function LoadTestList() {
            debugger;

            var patientID = $('#<%= hdfPatient_ID.ClientID%>').val();
            docfromNotes = $('#tblDOctorNotes').find('tbody').find('td input[name=txtDoctorName]').val();

            if (patientID != "(New)") {
                PageMethods.GetTestList(patientID, function (res) {

                    var test = JSON.parse(res);

                    var rows = '';
                    $.each(test, function (key, value) {
                        debugger;
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



                        if (value.Is_Result == null || value.Is_Result == false) {
                            value.Is_Result = ""

                        }
                        if (value.Recieved_ID == null) {
                            value.Recieved_ID = ""
                        }
                        if (value.IsBilled == null || value.IsBilled == false) {
                            value.IsBilled = "";
                            Result = "Bill Pending";
                        }
                        if (value.IsBilled == true) {

                            Result = "Sample Pending";
                        }

                        var isample = value.IsSample;
                        if (isample != "0") {
                            Sample = "Yes";
                            Result = "Acknowledgement Pending";
                        }
                        if (value.IsAknowledgment != "0") {
                            Sample = "Yes";
                            Result = "Result Pending";

                        }
                        if (value.isResult == "True") {
                            Result = "Approval Pending";
                            Sample = "Yes";
                        }
                        if (value.isResult == "True" && value.Is_Approved == "True") {
                            Result = "Approved";
                            Sample = "Yes";
                        }


                        if (value.DoctorName == "" || value.DoctorName == null || value.DoctorName == "null" || value.DoctorName == 'null') {
                            value.DoctorName = "-";
                        }

                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                debugger;
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="LabtestDtID" value="' + value.Lab_Test_Detail_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtIs_Result" value="' + value.Is_Result + '"/><input type="hidden" name="txtIsBIllied" value="' + value.IsBilled + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="display:none;" href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="LabtestDtID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtIs_Result" value="' + value.Is_Result + '"/><input type="hidden" name="txtIsBIllied" value="' + value.IsBilled + '"/><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="display:none; href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                                else {
                                    debugger;
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="LabtestDtID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtIs_Result" value="' + value.Is_Result + '"/><input type="hidden" name="txtIsBIllied" value="' + value.IsBilled + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="display:none; href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                            }
                        }
                        else {
                            debugger;
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="LabtestDtID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtIs_Result" value="' + value.Is_Result + '"/><input type="hidden" name="txtIsBIllied" value="' + value.IsBilled + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="display:none; href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        }
                        $('.tests-table').append(row);
                    });

                });
            }
        }



        function SaveDischargeMedicines() {
            debugger;
            var Dtable = $('#tblDischargeMedication');
            var MedicinesList = [];
            Dtable.find('tbody tr').each(function (key, value) {

                debugger
                MedicinesList.push({

                    'Medicine_Date': $($(value).find('td')[0]).text().trim(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[13]).text(), 'Regular': $($(value).find('td')[9]).text(), 'STAT': $($(value).find('td')[10]).text(), 'PRN': $($(value).find('td')[11]).text(),
                });
            });

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();

            var MedicineDetails = { PatientID: InPatID == '(New)' ? 0 : InPatID, MedicineList: MedicinesList }

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

            var OutPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var OrthoDetails = { Pat: PatID, PatientID: OutPatID, OrthoList: OrthoList }

            PageMethods.SaveOrthoDetail(btnsave, JSON.stringify(OrthoDetails), function (response) { SaveServices_Procedures(); });

        }

        function SaveServices_Procedures() {
            debugger;
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

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();

            var ServiceDetails = { PatId: patID, InPatId: InPatID, ServicesList: ProcedureList };

            PageMethods.SaveServicesDetail(btnSave, JSON.stringify(ServiceDetails), function (response) {

                SaveInfusion();
            });

        }

        function LoadServices_Procedures(PatientId) {

            debugger;
            if ($("#<%= txtIn_Patient_ID.ClientID%>").val() !== "(New)") {
                $('#ServicesHistoryHeader').html('<h2>Loading Previous History Please Wait...</h2>');
                PageMethods.LoadServicesDetail(PatientId, $('#<%= txtIn_Patient_ID.ClientID%>').val(), function (response) {

                    debugger;
                    var Services = JSON.parse(response);
                    var rows = "";
                    var rowsHistory = "";

                    $.each(Services, function (key, value) {

                        var timeStamp = parseInt(value.ServiceDate.substr(6, 10));

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");

                        var entryDate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td><td style="text-align: left;"> <a style="display:none;" href="#" onclick="DeleteRow(this)">Delete</a> </td> </tr>';

                        rowsHistory += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td></tr>';

                    });

                    $('#tblServices tbody').append(rows);
                    $('#tblServicesHistory tbody').append(rowsHistory);
                    $("#ServicesHistoryHeader").html("<h2 style= 'color:white !important;text-align:center;'>Previous History</h2>");

                });

            }

        }

        function SaveMedicines() {
            debugger;
            var table = $('#tblMedicinesListRegular');
            var tablePRN = $('#tblMedicinesListPRN');
            var tableStat = $('#tblMedicinesListSTAT');
            var MedicinesList = [];
            var MedicinesListPRN = [];
            var MedicinesListSTAT = [];
            table.find('tbody tr').each(function (key, value) {
                debugger;
                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[4]).text(),
                    'Oral': $($(value).find('td')[6]).text(),
                    'Injection': $($(value).find('td')[5]).text(),
                    'AttendingParamedical_Staff': $($(value).find('td')[9]).text(),
                    'Dosage_From': $($(value).find('td')[3]).text(),
                    'Dosage_Qty': $($(value).find('td')[2]).text(),
                    'Other_Instruction': $($(value).find('td')[8]).text(),
                    'Special_Instruction': $($(value).find('td')[9]).text(),
                    'ItemCode': $($(value).find('td')[12]).text(),
                    'Start_Date_Time': $($(value).find('td')[0]).text(),
                    'Stop_Date_Time': $($(value).find('td')[7]).text(),
                    //'High_Risk': $($(value).find('td')[8]).text(),
                    'User': $($(value).find('td')[10]).text(),
                    'Max_PRN': "",
                    "Regular": true,
                    "STAT": false,
                    "PRN": false,
                });
            });
            tableStat.find('tbody tr').each(function (key, value) {
                debugger;
                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[4]).text(),
                    'Oral': $($(value).find('td')[6]).text(),
                    'Injection': $($(value).find('td')[5]).text(),
                    'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[3]).text(),
                    'Dosage_Qty': $($(value).find('td')[2]).text(),
                    'Other_Instruction': $($(value).find('td')[7]).text(),
                    'Special_Instruction': $($(value).find('td')[8]).text(),
                    'ItemCode': $($(value).find('td')[11]).text(),
                    'Start_Date_Time': $($(value).find('td')[0]).text(),
                    'Stop_Date_Time': "",
                    'High_Risk': "",
                    'User': $($(value).find('td')[9]).text(),
                    'Max_PRN': "",
                    "Regular": false,
                    "STAT": true,
                    "PRN": false,
                });
            });
            tablePRN.find('tbody tr').each(function (key, value) {
                debugger;
                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[4]).text(),
                    'Oral': $($(value).find('td')[6]).text(),
                    'Injection': $($(value).find('td')[5]).text(),
                    'AttendingParamedical_Staff': $($(value).find('td')[9]).text(),
                    'Dosage_From': $($(value).find('td')[3]).text(),
                    'Dosage_Qty': $($(value).find('td')[2]).text(),
                    'Other_Instruction': $($(value).find('td')[8]).text(),
                    'Special_Instruction': $($(value).find('td')[9]).text(),
                    'ItemCode': $($(value).find('td')[12]).text(),
                    'Start_Date_Time': $($(value).find('td')[0]).text(),
                    'Stop_Date_Time': "",
                    'High_Risk': "",
                    'User': $($(value).find('td')[10]).text(),
                    'Max_PRN': $($(value).find('td')[7]).text(),
                    "Regular": false,
                    "STAT": false,
                    "PRN": true,
                });
            });
            debugger;
            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            var MedicineDetails = { PatientID: InPatID == '(New)' ? 0 : InPatID, MedicineList: MedicinesList }

            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { SaveDischargeMedicines(); });
        }

        function saveTests() {
            debugger;
            var table = $('.tests-table tbody');
            var test_list = [];
            table.find('tr').each(function (key, value) {
                debugger;
                test_list.push({ 'Date': $(value).find('td input[name=testDate]').val(), 'TestID': $(value).find('td input[name=testID]').val(), 'Catagory_ID': $(value).find('td input[name=txtGroupCategory]').val(), 'Dept_ID': $(value).find('td input[name=txtDeptID]').val(), 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'Doctor': $(value).find('td input[name=Docid]').val(), 'Area_Of_Interest': $(value).find('td input[name=txtArea_Of_Interest]').val(), 'Special_Tests': $(value).find('td input[name=txtSpecial_Test]').val(), 'RecievedID': $(value).find('td input[name=txtRecievedID]').val(), 'Is_Result': $(value).find('td input[name=txtIs_Result]').val(), 'IsBIllied': $(value).find('td input[name=txtIsBIllied]').val() });
            });
            var patientID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (patientID == '(New)' || patientID == '')
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list };
            debugger;
            PageMethods.SaveTest(JSON.stringify(labTest), function (res) {
                SaveMedicines();
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

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;
            var ResulttrptDetail = { Pat: PatID, InPatientID: InPatID, Resulttrpt: tblResultrpt }

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

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;
            debugger;
            var NoteDetails = { Pat: PatID, InPatientID: InPatID, NoteList: DoctorNoteList }
            localStorage.SelectedTabID = 1;
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

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;
            var IntructionDetails = { Pat: PatID, InPatientID: InPatID, ListIns: InstructionList }

            PageMethods.InsertInstuctionDetail(btnsave, JSON.stringify(IntructionDetails), function (response) {
                SaveEyeList();

            });

        }

        function SaveWard() {
            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (InPatID == '(New)' || InPatID == '')
                InPatID = 0;
            var refer_To = $("#ctl00_MainContent_ddlReferTo").val();
            if (refer_To != "0") {
                var ddlWard_No = $('#ctl00_MainContent_ddlwards').val();

                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var txtBed_No = $('#ctl00_MainContent_txtBedno').val();

                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

                PageMethods.SaveWardInformation(btnsave, PatID, InPatID, ddlWard_No, txtBed_No, txtExpected_Discharge_Date, ddlDoctor, DichargChk, function (response) {
                    saveTests();
                });
            }
            else {

                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();
                var txtBed_No = $('#ctl00_MainContent_txtBed_No').val();
                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

                PageMethods.SaveWardInformation(btnsave, PatID, InPatID, ddlWard_No, txtBed_No, txtExpected_Discharge_Date, ddlDoctor, DichargChk, function (response) {
                    saveTests();
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
                    saveTests();
                });
            }
            else {
                var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
                var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
                var ddlRoom_No = $('#ctl00_MainContent_ddlRoom_No').val();
                var txtRoom_Type = $('#ctl00_MainContent_txtRoom_Type').val();
                var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
                PageMethods.SaveRoomInformation(btnsave, PatID, InPatID, ddlRoom_No, txtRoom_Type, txtExpected_Discharge_Date, ddlDoctor, DichargChk, function (response) {
                    saveTests();
                });


            }
        }

        function CheckExistInOutPatient() {
            debugger;

            var patient_Id = $("#<%= hdfPatient_ID.ClientID%>").val();
            $.ajax({
                type: "POST",
                url: "InPatientsCase.aspx/CheckExistOutPatient",
                data: JSON.stringify({
                    "Patient_ID": patient_Id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data == "Exist") {
                        alert("First Discharge Mr# " + $('#ctl00_MainContent_txtPatient_ID').val() + " from OPD");
                    }
                    else {
                        saveTests();
                    }
                },
                failure: function (response) {
                    alert("Failure");
                }
            });
        }

        function SaveInPatientAllRecord() {
            debugger;
            $('#btnSave').attr('disabled', true);
            $('#loadingimage').show();
            CheckExistInOutPatient();


        }

        function LoadHistory() {

            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            if (dischargechk == true) {
                $('#btnDischargePrint').attr('disabled', false);
            }
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != '(New)') {
                LoadPsychiatryHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPsychiatryHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadVitalParametersHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadVitalParametersHistoryDischarge($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadClinicalSummaryHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadServices_Procedures($("#<%= hdfPatient_ID.ClientID%>").val());
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadTestsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadHistoryTabHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadExaminationTabHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadSymtompsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadENTHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadEyeListHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDermaHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadRoomsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadWardHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDoctorNoteHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                tblDischargeNote($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadOrtho($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPeadsHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPeadsHistory($('#<%= hdfPatient_ID.ClientID%>').val());

            }
        }
        function LoadClinicalSummaryHistory(PatientID) {
            $('#tblHistoryClinicalHeader').html('<h2 class="color">Loading Previous History Please Wait...</h2>');
            PageMethods.LoadClinicalSummaryHistory(PatientID, function (res) {

                var Data = JSON.parse(res);

                var rows = "";
                $.each(Data, function (key, value) {
                    debugger;
                    var TrnsDate = "";
                    var retdate = "";
                    if (value.Date_Time == null || value.Date_Time == "null") {

                    }
                    else {

                        TrnsDate = new Date(parseInt(value.Date_Time.substr(6)));
                        retdate = moment(TrnsDate).format('LLLL');
                    }

                    rows += "<tr><td>" + retdate +
                        "</td><td>" + Data[key].Clinical_Notes +
                        "</td><td>" + Data[key].DoctorName +
                        "</td></tr>";

                });
                $("#tblClinicalHistory tbody tr").remove();
                $("#tblClinicalHistory tbody").html(rows);
                $('#tblHistoryClinicalHeader').html('<h2 class="color">Previous History</h2>');
            }, function (e) { });

        }
        function LoadExaminationTabHistory(PatientID) {

            $('#tblExaminationHistoryHeader').html('<h2 class="color" >Loading Previous History Please Wait...</h2>');

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
                        "</td><td>" + value.GPE_Value +
                        "</td><td>" + value.CNS_Value +
                        "</td><td>" + value.CVS_Value +
                        "</td><td>" + value.RESP_Value +
                        "</td><td>" + value.GIT_Value +
                        "</td><td>" + value.TruckTorso +
                        "</td><td>" + value.Provisional_Diagnosis_Examination +
                        "</td></tr>";
                });

                $("#tblExaminationHistory tbody tr").remove();
                $("#tblExaminationHistory tbody").html(rows);
                $('#tblExaminationHistoryHeader').html('<h2 class="color" >Previous History</h2>');

            }, function (e) { });

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
            }, function (e) { alert(e.getmessage()); });
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
            }, function (e) { alert(e.getmessage()); });
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
            window.location = "InPatientView.aspx";
        }

        function LoadHistoryTabHistory(PatientID) {

            $('#tblHistoryTabHistoryHeader').html('<h2 class="color">Loading Previous History Please Wait....</h2>')
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
                            + ' </td> <td> ' + value.HistoryOfPastIllness + ' </td> <td> ' + value.HistoryOfFamily + ' </td><td> ' + value.SocioEconomicHistory + ' </td> <td> ' + value.Birth_History + ' </td> <td> ' + value.Drug_History + ' </td> <td> ' + value.Personal_History + ' </td> <td> ' + value.ObstetricHistory + ' </td><td> ' + value.AllergiesHistory + ' </td><td> ' + value.TreatmentHistory + ' </td><td> ' + value.Vaccination_History + ' </td><td> ' + value.Other_History + ' </td> </tr>';

                    });
                    $('#tblHistoryTabHistory tbody tr').remove();
                    $('#tblHistoryTabHistory tbody').html(rows);
                    $('#tblHistoryTabHistoryHeader').html('<h2 class="color">Previous History</h2>')
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

            }, function (e) { alert(e.getmessage()); });
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


            }, function (e) { alert(e.getmessage()); });
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
            debugger;

            if (PatientID != "(New)") {

                PageMethods.LoadDoctorNoteForHistory(PatientID, function (res) {
                    debugger;
                    var Rooms = JSON.parse(res);
                    var rows = '';
                    $.each(Rooms, function (key, value) {
                        debugger;
                        var timeStamp = parseInt(value.Doctor_Note_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var docstatus;
                        if (value.DoctorStatus == null) {
                            value.DoctorStatus = "";
                            docstatus = value.Doctor_Status;
                        } else {
                            docstatus = value.DoctorStatus;
                        }


                        rows += '<tr> <td> ' + date + ' </td> <td>' + docstatus
                            + ' </td> <td> ' + value.DoctorName
                            + ' </td> <td> ' + value.Progress_Note + ' </td> <td>' + value.Doctor_Instruction + '</td> </tr>';
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
            $('#txtNewSymptom').val("");
            $('#btnaddsym').hide();
        }
        function LoadWardHistory(PatientID) {

            if (PatientID != '(New)') {

                PageMethods.LoadWardForHistory(PatientID, function (res) {
                    var Wards = JSON.parse(res);
                    var rows = '';
                    $.each(Wards, function (key, value) {
                        var timeStampEx;
                        var timeStamp = parseInt(value.Admission_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        if (value.To_TimeDate != null) {
                            if (value.Discharge_On != null) {
                                timeStampEx = parseInt(value.Discharge_On.substr(6, 10));
                                timeStampEx = moment.unix(timeStampEx).format('M/D/YYYY h:m:s A');
                            }
                            else {
                                timeStampEx = '';
                            }
                        }

                        if (value.To_TimeDate == null)
                            timeStampEx = "";

                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.DepartmentName + ' </td> <td> ' + value.DoctorName + ' </td><td> ' + value.Health_Complaints + ' </td> <td> ' + timeStampEx + ' </                            td><td> ' + value.Ward_No + ' </td> <td> ' + value.Bed_No_Assigned + ' </td> </tr>';

                    }
                    );
                    $('#tblWardHistory tbody tr').remove();
                    $('#tblWardHistory tbody').html(rows);

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
                }
                else {
                    checkRepeateRecord = true;
                    window.location = "InPatientsCase.aspx?ID=" + data;
                }
            }, function (error) { })
        }
        function checkRooms() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeatRooms(patID, function (data) {

                $.each(JSON.parse(data), function (key, value) {

                    window.location = "InPatientsCase.aspx?ID=" + value.In_Patient_ID;
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
        function InfusionVOL() {

            var infVol = '';

            PageMethods.InfusionVOL(function (Tests) {

                optionsInf = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optionsInf += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_InsVol').html(optionsInf);

            });
        }


        function AdditiveDose() {

            var optionsAdd = '';

            PageMethods.AdditiveDose(function (Tests) {

                optadd = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optadd += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_addtiveDose').html(optadd);

            });
        }


        function InfusionRate() {

            var optionsRate = '';

            PageMethods.InfusionRate(function (Tests) {

                optRate = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optRate += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });


            });
        }


        function Routes() {

            var optionsRate = '';

            PageMethods.Routes(function (Tests) {

                optRoute = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optRoute += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_route').html(optRoute);

            });
        }

        function Sides() {

            var optSides = '';

            PageMethods.Sides(function (Tests) {

                optSides = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optSides += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlSides').html(optSides);

            });
        }
        function InfussionPharmacy() {

            var optionsRate = '';

            PageMethods.InfussionPharmacy(function (Tests) {

                opt_Pharm = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    opt_Pharm += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                });
                $('#ddl_InsFluid').html(opt_Pharm);

            });
        }



        function additive() {


            PageMethods.additive(function (Tests) {

                opt_additive = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    opt_additive += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                });
                $('#ddl_addtive').html(opt_additive);
                $('#ddl_addtive').select2();

            });
        }


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

        function AddLabTest(maindpt) {

            var test = $('#ddlTestList').find('option:selected').text();
            PageMethods.GetLabTestDDLDetails(test, maindpt, function (res) {

                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = '-';
                    var test = $('#ddlTestList').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
                    var dateValue = '<%= DateTime.Now%>';

                    var TestMainDepartmentName;
                    var row;
                    var doctorVal;
                    var doctor;

                    doctorVal = $('#ctl00_MainContent_DdlDocName').find('option:selected').val();
                    doctor = $('#ctl00_MainContent_DdlDocName').find('option:selected').text();
                    if (doctor == "" || doctor == undefined || doctor == null || doctor == "NULL" || doctor == "null") {

                    }


                    if (doctorVal == 0 || doctorVal == undefined || doctorVal == "" || doctorVal == '') {
                        alert("Select Doctor...");
                        return false;


                    }

                    if (value.Test_ID != 0) {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIsBIllied"/> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td>  <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    var test_array = $('.tests-table').find('input[name=testID][value="' + value.TestID + '"]');
                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);
                        $('#ctl00_MainContent_txtAreaOfInterest').val('');

                    }
                });
            }, function (err) { });
        }

        function AddRadialogyTest() {
            debugger;
            $("#btnXray").removeClass("btn-danger").addClass("btn-info");
            $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
            $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
            var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
            var ddl_XRayLF_Name = $('#ddlXRayLF option:selected').text();
            var ddlXRayLF_Namevalue = ',' + ddl_XRayLF_Name;

            var Result = 'Result';
            var test = $('#ddlTestList').val();
            var date = '<%= DateTime.Now%>';
            var IsRotationShow = $('#divRotation').is(":visible");
            var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
            var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";

            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetTestMainDepartmentDetails",
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
                    doctorVal = $('#tblDOctorNotes').find('tbody').find('td input[name=txtDoctorValue]').val();


                    doctor = $('#tblDOctorNotes').find('tbody').find('td input[name=txtDoctorName]').val();

                    if (doctor == "" || doctor == undefined || doctor == null || doctor == "NULL" || doctor == "null") {
                        doctor = "-";
                    }


                    if (doctorVal == 0 || doctorVal == undefined) {
                        doctorVal = "";

                    }

                    var areaOfIntrest = $('#ctl00_MainContent_txtAreaOfInterest').val();

                    var SpecialTest = "";
                    var row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '">' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Namevalue + '</td><td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtSpecial_Test" value="' + SpecialTest + '"/><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfIntrest + '"/> ' + areaOfIntrest + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                    var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');
                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);
                        $('#ctl00_MainContent_txtAreaOfInterest').val('');

                    }
                },
                failure: function (response) {
                    alert(response.d);
                }

            });

        }
        function AddProcedureTest() {
            var Result = 'Result';
            var Procedure = $('#ddlTestList').val();
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
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

            var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td><td><input type="hidden" name="testID" value="' + Procedure + '" /> <input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"> ' + $('#ddlTestList').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';


            var test_array = $('.tests-table').find('input[name=testID][value="' + Procedure + '"]');
            if (test_array.length > 0) {
                alert('This Procedure already added!');
            } else {
                $('.tests-table').append(row);
            }
        }

        function AddAllTest() {

            var maindpt = $('#ddlMainTestDepartment').val();
            var CheckTest = $('#ddlTestList').val();

            if (CheckTest != 0 || CheckTest != null) {
                if (maindpt == "001") {
                    AddLabTest(maindpt);

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
        var medicine = '';
        function FillPharmacyItem() {
            PageMethods.FillPharmacyItemDropDown(function (Medicine) {
                medicine = JSON.parse(Medicine);

                var options = '<option value="' + 0 + '"> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.Item_Code + '"> ' + value.Description + ' </option>';
                });
                $('#txtPharmacyItem').html(options);
                $('#txtPharmacyItem').select2();
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
        function event() {



        }
        function GetQS() {

            var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            if (url[0].includes('=')) {
                var QS = url[0].split('=')[1];
                $('#queryString').val(QS);

            }
        }
        function toHtml(element) {

            var separator = /(\r\n|\n|\r)/gm;
            if ($(element).val() == 'comma')
                separator = /,/gm;
            else if ($(element).val() == 'semicolon')
                separator = /;/gm;
            else if ($(element).val() == '• ') {
                separator = /;/gm;
            }
            var ss = '<li>' + $(element).val().trim().replace(separator, "</li>\n\t<li>") + '</li>';
            var data = ss.replaceAll('•', '');

            return data;

        }
        var button_text_name = "";
        function SaveInfusion() {
            debugger;

            var table = $('#table_res');
            var Infusion_List = [];
            table.find('tbody tr').each(function (key, value) {


                Infusion_List.push({
                    'Infusion_Fluid': $($(value).find('td')[3]).text(), 'Additive': $($(value).find('td')[7]).text(), 'Infusion_Volume': $($(value).find('td')[4]).text(), 'Additive_Dose': $($(value).find('td')[8]).text(), 'Infusion_Rate': $($(value).find('td')[5]).text(), 'Route': $($(value).find('td')[9]).text(), 'Duration': $($(value).find('td')[6]).text(), 'Sides': $($(value).find('td')[10]).text(), "stop_Date": $($(value).find('td')[11]).text(), "Start_Date": $($(value).find('td')[2]).text(), "Infusion_Type": $($(value).find('td')[1]).text(), 'Created_Date': $($(value).find('td')[0]).text()

                });
            });
            debugger;
            var Patien_ID = $('#<%= txtPatient_ID.ClientID%>').val();
            var InPatien_ID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();

            var Infusion_Details = { PatientID: Patien_ID, InPatientID: InPatien_ID, InfusionDetails: Infusion_List }
            PageMethods.SaveInfusion(JSON.stringify(Infusion_Details), function (res) {


                saveAllRecord();
            });
        }

        function AddInfusion() {
            debugger;
            var arr = [];

            $('#tblAdditive tbody tr:gt(0)').each(function () {
                debugger;
                var text = $(this).find('td:eq(0)').text();
                arr.push(text);
            });
            var arr_join = arr.join();
            debugger;
            var ddl_addtive = $('#ddl_addtive :selected').text();
            var ddl_InsFluid = $('#ddl_InsFluid :selected').text();
            var ddl_InsVol = $('#ddl_InsVol :selected').text();
            var ddl_addtiveDose = $('#ddl_addtiveDose :selected').text();
            var ddl_InsRate = $('#ddl_InsRate').val();
            var ddl_route = $('#ddl_route :selected').text();

            if (ddl_addtive == "Please Select") {
                ddl_addtive = '';
            }

            if (ddl_InsFluid == "Please Select") {
                ddl_InsFluid = '';
            }
            if (ddl_InsVol == "Please Select") {
                ddl_InsVol = '';
            }
            if (ddl_addtiveDose == "Please Select") {
                ddl_addtiveDose = '';
            }
            if (ddl_InsRate == "Please Select") {
                ddl_InsRate = '';
            }
            if (ddl_route == "Please Select") {
                ddl_route = '';
            }
            var infusion_duration = $('#txtDurationInfusion').val();
            var duration = $('#txtDurationInfusion').val();
            var stop_time = $('#txtStopDateTime').val();
            var sides = $('#ddlSides :selected').text();
            if (sides == "Please Select") {
                sides = '';
            }
            var start_Date = $('#txtStartDate').val();
            var start_Time = $('#txtStartTime').val();
            var complete = start_Date + ' ' + start_Time;
            var stop_Date = $('#txtStopDateTime').val();
            var stop_Time = $('#txtStopTime').val();
            var completeStop = stop_Date + ' ' + stop_Time;

            var datetime = '<%= DateTime.Now%>';
            var username ='<%= AppConfig.UserName%>';

            var Inf_type = $('#chkIntermittent').is(':checked');
            if (Inf_type == true) {
                Inf_type = "Intermittent";
            }

            {
                Inf_type = "Continous";
            }
            if ($('#chkIntermittent').is(':checked') == false && $('#chkContinous').is(':checked') == false) {
                Inf_type = "";
            }

            if ($('#btnAddinfs').val() == 'Add') {
                var row = '<tr> <td> ' + datetime + ' </td><td> ' + Inf_type + '</td><td> ' + complete + '</td> <td> ' + ddl_InsFluid + ' </td> <td> ' + ddl_InsVol + '</td><td> ' + ddl_InsRate + ' </td> <td> ' + duration + '</td><td> ' + arr_join + ' </td> <td> ' + ddl_addtiveDose + ' </td><td style="display:none;">' + ddl_route + '</td> <td>' + sides + '</td> <td>' + completeStop + '</td> <td>' + username + '</td><td><a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';

                $('#t_body').append(row);


                $('#ddl_InsFluid').val(0);
                $('#ddl_addtive').val(0).trigger('change');
                $('#ddl_InsVol').val(0);
                $('#ddl_addtiveDose').val(0);
                $('#ddl_InsRate').val('');
                $('#ddl_route').val(0);
                $('#txtDurationInfusion').val('');
                $('#txtStopDateTime').val('');
                $('#txtStopTime').val('');
                $('#ddlSides').val(0);

            }
            else {

            }



        }
        function diff_minutes(dt2, dt1) {

            var diff = (dt2.getTime() - dt1.getTime()) / 1000;
            diff /= 60;
            return Math.abs(Math.round(diff));

        }
        function Delete(anchor) {
            $(anchor).closest('tr').remove();
        }
        function parseDate(str) {
            debugger;
            var mdy = str.split('/');
            return new Date(mdy[2], mdy[0] - 1, mdy[1]);
        }

        function datediff(first, second) {

            return Math.round((second - first) / (1000 * 60 * 60 * 24));
        }
        function CalDate(date1, date2) {
            debugger;
            var diff = Math.floor(date1.getTime() - date2.getTime());
            var secs = Math.floor(diff / 1000);
            var mins = Math.floor(secs / 60);
            var hours = Math.floor(mins / 60);
            var days = Math.floor(hours / 24);
            var months = Math.floor(days / 31);
            var years = Math.floor(months / 12);
            months = Math.floor(months % 12);
            days = Math.floor(days % 31);
            hours = Math.floor(hours % 24);
            mins = Math.floor(mins % 60);
            secs = Math.floor(secs % 60);
            var message = "";
            if (days <= 0) {
                message += Math.abs(mins) - 1 + " min ";
                message += Math.abs(hours) - 1 + " hours ";
                message += Math.abs(days) + " days ";

            }
            else {

                message += Math.abs(mins) + " min ";
                message += Math.abs(hours) + " hours ";

            }
            return message
        }
        var TimePicker = '';
        $(document).ready(function () {



            $('#tblDischargeMedication').show();
            $('#btnsaveprint').hide();

            $('#txtStopTime').on('click', function () {


                TimePicker = "txtStopTime";

            });
            $('#txtStopT').on('click', function () {
                TimePicker = "txtStopT";


            });
            $('#btnMO_Medicine').hide();

            $('#btnDischarge').show();
            $('#chkIntermittent').on('change', function () {
                $('#drinter').text('Duration/Interval');
                $('#StopField').hide();
                $('#txtStopDateTime').val('');
                $('#txtStopTime').val('');

            })
            $('#chkContinous').on('change', function () {
                $('#drinter').text('Duration')
                $('#StopField').show();
            })

            $('#txtStartD').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    debugger;
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate() + 1);
                    $("#txtStopD").datepicker("option", "minDate", dt);
                }
            });
            $('#txtStartD').datepicker({ dateFormat: 'mm/dd/yy' });
            $('#txtStopD').on('change', function () {
                debugger;
            });
            debugger;


            $('#ddl_addtive').on('change', function () {
                debugger;
                var name = $(this).find('option:selected').text();
                var nameval = $(this).find('option:selected').val();

                if (nameval == 0 || nameval == "0" || nameval == '0') {
                    return false;
                }

                var row = '';
                row = '<tr>' +
                    '<td>' + name + '</td>' +
                    '<td><a href="javascript:void(0)" onClick="Delete(this)">Delete</a></td>' +

                    '</tr>';

                $('#tblAdditive tbody').append(row);


            });

            $('#txtStopD').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    debugger;
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate());
                    $("#txtStartD").datepicker("option", "maxDate", dt);
                    var st1 = moment($('#txtStartD').val());
                    var st2 = moment($('#txtStopD').val());

                    var start_Date = $('#txtStartD').val();
                    var start_Time = $('#txtStartT').val();
                    var complete = start_Date + ' ' + start_Time;
                    var stop_Date = $('#txtStopD').val();
                    var stop_Time = $('#txtStopT').val();
                    if (stop_Time == "") stop_Time = start_Time;
                    var completeStop = stop_Date + ' ' + stop_Time;
                    var start_Date = $('#txtStartD').val();
                    var start_Time = $('#txtStartT').val();
                    var complete = start_Date + ' ' + start_Time;
                    var stop_Date = $('#txtStopD').val();
                    var stop_Time = $('#txtStopT').val();
                    if (stop_Time == "") stop_Time = start_Time;
                    var completeStop = stop_Date + ' ' + stop_Time;


                    var oldDate = new Date(complete)
                    var newDate = new Date(completeStop)
                    var time = newDate - oldDate;
                    var seconds = moment.duration(time).seconds();
                    var minutes = moment.duration(time).minutes();
                    var hours = moment.duration(time).hours();
                    var days = moment.duration(time).days();
                    $('#txtInjection').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);

                }
            });
            $('#txtStartDate').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate());
                    $("#txtStopDateTime").datepicker("option", "minDate", dt);
                }
            });
            $('#txtStopDateTime').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate() - 1);
                    $("#txtStartDate").datepicker("option", "minDate", dt);
                }
            });
            $('#txtStopDateTime').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    debugger;
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate());
                    $("#txtStartDate").datepicker("option", "maxDate", dt);
                    var st1 = moment($('#txtStartDate').val());
                    var st2 = moment($('#txtStopDateTime').val());

                    var start_Date = $('#txtStartDate').val();
                    var start_Time = $('#txtStartTime').val();
                    var complete = start_Date + ' ' + start_Time;
                    var stop_Date = $('#txtStopDateTime').val();
                    var stop_Time = $('#txtStopTime').val();
                    var completeStop = stop_Date + ' ' + stop_Time;
                    var start_Date = $('#txtStartDate').val();
                    var start_Time = $('#txtStopDateTime').val();
                    var complete = start_Date + ' ' + start_Time;
                    var stop_Date = $('#txtStopDateTime').val();
                    var stop_Time = $('#txtStopTime').val();
                    var completeStop = stop_Date + ' ' + stop_Time;


                    var oldDate = new Date(complete)
                    var newDate = new Date(completeStop)
                    var time = newDate - oldDate;
                    var seconds = moment.duration(time).seconds();
                    var minutes = moment.duration(time).minutes();
                    var hours = moment.duration(time).hours();
                    var days = moment.duration(time).days();
                    $('#txtDurationInfusion').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);

                }
            });


            $('#txtStartDate').datepicker('setDate', new Date());
            var dt = new Date($('#txtStartDate').val());
            dt.setDate(dt.getDate());
            $("#txtStopDateTime").datepicker("option", "minDate", dt);


            var current_time = moment().format("hh:mm A");
            $('#txtStartTime').ptTimeSelect({});
            $('#txtStartTime').val(current_time);
            $('#txtStopTime').ptTimeSelect({});

            $('#txtStartD').datepicker('setDate', new Date());
            debugger;
            var dt = new Date($('#txtStartD').val());
            dt.setDate(dt.getDate());
            $("#txtStopD").datepicker("option", "minDate", dt);

            $('#txtStartT').ptTimeSelect({});
            $('#txtStartT').val(current_time);
            $('#txtStopT').ptTimeSelect({});
            $("#txtStopT").on("input", function () {

                alert();
            });


            InfusionVOL();
            AdditiveDose();
            InfusionRate();
            Routes();
            Sides();
            InfussionPharmacy();
            additive();
            $('textarea').addClass("todolist");
            $('#ctl00_MainContent_txtAreaOfInterest').removeClass('todolist');

            $('#ctl00_MainContent_txtIdentificationMarks').removeClass('todolist');

            $('#txtRemarks').removeClass('todolist');


            $(".todolist").focus(function (event) {

                if (document.getElementById(event.currentTarget.id).value === '') {
                    document.getElementById(event.currentTarget.id).value += '• ';
                }
            });
            $(".todolist").keyup(function (event) {

                var keycode = (event.keyCode ? event.keyCode : event.which);
                if (keycode == '13') {
                    var text = $('#' + event.currentTarget.id + '').val();
                    text += "• ";
                    $('#' + event.currentTarget.id + '').val(text);
                }

                var txtval = document.getElementById(event.currentTarget.id).value;
                if (txtval.substr(txtval.length - 1) == '\n') {
                    document.getElementById(' + event.currentTarget.id + ').value = txtval.substring(0, txtval.length - 1);
                }
            });



            $('#btnDischargePrint').attr('disabled', true);
            $("#txtMedicineName").hide();
            $("#lblMed").hide();
            $("#ctl00_MainContent_ddlMO_Doctor_Status").on('change', function () {
                var status = $(this).val();
                PageMethods.GetDoctorsAgainstMO(status, function (Medicine) {
                    var options = '<option value=""> Select Doctor  </option>'
                    $.each(JSON.parse(Medicine), function (key, value) {
                        options += '<option value="' + value.Emp_ID + '"> ' + value.Emp_Name + ' </option>';
                    });

                    $('#ctl00_MainContent_ddlMo_Doctor_Name').html(options);
                    $('#ctl00_MainContent_ddlMo_Doctor_Name').select2();



                });
            });

            $("#ctl00_MainContent_DocStatus").on('change', function () {
                var status = $(this).val();
                PageMethods.GetDoctorsAgainstMO(status, function (Medicine) {
                    var options = '<option value=""> Select Doctor  </option>'
                    $.each(JSON.parse(Medicine), function (key, value) {
                        options += '<option value="' + value.Emp_ID + '"> ' + value.Emp_Name + ' </option>';
                    });

                    $('#ctl00_MainContent_DdlDocName').html(options);
                    $('#ctl00_MainContent_DdlDocName').select2();

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
            FillRooms();
            FillRoomsRefer();
            ChangePanel();

            FillPharmacyItem();
            var btnsave = $("#btnSave").val();

            var chk = '<%= Request.QueryString["ID"]%>';

            if (chk != "") {

                chkIssuance_Of_Select();
                chkrefer_Of_Select();
                loadReferenceInformation();
                $('#loadingimage').hide();
                $("#ctl00_MainContent_ddlMo_Doctor_Name").val(localStorage.DoctorID);
                $("#ctl00_MainContent_ddlMO_Doctor_Status").val(localStorage.DesignationID);
                loadTokenInputsDefaultForServices();
            }

            if ($('#ctl00_MainContent_txtIn_Patient_ID').val() != '(New)') {
                LoadDoctorNote();
                LoadMedicines();
                LoadTestList();
                LoadHistory();
                LoadEyeList();
                LoadSymtomps();
                LoadLabResultrpt();
                //LoadMedicines();
                LoadInfusion();
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
                else {
                    $("#tabs").tabs("option", "active", 0);
                }
            }
            else {
                $("#tabs").tabs("option", "active", 0);
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
            FillWardBedsRefer();
            $('#add-new-Othertest').click(function () {


                var Result = 'Result';
                var test = $('#ddlOtherTest').val();
                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
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

                var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"><input type="hidden" name="txtDeptID" value="0"/> ' + $('#ddlOtherTest').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';


                var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');
                if (test_array.length > 0) {
                    alert('This test already added!');
                } else {
                    $('.tests-table').append(row);
                }
            });

            $('#btnAddMedicine').on("click", function (e) {

                $('#chkRegular').prop('checked', true);
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

            });
            $('#btnRegularMedicine').on("click", function (e) {
                $('#RiskMed').show();
                $('#StopMed').show();
                $('#trduration').show();
                $('#trIns').hide();
                $('#text').text('Regular Medication Orders');
                localStorage.IsRegular = 1;
                localStorage.IsPRN = 0;
                localStorage.IsStat = 0;
                $('#chkRegular').prop('checked', true);
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
                $('#ddlDosage_Qty').val('');
                $('#ddlDosage_From').val('0')
                $('#txtStopD').val('');
                $('#txtStopT').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#ddlOther_Instruction').val('0');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');

                $('#txtMedicineName').focus();

            });
            $('#btnSTATMedicine').on("click", function (e) {
                $('#text').text('Once - Only / STAT Medication Orders');
                $('#RiskMed').hide();
                $('#StopMed').hide();
                $('#trduration').hide();
                $('#trIns').hide();
                localStorage.IsStat = 1;
                localStorage.IsPRN = 0;
                localStorage.IsRegular = 0;
                $('#chkRegular').prop('checked', true);
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

            });
            $('#btnPRNMedicine').on("click", function (e) {
                debugger;
                $('#RiskMed').hide();
                $('#StopMed').hide();
                $('#trduration').hide();
                $('#trIns').show();
                $('#text').text('PRN(As Needed Medication) Orders');
                localStorage.IsPRN = 1;
                localStorage.IsStat = 0;

                localStorage.IsRegular = 0;
                $('#chkRegular').prop('checked', true);
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
                $('#Routes').val('0');
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('')
                $('#ddlOther_Instruction').val('0')

                $('#txtMedicineName').focus();

            });
            $('#btnSaveMedicine').on("click", function () {
                debugger;

                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");
                    $('#txtInjection').val("0");
                    $('#AttendingParamedicalStaff').val("0");

                }

                if ($('#txtPharmacyItem').val() == 'Select Medicine') {
                    $('#txtPharmacyItem').val() = '';
                }

                if ($('#txtMedicen').val() != '' && $('#txtPharmacyItem').val() != '') {
                    alert("Please Eneter One Name")
                    return false;
                }
                if ($('#txtMedicen').val() == '' && $('#txtPharmacyItem').val() == '') {
                    alert("Please Eneter Name")
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
                    alert("Please Select Dose ")
                    return false;
                }
                var Frequency = $('#txtRecomended_Dosage').val();
                if (Frequency == "") {
                    alert("Please Select Frequency ")
                    return false;
                }
                var DosageFrom = $('#ddlDosage_From').val();
                var Route = $('#Routes').val();
                if (Route == "") {
                    alert("Please Select Route ")
                    return false;
                }
                var Duration = $('#txtInjection').val();
                if (Duration == "") {
                    if (localStorage.IsPRN == 1 || localStorage.IsStat == 1) {

                    }
                    else {
                        alert("Please Select Duration ");
                        return false;
                    }
                }

                var datetime = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss A")%>';
                var datetimeValue = '<%= DateTime.Now%>';
                var start_Date = $('#txtStartD').val();
                var start_Time = $('#txtStartT').val();
                var complete = start_Date + ' ' + start_Time;
                var stop_Date = $('#txtStopD').val();
                var stop_Time = $('#txtStopT').val();
                var completeStop = stop_Date + ' ' + stop_Time;
                var datetime = '<%= DateTime.Now%>';
                var username = '<%= AppConfig.UserName%>';
                debugger;
                var rdRiskY = $('#rdRiskY').is(':checked');
                if (rdRiskY == true) {
                    rdRiskY = "Yes";
                }
                else {
                    rdRiskY = "No";
                }
                if ($('#rdRiskY').is(':checked') == false && $('#rdRiskN').is(':checked') == false) {
                    rdRiskY = "";
                }

                if ($(this).val() == 'Save') {
                    debugger;
                    var medicine = ''
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    var Regular = $('#chkRegular').prop('checked');
                    var Stat = $('#chkStat').prop('checked');
                    var PRN = $('#chkPRN').prop('checked');

                    if (medicine == '') {
                        var otherIns = $('#ddlOther_Instruction').find('option:selected').text();
                        if (otherIns == ' Select' || otherIns == " Select") {
                            otherIns = '';
                        }

                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#ddlDosage_Qty').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td><td> ' + $('#txtInjection').val() + '</td>   <td> ' + $('#Routes').find('option:selected').text() + ' </td><td>' + completeStop + '</td> <td>' + otherIns + '</td>' + '<td> ' + $('#AttendingParamedicalStaff').val() + ' </td>' + '<td>' + username + '</td>' + '<td><a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';


                        if (localStorage.IsStat == 1) {
                            debugger;
                            var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        }
                        if (localStorage.IsPRN == 1) {
                            debugger;
                            var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        }
                    }
                    else {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';

                        if (localStorage.IsStat == 1) {
                            debugger;
                            var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';;

                        }
                        if (localStorage.IsPRN == 1) {
                            debugger;

                            var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        }
                    }
                    if (localStorage.IsRegular == 1) {
                        var table = $('#tblMedicinesListRegular tbody');
                        table.append(row);
                    }
                    if (localStorage.IsStat == 1) {
                        var table = $('#tblMedicinesListSTAT tbody');
                        table.append(row);
                    }
                    if (localStorage.IsPRN == 1) {
                        var table = $('#tblMedicinesListPRN tbody');
                        table.append(row);
                    }
                    else if (localStorage.IsDischarge == 1) {
                        var table = $('#tblDischargeMedication tbody');
                        table.append(row);

                    }
                }
                else if ($(this).val() == 'Update') {
                    debugger;

                    var tid = $('#MedicationModel input[name=uurowid]').val();
                    var row = '';
                    if (localStorage.IsDischarge == 0) {

                        if (localStorage.IsPRN == 1) {
                            row = $('#tblMedicinesListPRN tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                            $(row).find('td')[0].innerText = complete;
                            $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                            $(row).find('td')[2].innerText = $('#ddlDosage_Qty').val();
                            $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                            $(row).find('td')[4].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();

                            $(row).find('td')[6].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                            $(row).find('td')[7].innerText = $('#txtPrnDose').val();
                            $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text();
                            $(row).find('td')[9].innerText = $('#AttendingParamedicalStaff').val();
                            $(row).find('td')[12].innerText = $('#txtPharmacyItem').val();

                        }
                        else if (localStorage.IsStat == 1) {
                            row = $('#tblMedicinesListSTAT tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                            $(row).find('td')[0].innerText = complete;
                            $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                            $(row).find('td')[2].innerText = $('#ddlDosage_Qty').val();
                            $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                            $(row).find('td')[4].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                            $(row).find('td')[5].innerText = $('#MedicationModel input[name=txtInjection]').val();
                            $(row).find('td')[6].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                            $(row).find('td')[7].innerText = $('#ddlOther_Instruction').find('option:selected').text();
                            $(row).find('td')[8].innerText = $('#AttendingParamedicalStaff').val();
                            $(row).find('td')[11].innerText = $('#txtPharmacyItem').val();
                        }
                        else if (localStorage.IsRegular == 1) {
                            debugger;
                            row = $('#tblMedicinesListRegular tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                            $(row).find('td')[0].innerText = complete;
                            $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                            $(row).find('td')[2].innerText = $('#ddlDosage_Qty').val();
                            $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                            $(row).find('td')[4].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                            $(row).find('td')[5].innerText = $('#MedicationModel input[name=txtInjection]').val();
                            $(row).find('td')[6].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                            $(row).find('td')[7].innerText = completeStop;
                          

                            $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text();
                            $(row).find('td')[9].innerText = $('#AttendingParamedicalStaff').val();
                            $(row).find('td')[12].innerText = $('#txtPharmacyItem').val();


                        }
                    }
                    else if (localStorage.IsDischarge == 1) {
                        row = $('#tblDischargeMedication tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                        $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                        $(row).find('td')[2].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                        $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                        $(row).find('td')[4].innerText = $('#MedicationModel input[name=txtInjection]').val();
                        $(row).find('td')[5].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();

                        $(row).find('td')[6].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                        $(row).find('td')[7].innerText = $('#ddlDosage_Qty').val();
                        $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim() == "Select" ? '' : $('#ddlOther_Instruction').find('option:selected').text().trim();
                        '<a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
                    }

                }


                $('#txtMedicen').hide();
                $('#txtMedicen').val('');
                $('#txtMedicineName').val('');
                $('#txtPharmacyItem').val(0).trigger('change');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlOther_Instruction').val('');
                $('#txtPrnDose').val('');
                $('#txtStopD').val('');
                $('#txtStopT').val('');
                $('#ddlDosage_Qty').val('');
                $('#txtPharmacyItem').val('');
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
            $("#ctl00_MainContent_txtTimeOfDeath").datetimepicker({
                datepicker: false,
                step: 15,
                format: 'h:i A'
            });
        }

        function chkIssuance_Of_Select() {
            $('#tblWards tbody tr').remove();
            $('#tblRooms tbody tr').remove();

            var Issuance_Of = document.getElementById('<%= ddlIssuance_Of.ClientID%>').value;
            if (Issuance_Of == 0) {
                document.getElementById('<%= ddlRoom_No.ClientID%>').value = 0;
                document.getElementById('<%= txtRoom_Type.ClientID%>').value = 0;
                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;


                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = true;
                document.getElementById('<%= txtRoom_Type.ClientID%>').disabled = true;
                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;


                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroud";

                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";


            }
            else if (Issuance_Of == '001') {

                document.getElementById('<%= ddlRoom_No.ClientID%>').value = 0;
                document.getElementById('<%= txtRoom_Type.ClientID%>').value = 0;
                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = false;

                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = true;
                document.getElementById('<%= txtRoom_Type.ClientID%>').disabled = true;

                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroud";

                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroudWhite";
            }
            else {

                document.getElementById('<%= ddlWard_No.ClientID%>').value = 0;

                document.getElementById('<%= ddlWard_No.ClientID%>').disabled = true;

                document.getElementById('<%= txtRoom_Type.ClientID%>').disabled = false;
                document.getElementById('<%= ddlRoom_No.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoom_No.ClientID%>').className = "dropdownBackgroudWhite";
                document.getElementById('<%= ddlWard_No.ClientID%>').className = "dropdownBackgroud";
            }
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

                document.getElementById('tblBed').style.display = "none";
                document.getElementById('tblRoom').style.display = "none";

            }
            else if (Issuance_Of == '001') {

                document.getElementById('<%= ddlroom.ClientID%>').value = 0;
                document.getElementById('<%= ddlRoomType.ClientID%>').value = 0;
                document.getElementById('<%= ddlwards.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroom.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomType.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroom.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlwards.ClientID%>').className = "dropdownBackgroudWhite";

                document.getElementById('tblBed').style.display = "table";
                document.getElementById('tblRoom').style.display = "none";

            }
            else {

                document.getElementById('<%= ddlwards.ClientID%>').value = 0;
                document.getElementById('<%= ddlwards.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomType.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroom.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroom.ClientID%>').className = "dropdownBackgroudWhite";
                document.getElementById('<%= ddlwards.ClientID%>').className = "dropdownBackgroud";

                document.getElementById('tblBed').style.display = "none";
                document.getElementById('tblRoom').style.display = "table";

            }
        }
        function PendingAdmisionPatients() {

            PageMethods.PendingAdmisionPatients(function (res) {

                var patients = JSON.parse(res);

                if (patients != "") {
                    var rows = '';
                    $.each(patients, function (key, value) {

                        rows = '<tr><td><input type="hidden" name="Patient_ID" value="' + value.pat_id + '"/><a  href="javascript:void(0)" style="color:blue" onclick=selectPatient(' + value.pat_id + ')>' + value.Patient_No + '</a> </td><td>' + value.Department + '</td></tr>';


                    });
                    $('#tblAdmisionPatientbody').html(rows);
                }

            });
        }
        function selectPatient(Patient_ID) {
            debugger;
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
        }
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
        function RemoveExtraDepts() {
            var UserID = '<%= Session["UserID"]%>';
            PageMethods.RemoveExtraDepts(UserID, SuccessFunc, function (exec) { alert(exec.getmessage()); })
        }
        function SuccessFunc(data) {
            debugger;
            var parsedData = JSON.parse(data);
            var options = '<option value="0">Please Select</option>';
            $.each(parsedData, function (key, value) {
                options += '<option value=' + value.Department_ID + '> ' + value.Department_Name + '</option>';
            });
            $('#ctl00_MainContent_ddlDepartments').html(options);
            setTimeout(function () {

                $('#ctl00_MainContent_ddlDepartments').val(localStorage.DeptID);
            }, 1000);

        }
        function select(inPatID) {
            debugger;
            $(".se-pre-con").fadeIn("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            localStorage.inPatID = inPatID;
            var chkPrivateforload = document.getElementById("ctl00_MainContent_chkPrivate").checked;
            localStorage.IsPrivate = chkPrivateforload;
            window.location.href = 'InPatientsCase.aspx' + '?ID=' + inPatID;
        }

        function fillDoctors() {
            debugger;
            var departmentId = $('#ctl00_MainContent_ddlDepartments').val();

            if (!departmentId) {
                $('#ddldoctors').html('<option value="">Select Doctor</option>');
                return;
            }

            var options = '<option value="">Select Doctor</option>';

            $.ajax({
                url: 'InPatientsCase.aspx/GetDoctors',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ departmentId: departmentId }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;

                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });

                    $('#ddldoctors').html(options);
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching doctor data:', error);
                }
            });
        }



        function fillPendingPatientsList() {
            debugger;
            $(".se-pre-con").fadeIn("slow");
            debugger;
            /*      var SelectedDepartment = localStorage.DeptID;*/
            var SelectedDepartment = $("#ctl00_MainContent_ddlDepartments").val();
            var SelectedDoctor = $("#ddldoctors").val();

            PageMethods.PendingPatients(SelectedDepartment, SelectedDoctor, function (data) {
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                  
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    var status = value.Checked;
                    if (status != null) {
                        status = "Checked"
                    }
                    else {
                        status = "Unchecked"
                    }
                  
                    var chkPrivate = document.getElementById("ctl00_MainContent_chkPrivate").checked;
                    if (chkPrivate == true) {
                        if (value.Patient_Type == "02") {
                            rows += '<tr> <td>' + value.Patient_No + '</td>' + '<td>' + value.Full_Name + '</td> ' + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + value.Gender + '</td> ' + '<td>' + retdate + '</td> ' + '<td>' + value.Department + '</td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.UserName + '</td> ' + '<td>' + status + '</td>' + ' <td> <a href="javascript:void(0)" onclick=select(' + value.In_Patient_ID + ')>Select</a> </td> </tr>';
                           
                        }
                    }
                    else {
                        if (value.Patient_Type != "02") {
                            rows += '<tr> <td>' + value.Patient_No + '</td>' + '<td>' + value.Full_Name + '</td> ' + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + value.Gender + '</td> ' + '<td>' + retdate + '</td> ' + '<td>' + value.Department + '</td> ' + '<td>' + value.DoctorName + '</td> '+ '<td>' + value.UserName + '</td> ' + '<td>' + status + '</td>' + ' <td> <a href="javascript:void(0)" onclick=select(' + value.In_Patient_ID + ')>Select</a> </td> </tr>';
                        }
                    }
                });
                $('#tblPendingPatients tbody').html(rows);
            }, function (exec) { })
        }

        

        function FillRooms() {

            var RoomType = $('#ctl00_MainContent_txtRoom_Type').val();
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
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/                             ><a href="#" onclick="Selectroom(this)" style="color:green"> ' + value.Room_No + ' </a> </td></tr>';
                        }
                        else {
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/                              ><font color="red">' + value.Room_No + '</font></td></tr>';
                        }
                        $('#tblRooms').append(rows);
                    });
                }
                else {
                    $('#tblRooms tbody tr').remove();
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
            debugger;
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
            window.location = "InPatientsCase.aspx";
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


        function loadReferenceInformation() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            $.ajax({
                type: "POST",
                url: "InPatientsCase.aspx/loadReferenceInformation",
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
        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            $.ajax({
                type: "POST",
                url: "InPatientsCase.aspx/GetDetail",
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
                var IPD_ID = data.d.IPD_ID;
                if (IPD_ID == 0 || IPD_ID == 'null' || IPD_ID == null) {
                    alert("Please Create Admission First");
                    $('#btnSave').attr('disabled', true);
                    $('#btnsaveprint').attr('disabled', true);
                    return true;
                }
            }
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
            $('#ctl00_MainContent_ddlDepartments').val(localStorage.DeptID);
        }

        function Cleardrpdwn() {

            FillMedicine();
        }
        function CleardrpdwnItem() {

            FillPharmacyItem()
        }
        function NewMedicine() {

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

        function DischargeRequest() {
            debugger;
            $("#ctl00_MainContent_DischargeRequest").val('true')
            SaveInPatientAllRecord();
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   <div id="MedicationModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="width: 850px; margin-left: 133px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Medicine</h4>
                </div>
                <div class="modal-body">
                    <fieldset>
                        <legend id="text">Medication Details</legend>
                        <table id="tblMedicines" class="add-test">                            
                                <form id="item">
                                    <div class="row">
                                        <div class="col-lg-3 col-md-3 col-sm-4">
                                            <span>Start Date</span>
                                            <input type="text" id="txtStartD" />
                                        </div>
                                        <div class="col-lg-3 col-md-3 col-sm-4" style="margin-left: 0px !important">
                                            <span>Start Time</span>
                                            <input type="text" id="txtStartT" />
                                        </div>
                                        <div class="col-lg-6 col-md-3 col-sm-4" id="MedicineName">
                                            <span id="lblMed">Medicine Name</span>
                                            <select id="txtMedicineName" name="txtMedicineName" class="js-example-responsive;" onchange="CleardrpdwnItem()"></select>
                                            <span id="pitem">Medicine Name</span><span class="RedStar">*</span>
                                            <select id="txtPharmacyItem" name="txtPharmacyItem" style="width: 135px !important" onchange="Cleardrpdwn()">
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-3 col-md-3 col-sm-4">
                                            <span>Dose</span><span class="RedStar">*</span>
                                            <input type="text" id="ddlDosage_Qty" name="DosageQty" />
                                        </div>
                                    <div class="col-lg-3 col-md-3 col-sm-4">
                                         <label> Dosage Unit  :</label> 
                                        <select id="ddlDosage_From"  name="DosageFrom">
                                        <option value="">Select</option></select>                                        
                                    </div>

                                        <div class="col-lg-3 col-md-3 col-sm-4">
                                            <span>Frequency </span><span class="RedStar">*</span>
                                            <select id="txtRecomended_Dosage" name="RecomendedDosage" style="margin-top:7px !important" > </select>
                                        </div>                                       
                                        <div class="col-lg-3 col-md-3 col-sm-4" id="trduration">
                                            <label>Duration(H/D/W/M)<span class="RedStar">*</span></label>
                                            <input type="text" id="txtInjection" name="txtInjection" placeholder="Duration" disabled="disabled" />
                                        </div>  
                                        </div>
                                    <div class="row">
                                        <div class="col-lg-3 col-md-3 col-sm-4">
                                            <label>Route<span class="RedStar">*</span> </label>
                                            <select id="Routes" name="Routes" style="margin-top:-2%" tabindex="4">
                                            </select>
                                        </div>
                                    <div class="col-lg-3 col-md-3 col-sm-4" id="StopMed">
                                        <span>Stop Date</span>
                                        <input type="text" id="txtStopD"/>
                                        </div>
                                        <div class="col-lg-0 col-md-3 col-sm-4"  id="trIns"></div>
                                         <div class="col-lg-3 col-md-4 col-sm-6" >
                                             <span>Stop Time</span>
                                             <input type="text" id="txtStopT" />
                                         </div>
                                    <div class="col-lg-3 col-md-4 col-sm-6" id="RiskMed">
                                    <span>Special Instructions </span><span class="RedStar"></span>
                                    <input type="text" name="AttendingParamedicalStaff" id="AttendingParamedicalStaff"  tabindex="6"/>
                                    </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <span style="">Other Instructions </span>
                                            <select style="" id="ddlOther_Instruction" name="OtherInstruction">
                                                <option>Please Select</option>
                                            </select>
                                        </div>
                                    </div>
                                   </form>
                                <td>
                                    <input type="text" id="txtMedicen" visible="false" style="" />
                                </td>                              
                           

                            <tr style="display:none;">
                                  <td>                                  
                                  <input type="radio" id="chkRegular" name="foo" />
                                      <label><h2>Regular</h2></label>
                                </td>                              
                                 <td>
                                    <input type="radio" id="chkStat" name="foo"/>
                                       <label><h2>Stat</h2></label>
                                </td>                             
                                 <td>
                                    <input type="radio" id="chkPRN" name="foo"/>
                                       <label><h2>PRN</h2></label>
                                </td>                               
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <input type="button" id="btnSaveMedicine" class="btn btn-primry" name="btnSaveMedicine" value="Save" tabindex="7" />
                                </td>                                                            
                                 <td>                                
                                    <input type="button" id="Addmedicine" class="btn btn-primry" value="Add Unlisted Medicine"  style="margin-left: 110px;width:60% !important" onclick="NewMedicine()" />
                                        </td>
                                <td></td>
                            </tr>
                        </table>
                    </fieldset>
                    <input type="hidden" name="uurowid" value="" />
                </div>
                <div class="modal-footer">
                    <input type="button" value="Done" class="btn-gray" data-dismiss="modal" style="width:13% !important" />
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
                <div class="col-lg-5 col-md-5 col-sm-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                    <div class="image-container">
                                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Addmittiedpatient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                                    </div>
                                </div>
                                <div class="col-lg-8 col-md-5 col-sm-6">
                                <div class="row mb-3 detail">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :*"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6">
                                        <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                                        <asp:HiddenField ID="hdfPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                                        <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
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
                                            <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
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
                       <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                        <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                       <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="Label36" runat="server" Text="Patient Type:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                         <asp:Label ID="vLbl_Patient_Type" runat="server" style="background-color: silver;"></asp:Label>
                    </div>
                </div>
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="Label35" runat="server" Text="InPatient Admit Catagory :"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="vLbl_Patient_AdmitCatagory" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>
  </div>
</div>
            
            <div style="width: 100%">
                <div id="tabs">
                    <ul>                     
                        <li><a href="#Tab-19">Waiting List</a></li>
                        <li><a href="#Tab-2">Receiving</a></li>
                        <li><a href="#Tab-8">History</a></li>
                        <li><a href="#Tab-13">Examination</a></li>
                        <li><a href="#Tab-6">Investigation</a></li>
                        <li><a href="#Tab-14">Services</a></li>
                        <li><a href="#Tab-4">Medication</a></li>
                        <li><a href="#Tab-18">IV Fluid</a></li>
                        <li><a href="#Tab-16">Treatment</a></li>
                        <li><a href="#Tab-7">Doctor</a></li>
                        <li><a href="#Tab-17">Doctors Plan</a></li>
                        <li><a href="#Tab-12">Refer</a></li>
                        <li><a href="#Tab-15">Vitals Discharge </a></li> 
                        <li><a href="#Tab-3" style="display: none">Operations</a></li>
                        <li><a href="#Tab-11">Death Details</a></li>  
                                   </ul>

                    <div id="Tab-19">
                <h2>Patients Waiting List Department Wise : </h2>
                <div id="Div2">
                    <div>
                        <table id="tblHeader">
                            <tr>
                                <td>
                                    <h4 style="margin-left: 5px;">Select Your Department </h4>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 261px">
                                    <select  id="ddlDepartments" runat="server" onchange="fillDoctors();"></select>
                                </td>
                                <td style="width: 261px">
                                    <select id="ddldoctors" style="margin-left: 14px;"  onchange="fillPendingPatientsList();">
                                        <option value="">Select Doctor</option>
                                    </select>
                                </td>
                                <td style="padding-left:20px !important">Private</td>
                                <td style="padding-left:10px !important">
                                    <asp:CheckBox ID="chkPrivate" runat="server" onclick="fillPendingPatientsList()"></asp:CheckBox>
                                </td>
                                
                            </tr>
                        </table>
                    </div>
                    <div style="overflow: scroll; height: 400px;">
                        <fieldset>
                            <table class="table table-hover table-striped table-bordered" id="tblPendingPatients" style="overflow: scroll;">
                                <thead id="ihead">
                                    <tr>
                                        <th>MR No</th>
                                        <th>Patient Name</th>
                                        <th>Age</th>
                                        <th>Gender</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Department</th>
                                        <th>Doctor</th>
                                        <th>Operator Name</th>
                                     
                                        <th>Status</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>
                        </fieldset>
                    </div>
                </div>
            </div>


                    <div id="Tab-1" style="display :none;">
                        <div id="OtherDetails" style="width: 70%; min-height: 300px !important; height: auto !important;">
                            <table style="padding: 20px">
                                <tr>
                                    <td colspan="5">
                                        <h2 style="width: 719px;">Admission Details : </h2>
                                    </td>
                                     <td>
                                        <h2 style="width: 500px !important;"> Today Admission : </h2>
                                    </td>
                                    <td colspan="2" style="width: 500px !important;">
                                        <div style=" overflow: scroll;width:258px; height: 133px;margin-left:-299px">
                                <table id="tblAdmisionPatient" class="table" style="width: 100% !important;">
                                    <thead>
                                        <tr>
                                            <th>MR No</th>
                                            <th>Dept</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tblAdmisionPatientbody">
                                    </tbody>
                                </table>
                            </div>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width: 155px">
                                        <asp:Label ID="LblAdmission_Date" runat="server" Text="Admission Date"></asp:Label>
                                    </td>
                                    <td style="width: 203px;">
                                        <asp:TextBox ID="txtAdmission_Date" runat="server" ReadOnly="true"></asp:TextBox>
                                    </td>
                                    <td></td>
                                    <td style="width: 143px; padding-left: 45px;">
                                        <asp:Label ID="lblIssuance_Of" runat="server" Text="Admit To *"></asp:Label>
                                    </td>
                                    <td style="width: 203px">
                                        <asp:UpdatePanel ID="UpdatePanel9" TabIndex="6" runat="server">
                                            <ContentTemplate>
                                                <asp:DropDownList ID="ddlIssuance_Of" runat="server" AppendDataBoundItems="true" onChange="chkIssuance_Of_Select()"></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvIssuance_Of" ControlToValidate="ddlIssuance_Of" InitialValue="0" runat="server" ErrorMessage="Select Admit To" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                    <td>
                                        <asp:UpdatePanel ID="UpdatePanel8" runat="server" UpdateMode="Always">
                                            <ContentTemplate>
                                                <asp:Label ID="vlblCurrent_Allocated_Room_Ward" runat="server" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                        <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                                            <ContentTemplate>
                                                <asp:Button ID="btnAllocatedRoomWardChkTriggerBtn" Style="display: none;" Text="Chk Allocated Room" runat="server" OnClick="btnAllocatedRoomWardChkTriggerBtn_Click" CausesValidation="false" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="LblDepartment" runat="server" Text="Department"></asp:Label>
                                    </td>
                                    <td style="width: 203px;">
                                        <asp:DropDownList ID="ddlDepartment" TabIndex="1" runat="server" Width="167px" AppendDataBoundItems="true" onchange="Chk_Doctor_Info()"></asp:DropDownList>
                                        <asp:UpdatePanel ID="UpdatePanel12" runat="server" UpdateMode="Always">
                                            <ContentTemplate>
                                                <asp:Button ID="btnGet_Doctor" Style="display: none;" Text="" runat="server" OnClick="btnGet_Doctor_Click" CausesValidation="false" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td></td>
                                    <td style="padding-left: 45px;">
                                        <asp:Label ID="lblWard_No" runat="server" Text="Ward *"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:UpdatePanel ID="UpdatePanel11" TabIndex="7" runat="server" UpdateMode="Always">
                                            <ContentTemplate>
                                                <asp:DropDownList ID="ddlWard_No" runat="server" AppendDataBoundItems="true" OnChange="FillWardBeds()" disabled="disabled"></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td>
                                        <asp:UpdateProgress ID="UpdateProgress2" runat="server" DisplayAfter="1000" DynamicLayout="False">
                                            <ProgressTemplate>
                                                <div class="loadingimage">
                                                     <asp:Image ID="image2" ImageUrl="~../../../../wwwroot/images/loading.gif" runat="server" Width="32px" />
                                                </div>
                                            </ProgressTemplate>
                                        </asp:UpdateProgress>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="LblDoctor" runat="server" Text="Admitting Doctor"></asp:Label>
                                    </td>
                                    <td style="width: 203px;">

                                        <asp:UpdatePanel runat="server" TabIndex="2" ID="UpdatePanel13">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:DropDownList ID="ddlDoctor" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td></td>
                                    <td style="padding-left: 45px;">
                                        <asp:Label ID="LblBed_No" runat="server" Text="Bed No"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBed_No" TabIndex="8" runat="server" Enabled="true"></asp:TextBox>
                                    </td>

                                    <td>
                                        <asp:RangeValidator ID="rngBed_No" Type="Integer" runat="server" MinimumValue="0" MaximumValue="999999999" ControlToValidate="txtBed_No" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
                                    </td>
                                    <td>
                                        <asp:UpdatePanel ID="UpdatePanel3" runat="server" UpdateMode="Conditional">
                                            <Triggers>
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:Label ID="lblChk" runat="server" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="7">
                                        <asp:UpdatePanel ID="UpdatePanel5" runat="server" UpdateMode="Conditional">
                                            <ContentTemplate>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="LblHealth_Complaints" runat="server" Text="Health Complaint *"></asp:Label>

                                    </td>
                                    <td style="width: 203px;">
                                        <asp:TextBox ID="txtHealth_Complaints" TabIndex="3" runat="server" TextMode="MultiLine" Style="width: 168px;"></asp:TextBox>
                                    </td>

                                    <td>
                                        <asp:RequiredFieldValidator ID="rfvHealth_Complaints" ControlToValidate="txtHealth_Complaints" runat="server" ErrorMessage="Enter Health Complaint" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                    <td style="padding-left: 45px;">
                                        <asp:Label ID="lblRoom_No" runat="server" Text="Room_No *"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlRoom_No" TabIndex="9" runat="server" AppendDataBoundItems="true" AutoPostBack="true" disabled="disabled"></asp:DropDownList>
                                    </td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="LblExpected_Discharge_Date" runat="server" Text="Expected Discharge Date"></asp:Label>
                                    </td>
                                    <td style="width: 203px;">
                                        <asp:TextBox ID="txtExpected_Discharge_Date" TabIndex="4" runat="server"></asp:TextBox>
                                    </td>
                                    <td></td>
                                    <td style="padding-left: 45px;">
                                        <asp:Label ID="LblRoom_Type" runat="server" Text="Room Type"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:UpdatePanel ID="UpdatePanel1" TabIndex="10" runat="server">
                                            <ContentTemplate>
                                                <asp:DropDownList ID="txtRoom_Type" runat="server" AppendDataBoundItems="true" AutoPostBack="true" onChange="FillRooms()"></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <tr>
                                     <td>
                                        <asp:Label ID="Label34" runat="server" Text="InPatient Admit Catagory"></asp:Label>
                                    </td>
                                    <td style="width: 203px;">
                                        <asp:DropDownList ID="ddlPatientType" TabIndex="5" runat="server" AppendDataBoundItems="true" onChange="ChangePanel()"></asp:DropDownList>
                                    </td>
                                     <td></td>
                                           <td><asp:Label id="lblPanelCompany" runat="server">Panel Companies</asp:Label> </td>
                                    <td>  <asp:DropDownList ID="ddlPanelCompany" runat="server" AppendDataBoundItems="true" ></asp:DropDownList></td>
                                </tr>
                                <tr>
                    <td>
                        <asp:Label ID="Label37" runat="server" Text="Print This Record:"></asp:Label>
                    </td>
                    <td style="width: 203px">
                        <input type="button" value="Print" id="btnPrintAdmisionDetail" onclick="PrintAdmisionDetail()"/>
                    </td
                </tr>
                            </table>
                            <div style="margin-left: 753px;margin-top: -211px; width: 185px; overflow: scroll; height: 250px; max-height: 400px !important;">
                                <table id="tblWards" class="table" style="width: 100% !important;">
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
                            <div style="margin-left: 973px; margin-top: -250px; width: 185px; overflow: scroll; height: 250px; max-height: 400px !important;">
                                <table id="tblRooms" class="table" style="width: 100% !important;">
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
                            <table style="margin-left: 60px; margin-top: 10px;" id="dvtblRoomsHistory">
                                <tr>
                                    <td>
                                        <table class="table" style="width: 1105px; height: 30px; overflow: scroll;" id="tblRoomsHistory">
                                            <thead>
                                                <tr>
                                                    <td colspan="12">
                                                        <div id="Div1">
                                                            <h2>Room Previous History</h2>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>Admission Date</th>
                                                    <th>Department </th>
                                                    <th>Admitting Doctor </th>
                                                    <th style="width: 300px;">Health Complaint </th>
                                                    <th>Discharge Date </th>
                                                    <th>Room No</th>
                                                    <th>Room Type</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </table>


                            <table style="margin-left: 60px; margin-top: 10px;" id="dvHistoward">
                                <tr>
                                    <td>
                                        <table class="table" style="width: 1105px; height: 30px; overflow: scroll;" id="tblWardHistory">
                                            <thead>
                                                <tr>
                                                    <td colspan="12">
                                                        <div id="Div3">
                                                            <h2>Ward Previous History</h2>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>Admission Date</th>
                                                    <th>Department </th>
                                                    <th>Admitting Doctor </th>
                                                    <th>Health Complaint </th>
                                                    <th>Discharge Date </th>
                                                    <th>Ward</th>
                                                    <th>Bed No</th>
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
                    
                    <div id="Tab-2">
                      
                                    <table style="padding: 100px">
                                           <form id="items">
                                        <div class="row">
                                  <div class="col-lg-3 col-md-3 col-sm-4">
                                       <h2>Receiving Note: </h2>
                                      </div>
                                            </div>
                                     <div class="row">
                                     <div class="col-lg-3 col-md-3 col-sm-4">
                                     <asp:Label ID="lblRateBeats" runat="server" Text="Pulse Rate (Beats per Min)"></asp:Label>
                                    <asp:TextBox ID="txtRateBeats" runat="server" TabIndex="1"></asp:TextBox>
                                         </div>
                                        <%-- <div class="col-lg-1 col-md-3 col-sm-4">
                                             </div>--%>
                                          <div class="col-lg-3 col-md-3 col-sm-4">
                                         <asp:Label ID="LblBP" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
                                         <asp:TextBox ID="txtBP" runat="server" TabIndex="2"></asp:TextBox>
                                         </div>
                                      <%--   <div class="col-lg-1 col-md-3 col-sm-4">
                                         </div>--%>
                                         <div class="col-lg-3 col-md-3 col-sm-4">
                                             <asp:Label ID="LblTemp" runat="server" Text="Temperature (°F)"></asp:Label>
                                             <asp:TextBox ID="txtTemp" runat="server" TabIndex="3"></asp:TextBox>
                                         </div>
                                    <%--     <div class="col-lg-1 col-md-3 col-sm-4">
                                         </div>--%>
                                         <div class="col-lg-3 col-md-3 col-sm-4">
                                         <asp:label ID="lblRhythm" runat="server" Text="Rhythm"></asp:label>
                                         <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythm"></asp:DropDownList>
                                         </div>                                         
                                         </div>
                                     <div class="row">
                                     <div class="col-lg-3 col-md-3 col-sm-4">
                                     <asp:Label ID="lblBSR" runat="server" Text="BSR (mg/dl)"></asp:Label>
                                    <asp:TextBox ID="txtBSR" runat="server" TabIndex="1"></asp:TextBox>
                                         </div>
                       
                                          <div class="col-lg-3 col-md-3 col-sm-4">
                                         <asp:Label ID="LblWeight" runat="server" Text="Weight (kg)"></asp:Label>
                                         <asp:TextBox ID="txtWeight" runat="server" TabIndex="2" onchange="calculateBMI()"></asp:TextBox>
                                         </div>
                             <%--            <div class="col-lg-1 col-md-3 col-sm-4">
                                         </div>--%>
                                         <div class="col-lg-3 col-md-3 col-sm-4">
                                             <asp:Label ID="LblHeight" runat="server" Text="Height (cm)"></asp:Label>
                                             <asp:TextBox ID="txtHeight" runat="server" TabIndex="3" onchange="calculateBMI()"></asp:TextBox>
                                         </div>
                                 <%--        <div class="col-lg-1 col-md-3 col-sm-4">
                                         </div>--%>
                                         <div class="col-lg-3 col-md-3 col-sm-4">
                                         <asp:label ID="lblBMI" runat="server" Text="BMI"></asp:label>
                                         <asp:TextBox ID="txtBMI" runat="server" TabIndex="3"></asp:TextBox>
                                         </div>                                         
                                         </div>
                                        <div class="row">                                       
                                         <div class="col-lg-3 col-md-3 col-sm-4">
                                        <asp:Label ID="LblRespiration" runat="server" Text="Respiration Rate (/min)"></asp:Label>
                                        <asp:TextBox ID="txtRespiration" runat="server" TabIndex="4"></asp:TextBox>
                                             </div>
                                  <%--          <div class="col-lg-1 col-md-3 col-sm-4">
                                                </div>--%>
                                            <div class="col-lg-3 col-md-3 col-sm-4">
                                  <asp:Label ID="lblSaturation" runat="server" Text="O2 Saturation"></asp:Label>
                                     <asp:TextBox ID="txtSaturation" runat="server" TabIndex="2"></asp:TextBox>
                                            </div>
                                        <%--    <div class="col-lg-1 col-md-3 col-sm-4">
                                                </div>--%>
                                            <div class="col-lg-3 col-md-3 col-sm-4">
                                            <asp:Label ID="lblOthersReceiveNote" runat="server" Text="Others"></asp:Label>
                                    <asp:TextBox ID="txtOthersRcvNote" runat="server"  TextMode="MultiLine" TabIndex="2" Style="width:100% !important;height:33px !important"></asp:TextBox>
                                            </div>
                                           <%-- <div class="col-lg-1 col-md-3 col-sm-4">
                                                </div>--%>
                                            <div class="col-lg-3 col-md-3 col-sm-4">
                                                <asp:Label ID="lblVolume" runat="server" Text="Volume"></asp:Label>
                                        <asp:DropDownList runat="server" ID="ddlVolume" AppendDataBoundItems="true"></asp:DropDownList>
                                            </div>
                                            </div>
                                               <div class="row">
                                                   <div class="col-lg-3 col-md-6 col-sm-4">
                                                       <label></label>
                                                  <asp:TextBox ID="txtSaturation_Oxygen2" runat="server" TabIndex="2"></asp:TextBox>                                                  
                                                   </div>
                                               <%--    <div class="col-lg-1 col-md-6 col-sm-4">
                                                         </div>--%>
                                                   <div class="col-lg-3 col-md-3 col-sm-4">
                                                       <label></label>
                                                  <asp:TextBox ID="txtSaturation_Oxygen1" runat="server" TabIndex="2"></asp:TextBox>                                                      
                                                   </div>
                                               <%--    <div class="col-lg-1 col-md-6 col-sm-4">
                                                   </div>--%>
                                                   <div class="col-lg-6 col-md-6 col-sm-4">
                                                       <asp:Label ID="lblRN_Special_Instruction" runat="server" Text="Special Instruction"></asp:Label>
                                                       <asp:TextBox ID="txtRN_Special_Instruction" runat="server" TabIndex="9" TextMode="MultiLine" class="todolist" Style="width:100%;height:33px" onchange="FillInstruction()"></asp:TextBox>
                                                   </div>
                                                   </div>
                                             <div class="row">
                                                 <div class="col-lg-1 col-md-6 sm-12">
                                                     <label>On Room Air</label>
                                                     </div>
                                                  <div class="col-lg-1 col-md-4 col-sm-6">
                                                     <asp:CheckBox runat="server" ID="chk_OnRoomAir" />
                                                 </div>
                                                    <div class="col-lg-1 col-md-4 col-sm-6"></div>
                                                 <div class="col-lg-1 col-md-4 col-sm-6">
                                                     <label>With Oxygen</label>
                                                 </div>
                                                 <div class="col-lg-1 col-md-4 col-sm-6">
                                                     <asp:CheckBox runat="server" ID="chk_WithOxygen" />
                                                 </div>
                                                     </div>
                                                 <div>
                                                     <input placeholder="enter value" type="text" id="entryText" style="width: 227px!important; position: relative; left: 573px; top: -3px; display: none;" />
                                                     <input type="button" id="btn_add" value="Add" style="position: relative; left: 731px; display: none; /* float: left!important; */float: left;" />
                                                      <asp:Label ID="lblRecieving_Time" runat="server" Text=" Receiving Date & Time" Visible="false" ></asp:Label>
                                                      <asp:TextBox ID="txtReceiving_Date" runat="server" ReadOnly="true" Visible="false" ></asp:TextBox>
                                                     <div class="col-lg-2">
                                                     <input type="button" value="Print" id="PrintVital" class="btn btn-primry" onclick ="PrintVitals();" />
                                                         </div>
                                                 </div>
                                        </form>                                                                                           
                        </table>
                        <table class="table">
                            <tr>
                                <td>
                                    <div style="overflow:scroll;margin-left:-9px">
                                    <table class="table" id="tblVitalParametersHistory">
                                        <thead>
                                            <tr>
                                                <td colspan="20">
                                                    <div id="tblHistoryHeader">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Receiving Date & Time </th>
                                                <th style="width: 84px;">Status</th>
                                                <th>Rate_Beats</th>
                                                <th>Temperature</th>
                                                <th>Rhythm</th>
                                                <th>Volume</th>
                                                <th>Blood Pressure</th>
                                                <th>Others </th>                                                
                                                <th>Respiration </th>
                                                <th>Instruction </th>
                                                <th>O2 Saturation</th>                                                
                                                <th>O2 Saturation_Oxygen1</th>
                                                <th>O2 Saturation_Oxygen2</th>
                                                <th>BSR</th>
                                                <th>BMI</th>
                                                <th>Wt</th>
                                                <th>Ht</th>
                                                   <th>Username</th>                                             
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                        </div>
                                </td>
                            </tr>
                        </table>
                    </div>

                   <div id="Tab-3">
                        <div id="Operations" style="width: 70%">
                            <table style="padding: 20px">
                                <tr>
                                    <td colspan="4">
                                        <h2>Operations : </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblOperation_No" runat="server" Text="Operation No."></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtOperation_No" runat="server"></asp:TextBox>
                                    </td>

                                    <td class="mgTab">
                                        <asp:Label ID="lblPerformed_By" runat="server" Text="Performed By"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:DropDownList ID="ddlPerformed_By" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblBrief_Description" runat="server" Text="Brief Description "></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBrief_Description" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td class="mgTab">
                                        <asp:Label ID="lblSurgeon_Note" runat="server" Text="Surgeon_Note "></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtSurgeon_Note" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblMedication_Precautions" runat="server" Text="Medication And Precautions"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtMedication_Precautions" runat="server"></asp:TextBox>
                                    </td>
                                    <td class="mgTab">
                                        <asp:Label ID="lblPost_Operative_Care" runat="server" Text="Post Operative Care"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPost_Operative_Care" runat="server"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblShifted_To_ICU" runat="server" Text="Shifted To ICU "></asp:Label>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="cbShifted_To_ICU" runat="server"></asp:CheckBox>
                                    </td>
                                    <td class="mgTab">
                                        <asp:Label ID="lblShifted_To_CCU" runat="server" Text="Shifted To CCU"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="cbShifted_To_CCU" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblShifted_Observation_Room" runat="server" Text="Shifted To Observation Room"></asp:Label>
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="cbShifted_To_Observation_Room" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>

                    <div id="Tab-4">
                        <div id="Medication" >
                            <h2 >Medication : </h2>
                            <table style="width:100%">
                                <tr>
                                    <td>
                                        <input type="button" value="Regular Medicine" id="btnRegularMedicine" class="btn btn-primry" style="width: 15% !important;"/>
                                   <%--        <input type="button" value="STAT Medicine" class="btn btn-primry" id="btnSTATMedicine" style="width: 15% !important;"/>
                                         <input type="button" value="PRN Medicine" class="btn btn-primry" id="btnPRNMedicine" style="width:15% !important;"/> --%>                     
                                         <input type="button" class="btn btn-primry" onclick="PrintMecicationDetail()" value="Regular Print" style="width:15% !important" />
                                       <%-- <input type="button" class="btn btn-primry" onclick="PrintMecicationDetailPRN()" value="STAT Print"  style="width: 15% !important;"/>
                                         <input type="button" class="btn btn-primry" onclick="PrintMecicationDetailSTAT()" value="PRN Print" style="width: 15% !important;" />--%>
                                        <h2>Regular Medicine</h2>
                                        <div style="overflow: scroll; height: 280px;">                                       
                                        <table class="table" id="tblMedicinesListRegular">
                                        <thead>
                                            <tr style="position: sticky; top: 0px; z-index: 10;">
                                                <th style="width: 160px;">Start Date & Time </th>
                                                <th style="width: 170px;">Medicine Name </th>
                                                <th>Dose </th>
                                                <th>Dosage Unit </th>
                                                <th>Frequency  </th>
                                                <th>Duration </th>
                                                <th>Route </th>
                                                <th>Stop Date & Time</th>
                                                <%--<th>High Risk Drug</th>--%>
                                                <th>Other Instruction</th>
                                                 <th>Special Instructions </th>
                                                <th>Username</th>
                                                <th style="width: 100PX;">Edit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                            </div>
                                        <%-- <h2>STAT Medicine</h2>
                                          <div style="overflow: scroll; height: 280px;">
                                            <table class="table" id="tblMedicinesListSTAT">
                                        <thead>
                                            <tr style="position: sticky; top: 0px; z-index: 10;">
                                                <th style="width: 160px;">Start Date & Time </th>
                                                <th style="width: 170px;">Medicine Name </th>
                                                <th>Dose </th>
                                                <th>Dosage Unit </th>
                                                <th>Frequency  </th>
                                                <th>Duration </th>
                                                <th>Route </th>
                                                <th>Other Instruction</th>
                                                <th>Special Instructions </th>
                                                <th>Username</th>                                              
                                                <th style="width: 100PX;">Edit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                              </div>
                                          <h2>PRN Medicine</h2>
                                          <div style="overflow: scroll; height: 280px;">
                                            <table class="table" id="tblMedicinesListPRN">
                                        <thead>
                                            <tr style="position: sticky; top: 0px; z-index: 10;">
                                                <th style="width: 160px;">Start Date & Time </th>
                                                <th style="width: 170px;">Medicine Name </th>
                                                <th>Dose </th>
                                                <th>Dosage Unit </th>
                                                <th>Frequency  </th>
                                                <th>Duration </th>
                                                <th>Route </th>                                                                                               
                                                <th>Max Prn Dose/24 Hours</th>
                                                 <th>Other Instruction</th>
                                                   <th>Special Instructions </th>
                                                 <th>Username</th>                                             
                                               <th style="WIDTH: 100PX;">Edit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>                                      
                                        </div>--%>
                                    </td>
                                </tr>
                            </table>
                            <div style=" overflow: scroll; height: 280px;">
                                <table class="table" id="tblHistoryMedication">
                                        <thead>
                                            <tr style="position: sticky; top: 0;z-index: 10;";>
                                                <td colspan="12">
                                                    <div id="HeaderHistoryMedication">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr style="position: sticky; top: 70px; z-index: 10;">
                                                <th style="width: 160px;">Date</th>
                                                <th style="width: 84px;">Status</th>
                                                <th style="width: 170px;">Medicine Name</th>
                                                <th>Frequency</th>
                                                <th>Routes</th>
                                                <th>Duration</th>
                                                <th>Special Instructions</th>
                                                <th>Dosage From</th>
                                                <th>Dosage Qty</th>
                                                <th>Other Instruction</th>
                                                <th>Medication Type</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                            </div>
                        </div>
                    </div>
                   
                    <div id="Tab-5" style="display: none">
                        <div id="Discharge_Detail" style="width: 70%">
                            <table>
                                <tr>
                                    <td>
                                        <table style="padding: 20px">
                                            <tr>
                                                <td colspan="4">
                                                    <h2>Discharge Details : </h2>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDischarge_By" runat="server" Text="Advise By"></asp:Label>
                                                </td>
                                                <td>
                                                      <asp:UpdatePanel runat="server" ID="UpdatePanel2">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="ddlDepartment" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:DropDownList ID="ddlDischarge_By" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="1"></asp:DropDownList>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                                </td>
                                                <td class="mgTab">
                                                    <asp:Label ID="lblDischarge_On" runat="server" Text="Discharged Date "></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtDischarge_On" runat="server" disabled="disabled"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblPrevention_Precaution" runat="server" Text="Advice "></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtPrevention_Precaution" runat="server" TextMode="MultiLine" Style="width: 168px;" TabIndex="2"></asp:TextBox>
                                                </td>
                                                <td class="mgTab">
                                                    <asp:Label ID="lblNext_Visit" runat="server" Text="Follow Up"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtNext_Visit" runat="server" TabIndex="5"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblMedicine_Provided" runat="server" Text="Procedure Operation"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtProcedure_Operation" runat="server" TextMode="MultiLine" Style="width: 170px;" TabIndex="3"></asp:TextBox>
                                                </td>
                                                <td class="mgTab">
                                                    <asp:Label ID="lblMedications" runat="server" Text="Diagnosis"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtMedication" runat="server" TextMode="MultiLine" Style="width: 170px;" TabIndex="6"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblBilling" runat="server" Text="Procedure Detail"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:TextBox ID="txtBilling" runat="server" TextMode="MultiLine" Style="width: 170px;" TabIndex="4"></asp:TextBox>
                                                </td>
                                                <td class="mgTab">
                                                    <asp:Label ID="lblDeath_Certificate" runat="server" Text="Death Certificate" style="display:none"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="cbDeath_Certificate" runat="server" style="display:none"></asp:CheckBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDischarge_Slip" runat="server" Text="Discharge Slip"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:CheckBox ID="cbDicharg_Slip" runat="server"></asp:CheckBox>
                                                </td>
                                                <td>                                                 
                                                    <asp:CheckBox ID="chkDischargeMedication" runat="server" Style="display: none" />
                                                </td>                                                
                                            </tr>
                                            <tr>
                                                <td><input type="button" id="btnDischargePrint" value="Discharge Print" name="name" onclick="    PrintInpatientReceipt();" style="width: 120px;" /></td>
                                            </tr>
                                        </table>
                                    </td>
                                    <td>
                                        <table style="width: 100px; margin-top: -55px !important;">
                                            <tr>
                                                <td style="width: 72px;">
                                                    <asp:Label ID="Label20" runat="server" Text="Lab Result"></asp:Label>
                                                </td>
                                                <td>
                                                    <asp:DropDownList ID="ddlLabResult" runat="server" Width="167px" AppendDataBoundItems="true" Style="width: 74px !important;"></asp:DropDownList>
                                                </td>
                                                <td>
                                                    <input id="btnlabrpt" type="button" value="Add" onclick="InsertLabResult()" style="width: 57px; margin-left: -68px; height: 30px;"></input></td>
                                            </tr>
                                            <tr>
                                                <td colspan="2">
                                                    <div id="Div6" style="height: 207px; margin-left: -21px; width: 335px; overflow: scroll;">
                                                        <table class="table" id="tblResultrpt" style="width: 317px;">
                                                            <thead>
                                                                <tr>
                                                                    <th style="width: 80px;">Test Name </th>
                                                                    <th>Test Result </th>

                                                                    <th style="width: 53px;">Action</th>
                                                                </tr>
                                                            </thead>
                                                            <tbody>
                                                            </tbody>
                                                        </table>
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>

                            <table style="margin-left: -18px;">
                        
                                <tr>
                                    <td>
                                        <table class="table" id="tblDischargeNote" style="width: 1234px;">
                                            <thead>
                                                <tr>
                                                    <td colspan="12">
                                                        <div id="Div5">
                                                            <h2>Previous History</h2>
                                                        </div>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <th>Discharge By</th>
                                                    <th>Discharged Date</th>
                                                    <th>Advice</th>
                                                    <th>Digonises</th>
                                                    <th>Procedure Operation</th>
                                                    <th>Procedure Detail</th>
                                                    <th>Follow Up</th>
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
                  
                    <div id="Tab-7">
                        <div id="Mos_Observation">
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <h2>Doctor Note : </h2>
                                </div>
                            </div>
                             <div class="row">
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:Label ID="lblMo_Date" runat="server" Text="Date"></asp:Label>
                                     <asp:TextBox ID="txtMo_Date" runat="server" ReadOnly="true"></asp:TextBox>
                                 </div>
                                  <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:Label ID="lblMo_Doctor_Status" runat="server" Text="Doctor Designation"></asp:Label>
                                      <asp:DropDownList ID="ddlMO_Doctor_Status" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                 </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:Label ID="lblMo_Doctor_Name" runat="server" Text="Doctor Name"></asp:Label>
                                     <asp:DropDownList ID="ddlMo_Doctor_Name" runat="server"  AppendDataBoundItems="true"></asp:DropDownList>
                                     <asp:CheckBox ID="chkdoctor" runat="server" Style="display: none" />
                                     <asp:CheckBox ID="chkMedDoctor" runat="server" Style="display: none" />
                                 </div>
                                 <div class="col-lg-6 col-md-4 col-sm-6">
                                     <div class="row">
                                   <div class="col-lg-3 col-md-4 col-sm-6">
                                     <input id="btnMO_Investigation" type="button" value="Investigation" class="btn btn-primry MarTop" onclick="GetInvestigationTab()" ></input>
                                 </div>
                                    <div class="col-lg-3 col-md-4 col-sm-6">
                                        <input id="btnAdd" type="button" value="Add" class="btn btn-primry MarTop" onclick="InsertDoctorNote()"></input>                                       
                                        </div>
                                         <div class="col-lg-3 col-md-4 col-sm-6">
                                             <input type="button" id="btnProgressNote" class="btn btn-primry MarTop" value="Print" onclick="ProgressNote()";  />
                                             </div>
                                         <div class="col-lg-3 col-md-4 col-sm-6">
                                         <input id="btnMO_Medicine" type="button" value="Medicine" onclick="GetLastMediceineTab()" class="MarTop"></input>
                                         </div>
                                     </div>
                                 </div>
                            </div>

                            <div>
                                <div class="row">
                                    <div class="col-lg-6 col-md-4 col-sm-6">
                                        <h2>Progress Note</h2>
                                        <asp:TextBox ID="txtMo_Progress_Note" runat="server" TextMode="Multiline" Style="height: 160px;"></asp:TextBox>
                                    </div>
                                    <div class="col-lg-6 col-md-4 col-sm-6">
                                        <h2>Instruction</h2>
                                        <asp:TextBox ID="txtMo_Instruction" runat="server" TextMode="Multiline" Style="height: 160px;width:100%;"></asp:TextBox>
                                    </div>
                                </div>
                            </div>

                            <div style="overflow: scroll; height: 210px;margin-left:-5px">
                                <table id="tblDOctorNotes" class="table">
                                    <thead>
                                        <tr style="position: sticky; top: 0; z-index: 10;">
                                            <th style="width: 158px">Date</th>
                                            <th style="width: 110px;">Doctor Designation</th>
                                            <th style="width: 135px">Doctor Name</th>
                                            <th>Progress Note</th>
                                            <th>Instruction</th>
                                            <th style="width: 31px">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>


                            <div style="overflow: scroll; height: 265px;margin-left:-5px">
                                <table class="table" id="tblDoctorNoteHistroy">
                                    <thead>
                                        <tr>
                                            <td colspan="12">
                                                <div id="Div4">
                                                    <h2 class="color">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th style="width: 158px">Date</th>
                                            <th style="width: 110px;">Doctor Status</th>
                                            <th style="width: 135px">Doctor Name</th>
                                            <th>Progress Note</th>
                                            <th>Instruction</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <div id="Tab-8">
                        <h2>Presenting Complaints : </h2>
                        <div id="Patientdetail" style="width: 100%">
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-sm-12" id="tr-heading">
                                    <label>Symptom</label>
                                    <input type="text" name="txtSymtom" id="txtSymtom"  />
                                    </div>
                                <div class="col-lg-1 col-md-4 col-sm-12">
                                    <label>Duration</label>
                                    <input type="text" name="txtDuration" id="txtDuration"  />
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-12">
                                    <select id="ddlDaysMonthsYears" style="margin-top:21%" ></select>
                                    </div>
                                <div class="col-lg-2 col-md-4 col-sm-12">
                                    <label>Remarks</label>
                                     <textarea name="txtRemarks" id="txtRemarks" style="width: 100% !important; height: 36px;"></textarea>                                    
                                </div>
                                <div class="col-lg-1 col-md-6 col-sm-12">
                                    <input type="button" id="btnAddHistory" class="btn btn-primry" onclick="Add_SymtomRow()" value="Add" style="margin-top:21%" />
                                    </div>
                                <div class="col-lg-5 col-md-6 col-sm-12">
                                    <div id="dvtblSymtomps">
                                        <table class="table" id="tblSymtoms">
                                            <thead>
                                                <tr>
                                                    <th style="display: none;">Row ID</th>
                                                    <th style="display: none;">Symtom ID</th>
                                                    <th style="width: 248px !important;">Symptom </th>
                                                    <th style="width: 19px !important;">Dur </th>
                                                    <th style="width: 50px !important;">D/M/Y</th>
                                                    <th style="width: 100px !important;">Remarks </th>
                                                    <th style="width: 50px !important;">Edit</th>
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
                                    <div>
                                        <a href="javascript:void(0)" onclick="new_value()" style="text-decoration: underline; color: #438eb9 ; font-size: 20px;">Add New <i class="fa fa-plus" style="margin-left: 5px;"></i></a>
                                    </div>
                                </div>
                                </div>
                            <div>
                                <div id="Div2">
                                    <input type="text" id="txtNewSymptom" style="width: 200px !important; display: none" />
                                    <input type="button" id="btnaddsym" class="btn btn-primry" onclick="SymptomInsert()" style="width:7% !important;display: none" value="Save" />
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
                            
                            <table style=" margin-top: 13px;width:100%" id="tblHistory ">
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
                                        <asp:TextBox ID="txtHistoryOfPeresentIllness" TextMode="MultiLine" runat="server" TabIndex="1" class="todolist"></asp:TextBox>
                                    </td>
                                     <td colspan="2">
                                        <asp:Label ID="Label40" runat="server" Text="Vaccination History "></asp:Label>
                                         <asp:TextBox ID="txtVaccinationHistory" runat="server" TextMode="MultiLine" TabIndex="10" class="todolist"></asp:TextBox>
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
                                        <asp:TextBox ID="txtHistoryOfPastIllness" runat="server" TextMode="MultiLine" TabIndex="2" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label41" runat="server" Text="Any Other History "></asp:Label>
                                        <asp:TextBox ID="txtAnyOtherHistory" runat="server" TextMode="MultiLine" TabIndex="10" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label3" runat="server" Text="Family History"></asp:Label>
                                        <asp:TextBox ID="txtHistoryOfFamily" runat="server" TextMode="MultiLine" TabIndex="3" class="todolist"></asp:TextBox>
                                    </td>
                                </tr>

                                <tr>
                                    <td colspan="2">
                                        <asp:Label ID="Label5" runat="server" Text="SocioEconomic History"></asp:Label>
                                        <asp:TextBox ID="txtSocioEconomicHistory" runat="server" TextMode="MultiLine" TabIndex="4" class="todolist"></asp:TextBox>
                                    </td>   
                                    <td  colspan="2">
                                        <asp:Label ID="Label15" runat="server" Text="Birth History"></asp:Label>
                                        <asp:TextBox ID="txtBirthHistory" runat="server" TextMode="MultiLine" TabIndex="5" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label8" runat="server" Text="Drug History"></asp:Label>
                                        <asp:TextBox ID="txtDrugHistory" runat="server" TextMode="MultiLine" TabIndex="6" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label17" runat="server" Text="Personal History"></asp:Label>
                                        <asp:TextBox ID="txtPersonalHistory" runat="server" TextMode="MultiLine" TabIndex="7" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="Label7" runat="server" Text="Obstetric History"></asp:Label>
                                        <asp:TextBox ID="txtObstetricHistory" runat="server" TextMode="MultiLine" TabIndex="7" class="todolist"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <asp:Label ID="Label9" runat="server" Text="Allergies History"></asp:Label>
                                        <asp:TextBox ID="txtAllergiesHistory" runat="server" TextMode="MultiLine" TabIndex="9" class="todolist"></asp:TextBox>
                                    </td>
                                    <td colspan="2">
                                        <asp:Label ID="lblProvisionalDiagnosis" Text="Provisional Diagnosis" runat="server"></asp:Label>
                                        <asp:TextBox runat="server" ID="txtProvisionalDiagnosis" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td colspan="4">
                                        <asp:Label ID="Label11" runat="server" Text="Treatment History"></asp:Label>
                                        <asp:TextBox ID="txtTreatmentHistory" runat="server" TextMode="MultiLine" TabIndex="10" Style="width:97%" class="todolist"></asp:TextBox>
                                    </td>
                                    <td style="padding-left:3%">
                                        <input type="button" id="btnAddPrint" class="btn btn-primry" onclick="AddPrint()" value="Print" style="width: 40% !important" />
                                    </td>
                                </tr>
                            </table>
                          
                            <div>
                                <table class="table" style="margin-left:-5px" id="tblHistoryTabHistory" >
                                    <thead>
                                        <tr>
                                            <td colspan="26">
                                                <div id="tblHistoryTabHistoryHeader">
                                                    <h2 class="color">Previous History</h2>
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
                           
                         
                            <table class="table">
                                <tr>
                                    <td>
                                      <div id="dvSyptomHistory" style="overflow:scroll;height: 211px;margin-left:-11px">
                                <table class="table" id="tblSymptomHistory">
                                    <thead>
                                        <tr>
                                            <td colspan="6">
                                                <div id="Div8">
                                                    <h2 class="color">Symptom History</h2>
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

                    <div id="Tab-6">
                        <div class="row">
                            <div class="col-lg-4 col-md-6 col-sm-12">                               
                                <h2>Main Tests Department : </h2>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-2 col-md-6 col-sm-12" style="margin-top:-6px">
                                <label>Select Main Department</label>
                                <select id="ddlMainTestDepartment" onchange="LoadTestByDepartment()" >
                                    <option value="">Select Department</option>
                                </select>
                            </div>
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                <label></label>
                                <select id="ddlTestList" >
                                </select>
                            </div>
                             <div class="col-lg-2 col-md-6 col-sm-12">
                                 <asp:Label ID="LblDesignation" runat="server" Text="Doctor Designation"></asp:Label>
                                  <asp:DropDownList ID="DocStatus" runat="server"  AppendDataBoundItems="true"></asp:DropDownList>
                            </div>
                             <div class="col-lg-2 col-md-6 col-sm-12">
                                  <asp:Label ID="LblDocName" runat="server" Text="Doctor Name"></asp:Label>
                                 <asp:DropDownList ID="DdlDocName" runat="server"  AppendDataBoundItems="true" ></asp:DropDownList>
                            </div>
                            <div class="col-lg-4 col-md-6 col-sm-12" style="margin-top:-6px">
                                 <label>Area Of Interest</label>
                                <asp:TextBox ID="txtAreaOfInterest" runat="server" style="width:98% !important;height:33px !important;" TextMode="MultiLine"></asp:TextBox>
                            </div>
                            </div>
                        <div class="row">
                               <div class="col-lg-2 col-md-6 col-sm-12" >
                                 <input type="button" class="btn btn-primry" value="Add Test" id="btnAddAllTest" onclick="AddAllTest();"  />
                            </div>
                            
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                <div id="divRotation" style="display: none">
                                    <select id="ddlRotation" style="display: none; width: 200px">
                                    </select>
                                </div>
                                <div id="divX_Ray">
                                    <select id="ddlXRayLF" style="display: none; width: 73px !important; margin-left: 101px; margin-top: -28px; height: 28px;">
                                        <option value="0"></option>
                                        <option value="L">Left</option>
                                        <option value="R">Right</option>
                                    </select>
                            </div>
                        </div>
                            </div>
          
                               
                                                  
                    <div >
                        <table class="table tests-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Test Name</th>
                                    <th>Sample Received</th>
                                    <th>Test Status</th>                                 
                                    <th>Area Of Interest</th>
                                    <th>Doctor Name</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="loadtest"></tbody>
                        </table>

                    </div>
                    <div style="overflow:scroll;height:300px;margin-left:-9px">
                        <table class="table" id="dvHistoryTests">
                            <tr >
                                <td>
                                    <table class="table" id="tblHistoryTests" >
                                        <thead>
                                            <tr style="position: sticky; top: 0;z-index: 10;">
                                                <td colspan="12">
                                                    <div id="HeaderTests">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr style="position: sticky; top: 65px; z-index: 10;">
                                                <th>Date</th>
                                               <th>Status</th>
                                                <th>Test Name</th>
                                                <th>Sample Received</th>
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

                    <div id="Tab-14">
                        <h2> Services / Procedures</h2>
                        <div>
                            <table>
                                <tbody>
                                    <tr>
                                        <td style="width: 225px !important;">
                                            <input type="text" id="txtService" name="txtService" runat="server" />
                                        </td>
                                        <td>
                                            <input type="button" id="btnAddService" class="btn btn-primry" name="btnAddService" onclick="AddServiceOrItem()" value="Add Service" style="top: 3px; left: 20px;" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>

                          <div style="overflow: scroll; height: 250px !important; height: auto;">
                <table class="table" style="height: auto; overflow: scroll;" id="tblServices">
                    <thead>
                        <tr style="position: sticky; top: 0px; z-index: 10;">
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
                           
            <div style="overflow: scroll; height: 250px !important; height: auto;">
                <table class="table" id="tblServicesHistory">
                    <thead>
                        <tr style="position: sticky; top: 0;z-index: 10;">
                            <td colspan="12">
                                <div id="ServicesHistoryHeader">
                                    <h2 class="color">Previous History</h2>
                                </div>
                            </td>
                        </tr>
                        <tr style="position: sticky; top: 70px; z-index: 10;">                            
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

                    <div id="Tab-13">
                        <h2>Examination Details : </h2>
                        <div class="row">
                          <div class="col-lg-4 col-md-4 col-sm-6">
                             
                                    <table class="table table-bordered"  id="Examdetails" style="width: 100%;border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td colspan="3">
                                            <h2>General Physical Examination:</h2>
                                        </td>
                                    </tr>
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
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblPallor" runat="server" Text="Pallor"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label90" for="ctl00_MainContent_Pallor1" runat="server" title="True"  style="vertical-align: middle;" >Y</label>
                                            <input type="radio" id="Pallor1" runat="server" name="Pallor" value="True"  style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label91" for="ctl00_MainContent_Pallor2" runat="server" title="False"  style="vertical-align: middle;" >N</label>
                                            <input type="radio" id="Pallor2" runat="server" name="Pallor" value="False"  style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblDehydration" runat="server" Text="Dehydration"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label92" for="ctl00_MainContent_Dehydration1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Dehydration1" runat="server" name="Dehydration" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label93" for="ctl00_MainContent_Dehydration2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Dehydration2" runat="server" name="Dehydration" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblGCSOrientation" runat="server" Text="GCS Oriented"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label94" for="ctl00_MainContent_GCSOrientation1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="GCSOrientation1" runat="server" name="GCSOrientation" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label95" for="ctl00_MainContent_GCSOrientation2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="GCSOrientation2" runat="server" name="GCSOrientation" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblConsciousOrientely" runat="server" Text="Conscious / Orientely"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label96" for="ctl00_MainContent_ConsciousOrientely1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="ConsciousOrientely1" runat="server" name="ConsciousOrientely" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label97" for="ctl00_MainContent_ConsciousOrientely2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="ConsciousOrientely2" runat="server" name="ConsciousOrientely" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label129" runat="server" Text="JVP"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label130" for="JVP1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="JVP1" runat="server" name="JVP" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label131" for="JVP2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="JVP2" runat="server" name="JVP" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label126" runat="server" Text="Edema"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label127" for="Edema1" runat="server"  style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Edema1" runat="server" name="Edema" value="True"  style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label128" for="Edema2" runat="server"  style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Edema2" runat="server" name="Edema" value="False"  style="vertical-align: middle;" />
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label132" runat="server" Text="Cyanosis"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label133" for="Cyanosis1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Cyanosis1" runat="server" name="Cyanosis" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label134" for="Cyanosis" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="Cyanosis2" runat="server" name="Cyanosis" value="False" style="vertical-align: middle;" />
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                            <asp:TextBox ID="TextBoxGpe" runat="server" TextMode="MultiLine" Class="todolist" Style="margin-left: 1%;"></asp:TextBox>
                                        </td>
                                    </tr> 
                                      
                                </table>
                            </div>  
                             <div class="col-lg-4 col-md-4 col-sm-6">
                                              <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td colspan="3">
                                            <h2>GCS:</h2>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="Label2" runat="server" Text="Eye Opening Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
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
                                            <asp:Label ID="Label4" runat="server" Text="Motor Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
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
                                            <asp:Label ID="Label6" runat="server" Text="Verbal Response" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtVR" runat="server" TabIndex="3" onchange="VRFunction()" Style="width: 100%;"></asp:TextBox>
                                        </td>
                                        <td style="text-align: center;">
                                           
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
                                            <label for="ctl00_MainContent_CranialNerves1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="CranialNerves1" runat="server" name="CranialNerves" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_CranialNerves2" runat="server" style="vertical-align: middle;"  title="False">N</label>
                                            <input type="radio" id="CranialNerves2" runat="server" name="CranialNerves" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label runat="server" ID="lblSignsOfMeningism" Text="Signs Of Meningism" Style="display: block; font-weight: bold; margin-bottom: 5px;"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_SignsOfMeningism1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="SignsOfMeningism1" runat="server" name="SignsOfMeningism" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_SignsOfMeningism2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                            <input type="radio" id="SignsOfMeningism2" runat="server" name="SignsOfMeningism" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:TextBox runat="server" ID="txtFurtherExplanation" TextMode="MultiLine" Style="margin-left:1%;height:95px"></asp:TextBox>
                                        </td>
                                    </tr>
                                </table>
                                    </div>
                            <div class="col-lg-4 col-md-4 col-sm-6">
                                    <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td>
                                            <h2>CNS</h2>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:label runat="server" ID="lblHMFIntact" Text="HMF Intact"></asp:label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label for="ctl00_MainContent_HMFIntact1" style="vertical-align: middle;" title="True">Y</label>
                                             <input type="radio" id="HMFIntact1" runat="server" name="HMFIntact" value="True" style="vertical-align: middle;" />                                           
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label1"  for="ctl00_MainContent_HMFIntact2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" runat="server" id="HMFIntact2"  name="HMFIntact" value="False" style="vertical-align: middle;" />                                            
                                             
                                       </td>                                      
                                    </tr>
                                     <tr>
                                        <td  colspan="3">                                          
                                             <asp:TextBox ID="TextBoxCns" runat="server" TextMode="MultiLine" style="margin-left:1%" ></asp:TextBox> </td>
                                    </tr>
                                        </table>
                                   <div class="row">
                                    <div class="col-lg-12 col-md-4 col-sm-6">
                                        <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <%--Power--%>
                                    <tr>
                                      <td><h2>Power:</h2></td>
                                    </tr>
                                    <tr>
                                        <td style="width:25% !important" >
                                             <asp:label runat="server" ID="Label1upperL" Text="Upper Limbs"></asp:label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            R&nbsp&nbsp<asp:TextBox ID="TxtR_Upper" runat="server" Class="Wid" ></asp:TextBox>
                                        </td>
                                        <td>
                                            <asp:Label runat="server" ID="Label108" Text=""></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">L&nbsp&nbsp<asp:TextBox ID="TxtL_Upper" runat="server" Class="Wid" ></asp:TextBox>
                                        </td>
                                    </tr>
                                     <tr>
                                        <td >
                                           <asp:label runat="server" ID="Label109" Text="Lower Limbs"></asp:label>
                                        </td>
                                        <td style="white-space: nowrap;">
                                            R&nbsp&nbsp<asp:TextBox ID="TxtR_Lower" runat="server"  Class="Wid" ></asp:TextBox>
                                        </td>
                                         <td>
                                             <asp:Label runat="server" ID="Label110" Text=""></asp:Label>
                                         </td>
                                         <td style="white-space: nowrap;">L&nbsp&nbsp
                                             <asp:TextBox ID="TxtL_Lower" runat="server" Class="Wid" ></asp:TextBox>
                                         </td>
                                    </tr>
                                            <tr>
                                                 <td>
                                            <div style="margin-bottom: 51px !important;"></div>
                                                             </td>
                                            </tr>
                                            </table>
                                        </div>
                                  
                                </div>
                                    </div>
                              
                           </div>
                           
                          <div class="row">
                               <div class="col-lg-4 col-md-4 col-sm-6">
                                   <table  class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                  
                                    <tr>
                                        <td><h2>GIT:</h2></td>
                                    </tr>
                                    <tr>
                                        <td >
                                           <asp:label ID="lblAbdomenSoft" runat="server" Text="Abdomen Soft"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label69"  for="ctl00_MainContent_AbdomenSoft1" style="vertical-align: middle;" runat="server" title="True">Y</label>
                                            <input type="radio" id="AbdomenSoft1" runat="server" name="AbdomenSoft" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label70"  for="ctl00_MainContent_AbdomenSoft2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="AbdomenSoft2" runat="server" name="AbdomenSoft"  value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td >
                                           <asp:label ID="lblTenderness" runat="server" Text="Tenderness"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label71" for="ctl00_MainContent_Tenderness1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Tenderness1" runat="server" name="Tenderness" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label72" for="ctl00_MainContent_Tenderness2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="Tenderness2" runat="server" name="Tenderness" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                     <tr>
                                        <td >
                                           <asp:label ID="lblGuarding" runat="server" Text="Guarding"></asp:label>
                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label73" for="ctl00_MainContent_Guarding1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Guarding1" runat="server" name="Guarding" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label74" for="ctl00_MainContent_Guarding2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="Guarding2" runat="server" name="Guarding" value="False" style="vertical-align: middle;" />
                                             
                                        </td>
                                    </tr>
        
                                     <tr>
                                        <td >
                                           <asp:label ID="lblBowelSound" runat="server" Text="Bowel Sound"></asp:label>
                                        </td>                                       
                                          <td style="white-space: nowrap;">
                                              <label id="Label75" for="ctl00_MainContent_BowelSound1" runat="server" title="True">Y</label>
                                            <input type="radio" id="BowelSound1" runat="server" name="BowelSound" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label id="Label76" for="ctl00_MainContent_BowelSound2" runat="server" title="False">N</label>
                                             <input type="radio" id="BowelSound2" runat="server" name="BowelSound" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
          
                                    <tr>
                                        <td >
                                           <asp:label ID="lblDistention" runat="server" Text="Distention"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label77" for="ctl00_MainContent_Distention1" runat="server"  style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Distention1" runat="server" name="Distention" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label78" for="ctl00_MainContent_Distention2" runat="server"  style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="Distention2" runat="server" name="Distention" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                   
                                     <tr>
                                        <td >
                                           <asp:label ID="lblFluidThrill" runat="server" Text="Fluid Thrill"></asp:label>
                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label79" for="ctl00_MainContent_FluidThrill1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="FluidThrill1" runat="server" name="FluidThrill" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label80" for="ctl00_MainContent_FluidThrill2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="FluidThrill2" runat="server" name="FluidThrill" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                 
                                     <tr>
                                        <td >
                                           <asp:label ID="lblShiftingDullness" runat="server" Text="Shifting Dullness"></asp:label>
                                        </td>                                       
                                          <td style="white-space: nowrap;">
                                              <label id="Label81" for="ctl00_MainContent_ShiftingDullness1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="ShiftingDullness1" runat="server" name="ShiftingDullness" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label82" for="ctl00_MainContent_ShiftingDullness2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="ShiftingDullness2" runat="server" name="ShiftingDullness" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                   
                                     <tr>
                                        <td >
                                           <asp:label ID="lblEpigastriaDiscomfort" runat="server" Text="Epigastria Discomfort"></asp:label>
                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label83" for="ctl00_MainContent_EpigastriaDiscomfort1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input id="EpigastriaDiscomfort1" type="radio" runat="server" name="EpigastriaDiscomfort" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label84" for="ctl00_MainContent_EpigastriaDiscomfort2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input id="EpigastriaDiscomfort2" type="radio"  runat="server" name="EpigastriaDiscomfort" value="False" style="vertical-align: middle;" />
                                             
                                       </td>
                                    </tr>
                                     <tr>
                                        <td >
                                           <asp:label ID="lblRetrosternalBurning" runat="server" Text="Retrosternal Burning"></asp:label>
                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label85" for="ctl00_MainContent_RetrosternalBurning1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="RetrosternalBurning1" runat="server" name="RetrosternalBurning"  value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label86" for="ctl00_MainContent_RetrosternalBurning2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="RetrosternalBurning2" runat="server" name="RetrosternalBurning" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                         <tr>
                                        <td >
                                            <div style="margin-bottom:7px" ></div>
                                        </td>
                                    </tr>
                                     <tr>
                                        <td colspan="3"> <asp:TextBox ID="TextBoxGit" runat="server" TextMode="MultiLine" Style="margin-left:2%;height:130px"></asp:TextBox> </td>                                     
                                    </tr>
                                    <tr>
                                       <td>
                                           <label id="lblProExamination">Provisional Diagnosis</label></td>
                                    </tr>
                                    <tr> <td colspan="3"> <asp:TextBox ID="txtProDiagExami" runat="server" TextMode="MultiLine" Style="margin-left:2%;height:154px"></asp:TextBox> </td>
                                        </tr>
                          
                            </table>
                         </div>
                               <div class="col-lg-4 col-md-4 col-sm-6">
                                    <table  class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td><h2>CVS:</h2></td>
                                    </tr>
                                     <tr>
                                        <td >
                                            <asp:label runat="server" ID="lblHeartSound" Text="Heart Sound"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label38" for="ctl00_MainContent_HeartSound1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="HeartSound1" runat="server" name= "HeartSound" style="vertical-align: middle;" value="True"  />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label39" for="ctl00_MainContent_HeartSound2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="HeartSound2" runat="server" name= "HeartSound" style="vertical-align: middle;" value="False"  />
                                        </td>
                                    </tr>
                                    
                                     <tr>
                                        <td >
                                            <asp:label runat="server" ID="lblArrhythmias" Text="Arrhythmias"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label42"  for="ctl00_MainContent_Arrhythmias1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Arrhythmias1" runat="server" name= "Arrhythmias" style="vertical-align: middle;" value="True" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label44" for="ctl00_MainContent_Arrhythmias2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="Arrhythmias2" runat="server" name= "Arrhythmias" style="vertical-align: middle;" value="False" />
                                        </td>
                                    </tr>
                                
                                     <tr>
                                        <td>
                                            <asp:label runat="server" ID="lblMurmur" Text="Murmur"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label45" for="ctl00_MainContent_Murmur1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="Murmur1" runat="server" name= "Murmur" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label46" for="ctl00_MainContent_Murmur2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="Murmur2" runat="server" name= "Murmur" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                  
                                     <tr>
                                        <td >
                                            <asp:label runat="server" ID="lblAnyOtherAddedSound" Text="Any Other Added Sound"></asp:label>
                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label47" for="ctl00_MainContent_AnyOtherAddedSound1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="AnyOtherAddedSound1" runat="server" name= "AnyOtherAddedSound" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label48" for="ctl00_MainContent_AnyOtherAddedSound2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="AnyOtherAddedSound2" runat="server" name= "AnyOtherAddedSound" value="False" style="vertical-align: middle;" />
                                        </td>
                                   </tr>
                                 
                                    <tr>
                                        <td >
                                            <asp:label runat="server" ID="lblAnyOtherFindings" Text="Any Other Findings"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label49" for="ctl00_MainContent_AnyOtherFindings1" runat="server" style="vertical-align: middle;" title="True">Y</label>
                                            <input type="radio" id="AnyOtherFindings1" runat="server" name= "AnyOtherFindings" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label50" for="ctl00_MainContent_AnyOtherFindings2" runat="server" style="vertical-align: middle;" title="False">N</label>
                                             <input type="radio" id="AnyOtherFindings2" runat="server" name= "AnyOtherFindings" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                      <tr>
                                        <td colspan="3"> <asp:TextBox ID="TextBoxCvs" runat="server" TextMode="MultiLine" Style="margin-left:1%;height:140px" ></asp:TextBox> </td>
                                    </tr>
                                                    </table>


                                   <div class="row">
                                       <div class="col-lg-12 col-md-12">
                                            <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                                <tr>
                                                    <td>
                                                        <h2>Sensory:</h2>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label runat="server" ID="Label111" Text="Upper Limbs"></asp:Label>
                                                    </td>
                                                    <td class="pad">
                                                        <asp:Label ID="Label122" runat="server" Text="R"></asp:Label>
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label112" for="SUL_RY" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                                        <input type="radio" id="SUL_RY" runat="server" name="SUL_RY" value="True" style="vertical-align: middle;" />                                                       
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label113" for="SUL_RN" runat="server" title="True" style="vertical-align: middle;">N</label>
                                                        <input type="radio" id="SUL_RN" runat="server" name="SUL_RY" value="False" style="vertical-align: middle;" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td class="pad">
                                                        <asp:Label ID="Label123" runat="server" Text="L"></asp:Label>
                                                    </td>
                                                    <td style="white-space: nowrap;">   
                                                        <label id="Label114" for="SUL_LY" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                                        <input type="radio" id="SUL_LY" runat="server" name="SUL_LY" value="True" style="vertical-align: middle;" />
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label115" for="SUL_LN" runat="server" title="True" style="vertical-align: middle;">N</label>
                                                        <input type="radio" id="SUL_LN" runat="server" name="SUL_LY" value="False" style="vertical-align: middle;" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td  >
                                                        <asp:Label runat="server" ID="Label116" Text="Lower Limbs"></asp:Label>
                                                    </td>
                                                    <td class="pad">
                                                        <asp:Label ID="Label124" runat="server" Text="R"></asp:Label>
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label117" for="SLL_RY" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                                        <input type="radio" id="SLL_RY" runat="server" name="SLL_RY" value="True" style="vertical-align: middle;" />
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label118" for="SLL_RN" runat="server" title="True" style="vertical-align: middle;">N</label>
                                                        <input type="radio" id="SLL_RN" runat="server" name="SLL_RY" value="False" style="vertical-align: middle;" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td></td>
                                                    <td class="pad">
                                                    <asp:Label ID="Label125" runat="server" Text="L"></asp:Label>
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label119" for="SLL_LY" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                                        <input type="radio" id="SLL_LY" runat="server" name="SLL_LY" value="True" style="vertical-align: middle;" />
                                                    </td>
                                                    <td style="white-space: nowrap;">
                                                        <label id="Label120" for="SLL_LN" runat="server" title="True" style="vertical-align: middle;">N</label>
                                                        <input type="radio" id="SLL_LN" runat="server" name="SLL_LY" value="False" style="vertical-align: middle;" />
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td>
                                                        <asp:Label runat="server" ID="Label121" Text="Torso/Trunk :"></asp:Label></td>
                                                </tr>
                                                <tr>
                                                    <td colspan="4">
                                                        <asp:TextBox ID="txtTorsoTruck" runat="server" TextMode="MultiLine" Style="margin-left:1%" ></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>
                                       </div>
                                   </div>
                                 </div>
                              
                               <div class="col-lg-4 col-md-4 col-sm-6">
                                   <table class="table table-bordered" style="width: 100%; border: 1px solid #ccc; margin-top: 10px;">
                                    <tr>
                                        <td><h2>RESP:</h2></td>
                                    </tr>
                                    <%-- NVB starts--%>
                                    <tr>
                                        <td>
                                            <asp:label runat="server" ID="lblNVB" Text="NVB"></asp:label>
                                        </td>   
                                        <td>
                                        <asp:label ID="Label51"  runat="server" Text="R"></asp:label> 
                                        </td>
                                        <td style="white-space: nowrap;">
                                             <label id="Label52" for="ctl00_MainContent_NVB_Right1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="NVB_Right1" runat="server" name="NVB_Right" value="True" style="vertical-align: middle;" />                                          
                                        </td>

                                        <td style="white-space: nowrap;">
                                            <label id="Label53" for="ctl00_MainContent_NVB_Right2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                             <input type="radio" id="NVB_Right2" runat="server" name="NVB_Right" value="False" style="vertical-align: middle;" />
                                             
                                        </td>                                                                             
                                    </tr>
                                    <tr>
                                        <td>
                                            &nbsp;
                                        </td>
                                        <td>
                                            <asp:label ID="Label54" runat="server" Text="L"></asp:label>
                                        </td>
                                         <td style="white-space: nowrap;">                                                                                      
                                            <label id="Label55" for="ctl00_MainContent_NVB_Left1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                             <input type="radio" id="NVB_Left1" runat="server" name="NVB_Left" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label56" for="ctl00_MainContent_NVB_Left2" runat="server" title="False" style="vertical-align: middle;" >N</label>
                                             <input type="radio" id="NVB_Left2" runat="server" name="NVB_Left" value="False" style="vertical-align: middle;" />                                           
                                        </td>
                                    </tr>                                
                                    <tr>
                                        <td>
                                            <asp:label runat="server" ID="lblCrepitation" Text="Crepitation"></asp:label>
                                            &nbsp;
                                        </td>
                                        <td>
                                            <asp:Label ID="Label57" runat="server" Text="R"></asp:Label>
                                        </td>
                                        <td style="white-space: nowrap;">      
                                            <label id="Label58" for="ctl00_MainContent_Crepitation_Right1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Crepitation_Right1" runat="server" name="Crepitation_Right" value="True" style="vertical-align: middle;" />             
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label59" for="ctl00_MainContent_Crepitation_Right2" runat="server" title="False" style="vertical-align: middle;" >N</label>
                                             <input type="radio" id="Crepitation_Right2" runat="server" name="Crepitation_Right" value="False" style="vertical-align: middle;" />        
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>&nbsp;
                                        </td>
                                        <td>
                                            <asp:label ID="Label60" runat="server" Text="L"></asp:label>
                                        </td>
                                         <td  style="white-space: nowrap;">   
                                             <label id="Label61" for="ctl00_MainContent_Crepitation_Left1" runat="server" title="True" style="vertical-align: middle;" >Y</label>
                                            <input type="radio" id="Crepitation_Left1" runat="server" name="Crepitation_Left" value="True" style="vertical-align: middle;" />   
                                        </td>
                                        <td  style="white-space: nowrap;">
                                            <label id="Label62" for="ctl00_MainContent_Crepitation_Left2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                             <input type="radio" id="Crepitation_Left2" runat="server" name="Crepitation_Left" value="False" style="vertical-align: middle;" />    
                                        </td>
                                    </tr>
                                     <%-- Crepitation ends--%>
                                    <tr>
                                      
                                        <td >
                                           <asp:label ID="lblWheeze" runat="server" Text="Wheeze"></asp:label>
                                        </td>
                                          <td>

                                        </td>
                                         <td style="white-space: nowrap;">
                                             <label id="Label63" for="ctl00_MainContent_Wheeze1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="Wheeze1" runat="server" name= "Wheeze" value="True" style="vertical-align: middle;" />
                                            
                                        </td>
                                        <td style="white-space: nowrap;">
                                            <label id="Label64" for="ctl00_MainContent_Wheeze2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                             <input type="radio" id="Wheeze2" runat="server" name= "Wheeze" value="False" style="vertical-align: middle;" />                                          
                                        </td>
                                    </tr>
                                      <tr>
                                        <td>
                                           <asp:label ID="lblRanchi" runat="server" Text="Ranchi"></asp:label>
                                        </td>
                                            <td>

                                        </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label65" for="ctl00_MainContent_Ranchi1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                              <input type="radio" id="Ranchi1" runat="server" name="Ranchi" value="True" style="vertical-align: middle;" />                                      
                                          </td>
                                          <td style="white-space: nowrap;">
                                              <label id="Label66" for="ctl00_MainContent_Ranchi2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                              <input type="radio" id="Ranchi2" runat="server" name="Ranchi" value="False" style="vertical-align: middle;" />
                                          </td>
                                    </tr>
                                     <tr>
                                        <td>
                                           <asp:label ID="lblAnyOtherSound" runat="server" Text="Any Other Sound"></asp:label>
                                        </td>
                                         <td></td>
                                        <td  style="white-space: nowrap;">
                                            <label id="Label67" for="ctl00_MainContent_AnyOtherSound1" runat="server" title="True" style="vertical-align: middle;">Y</label>
                                            <input type="radio" id="AnyOtherSound1" runat="server" name="AnyOtherSound" value="True" style="vertical-align: middle;" />
                                        </td>
                                        <td  style="white-space: nowrap;">
                                            <label id="Label68"  for="ctl00_MainContent_AnyOtherSound2" runat="server" title="False" style="vertical-align: middle;">N</label>
                                             <input type="radio" id="AnyOtherSound2" runat="server" name="AnyOtherSound" value="False" style="vertical-align: middle;" />
                                        </td>
                                    </tr>
                                     <tr>
                                        <td colspan="4"> 
                                            <asp:TextBox ID="TextBoxResp" runat="server" TextMode="MultiLine" Style="margin-left:1%" ></asp:TextBox> </td>
                                    </tr>
                                   </table>
                               </div>
                              <div class="col-lg-1 col-md-4 col-sm-6" style="margin-top:18%">
                                  <input type="button" id="btnAdPrint" class="btn btn-primry" onclick="AdPrint()" value="Print" />
                              </div>
                          </div>
                       
                        <div>
                                <table class="table" id="tblExaminationHistory" style="display: block; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <td colspan="37">
                                                <div id="tblExaminationHistoryHeader" style="text-align:center;margin-left: -50%">
                                                    <h2 class="color">Previous History</h2>
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
                                            <th>Conscious / Orientely</th>
                                            <th>HMF Intact</th>                                            
                                            <th>Any Other Findings</th>
                                            <th>Any Other Sound</th>
                                            <th>Retrosternal Burning</th>
                                            <th>Torso/Trunk</th>
                                            <th>Provisional Diagnosis</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                    </div>
                
                    <div id="Tab-9" style="display: none;">
                        <div id="Nursing_Note" style="width: 90%">
                            <table>
                                <tr>
                                    <td>
                                        <h2>Nursing Note : </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <input type="button" value="In-Patient Monitering" onclick="GotoinPatientMoi();" />
                                    </td>
                                </tr>
                            </table>

                        </div>
                    </div>

                    <div id="Tab-11">    
                         <div id="Death_Details">
                             <div class="row">
                                 <div class="col-lg-4 col-md-6 col-sm-8">
                                     <h2>Death Details:</h2>
                                 </div>
                             </div>
                             <div class="row">
                                 <div class="col-lg-4 col-md-4 col-sm-6">
                                      <asp:label runat="server" ID="lblIdentificationMarks" Text="Identification Marks"></asp:label>
                                      <asp:TextBox runat="server" ID="txtIdentificationMarks" Style="width:100%;height:34px" TextMode="MultiLine"></asp:TextBox>
                                 </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:label runat="server" ID="lblDateofDeath" Text="Date Of Death"></asp:label>
                                      <asp:TextBox runat="server" ID="txtDateofDeath" ></asp:TextBox>
                                     </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:label runat="server" ID="lblPlaceOfDeath" Text="Place Of Death"></asp:label>
                                     <asp:DropDownList ID="ddlPlaceOfDeath" AppendDataBoundItems="true" runat="server" ></asp:DropDownList>
                                     </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:label runat="server" ID="lblCauseOfDeath" Text="Cause Of Death"></asp:label>
                                      <asp:TextBox ID="txtCause_Of_Death" runat="server" Style=""></asp:TextBox>
                                     </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:label runat="server" ID="lblTimeOfDeath" Text="Time Of Death"></asp:label>
                                     <asp:TextBox runat="server"  ID="txtTimeOfDeath"></asp:TextBox>
                                     </div>
                             </div>
                             <div class="row">
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lblIssuingOfficerName" Text="Issuing Officer Name"></asp:Label>
                                     <asp:TextBox runat="server" ID="txtIssuingOfficerName"></asp:TextBox>
                            </div>
                                  <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:Label runat="server" ID="lblDeathCertifiedBy1" Text="">Death Certified By 1 -</asp:Label>
                                      <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDeathCertifiedbyDr1" ></asp:DropDownList>
                                      </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lblDeathCertifiedBy2" Text="">2 -</asp:Label>
                                      <asp:DropDownList runat="server"  ID="ddlDeathCertifiedbyDr2" AppendDataBoundItems="true"></asp:DropDownList>
                                     </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lblBodyHandedOverTo" Text="Body Handed Over To"></asp:Label>
                                      <asp:TextBox runat="server" ID="txtBodyHandedOverTo"></asp:TextBox>
                                 </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:Label runat="server" ID="lblFamilyPersonName" Text="Family Person (Name)"></asp:Label>
                                      <asp:TextBox runat="server" ID="txtFamilyPersonName"></asp:TextBox>
                                     </div>
                                 <div class="col-lg-2 col-md-4 col-sm-6">
                                     <asp:Label runat="server" ID="lbl_CNIC" Text="CNIC"></asp:Label>
                                     <asp:TextBox runat="server" ID="txtCNIC"></asp:TextBox>
                                     </div>
                                 </div>
                             <div class="row">
                                  <div class="col-lg-2 col-md-4 col-sm-6">
                                      <asp:Label runat="server" ID="lblRelationWithDeceased" Text="Relation with Deceased"> </asp:Label>
                                      <asp:TextBox runat="server" ID="txtRelationWithDeceased"></asp:TextBox>
                                      </div>
                                 <div class="col-lg-4 col-md-4 col-sm-6">
                                      <asp:Label runat="server" ID="lblCMO_Police" Text="C.M.O / Police"></asp:Label>
                                     <asp:TextBox runat="server" ID="txtCMO_Police"></asp:TextBox>
                                     </div>
                                 <div class="col-lg-1 col-md-4 col-sm-6">
                                     <label></label>
                                 <input type="button" class="btn btn-primry" id="btnPrint" value="Print" onclick="PrintS();" />
                                 </div>
                             </div>
                         </div>
                    </div>
                    
                    <div id="Tab-12" style="height:auto;">
                        <div class="row">
                            <div class="col-lg-2 col-md-6 col-sm-8">
                                <h2>Refer:</h2>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label>Previous Dept.</label>
                                <input type="text" id="txtdprevDepart" disabled="disabled" />
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label>Previous Ward/Bed</label>
                                <input type="text" id="txtWardBed" disabled="disabled" />
                                </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label>Previous Room/Bed</label>
                                <input type="text" id="txtRoomBed" disabled="disabled" />
                                </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <asp:Label ID="lblreferto" runat="server" Text="Refer To *"></asp:Label>
                                <asp:UpdatePanel ID="UpdatePanel4" TabIndex="6" runat="server">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlReferTo" runat="server" Class="mmtop" AppendDataBoundItems="true" onChange="chkrefer_Of_Select()"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ControlToValidate="ddlReferTo"  InitialValue="0" runat="server" ErrorMessage="Select Refer To" Text="*"></asp:RequiredFieldValidator>
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
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <asp:Label ID="lblWards" runat="server" Text="Ward *"></asp:Label>
                                <asp:UpdatePanel ID="UpdatePanel15" TabIndex="7" runat="server" UpdateMode="Always">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlwards" Class="mmtop" runat="server" AppendDataBoundItems="true" OnChange="FillWardBedsRefer()" disabled="disabled"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                 <asp:Label ID="Label135" runat="server" Text="Bed No"></asp:Label>
                                 <asp:TextBox ID="txtBedno" TabIndex="8" runat="server" Class="mmtop" Enabled="true" ></asp:TextBox>
                                <asp:RangeValidator ID="RangeValidator1" Type="Integer" runat="server" MinimumValue="0" MaximumValue="999999999" ControlToValidate="txtBedno" ErrorMessage="Only Enter Integer Values" Text="*"></asp:RangeValidator>
                                </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                 <asp:Label ID="lblRoom" runat="server" Text="Room_No *"></asp:Label>
                                <asp:DropDownList ID="ddlroom" TabIndex="9" runat="server" AppendDataBoundItems="true" AutoPostBack="true" disabled="disabled"></asp:DropDownList>
                                </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <asp:Label ID="lblroomtype" runat="server" Text="Room Type"></asp:Label>
                                <asp:UpdatePanel ID="UpdatePanel16" TabIndex="10" runat="server">
                                    <ContentTemplate>
                                        <asp:DropDownList ID="ddlRoomType" runat="server" AppendDataBoundItems="true" AutoPostBack="true" onChange="FillRoomsRefer()"></asp:DropDownList>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </div>
                            <div class="col-lg-4 col-md-6 col-sm-8 no-scrollbar" style="overflow: scroll; height: 250px;">
                                <table id="tblBed" class="table">
                                    <thead>
                                        <tr style="position: sticky; top: 0;z-index: 10;">
                                            <th>MR No.</th>
                                            <th>Bed No</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>

                                <table id="tblRoom" class="table">
                                    <thead>
                                        <tr style="position: sticky; top: 0; z-index: 10;">
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

                    <div id="Tab-17">
                        <div class="row">
                            <div class="col-lg-3 col-md-6 col-sm-12">
                                <h2>Doctors Plan : </h2>
                            </div>
                        </div>
                        <asp:TextBox ID="txtDoctoNotes" runat="server" TextMode="MultiLine" Style="width: 800px; height: 216px;"></asp:TextBox>
                    </div>
                    <div id="Tab-18">
                        <div id="Infs_Order">
                            <table>
                                <tr>
                                    <td>
                                        <h2>IV Fluid Orders : </h2>
                                    </td>
                                </tr>
                            </table>

                            <div class="row">
                                <div class="col-md-2">
                                    <label>Infusion Type</label>
                                </div>
                                <div class="col-md-1">
                                    <input type="radio" id="chkIntermittent" style="margin-left: -15% !important" name="InfType" />
                                    Intermittent                 
                                </div>

                                <div class="col-md-1">
                                    <input type="radio" id="chkContinous" style="margin-left: -15% !important" name="InfType" />
                                    Continuous                 
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-8">
                                    <div class="row">
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Start Date</label>
                                            <input type="text" id="txtStartDate" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Start Time</label>
                                            <input type="text" id="txtStartTime" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Fluid Name</label>
                                            <select class="ddlInsFluid" id="ddl_InsFluid">
                                                <option></option>
                                            </select>
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Additive</label>
                                            <select class="ddladdtive" id="ddl_addtive">
                                                <option></option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Infusion Volume</label>
                                            <select class="ddlInsVol" id="ddl_InsVol">
                                                <option></option>
                                            </select>
                                        </div>

                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Additive Dose</label>
                                            <select class="ddladdtive" id="ddl_addtiveDose">
                                                <option></option>
                                            </select>
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Infusion Rate (ml/hour OR drop/min)</label>
                                            <input type="text" id="ddl_InsRate" class="ddlInsRate" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Site</label>
                                            <select class="ddlSides" id="ddlSides">
                                                <option></option>
                                            </select>
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label id="drinter">Duration</label>
                                            <input type="text" id="txtDurationInfusion" disabled="disabled" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6" id="StopField">
                                            <label>Stop Date</label>
                                            <input type="text" id="txtStopDateTime" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <label>Stop Time</label>
                                            <input type="text" id="txtStopTime" />
                                        </div>
                                        <div class="col-lg-3 col-md-4 col-sm-6">
                                            <div class="row">
                                                <div class="col-lg-6 col-md-4 col-sm-6">
                                                    <label></label>
                                                    <input type="button" id="btnAddinfs" onclick="AddInfusion()" class="btn btn-primry" value="Add" />
                                                </div>
                                                <div class="col-lg-6 col-md-4 col-sm-6">
                                                    <label></label>
                                                    <input type="button" id="btnAddiPrint" onclick="InfusionPrint()" class="btn btn-primry" value="Print" />
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="col-lg-4 col-md-4 col-sm-6">
                                    <table id="tblAdditive" class="table">
                                        <tr>
                                            <th>Additive</th>
                                            <th>Action</th>
                                        </tr>
                                    </table>
                                </div>
            <div class="col-md-1" style="display:none;">
                <label>Route</label>
            </div>
            <div class="col-md-2" style="display:none;">
                <select class="ddlroute" id="ddl_route">
                    <option></option></select>
            </div>

            <table class="table table-hover table-striped table-bordered" id="table_res" style="overflow: scroll; height: auto; margin-top: 20px;">
               <thead>
                    <tr id="row_sample">
                        <th>Date & Time</th>
                        <th>Infusion Type</th>
                        <th>Start Date & Time</th>
                        <th>Fluid Name</th>
                        <th>Infusion Volume</th>
                        <th>Infsuion Rate</th>
                        <th>Duration/Interval</th>
                        <th>Additive</th>
                        <th>Additive Dose</th>
                        <th style="display:none;">Route</th>
                        <th>Site</th>
                        <th>Stop Date & Time</th>
                        <th>User Name</th>
                        <th >Action</th>
                    </tr>
                </thead>
                <tbody id="t_body">
                </tbody>
            </table>
                            </div>
                        </div>
                      </div>

                    <div id="Tab-16">
                        <div class="row">
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                 <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDoctorClinicalSummary"></asp:DropDownList>
                            </div>
                        </div>
                         <div class="row">
                             <div class="col-lg-12 col-md-6 col-sm-12">
                              <h2>Clinical Notes : </h2>
                             <asp:TextBox ID="txtAreaClinicalNotes" runat="server" TextMode="MultiLine" Style="height:200px !important;width:100%" ></asp:TextBox>
                             </div>
                      </div>

                        <input type="button" id="btnBasePrint" class="btn btn-primry" value="Print" onclick="PrintConsultant();"style="width: 100px !important;margin-left:-5px" />
                          <table class="table" id="tblClinicalHistory" style="margin-left:-5px">
                                        <thead>
                                            <tr>
                                                <td colspan="14">
                                                    <div id="tblHistoryClinicalHeader">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                               <th>Date </th>
                                                <th>Clinical Summary</th>
                                                    <th>Doctor</th>                                            
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>


                    </div>

                    <div id="Tab-15">                                                            
                                   <table style="padding: 100px">
                                     <form id="item">
                                       <div class="row">
                                            <div class="col-lg-5 col-md-3 col-sm-4">
                                            <h2>Discharge Note: </h2>
                                           </div>
                                           </div>
                                         <div class="row">
                                          <div class="col-lg-3 col-md-6 col-sm-12">
                                          <asp:Label ID="Label98" runat="server" Text="Pulse Rate (Beats per Min)"></asp:Label>
                                         <asp:TextBox ID="txtPulseRate" runat="server" TabIndex="1"></asp:TextBox>
                                              </div>
                                          <div class="col-lg-3 col-md-6 col-sm-12">
                                       <asp:Label ID="Label99" runat="server" Text="Blood Pressure (120/80)"></asp:Label>
                                     <asp:TextBox ID="txtBPDischarge" runat="server" TabIndex="2"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label100" runat="server" Text="Rhythm"></asp:Label>
                                <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlRhythmdischarge"></asp:DropDownList>
                                             </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                              <asp:Label ID="Label101" runat="server" Text="Temperature (°F)"></asp:Label>
                                               <asp:TextBox ID="txtTempdisch" runat="server" TabIndex="3"></asp:TextBox>
                                             </div>
                                             </div>
                                         <div class="row">
                                             <div class="col-lg-3 col-md-3 col-sm-4">
                                                 <asp:Label ID="Label12" runat="server" Text="BSR (mg/dl)"></asp:Label>
                                                 <asp:TextBox ID="txtBSRDischarge" runat="server" TabIndex="1"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-3 col-sm-4">
                                                 <asp:Label ID="Label16" runat="server" Text="Weight (kg)"></asp:Label>
                                                 <asp:TextBox ID="txtWeightDischarge" runat="server" TabIndex="2" onchange="calculateBMIDisharge()"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-3 col-sm-4">
                                                 <asp:Label ID="Label18" runat="server" Text="Height (cm)"></asp:Label>
                                                 <asp:TextBox ID="txtHeightDischarge" runat="server" TabIndex="3" onchange="calculateBMIDisharge()"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-3 col-sm-4">
                                                 <asp:Label ID="Label87" runat="server" Text="BMI"></asp:Label>
                                                 <asp:TextBox ID="txtBMIDischarge" runat="server" TabIndex="3"></asp:TextBox>
                                             </div>
                                         </div>
                                         <div class="row">
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label104" runat="server" Text="O2 Saturation"></asp:Label>
                                                 <asp:TextBox ID="txtSaturation_Oxygen2_desc" runat="server" TabIndex="2"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                             <asp:Label ID="Label103" runat="server" Text="Respiration Rate (/min)"></asp:Label>
                                             <asp:TextBox ID="txtRespRateDesc" runat="server" TabIndex="4"></asp:TextBox>
                                            </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label102" runat="server" Text="Volume"></asp:Label>
                                                 <asp:DropDownList runat="server" ID="ddlvolumedisc" AppendDataBoundItems="true"></asp:DropDownList>
                                             </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label105" runat="server" Text="Others"></asp:Label>
                                                 <asp:TextBox ID="txtotherecdesc" runat="server" TabIndex="2"></asp:TextBox>
                                             </div>
                                             </div>
                                         <div class="row">
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label106" runat="server" Text=" Receiving Date & Time"></asp:Label>
                                                 <asp:TextBox ID="txttxtReceiving_DateDesc" runat="server" ReadOnly="true"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label107" runat="server" Text="Special Instruction"></asp:Label>
                                                 <asp:TextBox ID="txtRN_Special_Instruction_Desc" runat="server" TabIndex="9" TextMode="MultiLine" Style="height: 35px; width: 100%" onchange="FillInstruction()"></asp:TextBox>
                                             </div>
                                             <div class="col-lg-2 col-md-6 col-sm-12">
                                                 <label></label>
                                                 <asp:TextBox ID="txtsaturationDis" runat="server" TabIndex="2"></asp:TextBox>                                                
                                             </div>
                                             <div class="col-lg-1 col-md-1 col-sm-1">
                                                 <div class="flexx">
                                                     <label class="labl">On Room Air</label>
                                                     <asp:CheckBox runat="server" ID="chk_OnRoomAirDesc" Style="flex: 0 0 auto;" />
                                                 </div>
                                             </div>


                                             <div class="col-lg-2 col-md-3 col-sm-12">
                                                 <label></label>
                                                 <asp:TextBox ID="txtOxygen1" runat="server" TabIndex="2"></asp:TextBox>
                                             </div>

                                             <div class="col-lg-1 col-md-1 col-sm-1">
                                                 <div class="flexx">
                                                     <label for="chk_WithOxygenDesc" class="labl">With Oxygen</label>
                                                     <asp:CheckBox runat="server" ID="chk_WithOxygenDesc" Style="flex: 0 0 auto;" />
                                                 </div>
                                             </div>
                                         </div>
                                         <div class="row">
                                             <div class="col-lg-3 col-md-6 col-sm-12">
                                                 <asp:Label ID="Label10" runat="server" Text="Discharge Type"></asp:Label>
                                                 <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDischarge_Type"></asp:DropDownList>
                                             </div>
                                         </div>
                                         <div class="row">
                                             <div class="col-lg-8">
                                                 <div class="row">
                                                     <div class="col-lg-2 col-md-3 col-sm-12">
                                                         <input type="button" value="Add Medicine" class="btn btn-primry" id="btnDischarge" onclick="AddDischageMedication(this)" />
                                                     </div>
                                                     <div class="col-lg-2 col-md-3 col-sm-12">
                                                         <input type="button" id="btnprintVital" value="Print" class="btn btn-primry" onclick="PrintVitalMedicationDetail()" />
                                                     </div>
                                                     <div class="col-lg-2 col-md-3 col-sm-12">
                                                         <input type="button" id="btnDischargeRequest" value="Discharge Request" class="btn btn-primry" onclick="DischargeRequest()" />
                                                         <input type="hidden" runat="server" id="DischargeRequest" value='false'/>
                                                     </div>
                                                 </div>
                                             </div>
                                         </div>
                                           </form>

                        </table>
                                <tr>
                                    <td>
                                        <div style="overflow: scroll; height: 280px;">
                                            <table class="table" id="tblDischargeMedication">                                                                                           
                                                  <thead>
                                                       <tr style="position: sticky; top: 0;z-index: 10;">
                                                        <td colspan="12">
                                                            <div id="Div7">
                                                                <h2 class="color">Medication on Discharge</h2>
                                                            </div>
                                                        </td>
                                                    </tr>
                                            <tr style="position: sticky; top: 75px; z-index: 10;">
                                                <th style="width: 160px;">Date </th>
                                                <th style="width: 170px;">Medicine Name </th>
                                                <th>Dosage Qty </th>
                                                <th>Dosage From</th>
                                                <th>Frequency</th>
                                                <th>Duration </th>
                                                <th>Routes </th>
                                                 <th>Other Instruction</th>
                                                <th>Special Instructions </th>
                                                 <th>User Name</th>
                                                 <th>Edit</th>
                                             
                                            </tr>
                                        </thead>
                                                <tbody>
                                                </tbody>
                                            </table>
                                        </div>
                                </tr>
                        <table class="table">
                            <tr>
                                <td>
                                    <table class="table" id="tblVitalParametersHistoryDesc" >
                                        <thead>
                                            <tr>
                                                <td colspan="14">
                                                    <div id="tblHistoryHeaderDesc">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Receiving Date & Time </th>
                                                <th style="width: 84px;">Status</th>
                                                <th>Rate_Beats</th>
                                                <th>Temperature</th>
                                                <th>Rhythm</th>
                                                <th>Volume</th>
                                                <th>Blood Pressure</th>
                                                <th>Others </th>                                                
                                                <th>Respiration </th>
                                                <th>Instruction </th>
                                                <th>O2 Saturation</th>                                                
                                                <th>O2 Saturation_Oxygen1</th>
                                                <th>O2 Saturation_Oxygen2</th>
                                                <th>O2 BSR</th>
                                                <th>O2 BMI</th>
                                                <th>O2 Wt</th>
                                                <th>O2 Ht</th>
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
                </div>
                    <div class="row" style="margin-top:1%">
                        <div class ="col-lg-8">
                  <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="New" class="btn btn-yellow" name="btnName" onclick="NewWindow()" />
                  </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnBackList" class="btn btn-gray" value="View " onclick="BackToList()" />
                  </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                         <input type="button" class="btn btn-primry" onclick="SaveInPatientAllRecord();" value="Save" id="btnSave" />    
                  </div>
                  <div class="col-lg-2 col-md-3 col-sm-6">
                         <input type="button" class="btn btn-primry" value="Prescription" onclick="PrintInPatient();" id="btnPrintPrescription" /> 
                  </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                          <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="BulletList" />
                          <asp:Label ID="lblMessage" runat="server"></asp:Label>
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnsaveprint" value="Save & Print" onclick="SaveInPatientAllRecord();" />
                    </div>
                    <div id="loadingimage" style="display: none">
                        <asp:Image ID="image" ImageUrl="~../../../../wwwroot/images/loading.gif" runat="server" Width="32px" />
                    </div>
                </div>
            </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>
     <div id="myModalENT" class="modal fade" role="dialog" style="margin-left: -135px;">

        <div class="modal-dialog">

            <!-- Modal content-->
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
            <!-- Modal content-->
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

            <!-- Modal content-->
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

            <!-- Modal content-->
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
               <%-- <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Teaching  Hospital   
                    35KM Ferozepur Rd Lahore  phone: 0492 45109-6 
                   
                   

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
                    Arif Memorial Teaching  Hospital
                    35 Km Ferozpur Road Lahore
                    Phone: 0492 45109-6 
                 
                

                </div>
            </div>

        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PATIENT DETAIL</b>
        </div>
        <style>
            table.printtable {
                border: none;
                width: 100%;
                padding: 5px;
            }

                table.printtable tr td {
                    padding: 10px;
                    font-size: 18px;
                    color: #000;
                }

            .underline {
                border-bottom: 1px dotted #999;
                width: 100%;
            }

            .tdtitle {
                font-size: 20px;
                font-weight: bold;
            }
        </style>
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
                     Arif Memorial Teaching  Hospital 
                     35 Km Ferozpur Road Lahore
                     Phone: 0492 45109-6 
                      
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
                <td>لاءيں</td>
                <td>تشریف      
                </td>
                <td>میں</td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>
                    <span>OPD</span>
                </td>
                <td>کو</td>
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
                <td>دوبارہ</td>
            </tr>
        </table>
        <h6 style="width: 500px; margin-top: 300px; font-size: 14px; margin-left: 70px;">This is a Computer Generated Image and does not require Signature </h6>
    </div>
    <div id="myModalOrtho" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
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

                <!-- Modal content-->
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

            <!-- Modal content-->
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
</asp:Content>