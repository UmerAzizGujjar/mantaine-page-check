<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Refund.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Refund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/css/CustomCss/Refund.css" rel="stylesheet" />
    <script type="text/javascript">          
        $(document).ready(function () {


            $('#colApprove').hide();
            $('#colPrint').hide();

            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            if (refundID) {
                LoadPatientDetails(refundID);
            }

            $('#txtHospitalRefund, #txtDoctorRefund').on('input', updateTotalRefund);
            updateTotalRefund();
            $('#TotalRefundAmount').prop('disabled', true);

            $('#txtRefundDate').datepicker({
                dateFormat: 'mm/dd/yy',
                changeMonth: true,
                changeYear: true,
                yearRange: '2000:2030',
                defaultDate: new Date()
            });
        });

        function LoadPatientDetails(refundID) {
            $.ajax({
                type: "POST",
                url: "OPD_Refund.aspx/GetOPDPatient",
                data: JSON.stringify({ refundID: refundID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccesss,
                error: function () {
                    alert("Failed to load refund details.");
                }
            });
        }

        function OnSuccesss(response) {
            var data = JSON.parse(response.d);
            if (!data.Refund_ID) {
                alert("Refund not found.");
                return;
            }
            $('#hdPatientID').text(data.Patient_ID);
            $('#hdRegPatId').val(data.Reg_PatId);
            $('#lblMRNo').text(data.Patient_No);
            $('#lblPatienName').text(data.Full_Name);
            $('#lblAgeYears').text(data.Age_years);
            $('#lblGender').text(data.Gender);
            $('#lblRegDate').text(formatDate(data.Entry_Date));
            $('#lblAddress').text(data.Address);
            $('#lblContactNo').text(data.Mobile1);
            $('#lblDepartment').text(data.department);
            $('#lblPatientCategory').text(data.Patient_Main_Category);
            $('#txtRemarks').val(data.Remarks);

            $('#txtOPD_NO').val(data.OPD_No);
            $('#txtHospitalRefund').val((data.Hospital_Refund || 0).toFixed(2));
            $('#txtDoctorRefund').val((data.Doctor_Refund || 0).toFixed(2));

            $('#txtDoctorAmount').val((data.Doctor_Amount || 0).toFixed(2));
            $('#txtHospitalShare').val((data.Hospital_share || 0).toFixed(2));
            $('#txtActualAmount').val((data.Actual_amount || 0).toFixed(2));

            if (data.Refund_Date) {
                var refundDate = parseAspNetDate(data.Refund_Date);
                if (refundDate) {
                    $('#txtRefundDate').val($.datepicker.formatDate('mm/dd/yy', refundDate));
                }
            } else {
                $('#txtRefundDate').val($.datepicker.formatDate('mm/dd/yy', new Date()));
            }

            $('#btnSave').val('Update');

            if (data.Status === "Approved") {
                $('#btnSave').prop('disabled', true);
                $('#txtHospitalRefund').prop('disabled', true);
                $('#txtDoctorRefund').prop('disabled', true);
                $('#txtRemarks').prop('disabled', true);
                $('#txtRefundDate').prop('disabled', true);
                $('#colSave').hide();
                $('#colApprove').hide();
                $('#colPrint').show();
            } else {
                $('#colSave').show();
                $('#colApprove').show();
                $('#colPrint').hide();
            }
        }

        function updateTotalRefund() {
            var hospitalRefund = parseFloat($('#txtHospitalRefund').val()) || 0;
            var doctorRefund = parseFloat($('#txtDoctorRefund').val()) || 0;
            var total = hospitalRefund + doctorRefund;
            $('#TotalRefundAmount').val(total.toFixed(2));
        }

        function parseAspNetDate(dateStr) {
            if (!dateStr) return null;
            var match = dateStr.match(/\/Date\((\d+)(?:[+-]\d+)?\)\//);
            if (match) {
                return new Date(parseInt(match[1]));
            }
            var isoDate = new Date(dateStr);
            return isNaN(isoDate.getTime()) ? null : isoDate;
        }

        function formatDate(dateStr) {
            var d = parseAspNetDate(dateStr);
            if (!d) return "";

            var months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
            return d.getDate() + '-' + months[d.getMonth()] + '-' + d.getFullYear();
        }

        function PrintRefund() {
            debugger;
            var refundID = '<% =Request.QueryString["RefundID"] %>';
            if (!refundID) {
                var urlParams = new URLSearchParams(window.location.search);
                refundID = urlParams.get("RefundID");
            }

            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=PrintRefundReport&Title=Refund Print &Refund_ID=" + refundID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintAdvanceReport&Title=Refund Print &Refund_ID=" + refundID;
            }
            window.open(url, '_blank');
        }

        function GetPatientDetailByOPDNO() {
            var opdNo = $('#txtOPD_NO').val();
            if (!opdNo.trim()) {
                alert("Please enter OPD No.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "OPD_Refund.aspx/GetPatientByOPDNo",
                data: JSON.stringify({ "opdNo": opdNo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var patients = JSON.parse(response.d);
                    if (patients.length === 0) {
                        alert("No patient found.");
                        return;
                    }
                    var p = patients[0];

                    if (p.Is_Refund == 1 || p.Is_Refund == true) {
                        Swal.fire({
                            title: "Already Refunded",
                            text: "This patient OPD is already refunded",
                            icon: "warning",
                            button: "OK"
                        });
                        return;
                    }
                    $('#hdPatientID').text(p.Patient_ID);
                    $('#hdRegPatId').val(p.Reg_PatId);
                    $('#lblMRNo').text(p.Patient_No);
                    $('#lblPatienName').text(p.Full_Name);
                    $('#lblAgeYears').text(p.Age_years);
                    $('#lblGender').text(p.Gender);
                    $('#lblRegDate').text(p.Creation_Date);
                    $('#lblAddress').text(p.Permanent_Address);
                    $('#lblContactNo').text(p.Mobile1);
                    $('#lblDepartment').text(p.Department);
                    $('#lblPatientCategory').text(p.Patient_Type);
                    $('#txtDoctorAmount').val(p.Doctor_Amount);
                    $('#txtHospitalShare').val(p.Hospital_share);
                    $('#txtActualAmount').val(p.Actual_amount);
                    $('#txtRefundDate').val($.datepicker.formatDate('mm/dd/yy', new Date()));
                    $('#colApprove').hide();
                    $('#colPrint').hide();
                    $('#colSave').show();
                    $('#btnSave').val('Save');
                    $('#btnSave').prop('disabled', false);
                    $('#txtHospitalRefund').prop('disabled', false);
                    $('#txtDoctorRefund').prop('disabled', false);
                    $('#txtRemarks').prop('disabled', false);
                },
                error: function () {
                    alert("Failed to load patient data.");
                }
            });
        }

        function SaveOPDRecord() {
            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            var HospitalRefund = parseFloat($("#txtHospitalRefund").val()) || 0;
            var DoctorRefund = parseFloat($("#txtDoctorRefund").val()) || 0;

            var maxHospitalShare = parseFloat($("#txtHospitalShare").val()) || 0;
            var maxDoctorAmount = parseFloat($("#txtDoctorAmount").val()) || 0;

            var refundDate = $('#txtRefundDate').val();
            if (!refundDate) {
                refundDate = $.datepicker.formatDate('mm/dd/yy', new Date());
            }

            if (HospitalRefund > maxHospitalShare) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Invalid Hospital Refund',
                    text: 'Hospital refund cannot exceed the hospital share (' + maxHospitalShare.toFixed(2) + ').',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            if (DoctorRefund > maxDoctorAmount) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Invalid Doctor Refund',
                    text: 'Doctor refund cannot exceed the doctor amount (' + maxDoctorAmount.toFixed(2) + ').',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            if (HospitalRefund === 0 && DoctorRefund === 0) {
                Swal.fire({
                    icon: 'warning',
                    title: 'No Refund Amount',
                    text: 'Please enter at least one refund amount (Hospital or Doctor).',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            var data = {
                Refund_ID: refundID || "",
                Patient_ID: $("#hdPatientID").text(),
                Reg_PatId: $("#hdRegPatId").val(),
                OPD_No: $("#txtOPD_NO").val(),
                Refund_Date: refundDate,
                Hospital_Refund: HospitalRefund,
                Doctor_Refund: DoctorRefund,
                Remarks: $("#txtRemarks").val()
            };

            $.ajax({
                type: "POST",
                url: "OPD_Refund.aspx/SaveRefund",
                data: JSON.stringify({ data: data }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "Success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Refund OPD saved successfully. Please Approve to generate voucher.',
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        }).then(() => {
                            if (!refundID) {
                                window.location.reload();
                            } else {
                                LoadPatientDetails(refundID);
                            }
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function () {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Save failed.',
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                }
            });
        }

        function ApproveOPDRecord() {
            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            if (!refundID) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Error',
                    text: 'Cannot approve: No Refund ID found. Please save first.'
                });
                return;
            }

            Swal.fire({
                title: 'Are you sure?',
                text: "This will generate the financial voucher and mark as Approved!",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#3085d6',
                cancelButtonColor: '#d33',
                confirmButtonText: 'Yes, Approve it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "OPD_Refund.aspx/ApproveRefund",
                        data: JSON.stringify({ refundID: refundID }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d === "Success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Approved!',
                                    text: 'Refund approved and voucher generated.',
                                    showConfirmButton: false,
                                    timer: 2000
                                }).then(() => {
                                    LoadPatientDetails(refundID); 
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Approval Failed',
                                    text: response.d
                                });
                            }
                        },
                        error: function () {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Approval request failed.'
                            });
                        }
                    });
                }
            });
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <input type="hidden" id="hdRegPatId" />
        <input type="hidden" id="hdPatientID" />
        
        <div class="row">
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/billing2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image /">
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-4 col-md-5 col-sm-6">
                                        <label>OPD No:</label>
                                    </div>
                                    <div class="col-lg-8 col-md-7 col-sm-6 top">
                                        <input type="text" id="txtOPD_NO" class="form-control" />
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-4 col-md-5 col-sm-6">
                                        <label>Patient Name :</label>
                                    </div>
                                    <div class="col-lg-8 col-md-7 col-sm-6 top">
                                        <label id="lblPatienName"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                        <label>Contact No :</label>
                                    </div>
                                    <div class="col-lg-8 col-md-7 col-sm-6 top">
                                        <label id="lblContactNo"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                        <label>Reg. Date :</label>
                                    </div>
                                    <div class="col-lg-8 col-md-7 col-sm-6 top">
                                        <label id="lblRegDate"></label>
                                    </div>
                                </div>
                                <div class="row mb-3 mtt">
                                    <div class="col-lg-4 col-md-5 col-sm-6 formrgn">
                                        <label>Gender :</label>
                                    </div>
                                    <div class="col-lg-8 col-md-7 col-sm-6 top">
                                        <label id="lblGender"></label>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-lg-4 formrgn">
                                <label>Age Years :</label>
                            </div>
                            <div class="col-lg-4">
                                <label id="lblAgeYears"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 formrgn">
                                <label>Address :</label>
                            </div>
                            <div class="col-lg-4">
                                <label id="lblAddress"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 formrgn">
                                <label>Patient Category :</label>
                            </div>
                            <div class="col-lg-4">
                                <label id="lblPatientCategory"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 formrgn">
                                <label>Department :</label>
                            </div>
                            <div class="col-lg-4">
                                <label id="lblDepartment"></label>
                            </div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4 formrgn" style="display: none">
                                <label>MR No *:</label>
                            </div>
                            <div class="col-lg-4" style="display: none">
                                <label id="lblMRNo"></label>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" value="Search" id="btnSearch" class="btn btn-primry" onclick="GetPatientDetailByOPDNO()" />
            </div>
        </div>

        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Doctor Share</label>
                <input type="text" id="txtDoctorAmount" class="form-control text-right" disabled="disabled" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Hospital Share</label>
                <input type="text" id="txtHospitalShare" class="form-control text-right" disabled="disabled" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Actual Amount</label>
                <input type="text" id="txtActualAmount" class="form-control text-right" disabled="disabled" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Hospital Refund</label>
                <input type="text" id="txtHospitalRefund" class="form-control text-right"  />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Doctor Refund</label>
                <input type="text" id="txtDoctorRefund" class="form-control text-right" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Total Refund</label>
                <input type="text" id="TotalRefundAmount" class="form-control text-right" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Refund Date</label>
                <input type="text" id="txtRefundDate" class="form-control datepicker" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Remarks</label>
                <input type="text" id="txtRemarks" class="form-control" />
            </div>
            
        </div>
        
        <div class="row mt-3" id="divActionButtons">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6" id="colSave">
                        <input type="button" value="Save" onclick="SaveOPDRecord()" id="btnSave" class="btn btn-primry" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6" id="colApprove">
                        <input type="button" value="Approve" onclick="ApproveOPDRecord()" id="btnApprove" class="btn btn-primry" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="List View" class="btn-gray" onclick="window.open('OPD_Refund_List.aspx')" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3" id="colPrint">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintRefund()" value="Print" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>