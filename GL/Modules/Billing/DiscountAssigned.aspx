<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountAssigned.aspx.cs" Inherits="PMS.Modules.Billing.DiscountAssigned" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/discount-assigned.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">

        // =============================================
        //  PAGE READY
        // =============================================
        $(document).ready(function () {
            $('#btnApprove').hide();
            $("#txtdiscountdate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtdiscountdate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
            LoadTokenInputsDefaultMRNo();

            var discountAssignID = '<% =Request.QueryString["Discount_Assign_ID"] %>';
            if (discountAssignID != "") {
                LoadDiscountForEdit(discountAssignID);
            }

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

        function LoadDiscountForEdit(discountAssignID) {
            $.ajax({
                type: "POST",
                url: "DiscountAssigned.aspx/GetDiscountDataForEdit",
                data: JSON.stringify({ Discount_Assign_ID: discountAssignID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Full response:", response);
                    if (response.d && response.d.indexOf("error") > -1) {
                        var errorData = JSON.parse(response.d);
                        if (errorData.error) {
                            Swal.fire({ title: "Error!", text: errorData.error, icon: "error" });
                            return;
                        }
                    }

                    var data = JSON.parse(response.d);
                    console.log("Parsed data:", data);

                    if (data.Master) {
                        $('#hdPatientID').text(data.Master.Patient_ID || '');
                        $('#hdnBillID').val(data.Master.Bill_ID || '');
                        $('#hdRegID').val(data.Master.Reg_ID || '');
                        $('#hdnDiscountAssignID').val(data.Master.Discount_Assign_ID || '');

                        if (data.Patient) {
                            $('#lblMRNo').text(ReplaceNullWith_Space(data.Patient.Patient_No));
                            $('#lblPatienName').text(ReplaceNullWith_Space(data.Patient.Full_Name));
                            $('#lblAgeYears').text(ReplaceNullWith_Space(data.Patient.Age_years));
                            $('#lblGender').text(ReplaceNullWith_Space(data.Patient.Gender));
                            $('#lblAddress').text(ReplaceNullWith_Space(data.Patient.Permanent_Address));
                            $('#lblContactNo').text(ReplaceNullWith_Space(data.Patient.Mobile1));
                            if (data.Patient.Creation_Date) {
                                $('#lblRegDate').text(data.Patient.Creation_Date);
                            }
                        }

                        if (data.Master.Discount_Date) {
                            $('#txtdiscountdate').val(data.Master.Discount_Date);
                        }
                        $('#txtRemarks').val(ReplaceNullWith_Space(data.Master.Remarks));

                        var originalTotalAmount = 0;
                        if (data.BillItems && data.BillItems.length > 0) {
                            for (var i = 0; i < data.BillItems.length; i++) {
                                var netAmount = parseFloat(data.BillItems[i].Net_Amount) || 0;
                                var discountAmount = parseFloat(data.BillItems[i].Discount_Amount) || 0;
                                originalTotalAmount += (netAmount + discountAmount);
                            }
                            $('#txtReceivedAmount').val(originalTotalAmount.toFixed(2));
                            console.log("Original Total Amount:", originalTotalAmount);
                        }

                        var rows = '';
                        if (data.BillItems && data.BillItems.length > 0) {
                            console.log("Number of BillItems:", data.BillItems.length);

                            for (var i = 0; i < data.BillItems.length; i++) {
                                var item = data.BillItems[i];
                                var existingDiscountPer = 0;
                                var existingDiscountAmount = 0;

                                console.log("Processing item:", item.Item_Name);
                                console.log("Bill_Details_ID:", item.Bill_Details_ID);

                                if (data.DiscountItems && data.DiscountItems.length > 0) {
                                    var discountItem = data.DiscountItems.find(d => d.Bill_Detail_ID == item.Bill_Details_ID);
                                    if (discountItem) {
                                        existingDiscountPer = discountItem.Discount_Percentage;
                                        existingDiscountAmount = discountItem.Discount_Amount;
                                        console.log("Found discount - Per:", existingDiscountPer, "Amount:", existingDiscountAmount);
                                    }
                                }

                                var originalAmount = (parseFloat(item.Net_Amount) || 0) + (parseFloat(item.Discount_Amount) || 0);
                                console.log("Original Amount:", originalAmount);

                                rows += '<tr data-original-amount="' + originalAmount + '">' +
                                    '<td style="display:none">' + (item.pat_id || '') + '</td>' +
                                    '<td style="display:none">' + (item.Bill_Details_ID || '') + '</td>' +
                                    '<td style="display:none">' + (item.Item_Id || '') + '</td>' +
                                    '<td style="text-align:center;">' + (item.Item_Name || '') + '</td>' +
                                    '<td style="text-align:center;">' + (parseFloat(item.Discount_Amount) || 0).toFixed(2) + '</td>' +
                                    '<td style="text-align:center;">' + originalAmount.toFixed(2) + '</td>' +  
                                    '<td style="text-align:center;">' +
                                    '<input type="text" name="DisPer" class="form-control percentage-input" value="' + existingDiscountPer.toFixed(2) + '" />' +
                                    '</td>' +
                                    '<td style="text-align:center;">' +
                                    '<input type="text" name="DisAmount" class="form-control discount-input" value="' + existingDiscountAmount.toFixed(2) + '" />' +
                                    '</td>' +
                                    '</td>';
                            }
                        } else {
                            console.warn("No BillItems found!");
                            rows = '<tr><td colspan="8" style="text-align:center;">No items found for this bill</td></tr>';
                        }

                        $('#tblDetails tbody').empty();
                        $('#tblDetails tbody').append(rows);
                        console.log("Table populated with", $('#tblDetails tbody tr').length, "rows");

                        var totalDiscountAmount = parseFloat(data.Master.Total_Discount) || 0;
                        var totalNetAmount = parseFloat(data.Master.Total_amount) || 0;

                        var totalDiscountPercentage = 0;
                        if (originalTotalAmount > 0 && totalDiscountAmount > 0) {
                            totalDiscountPercentage = (totalDiscountAmount / originalTotalAmount) * 100;
                        }

                        $('#txttotaldiscount').val(totalDiscountAmount.toFixed(2));
                        $('#lblOutputShow').val(totalNetAmount.toFixed(2));
                        $('#txtDisPer').val(totalDiscountPercentage.toFixed(2));

                        $('#btnSave').val('Update');
                        enableAllDiscountFields();

                        if (data.Master.File_Path) {
                            $('#ctl00_MainContent_HyperLink1').show();
                            $('#hdnDiscountFilePath').val(data.Master.File_Path);
                            $('#btnDeleteDiscountFile').show();
                        } else {
                            $('#ctl00_MainContent_HyperLink1').hide();
                            $('#btnDeleteDiscountFile').hide();
                        }

                        $.ajax({
                            type: "POST",
                            url: "DiscountAssigned.aspx/GetUserDiscountPermission",
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (resp) {
                                if (resp.d && data.Master.Status !== "Approved") {
                                    $('#btnApprove').show();
                                }
                            }
                        });

                        console.log("Edit mode loaded successfully");
                        console.log("Total Discount Amount:", totalDiscountAmount);
                        console.log("Total Discount Percentage:", totalDiscountPercentage);
                    } else {
                        console.error("No Master data found");
                        Swal.fire({ title: "Error!", text: "No discount data found for ID: " + discountAssignID, icon: "error" });
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error Details:");
                    console.error("Status:", status);
                    console.error("Error:", error);
                    console.error("Response Text:", xhr.responseText);
                    Swal.fire({
                        title: "Error!",
                        text: "Failed to load discount data: " + error + "\nCheck console for details",
                        icon: "error"
                    });
                }
            });
        }

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

    
        function sendFile(ID) {
            var fileInput = $('#choseDiscountFile')[0];
            if (fileInput && fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', fileInput.files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadDiscountAssignFiles.ashx',
                    data: data,
                    processData: false,
                    contentType: false,
                    error: function (xhr, status, error) {
                        console.warn('File upload failed:', error);
                    }
                });
            }
        }

        function DeleteDiscountFile() {
            var discountId = $('#hdnDiscountAssignID').val();
            if (!discountId) return;

            Swal.fire({
                title: 'Delete Attachment?',
                text: 'Are you sure you want to remove this file?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, delete it',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "DiscountAssigned.aspx/DeleteDiscountFile",
                        data: JSON.stringify({ Discount_Assign_ID: discountId }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d) {
                                $('#choseDiscountFile').val('');
                                $('#hdnDiscountFilePath').val('');
                                $('#ctl00_MainContent_HyperLink1').hide();
                                $('#btnDeleteDiscountFile').hide();
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Deleted!',
                                    text: 'File has been removed.',
                                    timer: 1500,
                                    showConfirmButton: false
                                });
                            } else {
                                Swal.fire({ icon: 'error', title: 'Error!', text: 'Failed to delete file.' });
                            }
                        },
                        error: function () {
                            Swal.fire({ icon: 'error', title: 'Error!', text: 'Something went wrong.' });
                        }
                    });
                }
            });
        }

        function SaveRecord() {
            $('#btnSave').attr('disabled', true);
            if (validateSave()) {
                var Patient_ID = $("#hdPatientID").text();
                var Reg_ID = $("#hdRegID").val();
                var Bill_ID = $("#hdnBillID").val();
                var remarks = $("#txtRemarks").val();
                var discountDate = $("#txtdiscountdate").val();
                var totalDiscount = $('#txttotaldiscount').val();
                var Total_Amount = $('#lblOutputShow').val();
                var Discount_Assign_ID = $('#hdnDiscountAssignID').val(); 

                var ServiceDiscount = [];
                $('#tblDetails tbody tr').each(function (key, value) {
                    var Bill_Detail_ID = $(this).find('td:eq(1)').text();
                    var Item_ID = $(this).find('td:eq(2)').text();
                    var Item_Name = $(this).find('td:eq(3)').text();
                    var Original_Amount = $(this).data('original-amount');
                    var Discount_Percentage = $(this).find('input[name="DisPer"]').val() || '0';
                    var Discount_Amount = $(this).find('input[name="DisAmount"]').val() || '0';
                    var Net_Amount = parseFloat(Original_Amount) - parseFloat(Discount_Amount);
                    var Item_Type = "Service";

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

                var data = {
                    Discount_Assign_ID: Discount_Assign_ID ? parseInt(Discount_Assign_ID) : 0, // 0 means new record
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
            var savedId = Discount_Assign_ID || res;
            sendFile(savedId);
            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: Discount_Assign_ID ? 'Discount Successfully Updated' : 'Discount Successfully Saved',
                timer: 2000,
                showConfirmButton: false
            });
            setTimeout(function () { window.location = 'DiscountAssigned.aspx?Discount_Assign_ID=' + savedId; }, 2000);
        }, function (error) {
            $('#btnSave').attr('disabled', false);
            Swal.fire({ icon: 'error', title: 'Error!', text: error.get_message() });
        });
            } else {
                $('#btnSave').attr('disabled', false);
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


        function ApproveRecord() {
            $('#btnApprove').attr('disabled', true);

            var Bill_ID = $("#hdnBillID").val();

            if (!Bill_ID || Bill_ID == "0") {
                $('#btnApprove').attr('disabled', false);
                Swal.fire({ title: "Error!", text: "Bill ID is missing", icon: "error" });
                return;
            }

            Swal.fire({
                title: "Confirm Approval",
                text: "This will update Billing, Receipts, and Item Details with the saved discounts. Continue?",
                icon: "warning",
                showCancelButton: true,
                confirmButtonText: "Yes, Approve",
                cancelButtonText: "Cancel"
            }).then((result) => {
                if (result.isConfirmed) {
                    PageMethods.ApproveDiscount(Bill_ID,
                        function (res) {
                            if (res === "Success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Approved!',
                                    text: 'Billing, Receipts, and Item Details updated successfully',
                                    timer: 2000
                                });
                                $('#btnApprove').hide();
                            } else {
                                $('#btnApprove').attr('disabled', false);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: res
                                });
                            }
                        },
                        function (error) {
                            $('#btnApprove').attr('disabled', false);
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: error.get_message()
                            });
                        }
                    );
                }
            });
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="da-page">

        <input type="hidden" id="hdPatientID" />
        <input type="hidden" id="hdnBillID" />
        <input type="hidden" id="hdRegID" />
        <input type="hidden" id="hdnDiscountAssignID" />

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="da-badge"><span class="da-badge-label">Bill No</span><span class="da-badge-value" id="badgeDaBill">---</span></div>
                <div class="da-badge"><span class="da-badge-label">Patient</span><span class="da-badge-value" id="badgeDaPatient">---</span></div>
                <div class="da-badge"><span class="da-badge-label">Net Payable</span><span class="da-badge-value" id="badgeDaNet">0</span></div>
            </div>
        </div>

        <div class="da-layout">

            <%-- Patient + bill search --%>
            <section class="da-card">
                <h5 class="da-card-title"><i class="fa fa-user-circle"></i> Patient Information</h5>
                <div class="da-patient">
                    <div class="da-avatar">
                        <img src="../../../../wwwroot/SOURCE_IMAGES/DASHBOARD_ICONS/billing2.png" alt="Patient Image" />
                    </div>
                    <div class="da-who">
                        <div class="da-name" id="lblPatienName"></div>
                        <div class="da-search">
                            <div class="da-field">
                                <label for="txtBillNo">Bill No</label>
                                <input type="text" id="txtBillNo" class="da-input" autocomplete="off" />
                            </div>
                            <input type="button" value="Search" id="btnSearch" class="btn btn-primry" onclick="GetPatientDetailByBill()" />
                        </div>
                    </div>
                </div>
                <dl class="da-info">
                    <div><dt>Contact No</dt><dd id="lblContactNo"></dd></div>
                    <div><dt>Reg. Date</dt><dd id="lblRegDate"></dd></div>
                    <div><dt>Age Years</dt><dd id="lblAgeYears"></dd></div>
                    <div><dt>Gender</dt><dd id="lblGender"></dd></div>
                    <div><dt>Patient Category</dt><dd id="lblPatientCategory"></dd></div>
                    <div><dt>Department</dt><dd id="lblDepartment"></dd></div>
                    <div class="da-span-all"><dt>Address</dt><dd id="lblAddress"></dd></div>
                    <div style="display:none"><dt>MR No *</dt><dd id="lblMRNo"></dd></div>
                </dl>
            </section>

            <%-- Date, remarks, attachment --%>
            <section class="da-card">
                <h5 class="da-card-title"><i class="fa fa-percent"></i> Discount Details</h5>
                <div class="da-grid da-grid-1">
                    <div class="da-field">
                        <label for="txtdiscountdate">Discount Date</label>
                        <input type="text" id="txtdiscountdate" class="da-input" />
                    </div>
                    <div class="da-field">
                        <label for="txtRemarks">Remarks</label>
                        <textarea id="txtRemarks" class="da-input"></textarea>
                    </div>
                    <div class="da-field">
                        <label for="choseDiscountFile">Attachment</label>
                        <div class="da-attach">
                            <input type="file" id="choseDiscountFile" name="choseDiscountFile" />
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="da-link">
                                <i class="fa fa-download"></i> Download
                            </asp:HyperLink>
                            <a href="#" id="btnDeleteDiscountFile" class="da-del" onclick="DeleteDiscountFile(); return false;" style="display:none;">
                                <i class="fa fa-trash"></i> Delete
                            </a>
                        </div>
                    </div>
                </div>
            </section>
        </div>

        <section class="da-card">
            <h5 class="da-card-title"><i class="fa fa-list"></i> Bill Items</h5>
            <div class="da-table-wrap">
                <table id="tblDetails" class="table da-table">
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

            <div class="da-grid da-summary">
                <div class="da-field da-figure">
                    <label for="txtReceivedAmount">Total Received Amount</label>
                    <input type="text" id="txtReceivedAmount" class="da-input" readonly />
                </div>
                <div class="da-field da-figure">
                    <label for="txtDisPer">Total Discount %</label>
                    <input type="text" id="txtDisPer" class="da-input" value="0" />
                </div>
                <div class="da-field da-figure">
                    <label for="txttotaldiscount">Total Discount Amount</label>
                    <input type="text" id="txttotaldiscount" disabled="disabled" class="da-input" value="0" />
                </div>
                <div class="da-field da-figure da-figure-main">
                    <label for="lblOutputShow">Net Payable Amount</label>
                    <input type="text" id="lblOutputShow" disabled="disabled" class="da-input" value="0" />
                </div>
            </div>
        </section>

        <div class="da-actions">
            <div>
                <input type="button" value="Save" id="btnSave" class="btn btn-primry" onclick="SaveRecord()" />
            </div>
            <div>
                <input type="button" value="Print" id="btnPrint" class="btn btn-primry" onclick="PrintRefund()" />
            </div>
            <div>
                <input type="button" value="New" id="btnnew" class="btn btn-primry" onclick="window.location = 'DiscountAssigned.aspx'" />
            </div>
            <div>
                <input type="button" value="List" id="btnlist" class="btn btn-primry" onclick="window.location = 'DiscountAssignedList.aspx'" />
            </div>
            <div>
                <input type="button" value="Approve" id="btnApprove" class="btn btn-primry" onclick="ApproveRecord()" />
            </div>
        </div>

    </div>

    <script type="text/javascript">
        // title-line badges follow the form (the page script fills the fields in after loading)
        function syncDiscountBadges() {
            $('#badgeDaBill').text($('#txtBillNo').val() || '---');
            $('#badgeDaPatient').text($.trim($('#lblPatienName').text()) || '---');
            $('#badgeDaNet').text($('#lblOutputShow').val() || '0');
        }
        $(function () {
            syncDiscountBadges();
            setInterval(syncDiscountBadges, 600);
        });
    </script>
</asp:Content>
