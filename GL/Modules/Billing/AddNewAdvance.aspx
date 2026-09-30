<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddNewAdvance.aspx.cs" Inherits="PMS.AddNewAdvance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Advance.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<script type="text/javascript">
    $(document).ready(function () {
        $("#txtAdvanceDate").datepicker({ dateFormat: 'mm/dd/yy' });
        $("#txtAdvanceDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
        LoadTokenInputsDefaultMRNo();

        var advID = '<% =Request.QueryString["advID"] %>';
        if (advID != "") {
            LoadPatientDetails(advID);
        }
        var Reg_ID = '<% =Request.QueryString["Reg_ID"] %>';
        var PatientId_QS = '<% =Request.QueryString["Reg_ID"] %>';

        if (PatientId_QS != "") {
            var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientId_QS);
            $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });
        }

    });

    function OnSuccess(data) {
        if (data.d != '') {
            if (data.d.Patient_Discount_Type == null)
                data.d.Patient_Discount_Type = "";
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
            $('#lblPatientDiscountType').text(ReplaceNullWith_Space(data.d.Patient_Discount_Type));
            $('#lblOutputShow').text(ReplaceNullWith_Space(data.d.Balance));

       var status = data.d.Status ? data.d.Status.trim() : "Created";
        
        var divApprove = $('#divApproveContainer');
        var divUnApprove = $('#divUnApproveContainer');
        var divVoucher = $('#divVoucherContainer');

        divApprove.hide();
        divUnApprove.hide();
        divVoucher.hide();

        if (status === "Created") {
            divApprove.show();
        } 
        else if (status === "Approved") {
            divUnApprove.show();
            divVoucher.show();
        } 
        else if (status === "UnApproved") {
            divApprove.show();
        }
        }
    }

    function PrintAdvance() {
        var reg_id = '<% =Request.QueryString["advID"] %>';
        var locationInfo = window.location;
        var url = "/ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Advane Payment Print &Adv_IDs=" + reg_id;
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];
            url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Advane Payment Print &Adv_IDs=" + reg_id;
        }
        window.open(url, '_blank');
    }
    function PrintAdvanceThermal() {
        var reg_id = '<% =Request.QueryString["advID"] %>';
        var locationInfo = window.location;
        var url = "/ReportViewer.aspx?ReportName=PrintAdvanceThermalReport&Title=Advane Payment Thermal Print &Adv_IDs=" + reg_id;
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];
            url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintAdvanceThermalReport&Title=Advane Payment Thermal Print &Adv_IDs=" + reg_id;
        }
        window.open(url, '_blank');
    }

    function LoadPatientDetails(advID) {
        var AdvanceId = advID;
        $.ajax({
            type: "POST",
            url: "AddNewAdvance.aspx/GetPatientAndAdvanceDetail",
            data: "{'AdvanceId':" + AdvanceId + "}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: OnSuccesss,
            failure: function (response) {
                alert(response.d);
            }
        });
    }

    function LoadTokenInputsDefaultMRNo() {
        $("#txtMRNo").tokenInput("../../json.aspx?Table=Patients",
            {
                tokenLimit: 1,
                onAdd: function (item) {
                    try {
                        $("#hdPatientID").val(item.id);
                        $("#txtMRNo").val(item.name);
                        GetPatientDetail();
                    } catch (err) {
                        alert(err.message);
                    }
                }
            });
    }

    function GetPatientDetail() {
        var Patient_ID = $('#hdPatientID').val();
        $.ajax({
            type: "POST",
            url: "AddNewAdvance.aspx/LoadPatientDetails",
            data: "{'PatientID':" + Patient_ID + "}",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: OnSuccess,
            failure: function (response) {
                alert(response.d);
            }
        });
    }

    function httpGet(theUrl) {
        var xmlHttp = null;
        xmlHttp = new XMLHttpRequest();
        xmlHttp.open("GET", theUrl, false);
        xmlHttp.send(null);
        return xmlHttp.responseText;
    }

   function OnSuccesss(data) {
    var parseData = JSON.parse(data.d);
    if (data.d != '') {
        if (data.d.Patient_Discount_Type == null)
            data.d.Patient_Discount_Type = "";
        var mydate = new Date(Date.parse(parseData.Created_time));
        var dateR = mydate.toLocaleDateString();
        $('#lblPatienName').text(ReplaceNullWith_Space(parseData.Full_Name));
        $('#lblAgeYears').text(ReplaceNullWith_Space(parseData.Age_years));
        $('#lblGender').text(ReplaceNullWith_Space(parseData.Gender));
        $('#lblRegDate').text(dateR);
        $('#lblAddress').text(ReplaceNullWith_Space(parseData.Permanent_Address));
        $('#lblContactNo').text(ReplaceNullWith_Space(parseData.Mobile1));
        $('#lblDepartment').text(ReplaceNullWith_Space(parseData.department));
        $('#lblPatientCategory').text(ReplaceNullWith_Space(parseData.Patient_Main_Category));
        $('#lblPatientDiscountType').text(ReplaceNullWith_Space(parseData.Patient_Discount_Type));
        $('#txtRemarks').val(ReplaceNullWith_Space(parseData.Remarks));
        $('#txtAdvanceAmount').val(ReplaceNullWith_Space(parseData.Advance_Amount));
        var date = $.datepicker.formatDate('mm-dd-yy', new Date(parseInt(parseData.Advance_Date.substring(6, 19))));
        $('#txtAdvanceDate').val(ReplaceNullWith_Space(date));
        var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + parseData.pat_id);
        $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });
        $('#btnSave').val('Update');
        $('#lblOutputShow').text(ReplaceNullWith_Space(Balance));

        
        

        if (parseData.Payment_type) {
            $('#ddlPaymentType').val(parseData.Payment_type);
        } else {
            $('#ddlPaymentType').val("0");
        }

        
    }
}

    function ReplaceNullWith_Space(Data) {
        if (Data == "null")
            return " ";
        else
            return Data;
    }

    function PrintVoucher() {
        var advID = '<%= Request.QueryString["advID"] %>' || '0';
        advID = advID.trim() === "" ? "0" : advID;
        var locationInfo = window.location;
        var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Voucher&TransID=' + advID + '&TransType=ADVANCE';
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];
            url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Advance Voucher&TransID=' + advID + '&TransType=ADVANCE';
        }
        window.open(url, '_blank');
    }

    function SaveRecord() {
    $('#btnSave').attr('disabled', true);
    var Patient_ID = $('#hdPatientID').val();
    var advanceAmount = $("#txtAdvanceAmount").val();
    var ddlPaymentType = $("#ddlPaymentType").val();  // Now matches the HTML ID
    var remarks = $("#txtRemarks").val();
    var advanceDate = $("#txtAdvanceDate").val();
    var saveVal = $('#btnSave').val();
    var advID = '<% =Request.QueryString["advID"] %>';
    if (advID == "") advID = "0";
    
    if (Patient_ID == "") {
        alert("Mr No. is missing");
        $('#btnSave').attr('disabled', false);
        return;
    }
    if (advanceAmount == "") {
        alert("Advance amount is missing");
        $('#btnSave').attr('disabled', false);
        return;
    }
    if (ddlPaymentType == "0" || ddlPaymentType == "") {
        alert("Please select Payment Type");
        $('#btnSave').attr('disabled', false);
        return;
    }
    else {
        $.ajax({
            type: "POST",
            url: "AddNewAdvance.aspx/CheckExistInPatient",
            data: JSON.stringify({
                "PatientID": Patient_ID,
            }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var Parse = JSON.parse(response.d);
                if (Parse == null) {
                    alert("First create In Patient of : " + $("#txtMRNo").val());
                    $('#btnSave').attr('disabled', false);
                    return;
                }
                else {
                    $.ajax({
                        type: "POST",
                        url: "AddNewAdvance.aspx/SaveAdvance",
                        data: JSON.stringify({
                            "PatientID": parseInt(Patient_ID),  // Convert to int
                            "AdvanceAmount": parseInt(advanceAmount),  // Convert to int
                            "ddlPaymentType": ddlPaymentType,
                            "AdvanceDate": advanceDate,
                            "Remarks": remarks,
                            "InPatientID": Parse.In_Patient_ID,
                            "SaveVal": saveVal,
                            "AdvID": parseInt(advID)  // Convert to int
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var advID = response.d;
                    
                            if (saveVal == "Save") {
                                alert("Data Save Successfully");
                                $("#txtMRNo").tokenInput('clear');
                                $("#txtAdvanceAmount").val("");
                                $("#txtRemarks").val("");
                                $("#ddlPaymentType").val("0");  // Reset dropdown
                                var url = "../../ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Advane Payment Print &Adv_IDs=" + advID;
                                window.open(url, '_blank');
                                window.location = "AddNewAdvance.aspx";
                            }
                            else if (saveVal == "Update") {
                                alert("Data Updated Successfully");
                                $("#txtMRNo").tokenInput('clear');
                                $("#txtAdvanceAmount").val("");
                                $("#txtRemarks").val("");
                                $("#ddlPaymentType").val("0");  // Reset dropdown
                                var url = "../../ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Advane Payment Print &Adv_IDs=" + advID;
                                window.open(url, '_blank');
                                window.location = "AddNewAdvance.aspx";
                            }
                            else {
                                $('#btnSave').attr('disabled', false);
                                alert(response.d);
                            }
                        },
                        failure: function (response) {
                            alert(response.d);
                        },
                        error: function () {
                            $('#btnSave').attr('disabled', false);
                        }
                    });
                }
            },
            failure: function (response) {
                alert(response.d);
            },
            error: function () {
                $('#btnSave').attr('disabled', false);
            }
        });
    }
}
    function ApproveAdvance() {
        $('#btnApprove').attr('disabled', true);
        var advanceid = '<% =Request.QueryString["advID"] %>';
        PageMethods.Approve_Advance(advanceid, function (response) {
            try {
                var result = JSON.parse(response);
                if (result && result.Message) {
                    if (result.Success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: result.Message,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        setTimeout(function () {
                            location.reload();
                        }, 2000);
                    } else {
                        $('#btnApprove').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: result.Message,
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                } else {
                    $('#btnApprove').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid response from server',
                        showConfirmButton: true
                    });
                }
            } catch (error) {
                $('#btnApprove').attr('disabled', false);
                console.error("Error parsing response:", error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'An error occurred while processing the request',
                    showConfirmButton: true
                });
            }
        }, function (error) {
            $('#btnApprove').attr('disabled', false);
            console.error("PageMethods error:", error);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: error.get_message ? error.get_message() : 'An error occurred',
                showConfirmButton: true
            });
        });
    }
    
    function UnApprove() {
        $('#btnUnApprove').attr('disabled', true);
        var advid = '<% =Request.QueryString["advID"] %>';
        PageMethods.unApproveAdvance(advid, function (response) {
            try {
                var result = JSON.parse(response);
                if (result && result.Message) {
                    if (result.Success) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: result.Message,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        setTimeout(function () {
                            location.reload();
                        }, 2000);
                    } else {
                        $('#btnUnApprove').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: result.Message,
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                } else {
                    $('#btnUnApprove').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid response from server',
                        showConfirmButton: true
                    });
                }
            } catch (error) {
                $('#btnUnApprove').attr('disabled', false);
                console.error("Error parsing response:", error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'An error occurred while processing the request',
                    showConfirmButton: true
                });
            }
        }, function (error) {
            $('#btnUnApprove').attr('disabled', false);
            console.error("PageMethods error:", error);
            Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: error.get_message ? error.get_message() : 'An error occurred',
                showConfirmButton: true
            });
        });
    }
