<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddNewAdvance.aspx.cs" Inherits="PMS.AddNewAdvance" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/Advance.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<script type="text/javascript">
    $(document).ready(function () {
        $("#txtAdvanceDate").datepicker({ dateFormat: 'mm/dd/yy' });
        $("#txtAdvanceDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
        debugger;
        LoadTokenInputsDefaultMRNo();

        var advID = '<% =Request.QueryString["advID"] %>';
        if (advID != "") {
            LoadPatientDetails(advID);
        }
        var Reg_ID = '<% =Request.QueryString["Reg_ID"] %>';
        var PatientId_QS = '<% =Request.QueryString["Reg_ID"] %>';

        if (PatientId_QS != "") {
            debugger;
            var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientId_QS);
            $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });
        }

    });

    function OnSuccess(data) {
        debugger;
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
        debugger;
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

    function LoadPatientDetails(advID) {
        debugger;
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
        debugger;
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
        debugger;
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
    debugger;
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
        debugger;
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
    debugger;
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
        return;
    }
    if (advanceAmount == "") {
        alert("Advance amount is missing");
        return;
    }
    if (ddlPaymentType == "0" || ddlPaymentType == "") {
        alert("Please select Payment Type");
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
                debugger;
                var Parse = JSON.parse(response.d);
                if (Parse == null) {
                    alert("First create In Patient of : " + $("#txtMRNo").val());
                    return;
                }
                else {
                    debugger;
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
                                alert(response.d);
                            }
                        },
                        failure: function (response) {
                            alert(response.d);
                        }
                    });
                }
            },
            failure: function (response) {
                alert(response.d);
            }
        });
    }
}
    function ApproveAdvance() {
        var advanceid = '<% =Request.QueryString["advID"] %>';
        PageMethods.Approve_Advance(advanceid, function (response) {
            debugger;
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid response from server',
                        showConfirmButton: true
                    });
                }
            } catch (error) {
                console.error("Error parsing response:", error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'An error occurred while processing the request',
                    showConfirmButton: true
                });
            }
        }, function (error) {
            debugger;
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
        var advid = '<% =Request.QueryString["advID"] %>';
        PageMethods.unApproveAdvance(advid, function (response) {
            debugger;
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid response from server',
                        showConfirmButton: true
                    });
                }
            } catch (error) {
                console.error("Error parsing response:", error);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'An error occurred while processing the request',
                    showConfirmButton: true
                });
            }
        }, function (error) {
            debugger;
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
        <div class="row">
            <!-- Left Card -->
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-5 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/AddAdvance.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                                </div>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label for="txtMRNo" class="form-label">MR No *:</label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                                        <input type="text" id="txtMRNo" class="form-control" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6">
                                        <label class="form-label">Patient Name :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                                        <label id="lblPatienName"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label class="form-label">Contact No :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                                        <label id="lblContactNo"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label class="form-label">Reg. Date :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                                        <label id="lblRegDate"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                        <label class="form-label">Gender :</label>
                                    </div>
                                    <div class="col-lg-7 col-md-5 col-sm-6 top">
                                        <label id="lblGender"></label>
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
                                <label class="form-label">Age Years :</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <label id="lblAgeYears"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label class="form-label">Address :</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <label id="lblAddress"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label class="form-label">Patient Category :</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <label id="lblPatientCategory"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label class="form-label">Department :</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <label id="lblDepartment"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label class="form-label">InPatient Admit Category :</label>
                            </div>
                            <div class="col-lg-7 col-md-5 col-sm-6">
                                <label id="lblPatientDiscountType" style="background-color: silver;"></label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <div class="row">
           <div class="col-md-2 mb-3">
                <label for="ddlPaymentType" class="form-label">Payment Type</label>
                <select id="ddlPaymentType">
                    <option value="0">Select</option>
                    <option value="01">Cash</option>
                    <option value="02">Bank</option>
                </select>
            </div>
            <div class="col-md-2 mb-3">
                <label for="txtAdvanceDate" class="form-label">Advance Date :</label>
                <input type="text" id="txtAdvanceDate" class="form-control" />
            </div>
            <div class="col-md-2 mb-3">
                <label for="txtAdvanceAmount" class="form-label">Advance Amount *:</label>
                <input type="text" id="txtAdvanceAmount" class="form-control" />
            </div>
            <div class="col-md-3 mb-3" style="display: none">
                <label class="form-label">Output:</label>
                <label id="lblOutput" style="background-color: silver;"></label>
                <label id="lblOutputShow" style="margin-left: -214px;"></label>
            </div>
            <div class="col-md-3 mb-3">
                <label for="txtRemarks" class="form-label">Remarks:</label>
                <textarea id="txtRemarks" style="width: 100% !important; height: 35px !important;"
                    class="form-control" cols="" rows="2"></textarea>
            </div>
        </div>

        <div class="row">
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
