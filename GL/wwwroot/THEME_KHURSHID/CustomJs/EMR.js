  <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            loadtokenInputsByMrNo();
            FillModePresentation();
            $("#ipdvitals").hide();
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
                        $('#doctorname').text(data.doctor.Emp_Name);  // Display doctor name
                    } else {
                        $('#doctorname').text("");  // Handle case where doctor is null
                    }

                    if (data && data.AppointmentDate) {
                        var date = data.AppointmentDate;
                        date = moment(date).format('MMMM-DD-YY');
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
                        $('#prvDoctor').text(data.doctor.Emp_Name);  // Display doctor name
                    } else {
                        $('#prvDoctor').text("");  // Handle case where doctor is null
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
            var options = '<option value="0">Please Select</option>';

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

            if (category == "01") {
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/LoadVitalParametersHistory",
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json", // Expect JSON response
                    success: function (res) {
                        debugger;
                        var rows = '';
                        $.each(JSON.parse(res.d), function (key, value) {
                            var date = moment(value.Created_Time).format('DD-MM-YY');
                            console.log(value);  // Check if data is being processed correctly

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

            // Handle category == "03" with AJAX
            if (category == "03") {
                $("#opdvitals").hide();
                $("#opdvitals").empty();
                $("#ipdvitals").show();
                $.ajax({
                    type: "POST",
                    url: "EMR.aspx/LoadVitalParametersHistoryIPD", // Same request but for discharge data
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json", // Expect JSON response
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


            Appendtestintable();
            createChartOPD();
        }

        function Appendtestintable() {
            var patid = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();

            if (category == "01") {
                PageMethods.GetTestListForHistory(patid, function (res) {
                    var test = JSON.parse(res);
                    $.each(test, function (key, value) {

                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        if (value.Test_ID != 0) {


                            row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + value.DoctorName + '</td></tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                    });
                });
            }
            if (category == "03") {
                PageMethods.GetTestListForHistoryIPD(patid, function (res) {
                    var test = JSON.parse(res);
                    $.each(test, function (key, value) {

                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        if (value.Test_ID != 0) {


                            row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + value.DoctorName + '</td></tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                    });
                });
            }
        }
        let chart; // Declare globally to maintain state

        function createChartOPD() {
            debugger;
            var patid = $("#hdfReg_ID").val();
            var category = $('#ddlmaindepartment').val();

            // Destroy the chart if it exists
            if (chart) {
                chart.destroy();
                chart = null; // Clear the chart reference
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
                        color: '#EFA63E'
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
                        color: '#EFA63E'
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
                        color: '#EFA63E'
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





    </script>