<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MainDashboard.aspx.cs" Inherits="PMS.MainDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous" />
    <link href="../../wwwroot/Pakred/css/MainDashboard.min.css" rel="stylesheet" />


  <style type="text/css">

      .completecard{
          height: 160px; width: 71%;
          border-radius: 10px; 
          overflow: hidden;
      }

      .headercolor {
          background-color: #EFA63E !important;
          height:45px !important;
      }

      .iconcolor{
          font-size: 33px !important; 
          color: white !important;
      }

    span {
        font-size: 13px;
    }
    
    .card {
        background-color: #fff;
        border-radius: 10px;
        position: relative;
        margin-bottom: 30px;
        box-shadow: 0 0.46875rem 2.1875rem rgba(90,97,105,0.1), 
                    0 0.9375rem 1.40625rem rgba(90,97,105,0.1), 
                    0 0.25rem 0.53125rem rgba(90,97,105,0.12), 
                    0 0.125rem 0.1875rem rgba(90,97,105,0.1);
    }
    
    .card-outline-yellow {
        border: 2px solid #EFA63E;
        background-color: white !important;
    }
    
    .yellow-icon {
        color: #EFA63E !important;
        font-size: 34px !important;
        margin-right: 0px;
        margin-top: 0px;
    }
    
    .black-text {
        color: black !important;
    }
    
    .yellow-hr {
        border-top: 1px solid #EFA63E;
    }
    
    .card .card-statistic-3 .card-icon-large .fas, 
    .card .card-statistic-3 .card-icon-large .far, 
    .card .card-statistic-3 .card-icon-large .fab, 
    .card .card-statistic-3 .card-icon-large .fal {
        font-size: 90px;
    }
    
    .card .card-statistic-3 .card-icon {
        text-align: center;
        line-height: 50px;
        margin-left: 15px;
        position: absolute;
        right: -5px;
        top: 125px;
        opacity: 1;
    }
    
    .progress {
        display: none;
    }
    
    h2, h3 {
        color: black !important;
        font-size: 14px;
    }
    
    .card-title {
        font-size: 16px !important;
    }
    
    a {
        color: black !important;
    }
    
    a:hover {
        color: #EFA63E !important;
        text-decoration: none;
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

                            $('#BloodBankTotal').text(data[i].Total_patient_Count);


                        }

                        if (department == "CT_Scan") {

                            $('#CT_Scan_Total').text(data[i].Total_patient_Count);


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



                    var rowColorStyle = 'style="background: linear-gradient(to right, #493240, #4bb97b) !important;color:#fff;"';
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
   
    <br />

    <div class="container-fluid">
       <div class="col-md-12" style="padding-left:10%">
    <div class="row">
        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >

        <div  class="d-flex align-items-center justify-content-between px-3 py-2  headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">General Patients</h3>
            <i class="far fa-user-md iconcolor" ></i>
        </div>
        
        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="total_opd" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0">
                        <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillPendingPatientsList()">Pending</a>
                    </h3>
                </div>
                <div class="col-4 text-right">
                    <span id="total_Pending" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-8">
                    <h3 class="mb-0">
                        <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillcheckedpatient()">Checked</a>
                    </h3>
                </div>
                <div class="col-4 text-right">
                    <span id="total_checked" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">Doctor Wise</h3>
            <i class="far fa-user-md iconcolor" ></i>
        </div>
        
        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patient</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="total_prvt" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0">
                        <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillPendingPrivatePatientsList();">Pending</a>
                    </h3>
                </div>
                <div class="col-4 text-right">
                    <span id="tot_pending" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-8">
                    <h3 class="mb-0">
                        <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="CheckPrivate()">Checked</a>
                    </h3>
                </div>
                <div class="col-4 text-right">
                    <span id="tot_checked" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">IPD</h3>
            <i class="fas fa-bed iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patient</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="total_prvts" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Pending</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="tot_pendings" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Checked</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="tot_checkeds" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">Emergency</h3>
            <i class="fas fa-hospital-alt iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="Emergency_total" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Short Stay</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="ShortStay" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

    </div>
    <div class="row">
        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">Lab</h3>
            <i class="fas fa-flask iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="LabTotal" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Checked</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="LabChecked" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center">
                <div class="col-8">
                    <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillPendinglabList();">
                        <h3 class="mb-0">Pending</h3>
                    </a>
                </div>
                <div class="col-4 text-right">
                    <span id="labpending" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">Blood Bank</h3>
            <i class="fas fa-tint iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="BloodBankTotal" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">UltraSound</h3>
            <i class="fas fa-desktop-alt iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="ultraTotal" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Checked</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="ultrachecked" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillPendingultralist();">
                        <h3 class="mb-0">Pending</h3>
                    </a>
                </div>
                <div class="col-4 text-right">
                    <span id="ultrapending" class="black-text font-weight-bold">0</span>
                </div>
            </div>
        </div>
    </div>
</div>

        <div class="col-xl-3 col-lg-6">
    <div class="card card-outline-yellow completecard" >
        <div  class="d-flex align-items-center justify-content-between px-3 py-2 headercolor">
            <h3 class="card-title mb-0 font-weight-bold black-text">X-Ray</h3>
            <i class="fas fa-x-ray iconcolor" ></i>
        </div>

        <div class="card-statistic-3 px-3 pt-3">
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Total Patients</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="X-RayTotal" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <h3 class="mb-0 black-text">Checked</h3>
                </div>
                <div class="col-4 text-right">
                    <span id="xraychecked" class="black-text font-weight-bold">0</span>
                </div>
            </div>
            <div class="row align-items-center mb-2">
                <div class="col-8">
                    <a class="black-text" style="text-decoration: none; cursor: pointer;" onclick="fillPendingxraylist();">
                        <h3 class="mb-0">Pending</h3>
                    </a>
                </div>
                <div class="col-4 text-right">
                    <span id="xraypending" class="black-text font-weight-bold">0</span>
                </div>
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
