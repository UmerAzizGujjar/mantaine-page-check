<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DashPatientsCountertoClinic.aspx.cs" Inherits="PMS.Modules.Dashboards.DashPatientsCountertoClinic" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <style type="text/css">
        .table tr {
            border: 1px solid #D9E4E6;
            height: 55px !important;
        }

            .table tr th {
                text-align: center;
                border: 1px solid #FFF;
                background-color: #308665db;
                color: white;
            }

            .table tr td {
                text-align: center;
                border: 1px solid gray;
            }

        #Box1 {
            width: 250px;
            height:70px;
        }

        #Box2 {
            width: 250px;
            height:70px;
        }
         select{
        width:200px !important;
    }
         input{
             width:200px !important;
         }
        #Box3 {
            width: 250px;
            height:70px;
        }

        .h3, h3 {
            font-size: 15px;
            font-weight: 600;
        }

        #h1 {
            font-weight: 600;
            position: relative;
            /*margin-left: 38%;*/
            font-size: 37px;
            font-family: revert;
            color: #438eb9;
        }

        .l-bg-orange-dark {    background: linear-gradient(to right, #032c7a, #1d78ddf2) !important;    color: #fff;}


.l-bg-green-dark {    background: linear-gradient(to right, #602222, #b50716) !important;    color: #fff;}

    </style>


    <script type="text/javascript">
    $(document).ready(function () {

        var date = '<%= DateTime.Now%>';
        $("#txtsdate").datepicker({
            dateFormat: 'MM d,yy',

        }).attr('readonly', 'readonly');

        $("#txtedate").datepicker({
            dateFormat: 'MM d,yy',

        }).attr('readonly', 'readonly');

        date = moment(date).format('LL');
        $("#txtsdate").val(date);
        $("#txtedate").val(date);

        LoadDashboard(date, date);

    });


    function Loadsearchboard() {
        var dt = $('#txtsdate').val();
        var dts = $('#txtedate').val();

        LoadDashboard(dt, dts);    
    }
 
  
    function LoadDashboard(startdate, Enddate) {
        var txt_sdate = startdate;
        var txt_edate = Enddate;
        var Dep = $('#ddlDepartemt').val();

        $.ajax({
            type: "POST",
            url: "DashPatientsCountertoClinic.aspx/ViewList",
            data: JSON.stringify({
                'txt_sdate': txt_sdate,
                'txt_edate': txt_edate,
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (data) {
                var parsedData = JSON.parse(data.d);
                var rows = '';
                var srNo = 1;
                var totalPatients = parsedData.length;
                var totalTimeSpent = 0;

                $('#regdetail tbody').empty();
                $.each(parsedData, function (key, value) {
                    var RegDate = value.Reg_Time ? new Date(parseInt(value.Reg_Time.substr(6))) : null;
                    var Reg_Date = RegDate ? moment(RegDate).format('LLLL') : '';

                    var OPDDate = value.Opd_Time ? new Date(parseInt(value.Opd_Time.substr(6))) : null;
                    var Opd_Date = OPDDate ? moment(OPDDate).format('LLLL') : '';

                    var OutpatDate = value.Out_patient_Time ? new Date(parseInt(value.Out_patient_Time.substr(6))) : null;
                    var Out_pat_Date = OutpatDate ? moment(OutpatDate).format('LLLL') : '';

                    var LabDate = value.Lab_Time ? new Date(parseInt(value.Lab_Time.substr(6))) : null;
                    var Lab_Date = LabDate ? moment(LabDate).format('LLLL') : '';

                    var MedicineDate = value.Medicine_Time ? new Date(parseInt(value.Medicine_Time.substr(6))) : null;
                    var Medicine_Date = MedicineDate ? moment(MedicineDate).format('LLLL') : '';

                    var ServiceDate = value.Service_Time ? new Date(parseInt(value.Service_Time.substr(6))) : null;
                    var Service_Date = ServiceDate ? moment(ServiceDate).format('LLLL') : '';

                    var DischargeDate = value.Discharge_Date ? new Date(parseInt(value.Discharge_Date.substr(6))) : null;
                    var Discharge_Date = DischargeDate ? moment(DischargeDate).format('LLLL') : '';

                    var Total_Time_Spent = parseFloat(value.Total_Time_Spent) || 0;
                    totalTimeSpent += Total_Time_Spent; 
                    rows += '<tr><td style="text-align:left;">' + srNo + '</td><td style="text-align:left;">' + value.mr_no_sequence + '</td><td style="text-align:left;">' + value.Full_Name + '</td><td style="text-align:left;">' + Reg_Date + '</td><td style="text-align:left;">' + Opd_Date + '</td><td style="text-align:left;">' + Out_pat_Date + '</td><td style="text-align:left;">' + Lab_Date + '</td><td style="text-align:left;">' + Medicine_Date + '</td><td style="text-align:left;">' + Service_Date + '</td><td style="text-align:left;">' + Discharge_Date + '</td><td style="text-align:left;">' + value.Total_Time_Spent + '</td></tr>';

                    srNo++;
                });

                $('#regdetail tbody').append(rows);

                var avgTimeSpent = totalPatients > 0 ? (totalTimeSpent / totalPatients).toFixed(2) : 0;

                $('#totalPatients').text(totalPatients);
                $('#avgTimeSpent').text( avgTimeSpent + ' hours');
            },
            error: function (xhr, status, error) {
                console.error("Error occurred: " + status + " " + error);
            }
        });
    }


    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row" style="text-align :center;">
        <h1 id="h1">Time Slab of Patient in OPD</h1>
    </div>
    <br />

    <div class="row">
    <div class="col-lg-12 ">
        <div class="col-md-4" style="margin-left:200px !important;">
            <div class="card l-bg-orange-dark text-white" id="Box1">
                <div class="card-header" style="height: 30px; background-color: #2222 ;text-align: center;">
                    <h3 id="Dpt" style="padding: 5px;">Total Patients</h3>
                    <i class="fas fa-thin  fa-sack-dollar" style="position: relative; float: right; margin-top: -25px; margin-right: 1px; font-size: 18px;"></i>
                </div>

           <div class="card-body">
          
                  <div class="col-12" style="text-align:center; font-size:15px !important;">
                        <span id="totalPatients">0</span>
                    </div>

                </div>
            </div>
        </div>
        <div class="col-md-4" style="padding-left: 72px!important;">

            <div class="card l-bg-green-dark text-white" id="Box2">
                <div class="card-header" style="height: 30px; background-color: #2222 ;text-align: center;">
                    <h3 id="Dpt2"style="padding: 5px;" >Average Patients</h3>
                    <i class="fas fa-book-medical" style="position: relative; float: right; margin-top: -24px; margin-right: -6px; font-size: 18px;"></i>
                </div>
                <div class="card-body">
                 
              <div class="col-12" style="text-align:center; font-size:15px !important;">
                        <span id="avgTimeSpent">0</span>
                    </div>

                </div>
          
            </div>
        </div>

    </div>
</div>

    <br />
     <br />
    <div class="row">
        <div class="col-lg-2">
            <label> Start Date: </label>
            <input type="text" id="txtsdate" />
        </div>

        <div class="col-lg-2">
            <label> End Date: </label>
            <input type="text" id="txtedate" />
        </div>
        <div class="col-lg-2">
            <input type="button" id="serach" class="btn btn-primry" value="Search" onclick="Loadsearchboard()" />
        </div>
    </div>

    <div class="row" style="margin-top: 60px; overflow: scroll!important; height: 700px !important;">
        <div class="col-lg-12">
            <table class="table" id="regdetail">
                <thead>
                    <tr>
                        <th>SR No</th>
                        <th>MR No</th>
                        <th>Patient Name</th>
                        <th>Reg Date</th>
                        <th>OPD Date</th>
                        <th>Out Patient</th>
                        <th>Lab Date</th>
                        <th>Medicine Date</th>
                        <th>Service Date</th>
                        <th>Discharge Date</th>
                        <th>Total Hours</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </div>
</asp:Content>
