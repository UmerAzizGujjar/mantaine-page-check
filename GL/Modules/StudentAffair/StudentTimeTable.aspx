
<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentTimeTable.aspx.cs" Inherits="PMS.StudentTimeTable" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style type="text/Css">
       
          input[name="Date"]:focus {
                border: 1px solid #ff2950 !important;
                background-color:lightgoldenrodyellow;
          }
          #program:focus {
              border: 1px solid #ff2950 !important;
                background-color:lightgoldenrodyellow;
          }
          #ddlClass:focus {
               border: 1px solid #ff2950 !important;
                background-color:lightgoldenrodyellow;
          }
          #ddlWeek:focus {
               border: 1px solid #ff2950 !important;
                background-color:lightgoldenrodyellow;
          }


        .rowtr:focus-within {
            background-color: #5b9dc9;
        }
        .mtop{
            margin-top:20px;
        }
    </style>

    <script type="text/javascript"> 
        $(document).ready(function () {

            
           GetSubjectType();
            GetGroup(); 
            Getbatchs();
            GetVenu();
            GetTeacher();
            
            debugger;
                 <% if (Request.QueryString["ID"] != null)
                  { %>
                        var Stu_ID = '<%= Request.QueryString["ID"]%>'
                        EditMasterSubject(Stu_ID);
                    <% }%>
            $('#ddlClass').on("change", function () {
                debugger;
                program = $('#program').val();
                classs = $('#ddlClass').val();
                GetSubject();
                GetGroup();
            })

            var dropdowns = [
                { id: '#program', method: 'GetProgram' },
                { id: '#ddlClass', method: 'GetClass' },
                { id: '#ddlWeek', method: 'GetWeek' },
                { id: '#ddlBlock', method: 'GetAcademicBlock' },
                { id: '#ddlModule', method: 'GetAcademicModule' }
            ];

            dropdowns.forEach(item => {
                const $element = $(item.id);
                $element.select2();
                $element.off('select2:opening').on('select2:opening', function (e) {
                    if (!$element.data('filled')) {
                        e.preventDefault();
                        $element.data('shouldReopen', true);
                        fillDropdown($element, item.method);
                    }
                });
            });
            var Student_Id = $('#Subject_id').val();
            Student_Id = '<%= Request.QueryString["ID"]%>'
            if (Student_Id == '' || Student_Id == "" || Student_Id == null || Student_Id == "null") {
               $('#Replicate').attr('disabled', true);
            }
        });

        function fillDropdown($dropdown, methodName, callback) {
            if ($dropdown.data('filled')) {
                if (callback) callback();
                return;
            }

            var currentValue = $dropdown.val();
            var currentText = $dropdown.find('option:selected').text();

            $dropdown.html('<option value="">Loading...</option>').trigger('change.select2');

            $.ajax({
                type: "POST",
                url: "StudentTimeTable.aspx/" + methodName,
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        const allOptions = [{ DataValue_Name: "", DataValue_Description: "Select" }].concat(data);
                        $dropdown.data('allOptions', allOptions);

                        let optionsHtml = '';
                        let valueFound = false;

                        allOptions.forEach(opt => {
                            const isSelected = opt.DataValue_Name === currentValue;
                            if (isSelected) valueFound = true;
                            optionsHtml += `<option value="${opt.DataValue_Name}"${isSelected ? ' selected="selected"' : ''}>${opt.DataValue_Description}</option>`;
                        });

                        if ($dropdown.hasClass('select2-hidden-accessible')) {
                            $dropdown.select2('destroy');
                        }

                        $dropdown.html(optionsHtml).data('filled', true);

                        if (currentValue && currentValue !== "" && !valueFound) {
                            $dropdown.prepend(`<option value="${currentValue}" selected="selected">${currentText}</option>`);
                        }

                        $dropdown.select2();

                        $dropdown.trigger('change.select2');

                        if ($dropdown.data('shouldReopen')) {
                            $dropdown.data('shouldReopen', false);
                            setTimeout(() => {
                                $dropdown.select2('open');
                            }, 50);
                        }
                        if (callback) callback();
                    } catch (e) {
                        $dropdown.data('filled', false);
                        $dropdown.html('<option value="">Error loading</option>').trigger('change.select2');
                    }
                },
                error: function (xhr, status, error) {
                    $dropdown.data('filled', false);
                    $dropdown.html('<option value="">Load failed</option>').trigger('change.select2');
                }
            });
        }

        function Selectfunc() {
            var currentYear = new Date().getFullYear();
            var slct_value = $("#program").val() || "";
            var pid = slct_value.replace(/^0+/, '') || slct_value;
            var $ddlClass = $('#ddlClass');
            var all = $ddlClass.data('allOptions') || [];

            if (!all.length) {
                fillDropdown($ddlClass, 'GetClass', Selectfunc, false);
                return;
            }

            var allowedIndexes;

            if (pid === '2') {
                allowedIndexes = [1, 2, 3, 4, 5];
                $('#ddlClass').val(currentYear + '-' + (currentYear + 5));
            }
            else if (pid === '1') {
                allowedIndexes = [1];
                $('#ddlClass').val(currentYear + '-' + (currentYear + 2));
            }
            else if (pid === '3') {
                allowedIndexes = [1, 2, 3, 4];
                $('#ddlClass').val(currentYear + '-' + (currentYear + 1));
            }
            else {
                allowedIndexes = [];
                for (var i = 1; i < all.length; i++) {
                    allowedIndexes.push(i);
                }
                $('#ddlClass').val('');
            }

            let newHtml = `<option value="${all[0].DataValue_Name}">${all[0].DataValue_Description}</option>`;
            allowedIndexes.forEach(idx => {
                if (all[idx]) {
                    newHtml += `<option value="${all[idx].DataValue_Name}">${all[idx].DataValue_Description}</option>`;
                }
            });

            $ddlClass.html(newHtml).val('').trigger('change');
        }

        function Addrow() {
            debugger;
            var program = $("#program").val();
            var ClassName = $("#ddlClass option:selected").text();
            var ClassVal = $('#ddlClass').val();
            var ddlWeek = $('#ddlWeek').val();
            GetSubject();

            var rows = '';

            var rowlength = tblItemDescription.rows.length;
            debugger;
            rows += '<tr Class="rowtr">' +
                '<td style = "width: 78px !important;"><input style="display:none;" type="text" name="clas" id="clas' + rowlength + '"  value="' + ClassVal + '" />' + ClassName + '</td>' +
                '<td><input type="text"" style="width: 110px!important;font-size: 12px;height: 23px;" name="Date" id="txt_Date' + parseInt(parseInt(rowlength)) + '" value=""  /></td>' +

                '<td style = "width: 220px !important; ">From:<input type="time" name="FTime" value=" " id="FTime' + rowlength + '"  style="width: 94px !important;font-size: 12px;height: 23px;"   /> To: <input type="time" name="TTime"  value="" id="Time' + rowlength + '" style="width: 94px!important;font-size: 12px;height: 23px;" /></td>' +

                '<td ><select style ="font-size:12px;height:25px;" id="ddlstdsubj' + rowlength + '" name="ddlGetStuSub"> ' + GetStudentSubject + ' </select > ' +
                '</td>' +

                '<td ><select style ="font-size:12px;height:25px;" id="ddlitmeCode' + rowlength + '" name="ddlSubject"> ' + GlobSubj + ' </select > ' +
                '</td>' +

                '<td ><select style ="font-size:12px;height:25px;" id="ddlbatchs' + rowlength + '" name="ddlBatch"> ' + Getbatch + ' </select > ' +
                '</td>' +

                '<td ><select style ="font-size:12px;height:25px;" id="ddlgroups' + rowlength + '" name="ddlGroup"> ' + Getgrp + ' </select > ' +
                '</td>' +

                '<td><input style = "margin-left: 12px !important; width: 31px !important;" type="Checkbox" name="whlclass" id="whole' + rowlength + '"  value=""/></td>' +

                '<td><input  type="text"  style ="font-size:12px;height:25px;" id="Topic' + rowlength + '" name="Topic" value=""/></td>' +

                '<td ><select style ="width:80px !important; font-size:12px;height:25px;"  id="ddlTeacher' + rowlength + '" class="teach" name="ddlTeacher"> ' + GetTeacher + ' </select > ' +
                '</td>' +

                '<td ><select style ="font-size:12px;height:25px;" id="ddlVenue' + rowlength + '" name="ddlVenue"> ' + GetVenue + ' </select > ' +
                '</td>' +

                

                '<td><input style = "margin-left: 15px !important;" type="Checkbox" name="chkhldy" id="chkhldy' + rowlength + '"  value=""/></td>' + '<td><input style = "margin-left: 12px !important; width: 15px !important;" type="Checkbox" name="chkbrk" id="chkbrks' + rowlength + '"  value=""/></td>' +
                '<td><a href="#" onclick ="Delete(this)"><i class="glyphicon glyphicon-trash"  style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative; margin-left: 12px !important;"></i></a></td>'
            '</tr>'
            debugger;
            if (ClassVal == "0") {
                $('#tblPerson').attr('disabled', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Class',
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
            else if (program == "0") {
                $('#tblPerson').attr('disabled', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Program',
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
            else if (ddlWeek == "0") {
                $('#tblPerson').attr('disabled', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Week',
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
        
            $('#tblPerson').append(rows);
            var $newDropdown = $('#ddlstdsubj' + rowlength);
            GetSubject($newDropdown);
            $('.teach').select2();


            $('#program').attr('disabled', 'disabled');
            $('#ddlClass').attr('disabled', true);
            $('#ddlWeek').attr('disabled', true);
       

            $('#ddlbatchs' + rowlength + '').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 != "") {
                    debugger;
                    $('#whole' + rowlength + '').attr('disabled', true);
                    $('#ddlgroups' + rowlength + '').attr('disabled', true);
                }

            });

            $('#ddlbatchs' + rowlength + '').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 == "Please Select" || subject1 == 'Please Select') {
                    debugger;
                    $('#whole' + rowlength + '').attr('disabled', false);
                    $('#ddlgroups' + rowlength + '').attr('disabled', false);
                    $('#ddlbatchs' + rowlength + '').attr('disabled', false)
                }

            });



            $('#ddlgroups' + rowlength + '').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 != "") {
                    debugger;
                    $('#whole' + rowlength + '').attr('disabled', true);
                    $('#ddlbatchs' + rowlength + '').attr('disabled', true);
                }
            });


            $('#ddlgroups' + rowlength + '').on('change', function () {
                debugger;
                var subject1 = $(this).find(':selected').text();
                if (subject1 == "Please Select" || subject1 == 'Please Select') {
                    debugger;
                    $('#whole' + rowlength + '').attr('disabled', false);
                    $('#ddlgroups' + rowlength + '').attr('disabled', false);
                    $('#ddlbatchs' + rowlength + '').attr('disabled', false)
                }

            });
        

           $('#whole' + rowlength + '').on('change', function () {
               debugger;

                   if ($('#whole' + rowlength + '').is(':checked'))
                   {
                       $('#ddlbatchs' + rowlength + '').attr('disabled', true)
                       $('#ddlgroups' + rowlength + '').attr('disabled', true);
                   }
               else{
                       $('#ddlbatchs' + rowlength + '').attr('disabled', false)
                       $('#ddlgroups' + rowlength + '').attr('disabled', false)
                   }
           });
            $('#chkhldy' + rowlength + '').on('change', function () {
                debugger;
                if ($('#chkhldy' + rowlength + '').is(':checked')) {
                    debugger;
                    $('#ddlbatchs' + rowlength + '').attr('disabled', true);
                    $('#ddlgroups' + rowlength + '').attr('disabled', true);
                    $('#ddlitmeCode' + rowlength + '').attr('disabled', true);
                    $('#ddlstdsubj' + rowlength + '').attr('disabled', true);
                    $('#FTime' + rowlength + '').attr('disabled', true);
                    $('#Time' + rowlength + '').attr('disabled', true);
                    $('#ddlTeacher' + rowlength + '').attr('disabled', true);
                    $('#ddlVenue' + rowlength + '').attr('disabled', true);
                }
                else {
                    debugger;
                    $('#ddlbatchs' + rowlength + '').attr('disabled', false);
                    $('#ddlgroups' + rowlength + '').attr('disabled', false);
                    $('#ddlitmeCode' + rowlength + '').attr('disabled', false);
                    $('#ddlstdsubj' + rowlength + '').attr('disabled', false);
                    $('#FTime' + rowlength + '').attr('disabled', false);
                    $('#Time' + rowlength + '').attr('disabled', false);
                    $('#ddlTeacher' + rowlength + '').attr('disabled', false);
                    $('#ddlVenue' + rowlength + '').attr('disabled', false);
                }
            });
            $('#chkbrks' + rowlength + '').on('change', function () {
                debugger;
                if ($('#chkbrks' + rowlength + '').is(':checked')) {
                    debugger;
                    $('#ddlbatchs' + rowlength + '').attr('disabled', true);
                    $('#ddlgroups' + rowlength + '').attr('disabled', true);
                    $('#ddlitmeCode' + rowlength + '').attr('disabled', true);
                    $('#ddlstdsubj' + rowlength + '').attr('disabled', true);
                    $('#ddlTeacher' + rowlength + '').attr('disabled', true);
                    $('#ddlVenue' + rowlength + '').attr('disabled', true);
                }
                else {
                    debugger;
                    $('#ddlbatchs' + rowlength + '').attr('disabled', false);
                    $('#ddlgroups' + rowlength + '').attr('disabled', false);
                    $('#ddlitmeCode' + rowlength + '').attr('disabled', false);
                    $('#ddlstdsubj' + rowlength + '').attr('disabled', false);
                   
                    $('#ddlTeacher' + rowlength + '').attr('disabled', false);
                    $('#ddlVenue' + rowlength + '').attr('disabled', false);
                }
            });
           
            debugger;
            $(function () {
                debugger;
                var date = new Date();
                var dayNo = date.getDay();
                var mindate = (dayNo);
                var d = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                $('input[name="Date"]').datepicker({
                    dateFormat: 'dd/mm/yy',
                    onSelect: function (dateText, inst) {
                        debugger;
                        var day = dateText.split('/');
                        var today = new Date(parseInt(day[2]), parseInt(day[1]) - 1, parseInt(day[0]), null, null, null, null);
                        $(this).val(dateText + ' - ' + d[today.getDay()]);
                        $(this).focus();
                    }
                });
            });
        }
       
        var GlobSubj = '';
        function GetSubjectType() {
            var optionsDepth = '';
            $.ajax({
                type: "post",
                url: "StudentTimeTable.aspx/GetSubjects",
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    optionsDepth = '<option value="0">Please Select</option>';
                    var data = JSON.parse(msg.d);
                    $.each(data, function (key, value) {
                        optionsDepth += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    GlobSubj = optionsDepth;
                },
            });
        }
        var Getbatch;
        function Getbatchs() {
            Getbatch = '';
            $.ajax({
                url: 'StudentTimeTable.aspx/GetBatch',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: false,
                success: function (data) {
                    Getbatch = '<option value="0">Please Select</option>';
          
                    $.each(JSON.parse(data.d), function (key, value) {
                  
                        Getbatch += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlbatchs').html(Getbatch);
                },
            });
        }
        var Getgrp;
        function GetGroup() {
             Getgrp = '';
            $.ajax({
                url: 'StudentTimeTable.aspx/GetGroups',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: false,
                success: function (data) {
                    Getgrp = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(data.d), function (key, value) {
                        Getgrp += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlgroups').html(Getgrp);
                },
            });
        }


        function Print() {

            var Class = $('#ddlClass').find('option:selected').val();
         
            var ddlProgram = $("#program").find('option:selected').val();
            var ddlWeek = $("#ddlWeek").find('option:selected').val();
            window.open('ReportViewer.aspx?ReportName=StudentTimeTable&ReportTitle=Student Time Table' + '&Class=' + Class + '&Program=' + ddlProgram + '&ddlWeek=' + ddlWeek);
        }

        var GetStudentSubject;
        function GetSubject($targetDropdown) {
            return new Promise(function (resolve, reject) {
                var studentClass = $('#ddlClass').val();
                var studentPRogram = $('#program').val();
                var studentBlock = $('#ddlBlock').val();
                var studentModule = $('#ddlModule').val();

                $.ajax({
                    url: 'StudentTimeTable.aspx/GetSubj',
                    data: JSON.stringify({
                        "studentPRogram": studentPRogram,
                        "studentClass": studentClass,
                        "studentBlock": studentBlock,
                        "studentModule": studentModule
                    }),
                    type: 'post',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (data) {
                        var optionsHtml = '<option value="0">Please Select</option>';
                        $.each(JSON.parse(data.d), function (key, value) {
                            optionsHtml += '<option value="' + value.Subject_Detail_ID + '">' + value.Subject_Name + '</option>';
                        });
                        $targetDropdown.html(optionsHtml);
                        resolve();
                    },
                    error: function () {
                        console.log("Error loading subjects.");
                        reject();
                    }
                });
            });
        }
        
        var GetVenue;
        function GetVenu() {
            debugger;
            Getven = '';
            $.ajax({
                url: 'StudentTimeTable.aspx/GetVenues',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: false,
                success: function (data) {
                    GetVenue = '<option value="0">Select </option>';
                    $.each(JSON.parse(data.d), function (key, value) {
                        GetVenue += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlVenue').html(GetVenue);
                },
            });
        }

        var GetTeacher;
        function GetTeacher() {
            debugger;
            Gettech = '';
            $.ajax({
                url: 'StudentTimeTable.aspx/GetTeachers',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                async: false,
                success: function (data) {
                    GetTeacher = '<option value="0">Select </option>';
                    $.each(JSON.parse(data.d), function (key, value) {
                        GetTeacher += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlTeacher').html(GetTeacher);
                },
            });
        }       
        debugger;
        function Delete(row) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
            var b = $('#tblItemDescription tbody tr').length;
            if (b <= 0) {
                $('#program').attr('disabled', false);
                $('#ddlClass').attr('disabled', false);
                $('#ddlWeek').attr('disabled', false);
            }
        }
        function EditMasterSubject(Stu_ID) {
            debugger;
            PageMethods.editMaster(Stu_ID, function (resp) {
                var studata = JSON.parse(resp);

                $('#Subject_id').val(studata.St_id);

                $('#btnSave').val('Update');

                $('#program').html(
                    $('<option>', {
                        value: studata.Program,
                        text: studata.Program_Text
                    })
                );

                $('#ddlClass').html(
                    $('<option>', {
                        value: studata.Class,
                        text: studata.Class_Text
                    })
                );

                $('#ddlWeek').html(
                    $('<option>', {
                        value: studata.Weeks,
                        text: studata.Weeks_Text
                    })
                );

                $('#ddlBlock').html(
                    $('<option>', {
                        value: studata.Block,
                        text: studata.Block_Text
                    })
                );

                $('#ddlModule').html(
                    $('<option>', {
                        value: studata.Module,
                        text: studata.Module_Text
                    })
                );

            });
            GetGroup();
                editDetail(Stu_ID);
            
         
        }
    
        async function editDetail(Stu_ID) {
            $("#btnSave").attr('disabled', true);

            try {
                const response = await $.ajax({
                    type: "post",
                    url: "StudentTimeTable.aspx/EditDetail",
                    data: JSON.stringify({ "Stu_ID": Stu_ID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json"
                });

                var studata = JSON.parse(response.d);
                var mdTable = $('#tblPerson');
                mdTable.empty();

                for (let index = 0; index < studata.length; index++) {
                    let md = studata[index];

                    var time = moment(md.FromTime).format('HH:mm');
                    var ttime = moment(md.ToTime).format('HH:mm');
                    var dt = new Date(parseInt(md.Date.substr(6)));
                    dt = moment(dt).format('DD/MM/YYYY');
                    var ab = md.Day_Name;
                    var da = index + 1;
                    mdTable.append(`
                <tr class="rowtr">
                    <td style="display:none; width: 78px !important;">
                        <input style="display:none; width: 80px !important;" type="text" name="clas" id="clas" value="${md.Class_Year}"/>
                    </td>
                    <td>${md.classname}</td>
                    <td><input type="text" style="width: 110px !important;font-size: 12px;height: 23px;" name="Date" id="txt_Date${da}" value="${dt} -${ab}" /></td>
                    <td>
                        From:<input type="time" style="width: 95px!important;font-size: 12px;height: 23px;" name="FTime" id="FTime${index}" value="${time}" />
                        To: <input type="time" style="width: 95px!important;font-size: 12px;height: 23px;" name="TTime" id="Time${index}" value="${ttime}" />
                    </td>
                    <td><select style="font-size:12px;height:25px;" id="ddlstdsubj${index}" name="ddlGetStuSub">${GetStudentSubject}</select></td>
                    <td><select style="font-size:12px;height:25px;" id="ddlitmeCode${index}" name="ddlSubject">${GlobSubj}</select></td>
                    <td><select style="font-size:12px;height:25px;" id="ddlbatchs${index}" name="ddlBatch">${Getbatch}</select></td>
                    <td><select style="font-size:12px;height:25px;" id="ddlgroups${index}" name="ddlGroup">${Getgrp}</select></td>
                    <td><input style="margin-left: 12px !important; width: 31px !important;" type="checkbox" name="whlclass" id="whole${index}" value="${md.Whole_Class}" /></td>
                    <td><input disabled type="text" name="Topic" id="Topic${index}" value="${md.Topic}" style="height: 25px;"/></td>
                    <td><select style="font-size:12px;height:25px;" id="ddlTeacher${index}" name="ddlTeacher" class="teach">${GetTeacher}</select></td>
                    <td><select style="font-size:12px;height:25px;" id="ddlVenue${index}" name="ddlVenue">${GetVenue}</select></td>
                    <td><input style="margin-left: 15px !important;" type="checkbox" name="chkhldy" id="chkhldy${index}" value="${md.Holiday}" /></td>
                    <td><input style="margin-left: 12px !important;" type="checkbox" name="chkbrk" id="chkbrks${index}" value="${md.Brea_k}" /></td>
                    <td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative; margin-left: 12px !important;"></i></a></td>
                </tr>
            `);
                    $('.teach').select2();
                    if (md.Whole_Class == true) {
                        $(`#whole${index}`).prop('checked', true);
                        $(`#ddlbatchs${index}`).prop('disabled', true);
                        $(`#ddlgroups${index}`).prop('disabled', true);
                    } else {
                        $(`#ddlbatchs${index}`).prop('disabled', false);
                        $(`#ddlgroups${index}`).prop('disabled', false);
                    }
                    if (md.Holiday == true) {
                        $(`#chkhldy${index}`).prop('checked', true);
                    }
                    if (md.Brea_k == true) {
                        $(`#chkbrks${index}`).prop('checked', true);
                    }
                    $(`#ddlitmeCode${index}`).val(md.Practical).trigger('change');
                    $(`#ddlbatchs${index}`).val(md.Batch).trigger('change');
                    $(`#ddlgroups${index}`).val(md.Groups).trigger('change');
                    $(`#ddlTeacher${index}`).val(md.Teacher).trigger('change');
                    $(`#ddlVenue${index}`).val(md.Venue).trigger('change');

                    var $subjectDropdown = $(`#ddlstdsubj${index}`);
                    await GetSubject($subjectDropdown);
                    await new Promise(resolve => setTimeout(resolve, 0));
                    if ($subjectDropdown.find(`option[value="${md.Subjects}"]`).length) {
                        $subjectDropdown.val(md.Subjects).trigger('change');
                    } else {
                        console.warn(`Subject "${md.Subjects}" not available in dropdown for row ${index}`);
                        $subjectDropdown.val('0');
                    }
                    $(`#ddlTeacher${index}`).select2();

                    $(`#ddlbatchs${index}`).on('change', function () {
                        var subject1 = $(this).find(':selected').text();
                        if (subject1 != "Please Select") {
                            $(`#whole${index}`).prop('disabled', true);
                            $(`#ddlgroups${index}`).prop('disabled', true);
                        } else {
                            $(`#whole${index}`).prop('disabled', false);
                            $(`#ddlgroups${index}`).prop('disabled', false);
                        }
                    });

                    $(`#ddlgroups${index}`).on('change', function () {
                        var subject1 = $(this).find(':selected').text();
                        if (subject1 != "Please Select") {
                            $(`#whole${index}`).prop('disabled', true);
                            $(`#ddlbatchs${index}`).prop('disabled', true);
                        } else {
                            $(`#whole${index}`).prop('disabled', false);
                            $(`#ddlbatchs${index}`).prop('disabled', false);
                        }
                    });

                    $(`#whole${index}`).on('change', function () {
                        if ($(this).is(':checked')) {
                            $(`#ddlbatchs${index}`).prop('disabled', true);
                            $(`#ddlgroups${index}`).prop('disabled', true);
                        } else {
                            $(`#ddlbatchs${index}`).prop('disabled', false);
                            $(`#ddlgroups${index}`).prop('disabled', false);
                        }
                    });

                    $(`#chkhldy${index}`).on('change', function () {
                        var disabled = $(this).is(':checked');
                        $(`#ddlbatchs${index}, #ddlgroups${index}, #ddlitmeCode${index}, #ddlstdsubj${index}, #FTime${index}, #Time${index}, #ddlTeacher${index}, #ddlVenue${index}`)
                            .prop('disabled', disabled);
                    });

                    $(`#chkbrks${index}`).on('change', function () {
                        var disabled = $(this).is(':checked');
                        $(`#ddlbatchs${index}, #ddlgroups${index}, #ddlitmeCode${index}, #ddlstdsubj${index}, #ddlTeacher${index}, #ddlVenue${index}`)
                            .prop('disabled', disabled);
                    });
                }

                initializeDatePickers();
                initializeTimePickers();

                $("#btnSave").attr('disabled', false);

            } catch (error) {
                alert("Data not transferred");
            }
        }

        function initializeDatePickers() {
            var d = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
            $('input[name="Date"]').datepicker({
                dateFormat: 'dd/mm/yy',
                onSelect: function (dateText, inst) {
                    var day = dateText.split('/');
                    var today = new Date(parseInt(day[2]), parseInt(day[1]) - 1, parseInt(day[0]));
                    $(this).val(dateText + ' - ' + d[today.getDay()]);
                    $(this).focus();
                }
            });
        }

        function initializeTimePickers() {
            $('input[name="TTime"]').ptTimeSelect({
                onClose: function () {
                    $('input[name="TTime"]').focus();
                }
            });
            $('input[name="FTime"]').ptTimeSelect({});
        }
        function Replicates() {
                debugger;
                var Subject_id = $('#Subject_id').val();
                var program = $('#program').val();
                var ddlClass = $('#ddlClass').val();
                var ddlWeek = $('#ddlWeek').val();
                var ddlBlock = $('#ddlBlock').val();
                var ddlModule = $('#ddlModule').val();
                var Save_list = [];
                debugger;
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    var Class = $($(value).find('td input[name=clas]')[0]).val();
                    var txtClass = $($(value).find('td input[name=clas]')[0]).text();
                    var Dates = $($(value).find('td input[name=Date]')[0]).val();
                    var dt = new Date();
                    var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
                    var Dte = Dates.split('-');
                    debugger;
                    Dated = Dte[0];
                    var today = Dated.trim();
                    var day = today.split('/');
                    var dat = new Date(parseInt(day[2]), parseInt(day[1]) - 1, parseInt(day[0]), null, null, null, null);
                    debugger;

                    DayName = Dte[1];
                    var day = DayName.trim();
                    debugger;
                    var TTime = $($(value).find('td input[name=TTime]')[0]).val();
                    if (TTime == null || TTime == 0 || TTime == "") {
                        TTime = time;
                    }
                    var FTimes = $($(value).find('td input[name=FTime]')[0]).val();
                    if (FTimes == null || FTimes == 0 || FTimes == "") {
                        FTimes = time;
                    }  




                    debugger;                 
                    var TTime = $($(value).find('td input[name=TTime]')[0]).val();
                    if (TTime == null || TTime == 0 || TTime == "") {
                        TTime = time; 
                    }                  
                    var FTimes = $($(value).find('td input[name=FTime]')[0]).val();                    
                    if (FTimes == null || FTimes == 0 || FTimes == "") {
                        FTimes = time
                    }
                    var ddlSubject = $($(value).find('td Select[name=ddlSubject]')[0]).val();
                    var ddlBatch = $($(value).find('td Select[name=ddlBatch]')[0]).val();
                    var ddlGroup = $($(value).find('td Select[name=ddlGroup]')[0]).val();
                    var ddlTeacher = $($(value).find('td Select[name=ddlTeacher]')[0]).val();
                    var ddlVenu = $($(value).find('td Select[name=ddlVenue]')[0]).val();
                    var whlclass = $($(value).find('td input[name=whlclass]')[0]).prop("checked");
                    var ddlGetStuSub = $($(value).find('td Select[name=ddlGetStuSub]')[0]).val();
                    var chkhldy = $($(value).find('td input[name=chkhldy]')[0]).prop("checked");
                    var chkbrk = $($(value).find('td input[name=chkbrk]')[0]).prop("checked");
                    var topic = $($(value).find('td input[name=Topic]')[0]).val();
                    Save_list.push({

                        Class: Class, txtClass: txtClass, dat: dat, day: day, FTimes: FTimes, TTime: TTime, ddlSubject: ddlSubject, ddlBatch: ddlBatch, ddlGroup: ddlGroup, topic: topic, whlclass: whlclass, ddlVenu: ddlVenu, ddlTeacher: ddlTeacher, ddlGetStuSub: ddlGetStuSub, chkhldy: chkhldy, chkbrk: chkbrk,
                    });
                });
            var StdTimetable = { "Subject_id": Subject_id, "program": program, "ddlClass": ddlClass, "ddlWeek": ddlWeek, "ddlBlock": ddlBlock, "ddlModule": ddlModule, "Save_list": Save_list };
            PageMethods.Replicate(JSON.stringify(StdTimetable), function () {
                window.location.href = 'StudentTimeTable.aspx'
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Replicate Data Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                    window.location = "TimeTableList.aspx";
                });
        }
        function SaveSubject() {
            debugger;
            var Subject_id = $('#Subject_id').val();
            var btnSave = $('#btnSave').val();

            var program = $('#program').val();
            var ddlClass = $('#ddlClass').val();
            var ddlWeek = $('#ddlWeek').val();
            var ddlBlock = $('#ddlBlock').val();
            var ddlModule = $('#ddlModule').val();

            if (!program || program === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Program',
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

            if (!ddlClass || ddlClass === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Class',
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

            if (!ddlWeek || ddlWeek === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Week',
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

            var Save_list = [];
            debugger;
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var Class = $($(value).find('td input[name=clas]')[0]).val();
                var txtClass = $($(value).find('td input[name=clas]')[0]).text();
                var Dates = $($(value).find('td input[name=Date]')[0]).val();
                var dt = new Date();
                var time = dt.getHours() + ":" + dt.getMinutes() + ":" + dt.getSeconds();
                var Dte = Dates.split('-');
                debugger;
                Dated = Dte[0];
                var today = Dated.trim();
                var day = today.split('/');
                var dat = new Date(parseInt(day[2]), parseInt(day[1]) - 1, parseInt(day[0]), null, null, null, null);
                debugger;

                DayName = Dte[1];
                var day = DayName.trim();
                debugger;
                var TTime = $($(value).find('td input[name=TTime]')[0]).val();
                if (TTime == null || TTime == 0 || TTime == "") {
                    TTime = time;
                }
                var FTimes = $($(value).find('td input[name=FTime]')[0]).val();
                if (FTimes == null || FTimes == 0 || FTimes == "") {
                    FTimes = time;
                }
                var ddlSubject = $($(value).find('td Select[name=ddlSubject]')[0]).val();
                var ddlBatch = $($(value).find('td Select[name=ddlBatch]')[0]).val();
                var ddlGroup = $($(value).find('td Select[name=ddlGroup]')[0]).val();
                var whlclass = $($(value).find('td input[name=whlclass]')[0]).prop("checked");
                var ddlGetStuSub = $($(value).find('td Select[name=ddlGetStuSub]')[0]).val();
                var chkhldy = $($(value).find('td input[name=chkhldy]')[0]).prop("checked");
                var ddlVenu = $($(value).find('td Select[name=ddlVenue]')[0]).val();
                var ddlTeacher = $($(value).find('td Select[name=ddlTeacher]')[0]).val();
                var chkbrk = $($(value).find('td input[name=chkbrk]')[0]).prop("checked");
                var topic = $($(value).find('td input[name=Topic]')[0]).val();
                Save_list.push({
                    Class: Class, txtClass: txtClass, dat: dat, day: day, FTimes: FTimes, TTime: TTime, ddlSubject: ddlSubject, ddlBatch: ddlBatch, ddlGroup: ddlGroup, whlclass: whlclass, topic: topic, ddlVenu: ddlVenu, ddlTeacher: ddlTeacher, ddlGetStuSub: ddlGetStuSub, chkhldy: chkhldy, chkbrk: chkbrk,
                });
            });
            var StdTimetable = { "Subject_id": Subject_id, "program": program, "ddlClass": ddlClass, "ddlWeek": ddlWeek, "ddlBlock": ddlBlock, "ddlModule": ddlModule, "Save_list": Save_list };
            PageMethods.SaveTimeTable(JSON.stringify(StdTimetable), btnSave, function ()
            {

                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                window.location ="TimeTableList.aspx";
            });
        }
        function Listopens() {
            window.location = "TimeTableList.aspx";
        }
        function newopen() {
            window.location = "StudentTimeTable.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-3 col-sm-3">
            <label><span style="color: red;">*</span>Program:</label>
            <select id="program" name="ddlProgram" onchange="Selectfunc()">
                <option value="">Select Program</option>
            </select>
            <input type="hidden" id="subject_id" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-3">
            <label><span style="color: red;">*</span>Class:</label>
            <select id="ddlClass" name="ddClass">
                <option value="">Select Class</option>
            </select>
            <input type="hidden" id="Subject_id" />
        </div>
        <div class="col-lg-2 col-md-3 col-sm-3">
            <label><span style="color: red;">*</span>Week:</label>
            <select id="ddlWeek">
                 <option value="">Select Week</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label>Block</label>
            <select id="ddlBlock" class="form-control">
                <option value="">Select Block</option>
            </select>
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label>Module</label>
            <select id="ddlModule" class="form-control">
                <option value="">Select Module</option>
            </select>
        </div>
        <div class="col-lg-1 col-md-3 col-sm-3">
            <input type="button" class="btn-primry" style="margin-top: 25px;" onclick="Addrow()" value="+" id="AddPerson" />
        </div>
    </div>
    <div id="Tab-1" class="mtop">
            <table class="table table-bordered" id="tblItemDescription">
                <thead>
                    <tr class="rowtr">
                       <th>Class</th>
                        <th style="width:7%">Date</th>
                        <th style="width:16%">Time</th>
                        <th >Subjects</th>
                        <th >Sub Subjects</th>
                        <th >Batch</th>
                        <th >Group</th>
                        <th>W.HClass</th>
                        <th style="width:9%">Topic</th>
                        <th>Teacher</th>
                        <th>Venue</th>
                        <th>Holiday</th>
                        <th>Break</th>
                        <th>Action</th>
                    </tr>
                </thead>                                           
                <tbody id="tblPerson">
                </tbody>
            </table>
    </div>
    <div class-="row">
        <div class="col-lg-8">
            <div class="row">
        <div class="col-lg-2 col-md-1 col-sm-3">
              <input type="button"  onclick="SaveSubject()" class="btn-primry"  id="btnSave" value="Save"  />
        </div>
                <div class="col-lg-2 col-md-1 col-sm-3">
                    <input type="button" onclick="Listopens()" class="btn btn-gray" id="List" value="List" />
                </div>
        <div class="col-lg-2 col-md-1 col-sm-3">
               <input type="button"  onclick="Replicates()"  class="btn-primry"  id="Replicate" value="Replicate" />
        </div>
        <div class="col-lg-2 col-md-1 col-sm-3">
                 <input type="button"  onclick="newopen()"  class="btn btn-yellow"  id="New" value="New"  />
        </div>
        <div class="col-lg-2 col-md-1 col-sm-3">
                <input type="button"  onclick="Print()" class="btn-primry"  id="print" value="Print"  />
        </div>
    </div>
     </div>
        </div>
 
</asp:Content>

