<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientMonitoring.aspx.cs" Inherits="PMS.InPatientMonitoring" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register Src="~/LookupControl.ascx" TagName="LookupControl" TagPrefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/ipdmonitoring.css" rel="stylesheet" />
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>


    <script type="text/javascript">
        (function ($) {

            jQuery.ptTimeSelect.setTime = function () {
                debugger;

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
                        $('#txtInjections').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
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
                            $('#txtInjections').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);
                        }
                    }
                }

            };
        })(jQuery);
        google.load("visualization", "1", { packages: ["corechart"] });

        function drawPulse() {

            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);
            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);
            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);
            $('#ctl00_MainContent_chkBlood').attr('checked', false);
            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            ('#ctl00_MainContent_chkSaturation').attr('checked', false);

            var chek = document.getElementById('ctl00_MainContent_chkPulse_Min').checked;
            if (chek === true) {

                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartPulseData',

                        data: "{'ID':" + id + "}",
                        success: function (data) {


                            drawchartPulse(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();

            }

        }

        function drawchartPulse(dataValues) {

            var data = new google.visualization.DataTable(dataValues);

            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Pulse_Min');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Pulse_Min]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {

                    title: "Pulse Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },

                });
        }
        function drawBP() {

            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);
            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);
            $('#ctl00_MainContent_chkBlood').attr('checked', false);
            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            $('#ctl00_MainContent_chkSaturation').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkBP_mm_Hg').checked;
            if (chek === true) {
                $('#chart_div').show();
                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartDataBP',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartBP(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }
        function drawchartBP(dataValues) {

            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Systolic ');
            data.addColumn('number', 'Diastolic');

            data.addColumn({ type: 'string', role: 'tooltip' });
            for (var i = 0; i < dataValues.length; i++) {
                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var Type = "AM";
                if (hours >= 12) {

                    Type = "PM";
                }
                var total = newdate + '/' + hours + '-' + minutes + '-' + Type;
                var BPValue = ([dataValues[i].BP_mm_Hg]).toString();
                var array = BPValue.split("/");
                var id_part1 = array[0];
                var id_part2 = array[1];

                data.addRow([total, parseInt(id_part1), parseInt(id_part2), 'BP_mm_Hg:' + parseInt(id_part2) + '']);


            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "BP Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "75%" },
                })
        }

        function AdPrint() {

            var In_Patient_ID = $('#ctl00_MainContent_txtInPatient_Mon_ID').val();
            var url = '../../ReportViewer.aspx?ReportName=InPatientMonitoring&ReportTitle=Clinical Summary Report' + '&In_Patient_ID=' + In_Patient_ID;
            window.open(url, '_blank');
        }

        function PrintNotes() {
            debugger;
            var In_Patient_ID = $('#ctl00_MainContent_hdnInpatient_id').val();
            var url = '../../ReportViewer.aspx?ReportName=NursingProgressNote&ReportTitle=Nursing Notes Report' + '&In_Patient_ID=' + In_Patient_ID;
            window.open(url, '_blank');
        }

        function PrintVitals() {
            var In_Patient_ID = $('#ctl00_MainContent_txtIn_Patient_ID').val();
            window.open('../../ReportViewer.aspx?ReportName=PrintIPDVitals&ReportTitle=In Patient Doctor Print' + '&In_Patient_ID=' + In_Patient_ID);
        }
        function drawchart(dataValues) {

            var data = new google.visualization.DataTable(dataValues);

            data.addColumn('string', 'InPatient_Mon_Dtl_ID');
            data.addColumn('number', 'Pulse_Min');
            data.addColumn('number', 'BP_mm_Hg');
            data.addColumn('number', 'Temp_C');
            data.addColumn('number', 'Respiration_Min');
            data.addColumn('number', 'Weight_Kg');
            data.addColumn('number', 'Blood_Suger');

            for (var i = 0; i < dataValues.length; i++) {
                data.addRow([dataValues[i].InPatient_Mon_Dtl_ID, dataValues[i].Pulse_Min, dataValues[i].BP_mm_Hg, dataValues[i].Temp_C, dataValues[i].Respiration_Min, dataValues[i].Weight_Kg, dataValues[i].Blood_Suger]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Patient Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: '50%' },
                });
        }
        function drawTemp() {

            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);

            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);
            $('#ctl00_MainContent_chkBlood').attr('checked', false);
            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            $('#ctl00_MainContent_chkSaturation').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkTemp_C').checked;
            if (chek === true) {

                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartDataTemp',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartTemp(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }
        function drawchartTemp(dataValues) {
            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Temp_C');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Temp_C]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Temp Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },
                });
        }
        function drawResp() {

            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);
            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);

            $('#ctl00_MainContent_chkBlood').attr('checked', false);
            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            $('#ctl00_MainContent_chkSaturation').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkRespiration_Min').checked;
            if (chek === true) {

                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartDataResp',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartResp(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }
        function drawchartResp(dataValues) {

            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Respiration_Min');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Respiration_Min]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Respiration_Min Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },
                });
        }
        function drawBlood() {
            debugger
            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);
            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);
            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);

            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            $('#ctl00_MainContent_chkSaturation').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkBlood').checked;
            if (chek === true) {
                debugger
                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartDataBlood',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartBlood(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }
        function drawchartBlood(dataValues) {


            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Blood_Suger');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Blood_Suger]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Blood Sugar Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },
                });
        }
        function drawWeight() {
            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);
            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);
            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);
            $('#ctl00_MainContent_chkBlood').attr('checked', false);

            $('#ctl00_MainContent_chkSaturation').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkWeight_Kg').checked;
            if (chek === true) {
                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartDataWeight',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartWeight(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }
        function drawSaturation() {
            $('#ctl00_MainContent_chkBP_mm_Hg').attr('checked', false);
            $('#ctl00_MainContent_chkTemp_C').attr('checked', false);
            $('#ctl00_MainContent_chkRespiration_Min').attr('checked', false);
            $('#ctl00_MainContent_chkBlood').attr('checked', false);
            $('#ctl00_MainContent_chkWeight_Kg').attr('checked', false);
            $('#ctl00_MainContent_chkPulse_Min').attr('checked', false);
            var chek = document.getElementById('ctl00_MainContent_chkSaturation').checked;
            if (chek === true) {
                $('#chart_div').show();

                if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                    var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                    $.ajax({
                        type: 'POST',
                        dataType: 'json',
                        contentType: 'application/json',
                        url: 'InPatientMonitoring.aspx/GetChartSaturation',

                        data: "{'ID':" + id + "}",
                        success: function (data) {
                            drawchartSaturation(data.d);
                        },

                        error: function () {
                            alert("Error loading data! Please try again.");
                        }
                    });
                }
            }

            else {
                $('#chart_div').hide();
            }

        }

        function drawchartSaturation(dataValues) {

            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Saturation');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Saturation]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Saturation Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },
                });
        }

        function drawchartWeight(dataValues) {

            var data = new google.visualization.DataTable(dataValues);
            data.addColumn('string', 'Mon_Date');
            data.addColumn('number', 'Weight_Kg');


            for (var i = 0; i < dataValues.length; i++) {

                var timeStamp = parseInt(dataValues[i].Mon_Date.substr(6, 10));
                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                var datearray = date.split("/");
                var newdate = datearray[1];
                var datetime = new Date(date);
                var hours = datetime.getHours();
                var minutes = datetime.getMinutes();
                var seconds = datetime.getSeconds();
                var dd = "AM";

                if (hours >= 12) {

                    dd = "PM";
                }


                var total = newdate + '/' + hours + '-' + minutes + '-' + dd;

                data.addRow([total, dataValues[i].Weight_Kg]);
            }

            var chart = new google.visualization.LineChart(document.getElementById('chart_div'));

            chart.draw(data,
                {
                    title: "Weight Monitorting",
                    position: "top",
                    fontsize: "14px",
                    chartArea: { width: "90%" },
                });
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
                $('#txtMedicineNames').val('');
                $('#txtDosages').val('');
                $('#txtRecomended_Dosages').val('');
                $('#txtOrals').val('');
                $('#txtInjections').val('');
                $('#btnSaveMedicines').val('Update');
                var row = $(AnchorTag).parents('tr')[0];
                $('#txtMedicineNames').val($($(row).find('td')[1]).text());
                var Medicine_Id = $($(row).find('td')[1]).text();
                var dosage_qty = $($(row).find('td')[2]).text().trim();
                var dosage_form = $($(row).find('td')[3]).text().trim();
                var frequency = $($(row).find('td')[5]).text().trim();
                var routes = $($(row).find('td')[6]).text().trim();
                var Req_Qty = $($(row).find('td')[7]).text().trim();
                var Rec_Qty = $($(row).find('td')[8]).text().trim();
                var duration = $($(row).find('td')[4]).text().trim();
                var special_instruction = $($(row).find('td')[5]).text().trim();
                var other_instruction = $($(row).find('td')[8]).text().trim();
                if (localStorage.IsRegular == 1) {
                    special_instruction = $($(row).find('td')[11]).text().trim();
                    other_instruction = $($(row).find('td')[10]).text().trim();
                    var Stop_Date = $($(row).find('td')[9]).text().split(' ')[0];
                    var Stop_Time = $($(row).find('td')[9]).text().split(' ')[1];
                    frequency = $($(row).find('td')[4]).text().trim();
                    duration = $($(row).find('td')[5]).text().trim();
                    $('#txtStopD').val(Stop_Date);
                    $('#txtStopT').val(Stop_Time);
                    debugger;
                    //var high_risk = $($(row).find('td')[8]).text().trim();
                    //if (high_risk == "No") {
                    //    $('#rdRiskN').prop('checked', true);
                    //}
                    //else { $('#rdRiskY').prop('checked', true); }
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
                    frequency = $($(row).find('td')[4]).text().trim();                      // Frequency
                    duration = $($(row).find('td')[5]).text().trim();                       // Duration
                    other_instruction = $($(row).find('td')[9]).text().trim();              // Other Instruction
                    special_instruction = $($(row).find('td')[10]).text().trim();           // Special Instructions
                    var reqQty = $($(row).find('td')[7]).find('input').val() || 0;          // Request Qty
                    var recQty = $($(row).find('td')[8]).find('input').val() || 0;          // Received Qty

                    // Populate modal fields
                    $('#txtInjections').val(duration);
                    $('#AttendingParamedicalStaffs').val(special_instruction);
                    // Set dropdowns – you may need to select by text
                    $('#ddlOther_Instruction').val(other_instruction);
                    // If you have hidden fields for quantities in the modal, set them
                    $('#MedicationModel input[name=IssueQty]').val(reqQty);
                    $('#MedicationModel input[name=RecQty]').val(recQty);
                    // Also set frequency and dose if needed
                    $('#txtRecomended_Dosages').val(frequency);   // might need to select by text
                    // etc.
                }

                debugger;

                var s = medicine.filter(x => x.Description == $(row).find('td')[1].innerText);
                $('#txtPharmacyItem').val(s[0].Item_Code).trigger('change');

                $("#ddlDosage_Qty").val(dosage_qty);

                $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
                $("#Route").find('option:contains(' + routes + ')')[0].selected = true;
                $('#ddlOther_Instructions').find('option:contains(' + other_instruction + ')')[0].selected = true;
                $('#txtMedicineNames').val($($(row).find('td')[1]).text());
                $('#txtInjections').val(duration);
                $('#AttendingParamedicalStaffs').val(special_instruction);
                $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
                $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            }, 3000);

        }
        $(document).on('select2:select', '#txtPharmacyItem', function (e) {
            var selected = e.params.data;
            if (selected && selected.id && selected.text) {
                var $sel = $('#txtPharmacyItem');
                if ($sel.find('option[value="' + selected.id + '"]').length === 0) {
                    $sel.append('<option value="' + selected.id + '">' + selected.text + '</option>');
                }
            }
        });
        function FillDosage() {
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value="' + 0 + '"> Select</option>'
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
        var medicine = '';
        function FillPharmacyItem() {
            PageMethods.FillPharmacyItemDropDown(function (Medicine) {
                medicine = JSON.parse(Medicine);

                var options = '<option value="' + 0 + '"> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.Item_Code + '"> ' + value.Description + ' </option>';
                });
                $('#txtPharmacyItem').html(options);
                initMedicationSelect2();
            });
        }
        function initMedicationSelect2() {
            var $sel = $('#txtPharmacyItem');
            if ($sel.data('select2')) { return; }
            $sel.select2({
                width: 'resolve',
                placeholder: 'Select Medicine',
                allowClear: true,
                dropdownParent: $('#MedicationModel'),
                minimumInputLength: 1,
                ajax: {
                    url: 'InPatientMonitoring.aspx/getpharmacyitems',
                    type: 'POST',
                    dataType: 'json',
                    contentType: 'application/json',
                    processData: false,
                    delay: 300,
                    data: function (params) {
                        return JSON.stringify({ searchString: params.term || '' });
                    },
                    processResults: function (response) {
                        var items = [];
                        try {
                            items = JSON.parse(response.d);
                        } catch (e) {
                            console.error('Error parsing pharmacy items:', e);
                        }
                        return {
                            results: $.map(items, function (item) {
                                return { id: item.Item_Code, text: item.Description };
                            })
                        };
                    },
                    cache: true
                }
            });
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
        function FillMedicine() {
            PageMethods.FillMedicineDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {

                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#txtMedicineNames').html(options);
                $('#txtMedicineNames').select2();
            });
        }
        function FillFrequency() {
            PageMethods.FillFrequencyDropDown(function (Frequency) {
                var options = '<option value=""> Select Frequency  </option>'
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + "-" + value.Segment1 + ' </option>';
                });
                $('#txtRecomended_Dosages').html(options);

            });
        }
        function Cleardrpdwn() {

            FillMedicine();
        }
        function CleardrpdwnItem() {

            FillPharmacyItem()
        }
        function NewMedicine() {
           // $('#txtPharmacyItem').val('').trigger('change');
            $('#txtMedicen').show();
            var medicine = $('#txtMedicen').val();
            if (medicine != "") {
                $('#txtMedicen').hide();
                $('#txtMedicen').val("");

            }
        }
        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value=""> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Route').html(options);
            });
        }
        var inpatient = 0;
        var TimePicker = '';
        var medicationRequestCode = '01'; 
        $(document).ready(function () {
            $('textarea').addClass("todolist");
            $('#ctl00_MainContent_txtAreaOfInterest').removeClass('todolist');
            $('#ctl00_MainContent_txtIdentificationMarks').removeClass('todolist');
            InfusionVolume();
            AdditiveDose();
            InfussionPharmacy();
            additive();
            Sides();
            CheckMonitoringMedicines();
            loadNurseName();
            CheckDischarge();

            //$('#txtStopD').datepicker({
            //    dateFormat: 'mm/dd/yy', numberOfMonths: 1,
            //    onSelect: function (selected) {
            //        debugger;
            //        var dt = new Date(selected);
            //        dt.setDate(dt.getDate() + 1);
            //        $("#txtStopD").datepicker("option", "minDate", dt);
            //    }
            //});

            $('#txtStartD').datepicker({
                dateFormat: 'mm/dd/yy', numberOfMonths: 1,
                onSelect: function (selected) {
                    debugger;
                    var dt = new Date(selected);
                    dt.setDate(dt.getDate() + 1);
                    $("#txtStopD").datepicker("option", "minDate", dt);
                }
            });
            $('#txtStartD').datepicker('setDate', new Date());
            $('#txtStartD').datepicker({ dateFormat: 'mm/dd/yy' });
            $('#txtStopD').on('change', function () {
                debugger;
            });
            var current_time = moment().format("hh:mm A");
            $('#txtStartT').ptTimeSelect({});
            $('#txtStartT').val(current_time);
            $('#txtStopT').ptTimeSelect({});
            $("#txtStopT").on("input", function () {

                alert();
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
                    $('#txtInjections').val("Day:" + parseInt(days) + " Hours: " + hours + " Min : " + minutes);

                }
            });
            $('#txtStopT').on('click', function () {
                TimePicker = "txtStopT";
            });

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

          //  $('#Addmedicine').attr('disabled', true);
            $("#txtMedicineNames").hide();
            $("#lblMed").hide();
            //  var current_time = moment().format("hh:mm A");
            $('#txtStartTime').ptTimeSelect({});
            $('#txtStartTime').val(current_time);

            $('#txtStopTime').ptTimeSelect({});

            $('#txtRemarks').removeClass('todolist');

            $('#ddl_addtive').on('change', function () {

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


            $("#ctl00_MainContent_txtSaturationRoom").focusin(function () {

                var text = $(this).val().replace(" %", "");
                $(this).val(text);
            });

            $("#ctl00_MainContent_txtSaturationRoom").focusout(function () {

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


            $("#ctl00_MainContent_txtSaturation_Oxygen1").focusout(function () {

                if ($(this).val() == " L/Min") {
                    $(this).val("");
                }
                else {
                    $(this).val($(this).val() + " L/Min");
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


            $('#txtStartDate').datepicker('setDate', new Date());
            var dt = new Date($('#txtStartDate').val());
            dt.setDate(dt.getDate());
            $("#txtStopDateTime").datepicker("option", "minDate", dt);

            bindControls();
            bindDate();
            GetMonDetail();
            GetInTake();
            GetOutput();
            GetProgressNotes();
            LoadMedicines();
            LoadMedicinesForMon();
            FillMedicine();
            FillFrequency();
            FillOtherInstruction();
            FillDosageQty();
            FillPharmacyItem();
            FillDosage();
            FillRoutes();
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != "(New)") {
                CountTotalQty();
                CountTotalQtyOutPut();
                CountPerQty();
                CountPerQtyOutput();
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicinesFormInPatient($('#<%= hdfPatient_ID.ClientID%>').val());
                Appendtestintable($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadInstruction();
                LoadInstructionEdit();
                loadServices();
                LoadInfusion();


            }


            LoadHistory();
            $('#<%= txtPatient_ID.ClientID%>').change(function () {
                checkRepeat();
                loadAjax();
                CountTotalQty();
                CountTotalQtyOutPut();
                CountPerQty();
                CountPerQtyOutput();
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
            LoadMedicinesFormInPatient($('#<%= hdfPatient_ID.ClientID%>').val());


            LoadHistory();
        });
        <%if (Request.QueryString["ID"] != null)
               {%>
            LoadInstruction();
            LoadInstructionEdit();
            $('#btnSave').val("Update");
            $('#loadingimage').hide();
            loadReferenceInformation();
                <%}%>
            $("#ctl00_MainContent_txtDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $('#btnSaveMedicine').on("click", function () {

                var datetime = '<%= DateTime.Now%>';
          if ($('#btnSaveMedicine').val() == 'Add Medicine') {
              var row = '<tr data-new="true"> <td> ' + datetime + ' </td><td> ' + $('#txtMedicineName').find('option:selected').text() + '</td> <td> ' + $('#txtDosage').val() + ' </td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
              var table = $('#tblMedicinesList tbody');
              table.append(row);
          }
          else {
              var tid = $('#tblMedicinesList input[name=uurowid]').val();
              var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
              $(row).attr('data-new', 'true');
              $(row).find('td')[1].innerText = $('#tblMedicinesList select[name=txtMedicineName]').find('option:selected').text();
              $(row).find('td')[2].innerText = $('#tblMedicinesList input[name=txtDosage]').val();
              $(row).find('td')[3].innerText = $('#tblMedicinesList select[name=RecomendedDosage]').find('option:selected').text();
              $(row).find('td')[4].innerText = $('#tblMedicinesList select[name=Routes]').find('option:selected').text();
              $(row).find('td')[5].innerText = $('#tblMedicinesList input[name=txtInjection]').val();
              $(row).find('td')[6].innerText = $('#tblMedicinesList input[name=AttendingParamedicalStaff]').val();
          }
          $('#MedicationModel').modal('hide');
      });

            $('#btnAddMedicines').on("click", function (e) {

                $('#chkRegular').prop('checked', true);
                var name = e.delegateTarget.attributes.id.value;
                button_text_name = name;
                localStorage.IsDischarge = 0;

                $("#btnSaveMedicine").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
                $('#txtMedicen').hide();
                $('#txtMedicineNames').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjections').val('');

                $('#txtMedicineNames').focus();

            });
            $('#btnRegularMedicine').on("click", function (e) {
                debugger;
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
                $('#txtMedicineNames').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlDosage_From').val('0')
                $('#txtStopD').val('');
                $('#txtStopT').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#ddlOther_Instruction').val('0');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjections').val('');

                $('#txtMedicineNames').focus();

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
                $('#txtMedicineNames').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjections').val('');

                $('#txtMedicineNames').focus();

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

                $("#btnSaveMedicines").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
                $('#txtMedicen').hide();
                $('#txtMedicineNames').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').val('0');
                $('#txtInjections').val('');
                $('#AttendingParamedicalStaff').val('')
                $('#ddlOther_Instruction').val('0')

                $('#txtMedicineNames').focus();

            });
            $('#btnSaveMedicines').on("click", function () {
                debugger;

                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");
                    $('#txtInjections').val("0");
                    $('#AttendingParamedicalStaff').val("0");

                }

                var value = $('#txtPharmacyItem').val();

                if ($('#txtPharmacyItem').val() == 'Select Medicine' || $('#txtPharmacyItem').val() == null || $('#txtPharmacyItem').val() == '0') {
                    $('#txtPharmacyItem').val('');
                }

                var medicen = $('#txtMedicen').val();
                var pharmacyItem = $('#txtPharmacyItem').val();

                if ((medicen == '' || medicen == null) && (pharmacyItem == '' || pharmacyItem == null)) {
                    alert("Please enter medicine name");
                    return false;
                }

                if ((medicen != '' && medicen != null) && (pharmacyItem != '' && pharmacyItem != null && pharmacyItem != '0')) {
                    alert("Please enter only one medicine name");
                    return false;
                }
                var UnListedMed = $('#txtMedicen').val();
                var pharmacyITem = '';

                if ($('#txtPharmacyItem').val() != '' && $('#txtPharmacyItem').val() != '0' && $('#txtPharmacyItem').val() != null) {
                    pharmacyITem = $('#txtPharmacyItem').find('option:selected').text();
                } else if (UnListedMed != '' && UnListedMed != null) {
                    pharmacyITem = UnListedMed;
                }

                var itemCode = '';
                if ($('#txtPharmacyItem').val() != '' && $('#txtPharmacyItem').val() != '0' && $('#txtPharmacyItem').val() != null) {
                    itemCode = $('#txtPharmacyItem').val();
                } else {
                    itemCode = '0';
                }
                var unlistedFlag = (itemCode === '0' || itemCode === 0 || itemCode === '' || itemCode === null) ? 1 : 0;

                var Dose = $('#txtDosages').val();
                if (Dose == "") {
                    alert("Please Select Dose ")
                    return false;
                }
                var Frequency = $('#txtRecomended_Dosages').val();
                if (Frequency == "" || Frequency == null || Frequency == "0") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Validation Error',
                        text: 'Please select the Frequency.',
                        confirmButtonColor: '#3085d6',
                        confirmButtonText: 'OK'
                    });
                    $('#txtRecomended_Dosages').focus();
                    return false;
                }

                var DosageQty = $('#ddlDosage_Qty').val();
                if (DosageQty == "" || DosageQty == null || DosageQty == "0") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Validation Error',
                        text: 'Please enter the Dosage Qty.',
                        confirmButtonColor: '#3085d6',
                        confirmButtonText: 'OK'
                    });
                    $('#ddlDosage_Qty').focus();
                    return false;
                }
                var DosageFrom = $('#ddlDosage_From').val();
                var Route = $('#Route').val();
                if (Route == "" || Route == null || Route == "0") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Validation Error',
                        text: 'Please select the Route.',
                        confirmButtonColor: '#3085d6',
                        confirmButtonText: 'OK'
                    });
                    $('#Route').focus();
                    return false;
                }
                //var Duration = $('#txtInjections').val();
                //if (Duration == "") {
                //    if (localStorage.IsPRN == 1 || localStorage.IsStat == 1) {

                //    }
                //    else {
                //        alert("Please Select Duration ");
                //        return false;
                //    }
                //}

                $.ajax({
                    type: "POST",
                    url: "InPatientMonitoring.aspx/MedicationRequestQty",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false, 
                    success: function (response) {
                        medicationRequestCode = response.d;
                    },
                    error: function () {
                        medicationRequestCode = "01"; 
                    }
                });

                var requestQty = $('#txtRequestQty').val();
                if (requestQty == '' || isNaN(requestQty) || requestQty == null) {
                    requestQty = 0;
                } else {
                    requestQty = parseFloat(requestQty);
                }

                if (medicationRequestCode === "01") {
                    if (requestQty <= 0) {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Request Qty Required',
                            text: 'Please enter a quantity greater than 0 for the medication request.',
                            confirmButtonText: 'OK'
                        });
                        $('#txtRequestQty').focus();
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
                    if (itemCode == undefined) {
                        itemCode = 0;
                    }
                    var Regular = $('#chkRegular').prop('checked');
                    var Stat = $('#chkStat').prop('checked');
                    var PRN = $('#chkPRN').prop('checked');

                    if (medicine == '') {
                        var otherIns = $('#ddlOther_Instruction').find('option:selected').text();
                        if (otherIns == ' Select' || otherIns == " Select") {
                            otherIns = '';
                        }

                        // ========== MODIFY: Use requestQty variable instead of hardcoded "0" ==========
                        var row = '<tr data-new="true"> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#ddlDosage_Qty').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + ' </td><td> ' + $('#txtInjections').val() + '</td>   <td> ' + $('#Route').find('option:selected').text() + ' </td><td> <input type="text" class="form-control routeInput" value="' + requestQty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td>' + completeStop + '</td> <td>' + otherIns + '</td><td> ' + $('#AttendingParamedicalStaffs').val() + ' </td>' + '<td>' + username + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="RtnQty"  placeholder="Enter value" /></td>' + '<td><a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        // ========== END MODIFY ==========

                        //  var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td><td> ' + $('#Route').find('option:selected').text() + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td> ' + $('#txtInjections').val() + '</td><td>' + $('#AttendingParamedicalStaffs').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="RtnQty"  placeholder="Enter value" /></td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        if (localStorage.IsStat == 1) {
                            // STAT row – matches tblMedicinesListSTAT header (13 columns)
                            // ========== MODIFY: Use requestQty variable for STAT row ==========
                            var row = '<tr data-new="true">' +
                                '<td><input type="hidden" name="testDate" value="' + complete + '">' + complete + '</td>' +
                                '<td><input type="hidden" name="hdnItemCode" value="' + itemCode + '">' + pharmacyITem + '</td>' +
                                '<td>' + $('#ddlDosage_Qty').val() + '</td>' +
                                '<td>' + $('#ddlDosage_From').find('option:selected').text() + '</td>' +
                                '<td>' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td>' +
                                '<td>' + $('#txtInjections').val() + '</td>' +
                                '<td>' + $('#Route').find('option:selected').text() + '</td>' +
                                '<td><input type="text" class="form-control routeInput" value="' + requestQty + '" name="IssueQty" placeholder="Enter value" /></td>' +
                                '<td><input type="text" class="form-control routeInput" value="0" name="RecQty" placeholder="Enter value" /></td>' +
                                '<td>' + otherIns + '</td>' +
                                '<td>' + $('#AttendingParamedicalStaffs').val() + '</td>' +
                                '<td>' + username + '</td>' +
                                '<td>' +
                                '<a href="#" onclick="editMedicine(this)"> Edit </a> | ' +
                                '<a href="#" onclick="deleteMedicine(this)"> Delete </a> ' +
                                '<input type="hidden" name="uurowid" value="' + uuid() + '" />' +
                                '</td>' +
                                '</tr>';
                            // ========== END MODIFY ==========

                        }
                        // if (localStorage.IsPRN == 1) {
                        //     debugger;
                        //     var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td><td> ' + $('#Route').find('option:selected').text() + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td> ' + $('#txtInjections').val() + '</td><td>' + $('#AttendingParamedicalStaffs').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        // }
                    }
                    else {
                        debugger;
                        //  var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td><td> ' + $('#Route').find('option:selected').text() + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td> ' + $('#txtInjections').val() + '</td><td>' + $('#AttendingParamedicalStaffs').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="RtnQty"  placeholder="Enter value" /></td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        // ========== MODIFY: Use requestQty variable for this row too ==========
                        var row = '<tr data-new="true"> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#ddlDosage_Qty').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + ' </td><td> ' + $('#txtInjections').val() + '</td>   <td> ' + $('#Route').find('option:selected').text() + ' </td><td> <input type="text" class="form-control routeInput" value="' + requestQty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td>' + completeStop + '</td> <td>' + otherIns + '</td><td> ' + $('#AttendingParamedicalStaffs').val() + ' </td>' + '<td>' + username + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="RtnQty"  placeholder="Enter value" /></td>' + '<td><a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        // ========== END MODIFY ==========

                        // if (localStorage.IsStat == 1) {
                        //     debugger;
                        //     var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td><td> ' + $('#Route').find('option:selected').text() + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td> ' + $('#txtInjections').val() + '</td><td>' + $('#AttendingParamedicalStaffs').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';;

                        // }
                        // if (localStorage.IsPRN == 1) {
                        //     debugger;

                        //     var row = '<tr> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosages').find('option:selected').text() + '</td><td> ' + $('#Route').find('option:selected').text() + '</td><td> <input type="text" class="form-control routeInput" value="0"   name="IssueQty"  placeholder="Enter value" /></td> <td> <input type="text" class="form-control routeInput" value="0"   name="RecQty"  placeholder="Enter value" /></td><td> ' + $('#txtInjections').val() + '</td><td>' + $('#AttendingParamedicalStaffs').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td> <a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                        // }
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
                            $(row).attr('data-new', 'true');
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
                            $(row).attr('data-new', 'true');
                            $(row).find('td')[0].innerText = complete;   // Start Date
                            $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();   // Medicine Name
                            $(row).find('td')[2].innerText = $('#ddlDosage_Qty').val();   // Dose
                            $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();   // Dosage Unit
                            $(row).find('td')[4].innerText = $('#txtRecomended_Dosages').find('option:selected').text();   // Frequency
                            $(row).find('td')[5].innerText = $('#txtInjections').val();   // Duration
                            $(row).find('td')[6].innerText = $('#Route').find('option:selected').text();   // Route
                            $(row).find('td')[7].innerText = $('input[name=IssueQty]', '#MedicationModel').val();   // Request Qty
                            $(row).find('td')[8].innerText = $('input[name=RecQty]', '#MedicationModel').val();   // Received Qty
                            $(row).find('td')[9].innerText = $('#ddlOther_Instruction').find('option:selected').text();   // Other Instruction
                            $(row).find('td')[10].innerText = $('#AttendingParamedicalStaffs').val();   // Special Instructions
                            $(row).find('td')[11].innerText = username;   // Username (or keep as is)
                            // td[12] is the Edit column – leave unchanged
                        }
                        else if (localStorage.IsRegular == 1) {
                            debugger;
                            row = $('#tblMedicinesListRegular tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                            $(row).attr('data-new', 'true');
                            $(row).find('td')[0].innerText = complete;
                            $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                            $(row).find('td')[2].innerText = $('#ddlDosage_Qty').val();
                            $(row).find('td')[3].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                            $(row).find('td')[4].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                            $(row).find('td')[5].innerText = $('#MedicationModel input[name=txtInjections]').val();
                            $(row).find('td')[6].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                            $(row).find('td')[7].innerText = $('#MedicationModel input[name=IssueQty]').val();
                            $(row).find('td')[8].innerText = $('#MedicationModel input[name=RecQty]').val();
                            $(row).find('td')[9].innerText = completeStop;
                            $(row).find('td')[10].innerText = rdRiskY;
                            $(row).find('td')[11].innerText = $('#ddlOther_Instruction').find('option:selected').text();
                            $(row).find('td')[12].innerText = $('#AttendingParamedicalStaff').val();
                            $(row).find('td')[14].innerText = $('#txtPharmacyItem').val();
                            $(row).find('td')[13].innerText = $('#MedicationModel input[name=RtnQty]').val();;


                        }
                    }
                    else if (localStorage.IsDischarge == 1) {
                        row = $('#tblDischargeMedication tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                        $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                        $(row).find('td')[2].innerText = $('#MedicationModel select[name=RecomendedDosage]').find('option:selected').text();
                        $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                        $(row).find('td')[4].innerText = $('#MedicationModel input[name=IssueQty]').val();
                        $(row).find('td')[5].innerText = $('#MedicationModel input[name=RecQty]').val();
                        $(row).find('td')[6].innerText = $('#MedicationModel input[name=txtInjections]').val();
                        $(row).find('td')[7].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();

                        $(row).find('td')[8].innerText = $('#ddlDosage_From').find('option:selected').text().trim() == "Select" ? '' : $('#ddlDosage_From').find('option:selected').text().trim();
                        $(row).find('td')[9].innerText = $('#ddlDosage_Qty').val();
                        $(row).find('td')[10].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim() == "Select" ? '' : $('#ddlOther_Instruction').find('option:selected').text().trim();
                        '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
                    }

                }

                $('#txtRequestQty').val('0');

                $('#txtMedicen').hide();
                $('#txtMedicen').val('');
                $('#txtMedicineNames').val('');
                $('#txtPharmacyItem').val(0).trigger('change');
                $('#txtRecomended_Dosages').val('');
                $('#txtDosages').val('');
                $('#Route').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjections').val('');
                $('#AttendingParamedicalStaffs').val('');
                $('#txtMedicineNames').focus();
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlOther_Instruction').val('');
                $('#txtPrnDose').val('');
                $('#txtStopD').val('');
                $('#txtStopT').val('');
                $('#ddlDosage_Qty').val('');
                $('#txtPharmacyItem').val('');
            });

            <%--$('#btnSaveMedicine').on("click", function () {
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
                var itemCode = ($('#txtPharmacyItem').val() != '' && $('#txtPharmacyItem').val() != '0' && $('#txtPharmacyItem').val() != null) ? $('#txtPharmacyItem').val() : '0';
                var unlistedFlag = (itemCode === '0' || itemCode === 0 || itemCode === '' || itemCode === null) ? 1 : 0;

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


                             var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#ddlDosage_Qty').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td><td> ' + $('#txtInjection').val() + '</td>   <td> ' + $('#Routes').find('option:selected').text() + ' </td><td style="display:none;">' + completeStop + '</td> <td>' + otherIns + '</td><td style= "display:none;"> ' + otherIns + ' </td>' + '<td> ' + $('#AttendingParamedicalStaff').val() + ' </td>' + '<td>' + username + '</td>' + '<td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';







                             if (localStorage.IsStat == 1) {
                                 debugger;
                                 var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                             }
                             if (localStorage.IsPRN == 1) {
                                 debugger;
                                 var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                             }
                         }
                         else {
                             debugger;
                             var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';

                             if (localStorage.IsStat == 1) {
                                 debugger;
                                 var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';;

                             }
                             if (localStorage.IsPRN == 1) {
                                 debugger;

                                 var row = '<tr' + (unlistedFlag === 1 ? ' class="unlisted-row"' : '') + '> <td> <input type="hidden" name="testDate" value="' + complete + '">' + complete + ' </td><td><input type="hidden" name="hdnItemCode" value="' + itemCode + '"> ' + pharmacyITem + '</td><td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + '</td><td> ' + $('#txtInjection').val() + '</td><td>' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + $('#ddlDosage_From').find('option:selected').text() + ' </td> <td> ' + $('#ddlDosage_Qty').val() + ' </td>' + '<td> ' + $('#ddlOther_Instruction').find('option:selected').text() + ' </td>' + '<td>' + username + '</td><td>' + (unlistedFlag === 1 ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + unlistedFlag + '" />  </td><td style="display:none;">' + itemCode + '</td></tr>';
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
                                 $(row).find('td')[8].innerText = rdRiskY;

                                 $(row).find('td')[9].innerText = $('#ddlOther_Instruction').find('option:selected').text();
                                 $(row).find('td')[10].innerText = $('#AttendingParamedicalStaff').val();
                                 $(row).find('td')[13].innerText = $('#txtPharmacyItem').val();


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
                             '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
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
                 });--%>
        });
        function editPlus(AnchorTag) {

            $('#btnAddPulse').val('Update');
            var row = $(AnchorTag).parents('tr')[0];
            $('#ctl00_MainContent_txtPulse_Min').val($($(row).find('td')[1]).text());
            $('#ctl00_MainContent_txtBP_mm_Hg').val($($(row).find('td')[2]).text());
            $('#ctl00_MainContent_txtTemp_C').val($($(row).find('td')[3]).text());
            $('#ctl00_MainContent_txtRespiration_Min').val($($(row).find('td')[4]).text());
            $('#ctl00_MainContent_txtBlood').val($($(row).find('td')[5]).text());
            $('#ctl00_MainContent_txtWeight_Kg').val($($(row).find('td')[6]).text());
            $('#tblMoinitring input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
            $('#ctl00_MainContent_txtSaturation').val($($(row).find('td')[7]).text());

            $('#ctl00_MainContent_txtSaturationRoom').val($($(row).find('td')[8]).text());

            $('#ctl00_MainContent_txtSaturation_Oxygen1').val($($(row).find('td')[9]).text());
            $('#ctl00_MainContent_txtHeight').val($($(row).find('td')[10]).text());
            $('#ctl00_MainContent_txtBMI').val($($(row).find('td')[11]).text());
        }
        function editProgress(AnchorTag) {
            $('#btnAddPulse').val('Update');
            var row = $(AnchorTag).parents('tr')[0];
            $('#ctl00_MainContent_txtPulse_Min').val($($(row).find('td')[1]).text());
            $('#ctl00_MainContent_txtBP_mm_Hg').val($($(row).find('td')[2]).text());
            $('#ctl00_MainContent_txtTemp_C').val($($(row).find('td')[3]).text());
            $('#ctl00_MainContent_txtRespiration_Min').val($($(row).find('td')[4]).text());
            $('#ctl00_MainContent_txtBlood').val($($(row).find('td')[5]).text());
            $('#ctl00_MainContent_txtWeight_Kg').val($($(row).find('td')[6]).text());
            $('#tblMoinitring input[name=uurowid]').val($(row).find('input[name=uurowid]').val());
            $('#ctl00_MainContent_txtSaturation').val($($(row).find('td')[7]).text());

            $('#ctl00_MainContent_txtSaturationRoom').val($($(row).find('td')[8]).text());

            $('#ctl00_MainContent_txtSaturation_Oxygen1').val($($(row).find('td')[9]).text());
            $('#ctl00_MainContent_txtHeight').val($($(row).find('td')[10]).text());
            $('#ctl00_MainContent_txtBMI').val($($(row).find('td')[11]).text());
        }
        function bindDate() {
            $("#ctl00_MainContent_txtMedicine_Given_Date").datepicker({ dateFormat: 'mm/dd/yy' });
        }
        function deleteMedicine(AnchorTag) {
            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
        }
        function AddMonitering() {

            var pulse = $('#ctl00_MainContent_txtPulse_Min').val();
            var bp = $('#ctl00_MainContent_txtBP_mm_Hg').val();
            var temp = $('#ctl00_MainContent_txtTemp_C').val();
            var respiration = $('#ctl00_MainContent_txtRespiration_Min').val();
            var blood = $('#ctl00_MainContent_txtBlood').val();
            var weight = $('#ctl00_MainContent_txtWeight_Kg').val();
            var saturation = $('#ctl00_MainContent_txtSaturation').val();
            var saturationRoom = $('#ctl00_MainContent_txtSaturationRoom').val();
            var saturationOxygen = $('#ctl00_MainContent_txtSaturation_Oxygen1').val();

            if (pulse === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Pulse (per minute).',
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
            if (bp === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter BP (mm Hg).',
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
            //if (temp === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Temperature (°C).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (respiration === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Respiration (per minute).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (blood === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Blood Group or Blood Info.',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (weight === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Weight (Kg).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (saturation === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Saturation (%).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (saturationRoom === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Saturation (Room).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (saturationOxygen === "") {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please enter Saturation (Oxygen).',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}


            var datetime = '<%= DateTime.Now%>';
            if ($('#btnAddPulse').val() == 'Add') {
                var row = '<tr>' +
                    '<td>' + datetime + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtPulse_Min').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtBP_mm_Hg').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtTemp_C').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtRespiration_Min').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtBlood').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtWeight_Kg').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtSaturation').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtSaturationRoom').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtSaturation_Oxygen1').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtHeight').val() + '</td>' +
                    '<td>' + $('#ctl00_MainContent_txtBMI').val() + '</td>' +
                    '<td>' +
                    '<a href="#" onclick="editPlus(this)">Edit</a> | ' +
                    '<a href="#" onclick="deleteMedicine(this)">Delete</a>' +
                    '<input type="hidden" name="uurowid" value="' + uuid() + '" />' +
                    '</td>' +
                    '</tr>';
                var table = $('#tblMoinitring tbody');
                table.append(row);
                $('#ctl00_MainContent_txtPulse_Min').val('');
                $('#ctl00_MainContent_txtBP_mm_Hg').val('');
                $('#ctl00_MainContent_txtTemp_C').val('');
                $('#ctl00_MainContent_txtRespiration_Min').val('');
                $('#ctl00_MainContent_txtBlood').val('');
                $('#ctl00_MainContent_txtWeight_Kg').val('');
                $('#ctl00_MainContent_txtSaturation').val('');
            }
            else {

                var tid = $('#tblMoinitring input[name=uurowid]').val();
                var row = $('#tblMoinitring tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                $(row).find('td')[1].innerText = $('#ctl00_MainContent_txtPulse_Min').val();
                $(row).find('td')[2].innerText = $('#ctl00_MainContent_txtBP_mm_Hg').val();
                $(row).find('td')[3].innerText = $('#ctl00_MainContent_txtTemp_C').val();
                $(row).find('td')[4].innerText = $('#ctl00_MainContent_txtRespiration_Min').val();
                $(row).find('td')[5].innerText = $('#ctl00_MainContent_txtBlood').val();
                $(row).find('td')[6].innerText = $('#ctl00_MainContent_txtWeight_Kg').val();
                $(row).find('td')[7].innerText = $('#ctl00_MainContent_txtSaturation').val();
                $(row).find('td')[10].innerText = $('#ctl00_MainContent_txtHeight').val();
                $(row).find('td')[11].innerText = $('#ctl00_MainContent_txtBMI').val();

                $('#btnAddPulse').val('Add')
            }

        }
        function AddProgressNote() {

            var datetime = '<%= DateTime.Now%>';
            var NurseName = $('#ctl00_MainContent_ddlNurseName').find('option:selected').text();

            if ($('#btnAddProgress').val() == 'Add') {
                var row = '<tr> <td> ' + $('#ctl00_MainContent_txtDate').val() + ' </td><<td> ' + NurseName + '</td> <td> ' + $('#ctl00_MainContent_txtProgressNote').val() + '</td><td> ' + $('#ctl00_MainContent_txtInstruction').val() + ' </td> <td> <a href="#" onclick="editPlus(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                var table = $('#tblProdressNote tbody');
                table.append(row);
                $('#ctl00_MainContent_txtProgressNote').val('');
                $('#ctl00_MainContent_txtInstruction').val('');
                $('#ctl00_MainContent_ddlNurseName').val('');

            }
            else {
                var tid = $('#tblMoinitring input[name=uurowid]').val();
                var row = $('#tblMoinitring tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                $(row).find('td')[1].innerText = $('#ctl00_MainContent_txtPulse_Min').val();
                $(row).find('td')[2].innerText = $('#ctl00_MainContent_txtPulse_Min').val();
                $(row).find('td')[3].innerText = $('#ctl00_MainContent_txtTemp_C').val();
                $(row).find('td')[4].innerText = $('#ctl00_MainContent_txtRespiration_Min').val();
                $(row).find('td')[5].innerText = $('#ctl00_MainContent_txtWeight_Kg').val();
                $(row).find('td')[6].innerText = $('#ctl00_MainContent_txtSaturation').val();
                $('#btnAddPulse').val('Add')
            }
        }
        function AddOutput() {
            var datetime = '<%= DateTime.Now%>';
            var row = '<tr> <td> ' + datetime + ' </td><td> ' + $('#ctl00_MainContent_txtUrine').val() + '</td> <td> ' + $('#ctl00_MainContent_txtDrain1').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtDrain2').val() + '</td><td> ' + $('#ctl00_MainContent_txtDrain3').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtNG').val() + '<td> ' + $('#ctl00_MainContent_txtStool').val() + ' </td><td> ' + $('#ctl00_MainContent_txtVomiting').val() + '</td><td> ' + $('#ctl00_MainContent_TextBox2').val() + '</td><td> ' + $('#ctl00_MainContent_txtOther').val() + '</td><td>  <a href="#" onclick="deleteMedicine(this)"> Delete </a> </td> </tr>';
            var table = $('#tblOutput tbody');
            table.append(row);
            $('#ctl00_MainContent_txtUrine').val('');
            $('#ctl00_MainContent_txtDrain1').val('');
            $('#ctl00_MainContent_txtDrain2').val('');
            $('#ctl00_MainContent_txtDrain3').val('');
            $('#ctl00_MainContent_txtNG').val('');
            $('#ctl00_MainContent_txtStool').val('');
            $('#ctl00_MainContent_txtVomiting').val('');
            $('#ctl00_MainContent_txtOther').val('');
            $('#ctl00_MainContent_TextBox2').val('');
        }
        function AddIntake() {


            var intk = $('#ctl00_MainContent_ddlPerformed_By').find('option:selected').text();
            if (intk == 'Please Select' || intk == "Please Select") {
                intk = '';
            }

            var datetime = '<%= DateTime.Now%>';
            var row = '<tr> <td> ' + datetime + ' </td> <td><input type="hidden" name="txtIntakeMain" value="' + $('#ctl00_MainContent_ddlPerformed_By').val() + '" /><input type="hidden" name="txtIntakeItem" value="' + $('#ctl00_MainContent_txtItems').val() + '" /> ' + intk + ',' + $('#ctl00_MainContent_txtItems').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtQty').val() + '</td><td> <a href="#" onclick="deleteMedicine(this)"> Delete </a>  </td> </tr>';
            var table = $('#tblIntake tbody');
            table.append(row);
            $('#ctl00_MainContent_ddlPerformed_By').val('0');
            $('#ctl00_MainContent_txtItems').val('');
            $('#ctl00_MainContent_txtQty').val('');
        }
        function SaveMedicines() {

            var table = $('#tblMedicinesList');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                if ($(value).attr('data-new') !== 'true') return;
                MedicinesList.push({ 'Medicine_Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Recomended_Dosage': $($(value).find('td')[2]).text(), 'Frequency': $($(value).find('td')[3]).text(), 'Oral': $($(value).find('td')[4]).text(), 'Injection': $($(value).find('td')[5]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[6]).text(), 'Nurse_Name': $(value).find('td input[name=ddlNurseName]').val(), 'Duration': $($(value).find('td')[7]).text(), 'Special_Ins': $($(value).find('td')[8]).text(), 'Dosage_From': $($(value).find('td')[9]).text(), 'Dosage_Qty': $($(value).find('td')[10]).text(), 'Other_Ins': $($(value).find('td')[11]).text(), 'Type': $($(value).find('td')[12]).text(), });
            });
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

           var OutPatID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }
            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) {
                table.find('tbody tr').removeAttr('data-new');
                SaveMedicinesForMon();
            });
        }
        function SaveMedicinesForMon() {
            debugger;
            var table = $('#tblMedicinesListRegular');
            var tablePRN = $('#tblMedicinesListPRN');
            var tableStat = $('#tblMedicinesListSTAT');
            var MedicinesList = [];
            var MedicinesListPRN = [];
            var MedicinesListSTAT = [];

            table.find('tbody tr').each(function (key, value) {
                debugger;
                if ($(value).attr('data-new') !== 'true') return;

                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[4]).text(),
                    'Oral': $($(value).find('td')[6]).text(),
                    'Issue_Qty': $(value).find('td:eq(7) input').val(),
                    'Rec_Qty': $(value).find('td:eq(8) input').val(),
                    'Rtn_Qty': $(value).find('td:eq(13) input').val(),
                    'Injection': $($(value).find('td')[5]).text(),
                    'AttendingParamedical_Staff': $($(value).find('td')[11]).text(),
                    'Dosage_From': $($(value).find('td')[3]).text(),
                    'Dosage_Qty': $($(value).find('td')[2]).text(),
                    'Other_Instruction': $($(value).find('td')[10]).text(),
                    'Special_Instruction': $($(value).find('td')[11]).text(),
                    'ItemCode': $($(value).find('td')[15]).text(),
                    'Start_Date_Time': $($(value).find('td')[0]).text(),
                    'Stop_Date_Time': $($(value).find('td')[9]).text(),
                    'User': $($(value).find('td')[12]).text(),
                    'Max_PRN': "",
                    "Regular": true,
                    "STAT": false,
                    "PRN": false,
                    "Unlisted_Med": $(value).find('input[name=hdnUnlistedMed]').val() === '1'
                });
            });

            tableStat.find('tbody tr').each(function (key, value) {
                debugger;
                if ($(value).attr('data-new') !== 'true') return;
                var itemCode = $(this).find('input[name=hdnItemCode]').val() || '';
                MedicinesList.push({
                    'Medicine_Date': $($(value).find('td')[0]).text(),
                    'Medicine_Name': $($(value).find('td')[1]).text(),
                    'Frequency': $($(value).find('td')[4]).text(),
                    'Oral': $($(value).find('td')[6]).text(),               // Route
                    'Injection': $($(value).find('td')[5]).text(),          // Duration
                    'AttendingParamedical_Staff': $($(value).find('td')[10]).text(),   // Special Instructions
                    'Dosage_From': $($(value).find('td')[3]).text(),
                    'Dosage_Qty': $($(value).find('td')[2]).text(),
                    'Other_Instruction': $($(value).find('td')[9]).text(),
                    'Special_Instruction': $($(value).find('td')[10]).text(),
                    'ItemCode': itemCode,
                    'Start_Date_Time': $($(value).find('td')[0]).text(),
                    'Stop_Date_Time': "",
                    'High_Risk': "",
                    'User': $($(value).find('td')[11]).text(),
                    'Max_PRN': "",
                    "Regular": false,
                    "STAT": true,
                    "PRN": false,
                    'Issue_Qty': $($(value).find('td')[7]).find('input').val() || 0,
                    'Rec_Qty': $($(value).find('td')[8]).find('input').val() || 0,
                    "Unlisted_Med": $(value).find('input[name=hdnUnlistedMed]').val() === '1'
                });
            });

            tablePRN.find('tbody tr').each(function (key, value) {
                debugger;
                if ($(value).attr('data-new') !== 'true') return;
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
                    "Unlisted_Med": $(value).find('input[name=hdnUnlistedMed]').val() === '1'
                });
            });

            debugger;
            var InPatID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var ActualPatientID = $('#<%= hdfPatient_ID.ClientID%>').val(); 

            var MedicineDetails = {
                PatientID: InPatID == '(New)' ? 0 : InPatID,
                ActualPatientID: ActualPatientID, 
                MedicineList: MedicinesList
            }

            PageMethods.SaveMedicinesforMon(JSON.stringify(MedicineDetails), function (response) {
                table.find('tbody tr, tableStat tbody tr, tablePRN tbody tr').removeAttr('data-new');
                SaveInTake();
            });
        }
        function SaveAlRecord() {
            $('#btnSave').attr('disabled', true);
            $('#loadingimage').show();
            SavePatientMonitiring();
            SaveServices_Procedures();
            SaveRefer();
            localStorage.SelectedTabID = $("#tabs").tabs("option", "active");
        }

                function SaveRefer() {
            var ReferTo = document.getElementById('<%= ddlReferTo.ClientID%>').value;
            var WardID = document.getElementById('<%= ddlwardsRef.ClientID%>').value;
            var BedNo = document.getElementById('<%= txtBednoRef.ClientID%>').value;
            var RoomID = document.getElementById('<%= ddlroomRef.ClientID%>').value;
            var RoomType = document.getElementById('<%= ddlRoomTypeRef.ClientID%>').value;
            var PatientID = document.getElementById('<%= hdfPatient_ID.ClientID%>').value;
            var InPatientID = document.getElementById('<%= hdnInpatient_id.ClientID%>').value; // ← ADD THIS

            if (ReferTo == "0" || ReferTo == "") {
                $('#loadingimage').hide();
                return;
            }

            // Pass InPatientID as the second parameter
            PageMethods.SaveRefer(PatientID, InPatientID, ReferTo, WardID, BedNo, RoomID, RoomType, function (response) {
                $('#loadingimage').hide();
                if (response == "Success") {
                    alert("Referral saved successfully");
                    // Refresh previous info after saving
                    loadReferenceInformation();
                } else {
                    alert("Referral Error: " + response);
                }
            });
        }



        function SavemMaster() {

            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var Nursing_Plan = toHtml('#ctl00_MainContent_txt_Nursing_plan');
            var Nurse_Name_N = toHtml('#ctl00_MainContent_txt_Nurse_Name_Nursing');
            var MR_No = $('#txtMR_No').val();

            PageMethods.SavePatientMonitiring(btnsave, In_Mon_ID, Nursing_Plan, PatID, Nurse_Name_N, MR_No, function (response) {

                alert("Data Has been Successfully Saved");
                $('#btnSave').val("Update");
                window.location = "InPatientMonitoring.aspx?ID=" + response;
                $('#btnSave').val("Update");
            });
        }

        function New() {
            window.location = "InPatientMonitoring.aspx";
        }
        function showGraph() {

            var chek = document.getElementById('ctl00_MainContent_chkGraph').checked;
            if (chek === true) {
                $('#chart_div').show();
            }
            else {
                $('#chart_div').hide();
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





        function showTable() {
            var chek = document.getElementById('ctl00_MainContent_chkTable').checked;
            if (chek === true) {
                $('#tblMoinitring').show();
            }
            else {
                $('#tblMoinitring').hide();
            }
        }
        function GetMonDetail() {

            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                PageMethods.GetMonitringDetail(id, function (res) {

                    var MonitringDetail = JSON.parse(res);
                    var rows = '';
                    $.each(MonitringDetail, function (key, value) {
                        var timeStamp = parseInt(value.Mon_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Pulse_Min + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td>' + value.Temp_C + '</td><td> ' + value.Respiration_Min + ' </td> <td> ' + value.Blood_Suger + ' </td><td> ' + value.Weight_Kg + ' </td><td> ' + value.Saturation + ' </td><td > ' + value.Room_Air + ' </td><td > ' + value.With_Oxygen + ' </td><td > ' + value.Height_Cm + ' </td><td > ' + value.BMI + ' </td><td> <a href="#" onclick="editPlus(this)"> Edit </a> | <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblMoinitring tbody').html(rows);
                });
            }
        }
        function GetInTake() {

            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                PageMethods.GetInTakeDetail(id, function (res) {

                    var InTakeDetail = JSON.parse(res);
                    var rows = '';
                    $.each(InTakeDetail, function (key, value) {

                        var timeStamp = parseInt(value.Intake_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.Main_ItemName == null || value.Main_ItemName == "null" || value.Main_ItemName == 'null') {
                            value.Main_ItemName = '';
                        }
                        rows += '<tr> <td> ' + date + ' </td><td><input type="hidden" value="' + value.Item + '" name="txtIntakeItem" /><input type="hidden" value="' + value.Main_Item + '" name="txtIntakeMain" /> ' + value.Main_ItemName + ',' + value.Item + ' </td><td>' + value.Qty + '</td><td> <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblIntake tbody').html(rows);
                });
            }
        }
        function LoadInTakeHistory(PatientID) {
            PageMethods.LoadInTakeHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var timeStamp = parseInt(value.Intake_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    if (value.Main_ItemName == null || value.Main_ItemName == "null" || value.Main_ItemName == 'null') {
                        value.Main_ItemName = '';
                    }
                    rows += '<tr> <td> ' + date + ' </td><td> ' + value.Main_ItemName + ',' + value.Item + ' </td><td>' + value.Qty + '</td></tr>';
                });
                $('#tblHistoryIntake tbody').html(rows);
            });
        }
        function LoadOutputHistory(PatientID) {
            PageMethods.LoadOutputHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var timeStamp = parseInt(value.Output_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    rows += '<tr> <td> ' + date + ' </td><td> ' + value.Urine + ' </td><td>' + value.Drain1 + '</td><td> ' + value.Drain2 + ' </td><td>' + value.Drain3 + '</td><td> ' + value.NG + ' </td><td>' + value.Stool + '</td><td> ' + value.Vomiting + ' </td><td> ' + value.Stoma + ' </td><td>' + value.Other + '</td></tr>';
                });
                $('#tblOutputHistory tbody').html(rows);
            });
        }
        function LoadProgressNoteHistory(PatientID) {
            PageMethods.LoadProgressNoteHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var timeStamp = parseInt(value.Progress_Notes_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    rows += '<tr> <td> ' + date + ' </td><td> ' + value.Nurse_Name + ' </td><td>' + value.Progress_Note + '</td><td>' + value.Over_Instruction + '</td></tr>';
                });
                $('#tblProgressNoteHistory tbody').html(rows);
            });
        }
        function LoadHistory() {

            if ($('#<%= hdfPatient_ID.ClientID%>').val() != '(New)') {
                LoadVitalParametersHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadInTakeHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadOutputHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadProgressNoteHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadServices_Procedures($("#<%= hdfPatient_ID.ClientID%>").val());
            }
        }
        function LoadVitalParametersHistory(PatientID) {
            $('#tblHistoryHeader').html('<h2 class="hedingcolor">Loading Previous History Please Wait....</h2>')
            PageMethods.LoadMonitertingForHistory(PatientID, function (res) {

                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var timeStamp = parseInt(value.Mon_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    rows += '<tr> <td> ' + date + ' </td> <td> ' + value.Pulse_Min
                        + ' </td> <td> ' + value.BP_mm_Hg + ' </td> <td> ' + value.Temp_C + ' </td><td> ' + value.Respiration_Min + ' </td> <td> ' + value.Blood_Suger + ' </td> <td> ' + value.Weight_Kg + '</td><td> ' + value.Saturation + '</td><td > ' + value.Room_Air + ' </td><td > ' + value.With_Oxygen + ' </td><td > ' + value.Height_Cm + ' </td><td > ' + value.BMI + ' </td></tr>';
                });

                $('#tblVitalParametersHistory tbody tr').remove();
                $('#tblVitalParametersHistory tbody').html(rows);
                $('#tblHistoryHeader').html('<h2 class="hedingcolor">Previous History</h2>')
            }, function (e) { });
        }
        function GetOutput() {
            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                PageMethods.GetOutputDetail(id, function (res) {
                    var inPatOutputDetail = JSON.parse(res);
                    var rows = '';
                    $.each(inPatOutputDetail, function (key, value) {
                        var timeStamp = parseInt(value.Output_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Urine + ' </td> <td> ' + value.Drain1 + ' </td><td>' + value.Drain2 + '</td><td>' + value.Drain3 + '</td><td>' + value.NG + '</td><td>' + value.Stool + '</td><td>' + value.Vomiting + '</td><td>' + value.Stoma + '</td><td>' + value.Other + '</td><td> <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblOutput tbody').html(rows);
                });
            }
        }
        function GetProgressNotes() {
            
            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                var id = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
                PageMethods.GetProgressNotesDetail(id, function (res) {
                    
                    var inPatOutputDetail = JSON.parse(res);
                    var rows = '';
                    $.each(inPatOutputDetail, function (key, value) {
                        var timeStamp = parseInt(value.Progress_Notes_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Nurse_Name + ' </td> <td> ' + value.Progress_Note + ' </td><td>' + value.Over_Instruction + '</td>td> <a href="#" onclick="deleteMedicine(this)"> Delete </a>  </td> <td> <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a>  </td> </tr>';
                    });
                    $('#tblProdressNote tbody').html(rows);
                });
            }
        }

        function LoadMedicines() {
            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicines($('#<%= txtInPatient_Mon_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
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
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row"' : '') + '> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td style="display:none"> ' + value.Injections + ' </td><td> <input type="text"  id="ddlNurseName" name="ddlNurseName" style="width:80px !important;" value="' + value.Nurse_Name + '"/></td><td>' + value.Injections + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td><td>' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '') + ' <input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" /></td> </tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                });
            }
        }
        function LoadMedicinesFormInPatient(PatientID) {
          
            PageMethods.LoadMedicinesFormInPat(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    debugger;
                    var rowmodalAppendload = '';
                    var rowsRegular = '';
                    var rowsPRN = '';
                    var rowsStat = '';
                    var role;
                    var allowMedicationEdit = false; 
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var Username = '<%= AppConfig.UserName%>';
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        role = value.userrole;
                        allowMedicationEdit = value.AllowMedicationEdit;
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        var s1 = parseInt(value.Start_Date_Time.substr(6, 10));
                        var Start_Date = moment.unix(s1).format('MM/DD/YYYY hh:mm:ss A');
                        var Req_Qty = value.Req_Qty
                        if (Req_Qty == null || Req_Qty == 'null') {
                            Req_Qty = 0
                        }
                        var Rcv_Qty = value.Rcv_Qty
                        if (Rcv_Qty == null || Rcv_Qty == 'null') {
                            Rcv_Qty = 0
                        }
                        var Rtn_Qty = value.Rtn_Qty
                        if (Rtn_Qty == null || Rtn_Qty == 'null') {
                            Rtn_Qty = 0
                        }
                        debugger;
                        if (value.Regular == true || value.Regular == "1") {
                            if (value.Stop_Date_Time == null) {
                                Stop_Date = '';
                            }
                            else {
                                var s2 = parseInt(value.Stop_Date_Time.substr(6, 10));
                                var Stop_Date = moment.unix(s2).format('MM/DD/YYYY hh:mm:ss A');
                            }
                            rowsRegular += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row unlisted-saved"' : '') + '> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td>  <td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty + '"   name="RecQty"  placeholder="Enter value" /></td> <td>' + Stop_Date + '</td> <td> ' + value.Other_Instruction + ' </td>' + '<td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td> <input type="text" class="form-control routeInput" value="' + Rtn_Qty + '"   name="RtnQty"  placeholder="Enter value" /></td><td class="eddit">' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + '<input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" /> </td><td style="display:none;">' + value.Item_Code + '</td></tr>';

                        }
                        else if (value.PRN == true) {
                            rowsPRN += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row unlisted-saved"' : '') + '> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td style="background-color: red;"> ' + value.Max_PRN_Dose + ' </td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td class="eddit">' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + '<input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" />  </td> <td style="display:none;"></td></tr>';

                        }
                        else if (value.STAT == true) {

                            rowsStat += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td> ' + value.Other_Instruction + '</td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td>' + '<td>' + value.Username + '</td><td><input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;"></td></tr>';

                        }

                        rowmodalAppendload += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td>' + value.Other_Instruction + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td> </td></tr>';



                    });
                    setTimeout(function () {

                        $('#tblDischargeMedication tbody').html(rowmodalAppendload);
                        $('#tblMedicinesListRegular tbody').html(rowsRegular);
                        $('#tblMedicinesListSTAT tbody').html(rowsStat);
                        $('#tblMedicinesListPRN tbody').html(rowsPRN);

                        if (allowMedicationEdit == true) {
                            $('.eddit a').show();
                        }
                        else {
                            $('.eddit a').hide();
                        }

                    }, 6000)


                    

                });
                   
               }
        function LoadMedicinesForMon() {
            debugger;
            if ($('#<%= txtInPatient_Mon_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicinesForMon($('#<%= txtInPatient_Mon_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    debugger;
                    var rowmodalAppendload = '';
                    var rowsRegular = '';
                    var rowsPRN = '';
                    var rowsStat = '';
                    var role;
                    var allowMedicationEdit = false;
                    $.each(Medicines, function (key, value) {
                        debugger;
                        var Username = '<%= AppConfig.UserName%>';
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        role = value.userrole;
                        allowMedicationEdit = value.AllowMedicationEdit;
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        if (value.Other_Instruction == null || value.Other_Instruction == 'null') value.Other_Instruction = '';
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        var s1 = parseInt(value.Start_Date_Time.substr(6, 10));
                        var Start_Date = moment.unix(s1).format('MM/DD/YYYY hh:mm:ss A');
                        var Req_Qty = value.Req_Qty
                        if (Req_Qty == null || Req_Qty == 'null') {
                            Req_Qty = 0
                        }
                        var Rcv_Qty = value.Rcv_Qty
                        if (Rcv_Qty == null || Rcv_Qty == 'null') {
                            Rcv_Qty = 0
                        }
                        var Rtn_Qty = value.Rtn_Qty
                        if (Rtn_Qty == null || Rtn_Qty == 'null') {
                            Rtn_Qty = 0
                        }
                        debugger;
                        if (value.Regular == true || value.Regular == "1") {
                            if (value.Stop_Date_Time == null) {
                                Stop_Date = '';
                            }
                            else {
                                var s2 = parseInt(value.Stop_Date_Time.substr(6, 10));
                                var Stop_Date = moment.unix(s2).format('MM/DD/YYYY hh:mm:ss A');
                            }
                            rowsRegular += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row unlisted-saved"' : '') + '> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td>  <td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty + '"   name="RecQty"  placeholder="Enter value" /></td> <td>' + Stop_Date + '</td> <td> ' + value.Other_Instruction + ' </td>' + '<td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td> <input type="text" class="form-control routeInput"  value="' + Rtn_Qty + '"   name="RtnQty"  placeholder="Enter value" /></td><td class="eddit">' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + '<input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" />  </td><td style="display:none;">' + value.Item_Code + '</td></tr>';

                        }
                        else if (value.PRN == true) {
                            rowsPRN += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row unlisted-saved"' : '') + '> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td style="background-color: red;"> ' + value.Max_PRN_Dose + ' </td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td><td class="eddit">' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + '<input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" />  </td> <td style="display:none;"></td></tr>';

                        }
                        else if (value.STAT == true) {

                            rowsStat += '<tr' + (value.Unlisted_Med == true ? ' class="unlisted-row unlisted-saved"' : '') + '> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td> ' + value.Other_Instruction + '</td><td> ' + value.Other_Instruction + '</td>' + ' <td>' + value.AttendingParamedical_Staff + '</td>' + '<td>' + value.Username + '</td><td class="eddit">' + (value.Unlisted_Med == true ? '<span class="unlisted-tag">Unlisted</span>' : '<a href="#" onclick="editMedicine(this)"> Edit </a> <a href="#" onclick="deleteMedicine(this)"> Delete </a>') + '<input type="hidden" name="uurowid" value=' + uuid() + ' /><input type="hidden" name="hdnUnlistedMed" value="' + (value.Unlisted_Med == true ? '1' : '0') + '" />  </td><td style="display:none;"></td></tr>';

                        }

                        rowmodalAppendload += '<tr> <td> <input type="hidden" name="testDate" value="' + Start_Date + '">' + Start_Date + ' </td><td> ' + value.Medicine_Name + '</td><td> ' + value.Dosage_Qty + '</td><td> ' + value.Dosage_From + '</td> <td> ' + value.Frequency + ' </td><td> ' + value.Injections + '</td>   <td> ' + value.Oral + ' </td><td> <input type="text" class="form-control routeInput" value="' + Req_Qty + '"   name="IssueQty"  placeholder="Enter value" /></td><td> <input type="text" class="form-control routeInput" value="' + Rcv_Qty +'"   name="RecQty"  placeholder="Enter value" /></td><td>' + value.Other_Instruction + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Username + '</td> </td></tr>';



                    });
                    setTimeout(function () {

                        $('#tblDischargeMedication tbody').html(rowmodalAppendload);
                        $('#tblMedicinesListRegular tbody').html(rowsRegular);
                        $('#tblMedicinesListSTAT tbody').html(rowsStat);
                        $('#tblMedicinesListPRN tbody').html(rowsPRN);

                        if (allowMedicationEdit == true) {
                            $('.eddit a').show();
                        }
                        else {
                            $('.eddit a').hide();
                        }

                    }, 6000)


                    

                });
                   }
               }

        function SavePatientMonitiring() {

            var table = $('#tblMoinitring');
            var MoinitringList = [];
            table.find('tbody tr').each(function (key, value) {

                MoinitringList.push({ 'Date': $($(value).find('td')[0]).text(), 'Pulse_Min': $($(value).find('td')[1]).text(), 'BP_mm_Hg': $($(value).find('td')[2]).text(), 'Temp_C': $($(value).find('td')[3]).text(), 'Respiration_Min': $($(value).find('td')[4]).text(), 'Blood_Suger': $($(value).find('td')[5]).text(), 'Weight_Kg': $($(value).find('td')[6]).text(), 'Saturation': $($(value).find('td')[7]).text(), 'Room_Air': $($(value).find('td')[8]).text(), 'With_Oxygen': $($(value).find('td')[9]).text(), 'Height': $($(value).find('td')[10]).text(), 'BMI': $($(value).find('td')[11]).text() });

            });
            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
          var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var MonDetails = { InPatient_Mon_ID: In_Mon_ID == '(New)' ? 0 : In_Mon_ID, Patient_ID: PatID, MonList: MoinitringList }

            PageMethods.SavePatientMonitiringDetail(btnsave, JSON.stringify(MonDetails), function (response) { SaveMedicines(); });
        }

        function SaveInTake() {
            
            var table = $('#tblIntake');
            var IntakeList = [];
            table.find('tbody tr').each(function (key, value) {
                
                IntakeList.push({ 'IntakeDate': $($(value).find('td')[0]).text(), 'Main_Item': $(value).find('td input[name=txtIntakeMain]').val(), 'Item': $(value).find('td input[name=txtIntakeItem]').val(), 'Qty': $($(value).find('td')[2]).text() });

            });
            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            
            var IntakeList = { InPatient_Mon_ID: In_Mon_ID == '(New)' ? 0 : In_Mon_ID, Patient_ID: PatID, IntakeListt: IntakeList }

            PageMethods.SaveIntakeDetail(btnsave, JSON.stringify(IntakeList), function (response) { SaveOutput(); });
        }

        function SaveOutput() {

            var table = $('#tblOutput');
            var OutputList = [];
            table.find('tbody tr').each(function (key, value) {

                OutputList.push({ 'Date': $($(value).find('td')[0]).text(), 'Urine': $($(value).find('td')[1]).text(), 'Drain1': $($(value).find('td')[2]).text(), 'Drain2': $($(value).find('td')[3]).text(), 'Drain3': $($(value).find('td')[4]).text(), 'NG': $($(value).find('td')[5]).text(), 'Stool': $($(value).find('td')[6]).text(), 'Vomiting': $($(value).find('td')[7]).text(), 'Stoma': $($(value).find('td')[8]).text(), 'Other': $($(value).find('td')[9]).text() });

            });
            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutputDetails = { InPatient_Mon_ID: In_Mon_ID == '(New)' ? 0 : In_Mon_ID, Patient_ID: PatID, OutputListt: OutputList }

            PageMethods.SaveOutputDetail(btnsave, JSON.stringify(OutputDetails), function (response) { SaveProgressNotes(); });
        }
        function SaveProgressNotes() {
            var table = $('#tblProdressNote');
            var ProgressNotesList = [];
            table.find('tbody tr').each(function (key, value) {
                ProgressNotesList.push({ 'Date': $($(value).find('td')[0]).text(), 'NurseName': $($(value).find('td')[1]).text(), 'ProgressNote': $($(value).find('td')[2]).text(), 'OverInstruction': $($(value).find('td')[3]).text() });
            });
            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var ProgressNotesListDetails = { InPatient_Mon_ID: In_Mon_ID == '(New)' ? 0 : In_Mon_ID, Patient_ID: PatID, ProgressNotesListt: ProgressNotesList }
            PageMethods.SaveProgressNotesDetail(btnsave, JSON.stringify(ProgressNotesListDetails), function (response) { SaveInstructionDetail(); });
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
                loadServices();
            }
        }
        function enabledisable() {
            if (chkBox == true) {

                rdo_false();
            }
            if (chkBox == false) {
                rdo_true();
            }
        }

        // function Appendtestintable(patid) {

        //     var in_patient_Id = $('#ctl00_MainContent_hdnInpatient_id').val()
        //     $('#tblLabtest tbody').empty();

        //     PageMethods.GetTestListForHistoryIPD(in_patient_Id, function (res) {
        //             var test = JSON.parse(res);
        //             var Result = 'Result';
        //             $.each(test, function (key, value) {
        //                 var Result = 'Pendding';
        //                 var timeStamp = parseInt(value.Date.substr(6, 10));
        //                 var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
        //                 if (value.L_R_Rotation_ID == null) value.L_R_Rotation_ID = "";
        //                 var datearray = date.split("/");
        //                 var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
        //                 debugger;
        //                 if (value.isApproved == true) {
        //                     Result = "View Result";
        //                     Sample = "Yes";
        //                     $("#btnprint").attr('disabled', false)
        //                 }
        //                 if (value.isApproved == false) {
        //                     Result = "Waiting";
        //                     Sample = "No";
        //                     $("#btnprint").attr('disabled', true)
        //                 }

        //                 if (value.Test_ID != 0) {
        //                     row = '<tr>' +
        //                         '<td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
        //                         '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
        //                         '<input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/>' +
        //                         '<input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/>' +
        //                         '<input type="hidden" name="txtRotation" value="0">' +
        //                         '<input type="hidden" name="txtGroupCategory" value="0">' +
        //                         (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
        //                         ' ' + value.Test_Name + ' ' +
        //                         (value.GroupName == null ? ' ' : ', ' + value.GroupName) +
        //                         '</td>' +
        //                         '<td>' + Result + '</td>' +
        //                         '<td>' + value.DoctorName + '</td>' +
        //                         '<td>' +
        //                         '<a style="border-radius: 4px;background-color:#308665db !important;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PreviewReport(this)" id="btnprint">' +
        //                         '<i class="fa fa-print" style="color:white !important;"></i></a>' +
        //                         '</td>' +
        //                         '<td style="display:none;">' +
        //                         '<input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.Lab_Test_ID + '" />' +
        //                         '<input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
        //                         '<input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Column + '" />' +
        //                         '<input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.Patient_ID + '" />' +
        //                         '<input type="hidden" name="Lab_Test_Detail_ID" id="Lab_Test_Detail_ID" value="' + value.Lab_Test_Detail_ID + '" />' +
        //                         '</td></tr>';
        //                 }
        //                 $('#tblLabtest tbody').append(row);
        //                 console.log(row);
        //             });
        //         });
        // }

        function Appendtestintable(patid) {

            var in_patient_Id = $('#ctl00_MainContent_hdnInpatient_id').val();
            $('#tblLabtest tbody').empty();

            PageMethods.GetTestListForHistoryIPD(in_patient_Id, function (res) {

                var test = JSON.parse(res);

                $.each(test, function (key, value) {

                    var Result = "";
                    var Sample = "";

                    var timeStamp = parseInt(value.Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                    if (value.L_R_Rotation_ID == null)
                        value.L_R_Rotation_ID = "";

                    var datearray = date.split("/");
                    var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                    if (value.isApproved) {
                        Result = "View Result";
                        Sample = "Yes";
                    }
                    else {
                        Result = "Waiting";
                        Sample = "No";
                    }

                    var printButton = "";

                    if (value.isApproved) {
                        printButton =
                            '<a href="#" ' +
                            'style="border-radius:4px;background-color:#308665db;margin-left:4px;color:white;padding:5px 8px;" ' +
                            'onclick="PreviewReport(this); return false;">' +
                            '<i class="fa fa-print" style="color:white;"></i>' +
                            '</a>';
                    }
                    else {
                        printButton =
                            '<a href="javascript:void(0);" ' +
                            'style="border-radius:4px;background-color:#bfbfbf;margin-left:4px;color:white;padding:5px 8px;pointer-events:none;cursor:not-allowed;opacity:0.5;">' +
                            '<i class="fa fa-print" style="color:white;"></i>' +
                            '</a>';
                    }

                    if (value.Test_ID != 0) {

                        var row = '<tr>' +
                            '<td>' +
                            '<input type="hidden" name="testDate" value="' + newdate + '">' +
                            newdate +
                            '</td>' +

                            '<td>' +
                            '<input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/>' +
                            '<input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/>' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="0">' +
                            (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                            ' ' + value.Test_Name +
                            (value.GroupName == null ? '' : ', ' + value.GroupName) +
                            '</td>' +

                            '<td>' + Result + '</td>' +

                            '<td>' + value.DoctorName + '</td>' +

                            '<td>' + printButton + '</td>' +

                            '<td style="display:none;">' +
                            '<input type="hidden" name="List_Of_Test_IDs" value="' + value.Lab_Test_ID + '" />' +
                            '<input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
                            '<input type="hidden" name="Report_Colum" value="' + value.Report_Column + '" />' +
                            '<input type="hidden" name="test_wise_id" value="' + value.Patient_ID + '" />' +
                            '<input type="hidden" name="Lab_Test_Detail_ID" value="' + value.Lab_Test_Detail_ID + '" />' +
                            '</td>' +
                            '</tr>';

                        $('#tblLabtest tbody').append(row);
                    }
                });
            });
        }

        function PreviewReport($this) {
            var tbl = $($($this).parents('tr')[0]);
            var hdn_Patient_ID = tbl.find("td").find("input[id=Patient_Id]").val();
            var ChkLetterHead = true;
            var ListOfTestIDs = '';
            var ListTransID = '';
            var Report_Column = '';
            var LabTestDetailsID = '';
            var billdetailid = '';

            Report_Column = tbl.find('td').find('input[name=Report_Colum]').val();
            ListOfTestIDs = tbl.find('td').find('input[name=testID]').val();
            test_wise_ids = tbl.find('td').find('input[name=test_wise_id]').val();
            ListTransID = tbl.find('td').find('input[name=List_Of_Test_IDs]').val();
            LabTestDetailsID = tbl.find('td').find('input[name=Lab_Test_Detail_ID]').val();
            billdetailid = tbl.find('td').find('input[name=Bill_Details_ID]').val();
            var url = '../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + billdetailid + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead;
            window.open(url, '_blank');
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function loadtokenInputsDefault() {
            debugger;
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=In_Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#hdfPatient_ID").val(item.id);

                            loadAjax();
                            LoadInstruction();
                            loadReferenceInformation();
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
        }
        function loadAjax() {
            debugger;
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            $.ajax({
                type: "POST",
                url: "InPatientMonitoring.aspx/GetDetail",
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
                var mydate = new Date(Date.parse(data.d.Created_time));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vLbl_WardName.ClientID %>').text(data.d.Ward_Name || '');
                $('#<%= vLbl_BedNo.ClientID %>').text(data.d.Bed_No || '');
                $('#ctl00_MainContent_hdnInpatient_id').val(data.d.inPatient);
                $("#hdnipd_id").val(data.d.in_patient_id);
                console.log(data.d.in_patient_id);

                if (data.d.MR_No && data.d.MR_No !== '') {
                    $('#txtMR_No').val(data.d.MR_No);
                    $('#txtMR_No').prop('disabled', true);
                } else {
                    $('#txtMR_No').val('');
                    $('#txtMR_No').prop('disabled', false);
                }

                CheckDischarge();


            }
        }
        function loadtokenInputs(data) {
            debugger;
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=In_Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger;
                        $("#hdfPatient_ID").val(item.id);
                        loadAjax();
                        loadReferenceInformation();
                    }
                });
        }
        $(function () {
            $("#tabs").tabs();
            GetLastSelectedTab();
            loadWaitingList();
        });
        function loadWaitingList() {
            var id = '<%=Request.QueryString["ID"]%>';
            var inPatientID = '<%=Request.QueryString["InPatientID"]%>';
            if ((id == "" || id == null) && (inPatientID == "" || inPatientID == null)) {
                RemoveExtraDepts_WL();
            }
        }
        function GetLastSelectedTab() {

            $("#tabs").tabs("option", "active", localStorage.SelectedTabID);
        }
        function checkRepeat() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeat(patID, function (data) {

                $.each(JSON.parse(data), function (key, value) {
                    window.location = "InPatientMonitoring.aspx?ID=" + value.InPatient_Mon_ID;
                    $('#btnSave').val("Update");
                });
            }, function (error) { })
        }
        function CountTotalQty() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.CountQty(patID, function (data) {
                var total = 0.00;
                $.each(JSON.parse(data), function (key, value) {
                    var samt = value.Qty;
                    if (samt != '') {
                        var amt = parseFloat(samt);
                        if (isNaN(amt) == false) {
                            total += amt;
                        }
                    }
                });
                $('#ctl00_MainContent_lblTotalDays').text(total);
            }, function (error) { })
        }
        function CountTotalQtyOutPut() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.CountQtyOutput(patID, function (data) {
                var total = 0.00;
                $.each(JSON.parse(data), function (key, value) {

                    var samt = value.Qty;
                    if (samt != '') {
                        var amt = parseFloat(samt);
                        if (isNaN(amt) == false) {
                            total += amt;
                        }
                    }
                });
                $('#ctl00_MainContent_lblTotalDaysOutput').text(total);
            }, function (error) { })
        }
        function CountPerQty() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.CountPerQty(patID, function (data) {
                var total = 0.00;
                $.each(JSON.parse(data), function (key, value) {

                    var samt = value.Qty;
                    if (samt != '') {
                        var amt = parseFloat(samt);
                        if (isNaN(amt) == false) {
                            total += amt;
                        }
                    }
                });
                $('#ctl00_MainContent_lblPerDays').text(total);

            }, function (error) { })
        }
        function CountPerQtyOutput() {
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.CountPerQtyOutput(patID, function (data) {
                var total = 0.00;
                $.each(JSON.parse(data), function (key, value) {

                    var samt = value.Qty;
                    if (samt != '') {
                        var amt = parseFloat(samt);
                        if (isNaN(amt) == false) {
                            total += amt;
                        }
                    }
                });
                $('#ctl00_MainContent_lblPerDaysOutput').text(total);

            }, function (error) { })
        }
        function LoadMedicationHistory(PatientID) {
            debugger;
            if (PatientID != '(New)') {
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    var Stop_Date;
                    $.each(Medicines, function (key, value) {
                        var type = '';
                        debugger;
                        if (value.Regular == true) {
                            type = "REGULAR";
                        }

                        if (value.STAT == true) {
                            type = "STAT";
                        }

                        if (value.PRN == true) {
                            type = "PRN";
                        }
                        if (value.Stop_Date_Time == null) {
                            Stop_Date = '';
                        }
                        else {
                            var s2 = parseInt(value.Stop_Date_Time.substr(6, 10));
                            Stop_Date = moment.unix(s2).format('MM/DD/YYYY hh:mm:ss A');
                        }
                        debugger;
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td style="display:none"> ' + value.Req_Qty + ' </td> <td>' + value.Req_Qty + '</td><td>' + value.Rcv_Qty + '</td><td>' + Stop_Date + '</td><td>' + value.AttendingParamedical_Staff + '</td> <td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td></tr>';
                        // rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td style="display:none"> ' + value.Req_Qty + ' </td> <td>' + value.Req_Qty + '</td><td>' + value.Rcv_Qty + '</td><td>' + Stop_Date + '</td><td>' + value.AttendingParamedical_Staff + '</td> <td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td><td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                    });
                    debugger;
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                    $('#tblHistoryMedications tbody tr').remove();
                    $('#tblHistoryMedications tbody').html(rows);
                    $('#HeaderHistoryMedications').html('<h2 class="color">Previous History</h2>');
                });
            }
        }
        function SaveInstructionDetail() {

            
            var table = $('#tblInstruction2');
            var InstructionList = [];
            table.find('tbody tr').each(function (key, value) {
                
                InstructionList.push({ 'Instruction_Date': $($(value).find('td')[0]).text(), 'Doctor_Status': DocStatus[1], 'Doctor_ID': $(value).find('td input[name=txtDoctorValue]').val(), 'Doctor_Instruction': $($(value).find('td')[2]).text(), 'ChekInstruction': $(value).find('td input[name=chekInstruction]')[0].checked, 'Nurse_Name': $(value).find('td input[name=ddlNurseName]').val(), 'Progress_Note': $(value).find('td input[name=txtprogress]').val(), });

            });

            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
             var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var ipd = $('#ctl00_MainContent_hdnInpatient_id').val();

            var IntructionDetails = { Pat: PatID, InPatientID: ipd, ListIns: InstructionList, listDel: ArrDel }
            
            PageMethods.InsertInstuctionDetail(btnsave, JSON.stringify(IntructionDetails), function (response) {
                SavemMaster();

            });

        }

        
        function select3(anchor) {
            
            debugger;
            var row = $(anchor).parents('tr')[0];
            var OPD = $($(row).find('td')[0]).val();
            var MedicineName = $($(row).find('td')[1]).text();
            var Dosage = $($(row).find('td')[2]).text();
            var Frequency = $($(row).find('td')[3]).text();
            var Routes = $($(row).find('td')[4]).text();
            var Duration = $($(row).find('td')[7]).text();
            var Special_Ins = $($(row).find('td')[8]).text();
            var Dosage_From = $($(row).find('td')[9]).text();
            var Dosage_Qty = $($(row).find('td')[10]).text();
            var Other_Ins = $($(row).find('td')[11]).text();
            var Type = $($(row).find('td')[12]).text();
            var date = '<%= DateTime.Now %>';
            var row = '<tr><td>' + date + '</td><td>' + MedicineName + '</td><td>' + Dosage + '</td><td>' + Frequency + '</td><td> ' + Routes + '</td><td style="display:none"> ' + Duration + '</td><td> <input type="text"  id="ddlNurseName" name="ddlNurseName" style="width:80px !important;"/></td><td>' + Duration + '</td><td>' + Special_Ins + '</td><td>' + Dosage_From + '</td><td>' + Dosage_Qty + '</td><td>' + Other_Ins + '</td><td>' + Type + '</td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteMedicine(this)">Delete</a></td></tr>';
            $('#tblMedicinesList').append(row);
        }
        var ArrDel = [];
        var DocStatus;
        function selectDoctorInstruction(anchor) {
            
            var row = $(anchor).parents('tr')[0];
            var Date = $($(row).find('td')[0]).text();
            var Doctor_name = $($(row).find('td')[1]).text();

            DocStatus = Doctor_name.split(',')
            var Doctor_ID = $($(row).find('td')[1]).find('input[name="txtDoctorValue"]').val();
            var Doctor_Note_ID = $($(row).find('td')[1]).find('input[name="txtDoctorNoteID"]').val();
            var Instruction = $($(row).find('td')[2]).text();
            var Nurse_Name = $($(row).find('td')[3]).find('input[name="ddlNurseName"]').val();
            var ProgresNote = $($(row).find('td')[2]).find('input[name="txtprogress"]').val();

            var date = '<%= DateTime.Now %>';
            rows = '<tr> <td> ' + Date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="">  ' + Doctor_name + '<input type="hidden" name ="txtDoctorValue" value="' + Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + ProgresNote + '">' + Instruction + '</td><td><input type="text" name="ddlNurseName" value="' + Nurse_Name + '" style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction" checked  disabled/></td> </tr>';
            $('#tblInstruction2 tbody').append(rows);

            ArrDel.push({ 'Doctor_Note_ID': Doctor_Note_ID, });
            $(row).remove();
        }
        function LoadInstructionEdit() {
            
            if ($('#<%= txtPatient_ID.ClientID%>').val() != '') {
                PageMethods.GetInstructionEdit($('#<%= txtPatient_ID.ClientID%>').val(), function (res) {
                    
                    var Instruction = JSON.parse(res);
                    var rows = '';
                    $.each(Instruction, function (key, value) {
                        var timeStamp = parseInt(value.Doctor_Note_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        if (value.Doctor_Status == null)
                            value.Doctor_Status = "";
                        DocStatus = value.Doctor_Status;
                        
                        if (value.Nurse_Name == null) value.Nurse_Name = '';
                        rows += '<tr> <td> ' + date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Doctor_Status + '">  ' + value.DoctorName + ',' + value.Doctor_Status
                            + '<input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + value.Progress_Note + '">' + value.Doctor_Instruction + '</td><td><input type="text" value="' + value.Nurse_Name + '" name="ddlNurseName"  style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction"  ' + (value.IsLatest ? 'checked' : '') + ' onclick="selectDoctorInstruction(this)" checked disabled style="width: 20px;" /></td> </tr>';
                    });
                    $('#tblInstruction2 tbody').html(rows);
                });
            }
        }
        function LoadInstruction() {
            
            if ($('#<%= txtPatient_ID.ClientID%>').val() != '') {
                PageMethods.GetInstruction($('#<%= txtPatient_ID.ClientID%>').val(), function (res) {
                    
                    var Instruction = JSON.parse(res);
                    var rows = '';
                    $.each(Instruction, function (key, value) {
                        var timeStamp = parseInt(value.Admission_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        if (value.DoctorStatus == null)
                            value.DoctorStatus = "";
                        if (value.RN_Special_Instruction == "") {

                        }
                        else {
                            if (value.RN_Special_Instruction == ' ,') {
                            }
                            else {
                                
                                if (value.Nurse_Name == null) value.Nurse_Name = '';
                                rows += '<tr> <td> ' + date + ' </td> <td><input type="hidden" name ="txtDoctorNoteID" value="' + value.Doctor_Note_ID + '"><input type="hidden" name ="txtDoctorStatus" value="' + value.Doctor_Status + '">  ' + value.DoctorName
                                    + ',' + value.DoctorStatus
                                    + '<input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + value.Progress_Note + '">' + value.RN_Special_Instruction + '</td><td><input type="text" value="' + value.Nurse_Name + '" name="ddlNurseName"  style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction"  ' + (value.IsLatest ? 'checked' : '') + ' onclick="selectDoctorInstruction(this)" /></td> </tr>';
                            }
                        }
                    });
                    $('#tblInstruction tbody').html(rows);
                });
            }
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

        function loadServices() {
            
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

        function LoadServices_Procedures(PatientId) {
            $('#tblServices tbody').empty();
            $('#tblServicesHistory tbody').empty();
            
            if ($("#ctl00_MainContent_hdnInpatient_id").val() !== "(New)") {
                $('#ServicesHistoryHeader').html('<h2 class="hedingcolor">Loading Previous History Please Wait...</h2>');
                PageMethods.LoadServicesDetail(PatientId, $('#ctl00_MainContent_hdnInpatient_id').val(), function (response) {

                    
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
                    $("#ServicesHistoryHeader").html("<h2 class='hedingcolor'>Previous History</h2>");

                });

            }

        }

        function LoadInfusion() {
            if ($('#ctl00_MainContent_hdnInpatient_id').val() != '(New)') {
                PageMethods.Load_Infusion($('#ctl00_MainContent_hdnInpatient_id').val(), function (res) {
                    var Medicines = JSON.parse(res);

                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        
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

        function SaveServices_Procedures() {
            
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

            var InPatID = $('#ctl00_MainContent_hdnInpatient_id').val();

            var ServiceDetails = { PatId: patID, InPatId: InPatID, ServicesList: ProcedureList };

            PageMethods.SaveServicesDetail(btnSave, JSON.stringify(ServiceDetails), function (response) {

                SaveInfusion();
            });

        }




        function AddInfusion() {
            
            var arr = [];

            $('#tblAdditive tbody tr:gt(0)').each(function () {
                
                var text = $(this).find('td:eq(0)').text();
                arr.push(text);
            });
            var arr_join = arr.join();
            
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
             var username = '<%= AppConfig.UserName%>';

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

        


        function InfusionVolume() {

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

        function Delete(anchor) {
            $(anchor).closest('tr').remove();
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

        function SaveInfusion() {
            

            var table = $('#table_res');
            var Infusion_List = [];
            table.find('tbody tr').each(function (key, value) {


                Infusion_List.push({
                    'Infusion_Fluid': $($(value).find('td')[3]).text(), 'Additive': $($(value).find('td')[7]).text(), 'Infusion_Volume': $($(value).find('td')[4]).text(), 'Additive_Dose': $($(value).find('td')[8]).text(), 'Infusion_Rate': $($(value).find('td')[5]).text(), 'Route': $($(value).find('td')[9]).text(), 'Duration': $($(value).find('td')[6]).text(), 'Sides': $($(value).find('td')[10]).text(), "stop_Date": $($(value).find('td')[11]).text(), "Start_Date": $($(value).find('td')[2]).text(), "Infusion_Type": $($(value).find('td')[1]).text(), 'Created_Date': $($(value).find('td')[0]).text()

                });
            });
            
            var Patien_ID = $('#<%= txtPatient_ID.ClientID%>').val();
            var InPatien_ID = $('#ctl00_MainContent_hdnInpatient_id').val();
            var InPatID = $('#ctl00_MainContent_hdnInpatient_id').val();

            var Infusion_Details = { PatientID: Patien_ID, InPatientID: InPatien_ID, InfusionDetails: Infusion_List }
            PageMethods.SaveInfusion(JSON.stringify(Infusion_Details), function (res) {


            });
        }



        function RemoveExtraDepts_WL() {
            PageMethods.GetDepartments_WL(function (data) {
                var parsedData = JSON.parse(data);
                var options = '';
                $.each(parsedData, function (key, value) {
                    options += '<option value=' + value.Department_ID + '> ' + value.Department_Name + '</option>';
                });
                $('#ddlDepartmentsWL').html(options);
                setTimeout(function () {
                    $('#ddlDepartmentsWL').val("0");
                    fillWards_WL();
                    fillPendingPatientsList_WL();
                }, 1000);
            }, function (exec) { alert(exec.getmessage()); })
        }
        function fillWards_WL() {
            var departmentId = $('#ddlDepartmentsWL').val();
            $.ajax({
                url: 'InPatientMonitoring.aspx/GetWards_WL',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ departmentId: departmentId || '0' }),
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $('#ddlWardsWL').empty();
                    $('#ddlWardsWL').append('<option value="">All Wards</option>');
                    $.each(data, function (key, value) {
                        $('#ddlWardsWL').append('<option value="' + value.Ward_ID + '">' + value.Ward_Type + '</option>');
                    });
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching ward data:', error);
                }
            });
        }
        function fillPendingPatientsList_WL() {
            $(".se-pre-con").fadeIn("slow");
            var SelectedDepartment = $('#ddlDepartmentsWL').val();
            var SelectedWard = $('#ddlWardsWL').val();
            var deptParam = (SelectedDepartment === "0" || SelectedDepartment === "" || !SelectedDepartment) ? "" : SelectedDepartment;
            var wardParam = (SelectedWard === "0" || SelectedWard === "" || !SelectedWard || SelectedWard === "All Wards") ? "" : SelectedWard;
            PageMethods.PendingPatients_WL(deptParam, wardParam, function (data) {
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
                    var chkPrivate = document.getElementById("chkPrivateWL").checked;
                    if (chkPrivate == true) {
                        if (value.Patient_Type == "02") {
                            rows += '<tr>' +
                                '<td>' + value.Patient_No + '</td>' +
                                '<td>' + value.Full_Name + '</td>' +
                                '<td>' + value.Age_years + '</td>' +
                                '<td>' + value.Gender + '</td>' +
                                '<td>' + retdate + '</td>' +
                                '<td>' + value.DepartmentName + '</td>' +
                                '<td>' + value.WardName + '</td>' +
                                '<td>' + value.DoctorName + '</td>' +
                                '<td>' + value.UserName + '</td>' +
                                '<td>' + status + '</td>' +
                                '<td><a href="javascript:void(0)" onclick=selectPatientIPD(' + value.In_Patient_ID + ')>Select</a></td>' +
                                '</tr>';
                        }
                    }
                    else {
                        if (value.Patient_Type != "02") {
                            rows += '<tr>' +
                                '<td>' + value.Patient_No + '</td>' +
                                '<td>' + value.Full_Name + '</td>' +
                                '<td>' + value.Age_years + '</td>' +
                                '<td>' + value.Gender + '</td>' +
                                '<td>' + retdate + '</td>' +
                                '<td>' + value.DepartmentName + '</td>' +
                                '<td>' + value.WardName + '</td>' +
                                '<td>' + value.DoctorName + '</td>' +
                                '<td>' + value.UserName + '</td>' +
                                '<td>' + status + '</td>' +
                                '<td><a href="javascript:void(0)" onclick=selectPatientIPD(' + value.In_Patient_ID + ')>Select</a></td>' +
                                '</tr>';
                        }
                    }
                });
                $('#tblPendingPatientsWL tbody').html(rows);
                $(".se-pre-con").fadeOut("slow");
            }, function (exec) {
                $(".se-pre-con").fadeOut("slow");
            })
        }
        function selectPatientIPD(inPatID) {
            localStorage.inPatID = inPatID;
            var chkPrivateforload = document.getElementById("chkPrivateWL").checked;
            localStorage.IsPrivate = chkPrivateforload;
            window.location.href = 'InPatientMonitoring.aspx' + '?InPatientID=' + inPatID;
        }

        function CheckMonitoringMedicines() {
            $.ajax({
                type: 'POST',
                url: 'InPatientMonitoring.aspx/MonitoringMedicines',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var code = response.d;
                    if (code === "01") {                      
                        $('#btnRegularMedicine').show();                      
                        $('#Medicationheading').show();                      
                        $('#RegulerMedicinePrint').show();                      
                    } else {
                        $('#btnRegularMedicine').hide();
                        $('#Medicationheading').hide();
                        $('#RegulerMedicinePrint').hide();                    
                    }
                },
                error: function () {
                    console.log("Error fetching monitoring medicines setting");                    
                    $('#btnRegularMedicine').show();
                }
            });
        }

        function loadNurseName() {
            PageMethods.loadAllUsers(function (res) {
                var data = JSON.parse(res);
                var options = '';
                $.each(data, function (i, item) {
                    options += '<option value="' + item.UserId + '">' + item.UserName + '</option>';
                });
                $('#ctl00_MainContent_ddlNurseName').html(options).select2();
            });
        }

        function CheckDischarge() {
            var inPatID = $('#ctl00_MainContent_hdnInpatient_id').val();
            var inMonID = $('#ctl00_MainContent_txtInPatient_Mon_ID').val();

            if (inPatID && inPatID !== '0' && inPatID !== '' && inPatID !== '(New)') {
                $.ajax({
                    type: 'POST',
                    url: 'InPatientMonitoring.aspx/IsPatientDischarged',
                    contentType: 'application/json; charset=utf-8',
                    data: JSON.stringify({ InPatientID: inPatID }),
                    success: function (response) {
                        if (response.d) {
                            $('#btnSave').prop('disabled', true).css('opacity', '0.5');
                            $('#btnSave').val('Patient Discharged');
                        } else {
                            $('#btnSave').prop('disabled', false).css('opacity', '1');

                            if (inMonID && inMonID !== '(New)' && inMonID !== '') {
                                $('#btnSave').val('Update');
                            } else {
                                $('#btnSave').val('Save');
                            }
                        }
                    }
                });
            }
        }

        function chkrefer_Of_Select() {
            $('#tblBedRef tbody tr').remove();
            $('#tblRoomRef tbody tr').remove();

            var Issuance_Of = document.getElementById('<%= ddlReferTo.ClientID%>').value;
            if (Issuance_Of == 0) {
                document.getElementById('<%= ddlroomRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlRoomTypeRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlwardsRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlroomRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomTypeRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlwardsRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroomRef.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlwardsRef.ClientID%>').className = "dropdownBackgroud";

                document.getElementById('tblBedRef').style.display = "none";
                document.getElementById('tblRoomRef').style.display = "none";
            }
            else if (Issuance_Of == '001') {
                document.getElementById('<%= ddlroomRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlRoomTypeRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlwardsRef.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroomRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomTypeRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroomRef.ClientID%>').className = "dropdownBackgroud";
                document.getElementById('<%= ddlwardsRef.ClientID%>').className = "dropdownBackgroudWhite";

                document.getElementById('tblBedRef').style.display = "table";
                document.getElementById('tblRoomRef').style.display = "none";
            }
            else {
                document.getElementById('<%= ddlwardsRef.ClientID%>').value = 0;
                document.getElementById('<%= ddlwardsRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlRoomTypeRef.ClientID%>').disabled = false;
                document.getElementById('<%= ddlroomRef.ClientID%>').disabled = true;
                document.getElementById('<%= ddlroomRef.ClientID%>').className = "dropdownBackgroudWhite";
                document.getElementById('<%= ddlwardsRef.ClientID%>').className = "dropdownBackgroud";

                document.getElementById('tblBedRef').style.display = "none";
                document.getElementById('tblRoomRef').style.display = "table";
            }
        }

        function FillWardBedsRefer() {
            PageMethods.FillWardBeds($('#<%= ddlwardsRef.ClientID%>').find('option:selected')[0].value, function (res) {
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
                $('#tblBedRef tbody tr').remove();
                $('#tblBedRef tbody').html(rows);
            });
        }

        function FillRoomsRefer() {
            var RoomType = $('#<%= ddlRoomTypeRef.ClientID%>').val();
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
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/><a href="#" onclick="SelectroomRefer(this)" style="color:green"> ' + value.Room_No + ' </a> </td></tr>';
                        }
                        else {
                            rows = '<tr><td>' + value.PatientNmae + '</td><td><input type="hidden" name="ID" value="' + value.Room_ID + '"/><input type="hidden" name="Type" value="' + value.Room_Type + '"/><font color="red">' + value.Room_No + '</font></td></tr>';
                        }
                        $('#tblRoomRef').append(rows);
                    });
                }
                else {
                    $('#tblRoomRef tbody tr').remove();
                }
            });
        }

        function SelectroomRefer(anchor) {
            var row = $(anchor).parents('tr')[0];
            var ID = $($(row).find('td input[name=ID]')[0]).val();
            var Type = $($(row).find('td input[name=Type]')[0]).val();
            $('#<%= ddlroomRef.ClientID%>').val(ID);
        }

        function SelectBedRefer(WardID, BedNo) {
            $('#<%= txtBednoRef.ClientID%>').val("");
            $('#<%= txtBednoRef.ClientID%>').val(BedNo);
        }

        function loadReferenceInformation() {
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID%>").val();
            if (Patient_ID && Patient_ID != "(New)") {
                $.ajax({
                    type: "POST",
                    url: "InPatientMonitoring.aspx/loadReferenceInformation",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccessReferenceRef,
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
        }

        function OnSuccessReferenceRef(response) {
            var onsuccessreference = JSON.parse(response.d);

            $('#txtdprevDepart').val(onsuccessreference.Reffer_To);

            var room_type = onsuccessreference.Room_Type;
            var ward_id = onsuccessreference.Ward_ID;
            var bed_no = onsuccessreference.Bed_No;
            var room_id = onsuccessreference.Room_ID;
            var room_no = onsuccessreference.Room_No;
            var Description = onsuccessreference.Description;
            if (Description && Description.includes("Execute")) Description = "0";
            if (room_no && room_no.includes("Execute")) room_no = "0";
            var Ward_Complete = (Description == null ? "0" : Description) + '-' + (bed_no == null ? "0" : bed_no);
            var room_complete = (room_type == null ? "0" : room_type) + '-' + (room_no == null ? "0" : room_no);

            $('#txtWardBed').val(Ward_Complete);
            $('#txtRoomBed').val(room_complete);
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:UpdatePanel runat="server" ID="UpdatePanel1" UpdateMode="Conditional">
        <Triggers>
        </Triggers>
        <ContentTemplate>
            <input type="hidden" id="hdnipd_id" />
            <div class="row">
                <!-- Left Card -->
                <div class="col-lg-5 col-md-5 col-sm-12">
                    <div class="card">
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                    <div class="image-container">
                                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Addmittiedpatient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                                    </div>
                                </div>
                                <div class="col-lg-8 col-md-7 col-sm-6">
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-4 col-md-5 col-sm-6">
                                            <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :*"></asp:Label>
                                        </div>
                                        <div class="col-lg-8 col-md-7 col-sm-6">
                                            <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                                            <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                                            <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6">
                                            <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 top">
                                            <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                                        </div>
                                    </div>
                                    <div class="row mb-3 mtt">
                                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                            <asp:Label ID="lblWardName" runat="server" Text="Ward Name :"></asp:Label>
                                        </div>
                                        <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                            <asp:Label ID="vLbl_WardName" runat="server"></asp:Label>
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
                                    <asp:Label ID="lblInPatient_Mon_ID" runat="server" Text="Monitoring ID"></asp:Label>
                                </div>
                                <div class="col-lg-4 col-md-5 col-sm-6">
                                    <asp:TextBox ID="txtInPatient_Mon_ID" runat="server" ReadOnly="True"></asp:TextBox>
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
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
                                    <asp:Label ID="lblBedNo" runat="server" Text="Bed No :"></asp:Label>
                                </div>
                                <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                                    <asp:Label ID="vLbl_BedNo" runat="server"></asp:Label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
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
                     <table id="tblMedicine" class="add-test">                            
                             <form id="item">
                                 <div class="row">
                                     <div class="col-lg-3 col-md-3 col-sm-4">
                                         <span>Start Date</span>
                                         <input type="text" id="txtStartD" disabled="disabled" />
                                     </div>
                                     <div class="col-lg-3 col-md-3 col-sm-4" style="margin-left: 0px !important">
                                         <span>Start Time</span>
                                         <input type="text" id="txtStartT" disabled="disabled" />
                                     </div>
                                     <div class="col-lg-6 col-md-3 col-sm-4" id="MedicineName">
                                        <%-- <span id="lblMed">Medicine Name</span>
                                         <select id="txtMedicineNames" name="txtMedicineNames" style="display:none;" class="js-example-responsive;" onchange="CleardrpdwnItem()"></select>--%>
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
                                         <select id="txtRecomended_Dosages" name="RecomendedDosage" style="margin-top:7px !important" > </select>
                                     </div>                                       
                                     <div class="col-lg-3 col-md-3 col-sm-4" id="trduration">
                                         <label>Duration(H/D/W/M)<span class="RedStar">*</span></label>
                                         <input type="text" id="txtInjections" name="txtInjection" placeholder="Duration" disabled="disabled" />
                                     </div>  
                                     </div>
                                 <div class="row">
                                     <div class="col-lg-3 col-md-3 col-sm-4">
                                         <label>Route<span class="RedStar">*</span> </label>
                                         <select id="Route" name="Routes" style="margin-top:-2%" tabindex="4">
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
                                 <input type="text" name="AttendingParamedicalStaff" id="AttendingParamedicalStaffs"  tabindex="6"/>
                                 </div>
                                 </div>
                                 <div class="row">
                                     <div class="col-lg-3 col-md-4 col-sm-6">
                                         <span style="">Other Instructions </span>
                                         <select style="" id="ddlOther_Instruction" name="OtherInstruction">
                                             <option>Please Select</option>
                                         </select>
                                     </div>
                                     <div class="col-lg-3 col-md-3 col-sm-4">
                                         <span>Request Qty:</span>
                                         <input type="text" id="txtRequestQty" min="0" value="0" />
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
                                 <input type="button" id="btnSaveMedicines" class="btn btn-primry" name="btnSaveMedicines" value="Save" tabindex="7" />
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
        </ContentTemplate>
    </asp:UpdatePanel>
    <div style="width: 100%">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-19">Waiting List</a></li>
                <li><a href="#Tab-2">Patient Monitoring</a></li>
                 <li><a href="#Tab-14">Services</a></li>
                <li><a href="#Tab-18">IV Fluid</a></li>
                <li><a href="#Tab-8">Medicine</a></li>
                <li><a href="#Tab-4">Fluid Intake/Output</a></li>
                <li><a href="#Tab-3">Progress Note</a></li>
                <li><a href="#Tab-5">Medication</a></li>
                <li><a href="#Tab-6">Doctor Instruction</a></li>
                <li><a href="#Tab-7">Nursing Plan</a></li>
                <li><a href="#Tab-20">Investigation</a></li>
               <li><a href="#Tab-12">Refer</a></li>

            </ul>
            <div id="Tab-20">
                <h3>Investigation :</h3>


                 <div class="table table-container" style="overflow-y: scroll; height: 400px">
     <table id="tblLabtest" class="table table-hover table-striped table-bordered">
         <thead style="height: 35px;">
             <tr style="position: sticky; top: 0; z-index: 10;">
                 <th>Date</th>
                 <th>Test Name</th>
                 <th>Result</th>
                 <th>Doctor</th>
                 <th>Action</th>
             </tr>
         </thead>
         <tbody id="loadtest">
         </tbody>
     </table>
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
                        <asp:UpdatePanel ID="UpdatePanelRef1" TabIndex="6" runat="server">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlReferTo" runat="server" Class="mmtop" AppendDataBoundItems="true" onChange="chkrefer_Of_Select()"></asp:DropDownList>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:RequiredFieldValidator ID="rfvReferTo" ControlToValidate="ddlReferTo" InitialValue="0" runat="server" ErrorMessage="Select Refer To" Text="*"></asp:RequiredFieldValidator>
                        <asp:UpdatePanel ID="UpdatePanelRef2" runat="server" UpdateMode="Always">
                            <ContentTemplate>
                                <asp:Label ID="lblAllocatedRoomWardRef" runat="server" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                        <asp:UpdatePanel ID="UpdatePanelRef3" runat="server">
                            <ContentTemplate>
                                <asp:Button ID="btnAllocatedRoomwardCheckRefer" Style="display: none;" Text="Chk Allocated Room" runat="server" OnClick="btnAllocatedRoomwardCheckRefer_Click" CausesValidation="false" />
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="lblWardsRef" runat="server" Text="Ward *"></asp:Label>
                        <asp:UpdatePanel ID="UpdatePanelWardRef" TabIndex="7" runat="server" UpdateMode="Always">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlwardsRef" Class="mmtop" runat="server" AppendDataBoundItems="true" OnChange="FillWardBedsRefer()" disabled="disabled"></asp:DropDownList>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="lblBednoRef" runat="server" Text="Bed No"></asp:Label>
                        <asp:TextBox ID="txtBednoRef" TabIndex="8" runat="server" Class="mmtop" Enabled="true"></asp:TextBox>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="lblRoomRef" runat="server" Text="Room_No *"></asp:Label>
                        <asp:DropDownList ID="ddlroomRef" TabIndex="9" runat="server" AppendDataBoundItems="true" disabled="disabled"></asp:DropDownList>
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="lblroomtypeRef" runat="server" Text="Room Type"></asp:Label>
                        <asp:UpdatePanel ID="UpdatePanelRoomTypeRef" TabIndex="10" runat="server">
                            <ContentTemplate>
                                <asp:DropDownList ID="ddlRoomTypeRef" runat="server" AppendDataBoundItems="true" AutoPostBack="true" onChange="FillRoomsRefer()"></asp:DropDownList>
                            </ContentTemplate>
                        </asp:UpdatePanel>
                    </div>
                    <div class="col-lg-4 col-md-6 col-sm-8 no-scrollbar" style="overflow: scroll; height: 250px;">
                        <table id="tblBedRef" class="table">
                            <thead>
                                <tr style="position: sticky; top: 0;z-index: 10;">
                                    <th>MR No.</th>
                                    <th>Bed No</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>

                        <table id="tblRoomRef" class="table">
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
            <div id="Tab-19">
                <h2>Patients Waiting List Department Wise : </h2>
                <div id="Div2_WL">
                    <div>
                        <table id="tblHeader_WL">
                            <tr>
                                <td>
                                    <h4 style="margin-left: 5px;">Select Your Department </h4>
                                </td>
                            </tr>
                            <tr>
                                <td style="width: 261px">
                                    <select id="ddlDepartmentsWL" onchange="fillWards_WL(); fillPendingPatientsList_WL();"></select>
                                </td>
                                <td style="width: 261px">
                                    <select id="ddlWardsWL" style="margin-left: 14px;" onchange="fillPendingPatientsList_WL();">
                                        <option value="">All Wards</option>
                                    </select>
                                </td>
                                <td style="padding-left:20px !important">Private</td>
                                <td style="padding-left:10px !important">
                                    <input type="checkbox" id="chkPrivateWL" onclick="fillPendingPatientsList_WL()" />
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div style="overflow: scroll; height: 400px;">
                        <fieldset>
                            <table class="table table-hover table-striped table-bordered" id="tblPendingPatientsWL" style="overflow: scroll;">
                                <thead id="ihead_WL">
                                    <tr>
                                        <th>MR No</th>
                                        <th>Patient Name</th>
                                        <th>Age</th>
                                        <th>Gender</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Department</th>
                                        <th>Ward</th>
                                        <th>Doctor</th>
                                        <th>Operator Name</th>
                                        <th>Status</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody_WL">
                                </tbody>
                            </table>
                        </fieldset>
                    </div>
                </div>
            </div>
            <div id="Tab-1" style="display: none">
                <div id="OtherDetails" style="width: 70%">
                    <table>
                        <tr>
                            <td>
                                <asp:UpdatePanel runat="server" ID="upInPatForm" UpdateMode="Conditional">
                                    <Triggers>
                                        <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                        <asp:AsyncPostBackTrigger ControlID="BtnDelete" EventName="Click" />
                                    </Triggers>
                                    <ContentTemplate>
                                        <table>
                                            <tr>
                                                <td>
                                                    <table style="padding: 20px">
                                                        <tr>
                                                            <td colspan="4">
                                                                <h2>Other Details : </h2>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="LblMedicine_Type" runat="server" Text="Medicine Type "></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlMedicine_Type" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                                            </td>
                                                            <td class="mgTab">
                                                                <asp:Label ID="LblMedicine_Name" runat="server" Text="Medicine Name "></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlMedicine_Name" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblNurse" runat="server" Text="Nurse "></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:DropDownList ID="ddlNurse" runat="server" Width="167px" AppendDataBoundItems="true"></asp:DropDownList>
                                                            </td>

                                                            <td class="mgTab">
                                                                <asp:Label ID="lblNo_Of_Item" runat="server" Text="No_Of_Item"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtNo_Of_Item" runat="server"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblMedicine_Given_Date" runat="server" Text="Medicine Given Date "></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtMedicine_Given_Date" runat="server"></asp:TextBox>
                                                            </td>

                                                            <td class="mgTab">
                                                                <asp:Label ID="lblCharges" runat="server" Text="Charges"></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtCharges" runat="server"></asp:TextBox>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td>
                                                                <asp:Label ID="lblDescription" runat="server" Text="Description "></asp:Label>
                                                            </td>
                                                            <td>
                                                                <asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Width="200" Height="60"></asp:TextBox>
                                                            </td>
                                                            <td style="padding-left: 35px; padding-top: 30px;" colspan="2">
                                                                <asp:Button ID="btnAdd" runat="server" Text="Add" Width="107px" ClientIDMode="Static" OnClick="btnAdd_Click" />
                                                                &nbsp;
                                                  <asp:Button ID="BtnDelete" runat="server" Text="Delete" Width="107px" CausesValidation="false" OnClick="BtnDelete_Click" />
                                                                &nbsp;
                                                        <asp:Button ID="btnClear" CausesValidation="false" Width="107px" runat="server" Text="Clear" OnClick="btnClear_Click" />
                                                            </td>
                                                        </tr>
                                                    </table>
                                                </td>
                                            </tr>
                                        </table>
                                    </ContentTemplate>
                                </asp:UpdatePanel>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <asp:Label ID="lblValidation" Text="" runat="server" CssClass="errorMessage" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan="2">
                                <div style="width: 900px; float: left">
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="upGridList" UpdateMode="Always">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                                <asp:AsyncPostBackTrigger ControlID="BtnDelete" EventName="Click" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:GridView ID="GRD" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                                    CellPadding="3" ShowFooter="True" OnSelectedIndexChanging="GRD_SelectedIndexChanging" Style="z-index: -1">
                                                    <Columns>
                                                        <asp:TemplateField HeaderText="Index" Visible="false">
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblIndex" runat="server" Text='<%# Bind("Index") %>'></asp:Label>
                                                            </ItemTemplate>
                                                            <EditItemTemplate>
                                                                <asp:TextBox ID="TextBox1" runat="server"></asp:TextBox>
                                                            </EditItemTemplate>
                                                        </asp:TemplateField>

                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:LinkButton ID="imgedit" CausesValidation="false" CommandName="select" runat="server">edit</asp:LinkButton>
                                                            </ItemTemplate>
                                                            <ItemStyle HorizontalAlign="Center" Width="100px" />
                                                        </asp:TemplateField>

                                                        <asp:BoundField DataField="Medicine_Type" HeaderText="Medicine Type">
                                                            <ItemStyle Width="90px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Medicine_Name" HeaderText="Medicine Name">
                                                            <ItemStyle Width="200px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Nurse" HeaderText="Nurse">
                                                            <ItemStyle Width="200px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="No_Of_Item" HeaderText="No Of Item">
                                                            <ItemStyle Width="90px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Medicine_Given_Date" HeaderText="Med Given Date">
                                                            <ItemStyle Width="115px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Description" HeaderText="Description">
                                                            <ItemStyle Width="115px" />
                                                        </asp:BoundField>
                                                        <asp:TemplateField HeaderText="Charges">
                                                            <ItemTemplate>
                                                                <asp:Label ID="lblCharges" runat="server" Text='<%# Bind("Charges","{0:n2}") %>' />
                                                            </ItemTemplate>
                                                            <ItemStyle Width="85px" HorizontalAlign="Right" />
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="upMessage" UpdateMode="Always">
                                            <ContentTemplate>
                                                <asp:Label ID="Label1" runat="server" CssClass="errorMessage" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </div>
            <div id="Tab-2">
                <div id="VitalParameters" style="width: 100%">
                    <h2>Patient Monitoring : </h2>
                    <form>
                        <div class="row">
                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="lblDiabetes" runat="server" Text="Pulse(/min)"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtPulse_Min" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkPulse_Min" runat="server" onclick="drawPulse();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="LblBP_mm_Hg" runat="server" Text="BP(mmHg) (Systolic / Diastolic)"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtBP_mm_Hg" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkBP_mm_Hg" runat="server" onclick="drawBP();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="LblTemp_C" runat="server" Text="Temp (oF)"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtTemp_C" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkTemp_C" runat="server" onclick="drawTemp();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="LblRespiration_Min" runat="server" Text="Respiration (/min)"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtRespiration_Min" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkRespiration_Min" runat="server" onclick="drawResp();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="Label2" runat="server" Text="Blood Sugar(mg/dl)"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtBlood" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkBlood" runat="server" onclick="drawBlood();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <asp:Label ID="LblWeight_Kg" runat="server" Text="Weight_Kg"></asp:Label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtWeight_Kg" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkWeight_Kg" runat="server" onclick="drawWeight();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>

                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <label for="Saturation" id="Lbl_Sat">Saturation</label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtSaturation" runat="server"></asp:TextBox>
<%--                                    <asp:CheckBox ID="chkSaturation" runat="server" onclick="drawSaturation();" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>

                            <div class="col-lg-1 col-md-3 col-sm-4"></div>

                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <label for="chk_WithOxygen">On Room Air</label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtSaturationRoom" runat="server" TabIndex="2"></asp:TextBox>
<%--                                    <asp:CheckBox runat="server" ID="chk_OnRoomAir" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-lg-2 col-md-3 col-sm-4">
                                <label for="chk_WithOxygen">With Oxygen</label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtSaturation_Oxygen1" runat="server" TabIndex="2"></asp:TextBox>
<%--                                    <asp:CheckBox runat="server" ID="chk_WithOxygen" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>
                            <div class="col-lg-2 col-md-3 col-sm-4">
                               <label for="txtHeight">Height (cm)</label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtHeight" runat="server" TabIndex="2"></asp:TextBox>
<%--                                    <asp:CheckBox runat="server" ID="chk_WithOxygen" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                            <div class="col-lg-1 col-md-3 col-sm-4"></div>
                            <div class="col-lg-2 col-md-3 col-sm-4">
                               <label for="txtBMI">BMI</label>
                                <div class="marchk">
                                    <asp:TextBox ID="txtBMI" runat="server" TabIndex="2"></asp:TextBox>
<%--                                    <asp:CheckBox runat="server" ID="chk_WithOxygen" Style="margin-left: 10px;" />--%>
                                </div>
                            </div>
                        <%--    <div class="col-lg-1 col-md-4 col-sm-6" style="display: flex; align-items: center; margin-top: 1%;">
                                <asp:Label ID="Label10" runat="server" Text="Graph" Style="margin-right: 5px;"></asp:Label>
                                <asp:CheckBox ID="chkGraph" runat="server" onclick="showGraph();" />
                            </div>--%>

<%--                            <div class="col-lg-1 col-md-4 col-sm-6" style="display: flex; align-items: center; margin-top: 1%;">
                                <asp:Label ID="Label19" runat="server" Text="Table" Style="margin-right: 5px;"></asp:Label>
                                <asp:CheckBox ID="chkTable" runat="server" onclick="showTable()" />
                            </div>
                            <div class="col-lg-1 col-md-4 col-sm-6"></div>--%>
                            <div class="col-lg-1 col-md-4 col-sm-6">
                                <label></label>
                                <input type="button" id="btnAddPulse" class="btn btn-primry" onclick="AddMonitering()" value="Add" />
                            </div>
                            <div class="col-lg-1 col-md-4 col-sm-6">
                                <label></label>
                            <input type="button" value="Print" id="PrintVital" class="btn btn-primry" onclick ="PrintVitals();" />
                            </div>
                        </div>
                    </form>
                    <div id="chart_div" style="margin-top: -16%; height: 296px" class="responsive">
                    </div>

                    <div style="width: 100%; overflow: scroll; height: 266px; max-height: 400px !important;">
                        <table class="table" id="tblMoinitring">
                            <thead>
                                <tr>
                                    <th>Date & Time</th>
                                    <th>Pulse</th>
                                    <th>BP </th>
                                    <th>Temp</th>
                                    <th>Respiration </th>
                                    <th>Blood Suger(mg/dl)</th>
                                    <th>Weight</th>
                                    <th>Saturation</th>
                                    <th>Room Air</th>
                                    <th>With Oxygen</th>
                                    <th>Height</th>
                                    <th>BMI</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
                <table style="width: 100%" id="divVitalParametersHistory">
                    <tr>
                        <td>
                            <div style="overflow: scroll; height: 266px;">
                                <table class="table" id="tblVitalParametersHistory">
                                    <thead>
                                        <tr>
                                            <td colspan="12">
                                                <div id="tblHistoryHeader">
                                                    <h2 class="hedingcolor">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date</th>
                                            <th>Pulse</th>
                                            <th>BP </th>
                                            <th>Temp</th>
                                            <th>Respiration </th>
                                            <th>Blood Suger(mg/dl)	</th>
                                            <th>Weight</th>
                                            <th>Saturation</th>
                                            <th>Room Air</th>
                                            <th>With Oxygen</th>
                                            <th>Height</th>
                                            <th>BMI</th>
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
                <div id="ProgressNote" >
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                             <h2>Progress Notes : </h2>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="Label3" runat="server" Text="Nurse Name "></asp:Label>
                            <%--<asp:TextBox ID="txtNurseName" runat="server"></asp:TextBox>--%>
                            <asp:DropDownList ID="ddlNurseName" runat="server"></asp:DropDownList>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="Label12" runat="server" Text="Date/Time"></asp:Label>
                            <asp:TextBox ID="txtDate" runat="server" disabled="disabled"></asp:TextBox>
                            </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input id="printNote" type="button" class="btn btn-primry" value ="Print" onclick="PrintNotes();" />
                            </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <asp:Label ID="Label4" runat="server" Text="Progress Note"></asp:Label>
                            <asp:TextBox ID="txtProgressNote" runat="server" TextMode="MultiLine" Style="width: 100%; height: 300px;"></asp:TextBox>
                        </div>
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <asp:Label ID="Label13" runat="server" Text="Shift Hand Over Notes"></asp:Label>
                            <asp:TextBox ID="txtInstruction" runat="server" TextMode="MultiLine" Style="width: 100%; height: 300px;"></asp:TextBox>
                            </div>
                    </div>



                    <table style="padding: 20px">
                        <tr>
                            <td colspan="8">
                                <table style="width: 1213px;">
                                    <tr>
                                        <td>
                                            <input type="button" value="Add" class="btn btn-primry" style="width: 10% !important" id="btnAddProgress" onclick="AddProgressNote()" />
                                            <div style="width: 92%; overflow: scroll; height: 266px; max-height: 400px !important;">
                                                <table class="table" id="tblProdressNote">
                                                    <thead>
                                                        <tr>
                                                            <th style="width: 160px;">Date & Time</th>
                                                            <th style="width: 170px;">Nurse Name </th>
                                                            <th>Note</th>
                                                            <th>Shift Hand Over Notes  </th>
                                                            <th style="width: 100px;">Action  </th>
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
                        <tr>
                            <td colspan="8">
                                <div style="width: 92%; overflow: scroll; height: 266px; max-height: 400px !important;">
                                    <table class="table" id="tblProgressNoteHistory">
                                        <thead>
                                            <tr>
                                                <td colspan="10">
                                                    <div id="Div4" style="height: 20px;">
                                                        <h2 class="hedingcolor">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th style="width: 160px;">Date & Time</th>
                                                <th style="width: 170px;">Nurse Name </th>
                                                <th>Note</th>
                                                <th>Shift Hand Over Notes  </th>
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
            </div>

            <div id="Tab-4">
                <div id="Div2">
                    <div class="col-lg-6 col-md-6 col-sm-6">
                    <div class="row">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                        <h2>Intake :</h2>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-4 col-md-6 col-sm-12 d-flex align-items-center">
                            <asp:Label ID="Label11" runat="server" Style="margin-right: 5px;">Total &nbsp; Days &nbsp; (Qty) &nbsp; :-</asp:Label>
                            <asp:Label ID="lblTotalDays" runat="server"></asp:Label>
                        </div>
                        <div class="col-lg-4 col-md-6 col-sm-12 d-flex align-items-center">
                            <asp:Label ID="Label21"  runat="server" Style="margin-right: 5px;" >Per &nbsp; Day &nbsp; (Qty) &nbsp :-</asp:Label>         
                            <asp:Label ID="lblPerDays" runat="server"></asp:Label>
                        </div>
                    </div>

                    <div class="row mt">
                        <div class="col-lg-3 col-md-4 col-sm-6">
                            <label></label>
                            <asp:DropDownList ID="ddlPerformed_By" runat="server"  AppendDataBoundItems="true"></asp:DropDownList>
                            </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="Label14" runat="server" Text="Item"></asp:Label>
                            <asp:TextBox ID="txtItems" runat="server"></asp:TextBox>
                            </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Label ID="Label15" runat="server" Text="Qty(ml)"></asp:Label>
                            <asp:TextBox ID="txtQty" runat="server" ></asp:TextBox>
                    </div>

                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label></label>
                        <input type="button" class="btn btn-primry" value="Add"  onclick="AddIntake()" />
                            </div>
                        </div>
                        <div class="row">
                        <div class="col-lg-9 col-sm-6 col-md-6">
                            <div style="overflow: scroll; height: 266px; max-height: 400px !important;">
                            <table class="table" id="tblIntake">
                                <thead>
                                    <tr>
                                        <th>Date/Time </th>
                                        <th>Item </th>
                                        <th>Qty</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                            </div>
                        </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-9 col-md-9 col-sm-9">
                                <div style="overflow: scroll; height: 266px; max-height: 400px !important;margin-top:9% !important;">
                                    <table class="table" id="tblHistoryIntake">
                                        <thead>
                                            <tr>
                                                <td colspan="3">
                                                    <div id="Div1" style="height: 20px;">
                                                        <h2 class="hedingcolor">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th>Date/Time </th>
                                                <th>Item </th>
                                                <th>Qty</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        </div>
                    <div class="col-lg-6 col-md-6 col-sm-6">
                        <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <h2>Output :</h2>
                            </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-4 col-md-6 col-sm-12 d-flex align-items-center">
                                    <asp:Label ID="Label20" runat="server">Total &nbsp; Days &nbsp; (Qty) &nbsp; :-</asp:Label>
                                    <asp:Label ID="lblTotalDaysOutput" runat="server"></asp:Label>
                                </div>
                                <div class="col-lg-4 col-md-6 col-sm-12 d-flex align-items-center">
                                    <asp:Label ID="Label23" runat="server" Style="margin-left:-27%" >Per &nbsp; Day &nbsp; (Qty) &nbsp;&nbsp;&nbsp;&nbsp; :-</asp:Label>
                                     <asp:Label ID="lblPerDaysOutput" runat="server"></asp:Label>
                                </div>
                            </div>
                        <div class="row mt">
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                  <asp:Label ID="Label5" runat="server" Text="Urine"></asp:Label>
                                  <asp:TextBox ID="txtUrine" runat="server" ></asp:TextBox>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <asp:Label ID="Label6" runat="server" Text="Drain !"></asp:Label>
                                 <asp:TextBox ID="txtDrain1" runat="server" ></asp:TextBox>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                 <asp:Label ID="Label7" runat="server" Text="Drain 2"></asp:Label>
                                <asp:TextBox ID="txtDrain2" runat="server" ></asp:TextBox>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <asp:Label ID="Label8" runat="server" Text="Drain 3"></asp:Label>
                                <asp:TextBox ID="txtDrain3" runat="server" ></asp:TextBox>
                            </div>
                        </div>
                        <div class="row mt">
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <asp:Label ID="Label9" runat="server" Text="NG"></asp:Label>
                                <asp:TextBox ID="txtNG" runat="server" ></asp:TextBox>
                                </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <asp:Label ID="Label16" runat="server" Text="Stool"></asp:Label>
                                <asp:TextBox ID="txtStool" runat="server" ></asp:TextBox>
                                </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                 <asp:Label ID="Label17" runat="server" Text="Vomiting"></asp:Label>
                                <asp:TextBox ID="txtVomiting" runat="server" ></asp:TextBox>
                                </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <asp:Label ID="Label22" runat="server" Text="Stoma"></asp:Label>
                                 <asp:TextBox ID="TextBox2" runat="server" ></asp:TextBox>
                            </div>
                            </div>
                        <div class="row mt">
                            <div class="col-lg-6 col-md-4 col-sm-6">
                                <asp:Label ID="Label18" runat="server" Text="Other"></asp:Label>
                                <asp:TextBox ID="txtOther" runat="server" ></asp:TextBox>
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label></label>
                                <input type="button" value="Add" onclick="AddOutput()" class="btn btn-primry"  />

                            </div>
                            </div>
                        <div class="row">
                            <div class="col-lg-12 col-md-4 col-sm-6">
                                <div style="overflow: scroll; height: 188px; max-height: 400px !important;">
                                    <table id="tblOutput" class="table">
                                        <thead>
                                            <tr>
                                                <th>Date/Time</th>
                                                <th>Urine </th>
                                                <th>Drain1</th>
                                                <th>Drain2</th>
                                                <th>Drain3</th>
                                                <th>NG </th>
                                                <th>Stool </th>
                                                <th>Vomiting </th>
                                                <th>Stoma </th>
                                                <th>Other </th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div style=" overflow: scroll; height: 266px; max-height: 400px !important;">
                                <table id="tblOutputHistory" class="table" >
                                    <thead>
                                        <tr>
                                            <td colspan="10">
                                                <div id="Div3" style="height: 20px;">
                                                    <h2 class="hedingcolor">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date/Time</th>
                                            <th>Urine </th>
                                            <th>Drain1</th>
                                            <th>Drain2</th>
                                            <th>Drain3</th>
                                            <th>NG </th>
                                            <th>Stool </th>
                                            <th>Vomiting </th>
                                            <th>Stoma </th>
                                            <th>Other </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <table>
                            <td>
                                <table style="width: 527px;">
                                    <tr>
                                        <td colspan="3">
                                            
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="3">
                                           
                                        </td>
                                    </tr>
                                </table>
                            </td>
                    </table>
                </div>
            </div>
            <div id="Tab-5" style="display: none">
                <div id="tabMedication" style="width: 100%;">
                    <div id="dvtblSymtomps" style="height: 207px; overflow: scroll;">
                        <table class="table" style="overflow: scroll;"
                            id="tblHistoryMedication">
                            <thead>
                                <tr>
                                    <th style="width: 160px;">Date </th>
                                    <th style="width: 170px;">Medicine Name </th>
                                    <th>Dosage</th>
                                    <th>Frequency  </th>
                                    <th>Routes </th>
                                    <th style="display: none">Duration </th>
                                    <th>Doctor Name</th>
                                    <th>Duration </th>
                                    <th>Special Instruction </th>
                                    <th>Dosage From </th>
                                    <th>Dosage Qty </th>
                                    <th>Other Instruction</th>
                                    <th>Medication Type</th>
                                    <th style="width: 100PX;">Action</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>

                    <table id="tblMedicines" class="add-test" style="display: none;">
                        <tr>
                            <td style="width: 110px"><span>Medicine Name</span></td>
                            <td style="width: 234px">
                                <select id="txtMedicineName" name="txtMedicineName">
                                </select>
                            </td>
                            <td style="width: 110px"><span>Dosage</span></td>
                            <td style="width: 234px">
                                <input type="text" id="txtDosage" name="txtDosage" tabindex="2" />
                            </td>
                            <td style="width: 110px"><span>Frequency </span></td>
                            <td style="width: 234px">
                                <select id="txtRecomended_Dosage" name="RecomendedDosage" tabindex="3">
                                    <option value="">Select Frequency </option>
                                </select>
                            </td>
                        </tr>

                        <tr>
                            <td><span>Route </span></td>
                            <td>
                                <select id="Routes" name="Routes" tabindex="4">
                                    <option value="">Select Route </option>
                                </select>
                            </td>
                            <td><span>Duration(Days) </span></td>
                            <td>
                                <input type="text" id="txtInjection" name="txtInjection" tabindex="5" />
                            </td>
                            <td style="width: 200px;"><span>Attending Paramedical Staff</span></td>
                            <td>
                                <input type="text" id="AttendingParamedicalStaff" name="AttendingParamedicalStaff" tabindex="5" />
                            </td>
                        </tr>
                    </table>
                    <div id="Div5" style="height: 207px; overflow: scroll;">
                        <table class="table">
                            <tr>
                                <td>
                                    <table class="table" id="tblMedicinesList">
                                        <thead>
                                            <tr style="position: sticky; top: 0px; z-index: 10;">
                                                <th style="width: 160px;">Date </th>
                                                <th style="width: 170px;">Medicine Name </th>
                                                <th>Dosage</th>
                                                <th>Frequency</th>
                                                <th>Routes </th>
                                                <th style="display: none">Duration </th>
                                                <th>Nurse Name</th>
                                                <th>Duration </th>
                                                <th>Special Instruction </th>
                                                <th>Dosage From </th>
                                                <th>Dosage Qty </th>
                                                <th>Other Instruction</th>
                                                <th>Medication Type</th>
                                                <th style="width: 100PX;">Edit</th>
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
            <div id="Tab-7">
                <div id="Nursing_plan">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <h2>Nursing Plan : </h2>
                        </div>
                    </div>
                    <div class="row" id="tblNursing_plan">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                            <asp:Label ID="lblNursing_plan" runat="server" Text="Nursing Plan"></asp:Label>
                            <asp:TextBox ID="txt_Nursing_plan" runat="server" TabIndex="9" TextMode="MultiLine" class="todolist" Style="font-size: 18px!important; width: 100%; height: 160px;"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="Label24" runat="server" Text="Nurse Name"></asp:Label>
                            <asp:TextBox ID="txt_Nurse_Name_Nursing" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-1 col-md-4 col-sm-6">
                            <label></label>
                            <input type="button" id="btnAdPrint" class="btn btn-primry" onclick="AdPrint()" value="Print" />
                        </div>
                    </div>
                    <div>
                    </div>
                </div>
            </div>
            <div id="Tab-14">
                <h2>Services / Procedures</h2>
                <div>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 225px !important;">
                                    <%--<input type="text" id="txtService" name="txtService" runat="server" />--%>
                                    <asp:TextBox id="txtService" name="txtService" runat="server"></asp:TextBox>
                                </td>
                                <td>
                                    <input type="button" id="btnAddService" class="btn btn-primry" name="btnAddService" onclick="AddServiceOrItem()" value="Add Service" style="top: 3px; left: 20px;width:26% !important" />
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
                            <tr style="position: sticky; top: 0; z-index: 10;">
                                <td colspan="12">
                                    <div id="ServicesHistoryHeader">
                                        <h2 class="hedingcolor">Previous History</h2>
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
                        <div class="col-md-1" style="display: none;">
                            <label>Route</label>
                        </div>
                        <div class="col-md-2" style="display: none;">
                            <select class="ddlroute" id="ddl_route">
                                <option></option>
                            </select>
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
                                    <th style="display: none;">Route</th>
                                    <th>Site</th>
                                    <th>Stop Date & Time</th>
                                    <th>User Name</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="t_body">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <%--Medication Tab Start--%> 
                                <div id="Tab-8">
                        <div id="Medication" >
                            <h2 id="Medicationheading">Medication : </h2>
                            <table style="width:100%">
                                <tr>
                                    <td>
                                        <input type="button" value="Regular Medicine" id="btnRegularMedicine" class="btn btn-primry" style="width: 15% !important;"/>
                                       <input type="button" value="STAT Medicine" class="btn btn-primry" id="btnSTATMedicine" style="width: 15% !important;"/>
                                         <%--<input type="button" value="PRN Medicine" class="btn btn-primry" id="btnPRNMedicine" style="width:15% !important;"/>--%>                    
                                         <input type="button" id="RegulerMedicinePrint" class="btn btn-primry" onclick="PrintMecicationDetail()" value="Regular Print" style="width:15% !important" />
        <%--                                <input type="button" class="btn btn-primry" onclick="PrintMecicationDetailPRN()" value="STAT Print"  style="width: 15% !important;"/>
                                         <input type="button" class="btn btn-primry" onclick="PrintMecicationDetailSTAT()" value="PRN Print" style="width: 15% !important;" />--%>
                                         <label for="txtMR_No" style="margin-left: 20px; margin-right: 5px;">MR No:</label>
                                         <input type="text" id="txtMR_No" style="width: 180px !important;" />
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
                                                <th>Request Qty </th>
                                                <th>Received Qty </th>
                                                <th>Stop Date & Time</th>
                                                <th>Other Instruction</th>
                                                 <th>Special Instructions </th>
                                                <th>Username</th>
                                                <th>Rtn Qty</th>
                                                <th style="width: 100PX;">Edit</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                            </div>

                                         <h2>STAT Medicine</h2>
                                          <div style="overflow: scroll; height: 280px;">
                                           <table class="table" id="tblMedicinesListSTAT">
                                            <thead>
                                                <tr>
                                                    <th>Start Date & Time</th>
                                                    <th>Medicine Name</th>
                                                    <th>Dose</th>
                                                    <th>Dosage Unit</th>
                                                    <th>Frequency</th>
                                                    <th>Duration</th>
                                                    <th>Route</th>
                                                    <th>Request Qty</th>
                                                    <th>Received Qty</th>
                                                    <th>Other Instruction</th>
                                                    <th>Special Instructions</th>
                                                    <th>Username</th>
                                                    <th>Edit</th>
                                                </tr>
                                            </thead>
                                            <tbody></tbody>
                                        </table>
                                              </div>
                                       <%--   <h2>PRN Medicine</h2>
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
                                                <th>Request Qty </th>
                                                <th>Received Qty </th>                                                                                             
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
                                <table class="table" id="tblHistoryMedications">
                                        <thead>
                                            <tr style="position: sticky; top: 0;z-index: 10;";>
                                                <td colspan="14">
                                                    <div id="HeaderHistoryMedications">
                                                        <h2 class="color">Previous History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr style="position: sticky; top: 70px; z-index: 10;">
                                                <th style="width: 160px;">Date</th>
                                                <th style="width: 170px;">Medicine Name</th>
                                                <th>Frequency</th>
                                                <th>Routes</th>
                                                <th>Request Qty </th>
                                                <th>Received Qty </th>
                                                <th>Stop Date & Time</th>
                                                <th>Special Instructions</th>
                                                <th>Dosage From</th>
                                                <th>Dosage Qty</th>
                                                <th>Other Instruction</th>
                                                <th>Medication Type</th>
                                                <%--<th>Action</th>--%>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                            </div>
                        </div>
                    </div>
             <%--Medication Tab End--%> 
            <div id="Tab-6">
                <div id="Instruction" style="width: 90%">
                    <table>

                        <tr>
                            <td>
                                <h2>Instruction : </h2>
                            </td>
                        </tr>
                    </table>
                    <div style="margin-left: -1px; width: 1119px; overflow: scroll; height: 292px; max-height: 400px !important;">
                        <table id="tblInstruction" class="table" style="width: 100% !important;">
                            <thead>
                                <tr>
                                    <th style="width: 160px">Date/Time</th>
                                    <th style="width: 340px">Doctor Name & Type </th>
                                    <th style="width: 760px">Instruction Given</th>
                                    <th style="width: 760px">Nurse Name</th>
                                    <th style="width: 100px">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div style="margin-left: -1px; margin-top: -23px; width: 1119px; overflow: scroll; height: 292px; max-height: 400px !important;">
                        <table id="tblInstruction2" class="table" style="width: 100% !important;">
                            <thead>
                                <tr>
                                    <th style="width: 160px">Date/Time</th>
                                    <th style="width: 340px">Doctor Name & Type </th>
                                    <th style="width: 760px">Instruction Follwed</th>
                                    <th style="width: 760px">Nurse Name</th>
                                    <th style="width: 100px">Action</th>
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
    <div class="row" style="margin-top: 1%">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" id="btnSave" class="btn btn-primry" value="Save" onclick="SaveAlRecord()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" id="btnNew" value="New" onclick="New()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Button Text="View" runat="server" ID="btnBack" Class="btn-gray" CausesValidation="false" PostBackUrl="~/Modules/PatientManagement/InPatientMonitoringList.aspx" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <asp:Label ID="lblMessage" runat="server"></asp:Label>
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" />
                </div>
                <div id="loadingimage" style="display: none">
                    <asp:Image ID="image" ImageUrl="~../../../../wwwroot/THEME_TIBBIT/images/loading.gif" runat="server" Width="32px" />
                </div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hdnInpatient_id" Value="0" runat="server" />
</asp:Content>
