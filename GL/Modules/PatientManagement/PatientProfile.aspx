<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientProfile.aspx.cs" Inherits="PMS.PatientProfile" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style type="text/css">
          div.token-input-dropdown {
    overflow: auto;
    max-height: 150px;
}
            ul.token-input-list {
                width: 168px;
            }

            .table {
                margin: 1em 0;
                width: 100%;
                overflow: hidden;
                background: #FFF;
                color: #024457;
            }

                .table tr {
                    border: 1px solid #D9E4E6;
                }

                    .table tr:nth-child(even) {
                        background-color: #EAF3F3;
                    }

                .table th {
                    display: none;
                    border: 1px solid #FFF;
                    background-color: #438eb9;
                    color: #FFF;
                    padding: 1em;
                }

                .table thead th {
                    display: table-cell;
                    text-align: center;
                }

            @media (min-width: 480px) {
                .table th:nth-child(2) span {
                    display: block;
                }

                .table th:nth-child(2):after {
                    display: none;
                }
            }

            .table td {
                display: block;
                word-wrap: break-word;
                max-width: 7em;
            }

                .table td:first-child {
                    display: table-cell;
                    text-align: center;
                    border-right: 1px solid #D9E4E6;
                }

            @media (min-width: 480px) {
                .table td {
                    border: 1px solid #D9E4E6;
                }
            }

            .table th, .table td {
                text-align: center;
                margin: .5em 1em;
            }

            @media (min-width: 480px) {
                .table th, .table td {
                    display: table-cell;
                    padding: 1em;
                }
            }
        </style>
    <script type="text/javascript">
        function FillTokenInputForMRNo() {
            var PatientID = $('#hdfPatient_ID').val();
            var CNIC = $('#txtCNIC').val();
            var ContectNo = $('#txtContectNo').val();




            if (PatientID == '') {
                tokenInputs('txtMRNo', 'Patients');
                
                tokenInputs('txtCNIC', 'PatientsByCNIC');
                tokenInputs('txtContectNo', 'PatientsByContectNO');

            }
            else {
                

                var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + CNIC);

                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });

                LoadPatientDetails();
            }
        }
        function tokenInputs(textboxID, tblName, OnAddFun) {
           
            $('#' + textboxID).tokenInput("json.aspx?Table=" + tblName,
             {
                 tokenLimit: 1,
                 onAdd:
                     function (item) {
                         try {
                             if (tblName == 'Patients') {
                                 alert(item.id);
                                $("#hdfPatient_ID").val(item.id);
                                 LoadPatientDetails();
                             }
                             if (tblName == 'PatientsByCNIC') {
                                 alert(item.id);
                                 $("#hdfPatient_ID").val(item.id);
                                LoadPatientDetails();
                             }
                             if (tblName == 'PatientsByContectNO') {
                                 alert(item.id);
                                 $("#hdfPatient_ID").val(item.id);
                                 LoadPatientDetails();
                             }

                         }
                         catch (err) {
                             alert(err.message);
                         }

                     }
             });
        }
        function LoadPatientDetails() {

            var Patient_ID = $('#hdfPatient_ID').val();
            alert(Patient_ID);
            $.ajax({
                type: "POST",
                url: "BillingProcess.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }
        function OnSuccess(data) {
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
            }
        }

        $(document).ready(function () {

            FillTokenInputForMRNo();

            $("#txtStartDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtEndDate").datepicker({ dateFormat: 'mm/dd/yy' });
           
        });
        function FetchRecommendedDetails() {

            var options = '<option value="0" >Select Follow No</option>';
            $('#hdfPatient_ID').val($('#txtMRNo').val())

            PageMethods.FetchRecommendedDetails($('#hdfPatient_ID').val(), function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    var FollowUp = key + 1;
                    options += '<option value="' + value.Patient_ID + '" >' + FollowUp + '</option>';
                });
                $('#ddlFollowUp').html(options);
                //$('#ddlDoctor').select2();                    
            });
        }

        function FetchAllPatientData() {


            PageMethods.FetchRecommendedDetails($('#ddlFollowUp').val(), function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    var FollowUp = key + 1;
                    options += '<option value="' + value.Patient_ID + '" >' + FollowUp + '</option>';
                });
                $('#ddlFollowUp').html(options);
                //$('#ddlDoctor').select2();                    
            });
        }

        function LoadTestsHistory() {


            $('#divTest').show();
            $('#divMedication').hide();
            PageMethods.GetTestListForHistory($('#hdfPatient_ID').val(), function (res) {
                var test = JSON.parse(res);
                var rows = '';

                $.each(test, function (key, value) {
                    if (value.L_R_Rotation_ID == null)
                        value.L_R_Rotation_ID = "";
                    var timeStamp = parseInt(value.Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                    var Result = 'Pendding';
                    var Sample = 'No';
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
                            row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"> <input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                        }
                        else {

                            if (value.Department_ID == "003") {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /><input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/> <input type="hidden" name="txtRotation" value="' + value.Rotation_ID + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + value.L_R_Rotation_ID + '"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.DataValue_Description == null ? ' ' : ', ' + value.DataValue_Description) + ',' + value.L_R_Rotation_ID + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                            }

                            else {
                                row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td> <td>' + value.Status + '</td> <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_Type + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="0"><input type="hidden" name="txtDeptID" value="' + value.Department_ID + '"/> ' + (value.DepartmentName == null ? '' : value.DepartmentName + ', ') + ' ' + value.Test_Name + ' ' + (value.Rotation == null ? ' ' : ', ' + value.Rotation) + '</td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';

                            }
                        }
                    }
                    else {
                        row = '<tr><td><input type="hidden" name="testDate" value="' + date + '">' + date + '</td><td>' + value.Status + '</td>  <td><input type="hidden" name="testID" value="' + value.Test_ID + '" /> <input type="hidden" name="txtValueType" value="' + value.Value_TypeGroup + '"/><input type="hidden" name="txtRecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="txtRotation" value="0"><input type="hidden" name="txtGroupCategory" value="' + value.Catagory_ID + '"/><input type="hidden" name="txtDeptID" value="' + value.Dept_ID + '"/>' + (value.TestMainDepartmentName == null ? '' : value.TestMainDepartmentName + ', ') + ' ' + value.Group_Name + ' </td><td>' + Sample + '</td><td>' + (value.Is_Result == true ? '<a href="javascript:void(0)"onclick="EditResultInPatient(this)" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + Result + '</a>' : Result + '') + ' </td><td> <input type="hidden" name="txtSpecial_Test" value="' + value.Special_Tests + '"/> ' + value.Special_Tests + '  </td><td><input type="hidden" name="txtArea_Of_Interest" value="' + value.Area_Of_Interest + '"/> ' + value.Area_Of_Interest + ' </td><td>' + value.DoctorName + ' <input type="hidden" name="Docid" value="' + value.Doctor + '" </td> </tr>';
                    }
                    $('#tblHistoryTests tbody').append(row);
                });
            });
            // }
        }
        function EditResultInPatient(anchor) {

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
        function ShowReport() {
            var table_tds = $('.test-table tr:not(:first)').find('#valuetype[value=table]').closest('tr').find('td:nth-child(3)');
            var fixed_tds = $('.test-table tr:not(:first)').find('#valuetype[value=fixed]').closest('tr').find('td:nth-child(3)');
            var valueType = $('#type').val();
            var tids = $('#IDtest').val();
            tids = tids.replace(/,+$/g, '');
            if (valueType == "table") {

                window.open('ReportViewer.aspx?ReportName=TestResult&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }

            if (valueType == "fixed") {

                window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + tids);
            }
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


                    var dd = "LabTestImg\\" + value.Image_path;
                    img.attr("src", dd);
                    dvPreview.append(img);

                    if (value.Image_path == null || value.Image_path == "" || value.Image_path == "undefined") {
                        $("#errorMsg").show();
                    }
                    else { $("#errorMsg").hide(); }

                });

            });
        }

        function LoadAllMedicationHistory() {
            $('#divTest').hide();
            $('#divMedication').show();
            PageMethods.LoadMedicinesForHistory($('#hdfPatient_ID').val(), function (res) {
                var Medicines = JSON.parse(res);
                var rows = '';
                $.each(Medicines, function (key, value) {
                    if (value.DoctorName == null)
                        value.DoctorName = "";

                    var timeStamp = parseInt(value.Medicine_Date.substr(6, 10));
                    var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');

                    rows += '<tr> <td> ' + date + ' </td><td>' + value.Status + '</td><td> ' + value.Medicine_Name + ' </td> <td> ' + value.Recomended_Dosage + ' </td><td> ' + value.Frequency + ' </td> <td> ' + value.Oral + ' </td><td> ' + value.Injections + ' </td> <td>' + value.DoctorName + '</td> </tr>';
                });
                $('#tblHistoryMedication tbody tr').remove();
                $('#tblHistoryMedication tbody').html(rows);
                $('#HeaderHistoryMedication').html('<h2>Previous History</h2>');
            });

        }
        </script>


     <div id="header">
         <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />

            <table style="width: 819px; height: 187px;">
               
                <tr>
                    <td>
                        <label>
                            MR No *:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtMRNo" onchange="FetchRecommendedDetails()"/>

                    </td>
                    <td>
                        <label>
                            Follow No:
                        </label>
                    </td>
                    <td>
                         <select id="ddlFollowUp" onchange="FetchAllPatientData()"></select>
                    </td>
                </tr>
                 <tr>
                    <td>
                        <label>
                            CNIC *:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtCNIC" onchange="FetchRecommendedDetails()"/>

                    </td>
                    <td>
                        <label>
                            Contect No:
                        </label>
                    </td>
                    <td>
                         <input type="text" id="txtContectNo" onchange="FetchRecommendedDetails()"/>
                    </td>
                </tr>
                 <tr>
                    <td>
                        <label>
                            Start Date *:
                        </label>
                    </td>
                    <td>
                        <input type="text" id="txtStartDate" onchange="FetchRecommendedDetails()"/>

                    </td>
                    <td>
                        <label>
                            End Date:
                        </label>
                    </td>
                    <td>
                         <input type="text" id="txtEndDate" onchange="FetchRecommendedDetails()"/>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Patient Name :	</label>
                    </td>
                    <td>
                        <label id="lblPatienName"></label>
                    </td>
                    <td>
                        <label>Contact No :	</label>
                    </td>
                    <td>
                        <label id="lblContactNo"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Reg. Date :	</label>
                    </td>
                    <td>
                        <label id="lblRegDate"></label>
                    </td>
                    <td>
                        <label>Gender  :	</label>
                    </td>
                    <td>
                        <label id="lblGender"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Age Years :	</label>
                    </td>
                    <td>
                        <label id="lblAgeYears"></label>
                    </td>
                    <td>
                        <label>Address   :	</label>
                    </td>
                    <td>
                        <label id="lblAddress"></label>
                    </td>
                </tr>
                <tr>
                    <td>
                        <label>Patient Category :	</label>
                    </td>
                    <td>
                        <label id="lblPatientCategory"></label>
                    </td>
                    <td>
                        <label>Department  :	</label>
                    </td>
                    <td>
                        <label id="lblDepartment"></label>
                    </td>
                </tr>
                
            </table>
        </div>
        <div id="divTest" style="width: 1143px; overflow: scroll; height: 280px;display:none">
                        <table style="margin-left: -1px; margin-top: 10px;" id="dvHistoryTests">
                            <tr>
                                <td>
                                    <table class="table" id="tblHistoryTests" style="WIDTH: 1126PX;">
                                        <thead>
                                            
                                            <tr>
                                                <th>Date</th>
                                               <th style="width: 84px;">Status</th>
                                                <th style="width: 418px;">Test Name</th>
                                                <th style="width: 71px;">Sample Received</th>
                                                <th>Result</th>
                                                <th>Special Tests</th>
                                                <th>Area Of Interest</th>
                                                <th>Doctor Name</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                        </tbody>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </div>
      <div  id="divMedication" style="width: 1150px; overflow: scroll; height: 280px; margin-left: 54px;display:none">
                                <table class="table" id="tblHistoryMedication" style="WIDTH: 1132PX;">
                                    <thead>
                                        
                                        <tr>
                                            <th style="width: 160px;">Date </th>
                                            <th style="width: 84px;">Status</th>
                                            <th style="width: 170px;">Medicine Name </th>
                                           
                                            <th>Dosage</th>
                                            <th>Frequency  </th>
                                            <th>Routes </th>
                                            <th>Duration </th>
                                            <th>Doctor Name </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                    </tbody>
                                </table>
                            </div>

     <div id="Detailpanel">
        1- <a href="#">OutPatient</a>
         <br />

         2-<a href="#">InPatient</a>
             <br />
         3-<a href="#" onclick="LoadTestsHistory()">Test Detail</a>
             <br />
         4-<a href="#" onclick="LoadAllMedicationHistory()">Medication</a>
          <br />
         5-<a href="#" onclick="LoadAllMedicationHistory()">Endoscopy</a>
         <br />
         6-<a href="#" onclick="LoadAllMedicationHistory()">O.T</a>
            
            
        </div>  
     <div id="myResultModal" class="modal fade" role="dialog">

            <div class="modal-dialog">

                <!-- Modal content-->
                <div class="modal-content" style="width: 414px; margin-left: 296px;">
                    <div class="modal-header">
                        <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                        <h4 class="modal-title">View Test Images and Report</h4>
                    </div>
                    <div class="modal-body">
                        <table>
                            <tr>
                                <td>
                                    <input type="hidden" id="type" />
                                    <input type="hidden" id="IDtest" />
                                </td>
                                <td>
                                    <div style="margin-top: -15px; margin-left: 38px;">
                                        <table border="0" cellpadding="0" cellspacing="5">
                                            <tr>
                                                <td>
                                                    <div id="errorMsg" class="formLabel" style="color: red; display: none">No Image Uploaded.</div>
                                                    <%--<asp:Image ID="Image1" src="" AlternateText="" ClientIDMode="Static" runat="server" Height="126" Width="166" onClick="swipe()" />--%>
                                                    <div id="dvPreview" style="white-space: nowrap; overflow-x: visible; overflow-y: hidden; width: 260px;">
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                        <br />
                                        <input type="button" style="width: 123px; margin-left: 45px;" id="btnResultPrint" value="View Print Report" onclick="ShowReport()" />
                                        <input type="hidden" id="hdnNewFiles" />
                                    </div>
                                </td>
                            </tr>
                        </table>

                    </div>
                </div>
            </div>
        </div>

</asp:Content>
