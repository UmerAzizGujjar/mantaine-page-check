<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ShiftAppointment.aspx.cs" Inherits="PMS.ShiftAppointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            loaddoctor();

            // Master checkbox - keep only one
            $('[id*="Getrow"]').on('click', function () {
                var isTrue = $('#Getrow').is(':checked');
                $('.chckrow').prop('checked', isTrue);
            });

            // Datepickers - initialise all, shiftdate gets onSelect
            $("#txt_shiftdate").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0,
                onSelect: function () {
                    loadShiftTimes();
                }
            }).attr('readonly', 'readonly');

            $("#txt_dateto").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0
            }).attr('readonly', 'readonly');

            $("#txt_datefrom").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0
            }).attr('readonly', 'readonly');

            // Restore from query string (if any)
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
                // Load times if date is set from query string
                loadShiftTimes();
            }

            // Search button
            $('#btnSearch').click(function () {
                getpage();
            });

            // Shift button - now with time and conflict checks
            $('#btnshiftApt').on('click', function () {
                debugger;
                var ShiftDate = $('#txt_shiftdate').val();
                var ShiftDoctorId = $('#ddlShiftDoctor').val();
                var ShiftTime = $('#ddlShiftTime').val();

                // Validate date and time
                if (!ShiftDate) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select a shift date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                    });
                    return;
                }
                if (!ShiftTime || ShiftTime === "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please select a shift time',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                    });
                    return;
                }

                // If a new doctor is selected, check roster and time conflict
                if (ShiftDoctorId && ShiftDoctorId != "0") {
                    PageMethods.CheckDoctorRosterForDate(ShiftDoctorId, ShiftDate, function (hasRoster) {
                        if (!hasRoster) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Doctor has no roster defined for selected date',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                            });
                            return;
                        }
                        // Use time‑specific conflict check instead of date‑only
                        PageMethods.CheckTimeConflict(ShiftDoctorId, ShiftDate, ShiftTime, function (hasConflict) {
                            if (hasConflict) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Doctor already has an appointment at this time on selected date',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                                });
                                return;
                            }
                            shiftAppointments(ShiftDoctorId, ShiftTime);
                        });
                    });
                } else {
                    // No new doctor selected – still update the time (and keep same doctor)
                    shiftAppointments(null, ShiftTime);
                }
            });

            // Bind change events for doctor and shift date (manual changes)
            $('#ddlShiftDoctor, #txt_shiftdate').on('change', loadShiftTimes);
        });

        // ---------- Helper Functions ----------
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
            var doc_id = $('#chk_Doc').find('option:selected').val();

            if (doc_id == "0") {
                stDate = "";
                endDate = "";
            }

            PageMethods.getlist(stDate, endDate, doc_id, function (data) {
                debugger;
                if (data.length === 0) {
                    $("#table_res tbody").empty();
                    return false;
                }
                else {
                    debugger;
                    abc = false;
                    var Priority = '';
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
                            var Status = $(this).find('td:eq(6)').text();
                            if (Status == "Visited") {
                                $(this).css('background-color', 'rgba(26, 255, 26, 0.44)');
                            }
                            if (Status == "Not Visited") {
                                $(this).css('background-color', '#ff7c7c69');
                            }
                        });
                    }
                }
            });
            return false;
        }

        function loaddoctor() {
            debugger;
            PageMethods.LoadDoctor(function (res) {
                debugger;
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#chk_Doc').val(options);
                $('#chk_Doc').append(options);
                $('#chk_Doc').html(options);
                $('#chk_Doc').select2();

                $('#ddlShiftDoctor').html('<option value="">Select Doctor (Optional)</option>' + options);
                $('#ddlShiftDoctor').select2();

                // Load times if a shift date is already set (e.g., from query string)
                loadShiftTimes();
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


        function loadShiftTimes() {
    var doctorId = $('#ddlShiftDoctor').val();
    var shiftDate = $('#txt_shiftdate').val();
    var $timeSelect = $('#ddlShiftTime');

    if (doctorId && doctorId != "" && shiftDate) {
        PageMethods.GetDoctorAvailableSlots(doctorId, shiftDate, function (slots) {
            $timeSelect.empty().append('<option value="">Select Time</option>');
            if (slots && slots.length) {
                $.each(slots, function (i, slot) {
                    var option = $('<option></option>')
                        .val(slot.value)
                        .text(slot.display);

                    if (slot.booked) {
                        option.prop('disabled', true)
                              .css({
                                  'background-color': '#ffcccc',
                                  'color': '#990000',
                                  'font-weight': 'bold'
                              });
                    }
                    $timeSelect.append(option);
                });
            } else {
                $timeSelect.append('<option value="">No available slots</option>');
            }
        });
    } else {
        $timeSelect.empty().append('<option value="">Select Time</option>');
    }
}

        // Perform the shift for all selected appointments
        function shiftAppointments(ShiftDoctorId, ShiftTime) {
            var ShiftDate = $('#txt_shiftdate').val();
            $.each($('#table_res tbody tr'), function (key, value) {
                var chck = $(value).find('td input[name=Getrow]').prop("checked");
                var appid = $(value).find('td input[name=app_id]').val();
                if (chck) {
                    if (ShiftDoctorId) {
                        PageMethods.ShiftAPTWithDoctor(appid, ShiftDate, ShiftDoctorId, ShiftTime, function (response) { });
                    } else {
                        PageMethods.ShiftAPT(appid, ShiftDate, ShiftTime, function (response) { });
                    }
                }
            });
            // Refresh the page after shifting
            window.location.href = 'ShiftAppointment.aspx';
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
        <div class="col-lg-1 col-md-3 col-sm-6">
            <label class="col-form-label">From</label>
            <input type="text" id="txt_datefrom" class="form-control" />
        </div>
        <div class="col-lg-1 col-md-3 col-sm-6">
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
        <div class="col-lg-2 col-md-3 col-sm-6">
            <label>Shift Doctor</label>
            <select id="ddlShiftDoctor" class="form-select">
                <option value="">Select Doctor (Optional)</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-6">
            <label>Shift Time</label>
            <select id="ddlShiftTime" class="form-select">
                <option value="">Select Time</option>
            </select>
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
                        <input id="Getrow" class="chckrow" type="checkbox" />
                    </th>
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