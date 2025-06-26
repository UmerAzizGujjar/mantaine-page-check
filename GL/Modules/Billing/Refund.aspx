<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Refund.aspx.cs" Inherits="PMS.Refund" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/CustomCss/Refund.css" rel="stylesheet" />
     <link href="../../wwwroot/Pakred/css/CustomCss/swalalert.css" rel="stylesheet" />

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
            }
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
        function LoadPatientDetails(advID) {
            debugger;
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
            debugger;
            var parseData = JSON.parse(data.d);
            if (data.d != '') {
                if (data.d.Patient_Discount_Type == null)
                    data.d.Patient_Discount_Type = "";
                var mydate = new Date(Date.parse(parseData.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#hdPatientID').text(ReplaceNullWith_Space(parseData.Patient_ID));
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
            debugger;
            PageMethods.LoadShareDetails(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                var Description = '';

                $.each(data, function (key, value) {
                    debugger;
                    rows = '<tr></td> ' + value.Item_Name + '</td><td>' + value.Item_Name + '</td><td>' + value.Doctor_Share + '</td><td>' + value.Net_Amount + '  </td><td>' + value.Refund_Amount + '  </td><td>' + value.Hospital_Refund + '  </td></tr>'


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
            debugger;
            PageMethods.RefundDetials(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#Doctor_Share_Table tbody tr').length)));
                var Description = '';
                $.each(data, function (key, value) {
                    debugger;
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
            debugger;
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
            debugger;
            var Bill_No = $('#txtBillNo').val();
            $.ajax({
                type: "post",
                url: "Refund.aspx/LoadPatientDetailsByBillNO",
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
                    $('#lblContactNo').text(parse[0].Mobile1);
                    $('#lblDepartment').text(parse[0].Department);
                    $('#lblPatientCategory').text(parse[0].Patient_Type);
                    for (var i = 0; i < length; i++) {
                        debugger;
                        rows += '<tr><td style="display:none">' + parse[i].Patient_ID + '</td><td style="display:none">' + parse[i].Bill_Details_ID + '  </td><td style="display:none">' + parse[i].Item_Id + '</td><td style="text-align: center;">' + parse[i].Item_Name + '</td><td style="text-align: center;">' + parse[i].Doctor_Share + '</td><td style="text-align: center;">' + parse[i].Hospital_Share + '</td><td><input type="text"  id="DocRefund' + i + '"  name="DocRefund" value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td><td><input type="text" name="HosRefund" value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td></tr>';
                    }
                    $('#tblDetails tbody tr').remove();
                    $('#tblDetails tbody').append(rows);
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
                    debugger;
                    var parse = JSON.parse(response.d);
                    var length = parse.length;
                    var rows;
                    debugger;
                    for (var i = 0; i < length; i++) {
                        debugger;
                        rows += '<tr><td style="display:none">' + parse[i].Patient_ID + '</td><td style="display:none">' + parse[i].Emp_ID + '</td><td style="display:none">' + parse[i].Record_ID + '</td><td style="text-align: center;">' + parse[i].Emp_Name + '</td><td style="text-align: center;">' + parse[i].Share_Type_Name + '</td><td style="text-align: center;">' + parse[i].Amount + '</td><td><input type="text" id="RefundDis' + i + '" name="RefundDis" value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td></tr>';
                    }
                    $('#Doctor_Share_Table tbody tr').remove();
                    $('#Doctor_Share_Table tbody').append(rows);

                }
            });

        }
        function calculateDoctorShare() {
            debugger;
            var list = document.getElementById('tblDetails');
            var doctorsList = document.getElementById('Doctor_Share_Table');
            var totalDoctorDistribution = 0;
            var totalDoctorShare = 0;
            for (var i = 0; i < list.rows.length - 1; i++) {
                var data = $('#DocRefund' + i + '').val();
                if (data == '')
                    data = 0;
                totalDoctorShare += parseInt(data);
            }
            for (var i = 0; i < doctorsList.rows.length - 1; i++) {
                var data = $('#RefundDis' + i + '').val();
                if (data == '')
                    data = 0;
                totalDoctorDistribution += parseInt(data);
            }
            $('#txtTotalDoctorShare').val(totalDoctorShare);
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

            if (Totaldoctorshare != Totaldoctordistribution) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Doctor Refund and Doctor Distribution Refund Should be Same.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                proceed = false;
            }

            return proceed;
        }
    </script>

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
                            <img src="~../../../../wwwroot/Pakred/images/dashboard_Icons/billing2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image /">
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
           <div class="col-lg-2 col-md-4 col-sm-6">
               <label>Refund Date :</label>
               <input type="text" id="txtAdvanceDate" class="form-control" />
           </div>
           <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Remarks:</label>
               <textarea id="txtRemarks" class="form-control" style="height:35px"></textarea>
           </div>
       </div>       
    </div>






    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-6 col-md-6 col-sm-6" style="margin-top:2%" >
                <div class="table-responsive" style="height: 250px;">
                    <table class="table table-borderless" id="tblDetails">
                        <thead>
                            <tr>
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
            <div class="col-lg-6 col-md-6 col-sm-6">
                <div class="table-responsive">
                    <tr>
                        <td>
                            <input type="hidden" id="txtAdvanceAmount" />
                        </td>
                        <td>
                            <label id="lblOutput" style="background-color: silver; display: none;"></label>
                        </td>
                        <td>
                            <label id="lblOutputShow" style="margin-left: -214px; display: none;"></label>
                        </td>
                        <td>
                            <div>
                                <fieldset>
                                    <legend style="margin-bottom: 0px">Doctor Refund Distribution</legend>
                                    <div class="table-responsive" style="max-height: 217px;">
                                        <table class="table table-borderless" id="Doctor_Share_Table">
                                            <thead>
                                                <tr>
                                                    <th style="width: 126px;">Doctor Name</th>
                                                    <th style="width: 126px;">Share Type</th>
                                                    <th style="width: 72px;">Amount</th>
                                                    <th style="width: 72px;">Refund Dis</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                            </tbody>
                                        </table>
                                    </div>
                                </fieldset>
                            </div>
                        </td>
                    </tr>

                </div>
            </div>


        </div>
    </div>


    <div class="container mt-2">
        <div class="row ml-1">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <div id="dvSummary">

                    <tr>
                        <td>Total Doctor Refund</td>
                        <td>
                            <input type="text" id="txtTotalDoctorShare" class="form-control text-right fs-4" disabled="disabled" />
                        </td>
                    </tr>

                </div>
            </div>
            <div class="col-lg-6 col-md-6 col-sm-12">
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <div id="dvSummary">
                    <tr>
                        <td>Doctors Refund Distribution</td>
                        <td>
                            <input type="text" id="txtDoctorTotalDistribution" class="form-control" disabled="disabled" />
                        </td>
                    </tr>
                </div>
            </div>
        </div>
    </div>



    <div class="row mt-3">
        <div class =" col-lg-8">
            <div class="row">
        <div class="col-lg-2 col-md-3 col-sm-6">
            <input type="button"  value="Save" onclick="SaveRecord()" id="btnSave" class="btn btn-primry" />
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



</asp:Content>
