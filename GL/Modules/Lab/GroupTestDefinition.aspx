<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupTestDefinition.aspx.cs" Inherits="PMS.GroupTestDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/GroupTestDefinition.css" rel="stylesheet" />
    <script type="text/javascript">
        var datavalueID = 0;
        var datavalueDescription = '';
        var Patients_Categories = '';
        var Main_Department = '';
        var reportColums = '';
        var Division = '';
        var addOrEdit = 'ADD';
        var payment = '';
        var Special_Test = '';
        $(document).ready(function () {

            var bool = '<%= Convert.ToBoolean(is_admin_Test_Rate)%>'
            if (bool == "True") {
                $('#tblDetail').show();
                $('#txtRate').prop('disabled', false);
            }
            else {
                $('#tblDetail').hide();
                $('#txtRate').prop('disabled', true);
            }

            GetGroupDepartments();
            GetPatientTypes();
            GetMainDepartments();
            var urlParams = new URLSearchParams(location.search);
           
            if (urlParams.get('DataValue_ID') != null) {
                addOrEdit = 'EDIT';
                datavalueID = urlParams.get('DataValue_ID');
                datavalueDescription = urlParams.get('DataValue_Description');
                reportColums = urlParams.get('Segment2');
                reportTime = urlParams.get('Segment3');
                Reporting_Day = urlParams.get('Segment4');
                Division = urlParams.get('Division');
                rate = urlParams.get('Segment1');
                Fixed_Value = urlParams.get('Fixed_Value');
                Result_Value = urlParams.get('Result_Value');
                List_Value = urlParams.get('List_Value');
                Required_Value = urlParams.get('Required_Value');
                chkPayment = urlParams.get('chkPayment');
                Special_Test = urlParams.get('Special_Test');
                Group_Depart = urlParams.get('Group_Depart');
                var machineName = urlParams.get('machine_name');
                var standardName = urlParams.get('StandardName');
                machineName = (machineName && machineName != 'undefined' && machineName != 'null') ? machineName : '';
                standardName = (standardName && standardName != 'undefined' && standardName != 'null') ? standardName : '';
                $('#txtMachineName').val(machineName || '');
                $('#txtStandardName').val(standardName || '');
                $('#txtGroupTest').val(datavalueDescription);
                $('#txtRate').val(rate);
                $('#ddlrptColumns').val(reportColums);
                $('#Rpt_Time').val(reportTime);
                $('#Rpt_Day').val(Reporting_Day);
                if (Fixed_Value == "true") {
                    $("#ChkFixedValue").prop('checked', true);
                }
                if (Result_Value == "true") {
                    $("#ChkResultvalue").prop('checked', true);
                }
                if (List_Value == "true") {
                    $("#ChkListValue").prop('checked', true);
                }
                if (Required_Value == "true") {
                    $("#chkRequirdImage").prop('checked', true);
                }
                if (chkPayment == "true") {
                    $("#chkPayment").prop('checked', true);
                }
                if (Special_Test == "true") {
                    $("#chkSpecial_Test").prop('checked', true);
                }
                getSavedRates(datavalueID, 'IPD');
                getSavedRates(datavalueID, 'OPD');


                GetGroupDepartments(Group_Depart);
                GetMainDepartments(Division);


            }

            $('#btnSave').click(function () {
                saveData();
            });

        });

        function saveData() {

            var tblIPDList = document.getElementById('IPD_Test_Rate_Table');
            var ipdData = new Array();
            for (var i = 1; i < tblIPDList.rows.length; i++) {
                var ipdCategory = $('#ipdSelect' + i + '').val();
                var ipdRate = $('#ipdRate' + i + '').val();
                if (ipdCategory != null && ipdRate != null) {
                    ipdData[i] = new Array(ipdCategory, ipdRate);
                }
            }

            var tblOPDList = document.getElementById('OPD_Test_Rate_Table');
            var opdData = new Array();
            for (var i = 1; i < tblOPDList.rows.length; i++) {
                var opdCategory = $('#opdSelect' + i + '').val();
                var opdRate = $('#opdRate' + i + '').val();
                if (opdCategory != null && opdRate != null) {
                    opdData[i] = new Array(opdCategory, opdRate);
                }
            }
            datavalueDescription = $('#txtGroupTest').val();
            Main_Department = $('#ddlMainDepartment').val();
            reportColums = $("#ddlrptColumns").val();
            var FixedValue = $('#ChkFixedValue').prop('checked');
            var Resultvalue = $('#ChkResultvalue').prop('checked');
            var ListValue = $('#ChkListValue').prop('checked');
            var ReqImage = $('#chkRequirdImage').prop('checked');
            var chkPayment = $('#chkPayment').prop('checked');
            var chkSpecial_Test = $('#chkSpecial_Test').prop('checked');

            var TestDeprtment = $("#ddlGroup_Department").val();
            var reporthour = $("#Rpt_Time").val();
            var reportDay = $("#Rpt_Day").val();
            var machineName = $("#txtMachineName").val();
            var standardName = $("#txtStandardName").val();
            var TestRate = $('#txtRate').val();
            if ($(Rpt_Time).val() == '')
                reporthour = 0;
            if ($(Rpt_Day).val() == '')
                reporthour = 0;
            PageMethods.saveData(datavalueID, datavalueDescription, reportColums, Main_Department, reporthour, ipdData, opdData, addOrEdit, reportDay, FixedValue, Resultvalue, ListValue, ReqImage, TestDeprtment, chkPayment, chkSpecial_Test, machineName, standardName, TestRate,onSuccess, onFail);
        }
        function GetMainDepartments(Division) {
            var options = '<option value="0">Select Department</option>';
            PageMethods.GetMainDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainDepartment').html(options);
                var urlParams = new URLSearchParams(location.search);
                
                if (urlParams.get('DataValue_ID') != null) {
                    if (Division == 'null' || Division == null) Division = 0;
                    $('#ddlMainDepartment').val(Division);
                }
            });
        }
        function onSuccess() {
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'Saved Successfully.',
                showConfirmButton: false,
                timer: 2500,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
             window.location.href = "GroupTestList.aspx";
        };
        function onFail() { alert('Error'); };

        function getSavedRates(datavalueID, patientType) {
            PageMethods.getSavedRates(datavalueID, patientType,
                function (d) {
                    var data = JSON.parse(d);
                    
                    if (patientType == 'IPD') {
                        for (var i = 1; i <= data.length; i++) {
                            generateIPDRow();
                            $('#ipdSelect' + i + '').val(data[i - 1].Patient_Category);
                            $('#ipdRate' + i + '').val(data[i - 1].Test_Rate);
                        }
                    }
                    else {
                        
                        for (var i = 1; i <= data.length; i++) {
                            generateOPDRow();
                            $('#opdSelect' + i + '').val(data[i - 1].Patient_Category);
                            $('#opdRate' + i + '').val(data[i - 1].Test_Rate);
                        }
                    }
                }
                , onFail);
        }
        function GetGroupDepartments(d) {
            var options = '<option value="">Select Department</option>';
            PageMethods.GetGroupDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#ddlGroup_Department').html(options);
            });
        }
        function GetPatientTypes() {
            var options = '<option value="">Select Category</option>';
            $.ajax({
                type: "post",
                url: "GroupTestDefinition.aspx/GetPatientTypes",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {

                    $.each(JSON.parse(response.d), function (key, value) {

                        options += '<option value="' + value.DataValue_Name + '">' + value.DataValue_Description + '</option>'
                    });

                    Patients_Categories = options;
                },
                failure: function (response) {
                    alert("Error!!!");
                }
            });
        }

        function generateIPDRow() {
            var rowID = document.getElementById('IPD_Test_Rate_Table').rows.length - 1;
            var html = '<tr id = "ipdRow' + rowID + '">' +
                '<td><select style="width: 145px !important;" id = "ipdSelect' + rowID + '">' + Patients_Categories + '</select></td>' +
                '<td><input type="text" id="ipdRate' + rowID + '" style="width: 65px !important;"/></td>' +
                '<td><a href="javascript:void(0)" onclick="DeleteRate(this)">Delete</a>' +
                '</td>' +
                '</tr>';

            $('#IPD_Test_Rate_Table').append(html);
        }

        function generateOPDRow() {
            var rowID = document.getElementById('OPD_Test_Rate_Table').rows.length - 1;
            var html = '<tr id = "opdRow' + rowID + '">' +
                '<td><select style="width: 145px !important;" id = "opdSelect' + rowID + '">' + Patients_Categories + '</select></td>' +
                '<td><input type="text" id="opdRate' + rowID + '" style="width: 65px !important;"/></td>' +
                '<td><a href="javascript:void(0)" onclick="DeleteRate(this)">Delete</a>' +
                '</td>' +
                '</tr>';

            $('#OPD_Test_Rate_Table').append(html);
        }

        function DeleteRate(reference) {
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
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <form id="grouptest">
        <div class="gt-page">

            <div class="pr-meta-bar">
                <div class="meta-left">
                    <span class="meta-title"><i class="fa fa-object-group"></i> Group Test Definition</span>
                </div>
                <div class="meta-right"></div>
            </div>

            <div class="pr-primary-settings">
                <h5 class="pr-section-title"><i class="fa fa-info-circle"></i> Group Test Information</h5>
                <div class="row">
                    <div class="col-md-2 col-lg-2">
                        <label>Group Test Name</label>
                        <input type="text" name="txtGroupTest" id="txtGroupTest" class="form-control" />
                    </div>
                    <div class="col-md-2 col-lg-2" id="tblMaster">
                        <label>Report Columns</label>
                        <select id="ddlrptColumns" class="form-control">
                            <option value="2">2-Fixed Or DropDown</option>
                            <option value="3">3-DropDown and Fixed</option>
                            <option value="4">4-Table Range and Fixed</option>
                            <option value="5">5-Value Range Table</option>
                            <option value="6">6-Cutt Off</option>
                            <option value="7">7-Result Organism</option>
                            <option value="8">8-Altra Sound Fixed</option>
                            <option value="9">9-Value Range</option>
                            <option value="10">10-Blood Bank Report</option>
                            <option value="11">11-Fixed,Patient Value and Result Report</option>
                            <option value="12">12-Histopathology Report</option>
                            <option value="13">13-X-Ray Radiology Report</option>
                            <option value="14">14-Ct Scan Radiology Report</option>
                            <option value="15">15-MRI Radiology Report</option>
                            <option value="16">16-ECG Cardiology Report</option>
                            <option value="17">17-BioFire BioFire Test</option>
                            <option value="18">18-Diagnostic Blood Tests</option>

                        </select>
                    </div>
                    <div class="col-md-2 col-lg-2">
                        <label>Main Department</label>
                        <select id="ddlMainDepartment" class="form-control"></select>
                    </div>
                    <div class="col-md-2 col-lg-2">
                        <label>Group Department</label>
                        <select id="ddlGroup_Department" class="form-control">
                        </select>
                    </div>
                    <div class="col-md-2 col-lg-2">
                        <label>Machine Name</label>
                        <input type="text" name="txtMachineName" id="txtMachineName" class="form-control" />
                    </div>
                    <div class="col-md-2 col-lg-2">
                        <label>Standard Name</label>
                        <input type="text" name="txtStandardName" id="txtStandardName" class="form-control" />
                    </div>
                    <div class="col-md-2 col-lg-2">
                        <label>Rate</label>
                        <input type="number" id="txtRate" class="form-control" disabled="disabled" />
                    </div>
                    <div class="col-md-4 col-lg-4">
                        <label>Reporting Time</label>
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
                </div>
            </div>
      
            <div class="pr-primary-settings">
                <h5 class="pr-section-title"><i class="fa fa-check-square-o"></i> Options</h5>
                <div class="row">
                    <div class="col-md-12 gt-check-row">
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="ChkResultvalue" /> Result Value</label>
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="ChkListValue" /> List Value</label>
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="ChkFixedValue" /> Fixed Value</label>
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="chkRequirdImage" /> Required Img</label>
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="chkPayment" name="chkPayment" /> Payment</label>
                        <label class="gt-check"><input class="form-check-input" type="checkbox" id="chkSpecial_Test" name="chkSpecial_Test" /> Special Test</label>
                    </div>
                </div>
            </div>


            <div class="pr-primary-settings" id="tblDetail">
                <h5 class="pr-section-title"><i class="fa fa-money"></i> Test Rates</h5>
                <div class="row">
                    <div class="col-md-6 col-lg-6 col-sm-12">
                        <legend>IPD Test Rates</legend>
                        <div class="gt-rate-wrap">
                            <table class="table" id="IPD_Test_Rate_Table">
                                <thead>
                                    <tr><a href="javascript:void(0)" class="fa fa-plus iconAdd" onclick="generateIPDRow()" style="font-size: 18px;float: right;"></a></tr>
                                    <tr>
                                        <th style="width: 135px;">Patient Category</th>
                                        <th style="width: 72px;">Rate</th>
                                        <th style="width: 70px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="col-md-6 col-lg-6 col-sm-12">
                        <legend>OPD Test Rates</legend>
                        <div class="gt-rate-wrap">
                            <table class="table" id="OPD_Test_Rate_Table">
                                <thead>
                                    <tr> <a href="javascript:void(0)" class="fa fa-plus iconAdd" onclick="generateOPDRow()" style="font-size: 18px;float: right;"></a></tr>
                                    <tr>
                                        <th style="width: 135px;">Patient Category</th>
                                        <th style="width: 72px;">Rate</th>
                                        <th style="width: 70px;">Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-2 col-md-3 col-sm-6">
                    <input type="button" class="btn btn-primry" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-6">
                    <input type="button" name="back" class="btn btn-gray" value="View" onclick="location.href = 'GroupTestList.aspx'" />
                </div>
            </div>

        </div>
    </form>
</asp:Content>
