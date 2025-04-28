<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabTestResult.aspx.cs" Inherits="PMS.LabTestResult" ValidateRequest="false" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <meta http-equiv="cache-control" content="no-cache" />
    <meta http-equiv="Pragma" content="no-cache" />
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="Scripts/jquery.fileupload.js"></script>
    <script type="text/javascript" src="Scripts/upload.js"></script>
    <link href="css/stock.css" rel="stylesheet" />
    <script src="<%= Page.ResolveClientUrl("~/Scripts/ckeditor/ckeditor.js")%>" type="text/javascript"></script>

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
        //$(function () {
        //    $('#FileUpload1').change(function () {
        //       
        //        $('#Image1').hide();
        //        var reader = new FileReader();
        //        reader.onload = function (e) {
        //            $('#Image1').show();
        //            $('#Image1').attr("src", e.target.result)
        //            $('#Image2').attr("src", e.target.result);
        //        }
        //        reader.readAsDataURL($(this)[0].files[0]);
        //    });
        //});
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

        function toggle(source) {

            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {


                if (checkboxes[i] != source)
                    if (checkboxes[i].hasAttribute("id") == true) {
                    }
                    else {
                        checkboxes[i].checked = source.checked;
                    }
            }
        }

        debugger;
        var index = 0;
        function ShowReport() {
            debugger;
            var textInput = [];
            //debugger;td:eq(10) #Report_Colum
            var ChkLetterHead = $("#ChkIs_latterhead").prop('checked');
            var CheckUnApprove = 0;
            $("#tblLabTest tr").find('td:eq(10) #Report_Colum').map(function () {
                debugger;

                if (textInput.indexOf(this.value) === -1) {
                    debugger;
                    textInput.push(this.value);
                }

            });

            //var uniques = textInput.unique();
            //alert(uniques);
            $('#tblLabTest tr').each(function (key, value) {

                var Checked = $(this).find('td:eq(0) input[name=chkReport]').prop('checked');

                if (Checked == true) {
                    Chk_IsApprove = $(this).find('td:eq(8) #isApprove').attr('value');

                    if (Chk_IsApprove == false || typeof Chk_IsApprove === 'undefined' || Chk_IsApprove == 'false' || Chk_IsApprove == "False") {
                        CheckUnApprove += 1;
                    }
                }
            });

            if (CheckUnApprove > 0) {
                alert("Please Approve The Test First");
                return false;
            }
            else {

                for (var i = 0; i < textInput.length; i++) {

                    var ListOfTestIDs = '';
                    var ListTransID = '';
                    var Report_Column = '';
                    var ListBillDetailID = '';
                    var LabTestDetailsID = '';
                    var test_wise_ids = '';

                    index = textInput[i];

                    $('#tblLabTest tr').each(function () {

                        //   closeCoutner += 1;


                        var Checked = $(this).find('td:eq(0) input[name=chkReport]').prop('checked');

                        if (Checked == true) {

                            Report_Column = $(this).find('td:eq(10) #Report_Colum').val();
                            //$(this).find('td:eq(11) #Report_Column').val();
                            Chk_IsApprove = $(this).find('td:eq(8) #isApprove').attr('value');
                            if (Report_Column == "null" || Report_Column == '') {
                                alert("Please Verify Report Again this Test ")
                                return false;
                            }
                            debugger;
                            if (index == Report_Column.trim()) {
                                debugger;
                                var transIds = $(this).find('td:eq(1)').text();
                                ListTransID += ', ' + transIds;
                                var billdetailid = $(this).find('input[name="Bill_Details_ID"]').val();

                                ListBillDetailID += ', ' + billdetailid;
                                LabTestDetailsID = $(this).find('td:eq(2)').text();
                                test_wise_ids = $(this).find('input[name=test_wise_id]').val();
                                var groupCategory = $(this).find('#GroupCategory').val();
                                if (groupCategory != "") {

                                    var testIds = $(this).find('td:eq(10) #ListOfTestIDs').val();

                                    if (testIds == "null" || testIds == '') {
                                        testIds = $(this).find('td:eq(1) #labtestDID').val();
                                    }
                                    ListOfTestIDs += ', ' + testIds;
                                }
                                else {
                                    ListOfTestIDs += ', ' + $(this).find('#labtestDID').val();
                                }
                            }
                        } // check false
                        //loop end
                    });
                    debugger;
                    ListTransID = ListTransID.replace(', ', '');
                    ListOfTestIDs = ListOfTestIDs.replace(', ', '');
                    ListBillDetailID = ListBillDetailID.replace(', ', '');
                    if (ListOfTestIDs != '') {

                        // var Patient_ID = $('#hdnPatient_ID').val();
                        w = window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + index + '&ChkLetterHead=' + ChkLetterHead)
                    }

                }



            }

        }


        function httpGet(theUrl) {

            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function fillTokenInput(Bill_No) {
            localStorage.billid = 1
            localStorage.patientid = 0
            localStorage.isSaved = 0
            // $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            $('#ctl00_MainContent_txtBilling').tokenInput('clear');
            //   var tokenData = httpGet("json.aspx?Table=PatientsFetchByID&q=" + PatientID);
            var tokenData = httpGet("json.aspx?Table=Billing&q=" + Bill_No);


            $('#ctl00_MainContent_txtBilling').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

            //  $('#hdnPatient_ID').val(JSON.parse(tokenData)[0].id);
            $("#hdBill_id").val(JSON.parse(tokenData)[0].id);
            $("#hdnBill_No").val(JSON.parse(tokenData)[0].name);
            //  loadPatientData();
            loadPatientDataUsingBillId();

        }


        $(document).ready(function () {

            //$('#ctl00_MainContent_Button1').on('click', function ()
            //{
            //    debugger;
            //    $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
            //    $("#hdnPatient_ID").val('(New)');
            //    localStorage.clear();

            //    sessionStorage.clear();

            //    window.location.href = "LabTestResult.aspx";

            //})
            $("#ddlrptColumns").val(4);

            var PatientID = '<%=Request.QueryString["PatientID"]%>';
            if (PatientID != "") {
                fillTokenInput(PatientID);
            }
            bindControls();
            GetPendingList();
            $('#btnGrowth').click(function () {


                var Growthtext = ddlGrowth.options[ddlGrowth.selectedIndex].text;
                var existingText = $('#txtAreaGrowth').val();
                existingText += '\n' + Growthtext;
                $('#txtAreaGrowth').val(Growthtext);
            });
            $('#btnGrowthInfo').click(function () {


                var Growthtext = growthInfor.options[growthInfor.selectedIndex].text;
                var existingText = $('#txtAreaGrowthInfo').val();
                existingText += '\n' + Growthtext;
                $('#txtAreaGrowthInfo').val(Growthtext);
            });
            $('#btnOrganism').click(function () {

                row = '<tr><td>' +
                    //$('#ddlOrganism').find('option:selected').text() +
                    $('#ddlOrganism').find('option:selected').text() +
                    '</td><td><input type="text" class="arrow" autocomplete="off" name="orgvalue" id="orgvalue" value="" style="width: 60px !important;"/></td><td> <input type="text" class="arrow" autocomplete="off" name="orgvalue2" id="orgvalue2" value="" style="width: 60px !important;"/></td><td> <input type="text" class="arrow" autocomplete="off" name="orgvalue3" id="orgvalue3" value="" style="width: 60px !important;"/> </td><td> <a href="javascript:void(0)" onclick="DeleteOrganism(this)">Delete</a></td></tr>';
                // $("#tblOrganism tbody").remove();
                var table = $('#tblOrganism tbody');
                table.append(row);
                $("#ddlOrganism").select2('open');
                // var Organism = $('#ddlOrganism').text();
                //var Organism = ddlOrganism.options[ddlOrganism.selectedIndex].text;
                //var existing = $('#TextareaOrganism').val();
                //existing += '\n' + Organism;
                //$('#TextareaOrganism').val(existing.trim());
            });
            $('#chkUltraSound_level').change(function () {

                var getVal = this.value;
                if (getVal == "") {
                    CKEDITOR.instances.txtfixedType.setData("");
                }
                PageMethods.FillUltrasound_level(getVal, function (resp) {
                    var fixedVal = JSON.parse(resp);
                    CKEDITOR.instances.txtfixedType.setData(fixedVal);
                });
            });
            $('#btnApprove').click(function () {

                test_list = [];
                var tbl = $("#tblgroupTestlist tbody tr");

                $.each(tbl, function (key, val) {

                    var name = $(val).find('input[name="testDepartment"]').attr('name');
                    if (name == "testDepartment") {
                    }
                    else {
                        var Ids = $(val).find('td:eq(0)').text();
                        //$(val).find('td[id=testDetailID]').text();
                        test_list.push({ 'TestDID': Ids });
                    }
                });
                //For Single Tests
                var testID = $('#hdtestdetailid').val();
                if (testID != null && testID > 0) {
                    test_list.push({ 'TestDID': testID });
                }
                var Lab_ID = 0;
                var TesttDetails = { Lab_ID: Lab_ID == '(New)' ? 0 : Lab_ID, test_list: test_list }
                if (test_list.length > 0) {
                    PageMethods.ApproveTestDetailCat(Lab_ID, JSON.stringify(TesttDetails), function (response) {

                        //alert(response)
                        $("[id$='_btnRefresh']").trigger('click');
                        $('#myModal').modal('hide');
                        $("#myModal tbody").empty();
                        $("#tblsingleTest tbody").empty();
                    }, function (onfailure) {

                        alert(onfailure);
                    });
                }
            });
            $('#btnReject').click(function () {
                localStorage.isSaved = 1;
                test_list = [];
                var tbl = $("#tblgroupTestlist tbody tr");
                $.each(tbl, function (key, val) {

                    var name = $(val).find('input[name="testDepartment"]').attr('name');
                    if (name == "testDepartment") {
                    }
                    //});
                    else {
                        var Ids = $(val).find('td:eq(0)').text();
                        //$(val).find('td[id=testDetailID]').text();
                        test_list.push({ 'TestDID': Ids });
                    }
                });
                //For Single Tests
                var testID = $('#hdtestdetailid').val();
                if (testID != null && testID > 0) {
                    test_list.push({ 'TestDID': testID });
                }
                var Lab_ID = 0;
                var TesttDetails = { Lab_ID: Lab_ID == '(New)' ? 0 : Lab_ID, test_list: test_list }
                if (test_list.length > 0) {
                    PageMethods.RejectTestDetail(Lab_ID, JSON.stringify(TesttDetails), function (response) {

                        $("[id$='_btnRefresh']").trigger('click');
                        $('#myModal').modal('hide');
                        $("#myModal tbody").empty();
                        $("#tblsingleTest tbody").empty();
                    }, function (onfailure) {

                        alert(onfailure);
                    });
                }

            });
            $('#saveTest').click(function () {
                localStorage.isSaved = 1;
                debugger;
                if (isGroup) { //Save group Test
                    debugger;
                    var table = $('#tblgroupTestlist');
                    var test_list = [];
                    var Rem = CKEDITOR.instances.txtMaster_Remarks.getData();
                    table.find('tr:gt(0)').each(function (key, value) {
                        //new code 

                        var Rem2 = CKEDITOR.instances['txtfixedTypeGroup' + key + ''].getData();
                        var array = {};
                        var lab_test_Detail_id = $($(value).find('td')[0]).text();
                        //var lab_test_Detail_id = $($(rowSave).parents('tr')[0]).find('td:eq(0)').text();
                        var filesComplete = $($(value).find('td')[5]).get(0).files;
                        if (typeof filesComplete === 'undefined')
                            filesComplete = 0;

                        var datas = new FormData();
                        for (var i = 0; i < filesComplete.length; i++) {
                            datas.append(filesComplete[i].name, filesComplete[i]);
                        }
                        datas.append('lab_test_Detail_id', lab_test_Detail_id);

                        //var fixed_values = $($(value).find('td')[2]).text();
                        var fixed_values = Rem2;
                        if (fixed_values == "") fixed_values = '0';

                        var value_type = $($(value).find('td')[3]).text();
                        if (value_type == "") value_type = "0";
                        var result_type = $($(value).find('td')[4]).find('select').val();
                        var Master_Remarks = Rem;
                        if (result_type == null) result_type = "0";
                        var Growthtype = $($(value).find('td')[5]).find('select').val();
                        var OrganismType = $($(value).find('td')[6]).find('select').val();
                        var GetBillDetailID = $($(value).find('td')[7]).text();

                        var options = {};
                        options.url = "ImageUpload.ashx";
                        options.type = "POST";
                        options.data = datas;
                        options.contentType = false;
                        options.processData = false;
                        //options.success = function (result) { alert(result) };
                        //options.error = function (err) { alert(err.statusText); };
                        $.ajax(options);
                        //end
                        array.lab_test_Detail_id = lab_test_Detail_id;
                        array.fixed_values = fixed_values;
                        array.value_type = value_type;
                        array.result_type = result_type;
                        array.Growthtype = Growthtype;
                        array.OrganismType = OrganismType;
                        array.Master_Remarks = Master_Remarks;
                        array.BillDetailID = GetBillDetailID;
                        test_list.push(array);

                        //test_list.push({

                        //    'lab_test_Detail_id': lab_test_Detail_id,
                        //    'fixed_values': fixed_values,
                        //    'value_type': value_type,
                        //    'result_type': result_type,
                        //    'Growthtype': Growthtype,
                        //    'OrganismType': OrganismType,
                        //    //'fixed_val': fixed_val, 'value_type': value_type, 'List_type': List_type
                        //});

                    });
                    var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
                    debugger;
                    var chkBillID = $("#hdBill_id").val();
                    if (chkBillID == "(New)") {
                        localStorage.Bill_No = chkBillID;
                    }
                    //var TesttDetails = {test_list: test_list }
                    PageMethods.SaveGroupTest(Lab_ID, test_list, function (response) {


                        $('#myModal').modal('hide');
                        $("[id$='_btnRefresh']").trigger('click');

                    });
                }
                else //Save Single Test
                {

                    debugger;
                    var labTestDetailID = $("#ltdID").val();
                    var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
                    //TestID = $($(row).find('td input[name=labtestDID]')[0]).val();
                    var startRange = '';
                    var endRange = '';
                    //new org table save
                    var i = 0;
                    Organism_List = [];
                    $.each($('#tblOrganism tbody tr'), function (key, value) {

                        var OrgName = $($(value).find('td')[0]).text();
                        var OrgValue = $(value).find('input[name="orgvalue"]').val();
                        var OrgValue2 = $(value).find('input[name="orgvalue2"]').val();
                        var OrgValue3 = $(value).find('input[name="orgvalue3"]').val();
                        var orgname_header = $("#tblOrganism").find('th:eq(1)').text();
                        var orgname_header2 = $("#tblOrganism").find('th:eq(2)').text();
                        var orgname_header3 = $("#tblOrganism").find('th:eq(3)').text();
                        Organism_List[i] = new Array(OrgName, OrgValue,
                            OrgValue2, OrgValue3, orgname_header,
                            orgname_header2, orgname_header3, Lab_ID, globalTestId);
                        i++;
                    });
                    PageMethods.SaveOrganismList(Organism_List, Lab_ID, bill_detailid, function (response) {
                    });

                    var valueofTemplate = CKEDITOR.instances.txtfixedType.getData();
                    var Master_Remarks = CKEDITOR.instances.txtMaster_Remarks.getData();
                    var valuetype = $("#txtvaluetype").val();
                    var GrowthType = $("#txtAreaGrowth").val();
                    var OrganismType = $("#TextareaOrganism").text();
                    var GrowthType_Info = $("#txtAreaGrowthInfo").val();
                    var level = $("#chkUltraSound_level   option:selected").val();
                    if (typeof level === "undefined") {
                        level = "";
                    }
                    if (valuetype == '') valuetype = '0';
                    var filesComplete = $("#ctl00_MainContent_fileUploadMultiple").get(0).files;

                    var dataImgs = new FormData();
                    for (var i = 0; i < filesComplete.length; i++) {
                        dataImgs.append(filesComplete[i].name, filesComplete[i]);
                    }
                    var lab_test_Detail_id = $("#hdtestdetailid").val();
                    dataImgs.append('lab_test_Detail_id', lab_test_Detail_id);
                    $("#ctl00_MainContent_session_obejct").val(lab_test_Detail_id);


                    var chkBillID = $("#hdBill_id").val();
                    if (chkBillID == "(New)") {
                        localStorage.Bill_No = chkBillID;
                    }
                    $("[id$='_buttonimageuploadNotes']").trigger('click');
                    arr = [];
                    $("#ddllistType option").each(function (key, index) {
                        list = {};
                        list.values = $(this).text();
                        arr.push(list);
                    });
                    //console.log(list);
                    var resultVal = $("#ddllistType").val();
                    var data = JSON.stringify({
                        "valuetype": valuetype,
                        "valueofTemplate": valueofTemplate,
                        "Lab_ID": Lab_ID,
                        "testDetailID": testDetailID,
                        "CatID": CatID,
                        "resultVal": resultVal,
                        "GrowthType": GrowthType,
                        "GrowthTypeInfo": GrowthType_Info,
                        "OrganismType": OrganismType,
                        "Master_Remarks": Master_Remarks,
                        "Levels": level
                    });

                    $.ajax({
                        type: "POST",
                        url: "LabTestResult.aspx/SaveTestDetail",
                        data: data,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            if (data.d == 'Successfull') {
                                alert("Saved");
                            }
                            setTimeout(function () { $('#myModal').modal('hide'); }, 3000);
                        },
                        failure: function (response) {
                            alert(response.d);
                        }
                    });
                }

            });
            $('#tblgroupTestlist tbody td').click(function () {

                //var cid = $(this).attr('id');
                //alert(cid);
                var cval = $(this).text();
                alert(cval);
            });
            // Approve Test Result
            $('#btnApprove').click(function () {
                localStorage.isSaved = 1;
                $('#mTestName')
                $('#mTestGroup')
                var department = $('#mTestDepartment').val();
                var maindepartment = $('#mMainDepartment').val();
                var status = $('#mStatus').val();
                var testvalue = $('#mTestValue').val();
                if (typeof testvalue === "undefined") testvalue = 0;
                var template = $('#mTestTemplate').val();
                if (typeof template === "undefined") template = 0;
                //  var template = CKEDITOR.instances.mTestTemplate.getData();;

                var diagnosis = $('#mTestDiagnosis').val();
                var notes = $('#mTestNotes').val();
                var mTestID = $('#mTestID').val();
                var testID = $('#testDetailID').val();
                if (mTestID == "0") {
                    var table = $('#tblCatValues');
                    var test_list = [];
                    table.find('tr').each(function (key, value) {
                        test_list.push({ 'TestDID': $(value).find('td input[name= labtestDID]').val(), 'Value': $(value).find('td input[name=txtValue]').val() });
                    });
                    var Lab_ID = $("#hdnLab_Test_ID").val();
                    var TesttDetails = { Lab_ID: Lab_ID == '(New)' ? 0 : Lab_ID, test_list: test_list }
                    PageMethods.ApproveTestDetailCat(Lab_ID, JSON.stringify(TesttDetails), function (response) {
                        $('#myModal').modal('hide');

                        $('#result' + GroupCatID + '').text("View Result");
                    });
                }
                else {


                    var data = JSON.stringify({ TestDetailID: testID, TestValue: testvalue, Template: template, Diagnosis: diagnosis, Notes: notes, });
                    $.ajax({
                        type: "POST",
                        url: "LabTestResult.aspx/ApproveTestDetail",
                        data: data,
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (data) {

                            //$('#mTestValue').val('');
                            $('#mTestDiagnosis').val('');
                            $('#mTestNotes').val('');
                            $('#myModal').modal('hide');
                            var id = $("#hdnLab_Test_ID").val();
                            $('#result' + id + '').text("Conducted");
                        },
                        failure: function (response) {
                            alert(response.d);
                        }
                    });
                }
            });

            //var ageInput = document.getElementByName("age")

            //ageInput.addEventListener("keydown", function (e) {
            //    // prevent: "e", "=", ",", "-", "."
            //    if ([69, 187, 188, 189, 190].includes(e.keyCode)) {
            //        e.preventDefault();
            //    }
            //})
            FillGrowthType();
            FillOrganismType();
            FillGrowthInfo();
        });
        function readIMG(input) {

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

            var countFiles = $(input)[0].files.length;
            var imgPath = $(input)[0].value;
            var extn = imgPath.substring(imgPath.lastIndexOf('.') + 1).toLowerCase();
            if (extn == "gif" || extn == "png" || extn == "jpg" || extn == "jpeg") {
                if (typeof (FileReader) != "undefined") {
                    //loop for each file selected for uploaded.
                    for (var i = 0; i < countFiles; i++) {

                        var reader = new FileReader();
                        reader.onload = function (e) {

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

            $.ajax({
                type: "post",
                url: "LabTestResult.aspx/PendingResultList",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    //alert(respose.d)
                    var parse = JSON.parse(response.d);
                    var rows = "";
                    for (var i = 0; i < parse.length; i++) {
                        var mydate = moment(parse[i].Bill_Date).format('D MMMM YYYY h:mm:ss a');
                        //var mydate = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse[i].Bill_Date.substring(6, 19))))

                        rows += '<tr><td style="display:none;">' + parse[i].Patient_ID + '</td><td>' + parse[i].Bill_No + '</td><td>' + mydate + '</td><td>' + parse[i].Full_Name + '</td><td>' + parse[i].Father_Name + '</td><td>' + parse[i].Patient_Category + '</td><td>' + parse[i].Test_Status + '</td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="fillTokenInput(' + parse[i].Bill_No + ')">Select</a></td></tr>';
                    }
                    $("#tblPendingPatientsLIst").append(rows);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function GetSelectedDetail(patient_ID) {

            //var PatientID = $('#hdfPatient_ID').val();
            if (patient_ID != "") {
                $('#txtMR_No').tokenInput('clear');
                var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + patient_ID);

                $('#txtMR_No').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
                $("#hdPatientID").val(JSON.parse(tokendata)[0].id);
                //if (localStorage.IsLabTest == 1) {
                //    debugger;
                //    localStorage.IsPatient = 0;
                //    localStorage.IsLabTest = 1;


                //}
                //else {
                //    localStorage.IsPatient = 1;
                //    localStorage.IsLabTest = 0;

                //}

                GetPatientDetail();
            }
            else {
                //tokenInputs('txtMR_No', 'Patients');
            }
        }
        function image(input) {

            var output = document.getElementById('image');
            var a = URL.createObjectURL(input.files[0]);
            console.log(a);
        }
        function CheckNumberOrNot(e) {

            var check = true;
            // prevent: "e", "=", ",", "-", "."
            if ([69, 187, 188, 189, 190].includes(e.keyCode))
                check = false;

            var charCode = (e.which) ? e.which : e.keyCode;

            if (charCode > 31 && (charCode < 48 || charCode > 57))
                check = false;

            if (check == false) {

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

            var storageBillNo = localStorage.Bill_No;
            if (storageBillNo != "(New)") {
                $("#ctl00_MainContent_txtBilling").val(storageBillNo);

                loadPatientDataUsingBillId();


            }

            var hdFile_ID = $("#hdnPatient_ID").val();
            if (hdFile_ID != "(New)") {

                var Patient_ID = $("#hdnPatient_ID").val();
                var tokendata = httpGet("json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {

                loadtokenInputsDefault();
            }
            //var hdFile_ID = $("#hdnLab_Test_ID").val();
            //if (hdFile_ID != "(New)") {
            //    var Lab_Test_ID = $("#hdnLab_Test_ID").val();
            //    var tokendata = httpGet("json.aspx?Table=Laboratory_Test&Record=Edit&q=" + Lab_Test_ID);
            //    loadPatientDataUsingLabID();
            //}
            //else {
            //    $('#ctl00_MainContent_txtLab_Test_ID').tokenInput("json.aspx?Table=Laboratory_Test",
            //{
            //    tokenLimit: 1,
            //    onAdd: function (item) {
            //        try {
            //            
            //            $("#hdnLab_Test_ID").val(item.id);
            //            loadPatientDataUsingLabID();
            //        }
            //        catch (err) {
            //            alert(err.message);
            //        }
            //    }
            //});
            //}
            var hdFile_ID = $("#hdnLab_Test_ID").val();
            if (hdFile_ID != "(New)") {
                var Lab_Test_ID = $("#hdnLab_Test_ID").val();
                var tokendata = httpGet("json.aspx?Table=Billing&Record=Edit&q=" + Lab_Test_ID);
                loadPatientDataUsingLabID();
            }
            else {

                $('#ctl00_MainContent_txtBilling').tokenInput("json.aspx?Table=Billing",
                    {
                        tokenLimit: 1,
                        onAdd: function (item) {
                            try {
                                localStorage.billid = 1
                                localStorage.patientid = 0
                                localStorage.isSaved = 0
                                $("#hdBill_id").val(item.id);
                                $("#hdnBill_No").val(item.name);
                                loadPatientDataUsingBillId();
                                //    loadPatientDataUsingLabID();
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
                            localStorage.billid = 0
                            localStorage.patientid = 1
                            localStorage.isSaved = 0
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

            var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            var Lab_id = $("#ctl00_MainContent_txtLab_Test_ID").val();
            if (Lab_ID == null || Lab_ID == "(New)") {
                $.ajax({
                    type: "POST",
                    url: "LabTestResult.aspx/GetDetail",
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

        debugger;
        function GetLabDetailAgainstBill() {
            debugger;

            var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
            var Bill_ID = $("#hdBill_id").val();
            if (Patient_ID == null || Patient_ID == "" || Patient_ID == "(New)") {
                Patient_ID = "0";
            }
            if (Bill_ID == null || Bill_ID == "" || Bill_ID == "(New)") {
                Bill_ID = 0;
            }
            PageMethods.GetLabDetailByBill_id(Patient_ID, Bill_ID, function (res) {
                debugger;
                var Test = JSON.parse(res);
                var rows = '';
                var preview = '';
                $.each(Test, function (key, value) {


                    //  $("#ctl00_MainContent_txtBilling").val(value.LabID);

                    if (value.MainDepartment == null)
                        value.MainDepartment = "";
                    if (value.TestDepartment == null)
                        value.TestDepartment = "";
                    if (value.Unit_Name == null)
                        value.Unit_Name = ""
                    if (value.Rejected_Reason == null)
                        value.Rejected_Reason = ""

                    if (value.Is_Result == true) {
                        result = "View Result";
                    }
                    else {
                        result = "Add Result"
                    }
                    var dd = tbltestid.rows.length;
                    test_wise_id = value.patient_ID;
                    if (value.Group_Category != "") {
                        if (value.Is_Result == true && value.Is_Approve == true) {

                            result = "View Result";
                            preview = "Preview";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                        //Only View Result Will Show
                        else if (value.Is_Result == true && value.Is_Approve == false) {

                            result = "View Result";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                        else {

                            //Group Test
                            //Add Result Will Show
                            result = "Add Result"
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }

                    }
                    else {
                        if (value.Is_Result == true && value.Is_Approve == true) {

                            result = "View Result";
                            preview = "Preview";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                        //Only View Result Will Show
                        else if (value.Is_Result == true && value.Is_Approve == false) {

                            result = "View Result";
                            preview = "";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                        //Add Result Will Show
                        else {

                            result = "Add Result";
                            preview = "";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                    }
                    //if (value.Is_Approve == true) {
                    //    result = "View Result";
                    //    preview = "Preview";
                    //}
                    //else {
                    //    result = "View Result";
                    //    preview = "";
                    //}
                    ////Single Test
                    //rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a>| <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/></td></tr>';

                });

                $('.table tbody').html(rows);
                //    removeDuplicates();
                //var contents = {},
                // duplicates = false;
                //$("#tblLabTest td").each(function () {
                //    var tdContent = $(this).text();
                //    if (contents[tdContent]) {
                //        duplicates = true;
                //        return false;
                //    }
                //    contents[tdContent] = true;
                //});
                //if (duplicates)
                //    alert("There were duplicates.");
                //$("#tblLabTest tr:contains('true')").css("color", "red");
                $(".tdemergency").hide();

            });
        }
        function removeDuplicates() {
            var seen = {};
            $('#tblLabTest tr ').each(function () {
                debugger;
                var test_id = $(this).find('td:eq(1) #labtestDID').val();
                var test_name = $(this).find('td:eq(3)').text();
                var date = $(this).find('td:eq(5)').text();

                if (seen[test_name] && seen[test_id] && seen[date]) {
                    $(this).remove();
                }
                else {
                    seen[test_name] = true;

                }
            });

        }
        debugger;
        // test_wise_id;
        function PreviewReport($this) {
            debugger;
            //alert(patIddddd);
            var tbl = $($($this).parents('tr')[0]);
            //var Patient_ID = $('#hdnPatient_ID').val();
            var ChkLetterHead = true;
            var ListOfTestIDs = '';
            var ListTransID = '';
            var Report_Column = '';
            var LabTestDetailsID = '';
            debugger;
            Report_Column = tbl.find('td').find('input[name=Report_Colum]').val();
            ListOfTestIDs = tbl.find('td').find('input[name=List_Of_Test_IDs]').val();
            test_wise_ids = tbl.find('td').find('input[name=test_wise_id]').val();
            // PatientID = tbl.find('td').find('input[name=patient_Id]').val();
            //ListTransID = tbl.find('td:eq(0)').text();
            ListTransID = tbl.find('td:eq(1)').text();
            //LabTestDetailsID = tbl.find('td:eq(2)').text();
            LabTestDetailsID = tbl.find('td:eq(2)').text();
            var billdetailid = tbl.find('td:eq(10) #Bill_Details_ID').val()
            var testIds = tbl.find('td:eq(10) #ListOfTestIDs').val();
            if (testIds == "null" || testIds == '') {
                debugger;
                //testIds = tbl.find('td:eq(1) #labtestDID').val();
                testIds = tbl.find('td:eq(1) #labtestDID').val();
                //testIds = tbl.find('td:eq(1)').find('input').attr('labid')
                ListOfTestIDs = testIds;
            }
            else {
                //ListOfTestIDs += ', ' + tbl.find('#labtestDID').val();
            }
            debugger;

            ListBillDetailID = billdetailid.replace(', ', '');
            window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead);
        }

        //function PreviewReport($this) {
        //    debugger;
        //    var tbl = $($($this).parents('tr')[0]);
        //    var Patient_ID = $('#hdnPatient_ID').val();
        //    var ChkLetterHead = true;
        //    var ListOfTestIDs = '';
        //    var ListTransID = '';
        //    var Report_Column = '';
        //    var LabTestDetailsID = '';

        //    Report_Column = tbl.find('td').find('input[name=Report_Colum]').val();
        //    ListOfTestIDs = tbl.find('td').find('input[name=List_Of_Test_IDs]').val();
        //    //ListTransID = tbl.find('td:eq(0)').text();
        //    ListTransID = tbl.find('td:eq(1)').text();
        //    //LabTestDetailsID = tbl.find('td:eq(2)').text();
        //    LabTestDetailsID = tbl.find('td:eq(2)').text();
        //    var billdetailid = tbl.find('td:eq(10) #Bill_Details_ID').val()
        //    var testIds = tbl.find('td:eq(10) #ListOfTestIDs').val();
        //    if (testIds == "null" || testIds == '') {
        //        debugger;
        //        //testIds = tbl.find('td:eq(1) #labtestDID').val();
        //        testIds = tbl.find('td:eq(1) #labtestDID').val();
        //        //testIds = tbl.find('td:eq(1)').find('input').attr('labid')
        //        ListOfTestIDs = testIds;
        //    }
        //    else {
        //        //ListOfTestIDs += ', ' + tbl.find('#labtestDID').val();
        //    }

        //    ListBillDetailID = billdetailid.replace(', ', '');
        //    window.open('ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&Patient_ID=' + Patient_ID + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead);
        //}
        debugger;
        var test_wise_id;
        function GetLabDetail() {
            debugger;
            var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            if (Patient_ID == null || Patient_ID == "" || Patient_ID == "(New)") {
                Patient_ID = "0";
            }
            if (Lab_ID == null || Lab_ID == "" || Lab_ID == "(New)") {
                Lab_ID = 0;
            }
            if (localStorage.isSaved == 1 && localStorage.patientid == 1) {
                Lab_ID = 0;
            }
            PageMethods.GetLabDetail(Patient_ID, Lab_ID, function (res) {
                debugger;
                var Test = JSON.parse(res);
                var rows = '';
                var preview = '';
                $.each(Test, function (key, value) {


                    $("#<%= txtLab_Test_ID.ClientID %>").val(value.LabID);

                    if (value.MainDepartment == null)
                        value.MainDepartment = "";
                    if (value.TestDepartment == null)
                        value.TestDepartment = "";
                    if (value.Unit_Name == null)
                        value.Unit_Name = ""
                    if (value.Rejected_Reason == null)
                        value.Rejected_Reason = ""
                    if (value.Is_Result == true) {
                        result = "View Result";
                    }
                    else {
                        result = "Add Result"
                    }
                    debugger;
                    var dd = tbltestid.rows.length;
                    test_wise_id = value.patient_ID;
                    if (value.Group_Category != "") {
                        if (value.Is_Result == true && value.Is_Approve == true) {
                            result = "View Result";
                            preview = "Preview";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + test_wise_id + '"/></td></tr>';
                        }
                        //Only View Result Will Show
                        else if (value.Is_Result == true && value.Is_Approve == false) {
                            result = "View Result";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.patient_ID + '"/></td></tr>';
                        }
                        else {
                            //Group Test
                            //Add Result Will Show
                            result = "Add Result"
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.patient_ID + '"/></td></tr>';
                        }

                    }
                    else {
                        if (value.Is_Result == true && value.Is_Approve == true) {
                            result = "View Result";
                            preview = "Preview";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.patient_ID + '"/></tr>';
                        }
                        //Only View Result Will Show
                        else if (value.Is_Result == true && value.Is_Approve == false) {
                            result = "View Result";
                            preview = "";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.patient_ID + '"/></td></tr>';
                        }
                        //Add Result Will Show
                        else {
                            result = "Add Result";
                            preview = "";
                            rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a> | <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '"></span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/><input type="hidden" name="test_wise_id" id="test_wise_id" value="' + value.patient_ID + '"/></td></tr>';
                        }
                    }



                    //Group Test
                    //if (value.Is_Approve == true)
                    //{
                    //    result = "View Result";
                    //    preview = "Preview";
                    //}
                    //else
                    //{
                    //    result = "View Result";
                    //    preview = "";
                    //}

                    //    rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_ID + '">' + result + '</span></a>| <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/></td></tr>';
                    //}
                    //else
                    //{
                    //    if (value.Is_Approve == true) {
                    //        result = "View Result";
                    //        preview = "Preview";
                    //    }
                    //    else {
                    //        result = "View Result";
                    //        preview = "";
                    //    }
                    //    //Single Test
                    //    rows += '<tr><td><input type="checkbox" name="chkReport" value=""/></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td><td>' + value.Service_Date + '</td><td>' + value.Unit_Name + '</td><td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a>| <a href="javascript:void(0)" onclick="PreviewReport(this)"><span id="isApprove" value="' + value.Is_Approve + '">' + preview + '</span></a></td><td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + value.Emergancy + '</td><td style="display:none;"><input type="hidden" name="Group_Category" id="GroupCategory" value="' + value.Group_Category + '" /><input type="hidden" name="List_Of_Test_IDs" id="ListOfTestIDs" value="' + value.ListOfTestIDs + '"/><input type="hidden" name="Bill_Details_ID" id="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Report_Colum" id="Report_Colum" value="' + value.Report_Colum + '"/></td></tr>';
                    //}

                });

                $('.table tbody').html(rows);
                // removeDuplicates();
                //$("#tblLabTest tr:contains('true')").css("color", "red");
                $(".tdemergency").hide();

            });
        }

        //Pending
        function GetLabDetailUsingLabID() {

            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            PageMethods.GetLabDetailUsingLabID(Lab_ID, function (res) {
                var Test = JSON.parse(res);
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
                    else { result = "Add Result" }
                    var dd = tbltestid.rows.length;
                    if (value.Lab_Test_Detail_ID == null) {
                        value.Lab_Test_Detail_ID = ""



                        //Group Test
                        rows += '<tr><td><input type="checkbox" name="chkReport" value=""></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + Lab_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td style="color:red"><input type="hidden"  value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.MainDepartment + '</td><td>' + value.TestDepartment + '</td><td>' + value.Unit_Name + '</td><td>' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.GroupCategory_ID + '">' + result + '</span></a><input type="hidden" name="CatID" value="' + value.GroupCategory_ID + '"></td></tr>';
                    }
                    else {
                        //Single Test
                        rows += '<tr><td><input type="checkbox" name="chkReport" value=""></td><td><input type="hidden" name="labtestDID" id="labtestDID" value="' + value.Test_ID + '" />' + Lab_ID + '</td><td style="display:none">' + value.Lab_Test_Detail_ID + '</td><td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + value.Test_Name + '</td><td><input type="hidden"  value="' + value.Parent_Transaction_Type_ID + '" />' + value.MainDepartment + '</td><td>' + value.TestDepartment + '</td><td>' + value.Unit_Name + '</td><td>' + (value.Status ? 'Paid' : 'Unpaid') + '</td><td><input type="hidden" id="valuetype" value="' + value.ValueType + '"><a href="javascript:void(0)" onclick="EditData(this)"><span id="result' + value.Lab_Test_Detail_ID + '">' + result + '</span></a></td></tr>';
                    }
                });
                $('.table tbody').html(rows);
            });
        }
        function loadPatientDataUsingLabID() {

            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            $("#ctl00_MainContent_txtPatient_ID").val("");
            $.ajax({
                type: "POST",
                url: "LabTestResult.aspx/GetDetailUsingLabID",
                data: "{'Lab_ID':" + Lab_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function loadPatientDataUsingBillId() {
            debugger;
            var Bill_No = $("#hdnBill_No").val();
            localStorage.Bill_No = Bill_No;

            var Bill_ID = $("#hdBill_id").val();
            $("#ctl00_MainContent_txtPatient_ID").val("");
            $.ajax({
                type: "POST",
                url: "LabTestResult.aspx/GetDetailUsingBillID",
                data: "{'Bill_ID':" + Bill_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccessBill,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function OnSuccessBill(data) {
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

                //GetLabDetailUsingLabID();

                setTimeout(function () {
                    GetLabDetailAgainstBill();

                }, 2500)

            }
        }
        var checkCatagory;
        //function select3(check) {
        //    
        //    var row = $(check).parents('tr')[0];
        //  $($($check).parents('tr')[0]).find('td:nth-child(2)')[0].innerText
        //  var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
        //    var Lab_ID = $(row).find('td:eq(1)').text();
        //    var trnsid = $(row).find('td input[name=chkReport]')[0].checked;
        //    var CatID = $($(row).find('td input[name=labtestDID]')[0]).val();
        //    if (trnsid == true) {
        //        
        //        PageMethods.LoadTestCatogry(Lab_ID, CatID, function (res) {
        //            
        //            var Test = JSON.parse(res);
        //            var rows = '';
        //            $.each(Test, function (key, value) {
        //                
        //                rows += value.Lab_Detail_ID + ',';
        //            });
        //            $($(row).find('td')[2]).text(rows);
        //        });
        //    }
        //    else {
        //        $($(row).find('td')[2]).text('');
        //    }
        //}
        function showImage(testDetailID, single) {

            PageMethods.LoadimagesDetail(testDetailID, single, function (res) {

                var container = '';
                container = $('#container');
                if (res == null || res == "[]" || res == "undefined") {
                    $("#errorMsg").show();
                    container.html('');
                }
                else { $("#errorMsg").hide(); }

                var test = JSON.parse(res);
                var counter = test[0].Single;
                var rows = '';


                container.innerHTML = "";
                container.html('');
                localStorage.clear();
                $.each(test, function (key, value) {
                    // var img = $("<img onclick='window.open(this.src)' />");


                    var img = $('<img onclick="window.open(this.src)" src=""/><a href="#" onclick="deleteImage(this)">Delete</a>');
                    img.attr("style", "height:82px;width: 82px");
                    var dd = value.Image_path;

                    img.attr("src", dd);

                    container.append(img);

                    if (value.Image_path == null || value.Image_path == "") {
                        $("#errorMsg").show();
                    }
                    else { $("#errorMsg").hide(); }
                });
            });
        }
        $(document).ready(function () {



            if (CKEDITOR) {
                CKEDITOR.replace('txtfixedType');
            }

            $('#txtMRNOSearch').keyup(function (e) {

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
            $("#chkUltraSound_level").hide();
            $('#SearchFilter').change(function (e) {

                //var CheckAll = $('#chkTodayAll').checked;

                var MRno = $('#SearchFilter :selected').text();
                var tbl = document.getElementById('tblPendingPatientsLIst');
                if (MRno.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[4].innerText != MRno.trim()) {
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

        function LabTestMultipleID(testID) {
            debugger;
            PageMethods.getResultValues(testID, function (res) {

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

            //$('#saveTest').val("UnApprove");
            checkUnApproved = true;

        }
        //  var j = jQuery.noConflict();
        var GroupCatID = "";
        var isGroup = '';
        var testDetailid = '';
        var CatID = '';
        var appendedRow = '';
        var result_type_value = '';
        var result_type_fixed = '';
        var result_type_list = '';
        var arrayTemp = '';
        var bill_detailid = '';
        var detail_id = '';

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
            bill_detailid = billDetailID;

            if (Group_Categroy == "") {
                $("#tblgroupTestlist").hide();
                $("#tblsingleTest").show();
                $("#saveTest").show();
            }
            else {

                $("#tblgroupTestlist").show();
                $("#tblsingleTest").hide();
                // $("#saveTest").hide();
            }
            // setTimeout(function () { 

            $('#myModal').modal('hide');
            PageMethods.LoadTestCatogry(LabID, CatID, billDetailID, function (res) {
                debugger;

                var parsedData = JSON.parse(res);
                var row = '';
                if (Group_Categroy === "") // Single
                {
                    $('#dvSingleTestName').show();
                    $('#pTestName').text($($($this).parents('tr')[0]).find('td:nth-child(4)')[0].innerText);
                    $("#tblsingleTest td:eq(2)").show();
                    $("#tblsingleTest th:eq(2)").show();
                    $("#tblsingleTest td:eq(3)").show();
                    $("#tblsingleTest th:eq(3)").show();
                    $("#tblsingleTest td:eq(4)").show();
                    $("#tblsingleTest th:eq(4)").show();
                    $("#tblsingleTest td:eq(5)").show();
                    $("#tblsingleTest th:eq(5)").show();
                    $("#tblsingleTest td:eq(6)").show();
                    $("#tblsingleTest th:eq(6)").show();
                    // single
                    var single = "1";
                    isGroup = false;
                    var test_id = parsedData[0].Test_ID;
                    LabTestMultipleID(test_id);
                    //  LabTestMultipleID(CatID);
                    $.ajax({

                        type: "POST",
                        url: "LabTestResult.aspx/GetTestDetail",
                        data: "{'TestDetailID':" + testDetailID + ",'LabID':" + LabID + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            debugger;
                            var data = JSON.parse(response.d);
                            console.log(data);
                            var result_value = data[8];
                            var IS_Culture = data[18];
                            var range = data[13];
                            var fixedValue = data[14];
                            var growth = data[15];
                            result_type_value = data[10];
                            result_type_fixed = data[11];
                            result_type_list = data[12];
                            Master_Remarks = data[17];
                            var Ranges = data[19]; //Gender Vise
                            var AllRange = data[20]; //All 
                            var CheckLevel = data[23];//Check Levels
                            var TestID = data[21];
                            var UltraLevels = data[24];
                            var TestRange = '';
                            var ResultTypeImage = data[26];
                            var is_Result = data[27];
                            var is_Approved = data[24];
                            //var AllRanges = Start_Range + " - " + End_Range;
                            var MainDept = data[2];
                            //$('#chkUltraSound_level').prop('selectedIndex', UltraLevels);
                            if (CheckLevel == "True") {

                                $("#chkUltraSound_level").show();
                                getAllLevels(TestID);
                            }

                            //$('#chkUltraSound_level').val(UltraLevels)
                            console.log(data);
                            $('#txtfixedType').val(fixedValue);
                            $('#txtMaster_Remarks').val(Master_Remarks);
                            $('#txtAreaGrowth').text(growth);
                            //$('#txtAreaGrowth').val(Growth_Type);
                            //  $('#TextareaOrganism').val(Organism_Type);

                            CKEDITOR.instances.txtfixedType.setData(fixedValue);
                            CKEDITOR.instances.txtMaster_Remarks.setData(Master_Remarks);
                            if (Ranges == null) {
                                TestRange = AllRange;
                            }
                            else {
                                TestRange = Ranges;
                            }
                            if (Ranges == null || Ranges == '') {
                                TestRange = AllRange;
                            }
                            else {
                                TestRange = Ranges;
                            }
                            $('#ranges').val(TestRange);
                            $('#txtvaluetype').val(range);
                            $("#ddllistType").val(result_value);

                            if (result_type_fixed != "True") {
                                $("#tblsingleTest td:eq(0)").hide();
                                $("#tblsingleTest th:eq(0)").hide();

                            }
                            else {
                                $("#tblsingleTest td:eq(0)").show();
                                $("#tblsingleTest th:eq(0)").show();
                            }
                            if (result_type_value != "True") {

                                $("#tblsingleTest td:eq(1)").hide();
                                $("#tblsingleTest th:eq(1)").hide();
                                $("#tblsingleTest td:eq(2)").hide();
                                $("#tblsingleTest th:eq(2)").hide();
                            }
                            else {

                                $("#tblsingleTest td:eq(1)").show();
                                $("#tblsingleTest th:eq(1)").show();
                                $("#tblsingleTest td:eq(2)").show();
                                $("#tblsingleTest th:eq(2)").show();
                            }

                            if (result_type_list != "True") {

                                $("#tblsingleTest td:eq(3)").hide();
                                $("#tblsingleTest th:eq(3)").hide();
                                $("#tblsingleTest td:eq(5)").hide();
                                $("#tblsingleTest th:eq(5)").hide();

                            }
                            else {

                                $("#tblsingleTest td:eq(3)").show();
                                $("#tblsingleTest th:eq(3)").show();
                                $("#tblsingleTest td:eq(5)").show();
                                $("#tblsingleTest th:eq(5)").show();
                            }
                            if (IS_Culture == "True") {

                                $("#tblsingleTest td:eq(4)").show();
                                $("#tblsingleTest th:eq(4)").show();
                                $("#tblsingleTest td:eq(5)").show();
                                $("#tblsingleTest th:eq(5)").show();
                            }
                            else {


                                $("#tblsingleTest td:eq(4)").hide();
                                $("#tblsingleTest th:eq(4)").hide();
                                $("#tblsingleTest td:eq(5)").hide();
                                $("#tblsingleTest th:eq(5)").hide();

                            }

                            if (ResultTypeImage == "True") {

                                setTimeout(function () {
                                    showImage(testDetailID, single);
                                }, 1000);
                            }
                            else {
                                $("#tblsingleTest th:eq(6)").hide();
                                $("#tblsingleTest td:eq(6)").hide();
                            }
                            if (MainDept != "Lab Test") {
                                $("#tblsingleTest td:eq(2)").hide();
                                $("#tblsingleTest th:eq(2)").hide();
                            }
                            //if ( is_Approved == "False") {
                            //     
                            //     //$('#txtvaluetype').prop("readonly", true);
                            //     $("#saveTest").val("Update");
                            //     $("#btnApprove").show();
                            //     $("#btnReject").hide();
                            // }

                            // else {
                            //     
                            //    // $('#txtvaluetype').prop("readonly", true);
                            //     $("#saveTest").hide();
                            //     $("#btnApprove").hide();
                            //     $("#btnReject").show();
                            // }
                            if (is_Result == "False" && (is_Approved == "False" || is_Approved == null)) {

                                $('#txtvaluetype').prop("readonly", false);
                                $("#saveTest").show();
                                $("#saveTest").val("Save");
                                $("#btnApprove").hide();
                                $("#btnReject").hide();
                            }
                            else if (is_Result == "True" && (is_Approved == "False" || is_Approved == null)) {

                                //$('#txtvaluetype').prop("readonly", true);
                                $("#saveTest").val("Update");
                                $("#btnApprove").show();
                                $("#btnReject").hide();
                            }

                            else {

                                $('#txtvaluetype').prop("readonly", true);
                                $("#saveTest").hide();
                                $("#btnApprove").hide();
                                $("#btnReject").show();
                            }
                            //if (CheckLevel == "True") {
                            //    
                            //    $("#chkUltraSound_level").show();

                            //    getAllLevels(TestID);
                            //     getUltraSound(TestID);
                            //}
                            setTimeout(function () {
                                $('#chkUltraSound_level').val(UltraLevels);
                            }, 1000);

                            //if (CheckLevel == "True") {
                            //    
                            //    $("#chkUltraSound_level").show();

                            //    getAllLevels(TestID);
                            //    // getUltraSound(TestID);
                            //    $('#chkUltraSound_level').val(UltraLevels)
                            //}
                            if (Ranges == null || Ranges == '') {
                                TestRange = AllRange;
                            }
                            else {
                                TestRange = Ranges;
                            }

                        }, error: function () {

                        }
                    });
                    PageMethods.LoadOrganismList(LabID, globalTestId, billDetailID, function (res) {
                        debugger;
                        var Org = JSON.parse(res);
                        if (Org.length > 0) {
                            var case1 = Org[0].Organism_Name_Header;
                            var case2 = Org[0].Organism_Name_Case2_Header;
                            var case3 = Org[0].Organism_Name_Case3_Header;
                        }


                        var rows = '';
                        $('#tblOrganism td').remove();
                        $.each(Org, function (key, value) {
                            debugger;
                            rows += '<tr><td>'
                                + value.Organism_Name + '</td><td><input id="txt_sr" class="arrow" type="text" autocomplete="off" name="orgvalue" value="'
                                + value.Organism_Value + '" /></td><td><input id="txt_sr" class="arrow" type="text" autocomplete="off" name="orgvalue2" value="'
                                + value.Organism_Name_Case2 + '" /></td><td><input id="txt_sr" class="arrow" type="text" autocomplete="off" name="orgvalue3" value="'
                                + value.Organism_Name_Case3 + '" /></td><td> <a href="javascript:void(0)" onclick="DeleteOrganism(this)">Delete</a></td></tr>';
                        });
                        $('#tblOrganism tbody').html(rows);
                        $("#tblOrganism").find('th:eq(1)').text(case1);
                        $("#tblOrganism").find('th:eq(2)').text(case2);
                        $("#tblOrganism").find('th:eq(3)').text(case3);
                    });
                    //$.ajax({
                    //    type: "POST",
                    //    url: "LabTestResult.aspx/LoadimagesDetail",
                    //    data: JSON.stringify({
                    //        "TestDetailID": testDetailID,

                    //    }),
                    //    contentType: "application/json; charset=utf-8",
                    //    dataType: "json",
                    //    success: function (data) {
                    //        
                    //        var img_index = 0;
                    //        parsed_image_data = JSON.parse(data.d);


                    //        for (var i = 0; i < parsed_image_data.length; i++) {
                    //            
                    //            $("#tblsingleTest tr:gt(0)").each(function () {
                    //                
                    //                var test_detail_id = $(this).find('td:eq(6) #hdtestdetailid').val();
                    //                //E:\Haseeb Development\GL - Mughal Eye\GL - Mughal Eye\GL\GL
                    //                var reader = new FileReader();
                    //                reader.onload = function (e) {
                    //                var img = $('<img />').attr({
                    //                    'id': 'myImage' + img_index,
                    //                    'src': parsed_image_data[2].Image_path,
                    //                    'alt': ' logo',
                    //                    'title': ' logo',
                    //                    'width': 40

                    //                }).appendTo('#container' + test_detail_id + '');

                    //                img_index++;
                    //                }
                    //                var srcs = [],
                    //                              temp;

                    //                $("img").filter(function () {
                    //                    
                    //                    temp = $(this).attr("src");
                    //                    if ($.inArray(temp, srcs) < 0) {
                    //                        srcs.push(temp);
                    //                        return false;
                    //                    }
                    //                    return true;
                    //                }).remove();
                    //            });

                    //        }



                    //    },
                    //    error: function () {


                    //    }

                    //});
                }
                else {
                    $('#dvSingleTestName').hide();
                    $("#tblsingleTest td:eq(2)").show();
                    $("#tblsingleTest th:eq(2)").show();
                    $("#tblsingleTest td:eq(3)").show();
                    $("#tblsingleTest th:eq(3)").show();
                    $("#tblsingleTest td:eq(4)").show();
                    $("#tblsingleTest th:eq(4)").show();
                    $("#tblsingleTest td:eq(5)").show();
                    $("#tblsingleTest th:eq(5)").show();
                    var single = "0";
                    //group
                    isGroup = true;

                    $('#tblgroupTestlist tr:gt(0)').remove();
                    optionsList = '<option>Please Select</option>';
                    var parsed_image_data = '';
                    $.each(parsedData, function (key, value) {
                        debugger;
                        var editable = "contenteditable";
                        if (parsedData[key].Is_Approve == true) {
                            editable = "";
                        }
                        var selectValue = '';
                        var optionsList = '';
                        var Remarks = '';
                        Remarks = parsedData[key].Master_Remarks;
                        //$('#txtMaster_Remarks').val(Remarks);
                        CKEDITOR.instances['txtMaster_Remarks'].setData(Remarks);
                        optionsList += '<option>Please Select</option>';
                        for (var i = 0; i <= parsedData[key].resultValueList.length - 1; i++) {
                            optionsList += '<option>' + parsedData[key].resultValueList[i] + ' </option>';
                        }
                        if (parsedData[key].Test_Value == null) parsedData[key].Test_Value = '';


                        var fixed = '';
                        var typeVal = '';
                        var typelist = '';
                        var TestRange = '';
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
                        if (parsedData[key].Ranges == null) {
                            TestRange = parsedData[key].AllRange;
                        }
                        else {
                            TestRange = parsedData[key].Ranges;
                        }
                        if (parsedData[key].Ranges == null || parsedData[key].Ranges == '') {
                            TestRange = parsedData[key].AllRange;
                        }
                        else {
                            TestRange = parsedData[key].Ranges;
                        }
                        if (detail_id == null || detail_id == 'null') {
                            parsedData[key].Lab_Test_Detail_ID = detail_id;
                        }
                        row = '<tr><td style="display:none;">'
                            + parsedData[key].Lab_Test_Detail_ID + '</td><td>'
                            + parsedData[key].Test_Name + '</td><td style="width: 550px;" class=' + 'arrow-togglable '
                            + parsedData[key].Result_Type_Fixed + '><textarea id="txtfixedTypeGroup'
                            + key + '" name="txtfixedTypeGroup"></textarea></td><td data-text="sdasd" class=' + 'arrow-togglable '
                            + parsedData[key].Result_Type_Value + '><div ' + editable + '>'
                            + typeVal + '</div></td><td>' + TestRange + '</td><td class='
                            + parsedData[key].Result_Type_List + '> <select id="ddlResultValue'
                            + key + '">' + optionsList + '</select></td><td> <input  onchange="readIMG(this)" id="fileUploadMultiple'
                            + parsedData[key].Lab_Test_Detail_ID + '" type="file" name="FileUpload" multiple="multiple" class="image"/><div id="container'
                            + parsedData[key].Lab_Test_Detail_ID + '" style="width:150px;"></div></td><td id="billdid" style="display:none;">'
                            + parsedData[key].Bill_Details_ID + '</td></tr>';
                        onchange = "readIMG(this)"

                        Lab_Test_Detail_ID = parsedData[key].Lab_Test_Detail_ID;


                        $('#tblgroupTestlist tbody').append(row);
                        if (parsedData[key].Result_Type_List == false) {
                            $('#ddlResultValue' + key + '').hide();
                        }
                        else {
                        }
                        // $('#ddlResultValue' + key + '').val(parsedData[key].Result_Value);
                        $('#ddlResultValue' + key + '').val(parsedData[key].Growth_Type);
                        if (parsedData[key].Growth_Type != '' && parsedData[key].Growth_Type != null) {
                            for (var i = 0; i <= parsedData[key].Growth_Type.length; i++) {

                                var GrowthType = parsedData[key].Growth_Type;
                                $('#ddlGrowth' + i + '').val(GrowthType);
                            }
                        }


                        //if (parsedData[key].Growth_Type != '' && parsedData[key].Growth_Type != null) {
                        //    for (var i = 0; i <= parsedData[key].Organism_Type.length; i++) {
                        //        
                        //        var OrganismType = parsedData[key].Organism_Type;
                        //        $('#ddlOrganism' + i + '').val(GrowthType);
                        //    }
                        //}

                        groupKeys = ('txtfixedTypeGroup' + key + '');
                        CKEDITOR.replace(groupKeys, {
                            height: 50
                        });
                        CKEDITOR.instances['txtfixedTypeGroup' + key + ''].setData(fixed);

                        if (parsedData[key].FixedValue == false || parsedData[key].FixedValue == null) {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(2)').hide();
                                $(this).find('td:eq(2)').hide();

                            });
                        }
                        else {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(2)').show();
                                $(this).find('td:eq(2)').show();

                            });

                        }
                        if (parsedData[key].Resultvalue == false || parsedData[key].Resultvalue == null) {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(3)').hide();
                                $(this).find('td:eq(3)').hide();
                                $(this).find('th:eq(4)').hide();
                                $(this).find('td:eq(4)').hide();
                            });
                        }
                        else {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(3)').show();
                                $(this).find('td:eq(3)').show();
                                $(this).find('th:eq(4)').show();
                                $(this).find('td:eq(4)').show();

                            });
                        }
                        if (parsedData[key].ReqImage == false || parsedData[key].ReqImage == null) {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(6)').hide();
                                $(this).find('td:eq(6)').hide();
                            });
                        }
                        else {
                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(6)').show();
                                $(this).find('td:eq(6)').show();
                            });

                        }
                        if (parsedData[key].ListValue == false || parsedData[key].ListValue == null) {

                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(5)').hide();
                                $(this).find('td:eq(5)').hide();
                            });
                        }
                        else {


                            $("#tblgroupTestlist tr").each(function () {
                                $(this).find('th:eq(5)').show();
                                $(this).find('td:eq(5)').show();
                            });

                        }
                        //if (parsedData[key].ListValue == false && parsedData[key].ReqImage == false && parsedData[key].Resultvalue == false && parsedData[key].FixedValue == false)
                        //{  $("#tblgroupTestlist tr").each(function () {
                        //    $(this).find('th:eq(4)').hide();
                        //    $(this).find('td:eq(4)').hide();
                        //});
                        //}
                        if (parsedData[key].Is_Result == true && parsedData[key].Is_Approve == false) {

                            $('#agRatio' + key).prop("readonly", true);
                            $("#saveTest").val("Update");
                            $("#btnApprove").show();
                            $("#btnReject").hide();

                        }

                        //else if (parsedData[key].Is_Approve == true) {

                        ////    counter++;
                        //    $('#agRatio' + key).prop("readonly", true);
                        //    $("#saveTest").hide();
                        //    $("#btnApprove").hide();
                        //    $("#btnReject").show();
                        //}
                        else if (parsedData[key].Is_Result == false && parsedData[key].Is_Approve == false) {

                            $('#txtvaluetype').prop("readonly", false);
                            $("#saveTest").show();
                            $("#saveTest").val("Save");
                            $("#btnApprove").hide();
                            $("#btnReject").hide();
                        }
                        else if (parsedData[key].Is_Result == true && parsedData[key].Is_Approve == true) {
                            $('#txtvaluetype').prop("readonly", true);
                            $("#saveTest").hide();
                            $("#btnApprove").hide();
                            $("#btnReject").show();
                        }
                        //else
                        //{
                        //    alert(parsedData[key].Is_Result);
                        //    alert(parsedData[key].Is_Approve);
                        //    $("#saveTest").hide();
                        //    $("#btnApprove").hide();
                        //    $("#btnReject").show();

                        //}
                        //if (is_Result == "False" && (is_Approved == "False" || is_Approved == null)) {

                        //    $('#txtvaluetype').prop("readonly", false);
                        //    $("#saveTest").show();
                        //    $("#saveTest").val("Save");
                        //    $("#btnApprove").hide();
                        //    $("#btnReject").hide();
                        //}
                        //else if (is_Result == "True" && (is_Approved == "False" || is_Approved == null)) {

                        //    //$('#txtvaluetype').prop("readonly", true);
                        //    $("#saveTest").val("Update");
                        //    $("#btnApprove").show();
                        //    $("#btnReject").hide();
                        //}

                        //else {

                        //    $('#txtvaluetype').prop("readonly", true);
                        //    $("#saveTest").hide();
                        //    $("#btnApprove").hide();
                        //    $("#btnReject").show();
                        //}
                        //if ( parsedData[key].Is_Approve == false) {
                        //    
                        //    //$('#agRatio' + key).prop("readonly", true);
                        //    $("#saveTest").val("Update");
                        //    $("#btnApprove").show();
                        //    $("#btnReject").hide();
                        //}
                        //else if (parsedData[key].Is_Approve == true) {
                        //    //    counter++;
                        //   // $('#agRatio' + key).prop("readonly", true);
                        //    $("#saveTest").hide();
                        //    $("#btnApprove").hide();
                        //    $("#btnReject").show();
                        //}
                    });
                    //  showImage(testDetailID, single);
                    //$.ajax({
                    //    type: "POST",
                    //    url: "LabTestResult.aspx/LoadimagesDetail",
                    //    data: JSON.stringify({
                    //        "TestDetailID": Lab_Test_Detail_ID,

                    //    }),
                    //    contentType: "application/json; charset=utf-8",
                    //    dataType: "json",
                    //    success: function (data) {
                    //        
                    //        var img_index = 0;
                    //        parsed_image_data = JSON.parse(data.d);
                    //        for (var i = 0; i < parsed_image_data.length; i++) {
                    //            $("#tblgroupTestlist tr:gt(0)").each(function () {
                    //                var test_detail_id = $(this).find('td:eq(0)').text();
                    //                //E:\Haseeb Development\GL - Mughal Eye\GL - Mughal Eye\GL\GL
                    //                var img = $('<img />').attr({
                    //                    'id': 'myImage' + img_index,
                    //                    'src': parsed_image_data[i].Image_path,
                    //                    'alt': ' logo',
                    //                    'title': ' logo',
                    //                    'width': 40

                    //                }).appendTo('#container' + parsed_image_data[i].Lab_Test_Detail_ID + '');

                    //                img_index++;
                    //                var srcs = [],
                    //                              temp;

                    //                $("img").filter(function () {
                    //                    
                    //                    temp = $(this).attr("src");
                    //                    if ($.inArray(temp, srcs) < 0) {
                    //                        srcs.push(temp);
                    //                        return false;
                    //                    }
                    //                    return true;
                    //                }).remove();
                    //            });

                    //        }



                    //    },
                    //    error: function () {


                    //    }

                    //});


                }



                $('#myModal').modal({
                    backdrop: 'static'
                });
            });
            //            }
            //, 4000);

        }  // EditData ends


        var fileListGlobal = '';
        function Edit(rowSave) {

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
                    "OrganismType": OrganismType
                    //"formDataToUpload": formDataToUpload


                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    if (data.d == 'Successfull') {

                        alert("Saved");
                    }
                    setTimeout(function () { $('#myModal').modal('hide'); }, 3000);
                    location.reload()
                }, error: function () { }


            });


        }
        function OnSuccess(data) {

            if (data.d != '') {

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
                if (localStorage.IsPatient == 1) {
                    if (localStorage.IsLabTest == 0) {

                        GetLabDetail();
                    }
                }
                else if (localStorage.IsPatient == 0) {
                    if (localStorage.IsLabTest == 1) {
                        loadPatientDataUsingSampleID();
                        var hdFile_ID = $("#hdnLab_Test_ID").val();
                        var tokenInputs = httpGet("json.aspx?Table=Sample&q=" + localStorage.labID);
                        //$('#ctl00_MainContent_txtLabNo').tokenInput("add", { id: JSON.parse(tokenInputs)[0].id, name: JSON.parse(tokenInputs)[0].name });
                    }

                }

                //GetLabDetailUsingLabID();

                //      GetLabDetail();
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
                if (data.d.Address == "null" || data.d.Address == null) data.d.Address = '';
                $('#<%= vLbl_Adress.ClientID %>').text(data.d.Address);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
                if ($('#ctl00_MainContent_txtBilling').val() == "") {
                    if (localStorage.IsLabTest == 1) {
                    }
                    else {

                        GetLabDetail();
                    }
                }
            }
        }
        function FillGrowthType() {
            var options = ''
            PageMethods.fillGrowthTypes(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlGrowth').html(options);
                GrowthTypeGlobal = options;
            });
            return options;
        }
        function FillGrowthInfo() {
            var options = ''
            PageMethods.fillGrowthInfos(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#growthInfor').html(options);
                GrowthTypeGlobal = options;
            });
            return options;
        }
        function FillOrganismType() {
            var options = ''
            PageMethods.FillOrganismType(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlOrganism').html(options);
                OrganismTypeGlobal = options;
            });
            return options;
        }
        function DeleteOrganism(reference) {

            $($(reference).parents('tr')[0]).remove();
        }

        function getAllLevels(TestID) {
            var newTestID = TestID;
            PageMethods.GetAll_UltraSoundLevel(function (resp) {
                var options = '<option value="0">Select Level</option>'
                $.each(JSON.parse(resp), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" testIds = "' + newTestID + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#chkUltraSound_level').html(options);
                // levelType = options;
            });
        }

    </script>

    <style type="text/css">
        #txt_sr {
            width: 86px !important;
        }

        [contenteditable=true]:empty:not(:focus):before {
            content: attr(data-text);
        }

        bgcolor {
            color: red;
        }

        .wgtmsr {
            width: 380px !important;
        }

        fieldset {
            border: 1px groove #ddd !important;
            padding: 0 1.4em 1.4em 1.4em !important;
            margin: 0 0 1.5em 0 !important;
            -webkit-box-shadow: 0px 0px 0px 0px #000;
            box-shadow: 0px 0px 0px 0px #000;
        }

        legend {
            font-size: 1.2em !important;
            font-weight: bold !important;
            text-align: left !important;
            width: auto;
            padding: 0 10px;
            border-bottom: none;
            margin-bottom: 0px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
            border: 1px solid #167F92;
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

           li.token-input-token {
                   height:30px !important;
                }

           ul.token-input-list {
                 height:36px !important;
                 width:187px !important;
            }
        


        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        div .cke_contents {
            /*height: 60px !important;
        width: 300px;*/
        }

        .cke_top {
            padding: 0px 0px 0px !important;
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

        #test_id {
            width: 60px !important;
            text-align: center;
            font-weight: bold;
        }

        .ErrorAlert {
            border: 1px solid red !important;
        }
    </style>
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

        <table style="padding: 20px; width: 785px; height: 200px; float: left;">

            <tr>
                <td style="width: 111px;">
                    <asp:Label ID="LblLab_Test_ID" runat="server" Text="Bill No :"></asp:Label>
                </td>
                <td style="width: 205px;">
                    <asp:TextBox ID="txtBilling" runat="server"></asp:TextBox>
                    <asp:HiddenField ID="hdBill_id" runat="server" ClientIDMode="Static" Value="(New)" />
                    <asp:TextBox ID="txtLab_Test_ID" runat="server" Style="display: none;"></asp:TextBox>
                    <asp:HiddenField ID="hdnLab_Test_ID" runat="server" ClientIDMode="Static" Value="(New)" />
                    <asp:HiddenField ID="hdnBill_No" runat="server" ClientIDMode="Static" Value="(New)" />
                </td>
                <td class="mg" style="padding-left: 20px; width: 51px;"></td>
                <td>
                    <asp:Label ID="lblPatien_ID" runat="server" Text="MR No:*"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                    <asp:HiddenField ID="hdnPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                </td>
                <td></td>
            </tr>
            <tr id="tr-1">
                <td>
                    <asp:Label ID="lblPatient_Name" runat="server" Text="Name :"></asp:Label>
                </td>
                <td style="width: 100px;">
                    <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                </td>
                <td></td>
                <td class="mg">
                    <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                </td>
                <td>
                    <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                </td>
                <td></td>
            </tr>
            <tr id="tr-2">
                <td>
                    <asp:Label ID="lblAdress" runat="server" Text="Adress :"></asp:Label>
                </td>
                <td style="width: 100px;">
                    <asp:Label ID="vLbl_Adress" runat="server"></asp:Label>
                </td>
                <td></td>
                <td class="mg">
                    <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                </td>
                <td>
                    <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                </td>
                <td></td>
            </tr>
            <tr id="tr-3">
                <td>
                    <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                </td>
                <td style="width: 100px;">
                    <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                </td>
                <td></td>
                <td class="mg">
                    <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date:"></asp:Label>
                </td>
                <td>
                    <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                </td>
                <td></td>
            </tr>
            <tr id="tr-4">
                <td>
                    <asp:Label ID="LblPatient_Category" runat="server" Text="Category :"></asp:Label>
                </td>
                <td style="width: 100px;">
                    <asp:Label ID="vPatient_Category" runat="server"></asp:Label>
                </td>
                <td></td>
                <td class="mg"></td>
                <td></td>
                <td></td>

            </tr>



            <tr>
                <td style="display: none">Report Columns</td>
                <td style="display: none">
                    <select id="ddlrptColumns" style="width: 210px!important;">
                        <option value="2">2-Fixed Or DropDown</option>
                        <option value="3">3-DropDown and Fixed</option>
                        <option value="4">4-Table Range and Fixed</option>
                        <option value="5">4-Value Range Table</option>
                        <option value="6">5-Cutt Off</option>
                        <option value="7">6-Result Organism</option>
                    </select></td>
            </tr>

            <tr>
                <td colspan="6">
                    <table class="table test-table" id="tblLabTest">
                        <thead>
                            <th><input type="checkbox" onclick="toggle(this);" /></th>
                            <th>Lab Test ID</th>
                            <th style="display: none">Test Detail ID</th>
                            <th>Test Name</th>
                            <th>Rej Remarks</th>
                            <th>Bill Date</th>
                            <th>Unit</th>
                            <th style="display: none;">Status</th>
                            <th>Action</th>
                            <th style="display: none;">Group_Category</th>
                            <th style="display: none;">List Of TestIDs</th>
                           <%-- <th>PatientID</th>--%>
                            <%--In case of group--%>
                        </thead>
                        <tbody id="tbltestid"></tbody>
                    </table>
                </td>
            </tr>
            <tr>
                <td></td>
                <td style="width: 100px;">
                    <br />
                    <asp:Button Text="Back" Width="93px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/LaboratoryTestView.aspx" />
                    &nbsp;
                             <input type="button" style="width: 93px" id="btnResultPrint" value="Print" onclick="ShowReport()" />
                    &nbsp;
                     
                </td>
                 <%--PostBackUrl="~/LabTestResult.aspx"--%> 
                <td> <asp:Button Text="New" Width="93px" runat="server" ID="Button1"  style="margin-top: 18px;" OnClick="Button1_Click"/></td>
                <td></td>
                <td></td>
                <td></td>
            </tr>
            <tr>
                <td colspan="6"></td>
            </tr>
            <tr>
                <td colspan="6">
                    <asp:Label ID="lblMessage" Text="" runat="server" />
                </td>
            </tr>
        </table>



    </div>

    <div for="unofficial_work" style="margin-left: 1106px; margin-top: -1px; width: 341px; position: absolute;">
        <%--<b style="float:left;">Search</b>--%>
        <select id="SearchFilter" style="width: 174px !important; float: left;">
            <option>All </option>
            <option>Pending  </option>
            <option>Approved </option>
            <option>Rejected </option>
        </select>
    </div>

    <%-- new code for pending table list --%>
    <tr>
        <td>
            <b style="margin-left: 10px;">Search From Bill No:</b><input id="txtMRNOSearch" type="text" style="margin-left: 12px; width: 120px !important;"></input></td>

    </tr>

    <div id="dvtblSymtomps" style="height: 298px; margin-left: 802px; width: 596px; overflow: scroll; position: absolute;">
        <%--   <div style="margin-left: 624px; margin-top: 73px; margin-bottom: -41px;"> <a href="#" id="testViewDetails">Enlarge</a></div>--%>

        <table class="responstable" style="overflow: scroll; width: 574px;" id="tblPendingPatientsLIst">
            <thead>
                <tr>
                    <th>Bill No</th>
                    <th>Bill Date</th>
                    <th>Name</th>
                    <th>Father Name</th>
                    <th>Dpt</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody></tbody>
        </table>
    </div>

    <%--end--%>

    <style>
        .modal-body input[type="text"] {
            height: 25px;
        }

        .test-table {
            width: 100%;
        }

            .test-table tr td {
                padding: 5px;
            }
    </style>
    <!-- Modal -->
  
    <div id="myModal" class="modal fade" role="dialog">
        <div class="modal-dialog">

            <!-- Modal content-->
            <div class="modal-content" style="width: 1504px; margin-left: -459px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title" id="titleee">Add Test Result</h4>
                </div>
                  <div id="dvSingleTestName"><p id="pTestName" style="margin-left: 29px;
    font-size: 20px;
    color: blue;
"></p>  </div>
                <div class="modal-body">
                    <table class="test-table responstable" id="tblsingleTest">
                        <tr>
                            <th>Fixed Type</th>
                            <th>Patient Result</th>
                            <th>Reference Ranges</th>
                            <th>List Type</th>
                            <th>Growth/Non Growth</th>
                            <th>Organism Detected </th>
                            <th>Image Upload</th>
                        </tr>
                        <tr>
                            <td>
                                <textarea id="txtfixedType" name="txtfixedType"></textarea>
                                <div style="margin-top: 25px;">
                                    <select id="chkUltraSound_level" class="wgtmsr"></select>
                            </td>
                </div>
                <td>
                    <input type="text" id="txtvaluetype" class="arrow-togglable" style="margin-left: 15px;" /></td>
                <td>
                    <input type="text" id="ranges" class="arrow-togglable" style="margin-left: 15px;" readonly /></td>
                <td>
                    <select id="ddllistType" class="arrow-togglable" style="margin-left: 15px;"></select></td>

                <td>
                    <select id="ddlGrowth" style="/*margin-left: 29px; */
    margin-top: 167px;">
                    </select><input type="button" id="btnGrowth" name="AddGrowth" value="Add" class="arrow-togglable" style="margin-left: 192px; margin-top: -54px;" />
                    <textarea rows="4" cols="50" id="txtAreaGrowth" style="width: 297px; margin-top: 35px;"> </textarea>

                    <select id="growthInfor" style="margin-top: 50px;"></select>
                    <input type="button" id="btnGrowthInfo" name="AddGrowthInfo"
                        value="Add" class="arrow-togglable" style="margin-left: 192px; margin-top: -54px;" />
                    <textarea rows="4" cols="50" id="txtAreaGrowthInfo" style="width: 297px; margin-top: 35px;"> </textarea>
                </td>
                <td>
                    <select id="ddlOrganism" class="limitedNumbChosen" style="/*margin-left: 29px; */
    margin-top: 167px;">
                    </select>
                    <input type="button" id="btnOrganism" name="AddOrganism" value="Add" class="arrow-togglable" style="margin-left: 192px; margin-top: -54px;" />
                    <%--                              <textarea rows="4" cols="50" id="TextareaOrganism" style="width: 297px;margin-top: 35px;"> 
</textarea>--%>
                    <table id="tblOrganism" class="responstable">
                        <thead>
                            <th contenteditable>Org Name</th>
                            <th contenteditable></th>
                            <th contenteditable></th>
                            <th contenteditable></th>
                            <th contenteditable>Action</th>

                        </thead>
                        <tbody></tbody>
                    </table>
                </td>
                <td>
                    <asp:FileUpload runat="server" ID="fileUploadMultiple" AllowMultiple="true" CssClass="image" onchange="readIMGsingle(this)" />
                    <div id="container" style="width: 150px;"></div>
                </td>
                <%--<input  onchange="readIMGsingle(this)" id="fileUploadMultiple" type="file" name="FileUpload" multiple="multiple" class="image"/> </td>--%>
                <td style="display: none;">
                    <input type="hidden" id="hdtestdetailid" />
                </td>
                </tr>
                    </table>
                    <table id="tblgroupTestlist" class="responstable">
                        <thead>
                            <th style="display: none"></th>
                            <th>Test Name</th>
                            <th>Fixed Type</th>
                            <th>Patient Result</th>
                            <th>Reference Ranges</th>
                            <th style="width: 193px;">List Type</th>
                            <th>Image Upload</th>
                            <%-- <th>Action</th>--%>
                        </thead>
                        <tbody></tbody>
                    </table>


            </div>
            <%--  --%>
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
                                    <div class="modal-footer">
                                        <%--<input type="button" value="Save Remarks" />--%>
                                        <%--<button class="btn btn-danger" data-dismiss-modal="modal2">Close</button>--%>
                                        <input type="button" id="btndismiss" class="btn btn-danger" data-dismiss-modal="modal2" value="Close" onclick="$('#myInnerModal1').modal('hide');" />
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
            <%--  --%>
            <div class="modal-footer">
                <input class="btn btn-success" data-toggle="modal" data-target="#myInnerModal1" style="float: left;" value="Remarks" />
                <input type="button" id="saveTest" name="saveTest" value="Save" />
                 <input type="button" id="btnApprove" name="btnApprove" value="Approve" style="margin-right: 185px;" />
                    <input type="button" id="btnReject" name="btnReject" value="Reject" style="margin-right: 185px;" />
                <asp:Button ID="buttonimageuploadNotes" runat="server" OnClick="buttonimageuploadNotes_Click" Text=" " Style="display: none;" />
                <asp:Button ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" Style="display: none" />
                <asp:HiddenField ID="session_obejct" runat="server" />
            </div>
        </div>

    </div>
    <%--      <div class="modal fade" id="myModalRemarks" role="dialog">
    <div class="modal-dialog" style="margin-left:34px;">
    
      <!-- Modal content-->
      <div class="modal-content" style="width:1502px;">
        <div class="modal-header">
          <button type="button" class="close" data-dismiss-modal="modal2">&times;</button>
          <h4 class="modal-title">Remarks</h4>
        </div>
        <div class="modal-body">
            <textarea name="editor1" id="editor1" rows="10" cols="80">
                Enter your remarks.!
            </textarea>
            <script>
                CKEDITOR.replace('editor1');
            </script>
        <div class="modal-footer" style="background-color: white;height: 20px;color: white;">
          <button type="button" class="" style="background-color:cadetblue;">Save</button>
            <button type="button" class="btn btn-danger" data-dismiss-modal="modal2">Close</button>
        </div>
      </div>
      
    </div>
  </div>
          </div>--%>
</asp:Content>
