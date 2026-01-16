<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ShiftAppointment.aspx.cs" Inherits="PMS.ShiftAppointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            loaddoctor();

            $('[id*="Getrow"]').on('click', function () {
                debugger; var isTrue = $('#Getrow').is(':checked');
                if (isTrue) {
                    debugger; $('.chckrow').prop('checked', true);
                } else {
                    debugger; $('.chckrow').prop('checked', false);
                }
            });

            var date = '<%= DateTime.Now%>';
            $("#txt_shiftdate").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0 // Setting minDate to 0 means only future dates are allowed
            }).attr('readonly', 'readonly');

            $("#txt_dateto").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0 // Setting minDate to 0 means only future dates are allowed
            }).attr('readonly', 'readonly');

            $("#txt_datefrom").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0 // Setting minDate to 0 means only future dates are allowed
            }).attr('readonly', 'readonly');

            var checkeditmode_startdate = '<%= Request.QueryString["stDate"]%>';

            var checkeditmode_enddate = '<%= Request.QueryString["endDate"]%>';
            var checkeditmode_shiftdate = '<%= Request.QueryString["ShiftDate"]%>';


            if (checkeditmode_startdate != '') {

                $('#txt_datefrom').val(checkeditmode_startdate);
            }

            if (checkeditmode_enddate != '') {

                $('#txt_dateto').val(checkeditmode_enddate);
            }
            if (checkeditmode_shiftdate != '') {

                $('#txt_shiftdate').val(checkeditmode_shiftdate);
            }




            $('#btnSearch').click(function () {
                getpage();
                //loadappt(appID);

            });
            $('#btnshiftApt').on('click', function () {
                debugger;
                /*var ShiftDate = $('#txt_shiftdate').val();*/

                $.each($('#table_res tbody tr'), function (key, value) {
                    debugger;
                    var chck = $($(value).find('td input[name=Getrow]')[0]).prop("checked");
                    var appid = $($(value).find('td input[name=app_id]')[0]).val();
                    var ShiftDate = $('#txt_shiftdate').val();
                    debugger;
                    if (chck == "true" || chck == true) {
                        debugger;
                        PageMethods.ShiftAPT(appid, ShiftDate, function (response) {
                            debugger;
                            var data = response;
                            if (data == "Success") {
                                // alert("Bill has been approved successfully");

                            }



                        });

                    }
                    else {

                    }





                });
                window.location.href = 'ShiftAppointment.aspx';
            });


        });

        function toTitleCase(str) {
            return str.replace(/[^a-zA-Z0-9]+(.)/g, function (match) {
                return match.toUpperCase();
            });
        }
        function getpage() {
            debugger;
            var stDate;
            var endDate;
            if (stDate == null) {


                var getstDate = $('#txt_datefrom').val();
                stDate = getstDate;

            }

            else {
                stDate = stDate;
            }
            if (endDate == null) {
                endDate = $('#txt_dateto').val();
            }

            else {
                endDate = endDate;
            }
            // date and status search both

            var doc_id = $('#chk_Doc').find('option:selected').val();


            if (doc_id == "0") {


                stDate = "";
                endDate = "";


            }

            //Append data from data base table
            PageMethods.getlist(stDate, endDate, doc_id, function (data) {
                debugger;
                if (data.length === 0) {
                    // Empty the tbody of the table with id "table_res"
                    $("#table_res tbody").empty();
                    return false;
                }
                else {
                    debugger;
                    abc = false;
                    //var table;
                    var Priority = '';
                    //table = $('#tblRes').table();
                    var length = $("#table_res tr:gt(0)").length;
                    debugger;
                    if (data != '') {
                        var data = JSON.parse(data);
                        var rows = '';
                        debugger;
                        $.each(data, function (i, item) {
                            debugger;
                            var App_Date = moment(data[i].App_Date).format('LL');
                            var time = moment(data[i].Time).format('h:mm a');
                            var app_id = data[i].Appointment_ID;
                            debugger;
                            rows += '<tr><td style="display:none;"><input id="app_id" name="app_id" class="app_id" type="hidden" value="' + app_id + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td>' + data[i].Appointment_No + '</td><td>' + toTitleCase(data[i].Patient_Name.replace("_", " ")) + '</td><td>' + data[i].emp_name + '</td><td>' + App_Date + '</td></tr>';



                        });
                        debugger;
                        $('#t_body').html(rows);

                        $('#table_res tbody:eq(1) tr').each(function (key, value) {
                            // debugger;
                            var Status = $(this).find('td:eq(6)').text();

                            if (Status == "Visited") {
                                $(this).css('background-color', 'rgba(26, 255, 26, 0.44)');
                            }

                            if (Status == "Not Visited") {
                                $(this).css('background-color', '#ff7c7c69');
                            }
                            else {

                            }
                        });

                    }
                }

            });


            return false;
        }

        var Doctors;
        var options;
        function loaddoctor() {
            debugger;
            PageMethods.LoadDoctor(function (res) {
                debugger;
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#chk_Doc').val(options);
                $('#chk_Doc').append(options);
                $('#chk_Doc').html(options);





            });
        }

        function ddldocchange() {
            debugger;



            var DocChk = $('#chk_Doc').find('option:selected').text();
            getpage();
            if (DocChk == "Select Doctor") {
                acc = true;

            }
            else {
                var tbl = document.getElementById('table_res');
                if (DocChk.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[3].innerText != DocChk) {
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

        }




    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row mb-3">
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Doctor</label>
                <select id="chk_Doc" class="form-select" onchange="ddldocchange()">
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label class="col-form-label">From</label>
                <input type="text" id="txt_datefrom" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label class="col-form-label ms-3">To</label>
                <input type="text" id="txt_dateto" class="form-control ms-3" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label></label>
                <input type="button" id="btnSearch" class="btn btn-primry" value="Search" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Shift Appointment</label>
                <input type="text" id="txt_shiftdate" class="form-control" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <label></label>
                <input type="button" id="btnshiftApt" class="btn btn-primry" value="Shift" />
            </div>
        </div>

    <br />
       <div class="table-container">
        <table class="table" id="table_res" style="overflow: scroll; height: auto;">
            <thead>
                <tr>
                     <th style="width: 8%;">
                <input id="Getrow" class="chckrow" type="checkbox" /></th>
                <th>APPT NO</th>
                <th>PATIENT NAME</th>
                <th>DOCTOR NAME</th>
                <th>DATE</th>
                </tr>
            </thead>
            <tbody id="t_body">
            </tbody>

        </table>
           </div>


  
</asp:Content>
