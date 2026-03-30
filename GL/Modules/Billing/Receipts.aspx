<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Receipts.aspx.cs" Inherits="PMS.Receipts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Receipts.css" rel="stylesheet" />
     <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <script type="text/javascript">
        var TotalBill_Amount = 0;
        var TotalAmount = 0;
        var TotalReceipt_Amount = 0;
        function CountNetAmount() {
            debugger;
            var txtReceiptAmount = $('#txtNetBalance').val();
            var ReceiptAmount = $('#txtReceiptAmount').val();
            if (ReceiptAmount == "")
                ReceiptAmount = 0.00
            var Balance = txtReceiptAmount - ReceiptAmount;
          //  $('#txtNetBalance').val(Balance);
            $('#txtNetReceivable').val(Balance);
        }

        function DischargeCheck() {
            debugger;
            var dd = document.getElementById('chkDischarge').checked;

            if ($('#chkDischarge').is(':checked') == true) {
                $('#DischargeModel').modal({
                    backdrop: 'static'
                });
                var disamount = $('#txtDischargeNetAmount').val();
                if (disamount == "0") {
                    $('#txtDischargeDiscountPercentage').val(0);
                    $('#txtDischargeDiscountAmount').val(0);
                }
                $('#txtDischargeTotalAmount').val(0);
                $('#txtDischargeNetAmount').val(0);

                if (Discharge === true) {
                    GetDischargeServiceDetails(Receipt_ID);
                    GetDischargeInvestigationDetails(Receipt_ID);
                }
                else if (Discharge === false) {
                    GetInvestigationDetails(Patient_ID);
                    UpdateAmount();
                }
            }
        }

        function GetDischargeServiceDetails(Receipt_ID) {
            debugger;
            if (Receipt_ID != 0) {
                PageMethods.GetDischargeServiceDetails(Receipt_ID, function (data) {
                    $('#tblDischarge tbody tr').remove();
                    var rowNo = 0;
                    var InvestigationAmount = 0;
                    $.each(JSON.parse(data), function (key, value) {
                        if (value.Discharge_Test_Date == null) {
                            value.Discharge_Test_Date = "0";
                        }

                        var rowID = $('#tblDischarge tr').length;
                        var rows = '<tr><td>' + rowID + ' </td><td><input type="hidden" name="txtServiceType" id="txtServiceType' + rowID + '"  value="Service"/> <input type="hidden" name="txtServiceID" id="txtServiceID' + rowID + '"  value="' + value.Item_ID + '"/>' + value.Item_Name + '</td><td><input type="text" name="txtQty" id="txtQty' + rowID + '" style="width:  78px !important;" onkeyup="UpdateAmountWithQTy(' + rowID + ')"   value="' + value.Qty + '" /></td><td><input type="text" name="txtServiceAmount" id="txtServiceAmount' + rowID + '" style="width:  89px !important;    height: 28px;" onkeyup="UpdateAmount(' + rowID + ')"   value="' + value.Item_Amount + '"/></td><td><input type="text" name="txtServiceAmount" id="txtServiceAmount' + rowID + '" style="width:  89px !important;    height: 28px;"  disabled="disabled"  value="' + value.Item_NetAmount + '"/></tr>';
                        $('#tblDischarge').append(rows);
                        $('#txtDischargeDiscountPercentage').val(value.Discount_Percentage);
                        $('#txtDischargeDiscountAmount').val(value.Discount_Amount);
                        $('#txtDischargeTotalAmount').val(value.Discharge_Amount);
                        $('#txtDischargeNetAmount').val(value.Net_Amount);
                        Discharge_ID = value.Discharge_ID;
                    });
                });
            }
        }
        function GetDischargeInvestigationDetails(Receipt_ID) {
            PageMethods.GetDischargeInvestigationDetails(Receipt_ID, function (data) {
                $('#tblInvestigationDetails tbody tr').remove();
                var InvestigationAmount = 0;
                var rowNo = 0;
                var InvestigationAmount = 0;
                $.each(JSON.parse(data), function (key, value) {
                    if (value.Discharge_Test_Date == null) {
                        value.Discharge_Test_Date = "0";
                    }
                    else {

                        var TrnsDate = new Date(parseInt(value.Discharge_Test_Date.substr(6)));
                        TrnsDate = moment(TrnsDate).format('L');
                    }
                    var ItemName;

                    if (value.Item_Name != null) {
                        ItemName = value.Item_Name;
                    }
                    else
                        ItemName = value.Group_Name;

                    rowNo = $('#tblInvestigationDetails tr').length;
                    var row = '<tr> <td> ' + parseInt(rowNo) + ' </td> <td><input type="hidden" name="txtDischargeTestDate" id="txtDischargeTestDate" value="' + TrnsDate + '"/>' + TrnsDate + '  </td> <td> <input type="hidden" id="txtTest_ID" name ="txtTest_ID" value="' + value.Item_ID + '"/> <input type="hidden" name="txtParentTransID" id="txtParentTransID" value="' + value.Parent_Trans_ID + '"/>   ' + ItemName + ' </td>  <td> <input type="hidden" name="txtTest_Amount" id="txtTest_Amount" value="' + value.Item_Amount + '"/> ' + value.Item_Amount + ' </td> </tr>';
                    $('#tblInvestigationDetails').append(row);
                    InvestigationAmount += value.Item_Amount;
                    Discharge_ID = value.Discharge_ID;
                    $('#txtInvestigationAvailableLimit').val(value.Investigation_Limit);
                });

                $('#txtInvestigationAmount').val(InvestigationAmount);


                PageMethods.GetInvestigationLimit(Bill_ID, function (data) {

                    var InvestigtionLimit = JSON.parse(data).Amount;
                    $('#txtInvestigationAvailableLimit').val(InvestigtionLimit);
                    if (InvestigationAmount > InvestigtionLimit) {
                        $('#txtInvestigationAmount').prop('disabled', '');
                        $('#txtInvestigationAmount').css('background-color', 'red');
                    }
                    else
                        $('#txtInvestigationAmount').css('background-color', 'white');
                });

            });
        }
        function GetInvestigationDetails(PatientID) {
            debugger;
            PageMethods.GetInvestigationDetails(PatientID, function (data) {
                $('#tblInvestigationDetails tbody tr').remove();
                var rowNo = 0;
                var InvestigationAmount = 0;
                $.each(JSON.parse(data), function (key, value) {
                    var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                    TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                    rowNo = $('#tblInvestigationDetails tr').length;
                    var row = '<tr> <td> ' + parseInt(rowNo) + ' </td> <td><input type="hidden" name="txtDischargeTestDate" id="txtTest_Date" value="' + TrnsDate + '"/>' + TrnsDate + '  </td> <td> <input type="hidden" id="txtTest_ID" name ="txtTest_ID" value="' + value.Item_ID + '"/> <input type="hidden" name="txtParentTransID" id="txtParentTransID" value="' + value.ParentTrans_ID + '"/>   ' + value.Item_Name + ' </td>  <td> <input type="hidden" name="txtTest_Amount" id="txtTest_Amount" value="' + value.Rate + '"/> ' + value.Rate + ' </td> </tr>';
                    $('#tblInvestigationDetails').append(row);
                    InvestigationAmount += value.Rate;
                });

                $('#txtInvestigationAmount').val(InvestigationAmount);


                PageMethods.GetInvestigationLimit(Bill_ID, function (data) {

                    var InvestigtionLimit = JSON.parse(data).Amount;
                    $('#txtInvestigationAvailableLimit').val(InvestigtionLimit);
                    if (InvestigationAmount > InvestigtionLimit) {
                        $('#txtInvestigationAmount').prop('disabled', '');
                        $('#txtInvestigationAmount').css('background-color', 'red');
                    }
                    else
                        $('#txtInvestigationAmount').css('background-color', 'white');
                });

            });
        }

        function FillServiceTypes() {
            var options = '';
            PageMethods.GetServices(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlServiceTypes').html(options);
                $('#ddlServiceTypes').select2();
            });
        }


        function PrintDischargeReport() {
            var contents = $("#PrintDischargeReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }

        function PrintRecieptReport() {
            var contents = $("#PrintRecieptReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
            }, 500);
        }
        function PrintCashReceipt() {
            debugger;
            var RcptID = '<%= Request.QueryString["Receipt_ID"]%>';

            if (Receipt_ID == '') {


            }
            else {
                window.open('../../ReportViewer.aspx?ReportName=ReceiptbasePrint&ReportTitle=Cash  Receipt ' + '&Receipt_ID=' + RcptID);
            }


        }

        function PrintCashReceipfft() {
            debugger;
            var chkdischarge = document.getElementById('chkDischarge').checked;
            var MRNo = $('#txtMRNo').val();
            if (chkdischarge == true) {

                $.ajax({
                    type: "POST",
                    url: "Receipts.aspx/PrintDischargeReceipt",
                    data: JSON.stringify({
                        'Bill_ID': Bill_ID,
                        'MRNo': MRNo,
                        'Receipt_ID': Receipt_ID
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {

                        $('#lblNamedisrpt').text(response.d.Full_Name);
                        $('#lblAgerptdis').text(response.d.Age_years);
                        $('#lblGenderrptdis').text(response.d.Gender);

                        if (response.d.NIC == "") {
                            $('#lblCNICdisrpt').text(".");
                        }
                        else {
                            $('#lblCNICdisrpt').text(response.d.NIC);
                        }

                        if (response.d.Department != null) {
                            $('#lblDepartmentrpt').text(response.d.Department
                            );
                        }
                        else {
                            $('#lblDepartmentrpt').text("");
                        }
                        if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                            $('#lblTyperptdis').text(response.d.Patient_Type);
                        }
                        else {
                            $('#lblTyperptdis').text(".");
                        }
                        $('#lblAddressrptdis').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);


                        if (response.d.ContectNo == "") {
                            $('#lblContactrptdis').text(".");
                        }
                        else {
                            $('#lblContactrptdis').text(response.d.ContectNo);
                        }
                        $('#lvlMRnodis').text(response.d.MR_No);

                        $('#lvlBillnodis').text(response.d.Bill_No);
                        var date = response.d.Bill_Date;
                        var finaldate = moment(date).format('L');
                        $('#lblDateTimerptdis').text(finaldate);
                        debugger;
                        $('#lblTotalPayable').text(CurrencyFormatted(response.d.Total_Amount));

                        $('#lblDiscount').text(CurrencyFormatted(response.d.Discount_Percentage));
                        $('#lblAmount').text(CurrencyFormatted(response.d.Discount_Amount));
                        var totalPayAble = parseInt(response.d.Total_Amount) - parseInt(response.d.Discount_Amount);
                        test_skill(totalPayAble);
                        $('#lblNetPayable').text(CurrencyFormatted(totalPayAble));
                        $('#lblAmountReceived').text(CurrencyFormatted(totalPayAble));
                        var balance = totalPayAble - totalPayAble;
                        $('#lblTotalBalance').text(CurrencyFormatted(balance));

                        if (response.d.Remarks == "") {
                            $('#txtRemarksrpt').text(".");
                        }
                        else {
                            $('#txtRemarksrpt').text(response.d.Remarks);
                        }

                        $('#lblOperatorrptdis').text(response.d.Printed_By);


                        GetDischargeCharges(Receipt_ID, response.d.Total_Amount, response.d.Discount_Amount);

                    },
                    Error: function (x, e) {
                        alert(e)
                    }
                });
            }
            else {

                $.ajax({
                    type: "POST",
                    url: "Receipts.aspx/PrintReceipt",
                    data: JSON.stringify({
                        'ReceiptNo': Receipt_ID,
                        'MRNo': MRNo
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#ctl00_MainContent_lblNamerpt').text(response.d.Full_Name);
                        $('#lblAgerpt').text(response.d.Age_years);
                        $('#lblGenderrpt').text(response.d.Gender);
                        if (response.d.NIC == "") {
                            $('#lblCNICrpt').text(".");
                        }
                        else {
                            $('#lblCNICrpt').text(response.d.NIC);
                        }
                        if (response.d.Department != null) {
                            $('#lblDepartmentrpt').text(response.d.Department
                            );
                        }
                        else {
                            $('#lblDepartmentrpt').text("");
                        }

                        var PatientCategory = $('#lblPatientCategory').text();
                        $('#lblPatientTyperpt').text(PatientCategory);

                        $('#lblAddressrpt').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);
                        if (response.d.ContectNo == "") {
                            $('#lblContactrpt').text(".");
                        }
                        else {
                            $('#lblContactrpt').text(response.d.ContectNo);
                        }
                        $('#lblOperatorrpt').text(response.d.Printed_By);
                        $('#lvlBillno').text(response.d.Bill_No + "-" + response.d.ReceiptNo);
                        $('#lvlReceiptAmount').text(CurrencyFormatted(response.d.Received_Amount));
                        var date = response.d.Bill_Date;
                        var finaldate = moment(date).format('L');
                        $('#lblDateTimerpt').text(finaldate);
                        $('#lvlMRno').text(response.d.MR_No);

                        var admision = $('#lblAddmisionDate').text();
                        if (admision == "")
                            $('#lblAddmisionDaterpt').text(".");
                        else
                            $('#lblAddmisionDaterpt').text(admision);
                        var lblWardNo = $('#lblWardNo').text();
                        var lblBedNo = $('#lblBedNo').text();
                        $('#lblWardNorpt').text(lblWardNo + '/' + lblBedNo);
                        var discharge = $('#lblDischargeDate').text();
                        if (discharge == "" || discharge == undefined || discharge == "undefined")
                            $('#lblDischargeDaterpt').text(".");
                        else
                            $('#lblDischargeDaterpt').text(discharge);
                        var txtReceiptDate = $('#txtReceiptDate').val();
                        $('#txtReceiptDaterpt').text(txtReceiptDate);

                        $('#lblTotalBillrpt').text(CurrencyFormatted(response.d.Total_Amount));
                        var TotalReceiptsAmt = $('#totalReceipt').val();
                        var NetBalance = $('#txtNetBalance').val();
                        var FinalRecieptAmount = (response.d.Total_Amount) - (NetBalance);
                        $('#lblTotalRecieptrpt').text(CurrencyFormatted(FinalRecieptAmount));
                        $('#lblTotalNetBalancerpt').text(CurrencyFormatted(NetBalance));

                        $('#lblOperatorrpt').text(response.d.Printed_By);

                    },
                    Error: function (x, e) {
                        alert(e)
                    }
                });
            }
        }

        function GetDischargeCharges(Receipt_ID, Total_Amount, Discount_Amount) {

            PageMethods.GetDischargeCharges(Receipt_ID, function (res) {
                var Test = JSON.parse(res);
                rows = '';
                var SrNo = 0;

                $.each(Test, function (key, value) {


                    var FinalTotalAmount = parseInt(value.Discharge_Amount) + parseInt(Total_Amount);
                    $('#lblTotalPayable').text(CurrencyFormatted(FinalTotalAmount));
                    var totalDiscount_Amount = parseInt(value.Discount_Amount) + parseInt(Discount_Amount);
                    $('#lblAmount').text(CurrencyFormatted(totalDiscount_Amount));
                    var totalPayAble = parseInt(FinalTotalAmount) - parseInt(totalDiscount_Amount);

                    $('#lblNetPayable').text(CurrencyFormatted(totalPayAble));
                    test_skill(totalPayAble);
                    $('#lblAmountReceived').text(CurrencyFormatted(totalPayAble));

                    var Balnce = totalPayAble - totalPayAble
                    $('#lblTotalBalance').text(CurrencyFormatted(Balnce));
                });
                PrintBillingDetail(Bill_ID);

            });
        }



        function test_skill(Amount) {

            var junkVal = Amount;
            junkVal = Math.floor(junkVal);
            var obStr = new String(junkVal);
            numReversed = obStr.split("");
            actnumber = numReversed.reverse();

            if (Number(junkVal) >= 0) {
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'wrong Number cannot be converted',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (Number(junkVal) == 0) {

                $('#NetPayableInWord').text('Rupees Zero Only');
                return false;
            }
            if (actnumber.length > 9) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Oops!!!! the Number is too big to covertes',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }

            var iWords = ["Zero", " One", " Two", " Three", " Four", " Five", " Six", " Seven", " Eight", " Nine"];
            var ePlace = ['Ten', ' Eleven', ' Twelve', ' Thirteen', ' Fourteen', ' Fifteen', ' Sixteen', ' Seventeen', ' Eighteen', ' Nineteen'];
            var tensPlace = ['dummy', ' Ten', ' Twenty', ' Thirty', ' Forty', ' Fifty', ' Sixty', ' Seventy', ' Eighty', ' Ninety'];

            var iWordsLength = numReversed.length;
            var totalWords = "";
            var inWords = new Array();
            var finalWord = "";
            j = 0;
            for (i = 0; i < iWordsLength; i++) {
                switch (i) {
                    case 0:
                        if (actnumber[i] == 0 || actnumber[i + 1] == 1) {
                            inWords[j] = '';
                        }
                        else {
                            inWords[j] = iWords[actnumber[i]];
                        }
                        inWords[j] = inWords[j] + ' Only';
                        break;
                    case 1:
                        tens_complication();
                        break;
                    case 2:
                        if (actnumber[i] == 0) {
                            inWords[j] = '';
                        }
                        else if (actnumber[i - 1] != 0 && actnumber[i - 2] != 0) {
                            inWords[j] = iWords[actnumber[i]] + ' Hundred and';
                        }
                        else {
                            inWords[j] = iWords[actnumber[i]] + ' Hundred';
                        }
                        break;
                    case 3:
                        if (actnumber[i] == 0 || actnumber[i + 1] == 1) {
                            inWords[j] = '';
                        }
                        else {
                            inWords[j] = iWords[actnumber[i]];
                        }
                        if (actnumber[i + 1] != 0 || actnumber[i] > 0) {
                            inWords[j] = inWords[j] + " Thousand";
                        }
                        break;
                    case 4:
                        tens_complication();
                        break;
                    case 5:
                        if (actnumber[i] == 0 || actnumber[i + 1] == 1) {
                            inWords[j] = '';
                        }
                        else {
                            inWords[j] = iWords[actnumber[i]];
                        }
                        if (actnumber[i + 1] != 0 || actnumber[i] > 0) {
                            inWords[j] = inWords[j] + " Lakh";
                        }
                        break;
                    case 6:
                        tens_complication();
                        break;
                    case 7:
                        if (actnumber[i] == 0 || actnumber[i + 1] == 1) {
                            inWords[j] = '';
                        }
                        else {
                            inWords[j] = iWords[actnumber[i]];
                        }
                        inWords[j] = inWords[j] + " Crore";
                        break;
                    case 8:
                        tens_complication();
                        break;
                    default:
                        break;
                }
                j++;
            }

            function tens_complication() {
                if (actnumber[i] == 0) {
                    inWords[j] = '';
                }
                else if (actnumber[i] == 1) {
                    inWords[j] = ePlace[actnumber[i - 1]];
                }
                else {
                    inWords[j] = tensPlace[actnumber[i]];
                }
            }
            inWords.reverse();
            for (i = 0; i < inWords.length; i++) {
                finalWord += inWords[i];
            }

            $('#NetPayableInWord').text(finalWord);
        }
        function CurrencyFormatted(num) {
            if (num == null)
                num = "0";
            num = num.toString().replace(/\$|\,/g, '');
            if (isNaN(num))
                num = "0";
            sign = (num == (num = Math.abs(num)));
            num = Math.floor(num * 100 + 0.50000000001);
            cents = num % 100;
            num = Math.floor(num / 100).toString();
            if (cents < 10)
                cents = "0" + cents;
            for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
                num = num.substring(0, num.length - (4 * i + 3)) + ',' +
                    num.substring(num.length - (4 * i + 3));
            return (((sign) ? '' : '-') + num);
        }
        var rows = '';
        function PrintBillingDetail(Bill_ID) {
            PageMethods.PrintBillingDetail(Bill_ID, function (res) {
                var Test = JSON.parse(res);
                rows = '';
                var SrNo = 0;
                $('#Billtbody tr').remove();
                $.each(Test, function (key, value) {
                    SrNo += 1
                    rows += '<tr><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey;text-align:center">' + SrNo + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Item_Name + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right"> ' + CurrencyFormatted(value.Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;display:none;text-align:right">' + CurrencyFormatted(value.Discount_Percentage) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right;">' + CurrencyFormatted(value.Discount_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right;">' + CurrencyFormatted(value.Net_Amount) + '</td></tr>';
                });

                PrintDischargeDetailrpt(Receipt_ID, Patient_ID);

            });
        }
        function PrintDischargeDetailrpt(Bill_ID, Patient_ID) {
            PageMethods.PrintDischargeDetailrpt(Receipt_ID, Patient_ID, function (res) {

                var disDetail = JSON.parse(res);
                var row = '<tr><td colspan="6" style="border: 1px solid black; border-collapse: collapse;;border-color:lightgrey;text-align:left"><b >Discharge Detail</b></td></tr>';
                var SrNo = 0;

                $.each(disDetail, function (key, value) {

                    SrNo += 1
                    var DisAmt = value.Item_Amount * value.Discount_Percentage / 100;
                    var NetAmount = value.Item_Amount - DisAmt;

                    row += '<tr"><td  style="border: 1px solid black; border-collapse: collapse;;border-color:lightgrey;text-align:center">' + SrNo + '</td><td  style="border: 1px solid black; border-collapse: collapse;border-color:lightgrey">' + value.Item_Name + '</td><td  style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right"> ' + CurrencyFormatted(value.Item_Amount) + '</td><td  style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right">' + parseFloat(DisAmt.toFixed(6)) + '</td><td  style="border: 1px solid black; border-collapse: collapse;text-align: center;border-color:lightgrey;text-align:right">' + value.Item_NetAmount + '</td></tr>';
                });

                $('#Billtbody').html(rows);
                $('#Billtbody').append(row);
                PrintDischargeReport();
            });
        }

        var Patient_ID = '';
        var Receipt_ID = '';
        var Bill_ID = '';
        var Discharge = false;
        var Discharge_ID = 0;
        var AllTotalAmount = 0;
        function OpenBill(BillID) {
            window.open("BillingProcess.aspx?Bill_ID=" + BillID);
        }

        function LoadBills() {
            debugger;
            var BillID = 0;
            var Bill_no = $("#txtMRNo").val();
            PageMethods.LoadBills(Patient_ID, Bill_no, function (resp) {
                debugger;
                $('#tblBills tbody tr').remove();

                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
                    var TrnsDate = new Date(parseInt(value.Bill_Date.substr(6)));
                    if (value.PackageName == null) {
                        value.PackageName = "";
                    }

                    TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                    var row = '<tr> <td> <a href="javascript:void(0)"  onclick="OpenBill(' + value.Bill_ID + ')" >' + value.Bill_No + ' </a> </td> <td> ' + TrnsDate + ' </td> <td> ' + value.PackageName + ' </td> <td> ' + value.Amount + ' </td>  </tr>';
                    Bill_ID = value.Bill_ID;
                    BillID = value.Bill_ID;

                    TotalBill_Amount += parseFloat(value.Balance_Amount);
                    $('#tblBills tbody').append(row);



                    var DischargeAmount = $('#txtDischageCharges').val();
                    if (DischargeAmount == '')
                        DischargeAmount = 0;

                    if (DischargeAmount == 0)
                        $('#txtDischageCharges').val(DischargeAmount);
                    AllTotalAmount = value.Amount;
                    $('#totalBill').val(value.Amount);
                    $('#txtNetReceivable').css('background-color', 'red');
                });

                var id = '<%= Request.QueryString["Bill_ID"]%>';
                if (id != "") { }
                else {
                    var Pending_Amount = parseInt(AllTotalAmount) - (parseInt(TotalAmount) + parseInt(TotalReceipt_Amount));
                    $('#txtNetBalance').val(Pending_Amount);
                    $('#txtNetReceivable').val(Pending_Amount);
                    $('#txtNetReceivable').css('background-color', 'red');
                    $('#lblTotalBillsmsg').text('Total Bill Amount:- ');

                }
                LoadReceipts(BillID);
            }, function (error) {
                alert(error.get_message());
            });



        }
        function LoadAdvance() {
            debugger;
            PageMethods.LoadAdvances(Patient_ID, function (resp) {

                $('#tblAdvance tbody tr').remove();

                $.each(JSON.parse(resp), function (key, value) {
                    var TrnsDate = new Date(parseInt(value.Advance_Date.substr(6)));
                    TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                    var row = '<tr> <td> <a href="javascript:void(0)"  onclick="OpenAdvance(' + value.Advance_ID + ')" >' + value.Advance_ID + ' </a> </td> <td> ' + TrnsDate + ' </td> <td> ' + value.Remarks + ' </td>  <td> ' + value.Amount + ' </td> </tr>';
                    TotalAmount += parseFloat(value.Amount);
                    $('#tblAdvance tbody').append(row);




                    var DischargeAmount = $('#txtDischageCharges').val();
                    if (DischargeAmount == '')
                        DischargeAmount = 0;

                    if (DischargeAmount == 0)
                        $('#txtDischageCharges').val(DischargeAmount);

                    $('#txtNetReceivable').css('background-color', 'red');
                });
                debugger;
                var netBalance_Amt = $('#txtNetBalance').val();
                var Total_amt = parseInt(AllTotalAmount) - (parseInt(TotalAmount) + parseInt(TotalReceipt_Amount));
                $('#totalAdvanceAmount').val(TotalAmount);
                $('#txtNetBalance').val(Total_amt);
                $('#txtNetReceivable').val(Total_amt);
                $('#txtNetReceivable').css('background-color', 'red');
                $('#lblTotalBillsmsg').text('Total Bill Amount:- ');
            });
        }

        function LoadReceipts(BillID) {
            debugger;

            PageMethods.LoadReceipts(BillID, function (resp) {
                debugger;
                $('#tblReceipts tbody tr').remove();

                var NoOf_Bills = $('#tblBills tbody tr').length;

                if (NoOf_Bills <= 0) {
                    $('#totalReceipt').val('0');
                    $('#txtNetBalance').val('0');
                    return;
                }


                $('#txtNetBalance').val(JSON.parse(resp));
                var TotalReceiptAmount = 0;
                $.each(JSON.parse(resp), function (key, value) {
                    debugger;
                    var row = '';
                    if (value.Receipt_Date == undefined) {

                    }
                    else {
                        debugger;
                        var TrnsDate = new Date(parseInt(value.Receipt_Date.substr(6)));
                        TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                        row = '<tr> <td> <a href="javascript:void(0)" onclick="LoadReceiptByClick(' + value.Receipt_ID + ')" > ' + value.Receipt_No + ' </a> </                      td>  <td> ' + value.Bill_No + ' </td> <td> ' + TrnsDate + ' </td> <td> ' + value.Amount + ' </td> <td> ' + value.Remarks + ' </td> </tr>';

                        TotalReceiptAmount += parseFloat(value.Amount);
                        $('#tblReceipts tbody').append(row);
                       TotalReceipt_Amount = TotalReceiptAmount
                        var Total_amt = parseInt(AllTotalAmount) - (parseInt(TotalAmount) + parseInt(TotalReceipt_Amount));
                        $('#txtNetBalance').val(Total_amt);
                        $('#txtNetReceivable').val(Total_amt);
                    }
                });
                $('#lblTotalReceiptsmsg').text('Total Receipt Amount:- ');
                $('#totalReceipt').val(TotalReceiptAmount);

            }, function (error) {
                alert(error.get_message());
            });
        }

        function LoadReceiptByClick(ReceiptID) {
            Receipt_ID = ReceiptID;
            window.location = 'Receipts.aspx?Receipt_ID=' + Receipt_ID;
        }

        function SaveRecord() {
            debugger;
            var val = document.getElementById("hdnDuplicateCheck").value;
            var returnVal = false;
            if (val == "0") {
                document.getElementById("hdnDuplicateCheck").value = "1";


                var Receipt_Date = $('#txtReceiptDate').val();
                var Remarks = $('#txtRemarks').val();
                var Receipt_Amount = $('#txtReceiptAmount').val();
                var NetReceivable = $('#txtNetReceivable').val();
                var Net_Balance = $('#txtNetBalance').val();

                if (Receipt_ID == '' )
                    Receipt_ID = 0
                if (Bill_ID == '')
                    Bill_ID = 0
                if ($('#txtMRNo').val() == '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Patient.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#txtMRNo').focus();
                    return;
                }
                else if (isNaN($('#txtReceiptAmount').val())) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Enter Only Digits.!',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#txtReceiptAmount').focus();
                    return;
                }
                else if (($('#txtReceiptAmount').val()) == '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Amount is required.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $('#txtReceiptAmount').focus();
                    return;
                }
                else if (Bill_ID == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Select Your Bill.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    return;
                }
                if ($('#chkDischarge').is(':checked') == true) {
                    if (parseFloat($('#txtReceiptAmount').val()) < NetReceivable) {
                        alert('Receipt Amount Should Be:-' + NetReceivable);
                        $('#txtReceiptAmount').focus();
                        return;
                    }
                }
                var Discharge = $('#chkDischarge').is(':checked');
                var Discharge_Amount = $('#txtDischageCharges').val();

                if (Discharge_Amount == '')
                    Discharge_Amount = 0;
                Receipt_Amount = Receipt_Amount - Discharge_Amount;
                PageMethods.SaveReceipt(Receipt_ID, Patient_ID, Receipt_Date, Remarks, Receipt_Amount, Bill_ID, Discharge, Discharge_Amount, function (resp) {
                    debugger;
                    if (Receipt_ID == 0)
                        $('#lblmsg').text('Record Saved Successfully.');
                    else
                        $('#lblmsg').text('Record Updated Successfully.');
                    Receipt_ID = resp;

                    if (Discharge == true) {

                        SaveServices(Receipt_ID, Discharge_ID);
                    }

                    window.location = 'Receipts.aspx?Receipt_ID=' + Receipt_ID;

                }, function (error) {
                    alert(error.get_message());
                });
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Processing Please Wait',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                returnVal = false;
            }
        }

        function tokenInputs(textboxID, tblName, OnAddFun) {
            $('#' + textboxID).tokenInput("../../json.aspx?Table=" + tblName,
                {
                    tokenLimit: 1,
                    onAdd:
                        function (item) {
                            try {
                                debugger;
                                if (tblName == 'BillNoFetchByID') {
                                    Patient_ID = item.type;
                                    Clear(false, true);
                                    CheckPackages();

                                }
                            }
                            catch (err) {
                                alert(err.message);
                            }
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

        function FillTokenInputForMRNo() {
            debugger;
            if (Patient_ID == '') {

                tokenInputs('txtMRNo', 'BillNoFetchByID');

            }
            else {

                var tokendata = httpGet("../../json.aspx?Table=BillNoFetchByID&q=" + Bill_ID);
                $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, type: JSON.parse(tokendata)[0].type });
            }
        }

        function LoadPatientDetails() {
            debugger;
            $.ajax({
                type: "POST",
                url: "Receipts.aspx/GetPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }

        function LoadInPatientDetail() {
            PageMethods.LoadInPatientDetail(Patient_ID, function (resp) {

                var data = JSON.parse(resp);

                if (data != null) {
                    debugger;
                    if (data.Room_Name == null)
                        data.Room_Name = "";
                    if (data.Ward_Name == null)
                        data.Ward_Name = "";
                    if (data.Bed_No == null)
                        data.Bed_No = "";
                    if (data.Discharge_On == null)
                        data.Discharge_On = "";
                    if (data.Admission_Date == null)
                        data.Admission_Date = "";
                    var TrnsDate = new Date(parseInt(data.Admission_Date.substr(6)));
                    var Addmisiondate = moment(TrnsDate).format('L');
                    if (data.Discharge_On != "") {
                        var trnsDate = new Date(parseInt(data.Discharge_On.substr(6)));
                        var DischargDate = moment(trnsDate).format('L');
                    }

                    $('#lblWardNo').text(ReplaceNullWith_Space(data.Ward_Name));
                    $('#lblBedNo').text(ReplaceNullWith_Space(data.Bed_No));
                    $('#lblRoomNo').text(ReplaceNullWith_Space(data.Room_Name));
                    $('#lblAddmisionDate').text(Addmisiondate);
                    $('#lblDischargeDate').text(DischargDate);
                    $('#lblPatientCategory').text(ReplaceNullWith_Space(data.Patient_Type));
                    $('#lblPatientDiscountCatagory').text(ReplaceNullWith_Space(data.Patient_Discount_Typename));




                }
            }, function (error) {
                alert(error.get_message());
            });
            LoadAdvance();
            LoadBills();
            
           
            
        }
        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }
        function OnSuccess(data) {
            debugger;
            if (data.d != '') {
                var mydate = new Date(Date.parse(data.d.Entry_Date));
                var dateR = mydate.toLocaleDateString();
                $('#lb_Mirno').text(ReplaceNullWith_Space(data.d.Patient_No));
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                $('#lblRegDate').text(dateR);
                $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#lblDepartment').text(ReplaceNullWith_Space(data.d.department));
                $('#lblPatientCategory').text(ReplaceNullWith_Space(data.d.Patient_Type));
                LoadInPatientDetail();
            }
        }
        var NewPatientID = "";
        var NewBillId = "";
        function LoadRecord() {
            debugger;
            var RcptID = '<%= Request.QueryString["Receipt_ID"]%>';
            if (Receipt_ID == '')
                Receipt_ID = 0
            if (RcptID != '' && Receipt_ID == 0)
                Receipt_ID = RcptID;
            PageMethods.LoadRecord(Receipt_ID, function (resp) {
                var rec = JSON.parse(resp);
                var ReceiptID = "";
                var NweRemarks = "";
                var DischargeCharges = "";
                var ReceiptAmount = "";
                var ReceiptNo = "";


                var Receipt_Date = "";
                var NewDischarge = false;
                var DischargeAmount = 0.00;
                var NetAmount = "";
                $.each(rec, function (key, value) {
                    debugger;
                    Receipt_ID = value.Receipt_ID;
                    NewPatientID = value.Patient_ID;
                    NewBillId = value.Bill_No;
                    if (ReceiptNo == "")
                        ReceiptNo = value.Receipt_No;
                    else {
                        ReceiptNo = ReceiptNo + "," + value.Receipt_No;
                    }
                    if (ReceiptID == "")
                        ReceiptID = value.Receipt_ID;
                    else {
                        ReceiptID = ReceiptID + "," + value.Receipt_ID;
                    }
                    var gg = parseFloat(value.Receipt_Amount) + parseFloat(value.Receipt_Amount);
                    if (ReceiptAmount == "")
                        ReceiptAmount = parseFloat(value.Receipt_Amount);
                    else
                        ReceiptAmount = ReceiptAmount + parseFloat(value.Receipt_Amount);
                    NweRemarks = value.Remarks;
                    NewDischarge = value.Discharge;
                    DischargeCharges = value.Discharge_Charges;
                    Receipt_Date = value.Receipt_Date;
                    if (value.Discharge_Charges != null)
                        DischargeAmount = value.Discharge_Charges;
                    NetAmount = value.NetAmount;

                });
                debugger;
                Patient_ID = NewPatientID;
                Bill_ID = NewBillId;

                FillTokenInputForMRNo();

                var TrnsDate = new Date(parseInt(Receipt_Date.substr(6)));
                TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                debugger;
                $('#txtReceiptDate').val(TrnsDate);
                $('#txtRemarks').val(NweRemarks);
                $('#txtReceiptAmount').val(parseInt(ReceiptAmount) + parseInt(DischargeAmount));
                $('#txtReceiptNo').val(ReceiptNo);
                $('#txtDischageCharges').val(DischargeCharges);

                if (NewDischarge === true)
                    $('#chkDischarge').prop('checked', 'checked')
                else
                    $('#chkDischarge').prop('checked', '')

                $('#btnSave').val('Update');
                $('#totalBill').val(parseFloat(NetAmount));
                $('#lblmsg').text('Record Loaded Successfully.');



                if (NewDischarge === true) {
                    GetDischargeServiceDetails(ReceiptNo);
                    GetDischargeInvestigationDetails(Receipt_ID);
                }
                else if (NewDischarge === false) {
                    GetInvestigationDetails(Patient_ID);
                }
            }, function (error) {
                alert(error.get_message());
            });
        }

        function AddServices() {

            var serviceName = $('#ddlServiceTypes option:selected').text();
            var serviceID = $('#ddlServiceTypes').val();
            var rowID = tblDischarge.rows.length;
            var rows = '<tr><td>' + rowID + ' </td><td><input type="hidden" name="txtServiceType" id="txtServiceType' + rowID + '"  value="Service"/> <input type="hidden" name="txtServiceID" id="txtServiceID' + rowID + '"  value="' + serviceID + '"/>' + serviceName + '</td><td><input type="text"                    name="txtQty" id="txtQty' + rowID + '"  style="width:  78px !important;" onkeyup="UpdateAmountWithQTy(' + rowID + ')" value="1"/><td><input type="text"      name="txtServiceAmount" id="txtServiceAmount' + rowID + '" style="width:  89px !important;    height: 28px;" onkeyup="UpdateAmount(' + rowID + ')"<td/><td><input type="text"      name="txtServiceNetAmount" id="txtServiceNetAmount' + rowID + '" disabled="disabled" style="width:  89px !important;    height: 28px;" onkeyup="UpdateAmount(' + rowID + ')"<td/></tr>';
            $('#tblDischarge').append(rows);
        }
        function UpdateDiscountAmount() {
            var NetAmount = 0;
            var ServiceAmount = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            var GetPercssss = 0;
            var fina = 0;
            var DisPer = $('#txtDischargeDiscountPercentage').val();
            var DisAmt = $('#txtDischargeDiscountAmount').val();
            var DischargeTotalAmount = $('#txtDischargeTotalAmount').val();
            var DischargeNetAmount = $('#txtDischargeNetAmount').val();
            if (DisAmt != "") {
                GetPercssss = (100 / DischargeTotalAmount) * DisAmt;
                $('#txtDischargeDiscountPercentage').val(GetPercssss);
                final = DischargeTotalAmount - DisAmt
                $('#txtDischargeNetAmount').val(final);
            }
        }
        function UpdateDiscountPercentage() {
            var NetAmount = 0;
            var ServiceAmount = 0;
            var TotalAmount = 0;
            var GetPercAmount = 0;
            var final = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            var DisPer = $('#txtDischargeDiscountPercentage').val();
            var DisAmt = $('#txtDischargeDiscountAmount').val();
            var DischargeTotalAmount = $('#txtDischargeTotalAmount').val();
            var DischargeNetAmount = $('#txtDischargeNetAmount').val();
            if (DisPer != "") {
                GetPercAmount = DischargeTotalAmount * DisPer / 100;
                $('#txtDischargeDiscountAmount').val(GetPercAmount);
                final = DischargeTotalAmount - GetPercAmount
                $('#txtDischargeNetAmount').val(final);
            }
        }
        function GetDischargeAmount() {
            var NetAmount = 0;
            var ServiceAmount = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            var DisPer = $('#txtDischargeDiscountPercentage').val();
            var DisAmt = $('#txtDischargeDiscountAmount').val();
            var DischargeTotalAmount = $('#txtDischargeTotalAmount').val();
            var DischargeNetAmount = $('#txtDischargeNetAmount').val();
            if (DischargeNetAmount == "")
                DischargeNetAmount = 0.00
            $('#txtDischageCharges').val(DischargeNetAmount);
            $('#txtNetReceivable').val(parseFloat($('#txtNetReceivable').val()) + parseFloat($('#txtDischageCharges').val()));
        }
        function UpdateAmountWithQTy(rowid) {

            var Amount = document.getElementById('txtServiceAmount' + rowid + '').value;
            var Qty = document.getElementById('txtQty' + rowid + '').value;

            var totalAmount = Qty * Amount
            $('#txtServiceAmount' + rowid + '').val(totalAmount);
            UpdateAmount()
        }
        function UpdateAmount() {
            debugger;
            var NetAmount = 0;
            var ServiceAmount = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            var DisPer = $('#txtDischargeDiscountPercentage').val();
            var DisAmt = $('#txtDischargeDiscountAmount').val(TotalAmount);
            var rowID = tblDischarge.rows.length - 1;
            for (i = 0; i <= rowID; i++) {
                var j = i + 1;
                if (j <= rowID) {
                    ServiceAmount = document.getElementById('txtServiceAmount' + j + '').value;
                    if (ServiceAmount == "")
                        ServiceAmount = 0.00;
                    var ServiceQty = $('#txtQty' + j + '').val()

                    var ServiceNetAmount = $('#txtServiceNetAmount' + j + '').val();
                    if (ServiceNetAmount == "")
                        ServiceNetAmount = 0.00;

                    var TotalNetAmount = ServiceAmount * ServiceQty;
                    $('#txtServiceNetAmount' + j + '').val(TotalNetAmount)
                    TotalAmount += parseInt(TotalNetAmount);
                }
            }
            $('#txtDischargeTotalAmount').val(TotalAmount);
            var DischargeTotalAmount = $('#txtDischargeTotalAmount').val();
            $('#txtDischargeNetAmount').val(TotalAmount);
            if (DisPer != "") {
                var Getper = DischargeTotalAmount * DisPer / 100;
                $('#txtDischargeDiscountAmount').val(Getper);
                var final = DischargeTotalAmount - Getper
                $('#txtDischargeNetAmount').val(final);
            }
        }
        function SaveServices(Receipt_ID, Discharge_ID) {
            var table = $('#tblDischargeBody');
            var service_list = [];
            table.find('tr').each(function (key, value) {
                service_list.push({ 'Transaction_Type': "Service", 'Item_ID': $(value).find('td input[name=txtServiceID]').val(), 'Discharge_Amount': $(value).find('td input[name=txtServiceAmount]').val(), 'Qty': $(value).find('td input[name=txtQty]').val(), 'Net_Amount': $(value).find('td input[name=txtServiceNetAmount]').val() });
            });
            var tableTest = $('#tblInvestigationDetailsBody');
            var test_list = [];
            tableTest.find('tr').each(function (key, value) {

                var trnsID = $(value).find('td input[name=txtParentTransID]').val();
                test_list.push({ 'Discharge_Test_Date': $(value).find('td input[name=txtDischargeTestDate]').val(), 'Transaction_Type': 'Test', 'Parent_Trans_ID': $(value).find('td input[name=txtParentTransID]').val(), 'Item_ID': $(value).find('td input[name=txtTest_ID]').val(), 'Discharge_Amount': $(value).find('td input[name=txtTest_Amount]').val() });
            });
            var Discharge_Charges = $('#txtDischageCharges').val();
            var DisPer = $('#txtDischargeDiscountPercentage').val();
            var DisAmt = $('#txtDischargeDiscountAmount').val();
            var DischargeTotalAmount = $('#txtDischargeTotalAmount').val();
            var DischargeNetAmount = $('#txtDischargeNetAmount').val();
            var Investigation_Limit = $('#txtInvestigationAvailableLimit').val();
            if (Discharge_Charges == 0) {
                Discharge_Charges = 0.00;
            }

            if (Receipt_ID != 0 || Patient_ID != "") {
                var servicelisteeeeee = { 'Discharge_Charges': Discharge_Charges, 'PatientID': Patient_ID, 'Receipt_ID': Receipt_ID, 'Discharge_Amount': DischargeTotalAmount, 'Discount_Percentage': DisPer, 'Discount_Amount': DisAmt, 'Net_Amount': DischargeNetAmount, 'Discharge_ID': Discharge_ID, 'Investigation_Limit': Investigation_Limit, 'service_list': service_list, 'test_list': test_list };
                PageMethods.SaveServiceDetail(JSON.stringify(servicelisteeeeee), function (res) {
                });
            }
        }
        function GetServiceDetails() {
            PageMethods.GetServiceDetails(Bill_ID, function (resp) {
                if (resp != 'null') {
                    var data = JSON.parse(resp);
                    console.clear();
                }
            }, function (error) {
                alert(error.get_message());
            });
        }
        function Clear(ClearMR, clearHistoryTableRows) {
            var Receipt_ID = '';
            var Bill_ID = '';
            var Discharge = false;
            var Discharge_ID = 0;

            $('#lblmsg').text('');
            $('#txtReceiptNo').val('New');
            $("#txtReceiptDate").val($.datepicker.formatDate('dd M yy', new Date()));
            $('#txtRemarks').val('');
            $('#txtReceiptAmount').val('');
            if (ClearMR) {
                Patient_ID = 0;
                $('#txtMRNo').tokenInput('clear');
            }
            $('#lblPatienName').text('');
            $('#lblAgeYears').text('');
            $('#lblGender').text('');
            $('#lblRegDate').text('');
            $('#lblAddress').text('');
            $('#lblContactNo').text('');
            $('#lblDepartment').text('');
            $('#lblPatientCategory').text('');
            if (clearHistoryTableRows) {
                $('#tblBills tbody tr').remove();
                $('#tblReceipts tbody tr').remove();
                $('#lblTotalBills').text('');
                $('#lblTotalReceipts').text('');
            }
            $('#chkDischarge').prop('checked', '');
            $('#totalBill').val('0');
            $('#totalReceipt').val('0');
            $('#txtNetBalance').val('0');
            $('#btnSave').val('Save');
        }
        $(document).ready(function () {

            $("#txtDateFrom").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtDateTo").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtReceiptDate").datepicker({ dateFormat: 'mm/dd/yy' });
            $("#txtDateFrom").val($.datepicker.formatDate('dd M yy', new Date()));
            $("#txtDateTo").val($.datepicker.formatDate('dd M yy', new Date()));
            $("#txtReceiptDate").val($.datepicker.formatDate('dd M yy', new Date()));


            var RcptID = '<%= Request.QueryString["Receipt_ID"]%>';

            if (RcptID != "") {
                LoadRecord();
            }
            FillTokenInputForMRNo();
            FillServiceTypes();
            $(function () {
                $('#txtNetReceivable').keypress(function (event) {
                    event.preventDefault();
                    return false;
                });
            });


            LoadTotalBillingSum(); 
            LoadTotalDiscount();
            LoadTotalNetAmount();
            LoadCashPaid();
            LoadAdvances();
            LoadRefund();
            LoadActual();
            LoadPrivateCash();
            LoadPanelCash();
            GetBoxesVisibility();

        });
        function PrinAllReceiptDetail() {
            var MrNo = $('#txtMRNo').val();
            var chkSummary = document.getElementById('chkSummary').checked;

            if (MrNo == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select MR No',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            else {
                if (chkSummary != true)
                    window.open('/ReportViewer.aspx?ReportName=PrinAllReceiptDetail&ReportTitle=Bill Detail (IPD)  ' + '&PatientID=' + $('#txtMRNo').val());
                else
                    window.open('/ReportViewer.aspx?ReportName=InPatientSummarry&ReportTitle=Bill Summary (IPD)  ' + '&PatientID=' + $('#txtMRNo').val());
            }

        }
        var checkPackages = false;
        function CheckPackages() {


            PageMethods.CheckPackages($('#txtMRNo').val(), function (resp) {

                if (resp != null)
                    checkPackages = true;
                LoadPatientDetails();


            });
        }

        function LoadTotalBillingSum() {
            PageMethods.GetTotalBillingsAmount(function (data) {
                $('#lblTotalBillingSum').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadTotalDiscount() {
            PageMethods.GetTotalDiscountAmount(function (data) {
                $('#lblTotalDiscount').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadTotalNetAmount() {
            PageMethods.GetTotalNetAmount(function (data) {
                $('#lblTotalAmount').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadCashPaid() {
            PageMethods.GetTotalCashPaid(function (data) {
                $('#lblTotalCashPaid').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadAdvances() {
            PageMethods.GetTotalAdvance(function (data) {
                $('#lblTotalAdvance').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadRefund() {
            PageMethods.GetTotalRefund(function (data) {
                $('#lblTotalAdvance').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadActual() {
            PageMethods.GetTotalActual(function (data) {
                $('#lblActualCash').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadPrivateCash() {
            PageMethods.GetTotalPrivateCash(function (data) {
                $('#lblPrivateCash').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function LoadPanelCash() {
            PageMethods.GetTotalPanelCash(function (data) {
                $('#lblPanelCash').text(CurrencyFormatted(data));
            }, function (error) {
                console.log(error.get_message());
            });
        }

        function GetBoxesVisibility() {
            $.ajax({
                type: "POST",
                url: "Receipts.aspx/GetBoxesVisibility",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var code = response.d;

                    if (code === "01") {
                        $("#divReceiptsBoxes").show();
                    } else {
                        $("#divReceiptsBoxes").hide();
                    }
                }
            });
        }

    </script>
    <div class="row">
        <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
        <div class="row mb-3" id="divReceiptsBoxes">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header text-white">
                        <i class=""></i>Total Sale
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalBillingSum">0.00</h4>
                    </div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header text-white"><i class=""></i>Private</div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblPrivateCash">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header text-white"><i class=""></i>Panel</div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblPanelCash">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header text-white">
                        <i class=""></i>Discount
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalDiscount">0.00</h4>
                    </div>
                </div>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header  text-white">
                        <i class=""></i>Net Sale
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalAmount">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header  text-white">
                        <i class=""></i>Cash Paid
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalCashPaid">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header  text-white">
                        <i class=""></i>Advances
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalAdvance">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header  text-white">
                        <i class=""></i>Services Refund
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblTotalRefund">0.00</h4>
                    </div>
                </div>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <div class="card1 border-primary shadow-sm">
                    <div class="card-header  text-white">
                        <i class=""></i>Actual Cash
                    </div>
                    <div class="card-body text-center">
                        <h4 class="card-title text-primary" id="lblActualCash">0.00</h4>
                    </div>
                </div>
            </div>
            
            

        </div>
        <!-- Left Card -->
        <div class="col-lg-4 col-md-5 col-sm-12">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <div class="image-container">
                                <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Addrecepit.png" alt="Patient Image" class="img-fluid rounded-circle patient-image " />
                            </div>
                        </div>
                        <div class="col-lg-7 col-md-7 col-sm-6">
                            <div class="row mb-3 mtt">
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <label>Bill No *:</label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6">
                                    <input type="text" id="txtMRNo" />
                                </div>
                            </div>
                            <div class="row mb-3 mtt">
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <label>Receipt No:</label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6">
                                    <input type="text" id="txtReceiptNo" disabled="disabled" value="New" />
                                    <input type="hidden" id="hdntxtReceiptNo" value="" />
                                </div>
                            </div>
                            <div class="row mb-3 mtt">
                                <div class="col-lg-5 col-md-5 col-sm-6">
                                    <label>Receipt Date :</label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6">
                                    <input type="text" id="txtReceiptDate" disabled="disabled" />
                                </div>
                            </div>
                            <div class="row mb-3">
                                <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                    <label>Addmision Date  :</label>
                                </div>
                                <div class="col-lg-7 col-md-7 col-sm-6">
                                    <label id="lblAddmisionDate"></label>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <!-- Right Card -->
        <div class="col-lg-4 col-md-5 col-sm-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Age Years :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblAgeYears"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Contact No :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblContactNo"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Patient Name :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblPatienName"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Patient Category :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblPatientCategory"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Reg. Date :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblRegDate"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Department  :	</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblDepartment"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Address:</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblAddress"></label>
                        </div>
                    </div>
                    <label style="display: none;">Panel Company</label>
                    <label style="display: none;">Panel Company</label>
                </div>
            </div>
        </div>
        <!-- Right Card -->
        <div class="col-lg-4 col-md-5 col-sm-12">
            <div class="card">
                <div class="card-body">
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6">
                            <label>Bed No:</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblBedNo"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>Room No  :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6">
                            <label id="lblRoomNo"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>Ward No  :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <label id="lblWardNo"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>MR NO :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <label id="lb_Mirno"></label>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                            <label>Gender :</label>
                        </div>
                        <div class="col-lg-7 col-md-5 col-sm-6 top">
                            <label id="lblGender"></label>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <hr class="hr_receipt" />
        <div class="row g-3">
            <div  class="col-lg-8">
                <div class="row">
                      <!-- Left Card -->
            <div class="col-md-6">
                <div class="cards border-danger">
                    <div class="card-body">
                        <div class="mb-3">
                            <label for="totalAdvanceAmount" class="form-label">Total Advance Amount:</label>
                            <input type="text" id="totalAdvanceAmount" disabled="disabled" name="totalAdvanceAmount" class="form-control" />
                        </div>
                        <div class="mb-3">
                            <label for="totalBill" class="form-label">Total Bill:</label>
                            <input type="text" id="totalBill" disabled="disabled" name="totalBill" class="form-control" />
                        </div>
                        <div class="mb-3">
                            <label for="totalReceipt" class="form-label">Total Receipt:</label>
                            <input type="text" id="totalReceipt" disabled="disabled" name="totalReceipt" class="form-control" />
                        </div>
                        <div class="mb-3">
                            <label for="txtNetBalance" class="form-label">Net Balance:</label>
                            <input type="text" id="txtNetBalance" disabled="disabled" name="netBalance" class="form-control" />
                        </div>
                        <div class="form-check" >
                            <label style="margin-left: 15px;">Discharge</label>
                            <input type="checkbox" style="margin-top: 9px;width: 58px !important;" id="chkDischarge" onchange="DischargeCheck();" />
                        </div>
                    </div>
                </div>

            </div>

            <!-- Right Card -->
            <div class="col-lg-6">
                <div class="cards border-danger">
                    <div class="card-body">
                        <div class="mb-3">
                            <label for="txtReceiptAmount" class="form-label">Receipt Amount:</label>
                            <input type="text" id="txtReceiptAmount" name="txtReceiptAmount" onkeyup="CountNetAmount()" class="form-control" />
                        </div>
                        <div class="mb-3">
                            <label for="txtRemarks" class="form-label">Remarks:</label>
                            <input type="text" id="txtRemarks" name="remarks" class="form-control" />
                        </div>
                        <div class=" mb-3">
                            <label for="txtDischageCharges" class="form-label">Discharge Charges:</label>
                            <input type="text" id="txtDischageCharges" disabled="disabled" name="txtDischageCharges" class="form-control" />

                        </div>
                        <div class="mb-3">
                            <label for="txtNetReceivable" class="form-label">Net Receivables:</label>
                            <input type="text" id="txtNetReceivable" name="txtNetReceivable"  class="form-control fieldcolor" />
                        </div>
                     
                            <div class="form-check">
                                   <label>Summary:</label>
                                <input type="checkbox" style="margin-top: 9px;width: 58px !important;" id="chkSummary" />
                             
                            </div>
                       
                    </div>
                </div>
            </div>
                </div>
                <div class="row">
                      <div class="col-lg-2 col-md-3 col-sm-4">
                          <input type="button" class="btn btn-primry" style="width:auto" value="Save" onclick="SaveRecord()" id="btnSave" />
                  </div>
                  <div class="col-lg-2 col-md-3 col-sm-4">
                       <input type="button" class="btn btn-yellow" style="width:auto" value="New" onclick="window.location = 'Receipts.aspx'" />
                  </div> 
                  <div class="col-lg-2 col-md-3 col-sm-4">
                      <input type="button" class="btn btn-primry" style="width:auto" value="Print" name="name" onclick="PrintCashReceipt();" />
                  </div> 
                  <div class="col-lg-2 col-md-3 col-sm-4">
                           <input type="button" class="btn-gray"  style="width:auto" value="List View" onclick="window.open('ReceiptsView.aspx')" />
                  </div> 
                  <div class="col-lg-3 col-md-3 col-sm-4">             
                      <input type="button" style="width:auto" class="btn btn-primry" value="Print All Detail" onclick="PrinAllReceiptDetail();" />
                  </div>
                </div>
            </div>
          
            <div class="col-lg-4">
                <div class="row">
                    <div class="col-lg-12">
                        <div class="self2">
                            <h3 class="self" style="position: relative;">Advance Entries </h3>
                            <div style="width: 430px; overflow: scroll; height: 153px !important; height: auto;">
                                <table class="table" id="tblAdvance" style="height: 146px !important; height: auto; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <th style="width: 36px;">Advance No
                                            </th>

                                            <th style="width: 75px;">Date
                                            </th>

                                            <th style="width: 169px;">Remarks
                                            </th>
                                            <th style="width: 66px;">Amount
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>

                            <label id="Label1"></label>
                            <label id="Label2"></label>
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">

                        <div style="height: 226px;" class="self2">

                            <h3 class="self">Bill Entries </h3>
                            <div style="width: 430px; overflow: scroll; height: 138px !important; height: auto;">
                                <table class="table" id="tblBills" style="height: 146px !important; height: auto; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <th style="width: 36px;">No
                                            </th>
                                            <th style="width: 86px;">Date
                                            </th>
                                            <th style="width: 126px;">Description
                                            </th>
                                            <th style="width: 67px;">Amount
                                            </th>

                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>

                        </div>

                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-12">
                        <div style="" class="self2">
                            <h3 style="position: relative;" class="self">Receipt Entries </h3>
                            <div style="width: 430px; overflow: scroll; height: 163px !important; height: auto;">

                                <table class="table" id="tblReceipts" style="height: 146px !important; height: auto; overflow: scroll;">
                                    <thead>
                                        <tr>
                                            <th style="width: 36px;">Receipt No
                                            </th>
                                            <th>Bill No</th>
                                            <th style="width: 75px;">Date
                                            </th>
                                            <th style="width: 66px;">Amount
                                            </th>
                                            <th style="width: 169px;">Remarks
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>
                            <label id="lblTotalReceiptsmsg"></label>

                        </div>
                    </div>
                </div>
            </div>
        </div>
   
    



    <div id="PrintRecieptReport" style="display: none;">

        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px;">

            <div style="padding: 5px; margin-left: -30px">
           </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 137px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -170px;">
                   Arif Memorial Teaching Hospital
                </div>
            </div>
        </div>

        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: -30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: center; font-size: 14px">Date</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 80px; text-align: center; font-size: 14px;margin-top: -8px;">
                        <span id="txtReceiptDaterpt"></span>
                    </h6>
                </td>

                <td colspan="3">
                    <h6 style="width: 150px; margin-left: 80px; font-size: 26px">Cash Reciept</h6>
                </td>

                <td>
                    <h6 style="font-size: 14px; margin-top: -8px;">Receipt No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: center; font-size: 14px; margin-top: -8px;">
                        <span id="lvlBillno"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: center; margin-top: -61px; font-size: 14px; margin-left: 10px;">MR No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 80px; text-align: center; margin-top: -59px; font-size: 14px">
                        <span id="lvlMRno"></span>
                    </h6>
                </td>
                <td></td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -61px; font-size: 14px;">Name:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; margin-top: -59px; text-align: center; font-size: 14px">
                        <span id="ctl00_MainContent_lblNamerpt"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -61px; font-size: 14px;">Age/Gender:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: center; margin-top: -59px; font-size: 14px;">
                        <span id="lblAgerpt"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: center; margin-top: -50px; margin-left: 10px; font-size: 14px">Contect:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 80px; text-align: center; margin-top: -47px; font-size: 14px;">
                        <span id="lblContactrpt"></span>
                    </h6>
                </td>
                <td></td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 14px; margin-top: -50px;">CNIC:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: center; font-size: 14px; margin-top: -47px">
                        <span id="lblCNICrpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -50px; font-size: 14px;">Patient Type:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; text-align: center; margin-top: -47px; font-size: 14px;">
                        <span id="lblPatientTyperpt"></span>
                    </h6>
                </td>

            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: center; margin-top: -47px; margin-left: 19px; font-size: 14px;">Admission:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 78px; margin-top: -43px; text-align: center; font-size: 14px;">
                        <span id="lblAddmisionDaterpt"></span>
                    </h6>
                </td>

                <td></td>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -47px; font-size: 14px">Discharge:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; margin-top: -43px; text-align: center; font-size: 14px;">
                        <span id="lblDischargeDaterpt"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; margin-top: -47px; font-size: 14px;">Ward/Bed:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; margin-top: -43px; text-align: center; font-size: 14px;">
                        <span id="lblWardNorpt"></span>
                    </h6>
                </td>

            </tr>

        </table>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: -10px; margin-left: 70px;">
            <tr>
                <td>
                    <h6 style="width: 160px; font-size: 20px">Recieved Amount</h6>
                </td>

                <td style="width: 30px"></td>
                <td style="text-align:right">
                    <h6 style="border: 1px solid black; border-collapse: collapse; text-align: right; border-color: gray; margin-top: -15px; height: 25px; width: 120px; font-size: 24px;text-align:right;text-align:right">
                        <span id="lvlReceiptAmount"></span>
                    </h6>
                </td>
            </tr>

        </table>
        <table class="table" style="border: 1px solid black; display:none; border-collapse: collapse; border-color: gray; width: 275px; margin-top: -65px; margin-left: 560px;" id="tblBillingDetail" cellpadding="5" cellspacing="5">
            <tr>
                <td style=""><b>Total Bill:</b></td>
                <td></td>
                <td style="text-align:right">
                    <span id="lblTotalBillrpt" class="lede" style="font-weight: bold;"><b></b></span>
                </td>
            </tr>
            <tr>

                <td><b>Total Reciept:</b></td>
                <td></td>
                <td style="text-align:right">
                    <span id="lblTotalRecieptrpt" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tr>

                <td style=""><b>Total Net Balance</b></td>
                <td></td>
                <td style="text-align:right">
                    <span id="lblTotalNetBalancerpt" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tbody>
            </tbody>
        </table>

        <table class="table" style="margin-top: -50px; margin-left: 70px; display:none">
            <tr>
                <td><b>Operator Name:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -20px; margin-top: 30px; font-size: 14px; line-height: 14px;">
                        <span id="lblOperatorrpt"></span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
    </div>
    <div id="DischargeModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1120px; margin-left: -219px; margin-top: 100px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Discharge</h4>
                </div>

                <div class="modal-body">
                    <fieldset>
                        <legend>Discharge Charges Details</legend>
                        <table style="width: 408px;">
                            <tr>
                                <td style="width: 110px"><span>Service Type:-</span></td>
                                <td style="width: 234px">
                                    <select id="ddlServiceTypes" name="ddlServiceTypes">
                                    </select>
                                </td>
                                <td>
                                    <input type="button" id="btnAddDischarge" class="btn btn-primry" value="Add Service" onclick="AddServices()"/>
                                </td>
                            </tr>
                        </table>
                        <div style="height: 272px;overflow:scroll;width: 556px;">
                        <table id="tblDischarge" class="table" style="width: 540px;">
                            <thead>
                                <tr>
                                    <th>Sr.</th>
                                    <th>Description</th>
                                    <th style="width: 95px;"> Qty</th>
                                    <th style="width: 115px;">Amount</th>
                                     <th style="width: 115px;">Net Amount</th>
                                </tr>
                            </thead>
                            <tbody id="tblDischargeBody">
                            </tbody>
                        </table>
                            </div>
                        <div id="dvDischargeSummary">
                            <table style="width: 449px;margin-top: 28px;">
                                <tr>
                                    <td>Total Amount:
                                    </td>
                                    <td>
                                        <input type="text" id="txtDischargeTotalAmount" disabled="disabled" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Discount %:
                                    </td>
                                    <td>
                                     <input type="text" id="txtDischargeDiscountPercentage" style="width: 46px !important;" onkeyup="UpdateDiscountPercentage()"/>
                                        %
                                        <input type="text" id="txtDischargeDiscountAmount" style="width: 105px !important;" onkeyup="UpdateDiscountAmount()" />
                                    </td>

                                </tr>
                                <tr>
                                    <td>Net Amount:
                                    </td>
                                    <td>
                                        <input type="text" id="txtDischargeNetAmount" disabled="disabled" />
                                    </td>
                                </tr>
                            </table>
                        </div>

                        <div style="margin-left: 588px; margin-top: -420px !important; height: 272px;overflow:scroll;">
                            <table id="tblInvestigationDetails" class="table" style="width: 99.5% !important;">
                                <thead>
                                    <tr>
                                        <th>Sr.</th>
                                        <th>Date</th>
                                        <th>Test Name</th>
                                        <th>Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="tblInvestigationDetailsBody">
                                </tbody>
                            </table>                            
                        </div>
                        <div style="margin-left: 668px; width: 420px !important; margin-top: 66px;">
                            <table style="width: inherit;">
                                <tr>
                                    <td>Investigation Available Limit:
                                    </td>
                                    <td>
                                        <input type="text" id="txtInvestigationAvailableLimit" value="0" disabled="disabled" />
                                    </td>
                                </tr>
                                <tr>
                                    <td>Investigation Amount:
                                    </td>
                                    <td>
                                        <input type="text" id="txtInvestigationAmount" value="0" disabled="disabled" />
                                    </td>
                                </tr>

                            </table>
                        </div>
                    </fieldset>
                    <input type="hidden" name="uurowid" value="" />
                </div>
                <div class="modal-footer">
                    <input type="button" value="Save Discharge Details" class="btn btn-primry" style="width: 185px !important;" onclick="GetDischargeAmount()" data-dismiss="modal"/>
                </div>
            </div>
        </div>
    </div>
     <div id="PrintDischargeReport" style="display: none;">

        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Central Park Teaching Hospital
                    <br />
                    <b style="font-size: 14px">(Project of Health & Education Foundaion)</b>

                </div>
            </div>

        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">Reciept</b>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -8px;font-family:Calibri">MR No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px">
                        <span id="lvlMRnodis"></span>
                    </h6>
                </td>
                <td></td>
                <td>
                    <h6 style="width: 100px;"></h6>
                </td>
                <td>
                    <h6 style="width: 128px;"></h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 14px; margin-top: -8px;font-family:Calibri">Bill No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lvlBillnodis"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -38px;font-family:Calibri">Name:</h6>
                </td>
                <td colspan="4">
             <h6 style="border-bottom: 1px dotted #000; width: 355px !important; text-align: left; margin-left: -50px; margin-top: -35px; font-size: 14px;">
                        <span id="lblNamedisrpt"></span>
                    </h6>
                </td>
               
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -35px; font-size: 14px;font-family:Calibri">Bill Date</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -15px; margin-top: -35px; font-size: 14px;">
                        <span id="lblDateTimerptdis">.</span>
                    </h6>
                </td>
            </tr>
         
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -50px;font-family:Calibri">Age:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -45px; font-size: 14px;">
                        <span id="lblAgerptdis"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -50px;font-family:Calibri">Gender:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -15px; margin-top: -45px; font-size: 14px;">
                        <span id="lblGenderrptdis"></span>
                    </h6>
                </td>
            </tr>
               <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -38px; font-size: 14px;font-family:Calibri">CNIC</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -35px; font-size: 14px;">
                        <span id="lblCNICdisrpt"></span>
                    </h6>
                </td>

             
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -38px; font-size: 14px;font-family:Calibri">Contect:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -15px; margin-top: -35px; font-size: 14px;">
                        <span id="lblContactrptdis"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px;font-family:Calibri">Address:</h6>
                </td>
                <td colspan="6">
                    <h6 style="border-bottom: 1px dotted #000; width: 671px; text-align: left; margin-left: -50px; margin-top: -37px; font-size: 14px;">
                        <span id="lblAddressrptdis"></span>
                    </h6>
                </td>
            </tr>
        </table>
       
         <div style="border: 2px solid black; border-collapse: collapse; border-color: gray;margin-top: -20px; margin-left: 52px; width: 740px;min-height:566px" cellpadding="5" cellspacing="5"">
          <table class="table" style="overflow: scroll;width: 741px;margin-top: -5px;font-family:Calibri;" id="tblBilling">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Sr. </th>

                    <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Description </th>
                    <th style="width: 30px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Amount </th>
                    <th style="width: 33px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; display: none;">Dis % </th>
                    <th style="width: 76px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Dis Amount </th>
                    <th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-size:18px">Net Amount </th>
                </tr>
            </thead>
            <tbody id="Billtbody" class="table">
            </tbody>
        </table>
            </div>

             <table class="table" style="width: 305px; margin-left: 495px;" ; id="Table1" cellpadding="5" cellspacing="5">
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblTotalPayable" class="lede" style="font-weight: bold;"><b></b></span>
                </td>
            </tr>
            <tr style="display: none">

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount %:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblDiscount" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblAmount" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Net Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblNetPayable" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Amount Received:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblAmountReceived" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Balance:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:right">
                    <span id="lblTotalBalance" class="lede" style="font-weight: bold;"></span>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
         
          
         <table class="table" style="margin-left:50px;margin-top:-170px">
            <tr>
                <td><b style="font-family:Calibri">Net Amount In Word:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 285px; text-align: left;font-family:Calibri; margin-left: -28px; margin-top: 34px; font-size: 14px; line-height: 14px;">
                        <span id="NetPayableInWord">.</span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
        <table class="table" style="margin-left:50px;margin-top:-40px">
            <tr>
                <td><b style="font-family:Calibri">Operator Name:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000;font-family:Calibri; width: 230px; text-align: left; margin-left: -30px; margin-top: 32px; font-size: 14px; line-height: 14px;">
                        <span id="lblOperatorrptdis"></span>
                    </h6>
                </td>
            </tr>
            </table>
               
       
    </div>
</asp:Content>
