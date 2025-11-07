<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentAttendance.aspx.cs" Inherits="PMS.StudentAttendance" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">


        $(document).ready(function () {
            $('#Practical').hide();
            $('#lblsubjtype').hide();
            UserRoless();

            var dropdowns = [
                { id: '#program', method: 'GetProgram' },
             
                { id: '#ddlBatch', method: 'StudentBatch' },
                { id: '#ddlGroup', method: 'StudentGroup' },
                { id: '#Class', method: 'GetClass' },
                {
                    id: '#ddlBlock',
                    method: 'GetAcademicBlockByWeek',
                    dependsOn: ['#ddlWeek']
                },
                {
                    id: '#ddlModule',
                    method: 'GetAcademicModuleByWeek',
                    dependsOn: ['#ddlWeek']
                }
            ];

            $('#ddldate').select2();
            $('#Subject').select2();
            $('#Time').select2();

            dropdowns.forEach(item => {
                const $element = $(item.id);
                $element.select2();
                $element.data('lastParams', null);

                $element.off('select2:opening').on('select2:opening', function (e) {
                    const params = item.getParams ? item.getParams() : null;

                    let needsFetch = false;

                    if (!$element.data('filled')) {
                        needsFetch = true;
                    } else if (item.dependsOn && item.getParams) {
                        const currentParamString = JSON.stringify(params || {});
                        const lastParamString = $element.data('lastParams') || "{}";

                        if (currentParamString !== lastParamString) {
                            needsFetch = true;
                        }
                    }

                    if (needsFetch) {
                        e.preventDefault();
                        $element.data('shouldReopen', true);
                        if (params && item.dependsOn) {
                            let missing = false;
                            item.dependsOn.forEach(dep => {
                                const depVal = $(dep).val();
                                if (!depVal || depVal === "0" || depVal === "") {
                                    missing = true;
                                }
                            });
                            if (missing) {
                                $element.html('<option value="">Please select dependencies first</option>').trigger('change.select2');
                                return;
                            }
                        }
                        fillDropdown($element, item.method, null, params, function () {
                            if (params) {
                                $element.data('lastParams', JSON.stringify(params));
                            }
                        });
                    }
                });

                $element.off('select2:select').on('select2:select', function () {
                    $element.data('shouldReopen', false);
                    if (typeof item.onSelect === 'function') {
                        item.onSelect($element);
                    }
                });
            });

            $('#program').on('change', Selectfunc);

            



            $('#ddldate').on("change", function () {
                debugger;
                program = $('#program').val();
                classs = $('#Class').val();
                week = $('#ddlWeek').val();
                date = $('#ddldate').val();
              
                GetSubject();

            });


      

            $('#Subject').on("change", function () {
                debugger;

                Prac = $('#Practical').val();
                Subj = $('#Subject').val();
                GetTime();
            })

            $('#Practical').on("change", function () {
                debugger;
                Prac = $('#Practical').val();
                Subj = $('#Subject').val();
                GetTime();
            });


       

            $('#ddlWeek').on("change", function () {
                debugger;
                clas = $('#Class').val();
                prgrm = $('#program').val();
                week = $('#ddlWeek').val();
                Getnewdate();

                const selectedWeek = $(this).val();
                if (selectedWeek && selectedWeek !== "0") {
                    fillDropdown($('#ddlBlock'), 'GetAcademicBlockByWeek', null, { week: selectedWeek });
                    fillDropdown($('#ddlModule'), 'GetAcademicModuleByWeek', null, { week: selectedWeek });
                } else {
                    $('#ddlBlock').html('<option value="">Select Week First</option>').trigger('change.select2');
                    $('#ddlModule').html('<option value="">Select Week First</option>').trigger('change.select2');
                }
            });
            $('#Class').on("change", function () {
                const selectedClas = $(this).val();
                const selectedProgram = $('#program').val();

                if (selectedClas && selectedClas !== "0") {
                    fillDropdown(
                        $('#ddlWeek'),
                        'GetWeekByClass',
                        null,
                        {
                            std_Class: selectedClas,   // ✅ must match WebMethod param name
                            std_program: selectedProgram  // ✅ must match WebMethod param name
                        }
                    );
                } else {
                    $('#ddlWeek').html('<option value="">Select Week First</option>').trigger('change.select2');
                }
            });





            $('#Time').on("change", function () {
                debugger;
                program = $('#program').val();
                classs = $('#Class').val();
                StudId = $('#Time option:selected').text();
                var Time = StudId.split("-");
                FromTime = Time[0];
                ToTime = Time[1];
                GetAttendaceDetail();
            });


            $('#Update').hide();
            $('#Save').attr("disabled", true);
            $('#AttendanceProc').attr("disabled", true);
            $('#btnPrint').attr("disabled", true);

            $('[id*=Present]').on('click', function () {
                debugger;
                var isTrue = $('[id=Present]').is(':checked');
                if (isTrue) {
                    debugger;
                    $('.chckP').prop('checked', true);
                    $('.chckL').prop('checked', false);
                    $('.chckA').prop('checked', false);


                }
                else {
                    debugger;
                    $('.chckP').prop('checked', false);
                }
            });

            $('[id*=Leave]').on('click', function () {
                debugger;
                var isTrue = $('[id=Leave]').is(':checked');
                if (isTrue) {
                    $('.chckL').prop('checked', true);
                    $('.chckA').prop('checked', false);
                    $('.chckP').prop('checked', false);



                }
                else {
                    $('.chckL').prop('checked', false);
                }
            });

            $('[id*="Absent"]').on('click', function () {

                var isTrue = $('#Absent').is(':checked');
                if (isTrue) {

                    $('.chckP').prop('checked', false);
                    $('.chckL').prop('checked', false);
                    $('.chckA').prop('checked', true);
                }
                else {
                    $('.chckA').prop('checked', false);
                }
            });

            $('[id*="Getrow"]').on('click', function () {
                debugger;
                var isTrue = $('#Getrow').is(':checked');
                if (isTrue) {
                    debugger;
                    $('.chckrow').prop('checked', true);
                }
                else {
                    debugger;
                    $('.chckrow').prop('checked', false);
                }
            });

            $('#ddlBatch').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 != "") {
                    debugger;
                    $('#txt_WholeClass').attr('disabled', true);
                    $('#ddlGroup').attr('disabled', true);
                }

            });
            $('#ddlBatch').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 == "Select" || subject1 == 'Select') {
                    debugger;
                    $('#txt_WholeClass').attr('disabled', false);
                    $('#ddlGroup').attr('disabled', false);
                    $('#ddlBatch').attr('disabled', false)
                }

            });





            $('#ddlGroup').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 != "") {
                    debugger;
                    $('#txt_WholeClass').attr('disabled', true);
                    $('#ddlBatch').attr('disabled', true);
                }
            });


            $('#ddlGroup').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 == "Select" || subject1 == 'Select') {
                    debugger;
                    $('#txt_WholeClass').attr('disabled', false);
                    $('#ddlGroup').attr('disabled', false);
                    $('#ddlBatch').attr('disabled', false)
                }

            });


            $('#txt_WholeClass').on('change', function () {
                debugger;

                if ($('#txt_WholeClass').is(':checked')) {
                    $('#ddlBatch').attr('disabled', true)
                    $('#ddlGroup').attr('disabled', true);
                }
                else {
                    $('#ddlBatch').attr('disabled', false)
                    $('#ddlGroup').attr('disabled', false)
                }
            })


            debugger;
            $("#txt_WholeClass").prop('checked', true)
        })

            function Selectfunc() {
                var currentYear = new Date().getFullYear();
                var slct_value = $("#program").val() || "";
                var pid = slct_value.replace(/^0+/, '') || slct_value;
                var $ddlClass = $('#Class');
                var all = $ddlClass.data('allOptions') || [];

                if (!all.length) {
                    fillDropdown($ddlClass, 'GetClass', Selectfunc, false);
                    return;
                }

                var allowedIndexes;

                if (pid === '2') {
                    allowedIndexes = [1, 2, 3, 4, 5];
                    $('#Class').val(currentYear + '-' + (currentYear + 5));
                }
                else if (pid === '1') {
                    allowedIndexes = [1];
                    $('#Class').val(currentYear + '-' + (currentYear + 2));
                }
                else if (pid === '3') {
                    allowedIndexes = [1, 2, 3, 4];
                    $('#Class').val(currentYear + '-' + (currentYear + 1));
                }
                else {
                    allowedIndexes = [];
                    for (var i = 1; i < all.length; i++) {
                        allowedIndexes.push(i);
                    }
                    $('#Class').val('');
                }

                let newHtml = `<option value="${all[0].DataValue_Name}">${all[0].DataValue_Description}</option>`;
                allowedIndexes.forEach(idx => {
                    if (all[idx]) {
                        newHtml += `<option value="${all[idx].DataValue_Name}">${all[idx].DataValue_Description}</option>`;
                    }
                });

                $ddlClass.html(newHtml).val('').trigger('change');
            }

        

        function fillDropdown($dropdown, methodName, callback, params = null) {
            if ($dropdown.data('filled') && !params) { 
                if (callback) callback();
                return;
            }

            $dropdown.html('<option value="">Loading...</option>').trigger('change.select2');
            var currentValue = $dropdown.val();

            var requestData = params ? JSON.stringify(params) : '{}';

            $.ajax({
                type: "POST",
                url: "StudentAttendance.aspx/" + methodName,
                data: requestData,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        const allOptions = [{ DataValue_Name: "", DataValue_Description: "Select" }].concat(data);

                        $dropdown.data('allOptions', allOptions);

                        let optionsHtml = '';
                        allOptions.forEach(opt => {
                            const value = opt.Std_Id || opt.DataValue_Name;
                            const text = (opt.FromTime && opt.ToTime)
                                ? `${moment(opt.FromTime).format('h:mm a')} - ${moment(opt.ToTime).format('h:mm a')}`
                                : (opt.Date && opt.Day_Name)
                                    ? `${opt.Day_Name} - ${moment(new Date(parseInt(opt.Date.substr(6)))).format('DD-MM-YY')}`
                                    : opt.DataValue_Description || "Unknown";

                            const sel = value === currentValue ? ' selected="selected"' : '';
                            optionsHtml += `<option value="${value}"${sel}>${text}</option>`;
                        });

                        $dropdown.html(optionsHtml).data('filled', true).trigger('change.select2');

                        if ($dropdown.data('shouldReopen')) {
                            $dropdown.data('shouldReopen', false);
                            setTimeout(() => {
                                $dropdown.select2('open');
                            }, 50);
                        }

                        if (callback) callback();
                    } catch (e) {
                        console.error("Error parsing dropdown data:", e);
                        $dropdown.data('filled', false);
                        $dropdown.html('<option value="">Error loading</option>').trigger('change.select2');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    $dropdown.data('filled', false);
                    $dropdown.html('<option value="">Load failed</option>').trigger('change.select2');
                }
            });
        }
        var GetStudentweek;
        function Get_Week() {
            var std_program = $('#program').val();
            var std_Class = $('#Class').val();
           
            
            debugger;
            GetStudentweek = '';
            $.ajax({
                url: 'StudentAttendance.aspx/GetWeeks',
                data: JSON.stringify({
                    "std_program": std_program,
                    "std_Class": std_Class
                   
                }),
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: true,

                success: function (data) {
                    GetStudentweek = '<option value="0">Please Select</option>';
                    debugger;
                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;
                        GetStudentweek += '<option value="' + value.Weeks + '" >' + value.Week_text + '</option>';
                    });
                    $('#ddlWeek').html(GetStudentweek).trigger('change.select2');
                },
            });
        }
       

        var classs;
        var program;
        var GetStudentSubject;
        var date;
        function GetSubject() {
            var block = $('#ddlBlock').val();
            var module = $('#ddlModule').val();
            var dt = new Date(parseInt(date.substr(6)));
            dt = moment(dt).format('L');
            debugger;
            Getgrp = '';
            $.ajax({
                url: 'StudentAttendance.aspx/GetSubj',
                data: JSON.stringify({
                    "program": program,
                    "classs": classs,
                    "week": week,
                    "block": block,
                    "module": module,
                    "date": dt
                }),
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: true,

                success: function (data) {
                    GetStudentSubject = '<option value="0">Please Select</option>';
                    debugger;
                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;
                        GetStudentSubject += '<option value="' + value.Subject_Detail_ID + '" >' + value.Subject_Name + '</option>';
                    });
                    $('#Subject').html(GetStudentSubject).trigger('change.select2');
                },
            });
        }

        var Subjet = '';
        function GetSubjectType() {
            var optionsDepth = '';
            $.ajax({
                type: "post",
                url: "StudentAttendance.aspx/GetSubjectType",
                data: JSON.stringify({
                    "Subject": Subjet,
                    "classs": classs,
                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    optionsDepth = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        optionsDepth += '<option value="' + value.Practical + '" >' + value.prac + '</option>';
                    });
                    $('#Practical').html(optionsDepth);
                },
            });
        }

        

        var Subj;
        var Prac;
        var block;
        var Module;
        function GetTime() {
            var getTime = '';
            var dat = $('#ddldate').val();
            var block = $('#ddlBlock').val();
            var Module = $('#ddlModule').val();
            var dt = new Date(parseInt(dat.substr(6)));
            dt = moment(dt).format('L');
            debugger;
            $.ajax({
                url: 'StudentAttendance.aspx/GetTime',
                data: JSON.stringify({
                    "sub": Subj,
                    "practical": Prac,
                    "classs": classs,
                    "week": week,
                    "block": block,
                    "Module": Module,
                    "date": dt,
                    
                }),
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    getTime = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;
                        var Fromtime = moment(value.FromTime).format('h:mm a');
                        var Totime = moment(value.ToTime).format('h:mm a');
                        getTime += '<option value="' + value.Std_Id + '" >' + Fromtime + ' - ' + Totime + '</option>';
                    });
                    $('#Time').html(getTime).trigger('change.select2');
                },
            });
        }
        var week;
        var prgrm;
        var clas;

        function Getnewdate() {
            var getTimes = ''
            debugger;
            $.ajax({
                url: 'StudentAttendance.aspx/GetDateOfAttendance',
                data: JSON.stringify({
                    "week": week,
                    "prgrm": prgrm,
                    "clas": clas
                }),
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    getTimes = '<option value="0">Please Select</option>';

                    $.each(JSON.parse(data.d), function (key, value) {
                        var dt = new Date(parseInt(value.Date.substr(6)));
                        dt = moment(dt).format('L');
                        var newdate = value.Day_Name + '-' + dt;
                        getTimes += '<option value="' + value.Date + '" >' + newdate + '</option>';
                    });
                    $('#ddldate').html(getTimes).trigger('change.select2');


                },
            });
        }

        function empty() {
            //empty your array
            Array.length = 0;
        }

        var FromTime;
        var ToTime;

        var isAttendance;
        debugger;
        function GetAttendaceDetail() {

            debugger;
            var date = $("#ddldate").val();
            var dt = new Date(parseInt(date.substr(6)));
            dt = moment(dt).format('L');
            var FrTotime = $("#Time option:selected").text();
            var ClassName = $("#Class option:selected").text();
            clasvalue = $("#Class").val();
            var Subject = $("#Subject option:selected").text();
            subvalue = $("#Subject").val();
            var Practical = $("#Practical option:selected").text();
            var Group = $("#ddlGroup ").val();
            var bathc = $("#ddlBatch").val();
            var txt_WholeClass = $('#txt_WholeClass').prop("checked");
            Pracvalue = $("#Practical").val();

            $.ajax({
                url: 'StudentAttendance.aspx/GetAttendanceDetaile',
                data: JSON.stringify({
                    "FTime": FromTime,
                    "TTime": ToTime,
                    "classs": classs,
                    "program": program,
                    "date": dt,
                    "Group": Group,
                    "bathc": bathc,
                    "txt_WholeClass": txt_WholeClass

                }),
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (_data) {
                    debugger;
                    _data = JSON.parse(_data.d);
                    var Attendance = $('#tblStutimetable');
                    $('#tblStutimetable tr:gt(0)').remove();
                    $(_data).each(function (index, md) {
                        debugger;
                        isAttendance = md.isAttendance;

                        var timm = new Date(parseInt(md.Date.substr(6)));
                        var timee = moment(timm).format("HH:mm:ss");

                        var dt = new Date(parseInt(md.Date.substr(6)));
                        dt = moment(dt).format('L');

                        var time = moment(md.FromTime).format('h:mm a');
                        var ttime = moment(md.ToTime).format('h:mm a');

                        var srnumber = index + 1;
                        Attendance.append('<tr><td style="display:none"><input type="hidden" id="ATime' + srnumber + '" name="ATime" value="' + timee + '" /></td>  <td> <input type="Checkbox" name="Getrow" id="Getrow' + srnumber + '" class="chckrow">  </td>   <td style="width:40px !important;"> <input type="hidden" id="FTtime' + srnumber + '" name="FTtime" value="' + FrTotime + '" /> ' + srnumber + '</td><td><input style="height:25px; width: 120px !important; margin-bottom:0px;" disabled type="text" id="Date' + srnumber + '" name="Date" value="' + dt + '-' + md.Day_Name + '" /></td> <td> From <input style="height:25px; width: 70px !important; margin-bottom:0px;"  type="text" id="frtime' + srnumber + '" name="FTime" value="' + time + '" /> To <input style="height:25px; width: 70px !important; margin-bottom:0px;"  type="text" id="trtime' + srnumber + '" name="TTime" value="' + ttime + '" /></td>  <td style="width:10px;"> <input type="hidden" name="Stud_Id" id="Stud_Id' + srnumber + '" value="' + md.Student_Id + '" ><input style="height:25px; width: 153px !important; margin-bottom:0px;" disabled type="text" id="StuName' + srnumber + '" name="StuName" value="' + md.Full_Name + '" /></td>   <td style="width:10px;"><input style="height:25px; width: 62px !important; margin-bottom:0px;" disabled type="text" id="Roll_No' + srnumber + '" name="Roll_No" value="' + md.Roll_No + '" /></td>    <td style="font-size: 12px; font-weight: bold; padding-top: 14px; width:25px !important;">' + md.ClassName + ' </td><td style="display:none"><input type="hidden" id="class' + srnumber + '" name="class" value="' + clasvalue + '" /> </td> <td><input style="height:25px; width:75px !important; margin-bottom:0px;" disabled type="text" id="batchs' + srnumber + '" name="batchs" value="' + md.Batch + '" /></td>   <td><input style="height:25px; width: 75px !important; margin-bottom:0px;" disabled type="text" id="groups' + srnumber + '" name="groups" value="' + md.Group + '" /></td>                      <td style="font-size: 12px; font-weight: bold; padding-top: 14px;">' + Subject + '</td><td style="display:none"> <input type="hidden" id="Subject' + srnumber + '" name="Subject" value="' + subvalue + '" /></td><td style="font-size: 12px; font-weight: bold; padding-top: 14px;"> ' + md.SubSubject + '</td><td style="display:none"><input type="hidden" id="Practical' + srnumber + '" name="Practical" value="' + Pracvalue + '" /></td><td style = "width: 42px !important;">P <input type="Checkbox" id="Present' + srnumber + '" name="Present"  class ="chckP"></td>        <td  style = "width: 42px !important;">A <input type="Checkbox" id="Absent' + srnumber + '" name="Absent"  class ="chckA"></td>         <td  style = "width: 42px !important;">L <input type="Checkbox" id="Leave' + srnumber + '"  name="Leave"  class ="chckL"></td> </tr>');
                        debugger;
                        $('#Present' + srnumber + '').on("change", function () {
                            debugger;

                            var isTrue = ($('#Present' + srnumber + '').is(':checked'))
                            if (isTrue) {
                                $('#Absent' + srnumber + '').attr('checked', false)
                                $('#Leave' + srnumber + '').attr('checked', false);
                            }
                        });

                        debugger;
                        $('#Absent' + srnumber + '').on("change", function () {
                            debugger;

                            var isTrue = ($('#Absent' + srnumber + '').is(':checked'))
                            if (isTrue) {
                                $('#Present' + srnumber + '').attr('checked', false)
                                $('#Leave' + srnumber + '').attr('checked', false);
                            }
                        });

                        debugger;
                        $('#Leave' + srnumber + '').on("change", function () {
                            debugger;

                            var isTrue = ($('#Leave' + srnumber + '').is(':checked'))
                            if (isTrue) {
                                $('#Absent' + srnumber + '').attr('checked', false)
                                $('#Present' + srnumber + '').attr('checked', false);
                            }
                        });


                        $('#Present' + srnumber + '').prop('checked', md.Present)
                        $('#Absent' + srnumber + '').prop('checked', md.Absent)
                        $('#Leave' + srnumber + '').prop('checked', md.Leave)


                        ToDate();
                        FromDate();
                    });
                    debugger;
                    if (isAttendance == 'Attendance') {
                        $('#Save').attr("disabled", true);
                        $('#AttendanceProc').attr("disabled", true);
                        $('#btnPrint').attr("disabled", false);

                        $('#Update').show();



                    }
                    else {
                        $('#Save').attr("disabled", false);
                        $('#AttendanceProc').attr("disabled", false);
                        $('#btnPrint').attr("disabled", true);

                        $('#Update').hide();
                    }

                },

                error: function () {
                    alert("Get Error");
                }

            });

        }

        var ups;
        function UserRoless() {
            debugger;
            $.ajax({
                type: "POST",
                url: "StudentAttendance.aspx/UserRoles",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    ups = JSON.parse(response.d);

                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }


        function ToDate() {
            $('input[name="TTime"]').ptTimeSelect({});
        }
        function FromDate() {
            $('input[name="FTime"]').ptTimeSelect({});
        }
     
        function Print() {


            var date = $("#ddldate").val();
            var dt = new Date(parseInt(date.substr(6)));
            dt = moment(dt).format('L');
            var FrTotime = $("#Time option:selected").text();
            var ClassName = $("#Class option:selected").text();
            clasvalue = $("#Class").val();
            var Subject = $("#Subject option:selected").text();
            subvalue = $("#Subject").val();
            var Practical = $("#Practical option:selected").text();
            var Group = $("#ddlGroup ").val();
            var bathc = $("#ddlBatch").val();
            var txt_WholeClass = $('#txt_WholeClass').prop("checked");
            Pracvalue = $("#Practical").val();

            debugger;

            window.open('ReportViewer.aspx?ReportName=AttendanceReport&ReportTitle=Student Attendance Report' + '&FTime=' + FromTime + '&TTime=' + ToTime + '&classs=' + classs + '&program=' + program + '&date=' + dt + '&Group=' + Group + '&bathc=' + bathc + '&txt_WholeClass=' + txt_WholeClass);
        }

        function ProcessAttendance() {
            //debugger;


            $('#Save').attr('disabled', true);



            var table = $('#tbody');
            var Update_list = [];
            table.find('tr input[name=Getrow]').each(function (key, value) {

                var ti = $($(value).closest('tr').find('td input[name=FTtime]')[0]).val();
                var ft = ti.split("-");
                var frmtim = ft[0];
                var totim = ft[1];

                var dt = $($(value).closest('tr').find('td input[name=Date]')[0]).val();
                var datee = dt.split("-");
                var Newdate = datee[0];

                var RollNo = $($(value).closest('tr').find('td input[name=Roll_No]')[0]).val();

                var Paramaters = { "frmtim": frmtim, "totim": totim, "date": Newdate, "RollNo": RollNo };


                PageMethods.AttendanceProcess(JSON.stringify(Paramaters), function (data) {

                    debugger;
                    var _data = JSON.parse(data);
                    var attendance = _data[0].isAttendance;
                    var attendanceTime = _data[0].AttendanceTime;
                    debugger;

                    var atime = moment(attendanceTime).format("HH:mm:ss");

                    if (attendance == "True" || attendance == true) {
                        $($(value).closest('tr').find('td input[name=Present]')[0]).prop('checked', true);
                        $($(value).closest('tr').find('td input[name=ATime]')[0]).val(atime);//('checked', true);
                    }
                    else {
                        debugger;

                        $($(value).closest('tr').find('td input[name=Absent]')[0]).prop('checked', true);
                    }
                    setTimeout(function () {
                        $('#Save').attr('disabled', false);
                    }, 7000)
                });


            });

        }



        var RowNo;
        function UpdateAttendance() {
            debugger;
            var table = $('#tbody');
            var Update_list = [];
            debugger;
            table.find('tr input[name=Getrow]:checked').each(function (key, value) {
                debugger;
                var ti = $($(value).closest('tr').find('td input[name=FTtime]')[0]).val();
                var ft = ti.split("-");
                var frmtim = ft[0];
                var totim = ft[1];

                var dt = $($(value).closest('tr').find('td input[name=Date]')[0]).val();
                var datee = dt.split("-");
                var Newdate = datee[0];
                // var totim = ft[1];


                Update_list.push({
                    'frmtim': frmtim,
                    'totim': totim,
                    'dat': Newdate,
                    'Student_Id': $($(value).closest('tr').find('td input[name=Stud_Id]')[0]).val(),
                    'Classval': $($(value).closest('tr').find('td input[name=class]')[0]).val(),
                    'Subval': $($(value).closest('tr').find('td input[name=Subject]')[0]).val(),
                    'pracval': $($(value).closest('tr').find('td input[name=Practical]')[0]).val(),
                    'chkPresent': $($(value).closest('tr').find('td input[name=Present]')[0]).prop("checked"),
                    'chkAbsent': $($(value).closest('tr').find('td input[name=Absent]')[0]).prop("checked"),
                    'chkLeave': $($(value).closest('tr').find('td input[name=Leave] ')[0]).prop("checked"),
                });
                debugger;
            });
            if (Update_list.length == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Check Any Student',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            else {
                var Parameters = { "Update_list": Update_list, };
            }

            if (ups == false) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'You Dont Have Rights To Update Attendance',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#Update').attr('disabled', true)
                return;
            }

            PageMethods.UpdateAttendance(JSON.stringify(Parameters), function () {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Update Data Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            });
        }
        var clasvalue;
        var subvalue;
        var Pracvalue;
        debugger;
        function SaveAttendance() {
            debugger;
            var Save_list = [];
            debugger;
            debugger;
            $.each($('#tblStutimetable tbody tr'), function (key, value) {

                debugger;
                var Student_Id = $($(value).find('td input[name=Stud_Id]')[0]).val();
                var FromTotime = $($(value).find('td input[name=FTtime]')[0]).val();
                var ft = FromTotime.split("-");
                var frmtim = ft[0];
                var totim = ft[1];
                var Classval = clasvalue;
                var Subval = subvalue;
                var pracval = Pracvalue;
                var Student_Name = $($(value).find('td input[name=StuName]')[0]).val();
                var Roll_No = $($(value).find('td input[name=Roll_No]')[0]).val();
                var batchs = $($(value).find('td input[name=batchs]')[0]).val();
                var groups = $($(value).find('td input[name=groups]')[0]).val();
                var TTimes = $($(value).find('td input[name=TTime]')[0]).val();
                var FTimes = $($(value).find('td input[name=FTime]')[0]).val();
                var chkPresent = $($(value).find('td input[name=Present]')[0]).prop("checked");
                var chkAbsent = $($(value).find('td input[name=Absent]')[0]).prop("checked");
                var chkLeave = $($(value).find('td input[name=Leave]')[0]).prop("checked");
                var Dates = $($(value).find('td input[name=Date]')[0]).val();

                var ATime = $($(value).find('td input[name=ATime]')[0]).val();

                var Dte = Dates.split('-');
                debugger;
                Dated = Dte[0];
                debugger;
                var dat = Dated.trim();
                debugger;
                DayName = Dte[1];
                var day = DayName.trim();


                Save_list.push({
                    Student_Id: Student_Id, frmtim: frmtim, batchs: batchs, dat: dat, day: day, groups: groups, FTimes: FTimes, TTimes: TTimes, totim: totim, Classval: Classval, Subval: Subval, pracval: pracval, Student_Name: Student_Name, Roll_No: Roll_No, chkPresent: chkPresent, chkAbsent: chkAbsent, chkLeave: chkLeave, ATime, Block: $('#ddlBlock').val(),
                    Module: $('#ddlModule').val()
                });
            });

            debugger;
            var Parameter = { "Save_list": Save_list, };

            debugger;
            PageMethods.SaveAttendance(JSON.stringify(Parameter), function (res) {
                debugger;
                _data = JSON.parse(res);

                $('#tblStutimetable tr:gt(0)').remove();

                var Attendance = $('#tbody');
                $(_data).each(function (index, md) {
                    debugger;

                    var St_id = md.Student_Id;
                    var sname = md.Student_Name;
                    var rollno = md.Roll_No;
                    var p = md.chkPresent;
                    var Fromtime = moment(md.frmtim).format('h:mm a');
                    var Totime = moment(md.totim).format('h:mm a');
                    var FrTotime = Fromtime + '-' + Totime;
                    var srnumber = index + 1;

                    var dt = new Date(parseInt(md.dat.substr(6)));
                    dt = moment(dt).format('L');


                    Attendance.append('<tr>  <td> <input type="Checkbox" name="Getrow" id="Getrow' + srnumber + '" class="chckrow">  </td>   <td style="width:40px !important;"> <input type="hidden" id="FTtime' + srnumber + '" name="FTtime" value="' + FrTotime + '" /> ' + srnumber + '</td><td><input style="height:25px; width: 120px !important; margin-bottom:0px;" disabled type="text" id="Date' + srnumber + '" name="Date" value="' + dt + '-' + md.day + '" /></td> <td> From <input style="height:25px; width: 70px !important; margin-bottom:0px;"  type="text" id="frtime' + srnumber + '" name="FTime" value="' + Fromtime + '" /> To <input style="height:25px; width: 70px !important; margin-bottom:0px;"  type="text" id="trtime' + srnumber + '" name="TTime" value="' + Totime + '" /></td>  <td style="width:10px;"> <input type="hidden" name="Stud_Id" id="Stud_Id' + srnumber + '" value="' + md.Student_Id + '" ><input style="height:25px; width: 153px !important; margin-bottom:0px;" disabled type="text" id="StuName' + srnumber + '" name="StuName" value="' + md.Student_Name + '" /></td>   <td style="width:10px;"><input style="height:25px; width: 62px !important; margin-bottom:0px;" disabled type="text" id="Roll_No' + srnumber + '" name="Roll_No" value="' + md.Roll_No + '" /></td>    <td style="font-size: 12px; font-weight: bold; padding-top: 14px; width:25px !important;">' + md.Classname + ' </td><td style="display:none"><input type="hidden" id="class' + srnumber + '" name="class" value="' + md.Classval + '" /> </td> <td><input style="height:25px; width:75px !important; margin-bottom:0px;" disabled type="text" id="batchs' + srnumber + '" name="batchs" value="' + md.batchs + '" /></td>   <td><input style="height:25px; width: 75px !important; margin-bottom:0px;" disabled type="text" id="groups' + srnumber + '" name="groups" value="' + md.groups + '" /></td>                      <td style="font-size: 12px; font-weight: bold; padding-top: 14px;">' + md.Subjectname + '</td><td style="display:none"> <input type="hidden" id="Subject' + srnumber + '" name="Subject" value="' + md.Subject + '" /></td><td style="font-size: 12px; font-weight: bold; padding-top: 14px;"> ' + md.pracval + '</td><td style="display:none"><input type="hidden" id="Practical' + srnumber + '" name="Practical" value="' + md.pracval + '" /></td><td style = "width: 42px !important;">P <input type="Checkbox" id="Present' + srnumber + '" name="Present"  class ="chckP"></td>        <td  style = "width: 42px !important;">A <input type="Checkbox" id="Absent' + srnumber + '" name="Absent"  class ="chckA"></td>         <td  style = "width: 42px !important;">L <input type="Checkbox" id="Leave' + srnumber + '"  name="Leave"  class ="chckL"></td> </tr>');



                    length++;
                    debugger;
                    if (p == "True" || p == true) {
                        $('#Present' + srnumber + '').attr('checked', true);
                    }

                    if (md.chkAbsent == "True" || md.chkAbsent == true) {
                        $('#Absent' + srnumber + '').attr('checked', true);
                    }

                    if (md.chkLeave == "True" || md.chkLeave == true) {
                        $('#Leave' + srnumber + '').attr('checked', true);
                    }

                    $('#Present' + srnumber + '').on("change", function () {
                        debugger;

                        var isTrue = ($('#Present' + srnumber + '').is(':checked'))
                        if (isTrue) {
                            $('#Absent' + srnumber + '').attr('checked', false)
                            $('#Leave' + srnumber + '').attr('checked', false);
                        }
                    });

                    debugger;
                    $('#Absent' + srnumber + '').on("change", function () {
                        debugger;

                        var isTrue = ($('#Absent' + srnumber + '').is(':checked'))
                        if (isTrue) {
                            $('#Present' + srnumber + '').attr('checked', false)
                            $('#Leave' + srnumber + '').attr('checked', false);
                        }
                    });

                    debugger;
                    $('#Leave' + srnumber + '').on("change", function () {
                        debugger;

                        var isTrue = ($('#Leave' + srnumber + '').is(':checked'))
                        if (isTrue) {
                            $('#Absent' + srnumber + '').attr('checked', false)
                            $('#Present' + srnumber + '').attr('checked', false);
                        }
                    });

                    $('#Save').attr("disabled", true);

                    $('#AttendanceProc').attr("disabled", true);
                    $('#btnPrint').attr("disabled", false);
                    $('#Update').show();

                });
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Save Data Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            });
        }


    </script>

</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-md-2">
            <label>Program</label>
            <select id="program" name="program" onchange="Selectfunc()">
                <option value="0">Please Select</option>
            </select>
        </div>

        <div class="col-md-2">
            <label>Class</label>
            <select id="Class" name="Class">
                <option value="0">Please Select</option>
            </select>
        </div>

        <div class="col-md-2">
            <label>Week:</label>
            <select id="ddlWeek" name="Class">
                <option value="0">Please Select</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label>Block</label>
            <select id="ddlBlock" class="form-control">
                <option value="">Please Select</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label>Module</label>
            <select id="ddlModule" class="form-control">
                <option value="">Please Select</option>
            </select>
        </div>
        <div class="col-md-2">
            <label>Date:</label>
            <select id="ddldate" name="ddldate">
                <option value="0">Please Select</option>
            </select>

        </div>
    </div>
    <div class="row">
        <div class="col-md-2">
            <label>Subject</label>
            <select id="Subject" name="Subject">
                <option value="0">Please Select</option>
            </select>
        </div>
        <div class="col-md-2">
            <label style="margin-left: 14px !important;">Time</label>
            <select id="Time" name="Time">
                <option value="0">Please Select</option>
            </select>
        </div>
        <div class="col-md-2">
            <label>Group</label>
            <select id="ddlGroup">
                <option value="0">Please Select</option>
            </select>
        </div>
        <div class="col-md-2">
            <label>Batch</label>
            <select id="ddlBatch">
                <option value="0">Please Select</option>
            </select>
        </div>
        <div class="col-md-3" style="margin-top: 23px !important; margin-left: 3px;">
            <div class="col-md-2">
                <label>W.C</label>
            </div>
            <div class="col-md-2">
                <input type="checkbox" id="txt_WholeClass" />
            </div>
        </div>
        <div class="col-md-1">
            <label id="lblsubjtype">Sub_Subject</label>
            <select id="Practical" name="Practical">
                <option value="0">Please Select</option>
            </select>
        </div>
    </div>
    <br />
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-1 col-sm-2">
                    <input type="button" class="btn-primry" onclick="SaveAttendance()" value="Save" id="Save" />
                </div>
                <div class="col-lg-2 col-md-2 col-sm-2">
                    <input type="button" class="btn btn-gray" onclick="ProcessAttendance()" value="Attendance Process" id="AttendanceProc" />
                </div>
                <div class="col-lg-2 col-md-1 col-sm-2">
                    <input type="button" class="btn-primry" onclick="Print()" value="Print" id="btnPrint" />
                </div>
                <div class="col-lg-2 col-md-1 col-sm-2">

                    <input type="button" class="btn btn-yellow" onclick="UpdateAttendance()" value="Update" id="Update" />
                </div>
            </div>
        </div>
    </div>





    <div class="row">
        <div class="col-md-12" style="overflow: scroll; min-height: 150px; max-height: 500px; min-width: 1200px !important;">
            <table class="table table-bordered" style="overflow: scroll; height: auto" id="tblStutimetable">
                <thead>
                    <tr>
                        <th style="width: 40px;">Row
                             <input type="checkbox" id="Getrow" name="Present" />
                        </th>
                        <th style="width: 50px !important; font-size: 16px;">Sr</th>
                        <th>Date</th>
                        <th style="min-width: 214px;">Time</th>
                        <th>Student Name</th>
                        <th>Roll No</th>
                        <th>Class</th>
                        <th>Batch</th>
                        <th>Group</th>
                        <th>Subject</th>
                        <th>Sub_Subject</th>
                        <th style="width: 42px;">P
                            <input type="checkbox" id="Present" name="Present" class="chckP" />
                        </th>
                        <th style="width: 42px;">A
                            <input type="checkbox" id="Absent" name="Absent" class="chckA" />
                        </th>
                        <th style="width: 42px;">L
                            <input type="checkbox" id="Leave" name="Leave" class="chckL" />
                        </th>
                    </tr>
                </thead>

                <tbody id="tbody">
                </tbody>

            </table>
        </div>
    </div>


</asp:Content>
