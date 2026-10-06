<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Refund.aspx.cs" Inherits="PMS.Refund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Refund.css" rel="stylesheet" />
     <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />

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
        });
        function PrintRefund() {
            var refundID = '<% =Request.QueryString["advID"] %>';
             var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + refundID;
             if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + refundID;
             }
             window.open(url, '_blank');
         }
        function LoadPatientDetails(advID) {
            var AdvanceId = advID;

            $.ajax({
                type: "POST",
                url: "Refund.aspx/GetPatientAndAdvanceDetail",
                data: "{'AdvanceId':" + AdvanceId + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccesss,
                failure: function (response) {

                    alert(response.d);
                }
            });
            LoadShareDetails(advID);
            RefundDetials(advID)
        }
        function OnSuccesss(data) {
            var parseData = JSON.parse(data.d);
            if (data.d != '') {
                if (data.d.Patient_Discount_Type == null)
                    data.d.Patient_Discount_Type = "";

                var status = parseData.Status ? parseData.Status.trim() : "Created";

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
                var mydate = new Date(Date.parse(parseData.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#hdPatientID').text(ReplaceNullWith_Space(parseData.Patient_ID));
                $('#hdnBillID').val(ReplaceNullWith_Space(parseData.bill_ID));
                $('#lblMRNo').text(ReplaceNullWith_Space(parseData.Patient_No));
                $('#lblPatienName').text(ReplaceNullWith_Space(parseData.Full_Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(parseData.Age_years));
                $('#lblGender').text(ReplaceNullWith_Space(parseData.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(parseData.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(parseData.Mobile1));
                $('#lblDepartment').text(ReplaceNullWith_Space(parseData.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(parseData.Patient_Main_Category));
                $('#lblPatientDiscountType').text(ReplaceNullWith_Space(parseData.Patient_Discount_Type));
                $('#txtRemarks').val(ReplaceNullWith_Space(parseData.Remarks));
                $('#lblOutputShow').text(ReplaceNullWith_Space(Balance));
                var date = $.datepicker.formatDate('mm-dd-yy', new Date(parseInt(parseData.Advance_Date.substring(6, 19))));
                $('#txtAdvanceAmount').val(ReplaceNullWith_Space(parseData.Advance_Amount));
                $('#txtAdvanceDate').val(ReplaceNullWith_Space(date));
                var tokendata = httpGet("json.aspx?Table=PatientsFetchByID&q=" + parseData.Patient_ID);
                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name });


                
            }
        }
        function LoadShareDetails(advID) {
            PageMethods.LoadShareDetails(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                var Description = '';
                $.each(data, function (key, value) {
                    rows = '<tr></td> ' + value.Item_Name + '</td><td>' + value.Item_Name + '</td><td>' + value.Doctor_Share + '</td><td>' + value.Net_Amount + '  </td><td>' + value.Doctor_Refund + '  </td><td>' + value.Hospital_Refund + '  </td><td></td></tr>'
                    $('#tblDetails tbody').append(rows);
                    rowIndex++;
                });
                $('#btnSave').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function RefundDetials(advID) {
            PageMethods.RefundDetials(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#Doctor_Share_Table tbody tr').length)));
                var Description = '';
                $.each(data, function (key, value) {
                    rows = '<tr></td> ' + value.Emp_Name + '</td><td>' + value.Emp_Name + '</td><td>' + value.Share_type + '</td><td>' + value.Amount + '  </td><td>' + value.Refund_Amount + '  </td></tr>'
                    $('#Doctor_Share_Table tbody').append(rows);
                    rowIndex++;
                });
                $('#btnSave').val('Update');
                $('#btnSave').attr('disabled', 'disabled');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function LoadTokenInputsDefaultMRNo() {
            $("#txtMRNo").tokenInput("json.aspx?Table=Patients",
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

        function GetPatientDetailByBill() {
            var Bill_No = $('#txtBillNo').val();

            if (Bill_No == '' || Bill_No == null) {
                Swal.fire({
                    title: "Warning!",
                    text: "Please enter Bill No",
                    icon: "warning",
                    confirmButtonText: "OK"
                });
                return;
            }

            var sampleTakenIds = [];
            $.ajax({
                type: "post",
                url: "Refund.aspx/GetSampleTakenDetailIds",
                data: JSON.stringify({ "Bill_No": Bill_No }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (r) {
                    try { sampleTakenIds = JSON.parse(r.d); } catch (e) { sampleTakenIds = []; }
                },
                error: function () { sampleTakenIds = []; }
            });

            $.ajax({
                type: "post",
                url: "Refund.aspx/LoadPatientDetailsByBillNO",
                data: JSON.stringify({
                    "Bill_No": Bill_No
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);

                    if (parse && parse.length > 0) {
                        if (parse[0].IsCancel == 1 || parse[0].IsCancel == true) {

                            Swal.fire({
                                icon: 'warning',
                                title: 'Cancelled Bill',
                                text: 'This bill is cancelled.',
                                confirmButtonText: 'OK'
                            });

                            $('#tblDetails tbody').empty();
                            $('#Doctor_Share_Table tbody').empty();
                            $('#btnSave').prop('disabled', true);

                            return;
                        }
                        var length = parse.length;
                        var rows = '';
                        var hasRefundableItems = false;
                        var totalAmount = 0;
                        var receivedAmount = 0;

                        $('#hdPatientID').text(parse[0].Patient_ID);
                        $('#hdnBillID').val(parse[0].bill_ID);
                        $('#lblMRNo').text(parse[0].Patient_No);
                        $('#lblPatienName').text(parse[0].Full_Name);
                        $('#lblAgeYears').text(parse[0].Age_years);
                        $('#lblGender').text(parse[0].Gender);
                        $('#lblRegDate').text(parse[0].Creation_Date);
                        $('#lblAddress').text(parse[0].Permanent_Address);
                        $('#lblContactNo').text(parse[0].Mobile1);
                        $('#lblDepartment').text(parse[0].Department);
                        $('#lblPatientCategory').text(parse[0].Patient_Type);
                        totalAmount = parse[0].Total_Amount;
                        receivedAmount = parse[0].Received_Amount;
                        $('#txtToT_amount').val(totalAmount);
                        $('#txt_RcvdAmount').val(receivedAmount);

                        var rowIndex = 0;
                        var sampleSkipped = 0;
                        for (var i = 0; i < length; i++) {
                            if ($.inArray(parse[i].Bill_Details_ID, sampleTakenIds) !== -1) {
                                sampleSkipped++;
                                continue;
                            }
                            if (parse[i].Is_Refunded == true || parse[i].Is_Refunded == 1) {
                                continue;
                            }

                            hasRefundableItems = true;

                            rows += '<tr>' +
                                '<td style="display:none">' + parse[i].Patient_ID + '</td>' +
                                '<td style="display:none">' + parse[i].Bill_Details_ID + '</td>' +
                                '<td style="display:none">' + parse[i].Item_Id + '</td>' +
                                '<td style="text-align: center;">' + parse[i].Item_Name + '</td>' +
                                '<td style="text-align: center;">' + parse[i].Doctor_Share + '</td>' +
                                '<td style="text-align: center;">' + parse[i].Hospital_Share + '</td>' +
                                '<td><input type="text" id="DocRefund' + rowIndex + '" name="DocRefund" value="0" style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                                '<td><input type="text" name="HosRefund" value="0" style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                                '<td style="text-align: center;"><input type="checkbox" name="chkRefund" onchange="autoFillShare(this)" /></td>' +
                                '</tr>';
                            rowIndex++;
                        }

                        if (!hasRefundableItems) {
                            if (sampleSkipped > 0) {
                                Swal.fire({
                                    title: "Sample Taken",
                                    text: "This bill is sample taken. We cannot refund it.",
                                    icon: "warning",
                                    confirmButtonText: "OK"
                                });
                            } else {
                                Swal.fire({
                                    title: "No Items Available",
                                    text: "All items in this bill have already been refunded.",
                                    icon: "warning",
                                    confirmButtonText: "OK"
                                });
                            }
                            $('#tblDetails tbody tr').remove();
                            $('#btnSave').attr('disabled', 'disabled');
                            return;
                        }

                        $('#tblDetails tbody tr').remove();
                        $('#tblDetails tbody').append(rows);
                        $('#btnSave').removeAttr('disabled');

                        if (sampleSkipped > 0) {
                            Swal.fire({
                                icon: 'info',
                                title: 'Sample Taken',
                                text: sampleSkipped + ' item(s) not shown because sample already taken.',
                                showConfirmButton: false,
                                timer: 3000
                            });
                        }
                    } else {
                        Swal.fire({
                            title: "Not Found",
                            text: "No bill found with this Bill No",
                            icon: "error",
                            confirmButtonText: "OK"
                        });
                    }
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        title: "Error",
                        text: "Error loading bill details: " + error,
                        icon: "error",
                        confirmButtonText: "OK"
                    });
                }
            });

            $.ajax({
                type: "post",
                url: "Refund.aspx/LoadDoctorShare",
                data: JSON.stringify({
                    "Bill_No": Bill_No
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var length = parse.length;
                    var rows = '';
                    for (var i = 0; i < length; i++) {
                        rows += '<tr>' +
                            '<td style="display:none">' + parse[i].Patient_ID + '</td>' +
                            '<td style="display:none">' + parse[i].Emp_ID + '</td>' +
                            '<td style="display:none">' + parse[i].Record_ID + '</td>' +
                            '<td style="text-align: center;">' + parse[i].Emp_Name + '</td>' +
                            '<td style="text-align: center;">' + parse[i].Share_Type_Name + '</td>' +
                            '<td style="text-align: center;">' + parse[i].Amount + '</td>' +
                            '<td><input type="text" id="RefundDis' + i + '" name="RefundDis" value="0" style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                            '</tr>';
                    }
                    $('#Doctor_Share_Table tbody tr').remove();
                    $('#Doctor_Share_Table tbody').append(rows);
                }
            });
        }
        function autoFillShare(chk) {
            var row = $(chk).closest('tr');
            var doctorShare = parseFloat(row.find('td:eq(4)').text()) || 0;
            var hospitalShare = parseFloat(row.find('td:eq(5)').text()) || 0;
            if ($(chk).is(':checked')) {
                row.find('input[name="DocRefund"]').val(doctorShare);
                row.find('input[name="HosRefund"]').val(hospitalShare);
            } else {
                row.find('input[name="DocRefund"]').val(0);
                row.find('input[name="HosRefund"]').val(0);
            }
            calculateDoctorShare();
        }
        function calculateDoctorShare() {
            var list = document.getElementById('tblDetails');
            var doctorsList = document.getElementById('Doctor_Share_Table');
            var totalDoctorRefund = 0;
            var totalHospitalRefund = 0;
            var totalDoctorDistribution = 0;
            for (var i = 0; i < list.rows.length - 1; i++) {

                var docRefund = $('#DocRefund' + i).val();
                var hosRefund = $(list.rows[i + 1]).find('input[name="HosRefund"]').val();

                if (docRefund == '' || isNaN(docRefund))
                    docRefund = 0;

                if (hosRefund == '' || isNaN(hosRefund))
                    hosRefund = 0;

                totalDoctorRefund += parseFloat(docRefund);
                totalHospitalRefund += parseFloat(hosRefund);
            }
            for (var i = 0; i < doctorsList.rows.length - 1; i++) {

                var data = $('#RefundDis' + i).val();

                if (data == '' || isNaN(data))
                    data = 0;

                totalDoctorDistribution += parseFloat(data);
            }
            var combinedTotal = totalDoctorRefund + totalHospitalRefund;
            $('#txtTotalDoctorShare').val(combinedTotal);
            $('#txtDoctorTotalDistribution').val(totalDoctorDistribution);
        }


        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }


        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }

        function CheckBillTestApproved(Bill_ID, callback) {

            $.ajax({
                type: "POST",
                url: "Refund.aspx/CheckBillTestApproved",
                data: JSON.stringify({ Bill_ID: Bill_ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (response) {

                    if (response.d == true) {

                        //alert("One of the test from this Bill is Approved so You can not refund this bill.");
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: "One of the Test from This Bill is Approved You Can't Refund this Bill.",
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        callback(false);
                    }
                    else {

                        callback(true);
                    }
                },

                error: function (xhr, status, error) {

                    alert("Error : " + error);
                    callback(false);
                }
            });
        }
        function SaveRecord() {
            $('#btnSave').attr('disabled', true);
            if (validateSave()) {


                var Patient_ID = $("#hdPatientID").text();
                var Bill_ID = $("#hdnBillID").val();

              //  CheckBillTestApproved(Bill_ID, function (canSave) {

                    // Stop saving if approved test exists
                    // if (!canSave) {
                    //     return;
                    // }
                    var remarks = $("#txtRemarks").val();
                    var advanceDate = $("#txtAdvanceDate").val();
                    var saveVal = $('#btnSave').val();

                    var ServiceRefund = [];

                    $.each($('#tblDetails tbody tr'), function (key, value) {

                        var Bill_Detial_ID = document.getElementById('tblDetails').rows[key + 1].cells[1].innerText;
                        var Doctor_Refund = $(value).find('input[name="DocRefund"]').val();
                        var Hos_Refund = $(value).find('input[name="HosRefund"]').val();
                        var Item_ID = document.getElementById('tblDetails').rows[key + 1].cells[2].innerText;

                        ServiceRefund.push({
                            Bill_Detial_ID: Bill_Detial_ID,
                            Doctor_Refund: Doctor_Refund,
                            Item_ID: Item_ID,
                            Hos_Refund: Hos_Refund
                        });
                    });

                    var ShareRefund = [];

                    $.each($('#Doctor_Share_Table tbody tr'), function (key, value) {

                        var Emp_ID = document.getElementById('Doctor_Share_Table').rows[key + 1].cells[1].innerText;
                        var Record_Id = document.getElementById('Doctor_Share_Table').rows[key + 1].cells[2].innerText;
                        var Refund_Amount = $(value).find('input[name="RefundDis"]').val();

                        ShareRefund.push({
                            Emp_ID: Emp_ID,
                            Record_Id: Record_Id,
                            Refund_Amount: Refund_Amount
                        });
                    });

                    var data = {
                        Patient_ID: Patient_ID,
                        advanceDate: advanceDate,
                        remarks: remarks,
                        ServiceRefund: ServiceRefund,
                        ShareRefund: ShareRefund
                    };

                    PageMethods.SaveRefund(JSON.stringify(data), function (res) {

                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Successfully Save',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location.reload();
                        $('#btnSave').attr('disabled', 'disabled');

                    }, function (error) {
                        $('#btnSave').attr('disabled', false);
                        alert(error.get_message());
                    });

                //});
            }
            else {
                $('#btnSave').attr('disabled', false);
            }
        }

<%--        function SaveRecord() {
            if (validateSave()) {
                var Patient_ID = $("#hdPatientID").text();
                var Bill_ID = $("#hdnBillID").val(); 
                CheckBillTestApproved(Bill_ID, function (canSave) {

                    // Stop saving if approved test exists
                    if (!canSave) {
                        return;
                    }
               
                var remarks = $("#txtRemarks").val();
                var advanceDate = $("#txtAdvanceDate").val();
                var saveVal = $('#btnSave').val();
                var advID = '<% =Request.QueryString["advID"] %>';

                var ServiceRefund = [];
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    var Bill_Detial_ID = document.getElementById('tblDetails').rows[key + 1].cells[1].innerText;
                    var Doctor_Refund = $(value).find('input[name="DocRefund"]').val();
                    var Hos_Refund = $(value).find('input[name="HosRefund"]').val();
                    var Item_ID = document.getElementById('tblDetails').rows[key + 1].cells[2].innerText;
                    ServiceRefund.push({
                        Bill_Detial_ID: Bill_Detial_ID, Doctor_Refund: Doctor_Refund, Item_ID: Item_ID, Hos_Refund: Hos_Refund
                    });
                });
                var ShareRefund = [];
                $.each($('#Doctor_Share_Table tbody tr'), function (key, value) {
                    var Emp_ID = document.getElementById('Doctor_Share_Table').rows[key + 1].cells[1].innerText;
                    var Record_Id = document.getElementById('Doctor_Share_Table').rows[key + 1].cells[2].innerText;
                    var Refund_Amount = $(value).find('input[name="RefundDis"]').val();

                    ShareRefund.push({
                        Emp_ID: Emp_ID, Record_Id: Record_Id, Refund_Amount: Refund_Amount
                    });
                });
                var data = { Patient_ID: Patient_ID, advanceDate: advanceDate, remarks: remarks, ServiceRefund: ServiceRefund, ShareRefund: ShareRefund };
                PageMethods.SaveRefund(JSON.stringify(data), function (res) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Successfully Save',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    window.location.reload();
                    $('#btnSave').attr('disabled', 'disabled');
                }, function (error) {
                    alert(error.get_message());
                });
            }
        }--%>

        function validateSave() {
            var proceed = true;
            var hasAnyRefund = false;

            $('#tblDetails tbody tr').each(function (index, row) {
                var doctorShare = parseFloat($(row).find('td:eq(4)').text()) || 0;
                var hospitalShare = parseFloat($(row).find('td:eq(5)').text()) || 0;
                var doctorRefund = parseFloat($(row).find('input[name="DocRefund"]').val()) || 0;
                var hospitalRefund = parseFloat($(row).find('input[name="HosRefund"]').val()) || 0;

                if (doctorRefund > 0 || hospitalRefund > 0) {
                    hasAnyRefund = true;
                }

                if (doctorRefund > doctorShare) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid Doctor Refund!',
                        text: 'Doctor Refund cannot be greater than Doctor Share.',
                        confirmButtonColor: '#d33'
                    });
                    proceed = false;
                    return false;
                }

                if (hospitalRefund > hospitalShare) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid Hospital Refund!',
                        text: 'Hospital Refund cannot be greater than Hospital Share.',
                        confirmButtonColor: '#d33'
                    });
                    proceed = false;
                    return false;
                }
            });

            if (!hasAnyRefund && proceed) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Refund Amount!',
                    text: 'Please enter at least one refund amount before saving.',
                    confirmButtonColor: '#d33'
                });
                proceed = false;
            }

            return proceed;
        }


        function ApproveRefund() {
            $('#btnApprove').attr('disabled', true);
            var refundId = '<% =Request.QueryString["advID"] %>';
            if (!refundId || refundId == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'No refund record found to approve.',
                    showConfirmButton: true
                });
                $('#btnApprove').attr('disabled', false);
                return;
            }

            PageMethods.Approve_Refund(refundId, function (response) {
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

        
        function UnApproveRefund() {
            $('#btnUnApprove').attr('disabled', true);
            var refundId = '<% =Request.QueryString["advID"] %>';
    if (!refundId || refundId == "") {
        Swal.fire({
            icon: 'error',
            title: 'Error!',
            text: 'No refund record found to unapprove.',
            showConfirmButton: true
        });
        $('#btnUnApprove').attr('disabled', false);
        return;
    }

    PageMethods.UnApprove_Refund(refundId, function (response) {
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


function PrintVoucher() {
    var refundID = '<%= Request.QueryString["advID"] %>' || '0';
    refundID = refundID.trim() === "" ? "0" : refundID;
    var locationInfo = window.location;
    var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=Refund Voucher&TransID=' + refundID + '&TransType=REFUND';
    if (!locationInfo.origin.includes('localhost')) {
        var urlInfo = window.location.href.split('/');
        var ip = urlInfo[2];
        var foldername = urlInfo[3];
        url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Refund Voucher&TransID=' + refundID + '&TransType=REFUND';
    }
    window.open(url, '_blank');
}

    </script>

    <div class="container-fluid">
        <input type="hidden" id="hdPatientID" />
        <input type="hidden" id="hdnBillID" />
        <input type="hidden" id="txtAdvanceAmount" />
        <label id="lblOutput" style="background-color: silver; display: none;"></label>
        <label id="lblOutputShow" style="margin-left: -214px; display: none;"></label>

        <div class="bp-meta-bar">
            <div class="bp-meta-title">
                <i class="fa fa-file-text-o"></i>
                <span>Bill Refund</span>
                <span class="bp-badge bp-badge--new" id="refundStatusBadge">New Refund</span>
            </div>
            <div class="bp-meta-actions">
                <button type="button" class="bp-meta-btn bp-meta-btn--search" id="btnSearch" onclick="GetPatientDetailByBill()">
                    <i class="fa fa-search"></i> Search Bill
                </button>
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
                            <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/billing2.png" alt="Patient" id="patientImage" />
                        </div>
                        <div class="bp-patient-info">
                            <div class="bp-patient-name" id="lblPatienName">Patient Name</div>
                            <dl class="bp-patient-grid">
                                <dt>Bill No</dt>
                                <dd><input type="text" id="txtBillNo" class="bp-input" style="height:26px;padding:3px 7px;" /></dd>
                                <dt>Contact</dt><dd id="lblContactNo"></dd>
                                <dt>Gender</dt><dd id="lblGender"></dd>
                                <dt>Reg Date</dt><dd id="lblRegDate"></dd>
                                <dt>MR No</dt><dd id="lblMRNo"></dd>
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
                <i class="fa fa-money"></i>
                <span>Refund Details</span>
            </div>
            <div class="bp-card-body">
                <div class="bp-bento bp-bento--4" style="gap:12px;">
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Refund Date</label>
                        <input type="text" id="txtAdvanceDate" class="bp-input datepicker" />
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Total Bill</label>
                        <input type="text" id="txtToT_amount" class="bp-input" style="text-align:right;" disabled="disabled" />
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Received Amount</label>
                        <input type="text" id="txt_RcvdAmount" class="bp-input" style="text-align:right;" disabled="disabled" />
                    </div>
                    <div>
                        <label class="bp-summary-label" style="display:block;margin-bottom:4px;">Remarks</label>
                        <textarea id="txtRemarks" class="bp-input" style="height:30px;resize:vertical;"></textarea>
                    </div>
                </div>
            </div>
        </div>

        <div class="bp-card">
            <div class="bp-card-header">
                <i class="fa fa-list"></i>
                <span>Refund Items</span>
            </div>
            <div class="bp-card-body" style="padding:8px;">
                <div class="bp-table-wrap bp-table-scroll">
                    <table class="bp-table" id="tblDetails">
                        <thead>
                            <tr>
                                <th>Description</th>
                                <th style="text-align:right;">Doc Share</th>
                                <th style="text-align:right;">Hospital Share</th>
                                <th style="text-align:right;width:95px;">Doctor Refund</th>
                                <th style="text-align:right;width:95px;">Hospital Refund</th>
                                <th style="text-align:center;width:60px;">Select</th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                </div>

                <fieldset style="display:none">
                    <legend style="margin-bottom: 0px">Doctor Refund Distribution</legend>
                    <div class="bp-table-wrap bp-table-scroll">
                        <table class="bp-table" id="Doctor_Share_Table">
                            <thead>
                                <tr>
                                    <th>Doctor Name</th>
                                    <th>Share Type</th>
                                    <th style="text-align:right;">Amount</th>
                                    <th style="text-align:right;width:95px;">Refund Dis</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </fieldset>
            </div>
        </div>

        <div class="bp-card">
            <div class="bp-card-body" style="padding:0;">
                <div class="bp-summary-row bp-summary-row--total">
                    <span class="bp-summary-label">Total Refund</span>
                    <input type="text" id="txtTotalDoctorShare" class="bp-summary-value" style="font-size:15px;font-weight:700;color:var(--bp-primary);" disabled="disabled" />
                    <input type="hidden" id="txtDoctorTotalDistribution" disabled="disabled" />
                </div>
            </div>
        </div>

        <div class="row mt-3">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="Save" onclick="SaveRecord()" id="btnSave" class="btn btn-primry" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="List View" class="btn-gray" onclick="window.open('RefundList.aspx')" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintRefund()" value="Print" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3" id="divApproveContainer" style="display:none;">
                        <input type="button" id="btnApprove" class="btn btn-primry" onclick="ApproveRefund()" value="Approve" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3" id="divUnApproveContainer" style="display:none;">
                        <input type="button" id="btnUnApprove" class="btn btn-primry" onclick="UnApproveRefund()" value="UnApprove" />
                    </div>

                    <div class="col-lg-2 col-md-2 col-sm-3" id="divVoucherContainer" style="display:none;">
                        <input type="button" id="btnPrintVoucher" class="btn btn-primry" onclick="PrintVoucher();" value="Voucher" />
                    </div>
                </div>
            </div>
        </div>
    </div>



</asp:Content>