</script>




    <div id="header" class="container-fluid">
        <input type="hidden" id="hdPatientID" />
        <label id="lblOutput" style="background-color: silver; display: none;"></label>
        <label id="lblOutputShow" style="margin-left: -214px; display: none;"></label>

        <div class="bp-meta-bar">
            <div class="bp-meta-title">
                <i class="fa fa-money"></i>
                <span>Advance Payment</span>
                <span class="bp-badge bp-badge--new" id="advanceStatusBadge">New Advance</span>
            </div>
        </div>

        <div class="bp-bento">
            <div class="bp-card">
                <div class="bp-card-header">
                    <i class="fa fa-user-circle"></i>
                    <span>Patient Information</span>
                </div>
                <div class="bp-card-body">
                    <div class="bp-patient">
                        <div class="bp-patient-avatar">
                            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/AddAdvance.png" alt="Patient" id="patientImage" />
                        </div>
                        <div class="bp-patient-info">
                            <div class="bp-patient-name" id="lblPatienName">Patient Name</div>
                            <dl class="bp-patient-grid">
                                <dt>MR No</dt>
                                <dd><input type="text" id="txtMRNo" /></dd>
                                <dt>Contact</dt><dd id="lblContactNo"></dd>
                                <dt>Gender</dt><dd id="lblGender"></dd>
                                <dt>Reg Date</dt><dd id="lblRegDate"></dd>
                            </dl>
                        </div>
                    </div>
                </div>
            </div>

            <div class="bp-card">
                <div class="bp-card-header">
                    <i class="fa fa-info-circle"></i>
                    <span>Additional Details</span>
                </div>
                <div class="bp-card-body" style="padding:0;">
                    <div class="bp-summary-row">
                        <span class="bp-summary-label">Age</span>
                        <span id="lblAgeYears" class="bp-summary-value bp-summary-value--readonly"></span>
                    </div>
                    <div class="bp-summary-row">
                        <span class="bp-summary-label">Address</span>
                        <span id="lblAddress" style="margin-left:auto;color:var(--bp-text);font-weight:600;text-align:right;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;max-width:65%;"></span>
                    </div>
                    <div class="bp-summary-row">
                        <span class="bp-summary-label">Patient Category</span>
                        <span id="lblPatientCategory" style="margin-left:auto;color:var(--bp-text);font-weight:600;"></span>
                    </div>
                    <div class="bp-summary-row">
                        <span class="bp-summary-label">Department</span>
                        <span id="lblDepartment" style="margin-left:auto;color:var(--bp-text);font-weight:600;"></span>
                    </div>
                    <div class="bp-summary-row">
                        <span class="bp-summary-label">Admit Category</span>
                        <span id="lblPatientDiscountType" style="margin-left:auto;color:var(--bp-text);font-weight:600;"></span>
                    </div>
                </div>
            </div>
        </div>

        <div class="bp-card">
            <div class="bp-card-header">
                <i class="fa fa-credit-card"></i>
                <span>Advance Details</span>
            </div>
            <div class="bp-card-body">
                <div class="bp-bento bp-bento--4" style="gap:12px;">
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Payment Type</label>
                        <select id="ddlPaymentType" class="bp-select">
                            <option value="0">Select</option>
                            <option value="01">Cash</option>
                            <option value="02">Bank</option>
                        </select>
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Advance Date</label>
                        <input type="text" id="txtAdvanceDate" class="bp-input datepicker" />
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Advance Amount *</label>
                        <input type="text" id="txtAdvanceAmount" class="bp-input" style="text-align:right;font-weight:700;color:var(--bp-primary);" />
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Remarks</label>
                        <textarea id="txtRemarks" class="bp-input" style="height:30px;resize:vertical;"></textarea>
                    </div>
                </div>
            </div>
        </div>

        <div class="row mt-3">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="Save" class="btn btn-primry" onclick="SaveRecord()" id="btnSave" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" class="btn-gray" value="View" onclick="window.open('AdvanceList.aspx')" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" class="btn-gray" value="New" onclick="window.open('AddNewAdvance.aspx')" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintAdvance()" value="Print" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3">
                        <input type="button" id="btnPrint1" class="btn btn-primry" onclick="PrintAdvanceThermal()" value="Print2" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3" id="divApproveContainer">
                        <input type="button" id="btnApprove" class="btn btn-primry" onclick="ApproveAdvance()" value="Approve" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3" id="divUnApproveContainer">
                        <input type="button" id="btnUnApprove" class="btn btn-primry" onclick="UnApprove()" value="UnApprove" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3" id="divVoucherContainer">
                        <input type="button" id="btnPrintVoucher" class="btn btn-primry" onclick="PrintVoucher();" value="Voucher" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
