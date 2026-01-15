<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Derma_Appointment.aspx.cs" Inherits="PMS.Derma_Appointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Appointment.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/Tibbit_theme/CustomJs/Appointment.js"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            var txt_apt_no = $('#txt_apt_no').val();

            var dropdowns = [

                { id: '#ddl_Province', method: 'GetProvince' },
                { id: '#txtcity', method: 'GetCity' },
                { id: '#ddlCountry', method: 'GetCountry' },
                { id: '#ddlArea', method: 'GetArea' },
                { id: '#ddl_Gender', method: 'GetGender' },
                { id: '#ddl_status', method: 'GetMartailStatus' },
                { id: '#ddlPatient_Type', method: 'PatientType' },

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


            });

            

            LoadDetailDoctor();
            LoadProcedureFilter();
            LoadMachine();
            LoadHelper();
            LoadRooms();
            $('#ddl_colstnt').on('change', function () {
                ConfigureAvailableDates();
                GetAppNoByDoctor();
                LoadPage();
            });

            $('#ddl_helper').on('change', function () {
                GethelperAvailbilty();
            });

            $('#ddlMachine').on('change', function () {
                GetMachineAvailbilty();
            });

            $('#ddlRoom').on('change', function () {
                GetRoomsAvailbilty();
            });

            $('#ddl_procedures').on('change', function () {
                LoadProcedureTime();
                //ConfigureAvailableDates();
            });
            GetServices();
            //LoadDetailDoctor();

            $('#ddl_colstnt').select2();
            $('#ddl_helper').select2();
            $('#ddlRoom').select2();
            $('#ddlMachine').select2();
            $('#chk_Procedure').select2();

            let isSaving = false;

            function safeSaveAttempt() {
                if (isSaving) {
                    console.warn("Save already in progress. Ignoring duplicate trigger.");
                    return;
                }

                isSaving = true;
                $('#btnSave, #btnSaveMessage').prop('disabled', true).addClass('disabled');
                SaveAllRecord();

            }

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
                    //  LoadDetailDoctor(dep)
                    setTimeout(function () {
                        $('#ddlServices').focus();
                    }, 5);



                });
            }
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

            var ids = '<%= Request.QueryString["aID"]%>';
            var App_id = '<%= Request.QueryString["APPID"]%>';

            if (ids !== "" || App_id !== "") {
                if (ids !== "") loadappt(ids);
                if (App_id !== "") loadapptEdit(App_id);
            } else {
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
            debugger;
            if ($dropdown.data('filled')) return;

            $dropdown.data('filled', false);

            $.ajax({
                type: "POST",
                url: "Derma_Appointment.aspx/" + methodName,
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        debugger;
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
            window.location.href = "Derma_Appointment.aspx";
        }
        

        function ConfigureAvailableDates() {
            debugger;
            var doc_id = $('#ddl_colstnt').val();
            var txt_date = $("#txt_date").val();
            var procTimeSlot = $("#txtProcedureTime").val();

            $.ajax({
                type: "POST",
                url: "Derma_Appointment.aspx/GetAvailableDatesAndTimes",
                data: JSON.stringify({
                    'doc_id': doc_id,
                    'txt_date': txt_date,
                    'procTimeSlot': procTimeSlot
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    var result = JSON.parse(response.d);

                    // If backend returned an error
                    if (result.error) {
                        alert(result.error);
                        $("#txt_stdoctime").val("");
                        $("#txt_enddoctime").val("");
                        return;
                    }

                    // 🔥 Assign TimeIn & TimeOut to input fields
                    $("#txt_stdoctime").val(result.TimeIn);
                    $("#txt_enddoctime").val(result.TimeOut);
                    $("#txt_sthelpertime").val(result.TimeIn);
                    $("#txt_endhelpertime").val(result.TimeOut);
                    $("#txt_stmachinetime").val(result.TimeIn);
                    $("#txt_endmachinetime").val(result.TimeOut);
                    $("#txt_roomStTime").val(result.TimeIn);
                    $("#txt_roomendTime").val(result.TimeOut);


                },

                error: function (xhr, status, error) {
                    console.error("Error fetching available dates:", error);
                }
            });
        }

        function GethelperAvailbilty() {
            debugger;
            var Emp_Id = $("#ddl_helper").val()
            var txt_date = $("#txt_date").val();
            //var helperTimeIn = $("#txt_sthelpertime").val()
            //var helperTimeOut = $("#txt_endhelpertime").val()

            var helperTimeIn = moment($("#txt_stdoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");
            var helperTimeOut = moment($("#txt_enddoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");

            $.ajax({
                type: "POST",
                url: "Derma_Appointment.aspx/CheckHelperAvailability",
                data: JSON.stringify({
                    'Emp_Id': Emp_Id,
                    'txt_date': txt_date,
                    'helperTimeIn': helperTimeIn,
                    'helperTimeOut': helperTimeOut,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    var result = JSON.parse(response.d);

                    // If backend returned an error
                    if (result.error) {
                        alert(result.error);
                        $("#txt_sthelpertime").val("");
                        $("#txt_endhelpertime").val("");
                        return;
                    }

                    // 🔥 Assign TimeIn & TimeOut to input fields
                    //$("#txt_sthelpertime").val(result.TimeIn);
                    //$("#txt_endhelpertime").val(result.TimeOut);

                },

                error: function (xhr, status, error) {
                    console.error("Error fetching available dates:", error);
                }
            });
        }

        function GetRoomsAvailbilty() {
            debugger;
            var Room_Id = $("#ddlRoom").val();
            var txt_date = $("#txt_date").val();
            var RoomTimeIn = moment($("#txt_stdoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");
            var RoomTimeOut = moment($("#txt_enddoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");

            $.ajax({
                type: "POST",
                url: "Derma_Appointment.aspx/CheckRoomsAvailability",
                data: JSON.stringify({
                    'Room_Id': Room_Id,
                    'txt_date': txt_date,
                    'RoomTimeIn': RoomTimeIn,
                    'RoomTimeOut': RoomTimeOut,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    var result = JSON.parse(response.d);

                    // If backend returned an error
                    if (result.error) {
                        alert(result.error);
                        $("#txt_roomStTime").val("");
                        $("#txt_enddoctime").val("");
                        return;
                    }
                    //// 🔥 Assign TimeIn & TimeOut to input fields
                    //$("#txt_stdoctime").val(result.TimeIn);
                    //$("#txt_roomendTime").val(result.TimeOut);
                },

                error: function (xhr, status, error) {
                    console.error("Error fetching available dates:", error);
                }
            });
        }

        function GetMachineAvailbilty() {
            debugger;
            var Mch_Id = $("#ddlMachine").val()
            var txt_date = $("#txt_date").val();

            var MachineTimeIn = moment($("#txt_stdoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");
            var MachineTimeOut = moment($("#txt_enddoctime").val(), ["hh:mm A", "HH:mm"]).format("HH:mm:ss");

            $.ajax({
                type: "POST",
                url: "Derma_Appointment.aspx/CheckMachineAvailability",
                data: JSON.stringify({
                    'Mch_Id': Mch_Id,
                    'txt_date': txt_date,
                    'MachineTimeIn': MachineTimeIn,
                    'MachineTimeOut': MachineTimeOut,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {
                    var result = JSON.parse(response.d);

                    if (result.error) {
                        alert(result.error);
                        $("#txt_stmachinetime").val("");
                        $("#txt_endmachinetime").val("");
                        return;
                    }
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
                url: "Derma_Appointment.aspx/Getmr",
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
                url: "Derma_Appointment.aspx/loadApp_data",
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
            //$('#srchpat').text("Search Your Patients:");
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
            actions += '<a class="tooltips" href="#"  onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
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
                window.location.href = "Derma_Appointment.aspx?ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;

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
                    url: "Derma_Appointment.aspx/ViewLists",
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
                url: 'Derma_Appointment.aspx/GetProvince',
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
                url: 'Derma_Appointment.aspx/GetCity',
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
                url: 'Derma_Appointment.aspx/GetCountry',
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
                url: 'Derma_Appointment.aspx/GetArea',
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
                            var helperStart = data[i].Helper_Start_Time
                                ? moment(data[i].Helper_Start_Time).format('h:mm A')
                                : '';

                            var helperEnd = data[i].Helper_End_Time
                                ? moment(data[i].Helper_End_Time).format('h:mm A')
                                : '';

                            var technicianTime = (helperStart && helperEnd)
                                ? helperStart + ' - ' + helperEnd
                                : 'N/A';

                            if (cancel) {
                                status = 'Cancelled';
                            }

                            rows += '<tr>' +
                                '<td>' + (i + 1) + '</td>' + '<td>' + data[i].Appointment_No + '</td>' + '<td>' + toTitleCase(data[i].Patient_Name.replace("_", " ")) + '</td>' + '<td>' + data[i].emp_name + '</td>' + '<td>' + (data[i].Technician_Name || 'N/A') + '<td>' + technicianTime + '</td>' + '<td>' + (data[i].Procedure_Name || 'N/A') + '</td>' + '<td>' + data[i].Phone + '</td>' + '<td>' + App_Date + '</td>' + '<td name="statusCell">' + status + '</td>' + '<td style="display:none;" name="cancelAppointment">' + data[i].cancelAppointment + '</td>' + '<td style="width: 250px;">' + '<a href="#" onclick="Edit(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px; margin-left: 9px;">Change Schedule</a>' +
                                '<a href="#" onclick="CancelAppointment(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #ea0000; color: white; padding: 4px 11px; margin-left: 9px;">Cancel</a>' +
                                '</td>' +
                                '</tr>';
                        });

                        $('#t_body').html(rows);

                        $('#table_res tbody:eq(1) tr').each(function (key, value) {
                            debugger;
                            var $statusCell = $(this).find('td[name="statusCell"]');
                            var status = $statusCell.text();
                            var app_date = $(this).find('td:eq(5)').text();
                            var cancel = $(this).find('td[name="cancelAppointment"]').text();
                            var currentDate = moment().format('LL');


                            if (status === "Visited") {
                                $statusCell.css('background-color', '#77f577');
                                $(this).find('td:last a').hide();
                            } else if (status === "Booked") {
                                $statusCell.css('background-color', '#ffdc86');
                            }

                            if (cancel === "true") {
                                $statusCell.css('background-color', '#FF6060');
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
                    url: "Derma_Appointment.aspx/CancelAppointment",
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

        function loadappt(App_id) {
            if (!App_id) return;

            PageMethods.loadAppData(App_id, function (resp) {
                var data = JSON.parse(resp);

                $('#btnSave').val('Update');
                $('#txt_pt_name').val(data.Patient_Name || '');
                $('#txt_phone_no').val(data.Phone || '');
                $('#txt_age').val(data.Age || '');
                $('#txtRemarks').val(data.Remarks || '');
                $('#txt_apt_no').val(data.Appointment_No);
                $('#hdfreg_ini_id').val(data.Reg_id || '');
                $('#txt_ID').val(data.Appointment_ID || '');

                setTimeout(() => {
                    $('#ddl_procedures').val(data.Item_Id);
                    $('#ddl_colstnt').val(data.Consultant_ID).prop('disabled', false);
                    $('#ddl_helper').val(data.Helper_Id);
                    $('#ddlMachine').val(data.Machine_Id);
                    $('#ddlRoom').val(data.Room_Id);

                    $('#ddl_procedures, #ddl_colstnt, #ddl_helper, #ddlMachine, #ddlRoom').each(function () {
                        if ($(this).hasClass('select2-hidden-accessible')) {
                            $(this).trigger('change.select2');
                        }
                    });
                }, 2000);

                try {
                    var formattedDate = moment(data.app_date).format('LL');
                    $('#txt_date').val(formattedDate);
                } catch (e) {
                    console.warn('Invalid date:', data.app_date);
                }
                $('#txt_date').attr('readonly', true);

                $('#txt_stdoctime').val(extractTime(data.Doctor_Start_Time));
                $('#txt_enddoctime').val(extractTime(data.Doctor_End_Time));
                $('#txt_sthelpertime').val(extractTime(data.Helper_Start_Time));
                $('#txt_endhelpertime').val(extractTime(data.Helper_End_Time));
                $('#txt_stmachinetime').val(extractTime(data.Machine_Start_Time));
                $('#txt_endmachinetime').val(extractTime(data.Machine_End_Time));
                $('#txt_roomStTime').val(extractTime(data.Room_Start_Time));
                $('#txt_roomendTime').val(extractTime(data.Room_End_Time));

                $('#ClosePatientsSearchModel').click();
            }, function (error) {
                alert('Error loading appointment: ' + error.get_message());
            });
        }
        debugger;

        function extractTime(timeStr) {
            if (!timeStr) return '';

            var clean = ('' + timeStr).trim();

            if (/^\d{1,2}:\d{2}$/.test(clean)) {
                var parts = clean.split(':');
                var h = parseInt(parts[0], 10);
                var m = parts[1];
                if (h >= 0 && h <= 23 && m >= 0 && m <= 59) {
                    return h.toString().padStart(2, '0') + ':' + m;
                }
            }

            var match = clean.match(/(\d{1,2}):(\d{2})\s*(AM|PM)?/i);
            if (match) {
                var hours = parseInt(match[1], 10);
                var minutes = match[2];
                var period = (match[3] || '').toUpperCase();
                if (!period) {
                    if (hours <= 23) {
                        return hours.toString().padStart(2, '0') + ':' + minutes;
                    }
                }

                if (period === 'PM' && hours < 12) hours += 12;
                if (period === 'AM' && hours === 12) hours = 0;

                if (hours >= 0 && hours <= 23) {
                    return hours.toString().padStart(2, '0') + ':' + minutes;
                }
            }

            var fallback = clean.match(/(\d{1,2}):(\d{2})/);
            if (fallback) {
                var h = parseInt(fallback[1], 10);
                var m = fallback[2];
                if (h <= 23 && m <= 59) {
                    return h.toString().padStart(2, '0') + ':' + m;
                }
            }

            console.warn('Unrecognized time format:', timeStr);
            return '';
        }

        debugger;
        function loadapptEdit(App_id) {
            debugger;
            if (!App_id) return;
            PageMethods.loadAppData_edit(App_id, function (resp) {
                debugger;
                var data = JSON.parse(resp);

                $('#btnSave').val('Update');
                $('#txt_pt_name').val(data.Patient_Name || '');
                $('#txt_phone_no').val(data.Phone || '');
                $('#txt_age').val(data.Age || '');
                $('#txtRemarks').val(data.Remarks || '');
                $('#txt_apt_no').val(data.Appointment_No);
                // Consultant (already working)).val(data.Appointment_No || '');
                $('#hdfreg_ini_id').val(data.Reg_id || '');
                $('#txt_ID').val(data.Appointment_ID || '');

                
                setTimeout(() => {
                    $('#ddl_procedures').val(data.Item_Id);
                    $('#ddl_colstnt').val(data.Consultant_ID).prop('disabled', false);
                    $('#ddl_helper').val(data.Helper_Id);
                    $('#ddlMachine').val(data.Machine_Id);
                    $('#ddlRoom').val(data.Room_Id);

                    $('#ddl_procedures, #ddl_colstnt, #ddl_helper, #ddlMachine, #ddlRoom').each(function () {
                        if ($(this).hasClass('select2-hidden-accessible')) {
                            $(this).trigger('change.select2');
                        }
                    });
                }, 2000);

                try {
                    var formattedDate = moment(data.app_date).format('LL');
                    $('#txt_date').val(formattedDate);
                } catch (e) {
                    console.warn('Invalid date:', data.app_date);
                }
                $('#txt_date').attr('readonly', true);

                

                $('#txt_stdoctime').val(extractTime(data.Doctor_Start_Time));
                $('#txt_enddoctime').val(extractTime(data.Doctor_End_Time));
                $('#txt_sthelpertime').val(extractTime(data.Helper_Start_Time));
                $('#txt_endhelpertime').val(extractTime(data.Helper_End_Time));
                $('#txt_stmachinetime').val(extractTime(data.Machine_Start_Time));
                $('#txt_endmachinetime').val(extractTime(data.Machine_End_Time));
                $('#txt_roomStTime').val(extractTime(data.Room_Start_Time));
                $('#txt_roomendTime').val(extractTime(data.Room_End_Time));

                $('#ClosePatientsSearchModel').click();

            }, function (error) {
                alert('Error loading appointment: ' + error.get_message());
            });
        }



        function Edit(aID) {
            debugger;
            window.location.href = "Derma_Appointment.aspx?aID=" + aID;

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
                $('#ddl_procedures').html(options).select2();


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
                url: "Derma_Appointment.aspx/SavePatientDetails",
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

    
        var ProcedureTime = "";   
        function LoadProcedureTime() {
            var procid = $('#ddl_procedures').val();
            PageMethods.GetProcedureTime(procid, function (data) {
                ProcedureTime = JSON.parse(data);  
                $('#txtProcedureTime').val(ProcedureTime);
            });
        }
        function LoadDetailDoctor() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetDoctors(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    if (key >= 0) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    }
                });
                $('#ddl_colstnt').html(options).select2();
                $('#chk_Doc').html(options).select2();
            });
        }

        function LoadRooms() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetRooms(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    if (key >= 0) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    }
                });
                $('#ddlRoom').html(options).select2();
            });
        }

        function LoadMachine() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetMachine(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    if (key >= 0) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    }
                });
                $('#ddlMachine').html(options).select2();
            });
        }

        function LoadHelper() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetHelper(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    if (key >= 0) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    }
                });
                $('#ddl_helper').html(options).select2();
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
                LoadPage();
            } else {
                var tbl = document.getElementById('table_res');
                if (DocChk.trim() != '') {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[3].innerText != DocChk) {
                            var row = tbl.rows[i];
                            row.style.display = 'none';
                        } else {
                            var row = tbl.rows[i];
                            row.style.display = '';
                        }
                    }
                } else {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }
                }
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
            var btnsave = $('#btnSave').val();
            var txt_ID = $('#txt_ID').val();
            var ddl_colstnt = $('#ddl_colstnt').val();
            var ddl_helper = $('#ddl_helper').val();
            var ddlMachine = $('#ddlMachine').val();
            var ddlRoom = $('#ddlRoom').val();
            var txt_apt_no = $('#txt_apt_no').val();
            var txt_date = $('#txt_date').val();
            var txt_time_24hr = $('#txt_time').val();
            var reg_id = $('#hdfreg_ini_id').val();
            var item_id = $('#ddl_procedures').val();



            var Doc_Start_Time = $("#txt_stdoctime").val();
            var Doc_End_Time = $("#txt_enddoctime").val();
            var Helper_Start_Time = $("#txt_sthelpertime").val();
            var Hepler_End_Time = $("#txt_endhelpertime").val();
            var Machine_Start_Time = $("#txt_stmachinetime").val();
            var Machine_End_Time = $("#txt_endmachinetime").val();
            var Room_Start_Time = $("#txt_roomStTime").val();
            var Room_End_Time = $("#txt_roomendTime").val();

            //if (!(Doc_Start_Time === Helper_Start_Time &&
            //    Helper_Start_Time === Machine_Start_Time &&
            //    Machine_Start_Time === Room_Start_Time)) {

            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Doctor, Helper, Machine and Room START TIME must be the same.',
            //        showConfirmButton: false,
            //        timer: 2500,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            //if (!(Doc_End_Time === Hepler_End_Time &&
            //    Hepler_End_Time === Machine_End_Time &&
            //    Machine_End_Time === Room_End_Time)) {

            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Doctor, Helper, Machine and Room END TIME must be the same.',
            //        showConfirmButton: false,
            //        timer: 2500,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}
            var aptid = '<%= Request.QueryString["aID"]%>';
            debugger;
                    var editmode_ID = '<%= Request.QueryString["aID"]%>';

            $('#btnSave').attr('disabled', true);
            var AllItemDetail = {
                'txt_ID': txt_ID, 'ddl_colstnt': ddl_colstnt, 'ddl_helper': ddl_helper, 'ddlMachine': ddlMachine, 'ddlRoom': ddlRoom,
                'txt_apt_no': txt_apt_no, 'txt_date': txt_date, 'reg_id': reg_id
                , 'Doc_Start_Time': Doc_Start_Time, 'Doc_End_Time': Doc_End_Time
                , 'Helper_Start_Time': Helper_Start_Time, 'Hepler_End_Time': Hepler_End_Time
                , 'Machine_Start_Time': Machine_Start_Time, 'Machine_End_Time': Machine_End_Time
                , 'Room_Start_Time': Room_Start_Time, 'Room_End_Time': Room_End_Time, 'item_id': item_id
            };

            PageMethods.SaveAppointment(btnsave, JSON.stringify(AllItemDetail), editmode_ID, function (res) {
                Swal.fire({
                    icon: 'success',
                    title: 'Appointment Saved!',
                    text: 'Data has been saved Successfully',
                    confirmButtonText: 'OK'
                }).then(() => {
                    window.location = "Derma_Appointment.aspx";
                });
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
                url: "Derma_Appointment.aspx/CheckDays",
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

        function loadCalendarForMonth(year, month, doctorName = null) {
            var start = moment([year, month, 1]).startOf('day').format('YYYY-MM-DD');
            var end = moment([year, month, 1]).endOf('month').format('YYYY-MM-DD');

            $('#calendarHeader').text('Loading appointments...');

            if (typeof PageMethods !== 'undefined' && PageMethods.getlist) {
                PageMethods.getlist(start, end, function (data) {
                    var parsed = [];
                    if (!data || (Array.isArray(data) && data.length === 0)) {
                        parsed = [];
                    } else {
                        try {
                            parsed = (typeof data === 'string') ? JSON.parse(data) : data;
                        } catch (e) {
                            parsed = data || [];
                        }
                    }

                    if (doctorName && doctorName !== "Select Doctor") {
                        parsed = parsed.filter(function (appt) {
                            return appt.emp_name === doctorName;
                        });
                    }

                    var mapped = mapAppointmentsByDate(parsed);
                    buildCalendar(year, month, mapped);
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

        function LoadProcedureFilter() {
            var options = '<option value="">All Procedures</option>';
            PageMethods.GetServices(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                });
                $('#chk_Procedure').html(options);
            });
        }

        function filterByProcedure() {
            var procId = $('#chk_Procedure').val();
            var $rows = $('#table_res tbody tr');

            if (!procId) {
                $rows.show();
                return;
            }

            $rows.each(function () {
                var rowProcId = $(this).find('td:eq(6)').text().trim(); 
                var rowProcName = $(this).find('td:eq(6)').text().trim();
                var selectedProcName = $('#chk_Procedure option:selected').text();

                if (selectedProcName === "All Procedures" || rowProcName === selectedProcName) {
                    $(this).show();
                } else {
                    $(this).hide();
                }
            });
        }
    
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />

    <div style="display: none">
        <label>ID</label>
        <input type="text" id="txt_ID" readonly="readonly" />
    </div>
    <div class="row">
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-6">
                <input type="hidden" id="hdfreg_ini_id" />
                <label>Appointment Number</label>
                <input type="text" id="txt_apt_no" class="form-control" readonly="readonly" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Patient Name</label>
                <input type="text" id="txt_pt_name" class="form-control" style="text-transform: capitalize;" autocomplete="off" />
                <input type="hidden" id="Pat_Id" class="form-control" style="text-transform: capitalize;" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Phone #</label>
                <input type="text" id="txt_phone_no" class="form-control" maxlength="11" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Age</label>
                <input type="text" id="txt_age" class="form-control" autocomplete="off" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Procedure</label>
                <select class="form-control" id="ddl_procedures">
                    <option></option>
                </select>
                <input type ="hidden" id="txtProcedureTime" name ="txtProcedureTime" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Date</label>
                <input type="text" id="txt_date" class="form-control" onchange="GetAppNoByDoctor()" autocomplete="off" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Consultant</label>
                <select class="ddldoc form-control" id="ddl_colstnt">
                    <option></option>
                </select>
            </div>

            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Technician</label>
                <select class="form-control" id="ddl_helper">
                    <option></option>
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Machine</label>
                <select class="form-control" id="ddlMachine">
                    <option></option>
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label>Room</label>
                <select class="form-control" id="ddlRoom">
                    <option></option>
                </select>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
            </div>
        </div>
        <div class="row">
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_stdoctime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_enddoctime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_sthelpertime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_endhelpertime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_stmachinetime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_endmachinetime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_roomStTime" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-6">
                <input type="time" id="txt_roomendTime" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-9 col-md-10 col-sm-12">
                <div class="row row_2" style="margin-top: 1%">
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn-primry" id="btnSaveMessage" value="Save & Send Msg" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" id="btnSave" value="Save" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn-gray" value="View" id="btnBack" onclick="window.location = 'Derma_Appointment_list.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="window.location = 'Derma_Appointment.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" value="Print" id="btnPrint" onclick="appointmentPatient_Print()" />
                    </div>
                </div>
            </div>
        </div>


    </div>
    <div class="row ">       
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label>From</label>
            <input type="text" id="txt_datefrom" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label style="margin-left: 15px!important">To</label>
            <input type="text" id="txt_dateto" />
        </div>       
        <div class="col-lg-1 col-md-2 col-sm-3">
            <label></label>
            <input type="button" id="btnSearch" class="btn btn-primry" value="Search" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Doctor</label>
            <select id="chk_Doc" onchange="ddldocchange()">
            </select>
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4 mg">
            <label>Procedure</label>
            <select id="chk_Procedure" onchange="filterByProcedure()">
                <option value="">All Procedures</option>
            </select>
        </div>
        <div class="col-lg-1 col-md-3 col-sm-4 mg">
            <label></label>
            <select id="chk_status" onchange="testddlchange()">
                <option>All</option>
                <option>Visited</option>
                <option>Booked</option>
            </select>
        </div>
        <div class="col-lg-1 col-md-2 col-sm-3">
            <label></label>
            <input type="button" id="btntoggle" class="btn btn-primry" onclick="toggleCalendar" value="Calendar View" />
        </div>


    </div>
   <div class="wrap calendar" style="display: none">
  <div class="panel">
    <div class="controls" style="margin-bottom: 15px; display: flex; gap: 10px; align-items: center;">
        <div class="col-lg-2 col-md-6 cl-sm-12">
            <label for="calMonthSelect">Month:</label>
            <select id="calMonthSelect"></select>
        </div>
        <div class="col-lg-2 col-md-6 cl-sm-12">
            <label for="calYearSelect">Year:</label>
            <select id="calYearSelect"></select>
        </div>
      <button id="calGoBtn" class="btn btn-primry" style="padding: 4px 10px;">Show</button>
      <button id="calTodayBtn" class="btn btn-gray" style="padding: 4px 10px;">Today</button>
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
                <!-- day cells will be injected here -->
            </div>
        </div>
    </div>
    <div class="row table-container list">

        <table class="table" id="table_res" style="margin-left: 11px !important">
            <thead>
            <tr id="row_sample">
                <th>S No.</th>
                <th>APPT NO</th>
                <th>PATIENT NAME</th>
                <th>DOCTOR NAME</th>
                <th>Technician Name</th>
                <th>Technician Time</th>
                <th>PROCEDURE</th>
                <th>PHONE NUMBER</th>
                <th>DATE</th>
                <th>STATUS</th>
                <th style="text-align: center;">ACTIONS</th>


            </tr>
                </thead>
            <tbody id="t_body">
            </tbody>

        </table>



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
                                <select id="ddl_name" class="form-control" style="width: 137%">
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
                                <input type="text" id="txt_dob" class="form-control" placeholder="DOB" onchange="CalculateDateOfBirth();" style="width: 137% !important; margin-top: 8px;" />
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
