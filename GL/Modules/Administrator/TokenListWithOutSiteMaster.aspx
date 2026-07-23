
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="TokenListWithOutSiteMaster.aspx.cs" Inherits="PMS.TokenListWithOutSiteMaster" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="../../wwwroot/Select2/select2.min.css" rel="stylesheet" />
    <link href="../../wwwroot/CustomCSS/toggle.css" rel="stylesheet" />
</head>
<body>

    <div class="container my-5">
        <!-- Toggle Buttons -->
        <div class="d-flex justify-content-end toggle-btns mb-4">
            <button id="clinicBtn" class="btn btn-light active">Department</button>
            <button id="doctorBtn" class="btn btn-light">Doctor</button>
        </div>
        <!-- Clinic Table -->
        <div id="clinicTable">
            <div class="row">
                <div class="col-lg-4 col-md-4 col-sm-4">
                    <label>Patient Category</label>
                    <select id="ddlPatientType" onchange="GetLatestToken();" class="widths"></select>
                </div>
                <div class="col-lg-4 col-md-4 col-sm-4">
                    <label>Department</label>
                    <select id="ddldepartment" onchange="GetLatestToken();" class="widths"></select>
                </div>

            </div>
            <h3 class="text-danger">Department Wise Patients</h3>
            <table id="tblgnrltoken" class="table table-bordered table-striped">
                <thead class="table-danger">
                    <tr>
                        <th>Token Number</th>
                        <th>MR Number</th>
                        <th>Patient Name</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
        <!-- Doctor Table (Initially Hidden) -->
        <div id="doctorTable" style="display: none;">
             <div class="row">
                <div class="col-lg-4 col-md-4 col-sm-4">
                    <select id="ddldoctor" onchange="GetLatest_doc_Token()" class="widths"></select>
                </div>

            </div>
            <h3 class="text-danger">Doctor's Patients</h3>
            <table id="tblprivatepatient" class="table table-bordered table-striped">
                <thead class="table-danger">
                    <tr>
                        <th>Token Number</th>
                        <th>MR Number</th>
                        <th>Patient Name</th>
                        <th>Doctor Name</th>
                    </tr>
                </thead>
                <tbody id="ibody_pvt">
                </tbody>
            </table>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="../../wwwroot/Select2/select2.min.js"></script>
    <script>
        $(document).ready(function () {
            FillPatientType();
            FillDepartment();
            filldoctor();
            GetLatestToken();
            GetLatest_doc_Token();
            
            $('#clinicBtn').click(function () {
                $('#doctorTable').hide();
                $('#clinicTable').show();
                $(this).addClass('active');
                $('#doctorBtn').removeClass('active');
            });

            $('#doctorBtn').click(function () {
                $('#clinicTable').hide();
                $('#doctorTable').show();
                $(this).addClass('active');
                $('#clinicBtn').removeClass('active');
            });
        });
        function filldoctor() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'TokenList.aspx/GetDoctor',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });
                    $('#ddldoctor').html(options);
                    $('#ddldoctor').select2();


                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function FillPatientType() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'TokenList.aspx/PatientType',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlPatientType').html(options);
                    $('#ddlPatientType').select2();

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function FillDepartment() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'TokenList.aspx/GetDepartment',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddldepartment').html(options);
                    $('#ddldepartment').select2();

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }
        function GetLatestToken() {
            debugger;
            var patientType = $('#ddlPatientType').val();
            var department = $('#ddldepartment').val();
            if (patientType == null) {
                patientType = 0;
            }
            if (department == null) {
                department = 0;
            }
            $.ajax({
                url: 'TokenList.aspx/LoadTokenPatientFilter',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ patientType: patientType, department: department }),
                success: function (_data) {
                    debugger;
                    _data = JSON.parse(_data.d);
                    var mdTable = $('#tblgnrltoken');
                    $('#tbl tr:gt(0)').remove();
                    table = $('#ibody');
                    var rows = '';
                    table.empty();
                    debugger;
                    $.each(_data, function (key, value) {
                        bill_id = value.Bill_ID;
                        debugger;

                        $("#ibody").append('<tr style=""><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.tokenNo + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.mr_no_sequence + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Full_Name + '</td></tr>');
                        length++;

                        return true;
                    });

                },
                error: function () {
                    alert("Get Error");
                }
            });
        }

        setInterval(function () {
            location.reload();
        }, 180000);
    function GetLatest_doc_Token() {
            var doc_Id = $('#ddldoctor').val();
            $.ajax({
                url: 'TokenList.aspx/LoadDocTokenPatientFitler',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({ doc_Id: doc_Id }),
                success: function (_data) {
                    debugger;
                    _data = JSON.parse(_data.d);
                    var mdTable = $('#tblprivatepatient');
                    $('#tbl tr:gt(0)').remove();
                    table = $('#ibody_pvt');
                    var rows = '';
                    table.empty();
                    debugger;
                    var isFirstRowAppended = false;

                    $.each(_data, function (key, value) {
                        $("#ibody_pvt").append('<tr style=""><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Doc_Token + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.mr_no_sequence + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Full_Name + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.doc_name + '</td></tr>');
                        length++;

                        return true;
                    });
                },
                error: function () {
                    alert("Get Error");
                }
            });
        }

        setInterval(function () {
            location.reload();
        }, 180000);
    </script>

</body>

</html>
