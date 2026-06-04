<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LabTestResult.aspx.cs" Inherits="PMS.LabTestResult" ValidateRequest="false" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/LabReportPreview.css" rel="stylesheet" />
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This browser does not support HTML5 FileReader.',
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
        });


        function toggle(source) {
            debugger;
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

        var index = 0;
        function ShowReport() {
            debugger;
            var textInput = [];
            // debugger;td:eq(10) #Report_Colum
            var ChkLetterHead = $("#ChkIs_latterhead").prop('checked');
            var CheckUnApprove = 0;
            $("#tblLabTest tr").find('td:eq(15) #Report_Colum').map(function () {
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
                    Chk_IsApprove = $(this).find('td:eq(13) #isApprove').attr('value');

                    if (Chk_IsApprove == false || typeof Chk_IsApprove === 'undefined' || Chk_IsApprove == 'false' || Chk_IsApprove == "False") {
                        CheckUnApprove += 1;
                    }
                }
            });

            if (CheckUnApprove > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Approve The Test First',
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

                            Report_Column = $(this).find('td:eq(15) #Report_Colum').val();
                            //$(this).find('td:eq(11) #Report_Column').val();
                            Chk_IsApprove = $(this).find('td:eq(13) #isApprove').attr('value');
                            if (Report_Column == "null" || Report_Column == '') {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Please Verify Report Again this Test',
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
                            debugger;
                            if (index == Report_Column.trim()) {
                                debugger;
                                var transIds = $(this).find('td:eq(1)').text();
                                ListTransID += ', ' + transIds;
                                var billdetailid = $(this).find('input[name="Bill_Details_ID"]').val();
                                test_wise_ids = $(this).find('input[name=test_wise_id]').val();
                                ListBillDetailID += ', ' + billdetailid;
                                LabTestDetailsID = $(this).find('td:eq(2)').text();

                                var groupCategory = $(this).find('#GroupCategory').val();
                                if (groupCategory != "") {

                                    var testIds = $(this).find('td:eq(15) #ListOfTestIDs').val();

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
                        w = window.open('../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + index + '&ChkLetterHead=' + ChkLetterHead)

                        //var Patient_ID = $('#hdnPatient_ID').val();
                        //w = window.open('../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&Patient_ID=' + Patient_ID + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + index + '&ChkLetterHead=' + ChkLetterHead)
                    }

                }



            }

        }

        //function UltraSoundTestDetail() {

        //    PageMethods.AllUltraSoundTest(function (data) {
        //        var parsedData = JSON.parse(data);
        //        var rows = '';
        //        $.each(parsedData, function (key, value) {
        //            var retdate = moment(value.Bill_Date).format('DD-MMM-YYYY hh:mm A');
        //            rows += '<tr id="row' + key + '"><input type="hidden" name="Bill_ID" value="' + value.Bill_ID + '"/><input type="hidden" name="pat_id" value="' + value.pat_id + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><td><input type="hidden"  name="Bill_Date" value="' + retdate + '"/>' + retdate + '</td> <td> <input type="hidden"  name="Bill_No" value="' + value.Bill_No + '"/>' + value.Bill_No + ' </td> <td><input type="hidden"  name="Full_Name" value="' + value.Full_Name + '"/>' + value.Full_Name + '</td><td><input type="hidden" name="Item_Name" value="' + value.Item_Name + '"/>' + value.Item_Name + '</td><td><input type="hidden"  name="Priorities" value="' + value.Priorities + '"/>' + (value.Priorities || '') + '</td><td> <a href="#" onclick=fillTokenInput(' + value.Bill_No + ')>Select</a> </td> </tr>';
        //        });
        //        $('#tbl_radilogy tbody').html(rows);
        //    },
        //        function (exec) { alert(exec.getmessage()); })
        //}

        function httpGet(theUrl) {

            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        var AllowLab, AllowUltra, AllowCtScan, Allow_Xray, Allow_blood;

        function AllowLabRights() {
            $.ajax({
                type: "POST",
                url: "LabTestResult.aspx/checkLab_rights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (response) {
                    console.log(response);
                    debugger;
                    var data = typeof response.d === 'string' ? JSON.parse(response.d) : response.d;
                    AllowLab = data.allow_lab;
                    AllowUltra = data.allow_ultra;
                    AllowCtScan = data.allow_ctscan;
                    Allow_Xray = data.allow_xray;
                    Allow_blood = data.allow_b_bank;

                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error: ", status, error);
                }
            });


        }
        function fillTokenInput(Bill_No) {
            localStorage.billid = 1
            localStorage.patientid = 0
            localStorage.isSaved = 0

            $('#ctl00_MainContent_txtBilling').tokenInput('clear');

            var tokenData = httpGet("../../json.aspx?Table=Billing&q=" + Bill_No);


            $('#ctl00_MainContent_txtBilling').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

            //  $('#hdnPatient_ID').val(JSON.parse(tokenData)[0].id);
            $("#hdBill_id").val(JSON.parse(tokenData)[0].id);
            $("#hdnBill_No").val(JSON.parse(tokenData)[0].name);
            //  loadPatientData();
            loadPatientDataUsingBillId();

        }


        $(document).ready(function () {

            $("#ddlrptColumns").val(4);
            AllowLabRights();
            //UltraSoundTestDetail();
            //PageMethods.CheckRadiologylistRights(function (response) {
            //    var hasRights = JSON.parse(response);

            //    if (hasRights === true) {
            //        $('#Radiologylist').show();
            //        UltraSoundTestDetail();
            //    } else {
            //        $('#Radiologylist').hide();
            //    }
            //}, function (error) {
            //    alert('Error checking rights: ' + error.get_message());
            //});
            var PatientID = '<%=Request.QueryString["PatientID"]%>';
            if (PatientID != "") {
                fillTokenInput(PatientID);
            }
            bindControls();
            $('#ddlTestDepartment').change(function (e) {
                debugger;
                //var CheckAll = $('#chkTodayAll').checked;

                var Dept = $("#ddlTestDepartment option:selected").text();

                var tbl = document.getElementById('tblLabTest');
                if (Dept != "Select Department") {
                    if (Dept.trim() != '') {

                        for (var i = 1; i < tbl.rows.length; i++) {
                            if (tbl.rows[i].cells[7].innerText != Dept) {
                                var row = tbl.rows[i];
                                row.style.display = 'none';
                            }
                            else {
                                var row = tbl.rows[i];
                                row.style.display = '';
                            }
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
            // GetPendingList();   //  21-01-2021
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
            $(function () {
                setTimeout(function () {
                    $('#<%= txtSearchBillNo.ClientID %>').tokenInput("../../json.aspx?Table=BillingBarcode", {
                        tokenLimit: 1,
                        onAdd: function (item) {
                            try {
                                $("#hdBill_id").val(item.id);
                                $("#hdnBill_No").val(item.name);
                                loadpatientdetailbybarcode();
                            } catch (err) {
                                alert(err.message);
                            }
                        }
                    });

                    // Set focus after a short delay (adjust the delay if needed)
                    $('#<%= txtSearchBillNo.ClientID %>').focus();
                }, 800); // 200 milliseconds delay
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
                debugger;
                test_list = [];
                var tbl = $("#tblgroupTestlist tbody tr");

                $.each(tbl, function (key, val) {
                    var testDetailId = $(val).find('td:eq(0)').text().trim();
                    if (testDetailId != null && testDetailId !== "" && testDetailId > 0) {
                        test_list.push({ 'TestDID': testDetailId });
                    }
                });
                //$.each(tbl, function (key, val) {

                //    var name = $(val).find('input[name="testDepartment"]').attr('name');
                //    if (name == "testDepartment") {
                //    }
                //    else {
                //        var Ids = $(val).find('td:eq(0)').text();
                //        //$(val).find('td[id=testDetailID]').text();
                //        test_list.push({ 'TestDID': Ids });
                //    }
                //});
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
                        ApproveedLab();
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
                debugger;
                localStorage.isSaved = 1;
                test_list = [];
                var tbl = $("#tblgroupTestlist tbody tr");
                $.each(tbl, function (key, val) {
                    debugger;
                    var name = $(val).find('input[name="testDepartment"]').attr('name');
                    if (name == "testDepartment") {
                    }
                    else {
                        var Ids = $(val).find('td:eq(0)').text();
                        //$(val).find('td[id=testDetailID]').text();
                        if (Ids != null && Ids > 0 && Ids != "") {
                            test_list.push({ 'TestDID': Ids });
                        }
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
                        debugger;
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
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Saved',
                                    showConfirmButton: false,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });

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
                        ApproveedLab();
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
                            ApproveedLab();
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


            FillGrowthType();
            FillOrganismType();
            FillGrowthInfo();
            GetTestDepartment();
        });

        function ApproveedLab() {
            debugger;
            var BillId = '<% =Request.QueryString["Bill_ID"] %>';
            PageMethods.approve_Bill(BillId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: message[0].Message,
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    //alert(message[0].Message);
                    //location.reload();
                }
            });
        }
        function GetTestDepartment() {
            var options = '<option value="">Select Department</option>';
            PageMethods.FillTestDepartment(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlTestDepartment').html(options);
            });
            return options;
        }
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This browser does not support FileReader.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Pls select only images',
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This browser does not support FileReader.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Pls select only images',
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



        function GetSelectedDetail(patient_ID) {
            if (patient_ID != "") {
                $('#txtMR_No').tokenInput('clear');
                var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + patient_ID);

                $('#txtMR_No').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
                $("#hdPatientID").val(JSON.parse(tokendata)[0].id);


                GetPatientDetail();
            }
            else {

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
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Only numeric values allowed',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                e.preventDefault();
            }
        }
        function loadtokenInputs(data) {
            $("#ctl00_MainContent_txtPatient_ID").tokenInput("../../json.aspx?Table=LabResultPatient",
                {
                    prePopulate: data,
                    tokenLimit: 1,
                    onAdd: function (item) {
                        $("#hdnPatient_ID").val(item.id);
                    }
                });
        }
        debugger;
        function bindControls() {
            debugger;
            var storageBillNo = localStorage.Bill_No;
            if (storageBillNo != "(New)") {
                $("#ctl00_MainContent_txtBilling").val(storageBillNo);

                loadPatientDataUsingBillId();


            }

            var hdFile_ID = $("#hdnPatient_ID").val();
            debugger;
            if (hdFile_ID != "(New)") {

                var Patient_ID = $("#hdnPatient_ID").val();
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + Patient_ID);
                loadtokenInputs(JSON.parse(tokendata));
            }
            else {

                loadtokenInputsDefault();
            }

            var hdFile_ID = $("#hdnLab_Test_ID").val();
            if (hdFile_ID != "(New)") {
                var Lab_Test_ID = $("#hdnLab_Test_ID").val();
                var tokendata = httpGet("../../json.aspx?Table=Billing&Record=Edit&q=" + Lab_Test_ID);
                loadPatientDataUsingLabID();
            }
            else {

                $('#ctl00_MainContent_txtBilling').tokenInput("../../json.aspx?Table=Billing",
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

            $('#<%= txtSampleNo.ClientID %>').tokenInput("../../json.aspx?Table=SampleNo", {
                tokenLimit: 1,
                onAdd: function (item) {
                    try {
                        $('#ctl00_MainContent_txtPatient_ID').tokenInput('clear');
                        $('#ctl00_MainContent_txtBilling').tokenInput('clear');

                        $("#hdnPatient_ID").val(item.patient_id);

                        if (item.bill_id && item.bill_id !== "") {
                            $("#hdBill_id").val(item.bill_id);
                            $("#hdnBill_No").val(item.name);
                            loadPatientDataUsingBillId();
                        } else {
                            alert("No billing record found for this sample.");
                        }
                    } catch (err) {
                        alert("Error: " + err.message);
                    }
                }
            });
        }


        function loadtokenInputsDefault() {
            debugger;
            $('#ctl00_MainContent_txtPatient_ID').tokenInput("../../json.aspx?Table=LabResultPatient",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger;
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
        debugger;
        function loadPatientData() {
            debugger;
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
                    // Skip if not both result exists AND approved
                    if (!(value.Is_Result === true && value.Is_Approve === true)) {
                        return; // skip this item
                    }

                    // Normalize nulls
                    value.MainDepartment = value.MainDepartment || "";
                    value.TestDepartment = value.TestDepartment || "";
                    value.Unit_Name = value.Unit_Name || "";
                    value.Rejected_Reason = value.Rejected_Reason || "";

                    var test_wise_id = value.patient_ID;
                    var main_dep = value.Test_Main_Department || "";

                    // Build row — ONLY Preview, NO "View Result"
                    rows += '<tr>' +
                        '<td><input type="checkbox" name="chkReport" /></td>' +
                        '<td><input type="hidden" name="labtestDID" value="' + value.Test_ID + '" />' + value.Lab_Test_ID + '</td>' +
                        '<td style="display:none">' + value.Lab_Test_Detail_ID + '</td>' +
                        '<td><input type="hidden" value="' + (value.Parent_Transaction_Type || '') + '" />' + (value.Test_Name || '') + '</td>' +
                        '<td><input type="hidden" value="' + (value.Parent_Transaction_Type_ID || '') + '" />' + value.Rejected_Reason + '</td>' +
                        '<td>' + (value.Service_Date || '') + '</td>' +
                        '<td>' + value.Unit_Name + '</td>' +
                        '<td>' + value.TestDepartment + '</td>' +
                        '<td>' + (value.Test_Performed_By || '') + '</td>' +
                        '<td>' + (value.Result_Time || '') + '</td>' +
                        '<td>' + (value.Approved_By || '') + '</td>' +
                        '<td>' + (value.Approved_Time || '') + '</td>' +
                        '<td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td>' +
                        '<td>' +
                        '<input type="hidden" id="valuetype" value="' + (value.ValueType || '') + '">' +
                        // 🔴 NO "View Result" — only Preview
                        '<a href="javascript:void(0)" onclick="PreviewReport(this)">' +
                        '<span id="isApprove" value="' + value.Is_Approve + '">Preview</span>' +
                        '</a>' +
                        '</td>' +
                        '<td class="tdemergency"><input type="hidden" id="emergency" value="' + value.Test_ID + '"/>' + (value.Emergancy || '') + '</td>' +
                        '<td style="display:none;">' +
                        '<input type="hidden" name="Group_Category" value="' + (value.Group_Category || '') + '" />' +
                        '<input type="hidden" name="List_Of_Test_IDs" value="' + (value.ListOfTestIDs || '') + '" />' +
                        '<input type="hidden" name="Bill_Details_ID" value="' + (value.Bill_Details_ID || '') + '" />' +
                        '<input type="hidden" name="Report_Colum" value="' + (value.Report_Colum || '') + '" />' +
                        '<input type="hidden" name="test_wise_id" value="' + test_wise_id + '" />' +
                        '</td>' +
                        '</tr>';
                });

                //$('.table tbody').html(rows);
                $('#tbltestid').html(rows);


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
        //function PreviewReport($this) {
        //    debugger;
        //    var tbl = $($($this).parents('tr')[0]);
        //    // var Patient_ID = $('#hdnPatient_ID').val();
        //    var hdn_Patient_ID = tbl.find("td").find("input[id=Patient_Id]").val();
        //    var ChkLetterHead = true;
        //    var ListOfTestIDs = '';
        //    var ListTransID = '';
        //    var Report_Column = '';
        //    var LabTestDetailsID = '';

        //    Report_Column = tbl.find('td').find('input[name=Report_Colum]').val();
        //    ListOfTestIDs = tbl.find('td').find('input[name=List_Of_Test_IDs]').val();
        //    test_wise_ids = tbl.find('td').find('input[name=test_wise_id]').val();
        //    //ListTransID = tbl.find('td:eq(0)').text();
        //    ListTransID = tbl.find('td:eq(1)').text();
        //    //LabTestDetailsID = tbl.find('td:eq(2)').text();
        //    LabTestDetailsID = tbl.find('td:eq(2)').text();
        //    var billdetailid = tbl.find('td:eq(14) #Bill_Details_ID').val()
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
        //    window.open('../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&test_wise_ids=' + test_wise_ids + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead);

        //    /*  window.open('../../ReportViewer.aspx?ReportName=TestResultQ&ReportTitle=Department Of Pathalogy&Test_IDs=' + ListOfTestIDs + '&Patient_ID=' + hdn_Patient_ID + '&TransID=' + ListTransID + '&labTDetailsID=' + LabTestDetailsID + '&BillDetailID=' + ListBillDetailID + '&ReportColumn=' + Report_Column + '&ChkLetterHead=' + ChkLetterHead);*/

        //}

        function PreviewReport($this) {
            debugger;
            var $row = $($this).closest('tr');

            var ChkLetterHead = true;

            var ListOfTestIDs = $row.find('input[name="List_Of_Test_IDs"]').val() || '';
            var test_wise_ids = $row.find('input[name="test_wise_id"]').val() || '';
            var Report_Column = $row.find('input[name="Report_Colum"]').val() || '';
            var LabTestDetailsID = $row.find('td:eq(2)').text();
            var ListTransID = $row.find('td').eq(1).contents().filter(function () {
                return this.nodeType === 3;
            }).text().trim();

            var billdetailid = $row.find('input[name="Bill_Details_ID"]').val() || '';

            if (!ListOfTestIDs || ListOfTestIDs === "null") {
                var labTestDID = $row.find('input[name="labtestDID"]').val();
                ListOfTestIDs = labTestDID || '';
            }

            var ListBillDetailID = (billdetailid || '').replace(', ', '');

            window.open(
                '../../ReportViewer.aspx?ReportName=TestResultQ' +
                '&ReportTitle=Department Of Pathalogy' +
                '&Test_IDs=' + encodeURIComponent(ListOfTestIDs) +
                '&test_wise_ids=' + encodeURIComponent(test_wise_ids) +
                '&TransID=' + encodeURIComponent(ListTransID) +
                '&labTDetailsID=' + encodeURIComponent(LabTestDetailsID) +
                '&BillDetailID=' + encodeURIComponent(ListBillDetailID) +
                '&ReportColumn=' + encodeURIComponent(Report_Column) +
                '&ChkLetterHead=' + ChkLetterHead
            );
        }


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
                    // 🔴 CRITICAL: Only process if result EXISTs AND is APPROVED
                    if (!(value.Is_Result === true && value.Is_Approve === true)) {
                        return; // skip all other rows
                    }

                    // Normalize null/undefined fields
                    value.MainDepartment = value.MainDepartment || "";
                    value.TestDepartment = value.TestDepartment || "";
                    value.Unit_Name = value.Unit_Name || "";
                    value.Rejected_Reason = value.Rejected_Reason || "";
                    value.Parent_Transaction_Type = value.Parent_Transaction_Type || "";
                    value.Parent_Transaction_Type_ID = value.Parent_Transaction_Type_ID || "";
                    value.Service_Date = value.Service_Date || "";
                    value.Test_Performed_By = value.Test_Performed_By || "";
                    value.Result_Time = value.Result_Time || "";
                    value.Approved_By = value.Approved_By || "";
                    value.Approved_Time = value.Approved_Time || "";
                    value.Group_Category = value.Group_Category || "";
                    value.ListOfTestIDs = value.ListOfTestIDs || "";
                    value.Bill_Details_ID = value.Bill_Details_ID || "";
                    value.Report_Colum = value.Report_Colum || "";
                    value.Emergancy = value.Emergancy || "";
                    value.ValueType = value.ValueType || "";

                    var test_wise_id = value.patient_ID || "";
                    var labTestID = value.Lab_Test_ID || "";
                    var testID = value.Test_ID || "";
                    var labTestDetailID = value.Lab_Test_Detail_ID || "";

                    // Build row — ONLY "Preview", NO "View Result"
                    rows += '<tr>' +
                        '<td><input type="checkbox" name="chkReport" /></td>' +
                        '<td><input type="hidden" name="labtestDID" value="' + testID + '" />' + labTestID + '</td>' +
                        '<td style="display:none">' + labTestDetailID + '</td>' +
                        (value.Group_Category ?
                            '<td style="color:red"><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + (value.Test_Name || '') + '</td>' :
                            '<td><input type="hidden" value="' + value.Parent_Transaction_Type + '" />' + (value.Test_Name || '') + '</td>'
                        ) +
                        '<td><input type="hidden" value="' + value.Parent_Transaction_Type_ID + '" />' + value.Rejected_Reason + '</td>' +
                        '<td>' + value.Service_Date + '</td>' +
                        '<td>' + value.Unit_Name + '</td>' +
                        '<td>' + value.TestDepartment + '</td>' +
                        '<td>' + value.Test_Performed_By + '</td>' +
                        '<td>' + value.Result_Time + '</td>' +
                        '<td>' + value.Approved_By + '</td>' +
                        '<td>' + value.Approved_Time + '</td>' +
                        '<td style="display:none;">' + (value.Status ? 'Paid' : 'Unpaid') + '</td>' +
                        '<td>' +
                        '<input type="hidden" id="valuetype" value="' + value.ValueType + '">' +
                        // ✅ ONLY "Preview" — NO "View Result" link
                        '<a href="javascript:void(0)" onclick="PreviewReport(this)">' +
                        '<span id="isApprove" value="' + value.Is_Approve + '">Preview</span>' +
                        '</a>' +
                        '</td>' +
                        '<td class="tdemergency"><input type="hidden" id="emergency" value="' + testID + '"/>' + value.Emergancy + '</td>' +
                        '<td style="display:none;">' +
                        '<input type="hidden" name="Group_Category" value="' + value.Group_Category + '" />' +
                        '<input type="hidden" name="List_Of_Test_IDs" value="' + value.ListOfTestIDs + '" />' +
                        '<input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '" />' +
                        '<input type="hidden" name="Report_Colum" value="' + value.Report_Colum + '" />' +
                        '<input type="hidden" name="test_wise_id" value="' + test_wise_id + '" />' +
                        '</td>' +
                        '</tr>';
                });

                $('.table tbody').html(rows);

                $(".tdemergency").hide();

            });
        }

        // Pending
        function GetLabDetailUsingLabID() {
            debugger;
            var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val();
            PageMethods.GetLabDetailUsingLabID(Lab_ID, function (res) {
                var Test = JSON.parse(res);
                var rows = '';
                $.each(Test, function (key, value) {
                    // 🔴 CRITICAL: Only show if result EXISTS AND is APPROVED
                    if (!(value.Is_Result === true && value.Is_Approve === true)) {
                        return; // skip
                    }

                    // Normalize fields
                    value.MainDepartment = value.MainDepartment || "";
                    value.TestDepartment = value.TestDepartment || "";
                    value.Unit_Name = value.Unit_Name || "";
                    value.Parent_Transaction_Type = value.Parent_Transaction_Type || "";
                    value.Parent_Transaction_Type_ID = value.Parent_Transaction_Type_ID || "";
                    value.Lab_Test_Detail_ID = value.Lab_Test_Detail_ID || "";
                    value.GroupCategory_ID = value.GroupCategory_ID || "";
                    value.ValueType = value.ValueType || "";
                    value.Test_Name = value.Test_Name || "";

                    var Lab_ID = $("#<%= hdnLab_Test_ID.ClientID %>").val() || "";

    // Set Lab ID once (outside loop is better, but kept inline for safety)
                   $("#<%= txtLab_Test_ID.ClientID %>").val(value.LabID || "");

                   // Decide: Group vs Single test
                   if (!value.Lab_Test_Detail_ID) {
                       // Group Test
                       rows += '<tr>' +
                           '<td><input type="checkbox" name="chkReport" /></td>' +
                           '<td><input type="hidden" name="labtestDID" value="' + (value.Test_ID || '') + '" />' + Lab_ID + '</td>' +
                           '<td style="display:none">' + value.Lab_Test_Detail_ID + '</td>' +
                           '<td style="color:red">' +
                           '<input type="hidden" value="' + value.Parent_Transaction_Type + '" />' +
                           value.Test_Name +
                           '</td>' +
                           '<td><input type="hidden" value="' + value.Parent_Transaction_Type_ID + '" />' + value.MainDepartment + '</td>' +
                           '<td>' + value.TestDepartment + '</td>' +
                           '<td>' + value.Unit_Name + '</td>' +
                           '<td>' + (value.Status ? 'Paid' : 'Unpaid') + '</td>' +
                           '<td>' +
                           '<input type="hidden" id="valuetype" value="' + value.ValueType + '">' +
                           // ✅ ONLY "Preview" — NO EditData/View Result
                           '<a href="javascript:void(0)" onclick="PreviewReport(this)">' +
                           '<span>Preview</span>' +
                           '</a>' +
                           '<input type="hidden" name="CatID" value="' + value.GroupCategory_ID + '">' +
                           '</td>' +
                           '</tr>';
                   } else {
                       // Single Test
                       rows += '<tr>' +
                           '<td><input type="checkbox" name="chkReport" /></td>' +
                           '<td><input type="hidden" name="labtestDID" value="' + (value.Test_ID || '') + '" />' + Lab_ID + '</td>' +
                           '<td style="display:none">' + value.Lab_Test_Detail_ID + '</td>' +
                           '<td>' +
                           '<input type="hidden" value="' + value.Parent_Transaction_Type + '" />' +
                           value.Test_Name +
                           '</td>' +
                           '<td><input type="hidden" value="' + value.Parent_Transaction_Type_ID + '" />' + value.MainDepartment + '</td>' +
                           '<td>' + value.TestDepartment + '</td>' +
                           '<td>' + value.Unit_Name + '</td>' +
                           '<td>' + (value.Status ? 'Paid' : 'Unpaid') + '</td>' +
                           '<td>' +
                           '<input type="hidden" id="valuetype" value="' + value.ValueType + '">' +
                           // ✅ ONLY "Preview"
                           '<a href="javascript:void(0)" onclick="PreviewReport(this)">' +
                           '<span>Preview</span>' +
                           '</a>' +
                           '</td>' +
                           '</tr>';
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
        debugger;
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
        debugger;
        function OnSuccessBill(data) {
            debugger;
            if (data.d != '') {

                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();



                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Department.ClientID %>').text(data.d.Department);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
                $('#<%= vLbl_Location.ClientID %>').text(data.d.Location);

                //GetLabDetailUsingLabID();
                GetLabDetailAgainstBill();
            }
        }
        var checkCatagory;
       
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

            $(function () {
                setTimeout(function () {
                    $('#<%= txtSearchBillNo.ClientID %>').focus();
                }, 100); // 200 milliseconds delay
            });


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
        function loadpatientdetailbybarcode() {
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
        function LabTestMultipleID(testID) {

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
            //setTimeout(function () { 

            $('#myModal').modal('hide');
            PageMethods.LoadTestCatogry(LabID, CatID, billDetailID, function (res) {

                debugger;
                var parsedData = JSON.parse(res);
                console.log(parsedData)
                var row = '';
                if (Group_Categroy == "") //Single
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
                    //single
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
                       
                            var MainDept = data[2];
                          
                            if (CheckLevel == "True") {

                                $("#chkUltraSound_level").show();
                                getAllLevels(TestID);
                            }
                            console.log("Data "+ data);
                            $('#txtfixedType').val(fixedValue);
                            $('#txtMaster_Remarks').val(Master_Remarks);
                            $('#txtAreaGrowth').text(growth);
                          
                            CKEDITOR.instances.txtfixedType.setData(fixedValue);
                            CKEDITOR.instances.txtMaster_Remarks.setData(Master_Remarks);
  
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
                                $("#tblsingleTest th:eq(5").show();
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
                          
                            setTimeout(function () {

                                $('#chkUltraSound_level').val(UltraLevels)
                            }
                                , 1000);

                          
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

                        var Org = JSON.parse(res);
                        if (Org.length > 0) {
                            var case1 = Org[0].Organism_Name_Header;
                            var case2 = Org[0].Organism_Name_Case2_Header;
                            var case3 = Org[0].Organism_Name_Case3_Header;
                        }


                        var rows = '';
                        $('#tblOrganism td').remove();
                        $.each(Org, function (key, value) {

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
                            + parsedData[key].Test_Name + '</td><td style="width: 550px;" class="arrow-togglable '
                            + parsedData[key].Result_Type_Fixed + '"><textarea id="txtfixedTypeGroup'
                            + key + '" name="txtfixedTypeGroup"></textarea></td><td data-text="sdasd" class="arrow-togglable '
                            + parsedData[key].Result_Type_Value + '"><div '
                            + editable + ' class="editable-div" style=" height: 25px; padding: 3px; border: 1px solid gray;">' + typeVal
                            + '</div> </td><td>'
                            + TestRange + '</td><td class="'
                            + parsedData[key].Result_Type_List + '"> <select id="ddlResultValue'
                            + key + '">' + optionsList + '</select></td><td> <input onchange="readIMG(this)" id="fileUploadMultiple'
                            + parsedData[key].Lab_Test_Detail_ID + '" type="file" name="FileUpload" multiple="multiple" class="image"/><div id="container'
                            + parsedData[key].Lab_Test_Detail_ID + '" style="width:150px;"></div></td><td id="billdid" style="display:none;">'
                            + parsedData[key].Bill_Details_ID + '</td></tr>';


                        Lab_Test_Detail_ID = parsedData[key].Lab_Test_Detail_ID;


                        $('#tblgroupTestlist tbody').append(row);
                        if (parsedData[key].Result_Type_List == false) {
                            $('#ddlResultValue' + key + '').hide();
                        }
                        else {
                        }
                       
                        $('#ddlResultValue' + key + '').val(parsedData[key].Growth_Type);
                        if (parsedData[key].Growth_Type != '' && parsedData[key].Growth_Type != null) {
                            for (var i = 0; i <= parsedData[key].Growth_Type.length; i++) {

                                var GrowthType = parsedData[key].Growth_Type;
                                $('#ddlGrowth' + i + '').val(GrowthType);
                            }
                        }
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
                     
                        if (parsedData[key].Is_Result == true && parsedData[key].Is_Approve == false) {

                            $('#agRatio' + key).prop("readonly", true);
                            $("#saveTest").val("Update");
                            $("#btnApprove").show();
                            $("#btnReject").hide();

                        }

                   
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
                     
                    });
                


                }



                $('#myModal').modal({
                    backdrop: 'static'
                });
            });
           
        }


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
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Saved',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                    setTimeout(function () { $('#myModal').modal('hide'); }, 3000);
                    location.reload()
                }, error: function () { }


            });


        }
        function OnSuccess(data) {
            debugger;
            if (data.d != '') {
                debugger;
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                var tokendata = httpGet("../../json.aspx?Table=Patients&Record=Edit&q=" + data.d.Patient_No);
                $('#ctl00_MainContent_txtPatient_ID').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });


                $('#<%= vlblPatients_Name.ClientID %>').text(data.d.Name);
                $('#<%= vLbl_Age.ClientID %>').text(data.d.Age);
                $('#<%= vLbl_Gender.ClientID %>').text(data.d.Gender);
                $('#<%= vLbl_RegDate.ClientID %>').text(dateR);
                $('#<%= vLbl_Department.ClientID %>').text(data.d.Department);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
                $('#<%= vLbl_Location.ClientID %>').text(data.d.Location);
                if ($("#ctl00_MainContent_txtBilling").val() != "") { }
                else {
                    GetLabDetail();
                }                
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
                $('#<%= vLbl_Department.ClientID %>').text(data.d.Department);
                $('#<%= vLbl_Contact.ClientID %>').text(data.d.Mobile);
                $('#<%= vPatient_Category.ClientID %>').text(data.d.Patient_Category);
                $('#<%= vLbl_Location.ClientID %>').text(data.d.Location);

                if (localStorage.billid == 0) {
                    GetLabDetail();
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
                                    <img src="~../../../../wwwroot/Pakred/images/dashboard_Icons/Lab2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <b>Search Bill No</b>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtSearchBillNo" runat="server"></asp:TextBox>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                       <asp:Label ID="LblLab_Test_ID" runat="server" Text="Bill No :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <asp:TextBox ID="txtBilling" runat="server"></asp:TextBox>
                                        <asp:HiddenField ID="hdBill_id" runat="server" ClientIDMode="Static" Value="(New)" />
                                        <asp:TextBox ID="txtLab_Test_ID" runat="server" Style="display: none;"></asp:TextBox>
                                        <asp:HiddenField ID="hdnLab_Test_ID" runat="server" ClientIDMode="Static" Value="(New)" />
                                        <asp:HiddenField ID="hdnBill_No" runat="server" ClientIDMode="Static" Value="(New)" />
                                    </div>
                                </div>                               
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 ">
                                       <asp:Label ID="lblPatient_Name" runat="server" Text="Name :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                         <asp:Label ID="vlblPatients_Name" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <asp:Label ID="lblAge_Years" runat="server" Text="Age Years :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 detail">
                                         <asp:Label ID="vLbl_Age" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <asp:Label ID="lblGender" runat="server" Text="Gender :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 detail">
                                       <asp:Label ID="vLbl_Gender" runat="server"></asp:Label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <asp:Label ID="lblLocation" runat="server" Text="Ward/Bed :"></asp:Label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 detail">
                                       <asp:Label ID="vLbl_Location" runat="server"></asp:Label>
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
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                <asp:Label ID="lblPatien_ID" runat="server" Text="MR No :"></asp:Label>
                                <asp:Label runat="server" Style="font-size: 20px; color: red;">*</asp:Label>
                            </div>
                            <div class="col-lg-4 col-md-7 col-sm-6">
                                <asp:TextBox ID="txtPatient_ID" runat="server"></asp:TextBox>
                                <asp:HiddenField ID="hdnPatient_ID" runat="server" Value="(New)" ClientIDMode="Static" />
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6">
                                <asp:Label ID="lblSampleNo" runat="server" Text="Sample No :"></asp:Label>
                            </div>
                            <div class="col-lg-4 col-md-7 col-sm-6">
                                <asp:TextBox ID="txtSampleNo" runat="server"></asp:TextBox>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="lblContactNo" runat="server" Text="Contact No :"></asp:Label>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6 top">
                              <asp:Label ID="vLbl_Contact" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="LblReg_Date" runat="server" Text="Reg. Date :"></asp:Label>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6 top">
                                 <asp:Label ID="vLbl_RegDate" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                               <asp:Label ID="LblPatient_Category" runat="server" Text="Category :"></asp:Label>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6 top">
                               <asp:Label ID="vPatient_Category" runat="server"></asp:Label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <asp:Label ID="lblAdress" runat="server" Text="Department :"></asp:Label>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6 top">
                                 <asp:Label ID="vLbl_Department" runat="server"></asp:Label>
                            </div>
                        </div>
                    </div>
                    </div>
                </div>
            </div>
        <div class="row">
           <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Test Department</label>
  <select id="ddlTestDepartment">
     <option></option>
 </select>
           </div>
        </div>
        <div class="row">
            <div class="table-responsive-lg table-responsive-md">
                <table style="padding: 20px; height: 200px; float: left;">                   
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
                <table class="table test-table" id="tblLabTest" >
                    <thead>
                        <tr>
                        <th><input type="checkbox" onclick="toggle(this);" /></th>
                        <th>Lab Test ID</th>
                        <th style="display: none">Test Detail ID</th>
                        <th>Test Name</th>
                        <th>Rej Remarks</th>
                        <th>Bill Date</th>
                        <th>Unit</th>
                        <th>Group Department</th>
                        <th>Reported By</th>
                        <th>Reported Date</th>
                        <th>Approved By</th>
                        <th>Approved Time</th>
                        <th style="display: none;">Status</th>
                        <th>Action</th>
                        <th style="display: none;">Group_Category</th>
                        <th style="display: none;">List Of TestIDs</th>    
                            </tr>
                    </thead>
                    <tbody id="tbltestid"></tbody>
                </table>
            </td>
        </tr>
        <tr>
            <%--<td colspan="6"></td>--%>
        </tr>
        <tr>
            <td colspan="6">
                <asp:Label ID="lblMessage" Text="" runat="server" />
            </td>
        </tr>
                    <tr style="display: none;">
                        <td>
                            <b style="margin-left: 10px; display: none;">Search From Bill No:</b>
                            <input id="txtMRNOSearch" type="text" style="margin-left: 12px; width: 120px !important; display: none;" />
                        </td>
                    </tr>
        </table>
                
    </div>        
    
</div>
                    <div class="row" >
    <div class="col-lg-6 col-md-3 sm-6" style="display:none;" id="Radiologylist">
        <h1>Radiology Patients List </h1>
        <div class="row" style="overflow: scroll; height: 500px;">
        <table class="table test-table" id="tbl_radilogy" style="overflow: scroll; height: 500px;">
            <thead>
                <tr>
                    <th>Bill Date</th>
                    <th>Bill No</th>
                    <th>Name</th>
                    <th>Test Name</th>
                    <th>Priority</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tbl_tbodyradiology">
            </tbody>
        </table>
            </div>
    </div>
</div>
</div>

    <div for="unofficial_work" style="margin-left: 1106px; margin-top: -1px; width: 341px; position: absolute; display: none;">
        <select id="SearchFilter" style="width: 174px !important; float: left; display: none;">
            <option>All </option>
            <option>Pending  </option>
            <option>Approved </option>
            <option>Rejected </option>
        </select>
    </div>



<div id="myModal" class="modal fade" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content" style="width: 1268px; margin-left: -333px;">
            <div class="modal-header">
                <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                <h4 class="modal-title" id="titleee">Add Test Result</h4>
            </div>
            <div id="dvSingleTestName">
                <p id="pTestName" style="margin-left: 29px; font-size: 20px; color: blue;"></p>
            </div>
            <div class="modal-body">
               <table class="test-table responstable" id="tblsingleTest">
    <thead>
        <tr>
            <th>Fixed Type</th>
            <th>Patient Result</th>
            <th>Reference Ranges</th>
            <th>List Type</th>
            <th>Growth/Non Growth</th>
            <th>Organism Detected</th>
            <th>Image Upload</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td data-label="Fixed Type">
                <textarea id="txtfixedType" name="txtfixedType"></textarea>
                <div style="margin-top: 25px;">
                    <select id="chkUltraSound_level" class="wgtmsr"></select>
                </div>
            </td>
            <td data-label="Patient Result">
                <input type="text" id="txtvaluetype" class="arrow-togglable" style="margin-left: 0; width: 100%; max-width: 297px;" />
            </td>
            <td data-label="Reference Ranges">
                <input type="text" id="ranges" class="arrow-togglable" style="margin-left: 0; width: 100%; max-width: 297px;" readonly />
            </td>
            <td data-label="List Type">
                <select id="ddllistType" class="arrow-togglable" style="margin-left: 0; width: 100%; max-width: 297px;"></select>
            </td>
            <td data-label="Growth/Non Growth">
                <select id="ddlGrowth" style="width:100% !important; max-width:297px;"></select>
                <input type="button" id="btnGrowth" name="AddGrowth" value="Add" class="btn btn-primry" />
                <textarea rows="4" cols="50" id="txtAreaGrowth" style="width: 100%; max-width: 297px; margin-top: 8px;"></textarea>
                <select id="growthInfor" style="margin-top: 15px; width:100% !important; max-width:297px;"></select>
                <input type="button" id="btnGrowthInfo" name="AddGrowthInfo" value="Add" class="btn btn-primry" style="margin-top: 8px;" />
                <textarea rows="4" cols="50" id="txtAreaGrowthInfo" style="width: 100%; max-width: 297px; margin-top: 8px;"></textarea>
            </td>
            <td data-label="Organism Detected">
                <select id="ddlOrganism" class="limitedNumbChosen" style="width:100% !important; max-width:297px;"></select>
                <input type="button" id="btnOrganism" name="AddOrganism" value="Add" class="btn btn-primry" style="margin-top: 8px;" />
                <table id="tblOrganism" class="responstable">
                    <thead>
                        <tr>
                            <th contenteditable>Org Name</th>
                            <th contenteditable></th>
                            <th contenteditable></th>
                            <th contenteditable></th>
                            <th contenteditable>Action</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </td>
            <td data-label="Image Upload">
                <asp:FileUpload runat="server" ID="fileUploadMultiple" AllowMultiple="true" CssClass="image" onchange="readIMGsingle(this)" />
                <div id="container" style="width: 150px; margin-top: 10px;"></div>
            </td>
            <td style="display: none;" data-label="">
                <input type="hidden" id="hdtestdetailid" />
            </td>
        </tr>
    </tbody>
</table>
                <table id="tblgroupTestlist" class="table">
                    <thead>
                        <tr>
                            <th style="display: none"></th>
                            <th>Test Name</th>
                            <th>Fixed Type</th>
                            <th>Patient Result</th>
                            <th>Reference Ranges</th>
                            <th style="width: 193px;">List Type</th>
                            <th>Image Upload</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>


            <div class="modal-body">
                <div class="modal" id="myInnerModal1">
                    <div class="modal-dialogue">
                        <div class="modal-content">
                            <div class="modal-body">
                                <textarea name="txtMaster_Remarks" id="txtMaster_Remarks" rows="10" cols="80"></textarea>
                                <script>
                                    CKEDITOR.replace('txtMaster_Remarks');
                                </script>
                            </div>
                            <div class="modal-footer">
                                <input type="button" id="btndismiss" class="btn btn-danger" value="Close" onclick="$('#myInnerModal1').modal('hide');" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer">
                <div class="row">
                    <div class="col-lg-2 col-md-6 col-sm-12">
                <input class="btn btn-yellow" data-toggle="modal" data-target="#myInnerModal1" style="color:white !important;border-radius:5px;height:35px;" value="Remarks" />
                        </div>
                    <div class="col-lg-2 col-md-6 col-sm-12">
                <input type="button" class="btn btn-primry" id="saveTest" name="saveTest" value="Save" />
                        </div>
                    <div class="col-lg-2 col-md-6 col-sm-12">
                <input type="button" id="btnApprove" class="btn btn-primry" name="btnApprove" value="Approve"  />
                        </div>
                    <div class="col-lg-2 col-md-6 col-sm-12">
                <input type="button" id="btnReject" class="btn btn-primry" name="btnReject" value="Reject"  />
                        </div>
                <asp:Button ID="buttonimageuploadNotes" runat="server" OnClick="buttonimageuploadNotes_Click" Text=" " Style="display: none;" />
                <asp:Button ID="btnRefresh" runat="server" OnClick="btnRefresh_Click" Style="display: none" />
                <asp:HiddenField ID="session_obejct" runat="server" />
            </div>
        </div>
    </div>
    </div>
      </div>

    <div class="row">
    <div class="col-lg-8">
    <div class="row">
        <div class="col-lg-2 col-md-12 mb-2">
            <asp:Button Text="Back" runat="server" Class="btn btn-primry" ID="btnBack" CausesValidation="false" PostBackUrl="~/Modules/Lab/LaboratoryTestView.aspx" />
        </div>
        <div class="col-lg-2 col-md-12 mb-2">
            <input type="button" class="btn-gray"  id="btnResultPrint" value="Print"  onclick="ShowReport()" />
        </div>
        <div class="col-lg-2 col-md-12 mb-2">
            <asp:Button Text="New" class="btn btn-gray" runat="server" ID="Button1" OnClick="Button1_Click" />
        </div>
    </div>
        </div>
        </div>
</asp:Content>

