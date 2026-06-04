 <%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OutPatients.aspx.cs" Inherits="PMS.WebForm11" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/lib/sweetalert/Outpatient.css" rel="stylesheet" />
     <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">
        window.addEventListener('load', function () {
            $(".se-pre-con").fadeOut("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "auto");
        });
        $(window).load(function () {
            $(".se-pre-con").fadeOut("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "auto");

        });
        debugger;
        var Global_Vital = 0;
   
        function loadAllDoctor() {
            debugger;
            PageMethods.loadAllDoc(function (res) {
                var doctor = JSON.parse(res);
                var options = '';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ctl00_MainContent_ddlDoctorName').html(options)
                LoadDesignation()
            });
            
        }
        function loaddoctor(id) {

            PageMethods.LoadDoctor(id, function (res) {
                var doctor = JSON.parse(res);
                var options = '';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ctl00_MainContent_ddlDoctorName').html(options)
            });
        }
        function loaddoctor_byDep() {
            var depart = $('#ctl00_MainContent_ddlPatient_Main_Category').val();
            PageMethods.LoadDoctor_bydep(depart, function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';

                $.each(doctor, function (key, value) {

                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });

                $('#ddldoctors').html(options)
                $('#ddldoctors').attr('disabled', false);
            });
        }

        function LoadTemplateForTest() {

            var options = '<option value="0" >Select Template</option>';

            PageMethods.GetTemplate(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                });
                $('#ddlTemplateTest').html(options);
                $('#ddlTemplateTest').select2();
            });
        }
        function LoadTemplate() {

            var options = '<option value="0" >Select Template</option>';

            PageMethods.GetTemplate(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Template_Id + '" >' + value.Template_Name + '</option>';
                });
                $('#ddlTemplate').html(options);
                $('#ddlTemplate').select2();
            });
        }
        debugger;
        function LoadTemplateMedicine() {
            debugger;
            var Templateid = $('#ddlTemplate').val()
            PageMethods.GetTemplateMedicine(Templateid, function (res) {
                debugger;
                var Medicines = JSON.parse(res);
                var rows = '';
                $.each(Medicines, function (key, value) {
                    debugger;
                    var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    var datearray = date.split("/");
                    var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                    debugger;

                    rows += '<tr> <td><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td><td> <a href="#" onclick="editMedicine(this)">Edit</a> |  <a href="#" onclick="deleteMedicine(this)"> Delete </a></td> <td style="display:none;">' + value.Item_Code + '</td></tr>';
                });
                $('#tblMedicinesList tbody').append(rows);
            })
        }

        function LoadtepmlateTest() {
            debugger;
            var Templateid = $('#ddlTemplateTest').val()
            PageMethods.GetTemplateTest(Templateid, function (res) {
                debugger;
                var test = JSON.parse(res);
                var Dep_id = '';
                var Test = '';
                var Rot_id = '';
                $.each(test, function (key, value) {
                    debugger;
                    Dep_id = value.Department_id,
                        Test = value.Test_Name,
                        Testid = value.Test_Id,
                        Rot_id = value.Rotation_Id
                    AddTemplateTest(Dep_id, Test, Rot_id, Testid)
                });

            })
        }



        function AddTemplateTest(Dep_id, Test, Rot_id, Testid) {
            debugger;
            var maindpt = Dep_id
            var CheckTest = Test

            if (CheckTest != 0 || CheckTest != null) {
                if (maindpt == "001") {
                    AddTemLabTest(maindpt, CheckTest);

                }
                else if (maindpt == "002") {
                    AddTempRadialogyTest(CheckTest, Testid);

                }
                else if (maindpt == "003") {
                    AddTempRadialogyTest(CheckTest, Testid);

                }
                else if (maindpt == "004") {
                    AddTempRadialogyTest(CheckTest, Testid);

                }
                else if (maindpt == "005") {

                    AddTempBloodTest(Testid, CheckTest);

                    $('#divRotation').hide();
                }
                else if (maindpt == "006") {

                    FillTemProcedure(CheckTest, Testid);

                    $('#divRotation').hide();
                }
                else if (maindpt == "007") {

                    FillProcedure("007");
                    $('#ddlXRayLF').hide();
                    $('#divRotation').hide();
                }
            }
            else {

            }

        }
        function AddTemLabTest(maindpt, CheckTest) {
            debugger;
            var test = CheckTest;


            PageMethods.GetLabTestDDLDetails(test, maindpt, function (res) {

                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    if (value.Test_ID != 0) {

                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i style="color: white !important;margin-top: 10px;" class="fa fa-trash"></i></a></td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }

                    $('.tests-table').append(row);

                });
                $("#ctl00_MainContent_txtSpecialTests").val("");
                $("#ctl00_MainContent_txtAreaOfInterest").val("");

            }, function (err) { });

        }
        function AddTempRadialogyTest(CheckTest, Testid) {
            debugger;
            $("#btnXray").removeClass("btn-danger").addClass("btn-info");
            $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
            $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
            var Result = 'Result';
            var test = Testid;
            var testname = CheckTest;
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
            var dateValue = '<%= DateTime.Now%>';
            var IsRotationShow = $('#divRotation').is(":visible");

            var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
            var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
            if (Rotation_Name == "Select" || Rotation_ID == 0) {
                Rotation_ID = "";
                Rotation_Name = "";
            }
            var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
            var ddl_XRayLF_Name = IsRotationShow ? $('#ddlXRayLF option:selected').text() : " ";
            var ddlXRayLF_Name = ',' + ddl_XRayLF_Name;

            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetTestMainDepartmentDetails",
                data: JSON.stringify({ TestID: test }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    var MainDeptName = JSON.parse(data.d);
                    TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                    MainDepartmentName = MainDeptName[0].estMainDepartmen;
                    if (MainDepartmentName == "003") {

                        var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + testname + ', ' + Rotation_Name + ddlXRayLF_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    else {
                        var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + testname + ', ' + Rotation_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                    }
                    debugger;
                    var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');
                    $('.tests-table').append(row);
                    $('#ddlXRayLF option:selected').val("0");
                    $("#ctl00_MainContent_txtSpecialTests").val("");
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");

                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: response.d,
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
        function AddTempBloodTest(Testid, CheckTest) {
            var test = CheckTest;

            PageMethods.GetBBDDLDetails(test, function (res) {

                $.each(JSON.parse(res), function (key, value) {

                    var Result = 'Result';
                    var test = Testid
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    if (value.Test_ID != 0) {

                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }

                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtSpecialTests").val("");
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");
                });

            }, function (err) { });

        }
        function FillTemProcedure(CheckTest, Testid) {
            debugger;
            PageMethods.GetTemProcedure(CheckTest, function (item) {
                debugger;
                $.each(JSON.parse(item), function (key, value) {
                    var Result = 'Result';
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var row;
                    var TestMainDepartmentName = value.Main_Department_Name;
                    debugger;
                    row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (TestMainDepartmentName == null ? '' : TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                    test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    $('.tests-table').append(row);
                });



            });
        }



        function LoadDesignation() {
            debugger;
            var DocID = $('#ctl00_MainContent_ddlDoctorName').val();
            PageMethods.LoadDesignation(DocID, function (res) {
                var doctor = JSON.parse(res);
                var rowsText = '';
                debugger;
                $('#ctl00_MainContent_txtDesignation').val(doctor.Emp_designatin);
            });
            ConfigureAvailableDates(DocID);
        }

        function ConfigureAvailableDates(DocID) {
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetAvailableDates",
                data: JSON.stringify({ DocID: DocID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var availableDates = JSON.parse(response.d);

                    $("#ctl00_MainContent_FollowNoDate").datepicker("destroy"); // Remove any previous config

                    $("#ctl00_MainContent_FollowNoDate").datepicker({
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
        function check() {
            debugger;
            if ($("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PSYCHIATRY") {
                $("#ctl00_MainContent_lblNextPlan").show();
                $("#ctl00_MainContent_txtNextPlan").show();
            }
            else {
                $("#ctl00_MainContent_lblNextPlan").hide();
                $("#ctl00_MainContent_txtNextPlan").hide();
            }

            if ($("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "MEDICINE UNIT-II" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "MEDICINE UNIT-I" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS MEDICINE" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS SURGERY" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS CAMP") {
                if ($("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS MEDICINE" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS SURGERY" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "PAEDS CAMP") {
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').hide();
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').hide();
                    $("#ctl00_MainContent_Label34").hide();
                    $("#ctl00_MainContent_txtedd").hide();
                    $("#ctl00_MainContent_txtMUAC").show();
                    $("#ctl00_MainContent_txtOFC").show();
                    $("#ctl00_MainContent_lblMUAC").show();
                    $("#ctl00_MainContent_lblOFC").show();

                }
                else {
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').show();
                    $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').show();
                    $("#ctl00_MainContent_Label34").show();
                    $("#ctl00_MainContent_txtedd").show();
                    $("#ctl00_MainContent_txtMUAC").hide();
                    $("#ctl00_MainContent_txtOFC").hide();
                    $("#ctl00_MainContent_lblMUAC").hide();
                    $("#ctl00_MainContent_lblOFC").hide();
                }

                $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').hide();
                $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').hide();
                $("#ctl00_MainContent_Label34").hide();
                $("#ctl00_MainContent_txtedd").hide();
                $("#tblPsychiatryHistory").hide();
                $("#ctl00_MainContent_txtBirthHistory").hide();
                $("#ctl00_MainContent_Label15").hide();
                $('#ui-id-20').hide();
                $('#ui-id-21').hide();


                $('#ui-id-19').show();
                $("#tabGO").show();


            }
            else {

                $("#vitalparams").find('tr:nth-child(5) td:nth-child(3)').show();
                $("#vitalparams").find('tr:nth-child(5) td:nth-child(4)').show();

                $("#ctl00_MainContent_Label34").show();
                $("#ctl00_MainContent_txtedd").show();
                $("#tblPsychiatryHistory").hide();
                $("#ctl00_MainContent_txtMUAC").hide();
                $("#ctl00_MainContent_txtOFC").hide();

                $("#ctl00_MainContent_lblMUAC").hide();
                $("#ctl00_MainContent_lblOFC").hide();

            }
            if ($("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "SURGERY-I" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "SURGERY-II" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "GYNAE UNIT-I" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "GYNAE UNIT-II") {

                $("#ctl00_MainContent_txtBirthHistory").hide();
                $("#ctl00_MainContent_Label15").show();
                $("#ctl00_MainContent_txtGIT").show();
                $("#ctl00_MainContent_Label50").show();
                $("#ctl00_MainContent_txtAbdomin").show();
                $("#ctl00_MainContent_lblAbdomin").show();
                $("#tblPeExam").find('tr:nth-child(3)').show();
                $("#tblPeExam").find('tr:nth-child(2)').show();
                if ($("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "GYNAE UNIT-I" || $("#ctl00_MainContent_ddlDepartment :selected").text().trim() == "GYNAE UNIT-II") {

                    $("#ctl00_MainContent_txtCVS").show();
                    $("#ctl00_MainContent_Label6").show();
                    $("#ctl00_MainContent_txtRESP").show();
                    $("#ctl00_MainContent_Label2").show();
                    $("#tabGO").show();
                    $('#ui-id-19').show();
                    $('#ui-id-20').show();
                    $('#ui-id-21').show();
                    $("#ctl00_MainContent_txtBirthHistory").hide();
                    $("#ctl00_MainContent_Label15").hide();
                    $("#ctl00_MainContent_txtGYNAE").show();
                    $("#ctl00_MainContent_Label16").show();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').show();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').show();

                }
                else {
                    $("#ctl00_MainContent_txtCVS").show();
                    $("#ctl00_MainContent_Label6").show();
                    $("#ctl00_MainContent_txtRESP").show();
                    $("#ctl00_MainContent_Label2").show();
                    $('#ui-id-20').hide();
                    $('#ui-id-21').hide();
                    $("#tabGO").show();
                    $('#ui-id-19').show();
                    $("#ctl00_MainContent_txtGYNAE").hide();
                    $("#ctl00_MainContent_Label16").hide();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').hide();
                    $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').hide();
                }
            }
            else {
                $("#ctl00_MainContent_txtGIT").show();
                $("#ctl00_MainContent_Label50").show();
                $("#ctl00_MainContent_txtAbdomin").show();
                $("#ctl00_MainContent_lblAbdomin").show();
                $('#ui-id-20').hide();
                $('#ui-id-21').hide();
                $("#tabGO").show();
                $('#ui-id-19').show();
                $("#ctl00_MainContent_txtBirthHistory").show();
                $("#ctl00_MainContent_Label15").show();
                $("#tblPeExam").find('tr:nth-child(3)').hide();
                $("#tblPeExam").find('tr:nth-child(2)').hide();
                $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').hide();
                $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').hide();

            }


        }
        function Abdomin_CheckedChangedFlat() {

            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", false);
        }
        function Abdomin_CheckedChangedDistended() {
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", false);
        }
        function Abdomin_CheckedChangedScaphoid() {
            $("#ctl00_MainContent_rdbPeads_Scaphoid").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Distended").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Flat").prop("checked", false);
        }

        function Anterioropen_CheckedChangedOpen() {

            $("#ctl00_MainContent_rdbPeads_Anterioropen").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_AnteriorClose").prop("checked", false);

        }
        function Anterioropen_CheckedChangedClose() {
            $("#ctl00_MainContent_rdbPeads_Anterioropen").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_AnteriorClose").prop("checked", true);

        }
        function Antenatal_CheckedChangedBooked() {

        }
        function Natal_CheckedChangedSVD() {

            $("#ctl00_MainContent_rdbPeads_SVD").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_LSCS").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", false);
            $('#TDPeadsEmergency').hide();
            $('#TDPeadsElective').hide();
        }
        function Natal_CheckedChangedLSCS() {

            $("#ctl00_MainContent_rdbPeads_SVD").prop("checked", false);
            var check = $("#ctl00_MainContent_rdbPeads_LSCS").prop("checked", true);
            if (check = "True") {
                $('#TDPeadsEmergency').show();
                $('#TDPeadsElective').show();
            }

        }
        function Natal_CheckedChangedEmergency() {
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", true);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", false);

        }
        function Natal_CheckedChangedElective() {
            $("#ctl00_MainContent_rdbPeads_Emergency").prop("checked", false);
            $("#ctl00_MainContent_rdbPeads_Elective").prop("checked", true);


        }
        function ShowDermaModel() {
            $('#myModalDerma').modal({
                backdrop: 'static'
            });
        }
        function ShowOrthoModel() {
            $('#myModalOrtho').modal({
                backdrop: 'static'
            });
        }

        function ShowPeadsModel() {
            $('#ModelPeads').modal({
                backdrop: 'static'
            });

        }
        function LoadDermaHistory(PatientID) {
            PageMethods.LoadDermaHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td> <td>' + value.Status + '</td><td> ' + value.DermaFace + ' </td> <td> ' + value.DermaNeck
                        + ' </td> <td> ' + value.DermaTrunk + ' </td> <td> ' + value.DermaUpperLimb +
                        ' </td><td> ' + value.DermaLowerLimb + ' </td> <td> ' + value.DermaFlexures +
                        ' </td> <td> ' + value.DermaGenitalias + ' </td> <td> ' + value.DermaHair +
                        ' </td> <td> ' + value.DermaNail + ' </td><td> ' + value.DermaMucousMembrane +
                        ' </td><td> ' + value.DermaEyes + ' </td><td> ' + value.DermaEars +
                        ' </td><td> ' + value.DermaNose + ' </td><td> ' + value.DermaLips + ' </td></tr> ';
                });
                $('#tblDermaHistory tbody tr').remove();
                $('#tblDermaHistory tbody').html(rows);
                $('#tblDermaHistoryHeader').html('<h2>Derma History</h2>')
            });
        }

        function insertOrtho() {
            var rows;
            // var Date=<%=DateTime.Now%>
            rows += '<tr><td> <input type="hidden" name="txtddlOrthoType" value="' + $('#ctl00_MainContent_ddlOrthoType').val() + '" />' + $('#ctl00_MainContent_ddlOrthoType option:selected').text() + '</td> <td> ' + $('#ctl00_MainContent_ddlOrthoSide').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtHistory').val()
                + ' </td> <td> ' + $('#ctl00_MainContent_txtDM').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtHTN').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtIHD').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtLook').val() +
                ' </td> <td> ' + $('#ctl00_MainContent_txtFeel').val() + ' </td> <td> ' + $('#ctl00_MainContent_txtMove').val() +
                ' </td> <td> ' + $('#ctl00_MainContent_txtSpecial_Tests').val() + ' </td><td> ' + $('#ctl00_MainContent_txtSensory').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtMotor').val() + ' </td><td> ' + $('#ctl00_MainContent_txtReflexes').val() +
                ' </td><td> ' + $('#ctl00_MainContent_txtVascularStatus').val() + ' </td><td> ' + $('#ctl00_MainContent_txtOthers').val() +
                '</td></tr> ';
            $('#tblOrtho tbody').append(rows);
            $('#ctl00_MainContent_ddlOrthoSide').val('0');
            $('#ctl00_MainContent_ddlOrthoType').val('0');
            $('#ctl00_MainContent_txtVascularStatus').val('');
            $('#ctl00_MainContent_txtHistory').val('');
            $('#ctl00_MainContent_txtDM').val('');
            $('#ctl00_MainContent_txtHTN').val('');
            $('#ctl00_MainContent_txtIHD').val('');
            $('#ctl00_MainContent_txtLook').val('');
            $('#ctl00_MainContent_txtFeel').val('');
            $('#ctl00_MainContent_txtMove').val('');
            $('#ctl00_MainContent_txtSpecial_Tests').val('');
            $('#ctl00_MainContent_txtSensory').val('');
            $('#ctl00_MainContent_txtMotor').val('');
            $('#ctl00_MainContent_txtReflexes').val('');
            $('#ctl00_MainContent_txtVascularStatus').val('');
            $('#ctl00_MainContent_txtOthers').val('');
        }

        function Appendtestintable() {
            var PatientID = ($('#<%= hdfPatient_ID.ClientID%>').val())
            if (PatientID != '(New)') {
                PageMethods.GetTestListForHistory(PatientID, function (res) {
                    debugger;
                    var test = JSON.parse(res);
                    var rows = '';
                    var Result = 'Pending';
                    var Sample = 'No';
                    $.each(test, function (key, value) {
                        debugger;
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var date = moment().format('M/D/YYYY h:mm:ss A');
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Is_Result == true) {
                            Result = 'Result';
                            Sample = "Yes";
                        }
                        if (value.Is_Result == false) {
                            Result = "Waiting";
                            Sample = "No";
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td> </tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="' + value.DataValue_Name + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td> </tr>';
                        }
                        $('#tblLabtest tbody').append(row);
                    });
                });
            }
        }

        function Appendintable() {
            var PatientID = ($('#<%= hdfPatient_ID.ClientID %>').val());
            if (PatientID != '(New)') {
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';

                    var headerCheckbox = $('#select-all-checkbox');
                    if (headerCheckbox.is(':checked')) {
                        $.each(Medicines, function (index, value) {
                            var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                            var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                            var datearray = date.split("/");
                            var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                            rows += '<tr>';
                            rows += '<td><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td>';
                            rows += '<td>' + value.Medicine_Name + '</td>';
                            rows += '<td>' + value.Frequency + '</td>';
                            rows += '<td>' + value.Oral + '</td>';
                            rows += '<td>' + value.Injections + '</td>';
                            rows += '<td>' + value.AttendingParamedical_Staff + '</td>';
                            rows += '<td>' + value.Dosage_From + '</td>';
                            rows += '<td>' + value.Dosage_Qty + '</td>';
                            rows += '<td>' + value.Other_Instruction + '</td>';
                            rows += '<td><a href="#" onclick="deleteMedicine(this)">Delete</a></td>';
                            rows += '</tr>';
                        });
                    } else {
                        $('#tblHistoryMedication tbody tr').each(function (index, tr) {
                            var checkbox = $(tr).find('.history-checkbox');
                            if (checkbox.is(':checked')) {
                                var value = Medicines[index];
                                var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                                var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                                var datearray = date.split("/");
                                var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                                rows += '<tr>';
                                rows += '<td><input type="hidden" name="testDate" value="' + date + '"> ' + newdate + ' </td>';
                                rows += '<td>' + value.Medicine_Name + '</td>';
                                rows += '<td>' + value.Frequency + '</td>';
                                rows += '<td>' + value.Oral + '</td>';
                                rows += '<td>' + value.Injections + '</td>';
                                rows += '<td>' + value.AttendingParamedical_Staff + '</td>';
                                rows += '<td>' + value.Dosage_From + '</td>';
                                rows += '<td>' + value.Dosage_Qty + '</td>';
                                rows += '<td>' + value.Other_Instruction + '</td>';
                                rows += '<td><a href="#" onclick="deleteMedicine(this)">Delete</a></td>';
                                rows += '</tr>';
                            }
                        });
                    }

                    $('#tblMedicinesList tbody').append(rows);
                });
            }
        }

        function AppendSymtompsHistory() {
            var PatID = ($('#<%= hdfPatient_ID.ClientID%>').val())
            if (PatID != '(New)') {
                if (PatID != '') {
                    PageMethods.LoadSymtompsHistory(PatID, function (res) {
                        var Symtomps = JSON.parse(res);
                        var rows = '';
                        $.each(Symtomps, function (key, value) {
                            var rowID = uuid();
                            rows += '<tr> <td style="display:none;"> ' + value.Symtom_ID + ' </td> <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + ' </td> <td> ' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td> <td><a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';
                            if (value.Symtom_ID.length > 0)
                                $('#dvSyptomHistory').show();
                            else
                                $('#dvSyptomHistory').hide();
                        });
                        $('#tblSymtoms tbody').html(rows);
                    });
                }
            }
        }
        function AppendServices_Procedures() {
            debugger;
            var PatientId = ($('#<%= hdfPatient_ID.ClientID%>').val())
            if ($("#<%= hdfPatient_ID.ClientID%>").val() !== "(New)") {
                $('#ServicesHistoryHeader').html('<h2 class="headingcolr">Loading Previous History Please Wait...</h2>');
                PageMethods.LoadServicesDetailforHistory(PatientId, $('#<%= hdfPatient_ID.ClientID%>').val(), function (response) {
                    var Services = JSON.parse(response);
                    var rows = "";
                    var rowsHistory = "";
                    $.each(Services, function (key, value) {
                        var timeStamp = parseInt(value.ServiceDate.substr(6, 10));
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        var entryDate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        rows += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td><td style="text-align: left;"> <a  href="#" onclick="DeleteRow(this)">Delete</a> </td> </tr>';
                    });
                    $('#tblServices tbody').append(rows);
                });
            }
        }





        function LoadVitalParametersHistory(PatientID) {
            if (PatientID != "(New)") {
                $('#tblHistoryHeader').html('<h2 class="headingcolr">Loading Previous History Please Wait....</h2>')
                PageMethods.LoadVitalParametersHistory(PatientID, function (res) {
                    debugger;
                    var Data = JSON.parse(res);
                    var rows = '';
                    $.each(Data, function (key, value) {
                        var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                        var retdate = moment(TrnsDate).format('LLLL');
                        rows += '<tr> <td value="' + value.Out_Patient_ID + '"> ' + retdate + ' </td><td>' + value.Status + '</td> <td> ' + value.Pulse_Min
                            + ' </td> <td> ' + value.Temp_C + ' </td> <td> ' + value.Height_Cm + ' </td><td> ' + value.L_M_P + ' </td><td> ' + value.SPO2 + ' </td><td> ' + value.BSR + ' </td><td> ' + value.BMI + ' </td><td> ' + value.BP_mm_Hg + ' </td> <td> ' + value.Respiration_Min + ' </td> <td> ' + value.Weight_Kg + ' </td><td><a href="#" onclick="LoadVitalFromhistory(' + value.Out_Patient_ID + ')"><i class="fa fa-upload"></i></a> </td> </tr>';
                    });
                    $('#tblVitalParametersHistory tbody tr').remove();
                    $('#tblVitalParametersHistory tbody').html(rows);
                    $('#tblHistoryHeader').html('<h2 class="headingcolr">Previous History</h2>')
                });
            }
        }
        function LoadVitalFromhistory(Out_Patient_ID) {
            var opdid = Out_Patient_ID
            PageMethods.LoadVitalFromhistory(opdid, function (res) {
                var Data = JSON.parse(res);
                $.each(Data, function (key, value) {
                    $('#ctl00_MainContent_txtBP').val(value.BP_mm_Hg)
                    $('#ctl00_MainContent_txtWeight').val(value.Weight_Kg)
                    $('#ctl00_MainContent_txtHeight').val(value.Height_Cm)
                    $('#ctl00_MainContent_txtRespiration').val(value.Respiration_Min)
                    $('#ctl00_MainContent_txtTemp').val(value.Temp_C)
                    $('#ctl00_MainContent_txtLMP').val(value.L_M_P)
                    $('#ctl00_MainContent_txtspo2').val(value.SPO2)
                    $('#ctl00_MainContent_TxtBSR').val(value.BSR)
                    $('#ctl00_MainContent_txtPuls').val(value.pulse_Min)
                    $('#ctl00_MainContent_txtBMI').val(value.BMI)
                })

            });
        }
        function LoadHistoryFromhistory(Out_Patient_ID) {
            debugger;
            var opdid = Out_Patient_ID
            PageMethods.LoadVitalFromhistory(opdid, function (res) {
                var Data = JSON.parse(res);
                $.each(Data, function (key, value) {
                    $('#ctl00_MainContent_txtHistoryOfPeresentIllness').val(value.HistoryOfPeresentIllness)
                    $('#ctl00_MainContent_txtHistoryOfPastIllness').val(value.HistoryOfPastIllness)
                    $('#ctl00_MainContent_txtHistoryOfFamily').val(value.HistoryOfFamily)
                    $('#ctl00_MainContent_txtSocioEconomicHistory').val(value.SocioEconomicHistory)
                    $('#ctl00_MainContent_txtBirthHistory').val(value.Birth_History)
                    $('#ctl00_MainContent_txtDrugHistory').val(value.Drug_History)
                    $('#ctl00_MainContent_txtDevelopmentHistory').val(value.DevelopmentHistory)
                    $('#ctl00_MainContent_txtVaccinationHistory').val(value.VaccinationHistory)
                    $('#ctl00_MainContent_txtNutritionHistory').val(value.NutritionHistory)
                    $('#ctl00_MainContent_txtPersonalHistory').val(value.Personal_History)
                    $('#ctl00_MainContent_txtObstetricHistory').val(value.ObstetricHistory)
                    $('#ctl00_MainContent_txtAllergiesHistory').val(value.AllergiesHistory)
                    $('#ctl00_MainContent_txtTreatmentHistory').val(value.TreatmentHistory)
                    $('#ctl00_MainContent_txtGIT').val(value.GIT)
                    $('#ctl00_MainContent_txtGYNAE').val(value.GYNAE)
                    $('#ctl00_MainContent_txtUGS').val(value.URG)
                    $('#ctl00_MainContent_txtRESP').val(value.RESP)
                    $('#ctl00_MainContent_txtCNS').val(value.CNS)
                    $('#ctl00_MainContent_txtCVS').val(value.CVS)
                    $('#ctl00_MainContent_txtProvisionalDiagnosis').val(value.ProvisionalDiagnosis)
                    $('#ctl00_MainContent_txtRemarksHistory').val(value.txtRemarksHistory)
                    $('#ctl00_MainContent_txtBP').val(value.txtInputBox1)
                    $('#ctl00_MainContent_txtLocal').val(value.Local)
                    $('#ctl00_MainContent_txtMucculor').val(value.Mucculor)
                    $('#ctl00_MainContent_txtAbdomin').val(value.Abdominal)
                    $('#ctl00_MainContent_txtPA_Gynae').val(value.PA_Gynae)
                    $('#ctl00_MainContent_txtPS_Gynae').val(value.PS_Gynae)
                    $('#ctl00_MainContent_txtUterus').val(value.Uterus)
                    $('#ctl00_MainContent_txtFX').val(value.FX)
                    $('#ctl00_MainContent_txtPS_OBS').val(value.PS_Obs)
                    $('#ctl00_MainContent_txtPS_OBS').val(value.PV_Obs)
                    $('#ctl00_MainContent_txtSFH').val(value.SFH)
                    $('#ctl00_MainContent_txtLIE').val(value.LIE)
                    $('#ctl00_MainContent_txtPresentation').val(value.Presentation)
                    $('#ctl00_MainContent_txtFHR').val(value.FHR)
                    $('#ctl00_MainContent_txtEngagement').val(value.Engagement)

                })

            });
        }
        function LoadPsychiatryHistoryInpat(PatientID) {

            PageMethods.LoadPsychiatryHistoryInpat(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>InPatient</td> <td> ' + value.Psychiatry_Informant + ' </td> <td> ' + value.Psychiatry_Source_Referral
                        + ' </td> <td> ' + value.Psychiatry_Neck_Holding + ' </td> <td> ' + value.Psychiatry_Walking +
                        ' </td><td> ' + value.Psychiatry_Talking + ' </td> <td> ' + value.Psychiatry_Others +
                        ' </td> <td> ' + value.Psychiatry_Menarche + ' </td> <td> ' + value.Psychiatry_Menstrual +
                        ' </td> <td> ' + value.Psychiatry_Attachment_Separation + ' </td><td> ' + value.Psychiatry_Health +
                        ' </td><td> ' + value.Psychiatry_Nail_Biting + ' </td><td> ' + value.Psychiatry_Temper_Tantrums +
                        ' </td><td> ' + value.Psychiatry_Bed_Wetting + ' </td><td> ' + value.Psychiatry_Academics + ' </td>'

                        + ' </td> <td> ' + value.Psychiatry_Peer_Relationship + ' </td> <td> ' + value.Psychiatry_Behaviour +
                        ' </td><td> ' + value.Psychiatry_Occupational_History + ' </td> <td> ' + value.Psychiatry_Sexual_History +
                        ' </td> <td> ' + value.Psychiatry_Substance_Use + ' </td> <td> ' + value.Psychiatry_Forensic_Use +
                        ' </td> <td> ' + value.Psychiatry_Relationship + ' </td><td> ' + value.Psychiatry_Leisure_Activities +
                        ' </td><td> ' + value.Psychiatry_Attitude_Standards + ' </td><td> ' + value.Psychiatry_Prevalling_Mood +
                        ' </td><td> ' + value.Psychiatry_Reaction_Stress + ' </td><td> ' + value.Psychiatry_Religious_Practices +

                        ' </td><td> ' + value.Psychiatry_Father + ' </td> <td> ' + value.Psychiatry_Mother +
                        ' </td><td> ' + value.Psychiatry_Siblings + ' </td> <td> ' + value.Psychiatry_Familial_Illness +
                        ' </td> <td> ' + value.Psychiatry_Home_Atmosphere + ' </td> <td> ' + value.Psychiatry_Actual_age +
                        ' </td> <td> ' + value.Psychiatry_Race + ' </td><td> ' + value.Psychiatry_Tattoos_body_scars +
                        ' </td><td> ' + value.Psychiatry_Body_Habitus + ' </td><td> ' + value.Psychiatry_Dress +
                        ' </td><td> ' + value.Psychiatry_Hygiene + ' </td><td> ' + value.Psychiatry_Psychomotor_Activity +

                        ' </td><<td> ' + value.Psychiatry_Involuntary_movements + ' </td><td> ' + value.Psychiatry_Dystonia_EPS + ' </td><td> ' + value.Psychiatry_Tardive_dyskinesia + ' </td><td> ' + value.Psychiatry_Tics + ' </td><td> ' + value.Psychiatry_Tremors + ' </td><td> ' + value.Psychiatry_Attentiveness_interview + ' </td><td> ' + value.Psychiatry_Eye_Contact + ' </td><td> ' + value.Psychiatry_Level_Consciousness + ' </td><td> ' + value.Psychiatry_Rate + ' </td><td> ' + value.Psychiatry_Rhythm + ' </td><td> ' + value.Psychiatry_Volume + ' </td><td> ' + value.Psychiatry_Tone + ' </td><td> ' + value.Psychiatry_Modulation + ' </td><td> ' + value.Psychiatry_Depressed + ' </td><td> ' + value.Psychiatry_Elated + ' </td><td> ' + value.Psychiatry_Irritable + ' </td><td> ' + value.Psychiatry_Labile + ' </td><td> ' + value.Psychiatry_Incongruent + ' </td><td> ' + value.Psychiatry_Blunting_Flattening_Apathy + ' </td><td> ' + value.Psychiatry_Thinking + ' </td><td> ' + value.Psychiatry_Plans + ' </td><td> ' + value.Psychiatry_Actions + ' </td><td> ' + value.Psychiatry_Preservative + ' </td><td> ' + value.Psychiatry_LoosAssociation + ' </td><td> ' + value.Psychiatry_Tangentiaility + ' </td><td> ' + value.Psychiatry_Circumstantiality + ' </td><td> ' + value.Psychiatry_Flight_Ideas + ' </td><td> ' + value.Psychiatry_Thought_Insertion + ' </td><td> ' + value.Psychiatry_Thought_Withdrawal + ' </td><td> ' + value.Psychiatry_Thought_Broadcasting + ' </td><td> ' + value.Psychiatry_Thought_Control + ' </td><td> ' + value.Psychiatry_Dellusion + ' </td><td> ' + value.Psychiatry_Overvalued_Ideas + ' </td><td> ' + value.Psychiatry_Depresonalization + ' </td><td> ' + value.Psychiatry_Derealization + ' </td><td> ' + value.Psychiatry_Obsession + ' </td><td> ' + value.Psychiatry_Phobies + ' </td><td> ' + value.Psychiatry_Homocidial_Ideas + ' </td><td> ' + value.Psychiatry_Illusion + ' </td><td> ' + value.Psychiatry_Hallucination + ' </td><td> ' + value.Psychiatry_Orientation_Time + ' </td><td> ' + value.Psychiatry_Place + ' </td><td> ' + value.Psychiatry_Person + ' </td><td> ' + value.Psychiatry_Attention_Concentration + ' </td><td> ' + value.Psychiatry_Days_Week + ' </td><td> ' + value.Psychiatry_Immediate_Memory + ' </td><td> ' + value.Psychiatry_Recent_Events + ' </td><td> ' + value.Psychiatry_Remote_Events + ' </td><td> ' + value.Psychiatry_Adress_Recall_Two + ' </td><td> ' + value.Psychiatry_Adress_Recall_Five + ' </td><td> ' + value.Psychiatry_General_knowledge + ' </td><td> ' + value.Psychiatry_Arthemetic_Calculation + ' </td> <td> ' + value.Psychiatry_Abstraction + ' </td><td>' + value.Psychiatry_Insight + ' </td> <td>' + value.Psychiatry_HBM_Problem + ' </td> <td>' + value.Psychiatry_HBM_Caused + ' </td> <td>' + value.Psychiatry_HBM_Started + ' </td> <td>' + value.Psychiatry_HBM_Course + ' </td> <td>' + value.Psychiatry_HBM_Treatment + ' </td><td>' + value.Psychiatry_HBM_Effects + ' </td><td>' + value.Psychiatry_PE_Pluse + ' </td><td>' + value.Psychiatry_PE_BP + ' </td> <td>' + value.Psychiatry_PE_Temperature + ' </td><td>' + value.Psychiatry_PE_Weight + ' </td><td>' + value.Psychiatry_PE_RespiratoryRate + ' </td><td>' + value.Psychiatry_PE_Jaundice + ' </td> <td>' + value.Psychiatry_PE_Anemia + ' </td> <td>' + value.Psychiatry_PE_Cyanosis + ' </td><td>' + value.Psychiatry_PE_Clubbing + ' </td><td>' + value.Psychiatry_PE_JVP + ' </td><td>' + value.Psychiatry_PE_LymphNodes + ' </td><td>' + value.Psychiatry_PE_Edema + ' </td><td>' + value.Psychiatry_PE_Respiratory + ' </td><td>' + value.Psychiatry_PE_Cardiovascular + ' </td> <td>' + value.Psychiatry_PE_Gastro_Intestinal + ' </td><td>' + value.Psychiatry_PE_Observation + ' </td> <td>' + value.Psychiatry_PE_Cranial_Nerves + ' </td> <td>' + value.Psychiatry_PE_Limb_Strength + ' </td> <td>' + value.Psychiatry_PE_Spasticity + ' </td> <td>' + value.Psychiatry_PE_Position + ' </td>  <td>' + value.Psychiatry_PE_Vibration + ' </td> <td>' + value.Psychiatry_PE_Stereognosis + ' </td> <td>' + value.Psychiatry_PE_Pain + ' </td> <td>' + value.Psychiatry_PE_Biceps + ' </td> <td>' + value.Psychiatry_PE_Triceps + ' </td> <td>' + value.Psychiatry_PE_Brachioradialis + ' </td> <td>' + value.Psychiatry_PE_Quadriceps + ' </td> <td>' + value.Psychiatry_PE_Patellar + ' </td> <td>' + value.Psychiatry_PE_Achilles + ' </td><td>' + value.Psychiatry_PE_Extensor + ' </td> <td>' + value.Psychiatry_PE_Frontal + ' </td><td>' + value.Psychiatry_PE_Finger + ' </td> <td>' + value.Psychiatry_PE_Heel + ' </td> <td>' + value.Psychiatry_PE_Movements + ' </td> <td>' + value.Psychiatry_PE_Gait + ' </td> <td>' + value.Psychiatry_PE_Neck_Rigidity + ' </td>  <td>' + value.Psychiatry_PE_Kerning_Sign + ' </td> <td>' + value.Psychiatry_PE_Brudzinki_Sign + ' </td> <td>' + value.Psychiatry_For_Summary + ' </td> <td>' + value.Psychiatry_For_Diagnosis + ' </td> <td>' + value.Psychiatry_For_AxisI + ' </td> <td>' + value.Psychiatry_For_AxisII + ' </td> <td>' + value.Psychiatry_For_AxisIII + ' </td> <td>' + value.Psychiatry_For_AxisIV + ' </td> <td>' + value.Psychiatry_For_AxisV + ' </td> <td>' + value.Psychiatry_For_PredisposingFactors + ' </td> <td>' + value.Psychiatry_For_PrecipitatingFactors + ' </td> <td>' + value.Psychiatry_For_PrepetuatingFactors + ' </td>  <td>' + value.Psychiatry_For_Investigation + ' </td> <td>' + value.Psychiatry_For_Medical + ' </td> <td>' + value.Psychiatry_For_Psychological + ' </td> <td>' + value.Psychiatry_Major_Issues + ' </td> <td>' + value.Psychiatry_For_Strengths + ' </td><td>' + value.Psychiatry_For_Goals + ' </td> <td>' + value.Psychiatry_For_Strategies + ' </td> </tr> ';
                    $('#tblPsychiatryHistory tbody').append(rows);

                });

            });
        }
        function LoadPsychiatryHistory(PatientID) {

            PageMethods.LoadPsychiatryHistory(PatientID, function (res) {

                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>OutPatient</td> <td> ' + value.Psychiatry_Informant + ' </td> <td> ' + value.Psychiatry_Source_Referral
                        + ' </td> <td> ' + value.Psychiatry_Neck_Holding + ' </td> <td> ' + value.Psychiatry_Walking +
                        ' </td><td> ' + value.Psychiatry_Talking + ' </td> <td> ' + value.Psychiatry_Others +
                        ' </td> <td> ' + value.Psychiatry_Menarche + ' </td> <td> ' + value.Psychiatry_Menstrual +
                        ' </td> <td> ' + value.Psychiatry_Attachment_Separation + ' </td><td> ' + value.Psychiatry_Health +
                        ' </td><td> ' + value.Psychiatry_Nail_Biting + ' </td><td> ' + value.Psychiatry_Temper_Tantrums +
                        ' </td><td> ' + value.Psychiatry_Bed_Wetting + ' </td><td> ' + value.Psychiatry_Academics + ' </td>'

                        + ' </td> <td> ' + value.Psychiatry_Peer_Relationship + ' </td> <td> ' + value.Psychiatry_Behaviour +
                        ' </td><td> ' + value.Psychiatry_Occupational_History + ' </td> <td> ' + value.Psychiatry_Sexual_History +
                        ' </td> <td> ' + value.Psychiatry_Substance_Use + ' </td> <td> ' + value.Psychiatry_Forensic_Use +
                        ' </td> <td> ' + value.Psychiatry_Relationship + ' </td><td> ' + value.Psychiatry_Leisure_Activities +
                        ' </td><td> ' + value.Psychiatry_Attitude_Standards + ' </td><td> ' + value.Psychiatry_Prevalling_Mood +
                        ' </td><td> ' + value.Psychiatry_Reaction_Stress + ' </td><td> ' + value.Psychiatry_Religious_Practices +

                        ' </td><td> ' + value.Psychiatry_Father + ' </td> <td> ' + value.Psychiatry_Mother +
                        ' </td><td> ' + value.Psychiatry_Siblings + ' </td> <td> ' + value.Psychiatry_Familial_Illness +
                        ' </td> <td> ' + value.Psychiatry_Home_Atmosphere + ' </td> <td> ' + value.Psychiatry_Actual_age +
                        ' </td> <td> ' + value.Psychiatry_Race + ' </td><td> ' + value.Psychiatry_Tattoos_body_scars +
                        ' </td><td> ' + value.Psychiatry_Body_Habitus + ' </td><td> ' + value.Psychiatry_Dress +
                        ' </td><td> ' + value.Psychiatry_Hygiene + ' </td><td> ' + value.Psychiatry_Psychomotor_Activity +

                        ' </td><<td> ' + value.Psychiatry_Involuntary_movements + ' </td><td> ' + value.Psychiatry_Dystonia_EPS + ' </td><td> ' + value.Psychiatry_Tardive_dyskinesia + ' </td><td> ' + value.Psychiatry_Tics + ' </td><td> ' + value.Psychiatry_Tremors + ' </td><td> ' + value.Psychiatry_Attentiveness_interview + ' </td><td> ' + value.Psychiatry_Eye_Contact + ' </td><td> ' + value.Psychiatry_Level_Consciousness + ' </td><td> ' + value.Psychiatry_Rate + ' </td><td> ' + value.Psychiatry_Rhythm + ' </td><td> ' + value.Psychiatry_Volume + ' </td><td> ' + value.Psychiatry_Tone + ' </td><td> ' + value.Psychiatry_Modulation + ' </td><td> ' + value.Psychiatry_Depressed + ' </td><td> ' + value.Psychiatry_Elated + ' </td><td> ' + value.Psychiatry_Irritable + ' </td><td> ' + value.Psychiatry_Labile + ' </td><td> ' + value.Psychiatry_Incongruent + ' </td><td> ' + value.Psychiatry_Blunting_Flattening_Apathy + ' </td><td> ' + value.Psychiatry_Thinking + ' </td><td> ' + value.Psychiatry_Plans + ' </td><td> ' + value.Psychiatry_Actions + ' </td><td> ' + value.Psychiatry_Preservative + ' </td><td> ' + value.Psychiatry_LoosAssociation + ' </td><td> ' + value.Psychiatry_Tangentiaility + ' </td><td> ' + value.Psychiatry_Circumstantiality + ' </td><td> ' + value.Psychiatry_Flight_Ideas + ' </td><td> ' + value.Psychiatry_Thought_Insertion + ' </td><td> ' + value.Psychiatry_Thought_Withdrawal + ' </td><td> ' + value.Psychiatry_Thought_Broadcasting + ' </td><td> ' + value.Psychiatry_Thought_Control + ' </td><td> ' + value.Psychiatry_Dellusion + ' </td><td> ' + value.Psychiatry_Overvalued_Ideas + ' </td><td> ' + value.Psychiatry_Depresonalization + ' </td><td> ' + value.Psychiatry_Derealization + ' </td><td> ' + value.Psychiatry_Obsession + ' </td><td> ' + value.Psychiatry_Phobies + ' </td><td> ' + value.Psychiatry_Homocidial_Ideas + ' </td><td> ' + value.Psychiatry_Illusion + ' </td><td> ' + value.Psychiatry_Hallucination + ' </td><td> ' + value.Psychiatry_Orientation_Time + ' </td><td> ' + value.Psychiatry_Place + ' </td><td> ' + value.Psychiatry_Person + ' </td><td> ' + value.Psychiatry_Attention_Concentration + ' </td><td> ' + value.Psychiatry_Days_Week + ' </td><td> ' + value.Psychiatry_Immediate_Memory + ' </td><td> ' + value.Psychiatry_Recent_Events + ' </td><td> ' + value.Psychiatry_Remote_Events + ' </td><td> ' + value.Psychiatry_Adress_Recall_Two + ' </td><td> ' + value.Psychiatry_Adress_Recall_Five + ' </td><td> ' + value.Psychiatry_General_knowledge + ' </td><td> ' + value.Psychiatry_Arthemetic_Calculation + ' </td> <td> ' + value.Psychiatry_Abstraction + ' </td><td>' + value.Psychiatry_Insight + ' </td>  <td>' + value.Psychiatry_HBM_Problem + ' </td> <td>' + value.Psychiatry_HBM_Caused + ' </td> <td>' + value.Psychiatry_HBM_Started + ' </td> <td>' + value.Psychiatry_HBM_Course + ' </td> <td>' + value.Psychiatry_HBM_Treatment + ' </td><td>' + value.Psychiatry_HBM_Effects + ' </td><td>' + value.Psychiatry_PE_Pluse + ' </td><td>' + value.Psychiatry_PE_BP + ' </td> <td>' + value.Psychiatry_PE_Temperature + ' </td><td>' + value.Psychiatry_PE_Weight + ' </td><td>' + value.Psychiatry_PE_RespiratoryRate + ' </td><td>' + value.Psychiatry_PE_Jaundice + ' </td> <td>' + value.Psychiatry_PE_Anemia + ' </td> <td>' + value.Psychiatry_PE_Cyanosis + ' </td><td>' + value.Psychiatry_PE_Clubbing + ' </td><td>' + value.Psychiatry_PE_JVP + ' </td><td>' + value.Psychiatry_PE_LymphNodes + ' </td><td>' + value.Psychiatry_PE_Edema + ' </td><td>' + value.Psychiatry_PE_Respiratory + ' </td><td>' + value.Psychiatry_PE_Cardiovascular + ' </td> <td>' + value.Psychiatry_PE_Gastro_Intestinal + ' </td><td>' + value.Psychiatry_PE_Observation + ' </td> <td>' + value.Psychiatry_PE_Cranial_Nerves + ' </td> <td>' + value.Psychiatry_PE_Limb_Strength + ' </td> <td>' + value.Psychiatry_PE_Spasticity + ' </td> <td>' + value.Psychiatry_PE_Position + ' </td>  <td>' + value.Psychiatry_PE_Vibration + ' </td> <td>' + value.Psychiatry_PE_Stereognosis + ' </td> <td>' + value.Psychiatry_PE_Pain + ' </td> <td>' + value.Psychiatry_PE_Biceps + ' </td> <td>' + value.Psychiatry_PE_Triceps + ' </td> <td>' + value.Psychiatry_PE_Brachioradialis + ' </td> <td>' + value.Psychiatry_PE_Quadriceps + ' </td> <td>' + value.Psychiatry_PE_Patellar + ' </td> <td>' + value.Psychiatry_PE_Achilles + ' </td><td>' + value.Psychiatry_PE_Extensor + ' </td> <td>' + value.Psychiatry_PE_Frontal + ' </td><td>' + value.Psychiatry_PE_Finger + ' </td> <td>' + value.Psychiatry_PE_Heel + ' </td> <td>' + value.Psychiatry_PE_Movements + ' </td> <td>' + value.Psychiatry_PE_Gait + ' </td> <td>' + value.Psychiatry_PE_Neck_Rigidity + ' </td>  <td>' + value.Psychiatry_PE_Kerning_Sign + ' </td> <td>' + value.Psychiatry_PE_Brudzinki_Sign + ' </td> <td>' + value.Psychiatry_For_Summary + ' </td> <td>' + value.Psychiatry_For_Diagnosis + ' </td> <td>' + value.Psychiatry_For_AxisI + ' </td> <td>' + value.Psychiatry_For_AxisII + ' </td> <td>' + value.Psychiatry_For_AxisIII + ' </td> <td>' + value.Psychiatry_For_AxisIV + ' </td> <td>' + value.Psychiatry_For_AxisV + ' </td> <td>' + value.Psychiatry_For_PredisposingFactors + ' </td> <td>' + value.Psychiatry_For_PrecipitatingFactors + ' </td> <td>' + value.Psychiatry_For_PrepetuatingFactors + ' </td>  <td>' + value.Psychiatry_For_Investigation + ' </td> <td>' + value.Psychiatry_For_Medical + ' </td> <td>' + value.Psychiatry_For_Psychological + ' </td> <td>' + value.Psychiatry_Major_Issues + ' </td> <td>' + value.Psychiatry_For_Strengths + ' </td><td>' + value.Psychiatry_For_Goals + ' </td> <td>' + value.Psychiatry_For_Strategies + ' </td> </tr> ';
                    $('#tblPsychiatryHistory tbody').append(rows);

                });

            });
        }

        function LoadPeadsHistory(PatientID) {


            PageMethods.LoadPeadsHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var DelivryDate = new Date(parseInt(value.Peads_DateOfDelivery.substr(6)));
                    var DeliveryDate = moment(DelivryDate).format('DD/MM/YYYY');
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>OutPatient</td><td> ' + value.Peads_FullTerm + ' </td><td> ' + value.Peads_PreTerm + ' </td><td> ' + DeliveryDate + ' </td><td> ' + value.Peads_TimeOfDelivery + ' </td><td> ' + value.Peads_Booked + ' </td><td> ' + value.Peads_UnBooked + ' </td><td> ' + value.Peads_DAIHandling + ' </td><td> ' + value.Peads_ANTURash + ' </td><td> ' + value.Peads_PIH + ' </td><td> ' + value.Peads_GDM + ' </td><td> ' + value.Peads_Vacinated + ' </td><td> ' + value.Peads_ANTOthers + ' </td><td> ' + value.Peads_SVD + ' </td><td> ' + value.Peads_LSCS + ' </td><td> ' + value.Peads_Emergency + ' </td><td> ' + value.Peads_Elective + ' </td><td> ' + value.Peads_PlaceOfDelivery + ' </td><td> ' + value.Peads_IndicationForLSCS + ' </td><td> ' + value.Peads_apgerScore1min + ' </td><td> ' + value.Peads_apgerScore5min + ' </td><td> ' + value.Peads_Resuscitation + ' </td><td> ' + value.Peads_NatalOthers + ' </td><td> ' + value.Peads_Moaning + ' </td><td> ' + value.Peads_RespDistress + ' </td><td> ' + value.Peads_PostNATALCyanosis + ' </td><td> ' + value.Peads_Fits + ' </td><td> ' + value.Peads_ReluctanceToFeed + ' </td><td> ' + value.Peads_PostNatalOthers + ' </td> <td> ' + value.Peads_weight + ' </td><td> ' + value.Peads_Length + ' </td><td> ' + value.Peads_HC + ' </td><td> ' + value.Peads_General_Appearance + '</td><td> ' + value.Peads_Cyanosis + ' </td><td> ' + value.Peads_Jaundice + ' </td><td> ' + value.Peads_Lethargy + ' </td><td> ' + value.Peads_Rash + ' </td><td> ' + value.Peads_Others + ' </td><td> ' + value.Peads_Caput + ' </td><td> ' + value.Peads_Cephalhematoma + ' </td><td> ' + value.Peads_Anterioropen + ' </td><td> ' + value.Peads_AnteriorClose + ' </td><td> ' + value.Peads_Dextrocardia + ' </td><td> ' + value.Peads_Bulging + ' </td><td> ' + value.Peads_Murmur + ' </td><td> ' + value.Peads_HeartSound + ' </td><td> ' + value.Peads_Nasal + ' </td><td> ' + value.Peads_Recessions + ' </td><td> ' + value.Peads_AddedSounds + ' </td><td> ' + value.Peads_Flat + ' </td><td> ' + value.Peads_Distended + ' </td><td> ' + value.Peads_Scaphoid + ' </td><td> ' + value.Peads_Liver + ' </td><td> ' + value.Peads_Spleen + ' </td><td> ' + value.Peads_GITOthers + ' </td><td> ' + value.Peads_Sucking + ' </td><td> ' + value.Peads_Rooting + ' </td><td> ' + value.Peads_Moro + ' </td><td> ' + value.Peads_CNSOthers + ' </td> </tr> ';

                    $('#tblPeadsHistory tbody').append(rows);
                });
                $('#tblPeadsHeader').html('<h2>Peads History</h2>')
            });
        }
        function LoadPeadsHistoryInpat(PatientID) {


            PageMethods.LoadPeadsHistoryInpat(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var DelivryDate = new Date(parseInt(value.Peads_DateOfDelivery.substr(6)));
                    var DeliveryDate = moment(DelivryDate).format('DD/MM/YYYY');
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr> <td> ' + retdate + '</td><td>InPatient</td><td> ' + value.Peads_FullTerm + ' </td><td> ' + value.Peads_PreTerm + ' </td><td> ' + DeliveryDate + ' </td><td> ' + value.Peads_TimeOfDelivery + ' </td><td> ' + value.Peads_Booked + ' </td><td> ' + value.Peads_UnBooked + ' </td><td> ' + value.Peads_DAIHandling + ' </td><td> ' + value.Peads_ANTURash + ' </td><td> ' + value.Peads_PIH + ' </td><td> ' + value.Peads_GDM + ' </td><td> ' + value.Peads_Vacinated + ' </td><td> ' + value.Peads_ANTOthers + ' </td><td> ' + value.Peads_SVD + ' </td><td> ' + value.Peads_LSCS + ' </td><td> ' + value.Peads_Emergency + ' </td><td> ' + value.Peads_Elective + ' </td><td> ' + value.Peads_PlaceOfDelivery + ' </td><td> ' + value.Peads_IndicationForLSCS + ' </td><td> ' + value.Peads_apgerScore1min + ' </td><td> ' + value.Peads_apgerScore5min + ' </td><td> ' + value.Peads_Resuscitation + ' </td><td> ' + value.Peads_NatalOthers + ' </td><td> ' + value.Peads_Moaning + ' </td><td> ' + value.Peads_RespDistress + ' </td><td> ' + value.Peads_PostNATALCyanosis + ' </td><td> ' + value.Peads_Fits + ' </td><td> ' + value.Peads_ReluctanceToFeed + ' </td><td> ' + value.Peads_PostNatalOthers + ' </td> <td> ' + value.Peads_weight + ' </td><td> ' + value.Peads_Length + ' </td><td> ' + value.Peads_HC + ' </td><td> ' + value.Peads_General_Appearance + '</td><td> ' + value.Peads_Cyanosis + ' </td><td> ' + value.Peads_Jaundice + ' </td><td> ' + value.Peads_Lethargy + ' </td><td> ' + value.Peads_Rash + ' </td><td> ' + value.Peads_Others + ' </td><td> ' + value.Peads_Caput + ' </td><td> ' + value.Peads_Cephalhematoma + ' </td><td> ' + value.Peads_Anterioropen + ' </td><td> ' + value.Peads_AnteriorClose + ' </td><td> ' + value.Peads_Dextrocardia + ' </td><td> ' + value.Peads_Bulging + ' </td><td> ' + value.Peads_Murmur + ' </td><td> ' + value.Peads_HeartSound + ' </td><td> ' + value.Peads_Nasal + ' </td><td> ' + value.Peads_Recessions + ' </td><td> ' + value.Peads_AddedSounds + ' </td><td> ' + value.Peads_Flat + ' </td><td> ' + value.Peads_Distended + ' </td><td> ' + value.Peads_Scaphoid + ' </td><td> ' + value.Peads_Liver + ' </td><td> ' + value.Peads_Spleen + ' </td><td> ' + value.Peads_GITOthers + ' </td><td> ' + value.Peads_Sucking + ' </td><td> ' + value.Peads_Rooting + ' </td><td> ' + value.Peads_Moro + ' </td><td> ' + value.Peads_CNSOthers + ' </td> </tr> ';

                    $('#tblPeadsHistory tbody').append(rows);
                });

                $('#tblPeadsHeader').html('<h2>Peads History</h2>')
            });
        }
        function LoadEyeListHistory(PatientID) {

            if (PatientID != "(New)") {

                var rows = '';
                PageMethods.GetEyeListHistory(PatientID, function (res) {

                    var list = JSON.parse(res);
                    $.each(list, function (key, value) {
                        debugger;
                        var EyeMainTypeName = '0';
                        var EyeSubTypeName = '0';
                        var timeStamp = '<%= DateTime.Now%>'
                        var date = moment.unix(timeStamp).format('D/M/YYYY h:m:s A');
                        rows += '<tr><td>' + value.Status + '</td><td><input type="hidden" name="txtEyeUUID" value="' + uuid() + '" /> <input type="hidden" name="txtEyeMainTypeID" value=' + value.EyeMainTypeID + ' /><input type="hidden" name="txtEyeSubTypeID" value=' + value.EyeSubTypeID + ' /> ' + EyeMainTypeName + '</td><td>' + EyeSubTypeName + '</td><td>' + value.RightEye + '</td><td>' + value.LeftEye + '</td> </tr>';

                    });

                    $('#tblEyesHistory tbody').html(rows);
                    $("#tblEyesHistory").find('tr:nth-child(2) th:nth-child(2)').hide();
                    $("#tblEyesHistory").find('tr:nth-child(2) th:nth-child(3)').hide();
                    $("#tblEyesHistory").find('tr:nth-child(2) td:nth-child(2)').hide();
                    $("#tblEyesHistory").find('tr:nth-child(2) td:nth-child(3)').hide();
                    $("#tblEyesHistory").find('tr:nth-child(1) td:nth-child(2)').hide();
                    $("#tblEyesHistory").find('tr:nth-child(1) td:nth-child(3)').hide();
                    $("#tblEyesHistory tr").each(function () {
                        $(this).find('td:nth-child(2)').hide();
                        $(this).find('td:nth-child(3)').hide();
                    });
                    $("#tblEyes").find('tr:nth-child(1) td:nth-child(1)').hide();
                    $("#tblEyes").find('tr:nth-child(1) td:nth-child(2)').hide();
                });
            }
        }

        function LoadEyeList() {
            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID != "(New)") {
                var rows = '';
                PageMethods.GetEyeList(patientID, function (res) {
                    var list = JSON.parse(res);
                    $.each(list, function (key, value) {
                        var EyeMainTypeName = '0';
                        var EyeSubTypeName = '0';
                        var timeStamp = '<%= DateTime.Now%>'
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        rows += '<tr><td><input type="hidden" name="txtEyeUUID" value="' + uuid() + '" /> <input type="hidden" name="txtEyeMainTypeID" value=' + value.EyeMainTypeID + ' /><input type="hidden" name="txtEyeSubTypeID" value=' + value.EyeSubTypeID + ' /> ' + EyeMainTypeName + '</td><td>' + EyeSubTypeName + '</td><td>' + value.RightEye + '</td><td>' + value.LeftEye + '</td> <td>  <a href="javascript:void(0)" onclick=EditEyeRow(this) style="display:none;">Edit</a> <a href="javascript:void(0)" onclick=DeleteEyeRow(this)>Delete</a></td></tr>';
                    });
                    $('#tblEyes tbody').html(rows);
                    $("#tblEyes").find('tr:nth-child(1) th:nth-child(1)').hide();
                    $("#tblEyes").find('tr:nth-child(1) th:nth-child(2)').hide();
                    $("#tblEyes tr").each(function () {
                        $(this).find('td:nth-child(1)').hide();
                        $(this).find('td:nth-child(2)').hide();
                    });
                });
            }
        }

        function SaveEyeList() {
            var table = $('#tblEyes');
            var list = [];
            table.find('tbody tr').each(function (key, value) {
                var RightEye = $($(value).find('td')[2]).text();
                var LeftEye = $($(value).find('td')[3]).text();
                var EyeMainTypeID = $(value).find('td input[name=txtEyeMainTypeID]').val();
                var EyeSubTypeID = $(value).find('td input[name=txtEyeSubTypeID]').val();
                list.push({ 'EyeMainTypeID': EyeMainTypeID, 'EyeSubTypeID': EyeSubTypeID, 'RightEye': RightEye, 'LeftEye': LeftEye });
            });

            var TransactionID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (TransactionID == '(New)' || TransactionID == '')
                TransactionID = 0;
            var data = { 'TransactionID': TransactionID, 'EyeDetails': list };
            PageMethods.SaveEyeList(JSON.stringify(data), function (res) {
                SaveOrtho();
            });
        }

        function FillEyeSubTypeOnchangeOfEyeMainType() {

            $('#ddlEyeMainType').change(function () {
                PageMethods.GetEyeSubType(ddlEyeMainType.value, function (data) {
                    options = '';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlEyeSubType option').remove()
                    $('#ddlEyeSubType').html(options);

                });
            });
        }

        function EditEyeRow(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            $('#ddlEyeMainType').val($($(row).find('td input[name=txtEyeMainTypeID]')).val());
            $('#ddlEyeSubType').val($($(row).find('td input[name=txtEyeSubTypeID]')).val());
            $('#txtRightEye').val($($(row).find('td')[2]).text());
            $('#txtLeftEye').val($($(row).find('td')[3]).text());

            localStorage.uuidEyeTable = $($(row).find('td input[name=txtEyeUUID]')).val();
        }

        function DeleteEyeRow(row) {
            $($(row).parents('tr')[0]).remove();
        }

        function AddEyeRow() {

        }

        function FillEyeMainTypesAndSubTypes() {
            var options = '';
            PageMethods.GetEyeMainType(function (data) {
                options = '';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlEyeMainType option').remove()
                $('#ddlEyeMainType').html(options);
            });
        }
        function ShowEyeModel() {

            $('#EyeModel').modal({
                backdrop: 'static'
            });
        }

        function getHistoryResponse(x) {

            var resp = JSON.parse(x);
            debugger;
            for (var i = 0; i < resp.length; i++) {
                var row =
                    '<tr>' +
                    '<td>' + resp[i].Info_Type + '</td>' +
                    '<td>' + resp[i].Right_Eye + '</td>' +
                    '<td>' + resp[i].Left_Eye + '</td>' +
                    '</tr>';
                $("#tblEyesHistory").append(row);
            }
        }

        function ShowPsychiatryModel() {
            $('#PsychiatryModel').modal({
                backdrop: 'static'
            });
        }

        function swipe() {
            var largeImage = document.getElementById('Image1');
            largeImage.style.display = 'block';
            largeImage.style.width = 200 + "px";
            largeImage.style.height = 200 + "px";
            var url = largeImage.getAttribute('src');
            window.open(url, 'Image', 'width=largeImage.stylewidth,height=largeImage.style.height,resizable=1');
        }

        function ShowEntModel() {
            $('#myModalENT').modal({
                backdrop: 'static'
            });
        }

        function NewWindow() {
            window.location = "OutPatients.aspx";
        }
        function BackToList() {
            window.location = "OutPatientsView.aspx";
        }
        debugger;
        function ShowReport($this) {
            debugger;
            var row = $($this).parents('tr')[0];
            var TestDetailsIds = $($(row).find('td input[name=labTestDetaiId]')[0]).val();
            var LabTestIds = $($(row).find('td input[name=labTestIDs]')[0]).val();
            var BillDetailIds = $($(row).find('td input[name=billDetailID]')[0]).val();
            var TestId = $($(row).find('td input[name=TestIDs]')[0]).val();
            var ReportCol = $($(row).find('td input[name=ReportColumns]')[0]).val();
            var Patient_ID = $('#ctl00_MainContent_txtMRNO').val();
            window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs='
                + TestId + '&Patient_ID=' + Patient_ID + '&TransID=' + LabTestIds + '&ReportColumn=' + ReportCol);

        }

        function GetLastSelectedTab() {
            $("#tabs").tabs("option", "active", localStorage.SelectedTabID);
        }
        function PrintInPatientsReport(dv) {

            var contents = $("#" + dv).html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();

            frameDoc.document.write('<html>');
            frameDoc.document.write('<head>');
            frameDoc.document.write('<link href="css/report.css" rel="stylesheet" />');
            frameDoc.document.write('</head>');
            frameDoc.document.write('<body>');

            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function LoadOptBasicInfo(opID) {

            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/LoadOptBasicInfo",
                data: JSON.stringify({
                    'PatientID': opID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    $("#printInfo").find("#NameInfo").text(response.d.Full_Name);
                    $("#printInfo").find("#AgeInfo").text(response.d.Age_years);
                    $("#printInfo").find("#GenderInfo").text(response.d.Gender);
                    $("#printInfo").find("#NICInfo").text(response.d.NIC);
                    $("#printInfo").find("#AddressInfo").text(response.d.Permanent_Address);
                    $("#printInfo").find("#ContactInfo").text(response.d.Contact);
                    $("#printInfo").find("#PresentationInfo").text(response.d.Mode_Of_Registration);
                    $("#printInfo").find("#MRNoInfo").text(response.d.Patient_No);
                    $("#printInfo").find("#FupNoInfo").text(response.d.Follow_Up);
                    $("#printInfo").find("#DeptInfo").text(response.d.Department);
                    $("#printInfo").find("#TypeInfo").text(response.d.Patient_Type);
                    $("#printInfo").find("#DateInfo").text(response.d.Created_Time.split(' ')[0]);
                    $("#printInfo").find("#TnoInfo").text(response.d.TokenNo);
                    $("#printInfo").find("#chargesInfo").text("Rs" + response.d.Receipt_Amount.split('.')[0] + "/-");
                    $("#printInfo").find("#DNameInfo").text(response.d.Doctor_ID);

                    PrintInPatientsReport("printInfo");
                },
                Error: function (x, e) {
                    alert(e)
                }
            });

        }
        function PrintInpatientReceipt() {
            debugger;
            var disc = document.getElementById("ctl00_MainContent_CheckBox1").checked;

            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/PrintInPatientReceipt",
                data: JSON.stringify({
                    'InPatientID': ID,
                    'OUTPatientID': oUTID

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    $('#ctl00_MainContent_lblNamerpt').text(response.d.Full_Name);
                    $('#lblAgerpt').text(response.d.Age_years);
                    $('#lblGenderrpt').text(response.d.Gender);

                    if (response.d.Department != null) {
                        $('#lblDepartmentrpt').text(response.d.Department + "-" + response.d.RoomNo);
                    }
                    else {
                        $('#lblDepartmentrpt').text("");
                    }
                    if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                        $('#lblTyperpt').text(response.d.Patient_Type);
                    }
                    else {
                        $('#lblTyperpt').text(".");
                    }
                    if (response.d.Pulse_Min != null) {
                        $('#lblPlus').text(response.d.Pulse_Min);
                    }
                    if (response.d.Special_Test != null) {
                        $('#tblSpecialTest').text(response.d.Special_Test);
                    }
                    if (response.d.Area_Of_Interest != null) {
                        $('#tblAreaOf_Intrest').text(response.d.Area_Of_Interest);
                    }
                    if (response.d.Advice != null) {
                        $('#tblAdvice').text(response.d.Advice);
                    }
                    else {

                        $('#lblPlus  ').html(".");
                    }
                    if (response.d.Respiration_Min != null) {
                        $('#lblRespiration').text(response.d.Respiration_Min);
                    }
                    else {
                        $('#lblRespiration').text(".");
                    }
                    if (response.d.Temp_C != null) {
                        $('#lblTemp').text(response.d.Temp_C);
                    }
                    else {
                        $('#lblTemp').text(".");
                    }
                    if (response.d.BP != null) {
                        $('#lblBP').text(response.d.BP);
                    }
                    else {
                        $('#lblBP').text(".");
                    }
                    if (response.d.Weight != null) {
                        $('#lblWeight').text(response.d.Weight);
                    }
                    else {
                        $('#lblWeight').text(".");
                    }

                    if (response.d.HistoryOfPastIllness != null) {
                        $('#lblHistoryOfPresent').text(response.d.HistoryOfPastIllness);
                    }
                    else {
                        $('#lblHistoryOfPresent').text(".");
                    }
                    if (response.d.ObstetricHistory != null) {
                        $('#lblObstetricHistory').text(response.d.ObstetricHistory);
                    }
                    else {
                        $('#lblObstetricHistory').text(".");
                    }
                    if (response.d.drug_History != null) {
                        $('#lblDrugHistory').text(response.d.drug_History);
                    }
                    else {
                        $('#lblDrugHistory').text(".");
                    }

                    var date = response.d.Created_Time;
                    var finaldate = moment(date).format('L');
                    $('#lblDateTimerpt').text(date);

                    $('#lblAttendingDoctorrpt').text(response.d.Referring_Doctor);

                    $('#lblAddressrpt').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);

                    if (response.d.NIC == "") {
                        $('#lblCNICrpt').text(".");
                    }
                    else {
                        $('#lblCNICrpt').text(response.d.NIC);
                    }

                    if (response.d.Doctor_ID == null) {
                        $('#lblDoctorrpt').text(".");
                    }
                    else {
                        $('#lblDoctorrpt').text(response.d.Doctor_ID);
                    }


                    if (response.d.ContectNo == "") {
                        $('#lblContactrpt').text("");
                    }
                    else {
                        $('#lblContactrpt').text(response.d.ContectNo);
                    }
                    $('#lblOPDNorpt').text(response.d.MR_No);

                    $('#lblTokanNorpt  ').text(response.d.Token_No);

                    $('#lblFatherName').text(response.d.Father_Name);


                    $('#lblSlipChargesrpt').text("Rs" + parseInt(response.d.ReceiptCharges) + "/-");
                    $('#lblOperatorrpt').text(response.d.PrintedBy);
                    if (response.d.Prisentation != null) {
                        $('#lblPresentationrpt').text(response.d.Prisentation);
                    }
                    else
                        $('#lblPresentationrpt').text(".");

                    if (response.d.follow == 1) {

                        response.d.follow = "New patient";
                        $('#lblNumber').text(response.d.follow);
                    }
                    else {
                        $('#lblNumber').text(response.d.follow);
                    }
                    $('#txtFinal_Diagnosis').text(response.d.Final_Diagnosis);
                    $('#txtFollowUp').text(response.d.Follow_Up);

                    $('#txtProvisional').text(response.d.ProvisionalD);
                    if (response.d.ProvisionalD == null)
                        response.d.ProvisionalD = "";


                    var Follow_Date = response.d.Follow_Date;
                    var FollowDate = moment(Follow_Date).format('L');
                    $('#txtFollowDate').text(Follow_Date);
                    if (response.d.Advice == null)
                        response.d.Advice = "";
                    $('#txtAdvicerpt').text(response.d.Advice)

                    ID = $('#<%=txtPatient_ID.ClientID%>').val();
                    oUTID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
                    PageMethods.LoadMedicinesForHistoryrpt(ID, oUTID, function (res) {
                        debugger;
                        var Medicines = JSON.parse(res);
                        var rows = '';
                        $('#tblMedicenerpt tr').remove();


                        $.each(Medicines, function (key, value) {
                            debugger;
                            rows += '<tr><td>*</td><td style="width:400px;">' + value.Medicine_Name + '</td><td style="width:200px;"> ' + value.Recomended_Dosage + '</td><td style="width:200px;">' + value.Frequency + '</td><td style="width:200px;">' + value.Injections + ' </td></tr>';
                        });


                        $('#tblMedicenerpt').html(rows);
                        debugger;

                    });
                    PageMethods.LoadRecommendedTest(ID, oUTID, function (res) {
                        var test = JSON.parse(res);
                        var rows = '';
                        $('#tblTestRecommended tr').remove();

                        $.each(test, function (key, value) {

                            rows += '<tr><td>*</td><td>' + value.Test_Description + '</td></tr>';
                        });

                        $('#tblTestRecommended').html(rows);
                        debugger;


                    });
                    PageMethods.LoadSymptom(ID, oUTID, function (res) {
                        var test = JSON.parse(res);
                        var rows = '';
                        $('#tblsymptom tr').remove();

                        $.each(test, function (key, value) {

                            rows += '<tr><td>*</td><td style="width:350px;" >' + value.Symtom_Description + '</td><td style="width:200px;"> ' + value.Duration + '</td><td style="width:200px;"> ' + value.DaysMonth + '</td><td style="width:400px;"> ' + value.Remarks + '</td></tr>';
                        });


                        $('#tblsymptom').html(rows);
                        debugger;
                    });

                    setTimeout(function () { LoadTestrpt(); }, 5000);
                },
                Error: function (x, e) {
                    alert(e)
                }
            });
        }


        function LoadENTHistoryReport() {

            var patientName = $("#ctl00_MainContent_vlblPatients_Name").text();
            var age = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Gender = $("#ctl00_MainContent_vlblPatients_Name").text();
            var CNIC = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Address = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Contact = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Presentaion = $("#ctl00_MainContent_vlblPatients_Name").text();
            var MRNo = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Dept = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Type = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Date = $("#ctl00_MainContent_vlblPatients_Name").text();
            var TokenNO = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Charges = $("#ctl00_MainContent_vlblPatients_Name").text();
            var Operator = $("#ctl00_MainContent_vlblPatients_Name").text();
            var DoctorName = $("#ctl00_MainContent_vlblPatients_Name").text();

        }

        function LoadTestrpt(PatientID) {
            debugger;
            ID = $('#<%=txtPatient_ID.ClientID%>').val();
            oUTID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            PageMethods.LoadTestrpt(ID, oUTID, function (res) {

                var Test = JSON.parse(res);

                var rows = '';

                $('#tblTestrpt tr').remove();

                $.each(Test, function (key, value) {
                    if (value.Rotation == null) {
                        value.Rotation = "";
                    }
                    if (value.DepartmentName == null) {
                        value.DepartmentName = "";
                    }
                    if (value.Test_ID != 0) {

                        rows += '<tr><td>*</td><td>' + value.DepartmentName + '</td><td>' + value.Test_Name + '</td><td>' + value.Rotation + '</td></tr>';
                    }
                    else {

                        rows += '<tr><td>*</td><td>Lab Test</td><td>' + value.Group_Name + '</td><td>' + value.Rotation + '</td></tr>';
                    }
                });
                $('#tblTestrpt').html(rows);
                PrintInPatientsReport("PrintInPatientsReport");
            });
        }
        function checkRepeat() {

            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            PageMethods.checkRepeat(patID, function (data) {

                $.each(JSON.parse(data), function (key, value) {
                    debugger;
                    $('.se-pre-con').fadeIn();
                    $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
                    $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
                    window.location = "OutPatients.aspx?ID=" + value.Out_Patient_ID;
                    $('#btnSave').val("Update");
                    $('#btnSave_Vital').val('Update Vital');

                });
            }, function (error) { })
        }

        function checkDepartment() {


            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            if (patID != "") {
                PageMethods.checkDepartment(patID, function (data) {
                    var rows;
                    $.each(JSON.parse(data), function (key, value) {

                        var timeStamp = parseInt(value.Created_Time.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Segment1 == null) {

                            rows += '<tr> <td> ' + newdate + ' </td> <td> ' + value.DepartmentName
                                + ' </td>  </tr>';
                        }
                        else {
                            rows += '<tr> <td> ' + newdate + ' </td> <td> ' + value.DepartmentName + "(" + value.Segment1
                                + ")" + ' </td>  </tr>';
                        }
                    });
                    $('#tblDept tbody').html(rows);
                }, function (error) { })
            }

        }

        debugger;
        $(function () {
            $("#ctl00_MainContent_ddlDepartment").change(function () {
                debugger;
                check();
            });
        });
        debugger;
        function loadDynamicTextBoxs() {
            debugger;
            var a = $("#ctl00_MainContent_ddlDepartment").find(":selected").text().trim();
        }




        $(function () {
            $("#fileupload").change(function (event) {
                var x = URL.createObjectURL(event.target.files[0]);
                $("#upload-img").attr("src", x);
                console.log(event);
            });
        })



        debugger;
        function sendFile(ID) {
            debugger
            console.log(ID);
            var data = new FormData();
            data.append('file', $('#fileupload')[0].files[0]);
            data.append('ID', ID);
            $.ajax({
                type: 'post',
                url: 'UploadStudImg.ashx',
                data: data,
                success: function (status) {
                },
                processData: false,
                contentType: false,
                error: function () {
                   
                }
            });
        }

        debugger;
        function downloadFile() {
            debugger;
            var ID = '<%=Request.QueryString["ID"]%>';
            var downloadUrl = 'DownloadFile.ashx?ID=' + ID;
            window.location.href = downloadUrl;
        }


        debugger;
        function PrintoutPatient() {
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            var url = '../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + id;
            window.open(url, '_blanks');
        }

        debugger;
        function Reffared_printView() {
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            var url = '../../ReportViewer.aspx?ReportName=OutPatientRefferal&Title=Out Patient Report&outPatientID=' + id;
            window.open(url, '_blanks');
        }
        debugger;
        $(document).ready(function () {
            debugger;
            fillDepartment();
            $("#ddl_xray_rotation").hide();
            $('#ctl00_MainContent_ddlProto').select2();
            LoadTemplate();
            LoadTemplateForTest();
            debugger;
            var txtpatids = $('#<%= txtPatient_ID.ClientID%>').val() || 0;

            if (txtpatids > 0) {
                localStorage.clear();
            }
            $('#txtPharmacyItem').on('select2:select', function (e) {
                debugger;
                getTemplate();

            });
            AllowOPDTabs();
            var ids = '<%=Request.QueryString["ID"]%>';
            debugger;
            if (ids != "") {
                loaddoctor(id);

            }
            else {
                loadAllDoctor();
            }
            //localStorage.clear();
            
            $('#Add_Unlisted_Medicine').attr('disabled', false);
            $('#tblHistoryTabHistoryHeader').show();
            $('#tblSymptomHistory').show();
            $('#LoadSymp').show();
            $('#tblPsychiatryHistory').show();
            $('#tblHistoryTabHistory').show();

            $('.se-pre-con').fadeIn();

            debugger;
            $('#tblEyes').hide();
            $('#btnAddEye').hide();
            $("#txtMedicineName").hide();
            $("#lblMed").hide();
            filldoc();
            $("#tblMedicines").find('tr:eq(0)').find('td:eq(0)').hide();

            $('#btnGetAllIServices').on('click', function () {
                debugger;
                LoadAllitem('');
            });
            $('#searchInput').on('keyup', function () {
                debugger
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });
            $('#btngetalltest').on('click', function () {
                debugger;
                LoadAllTests('', '');
            });
            $('#searchInput_test').on('keyup', function () {
                debugger;
                var searchTexttest = $(this).val().trim();
                var CategoryID = $('#ddlMainTestDepartment').val();
                LoadAllTests(CategoryID, searchTexttest);
            });



            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                var discharge = $('#' + '<%= hdfdhischarge.ClientID %>').val();

                if (discharge == "true") {
                    $('#btnSave').attr('disabled', true);
                }
                else {
                    $('#btnSave').attr('disabled', false);
                }

                setTimeout(function () {
                    $("#tabs").tabs("option", "active", 0);
                    check();
                }, 1000);
            }
            else {
                fillPendingPatientsList();
                setTimeout(function () {
                    $("#ctl00_MainContent_ddlDepartment").val(0);
                    $("#tabs").tabs("option", "active", 0);
                    $('#ui-id-20').hide();
                    $('#ui-id-21').hide();

                    $('#ui-id-19').show();
                    $("#tblPeExam").find('tr:nth-child(3)').hide();
                    $("#tblPeExam").find('tr:nth-child(2)').hide();

                }, 1000);
            }


            $("#tbleyeType").find('tr:nth-child(1) td:nth-child(1)').hide();
            $("#tbleyeType").find('tr:nth-child(1) td:nth-child(2)').hide();
            $("#tbleyeType").find('tr:nth-child(2) td:nth-child(1)').hide();
            $("#tbleyeType").find('tr:nth-child(2) td:nth-child(2)').hide();
            $("#tblEyes").find('tr:nth-child(1) th:nth-child(1)').hide();
            $("#tblEyes").find('tr:nth-child(1) th:nth-child(2)').hide();
            $("#tblEyesHistory").find('tr:nth-child(2) th:nth-child(2)').hide();
            $("#tblEyesHistory").find('tr:nth-child(2) th:nth-child(3)').hide();
            $("#tblEyesHistory").find('tr:nth-child(2) td:nth-child(2)').hide();
            $("#tblEyesHistory").find('tr:nth-child(2) td:nth-child(3)').hide();
            $("#tblEyes").find('tr:nth-child(1) td:nth-child(1)').hide();
            $("#tblEyes").find('tr:nth-child(1) td:nth-child(2)').hide();
            $("#ctl00_MainContent_Label16").show();
            $("#ctl00_MainContent_txtGYNAE").show();
            $("#ctl00_MainContent_txtCVS").show();
            $("#ctl00_MainContent_Label2").show();
            $("#ctl00_MainContent_txtRESP").show();
            $("#ctl00_MainContent_Label6").show();
            $("#ctl00_MainContent_txtAbdomin").show();
            $("#ctl00_MainContent_lblAbdomin").show();
            $("#ctl00_MainContent_lblNextPlan").hide();
            $("#ctl00_MainContent_txtNextPlan").hide();
            $("#ctl00_MainContent_txtMUAC").hide();
            $("#ctl00_MainContent_txtOFC").hide();
            $("#ctl00_MainContent_lblMUAC").hide();
            $("#ctl00_MainContent_lblOFC").hide();
            $("#vitalparams").find('tr:nth-child(7) td:nth-child(4)').hide();
            $("#vitalparams").find('tr:nth-child(7) td:nth-child(3)').hide();
            $('#ctl00_MainContent_txtBMI').focusout(function () {
                $('#btnSave').focus();
            });

            if (document.getElementById('ctl00_MainContent_rdbPeads_LSCS').checked) {
                $('#TDPeadsEmergency').show();
                $('#TDPeadsElective').show();
            }
            else {
                $('#TDPeadsEmergency').hide();
                $('#TDPeadsElective').hide();
            }

            $("#ctl00_MainContent_txtLMP").datepicker();
            $("#ctl00_MainContent_txtedd").datepicker();

            LoadEyeList();
            FillEyeMainTypesAndSubTypes();
            FillEyeSubTypeOnchangeOfEyeMainType();
            $("#ctl00_MainContent_FollowNoDate").datepicker();
            var today = new Date();
            var dd = today.getDate();
            var mm = today.getMonth() + 1;
            $("#ctl00_MainContent_txtPeads_DateOfDelivery").datepicker();
            $("#ctl00_MainContent_txtPeads_TimeOfDelivery").ptTimeSelect();
            var yyyy = today.getFullYear();

            if (dd < 10) {
                dd = '0' + dd
            }

            if (mm < 10) {
                mm = '0' + mm
            }
            debugger;
            today = mm + '/' + dd + '/' + yyyy;
            $('#txtMedicen').hide();
            $('#<%= txtPatient_ID.ClientID%>').change(function () {
                loadAjax();
                $('#ctl00_MainContent_btnSave').val("Save");
                $('#ctl00_MainContent_txtOut_Patient_ID').val("(New)");
                ClearAll();
                $('#<%= txtPatient_ID.ClientID%>').val($('#<%= hdfPatient_ID.ClientID%>').val());
                $('#<%= txtOut_Patient_ID.ClientID%>').val("(New)");
                checkRepeat();
                checkDepartment();
                LoadHistory();
                var dateValue = '<%= DateTime.Now.Date.ToString(AppConfig.DateFormat)%>';
                $("#ctl00_MainContent_FollowNoDate").val(dateValue);

            });
                 <%if (Request.QueryString["ID"] != null)
        {%>
            $('#btnSave').val("Update");
            $('#btnSave_Vital').val('Update Vital');
                 <%}%>
            jQuery(window).on("load", function () {
                debugger;
                $('#ctl00_MainContent_ddlDepartment').val('0');

                SelectActualDataOnPageLoad();
            });

            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != null) {
                if (id != '') {
                    ajaxCall('OutPatients.aspx/getEyeInfo', "{'Out_Patient_ID':" + id + "}", getEyeInfoResponse);
                    ajaxCall('OutPatients.aspx/getSlitInfo', "{'Out_Patient_ID':" + id + "}", getSlitResponse);
                    ajaxCall('OutPatients.aspx/loadEyeHistory', "{'Out_Patient_ID':" + id + "}", getHistoryResponse);
                }
            }
            $(".se-pre-con").fadeOut("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "auto");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "auto");


        });


        var tabsOPd;
        function AllowOPDTabs() {
            debugger;
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/checkOPD_tabs",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    tabsOPd = data.d;

                    if (tabsOPd == "true") {
                        $('#ui-id-3').hide();
                        $('#ui-id-4').hide();
                        $('#ui-id-5').hide();
                        $('#ui-id-7').hide();
                        $('#ui-id-8').hide();
                        $('#ui-id-9').hide();
                    }
                    else {
                        $('#ui-id-3').show();
                        $('#ui-id-4').show();
                        $('#ui-id-5').show();
                        $('#ui-id-7').show();
                        $('#ui-id-8').show();
                        $('#ui-id-9').show();
                    }

                },
                failure: function () {
                    alert(bi);
                }
            });


        }
        function getSlitResponse(x) {
            var data = JSON.parse(x);
            debugger;
            if (data.length > 0) {
                $('#txtInteriorRight0').val(data[0].Interior_Right.toString().trim());
                $('#txtInteriorLeft0').val(data[0].Interior_Left.toString().trim());
                $('#txtPosteriorRight0').val(data[0].Posterior_Right.toString().trim());
                $('#txtPosteriorLeft0').val(data[0].Posterior_Left.toString().trim());
            }
        }

        function getEyeInfoResponse(x) {
            var data = JSON.parse(x);
            for (var i = 0; i < data.length; i++) {
                $('#txtRightEye' + i + '').val(data[i].Right_Eye);
                $('#txtLeftEye' + i + '').val(data[i].Left_Eye);
            }
        }

        function ajaxCall(url, data, getResposeParam) {
            debugger;
            var call = '';
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: url,
                data: data,
                async: true,
                success: function (resp) {
                    debugger;
                    getResposeParam(resp.d);
                },
                error: function (data) {
                    alert("Error");
                }
            });
        }

        function LoadHistoryTabHistory(PatientID) {


            PageMethods.LoadHistoryTabHistory(PatientID, function (res) {

                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));

                    var retdate = moment(TrnsDate).format('LLLL');
                    if (value.Reffer_To == null) {
                        value.Reffer_To = "";
                    }
                    if (value.Mucculor == null) {
                        value.Mucculor = "";
                    }
                    if (value.Local == null) {
                        value.Local = "";
                    }
                    rows += '<tr> <td> ' + retdate + ' </td><td>' + value.Status + '</td> <td> ' + value.HistoryOfPeresentIllness
                        + ' </td> <td> ' + value.HistoryOfFamily + ' </td><td> ' + value.DevelopmentHistory + ' </td> <td> ' + value.VaccinationHistory + ' </td><td> ' + value.NutritionHistory + ' </td><td> ' + value.SocioEconomicHistory + ' </td> <td> ' + value.Birth_History + ' </td> <td> ' + value.Drug_History + ' </td> <td> ' + value.Personal_History + ' </td> <td> ' + value.ObstetricHistory + ' </td><td> ' + value.AllergiesHistory + ' </td ><td> ' + value.TreatmentHistory + ' </td><td> ' + value.GIT + ' </td><td> ' + value.CVS + ' </td><td> ' + value.CNS + ' </td><td> ' + value.RESP + ' </td><td> ' + value.GYNAE + ' </td><td> ' + value.URG + ' </td><td> ' + value.Abdominal + ' </td><td> ' + value.PAGynae + ' </td><td> ' + value.PSGynae + ' </td><td> ' + value.Uterus + ' </td><td> ' + value.FX + ' </td><td> ' + value.PSObs + ' </td><td> ' + value.PVObs + ' </td><td> ' + value.SFH + ' </td><td> ' + value.LIE + ' </td><td> ' + value.Presentation + ' </td><td> ' + value.FHR + ' </td><td> ' + value.Engagement + ' </td><td> ' + value.Mucculor + ' </td><td> ' + value.Local + ' </td><td> ' + value.ProvisionalDiagnosis + ' </td><td> ' + value.txtRemarksHistory + ' </td><td> ' + value.txtInputBox1 + ' </td><td><a href="#" onclick="LoadHistoryFromhistory(' + value.Out_Patient_Id + ')"> Select </a> </td> </tr>';


                });
                $('#tblHistoryTabHistory tbody tr').remove();
                $('#tblHistoryTabHistory tbody').html(rows);
                $('#tblHistoryTabHistoryHeader').html('<h2>Previous History</h2>')
                $(".se-pre-con").fadeOut("slow");
            });
        }
        function LoadControlHistory(PatientID) {
            debugger;

            PageMethods.LoadControlHistory(PatientID, function (res) {

                var Data = JSON.parse(res);
                var rows = '';
                $.each(Data, function (key, value) {
                    debugger;
                    var timeStamp = parseInt(value.Created_Time.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    var datearray = date.split("/");

                    var updateTime = '';
                    var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                    if (value.Updated_Time != null) {
                        if (value.Updated_Time != '') {
                            timeStamp = parseInt(value.Updated_Time.substr(6, 10));
                            date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                            datearray = date.split("/");
                            updateTime = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        }
                    }
                    if (value.Admission == null)
                        value.Admission = "";
                    if (value.Follow_Up == null)
                        value.Follow_Up = "";
                    if (value.Folllow_Date == null)
                        value.Folllow_Date = "";


                    if (value.Folllow_Date == null)
                        value.Folllow_Date = "";
                    //if (value.Doctor_ID != null)
                    //    $('#ctl00_MainContent_ddlDoctorName').val(value.Doctor_ID).trigger('change');
                    if (value.Doctor_ID == null) {
                        loadAllDoctor();
                        $('#ctl00_MainContent_ddlDoctorName').attr('disabled', true);
                    }

                    var timeFolllow_Date = parseInt(value.Folllow_Date.substr(6, 10));
                    var datefOLLW = moment.unix(timeFolllow_Date).format('M/D/YYYY h:m:s A');
                    var arraydatefOLLW = datefOLLW.split("/");

                    var newdatefOLLW = arraydatefOLLW[1] + '/' + arraydatefOLLW[0] + '/' + arraydatefOLLW[2];
                    rows += '<tr>' +
                        '<td> ' + newdate + ' </td>' +
                        '<td> ' + updateTime + ' </td>' +
                        '<td> ' + value.Doctor_Name + ' </td>' +
                        '<td> ' + value.Designation + ' </td>' +
                        '<td> ' + value.Admission + ' </td>' +
                        '<td> ' + value.Discharge + ' </td>' +
                        '<td> ' + value.FinalDiagnosis + ' </td>' +
                        '<td> ' + value.Follow_Up + ' </td>' +
                        '<td> ' + newdatefOLLW + ' </td>' +
                        '<td> ' + value.Advice + ' </td>' +
                        '<td> ' + value.Next_Plan + ' </td>' +
                        '</tr>';

                });
                $('#tblControlHistory tbody').html(rows);
                $('#tblControlHistoryHeader').html('<h2 class="headingcolr">Previous History</h2>')
            });
        }

        function LoadMedicationHistory(PatientID) {
            $('#dvHistoryMedication').hide();
            if (PatientID != '(New)') {
                $('#HeaderHistoryMedication').html('<h2 class="headingcolr">Loading Previous History Please Wait....</h2>')
                PageMethods.LoadMedicinesForHistory(PatientID, function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {
                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];

                        rows += '<tr>';
                        rows += '<td><input type="checkbox" class="history-checkbox" /></td>';
                        rows += '<td>' + newdate + '</td>';
                        rows += '<td>' + value.Status + '</td>';
                        rows += '<td>' + value.Medicine_Name + '</td>';
                        rows += '<td>' + value.Frequency + '</td>';
                        rows += '<td>' + value.Oral + '</td>';
                        rows += '<td>' + value.Injections + '</td>';
                        rows += '<td>' + value.AttendingParamedical_Staff + '</td>';
                        rows += '</tr>';

                        if (value.Medicine_Name.length > 0) {
                            $('#dvHistoryMedication').show();
                        } else {
                            $('#dvHistoryMedication').hide();
                        }
                    });
                    $('#tblHistoryMedication tbody tr').remove();
                    $('#tblHistoryMedication tbody').html(rows);
                    $('#HeaderHistoryMedication').html('<h2 style="color:white !important">Previous History</h2>');


                    $('#select-all-checkbox').change(function () {
                        var isChecked = $(this).prop('checked');
                        $('.history-checkbox').prop('checked', isChecked);
                    });
                });
            }
        }

        function LoadSymtompsHistory(PatID) {
            $('#dvSyptomHistory').hide();
            if (PatID != '(New)') {
                if (PatID != '') {
                    PageMethods.LoadSymtompsHistory(PatID, function (res) {
                        var Symtomps = JSON.parse(res);
                        var rows = '';
                        $.each(Symtomps, function (key, value) {

                            var rowID = uuid();
                            rows += '<tr> <td style="display:none;"> ' + value.Symtom_ID + ' </td><td>' + value.Status + '</td> <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + ' </td> <td> ' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td></tr>';

                            if (value.Symtom_ID.length > 0)
                                $('#dvSyptomHistory').show();
                            else
                                $('#dvSyptomHistory').hide();

                        });
                        $('#tblSymptomHistory tbody').html(rows);
                    });
                }
            }
        }
        function LoadTestList() {

            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID != "(New)") {
                PageMethods.GetTestList(patientID, function (res) {
                    var test = JSON.parse(res);

                    var rows = '';
                    $.each(test, function (key, value) {
                        var Result = 'Pendding';
                        var Sample = 'No';

                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Is_Result == true) {
                            Result = "View Result";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == false) {
                            Result = "Waiting";
                            Sample = "Yes";
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i class="fa fa-trash"></i></a></td></tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i class="fa fa-trash"></i></a></td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i class="fa fa-trash"></i></a></td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultOPD(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i class="fa fa-trash"></i></a></td></tr>';
                        }
                        $('.tests-table').append(row);
                    });
                });
            }
        }

        function LoadTestsHistory(PatientID) {
            if (PatientID != '(New)') {
                $('#tblHistoryTests tbody tr').remove();
                PageMethods.GetTestListForHistory(PatientID, function (res) {
                    debugger;
                    var test = JSON.parse(res);
                    var rows = '';
                    var Sample = 'No';
                    $.each(test, function (key, value) {
                        debugger;
                        var Result = 'Pending';
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        var datearray = date.split("/");
                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Is_Result == true) {
                            Result = "Resulted";
                            Sample = "Yes";
                        }
                        if (value.Is_Result == false) {
                            Result = "Waiting";
                            Sample = "No";
                        }
                        if (value.Test_ID != 0) {
                            if (value.Department_ID == "001") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td>' + value.Status + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td> </tr>';
                            }
                            else {
                                if (value.Department_ID == "003") {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="' + value.DataValue_Name + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td></tr>';
                                }
                                else {
                                    row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/> <input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td></tr>';
                                }
                            }
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + newdate + '">' + newdate + '</td><td>' + value.Status + '</td>   <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td>   <td>' + Sample + '</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> </tr>';
                        }
                        $('#tblHistoryTests tbody').append(row);
                    });
                });
            }
        }
        debugger;

        function LoadHistory() {
            debugger;
            if ($('#<%= hdfPatient_ID.ClientID%>').val() != undefined) {
                LoadVitalParametersHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadMedicationHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadTestsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadControlHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                loadtest($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadHistoryTabHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadSymtompsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadENTHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadEyeListHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadDermaHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPsychiatryHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPsychiatryHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadOrtho($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPeadsHistory($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadPeadsHistoryInpat($('#<%= hdfPatient_ID.ClientID%>').val());
                LoadServices_ProceduresForHistory($('#<%= hdfPatient_ID.ClientID%>').val());
            }
        }



        function LoadENTHistory(PatientID) {
            $('#dvENTHistory').hide();
            PageMethods.LoadENTHistory(PatientID, function (res) {
                var Data = JSON.parse(res);
                var rows = '';

                $.each(Data, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    rows += '<tr id="' + value.Out_Patient_ID + '"><td>';
                    if (value.Status.toLowerCase() != "inpatient") {
                        rows += '<a href="ReportViewer.aspx?OutPatientID=' + value.Out_Patient_ID + '&ReportName=rptPrintEnt" target="_blank" onclick="" class="printEnt" rel="' + value.Out_Patient_ID + '">Print</a></td>';
                    }
                    else
                        rows += '-';
                    rows += '<td> ' + retdate + '</td><td>' + value.Status + '</td> <td> ' + value.ENT_Throat_IDL + ' </td> <td> ' + value.ENT_Throat_Nose
                        + ' </td> <td> ' + value.ENT_Ear_Right + ' </td> <td> ' + value.Ent_Ear_Left +
                        ' </td><td> ' + value.ENT_Rinnes_Right_PosNeg + ' </td> <td> ' + value.ENT_Rinnes_Right_Neg +
                        ' </td> <td> ' + value.ENT_Rinnes_Right_FalseNeg + ' </td> <td> ' + value.ENT_Rinnes_Right_FNeg +
                        ' </td> <td> ' + value.ENT_Rinnes_Lft_PosNeg + ' </td><td> ' + value.ENT_Rinnes_Lft_Neg +
                        ' </td><td> ' + value.ENT_Rinnes_Lft_FalseNeg + ' </td><td> ' + value.ENT_Rinnes_Lft_FNeg +
                        ' </td><td> ' + value.ENT_Webber_Central + ' </td><td> ' + value.ENT_Webber_Lateralized +
                        ' </td><td> ' + value.ENT_Investigation_PTA + ' </td><td> ' + value.ENT_Investigation_Tympanometry +
                        ' </td></tr> ';

                    if (value.ENT_Throat_IDL.length > 0)
                        $('#dvENTHistory').show();
                    else
                        $('#dvENTHistory').hide();
                });
                $('#tblENTHistory tbody tr').remove();
                $('#tblENTHistory tbody').html(rows);
                $('#tblENTHistoryHeader').html('<h2>ENT History</h2>')
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
        function getTemplate() {
            var item_id = $('#txtPharmacyItem').val();
            PageMethods.loadtemplate(item_id, function (resp) {
                debugger;
                var data = JSON.parse(resp);

                if (data && data.length > 0) {
                    var templateData = data[0];
                    debugger;
                    setDropdownText('#ddlDosage_Qty', templateData.Dosage_Qty);
                    setDropdownText('#ddlDosage_From', templateData.Dosage_From);
                    setDropdownText('#txtRecomended_Dosage', templateData.Frequency);
                    setDropdownText('#txtInjection', templateData.Injections);
                    setDropdownText('#Routes', templateData.Oral);
                    //$('#txtInjection').val(templateData.Injections);
                    $('#AttendingParamedicalStaff').val(templateData.AttendingParamedical_Staff);
                    setDropdownText('#ddlOther_Instruction', templateData.Other_Instruction);
                }
            },
                function (error) {
                    alert(error.get_message());
                });
        }

        function setDropdownText(selector, text) {

            var dropdown = $(selector);
            var matchFound = false;
            dropdown.find('option').each(function () {
                if ($(this).text().trim() === text.trim()) {
                    dropdown.val($(this).val()).trigger('change');
                    matchFound = true;
                    return false;
                }
            });
            if (!matchFound) {
                console.error(`No matching option found for text: ${text}`);
            }
        }



        function FillOtherTest() {

            var options = '';

            PageMethods.FillOtherTest(function (item) {
                $.each(JSON.parse(item), function (key, value) {
                    options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                });
                $('#ddlOtherTest').html(options);
                $('#ddlOtherTest').select2();

            });
        }

        var options = '<option value=""> Select Frequency  </option>'



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
                $('#divRotation').hide();
                $('#ddl_xray_rotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (CategoryID == '003') {
                $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                $('#divRotation').show();
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
                $('#divRotation').hide();

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


        function LoadSymtomps() {
            var outPatID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            if (outPatID != '(New)') {
                if (outPatID != '') {
                    PageMethods.LoadSymtomps(outPatID, function (res) {
                        var Symtomps = JSON.parse(res);
                        var rows = '';
                        $.each(Symtomps, function (key, value) {

                            var rowID = uuid();
                            rows += '<tr> <td style="display:none;"> ' + rowID + ' </td> <td style="display:none;"> ' + value.Symtom_ID + ' </td> <td> ' + value.Symtom_Name + ' </td> <td> ' + value.Duration + ' </td> <td> ' + value.Days_Years_Months + ' </td> <td> ' + value.Remarks + ' </td> <td> <a href="#" onclick="Edit_Symtom(this)">Edit</a>|<a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';

                        });
                        $('#tblSymtoms tbody').html(rows);
                    });
                }
            }
        }
        debugger;
        function filldoc() {
            var options;
            PageMethods.Getdoctors(function (data) {
                debugger;
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $("#ctl00_MainContent_ddldocname").html(options);
                $("#ctl00_MainContent_ddldocname").select2();
            });
            return options;
        }

        function fillDepartment() {
            var options;
            PageMethods.GetAllDeparmtent(function (data) {
                debugger;
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $("#ctl00_MainContent_ddlPatientDepartment").html(options);
                $("#ctl00_MainContent_ddlPatientDepartment").select2();
            });
            return options;
        }
        function FillDropDowns() {
            PageMethods.FillDays_Years_MonthsDropDown(function (data) {
                var options = '';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value=' + value.DataValue_Name + '> ' + value.DataValue_Description + '</option>';
                });
                $('#ddlDaysMonthsYears').html(options);
            })
        }

        function Edit_Symtom(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            $('#txtDuration').val($($(row).find('td')[3]).text());
            $('#ddlDaysMonthsYears').find('option:contains(' + $(row).find('td')[4].innerText + ')')[0].selected = true;
            $('#txtRemarks').val($($(row).find('td')[5]).text());
            localStorage.SymtomID = $($(row).find('td')[1]).text();
            localStorage.SymtomName = $($(row).find('td')[2]).text();
            localStorage.rowID = $($(row).find('td')[0]).text();
            LoadTokenInputForSymtoms();
        }

        function SaveHistoryTab() {

            var SymtomsList = [];

            $.each($('#tblSymtoms tbody tr'), function (key, value) {
                debugger;

                var dayYearMonthText = $($(value).find('td')[4]).text();
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                dayYearMonthText = dayYearMonthText.replace(" ", "");
                var dayYearMonthID = $('#ddlDaysMonthsYears').find('option:contains(' + dayYearMonthText + ')')[0].value;

                SymtomsList.push({ 'SymtomID': $($(value).find('td')[1]).text(), 'Duration': $($(value).find('td')[3]).text(), 'DayYearMonth': dayYearMonthID, 'Remarks': $($(value).find('td')[5]).text() });
            });

            var SymtomsList = {
                OutPatientID: ($('#ctl00_MainContent_txtOut_Patient_ID').val() != "(New)") ? $('#ctl00_MainContent_txtOut_Patient_ID').val() : "0",
                SymtomsList: SymtomsList
            }
            PageMethods.SaveSymtoms(JSON.stringify(SymtomsList), function (response) { SaveEyeList() });

        }
        debugger;

        function Add_SymtomRow() {
            debugger;

            var checksymtomadded = false;
            $(".symtopclass").each(function () {
                var symtomid = $(this).val();
                if (symtomid == localStorage.SymtomID) {
                    checksymtomadded = true;
                }
            });
            if (checksymtomadded === false) {
                $("#btnAddHistory").removeClass("btn-info").addClass("btn-danger");
                var rowID = uuid();

                var symp = $('#txtSymtom').val();

                var html = '<tr> <td style="display:none;"> <input type="hidde" class="symtopclass" value="' + localStorage.SymtomID + '" />' + rowID + ' </td> <td style="display:none;"> ' + localStorage.SymtomID + ' </td> <td> ' + localStorage.SymtomName + ' </td> <td> ' + $('#txtDuration').val() + ' </td> <td> ' + $('#ddlDaysMonthsYears').find('option:selected').text() + ' </td> <td> ' + $('#txtRemarks').val() + ' </td> <td> <a href="#" onclick="Edit_Symtom(this)">Edit</a>|<a href="#" onclick="Delete_Symtom(this)">Delete</a></td></tr>';


                if (symp === "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Fill Symptom First',
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
                    $('#tblSymtoms tbody').append(html);
                }

                $('#txtSymtom').tokenInput('clear');
                $('#txtDuration').val("");
                $('#ddlDaysMonthsYears').val("001");
                $('#txtRemarks').val("");
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Symptom already added',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
        }

        function Delete_Symtom(row) {
            $($(row).parents('tr')[0]).remove();
        }


        function RemoveExtraDepts() {

            var UserID = '<%= Session["UserID"]%>';

            PageMethods.RemoveExtraDepts(UserID, SuccessFunc, function (exec) { })
        }

        function SuccessFunc(data) {

            var parsedData = JSON.parse(data);
            var options = '<option value="0">Please Select</option>';
            $.each(parsedData, function (key, value) {
                options += '<option value=' + value.Department_ID + '> ' + value.Department_Name + '</option>';
            });

            $('#ctl00_MainContent_ddlDepartment').html(options);
            $('#ctl00_MainContent_ddlDepartment').val(localStorage.DeptID);
        }

        function fillPendingPatientsList() {
            debugger;
            $(".se-pre-con").fadeIn("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            var filterDepartment = $('#ctl00_MainContent_ddlPatientDepartment').val();
            var doc_name = $('#ctl00_MainContent_ddldocname').val();
            if (doc_name == null) {
                doc_name == "0"
            }

            PageMethods.PendingPatients(filterDepartment, doc_name, function (data) {
                debugger;
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                    debugger;
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');
                    var status = '';
                    var FilterClinic = (value.FilterClinic === null || value.FilterClinic === '' || value.FilterClinic === 'Please Select') ? '' : value.FilterClinic;
                    var DoctorName = value.DoctorName ?? '';
                    var rowColorStyle = '';

                    if (value.BP == null || value.BP == '') {
                        status = 'Un Checked';
                    } else {
                        status = 'Checked';
                        rowColorStyle = 'style="background-color: #aeffae;"';
                    }

                    rows += '<tr ' + rowColorStyle + '> <td>' + value.Patient_No + '</td> <td> ' + value.Token_No + ' </td>' + '<td>' + value.Full_Name + '</td> ' + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + value.Department + '<td>' + FilterClinic + '</td> ' + '<td>' + DoctorName + '</td> ' + '<td>' + retdate + '</td> ' + '<td>' + value.UserName + '</td> ' + '<td>' + status + '</td>' + ' <td> <a href="javascript:void(0)" onclick=select(' + value.Patient_ID + ')><i class="fa fa-upload" ></i></a> </td> </tr>';
                });
                debugger;
                $('#tblPendingPatients tbody').html(rows);

                $(".se-pre-con").fadeOut("slow");

            }, function (exec) { })
        }

        debugger;
        function LoadTokenInputForSymtoms() {
            debugger;
            $('#txtSymtom').tokenInput('clear');

            var SymtomID = localStorage.SymtomID;

            if (SymtomID != '') {

                SymtomID = "";

                for (var i = 0; i < localStorage.SymtomID.length; i++) {
                    if (i == 0) {

                    }
                    else {
                        SymtomID += localStorage.SymtomID[i];
                    }
                }
                var tokenData = httpGet("../../json.aspx?Table=Symtoms&Mode=Edit&q=" + SymtomID);

                var parsedData = JSON.parse(tokenData);

                $('#txtSymtom').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
            }
        }
        function select(PatID) {
            debugger;
            $(".se-pre-con").fadeIn("slow");
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            localStorage.PatID = PatID;
            window.location.href = 'OutPatients.aspx';
        }
        debugger;
        function ClearAll() {

            $('#tabs').find('input:text').each(function () {

                $('<%# txtOut_Patient_ID.ClientID%>').value = "(New)";
                $('select option:nth-child(1)').attr('selected', 'selected');
                $(':text, textarea').val('');
                $('input:checkbox').removeAttr('checked');
                $('#tblSymtoms tbody tr').remove();
                $('#tblVitalParametersHistory tbody tr').remove();
                $('#tblHistoryTabHistory tbody tr').remove();
                $('#tblENTHistory tbody tr').remove();
                $('#tblSymptomHistory tbody tr').remove();
                $('#tblMedicinesList tbody tr').remove();
                $('#tblHistoryMedication tbody tr').remove();
                $('.tests-table tbody tr').remove();
                $('#tblHistoryTests tbody tr').remove();
                $('#tblControlHistory tbody tr').remove();
                $('#ctl00_MainContent_btnSave').val('Save');


            });
        }
        debugger;
        function SelectActualDataOnPageLoad() {
            debugger;
            $('.se-pre-con').fadeIn();
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            debugger;
        


        
            if ($('#hdfPatient_ID').val() == '(New)') {
                debugger;
                if (localStorage.PatID != "0" && localStorage.PatID != undefined) {
                    debugger;
                    var pat = localStorage.PatID;
                    $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
                    var tokenData = httpGet("../../json.aspx?Table=Out_Patients&Record=Edit&q=" + pat);
                    var parsedData = JSON.parse(tokenData)[0];

                
                    $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: localStorage.PatID, name: parsedData.name });
                 
                    $("#hdfReg_ID").val(parsedData.regPatId);
                    $('#<%= txtPatient_ID.ClientID%>').val(localStorage.PatID);
                    $('#<%= hdfPatient_ID.ClientID%>').val(localStorage.PatID);
                    localStorage.PatID = 0;

                    loadAjax();
                    $('#ctl00_MainContent_btnSave').val("Save");
                    $('#ctl00_MainContent_txtOut_Patient_ID').val("(New)");

                    $('#<%= txtOut_Patient_ID.ClientID%>').val("(New)");
                    checkRepeat();
                    LoadHistory();
                }
            }

        }
        debugger;
        function loadtokenInputsDefault() {
            debugger;
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=Out_Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger;
                        try {
                            $('.se-pre-con').fadeIn();
                            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
                            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
                            $("#hdfPatient_ID").val(item.id);
                            $("#hdfReg_ID").val(item.regPatId);
                            localStorage.PatientIDforNewForm = item.id;
                            loadAjax();
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
        }
        debugger;
        function loadtokenInputsDefaulte() {
            $('#ctl00_MainContent_txtMRNO').tokenInput("../../json.aspx?Table=Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            debugger;
                            $("#ctl00_MainContent_txtMRNO").val(item.id);
                           // loadtest();
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
        }
        debugger;
        function loadtokenInputsByMrNo(data) {
            debugger;
            $("#ctl00_MainContent_txtPatNO").tokenInput("../../json.aspx?Table=Out_PatientsbyMrNo",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                        $("#hdfReg_ID").val(item.reg_patId);
                        localStorage.PatientIDforNewForm = item.id;
                        $("#ctl00_MainContent_txtPatient_ID").val(item.id);
                        localStorage.SelectedTabID = 1;
                        loadAjax();
                        LoadHistory();
                        checkRepeat();
                    }
                });
        }
        function loadtokenInput(data) {
            $("#ctl00_MainContent_txtMRNO").tokenInput("../../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger;
                        $('.se-pre-con').fadeIn();
                        $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
                        $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
                        $("#ctl00_MainContent_txtMRNO").val(item.id);
                       // loadtest();
                    }
                });


        }
        function FillMainTestDepartment() {

            var options = '<option value="0" >Select Main Department</option>';

            PageMethods.FillTestMainDepartment(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainTestDepartment').html(options);
                $('#ddlMainTestDepartment').select2();

            });
        }

        function AddBloodTest() {
            var test = $('#ddlTestList').find('option:selected').text();

            PageMethods.GetBBDDLDetails(test, function (res) {

                $.each(JSON.parse(res), function (key, value) {

                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    if (value.Test_ID != 0) {

                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupCategoryName == null ? ' ' : ', ' + value.GroupCategoryName) + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" href="javascript:void(0)" onclick="deleteTest(this)"><i style="color: white !important;margin-top: 10px;" class="fa fa-trash"></a></td></tr>';

                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="deleteTest(this)">Delete</a></td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }

                    $('.tests-table').append(row);
                    $("#ctl00_MainContent_txtSpecialTests").val("");
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");
                });

            }, function (err) { });

        }

        function AddLabTest(maindpt) {
            debugger;
            var test = $('#ddlTestList').find('option:selected').text();


            PageMethods.GetLabTestDDLDetails(test, maindpt, function (res) {

                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = 'Result';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                    var dateValue = '<%= DateTime.Now%>';
                    var TestMainDepartmentName;
                    var row;
                    var test_array;

                    if (value.Test_ID != 0) {
                        row = '<tr>' +
                            '<td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>' +
                            '<td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' +
                            '<input type="hidden" name="txtRotation" value="0">' +
                            '<input type="hidden" name="txtGroupCategory" value="0">' +  // Added closing quote for value attribute
                            '<input type="hidden" name="txtDeptID" value="' + maindpt +'"/> ' +
                            (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') +
                            value.Test_Name +
                            '</td>' +
                            '<td>No</td>' +
                            '<td>' + Result + '</td>' +
                            '<td><input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' +
                            ctl00_MainContent_txtSpecialTests.value + '</td>' +
                            '<td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' +
                            ctl00_MainContent_txtAreaOfInterest.value + '</td>' +
                            '<td><input type="hidden" name="rowid" value="' + uuid() + '" />' +  // Removed the space before <input>
                            '<a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="deleteTest(this)">' +
                            '<i class="fa fa-trash" style="color: white !important;margin-top: 10px;"></i></a>' +
                            '</td></tr>';


                        test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + maindpt + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                        '<a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="deleteTest(this)">' +
                            '<i class="fa fa-trash" style="color: white !important;margin-top: 10px;"></i></a>' +
                            '</td></tr>';
                        test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                    }

                    $('.tests-table').append(row);

                });
                $("#ctl00_MainContent_txtSpecialTests").val("");
                $("#ctl00_MainContent_txtAreaOfInterest").val("");

            }, function (err) { });

        }

        function AddRadialogyTest() {
            debugger;
            $("#btnXray").removeClass("btn-danger").addClass("btn-info");
            $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
            $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");

            var Result = 'Result';
            var test = $('#ddlTestList').val();
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
            var dateValue = '<%= DateTime.Now%>';
            var IsRotationShow = $('#divRotation').is(":visible");

            var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
            var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
            if (Rotation_Name == "Select" || Rotation_ID == 0) {
                Rotation_ID = "";
                Rotation_Name = "";
            }

            var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
            var ddl_XRayLF_Name = IsRotationShow ? $('#ddlXRayLF option:selected').text() : " ";
            var ddlXRayLF_Name = ',' + ddl_XRayLF_Name;

            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetTestMainDepartmentDetails",
                data: JSON.stringify({ TestID: test }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {

                    var MainDeptName = JSON.parse(data.d);
                    TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                    MainDepartmentName = MainDeptName[0].estMainDepartmen;

                    if (MainDepartmentName == "003") {

                        var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td><td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="deleteTest(this)">' +
                            '<i class="fa fa-trash" style="color: white !important;margin-top: 10px;"></i></a>' +
                            '</td></tr>';
                    }
                    else {
                        var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" />' +
                            '<a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="deleteTest(this)">' +
                            '<i class="fa fa-trash" style="color: white !important;margin-top: 10px;"></i></a>' +
                            '</td></tr>';
                    }
                    debugger;
                    var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');


                    $('.tests-table').append(row);
                    $('#ddlXRayLF option:selected').val("0");
                    $("#ctl00_MainContent_txtSpecialTests").val("");
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");
                },
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function AddProcedureTest() {
            var Result = 'Result';
            var Procedure = $('#ddlTestList').val();
            var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
            var dateValue = '<%= DateTime.Now%>';

            var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + Procedure + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"><input type="hidden" name="txtDeptID" value="0"/> ' + $('#ddlProcedure').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';


            var test_array = $('.tests-table').find('input[name=testID][value="' + Procedure + '"]');

            $('.tests-table').append(row);




        }
        function AddAllTest() {
            debugger;
            var maindpt = $('#ddlMainTestDepartment').val();
            var CheckTest = $('#ddlTestList').val();

            if (CheckTest != 0 || CheckTest != null) {
                if (maindpt == "001") {
                    AddLabTest(maindpt);

                }
                else if (maindpt == "002") {
                    AddRadialogyTest();

                }
                else if (maindpt == "003") {
                    AddRadialogyTest();

                }
                else if (maindpt == "004") {
                    AddRadialogyTest();

                }
                else if (maindpt == "005") {

                    AddBloodTest();

                    $('#divRotation').hide();
                }
                else if (maindpt == "006") {

                    FillProcedure("006");

                    $('#divRotation').hide();
                }
                else if (maindpt == "007") {

                    FillProcedure("007");
                    $('#ddlXRayLF').hide();
                    $('#divRotation').hide();
                }
                else if (maindpt == "008") {
                    AddCardioTest(maindpt);

                }
            }
            else {

            }

        }
        function AddCardioTest(maindpt) {
            debugger;
            var test = $('#ddlTestList').find('option:selected').text();


            PageMethods.GetCardioDDLDetails(test, maindpt, function (res) {

                $.each(JSON.parse(res), function (key, value) {
                    debugger;
                    var Result = 'Pending';
                    var test = $('#ddlLabTest').val();
                    var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
             var dateValue = '<%= DateTime.Now%>';
             var TestMainDepartmentName;
             var row;
             var test_array;

             if (value.Test_ID != 0) {

                 row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                 test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
             }
             else {
                 row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + value.Main_Department + '"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';
                 test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
             }

             $('.tests-table').append(row);
             //}
         });
         $("#ctl00_MainContent_txtSpecialTests").val("");
         $("#ctl00_MainContent_txtAreaOfInterest").val("");

     }, function (err) { });

         }

        function LoadTestByDepartment() {
            debugger;
            var maindpt = $('#ddlMainTestDepartment').val();

            

            if (maindpt == "0") {
                $('#ddlTestList').val("");
                $('#ddlTestList').text("");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            if (maindpt == "001") {
                $('#ddl_xray_rotation').hide();
                FillLabTests();
               
                $('#ddlXRayLF').hide();

            }
            else if (maindpt == "002") {
                $('#ddlXRayLF').hide();
                $('#ddl_xray_rotation').hide();
                FillTestsByCategory('002');
               
            }
            else if (maindpt == "003") {
                $('#ddl_xray_rotation').show();
                FillTestsByCategory('003');
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "004") {
                $('#ddl_xray_rotation').hide();
                FillTestsByCategory('004');
                $('#ddlXRayLF').hide();

            }
            
            else if (maindpt == "005") {
                $('#ddl_xray_rotation').hide();
                FillProcedure("005");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "006") {
                $('#ddl_xray_rotation').hide();
                FillProcedure("006");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "007") {
                $('#ddl_xray_rotation').hide();
                FillProcedure("007");
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();
            }
            else if (maindpt == "008") {
                GetCardioTests();
                $('#divRotation').hide();
                $('#ddlXRayLF').hide();

            }
        }



        function GetCardioTests() {
            var options = '<option value="0" >Please Select</option>';
            PageMethods.GetCardioTests(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ddlTestList').html(options);
                $('#ddlTestList').select2();
                localStorage.TestForCategoryWiseSelections = options;
            });
        }
        function EditResultOPD(anchor) {

            txtRecievedID
            var row = $(anchor).parents('tr')[0];
            var CatagoryID = $($(row).find('td input[name=txtGroupCategory]')[0]).val();
            var txtRecievedID = $($(row).find('td input[name=txtRecievedID]')[0]).val();
            var TestDetailID = $($(row).find('td input[name=TestDetailID]')[0]).val();
            var LabTestID = $($(row).find('td input[name=LabTestID]')[0]).val();
            var valuetype = $($(row).find('td input[name=txtValueType]')[0]).val();
            var ID = "";
            var labTestID = "";
            if (CatagoryID != 0) {
                PageMethods.LoadAllTestResultCatagory(txtRecievedID, CatagoryID, function (data) {

                    var alldata = JSON.parse(data);
                    $.each(alldata, function (key, value) {
                        ID += value.Lab_Test_Detail_ID + ',';
                        labTestID = value.Lab_Test_ID
                    });

                    showImage(labTestID);
                    $('#IDtest').val(ID);
                    $('#type').val(valuetype);
                    $('#myResultModal').modal({
                        backdrop: 'static'
                    });
                }, function (error) { })
            }
            else {
                $('#IDtest').val(txtRecievedID);

                $('#type').val(valuetype);
                showImage(txtRecievedID);
                $('#myResultModal').modal({
                    backdrop: 'static'
                });
            }
        }
        debugger;
        function EditData(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            var CatagoryID = $($(row).find('td input[name=CatagoryID]')[0]).val();
            var TestDetailID = $($(row).find('td input[name=TestDetailID]')[0]).val();
            var LabTestID = $($(row).find('td input[name=LabTestID]')[0]).val();
            var valuetype = $($(row).find('td input[name=valuetype]')[0]).val();
            var GroupCategory = $($(row).find('td input[name=txtGroupCategory]')[0]).val();

            var labTestDetaiIds = "";
            var labTestID = "";
            var testIds = "";
            var billDetailId = "";
            var reportCol = "";
            PageMethods.LoadAllTestCatagory(LabTestID, CatagoryID, GroupCategory, function (data) {

                var alldata = JSON.parse(data);
                $.each(alldata, function (key, value) {
                    labTestDetaiIds += value.Lab_Test_Detail_ID + ',';
                    testIds += value.Test_ID + ',';
                    labTestID = value.Lab_Test_ID;
                    billDetailId = value.Bill_Details_ID;
                    reportCol = value.Report_Colum
                });

                showImage(TestDetailID);
                $('#labTestDetails').val(labTestDetaiIds);
                $('#labTestIDs').val(labTestID);
                $('#billDetailIDs').val(billDetailId);
                $('#TestID').val(testIds);
                $('#ReportColumn').val(reportCol);

                $('#type').val(valuetype);
                $('#myResultModal').modal({
                    backdrop: 'static'
                });
            }, function (error) { })

        }
        function showImage(testDetailID) {

            PageMethods.LoadimagesDetail(testDetailID, function (res) {
                if (res == null || res == "[]" || res == "undefined") {
                    $("#errorMsg").show();
                }
                else { $("#errorMsg").hide(); }
                var test = JSON.parse(res);
                var rows = '';
                var dvPreview = $("#dvPreview");
                dvPreview.html("");
                $.each(test, function (key, value) {
                    var img = $("<img onclick='window.open(this.src)'/>");
                    img.attr("style", "height:60px;width: 60px");
                    var dd = value.Image_path;
                    img.attr("src", dd);
                    dvPreview.append(img);
                    if (value.Image_path == null || value.Image_path == "" || value.Image_path == "undefined") {
                        $("#errorMsg").show();
                    }
                    else { $("#errorMsg").hide(); }
                });
            });
        }
        function loadtest(pat_id) {
            debugger;
            var txtMRNO = $("#ctl00_MainContent_txtMRNO").val();
            if (txtMRNO != null) {
                PageMethods.GetTestResultList(pat_id, function (res) {
                    debugger;
                    var test = JSON.parse(res);
                    console.log(test);
                    var rows = '';
                    $.each(test, function (key, value) {
                        debugger;
                        var img_Id = value.Image_ID;
                        var img_path = value.ImagePath;
                        test_wise_id = value.patient_ID;
                        if (value.DepartmentName == "Lab Test") {
                            var RDate = moment(value.Test_Ready_On).format('L');
                            var CDate = moment(value.Service_Date).format('L');
                            console.log(CDate)
                        }
                        else {
                            var RDate = moment(value.Test_Ready_On).format('L');
                            var CDate = moment(value.Service_Date).format('L');
                        }
                        if (value.Test_Collected_By == null) {
                            value.Test_Collected_By = "";
                        }
                        debugger;
                        if (value.Is_Result == true && value.Is_Approve == true) {
                            debugger;
                            if (img_Id == "" || img_Id == null) {
                                debugger;
                                result = "View Result";
                                preview = "Preview";
                                rows += '<tr><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + CDate + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + RDate + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Test_Name + '</td><td>' + value.Test_Collected_By + '</td><td style="display:none;"></td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"> <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td style="display:none;" class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/></td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="labtestDIDs" id="labtestDIDs" value="' + value.Lab_Test_ID + '" /><input type="hidden" name="TestDetailID" id="TestDetailID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                            }
                            else {
                                debugger;
                                result = "View Result";
                                preview = "Preview";
                                rows += '<tr><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + CDate + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + RDate + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Test_Name + '</td><td>' + value.Test_Collected_By + '</td><td style="display:none;"></td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"> <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td style="display:none;" class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/></td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="labtestDIDs" id="labtestDIDs" value="' + value.Lab_Test_ID + '" /><input type="hidden" name="TestDetailID" id="TestDetailID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td><td name="imageview" id="imageview"> <a onclick="ImgPreviewReport(' + img_Id + ')"> View Image </a></td></tr>';
                            }
                        }

                        else {
                            if (value.DepartmentName == "Lab Test") {
                                debugger;
                                var RDate = moment(value.Test_Ready_On).format('L');
                                var CDate = moment(value.Service_Date).format('L');
                                var advice_date = moment(value.Service_Date).format('L');
                            }
                            else {
                                var RDate = moment(value.Test_Ready_On).format('L');
                                var CDate = moment(value.Service_Date).format('L');
                                var advice_date = moment(value.Service_Date).format('L');
                            }
                            if (value.Test_Collected_By == null) {
                                value.Test_Collected_By = "";
                            }
                            var advice_date = moment(value.Service_Date).format('L');
                            result = "Waiting";
                            rows += '<tr><td><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="billDetailID" value="' + value.Bill_Details_ID + '" /><input type="hidden" name="TestDetailID" value="' + value.Lab_Test_Detail_ID + '" /><input type="hidden" name="CatagoryID" value="' + value.Catagory_ID + '" /><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '" />' + advice_date + '</td><td>' + RDate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '" />' + value.DepartmentName + ', ' + value.Test_Name + ', ' + (value.Rotation == null ? "" : value.Rotation) + '</td></td><td>' + value.Test_Collected_By + '</td><td><input type="hidden" id="valuetype" value="' + value.Value_Type + '"><span>' + result + '</span></a></td></tr>'
                        }
                    });
                    $('#tblResultTest tbody tr').remove();
                    $('#tblResultTest tbody').html(rows);
                });
            }
        }

        debugger;
        function ImgPreviewReport(img_Id) {
            var PatientID = $('#<%= hdfReg_ID.ClientID %>').val();
           if (!PatientID || PatientID === '(New)') {
               Swal.fire({
                   icon: 'error',
                   title: 'Error!',
                   text: 'Patient registration ID not found. Please select a patient first.',
                   showConfirmButton: true
               });
               return;
           }
           var Image_Id = img_Id;
           window.open('../../ReportViewer.aspx?ReportName=TestResultQImg&ReportTitle=Department Of Pathalogy&PatientID=' + PatientID + '&Image_Id=' + Image_Id);
       }
        debugger;
        function PreviewReport($this) {
            debugger;
            var tbl = $($($this).parents('tr')[0]);
            var hdn_Patient_ID = tbl.find("td").find("input[id=Patient_Id]").val();
            var ChkLetterHead = true;
            var ListOfTestIDs = '';
            var ListTransID = '';
            var Report_Column = '';
            var LabTestDetailsID = '';

            Report_Column = tbl.find('td').find('input[name=Report_Colum]').val();
            ListOfTestIDs = tbl.find('td').find('input[name=List_Of_Test_IDs]').val();
            test_wise_ids = tbl.find('td').find('input[name=test_wise_id]').val();
            ListTransID = tbl.find('td:eq(8) #labtestDIDs').val();
            LabTestDetailsID = tbl.find('td:eq(8) #TestDetailID').val();
            var billdetailid = tbl.find('td:eq(8) #Bill_Details_ID').val()
            var testIds = tbl.find('td:eq(8) #ListOfTestIDs').val();
            if (testIds == "null" || testIds == '') {
                debugger;
                testIds = tbl.find('td:eq(0) #labtestDID').val();
                ListOfTestIDs = testIds;
            }
            else {
            }

            ListBillDetailID = billdetailid.replace(', ', '');
            window.open('../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead);
        }
        debugger;
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=Out_Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdfPatient_ID").val(item.id);
                        localStorage.PatientIDforNewForm = item.id;

                        localStorage.SelectedTabID = 1;
                        $("#tabs").tabs("option", "active", localStorage.SelectedTabID);
                        $('#ctl00_MainContent_txtPuls').focus();
                    }
                });

            loadAjax();
        }
        $(document).on('keyup', '.select2-search__field', function () {
            var searchString = $(this).val();

            if (searchString.length < 2) {
                return;
            }

            $.ajax({
                url: 'OutPatients.aspx/getpharmacyitems',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ searchString: searchString }),
                success: function (response) {
                    try {
                        var pharmacyItems = JSON.parse(response.d);
                        var $select = $('#txtPharmacyItem');

                        $.each(pharmacyItems, function (key, value) {
                            var optionExists = $select.find('option[value="' + value.Item_ID + '"]').length > 0;
                            if (!optionExists) {
                                $select.append('<option value="' + value.Item_ID + '">' + value.Description + '</option>');
                            }
                        });

                        $select.trigger('change');

                    } catch (error) {
                        console.error('Error parsing response:', error);
                    }
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching data:', error);
                }
            });
        });

        $(document).on('keydown', '.select2-search__field', function (event) {
            if (event.keyCode === 13) {
                $('#txtPharmacyItem').select2('close');
            }
        });



        debugger;
        $(document).ready(function () {


            debugger;
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            $('#txtSymtom').tokenInput("../../json.aspx?Table=Symtoms",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            localStorage.SymtomName = item.name;
                            localStorage.SymtomID = item.id;
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });


            $("#ctl00_MainContent_txtService").tokenInput("../../json.aspx?Table=INV_ItemsForBilling",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {

                        try {

                            localStorage.SelectedItemID = item.id;
                            localStorage.SelectedItemType = item.Type;
                            localStorage.SelectedItemName = item.name;
                            localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);

                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });
            FillMainTestDepartment()
            FillOtherTest()
            FillDropDowns();
            debugger;
            var id = '<%=Request.QueryString["ID"]%>';
            if (id == "") {
                RemoveExtraDepts();
                var abc = $('#<%=txtOut_Patient_ID.ClientID%>').val();

            }



            var ids = '<%=Request.QueryString["ID"]%>';
            debugger;
            if (ids != "") {
                loaddoctor(id);

            }
            else {
                loadAllDoctor();
            }

            $('#ddldoctors').attr('disabled', false);
           // loaddoctor();
            loaddoctor_byDep();         
            $('#ctl00_MainContent_ddlPatientDepartment').on("change", function () {
                       /* localStorage.DeptID =*/ $('#ctl00_MainContent_ddlPatientDepartment').find('option:selected')[0].value;
                fillPendingPatientsList();
            })

            var OPD_Patient = $('#<%=txtPatient_ID.ClientID%>').val();

            if (OPD_Patient == "(New)")
                OPD_Patient = localStorage.PatientIDforNewForm;
            if (OPD_Patient != "") {


                var Patient_ID = OPD_Patient;
                var tokendata = httpGet("../../json.aspx?Table=OutPatients&Patient_ID=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
                var tokendatas = httpGet("../../json.aspx?Table=OutPatients_MrNo&Patient_ID=" + Patient_ID);
                loadtokenInputsByMrNo(JSON.parse(tokendatas));

            }
            else {
                loadtokenInputsDefault();
                loadtokenInputsByMrNo();
            }
            var OPD_MR = $('#<%=txtMRNO.ClientID%>').val();


            if (OPD_MR != "") {

                var Patient_ID = OPD_MR;
                var tokendata = httpGet("../../json.aspx?Table=OutPatients&Patient_ID=" + Patient_ID);
                loadtokenInput(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefaulte();
            }
            LoadPatientCategory();
            $(function () {
                $("#tabs").tabs();
                $('#PsychiatryTabs').tabs();
                $('#PeadsTabs').tabs();
                $('#tabsn').tabs();
                $('#tabGO').tabs();
                GetLastSelectedTab();
            });
            if ($('#<%=txtOut_Patient_ID.ClientID%>').val() != "(New)") {

                LoadMedicines();
                LoadTestList();
                LoadSymtomps();
                LoadHistory();
                LoadServices_Procedures();
                Load_Proto();


            }


            FillRoutes();
            FillFrequency();
            FillDosage();
            FillDuration();
            FillOtherInstruction();
            FillDosageQty();
            FillMedicine();
            FillPharmacyItem();
            checkDepartment();

            debugger;
            $('#btnAddMedicine').on("click", function () {

                debugger;
                $("#btnSaveMedicine").val('Save');
                $('#MedicationModel').modal({
                    backdrop: 'static'

                });
                $('#txtMedicen').hide();
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('0');
                $('#AttendingParamedicalStaff').val('');
                $('#ddlDosage_From').val('');

            });
            debugger;
            $('#btnSave_Vital').on("click", function () {

                Global_Vital = 1;
                SaveMedicinesAndTests();
            });
            $('#btnSaveMedicine').on("click", function () {
                debugger;
                if ($('#txtPharmacyItem').find('option:selected').text().trim() == 'Reassurance') {
                    $('#txtDosage').val("0");
                    $('#txtInjection').val("0");
                    $('#AttendingParamedicalStaff').val("0");

                }

                if ($('#txtPharmacyItem').val() == 'Select Medicine' || $('#txtPharmacyItem').val() == null) {
                    $('#txtPharmacyItem').val('');
                }

                if ($('#txtMedicen').val() != '' && $('#txtPharmacyItem').val() != '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter One Name',
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
                if ($('#txtMedicen').val() == '' && $('#txtPharmacyItem').val() == '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Name',
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
                var UnListedMed = $('#txtMedicen').val();

                if ($('#txtPharmacyItem').val() != '')
                    var pharmacyITem = $('#txtPharmacyItem').find('option:selected').text()
                else {
                    var pharmacyITem = $('#txtMedicen').val()
                }


                var Dose = $('#txtDosage').val();
                if (Dose == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Dose',
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
                var Frequency = $('#txtRecomended_Dosage').val();
                if (Frequency == "" || Frequency == "0" || Frequency == null) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Frequency',
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
                var DosageFrom = $('#ddlDosage_From').val();
                if (DosageFrom == 'Select') DosageFrom = '';

                var Route = $('#Routes').val();
                if (Route == "Select Routes") Route = '';
                if (Route == "" || Route == "0") {
                }
                var Duration = $('#txtInjection').val();
                if (Duration == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Duration',
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
                var datetime = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A")%>';
                var datetimeValue = '<%= DateTime.Now%>';
                var dosage_from = $('#ddlDosage_From').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_From').find('option:selected').text();
                var dosage_Qty = $('#ddlDosage_Qty').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlDosage_Qty').find('option:selected').text();
                var routes = $('#Routes').find('option:selected').text().trim() == 'Select Routes' ? '' : $('#Routes').find('option:selected').text();
                var duration = $('#txtInjection').find('option:selected').text().trim() == 'Select Duration' ? '' : $('#txtInjection').find('option:selected').text();
                var other_Instruction = $('#ddlOther_Instruction').find('option:selected').text().trim() == 'Select' ? '' : $('#ddlOther_Instruction').find('option:selected').text();

                if ($(this).val() == 'Save') {
                    debugger;
                    var medicine = ''//$('#txtMedicineName').val();
                    var pharmacyItem = $('#txtPharmacyItem').val();
                    var itemCode = $('#txtPharmacyItem').find('option:selected').val();
                    if (medicine == '') {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td><input type="hidden" name="hdnItemCode" value="0"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + routes + ' </td> <td> ' + duration + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td><td style="display:none;">' + itemCode + '</td></tr>';
                    }
                    else {
                        debugger;
                        var row = '<tr> <td> <input type="hidden" name="testDate" value="' + datetimeValue + '">' + datetime + ' </td><td> <input type="hidden" name="hdnItemCode" value="' + pharmacyItem + '"> ' + pharmacyITem + '</td> <td> ' + $('#txtRecomended_Dosage').find('option:selected').text() + ' </td> <td> ' + '</td><td> ' + routes + ' </td> <td> ' + duration + '<td> ' + $('#AttendingParamedicalStaff').val() + '</td><td> ' + dosage_from + '</td><td> ' + dosage_Qty + '</td><td> ' + other_Instruction + ' </td>' + '<td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + itemCode + '</td></tr>';
                    }

                    var table = $('#tblMedicinesList tbody');
                    table.append(row);
                }
                else if ($(this).val() == 'Update') {
                    debugger;

                    var tid = $('#MedicationModel input[name=uurowid]').val();

                    var row = $('#tblMedicinesList tbody tr').find('input[value=' + tid + ']').parents('tr')[0];

                    $(row).find('td')[1].innerText = $('#txtPharmacyItem').find('option:selected').text().trim();
                    $(row).find('td')[2].innerText = $('#txtRecomended_Dosage').find('option:selected').text();

                    $(row).find('td')[3].innerText = $('#MedicationModel select[name=Routes]').find('option:selected').text();
                    // $(row).find('td')[4].innerText = $('#MedicationModel input[name=txtInjection]').val();
                    $(row).find('td')[4].innerText = $('#MedicationModel select[name=txtInjection]').find('option:selected').text();
                    $(row).find('td')[5].innerText = $('#MedicationModel input[name=AttendingParamedicalStaff]').val();
                    $(row).find('td')[7].innerText = $('#ddlDosage_Qty').find('option:selected').text().trim();
                    $(row).find('td')[8].innerText = $('#ddlOther_Instruction').find('option:selected').text().trim();
                    var medicine_id = $(row).find('td')[10].innerText;
                    if (medicine_id == '') {
                        $(row).find('td')[1].innerText = $('#txtMedicen').val();
                    }

                    $(row).find('td')[10].innerText = $('#txtPharmacyItem').val();
                    '<a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a>'
                }
                $('#txtMedicen').hide();
                $('#txtMedicen').val('');
                $('#txtMedicineName').val('');
                $('#txtRecomended_Dosage').val('');
                $('#txtDosage').val('');
                $('#Routes').find('option:nth-child(1)')[0].selected = true;
                $('#txtInjection').val('');
                $('#AttendingParamedicalStaff').val('');
                $('#txtMedicineName').focus();
                $('#ddlDosage_From').val('');
                $('#ddlDosage_Qty').val('');
                $('#ddlOther_Instruction').val('');
                $('#txtPharmacyItem').val('0').trigger('change');
            });



            $('#add-new-test').click(function () {


            });

            $('#add-new-testDirect').click(function () {



            });
            $('#add-new-Procedure').click(function () {

                var Result = 'Result';
                var Procedure = $('#ddlProcedure').val();
                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';

                var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + Procedure + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"><input type="hidden" name="txtDeptID" value="0"/> ' + $('#ddlProcedure').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                var test_array = $('.tests-table').find('input[name=testID][value="' + Procedure + '"]');
                if (test_array.length > 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This Procedure already added!',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                } else {
                    $('.tests-table').append(row);

                }
            });

            $('#add-new-Othertest').click(function () {

                var Result = 'Result';
                var test = $('#ddlOtherTest').val();
                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';

                var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtddlXRayLF_Name" value="0"><input type="hidden" name="txtDeptID" value="0"/> ' + $('#ddlOtherTest').find('option:selected').text() + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)">Delete</a></td></tr>';

                var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');


                $('.tests-table').append(row);


            });



        });




        function uuid() {
            var uuid = "", i, random;
            for (i = 0; i < 32; i++) {
                random = Math.random() * 16 | 0;

                if (i == 8 || i == 12 || i == 16 || i == 20) {
                    uuid += "-"
                }
                uuid += (i == 12 ? 4 : (i == 16 ? (random & 3 | 8) : random)).toString(16);
            }
            return uuid;
        }
        function calculateBMI() {
            var height_in_cm = parseFloat($('#ctl00_MainContent_txtHeight').val());
            var weight_kg = parseFloat($('#ctl00_MainContent_txtWeight').val());


            if (isNaN(height_in_cm) || isNaN(weight_kg)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter valid height and weight.',
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

            var height_m = height_in_cm / 100;
            var calcBMI = weight_kg / (height_m * height_m);

            $('#ctl00_MainContent_txtBMI').val(calcBMI.toFixed(2));
        }

        function FillRoutes() {
            PageMethods.FillRoutesDropDown(function (Routes) {
                var options = '<option value="0"> Select Routes </option>'
                $.each(JSON.parse(Routes), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#Routes').html(options);

            });
        }

        function FillFrequency() {
           // FillPharmacyItem
            PageMethods.FillFrequencyDropDown(function (Frequency) {
                var options = '<option value="0"> Select Frequency  </option>'
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + "-" + value.Segment1 + ' </option>';
                });
                $('#txtRecomended_Dosage').html(options);

            });
        }
        function FillDuration() {
            FillPharmacyItem
            PageMethods.FillDurationDropDown(function (Frequency) {
                var options = '<option value="0"> Select Duration  </option>'
                $.each(JSON.parse(Frequency), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.Segment1 + ' </option>';
                });
                $('#txtInjection').html(options);

            });
        }
        function FillDosage() {
            PageMethods.FillDosageDropDown(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_From').html(options);
            });
        }
        function FillDosageQty() {
            PageMethods.FillDosageQty(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlDosage_Qty').html(options);
            });
        }
        function FillOtherInstruction() {
            PageMethods.FillOtherInstruction(function (Dosage) {
                var options = '<option value="0"> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlOther_Instruction').html(options);
            });
        }
        function FillPharmacyItem() {
            PageMethods.FillPharmacyItemDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.Item_ID + '"> ' + value.Description + ' </option>';
                });

                $('#txtPharmacyItem').html(options);
                $('#txtPharmacyItem').select2();


            });
        }

        function Cleardrpdwn() {

            FillMedicine();
        }
        function CleardrpdwnItem() {

            FillPharmacyItem()
        }
        function FillMedicine() {
            PageMethods.FillMedicineDropDown(function (Medicine) {
                var options = '<option value=""> Select Medicine  </option>'
                $.each(JSON.parse(Medicine), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#txtMedicineName').html(options);

            });
        }

        function LoadAllitem(searchText) {
            debugger;
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetAllServices",
                data: JSON.stringify({ searchText: searchText }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var items = JSON.parse(response.d);
                    debugger;
                    var tableBody = $('#itemsTableBody');
                    tableBody.empty();
                    $.each(items, function (index, item) {
                        var row = '<tr>' +
                            '<td><input type="checkbox" class="itemCheckbox" onclick="handleCheckboxClick(this)"></td>' +
                            '<td>' + item.Item_ID + '</td>' +
                            '<td>' + item.Item_Code + '</td>' +
                            '<td>' + item.Description + '</td>' +
                            '<td>' + item.Sale_Rate + '</td>' +
                            '</tr>';
                        tableBody.append(row);
                    });
                    $('#itemsModal').modal('show');
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function handleCheckboxClick(anchor) {
            if ($(anchor).is(':checked')) {
                append(anchor);
            }
        }

        function handletestcheck(anchor) {
            debugger;
            if ($(anchor).is(':checked')) {
                AddtestbyDep(anchor);
            }
        }
        function LoadAllTests(CategoryID, searchTexttest) {
            debugger;
            var CategoryID = $('#ddlMainTestDepartment').val();
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/GetAllTest",
                data: JSON.stringify({ CategoryID: CategoryID, searchTexttest: searchTexttest }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger
                    var items = JSON.parse(response.d);
                    debugger
                    var tableBody = $('#testLabletbody');
                    tableBody.empty();
                    $.each(items, function (index, item) {
                        var row = '<tr>' +
                            '<td><input type="checkbox" class="itemCheckbox" onclick="handletestcheck(this)"></td>' +
                            '<td>' + item.TestID + '</td>' +
                            '<td>' + item.TestName + '</td>' +
                            '</tr>';
                        tableBody.append(row);
                    });
                    $('#testmodal').modal('show');
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }



        function append(anchor) {
            debugger;
            var User_Name = '<%= AppConfig.UserName %>';
            var entryDate = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt") %>';
            var row = $(anchor).closest('tr');
            var Item_ID = $(row).find('td:eq(1)').text();
            var Item_Code = $(row).find('td:eq(2)').text();
            var Item_name = $(row).find('td:eq(3)').text();
            var Sale_Rate = $(row).find('td:eq(4)').text();
            var item_type = "Service";

            var exists = false;
            $('#tblServices tr').each(function () {
                var existingItemCode = $(this).find('td:eq(1)').text();
                if (existingItemCode === Item_Code) {
                    exists = true;
                    return false;
                }
            });
            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already Exists in the table.',
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
            var length = $("#tblServices tr").length;
            length++;


            var rows = '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + Item_ID + '" /> <input type="hidden" name="hdnItemName" value="' + Item_name + '" /> <input type="hidden" name="hdnNet_Amount" value="' + Sale_Rate + '" /> <input type="hidden" name="hdnItemType" value="' + item_type + '" /> <input type="hidden" name="hdnPageType" value="IPD" />' + Item_name + '</td><td style="text-align:left;">' + User_Name + '</td> <td style="text-align: left;"><a href="javascript:void(0)" onclick="DeleteRow(this)"style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a> </td> </tr>';


            $("#tblServices").append(rows);


            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });

        }
        debugger;
        function AddProto() {
            debugger;
            var protoval = $('#ctl00_MainContent_ddlProto').val();
            var prototext = $('#ctl00_MainContent_ddlProto option:selected').text();

            var rows = '<tr><td ><input type="hidden" name="ProtoId" value="' + protoval + '" />' + prototext + '</td> <td style="text-align: left;"> <a  href="#" onclick="DeleteRow(this)">Delete</a> </td> </tr>';
            $("#tblProto").append(rows);
        }

        function SaveProtos() {
            debugger;
            var table = $("#tblProto");
            var ProcedureList = [];
            var btnSave = $('#btnSave').val();
            table.find("tbody tr").each(function (key, value) {
                ProcedureList.push({
                    'Proto_Description': $($(value).find("td")[0]).text(),
                    'ProtoId': $($(value).find("td")[0]).find("input[name=ProtoId]").val(),
                });
            });
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            var opdid = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            var ProtoDetails = { PatId: patID, opdid: opdid, ProtoList: ProcedureList };
            PageMethods.SaveProto(btnSave, JSON.stringify(ProtoDetails), function (response) {

            });
        }
        function Load_Proto() {
            debugger;
            if ($("#<%= hdfPatient_ID.ClientID%>").val() !== "(New)") {
                var patients_id = $('#<%= txtOut_Patient_ID.ClientID %>').val();
                PageMethods.LoadProtoDetails(patients_id, function (response) {
                    var Proto = JSON.parse(response);
                    var rows = "";

                    $.each(Proto, function (key, value) {
                        rows += '<tr><td ><input type="hidden" name="ProtoId" value="' + value.ProtoId + '" />' + value.Proto_Description + '</td>  </tr>';
                    });
                    $('#tblProto tbody').append(rows);
                });
            }
        }
        function AddtestbyDep(anchor) {
            debugger;
            var row = $(anchor).closest('tr');
            var CategoryID = $('#ddlMainTestDepartment').val();
            var test_id = $(row).find('td:eq(2)').text();
            var test = $(row).find('td:eq(1)').text();

            if (CategoryID == '001') {


                PageMethods.GetlabDetailByCategory(test_id, CategoryID, function (res) {

                    $.each(JSON.parse(res), function (key, value) {
                        debugger;
                        var Result = 'Result';
                        var test = $('#ddlLabTest').val();
                        var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                        var dateValue = '<%= DateTime.Now%>';
                        var TestMainDepartmentName;
                        var row;
                        var test_array;

                        if (value.Test_ID != 0) {

                            row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory value="0"><input type="hidden" name="txtDeptID" value="' + value.Main_Department +'"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + '</td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a></td></tr>';

                            test_array = $('.tests-table').find('input[name=testID][value="' + value.Test_ID + '"]');
                        }
                        else {
                            row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Group_Category + '"/><input type="hidden" name="txtDeptID" value="' + value.Main_Department +'"/> ' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Test_Name + ' </td>   <td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a></td></tr>';
                            test_array = $('.tests-table').find('input[name=txtGroupCategory][value="' + value.Group_Category + '"]');
                        }

                        $('.tests-table').append(row);
                    });
                    $("#ctl00_MainContent_txtSpecialTests").val("");
                    $("#ctl00_MainContent_txtAreaOfInterest").val("");

                }, function (err) { });
            }

            else if (CategoryID == '002' || CategoryID == '003' || CategoryID == '005' || CategoryID == '008') {
                debugger;
                $("#btnXray").removeClass("btn-danger").addClass("btn-info");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");

                var Result = 'Result';

                var date = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now%>';
                var IsRotationShow = $('#divRotation').is(":visible");

                var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
                var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
                if (Rotation_Name == "Select" || Rotation_ID == 0) {
                    Rotation_ID = "";
                    Rotation_Name = "";
                }

                var ddlXRayLF_ID = IsRotationShow ? $('#ddlXRayLF option:selected').val() : "0";
                var ddl_XRayLF_Name = IsRotationShow ? $('#ddlXRayLF option:selected').text() : " ";
                var ddlXRayLF_Name = ',' + ddl_XRayLF_Name;

                $.ajax({
                    type: "POST",
                    url: "OutPatients.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: test }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        var MainDeptName = JSON.parse(data.d);
                        TestMainDepartmentName = MainDeptName[0].TestMainDepartmentName123;
                        MainDepartmentName = MainDeptName[0].estMainDepartmen;
                        debugger;
                        if (MainDepartmentName == "003") {

                            var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtddlXRayLF_Name" value="' + ddl_XRayLF_Name + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + ddlXRayLF_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a></td></tr>';
                        }
                        else {
                            var row = '<tr><td><input type="hidden" name="testDate" value="' + dateValue + '">' + date + '</td><td><input type="hidden" name="testID" value="' + test + '" /> <input type="hidden" name="txtRotation" value="' + Rotation_ID + '"><input type="hidden" name="txtDeptID" value="' + MainDepartmentName + '"/> ' + TestMainDepartmentName + ', ' + $('#ddlTestList').find('option:selected').text() + ', ' + Rotation_Name + '</td><td>No</td><td>' + Result + '</td> <td> <input type="hidden" name="txtSpecial_Test" value="' + ctl00_MainContent_txtSpecialTests.value + '"/> ' + ctl00_MainContent_txtSpecialTests.value + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + ctl00_MainContent_txtAreaOfInterest.value + '"/> ' + ctl00_MainContent_txtAreaOfInterest.value + ' </td> <td><input type="hidden" name="rowid" value="' + uuid() + '" /><a href="javascript:void(0)" onclick="deleteTest(this)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a></td></tr>';
                        }
                        debugger;
                        var test_array = $('.tests-table').find('input[name=testID][value="' + test + '"]');


                        $('.tests-table').append(row);
                        $('#ddlXRayLF option:selected').val("0");
                        $("#ctl00_MainContent_txtSpecialTests").val("");
                        $("#ctl00_MainContent_txtAreaOfInterest").val("");
                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }



        }
        function AddServiceOrItem() {

            var User_Name = '<%= AppConfig.UserName %>';
            var Item_Id = $('#ctl00_MainContent_txtService').val();
            var entryDate = '<%= DateTime.Now.ToString("MM/dd/yyyy hh:mm:ss tt") %>';
            setTimeout(function () {

                if ($('#ctl00_MainContent_txtService').val() === "")
                    return false;



                var rows = '<tr>' +
                    '<td style="text-align:left;">' + entryDate + '</td>' +
                    '<td style="text-align:left;">' +
                    '<input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" />' +
                    '<input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" />' +
                    '<input type="hidden" name="hdnNet_Amount" value="' + localStorage.SelectedItemAmount + '" />' +
                    '<input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" />' +
                    '<input type="hidden" name="hdnPageType" value="IPD" />' +
                    localStorage.SelectedItemName +
                    '</td>' +
                    '<td style="text-align:left;">' + User_Name + '</td>' +
                    '<td style="text-align: left;">' +
                    '<a href="javascript:void(0)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color:white; padding: 5px 8px;" onclick="DeleteRow(this)">' +
                    '<i class="fa fa-trash" style="color: white !important;"></i>' +
                    '</a>' +
                    '</td>' +
                    '</tr>';


                $('#tblServices tbody').append(rows);
                $('#ctl00_MainContent_txtService').tokenInput('clear');

            }, 300);


        }
        function DeleteRow(anchor) {
            var row = $(anchor).parents('tr')[0];
            row.remove();

        }



        function LoadServices_ProceduresForHistory(PatientId) {
            debugger;
            if ($("#<%= hdfPatient_ID.ClientID%>").val() !== "(New)") {
                $('#ServicesHistoryHeader').html('<h2 class="headingcolr">Loading Previous History Please Wait...</h2>');
                PageMethods.LoadServicesDetailforHistory(PatientId, $('#<%= hdfPatient_ID.ClientID%>').val(), function (response) {
                    var Services = JSON.parse(response);
                    var rows = "";
                    var rowsHistory = "";
                    $.each(Services, function (key, value) {
                        var timeStamp = parseInt(value.ServiceDate.substr(6, 10));
                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        var entryDate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        rowsHistory += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td></tr>';
                    });
                    $('#tblServicesHistory tbody').append(rowsHistory);
                    $("#ServicesHistoryHeader").html("<h2 class='headingcolr'>Previous History</h2>");
                });
            }
        }
        function LoadServices_Procedures() {
            debugger;
            if ($("#<%= hdfPatient_ID.ClientID%>").val() !== "(New)") {
                var patients_id = $('#<%= txtOut_Patient_ID.ClientID %>').val();
                PageMethods.LoadServicesDetails(patients_id, function (response) {
                    var Services = JSON.parse(response);
                    var rows = "";
                    var rowsHistory = "";
                    $.each(Services, function (key, value) {
                        var timeStamp = parseInt(value.ServiceDate.substr(6, 10));

                        var date = moment.unix(timeStamp).format('DD/MM/YYYY hh:mm:ss A');
                        var datearray = date.split("/");
                        var entryDate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        rows += '<tr><td style="text-align:left;">' + entryDate + '</td> <td style="text-align:left;"> <input type="hidden" name="hdnItemID" value="' + value.ServiceItemId + '" /> <input type="hidden" name="hdnItemName" value="' + value.Service_ProcedureName + '" /> <input type="hidden" name="hdnNet_Amount" value="' + value.ServiceItemAmount + '" /> <input type="hidden" name="hdnItemType" value="' + value.ServiceItemType + '" /> <input type="hidden" name="hdnPageType" value="' + value.PatientType + '" />' + value.Service_ProcedureName + '</td><td style="text-align:left;">' + value.UserName + '</td><td style="text-align: left;"> <a  href="#" onclick="DeleteRow(this)" style="border-radius: 4px; background-color: #ad170c; margin-left: 4px; color: white; padding: 5px 8px;"><i class="fa fa-trash"></i></a> </td> </tr>';
                    });
                    $('#tblServices tbody').append(rows);
                });
            }
        }
        function editMedicine(AnchorTag) {
            debugger;
            $('#MedicationModel').modal({
                backdrop: 'static'
            });

            $('#txtMedicineName').val('');
            $('#txtDosage').val('');
            $('#txtRecomended_Dosage').val('');
            $('#txtOral').val('');
            $('#txtInjection').val('');

            $('#btnSaveMedicine').val('Update');
            var row = $(AnchorTag).parents('tr')[0];
            var Medicine_Id = $($(row).find('td')[10]).text();
            var medicine_name = $($(row).find('td')[1]).text().trim();
            var dosage_qty = $($(row).find('td')[7]).text().trim();
            var dosage_form = $($(row).find('td')[6]).text().trim();
            var frequency = $($(row).find('td')[2]).text().trim();
            var routes = $($(row).find('td')[3]).text().trim();
            var duration = $($(row).find('td')[4]).text().trim();
            var special_instruction = $($(row).find('td')[5]).text().trim();
            var other_instruction = $($(row).find('td')[8]).text().trim();
            $('#txtPharmacyItem').val(Medicine_Id).trigger('change');
            $("#ddlDosage_Qty").find('option:contains(' + dosage_qty + ')')[0].selected = true;
            $("#ddlDosage_From").find('option:contains(' + dosage_form + ')')[0].selected = true;
            $("#txtRecomended_Dosage").find('option:contains(' + frequency + ')')[0].selected = true;
            $("#Routes").find('option:contains(' + routes + ')')[0].selected = true;
            $('#ddlOther_Instruction').find('option:contains(' + other_instruction + ')')[0].selected = true;
            $('#txtMedicineName').val($($(row).find('td')[1]).text());
            if (Medicine_Id == '') {
                $('#txtMedicen').show();
                $('#txtMedicen').val($($(row).find('td')[1]).text());

            }
            else {
                $('#txtMedicen').hide();
                $('#txtMedicen').val('');

            }
            $('#txtPharmacyItem').html(
                $('<option>', {
                    value: Medicine_Id,
                    text: medicine_name
                })
            ).attr('disabled', false);
            var durationOption = $('#txtInjection').find('option:contains(' + duration + ')');
            if (durationOption.length > 0) {
                durationOption[0].selected = true;
            } else {
                $('#txtInjection').prop('selectedIndex', 0);
            }

            //$('#txtInjection').val(duration);
            $('#AttendingParamedicalStaff').val(special_instruction);
            $('#MedicationModel input[name=uurowid]').val($(row).find('input[name=uurowid]').val());


        }
        function deleteMedicine(AnchorTag) {

            var row = $(AnchorTag).parents('tr')[0];
            row.remove();
        }

        function SaveMedicinesAndTests() {

            SaveMedicines();
            localStorage.SelectedTabID = $("#tabs").tabs("option", "active");
        }
        function LoadOrtho() {
            if ($('#<%= txtOut_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadOrthoDetail($('#<%= txtOut_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);
                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        rows += '<tr>  <td><input type="hidden" name ="txtDoctorStatus" value="' + value.Organ_Name + '"> ' + value.Organ_Name
                            + ' </td> <td> ' + value.Organ_Side + ' </td> <td> ' + value.Ortho_History + ' </td> <td>' + value.DM + '</td><td> ' + value.Ortho_History + ' </td> <td>' + value.IHD + '</td><td> ' + value.Look + ' </td> <td>' + value.Feel + '</td><td> ' + value.Move + ' </td> <td>' + value.Special_Tests + '</td><td> ' + value.Sensory + ' </td> <td>' + value.Motor + '</td> <td> ' + value.Reflexes + ' </td> <td>' + value.Vascular_Status + '</td> <td> ' + value.Others + ' </td></tr>';
                    });
                    $('#tblOrtho tbody').append(rows);
                });
            }
        }

        function SaveOrtho() {

            var table = $('#tblOrtho');
            var OrthoList = [];
            table.find('tbody tr').each(function (key, value) {

                OrthoList.push({ 'Organ_Name': $($(value).find('td')[0]).text(), 'Organ_Side': $($(value).find('td')[1]).text(), 'Ortho_History': $($(value).find('td')[2]).text(), 'DM': $($(value).find('td')[3]).text(), 'HTN': $($(value).find('td')[4]).text(), 'IHD': $($(value).find('td')[5]).text(), 'Look': $($(value).find('td')[6]).text(), 'Feel': $($(value).find('td')[7]).text(), 'Move': $($(value).find('td')[8]).text(), 'Special_Tests': $($(value).find('td')[9]).text(), 'Sensory': $($(value).find('td')[10]).text(), 'Motor': $($(value).find('td')[11]).text(), 'Reflexes': $($(value).find('td')[12]).text(), 'Vascular_Status': $($(value).find('td')[13]).text(), 'Others': $($(value).find('td')[14]).text() });

            });
            var btnsave = $('#btnSave').val();
            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var OrthoDetails = { Pat: PatID, PatientID: OutPatID, OrthoList: OrthoList }

            PageMethods.SaveOrthoDetail(btnsave, JSON.stringify(OrthoDetails), function (response) {
                SaveProtos();
                saveAllRecord();
                SaveServices_Procedures();
            });

        }



        function SaveServices_Procedures() {
            debugger;
            var table = $("#tblServices");
            var ProcedureList = [];
            var btnSave = $('#btnSave').val();
            table.find("tbody tr").each(function (key, value) {
                ProcedureList.push({
                    'ServiceDate': $($(value).find("td")[0]).text(),
                    'Service_ProcedureName': $($(value).find("td")[1]).text().trim(),
                    "ServiceItemId": $($(value).find("td")[1]).find("input[name=hdnItemID]").val(),
                    "ServiceItemAmount": $($(value).find("td")[1]).find("input[name=hdnNet_Amount]").val(),
                    "ServiceItemType": $($(value).find("td")[1]).find("input[name=hdnItemType]").val(),
                    "PatientType": $($(value).find("td")[1]).find("input[name=hdnPageType]").val(),
                    "UserName": $($(value).find("td")[2]).text()
                });
            });
            var patID = $('#<%= txtPatient_ID.ClientID%>').val();
            var opdid = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            var ServiceDetails = { PatId: patID, opdid: opdid, ServicesList: ProcedureList };
            PageMethods.SaveServicesDetail(btnSave, JSON.stringify(ServiceDetails), function (response) {
                SaveInfusion();
            });
        }






        function SaveMedicines() {
            debugger;
            var table = $('#tblMedicinesList');
            var MedicinesList = [];
            table.find('tbody tr').each(function (key, value) {
                var date = '<%= DateTime.Now%>'
                MedicinesList.push({
                    'Medicine_Date': $(value).find('td input[name=testDate]').val(), 'Medicine_Name': $($(value).find('td')[1]).text(), 'Frequency': $($(value).find('td')[2]).text(), 'Oral': $($(value).find('td')[3]).text(), 'Injection': $($(value).find('td')[4]).text(), 'AttendingParamedical_Staff': $($(value).find('td')[5]).text(),
                    'Dosage_From': $($(value).find('td')[6]).text(), 'Dosage_Qty': $($(value).find('td')[7]).text(), 'Other_Instruction': $($(value).find('td')[8]).text(), 'ItemCode': $($(value).find('td')[10]).text(),
                });

            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();

            var OutPatID = $('#<%= txtOut_Patient_ID.ClientID%>').val();
            if (OutPatID == '(New)' || OutPatID == '')
                OutPatID = 0;
            var MedicineDetails = { Pat: PatID, PatientID: OutPatID, MedicineList: MedicinesList }

            PageMethods.SaveMedicines(JSON.stringify(MedicineDetails), function (response) { saveTests(); });

        }
        function saveTests() {
            var table = $('.tests-table tbody');
            var test_list = [];
            var tbl = document.getElementById('loadtest');
            table.find('tr').each(function (key, value) {
                var rotation = $(value).find('td').eq(1).text();
                var showTestDescription = false;
                if (rotation.includes('X-Ray') || rotation.includes('CT-Scan')) {
                    showTestDescription = true;
                }

                var date = '<%= DateTime.Now%>';
                test_list.push({ 'Date': $(value).find('td input[name=testDate]').val(), 'TestID': $(value).find('td input[name=testID]').val(), 'Catagory_ID': $(value).find('td input[name=txtGroupCategory]').val(), 'Dept_ID': $(value).find('td input[name=txtDeptID]').val(), 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'Special_Tests': $(value).find('td input[name=txtSpecial_Test]').val(), 'Area_Of_Interest': $(value).find('td input[name=txtArea_Of_Interest]').val(), 'rotation': rotation, 'showTestDescription': showTestDescription });

            });

            var PatID = $('#<%= txtPatient_ID.ClientID%>').val();
            var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
            if (patientID == '(New)' || patientID == '')
                patientID = 0;
            var labTest = { 'PatientID': patientID, 'TestList': test_list, 'PatID': PatID };
            PageMethods.SaveTest(JSON.stringify(labTest), function (res) {
                SaveHistoryTab();

            });
        }
        function LoadMedicines() {
            debugger;
            if ($('#<%= txtOut_Patient_ID.ClientID%>').val() != '(New)') {
                PageMethods.LoadMedicines($('#<%= txtOut_Patient_ID.ClientID%>').val(), function (res) {
                    var Medicines = JSON.parse(res);

                    var rows = '';
                    $.each(Medicines, function (key, value) {

                        var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        var datearray = date.split("/");

                        var newdate = datearray[1] + '/' + datearray[0] + '/' + datearray[2];
                        if (value.Oral.trim() == "Select Routes") value.Oral = '';
                        if (value.Dosage_Qty.trim() == "Select") value.Dosage_Qty = '';
                        if (value.Dosage_From.trim() == "Select") value.Dosage_From = '';
                        if (value.Other_Instruction.trim() == "Select") value.Other_Instruction = '';

                        rows += '<tr> <td> <input type="hidden" name="testDate" value="' + date + '">' + newdate + ' </td><td> ' + value.Medicine_Name + ' </td><td>' + value.Frequency + '</td><td> ' + value.Oral + ' </td> <td> ' + value.Injections + ' </td><td> ' + value.AttendingParamedical_Staff + ' </td><td> ' + value.Dosage_From + ' </td><td> ' + value.Dosage_Qty + ' </td><td> ' + value.Other_Instruction + ' </td> <td> <a href="#" onclick="editMedicine(this)"> Edit </a> | <a href="#" onclick="deleteMedicine(this)"> Delete </a> <input type="hidden" name="uurowid" value=' + uuid() + ' />  </td> <td style="display:none;">' + value.Item_Code + '</td> </tr>';
                    });
                    $('#tblMedicinesList tbody').html(rows);
                    debugger

                });

            }

        }
        function PopulateTestList() {
            var options = '';
            PageMethods.GetTests(function (tests) {
                $.each(JSON.parse(tests), function (key, value) {
                    options += '<option value="' + value.Test_ID + '">' + value.Test_Name + '</option>';
                });
                $('#tests-list').html(options);
                $('#tests-list').select2();
            });
        }

        function deleteTest(crow) {
            var row = $(crow).parents('tr')[0];
            row.remove();
        }

        function FillTest() {

            var Grpdpt = $('#groups').val();
            var options;
            PageMethods.FillTestName(Grpdpt, function (departments) {
                $.each(JSON.parse(departments), function (key, value) {

                    options += '<option value="' + value.Test_ID + '"> ' + value.Test_Name + ' </option>';

                });
                $('#groupsCat').empty();
                $('#groupsCat').html(options);
            });
        }





        function LoadPatientCategory() {

            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            if (Patient_ID != '(New)') {
                PageMethods.GetPatient_CategoryByPat(Patient_ID, function (resp) {

                    var options = '';

                    PageMethods.GetPatient_Category(function (Patient_Category) {
                        $.each(JSON.parse(Patient_Category), function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '" ' + (JSON.parse(resp)[0].Patient_Type == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlPatient_Category').html(options);
                    });

                }, function (e) { });
            }
        }

        function loadAjax() {
            debugger;
            $('.se-pre-con').fadeIn();
            $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "none");
            $($('#tabs').find('ul').find('li')[9]).css("pointer-events", "auto");
            LoadPatientCategory();
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            if (Patient_ID != '(New)') {
                localStorage.PatientIDforNewForm = Patient_ID;
                $.ajax({
                    type: "POST",
                    url: "OutPatients.aspx/GetDetail",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess,
                    failure: function (response) {

                    }
                });
            }



        }
        function OnSuccess(data) {
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#<%= vlblPatients_Name.ClientID %>').text(ReplaceNullWith_Space(data.d.Name));
                $('#<%= vLbl_Age.ClientID %>').text(ReplaceNullWith_Space(data.d.Age));
                $('#<%= vLbl_Gender.ClientID %>').text(ReplaceNullWith_Space(data.d.Gender));
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(ReplaceNullWith_Space(data.d.Address));
                $('#<%= vLbl_Contact.ClientID %>').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#<%= lblDpt.ClientID %>').text(ReplaceNullWith_Space(data.d.department));
                $('#<%= lblFollow.ClientID %>').text(ReplaceNullWith_Space(data.d.Follow));
                $('#<%= lblPatient_Category.ClientID %>').text(ReplaceNullWith_Space(data.d.Patient_type));
                $('#<%= lblDoc.ClientID %>').text(ReplaceNullWith_Space(data.d.dotorname));
                <%--$('#<%= lblDoc.ClientID %>').text(ReplaceNullWith_Space(data.d.doctor));--%>
                setTimeout(function () {

                    $($('#tabs').find('ul').find('li')[1]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[2]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[3]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[4]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[5]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[6]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[7]).css("pointer-events", "auto");
                    $($('#tabs').find('ul').find('li')[8]).css("pointer-events", "auto");
                }, 1000);

            }
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }

        function httpGet(theUrl) {

            var xmlHttp = null;

            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function On_Sypyum_Success() {

            LoadTokenInputForSymtoms();
        }
        function SymptomInsert() {

            var syptum = $('#txtNewSymptom').val();
            PageMethods.SyptumNew(syptum, On_Sypyum_Success);
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'New Symtom Save Successfully',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
        }
        function new_value() {

            $('#txtNewSymptom').show();
            var syptum = $('#txtNewSymptom').val();
            if (syptum != "") {
            }
        }

        function NewMedicine() {
            $('#txtPharmacyItem').val(0).trigger('change');
            $('#txtMedicen').show();
            var medicine = $('#txtMedicen').val();
            if (medicine != "") {
                $('#txtMedicen').hide();
                $('#txtMedicen').val("");

            }
        }
        function On_Success() {
            FillMedicine();
        }
        function MedicenInsert() {

            var medicine = $('#txtMedicen').val();
            PageMethods.GeMedicineNew(medicine, On_Success);
        }

        function ClearAllTable() {

            window.location.href = 'OutPatients.aspx';
            localStorage.PatientIDforNewForm = $('#<%= hdfPatient_ID.ClientID%>').val();
            var Patient_ID = localStorage.PatientIDforNewForm;
            var tokendata = httpGet("../../json.aspx?Table=OutPatients&Patient_ID=" + Patient_ID);
            var tokendatas = httpGet("../../json.aspx?Table=OutPatients_MrNo&Patient_ID=" + Patient_ID);
            loadtokenInputsByMrNo(JSON.parse(tokendatas));
            loadtokenInputs(JSON.parse(tokendata));

        }
        function onAjaxFailed(error) {
            if ($.isNumeric(error)) {
                window.location = "OutPatients.aspx?ID=" + error;
            }
            else {
                alert(error);
            }
        }

        function saveAllRecord() {
            debugger;
            var Patient_ID = $("#<%= hdfPatient_ID.ClientID %>").val();
            var reg_ID = $("#<%= hdfReg_ID.ClientID %>").val();
            var Administration = $('#ctl00_MainContent_ddlIssuance_Of').val();
            if (Administration == 0)
                Administration = "";
            var Out_Patient_ID = $('#ctl00_MainContent_txtOut_Patient_ID').val();
            if (Out_Patient_ID == "(New)")
                Out_Patient_ID = "";


            var interrior = [];
            var posterior = [];

            var rightData = $('#txtInteriorRight0').val() || "";
            var leftData = $('#txtInteriorLeft0').val() || "";
            interrior.push([rightData, leftData]);

            rightData = $('#txtPosteriorRight0').val() || "";
            leftData = $('#txtPosteriorLeft0').val() || "";
            posterior.push([rightData, leftData]);

            var eyeInfo = [];

            for (var i = 0; i < 5; i++) {
                var infoType = $('#lblEye' + i).text().trim();
                var rightData = $('#txtRightEye' + i).val() || "";
                var leftData = $('#txtLeftEye' + i).val() || "";

                eyeInfo.push({
                    Info_Type: infoType.toUpperCase(),
                    Right_Eye: rightData,
                    Left_Eye: leftData
                });
            }



            var data = {
                Patient_ID: Patient_ID,
                reg_ID: reg_ID,
                 btnsave : $('#btnSave').val(),
                 btnsaveVital : $('#btnSave_Vital').val(),
                 Discharged : document.getElementById("ctl00_MainContent_CheckBox1").checked,
                 No_Medicine : document.getElementById("ctl00_MainContent_chkNo_Medicine").checked,
                 No_LabTest : document.getElementById("ctl00_MainContent_chkNo_Test").checked,
                 Doctor_ID : $('#ctl00_MainContent_ddlDoctorName option:selected').val(),
                 Follow_Up : $('#ctl00_MainContent_ddlFOllowUp').val(),
                 Proto : $('#ctl00_MainContent_ddlProto').val(),
                 Follow_Date : $('#ctl00_MainContent_FollowNoDate').val(),
                 pulse_Min : $('#ctl00_MainContent_txtPuls').val(),
                 L_M_P : $('#ctl00_MainContent_txtLMP').val(),
                 SPO2 : $('#ctl00_MainContent_txtspo2').val(),
                 pulse_Min : $('#ctl00_MainContent_txtPuls').val(),
                 L_M_P : $('#ctl00_MainContent_txtLMP').val(),
                 SPO2 : $('#ctl00_MainContent_txtspo2').val(),
                 BP_mm_Hg : $('#ctl00_MainContent_txtBP').val(),
                 MUAC : $('#ctl00_MainContent_txtMUAC').val(),
                 OFC : $('#ctl00_MainContent_txtOFC').val(),
                 Temp_C : $('#ctl00_MainContent_txtTemp').val(),
                 Respiration_Min : $('#ctl00_MainContent_txtRespiration').val(),
                 Height_Cm : $('#ctl00_MainContent_txtHeight').val(),
                 Weight_Kg : $('#ctl00_MainContent_txtWeight').val(),
                 Refer_To_Hospital : $('#ctl00_MainContent_txtRefer_To_Hospital').val(),
                Reffer_To: $('#ctl00_MainContent_ddlPatient_Main_Category').val(),
                Reffer_doc: $('#ddldoctors').val() || "",
                 Provisional_Diagnosis : $('#ctl00_MainContent_txtProvisionalDiagnosis').val(),
                 HistoryOfPeresentIllness : $('#ctl00_MainContent_txtHistoryOfPeresentIllness').val(),
                 HistoryOfFamily : $('#ctl00_MainContent_txtHistoryOfFamily').val(),
                 HistoryOfPastIllness : $('#ctl00_MainContent_txtHistoryOfPastIllness').val(),
                 CVS : $('#ctl00_MainContent_txtCVS').val(),
                 GIT : $('#ctl00_MainContent_txtGIT').val(),
                 RESP : $('#ctl00_MainContent_txtRESP').val(),
                 SocioEconomicHistory : $('#ctl00_MainContent_txtSocioEconomicHistory').val(),
                 CNS : $('#ctl00_MainContent_txtCNS').val(),
                 GYNAE : $('#ctl00_MainContent_txtGYNAE').val(),
                 Mucculor : $('#ctl00_MainContent_txtMucculor').val(),
                 Local : $('#ctl00_MainContent_txtLocal').val(),
                 Advice : $('#ctl00_MainContent_txtAdvice').val(),
                 Special_Test : $('#ctl00_MainContent_txtSpecialTests').val(),
                 Area_Of_Interest : $('#ctl00_MainContent_txtAreaOfInterest').val(),
                 Birth_History : $('#ctl00_MainContent_txtBirthHistory').val(),
                 Reffer_No : $('#ctl00_MainContent_txtRefferNote').val(),
                 Drug_History : $('#ctl00_MainContent_txtDrugHistory').val(),
                 Personal_History : $('#ctl00_MainContent_txtPersonalHistory').val(),
                 txtRemarksHistory : $('#ctl00_MainContent_txtRemarksHistory').val(),
                 ObstetricHistory : $('#ctl00_MainContent_txtObstetricHistory').val(),
                 AllergiesHistory : $('#ctl00_MainContent_txtAllergiesHistory').val(),
                 TreatmentHistory : $('#ctl00_MainContent_txtTreatmentHistory').val(),
                 DevelopmentHistory : $('#ctl00_MainContent_txtDevelopmentHistory').val(),
                 VaccinationHistory : $('#ctl00_MainContent_txtVaccinationHistory').val(),
                NutritionHistory: $('#ctl00_MainContent_txtNutritionHistory').val(),


                 chkPallor : document.getElementById("ctl00_MainContent_chkPallor").checked,
                 chkJVP : document.getElementById("ctl00_MainContent_chkJVP").checked,
                 chkaganoris : document.getElementById("ctl00_MainContent_chkaganoris").checked,
                 chkunconceed : document.getElementById("ctl00_MainContent_chkunconceed").checked,
                 chkjaundice : document.getElementById("ctl00_MainContent_chkjaundice").checked,
                 hydration : document.getElementById("ctl00_MainContent_hydration").checked,
                 edema : document.getElementById("ctl00_MainContent_edema").checked,
                 chk1 : document.getElementById("ctl00_MainContent_chk1").checked,
                 chk2 : document.getElementById("ctl00_MainContent_chk2").checked,
                 chk3 : document.getElementById("ctl00_MainContent_chk3").checked,
                 chk4 : document.getElementById("ctl00_MainContent_ns").checked,
                 chk5 : document.getElementById("ctl00_MainContent_sl").checked,
                 Other : $('#ctl00_MainContent_txtInputBox1').val(),
                 Designation : $('#ctl00_MainContent_txtDesignation').val(),
                 FinalDiagnosis : $('#ctl00_MainContent_txtFinalDiagnosis').val(),
                 Final_Rec : $("#ctl00_MainContent_Final_Rec").val(),
                Administration: Administration,
                ENT_Throat_IDL: $('#ctl00_MainContent_txtmidl').val() || "",
                ENT_Throat_Nose: $('#ctl00_MainContent_txtmNose').val() || "",
                ENT_Ear_Right: $('#ctl00_MainContent_txtmRight').val() || "",
                Ent_Ear_Left: $('#ctl00_MainContent_txtmLeft').val() || "",
                ComRightPos: $('#ctl00_MainContent_ComRightPos').val() || "",
                ComLeftPos: $('#ctl00_MainContent_ComLeftPos').val() || "",
                ComRightNeg: $('#ctl00_MainContent_ComRightNeg').val() || "",
                ComLeftNeg: $('#ctl00_MainContent_ComLeftNeg').val() || "",
                ComRightF: $('#ctl00_MainContent_ComRightF').val() || "",
                ComLeftF: $('#ctl00_MainContent_ComLeftF').val() || "",
                ComRightFNeg: $('#ctl00_MainContent_ComRightFNeg').val() || "",
                ComLeftFNeg: $('#ctl00_MainContent_ComLeftFNeg').val() || "",
                ComCentral: $('#ctl00_MainContent_ComCentral').val() || "",
                ComLateralized: $('#ctl00_MainContent_ComLateralized').val() || "",
                ComPTA: $('#ctl00_MainContent_ComPTA').val() || "",
                ComTympanometry: $('#ctl00_MainContent_ComTympanometry').val() || "",
                ENT_Rinnes_Right_PosNeg : document.getElementById('ctl00_MainContent_mchkRightPos').checked,
                ENT_Rinnes_Lft_PosNeg : document.getElementById('ctl00_MainContent_mchkLeftPos').checked,
                ENT_Rinnes_Right_FalseNeg : document.getElementById('ctl00_MainContent_mchkRightF').checked,
                ENT_Rinnes_Lft_FalseNeg : document.getElementById('ctl00_MainContent_mchkLeftF').checked,
                ENT_Webber_Central : document.getElementById('ctl00_MainContent_mchkcentral').checked,
                ENT_Webber_Lateralized : document.getElementById('ctl00_MainContent_mchkLateralized').checked,
                ENT_Investigation_PTA : document.getElementById('ctl00_MainContent_mchkPTA').checked,
                ENT_Investigation_Tympanometry : document.getElementById('ctl00_MainContent_mchkTympanometry').checked,
                ENT_Rinnes_Right_Neg : document.getElementById('ctl00_MainContent_mchkRightNeg').checked,
                ENT_Rinnes_Lft_Neg : document.getElementById('ctl00_MainContent_mchkLeftNeg').checked,
                ENT_Rinnes_Right_FNeg : document.getElementById('ctl00_MainContent_mchkRightFNeg').checked,
                ENT_Rinnes_Lft_FNeg : document.getElementById('ctl00_MainContent_mchkLeftFNeg').checked,
                txtInformant : $('#ctl00_MainContent_txtInformant').val(),
                txtSourceOfReferral : $('#ctl00_MainContent_txtSourceOfReferral').val(),
                chkNeckHolding : document.getElementById("ctl00_MainContent_chkNeckHolding").checked,
                chkWalking : document.getElementById('ctl00_MainContent_chkWalking').checked,
                chkTalking : document.getElementById('ctl00_MainContent_chkTalking').checked,
                chkOthers : document.getElementById('ctl00_MainContent_chkOthers').checked,
                txtMenarche : $('#ctl00_MainContent_txtMenarche').val(),
                txtMenstrual : $('#ctl00_MainContent_txtMenstrual').val(),
                txtAttachmentSeparationfromParents : $('#ctl00_MainContent_txtAttachmentSeparationfromParents').val(),
                txtHealth : $('#ctl00_MainContent_txtHealth').val(),
                chkNailBiting : document.getElementById('ctl00_MainContent_chkNailBiting').checked,
                chkTemperTantrums : document.getElementById('ctl00_MainContent_chkTemperTantrums').checked,
                chkBedWetting : document.getElementById('ctl00_MainContent_chkBedWetting').checked,
                txtAcademics : $('#ctl00_MainContent_txtAcademics').val(),
                txtPeerRelationship : $('#ctl00_MainContent_txtPeerRelationship').val(),
                txtBehaviour : $('#ctl00_MainContent_txtBehaviour').val(),
                txtOccupationalHistory : $('#ctl00_MainContent_txtOccupationalHistory').val(),
                txtMaritalRelationshipSexualHistory : $('#ctl00_MainContent_txtMaritalRelationshipSexualHistory').val(),
                txtSubstanceUse : $('#ctl00_MainContent_txtSubstanceUse').val(),
                txtForensicUse : $('#ctl00_MainContent_txtForensicUse').val(),
                txtRelationship : $('#ctl00_MainContent_txtRelationship').val(),
                txtLeisureActivities : $('#ctl00_MainContent_txtLeisureActivities').val(),
                txtAttitudetoSelfandStandards : $('#ctl00_MainContent_txtAttitudetoSelfandStandards').val(),
                txtPrevallingMood : $('#ctl00_MainContent_txtPrevallingMood').val(),
                txtReactionPattrentoStress : $('#ctl00_MainContent_txtReactionPattrentoStress').val(),
                txtReligiousPracticesAttitute : $('#ctl00_MainContent_txtReligiousPracticesAttitute').val(),
                txtFather : $('#ctl00_MainContent_txtFather').val(),
                txtMother : $('#ctl00_MainContent_txtMother').val(),
                txtSiblings: $('#ctl00_MainContent_txtSiblings').val(),

                txtHomeAtmosphererelationshipsocialclass : $('#ctl00_MainContent_txtHomeAtmosphererelationshipsocialclass').val(),
                txtFamilialIllness : $('#ctl00_MainContent_txtFamilialIllness').val(),
                txtActualandapparentage : $('#ctl00_MainContent_txtActualandapparentage').val(),
                txtRace : $('#ctl00_MainContent_txtRace').val(),
                txtTattoosbodypiercingandscars : $('#ctl00_MainContent_txtTattoosbodypiercingandscars').val(),
                txtBodyHabitus : $('#ctl00_MainContent_txtBodyHabitus').val(),
                txtDress : $('#ctl00_MainContent_txtDress').val(),
                txtHygiene : $('#ctl00_MainContent_txtHygiene').val(),
                txtPsychomotorActivity : $('#ctl00_MainContent_txtPsychomotorActivity').val(),
                txtInvoluntarymovements : $('#ctl00_MainContent_txtInvoluntarymovements').val(),
                txtDystoniaEPS : $('#ctl00_MainContent_txtDystoniaEPS').val(),
                txtTardivedyskinesia : $('#ctl00_MainContent_txtTardivedyskinesia').val(),
                txtTics : $('#ctl00_MainContent_txtTics').val(),
                txtTremors : $('#ctl00_MainContent_txtTremors').val(),
                txtAttentivenesstointerview : $('#ctl00_MainContent_txtAttentivenesstointerview').val(),
                txtEyeContact : $('#ctl00_MainContent_txtEyeContact').val(),
                txtLevelofConsciousness : $('#ctl00_MainContent_txtLevelofConsciousness').val(),
                txtRate : $('#ctl00_MainContent_txtRate').val(),
                txtRhythm : $('#ctl00_MainContent_txtRhythm').val(),
                txtVolume : $('#ctl00_MainContent_txtVolume').val(),
                txtTone : $('#ctl00_MainContent_txtTone').val(),
                txtModulation: $('#ctl00_MainContent_txtModulationvar').val(),
                txtDepressed : $('#ctl00_MainContent_txtDepressed').val(),
                txtElated : $('#ctl00_MainContent_txtElated').val(),
                txtIrritable : $('#ctl00_MainContent_txtIrritable').val(),
                txtLabile : $('#ctl00_MainContent_txtLabile').val(),
                txtIncongruent : $('#ctl00_MainContent_txtIncongruent').val(),
                txtbluntingflatteningapathy : $('#ctl00_MainContent_txtBluntingFlatteningApathy').val(),
                txtThinkingPremeditation : $('#ctl00_MainContent_txtThinkingPremeditation').val(),
                txtPlans : $('#ctl00_MainContent_txtPlans').val(),
                txtNextPlan : $('#ctl00_MainContent_txtNextPlan').val(),
                txtActions : $('#ctl00_MainContent_txtActions').val(),
                txtPreservative : $('#ctl00_MainContent_txtPreservative').val(),
                txtLoosAssociation : $('#ctl00_MainContent_txtLoosAssociation').val(),
                txtTangentiaility : $('#ctl00_MainContent_txtTangentiaility').val(),
                txtCircumstantiality : $('#ctl00_MainContent_txtCircumstantiality').val(),
                txtFlightofIdeas : $('#ctl00_MainContent_txtFlightofIdeas').val(),
                txtThoughtInsertion : $('#ctl00_MainContent_txtThoughtInsertion').val(),
                txtThoughtWithdrawal : $('#ctl00_MainContent_txtThoughtWithdrawal').val(),
                txtThoughBroadcasting : $('#ctl00_MainContent_txtThoughBroadcasting').val(),
                txtThoughControl : $('#ctl00_MainContent_txtThoughControl').val(),
                txtDellusion : $('#ctl00_MainContent_txtDellusion').val(),
                txtovervaluedideas : $('#ctl00_MainContent_txtovervaluedideas').val(),
                txtDepresonalization : $('#ctl00_MainContent_txtDepresonalization').val(),
                txtDerealization : $('#ctl00_MainContent_txtDerealization').val(),
                txtthrougObsession : $('#ctl00_MainContent_txtthrougObsession').val(),
                txtthrougPhobies : $('#ctl00_MainContent_txtthrougPhobies').val(),
                txtthrougHomocidialIdeas : $('#ctl00_MainContent_txtthrougHomocidialIdeas').val(),
                txtillusion : $('#ctl00_MainContent_txtillusion').val(),
                txtHallucinationAuditoryVisualOlfactoryGustatoryTactile : $('#ctl00_MainContent_txtHallucinationAuditoryVisualOlfactoryGustatoryTactile').val(),
                txtorientationtime : $('#ctl00_MainContent_txtorientationtime').val(),
                txtplace : $('#ctl00_MainContent_txtplace').val(),
                txtperson : $('#ctl00_MainContent_txtperson').val(),
                txtAttentionConcentrationSerial7Test : $('#ctl00_MainContent_txtAttentionConcentrationSerial7Test').val(),
                txtOrDaysOfWeekReverseOrder : $('#ctl00_MainContent_txtOrDaysOfWeekReverseOrder').val(),
                txtImmediatememory : $('#ctl00_MainContent_txtImmediatememory').val(),
                txtshorttermrecentevents : $('#ctl00_MainContent_txtshorttermrecentevents').val(),
                txtadressrecallafter2minutes : $('#ctl00_MainContent_txtadressrecallafter2minutes').val(),
                txtlongtermremoteevents : $('#ctl00_MainContent_longtermremoteevents').val(),
                txtadressrecallafter5minues : $('#ctl00_MainContent_txtadressrecallafter5minues').val(),
                txtgeneralknowledgequestion : $('#ctl00_MainContent_txtgeneralknowledgequestion').val(),
                txtsimplearthemeticcalculation : $('#ctl00_MainContent_txtsimplearthemeticcalculation').val(),
                txtabstrationconcertethinking : $('#ctl00_MainContent_txtabstrationconcertethinking').val(),
                txtinsight: $('#ctl00_MainContent_txtinsight').val(),
                DermaFace: $('#ctl00_MainContent_txtDermaFace').val() || "",
                DermaNeck: $('#ctl00_MainContent_txtDermaNeck').val() || "",
                DermaTrunk: $('#ctl00_MainContent_txtDermaTrunk').val() || "",
                DermaUpperLimb: $('#ctl00_MainContent_txtDermaUpperLimb').val() || "",
                DermaLowerLimb: $('#ctl00_MainContent_txtDermaLowerLimb').val() || "",
                DermaFlexures: $('#ctl00_MainContent_txtDermaFlexures').val() || "",
                DermaGenitalias: $('#ctl00_MainContent_txtDermaGenitalias').val() || "",
                DermaHair: $('#ctl00_MainContent_txtDermaHair').val() || "",
                DermaNail: $('#ctl00_MainContent_txtDermaNail').val() || "",
                DermaMucousMembrane: $('#ctl00_MainContent_txtDermaMucousMembrane').val() || "",
                DermaEyes: $('#ctl00_MainContent_txtDermaEyes').val() || "",
                DermaEars: $('#ctl00_MainContent_txtDermaEars').val() || "",
                DermaNose: $('#ctl00_MainContent_txtDermaNose').val() || "",
                DermaLips: $('#ctl00_MainContent_txtDermaLips').val() || "",
                Out_Patient_ID: Out_Patient_ID,

                Interior_Right: interrior[0][0],
                Interior_Left: interrior[0][1],
                Posterior_Right: posterior[0][0],
                Posterior_Left: posterior[0][1],
                PE_Pluse : $('#ctl00_MainContent_txtPE_Pluse').val(),
                PE_BP : $('#ctl00_MainContent_txtPE_BP').val(),
                PE_Temperature : $('#ctl00_MainContent_txtPE_Temperature').val(),
                PE_Weight : $('#ctl00_MainContent_txtPE_Weight').val(),
                PE_RespiratoryRate : $('#ctl00_MainContent_txtPE_RespiratoryRate').val(),
                PE_Jaundice : $('#ctl00_MainContent_txtPE_Jaundice').val(),
                PE_Anemia : $('#ctl00_MainContent_txtPE_Anemia').val(),
                PE_Cyanosis : $('#ctl00_MainContent_txtPE_Cyanosis').val(),
                PE_Clubbing : $('#ctl00_MainContent_txtPE_Clubbing').val(),
                PE_JVP : $('#ctl00_MainContent_txtPE_JVP').val(),
                PE_LymphNodes : $('#ctl00_MainContent_txtPE_LymphNodes').val(),
                PE_Edema : $('#ctl00_MainContent_txtPE_Edema').val(),
                PE_Respiratory : $('#ctl00_MainContent_txtPE_Respiratory').val(),
                PE_Cardiovascular : $('#ctl00_MainContent_txtPE_Cardiovascular').val(),
                PE_Gastro_Intestinal : $('#ctl00_MainContent_txtPE_Gastro_Intestinal').val(),
                PE_Observation : $('#ctl00_MainContent_txtPE_Observation').val(),
                PE_Cranial_Nerves : $('#ctl00_MainContent_txtPE_Cranial_Nerves').val(),
                PE_Limb_Strength : $('#ctl00_MainContent_txtPE_Limb_Strength').val(),
                PE_Spasticity : $('#ctl00_MainContent_txtPE_Spasticity').val(),
                PE_Position : $('#ctl00_MainContent_txtPE_Position').val(),
                PE_Vibration : $('#ctl00_MainContent_txtPE_Vibration').val(),
                PE_Stereognosis : $('#ctl00_MainContent_txtPE_Stereognosis').val(),
                PE_Pain : $('#ctl00_MainContent_txtPE_Pain').val(),
                PE_Biceps : $('#ctl00_MainContent_txtPE_Biceps').val(),
                PE_Triceps : $('#ctl00_MainContent_txtPE_Triceps').val(),
                PE_Brachioradialis : $('#ctl00_MainContent_txtPE_Brachioradialis').val(),
                PE_Quadriceps : $('#ctl00_MainContent_txtPE_Quadriceps').val(),
                PE_Patellar : $('#ctl00_MainContent_txtPE_Patellar').val(),
                PE_Achilles : $('#ctl00_MainContent_txtPE_Achilles').val(),
                PE_Extensor : $('#ctl00_MainContent_txtPE_Extensor').val(),
                PE_Frontal : $('#ctl00_MainContent_txtPE_Frontal').val(),
                PE_Finger : $('#ctl00_MainContent_txtPE_Finger').val(),
                PE_Heel : $('#ctl00_MainContent_txtPE_Heel').val(),
                PE_Movements : $('#ctl00_MainContent_txtPE_Movements').val(),
                PE_Gait : $('#ctl00_MainContent_txtPE_Gait').val(),
                HBM_Problem : $('#ctl00_MainContent_txtHBM_Problem').val(),
                HBM_Caused : $('#ctl00_MainContent_txtHBM_Caused').val(),
                HBM_Started : $('#ctl00_MainContent_txtHBM_Started').val(),
                HBM_Course : $('#ctl00_MainContent_txtHBM_Course').val(),
                HBM_Treatment : $('#ctl00_MainContent_txtHBM_Treatment').val(),
                HBM_Effects : $('#ctl00_MainContent_txtHBM_Effects').val(),
                PE_Neck_Rigidity : document.getElementById('ctl00_MainContent_chkPE_Neck_Rigidity').checked,
                PE_Kerning_Sign : document.getElementById('ctl00_MainContent_chkPE_Kerning_Sign').checked,
                PE_Brudzinki_Sign : document.getElementById('ctl00_MainContent_chkPE_Brudzinki_Sign').checked,
                For_Summary : $('#ctl00_MainContent_txtFor_Summary').val(),
                For_Diagnosis : $('#ctl00_MainContent_txtFor_Diagnosis').val(),
                For_AxisI : $('#ctl00_MainContent_txtFor_AxisI').val(),
                For_AxisII : $('#ctl00_MainContent_txtFor_AxisII').val(),
                For_AxisIII : $('#ctl00_MainContent_txtFor_AxisIII').val(),
                For_AxisIV : $('#ctl00_MainContent_txtFor_AxisIV').val(),
                For_AxisV : $('#ctl00_MainContent_txtFor_AxisV').val(),
                For_PredisposingFactors : $('#ctl00_MainContent_txtFor_PredisposingFactors').val(),
                For_PrecipitatingFactors : $('#ctl00_MainContent_txtFor_PrecipitatingFactors').val(),
                For_PrepetuatingFactors : $('#ctl00_MainContent_txtFor_PrepetuatingFactors').val(),
                For_Investigation : $('#ctl00_MainContent_txtFor_Investigation').val(),
                For_Medical : $('#ctl00_MainContent_txtFor_Medical').val(),
                For_Psychological : $('#ctl00_MainContent_txtFor_Psychological').val(),
                For_Major_Issues : $('#ctl00_MainContent_txtFor_Major_Issues').val(),
                For_Strengths : $('#ctl00_MainContent_txtFor_Strengths').val(),
                For_Goals : $('#ctl00_MainContent_txtFor_Goals').val(),
                For_Strategies : $('#ctl00_MainContent_txtFor_Strategies').val(),
                Heptomology : $("#ctl00_MainContent_txtHeptomogy").val(),
                Splenomegaly : $("#ctl00_MainContent_txtsplenomegaly").val(),
                txtPeads_weight : $('#ctl00_MainContent_txtPeads_weight').val(),
                txtPeads_Length : $('#ctl00_MainContent_txtPeads_Length').val(),
                txtPeads_HC : $('#ctl00_MainContent_txtPeads_HC').val(),
                txtPeads_General_Appearance: $('#ctl00_MainContent_txtPeads_General_Appearance').val(),


                chkPeads_Cyanosis : document.getElementById('ctl00_MainContent_chkPeads_Cyanosis').checked,
                chkPeads_Jaundice : document.getElementById('ctl00_MainContent_chkPeads_Jaundice').checked,
                chkPeads_Lethargy : document.getElementById('ctl00_MainContent_chkPeads_Rash').checked,
                chkPeads_Rash : document.getElementById('ctl00_MainContent_chkPeads_Rash').checked,
                txtPeads_Others : $('#ctl00_MainContent_txtPeads_Others').val(),
                chkPeads_Caput : document.getElementById('ctl00_MainContent_chkPeads_Caput').checked,
                chkPeads_Cephalhematoma : document.getElementById('ctl00_MainContent_chkPeads_Cephalhematoma').checked,
                rdbPeads_Anterioropen : document.getElementById('ctl00_MainContent_rdbPeads_Anterioropen').checked,
                rdbPeads_AnteriorClose : document.getElementById('ctl00_MainContent_rdbPeads_AnteriorClose').checked,
                chkPeads_Dextrocardia : document.getElementById('ctl00_MainContent_chkPeads_Dextrocardia').checked,
                chkPeads_Bulging : document.getElementById('ctl00_MainContent_chkPeads_Bulging').checked,
                chkPeads_Murmur : document.getElementById('ctl00_MainContent_chkPeads_Murmur').checked,
                txtPeads_HeartSound : $('#ctl00_MainContent_txtPeads_HeartSound').val(),
                chkPeads_Nasal : document.getElementById('ctl00_MainContent_chkPeads_Nasal').checked,
                chkPeads_Recessions : document.getElementById('ctl00_MainContent_chkPeads_Recessions').checked,
                txtPeads_AddedSounds : $('#ctl00_MainContent_txtPeads_AddedSounds').val(),
                rdbPeads_Flat : document.getElementById('ctl00_MainContent_rdbPeads_Flat').checked,
                rdbPeads_Distended : document.getElementById('ctl00_MainContent_rdbPeads_Distended').checked,
                rdbPeads_Scaphoid : document.getElementById('ctl00_MainContent_rdbPeads_Scaphoid').checked,
                chkPeads_Liver : document.getElementById('ctl00_MainContent_chkPeads_Liver').checked,
                chkPeads_Spleen : document.getElementById('ctl00_MainContent_chkPeads_Spleen').checked,
                txtPeads_GITOthers : $('#ctl00_MainContent_txtPeads_GITOthers').val(),
                chkPeads_Sucking : document.getElementById('ctl00_MainContent_chkPeads_Sucking').checked,
                chkPeads_Rooting : document.getElementById('ctl00_MainContent_chkPeads_Rooting').checked,
                chkPeads_Moro : document.getElementById('ctl00_MainContent_chkPeads_Moro').checked,
                txtPeads_CNSOthers : $('#ctl00_MainContent_txtPeads_CNSOthers').val(),
                chkPeads_FullTerm : document.getElementById('ctl00_MainContent_chkPeads_FullTerm').checked,
                chkPeads_PreTerm : document.getElementById('ctl00_MainContent_chkPeads_PreTerm').checked,
                txtPeads_DateOfDelivery : $('#ctl00_MainContent_txtPeads_DateOfDelivery').val(),
                txtPeads_TimeOfDelivery : $('#ctl00_MainContent_txtPeads_TimeOfDelivery').val(),
                rdbPeads_Booked : document.getElementById('ctl00_MainContent_rdbPeads_Booked').checked,
                rdbPeads_UnBooked : document.getElementById('ctl00_MainContent_rdbPeads_UnBooked').checked,
                chkPeads_DAIHandling : document.getElementById('ctl00_MainContent_chkPeads_DAIHandling').checked,
                chkPeads_ANTURash : document.getElementById('ctl00_MainContent_chkPeads_ANTURash').checked,
                chkPeads_PIH : document.getElementById('ctl00_MainContent_chkPeads_PIH').checked,
                chkPeads_GDM : document.getElementById('ctl00_MainContent_chkPeads_GDM').checked,
                chkPeads_Vacinated : document.getElementById('ctl00_MainContent_chkPeads_Vacinated').checked,
                txtPeads_ANTOthers : $('#ctl00_MainContent_txtPeads_ANTOthers').val(),
                rdbPeads_SVD : document.getElementById('ctl00_MainContent_rdbPeads_SVD').checked,
                rdbPeads_LSCS : document.getElementById('ctl00_MainContent_rdbPeads_LSCS').checked,
                rdbPeads_Emergency : document.getElementById('ctl00_MainContent_rdbPeads_Emergency').checked,
                rdbPeads_Elective : document.getElementById('ctl00_MainContent_rdbPeads_Elective').checked,
                txtPeads_PlaceOfDelivery : $('#ctl00_MainContent_txtPeads_PlaceOfDelivery').val(),
                txtPeads_IndicationForLSCS : $('#ctl00_MainContent_txtPeads_IndicationForLSCS').val(),
                chkPeads_Resuscitation : document.getElementById('ctl00_MainContent_chkPeads_Resuscitation').checked,
                txtPeads_NatalOthers : $('#ctl00_MainContent_txtPeads_NatalOthers').val(),
                chkPeads_Moaning : document.getElementById('ctl00_MainContent_chkPeads_Moaning').checked,
                chkPeads_RespDistress : document.getElementById('ctl00_MainContent_chkPeads_RespDistress').checked,
                chkPeads_PostNATALCyanosis : document.getElementById('ctl00_MainContent_chkPeads_PostNATALCyanosis').checked,
                chkPeads_Fits : document.getElementById('ctl00_MainContent_chkPeads_Fits').checked,
                chkPeads_ReluctanceToFeed: document.getElementById('ctl00_MainContent_chkPeads_ReluctanceToFeed').checked,


                txtPeads_PostNatalOthers : $('#ctl00_MainContent_txtPeads_PostNatalOthers').val(),
                Edd : $('#ctl00_MainContent_txtedd').val(),
                Bsr : $('#ctl00_MainContent_TxtBSR').val(),
                Bmi : $('#ctl00_MainContent_txtBMI').val(),
                URG : $("#ctl00_MainContent_txtUGS").val(),
                chkdre : document.getElementById('ctl00_MainContent_chkDRE').checked,
                chkProctoscopy : document.getElementById('ctl00_MainContent_chkProctoscopy').checked,
                Abdominal : $("#ctl00_MainContent_txtAbdomin").val(),
                Pa_gynae : $("#ctl00_MainContent_txtPA_Gynae").val(),
                ps_gynae : $("#ctl00_MainContent_txtPS_Gynae").val(),
                uterus : $("#ctl00_MainContent_txtUterus").val(),
                ps_obs : $("#ctl00_MainContent_txtPS_OBS").val(),
                pv_obs : $("#ctl00_MainContent_txtPV").val(),
                fx : $("#ctl00_MainContent_txtFX").val(),
                sfh : $("#ctl00_MainContent_txtSFH").val(),
                lie : $("#ctl00_MainContent_txtLIE").val(),
                presentation : $("#ctl00_MainContent_txtPresentation").val(),
                fhr : $("#ctl00_MainContent_txtFHR").val(),
                engagement : $("#ctl00_MainContent_txtEngagement").val(),
                Peads_apgerScore1min: $('#ctl00_MainContent_ddlPeads_apgerScore1min').val() || "",
                Peads_apgerScore5min: $('#ctl00_MainContent_ddlPeads_apgerScore5min').val() || "",
                Verbal_Consent : $('#ctl00_MainContent_ddlverbal_consent').val(),
            }
            
          
            $.ajax({
                type: "POST",
                url: "OutPatients.aspx/SaveRecord",
                data: JSON.stringify({ data : data ,eyeInfos: eyeInfo}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Record has been saved successfully.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    
                    debugger;
                    sendFile(response.d);
                    setTimeout(function () {
                        window.location = "OutPatients.aspx?ID=" + response.d;
                    }, 2500);


                    $('#btnSave').val("Update");
                    $('#btnSave_Vital').text('Update Vital');
                },
                error: function (xhr, status, error) {
                    console.error("Error:", error);
                }
            });
            
            if ($('#fileupload')[0].files.length > 0) {
                var patientID = $('#<%= txtOut_Patient_ID.ClientID %>').val();
                if (patientID != "(New)") {
                    sendFile(patientID);
                }
            }
        }
        $(".js-example-responsive").select2({
            width: 'resolve'
        });


    </script>
    <style type="text/css">   
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="preloader" style="display: none;"><h1>Loading Page.....</h1></div>
    <div class="loader" style="display:none;    width: 200px;height: 200px;margin-left: 450px;margin-top: 30px;"><%--<img src="~../../../../wwwroot/THEME_TIBBIT/images/loading.gif"/>--%></div>
<div id="MedicationModel" class="modal fade" role="dialog">
    <div class="modal-dialog modal-lg"> <!-- Use modal-lg for larger standard size -->
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title">Add Medicine</h4>
            </div>
            <div class="modal-body">
                <fieldset>
                    <legend>Medication Details</legend>
                    <div style="overflow-x: auto;">
                        <table id="tblMedicines" class="add-test">
                            <tr>
                                <td>
                                    <span id="lblMed">Medicine Name</span>
                                </td>
                                <td>           
                                    <span id="pitem">Medicine Name</span><span class="RedStar">*</span>
                                </td>
                                <td>
                                    <select id="txtPharmacyItem" style="width:100%" name="txtPharmacyItem" onclick="getTemplate()" class="js-example-basic-single"></select>
                                </td>
                                <td id="MedicineName">
                                    <select id="txtMedicineName" name="txtMedicineName" class="js-example-responsive" onchange="CleardrpdwnItem()"></select>
                                </td>
                            </tr>
                            <tr>
                                <td><span>Dose</span><span class="RedStar"></span></td>
                                <td>
                                    <select id="ddlDosage_Qty" name="DosageQty"></select>
                                </td>
                                <td>
                                    <select id="ddlDosage_From" style="width:40%" name="DosageFrom"></select>
                                </td>
                            </tr>
                            <tr>
                                <td><span>Frequency</span><span class="RedStar">*</span></td>
                                <td>
                                    <select id="txtRecomended_Dosage" name="RecomendedDosage"></select>
                                </td>
                            </tr>
                            <tr>
                                <td><span>Route</span><span class="RedStar"></span></td>
                                <td>
                                    <select id="Routes" name="Routes"></select>
                                </td>
                                <td><span>Other Instructions</span></td>
                            </tr>
                            <tr>
                                <td><span>Duration (Days/Hours)</span><span class="RedStar">*</span></td>
                                <td>
                                    <select id="txtInjection" name="txtInjection" tabindex="5" style="width: 176px !important">
                                      
                                    </select>
                                </td>
                                <td>
                                    <select id="ddlOther_Instruction" name="OtherInstruction"></select>
                                </td>
                            </tr>
                            <tr>
                                <td><span>Special Instructions</span><span class="RedStar"></span></td>
                                <td>
                                    <input type="text" name="AttendingParamedicalStaff" id="AttendingParamedicalStaff" />
                                </td>
                                <td>
                                    <input type="text" id="txtMedicen" style="display: none;" />
                                </td>
                            </tr>
                        </table>
                        <div class="row">
                            <div class="col-lg-3 col-md-4 col-sm-6">
                            <input type="button" class="btn btn-gray" id="Add_Unlisted_Medicine" value="Add Unlisted Medicine" onclick="NewMedicine()" />
                                </div>
                        </div>
                    </div>
                </fieldset>
                <input type="hidden" name="uurowid" value=""/>
              </div>
             <div class="modal-footer justify-content-end"> <!-- Added justify-content-end to align buttons to the right -->
                <button type="button" class="btn btn-primry" id="btnSaveMedicine" name="btnSaveMedicine">Save</button>
                <button type="button" value="Done" class="btn btn-gray" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

    <div style="width: 100%">

  <div class="row">
    <!-- Left Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                        <div class="image-container">
                            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Patient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-7 col-sm-6">
                        <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" style="display:none;"></asp:TextBox>

                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 top">
                                <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblAge_Years" runat="server" Text="Age (Years):"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblContactNo" runat="server" Text="Contact No:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblGender" runat="server" Text="Gender:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vLbl_Gender" CssClass="md" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="Label10" runat="server" Text="Category:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="lblPatient_Category" CssClass="md" runat="server"></asp:Label>
                            </div>
                        </div>

                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblAdress" runat="server" Text="Address:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6 top">
                                <asp:Label ID="vLbl_Adress" CssClass="md" runat="server"></asp:Label>
                            </div>                          
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="LblOut_Patient_ID" runat="server" Text="MR No:"></asp:Label>
                    </div>
                    <div class="col-lg-5 col-md-5 col-sm-6">
                        <asp:TextBox ID="txtPatNO" runat="server" class="form-control" />
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="lblPatien_ID" runat="server" Text="OPD No *"></asp:Label>
                    </div>
                    <div class="col-lg-5 col-md-5 col-sm-6">
                        <asp:TextBox ID="txtPatient_ID" runat="server" class="form-control" />
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6">
                        <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6">
                        <asp:Label ID="vLbl_RegDate" CssClass="md" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="dlbldpt" runat="server" Text="Department:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <asp:Label ID="lblDpt" runat="server"></asp:Label>
                    </div>
                </div> 
                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="dlbdoc" runat="server" Text="Doctor:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 detail">
                        <asp:Label ID="lblDoc" runat="server"></asp:Label>
                    </div>
                </div>

                <div class="row mb-3">
                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="dlblFollowNo" runat="server" Text="Follow No:"></asp:Label>
                    </div>
                    <div class="col-lg-7 col-md-5 col-sm-6 formrgn">
                        <asp:Label ID="lblFollow" runat="server"></asp:Label>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>


        <%--<img src="~../../../../wwwroot/Styles/805.gif" class="se-pre-con" style="margin-left: 500px;"/>--%>
        <div id="tabs">
            <ul class="forcolor" >
                <li><a href="#Tab-4" >Patients Waiting List</a></li>
                <li><a href="#Tab-2" >Vital Parameter</a></li>
                <li><a href="#Tab-1">History / Examination</a></li>
                <li><a href="#Tab-6">Investigation</a></li>
                <li><a href="#Tab-9">Services</a></li>
                <li><a href="#Tab-3" style="display: none;">OPD Details</a></li>
                <li><a href="#Tab-5">Medication</a></li>
                <li><a href="#Tab-7">Follow Up / Verified</a></li>
                <li><a href="#Tab-8">Test Result</a></li>
                
            </ul>
            <div id="Tab-1">
                <h3 style="font-weight:bold;margin-top: 32px;">Presenting Complaints : </h3>
                <div id="Patientdetail" style="width: 100%">
           <div  style="height: 90px;">                   
                        <div style="text-align: left;" id="Div1">
                            <div class="row">
                                <div class="col-lg-2 col-md-3 col-sm-12 mb-2">
                                    <label>Symptom</label>
                                    <input type="text" name="txtSymtom" id="txtSymtom" class="form-control" />
                                </div>
                                <div class="col-lg-1 col-md-3 col-sm-12 mb-2">
                                    <label>Duration</label>
                                    <input type="text" name="txtDuration" id="txtDuration" class="form-control" />
                                </div>
                                <div class="col-lg-1 col-md-3 col-sm-12 mb-2">
                                    <label>Duration</label>
                                    <select id="ddlDaysMonthsYears" class="form-select">
                                        <option value="">Select</option>
                                        <option value="days">Days</option>
                                        <option value="months">Months</option>
                                        <option value="years">Years</option>
                                    </select>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-12 mb-2">
                                    <label>Remarks</label>
                                    <textarea style="width:100%;height:33px;" name="txtRemarks" id="txtRemarks" class="form-control"></textarea>
                                </div>
                                <div class="col-lg-2 col-md-4 col-sm-12 mb-2">
                                    <label>Add New Symptom</label>
                                    <input type="text" id="txtNewSymptom" class="form-control" />
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-1 col-md-4 col-sm-12 mb-2">
                                    <input type="button" id="btnAddHistory" class="btn btn-primry" onclick="Add_SymtomRow()" value="Add" />
                                </div>
                                <div class="col-lg-1 col-md-4 col-sm-12 mb-2">
                                    <input type="button" value="Save" id="btn_save" class="btn btn-primry" onclick="SymptomInsert()" style="margin-left:-10px" />
                                </div>
                            </div>
                        </div>
                    </div>


                    <div id="dvtblSymtomps" style="margin-left: 60%; margin-top:-8%; height: 184px;overflow-y:scroll">       
                        <div class="table-container">
                        <table class="table" style="margin-left:23px;"  id="tblSymtoms">
                            <thead>
                                <tr>
                                <th style="display: none;">Row ID</th>
                                <th style="display: none;">Symtom ID</th>
                                <th>Symptom </th>
                                <th>Dur </th>
                                <th>D/M/Y</th>
                                <th>Remarks </th>
                                <th>Edit</th>
                                    </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                            </div>
                    </div>
                     <div style="margin-left: 68%;">
                           <div class="table-container">
                        <table style="width:100%">
                            <tr>
                                <td class="auto-style1">
                                <h3>Refered To </h3>
                            </td>
                            </tr>
                            <tr>
                         <td class="auto-style1">
                                <asp:Label ID="Label13" runat="server" Text="Refered To"></asp:Label>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </td>
                            <td>
                                <asp:DropDownList ID="ddlPatient_Main_Category" onchange="loaddoctor_byDep()" runat="server"  AppendDataBoundItems="true" TabIndex="21">
                                </asp:DropDownList>
                            </td>
                                </tr>  
                            <tr>
                         <td class="auto-style1">
                              <label>Reffered Doctor</label>
                            </td>
                                <td>
                                <select id="ddldoctors">
                                </select>
                            </td>
                                </tr>
                            <tr>
                                <td class="auto-style1">
                                <asp:Label ID="Label14" runat="server" Text="Referral Note"></asp:Label>
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                </td>
                            <td>
                                <asp:TextBox ID="txtRefferNote"  TextMode="SingleLine" runat="server" TabIndex="22"></asp:TextBox>
                            </td>
                            </tr>
                            <tr>
                                <td class="auto-style1">                                    
                                </td>
                            </tr>
                          
                            </table>
                               </div>
                         <div style="overflow: scroll; height: 138px; width: 100%;" class="auto-style1">
                                    <table class="table" id="tblDept" style="overflow: scroll;">
                                        <thead>                                    
                                           <tr>
                                                <th>Date</th>
                                                <th>Dept</th>
                                            </tr>
                                        </thead>
                                       <tbody>
                                       </tbody>
                                    </table>
                                </div>
                             </div>
                    <div class="table-container">
                    <div style="margin-top: -1px; margin-left:68%; height: 500px;">                       
                        <h3 style="margin-top:3%">Special Examination</h3>
                        <table style="width: 100%;margin-top:2%;height:300px">
                            <hr />
                            <tr>
                                <td class="icon-cell">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/ENT.png"  alt="ENT" style="width: 100px;cursor: pointer"  onclick="ShowEntModel()" />
                                    <span>ENT</span>
                                </td>
                                <td class="icon-cell">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/eye.png" alt="ENT" style="width: 100px; cursor: pointer" onclick="ShowEyeModel()" />
                                    <span>EYE</span>
                                </td>
                                <td  class="icon-cell">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/dermatologist.png" alt="ENT" style="width: 100px; cursor: pointer" onclick="ShowDermaModel()" />
                                    <span>Dermatologist</span>
                                </td>
                            </tr>
                      
                            <tr>                                
                                <td class="icon-cell mtt-top">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/Peeds 1.png" alt="ENT" style="width: 100px; cursor: pointer" onclick="ShowPeadsModel()" />
                                    <span>Peads</span>
                                    </td>
                                <td class="icon-cell">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/Psychiatry.png" alt="ENT" style="width: 100px; cursor: pointer" onclick="ShowPsychiatryModel()"/>
                                    <span style="font-weight: bold;">Psychiatry</span>
                                </td>
                                <td class="icon-cell">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/GENERAL_ICONS/ortho.svg" alt="Ortho" style="width: 100px; cursor: pointer" onclick="ShowOrthoModel()" />
                                    <span style="font-weight: bold;">Ortho</span>
                                </td>
                            </tr>                          
                        </table>
                             </div>
                        </div>
                   
                       <div id="tabsn" style="width:66%;margin-top: -800px;height:634px">
                           
                           <ul>
                               <li><a href="#Tabh-1">History</a></li>
                               <li><a href="#Tabh-2">General Physical Examination</a></li>
                               <li class="lili"><a href="#Tabh-3" >Gynae/OBS</a></li>
                            </ul>

                       <%-- TAB 1 --%>
                          <div id="Tabh-1">
                                <table id="tblHistory" class="widthtbl" style="width: 100%;">
                                    <tr>
                                        <td colspan="6">
                                            <h3>History Section</h3>
                                        </td>
                                    </tr>

                                    <!-- History of Present Illness, Past History, and Birth History -->
                                    <tr>
                                        <td colspan="2">
                                            <asp:Label ID="Label1" runat="server" Text="History Of Present Illness"></asp:Label>
                                            <asp:TextBox ID="txtHistoryOfPeresentIllness" TextMode="MultiLine" runat="server" TabIndex="1"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="d" runat="server" Text="Past History"></asp:Label>
                                            <asp:TextBox ID="txtHistoryOfPastIllness" runat="server" TextMode="MultiLine" TabIndex="2"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label15" runat="server" Text="Birth History"></asp:Label>
                                            <asp:TextBox ID="txtBirthHistory" runat="server" TextMode="MultiLine" TabIndex="5"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <!-- Gynae, Drug History, Personal History -->
                                    <tr>
                                        <td colspan="2">
                                            <asp:Label ID="Label16" runat="server" Text="Gynae"></asp:Label>
                                            <asp:TextBox ID="txtGYNAE" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label8" runat="server" Text="Drug History"></asp:Label>
                                            <asp:TextBox ID="txtDrugHistory" runat="server" TextMode="MultiLine" TabIndex="6"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label17" runat="server" Text="Personal History"></asp:Label>
                                            <asp:TextBox ID="txtPersonalHistory" runat="server" TextMode="MultiLine" TabIndex="7"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <!-- Obstetric History, Allergies History, Treatment History -->
                                    <tr>
                                        <td colspan="2">
                                            <asp:Label ID="Label7" runat="server" Text="Obstetric History"></asp:Label>
                                            <asp:TextBox ID="txtObstetricHistory" runat="server" TextMode="MultiLine" TabIndex="7"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label9" runat="server" Text="Allergies History"></asp:Label>
                                            <asp:TextBox ID="txtAllergiesHistory" runat="server" TextMode="MultiLine" TabIndex="9"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label11" runat="server" Text="Treatment History"></asp:Label>
                                            <asp:TextBox ID="txtTreatmentHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <!-- Development History, Vaccination History, Nutrition History -->
                                    <tr>
                                        <td colspan="2">
                                            <asp:Label ID="lblDevelopmentHistory" runat="server" Text="Development History"></asp:Label>
                                            <asp:TextBox ID="txtDevelopmentHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="lblVaccinationHistory" runat="server" Text="Vaccination History"></asp:Label>
                                            <asp:TextBox ID="txtVaccinationHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="lblNutritionHistory" runat="server" Text="Nutrition History"></asp:Label>
                                            <asp:TextBox ID="txtNutritionHistory" runat="server" TextMode="MultiLine" TabIndex="10"></asp:TextBox>
                                        </td>
                                    </tr>

                                    <!-- Family History, SocioEconomic History -->
                                    <tr>
                                        <td colspan="2">
                                            <asp:Label ID="Label3" runat="server" Text="Family History"></asp:Label>
                                            <asp:TextBox ID="txtHistoryOfFamily" runat="server" TextMode="MultiLine" TabIndex="3"></asp:TextBox>
                                        </td>
                                        <td colspan="2">
                                            <asp:Label ID="Label5" runat="server" Text="SocioEconomic History"></asp:Label>
                                            <asp:TextBox ID="txtSocioEconomicHistory" runat="server" TextMode="MultiLine" TabIndex="4"></asp:TextBox>
                                        </td>
                                        <td colspan="2"></td> <!-- Empty space for balanced layout -->
                                    </tr>
                                </table>
                            
                            </div>
                            <div id="Tabh-2">
                            <table class="widthtbl" style="width: 100%;">
                                <tr>
                                    <td>Pallor</td>
                                    <td>
                                        <asp:CheckBox ID="chkPallor" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>JVP</td>
                                    <td>
                                        <asp:CheckBox ID="chkJVP" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Cyanosis</td>
                                    <td>
                                        <asp:CheckBox ID="chkaganoris" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Disoriented</td>
                                    <td>
                                        <asp:CheckBox ID="chkunconceed" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>
    
                                <tr>
                                    <td>Jaundice</td>
                                    <td>
                                        <asp:CheckBox ID="chkjaundice" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Dehydration</td>
                                    <td>
                                        <asp:CheckBox ID="hydration" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Edema</td>
                                    <td>
                                        <asp:CheckBox ID="edema" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Lymphadenopathy</td>
                                    <td>
                                        <asp:CheckBox ID="chk1" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>

                                <tr>
                                    <td>Clubbing</td>
                                    <td>
                                        <asp:CheckBox ID="chk2" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Dyspnoea</td>
                                    <td>
                                        <asp:CheckBox ID="chk3" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Neck Swelling</td>
                                    <td>
                                        <asp:CheckBox ID="ns" runat="server"></asp:CheckBox>
                                    </td>
                                    <td>Skin Lesions</td>
                                    <td>
                                        <asp:CheckBox ID="sl" runat="server"></asp:CheckBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Other</td>
                                    <td colspan="7">
                                        <asp:TextBox ID="txtInputBox1" runat="server" TextMode="MultiLine" Style="height: 60px; width: 98%;margin-left:1%" TabIndex="11"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                                            <table id="tblPeExam" class="widthtbl" style="width: 100%;">
                                                <tr>
                                                    <td colspan="6">
                                                        <b><h3>Systemic Examination</h3></b>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td colspan="6">
                                                        <b><h2>Add Per Rated Examination</h2></b>
                                                    </td>
                                                </tr>

                                                <!-- DRE and Proctoscopy with labels on top -->
                                                <tr>
                                                    <td colspan="3">
                                                        <asp:Label ID="LabelDRE" runat="server" Text="DRE"></asp:Label>
                                                        <asp:CheckBox ID="chkDRE" runat="server"></asp:CheckBox>
                                                    </td>
                                                    <td colspan="3">
                                                        <asp:Label ID="LabelProctoscopy" runat="server" Text="Proctoscopy"></asp:Label>
                                                        <asp:CheckBox ID="chkProctoscopy" runat="server"></asp:CheckBox>
                                                    </td>
                                                </tr>

                                                <!-- CNS, CVS, and Respiration fields with labels on top -->
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="Label4" runat="server" Text="CNS Examination"></asp:Label>
                                                        <asp:TextBox ID="txtCNS" runat="server" TabIndex="12" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="Label2" runat="server" Text="CVS Examination"></asp:Label>
                                                        <asp:TextBox ID="txtCVS" runat="server" TabIndex="13" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="Label6" runat="server" Text="Respiration Examination"></asp:Label>
                                                        <asp:TextBox ID="txtRESP" runat="server" TabIndex="14" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                     <td>
                                                        <asp:Label ID="Label50" runat="server" Text="GI Examination"></asp:Label>
                                                        <asp:TextBox ID="txtGIT" runat="server" TabIndex="15" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                </tr>

                                                <!-- GI, Abdomin, and Urogenital fields with labels on top -->
                                                <tr>
                                                    <td>
                                                        <asp:Label ID="lblAbdomin" runat="server" Text="Abdomin"></asp:Label>
                                                        <asp:TextBox ID="txtAbdomin" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="Label51" runat="server" Text="Urogenital System"></asp:Label>
                                                        <asp:TextBox ID="txtUGS" runat="server" TabIndex="17" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                        <td>
                                                        <asp:Label ID="Label52" runat="server" Text="Musculoskeletal System"></asp:Label>
                                                        <asp:TextBox ID="txtMucculor" runat="server" TabIndex="18" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                    <td>
                                                        <asp:Label ID="Label53" runat="server" Text="Local/Special Examination"></asp:Label>
                                                        <asp:TextBox ID="txtLocal" runat="server" TabIndex="19" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                </tr>


                                                     <tr>
                                                    <td colspan="6">
                                                        <h3>Differentiate/Provisional Diagnosis</h3>
                                                    </td>
                                                      </tr>
                                                <tr>
                                                    <td colspan="2">
                                                        <asp:Label ID="Label54" runat="server" Text="Provisional Diagnosis"></asp:Label>
                                                        <asp:TextBox ID="txtProvisionalDiagnosis" runat="server" TextMode="MultiLine" TabIndex="19" ></asp:TextBox>
                                                    </td>
                                                    <td colspan="2">
                                                        <asp:Label ID="Label55" runat="server" Text="Remarks"></asp:Label>
                                                        <asp:TextBox ID="txtRemarksHistory" runat="server" TabIndex="20" TextMode="MultiLine"></asp:TextBox>
                                                    </td>
                                                </tr>
                                            </table>

                            </div>
                            <div id="Tabh-3" style="height: 624px;">
                                <div id="tabGO" style="border:none">  
                                     <ul>
                                <li class="lili"><a href="#Tabh-4">Gynae</a></li>
                                <li class="lili"><a href="#Tabh-5">OBS</a></li>
                                      </ul>    
                                    
                                 <div id="Tabh-4">
                                    <div class="table-container">
                                     <table id="tblAbdominal">
                                         <tr>
                                           <td><asp:Label ID="lblPA" runat="server" Text="P\A" font-size="20px"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtPA_Gynae" TextMode="MultiLine" Style="margin-left:20px"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblPS" runat="server" Text="P\S" font-size="20px"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtPS_Gynae" TextMode="MultiLine" Style="margin-left:20px"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td>  <b>
                                         <h2>P\V</h2>
                                     </b></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblUterus" runat="server" Text="Uterus"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtUterus" TextMode="MultiLine" Style="margin-left:20px"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                              <td><asp:Label ID="lblFX" runat="server" Text="FX"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtFX" TextMode="MultiLine" Style="margin-left:20px"></asp:TextBox></td>
                                         </tr>                                     
                                     </table>
                                  </div>
                                 </div>
                               <div id="Tabh-5">
                                   <div class="table-container">
                                    <table id="tblOBS">
                                         <tr>
                                           <td><asp:Label ID="lblPS_OBS" runat="server" Text="P\S" font-size="20px"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtPS_OBS" TextMode="MultiLine"></asp:TextBox></td>
                                       </tr>
                                        <tr>
                                           <td><asp:Label ID="lblPV" runat="server" Text="P\V" font-size="20px"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtPV" TextMode="MultiLine"></asp:TextBox></td>
                                        </tr>
                                          <tr>
                                             <td>
                                                  <b>
                                         <h2>Abdominal</h2>
                                             </b>
                                             </td>

                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblSFH" runat="server" Text="SFH"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtSFH" TextMode="MultiLine"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblLIE" runat="server" Text="LIE"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtLIE" TextMode="MultiLine"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblPresentation" runat="server" Text="Presentation"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtPresentation" TextMode="MultiLine"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblFHR" runat="server" Text="FHR"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtFHR" TextMode="MultiLine"></asp:TextBox></td>
                                         </tr>
                                         <tr>
                                             <td><asp:Label ID="lblEngagement" runat="server" Text="Engagement"></asp:Label></td>
                                             <td><asp:TextBox runat="server" ID="txtEngagement" TextMode="MultiLine"></asp:TextBox></td>
                                         </tr>
                                        </table>
                                       </div>

                               </div>
                           </div>
                           </div>
    
                    </div>
                   
               
                    <div class="table-container">
                    <div style="margin-left: -5px; margin-top: 12px;">
                        <table class="table" id="tblHistoryTabHistory" style="display: block; overflow: scroll;">
                            <thead>
                                <tr>
                                    <td colspan="140">
                                        <div id="tblHistoryTabHistoryHeader">
                                            <h2 style="color:white !important">Previous History</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>History Of Present Illness</th>
                                    <th>Family History</th>
                                    <th>Development History</th>
                                    <th>Vaccination History</th>
                                    <th>Nutrition History</th>
                                    <th>SocioEconomic History </th>
                                    <th>Birth History </th>
                                    <th>Drug History </th>
                                    <th>Personal History </th>
                                    <th>Obstetric History </th>
                                    <th>Allergies History </th>
                                    <th>Treatment History</th>
                                    <th>GIT</th>
                                    <th>CVS</th>
                                    <th>CNS</th>
                                    <th>RESP</th>
                                    <th>Gyane</th>
                                    <th>UGS</th>
                                    <th>Abdominal</th>
                                    <th>PA(Gynae)</th>
                                    <th>PS(Gynae)</th>
                                    <th>Uterus</th>
                                    <th>FX</th>
                                    <th>PS(OBS)</th>
                                    <th>PV(OBS)</th>
                                    <th>SFH</th>
                                    <th>LIE</th>
                                    <th>Presentation</th>
                                    <th>FHR</th>
                                    <th>Engagement</th>
                                    <th>Muscu..Sys</th>
                                    <th>Local Ex </th>
                                    <th>Provisional Diagnosis</th>
                                    <th>Remarks    </th>
                                    <th>Other</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                        </div>
                    <div class="table-container">
                    <table>
                        <tr>
                            <td>
                                <div id="dvSyptomHistory" <%--style=" height:100px;"--%>>
                                    <table class="table" style="height: 30px; overflow: scroll;" id="tblSymptomHistory">
                                        <thead>
                                            <tr>
                                                <td colspan="6">
                                                    <div id="Div8">
                                                        <h2 style="color:white !important;">Symptom History</h2>
                                                    </div>
                                                </td>
                                            </tr>
                                            <tr>
                                                <th style="display: none;">Symtom ID</th>
                                                <th>Status</th>
                                                <th style="width: 183px  !important;">Symptom </th>
                                                <th>Duration </th>
                                                <th>D / M / Y</th>
                                                <th>Remarks </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                    <input type="button" id="LoadSymp" value="Load Syptoms" class="btn btn-primry" style="width:115px !important;" onclick="AppendSymtompsHistory()" />
                                </div>
                            </td>
                            <td></td>
                        </tr>
                    </table>
                        </div>

                    <div id="dvPsychiatryHistory" style="margin: 0 auto; margin-top: 0px;">
                        <table class="table" id="tblPsychiatryHistory" style="display: block; overflow: scroll;">
                         
                            <thead>
                                <tr>
                                    <td colspan="160">
                                        <div id="tblPsychiatryHeader">
                                            <h2 style="color:white !important;">Psychiatry History</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>Informant(s) </th>
                                    <th>Source Of Referral</th>
                                    <th>Neck Holding </th>
                                    <th>Walking </th>
                                    <th>Talking</th>
                                    <th>Others</th>
                                    <th>Menarche</th>
                                    <th>Menstrual</th>
                                    <th>Attachment/ Separation from Parents</th>
                                    <th>Health</th>
                                    <th>Nail Biting</th>
                                    <th>Temper Tantrums</th>
                                    <th>Bed Wetting</th>
                                    <th>Academics</th>
                                    <th>Peer Relationship</th>
                                    <th>Behaviour</th>
                                    <th>History</th>
                                    <th>Sexual History</th>
                                    <th>Substance Use</th>
                                    <th>Forensic Use</th>
                                    <th>Relationship</th>
                                    <th>Leisure Activities </th>
                                    <th>Attitude</th>
                                    <th>Prevalling Mood</th>
                                    <th>Reaction Pattren to Stress </th>
                                    <th>Religious Practices</th>
                                    <th>Father</th>
                                    <th>Mother </th>
                                    <th>Siblings</th>
                                    <th>Familial Illness</th>
                                    <th>Home Atmosphere, relationship, social class </th>
                                    <th>Actual Age</th>
                                    <th>Race</th>
                                    <th>Tattoos, body piercing and scars:</th>
                                    <th>Body Habitus</th>
                                    <th>Dress</th>
                                    <th>Hygiene </th>
                                    <th>Psychomotor Activity:</th>
                                    <th>Involuntary movements</th>
                                    <th>Dystonia &amp; EPS</th>
                                    <th>Tardive dyskinesia</th>
                                    <th>Tics</th>
                                    <th>Tremors </th>
                                    <th>Attentiveness to interview</th>
                                    <th>Eye Contact</th>
                                    <th>Level of Consciousness</th>
                                    <th>Rate</th>
                                    <th>Rhythm</th>
                                    <th>Volume </th>
                                    <th>Tone</th>
                                    <th>Modulation</th>
                                    <th>Depressed</th>
                                    <th>Elated</th>
                                    <th>Irritable</th>
                                    <th>Labile</th>
                                    <th>Incongruent</th>
                                    <th>Blunting/ Flattening/ Apathy </th>
                                    <th>Thinking/ Premeditation</th>
                                    <th>Plans</th>
                                    <th>Actions</th>
                                    <th>Preservative</th>
                                    <th>LoosAssociation</th>
                                    <th>Tangentiaility</th>
                                    <th>Circumstantiality</th>
                                    <th>Flight Ideas </th>
                                    <th>Thought Insertion</th>
                                    <th>Thought Withdrawal</th>
                                    <th>Thought Broadcasting</th>
                                    <th>Thought Control</th>
                                    <th>Dellusion</th>
                                    <th>Overvalued Ideas</th>
                                    <th>Depresonalization</th>
                                    <th>Derealization </th>
                                    <th>Obsession</th>
                                    <th>Phobies</th>
                                    <th>Homocidial Ideas</th>
                                    <th>Illusion</th>
                                    <th>Hallucination </th>
                                    <th>Orientation:Time</th>
                                    <th>Place</th>
                                    <th>Person </th>
                                    <th>Attention &amp; Concentration</th>
                                    <th>Days Of Week</th>
                                    <th>Immediate Memory</th>
                                    <th>Short Term:Recent Events</th>
                                    <th>Long Term :Remote Events</th>
                                    <th>Adress Recall After 2 Minutes</th>
                                    <th>Adress Recall After 5 Minutes</th>
                                    <th>General knowledge Questions </th>
                                    <th>Simple Arthemetic Calculation</th>
                                    <th>Abstraction /Concrete Thinking</th>
                                    <th>Insight</th>
                                    <th>Health problem</th>
                                    <th>Health caused  </th>
                                    <th>problem started</th>
                                    <th>Health course </th>
                                    <th>Health treatment </th>
                                    <th>Health effects </th>
                                    <th>PLUSE</th>
                                    <th>B.P  </th>
                                    <th>TEMPERATURE</th>
                                    <th>Weight </th>
                                    <th>Respiratory Rate</th>
                                    <th>JAUNDICE</th>
                                    <th>ANEMIA </th>
                                    <th>CYANOSIS</th>
                                    <th>CLUBBING </th>
                                    <th>JVP</th>
                                    <th>LYMPH NODES </th>
                                    <th>EDEMA </th>
                                    <th>Respiratory</th>
                                    <th>Cardiovascular</th>
                                    <th>Gastro-Intestinal: </th>
                                    <th>Observation:(Involuntary Movements / Gestures / Mannerism / Mobility)</th>
                                    <th>Cranial Nerves: </th>
                                    <th>Limb strength: </th>
                                    <th>Spasticity, Flaccidity, or Fasciculations:</th>
                                    <th>Position</th>
                                    <th>Vibration</th>
                                    <th>Stereognosis</th>
                                    <th>Pain</th>
                                    <th>Biceps</th>
                                    <th>Triceps</th>
                                    <th>Brachioradialis</th>
                                    <th>Quadriceps</th>
                                    <th>Patellar</th>
                                    <th>Achilles</th>
                                    <th>Extensor Plantar Response </th>
                                    <th>Frontal Release Reflexes </th>
                                    <th>Finger_to_nose Test </th>
                                    <th>Heel-to-shin Test </th>
                                    <th>Rapid Alternating Movements </th>
                                    <th>Gait</th>
                                    <th>Neck Rigidity</th>
                                    <th>Kerning's Sign</th>
                                    <th>Brudzinki's Sign</th>
                                    <th>Assessment Summary</th>
                                    <th>Diagnosis</th>
                                    <th>Axis I: </th>
                                    <th>Axis II: </th>
                                    <th>Axis III: </th>
                                    <th>Axis IV: </th>
                                    <th>Axis V: </th>
                                    <th>Predisposing Factors:</th>
                                    <th>Precipitating Factors: </th>
                                    <th>Prepetuating Factors: </th>
                                    <th>Investigation</th>
                                    <th>Medical</th>
                                    <th>Psychological</th>
                                    <th>Major Issues: </th>
                                    <th>Strengths and Weaknesses: </th>
                                    <th>Management Goals: </th>
                                    <th>Strategies and Interventions: </th>
                                </tr>

                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>

                </div>
            </div>
            <div class="table-container">
            <div id="Tab-2">

                <div id="Vital Parameter" style="width: 100%">
                    <table style="padding: 20px" id="vitalparams">
                        <tr>
                            <td colspan="4">
                                <h2>Vital Parameters : </h2>
                            </td>
                        </tr>
                        <tr>
                            <td></td>
                            <td></td>
                            <td class="mgTab"></td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="LblPuls" runat="server" Text="Pulse (Beats/min)"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtPuls" runat="server" TabIndex="1"></asp:TextBox>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="LblHeight" runat="server" Text="Height (ft.cm)"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtHeight"  placeholder="5.2" runat="server" TabIndex="5"></asp:TextBox>


                            </td>
                            <td class="mgTab">
                                <asp:Label ID="Label35" runat="server" Text="BSR"></asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:TextBox ID="TxtBSR"  runat="server" TabIndex="9" CssClass="align"></asp:TextBox>


                            </td>
                              <td class="mgTab">
                                <asp:Label ID="LBL_SPO2" runat="server" Text="SPO2"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtspo2" runat="server" TabIndex="7"></asp:TextBox>


                            </td>

                        </tr>
                      
                        <tr class="mtt-top">
                            <td>
                                <asp:Label ID="LblBP" runat="server" Text="B.P (mmHg) "></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBP" runat="server" placeholder="120/80" TabIndex="2"></asp:TextBox>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="LblWeight" runat="server" Text="Weight (kgs)"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtWeight" onchange="calculateBMI()" runat="server" TabIndex="6"></asp:TextBox>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="LblBMI" runat="server" Text="BMI"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtBMI" runat="server" TabIndex="10"></asp:TextBox>

                            </td>
                             <td class="mgTab">
                                <asp:Label ID="LBL_LMP" runat="server" Text="L.M.P"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtLMP" runat="server" TabIndex="7"></asp:TextBox>


                            </td>
                        </tr>
                        
                        <tr class="mtt-top">

                            <td>
                                <asp:Label ID="LblTemp" runat="server" Text="Temp (°F)"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtTemp" runat="server" TabIndex="3"></asp:TextBox>

                            </td>
                            <td>
                                <asp:Label ID="Label12" runat="server" Text="Respiration (Breaths/min)"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtRespiration" runat="server" TabIndex="4"></asp:TextBox>


                            </td>
                           
                          
                           <td class="mgTab">
                                <asp:Label ID="lblMUAC" runat="server" Text="MUAC(cm)"></asp:Label>

                            </td>
                            <td>
                                  <asp:TextBox ID="txtMUAC" runat="server" TabIndex="11"></asp:TextBox>

                            </td>

                        </tr>
                        <tr style="display: none;">
                            <td>
                                <asp:Label ID="LblProvisional_Diagnosis" runat="server" Text="Provisional Diagnosis"></asp:Label>

                            </td>
                            <td></td>
                            <td class="mgTab">
                                <asp:Label ID="LblRefer_To_Hospital" runat="server" Text="Refer To Hospital"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtRefer_To_Hospital" runat="server" TextMode="MultiLine" TabIndex="9"></asp:TextBox>

                            </td>

                        </tr>
                        <tr style="display:none;">
                            
                             <td class="mgTab">

                                <asp:Label ID="Label34" runat="server" Text="EDD"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtedd" runat="server" TabIndex="8"></asp:TextBox>


                            </td>
                            <td class="mgTab">

                                <asp:Label ID="lblOFC" runat="server" Text="OFC(cm)"></asp:Label>

                            </td>
                            <td>
                                <asp:TextBox ID="txtOFC" runat="server" TabIndex="12"></asp:TextBox>
                            </td>

                        </tr>
                        <tr>
                            <td>
                                <input type="button" class="btn-primry" value="Save Vital" id="btnSave_Vital"  style = "font-size:16px" <%-- onclick="SaveMedicinesAndTests()"--%>  />
                            </td>
                        </tr>


                    </table>
                    </div>
                   <div class="table-container">
                        <table style="width:100%" id="divVitalParametersHistory">

                             <tr>
                                 <td>
                                     <table class="table" id="tblVitalParametersHistory">
                                         <thead>
                                             <tr>
                                                 <td colspan="14">
                                                     <div id="tblHistoryHeader">
                                                         <h3 class="headingcolr" >Previous History</h3>
                                                     </div>
                                                 </td>
                                             </tr>
                                             <tr>
                                                 <th>Date</th>
                                                 <th>Status</th>
                                                 <th>Pulse</th>
                                                 <th>Temp</th>
                                                 <th>Height</th>
                                                 <th>L.M.P</th>
                                                 <th>SPO2</th>
                                                  <th>BSR</th>
                                                 <th>BMI</th>                                           
                                                 <th>BP </th>
                                                 <th>Respiration </th>
                                                 <th>Weight</th>                                         
                                                 <th>Action</th>
                                             </tr>
                                         </thead>
                                         <tbody>
                                         </tbody>
                                     </table>
                                 </td>
                             </tr>
                        </table>
               
                       </div>



                </div>
            </div>
            <div id="Tab-3" style="display: none">
                <h1>In-Patient Details : </h1>
                <div id="IPD Details" style="width: 70%">
                    <table>
                        <tr>
                            <td>
                                <asp:Label ID="LblOPD_Entry_Date_Detail" runat="server" Text="OPD Entry Date : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vLblOPD_Entry_Date_Detail" runat="server"></asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="LblSufferingDays" runat="server" Text="Suffering Days : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vLblSufferingDays" runat="server"></asp:Label>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="LblRecommended_Department_Detail" runat="server" Text="Recommended Department : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vLblRecommended_Department_Detail" runat="server"></asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="LblRecommended_Doctor_Detail" runat="server" Text="Recommended Doctor : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vLblRecommended_Doctor_Detail" runat="server"></asp:Label>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblRefering_Doctor_Detail" runat="server" Text="Refering Doctor : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblRefering_Doctor_Detail" runat="server"></asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="lblRefer_To_Hospital_Detail" runat="server" Text="Refer To Hospital : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblRefer_To_Hospital_Detail" runat="server"></asp:Label>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblComplaints_Detail" runat="server" Text="Helth Complaints : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblHealth_Complaints_Detail" runat="server"></asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="lblPulse_Detail" runat="server" Text="Pulse :"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblPulse_Detail" runat="server"> /min</asp:Label>

                                &nbsp;</td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblBlood_Pressure_Detail" runat="server" Text="Blood Pressure :"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblBlood_Pressure_Detail" runat="server"> mm of hg</asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="lblHeight_Detail" runat="server" Text="Height :"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblHeight_Detail" runat="server"> cm</asp:Label>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblWeight_Detail" runat="server" Text="Weight  : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblWeight_Detail" runat="server"> kg</asp:Label>

                            </td>
                            <td class="mgTab">
                                <asp:Label ID="lblRespiration_Detail" runat="server" Text="Respiration :"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblRespiration_Detail" runat="server"> /min</asp:Label>

                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblTemp_Detail" runat="server" Text="Temp :"></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblTemp_Detail" runat="server"> c</asp:Label>

                            </td>
                            <td class="mgTab">

                                <asp:Label ID="lblProvisional_Detail" runat="server" Text="Provisional Diagnosis : "></asp:Label>
                            </td>
                            <td>
                                <asp:Label ID="vlblProvisional_Detail" runat="server"></asp:Label>

                            </td>
                        </tr>

                    </table>
                </div>
            </div>
            <div id="Tab-4">
                <h1>Patients Waiting List Department Wise : </h1>
                <div id="Div2">
                    <div class="row" style="margin-bottom:10px">
                         <div class="col-lg-1 col-md-4 col-sm-6">
                            <label> Department </label>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <select id="ddlPatientDepartment" runat="server"></select>
                        </div>
                         <div class="col-lg-1 col-md-4 col-sm-6">
                            <label> Doctor </label>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6" id="doctor">
                            <select id="ddldocname" onchange="fillPendingPatientsList();" runat="server"></select>
                        </div>
                    </div>
                    <div>
                    </div>
                    <div class="table-container" style="overflow: scroll; height: 400px;">
                        <table class="table table-hover table-striped table-bordered" id="tblPendingPatients">
                            <thead id="ihead">
                                <tr>
                                    <th>OPD No</th>
                                    <th>Token No</th>
                                    <th>Patient Name</th>
                                    <th>Age</th>
                                    <th>Department</th>
                                    <th>Filter Clinic</th>
                                    <th>Doctor</th>
                                    <th style="width: 173px;">Created Time</th>
                                    <th>Operator Name</th>
                                    <th>Status</th>
                                    <th>Select</th>
                                </tr>
                            </thead>
                            <tbody id="ibody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
            <div id="Tab-5">
                <div id="Medication">
                    <h2>Medication :</h2>
                            <div class="row align-items-center mb-3">
                                <div class="col-lg-2 col-md-4 col-sm-12">
                                    <h4 style="font-weight: bold;">Template</h4>
                                    <select id="ddlTemplate" class="form-select" onchange="LoadTemplateMedicine()">
                                        <option value="">Select Template</option>                                   
                                    </select>
                                </div>
                                <div class="d-flex align-items-center" style="margin-top: 36px;">
                                    <div class="col-lg-2 col-md-4 col-sm-12">
                                        <input type="button" class="btn btn-primry" style="width: 70% !important;" value="Add Medicine" id="btnAddMedicine" />
                                    </div>
                                    <div class="col-lg-2 col-md-8 col-sm-12 d-flex align-items-center" style="margin-left:-4%;">
                                        <label for="chkNo_Medicine" class="me-2">No Medicine</label>
                                        <asp:CheckBox class="Chkbox" ID="chkNo_Medicine" runat="server" Style="margin-left:10%" />
                                    </div>
                                </div>


                            </div>

                                                  
                                <div >
                               <div class="table-container">
                                         <div class="table-responsive" style="overflow-y:scroll;height:360px">
                                       <table class="table table-bordered" id="tblMedicinesList">
                                           <thead>
                                               <tr style="position: sticky; top: 0px; z-index: 10;" >
                                                   <th>Date</th>
                                                   <th>Medicine Name</th>
                                                   <th>Frequency</th>
                                                   <th>Routes</th>
                                                   <th>Duration</th>
                                                   <th>Special Instructions</th>
                                                   <th>Dosage Form</th>
                                                   <th>Dosage Qty</th>
                                                   <th>Other Instructions</th>
                                                   <th>Edit</th>
                                               </tr>
                                           </thead>
                                           <tbody>
                                           </tbody>
                                       </table>
                                   </div>
                               </div>
                                </div>


                      <div class="table-container" id="dvHistoryMedication">
                  <table class="table" id="tblHistoryMedication">
                      <thead>
                          <tr>
                              <td colspan="12">
                                  <div id="HeaderHistoryMedication">
                                      <h2 style="color:white !important">Previous History</h2>
                                  </div>
                              </td>
                          </tr>
                          <tr>
                              <th><input type="checkbox" id="select-all-checkbox" /></th>
                              <th>Date </th>
                              <th>Status </th>
                              <th>Medicine Name</th>
                              <th>Frequency  </th>
                              <th>Routes </th>
                              <th>Duration </th>
                              <th>Dosage</th>
                            <th style="display:none;">Attending Paramedical Staff </th>
                          </tr>
                      </thead>
                      <tbody>
                      </tbody>
                  </table>
             
                          <div class="row">
                              <div class="col-lg-8 col-md-9 col-sm-10">
                                  <div class="row">
                                      <div class="col-lg-2 col-md-4 col-sm-6">
                                          <input type="button" class="btn btn-primry" value="Load Medicine" id="load_previous_Med" onclick="Appendintable()" />
                                      </div>
                                  </div>
                              </div>
                          </div>
                      </div>
                </div>
            </div>

     <div id="Tab-6">
    <div id="Tests" style="width: 100%;">
        <table>
            <form>
                <div class="row">
                    <div class="col-lg-6 col-md-3 col-sm-6">
                        <h1 style="font-weight: bold;">Main Tests Department :</h1>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label style="font-weight: bold;">Template</label>
                        <select id="ddlTemplateTest" onchange="LoadtepmlateTest()" style="width: 100%;"></select>
                    </div>
                    <div class="col-lg-3 col-md-3 col-sm-6">
                        <label>Department</label>
                        <select id="ddlMainTestDepartment" class="form-control" onchange="LoadTestByDepartment()"></select>
                    </div>
                    <div class="col-lg-3 col-md-3 col-sm-6">
                        <label>Test</label>
                        <select id="ddlTestList" class="form-control">
                            <option value="">Select Department</option>
                        </select>
                    </div>
                      <div class="col-lg-2 col-md-3 col-sm-6" style="margin-top: 30px;">
                        <label>No Lab Test</label>
                        <asp:CheckBox class="Chkbox" ID="chkNo_Test" style="margin-left:5% !important;" runat="server"></asp:CheckBox>
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6" id="ddl_xray_rotation" style="margin-top: 2%;">
                        <select id="ddlRotation"></select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <label>Special Test</label>
                        <asp:TextBox ID="txtSpecialTests" Class="form-control" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                    <div class="col-lg-3 col-md-3 col-sm-6">
                        <label>Area Of Interest</label>
                        <asp:TextBox ID="txtAreaOfInterest" runat="server" TextMode="MultiLine"></asp:TextBox>
                    </div>
                    
                    <div class="col-lg-2 col-md-3 col-sm-6" style="margin-top: 2%;">
                        <input type="button" class="btn-primry" value="Add Test" id="btnAddAllTest" onclick="AddAllTest()" style="width:60% !important" />
                    </div>
                    <div class="col-lg-1 col-md-3 col-sm-6" style="margin-top: 2%;margin-left:-5%">
                        <span class="btn-tests btn-primry"  id="btngetalltest"><i class="fa fa-check-square">Test</i></span>
                    </div>
                  
                </div>
                <div class="col-lg-0 col-md-3 col-sm-6">
                    <select id="ddlXRayLF" style="display: none; width: 73px !important; margin-left: 101px; margin-top: -28px; height: 28px;">
                        <option value="0"></option>
                        <option value="L">Left</option>
                        <option value="R">Right</option>
                    </select>
                </div>
            </form>
        </table>
    </div>

    <div style="height: 280px;">
        <div class="table table-container" style="overflow-y:scroll;height:266px">
            <table id="tblLabtest" class="table table-bordered table-custom tests-table">
                <thead>
                    <tr style="position: sticky; top: 0;z-index: 10;">
                        <th>Date</th>
                        <th>Test Name</th>
                        <th>Sample Received</th>
                        <th>Result</th>
                        <th>Special Tests</th>
                        <th>Area Of Interest</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="loadtest">
                </tbody>
            </table>
        </div>
    </div>

    <div style="height: 280px;">
        <div class="table-container">
            <div class="table-responsive" style="overflow-y:scroll;height:286px">
                <table id="dvHistoryTests">
                    <tr>
                        <td>
                            <table class="table" id="tblHistoryTests">
                                <thead>
                                    <tr style="position: sticky; top: 0;z-index: 10;">
                                        <td colspan="12">
                                            <div id="HeaderTests">
                                                <h2 class="headingcolr">Previous History</h2>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr style="position: sticky; top: 70px; z-index: 10;">
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Test Name</th>
                                        <th>Sample Received</th>
                                        <th>Result</th>
                                        <th>Special Tests</th>
                                        <th>Area Of Interest</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

         <div class="row">
             <div class="col-lg-8 col-md-9 col-sm-10">
                 <div class="row">
                     <div class="col-lg-2 col-md-4 col-sm-6">
                         <input type="button" class="btn btn-primry" value="Load Test" id="load_previous_test" onclick="Appendtestintable()" />
                     </div>
                 </div>
             </div>
         </div>
     </div>

            <div id="Tab-7">
                <div id="Control" style="width: 100%">
                    <form>
                        <div class="row">
                        <div class="col-lg-2 col-md-3 col-sm-6">
                             <h1 style="font-weight:bold">Disposal: </h1>
                        </div>
                        </div>
                        <div class="row">
                        <div class="col-lg-2 col-md-3 col-sm-6">
                        <label>Doctor Name <span class="RedStar">*</span></label>
                        <asp:DropDownList ID="ddlDoctorName" class="form-control" runat="server"  AppendDataBoundItems="true" onchange="LoadDesignation();" ></asp:DropDownList >
                        </div>                        
                          <div class="col-lg-2 col-md-3 col-sm-6">
                              <label>Designation </label>
                              <asp:TextBox ID="txtDesignation" Class="form-control" ReadOnly="true" runat="server"></asp:TextBox>
                         </div>
                             <div class="col-lg-2 col-md-3 col-sm-6">
                                 <label>Addmision </label>
                                 <asp:DropDownList ID="ddlIssuance_Of" Class="dropdownBackgroud ; form-control" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                             </div>
                         <div class="col-lg-2 col-md-3 col-sm-6">
                                     <label>Follow Up <span class="RedStar">*</span></label>
                                    <asp:DropDownList ID="ddlFOllowUp"  CssClass="dropdownBackgroud" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                         </div>
                          <div class="col-lg-2 col-md-3 col-sm-6">
                              <label> FollowUp Date<span class="RedStar">*</span></label>
                              <asp:TextBox ID="FollowNoDate" runat="server"></asp:TextBox>
                         </div>
                         <div class="col-lg-2 col-md-3 col-sm-6">
                                  <label>Date</label>
                                   <asp:TextBox ID="txtDate" runat="server" ReadOnly="True"></asp:TextBox>
                         </div>
                            </div>
                       <div class="row">
                            <div class="col-lg-2 col-md-6">
                                <label for="txtFinalDiagnosis">Diagnosis Dx / DDs</label>
                                <asp:TextBox ID="txtFinalDiagnosis" class="form-control" runat="server" TextMode="MultiLine"></asp:TextBox>
                            </div>
                            <div class="col-lg-2 col-md-6">
                                <label for="txtAdvice">Advice</label>
                                <asp:TextBox ID="txtAdvice" runat="server" class="form-control" TextMode="MultiLine"></asp:TextBox>
                            </div>
                             <div class="col-lg-2">
                                <label>Proto <span class="RedStar">*</span></label>                                
                                   <asp:DropDownList ID="ddlProto" CssClass="dropdownBackgroud" runat="server" onchange="AddProto();"  AppendDataBoundItems="true"></asp:DropDownList >
                            </div>
                            <div class="col-lg-1 col-md-3">
                                <label for="CheckBox1" style="margin-top:27%">Discharge<span class="RedStar">*</span></label>
                                </div>
                           <div class="col-lg-1 col-md-3" style="margin-top:2% !important">
                                <asp:CheckBox ID="CheckBox1" runat="server"></asp:CheckBox>
                            </div>
                           <div class="col-lg-2 col-md-3 col-sm-4">
                              <label>Verbal Consent <span class="RedStar">*</span></label>
                              <asp:DropDownList ID="ddlverbal_consent"  CssClass="dropdownBackgroud" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
                         </div>
                        </div>
                        <div class =" row">
                                                                       <div class="col-lg-4 col-md-3 col-sm-4">
                 <table class="table" style="height: auto; overflow: scroll;" id="tblProto">
                     <thead>
                         <tr>
                             <th style="text-align: left;">Protos</th>
                             <th>Action</th>
                         </tr>
                     </thead>
                     <tbody>
                     </tbody>
                 </table>
             </div>
                        </div>
                        <div class="row mt-3">
                            <div class="col-lg-6">
                                <label for="Final_Rec">Referral</label>
                                <asp:TextBox ID="Final_Rec" class="form-control" runat="server" TextMode="MultiLine" Style="height: 250px!important;"></asp:TextBox>
                            </div>
      
                <h5 class="font-weight-bold text-danger" style="font-size: 24px;text-align: center;font-weight: bold;margin-top:-10px">File Attachment</h5>  
                <div class="col-lg-6 d-flex align-items-center card2">
                    <div class="w-100">            
                        <div class="d-flex justify-content-center">            
                            <div class="text-center col-lg-3 col-md-3 col-sm-4">
                                <div class="p-3 border rounded" style="cursor: pointer; background-color: #f5f5f5; border: 1px dashed #ccc; width: 240px;" onclick="document.getElementById('fileupload').click();">
                                    <div class="bg-danger text-white rounded-circle d-flex justify-content-center align-items-center" style="width: 80px; height: 80px; margin: 0 auto;">
                                        <i class="fa fa-upload fa-2x"></i>
                                    </div>
                                    <p class="mt-2">Drag and drop file or Choose File</p>                       
                                   <input type="file" id="fileupload" style="display:none">
                                </div>
                            </div>
                              <div class="text-center col-lg-3 col-md-3 col-sm-4"></div>
                            <div class="text-center col-lg-3 col-md-3 col-sm-4">
                                <div class="p-3 border rounded" style="cursor: pointer; background-color: #f5f5f5; border: 1px dashed #ccc; width: 240px;"">
                                    <div class="bg-danger text-white rounded-circle d-flex justify-content-center align-items-center" style="width: 80px; height: 80px; margin: 0 auto;">
                                        <i class="fa fa-download fa-2x"  id="downloadfile" onclick="downloadFile()"></i>
                                    </div>
                                    <p class="mt-2">Download file</p>

                                </div>
                            </div>

                        </div>

                    </div>
                </div>

                        </div>
                    </form>

                    <table style="margin-left: 60px;">
                        <tr>
                           <td> <asp:Label ID="lblNextPlan" runat="server" Text="Next Plan" style="font-weight:bold;"></asp:Label></td>
                                    <td>
                                        <asp:TextBox ID="txtNextPlan" runat="server"></asp:TextBox>
                                    </td>

                        </tr>
                    </table>
                </div>

                <div class="table-responsive">
                    <table class="table table-bordered" id="tblControlHistory">
                        <thead>
                            <tr>
                                <td colspan="12">
                                    <div id="tblControlHistoryHeader">
                                        <h2 class="headingcolr">Previous History</h2>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <th>Date</th>
                                <th>Last Update Date</th>
                                <th>Doctor Name</th>
                                <th>Designation</th>
                                <th>Admission</th>
                                <th>Discharge</th>
                                <th>Final Diagnosis</th>
                                <th>Follow Up</th>
                                <th>Follow Date</th>
                                <th>Advice</th>
                            </tr>
                        </thead>
                        <tbody id="cleartbl">                            
                        </tbody>
                    </table>
                </div>
            </div>
            <div id="Tab-8">
                <table>
                    <tr >
                        <td style="width:203px; display:none">
                            <asp:Label ID="Label19" runat="server" Text="MR No" Style="margin-right:20px"></asp:Label>
                        </td>
                        <td style="padding-bottom:7px; display:none">
                            <asp:TextBox ID="txtMRNO" runat="server"></asp:TextBox>
                        </td>

                    </tr>
                </table>
                <div class="table-container">
                    <div class="table-responsive" style="height: 280px;">
                        <table class="table" id="tblResultTest">
                            <thead>
                                <tr>
                                    <td colspan="12">
                                        <div id="Div3">
                                            <h2 class="headingcolr">Previous History</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Test Collected Date</th>
                                    <th>Test Ready Date</th>
                                    <th>Test Name</th>
                                    <th>Test Collected By</th>
                                    <th>Result</th>
                                    <th>Image View</th>
                                </tr>
                            </thead>
                            <tbody id="Tbody1">
                            </tbody>
                        </table>
                    </div>
                </div>
                </div>

                 <div id="Tab-9">
                     <div class="row align-items-center mb-3">
                         <div class="col-lg-2 col-md-4 col-sm-12">
                             <h2>Services</h2>
                             <input type="text" id="txtService" name="txtService" runat="server" class="form-control" />
                         </div>
                         <div class="col-lg-1 col-md-4 col-sm-12 position-relative">
                             <input type="button" id="btnAddService" class="btn btn-primry" name="btnAddService" onclick="AddServiceOrItem()" value="Add Service" style="margin-top: 16%;margin-left:4%;width:50% !important" />
                         </div>
                         <div class="col-lg-2 col-md-4 col-sm-12  position-relative">
                             <span class="btn btn-item" id="btnGetAllIServices" style="margin-top: 16%;margin-left:-47%" ><i class="fa fa-check-square"></i>Services</span>
                         </div>
                     </div>


                         <div style="height: 250px !important;overflow-y:scroll">
                         <table class="table"  id="tblServices">
                         <thead>
                        <tr>                           
                            <th style="text-align: left;position: sticky; top: 0;z-index: 10;">Date Time</th>
                            <th style="text-align: left;position: sticky; top: 0;z-index: 10;">Services / Procedure</th>
                            <th style="text-align: left;position: sticky; top: 0;z-index: 10;">User Name</th>
                            <th style="text-align: left;position: sticky; top: 0;z-index: 10;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div> 
                           
            <div style=" height: 250px !important;overflow-y:scroll;">
                <table class="table" id="tblServicesHistory">
                    <thead>
                        <tr style="position: sticky; top: 0;z-index: 10;">
                            <td colspan="12">
                                <div id="ServicesHistoryHeader">
                                    <h2 class="headingcolr">Previous History</h2>
                                </div>
                            </td>
                        </tr>
                        <tr  style="text-align: left;position: sticky; top: 70px;z-index: 10;">                            
                            <th>Date Time</th>
                            <th>Services / Procedure</th>
                            <th>User Name</th>
                          
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
                    <input type="button" onclick="AppendServices_Procedures()" class="btn-primry" id="Loadservice" value="Load Services" style=" width:130px !important" />

               </div>
        </div>

        <div>
            <table>
                <tr>

                    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfReg_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfPatient_No" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfdhischarge" Value ="false" runat="server" ClientIDMode="Static" />
                    <asp:HiddenField ID="hdfFetch_ID" runat="server" ClientIDMode="Static" />
                </tr>                             
                <tr>
                    <td>                     
                        &nbsp;                       
                        &nbsp;
                        <input type="button" value="Clear" name="name" onclick="ClearAll();" style="display: none;" />
                        &nbsp;                       
                        &nbsp;                                                    
                         &nbsp;                                                           
                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblMessage" runat="server"></asp:Label>

                    </td>
                </tr>
                <tr>
                    <td>
                        <asp:ValidationSummary ID="ValidationSummary1" runat="server"
                            ForeColor="Red" HeaderText="Page Errors"
                            ShowSummary="true" DisplayMode="List" />
                    </td>
                </tr>
            </table>
            <div class="button-container" style="margin-top: 1%">
                <div class =" col-lg-8">
                <div class="button-row">
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" id="btnSave" value="Save" onclick="SaveMedicinesAndTests()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-yellow" value="New" name="btnName" onclick="NewWindow()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" value="Prescription" name="name" onclick="PrintoutPatient();" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" id="btnBackList" class="btn btn-gray" value="View" onclick="BackToList()" />
                    </div>
                       <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" id="Reffar_print" style="display:none" value="Reffaral Print" onclick="Reffared_printView();" />
                    </div>
                </div>
            </div>
                </div>
        </div>
        <div id="myResultModal" class="modal fade" role="dialog">

            <div class="modal-dialog">

                <div class="modal-content" style="width: 414px; margin-left: 296px;">
                    <div class="modal-header">
                        <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">View Test Images and Report</h4>
                    </div>
                    <div class="modal-body">

                        <table>
                            <tr>
                           
                                <td style="display:none;">
                                    <input type="hidden" name="labTestDetaiId" id="labTestDetails" value=' + labTestDetaiIds + '/>
                                      <input type="hidden" name="labTestIDs" id="labTestIDs" value=' + labTestID + '/> 
                                      <input type="hidden" name="billDetailID" id="billDetailIDs" value=' + billDetailId + '/> 
                                     <input type="hidden" name="TestIDs" id="TestID" value=' + testIds + '/> 
                                    <input type="hidden" name="ReportColumns" id="ReportColumn" value=' + reportCol + '/> 
                                </td>
                                <td>
                                    <div style="margin-top: -15px; margin-left: 38px;">

                                        <table border="0" cellpadding="0" cellspacing="5">
                                            <tr>
                                                <td>
                                                    <div id="errorMsg" class="formLabel" style="color: red; display: none">No Image Uploaded.</div>

                                                 
                                                    <div id="dvPreview" style="white-space: nowrap; overflow-x: visible; overflow-y: hidden; width: 260px;">
                                                    </div>

                                                </td>
                                            </tr>
                                        </table>
                                        <input type="button" style="width: 123px; margin-left: 45px;" id="btnResultPrint" value="View Print Report" onclick="ShowReport(this)" />
                                        <input type="hidden" id="hdnNewFiles" />
                                    </div>
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>

           <div id="PrintInPatientsReport" style="display: none;">

        <div style="height: 110px; padding-left:100px; -webkit-print-color-adjust: exact; width: 750px; margin: 0 auto;">

            <div style="padding: 5px;">
              <%--  <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 440px; height: 110px; margin-top: -113px; margin-left: 110px;">
                <div style="padding-top: 40px; font-size: 30px; color:darkblue;font-weight: bold; text-align: center;font-family:Calibri">
                   Arif Memorial Teaching Hospital 
                </div>
            </div>
        </div>
           <span style="float:right"><span style="padding-right:5px">Print Date:</span><%=DateTime.Now%></span>

          <table class="header_Table">
            <tr >
                <td class="Header_first_column_Lable">
                    <span>MR No :</span></td>
                <td class="header_lable_value">    
                     <span class="margintop" id="lblOPDNorpt"></span></td>
                <td class="header_lable"><span>Name:</span></td>
                <td class="header_lable_value"><span id="ctl00_MainContent_lblNamerpt"></span></td>
                <td class="header_lable">
                    <span>Father/Husband:</span>
                </td>
                <td class="header_lable_value">
               
                        <span id="lblFatherName"></span>
                    
                </td>              
                <td class="header_lable">
                    <span>Age:</span>
                </td>
                <td class="header_lable_value">
                          
                        <span id="lblAgerpt"></span>
                </td>
            </tr>
            <tr >
                         <td class="Header_first_column_Lable">
                    <span>Token No:</span>
                </td>
                <td class="header_lable_value">
                    
                        <span id="lblTokanNorpt"></span>
                   
                </td>
                <td class="header_lable">
                    <span>Contact:</span>
                </td>
                <td style ="width:150px"; class="header_lable_value">
                  
                        <span id="lblContactrpt"style="min-width:150px">></span>
                    
                </td>
                <td class="header_lable">
                    <span>Doctor:</span>
                </td>
                <td colspan="3" class="header_lable_value">
                        <span id="lblDoctorrpt"></span>
                </td>
            </tr>
            <tr>
                 <td class="Header_first_column_Lable">
                    <span>Presentaion:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblPresentationrpt"></span>
                </td>
                  <td class="header_lable">
                    <span>Gender:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblGenderrpt"></span>
                </td>
                
                <td class="header_lable">
                    <span>Dept:</span>
                </td>
                <td colspan="3" class="header_lable_value">
                        <span id="lblDepartmentrpt"></span>
                </td>
				 
            </tr>
            <tr>
                 <td  class="Header_first_column_Lable">
                    <span>Type:</span>
                </td>
                <td class="header_lable_value"> 
                        <span id="lblTyperpt"></span>
                </td>
                <td class="header_lable">
                    <span>Date/Time:</span>
                </td>
                <td style= "font-size:smaller"; "width: 125px"; class="header_lable_value">
                        <span id="lblDateTimerpt"style="min-width:150px">></span>
                </td>
                 <td class="header_lable">
                    <span>CNIC:</span>
                </td>
                <td  style= "width: 150px";  class="header_lable_value">
                        <span id="lblCNICrpt" style="min-width:150px"></span>
                </td>
                 <td class="header_lable">
                    <span>Charges:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblSlipChargesrpt"></span>
                </td>
            </tr>

            <tr>
               <td class="Header_first_column_Lable">
                    <span>Address:</span>
                </td>
                <td colspan="3" class="header_lable_value">
                   
                        <span id="lblAddressrpt"></span>
                </td>
				<td class="header_lable">
                    <span >F.up No:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblNumber"></span>
                </td>
                <td class="header_lable">
                    <span >Operator:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblOperatorrpt"></span>
                </td>
            </tr>
        </table>
           <hr style="margin-top: 30px;" />
        <table>
            <tr>
                <td style="width:250px">
        <h6 style="width: 200px; text-align: left; font-size: 20px;color:darkblue; font-size: 14px;font-family:Calibri">Vital Signs</h6>
                    </td>
                <td>
                    <table>
            <tr>
                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">Pulse</h6>
                </td>
                <td>
                    <h6 style="width: 40px;font-size: 14px; border-bottom: 1px dotted #000 !important;" id="lblPlus">
                    
                    </h6>
                </td>
                <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri">Temp</h6>
                </td>
                <td>
                    <h6 style="width: 40px;font-size: 14px; border-bottom: 1px dotted #000;">
                        <span id="lblTemp"></span>
                    </h6>
                </td>
                  <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri">Resp</h6>
                </td>
                <td>
                    <h6 style="width: 40px;font-size: 14px; border-bottom: 1px dotted #000;">
                        <span id="lblRespiration"></span>
                    </h6>
                </td>
                  <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">BP</h6>
                </td>
                <td>
                    <h6 style="width: 40px;font-size: 14px; border-bottom: 1px dotted #000;">
                        <span id="lblBP"></span>
                    </h6>
                </td>
                 <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">Weight</h6>
                </td>
                <td>
                    <h6 style="width: 40px;font-size: 14px; padding-left:5px; border-bottom: 1px dotted #000;">
                        <span id="lblWeight"></span>
                    </h6>
                </td>
            </tr>

        </table></td>
                </tr>
       </table>
              <hr/>
            <h6 style="width: 200px; text-align: left; font-size: 20px; color:darkblue;margin-top: 0px;font-size: 14px">Clinical History</h6>


            <table style="margin-top: -15px;">

                   <tr>
                                       <td>
                    <h6 style=" width: 80px;font-size: 14px;color:darkblue;font-family:Calibri; margin-left: 50px">Symptom</h6>
                </td>

                <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri; margin-left: 150px">Duration</h6>
                </td>
             
                  <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri; margin-left: 90px">D/M/Y</h6>
                </td>
            
                  <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 50px;font-size: 14px;color:darkblue;font-family:Calibri; margin-left: 165px">Remarks</h6>
                </td>
       
            </tr>
                </table>
             <%--<hr />--%>
               <table style="margin-top: 5px; border: 1px solid black; border-collapse: collapse; width: 1050px;" cellpadding="5" cellspacing="5" id="tblsymptom">
            </table>
           <table style="margin-top: -1px;">
                <tr>
                     <td>
                    <h6 style=" width: 200px;font-size: 14px;color:darkblue;font-family:Calibri">History Of Present Illness</h6>
                </td>
                <td>
                    <h6 style="width: 350px;font-size: 14px; border-bottom: 1px dotted #000 !important;" id="lblHistoryOfPresent">
                    </h6>
                </td>
                    </tr>
                 <tr>
                     <td>
                    <h6 style=" width: 200px;font-size: 14px;color:darkblue;font-family:Calibri">Drug History</h6>
                </td>
                <td>
                    <h6 style="width: 350px;font-size: 14px; border-bottom: 1px dotted #000 !important;" id="lblDrugHistory">
                    </h6>
                </td>
                    </tr>
                 <tr>
                     <td>
                    <h6 style=" width: 200px;font-size: 14px;color:darkblue;font-family:Calibri">Obstetric History</h6>
                </td>
                <td>
                    <h6 style="width: 350px;font-size: 14px; border-bottom: 1px dotted #000 !important;" id="lblObstetricHistory">
                    </h6>
                </td>
                    </tr>

            </table>
        
            <hr />
            

<div style=" width: 33%;  float: left;" id="div5" >
    <h6 style="color:darkblue;font-size: 14px;float:both;">Test Recommended </h6>
    <table style="margin-top: 20px; border: 1px solid black; border-collapse: collapse; float:both" cellpadding="5" cellspacing="5" id="tblTestRecommended">
        
   </table>
</div>
<div style=" width: 33%;  float: left;" id="div6" >
    
      <h6 style="color:darkblue;font-size: 14px;float:both;">Special Test </h6>
      <table style="margin-top: 20px; border: 1px solid black; border-collapse: collapse; float:left;" cellpadding="5" cellspacing="5" >
         
      </table>
</div>
<div style="float: left;" id="div7">
      <h6 style="color:darkblue;font-size: 14px;float:both;">Area Of Interest </h6>
      <table style="border: 1px solid black; border-collapse: collapse; float:both" cellpadding="5" cellspacing="5" id="tblAreaOf_Intrest"> 
      </table>
          
</div> 
<hr style="width: 100%;" />


<div id="div9">
       <h6 style="color:darkblue;font-size: 14px;float:both;">Eye</h6>      
</div>
<hr style="width: 100%" />

<h6 style="width: 350px; margin-top: 40px; color:darkblue;font-size: 14px;">Medicine </h6>
               <h2 style="color:red;font-weight:bold; margin-top:-30px; margin-left:20px; font-size:25px;">Rx:</h2>
                  <table style="margin-top: -15px;">
                   <tr>
                                       <td>
                    <h6 style=" width: 80px;font-size: 14px;color:darkblue;font-family:Calibri; margin-left: 50px">Name</h6>
                </td>

                <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri; margin-left: 270px">Dosage</h6>
                </td>
                  <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri; margin-left: 100px">Frequency</h6>
                </td>
                  <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 50px;font-size: 14px;color:darkblue;font-family:Calibri; margin-left: 175px">Duration(Days/Hours)</h6>
                </td>
            </tr>
                </table>
            <table style="margin-top: 5px; border: 1px solid black; border-collapse: collapse; width: 1050px;" cellpadding="3" cellspacing="3" id="tblMedicenerpt"> 
            </table>

<hr style="width: 100%" />


<div style=" width: 33%;  float: left;" id="div10" >
    
  <h6 style="color:darkblue;font-size: 14px;float:both;">Final DIgnosies</h6>
  <h6 style="border-bottom: 1px dotted #000; width:250px; text-align: center; margin-top: 15px; font-size: 14px; line-height: 14px;"><span id="txtFinal_Diagnosis"></span>
  </h6>
</div>
<div style=" float: left;" id="div11" >
     <h6 style="color:darkblue;font-size: 14px;float:both;">Advice</h6>
     <table style="border: 1px solid black; border-collapse: collapse; width: 480px;float:left" cellpadding="5" cellspacing="5" id="tblAdvice"> 
     </table>
</div>
<hr style="width: 100%;" />




<div style=" width: 33%;  float: left;" id="div12" >
    
  <h6 style="color:darkblue;font-size: 14px;float:both;">FollowUp</h6>
  <h6 style="border-bottom: 1px dotted #000; width: 145px; text-align: center; margin-top: 15px; font-size: 14px; line-height: 14px;"><span id="txtFollowUp"></span>
  </h6>
</div>
<div style=" float: left;" id="div13" >
     <h6 style="color:darkblue;font-size: 14px;float:both;">Follow Date</h6>
      <h6 style="border-bottom: 1px dotted #000; width: 145px; text-align: center; margin-top: 15px; font-size: 14px; line-height: 14px;"><span id="txtFollowDate"></span>
     </h6>
</div>


        </div>


        

    </div>
    <div id="myModalENT" class="modal fade" role="dialog">
  <div class="modal-dialog modal-lg modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal">&times;</button>
        <h4 class="modal-title">ENT</h4>
      </div>
      <div class="modal-body">
        <h4>Throat</h4>
        <div class="table-responsive">
          <table class="table">
            <tbody>
              <tr>
                <td>
                  <table class="table">
                    <tbody>
                      <tr>
                        <td width="195px">IDL</td>
                        <td><asp:TextBox runat="server" type="text" ID="txtmidl" /></td>
                      </tr>
                      <tr>
                        <td>Nose</td>
                        <td><asp:TextBox runat="server" type="text" ID="txtmNose" /></td>
                      </tr>
                      <tr>
                        <td><h4>Ear</h4></td>
                      </tr>
                      <tr>
                        <td>Right</td>
                        <td><asp:TextBox runat="server" type="text" ID="txtmRight" /></td>
                      </tr>
                      <tr>
                        <td>Left</td>
                        <td><asp:TextBox runat="server" type="text" ID="txtmLeft" /></td>
                      </tr>
                      <tr>
                        <td><h3>Tuning Fork Test</h3></td>
                      </tr>
                      <tr>
                        <td><h4>Rinnes</h4></td>
                      </tr>
                    </tbody>
                  </table>
                  <table class="table">
                    <tbody>
                      <tr>
                        <td><h5>Right Ear</h5></td>
                        <td></td>
                        <td><h5>Left Ear</h5></td>
                        <td></td>
                      </tr>
                      <tr>
                        <td>+ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkRightPos" />
                          <asp:TextBox CssClass="textComment mm"  runat="server" placeholder="+ve Right Ear Comments" ID="ComRightPos" />
                        </td>
                        <td>+ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkLeftPos" />
                          <asp:TextBox CssClass="textComment mm"  runat="server" placeholder="+ve Left Ear Comments" ID="ComLeftPos" />
                        </td>
                      </tr>
                      <tr>
                        <td>-ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkRightNeg" />
                          <asp:TextBox CssClass="textComment mm"  runat="server" placeholder="-ve Right Ear Comments" ID="ComRightNeg" />
                        </td>
                        <td>-ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkLeftNeg" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="-ve Left Ear Comments" ID="ComLeftNeg" />
                        </td>
                      </tr>
                      <tr>
                        <td>False</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkRightF" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="False Right Ear Comments" ID="ComRightF" />
                        </td>
                        <td>False</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkLeftF" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="False Left Ear Comments" ID="ComLeftF" />
                        </td>
                      </tr>
                      <tr>
                        <td>-ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkRightFNeg" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="-ve Right Ear Comments" ID="ComRightFNeg" />
                        </td>
                        <td>-ve</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkLeftFNeg" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="-ve Left Ear Comments" ID="ComLeftFNeg" />
                        </td>
                      </tr>
                      <tr>
                        <td><h4>Webber's</h4></td>
                      </tr>
                      <tr>
                        <td>Central</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkcentral" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="Central Comments" ID="ComCentral" />
                        </td>
                        <td>Lateralized</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkLateralized" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="Lateralized Comments" ID="ComLateralized" />
                        </td>
                      </tr>
                      <tr>
                        <td><h4>Investigation</h4></td>
                      </tr>
                      <tr>
                        <td>PTA</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkPTA" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="PTA Comments" ID="ComPTA" />
                        </td>
                        <td>Tympanometry</td>
                        <td>
                          <asp:CheckBox runat="server" ID="mchkTympanometry" />
                          <asp:TextBox CssClass="textComment mm" runat="server" placeholder="Tympanometry Comments" ID="ComTympanometry" />
                        </td>
                      </tr>
                    </tbody>
                  </table>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div id="dvENTHistory" class="table-responsive" style="overflow-y: auto; max-height: 300px;">
          <table class="table" id="tblENTHistory">
            <thead>
              <tr>
                <td colspan="20">
                  <h2>ENT History</h2>
                </td>
              </tr>
              <tr>
                <th>Print Report</th>
                <th>Date</th>
                <th>Status</th>
                <th>IDL</th>
                <th>Nose</th>
                <th>Ear Right</th>
                <th>Ear Left</th>
                <th>Rinnes Right Ear +ve</th>
                <th>Rinnes Right Ear -ve</th>
                <th>Rinnes Right Ear False</th>
                <th>Rinnes Right Ear -ve</th>
                <th>Rinnes Left Ear +ve</th>
                <th>Rinnes Left Ear -ve</th>
                <th>Rinnes Left Ear False</th>
                <th>Rinnes Left Ear -ve</th>
                <th>Webber's Central</th>
                <th>Webber's Lateralized</th>
                <th>Investigation PTA</th>
                <th>Tympanometry</th>
              </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>
      </div>
      <div class="modal-footer">
          <div class="row">
              <div class="col-lg-2 col-md-4 col-sm-6">
                  <input type="button" id="Button1" name="saveENT" value="Save" class="btn btn-primry" data-dismiss="modal" />
              </div>
          </div>
      </div>
    </div>
  </div>
</div>


    <div id="PsychiatryModel" class="modal fade" role="dialog" style="overflow-y: overaly;">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1060px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Psychiatry</h4>
                </div>
                <div class="modal-body">

                    <table style="padding: 15px; width: 960px;">
                        <tr>
                            <td colspan="6">
                                <h2>Assessment History & Examination </h2>
                            </td>
                        </tr>
                    </table>
                    <div id="PsychiatryTabs">
                        <ul>
                            <li><a href="#PsychiatryTab-1">Personal History</a></li>
                            <li><a href="#PsychiatryTab-2">Pre-Morbid Personality</a></li>
                            <li><a href="#PsychiatryTab-3">Family History</a></li>
                            <li><a href="#PsychiatryTab-4">Mental State Examination</a></li>
                            <li><a href="#PsychiatryTab-5">Physical Examination</a></li>
                            <li><a href="#PsychiatryTab-6">Formulation</a></li>
                        </ul>
                        <div id="PsychiatryTab-1">
                            <table style="margin-top: 40px;">
                                <tr>
                                    <td style="width:100px;">Informant(s):
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtInformant" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td style="width:140px;">Source Of Referral
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtSourceOfReferral" runat="server" TabIndex="16" Style="width:200% !important" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4"><b>
                                        <h2>Personal History</h2>
                                    </b></td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Early Development Milestones: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(a:) Neck Holding &nbsp;
                                    <asp:CheckBox ID="chkNeckHolding" runat="server" Style="position: relative; top: -17px;" />
                                    </td>
                                    <td colspan="2">(b:) Walking &nbsp;
                                    <asp:CheckBox ID="chkWalking" runat="server" Style="position: relative; top: -17px;" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(c:) Talking &nbsp;
                                    <asp:CheckBox ID="chkTalking" runat="server" Style="position: relative; top: -17px;" />
                                    </td>
                                    <td colspan="2">(d:) Others &nbsp;
                                      <asp:CheckBox ID="chkOthers" runat="server" Style="position: relative; top: -17px;" />
                                    </td>
                                </tr>


                                <tr>
                                    <td>Menarche
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtMenarche" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>Menstrual
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtMenstrual" runat="server" TabIndex="16" Style="width:203% !important" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Early Childhood: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(a:) &nbsp;      Attachment/ Separation from Parents
                                    </td>

                                    <td colspan="2">
                                        <asp:TextBox ID="txtAttachmentSeparationfromParents" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(b:) &nbsp;      Health(Serious Illness, Severe Fever, Operation)
                                    </td>
                                    <td colspan="2">
                                        <asp:TextBox ID="txtHealth" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Neurotic Traits:</h3>
                                    </td>
                                    <td>&nbsp;&nbsp;&nbsp;Nail Biting: 
                                     <asp:CheckBox ID="chkNailBiting" Style="position:relative;top:-17px" runat="server" />&nbsp;&nbsp;
    
                                         Temper Tantrums: 
                                         <asp:CheckBox ID="chkTemperTantrums" Style="position:relative;top:-17px" runat="server" />&nbsp;&nbsp;
    
                                         Bed Wetting: 
                                         <asp:CheckBox ID="chkBedWetting" Style="position:relative;top:-17px" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Schooling: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;                    Academics
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtAcademics" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:)Peer Relationship
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeerRelationship" runat="server" TabIndex="16" Style="width:200%" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Behaviour
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtBehaviour" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Occupational: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;                    History
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtOccupationalHistory" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;                    Marital/ Relationship/ Sexual History:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtMaritalRelationshipSexualHistory" Style="width:200%" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;                    Substance Use:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtSubstanceUse" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;                    Forensic Use:
                                    </td>

                                    <td>
                                        <asp:TextBox ID="txtForensicUse" Style="width:200%" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>

                            </table>
                        </div>

                        <div id="PsychiatryTab-2">
                            <table style="width: 860px;">
                                <tr>
                                    <td colspan="4">
                                        <h2>Pre-Morbid Personality: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Relationship:</td>
                                    <td>
                                        <asp:TextBox ID="txtRelationship" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Leisure Activities:</td>
                                    <td>
                                        <asp:TextBox ID="txtLeisureActivities" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Attitude to Self and Standards:</td>
                                    <td>
                                        <asp:TextBox ID="txtAttitudetoSelfandStandards" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Prevalling Mood:</td>
                                    <td>
                                        <asp:TextBox ID="txtPrevallingMood" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Reaction Pattren to Stress:</td>
                                    <td>
                                        <asp:TextBox ID="txtReactionPattrentoStress" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Religious Practices/ Attitute:</td>
                                    <td>
                                        <asp:TextBox ID="txtReligiousPracticesAttitute" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="PsychiatryTab-3">
                            <table style="width: 860px;">
                                <tr>
                                    <td colspan="4">
                                        <h2>Family History: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Father:</td>
                                    <td>
                                        <asp:TextBox ID="txtFather" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Mother:</td>
                                    <td>
                                        <asp:TextBox ID="txtMother" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Siblings:</td>
                                    <td>
                                        <asp:TextBox ID="txtSiblings" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Home Atmosphere, relationship, social class:</td>
                                    <td>
                                        <asp:TextBox ID="txtHomeAtmosphererelationshipsocialclass" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Familial Illness:</td>
                                    <td>
                                        <asp:TextBox ID="txtFamilialIllness" runat="server" TabIndex="16" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div id="PsychiatryTab-4">
                            <table>
                                <tr>
                                    <td colspan="4">
                                        <h2>MentalStateExamination: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Appearance: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td style="width:200px">(a:) &nbsp;       Actual and apparent age:</td>
                                    <td>
                                        <asp:TextBox ID="txtActualandapparentage" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td style="width:14%">(b:) &nbsp;      
                                    Race:</td>
                                    <td>
                                        <asp:TextBox ID="txtRace" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Tattoos, body piercing and scars:</td>
                                    <td>
                                        <asp:TextBox ID="txtTattoosbodypiercingandscars" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Body Habitus:</td>
                                    <td>
                                        <asp:TextBox ID="txtBodyHabitus" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Dress:</td>
                                    <td>
                                        <asp:TextBox ID="txtDress" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Hygiene:</td>
                                    <td>
                                        <asp:TextBox ID="txtHygiene" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Behaviour: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Psychomotor Activity:</td>
                                    <td>
                                        <asp:TextBox ID="txtPsychomotorActivity" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Involuntary movements:</td>
                                    <td>
                                        <asp:TextBox ID="txtInvoluntarymovements" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Dystonia & EPS:</td>
                                    <td>
                                        <asp:TextBox ID="txtDystoniaEPS" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Tardive dyskinesia:</td>
                                    <td>
                                        <asp:TextBox ID="txtTardivedyskinesia" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Tics:</td>
                                    <td>
                                        <asp:TextBox ID="txtTics" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Tremors:</td>
                                    <td>
                                        <asp:TextBox ID="txtTremors" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Co-operation: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Attentiveness to interview:</td>
                                    <td>
                                        <asp:TextBox ID="txtAttentivenesstointerview" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Eye Contact:</td>
                                    <td>
                                        <asp:TextBox ID="txtEyeContact" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Level of Consciousness:</td>
                                    <td>
                                        <asp:TextBox ID="txtLevelofConsciousness" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Speech of Talk: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Rate:</td>
                                    <td>
                                        <asp:TextBox ID="txtRate" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Rhythm:</td>
                                    <td>
                                        <asp:TextBox ID="txtRhythm" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Volume:</td>
                                    <td>
                                        <asp:TextBox ID="txtVolume" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Tone:</td>
                                    <td>
                                        <asp:TextBox ID="txtTone" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp; Modulation:</td>
                                    <td>
                                        <asp:TextBox ID="txtModulationvar" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Mood: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>(Usual Affect, Variation in Moods, Subjective/ Objective Mood) </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;       Depressed:</td>
                                    <td>
                                        <asp:TextBox ID="txtDepressed" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      
                                    Elated:</td>
                                    <td>
                                        <asp:TextBox ID="txtElated" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Irritable:</td>
                                    <td>
                                        <asp:TextBox ID="txtIrritable" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(d:) &nbsp;      Labile:</td>
                                    <td>
                                        <asp:TextBox ID="txtLabile" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Incongruent:</td>
                                    <td>
                                        <asp:TextBox ID="txtIncongruent" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(f:) &nbsp;      Blunting/ Flattening/ Apathy:</td>
                                    <td>
                                        <asp:TextBox ID="txtBluntingFlatteningApathy" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Suicidal Risk: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;      Thinking/ Premeditation:</td>
                                    <td>
                                        <asp:TextBox ID="txtThinkingPremeditation" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                    <td>(b:) &nbsp;      Plans:</td>
                                    <td>
                                        <asp:TextBox ID="txtPlans" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Actions:</td>
                                    <td>
                                        <asp:TextBox ID="txtActions" runat="server" TextMode="MultiLine"></asp:TextBox>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h2>Thoughts: </h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h2>Thought Process: </h2>
                                        (Usual Pattren of Thinkng; Views about Self, World and Others)
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp;      Preservative:</td>
                                    <td>
                                        <asp:TextBox ID="txtPreservative" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                    <td>(b:) &nbsp;      LoosAssociation:</td>
                                    <td>
                                        <asp:TextBox ID="txtLoosAssociation" runat="server" TextMode="MultiLine"></asp:TextBox>                                     
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp;      Tangentiaility:</td>
                                    <td>
                                        <asp:TextBox ID="txtTangentiaility" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                    <td>(d:) &nbsp;      Circumstantiality:</td>
                                    <td>
                                        <asp:TextBox ID="txtCircumstantiality" runat="server" TextMode="MultiLine"></asp:TextBox>                                     
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:) &nbsp;      Flight of Ideas:</td>
                                    <td>
                                        <asp:TextBox ID="txtFlightofIdeas" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <h3>Thought Content:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Thought Insertion
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtThoughtInsertion" runat="server" TextMode="MultiLine"></asp:TextBox>                                        
                                    </td>
                                    <td>(b:)&nbsp;Thought Withdrawal
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtThoughtWithdrawal" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Thought Broadcasting
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtThoughBroadcasting" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                   </td>
                                    <td>(d:)&nbsp;Thought Control
                                    </td>
                                    <td>
                                       <asp:TextBox ID="txtThoughControl" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;Dellusion:(Persecutory /Dellusion of refrence, Dellusion of control,Jealous, Erotomanic, Somatic, Grandious, Nihilistic,Bizarre, Sexual or amrous)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDellusion" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                  </td>
                                    <td>(f:)&nbsp;Overvalued Ideas
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtovervaluedideas" runat="server" TextMode="MultiLine"></asp:TextBox>                                   
                                    </td>
                                </tr>
                                <tr>
                                    <td>(g:)&nbsp;Depresonalization
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDepresonalization" runat="server" TextMode="MultiLine"></asp:TextBox>                                        
                                    </td>
                                    <td>(h:)&nbsp;Derealization
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtDerealization" runat="server" TextMode="MultiLine"></asp:TextBox>                                     
                                    </td>
                                </tr>
                                <tr>
                                    <td>(i:)&nbsp;Obsession
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougObsession" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                    <td>(j:)&nbsp;Phobies
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougPhobies" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                </tr>
                                <tr>
                                    <td>(k:)&nbsp;Homocidial Ideas
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtthrougHomocidialIdeas" runat="server" TextMode="MultiLine"></asp:TextBox>                                    
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Perception:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Illusion</td>
                                    <td>
                                        <asp:TextBox ID="txtillusion" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                    <td>(b:)&nbsp;Hallucination (Auditory, Visual, Olfactory, Gustatory, Tactile)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtHallucinationAuditoryVisualOlfactoryGustatoryTactile" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Cognitive Status: </h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;Orientation:Time
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtorientationtime" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>


                                    <td>(b:)&nbsp;Place
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtplace" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Person
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtperson" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                    <td>(d:)&nbsp;Attention & Concentration:Serial-7 Test
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtAttentionConcentrationSerial7Test" runat="server" TextMode="MultiLine"></asp:TextBox>                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;Or Days Of Week:(Reverse Order)
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtOrDaysOfWeekReverseOrder" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p>Memory:</p>
                                    </td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp; Immediate Memory
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtImmediatememory" runat="server" TextMode="MultiLine"></asp:TextBox>                                      
                                    </td>
                                    <td>(b:)&nbsp;Short Term:Recent Events
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtshorttermrecentevents" runat="server" TextMode="MultiLine"></asp:TextBox>                                     
                                    </td>
                                </tr>
                                <tr>

                                    <td>(c:)&nbsp;Adress Recall After 2 Minutes
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtadressrecallafter2minutes" runat="server" TextMode="MultiLine"></asp:TextBox>                                     
                                    </td>

                                    <td>(d:)&nbsp; Long Term :Remote Events
                                    </td>
                                    <td>
                                        <asp:TextBox ID="longtermremoteevents" runat="server" TextMode="MultiLine"></asp:TextBox>                                    
                                    </td>

                                </tr>
                                <tr>
                                    <td>(e:)&nbsp; Adress Recall After 5 Minutes
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtadressrecallafter5minues" runat="server" TextMode="MultiLine"></asp:TextBox>
                                      
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <p><i>General Infomation / Intelligence</i></p>
                                    </td>

                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;General knowledge Questions
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtgeneralknowledgequestion" runat="server" TextMode="MultiLine"></asp:TextBox>
                                     
                                    </td>
                                    <td>(b:)&nbsp;Simple Arthemetic Calculation
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtsimplearthemeticcalculation" runat="server" TextMode="MultiLine"></asp:TextBox>                                  
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;Abstraction /Concrete Thinking
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtabstrationconcertethinking" runat="server" TextMode="MultiLine"></asp:TextBox>
                                        
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>(a:)&nbsp;Insight:</h3>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtinsight" runat="server" TextMode="MultiLine"></asp:TextBox>
                                       
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Health Belief Model:</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>(a:)&nbsp;What name you give to your problem?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Problem" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(b:)&nbsp;What you think what caused your problem?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Caused" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(c:)&nbsp;What you think how it started?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Started" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(d:)&nbsp;What you think about the course the disease will take?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Course" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(e:)&nbsp;What type of treatment you prefer to take?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Treatment" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(f:)&nbsp;What will be effects of your disease on others around you?</td>
                                    <td>
                                        <asp:TextBox ID="txtHBM_Effects" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                            </table>
                        </div>

                        <div id="PsychiatryTab-5">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;">PLUSE</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_Pluse" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">B.P</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_BP" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">TEMPERATURE</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPE_Temperature" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Weight</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Weight" runat="server"></asp:TextBox></td>
                                    <td>Respiratory Rate</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_RespiratoryRate" runat="server"></asp:TextBox></td>
                                    <td>JAUNDICE</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Jaundice" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>ANEMIA</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Anemia" runat="server"></asp:TextBox></td>
                                    <td>CYANOSIS</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cyanosis" runat="server"></asp:TextBox></td>
                                    <td>CLUBBING</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Clubbing" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>JVP</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_JVP" runat="server"></asp:TextBox></td>
                                    <td>LYMPH NODES</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_LymphNodes" runat="server"></asp:TextBox></td>
                                    <td>EDEMA</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Edema" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>SYSTEMATIC EXAMINATION:</h2>
                                    </td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Respiratory:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Respiratory" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Cardiovascular:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cardiovascular" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Gastro-Intestinal:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Gastro_Intestinal" runat="server" TextMode="MultiLine"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>Cns Examiniation:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Observation:(Involuntary Movements / Gestures / Mannerism / Mobility)</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Observation" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Cranial Nerves:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Cranial_Nerves" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td colspan="6">
                                        <h3>Motor System:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Limb strength:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Limb_Strength" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                    <td>Spasticity, Flaccidity, or Fasciculations:</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Spasticity" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>SENSORY SYSTEM:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Position</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Position" runat="server"></asp:TextBox></td>
                                    <td>Vibration</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Vibration" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Stereognosis</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Stereognosis" runat="server"></asp:TextBox></td>
                                    <td>Pain</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Pain" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>REFLEXES:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Biceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Biceps" runat="server"></asp:TextBox></td>
                                    <td>Triceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Triceps" runat="server"></asp:TextBox></td>
                                    <td>Brachioradialis</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Brachioradialis" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Quadriceps</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Quadriceps" runat="server"></asp:TextBox></td>
                                    <td>Patellar</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Patellar" runat="server"></asp:TextBox></td>
                                    <td>Achilles</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Achilles" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Extensor Plantar Response</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Extensor" runat="server"></asp:TextBox></td>
                                    <td>Frontal Release Reflexes</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Frontal" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h3>CEREBELLAR SYSTEM:</h3>
                                    </td>
                                </tr>
                                <tr>
                                    <td>Finger_to_nose Test</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Finger" runat="server"></asp:TextBox></td>
                                    <td>Heel-to-shin Test</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Heel" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Rapid Alternating Movements</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Movements" runat="server"></asp:TextBox></td>
                                    <td>Gait</td>
                                    <td>
                                        <asp:TextBox ID="txtPE_Gait" runat="server"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td colspan="6">
                                        <h2>SIGNS OF MENINGEAL IRRITATION:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(a:) Neck Rigidity &nbsp;
                                    <asp:CheckBox ID="chkPE_Neck_Rigidity" Style="position:relative;top:-17px"  runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(b:) Kerning's Sign &nbsp;
                                    <asp:CheckBox ID="chkPE_Kerning_Sign" Style="position:relative;top:-17px" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="2">(c:) Brudzinki's Sign &nbsp;
                                     <asp:CheckBox ID="chkPE_Brudzinki_Sign" Style="position:relative;top:-17px" runat="server" />
                                    </td>
                                </tr>


                            </table>
                        </div>

                        <div id="PsychiatryTab-6">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 200px;">
                                        <h4>Summary:</h4>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Summary" runat="server" TextMode="MultiLine" Width="400px" Height="80px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>
                                        <h4>Diagnosis:</h4>
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Diagnosis" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis I:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisI" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Axis II:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisII" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis III:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisIII" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Axis IV:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisIV" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>Axis V:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_AxisV" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>
                                        <h4>Causation:</h4>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Predisposing Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PredisposingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Precipitating Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PrecipitatingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Prepetuating Factors:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_PrepetuatingFactors" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <h3>MANAGEMENT PLAN:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Investigation:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Investigation" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Treatment Plan:</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Medical:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Medical" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Psychological:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Psychological" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="2">
                                        <h3>Psychosocial Management:</h3>
                                    </td>

                                </tr>
                                <tr>
                                    <td>Major Issues:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Major_Issues" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Strengths and Weaknesses:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Strengths" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Management Goals:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Goals" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>Strategies and Interventions:</td>
                                    <td>
                                        <asp:TextBox ID="txtFor_Strategies" runat="server" TextMode="MultiLine" Width="400px"></asp:TextBox></td>
                                </tr>

                            </table>
                        </div>

                    </div>
                </div>
                <div class="modal-footer">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" id="Button4" class="btn btn-primry" name="saveENT" value="Save" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>




    <div id="EyeModel" class="modal fade" role="dialog" style="margin-left: 267px;">

        <div class="modal-dialog">

            <div class="modal-content" style="width: 729px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h2 class="modal-title">Eye</h2>
                </div>
                <div class="modal-body">
                    
                    <div>
                        <table style="width: 250px; float:left;" id="tbleyeType">
                            <tr>
                                <td>Eye Main Type
                                </td>
                                <td>Eye Sub Type
                                </td>
                                <td></td>
                                <td>Right  Eye 
                                </td>
                                <td>Left Eye  
                                </td>
                                <td></td>
                            </tr>
                            <tr>
                                <td>
                                    <select id="ddlEyeMainType"></select>
                                </td>
                                <td>
                                    <select id="ddlEyeSubType"></select>
                                </td>
                             
                                <td style="width:70px;"><label id='lblEye0'>VA</label></td>
                                <td style="width:70px;">
                                    <input type="text" id="txtRightEye0" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td style="width:70px;">
                                    <input type="text" id="txtLeftEye0" style="width: 50px !important; height: 29px;" />
                                </td>
                                
                            </tr>
                            <tr>
                               
                                <td style="width:70px;"><label id='lblEye1'>BCVA</label></td>
                                <td>
                                    <input type="text" id="txtRightEye1" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtLeftEye1" style="width: 50px !important; height: 29px;" />
                                </td>
                             </tr>
                            <tr>
                               
                                <td style="width:70px;"><label id='lblEye2'>VA with PH</label></td>
                                <td>
                                    <input type="text" id="txtRightEye2" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtLeftEye2" style="width: 50px !important; height: 29px;" />
                                </td>
                             </tr>
                            <tr>
                              
                                <td style="width:70px;"><label id='lblEye3'>VA e glasses</label></td>
                                <td>
                                    <input type="text" id="txtRightEye3" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtLeftEye3" style="width: 50px !important; height: 29px;" />
                                </td>
                             </tr>
                            <tr>
                                
                                <td style="width:70px;"><label id='lblEye4'>Near Vision</label></td>
                                <td>
                                    <input type="text" id="txtRightEye4" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtLeftEye4" style="width: 50px !important; height: 29px;" />
                                </td>
                             </tr>
                            <tr>
                                <td></td>
                                <td colspan="2">
                                    <input type="button" value="Add" id="btnAddEye" style="margin-top: -3px; width: 121px !important;" onclick="AddEyeRow()" />
                                </td>
                            </tr>
                        </table>


                        <table class="table table-border" style="width: 430px; float:left;" id="">
                            <tr>
                                <th colspan="4" style=" background-color:white !important; color:black;">Slit Lamp Exam</th>
                            </tr>
                            <tr>
                                <th colspan="2"><span style="font-weight:bold;">Anterior segment</span></th>
                                
                                <th colspan="2"><span style="font-weight:bold;">Posterior</span></th>
                            </tr>
                            <tr>
                                <td>
                                    <input type="text" id="txtInteriorRight0" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtInteriorLeft0" style="width: 50px !important; height: 29px;" />
                                </td>
                               
                                <td>
                                    <input type="text" id="txtPosteriorRight0" style="width: 50px !important; height: 29px;" />
                                </td>
                                <td>
                                    <input type="text" id="txtPosteriorLeft0" style="width: 50px !important; height: 29px;" />
                                </td>
                             </tr>
                            <tr>
                                <td>Right</td>
                                <td>Left</td>
                                <td>Right</td>
                                <td>Left</td>
                            </tr>
                        </table>
                       


                        <div id="Div4" style="overflow: scroll; width: 703px;">
                            <table class="table" id="tblEyes">
                                <thead>
                                    <th>Eye Main Type</th>
                                    <th>Eye Sub Type</th>
                                    <th>Description</th>
                                    <th>Right Eye</th>
                                    <th>Left Eye</th>
                                    <th>Actions</th>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>

                        <div id="dvEyeHistory" style="overflow: scroll; width: 703px;">
                            <table class="table" style="width: 688px; height: 30px; overflow: scroll;" id="tblEyesHistory">
                                <thead>
                                    <tr>
                                        <td colspan="21">
                                            <div id="EyeHistoryHeader">
                                                <h2>Eye History</h2>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <th>Status</th>
                                        <th>Eye Main Type</th>
                                        <th>Eye Sub Type</th>
                                        <th>Right Eye</th>
                                        <th>Left Eye</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>


                </div>
                <div class="modal-footer">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 co-sm-6">
                            <input type="button" id="Button3" name="saveENT" value="Save" class="btn btn-primry" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="myModalDerma" class="modal fade" role="dialog" style="margin-left: -135px;">

        <div class="modal-dialog">

            <div class="modal-content" >
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Derma</h4>
                </div>
                <div class="modal-body">
                    <h4>Skin</h4>


                    <table class="test-table">
                        <tbody>
                            <tr>
                                <td></td>
                                <td width="120px">Face
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaFace" /></td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Neck
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNeck" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Trunk
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaTrunk" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Upper Limb
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaUpperLimb" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>Lower Limb
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaLowerLimb" />
                                </td>
                            </tr>
                            <tr>
                                <td>&nbsp  </td>
                                <td>&nbsp   </td>
                                <td>&nbsp   </td>
                            </tr>
                            <tr>
                                <td>&nbsp  </td>
                                <td>&nbsp   </td>
                                <td>&nbsp   </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>

                        <tbody>
                            <tr>
                                <td width="120px">Flexures
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaFlexures" />
                                </td>
                            </tr>
                            <tr>
                                <td>Genitalias
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaGenitalias" />
                                </td>
                            </tr>
                            <tr>
                                <td>Hair
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaHair" />
                                </td>
                            </tr>
                            <tr>
                                <td>Nail
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNail" />
                                </td>
                            </tr>
                            <tr>
                                <td>Mucous Membrane
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaMucousMembrane" />
                                </td>
                            </tr>
                            <tr>
                                <td>Eyes
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaEyes" />
                                </td>
                            </tr>
                            <tr>
                                <td>Ears
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaEars" />
                                </td>
                            </tr>
                            <tr>
                                <td>Nose
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaNose" />
                                </td>
                            </tr>
                            <tr>
                                <td>Lips
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDermaLips" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <div id="dvDermaHistory" style="margin: 0 auto; margin-top: 0px;">
                        <table class="table" id="tblDermaHistory" style="display: block; overflow: scroll; height: 305px;">
                         
                            <thead>
                                <tr>
                                    <td colspan="20">
                                        <div id="tblDermaHistoryHeader">
                                            <h2 style="margin-left: -244px;">Derma History</h2>
                                        </div>
                                    </td>
                                </tr>
                                <tr>
                                    <th>Date</th>
                                    <th>Status</th>
                                    <th>DermaFace </th>
                                    <th>DermaNeck</th>
                                    <th>DermaTrunk </th>
                                    <th>DermaUpperLimb </th>
                                    <th>DermaLowerLimb</th>
                                    <th>DermaFlexures</th>
                                    <th>DermaGenitalias</th>
                                    <th>DermaHair</th>
                                    <th>DermaNail</th>
                                    <th>DermaMucousMembrane</th>
                                    <th>DermaEyes</th>
                                    <th>DermaEars</th>
                                    <th>DermaNose</th>
                                    <th>DermaLips</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>


                </div>

                <div class="modal-footer">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" id="Button2" name="saveENT" class="btn btn-primry" value="Save" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="myModalOrtho" class="modal fade" role="dialog">

        <div class="modal-dialog">

            <div class="modal-content" style="width: 1082px; margin-left: -73px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Ortho</h4>
                </div>
                <div class="modal-body">

                    <table>
                        <tbody>

                            <tr>
                                <td style="width: 100px">
                                    <asp:Label ID="Label20" runat="server" Text="Organ Name"></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlOrthoType" runat="server" Width="180px" AppendDataBoundItems="true" TabIndex="21">
                                    </asp:DropDownList>
                                </td>

                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <asp:Label ID="Label21" runat="server" Text="Organ Side"></asp:Label>
                                </td>
                                <td>
                                    <asp:DropDownList ID="ddlOrthoSide" runat="server" Width="180px" AppendDataBoundItems="true" TabIndex="21">
                                    </asp:DropDownList>
                                </td>
                            </tr>
                        </tbody>
                    </table>

                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 39%">
                                    <h2>History</h2>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtHistory" Style="width:105% !important" TextMode="MultiLine" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>

                                <td></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label22" runat="server" Text="DM"></asp:Label>

                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtDM" />

                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label23" runat="server" Text="HTN"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtHTN" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label24" runat="server" Text="IHD"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtIHD" />
                                </td>
                            </tr>

                        </tbody>
                    </table>

                    <table>
                        <tbody>
                            <tr>

                                <td style="width: 100px">
                                    <h2>Examination</h2>
                                </td>

                            </tr>

                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>

                                <td></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label25" runat="server" Text="Look"></asp:Label>

                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtLook" />

                                </td>
                            </tr>

                            <tr>

                                <td></td>
                                <td>
                                    <asp:Label ID="Label26" runat="server" Text="Feel"></asp:Label>

                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtFeel" />

                                </td>
                            </tr>

                            <tr>

                                <td></td>
                                <td>
                                    <asp:Label ID="Label27" runat="server" Text="Move"></asp:Label>

                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtMove" />

                                </td>
                            </tr>

                            <tr>

                                <td></td>
                                <td>
                                    <asp:Label ID="Label28"  runat="server" Text="Special Tests"></asp:Label>

                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtSpecial_Tests" />

                                </td>
                            </tr>

                            <tr>

                                <td></td>
                                <td>
                                    <h3>Neurology</h3>

                                </td>
                                <td></td>
                            </tr>
                        </tbody>
                    </table>

                    <table>
                        <tbody>
                            <tr>

                                <td></td>
                                <td></td>
                                <td style="width: 100px">
                                    <asp:Label ID="Label29" runat="server" Text="Sensory"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtSensory" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label30" runat="server" Text="Motor"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtMotor" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td></td>
                                <td>
                                    <asp:Label ID="Label31" runat="server" Text="Reflexes"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtReflexes" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table>
                        <tbody>
                            <tr>
                                <td style="width: 100px">
                                    <asp:Label ID="Label32" runat="server" Text="Vascular Status"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtVascularStatus" />
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <asp:Label ID="Label33" runat="server" Text="Others"></asp:Label>
                                </td>
                                <td>
                                    <asp:TextBox runat="server" type="text" ID="txtOthers" />
                                </td>
                            </tr>
                            <tr>
                                <td>

                                    <input type="button" class="btn btn-primry" id="btnAddOrtho" name="btnAddOrtho" value="Add" onclick="insertOrtho()" /></td>
                            </tr>
                        </tbody>
                    </table>
                    <table class="table" id="tblOrtho" style="display: block; width: 1040px;">
                        <thead>
                            <tr>
                                <th>Organ Name</th>
                                <th>Organ Side</th>
                                <th>DM </th>
                                <th>HTN</th>
                                <th>IHD</th>
                                <th>Look</th>
                                <th>Feel</th>
                                <th>Move</th>
                                <th>Special Tests</th>
                                <th>Treatment History</th>
                                <th>Sensory</th>
                                <th>Motor</th>
                                <th>Reflexes</th>
                                <th>Vascular Status</th>
                                <th>Others</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>

                </div>

                <div class="modal-footer">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" id="Button5" class="btn btn-primry" name="saveENT" value="Save" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div id="ModelPeads" class="modal fade" role="dialog" style="overflow-y: overaly;">
        <div class="modal-dialog">

            <div class="modal-content" style="width: 1060px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Peads</h4>
                </div>
                <div class="modal-body">
                    <div id="PeadsTabs">
                        <ul>
                            <li><a href="#PeadsTab-2">NICU</a></li>
                            <li><a href="#PeadsTab-1">Examination</a></li>
                        </ul>
                        <div id="PeadsTab-1">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;">Weight(kg)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_weight" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">Length(cm)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_Length" runat="server"></asp:TextBox></td>
                                    <td style="width: 110px;">H.C(cm)</td>
                                    <td style="width: 200px;">
                                        <asp:TextBox ID="txtPeads_HC" runat="server"></asp:TextBox></td>

                                </tr>
                                <tr>
                                    <td>General Appearance:</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_General_Appearance" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>(a:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Cyanosis" Text="Cyanosis" runat="server" />
                                    </td>
                                    <td>(b:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Jaundice" Text="Jaundice" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>(c:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Lethargy" Text="Lethargy" runat="server" />
                                    </td>
                                    <td>(d:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_Rash" Text="Rash" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Others:</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_Others" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>Head:</h2>
                                    </td>
                                </tr>
                                <tr>
                                          <td>
                                <asp:Label ID="lblHeptomogy" runat="server" Text="Heptomology"></asp:Label>
                            </td>
                            <td>
                                 <asp:TextBox ID="txtHeptomogy" runat="server" TextMode="MultiLine"></asp:TextBox>
                            </td>
                                        </tr>
                                 <tr>
                                          <td>
                                <asp:Label ID="lblsplenomegaly" runat="server" Text="splenomegaly"></asp:Label>
                            </td>
                            <td>
                                 <asp:TextBox ID="txtsplenomegaly" runat="server" TextMode="MultiLine"></asp:TextBox>
                            </td>
                                        </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Caput" Text="Caput" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Cephalhematoma" Text="Cephalhematoma" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">Anterior Fontanelle:
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Anterioropen" Text="Open" runat="server" Checked="false" onchange="Anterioropen_CheckedChangedOpen()" />
                                        <asp:RadioButton ID="rdbPeads_AnteriorClose" Text="Closed" runat="server" Checked="false" onchange="Anterioropen_CheckedChangedClose()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>CVS:</h2>
                                    </td>
                                </tr>

                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Dextrocardia" Text="Dextrocardia" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Bulging" Text="Bulging Precordium" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Murmur" Text="Murmur" runat="server" />
                                    </td>
                                    <td>Heart Sounds
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_HeartSound" runat="server"></asp:TextBox>
                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>RESP:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Nasal" Text="Nasal Flaring" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Recessions" Text="Recessions" runat="server" />
                                    </td>
                                    <td>Added Sounds
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_AddedSounds" runat="server"></asp:TextBox>
                                    </td>

                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>GIT:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">Abdomin:
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Flat" Text="Flat" runat="server" Checked="false" onchange="Abdomin_CheckedChangedFlat()" />
                                    </td>

                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Distended" Text="Distended" runat="server" Checked="false" onchange="Abdomin_CheckedChangedDistended()" /></td>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Scaphoid" Text="Scaphoid" runat="server" Checked="false" onchange="Abdomin_CheckedChangedScaphoid()" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Liver" Text="Liver: >3cm" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Spleen" Text="Spleen: >2cm" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Others
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_GITOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="6">
                                        <h2>CNS:</h2>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Sucking" Text="Sucking" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Rooting" Text="Rooting" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Moro" Text="Moro" runat="server" />
                                    </td>
                                    <td>Others
                                    </td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_CNSOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>

                                </tr>
                            </table>
                        </div>


                        <div id="PeadsTab-2">
                            <table style="width: 995px;">
                                <tr style="width: 990px;">
                                    <td style="width: 110px;">
                                        <h3>ANTENATAL</h3>
                                    </td>
                                    <td style="width: 200px;"></td>

                                    <td style="width: 110px;"></td>
                                    <td style="width: 200px;"></td>
                                    <td style="width: 110px;"></td>
                                    <td style="width: 200px;"></td>

                                </tr>
                                <tr>
                                    <td>(i:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_FullTerm" Text="Full Term" runat="server" /></td>
                                    <td>(ii:) &nbsp; 
                                        <asp:CheckBox ID="chkPeads_PreTerm" Text="Pre Term" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Date of Delivery</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_DateOfDelivery" runat="server"></asp:TextBox></td>
                                    <td>Time of Delivery</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_TimeOfDelivery" runat="server"></asp:TextBox></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_Booked" Text="Booked" runat="server" Checked="false" onchange="Antenatal_CheckedChangedBooked()" />

                                    </td>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_UnBooked" Text="UnBooked" runat="server" Checked="false" onchange="Antenatal_CheckedChangedUnBooked()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_DAIHandling" Text="DAI Handling" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_ANTURash" Text="Rash" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_PIH" Text="PIH" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_GDM" Text="GDM" runat="server" /></td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Vacinated" Text="Vacinated" runat="server" /></td>
                                </tr>
                                <tr>
                                    <td>Others</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_ANTOthers" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td>
                                        <h3>NATAL</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>Mode of Delivery</td>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_SVD" Text="SVD" runat="server" Checked="false" onchange="Natal_CheckedChangedSVD()" />

                                    </td>
                                    <td>
                                        <asp:RadioButton ID="rdbPeads_LSCS" Text="LSCS" runat="server" Checked="false" onchange="Natal_CheckedChangedLSCS()" />
                                    </td>
                                    <td id="TDPeadsEmergency" style="display: none;">
                                        <asp:RadioButton ID="rdbPeads_Emergency" Text="Emergency" runat="server" Checked="false" onchange="Natal_CheckedChangedEmergency()" />
                                    </td>
                                    <td id="TDPeadsElective" style="display: none;">
                                        <asp:RadioButton ID="rdbPeads_Elective" Text="Elective" runat="server" Checked="false" onchange="Natal_CheckedChangedElective()" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Place Of Delivery</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_PlaceOfDelivery" runat="server"></asp:TextBox></td>
                                    <td>Indication For LSCS</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_IndicationForLSCS" runat="server" TextMode="MultiLine"></asp:TextBox></td>
                                </tr>

                                <tr>
                                    <td>Apger Score:</td>
                                </tr>
                                <tr>
                                    <td>1 Min</td>
                                    <td>
                                        <asp:DropDownList ID="ddlPeads_apgerScore1min" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                        </asp:DropDownList></td>
                                    <td>5 Min</td>
                                    <td>
                                        <asp:DropDownList ID="ddlPeads_apgerScore5min" runat="server" Width="167px" AppendDataBoundItems="true" TabIndex="21">
                                        </asp:DropDownList></td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Resuscitation" Text="Resuscitation" runat="server" />
                                    </td>
                                </tr>

                                <tr>
                                    <td>Others</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_NatalOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                                <tr>
                                    <td>
                                        <h3>Post NATAL</h3>
                                    </td>
                                    <td></td>
                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Moaning" Text="Moaning" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_RespDistress" Text="Resp. Distress" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_PostNATALCyanosis" Text="Cyanosis" runat="server" />
                                    </td>

                                </tr>
                                <tr>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_Fits" Text="Fits" runat="server" />
                                    </td>
                                    <td>
                                        <asp:CheckBox ID="chkPeads_ReluctanceToFeed" Text="Reluctance To Feed" runat="server" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Others</td>
                                    <td>
                                        <asp:TextBox ID="txtPeads_PostNatalOthers" runat="server" TextMode="MultiLine"></asp:TextBox>
                                    </td>
                                </tr>
                            </table>
                            <div id="dvPeadsHistory" style="margin: 0 auto; margin-top: 0px;">
                                <table class="table" id="tblPeadsHistory" style="display: block; overflow: scroll;">
                                    
                                    <thead>
                                        <tr>
                                            <td colspan="160">
                                                <div id="tblPeadsHeader">
                                                    <h2 style="float: left;">Peads History</h2>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr>
                                            <th>Date</th>
                                            <th>Status</th>
                                            <th>Full Term</th>
                                            <th>Pre Term</th>
                                            <th>Date Of Delivery</th>
                                            <th>Time Of Delivery,</th>
                                            <th>Booked</th>
                                            <th>Un Booked</th>
                                            <th>DAI Handling</th>
                                            <th>Rash</th>
                                            <th>PIH</th>
                                            <th>GDM</th>
                                            <th>Vacinated</th>
                                            <th>Antenatal Others</th>
                                            <th>SVD</th>
                                            <th>LSCS</th>
                                            <th>Emergency</th>
                                            <th>Elective</th>
                                            <th>Place Of Delivery</th>
                                            <th>Indication For LSCS</th>
                                            <th>Apgar Score 1min</th>
                                            <th>Apgar Score 5min</th>
                                            <th>Resuscitation Needed</th>
                                            <th>Other Natal</th>
                                            <th>Moaning</th>
                                            <th>Resp. Distress</th>
                                            <th>Cyanosis</th>
                                            <th>Fits</th>
                                            <th>Reluctance To Feed</th>
                                            <th>Other Post Natal</th>
                                            <th>Weight(kg)</th>
                                            <th>Length(cm)</th>
                                            <th>H.C(cm)</th>
                                            <th>General Appearance</th>
                                            <th>Cyanosis</th>
                                            <th>Jaundice</th>
                                            <th>Lethargy</th>
                                            <th>Rash</th>
                                            <th>Others</th>
                                            <th>Caput</th>
                                            <th>Cephalhematoma</th>
                                            <th>Anterior Fontanelle Open</th>
                                            <th>Anterior Fontanelle Close</th>
                                            <th>Dextrocardia</th>
                                            <th>Bulging Precordium</th>
                                            <th>Murmur</th>
                                            <th>Heart Sound</th>
                                            <th>Nasal Flaring</th>
                                            <th>Recessions</th>
                                            <th>Added Sounds</th>
                                            <th>Abdomin Flat</th>
                                            <th>Abdomin Distended</th>
                                            <th>Abdomin Scaphoid</th>
                                            <th>Liver: >3cm</th>
                                            <th>Spleen:>2cm</th>
                                            <th>Others</th>
                                            <th>Sucking</th>
                                            <th>Rooting</th>
                                            <th>Moro</th>
                                            <th>Others</th>

                                        </tr>

                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>
                        </div>



                    </div>
                </div>
                <div class="modal-footer">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" id="Button6" name="saveENT" class="btn btn-primry" value="Save" data-dismiss="modal" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="printInfo" style="display: none">
        <div style="height: 125px; -webkit-print-color-adjust: exact;border:solid 1px; width: 750px; margin: 0 auto;">
            <div style="padding: 5px;float:left">
             <%--   <img height="105" width="120" src="images/HMIS_Icons/CPHLogoLatest.png" style="margin-top: -1px;">--%>
            </div>
             <div style="padding-top: 20px; font-weight: bold; float:left; text-align: center;">
                    <h1><% =AppConfig.Company_Name %></h1>
                 <h5>31-Km Ferozpur Road (Kahna Nou), Lahore.</h5>
             </div>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 1px; margin: 0 auto; height: 200px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px">Name</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -50px; margin-top: 0px; font-size: 14px">
                        <span id="NameInfo"></span>
                    </h6>
                </td>


                <td>
                    <h6 style="width: 50px; text-align: left; font-size: 20px; font-size: 14px">Age</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -16px; margin-top: 0px; font-size: 14px">
                        <span id="AgeInfo"></span>
                    </h6>
                </td>


                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -2px;">Gender</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; font-size: 20px; margin-left: -15px; margin-top: 0px; font-size: 14px">
                        <span id="GenderInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: 0px; font-size: 14px">CNIC</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: left; margin-top: -10px; margin-left: -10px; font-size: 14px; line-height: 14px;">
                        <span id="NICInfo"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 130px; text-align: left; margin-top: -25px; font-size: 14px">Address</h6>
                </td>
                <td colspan="3">
                    <h6 style="border-bottom: 1px dotted #000; width: 331px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px; line-height: 14px;">
                        <span id="AddressInfo"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -20px; font-size: 14px">Contact</h6>
                </td>
                <td>
                    <h6 style='border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -15px; margin-top: -20px; font-size: 14px; line-height: 14px;'>
                        <span id="ContactInfo"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="font-size: 14px; margin-top: -20px; width: 50px;">Presentaion</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: left; margin-top: -15px; margin-left: -10px; font-size: 14px; line-height: 14px;">
                        <span id="PresentationInfo"></span>
                    </h6>
                </td>

            </tr>

            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">MR No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -50px; margin-top: -12px; font-size: 14px">
                        <span id="MRNoInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 50px; text-align: left; margin-top: -20px; font-size: 14px">F.up No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -16px; margin-top: -10px; line-height: 14px; font-size: 14px;">
                        <span id="FupNoInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; margin-top: -25px; font-size: 14px">Dept</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -15px; margin-top: -10px; font-size: 14px">
                        <span id="DeptInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">Type</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -15px; margin-top: -10px; font-size: 14px; line-height: 14px;">
                        <span id="TypeInfo"></span>
                    </h6>
                </td>
            </tr>

            <tr>



                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">Date</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -50px; margin-top: -15px; font-size: 14px">
                        <span id="DateInfo"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 90px; text-align: left; margin-top: -20px; font-size: 14px">Token No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 95px; text-align: center; margin-left: -16px; margin-top: -20px; line-height: 14px; font-size: 14px;">
                        <span id="TnoInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; margin-top: -20px; font-size: 14px">Charges</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: center; width: 125px; margin-left: -16px; margin-top: -13px; line-height: 14px; font-size: 14px;">
                        <span id="chargesInfo"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -20px; font-size: 14px">Operator</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -20px; margin-top: -12px; font-size: 14px; line-height: 14px;">
                        <span id="optInfo"><%=AppConfig.UserName %></span>
                    </h6>
                </td>

            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px">Doctor Name</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: center; margin-left: -25px; margin-top: -25px; font-size: 14px">
                        <span id="DNameInfo"></span>
                    </h6>
                </td>
            </tr>

        </table>
    </div>
    



<div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="itemsModalLabel">Item Details</h3>
        
            </div>
            <div class="modal-body">
                <input type="text" id="searchInput" class="form-control search-input" placeholder="Search items...">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>Select</th>
                            <th>Item ID</th>
                            <th>Item Code</th>
                            <th>Description</th>
                            <th>Rate</th>
                        </tr>
                    </thead>
                    <tbody id="itemsTableBody">
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>


<div class="modal fade" id="testmodal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h3 class="modal-title" id="testmodalLabel">Item Details</h3>
             
            </div>
            <div class="modal-body">
                <input type="text" id="searchInput_test" class="form-control search-input" placeholder="Search items...">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>Select</th>
                            <th>Test ID</th>
                            <th>Test Name</th>
                        </tr>
                    </thead>
                    <tbody id="testLabletbody">
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-gray"  data-dismiss="modal" >Close</button>
            </div>
        </div>
    </div>
</div>


</asp:Content>

