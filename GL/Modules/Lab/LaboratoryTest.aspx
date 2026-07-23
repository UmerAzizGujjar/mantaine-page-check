<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaboratoryTest.aspx.cs" Inherits="PMS.LaboratoryTest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/AddNewLabTest.css" rel="stylesheet" />
    <style>
        
.MyTable {
    width: 100%;
    max-width: 100%;
    margin-bottom: 20px;
}

    .MyTable th {
        background-color: #ffffff !important;
        color: #6a6969 !important;
    }
.vitalsTable {
    border: 3px solid #cccccc;
    border-radius: 6px;
    padding: 12px 16px;
    background-color: #fff;
    margin-bottom: 15px;
}
    </style>
    <script type="text/javascript">

      
        function ShowReport() {
            var table_tds = $('.test-table tr:not(:first)').find('#valuetype[value=table]').closest('tr').find('td:nth-child(3)');
            var fixed_tds = $('.test-table tr:not(:first)').find('#valuetype[value=fixed]').closest('tr').find('td:nth-child(3)');
            var valueType = $('#type').val();
            var tids = $('#IDtest').val();
            if (valueType == "table") {
                window.open('ReportViewer.aspx?ReportName=TestResult&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }
            if (valueType == "fixed") {
                window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }
        }
        function FillModePresentation() {
            var options = '<option value="0">Vital Type</option>';

            $.ajax({
                url: 'LaboratoryTest.aspx/ModePresentation',
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
            var patid = $('#<%= txtPatient_ID.ClientID%>').val();
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
                    url: "LaboratoryTest.aspx/LoadVitalParametersHistory",
                    data: JSON.stringify({ patid: patid }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (res) {
                        debugger;
                        var rows = '';
                        $.each(JSON.parse(res.d), function (key, value) {
                            var date = moment(value.Created_Time).format('DD-MM-YY');
                            // console.log(value);
                            $("#hdfoutPatID").val(value.Out_Patient_ID);
                            rows += '<tr><td  value="' + value.Out_Patient_ID + '"> ' + date + ' </td><td>' + value.Status + '</td> <td> ' + value.Pulse_Min
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
                    url: "LaboratoryTest.aspx/LoadVitalParametersHistoryIPD",
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
                    url: "LaboratoryTest.aspx/LoadVitalParametersHistoryemergency",
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

            //Appendtestintable();
            //fetchPatientDepOPD();
            //createChartOPD();
        }
        function swipe() {

            var largeImage = document.getElementById('Image1');
            largeImage.style.display = 'block';
            largeImage.style.width = 200 + "px";
            largeImage.style.height = 200 + "px";
            var url = largeImage.getAttribute('src');
            window.open(url, 'Image', 'width=largeImage.stylewidth,height=largeImage.style.height,resizable=1');
        }


        $(document).ready(function () {

            $("#ipdvitals").hide();
            $("#emergencyVital").hide();
            $("#opdvitals").hide();
            $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
            $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
            $("#testViewDetails").on('click', function () {

                var html = $('#tblPendingPatients tbody').html();
                $('#tstDetailModal tbody').html(html);

                $('#TestViewDetail').modal({
                    backdrop: 'static'
                });

                debugger;
                $('#tblPendingPatients tbody tr').remove();
                $('#tblPendingPatients tbody').html(rows);
                var s = $(anchor);
                $(s).closest('tr').remove();
            });
            FillModePresentation();
            bindControls();
            enabledisable();
            GetMainDepartments();
            FillLabTests();
            $('#txtSearchDate').datepicker();
            if ($('#<%= txtPatient_ID.ClientID%>').val() != "") {
                LoadTestsHistory();
                LoadVitalParameters();
            }
               
            $('#main-departments').val(localStorage.DeptID);
            jQuery(window).on("load", function () {
                debugger;
                $('#main-departments').val(localStorage.DeptID);

            });
            $('#<%= txtPatient_ID.ClientID%>').change(function () {

                loadAjax();
                $('#ctl00_MainContent_saveLabTest').val("Save");
                $('#ctl00_MainContent_txtLab_Test_ID').val("(New)");
                $('#tbltest tr').remove();
                LoadTestsHistory();
                LoadVitalParameters();
            });
            $('#txtMRNOSearch').on('keyup', function (e) {
                debugger;
                var MRno = $('#txtMRNOSearch').val();
                var tbl = document.getElementById('tblPendingPatients');
                if (MRno.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[1].innerText != MRno) {
                            var row = tbl.rows[i];
                            row.style.display = 'none';
                        }
                        else {
                            var row = tbl.rows[i];
                            row.style.display = '';
                        }
                    }
                }
                else {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }
                }
            });

            <%if (AppConfig.UserName == "Prof Tahir")
                  {%>
            localStorage.DeptID = "001";
            $('#main-departments').val(localStorage.DeptID);
            <%}%>
            <% else if (AppConfig.UserName == "Dr.Sofia Khan")
                  {%>
            localStorage.DeptID = "001";
            $('#main-departments').val(localStorage.DeptID);
            <%}%>
            <% else if (AppConfig.UserName == "Imran.Yousaf")
                  {%>
            localStorage.DeptID = "003";
            $('#main-departments').val(localStorage.DeptID);
            <%}%>
        <%else
                  {%>
            localStorage.DeptID = "001";
            $('#main-departments').val(localStorage.DeptID);
       <%}%>
        });
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

                    var img = $("<img onclick='window.open(this.src)' />");
                    img.attr("style", "height:60px;width: 60px");

                    var dd = "LabTestImg\\" + value.Image_path;
                    img.attr("src", dd);
                    dvPreview.append(img);
                    if (value.Image_path == null || value.Image_path == "") {
                        $("#errorMsg").show();
                    }
                    else { $("#errorMsg").hide(); }
                });
            });
        }
        function EditData(anchor) {

            $.ajax({
                type: "POST",
                url: "LaboratoryTest.aspx/GetTestDetail",
                data: "{'TestDetailID':" + anchor + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    $('#IDtest').val(anchor);
                    $('#type').val(data.d.ValueType);
                    var type = data.d.ValueType;
                    $('#myModal').modal({
                        backdrop: 'static'
                    });
                    showImage(anchor);
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function FillLabTests() {
            var options = '';
            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlLabTest').html(options);
                $('#ddlLabTest').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function LoadTestsHistory() {

            $('#HeaderTests').html('<h2 class="headingcolor">Loading Previous History Please Wait....</h2>')
            var hdFile_ID = $("#ctl00_MainContent_txtPatient_ID").val();
            if (hdFile_ID != null || hdFile_ID != " " || hdFile_ID != "undefined") {
                PageMethods.GetTestListForHistory(hdFile_ID, function (res) {
                    var test = JSON.parse(res);
                    var rows = '';
                    var result;
                    $.each(test, function (key, value) {
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.Test_Collected_By == null)
                            value.Test_Collected_By = "";
                        if (value.Test_Collected_On == null)
                            value.Test_Collected_On = "";
                        var CDate = moment(value.Test_Collected_On).format('L');
                        var RDate = moment(value.Test_Ready_On).format('M/D/YYYY h:m:s A');
                        if (value.Rotation == null)
                            value.Rotation = "";
                        if (value.Rotation == 0)
                            value.Rotation = "";
                        if (value.L_R_Rotation_ID == 0)
                            value.L_R_Rotation_ID = "";
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        if (value.mainDepartmentName == null)
                            value.mainDepartmentName = "";
                        if (value.Is_Result == true) {
                            result = "View Result";
                            rows += '<tr><td><input type="hidden" name="testID" value="' + value.Lab_Test_Detail_ID + '" />' + CDate + '</td><td>' + RDate + '</td><td><input type="hidden" name="Bill_No" value="' + value.Bill_No + '" />' + value.Bill_No + '</td><td><input type="hidden" name="Patid" value="' + value.mr_no_sequence + '" />' + value.mr_no_sequence + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' + value.mainDepartmentName + ',' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td><td>' + value.Test_Collected_By + '</td><td><a href="javascript:void(0)"onclick="EditData(' + value.Lab_Test_Detail_ID + ')" id="result" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + result + '</a></td></tr>';
                        }
                        else {

                            result = "Waiting"
                            rows += '<tr><td><input type="hidden" name="testID" value="' + value.Lab_Test_Detail_ID + '" />' + CDate + '</td><td>' + RDate + '</td><td><input type="hidden" name="Bill_No" value="' + value.Bill_No + '" />' + value.Bill_No + '</td><td><input type="hidden" name="Patid" value="' + value.mr_no_sequence + '" />' + value.mr_no_sequence + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' + value.mainDepartmentName + ',' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td><td>' + value.Test_Collected_By + '</td><td>' + result + '</td></tr>';
                        }
                    });
                    $('#tblHistoryTests tbody tr').remove();
                    $('#tblHistoryTests tbody').html(rows);
                    $('#HeaderTests').html('<h2 class="headingcolor">Previous History</h2>')
                });
            }
        }
        function FillTestsByCategory(CategoryID) {
            var options = '';
            if (CategoryID == '002') {
                $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').show();
                $('#ddlXRayLF').show();
                PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
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
                $('#ddlXRayLF').hide();
                $('#divRotation').show();
                PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                    options = '';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                options = '';
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                });
                $('#groupsCat').html(options);
                $('#groupsCat').select2();
            });
        }
        function FillTest() {
            var Grpdpt = $('#groups').val();
            var options;
            PageMethods.FillTestName(Grpdpt, function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.Test_ID + '"> ' + value.Test_Name + ' </option>';
                });
                $('#groupsCat').empty();
                $('#groupsCat').html(options);
            });
        }
        function bindDate() {
        }
        function bindControls() {
            bindDate();
            var hdFile_ID = $("#hdfPatient_ID").val();
            if (hdFile_ID != "(New)" && hdFile_ID != null && hdFile_ID != "") {
                var Patient_ID = document.getElementById('<%= txtPatient_ID.ClientID%>').value;
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else if (document.getElementById('<%= chkCustomer.ClientID %>').checked == false) {
                loadtokenInputsDefault();
            }
            
        }
        function hide() {
            $('#tr-1').hide();
            $('#tr-2').hide();
            $('#tr-3').hide();
            $('#tr-4').hide();
        }
        function show() {
            $('#tr-1').show();
            $('#tr-2').show();
            $('#tr-3').show();
            $('#tr-4').show();
        }
        function enabledisable() {
            var chkBox = document.getElementById('<%= chkCustomer.ClientID %>').checked;
            if (chkBox == true) {
                hide();
            }
            else {
                show();
            }
            return true;
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
                            $('#tbltest tr').remove();
                            
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
                url: "LaboratoryTest.aspx/GetDetail",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        debugger;

        function OnSuccess(data) {
            debugger;
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
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

    </script>
    <script type="text/javascript">
        $(document).ready(function () {
            $('#add_all_test').change(function () {
                if ($(this)[0].checked) {
                    $('#tests')[0].selectedIndex = 0;
                    $('#tests').prop('disabled', true);
                } else {
                    $('#tests').prop('disabled', false);
                }
            });
            $('#print-slip').click(function () {
                var lid = '<%= Request.QueryString["ID"] %>';
                window.open('ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + lid);
            });
            PopulateTestList();
            $('#add-new-test').click(function () {

                var patientID = $('#<%= txtPatient_ID.ClientID %>').val();
                if (patientID == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select MR No.',
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
                var test = $('#main-departments').val();
                if (test != "001") {
                    document.getElementById('lab').style.display = "none";
                    document.getElementById('labtest').style.display = "none";
                    document.getElementById('labtest1').style.display = "none";
                    $('#radtest1').show();
                    $('#radtest2').show();
                    $('#radtest3').show();
                    $('#radtest4').show();
                }
                else {
                    $('#lab').show();
                    $('#labtest').show();
                    $('#labtest1').show();
                    $('#radtest1').hide();
                    $('#radtest2').hide();
                    $('#radtest3').hide();
                    $('#radtest4').hide();
                }
                $('#MedicationModel').modal({
                    backdrop: 'static'
                });
            });
            $('#add-new-testDirect').click(function () {
                PageMethods.GetLabTestDDLDetails(ddlLabTest.value, function (res) {
                    console.clear();
                    $.each(JSON.parse(res), function (key, value) {
                        var test = $('#tests-list');
                        var date = '<%=DateTime.Now.Date.ToString(AppConfig.DateFormat)%>';
                        var datetime = '<%=DateTime.Now%>';
                        var userName = '<%= AppConfig.UserName %>';
                        var TestMainDepartmentName;
                        var count = tbltest.rows.length;
                        var row = '<tr><td><input type="hidden" name="LabTestDetali" value="0"><input type="hidden" name="testDate" value="0">' + datetime + '</td>  <td><input type="hidden" name="testID" value="' + value.TestID + '" /> <input type="hidden"name="txtRotation" value="0"> ' + (value.MainDepartmentName == null ? '' : value.MainDepartmentName + ', ') + ' ' + value.TestName + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td> <td><input type="hidden"name="txtArea" value="' + $('#ctl00_MainContent_txtAreaOfInterest').val() + '" />' + $('#ctl00_MainContent_txtAreaOfInterest').val() + '</td>  <td><input type="checkbox" id="Payment' + count + '" name="payment" checked /></td><td><input name="Type" value="Direct To Lab" style="display:none" /> <input type="text"  value="" disabled="disabled" id="txtCollectionDate' + count + '" name="txtCollectionDate" style="width:167px ! important;" /></td><td>  <input type="text" id="txtReadyBy' + count + '" name="txtReadyBy" style="width:167px !important;"/></td><td><input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:100px !important;" value="' + userName + '"/></td>><td><input type="text" id="txtPerformedBy" name="txtPerformedBy" style="width:100px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + count + '" onclick="EnableRemarks(this)" name="Emergancy"  style="width: 92px;height: 17px;"></input></td><td><input type="text" name="txtRemarks" style="width: 138px !important;display:none"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                        var test_array = $('#tbltestDetail').find('input[name=testID][value="' + value.TestID + '"]');
                        if (test_array.length > 0) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'This test already added!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        } else {
                            $('#MedicationModel').modal('hide');
                            $('#tbltestDetail').append(row);
                            $("#txtReadyBy" + count).datetimepicker({ format: 'm-d-y   h:i:s A' });
                            $('#txtCollectionDate' + count).datetimepicker();
                            $("#txtReadyBy" + count).val(datetime);
                            $('#txtCollectionDate' + count).val(datetime);
                        }
                    });
                }, function (err) { });

            });
            $('#add-new-testList').click(function () {

                $("#btnXray").removeClass("btn-danger").addClass("btn-info");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                var Result = 'Result';
                var testd = $('#groupsCat').val();
                var date = '<%= DateTime.Now %>';
                var IsRotationShow = $('#divRotation').is(":visible");
                var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
                var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
                var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
                var ddl_XRayLF_Name = IsRotationShow ? $('#ddlXRayLF option:selected').text() : " ";
                var ddlXRayLF_Name = ',' + ddl_XRayLF_Name;
                $.ajax({
                    type: "POST",
                    url: "LaboratoryTest.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: testd }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var MainDeptName = JSON.parse(data.d);
                        TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                        MainDepartmentName = MainDeptName[0].estMainDepartmen;
                        var test = $('#tests-list');
                        var datetime = '<%= DateTime.Now%>';

                        var df = tbltest.rows.length;
                        var date = '<%=DateTime.Now.Date.ToString(AppConfig.DateFormat)%>';

                        var userName = '<%= AppConfig.UserName %>';
                        if (MainDepartmentName != '003')
                            ddl_XRayLF_Name = "";
                        ddlXRayLF_Name == 0;
                        var row = '<tr><td><input type="hidden" name="LabTestDetali" value="0"><input type="hidden" name="testDate" value="0">' + datetime + '</td><td><input type="hidden" name="testID"  value="' + testd + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '">' + TestMainDepartmentName + ', ' + $('#groupsCat').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Name + '</td><td></td><td><input type="checkbox" id="Payment' + df + '" name="payment" checked/></td><td> <input name="Type" value="Direct To Lab" style="display:none"/><input type="text"  value="" id="txtCollectionDate' + df + '" name="txtCollectionDate" disabled="disabled"  style="width:167px !important;"/></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:167px !important;"/></td><td> <input type="text" id="txtCollectionBy"  name="txtCollectionBy" style="width:100px !important;"  value="' + userName + '"/></td><td> <input type="text" id="txtPerformedBy" name="txtPerformedBy" style="width:100px !important;"  value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" onclick="EnableRemarks(this)" name="Emergancy"  style="width: 92px;height: 17px;"></input></td><td><input  type="text" name="txtRemarks" style="width: 138px !important;display:none"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        var test_array = $('.tests-table').find('input[name=testID][value=' + $('#groupsCat').val() + ']');
                        if (test_array.length > 0) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'This test already added!',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        } else {
                            $('#MedicationModel').modal('hide');
                            $('#tbltestDetail').append(row);
                            $('#txtReadyBy' + df).datetimepicker({ format: 'm-d-y   h:i:s A' });
                            $('#txtCollectionDate' + df).datepicker();
                            $("#txtReadyBy" + df).val(datetime);
                            $('#txtCollectionDate' + df).val(datetime);
                        }
                    }
                });
            });

            $('#ctl00_MainContent_saveLabTest').click(function () {
                debugger;
               
                var btnSave = $('#ctl00_MainContent_saveLabTest').val();
               
                var btnSave = $('#ctl00_MainContent_saveLabTest').val();
                var table = $('#tbltest');
                var test_list = [];
                var transType = $("input[name='Type']").val();
                var transID = $("input[name='testDate']").val();
                //                
                var Bill_Details_ID = $("input[name='Bill_Details_ID']").val();
                if (transID == "null") {
                    transID = 0;
                }
                var LabTestID = $('#ctl00_MainContent_txtLab_Test_ID').val();
                if (LabTestID == "(New)") {
                    LabTestID = 0;
                }

                table.find('tr').each(function (key, value) {
                    test_list.push({ 'TestID': $(value).find('td input[name=testID]').val(), 'TestDID': $(value).find('td input[name=LabTestDetali]').val(), 'ParrentLabTestDetali': $(value).find('td input[name=ParrentLabTestDetali]').val(), 'ParentLabTestID': $(value).find('td input[name=ParentLabTestID]').val(), 'Bill_Details_ID': $(value).find('td input[name=Bill_Details_ID]').val(), 'GroupCatID': $(value).find('td input[name=GroupCatID]').val(), 'Area': $(value).find('td input[name=txtArea]').val(), 'Payment': $(value).find('td input[name=payment]')[0].checked, 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'TestCollectedOn': $(value).find('td input[name=txtCollectionDate]').val(), 'TestReadyOn': $(value).find('td input[name=txtReadyBy]').val(), 'TestCollectedBy': $(value).find('td input[name=txtCollectionBy]').val(), 'TestPerformedBy': $(value).find('td input[name=txtPerformedBy]').val(), 'Emergancy': $(value).find('td input[name=Emergancy]')[0].checked, 'Remarks': $(value).find('td input[name=txtRemarks]').val() });
                });
                var patientID = '#<%= txtPatient_ID.ClientID %>';
                var labTest = { 'PatientID': $(patientID).val(), 'TestList': test_list };
                PageMethods.SaveTest(LabTestID, btnSave, transType, transID, JSON.stringify(labTest), function (res) {
                    $('#ctl00_MainContent_saveLabTest').val("Update");
                    localStorage.DeptID = $("#main-departments").val();
                    window.location = "LaboratoryTest.aspx"; 
                });
            });
        });
        function New() {
            window.location = "LaboratoryTest.aspx";
            $("#main-departments").val(0);
        }
        function PopulateTestList() {
            var options = '';
            PageMethods.GetTests(function (tests) {
                $.each(JSON.parse(tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '">' + value.Test_Name + '</option>';
                });
                $('#tests-list').html(options);
                $('#tests-list').select2();
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

        function GetTestList(id) {
            PageMethods.GetTestList(id, function (res) {
                var test = JSON.parse(res);
                var rows = '';
                $.each(test, function (key, value) {
                    var timeStamp = parseInt(value.Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    if (value.Test_Collected_By == null)
                        value.Test_Collected_By = "";
                    if (value.Test_Ready_On == null)
                        value.Test_Ready_On = "";
                    if (value.Test_Collected_On == null)
                        value.Test_Collected_On = "";
                    if (value.Test_Performed_By == null)
                        value.Test_Performed_By = "";
                    if (value.Area_Of_Interest == null)
                        value.Area_Of_Interest = "";
                    if (value.Rotation == null)
                        value.Rotation = "";
                    if (value.Rotation == 0)
                        value.Rotation = "";
                    if (value.Rotation == "undefined")
                        value.Rotation = "";
                    if (value.Rotation == "")
                        value.Rotation = "";
                    if (value.L_R_Rotation_ID == 0)
                        value.L_R_Rotation_ID = "";
                    if (value.L_R_Rotation_ID == null)
                        value.L_R_Rotation_ID = "";
                    if (value.L_R_Rotation_ID == "undefined")
                        value.L_R_Rotation_ID = "";
                    if (value.L_R_Rotation_ID == "")
                        value.L_R_Rotation_ID = "";

                    var dateTest_Ready = moment(value.Test_Ready_On).format('M/D/YYYY h:m:s A');
                    
                    var dateTest_Colection = moment(value.Test_Collected_On).format('M/D/YYYY h:m:s A');
                    var df = tbltest.rows.length;
                    rows += '<tr><td><input type="hidden" name="testDate" value="' + value.Parent_Transaction_Type_ID + '"><input type="hidden" name="LabTestDetali" value="' + value.Lab_Test_Detail_ID + '">' + date + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '" /> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '">' + value.DepartmentName + ',' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td><td><input type="hidden" name="txtArea" value="' + value.Area_Of_Interest + '" />' + value.Area_Of_Interest + '</td><td><input type="checkbox" name="payment" ' + (value.Status ? 'checked' : '') + ' disabled style="width: 92px;height: 17px;" /></td><td><input name="Type" value="' + value.Parent_Transaction_Type + '" style="display:none"/><input type="text" style="width:156px !important;margin-left:-6px"  id="txtCollectionDate" name="txtCollectionDate" disabled="disabled" value="' + dateTest_Colection + '"/></td><td>  <input type="text" id="txtReadyBy' + key + '"  name="txtReadyBy" value="' + dateTest_Ready + '" style="width:155px !important;margin-left:-8px"/></td><td> <input type="text"  id="txtCollectionBy" name="txtCollectionBy" value="' + value.Test_Collected_By + '" style="width:96px !important;margin-left:-6px"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" value="' + value.Test_Performed_By + '" style="width:96px !important;margin-left:-6px"/></td><td><input type="checkbox" onclick="EnableRemarks(this)"  id="Emergancy' + df + '" name="Emergancy"  ' + (value.Emergancy ? 'checked' : '') + '  style="width: 92px;height: 17px;" /></td><td><input type="text" name="txtRemarks" style="width: 121px !important" value="' + value.Remark + '" /></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                });
                $('#tbltest').html(rows);
                $.each($('#tbltestDetail tbody tr'), function (key, value) {

                    var emergancy = $(value).find('input[name="Emergancy"]').prop('checked');
                    if (emergancy == true)
                        $(value).find('input[name="txtRemarks"]').show();
                    else
                        $(value).find('input[name="txtRemarks"]').hide();
                });

                var count = tbltest.rows.length;
                for (i = 0; i < count; i++) {
                    $('#txtReadyBy' + i).datetimepicker({ format: 'm-d-y   h:i:s A' });
                }
                $('#ctl00_MainContent_saveLabTest').val("Update");
            });
        }
        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }
        function deleteTest(crow) {
            var row = $(crow).parents('tr')[0];
            row.remove();
        }
        function GetMainDepartments(d) {
            var options = '<option value="0">Select Department</option>';
            PageMethods.GetMainDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {

                    if (value.DataValue_Name != "005") {
                        if (value.DataValue_Name != "006") {
                            if (value.DataValue_Name != "007") {

                                options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                            }
                        }
                    }
                });

                $('#main-departments').html(options);
                $('#main-departments').val(localStorage.DeptID);
                TestDetail();
            });
        }
        function download() {
            var src = Image1.src;
            PageMethods.GetImage(src, function (departments) {
            });
        }
       


        function SearchByMRNoTestDetail() {
            debugger;
            var MRno = $('#txtMRNOSearch').val();
            var SelectedDepartment = $('#main-departments').find('option:selected')[0].value;
            if (MRno == "") {
                TestDetail();
            }
            else {

                if (SelectedDepartment == "001") {
                    PageMethods.MRNoPendingLabTest(SelectedDepartment, MRno, function (data) {
                        var parsedData = JSON.parse(data);
                        var rows = '';
                        $.each(parsedData, function (key, value) {
                            if (value.DoctorName == null || value.DoctorName == "0")
                                value.DoctorName = "";
                            if (value.Rotation == null)
                                value.Rotation = "";
                            if (value.Rotation == 0)
                                value.Rotation = "";
                            if (value.L_R_Rotation_ID == 0)
                                value.L_R_Rotation_ID = "";
                            if (value.L_R_Rotation_ID == null)
                                value.L_R_Rotation_ID = "";
                            var retdate = moment(value.Created_Time).format('LLLL');
                            if (value.Lab_Test_Detail_ID == null) {
                                value.Recieved_ID == "0";
                                value.Lab_Test_Detail_ID = "0";
                            }
                            if (value.chkPackages == null)
                                value.chkPackages = "0";
                            var mydate = new Date(Date.parse(value.Entry_Date));
                            var retdate = mydate.toLocaleDateString();

                            if (value.Test_ID != 0) {
                                if (value.Recieved_ID != 0) {
                                    rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                                }
                                else {
                                    rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden"" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                                }
                            }
                            else {
                                if (value.Recieved_ID != 0) {
                                    rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="OPD" value="' + value.Parent_Transaction_Type_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.GroupCategory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                                }
                                else {

                                    rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                                }
                            }
                        });
                        $('#tblPendingPatients tbody').html(rows);
                        $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                        $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
                        CountResult(SelectedDepartment);
                    }, function (exec) { alert(exec.getmessage()); })
                }
                else {
                    debugger;
                    PageMethods.MRNOPendingTest(SelectedDepartment, MRno, function (data) {
                        debugger;
                        var parsedData = JSON.parse(data);
                        var rows = '';
                        $.each(parsedData, function (key, value) {
                            if (value.DoctorName == null || value.DoctorName == "0")
                                value.DoctorName = "";
                            if (value.Rotation == null)
                                value.Rotation = "";
                            if (value.Rotation == 0)
                                value.Rotation = "";
                            if (value.L_R_Rotation_ID == 0)
                                value.L_R_Rotation_ID = "";
                            if (value.L_R_Rotation_ID == null)
                                value.L_R_Rotation_ID = "";
                            if (value.chkPackages == null)
                                value.chkPackages = "0";

                            var mydate = new Date(Date.parse(value.Entry_Date));
                            var retdate = mydate.toLocaleDateString();
                            if (value.Recieved_ID != null) {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '" /><input type="hidden" name="testCatID" value="0"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '" /> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '" />' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';

                            }
                            else {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"><input type="hidden" name="testCatID" value="0"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '">' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                            }
                        });

                        $('#tblPendingPatients tbody').html(rows);
                        $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                        $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
                        CountResult(SelectedDepartment);
                    }, function () { })
                }
            }
        }

        function getTransactionColor(type) {
            switch (type) {
                case 'EmergencyPatient': return 'red';
                case 'OutPatient': return 'green';
                case 'InPatient': return '#FBB117';
                case 'Front Desk': return '#FF6F61';
                default: return 'black';
            }
        }

        function TestDetail() {
            debugger;
            var SelectedDepartment = $('#main-departments').find('option:selected')[0].value;
            if (SelectedDepartment == "001") {

             
                PageMethods.AllPendingLabTestDetail(SelectedDepartment, function (data) {
                    var parsedData = JSON.parse(data);
                    var rows = '';
                    $.each(parsedData, function (key, value) {
                        if (value.DoctorName == null || value.DoctorName == "0")
                            value.DoctorName = "";
                        if (value.Rotation == null)
                            value.Rotation = "";
                        if (value.Rotation == 0)
                            value.Rotation = "";
                        if (value.L_R_Rotation_ID == 0)
                            value.L_R_Rotation_ID = "";
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var retdate = moment(value.Created_Time).format('LLLL');
                        if (value.Lab_Test_Detail_ID == null) {
                            value.Recieved_ID == "0";
                            value.Lab_Test_Detail_ID = "0";
                        }
                        if (value.chkPackages == null)
                            value.chkPackages = "0";
                        debugger;
                        var retdate = moment(value.Date).format('DD-MMM-YYYY hh:mm A');

                        if (value.Test_ID != 0) {
                            if (value.Recieved_ID != null) {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/><input type="hidden" name="RetDate" value="' + retdate + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td><span style="color: ' + getTransactionColor(value.Transaction_Type) + ';">' + value.Transaction_Type + '</span></td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                            }
                            else {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/><input type="hidden" name="RetDate" value="' + retdate + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td><span style="color: ' + getTransactionColor(value.Transaction_Type) + ';">' + value.Transaction_Type + '</span></td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                            }
                        }
                        else {
                            if (value.Recieved_ID != null) {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="OPD" value="' + value.Parent_Transaction_Type_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/><input type="hidden" name="RetDate" value="' + retdate + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO"  id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td><span style="color: ' + getTransactionColor(value.Transaction_Type) + ';">' + value.Transaction_Type + '</span></td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                            }
                            else {

                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/><input type="hidden" name="RetDate" value="' + retdate + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td><span style="color: ' + getTransactionColor(value.Transaction_Type) + ';">' + value.Transaction_Type + '</span></td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                            }
                        }
                    });
                    $('#tblPendingPatients tbody').html(rows);
                    $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                    $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
                    CountResult(SelectedDepartment);
                }, function (exec) { alert(exec.getmessage()); })

            }
            else {
               
            }
        }


        
        function ShowAllCnicWise() {

            $('#chkTodayAll').attr('checked', false);

            var SelectedDepartment = $('#main-departments').find('option:selected')[0].value;

            var cnic = $('#txtCNIC').val();

           

            PageMethods.PendingLabTestCNIC(SelectedDepartment, cnic, function (data) {

               
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {

                    if (value.DoctorName == null || value.DoctorName == "0")
                        value.DoctorName = "";
                    if (value.Rotation == null)
                        value.Rotation = "";
                    if (value.Rotation == 0)
                        value.Rotation = "";
                    if (value.L_R_Rotation_ID == 0)
                        value.L_R_Rotation_ID = "";
                    if (value.L_R_Rotation_ID == null)
                        value.L_R_Rotation_ID = "";
                    var retdate = moment(value.Created_Time).format('LLLL');
                    if (value.Lab_Test_Detail_ID == null) {
                        value.Recieved_ID == "0";
                        value.Lab_Test_Detail_ID = "0";
                    }
                    if (value.Transaction_Type == null || value.Transaction_Type == "0") {
                        value.Transaction_Type = "";
                    }
                    if (value.chkPackages == null)
                        value.chkPackages = "0";
                    var mydate = new Date(Date.parse(value.Entry_Date));
                    var retdate = mydate.toLocaleDateString();

                    if (value.Test_ID != 0) {
                        if (value.Recieved_ID != 0) {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td>' + value.cnic + '</td>' + '<td>' + value.Mobile + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                        }
                        else {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td>' + value.cnic + '</td>' + '<td>' + value.Mobile + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                        }
                    }
                    else {
                        if (value.Recieved_ID != 0) {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="OPD" value="' + value.Parent_Transaction_Type_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.GroupCategory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + + '<td>' + value.cnic + '</td>' + '<td>' + value.Mobile + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                        }
                        else {

                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td>' + value.cnic + '</td>' + '<td>' + value.Mobile + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                        }
                    }
                });
                $("#tblPendingPatients").find('tr th:nth-child(7)').show();
                $("#tblPendingPatients").find('tr th:nth-child(8)').show();
                $('#tblPendingPatients tbody').html(rows);
                CountResult(SelectedDepartment);
            }, function (exec) { alert(exec.getmessage()); })

           
        }
        

        function getTests_WRT_Date() {
            debugger;
        

            var CheckAll = $('#chkTodayAll').prop('checked');
            var tbl = document.getElementById('tblPendingPatients');
            if (CheckAll == true) {
                var currentDate = '<%= DateTime.Now.Date.ToString(AppConfig.DateFormat) %>';

                for (var i = 1; i < tbl.rows.length; i++) {
                    if (tbl.rows[i].cells[0].innerText != currentDate) {
                        var row = tbl.rows[i];
                        row.style.display = 'none';
                    }
                    else {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }
                }
            }
            else {
                for (var i = 1; i < tbl.rows.length; i++) {
                    var row = tbl.rows[i];
                    row.style.display = '';
                }
            }
        }



        function ShowAllTestDateWise() {
            debugger;
           

            var SelectedDepartment = $('#main-departments').find('option:selected')[0].value;

            var SelectedDate = '<%= DateTime.Now.Date.ToString(AppConfig.DateFormat) %>';
            if (SelectedDepartment == "001") {
                PageMethods.PendingLabTestDateWise(SelectedDepartment, SelectedDate, function (data) {
                    var parsedData = JSON.parse(data);
                    var rows = '';
                    $.each(parsedData, function (key, value) {
                        debugger;
                        if (value.DoctorName == null || value.DoctorName == "0")
                            value.DoctorName = "";
                        if (value.Rotation == null)
                            value.Rotation = "";
                        if (value.Rotation == 0)
                            value.Rotation = "";
                        if (value.L_R_Rotation_ID == 0)
                            value.L_R_Rotation_ID = "";
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var retdate = moment(value.Created_Time).format('LLLL');
                        if (value.Lab_Test_Detail_ID == null) {
                            value.Recieved_ID == "0";
                            value.Lab_Test_Detail_ID = "0";
                        }
                        if (value.chkPackages == null)
                            value.chkPackages = "0";
                        var mydate = new Date(Date.parse(value.Date));
                        var retdate = mydate.toLocaleDateString();


                        if (value.Test_ID != 0) {
                            if (value.Recieved_ID != 0) {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                            }
                            else {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                            }
                        }
                        else {
                            if (value.Recieved_ID != 0) {
                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="OPD" value="' + value.Parent_Transaction_Type_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.GroupCategory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                            }
                            else {

                                rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden" name="txtMRNO" id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                            }
                        }
                    });
                    $('#tblPendingPatients tbody').html(rows);
                    $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                    $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
                    CountResult(SelectedDepartment);
                }, function (exec) { alert(exec.getmessage()); })

            }
            else {
                PageMethods.PendingTestDateWise(SelectedDepartment, SelectedDate, function (data) {
                    var parsedData = JSON.parse(data);
                    var rows = '';
                    $.each(parsedData, function (key, value) {
                        if (value.DoctorName == null || value.DoctorName == "0")
                            value.DoctorName = "";
                        if (value.Rotation == null)
                            value.Rotation = "";
                        if (value.Rotation == 0)
                            value.Rotation = "";
                        if (value.L_R_Rotation_ID == 0)
                            value.L_R_Rotation_ID = "";
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        if (value.chkPackages == null)
                            value.chkPackages = "0";

                        var mydate = new Date(Date.parse(value.Entry_Date));
                        var retdate = mydate.toLocaleDateString();
                        if (value.Recieved_ID != null) {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden"  id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '" /><input type="hidden" name="testCatID" value="0"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '" /> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '" />' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';

                        }
                        else {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden"  id="txtMRNO' + key + '" value="' + value.Bill_No + '"/>' + value.Bill_No + '</td>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"><input type="hidden" name="testCatID" value="0"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '">' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</input></td> ' + '<td>' + value.DoctorName + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                        }
                    });

                    $('#tblPendingPatients tbody').html(rows);
                    $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                    $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
                    CountResult(SelectedDepartment);
                }, function (exec) { alert(exec.getmessage()); })
            }
        }
        function CountResult(SelectedDepartment) {

            PageMethods.CountResult(SelectedDepartment, function (data) {
                $('#ctl00_MainContent_lblResultDpt').text(data);
            }, function (error) { })
        }
        function EnableRemarks(anchor) {

            var row = $(anchor).parents('tr')[0];
            var checkemr = $($(row).find('td input[name=Emergancy]')[0]).prop('checked');
            if (checkemr == true) {
                $($(row).find('td input[name=txtRemarks]')[0]).show();
            }
            else {
                $($(row).find('td input[name=txtRemarks]')[0]).hide();
                $($(row).find('td input[name=txtRemarks]')[0]).val("");
            }

        }
        var ChkPackeges = "null";

        function select3(anchor) {
            debugger;

            var row = $(anchor).parents('tr')[0];
            var RecievedID = $($(row).find('td input[name=RecievedID]')[0]).val();
            var Patient_ID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            
            var Bill_Details_ID = $($(row).find('td input[name=Bill_Details_ID]')[0]).val();

            var TransactionType = $($(row).find('td')[6]).text();
            var trnsid = $($(row).find('td input[name=OPD]')[0]).val();
            if (TransactionType != "0") {
                PageMethods.checkRepeat(RecievedID, function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        window.location = "LaboratoryTest.aspx?ID=" + value.Lab_Test_ID;
                        $('#ctl00_MainContent_saveLabTest').val("Update");



                    });
                }, function (error) { })
            }

            var SelectedDepartment = $('#main-departments').find('option:selected')[0].value;

            var OPD = $($(row).find('td')[0]).val();
           

            var chkPackages = $($(row).find('td input[name=chkPackages]')[0]).val();
            var Patient_ID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            var trnsid = $($(row).find('td input[name=OPD]')[0]).val();
            var Paymentcheck = $($(row).find('td input[name=Paymentcheck]')[0]).val();
            if (Paymentcheck != 'true') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Payment Not Done',
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
            var LTestid = $($(row).find('td input[name=Detail]')[0]).val();
            var LabTestID = $($(row).find('td input[name=LabTestID]')[0]).val();
            var PatID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            var type = $($(row).find('td')[6]).text();
            var Area = $($(row).find('td input[name=txtAreaofInterest]')[0]).val();
            var testCatID = $($(row).find('td input[name=testCatID]')[0]).val();

            var txtRotation = $($(row).find('td input[name=txtRotation]')[0]).val();
            var txtddlXRayLF_Name = $($(row).find('td input[name=txtddlXRayLF_Name]')[0]).val();
            var testID = $($(row).find('td')[3]).text();
            var name = $($(row).find('td')[4]).text();
            var existingID = $('#ctl00_MainContent_txtPatient_ID').val();
            var BillNo = $($(row).find('td input[name=txtMRNO]')[0]).val();
            var RetDate = $($(row).find('td input[name=RetDate]')[0]).val();
            var ComingID = PatID;
           
            if (existingID != "") {

                loadAjax();
                if (existingID != ComingID) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Test of Same Bill No',
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
            }

            if (existingID == "") {
                $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
                var tokenData = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + PatID);
                var parsedData = JSON.parse(tokenData);
                $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
            }

            var test_array = $('#tbltestDetail').find('input[name=billNum][value="' + BillNo + '"]');
            var table_Length = $("#tbltestDetail td").length;
            if (table_Length == 0) {

            }
            else {

                if (test_array.length == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Test of Same Bill',
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
            }

            var userName = '<%= AppConfig.UserName %>';
            var date = '<%= DateTime.Now %>';
            var datetime = '<%= DateTime.Now.Date.ToString(AppConfig.DateFormat) %>';
            if (testCatID != "0" && testID == "0") {
                var rowid = '';
                var df = tbltest.rows.length + 1;
                if (Paymentcheck == 'true') {

                    rowid += '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="' + LTestid + '"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="' + LabTestID + '"/><input type="hidden" name="billNum" value="' + BillNo + '"/>' + RetDate + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="0"> <input type="hidden" name="txtddlXRayLF_Name" value="0">' + name + '</td><td><input type="hidden" name="txtArea" value=""  /></td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment" ' + (Paymentcheck ? 'checked' : '') + '  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" name="txtCollectionDate" disabled="disabled" style="width:167px !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:167px  !important;" /></td><td> <input type="text"  id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td><input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" onclick="EnableRemarks(this)" name="Emergancy"  style="width: 92px;height: 17px;"></input></td><td><input  type="text" name="txtRemarks" style="width: 138px !important;"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                    $('#tbltestDetail').append(rowid);
                    var s = $(anchor);
                    $(s).closest('tr').remove();



                }
                else {

                    rowid += '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="' + LabTestID + '"/><input type="hidden" name="billNum" value="' + BillNo + '"/>' + RetDate + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="0"> <input type="hidden" name="txtddlXRayLF_Name" value="0">' + name + '</td><td><input type="hidden" name="txtArea" value="" /></td><td><input type="checkbox" disabled name="payment" id="Payment' + df + '"  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" disabled="disabled"  name="txtCollectionDate" style="width:167px !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:167px !important;" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 138px !important;"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    $('#tbltest').append(rowid);
                    var s = $(anchor);
                    $(s).closest('tr').remove();
                }
                

                $('#txtReadyBy' + df).datetimepicker({ format: 'm-d-y h:i:s A' });
              
                $('#txtCollectionDate' + df).datepicker();
                $('#txtReadyBy' + df).val(date);
                $('#txtCollectionDate' + df).val(date);

            }
            else {



                if (Paymentcheck == "true") {
                    var df = tbltest.rows.length + 1;

                    var row = '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="0"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="0"/><input type="hidden" name="billNum" value="' + BillNo + '"/>' + RetDate + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="' + txtRotation + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + txtddlXRayLF_Name + '">' + name + '</td><td><input type="hidden" name="txtArea" value="' + Area + '" />' + Area + '</td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment" ' + (Paymentcheck ? 'checked' : '') + ' style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" disabled="disabled"  id="txtCollectionDate' + df + '" name="txtCollectionDate" style="width:161px !important;margin-left:-7px" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:158px !important;margin-left:-6px" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:96px !important;margin-left:-6px"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:96px !important;margin-left:-6px" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 125px !important;"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    $('#tbltestDetail').append(row);
                    var s = $(anchor);
                    $(s).closest('tr').remove();

                }
                else {
                    var df = tbltest.rows.length + 1;

                    var row = '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="0"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="0"/><input type="hidden" name="billNum" value="' + BillNo + '"/>' + RetDate + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="' + txtRotation + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + txtddlXRayLF_Name + '">' + name + '</td><td><input type="hidden" name="txtArea" value="' + Area + '" />' + Area + '</td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment"  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" disabled="disabled"  name="txtCollectionDate" style="width:167px !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:167px !important;" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 138px !important;display:none"></input></td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    $('#tbltestDetail').append(row);
                    debugger;
                    var s = $(anchor);
                    $(s).closest('tr').remove();
                }

                $('#txtReadyBy' + df).datetimepicker({ format: 'm-d-y h:i:s A' });
                $('#txtCollectionDate' + df).datepicker();
                $('#txtReadyBy' + df).val(date);
                $('#txtCollectionDate' + df).val(date);
            }
            LoadTestsHistory();
            $('#ctl00_MainContent_saveLabTest').val("Save");
            $('#ctl00_MainContent_txtLab_Test_ID').val("(New)");
        }

        function checkPackeges(TransactionType, Patient_ID, trnsid) {

            PageMethods.checkPackeges(TransactionType, Patient_ID, trnsid, function (data) {

                ChkPackeges = data;


            }, function (error) { })
        }
        function BackToList() {
            window.location = "LaboratoryTestView.aspx";
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div id="PatientDetail" style="width: 100%">
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="chkCustomer" EventName="CheckedChanged" />
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
                            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Lab2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image">
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-7 col-sm-6">
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                 <asp:Label ID="Label3" runat="server" Text="MR No :*"></asp:Label>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblPatient_Name" runat="server" Text="Name :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
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
                                <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
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
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label>Search From Bill No:</label>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-6">
                                      <input id="txtMRNOSearch" type="text"></input>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                         <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-6">
                                         <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-5 col-md-5 col-sm-6 detail">
                                        <asp:Label ID="LblPatient_Category" runat="server" Text="Category :"></asp:Label>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-6 detail">
                                         <asp:Label ID="vPatient_Category" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-5 col-md-5 col-sm-6 detail">
                                        <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-6 detail">
                                        <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-5 col-md-5 col-sm-6 detail">
                                        <asp:Label ID="Label1" runat="server" Text="No of Result:"></asp:Label>
                                    </div>
                                    <div class="col-lg-4 col-md-5 col-sm-6">
                                       <asp:Label ID="lblResultDpt" style="display:none;" runat="server"></asp:Label>
                                    </div>
                                </div>
                            </div>
                            </div>
                        </div>
                    </div>
                  <div class="row" style="margin-bottom: 15px">
      <div class="col-lg-2 col-md-3 col-sm-3">
          <select id="ddlmaindepartment" onchange="LoadVitalParameters();"></select>
      </div>
  </div>
  <div class="main-row ">
      <div class="row vitalsTable" id="opdvitals" style="margin-left: -2px;">

          <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
              <h4 style="height: 30px; background-color: #f0f1f3; width: 125px; padding: 5px 12px; border-radius: 8px; margin: 0;">Latest Vitals
              </h4>
 
          </div>
          <table class="MyTable " id="tblVitalParametersHistory">

              <thead style="height: 35px;">
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
                      <th>Respiration</th>
                      <th>Weight</th>
                  </tr>
              </thead>
              <tbody>
              </tbody>
          </table>


      </div>
      <div class="roww vitalsTable" id="ipdvitals" style="margin-left: -2px;">
          <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
              <h4 style="height: 30px; background-color: #f0f1f3; width: 125px; padding: 5px 12px; border-radius: 8px; margin: 0;">Latest Vitals
              </h4>
 
          </div>
          <table class="MyTable" id="tblVitalParametersHistoryIPD">
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
      <div class="roww vitalsTable" id="emergencyVital" style="margin-left: -2px;">
          <div style="display: flex; align-items: center; justify-content: space-between; width: 100%;">
              <h4 style="height: 30px; background-color: #f0f1f3; width: 125px; padding: 5px 12px; border-radius: 8px; margin: 0;">Latest Vitals
              </h4>
 
          </div>
          <table class="MyTable" id="tblVitalParametersHistoryEmergency">
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
                
                <form id="item">
                    <div class="row">
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <asp:Label ID="Label2" runat="server" Text="Lab Test ID :"></asp:Label>
                            <asp:TextBox ID="txtLab_Test_ID" runat="server" ReadOnly="True"></asp:TextBox>
                        </div>
                        <div class="col-lg-2 col-md-3 col-sm-4">
                            <label>Search By Date:</label>
                            <select id="main-departments" onchange="TestDetail()"></select>
                        </div>
                        <div class="col-lg-1 col-md-3 col-sm-4" style="margin-top:1%">
                            <label>For Today:</label>
                            </div>
                        <div class="col-lg-1 col-md-3 col-sm-4" style="margin-top:1%">
                            <input type="checkbox" id="chkTodayAll" onchange="getTests_WRT_Date()" />
                        </div>
                    </div>
                        
                     </form>
               
                <table>
                    <tr>
                        <td>
                            <table>
                                <tr>
                                    <td style="width: 111px;"></td>
                                    <td></td>
                                    <td>
                                        <asp:CheckBox Text="(Walk-in Customer)" ID="chkCustomer" runat="server" onclick="" OnCheckedChanged="chkCustomer_CheckedChanged" AutoPostBack="true" Style="display: none" />
                                        <asp:RequiredFieldValidator ID="rfvPatient_ID" runat="server" ControlToValidate="txtPatient_ID" ErrorMessage="Select Patient ID" Text="*"></asp:RequiredFieldValidator>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                

                                <div class="row">
                    <div class="col-12">
                        <div class="table-responsive">
                            <table class="table" >
                                <tr>
                                    <td class="lab-head" >
                                        <h1 class="headingcolor">Test Calling List</h1>
                                    </td>
                                </tr>
                                <tr>
                                    <a href="#" id="testViewDetails">Enlarge</a>
                                </tr>
                                <tr>
                                    <td>
                                        <div id="dvtblSymtomps" class="table-responsive" style="height: 207px; overflow-y: auto; overflow-x: auto;">
                                            <table class="table" id="tblPendingPatients">
                                                <thead>
                                                    <tr>
                                                        <th>Bill Date</th>
                                                        <th>Bill No</th>
                                                        <th>Name</th>
                                                        <th>Test Name</th>
                                                        <th>Remarks</th>
                                                        <th>Dpt</th>
                                                        <th>CNIC</th>
                                                        <th>Mobile</th>
                                                        <th>Action</th>
                                                    </tr>
                                                </thead>
                                                <tbody></tbody>
                                            </table>
                                        </div>
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </div>
                   <div class="row">
                       <div class="col-12">
                           <div class="table-responsive" style="margin-top: 20px;overflow-y:scroll;height:180px;">
                               <table id="tbltestDetail" class="table table-bordered table-striped">
                                   <thead>
                                       <tr>
                                           <th>Bill Date</th>
                                           <th>Test Name</th>
                                           <th>Area Of Interest</th>
                                           <th>Payment</th>
                                           <th>Test Collected On</th>
                                           <th>Test Ready On</th>
                                           <th>Test Collected By</th>
                                           <th>Performed By</th>
                                           <th>Urgent</th>
                                           <th>Remarks</th>
                                           <th>Action</th>
                                       </tr>
                                   </thead>
                                   <tbody id="tbltest"></tbody>
                               </table>
                           </div>
                       </div>
                   </div>
                <div class="row">
                      <div class="table-responsive" style="width: 100%; overflow: scroll; height: 300px;">
                
                               <table class="table" id="tblHistoryTests">
                                    <thead>
                                        <tr>
                                            <td colspan="12">
                                                <div id="HeaderTests">
                                                    <h2 class="headingcolor">Previous History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Test Collected Date</th>
                                            <th>Test Ready Date</th>
                                            <th>Bill No</th>
                                            <th>Mr NO</th>
                                            <th style="width: 563px">Test Name</th>
                                            <th>Test Collected By</th>
                                            <th>Result</th>
                                        </tr>
                                    </thead>
                                    <tbody id="testbody">
                                    </tbody>
                                </table>

                    </div>
                </div>
                 
                   <div class="row">
                       <div class="col-12">
                           <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                           <asp:HiddenField ID="hdfPatient_No" runat="server" ClientIDMode="Static" />
                       </div>
                   </div>
                   <div class="row">
                       <div class="col-12">
                           <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                               ShowSummary="true" DisplayMode="List" />
                       </div>
                   </div>
                   <div class="row">
                       <div class="col-12">
                           <asp:Label ID="lblMessage" Text="" runat="server" />
                       </div>
                   </div>
            



                <div class="col-lg-8" style="margin-top:1%">
                    <div class="row">
                <div class="col-lg-2 col-md-3 col-sm-4">
                   <asp:Button ID="saveLabTest" runat="server" value="Save" class="btn btn-primry"  Text="Save" OnClientClick="this.disabled = true;" UseSubmitBehavior="false" TabIndex="20"/>                  
                    </div>
                
                <div class="col-lg-2 col-md-3 col-sm-4">
                <input type="button" class="btn btn-yellow"  value="New" id="btnNew" onclick="New()" />
                    </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                <input type="button" id="btnBackList" class="btn-gray" value="View " onclick="BackToList()" style="margin-left:10px" />
                    </div>
             <div class="col-lg-2 col-md-3 col-sm-4">
                <input type="button" value="Reported Slip" class="btn btn-primry" id="print-slip" />                           
                    </div>
                    </div>
                    </div>
                <div id="myModal" class="modal fade" role="dialog">
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
                                             <div id="dvPreview" style="white-space: nowrap; overflow-x: visible; overflow-y: hidden; width: 260px;"></div>
                                                        </td>
                                                    </tr>
                                                </table>
                                                <input type="button" class="btn btn-primry" id="Button1" value="View Print Report"  onclick  ="ShowReport()" />
                                                <input type="hidden" id="Hidden1" />
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    <div id="MedicationModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 412px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Test</h4>
                </div>
                <div style="margin-top: 2px; margin-left: 57px;" id="lab">
                    <h2>Lab Tests : </h2>
                </div>
                <div style="margin-top: -48px; margin-left: 433px;" id="radtest4">
                    <h2>Radiology Tests : </h2>
                </div>
                <table style="margin-left: 218px; width: 43px;">
                    <tr>
                        <td id="labtest">
                            <select id="ddlLabTest">
                                <option value="">Select Department</option>
                            </select>
                        </td>
                        <td id="labtest1">
                            <input type="button" value="Add Test" id="add-new-testDirect" />
                        </td>
                        <td id="radtest1">
                            <button type="button" id="btnultrasound" class="btn btn-info" onclick="FillTestsByCategory('002')">UltraSound</button>
                            <button type="button" id="btnXray" class="btn btn-info" value="X-Ray" onclick="FillTestsByCategory('003')">X-Ray</button>
                            <button type="button" id="btnCTscan" value="CT Scan" class="btn btn-info" onclick="FillTestsByCategory('004')">CT Scan</button>
                        </td>
                        <td id="radtest2">
                            <select id="groupsCat" style="width: 175px !IMPORTANT;">
                            </select>
                            <div id="divRotation">
                                <select id="ddlRotation" style="display: none;">
                                </select>
                            </div>
                            <div id="divX_Ray">
                                <select id="ddlXRayLF" style="display: none; width: 73px !important; margin-left: 101px; margin-top: -28px; height: 28px;">
                                    <option value="0"></option>
                                    <option value="L">Left</option>
                                    <option value="R">Right</option>
                                </select>
                            </div>
                        </td>
                        <td id="radtest3">
                            <input type="button" value="Add Test" id="add-new-testList" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <h2>Special Test </h2>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:TextBox ID="txtSpecialTests" runat="server" TextMode="MultiLine"></asp:TextBox>
                        </td>
                        <td></td>
                        <td>
                            <label style="width: 100px;">Area Of Interest</label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtAreaOfInterest" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
        <center>
    <div id="TestViewDetail" class="modal fade" style="height:auto;overflow:hidden!important;margin:30px;padding-right:0px !important">
        <div>
            
             <div class="modal-content">
                  <div class="panel-heading">
                     <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h3>Test View</h3>
                 </div>
               <div>
                 <table class="table" style=" table-layout: fixed;" id="tstHeaderModal">
                     <thead>
                         <tr>
                             <th>Date</th>
                             <th>MR No</th>
                             <th>Name</th>
                             <th>Test Name</th>
                             <th>Doctor Name</th>
                             <th>Dpt</th>
                             <th>Action</th>
                         </tr>
                     </thead>
                     <tbody>
                       
                     </tbody>
                 </table>
                 </div>
                   <div style="max-height:500px;overflow:auto;margin-top: -15px">
          <table id="tstDetailModal" class="table" style="table-layout: fixed;">             
              <tbody></tbody>            
          </table>
        </div>

             </div>
    </div>
        </div>
</center>
</asp:Content>


