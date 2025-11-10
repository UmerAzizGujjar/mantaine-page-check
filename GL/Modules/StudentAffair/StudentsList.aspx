<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentsList.aspx.cs" Inherits="PMS.StudentsList" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            GetFromClass();
            GetToClass();
            updatebill();
            GetBatch();
            GetGroup();
            GetStudentprogram();

            $("#txt_WholeClass").prop("checked", true);

            var table = $('#studentsTable').DataTable({
                "processing": true,
                "serverSide": true,
                "filter": true,
                "lengthChange": true,
                "pageLength": 25,
                "ajax": {
                    "type": "POST",
                    "url": "StudentsList.aspx/ViewList",
                    "contentType": "application/json; charset=utf-8",
                    "dataType": "json",
                    "data": function (d) {
                        return JSON.stringify({
                            draw: d.draw,
                            start: d.start,
                            length: d.length,
                            sortColumn: d.columns[d.order[0].column].data || "Student_Id",
                            sortColumnDirection: d.order[0].dir,
                            searchValue: d.search.value,

                            Class: $('#ddlFromClass').find('option:selected').val() || "",
                            Isactive: $('#Isactive').prop("checked"),
                            Noactive: $('#Noactive').prop("checked"),
                            ddlProgram: $("#ddlProgram").find('option:selected').val() || "",
                            ddlBatch: $("#ddlBatch").find('option:selected').val() || "",
                            ddlGroup: $("#ddlGroup").find('option:selected').val() || "",
                            txt_WholeClass: $("#txt_WholeClass").prop("checked")
                        });
                    },
                    "dataSrc": function (json) {
                        var response = JSON.parse(json.d);
                        $('#txtAllStudent').val(response.recordsTotal);
                        return response.data;
                    },
                    "error": function (xhr, error, thrown) {
                        console.error("DataTables AJAX error:", xhr.responseText);
                    }
                },
                "columns": [
                    {
                        "data": null,
                        "orderable": false,
                        "render": function () {
                            return '<input type="checkbox" class="chcktbl" />';
                        }
                    },
                    {
                        data: "AdmissionDate",
                        render: function (data) {
                            return data ? moment(data).format('L') : '';
                        }
                    },
                    { "data": "Roll_No" },
                    { "data": "Class" },
                    { "data": "Full_Name" },
                    { "data": "Father_Name" },
                    { "data": "Student_CNIC" },
                    { "data": "Student_Contact_No" },
                    { "data": "Batch" },
                    { "data": "Groups" },
                    { "data": "Sesion" },
                    {
                        "data": "Student_Id",
                        "orderable": false,
                        "render": function (data, type, row) {
                            return '<a class="HRlink" href="#" onclick="editOpen(' + data + ')">Edit</a> | ' +
                                '<a href="#" onclick="deleteConfirm(this)" data-id="' + data + '">Delete</a>';
                        }
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        var labelText = document.createElement('span');
                        labelText.textContent = 'Show entries ';
                        labelText.style.marginTop = '10px';
                        labelText.style.display = 'inline-block';

                        lengthDropdown.style.width = '60px';
                        label.innerHTML = '';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '17px';
                        label.appendChild(labelText);
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });

            $('#ddlFromClass, #ddlProgram, #ddlBatch, #ddlGroup, #txt_WholeClass, #Isactive, #Noactive, #txtSearch')
                .off('change keyup')
                .on('change keyup', function () {
                    table.ajax.reload();
            });
        });
        debugger;
        var userupdate;
        function updatebill() {
            debugger;

            $.ajax({
                type: "POST",
                url: "StudentsList.aspx/updatebills",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    userupdate = data.d;

                },
                failure: function () {

                    alert(bi);
                }
            });
        }
        function editOpen(id) {

            window.open("AddStudent.aspx?ID=" + id + "");

        }
        debugger;
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var StudentId = $($(row).find('td input[name=txt_Student_Id]')[0]).val();
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(StudentId, function (msg) {
                    if (msg == "Delete") {
                        row.remove();
                    }
                    else {
                        alert("This Student Can't be deleted")
                    }
                }, OnFail);
            }
        }
        function OnFail(exc) {
            alert(exc.get_message());
        }
        function GetFromClass(d) {
            var options = '<option value="">Select Class</option>';
            PageMethods.GetFromClass(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#ddlFromClass').html(options);
            });
        }
        function GetToClass(d) {
            var options = '';
            PageMethods.GetToClass(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#ddlToClass').html(options);
            });
        }


        function UpdateData() {

            if (userupdate == false || userupdate == "False" || userupdate == 'False') {
                debugger;
                alert("You Dont Have Rights");
                $('#update').attr('disabled', true)
                return;
            }
            else {

                $('#update').attr('disabled', false);
            }
            debugger;
      
            var table = $('#tbody');
            var Update_list = [];
            table.find('tr input[type=checkbox]:checked:visible').each(function (key, value) {

                Update_list.push({

                    'txtStudent_Id': $(value).closest('tr').find('td input[name=txt_Student_Id]').val(),
                    'Class_Value': $('#ddlToClass').find('option:selected').val()
                });

            });

            $.ajax({
                type: "post",
                url: "StudentsList.aspx/Update",

                data: JSON.stringify({
                    "Update_list": Update_list,

                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                success: function (msg) {
                    //success message
                    debugger;
                    swal({
                        title: "Data Successfully Save!",
                        icon: "success",
                        buttons: false,
                    });
                    //alert(msg.d)
                    location.reload();

                },
                error: function (err) {
                    //error message
                    alert(err.d)
                }
            });
            window.location = "StudentsList.aspx";
        }

        function Print() {

            var Class = $('#ddlFromClass').find('option:selected').val();
            var Isactive = $('#Isactive').prop("checked");
            var Noactive = $('#Noactive').prop("checked");
            var ddlProgram = $("#ddlProgram").find('option:selected').val();
            var ddlBatch = $("#ddlBatch").find('option:selected').val();
            var ddlGroup = $("#ddlGroup").find('option:selected').val();
            var txt_WholeClass = $("#txt_WholeClass").prop("checked");

            window.open('ReportViewer.aspx?ReportName=StudentList&ReportTitle=StudentList' + '&Class=' + Class + '&Isactive=' + Isactive + '&Noactive=' + Noactive + '&Program=' + ddlProgram + '&Batch=' + ddlBatch + '&Group=' + ddlGroup + '&WholeClass=' + txt_WholeClass);
        }


        function Selectfunc() {
            debugger;
            var currentYear = (new Date).getFullYear();

            var slct_value = $("#ddlProgram").val();

            if (slct_value == 02) {
                var yearmbbs = currentYear + 5;
                $('#txtSession').val(currentYear + '-' + yearmbbs);
                $($('#ddlClass').find('option')[1]).show();
                $($('#ddlClass').find('option')[2]).show();
                $($('#ddlClass').find('option')[3]).show();
                $($('#ddlClass').find('option')[4]).show();
                $($('#ddlClass').find('option')[5]).show();
            }
            else if (slct_value == 01) {
                var yearhealth = currentYear + 2;
                $('#txtSession').val(currentYear + '-' + yearhealth)
                $($('#ddlClass').find('option')[2]).hide();
                $($('#ddlClass').find('option')[3]).hide();
                $($('#ddlClass').find('option')[4]).hide();
                $($('#ddlClass').find('option')[5]).hide();
            }
            else if (slct_value == 03) {
                var yearBds = currentYear + 1;
                $('#txtSession').val(currentYear + '-' + yearBds)
                $($('#ddlClass').find('option')[1]).show();
                $($('#ddlClass').find('option')[2]).show();
                $($('#ddlClass').find('option')[3]).show();
                $($('#ddlClass').find('option')[4]).show();
                $($('#ddlClass').find('option')[5]).hide();
            }
        }
        function GetStudentprogram() {
            var Getprgrm = '';
            $.ajax({
                url: 'AddStudent.aspx/GetPrograms',
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

                },
            });
        }

        function GetBatch() {
            var GetBatch = '';
            $.ajax({
                url: 'AddStudent.aspx/StudentBatch',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    debugger;
                    GetBatch = '<option value="0">Select</option>';

                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;

                        GetBatch += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    });
                    $('#ddlBatch').html(GetBatch);
                },
            });
        }
        function GetGroup() {
            var GetGroup = '';
            $.ajax({
                url: 'AddStudent.aspx/StudentGroup',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (data) {
                    debugger;
                    GetGroup = '<option value="0">Select</option>';

                    $.each(JSON.parse(data.d), function (key, value) {
                        debugger;

                        GetGroup += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlGroup').html(GetGroup);
                },
            });
        }
        debugger;
        //function LoadData() {

        //    var Class = $('#ddlFromClass').find('option:selected').val();
        //    var search = $('#txtSearch').val();
        //    var Isactive = $('#Isactive').prop("checked");
        //    var Noactive = $('#Noactive').prop("checked");
        //    var ddlProgram = $("#ddlProgram").find('option:selected').val();
        //    var ddlBatch = $("#ddlBatch").find('option:selected').val();
        //    var ddlGroup = $("#ddlGroup").find('option:selected').val();
        //    var txt_WholeClass = $("#txt_WholeClass").prop("checked");

        //    debugger;
        //    $.ajax({

        //        type: "POST",
        //        url: "StudentsList.aspx/ViewList",
        //        data: JSON.stringify({
        //            "Class": Class,
        //            "Search": search,
        //            "Isactive": Isactive,
        //            "Noactive": Noactive,
        //            "ddlProgram": ddlProgram,
        //            "ddlBatch": ddlBatch,
        //            "ddlGroup": ddlGroup,
        //            "txt_WholeClass": txt_WholeClass


        //        }),
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",

        //        success: function (newdata) {
                    

        //            var data = JSON.parse(newdata.d);
        //            var Count = 0;
        //            $('#tbl tr:gt(0)').remove();
        //            table = $('#tbody');
        //            table.empty();
        //            $.each(data, function (key, value) {

        //                Count = Count + value.Totalcount;


        //                if (value.Admission == "null" || value.Admission == null || value.Admission == "") {
        //                    value.Admission = "";
        //                }

        //                if (value.Sesion == "null" || value.Sesion == null || value.Sesion == "") {
        //                    value.Sesion = "";
        //                }


        //                var AdmissionDate = value.Created_time;
        //                AdmissionDate = moment(AdmissionDate).format('L');

        //                if (AdmissionDate == "null" || AdmissionDate == "Invalid date" || AdmissionDate == null || AdmissionDate == 'null') {
        //                    AdmissionDate = "";
        //                }

        //                var batch = value.Batch;
        //                var Groups = value.Groups;



        //                if (batch == null) {
        //                    batch = ' ';
        //                }

        //                if (Groups == null) {
        //                    Groups = ' ';
        //                }

                     
        //                $("#tbody").append(
        //                    '<tr>' + '<td><input type="checkbox" class ="chcktbl" id = "chcktbl"  name="chkReport' + (key + 1) + '" value="false"/></td>' +

        //                    '<td style="display:none"><input type="hidden" id="txt_Student_Id' + (key + 1) + '" name="txt_Student_Id" value="' + value.Student_Id + '"/>' + value.Student_Id + '</td>' +

        //                    '<td><input type="hidden" id="txt_JoiningDate' + (key + 1) + '" name="txt_JoiningDate" value="' + AdmissionDate + '"/>' + AdmissionDate + '</td>' +

        //                    '<td ><input type="hidden" id="txt_RollNo' + (key + 1) + '" name="txt_RollNo" value="' + value.Student_Id + '"/>' + value.Roll_No + '</td>' +

        //                    '<td><input type="hidden" id="txt_Class' + (key + 1) + '" name="txt_Class" value="' + value.Student_Id + '"/>' + value.Class + '</td>' +

        //                    '<td><input type="hidden" id="txt_FullName' + (key + 1) + '" name="txt_FullName" value="' + value.Student_Id + '"/>' + value.Full_Name + '</td>' +


        //                    '<td><input type="hidden" id="txt_FatherName' + (key + 1) + '" name="txt_FatherName" value="' + value.Student_Id + '"/>' + value.Father_Name + '</td>' +


        //                    '<td><input type="hidden" id="txt_CNIC' + (key + 1) + '" name="txt_CNIC" value="' + value.Student_Id + '"/>' + value.Student_CNIC + '</td>' +


        //                    '<td><input type="hidden" id="txtTelephone' + (key + 1) + '" name="txtTelephone" value="' + value.Student_Id + '"/>' + value.Student_Contact_No + '</td>' +

        //                    '<td><input type="hidden" id="txtBatch' + (key + 1) + '" name="txtBatch" value="' + value.Student_Id + '"/>' + batch + '</td>' +

        //                    '<td><input type="hidden" id="txtGroups' + (key + 1) + '" name="Groups" value="' + value.Student_Id + '"/>' + Groups + '</td>' +

        //                    '<td><input type="hidden" id="txt_Sesion' + (key + 1) + '" name="txt_Sesion" value="' + value.Student_Id + '"/>' + value.Sesion + '</td>' +

        //                    '<td>' + '<a class="HRlink" href="#" onclick=editOpen(' + value.Student_Id + ')>Edit</a>' +
        //                    ' | <a href="#" onclick=deleteConfirm(this)>Delete</a>' + '</td>' +
        //                    '</tr>');
        //                length++;


        //                return true;
        //            });
        //            $('#txtAllStudent').val(Count);
        //        }
        //    });
        //}

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Program</label>
                <select id="ddlProgram" name="program"  onchange="Selectfunc()">                        
                </select>
            </div>

        <div class="col-lg-2 col-md-4 col-sm-6">
                  <label>FromClass</label>             
                <select id="ddlFromClass" onchange="LoadData()"></select>
            </div>

        <div class="col-lg-2 col-md-4 col-sm-6">
                 <label>ToClass</label>
                 <select  id="ddlToClass"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
                 <label>Group</label>
                 <select id="ddlGroup" onchange="LoadData()"></select>
            </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
                  <label>Batch</label>
                  <select id="ddlBatch" onchange="LoadData()"></select>
        </div>
        <div class=" col-md-1 col-sm-6" style="margin-top:2%">
                 <label>WholeClass</label>
            </div>
            <div class="col-md-1 col-sm-6" style="margin-top:2%;margin-left:-6%">
                <input type="checkbox" id="txt_WholeClass" />
            </div>      
             </div>
      
    <div class="row" style="margin-top:2%">
         <div class="col-lg-1 col-md-4 col-sm-6">
           <input type="button" id="aadnew" class="btn-primry" value="Add New" onclick="location.href = 'AddStudent.aspx';" />
       </div>

        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" class="btn-primry" value="Print" name="name" onclick="Print();"/>
        </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                 <input type="button" class="btn-primry" id="update" value="Update" onclick="UpdateData()" />
            </div>
    </div>


    <div class="row" style="margin-top: 40px;">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Search Your Students: </label>
            <input type="text" id="txtSearch" onkeyup ="LoadData()" />
        </div>
        <div class="col-md-2" style="display: flex; align-items: center; gap: 10px;">
            <label for="Isactive">
                IsActive
        <input type="checkbox" id="Isactive" onchange="LoadData()" />
            </label>
            <label for="Noactive">
                NoActive
        <input type="checkbox" id="Noactive" onchange="LoadData()" />
            </label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6"></div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Total Students: </label>
            <input type="text" id="txtAllStudent" readonly="" />
        </div>
    </div>


    <div style="overflow: scroll; height: 500px;margin-top: 22px;">
        <table id="studentsTable" class="table table-sm table-bordered table-hover table-striped" style="width:100%">
    <thead>
        <tr>
            <th><input type="checkbox" id="chckHead" /></th>
            <th>Joining Date</th>
            <th>Roll No</th>
            <th>Class</th>
            <th>Full Name</th>
            <th>Father Name</th>
            <th>NIC Number</th>
            <th>Telephone</th>
            <th>Batch</th>
            <th>Group</th>
            <th>Session</th>
            <th>Actions</th>
        </tr>
    </thead>
</table>
    </div>
</asp:Content>
