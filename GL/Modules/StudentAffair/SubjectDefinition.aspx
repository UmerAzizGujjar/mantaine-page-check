<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SubjectDefinition.aspx.cs" Inherits="PMS.SubjectDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .mtop {
            margin-top:15px;
        }
   
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            GetStudentprogram();
            GetStudentClass();

            debugger;
              <% if (Request.QueryString["ID"] != null)
        { %>
            var Stu_ID = '<%= Request.QueryString["ID"]%>'
             EditMasterSubject(Stu_ID);

            <% }%>
            $('#List').click(function () {
                window.location.href = "SubjectList.aspx";
            })
        });
        var counter = 3;
        var count = 4;
        var newTextBoxDiv;

        function addSubject() {
            debugger;

            var newTextBoxDiv = $(document.createElement('div'))
                .attr("id", 'subject' + counter)
                .addClass('row')
                .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

            newTextBoxDiv.after().html(`
                <div class="col-lg-2 col-md-3 col-sm-6"></div>
                <div class="col-lg-2 col-md-3 col-sm-6">
                    <label id="lbl${counter}" style="" class="rmv">Subject ${counter} :</label>
                    <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6">
                    <label id="lbl1${counter}" class="rmv" style="">Subject ${counter + 1} :</label>
                    <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
                </div>
                <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                    <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                        <i class="glyphicon glyphicon-trash" style="color:#f30a0a;font-size:17px;margin-top:25%;"></i>
                    </a>
                </div>
            `);

            $("#TextBoxesGroup").append(newTextBoxDiv);
            $('#ddlProgram').attr('disabled', 'disabled');
            $('#ddlClass').attr('disabled', true);

            counter += 2;
        }



        function RmvSubject(counterr) {
            debugger;

            var lblid = '#lbl' + counterr;
            var inputid = '#subject3' + counterr;
            var lbl1id = '#lbl1' + counterr;
            var input1id = '#subject4' + counterr;
            var btnid = '#rmvbtn' + counterr;
            var inputid3 = '#hdnsubject' + counterr;
            var inputid4 = '#hdnsubject4' + counterr;

            $(lblid).remove();
            $(inputid).remove();
            $(lbl1id).remove();
            $(input1id).remove();
            $(btnid).remove();
            $(inputid3).remove();
            $(inputid4).remove();
            counter -= 2;
            count -= 2;
        }
        function SubjectList() {
            debugger;
            window.location.href = "SubjectList.aspx";

        }
        function FormOpen() {
            debugger;
            window.location.href = "SubjectDefinition.aspx";
        }
        function GetStudentprogram() {
            var Getprgrm = '';
            $.ajax({
                url: 'SubjectDefinition.aspx/GetPrograms',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    debugger;
                    Getprgrm = '<option value="0">Please Select</option>';
                    debugger;
                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;

                        Getprgrm += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    });
                    $('#ddlProgram').html(Getprgrm);
                    $('#ddlProgram').select2();

                },
            });
        }
        function GetStudentClass() {
            var GetClass = '';
            $.ajax({
                url: 'SubjectDefinition.aspx/GetStudentClass',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    debugger;
                    GetClass = '<option value="0">Select</option>';
                    debugger;
                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;

                        GetClass += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    });
                    $('#ddlClass').html(GetClass);
                    $('#ddlClass').select2();

                },
            });
        }
        function Selectfunc() {
            debugger;
            var slct_value = $("#ddlProgram").val();

            if (slct_value == 01) {

                $($('#ddlClass').find('option')[1]).show();
                $($('#ddlClass').find('option')[2]).show();
                $($('#ddlClass').find('option')[3]).show();
                $($('#ddlClass').find('option')[4]).show();
                $($('#ddlClass').find('option')[5]).show();
            }
            else if (slct_value == 02) {
                $($('#ddlClass').find('option')[2]).hide();
                $($('#ddlClass').find('option')[3]).hide();
                $($('#ddlClass').find('option')[4]).hide();
                $($('#ddlClass').find('option')[5]).hide();
            }
            else if (slct_value == 03) {
                $($('#ddlClass').find('option')[1]).show();
                $($('#ddlClass').find('option')[2]).show();
                $($('#ddlClass').find('option')[3]).show();
                $($('#ddlClass').find('option')[4]).show();
                $($('#ddlClass').find('option')[5]).hide();
            }
        }
        debugger;
        function SaveSubject() {
            debugger;
            var Subject_id = $('#Subject_id').val();
            var btnSave = $('#btnSave').val();
            var ddlProgram = $('#ddlProgram').val();
            var ddlClass = $('#ddlClass').val();
            var newSelect = $('#inpval').val();
            if (newSelect == "0" && ddlProgram == "0") {
                alert("Please Select Program");
                $('#btnSave').attr('disabled', false);
                return;
            }
            if (newSelect == "0" && ddlClass == "0") {
                alert("please Select Class");
                $('#btnSave').attr('disabled', false);
                return;
            }



            var Arr = [];
            $('input[name="subject"]').each(function () {
                debugger;
                var Subject = $(this).val();

                Arr.push({
                    Subject: Subject,

                });
            });



            var Arr1 = [];
            $('input[name="hdnsubject"]').each(function () {
                debugger;

                var subjectDetailID = $(this).val();

                Arr1.push({

                    Subject_Detail_ID: subjectDetailID
                });
            });





            var Arr2 = [];

            var Subject1;
            for (let i = 0; i < Arr.length; i++) {
                debugger;

                var subjectDetailID1 = undefined;

                Subject1 = Arr[i].Subject;
                if (i < Arr1.length) {
                    subjectDetailID1 = Arr1[i].Subject_Detail_ID;
                }


                Arr2.push({
                    Subject: Subject1,
                    Subject_Detail_ID: subjectDetailID1
                });

            }


            debugger;
            var AllSubject = {
                Subject_id: Subject_id, ddlProgram: ddlProgram, ddlClass: ddlClass, Arr: Arr2,
            };


            PageMethods.SaveSubject(JSON.stringify(AllSubject), btnSave, function () {
                alert("Save Data Successfully");
                window.location = "SubjectList.aspx";
            });
        }
        function EditMasterSubject(Stu_ID) {

            PageMethods.editMaster(Stu_ID, function (resp) {
                var studata = JSON.parse(resp);

                $('#Subject_id').val(studata.subject_Id);


                $('#btnSave').val('Update');


                setTimeout(function () {
                    $('#ddlProgram').val(studata.Program).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlClass').val(studata.Class).trigger('change');
                }, 1000);
            })
            editDetail(Stu_ID);
        }

        function editDetail(Stu_ID) {
            debugger;
            PageMethods.EditDetail(Stu_ID, function (resp) {
                var studata = JSON.parse(resp);
                debugger;
                var dataCounts = studata.length - 1;
                if (dataCounts == 2) {
                    var NewCount = dataCounts - 1;
                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 3px;"name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 3px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 3px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px;margin-top:25%; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 3) {
                    debugger;

                    var NewCount = dataCounts - 2;
                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
                                <div class="col-lg-2 col-md-3 col-sm-6"></div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <label id="lbl${counter}" style="" class="rmv">Subject ${counter} :</label>
                                    <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <label id="lbl1${counter}" class="rmv" style="">Subject ${count} :</label>
                                    <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
                                </div>
                                <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                                    <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                                        <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%; "></i>
                                    </a>
                                </div>
                            `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 4) {
                    debugger;
                    var NewCount = dataCounts - 1;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
            <div class="col-lg-2 col-md-3 col-sm-6"></div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
            </div>
            <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                    <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                </a>
            </div>
             `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }


                        else if (dataCounts == 5) {
                        debugger;
                        var NewCount = dataCounts - 3;
                        for (let i = 0; i < NewCount; i++) {

                            newTextBoxDiv = $(document.createElement('div'))
                                .attr("id", 'subject' + counter + count)
                                .addClass('row') 
                                .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' }); 

                            newTextBoxDiv.html(`
                                <div class="col-lg-2 col-md-3 col-sm-6"></div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                                    <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-6">
                                    <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                                    <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
                                </div>
                                <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                                    <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                                        <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                                    </a>
                                </div>
                            `);

                            newTextBoxDiv.appendTo("#TextBoxesGroup");
                            counter += 2;
                            count += 2;
                        }
                    }

                else if (dataCounts == 6) {
                    debugger;
                    var NewCount = dataCounts - 2;

                    for (let i = 0; i < NewCount; i++) {
                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
            <div class="col-lg-2 col-md-3 col-sm-6"></div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
            </div>
            <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                    <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                </a>
            </div>
        `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 7) {
                    debugger;
                    var NewCount = dataCounts - 4;

                    for (let i = 0; i < NewCount; i++) {
                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
            <div class="col-lg-2 col-md-3 col-sm-6"></div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
            </div>
            <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                    <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                </a>
            </div>
        `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");

                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 8) {
                    debugger;
                    var NewCount = dataCounts - 4;

                    for (let i = 0; i < NewCount; i++) {
                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
            <div class="col-lg-2 col-md-3 col-sm-6"></div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
            </div>
            <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                    <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                </a>
            </div>
        `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");

                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 9) {
                    debugger;
                    var NewCount = dataCounts - 5;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 3px;"  name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 3px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 3px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }

                else if (dataCounts == 10) {
                    debugger;
                    var NewCount = dataCounts - 5;

                    for (let i = 0; i < NewCount; i++) {
                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count)
                            .addClass('row')
                            .css({ 'margin-top': '10px', 'align-items': 'center', 'justify-content': 'center' });

                        newTextBoxDiv.html(`
            <div class="col-lg-2 col-md-3 col-sm-6"></div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl${counter}" class="rmv">Subject ${counter} :</label>
                <input class="sbj rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject3${counter}" value="">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-6">
                <label id="lbl1${counter}" class="rmv">Subject ${count} :</label>
                <input class="rmv form-control" style="margin-left:3px;" type="text" name="subject" id="subject4${counter}" value="">
            </div>
            <div class="col-lg-1 col-md-1 col-sm-2 d-flex justify-content-center align-items-center">
                <a href="#" id="rmvbtn${counter}" onclick="RmvSubject(${counter})">
                    <i class="glyphicon glyphicon-trash" style="color:#f30a0a; font-size:17px;margin-top:25%;"></i>
                </a>
            </div>
        `);

                        newTextBoxDiv.appendTo("#TextBoxesGroup");

                        counter += 2;
                        count += 2;
                    }
                }


                else if (dataCounts == 11) {
                    debugger;
                    var NewCount = dataCounts - 6;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 12) {
                    debugger;
                    var NewCount = dataCounts - 6;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);
                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 13) {
                    debugger;
                    var NewCount = dataCounts - 7;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);
                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;"  name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 14) {
                    debugger;
                    var NewCount = dataCounts - 7;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;"  name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 15) {
                    debugger;
                    var NewCount = dataCounts - 8;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 16) {
                    debugger;
                    var NewCount = dataCounts - 8;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 17) {
                    debugger;
                    var NewCount = dataCounts - 9;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 18) {
                    debugger;
                    var NewCount = dataCounts - 9;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;"  name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 19) {
                    debugger;
                    var NewCount = dataCounts - 10;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);

                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;"  name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                else if (dataCounts == 20) {
                    debugger;
                    var NewCount = dataCounts - 10;

                    for (let i = 0; i < NewCount; i++) {

                        newTextBoxDiv = $(document.createElement('div'))
                            .attr("id", 'subject' + counter + count);


                        newTextBoxDiv.after().html('<label id="lbl' + counter + '" style="margin-left:34px" class="rmv">Subject ' + counter + ' : </label>' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject' + counter + '" value="" type="hidden" >' +
                            '<input class="sbj" style="margin-left: 11px;" type="text" name="subject' +
                            '" id="subject3' + counter + '" value="" >' + '<label id="lbl1' + counter + '" class="rmv"  style="margin-left:40px">Subject ' + count + ' : </label>' + '<input style="margin-left: 9px;" class="rmv" type="text" name="subject' +
                            '" id="subject4' + counter + '" value="" >' +
                            '<input class="sbj" style="margin-left: 11px;" name="hdnsubject' +
                            '" id="hdnsubject4' + counter + '" value="" type="hidden" >' + '  <a href="#" id="rmvbtn' + counter + '"   onclick="RmvSubject(' + counter + ')"  ><i  class="glyphicon glyphicon-trash" style="color: #f30a0a; font-size:17px; margin-left: 33px; "></i></a>');

                        newTextBoxDiv.appendTo("#TextBoxesGroup");
                        counter += 2;
                        count += 2;
                    }
                }
                debugger;

                $('input[name="subject"]').each(function (key, value) {
                    debugger;
                    if (studata[key] != undefined || studata[key] != null) {
                        $("#" + value.id).val(studata[key].Subject_Name);
                    }


                });
                debugger;

                $('input[name="hdnsubject"]').each(function (key, value) {
                    if (studata[key] != undefined || studata[key] != null) {
                        $("#" + value.id).val(studata[key].Subject_Detail_ID);
                    }
                    debugger;


                });
            });

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row" id="row1" style=" min-height:440px;">
                <div class="row">
                     <div class="col-lg-2 col-md-3 col-sm-6">
                         </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label>Program:</label>
                         <select id="ddlProgram" onchange="Selectfunc()"  class="fcux"></select>
                             <input type="hidden" id="Subject_id"  />
                    </div> 
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label>Class:</label>
                             <select id="ddlClass"   class="fcux"></select>
                             <input type="hidden" value="0" id="inpval" />
                    </div>
                </div>
                <div class="row mtop">
                    <div class="col-lg-2 col-md-3 col-sm-6"></div>  
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label for="subject" class="rmv">Subject 1:</label>
                        <input type="text" id="subject1" class="sbj" name="subject" />
                        <input class="sbj" name="hdnsubject" id="hdnsubject1" value="" type="hidden" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label for="subject" class="rmv">Subject 2 :</label>
                        <input type="text" id="subject2" class="sbj" name="subject" />
                        <input class="sbj" name="hdnsubject" id="hdnsubject2" value="" type="hidden" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <a href="#" id="addButton" style="margin-top:10px;" onclick="addSubject()">
                            <i class="fa fa-plus-circle" style="font-size:35px; margin-top:24px; color:#438eb9 ;"></i>
                        </a>
                    </div>
                </div>

<div class="row" id="TextBoxesGroup"></div> <!-- This is where new textboxes will be appended -->
     </div>
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button"  onclick="SaveSubject()" class="btn-primry"   id="btnSave"" value="Save"  />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" onclick="SubjectList()" class="btn btn-gray" id="List"" value="ListView" />
                    </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" onclick="FormOpen()" id="NewForm" class="btn btn-yellow" value="New" />
        </div>    
            </div>
            </div>
    </div>
</asp:Content>

