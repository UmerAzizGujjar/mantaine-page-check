<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MainDashboard.aspx.cs" Inherits="PMS.MainDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous" />
 
      <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/Scripts/jquery.tokeninput.js") %>"></script>
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/Styles/jquery.datetimepicker.css") %>" />
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script src="Scripts/jquery.ptTimeSelect.js" type="text/javascript"></script>
    <link href="css/report.css" rel="stylesheet" />
    <script src="<%=Page.ResolveUrl("~/Scripts/jquery.datetimepicker.js") %>" type="text/javascript"></script>
       <link href="CssJs/select2.min.css" rel="stylesheet" />
    <script src="CssJs/select2.min.js"></script>

    <style type="text/css">
        span {
            font-size: 13px;
        }

        .card {
            background-color: #fff;
            border-radius: 10px;
            border: none;
            position: relative;
            margin-bottom: 30px;
            box-shadow: 0 0.46875rem 2.1875rem rgba(90,97,105,0.1), 0 0.9375rem 1.40625rem rgba(90,97,105,0.1), 0 0.25rem 0.53125rem rgba(90,97,105,0.12), 0 0.125rem 0.1875rem rgba(90,97,105,0.1);
        }

        .l-bg-cherry {
            background: linear-gradient(to right, #493240, #ae9ba6) !important;
            color: #fff;
        }

        .l-bg-lun {
            background: linear-gradient(to right, #2da77c, #a1c7c0) !important;
            color: #fff;
        }

        .l-bg-ten {
            background: linear-gradient(to right, #373b44, #43cddd) !important;
            color: #fff;
        }

        .l-bg-room {
            background: linear-gradient(to right, #373b44, rgb(0 0 0 / 44%));
            color: #fff;
        }

        .l-bg-blue-dark {
            background: linear-gradient(to right, #373b44, #4286f4) !important;
            color: #fff;
        }

        .l-bg-green-dark {
            background: linear-gradient(to right, #3d1919, #d83240) !important;
            color: #fff;
        }

        .l-bg-orange-dark {
            background: linear-gradient(to right, #61513d, #439cfff2) !important;
            color: #fff;
        }

        .l-bg-yellow {
            background: linear-gradient(to right, #ec3131, #e6711d) !important;
            color: #fff;
        }

        .l-bg-purple {
            background: linear-gradient(to right, #493240, #4bb97b) !important;
            color: #fff;
        }

        .card .card-statistic-3 .card-icon-large .fas, .card .card-statistic-3 .card-icon-large .far, .card .card-statistic-3 .card-icon-large .fab, .card .card-statistic-3 .card-icon-large .fal {
            font-size: 110px;
        }

        .card .card-statistic-3 .card-icon {
            text-align: center;
            line-height: 50px;
            margin-left: 15px;
            color: #000;
            position: absolute;
            right: -5px;
            top: 20px;
            opacity: 0.1;
        }

        .l-bg-cyan {
            background: linear-gradient(135deg, #289cf5, #84c0ec) !important;
            color: #fff;
        }

        .l-bg-green {
            background: linear-gradient(135deg, #23bdb8 0%, #43e794 100%) !important;
            color: #fff;
        }

        .l-bg-orange {
            background: linear-gradient(to right, #f9900e, #ffba56) !important;
            color: #fff;
        }

        .l-bg-cyan {
            background: linear-gradient(135deg, #289cf5, #84c0ec) !important;
            color: #fff;
        }

        .progress-bar {
            display: none;
        }

        .progress {
            display: none;
        }
        h2{
            color:white !important;
        }
         h3{
            color:white !important;
        }
    </style>


    <script type="text/javascript">


        $(document).ready(function () {
            LoadDashboard();
         
        });
        debugger;
        function LoadDashboard() {
            debugger;
            async: false;
            $.ajax({
                async: false,
                type: "POST",
                url: "MainDashboard.aspx/ViewList",
                data: JSON.stringify({

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (data) {
                    debugger;

                    var data = JSON.parse(data.d);

                    debugger;
                    for (var i = 0; i < data.length; i++) {
                        var department = data[i].D_type;

                        if (department == "Blood Bank") {
                            // $('#Dpt11').text(department);
                            $('#BloodBankTotal').text(data[i].Total_patient_Count);
                            // $('#BBshare').text(data[i].Hospital_Share);

                        }

                        if (department == "CT_Scan") {
                            //$('#Dpt5').text(department);
                            $('#CT_Scan_Total').text(data[i].Total_patient_Count);
                            /*$('#DialShare').text(data[i].Hospital_Share);*/

                        }

                        if (department == "Ultra Sound") {
                          
                            $('#ultraTotal').text(data[i].Total_patient_Count);
                          
                        }
                        if (department == "Ultra Checked") {
                          
                            $('#ultrachecked').text(data[i].Total_patient_Count);
                          
                        }
                        if (department == "Ultra Pending") {
                          
                            $('#ultrapending').text(data[i].Total_patient_Count);
                          
                        }

                        if (department == "X-Ray") {
                            $('#X-RayTotal').text(data[i].Total_patient_Count);
                        }
                        if (department == "XRayChecked") {
                            $('#xraychecked').text(data[i].Total_patient_Count);
                        }
                        if (department == "XrayPending") {
                            $('#xraypending').text(data[i].Total_patient_Count);
                        }

                        if (department == "Lab checked") {

                            $('#LabChecked').text(data[i].Total_patient_Count);
                        }
                        if (department == "Lab Total") {
                            $('#LabTotal').text(data[i].Total_patient_Count);





                        }

                        if (department == "Lab Pending") {
                            $('#labpending').text(data[i].Total_patient_Count);





                        }
                        if (department == "Short Stay") {
                            // $('#Dpt10').text(department);
                            $('#ShortStay').text(data[i].Total_patient_Count);
                            /* $('#labshare').text(data[i].Hospital_Share);*/
                        }

                        if (department == "Emergency Total") {
                            // $('#Dpt6').text(department);

                            $('#Emergency_total').text(data[i].Total_patient_Count);
                            /*$('#labourshare').text(data[i].Hospital_Share);*/

                        }

                        if (department == "Private Pending") {
                            // $('#Dpt14').text(department);
                            $('#tot_pending').text(data[i].Total_patient_Count);
                            /*  $('#MisShare').text(data[i].Hospital_Share);*/

                        }

                        if (department == "Private Checked") {
                            // $('#Dpt8').text(department);
                            $('#tot_checked').text(data[i].Total_patient_Count);
                            /*$('#NIcushare').text(data[i].Hospital_Share);*/
                        }


                        if (department == "Private Today") {
                            // $('#Dpt').text(department);
                            $('#total_prvt').text(data[i].Total_patient_Count);
                            /*$('#Opdpat').text(data[i].TotalPatient);*/
                        }


                        if (department == "OPD Pending") {

                            $('#total_Pending').text(data[i].Total_patient_Count);

                        }
                        if (department == "OPD Checked") {

                            $('#total_checked').text(data[i].Total_patient_Count);

                        }


                        if (department == "OPD Total") {
                            // $('#Dpt9').text(department);
                            $('#total_opd').text(data[i].Total_patient_Count);

                        }




                    }

                }
            });
        }
        function fillPendingPrivatePatientsList() {
            $('#general').hide();
            $('#private').show();
            $('#lab').hide();
            $('#ultra').hide();
            $('#xray').hide();
            $('#chck_filter').hide();
            $('#chck_pvt').hide();
            PageMethods.PendingPrivatePatients(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                    // Ensure value.Waiting_Time is properly handled
                  
                    var rowColorStyle = 'style="  background: linear-gradient(to right, #2da77c, #a1c7c0) !important;color: #fff;"';
               
                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Waiting_Time + '</td></tr>';
                });

                $('#tblPendingPrivatePatients tbody').html(rows);

            }, function (exec) { });
        }
        function fillPendingPatientsList() {
            $('#general').show();
            $('#private').hide();
            $('#lab').hide();
            $('#xray').hide();
            $('#ultra').hide();
            $('#chck_filter').hide();
            $('#chck_pvt').hide();

            PageMethods.PendingPatients(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                
                   
                    var rowColorStyle = 'style="background: linear-gradient(to right, #493240, #ae9ba6) !important;color: #fff;"';
                 
                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Waiting_Time + '</td></tr>';
                });

                $('#tblPendingPatients tbody').html(rows);

            }, function (exec) { });
        }
        function fillPendinglabList() {
            $('#general').hide();
            $('#private').hide();
            $('#lab').show();
            $('#ultra').hide();
            $('#xray').hide();
            $('#chck_filter').hide();
            $('#chck_pvt').hide();
            PageMethods.PendingLabPatients(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                  
                 
                  
                    var rowColorStyle = 'style="background: linear-gradient(to right, #61513d, #439cfff2) !important;color: #fff;"'
                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Waiting_Time + '</td></tr>';
                });

                $('#tblpendinglab tbody').html(rows);

            }, function (exec) { });
        }
        function fillPendingultralist() {
            $('#general').hide();
            $('#private').hide();
            $('#lab').hide();
            $('#ultra').show();
            $('#xray').hide();
            $('#chck_filter').hide();
            $('#chck_pvt').hide();
            PageMethods.PendingUltraPatients(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                  
                 
                  
                    var rowColorStyle ='style="background: linear-gradient(to right, #493240, #4bb97b) !important;color:#fff;"';
                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Waiting_Time + '</td></tr>';
                });

                $('#tblpendingultra tbody').html(rows);

            }, function (exec) { });
        }
        function fillPendingxraylist() {
            $('#general').hide();
            $('#private').hide();
            $('#lab').hide();
            $('#ultra').hide();
            $('#xray').show();
            $('#chck_filter').hide();
            $('#chck_pvt').hide();
            PageMethods.PendingXrayPatients(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                  
                 
                  
                    var rowColorStyle = 'style="background: linear-gradient(to right, #373b44, #65758e) !important; color: #fff;"';

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Waiting_Time + '</td></tr>';
                });

                $('#tblpendingxray tbody').html(rows);

            }, function (exec) { });
        }
        function fillcheckedpatient() {
            $('#general').hide();
            $('#private').hide();
            $('#lab').hide();
            $('#ultra').hide();
            $('#xray').hide();
            $('#chck_filter').show();
            $('#chck_pvt').hide();

            PageMethods.CheckedFilterPatient(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {



                    var rowColorStyle = 'style="background: linear-gradient(to right, #493240, #ae9ba6) !important;color: #fff;"';

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Consumed_Time + '</td></tr>';
                });

                $('#tblcheckedpatient tbody').html(rows);

            }, function (exec) { });
        }
        function CheckPrivate() {
            $('#general').hide();
            $('#private').hide();
            $('#lab').hide();
            $('#ultra').hide();
            $('#xray').hide();
            $('#chck_filter').hide();
            $('#chck_pvt').show();

            PageMethods.checkedPvtPatient(function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {


                    var rowColorStyle = 'style="  background: linear-gradient(to right, #2da77c, #a1c7c0) !important;color: #fff;"';

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.mr_no_sequence + '</td> <td> ' + value.Full_Name + ' </td>' + '<td>' + value.Consumed_Time + '</td></tr>';
                });

                $('#tblcheckedpvt tbody').html(rows);

            }, function (exec) { });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row" style="justify-content: center;">
        <h1 class="card-title mb-0 font-weight-bold ml-5 p-3">Main Dashboard</h1>
    </div>
    <hr />
    <br />

    <div class="container-fluid">
        <div class="col-md-12">
            <div class="row">
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-cherry" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-user" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Filter Clinic Wise</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Patients
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_opd"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="fillPendingPatientsList()">Pending</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_Pending"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">  <a style="text-decoration: none; cursor: pointer;" onclick="fillcheckedpatient()">Checked</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_checked"></span>
                                </div>

                            </div>
                            <div class="progress mt-5" data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-lun" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-bed" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Doctor Wise</h3>
                            </div>
                         
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Patient
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_prvt"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="fillPendingPrivatePatientsList();">Pending</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="tot_pending"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a  style="text-decoration: none; cursor: pointer;" onclick="CheckPrivate()" >Checked</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="tot_checked"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-blue-dark" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-bed" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">IPD</h3>
                            </div>
               
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Patient
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_prvts"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Pending
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="tot_pendings"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Checked
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="tot_checkeds"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-green-dark" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-ambulance" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Emergency</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Total Patients
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="Emergency_total"></span>
                                </div>

                            </div>

                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">Short Stay
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="ShortStay"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>
            <div class="row">
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-orange-dark" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">
                            <div class="card-icon card-icon-large"><i class="fas fa-flask" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Lab</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Total Patients
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="LabTotal"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Checked
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="LabChecked"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <a style="text-decoration: none; cursor: pointer;" onclick="fillPendinglabList();"><h2 class="d-flex align-items-center mb-0">Pending
                                    </h2></a>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="labpending"></span>
                                </div>
                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-yellow" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">
                            <div class="card-icon card-icon-large"><i class="fas fa-tint" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Blood Bank</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Total Patients
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="BloodBankTotal"></span>
                                </div>
                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>

                </div>
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-purple" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-desktop-alt" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">UltraSound</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Total Patients
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="ultraTotal"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Checked
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="ultrachecked"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <a style="text-decoration: none; cursor: pointer;" onclick="fillPendingultralist();"><h2 class="d-flex align-items-center mb-0">Pending
                                    </h2></a>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="ultrapending"></span>
                                </div>
                            </div>

                            <%-- <div class="mb-4">
                        <h3 class="card-title mb-0">IPD</h3>
                    </div>--%>


                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-room" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">
                            <div class="card-icon card-icon-large"><i class="fas fa-x-ray" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">X-Ray</h3>
                            </div>
                           <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Total Patients
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="X-RayTotal"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h2 class="d-flex align-items-center mb-0">Checked
                                    </h2>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="xraychecked"></span>
                                </div>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <a style="text-decoration: none; cursor: pointer;" onclick="fillPendingxraylist();"><h2 class="d-flex align-items-center mb-0">Pending
                                    </h2></a>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="xraypending"></span>
                                </div>
                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>


            </div>
        </div>
        <br />
        <div class="row" id="general" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblPendingPatients" style="overflow: scroll;">
                    <thead id="ihead">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Waiting Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>

        </div> 
        <div class="row"  id="private" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblPendingPrivatePatients" style="overflow: scroll;">
                    <thead id="iheads">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Waiting Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibodys">
                    </tbody>
                </table>
            </div>

        </div> 
        <div class="row"  id="lab" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblpendinglab" style="overflow: scroll;">
                    <thead id="ihead_lab">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Waiting Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody_lab">
                    </tbody>
                </table>
            </div>

        </div> 
        <div class="row"  id="ultra" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblpendingultra" style="overflow: scroll;">
                    <thead id="ihead_ultra">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Waiting Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody_ultra">
                    </tbody>
                </table>
            </div>

        </div> 
        <div class="row"  id="xray" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblpendingxray" style="overflow: scroll;">
                    <thead id="ihead_xray">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Waiting Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody_xray">
                    </tbody>
                </table>
            </div>

        </div>
        <div class="row"  id="chck_filter" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblcheckedpatient" style="overflow: scroll;">
                    <thead id="ihead_chckd">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Consumed Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody_chck">
                    </tbody>
                </table>
            </div>

        </div> 
        <div class="row"  id="chck_pvt" style="display:none;">
            <div class="col-md-12 col-lg-12">
                <table class="table table-bordered" id="tblcheckedpvt" style="overflow: scroll;">
                    <thead id="ihead_pvtchck">
                        <tr>
                            <th>MrNo</th>
                            <th>Patient Name</th>
                            <th>Consumed Time</th>
                        </tr>
                    </thead>
                    <tbody id="ibody_pvt_chck">
                    </tbody>
                </table>
            </div>

        </div>
</asp:Content>
