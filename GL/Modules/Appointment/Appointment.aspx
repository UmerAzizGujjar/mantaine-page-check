<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Appointment.aspx.cs" Inherits="PMS.Appointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/CustomCss/Appointment.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;

            filldepartment();
            fillProvince();
            fillCity();
            fillCountry();
            fillArea();
            $('#chk_status').select2();
            $('#ddlsubdepartment').select2();
            $('#btnSave').on('click', function () {
                debugger;
                verifydoctoravail(function (result) {
                    debugger;

                    if (result === 'OnDay') {
                        save = $('#btnSave').val();
                        SaveAllRecord();
                    } else if (result === 'OffDay') {
                        return false;
                    }
                });

            });
            debugger;
            $("#txtSearch").keypress(function (event) {

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

            $('#btnSaveMessage').on('click', function () {
                verifydoctoravail(function (result) {
                    debugger;

                    if (result === 'OnDay') {
                        save = $('#btnSave').val();
                        SaveAllRecord();
                    } else if (result === 'OffDay') {
                        return false;
                    }
                });

            });


            debugger;
            var App_id = '<%= Request.QueryString["APPID"]%>';
            if (App_id != "") {

                loadapptEdit(App_id);
            }
            else {

            }


            fillgender();
            fillmartial();
            fillType();


            debugger;
            $('#ddl_colstnt').on('change', function () {
                debugger;
                var doctor_id = $('#ddl_colstnt').val();
                var aID = '<%= Request.QueryString["aID"]%>';
                if (aID != "") {

                }
                else {
                    GetAppNoByDoctor();
                }

                GetSubDepartmentByDoctor(doctor_id);
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
            $('#ddlsubdepartment').on('change', function () {
                debugger;


                setTimeout(function () {
                    $('#ddlServices').focus();
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

            LoadDetailDoctor();
            LoadPage();
            getpage();




            $('#ddl_colstnt').select2();

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
                $('#srchpat').text("Search By Phone No");

                jQuery(function ($) {
                    MaskedInput({
                        elm: document.getElementById('txtSearch'),
                        format: '+92__________',
                        separator: '-'
                    });
                    var phoneInput = document.getElementById('txtSearch');
                    var cursorPosition = 3;
                    phoneInput.setSelectionRange(cursorPosition, cursorPosition);

                });
            }

            if (ids !== "") {
                var appID = '<%= Request.QueryString["aID"]%>';

                setTimeout(function () {
                    loadappt(appID);

                }, 3000);



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
        });
        function GetSubDepartmentByDoctor(doctor_Id) {
            PageMethods.GetSubDepartmentByDoctor(doctor_Id, function (data) {
                var options = '';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Department + '" >' + value.Departments + '</option>';
                });
                $('#ddlsubdepartment').html(options);
                $('#ddlsubdepartment').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }
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
                alert("Please Enter Complete Mobile Number First");
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
            actions += '<a class="tooltips" style="color:#438eb9 ;font-size:16px;" href="#"  onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i><span class="tooltiptxt">Add</span></a>';
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

                            rows += '<tr>' +
                                '<td>' + (i + 1) + '</td>' + '<td>' + data[i].Appointment_No + '</td>' + '<td>' + toTitleCase(data[i].Patient_Name.replace("_", " ")) + '</td>' + '<td>' + data[i].emp_name + '</td>' + '<td>' + data[i].Phone + '</td>' + '<td>' + App_Date + '</td>' + '<td>' + time + '</td>' + '<td name="statusCell">' + status + '</td>' + '<td style="display:none;" name="cancelAppointment">' + data[i].cancelAppointment + '</td>' + '<td style="width: 250px;">' + '<a href="#" onclick="Edit(' + data[i].Appointment_ID + ')" style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px; margin-left: 9px;">Change Schedule</a>' +
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
                    url: "Appointment.aspx/CancelAppointment",
                    data: JSON.stringify({ appointmentId: appointmentId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        alert('Appointment canceled successfully');

                        location.reload();

                    },
                    error: function (xhr, status, error) {

                        alert('Failed to cancel the appointment. Please try again.');
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
                $('#ddl_colstnt').val(data.Consultant_ID).change();
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

                setTimeout(function () {
                    debugger;

                    $('#ddlsubdepartment').val(data.Sub_Department).change();

                    $('#ddlServices').val(data.Item_Id).change();

                }, 1500);

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

                $('#ddl_colstnt').val(data.Consultant_ID).change();
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
                setTimeout(function () {


                    $('#ddlsubdepartment').val(data.Sub_Department).change();

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


                alert("Please Enter compulsory Fields");
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

                    alert('Your Record Save and Load Successfully');
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


        function LoadDetailDoctor() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            PageMethods.GetDoctors(function (data) {
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
                alert("Please select Sub departmet");
                return true;
            }
            if (txt_time == '' || txt_time == undefined) {
                alert('Please Select Slot')
                return
            }
            if (txt_time_24hr == '' || txt_time_24hr == undefined) {
                alert('Roaster Not Defined')
                return
            }
            var aptid = '<%= Request.QueryString["aID"]%>';
            debugger;
            PageMethods.CheckDoctorAvailability(ddl_colstnt, txt_date, txt_time, aptid, function (res) {
                debugger;

                if (res === "Doctor not Available") {

                    alert("Doctor is not available, Please choose some other Day and time");
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
                        debugger;
                        alert('Data Save Successfully');
                        window.location = "Appointment.aspx";

                    });

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
                            alert('Doctor Not Available Today');
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

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />

    <div style="display: none">
        <label>ID</label>
        <input type="text" id="txt_ID" readonly="readonly" />
    </div>
    <div class="row">

        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <input type="hidden" id="hdfreg_ini_id" />
                    <label>Appointment Number</label>
                    <input type="text" id="txt_apt_no" class="form-control" readonly="readonly" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Patient Name</label>
                    <input type="text" id="txt_pt_name" class="form-control" style="text-transform: capitalize;" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Phone #</label>
                    <input type="text" id="txt_phone_no" class="form-control" maxlength="11" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Age</label>
                    <input type="text" id="txt_age" class="form-control" autocomplete="off" />
                </div>
            </div>
            <div class="row">
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Consultant</label>
                    <select class="ddldoc form-control" id="ddl_colstnt" disabled>
                        <option></option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label style="">Department</label>
                    <select style="border-radius: 5px; height: 29px;" class="form-control ddldoc" id="ddlsubdepartment" disabled>
                        <option></option>
                    </select>
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Date</label>
                    <input type="text" id="txt_date" class="form-control" onchange="GetAppNoByDoctor()" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                    <label>Time</label>
                    <input type="text" readonly id="txt_time" class="form-control" autocomplete="off" />
                </div>
                <div class="col-lg-3 col-md-3 col-sm-6">
                </div>
            </div>
     
            <div class="row row_2" style="margin-top:1%">
                <div class="col-lg-2 col-md-4 col-sm-6">
                   <input type="button" class="btn-primry" id="btnSaveMessage" value="Save & Send Msg"/>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn-primry" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn-gray" value="View" id="btnBack" onclick="window.location = 'AppointmentView.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="window.location = 'Appointment.aspx'" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn-primry" value="Print" id="btnPrint" onclick="appointmentPatient_Print()" />
                </div>
            </div>
        </div>
       <div class="col-lg-4 col-md-4 col-sm-4">
            <div class="col-lg-3">
                <div class="slot-container card" style="overflow: auto; width: 365px; height: 240px;">
                    <h5 class="timeslotheaders">Time Slots</h5>
                    <hr style="border: 1px solid #C4C4C4;">
                    <div id="slotsGrid" class="slots-grid">
                        <h3>Please Select Patient</h3>
                    </div>
                </div>
            </div>
        </div>



    </div>
    <div class="row ">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Doctor</label>
            <select id="chk_Doc" onchange="ddldocchange()">
            </select>
        </div>


        <div class="col-lg-2 col-md-3 col-sm-4">
            <label>From</label>
            <input type="text" id="txt_datefrom" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label style="margin-left: 15px!important">To</label>
            <input type="text" id="txt_dateto" />
        </div>
      
        <div class="col-lg-2 col-md-3 col-sm-4 mg">
            <label></label>
            <select id="chk_status" onchange="testddlchange()">
                <option>All</option>
                <option>Visited</option>
                <option>Booked</option>
            </select>
        </div>
          <div class="col-lg-1 col-md-2 col-sm-3">
            <label></label>
            <input type="button" id="btnSearch" class="btn btn-primry" value="Search" />
        </div>


    </div>

    <div class="row table-container">

        <table class="table" id="table_res" style="margin-left:11px !important">

            <tr id="row_sample">
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
