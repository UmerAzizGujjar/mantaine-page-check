<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyRefund.aspx.cs" Inherits="PMS.Modules.PatientManagement.EmergencyRefund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/emergency-refund.css" rel="stylesheet" />
    <script type="text/javascript">          
        $(document).ready(function () {
            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            if (refundID) {
                LoadPatientDetails(refundID);
            }

            $('#txtHospitalRefund, #txtDoctorRefund').on('input', updateTotalRefund);
            updateTotalRefund();
            $('#TotalRefundAmount').prop('disabled', true);
        });

        function LoadPatientDetails(refundID) {
            $.ajax({
                type: "POST",
                url: "EmergencyRefund.aspx/GetEmergencyPatient",
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
            $('#hdPatientID').text(data.Emer_id);
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

            $('#txtEmergency_NO').val(data.Emergency_No);
            $('#txtHospitalRefund').val((data.Hospital_Refund || 0).toFixed(2));
            $('#txtDoctorRefund').val((data.Doctor_Refund || 0).toFixed(2));

            $('#txtDoctorAmount').val((data.Doctor_Amount || 0).toFixed(2));
            $('#txtHospitalShare').val((data.Hospital_share || 0).toFixed(2));
            $('#txtActualAmount').val((data.Actual_amount || 0).toFixed(2));

            $('#btnSave').val('Update');
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
            var refundID = '<% =Request.QueryString["RefundID"] %>';
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=PrintEmergencyRefundReport&Title=Emergency Refund Print &Refund_ID=" + refundID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=PrintEmergencyRefundReport&Title=Emergency Refund Print &Refund_ID=" + refundID;
            }
            window.open(url, '_blank');
        }

        function GetPatientDetailByEmergencyNO() {
            var emergencyNo = $('#txtEmergency_NO').val();
            if (!emergencyNo.trim()) {
                alert("Please enter Emergency No.");
                return;
            }

            $.ajax({
                type: "POST",
                url: "EmergencyRefund.aspx/GetPatientByEmergencyNo",
                data: JSON.stringify({ "emergencyNo": emergencyNo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var patients = JSON.parse(response.d);
                    if (patients.length === 0) {
                        alert("No emergency record found.");
                        return;
                    }
                    var p = patients[0];

                    if (p.isCancel == true || p.isCancel === 1) {
                        Swal.fire({
                            title: "Emergency Cancelled",
                            text: "This emergency has been cancelled and cannot be processed for refund.",
                            icon: "warning",
                            button: "OK"
                        });
                        return;
                    }
                    if (p.Is_Refund == 1 || p.Is_Refund == true) {
                        Swal.fire({
                            title: "Already Refunded",
                            text: "This emergency is already refunded",
                            icon: "warning",
                            button: "OK"
                        });
                        return;
                    }
                    $('#hdPatientID').text(p.Emer_id);
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
                },
                error: function () {
                    alert("Failed to load emergency data.");
                }
            });
        }

        function SaveEmergencyRecord() {
            $('#btnSave').attr('disabled', true);
            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            var HospitalRefund = parseFloat($("#txtHospitalRefund").val()) || 0;
            var DoctorRefund = parseFloat($("#txtDoctorRefund").val()) || 0;

            var maxHospitalShare = parseFloat($("#txtHospitalShare").val()) || 0;
            var maxDoctorAmount = parseFloat($("#txtDoctorAmount").val()) || 0;

            if (HospitalRefund > maxHospitalShare) {
                $('#btnSave').attr('disabled', false);
                Swal.fire({
                    icon: 'warning',
                    title: 'Invalid Hospital Refund',
                    text: 'Hospital refund cannot exceed the hospital share (' + maxHospitalShare.toFixed(2) + ').'
                });
                return;
            }

            if (DoctorRefund > maxDoctorAmount) {
                $('#btnSave').attr('disabled', false);
                Swal.fire({
                    icon: 'warning',
                    title: 'Invalid Doctor Refund',
                    text: 'Doctor refund cannot exceed the doctor amount (' + maxDoctorAmount.toFixed(2) + ').'
                });
                return;
            }

            if (HospitalRefund === 0 && DoctorRefund === 0) {
                $('#btnSave').attr('disabled', false);
                Swal.fire({
                    icon: 'warning',
                    title: 'No Refund Amount',
                    text: 'Please enter at least one refund amount (Hospital or Doctor).'
                });
                return;
            }

            var data = {
                Refund_ID: refundID || "",
                Patient_ID: $("#hdPatientID").text(),
                Reg_PatId: $("#hdRegPatId").val(),
                Emergency_No: $("#txtEmergency_NO").val(),
                Refund_Date: $("#txtRefundDate").val(),
                Hospital_Refund: HospitalRefund,
                Doctor_Refund: DoctorRefund,
                Remarks: $("#txtRemarks").val()
            };

            $.ajax({
                type: "POST",
                url: "EmergencyRefund.aspx/SaveRefund",
                data: JSON.stringify({ data: data }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "Success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Emergency refund saved successfully.',
                            showConfirmButton: false,
                            timer: 2500
                        }).then(() => {
                            window.location.href = "EmergencyRefund_List.aspx";
                        });
                    } else {
                        $('#btnSave').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d
                        });
                    }
                },
                error: function () {
                    $('#btnSave').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Save failed.'
                    });
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="er-page">
        <input type="hidden" id="hdRegPatId" />
        <input type="hidden" id="hdPatientID" />
        <input type="hidden" id="txtRefundDate" class="datepicker" />

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="er-badge"><span class="er-badge-label">MR No</span><span class="er-badge-value" id="badgeRfMr">---</span></div>
                <div class="er-badge"><span class="er-badge-label">Total Refund</span><span class="er-badge-value" id="badgeRfTotal">0.00</span></div>
                <div class="er-badge"><span class="er-badge-label">Status</span><span class="er-badge-value" id="refundStatusBadge">New Refund</span></div>
            </div>
        </div>

        <div class="er-layout">
            <section class="er-card">
                <h5 class="er-card-title"><i class="fa fa-user-circle"></i> Patient Information</h5>
                <div class="er-patient">
                    <div class="er-avatar">
                        <img src="~../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/billing2.png" alt="Patient" id="patientImage" />
                    </div>
                    <div class="er-who">
                        <div class="er-name" id="lblPatienName">Patient Name</div>
                        <div class="er-search">
                            <div class="er-field">
                                <label for="txtEmergency_NO">Emergency No</label>
                                <input type="text" id="txtEmergency_NO" class="er-input" autocomplete="off" />
                            </div>
                            <button type="button" class="er-search-btn" id="btnSearch" onclick="GetPatientDetailByEmergencyNO()"><i class="fa fa-search"></i> Search Patient</button>
                        </div>
                    </div>
                </div>
                <dl class="er-info">
                    <div><dt>MR No</dt><dd id="lblMRNo"></dd></div>
                    <div><dt>Age</dt><dd id="lblAgeYears"></dd></div>
                    <div><dt>Gender</dt><dd id="lblGender"></dd></div>
                    <div><dt>Contact</dt><dd id="lblContactNo"></dd></div>
                    <div><dt>Reg Date</dt><dd id="lblRegDate"></dd></div>
                    <div><dt>Patient Category</dt><dd id="lblPatientCategory"></dd></div>
                    <div><dt>Department</dt><dd id="lblDepartment"></dd></div>
                    <div class="er-wide"><dt>Address</dt><dd id="lblAddress"></dd></div>
                </dl>
            </section>

            <section class="er-card">
                <h5 class="er-card-title"><i class="fa fa-file-text-o"></i> Original Amounts</h5>
                <div class="er-grid er-grid-1">
                    <div class="er-field er-figure er-figure-main">
                        <label for="txtActualAmount">Actual Amount</label>
                        <input type="text" id="txtActualAmount" class="er-input" disabled="disabled" />
                    </div>
                    <div class="er-field er-figure">
                        <label for="txtDoctorAmount">Doctor Share</label>
                        <input type="text" id="txtDoctorAmount" class="er-input" disabled="disabled" />
                    </div>
                    <div class="er-field er-figure">
                        <label for="txtHospitalShare">Hospital Share</label>
                        <input type="text" id="txtHospitalShare" class="er-input" disabled="disabled" />
                    </div>
                </div>
            </section>
        </div>

        <section class="er-card">
            <h5 class="er-card-title"><i class="fa fa-money"></i> Refund Details</h5>
            <div class="er-grid">
                <div class="er-field">
                    <label for="txtHospitalRefund">Hospital Refund</label>
                    <input type="text" id="txtHospitalRefund" class="er-input er-num" />
                </div>
                <div class="er-field">
                    <label for="txtDoctorRefund">Doctor Refund</label>
                    <input type="text" id="txtDoctorRefund" class="er-input er-num" />
                </div>
                <div class="er-field er-figure er-figure-main">
                    <label for="TotalRefundAmount">Total Refund</label>
                    <input type="text" id="TotalRefundAmount" class="er-input" disabled="disabled" />
                </div>
                <div class="er-field er-span-all">
                    <label for="txtRemarks">Remarks</label>
                    <input type="text" id="txtRemarks" class="er-input" />
                </div>
            </div>
        </section>

        <div class="er-actions">
            <div>
                <input type="button" value="Save" onclick="SaveEmergencyRecord()" id="btnSave" class="btn btn-primry" />
            </div>
            <div>
                <input type="button" value="List View" class="btn btn-primry" onclick="window.open('EmergencyRefund_List.aspx')" />
            </div>
            <div>
                <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintRefund()" value="Print" style="display: none" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        // title-line badges follow the form (the page script fills the fields in after loading)
        function syncRefundBadges() {
            $('#badgeRfMr').text($('#lblMRNo').text() || '---');
            $('#badgeRfTotal').text($('#TotalRefundAmount').val() || '0.00');
            $('#refundStatusBadge').text($('#btnSave').val() === 'Update' ? 'Saved' : 'New Refund');
        }
        $(function () {
            syncRefundBadges();
            setInterval(syncRefundBadges, 600);
        });
    </script>
</asp:Content>
