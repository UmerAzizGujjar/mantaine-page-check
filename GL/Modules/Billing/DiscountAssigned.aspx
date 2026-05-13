<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountAssigned.aspx.cs" Inherits="PMS.Modules.Billing.DiscountAssigned" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Refund.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">

        // =============================================
        //  PAGE READY
        // =============================================
        $(document).ready(function () {
            $("#txtdiscountdate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtdiscountdate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
            LoadTokenInputsDefaultMRNo();

            var advID = '<% =Request.QueryString["advID"] %>';
           if (advID != "") {
               LoadPatientDetails(advID);
           }

           // Master discount events
           $(document).on('keyup', '#txtDisPer', function () {
               calculateDiscountFromMaster();
           });

           $(document).on('keyup', '#txttotaldiscount', function () {
               calculateDiscountAmountFromMaster();
           });

           // Row discount events
           $(document).on('keyup', 'input[name="DisPer"]', function () {
               calculateDiscountFromRow($(this));
           });

           $(document).on('keyup', 'input[name="DisAmount"]', function () {
               calculateDiscountAmountFromRow($(this));
           });
       });

       

        // =============================================
        //  LOAD PATIENT DETAILS (via advID query string)
        // =============================================
        function LoadPatientDetails(advID) {
            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/GetPatientAndAdvanceDetail",
                data: "{'AdvanceId':'" + advID + "'}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccesss,
                failure: function (response) {
                    alert(response.d);
                }
            });
            LoadShareDetails(advID);
            RefundDetials(advID);
        }

        function OnSuccesss(data) {
            debugger;
            var parseData = JSON.parse(data.d);
            if (data.d != '') {
                var mydate = new Date(Date.parse(parseData.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#hdPatientID').text(ReplaceNullWith_Space(parseData.pat_id));
                $('#hdnBillID').val(ReplaceNullWith_Space(parseData.Bill_ID));
                $('#lblMRNo').text(ReplaceNullWith_Space(parseData.Patient_No));
                $('#lblPatienName').text(ReplaceNullWith_Space(parseData.Full_Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(parseData.Age_years));
                $('#lblGender').text(ReplaceNullWith_Space(parseData.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(parseData.Permanent_Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(parseData.Mobile1));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(parseData.Patient_Main_Category));
                $('#lblPatientDiscountType').text(ReplaceNullWith_Space(parseData.Patient_Discount_Type));
                $('#txtRemarks').val(ReplaceNullWith_Space(parseData.Remarks));
                $('#lblOutputShow').val(ReplaceNullWith_Space(parseData.Balance));
                var date = $.datepicker.formatDate('mm-dd-yy', new Date(parseInt(parseData.Refund_Date.substring(6, 19))));
                $('#txtdiscountdate').val(ReplaceNullWith_Space(date));
            }
        }

        function LoadShareDetails(advID) {
            PageMethods.LoadShareDetails(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                $.each(data, function (key, value) {
                    rows += '<tr><td style="display:none">' + value.Item_Name + '</td>' +
                        '<td>' + value.Item_Name + '</td>' +
                        '<td>' + value.Doctor_Share + '</td>' +
                        '<td>' + value.Net_Amount + '</td>' +
                        '<td>' + value.Doctor_Refund + '</td>' +
                        '<td>' + value.Hospital_Refund + '</td></tr>';
                });
                $('#tblDetails tbody').append(rows);
                $('#btnSave').val('Update');
            }, function (error) {
                alert(error.get_message());
            });
        }

        function RefundDetials(advID) {
            PageMethods.RefundDetials(advID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                $.each(data, function (key, value) {
                    rows += '<tr><td style="display:none">' + value.Emp_Name + '</td>' +
                        '<td>' + value.Emp_Name + '</td>' +
                        '<td>' + value.Share_type + '</td>' +
                        '<td>' + value.Amount + '</td>' +
                        '<td>' + value.Refund_Amount + '</td></tr>';
                });
                $('#Doctor_Share_Table tbody').append(rows);
                $('#btnSave').val('Update');
                $('#btnSave').attr('disabled', 'disabled');
            }, function (error) {
                alert(error.get_message());
            });
        }

        // =============================================
        //  MR NO TOKEN INPUT
        // =============================================
        function LoadTokenInputsDefaultMRNo() {
            $("#txtMRNo").tokenInput("json.aspx?Table=Patients", {
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
            var patientID = $("#hdPatientID").val();
            if (patientID) {
                $.ajax({
                    type: "POST",
                    url: "DiscountAssigned.aspx/LoadPatientDetails",
                    data: JSON.stringify({ PatientID: patientID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var parse = JSON.parse(response.d);
                        if (parse) {
                            $('#lblPatienName').text(parse.Name);
                            $('#lblAgeYears').text(parse.Age);
                            $('#lblGender').text(parse.Gender);
                            $('#lblRegDate').text(parse.Entry_Date);
                            $('#lblAddress').text(parse.Address);
                            $('#lblContactNo').text(parse.Mobile);
                            $('#lblDepartment').text(parse.department);
                            $('#lblPatientDiscountType').text(parse.Patient_Discount_Type);
                        }
                    }
                });
            }
        }

        // =============================================
        //  LOAD PATIENT + BILL DETAILS BY BILL NO
        // =============================================
 function GetPatientDetailByBill() {
    debugger;
    var Bill_No = $('#txtBillNo').val();
    if (!Bill_No) {
        Swal.fire({ title: "Error!", text: "Please enter Bill No", icon: "error" });
        return;
    }

    $.ajax({
        type: "post",
        url: "DiscountAssigned.aspx/LoadPatientDetailsByBillNO",
        data: JSON.stringify({ "Bill_No": Bill_No }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var parse = JSON.parse(response.d);

            if (parse && parse.length > 0) {
                if (parse[0].Is_Refund == true || parse[0].Is_Refund == 1) {
                    Swal.fire({ title: "Already Refunded", text: "This bill is already refund", icon: "warning" });
                    return;
                }

                if (parse[0].Received_Amount <= 0) {
                    Swal.fire({ title: "Invalid Amount", text: "Received Amount cannot be zero", icon: "warning" });
                    return;
                }
            }
            
            // ---- Populate patient header fields ----
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
            $('#txtReceivedAmount').val(parse[0].Received_Amount.toFixed(2)); // FIXED: Added parse[0]
            
            var rows = '';
            var totalAmount = 0;

            for (var i = 0; i < parse.length; i++) {
                var existingDiscount = parseFloat(parse[i].Discount_Amount) || 0;
                var netAmount = parseFloat(parse[i].Net_Amount) || parseFloat(parse[i].Hospital_Share) || 0;
                totalAmount += netAmount;

                // FIXED: Corrected HTML closing tags (removed extra quotes)
                rows += '<tr data-original-amount="' + netAmount + '">' +
                    '<td style="display:none">' + parse[i].Patient_ID + '</td>' +
                    '<td style="display:none">' + parse[i].Bill_Details_ID + '</td>' +
                    '<td style="display:none">' + parse[i].Item_Id + '</td>' +
                    '<td style="text-align:center;">' + parse[i].Item_Name + '</td>' +
                    '<td style="text-align:center;">' + existingDiscount.toFixed(2) + '</td>' +
                    '<td style="text-align:center;">' + netAmount.toFixed(2) + '</td>' +
                    '<td style="text-align:center;">' +
                    '<input type="text" name="DisPer" class="form-control percentage-input" value="0" />' +
                    '</td>' +
                    '<td style="text-align:center;">' +
                    '<input type="text" name="DisAmount" class="form-control discount-input" value="0" />' +
                    '</td>' +
                    '</tr>';
            }
            
            debugger;
            // ---- Clear old rows and append new ----
            $('#tblDetails tbody').empty(); // Better than removing tr
            $('#tblDetails tbody').append(rows);

            // ---- Reset summary fields ----
            $('#hdRegID').val(parse[0].pat_id);
            $('#txttotaldiscount').val('0');
            $('#txtDisPer').val('0');
            $('#lblOutputShow').val(totalAmount.toFixed(2));
        },
        error: function (xhr, status, error) {
            console.log("AJAX Error: " + error);
            Swal.fire({ title: "Error!", text: "Failed to load bill details", icon: "error" });
        }
    });
}

   
        // --- Helper: get total received amount from master field ---
        function GetTotalReceivedAmount() {
            return parseFloat($('#txtReceivedAmount').val()) || 0;
        }

        // -------------------------------------------------------
        //  MASTER -> ROWS  (user types in Discount % master field)
        // -------------------------------------------------------
        function calculateDiscountFromMaster() {
            var discPer = parseFloat($('#txtDisPer').val()) || 0;
            var totalAmount = GetTotalReceivedAmount();
            if (totalAmount <= 0) return;

            var totalDiscount = (totalAmount * discPer) / 100;
            $('#txttotaldiscount').val(totalDiscount.toFixed(2));

            distributeDiscountToRows(totalDiscount, totalAmount);
            updateNetPayable();

            // DISABLE row fields when master is used
            $('input[name="DisPer"]').prop('disabled', true);
            $('input[name="DisAmount"]').prop('disabled', true);
        }

    
        function calculateDiscountAmountFromMaster() {
            var discAmount = parseFloat($('#txttotaldiscount').val()) || 0;
            var totalAmount = GetTotalReceivedAmount();
            if (totalAmount <= 0) return;

            var discPer = (discAmount / totalAmount) * 100;
            $('#txtDisPer').val(discPer.toFixed(2));

            distributeDiscountToRows(discAmount, totalAmount);
            updateNetPayable();

            // DISABLE row fields when master is used
            $('input[name="DisPer"]').prop('disabled', true);
            $('input[name="DisAmount"]').prop('disabled', true);
        }

        // -------------------------------------------------------
        //  Distribute total discount proportionally across all rows
        //  Called only from master input handlers
        // -------------------------------------------------------
        function distributeDiscountToRows(totalDiscount, totalAmount) {
            var rows = $('#tblDetails tbody tr');
            var rowCount = rows.length;
            if (rowCount === 0) return;

            var distributed = 0;

            rows.each(function (index) {
                var originalAmount = parseFloat($(this).data('original-amount')) || 0;

                var rowDiscount;
                if (index === rowCount - 1) {
                    // Last row absorbs rounding remainder
                    rowDiscount = totalDiscount - distributed;
                } else {
                    // Proportional share based on row's original amount
                    rowDiscount = totalAmount > 0 ? (originalAmount / totalAmount) * totalDiscount : 0;
                }

                // Clamp: discount cannot exceed the row's original amount or be negative
                rowDiscount = Math.max(0, Math.min(rowDiscount, originalAmount));

                var rowDiscPer = originalAmount > 0 ? (rowDiscount / originalAmount) * 100 : 0;

                $(this).find('input[name="DisPer"]').val(rowDiscPer.toFixed(2));
                $(this).find('input[name="DisAmount"]').val(rowDiscount.toFixed(2));

                distributed += rowDiscount;
            });
        }

        // -------------------------------------------------------
        //  ROW -> MASTER  (user types Discount % in a row)
        // -------------------------------------------------------
        function calculateDiscountFromRow($input) {
            var $tr = $input.closest('tr');
            var originalAmount = parseFloat($tr.data('original-amount')) || 0;
            var discPer = parseFloat($tr.find('input[name="DisPer"]').val()) || 0;

            discPer = Math.max(0, Math.min(discPer, 100));
            var discAmount = (originalAmount * discPer) / 100;
            discAmount = Math.max(0, Math.min(discAmount, originalAmount));

            $tr.find('input[name="DisAmount"]').val(discAmount.toFixed(2));
            updateMasterFromRows();

            // DISABLE master fields when row is used
            $('#txtDisPer').prop('disabled', true);
            $('#txttotaldiscount').prop('disabled', true);
        }

        // -------------------------------------------------------
        //  ROW -> MASTER  (user types Discount Amount in a row)
        // -------------------------------------------------------
        function calculateDiscountAmountFromRow($input) {
            var $tr = $input.closest('tr');
            var originalAmount = parseFloat($tr.data('original-amount')) || 0;
            var discAmount = parseFloat($tr.find('input[name="DisAmount"]').val()) || 0;

            discAmount = Math.max(0, Math.min(discAmount, originalAmount));
            var discPer = originalAmount > 0 ? (discAmount / originalAmount) * 100 : 0;

            $tr.find('input[name="DisPer"]').val(discPer.toFixed(2));
            updateMasterFromRows();

            // DISABLE master fields when row is used
            $('#txtDisPer').prop('disabled', true);
            $('#txttotaldiscount').prop('disabled', true);
        }

        function enableAllDiscountFields() {
            $('input[name="DisPer"]').prop('disabled', false);
            $('input[name="DisAmount"]').prop('disabled', false);
            $('#txtDisPer').prop('disabled', false);
            $('#txttotaldiscount').prop('disabled', false);
        }
        // -------------------------------------------------------
        //  Sum all row discounts -> update master fields
        //  Uses .val() directly so no keyup is fired
        // -------------------------------------------------------
        function updateMasterFromRows() {
            var totalDiscount = 0;
            var totalAmount = GetTotalReceivedAmount();

            $('#tblDetails tbody tr').each(function () {
                var discount = parseFloat($(this).find('input[name="DisAmount"]').val()) || 0;
                totalDiscount += discount;
            });

            var discPer = totalAmount > 0 ? (totalDiscount / totalAmount) * 100 : 0;

            // Set master fields WITHOUT triggering keyup (use .val not user typing)
            $('#txttotaldiscount').val(totalDiscount.toFixed(2));
            $('#txtDisPer').val(discPer.toFixed(2));

            updateNetPayable();
        }

        // -------------------------------------------------------
        //  Update the Net Payable Amount label
        // -------------------------------------------------------
        function updateNetPayable() {
            var totalAmount = GetTotalReceivedAmount();
            var totalDiscount = parseFloat($('#txttotaldiscount').val()) || 0;
            var net = totalAmount - totalDiscount;
            net = Math.max(0, net);
            $('#lblOutputShow').val(net.toFixed(2));
        }

        // =============================================
        //  END DISCOUNT CALCULATION FUNCTIONS
        // =============================================

        // =============================================
        //  SAVE RECORD
        // =============================================
        function SaveRecord() {
            debugger;
            if (validateSave()) {
                var Patient_ID = $("#hdPatientID").text();
                var Reg_ID = $("#hdRegID").val();
                var Bill_ID = $("#hdnBillID").val();
                var remarks = $("#txtRemarks").val();
                var discountDate = $("#txtdiscountdate").val();
                var totalDiscount = $('#txttotaldiscount').val();
                var Total_Amount = $('#lblOutputShow').val();

                var ServiceDiscount = [];
                $('#tblDetails tbody tr').each(function (key, value) {
                    var Bill_Detail_ID = $(this).find('td:eq(1)').text();
                    var Item_ID = $(this).find('td:eq(2)').text();
                    var Item_Name = $(this).find('td:eq(3)').text();
                    var Original_Amount = $(this).data('original-amount');
                    var Discount_Percentage = $(this).find('input[name="DisPer"]').val() || '0';
                    var Discount_Amount = $(this).find('input[name="DisAmount"]').val() || '0';
                    var Net_Amount = parseFloat(Original_Amount) - parseFloat(Discount_Amount);

                    var Item_Type = "Service"; // You can modify this logic based on your needs

                    ServiceDiscount.push({
                        Bill_Detail_ID: parseInt(Bill_Detail_ID),
                        Item_ID: parseInt(Item_ID),
                        Item_Name: Item_Name,
                        Item_Type: Item_Type,
                        Original_Amount: parseFloat(Original_Amount),
                        Discount_Percentage: parseFloat(Discount_Percentage),
                        Discount_Amount: parseFloat(Discount_Amount),
                        Net_Amount: Net_Amount
                    });
                });
                debugger;
                var data = {
                    Patient_ID: parseInt(Patient_ID),
                    Reg_ID: parseInt(Reg_ID),
                    DiscountDate: discountDate,
                    remarks: remarks,
                    Bill_Id: parseInt(Bill_ID),
                    Total_Discount: parseFloat(totalDiscount),
                    Total_Amount: parseFloat(Total_Amount),
                    ServiceDiscount: ServiceDiscount
                };

                PageMethods.SaveDiscount(JSON.stringify(data), function (res) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Discount Successfully Saved',
                        timer: 2500
                    });
                    setTimeout(function () { window.location.reload(); }, 2500);
                    $('#btnSave').attr('disabled', 'disabled');
                }, function (error) {
                    alert(error.get_message());
                });
            }
        }

        // =============================================
        //  VALIDATE BEFORE SAVE
        // =============================================
        function validateSave() {
            var proceed = true;

            $('#tblDetails tbody tr').each(function (index) {
                var originalAmount = parseFloat($(this).data('original-amount')) || 0;
                var discountAmount = parseFloat($(this).find('input[name="DisAmount"]').val()) || 0;

                if (discountAmount > originalAmount) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Invalid Discount!',
                        text: 'Discount cannot be greater than Net Amount for row ' + (index + 1)
                    });
                    proceed = false;
                    return false; // break $.each
                }
            });

            return proceed;
        }

        // =============================================
        //  UTILITY
        // =============================================
        function ReplaceNullWith_Space(Data) {
            if (Data == "null" || Data == null)
                return " ";
            else
                return Data;
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">

        <input type="hidden" id="hdPatientID" />
        <input type="hidden" id="hdnBillID" />
        <input type="hidden" id="hdRegID" />

        <%-- ======================== PATIENT INFO ROW ======================== --%>
        <div class="row">

            <%-- Left card: image + basic info + bill search --%>
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row">
                            <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                                <div class="image-container">
                                    <img src="../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/billing2.png"
                                        alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                                </div>
                            </div>
                            <div class="col-lg-8 col-md-7 col-sm-6">
                                <div class="row mb-3">
                                    <div class="col-lg-4 col-md-5 col-sm-6"><label>Bill No:</label></div>
                                    <div class="col-lg-8 col-md-7 col-sm-6">
                                        <input type="text" id="txtBillNo" class="form-control" />
                                    </div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-4 col-md-5 col-sm-6"><label>Patient Name :</label></div>
                                    <div class="col-lg-8 col-md-7 col-sm-6"><label id="lblPatienName"></label></div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-4 col-md-5 col-sm-6"><label>Contact No :</label></div>
                                    <div class="col-lg-8 col-md-7 col-sm-6"><label id="lblContactNo"></label></div>
                                </div>
                                <div class="row mb-3">
                                    <div class="col-lg-4 col-md-5 col-sm-6"><label>Reg. Date :</label></div>
                                    <div class="col-lg-8 col-md-7 col-sm-6"><label id="lblRegDate"></label></div>
                                </div>
                               
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Right card: additional patient details --%>
            <div class="col-lg-5 col-md-5 col-sm-12">
                <div class="card">
                    <div class="card-body">
                        <div class="row mb-3">
                            <div class="col-lg-4"><label>Age Years :</label></div>
                            <div class="col-lg-8"><label id="lblAgeYears"></label></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4"><label>Address :</label></div>
                            <div class="col-lg-8"><label id="lblAddress"></label></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4"><label>Patient Category :</label></div>
                            <div class="col-lg-8"><label id="lblPatientCategory"></label></div>
                        </div>
                        <div class="row mb-3">
                            <div class="col-lg-4"><label>Department :</label></div>
                            <div class="col-lg-8"><label id="lblDepartment"></label></div>
                        </div>
                         <div class="row mb-3">
                             <div class="col-lg-4 col-md-5 col-sm-6"><label>Gender :</label></div>
                             <div class="col-lg-8 col-md-7 col-sm-6"><label id="lblGender"></label></div>
                         </div>
                   
                        <div class="row mb-3" style="display:none">
                            <div class="col-lg-4"><label>MR No *:</label></div>
                            <div class="col-lg-8"><label id="lblMRNo"></label></div>
                        </div>
                    </div>
                </div>
            </div>

            <%-- Search button --%>
            <div class="col-lg-1 col-md-2 col-sm-6">
                <input type="button" value="Search" id="btnSearch" class="btn btn-primry mt-4"
                    onclick="GetPatientDetailByBill()" />
            </div>

        </div>
        <%-- END PATIENT INFO ROW --%>

        <%-- ======================== DATE + REMARKS ======================== --%>
        <div class="row mt-3">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label>Discount Date :</label>
                <input type="text" id="txtdiscountdate" class="form-control" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label>Remarks:</label>
                <textarea id="txtRemarks" class="form-control" style="height:35px"></textarea>
            </div>
        </div>

    
        <div class="row mt-3">
            <div class="col-12 table-responsive">
                <table id="tblDetails" class="table table-bordered">
                    <thead>
                        <tr>
                            <th style="display:none">Patient ID</th>
                            <th style="display:none">Bill Detail ID</th>
                            <th style="display:none">Item ID</th>
                            <th>Item Name</th>
                            <th>Existing Discount Amount</th>
                            <th>Net Amount</th>
                            <th>Discount %</th>
                            <th>Discount Amount</th>
                        </tr>
                    </thead>
                    <tbody></tbody>
                </table>
            </div>
        </div>

   
        <div class="row mt-3">
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label class="summary-label">Total Received Amount:</label>
                <input type="text" id="txtReceivedAmount" class="form-control" readonly />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label class="summary-label">Total Discount %:</label>
                <input type="text" id="txtDisPer" class="form-control" value="0" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label class="summary-label">Total Discount Amount:</label>
                <input type="text" id="txttotaldiscount" disabled="disabled" class="form-control" value="0" />
            </div>
            <div class="col-lg-3 col-md-4 col-sm-6">
                <label class="summary-label">Net Payable Amount:</label>
                   <input type="text" id="lblOutputShow" disabled="disabled" class="form-control" value="0" />
                
            </div>
        </div>


        <div class="row mt-3">
            <div class="col-lg-8 col-md-6 col-sm-6">
                 <div class="col-lg-2">
     <input type="button" value="Save Discount" id="btnSave" class="btn btn-primry"
         onclick="SaveRecord()" />
 </div>
 <div class="col-lg-2">
     <input type="button" value="Print" id="btnPrint" class="btn btn-primry"
         onclick="PrintRefund()" />
 </div>
            </div>
           
        </div>

    </div>
</asp:Content>
