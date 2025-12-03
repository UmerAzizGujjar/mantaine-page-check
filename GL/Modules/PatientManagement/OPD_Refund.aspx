<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Refund.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Refund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Refund.css" rel="stylesheet" />
    <script type="text/javascript">          
        $(document).ready(function () {
            $("#txtAdvanceDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtAdvanceDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
            debugger;

            var advID = '<% =Request.QueryString["advID"] %>';
        if (advID != "") {
            LoadPatientDetails(advID);

        }

    });
        
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
                    $('#hdPatientID').text(p.Patient_ID);
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


        function SaveRecord() {
            if (validateSave()) {
                debugger;
                var Patient_ID = $("#hdPatientID").text();

                var remarks = $("#txtRemarks").text();
                var advanceDate = $("#txtAdvanceDate").val();
                var saveVal = $('#btnSave').val();
                var advID = '<% =Request.QueryString["advID"] %>';

                var ServiceRefund = [];
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    debugger;
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
                    debugger;
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
        }

        function validateSave() {
            debugger;
            var proceed = true;

            var Totaldoctorshare = $('#txtTotalDoctorShare').val();
            var Totaldoctordistribution = $('#txtDoctorTotalDistribution').val();

            return proceed;
        }

        function SaveOPDRecord() {
            var data = {
                pat_id: $("#hdPatientID").text(),
                OPD_No: $("#txtOPD_NO").val(),
                Refund_Date: $("#txtAdvanceDate").val(),
                Hospital_Refund: parseFloat($("#txtHospitalRefund").val()) || 0,
                Doctor_Refund: parseFloat($("#txtDoctorRefund").val()) || 0,
                Remarks: $("#txtRemarks").val()
            };

            $.ajax({
                type: "POST",
                url: "OPD_Refund.aspx/SaveRefund",
                data: JSON.stringify({ data: data }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function () {
                    Swal.fire("Success", "Refund Saved!", "success");
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
