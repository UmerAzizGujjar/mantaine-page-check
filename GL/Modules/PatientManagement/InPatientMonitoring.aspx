<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientMonitoring.aspx.cs" Inherits="PMS.InPatientMonitoring" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<%@ Register Src="~/LookupControl.ascx" TagName="LookupControl" TagPrefix="uc1" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/ipdmonitoring.css" rel="stylesheet" />
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>


    <script type="text/javascript">

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
        function FillMedicine() {
            PageMethods.FillMedicineDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {

                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#txtMedicineName').html(options);
                $('#txtMedicineName').select2();
            });
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
        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value=""> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Routes').html(options);
            });
        }
        var inpatient = 0;
        $(document).ready(function () {
            $('textarea').addClass("todolist");
            $('#ctl00_MainContent_txtAreaOfInterest').removeClass('todolist');
            $('#ctl00_MainContent_txtIdentificationMarks').removeClass('todolist');
            InfusionVolume();
            AdditiveDose();
            InfussionPharmacy();
            additive();
            Sides();

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

            

            var current_time = moment().format("hh:mm A");
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
            FillMedicine();
            FillFrequency();
            FillRoutes();
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != "(New)") {
            CountTotalQty();
            CountTotalQtyOutPut();
            CountPerQty();
            CountPerQtyOutput();
            LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
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


            LoadHistory();
        });
        <%if (Request.QueryString["ID"] != null)
               {%>
        LoadInstruction();
        LoadInstructionEdit();
        $('#btnSave').val("Update");
        $('#loadingimage').hide();
                <%}%>
        $("#ctl00_MainContent_txtDate").datepicker({ dateFormat: 'mm/dd/yy' });
        $('#btnSaveMedicine').on("click", function () {
            
            var datetime = '<%= DateTime.Now%>';
            if ($('#btnSaveMedicine').val() == 'Add Medicine') {
                var row = '<tr> <td> ' + datetime + ' </td><td> ' + $('#txtMedicineName').find('option:selected').text() + '</td> <td> ' + $('#txtDosage').val() + ' </td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + '</td><td> ' + $('#Routes').find('option:selected').text() + ' </td> <td> ' + $('#txtInjection').val() + '<td> ' + $('#AttendingParamedicalStaff').val() + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                var table = $('#tblMedicinesList tbody');
                table.append(row);
            }
            else {
                var tid = $('#tblMedicinesList input[name=uurowid]').val();
                var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];
                $(row).find('td')[1].innerText = $('#tblMedicinesList select[name=txtMedicineName]').find('option:selected').text();
                $(row).find('td')[2].innerText = $('#tblMedicinesList input[name=txtDosage]').val();
                $(row).find('td')[3].innerText = $('#tblMedicinesList select[name=RecomendedDosage]').find('option:selected').text();
                $(row).find('td')[4].innerText = $('#tblMedicinesList select[name=Routes]').find('option:selected').text();
                $(row).find('td')[5].innerText = $('#tblMedicinesList input[name=txtInjection]').val();
                $(row).find('td')[6].innerText = $('#tblMedicinesList input[name=AttendingParamedicalStaff]').val();
            }
            $('#MedicationModel').modal('hide');
        });
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
            if (temp === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Temperature (°C).',
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
            if (respiration === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Respiration (per minute).',
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
            if (blood === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Blood Group or Blood Info.',
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
            if (weight === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Weight (Kg).',
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
            if (saturation === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Saturation (%).',
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
            if (saturationRoom === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Saturation (Room).',
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
            if (saturationOxygen === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Saturation (Oxygen).',
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


                var datetime = '<%= DateTime.Now%>';
                if ($('#btnAddPulse').val() == 'Add') {
                    var row = '<tr> <td> ' + datetime + ' </td><td> ' + $('#ctl00_MainContent_txtPulse_Min').val() + '</td> <td> ' + $('#ctl00_MainContent_txtBP_mm_Hg').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtTemp_C').val() + '</td><td> ' + $('#ctl00_MainContent_txtRespiration_Min').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtBlood').val() + '</td><td> ' + $('#ctl00_MainContent_txtWeight_Kg').val() + ' </td><td> ' + $('#ctl00_MainContent_txtSaturation').val() + ' </td><td > ' + $('#ctl00_MainContent_txtSaturationRoom').val() + ' </td><td > ' + $('#ctl00_MainContent_txtSaturation_Oxygen1').val() + ' </td>' + ' </td> <td> <a href="#" onclick="editPlus(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
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

                    $('#btnAddPulse').val('Add')
                }
           
        }
        function AddProgressNote() {
          
            var datetime = '<%= DateTime.Now%>';
            if ($('#btnAddProgress').val() == 'Add') {
                var row = '<tr> <td> ' + $('#ctl00_MainContent_txtDate').val() + ' </td><td> ' + $('#ctl00_MainContent_txtNurseName').val() + '</td> <td> ' + $('#ctl00_MainContent_txtProgressNote').val() + '</td><td> ' + $('#ctl00_MainContent_txtInstruction').val() + ' </td> <td> <a href="#" onclick="editPlus(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                var table = $('#tblProdressNote tbody');
                table.append(row);
                $('#ctl00_MainContent_txtProgressNote').val('');
                $('#ctl00_MainContent_txtInstruction').val('');
                $('#ctl00_MainContent_txtNurseName').val('');

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
                MedicinesList.push({ 'Date': $($(value).find('td')[0]).text(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Recomended_Dosage': $($(value).find('td')[2]).text(), 'Frequency': $($(value).find('td')[3]).text(), 'Oral': $($(value).find('td')[4]).text(), 'Injection': $($(value).find('td')[5]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[6]).text(), 'Nurse_Name': $(value).find('td input[name=txtNurseName]').val(), 'Duration': $($(value).find('td')[7]).text(), 'Special_Ins': $($(value).find('td')[8]).text(), 'Dosage_From': $($(value).find('td')[9]).text(), 'Dosage_Qty': $($(value).find('td')[10]).text(), 'Other_Ins': $($(value).find('td')[11]).text(), 'Type': $($(value).find('td')[12]).text(), });
            });
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }
            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { SaveInTake(); });
        }
        function SaveAlRecord() {
            $('#btnSave').attr('disabled', true);
            $('#loadingimage').show();
            SavePatientMonitiring();
            SaveServices_Procedures();
            localStorage.SelectedTabID = $("#tabs").tabs("option", "active");
        }
        function SavemMaster() {
            
            var btnsave = $('#btnSave').val();
            var In_Mon_ID = $('#<%= txtInPatient_Mon_ID.ClientID%>').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var Nursing_Plan = toHtml('#ctl00_MainContent_txt_Nursing_plan');
            var Nurse_Name_N = toHtml('#ctl00_MainContent_txt_Nurse_Name_Nursing');
            
            PageMethods.SavePatientMonitiring(btnsave, In_Mon_ID, Nursing_Plan, PatID, Nurse_Name_N, function (response) {
                
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
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Pulse_Min + ' </td> <td> ' + value.BP_mm_Hg + ' </td><td>' + value.Temp_C + '</td><td> ' + value.Respiration_Min + ' </td> <td> ' + value.Blood_Suger + ' </td><td> ' + value.Weight_Kg + ' </td><td> ' + value.Saturation + ' </td><td > ' + value.Room_Air + ' </td><td > ' + value.With_Oxygen + ' </td><td> <a href="#" onclick="editPlus(this)"> Edit </a> | <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
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
                        + ' </td> <td> ' + value.BP_mm_Hg + ' </td> <td> ' + value.Temp_C + ' </td><td> ' + value.Respiration_Min + ' </td> <td> ' + value.Blood_Suger + ' </td> <td> ' + value.Weight_Kg + '</td><td> ' + value.Saturation + '</td><td > ' + value.Room_Air + ' </td><td > ' + value.With_Oxygen + ' </td></tr>';
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
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td style="display:none"> ' + value.Injections + ' </td><td> <input type="text"  id="txtNurseName" name="txtNurseName" style="width:80px !important;" value="' + value.Nurse_Name + '"/></td><td>' + value.Injections + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Dosage_From + '</td><td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td><td> <a style="display:none;" href="#" onclick="editMedicine(this)"> Edit </a> | <a style="display:none;" href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> </tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                });
            }
        }

        function SavePatientMonitiring() {

            var table = $('#tblMoinitring');
            var MoinitringList = [];
            table.find('tbody tr').each(function (key, value) {

                MoinitringList.push({ 'Date': $($(value).find('td')[0]).text(), 'Pulse_Min': $($(value).find('td')[1]).text(), 'BP_mm_Hg': $($(value).find('td')[2]).text(), 'Temp_C': $($(value).find('td')[3]).text(), 'Respiration_Min': $($(value).find('td')[4]).text(), 'Blood_Suger': $($(value).find('td')[5]).text(), 'Weight_Kg': $($(value).find('td')[6]).text(), 'Saturation': $($(value).find('td')[7]).text(), 'Room_Air': $($(value).find('td')[8]).text(), 'With_Oxygen': $($(value).find('td')[9]).text() });

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
                            LoadInstruction();
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
                $('#ctl00_MainContent_hdnInpatient_id').val(data.d.inPatient);
                $("#hdnipd_id").val(data.d.in_patient_id);
                console.log(data.d.in_patient_id);
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
        }
        $(function () {
            $("#tabs").tabs();
            GetLastSelectedTab();
        });
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
            if (PatientID != '(New)') {
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
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
                        rows += '<tr> <td> ' + date + ' </td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td style="display:none"> ' + value.Injections + ' </td> <td>' + value.DoctorName + '</td><td>' + value.Injections + '</td><td>' + value.AttendingParamedical_Staff + '</td><td>' + value.Dosage_From + '</td> <td>' + value.Dosage_Qty + '</td><td>' + value.Other_Instruction + '</td><td>' + type + '</td><td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                    });
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                });
            }
        }
        function SaveInstructionDetail() {

            
            var table = $('#tblInstruction2');
            var InstructionList = [];
            table.find('tbody tr').each(function (key, value) {
                
                InstructionList.push({ 'Instruction_Date': $($(value).find('td')[0]).text(), 'Doctor_Status': DocStatus[1], 'Doctor_ID': $(value).find('td input[name=txtDoctorValue]').val(), 'Doctor_Instruction': $($(value).find('td')[2]).text(), 'ChekInstruction': $(value).find('td input[name=chekInstruction]')[0].checked, 'Nurse_Name': $(value).find('td input[name=txtNurseName]').val(), 'Progress_Note': $(value).find('td input[name=txtprogress]').val(), });

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
            var row = '<tr><td>' + date + '</td><td>' + MedicineName + '</td><td>' + Dosage + '</td><td>' + Frequency + '</td><td> ' + Routes + '</td><td style="display:none"> ' + Duration + '</td><td> <input type="text"  id="txtNurseName" name="txtNurseName" style="width:80px !important;"/></td><td>' + Duration + '</td><td>' + Special_Ins + '</td><td>' + Dosage_From + '</td><td>' + Dosage_Qty + '</td><td>' + Other_Ins + '</td><td>' + Type + '</td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteMedicine(this)">Delete</a></td></tr>';
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
            var Nurse_Name = $($(row).find('td')[3]).find('input[name="txtNurseName"]').val();
            var ProgresNote = $($(row).find('td')[2]).find('input[name="txtprogress"]').val();

            var date = '<%= DateTime.Now %>';
            rows = '<tr> <td> ' + Date + ' </td> <td><input type="hidden" name ="txtDoctorStatus" value="">  ' + Doctor_name + '<input type="hidden" name ="txtDoctorValue" value="' + Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + ProgresNote + '">' + Instruction + '</td><td><input type="text" name="txtNurseName" value="' + Nurse_Name + '" style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction" checked  disabled/></td> </tr>';
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
                            + '<input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + value.Progress_Note + '">' + value.Doctor_Instruction + '</td><td><input type="text" value="' + value.Nurse_Name + '" name="txtNurseName"  style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction"  ' + (value.IsLatest ? 'checked' : '') + ' onclick="selectDoctorInstruction(this)" checked disabled style="width: 20px;" /></td> </tr>';
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
                                    + '<input type="hidden" name ="txtDoctorValue" value="' + value.Doctor_ID + '"> </td>  <td><input type="hidden" name ="txtprogress" value="' + value.Progress_Note + '">' + value.RN_Special_Instruction + '</td><td><input type="text" value="' + value.Nurse_Name + '" name="txtNurseName"  style="font - size: medium;"/></td><td><input type="checkbox" name="chekInstruction"  ' + (value.IsLatest ? 'checked' : '') + ' onclick="selectDoctorInstruction(this)" /></td> </tr>';
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
                                        <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Addmittiedpatient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
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
                        </div>
                    </div>
                </div>
            </div>

        </ContentTemplate>
    </asp:UpdatePanel>
    <div style="width: 100%">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-2">Patient Monitoring</a></li>
                 <li><a href="#Tab-14">Services</a></li>
                <li><a href="#Tab-18">IV Fluid</a></li>
                <li><a href="#Tab-4">Fluid Intake/Output</a></li>
                <li><a href="#Tab-3">Progress Note</a></li>
                <li><a href="#Tab-5">Medication</a></li>
                <li><a href="#Tab-6">Doctor Instruction</a></li>
                <li><a href="#Tab-7">Nursing Plan</a></li>
               

            </ul>
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
                            <asp:TextBox ID="txtNurseName" runat="server"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <asp:Label ID="Label12" runat="server" Text="Date/Time"></asp:Label>
                            <asp:TextBox ID="txtDate" runat="server" disabled="disabled"></asp:TextBox>
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
                    <asp:Image ID="image" ImageUrl="~../../../../wwwroot/Tibbit_theme/images/loading.gif" runat="server" Width="32px" />
                </div>
            </div>
        </div>
    </div>
    <asp:HiddenField ID="hdnInpatient_id" Value="0" runat="server" />
</asp:Content>
