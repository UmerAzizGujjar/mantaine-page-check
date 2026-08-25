<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Appointment.aspx.cs" Inherits="PMS.Appointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Appointment.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/Appointment.js"></script>
     <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            var txt_apt_no = $('#txt_apt_no').val();
            if (txt_apt_no && txt_apt_no > 0) {
                var dropdowns = [
                    { id: '#ddlDepartment', method: 'GetDepartment' },
                    { id: '#ddl_Province', method: 'GetProvince' },
                    { id: '#txtcity', method: 'GetCity' },
                    { id: '#ddlCountry', method: 'GetCountry' },
                    { id: '#ddlArea', method: 'GetArea' },
                    { id: '#ddl_Gender', method: 'GetGender' },
                    { id: '#ddl_status', method: 'GetMartailStatus' },
                    { id: '#ddlPatient_Type', method: 'PatientType' },
                    { id: '#ddl_colstnt', method: 'GetDoctor' }
                ];

                dropdowns.forEach(item => {
                    debugger;
                    const $element = $(item.id);
                    $element.select2();
                    $element.on('select2:open', function () {
                        fillDropdown($element, item.method);
                    });

                    if (item.id === '#ddlPatient_Type') {
                        $element.prop('disabled', false);
                        $element.off('select2:select').on('select2:select', function () {
                            loaddata();
                            $(this).prop('disabled', true);
                        });
                    }

                    if (item.id === '#ddlDepartment') {
                        $element.prop('disabled', false);
                        $element.off('select2:select').on('select2:select', function () {
                            loaddoctor();
                        });
                    }

                    if (item.id === '#ddl_colstnt') {
                        $element.off('change').on('change', function () {
                            var doctor_id = $(this).val();
                            if (doctor_id) {
                                ConfigureAvailableDates(doctor_id);
                                GetAppNoByDoctor();
                                GetSubDepartmentByDoctor(doctor_id);
                                LoadPage();
                            }
                        });
                    }


                });
            }
            else {
                //LoadDetailDoctor();
                

            }
            


            $('#ddl_colstnt').select2();
            $('#chk_status').select2();
            $('#ddlsubdepartment').select2();
            //
            // Flag to prevent double-click or dual-button duplicate save
            let isSaving = false;

            function safeSaveAttempt() {
                if (isSaving) {
                    console.warn("Save already in progress. Ignoring duplicate trigger.");
                    return;
                }

                isSaving = true;
                $('#btnSave, #btnSaveMessage').prop('disabled', true).addClass('disabled');

                verifydoctoravail(function (result) {
                    try {
                        if (result === 'OnDay') {
                            save = $('#btnSave').val();
                            SaveAllRecord();
                        }
                    } finally {
                        // Re-enable buttons after a short delay
                        setTimeout(() => {
                            isSaving = false;
                            $('#btnSave, #btnSaveMessage').prop('disabled', false).removeClass('disabled');
                        }, 1000);
                    }
                });
            }

            // Attach both buttons to the same safe handler
            $('#btnSave').off('click').on('click', safeSaveAttempt);
            $('#btnSaveMessage').off('click').on('click', safeSaveAttempt);
            debugger;
            $("#txtSearch").keypress(function (event) {
                debugger;
                var SearchString = $('#txtSearch').val();
                if (event.which == 13) {
                    {

                        event.preventDefault();

                        if (SearchString != '') {

                            PageMethods.SearchPatients((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterPatients, OnFailPatients);
                        }
                    }
                    if (SearchString === '') {
                        FillPatientsList();
                    }
                }
            });
            $("#txtSearch").keyup(function (event) {

                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillPatientsList();
            });
            $('#txt_date').change(function () {
                LoadPage();
            });

       


            debugger;
            var App_id = '<%= Request.QueryString["APPID"]%>';
            if (App_id != "") {

                loadapptEdit(App_id);

            }
            if (App_id == "") {
                filldepartment();
                $('#ddlsubdepartment').on('change', function () {
                    debugger;
                    var dep = $('#ddlsubdepartment').val();
                    LoadDetailDoctor(dep)
                    setTimeout(function () {
                        $('#ddlServices').focus();
                    }, 5);



                });
            }

          

            debugger;
            $('#ddl_colstnt').on('change', function () {
                debugger;
                var doctor_id = $('#ddl_colstnt').val();
                ConfigureAvailableDates(doctor_id);
                var aID = '<%= Request.QueryString["aID"]%>';
                if (aID != "") {

                }
                else {
                    GetAppNoByDoctor();
                }

                //GetSubDepartmentByDoctor(doctor_id);
                LoadPage();

                setTimeout(function () {
                    $('#ddlsubdepartment').focus();
                }, 14);



            });
            $('#ctl00_MainContent_ddlPrefixDrp').on('select', function () {
                debugger;


                setTimeout(function () {
                    $('#txt_pt_name').focus();
                }, 5);



            });

            $('#ddlServices').on('change', function () {
                debugger;


                setTimeout(function () {
                    $('#txtRemarks').focus();
                }, 5);



            });
            MaskedInput({
                elm: document.getElementById('txt_phone_no'),
                format: '___________',
                separator: '-'

            });

           
            LoadPage();
            getpage();





            $('#chk_Doc').select2();

            $('#txt_pt_name').attr('disabled', true);
            $('#txt_phone_no').attr('disabled', true);
            $('#txt_age').attr('disabled', true);


            debugger;
            var ids = '<%= Request.QueryString["aID"]%>';
            var reg_pat = '<%= Request.QueryString["ID"]%>';
            debugger;

            if (ids == '' || ids == "") {
                debugger;


                $("#PatientsSearchModel").modal('show');


                var App_ids = '<%= Request.QueryString["APPID"]%>';
                if (App_ids != "") {
                    $("#PatientsSearchModel").modal('hide');
                }
                FillPatientsList();
                //$('#srchpat').text("Search By Phone No");

                //jQuery(function ($) {
                //    MaskedInput({
                //        elm: document.getElementById('txtSearch'),
                //        format: '+92__________',
                //        separator: '-'
                //    });
                //    var phoneInput = document.getElementById('txtSearch');
                //    var cursorPosition = 3;
                //    phoneInput.setSelectionRange(cursorPosition, cursorPosition);

                //});
            }

            if (ids !== "") {
                var appID = '<%= Request.QueryString["aID"]%>';

                    loadappt(appID);

       



            }
            else {
                GetAppNo();
            }

            var date = '<%= DateTime.Now%>';
            $("#txt_date").datepicker({
                dateFormat: 'MM d,yy',
                minDate: 0
            }).attr('readonly', 'readonly');

            date = moment(date).format('LL');
            $("#txt_date").val(date);

            var date = '<%= DateTime.Now%>';
            $("#txt_dateto").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_dateto").val(date);

            $("#txt_datefrom").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_datefrom").val(date);


            var checkeditmode_startdate = '<%= Request.QueryString["stDate"]%>';

            var checkeditmode_enddate = '<%= Request.QueryString["endDate"]%>';


            if (checkeditmode_startdate != '') {

                $('#txt_datefrom').val(checkeditmode_startdate);
            }

            if (checkeditmode_enddate != '') {

                $('#txt_dateto').val(checkeditmode_enddate);
            }


            $('#btnSearch').click(function () {
                getpage();


            });



            setTimeout(function () {
                $('#ctl00_MainContent_ddlPrefixDrp').focus();
            }, 5000);
            debugger;
            if (reg_pat != '' || reg_pat != "") {
                debugger;
                $('#ClosePatientsSearchModel').click();
                $('#patmodalClose').click();
                load_Initial_Pat_Data(reg_pat);
                $('#ddl_colstnt').attr('disabled', false);
                $('#ddlsubdepartment').attr('disabled', false);
            }

            PageMethods.GetAllDoctors(function (data) {
                var options = '<option value="">Select Doctor</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                $('#chk_Doc').html(options).select2();
            }, function (err) {
                console.error("Failed to load doctors for filter:", err);
            });

            (function populateCalendarControls() {
                var $month = $('#calMonthSelect');
                var $year = $('#calYearSelect');
                var months = moment.months();

                $month.empty();
                months.forEach(function (m, i) {
                    $month.append('<option value="' + i + '">' + m + '</option>');
                });

                var currentYear = moment().year();
                $year.empty();
                for (var y = currentYear - 5; y <= currentYear + 5; y++) {
                    $year.append('<option value="' + y + '">' + y + '</option>');
                }

                $month.val(moment().month());
                $year.val(currentYear);
            })();

            debugger;
            $('#calGoBtn').on('click', function (e) {
                e.preventDefault();
                var month = parseInt($('#calMonthSelect').val(), 10);
                var year = parseInt($('#calYearSelect').val(), 10);
                loadCalendarForMonth(year, month);
            });

            $('#calTodayBtn').on('click', function (e) {
                e.preventDefault();
                var now = moment();
                $('#calMonthSelect').val(now.month());
                $('#calYearSelect').val(now.year());
                loadCalendarForMonth(now.year(), now.month());
            });
        });

        function fillDropdown($dropdown, methodName) {
            if ($dropdown.data('filled')) return;

            $dropdown.data('filled', false);

            $.ajax({
                type: "POST",
                url: "Appointment.aspx/" + methodName,
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        var options = '<option value="0">Please Select</option>';

                        $.each(data, function (key, value) {
                            options += `<option value="${value.DataValue_Name}">
                                    ${value.DataValue_Description}
                                </option>`;
                        });

                        $dropdown.html(options)
                            .data('filled', true)
                            .trigger('change');
                        if ($dropdown.hasClass('select2-hidden-accessible')) {
                            $dropdown.select2('close').select2('open');
                        }
                    } catch (e) {
                        console.error(`Error parsing data from ${methodName}:`, e);
                        $dropdown.data('filled', false);
                    }
                },
                error: function (xhr, status, error) {
                    console.error(`Error fetching ${methodName}:`, error);
                    $dropdown.data('filled', false);
                }
            });
        }

        //function GetSubDepartmentByDoctor(doctor_Id) {
        //    PageMethods.GetSubDepartmentByDoctor(doctor_Id, function (data) {
        //        var options = '';
        //        $.each(JSON.parse(data), function (key, value) {
        //            options += '<option value="' + value.Department + '" >' + value.Departments + '</option>';
        //        });
        //        $('#ddlsubdepartment').html(options);
        //        $('#ddlsubdepartment').select2();
        //    },
        //        function (error) {
        //            alert(error.get_message());
        //        });
        //}
        //Print
        function appointmentPatient_Print() {
            debugger;
            var appointmentId = '<%= Request.QueryString["APPID"]%>';
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=Appointment_Patient_Print&Title=Appointment Patient Print &appointmentId=" + appointmentId;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Appointment_Patient_Print&Title=Appointment Patient Print &appointmentId=" + appointmentId;
            }
            window.open(url, '_blank');
        }
        function closemodal() {
            window.location.href = "Appointment.aspx";
        }
        function ConfigureAvailableDates(doc_id) {
            $.ajax({
                type: "POST",
                url: "Appointment.aspx/GetAvailableDates",
                data: JSON.stringify({ doc_id: doc_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var availableDates = JSON.parse(response.d);

                    $("#txt_date").datepicker("destroy"); // Remove any previous config

                    $("#txt_date").datepicker({
                        dateFormat: "yy-mm-dd", // format to match your returned data
                        beforeShowDay: function (date) {
                            var dmy = $.datepicker.formatDate("yy-mm-dd", date);
                            if (availableDates.indexOf(dmy) !== -1) {
                                return [true, "available-date", "Doctor Available"];
                            } else {
                                return [false, "", "Doctor Not Available"];
                            }
                        }
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error fetching available dates:", error);
                }
            });
        }
        function addfunc() {
            debugger;


            var maskedValue = $('#txtSearch').val();
            var unmaskedValue = maskedValue.replace(/_/g, '');


            var Ph_sNOs = unmaskedValue.length;


            if (Ph_sNOs === 13) {
                $('#addNewbtn').attr("disabled", false);
                AddNewPatient();
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Complete Mobile Number First',
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




            debugger;

            $('#ClosePatientsSearchModel').click();
            $('#patmodalClose').click();
            $('#PatientsSearchModel').hide();
            fillmrno();
            setTimeout(function () {
                $('#txt_mobile').val(unmaskedValue);
            }, 100);
            $('#txt_name').focus();
        }
        function fillmrno() {
            var data = {};

            $.ajax({
                type: "POST",
                url: "Appointment.aspx/Getmr",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var max_mr = data.d;
                    $('#txt_Mrnos').val(max_mr);
                },
                error: function (xhr, status, error) {
                    console.error("AJAX request failed:", status, error);
                }
            });
        }


        function load_Initial_Pat_Data(reg_pat) {
            var reg_id = reg_pat;
            $('#PatientsSearchModel').close;
            debugger;
            $.ajax({
                type: "POST",
                url: "Appointment.aspx/loadApp_data",
                data: JSON.stringify({
                    'reg_id': reg_id

                }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var dataaa = JSON.parse(data.d);

                    $('#txt_pt_name').val(dataaa.Full_Name);
                    $('#txt_phone_no').val(dataaa.Age);
                    $('#txt_age').val(dataaa.Age_years);
                    $('#txt_phone_no').val(dataaa.Mobile1);
                    $('#hdfreg_ini_id').val(dataaa.pat_id);
                    $('#txt_apt_no').val('');
                    $('#slotsGrid').html('<h3>Please Select Doctor</h3>');



                },
                error: function (x, e) {
                    alert(e)
                }
            });
        }
        function SearchPatients() {
            debugger;
            $('#PatientsSearchModel').modal({
                backdrop: 'static'

            });
            FillPatientsList();
            $('#addNewbtn').hide();
            $('#srchpat').text("Search Your Patients:");
            $('#txtSearch').unmask();
            $('#ClosePatientsSearchModel').show();

        }
        function AddNewPatient() {
            debugger;
            $('#ddl_pnl_cpy').next(".select2-container").hide();

            clearPatient();
            $('#hdfPatient_ID').val('(New)');

            $('#PatientModel').modal({
                backdrop: 'static'
            });
            $("#ddl_name").focus();
            $("#ddl_name").focus();
            MaskedInput({
                elm: document.getElementById('txt_cnic'), // select only by id
                format: '_____-_______-_',
                separator: '-'

            });
        }
        function FillPatientsList() {
            debugger;
            $('#tblPatientsResult tbody').empty();

            var SearchString = '';

            PageMethods.SearchPatients(SearchString, OnFilterPatients, OnFailPatients);
        }

        function OnFilterPatients(data) {

            ClearPatientResults();

            for (var i = 0; i < data.length; i++) {
                AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
            }
        }
        function OnFailPatients(exc) {
            alert(exc.get_message());
        }
        function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
            debugger;
            tblLength = tblPatientsResult.rows.length;

            var row = iPatientsBody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Reg_Patient_ID + '</span>';
            cell.className = "hide";

            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
            cell = row.insertCell(-1);
            var actions = ''
            actions += '<a class="tooltips" href="#"  onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i></a>';
            cell.innerHTML = actions;
        }
        function ClearPatientResults() {
            while (tblPatientsResult.rows.length > 1) {
                tblPatientsResult.deleteRow(1);
            }
        }
        var isAdd = false;
        function AddPatientDetail(Reg_Patient_ID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "Appointment.aspx?ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

        }

        function LoadPage() {
            debugger;
            var doc_id = $('#ddl_colstnt').val();
            var specificDate = $('#txt_date').val();
            if (doc_id != "") {
                $.ajax({
                    type: "POST",
                    url: "Appointment.aspx/ViewLists",
                    data: JSON.stringify({ doc_id: doc_id, specificDate: specificDate }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var responseData = JSON.parse(response.d);
                        var doctorData = responseData.DoctorData;
                        var appointments = responseData.Appointments;

                        if (!doctorData) {
                            console.error("Doctor is not available that day");
                            $('#slotsGrid').html('<h3>Doctor Roaster not Define</h2>');
                            $('#txt_time').val('');
                            return;
                        }

                        var slotsList = doctorData.Slots;
                        var slotsHtml = '';

                        slotsList.forEach(function (slot, index) {
                            var formattedItem1 = moment(slot.Item1).format('hh:mm A');
                            var formattedItem2 = moment(slot.Item2).format('hh:mm A');
                            var isBooked = appointments.some(function (appointment) {
                                var appointmentTime = moment(appointment.StartTime).format('hh:mm A');
                                return formattedItem1 === appointmentTime;
                            });
                            if (isBooked) {

                                slotsHtml += `<div class="slot-btn booked disabled" style="border 1px solid #484b4d" id="slot-${index}" data-time="${formattedItem1}">
                                    ${formattedItem1} to ${formattedItem2} 
                                  </div>`;
                            } else {
                                slotsHtml += `<div class="slot-btn" style="border 1px solid #484b4d" id="slot-${index}" data-time="${formattedItem1}" onclick="selectSlot('${formattedItem1}', 'slot-${index}')">
                                    ${formattedItem1} to ${formattedItem2}
                                  </div>`;
                            }
                        });
                        $('#slotsGrid').html(slotsHtml);
                        $('#txt_time').val('');
                    },
                    error: function (xhr, status, error) {

                    }
                });

            }

            return false;
        }

        function selectSlot(time, slotId) {

            $('.slot-btn').removeClass('selected');
            $(`#${slotId}`).addClass('selected');
            $('#txt_time').val(time);
        }




        var appendtime;
        function selectRow(appendtime) {
            debugger;
            $('#txt_time').val(appendtime);
        }
        function fillgender() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetGender(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_Gender').html(options);

            });
            return options;
        }

        function fillProvince() {
            var options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'Appointment.aspx/GetProvince',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddl_Province').html(options);

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }

        function fillCity() {
            var options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'Appointment.aspx/GetCity',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#txtcity').html(options);

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }

        function fillCountry() {
            var options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'Appointment.aspx/GetCountry',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlCountry').html(options);

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;
        }

        function fillArea() {
            var options = '<option value="0">Please Select</option>';

            $.ajax({
                url: 'Appointment.aspx/GetArea',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#txtarea').html(options);

                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });

            return options;

        }



        function fillType() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetPAtType(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlPatient_Type').html(options);
                $('#ddlPatient_Type').attr('disabled', true);
                $('#ddlPatient_Type').val('02');

            });
            return options;
        }
        function getpage() {

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

            var Statusddl = $('#chk_status').find('option:selected').text();


            if (Statusddl == "All" && abc == true) {


                stDate = "";
                endDate = "";
            }


            var DocChk = $('#chk_Doc').find('option:selected').text();


            if (DocChk == "Select Doctor" && acc == true) {


                stDate = "";
                endDate = "";


            }


            PageMethods.getlist(stDate, endDate, function (data) {
                debugger;
                if (data.length === 0) {
                    $("#table_res tbody").empty();
                    return false;
                } else {
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
                            var cancel = data[i].cancelAppointment;
                            var status = data[i].Status;

                            if (cancel) {
                                status = 'Cancelled';
                            }

                            var actions = '';
                            if (status === 'Booked') {
                                actions = '<td style="width: 250px;">' +
                                    '<a href="#" onclick="Edit(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px; margin-left: 9px;">Change Schedule</a>' +
                                    '<a href="#" onclick="CancelAppointment(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #ea0000; color: white; padding: 4px 11px; margin-left: 9px;">Cancel</a>' +
                                    '</td>';
                            } else {
                                actions = '<td></td>';
                            }

                            rows += '<tr>' +
                                '<td>' + (i + 1) + '</td>' + '<td>' + data[i].Appointment_No + '</td>' + '<td>' + toTitleCase(data[i].Patient_Name.replace("_", " ")) + '</td>' + '<td>' + data[i].emp_name + '</td>' + '<td>' + data[i].Phone + '</td>' + '<td>' + App_Date + '</td>' + '<td>' + time + '</td>' + '<td name="statusCell">' + status + '</td>' + '<td style="display:none;" name="cancelAppointment">' + data[i].cancelAppointment + '</td>' + actions +
                                '</tr>';
                        });

                            $('#t_body').html(rows);
                            __tBodyCache = rows;

                        $('#table_res tbody:eq(1) tr').each(function (key, value) {
                            debugger;
                            var $statusCell = $(this).find('td[name="statusCell"]'); 
                            var status = $statusCell.text();
                            var app_date = $(this).find('td:eq(5)').text(); 
                            var cancel = $(this).find('td[name="cancelAppointment"]').text();
                            var currentDate = moment().format('LL');

                            
                            if (status === "Visited") {
                                $statusCell.css('color', '#1b7a1b').css('font-weight', 'bold'); 
                                $(this).find('td:last a').hide();
                            } else if (status === "Booked") {
                                $statusCell.css('background-color', '#ffdc86');
                            }

                            if (cancel === "true" || status === "Cancelled") {
                                $statusCell.css('color', '#d32f2f').css('font-weight', 'bold'); 
                                $(this).find('td:last a').hide(); 
                            }
                        });
                    }
                }
            });


            return false;
        }
        function CancelAppointment(appointmentId) {
            debugger;
            if (confirm("Are you sure you want to cancel this appointment?")) {
                $.ajax({
                    type: "POST",
                    url: "Appointment.aspx/CancelAppointment",
                    data: JSON.stringify({ appointmentId: appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Appointment cancelled successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                        

                        location.reload();

                    },
                    error: function (xhr, status, error) {
                        Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: 'Failed to cancel the appointment. Please try again.',
        showConfirmButton: false,
        timer: 2000,
        customClass: {
            popup: 'swal-big-popup',
            title: 'swal-big-title',
            htmlContainer: 'swal-big-text'
        }
        });


                       
                    }
                });
            }
        }


        debugger;
        function loadappt(appID) {
            debugger;
            PageMethods.loadAppData(appID, function (resp) {
                debugger;
                if (appID != "") {
                    $('#btnSave').val('Update');
                }
                var data = JSON.parse(resp);
                var patientTitle = data.Patient_Name.split("_");
                var agePrefix = data.Age.split(" ");

                if (patientTitle.length > 1) {

                    $("#ctl00_MainContent_ddlPrefixDrp option:contains(" + patientTitle[0] + ")").attr("selected", true);
                }
                debugger;

                $('#ddl_colstnt')
                    .empty()
                    .append($('<option>', {
                        value: data.Consultant_ID,
                        text: data.doctor_name
                    }))
                    .val(data.Consultant_ID)
                    .trigger('change')
                    .select2();

                $('#txt_ID').val(data.Appointment_ID);
                $('#txt_pt_name').val(patientTitle[patientTitle.length - 1]);
                $("#ctl00_MainContent_ddlPrefixDrp")
                $('#txt_phone_no').val(data.Phone);
                $('#ctl00_MainContent_ddlPrefixAge').val(agePrefix[0]).change();
                $('#txt_age').val(agePrefix[1]);
                $('#txtRemarks').val(data.Remarks);
                $('#txt_age').val(data.Age);
                $('#txt_apt_no').val(data.Appointment_No);
                $('#hdfreg_ini_id').val(data.Reg_id);

                $('#txt_time').val(data.Time);

                $("#txt_date").datepicker({
                    dateFormat: 'MM d,yy',
                    minDate: 0
                }).attr('readonly', 'readonly');

                date = moment(date).format('LL');
                $("#txt_date").val(date);

                $('#ddlsubdepartment')
                    .empty()
                    .append($('<option>', {
                        value: data.Sub_Department,
                        text: data.Department_name
                    }))
                    .val(data.Sub_Department)
                    .prop('disabled', false)
                    .trigger('change')
                    .select2();

               // $('#ddlsubdepartment').val(data.Sub_Department).trigger('change');

                    $('#ddlServices').val(data.Item_Id).change();



            },

                function (error) {
                    alert(error.get_message());
                });
        }

       

        function loadapptEdit(App_id) {

            PageMethods.loadAppData_edit(App_id, function (resp) {

                if (App_id != "") {
                    $('#btnSave').val('Update');
                }
                var data = JSON.parse(resp);
                var patientTitle = data.Patient_Name.split("_");
                var agePrefix = data.Age.split(" ");
                debugger;
                $('#ddl_colstnt').html(
                    $('<option>', {
                        value: data.Consultant_ID,
                        text: data.doctor_name
                    })
                ).attr('disabled', false);
              //  $('#ddl_colstnt').val(data.Consultant_ID).change();
                $('#txt_ID').val(data.Appointment_ID);
                $('#txt_pt_name').val(data.Patient_Name);

                $('#txt_phone_no').val(data.Phone);
                $('#txt_age').val(data.Age);
                $('#txtRemarks').val(data.Remarks);
                $('#txt_apt_no').val(data.Appointment_No);
                $('#hdfreg_ini_id').val(data.Reg_id);
                $('#txt_time').val(data.Time);
                $('#txt_time').val(data.Time);

                $('#txt_date').attr('readonly', false);
                var date = $.datepicker.formatDate('M/D/Y', new Date(parseInt(data.app_date.substring(6, 19))));
                date = moment(data.app_date).format('LL');
                $('#txt_date').val(date);
                $('#txt_date').attr('readonly', true);
               // $('#ddlsubdepartment').val(data.Sub_Department).trigger('change');
                $('#ddlsubdepartment').html(
                    $('<option>', {
                        value: data.Sub_Department,
                        text: data.Department_name
                    })
                ).attr('disabled', false);
                setTimeout(function () {
                   // $('#ddlsubdepartment').val(data.Sub_Department).change();
                    $('#ddlServices').val(data.Item_Id).change();
                }, 1500);

            },

                function (error) {
                    alert(error.get_message());
                });
            $('#ClosePatientsSearchModel').click();
        }



        function Edit(aID) {
            debugger;
            window.location.href = "Appointment.aspx?aID=" + aID;

        }


        //first form id increment
        function GetAppNo() {
            PageMethods.GetAppNo(function (resp) {
                $('#txt_ID').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });

        }

        function GetAppNoByDoctor() {
            debugger;
            var doctorID = $('#ddl_colstnt').val();
            var checkdate = $('#txt_date').val();
            var aID = '<%= Request.QueryString["aID"]%>';
            if (aID != "") {

            }
            else {
                PageMethods.GetAppNoByDoctor(doctorID, checkdate, function (resp) {
                    debugger;

                    $('#txt_apt_no').val(resp);
                },
                    function (error) {
                        alert(error.get_message());
                    });
            }



        }

        debugger;
        function GetAppointmentTime() {
            debugger;
            var doctorID = $('#ddl_colstnt').val();
            debugger;
            PageMethods.GetAppointmentTime(doctorID, function (resp) {
                debugger;

                $("#txt_time").val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });

        }
        function fillmartial() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetMartailStatus(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddl_status').html(options);

            });
            return options;
        }

        function clearPatient() {

            $('#txt_name').val("");
            $('#txt_relation').val("");
            $('#txt_mobile').val("");
            $('#txt_dob').val("");
            $('#txt_cnic').val("");
            $('#txt_Address').val('');
            //   $('#ddltest_main_dpt').val(0);
            $('#updatePatient_Data').hide();
            $('#RevistPat').hide();
        }
        function GetServices() {
            debugger;
            var options = '<option value="0">Select Services</option>';
            PageMethods.GetServices(function (data) {
                $.each(JSON.parse(data), function (key, value) {

                    if (key >= 0) {
                        options += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                    }
                });
                $('#ddlServices').html(options);
                $('#ddlServices').select2();


            });

        }

        debugger;
        function SavePatient() {
            debugger;
            $('#SavePatient_Data').attr('disabled', true);
            var Prefix_PatientName = $('#ddl_name').val();
            var PatientName = $('#txt_name').val();
            var PatientID = $('#hdfPatient_ID').val();

            var Full_Name = Prefix_PatientName + PatientName;
            debugger;
            var RelationType = $('#ddlRelation').val();
            var Relation = $('#txt_relation').val();
            var Gender = $('#ddl_Gender').val();
            var reg_pat_id = $('#hdfreg_ini_id').val();

            var Mobile = $('#txt_mobile').val();

            var PreFix_DOB = $('#ddl_dob').val();
            var Age = $('#txt_dob').val();
            var Date_Of_Birth = $('#txtAge_yearss').val();

            var CNIC = $('#txt_cnic').val();
            var Address = $('#txt_Address').val();
            var martail_status = $('#ddl_status').val();

            var houseno = $('#txt_house').val();
            var stno = $('#txtstrm').val();
            var city = $('#txtcity :selected').text();
            var area = $('#txtarea :selected').text();
            var Country = $('#ddlCountry :selected').val();
            var city_val = $('#txtcity').val();
            var area_val = $('#txtarea').val();
            var Province = $('#ddl_Province :selected').val();

            if ((PatientName == "" || Mobile == "" || Age == "" || martail_status == "0" || Gender == "0" || Relation == "" || CNIC == "_____-_______-_" || houseno == "" || city_val == "0" || area_val == "0")) {

                Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: 'Please Enter compulsory Fields',
        showConfirmButton: false,
        timer: 2000,
        customClass: {
            popup: 'swal-big-popup',
            title: 'swal-big-title',
            htmlContainer: 'swal-big-text'
        }
        });

                
                $('#SavePatient_Data').attr('disabled', false);
                return;
                // }
            }

            var data = JSON.stringify({
                "Full_Name": Full_Name,
                "RelationType": RelationType,
                "Relation": Relation,
                "Gender": Gender,
                "Mobile": Mobile,
                "Date_Of_Birth": Date_Of_Birth,
                "CNIC": CNIC,
                "Address": Address,
                "houseno": houseno,
                "stno": stno,
                "city": city,
                "city_val": city_val,
                "area_val": area_val,
                "area": area,
                "Province": Province,
                "PatientID": PatientID,
                "martail_status": martail_status,
                "reg_pat_id": reg_pat_id,
                "Age": Age,
                "Country": Country,


            });
            $.ajax({
                type: "POST",
                url: "Appointment.aspx/SavePatientDetails",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var ini_patientID = data.d;
                    Swal.fire({
    icon: 'success',
    title: 'Success!',
    text: 'Your Record Save and Load Successfully.',
    showConfirmButton: false,
    timer: 2500,
    customClass: {
        popup: 'swal-big-popup',
        title: 'swal-big-title',
        htmlContainer: 'swal-big-text'
    }
});

                   
                    $('#PatientModel').modal('hide');

                    get_pat_initial_info(ini_patientID);



                },
                error: function (response) {
                    alert("Error");
                }
            });
        }
        function get_pat_initial_info(ini_patientID) {
            debugger;
            try {
                isAdd = true;
                window.location.href = "Appointment.aspx?ID=" + ini_patientID + "&isAdd=" + isAdd;

            } catch (err) {
                alert(err.message);
            }

        }


        function LoadDetailDoctor(dep) {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetDoctors(dep ,function (data) {
                $.each(JSON.parse(data), function (key, value) {

                    if (key >= 0) {
                        options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                    }
                });
                $('#ddl_colstnt').html(options);

                $('#chk_Doc').html(options);

            });

        }


        var abc = false;
        function testddlchange() {
            debugger;



            var Statusddl = $('#chk_status').find('option:selected').text();

            if (Statusddl == "All") {
                abc = true;
                LoadPage();
            }
            else {
                var tbl = document.getElementById('table_res');
                if (Statusddl.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[7].innerText != Statusddl) {
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


         var acc = false;
         var __tBodyCache = null;
         function toTitleCase(str) {
             return str.replace(/[^a-zA-Z0-9]+(.)/g, function (match) {
                 return match.toUpperCase();
             });
         }

          function ddldocchange() {
              debugger;

              var DocChk = $('#chk_Doc').find('option:selected').text();

              if (DocChk == "Select Doctor") {
                  acc = true;
                  $('#t_body').html(__tBodyCache || '');
                  LoadPage();
              } else {
                  if (__tBodyCache === null) __tBodyCache = $('#t_body').html();
                  var rows = __tBodyCache.split(/<tr[\s>]/i).filter(function (r) { return r.indexOf('</tr>') !== -1; });
                  var kept = [];
                  for (var i = 0; i < rows.length; i++) {
                      if (rows[i].indexOf('>' + DocChk + '<') !== -1) kept.push('<tr ' + rows[i]);
                  }
                  $('#t_body').html(kept.join(''));
              }

              if ($('.wrap.calendar').is(':visible')) {
                  var currentMonthIndex, currentYear;

                  if ($('#calMonthSelect').length && $('#calYearSelect').length) {
                      currentMonthIndex = parseInt($('#calMonthSelect').val(), 10);
                      currentYear = parseInt($('#calYearSelect').val(), 10);
                  }
                  else {
                      var headerText = $('#calendarHeader').text().trim();
                      if (headerText && !headerText.includes('Loading')) {
                          var parts = headerText.split(' ');
                          var monthName = parts[0];
                          currentYear = parseInt(parts[1], 10);
                          currentMonthIndex = moment().month(monthName).format('M') - 1;
                      } else {
                          var now = moment();
                          currentYear = now.year();
                          currentMonthIndex = now.month();
                      }
                  }

                  loadCalendarForMonth(currentYear, currentMonthIndex, DocChk === "Select Doctor" ? null : DocChk);
              }
          }
        function CalculateDateOfBirth() {
            debugger;
            var now = moment();
            var year = $('#txt_dob').val();
            var calculateDate = now.subtract(year, 'years');
            var finalDate = calculateDate.format("DD/MM/YYYY");
            var $datepicker = $('#txtAge_yearss');

            $datepicker.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: "dd/mm/yy"
            });

            $('#txtAge_yearss').unmask("99/99/9999");
            $datepicker.datepicker('setDate', finalDate);
            $('#txtAge_yearss').unmask("99/99/9999");
            $("#txtAge_yearss").mask("99/99/9999");
        }

        function filldepartment() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetDepartment(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlsubdepartment').html(options);

            });
            return options;
        } debugger;
        var save;
        function SaveAllRecord() {
            debugger;

            var btnsave = save;


            var txt_ID = $('#txt_ID').val();
            var txtPatientTitle = $("#ctl00_MainContent_ddlPrefixDrp :selected").text();
            var txt_pt_name = $('#txt_pt_name').val();
            var txt_phone_no = $('#txt_phone_no').val();
            if (txt_phone_no === "___________") {
                txt_phone_no = "";
            }
            var agePrefix = $("#ctl00_MainContent_ddlPrefixAge").val();
            var txt_age = $('#txt_age').val();
            var type = $('#ddlPatient_Type').val();

            var ddl_colstnt = $('#ddl_colstnt').val();
            var txt_apt_no = $('#txt_apt_no').val();
            var txt_date = $('#txt_date').val();
            var txt_time_24hr = $('#txt_time').val();
            var txt_time = convertTo24Hour(txt_time_24hr);
            var reg_id = $('#hdfreg_ini_id').val();

            debugger;
            var subdepartment = $('#ddlsubdepartment').val();
            if (subdepartment == '' || subdepartment == '0' || subdepartment == null) {
                
                Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Mandatory Fields.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                        });

                return true;
            }
            if (txt_time == '' || txt_time == undefined) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Time Slot',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                
                return
            }

            if (txt_time_24hr == '' || txt_time_24hr == undefined) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Roaster Not Defined',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                
                return
            }
            var aptid = '<%= Request.QueryString["aID"]%>';
            debugger;
            PageMethods.CheckDoctorAvailability(ddl_colstnt, txt_date, txt_time, aptid, function (res) {
                debugger;

                if (res === "Doctor not Available") {
                    Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: 'Doctor is not available, Please choose some other Day and time',
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

                else {


                    var editmode_ID = '<%= Request.QueryString["aID"]%>';

                    $('#btnSave').attr('disabled', true);
                    var AllItemDetail = {
                        'txt_ID': txt_ID, 'type': type, 'txt_pt_name': txt_pt_name, 'PatientTitle': txtPatientTitle,
                        'txt_phone_no': txt_phone_no, 'txt_age': txt_age, 'ddl_colstnt': ddl_colstnt,
                        'txt_apt_no': txt_apt_no, 'txt_date': txt_date, 'txt_time': txt_time, 'subdepartment': subdepartment, 'reg_id': reg_id,
                    };

                    PageMethods.SaveAppointment(btnsave, JSON.stringify(AllItemDetail), editmode_ID, function (res) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Appointment Saved!',
                            text: 'A WhatsApp confirmation has been sent automatically.',
                            confirmButtonText: 'OK'
                        }).then(() => {
                            window.location = "Appointment.aspx";
                        });
                    });
                    //for whatsapp integration\



                    //PageMethods.SaveAppointment(btnsave, JSON.stringify(AllItemDetail), editmode_ID, function (res) {
                    //    debugger;

                    //    // Get patient phone and format it for WhatsApp
                    //    var phone = $('#txt_phone_no').val().replace(/-/g, '').replace(/_/g, '');
                    //    var doctorName = $('#ddl_colstnt option:selected').text();
                    //    var appointmentDate = $('#txt_date').val();
                    //    var appointmentTime = $('#txt_time').val();

                    //    // Format phone for Pakistan (add 92 if needed)
                    //    if (phone.length === 11 && phone.startsWith('0')) {
                    //        phone = '92' + phone.substring(1); // 03001234567 → 923001234567
                    //    } else if (phone.length === 10 && phone.startsWith('3')) {
                    //        phone = '92' + phone; // 3001234567 → 923001234567
                    //    }

                    //    // Build WhatsApp message
                    //    var message = "Dear Patient,\n\nYour appointment is confirmed with Dr. " +
                    //        doctorName + " on " + appointmentDate + " at " + appointmentTime +
                    //        ".\n\nThank you!";

                    //    var whatsappUrl = "https://wa.me/  " + phone + "?text=" + encodeURIComponent(message);

                    //    // Show success + WhatsApp option
                    //    Swal.fire({
                    //        icon: 'success',
                    //        title: 'Appointment Saved!',
                    //        html: phone ? 'Click below to send WhatsApp confirmation to <strong>' + phone + '</strong>' : 'Phone number missing.',
                    //        showCancelButton: true,
                    //        confirmButtonText: 'Open WhatsApp',
                    //        cancelButtonText: 'Close',
                    //        customClass: {
                    //            popup: 'swal-big-popup',
                    //            title: 'swal-big-title',
                    //            htmlContainer: 'swal-big-text'
                    //        }
                    //    }).then((result) => {
                    //        if (result.isConfirmed) {
                    //            window.open(whatsappUrl, '_blank');
                    //        }
                    //        window.location = "Appointment.aspx";
                    //    });
                    //});
                }

            });

        }
        debugger;
        function convertTo24Hour(time) {
            debugger;
            var hours = parseInt(time.substr(0, 2));
            var minutes = time.substr(3, 2);
            var period = time.substr(6, 2).toUpperCase();

            if (period === 'PM' && hours < 12) {
                hours = hours + 12;
            }
            if (period === 'AM' && hours === 12) {
                hours = hours - 12;
            }

            var hoursStr = hours < 10 ? '0' + hours : hours; // Pad with zero if single digit
            return hoursStr + ':' + minutes;
        }

        debugger;
        function verifydoctoravail(callback) {
            debugger;
            var ddl_colstnts = $('#ddl_colstnt').val();
            var time_appointment = $('#txt_time').val();
            var date = $('#txt_date').val();

            $.ajax({
                type: "POST",
                url: "Appointment.aspx/CheckDays",
                data: JSON.stringify({
                    'ddl_colstnts': ddl_colstnts,
                    'date': date
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    debugger;
                    var dataaa = JSON.parse(data.d);





                    debugger;
                    if (dataaa && dataaa.Off_Days_Names && dataaa.Off_Days_Names.includes) {
                        var dateObject = new Date(date);
                        var options = { weekday: 'short' };
                        var dayNameShort = dateObject.toLocaleDateString('en-US', options);

                        if (dataaa.Off_Days_Names.includes(dayNameShort)) {
                            
                            Swal.fire({
        icon: 'error',
        title: 'Error!',
        text: 'Doctor Not Available Today',
        showConfirmButton: false,
        timer: 2000,
        customClass: {
            popup: 'swal-big-popup',
            title: 'swal-big-title',
            htmlContainer: 'swal-big-text'
        }
        });
                            callback('OffDay');
                        } else {
                            callback('OnDay');
                        }
                    } else {
                        callback('OnDay');
                    }
                },
                error: function (x, e) {
                    alert(e);
                }
            });
        }


        function convertToMinutes(timeString) {
            var [time, period] = timeString.split(' ');
            var [hours, minutes] = time.split(':');
            hours = parseInt(hours, 10);
            minutes = parseInt(minutes, 10);

            if (period === 'PM' && hours !== 12) {
                hours += 12;
            } else if (period === 'AM' && hours === 12) {
                hours = 0;
            }

            return hours * 60 + minutes;
        }

        function setFocus() {
            document.getElementById("txtSearch").focus();
            $("#txtSearch").focus();
        }
        document.addEventListener("DOMContentLoaded", setFocus);
        (function populateControls() {
            var $month = $('#monthSelect');
            var $year = $('#yearSelect');
            var months = moment.months();
            months.forEach(function (m, i) {
                $month.append('<option value="' + i + '">' + m + '</option>');
            });

            var currentYear = moment().year();
            for (var y = currentYear - 3; y <= currentYear + 3; y++) {
                $year.append('<option value="' + y + '">' + y + '</option>');
            }

            // default to current month/year
            $month.val(moment().month());
            $year.val(currentYear);
        })();

         // Populate controls
         (function populate() {
             var $m = $('#monthSelect'), $y = $('#yearSelect');
             var months = moment.months();
             months.forEach(function (m, i) { $m.append('<option value="' + i + '">' + m + '</option>'); });
             var now = moment();
             var cy = now.year();
             for (var yy = cy - 5; yy <= cy + 5; yy++) $y.append('<option value="' + yy + '">' + yy + '</option>');
             $m.val(now.month()); $y.val(now.year());
         })();

         function toTitleCase(s) { if (!s) return ''; return s.replace(/\w\S*/g, function (t) { return t.charAt(0).toUpperCase() + t.substr(1).toLowerCase(); }); }

         function mapAppointmentsByDate(arr) {
             var map = {};
             (arr || []).forEach(function (r) {
                 var dt = null;
                 if (r.App_Date) {
                     dt = moment(r.App_Date, moment.ISO_8601, true);
                     if (!dt.isValid()) dt = moment(r.App_Date);
                 } else if (r.Time) dt = moment(r.Time);
                 if (!dt || !dt.isValid()) return;
                 var iso = dt.format('YYYY-MM-DD');
                 if (!map[iso]) map[iso] = [];
                 r.cancelAppointment = (r.cancelAppointment === true || r.cancelAppointment === "true" || r.cancelAppointment === "True") ? "true" : "false";
                 map[iso].push(r);
             });
             return map;
         }

         function buildCalendar(year, month, appointmentsByDate) {
              $(document).off('.cal');
              $('#calendar').find('.cal-day, .cal-day.empty').remove();
             var firstOfMonth = moment([year, month, 1]);
             var daysInMonth = firstOfMonth.daysInMonth();
             var startDay = firstOfMonth.day();
             $('#calendarHeader').text(firstOfMonth.format('MMMM YYYY'));

             for (var i = 0; i < startDay; i++) $('#calendar').append('<div class="cal-day empty" aria-hidden="true"></div>');

             for (var d = 1; d <= daysInMonth; d++) {
                 var dayDate = moment([year, month, d]);
                 var iso = dayDate.format('YYYY-MM-DD');
                 var appts = appointmentsByDate[iso] || [];

                 var $day = $('<div class="cal-day" data-date="' + iso + '" role="gridcell" tabindex="0"></div>');
                 var $dateRow = $('<div class="date-row"></div>');
                 var $circle = $('<div class="date-circle">' + d + '</div>');
                 $dateRow.append($circle);
                 $day.append($dateRow);

                 if (appts.length) {
                     var hasCancelled = appts.some(a => a.cancelAppointment === "true");
                     var hasVisited = appts.some(a => a.Status === "Visited");
                     var hasBooked = appts.some(a => a.Status === "Booked");

                     if (hasCancelled) $day.addClass('status-Cancelled');
                     else if (hasVisited) $day.addClass('status-Visited');
                     else if (hasBooked) $day.addClass('status-Booked');

                     var bookedCount = appts.filter(a => a.Status === "Booked" && a.cancelAppointment !== "true").length;
                     var visitedCount = appts.filter(a => a.Status === "Visited").length;
                     var cancelledCount = appts.filter(a => a.cancelAppointment === "true" || a.Status === "Cancelled").length;

                     var $summary = $('<div class="summary" aria-hidden="true"></div>');
                     if (bookedCount) $summary.append('<div class="pill" style="background:linear-gradient(180deg,#fff8e6,#ffecd0);color:#4a3a00">B ' + bookedCount + '</div>');
                     if (visitedCount) $summary.append('<div class="pill" style="background:linear-gradient(180deg,#eaffec,#d7ffd5);color:#0b3f0b">V ' + visitedCount + '</div>');
                     if (cancelledCount) $summary.append('<div class="pill" style="background:linear-gradient(180deg,#ffd6d6,#ffbdbd);color:#670000">C ' + cancelledCount + '</div>');
                     $day.append($summary);

                     var $tooltip = $('<div class="tooltip" role="dialog" aria-label="Appointments for ' + iso + '"></div>');
                     appts.forEach(function (a) {
                         var status = (a.cancelAppointment === "true") ? "Cancelled" : (a.Status || "Unknown");
                         var time = '';
                         if (a.Time) {
                             var mt = moment(a.Time, moment.ISO_8601, true);
                             if (!mt.isValid()) mt = moment(a.Time);
                             time = mt.isValid() ? mt.format('h:mm a') : a.Time;
                         }
                         var doctor = a.emp_name || '';
                         var apptNo = a.Appointment_No || '';
                         var patient = a.Patient_Name ? toTitleCase((a.Patient_Name + '').replace(/_/g, ' ')) : '';

                         var $item = $('<div class="tt-item"></div>');
                         $item.append('<div class="name">' + (patient || 'Unknown') + ' <small style="opacity:.75">(' + apptNo + ')</small></div>');
                         var $meta = $('<div class="meta"></div>');
                         $meta.append('<div>' + (time ? time : '') + (doctor ? ' — ' + doctor : '') + '</div>');
                         var statusClass = (status === "Cancelled") ? 'status-cancel' : (status === "Visited" ? 'status-visited' : 'status-booked');
                         $meta.append('<div class="status-pill ' + statusClass + '">' + status + '</div>');
                         $item.append($meta);
                         $tooltip.append($item);
                     });
                     $day.append($tooltip);

                     $day.attr('aria-label', d + ' ' + firstOfMonth.format('MMMM YYYY') + '. ' + appts.length + ' appointments');
                 } else {
                     $day.append('<div class="no-appointments" aria-hidden="true">No appointments</div>');
                     $day.attr('aria-label', d + ' ' + firstOfMonth.format('MMMM YYYY') + '. No appointments');
                 }

                 // Robust bbox-based hover handler — call this immediately after $day.append($tooltip);
                 // Replace the handler inside buildCalendar with this version:
                 (function ($day) {
                     var $tooltip = $day.find('.tooltip');
                     var SHOW_DELAY = 100;  // Slightly longer to debounce
                     var HIDE_DELAY = 400;
                     var showTimer = null, hideTimer = null;
                     var isTracking = false;

                     function pointInElem(x, y, $el) {
                         if (!$el || !$el.length) return false;
                         var r = $el[0].getBoundingClientRect();
                         return (x >= r.left && x <= r.right && y >= r.top && y <= r.bottom);
                     }

                     function onPointerMove(ev) {
                         var x = ev.clientX, y = ev.clientY;
                         var insideDay = pointInElem(x, y, $day);
                         var insideTip = pointInElem(x, y, $tooltip);

                         if (insideDay || insideTip) {
                             clearTimeout(hideTimer);
                             if (!$day.hasClass('show-tooltip')) {
                                 clearTimeout(showTimer);
                                 showTimer = setTimeout(function () {
                                     $day.addClass('show-tooltip');
                                 }, SHOW_DELAY);
                             }
                         } else {
                             clearTimeout(showTimer);
                             if ($day.hasClass('show-tooltip')) {
                                 hideTimer = setTimeout(function () {
                                     $day.removeClass('show-tooltip');
                                 }, HIDE_DELAY);
                             }
                         }
                     }

                     function startTracking() {
                         if (isTracking) return;
                         isTracking = true;
                         $(document).on('mousemove.cal' + iso, onPointerMove);
                     }

                     function stopTracking() {
                         if (!isTracking) return;
                         isTracking = false;
                         $(document).off('mousemove.cal' + iso);
                         clearTimeout(showTimer);
                         clearTimeout(hideTimer);
                     }

                     var iso = $day.data('date');

                     $day.on('mouseenter', function (ev) {
                         startTracking();
                         onPointerMove(ev);
                     });

                     $day.on('mouseleave', function (ev) {
                         // Don't stop tracking immediately - let onPointerMove handle it
                         setTimeout(function () {
                             var x = ev.clientX, y = ev.clientY;
                             if (!pointInElem(x, y, $day) && !pointInElem(x, y, $tooltip)) {
                                 stopTracking();
                             }
                         }, 50);
                     });

                     if ($tooltip.length) {
                         $tooltip.on('click', function (e) {
                             e.stopPropagation();
                         });
                     }

                     $day.on('click', function (e) {
                         if ($tooltip.length && $(e.target).closest('.tooltip').length === 0) {
                             if ($day.hasClass('show-tooltip')) {
                                 $day.removeClass('show-tooltip');
                                 stopTracking();
                             } else {
                                 $day.addClass('show-tooltip');
                                 startTracking();
                             }
                         }
                     });

                 })($day);

                 $('#calendar').append($day);
             }
         }
         var __aptCache = {};
         function loadCalendarForMonth(year, month, doctorName = null, presetData) {
              var start = moment([year, month, 1]).startOf('day').format('YYYY-MM-DD');
              var end = moment([year, month, 1]).endOf('month').format('YYYY-MM-DD');
              var cacheKey = start + '|' + end;

              $('#calendarHeader').text('Loading appointments...');

              function render(parsed) {
                  if (doctorName && doctorName !== "Select Doctor") {
                      parsed = parsed.filter(function (appt) { return appt.emp_name === doctorName; });
                  }
                  buildCalendar(year, month, mapAppointmentsByDate(parsed));
              }

              if (presetData) { render(presetData); return; }
              if (__aptCache[cacheKey]) { render(__aptCache[cacheKey]); return; }

              if (typeof PageMethods !== 'undefined' && PageMethods.getlist) {
                  PageMethods.getlist(start, end, function (data) {
                      var parsed = [];
                      if (!data || (Array.isArray(data) && data.length === 0)) {
                          parsed = [];
                      } else {
                          try { parsed = (typeof data === 'string') ? JSON.parse(data) : data; }
                          catch (e) { parsed = data || []; }
                      }
                      __aptCache[cacheKey] = parsed;
                      render(parsed);
                  });
              } else {
                 console.warn('PageMethods.getlist not found.');
                 var mock = generateMockDataForMonth(year, month);
                 setTimeout(function () {
                     buildCalendar(year, month, mapAppointmentsByDate(mock));
                 }, 180);
             }
         }

         $('#goBtn').on('click', function () {
             var month = parseInt($('#monthSelect').val(), 10);
             var year = parseInt($('#yearSelect').val(), 10);
             loadCalendarForMonth(year, month);
         });
         $('#todayBtn').on('click', function () {
             var now = moment(); $('#monthSelect').val(now.month()); $('#yearSelect').val(now.year()); loadCalendarForMonth(now.year(), now.month());
         });

         $(function () { var now = moment(); loadCalendarForMonth(now.year(), now.month()); });
         $(function () {
             var $btn = $('#btntoggle');
             var $calendar = $('.calendar');
             var $listContainer = $('.table-container');



             $btn.off('click').on('click', function (e) {
                 e.preventDefault();

                 if ($calendar.is(':visible')) {
                     $calendar.slideUp(250, function () {
                         $listContainer.slideDown(250);
                     });
                     $btn.val('Show Calendar');
                 } else {
                     $listContainer.slideUp(250, function () {
                         $calendar.slideDown(250);
                     });
                     $btn.val('Show List');
                 }
             });
         });


     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />

    <div style="display: none">
        <label>ID</label>
        <input type="text" id="txt_ID" readonly="readonly" />
    </div>
<div class="apt-page">

    <!-- ============ META BAR ============ -->
    <div class="apt-meta-bar">
        <div class="apt-meta-title">
            <i class="fa fa-calendar-plus-o"></i>
            <span>Appointment</span>
            <span class="apt-meta-badge" id="aptStatusBadge">New</span>
        </div>
        <div class="apt-meta-actions">
            <span class="apt-meta-badge"><i class="fa fa-calendar"></i> <%= DateTime.Now.ToString("dd MMM yyyy") %></span>
        </div>
    </div>

    <!-- ============ APPOINTMENT FORM ============ -->
    <input type="hidden" id="hdfreg_ini_id" />
    <input type="hidden" id="txt_ID" readonly="readonly" />
    <input type="hidden" id="txt_apt_no" />
    <input type="hidden" id="txt_time" />

    <div class="apt-layout">

        <!-- Appointment Details Card -->
        <div class="apt-card">
            <div class="apt-card-header">
                <i class="fa fa-calendar"></i>
                <span>Appointment Details</span>
                <span class="apt-card-badge" id="aptBadge">New</span>
            </div>
            <div class="apt-card-body">
                <div class="apt-bento apt-bento--4">
                    <div class="apt-field">
                        <label class="apt-label">Appointment No</label>
                        <input type="text" id="txt_apt_no_disp" class="apt-input apt-input--readonly" readonly="readonly" autocomplete="off" />
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Patient Name</label>
                        <input type="text" id="txt_pt_name" class="apt-input" style="text-transform: capitalize;" autocomplete="off" />
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Phone #</label>
                        <input type="text" id="txt_phone_no" class="apt-input" maxlength="11" autocomplete="off" />
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Age</label>
                        <input type="text" id="txt_age" class="apt-input" autocomplete="off" />
                    </div>
                </div>

                <div class="apt-bento apt-bento--4">
                    <div class="apt-field">
                        <label class="apt-label">Department</label>
                        <select class="apt-select ddldoc" id="ddlsubdepartment">
                            <option></option>
                        </select>
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Consultant</label>
                        <select class="apt-select ddldoc" id="ddl_colstnt">
                            <option></option>
                        </select>
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Date</label>
                        <input type="text" id="txt_date" class="apt-input" onchange="GetAppNoByDoctor()" autocomplete="off" />
                    </div>
                    <div class="apt-field">
                        <label class="apt-label">Time</label>
                        <input type="text" id="txt_time_disp" class="apt-input apt-input--readonly" readonly autocomplete="off" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Time Slots Card -->
        <div class="apt-slots-card">
            <div class="apt-slots-header">
                <i class="fa fa-clock-o"></i>
                <span>Time Slots</span>
            </div>
            <div class="apt-slots-body">
                <div id="slotsGrid" class="slots-grid">
                    <h3>Please Select Patient</h3>
                </div>
            </div>
        </div>
    </div>

    <!-- ============ BUTTON ROW (UNCHANGED) ============ -->
    <div class="row row_2" style="margin-top:1%">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn-primry" id="btnSaveMessage" value="Save & Send Msg"/>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-yellow" id="btnSave" value="Save" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn-gray" value="View" id="btnBack" onclick="window.location = 'AppointmentView.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="window.location = 'Appointment.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-yellow" value="Print" id="btnPrint" onclick="appointmentPatient_Print()" />
        </div>
    </div>

    <!-- ============ FILTER ROW ============ -->
    <div class="apt-filter-row">
        <div class="apt-field">
            <label class="apt-label">From</label>
            <input type="text" id="txt_datefrom" class="apt-input" />
        </div>
        <div class="apt-field">
            <label class="apt-label">To</label>
            <input type="text" id="txt_dateto" class="apt-input" />
        </div>
        <button type="button" id="btnSearch" class="apt-btn-inline"><i class="fa fa-search"></i> Search</button>
        <div class="apt-field">
            <label class="apt-label">Doctor</label>
            <select id="chk_Doc" onchange="ddldocchange()" class="apt-select"></select>
        </div>
        <div class="apt-field">
            <label class="apt-label">Status</label>
            <select id="chk_status" onchange="testddlchange()" class="apt-select">
                <option>All</option>
                <option>Visited</option>
                <option>Booked</option>
            </select>
        </div>
        <button type="button" id="btntoggle" class="apt-btn-inline apt-btn-inline--gray" onclick="toggleCalendar"><i class="fa fa-calendar"></i> Calendar View</button>
    </div>

    <!-- ============ CALENDAR VIEW ============ -->
    <div class="wrap calendar" style="display:none">
        <div class="panel">
            <div class="controls">
                <div>
                    <label for="calMonthSelect">Month:</label>
                    <select id="calMonthSelect"></select>
                </div>
                <div>
                    <label for="calYearSelect">Year:</label>
                    <select id="calYearSelect"></select>
                </div>
                <button id="calGoBtn">Show</button>
                <button id="calTodayBtn" class="muted-btn">Today</button>
            </div>
            <div id="calendarHeader" aria-live="polite"></div>
            <div id="calendar" class="calendar" role="grid" aria-label="Appointment calendar">
                <div class="cal-header">Sun</div>
                <div class="cal-header">Mon</div>
                <div class="cal-header">Tue</div>
                <div class="cal-header">Wed</div>
                <div class="cal-header">Thu</div>
                <div class="cal-header">Fri</div>
                <div class="cal-header">Sat</div>
            </div>
        </div>
    </div>

    <!-- ============ LIST VIEW ============ -->
    <div class="row table-container list">
        <div class="apt-table-container">
            <table class="apt-table" id="table_res">
                <thead>
                    <tr>
                        <th>S No.</th>
                        <th>APPT NO</th>
                        <th>PATIENT NAME</th>
                        <th>DOCTOR NAME</th>
                        <th>PHONE NUMBER</th>
                        <th>DATE</th>
                        <th>TIME</th>
                        <th>STATUS</th>
                        <th style="text-align: center;">ACTIONS</th>
                    </tr>
                </thead>
                <tbody id="t_body"></tbody>
            </table>
        </div>
    </div>

</div>

    <div id="PatientsSearchModel" class="modal fade" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">

                <div class="modal-body">
                    <fieldset class="form-group">
                        <div class="row">
                            <div class="col-lg-3 col-md-3 col-sm-4">
                                <h5>Search Your Patients:</h5>
                                <input type="text" id="txtSearch" class="form-control" autocomplete="off" placeholder="Enter patient name or MR No." />
                            </div>
                            <div class="col-md-2 ">
                                <h5></h5>
                                <input type="button" id="addNewbtn" class="btn-primry" onclick="addfunc()" value="Add New" />
                            </div>
                        </div>
                    </fieldset>

                    <!-- Table of Results -->
                    <div class="table-responsive">
                        <table class="table table-hover table-striped table-bordered" id="tblPatientsResult">
                            <thead>
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Contact No</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="iPatientsBody">
                                <!-- Dynamic rows go here -->
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Modal Footer -->
                <div class="modal-footer">
                    <button type="button" id="patmodalClose" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>


    <div id="PatientModel" class="modal fade-in" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <div class="modal-body">
                        <div class=" row">
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label for="txt_Mrno">MR No</label>
                                <input type="text" id="txt_Mrno" class="form-control" disabled />
                            </div>
                            <div class="col-lg-1 col-md-4 col-sm-6">
                                <label for="ddl_name">Name<span style="color: red;">*</span></label>
                                <select id="ddl_name" class="form-control" style="width:137%">
                                    <option value="Mr.">Mr.</option>
                                    <option value="Mrs.">Mrs.</option>
                                    <option value="Ms.">Ms.</option>
                                    <option value="B/O.">B/O.</option>
                                </select>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label></label>
                                <input name="dob" type="text" id="txt_name" class="form-control" style="margin-top: 6px" />
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                                <select id="ddlRelation" class="form-control">
                                    <option value="S/O">S/O</option>
                                    <option value="W/O">W/O</option>
                                    <option value="D/O">D/O</option>
                                </select>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px">
                                <label></label>
                                <input type="text" id="txt_relation" class="form-control" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label for="PrefixAge">Age/DOB<span style="color: red;">*</span></label>
                                <select id="PrefixAge" class="form-control">
                                    <option value="Year">Year</option>
                                    <option value="Month">Month</option>
                                    <option value="Day">Day</option>
                                </select>
                            </div>
                            <div class="col-lg-1 col-md-4 col-sm-6">
                                <label></label>
                                <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" style="width:137% !important;margin-top: 8px;" />
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6" style="margin-top: 7px;">
                                <label></label>
                                <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd mmyy" />
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label for="ddl_Gender">Gender<span style="color: red;">*</span></label>
                                <select id="ddl_Gender" class="form-control"></select>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label for="txt_cnic">CNIC<span style="color: red;">*</span></label>
                                <input type="text" id="txt_cnic" class="form-control" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                                <input type="text" id="txt_mobile" class="form-control" />
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                                <select id="ddl_status" class="form-control"></select>
                            </div>
                            <div class="col-lg-2 colmd-4 col-sm-6">
                                <label>Country</label>
                                <select id="ddlCountry" class="form-control"></select>
                            </div>
                            <div class="col-lg-3 colmd-4 col-sm-6">
                                <label>Province</label>
                                <select id="ddl_Province" class="form-control"></select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-3 colmd-4 col-sm-6">
                                <label for="txtcity">City</label>
                                <select id="txtcity" class="form-control"></select>
                            </div>
                            <div class="col-lg-3 col-md-4 col-sm-6">
                                <label for="txtarea">Area</label>
                                <select id="txtarea" class="form-control"></select>
                            </div>
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <label for="txt_house">Address</label>
                                <input type="text" id="txt_house" class="form-control" />
                            </div>
                        </div>
                        <div class="form-group row" style="display: none;">
                            <label for="txt_Address" class="col-sm-3 col-form-label">Address<span style="color: red;">*</span></label>
                            <div class="col-sm-9">
                                <input type="text" id="txt_Address" class="form-control" />
                            </div>
                            <div class="col-lg-6 col-md-4 col-sm-6" style="display: none">
                                <label for="txtstrm">St#/Mh#/Rd#/<span style="color: red;">*</span></label>
                                <input type="text" id="txtstrm" class="form-control" />
                            </div>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-primry" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                    <button type="button" class="btn btn-secondary" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                    <button type="button" class="btn btn-danger" id="RevistPat" onclick="SaveRevist_Patient();">Revist</button>
                    <button type="button" class="btn btn-gray" onclick="closemodal" data-dismiss="modal">Close</button>
                </div>
            </div>

        </div>

    </div>





</asp:Content>
