<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientsDischarge.aspx.cs" Inherits="PMS.InPatientsDischarge" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ipddischarge.css" rel="stylesheet" />
    <style type="text/css">
        .edit-mode .token-input-delete-token {
            display: none !important;
        }

        .edit-mode #ctl00_MainContent_txtPatient_ID {
            background-color: #e9ecef !important;
            cursor: not-allowed !important;
        }
    </style>
    <script type="text/javascript">
        var btnVal = '';
        localStorage.IsDischarge = 0;
        $(document).ready(function () {
            debugger;

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
            $("#ctl00_MainContent_ddlDeathCertifiedbyDr1").select2({
                placeholder: "Select a doctor",
                allowClear: true
            });
            $("#ctl00_MainContent_ddlDeathCertifiedbyDr2").select2({
                placeholder: "Select a doctor",
                allowClear: true
            });

            $("#ctl00_MainContent_txtSaturation").focusin(function () {
                debugger;
                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtsaturationDis").focusin(function () {
                debugger;
                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen2").focusin(function () {
                debugger;
                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen2_desc").focusin(function () {
                debugger;
                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });
            $("#ctl00_MainContent_txtSaturation,#ctl00_MainContent_txtSaturation_Oxygen2").focusout(function () {
                debugger;
                if ($(this).val() == " %") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " %");
                }
            });
            $("#ctl00_MainContent_txtsaturationDis,#ctl00_MainContent_txtSaturation_Oxygen2_desc").focusout(function () {
                debugger;
                if ($(this).val() == " %") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " %");
                }
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen1").focusin(function () {
                debugger;
                var textOxygen = $(this).val().replace(" L/Min", "");
                $(this).val(textOxygen);
            });
            $("#ctl00_MainContent_txtOxygen1").focusin(function () {
                debugger;
                var textOxygen = $(this).val().replace(" L/Min", "");
                $(this).val(textOxygen);
            });
            $("#ctl00_MainContent_txtSaturation_Oxygen1").focusout(function () {
                debugger;
                if ($(this).val() == " L/Min") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " L/Min");
                }
            });
            $("#ctl00_MainContent_txtOxygen1").focusout(function () {
                debugger;
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
                    ((this.selectionEnd > 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_txtMR').on('keypress, keydown', function (event) {
                debugger;
                if ((event.which != 37 && (event.which != 39)) && ((this.selectionEnd > 1) ||
                    ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });
            $('#ctl00_MainContent_txtVR').on('keypress, keydown', function (event) {
                debugger;
                if ((event.which != 37 && (event.which != 39)) &&
                    ((this.selectionEnd > 1) ||
                        ((this.selectionEnd == 1) && (event.which == 8)))) {
                    return false;
                }
            });


        });
        function saveprint() {
            debugger;
            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            var ddlDischargeBy = $('#ctl00_MainContent_ddlDischarge_By').val();

            if (dischargechk == true) {
                if (ddlDischargeBy == "0" || ddlDischargeBy == null || ddlDischargeBy == "") {
                    Swal.fire({
                        title: 'Validation Error!',
                        text: 'Please select Discharge Doctor first.',
                        icon: 'warning',
                        confirmButtonText: 'OK'
                    });
                    return false;
                }

                CheckPendingBalanceBeforeSave(function (canProceed) {
                    if (canProceed) {
                        $('#loadingimage').show();
                        CheckExistInOutPatient();
                    } else {
                        $('#loadingimage').hide();
                        $('#ctl00_MainContent_cbDicharg_Slip').prop('checked', false);
                        $('#btnDischargePrint').attr('disabled', true);
                    }
                });
            } else {
                Swal.fire({
                    title: 'Validation Error!',
                    text: 'Please check the Discharge Slip checkbox first.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                return false;
            }
        }
        function InpatientDischargePrint() {
            debugger;
            InPAtID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            if (InPAtID != "") {
                window.open('../../ReportViewer.aspx?ReportName=DischargePrint&InPatientId=' + InPAtID);
            }
        }
        function toggleButton() {
            debugger;
            var checkboxdischarge = $('#ctl00_MainContent_cbDicharg_Slip').is(':checked');
            if (checkboxdischarge == true) {
                var ddlDischargeBy = $('#ctl00_MainContent_ddlDischarge_By').val();
                if (ddlDischargeBy == "0" || ddlDischargeBy == null || ddlDischargeBy == "") {
                    Swal.fire({
                        title: 'Validation Error!',
                        text: 'Please select Discharge Doctor first.',
                        icon: 'warning',
                        confirmButtonText: 'OK'
                    }).then(() => {
                        $('#ctl00_MainContent_cbDicharg_Slip').prop('checked', false);
                        $('#btnDischargePrint').attr('disabled', true);
                    });
                    return false;
                }

                CheckPendingBalanceBeforeSave(function (canProceed) {
                    if (canProceed) {
                        $('#btnDischargePrint').attr('disabled', false);
                    } else {
                        $('#ctl00_MainContent_cbDicharg_Slip').prop('checked', false);
                        $('#btnDischargePrint').attr('disabled', true);
                    }
                });
            } else {
                $('#btnDischargePrint').attr('disabled', true);
            }
        }
        function PrintAdmisionDetails(response) {
            debugger;
            PATID = $('#<%=txtPatient_ID.ClientID%>').val();

            InPAtID = response;
            $.ajax({
                type: "POST",
                url: "InPatientsDischarge.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    debugger;
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
                    debugger;
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
            debugger;
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
                url: "InPatientsDischarge.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    debugger;
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
                url: "InPatientsDischarge.aspx/PrintInPatientReceipt",
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
            debugger;
            PATID = $('#<%=txtPatient_ID.ClientID%>').val();
            InPAtID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            $.ajax({
                type: "POST",
                url: "InPatientsDischarge.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': PATID,
                    'OUTPatientID': InPAtID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    debugger;
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
                    url: "InPatientsDischarge.aspx/PrintInPatientReceipt",
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
                debugger;
                var doctorVal;
                var doctor;
                $.each(JSON.parse(res), function (key, value) {

                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy h:m:s A")%>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
                    doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();

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


                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);

                    }
                });

            }, function (err) { });

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
            debugger;
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

        function saveAllRecord() {

            debugger;
            var btnsave = $('#btnSave').val();
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            var txtAdmission_Date = $('#ctl00_MainContent_txtAdmission_Date').val();
            var ddlDepartment = $('#ctl00_MainContent_ddlDepartment').val();
            var ddlDoctor = $('#ctl00_MainContent_ddlDoctor').val();
            var txtHealth_Complaints = $('#ctl00_MainContent_txtHealth_Complaints').val();
            var txtExpected_Discharge_Date = $('#ctl00_MainContent_txtExpected_Discharge_Date').val();
            var ddlIssuance_Of = $('#ctl00_MainContent_ddlIssuance_Of').val();
            var ddlWard_No = $('#ctl00_MainContent_ddlWard_No').val();
            var PatientDiscountType = $('#ctl00_MainContent_ddlPatientType').val();
            var PanelCompany = $('#ctl00_MainContent_ddlPanelCompany').val();
            if (PatientDiscountType == "10") {
                if (PanelCompany == "0") {
                    alert("Please Select Panel Company");
                    return true;
                }

            }
            var patienttype = $("#ctl00_MainContent_vLbl_Patient_Type").text();

            var txtBed_No = $('#ctl00_MainContent_txtBed_No').val();
            var ddlRoom_No = $('#ctl00_MainContent_ddlRoom_No').val();
            var txtRoom_Type = $('#ctl00_MainContent_txtRoom_Type').val();

            var pulse_Min = $('#ctl00_MainContent_txtPuls').val();

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
            var OthersRN = $("#ctl00_MainContent_txtOthersRcvNote").val();

            var ddlEmrgRhythm = $('#ctl00_MainContent_ddlRhythm').val();
            var ddlEmrgVolume = $('#ctl00_MainContent_ddlVolume').val();
            var O2_Saturation_Oxygen1 = $("#ctl00_MainContent_txtSaturation_Oxygen1").val();
            var O2_Saturation_Oxygen2 = $("#ctl00_MainContent_txtSaturation_Oxygen2").val();

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

            var Murmur = $("input[name='ctl00$MainContent$Murmur']:checked").val();
            if (typeof Murmur === 'undefined') Murmur = null;
            else Murmur = JSON.parse(Murmur.toLowerCase());



            var PulseRate = $('#ctl00_MainContent_txtPulseRate').val();
            var BPDischarge = $('#ctl00_MainContent_txtBPDischarge').val();
            var Rhythmdischarge = $('#ctl00_MainContent_ddlRhythmdischarge').val();
            var volumedisc = $('#ctl00_MainContent_ddlvolumedisc').val();
            var Tempdisch = $('#ctl00_MainContent_txtTempdisch').val();
            var RespRateDesc = $('#ctl00_MainContent_txtRespRateDesc').val();
            var Oxygen2_desc = $('#ctl00_MainContent_txtSaturation_Oxygen2_desc').val();
            var saturationDis = $('#ctl00_MainContent_txtsaturationDis').val();
            var Oxygen1 = $('#ctl00_MainContent_txtOxygen1').val();
            var otherecdesc = $('#ctl00_MainContent_txtotherecdesc').val();
            var Special_Instruction_Desc = $('#ctl00_MainContent_txtRN_Special_Instruction_Desc').val();
            var Receiving_Date_Discharge = $('#ctl00_MainContent_txttxtReceiving_DateDesc').val();

            /* Death details tab, Portion fields */

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

            var ID = '<%= Request.QueryString["ID"]%>';
            PageMethods.SaveRecord(Patient_ID, btnsave, txtAdmission_Date, ddlDepartment, ddlDoctor, txtHealth_Complaints, txtExpected_Discharge_Date, ddlIssuance_Of, ddlWard_No, txtBed_No, ddlRoom_No, txtRoom_Type, BP_mm_Hg, Temp_C, Respiration_Min, txtRN_Special_Instruction, txtReceiving_Date, Provisional_Diagnosis, Reffer_To, HistoryOfPeresentIllness, HistoryOfFamily, HistoryOfPastIllness, SocioEconomicHistory, Birth_History, Reffer_No, Drug_History, Personal_History, ObstetricHistory, AllergiesHistory, TreatmentHistory, VaccinationHistory, AnyOtherHistory, ENT_Throat_IDL, ENT_Throat_Nose, ENT_Ear_Right, Ent_Ear_Left, ENT_Rinnes_Right_PosNeg, ENT_Rinnes_Lft_PosNeg, ENT_Rinnes_Right_FalseNeg, ENT_Rinnes_Lft_FalseNeg, ENT_Webber_Central, ENT_Webber_Lateralized, ENT_Investigation_PTA, ENT_Investigation_Tympanometry, ENT_Rinnes_Right_Neg, ENT_Rinnes_Lft_Neg, ENT_Rinnes_Right_FNeg, ENT_Rinnes_Lft_FNeg, txtInformant, txtSourceOfReferral, chkNeckHolding, chkWalking, chkTalking, chkOthers, txtMenarche, txtMenstrual, txtAttachmentSeparationfromParents, txtHealth, chkNailBiting, chkTemperTantrums, chkBedWetting, txtAcademics, txtPeerRelationship, txtBehaviour, txtOccupationalHistory, txtMaritalRelationshipSexualHistory, txtSubstanceUse, txtForensicUse, txtRelationship, txtLeisureActivities, txtAttitudetoSelfandStandards, txtPrevallingMood, txtReactionPattrentoStress, txtReligiousPracticesAttitute, txtFather, txtMother, txtSiblings, txtHomeAtmosphererelationshipsocialclass, txtFamilialIllness, txtActualandapparentage, txtRace, txtTattoosbodypiercingandscars, txtBodyHabitus, txtDress, txtHygiene, txtPsychomotorActivity, txtInvoluntarymovements, txtDystoniaEPS, txtTardivedyskinesia, txtTics, txtTremors, txtAttentivenesstointerview, txtEyeContact, txtLevelofConsciousness, txtRate, txtRhythm, txtVolume, txtTone, txtModulationvar, txtDepressed, txtElated, txtIrritable, txtLabile, txtIncongruent, txtbluntingflatteningapathy, txtThinkingPremeditation, txtPlans, txtActions, txtPreservative, txtLoosAssociation, txtTangentiaility, txtCircumstantiality, txtFlightofIdeas, txtThoughtInsertion, txtThoughtWithdrawal, txtThoughBroadcasting, txtThoughControl, txtDellusion, txtovervaluedideas, txtDepresonalization, txtDerealization, txtthrougObsession, txtthrougPhobies, txtthrougHomocidialIdeas, txtillusion, txtHallucinationAuditoryVisualOlfactoryGustatoryTactile, txtorientationtime, txtplace, txtperson, txtAttentionConcentrationSerial7Test, txtOrDaysOfWeekReverseOrder, txtImmediatememory,
                txtshorttermrecentevents, txtadressrecallafter2minutes, txtlongtermremoteevents, txtadressrecallafter5minues, txtgeneralknowledgequestion, txtsimplearthemeticcalculation, txtabstrationconcertethinking, txtinsight, DermaFace, DermaNeck, DermaTrunk, DermaUpperLimb, DermaLowerLimb,
                DermaFlexures, DermaGenitalias, DermaHair, DermaNail, DermaMucousMembrane,
                DermaEyes, DermaEars, DermaNose, DermaLips, HBM_Problem, HBM_Caused, HBM_Started, HBM_Course, HBM_Treatment, HBM_Effects, PE_Pluse, PE_BP, PE_Temperature, PE_Weight, PE_RespiratoryRate, PE_Jaundice, PE_Anemia, PE_Cyanosis, PE_Clubbing, PE_JVP, PE_LymphNodes, PE_Edema, PE_Respiratory, PE_Cardiovascular, PE_Gastro_Intestinal, PE_Observation, PE_Cranial_Nerves, PE_Limb_Strength, PE_Spasticity, PE_Position, PE_Vibration, PE_Stereognosis, PE_Pain, PE_Biceps, PE_Triceps, PE_Brachioradialis, PE_Quadriceps, PE_Patellar, PE_Achilles, PE_Extensor, PE_Frontal, PE_Finger, PE_Heel, PE_Movements, PE_Gait, PE_Neck_Rigidity, PE_Kerning_Sign, PE_Brudzinki_Sign, For_Summary, For_Diagnosis, For_AxisI, For_AxisII, For_AxisIII, For_AxisIV, For_AxisV, For_PredisposingFactors, For_PrecipitatingFactors, For_PrepetuatingFactors, For_Investigation, For_Medical, For_Psychological, For_Major_Issues, For_Strengths, For_Goals, For_Strategies, txtPeads_weight, txtPeads_Length, txtPeads_HC, txtPeads_General_Appearance, chkPeads_Cyanosis, chkPeads_Jaundice, chkPeads_Lethargy, chkPeads_Rash, txtPeads_Others, chkPeads_Caput, chkPeads_Cephalhematoma, rdbPeads_Anterioropen, rdbPeads_AnteriorClose, chkPeads_Dextrocardia, chkPeads_Bulging, chkPeads_Murmur, txtPeads_HeartSound, chkPeads_Nasal, chkPeads_Recessions, txtPeads_AddedSounds, rdbPeads_Flat, rdbPeads_Distended, rdbPeads_Scaphoid, chkPeads_Liver, chkPeads_Spleen, txtPeads_GITOthers, chkPeads_Sucking, chkPeads_Rooting, chkPeads_Moro, txtPeads_CNSOthers, chkPeads_FullTerm, chkPeads_PreTerm, txtPeads_DateOfDelivery, txtPeads_TimeOfDelivery, rdbPeads_Booked, rdbPeads_UnBooked, chkPeads_DAIHandling, chkPeads_ANTURash, chkPeads_PIH, chkPeads_GDM, chkPeads_Vacinated, txtPeads_ANTOthers, rdbPeads_SVD, rdbPeads_LSCS, rdbPeads_Emergency, rdbPeads_Elective, txtPeads_PlaceOfDelivery, txtPeads_IndicationForLSCS, Peads_apgerScore1min, Peads_apgerScore5min, chkPeads_Resuscitation, txtPeads_NatalOthers, chkPeads_Moaning, chkPeads_RespDistress, chkPeads_PostNATALCyanosis, chkPeads_Fits, chkPeads_ReluctanceToFeed, txtPeads_PostNatalOthers, txtProcedure_Operation, txtProcedure_Detail, txtDignosis, txtDischarge_On, ddlDischarge_By, txtNext_Visit, txtAdvice, chkdischarge, PatientDiscountType, PanelCompany, patienttype, referto, referward, referbed_no, referroomno, referroomtype, RateBeats, ddlEmrgRhythm, ddlEmrgVolume, OthersRN, O2_Saturation_Oxygen1, O2_Saturation_Oxygen2, Saturation, HMFIntact, CranialNerves, SignsOfMeningism, HeartSound, Arrhythmias, AnyOtherAddedSound, AnyOtherFindings, NVB_Right, NVB_Left, Crepitation_Right, Crepitation_Left, Wheeze, Ranchi, AnyOtherSound, AbdomenSoft, Tenderness, Guarding, BowelSound, Distention, FluidThrill, ShiftingDullness, EpigastriaDiscomfort, RetrosternalBurning, Jondus, Pallor, Dehydration, GCSOrientation, ConsciousOrientely, Murmur, TextBoxCns, TextBoxCvs, TextBoxResp, TextBoxGit, TextBoxGpe, eye_response, motor_response, verbal_Response, accumulated_response, FurtherExplanation, PulseRate, BPDischarge, Tempdisch, volumedisc, RespRateDesc, Rhythmdischarge, Oxygen2_desc, saturationDis, Oxygen1, otherecdesc, Special_Instruction_Desc, Receiving_Date_Discharge, IdentificationMarks, DateOfDeath, TimeOfDeath, PlaceOfDeath, CauseOfDeath, IssuingOfficerName, DeathCertifiedby1, DeathCertifiedby2, BodyHandedOverTo, FamilyPersonName, CNIC, RelationWithDeceased, CMO_Police, ID,
                function (response) {

                    debugger;
                    var btn = btnVal;

                    if (btn == 'btnSave') {
                        debugger;

                        alert('Data Successfully Save');

                        window.location = "InPatientsDischarge.aspx?ID=" + response;
                        $('#btnSave').val("Update");
                    }
                    else if (btn == 'btnsaveprint') {
                        debugger;

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
            var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
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
            debugger;
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




        function GetLastMediceineTab() {
            var doctor = $('#ctl00_MainContent_ddlMo_Doctor_Name').val();
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
        function AddDischageMedication() {
            localStorage.IsDischarge = 1;
            var dis = document.getElementById('ctl00_MainContent_cbDicharg_Slip').checked;
            if (dis == true) {


                return false;
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
            $('#tblHistoryHeader').html('<h2>Loading Previous History Please Wait....</h2>')
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
                $('#tblHistoryHeader').html('<h2>Previous History</h2>')
            }, function (e) { });
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
                $('#HeaderHistoryMedication').html('<h2>Loading Previous History Please Wait....</h2>')
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr> <td> ' + newdate + ' </td><td>' + value.Status + '</td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td></tr>';

                        if (value.Medicine_Name.length > 0)
                            $('#dvHistoryMedication').show();
                        else
                            $('#dvHistoryMedication').hide();
                    });
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                    $('#HeaderHistoryMedication').html('<h2>Previous History</h2>');
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
            debugger;
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
                var dosage_qty = $($(row).find('td')[7]).text().trim();
                var dosage_form = $($(row).find('td')[6]).text().trim();
                var frequency = $($(row).find('td')[2]).text().trim();
                var routes = $($(row).find('td')[3]).text().trim();
                var duration = $($(row).find('td')[4]).text().trim();
                var special_instruction = $($(row).find('td')[5]).text().trim();
                var other_instruction = $($(row).find('td')[8]).text().trim();

                $('#txtPharmacyItem').find('option:contains(' + $(row).find('td')[1].innerText + ')')[0].selected = true;
                $("#ddlDosage_Qty").find('option:contains(' + dosage_qty + ')')[0].selected = true;
                $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
                $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
                $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;
                $('#ddlOther_Instruction').find('option:contains(' + other_instruction + ')')[0].selected = true;
                $('#txtMedicineName').val($($(row).find('td')[1]).text());


                $('#txtInjection').val($($(row).find('td')[4]).text());
                $('#AttendingParamedicalStaff').val($($(row).find('td')[5]).text());
                $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());

            }, 2000);

        }

        function deleteMedicine(AnchorTag) {
            debugger;
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

                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td><input type="hidden" name="txtDoctor" value="' + value.Doctor_ID + '" />' + value.DoctorName + ' <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' /><input  type="checkbox" name="chkdischargevalue" checked="checked" style="display:none">  </td> </tr>';
                    });
                    $('#tblDischargeMedication tbody').html(rows);
                });
            }
        }


        function LoadMedicines() {
            debugger;
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    debugger;
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                });
            }
        }

        function LoadDischargeMedicines() {
            debugger;
            if ($('#<%= txtIn_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadDischargeMedicines($('#<%= txtIn_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    debugger;
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
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
            $('#HeaderTests').html('<h2>Loading Previous History Please Wait....</h2>')
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
            debugger;
            var patientID = $('#<%= hdfPatient_ID.ClientID%>').val();
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
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        }
                        $('.tests-table').append(row);
                    });

                });
            }
        }



        function SaveDischargeMedicines() {

            var Dtable = $('#tblDischargeMedication');
            var MedicinesList = [];
            Dtable.find('tbody tr').each(function (key, value) {


                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
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

            PageMethods.SaveOrthoDetail(btnsave, JSON.stringify(OrthoDetails), function (response) { saveAllRecord(); });

        }

        function SaveMedicines() {
            debugger;
            var table = $('#tblMedicinesList');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                debugger;

                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
                });
            });

            var InPatID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            var MedicineDetails = { PatientID: InPatID == '(New)' ? 0 : InPatID, MedicineList: MedicinesList }

            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { SaveDischargeMedicines(); });
        }

        function saveTests() {
            debugger;
            var table = $('.tests-table tbody');
            var test_list = [];
            table.find('tr').each(function (key, value) {
                test_list.push({ 'Date': $(value).find('td input[name=testDate]').val(), 'TestID': $(value).find('td input[name=testID]').val(), 'Catagory_ID': $(value).find('td input[name=txtGroupCategory]').val(), 'Dept_ID': $(value).find('td input[name=txtDeptID]').val(), 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'Doctor': $(value).find('td input[name=Docid]').val(), 'Area_Of_Interest': $(value).find('td input[name=txtArea_Of_Interest]').val(), 'Special_Tests': $(value).find('td input[name=txtSpecial_Test]').val(), 'RecievedID': $(value).find('td input[name=txtRecievedID]').val(), 'Is_Result': $(value).find('td input[name=txtIs_Result]').val(), 'IsBIllied': $(value).find('td input[name=txtIsBIllied]').val() });
            });
            var patientID = $('#<%= txtIn_Patient_ID.ClientID%>').val();
            if (patientID == '(New)' || patientID == '')
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list };
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


            PageMethods.SaveLabResultrpt(btnsave, JSON.stringify(ResulttrptDetail), function (response) { });

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
            var NoteDetails = { Pat: PatID, InPatientID: InPatID, NoteList: DoctorNoteList }

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
            debugger;
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
                url: "InPatientsDischarge.aspx/CheckExistOutPatient",
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
                        var Doctor = $('#ctl00_MainContent_ddlDoctor').val();
                        var Complain = $('#ctl00_MainContent_txtHealth_Complaints').val();
                        if (Doctor == "0" || Doctor == null) {
                            alert("Please Select Doctor");
                            return false;
                        }
                        if (Complain == "") {
                            alert("Please Enter Health Complaint ");
                            return false;
                        }
                        var ddlIssuance_Of = $('#ctl00_MainContent_ddlIssuance_Of').val();
                        var refer_to = $('#ctl00_MainContent_ddlReferTo').val();
                        if (refer_to != "0") {
                            if (refer_to == "001") {
                                var bedNo = $('#ctl00_MainContent_txtBedno').val();
                                if (bedNo == "") {
                                    alert("Please Select Bed No");
                                    return false;
                                }
                                SaveWard();
                            }
                            else if (refer_to == "002") {
                                var roomNo = $('#ctl00_MainContent_ddlroom').val();
                                if (roomNo == "0") {
                                    localStorage.SelectedTabID
                                    alert("Please Select Room No");
                                    return false;
                                }
                                SaveRoom();
                            }
                            else { return false; }

                        }
                        else {
                            if (ddlIssuance_Of == "0") {
                                alert("Please First Create Admision ");
                                return false;
                            }

                            if (ddlIssuance_Of == "001") {
                                var bedNo = $('#ctl00_MainContent_txtBed_No').val();
                                if (bedNo == "") {
                                    alert("Please Select Bed No");
                                    return false;
                                }
                                SaveWard();
                            }
                            else if (ddlIssuance_Of == "002") {
                                var roomNo = $('#ctl00_MainContent_ddlRoom_No').val();
                                if (roomNo == "0") {
                                    localStorage.SelectedTabID
                                    alert("Please Select Room No");
                                    return false;
                                }
                                SaveRoom();
                            }
                            else { return false; }
                        }


                        localStorage.SelectedTabID = $("#tabs").tabs("option", "active");
                        localStorage.DoctorID = $("#ctl00_MainContent_ddlMo_Doctor_Name").val();
                        localStorage.DesignationID = $("#ctl00_MainContent_ddlMO_Doctor_Status").val();

                    }
                },
                failure: function (response) {
                    alert("Failure");
                }
            });
        }

        function SaveInPatientAllRecord() {
            $('#btnSave').attr('disabled', true);
            debugger;
            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            var ddlDischargeBy = $('#ctl00_MainContent_ddlDischarge_By').val();

            if (dischargechk == true) {
                if (ddlDischargeBy == "0" || ddlDischargeBy == null || ddlDischargeBy == "") {
                    Swal.fire({
                        title: 'Validation Error!',
                        text: 'Please select Discharge Doctor first.',
                        icon: 'warning',
                        confirmButtonText: 'OK'
                    });
                    return false;
                }

                CheckPendingBalanceBeforeSave(function (canProceed) {
                    if (canProceed) {
                        $('#loadingimage').show();
                        LoadPatientDetails();
                    } else {
                        $('#btnSave').attr('disabled', false);
                        $('#loadingimage').hide();
                        $('#ctl00_MainContent_cbDicharg_Slip').prop('checked', false);
                        $('#btnDischargePrint').attr('disabled', true);
                    }
                });
            } else {
                Swal.fire({
                    title: 'Validation Error!',
                    text: 'Please check the Discharge Slip checkbox to discharge the patient.',
                    icon: 'warning',
                    confirmButtonText: 'OK'
                });
                $('#btnSave').attr('disabled', false);
                return false;
            }
        }
        function LoadPatientDetails() {
            debugger;
            var Patient_ID = $('#hdfPatient_ID').val();
            $("#in_PatientId").val(Patient_ID);
            var inpatId_Json = "";

            var ddlDoctor = $('#ctl00_MainContent_ddlDischarge_By').val();
            var DichargChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            var recordStatus = $('input#btnSave').val();

            if (recordStatus === "Save" && DichargChk !== true) {
                alert("You must select discharge Doctor & select Discharge Slip checkbox");
                $('#CloseSearchModel').click();
                $('#loadingimage').hide();
                return false;
            }

            if (ddlDoctor !== '0' && ddlDoctor !== 'undefined') {
                $.ajax({
                    type: "POST",
                    url: "InPatientsDischarge.aspx/GetPatientDetails",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess1,
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            else {
                alert("You must select discharge Doctor & select Discharge Slip checkbox");
                $('#CloseSearchModel').click();
                $('#loadingimage').hide();
                return false;
            }
        }

        function OnSuccess1(data) {
            debugger;
            if (data.d != '') {

                $("#in_PatientId").val(data.d.PatientID);



                if ((data.d.Bed_No != "" && data.d.Bed_No != 'undefined' && data.d.Bed_No != null) && (data.d.Ward_ID != "" && data.d.Ward_ID != 'undefined' && data.d.Ward_ID != null)) {


                    var InPatID = data.d.In_PatientID;
                    var ddlWard_No = data.d.Ward_ID;
                    var txtBed_No = data.d.Bed_No;
                    var PatID = data.d.PatientID;

                    var btnsave = $('#btnSave').val();
                    var PatID_1 = $('#<%= txtPatient_ID.ClientID%>').val();

                    var InPatID_1 = $('#<%= txtIn_Patient_ID.ClientID%>').val();
                    if (InPatID_1 == '(New)' || InPatID_1 == '')
                        InPatID_1 = 0;

                   
                    var ddlWard_No_1 = $('#ctl00_MainContent_ddlWard_No').val();
                    
                    var txtExpected_Discharge_On_Date = $('#ctl00_MainContent_txtDischarge_On').val();
                    var txtBed_No_1 = $('#ctl00_MainContent_txtBed_No').val();
                    var ddlDoctor = $('#ctl00_MainContent_ddlDischarge_By').val();
                    var DischargeChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

                    var txtAdvice = $('#ctl00_MainContent_txtPrevention_Precaution').val();
                    var txtProcedure_Operation = $('#ctl00_MainContent_txtProcedure_Operation').val();
                    var txtProcedure_Detail = $('#ctl00_MainContent_txtBilling').val();
                    var txtDignosis = $('#ctl00_MainContent_txtMedication').val();
                    var txtNext_Visit = $('#ctl00_MainContent_txtNext_Visit').val();
                    var DischargeType = $('#ctl00_MainContent_ddlDischarge_Type').val();
                    debugger;
                    var Package_type = $('#ddlPackageType').val();
                    var Package_Name = $('#ddlPackageName').val();
               

                    PageMethods.SaveWardInformation(btnsave, PatID, InPatID, ddlWard_No, txtBed_No, txtExpected_Discharge_On_Date, ddlDoctor, DischargeChk, txtAdvice, txtProcedure_Operation, txtProcedure_Detail, txtDignosis, txtNext_Visit, DischargeType, function (response) {
                        debugger;
                        if (response !== "") {
                                                  

                            var response_Arr = response.split(',');
                            if (response_Arr[0] === "Patient is Discharged Successfully !" || response_Arr[0] === "Patient is undischarged Successfully !") {
                                alert(response_Arr[0]);
                                window.location = "InPatientsDischarge.aspx?ID=" + response_Arr[1];
                                if (isRedirect == true) {
                                    window.open("../Billing/BillingProcess.aspx?Reg_ID=" + PatID + "&PackType=" + Package_type + "&packname=" + Package_Name + "&ipdid=" + InPatID);
                                }
                            }
                        }
                        else {
                            location.reload();
                        }
                        
                    });

                }  

               

                if ((data.d.Room_ID != "" && data.d.Room_ID != 'undefined' && data.d.Room_ID != null) && (data.d.RoomType != "" && data.d.RoomType != 'undefined' && data.d.RoomType != null)) {

                    var InPatID = data.d.In_PatientID;
                    var ddlWard_No = data.d.Ward_ID;
                    var txtBed_No = data.d.Bed_No;
                    var PatID = data.d.PatientID;

                    var btnsave = $('#btnSave').val();
                   
                    var txtExpected_Discharge_On_Date = $('#ctl00_MainContent_txtDischarge_On').val();
                    var ddlDoctor = $('#ctl00_MainContent_ddlDischarge_By').val();
                    var ddlRoom_No = data.d.Room_ID;
                    var txtRoom_Type = data.d.RoomType;
                    var DischargeChk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

                    var txtAdvice = $('#ctl00_MainContent_txtPrevention_Precaution').val();
                    var txtProcedure_Operation = $('#ctl00_MainContent_txtProcedure_Operation').val();
                    var txtProcedure_Detail = $('#ctl00_MainContent_txtBilling').val();
                    var txtDignosis = $('#ctl00_MainContent_txtMedication').val();
                    var txtNext_Visit = $('#ctl00_MainContent_txtNext_Visit').val();
                    var DischargeType = $('#ctl00_MainContent_ddlDischarge_Type').val();

                    var Package_type = $('#ddlPackageType').val();
                    var Package_Name = $('#ddlPackageName').val();

                    PageMethods.SaveRoomInformation(btnsave, PatID, InPatID, ddlRoom_No, txtRoom_Type, txtExpected_Discharge_On_Date, ddlDoctor, DischargeChk, txtAdvice, txtProcedure_Operation, txtProcedure_Detail, txtDignosis, txtNext_Visit, DischargeType, function (response) {
                        debugger;
                        if (response !== "") {

                            var response_Arr = response.split(',');
                            if (response_Arr[0] === "Patient is Discharged Successfully !" || response_Arr[0] === "Patient is undischarged Successfully !") {
                                alert(response_Arr[0]);
                                window.location = "InPatientsDischarge.aspx?ID=" + response_Arr[1];
                                if (isRedirect == true) {
                                    window.open("BillingProcess.aspx?Reg_ID=" + PatID + "&PackType=" + Package_type + "&packname=" + Package_Name + "&ipdid=" + InPatID);
                                }
                            }

                        }
                        else {
                            location.reload();
                        }
                    });

                }   

                
            }
        }


        function LoadHistory() {
            debugger;
            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;
            if (dischargechk == true) {
                $('#btnDischargePrint').attr('disabled', false);
            }
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != '(New)') {
                LoadPsychiatryHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPsychiatryHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadTestsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadENTHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadEyeListHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDermaHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                tblDischargeNote($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadOrtho($('#<%= hdfPatient_ID.ClientID%>').val());
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




        function BackToList() {
            window.location = "InPatientsDischargeList.aspx";
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
            var syptum = $('#txtNewSymptom').val();
            if (syptum != "") {
                $('#txtNewSymptom').hide();
            }
        }
        function On_Sypyum_Success() {
            debugger;
            LoadTokenInputForSymtoms();
            $('#txtNewSymptom').hide();
            $('#txtNewSymptom').val("");
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
            debugger;
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeat(patID, function (data) {
                debugger;
                if (data == 0) {
                    loadAjax();
                    $("#tabs").tabs("option", "active", 0);
                    checkRooms();
                   
                    $('#tblRoomsHistory').show();
                    $('#tblWardHistory').show();
                }
                else {
                    checkRepeateRecord = true;
                    window.location = "InPatientsDischarge.aspx?ID=" + data;
                }

               
            }, function (error) { })
        }

        function checkRooms() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeatRooms(patID, function (data) {

                $.each(JSON.parse(data), function (key, value) {

                    
                    window.location = "InPatientsDischarge.aspx?ID=" + value.In_Patient_ID;
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

        function AddLabTest() {
            debugger;
            var test = $('#ddlTestList').find('option:selected').text();
            PageMethods.GetLabTestDDLDetails(test, function (res) {
                debugger;
                $.each(JSON.parse(res), function (key, value) {
                    var Result = 'Result';
                    var test = $('#ddlTestList').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var doctorVal;
                    var doctor;
                    
                    doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
                    doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();

                    
                    if (doctorVal == 0 || doctorVal == undefined) {
                        alert("Please Select Doctor")
                        return false;
                    }

                    if (value.Test_ID != 0) {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + dateValue + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIsBIllied"/> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="001"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td>  <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    var test_array = $('.tests-table').find('input[name=testID][value="' + value.TestID + '"]');
                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);

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
                    


                    doctorVal = $('#ctl00_MainContent_ddlDoctor').find('option:selected').val();
                    doctor = $('#ctl00_MainContent_ddlDoctor').find('option:selected').text();


                    if (doctorVal == 0 || doctorVal == undefined) {
                        alert("Please Select Doctor")
                        return false;
                    }
                    var areaOfIntrest = $('#ctl00_MainContent_txtAreaOfInterest').val();
                    
                    var SpecialTest = "";
                    var row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRecievedID"/><input type="hidden" name="txtIs_Result"/><input type="hidden" name="txtIsBIllied"/><input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '">' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Namevalue + '</td><td>No</td><td>' + Result + '</td> <td><input type="hidden" name="txtSpecial_Test" value="' + SpecialTest + '"/><input type="hidden" name="txtArea_Of_Interest" value="' + areaOfIntrest + '"/> ' + areaOfIntrest + ' </td><td>' + doctor + ' <input type="hidden" name="Docid" value="' + doctorVal + '" </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                    var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');
                    if (test_array.length > 0) {
                        alert('This test already added!');
                    } else {
                        $('.tests-table').append(row);

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
            debugger;
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
            debugger;
            var url = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
            if (url[0].includes('=')) {
                var QS = url[0].split('=')[1];
                $('#queryString').val(QS);

            }
        }
     var isRedirect = false;
     var checkipddischarge = false;
     var InPatient_Ids_disc;
        $(document).ready(function () {
            debugger;

            var chk = '<%= Request.QueryString["ID"]%>';
            if (chk != "") {
                $('#ctl00_MainContent_cbDicharg_Slip').prop('disabled', true);
                $('#btnSave').prop('disabled', true);
                $('#ctl00_MainContent_txtPatient_ID').closest('.top').addClass('edit-mode');
                $('#ctl00_MainContent_txtPatient_ID').prop('disabled', true);
            }

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
            
            var btnsave = $("#btnSave").val();
            debugger;
            var chk = '<%= Request.QueryString["ID"]%>';

            if (chk != "") {

               
                loadReferenceInformation();
                $('#loadingimage').hide();
                $("#ctl00_MainContent_ddlMo_Doctor_Name").val(localStorage.DoctorID);
                $("#ctl00_MainContent_ddlMO_Doctor_Status").val(localStorage.DesignationID);
            }

            if ($('#ctl00_MainContent_txtIn_Patient_ID').val() !== '(New)') {
                debugger;
                LoadLabResultrpt();
               
            }
           
            if (chk != "") {

                if (localStorage.DoctorNoteTab == "true") {

                    $("#tabs").tabs("option", "active", 7);
                    localStorage.DoctorNoteTab = "False";
                }
            }

            var OPD_Patient = $('#<%=txtPatient_ID.ClientID%>').val();

            $('#<%= txtPatient_ID.ClientID%>').change(function () {

                debugger;

                checkRepeat();

            });
            <%if (Request.QueryString["ID"] != null)
              { %>

            $('#btnSave').val("Update");
            $('#btnDischargePrint').attr('disabled', false);

            <% } %>

                $('#btnDischarge_Billing').on('click', function () {
                debugger;
                isRedirect = true;
                InPatient_Ids_disc = $("#ctl00_MainContent_txtIn_Patient_ID").val();
                checkipddischarge = true;
                SaveInPatientAllRecord();



            }); 
            var inPatientID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            if (inPatientID && inPatientID !== "(New)" && inPatientID !== "") {
                CheckDischargeRequestStatus();
            }
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

            $('#btnAddMedicine').on("click", function () {
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
                    alert("Please Select Duration ");
                    return false;
                }
                // var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
                var datetime = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss A")%>';
                var datetimeValue = '<%= DateTime.Now%>';

                if ($(this).val() == 'Save') {
                    debugger;
                    var medicine = ''//$('#txtMedicineName').val();
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    if (medicine == '') {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetimeValue + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td><td> ' + $('#ddlDosage_Qty').find('option:selected').text() + '</td><td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                    }
                    else {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td> <input type="hidden" name="hdnItemCode" value="' + pharmacyItem + '"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + '</td><td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td><td> ' + $('#ddlDosage_Qty').find('option:selected').text() + '</td><td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + itemCode + '</td></tr>';
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
                    debugger;
                    var tid = $('#MedicationModel input[name=uurowid]').val();

                    var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];

                    $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                    $(row).find('td')[2].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();

                    $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                    $(row).find('td')[4].innerText = $('#MedicationModel input[name=txtInjection]').val();
                    $(row).find('td')[5].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();
                    $(row).find('td')[6].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();

                    $(row).find('td')[7].innerText = $('#ddlDosage_Qty').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_Qty').find('option:selected').text().trim();

                   

                    $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim() == "Select" ? '' : $('#ddlOther_Instruction').find('option:selected').text().trim();

                    
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
            debugger;
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
        debugger;
        var RoomType = $('#ctl00_MainContent_ddlRoomType').val();
        PageMethods.FillRooms(RoomType, function (res) {
            debugger;
            var item = JSON.parse(res);
            if (item != "") {
                var rows = '';
                var result;
                $.each(item, function (key, value) {
                    debugger;
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
        debugger;
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
        debugger;
        var hdFile_ID = $("#hdfPatient_ID").val();
        if (hdFile_ID != "(New)") {
            var Patient_ID = $("#hdfPatient_ID").val();
            var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
            loadtokenInputs(JSON.parse(tokendata));
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
    function NewWindow() {
        window.location = "InPatientsDischarge.aspx";
    }

    function loadtokenInputsDefault() {

        $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=In_Patients_discharge",
         {
             tokenLimit: 1,
             onAdd: function (item) {
                 try {
                     debugger;
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
      
        var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            $.ajax({
                type: "POST",
                url: "InPatientsDischarge.aspx/loadReferenceInformation",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccessReference,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
         var Package_type = '';
         var Package_Name = '';
        function OnSuccessReference(response) {
            debugger;
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
            Package_type = onsuccessreference.packagae_type;
            Package_Name = onsuccessreference.packagae_name;
             $('#ddlPackageType').val(onsuccessreference.packagae_type);
             $('#ddlPackageName').val(onsuccessreference.packagae_name);
            console.log(Package_type);
            console.log(Package_Name);
        }

        function loadAjax() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
        $.ajax({
            type: "POST",
            url: "InPatientsDischarge.aspx/GetDetail",
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
    var inpid = 0;
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
            $('#<%= vLbl_Patient_AdmitCatagory.ClientID%>').text(data.d.InPatient_AdmitCategory);
            $("#<%= txtIn_Patient_ID.ClientID%>").val(data.d.InPatient_Id);

            
            FillDoctorsByDepartment(data.d.Department);
            if (data.d.InPatient_Id && data.d.InPatient_Id !== "(New)" && data.d.InPatient_Id !== "") {
                CheckDischargeRequestStatus();
            }
        }
    }

        function FillDoctorsByDepartment(DepartmentId) {
            debugger;
            PageMethods.FillDoctorsByDepartment(DepartmentId, function (response) {
                var options = '<option value="0">Please Select</option>'
                $.each(JSON.parse(response), function (key, value) {
                    debugger;
                    options += '<option value="' + value.Emp_ID + '"> ' + value.Emp_Name + ' </option>';
                });
                $('#<%= ddlDischarge_By.ClientID%>').empty();
                $('#<%= ddlDischarge_By.ClientID%>').html(options);

            })
        }


        function loadtokenInputs(data) {
            debugger;
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=In_Patients_discharge",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger;
                        $("#hdfPatient_ID").val(item.id);
                        loadAjax();
                    }
                });
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

        // Function to check discharge request status and disable button if already requested
        function CheckDischargeRequestStatus() {
            debugger;
            var inPatientID = $('#ctl00_MainContent_txtIn_Patient_ID').val();

            if (inPatientID && inPatientID !== "(New)" && inPatientID !== "") {
                $.ajax({
                    type: "POST",
                    url: "InPatientsDischarge.aspx/GetDischargeRequestStatus",
                    data: JSON.stringify({
                        'InPatientID': inPatientID
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var status = response.d;
                        if (status === "1") {
                            // Discharge request already exists
                            $('#btnDischargeRequest').prop('disabled', true);
                            $('#btnDischargeRequest').val('Request Already Sent');
                            $('#btnDischargeRequest').addClass('btn-disabled');

                            //Swal.fire({
                            //    title: 'Information',
                            //    text: 'Discharge request has already been sent for this patient.',
                            //    icon: 'info',
                            //    confirmButtonText: 'OK'
                            //});
                        } else {
                            $('#btnDischargeRequest').prop('disabled', false);
                            $('#btnDischargeRequest').val('Discharge Request');
                        }
                    },
                    error: function (x, e) {
                        console.log('Error checking discharge request status: ' + e);
                    }
                });
            }
        }

        // Function to set discharge request
        function SetDischargeRequest() {
            debugger;
            var inPatientID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            var dischargechk = document.getElementById("ctl00_MainContent_cbDicharg_Slip").checked;

            if (!inPatientID || inPatientID === "(New)" || inPatientID === "") {
                Swal.fire({
                    title: 'Error!',
                    text: 'Please save the patient admission first before requesting discharge.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                return false;
            }

            // First check if discharge request already exists
            $.ajax({
                type: "POST",
                url: "InPatientsDischarge.aspx/GetDischargeRequestStatus",
                data: JSON.stringify({
                    'InPatientID': inPatientID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var status = response.d;
                    if (status === "1") {
                        Swal.fire({
                            title: 'Information',
                            text: 'Discharge request has already been sent for this patient.',
                            icon: 'info',
                            confirmButtonText: 'OK'
                        });
                        $('#btnDischargeRequest').prop('disabled', true);
                        return false;
                    }
                }
            });

            // Check if patient is already discharged
            if (dischargechk == true) {
                Swal.fire({
                    title: 'Error!',
                    text: 'This patient is already discharged.',
                    icon: 'error',
                    confirmButtonText: 'OK'
                });
                return false;
            }

            Swal.fire({
                title: 'Confirm Discharge Request',
                text: 'Are you sure you want to request discharge for this patient?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Request',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33'
            }).then((result) => {
                if (result.isConfirmed) {
                    $('#loadingimage').show();
                    $.ajax({
                        type: "POST",
                        url: "InPatientsDischarge.aspx/SetDischargeRequest",
                        data: JSON.stringify({
                            'InPatientID': inPatientID
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            $('#loadingimage').hide();
                            if (response.d === "Success") {
                                Swal.fire({
                                    title: 'Success!',
                                    text: 'Discharge request has been sent successfully.',
                                    icon: 'success',
                                    confirmButtonText: 'OK'
                                }).then(() => {
                                    // Disable the button after successful request
                                    $('#btnDischargeRequest').prop('disabled', true);
                                    $('#btnDischargeRequest').val('Request Already Sent');
                                    $('#btnDischargeRequest').addClass('btn-disabled');
                                });
                            } else if (response.d === "NotFound") {
                                Swal.fire({
                                    title: 'Error!',
                                    text: 'Patient record not found.',
                                    icon: 'error',
                                    confirmButtonText: 'OK'
                                });
                            } else {
                                Swal.fire({
                                    title: 'Error!',
                                    text: 'Failed to send discharge request. ' + response.d,
                                    icon: 'error',
                                    confirmButtonText: 'OK'
                                });
                            }
                        },
                        error: function (x, e) {
                            $('#loadingimage').hide();
                            Swal.fire({
                                title: 'Error!',
                                text: 'An error occurred while processing your request.',
                                icon: 'error',
                                confirmButtonText: 'OK'
                            });
                        }
                    });
                }
            });
        }
        function CheckPendingBalanceBeforeSave(callback) {
            debugger;
            var patientID = $('#<%= hdfPatient_ID.ClientID%>').val();
         var inPatientID = $('#ctl00_MainContent_txtIn_Patient_ID').val();

         if (inPatientID && inPatientID !== "(New)" && inPatientID !== "") {
             $('#loadingimage').show();
             $.ajax({
                 type: "POST",
                 url: "InPatientsDischarge.aspx/GetPendingBalance",
                 data: JSON.stringify({
                     'PatientID': patientID,
                     'InPatientID': inPatientID
                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     $('#loadingimage').hide();

                     // Check if we should skip the pending balance check
                     if (response.d === "SKIP_CHECK") {
                         // Patient has discount type '03' - proceed without any alert
                         if (callback) callback(true);
                         return;
                     }

                     var pendingBalance = parseFloat(response.d);
                     if (pendingBalance > 0) {
                         Swal.fire({
                             title: 'Pending Balance Alert!',
                             text: `Cannot discharge patient!\n\nPending Balance: Rs. ${pendingBalance.toFixed(2)}\n\nPlease receive the pending amount first.`,
                             icon: 'error',
                             confirmButtonText: 'OK',
                             confirmButtonColor: '#dc3545'
                         }).then(() => {
                             if (callback) callback(false);
                         });
                     } else {
                         if (callback) callback(true);
                     }
                 },
                 error: function (x, e) {
                     $('#loadingimage').hide();
                     Swal.fire({
                         title: 'Error!',
                         text: 'Unable to check pending balance. Please try again.',
                         icon: 'error',
                         confirmButtonText: 'OK'
                     }).then(() => {
                         if (callback) callback(false);
                     });
                 }
             });
         } else {
             if (callback) callback(true);
         }
     }

        // Modified DischargeRequest function to use the new method
        function DischargeRequest() {
            debugger;
            // Set the hidden field value
            $("#ctl00_MainContent_DischargeRequest").val('true');

            // Call the new function
            SetDischargeRequest();
        }

        // Add CSS class for disabled button
        var style = document.createElement('style');
        style.innerHTML = `
    .btn-disabled {
        opacity: 0.6;
        cursor: not-allowed;
        background-color: #6c757d !important;
        border-color: #6c757d !important;
    }
`;
        document.head.appendChild(style);

    </script>

   
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

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

                                <td style="width: 110px"><span id="pitem" style="margin-left: -365px;">Medicine Name</span><span class="RedStar">*</span></td>
                                <td style="width: 234px">
                                    <div style="margin-left: -529px;" >                                    <select 
                                        style="width: 48% !important" id="txtPharmacyItem" name="txtPharmacyItem" style="margin-left: -93px;margin-left: -176px;" onchange="Cleardrpdwn()">
                                    </select>
                                        </div>

                                </td>
                            </tr>
                            <tr>
                                <td style="width: 110px"><span>Dose</span><span class="RedStar">*</span></td>
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
                                <td><span>Frequency </span><span class="RedStar">*</span></td>
                                <td>
                                    <select id="txtRecomended_Dosage" name="RecomendedDosage" tabindex="3" style="width: 176px !important">
                                    
                                    </select>
                                </td>
                               

                            </tr>
                            
                            <tr>
                                <td><span>Route </span><span class="RedStar">*</span></td>
                                <td>
                                    <select id="Routes" name="Routes" tabindex="4" style="width: 176px !important">
                                     
                                    </select>
                                </td>
                                <td><span style="font-size:17px; padding-left: 106px; font-family: -webkit-body;">Other Instructions </span></td>
                            </tr>
                            <tr>
                                <td><span>Duration(Days/Hours) </span><span class="RedStar">*</span></td>
                                <td>
                                    <input type="text" id="txtInjection" name="txtInjection" placeholder="Duration" tabindex="5" style="width: 176px !important" />
                                </td>
                                <td>
                                      <select style="margin-left: 112px"  id="ddlOther_Instruction" name="OtherInstruction">
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
                                    <input type="button" id="btnSaveMedicine" name="btnSaveMedicine" value="Save" tabindex="7" />
                                </td>
                               
                              
                                 <td>
                                    <input type="button"  value="Add Unlisted Medicine" style="width: 177px; margin-left: 110px; background-color:#ab0138 !important" onclick="NewMedicine()" />
                                        </td>
                                <td></td>
                            </tr>
                        </table>
                    </fieldset>
                    <input type="hidden" name="uurowid" value="">
                </div>
                <div class="modal-footer">
                    <input type="button" value="Done" data-dismiss="modal" />


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
                                <div class="col-lg-5 col-md-5 col-sm-6 text-center">
                                    <div class="image-container">
                                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Addmittiedpatient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                                    </div>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6">
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6">
                                            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No : *"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                                            <asp:HiddenField ID="hdfPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                                            <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
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
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                      <asp:TextBox ID="txtIn_Patient_ID" runat="server" Text="(New)" ReadOnly="True"></asp:TextBox>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                   <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
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
                              
            <div style="width:83%">
                <div id="tabs" >
                    <ul>                      
                        <li><a href="#Tab-5">Discharge Details</a></li>                    
                    </ul>
                   
                    <div id="Tab-5">                       
                        <div id="Discharge_Detail">
                            <div class="row">
                                <div class="col-lg-4 col-md-6 col-sm-6">
                                    <h2>Discharge Details : </h2>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblDischarge_By" runat="server" Text="Advise By"></asp:Label>
                                    <asp:UpdatePanel runat="server" ID="UpdatePanel2">
                                        <ContentTemplate>
                                            <asp:DropDownList ID="ddlDischarge_By" runat="server" AppendDataBoundItems="true" TabIndex="1"></asp:DropDownList>
                                        </ContentTemplate>
                                    </asp:UpdatePanel>
                                </div>
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblDischarge_On" runat="server" Text="Discharged Date "></asp:Label>
                                    <asp:TextBox ID="txtDischarge_On"  runat="server" Enabled="false"></asp:TextBox>
                                </div>                              
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:Label ID="lblNext_Visit" runat="server" Text="Follow Up"></asp:Label>
                                    <asp:TextBox ID="txtNext_Visit" runat="server" TabIndex="5"></asp:TextBox>
                                </div>
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblPrevention_Precaution" runat="server" Text="Advice "></asp:Label>
                                    <asp:TextBox ID="txtPrevention_Precaution" runat="server" TextMode="MultiLine" Style="width: 100%; height: 36px !important;" TabIndex="2"></asp:TextBox>
                                </div>
                                <div class="col-lg-2 col-md-4 col-m-6">
                                 
                                         <input type="hidden" id="ddlPackageType" />
                                </div>
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblPackageName" Visible="false" runat="server" Text="Pacakge Name"></asp:Label>
                                      <input type="hidden" id="ddlPackageName" />
                                        
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblMedicine_Provided" runat="server" Text="Procedure Operation"></asp:Label>
                                    <asp:TextBox ID="txtProcedure_Operation" runat="server" TextMode="MultiLine" Style="width: 100%; height: 36px !important;" TabIndex="3"></asp:TextBox>
                                </div>
                                 <div class="col-lg-2 col-md-4 col-m-6">
                                     <asp:Label ID="lblMedications" runat="server" Text="Diagnosis"></asp:Label>
                                     <asp:TextBox ID="txtMedication" runat="server" TextMode="MultiLine" Style="width:100%;height: 36px !important;" TabIndex="6"></asp:TextBox>
                                </div>
                                <div class="col-lg-2 col-md-4 col-m-6">
                                    <asp:Label ID="lblBilling" runat="server" Text="Procedure Detail"></asp:Label>
                                    <asp:TextBox ID="txtBilling" runat="server" TextMode="MultiLine" Style="width:100%;height:36px !important;" TabIndex="4"></asp:TextBox>
                                    </div>
                                <div class="col-lg-2 col-md-4 col-sm-6">
                                    <asp:Label ID="Label20" runat="server" Text="Lab Result"></asp:Label>
                                    <asp:DropDownList ID="ddlLabResult" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <label></label>
                                    <input id="btnlabrpt" type="button" value="Add" onclick="InsertLabResult()" class="btn btn-primry">
                                </div>
                                </div>
                            <div class="row">
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                     <asp:Label ID="lblDischarge_Slip" runat="server" Text="Discharge Slip"></asp:Label>
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                  <asp:CheckBox ID="cbDicharg_Slip" runat="server" onclick="toggleButton()"></asp:CheckBox>
                                </div>
                                <div class="col-lg-2 col-md-6 col-sm-12">
                                    <asp:Label ID="Label10" runat="server" Text="Discharge Type"></asp:Label>
                                    <asp:DropDownList runat="server" AppendDataBoundItems="true" ID="ddlDischarge_Type"></asp:DropDownList>
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-6">
                                    <asp:Label ID="lblDeath_Certificate" runat="server" Text="Death Certificate" style="display:none"></asp:Label>
                                    <asp:CheckBox ID="cbDeath_Certificate" runat="server" style="display:none"></asp:CheckBox>
                                </div>
                                <div id="Div6">
                                </div>
                                </div>
                            <div class="row">
                                <div class="col-lg-2 col-md-6 col-sm-12">
                                    <input type="button" id="btnDischargePrint" class="btn-gray" value="Discharge Print" name="name"
                                        <%--onclick="PrintInpatientReceipt();"--%> 
                                      onclick="InpatientDischargePrint();"  />
                                </div>
                                 <div class="col-lg-4 col-md-6 col-sm-12"></div>
                                <div class="col-lg-3 col-md-4 col-sm-6">
                                    <table class="table" id="tblResultrpt">
                                        <thead>
                                            <tr>
                                                <th>Test Name </th>
                                                <th>Test Result </th>
                                                <th>Action</th>
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

                <div style="padding-top: 20px;">
                    <div class="col-lg-8">
                        <div class="row">
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                <input type="button" class="btn-primry" onclick="SaveInPatientAllRecord();" value="Save" id="btnSave" />
                            </div>
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                <input type="button" class="btn btn-yellow" value="New" name="btnName" onclick="NewWindow()" />
                            </div>
                            <div class="col-lg-2 col-md-6 col-sm-12">
                                <input type="button" class="btn-gray" id="btnBackList" value="View " onclick="BackToList()" />
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-12">
                                <input type="button" class="btn-primry" id="btnsaveprint" value="Save & Print" onclick="SaveInPatientAllRecord();" />
                            </div>
                            <div class="col-lg-3 col-md-6 col-sm-12">
                            <input type="button" id="btnDischargeRequest" value="Discharge Request" 
                                    class="btn btn-primry" onclick="DischargeRequest()" />
                            </div>

                            <div class="col-lg-3 col-md-6 col-sm-12" style="display:none;">
                                <input type="button" class="btn-primry" id="btnDischarge_Billing" value="Discharge & Billing" />
                            </div>
                        </div>
                    </div>
                    <table>
                        <tr>
                            <td>
                                 <div id="loadingimage" style="display:none">
                                <asp:Image ID="image" ImageUrl="~../../../../wwwroot/images/loading.gif" runat="server" Width="32px" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="BulletList" />
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
                                        <%--<textarea id="txtTangentiaility"></textarea>--%>
                                    </td>
                                    <td>(d:) &nbsp;      Circumstantiality:</td>
                                    <td>
                                        <asp:TextBox ID="txtCircumstantiality" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%--<textarea id="txtCircumstantiality"></textarea>--%>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Flight of Ideas:</td>
                                    <td>
                                        <asp:TextBox ID="txtFlightofIdeas" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%-- <textarea id="txtFlightofIdeas"></textarea>--%>
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
                                        <%--<textarea id="txtThoughtInsertion"></textarea>--%>
                                    </td>
                                    <td>(b:)&nbsp;Thought Withdrawal
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughtWithdrawal" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%--<textarea id="txtThoughtWithdrawal"></textarea>--%>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Thought Broadcasting
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughBroadcasting" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%-- <textarea id="txtThoughBroadcasting"></textarea>--%>
                                    </td>
                                    <td>(d:)&nbsp;Thought Control
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtThoughControl" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%--<textarea id="txtThoughControl"></textarea>--%>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;Dellusion:(Persecutory /Dellusion of refrence, Dellusion of control,Jealous, Erotomanic, Somatic, Grandious, Nihilistic,Bizarre, Sexual or amrous)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDellusion" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%--<textarea id="txtDellusion"></textarea>--%>
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
                                        <%-- <textarea id="txtImmediatememory"></textarea>--%>
                                    </td>

                                    <td>(b:)&nbsp;Short Term:Recent Events
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtshorttermrecentevents" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%--  <textarea id="txtshorttermrecentevents"></textarea>--%>
                                    </td>


                                </tr>
                                <tr>

                                    <td>(c:)&nbsp;Adress Recall After 2 Minutes
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtadressrecallafter2minutes" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        <%-- <textarea id="txtadressrecallafter2minutes"></textarea>--%>
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
                                        <%-- <textarea id="txtgeneralknowledgequestion"></textarea>--%>
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
                <td><div class="underline"><span id="Span1"></span></div></td>
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
            <tr id="tblLabResultrpt"></tr>
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
            <tr id="Madicenrow"></tr>
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
                <td><span id="txtFollowDate"></span> <span id="Span2"></span></td>
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
</asp:Content>