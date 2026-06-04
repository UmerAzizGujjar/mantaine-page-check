<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TestApproval.aspx.cs" Inherits="PMS.TestApproval" ValidateRequest="false" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/TestApproval.css" rel="stylesheet" />

    <script type="text/javascript">
        var GrowthTypeGlobal = '';
        var OrganismTypeGlobal = '';
        var testValueOptionsList = '';
        var globalTestId = '';
        function swipe(thi) {
            var largeImage = document.getElementsByName('other_amount');
            largeImage.style.display = 'block';
            largeImage.style.width = 200 + "px";
            largeImage.style.height = 200 + "px";
            var url = largeImage.getAttribute('src');
            window.open(url, 'Image', 'width=largeImage.stylewidth,height=largeImage.style.height,resizable=1');
        }
        $(function () {
            $("#FileUpload1").change(function () {
                if (typeof (FileReader) != "undefined") {

                    var dvPreview = $("#dvPreview");
                    dvPreview.html("");
                    var regex = /^([a-zA-Z0-9\s_\\.\-:])+(.jpg|.jpeg|.gif|.png|.bmp)$/;
                    $($(this)[0].files).each(function () {
                        var file = $(this);
                        if (regex.test(file[0].name.toLowerCase())) {
                            var reader = new FileReader();
                            reader.onload = function (e) {
                                var img = $("<img onclick='window.open(this.src)' />");
                                img.attr("style", "height:82px;width: 82px");
                                img.attr("src", e.target.result);
                                img.attr('id', '');
                                var ff = $("<a >Delete</a>");
                                dvPreview.append(img);

                            }
                            reader.readAsDataURL(file[0]);
                        } else {
                            alert(file[0].name + " is not a valid image file.");
                            dvPreview.html("");
                            return false;
                        }
                    });
                } else {
                    alert("This browser does not support HTML5 FileReader.");
                }
            });
        });
        //Bilal
        function httpGet(theUrl) {
            debugger;
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function fillTokenInput(PatientID) {
            debugger;
            // $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            var tokenData = httpGet("json.aspx?Table=PatientsFetchByID&q=" + PatientID);
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
            $('#hdnPatient_ID').val(JSON.parse(tokenData)[0].id);
            loadPatientData();
        }
        function rejectList($this) {


            debugger;
            //var groupCat = 0;
            var Group_Categroy = $($this).closest('tr').find('td input[name="GroupCategory"]').val();
            var LabTestDetailid = $($this).closest('tr').find('td input[id="labTestDetailID"]').val();
            var BillDetailID = $($this).closest('tr').find('td input[id="billDetailID"]').val();
            var Remarks = $($this).closest('tr').find('td input[name="myRemarks"]').val();
            //var Remarks = $('#Remarks' + LabTestDetailid + '').val();
            if (Group_Categroy > 0) {
                Group_Categroy = Group_Categroy;
            }
            else {
                Group_Categroy = "0";
            }
            PageMethods.RejectTests(LabTestDetailid, Group_Categroy, BillDetailID, Remarks, function (res) {
                alert(res);
            });

        }
        $(document).ready(function () {
            $("#ddlrptColumns").val(4);
            debugger;
            var PatientID = '<%=Request.QueryString["PatientID"]%>';
            if (PatientID != "") {
                fillTokenInput(PatientID);
            }
            bindControls();
            GetPendingList();
            $('#btnGrowth').click(function () {
                debugger;
                var Growthtext = ddlGrowth.options[ddlGrowth.selectedIndex].text;
                var existingText = $('#txtAreaGrowth').val();
                existingText += '\n' + Growthtext;
                $('#txtAreaGrowth').val(Growthtext);
            });
            $('#btnOrganism').click(function () {
                debugger;
                row = '<tr><td>' + $('#ddlOrganism').find('option:selected').text() + '</td><td><input type="text" name="orgvalue" id="orgvalue" value="" style="width: 65px !important;"/></td><td> <a href="javascript:void(0)" onclick="DeleteOrganism(this)">Delete</a></td></tr>';
                var table = $('#tblOrganism tbody');
                table.append(row);

            });
            $("#approveTest").click(function () {
                debugger;
                var table = $('#tbltest');
                var approve_list = [];
                $("#tbltest tr input[type=checkbox]:checked ").each(function (key, value) {
                    debugger;
                    var listOfIds = {};
                    var lab_test_Detail_id = $($($(this)[0]).closest('tr')[0]).find('td #labTestDetailID').val();
                    var groupCID = $($($(this)[0]).closest('tr')[0]).find('td #groupCID').val();
                    var billDetailID = $($($(this)[0]).closest('tr')[0]).find('td #billDetailID').val();

                    listOfIds.lab_test_Detail_id = lab_test_Detail_id;
                    listOfIds.Group_Category = groupCID;
                    listOfIds.Bill_Details_ID = billDetailID;
                    approve_list.push(listOfIds);
                });
                if (approve_list.length > 0) {
                   
                    debugger;
                    PageMethods.ApproveTests(approve_list, function (response) {
                        alert("Approved Successfully");
                    });
                }
                else {
                    alert("Please Select any test from list");
                }
            });
        });
        function LoadTestsHistory() {

            $('#HeaderTests').html('<h2>Loading Previous History Please Wait....</h2>')
            var hdFile_ID = $("#ctl00_MainContent_txtPatient_ID").val();
            if (hdFile_ID != null || hdFile_ID != " " || hdFile_ID != "undefined") {
                PageMethods.GetTestListForHistory(hdFile_ID, function (res) {
                    var test = JSON.parse(res);
                    var rows = '';
                    var result;
                    $.each(test, function (key, value) {
                        var timeStamp = parseInt(value.Date.substr(6, 10));
                        var date = moment.unix(timeStamp).format('M/D/YYYY h:m:s A');
                        if (value.Test_Collected_By == null)
                            value.Test_Collected_By = "";
                        if (value.Test_Collected_On == null)
                            value.Test_Collected_On = "";
                        var CDate = moment(value.Test_Collected_On).format('L');
                        var RDate = moment(value.Test_Ready_On).format('M/D/YYYY h:m:s A');
                        if (value.Rotation == null)
                            value.Rotation = "";
                        if (value.Rotation == 0)
                            value.Rotation = "";
                        if (value.L_R_Rotation_ID == 0)
                            value.L_R_Rotation_ID = "";
                        if (value.L_R_Rotation_ID == null)
                            value.L_R_Rotation_ID = "";
                        if (value.mainDepartmentName == null)
                            value.mainDepartmentName = "";
                        if (value.Is_Result == true) {
                            result = "View Result";
                            rows += '<tr><td><input type="hidden" name="testID" value="' + value.Lab_Test_Detail_ID + '" />' + CDate + '</td><td>' + RDate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' + value.mainDepartmentName + ',' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td><td>' + value.Test_Collected_By + '</td><td><a href="javascript:void(0)"onclick="EditData(' + value.Lab_Test_Detail_ID + ')" id="result" style="text-decoration: underline; color: #2a6496; font-size: 14px;">' + result + '</a></td></tr>';
                        }
                        else {

                            result = "Waiting"
                            rows += '<tr><td><input type="hidden" name="testID" value="' + value.Lab_Test_Detail_ID + '" />' + CDate + '</td><td>' + RDate + '</td><td><input type="hidden" name="testID" value="' + value.Test_ID + '" />' + value.mainDepartmentName + ',' + value.Test_Name + ',' + value.Rotation + ',' + value.L_R_Rotation_ID + '</td><td>' + value.Test_Collected_By + '</td><td>' + result + '</td></tr>';
                        }
                    });
                    $('#tblHistoryTests tbody tr').remove();
                    $('#tblHistoryTests tbody').html(rows);
                    $('#HeaderTests').html('<h2>Previous History</h2>')
                });
            }
        }
        function readIMG(input) {
            debugger;
            var img_index = 0;
            var detail_id = $(input).closest('tr').find('td:eq(0)')[0].innerText;
            var countFiles = $(input)[0].files.length;
            var imgPath = $(input)[0].value;
            var extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
            var image_holder = $("#image-holder");
            image_holder.empty();
            if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {
                if (typeof (FileReader) != "undefined") {
                    //loop for each file selected for uploaded.
                    for (var i = 0; i < countFiles; i++) {

                        var reader = new FileReader();
                        reader.onload = function (e) {
                            debugger;
                            var img = $('<img />').attr({
                                'id': 'myImage' + i,
                                'src': e.target.result,
                                'alt': 'JSFiddle logo',
                                'title': 'JSFiddle logo',
                                'width': 40,


                            }).appendTo('#container' + detail_id + '');

                            img_index++;

                        }
                        image_holder.show();
                        reader.readAsDataURL($(input)[0].files[i]);
                        '<a href="#" onclick="deleteImage(this)">Delete</a>'
                    }
                } else {
                    alert("This browser does not support FileReader.");
                }
            } else {
                alert("Pls select only images");
            }
        }
        function readIMGsingle(input) {
            debugger;
            var countFiles = $(input)[0].files.length;
            var imgPath = $(input)[0].value;
            var extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
            if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {
                if (typeof (FileReader) != "undefined") {
                    //loop for each file selected for uploaded.
                    for (var i = 0; i < countFiles; i++) {

                        var reader = new FileReader();
                        reader.onload = function (e) {
                            debugger;
                            var img = $('<img />').attr({
                                'id': 'myImage' + i,
                                'src': e.target.result,
                                'alt': 'JSFiddle logo',
                                'title': 'JSFiddle logo',
                                'width': 40
                            }).appendTo('#container');
                            ////var ff = $("<a >Delete</a>");

                        }
                        // image_holder.show();
                        reader.readAsDataURL($(input)[0].files[i]);
                        '<a href="#" onclick="deleteImage(this)">Delete</a>'
                    }
                } else {
                    alert("This browser does not support FileReader.");
                }
            } else {
                alert("Pls select only images");
            }

        }
        function GetPendingList() {
            debugger;
            $.ajax({
                type: "post",
                url: "TestApproval.aspx/ApprovedResultList",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var parse = JSON.parse(response.d);
                    var rows = "";
                    for (var i = 0; i < parse.length; i++) {

                        rows += '<tr><td style="display:none;">' + parse[i].Patient_ID + '</td><td>' + parse[i].Patient_No + '</td><td>' + parse[i].Full_Name + '</td><td>' + parse[i].Father_Name + '</td><td>' + parse[i].Patient_Category + '</td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="fillTokenInput(' + parse[i].Patient_ID + ')">Select</a></td></tr>';
                    }
                    $("#tblPendingPatientsLIst").append(rows);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function GetSelectedDetail(patient_ID) {
            debugger;
            //var PatientID = $('#hdfPatient_ID').val();
            if (patient_ID != "") {
                $('#txtMR_No').tokenInput('clear');
                var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + patient_ID);

                $('#txtMR_No').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
                $("#hdPatientID").val(JSON.parse(tokendata)[0].id);
                GetPatientDetail();
            }
            else {
                //tokenInputs('txtMR_No', 'Patients');
            }
        }
        function image(input) {
            debugger;
            var output = document.getElementById('image');
            var a = URL.createObjectURL(input.files[0]);
            console.log(a);
        }
        function CheckNumberOrNot(e) {
            debugger;
            var check = true;
            // prevent: "e", "=", ",", "-", "."
            if ([69, 187, 188, 189, 190].includes(e.keyCode))
                check = false;

            var charCode = (e.which) ? e.which : e.keyCode;

            if (charCode > 31 && (charCode < 48 || charCode > 57))
                check = false;

            if (check == false) {
                debugger;
                alert("Only numeric values allowed");
                e.preventDefault();
            }
        }
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../json.aspx?Table=Patients",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdnPatient_ID").val(item.id);
                    }
                });
        }
        function bindControls() {
            var hdFile_ID = $("#hdnPatient_ID").val();
            if (hdFile_ID != "(New)") {
                var Patient_ID = $("#hdnPatient_ID").val();
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {
                loadtokenInputsDefault();
            }
            var hdFile_ID = $("#hdnLab_Test_ID").val();
            if (hdFile_ID != "(New)") {
                var Lab_Test_ID = $("#hdnLab_Test_ID").val();
                var tokendata = httpGet("json.aspx?Table=Laboratory_Test&Record=Edit&q=" + Lab_Test_ID);
                loadPatientDataUsingLabID();
            }
            else {
                $('#ctl00_MainContent_txtLab_Test_ID').tokenInput("json.aspx?Table=Laboratory_Test",
            {
                tokenLimit: 1,
                onAdd: function (item) {
                    try {
                        debugger;
                        $("#hdnLab_Test_ID").val(item.id);
                        loadPatientDataUsingLabID();
                    }
                    catch (err) {
                        alert(err.message);
                    }
                }
            });
            }
        }
        function loadtokenInputsDefault() {
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("json.aspx?Table=Patients",
             {
                 tokenLimit: 1,
                 onAdd: function (item) {
                     try {
                         $("#hdnPatient_ID").val(item.id);
                         loadPatientData();
                     }
                     catch (err) {
                         alert(err.message);
                     }
                 }
             });
        }
        function loadPatientData() {
            debugger;
            var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            var Lab_id = $("#ctl00_MainContent_txtLab_Test_ID").val();
            if (Lab_ID == null || Lab_ID == "(New)") {
                $.ajax({
                    type: "POST",
                    url: "TestApproval.aspx/GetDetail",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccesss,
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
        }

        function GetLabDetail() {
            var TestRange = '';
            var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
           var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            if (Patient_ID == null || Patient_ID == "" || Patient_ID == "(New)") {
                Patient_ID = "0";
            }
            if (Lab_ID == null || Lab_ID == "" || Lab_ID == "(New)") {
                Lab_ID = 0;
            }

            PageMethods.GetLabDetail(Patient_ID, Lab_ID, function (res) {
                var Test = JSON.parse(res);
                console.log("Test", Test);
                var rows = '';
                $.each(Test, function (key, value) {
                    $("#<%= txtLab_Test_ID.ClientID %>").val(value.LabID);

                    if (value.MainDepartment == null)
                        value.MainDepartment = "";
                    if (value.TestDepartment == null)
                        value.TestDepartment = "";
                    if (value.Unit_Name == null)
                        value.Unit_Name = ""
                    if (value.Is_Result == true) {
                        result = "View Result";
                    }
                    else {
                        result = "Add Result"
                    }
                    if (value.Ranges == null || value.Ranges == '') {
                        TestRange = value.AllRange;
                    }
                    else {
                        TestRange = value.Ranges;
                    }
                    var dd = tbltest.rows.length;
                    if (value.Group_Category != "") {
                        var s = value.Group_Category;
                        debugger;
                        value.Start_Range = "",
                        value.End_Range = "";
                        //Group Test
                        debugger;
                        rows += '<tr>' +
                            '<td><input type="checkbox" name="chekApprove" value="approveVal"/></td>' +
                            '<td><input type="hidden" name="labtestDID" id="labtestDID" value="'
                            + value.Test_ID + '" />'
                            + value.Lab_Test_ID + '</td>' +
                            '<td style="color:red;cursor: pointer;" onclick="getTestID('
                            + value.Lab_Test_ID + ', '
                            + value.Test_ID + ' ,'
                            + value.Bill_Details_ID +
                            ')">'
                            + value.Test_Name + '</td>' +
                            '<td>' + TestRange + '</td>' +
                            '<td id="testVal">' + value.Test_Value + '</td>' +
                            '<td id="scrollid"><textarea  style="margin-bottom: 0px;">' + value.Test_Temp + '</textarea></td>' +
                            '<td> - </td>' +
                            '<td> - </td>' +
                            '<td style="text-align: center;"> <input type="text" name="myRemarks" id="Remarks' + value.Lab_Test_Detail_ID + '"  value="' + value.Rejected_Reason + '"/></td>' +
                            '<td style="width: 165px !important;">' +

                            '<a href="#" onclick="rejectList(this)"><span class="fa fa-close" style="font-size:31px;color:red"></span></a><a href="#" onclick="ShowReport('
                                + value.Test_ID + "," + value.Lab_Test_ID + "," + value.Lab_Test_Detail_ID +
                            ')"><span class="fa fa-edit" style="font-size:31px;color:green"></span> </a>' +


            
                            '</td>' +
                            '<td style="display:none;"><input type="hidden" name="GroupCategory" value=' + value.Group_Category + '></td>' +
                            '<td style="display:none;"><input type="hidden" id="labTestDetailID" value=' + value.Lab_Test_Detail_ID + '></td>' +
                            '<td style="display:none;"><input type="hidden" id="billDetailID" value=' + value.Bill_Details_ID + '></td>' +
                            '<td style="display:none;"><input type="hidden" name="labtestDID" id="groupCID' + value.Lab_Test_Detail_ID + '" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs' + value.Lab_Test_Detail_ID + '" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Report_Colum" id="Report_Colum' + value.Lab_Test_Detail_ID + '" value="' + value.Report_Colum + '"/></td></tr>';
                    }
                    else {
                        //Single Test
                        //loadPatientData(value.Lab_Test_ID, value.Test_ID);
                        rows += '<tr>' +
                           '<td><input type="checkbox" name="chekApprove" value="approveVal"/></td>' +
                           '<td>' + value.Lab_Test_ID + '</td>' +
                           '<td>' + value.Test_Name + '</td>' +
                           '<td>' + TestRange + '</td>' +
                           '<td id="testVal">' + value.Test_Value + '</td>' +
                           '<td id="scrollid"><textarea style="margin-bottom: 0px;">' + value.Test_Temp + '</textarea></td>' +
                           '<td>' + value.Growth_type + '</td>' +
                            '<td style="width: 800px;">' +
                               '<table  border="1" style="width: 208px;margin-bottom: -8px;">' +
                                 '<thread>' +
                                   '<tr>' +
                                    '<th>Org Name</th>' +
                                    '<th>S/R</th>' +
                                 '</tr>' +
                                 '</thread>' +
                                   '<tbody id="tblOrganism">' +
                                   '</tbody>' +
                               '</table>' +
                           '</td>' +
                           '<td style="text-align: center;width: 80px;"> <input type="text" name="myRemarks" id="Remarks'
                           + value.Lab_Test_Detail_ID + '"  value="' + value.Rejected_Reason + '"/></td>' +
                            '<td style="width: 165px !important;">' +
                               '<a href="#" onclick="rejectList(this)"><span class="fa fa-close" style="font-size:31px;color:red"></span></a><a href="#" onclick="ShowSingleReport(' + value.Test_ID + "," + value.Lab_Test_ID + "," + value.Lab_Test_Detail_ID +
                            ')"><span class="fa fa-edit" style="font-size:31px;color:green"></span> </a>' +
                            '<td style="display:none;"><input type="hidden" id="labTestDetailID" value=' + value.Lab_Test_Detail_ID + '></td>' +
                            '<td style="display:none;"><input type="hidden" id="billDetailID" value=' + value.Bill_Details_ID + '></td>' +
                                 '<td style="display:none;"><input type="hidden" name="labtestDID" id="groupCID' + value.Lab_Test_Detail_ID + '" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs' + value.Lab_Test_Detail_ID + '" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Report_Colum" id="Report_Colum' + value.Lab_Test_Detail_ID + '" value="' + value.Report_Colum + '"/></td></tr>';
                    }
                });
                $('.table tbody').html(rows);
                debugger;
                $(".tdemergency").hide();
            });
            // function loadPatientData(labTestId, testId) {
            //     console.log("loadPatientData", labTestId, testId);
            //debugger;
                PageMethods.LoadOrganismList(labTestId, testId, function (res) {
                    var Org = JSON.parse(res);
                    var rows = "";
                    $.each(Org, function (key, value) {
                        debugger;
                        rows += '<tr>' +
                            '<td>' + value.Organism_Name + '</td>' +
                            '<td>' + value.Organism_Value + '</td>' +
                        '</tr>';
                    });
                    $('#tblOrganism').append(rows);
                });
            }
            //}
            //....................................................................
            //report view 
            function ShowReport(Test_ID, Lab_Test_ID, Lab_Test_Detail_ID) {
                //var reportColums = $("#ddlrptColumns").val();
                debugger;
                var ListOfTestIDs = '';
                var GroupCat = $('#groupCID' + Lab_Test_Detail_ID + '').val();
                var ReportCol = $('#Report_Colum' + Lab_Test_Detail_ID + '').val();
                var ListOfTestIDs = $('#ListOfTestIDs' + Lab_Test_Detail_ID + '').val();
                if (ListOfTestIDs == "null") {
                    ListOfTestIDs = Test_ID;
                }

                var Patient_ID = $('#hdnPatient_ID').val();
                if (ListOfTestIDs.length > 2) {
                    //ListOfTestIDs = ListOfTestIDs.replace(', ', '');
                    //ReportCol = ReportCol.replace(', ', '');
                    debugger;
                    var Patient_ID = $('#hdnPatient_ID').val();
                    window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&Patient_ID=' + Patient_ID + '&TransID=' + Lab_Test_ID + '&ReportColumn=' + ReportCol);
                }
                else
                    window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + Test_ID + '&Patient_ID=' + Patient_ID + '&TransID=' + Lab_Test_ID + '&ReportColumn=' + ReportCol);
            }

            function ShowSingleReport(Test_ID, Lab_Test_ID, Lab_Test_Detail_ID) {

                debugger;
                var ReportCol = $('#Report_Colum' + Lab_Test_Detail_ID + '').val();
                var Patient_ID = $('#hdnPatient_ID').val();
                window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + Test_ID + '&Patient_ID=' + Patient_ID + '&TransID=' + Lab_Test_ID + '&ReportColumn=' + ReportCol);
            }

            //end
            $(document).ready(function () {
                //   $('#txtfixedType').ckeditor();
                if (CKEDITOR) {
                    // Replace the <textarea name = "content"> with a CKEditor instance. 
                    //  CKEDITOR.replace('txtfixedType');
                }
                $('#txtMRNOSearch').keyup(function (e) {
                    debugger;
                    //var CheckAll = $('#chkTodayAll').checked;
                    var MRno = $('#txtMRNOSearch').val();
                    var tbl = document.getElementById('tblPendingPatientsLIst');
                    if (MRno.trim() != '') {

                        for (var i = 1; i < tbl.rows.length; i++) {
                            if (tbl.rows[i].cells[1].innerText != MRno) {
                                var row = tbl.rows[i];
                                row.style.display = 'none';
                            }
                            else {
                                var row = tbl.rows[i];
                                row.style.display = '';
                            }
                        }
                    }
                    else {
                        for (var i = 1; i < tbl.rows.length; i++) {
                            var row = tbl.rows[i];
                            row.style.display = '';
                        }
                    }
                });
            });
            function getTestID(LabID, CatID, billDetailID) {
                var catID = CatID.toString();
                debugger;
                //  CatID = $($(this).find('#tbltest td input[name=labtestDID]')[1]).val();
                PageMethods.GetTestDetails(LabID, catID, billDetailID, function (res) {
                    var TestTable = JSON.parse(res);
                    var rows = '';
                    $.each(TestTable, function (key, value) {
                        rows += '<tr>' +
                                  '<td>' + value.Test_Name + '</td>' +
                                  '<td>' + value.Fixed_Value + '</td>' +
                                  '<td>' + value.Test_Value + '</td>' +
                                  '<td>' + "0" + '</td>'
                        '</tr>';
                    });
                    $('#groupTestlist tbody').empty();
                    $('#groupTestlist').append(rows);
                });
                $('#myModal').modal('show');
            }
            function LabTestMultipleID(testID) {
                debugger;
                PageMethods.getResultValues(testID, function (res) {
                    debugger;
                    var testValueList = JSON.parse(res);
                    testValueOptionsList = '';
                    $('#ddlTestResult').empty();
                    $('#ddllistType option').remove();
                    for (var i = 0; i < testValueList.length; i++) {

                        testValueOptionsList = '<option value="' + testValueList[i] + '">' + testValueList[i] + '</option>';
                        $('#ddllistType').append(testValueOptionsList);
                    }
                });
            }
            function LabTestMultipleID(testID) {
                debugger;
                PageMethods.getResultValues(testID, function (res) {
                    debugger;
                    var testValueList = JSON.parse(res);
                    testValueOptionsList = '';
                    $('#ddlTestResult').empty();
                    $('#ddllistType option').remove();
                    for (var i = 0; i < testValueList.length; i++) {

                        testValueOptionsList = '<option value="' + testValueList[i] + '">' + testValueList[i] + '</option>';
                        $('#ddllistType').append(testValueOptionsList);
                    }
                });
            }
            function deleteImage(imageURL) {
                debugger;
                var imageURL = $($(imageURL)[0]).attr('src');
                $.ajax({
                    type: "POST",
                    url: "LabTestResult.aspx/DeleteImage",
                    data: JSON.stringify({ "imagSrc": imageURL }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        if (data.d == "Success") {
                            $('#myModal').modal('hide');
                        }
                    }
                    , error: function () {

                    }


                });
            }
            function EditValue() {

                // document.getElementById("mTestTemplate").disabled = false;
                document.getElementById("mTestDiagnosis").disabled = false;
                document.getElementById("mTestNotes").disabled = false;
                document.getElementById("mTestValues").disabled = false;
                //document.getElementById("mTestTemplate").disabled = false;

                $('#saveTest').val("Update");
                $('#saveTest').show();

                $('#FileUpload1').show();
                $.each($('#tblCatValues tbody tr'), function (key, value) {

                    $(value).find('input[name="txtValue"]').prop('disabled', false);
                });
            }
            var checkUnApproved = false;
            function EnableEditValue() {
                $('#btnEdit').show();
                $('#btnApprove').hide();
                $('#saveTest').show();

                checkUnApproved = true;

            }
            var GroupCatID = "";
            var isGroup = '';
            var testDetailid = '';
            var CatID = '';
            var appendedRow = '';
            var result_type_value = '';
            var result_type_fixed = '';
            var result_type_list = '';
            function EditData($this) {
                debugger;
                var Lab_Test_Detail_ID = '';
                var LabID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            var LabID = $($($this).parents('tr')[0]).find('td:nth-child(2)')[0].innerText;
            $("#hdnLab_Test_ID").val(LabID);
            var row = $($this).parents('tr')[0];
            CatID = $($(row).find('td input[name=labtestDID]')[0]).val();
            globalTestId = $($(row).find('td input[name=labtestDID]')[0]).val();
            $("#hdtestdetailid").val(CatID);
            var Group_Categroy = $($(row).find('td input[name=Group_Category]')[0]).val();
            testDetailID = $($($this).parents('tr')[0]).find('td:nth-child(3)')[0].innerText;
            $("#hdtestdetailid").val(testDetailID);
            var billDetailID = $($(row).find('td input[name=Bill_Details_ID]')[0]).val();

            if (Group_Categroy == "") {
                $("#tblgroupTestlist").hide();
                $("#tblsingleTest").show();
                $("#saveTest").show();
            }
            else {
                debugger;
                $("#tblgroupTestlist").show();
                $("#tblsingleTest").hide();
            }
            $('#myModal').modal('hide');
            PageMethods.LoadTestCatogry(LabID, CatID, billDetailID, function (res) {

                debugger;
                var parsedData = JSON.parse(res);
                var row = '';
                if (Group_Categroy == "") //Single
                {
                    debugger;
                    //single
                    var single = "1";
                    isGroup = false;
                    LabTestMultipleID($("#labtestDID").val());
                    $.ajax({

                        type: "POST",
                        url: "LabTestResult.aspx/GetTestDetail",
                        data: "{'TestDetailID':" + testDetailID + ",'LabID':" + LabID + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            debugger;
                            var data = JSON.parse(response.d);
                            var result_value = data[8];
                            var range = data[13];
                            var fixedValue = data[14];
                            result_type_value = data[10];
                            result_type_fixed = data[11];
                            result_type_list = data[12];
                            Master_Remarks = data[17];
                            $('#txtfixedType').val(fixedValue);
                            $('#txtMaster_Remarks').val(Master_Remarks);
                            //$('#txtAreaGrowth').val(Growth_Type);
                            //  $('#TextareaOrganism').val(Organism_Type);
                            CKEDITOR.instances.txtfixedType.setData(fixedValue);
                            CKEDITOR.instances.txtMaster_Remarks.setData(Master_Remarks);
                            $('#txtvaluetype').val(range);
                            $("#ddllistType").val(result_value);
                            if (result_type_value != "True") {
                                $("#tblsingleTest td:eq(1)").hide();
                                $("#tblsingleTest th:eq(1)").hide();
                            }
                            else {
                                $("#tblsingleTest td:eq(1)").show();
                                $("#tblsingleTest th:eq(1)").show();
                            }
                            if (result_type_fixed != "True") {
                                $("#tblsingleTest td:eq(0)").hide();
                                $("#tblsingleTest th:eq(0)").hide();

                            }
                            else {
                                $("#tblsingleTest td:eq(0)").show();
                                $("#tblsingleTest th:eq(0)").show();
                            }
                            if (result_type_list != "True") {
                                $("#tblsingleTest td:eq(2)").hide();
                                $("#tblsingleTest th:eq(2)").hide();
                            }
                            else {
                                $("#tblsingleTest td:eq(2)").show();
                                $("#tblsingleTest th:eq(2)").show();
                            }

                        }, error: function () {

                        }
                    });

                    setTimeout(function () {

                        showImage(testDetailID, single);
                    }
     , 1000);
                }
                else {
                    var single = "0";
                    //group
                    isGroup = true;
                    debugger;
                    $('#tblgroupTestlist tr:gt(0)').remove();
                    optionsList = '<option>Please Select</option>';
                    var parsed_image_data = '';
                    $.each(parsedData, function (key, value) {
                        debugger;
                        var selectValue = '';
                        var optionsList = '';
                        var Remarks = '';
                        Remarks = parsedData[key].Master_Remarks;
                        $('#txtMaster_Remarks').val(Remarks);
                        for (var i = 0; i <= parsedData[key].resultValueList.length - 1; i++) {
                            optionsList += '<option>' + parsedData[key].resultValueList[i] + ' </option>';
                        }
                        if (parsedData[key].Test_Value == null) parsedData[key].Test_Value = '';
                        var fixed = '';
                        var typeVal = '';
                        var typelist = '';
                        if (parsedData[key].Result_Type_Fixed == false) {

                            fixed = "";
                        }
                        else {

                            fixed = parsedData[key].Fixed_Value;

                        }
                        if (parsedData[key].Result_Type_Value == false) {

                            typeVal = "";
                        }
                        else {

                            typeVal = parsedData[key].Test_Value;
                        }
                       


                        row = '<tr><td style="display:none;">' + parsedData[key].Lab_Test_Detail_ID + '</td><td>' + parsedData[key].Test_Name + '</td><td class=' + 'arrow-togglable ' + parsedData[key].Result_Type_Fixed + '><div contenteditable>' + fixed + '</div></td><td data-text="sdasd" class=' + 'arrow-togglable ' + parsedData[key].Result_Type_Value + '><div contenteditable>' + typeVal + '</div></td><td class=' + parsedData[key].Result_Type_List + '> <select id="ddlResultValue' + key + '">' + optionsList + '</select></td><td> <select id="ddlGrowth' + key + '">' + GrowthTypeGlobal + '</select></td><td> <select id="ddlOrganism' + key + '">' + OrganismTypeGlobal + '</select></td><td> <input  onchange="readIMG(this)" id="fileUploadMultiple' + parsedData[key].Lab_Test_Detail_ID + '" type="file" name="FileUpload" multiple="multiple" class="image"/><div id="container' + parsedData[key].Lab_Test_Detail_ID + '" style="width:150px;"></div></td><td><a href="#" onclick="Edit(this)"></a></td></tr>';
                        //onchange="readIMG(this)"
                        Lab_Test_Detail_ID = parsedData[key].Lab_Test_Detail_ID;
                        $('#tblgroupTestlist tbody').append(row);
                        if (parsedData[key].Result_Type_List == false) {
                            $('#ddlResultValue' + key + '').hide();
                        }
                        else {

                        }
                        $('#ddlResultValue' + key + '').val(parsedData[key].Result_Value);
                        if (parsedData[key].Growth_Type != '' && parsedData[key].Growth_Type != null) {
                            for (var i = 0; i <= parsedData[key].Growth_Type.length; i++) {
                                debugger;
                                var GrowthType = parsedData[key].Growth_Type;
                                $('#ddlGrowth' + i + '').val(GrowthType);
                            }
                        }
                        if (parsedData[key].Growth_Type != '' && parsedData[key].Growth_Type != null) {
                            for (var i = 0; i <= parsedData[key].Organism_Type.length; i++) {
                                debugger;
                                var OrganismType = parsedData[key].Organism_Type;
                                $('#ddlOrganism' + i + '').val(GrowthType);
                            }
                        }
                    });
                }
                $('#myModal').modal({
                    backdrop: 'static'
                });
            });
        }
        var fileListGlobal = '';
        function Edit(rowSave) {
            debugger;
            var lab_test_Detail_id = $($(rowSave).parents('tr')[0]).find('td:eq(0)').text();
            var filesComplete = $($(rowSave).closest('tr')[0]).find('td:eq(7) input[type=file]').get(0).files;

            var datas = new FormData();
            for (var i = 0; i < filesComplete.length; i++) {
                datas.append(filesComplete[i].name, filesComplete[i]);
            }
            datas.append('lab_test_Detail_id', lab_test_Detail_id);

            var fixed_values = $($(rowSave).parents('tr')[0]).find('td:eq(2)').text();
            if (fixed_values == "") fixed_values = '0';
            var value_type = $($(rowSave).parents('tr')[0]).find('td:eq(3)').text();
            if (value_type == "") value_type = "0";
            var result_type = $($(rowSave).parents('tr')[0]).find('td:eq(4)').find('select').val();

            if (result_type == null) result_type = "0";
            var Growthtype = $($(rowSave).parents('tr')[0]).find('td:eq(5)').find('select').val();
            var OrganismType = $($(rowSave).parents('tr')[0]).find('td:eq(6)').find('select').val();

            var options = {};
            options.url = "ImageUpload.ashx";
            options.type = "POST";
            options.data = datas;
            options.contentType = false;
            options.processData = false;
            options.success = function (result) { alert(result) };
            options.error = function (err) { alert(err.statusText); };
            $.ajax(options);
            $.ajax({
                type: "POST",
                url: "LabTestResult.aspx/SaveGroupTest",
                data: JSON.stringify({
                    "lab_test_Detail_id": lab_test_Detail_id,
                    "fixed_values": fixed_values,
                    "value_type": value_type,
                    "result_type": result_type,
                    "Growthtype": Growthtype,
                    "OrganismType": OrganismType,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d == 'Successfull') {

                        alert("Saved");
                    }
                    debugger;
                }, error: function () { }
            });
        }
        function OnSuccess(data) {
            debugger;
            if (data.d != '') {
                debugger;
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + data.d.Patient_No);
                $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
           $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
           $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
           $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
           $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
           $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
           $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
           debugger;
           //GetLabDetailUsingLabID();
           GetLabDetail();
       }
   }
   function OnSuccesss(data) {
       if (data.d != '') {
           var mydate = new Date(Date.parse(data.d.Entry_Date));
           var dateR = mydate.toLocaleDateString();
           $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
                debugger;
                GetLabDetail();
            }
        }
        function DeleteOrganism(reference) {
            debugger;
            $($(reference).parents('tr')[0]).remove();
        }
    </script>
    <script type="text/javascript">
        function toggle(source) {
            debugger;
            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i] != source)
                    checkboxes[i].checked = source.checked;
            }
        }

    </script>

    <script type="text/javascript">
        $(document).keydown(function (e) {

            switch (e.which) {
                case 37: // left arrow       
                    $(e.target).parent().prev().find('div').focus()
                    break;
                case 39: // right arrow
                    $(e.target).parent().next().find('div').focus()
                    break;
                case 40: // down
                    $(e.target).parent().parent().next().children().eq($(e.target).parent().index()).find('div').focus()
                    break;
                case 38: // up
                    $(e.target).parent().parent().prev().children().eq($(e.target).parent().index()).find('div').focus()
                    break;
                default: // exit for other keys
                    return;
            }

        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PatientDetail" style="width: 100%">
        <div class="row">
            <!-- Left Card -->
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Lab2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <asp:Label ID="LblLab_Test_ID" runat="server" Text="Lab Test ID :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtLab_Test_ID" runat="server"></asp:TextBox>
                                        <asp:HiddenField ID="hdnLab_Test_ID" runat="server" ClientIDMode="Static" Value="(New)" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <asp:Label ID="lblPatien_ID" runat="server" Text="MR No:*"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                                        <asp:HiddenField ID="hdnPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                       <asp:Label ID="lblPatient_Name" runat="server" Text="Name :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                       <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                       <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 top">
                                        <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
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
                                <b>Search From MRNo:</b>
                            </div>
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                <input id="txtMRNOSearch" type="text" />
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 detail">
                                <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 detail">
                               <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="LblPatient_Category" runat="server" Text="Category :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 detail">
                                 <asp:Label ID="vPatient_Category" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblAdress" runat="server" Text="Address :"></asp:Label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6 detail">
                                <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>
            </div>
        
       
        <table style="padding: 20px; width: 829px; height: 200px; float: left;">
            <tr style="display: none">
                <td>Report Columns</td>
                <td style="display: none">
                    <select id="ddlrptColumns" style="width: 210px!important;">
                        <option value="2">2-Fixed Or DropDown</option>
                        <option value="3">3-DropDown and Fixed</option>
                        <option value="4">4-Table Range and Fixed</option>
                        <option value="5">4-Value Range Table</option>
                        <option value="6">5-Cutt Off</option>
                        <option value="7">6-Result Organism</option>
                    </select>
                </td>
            </tr>
        </table>
    </div>
 
    <div id="dvtblSymtomps" style="width:70%;height: 298px;overflow: scroll; position: absolute;">
        <table class="table" style="overflow: scroll;" id="tblPendingPatientsLIst">
            <thead>
                <tr>
                    <th>MR No</th>
                    <th>Name</th>
                    <th>Father Name</th>
                    <th>Dpt</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>
    <div>
        <table>
            <tr>
                <td colspan="6">
                    <div style="margin-top: 7%;">
                        <h2>Tests : </h2>
                        <div style="overflow: scroll; height: 300px;">
                            <table id="tbltestDetail" class="table" style="width: 1325px;">
                                <thead>
                                    <tr>
                                        <th style="width: 174px;">
                                            <input type="checkbox" onclick="toggle(this);" />
                                        </th>
                                        <th style="width: 493px;">Lab Test ID</th>
                                        <th style="width: 163px;">Test Name</th>
                                        <th style="width: 430px;">Reference Ranges</th>
                                        <th style="width: 422px;">Patient Result</th>
                                        <th style="width: 140px;">Fixed Value</th>
                                        <th style="width: 142px;">Growth/Non Growth</th>
                                        <th style="width: 142px;">Organisim Detected</th>
                                        <th style="width: 601px;">Rej Remarks</th>
                                        <th style="width: 120px;">Action</th>
                                        <%--<th style="width: 142px;">Remarks</th>--%>
                                    </tr>
                                </thead>
                                <tbody id="tbltest"></tbody>
                            </table>
                        </div>
                    </div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:HiddenField ID="hdfPatient_ID" Value="(New)" runat="server" ClientIDMode="Static" />
                </td>
                <td style="width: 100px;">
                    <asp:HiddenField ID="hdfPatient_No" runat="server" ClientIDMode="Static" />
                </td>
                <td></td>
                <td class="mg"></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="6">
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors"
                        ShowSummary="true" DisplayMode="List" />
                </td>
            </tr>
            <tr>
                <td colspan="6">
                    <asp:Label ID="Label1" Text="" runat="server" />
                </td>
            </tr>
        </table>
    </div>
    <div>
        <div class="col-lg-1 col-md-4 col-sm-6" style="margin-top:1%">
               <input type="button" class="btn btn-primry" id="approveTest" name="approveTest" value="Approve" />
    </div>
        </div>
    <!-- Modal -->

    <div id="myModal" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="width: 1504px; margin-left: -459px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title" id="titleee">Test Results</h4>
                </div>
                <div class="modal-body">
                    <table id="groupTestlist" class="responstable">
                        <thead>
                            <tr>
                            <th style="display: none"></th>
                            <th>Test Name</th>
                            <th>Fixed Type</th>
                            <th>Patient Result</th>
                            <th style="width: 193px;">List Type</th>
                                </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>
                <div class="modal-body">
                    <tr>
                        <td>
                            <div class="modal" id="myInnerModal1">
                                <div class="modal-dialogue">
                                    <div class="modal-content">
                                        <div class="modal-body">
                                            <textarea name="txtMaster_Remarks" id="txtMaster_Remarks" rows="10" cols="80">
                                        </textarea>
                                            <script>
                                                CKEDITOR.replace('txtMaster_Remarks');
                                            </script>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                </div>
                <script type="text/javascript">
                    $("button[data-dismiss-modal=modal2]").click(function () {
                        $('#myInnerModal1').modal('hide');
                    });
                    $("button[data-dismiss-modal=modal2]").click(function () {
                        $('#myInnerModal1').modal('hide');
                    });
                </script>
                <div class="modal-footer">
                    <input type="button" id="btndismiss" class="btn btn-danger"
                        data-dismiss-modal="modal2" value="Close"
                        onclick="$('#myModal').modal('hide');" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>

