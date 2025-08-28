<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SampleCollectionFrom.aspx.cs" Inherits="PMS.SampleCollectionFrom" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/LabSample.css" rel="stylesheet" />
    <script type="text/javascript">   


        var CheckedTest = [];

        $(document).ready(function () {
            debugger;

            loadRangeType();
            $('#btnDetail').on('click', function () {
                debugger;
                if (localStorage.IsBill == 0) {
                    PopUPDetail();
                    $('#TestItemsModel').modal({
                        backdrop: 'static'
                    });

                }
                else if (localStorage.IsBill == 1) {
                    PopUPDetailBill();
                    $('#TestItemsModel').modal({
                        backdrop: 'static'
                    });
                }

            });
            var sampleID = '<%= Request.QueryString["SampleId"]%>';
             var sampleNo = '<%= Request.QueryString["SampleNo"]%>';
             debugger;
             var Patient_ID = '<%= Request.QueryString["Patient_ID"]%>';
             FillEmployeeNames();
             if (sampleID != "") {
                 debugger;
                 LoadTestEditMode(sampleID);
                 getSampleCode();
             }
             else {
                 GetNextSampleNo();
                 GetNextSampleSequence();
             }
             debugger;
             GetPendingList();
             loadtokenInputsDefaultPRNo();
             loadtokenInputsDefaultBill();
             debugger;
             var date = '<%= DateTime.Now %>';
             $("#txtSampleCollected_Date").val(date);

             if (Patient_ID != '') {
                 FillTokenInputForMRNo(Patient_ID);
             }
             $('#txtMRNOSearch').keyup(function (e) {
                 debugger;


                 var MRno = $('#txtMRNOSearch').val();
                 var tbl = document.getElementById('tblPendingSample');
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
        function FillTokenInputForMRNoQ() {
            debugger;
            var PatientID = '<%= Request.QueryString["ID"]%>';


            if (PatientID != "") {
                debugger;
                $('#txtMRNo').tokenInput('clear');
                var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientID);

                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });

            }
            else {

            }
        }
        function loadtokenInputsDefaultBill() {
            debugger;
            $('#txtBillNo').tokenInput("../../json.aspx?Table=Billing",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            localStorage.IsBill = 1;

                            $("#hdBillID").val(item.id);
                            var patient_id = $("#hdPatientID").val();
                            if (patient_id == "") {
                                $("#hdPatientID").val(item.PaientID);
                            }
                            else {

                            }
                            debugger;


                            GetPatientDetail();
                            $('#txtMR_No').tokenInput('clear');
                            var patient_id = $("#hdPatientID").val();
                            var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + patient_id);

                            $('#txtMR_No').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });

                            var sampleID = '<%= Request.QueryString["SampleId"]%>';
                             if (sampleID == '') {

                             }
                         }
                         catch (err) {
                             alert(err.message);
                         }

                     }
                 });


        }
        function PopUPDetailBill() {
            debugger;

            var BillId = $("#hdBillID").val();
            var ids = [];
            debugger;
            if ($('#CollectedSample tbody tr').length == 0) {
                ids[0] = -1;
            }
            else {
                var length = $('#CollectedSample tbody tr').length;
                for (var i = 0; i < length; i++) {
                    ids[i] = CheckedTest[i][2];
                }
            }

            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetTestDetailBill",
                data: JSON.stringify({
                    "BillId": BillId,
                    "Ids": ids
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var parse = JSON.parse(response.d)
                    debugger;
                    var length = CheckedTest.length;

                    if (parse.length != 0) {
                        var rows = "";
                        var PateintDep = "";
                        for (var i = 0; i < parse.length; i++) {

                            rows += '<tr><td style="width:32px;"></td><td style="display:none;">' + parse[i].Item_ID + '</td><td style="display:none;">' + parse[i].Bill_Details_ID + '</td><td>' + parse[i].Item_Name + '</td><td>' + PateintDep + '</td><td>' + parse[i].Gener + '</td><td>' + parse[i].Qty + '</td><td><input type="checkbox" class="' + parse[i].Item_Name + '" value="' + parse[i].Item_ID + ',' + parse[i].Bill_Details_ID + ',' + PateintDep + ',' + parse[i].Gener + ',' + parse[i].Qty + '"style="margin-top:-20px;" onclick="checkBoxClicked(this)" /></td></tr>';


                        }

                        debugger
                        $('#tblDetailModelTable tbody tr').remove();
                        $('#tblDetailModelTable tbody').append(rows);


                        debugger;

                    }
                    else {
                        $("#listModel").show();

                    }
                },
                failure: function (response) {
                    debugger;
                    alert("error!");
                }
            });

        }
        function getquerystring() {
            var queryString = new Array();
            $(function () {
                if (queryString.length == 0) {
                    if (window.location.search.split('?').length > 1) {
                        var params = window.location.search.split('?')[1].split('&');
                        for (var i = 0; i < params.length; i++) {
                            var key = params[i].split('=')[0];
                            var value = decodeURIComponent(params[i].split('=')[1]);
                            queryString[key] = value;
                        }
                    }
                }
                if (queryString["Patient_ID"] != null) {
                    var data = "<u>Values from QueryString</u><br /><br />";
                    data += "<b>Name:</b> " + queryString["Patient_ID "];
                    $("#lblData").html(data);
                    alet("data");

                }
            });
        }

        function getSampleCode() {
            debugger;
            var sampleID = '<%= Request.QueryString["SampleId"]%>';
             var sampleNo = '<%= Request.QueryString["SampleNo"]%>';
            $.ajax({
                type: "post",
                url: "SampleCollectionFrom.aspx/GetSampleCode",
                data: JSON.stringify({
                    "SampleID": sampleID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = response.d;


                    $('#txtSampleCode').val(parse);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function GetPendingList() {
            debugger;
            $.ajax({
                type: "post",
                url: "SampleCollectionFrom.aspx/PendingSampleList",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {


                    var parse = JSON.parse(response.d);
                    var rows = "";
                    for (var i = 0; i < parse.length; i++) {
                        debugger;
                        var TrnsDate = parseInt(parse[i].Creation_Date.substr(6));
                        TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY hh:mm A');

                        rows += '<tr><td style="display:none;">' + parse[i].Patient_ID + '</td><td>' + parse[i].Bill_No + '</td><td>' + parse[i].Patient_No + '</td><td>' + parse[i].Full_Name + '</td><td>' + TrnsDate + '</td><td>' + parse[i].Patient_Category + '</td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="GetSelectedDetail(' + parse[i].Bill_No + ')">Select</a></td></tr>';
                    }
                    $("#tblPendingSample").append(rows);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function LoadTestEditMode(sampleID) {
            debugger;
            if (sampleID.length > 0) {
                debugger;
                $.ajax({
                    type: "post",
                    url: "SampleCollectionFrom.aspx/LoadSampleHeader",
                    data: JSON.stringify({
                        "SampleID": sampleID
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var parse = JSON.parse(response.d);
                        var length = parse.length;

                        $("#txtSample_No").val(parse[0].Sample_No);
                        $("#hdSample_ID").val(parse[0].Sample_ID);
                        $("#txtSampleCollected_Date").val(parse[0].Sample_Collected_Date);
                        FillTokenInputForMRNo(parse[0].Patient_ID);
                        $("#Emp_Name").val(parse[0].Collected_Emp_ID);
                        debugger;
                        $.ajax({
                            type: "post",
                            url: "SampleCollectionFrom.aspx/LoadSampleDetail",
                            data: JSON.stringify({
                                "SampleID": sampleID
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                debugger;
                                var parse = JSON.parse(response.d);
                                var parse_for_check = parse;
                                var length = parse.length;
                                var rows;
                                debugger;
                                for (var i = 0; i < length; i++) {
                                    var checked = '';
                                    debugger;
                                    rows += '<tr><td style="display:none">' + parse[i].Test_ID + '</td><td style="display:none">' + parse[i].Bill_Details_ID + '</td><td style="text-align: center;">' + parse[i].Test_Name + '</td><td style="text-align: center;">' + parse[i].Dept + '</td><td style="text-align: center;">' + parse[i].Gener + '</td><td style="text-align: center;">' + parse[i].Qty + '</td><td style="text-align: center;"><input type="checkbox"  value="' + parse[i].Sample_Collected + '" id="Check' + i + '" name="Check"/><td style="text-align: center;"><input style="width: 150px;" type="text" name="Remarks" value="' + parse[i].Remarks + '" id="Remarks' + i + '"/></td></td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="DeleteTest(this)">Delete</a></td></tr>';
                                }
                                $('#CollectedSample tbody tr').remove();
                                $('#CollectedSample tbody').append(rows);
                                $.each(parse_for_check, function (key, value) {
                                    if (parse_for_check[key].Sample_Collected == true) {
                                        $('#Check' + key + '').prop('checked', true);
                                        $('#Check' + key + '').prop('disabled', true);
                                        $('#Remarks' + key + '').prop('disabled', true);
                                    }

                                });

                                $('#btSnave').val('Update');
                                debugger;
                                CheckedTest = CollectedSampleTableArray();
                            },
                            failure: function (response) {
                                alert("In failure method");
                            }
                        });
                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
            }
        }

        function DeleteTest(RowReference) {
            debugger;
            var row = $(RowReference).parents('tr')[0];

            if (confirm('Are you sure want to delete this record')) {
                debugger;
                var length = CheckedTest.length;
                for (var i = 0; i < length; i++) {
                    if (CheckedTest[i][0] == $($(row).find('td')[0]).text()) {
                        CheckedTest.splice(i, 1);
                        break;
                    }
                }
                row.remove();
            }
        }

        function FillTokenInputForMRNo(PatientID) {
            debugger;

            if (PatientID != "") {
                $('#txtMR_No').tokenInput('clear');
                var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientID);

                $('#txtMR_No').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
                $("#hdPatientID").val(JSON.parse(tokendata)[0].id);
                GetPatientDetail();
            }
            else {

            }
        }

        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function FillEmployeeNames() {
            debugger;

            $.ajax({
                type: "post",
                url: "SampleCollectionFrom.aspx/GetEmployeeNames",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    var length = parse.length;

                    var rows = "";
                    for (var i = 0; i < length; i++) {
                        rows += '<option value="' + parse[i].Emp_ID + '">' + parse[i].Emp_Name + '</option>';
                    }
                    debugger;
                    $("#Emp_Name option").remove();
                    $("#Emp_Name").append(rows);

                },
                failure: function (response) {
                    alert("In failure method");
                }

            });
        }

        function GetNextSampleNo() {
            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetSampleNo",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    $("#txtSample_No").val(response.d);
                },
                failure: function (response) {
                    debugger;
                    alert("error!");
                }
            });
        }

        function GetNextSampleSequence() {
            debugger;
            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetSampleSequenceId",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var maxno = response.d;
                    var date = new Date().getFullYear().toString().substr(-2);
                    SampleNoWithYear = (maxno + '-' + date);
                    $("#txtSample_ID").val(SampleNoWithYear);
                },
                failure: function (response) {

                    alert("error!");
                }
            });
        }


        function checkBoxClicked(value) {
            debugger;
            var TempArray = [];
            debugger;
            TempArray[0] = value.className;
            TempArray[1] = value.value.split(',')[0];
            TempArray[2] = value.value.split(',')[1];
            TempArray[3] = value.value.split(',')[2];
            TempArray[4] = value.value.split(',')[3];
            TempArray[5] = value.value.split(',')[4];
            if (value.checked == true) {
                CheckedTest.push(TempArray);
                debugger;
                var row;

                row = '<tr id=' + TempArray[1] + '><td style="display:none;">' + TempArray[1] + '</td><td style="display:none;">' + TempArray[2] + '</td><td style="text-align: center;">' + TempArray[0] + '</td><td style="text-align: center;">' + TempArray[3] + '</td><td style="text-align: center;">' + TempArray[4] + '</td><td style="text-align: center;">' + TempArray[5] + '</td><td style="text-align: center;"><input type="checkbox" name="Check" checked="checked" disabled = "disabled"/></td><td style="text-align: center;"><input type="text" name="Remarks"/></td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="DeleteTest(this)">Delete</a></td></tr>';

                $('#CollectedSample tbody').append(row);
            }
            else if (value.checked == false) {
                debugger;
                var length = CheckedTest.length;
                debugger;
                for (var i = 0; i < length; i++) {

                    if (CheckedTest[i][1] == value.value.split(',')[0] /*Test ID*/) {
                        $('#' + TempArray[1] + '').remove();
                        CheckedTest.splice(i, 1);
                        return false;
                    }
                }
            }
        }

        function appendTests() {
            $('#TestItemsModel').modal('hide');
        }

        function PopUPDetail() {
            debugger;

            var mrNo = $("#hdPatientID").val();
            var ids = [];
            debugger;
            if ($('#CollectedSample tbody tr').length == 0) {
                ids[0] = -1;
            }
            else {
                var length = $('#CollectedSample tbody tr').length;
                for (var i = 0; i < length; i++) {
                    ids[i] = CheckedTest[i][2];
                }
            }
            debugger;
            var PateintDep;
            mrNo = mrNo.trim();
            if (mrNo != "") {
                debugger;
                var pateintNo = $("#txtMR_No").val().toString().split('-')[0];
                $.ajax({
                    type: "POST",
                    url: "SampleCollectionFrom.aspx/GetPatientDep",
                    data: JSON.stringify({
                        "PateintNo": pateintNo,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var parse1 = JSON.parse(data.d)
                        debugger;
                        PateintDep = parse1;
                    },
                    failure: function (response) {
                        debugger;
                        alert("error!");
                    }
                });
                debugger;
                $.ajax({
                    type: "POST",
                    url: "SampleCollectionFrom.aspx/GetTestDetail",
                    data: JSON.stringify({
                        "MRNo": mrNo,
                        "Ids": ids
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var parse = JSON.parse(response.d)
                        debugger;
                        var length = CheckedTest.length;
                        debugger;
                        if (parse.length != 0) {
                            var rows = "";
                            for (var i = 0; i < parse.length; i++) {
                                debugger;
                                rows += '<tr><td style="width:32px;"></td><td style="display:none;">' + parse[i].Item_ID + '</td><td style="display:none;">' + parse[i].Bill_Details_ID + '</td><td>' + parse[i].Item_Name + '</td><td>' + PateintDep + '</td><td>' + parse[i].Gener + '</td><td>' + parse[i].Qty + '</td><td><input type="checkbox" class="' + parse[i].Item_Name + '" value="' + parse[i].Item_ID + ',' + parse[i].Bill_Details_ID + ',' + PateintDep + ',' + parse[i].Gener + ',' + parse[i].Qty + '"style="margin-top:-20px;" onclick="checkBoxClicked(this)"/></td></tr>';
                            }
                            $('#tblDetailModelTable tbody tr').remove();
                            $('#tblDetailModelTable tbody').append(rows);
                            debugger;
                            $('#TestItemsModel').modal({
                                backdrop: 'static'
                            });
                        }
                        else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'No record exist',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        }
                    },
                    failure: function (response) {
                        debugger;
                        alert("error!");
                    }
                });
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Patient ID',
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

        function CollectedSampleRemarksArray() {
            debugger;
            var RemArray = [];
            $("table#CollectedSample tbody tr").each(function () {
                debugger;
                var tmpArr = [];
                tmpArr[0] = $(this).find('td input[name=Remarks]').val();
                tmpArr[1] = $(this).find('td input[name=Check]')[0].checked;
                RemArray.push(tmpArr);
            });
            return RemArray;
        }
        function CollectedSampleTableArray() {
            debugger;
            var SelectedTestArray = [];
            $("table#CollectedSample tbody tr").each(function () {
                debugger;
                var TempRow = [];
                TempRow[0] = $(this).find('td:eq(2)').text();
                TempRow[1] = $(this).find('td:eq(0)').text();
                TempRow[2] = $(this).find('td:eq(1)').text();
                TempRow[3] = $(this).find('td:eq(3)').text();
                TempRow[4] = $(this).find('td:eq(4)').text();
                TempRow[5] = $(this).find('td:eq(5)').text();
                TempRow[6] = $(this).find('td input[name=Remarks]').val();
                TempRow[7] = $(this).find('td input[name=Check]')[0].checked;



                SelectedTestArray.push(TempRow);
            });
            return SelectedTestArray;
        }
        function loadtokenInputsDefaultPRNo() {
            debugger;
            $('#txtMR_No').tokenInput("../../json.aspx?Table=Patients",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {

                            $("#hdPatientID").val(item.id);
                            $("#txtMR_No").val(item.name);
                            var bill_id = $("#txtBillNo").val();

                            GetPatientDetail();
                            var sampleID = '<%= Request.QueryString["SampleId"]%>';
                             if ($('#txtBillNo').val() == "") {
                                 localStorage.IsBill = 0;
                             }
                             if (sampleID == '') {


                             }

                         }
                         catch (err) {
                             alert(err.message);
                         }

                     }
                 });

            $('#token-input-txtMR_No').focus();
        }


        function GetPatientDetail() {
            $("#listModel").hide();
            debugger;
            var patientID = $("#hdPatientID").val();

            debugger;
            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetPatient",
                data: JSON.stringify({
                    "PatientID": patientID,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);

                    $("#vlblPatients_Name").text(parse[0].Full_Name);
                    $("#vLbl_Contact").text(parse[0].Mobile1);
                    $("#vLbl_Adress").text(parse[0].City);
                    $("#vLbl_Gender").text(parse[0].Gender);
                    $("#vLbl_Age").text(parse[0].Age_years);
                    $("#vLbl_RegDate").text(parse[0].RegDate);
                    $("#vLbl_Specimen").text(parse[0].Specimen);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function GetSelectedDetail(Bill_No) {
            debugger;
            localStorage.IsBill = 1;

            if (Bill_No != "") {

                $('#txtBillNo').tokenInput('clear');

                var tokenData = httpGet("../../json.aspx?Table=Billing&q=" + Bill_No);
                $('#hdPatientID').val(JSON.parse(tokenData)[0].PaientID);

                $('#txtBillNo').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });

                $("#hdBill_id").val(JSON.parse(tokenData)[0].id);
                $("#hdnBill_No").val(JSON.parse(tokenData)[0].name);
            }
            else {

            }
        }

        debugger;
        function Print() {
            debugger;
            var sampleID = $("#hdSample_ID").val();
            window.open('ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Sample_ID=' + sampleID);
        }

        function loadRangeType() {

            var options = '<option value="0" >Select</option>';

            PageMethods.LoadPatRange(function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlPat_type').html(options);
                $('#ddlPat_type').val('6');

            });
        }

       

        function NewEntry() {
            window.location.href = "SampleCollectionFrom.aspx";
        }
        function SaveTest() {
            debugger;
            var cbEmployee = document.getElementById("Emp_Name");
            var employeeID = cbEmployee.options[cbEmployee.selectedIndex].value;
            debugger;
            var collectedDate = $("#txtSampleCollected_Date").val();
            var ddlPat_type = $("#ddlPat_type").val();

            if (ddlPat_type == 0 || ddlPat_type == "0" || ddlPat_type == '0' || ddlPat_type == null) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Patient Type',
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

            var mrNo = $("#hdPatientID").val();
            mrNo = mrNo.trim();
            var length = CheckedTest.length;
            var saveCheckedTest = CheckedTest;
            var rem = CollectedSampleRemarksArray();


            debugger;
            if (collectedDate != "" && mrNo != "") {
                if (length == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Select at least one test',
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
                    debugger;
                    if ($('#btSnave').val() == 'Save') {
                        debugger;
                        $.ajax({
                            type: "POST",
                            url: "SampleCollectionFrom.aspx/SaveTest",
                            data: JSON.stringify({
                                "CollectedDate": collectedDate,

                                "PatientID": mrNo,
                                "SaveCheckedTest": saveCheckedTest,
                                "EmployeeID": employeeID,
                                "rem": rem,
                                "ddlPat_type": ddlPat_type


                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",

                            success: function (response) {
                                debugger;
                                var splitted = response.d.split('-')[0];
                                var id = response.d.split('-')[1];
                                if (splitted == "Save") {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Save successfully',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });

                                    debugger;
                                    window.location = "SampleCollectionFrom.aspx?sampleID=" + id;
                                }
                                else {
                                    alert(response.d);
                                }
                            },
                            failure: function (response) {
                                debugger;
                                alert("In failure method");
                            }
                        });
                    }
                    if ($('#btSnave').val() == 'Update') {
                        debugger;
                        var sampleID = $("#hdSample_ID").val();
                        $.ajax({
                            type: "POST",
                            url: "SampleCollectionFrom.aspx/UpdateTest",
                            data: JSON.stringify({
                                "CollectedDate": collectedDate,

                                "SaveCheckedTest": saveCheckedTest,
                                "EmployeeID": employeeID,
                                "SampleID": sampleID,
                                "rem": rem,
                                "ddlPat_type": ddlPat_type
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",

                            success: function (response) {
                                debugger;
                                if (response.d == "Update") {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Updated successfully',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });

                                    debugger;
                                    window.location = "SampleCollectionFrom.aspx?sampleID=" + id;

                                    $("#txtMR_No").tokenInput("clear");
                                    $('#CollectedSample tbody tr').remove();
                                    CheckedTest = [];
                                    GetNextSampleNo();
                                    GetNextSampleSequence();
                                }
                                else {
                                    alert(response.d);
                                }
                            },
                            failure: function (response) {
                                debugger;
                                alert("In failure method");
                            }
                        });
                    }
                }
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'MR No. missing',
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

        function ListView() {
            window.open("TransactionView.aspx?Tag=SampleView");
        }

        function toggleAll(source) {
            var checkboxes = $('#tblDetailModelTable tbody input[type="checkbox"]');
            checkboxes.each(function () {
                this.checked = source.checked; 
                checkBoxClicked(this); 
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <!-- Left Card -->
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Lab2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label for="BillNo" style="font-weight: bold">Bill No: </label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6">
                                        <input type="text" id="txtBillNo" class="form-control" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label for="lblPatient_Name">Name:  </label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                        <label id="vlblPatients_Name"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label for="lblContactNo">Contact No :  </label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                        <label id="vLbl_Contact"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label for="lblGender" style="font-weight: bold">Gender:  </label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                        <label id="vLbl_Gender"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label for="lblAge_Years" style="font-weight: bold">Age Years:  </label>
                                    </div>
                                    <div class="col-lg-7 col-md-7 col-sm-6 formrgn">
                                        <label id="vLbl_Age"></label>
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
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <label for="MRNo">MR no:</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <input type="text" id="txtMR_No" class="form-control" />
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <label for="LblReg_Date">Reg. Date:  </label>
                            </div>
                            <div class="col-lg-8 col-md-5 col-sm-6 formrgn">
                                <label id="vLbl_RegDate"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <label for="lblAdress" style="font-weight: bold">Address:  </label>
                            </div>
                            <div class="col-lg-8 col-md-5 col-sm-6 formrgn">
                                <label id="vLbl_Adress"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                <label for="lblSpecimen" style="font-weight: bold">Specimen:  </label>
                            </div>
                            <div class="col-lg-8 col-md-5 col-sm-6 formrgn">
                                <label id="vLbl_Specimen"></label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>



        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label>Sample ID</label>
                <input type="text" id="txtSample_ID" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label for="SampleNo">Sample No:  </label>
                <input type="text" id="txtSample_No" class="form-control" readonly="readonly" />
            </div>
            
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label id="sampleCode" style="display: inline-block;">Sample Code</label>
                <input type="text" disabled="disabled" id="txtSampleCode" class="form-control" />
            </div>
            <div class="col-lg-1 col-md-3 col-sm-4">
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label id="lblSample_Date" style="display: inline-block;">Collected Date*</label>
                <input type="text" readonly="readonly" id="txtSampleCollected_Date" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label id="" style="display: inline-block;">Patient Type<span style="color: red;">*</span></label>
                <select id="ddlPat_type" class="form-control"></select>
            </div>
        </div>
    </form>

    <input type="hidden" id="hdSample_ID" />
    <input type="hidden" id="hdPatientID" />
    <input type="hidden" id="hdBillID" />
    <label id="lblEmp_Name" style="margin-left: 20px;display:none">Employee Name*</label>
    <select id="Emp_Name" style="height: 33px; margin-top: 11px; display:none">
        <option></option>
    </select>
    <div class="panel panel-default">
        <div class="panel-body">
            <div id="r1">
            </div>

            <div class="table-container">
                <input type="button" id="btnDetail" class="btn btn-primry" value="Select Test" style="margin-left: 88%; width: 12% !important;" />
                <table class="responstable table" id="CollectedSample" style="overflow: scroll; height: auto;">
                    <thead id="Collected_Sample_Head">
                        <tr id="Collected_Sample_tr">
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px; display: none">Test ID</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px; display: none">Bill Detail ID</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px;">Test Name</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px;">Department</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px">Gener</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px">Quantity</th>
                            <th style="text-align: center;">Collected</th>
                            <th style="text-align: center; padding-left: 0px; padding-right: 0px; width: 210px !important">Remarks</th>
                            <th style="text-align: center;">Action</th>

                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>


            </div>
            <div class="row">
                <div class="col-lg-8">
                    <div class="row">
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input id="btSnave" class="btn btn-primry" type="button" value="Save" onclick="SaveTest()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input id="btnList" class="btn-gray" type="button" value="View" onclick="ListView()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input id="btnNew" class="btn btn-yellow" type="button" value="New" onclick="NewEntry()" />
                </div>
                <div class="col-lg-2 col-md-3 col-sm-4">
                    <input id="btnPrintBarcode" class="btn btn-primry" type="button" value="Barcode" onclick="PrintBarcode()" />
                </div>
                        <div class="col-lg-2 col-md-3 col-sm-4" style="display:none">
                        <input id="btnPrint" class="btn btn-primry" type="button" value="Print" onclick="Print()"/>
                            </div>
            </div>
        </div>
    </div>
    </div>
    </div>

    <div id="TestItemsModel" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="TestItemsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h4 class="modal-title" id="TestItemsModalLabel">Detail Selection</h4>
                   
                </div>
                <div class="modal-body">
                    <input type="hidden" id="txthiddentr" name="txthiddentr" />
                    <div class="table-responsive" style="max-height: 400px; overflow-y: auto;">
                        <table class="table table-bordered table-striped" id="tblDetailModelTable">
                            <thead class="table-light">
                                <tr>
                                    <th style="width: 32px;"></th> 
                                    <th style="display: none">Test ID</th>
                                    <th style="display: none">Bill Detail ID</th>
                                    <th>Test Name</th>
                                    <th>Department</th>
                                    <th>Gener</th>
                                    <th>Quantity</th>
                                    <th><input type="checkbox" id="chkAll"  onclick="toggleAll(this)" /></th>
                                    
                                </tr>
                            </thead>
                            <tbody>
                                <!-- Dynamic rows go here -->
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" id="btnDetailSelection" class="btn btn-gray" name="btnDetailSelection" value="Close" onclick="appendTests()">Close</button>

                </div>
            </div>
        </div>
    </div>

    <div class="modal-content" style="height: 505px; overflow-y: auto" id="listModel">
        <div class="modal-header header-sample" style=" color: white;">
            <h4 class="modal-title">Sample Calling List</h4>
        </div>

        <b style="margin-left: 10px;">Search From Bill No:</b>
        <div class="col-lg-4 col-md-5 col-sm-6">
            <input id="txtMRNOSearch" type="text" style="margin-left: 12px;"></input>
        </div>

        <input type="hidden" id="Hidden1" name="txthidddentr" />
        <div>
            <table class="table" id="tblPendingSample">
                <thead>
                    <tr>
                        <th>Bill No</th>
                        <th>MR No</th>
                        <th>Patient Name</th>
                        <th>Bill Date</th>
                        <th>Department</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
