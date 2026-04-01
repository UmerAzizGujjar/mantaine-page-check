<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Doctor_Template.aspx.cs" Inherits="PMS.Doctor_Template" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            loaddoctor();
            loadPharmcayList();
            FillMainTestDepartment();
            debugger;
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                debugger;
                $('#btnSave').val('Update');
                LoadMasterData(id);
                setTimeout(function () {
                    LoadTestData(id);
                    LoadMedicineData(id);
                }, 1000);

            }
        });
        function LoadMasterData(id) {
            $.ajax({
                type: "POST",
                url: "Doctor_Template.aspx/LoadMasterData",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parsed_Data = JSON.parse(response.d);
                    $("#txtTempelateID").val(parsed_Data.Template_Id);

                    setTimeout(function () {
                        $("#ddlDoctor").val(parsed_Data.Doctor_Id).trigger('change');
                    }, 1000);
                    $('#isActive').val(parsed_Data.isActive); if (parsed_Data.isActive == 1) { $("#isActive").prop('checked', true); }
                    $("#Tem_Name").val(parsed_Data.Template_Name)

                }, error: function () { }
            });
        }

        function FillProcedure(deptID) {
            debugger;
            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetProcedure(deptID, function (item) {
                debugger;
                $.each(JSON.parse(item), function (key, value) {
                    debugger;
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                });

                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();

            });
        }

        function LoadMedicineData(id) {
            debugger;
            PageMethods.LoadMedicineData(id, function (resp) {
                debugger;
                var datas = JSON.parse(resp);



                $.each(datas, function (key, data) {

                    var Medicine_id = data.Medicine_id || [];
                    var Medicine_Name = data.Medicine_Name || [];
                    var IsPharmacys = data.IsPharmacy;
                    // Append new rows for medicines
                    var rows = '';
                    var rowlength = Medicine_Table.rows.length;
                    rows = '<tr>' +
                        '<td style="display:none">' +
                        '<input type="text" style="display:none" name="itemid" id="itemid' + rowlength + '" value="' + Medicine_id + '" />' + Medicine_id +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="ddlmed" id="ddlmed' + rowlength + '" value="' + Medicine_Name + '" />' + Medicine_Name +
                        '</td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                        '</td>' +
                        '</tr>'
                    $('#Medt_body').append(rows);

                });
            });
        }

        function LoadTestData(id) {
            debugger;
            PageMethods.LoadTestData(id, function (resp) {
                debugger;
                var datas = JSON.parse(resp);

                // Clear existing rows before appending new ones

                $.each(datas, function (key, data) {
                    var test_ids = data.Test_Id || [];
                    var Department_id = data.Department_id || [];
                    var Department_Name = data.Department_Name || [];
                    var Test_Name = data.Test_Name || [];
                    var Rotation_Id = data.Rotation_Id || [];
                    var Rotation_Name = data.Rotation_Name || [];

                    var rowlength = Test_Table.rows.length;
                    rows = '<tr>' +
                        '<td style="display:none">' +
                        '<input type="hidden" name="depid" id="depid' + rowlength + '" value="' + Department_id + '" />' + Department_id +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="ddlDepname" id="ddlDepname' + rowlength + '" value="' + Department_Name + '" />' + Department_Name +
                        '</td>' +
                        '<td style="display:none">' +
                        '<input type="hidden" name="testid" id="testid' + rowlength + '" value="' + test_ids + '" />' + test_ids +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="testname" id="testname' + rowlength + '" value="' + Test_Name + '" />' + Test_Name +
                        '</td >' +
                        '<td style="display:none">' +
                        '<input type="hidden" name="rotid" id="rotid' + rowlength + '" value="' + Rotation_Id + '" />' + Rotation_Id +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="rotname" id="rotname' + rowlength + '" value="' + Rotation_Name + '" />' + Rotation_Name +
                        '</td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                        '</td>' +
                        '</tr>'
                    $('#Testt_body').append(rows);

                });
            });
        }
        debugger;
        var Medics = '';
        function loadOriginatorsItemList(Medicine_ids) {
            debugger
            var item = Medicine_ids
            PageMethods.Loadpharmacyitems(item, function (resp) {
                optionsUser = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
                    Medics += '<option value="' + value.Item_Code + '" >' + value.Description + '</option>';
                });

            },
                function (error) {
                    alert(error.get_message());
                });
        }





        //function loaddoctor() {
        //    PageMethods.LoadDoctor(function (res) {
        //        var doctor = JSON.parse(res);
        //        var options = '';
        //        var rowsText = '';
        //        $.each(doctor, function (key, value) {
        //            options = '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
        //        });
        //        $('#ddlDoctor').html(options)
        //        $('#ddlDoctor').select2();
        //    });
        //}

        function loaddoctor() {
            PageMethods.LoadDoctor(function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0">Please Select</option>';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                });
                $('#ddlDoctor').html(options);
                $('#ddlDoctor').select2();
            });
        }

        function FillMainTestDepartment() {

            var options = '<option value="0" >Select Main Department</option>';

            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlDepartment').html(options);
                $('#ddlDepartment').select2();
            });
        }
        function FillLabTests() {
            debugger;
            var options = '<option value="0" >Please Select</option>';
            PageMethods.GetLabTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }

        function FillTestsByCategory(CategoryID) {
            debugger;
            var options = '<option value="0" >Please Select</option>';

            if (CategoryID == '002') {
                $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#ddlRotation').show();
                $('#ddlXRayLF').show();

                PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                    debugger;
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        debugger;
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }
            else if (CategoryID == '004') {
                debugger;
                $("#btnCTscan").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                $('#ddlXRayLF').hide();
                $('#ddlRotation').show();

                PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                    debugger;
                    var options = '<option value="0" >Select</option>';
                    $.each(JSON.parse(GetRotations), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlRotation option').remove()
                    $('#ddlRotation').html(options);
                    $('#ddlRotation').select2();
                });
            }


            PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                debugger;
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    options += '<option value="' + value.Test_ID + '">' + value.Test_Name + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
            });
        }
        function LoadTestByDepartment() {
            debugger;
            var maindpt = $('#ddlDepartment').val();
            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
            }
            if (maindpt == "001") {

                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
                FillLabTests();

            }
            else if (maindpt == "002") {
                FillTestsByCategory('002');
                $('#ddlXRayLF').hide();
                $('#ddlRotation').hide();
            }
            else if (maindpt == "003") {
                FillTestsByCategory('003');
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "004") {
                FillTestsByCategory('004');
                $('#ddlXRayLF').hide();

            }
            else if (maindpt == "005") {

                FillProcedure("005");
                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "006") {

                FillProcedure("006");
                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "007") {

                FillProcedure("007");
                $('#ddlRotation').hide();
                $('#ddlXRayLF').hide();
            }
        }
        debugger;
        function AppendTest() {
            debugger
            var selectedDepartment = $('#ddlDepartment option:selected');
            var departmentValue = selectedDepartment.val();
            var departmentText = selectedDepartment.text();
            var selectedTest = $('#ddlTestList option:selected');
            var testValue = selectedTest.val();
            var testname = selectedTest.text();
            var selectedRotation = $('#ddlRotation option:selected');
            var rotationValue = selectedRotation.val();
            var rotationText = selectedRotation.text();

            if (rotationValue == undefined) {
                rotationValue = '';
                rotationText = '';
            }

            if (departmentValue && testValue !== "0") {
                var rows = '';
                var rowlength = Test_Table.rows.length;
                rows = '<tr>' +
                    '<td style="display:none">' +
                    '<input type="hidden" name="depid" id="depid' + rowlength + '" value="' + departmentValue + '" />' + departmentValue +
                    '</td>' +
                    '<td>' +
                    '<input type="hidden" name="ddlDepname" id="ddlDepname' + rowlength + '" value="' + departmentText + '" />' + departmentText +
                    '</td>' +
                    '<td style="display:none">' +
                    '<input type="hidden" name="testid" id="testid' + rowlength + '" value="' + testValue + '" />' + testValue +
                    '</td>' +
                    '<td>' +
                    '<input type="hidden" name="testname" id="testname' + rowlength + '" value="' + testname + '" />' + testname +
                    '</td >' +
                    '<td style="display:none">' +
                    '<input type="hidden" name="rotid" id="rotid' + rowlength + '" value="' + rotationValue + '" />' + rotationValue +
                    '</td>' +
                    '<td>' +
                    '<input type="hidden" name="rotname" id="rotname' + rowlength + '" value="' + rotationText + '" />' + rotationText +
                    '</td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                    '</td>' +
                    '</tr>'
                $('#Testt_body').append(rows);

            }
        }
        function AppendMed() {
            debugger
            var selectedOption = $('#ddlMedicine option:selected');
            var selectedValue = selectedOption.val();
            var selectedText = selectedOption.text();
            if (selectedValue && selectedValue !== "0") {
                var rows = '';
                var rowlength = Medicine_Table.rows.length;
                rows = '<tr>' +
                    '<td style="display:none">' +
                    '<input type="text" style="display:none" name="itemid" id="itemid' + rowlength + '" value="' + selectedValue + '" />' +
                    '</td>' +
                    '<td>' +
                    '<input type="hidden" name="ddlmed" id="ddlmed' + rowlength + '" value="' + selectedText + '" />' + selectedText +
                    '</td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                    '</td>' +
                    '</tr>'
                $('#Medt_body').append(rows);
            }
        }
        function loadPharmcayList() {
            debugger;
            var searchString = '';
            var optionsUser = '';
            PageMethods.getpharmacyitems(searchString, function (resp) {
                optionsUser = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsUser += '<option value="' + value.Item_Code + '" >' + value.Description + '</option>';
                });
                $('#ddlMedicine').html(optionsUser);
                $('#ddlMedicine').select2();
            });
        }
        var activeSelect2Id = null;
        $(document).on('select2:open', function (e) {
            activeSelect2Id = $(e.target).attr('id');
            console.log('Opened Select2 element with ID:', activeSelect2Id);
        });
        $(document).on('keyup', '.select2-search__field', function () {
            debugger;
            var searchString = $(this).val();
            if (activeSelect2Id) {
                console.log('Working on Select2 element with ID:', activeSelect2Id);
                var optionsUser = '';
                PageMethods.getpharmacyitems(searchString, function (resp) {
                    optionsUser = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(resp), function (key, value) {
                        debugger;
                        optionsUser += '<option value="' + value.Item_Code + '" >' + value.Description + '</option>';
                    })
                    debugger;
                    $('#' + activeSelect2Id).append(optionsUser);
                });
            } else {
                console.error('No active Select2 element ID found.');
            }
        });


        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        debugger;

        function SaveRecord() {
            var Temp_Id = $('#txtTempelateID').val();
            if (Temp_Id === "") {
                Temp_Id = null; // Set to null if empty
            }
            var btnSave = $('#btnSave').val();
            var Doctor_Id = $('#ddlDoctor').val();
            var Tem_Name = $('#Tem_Name').val();
            var isActive = $('#isActive').prop('checked');

            var medList = [];
            var testList = [];
            var Medtable = $('#Medt_body');
            var Testtable = $('#Testt_body');

            $('#Medt_body tr').each(function (key, value) {
                var ddlMed = $(this).find('input[name="itemid"]').val();
                var ddlMedName = $(this).find('input[name="ddlmed"]').val();
                if (ddlMed) {
                    medList.push({ MedicineId: ddlMed, MedicineName: ddlMedName });
                }
            });

            $('#Testt_body tr').each(function (key, value) {
                var dep_id = $(this).find('input[name="depid"]').val();
                var dep_Name = $(this).find('input[name="ddlDepname"]').val();
                var test_id = $(this).find('input[name="testid"]').val();
                var test_Name = $(this).find('input[name="testname"]').val();
                var Rotation_id = $(this).find('input[name="rotid"]').val() || '';
                var Rotation_Name = $(this).find('input[name="rotname"]').val();

                if (dep_id && test_id) {
                    testList.push({
                        DepartmentId: dep_id,
                        DepartmentName: dep_Name,
                        TestId: test_id,
                        TestName: test_Name,
                        RotationId: Rotation_id,
                        RotationName: Rotation_Name
                    });
                }
            });

            console.log(testList);
            console.log(medList);
            if (Doctor_Id == '0' && Tem_Name == '') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Doctor OR Template',
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

            $.ajax({
                type: "POST",
                url: "Doctor_Template.aspx/SaveRecord",
                data: JSON.stringify({
                    btnSave: btnSave,
                    Temp_Id: Temp_Id,
                    Doctor_Id: Doctor_Id,
                    isActive: isActive,
                    Tem_Name: Tem_Name,
                    medList: medList,
                    testList: testList
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = response.d;
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data has been saved successfully',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    window.location.href = "Doctor_Template.aspx?ID=" + data;
                },
                error: function (xhr, status, error) {
                    console.error(xhr.responseText);
                }
            });
        }

    </script>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtTempelateID" name="txtTempelateID" />
    <div class="row">
        <div class="col-lg-3 col-md-5 col-sm-12">
            <label>Doctor Name</label>
            <div>
                <select id="ddlDoctor" name="ddlDoctor">
                </select>
            </div>
        </div>

        <div class="col-lg-3 col-md-5 col-sm-12">
            <label>Template Name</label>
            <div>
                <input type="text" id="Tem_Name" />
            </div>
        </div>
 
          <div class="col-lg-2 col-md-5 col-sm-12">
                <label>IsActive</label>
                <input type="checkbox" id="isActive" />
            </div>
    </div>

    <div class="row" style="overflow-x: auto">
        <div class="col-md-6">
            <div class="row">

                <label style="font-size: 30px!important">Medication Table</label>
            </div>
            <div class="row">
                <div class="col-lg-6 col-md-8 col-sm-12">
                    <select id="ddlMedicine"></select>             
                </div>
                <div class="col-lg-2 col-md-4 col-sm-5">
                       <input type="button" onclick="AppendMed()" class="btn-primry" value="+" id="AddMed"  />
                </div>
            </div>
            <div class="table-container">
                  <table class="table table-bordered" id="Medicine_Table" ">

                <tr id="row_sample">
                    <th style="display: none">Med_Id</th>
                    <th style="width: 90%;">Medicine Name</th>
                    <th style="text-align: center; width: 10%;">ACTIONS</th>
                </tr>
               <tbody id="Medt_body">
                </tbody>
            </table>
            </div>
          
        </div>


        <div class="col-md-6">
            <div class="row">
                <label style="font-size: 30px!important">Lab Test Table</label>
            </div>
            <div class="row">
                 <div class="col-lg-4 col-md-4 col-sm-8">
                     <select id="ddlDepartment" onchange="LoadTestByDepartment()"></select>
                     </div>
                 <div class="col-lg-4 col-md-4 col-sm-8">
                       <select id="ddlTestList" class="form-control" style="width: 150px !important;"></select>
                <select id="ddlRotation" style="display: none;"></select>
                     </div>
                <div class="col-lg-2 col-md-2 col-sm-8">                   
                <input type="button" onclick="AppendTest()" class="btn-primry" value="+" id="Addlabtest" />
                </div>
                
             
            </div>
            <div class="table-container">
                <table class="table table-bordered" id="Test_Table" >

                    <tr id="rows_sample">

                        <th style="width: 30%;">Department</th>
                        <th style="width: 30%;">Test</th>
                        <th style="width: 30%;">Rotation</th>
                        <th style="text-align: center; width: 10%;">ACTIONS</th>
                    </tr>

                    <tbody id="Testt_body">
                    </tbody>

                </table>
            </div>
        </div>
    </div>


    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                 <div  class="col-lg-2 col-md-4 col-sm-6">
        <input type="button" value="Save" class="btn btn-primry" id="btnSave" onclick="SaveRecord()" />
    </div>
            </div>
        </div>
       
        </div>
</asp:Content>
