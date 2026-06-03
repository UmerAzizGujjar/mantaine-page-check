<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Share_Distribution.aspx.cs" Inherits="PMS.Modules.Billing.Share_Distribution" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Refund.css" rel="stylesheet" />
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">

        $(document).ready(function () {
            $("#txtDistributuionDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtDistributuionDate").val($.datepicker.formatDate('mm/dd/yy', new Date()));
            getAccounts();
            LoadDetailDoctor()
            GetIPDAccounts()
            $("#btnApprove").hide()
            var Dist_ID = '<% =Request.QueryString["ID"] %>';
            if (Dist_ID != "") {
                LoadDistributionHead(Dist_ID)
            }


            $(document).on('keyup', '.disc-perc', function () {
                var perc = parseFloat($(this).val()) || 0;
                var shareableIncome = parseFloat($('#txtShareableIncome').val()) || 0;
                var row = $(this).closest('tr');
                var discAmount = (shareableIncome * perc) / 100;
                row.find('.net-amount').val(discAmount.toFixed(2));
                CalculateRemainingIPDShare();
            });
        });

        // Calculate remaining share and assign it to IPD SHARE row
        function CalculateRemainingIPDShare() {

            var shareableIncome = parseFloat($('#txtShareableIncome').val()) || 0;
            var distributedAmount = 0;
            var ipdRow = null;

            $('#tblDoctorShareDetails tbody tr').each(function () {

                var row = $(this);
                var accountName = row.find('#Account_Name').val()?.trim().toUpperCase();

                var netAmount = parseFloat(
                    row.find('.net-amount').val()
                ) || 0;

                // Save IPD SHARE row separately
                if (accountName === 'IPD SHARE') {
                    ipdRow = row;
                }
                else {
                    // Sum all doctor shares except IPD SHARE
                    distributedAmount += netAmount;
                }
            });

            // Remaining amount
            var remainingAmount = shareableIncome - distributedAmount;

            if (remainingAmount < 0) {
                remainingAmount = 0;
            }

            // Assign remaining amount to IPD SHARE row
            if (ipdRow) {
                ipdRow.find('.net-amount').val(remainingAmount.toFixed(2));
            }
        }
        function LoadDistributionHead(Dist_ID) {
            var id = Dist_ID
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/LoadDistributionHead",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    var TrnsDate = new Date(parseInt(parse[0].Distribution_Date.substr(6)));
                    TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                    var BillId = parse[0].Bill_Id
                    var Voucher_Status = parse[0].Voucher_Status
                    $("#txtDistributuionDate").val(TrnsDate);
                    $("#txtRemarks").val(parse[0].Remarks);
                    $("#hdBillID").val(BillId); 
                    $("#hdPatientID").val(parse[0].Patient_Id);
                    if (Voucher_Status != "Approved") {
                        $("#btnApprove").show()
                    }
                    

                    var Dist_ID = '<% =Request.QueryString["ID"] %>';
                    GetPatientDetailByBillID(BillId)
                    LoadDistributionDetail(Dist_ID)
                    LoadIPDDistributionShare(Dist_ID)
                    $("#btnSave").val("Update")
                }

            });
        }

        function LoadIPDDistributionShare(Dist_ID) {
            var id = Dist_ID
            PageMethods.LoadIPDDistributionShare(id, function (resp) {

                var data = JSON.parse(resp);
                var rows = '';

                $.each(data, function (key, value) {

                    rows += `
                            <tr>
                                <td style="text-align:center;">
                                    <input type="hidden" name="Account_ID" value="${value.Account_Id}">
                                    <input type="text" name="Account_Code" value="${value.Account_Code}" readonly>
                                </td>
                            
                                <td style="text-align:center;">
                                    <input type="text" name="Account_Name" value="${value.Share_Account_Name}" readonly>
                                </td>
                            
                                <td style="text-align:center;">
                                    <input type="number" class="form-control total-amount"
                                           name="txtRevenuAmount" value="${value.Total_Amount}">
                                </td>
                            
                                <td style="text-align:center;">
                                    <input type="number" class="form-control disc-perc"
                                           name="txtRevenuDiscPer" value="${value.Discount_Percentage}">
                                </td>
                            
                                <td style="text-align:center;">
                                    <input type="number" class="form-control disc-amount"
                                           name="txtRevenuDiscAmount" value="${value.Discount_Amount}">
                                </td>
                            
                                <td style="text-align:center;">
                                    <input type="number" class="form-control net-amount"
                                           name="txtRevenuNetAmount" value="${value.Net_Amount}">
                                </td>
                            </tr>`;
                });
                $('#tblDoctorShareDetails tbody')
                    .empty()
                    .append(rows);
            });
        }
        var shareableIncomes = 0;
        function LoadDistributionDetail(Dist_ID) {

            PageMethods.LoadDistributionDetail(Dist_ID, function (resp) {

                var data = JSON.parse(resp);
                var rows = '';

                $.each(data, function (key, value) {
                    debugger;
                    var options = Account.replace(
                        `value="${value.Account_Id}"`,
                        `value="${value.Account_Id}" selected`
                    );
                    if (value.Share_Calculation === 'IPD REVENUE') {
                        shareableIncomes = value.Net_Amount;
                        $('#txtShareableIncome').val(shareableIncomes)
                    }

                    rows += `
                    <tr>
                        <td>
                            <select id="ddlGlAccounts${key}" name="ddlGlAccounts" data-account="${value.Account_Id}">
                                ${options}
                            </select>
                        </td>
                        <td style="text-align:center;">
                            <input type="text" name="txtDescription" readonly value="${value.Share_Calculation}">
                        </td>
                        <td style="text-align:center;">
                            <input type="text" readonly name="txtTotalAmount" value="${value.Total_Amount}">
                        </td>
                        <td style="text-align:center;">
                            <input type="text" readonly name="txtDiscountPer" value="${value.Discount_Percentage}">
                        </td>
                        <td style="text-align:center;">
                            <input type="text" readonly name="txtDiscountAmount" value="${value.Discount_Amount}">
                        </td>
                        <td style="text-align:center;">
                            <input type="text" readonly name="txtNetAmount" value="${value.Net_Amount}">
                        </td>
                    </tr>`;
                });

                $('#tblDetails tbody').empty().append(rows);

            });
        }

        function CalculateRemainingIPDRevenue() {

            debugger;

            var totalDistributed = 0;
            var ipdamt = 0;

            // Sum all appended custom row amounts
            $('#tblDetails tbody tr.custom-share-row').each(function () {

                var amount = parseFloat(
                    $(this).find('.distribution-amount').val()
                ) || 0;

                totalDistributed = amount;
            });

            // Get original IPD REVENUE amount
            $('#tblDetails tbody tr').each(function () {

                var description = $(this)
                    .find('input[name="txtDescription"]')
                    .val();

                if (description &&
                    description.toUpperCase() === 'IPD REVENUE') {

                    ipdamt = parseFloat(
                        $(this)
                            .find('input[name="txtNetAmount"]')
                            .val()
                    ) || 0;
                }
            });

            // Remaining amount
            var remaining = ipdamt - totalDistributed;

            if (remaining < 0) {
                remaining = 0;
            }

            // Update IPD REVENUE row
            $('#tblDetails tbody tr').each(function () {

                var description = $(this)
                    .find('input[name="txtDescription"]')
                    .val();

                if (description &&
                    description.toUpperCase() === 'IPD REVENUE') {

                    $(this)
                        .find('input[name="txtTotalAmount"]')
                        .val(remaining.toFixed(2));

                    $(this)
                        .find('input[name="txtNetAmount"]')
                        .val(remaining.toFixed(2));
                }
            });
            $("#txtShareableIncome").val(remaining.toFixed(2))
        }
        function AddDistributionRow() {
            debugger;
            var description = $('#IPD_Discription').val();
            var amount = parseFloat($('#Dist_Amount').val()) || 0;

            if (description == '') {
                alert('Please Enter Description');
                return;
            }

            var rowCount = $('#tblDetails tbody tr').length;

            var row = `
        <tr class="custom-share-row">

            <td>
                <select id="ddlGlAccounts${rowCount}" name="ddlGlAccounts">
                    ${Account}
                </select>
            </td>

            <td style="text-align:center;">
                <input type="text"
                       class="form-control"
                       name="txtDescription"
                       value="${description}"
                       readonly>
            </td>

            <td style="text-align:center;">
                <input type="number"
                       class="form-control distribution-amount"
                       name="txtNetAmount"
                       value="${amount}"
                       readonly>
            </td>

            <td style="text-align:center;">
                <input type="number"
                       class="form-control distribution-amount"
                       name="txtNetAmount"
                       value="0"
                       readonly>
            </td>

            <td style="text-align:center;">
                <input type="number"
                       class="form-control distribution-amount"
                       name="txtNetAmount"
                       value="0"
                       readonly>
            </td>

            <td style="text-align:center;">
                <input type="number"
                       class="form-control distribution-amount"
                       name="txtNetAmount"
                       value="${amount}"
                       readonly>
            </td>

 

        </tr>
    `;

            $('#tblDetails tbody').append(row);

            // clear controls
            $('#IPD_Discription').val('');
            $('#Dist_Amount').val(0);

            // recalculate remaining IPD revenue
            CalculateRemainingIPDRevenue();
        }
        function GetPatientDetailByBillID(BillId) {
            debugger;
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/LoadPatientDetailsByBillID",
                data: JSON.stringify({
                    "BillId": BillId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess ,

            });
        }
        function OnSuccess(data) {
            debugger;
            var parse = JSON.parse(data.d);
            debugger;
            $('#hdPatientID').text(parse[0].Patient_ID);
            $('#hdBillID').text(parse[0].bill_ID);
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

        function PrintShareDistribution() {
            var Bill_ID = $("#hdBillID").val();

            //if (!Bill_ID || Bill_ID == '') {
            //    Swal.fire({
            //        icon: 'warning',
            //        title: 'Warning!',
            //        text: 'Please search and load a bill first.',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return;
            //}

            var Dist_ID = '<%= Request.QueryString["ID"] %>';

            if (Dist_ID != '') {
                window.open('../../ReportViewer.aspx?ReportName=IPD_Distribution_Bill_Print&ReportTitle=Share Distribution&Bill_ID=' + Bill_ID + '&Dist_ID=' + Dist_ID);
            } else {
                window.open('../../ReportViewer.aspx?ReportName=IPD_Distribution_Bill_Print&ReportTitle=Share Distribution&Bill_ID=' + Bill_ID);
            }
        }

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
                success: OnSuccess,
            });
            
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/LoadDistributionDetailsByBillNO",
                data: JSON.stringify({ "Bill_No": Bill_No }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;

                    var parse = JSON.parse(response.d);
                    var rows = '';
                    var shareableIncome = $('#txtShareableIncome').val() || 0;

                    for (var i = 0; i < parse.length; i++) {
                        var netAmount = parse[i].Net_Amount;
                        if (parse[i].Description === 'IPD REVENUE') {
                            shareableIncome = netAmount;
                            $('#txtShareableIncome').val(shareableIncome)
                        }
                        rows += `
                <tr>
                    <td>
                        <select id="ddlGlAccounts${i}" name="ddlGlAccounts">
                            ${Account}
                        </select>
                    </td>
                    <td style="text-align:center;">
                        <input type="text" id="txtDescription" name="txtDescription" readonly value="${parse[i].Description}">
                    </td>
                    <td style="text-align:center;">
                        <input type="text" readonly id="txtTotalAmount" name="txtTotalAmount" value="${parse[i].Total_Amount}">
                    </td>
                    <td style="text-align:center;">
                        <input type="text" readonly id="txtDiscountPer" name="txtDiscountPer" value="${parse[i].Discount_Percentage}">
                    </td>
                    <td style="text-align:center;">
                        <input type="text" readonly id="txtDiscountAmount" name="txtDiscountAmount" value="${parse[i].Discount_Amount}">
                    </td>
                    <td style="text-align:center;">
                        <input type="text" readonly id="txtNetAmount" name="txtNetAmount" value="${netAmount}">
                    </td>
                </tr>`;
                    }

                    $('#tblDetails tbody').empty();
                    $('#tblDetails tbody').append(rows);
                }
            });

        }

        function LoadDetailDoctor() {
            debugger;
            var options = '<option value="0">Select Doctor</option>';
            $.ajax({
                type: "post",
                url: "Share_Distribution.aspx/GetDoctors",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    debugger;
                    $.each(JSON.parse(response.d), function (key, value) {

                        options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                    });
                    Doctors = options;
                    $('#ddlDoctor').html(options);
                    $('#ddlDoctor').select2();
                },
                failure: function (response) {
                    alert("Error!!!");
                }
            });
        }
        var Account = '';
        function getAccounts() {
            $.ajax({
                url: 'Share_Distribution.aspx/filldropdowns',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '<option value="0">Please Select</option>';
                    let data = JSON.parse(response.d);
                    $.each(data, function (key, value) {
                        options += `<option value="${value.Account_ID}">${value.Account_Code} - ${value.Account_Name}</option>`;
                    });
                    $('#ddlGlAccounts').html(options);
                    $('#ddlGlAccounts').select2();
                    Account = options
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching accounts:', error);
                    callback('<option value="0">Error</option>');
                }
            });
        }

        function GetIPDAccounts() {
            $.ajax({
                url: 'Share_Distribution.aspx/fillIpddropdowns',
                type: 'POST',
                data: JSON.stringify({
                    
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '';
                    let data = JSON.parse(response.d);
                    $.each(data, function (key, value) {
                         options += `<option value="${value.Account_ID}">${value.Account_Code} - ${value.Account_Name}</option>`;
                    });
                    $('#ddlIpdAccount').html(options);
                    $('#ddlIpdAccount').select2();
                    $('#ddlIpdAccount').prop('disabled', false);
                },
            });
        }

        function GetDocAccounts() {
            var doc_id = $('#ddlDoctor').val();
            $.ajax({
                url: 'Share_Distribution.aspx/fillDocdropdowns',
                type: 'POST',
                data: JSON.stringify({
                    "doc_id": doc_id
                }),
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    let options = '';
                    let data = JSON.parse(response.d);
                    $.each(data, function (key, value) {
                        options += `<option value="${value.Account_ID}">${value.Account_Code} - ${value.Account_Name}</option>`;
                    });
                    $('#ddlGlDocAccounts').html(options);
                    $('#ddlGlDocAccounts').select2();
                },
            });
        }
        debugger;
        function GenerateIPDRows() {
            debugger;

            var accountId = $('#ddlIpdAccount').val();
            var IPDShare = $('#IPD_Share').val();
            var fullAccountText = $('#ddlIpdAccount option:selected').text();

            if (!IPDShare || !accountId) {
                alert('Please select both Doctor and Account');
                return;
            }
            var parts = fullAccountText.split('-');
            var accountCode = parts[0].trim();
            var accountName = parts.length > 1 ? parts[1].trim() : '';
            var row = `
            <tr>
                <td style="text-align:center;"><input type="hidden" id="Account_ID" name="Account_ID" value="${accountId}"><input type="text" id="Account_Code" name="Account_Code" value="${accountCode}" readonly></td>
                <td style="text-align:center;"><input type="text" id="Account_Name" name="Account_Name" value="${accountName}" readonly></td>
                <td style="text-align:center;">
                    <input type="number" class="form-control total-amount" id="txtRevenuAmount" name="txtRevenuAmount" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control disc-perc" id="txtRevenuDiscPer"  name="txtRevenuDiscPer" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control disc-amount" id="txtRevenuDiscAmount"  name="txtRevenuDiscAmount" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control net-amount" id="txtRevenuNetAmount"  name="txtRevenuNetAmount" value="${IPDShare}" >
                </td>
            </tr>
        `;

            $('#tblDoctorShareDetails tbody').append(row);
        }

        debugger;
        function GenerateRows() {

            var doctorId = $('#ddlDoctor').val();
            var doctorText = $('#ddlDoctor option:selected').text();

            var accountId = $('#ddlGlDocAccounts').val();
            var fullAccountText = $('#ddlGlDocAccounts option:selected').text();

            if (!doctorId || !accountId) {
                alert('Please select both Doctor and Account');
                return;
            }
            var parts = fullAccountText.split('-');
            var accountCode = parts[0].trim();
            var accountName = parts.length > 1 ? parts[1].trim() : '';
            var row = `
            <tr>
                <td style="text-align:center;"><input type="hidden" id="Account_ID" name="Account_ID" value="${accountId}"><input type="text" id="Account_Code" name="Account_Code" value="${accountCode}" readonly></td>
                <td style="text-align:center;"><input type="text" id="Account_Name" name="Account_Name" value="${doctorText}" readonly></td>
                <td style="text-align:center;">
                    <input type="number" class="form-control total-amount" id="txtRevenuAmount" name="txtRevenuAmount" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control disc-perc" id="txtRevenuDiscPer"  name="txtRevenuDiscPer" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control disc-amount" id="txtRevenuDiscAmount"  name="txtRevenuDiscAmount" value="0">
                </td>
                <td style="text-align:center;">
                    <input type="number" class="form-control net-amount" id="txtRevenuNetAmount"  name="txtRevenuNetAmount" value="0" readonly>
                </td>
            </tr>
        `;
            $('#tblDoctorShareDetails tbody').append(row);
        }
        debugger;
        function SaveRecord() {       
                debugger;
                var Patient_ID = $("#hdPatientID").text();
                var Bill_ID = $("#hdBillID").text();
                var remarks = $("#txtRemarks").text();
                var Distributuion_Date = $("#txtDistributuionDate").val();
                var IPD_Revenue = $("#txtShareableIncome").val();
                var saveVal = $('#btnSave').val();
            var Distribution_Id = '<% =Request.QueryString["ID"] %>'
            if (Distribution_Id == "") {
                Distribution_Id = 0;
            }
                var DepartmentDistribution = [];
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    var Account_ID = $(value).find('select[name="ddlGlAccounts"]').val();
                    var txtDescription = $(value).find('input[name="txtDescription"]').val();
                    var txtTotalAmount = $(value).find('input[name="txtTotalAmount"]').val();
                    var txtDiscountPer = $(value).find('input[name="txtDiscountPer"]').val();
                    var txtDiscountAmount = $(value).find('input[name="txtDiscountAmount"]').val();
                    var txtNetAmount = $(value).find('input[name="txtNetAmount"]').val();
                   // var Item_ID = document.getElementById('tblDetails').rows[key + 1].cells[2].innerText;
                    DepartmentDistribution.push({
                        Account_ID: Account_ID, IPD_Revenue: IPD_Revenue, txtDescription: txtDescription, txtTotalAmount: txtTotalAmount, txtDiscountPer: txtDiscountPer, txtDiscountAmount: txtDiscountAmount, txtNetAmount: txtNetAmount
                    });
                });
                var IPDDistribution = [];
            $.each($('#tblDoctorShareDetails tbody tr'), function (key, value) {
                    debugger;
                    var Account_ID = $(value).find('input[name="Account_ID"]').val();
                    var Account_Name = $(value).find('input[name="Account_Name"]').val();
                    var txtRevenuAmount = $(value).find('input[name="txtRevenuAmount"]').val();
                    var txtRevenuDiscPer = $(value).find('input[name="txtRevenuDiscPer"]').val();
                    var txtRevenuDiscAmount = $(value).find('input[name="txtRevenuDiscAmount"]').val();
                    var txtRevenuNetAmount = $(value).find('input[name="txtRevenuNetAmount"]').val();

                    IPDDistribution.push({
                        Account_ID: Account_ID, Account_Name: Account_Name, txtRevenuAmount: txtRevenuAmount, txtRevenuDiscPer: txtRevenuDiscPer, txtRevenuDiscAmount: txtRevenuDiscAmount, txtRevenuNetAmount: txtRevenuNetAmount
                    });
                });
            var data = { Distribution_Id: Distribution_Id,Patient_ID: Patient_ID, Bill_ID: Bill_ID, Distributuion_Date: Distributuion_Date, remarks: remarks, DepartmentDistribution: DepartmentDistribution, IPDDistribution: IPDDistribution };

            if (saveVal == "Save") {

                PageMethods.CheckBillExist(Bill_ID, function (res) {
                    debugger;
                    if (res == true) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Distribution Against This Bill Already Exist',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $('#btnSave').attr('disabled', 'disabled');
                        return false;
                    }
                    else {
                        PageMethods.SaveDistribution(JSON.stringify(data), function (res) {
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
                })
            }
            else {
                PageMethods.Update(JSON.stringify(data), function (res) {
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
        function Approve() {
            debugger;

            var BillId = '<%= Request.QueryString["ID"] %>';

            PageMethods.approve_Bill(BillId, function (response) {
                debugger;

                var result = JSON.parse(response);

                if (result.Status === true) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: result.Message,
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    location.reload();
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: result.Message,
                        confirmButtonText: 'OK'
                    });
                }
            },
                function (error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: error.get_message(),
                        confirmButtonText: 'OK'
                    });
                });
        }

            <%--function Approve() {
                debugger;
               
                var BillId = '<% =Request.QueryString["ID"] %>';
                PageMethods.approve_Bill(BillId, function (Tests) {
                 debugger
                 var message = JSON.parse(Tests);
                 if (message[0].Message != null || message[0].Message != "") {
                     Swal.fire({
                         icon: 'success',
                         title: 'Success!',
                         text: message[0].Message,
                         showConfirmButton: false,
                         timer: 2500,
                         customClass: {
                             popup: 'swal-big-popup',
                             title: 'swal-big-title',
                             htmlContainer: 'swal-big-text'
                         }
                     });
                     //alert(message[0].Message);
                     location.reload();
                 }
             });
         }--%>
    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container-fluid">
    <input type="hidden" id="hdPatientID" />
    <input type="hidden" id="hdBillID" />
    <div class="row">
