<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SampleCollectionFrom.aspx.cs" Inherits="PMS.SampleCollectionFrom" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/sample-collection.css" rel="stylesheet" />
    <script type="text/javascript">


        var CheckedTest = [];

        $(document).ready(function () {

            loadRangeType();
            loadUserBranch();
            FillOutSource();
            FillSampleStatus();
            GetacknowlagmentCondition();
            $('#btnDetail').on('click', function () {
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
             var Patient_ID = '<%= Request.QueryString["Patient_ID"]%>';
             FillEmployeeNames();
             if (sampleID != "") {
                 LoadTestEditMode(sampleID);
                 getSampleCode();
             }
             else {
                 GetNextSampleNo();
                 GetNextSampleSequence();
             }
             GetPendingList();
             loadtokenInputsDefaultPRNo();
             loadtokenInputsDefaultBill();
             var date = '<%= DateTime.Now %>';
             $("#txtSampleCollected_Date").val(date);

             if (Patient_ID != '') {
                 FillTokenInputForMRNo(Patient_ID);
             }
             $('#txtMRNOSearch').keyup(function (e) {


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
        var acknowlagment;
        function GetacknowlagmentCondition() {

            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetAcknowlagmentCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    acknowlagment = JSON.parse(response.d);                   
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function FillTokenInputForMRNoQ() {
            var PatientID = '<%= Request.QueryString["ID"]%>';


            if (PatientID != "") {
                $('#txtMRNo').tokenInput('clear');
                var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientID);

                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });

            }
            else {

            }
        }
        function loadtokenInputsDefaultBill() {
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
            var BillId = $("#hdBillID").val();
            var ids = [];

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
                    var Branch = $('#ddlUserBranch').val();
                    var parse = JSON.parse(response.d);

                    if (parse.length === 0) {
                        $("#listModel").show();
                        return;
                    }

                    if (parse[0].Branch_Id != Branch) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'This Test Not Belongs to this Branch.',
                            showConfirmButton: false,
                            timer: 2000
                        });
                        return;
                    }

                    var rows = "";
                    var PatientDep = "";

                    for (var i = 0; i < parse.length; i++) {
                        var sampleRemarks = parse[i].Sample_Remarks || '';

                        rows += '<tr>'
                            + '<td style="width:32px;">'
                            + '<td style="display:none;">' + parse[i].Item_ID + '</td>'
                            + '<td style="display:none;" class="bill-detail-id">' + parse[i].Bill_Details_ID + '</td>'
                            + '<td>' + parse[i].Item_Name + '</td>'
                            + '<td>' + PatientDep + '</td>'
                            + '<td>' + parse[i].Gener + '</td>'
                            + '<td>' + parse[i].Qty + '</td>'
                            + '<td class="remarks-cell">'
                            + '<input type="text" class="remarks-input-modal" placeholder="Enter remarks..." id="remarks_' + i + '" value="' + sampleRemarks.replace(/"/g, '&quot;') + '" />'
                            + '</td>'
                            + '<td>'
                            + '<button type="button" class="btn btn-sm btn-success save-remarks-btn" onclick="saveRemarks(this)">Save</button>'
                            + '</td>'
                            + '<td style="text-align:center;">'
                            + '<input type="checkbox" class="chkUrgentModal" id="urgent_' + i + '" />'
                            + '</td>'
                            + '<td>'
                            + '<input type="checkbox" class="' + parse[i].Item_Name + '" '
                            + 'value="' + parse[i].Item_ID + ',' + parse[i].Bill_Details_ID + ',' + PatientDep + ',' + parse[i].Gener + ',' + parse[i].Qty + '" '
                            + 'data-urgent="false" data-role="test-select" '
                            + 'style="margin-top:-20px;" onclick="checkBoxClicked(this)" />'
                            + '</td>'
                            + '</tr>';
                    }

                    $('#tblDetailModelTable tbody').empty();
                    $('#tblDetailModelTable tbody').append(rows);
                },
                failure: function (response) {
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
                    var parse = response.d;


                    $('#txtSampleCode').val(parse);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function GetPendingList() {
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
            if (sampleID.length > 0) {
                $.ajax({
                    type: "post",
                    url: "SampleCollectionFrom.aspx/LoadSampleHeader",
                    data: JSON.stringify({
                        "SampleID": sampleID
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var parse = JSON.parse(response.d);
                        var length = parse.length;
                        $('#token-input-txtBillNo').attr('disabled', 'disabled');
                        $('#token-input-txtMR_No').attr('disabled', 'disabled');
                        $("#txtSample_No").val(parse[0].Sample_No);
                        $("#hdSample_ID").val(parse[0].Sample_ID);
                        $("#txtRemarks").val(parse[0].Remarks);
                        $("#txtSampleCollected_Date").val(parse[0].Sample_Collected_Date);
                        FillTokenInputForMRNo(parse[0].Patient_ID);
                        $("#Emp_Name").val(parse[0].Collected_Emp_ID);
                        setTimeout(function () {
                            $("#ddlSample_Status").val(parse[0].Sample_Status).trigger();
                        }, 2000);
                        $.ajax({
                            type: "post",
                            url: "SampleCollectionFrom.aspx/LoadSampleDetail",
                            data: JSON.stringify({
                                "SampleID": sampleID
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                var parse = JSON.parse(response.d);
                                var parse_for_check = parse;
                                var length = parse.length;
                                var rows;
                                for (var i = 0; i < length; i++) {
                                    var checked = '';
                                    var urgentChecked = (parse[i].IsUrgent === true || parse[i].IsUrgent === 'true' || parse[i].IsUrgent === 1);
                                    rows += '<tr><td style="display:none">' + parse[i].Test_ID + '</td><td style="display:none">' + parse[i].Bill_Details_ID + '</td><td style="text-align: center;">' + parse[i].Test_Name + '</td><td style="text-align: center;">' + parse[i].Dept + '</td><td style="text-align: center;">' + parse[i].Gener + '</td><td style="text-align: center;">' + parse[i].Qty + '</td><td style="text-align: center;"><input type="checkbox"  value="' + parse[i].Sample_Collected + '" id="Check' + i + '" name="Check"/></td><td style="text-align: center;"><input type="checkbox" name="chkUrgent" id="chkUrgent' + i + '" ' + (urgentChecked ? 'checked="checked"' : '') + '/></td><td style="text-align: center;"><input style="width: 150px;" type="text" name="Remarks" value="' + parse[i].Remarks + '" id="Remarks' + i + '"/></td></td><td><select id="ddlOutSource" name="ddlOutSource">' + option_OutSource + '</select></td><td style="text-align: center;"><a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="DeleteTest(this)">Delete</a></td></tr>';
                               /*     $('select[name="ddlOutSource"]').eq(i).val(parse[i].OutSource);*/
                                }
                                $('#CollectedSample tbody tr').remove();
                                $('#CollectedSample tbody').append(rows);
                                for (var i = 0; i < parse.length; i++) {
                                    $('select[name="ddlOutSource"]').eq(i).val(parse[i].OutSource);
                                }

                                $.each(parse_for_check, function (key, value) {
                                    if (parse_for_check[key].Sample_Collected == true) {
                                        $('#Check' + key + '').prop('checked', true);
                                        $('#Check' + key + '').prop('disabled', true);
                                        $('#Remarks' + key + '').prop('disabled', true);
                                    }

                                });

                                $('#btSnave').val('Update');
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
            var row = $(RowReference).parents('tr')[0];

            if (confirm('Are you sure want to delete this record')) {
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

            $.ajax({
                type: "post",
                url: "SampleCollectionFrom.aspx/GetEmployeeNames",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var length = parse.length;

                    var rows = "";
                    for (var i = 0; i < length; i++) {
                        rows += '<option value="' + parse[i].Emp_ID + '">' + parse[i].Emp_Name + '</option>';
                    }
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
                    alert("error!");
                }
            });
        }

        function GetNextSampleSequence() {
            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetSampleSequenceId",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var maxno = response.d;
                    var date = new Date().getFullYear().toString().substr(-2);
                    SampleNoWithYear = (date + '-' + maxno); 
                    $("#txtSample_ID").val(SampleNoWithYear);
                },
                failure: function (response) {

                    alert("error!");
                }
            });
        }


        function FillSampleStatus() {
            var options = '<option value="">Select Status</option>';
            PageMethods.GetSampleStatus(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlSample_Status').html(options);

            });
            return options;
        }
        var option_OutSource = "";
        function FillOutSource() {
            option_OutSource = '<option value="0">Select Lab</option>';
            PageMethods.FillOutSource(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    option_OutSource += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
            });

        }

        function checkBoxClicked(value) {
            var TempArray = [];

            var remarksValue = "";
            var urgentValue = false;
            var $row = $(value).closest('tr');
            var $remarksInput = $row.find('.remarks-input-modal');
            if ($remarksInput.length > 0) {
                remarksValue = $remarksInput.val();
            }
            var $urgentInput = $row.find('.chkUrgentModal');
            if ($urgentInput.length > 0) {
                urgentValue = $urgentInput.is(':checked');
                value.setAttribute('data-urgent', urgentValue ? 'true' : 'false');
            } else {
                urgentValue = value.getAttribute('data-urgent') === 'true';
            }

            TempArray[0] = value.className;
            TempArray[1] = value.value.split(',')[0];
            TempArray[2] = value.value.split(',')[1];
            TempArray[3] = value.value.split(',')[2];
            TempArray[4] = value.value.split(',')[3];
            TempArray[5] = value.value.split(',')[4];
            TempArray[6] = remarksValue;
            TempArray[7] = urgentValue ? 'true' : 'false';

            if (value.checked == true) {
                CheckedTest.push(TempArray);
                var row;
                row = '<tr id="' + TempArray[1] + '">' +
                    '<td style="display:none;">' + TempArray[1] + '</td>' +
                    '<td style="display:none;">' + TempArray[2] + '</td>' +
                    '<td style="text-align: center;">' + TempArray[0] + '</td>' +
                    '<td style="text-align: center;">' + TempArray[3] + '</td>' +
                    '<td style="text-align: center;">' + TempArray[4] + '</td>' +
                    '<td style="text-align: center;">' + TempArray[5] + '</td>' +
                    '<td style="text-align: center;"><input type="checkbox" name="Check" checked="checked" disabled="disabled"/></td>' +
                    '<td style="text-align: center;"><input type="checkbox" name="chkUrgent" ' + (urgentValue ? 'checked="checked"' : '') + '/></td>' +
                    '<td style="text-align: center;"><input type="text" name="Remarks" value="' + remarksValue.replace(/"/g, '&quot;') + '"/></td>' +
                    '<td style="text-align: center;">' +
                    '<select id="ddlOutsource" name="ddlOutSource">' + option_OutSource + '</select>' +
                    '</td>' +
                    '<td style="text-align: center;">' +
                    '<a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="DeleteTest(this)">Delete</a>' +
                    '</td>' +
                    '</tr>';

                $('#CollectedSample tbody').append(row);
            } else if (value.checked == false) {
                var length = CheckedTest.length;
                for (var i = 0; i < length; i++) {
                    if (CheckedTest[i][1] == value.value.split(',')[0]) {
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
            var mrNo = $("#hdPatientID").val();
            var ids = [];

            if ($('#CollectedSample tbody tr').length == 0) {
                ids[0] = -1;
            }
            else {
                var length = $('#CollectedSample tbody tr').length;
                for (var i = 0; i < length; i++) {
                    ids[i] = CheckedTest[i][2];
                }
            }
            var PateintDep;
            mrNo = mrNo.trim();
            if (mrNo != "") {
                var pateintNo = $("#txtMR_No").val().toString().split('-')[0];
                $.ajax({
                    type: "POST",
                    url: "SampleCollectionFrom.aspx/GetPatientDep",
                    data: JSON.stringify({
                        "PateintNo": pateintNo,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (data) {
                        var parse1 = JSON.parse(data.d)
                        PateintDep = parse1;
                    },
                    failure: function (response) {
                        alert("error!");
                    }
                });
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
                        var Branch = $('#ddlUserBranch').val();
                        var length = CheckedTest.length;
                        if (parse[0].Branch_Id != Branch) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'This Test Not Belongs to this Branch.',
                                showConfirmButton: false,
                                timer: 2000
                            });
                            return;
                        }
                        if (parse.length != 0) {
                            var rows = "";
                            for (var i = 0; i < parse.length; i++) {
                                var sampleRemarks = (parse[i].Sample_Remarks || '').replace(/"/g, '&quot;');

                                rows += '<tr>'
                                    + '<td style="width:32px;">'
                                    + '<td style="display:none;">' + parse[i].Item_ID + '</td>'
                                    + '<td style="display:none;" class="bill-detail-id">' + parse[i].Bill_Details_ID + '</td>'
                                    + '<td>' + parse[i].Item_Name + '</td>'
                                    + '<td>' + PateintDep + '</td>'
                                    + '<td>' + parse[i].Gener + '</td>'
                                    + '<td>' + parse[i].Qty + '</td>'
                                    + '<td class="remarks-cell">'
                                    + '<input type="text" class="remarks-input-modal" placeholder="Enter remarks..." id="remarks_modal_' + i + '" value="' + sampleRemarks + '" />'
                                    + '</td>'
                                    + '<td>'
                                    + '<button type="button" class="btn btn-sm btn-success save-remarks-btn" onclick="saveRemarks(this)">Save</button>'
                                    + '</td>'
                                    + '<td style="text-align:center;">'
                                    + '<input type="checkbox" class="chkUrgentModal" id="urgent_' + i + '" />'
                                    + '</td>'
                                    + '<td>'
                                    + '<input type="checkbox" class="' + parse[i].Item_Name + '" '
                                    + 'value="' + parse[i].Item_ID + ',' + parse[i].Bill_Details_ID + ',' + PateintDep + ',' + parse[i].Gener + ',' + parse[i].Qty + '" '
                                    + 'data-urgent="false" data-role="test-select" '
                                    + 'style="margin-top:-20px;" onclick="checkBoxClicked(this)" />'
                                    + '</td>'
                                    + '</tr>';
                            }
                            $('#tblDetailModelTable tbody tr').remove();
                            $('#tblDetailModelTable tbody').append(rows);
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
                                timer: 2000
                            });
                        }
                    },
                    failure: function (response) {
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
                    timer: 2000
                });
            }
        }

        function CollectedSampleRemarksArray() {
            var RemArray = [];
            $("table#CollectedSample tbody tr").each(function () {
                var tmpArr = [];
                tmpArr[0] = $(this).find('td input[name=Remarks]').val();
                tmpArr[1] = $(this).find('td input[name=Check]')[0].checked;
                tmpArr[2] = $(this).find('td select[name=ddlOutSource]').val();
                RemArray.push(tmpArr);
            });
            return RemArray;
        }
        function CollectedSampleTableArray() {
            var SelectedTestArray = [];
            $("table#CollectedSample tbody tr").each(function () {
                var TempRow = [];
                TempRow[0] = $(this).find('td:eq(2)').text();
                TempRow[1] = $(this).find('td:eq(0)').text();
                TempRow[2] = $(this).find('td:eq(1)').text();
                TempRow[3] = $(this).find('td:eq(3)').text();
                TempRow[4] = $(this).find('td:eq(4)').text();
                TempRow[5] = $(this).find('td:eq(5)').text();
                TempRow[6] = $(this).find('td input[name=Remarks]').val();
                TempRow[7] = $(this).find('td input[name=chkUrgent]').is(':checked') ? 'true' : 'false';
                TempRow[8] = $(this).find('td input[name=Check]')[0].checked;
                SelectedTestArray.push(TempRow);
            });
            return SelectedTestArray;
        }

             function loadUserBranch() {
                PageMethods.GetUserBranch(function (result) {
                    if (!result || result === "null") {
                        $('#ddlUserBranch').empty().append('<option value="">No Branch Assigned</option>').prop('disabled', true);
                        return;
                    }

                    var branches = JSON.parse(result);
                    $('#ddlUserBranch').empty();
                    branches.forEach(function (branch) {
                        $('#ddlUserBranch').append(
                            '<option value="' + branch.branch_ID + '">' + branch.branch_Name + '</option>'
                        );
                    });
                    if (branches.length === 1) {
                        $('#ddlUserBranch').val(branches[0].branch_ID).prop('disabled', true);
                    } else {
                        $('#ddlUserBranch').prepend('<option value="">Select Branch</option>')
                            .val('')
                            .prop('disabled', false);
                    }
                });
            }
        function loadtokenInputsDefaultPRNo() {
      
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
            var patientID = $("#hdPatientID").val();

            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/GetPatient",
                data: JSON.stringify({
                    "PatientID": patientID,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
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

        function Print() {
            var sampleID = $("#hdSample_ID").val();
            window.open('../../ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + sampleID);
        }
        function PrintBarcode() {
            var sampleID = $("#hdSample_ID").val();
            window.open('../../ReportViewer.aspx?ReportName=LabBarcode&ReportTitle=Lab Barcode Report&Sample_ID=' + sampleID);

        }
        function PrintQrCode() {
            var sampleID = $("#hdSample_ID").val();
            window.open('../../ReportViewer.aspx?ReportName=LabQrCode&ReportTitle=Lab QrCode Report&Sample_ID=' + sampleID);

        }
            function PrintOrder() {
        var sampleID = $("#hdSample_ID").val();
        window.open('../../ReportViewer.aspx?ReportName=LabBarcodeSlip&ReportTitle=Department Of Pathology&Sample_ID=' + sampleID);
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

            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0")//no duplicate
            {
                document.getElementById("hdnDuplicateCheck").value = "1";
                var cbEmployee = document.getElementById("Emp_Name");
                var employeeID = cbEmployee.options[cbEmployee.selectedIndex].value;
                var collectedDate = $("#txtSampleCollected_Date").val();
                var Remarks = $("#txtRemarks").val();
                var sampleStatus = $("#ddlSample_Status   option:selected").val();
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
                        if ($('#btSnave').val() == 'Save & Print') {
                            $.ajax({
                                type: "POST",
                                url: "SampleCollectionFrom.aspx/SaveTest",
                                data: JSON.stringify({
                                    "CollectedDate": collectedDate,
                                    "Remarks": Remarks,
                                    "sampleStatus": sampleStatus,
                                    "PatientID": mrNo,
                                    "SaveCheckedTest": saveCheckedTest,
                                    "EmployeeID": employeeID,
                                    "rem": rem,
                                    "ddlPat_type": ddlPat_type


                                }),
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",

                                success: function (response) {
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

                                        TestDetail(id)

                                        //window.open('../../ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + id);
                                        var user_name = '<% =AppConfig.Company_Name %>';
                                        // 'id' is the newly generated Sample ID returned by SaveTest
                                        var sampleID = id;

                                        // Also store it in hidden field for future use
                                        $("#hdSample_ID").val(sampleID);

                                        if (user_name == 'Central Park Teaching Hospital') {
                                            
                                            window.open('../../ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + id);
                                            window.open('../../ReportViewer.aspx?ReportName=LabBarcode&ReportTitle=Lab Barcode Report&Sample_ID=' + sampleID);
                                        }
                                        else {
                                        window.open('../../ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + id);
                                        }

                                        window.location = "SampleCollectionFrom.aspx?sampleID=" + id;
                                    }
                                    else {
                                        alert(response.d);
                                    }
                                },
                                failure: function (response) {
                                    alert("In failure method");
                                }
                            });
                        }
                        if ($('#btSnave').val() == 'Update') {
                            var sampleID = $("#hdSample_ID").val();
                            $.ajax({
                                type: "POST",
                                url: "SampleCollectionFrom.aspx/UpdateTest",
                                data: JSON.stringify({
                                    "CollectedDate": collectedDate,
                                    "sampleStatus": sampleStatus,
                                    "Remarks": Remarks,

                                    "SaveCheckedTest": saveCheckedTest,
                                    "EmployeeID": employeeID,
                                    "SampleID": sampleID,
                                    "rem": rem,
                                    "ddlPat_type": ddlPat_type
                                }),
                                contentType: "application/json; charset=utf-8",
                                dataType: "json",

                                success: function (response) {
                                    if (response.d == "Update") {
                                        TestDetail(sampleID);
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

                                        window.location = "SampleCollectionFrom.aspx?sampleID=" + SampleId;

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
            else {
                alert("Processing Please Wait");
                returnVal = false;
            }
        }
        function TestDetail(id) {
            var SelectedDepartment = "001";
            PageMethods.AllPendingLabTestDetail(SelectedDepartment, id, function (data) {
                var parsedData = JSON.parse(data);
                var rows = '';
                $.each(parsedData, function (key, value) {
                    if (value.DoctorName == null || value.DoctorName == "0")
                        value.DoctorName = "";
                    if (value.Rotation == null)
                        value.Rotation = "";
                    if (value.Rotation == 0)
                        value.Rotation = "";
                    if (value.L_R_Rotation_ID == 0)
                        value.L_R_Rotation_ID = "";
                    if (value.L_R_Rotation_ID == null)
                        value.L_R_Rotation_ID = "";
                    var retdate = moment(value.Created_Time).format('LLLL');
                    if (value.Lab_Test_Detail_ID == null) {
                        value.Recieved_ID == "0";
                        value.Lab_Test_Detail_ID = "0";
                    }
                    if (value.chkPackages == null)
                        value.chkPackages = "0";

                    var mydate = new Date(Date.parse(value.Date));
                    var retdate = mydate.toLocaleDateString();

                    if (value.Test_ID != 0) {
                        if (value.Recieved_ID != 0) {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="Sample_Date" value="' + value.Sample_Date + '"/><input type="hidden" name="outSource" value="' + value.Outsource + '"/><input type="hidden" name="Sample_User" value="' + value.Sample_User + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td>' + value.Sample_No + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden"  id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';

                        }
                        else {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="outSource" value="' + value.Outsource + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td>' + value.Sample_No + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden"" id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="0"/>' + value.Test_Name + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                        }
                    }
                    else {
                        if (value.Recieved_ID != 0) {
                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="outSource" value="' + value.Outsource + '"/><input type="hidden" name="OPD" value="' + value.Parent_Transaction_Type_ID + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td>' + value.Sample_No + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID" value="' + value.Patient_ID + '"/><input type="hidden"  id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this) style="color:red">Select</a> </td> </tr>';
                        }
                        else {

                            rows += '<tr id="row' + key + '"><td><input type="hidden" name="chkPackages" value="' + value.chkPackages + '"/><input type="hidden" name="OPD" value="' + value.Out_Patient_ID + '"/><input type="hidden" name="Bill_Details_ID" value="' + value.Bill_Details_ID + '"/><input type="hidden" name="RecievedID" value="' + value.Recieved_ID + '"/><input type="hidden" name="outSource" value="' + value.Outsource + '"/><input type="hidden" name="Paymentcheck" value="' + value.IsBilled + '"/><input type="hidden" name="Detail" value="' + value.Lab_Test_Detail_ID + '"/><input type="hidden" name="LabTestID" value="' + value.Lab_Test_ID + '"/>' + retdate + '</td>' + ' <td>' + value.Sample_No + '</td>' + ' <td><input type="hidden" name="txtAreaofInterest" value="' + value.Area_Of_Interest + '"/><input type="hidden" name="Patient_ID"  value="' + value.Patient_ID + '"/><input type="hidden"  id="txtMRNO' + key + '" value="' + value.Patient_No + '"/>' + value.Patient_No + '</td> ' + '<td>' + value.Name + '</td> ' + '<td style="display:none">' + value.Test_ID + '</td>' + '<td><input type="hidden" id="txtID" value="' + value.Test_ID + '"/><input type="hidden" name="testCatID" value="' + value.Catagory_ID + '"/>' + value.GroupName + '</input></td> ' + '<td>' + value.Remarks + '</td> ' + '<td>' + value.Transaction_Type + '</td>' + '<td> <a href="#" onclick=select3(this)>Select</a> </td> </tr>';
                        }
                    }
                });
                $('#tblPendingPatients tbody').html(rows);
                $('#tblPendingPatients tbody tr').each(function (key, value) {
                    select3(value, id);

                });
                $("#tblPendingPatients").find('tr th:nth-child(7)').hide();
                $("#tblPendingPatients").find('tr th:nth-child(8)').hide();
            }, function (exec) { alert(exec.getmessage()); })


        }

        function select3(value, id) {

            var row = value;
            var RecievedID = $($(row).find('td input[name=RecievedID]')[0]).val();
            var Patient_ID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            var Bill_Details_ID = $($(row).find('td input[name=Bill_Details_ID]')[0]).val();

            var TransactionType = $($(row).find('td')[6]).text();
            var trnsid = $($(row).find('td input[name=OPD]')[0]).val();
            if (RecievedID != "0") {
                PageMethods.checkRepeat(RecievedID, function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        window.location = "LaboratoryTest.aspx?ID=" + value.Lab_Test_ID;
                        $('#ctl00_MainContent_saveLabTest').val("Update");
                    });
                }, function (error) { })
            }
            var SelectedDepartment = "001";
            var OPD = $($(row).find('td')[0]).val();
            var chkPackages = $($(row).find('td input[name=chkPackages]')[0]).val();
            var Patient_ID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            var trnsid = $($(row).find('td input[name=OPD]')[0]).val();
            var Paymentcheck = $($(row).find('td input[name=Paymentcheck]')[0]).val();
            var Sample_Date = $($(row).find('td input[name=Sample_Date]')[0]).val();
            var Sample_User = $($(row).find('td input[name=Sample_User]')[0]).val();
            var outSource = $($(row).find('td input[name=outSource]')[0]).val();

            var LTestid = $($(row).find('td input[name=Detail]')[0]).val();
            var LabTestID = $($(row).find('td input[name=LabTestID]')[0]).val();
            var PatID = $($(row).find('td input[name=Patient_ID]')[0]).val();
            var type = $($(row).find('td')[6]).text();
            var Area = $($(row).find('td input[name=txtAreaofInterest]')[0]).val();
            var testCatID = $($(row).find('td input[name=testCatID]')[0]).val();

            var txtRotation = $($(row).find('td input[name=txtRotation]')[0]).val();
            var txtddlXRayLF_Name = $($(row).find('td input[name=txtddlXRayLF_Name]')[0]).val();
            var testID = $($(row).find('td')[4]).text();
            var name = $($(row).find('td')[5]).text();
            var existingID = $("#hdPatientID").val();

            var userName = '<%= AppConfig.UserName %>';
             var date = '<%= DateTime.Now %>';
             var datetime = '<%= DateTime.Now.Date.ToString(AppConfig.DateFormat) %>';
             if (testCatID != "0" && testID == "0") {
                 var rowid = '';
                 var df = tbltest.rows.length + 1;
                 if (Paymentcheck == 'true') {
                     rowid += '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="' + LTestid + '"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="' + LabTestID + '"/>' + date + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="0"> <input type="hidden" name="txtddlXRayLF_Name" value="0">' + name + '</td><td><input type="hidden" name="txtArea" value=""  /></td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment" ' + (Paymentcheck ? 'checked' : '') + '  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" name="txtCollectionDate" disabled="disabled" style="width:123px  !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:106px   !important;" /></td><td> <input type="text"  id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td><input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" onclick="EnableRemarks(this)" name="Emergancy"  style="width: 92px;height: 17px;"></input></td><td><input  type="text" name="txtRemarks" style="width: 104px !important;"></input></td></tr>';
                     $('#tbltestDetail').append(rowid);
                 }
                 else {
                     rowid += '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="' + LTestid + '"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="' + LabTestID + '"/>' + date + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="0"> <input type="hidden" name="txtddlXRayLF_Name" value="0">' + name + '</td><td><input type="hidden" name="txtArea" value="" /></td><td><input type="checkbox" disabled name="payment" id="Payment' + df + '"  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" disabled="disabled"  name="txtCollectionDate" style="width:123px  !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:106px  !important;" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 104px !important;"></input></td></tr>';
                     $('#tbltest').append(rowid);
                 }
                 $('#txtReadyBy' + df).datetimepicker({ format: 'm-d-y h:i:s A' });
                 $('#txtCollectionDate' + df).datepicker();
                 $('#txtReadyBy' + df).val(date);
                 $('#txtCollectionDate' + df).val(date);
             }
             else {



                 if (Paymentcheck == "true") {
                     var df = tbltest.rows.length + 1;

                     var row = '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="0"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="0"/>' + date + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="' + txtRotation + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + txtddlXRayLF_Name + '">' + name + '</td><td><input type="hidden" name="txtArea" value="' + Area + '" />' + Area + '</td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment" ' + (Paymentcheck ? 'checked' : '') + ' style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" disabled="disabled"  id="txtCollectionDate' + df + '" name="txtCollectionDate" style="width:123px  !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:106px  !important;" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 104px !important;"></input></td></tr>';
                     $('#tbltestDetail').append(row);

                 }
                 else {
                     var df = tbltest.rows.length + 1;

                     var row = '<tr><td><input type="hidden" name="testDate" value="' + trnsid + '"><input type="hidden" name="LabTestDetali" value="' + LTestid + '"><input type="hidden" name="ParrentLabTestDetali" value="0"><input type="hidden" name="Bill_Details_ID" value="' + Bill_Details_ID + '"><input type="hidden" name="GroupCatID" value="' + testCatID + '"/><input type="hidden" name="LabTestID" value="' + LabTestID + '"/><input type="hidden" name="ParentLabTestID" value="0"/>' + date + '</td><td><input type="hidden" name="testID" value="' + testID + '" /><input type="hidden" name="txtRotation" value="' + txtRotation + '"> <input type="hidden" name="txtddlXRayLF_Name" value="' + txtddlXRayLF_Name + '">' + name + '</td><td><input type="hidden" name="txtArea" value="' + Area + '" />' + Area + '</td><td><input type="checkbox" disabled id="Payment' + df + '" name="payment"  style="width: 92px;height: 17px;"/><input name="Type" value="' + type + '" style="display:none"/></td><td> <input type="text"  value="" id="txtCollectionDate' + df + '" disabled="disabled"  name="txtCollectionDate" style="width:123px   !important;" /></td><td>  <input type="text" id="txtReadyBy' + df + '" name="txtReadyBy" style="width:106px  !important;" /></td><td> <input type="text" id="txtCollectionBy" name="txtCollectionBy" style="width:94px !important;"value="' + userName + '"/></td><td> <input type="text"  id="txtPerformedBy" name="txtPerformedBy" style="width:94px !important;" value="' + userName + '"/></td><td><input type="checkbox"  id="Emergancy' + df + '" name="Emergancy" onclick="EnableRemarks(this)"  style="width: 92px;height: 17px;"/></td><td><input type="text" name="txtRemarks"  style="width: 104px !important;display:none"></input></td>></tr>';
                     $('#tbltestDetail').append(row);
                 }

                 $('#txtReadyBy' + df).datetimepicker({ format: 'm-d-y h:i:s A' });
                 $('#txtCollectionDate' + df).datepicker();
                 $('#txtReadyBy' + df).val(date);
                 $('#txtCollectionDate' + df).val(date);
            }
            if (acknowlagment == '01') {
                SavelabTest(id);
            }
             
         }
        function SavelabTest(id) {
            var btnSave = "Save";
            var table = $('#tbltest');
            var test_list = [];
            var transType = $("input[name='Type']").val();
            var transID = $("input[name='testDate']").val();
            var Bill_Details_ID = $("input[name='Bill_Details_ID']").val();
            if (transID == "null") {
                transID = 0;
            }
            var LabTestID = 0;

            table.find('tr').each(function (key, value) {
                test_list.push({ 'TestID': $(value).find('td input[name=testID]').val(), 'TestDID': $(value).find('td input[name=LabTestDetali]').val(), 'ParrentLabTestDetali': $(value).find('td input[name=ParrentLabTestDetali]').val(), 'ParentLabTestID': $(value).find('td input[name=ParentLabTestID]').val(), 'Bill_Details_ID': $(value).find('td input[name=Bill_Details_ID]').val(), 'GroupCatID': $(value).find('td input[name=GroupCatID]').val(), 'Area': $(value).find('td input[name=txtArea]').val(), 'Payment': $(value).find('td input[name=payment]')[0].checked, 'RotationID': $(value).find('td input[name=txtRotation]').val(), 'L_R_Rotation_ID': $(value).find('td input[name=txtddlXRayLF_Name]').val(), 'TestCollectedOn': $(value).find('td input[name=txtCollectionDate]').val(), 'TestReadyOn': $(value).find('td input[name=txtReadyBy]').val(), 'TestCollectedBy': $(value).find('td input[name=txtCollectionBy]').val(), 'TestPerformedBy': $(value).find('td input[name=txtPerformedBy]').val(), 'Emergancy': $(value).find('td input[name=Emergancy]')[0].checked, 'Remarks': $(value).find('td input[name=txtRemarks]').val() });
            });
            var patientID = $("#hdPatientID").val();
            var labTest = { 'PatientID': patientID, 'TestList': test_list };
            PageMethods.SaveLabTestList(LabTestID, btnSave, transType, transID, JSON.stringify(labTest), function (res) {
                window.location = "SampleCollectionFrom.aspx?sampleID=" + id;
            });
        }
        function ListView() {
            window.open("TransactionView.aspx?Tag=SampleView");
        }

        function toggleAll(source) {
            var checkboxes = $('#tblDetailModelTable tbody input[data-role="test-select"]');
            checkboxes.each(function () {
                this.checked = source.checked;
                checkBoxClicked(this);
            });
        }

        function saveRemarks(button) {
            var $row = $(button).closest('tr');
            var remarksInput = $row.find('.remarks-input-modal');
            var remarks = remarksInput.val();
            var billDetailId = $row.find('.bill-detail-id').text();

            if (!remarks || remarks.trim() === "") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'Please enter remarks before saving.',
                    showConfirmButton: false,
                    timer: 2000
                });
                return;
            }

            $.ajax({
                type: "POST",
                url: "SampleCollectionFrom.aspx/SaveModalRemarks",
                data: JSON.stringify({
                    "BillDetailsID": billDetailId,
                    "Remarks": remarks
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "Success") {
                        $(button).removeClass('btn-success').addClass('btn-secondary');
                        $(button).text('Saved');
                        $(button).prop('disabled', true);
                        remarksInput.prop('disabled', true);

                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Remarks saved successfully.',
                            showConfirmButton: false,
                            timer: 1500
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: response.d,
                            showConfirmButton: false,
                            timer: 2000
                        });
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to save remarks.',
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
            });
        }

        // ── Meta Bar sync (visual only — does not change any save/load logic) ──
        function syncSampleMeta() {
            var code = $('#txtSample_No').val();
            if (code) {
                $('#sampleNoDisplay').text(code);
            }
            var branch = $('#ddlUserBranch option:selected').text();
            if (branch && branch !== 'Loading...') {
                $('#branchDisplay').text(branch);
            }
        }
        $(document).ready(function () {
            var originalVal = $.fn.val;
            $.fn.val = function (value) {
                var res = originalVal.apply(this, arguments);
                if (this.attr('id') === 'txtSample_No' && arguments.length >= 1) {
                    syncSampleMeta();
                }
                return res;
            };
            syncSampleMeta();
            $(document).on('change', '#ddlUserBranch', function () {
                syncSampleMeta();
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="sc-page">
    <form id="item">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="sc-badge"><span class="sc-badge-label">Sample No</span><span class="sc-badge-value" id="sampleNoDisplay">---</span></div>
                <div class="sc-badge"><span class="sc-badge-label">Branch</span><span class="sc-badge-value" id="branchDisplay">---</span></div>
            </div>
        </div>

        <div class="sc-layout2">
            <section class="sc-card">
                <h5 class="sc-card-title"><i class="fa fa-user-circle"></i> Patient Information</h5>
                <div class="sc-patient">
                    <div class="sc-avatar">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/Lab2.png" alt="Patient Image" />
                    </div>
                    <div class="sc-grid sc-patient-fields">
                        <div class="sc-field">
                            <label for="txtBillNo">Bill No</label>
                            <input type="text" id="txtBillNo" class="form-control" />
                        </div>
                        <div class="sc-field">
                            <label for="txtMR_No">MR No</label>
                            <input type="text" id="txtMR_No" class="form-control" />
                        </div>
                    </div>
                </div>
                <dl class="sc-info">
                    <div class="sc-span-2"><dt>Name</dt><dd id="vlblPatients_Name"></dd></div>
                    <div><dt>Contact No</dt><dd id="vLbl_Contact"></dd></div>
                    <div><dt>Gender</dt><dd id="vLbl_Gender"></dd></div>
                    <div><dt>Age Years</dt><dd id="vLbl_Age"></dd></div>
                    <div><dt>Reg. Date</dt><dd id="vLbl_RegDate"></dd></div>
                    <div><dt>Specimen</dt><dd id="vLbl_Specimen"></dd></div>
                    <div class="sc-span-all"><dt>Address</dt><dd id="vLbl_Adress"></dd></div>
                </dl>
            </section>

            <section class="sc-card">
                <h5 class="sc-card-title"><i class="fa fa-flask"></i> Sample Details</h5>
                <div class="sc-grid">
                    <div class="sc-field">
                        <label>Sample ID</label>
                        <input type="text" id="txtSample_ID" class="sc-input" readonly="readonly" />
                    </div>
                    <div class="sc-field">
                        <label for="txtSample_No">Sample No</label>
                        <input type="text" id="txtSample_No" class="sc-input" readonly="readonly" />
                    </div>
                    <div class="sc-field">
                        <label id="sampleCode">Sample Code</label>
                        <input type="text" disabled="disabled" id="txtSampleCode" class="sc-input" />
                    </div>
                    <div class="sc-field">
                        <label id="lblSample_Date">Collected Date*</label>
                        <input type="text" readonly="readonly" id="txtSampleCollected_Date" class="sc-input" />
                    </div>
                    <div class="sc-field">
                        <label>Patient Type<span class="sc-req">*</span></label>
                        <select id="ddlPat_type" class="sc-input"></select>
                    </div>
                    <div class="sc-field">
                        <label>Sample Status</label>
                        <select id="ddlSample_Status" class="sc-input"></select>
                    </div>
                    <div class="sc-field">
                        <label for="ddlUserBranch">Branch</label>
                        <select id="ddlUserBranch" class="sc-input">
                            <option value="">Loading...</option>
                        </select>
                    </div>
                    <div class="sc-field">
                        <label id="lblremarks">Remarks</label>
                        <input type="text" id="txtRemarks" class="sc-input" />
                    </div>
                </div>
            </section>
        </div>
    </form>

    <input type="hidden" id="hdSample_ID" />
    <input type="hidden" id="hdPatientID" />
    <input type="hidden" id="hdBillID" />
    <label id="lblEmp_Name" style="margin-left: 20px;display:none">Employee Name*</label>
    <select id="Emp_Name" style="height: 33px; margin-top: 11px; display:none">
        <option></option>
    </select>

    <section class="sc-card">
        <h5 class="sc-card-title"><i class="fa fa-list-alt"></i> Tests
            <input type="button" id="btnDetail" class="btn btn-primry sc-title-btn" value="Select Test" />
        </h5>
        <div id="r1">
        </div>
        <div class="sc-table-wrap">
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
                        <th style="text-align: center; padding-left: 0px; padding-right: 0px;">Urgent</th>
                        <th style="text-align: center; padding-left: 0px; padding-right: 0px; width: 210px !important">Remarks</th>
                        <th style="text-align: center; padding-left: 0px; padding-right: 0px;">Out Source</th>
                        <th style="text-align: center;">Action</th>
                    </tr>
                </thead>
                <tbody></tbody>
            </table>
        </div>
    </section>

    <div class="sc-actions">
        <div>
            <input id="btSnave" class="btn btn-primry w-100" type="button" value="Save & Print" onclick="SaveTest()" />
            <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
        </div>
        <div>
            <input id="btnList" class="btn-gray w-100" type="button" value="View" onclick="ListView()" />
        </div>
        <div>
            <input id="btnNew" class="btn btn-yellow w-100" type="button" value="New" onclick="NewEntry()" />
        </div>
        <div>
            <input id="btnPrintBarcode" class="btn btn-primry w-100" type="button" value="Barcode" onclick="PrintBarcode()" />
        </div>
        <div>
            <input id="btnPrintQrCode" class="btn btn-primry w-100" type="button" value="QR Code" onclick="PrintQrCode()" />
        </div>
        <div>
            <input id="btnPrintOrder" class="btn btn-primry w-100" type="button" value="Print Order" onclick="PrintOrder()" />
        </div>
        <div>
            <input id="btnPrint" class="btn btn-primry w-100" type="button" value="Print" onclick="Print()" />
        </div>
    </div>

    <section class="sc-card sc-list" id="listModel">
        <h5 class="sc-card-title"><i class="fa fa-list"></i> Sample Calling List</h5>
        <div class="sc-grid sc-search-row">
            <div class="sc-field">
                <label for="txtMRNOSearch">Search From Bill No</label>
                <input id="txtMRNOSearch" type="text" class="sc-input" />
            </div>
        </div>
        <div class="sc-table-wrap">
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
                       <div class="col-md-12" style="display:none">
                   <div style="overflow-y:scroll;height:300px;overflow-x:scroll;width:1294px;">
                       <table id="tbltestDetail" class="table" style="width:1267px;">
                                        <thead>
                                            <tr>
                                                <th >Bill Date</th>
                                                <th >Test Name</th>
                                                <th >Area Of Interest</th>
                                                <th>Payment</th>
                                                <th >Test Collected On</th>
                                                <th >Test Ready On</th>
                                                <th >Test Collected By</th>
                                                <th >Performed By</th>
                                                 <th>Urgent</th>
                                                <th >Remarks</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody id="tbltest"></tbody>
                                    </table>
                   </div>
               </div>
         <table class="table"  id="tblPendingPatients" style="display:none">
                                             <thead>
                                                 <tr>
                                                     <th>Bill Date</th>
                                                     <th>Sample No</th>
                                                     <th>MR No</th>
                                                     <th>Name</th>
                                                     <th>Test Name</th>
                                                     <th>Remarks</th>
                                                     <th>Dpt</th>
                                                     <th>CNIC</th>
                                                       <th>Mobile</th>
                                                     <th>Action</th>
                                                 </tr>
                                             </thead>
                                             <tbody></tbody>
                                         </table>
        </div>
    </section>
    </div>

    <div id="TestItemsModel" class="modal fade sc-modal" tabindex="-1" role="dialog" aria-labelledby="TestItemsModalLabel" aria-hidden="true">
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
                                    <th>Remarks</th>
                                     <th>Save</th>
                                     <th>Urgent</th>
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

</asp:Content>
