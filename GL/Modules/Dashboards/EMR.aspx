<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EMR.aspx.cs" Inherits="PMS.Modules.Dashboards.EMR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <script src="~../../wwwroot/Tibbit_theme/Scripts/jquery-1.11.1.min.js"></script>
    <script src="~../../wwwroot/Tibbit_theme/Scripts/jquery.canvasjs.min.js"></script>
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/EMR.css" rel="stylesheet" />
    <script src="~../../wwwroot/Tibbit_theme/js/apexchart.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/apexcharts"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            

            loadtokenInputsByMrNo();
            FillModePresentation();
            $("#ipdvitals").hide();
            $("#emergencyVital").hide();
            $("#opdvitals").hide();
            $('#token-input-ctl00_MainContent_txtPatNO').attr('placeholder', 'Enter MR No');
        });
        function loadtokenInputsByMrNo(data) {
            debugger;
            var newbox = $('#ctl00_MainContent_txtPatNO').val();
            debugger;

            if (newbox != null || newbox == "(New)") {
                $("#ctl00_MainContent_txtPatNO").tokenInput("../../json.aspx?Table=Patients",
                    {
                        prePopulate: data,
                        tokenLimit: 1,
                        onAdd: function (item) {
                            $("#hdfReg_ID").val(item.id);

                            fetchPatientInfo();

                        }
                    });
            }

        }

        function fetchPatientInfo() {
            debugger;
            var Patient_ID = $("#hdfReg_ID").val();

            $.ajax({
                type: "POST",
                url: "EMR.aspx/GetBasicInfo",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);

                    $('#patname').text(data.Name);
                    $('#mrno').text(data.Mr_No);
                    $('#txtage').text(data.Age);
                    $('#gender').text(data.Gender);
                    $('#phonenumber').text(data.Mobile);
                    $('#address').text(data.Address);
                    $('#CNIC').text(data.CNIC);


                    fetchAppointment();

                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });

        }
        function fetchAppointment() {
            var Patient_ID = $("#hdfReg_ID").val();
            $.ajax({
                type: "POST",
                url: "EMR.aspx/getAppoitnmentInfo",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    console.log(data);
                    if (data && data.doctor) {

                        $('#doctorname').text(data.doctor.Emp_Name);
                    } else {
                        $('#doctorname').text("");
                    }

                    if (data && data.AppointmentDate) {
                        var date = data.AppointmentDate;
                        date = moment(date).format('MMMM DD,YYYY');
                        $("#appdate").text(date);
                    } else {
                        $("#appdate").text("No appointments.");
                    }

                    getlastAppointment();
                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        function getlastAppointment() {
            var Patient_ID = $("#hdfReg_ID").val();
            $.ajax({
                type: "POST",
                url: "EMR.aspx/GetLastAppointmentVisit",
                data: JSON.stringify({ Patient_ID: Patient_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    if (data && data.doctor) {
                        $('#prvDoctor').text(data.doctor.Emp_Name);
                    } else {
                        $('#prvDoctor').text("");
                    }

                    if (data && data.AppointmentDate) {
                        var date = data.AppointmentDate;
                        date = moment(date).format('MMMM-DD-YY');
                        $("#prv_visit").text(date);
                    } else {
                        $("#prv_visit").text("No appointments.");
                    }
                    $("#Department").text(data.Department);
                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
            checkVisits();
        }
        function checkVisits() {
            var reg_id = $('#hdfReg_ID').val();
            $.ajax({
                type: "POST",
                url: "EMR.aspx/CountVisits",
                data: JSON.stringify({ reg_id: reg_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    debugger;
                    var data = JSON.parse(resp.d);
                    $("#opd").text(data.OutPatientCount);
                    $("#ipd").text(data.InPatientCount);
                    $("#emergency").text(data.EmergencyCaseCount);

                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });

        }
        function FillModePresentation() {
            var options = '<option value="0">Department</option>';

            $.ajax({
                url: 'EMR.aspx/ModePresentation',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;

                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlmaindepartment').html(options);
                    $('#ddlmaindepartment').select2();
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function LoadVitalParameters() {
            debugger;
            var patid = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();
            //if (patid != null) {
            //    alert("Select Mr No First");
            //    return;
            //}

            $("#ipdvitals").hide();
            $("#opdvitals").hide();
            $("#emergencyVital").hide();
            $("#tblVitalParametersHistory").hide();
            $("#tblVitalParametersHistoryIPD").hide();
            $("#tblVitalParametersHistoryEmergency").hide();

            if (category == "01") {
                $("#opdvitals").show();
                $("#tblVitalParametersHistory").show();
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/LoadVitalParametersHistory",
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        debugger;
                        var rows = '';
                        $.each(JSON.parse(res.d), function (key, value) {
                            var date = moment(value.Created_Time).format('DD-MM-YY');
                            // console.log(value);

                            rows += '<tr> <td value="' + value.Out_Patient_ID + '"> ' + date + ' </td><td>' + value.Status + '</td> <td> ' + value.Pulse_Min
                                + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Height_Cm + ' </td><td> ' + value.L_M_P + ' </td><td> ' + value.SPO2 + ' </td><td> ' + value.BSR + ' </td><td> ' + value.BMI + ' </td><td> ' + value.BP_mm_Hg + ' </td> <td> ' + value.Respiration_Min + ' </td> <td> ' + value.Weight_Kg + ' </td></tr>';
                        });

                        $('#tblVitalParametersHistory tbody tr').remove();
                        $('#tblVitalParametersHistory tbody').html(rows);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error: " + status + ": " + error);
                    }
                });
            }


            if (category == "03") {
                $("#ipdvitals").show();
                $("#tblVitalParametersHistoryIPD").show();
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/LoadVitalParametersHistoryIPD",
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var Data = JSON.parse(res.d);
                        var rows = '';
                        var gcs = "";

                        $.each(Data, function (key, value) {

                            if (value.RateBeats == "" && value.Emergency_Rhythm == null && value.Emergency_Volume == null &&
                                (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.BP_mm_Hg == "___/___" &&
                                value.O2_Saturation == "" && value.O2_Saturation_Oxygen1 == "" && value.O2_Saturation_Oxygen2 == "" &&
                                (value.RN_Special_Instruction == "<li></li>" || value.RN_Special_Instruction == "") &&
                                (value.OthersRecieveNote == "<li></li>" || value.OthersRecieveNote == "") && value.Temp_C == "") {
                                return;
                            }
                            gcs = value.GCS == null ? "" : value.GCS;


                            if (value.Emergency_Rhythm == null) value.Emergency_Rhythm = "";
                            if (value.Emergency_Volume == null) value.Emergency_Volume = "";

                            var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));
                            var retdateRec = moment.unix(TrnsDateRec).format('MM/DD/YYYY hh:mm:ss A');
                            rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.RateBeats + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Emergency_Rhythm + ' </td><td> ' + value.Emergency_Volume + ' </td>< td > ' + value.BP_mm_Hg + ' </td ></tr > ';
                        });

                        $('#tblVitalParametersHistoryIPD tbody tr').remove();
                        $('#tblVitalParametersHistoryIPD tbody').html(rows);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error: " + status + ": " + error);
                    }
                });
            }
            if (category == "02") {
                $("#emergencyVital").show();
                $("#tblVitalParametersHistoryEmergency").show();
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/LoadVitalParametersHistoryemergency",
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        var Data = JSON.parse(res.d);
                        var rows = '';
                        var gcs = "";
                        $.each(Data, function (key, value) {


                            var TrnsDateRec = parseInt(value.Receiving_date.substr(6, 10));
                            var retdateRec = moment.unix(TrnsDateRec).format('MM/DD/YYYY hh:mm:ss A');
                            rows += '<tr><td> ' + retdateRec + ' </td><td> ' + value.Status + ' </td> <td> ' + value.Rate_Beats
                                + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Rhythm + ' </td><td> ' + value.Volume + ' </td> <td> ' + value.BP_mm_Hg + ' </td></tr>';
                        });
                        $('#tblVitalParametersHistoryEmergency tbody tr').remove();
                        $('#tblVitalParametersHistoryEmergency tbody').html(rows);



                    },
                    error: function (xhr, status, error) {
                        console.error("Error: " + status + ": " + error);
                    }
                });
            }

            Appendtestintable();
            fetchPatientDepOPD();
            createChartOPD();
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

        function Appendtestintable() {
            var patid = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();


            $('#tblLabtest tbody').empty();

            if (category == "01") {
                PageMethods.GetTestListForHistory(patid, function (res) {
                    var test = JSON.parse(res);
                    var Result = 'Result';
                    $.each(test, function (key, value) {
                        var Result = 'Pendding';
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null) value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        debugger;
                        if (value.isApproved == true) {
                            Result = "View Result";
                            Sample = "Yes";
                            $("#btnprint").attr('disabled', false)
                        }
                        if (value.isApproved == false) {
                            Result = "Waiting";
                            Sample = "No";
                            $("#btnprint").attr('disabled', true)
                        }

                        if (value.Test_ID != 0) {
                            row = '<tr>' +
                                '<td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                                '<input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/>' +
                                '<input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/>' +
                                '<input type="hidden" name="txtRotation" value="0">' +
                                '<input type="hidden" name="txtGroupCategory" value="0">' +
                                (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                                ' ' + value.Test_Name + ' ' +
                                (value.GroupName == null ? ' ' : ', ' + value.GroupName) +
                                '</td>' +
                                '<td>' + Result + '</td>' +
                                '<td>' + value.DoctorName + '</td>' +
                                '<td>' +
                                '<a style="border-radius: 4px;background-color:#308665db !important;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PreviewReport(this)" id="btnprint">' +
                                '<i class="fa fa-print" style="color:white !important;"></i></a>' +
                                '</td>' +
                                '<td style="display:none;">' +
                                '<input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.Lab_Test_ID + '" />' +
                                '<input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
                                '<input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Column + '" />' +
                                '<input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.Patient_ID + '" />' +
                                '<input type="hidden" name="Lab_Test_Detail_ID" id="Lab_Test_Detail_ID" value="' + value.Lab_Test_Detail_ID + '" />' +
                                '</td></tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                        console.log(row);
                    });
                });
            }
            if (category == "03") {
                PageMethods.GetTestListForHistoryIPD(patid, function (res) {
                    var test = JSON.parse(res);
                    var Result = 'Result';
                    $.each(test, function (key, value) {
                        var Result = 'Pendding';
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null) value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        debugger;
                        if (value.isApproved == true) {
                            Result = "View Result";
                            Sample = "Yes";
                            $("#btnprint").attr('disabled', false)
                        }
                        if (value.isApproved == false) {
                            Result = "Waiting";
                            Sample = "No";
                            $("#btnprint").attr('disabled', true)
                        }

                        if (value.Test_ID != 0) {
                            row = '<tr>' +
                                '<td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                                '<input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/>' +
                                '<input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/>' +
                                '<input type="hidden" name="txtRotation" value="0">' +
                                '<input type="hidden" name="txtGroupCategory" value="0">' +
                                (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                                ' ' + value.Test_Name + ' ' +
                                (value.GroupName == null ? ' ' : ', ' + value.GroupName) +
                                '</td>' +
                                '<td>' + Result + '</td>' +
                                '<td>' + value.DoctorName + '</td>' +
                                '<td>' +
                                '<a style="border-radius: 4px;background-color:#308665db !important;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PreviewReport(this)" id="btnprint">' +
                                '<i class="fa fa-print" style="color:white !important;"></i></a>' +
                                '</td>' +
                                '<td style="display:none;">' +
                                '<input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.Lab_Test_ID + '" />' +
                                '<input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
                                '<input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Column + '" />' +
                                '<input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.Patient_ID + '" />' +
                                '<input type="hidden" name="Lab_Test_Detail_ID" id="Lab_Test_Detail_ID" value="' + value.Lab_Test_Detail_ID + '" />' +
                                '</td></tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                        console.log(row);
                    });
                });
            }
            if (category == "02") {
                PageMethods.GetTestListForHistoryEmergency(patid, function (res) {
                    var test = JSON.parse(res);
                    var Result = 'Result';
                    $.each(test, function (key, value) {
                        var Result = 'Pendding';
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null) value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        debugger;
                        if (value.isApproved == true) {
                            Result = "View Result";
                            Sample = "Yes";
                            $("#btnprint").attr('disabled', false)
                        }
                        if (value.isApproved == false) {
                            Result = "Waiting";
                            Sample = "No";
                            $("#btnprint").attr('disabled', true)
                        }

                        if (value.Test_ID != 0) {
                            row = '<tr>' +
                                '<td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td>' +
                                '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                                '<input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/>' +
                                '<input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/>' +
                                '<input type="hidden" name="txtRotation" value="0">' +
                                '<input type="hidden" name="txtGroupCategory" value="0">' +
                                (value.DepartmentName == null ? '' : value.DepartmentName + ', ') +
                                ' ' + value.Test_Name + ' ' +
                                (value.GroupName == null ? ' ' : ', ' + value.GroupName) +
                                '</td>' +
                                '<td>' + Result + '</td>' +
                                '<td>' + value.DoctorName + '</td>' +
                                '<td>' +
                                '<a style="border-radius: 4px;background-color:#308665db !important;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PreviewReport(this)" id="btnprint">' +
                                '<i class="fa fa-print" style="color:white !important;"></i></a>' +
                                '</td>' +
                                '<td style="display:none;">' +
                                '<input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.Lab_Test_ID + '" />' +
                                '<input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
                                '<input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Column + '" />' +
                                '<input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.Patient_ID + '" />' +
                                '<input type="hidden" name="Lab_Test_Detail_ID" id="Lab_Test_Detail_ID" value="' + value.Lab_Test_Detail_ID + '" />' +
                                '</td></tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                        console.log(row);
                    });
                });
            }
        }

        let chart;

        function createChartOPD() {
            debugger;
            var patid = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();


            if (chart) {
                chart.destroy();
                chart = null;
            }

            if (category == "01") {
                PageMethods.GetTotalVisits(patid, function (resp) {
                    debugger;
                    var data = JSON.parse(resp);

                    var labDataset = {
                        name: 'OutPatient',
                        data: [
                            data[0].January,
                            data[0].February,
                            data[0].March,
                            data[0].April,
                            data[0].May,
                            data[0].June,
                            data[0].July,
                            data[0].August,
                            data[0].September,
                            data[0].October,
                            data[0].November,
                            data[0].December
                        ],
                        color: '#438eb9 '
                    };

                    var options = {
                        series: [labDataset],
                        chart: {
                            type: 'bar',
                            height: 350
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '55%',
                                endingShape: 'rounded'
                            },
                        },
                        dataLabels: {
                            enabled: false
                        },
                        stroke: {
                            show: true,
                            width: 2,
                            colors: ['transparent']
                        },
                        xaxis: {
                            categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                        },
                    };

                    chart = new ApexCharts(document.querySelector("#VisitGrapgh"), options);
                    chart.render();
                }, function (error) {
                    alert(error.get_message());
                });
            }

            if (category == "03") {
                PageMethods.GetTotalVisitsIPD(patid, function (resp) {
                    debugger;
                    var data = JSON.parse(resp);

                    var labDataset = {
                        name: 'InPatient',
                        data: [
                            data[0].January,
                            data[0].February,
                            data[0].March,
                            data[0].April,
                            data[0].May,
                            data[0].June,
                            data[0].July,
                            data[0].August,
                            data[0].September,
                            data[0].October,
                            data[0].November,
                            data[0].December
                        ],
                        color: '#438eb9 '
                    };

                    var options = {
                        series: [labDataset],
                        chart: {
                            type: 'bar',
                            height: 350
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '55%',
                                endingShape: 'rounded'
                            },
                        },
                        dataLabels: {
                            enabled: false
                        },
                        stroke: {
                            show: true,
                            width: 2,
                            colors: ['transparent']
                        },
                        xaxis: {
                            categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                        },
                    };

                    chart = new ApexCharts(document.querySelector("#VisitGrapgh"), options);
                    chart.render();
                }, function (error) {
                    alert(error.get_message());
                });
            }

            if (category == "02") {
                PageMethods.GetTotalVisitsEmergency(patid, function (resp) {
                    debugger;
                    var data = JSON.parse(resp);

                    var labDataset = {
                        name: 'Emergency',
                        data: [
                            data[0].January,
                            data[0].February,
                            data[0].March,
                            data[0].April,
                            data[0].May,
                            data[0].June,
                            data[0].July,
                            data[0].August,
                            data[0].September,
                            data[0].October,
                            data[0].November,
                            data[0].December
                        ],
                        color: '#438eb9 '
                    };

                    var options = {
                        series: [labDataset],
                        chart: {
                            type: 'bar',
                            height: 350
                        },
                        plotOptions: {
                            bar: {
                                horizontal: false,
                                columnWidth: '55%',
                                endingShape: 'rounded'
                            },
                        },
                        dataLabels: {
                            enabled: false
                        },
                        stroke: {
                            show: true,
                            width: 2,
                            colors: ['transparent']
                        },
                        xaxis: {
                            categories: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
                        },
                    };

                    chart = new ApexCharts(document.querySelector("#VisitGrapgh"), options);
                    chart.render();
                }, function (error) {
                    alert(error.get_message());
                });
            }
        }
        function fetchPatientDepOPD() {
            debugger;
            var Patient_ID = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();
            var boxContainer_ipd = $("#boxContainer_IPD");
            boxContainer_ipd.empty(); // Clear the container before adding new content
            boxContainer_ipd.append('<div>No data available for the selected category.</div>');
            if (category == "01") {
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/GetDepartmentCount",
                    data: JSON.stringify({ patid: Patient_ID, category: category }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        debugger;
                        var data = JSON.parse(resp.d);

                        var boxContainer = $("#boxContainer");

                        boxContainer.empty();

                        if (data && data.length > 0) {

                            data.forEach(function (item) {
                                var box = `
                        <div class="info-box">
                            <div class="info-value">${item.PatientCount || "N/A"}</div>
                            <div class="info-label">${item.Department || "N/A"}</div>
                        </div>
                    `;
                                boxContainer.append(box);
                            });
                        } else {
                            boxContainer.append('<div>No data available for the selected category.</div>');
                        }
                    },
                    error: function (response) {
                        alert("Error: " + response.responseText);
                        console.error("AJAX Error: ", response);
                    }
                });
            }
            if (category == "02") {
                var boxContainer = $("#boxContainer");
                boxContainer.empty();
                boxContainer.append('<div>No data available for the selected category.</div>');

                var boxContainer_ipd = $("#boxContainer_IPD");
                boxContainer_ipd.empty();
                boxContainer_ipd.append('<div>No data available for the selected category.</div>');
            }
            if (category == "03") {
                var boxContainer = $("#boxContainer");
                boxContainer.empty();
                boxContainer.append('<div>No data available for the selected category.</div>');
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/GetDepartmentCountIPD",
                    data: JSON.stringify({ patid: Patient_ID, category: category }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (resp) {
                        debugger;
                        var data = JSON.parse(resp.d);

                        var boxContainer = $("#boxContainer_IPD");

                        boxContainer.empty();

                        if (data && data.length > 0) {
                            data.forEach(function (item) {
                                var box = `
                        <div class="info-box">
                            <div class="info-value">${item.PatientCount || "N/A"}</div>
                            <div class="info-label">${item.Department || "N/A"}</div>
                        </div>
                    `;
                                boxContainer.append(box);
                            });
                        } else {
                            boxContainer.append('<div>No data available for the selected category.</div>');
                        }
                    },
                    error: function (response) {
                        alert("Error: " + response.responseText);
                        console.error("AJAX Error: ", response);
                    }
                });
            }

        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="hdfPatient_ID" />
    <input type="hidden" id="hdfReg_ID" />
    <div class="row">
        <div class="col-lg-2">

            <asp:TextBox ID="txtPatNO" runat="server" class="form-control" />
        </div>
    </div>
    <div class="row">
        <!-- Left Column: Profile Information -->
        <div class="col-lg-5 col-md-5 col-sm-5">
            <div class="card3">
                <div class="profile-info">
                    <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/cake.png" alt="Profile Picture" class="profile-img">
                    <div class="profile-details">
                        <span class="profile-name" id="patname"></span>
                        <p><strong class="">MR No:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="mrno"></span>&nbsp; &nbsp; &nbsp; <strong class="">Age:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="txtage"></span>&nbsp;&nbsp;&nbsp; <strong class="">Gender:</strong> &nbsp; &nbsp; <span style="font-weight: 500 !important" id="gender"></span></p>
                        <p><strong class="">Phone Number:</strong> &nbsp; &nbsp;&nbsp; <span style="font-weight: 500 !important" id="phonenumber"></span></p>
                        <p><strong class="">CNIC:</strong>&nbsp;&nbsp;&nbsp; <span style="font-weight: 500 !important" id="CNIC"></span></p>
                        <p><strong class="">Address:</strong> &nbsp;&nbsp;&nbsp;<span style="font-weight: 500 !important" id="address"></span></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: Appointment Information -->
        <div class="col-lg-6 col-md-6 col-sm-6">
            <div class="appointmentcard">
                <div class="appointment-info">
                    <h5 style="margin-right: 45px; font-size: 1.3em">
                        <strong class="">Upcoming Appointment</strong>

                    </h5>
                    <span class="badge" style="cursor: pointer;"><span id="appdate">Appointment Date</span></span>
                    <h5 style="margin-left: 45px"><strong class="">Consultantaion with &nbsp;<span id="doctorname"></span></strong></h5>
                </div>

                <div class="appointment-details">
                    <div class="row-details">
                        <p><strong class="labelcolor">Last Visit:&nbsp;</strong><span id="prv_visit"></span></p>
                        <p><strong class="labelcolor">Doctor Name:&nbsp;</strong><span id="prvDoctor"></span></p>
                        <p><strong class="labelcolor">Department:&nbsp;</strong><span id="Department"></span></p>
                    </div>
                </div>

            </div>
        </div>
    </div>

    <div class="row" style="margin-bottom: 15px">
        <div class="col-lg-2 col-md-3 col-sm-3">
            <h4>Main Department</h4>
            <select id="ddlmaindepartment" onchange="LoadVitalParameters();"></select>
        </div>
    </div>
    <div class="main-row ">
        <div class="row vitalsTable" id="opdvitals" style="overflow: scroll; height: 230px; margin-left: -2px;">
            <h4 style="height: 30px; background-color: #f0f1f3; width: 120px; padding: 5px 12px; border-radius: 8px;">OPD Vitals</h4>
                <table class="table " id="tblVitalParametersHistory">

                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Pulse</th>
                            <th>Temp</th>
                            <th>Height</th>
                            <th>L.M.P</th>
                            <th>SPO2</th>
                            <th>BSR</th>
                            <th>BMI</th>
                            <th>BP </th>
                            <th>Respiration </th>
                            <th>Weight</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>


        </div>
        <div class="roww vitalsTable" id="ipdvitals" style="overflow: scroll; height: 200px; margin-left: -2px;">
            <h4 style="height: 30px; background-color: #f0f1f3; width: 103px; padding: 5px 12px; border-radius: 8px;">IPD Vitals</h4>
            <table class="table" id="tblVitalParametersHistoryIPD">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Rate Beats</th>
                        <th>Temperature</th>
                        <th>Rhythm</th>
                        <th>Volume</th>
                        <th>Blood Pressure</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
        <div class="roww vitalsTable" id="emergencyVital" style="overflow: scroll; height: 200px; margin-left: -2px;">
            <h4 style="height: 30px; background-color: #f0f1f3; width: 167px; padding: 5px 12px; border-radius: 8px;">Emergency Vitals</h4>
            <table class="table" id="tblVitalParametersHistoryEmergency">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Status</th>
                        <th>Rate Beats</th>
                        <th>Temperature</th>
                        <th>Rhythm</th>
                        <th>Volume</th>
                        <th>Blood Pressure</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>
    <div class="row g-3">
        <div class="col-lg-4 col-md-4 col-sm-6">
            <div class="card statusCards">
                <div style="display: flex; align-items: center; margin-top: -10px;">
                    <img class="img-fluid icons" src="../../../wwwroot/Tibbit_theme/images/dashboard_Icons/appointmentStats.png" alt="lab" />
                    <h4>Visits</h4>
                </div>

                <hr style="margin-bottom: 35px !important" />
                <div class="row">
                    <div class="col-lg-6 col-md-6 col-sm-6">
                        <div class="visits-cards stat-item">
                            <span class="number" id="opd"></span>
                            <span class="label">OPD Visits</span>
                        </div>
                    </div>
                    <div class="col-lg-6 col-md-6 col-sm-6">
                        <div class="visits-cards stat-item">
                            <span class="number" id="emergency"></span>
                            <span class="label">Emergency Visits</span>
                        </div>
                    </div>
                </div>
                <div class="row" style="margin-top: 10px">
                    <div class="col-lg-3 col-md-3 col-sm-3"></div>
                    <div class="col-lg-6 col-md-6 col-sm-6">
                        <div class="visits-cards stat-item">
                            <span class="number" id="ipd"></span>
                            <span class="label">IPD Visits</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-4 col-md-4 col-sm-4">
            <div class="card statusCards">
                <div style="display: flex; align-items: center; margin-top: -10px;">
                    <img class="img-fluid icons" src="../../../wwwroot/Tibbit_theme/images/dashboard_Icons/statistics.png" alt="lab" />
                    <h4>OPD Patient Status</h4>
                </div>
                <hr />
                <div id="boxContainer" class="box-container"></div>
            </div>
        </div>

        <div class="col-lg-4 col-md-4 col-sm-4">
            <div class="card statusCards">
                <div style="display: flex; align-items: center; margin-top: -10px;">
                    <img class="img-fluid icons" src="../../../wwwroot/Tibbit_theme/images/dashboard_Icons/statistics.png" alt="lab" />
                    <h4>IPD Patient Status</h4>
                </div>
                <hr />
                <div id="boxContainer_IPD" class="box-container"></div>

            </div>
        </div>
    </div>

    <div class="row" style="margin-top: 10px;">
        <div class="col-lg-6 col-md-6 col-sm-6 cardcard statusCards">
            <div>
                <h4 class="labelcolor" style="font-size: 24px">Monthly Wise Visit</h4>

            </div>
            <div id="VisitGrapgh" style="height: 300px; width: 100%;"></div>
        </div>
        <div class="col-lg-6 col-md-6 col-sm-6" style="margin-left: -10px;">
            <div class="card2 statusCards">
                <h4 class="labelcolor" style="font-size: 24px">Test List</h4>
                <hr />
                <div class="table table-container" style="overflow-y: scroll; height: 400px">
                    <table id="tblLabtest" class="table table-bordered table-custom tests-table">
                        <thead>
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
        </div>
    </div>
</asp:Content>