<!-- Left Card -->
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

            <div class="col-lg-2 col-md-6 col-sm-6">
              <input type="text" id ="IPD_Discription"/>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
              <input type="text" id ="Dist_Amount"/>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" onclick="AddDistributionRow();" class="btn-primry" value="+" id="generateRowsss" />
            </div>

        </div>
        <div class="row">
            <div class="col-lg-12 col-md-6 col-sm-6" style="margin-top: 2%">
                <div class="table-responsive" style="height: 250px;">
                    <table class="table table-borderless" id="tblDetails">
                        <thead>
                            <tr>
                                <th style="text-align: center; width: 20%;">Account</th>
                                <th style="text-align: center; width: 20%;">Description</th>
                                <th style="text-align: center; width: 15%;">Total Amount</th>
                                <th style="text-align: center; width: 15%;">Disc Percentage</th>
                                <th style="text-align: center; width: 15%;">Disc Amount</th>
                                <th style="text-align: center; width: 15%;">Net Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="row" style="background-color: #000000;">
            <div class="col-lg-5 col-md-6 col-sm-6"></div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <h4 style="color:aliceblue">Net Sharable Income</h4>
            </div>

            <div class="col-lg-1 col-md-6 col-sm-6">
                <input type="text" id="txtShareableIncome" name="txtShareableIncome" value="0" readonly style="margin-top: 8px;" />
            </div>
            <div class="col-lg-4 col-md-6 col-sm-6"></div>
        </div>

                <div class="row" style="margin-top: 10px;" >

            <div class="col-lg-2 col-md-6 col-sm-6">
                <select id="ddlIpdAccount" >
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
              <input type="text" id ="IPD_Share"/>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" onclick="GenerateIPDRows();" class="btn-primry" value="Add IPD Revenue" id="generateRowss" />
            </div>
        </div>
        <div class="row" style="margin-top: 10px;" >

            <div class="col-lg-2 col-md-6 col-sm-6">
                <select id="ddlDoctor" onchange="GetDocAccounts()">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <select id="ddlGlDocAccounts">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" onclick="GenerateRows();" class="btn-primry" value="Add Doctor" id="generateRows" />
            </div>
        </div>

        <div class="row">
            <div class="col-lg-12 col-md-6 col-sm-6" style="margin-top: 2%">
                <div class="table-responsive" style="height: 250px;">
                    <table class="table table-borderless" id="tblDoctorShareDetails">
                        <thead>
                            <tr>
                                <th style="text-align: center; width: 20%;">Account</th>
                                <th style="text-align: center; width: 20%;">Doctor </th>
                                <th style="text-align: center; width: 15%;">Total Amount</th>
                                <th style="text-align: center; width: 15%;">Disc Percentage</th>
                                <th style="text-align: center; width: 15%;">Disc Amount</th>
                                <th style="text-align: center; width: 15%;">Net Amount</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

    </div>

    <div class="container-fluid">
        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" id="btnSave" onclick="SaveRecord();" class="btn btn-primry" value="Save" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" class="btn btn-gray" value="List View" onclick="window.open('Share_Distribution_List.aspx')" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" id="" class="btn btn-primry" value="New" onclick="window.location = 'Share_Distribution.aspx'" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" id="btnApprove" class="btn btn-primry" value="Approve" onclick="Approve()" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-6">
                <input type="button" id="btnPrint" class="btn btn-primry" value="Print" onclick="PrintShareDistribution();" />
            </div> 

        </div>
    </div>
</asp:Content>
