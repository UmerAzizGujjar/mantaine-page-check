<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Share_Distribution.aspx.cs" Inherits="PMS.Modules.Billing.Share_Distribution" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Refund.css" rel="stylesheet" />
     <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            $("#txtDistributuionDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtDistributuionDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
        });
        function GetPatientDetailByBill() {
            debugger;
            var Bill_No = $('#txtBillNo').val();
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/LoadPatientDetailsByBillNO",
                data: JSON.stringify({
                    "Bill_No": Bill_No
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    var length = parse.length;
                    var rows;
                    debugger;
                    $('#hdPatientID').text(parse[0].Patient_ID);
                    $('#lblMRNo').text(parse[0].Patient_No);
                    $('#lblPatienName').text(parse[0].Full_Name);
                    $('#lblAgeYears').text(parse[0].Age_years);
                    $('#lblGender').text(parse[0].Gender);
                    $('#lblRegDate').text(parse[0].Creation_Date);
                    $('#lblAddress').text(parse[0].Permanent_Address);
                    $('#txtToT_amount').val(parse[0].Total_Amount);
                    $('#txt_netAmount').val(parse[0].Net_Amount);
                    $('#txt_RcvdAmount').val(parse[0].Received_Amount);
                    $('#txt_DiscAmount').val(parse[0].Discount_Amount);
                    $('#txt_BalAmount').val(parse[0].balance_Amount);
                    $('#txtAdv_amount').val(parse[0].Advance_Amount);
                    $('#lblContactNo').text(parse[0].Mobile1);
                    $('#lblDepartment').text(parse[0].Department);
                    $('#lblPatientCategory').text(parse[0].Patient_Type);
  
                }

            });
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/LoadDistributionDetailsByBillNO",
                data: JSON.stringify({
                    "Bill_No": Bill_No
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    var length = parse.length;
                    var rows;
                    debugger;
                    for (var i = 0; i < length; i++) {
                        debugger;
                        rows += '<tr><td style="display:none">' + parse[i].Patient_ID + '</td><td style="display:none">' + parse[i].Emp_ID + '</td><td style="display:none">' + parse[i].Record_ID + '</td><td style="text-align: center;">' + parse[i].Emp_Name + '</td><td style="text-align: center;">' + parse[i].Share_Type_Name + '</td><td style="text-align: center;">' + parse[i].Amount + '</td><td><input type="text" id="RefundDis' + i + '" name="RefundDis" value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td></tr>';
                    }
                    $('#tblDetails tbody tr').remove();
                    $('#tblDetails tbody').append(rows);

                }
            });
        }

    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container-fluid">
    <input type="hidden" id="hdPatientID" />
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
                            <label>Bill No:</label>
                        </div>
                        <div class="col-lg-8 col-md-7 col-sm-6 top">
                            <input type="text" id="txtBillNo" class="form-control" />
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
                        <div class="col-lg-4 formrgn">
                           <label>InPatient Admit Category :</label>
                        </div>
                        <div class="col-lg-4">
                            <label id="lblPatientDiscountType" class="bg-secondary"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-4 formrgn" style="display:none">
                            <label>MR No *:</label>
                        </div>
                        <div class="col-lg-4" style="display:none">
                             <label id="lblMRNo"></label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" value="Search" id="btnSearch" class="btn btn-primry"  onclick="GetPatientDetailByBill()" />
        </div>
    </div>
        <div class="row">
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Total Bill:</label>
                <input type="text" id="txtToT_amount" disabled="disabled" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Discount Amount:</label>
                <input type="text" id="txt_DiscAmount" disabled="disabled" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Net Amount :</label>
                <input type="text" id="txt_netAmount" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Recieved Amount:</label>
                <input type="text" id="txt_RcvdAmount" class="form-control" />
            </div>


        </div>

        <div class="row">
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Advance Amount:</label>
                <input type="text" id="txtAdv_amount" disabled="disabled" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Balance Amount:</label>
                <input type="text" id="txt_BalAmount" disabled="disabled" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Distribution Date :</label>
                <input type="text" id="txtDistributuionDate" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Remarks:</label>
                <textarea id="txtRemarks" class="form-control" style="height: 35px"></textarea>
            </div>

        </div>

    </div>


    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-12 col-md-6 col-sm-6" style="margin-top: 2%">
                <div class="table-responsive" style="height: 250px;">
                    <table class="table table-borderless" id="tblDetails">
                        <thead>
                            <tr>
                                <th>Account</th>
                                <th>Description</th>
                                <th>Doc Share</th>
                                <th>Hospital Share</th>
                                <th>Doctor Refund</th>
                                <th>Hospital Refund</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>


        </div>
    </div>


</asp:Content>
