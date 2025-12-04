<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Refund.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Refund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Refund.css" rel="stylesheet" />
    <script type="text/javascript">          
        $(document).ready(function () {
            $("#txtAdvanceDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtAdvanceDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));

            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID");

            if (refundID) {
                LoadPatientDetails(refundID);
            }
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

            $('#btnSave').val('Update');
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

        function formatDateForPicker(dateStr) {
            var d = parseAspNetDate(dateStr);
            if (!d) return "";

            var mm = (d.getMonth() + 1).toString().padStart(2, '0');
            var dd = d.getDate().toString().padStart(2, '0');
            var yyyy = d.getFullYear();
            return mm + '/' + dd + '/' + yyyy;
        }
        
        function PrintRefund() {
            debugger;
            var refundID = '<% =Request.QueryString["advID"] %>';
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
                    $('#hdPatientID').text(p.pat_id);
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
                    alert("Failed to load patient data.");
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


        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }


        

        function SaveOPDRecord() {
            var urlParams = new URLSearchParams(window.location.search);
            var refundID = urlParams.get("RefundID"); // matches your URL: ?RefundID=5

            var HospitalRefund = parseFloat($("#txtHospitalRefund").val()) || 0;
            var DoctorRefund = parseFloat($("#txtDoctorRefund").val()) || 0;

            var data = {
                Refund_ID: refundID || "", 
                pat_id: $("#hdPatientID").text(),
                OPD_No: $("#txtOPD_NO").val(),
                Refund_Date: $("#txtAdvanceDate").val(),
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
                        Swal.fire("Success", "Refund saved!", "success").then(() => {
                            window.location.href = "OPD_Refund_List.aspx";
                        });
                    } else {
                        Swal.fire("Error", response.d, "error");
                    }
                },
                error: function () {
                    Swal.fire("Error", "Save failed.", "error");
                }
            });
        }



    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <input type="hidden" id="hdPatientID" />
        <input type="hidden" id="txtOPD_No" />
        <div class="row">
            <!-- Left Card -->
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/billing2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image /">
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
            <!-- Right Card -->
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
                <label>Doctor Amount</label>
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
                <label>Remarks</label>
                <input type="text" id="txtRemarks" class="form-control" />
            </div>
        </div>
        
        <div class="row mt-3">
            <div class=" col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="Save" onclick="SaveOPDRecord()" id="btnSave" class="btn btn-primry" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" value="List View" class="btn-gray" onclick="window.open('RefundList.aspx')" />
                    </div>
                    <div class="col-lg-2 col-md-2 col-sm-3">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintRefund()" value="Print" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
