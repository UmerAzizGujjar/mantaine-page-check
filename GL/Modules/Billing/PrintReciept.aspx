<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="PrintReciept.aspx.cs" Inherits="PMS.WebForm10" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <title></title>
     
    <script src="Scripts/jquery-1.12.4.js"></script>
    <script src="Scripts/moment.js"></script>
    <%--<link href="Styles/style.css" rel="stylesheet" />--%>
    <link href="css/Report.css" rel="stylesheet" />
    <script src="Scripts/moment.min.js"></script>
     <script type="text/javascript">

         $(document).ready(function () {
             //alert();
       if ("<%=Request.QueryString["Bill_ID_Copy"]%>" != null) {

             PrintPatientCopy();
         }

         });
         $(function () {
             if ("<%=Request.QueryString["Patient_ID"]%>" != "") {
                 PrintPatientReceipt();
             }
             else if ("<%=Request.QueryString["Bill_ID"]%>" != null) {

                 PrintBIllingReceipt();
             }             
            
         });

         function PrintBillingReport() {
             
             var contents = $("#PrintBillingReport").html();
             var frame1 = $('<iframe />');
             frame1[0].name = "frame1";
             frame1.css({ "position": "absolute", "top": "-1000000px" });
             $("body").append(frame1);
             var frameDoc = frame1[0].contentWindow;
             frameDoc.document.open();
             //Create a new HTML document.
             frameDoc.document.write('<html>');
             frameDoc.document.write('<body>');
             //Append the external CSS file.
             //Append the DIV contents.
             frameDoc.document.write(contents);
             frameDoc.document.write('</body></html>');
             frameDoc.document.close();
             setTimeout(function () {
                 window.frames["frame1"].focus();
                 window.frames["frame1"].print();
                 frame1.remove();
                 window.close();               

                 //setTimeout(function () {

                 //    window.frames["frame1"].blur();
                 //    window.close();
                    

                 //}, 800);

                 //window.frames["frame1"].close()
                 //window.onfocus = function () {
                 //    window.close(); // Close the window
                 //}
                 //window.frames["frame1"].contentWindow.close()
                 //window.frames["frame1"].get(0).contentWindow;
                 //window.focus();
                 //window.close();
               //  window.focus();
             //    window.frames["frame1"].close();
             //    window.close();
                 //frame1.remove();
                 //window.close();

             }, 500);
             setTimeout(function () {
                 
     
                 window.close();
                 //  window.focus();
                 //    window.frames["frame1"].close();
                 //    window.close();
                 //frame1.remove();
                 //window.close();

             }, 700);

         }

         function PrintBillPatientCopyReport() {

             var contents = $("#PrintBillPatientCopyReport").html();
             var frame1 = $('<iframe />');
             frame1[0].name = "frame1";
             frame1.css({ "position": "absolute", "top": "-1000000px" });
             $("body").append(frame1);
             var frameDoc = frame1[0].contentWindow;
             frameDoc.document.open();             
             //Create a new HTML document.
             frameDoc.document.write('<html>');
             frameDoc.document.write('<body>');
             //Append the external CSS file.
             //Append the DIV contents.
             frameDoc.document.write(contents);
             frameDoc.document.write('</body></html>');
             frameDoc.document.close();
             setTimeout(function () {
                 alert();
                 window.frames["frame1"].focus();
                 window.frames["frame1"].print();
                 frame1.remove();
                 window.close();
             }, 500);
         }

         function PrintPatientCopy() {
             var Bill_ID = "<%=Request.QueryString["Bill_ID_Copy"]%>";
             var PatID = "<%=Request.QueryString["BillPatient_ID_Copy"]%>";
             $.ajax({
                 type: "POST",
                 url: "PrintReciept.aspx/PrintBillingReceipt",
                 data: JSON.stringify({
                     'ID': Bill_ID,
                     'PatID': PatID
                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     $('#lblNameb').text(response.d.Full_Name);
                     $('#lblAgeb').text(response.d.Age_years);
                     $('#lblPatientType').text(response.d.Patient_Type);

                     if (response.d.Gender == "M")
                         response.d.Gender = "Male"
                     else
                         response.d.Gender = "Female"
                     $('#lblGenderb').text(response.d.Gender);

                     if (response.d.NIC == "") {
                         $('#lblCNICb').text(".");
                     }
                     else {
                         $('#lblCNICb').text(response.d.NIC);
                     }

                     if (response.d.Department != null) {
                         $('#lblDepartmentb').text(response.d.Department
                             );
                     }
                     else {
                         $('#lblDepartmentb').text("");
                     }
                     if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                         $('#lblTyperb').text(response.d.Patient_Type);
                     }
                     else {
                         $('#lblTyperb').text(".");
                     }
                     $('#lblAddressb').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);


                     if (response.d.ContectNo == "") {
                         $('#lblContectb').text(".");
                     }
                     else {
                         $('#lblContectb').text(response.d.ContectNo);
                     }

                     $('#lblOperatorNameb').text(response.d.Printed_By);
                     var date = response.d.Bill_Date;
                     //var finaldate = moment(date).format('L');
                     $('#lblDateTimeb').text(date);
                     $('#lblTotalPayable').text(CurrencyFormatted(response.d.Total_Amount));

                     $("#lblTotalPayable").css("text-align:Right");
                     $('#lblDiscount').text(CurrencyFormatted(response.d.Discount_Percentage));
                     $('#lblAmount').text(CurrencyFormatted(response.d.Discount_Amount));
                     $('#lblNetPayable').text(CurrencyFormatted(response.d.Net_Amount));
                     $('#lblAmountReceived').text(CurrencyFormatted(response.d.Received_Amount));
                     $('#lblTotalBalance').text(CurrencyFormatted(response.d.Balance_Amount));

                     if (response.d.Remarks == "") {
                         $('#txtRemarksrpt').text(".");
                     }
                     else {
                         $('#txtRemarksrpt').text(response.d.Remarks);
                     }
                     // $('#txtRemarksrpt').text(response.d.Remarks);
                     $('#lvlMRno').text(response.d.MR_No);
                     $('#lvlBillno').text(response.d.Bill_No);
                     if (response.d.Ward_Name == "") {
                         $('#wardroom').text(response.d.Room_Name);
                     }
                     else if (response.d.Room_Name == "") {
                         $('#wardroom').text(response.d.Ward_Name);
                     }
                     if (response.d.ChargePolicy !== null && response.d.ChargePolicy !== "") {
                         $("#spnChargePolicy").text(response.d.ChargePolicy);
                     }
                     if (response.d.InPatientCat !== null && response.d.InPatientCat !== "") {
                         $("#spnIn-patCat").text(response.d.InPatientCat);
                     }

                     test_skill(response.d.Net_Amount);
                         PrintBillingPatientCopy(response.d.Bill_ID);


                     },
                     Error: function (x, e) {
                         alert(e)
                     }
                 });
         }

         function PrintBIllingReceipt() {
             var Bill_ID = "<%=Request.QueryString["Bill_ID"]%>";
             var PatID = "<%=Request.QueryString["BillPatient_ID"]%>";
             $.ajax({
                 type: "POST",
                 url: "PrintReciept.aspx/PrintBillingReceipt",
                 data: JSON.stringify({
                     'ID': Bill_ID,
                     'PatID': PatID
                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     console.log(response);
                     $('#lblNameb').text(response.d.Full_Name);
                     $('#lblAgeb').text(response.d.Age_years);
                     $('#lblPatientType').text(response.d.Patient_Type);

                     if (response.d.Gender == "M")
                         response.d.Gender = "Male"
                     else
                         response.d.Gender = "Female"
                     $('#lblGenderb').text(response.d.Gender);

                     if (response.d.NIC == "") {
                         $('#lblCNICb').text(".");
                     }
                     else {
                         $('#lblCNICb').text(response.d.NIC);
                     }

                     if (response.d.Department != null) {
                         $('#lblDepartmentb').text(response.d.Department
                             );
                     }
                     else {
                         $('#lblDepartmentb').text("");
                     }
                     if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                         $('#lblTyperb').text(response.d.Patient_Type);
                     }
                     else {
                         $('#lblTyperb').text(".");
                     }
                     $('#lblAddressb').text(response.d.Temporary_Address + "," + response.d.Permanent_Address + "," + response.d.Province);


                     if (response.d.ContectNo == "") {
                         $('#lblContectb').text(".");
                     }
                     else {
                         $('#lblContectb').text(response.d.ContectNo);
                     }

                     $('#lblOperatorNameb').text(response.d.Printed_By);
                     var date = response.d.Bill_Date;
                     //var finaldate = moment(date).format('L');
                     $('#lblDateTimeb').text(date);
                     $('#lblTotalPayable').text(CurrencyFormatted(response.d.Total_Amount));

                     $("#lblTotalPayable").css("text-align:Right");
                     $('#lblDiscount').text(CurrencyFormatted(response.d.Discount_Percentage));
                     $('#lblAmount').text(CurrencyFormatted(response.d.Discount_Amount));
                     $('#lblNetPayable').text(CurrencyFormatted(response.d.Net_Amount));
                     $('#lblAmountReceived').text(CurrencyFormatted(response.d.Received_Amount));
                     $('#lblTotalBalance').text(CurrencyFormatted(response.d.Balance_Amount));

                     if (response.d.Remarks == "") {
                         $('#txtRemarksrpt').text(".");
                     }
                     else {
                         $('#txtRemarksrpt').text(response.d.Remarks);
                     }
                     // $('#txtRemarksrpt').text(response.d.Remarks);
                     $('#lvlMRno').text(response.d.MR_No);
                     $('#lvlBillno').text(response.d.Bill_No);
                     $('#lblMRBarcode').text(response.d.MR_No);
                     $('#lblBillBarcode').text(response.d.Bill_No);
                     if (response.d.Ward_Name == "") {
                         $('#wardroom').text(response.d.Room_Name);
                     }
                     else if (response.d.Room_Name == "") {
                         $('#wardroom').text(response.d.Ward_Name);
                     }

                     if (response.d.ChargePolicy !== null && response.d.ChargePolicy !== "") {
                         $("#spnChargePolicy").text(response.d.ChargePolicy);
                     }

                     if (response.d.InPatientCat !== null && response.d.InPatientCat !== "") {
                         $("#spnIn-patCat").text(response.d.InPatientCat);
                     }

                     test_skill(response.d.Net_Amount);
                     PrintBillingDetail(response.d.Bill_ID);


                 },
                 Error: function (x, e) {
                     alert(e)
                 }
             });
         }

         function CurrencyFormatted(num) {
             num = num.toString().replace(/\$|\,/g, '');
             if (isNaN(num))
                 num = "0";
             sign = (num == (num = Math.abs(num)));
             num = Math.floor(num * 100 + 0.50000000001);
             cents = num % 100;
             num = Math.floor(num / 100).toString();
             if (cents < 10)
                 cents = "0" + cents;
             for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3) ; i++)
                 num = num.substring(0, num.length - (4 * i + 3)) + ',' +
                 num.substring(num.length - (4 * i + 3));
             return (((sign) ? '' : '-') + num);
         }
         var IsLab = false;
         function PrintBillingDetail(Bill_ID) {

             //$.ajax({
             //    type: "POST",
             //    url: "PrintReciept.aspx/PrintBillingDetail",
             //    data: JSON.stringify({
             //        'ID': Bill_ID,

             //    }),
             //    contentType: "application/json; charset=utf-8",
             //    dataType: "json",
             //    success: function (response) {
             //        alert(response)
             PageMethods.PrintBillingDetail(Bill_ID, function (res) {
                 var Test = JSON.parse(res);

                 var rows = '';
                 var SrNo = 0;
                 $('#Billtbody tr').remove();
                 $.each(Test, function (key, value) {
                     main_Department = value.MainDepartment;
                     if (main_Department == "001") {
                         IsLab = true;
                     }
                     SrNo += 1
                     var Discount_Amount = value.Discount_Amount;
                     Discount_Amount = parseFloat(Discount_Amount);
                     Discount_Amount = Discount_Amount.toFixed(0);

                     var Net_Amount = value.Net_Amount;
                     Net_Amount = parseFloat(Net_Amount);
                     Net_Amount = Net_Amount.toFixed(0);


                     rows += '<tr ><td valign="top" style="border: 1px solid black;  border-collapse: collapse;height:30px;border-color:lightgrey;text-align:center;margin-left: 45px;">' + SrNo + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Item_Name + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + CurrencyFormatted(value.Amount) + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;display:none;text-align:Right;" valign="top;margin-left: 45px;">' + CurrencyFormatted(value.Discount_Percentage) + '</td><td valign="top" style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Discount_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Net_Amount) + '</td></tr>';
                     //<td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:center;margin-left: 45px;">' + CurrencyFormatted(value.Report_Timing) + '</td>

                 });
                 $('#Billtbody').html(rows);
                 if (IsLab == true) {
                     $('#spnLabDesc').show();
                 }
                 PrintBillingReport();
                 //},
                 //Error: function (x, e) {
                 //    alert(e)
                 //}
             });
         }
         function PrintBillingPatientCopy(Bill_ID) {


             //$.ajax({
             //    type: "POST",
             //    url: "PrintReciept.aspx/PrintBillingDetail",
             //    data: JSON.stringify({
             //        'ID': Bill_ID,

             //    }),
             //    contentType: "application/json; charset=utf-8",
             //    dataType: "json",
             //    success: function (response) {
             //        alert(response)
             PageMethods.PrintBillingDetail(Bill_ID, function (res) {
                 var Test = JSON.parse(res);

                 var rows = '';
                 var SrNo = 0;
                 $('#Billtbody tr').remove();
                 $.each(Test, function (key, value) {
                     SrNo += 1
                     var Discount_Amount = value.Discount_Amount;
                     Discount_Amount = parseFloat(Discount_Amount);
                     Discount_Amount = Discount_Amount.toFixed(0);

                     var Net_Amount = value.Net_Amount;
                     Net_Amount = parseFloat(Net_Amount);
                     Net_Amount = Net_Amount.toFixed(0);


                     rows += '<tr ><td valign="top" style="border: 1px solid black;  border-collapse: collapse;height:30px;border-color:lightgrey;text-align:center;margin-left: 45px;">' + SrNo + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Item_Name + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + CurrencyFormatted(value.Amount) + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;display:none;text-align:Right;" valign="top;margin-left: 45px;">' + CurrencyFormatted(value.Discount_Percentage) + '</td><td valign="top" style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Discount_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Net_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:center;margin-left: 45px;">' + CurrencyFormatted(value.Report_Timing) + " - hr" + '</td></tr>';
                     //<td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:center;margin-left: 45px;">' + CurrencyFormatted(value.Report_Timing) + '</td>

                 });
                 $('#Billtbody').html(rows);

                 PrintBillPatientCopyReport();
                 //},
                 //Error: function (x, e) {
                 //    alert(e)
                 //}
             });
         }
         function removeCommas(str) {
             while (str.search(",") >= 1) {
                 str = (str + "").replace(',', '');
             }
             return str;
         };


         function PrintPatientReceipt() {
             var ID = "<%=Request.QueryString["Patient_ID"]%>";
             $.ajax({
                 type: "POST",
                 url: "PrintReciept.aspx/PrintPatientReceipt",
                 data: JSON.stringify({
                     'PatientID': ID
                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {

                     $('#ctl00_MainContent_lblNamerpt').text(response.d.Full_Name);
                     $('#lblFatherName').text(response.d.FatherName);
                     $('#lblAgerpt').text(response.d.Age_years);
                     $('#lblGenderrpt').text(response.d.Gender);


                     if (response.d.Department != null) {
                         $('#lblDepartmentrpt').text(response.d.Department + "-" + response.d.RoomNo);
                     }
                     else {
                         $('#lblDepartmentrpt').text("");
                     }
                     if (response.d.Patient_Type != null && response.d.Patient_Type != 'null') {
                         $('#lblTyperpt').text(response.d.Patient_Type);
                     }
                     else {
                         $('#lblTyperpt').text("Nill");
                     }
                     if (response.d.Marital_Status != null && response.d.Marital_Status != 'null') {
                         $('#lblMaritalStatusrpt').text(response.d.Marital_Status);
                     }
                     else {
                         $('#lblMaritalStatusrpt').text("Nill");
                     }

                     $('#lblDateTimerpt').text(response.d.Created_Time);

                     //if (response.d.Referring_Doctor != null) {
                     $('#lblAttendingDoctorrpt').text(response.d.Referring_Doctor);
                     //}
                     //else {
                     //    $('#lblAttendingDoctorrpt').text("");
                     //}
                     if (response.d.Permanent_Address == "") {
                         $('#lblAddressrpt').text("");
                     }
                     else {
                         $('#lblAddressrpt').text(response.d.Permanent_Address);
                     }


                     if (response.d.NIC == "") {
                         $('#lblCNICrpt').text("");
                     }
                     else {
                         $('#lblCNICrpt').text(response.d.NIC);
                     }

                     if (response.d.ContectNo == "") {
                         $('#lblContactrpt').text("");
                     }
                     else {
                         $('#lblContactrpt').text(response.d.ContectNo);
                     }

                     if (response.d.Doctor_Name == null) {
                         $('#lblDoctorrpt').text("");
                     }
                     else {
                         $('#lblDoctorrpt').text(response.d.Doctor_Name);
                     }

                     $('#lblOPDNorpt').text(response.d.MR_No);

                     $('#lblTokanNorpt  ').text(response.d.TokenNo);
                     if (response.d.Doctor_Amount == null || response.d.Doctor_Amount == "")
                         response.d.Doctor_Amount = 0.00;

                     var total = parseInt(response.d.ReceiptCharges) + parseInt(response.d.Doctor_Amount);

                     $('#lblSlipChargesrpt').text("Rs" + " " + parseInt(total));
                     $('#lblOperatorrpt').text(response.d.PrintedBy);
                     if (response.d.Prisentation != null) {
                         $('#lblPresentationrpt').text(response.d.Prisentation);
                     }
                     else
                         $('#lblPresentationrpt').text("Nill");
                     if (response.d.Pulse_Min != null) {
                         $('#lblPlus').text(response.d.Pulse_Min);
                     }
                     else {

                         $('#lblPlus  ').html(".");
                     }
                     if (response.d.Respiration_Min != null) {
                         $('#lblRespiration').text(response.d.Respiration_Min);
                     }
                     else {
                         $('#lblRespiration').text(".");
                     }
                     if (response.d.Temp_C != null) {
                         $('#lblTemp').text(response.d.Temp_C);
                     }
                     else {
                         $('#lblTemp').text(".");
                     }
                     if (response.d.BP != null) {
                         $('#lblBP').text(response.d.BP);
                     }
                     else {
                         $('#lblBP').text(".");
                     }

                     $('#lblNumber').text(response.d.follow);
                     //if (response.d.Prisentation != null) {
                     PrintPatientsReport();
                 },
                 Error: function (x, e) {
                     alert(e)
                 }
             });
         }
         function test_skill(Amount) {

             var junkVal = Amount;
             junkVal = Math.floor(junkVal);
             var obStr = new String(junkVal);
             numReversed = obStr.split("");
             actnumber = numReversed.reverse();

             if (Number(junkVal) >= 0) {
                 //do nothing
             }
             else {
                 alert('wrong Number cannot be converted');
                 return false;
             }
             if (Number(junkVal) == 0) {
                 //document.getElementById('container').innerHTML = 'Rupees Zero Only';
                 $('#NetPayableInWord').text("Rupees Zero Only");
                 return false;
             }
             if (actnumber.length > 9) {
                 alert('Oops!!!! the Number is too big to covertes');
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
             //document.getElementById('container').innerHTML = obStr + '  ' + finalWord;
         }
         function PrintPatientsReport() {

             window.print();
             setTimeout(function () { window.close(); }, 50);
             //var contents = $("#PrintPatientsReport").html();
             //var frame1 = $('<iframe />');
             //frame1[0].name = "frame1";
             //frame1.css({ "position": "absolute", "top": "-1000000px" });
             //$("body").append(frame1);
             //var frameDoc = frame1[0].contentWindow;
             //frameDoc.document.open();
             ////Create a new HTML document.
             //frameDoc.document.write('<html>');
             //frameDoc.document.write('<body>');
             ////Append the external CSS file.
             ////Append the DIV contents.
             //frameDoc.document.write(contents);
             //frameDoc.document.write('</body></html>');
             //frameDoc.document.close();
             //setTimeout(function () {
             //    window.frames["frame1"].focus();
             //    window.frames["frame1"].print();
             //    frame1.remove();
             //    window.close();
             //}, 50);
         }
     </script>    
 

</head>
<body>
    <form id="Form1" runat="server"> <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="true"></asp:ScriptManager></form>
   
      <div id="PrintPatientsReport" class="header_Table">  

        <div style="height: 110px; padding-left:100px; -webkit-print-color-adjust: exact; width: 750px; margin: 0 auto;">

            <div style="padding: 5px;">
                <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">
            </div>
            <div style="width: 440px; height: 110px; margin-top: -113px; margin-left: 110px;">
                <div style="padding-top: 40px; font-size: 30px; color:darkblue;font-weight: bold; text-align: center;font-family:Calibri">
                    Arif Memorial Teaching  Hospital
                </div>
            </div>
        </div>
     
      <table class="header_Table">
            <tr >
                <td class="Header_first_column_Lable">
                    <span>MR No :</span></td>
                <td class="header_lable_value">    
                     <span class="margintop" id="lblOPDNorpt"></span></td>
                <td class="header_lable"><span>Name:</span></td>
                <td class="header_lable_value"><span id="ctl00_MainContent_lblNamerpt"></span></td>
                <td class="header_lable">
                    <span>Father/Husband:</span>
                </td>
                <td class="header_lable_value">
               
                        <span id="lblFatherName"></span>
                    
                </td>              
                <td class="header_lable">

                    <span>Age:</span>
                </td>
                <td class="header_lable_value">
                          
                        <span id="lblAgerpt"></span>
                    
                </td>

                
            </tr>
            <tr >
                         <td class="Header_first_column_Lable">
                    <span>Token No:</span>
                </td>
                <td class="header_lable_value">
                    
                        <span style="font-weight:bolder !important" id="lblTokanNorpt"></span>
                   
                </td>
                <td class="header_lable">
                    <span>Contact:</span>
                </td>
                <td style ="width:150px"; class="header_lable_value">
                  
                        <span id="lblContactrpt"style="min-width:150px">></span>
                    
                </td>
                <td class="header_lable">
                    <span>Marital Status:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblMaritalStatusrpt"></span>
                </td>
                <td class="header_lable">
                    <span >F.up No:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblNumber"></span>
                </td>
                
            </tr>
            <tr>
                 <td class="Header_first_column_Lable">
                    <span>Presentaion:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblPresentationrpt"></span>
                </td>
                  <td class="header_lable">
                    <span>Gender:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblGenderrpt"></span>
                </td>
                
                <td class="header_lable">
                    <span>Dept:</span>
                </td>
                <td colspan="3" class="header_lable_value">
                        <span  style="font-weight:bolder !important" id="lblDepartmentrpt"></span>
                </td>
				 
            </tr>
            <tr>
                 <td  class="Header_first_column_Lable">
                    <span>Type:</span>
                </td>
                <td class="header_lable_value"> 
                        <span id="lblTyperpt"></span>
                </td>
                <td class="header_lable">
                    <span>Date:</span>
                </td>
                <td  style="width: 125px"; class="header_lable_value">
                        <span id="lblDateTimerpt"style="min-width:150px"></span>
                </td>
                 <td class="header_lable">
                    <span>CNIC:</span>
                </td>
                <td  style="width: 150px"; class="header_lable_value">
                        <span id="lblCNICrpt" style="min-width:150px"></span>
                </td>
                 <td class="header_lable">
                    <span>Charges:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblSlipChargesrpt"></span>
                </td>
            </tr>

            <tr>
               <td class="Header_first_column_Lable">
                    <span>Address:</span>
                </td>
                <td colspan="3" class="header_lable_value">
                   
                        <span id="lblAddressrpt"></span>
                </td>
				 <td class="header_lable">
                    <span>Doctor:</span>
                </td>
                <td  style="width: 150px"; class="header_lable_value">
                        <span id="lblDoctorrpt" style="min-width:150px"></span>
                </td>
                <td class="header_lable">
                    <span >Operator:</span>
                </td>
                <td class="header_lable_value">
                        <span id="lblOperatorrpt"></span>
                </td>
            </tr>
        </table>

        <hr style="margin-top: 20px;" />


        <h6 class ="Second_table_history"> Presenting Complaints / History</h6>

        <table class ="second_table_style";> <%--style="margin-top: 15px; height:auto">--%>
            <tr>
                <td>
                    <h6 class ="second_table_first_lable"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 class ="second_table_second_lable"></h6>
                </td>
            </tr>
        </table>

        <hr style="margin-top: 90px;" />
        <table>
            <tr>
                <td style="width:250px">
        <h6 style="width: 200px; text-align: left; font-size: 20px;color:darkblue; font-size: 14px;font-family:Calibri">Examination/ Clinical Findings</h6>
                    </td>
                <td>
                    <table>
            <tr>
                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">Pulse</h6>
                </td>
                <td>
                    <h6 style="width: 40px; border-bottom: 1px dotted #000 !important;" id="lblPlus">
                        <%--<span id="lblPlus"></span>--%>
                    </h6>
                </td>
                <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri">Temp</h6>
                </td>
                <td>
                    <h6 style="width: 40px; border-bottom: 1px dotted #000;">
                        <span id="lblTemp"></span>
                    </h6>
                </td>
                  <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;color:darkblue;font-size: 14px;font-family:Calibri">Resp</h6>
                </td>
                <td>
                    <h6 style="width: 40px; border-bottom: 1px dotted #000;">
                        <span id="lblRespiration"></span>
                    </h6>
                </td>
                  <td style="width:25px"></td>

                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">BP</h6>
                </td>
                <td>
                    <h6 style="width: 40px; border-bottom: 1px dotted #000;">
                        <span id="lblBP"></span>
                    </h6>
                </td>
                 <td style="width:25px"></td>
                <td>
                    <h6 style=" width: 38px;font-size: 14px;color:darkblue;font-family:Calibri">Weight</h6>
                </td>
                <td>
                    <h6 style="width: 40px; padding-left:7px; border-bottom: 1px dotted #000;">
                        <span id="lblWeight"></span>
                    </h6>
                </td>
            </tr>

        </table></td>
                </tr>
       </table>
        <table style="margin-top: -15px;">
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;"></h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;"></h6>
                </td>
            </tr>
        </table>

        <hr style="margin-top: 7px;" />

        <h6 style="width: 200px; text-align: left; color:darkblue;font-size: 20px; margin-top: 0px; font-size: 14px;font-family:Calibri">Investigations </h6>

        <table style="margin-top: -15px;">
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;" />
                </td>
            </tr>
             <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;" />
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 740px; margin-top: 0px;" />
                </td>
            </tr>
        </table>

        <hr style="margin-top: -10px;" />

        <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px;color:darkblue; font-size: 14px;font-family:Calibri">Provisional Diagnosis</h6>

        <table style="margin-top: -15px;">
           
        </table>



        <table style="border: 1px solid black; border-collapse; width: 100%; height: 220px;">
            <tr>
                <td style="border-bottom: 1px dotted black; width: 48%; color:darkblue;border-right: 2px solid black;font-family:Calibri; vertical-align: top; padding: 0; margin: 0;">
                    <h5>Medicine Prescribed</h5>
                </td>
                <td style="border-bottom: 1px dotted black; width: 48%;font-family:Calibri;color:darkblue; vertical-align: top; padding: 0; margin: 0;">
                    <h5>Advice</h5>
                </td>
            </tr>
            <tr>
                <td style="border-bottom: 1px dotted black; border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="border-bottom: 1px dotted black; padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>
            <tr>
                <td style="border-bottom: 1px dotted black; border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="border-bottom: 1px dotted black; padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>
            <tr>
                <td style="border-bottom: 1px dotted black; border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="border-bottom: 1px dotted black; padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>



            <tr>
                <td style="border-bottom: 1px dotted black; border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="border-bottom: 1px dotted black; padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>
            <tr>
                <td style="border-bottom: 1px dotted black; border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="border-bottom: 1px dotted black; padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>
            <%--<tr>
                <td style="border-right: 2px solid black; padding: 0; margin: 0;"><span>&nbsp</span></td>
                <td style="padding: 0; margin: 0;"><span>&nbsp</span></td>
            </tr>--%>

        </table>


        <%--<div style="margin-top: 10px;height:10px;width:500px" >
               
                Admission &nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;
            <input type="checkbox" value="Discharge" />
                Discharge&nbsp&nbsp;&nbsp; &nbsp; &nbsp;Signature & Stamp:
              
            </div>--%>

     <footer>
        <table style="margin-top:30px;font-family:Calibri;font-weight:bold">
            <tr>
                <td style="width: 50px">
                    <input type="checkbox" value="Admission" />
                </td>
                <td style="width: 50px">
                    <span style="font-family:Calibri;color:darkblue;">Admission</span>
                </td>
                <td style="width: 50px">
                    <input type="checkbox" value="Admission" />
                </td>
                <td style="width: 200px">
                    <span style="font-family:Calibri;color:darkblue;">Discharge</span>
                </td>
                <td></td><td style="min-width:200px"></td>
                <td>
                    <span><b style="color:darkblue;">Signature & Stamp:</b></span>
                </td>
                <td style="border-bottom: 1px dotted black; width: 140px"></td>
            </tr>
        </table>
   </footer>

   
    </div>

     <div id="PrintBillingReport" style="display: none;" >
        
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
                <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;" />
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Hospital Lahore
                    <br />

                </div>
            </div>

        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">Reciept</b>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px;font-family:Calibri">MR No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -50px; margin-top: -9px; font-size: 14px">
                        <span id="lvlMRno"></span>
                         <span class="margintop" id="lblMRBarcode" style="font-family:'Code 3 de 9';font-weight:normal;font-size:20px;width:80px"></span>
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
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -10px; font-size: 14px;">
                        <span id="lvlBillno"></span>
                         <span class="margintop" id="lblBillBarcode" style="font-family:'Code 3 de 9';font-weight:normal;font-size:20px;width:80px"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -25px;font-family:Calibri">Name:</h6>
                </td>
                <td colspan="4">
                    <h6 style="border-bottom: 1px dotted #000; width: 395px !important; text-align: left; margin-left: -50px; margin-top: -23px; font-size: 14px;">
                        <span id="lblNameb"></span>
                    </h6>
                </td>
                <%--<td></td>
                <td>
                    <h6 style="width: 100px;"></h6>
                </td>
                <td>
                    <h6 style="width: 128px;"></h6>
                </td>--%>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Bill Date</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -25px; font-size: 14px;">
                        <span id="lblDateTimeb"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">CNIC</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px;">
                        <span id="lblCNICb"></span>
                    </h6>
                </td>

                <td></td>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Contact:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblContectb"></span>
                    </h6>
                </td>
               <%--extra--%>
 <%--                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Time:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblTime"></span>
                    </h6>
                </td>--%>
                                 <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Patient Type:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblPatientType"></span>
                    </h6>
                </td>
                               
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -28px;font-family:Calibri">Age:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px;">
                        <span id="lblAgeb"></span>
                    </h6>
                </td>

                <td></td>
                <%--<td>
                    <h6 style="width: 100px;"></h6>
                </td>
                <td>
                    <h6 style="width: 128px;"></h6>
                </td>--%>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Gender:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblGenderb"></span>
                    </h6>
                </td>
                     <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px; font-family:Calibri">Ward / Room</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -10px; margin-top: -20px; font-size: 14px;">
                        <span id="wardroom"></span>
                    </h6>
                </td>
                <%--extra1--%>
<%--                        <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Reporting Time:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblReportingTime"></span>
                    </h6>
                </td>--%>


            </tr>

            <tr>
                <td></td>
                <td></td>
                <td></td>
                <td><h6 style="width: 80px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">In-Patient Category</h6></td>
                <td>
                      <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -10px; margin-top: -20px; font-size: 14px;">
                        <span id="spnIn-patCat"></span>
                    </h6>
                </td>
                <td>                    
                     <h6 style="width: 80px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Charge Policy</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -10px; margin-top: -20px; font-size: 14px;">
                        <span id="spnChargePolicy"></span>
                    </h6>
                </td>
            </tr>

            <tr>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -33px; font-size: 14px;font-family:Calibri">Address:</h6>
                </td>
                     <td colspan="6">
                    <h6 style="border-bottom: 1px dotted #000; width: 671px; text-align: left; margin-left: -50px; margin-top: -10px; font-size: 14px;">
                        <span id="lblAddressb"></span>
                    </h6>
                </td>
               <%-- extra3--%>


            </tr>
            <tr>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -32px; font-size: 14px;font-family:Calibri">Remarks:</h6>
                </td>
                <td colspan="6">
                    <h6 style="border-bottom: 1px dotted #000; width: 671px; text-align: left; margin-left: -40px; margin-top: -23px; font-size: 14px;">
                        <span id="txtRemarksrpt"></span>
                    </h6>
                </td>
            </tr>


        </table>


        <%--  <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; margin-left: 45px;font-size: 14px"></h6>
             
              <h6 style="width: 740px; margin-top: -20px;margin-left: 45px; font-size: 14px; color: darkgrey"><span id="txtRemarksrpt"></span></h6>
             


        --%>
                  
             <div style="border: 2px solid black; border-collapse: collapse; border-color: gray;margin-top: -20px; margin-left: 52px; width: 733px;min-height:400px" cellpadding="5" cellspacing="5"">
          <table class="table" style="overflow: scroll;width: 734px;margin-top: -5px;font-family:Calibri;" id="tblBilling">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Sr. </th>

                    <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;;font-size:18px">Description </th>
                    <th style="width: 30px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Amount </th>
                    <th style="width: 33px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; display: none;font-family:Calibri;font-size:18px">Dis % </th>
                    <th style="width: 76px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Dis Amount </th>
                    <th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Net Amount </th>
                     <%--<th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Report Timing </th>--%>
                </tr>
            </thead>
            <tbody id="Billtbody" >
            </tbody>
        </table>
                 </div>
          <div>

            <span id="spnLabDesc" style="display:none;font-size: 14px;margin-left:50px;">I allow the AMLab staff for phlebotomy procedure for mentioned lab investigation(s).</span>
         
         </div>

        <table class="table" style="width: 305px;margin-left: 490px;" id="tblBillingDetail" cellpadding="5" cellspacing="5">
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblTotalPayable" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr style="display: none">

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount %:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblDiscount" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblAmount" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Net Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblNetPayable" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Amount Received:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblAmountReceived" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Balance:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="lblTotalBalance" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
           <table class="table" style="margin-left:50px;margin-top:-170px">
            <tr>
                <td style=";font-family:Calibri"> <b>Net Amount In Word:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 275px; text-align: left;font-family:Calibri; margin-left: -28px; margin-top: 27px; font-size: 14px; line-height: 14px;">
                        <span id="NetPayableInWord">.</span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
        <table class="table" style="margin-left:50px;margin-top:-40px">
            <tr>
                <td style=";font-family:Calibri"><b>Operator Name:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left;font-family:Calibri; margin-left: -30px; margin-top: 43px; font-size: 14px; line-height: 14px;">
                        <span id="lblOperatorNameb"></span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
    </div>
    <div id="PrintBillPatientCopyReport" style="display:none;">
        
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">

            <div style="padding: 5px; margin-left: -30px">
                <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Hospital Lahore
                    <br />

                </div>
            </div>

        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">Patient Copy</b>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px;font-family:Calibri">MR No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 88px; text-align: left; margin-left: -50px; margin-top: -9px; font-size: 14px">
                        <span id="Span1"></span>
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
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -10px; font-size: 14px;">
                        <span id="Span2"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -25px;font-family:Calibri">Name:</h6>
                </td>
                <td colspan="4">
                    <h6 style="border-bottom: 1px dotted #000; width: 395px !important; text-align: left; margin-left: -50px; margin-top: -23px; font-size: 14px;">
                        <span id="Span3"></span>
                    </h6>
                </td>
                <%--<td></td>
                <td>
                    <h6 style="width: 100px;"></h6>
                </td>
                <td>
                    <h6 style="width: 128px;"></h6>
                </td>--%>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Bill Date</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -25px; font-size: 14px;">
                        <span id="Span4"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">CNIC</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px;">
                        <span id="Span5"></span>
                    </h6>
                </td>

                <td></td>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Contact:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="Span6"></span>
                    </h6>
                </td>
               <%--extra--%>
 <%--                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -25px; font-size: 14px;font-family:Calibri">Time:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblTime"></span>
                    </h6>
                </td>--%>
                                 <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Patient Type:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="Span7"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -28px;font-family:Calibri">Age:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 128px; text-align: left; margin-left: -50px; margin-top: -20px; font-size: 14px;">
                        <span id="Span8"></span>
                    </h6>
                </td>

                <td></td>
                <%--<td>
                    <h6 style="width: 100px;"></h6>
                </td>
                <td>
                    <h6 style="width: 128px;"></h6>
                </td>--%>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Gender:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="Span9"></span>
                    </h6>
                </td>
                <%--extra1--%>
<%--                        <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Reporting Time:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblReportingTime"></span>
                    </h6>
                </td>--%>


            </tr>
            <tr>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -33px; font-size: 14px;font-family:Calibri">Address:</h6>
                </td>
                     <td colspan="6">
                    <h6 style="border-bottom: 1px dotted #000; width: 671px; text-align: left; margin-left: -50px; margin-top: -10px; font-size: 14px;">
                        <span id="Span10"></span>
                    </h6>
                </td>
               <%-- extra3--%>


            </tr>
            <tr>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -32px; font-size: 14px;font-family:Calibri">Remarks:</h6>
                </td>
                <td colspan="6">
                    <h6 style="border-bottom: 1px dotted #000; width: 671px; text-align: left; margin-left: -40px; margin-top: -23px; font-size: 14px;">
                        <span id="Span11"></span>
                    </h6>
                </td>
            </tr>


        </table>


        <%--  <h6 style="width: 200px; text-align: left; font-size: 20px; margin-top: 0px; margin-left: 45px;font-size: 14px"></h6>
             
              <h6 style="width: 740px; margin-top: -20px;margin-left: 45px; font-size: 14px; color: darkgrey"><span id="txtRemarksrpt"></span></h6>
             


        --%>
                  
             <div style="border: 2px solid black; border-collapse: collapse; border-color: gray;margin-top: -20px; margin-left: 52px; width: 733px;min-height:400px" cellpadding="5" cellspacing="5"">
          <table class="table" style="overflow: scroll;width: 734px;margin-top: -5px;font-family:Calibri;" id="Table1">
            <thead>
                <tr>
                    <th style="width: 40px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Sr. </th>

                    <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;;font-size:18px">Description </th>
                    <th style="width: 30px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Amount </th>
                    <th style="width: 33px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; display: none;font-family:Calibri;font-size:18px">Dis % </th>
                    <th style="width: 76px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Dis Amount </th>
                    <th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Net Amount </th>
                     <th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Report Timing </th>
                </tr>
            </thead>
            <tbody id="Tbody1" >
            </tbody>
        </table>
                 </div>
         

        <table class="table" style="width: 305px;margin-left: 490px;" id="Table2" cellpadding="5" cellspacing="5">
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span12" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr style="display: none">

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount %:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span13" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Discount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span14" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Net Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span15" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Amount Received:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span16" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>
            <tr>

                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;font-family:Calibri"><b>Total Balance:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray;text-align:Right;">
                    <span id="Span17" class="lede" style="font-weight: bold;text-align:Right;"></span>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
           <table class="table" style="margin-left:50px;margin-top:-170px">
            <tr>
                <td style=";font-family:Calibri"> <b>Net Amount In Word:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 275px; text-align: left;font-family:Calibri; margin-left: -28px; margin-top: 27px; font-size: 14px; line-height: 14px;">
                        <span id="Span18">.</span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
        <table class="table" style="margin-left:50px;margin-top:-40px">
            <tr>
                <td style=";font-family:Calibri"><b>Operator Name:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left;font-family:Calibri; margin-left: -30px; margin-top: 43px; font-size: 14px; line-height: 14px;">
                        <span id="Span19"></span>
                    </h6>
                </td>
            </tr>

            <tbody>
            </tbody>
        </table>
    </div>
</body>
</html>
