<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TestDefination.aspx.cs" Inherits="PMS.TestDefination" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/TestDefinition.css" rel="stylesheet" />
    <script type="text/javascript">
        function FillOutSourceLabs() {

            var options = '<option value="0" >Please Select</option>';

            PageMethods.GetOutSourceLabs(function (Labs) {
                $.each(JSON.parse(Labs), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlOutSourceLabs').html(options);


            });
        }
        function hideFields() {

            var SelectedDepartment = $('#ddlTestDpt').find('option:selected')[0].text;
            if (SelectedDepartment == "Radialogy") {

                $('#UnitRow').hide();
                $('#NoteRow').hide();
                $('#GroupDptRow').hide();
                $('#GropuCategoryRow').hide();

                PageMethods.FillTestMainDepartment(function (departments) {
                    var options = '<option value="">Select Department</option>';
                    $.each(JSON.parse(departments), function (key, value) {
                        if (value.DataValue_Name == "002" || value.DataValue_Name == "003" || value.DataValue_Name == "004") {
                            options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                        }
                    });

                    $('#main-departments').empty();
                    $('#main-departments').html(options);
                });

            }
            else if (SelectedDepartment == "Lab Test") {

                $('#UnitRow').show();
                $('#NoteRow').show();
                $('#GroupDptRow').show();
                $('#GropuCategoryRow').show();

                PageMethods.TestMainDepartmentDrpdwn(function (departments) {
                    var options = '<option value="">Select Department</option>';
                    $.each(JSON.parse(departments), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                    });

                    $('#main-departments').empty();
                    $('#main-departments').html(options);
                });

            }

            else if (SelectedDepartment == "Other Test") {

                $('#UnitRow').hide();
                $('#NoteRow').hide();
                $('#GroupDptRow').hide();
                $('#GropuCategoryRow').hide();

                PageMethods.FillTestMainDepartment(function (departments) {
                    var options = '<option value="">Select Department</option>';
                    $.each(JSON.parse(departments), function (key, value) {
                        if (value.DataValue_Name == "007") {
                            options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                        }
                    });

                    $('#main-departments').empty();
                    $('#main-departments').html(options);
                });

            }
            else if (SelectedDepartment == "Blood Bank") {


            }
            else {
                $('#UnitRow').hide();
                $('#NoteRow').hide();
                $('#GroupDptRow').hide();
                $('#GropuCategoryRow').show();
                PageMethods.FillTestMainDepartment(function (departments) {
                    var options = '<option value="">Select Department</option>';
                    $.each(JSON.parse(departments), function (key, value) {
                        if (value.DataValue_Name == "005" || value.DataValue_Name == "006") {
                            options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                        }
                    });

                    $('#main-departments').empty();
                    $('#main-departments').html(options);
                });
            }


        }
        function ShowReport() {
            debugger;
            var test_id = $('#test_id').val();
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + test_id);
        }
        function FillTestMainDepartment() {

            PageMethods.FillTestMainDepartmentDrpdwn(function (dpt) {
                var options = '<option value=""> Select Test Main Department </option>'
                $.each(JSON.parse(dpt), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#ddlTestDpt').html(options);
                var id = $('#ddlTestDpt').val();
                if (id == "005") $('#GropuCategoryRow').show();
                
            });
        }
        function FillGroupHeaderLevel1() {

            PageMethods.FillGroupHeaderLevel1(function (resp) {
                var options = '<option value="">Select Group Header L1</option>'
                $.each(JSON.parse(resp), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#ddlGroupHeader').html(options);
               
            });
        }
        function Altrasound_level() {

            PageMethods.FillAltrasound_level(function (resp) {
                var options = '<option value="">Select Format</option>'
                $.each(JSON.parse(resp), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });

                $('#ddlAltrasound_level').html(options);
                levelType = options;
              
            });
        }
        $(document).ready(function () {
            debugger;
            var bool = '<%= Convert.ToBoolean(is_admin_Test_Rate)%>'

            var boxhideshow = '<%= Convert.ToBoolean(is_admin_Test_box)%>'



            if (boxhideshow == "True") {

                $('#RateRow').show();
            }
            else {
                $('#RateRow').hide();
            }
            if (bool == "True") {
                $('#dvIPDRates').show();
                $('#dvOPDRats').show();
            }
            else {
                $('#dvIPDRates').hide();
                $('#dvOPDRats').hide();
            }


            FillTestMainDepartment();
            FillGroupHeaderLevel1();
            var id = getParameterByName('id');
            var mode = getParameterByName('mode');

            GetPatientTypes();
            fill_extra_test(id);
            GetPatientsCategories();
            FillOutSourceLabs();
            GETGenre();
            Altrasound_level();
            GETDesignation();
            if (id != null && id != '') {
                setTimeout(function () { GetTest(id); }, 3000);

            }
            else {
                debugger;
                GetMainDepartments();
                GetGroupDepartments();
                GetUnits();
                GetGroups();
            }

        });
        $(document).ready(function () {
            if (CKEDITOR) {
               
                CKEDITOR.replace('fixed_value');
                

            }
            //temparory data store
            $('#btn_Lab_Test_Multiple_Value').click(function () {
                if ($('#Lab_Test_Multiple_Value').val() != "") {
                    $('#myTable').append('<tr class="w3-hover-green"><td style="text-align:center;">' + $("#Lab_Test_Multiple_Value").val() + '</td><td style="text-align:center"><a href="" style="color:indianred;font-size:18px;"   onclick="test_delete(this)"><i class="fa fa-trash" aria-hidden="true"></i></a></td></tr>');
                    $("#Lab_Test_Multiple_Value").val("");
                }
            });
            $("#btnSave").on('click', function () {
                save_test();
            });
            $("#btnSaveUltrasound").on('click', function () {
                save_ultraSound();
            });
            $("#loadultraSounds").on('click', function () {
                debugger;
                PageMethods.GetUltraSound(function (res) {
                    debugger;
                    var test = JSON.parse(res);
                    var ckeditor = test;
                    var loadval = test;
                    var loadUltraSound = test;
                    var row = '';
                    groupKeys = '';
                    var i = 0;
                    for (i = 0; i < test.length; i++) {
                        debugger;
                        row = row + '<tr><td><input type="hidden" name="ultraSoundlevel_ID" id="ultraSoundlevel_ID" value="' + test[i].UltraSoundLevel_ID + '" /><select style="" name="levelvalue" id="ddllevelvalue' + (i + 1) + '">' + levelType + '</select></td><td><textarea id="txtfixedValueType' + (i + 1) + '" name="txtfixedValueType">' + test[i].FixValues + '</textarea></td><td style="width: 127px;"><input type="hidden" name="value_id" value=""><a href="javascript:void(0)" onclick="value_delete(this)" style="pointer-events: none;">Delete</a></td></tr>';
                    }
                    $('#TblUltra_Value').append(row);

                    for (var k = 0; k < ckeditor.length; k++) {
                        debugger;
                        groupKeys = ('txtfixedValueType' + (k + 1) + '');
                        CKEDITOR.replace(groupKeys, {
                            height: 50
                        });
                        CKEDITOR.instances['txtfixedValueType' + (k + 1) + ''].setData(ckeditor[k].FixValues);
                    }

                    for (i = 0; i < loadval.length; i++) {
                        $('#ddllevelvalue' + (i + 1) + '').val(loadval[i].Levels);
                    }
                    $("#loadultraSounds").attr('Disabled', true);
                });
            });
        });
        function save_ultraSound() {
            debugger;
            var Ultra_value = [];
            $('#TblUltra_Value tbody tr').each(function (key, value) {
                debugger;
                var myArray = {};
                var Data = CKEDITOR.instances['txtfixedValueType' + (key + 1) + ''].getData();
                var Levels = $(value).find('select[name="levelvalue"]').val();
                var UltraSoundLevelID = $(value).find('[name="ultraSoundlevel_ID"]').val();
                var FixValues = Data;

                myArray.Levels = Levels;
                myArray.FixValues = FixValues;
                myArray.UltrasoundLevelID = UltraSoundLevelID;
                Ultra_value.push(myArray);
            });
            PageMethods.SaveUltraSound((Ultra_value),
                function (res) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Has been Successfully Saved.',
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
        function test_delete() {
            $('#myTable tr').click(function () {
                $(this).remove();
                return false;
            });
        }
        function CollectedTableArray() {
            debugger;
            var ExpenseArray = [];
            $("table#myTable tbody tr").each(function () {
                debugger;
                var TempRow = [];
                TempRow[0] = $(this).find('td:eq(0)').text();
                ExpenseArray.push(TempRow);
            });
            return ExpenseArray;
        }
        function GetTest(id) {
            debugger;
            PageMethods.GetTest(id, function (res) {
                var test = JSON.parse(res);
                var data = test.t;
                var values = test.v;
                var IPDTestRates = test.IPDTestRate;
                var OPDTestRates = test.OPDTestRate;
                $('#test_id').val(data.Test_ID);
                $('#test_name').val(data.Test_Name);
                $('#chkvalue').prop('checked', data.Result_Type_Value);
                $('#chkLevel').prop('checked', data.Chk_Levels);

                $('#chkPayment').prop('checked', data.Payment);
                $('#chkSpecial_Test').prop('checked', data.Special_Test);

                $('#chktemplate').prop('checked', data.Result_Type_Fixed);
                $('#chklistchooseresult').prop('checked', data.Result_Type_List);
                debugger;
                $('#Test_cultural').prop('checked', data.Is_Cultural);
                $('#ddlrptColumns').val(data.Report_Colum);
                $('#chkimageUpload').prop('checked', data.Result_Type_Image);


                $('#ddlTestDpt').val(data.Group_Header_L0);
                $("#ddlGroupHeader").val(data.Group_Header_L1);
                $("#ddlAltrasound_level").val(data.Altrasound_Level);

                debugger;
                if (data.Main_Department != "001") {
                    $('#UnitRow').hide();
                    $('#NoteRow').hide();
                    $('#GroupDptRow').hide();
                    $('#GropuCategoryRow').hide();
                }
                if (data.Main_Department == "005") {
                    $('#UnitRow').show();
                    $('#NoteRow').show();
                    $('#GroupDptRow').show();
                    $('#GropuCategoryRow').show();

                }
                debugger;
                var outsourceid = "";
                outsourceid = data.Out_Source_Lab_ID;
                if (outsourceid == null) {
                    $("#ddlOutSourceLabs").val(0);
                }
                else {
                    $('#ddlOutSourceLabs').val(data.Out_Source_Lab_ID);
                }
              

                $('#Rpt_Time').val(data.Reporting_Time);
                $('#Rpt_Day').val(data.Reporting_Day);

                $('#txtOrder').val(data.Group_Order);

                GetMainDepartments(data.Main_Department);
                GetGroupDepartments(data.Group_Department);

                GetUnits(data.Unit);
                GetGroups(data.Group_Category);
                GETGenre(data.Genre);
                GETDesignation(data.Test_Designation);
                $("#ddlGroupHeader").val(data.Group_Header_L1);
                $('#txtQty').val(data.Qty);
                $('#test_note').val(data.Note);
                $('#test_rate').val(data.Rate);

                if (!data.Active) {
                    $('#test_active')[0].checked = false;
                }
                
                
                $('input:radio[value=fixed]').click();
                $('#fixed_value').val(data.Fixed_Value);

                CKEDITOR.instances.fixed_value.setData(data.Fixed_Value);

              
                var rows = '';
                $.each(values, function (key, value) {
                    rows += '<tr><td><input type="hidden" name="type" value="' + value.Patient_Type + '">' + value.Patient_Type_Name + '</td><td><input type="hidden" name="start" value="' + value.Start_Range + '">' + value.Start_Range + '</td><td><input type="hidden" name="end" value="' + value.End_Range + '">' + value.End_Range + '</td><td style="width:127px;"><input type="hidden" name="value_id" value="' + value.TestValue_ID + '"><a href="javascript:void(0)" onclick="value_edit(this)">Edit</a> | <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
                });
                $('#TestValues tbody').html(rows);

                var RowIPDRates = '';
                $.each(IPDTestRates, function (key, value) {
                    RowIPDRates += '<tr><td><input type="hidden" id="IPDPatientCategory" value="' + value.Patient_Category + '">' + value.Patient_Category_Name + '</td><td><input type="hidden" id="IPDTestRate" value="' + value.Test_Rate + '">' + value.Test_Rate + '</td><td><a href="javascript:void(0)" onclick="EditIPDTestRates(this)">Edit</a> | <a href="javascript:void(0)" onclick="DeleteIPDTestRates(this)">Delete</a></td></tr>'
                });
                $('#IPD_Test_Rate_Table tbody').html(RowIPDRates);

                var RowOPDRates = '';
                $.each(OPDTestRates, function (key, value) {
                    RowOPDRates += '<tr><td><input type="hidden" id="OPDPatientCategory" value="' + value.Patient_Category + '">' + value.Patient_Category_Name + '</td><td><input type="hidden" id="OPDTestRate" value="' + value.Test_Rate + '">' + value.Test_Rate + '</td><td><a href="javascript:void(0)" onclick="EditOPDTestRates(this)">Edit</a> | <a href="javascript:void(0)" onclick="DeleteOPDTestRates(this)">Delete</a></td></tr>'
                });
                $('#OPD_Test_Rate_Table tbody').html(RowOPDRates);

                $('#btnSave').val("Update");
            });
        }
        function GETGenre(d) {
            debugger;
            var options = '<option value="">Select Gener</option>';
            debugger;
            PageMethods.FillTestGenreDrpdwn(function (groups) {
                debugger;
                $.each(JSON.parse(groups), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#ddlGenre').html(options);
            });
        }
        function GETDesignation(d) {
            debugger;
            var options = '<option value="">Select Designation</option>';
            debugger;
            PageMethods.FillTestDesignationDrpdwn(function (groups) {
                debugger;
                $.each(JSON.parse(groups), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#ddlDesignation').html(options);
            });
        }
        function new_value() {

            var html = '<tr><td><select style="margin-left: 0px;">' + patientTypes + '</select></td><td><input type="text" name="start" required style="margin-left: 0px;"></td><td><input type="text" name="end" style="margin-left: 0px;"></td><td style="width: 127px;"><input type="hidden" name="value_id" value=""><a href="javascript:void(0)" onclick="value_save(this)">Save</a> | <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
            $('.values_table table tbody').append(html);
        }
        function Level_value() {
            debugger;
            var html = '';
            var rowlength = TblUltra_Value.rows.length;
            var fixedValRow = 'txtfixedValueType' + rowlength;
            html += '<tr><td><select style="margin-left: 20px;" name="levelvalue" id="ddllevelvalue' + rowlength + '">' + levelType + '</select></td><td><textarea id="txtfixedValueType' + rowlength + '" name="txtfixedValueType"></textarea></td><td style="width: 127px;"><input type="hidden" name="value_id" value=""><a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
            $('.Ultra_values_table table tbody').append(html);
            CKEDITOR.replace(fixedValRow, {
                height: 50
            });
        }
        function getParameterByName(name, url) {
            if (!url) url = window.location.href;
            name = name.replace(/[\[\]]/g, "\\$&");
            var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }
        var patientTypes = "";
        var levelType = "";
        function value_delete(row) {
            debugger;
            $($(row).parents('tr')[0]).remove();
        }
        function value_save(save) {
            debugger;
            var row = $(save).parents('tr')[0];
            var type = $(row).find('select');
            var start = $(row).find('input[name=start]');
            var end = $(row).find('input[name=end]');
            var value_id = $(row).find('input[name=value_id]');
            if ($(start).val() == '' && $(end).val() == '') {
                if ($(start).val() == '') $(start).addClass('ErrorAlert'); else $(start).removeClass('ErrorAlert');
                if ($(end).val() == '') $(end).addClass('ErrorAlert'); else $(end).removeClass('ErrorAlert');
            }
            if ($(type).val() == '') $(type).addClass('ErrorAlert'); else $(type).removeClass('ErrorAlert');

            if (!$(start).hasClass('ErrorAlert') && !$(end).hasClass('ErrorAlert') && !$(type).hasClass('ErrorAlert')) {

                type.parent().html('<input type="hidden" name="type" value="' + type.val() + '">' + type.find('option:selected').text());
                start.parent().html('<input type="hidden" name="start" value="' + start.val() + '">' + start.val());
                end.parent().html('<input type="hidden" name="end" value="' + end.val() + '">' + end.val());
                $(save).parent().html('<input type="hidden" name="value_id" value="' + value_id.val() + '"><a href="javascript:void(0)" onclick="value_edit(this)">Edit</a> | <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a>');
            }

        }
        function value_edit(edit) {
            debugger;
            var row = $(edit).parents('tr')[0];
            var type = $(row).find('input[name=type]');
            var start = $(row).find('input[name=start]');
            var end = $(row).find('input[name=end]');
            var id = $(row).find('input[name=value_id]');
            type.parent().html('<select>' + patientTypes + '</select>');
            start.parent().html('<input type="text" name="start" value="' + start.val() + '">');
            end.parent().html('<input type="text" name="end" value="' + end.val() + '">');
            $(edit).parent().html('<input type="hidden" name="value_id" value="' + id.val() + '"><a href="javascript:void(0)" onclick="value_save(this)">Save</a> | <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a>');
        }
        function save_test() {
            debugger;

            var chk_value = ($('#chkvalue')[0].checked).toString();
            var chk_template = ($('#chktemplate')[0].checked).toString();
            var chk_listchooseresult = ($('#chklistchooseresult')[0].checked).toString();
            var chk_resultTypeImage = ($('#chkimageUpload')[0].checked).toString();
            var chk_Levels = ($('#chkLevel')[0].checked).toString();
            var chk_Payment = ($('#chkPayment')[0].checked).toString();
            var Special_Test = ($('#chkSpecial_Test')[0].checked).toString();

            test_id = $('#test_id');
            test_name = $('#test_name');
            group_departments = $('#group-departments');
            main_departments = $('#main-departments');
            groups = $('#groups');
            units = $('#units');
            test_note = $('#test_note');
            value_type = $('[name=value_type]:checked');
            fixed_value = $('#fixed_value');
            test_active = $('#test_active');
            test_rate = $('#test_rate');
            SelectedDepartment = $('#ddlTestDpt').val();
            var SelectedDepartment = $('#ddlTestDpt').find('option:selected').val();
            var SelectedDepartmentID = $('#ddlTestDpt').find('option:selected').text();
            var out_source_lab_id = $("#ddlOutSourceLabs").val();
            var Group_Header_L1 = $("#ddlGroupHeader").val();
            var Altrasound_Level = $("#ddlAltrasound_level").val();
            genre = $("#ddlGenre");
            Designation = $("#ddlDesignation")
            var qty = $("#txtQty");
            if ($(qty).val() == '')
                qty = 0;
            var reporthour = $("#Rpt_Time").val();
            if ($(Rpt_Time).val() == '')
                reporthour = 0;
            var reportDays = $("#Rpt_Day").val();


            var GroupOrder = $("#txtOrder").val();
            if ($(txtOrder).val() == '')
                GroupOrder = 0;

            if (SelectedDepartmentID == "Radialogy") {
                if ($(main_departments).val() == '' && $(test_rate).val() == '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'please fill main department',
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
            }




            var valueofTemplate = CKEDITOR.instances.fixed_value.getData();


            if ($(test_name).val() == '') $(test_name).addClass('ErrorAlert'); else $(test_name).removeClass('ErrorAlert');
            if ($(main_departments).val() == '') $(main_departments).addClass('ErrorAlert'); else $(main_departments).removeClass('ErrorAlert');

            if (value_type.val() == 'fixed') { if (valueofTemplate == '') { $(fixed_value).addClass('ErrorAlert'); } else { $(fixed_value).removeClass('ErrorAlert'); } } else { $(fixed_value).removeClass('ErrorAlert'); }

            var test_values = [];
            $('#TestValues tbody tr').each(function (key, value) {
                test_values.push({ 'ID': $(value).find('td input[name=value_id]').val(), 'Type': $(value).find('td input[name=type]').val(), 'Start': $(value).find('td input[name=start]').val(), 'End': $(value).find('td input[name=end]').val() });
            });
            var Ultra_value = [];
            $('#TblUltra_Value tbody tr').each(function (key, value) {
                debugger;
                Ultra_value.push({
                    'Levels': $(value).find('select[name="levelvalue"]').val(),
                    'FixValues': $(value).find('textarea:input[name=txtfixedValueType]').val(),
                });
            });
            debugger;
            var IPD_Test_Rates = [];
            $('#IPD_Test_Rate_Table tbody tr').each(function (key, value) {
                IPD_Test_Rates.push({ 'Patient_Type': 'IPD', 'Patient_Category': $(value).find('td #IPDPatientCategory').val(), 'Test_Rate': $(value).find('td #IPDTestRate').val() });
            });

            debugger;
            var OPD_Test_Rates = [];
            $('#OPD_Test_Rate_Table tbody tr').each(function (key, value) {
                OPD_Test_Rates.push({ 'Patient_Type': 'OPD', 'Patient_Category': $(value).find('td #OPDPatientCategory').val(), 'Test_Rate': $(value).find('td #OPDTestRate').val() });
            });
            var test_extra_values = [];
            $('#myTable tbody tr').each(function (key, value) {
                debugger;
                var value = $(value).closest('tr').find('td:eq(0)').text();
                var arr = {};
                arr.value = value;
                test_extra_values.push(arr);
            });

            var labTest = { 'ID': $(test_id).val(), 'Name': $(test_name).val(), 'MainDepartment': $(main_departments).val(), 'GroupDepartment': $(group_departments).val(), 'Group': $(groups).val(), 'Unit': $(units).val(), 'Note': $(test_note).val(), 'ValueType': $(value_type).val(), 'Rate': $(test_rate).val(), 'Active': $(test_active)[0].checked, 'cultural': $(Test_cultural)[0].checked, 'reportColums': $("#ddlrptColumns").val(), 'FixedValue': valueofTemplate, 'TestValues': test_values, 'IPDTestRates': IPD_Test_Rates, 'OPDTestRates': OPD_Test_Rates, 'SelectedDepartment': SelectedDepartment, 'out_source_lab_id': out_source_lab_id, 'reporthour': reporthour, 'reportDays': reportDays, 'GroupOrder': GroupOrder, 'Genre': $(genre).val(), 'Qty': $(qty).val(), 'Designation': $(Designation).val(), 'Group_Header_L1': Group_Header_L1, 'Altrasound_Level': Altrasound_Level, 'chk_value': chk_value, 'chk_template': chk_template, 'chk_listchooseresult': chk_listchooseresult, 'chk_resultTypeImage': chk_resultTypeImage, 'UltraValues': Ultra_value, 'chk_Levels': chk_Levels, 'chk_Payment': chk_Payment, 'Special_Test': Special_Test };
            PageMethods.SaveTest(JSON.stringify(labTest), test_extra_values,
                function (res) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Has been Successfully Saved.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                     location.href = "TestDefinationList.aspx";
                    
                });
            
        }
        function GetGroups(d) {
            var options = '<option value="">Select Group</option>';
            PageMethods.GetGroups(function (groups) {
                $.each(JSON.parse(groups), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#groups').html(options);
            });
        }
        function GetGroupDepartments(d) {
            var options = '<option value="">Select Department</option>';
            PageMethods.GetGroupDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#group-departments').html(options);
            });
        }
        function GetMainDepartments(d) {
            debugger;
            var options = '<option value="">Select Department</option>';
            PageMethods.GetMainDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#main-departments').html(options);
            });
        }
        function GetUnits(u) {
            PageMethods.GetUnits(function (units) {
                var options = '<option value="">Select Unit</option>';
                $.each(JSON.parse(units), function (key, value) {
                    var unit = value.DataValue_Description;
                    if (unit.includes("^")) {
                        unit = unit.split("|");
                        var sup = unit[0].split("^");
                        unit = unit[0] + ' ' + unit[1];
                    }
                    options += '<option value="' + value.DataValue_Name + '" ' + (u == value.DataValue_Name ? 'selected' : '') + ' >' + unit + '</option>';
                });
                $('#units').html(options);
            });
        }
        function fill_extra_test(id) {
            debugger;
            PageMethods.GetExtratest(id, function (res) {
                debugger;
                var test = JSON.parse(res);
                var row = '';
                var i = 0;
                for (i = 0; i < test.length; i++) {
                    debugger;
                    row = row + '<tr><td style="text-align:center">' + test[i].Value + '</td><td style="text-align:center"><a href=""  onclick="test_delete(this)">Delete</a></td></tr>';
                }
                $('#myTable').append(row);
            });
        }
        function fill_ultraLevel(id) {
            debugger;
            PageMethods.GetUltraValues(id, function (res) {
                debugger;
                var test = JSON.parse(res);
                var ckeditor = test;
                var loadval = test;
                var loadUltraSound = test;
                var row = '';
                groupKeys = '';
                var i = 0;
                for (i = 0; i < test.length; i++) {
                    debugger;
                    row = row + '<tr><td><select style="margin-left: 20px;" name="levelvalue" id="ddllevelvalue' + (i + 1) + '">' + levelType + '</select></td><td><textarea id="txtfixedValueType' + (i + 1) + '" name="txtfixedValueType">' + test[i].FixValues + '</textarea></td><td style="width: 127px;"><input type="hidden" name="value_id" value=""><a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
                }

                $('#TblUltra_Value').append(row);

                for (var k = 0; k < ckeditor.length; k++) {
                    debugger;
                    groupKeys = ('txtfixedValueType' + (k + 1) + '');
                    CKEDITOR.replace(groupKeys, {
                        height: 50
                    });
                    CKEDITOR.instances['txtfixedValueType' + (k + 1) + ''].setData(ckeditor[k].FixValues);
                }

                for (i = 0; i < loadval.length; i++) {
                    $('#ddllevelvalue' + (i + 1) + '').val(loadval[i].Levels);
                }
            });
        }
        function GetPatientTypes(id) {
            PageMethods.GetPatientTypes(function (units) {
                var options = '<option value="">Select Type</option>';
                $.each(JSON.parse(units), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>';
                });
                patientTypes = options;
            });
        }
        var Patients_Categories = "";
        function GetPatientsCategories() {
            debugger;
            var options = '<option value="">Select</option>';
            $.ajax({
                type: "post",
                url: "TestDefination.aspx/PatientsCategories",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    $.each(JSON.parse(response.d), function (key, value) {
                        debugger;
                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>'
                    });
                    debugger;
                    Patients_Categories = options;
                },
                failure: function (response) {
                    alert("Error!!!");
                }
            });
        }
        function IPD_value() {
            debugger;
            var html = '<tr><td><select style="">' + Patients_Categories + '</select></td><td><input type="text" id="IPDTestRate" style=""/></td><td><a href="javascript:void(0)" onclick="SaveIPDTestRates(this)">Save</a> | <a href="javascript:void(0)" onclick="DeleteIPDTestRates(this)">Delete</a></td></tr>';

            $('#IPD_Test_Rate_Table').append(html);
        }
        function SaveIPDTestRates(save) {
            debugger;
            var Row = $(save).parents('tr')[0];
            var PatientCategory = $(Row).find('select');
            var TestRate = $(Row).find('#IPDTestRate');

            if ($(PatientCategory).val() == '') $(PatientCategory).addClass('ErrorAlert');
            else $(PatientCategory).removeClass('ErrorAlert');

            if ($(TestRate).val() == '') $(TestRate).addClass('ErrorAlert');
            else $(TestRate).removeClass('ErrorAlert');

            if (!$(PatientCategory).hasClass('ErrorAlert') && !$(TestRate).hasClass('ErrorAlert')) {
                debugger;
                PatientCategory.parent().html('<input type="hidden" id="IPDPatientCategory" value="' + PatientCategory.val() + '">' + PatientCategory.find('option:selected').text());
                TestRate.parent().html('<input type="hidden" id="IPDTestRate" value="' + TestRate.val() + '">' + TestRate.val());
                $(save).parent().html('<a href="javascript:void(0)" onclick="EditIPDTestRates(this)">Edit</a> | <a href="javascript:void(0)" onclick="DeleteIPDTestRates(this)">Delete</a>');
            }
        }
        function EditIPDTestRates(reference) {
            debugger;
            var Row = $(reference).parents('tr')[0];
            var PatientCategory = $(Row).find('#IPDPatientCategory');
            var TestRate = $(Row).find('#IPDTestRate');
            
            PatientCategory.parent().html('<select style="width: 115px !important;">' + Patients_Categories + '</select>');
            TestRate.parent().html('<input type="text" id="IPDTestRate" style="width: 65px !important;" value="' + TestRate.val() + '"/>');
            $(reference).parent().html('<a href="javascript:void(0)" onclick="SaveIPDTestRates(this)">Save</a> | <a href="javascript:void(0)" onclick="DeleteIPDTestRates(this)">Delete</a>');
        }
        function DeleteIPDTestRates(reference) {
            debugger;
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    $($(reference).parents('tr')[0]).remove();
                }
            });
            
        }
        function OPD_value() {
            debugger;
            var html = '<tr><td><select style="width: 100% !important;margin-left: 0px;">' + Patients_Categories + '</select></td><td><input type="text" id="OPDTestRate" style=""/></td><td><a href="javascript:void(0)" onclick="SaveOPDTestRates(this)">Save</a> | <a href="javascript:void(0)" onclick="DeleteOPDTestRates(this)">Delete</a></td></tr>';

            $('#OPD_Test_Rate_Table').append(html);
        }
        function SaveOPDTestRates(save) {
            debugger;
            var Row = $(save).parents('tr')[0];
            var PatientCategory = $(Row).find('select');
            var TestRate = $(Row).find('#OPDTestRate');

            if ($(PatientCategory).val() == '') $(PatientCategory).addClass('ErrorAlert');
            else $(PatientCategory).removeClass('ErrorAlert');

            if ($(TestRate).val() == '') $(TestRate).addClass('ErrorAlert');
            else $(TestRate).removeClass('ErrorAlert');

            if (!$(PatientCategory).hasClass('ErrorAlert') && !$(TestRate).hasClass('ErrorAlert')) {
                debugger;
                PatientCategory.parent().html('<input type="hidden" id="OPDPatientCategory" value="' + PatientCategory.val() + '">' + PatientCategory.find('option:selected').text());
                TestRate.parent().html('<input type="hidden" id="OPDTestRate" value="' + TestRate.val() + '">' + TestRate.val());
                $(save).parent().html('<a href="javascript:void(0)" onclick="EditOPDTestRates(this)">Edit</a> | <a href="javascript:void(0)" onclick="DeleteOPDTestRates(this)">Delete</a>');
            }
        }
        function EditOPDTestRates(reference) {
            debugger;
            var Row = $(reference).parents('tr')[0];
            var PatientCategory = $(Row).find('#OPDPatientCategory');
            var TestRate = $(Row).find('#OPDTestRate');
            PatientCategory.parent().html('<select style="width: 115px !important;">' + Patients_Categories + '</select>');
            TestRate.parent().html('<input type="text" id="OPDTestRate" style="width: 65px !important;" value="' + TestRate.val() + '"/>');
            $(reference).parent().html('<a href="javascript:void(0)" onclick="SaveOPDTestRates(this)">Save</a> | <a href="javascript:void(0)" onclick="DeleteOPDTestRates(this)">Delete</a>');
        }
        function DeleteOPDTestRates(reference) {
            debugger;
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    $($(reference).parents('tr')[0]).remove();
                }
            });
            
        }
        $(function () {
            $("#tabs").tabs();
        });
    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PatientDetail">
        <contenttemplate>
                <div class="row mb-3">
                    <div class="col-md-3 col-lg-3">
                        <label for="test_id">ID</label>
                        <div class="row">
                            <div class="col-md-4 col-lg-3">
                                <input type="text" id="test_id" class="form-control" readonly="readonly" value="(New)" />
                            </div>
                            <div class="col-md-7 col-lg-9">
                                <select id="ddlTestDpt" class="form-control" onchange="hideFields()">
                                    <option value="">Select Test Main Department</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="col-md-3 col-lg-3" id="TestNameRow">
                        <label for="test_name">Test Name</label>
                        <input type="text" id="test_name" class="form-control" required />
                    </div>

                    <div class="col-md-3 col-lg-3">
                        <label for="main-departments">Main Department</label>
                        <select id="main-departments" class="form-control">
                            <option value="">Select Department</option>
                        </select>
                    </div>


                    <div class="col-md-3 col-lg-3">
                        <label for="group-departments">Group Department</label>
                        <select id="group-departments" class="form-control">
                            <option value="">Select Department</option>
                        </select>
                    </div>
                </div>

                
                <div class="row mb-3">

                    <div class="col-md-3 col-lg-3">
                        <label>Group Category</label>
                        <select id="groups" class="form-control">
                            <option value="">Select Group</option>
                        </select>
                    </div>

                    <div class="col-md-3 col-lg-3">
                        <label>Unit</label>
                        <select id="units" class="form-control">
                            <option value="">Select Unit</option>
                        </select>
                    </div>

                    <div class="col-md-3">
                        <label>Out Source Labs</label>
                        <select id="ddlOutSourceLabs" class="form-control"></select>
                    </div>

                    <div class="col-md-3 col-lg-3">
                        <label>Rate</label>
                        <input type="text" name="test_rate" id="test_rate" class="form-control" value="" />
                    </div>

                </div>

            <div class="row mb-3">
                <div class="col-md-3 col-lg-3">
                    <label>Designation *</label>
                    <select id="ddlDesignation" class="form-control">
                    </select>
                </div>
                <div class="col-md-3 col-lg-3">
                    <label>Sample Genre</label>

                    <select id="ddlGenre" class="form-control"></select>
                </div>

                <div class="col-md-3 col-lg-3">
                    <label>Report Columns</label>
                    <select id="ddlrptColumns">
                        <option value="2">2-Fixed Or DropDown</option>
                        <option value="3">3-DropDown and Fixed</option>
                        <option value="4">4-Table Range and Fixed</option>
                        <option value="5">5-Value Range Table</option>
                        <option value="6">6-Cutt Off</option>
                        <option value="7">7-Result Organism</option>
                        <option value="8">8-Ultrasound Fixed</option>
                        <option value="9">9-Value Range</option>
                        <option value="10">10-Blood Bank Report</option>
                        <option value="11">11-Fixed,Patient Value and Result Report</option>
                        <option value="12">12-Histopathology Report</option>
                        <option value="13">13-X-Ray Radiology Report</option>
                        <option value="14">14-Ct Scan Radiology Report</option>
                        <option value="15">15-MRI Radiology Report</option>
                        <option value="16">16-ECG Cardiology Report</option>

                    </select>
                </div>

                <div class="col-md-6 col-lg-1">
                    <label>Quantity (ml)</label>
                    <input type="text" id="txtQty" class="form-control" />
                </div>

                <div class="col-md-6 col-lg-2">
                    <label>Order</label>

                    <input type="number" step="1" min="1" id="txtOrder" class="form-control" />
                </div>
            </div>

                
                <div class="row mb-3">
                    <div class="col-md-3 col-lg-3">
                        <label>Reporting Time:</label>
                        <div class="row">
                            <div class="col-md-6">
                                <input type="number" step="1" min="1" id="Rpt_Time" class="form-control" />
                            </div>
                            <div class="col-md-6">
                                <select id="Rpt_Day" class="form-control">
                                    <option value="001">Hrs</option>
                                    <option value="002">Days</option>
                                </select>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3 col-lg-3">
                        <label>Group Header L1</label>
                        <select id="ddlGroupHeader" class="form-control"></select>
                    </div>
                    <div class="col-md-2 col-lg-1">
                        <input type="checkbox" id="test_active" checked="checked" name="test_active" />
                        <label for="test_active">Active</label>
                    </div>
                    <div class="col-md-2 col-lg-1">
                        <input type="checkbox" id="Test_cultural" name="Test_cultural" />
                        <label for="Test_cultural">Is cultural</label>
                    </div>
                    <div class="col-md-2 col-lg-1">
                        <input type="checkbox" id="chkLevel" name="chkLevel" />
                        <label for="chkLevel">Ultrasound</label>
                    </div>
                    <div class="col-md-2 col-lg-1">
                        <input type="checkbox" id="chkPayment" name="chkPayment" />
                        <label for="chkPayment">Payment</label>
                    </div>
                    <div class="col-md-2 col-lg-1">
                        <input type="checkbox" id="chkSpecial_Test" name="chkSpecial_Test" />
                        <label for="chkSpecial_Test">Special Test</label>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-8 mb-4 col-lg-6 col-sm-12">
                        <div id="dvIPDRates">
                            <fieldset class="mt-n3">
                                <legend>IPD Test Rates</legend>
                                <a href="javascript:void(0)" class="fa fa-plus iconAdd" style="font-size: 20px;float:right;margin-top:-20px;" onclick="IPD_value()"></a>
                                <div class="table-responsive" style="max-height: 217px;">
                                    <table class="table" id="IPD_Test_Rate_Table">
                                        <thead>
                                            <tr>
                                                <th style="width: 135px;">Patient Category</th>
                                                <th style="width: 72px;">Rate</th>
                                                <th style="width: 103px;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                    <div class="col-md-8 mb-4 col-lg-6 col-sm-12">
                        <div id="dvOPDRats">
                            <fieldset class="mt-n3">
                                <legend>OPD Test Rates</legend>
                                <a href="javascript:void(0)" class="fa fa-plus iconAdd" style="font-size: 20px;float:right;margin-top:-20px;"  onclick="OPD_value()"></a>
                                <div class="table-responsive" style="max-height: 217px;">
                                    <table class="table" id="OPD_Test_Rate_Table">
                                        <thead>
                                            <tr>
                                                <th style="width: 135px;">Patient Category</th>
                                                <th style="width: 77px;">Rate</th>
                                                <th style="width: 103px;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </fieldset>
                        </div>
                    </div>
                </div>
            <div class="table-container">
                <div id="value_box" style="height: 42px!Important; margin: 9px;">
                    <span style="line-height: 36px; padding-left: 90px; font-size: 19px;">Test Result Possibility</span>
                </div>
                <div style="width: 850px">
                    <div id="tabs">
                        <ul>
                            <li><a href="#Tab-1">Value Range Result</a></li>
                            <li><a href="#Tab-2">Fixed Text Result</a></li>
                            <li><a href="#Tab-3">List Choose  Result</a></li>
                            <li><a href="#Tab-4">Image Upload</a></li>
                            <li><a href="#Tab-5">Ultrasound Format</a></li>
                        </ul>
                        <div id="Tab-5">
                            <div class="Ultra_values_table">
                                <fieldset>
                                    <input type="button" class="btn btn-primry" id="loadultraSounds" value="Ultrasound Format" style="width: auto !important;" />
                                    <a href="javascript:void(0)" style=" font-size: 20px; float: right;" class="fa fa-plus iconAdd" onclick="Level_value()"></a>
                                    <table id="TblUltra_Value" class="table">
                                        <thead>
                                            <tr>
                                                <th style="width: 229px;">Format</th>
                                                <th style="width: 458px;">Fix Value</th>
                                                <th style="width: 103px;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody></tbody>
                                    </table>
                                    <div class="col-lg-3">
                                        <input type="button" class="btn btn-primry" name="Save" id="btnSaveUltrasound" value="Save" />
                                    </div>
                                </fieldset>
                            </div>
                        </div>

                        <div id="Tab-1">

                            <div class="values_table">
                                <fieldset>
                                    <legend>Values: &nbsp;&nbsp;<input type="checkbox" id="chkvalue" name="chkvalue" /></legend>
                                    <a href="javascript:void(0)" style=" font-size: 20px; float: right;" class="fa fa-plus iconAdd" onclick="new_value()"></a>
                                    <table id="TestValues" class="table">
                                        <thead>
                                            <tr>
                                                <th style="width: 229px;">Patient Type</th>
                                                <th style="width: 229px;">Normal Range Start</th>
                                                <th style="width: 229px;">Normal Range End</th>
                                                <th style="width: 103px;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </fieldset>
                            </div>
                        </div>
                        <div id="Tab-2">
                            <div class="fixed_value">
                                <fieldset>
                                    <legend>Template: &nbsp;&nbsp;<input type="checkbox" id="chktemplate" name="chktemplate" /></legend>
                                    <textarea name="fixed_value" id="fixed_value"></textarea>
                                </fieldset>
                            </div>
                        </div>
                        <div id="Tab-3">
                            <fieldset>
                                <legend>List Choose Result: &nbsp;&nbsp;<input type="checkbox" id="chklistchooseresult" name="chklistchooseresult" /></legend>
                                <div>

                                    <div class="row mt-4">
                                        <div class="col-lg-8">
                                            <input type="text" id="Lab_Test_Multiple_Value" placeholder="Enter Value" />
                                        </div>
                                        <div class="col-lg-4">
                                            <input type="button" class="btn btn-primry" id="btn_Lab_Test_Multiple_Value" value="Add" />
                                        </div>
                                    </div>
                                </div>
                                <div style="overflow-y: auto; height: 140px!important">
                                    <table class="tab table" id="myTable">
                                        <thead>
                                            <tr>
                                                <th style="width: 200px;">Value </th>
                                                <th style="width: 120px;">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </div>
                            </fieldset>
                        </div>
                        <div id="Tab-4">
                            <fieldset>
                                <legend>Image Upoad &nbsp;&nbsp;<input type="checkbox" id="chkimageUpload" name="chkimageUpload" /></legend>
                            </fieldset>

                        </div>
                    </div>
                </div>
               <div class="row" style="margin-top:1%">
                   <div class="col-lg-8">
                       <div class="row">
                   <div class="col-lg-2 col-md-3 col-sm-6">
                         <input type="button" name="back" class="btn btn-gray" value="View" onclick="location.href = 'TestDefinationList.aspx'" />
                   </div>
                   <div class="col-lg-2 col-md-3 col-sm-6">
                            <input type="button" name="Save" class="btn btn-primry"  id="btnSave" value="Save"  />
                   </div>
               </div>
            </div>
            </div>
            </div>
        
        </contenttemplate>
    </div>
</asp:Content>
