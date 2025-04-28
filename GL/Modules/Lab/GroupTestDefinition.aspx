<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GroupTestDefinition.aspx.cs" Inherits="PMS.GroupTestDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
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

            }
            else {
                $('#tblDetail').hide();

            }

            debugger;
            GetGroupDepartments();
            GetPatientTypes();
            GetMainDepartments();
            var urlParams = new URLSearchParams(location.search);
           
            if (urlParams.get('DataValue_ID') != null) {
                debugger;
                addOrEdit = 'EDIT';
                datavalueID = urlParams.get('DataValue_ID');
                datavalueDescription = urlParams.get('DataValue_Description');
                reportColums = urlParams.get('Segment2');
                reportTime = urlParams.get('Segment3');
                Reporting_Day = urlParams.get('Segment4');
                Division = urlParams.get('Division');
                Fixed_Value = urlParams.get('Fixed_Value');
                Result_Value = urlParams.get('Result_Value');
                List_Value = urlParams.get('List_Value');
                Required_Value = urlParams.get('Required_Value');
                chkPayment = urlParams.get('chkPayment');
                Special_Test = urlParams.get('Special_Test');
                Group_Depart = urlParams.get('Group_Depart');
                $('#txtGroupTest').val(datavalueDescription);
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
            debugger;

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
            if ($(Rpt_Time).val() == '')
                reporthour = 0;
            if ($(Rpt_Day).val() == '')
                reporthour = 0;
            PageMethods.saveData(datavalueID, datavalueDescription, reportColums, Main_Department, reporthour, ipdData, opdData, addOrEdit, reportDay, FixedValue, Resultvalue, ListValue, ReqImage, TestDeprtment, chkPayment, chkSpecial_Test, onSuccess, onFail);
        }
        function GetMainDepartments(Division) {
            debugger;
            var options = '<option value="0">Select Department</option>';
            PageMethods.GetMainDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlMainDepartment').html(options);
                debugger;
                var urlParams = new URLSearchParams(location.search);
                
                if (urlParams.get('DataValue_ID') != null) {
                    if (Division == 'null' || Division == null) Division = 0;
                    debugger;
                    $('#ddlMainDepartment').val(Division);
                }
            });
        }
        function onSuccess() {
            alert('Saved Successfully');
            window.location.href = "GroupTestList.aspx";
        };
        function onFail() { alert('Error'); };

        function getSavedRates(datavalueID, patientType) {
            debugger;
            PageMethods.getSavedRates(datavalueID, patientType,
                function (d) {
                    debugger;
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
            debugger;
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
            debugger;
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
            debugger;
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
            debugger;
            if (confirm("Are you sure you want to delete")) {
                $($(reference).parents('tr')[0]).remove();

            }
        }
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <form id="grouptest">
        <div class="row">
                        <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Group Test Name </label>
                <input type="text" name="txtGroupTest" id="txtGroupTest" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12" id="tblMaster">
                <label>Report Columns</label>
                <select id="ddlrptColumns">
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

                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-10 col-xs-6">
                <label>Reporting Time:</label>
                <select id="Rpt_Day">
                    <option value="001">Hrs</option>
                    <option value="002">Days</option>
                </select>
            </div>
            <div class="col-lg-1 col-md-2 col-sm-2 col-xs-2">
                <label></label>
                <input type="number" step="1" min="1" id="Rpt_Time" style="width: 45px !important; margin-top: 25px; margin-left: -20px;" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Main Department</label>
                <select id="ddlMainDepartment"></select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Group Department</label>
                <select id="ddlGroup_Department">
                </select>
            </div>
            </div>

      
        <div class="row">
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Result Value</label>
                </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input class="form-check-input" type="checkbox" id="ChkResultvalue" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>List Value</label>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
            <input class="form-check-input" type="checkbox" id="ChkListValue" />
                </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Fixed Value</label>
            </div>
                <div class="col-lg-1 col-md-4 col-sm-6">
                <input class="form-check-input" type="checkbox" id="ChkFixedValue" />
                    </div>

            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Required img</label>
            </div>  
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input class="form-check-input" type="checkbox" id="chkRequirdImage" />
                </div>

            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Payment</label>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
             <input class="form-check-input" type="checkbox"  id="chkPayment" name="chkPayment" />
                </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <label>Special Test</label>
            </div>
             <div class="col-lg-1 col-md-4 col-sm-6">
            <input class="form-check-input" type="checkbox" id="chkSpecial_Test" name="chkSpecial_Test" />
                 </div>
        </div>

        <div class="row">
            <div class="col-lg-1 col-md-2 col-sm-4 col-xs-4">
            <input type="button" class="btn btn-primry" id="btnSave" value="Save" />
                </div>
        </div>


        <div class="row">
             <table id="tblDetail" class="table table-responsive">
           <tr>
               <td>
                   <div>
                       <legend>IPD Test Rates</legend>
                       <table class="table" id="IPD_Test_Rate_Table">
                           <thead>
                               <tr><a href="javascript:void(0)  "onclick="generateIPDRow()" style="width: 64%;" class="mb-5">Add More</a></tr>
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
               </td>
                <td>
                   <div>
                       <legend style=" margin-top: -2px; margin-left: 183px;">OPD Test Rates</legend>
                       <table class="table" id="OPD_Test_Rate_Table" style="width: 88%; margin-left: 189px;">
                           <thead>
                               <tr><a href="javascript:void(0)" onclick="generateOPDRow()" style="margin-left: 193px;">Add More</a></tr>
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
               </td>
           </tr>
       </table>    
   </div>
       
    </form>
</asp:Content>
