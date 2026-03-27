<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillingProcess.aspx.cs" Inherits="PMS.BillingProcess" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Billing.css" rel="stylesheet" />
    
    <style>
        div.token-input-dropdown {
            overflow: auto;
            max-height: 150px;
        }
        /*k*/
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div style="margin: 0px 0px 0px 0px;">
        <script type="text/javascript">
            var DiscountAMt = 0;
            var is_Patient_Temp = false;
            var Test_Rate = 0;
            var doctorListGlobal = '';
            var doctorsListGlobalResponse = '';
            var shareTypeGlobalResponse = '';
            var globalTestRate = '';
            function BackToPrint() {
                var id = '<%=Request.QueryString["ID"]%>';
                var newWindow = 'PrintReciept.aspx?Bill_ID=' + '<%= Request.QueryString["Bill_ID"]%>' + '&BillPatient_ID=' + document.getElementById('<%=hdfPatient_ID.ClientID%>').value;
                var printWindow = window.open(newWindow);

                printWindow.addEventListener('load', function () {

                    setTimeout(function () {
                        printWindow.close();

                    }, 8000);

                }, true);

            }
            debugger;
            function PrintCRV() {
                debugger;
                var id = '<%= Request.QueryString["Bill_ID"]%>';
                var locationInfo = window.location;

                var user_name = '<% =AppConfig.Company_Name %>';
                if (user_name == 'As-Siraat Serving Humanity') {
                    reportPath = '../../ReportViewer.aspx';
                } else {
                    reportPath = 'ReportViewer.aspx'; // same folder
                }
                var url = "/ReportViewer.aspx?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=" + id;
                if (!locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=BillingBaseReport&ReportTitle=Billing Base Report&Bill_ID=' + id;
                }
                window.open(url, '_blank');

            }
            function PrintCRV1() {
                debugger;
                var id = '<%= Request.QueryString["Bill_ID"]%>';
    var locationInfo = window.location;

    var user_name = '<% =AppConfig.Company_Name %>';
    var reportPath;
    if (user_name == 'As-Siraat Serving Humanity') {
        reportPath = '../../ReportViewer.aspx';
    } else {
        reportPath = 'ReportViewer.aspx';
    }

    // Build URL — different report name based on whether doctorId is passed
    function buildUrl(doctorId) {
        var base;
        if (!locationInfo.origin.includes('localhost')) {
            var urlInfo = window.location.href.split('/');
            var ip = urlInfo[2];
            var foldername = urlInfo[3];
            base = 'http://' + ip + '/' + foldername + '/' + reportPath;
        } else {
            base = '/ReportViewer.aspx';
        }

        var reportName, reportTitle;

        if (doctorId != null) {
            // Doctor rows  → Consultant report
            reportName = 'BillingBaseReport_Consultant';
            reportTitle = 'Consultant%20Billing%20Report';
        } else {
            // No-doctor rows → Hospital Services report
            reportName = 'BillingBaseReport_Hospital_Services';
            reportTitle = 'Hospital%20Services%20Billing%20Report';
        }

        var url = base + '?ReportName=' + reportName
            + '&ReportTitle=' + reportTitle
            + '&Bill_ID=' + id;

        if (doctorId != null) {
            url += '&Doctor_ID=' + doctorId;
        }

        return url;
    }

    // Step 1: Fetch DISTINCT Doctor IDs from Ar_Billing_Details via AJAX
    $.ajax({
        type: "POST",
        url: "BillingProcess.aspx/GetDistinctDoctorsByBillId",
        data: JSON.stringify({ 'Bill_Id': id }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            debugger;
            var doctorIds = JSON.parse(response.d);

            // Step 2: Open Hospital Services report (no doctor = NULL/0 rows)
            setTimeout(function () {
                window.open(buildUrl(null), '_blank');
            }, 0);

            // Step 3: Open one Consultant report per distinct doctor
            $.each(doctorIds, function (index, item) {
                setTimeout(function () {
                    window.open(buildUrl(item.Doctor_ID), '_blank');
                }, (index + 1) * 700);
            });
        },
        error: function (err) {
            console.error("Failed to fetch doctor IDs", err);
            alert("Could not load doctor information for this bill.");
        }
    });
}

            var Appointment;
            function CheckAppointmentAllow() {

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/RightAppointmentBilling",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        Appointment = JSON.parse(response.d);
                        if (Appointment == '01') {
                            $('#btnAppointment').show();
                        }
                        else {
                            $('#btnAppointment').hide();
                            //getprNoBy();
                        }
                    },
                    error: function (error) {
                        console.error("Error fetching items", error);
                    }
                });
            }

            var Rpts;
            function CheckReceiptsUpdateonBilling() {

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/ReceiptsUpdateonBilling",
                    data: JSON.stringify({}),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var Rptss = JSON.parse(response.d);
                        if (Rptss == '001') {
                            Rpts = true;
                        }
                        else {
                            Rpts = false;
                        }
                    },
                    error: function (error) {
                        console.error("Error fetching items", error);
                    }
                });
            }


            function BackToPrintPatient() {
                var Bill_ID = '<%= Request.QueryString["Bill_ID"]%>'
                var PatID = document.getElementById('<%=hdfPatient_ID.ClientID%>').value;
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
                        debugger;
                        $('#lblNameb').text(response.d.Full_Name);
                        $('#lblAgeb').text(response.d.Age_years);
                        $('#lblPatientType').text(response.d.Patient_Type);
                        $('#lblchargePolicyb').text(response.d.ChargePolicy);

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

                        $('#lvlMRno').text(response.d.MR_No);
                        $('#lvlBillno').text(response.d.Bill_No);
                        if (response.d.Ward_Name == "") {
                            $('#wardroom').text(response.d.Room_Name);
                        }
                        else if (response.d.Room_Name == "") {
                            $('#wardroom').text(response.d.Ward_Name);
                        }
                        test_skill(response.d.Net_Amount);
                        PrintBillingPatientCopy(response.d.Bill_ID);
                    },
                    Error: function (x, e) {
                        alert(e)
                    }
                });
            }
            var IsLab = false;
            function PrintBillingPatientCopy(Bill_ID) {

                PageMethods.PrintBillingDetail(Bill_ID, function (res) {
                    var main_Department = "";
                    var Test = JSON.parse(res);
                    var rows = '';
                    var SrNo = 0;
                    $('#Billtbody tr').remove();
                    $.each(Test, function (key, value) {
                        debugger;
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

                        rows += '<tr ><td valign="top" style="border: 1px solid black;  border-collapse: collapse;height:30px;border-color:lightgrey;text-align:center;margin-left: 45px;">' + SrNo + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Item_Name + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + CurrencyFormatted(value.Amount) + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;display:none;text-align:Right;" valign="top;margin-left: 45px;">' + CurrencyFormatted(value.Discount_Percentage) + '</td><td valign="top" style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Discount_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + CurrencyFormatted(Net_Amount) + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:center;margin-left: 45px;">' + value.Report_Timing + '</td></tr>';

                    });
                    $('#Billtbody').html(rows);
                    if (IsLab == true) {
                        $('#spnLabDesc').show();
                    }

                    PrintBillPatientCopyReport();

                });
            }
            function TotalAmountToday() {
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/TotalAmountToday",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var amt = response.d;
                        $("#txtBillAmountToday").val(parseInt(amt));
                    }
                    , error: function () {
                    }
                })
            }
            function PopulatePackage() {
                $("#PackageModel").modal('show');
                LoadPackages()

            }
            function PopulateDetails() {
                $("#DetailModel").modal('show');
                LoadDetailsBillsAginstPatient()

            }
            function PopulateBillingDetails(Bill_ID) {
                $("#BillingDetailModel").modal('show');
                $("#DetailModel").modal('hide');
                LoadBillingsDetails(Bill_ID)

            }
            function LoadDetailsBillsAginstPatient() {
                var Patient_ID = $('#hdfPatient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetBillingRecords",
                    data: JSON.stringify({
                        'Patient_ID': Patient_ID
                    }),
                    contentType: "application/json; charset=utf-8",
                    datatype: "json",
                    success: function (resp) {
                        $('#tblDetailModelTable tbody').empty();
                        var rows = '';
                        var rowIndex = parseInt((parseInt($('#tblDetailModelTable tbody tr').length)));
                        $.each(JSON.parse(resp.d), function (key, value) {
                            rows = '<tr><td style="text-align:Center;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> ' + value.Bill_No + '</td><td> ' + value.Total_Amount + '</td><td> ' + value.Discount_Amount + '</td><td> ' + value.Received_Amount + '</td><td> ' + value.Balance_Amount + '</td><td style="background-color:#EFA63E;font-size:20px; color:white;"><i class="fa fa-eye" onclick="PopulateBillingDetails(' + value.Bill_ID + ')" id="btnDel"></i></td> </tr>'
                            $('#tblDetailModelTable tbody').append(rows);
                            rowIndex++;
                        });
                    },
                    failure: function (error) {
                        alert(error.get_message());
                    }
                });
            }
            function LoadBillingsDetails(Bill_Id) {
                var Patient_ID = $('#hdfPatient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetBillingRecordsDetails",
                    data: JSON.stringify({
                        'Bill_Id': Bill_Id
                    }),
                    contentType: "application/json; charset=utf-8",
                    datatype: "json",
                    success: function (resp) {
                        var rows = '';
                        $('#tblBillingDetailModelTable tbody').empty();
                        var rowIndex = parseInt((parseInt($('#tblBillingDetailModelTable tbody tr').length)));
                        $.each(JSON.parse(resp.d), function (key, value) {
                            rows = '<tr><td style="text-align:Center;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> ' + value.Bill_No + '</td><td> ' + value.Item_Name + '</td><td> ' + value.Item_Type + '</td><td> ' + value.Qty + '</td><td> ' + value.Amount + '</td><td> ' + value.Discount_Amount + '</td><td> ' + value.Net_Amount + '</td> </tr>'
                            $('#tblBillingDetailModelTable tbody').append(rows);
                            rowIndex++;
                        });
                    },
                    failure: function (error) {
                        alert(error.get_message());
                    }
                });
            }
            function LoadPackages() {
                debugger;
                var PackType = $("#hdn_pkgtype").val();
                var packname = $("#hdn_pkgname").val();
                if (packname != 0 && PackType != 0) {
                    $.ajax({
                        type: "POST",
                        url: "BillingProcess.aspx/GetPackageDetails",
                        data: JSON.stringify({
                            'PackType': PackType,
                            'packname': packname
                        }),
                        contentType: "application/json; charset=utf-8",
                        datatype: "json",
                        success: function (resp) {
                            $('#tblPackageModelTable tbody').empty();
                            var rows = '';
                            var rowIndex = parseInt((parseInt($('#tblPackageModelTable tbody tr').length)));
                            $.each(JSON.parse(resp.d), function (key, value) {
                                rows = '<tr><td style="text-align:Center;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> ' + value.Item_Name + '</td><td> ' + value.Amount + '</td> </tr>'
                                $('#tblPackageModelTable tbody').append(rows);
                                rowIndex++;
                            });
                        },
                        failure: function (error) {
                            alert(error.get_message());
                        }
                    });
                }
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
                for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
                    num = num.substring(0, num.length - (4 * i + 3)) + ',' +
                        num.substring(num.length - (4 * i + 3));
                return (((sign) ? '' : '-') + num);
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
                    alert('wrong Number cannot be converted');
                    return false;
                }
                if (Number(junkVal) == 0) {

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

            }
            function PrintBillPatientCopyReport() {
                var contents = $("#PrintBillingReport").html();
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
            function PrintVoucher() {
                debugger;
                var id = '<%=Request.QueryString["Bill_ID"]%>';
                var locationInfo = window.location;
                var url = 'ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=BIJV';
                if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                    var urlInfo = window.location.href.split('/');
                    var ip = urlInfo[2];
                    var foldername = urlInfo[3];
                    url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=BIJV';
                }
                window.open(url, '_blank');
            }
            function PrintHospital() {
                window.open('/ReportViewer.aspx?ReportName=PrintHospital&ReportTitle=Hospital Print' + '&Bill_ID=' + '<%= Request.QueryString["Bill_ID"]%>');
            }
            function PrintConsultant() {
                window.open('/ReportViewer.aspx?ReportName=PrintConsultant&ReportTitle=Consultant Print' + '&Bill_ID=' + '<%= Request.QueryString["Bill_ID"]%>');
            }
            function OpenNewForm() {
                window.location = "/BillingProcess.aspx";
            }
            function FillTestsByCategory(CategoryID) {
                var options = '<option value="0" >Please Select</option>';
                if (CategoryID == '002') {
                    $("#btnultrasound").removeClass("btn-info").addClass("btn-danger");
                    $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                    $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                    $('#divRotation').hide();
                }
                else if (CategoryID == '003') {
                    $("#btnXray").removeClass("btn-info").addClass("btn-danger");
                    $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                    $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                    $('#divRotation').show();
                    PageMethods.GetRotationsCategoryWise('Test XRay Rotations', function (GetRotations) {
                        var options = '<option value="0" >Select</option>';
                        $.each(JSON.parse(GetRotations), function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlRotation option').remove()
                        $('#ddlRotation').html(options);
                        $('#ddlRotation').select2();
                    });
                }
                else if (CategoryID == '004') {
                    $("#btnCTscan").removeClass("btn-info").addClass("btn-danger");
                    $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                    $('#btnXray').removeClass('btn-danger').addClass('btn-info');
                    $('#divRotation').show();
                    PageMethods.GetRotationsCategoryWise('Test CT Scan Rotations', function (GetRotations) {
                        var options = '<option value="0" >Select</option>';
                        $.each(JSON.parse(GetRotations), function (key, value) {
                            options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                        });
                        $('#ddlRotation option').remove();
                        $('#ddlRotation').html(options);
                        $('#ddlRotation').select2();
                    });
                }
                PageMethods.FillTestsByCategory(CategoryID, function (Tests) {
                    var options = '<option value="0" >Please Select</option>';
                    $.each(JSON.parse(Tests), function (key, value) {
                        options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                    });
                    $('#ddlTestList').html(options);
                    $('#ddlTestList').select2();
                });
            }
            function FillProcedure(deptID) {
                var options = '<option value="0" >Please Select</option>';
                PageMethods.GetProcedure(deptID, function (item) {
                    $.each(JSON.parse(item), function (key, value) {
                        options += '<option value="' + value.TestID + '" >' + value.TestName + '</option>';
                    });
                    $('#ddlTestList').html(options);
                    $('#ddlTestList').select2();
                });
            }
            function checkIsExistinOutPatient() {

                var Patient_ID = $('#hdfPatient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/IsPatientExistInOPD",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        var s = data.d;
                        if (s == true) {
                            $("#btnAddPackage").attr("disabled", true);
                        }
                        else {
                            $("#btnAddPackage").attr("disabled", false);
                        }
                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            var getnew_discamt = 0;
            function getamountbykhizar() {

                var DisAmount = 0;
                var totaldisamt = 0;
                var getnew_discamt = 0;
                var get_prevsamt = 0;
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    DisAmount = $(value).find('input[name="DisAmount"]').val();
                    totaldisamt += parseFloat(DisAmount);
                    if (totaldisamt > ss) {
                        get_prevsamt = parseFloat(totaldisamt) - parseFloat(DisAmount);
                        getnew_discamt = parseFloat(ss) - parseFloat(get_prevsamt);
                    }
                });
            }
            var Disc_Amount = 0;
            var Complete_disc_Amt = 0;
            var max_Total_Dic_Amt = 0;
            var max_Total_Dic_Amt_Ultra = 0;
            var max_Total_Dic_Amt_Xray = 0;
            var max_Total_Dic_Amt_ct_Scan = 0;
            var max_Total_Dic_Amt_Blood = 0;
            var max_Total_Dic_Amt_Item = 0;
            var max_Package_Amt = 0;
            var max_Total_Dic_Amt_Procedure = 0;
            localStorage.Disc_Zero = 0;
            localStorage.OnlyPercentage = 0;
            var Special = 0;
            debugger;
            function AddLabTest(maindpt) {
                debugger;
                localStorage.Disc_Zero = 0;
                localStorage.OnlyPercentage = 0;
                var pat_id = $('#txtMRNo').val();
                var remarks = $("#Remarks").val();
                var test = $('#ddlTestList').find('option:selected').text();
                PageMethods.GetLabTestDDLDetails(test, maindpt, pat_id, function (res) {
                    $.each(JSON.parse(res), function (key, value) {
                        var Result = 'Result';
                        var test = $('#ddlTestList').val();
                        var date = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';

                        var TestMainDepartmentName;
                        var ParentTransType = '';
                        if (JSON.parse(res).length > 1)
                            ParentTransType = 'Test Group Category';
                        var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                        var ParentTransID = 0;
                        if (ParentTransID == '' || ParentTransID == null)
                            ParentTransID = '0';
                        var ParentTransName = value.GroupName;
                        if (ParentTransName == '')
                            ParentTransName = ' ';

                        var Rate = value.Rate;

                        var RemainDiscAmt = value.Remaining_Amount;
                        var percentage_Amt = value.Total_Disc_Amt;
                        if (percentage_Amt == "0.0000") {

                            DisAmt = value.Disc;
                            localStorage.OnlyPercentage = 1;
                            if (RemainDiscAmt != "0.0000") {
                                localStorage.OnlyPercentage = 0;
                            }
                        }
                        var categ = $('#ddlMainTestDepartment').val();
                        var DisAmt = value.Disc;
                        if (DisAmt == "0.0000") {
                            localStorage.Disc_Zero = 1;
                        }
                        if (DisAmt == "There is no row at position 0.") {
                            DisAmt = "0.00";

                        }
                        else {
                            if (category == "001") {
                                if (isLabCompeted == true) {

                                    DisAmt = "0.00";
                                }
                                if (max_Total_Dic_Amt != 0) {
                                }
                                else {
                                    max_Total_Dic_Amt = value.Total_Disc_Amt;

                                }
                            }
                            if (category == "005") {
                                if (isBloodBankCompleted == true) {
                                    DisAmt = "0.00";
                                }
                                if (max_Total_Dic_Amt_Blood != 0) {
                                }
                                else {
                                    max_Total_Dic_Amt_Blood = value.Total_Disc_Amt;


                                }
                            }
                        }
                        var Discount_Amount = $('#txtDisAmt').val();
                        if (Rate == null || Rate == "")
                            Rate = 0;
                        if (globalTestRate == 0 || globalTestRate == "" || globalTestRate == null) {
                            globalTestRate = Rate;
                        }
                        if (value.Test_ID != 0) {
                            value.Group_Category == "0";
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.TestMainDepartmentName + '" /><input type="hidden" name="hdnDisPer" value="' + DisAmt + '"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)" disabled/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td id="amnt' + rowIndex + '" name="amnt" style="text-align:Right;" onkeypress="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td> <input type="text" name="DisPer" value="' + DisAmt + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"><td><input type="text" name="DocShare" id="ds' + rowIndex + '"  value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" onchange="GetDocAgreementValuess(this)" name="ddlDoctor" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + date + '"/>' + date + ' </td></tr>'
                            var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" disabled=disabled value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td><td>' + globalTestRate + '</td></tr>'
                        }
                        else {
                            ParentTransType = 'Test Group Category';
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnDisPer" value="' + DisAmt + '" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td> ' + remarks + '</td><td><input type="text" name="txtQty" disabled=disabled value="1" disabled style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td id="amnt' + rowIndex + '" name="amnt" style="text-align:Right;" onkeypress="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td> <input type="text" name="DisPer" value="' + DisAmt + '"  style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">  </td><td><input type="text" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '"  onchange="GetDocAgreementValuess(this)" name="ddlDoctor" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + date + '"/>' + date + ' </td> </tr>'
                            var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + ParentTransID + '" /> <input type="hidden" name="hdnParentTrans_Name"  value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '"  /> <input type="hidden" name="hdnParentTrans_Type" value="' + ParentTransType + '" /> <input type="hidden" name="hdnItemID" value="' + value.Test_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Test_Name + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + value.Group_Category + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + value.Test_Name + '</td><td>' + remarks + '</td><td>' + '<input type="text" name="txtQty" disabled=disabled value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td></td><td>' + globalTestRate + '</td></tr>'
                        }
                        var test_array = $('#tblDetails').find('input[name=hdnItemID][value="' + value.TestID + '"]');
                        if (test_array.length > 0) {
                            alert('This test already added!');
                            return false;
                        }
                        else {
                            $('#tblDetails tbody').append(rows);
                            $('.ddlDoctor').select2();
                            $('input[name="DisAmount"]').attr('disabled', true);
                            if (Alloweditrate == "true") {
                                $("#amnt" + rowIndex).attr('contenteditable', true);
                            }
                            else {
                                $("#amnt" + rowIndex).attr('contenteditable', false);
                            }

                            CalculateSummarieDiscountPerWise(rowIndex);

                            $('#tbltestModelTable tbody').append(rowstbl);
                        }
                        setTimeout(function () {
                            $(arr).filter(function (i, n) {

                                var company_id = 0;
                                if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || localStorage.OPD_Panel_ID == 0 || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                                if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || localStorage.IPD_PAnel_ID == 0 || typeof localStorage.IPD_PAnel_ID === 'undefined')
                                    company_id = localStorage.OPD_Panel_ID;
                                var lblPatientCategory = $('#lblPatientCategory').text();
                                var lblIn_Patient_Category = $('#lblPatientDiscountType').text();
                                if ((lblPatientCategory == "Sehat Sahulat Card") || (lblIn_Patient_Category == "Sehat Sahulat Card")) {
                                    company_id = "39";
                                }
                                if (n.Panel_ID == company_id) {
                                    $('#txtDisPer').val(n.Discount);
                                    CalculateSummariesMaster(false);
                                    return false;
                                }
                            });
                        }, 500);

                        var panel = $("#ddlpanel").val();
                        if (panel != 0 || panel != "0") {
                            if (value.Test_ID != 0) {
                                GetpanelTestRate(panel, value.Test_ID);
                            }
                            else {
                                GetpanelGroupTestRate(panel, value.Group_Category);
                            }
                        }

                    });
                }, function (err) { });
            }
            function AddRadialogyTest(maindpt) {
                debugger;
                localStorage.Disc_Zero = 0;
                localStorage.OnlyPercentage = 0;
                var remarks = $('#Remarks').val();
                var pat_id = $('#txtMRNo').val();
                $("#btnXray").removeClass("btn-danger").addClass("btn-info");
                $('#btnultrasound').removeClass('btn-danger').addClass('btn-info');
                $("#btnCTscan").removeClass("btn-danger").addClass("btn-info");
                var Result = 'Result';
                var test = $('#ddlTestList').val();
                var date = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                var IsRotationShow = $('#divRotation').is(":visible");
                var Rotation_ID = IsRotationShow ? $('#ddlRotation option:selected').val() : "0";
                var Rotation_Name = IsRotationShow ? $('#ddlRotation option:selected').text() : " ";
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: test, maindpt: maindpt, pat_id: pat_id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        var data = JSON.parse(data.d);
                        TestMainDepartmentName = data[0].MainDepartment;
                        var Rate = data[0].Rate;
                        var TestName = data[0].Test_Name;
                        var Category_ID = data[0].Depart_ID;
                        var rotation = $('#ddlRotation').val;

                        var DisAmt = data[0].Disc;//20 %
                        var categ = $('#ddlMainTestDepartment').val();

                        var DisAmt = data[0].Disc;
                        var percentage_Amt = data[0].Total_Disc_Amt;
                        var RemainDiscAmt = data[0].Remaining_Amount;
                        if (percentage_Amt == "0.0000") {

                            DisAmt = data[0].Disc;
                            localStorage.OnlyPercentage = 1;
                            if (RemainDiscAmt != "0.0000") {
                                localStorage.OnlyPercentage = 0;
                            }
                        }
                        if (DisAmt == "0.0000") {
                            localStorage.Disc_Zero = 1;


                        }
                        if (DisAmt == "There is no row at position 0.") {
                            DisAmt = "0.00";

                        }
                        else {

                            if (categ == "002") {
                                if (isUltraSoundCompleted == true) {
                                    DisAmt = "0.00";
                                }
                                if (max_Total_Dic_Amt_Ultra != 0) {
                                }
                                else {
                                    max_Total_Dic_Amt_Ultra = data[0].Total_Disc_Amt;
                                }
                            }
                            if (categ == "003") {
                                debugger
                                if (isXrayCompleted == true) {
                                    DisAmt = "0.00";
                                }
                                if (max_Total_Dic_Amt_Xray != 0) {
                                }
                                else {
                                    max_Total_Dic_Amt_Xray = data[0].Total_Disc_Amt;
                                }
                            }
                            if (categ == "004") {
                                debugger
                                if (isCTScanCompleted == true) {
                                    DisAmt = "0.00";
                                }
                                if (max_Total_Dic_Amt_ct_Scan != 0) {
                                }
                                else {
                                    max_Total_Dic_Amt_ct_Scan = data[0].Total_Disc_Amt; //1000

                                }
                            }
                        }
                        //1000
                        Rate = (Test_Rate != 0) ? Test_Rate : Rate;
                        if (Rate == null || Rate == "")
                            Rate = 0;
                        if (globalTestRate == 0 || globalTestRate == "" || globalTestRate == null) {
                            globalTestRate = Rate;
                        }
                        var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnDisPer" value="' + DisAmt + '" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + globalTestRate + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + ',' + Rotation_Name + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" value="1" disabled style="width: 45px !important;"  onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td id="amnt' + rowIndex + '" name="amnt" style="text-align:Right;"onkeypress="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + globalTestRate + ' </td><td> <input type="text" name="DisPer" value="' + DisAmt + '"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">  </td><input type="text" name="DocShare" value="' + 0 + '"  style="width: 75px !important;"/></td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" onchange="GetDocAgreementValuess(this)" name="ddlDoctor" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + date + '"/>' + date + ' </td> </tr>'
                        var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '.' + Rotation_Name + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" disabled=disabled onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + globalTestRate + '" /></td><td>' + globalTestRate + '</td><input type="text" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/><input type="hidden" name="Main_Department" value="' + maindpt + '" /></td></tr>'
                        debugger;
                        $('#tblDetails tbody').append(rows);
                        $('.ddlDoctor').select2();
                        $('#tbltestModelTable tbody').append(rowstbl);
                        debugger;
                        $('input[name="DisAmount"]').attr('disabled', true);
                        if (Alloweditrate == "true") {
                            $("#amnt" + rowIndex).attr('contenteditable', true);
                        }
                        else {
                            $("#amnt" + rowIndex).attr('contenteditable', false);
                        }
                        CalculateSummarieDiscountPerWise(rowIndex);
                        setTimeout(function () {
                            $(arr).filter(function (i, n) {

                                var company_id = 0;
                                if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || localStorage.OPD_Panel_ID == 0 || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                                if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || localStorage.IPD_PAnel_ID == 0 || typeof localStorage.IPD_PAnel_ID === 'undefined')
                                    company_id = localStorage.OPD_Panel_ID;
                                var lblPatientCategory = $('#lblPatientCategory').text();
                                var lblIn_Patient_Category = $('#lblPatientDiscountType').text();
                                if ((lblPatientCategory == "Sehat Sahulat Card") || (lblIn_Patient_Category == "Sehat Sahulat Card")) {
                                    company_id = "39";
                                }
                                if (n.Panel_ID == company_id) {
                                    $('#txtDisPer').val(n.Discount);
                                    CalculateSummariesMaster(false);
                                    return false;
                                }
                            });
                        }, 500);
                        var panel = $("#ddlpanel").val();
                        if (panel != 0 || panel != "0") {
                            GetpanelTestRate(panel, test);
                        }

                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            function AddProcedureTest() {
                var remarks = $('#Remarks').val();
                var Result = 'Result';
                var test = $('#ddlTestList').val();
                var TestName = $('#ddlProcedure').find('option:selected').text();
                var testgg = '<%= DateTime.Now.ToString("dd/MM/yyyy  h:m:s A") %>';
                var dateValue = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetTestMainDepartmentDetails",
                    data: JSON.stringify({ TestID: test }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var data = JSON.parse(data.d);
                        TestMainDepartmentName = data[0].MainDepartment;
                        var Rate = data[0].Rate;
                        var TestName = data[0].Test_Name;
                        var Category_ID = data[0].Category_ID;
                        Rate = (Test_Rate != 0) ? Test_Rate : Rate;
                        if (Rate == null || Rate == "")
                            Rate = 0;
                        var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnDisPer" value="0"/><input type="hidden" name="hdnDisAmount" / value="0.00" ><input type="hidden" name="hdnNet_Amount" value=' + Rate + ' /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '</td><td>' + remarks + '</td><td><input type="text" disabled name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + Rate + '" /></td><td  id="amnt' + rowIndex + '" name"amnt" style="text-align:Right;"> ' + Rate + ' </td><td> <input type="text" name="DisPer" value="0"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + ' </td> </tr>'
                        var rowstbl = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="' + (CheckInPatientObject == true ? 'InPatient' : '') + '" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + test + '" /> <input type="hidden" name="hdnItemName" value="' + TestName + '" /> <input type="hidden" name="hdnItemType" value="Test" /> <input type="hidden" name="hdnCategory_ID" value="' + Category_ID + '" /> <input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + TestName + '</td><td  id="amnt' + rowIndex + '" name"amnt">' + Rate + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td></tr>'
                        var test_array = $('#tblDetails').find('input[name=hdnItemID][value="' + test + '"]');
                        if (test_array.length > 0) {
                            alert('This test already added!');
                            return false;
                        }
                        else {
                            $('#tblDetails tbody').append(rows);
                            $('#tbltestModelTable tbody').append(rowstbl);

                            $('input[name="DisAmount"]').attr('disabled', true)
                            CalculateSummarieDiscountPerWise(rowIndex);

                        }
                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            debugger;
            var temp_Patient = 0;
            debugger;
            function AddAllTest() {
                debugger;
                localStorage.Disc_Zero = 0;

                debugger;
                var maindpt = $('#ddlMainTestDepartment').val();
                var CheckTest = $('#ddlTestList').val();
                var patient_ID = $('#hdfPatient_ID').val();
                var test_Name = $('#ddlTestList').find('option:selected').text();
                var matchingInputs = $('#tbltestModelTable input[name="hdnItemName"]').filter(function () {
                    return $(this).val() === test_Name;
                });
                var MatchingInputsDetailTable = $('#tblDetails input[name="hdnItemName"]').filter(function () {
                    return $(this).val() === test_Name;
                });

                if (matchingInputs.length > 0 || MatchingInputsDetailTable.length > 0) {
                    alert('Found ' + matchingInputs.length + ' matching input(s) with value: ' + test_Name);
                    return;
                } else {
                    var patient_category_description = $('#lblPatientCategory').val();
                    var inpatientCat = $('#lblPatientDiscountType').text();
                    if (inpatientCat != "") {
                        patient_category_description = inpatientCat;
                    }
                    if (patient_id_old != 0 || patient_id_old == null) {
                        patient_ID = patient_id_old;
                    }
                    if (CheckTest != 0 || CheckTest != null) {

                        $.ajax({
                            type: "post",
                            url: "BillingProcess.aspx/GetTestRate",
                            data: JSON.stringify({
                                "Patient_ID": patient_ID,
                                "Test_Name": test_Name,
                                "Patient_Category_Description": patient_category_description
                            }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (response) {
                                debugger;
                                if (response.d != 0) {
                                    globalTestRate = response.d;
                                }
                                else {
                                    globalTestRate = 0;
                                }
                                if (maindpt == "001") {
                                    AddLabTest(maindpt);
                                }
                                else if (maindpt == "002") {
                                    AddRadialogyTest(maindpt);
                                }
                                else if (maindpt == "003") {
                                    AddRadialogyTest(maindpt);
                                }
                                else if (maindpt == "004") {
                                    AddRadialogyTest(maindpt);
                                }
                                else {
                                    AddLabTest(maindpt);
                                }

                            },
                            failure: function (response) { }
                        });
                    }
                }

            }
            var category = "0";
            function LoadTestByDepartment() {
                var maindpt = $('#ddlMainTestDepartment').val();
                if (maindpt == "0") {
                    $('#ddlTestList').val("");
                    $('#ddlTestList').text("");
                    $('#divRotation').hide();
                }
                if (maindpt == "001") {
                    FillLabTests();
                    $('#divRotation').hide();
                    category = "001";
                }
                else if (maindpt == "002") {
                    FillTestsByCategory('002');
                    category = "002";
                }
                else if (maindpt == "003") {
                    FillTestsByCategory('003');
                    category = "003";
                }
                else if (maindpt == "004") {
                    FillTestsByCategory('004');
                    category = "004";
                }
                else if (maindpt == "005") {
                    FillProcedure("005");
                    $('#divRotation').hide();
                    category = "005";
                }
                else if (maindpt == "006") {
                    FillProcedure("006");
                    $('#divRotation').hide();
                    category = "006";
                }
                else if (maindpt == "007") {
                    FillProcedure("007");
                    $('#divRotation').hide();
                    category = "007";
                }
                else if (maindpt == "010") {
                    FillProcedure("010");
                    $('#divRotation').hide();
                    category = "010";
                }
                else if (maindpt == "009") {
                    FillProcedure("009");
                    $('#divRotation').hide();
                    category = "009";
                }
                else if (maindpt == "008") {
                    GetCardioTests();
                    $('#divRotation').hide();
                    category = "008";
                }
            }
            function GetCardioTests() {
                var options = '<option value="0" >Please Select</option>';
                PageMethods.GetCardioTests(function (Tests) {
                    $.each(JSON.parse(Tests), function (key, value) {
                        options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                    });
                    $('#ddlTestList').html(options);
                    $('#ddlTestList').select2();
                    localStorage.TestForCategoryWiseSelections = options;
                });
            }
            function FillLabTests() {
                var options = '<option value="0" >Please Select</option>';
                PageMethods.GetLabTests(function (Tests) {
                    $.each(JSON.parse(Tests), function (key, value) {
                        options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                    });
                    $('#ddlTestList').html(options);
                    $('#ddlTestList').select2();
                    localStorage.TestForCategoryWiseSelections = options;
                });
            }
            function FillMainTestDepartment() {
                var options = '<option value="0" >Select Main Department</option>';
                PageMethods.FillTestMainDepartment(function (Tests) {
                    $.each(JSON.parse(Tests), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlMainTestDepartment').html(options);
                });
            }
            function FillShareType() {
                var options = ''
                PageMethods.fillSahreTypes(function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    shareTypeGlobalResponse = options;
                });
                return options;
            }
            function FillChargePolicy() {
                //var options = ''
                PageMethods.GetChargePolicy(function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddlChargePolicy').html(options);
                    $('#ddlChargePolicy').val('11');
                    $('#ddlChargePolicy').attr('disabled', true);
                });
            }

            function LoadMainDepartment() {
                //var options = ''
                PageMethods.GetMainDepartment(function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#txtMaindepartment').html(options);
                    $('#txtMaindepartment').attr('disabled', true);
                });
            }
            function LoadBillDepartment() {
                //var options = ''
                PageMethods.GetSubdepartments(function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#BillDepartment').html(options);
                    $('#BillDepartment').select2();
                    //$('#BillDepartment').attr('disabled', true);
                });
            }
            function LoadBillPatCategory() {
                //var options = ''
                PageMethods.GetMainDepartment(function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#BillCategory').html(options);
                    $('#BillCategory').select2();
                    //$('#BillDepartment').attr('disabled', true);
                });
            }

            function Share_Doctor() {
                var doctorShareList = document.getElementById('Doctor_Share_Table');
                var currentRowIndex = doctorShareList.rows.length - 1;
                var html = '<tr>' +
                    '<td>' +
                    '<select id="ddlDoctorList' + currentRowIndex + '"">' + Doctor_Name + '</select>' +
                    '</td>' +
                    '<td>' +
                    '<select id="ddlShareType' + currentRowIndex + '"">' + shareTypeGlobalResponse + '</select>' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="DoctorAmount" id="DoctorAmount' + currentRowIndex + '"" onkeyup="calculateDoctorShare()"/>' +
                    '</td>' +
                    '<td>' +
                    '<a href="javascript:void(0)" onclick="DeleteShareDoctor(this)">Delete</a>' +
                    '</td>' +
                    '</tr>';
                $('#Doctor_Share_Table').append(html);
            }
            function DeleteShareDoctor(reference) {
                if (confirm("Are you sure you want to delete")) {
                    $($(reference).parents('tr')[0]).remove();
                    calculateDoctorShare();
                }
            }
            function Populate() {
                $('#TestModel').modal({
                    backdrop: 'static'
                });
                $('#tbltestModelTable tbody tr').remove();
            }
            function Print(divID) {
                var contents = $("#" + divID).html();
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
            var CheckInPatientObject = false;
            function OpenRecord() {
                var Bill_ID = '<%= Request.QueryString["Bill_ID"]%>';
                if (Bill_ID.length > 0) {
                    LoadBill(Bill_ID);
                }
            }
            var IPDDiscount = "";
            debugger
            function LoadBill(Bill_ID) {

                PageMethods.LoadBillHeader(Bill_ID, function (resp) {
                    debugger
                    var data = JSON.parse(resp);
                    var TrnsDate = new Date(parseInt(data[0].Bill_Date.substr(6)));
                    TrnsDate = moment(TrnsDate).format('DD-MMM-YYYY');
                    $('#hdfPatient_ID').val(data[0].Patient_ID);
                    $('#txtBillNo').val(data[0].Bill_No);
                    $("#txtBillDate").val(TrnsDate);
                    $('#txtRemarks').val(data[0].Remarks);
                    $('#txtTotalPayable').val(data[0].Total_Amount);
                    $('#txtDisPer').val(parseFloat(data[0].Discount_Percentage.toFixed(2)));
                    $('#hdntxtDisPer').val(data[0].Discount_Percentage);
                    $('#txtDisAmt').val(data[0].Discount_Amount);
                    $('#txtNetPayable').val(data[0].Net_Amount);
                    $('#txtAmountReceived').val(data[0].Received_Amount);
                    $('#txtBalances').val(data[0].Balance_Amount);
                    $('#ddlChargePolicy').val(data[0].Charge_Policy);



                    $('#txt_balance').val(data[0].Previous_Balance);
                    $('#txtprevious_paid').val(data[0].Previous_Paid);
                    $('#txtTotalDoctorShare').val(data[0].Total_Doctor_Share);
                    $('#txtOver_and_Above').val(data[0].Over_and_Above);
                    $('#txtcashinhand').val(data[0].Cash_In_Hand);
                    $('#txtbankcash').val(data[0].Bank_Cash);
                    debugger;
                    LoadSalesTaxDefinitions(
                        data[0].Sales_Tax_ID,
                        data[0].Sales_Tax_Percentage
                    );

                    $('#BillDepartment').html(
                        $('<option>', {
                            value: data[0].Bill_Department,
                            text: data[0].Bill_Department_text
                        })
                    );
                    $('#BillDepartment').attr('disabled', true);
                    $('#BillCategory').html(
                        $('<option>', {
                            value: data[0].Bill_Category,
                            text: data[0].Bill_Category_text
                        })
                    );
                    $('#BillCategory').attr('disabled', true);
                    var status = data[0].Status;
                    if (status === 'Approved') {
                        $('#btnPrintVoucher').show();
                    } else {
                        $('#btnPrintVoucher').hide();
                    }
                    if (status != "Approved") {
                        $('#btnApprove').show();
                    }

                    setTimeout(function () {
                        $('#ddlpanel').val(data[0].Panel_Id).trigger('change');
                    }, 1000)

                    setTimeout(function () {
                        $('#ddlCashInHand').val(data[0].Cash_In_Hand_Account).trigger('change');
                    }, 1000)
                    setTimeout(function () {
                        $('#ddl_Bank').val(data[0].Bank_Account).trigger('change');
                    }, 1000)
                    setTimeout(function () {
                        $('#txtMaindepartment').val(data[0].Main_Department).trigger('change');
                    }, 1000)


                    setTimeout(function () {
                        $('#ddlcasher').val(data[0].Casher).trigger('change');
                    }, 1000)
                    setTimeout(function () {
                        $('#ddlReffered_By').val(data[0].Referred_By);
                    }, 1000)

                    var Bill_ID = '<%= Request.QueryString["Bill_ID"]%>';
                    if (Bill_ID != "") {
                        IPDDiscount = data[0].Patient_Discount_Type;
                        $('#lblPatientDiscountType').text(data[0].Patient_Discount_Type);
                    }




                    FillTokenInputForMRNo();
                    LoadBillDetails(Bill_ID);
                    LoadDoctorShare(Bill_ID);

                    $('#ddlReffered_By').val(data[0].Referred_By).trigger('change');
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }
            debugger;
            function LoadBillDetails(Bill_ID) {
                debugger;
                PageMethods.LoadBillDetails(Bill_ID, function (resp) {
                    debugger;
                    var data = (JSON.parse(resp));
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var Description = '';
                    $.each(data, function (key, value) {

                        var TestDate = value.Issue_Date
                        if (TestDate == null) {
                            TestDate = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                        }
                        else {
                            TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Issue_Date.substring(6, 19))))
                        }
                        debugger;
                        rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td id="btndeletes"> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)" id="btnDelete" name="btndelBill">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="' + value.ParentTrans_Name + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.Item_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Item_Name + '" /> <input type="hidden" name="hdnProcedure" value="" /><input type="hidden" name="hdnItemType" value="' + value.Item_Type + '" /><input type="hidden" name="hdnDisPer" value=' + parseFloat(value.Discount_Percentage.toFixed(6)) + '><input type="hidden" name="hdnDisAmount" value=' + parseFloat(value.Discount_Amount.toFixed(6)) + '><input type="hidden" name="hdnNet_Amount" value=' + parseFloat(value.Net_Amount.toFixed(6)) + '><input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />' + value.Item_Name + '</td><td>' + value.Remarks + '</td><td><input type="text" name="txtQty" value="' + value.Qty + '" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td  id="amnt' + rowIndex + '" name"amnt" style="text-align:Right;"> ' + value.Amount + ' </td><td> <input type="text" name="DisPer" value="' + parseFloat(value.Discount_Percentage.toFixed(2)) + '"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="' + parseFloat(value.Discount_Amount.toFixed(2)) + '" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"> ' + parseFloat(value.Net_Amount.toFixed(0)) + ' </td><td> <input type="text" id = "ds' + key + '" name="Docshare" value="' + parseFloat(value.Doctor_Share.toFixed(0)) + '" style="width: 75px !important;" onkeyup="calculateDoctorShare(' + rowIndex + ')"/> </td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + parseFloat(value.Hospital_Share.toFixed(0)) + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + rowIndex + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)"  class="ddlDoctor" >' + doctors + '</select> <input type="hidden" name="Main_Department" value="' + value.Test_Main_Department + '" /></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td></tr>'
                        debugger;


                        $('#tblDetails tbody').append(rows);
                        //1 rightk
                        if (Alloweditrate == "true") {
                            $("#amnt" + rowIndex).attr('contenteditable', true);
                        }
                        else {
                            $("#amnt" + rowIndex).attr('contenteditable', false);
                        }
                        updates();
                        $('input[name="DisAmount"]').attr('disabled', true);
                        $('#ddldoctor' + rowIndex).val(value.Doctor_id);

                        $('#ddldoctor' + key + '').select2();
                        rowIndex++;

                    });
                    $('#btnSave').val('Update');
                    $('#btnPrint').show();


                },
                    function (error) {
                        alert(error.get_message());
                    })
            }


            debugger;
            function FetchAllPreviousBill(in_Pat) {
                debugger;
                PageMethods.LoadAllBillDetails(in_Pat, function (resp) {
                    debugger;
                    var data = (JSON.parse(resp));
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var Description = '';
                    $.each(data, function (key, value) {

                        var TestDate = value.Issue_Date
                        if (TestDate == null) {
                            TestDate = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                        }
                        else {
                            TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Issue_Date.substring(6, 19))))
                        }
                        rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td id="btndeletes"> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)" id="btnDelete" name="btndelBill">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="' + value.ParentTrans_Name + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.Item_ID + '" /> <input type="hidden" name="hdnItemName" value="' + value.Item_Name + '" /> <input type="hidden" name="hdnProcedure" value="" /><input type="hidden" name="hdnItemType" value="' + value.Item_Type + '" /><input type="hidden" name="hdnDisPer" value=' + parseFloat(value.Discount_Percentage.toFixed(6)) + '><input type="hidden" name="hdnDisAmount" value=' + parseFloat(value.Discount_Amount.toFixed(6)) + '><input type="hidden" name="hdnNet_Amount" value=' + parseFloat(value.Net_Amount.toFixed(6)) + '><input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />' + value.Item_Name + '</td><td>' + value.Remarks + '</td><td><input type="text" name="txtQty" value="' + value.Qty + '" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td  id="amnt' + rowIndex + '" name"amnt" style="text-align:Right;"> ' + value.Amount + ' </td><td> <input type="text" name="DisPer" value="' + parseFloat(value.Discount_Percentage.toFixed(2)) + '"style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="' + parseFloat(value.Discount_Amount.toFixed(2)) + '" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"> ' + parseFloat(value.Net_Amount.toFixed(0)) + ' </td><td> <input type="text" id = "ds' + key + '" name="Docshare" value="' + parseFloat(value.Doctor_Share.toFixed(0)) + '" style="width: 75px !important;" onkeyup="calculateDoctorShare(' + rowIndex + ')"/> </td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + parseFloat(value.Hospital_Share.toFixed(0)) + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + rowIndex + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)"  class="ddlDoctor" >' + doctors + '</select> <input type="hidden" name="Main_Department" value="' + value.Test_Main_Department + '" /></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td></tr>'

                        $('#tblDetails tbody').append(rows);
                        CalculateSummarieDiscountPerWise(rowIndex);
                        rowIndex++;

                    });
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }


            function getOptions() {
            }
            function LoadDoctorShare(Bill_ID) {
                PageMethods.LoadDocShare(Bill_ID, function (resp) {
                    var data = (JSON.parse(resp));
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#Doctor_Share_Table tbody tr').length)));
                    var Description = '';
                    $.each(data, function (key, value) {
                        rows = '<tr><td><select id="ddlDoctorList' + key + '" style="width: 122px !important;"> ' + doctorListGlobal + ' onkeyup="calculateDoctorShare(this)" </select></td><td><select id="ddlShareType' + key + '" style="width: 122px !important;"> ' + shareTypeGlobalResponse + ' onkeyup="calculateDoctorShare(this)" </select></td><td><input type="text" name="DoctorAmount" id="DoctorAmount' + key + '" value="' + parseFloat(value.Amount) + '" style="width: 65px !important;" onkeyup="calculateDoctorShare(this)"/></td><td> <a href="javascript:void(0)" onclick="DeleteShareDoctor(this)">Delete</a></td></tr>';
                        $('#Doctor_Share_Table tbody').append(rows);
                        rowIndex++;
                    });
                    for (var i = 0; i < data.length; i++) {
                        var doctorID = data[i].Emp_ID;
                        $('#ddlDoctorList' + i + '').val(doctorID);
                    }
                    for (var i = 0; i < data.length; i++) {
                        var Sharetype = data[i].Share_type;
                        $('#ddlShareType' + i + '').val(Sharetype);
                    }
                    calculateDoctorShare();
                    $('#btnSave').val('Update');
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }
            function LoadBillPackagesDetails(BillNo) {
                PageMethods.LoadBillPackagesDetails(BillNo, function (resp) {
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }
            var ExcludedItem_List = [];
            function validateSave() {
                var proceed = true;
                var Totaldoctorshare = isNaN($('#txtTotalDoctorShare').val()) == true ? 0 : $('#txtTotalDoctorShare').val();
                var Totaldoctordistribution = $('#txtDoctorTotalDistribution').val();
                var policy = $('#ddlChargePolicy').val();

                if (policy == "0") {
                    alert("Please Select Charge Policy");
                    proceed = false;
                }
                return proceed;
            }
            var Consumed_Lab = 0;
            var Consumed_Ultra_Sound = 0;
            var Consumed_Xray = 0
            var Consumed_Scan = 0;
            var Consumed_Blood = 0
            var Consumed_Item = 0;
            var Consumed_Procedure = 0;
            var Consumed_Package = 0;
            debugger;
            async function SaveRecord() {
                debugger;
                if (validateSave()) {
                    var val = document.getElementById("hdnDuplicateCheck").value;
                    var returnVal = false;
                    if (val == "0")//no duplicate
                    {
                        $('#btnSave').attr('disabled', 'disabled');
                        document.getElementById("hdnDuplicateCheck").value = "1";
                        var Bill_ID = '';
                        var Bill_Type = '';
                        Bill_ID = '<%= Request.QueryString["Bill_ID"]%>'
                        Bill_Type = '<%= Request.QueryString["Type"]%>'
                        if (Bill_ID == '')
                            Bill_ID = 0
                        var Details = [];
                        var Share = [];
                        debugger;
                        var Patient_ID = $('#txtMRNo').val();
                        var Opd_id = $('#hdnOpd_id').val();
                        var hdn_docid = $("#hdn_docid").val();
                        var opd_procedure = $('#hdn_opd_procedure').val();
                        var finalbill = $('#hdn_finalBill').val();
                        var Bill_Date = $('#txtBillDate').val();
                        var Remarks = $('#txtRemarks').val();
                        var TotalPayable = $('#txtTotalPayable').val();
                        var Discount_Percentage = $('#txtDisPer').val();
                        Discount_Percentage = $('#hdntxtDisPer').val();
                        var Discount_Amount = $('#txtDisAmt').val();
                        var Net_Amount = $('#txtNetPayable').val();
                        var Received_Amount = $('#txtAmountReceived').val();
                        var Balance_Amount = $('#txtBalances').val();
                        var Previous_Balance = $('#txtPreviousBlnc').val();
                        var Previous_Paid = $('#txtprevious_paid').val();
                        var Over_and_Above = $('#txtOver_and_Above').val();
                        var Cash_In_Hand = $('#txtcashinhand').val();
                        var Cash_In_Hand_Account = $('#ddlCashInHand').val();
                        var Bank_Account = $('#ddl_Bank').val();
                        var Bank_Cash = $('#txtbankcash').val();
                        var Main_Department = $('#txtMaindepartment').val();
                        debugger;
                        var PackageType = $('#hdn_pkgtype').val();
                        var PackageName = $('#hdn_pkgname').val();
                        var BillDepartment = $('#BillDepartment').val();
                        var BillCategory = $('#BillCategory').val();
                        var bomTotalValue = $('#bomTotalValue').val();
                        var selectedBranchId = $('#ddlUserBranch').val();
                        var Panel_Id = $('#ddlpanel').val();
                        if (bomTotalValue == undefined || bomTotalValue == null || bomTotalValue == "") {
                            bomTotalValue = 0.00
                        }
                        if (PackageType == "There is no row at position 0.") {
                            PackageType = "";
                        }
                        if (PackageName == "There is no row at position 0.") {
                            PackageName = "";
                        }


                        if (Previous_Balance == '') {
                            Previous_Balance = 0.00
                        }
                        if (Previous_Paid == '') {
                            Previous_Paid = 0.00
                        }
                        if (Cash_In_Hand == '') {
                            Cash_In_Hand = 0.00
                        }
                        if (Bank_Cash == '') {
                            Bank_Cash = 0.00
                        }
                        if (Over_and_Above == '') {
                            Over_and_Above = 0.00
                        }
                        if (Balance_Amount > 0.00) {
                            var result = await Swal.fire({
                                icon: 'warning',
                                title: 'Are you sure?',
                                text: 'Are you sure to save bill with Balance ' + Balance_Amount,
                                showCancelButton: true,
                                confirmButtonColor: '#d33',
                                cancelButtonColor: '#3085d6',
                                confirmButtonText: 'Yes',
                                cancelButtonText: 'Cancel',
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            })
                            if (!result.isConfirmed) {
                                $("#btnSave").prop("disabled", false);
                                document.getElementById("hdnDuplicateCheck").value = "0";
                                return;
                            }
                        }


                        var ChargePolicy = ddlChargePolicy.value;
                        var referred_by_doctor = $('#ddlReffered_By').val();
                        var Casher = $('#ddlcasher').val();

                        var bomItems = [];
                        $('#tblBOM tbody tr').each(function () {

                            if ($(this).find('td[colspan]').length) return;

                            var BOMDetailID = parseInt($(this).find('input[name="hdnBOMDetailID"]').val()) || 0;
                            var ItemID = parseInt($(this).find('input[name="hdnBOMItemID"]').val()) || 0;
                            var ItemCode = $(this).find('input[name="hdnBOMItemCode"]').val() || '';
                            var Description = $(this).find('input[name="hdnBOMDescription"]').val() || '';
                            var Qty = parseFloat($(this).find('input[name="hdnBOMQty"]').val()) || 0;
                            var Unit = $(this).find('input[name="hdnBOMUnit"]').val() || '';
                            var RecipeCostPerUnit = parseFloat($(this).find('input[name="hdnBOMRecipeCost"]').val()) || 0;
                            var CurrentAvgCost = parseFloat($(this).find('input[name="hdnBOMAvgCost"]').val()) || 0;
                            var RuntimeCost = parseFloat($(this).find('input[name="hdnBOMRuntimeCost"]').val()) || 0;
                            var Batch_No = $(this).find('input[name="hdnBOMBatchNo"]').val() || '';
                            var BaseUnitQty = $(this).find('input[name="hdnBOMBaseUnitQty"]').val();
                            BaseUnitQty = BaseUnitQty === '' ? null : parseFloat(BaseUnitQty);

                            bomItems.push({
                                BOMDetailID: BOMDetailID,
                                ItemID: ItemID,
                                ItemCode: ItemCode,
                                Description: Description,
                                Qty: Qty,
                                Unit: Unit,
                                RecipeCostPerUnit: RecipeCostPerUnit,
                                CurrentAvgCost: CurrentAvgCost,
                                RuntimeCost: RuntimeCost,
                                Batch_No: Batch_No,
                                BaseUnitQty: BaseUnitQty
                            });
                        });
                        $.each($('#Doctor_Share_Table tbody tr'), function (key, value) {
                            var Doc_ID = $(value).find('td:eq(0) #ddlDoctorList' + key + '').val();
                            var Share_type = $(value).find('td:eq(1) #ddlShareType' + key + '').val();
                            var Doc_Amount = $(value).find('input[name="DoctorAmount"]').val();
                            Share.push({
                                Doc_ID: Doc_ID, Doc_Amount: Doc_Amount, Share_type: Share_type
                            });
                        });
                        var isAmountZero = false;
                        $.each($('#tblDetails tbody tr'), function (key, value) {

                            var ParentTrans_ID = $(value).find('input[name="hdnParentTrans_ID"]').val();
                            var ParentTrans_Name = $(value).find('input[name="hdnParentTrans_Name"]').val();
                            var ParentTrans_Type = $(value).find('input[name="hdnParentTrans_Type"]').val();
                            var ItemID = $(value).find('input[name="hdnItemID"]').val();
                            var Remarks = $(value).find('td:eq(3)').html();
                            var Qty = $(value).find('input[name="txtQty"]').val();
                            var Category_ID = $(value).find('input[name="hdnCategory_ID"]').val();
                            var ItemName = $(value).find('input[name="hdnItemName"]').val();
                            var ItemType = $(value).find('input[name="hdnItemType"]').val();
                            var DocShare = $(value).find('input[name="DocShare"]').val();
                            var HosShare = $(value).find('input[name="HocShare"]').val();
                            var Doctor_id = $(value).find('select[name="ddlDoctor"]').val();
                            var Amount = $($(value).find('td')[5]).text();
                            if (Amount.trim() == 0) {
                                isAmountZero = true;
                            }
                            var RecommendedByDoctor = $(value).find('input[name="hdnRecommendedByDoctor"]').val();
                            var ExcludedFromPayment = false;
                            var DisPer = $(value).find('input[name="hdnDisPer"]').val();
                            var DisAmt = $(value).find('input[name="hdnDisAmount"]').val();
                            var isProcedure = $(value).find('input[name="hdnProcedure"]').val();
                            var MainDepartment = $(value).find('input[name="Main_Department"]').val();
                            var Test_CreatedDate = $(value).find('input[name="hdnTestCreatedDate"]').val();

                            var docShareVal = parseFloat(DocShare) || 0;
                            var hosShareVal = parseFloat(HosShare) || 0;
                            var netAmountVal = parseFloat($(value).find('input[name="hdnNet_Amount"]').val()) || 0;
                            var totalShare = docShareVal + hosShareVal;

                            if (totalShare > netAmountVal && netAmountVal > 0) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Validation Failed!',
                                    text: 'Row ' + (parseInt(key) + 1) + ': Doctor Share (' + docShareVal.toFixed(2) + ') + Hospital Share (' + hosShareVal.toFixed(2) + ') = ' + totalShare.toFixed(2) + ' exceeds Net Amount (' + netAmountVal.toFixed(2) + ')',
                                    confirmButtonText: 'OK',
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                $('#btnSave').prop('disabled', false);
                                document.getElementById("hdnDuplicateCheck").value = "0";
                                return false;
                            }

                            if (MainDepartment == "001") {
                                Consumed_Lab += parseFloat(DisAmt);
                            }
                            if (MainDepartment == "002") {
                                Consumed_Ultra_Sound += parseFloat(DisAmt);
                            }
                            if (MainDepartment == "003") {
                                Consumed_Xray += parseFloat(DisAmt);
                            }

                            if (MainDepartment == "004") {
                                Consumed_Scan += parseFloat(DisAmt);
                            }
                            if (MainDepartment == "005") {
                                Consumed_Blood += parseFloat(DisAmt);
                            }


                            if (ParentTrans_Type == "Package") {

                                Consumed_Package += parseFloat(DisAmt);
                            }
                            else {
                                if (isProcedure == "" || isProcedure == "null" || isProcedure == "0" || typeof isProcedure === 'undefined') {
                                    if (ItemType == "Item" || ItemType == "Service") {
                                        Consumed_Item += parseFloat(DisAmt);
                                    }


                                }

                                else {
                                    Consumed_Procedure += parseFloat(DisAmt);
                                }
                            }
                            if (ParentTrans_Type == "Package" && ItemType == "Test") {
                                MainDepartment = '001';
                            }
                            var Net_Amount = $(value).find('input[name="hdnNet_Amount"]').val();

                            Net_Amount = (Qty * Amount) - DisAmt;
                            Details.push({ ParentTrans_ID: ParentTrans_ID, ParentTrans_Name: ParentTrans_Name, ParentTrans_Type: ParentTrans_Type, ItemID: ItemID, CategoryID: Category_ID, ItemName: ItemName, ItemType: ItemType, Amount: Amount, RecommendedByDoctor: RecommendedByDoctor, ExcludedFromPayment: ExcludedFromPayment, DisPer: DisPer, DisAmt: DisAmt, Net_Amount: Net_Amount, Qty: Qty, Remarks: Remarks, MainDepartment: MainDepartment, Consumed_Lab: Consumed_Lab, Consumed_Ultra_Sound: Consumed_Ultra_Sound, Consumed_Xray: Consumed_Xray, Consumed_Scan: Consumed_Scan, Consumed_Blood: Consumed_Blood, Consumed_Item: Consumed_Item, Consumed_Procedure: Consumed_Procedure, Consumed_Package: Consumed_Package, DocShare: DocShare, HosShare: HosShare, Doctor_id: Doctor_id, Test_CreatedDate: Test_CreatedDate });
                        });

                        var totalDocShare = 0;
                        var totalHosShare = 0;
                        var totalNetAmount = 0;

                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            totalDocShare += parseFloat($(value).find('input[name="DocShare"]').val()) || 0;
                            totalHosShare += parseFloat($(value).find('input[name="HocShare"]').val()) || 0;
                            totalNetAmount += parseFloat($(value).find('input[name="hdnNet_Amount"]').val()) || 0;
                        });

                        var totalCombinedShare = totalDocShare + totalHosShare;

                        if (totalCombinedShare > totalNetAmount) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Total Validation Failed!',
                                text: 'Total Doctor Share (' + totalDocShare.toFixed(2) + ') + Total Hospital Share (' + totalHosShare.toFixed(2) + ') = ' + totalCombinedShare.toFixed(2) + ' exceeds Total Net Amount (' + totalNetAmount.toFixed(2) + ')',
                                confirmButtonText: 'OK',
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            $('#btnSave').prop('disabled', false);
                            document.getElementById("hdnDuplicateCheck").value = "0";
                            return;
                        }
                        debugger;
                        if (isAmountZero == true) {
                            alert("Amount Should not be zero");
                            return true;
                        }
                        var Parameters = { Bill_ID: Bill_ID, Patient_ID: Patient_ID, Opd_id: Opd_id, Bill_Date: Bill_Date, Remarks: Remarks, TotalPayable: TotalPayable, Discount_Percentage: Discount_Percentage, Discount_Amount: Discount_Amount, Net_Amount: Net_Amount, Received_Amount: Received_Amount, Balance_Amount: Balance_Amount, ChargePolicy: ChargePolicy, Details: Details, Share: Share, referred_by_doctor: referred_by_doctor, bomItems: bomItems, Casher: Casher, Previous_Balance: Previous_Balance, Previous_Paid: Previous_Paid, Over_and_Above: Over_and_Above, Cash_In_Hand: Cash_In_Hand, Cash_In_Hand_Account: Cash_In_Hand_Account, Bank_Account: Bank_Account, Bank_Cash: Bank_Cash, Main_Department: Main_Department, PackageType: PackageType, PackageName: PackageName, finalbill: finalbill, BillDepartment: BillDepartment, BillCategory: BillCategory, hdn_docid: hdn_docid, opd_procedure: opd_procedure, bomTotalValue: bomTotalValue, SelectedBranchId: selectedBranchId, Sales_Tax_ID: $('#hdnSalesTaxID').val(), Sales_Tax_Percentage: $('#hdnSalesTaxPercentage').val(), Panel_Id: Panel_Id, Appointment_ID: $('#hdnAppointment_ID').val(), }; //Total_Doctor_Share: Total_Doctor_Share,
                        var rcptAmt = $('#txtAmountReceived').val();
                        if (Patient_ID == '') {
                            alert('Select Patient.');
                        }
                        if (Rpts == true) {
                            PageMethods.CheckReceipts(Bill_ID, function (receipts) {
                                //  if (receipts == '') {
                                // ? Proceed to save — only ONE CheckReceipts call
                                PageMethods.SaveBillRecord(JSON.stringify(Parameters), function (resp) {
                                    // ?? Parse response safely
                                    let result;
                                    try {
                                        result = JSON.parse(resp);
                                    } catch (e1) {
                                        try {
                                            result = JSON.parse(JSON.parse(resp)); // double-serialized fallback
                                        } catch (e2) {
                                            result = { success: true, billId: resp.toString().trim() };
                                        }
                                    }

                                    // ?? Handle error
                                    if (result.success === false) {
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Validation Failed',
                                            text: result.message || 'An error occurred during save.',
                                            confirmButtonText: 'OK',
                                            customClass: {
                                                popup: 'swal-big-popup',
                                                title: 'swal-big-title',
                                                htmlContainer: 'swal-big-text'
                                            }
                                        }).then(() => {
                                            $('#btnSave').prop('disabled', false);
                                            document.getElementById("hdnDuplicateCheck").value = "0";
                                        });
                                        return;
                                    }

                                    // ?? Success path
                                    const billId = (result.billId || result || '').toString().trim();
                                    if (!billId || isNaN(billId)) {
                                        Swal.fire('Error!', 'Invalid Bill ID returned: ' + billId, 'error').then(() => {
                                            $('#btnSave').prop('disabled', false);
                                            document.getElementById("hdnDuplicateCheck").value = "0";
                                        });
                                        return;
                                    }

                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Data Successfully Saved.',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });

                                    const encodedBillId = encodeURIComponent(billId);
                                    window.open('../../ReportViewer.aspx?ReportName=BillingBaseReport&ReportTitle=Billing%20Base%20Report&Bill_ID=' + encodedBillId);

                                    setTimeout(function () {
                                        window.location.href = 'BillingProcess.aspx?Bill_ID=' + encodedBillId;
                                    }, 700);

                                    DeleteExcludedItems();

                                }, function (error) {
                                    // Save failed (network/exception)
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Save Failed',
                                        text: 'Network error: ' + (error.get_message?.() || error),
                                        confirmButtonText: 'OK'
                                    }).then(() => {
                                        $('#btnSave').prop('disabled', false);
                                        document.getElementById("hdnDuplicateCheck").value = "0";
                                    });
                                });

                                //}
                                //else {
                                //    // Receipts exist — block save
                                //    alert('Delete Following Receipts:- ' + receipts);
                                //    $('#btnSave').prop('disabled', false);
                                //    document.getElementById("hdnDuplicateCheck").value = "0";
                                //}
                            }, function (error) {
                                // CheckReceipts failed
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Receipt Check Failed',
                                    text: 'Error: ' + (error.get_message?.() || error),
                                    confirmButtonText: 'OK'
                                }).then(() => {
                                    $('#btnSave').prop('disabled', false);
                                    document.getElementById("hdnDuplicateCheck").value = "0";
                                });
                            });
                        }
                        else {
                            PageMethods.CheckReceipts(Bill_ID, function (receipts) {
                                if (receipts == '') {
                                    // ? Proceed to save — only ONE CheckReceipts call
                                    PageMethods.SaveBillRecord(JSON.stringify(Parameters), function (resp) {
                                        // ?? Parse response safely
                                        let result;
                                        try {
                                            result = JSON.parse(resp);
                                        } catch (e1) {
                                            try {
                                                result = JSON.parse(JSON.parse(resp)); // double-serialized fallback
                                            } catch (e2) {
                                                result = { success: true, billId: resp.toString().trim() };
                                            }
                                        }

                                        // ?? Handle error
                                        if (result.success === false) {
                                            Swal.fire({
                                                icon: 'error',
                                                title: 'Validation Failed',
                                                text: result.message || 'An error occurred during save.',
                                                confirmButtonText: 'OK',
                                                customClass: {
                                                    popup: 'swal-big-popup',
                                                    title: 'swal-big-title',
                                                    htmlContainer: 'swal-big-text'
                                                }
                                            }).then(() => {
                                                $('#btnSave').prop('disabled', false);
                                                document.getElementById("hdnDuplicateCheck").value = "0";
                                            });
                                            return;
                                        }

                                        // ?? Success path
                                        const billId = (result.billId || result || '').toString().trim();
                                        if (!billId || isNaN(billId)) {
                                            Swal.fire('Error!', 'Invalid Bill ID returned: ' + billId, 'error').then(() => {
                                                $('#btnSave').prop('disabled', false);
                                                document.getElementById("hdnDuplicateCheck").value = "0";
                                            });
                                            return;
                                        }

                                        Swal.fire({
                                            icon: 'success',
                                            title: 'Success!',
                                            text: 'Data Successfully Saved.',
                                            showConfirmButton: false,
                                            timer: 2500,
                                            customClass: {
                                                popup: 'swal-big-popup',
                                                title: 'swal-big-title',
                                                htmlContainer: 'swal-big-text'
                                            }
                                        });

                                        const encodedBillId = encodeURIComponent(billId);
                                        window.open('../../ReportViewer.aspx?ReportName=BillingBaseReport&ReportTitle=Billing%20Base%20Report&Bill_ID=' + encodedBillId);

                                        setTimeout(function () {
                                            window.location.href = 'BillingProcess.aspx?Bill_ID=' + encodedBillId;
                                        }, 700);

                                        DeleteExcludedItems();

                                    }, function (error) {
                                        // Save failed (network/exception)
                                        Swal.fire({
                                            icon: 'error',
                                            title: 'Save Failed',
                                            text: 'Network error: ' + (error.get_message?.() || error),
                                            confirmButtonText: 'OK'
                                        }).then(() => {
                                            $('#btnSave').prop('disabled', false);
                                            document.getElementById("hdnDuplicateCheck").value = "0";
                                        });
                                    });

                                }
                                else {
                                    // Receipts exist — block save
                                    alert('Delete Following Receipts:- ' + receipts);
                                    $('#btnSave').prop('disabled', false);
                                    document.getElementById("hdnDuplicateCheck").value = "0";
                                }
                            }, function (error) {
                                // CheckReceipts failed
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Receipt Check Failed',
                                    text: 'Error: ' + (error.get_message?.() || error),
                                    confirmButtonText: 'OK'
                                }).then(() => {
                                    $('#btnSave').prop('disabled', false);
                                    document.getElementById("hdnDuplicateCheck").value = "0";
                                });
                            });
                        }

                    }
                    else {
                        alert("Processing Please Wait");
                        returnVal = false;
                    }
                }
            }


            function DeleteExcludedItems() {
                for (var i = 0; i < ExcludedItem_List.length; i++) {
                    PageMethods.MarkTestAsExcludedFromPayment(ExcludedItem_List[i].ItemID, function () {
                    }, function (error) { alert(error.get_message()); })
                }
            }
            debugger;
            function GetDocAgreementValuess(rows) {
                debugger;
                var doc_1 = $("#ddldoctor1").val();
                $("#hdn_docid").val(doc_1);

                var InPatient_Type = $("#hdn_InPatienttype").val();
                var Patient_Type = $("#hdn_PatienttypeId").val();
                var Aggreement_Type = '02'

                if (InPatient_Type == "There is no row at position 0.") {
                    Aggreement_Type = Patient_Type
                }
                else {
                    Aggreement_Type = Aggreement_Type
                }
                var doc_id = $(rows).closest('tr').find('td select[name="ddlDoctor"]').val();
                var test_id = $(rows).closest('tr').find('td input[name ="hdnItemID"]').val();
                var item_id = $(rows).closest('tr').find('td input[name ="hdnItemID"]').val();
                var item_name = $(rows).closest('tr').find('td input[name ="hdnItemName"]').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetDocAgreementValues",
                    data: JSON.stringify({
                        doc_id: doc_id,
                        test_id: test_id,
                        item_id: item_id,
                        item_name: item_name,
                        Aggreement_Type: Aggreement_Type,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        debugger;
                        var result = JSON.parse(data.d);
                        var hos_share = parseFloat(result["hos_share"]) || 0;
                        var doc_share = parseFloat(result["doc_share"]) || 0;

                        // ?? Find the <tr> from 'rows'
                        var $row = $(rows).closest('tr');

                        // ? Read DisPer from *this row* (not 'value')
                        var disPerStr = $row.find('input[name="DisPer"]').val();
                        var disPerNum = parseFloat(disPerStr) || 0;

                        // ?? Apply discount % to hospital & doctor shares (if > 0)
                        if (disPerNum > 0) {
                            var factor = disPerNum / 100; // e.g. 20 ? 0.2
                            hos_share = hos_share * (1 - factor);
                            doc_share = doc_share * (1 - factor);
                        }

                        // ? Set final (discounted) values back
                        $row.find('input[name="HocShare"]').val(hos_share.toFixed(2));
                        $row.find('input[name="DocShare"]').val(doc_share.toFixed(2));

                        $row.find('input[name="hdnPerUnitDocShare"]').remove();
                        $row.find('input[name="hdnPerUnitHocShare"]').remove();

                        $row.append('<input type="hidden" name="hdnPerUnitDocShare" value="' + doc_share.toFixed(6) + '" />');
                        $row.append('<input type="hidden" name="hdnPerUnitHocShare" value="' + hos_share.toFixed(6) + '" />');

                    }
                })
            }



            function AssignValue(ControlID, value) {
                if (ControlID.value == '')
                    ControlID.value = value;
            }
            debugger;
            function CalculateDateOfBirth() {
                var ageInput = $('#txt_dob').val();
                var unit = $('#PrefixAge').val();

                var amount = parseInt(ageInput, 10);

                if (isNaN(amount) || amount <= 0 || amount > 1500) {
                    $('#txtAge_yearss').val('');
                    return;
                }

                var now = moment();
                var dob;
                if (unit === "Year") {
                    dob = now.clone().subtract(amount, 'years');
                } else if (unit === "Month") {
                    dob = now.clone().subtract(amount, 'months');
                } else if (unit === "Day") {
                    dob = now.clone().subtract(amount, 'days');
                } else {
                    $('#txtAge_yearss').val('');
                    return;
                }

                var finalDate = dob.format("DD/MM/YYYY");

                var $input = $('#txtAge_yearss');
                if (!$input.hasClass('hasDatepicker')) {
                    $input.datepicker({
                        changeMonth: true,
                        changeYear: true,
                        yearRange: "-100:+0",
                        dateFormat: "dd/mm/yy"
                    });
                }

                $input.datepicker('setDate', dob.toDate());
                $input.unmask().mask("99/99/9999");
            }
            function CalculateDiscountPercentage() {

                AssignValue(txtDisPer, 0);
                AssignValue(txtDisAmt, 0);
                AssignValue(txtAmountReceived, 0);
                var Amount = 0;
                var TotalAmount = 0;
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    Amount = $($(value).find('td')[5]).text();
                    TotalAmount += parseFloat(Amount);
                });
                $('#txtTotalPayable').val(TotalAmount.toFixed(1));
                var disAmt = $('#txtDisAmt').val();
                $('#txtDisPer').val((100 / TotalAmount * disAmt).toFixed(2));
                $('#hdntxtDisPer').val((100 / TotalAmount * disAmt).toFixed(6));
                var NetPayable = (TotalAmount - disAmt).toFixed(1);
                $('#txtNetPayable').val(NetPayable.toFixed(1));
                var AmtReceived = $('#txtAmountReceived').val();
                if (NetPayable != '') {
                    if (AmtReceived != '') {
                        $('#txtBalances').val((NetPayable - AmtReceived).toFixed(1));
                    }
                    else
                        $('#txtBalances').val(NetPayable.toFixed(0));
                }
                else {
                    $('#txtBalances').val(NetPayable.toFixed(0));
                }
            }
            var isLabCompeted = false;
            var isUltraSoundCompleted = false;
            var isXrayCompleted = false;
            var isCTScanCompleted = false;
            var isBloodBankCompleted = false;
            var isItemCompleted = false;
            var isPackageCompleted = false;
            var Lab = 0;
            var UltraSound = 0;
            var Xray = 0;
            var CT_Scan = 0;
            var Blood = 0;
            var Item = 0;
            var Package = 0;
            var Procedure = 0;
            var TotalDiscountAmount = 0;
            var TotalDiscountAmount_Ultra = 0;
            var TotalDiscountAmount_Xray = 0;
            var TotalDiscountAmount_CTScan = 0;
            var TotalDiscountAmount_Blood = 0;
            var TotalDiscountAmount_ITem = 0;
            var TotalDiscountAmount_Procedure = 0;
            var TotalDiscountAmount_Package = 0;
            var c_Dis_Amt = 0;

            function CalculateSummarieDiscountPerWise(rowIndex) {
                debugger;
                Special = 0;
                AssignValue(txtDisPer, 0);
                AssignValue(txtDisAmt, 0);
                AssignValue(txtAmountReceived, 0);
                var Amount = 0;
                var DisPer = 0;
                var DisAmt = 0;
                var cOmplete_Total_Dis = 0;
                var NetAmount = 0;
                var TotalAmount = 0;
                var TotalNetAmount = 0;
                var Qty = 0;
                var TotalAmount = parseFloat($("#txtTotalAmount").val()) || 0;
                var PreviousPaid = parseFloat($("#txtprevious_paid").val()) || 0;
                var PreviousAmount = parseFloat($("#txtprevious_Amount").val()) || 0;
                var PreviousBalance = parseFloat($("#txt_balance").val()) || 0;
                var AdvanceAmount = parseFloat($("#txtadvance_amount").val()) || 0;
                var RefundAmount = parseFloat($("#txtRefund_amount").val()) || 0;


                var category = $('#ddlMainTestDepartment').val();
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    debugger;

                    if (rowIndex == parseInt(key)) {


                        Qty = $(value).find('input[name="txtQty"]').val();
                        Amount = $($(value).find('td')[5]).text();
                        DisPer = $(value).find('input[name="DisPer"]').val();
                        // --- Recompute Doctor & Hospital Share based on editable amount ---
                        var $row = $(value);
                        var origPerUnitDoc = parseFloat($row.find('input[name="hdnPerUnitDocShare"]').val()) || 0;
                        var origPerUnitHoc = parseFloat($row.find('input[name="hdnPerUnitHocShare"]').val()) || 0;
                        var actualQty = parseFloat(Qty) || 1;

                        var originalRate = parseFloat($row.find('input[name="txtActualAmount"]').val()) || Amount;
                        if (originalRate > 0 && (origPerUnitDoc > 0 || origPerUnitHoc > 0)) {
                            var scaleFactor = Amount / originalRate;
                            var newDocShare = (origPerUnitDoc * actualQty) * scaleFactor;
                            var newHocShare = (origPerUnitHoc * actualQty) * scaleFactor;

                            var disPerNum = parseFloat(DisPer) || 0;
                            if (disPerNum > 0) {
                                var factor = disPerNum / 100;
                                newDocShare *= (1 - factor);
                                newHocShare *= (1 - factor);
                            }

                            $row.find('input[name="DocShare"]').val(newDocShare.toFixed(2));
                            $row.find('input[name="HocShare"]').val(newHocShare.toFixed(2));
                        }

                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                        DisAmt = (Qty * Amount) * DisPer / 100;
                        if (localStorage.OnlyPercentage == 1) {

                        }
                        else {
                            if (localStorage.Disc_Zero == 1) {
                                DisAmt = parseFloat(Amount);
                            }
                            if (localStorage.IsZero_Amt == 1) {
                                DisAmt = parseFloat(Amount);
                            }
                            if (localStorage.IsZero_Procedure == 1) {
                                DisAmt = parseFloat(Amount);
                            }
                        }
                        debugger;
                        $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));
                        var categ = $(value).find('input[name="hdnCategory_ID"]').val();
                        var MainDepart = $(value).find('input[name="Main_Department"]').val();

                        $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));


                        NetAmount = (Qty * Amount) - DisAmt;
                        $($(value).find('td')[8]).text(NetAmount.toFixed(0));
                        var old = max_Total_Dic_Amt;
                        $(value).find('input[name="hdnNet_Amount"]').val(NetAmount.toFixed(6));
                        var type = $(value).find('input[name="hdnItemType"]').val();
                        var _Procedure = $(value).find('input[name="hdnProcedure"]').val();
                        var _Package = $(value).find('input[name="hdnParentTrans_Type"]').val();

                        //var hospital_share = $(value).find('input[name="HocShare"]').val();
                        //var doctor_share = $(value).find('input[name="DocShare"]').val();

                        //// --- Apply discount % to hospital & doctor shares (localized change) ---
                        //if (DisPer && !isNaN(DisPer)) {
                        //    var disPerNum = parseFloat(DisPer) / 100; // e.g. 20% ? 0.2
                        //    var disAmtHosp = parseFloat(hospital_share || 0) * disPerNum;
                        //    var disAmtDoc  = parseFloat(doctor_share  || 0) * disPerNum;

                        //    // Update *displayed* shares (after discount deduction)
                        //    var newHospShare = parseFloat(hospital_share || 0) - disAmtHosp;
                        //    var newDocShare  = parseFloat(doctor_share  || 0) - disAmtDoc;

                        //    // Set back to inputs (as numbers, rounded to 2 decimals for UI)
                        //    $(value).find('input[name="HocShare"]').val(newHospShare.toFixed(2));
                        //    $(value).find('input[name="DocShare"]').val(newDocShare.toFixed(2));

                        //    // Optional: keep original values elsewhere? Not overwritten unless needed.
                        //}

                        if (localStorage.OnlyPercentage == 1) {



                        }
                        else {

                            Special = 1;

                            if ((type == "Item" || type == "Service") && _Package != "Package") {          //start


                                if (_Procedure == "0" || _Procedure == "" || _Procedure == "null" || _Procedure == null) {
                                    if (localStorage.IsHospitalService == false) {
                                        $(value).find('input[name="DisAmount"]').val();
                                        $(value).find('input[name="hdnDisAmount"]').val();
                                        $(value).find('input[name="hdnDisPer"]').val();
                                        $(value).find('input[name="DisPer"]').val();
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount);
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        return false;
                                    }
                                    else {
                                        debugger;
                                        var item_Id = $(value).find('input[name="hdnItemID"]').val();
                                        if (item_Id == "883" || item_Id == "884" || item_Id == "75" || item_Id == "65" || item_Id == "4464") {
                                        }
                                        else {
                                            Item += DisAmt;
                                            TotalDiscountAmount_ITem += DisAmt;
                                            if (Item > max_Total_Dic_Amt_Item) {
                                                var sub1 = TotalDiscountAmount_ITem - DisAmt;
                                                var sub2 = max_Total_Dic_Amt_Item - sub1;
                                                if (isItemCompleted == true) {
                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                debugger;
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                $(value).find('input[name="hdnDisPer"]').val();
                                                $(value).find('input[name="DisPer"]').val();
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                DisAmt = Net_Amount;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isItemCompleted = true;
                                                TotalDiscountAmount_ITem = max_Total_Dic_Amt_Item;
                                            }
                                            else {

                                                if (localStorage.IsZero_Amt == 1) {
                                                    if (Item > max_Total_Dic_Amt_Item) {
                                                        var sub1 = TotalDiscountAmount_ITem - Amount;
                                                        var sub2 = max_Total_Dic_Amt_Item - sub1;
                                                        if (isItemCompleted == true) {
                                                            $(value).find('input[name="DisAmount"]').val();
                                                            $(value).find('input[name="hdnDisAmount"]').val();
                                                            $(value).find('input[name="hdnDisPer"]').val();
                                                            $(value).find('input[name="DisPer"]').val();
                                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                            return false;
                                                        }
                                                        var amt = parseFloat(DisAmt);
                                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                        var DisPer = 100 / Amount * amt;
                                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                                        var Net_Amount = parseInt(Amount) - amt;
                                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                        isItemCompleted = true;
                                                        TotalDiscountAmount_ITem = max_Total_Dic_Amt_Item;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                else {

                                    Special = 1;

                                    Procedure += DisAmt;
                                    TotalDiscountAmount_Procedure += DisAmt;
                                    if (Procedure > max_Total_Dic_Amt_Procedure) {
                                        debugger;
                                        var sub1 = TotalDiscountAmount_Procedure - DisAmt;
                                        var sub2 = max_Total_Dic_Amt_Procedure - sub1;
                                        if (isItemCompeted_Procedure == true) {

                                            debugger;

                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;

                                        }
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isItemCompeted_Procedure = true;
                                        TotalDiscountAmount_Procedure = TotalDiscountAmount_Procedure;
                                    }
                                    else {

                                        if (localStorage.IsZero_Procedure == 1) {
                                            debugger;
                                            if (Procedure > TotalDiscountAmount_Procedure) {
                                                debugger;
                                                var sub1 = TotalDiscountAmount_Procedure - Amount;
                                                var sub2 = max_Total_Dic_Amt_Procedure - sub1;
                                                if (isItemCompeted_Procedure == true) {
                                                    debugger;

                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;

                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isItemCompeted_Procedure = true;
                                                TotalDiscountAmount_Procedure = max_Total_Dic_Amt_Procedure;
                                            }
                                        }
                                    }
                                }
                            }  //end
                            else if (_Package == "Package") {
                                debugger;
                                Package += DisAmt;
                                TotalDiscountAmount_Package += DisAmt;
                                if (Package > max_Package_Amt) {
                                    debugger;
                                    var sub1 = TotalDiscountAmount_Package - DisAmt;
                                    var sub2 = max_Package_Amt - sub1;
                                    if (isPackageCompleted == true) {
                                        $(value).find('input[name="DisAmount"]').val();
                                        $(value).find('input[name="hdnDisAmount"]').val();
                                        $(value).find('input[name="hdnDisPer"]').val();
                                        $(value).find('input[name="DisPer"]').val();
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - DisAmt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        return false;
                                    } debugger;
                                    var amt = parseFloat(DisAmt);
                                    $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                    $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                    var DisPer = 100 / Amount * amt;
                                    $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                    $(value).find('input[name="DisPer"]').val(DisPer);
                                    if (localStorage.Disc_Zero == 1) {
                                        $(value).find('input[name="hdnDisPer"]').val();
                                        $(value).find('input[name="DisPer"]').val();

                                    }
                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                    var Net_Amount = parseInt(Amount) - amt;
                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                    isPackageCompleted = true;
                                    TotalDiscountAmount_Package = max_Package_Amt;
                                }
                                else {
                                    debugger;
                                    if (localStorage.Disc_Zero == 1) {
                                        debugger;
                                        if (Package > max_Package_Amt) {
                                            debugger;
                                            var sub1 = TotalDiscountAmount_Package - Amount;
                                            var sub2 = max_Package_Amt - sub1;
                                            if (isPackageCompleted == true) {
                                                debugger;
                                                $(value).find('input[name="DisAmount"]').val();
                                                $(value).find('input[name="hdnDisAmount"]').val();
                                                $(value).find('input[name="hdnDisPer"]').val();
                                                $(value).find('input[name="DisPer"]').val();
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - DisAmt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                return false;
                                            }
                                            debugger;
                                            var amt = parseFloat(DisAmt);
                                            $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                            $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                            var DisPer = 100 / Amount * amt;
                                            $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                            $(value).find('input[name="DisPer"]').val(DisPer);
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - amt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            isPackageCompleted = true;
                                            TotalDiscountAmount_Package = max_Package_Amt;
                                        }
                                    }
                                }
                            }
                            else {  //start

                                Special = 1;
                                if (categ == "001" || categ == "Lab Test" || MainDepart == "001") {
                                    debugger;
                                    Lab += DisAmt;
                                    TotalDiscountAmount += DisAmt;
                                    if (Lab > max_Total_Dic_Amt) {
                                        debugger;
                                        var sub1 = TotalDiscountAmount - DisAmt;
                                        var sub2 = max_Total_Dic_Amt - sub1;
                                        if (isLabCompeted == true) {
                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;
                                        }
                                        debugger;
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        if (localStorage.Disc_Zero == 1) {
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();

                                        }
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isLabCompeted = true;
                                        TotalDiscountAmount = max_Total_Dic_Amt;
                                    }
                                    else {
                                        debugger;
                                        if (localStorage.Disc_Zero == 1) {
                                            if (Lab > max_Total_Dic_Amt) {

                                                var sub1 = TotalDiscountAmount - Amount;
                                                var sub2 = max_Total_Dic_Amt - sub1;
                                                if (isLabCompeted == true) {

                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isLabCompeted = true;
                                                TotalDiscountAmount = max_Total_Dic_Amt;
                                            }
                                        }
                                    }

                                }
                                else if (categ == "002" || categ == "Ultrasound") {
                                    UltraSound += DisAmt;
                                    TotalDiscountAmount_Ultra += DisAmt;

                                    if (UltraSound > max_Total_Dic_Amt_Ultra) {

                                        var sub1 = TotalDiscountAmount_Ultra - DisAmt;
                                        var sub2 = max_Total_Dic_Amt_Ultra - sub1;
                                        if (isUltraSoundCompleted == true) {
                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;
                                        }
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isUltraSoundCompleted = true;
                                        TotalDiscountAmount_Ultra = max_Total_Dic_Amt_Ultra;
                                    }
                                    else {
                                        if (localStorage.Disc_Zero == 1) {

                                            if (UltraSound > max_Total_Dic_Amt_Ultra) {
                                                var sub1 = TotalDiscountAmount_Ultra - Amount;
                                                var sub2 = max_Total_Dic_Amt_Ultra - sub1;
                                                if (isUltraSoundCompleted == true) {
                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isUltraSoundCompleted = true;
                                                TotalDiscountAmount_Ultra = max_Total_Dic_Amt_Ultra;
                                            }
                                        }
                                    }
                                }
                                else if (categ == "003" || categ == "X-Ray") {

                                    Xray += DisAmt;
                                    TotalDiscountAmount_Xray += DisAmt;

                                    if (Xray > max_Total_Dic_Amt_Xray) {

                                        var sub1 = TotalDiscountAmount_Xray - DisAmt;
                                        var sub2 = max_Total_Dic_Amt_Xray - sub1;
                                        if (isXrayCompleted == true) {
                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;
                                        }
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isXrayCompleted = true;
                                        TotalDiscountAmount_Xray = max_Total_Dic_Amt_Xray;
                                    }
                                    else {
                                        if (localStorage.Disc_Zero == 1) {
                                            if (Xray > max_Total_Dic_Amt_Xray) {
                                                var sub1 = TotalDiscountAmount_Xray - Amount;
                                                var sub2 = max_Total_Dic_Amt_Xray - sub1;
                                                if (isXrayCompleted == true) {
                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isXrayCompleted = true;
                                                TotalDiscountAmount_Xray = max_Total_Dic_Amt_Xray;
                                            }
                                        }

                                    }
                                }
                                else if (categ == "004" || categ == "CT-Scan") {

                                    CT_Scan += DisAmt;
                                    TotalDiscountAmount_CTScan += DisAmt;

                                    if (CT_Scan > max_Total_Dic_Amt_ct_Scan) {

                                        var sub1 = TotalDiscountAmount_CTScan - DisAmt;
                                        var sub2 = max_Total_Dic_Amt_ct_Scan - sub1;
                                        if (isCTScanCompleted == true) {
                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;
                                        }
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isCTScanCompleted = true;
                                        TotalDiscountAmount_CTScan = max_Total_Dic_Amt_ct_Scan;
                                    }
                                    else {
                                        if (localStorage.Disc_Zero == 1) {

                                            if (CT_Scan > max_Total_Dic_Amt_ct_Scan) {
                                                var sub1 = TotalDiscountAmount_CTScan - Amount;
                                                var sub2 = max_Total_Dic_Amt_ct_Scan - sub1;
                                                if (isXrayCompleted == true) {
                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isCTScanCompleted = true;
                                                TotalDiscountAmount_CTScan = max_Total_Dic_Amt_ct_Scan;
                                            }
                                        }
                                    }
                                }
                                else if (categ == "005" || categ == "Blood Bank" || categ == "053" || categ == "054" || categ == "055" || MainDepart == "005") {

                                    Blood += DisAmt;
                                    TotalDiscountAmount_Blood += DisAmt;
                                    if (Blood > max_Total_Dic_Amt_Blood) {

                                        var sub1 = TotalDiscountAmount_Blood - DisAmt;
                                        var sub2 = max_Total_Dic_Amt_Blood - sub1;
                                        if (isBloodBankCompleted == true) {
                                            $(value).find('input[name="DisAmount"]').val();
                                            $(value).find('input[name="hdnDisAmount"]').val();
                                            $(value).find('input[name="hdnDisPer"]').val();
                                            $(value).find('input[name="DisPer"]').val();
                                            var Amount = $(value).find('td:eq(5)').text().trim();
                                            var Net_Amount = parseInt(Amount) - DisAmt;
                                            $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                            return false;
                                        }
                                        var amt = parseFloat(DisAmt);
                                        $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                        $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                        var DisPer = 100 / Amount * amt;
                                        $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                        $(value).find('input[name="DisPer"]').val(DisPer);
                                        var Amount = $(value).find('td:eq(5)').text().trim();
                                        var Net_Amount = parseInt(Amount) - amt;
                                        $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                        isBloodBankCompleted = true;
                                        TotalDiscountAmount_Blood = max_Total_Dic_Amt_Blood;
                                    }
                                    else {
                                        if (localStorage.Disc_Zero == 1) {
                                            if (Blood > max_Total_Dic_Amt_Blood) {
                                                var sub1 = TotalDiscountAmount_Blood - Amount;
                                                var sub2 = max_Total_Dic_Amt_Blood - sub1;
                                                if (isBloodBankCompleted == true) {
                                                    $(value).find('input[name="DisAmount"]').val();
                                                    $(value).find('input[name="hdnDisAmount"]').val();
                                                    $(value).find('input[name="hdnDisPer"]').val();
                                                    $(value).find('input[name="DisPer"]').val();
                                                    var Amount = $(value).find('td:eq(5)').text().trim();
                                                    var Net_Amount = parseInt(Amount) - DisAmt;
                                                    $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                    return false;
                                                }
                                                var amt = parseFloat(DisAmt);
                                                $(value).find('input[name="DisAmount"]').val(amt.toFixed(2));
                                                $(value).find('input[name="hdnDisAmount"]').val(amt.toFixed(2));
                                                var DisPer = 100 / Amount * amt;
                                                $(value).find('input[name="hdnDisPer"]').val(DisPer);
                                                $(value).find('input[name="DisPer"]').val(DisPer);
                                                var Amount = $(value).find('td:eq(5)').text().trim();
                                                var Net_Amount = parseInt(Amount) - amt;
                                                $(value).find('td:eq(8)').text(Net_Amount.toFixed(0));
                                                isBloodBankCompleted = true;
                                                TotalDiscountAmount_Blood = max_Total_Dic_Amt_Blood;
                                            }
                                        }

                                    }
                                }
                            }
                        }
                        //end

                    }
                    debugger;
                    c_Dis_Amt += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                    var di = Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                    Amount = $($(value).find('td')[5]).text();
                    Qty = $(value).find('input[name="txtQty"]').val();
                    //Qty = Math.round(parseFloat($(value).find('input[name="txtQty"]').val()));
                    TotalAmount += parseFloat(Amount) * (Qty);


                    NetAmount = Amount - DisAmt;


                    TotalNetAmount += NetAmount;


                });
                debugger;
                var total_Disc = 0;
                var Net_Amt = 0;
                var total_amt = 0;
                var qty = 0;
                Temporary = Item;
                if (Special == 1) {


                    $.each($('#tblDetails tbody tr'), function (key, value) {


                        total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                        //var qty = Math.round(parseFloat($(value).find('input[name="txtQty"]').val()));
                        var qty = $(value).find('input[name="txtQty"]').val();

                        Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                        total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                    });
                   
                    var PreviousPaid = parseFloat($("#txtprevious_paid").val()) || 0;
                    var PreviousAmount = parseFloat($("#txtprevious_Amount").val()) || 0;
                    var PreviousBalance = parseFloat($("#txt_balance").val()) || 0;
                    var AdvanceAmount = parseFloat($("#txtadvance_amount").val()) || 0;
                    var RefundAmount = parseFloat($("#txtRefund_amount").val()) || 0;
                    var TotalAmount = Net_Amt - PreviousPaid - total_Disc;
                    debugger;
                    $('#txtTotalAmount').val(Net_Amt);
                    $('#txtTotalPayable').val(TotalAmount);
                    $('#txtDisAmt').val(total_Disc);
                    var net = Net_Amt - total_Disc;
                    $('#txtNetPayable').val(TotalAmount);
                    var AmtReceived = $('#txtAmountReceived').val();
                    var amt = parseFloat(AmtReceived) || 0;
                    if ($('#txtTotalPayable').val() != '') {
                        if (AmtReceived != '') {
                            $('#txtBalances').val(((net + PreviousAmount) - (amt + AdvanceAmount + PreviousPaid)).toFixed());
                            //   $('#txt_balance').val(((net + PreviousAmount) - (amt + AdvanceAmount + PreviousPaid)).toFixed());

                        }
                        else
                            $('#txtBalances').val(net.toFixed());
                    }
                    else {
                        $('#txtBalances').val(net.toFixed());
                    }
                }
                else {
                    if (isNaN(validate)) {
                        $.each($('#tblDetails tbody tr'), function (key, value) {


                            total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                            var qty = Math.round(parseFloat($(value).find('input[name="txtQty"]').val()));

                            Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                            total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                        });
                    }
                    debugger;
                    $('#txtTotalPayable').val(TotalAmount.toFixed());

                    $('#txtDisAmt').val(parseFloat(total_Disc).toFixed(2));
                    $('#txtNetPayable').val(TotalAmount.toFixed());
                    var AmtReceived = $('#txtAmountReceived').val();
                    if ($('#txtTotalPayable').val() != '') {
                        debugger;
                        if (AmtReceived != '') {
                            // $('#txtBalances').val((TotalNetAmount - AmtReceived).toFixed());
                            $('#txtBalances').val(((TotalNetAmount + PreviousAmount) - (AmtReceived + AdvanceAmount + PreviousPaid)).toFixed());
                        }
                        else
                            $('#txtBalances').val(TotalNetAmount.toFixed());
                    }
                    else {
                        $('#txtBalances').val(TotalNetAmount.toFixed());
                    }
                }

            }
            var Temporary = 0;
            debugger;
            function calculateDoctorShare() {
                debugger;
                var list = document.getElementById('tblDetails');
                var doctorsList = document.getElementById('Doctor_Share_Table');
                var totalDoctorDistribution = 0;
                var totalDoctorShare = 0;
                for (var i = 0; i < list.rows.length - 1; i++) {
                    totalDoctorShare += parseInt($('#DocShare' + i + '').val());
                }
                for (var i = 0; i < doctorsList.rows.length - 1; i++) {
                    totalDoctorDistribution += parseInt($('#DoctorAmount' + i + '').val());;
                }
                $('#txtTotalDoctorShare').val(totalDoctorShare);
                $('#txtDoctorTotalDistribution').val(totalDoctorDistribution);
            }
            function CalculateSummarieDiscountAmountWise(rowIndex) {
                debugger;
                AssignValue(txtDisPer, 0);
                AssignValue(txtDisAmt, 0);
                AssignValue(txtAmountReceived, 0);
                var Amount = 0;
                var TotalAmount = 0;
                var DisPer = 0;
                var DisAmt = 0;
                var NetAmount = 0;
                var Qty = 0;
                var TotalDiscountAmount = 0;
                var TotalNetAmount = 0;
                $.each($('#tblDetails tbody tr'), function (key, value) {
                    debugger;
                    debugger;
                    Amount = $($(value).find('td')[5]).text();
                    Qty = $(value).find('input[name="txtQty"]').val();
                    DisAmt = $(value).find('input[name="DisAmount"]').val();
                    $(value).find('input[name="hdnDisAmount"]').val(DisAmt);
                    DisPer = 100 / (Qty * Amount) * DisAmt;
                    $(value).find('input[name="DisPer"]').val(DisPer.toFixed(2));
                    $(value).find('input[name="hdnDisPer"]').val(DisPer.toFixed(6));
                    NetAmount = (Qty * Amount) - DisAmt;
                    $($(value).find('td')[8]).text(NetAmount.toFixed());
                    $(value).find('input[name="hdnNet_Amount"]').val(NetAmount.toFixed(6));
                    //}
                    Amount = $($(value).find('td')[5]).text();
                    TotalAmount += parseFloat(Qty) * parseFloat(Amount);
                    TotalDiscountAmount += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                    TotalNetAmount += parseFloat($($(value).find('td')[8]).text());
                });
                debugger;
                $('#txtTotalPayable').val(TotalAmount.toFixed());
                $('#txtDisAmt').val(TotalDiscountAmount.toFixed());
                $('#txtNetPayable').val(TotalNetAmount.toFixed());
                var AmtReceived = $('#txtAmountReceived').val();
                if ($('#txtTotalPayable').val() != '') {
                    if (AmtReceived != '') {
                        $('#txtBalances').val((TotalNetAmount - AmtReceived).toFixed());
                    }
                    else
                        $('#txtBalances').val(TotalNetAmount.toFixed());
                }
                else {
                    $('#txtBalances').val(TotalNetAmount.toFixed());
                }
            }
            //function CalculateSummariesMaster(AmtWise) {
            //    debugger;
            //    AssignValue(txtDisPer, 0);
            //    AssignValue(txtDisAmt, 0);
            //    AssignValue(txtAmountReceived, 0);
            //    var PerDisable = $('#txtDisPer').val();
            //    var amoutDisable = $('#txtDisAmt').val();
            //    var doctorShare = 0;
            //    var Amount = 0;
            //    var DisPer = 0;
            //    var DisAmt = 0;
            //    var NetAmount = 0;
            //    var TotalAmount = 0;
            //    var TotalDiscountAmount = 0;
            //    var TotalNetAmount = 0;
            //    var TotalDiscountAmount_Entered = 0;
            //    var Qty = 0;
            //    if (AmtWise) {
            //        $.each($('#tblDetails tbody tr'), function (key, value) {
            //            if (amoutDisable != "0") {
            //                $('#txtDisPer').attr("disabled", true);
            //            }
            //            else {
            //                $('#txtDisPer').attr("disabled", false);
            //            }
            //            Qty = $(value).find('input[name="txtQty"]').val();
            //            TotalDiscountAmount_Entered = $('#txtDisAmt').val();
            //            DisPer = 100 / parseFloat($('#txtTotalPayable').val()) * TotalDiscountAmount_Entered;
            //            DisPer = parseFloat(DisPer.toFixed(6));
            //            $(value).find('input[name="DisPer"]').val(DisPer.toFixed(2));
            //            $(value).find('input[name="hdnDisPer"]').val(DisPer.toFixed(6));
            //            Amount = $($(value).find('td')[5]).text();
            //            DisAmt = DisPer * (Amount * Qty) / 100;
            //            $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));
            //            $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));
            //            NetAmount = (Qty * Amount) - DisAmt;
            //            $($(value).find('td')[8]).text(NetAmount.toFixed(0));
            //            $(value).find('input[name="hdnNet_Amount"]').val(NetAmount.toFixed(6));
            //            TotalAmount += parseFloat(Amount);
            //            TotalDiscountAmount += parseFloat(DisAmt);
            //            TotalNetAmount += parseFloat(NetAmount);
            //        });
            //        $('#txtDisPer').val(DisPer.toFixed(2));
            //        $('#hdntxtDisPer').val(DisPer.toFixed(6));
            //    }
            //    else {
            //        debugger;
            //        $.each($('#tblDetails tbody tr'), function (key, value) {
            //            debugger;
            //            if (PerDisable != "0") {
            //                $('#txtDisAmt').attr("disabled", true);
            //            }
            //            else {
            //                $('#txtDisAmt').attr("disabled", false);
            //            }
            //            var TotalDisPer_Entered = $('#txtDisPer').val();
            //            Amount = $($(value).find('td')[5]).text();
            //            Qty = $(value).find('input[name="txtQty"]').val();
            //            DisAmt = TotalDisPer_Entered * (Amount * Qty) / 100;
            //            $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));
            //            $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));
            //            $(value).find('input[name="DisPer"]').val(parseFloat(TotalDisPer_Entered).toFixed(2));
            //            $(value).find('input[name="hdnDisPer"]').val(parseFloat(TotalDisPer_Entered).toFixed(6));
            //            NetAmount = (Qty * Amount) - DisAmt;
            //            $($(value).find('td')[8]).text(NetAmount.toFixed(0));
            //            $(value).find('input[name="hdnNet_Amount"]').val(parseFloat(NetAmount.toFixed(6)));
            //            TotalAmount += parseFloat(Amount);
            //            TotalDiscountAmount += parseFloat(DisAmt);
            //            TotalNetAmount += parseFloat(NetAmount);
            //            $('#hdntxtDisPer').val(TotalDisPer_Entered);
            //        });
            //    }
            //    $('#txtTotalPayable').val(TotalAmount.toFixed(0));
            //    $('#txtDisAmt').val(TotalDiscountAmount.toFixed());
            //    $('#hdnBaseNetPayable').val(TotalNetAmount.toFixed(0));
            //    $('#txtNetPayable').val(TotalNetAmount.toFixed(0));
            //    var AmtReceived = $('#txtAmountReceived').val();

            //    if ($('#txtTotalPayable').val() != '') {
            //        if (AmtReceived != '') {
            //            $('#txtBalances').val((TotalNetAmount - AmtReceived).toFixed(0));
            //        }
            //        else
            //            $('#txtBalances').val(TotalNetAmount.toFixed(0));
            //    }
            //    else {
            //        $('#txtBalances').val(TotalNetAmount.toFixed(0));
            //    }

            //    CalculateSalesTax();

            //}


            function CalculateSummariesMaster(AmtWise) {
                debugger;
                AssignValue(txtDisPer, 0);
                AssignValue(txtDisAmt, 0);
                AssignValue(txtAmountReceived, 0);
                var PerDisable = $('#txtDisPer').val();
                var amoutDisable = $('#txtDisAmt').val();
                var doctorShare = 0;
                var Amount = 0;
                var DisPer = 0;
                var DisAmt = 0;
                var NetAmount = 0;
                var TotalAmount = 0;
                var TotalDiscountAmount = 0;
                var TotalNetAmount = 0;
                var TotalDiscountAmount_Entered = 0;
                var Qty = 0;
                if (AmtWise) {
                    $.each($('#tblDetails tbody tr'), function (key, value) {
                        if (amoutDisable != "0") {
                            $('#txtDisPer').attr("disabled", true);
                        }
                        else {
                            $('#txtDisPer').attr("disabled", false);
                        }
                        Qty = $(value).find('input[name="txtQty"]').val();
                        TotalDiscountAmount_Entered = $('#txtDisAmt').val();
                        DisPer = 100 / parseFloat($('#txtTotalPayable').val()) * TotalDiscountAmount_Entered;
                        DisPer = parseFloat(DisPer.toFixed(6));
                        $(value).find('input[name="DisPer"]').val(DisPer.toFixed(2));
                        $(value).find('input[name="hdnDisPer"]').val(DisPer.toFixed(6));
                        Amount = $($(value).find('td')[5]).text();
                        DisAmt = DisPer * (Amount * Qty) / 100;
                        $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));
                        $(value).find('input[name="hdnDisAmount"]').val(DisAmt.toFixed(6));
                        NetAmount = (Qty * Amount) - DisAmt;
                        $($(value).find('td')[8]).text(NetAmount.toFixed(0));
                        $(value).find('input[name="hdnNet_Amount"]').val(NetAmount.toFixed(6));
                        TotalAmount += parseFloat(Amount);
                        TotalDiscountAmount += parseFloat(DisAmt);
                        TotalNetAmount += parseFloat(NetAmount);
                    });
                    $('#txtDisPer').val(DisPer.toFixed(2));
                    $('#hdntxtDisPer').val(DisPer.toFixed(6));
                }
                else {
                    debugger;
                    let Total = parseFloat($('#txtTotalPayable').val()) || 0;

                    TotalAmount = Total;
                    TotalDiscountAmount = (TotalAmount * PerDisable) / 100;
                    TotalNetAmount = TotalAmount - TotalDiscountAmount
                }
                $('#txtTotalPayable').val(TotalAmount.toFixed(0));
                $('#txtDisAmt').val(TotalDiscountAmount.toFixed(0));
                $('#hdnBaseNetPayable').val(TotalNetAmount.toFixed(0));
                $('#txtNetPayable').val(TotalNetAmount.toFixed(0));
                var AmtReceived = $('#txtAmountReceived').val();

                if ($('#txtTotalPayable').val() != '') {
                    if (AmtReceived != '') {
                        $('#txtBalances').val((TotalNetAmount - AmtReceived).toFixed(0));
                    }
                    else
                        $('#txtBalances').val(TotalNetAmount.toFixed(0));
                }
                else {
                    $('#txtBalances').val(TotalNetAmount.toFixed(0));
                }

                CalculateSalesTax();

            }

            var isQty = 0;
            var Tmp_ITem = 0;
            var s = 0;
            function CulculateAmonutWithQty(anchor, isHos, isPro) {
                if (IsDiscountAvaible == "False" || IsDiscountAvaible == "false") {
                    debugger;
                    var disTotal = $('#txtDisPer').val();
                    if (disTotal != "") {
                        debugger;
                        var Amount = $(anchor).closest('tr').find('td:eq(5)').text();
                        var qty = $($(anchor).closest('tr').find('td input[name=txtQty]')[0]).val();
                        var old_Dis_amt = parseInt(Amount) * parseInt() / 100;

                        var DisAmt = (parseInt(Amount) * qty) * parseInt(disTotal) / 100;

                        var net_amt = (parseInt(Amount) * qty) - parseFloat(DisAmt);

                        $($(anchor).closest('tr').find('td:eq(8)').text(net_amt.toFixed(0)));
                        $($(anchor).closest('tr').find('td input[name=DisAmount]')[0]).val(DisAmt);
                        $($(anchor).closest('tr').find('td input[name=hdnDisAmount]')[0]).val(DisAmt);
                        var total_Disc = 0;
                        var Net_Amt = 0;
                        var total_amt = 0;
                        var qty = 0;
                        //After 
                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            debugger;

                            total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                            var qty = Math.round(parseFloat($(value).find('input[name="txtQty"]').val()));

                            Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                            total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                        });
                        debugger;

                        $('#txtTotalAmount').val(Net_Amt);
                        var previouspaid = $('#txtprevious_paid').val();
                        var totalpayable = Net_Amt - previouspaid;
                        $('#txtTotalPayable').val(totalpayable);;
                        $('#txtDisAmt').val(total_Disc);
                        var net = Net_Amt - total_Disc;

                        $('#txtNetPayable').val(total_amt);
                        var AmtReceived = $('#txtAmountReceived').val();
                        if ($('#txtTotalPayable').val() != '') {
                            if (AmtReceived != '') {
                                $('#txtBalances').val((net - AmtReceived).toFixed());
                            }
                            else
                                $('#txtBalances').val(net.toFixed());
                        }
                        else {

                            $('#txtBalances').val(net.toFixed());

                        }


                    }

                    return false;
                }
                isQty = 1;
                var row = $(anchor).parents('tr')[0];

                var row_length = $(row).index();
                var Qty = $($(row).find('td input[name=txtQty]')[0]).val();
                var Package = $($(row).find('td input[name=hdnParentTrans_Type]')[0]).val();
                var Temp = Temporary;
                if (Package == "Package") {
                    debugger;
                    var Amount = $(row).find('td:eq(5)').text();


                    var qty = $($(row).find('td input[name=txtQty]')[0]).val();
                    var old_Dis_amt = parseInt(Amount) * parseInt(localStorage.Disc) / 100;

                    var DisAmt = (parseInt(Amount) * qty) * parseInt(localStorage.Disc) / 100;

                    var net_amt = (parseInt(Amount) * qty) - parseFloat(DisAmt);

                    $($(row).find('td:eq(8)').text(net_amt.toFixed(0)));
                    $($(row).find('td input[name=DisAmount]')[0]).val(DisAmt);
                    $($(row).find('td input[name=hdnDisAmount]')[0]).val(DisAmt);
                    Package = 0;
                    TotalDiscountAmount_Package = 0;
                    $.each($('#tblDetails tbody tr'), function (key, value) {
                        debugger;
                        var dis_amt = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));
                        var isItem = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));

                        var isProcedure = $(value).find('input[name="hdnProcedure"]').val();
                        var ItemType = $(value).find('input[name="hdnItemType"]').val();
                        var amt_dis = $(value).find('input[name="DisAmount"]').val();
                        Package += parseFloat(amt_dis);
                        TotalDiscountAmount_Package += parseFloat(amt_dis);


                    });



                    if (Package > max_Package_Amt) {
                        debugger;

                        var sub1 = TotalDiscountAmount_Package - DisAmt;
                        var sub2 = max_Package_Amt - sub1;
                        var amt = Math.abs(sub2);
                        var Total_Dis_Amt = Math.round(parseInt(amt));

                        $(row).find('input[name="DisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                        $(row).find('input[name="hdnDisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                        var DisPer = 100 / Amount * amt;
                        $(row).find('input[name="hdnDisPer"]').val(DisPer);
                        $(row).find('input[name="DisPer"]').val(DisPer);
                        var Amount = $(row).find('td:eq(5)').text().trim();
                        var Net_Amount = (parseInt(Amount) * parseInt(qty)) - amt;
                        $(row).find('td:eq(8)').text(Net_Amount.toFixed(0));
                        isPackageCompleted = true;
                        TotalDiscountAmount_Package = max_Package_Amt;
                    }
                    else {
                        isPackageCompleted = false;
                        TotalDiscountAmount_Package = Procedure;

                    }

                    var total_Disc = 0;
                    var Net_Amt = 0;
                    var total_amt = 0;
                    var qty = 0;
                    //After 
                    $.each($('#tblDetails tbody tr'), function (key, value) {
                        debugger;

                        total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                        var qty =($(value).find('input[name="txtQty"]').val());

                        Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                        total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                    });

                    $('#txtTotalAmount').val(Net_Amt);
                    var previouspaid = $('#txtprevious_paid').val();
                    var totalpayable = Net_Amt - previouspaid;
                    $('#txtTotalPayable').val(totalpayable);
                    $('#txtDisAmt').val(total_Disc);
                    var net = Net_Amt - total_Disc;
                    $('#txtNetPayable').val(total_amt);
                    var AmtReceived = $('#txtAmountReceived').val();
                    if ($('#txtTotalPayable').val() != '') {
                        if (AmtReceived != '') {
                            $('#txtBalances').val((net - AmtReceived).toFixed());
                        }
                        else
                            $('#txtBalances').val(net.toFixed());
                    }
                    else {
                        $('#txtBalances').val(net.toFixed());
                    }
                }
                else {
                    if (isHos == 1) {
                        debugger;
                        var Amount = $(row).find('td:eq(5)').text();


                        var qty = $($(row).find('td input[name=txtQty]')[0]).val();
                        var old_Dis_amt = parseInt(Amount) * parseInt(localStorage.Disc) / 100;
                        var DisAmt = (parseInt(Amount) * qty) * parseInt(localStorage.Disc) / 100;
                        if (localStorage.Disc == "0.0000") {
                            debugger;
                            Qty = $(row).find('input[name="txtQty"]').val();
                            DisAmt = $(row).find('input[name="DisAmount"]').val();
                            $(row).find('input[name="hdnDisAmount"]').val(DisAmt);
                            DisPer = 100 / (Qty * Amount) * DisAmt;
                            $(row).find('input[name="DisPer"]').val(DisPer.toFixed(2));
                            $(row).find('input[name="hdnDisPer"]').val(DisPer.toFixed(6));
                        }


                        if (localStorage.Disc == "0.0000") {
                        }
                        var net_amt = (parseInt(Amount) * qty) - parseFloat(DisAmt);

                        $($(row).find('td:eq(8)').text(net_amt.toFixed(0)));
                        $($(row).find('td input[name=DisAmount]')[0]).val(DisAmt);
                        $($(row).find('td input[name=hdnDisAmount]')[0]).val(DisAmt);
                        Item = 0;
                        TotalDiscountAmount_ITem = 0;
                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            debugger;
                            var dis_amt = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));
                            var isItem = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));

                            var isProcedure = $(value).find('input[name="hdnProcedure"]').val();
                            var ItemType = $(value).find('input[name="hdnItemType"]').val();
                            var Package = $(value).find('input[name="hdnParentTrans_Type"]').val();
                            if (Package == "Package") {

                            }
                            else {
                                if (isProcedure == "" || isProcedure == "null" || isProcedure == "0" || typeof isProcedure === 'undefined') {
                                    if (ItemType == "Item" || ItemType == "Service") {
                                        debugger;
                                        var amt_dis = $(value).find('input[name="DisAmount"]').val();
                                        Item += parseFloat(amt_dis);
                                        TotalDiscountAmount_ITem += parseFloat(amt_dis);
                                    }
                                }
                                else {


                                }
                            }

                        });



                        if (Item > max_Total_Dic_Amt_Item) {
                            debugger;

                            var sub1 = TotalDiscountAmount_ITem - DisAmt;
                            var sub2 = max_Total_Dic_Amt_Item - sub1;
                            var amt = Math.abs(sub2);
                            var Total_Dis_Amt = Math.round(parseInt(amt));

                            $(row).find('input[name="DisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                            $(row).find('input[name="hdnDisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                            var DisPer = 100 / Amount * amt;
                            $(row).find('input[name="hdnDisPer"]').val(DisPer);
                            $(row).find('input[name="DisPer"]').val(DisPer);
                            var Amount = $(row).find('td:eq(5)').text().trim();
                            var Net_Amount = (parseInt(Amount) * parseInt(qty)) - amt;
                            $(row).find('td:eq(8)').text(Net_Amount.toFixed(0));
                            isItemCompleted = true;
                            TotalDiscountAmount_ITem = max_Total_Dic_Amt_Item;
                        }
                        else {
                            isItemCompleted = false;
                            TotalDiscountAmount_ITem = Item;
                            if (localStorage.Disc == "0.0000") {
                            }

                        }

                        var total_Disc = 0;
                        var Net_Amt = 0;
                        var total_amt = 0;
                        var qty = 0;
                        //After 
                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            debugger;

                            total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                            var qty = ($(value).find('input[name="txtQty"]').val());

                            Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                            total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                        });
                        debugger;

                        $('#txtTotalAmount').val(Net_Amt);
                        var previouspaid = $('#txtprevious_paid').val();
                        var totalpayable = Net_Amt - previouspaid;
                        $('#txtTotalPayable').val(totalpayable);
                        $('#txtDisAmt').val(total_Disc);
                        var net = Net_Amt - total_Disc;
                        $('#txtNetPayable').val(total_amt);
                        var AmtReceived = $('#txtAmountReceived').val();
                        if ($('#txtTotalPayable').val() != '') {
                            if (AmtReceived != '') {
                                $('#txtBalances').val((net - AmtReceived).toFixed());
                            }
                            else
                                $('#txtBalances').val(net.toFixed());
                        }
                        else {
                            $('#txtBalances').val(net.toFixed());
                        }
                        //  }

                    }
                    if (isPro == 1) {

                        var Amount = $(row).find('td:eq(5)').text();

                        DisPer = $(row).find('input[name="DisPer"]').val();

                        var qty = $($(row).find('td input[name=txtQty]')[0]).val();
                        var old_Dis_amt = parseInt(Amount) * parseInt(localStorage.Disc_Pro) / 100;

                        var DisAmt = (parseInt(Amount) * qty) * parseInt(localStorage.Disc_Pro) / 100;

                        var net_amt = (parseInt(Amount) * qty) - parseFloat(DisAmt);

                        $($(row).find('td:eq(8)').text(net_amt.toFixed(0)));
                        $($(row).find('td input[name=DisAmount]')[0]).val(DisAmt);
                        $($(row).find('td input[name=hdnDisAmount]')[0]).val(DisAmt);
                        Procedure = 0;
                        TotalDiscountAmount_Procedure = 0;
                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            debugger;
                            var dis_amt = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));
                            var isItem = Math.round(parseFloat($(row).find('input[name="DisAmount"]').val()));

                            var isProcedure = $(value).find('input[name="hdnProcedure"]').val();
                            var ItemType = $(value).find('input[name="hdnItemType"]').val();
                            var Package = $(value).find('input[name="hdnParentTrans_Type"]').val();
                            if (Package == "Package") {

                            }
                            else {
                                if (isProcedure == "" || isProcedure == "null" || isProcedure == "0" || typeof isProcedure === 'undefined') {


                                }
                                else {
                                    var amt_dis = $(value).find('input[name="DisAmount"]').val();
                                    Procedure += parseFloat(amt_dis);
                                    TotalDiscountAmount_Procedure += parseFloat(amt_dis);

                                }
                            }

                        });
                        if (Procedure > max_Total_Dic_Amt_Procedure) {
                            debugger;

                            var sub1 = TotalDiscountAmount_Procedure - DisAmt;
                            var sub2 = max_Total_Dic_Amt_Procedure - sub1;
                            var amt = Math.abs(sub2);
                            var Total_Dis_Amt = Math.round(parseInt(amt));

                            $(row).find('input[name="DisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                            $(row).find('input[name="hdnDisAmount"]').val(Math.round(Total_Dis_Amt.toFixed(2)));
                            var DisPer = 100 / Amount * amt;
                            $(row).find('input[name="hdnDisPer"]').val(DisPer);
                            $(row).find('input[name="DisPer"]').val(DisPer);
                            var Amount = $(row).find('td:eq(5)').text().trim();
                            var Net_Amount = (parseInt(Amount) * parseInt(qty)) - amt;
                            $(row).find('td:eq(8)').text(Net_Amount.toFixed(0));
                            isItemCompeted_Procedure = true;
                            TotalDiscountAmount_Procedure = max_Total_Dic_Amt_Procedure;
                        }
                        else {
                            isItemCompeted_Procedure = false;
                            TotalDiscountAmount_Procedure = Procedure;
                        }
                        var total_Disc = 0;
                        var Net_Amt = 0;
                        var total_amt = 0;
                        var qty = 0;
                        //After 
                        if (isItemCompeted_Procedure == true) {

                            debugger;


                        }
                        $.each($('#tblDetails tbody tr'), function (key, value) {
                            debugger;

                            total_Disc += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                            var qty = $(value).find('input[name="txtQty"]').val();

                            Net_Amt += (Math.round(parseFloat($($(value).find('td')[5]).text())) * qty);

                            total_amt += Math.round(parseFloat($($(value).find('td')[8]).text()));

                        });

                        $('#txtTotalAmount').val(Net_Amt);
                        var previouspaid = $('#txtprevious_paid').val();
                        var totalpayable = Net_Amt - previouspaid;
                        $('#txtTotalPayable').val(totalpayable);
                        $('#txtDisAmt').val(total_Disc);
                        var net = totalpayable - total_Disc;
                        
                        $('#txtNetPayable').val(total_amt);
                        var AmtReceived = $('#txtAmountReceived').val();
                        if ($('#txtTotalPayable').val() != '') {
                            if (AmtReceived != '') {
                                $('#txtBalances').val((net - AmtReceived).toFixed());
                            }
                            else
                                $('#txtBalances').val(net.toFixed());
                        }
                        else {
                            $('#txtBalances').val(net.toFixed());
                        }

                    }

                }

                var $currentRow = $(anchor).closest('tr');
                var currentQty = parseFloat($currentRow.find('input[name="txtQty"]').val()) || 1;

                var perUnitDoc = parseFloat($currentRow.find('input[name="hdnPerUnitDocShare"]').val());
                var perUnitHoc = parseFloat($currentRow.find('input[name="hdnPerUnitHocShare"]').val());

                if (!isNaN(perUnitDoc) && !isNaN(perUnitHoc)) {
                    var newDocShare = perUnitDoc * currentQty;
                    var newHocShare = perUnitHoc * currentQty;

                    $currentRow.find('input[name="DocShare"]').val(newDocShare.toFixed(2));
                    $currentRow.find('input[name="HocShare"]').val(newHocShare.toFixed(2));

                    if (typeof calculateDoctorShare === 'function') {
                        calculateDoctorShare();
                    }
                }
                CalculateSummariesMaster(false)
                CountBalance()
            }


            debugger;
            function SumTotalAmountrecived() {
                debugger;
                var Cash_in_Hand = $('#txtcashinhand').val();
                var BankCash = $('#txtbankcash').val();
                if (BankCash == "") {
                    BankCash = 0;
                }
                if (Cash_in_Hand == "") {
                    Cash_in_Hand = 0;
                }


                $('#txtAmountReceived').val((Math.round(parseFloat(Cash_in_Hand)) + parseFloat(BankCash)).toFixed(0));
                CountBalance()
            }
            debugger;
            //function CountBalance() {
            //    debugger;
            //    var PreviousPaid = parseFloat($("#txtprevious_paid").val()) || 0;
            //    var PreviousAmount = parseFloat($("#txtprevious_Amount").val()) || 0;
            //    var PreviousBalance = parseFloat($("#txt_balance").val()) || 0;
            //    var AdvanceAmount = parseFloat($("#txtadvance_amount").val()) || 0;
            //    debugger;
            //    var AmtReceived = $('#txtAmountReceived').val();
            //    if ($('#txtTotalPayable').val() != '') {
            //        var Totalpayable = (Math.round(parseFloat($('#txtNetPayable').val()))).toFixed(0)
            //        if (AmtReceived != '') {
            //            $('#txtBalances').val((parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid));

            //            var prebln = (parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid)
            //            $('#txtPreviousBlnc').val(prebln);
            //        }
            //        else
            //            $('#txtBalances').val((parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid));
            //        var prebln = (parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid)
            //        $('#txtPreviousBlnc').val(prebln);
            //    }
            //    else {
            //        $('#txtBalances').val((parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid));
            //        var prebln = (parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount + PreviousPaid)
            //        $('#txtPreviousBlnc').val(prebln);
            //    }
            //}
            debugger;
            function CountBalance() {
                debugger;
                var PreviousPaid = parseFloat($("#txtprevious_paid").val()) || 0;
                var PreviousAmount = parseFloat($("#txtprevious_Amount").val()) || 0;
                var PreviousBalance = parseFloat($("#txt_balance").val()) || 0;
                var AdvanceAmount = parseFloat($("#txtadvance_amount").val()) || 0;
                var RefundAmount = parseFloat($("#txtRefund_amount").val()) || 0;
                var AmtReceived = $('#txtAmountReceived').val();

                var Totalpayable = 0;
                var finalAmountVal = $('#txtFinalAmount').val();
                if (finalAmountVal && finalAmountVal != '0' && finalAmountVal != '' && !isNaN(parseFloat(finalAmountVal))) {
                    Totalpayable = parseFloat(finalAmountVal).toFixed(0);
                }
                else if ($('#txtNetPayable').val() && $('#txtNetPayable').val() != '') {
                    Totalpayable = parseFloat($('#txtNetPayable').val()).toFixed(0);
                }

                if (AmtReceived != '' && !isNaN(parseFloat(AmtReceived))) {
                    var balance = (parseFloat(Totalpayable) + PreviousAmount) - (parseFloat(AmtReceived) + AdvanceAmount );
                    $('#txtBalances').val(balance.toFixed(0));
                    $('#txtPreviousBlnc').val(balance.toFixed(0));
                }
                else {
                    var balance = (parseFloat(Totalpayable) + PreviousAmount) - (AdvanceAmount );
                    $('#txtBalances').val(balance.toFixed(0));
                    $('#txtPreviousBlnc').val(balance.toFixed(0));
                }
            }
            var doctors = '';
            function FillDoctors() {

                var options = '<option value="0">Select Doctor</option>';

                PageMethods.GetDoctors(function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                    });
                    $('#ddlDoctor').html(options);
                    $('#ddlReffered_By').html(options);
                    doctors = options;
                    $('#ddlDoctor').select2();
                    $('#ddlReffered_By').select2();
                    Doctor_Name = options;
                    doctorListGlobal = options;
                    doctorsListGlobalResponse = JSON.parse(data);
                });
            }
            debugger;
            function AddPackage() {
                debugger;
                var disc = "0.00";
                var remarks = $('#Remarks').val();

                var PackType = $("#hdn_pkgtype").val();
                var packname = $("#hdn_pkgname").val();

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetPackageDetails",
                    data: JSON.stringify({
                        'PackType': PackType,
                        'packname': packname
                    }),
                    contentType: "application/json; charset=utf-8",
                    datatype: "json",
                    success: function (resp) {
                        var data = JSON.parse(resp.d);
                        var rowIndex = $('#tblDetails tbody tr').length;

                        // ?? Ensure doctors is valid
                        if (typeof doctors === 'undefined' || !doctors) {
                            console.error("? 'doctors' variable is not defined or empty!");
                            return;
                        }

                        $.each(data, function (key, value) {
                            var disc = "0.00";
                            var itemanme = value.Item_Name || value.GroupName;

                            // ? Safely get Share_type
                            var shareType = null;
                            if (value.m && value.m.Share_type !== undefined) {
                                shareType = value.m.Share_type;
                            } else if (value.Share_type) {
                                shareType = value.Share_type;
                            } else {
                                shareType = '';
                            }
                            var TestDate = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                            // ? Build select safely
                            var disabledAttr = (shareType === '002') ? ' disabled' : '';
                            var doctorSelect =
                                '<select id="ddldoctor' + (rowIndex + 1) + '" ' +
                                'name="ddlDoctor" ' +
                                'onchange="GetDocAgreementValuess(this)" ' +
                                'class="ddlDoctor"' +
                                disabledAttr + '>' +
                                doctors +
                                '</select>';

                            // ? Build row
                            var row = '<tr>' +
                                '<td style="text-align:center;">' + (rowIndex + 1) + '</td>' +
                                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                                '<td style="text-align:left;">' +
                                '<input type="hidden" name="hdnParentTrans_ID" value="' + (value.ParentTrans_ID || '') + '" />' +
                                '<input type="hidden" name="hdnParentTrans_Name" value="' + (value.ParentTrans_Name || '') + '" />' +
                                '<input type="hidden" name="hdnParentTrans_Type" value="' + (value.ParentTrans_Type || '') + '" />' +
                                '<input type="hidden" name="hdnDisPer" value="' + disc + '" />' +
                                '<input type="hidden" name="hdnDisAmount" value="0.00" />' +
                                '<input type="hidden" name="hdnNet_Amount" value="' + value.Amount + '" />' +
                                '<input type="hidden" name="hdnItemID" value="' + value.Item_Code + '" />' +
                                '<input type="hidden" name="hdnItemName" value="' + itemanme + '" />' +
                                '<input type="hidden" name="hdnItemType" value="' + value.Item_Type + '" />' +
                                '<input type="hidden" name="hdnRecommendedByDoctor" value="false" />' +
                                itemanme +
                                '</td>' +
                                '<td></td>' +
                                '<td>' +
                                '<input type="text" name="txtQty" disabled value="1" style="width:45px" onkeyup="CulculateAmonutWithQty(this)" />' +
                                '<input type="hidden" name="txtActualAmount" value="' + value.Amount + '" />' +
                                '<input type="hidden" name="hdnCategory_ID" value="' + value.Category_ID + '" />' +
                                '</td>' +
                                '<td style="text-align:right" onkeypress="CalculateSummarieDiscountPerWise(' + rowIndex + ')">' + value.Amount + '</td>' +
                                '<td><input type="text" name="DisPer" value="' + disc + '" style="width:37px" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')" /></td>' +
                                '<td><input type="text" name="DisAmount" value="" style="width:75px" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')" disabled /></td>' +
                                '<td style="text-align:right;">45</td>' +
                                '<td><input type="number" id="DocShare' + rowIndex + '" name="DocShare" value="0" style="width:75px" onkeyup="calculateDoctorShare()" /></td>' +
                                '<td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="0" style="width:75px" onkeyup="calculateDoctorShare()" /></td>' +
                                '<td>' + doctorSelect + '</td>' +
                                '<td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td>' +
                                '</tr>';



                            $('#tblDetails tbody').append(row);
                            CalculateSummarieDiscountPerWise(rowIndex);
                            var $newRow = $('#tblDetails tbody tr').eq(rowIndex);
                            var $amountCell = $newRow.find('td').eq(5);
                            if (Alloweditrate == "true") {
                                $amountCell.attr('contenteditable', true);
                            }
                            else {
                                $amountCell.attr('contenteditable', false);
                            }

                            // Patient type logic
                            //if ($("#lblPatientDiscountType").text().trim() === "Private") {
                            //    $("#tblDetails tr").each(function () {
                            //        //2right
                            //        $(this).find("td:eq(5)").attr('contenteditable', 'true');
                            //    });
                            //}

                            rowIndex++;
                        });

                        $('input[name="DisAmount"]').prop('disabled', true);
                    },
                    failure: function (error) {
                        alert(error.get_message());
                    }
                });
            }
            var Item_Discount = 0;
            var isItemCompeted = false;
            var isItemCompeted_Procedure = false;
            var notProcedurenotITem = false;
            debugger;


            function AddServiceOrItem() {
                debugger;

                var alreadyExists = false;
                $("#tblDetails tbody tr").each(function () {
                    var existingItemId = $(this).find('input[name="hdnItemID"]').val();
                    if (existingItemId == localStorage.SelectedItemID) {
                        alreadyExists = true;
                        return false;
                    }
                });

                if (alreadyExists) {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Service Already Added!',
                        text: 'This service is already in the list.',
                        showConfirmButton: true,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return;
                }

                notProcedurenotITem = false;
                localStorage.IsPocedure = false;
                if ($('#lblPatientDiscountType').text() == "Insurance Company") {
                    debugger;
                    var Type = '';
                    var Item_Id = $('#txtAddService').val();
                    if (is_Patient_Temp == true) {
                        Type = "IPD"
                    }
                    else {
                        Type = "OPD";
                    }
                    debugger;
                    var panel_id = 0;
                    if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || typeof localStorage.OPD_Panel_ID === 'undefined') panel_id = localStorage.IPD_PAnel_ID;
                    if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || typeof localStorage.IPD_PAnel_ID === 'undefined')
                        panel_id = localStorage.OPD_Panel_ID;
                    if (localStorage.OPD_Panel_ID != "null" && localStorage.IPD_PAnel_ID != "null") {
                        panel_id = localStorage.IPD_PAnel_ID;
                    }
                    debugger;
                    $.each(arr, function (index, value) {
                        if (Item_Id == value.Item_ID && panel_id == value.Panel_ID) {
                            debugger;

                            localStorage.SelectedItemAmount = value.Rate;
                            DiscountAMt = value.Discount;

                        }
                    });
                }
                debugger;

                var isHospital = localStorage.IsHospitalServices;
                var isMajorMinor = localStorage.Procedure_types;
                var isservice = localStorage.isService;
                var disc = "0.00";
                if (isMajorMinor == 0 || isMajorMinor == null || isMajorMinor == "null") {
                    debugger;

                    isMajorMinor = "";
                    disc = localStorage.Disc;

                    if (isHospital == true || isHospital == 'true' || isservice == true || isservice == "true") {

                        if (isItemCompeted == true) {

                            localStorage.Disc = "0.00";
                        }
                        if (max_Total_Dic_Amt_Item != 0) {

                        }
                        else {
                            max_Total_Dic_Amt_Item = Math.abs(localStorage.Total_Disc_Amt); //1000

                        }
                    }

                }
                else {

                    disc = localStorage.Disc_Pro;
                    localStorage.IsPocedure = true;
                    if (isItemCompeted_Procedure == true) {
                        localStorage.Disc = "0.00";
                    }
                    if (max_Total_Dic_Amt_Procedure != 0) {

                    }
                    else {
                        max_Total_Dic_Amt_Procedure = localStorage.Total_Disc_Amt_pro;
                    }


                }

                var remarks = $("#ctl00_MainContent_ddlpro_dis").val();
                setTimeout(function () {
                    if ($('#txtAddService').val() == "")
                        return false;
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    debugger;
                    var dateValue = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                    if (CheckInPatientObject == true) {
                        if (isNaN(validate)) {
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="InPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /><input type="hidden" name="hdnProcedure" value="' + isMajorMinor + '" /> <input type="hidden" name="hdnDisPer" value="' + disc + '"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td> ' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this,' + true + ',' + false + ')"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td id="amnt' + rowIndex + '" name"amnt" style="text-align:Right;"onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + '</td><td> <input type="text" name="DisPer" value="' + disc + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">' + localStorage.SelectedItemAmount + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + ' </td> </tr>'


                        }
                        else {
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="InPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /><input type="hidden" name="hdnProcedure" value="' + isMajorMinor + '" /> <input type="hidden" name="hdnDisPer" value="' + disc + '"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td> ' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this,' + localStorage.IsHospitalServices + ',' + localStorage.IsPocedure + ')"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td id="amnt' + rowIndex + '" name"amnt" style="text-align:Right;"onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + '</td><td> <input type="text" name="DisPer" value="' + disc + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">' + localStorage.SelectedItemAmount + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + ' </td> </tr>'
                        }
                    }
                    else {

                        if (isNaN(validate)) {
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="InPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /><input type="hidden" name="hdnProcedure" value="' + isMajorMinor + '" /> <input type="hidden" name="hdnDisPer" value="' + disc + '"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td> ' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this,' + true + ',' + false + ')"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td style="text-align:Right;" id="amnt' + rowIndex + '" name"amnt" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + '</td><td> <input type="text" name="DisPer" value="' + disc + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">' + localStorage.SelectedItemAmount + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + ' </td> </tr>'


                        }
                        else {
                            var rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + localStorage.SelectedItemID + '" /> <input type="hidden" name="hdnItemName" value="' + localStorage.SelectedItemName + '" /><input type="hidden" name="hdnProcedure" value="' + isMajorMinor + '" /> <input type="hidden" name="hdnDisPer" value="' + disc + '"/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + localStorage.SelectedItemAmount + '/><input type="hidden" name="hdnItemType" value="' + localStorage.SelectedItemType + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + localStorage.SelectedItemName + '</td><td> ' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this,' + localStorage.IsHospitalServices + ',' + localStorage.IsPocedure + ')"/><input type="hidden" name="txtActualAmount" value="' + localStorage.SelectedItemAmount + '"  /></td><td style="text-align:Right;" id="amnt' + rowIndex + '" name"amnt" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + localStorage.SelectedItemAmount + ' </td><td> <input type="text" name="DisPer" value="' + disc + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">' + localStorage.SelectedItemAmount + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;"  onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + ' </td> </tr>'
                        }
                    }



                    $('#tblDetails tbody').append(rows);
                    $('.ddlDoctor').select2();

                    loadBOMDetails(localStorage.SelectedItemID)

                    var panel = $("#ddlpanel").val();
                    if (panel != 0 || panel != "0") {
                        GetpanelServiceRate(panel, localStorage.SelectedItemID);
                    }


                    debugger;
                    if (Alloweditrate == "true") {

                        $("#amnt" + rowIndex).attr('contenteditable', true);

                    }
                    else {
                        $("#amnt" + rowIndex).attr('contenteditable', false);
                    }


                    var user_name = '<% =AppConfig.UserName %>';
                    // Ali.Tariq
                    //if (user_name === "Ali.Tariq" || user_name === "ali.tariq") {
                    //    debugger;
                    //    $('input[name="DisPer"]').attr('disabled', false);
                    //    $('input[name="DisAmount"]').attr('disabled', false);
                    //}
                    /* else {*/
                    $('input[name="DisAmount"]').attr('disabled', true);
                    //}
                    $('#txtDisPer').on('keyup', function () {
                        $('#tblDetails').find('input[name="DisPer"]').prop('disabled', true);
                        $('#tblDetails').find('input[name="DisAmount"]').prop('disabled', true);
                    });
                    $(document).on('keyup', 'input[name="DisPer"]', function () {
                        $('#txtDisPer').prop('disabled', true);
                        $('#txtDisAmt').prop('disabled', true);
                    });


                    ////else
                    ////{
                    ////       // $('input[name="DisPer"]').attr('disabled', true);
                    ////        $('input[name="DisAmount"]').attr('disabled', true);

                    ////}





                    if ($('#lblPatientCategory').text() == "Insurance Company") {
                        if (Type == "IPD") {
                            $('#txtDisPer').val(DiscountAMt);
                            CalculateSummariesMaster(false);
                        }
                        else if (Type = "OPD") {
                        }
                    }
                    debugger;
                    CalculateSummarieDiscountPerWise(rowIndex);

                    debugger;
                    var ItemId = localStorage.SelectedItemID;
                    var pat_type = $("#lblPatientDiscountType").text();
                    var INP_Private = $("#lblPatientCategory").text();

                    if (pat_type == "Private" || INP_Private == "Private") {
                        if (ItemId == 12402 || ItemId == 12404 || ItemId == 12408 || ItemId == 14218 || ItemId == 12407 || ItemId == 18138 || ItemId == 12393 || ItemId == 13206 || ItemId == 13208 || ItemId == 18842) {
                            $("#tblDetails tr").each(function () {
                                var item_id = $('#txtAddService').val();
                                var row_item_id = $(this).find('input[name="hdnItemID"]').val();

                            });
                        }
                    }
                    else if (pat_type == "Insurance Company" || INP_Private == "Insurance Company") {

                        debugger;
                        //if (ItemId == 13206 || ItemId == 18842 || ItemId == 13208 || ItemId == 12393 || ItemId == 19192 || ItemId == 19068) {
                        //    $("#tblDetails tr").each(function () {
                        //        debugger;
                        //        var item_id = $('#txtAddService').val();
                        //        var row_item_id = $(this).find('input[name="hdnItemID"]').val();
                        //        if (item_id == row_item_id) {

                        //            $(this).find("td:eq(5)").attr('contenteditable', 'True');
                        //        }
                        //    });
                        //}
                    }

                    var user_name = '<% =AppConfig.UserName %>';
                    // Ali.Tariq
                    if (user_name == "Ali.Tariq" || user_name == "ali.tariq") {
                        debugger;
                        if (typeof localStorage.Total_Disc_Amt === 'undefined') {
                            debugger;
                            $('input[name="DisPer"]').attr('disabled', false);
                            $('input[name="DisAmount"]').attr('disabled', false)
                        }
                        else {
                            $('input[name="DisAmount"]').attr('disabled', true)
                        }
                    }
                    else {
                        $('input[name="DisAmount"]').attr('disabled', true)
                    }
                }, 300);
                setTimeout(function () {
                    $(arr).filter(function (i, n) {
                        var company_id = 0;
                        if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || localStorage.OPD_Panel_ID == 0 || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                        if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || localStorage.IPD_PAnel_ID == 0 || typeof localStorage.IPD_PAnel_ID === 'undefined')
                            company_id = localStorage.OPD_Panel_ID;
                        var lblPatientCategory = $('#lblPatientCategory').text();
                        var lblIn_Patient_Category = $('#lblPatientDiscountType').text();
                        if ((lblPatientCategory == "Sehat Sahulat Card") || (lblIn_Patient_Category == "Sehat Sahulat Card")) {
                            company_id = "39";
                        }
                        if (n.Panel_ID == company_id) {
                            $('#txtDisPer').val(n.Discount);
                            if (isNaN(validate)) {

                            }
                            var disTotal = $('#txtDisPer').val();
                            if (disTotal != "") {
                                CalculateSummariesMaster(false);
                            }
                            else {
                                CalculateSummariesMaster(false);
                            }
                            return false;
                        }

                    });
                }, 700);


            }
            function GetpanelServiceRate(Panel_Id, Item_Id) {
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetpanelServiceRate",
                    data: JSON.stringify({ "Panel_Id": Panel_Id, "Item_Id": Item_Id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        var data = JSON.parse(response.d);
                        var newRate = parseFloat(data.Rate || 0);
                        var $lastRow = $("#tblDetails tbody tr:last");
                        $lastRow.find('input[name="txtActualAmount"]').val(newRate);
                        $lastRow.find('input[name="hdnNet_Amount"]').val(newRate);
                        $lastRow.find('td[id^="amnt"]').text(newRate.toFixed(2));
                        var rowIndex = $lastRow.index();
                        CalculateSummarieDiscountPerWise(rowIndex);
                    },
                });
            }

            function GetpanelTestRate(Panel_Id, Test_Id) {
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetpanelTestRate",
                    data: JSON.stringify({ "Panel_Id": Panel_Id, "Test_Id": Test_Id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        var data = JSON.parse(response.d);
                        var newRate = parseFloat(data.Rate || 0);
                        var $lastRow = $("#tblDetails tbody tr:last");
                        $lastRow.find('input[name="txtActualAmount"]').val(newRate);
                        $lastRow.find('input[name="hdnNet_Amount"]').val(newRate);
                        $lastRow.find('td[id^="amnt"]').text(newRate.toFixed(2));
                        var rowIndex = $lastRow.index();
                        CalculateSummarieDiscountPerWise(rowIndex);
                    },
                });
            }

            function GetpanelGroupTestRate(Panel_Id, Test_Id) {
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetpanelGroupTestRate",
                    data: JSON.stringify({ "Panel_Id": Panel_Id, "Test_Id": Test_Id }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        var data = JSON.parse(response.d);
                        var newRate = parseFloat(data.Rate || 0);
                        var $lastRow = $("#tblDetails tbody tr:last");
                        $lastRow.find('input[name="txtActualAmount"]').val(newRate);
                        $lastRow.find('input[name="hdnNet_Amount"]').val(newRate);
                        $lastRow.find('td[id^="amnt"]').text(newRate.toFixed(2));
                        var rowIndex = $lastRow.index();
                        CalculateSummarieDiscountPerWise(rowIndex);
                    },
                });
            }
            function getbomprocedure() {
                var Pat_id = $('#hdfPatient_ID').val();
                if (!Pat_id || Pat_id <= 0) {
                    console.warn("Invalid Patient ID");
                    return;
                }

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetItemCodesforBOM",
                    data: JSON.stringify({ "Pat_id": parseInt(Pat_id) }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",

                    success: function (response) {
                        var data = response.d;
                        if (!data || data.Item_ID == null || data.Item_ID <= 0) {
                            console.log("No service/item found for this patient.");
                            return;
                        }

                        var rowIndex = $('#tblDetails tbody tr').length;
                        var remarks = $("#ctl00_MainContent_ddlpro_dis").val() || "";
                        var itemtype = data.Services === true ? 'Service' : 'Item';
                        var isMajorMinors = (data.Procedure_types == null ||
                            data.Procedure_types === 0 ||
                            data.Procedure_types === "" ||
                            String(data.Procedure_types).toLowerCase() === "null")
                            ? ""
                            : data.Procedure_types;

                        var servicerow =
                            '<tr>' +
                            '<td style="text-align:left;">' + (rowIndex + 1) + '</td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                            '<td style="text-align:left;">' +
                            '<input type="hidden" name="hdnParentTrans_ID" value="0" />' +
                            '<input type="hidden" name="hdnParentTrans_Name" value="OPD" />' +
                            '<input type="hidden" name="hdnParentTrans_Type" value="" />' +
                            '<input type="hidden" name="hdnItemID" value="' + data.Item_ID + '" />' +
                            '<input type="hidden" name="hdnItemName" value="' + (data.Description || '').replace(/"/g, '&quot;') + '" />' +
                            '<input type="hidden" name="hdnProcedure" value="' + (isMajorMinors || '').replace(/"/g, '&quot;') + '" />' +
                            '<input type="hidden" name="hdnDisPer" value="0" />' +
                            '<input type="hidden" name="hdnDisAmount" value="0.00" />' +
                            '<input type="hidden" name="hdnNet_Amount" value="' + (data.Sale_Rate || 0) + '" />' +
                            '<input type="hidden" name="hdnItemType" value="' + itemtype + '" />' +
                            '<input type="hidden" name="hdnRecommendedByDoctor" value="false" />' +
                            (data.Description || '') +
                            '</td>' +
                            '<td>' + remarks.replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</td>' +
                            '<td>' +
                            '<input type="text" name="txtQty" value="1" style="width: 45px !important;" ' +
                            'onkeyup="CulculateAmonutWithQty(this, true, false)"/>' +
                            '<input type="hidden" name="txtActualAmount" value="' + (data.Sale_Rate || 0) + '" />' +
                            '</td>' +
                            '<td style="text-align:right;" id="amnt' + rowIndex + '" name="amnt">' + (data.Sale_Rate || 0).toFixed(2) + '</td>' +
                            '<td><input type="text" name="DisPer" value="0" style="width: 37px !important;" ' +
                            'onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/></td>' +
                            '<td><input type="text" name="DisAmount" value="0.00" style="width: 75px !important;" disabled ' +
                            'onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/></td>' +
                            '<td style="text-align:right;">' + (data.Sale_Rate || 0).toFixed(2) + '</td>' +
                            '<td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="0" ' +
                            'style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                            '<td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="0" ' +
                            'style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                            '<td><select id="ddldoctor' + (rowIndex + 1) + '" name="ddlDoctor" class="ddlDoctor">' + (typeof doctors !== 'undefined' ? doctors : '') + '</select></td>' +
                            '</tr>';

                        $('#tblDetails tbody').append(servicerow);

                        $('#hdn_opd_procedure').val("1");
                        //setTimeout(function () {
                        CalculateSummarieDiscountPerWise(rowIndex);
                        //}, 500);

                        loadBOMDetails(data.Item_ID);

                    },
                    error: function (xhr, status, error) {
                        console.error("AJAX Error:", error);
                        try {
                            var err = JSON.parse(xhr.responseText);
                            alert("Server Error: " + (err.Message || err));
                        } catch (e) {
                            alert("Failed to load item. Please try again.");
                        }
                    }
                });
            }
            function loadBOMDetails(procedureId) {
                debugger;
                procedureId = parseInt(procedureId);
                if (!procedureId || procedureId <= 0) {
                    console.warn("?? Invalid procedureId:", procedureId);
                    return;
                }

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetBOMDetailsByProcedure",
                    data: JSON.stringify({ "procedureId": procedureId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;
                        var $tbody = $('#tblBOM tbody');
                        $tbody.empty();

                        if (!data || !data.success || !Array.isArray(data.items) || data.items.length === 0) {
                            $tbody.append('<tr><td colspan="9" class="text-center text-muted">— No BOM configured for this procedure —</td></tr>');
                            //$('#bomSection').hide();
                            //$('#bomTotal').hide();
                            return;
                        }
                        data.items.forEach(function (item, idx) {
                            var safeDesc = (item.Description || '—').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                            var safeItemCode = (item.ItemCode || '—').replace(/</g, '&lt;').replace(/>/g, '&gt;');
                            //var safeBatch = (item.Batch_No || '—').replace(/</g, '&lt;').replace(/>/g, '&gt;');*

                            var row =
                                '<tr>' +
                                '<td>' + (idx + 1) + '</td>' +
                                '<td>' + safeItemCode +
                                '<input type="hidden" name="hdnBOMDetailID" value="' + (item.BOMDetailID || 0) + '" />' +
                                '<input type="hidden" name="hdnBOMItemID" value="' + (item.ItemID || 0) + '" />' +
                                '<input type="hidden" name="hdnBOMItemCode" value="' + safeItemCode + '" />' +
                                '<input type="hidden" name="hdnBOMDescription" value="' + (item.Description || '').replace(/"/g, '&quot;') + '" />' +
                                '<input type="hidden" name="hdnBOMBatchNo" value="' + (item.Batch_No || '').replace(/"/g, '&quot;') + '" />' +
                                '</td>' +
                                '<td>' + safeDesc + '</td>' +
                                '<td class="text-right">' + parseFloat(item.Qty).toFixed(2) +
                                '<input type="hidden" name="hdnBOMQty" value="' + (item.Qty || 0) + '" />' +
                                '</td>' +
                                '<td>' + (item.Unit || '—') +
                                '<input type="hidden" name="hdnBOMUnit" value="' + (item.Unit || '') + '" />' +
                                '</td>' +
                                '<td class="text-right text-muted">' + parseFloat(item.RecipeCostPerUnit).toFixed(2) +
                                '<input type="hidden" name="hdnBOMRecipeCost" value="' + (item.RecipeCostPerUnit || 0) + '" />' +
                                '</td>' +
                                '<td class="text-right"><strong>' + parseFloat(item.CurrentAvgCost).toFixed(2) +
                                '<input type="hidden" name="hdnBOMAvgCost" value="' + (item.CurrentAvgCost || 0) + '" />' +
                                '</td>' +
                                '<td class="text-right"><strong class="text-danger">' + parseFloat(item.RuntimeCost).toFixed(2) +
                                '<input type="hidden" name="hdnBOMRuntimeCost" value="' + (item.RuntimeCost || 0) + '" />' +
                                '<input type="hidden" name="hdnBOMBaseUnitQty" value="' + (item.BaseUnitQty != null ? item.BaseUnitQty : '') + '" />' +
                                '</td>' +
                                '</tr>';
                            $tbody.append(row);
                        });
                        var totalRuntime = data.items.reduce(function (sum, item) {
                            return sum + parseFloat(item.RuntimeCost || 0);
                        }, 0);

                        $('#bomTotalValue').val(totalRuntime.toFixed(2));
                        // $('#bomTotal').show();

                        //$('#bomSection').show();

                        console.log('? Loaded ' + data.items.length + ' BOM item(s). Total runtime cost: ' + totalRuntime.toFixed(2));
                    },
                    error: function (xhr, status, error) {
                        console.error('? BOM Load Error:', error);
                        try {
                            var err = JSON.parse(xhr.responseText);
                            console.error('Server:', err.Message || err);
                        } catch (e) { }
                        $('#tblBOM tbody').html('<tr><td colspan="9" class="text-danger text-center">?? Failed to load BOM</td></tr>');
                        //$('#bomSection').hide();
                        //$('#bomTotal').hide();
                    }
                });
            }

            var itemIds;
            function getitem_codeEmergency() {
                debugger;
                itemIds = [];
                var Pat_id = $('#hdfPatient_ID').val();
                console.log(Pat_id);

                debugger;
                $.ajax({
                    type: "post",
                    url: "BillingProcess.aspx/GetItemCodesforEmergency",
                    data: JSON.stringify({
                        "Pat_id": Pat_id,
                    }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        debugger;
                        var data = JSON.parse(msg.d);
                        debugger;
                        $.each(data, function (key, value) {
                            debugger;
                            itemIds.push(value);
                        });
                    }

                });

                debugger;
                FetchRecommendedServices(itemIds)
            }
            var itemIds;
            function getitem_codeIpd() {
                debugger;

                var pat_id = $('#hdfPatient_ID').val();
                itemIds = [];
                debugger;
                $.ajax({
                    type: "post",
                    url: "BillingProcess.aspx/GetItemCodesforipd",
                    data: JSON.stringify({
                        "pat_id": pat_id,
                    }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        debugger;
                        var data = JSON.parse(msg.d);
                        debugger;
                        $.each(data, function (key, value) {
                            debugger;
                            itemIds.push(value);
                        });
                    }

                });
                debugger;
                FetchRecommendedServices(itemIds)
            }
            var itemIds;
            function getitem_code() {
                debugger;
                var Pat_id = $('#hdfPatient_ID').val();
                itemIds = [];
                debugger;
                $.ajax({
                    type: "post",
                    url: "BillingProcess.aspx/GetItemCodes",
                    data: JSON.stringify({
                        "Pat_id": Pat_id,
                    }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        debugger;
                        var data = JSON.parse(msg.d);
                        debugger;
                        $.each(data, function (key, value) {
                            debugger;
                            itemIds.push(value);
                        });
                    }

                });
                FetchRecommendedServices(itemIds)
            }
            var ItemCode;
            var servicerow;
            debugger;
            function FetchRecommendedServices(itemIds) {
                debugger;
                itemIds.forEach(function (itemCode) {
                    debugger;
                    var itemId = itemCode;
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var rows;
                    $.ajax({
                        type: "post",
                        url: "BillingProcess.aspx/fetchServices",
                        data: JSON.stringify({
                            "itemId": itemId,
                        }),
                        dataType: 'JSON',
                        contentType: "application/json; charset=utf-8",
                        async: false,
                        success: function (msg) {
                            debugger;
                            var length = $("#tblDetails tr:gt(0)").length;
                            $('#Table_1 tr:gt(0)').remove();
                            var data = JSON.parse(msg.d);
                            debugger;
                            var itemtype = data[0].Services;
                            if (itemtype === true) {
                                itemtype = 'Service';
                            }
                            var isMajorMinors = data[0].Procedure_types;
                            if (isMajorMinors == 0 || isMajorMinors == null || isMajorMinors == "null") {
                                debugger;

                                isMajorMinors = "";
                            }
                            var remarks = $("#ctl00_MainContent_ddlpro_dis").val();
                            var TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[0].Services.substring(6, 19))))

                            debugger;
                            servicerow = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="0" /> <input type="hidden" name="hdnParentTrans_Name" value="OPD" /> <input type="hidden" name="hdnParentTrans_Type" value="" /> <input type="hidden" name="hdnItemID" value="' + data[0].Item_ID + '" /> <input type="hidden" name="hdnItemName" value="' + data[0].Description + '" /><input type="hidden" name="hdnProcedure" value="' + isMajorMinors + '" /> <input type="hidden" name="hdnDisPer" value=""/><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + data[0].Sale_Rate + '/><input type="hidden" name="hdnItemType" value="' + itemtype + '" /><input type="hidden" name="hdnRecommendedByDoctor" value="' + false + '" />' + data[0].Description + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this,' + true + ',' + false + ')"/><input type="hidden" name="txtActualAmount" value="' + data[0].Sale_Rate + '"  /></td><td style="text-align:Right;" id="amnt' + rowIndex + '" name="amnt" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"> ' + data[0].Sale_Rate + '</td><td> <input type="text" name="DisPer" value="0" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;">' + data[0].Sale_Rate + '</td><td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td> </tr>'
                        },
                    });
                    $('#tblDetails tbody').append(servicerow);
                    $('input[name="DisAmount"]').attr('disabled', true)


                    setTimeout(function () {
                        CalculateSummarieDiscountPerWise(rowIndex);
                    }, 1500)

                });
            }

            function ExcludeFromPayment(anchor) {
                console.clear();
                debugger;

                var row = $(anchor).parents('tr')[0];
                var tableName = $(row).closest('table').attr('id');
                if (tableName == "tbltestModelTable") {
                    debugger;
                    var rowIndex = $(anchor).closest('tr').index();
                    $('.blank tr').filter(function () {
                        return this.rowIndex - 1 === rowIndex;
                    }).remove();
                }
                var dis = $(row).find('input[name="DisAmount"]').val();
                var main_department = $(row).find('input[name="Main_Department"]').val();

                row.remove();
                var ItemID = $(row).find('input[name="hdnItemID"]').val();
                var ParentTrans_Type = $(row).find('input[name="hdnParentTrans_Type"]').val();
                if (ParentTrans_Type != "Test Group Category")
                    ExcludedItem_List.push({ ItemID: ItemID, ItemType: "Test" });
                CalculateTotals();

            }
            var length_Lab = 0;
            function CalculateTotals() {
                debugger;
                var Amount = 0;
                var DisAmt = 0;
                var NetAmount = 0;


                Lab = 0;
                UltraSound = 0;
                Xray = 0;
                CT_Scan = 0;
                Blood = 0;
                Item = 0;
                Procedure = 0;
                Package = 0;
                TotalDiscountAmount = 0;
                TotalDiscountAmount_Ultra = 0;
                TotalDiscountAmount_Xray = 0;
                TotalDiscountAmount_CTScan = 0;
                TotalDiscountAmount_Blood = 0;
                TotalDiscountAmount_ITem = 0;
                TotalDiscountAmount_Procedure = 0;
                TotalDiscountAmount_Package = 0;
                $.each($('#tblDetails tbody tr'), function (key, value) {

                    Amount += parseFloat($(this).closest("tr").find("td:eq(5)").text());
                    DisAmt += parseFloat($(value).find('input[name="DisAmount"]').val());
                    NetAmount = Amount - DisAmt;
                    var main_department = $(value).find('input[name="Main_Department"]').val();

                    if (main_department == "001") {


                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount = parseInt(TotalDiscountAmount) + parseInt(dis);
                        Lab = parseInt(Lab) + parseInt(dis);
                        if (TotalDiscountAmount < max_Total_Dic_Amt) {
                            isLabCompeted = false;
                        }


                    }
                    if (main_department == "002") {
                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount_Ultra = parseInt(TotalDiscountAmount_Ultra) + parseInt(dis);
                        UltraSound = parseInt(UltraSound) + parseInt(dis);

                        if (TotalDiscountAmount_Ultra < max_Total_Dic_Amt_Ultra) {
                            isUltraSoundCompleted = false;
                        }
                    }
                    if (main_department == "003") {
                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount_Xray = parseInt(TotalDiscountAmount_Xray) + parseInt(dis);
                        Xray = parseInt(Xray) + parseInt(dis);

                        if (TotalDiscountAmount_Xray < max_Total_Dic_Amt_Xray) {
                            isXrayCompleted = false;
                        }
                    }
                    if (main_department == "004") {
                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount_CTScan = parseInt(TotalDiscountAmount_CTScan) + parseInt(dis);
                        CT_Scan = parseInt(CT_Scan) + parseInt(dis);

                        if (TotalDiscountAmount_CTScan < max_Total_Dic_Amt_ct_Scan) {
                            isCTScanCompleted = false;
                        }
                    }
                    if (main_department == "005") {
                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount_Blood = parseInt(TotalDiscountAmount_Blood) + parseInt(dis);
                        Blood = parseInt(Blood) + parseInt(dis);

                        if (TotalDiscountAmount_Blood < max_Total_Dic_Amt_Blood) {
                            isBloodBankCompleted = false;
                        }
                    }

                    var isProcedure = $(value).find('input[name="hdnProcedure"]').val();

                    var ItemType = $(value).find('input[name="hdnItemType"]').val();
                    var PAckage = $(value).find('input[name="hdnParentTrans_Type"]').val();
                    if (PAckage == "Package") {
                        var dis = $(value).find('input[name="DisAmount"]').val();
                        TotalDiscountAmount_Package = parseInt(TotalDiscountAmount_Package) + parseInt(dis);
                        Package = parseInt(Package) + parseInt(dis);

                        if (TotalDiscountAmount_Package < max_Package_Amt) {
                            isPackageCompleted = false;
                        }
                    }
                    else {
                        if (isProcedure == "" || isProcedure == "null" || isProcedure == "0" || typeof isProcedure === 'undefined') {
                            if (ItemType == "Item" || ItemType == "Service") {
                                var dis = $(value).find('input[name="DisAmount"]').val();
                                TotalDiscountAmount_ITem = parseInt(TotalDiscountAmount_ITem) + parseInt(dis);
                                Item = parseInt(Item) + parseInt(dis);

                                if (TotalDiscountAmount_ITem < max_Total_Dic_Amt_Item) {
                                    isItemCompleted = false;
                                }
                            }


                        }

                        else {

                            var dis = $(value).find('input[name="DisAmount"]').val();
                            TotalDiscountAmount_Procedure = parseInt(TotalDiscountAmount_Procedure) + parseInt(dis);
                            Procedure = parseInt(Procedure) + parseInt(dis);

                            if (TotalDiscountAmount_Procedure < max_Total_Dic_Amt_Procedure) {
                                isItemCompeted_Procedure = false;
                            }

                        }
                    }
                    if (main_department == "001") {
                        if (Lab == 0) {
                            TotalDiscountAmount = 0;
                        }
                    }
                    if (main_department == "002") {
                        if (UltraSound == 0) {
                            TotalDiscountAmount_Ultra = 0;
                        }
                    }
                    if (main_department == "003") {
                        if (Xray == 0) {
                            TotalDiscountAmount_Xray = 0;
                        }
                    }
                    if (main_department == "004") {
                        if (CT_Scan == 0) {
                            TotalDiscountAmount_CTScan = 0;
                        }
                    }
                    if (main_department == "005") {
                        if (Blood == 0) {
                            TotalDiscountAmount_Blood = 0;
                        }
                    }
                    var isProcedure = $(value).find('input[name="hdnProcedure"]').val();
                    var ItemType = $(value).find('input[name="hdnItemType"]').val();
                    var PAckage = $(value).find('input[name="hdnParentTrans_Type"]').val();
                    if (PAckage == "Package") {
                        if (Package == 0) {
                            TotalDiscountAmount_Package = 0;
                        }

                    }
                    else {
                        if (isProcedure == "" || isProcedure == "null" || isProcedure == "0" || typeof isProcedure === 'undefined') {
                            if (ItemType == "Item" || ItemType == "Service") {
                                if (Item == 0) {
                                    TotalDiscountAmount_ITem = 0;
                                }

                            }
                        }
                        else {
                            if (Procedure == 0) {
                                TotalDiscountAmount_Procedure = 0;
                            }

                        }
                    }

                });

                Math.round($('#txtTotalPayable').val(Amount), 2);
                Math.round($('#txtTotalAmount').val(Amount), 2);
                $('#txtDisAmt').val(parseInt(Math.round(DisAmt)));
                $('#txtNetPayable').val(Math.round(NetAmount));

                var PreviousPaid = parseFloat($("#txtprevious_paid").val()) || 0;
                var PreviousAmount = parseFloat($("#txtprevious_Amount").val()) || 0;
                var PreviousBalance = parseFloat($("#txt_balance").val()) || 0;
                var AdvanceAmount = parseFloat($("#txtadvance_amount").val()) || 0;
                var RefundAmount = parseFloat($("#txtRefund_amount").val()) || 0;
                var TotalNetAmount = parseFloat($("#txtTotalAmount").val())
                var AmtReceived = $('#txtAmountReceived').val();
                if ($('#txtTotalPayable').val() != '') {
                    if (AmtReceived != '') {
                        // $('#txtBalances').val(Math.round(parseFloat(NetAmount) - parseFloat(AmtReceived)));
                        $('#txtBalances').val(((TotalNetAmount + PreviousAmount) - (AmtReceived + AdvanceAmount + PreviousPaid)).toFixed());
                    }
                    else
                        // $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
                        $('#txtBalances').val(((TotalNetAmount + PreviousAmount) - (AmtReceived + AdvanceAmount + PreviousPaid)).toFixed());
                }
                else {
                    // $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
                    $('#txtBalances').val(((TotalNetAmount + PreviousAmount) - (AmtReceived + AdvanceAmount + PreviousPaid)).toFixed());
                }
            }
            function checkRepeat() {
                var patID = $('#txtMRNo').val();
                PageMethods.checkRepeat(patID, function (data) {
                    if (data == "[]") {
                        CheckInPatientObject = false;
                    }
                    else {
                        CheckInPatientObject = true;
                    }
                }, function (error) { })
            }
            debugger;
            function FetchRecommendedDetails() {

                debugger;
                var remarks = $('#Remarks').val();
                $('#hdfPatient_ID').val($('#txtMRNo').val())
                PageMethods.FetchRecommendedDetails($('#hdfPatient_ID').val(), function (resp) {
                    debugger;
                    var rows = '';

                    var List = [];
                    var counter = 1;
                    $('#tblDetails tbody tr').remove();
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    $.each(JSON.parse(resp), function (key, value) {
                        debugger;
                        var TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Test_CreatedDate.substring(6, 19))))
                        rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="OutPatient" /><input type="hidden" name="Main_Department" value="' + value.MainDepartment + '" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.ItemID + '"/><input type="hidden" name="hdnItemName" value="' + value.ItemName + '" /> <input type="hidden" name="hdnItemType" value="' + value.ItemType + '" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + value.Amount + '/><input type="hidden" name="hdnCategory_ID" value="' + value.CategoryID + '" /> <input type="hidden" name="hdnDisPer" value="0" /><input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />' + value.ItemName + '</td><td>' + remarks + '</td><td><input type="text" name="txtQty" disabled="disabled" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td style="text-align:Right;"> ' + value.Amount + ' </td><td> <input type="text" name="DisPer" value="0"style="width: 75px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount"  value="0.00" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"> ' + value.Amount + '</td><td><input type="text" name="DocShare" id="ds' + rowIndex + '"  value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td></tr>'
                        debugger;
                        $('#tblDetails tbody').append(rows);
                        $('input[name="DisAmount"]').attr('disabled', true)
                        if (rows != '')
                            setTimeout(function () {
                                CalculateSummarieDiscountPerWise(rowIndex);
                            }, 1500)
                        rowIndex++;
                    });
                    debugger;

                    getitem_code();

                    FetchRecommendedInPatientDetails();
                    getbomprocedure();
                });
            }
            function FetchRecommendedInPatientDetails() {
                debugger;
                $('#hdfPatient_ID').val($('#txtMRNo').val())
                PageMethods.FetchRecommendedInPatientDetails($('#hdfPatient_ID').val(), function (resp) {
                    debugger;
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var List = [];
                    var counter = 1;

                    $.each(JSON.parse(resp), function (key, value) {
                        debugger;
                        var TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Test_CreatedDate.substring(6, 19))))
                        rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="Main_Department" value="' + value.MainDepartment + '" /> <input type="hidden" name="hdnParentTrans_Name" value="InPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.ItemID + '"/><input type="hidden" name="hdnItemName" value="' + value.ItemName + '" /> <input type="hidden" name="hdnItemType" value="' + value.ItemType + '" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + value.Amount + '/><input type="hidden" name="hdnCategory_ID" value="' + value.CategoryID + '" /> <input type="hidden" name="hdnDisPer" value="0" /><input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />' + value.ItemName + '</td><td>' + value.Remarks + '</td><td><input type="text" name="txtQty" disabled="disabled" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td style="text-align:Right;"> ' + value.Amount + ' </td><td> <input type="text" name="DisPer" value="0"style="width: 75px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"> ' + value.Amount + ' </td><td><input type="text" name="DocShare" id="ds' + rowIndex + '"  value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td> </tr>'

                        $('#tblDetails tbody').append(rows);

                        $('input[name="DisAmount"]').attr('disabled', true)
                        if (rows != '')
                            debugger;
                        CheckItemsinPackages(value.ItemID);
                        CalculateSummarieDiscountPerWise(rowIndex);
                        rowIndex++;
                    });
                    debugger;
                    getitem_codeIpd();
                    checkRepeat();
                    FetchRecommendedEmergencyPatDetails();
                });
            }
            function CheckItemsinPackages(itemid, itemname) {
                debugger;
                var PackType = $("#hdn_pkgtype").val();
                var packname = $("#hdn_pkgname").val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/CheckItemsinPackages",
                    data: JSON.stringify({
                        PackType: PackType,
                        packname: packname,
                        itemid: itemid
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        const result = JSON.parse(response.d);
                        console.log(result)
                        if (result.ItemExists) {
                            alert(`Item "${result.ItemName}" exists in the package!`);
                        }
                    },
                    error: function (error) {
                        console.error("Error:", error);
                        alert("An error occurred while checking the package.");
                    }
                });
            }


            function FetchRecommendedEmergencyPatDetails() {
                debugger;
                $('#hdfPatient_ID').val($('#txtMRNo').val());

                PageMethods.FetchRecommendedEmergencyDetails($('#hdfPatient_ID').val(), function (resp) {
                    debugger;
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var List = [];
                    var counter = 1;

                    $.each(JSON.parse(resp), function (key, value) {
                        var TestDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Test_CreatedDate.substring(6, 19))))
                        rows = '<tr><td style="text-align:left;">' + parseInt(parseInt(rowIndex) + 1) + '</td><td> <a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td><td style="text-align:left;"> <input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" /> <input type="hidden" name="hdnParentTrans_Name" value="EmergencyPatient" /> <input type="hidden" name="Main_Department" value="' + value.MainDepartment + '" /><input type="hidden" name="hdnParentTrans_Name" value="EmergencyPatient" /> <input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" /> <input type="hidden" name="hdnItemID" value="' + value.ItemID + '"/><input type="hidden" name="hdnItemName" value="' + value.ItemName + '" /> <input type="hidden" name="hdnItemType" value="' + value.ItemType + '" /><input type="hidden" name="hdnDisAmount" value="0.00"/><input type="hidden" name="hdnNet_Amount" value=' + value.Amount + '/><input type="hidden" name="hdnCategory_ID" value="' + value.CategoryID + '" /> <input type="hidden" name="hdnDisPer" value="0" /><input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '/><input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />' + value.ItemName + '</td><td>' + value.Remarks + '</td><td><input type="text" name="txtQty" disabled="disabled" value="1" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)"/><input type="hidden" name="txtActualAmount" value="' + value.Amount + '" /></td><td style="text-align:Right;"> ' + value.Amount + ' </td><td> <input type="text" name="DisPer" value="0"style="width: 75px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/> </td><td> <input type="text" name="DisAmount" value="" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/> </td> <td style="text-align:Right;"> ' + value.Amount + ' </td><td><input type="text" name="DocShare" id="ds' + rowIndex + '"  value="' + 0 + '"  style="width: 75px !important;"onkeyup="calculateDoctorShare()"/></td><td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="' + 0 + '"  style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>><td><select id="ddldoctor' + parseInt(parseInt(rowIndex) + 1) + '" name="ddlDoctor" onchange="GetDocAgreementValuess(this)" class="ddlDoctor" >' + doctors + '</select></td><td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + TestDate + '"/>' + TestDate + ' </td> </tr>'
                        $('#tblDetails tbody').append(rows);
                        $('input[name="DisAmount"]').attr('disabled', true)
                        if (rows != '')
                            CalculateSummarieDiscountPerWise(rowIndex);
                        rowIndex++;
                    });
                    debugger;

                    checkRepeat();
                    getitem_codeEmergency();
                });
            }
            localStorage.IsZero_Amt = 0;
            localStorage.IsZero_Procedure = 0;
            localStorage.IsBothAmtand = 0;
            localStorage.IsPackage = 0;
            localStorage.OnlyPackagePercentage = 0;
            function LoadITemsForPackage(Package_id) {
                var Patient_ID = $('#txtMRNo').val();
                localStorage.IsPackage = 1;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/LoadITemsForPackage",
                    data: "{'PatientID':" + Patient_ID + ",'item_id':" + Package_id + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (data) {
                        debugger;
                        var data = JSON.parse(data.d);
                        var RemainDiscAmt = data.Remaining_Amount;
                        var datas = data.Total_Disc_Amt;
                        if (datas == "0.0000") {

                            localStorage.OnlyPercentage = 1;
                            if (RemainDiscAmt != "0.0000") {
                                localStorage.OnlyPercentage = 0;
                            }

                        }
                        else {
                            localStorage.OnlyPercentage = 0;
                        }

                        if (data.Disc == "0.0000") {
                            localStorage.IsZero_Amt = 1;


                        }


                        if (data.Disc == "There is no row at position 0.") {
                            localStorage.Disc = "0.00";
                        }
                        else {

                            localStorage.Disc = data.Disc;
                            localStorage.Total_Disc_Amt = data.Total_Disc_Amt;
                            Item_Discount = data.Total_Disc_Amt;



                        }
                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            var validate = null;
            function LoadITemsForDiscount(item_id) {
                validate = null;
                localStorage.OnlyPercentage = 0;
                localStorage.IsZero_Amt = 0;
                localStorage.IsZero_Procedure = 0;
                localStorage.IsBothAmtand = 0;
                var Patient_ID = $('#txtMRNo').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/LoadITemsForDiscount",
                    data: "{'PatientID':" + Patient_ID + ",'item_id':" + item_id + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: false,
                    success: function (data) {
                        debugger;
                        var RemainDiscAmt = 0;
                        localStorage.OnlyPercentage = 0;
                        localStorage.IsZero_Amt = 0;
                        localStorage.IsZero_Procedure = 0;
                        debugger;
                        var data = JSON.parse(data.d);
                        if (data != null) {
                            localStorage.IsHospitalServices = data.Hospital_Services;
                            var datas = data.Total_Disc_Amt;
                            validate = datas;
                            var data_pro = data.Total_Disc_Amt_Pro;
                            RemainDiscAmt = data.Remaining_Amount;

                            datas = datas - RemainDiscAmt;
                            if (datas == "0.0000") {


                                localStorage.OnlyPercentage = 1;
                                if (RemainDiscAmt != "0.0000") {
                                    localStorage.OnlyPercentage = 0;
                                }

                            }

                            else {
                                localStorage.OnlyPercentage = 0;
                            }
                            if (data_pro == "0.0000") {

                            }

                            if (data.Disc == "0.0000") {
                                localStorage.IsZero_Amt = 1;


                            }
                            if (data.Disc_Pro == "0.0000") {

                                localStorage.IsZero_Procedure = 1;

                            }

                            if (data.Disc == "There is no row at position 0." || data.Disc_Pro == "There is no row at position 0.") {
                                localStorage.Disc = "0.00";
                            }
                            else {

                                localStorage.Disc = data.Disc;
                                localStorage.Total_Disc_Amt = data.Total_Disc_Amt;
                                Item_Discount = data.Total_Disc_Amt;
                                localStorage.Procedure_types = data.Procedure_types;
                                if (data.Procedure_types == null && data.Hospital_Services == false) localStorage.Procedure_types = true;
                                localStorage.Disc_Pro = data.Disc_Pro;
                                localStorage.Total_Disc_Amt_pro = data.Total_Disc_Amt_Pro;
                                localStorage.isService = data.Services;

                            }
                        }

                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            debugger;
            function tokenInputs(textboxID, tblName, OnAddFun) {
                debugger;
                $('#' + textboxID).tokenInput("../../json.aspx?Table=" + tblName,
                    {
                        tokenLimit: 1,
                        onAdd:
                            function (item) {
                                try {
                                    debugger;
                                    if (tblName == 'Patients') {
                                        debugger;
                                        $("#hdfPatient_ID").val(item.id);


                                        LoadPatientDetails();

                                        GetPatientIdfromOPd();
                                    }
                                    else if (tblName == 'INV_ItemsForBilling') {

                                        localStorage.SelectedItemID = item.id;
                                        localStorage.SelectedItemType = item.Type;
                                        localStorage.SelectedItemName = item.name;
                                        localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);
                                        LoadITemsForDiscount(item.id);



                                        $('#txtAddPackage').tokenInput("clear");
                                    }
                                    else if (tblName == 'Inv_Items_Panel' || tblName.includes('Inv_Items_Panel')) {
                                        localStorage.SelectedItemID = item.id;
                                        localStorage.SelectedItemType = item.Type;
                                        localStorage.SelectedItemName = item.name;
                                        localStorage.SelectedItemAmount = (item.Amount.length == 0 ? 0 : item.Amount);
                                        LoadITemsForDiscount(item.id);
                                        $('#txtAddPackage').tokenInput("clear");
                                    }
                                    else if (tblName == 'PacakgesForBilling') {
                                        localStorage.SelectedPackageID = item.id;
                                        localStorage.SelectedPackageType = item.Type;
                                        localStorage.SelectedPackageName = item.name;
                                        LoadITemsForPackage(item.id);
                                        $('#txtAddService').tokenInput("clear");

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
            var Opd_Ids;
            debugger;
            function GetPatientIdfromOPd() {
                debugger;
                var Patient_ID = $('#hdfPatient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetOpdId",
                    data: "{'Patient_ID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (msg) {
                        debugger;
                        var data = msg.d ? JSON.parse(msg.d) : null;
                        debugger;
                        Opd_Ids = data && data.Patient_ID ? data.Patient_ID : 0;
                        $('#hdnOpd_id').val(Opd_Ids);
                    }
                });
            }
            debugger;
            var userupdate;
            function Deletebillsupdate() {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/DeleteBillRights",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        userupdate = data.d;

                        if (userupdate == false || userupdate == "False" || userupdate == 'False') {

                        }
                    },
                    failure: function () {

                        alert(bi);
                    }
                });


            }
            debugger;

            function updates() {
                if (userupdate == false || userupdate == "False" || userupdate == 'False') {
                    $('a[name="btndelBill"]').hide();
                    debugger;

                    return true;
                }
            }

            debugger;
            function FillTokenInputForMRNo() {
                debugger;
                var PatientID = $('#hdfPatient_ID').val();
                if (PatientID == '') {
                    tokenInputs('txtMRNo', 'Patients');
                }
                else {
                    var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientID);
                    $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });
                }
            }
            debugger;
            function FillTokenInputForMRNoByreg() {
                debugger;
                var PatientID = $('#hdfPatient_ID').val();
                if (PatientID == '') {
                    tokenInputs('txtMRNo', 'Patients');
                }
                else {
                    var tokendata = httpGet("../../json.aspx?Table=PatientsFetchByID&q=" + PatientID);
                    $('#txtMRNo').tokenInput("add", { id: JSON.parse(tokendata)[0].id, name: JSON.parse(tokendata)[0].name, readonly: true });
                    LoadPatientDetails();
                }
            } debugger;
            function LoadPatientDetails() {
                debugger;
                var Patient_ID = $('#hdfPatient_ID').val();
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetPatientDetails",
                    data: "{'PatientID':" + Patient_ID + "}",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: OnSuccess,
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
            debugger;
            var IsDiscountAvaible = "";
            var departmentpat;
            var PatientID;
            var pat_id;
            function OnSuccess(data) {
                debugger;

                IsDiscountAvaible = "";
                var roomward = "";
                if (data.d != '') {
                    departmentpat = data.d.Patient_Discount_Type;
                    if (data.d.Ward_Name != null) {
                        roomward = data.d.Ward_Name + ',  ' + data.d.Bed_No
                    }
                    else if (data.d.Room_Name != null) {
                        roomward = data.d.Room_Name + ',  ' + data.d.Room_No
                    }
                    else {
                        $('#lblWardRoom').hide();
                    }

                    if (data.d.Patient_Discount_Type == null)
                        data.d.Patient_Discount_Type = "";
                    var mydate = new Date(Date.parse(data.d.Entry_Date));
                    var dateR = mydate.toLocaleDateString();
                    var isDisharge = ReplaceNullWith_Space(data.d.Discharge);
                    var isInpatient = ReplaceNullWith_Space(data.d.isInpatient);
                    is_Patient_Temp = isInpatient;
                    IsDiscountAvaible = data.d.IsDisountAvailable;
                    $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                    $('#lblAgeYears').text(ReplaceNullWith_Space(data.d.Age));
                    $('#lblGender').text(ReplaceNullWith_Space(data.d.Gender));
                    $('#lblRegDate').text(dateR);
                    $('#lblAddress').text(ReplaceNullWith_Space(data.d.Address));
                    $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                    $('#txtadvance_amount').val(data.d.advance_amount);
                    $('#txtprevious_paid').val(data.d.paid_amount);
                    $('#txtprevious_Amount').val(data.d.PreviousTotalAmount);
                    $('#lblDepartment').val(data.d.Department);
                    $('#txt_balance').val(data.d.Balance);
                    $('#txtMaindepartment').val(data.d.MainDepartment).trigger('change');
                   // $('#ddlReffered_By').val(ReplaceNullWith_Space(data.d.refferedoc)).trigger('change');
                    //$('#ddlReffered_By').attr('disabled', true);
                    var doc = data.d.refferedoc;
                    var hasDoctor = (doc && doc != "" && doc != "There is no row at position 0.");
                    $('#ddlReffered_By').val(doc).trigger('change').prop('disabled', hasDoctor);
                    $('#txtadmitdate').val(data.d.Admission_Date);
                    $('#txtdischargedate').val(data.d.Discharge_On);
                    $('#wardtype').val(data.d.Ward_Name);
                    $('#bedno').val(data.d.Bed_No);




                    var Packtypes = data.d.Package_Type
                    var Packnames = data.d.Package_Name

                    if (Packtypes == "There is no row at position 0.") {
                        Packtypes = ""
                    }
                    if (Packnames == "There is no row at position 0.") {
                        Packnames = ""
                    }
                    setTimeout(function () {
                        $('#ddlpanel').val(data.d.IPD_Panel_ID).trigger('change');
                    }, 1000)
                    $('#PackageType').val(Packtypes);
                    $('#PackageName').val(Packnames);
                    $('#hdn_PatienttypeId').val(data.d.Patient_Type_id);
                    $('#hdn_InPatienttype').val(data.d.In_Patient_Type);
                    $('#hdn_pkgtype').val(data.d.pkg_type);
                    $('#hdn_pkgname').val(data.d.pkg_name);
                    var a = data.opdid;
                    debugger;
                    var b = data.pat_id;
                    pat_id = data.d.pat_id;
                    PatientID = data.d.opdid;
                    debugger;
                    var Patient_ID = $('#hdfPatient_ID').val();




                    var isadd = '<%= Request.QueryString["isAdd"]%>';
                    var PackType = data.d.pkg_type;
                    var packname = data.d.pkg_name;
                    if (PackType == "There is no row at position 0.") {
                        PackType = "Null"
                    }

                    if (packname == "There is no row at position 0.") {
                        packname = "Null";
                    }
                    var in_Pat = data.d.In_Patient_ID;
                    var Request_Discharge = data.d.Request_Discharge;

                    var id = '<%= Request.QueryString["Bill_ID"]%>';

                    if (data.d.Patient_Type == null && data.d.In_Patient_Type == null) {

                        $('#lblPatientCategory').val('General');

                    }
                    else if (data.d.In_Patient_Type != null) {
                        $('#lblPatientCategory').val(ReplaceNullWith_Space(data.d.In_Patient_Type));
                    }
                    else {
                        $('#lblPatientCategory').val(ReplaceNullWith_Space(data.d.Patient_Type));
                    }
                    debugger;

                    if (id == '') {
                        if (Request_Discharge == true) {
                            debugger;
                            $("#hdn_finalBill").val("true");
                            AddPackage();
                            FetchAllPreviousBill(in_Pat);



                        }
                        else if (Request_Discharge != true)
                        {
                            $("#hdn_finalBill").val("false");
                        }
                        else {
                            if (id == '') {
                                var urlParams = new URLSearchParams(window.location.search);
                                var appointmentId = urlParams.get('Appointment_ID');
                                if (!appointmentId || appointmentId == '0' || appointmentId == '') {
                                    FetchRecommendedDetails();
                                }
                            }
                        }
                    }
                   
                    debugger;
                    var lblIn_Patient_Category = $('#lblPatientDiscountType').text();
                    if ((lblPatientCategory == "Insurance Company") || (lblIn_Patient_Category == "Insurance Company")) {
                        var opd_Panel_company = $('#lblOPDpnl').text();
                        var ipd_Panel_company = $('#lblIPDpnl').text();
                        var tokeinpt = $('#token-input-txtAddService').val();
                        if (typeof tokeinpt === 'undefined') {
                            if (opd_Panel_company == "Private Patient" || ipd_Panel_company == "Private Patient") {
                            }
                            else if (opd_Panel_company != "Private Patient" && opd_Panel_company != "" && opd_Panel_company != "Sehat Sahulat Card" && (lblIn_Patient_Category != "General")) {
                                var company_id = 0;
                                if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                                if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || typeof localStorage.IPD_PAnel_ID === 'undefined')
                                    company_id = localStorage.OPD_Panel_ID;
                                if (localStorage.OPD_Panel_ID != "null" && localStorage.IPD_PAnel_ID != "null") company_id = localStorage.IPD_PAnel_ID;
                                tokenInputs('txtAddService', 'Inv_Items_Panel&q=' + company_id + '&Panel=' + company_id);
                            }
                            else if ((lblPatientCategory == "General") && (lblIn_Patient_Category == "Insurance Company")) {
                                var company_id = 0;
                                if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                                if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || typeof localStorage.IPD_PAnel_ID === 'undefined')
                                    company_id = localStorage.OPD_Panel_ID;
                                if (localStorage.OPD_Panel_ID != "null" && localStorage.IPD_PAnel_ID != "null") company_id = localStorage.IPD_PAnel_ID;
                                tokenInputs('txtAddService', 'Inv_Items_Panel&q=' + company_id + '&Panel=' + company_id);
                            }
                            else if ((lblPatientCategory == "Private") && (lblIn_Patient_Category == "Insurance Company")) {
                                var company_id = 0;
                                if (localStorage.OPD_Panel_ID == "null" || localStorage.OPD_Panel_ID == null || typeof localStorage.OPD_Panel_ID === 'undefined') company_id = localStorage.IPD_PAnel_ID;
                                if (localStorage.IPD_PAnel_ID == "null" || localStorage.IPD_PAnel_ID == null || typeof localStorage.IPD_PAnel_ID === 'undefined')
                                    company_id = localStorage.OPD_Panel_ID;
                                if (localStorage.OPD_Panel_ID != "null" && localStorage.IPD_PAnel_ID != "null") company_id = localStorage.IPD_PAnel_ID;
                                tokenInputs('txtAddService', 'Inv_Items_Panel&q=' + company_id + '&Panel=' + company_id);
                            }
                            else if ((lblPatientCategory == "Insurance Company") && (lblIn_Patient_Category == "General")) {
                                var tokeinpt = $('#token-input-txtAddService').val();
                                if (typeof tokeinpt === 'undefined') {
                                    tokenInputs('txtAddService', 'INV_ItemsForBilling');
                                }
                            }
                        }
                    }

                    else if (((lblPatientCategory == "Private" || lblIn_Patient_Category == "Private")) && (lblIn_Patient_Category != "General")) {
                        var tokeinpt = $('#token-input-txtAddService').val();
                        if (typeof tokeinpt === 'undefined') {
                            tokenInputs('txtAddService', 'Inv_Items_Panel_Private');
                        }
                    }
                    else if ((lblPatientCategory == "Private") && (lblIn_Patient_Category == "General")) {
                        var tokeinpt = $('#token-input-txtAddService').val();
                        if (typeof tokeinpt === 'undefined') {
                            tokenInputs('txtAddService', 'INV_ItemsForBilling');
                        }
                    }

                    else if ((lblPatientCategory == "Sehat Sahulat Card") || (lblIn_Patient_Category == "Sehat Sahulat Card")) {
                        if (lblIn_Patient_Category == "Sehat Sahulat Card") {
                            var tokeinpt = $('#token-input-txtAddService').val();
                            if (typeof tokeinpt === 'undefined') {
                                tokenInputs('txtAddService', 'Inv_Items_Panel_Sehat_Sahulat');
                            }
                        }
                        else if (lblPatientCategory == "Sehat Sahulat Card" && lblIn_Patient_Category == "") {
                            var tokeinpt = $('#token-input-txtAddService').val();
                            if (typeof tokeinpt === 'undefined') {
                                tokenInputs('txtAddService', 'Inv_Items_Panel_Sehat_Sahulat');
                            }
                        }

                        else {
                            var tokeinpt = $('#token-input-txtAddService').val();
                            if (typeof tokeinpt === 'undefined') {
                                tokenInputs('txtAddService', 'INV_ItemsForBilling');
                            }
                        }
                    }
                    else {
                        var tokeinpt = $('#token-input-txtAddService').val();
                        if (typeof tokeinpt === 'undefined') {
                            tokenInputs('txtAddService', 'INV_ItemsForBilling');
                        }
                    }

                    $('#lblWardRoom').text(roomward);
                    checkIsExistinOutPatient();
                }
                var id = '<%= Request.QueryString["Bill_ID"]%>';
                if (id != "") {
                    if (IPDDiscount != "") {
                        $('#lblPatientDiscountType').text(IPDDiscount);
                    }
                    else {

                    }
                }


                var urlParams = new URLSearchParams(window.location.search);
                if (urlParams.get('isAdd') === 'true' && urlParams.get('Appointment_ID')) {

                }

                if (appointmentId && appointmentId != '0' && appointmentId != '') {
                    setTimeout(function () {
                        LoadDermaAppointmentServices(parseInt(appointmentId));
                    }, 1000);
                }

            }


            function LoadBillbypatid(pat_id) {
                debugger;
                $("#btnSavePrint").hide();
                PageMethods.loadbillbypatient_id(pat_id, function (resp) {
                    JSON.parse(resp);
                    debugger;
                    localStorage.clear();
                    var date1 = new Date();
                    var date2 = new Date($('#txtBillDate').val());
                    var Difference_In_Time = date2.getTime() - date1.getTime();
                    $('#lblDepartment').text('IPD');
                    $('#ddlpat_dep_main').val('008');

                    var Difference_In_Days = Difference_In_Time / (1000 * 3600 * 24);
                    var final = Math.round(Math.abs(Difference_In_Days));
                    //   alert(final);
                    if (final == 1) {
                        final = 0;
                    }
                    var data = (JSON.parse(resp));

                    ItmID = data[0].Item_ID;
                    itmName = data[0].Item_Name;
                    tyebill = data[0].BillType;



                    var assign_doc_id = data;
                    var rows = '';
                    var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                    var Description = '';
                    var hidshow = '';
                    $.each(data, function (key, value) {
                        debugger;


                        var Type = $("#lblPatientDiscountType").text();
                        var ward = $('#lblsetWardType').text();
                        var room = $('#lblserRoomNo').text();
                        if (Type == "Private") {
                            hidshow = "pointer-events:default;"
                        }
                        else {

                            hidshow = "pointer-events:none;"
                        }



                        debugger;
                        var username = '<%= AppConfig.UserName%>';



                        if (typeof value.ParentTrans_Name === 'undefined') value.ParentTrans_Name = "";
                        var ServiceDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Service_Date.substring(6, 19))))
                        if (value.IsShare.includes("There is no row at position 0.")) value.IsShare = false;
                        if (value.Procedure_Required.includes("There is no row at position 0.")) value.Procedure_Required = false;
                        if (value.IsOpenBill.includes("There is no row at position 0.")) value.IsOpenBill = false;
                        debugger;
                        rows = '<tr>'
                            + '<td style="text-align:center;">' + (parseInt(rowIndex) + 1) + '</td>'
                            + '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)" style="' + hidshow + '"><i class="fa fa-trash-o" style="font-size:17px"></i></a></td>'
                            + '<td style="text-align:left;">'
                            + '<input type="hidden" name="hdnParentTrans_ID" value="' + value.ParentTrans_ID + '" />'
                            + '<input type="hidden" name="hdnParentTrans_Name" value="' + value.ParentTrans_Name + '" />'
                            + '<input type="hidden" name="hdnParentTrans_Type" value="' + value.ParentTrans_Type + '" />'
                            + '<input type="hidden" name="hdnCategory_ID" value="' + value.Category_ID + '" />'
                            + '<input type="hidden" name="hdnItemID" value="' + value.Item_ID + '" />'
                            + '<input type="hidden" name="hdnItemName" value="' + value.Item_Name + '" />'
                            + '<input type="hidden" name="Main_Department" value="' + value.Test_Main_Department + '" />'
                            + '<input type="hidden" name="hdnItemType" value="' + value.Item_Type + '" />'
                            + '<input type="hidden" name="hdnDisPer" value="' + parseFloat(value.Discount_Percentage.toFixed(6)) + '" />'
                            + '<input type="hidden" name="hdnDisAmount" value="' + parseFloat(value.Discount_Amount.toFixed(6)) + '" />'
                            + '<input type="hidden" name="hdnNet_Amount" value="' + parseFloat(value.Net_Amount.toFixed(6)) + '" />'
                            + '<input type="hidden" name="hdnRecommendedByDoctor" value="' + value.RecommendedByDoctor + '" />'
                            + value.Item_Name
                            + '</td>'
                            + '<td>' + (value.Remarks || '') + '</td>'
                            + '<td>'
                            + '<input class="height_height" type="text" name="txtQty" value="' + value.Qty + '" style="width: 45px !important;" onkeyup="CulculateAmonutWithQty(this)" />'
                            + '<input type="hidden" name="txtActualAmount" value="' + value.Amount + '" />'
                            + '</td>'
                            + '<td style="text-align:right;font-weight:bold;">' + value.Amount + '</td>'
                            + '<td class="orderchange">'
                            + '<input class="height_height" type="text" name="DisPer" value="' + parseFloat(value.Discount_Percentage.toFixed(2)) + '" style="width: 37px !important;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')" />'
                            + '</td>'
                            + '<td class="orderchangeDiscount">'
                            + '<input class="height_height" type="text" name="DisAmount" value="' + parseFloat(value.Discount_Amount.toFixed(2)) + '" style="width: 75px !important;" onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')" />'
                            + '</td>'
                            + '<td style="text-align:right;font-weight:bold;">' + parseFloat(value.Net_Amount.toFixed(0)) + '</td>'
                            + '<td>'
                            + '<input type="text" style="width: 75px !important;" disabled name="DocShare" class="height_height" value="' + value.Doctor_Share.toFixed(2) + '" id="DocShare' + (rowIndex + 1) + '" onkeyup="calculateDoctorShare()" />'
                            + '</td>'
                            + '<td>'
                            + '<input type="text" class="height_height" style="width: 75px !important;" disabled name="HocShare" value="' + value.Hospital_Share.toFixed(2) + '" id="HocShare' + (rowIndex + 1) + '" onkeyup="calculateDoctorShare()" />'
                            + '</td>'
                            + '<td>'
                            + '<select id="ddldoctor' + rowIndex + '" name="ddlDoctor" class="ddlDoctor" onchange="GetDocAgreementValuess(this)">' + doctors + '</select>'
                            + '</td>'
                            + '<td style="display:none;">'
                            + '<input class="height_height" disabled type="text" name="BillDetailID" value="' + value.Bill_Details_ID + '" />'
                            + '</td>'
                            + '</tr>';




                        $('#tblDetails tbody').append(rows);
                        var isIPD = $("#lblPatientDiscountType").text();

                        $('#tblDetails tr').find('th:eq(9)').show();
                        $('#tblDetails tr').find('th:eq(10)').show();
                        $('#tblDetails tbody').find('tr:eq(' + parseInt(parseInt(rowIndex)) + ')').find('td:eq(9)').show();
                        $('#tblDetails tbody').find('tr:eq(' + parseInt(parseInt(rowIndex)) + ')').find('td:eq(10)').show();
                        $('#ddldoctor' + key + '').val(data[key].Doctor_Id);
                        $('#ddldoctor' + key + '').select2();
                        if (value.Item_Type == "Test") {
                            $('#tblDetails tbody').find('tr:eq(' + key + ')').find('input[name="txtDoctorShare"]').attr('disabled', false);
                            $('#tblDetails tbody').find('tr:eq(' + key + ')').find('input[name="txtHospitalShare"]').attr('disabled', false);
                        }


                        setTimeout(function () {
                            $("#tblDetails tr").each(function () {


                                var ITem_Type = $(this).find('input[name="hdnItemType"]').val();
                                var isOpenBill = $(this).find('input[name="hdnOpenBill"]').val();
                                var IsOpenShare = $(this).find('input[name="hdnOpenShare"]').val();
                                var isProcedure = $(this).find('input[name="hdnprocRequird"]').val();
                                var test_M_Department = $(this).find('input[name="Main_Department"]').val();
                                if (ITem_Type == "Item" || ITem_Type == "Service") {
                                    if (isOpenBill == "True") {

                                        if (IsOpenShare == "True" && isProcedure == "True") {

                                            $(this).find("td:eq(5)").attr('contenteditable', 'True');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', true);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', true);
                                        }
                                        if (isProcedure == "True" && IsOpenShare == "False") {
                                            $(this).find("td:eq(5)").attr('contenteditable', 'True');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', false);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', false);

                                        }
                                        if (IsOpenShare == "False" && isProcedure == "False") {
                                            $(this).find("td:eq(5)").attr('contenteditable', 'True');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', true);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', true);

                                            $(this).find('select[name="ddlDoctor"]').show();
                                            $(this).find('select[name="ddlDoctor"]').next(".select2-container").show();
                                            $(this).find('input[name="txtDoctorShare"]').show();
                                            $(this).find('input[name="txtHospitalShare"]').show();
                                        }

                                    }
                                    else {
                                        if (IsOpenShare == "True" && isProcedure == "True") {

                                            $(this).find("td:eq(5)").attr('contenteditable', 'False');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', true);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', true);
                                        }
                                        if (isProcedure == "True" && IsOpenShare == "False") {
                                            $(this).find("td:eq(5)").attr('contenteditable', 'False');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', false);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', false);

                                        }
                                        if (IsOpenShare == "False" && isProcedure == "False") {

                                            $(this).find("td:eq(5)").attr('contenteditable', 'False');
                                            $(this).find('input[name="txtDoctorShare"]').attr('disabled', true);
                                            $(this).find('input[name="txtHospitalShare"]').attr('disabled', true);
                                            $(this).find('select[name="ddlDoctor"]').show();
                                            $(this).find('select[name="ddlDoctor"]').next(".select2-container").hide();

                                        }
                                    }
                                }

                                else if (ITem_Type == "Test") {

                                    if (test_M_Department != "002") {
                                        $(this).find('select[name="ddlDoctor"]').show();
                                        $(this).find('select[name="ddlDoctor"]').next(".select2-container").show();
                                        $(this).find('input[name="txtDoctorShare"]').show();
                                        $(this).find('input[name="txtHospitalShare"]').show();
                                    }
                                }

                            });
                            setTimeout(function () {
                                if ($("#tblDetails tbody tr").length > 0 && $("#ctl00_MainContent_ddlUserDepartment").val() != "0") {
                                    $("#ctl00_MainContent_ddlBillType").attr("disabled", "true");

                                    $("#ctl00_MainContent_ddlUserDepartment").attr("disabled", false);

                                }
                            }, 300);


                        }, 2000);

                        setTimeout(function () {

                            CalculateSummarieDiscountPerWise(rowIndex);
                        }, 2000)

                        rowIndex++;
                    });
                    $("#tblDetails tr:gt(0)").each(function (key, value) {

                        var sixitems = ['102', '125', '103', '86'];
                        //, '103', '86'];
                        //102, 125,103,86

                        var item_id = $(this).find('input[name="hdnItemID"]').val();
                        var qty = $(this).find('input[name="txtQty"]').val();
                        var item_name = $(this).find('input[name="hdnItemName"]').val();
                        if (item_id == "102" || item_id == "125" || item_id == "103" || item_id == "86" || item_id == "112" || item_id == "113") {
                            if (Day_Occupied == null) {

                            }
                            else {

                            }
                        }

                    });

                    $('#btnSave').val('Update');
                },
                    function (error) {
                        alert(error.get_message());
                    })
            }

            function OpenModal() {
                debugger;
                $('#PatientsSearchModel').modal({
                    backdrop: 'static'

                });
                FillPatientsList();

                $('#srchpat').text("Search Your Patients:");
                $('#txtSearch').unmask();
                $('#ClosePatientsSearchModel').show();


            }

            function FillPatientsList() {
                debugger;
                $('#tblPatientsResult tbody').empty();

                var SearchString = '';

                PageMethods.AddPatient(SearchString, OnFilterPatients, OnFailPatients);
            }

            function SearchPatients() {
                var text = $('#txtPatientSearch').val();
                PageMethods.AddPatient(text, OnFilterPatients, OnFailPatients);
            }


            function OnFilterPatients(data) {

                ClearPatientResults();

                for (var i = 0; i < data.length; i++) {
                    AddPatientsResult(data[i].Reg_Patient_ID, data[i].Patient_No, data[i].Full_Name, data[i].NIC, data[i].Mobile1, data[i].Father_Name);
                }
            }
            debugger;
            function SavePatient() {
                debugger;
                $('#SavePatient_Data').attr('disabled', true);
                var Prefix_PatientName = $('#ddl_name').val();
                var PatientName = $('#txt_name').val();
                var PatientID = $('#hdfPatient_ID').val();


                var Full_Name = Prefix_PatientName + PatientName;
                debugger;
                var RelationType = $('#ddlRelation').val();
                var Relation = $('#txt_relation').val();
                var Gender = $('#ddl_Gender').val();

                var Mobile = $('#txt_mobile').val();
                var PreFix_DOB = $('#ddl_dob').val();
                var Age = $('#txt_dob').val();
                var Date_Of_Birth = $('#txtAge_yearss').val();
                var CNIC = $('#txt_cnic').val();
                var Address = $('#txt_Address').val();
                var martail_status = $('#ddl_status').val();
                if ((PatientName == "" || Mobile == "")) {


                    alert("Please Enter compulsory Fields");
                    $('#SavePatient_Data').attr('disabled', false);
                    return;
                    // }
                }


                var data = JSON.stringify({
                    "Full_Name": Full_Name,
                    "RelationType": RelationType,
                    "Relation": Relation,
                    "Gender": Gender,
                    "Mobile": Mobile,
                    "Date_Of_Birth": Date_Of_Birth,
                    "CNIC": CNIC,
                    "Address": Address,
                    "PatientID": PatientID,
                    "martail_status": martail_status,
                    "Age": Age,

                });
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/SavePatientDetail",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        debugger;
                        var Reg_Patient_ID = data.d;

                        alert('Your Record Save and Load Successfully');
                        $('#PatientModel').modal('hide');

                        //ApproveRegPatients(Reg_Patient_ID)
                        AddPatientDetail(Reg_Patient_ID);

                    },
                    error: function (response) {
                        alert("Error");
                    }
                });
            }

            function ApproveRegPatients(pat_id) {
                PageMethods.ApproveRegpatient(pat_id, function (Tests) {
                    debugger
                    var message = JSON.parse(Tests);
                    if (message[0].Message != null || message[0].Message != "") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: message[0].Message,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                });
            }
            function ClearPatientResults() {
                while (tblPatientsResult.rows.length > 1) {
                    tblPatientsResult.deleteRow(1);
                }
            }
            function clearPatient() {

                $('#txt_name').val("");
                $('#txt_relation').val("");
                $('#txt_mobile').val("");
                $('#txt_dob').val("");
                $('#txt_cnic').val("");
                $('#txt_Address').val('');
                $('#updatePatient_Data').hide();
                $('#RevistPat').hide();
            }
            debugger;
            function fillmrnos() {
                debugger;
                var data = {};

                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx.aspx/Getmr_no",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        debugger;
                        var max_mr = data.d;
                        $('#txt_Mrno').val('New');
                    },
                    error: function (xhr, status, error) {
                        console.error("AJAX request failed:", status, error);
                    }
                });
            }
            function OnFailPatients(exc) {
                alert(exc.get_message());
            }
            function AddNewPatient() {
                debugger;
                $('#ddl_pnl_cpy').next(".select2-container").hide();

                clearPatient();
                $('#hdfPatient_ID').val('(New)');

                $('#PatientModel').modal({
                    backdrop: 'static'
                });
                $("#ddl_name").focus();

            }

            function AddPatientsResult(Reg_Patient_ID, Patient_No, Full_Name, NIC, Mobile1, Father_Name) {
                debugger;
                tblLength = tblPatientsResult.rows.length;

                var row = iPatientsBody.insertRow(-1);
                var cell;

                cell = row.insertCell(-1);
                cell.innerHTML = '<span spnPatID' + tblLength + '>' + Reg_Patient_ID + '</span>';
                cell.className = "hide";

                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Patient_No + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Father_Name + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + NIC + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Mobile1 + '</span>';
                cell = row.insertCell(-1);
                var actions = ''
                actions += '<a style="color:#EFA63E;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=AddPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-plus-circle"></i></a>&nbsp;|&nbsp;&nbsp;';
                actions += '<a style="color:#FDC303;font-size:20px;padding:8px;border-radius:5px;text-decoration:none;" href="#" onclick=EditPatientDetail(' + Reg_Patient_ID + ')><i class="fa fa-pencil-square-o"></i></a>';
                cell.innerHTML = actions;
            }
            function addfunc() {
                debugger;

                var maskedValue = $('#txtSearch').val();


                var unmaskedValue = maskedValue.replace(/_/g, '');
                var Ph_sNOs = unmaskedValue.length;


                if (Ph_sNOs === 13) {
                    $('#addNewbtn').attr("disabled", false);
                    AddNewPatient();
                }
                else {
                    alert("Please Enter Complete Mobile Number First");
                    return;
                }




                debugger;

                $('#ClosePatientsSearchModel').click();
                fillmrnos();
                setTimeout(function () {
                    $('#txt_mobile').val(unmaskedValue);
                }, 100);
                $('#txt_name').focus();
            }
            var isAdd = false;
            function AddPatientDetail(Reg_Patient_ID) {
                debugger;
                try {
                    isAdd = true;

                    window.location.href = "BillingProcess.aspx?Reg_ID=" + Reg_Patient_ID + "&isAdd=" + isAdd;

                } catch (err) {
                    alert(err.message);
                }

            }

            function openQueue() {
                debugger;
                fillPendingPatientsLists();
                $('#queueModal').modal('show');
            }
            function fillPendingPatientsLists() {
                PageMethods.PendingPatients(function (data) {
                    debugger;
                    var parsedData = JSON.parse(data);
                    let query = parsedData.query;
                    let ipd = parsedData.ipd;
                    let allPendings = query.concat(ipd);

                    var rows = '';
                    $.each(allPendings, function (key, value) {
                        debugger;
                        var TrnsDate = new Date(parseInt(value.Created_Time.substr(6)));
                        var retdate = moment(TrnsDate).format('LLLL');
                        var status = '';
                        rows += '<tr> <td>' + value.mr_no_sequence + '</td> ' + '<td>' + value.Full_Name + '</td> ' + '<td>' + value.Age_years + '</td> ' + '<td>' + retdate + '</td> ' + ' <td> <a href="javascript:void(0)" onclick=AddPatientDetail(' + value.Actual_Patient_ID + ')><i class="fa fa-plus-circle fa-2x" ></i></a> </td> </tr>';
                    });
                    debugger;
                    $('#tblPendingPatients tbody').html(rows);


                    $(".se-pre-con").fadeOut("slow");

                }, function (exec) { })
            }
            function fillmartial() {
                var options = '<option value="0">Please Select</option>';
                PageMethods.GetMartailStatus(function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddl_status').html(options);
                });
                return options;
            }


            function fillCasher() {
                var options;

                $.ajax({
                    url: 'BillingProcess.aspx/GetUserAccount',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        var data = response.d ? JSON.parse(response.d) : response;
                        $.each(data, function (key, value) {
                            options += '<option value="' + value.cashier + '">' + value.Cashier_text + '</option>';
                        });
                        $('#ddlcasher').html(options);


                    },
                    error: function (xhr, status, error) {
                        console.error('Error fetching area data:', error);
                    }
                });

                return options;
            }


            function fillPanel() {
                var options = '<option value="0">Please Select</option>';

                $.ajax({
                    url: 'BillingProcess.aspx/GetPanel',
                    type: 'POST',
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        var data = response.d ? JSON.parse(response.d) : response;
                        $.each(data, function (key, value) {
                            options += '<option value="' + value.Panel_ID + '">' + value.Company_Name + '</option>';
                        });
                        $('#ddlpanel').html(options);
                        $('#ddlpanel').select2();
                    }
                });

                return options;
            }
            function fillgender() {
                var options = '<option value="0">Please Select</option>';
                PageMethods.GetGender(function (data) {
                    $.each(JSON.parse(data), function (key, value) {
                        options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                    });
                    $('#ddl_Gender').html(options);
                });
                return options;
            }
            debugger;
            function EditPatientDetail(id) {

                var Patient_ID = $('#hdfPatient_ID').val();
                $('#CloseSearchModel').click(function () {
                    window.location.href = "BillingProcess.aspx";
                });
                $('#CloseSearchModels').click();
                $("#SavePatient_Data").hide();
                $("#PatientsSearchModel").hide();
                $('#updatePatient_Data').show();
                $("#SavePatient_Data").hide();
                $('#RevistPat').show();
                $('#updatePatient_Data').show();
                $('#PatientModel').modal({
                    backdrop: 'static'
                });

                var ajaxFn = function () {
                    $.ajax({
                        type: "POST",
                        url: "BillingProcess.aspx/GetEditPatientDetails",
                        data: "{'Reg_Patient_ID':" + id + "}",
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: OnSuccessEdit,
                        failure: function (response) {
                            alert(response.d);
                        }
                    });

                }
                setTimeout(ajaxFn, 3000);



            }
            var Alloweditrate;
            function AllowRateEdit() {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/AllowEditRates",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        Alloweditrate = data.d;

                        if (Alloweditrate == "true") {

                            $('#bomSection').show();
                        }
                        else {
                            $('#bomSection').hide();
                        }

                    },
                    failure: function () {
                        alert("Error");
                    }
                });


            }


            var editrights;
            function AllowReceipeRights() {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/CheckRecipeRights",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        editrights = data.d;

                        if (editrights == "true") {

                            $('#bomSection').show();
                        }
                        else {
                            $('#bomSection').hide();
                        }

                    },
                    failure: function () {
                        alert("Error");
                    }
                });


            }
            var inPatientID;
            var Discharged;
            debugger;
            function OnSuccessEdit(data) {
                debugger;
                if (data.d != '') {
                    debugger;

                    inPatientID = data.d.Inpat;
                    Discharged = data.d.Discharged;
                    $("#txt_Mrno").val(data.d.Mr_No);
                    $("#txt_name").val(data.d.Name);
                    $("#ddl_Gender").val(data.d.Gender).change();
                    var newValue = data.d.Age.replace('Y', '');

                    $("#txt_dob").val(newValue);
                    $("#ddl_status").val(data.d.MaritalStatus);
                    $("#ddl_ctgry").val(data.d.Patient_Type).change();
                    $("#ddl_Doc").val(data.d.DocID).change();
                    $('#ddl_pnl_cpy').hide();

                    if (data.d.DOB != null) {
                        stDate = new Date(parseInt(data.d.DOB.substr(6)));
                        stDate = moment(stDate).format('L');
                        $('#txtAge_yearss').val(stDate);
                    }

                    $("#ddltest_main_dpt").val(data.d.department).change();

                    $('#ddlRelation').val(data.d.Relation).trigger('change');
                    $('#ddl_name').val(data.d.Title).trigger('change');
                    $("#txt_relation").val(data.d.FatherName);
                    $("#txt_mobile").val(data.d.Mobile);
                    $("#txt_cnic").val(data.d.CNIC);
                    $("#txt_Address").val(data.d.Address);
                    $("#ddl_bld_grp").val(data.d.Blood_Group).change();
                    $("#ddlRhFactor").val(data.d.Rh_Factor);
                    if (data.d.Patient_Type == "02") {

                        $("#ddl_pnl_cpy").val(data.d.PanelComany).change();
                        $("#txt_Emp").val(data.d.TxtEmp);
                        $("#txt_Ref").val(data.d.TxtRef);

                    }
                    $('#hdfPatient_ID').val(data.d.Reg_PatientID);



                }

            }
            var patient_id_old = 0;
            function ReplaceNullWith_Space(Data) {
                if (Data == "null")
                    return " ";
                else
                    return Data;
            }

            var patient_id_old = 0;
            function ReplaceNullWith_Space(Data) {
                if (Data == "null")
                    return " ";
                else
                    return Data;
            }
            function FillOtherTest() {
                var options = '';
                PageMethods.FillOtherTest(function (item) {
                    $.each(JSON.parse(item), function (key, value) {
                        options += '<option value="' + value.Test_ID + '" >' + value.Test_Name + '</option>';
                    });
                    $('#ddlOtherTest').html(options);
                    $('#ddlOtherTest').select2();
                });
            }
            var arr = [];
            function GetPanelRateAndDiscountComplete() {

                PageMethods.GetPanelRateAndDiscountComplete(function (data) {
                    var Parsed = JSON.parse(data);
                    $.each(Parsed, function (key, value) {
                        arr.push
                            ({
                                Item_ID: value.Item_ID,
                                Rate: value.Rate,
                                Discount: value.Discount,
                                Panel_ID: value.Panel_ID,
                            });
                    });
                });
            }
            function fillCashInHand() {
                debugger;

                PageMethods.GetGLAccounts(function (res) {
                    debugger;

                    var data = JSON.parse(res);
                    var cashOptions = '<option value="0">Please Select</option>';
                    $.each(data.cash, function (key, value) {
                        cashOptions += '<option value="' + value.Account_ID + '">' + value.name + '</option>';
                    });

                    $('#ddlCashInHand').html(cashOptions).select2();
                    var bankOptions = '<option value="0">Please Select</option>';
                    $.each(data.bank, function (key, value) {
                        bankOptions += '<option value="' + value.Account_ID + '">' + value.name + '</option>';
                    });

                    $('#ddl_Bank').html(bankOptions).select2();
                });
            }



            $(document).ready(function () {
                fillPanel();
                var Bill_ID = '<%= Request.QueryString["Bill_ID"] %>';
                if (Bill_ID != "") {
                    AllowBillEdit();
                }

                $("#btnPrint").hide();
                debugger;
                fillCasher();

                TotalAmountToday();
                $("#txtSearch").keypress(function (event) {

                    var SearchString = $('#txtSearch').val();
                    if (event.which == 13) {
                        {

                            event.preventDefault();

                            if (SearchString != '') {

                                PageMethods.AddPatient((Number(SearchString) ? parseInt(SearchString).toString() : SearchString), OnFilterPatients, OnFailPatients);
                            }
                        }
                        if (SearchString === '') {
                            FillPatientsList();
                        }
                    }

                });
                $("#txtSearch").keyup(function (event) {

                    var SearchString = $('#txtSearch').val();
                    event.preventDefault();
                    if (SearchString === '')
                        FillPatientsList();
                });
                fillmartial();
                fillgender();
                CheckAppointmentAllow();
                CheckReceiptsUpdateonBilling();

                jQuery(function ($) {
                    MaskedInput({
                        elm: document.getElementById('txtSearch'), // select only by id
                        format: '+92__________',
                        separator: '-'
                    });

                    var phoneInput = document.getElementById('txtSearch');
                    var cursorPosition = 3;
                    phoneInput.setSelectionRange(cursorPosition, cursorPosition);



                });

                $('#txt_cnic').attr('placeholder', '_____-_______-_');
                MaskedInput({
                    elm: document.getElementById('txt_cnic'),
                    format: '_____-_______-_',
                    separator: '-'

                });
                debugger;

                var id = '<%= Request.QueryString["Bill_ID"]%>';
                if (id != "") {
                    Deletebillsupdate();
                }

                localStorage.removeItem('Disc');
                localStorage.removeItem('Total_Disc_Amt');
                localStorage.Disc_Pro = "0.00";

                //GetPanelRateAndDiscountComplete();
                $("#txtDateFrom").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#txtDateTo").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#txtBillDate").datepicker({ dateFormat: 'mm/dd/yy' });
                $("#txtBillDate").val($.datepicker.formatDate('dd M yy', new Date()));
                FillTokenInputForMRNo();
                tokenInputs('txtAddPackage', 'PacakgesForBilling');
                //tokenInputs('txtAddService', 'INV_ItemsForBilling');
                //FillLabTests();
                FillDoctors();

                FillShareType();
                OpenRecord();
                debugger;
                // FillProcedure();
                var Reg_ID = '<%= Request.QueryString["Reg_ID"]%>';
                $('#hdfPatient_ID').val(Reg_ID);
                if (Reg_ID != "") {
                    setTimeout(function () {
                        FillTokenInputForMRNo();
                    }, 1000)

                }
                FillOtherTest();
                FillMainTestDepartment();
                FillChargePolicy();
                LoadMainDepartment();
                LoadBillDepartment();
                LoadBillPatCategory();
                fillCashInHand();

                AllowRateEdit();
                $('#add-new-testDirect').click(function () {
                });
                $('#add-new-Othertest').click(function () {
                });
                $('#add-new-Procedure').click(function () {
                });
                $('#add-new-testList').click(function () {
                });
                var id = '<%= Request.QueryString["Bill_ID"]%>';
                if (id != "") {
                }

                AllowReceipeRights();
                loadUserBranch();
                $('#ddlUserBranch').select2();

                LoadSalesTaxDefinitions();

                $("#txtAppointmentSearch").keypress(function (event) {
                    if (event.which == 13) {
                        event.preventDefault();
                        SearchAppointments();
                    }
                });

                var urlParams = new URLSearchParams(window.location.search);
                var appointmentId = urlParams.get('Appointment_ID');

                if (appointmentId && appointmentId != '0' && appointmentId != '') {
                    $('#hdnAppointment_ID').val(appointmentId);
                }

                if (appointmentId && appointmentId != '0' && appointmentId != '') {
                    $('#hdnAppointment_ID').val(appointmentId);
                    setTimeout(function () {
                        var patientId = $('#hdfPatient_ID').val();
                        if (patientId && patientId != '') {
                            LoadDermaAppointmentServices(parseInt(appointmentId));
                        }
                    }, 1500);
                }

                $("#ddl_name").change(function () {
                    var map = {
                        "Mr.": "S/O",
                        "Mrs.": "W/O",
                        "Ms.": "D/O"
                    };

                    $("#ddlRelation").val(map[$(this).val()]);
                });

            });  // document.ready ends

            var editrights;
            function AllowBillEdit() {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/CheckEditRights",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        editrights = data.d;

                        if (editrights == "true") {

                            $('#btnSave').attr('disabled', false);
                        }
                        else {
                            $('#btnSave').attr('disabled', true);
                        }

                    },
                    failure: function () {
                        alert("Error");
                    }
                });


            }

            function loadUserBranch() {
                PageMethods.GetUserBranch(function (result) {
                    if (!result || result === "null") {
                        $('#ddlUserBranch').empty().append('<option value="">No Branch Assigned</option>').prop('disabled', true);
                        return;
                    }

                    var branches = JSON.parse(result);
                    $('#ddlUserBranch').empty();
                    branches.forEach(function (branch) {
                        $('#ddlUserBranch').append(
                            '<option value="' + branch.branch_ID + '">' + branch.branch_Name + '</option>'
                        );
                    });
                    if (branches.length === 1) {
                        $('#ddlUserBranch').val(branches[0].branch_ID).prop('disabled', true);
                    } else {
                        $('#ddlUserBranch').prepend('<option value="">Select Branch</option>')
                            .val('')
                            .prop('disabled', false);
                    }
                });
            }



            function LoadSalesTaxDefinitions(selectedID, selectedPerc) {

                var options = '<option value="0">0</option>';

                PageMethods.GetSalesTaxDefinitions(function (Tests) {

                    $.each(JSON.parse(Tests), function (key, value) {

                        options += '<option value="' + value.Sales_Tax_ID + '" data-perc="' + value.Sales_Tax_Perc + '">'
                            + value.Sales_Tax_Perc +
                            '</option>';
                    });
                    $('#ddlSalesTax').html(options);
                    if (selectedID) {
                        $('#ddlSalesTax').val(selectedID).trigger('change');

                        if (selectedPerc) {
                            $('#hdnSalesTaxPercentage').val(selectedPerc);
                            CalculateSalesTax();
                        }
                    }

                });
            }
            function CalculateSalesTax() {
                debugger;
                var selectedOption = $('#ddlSalesTax option:selected');
                var salesTaxID = selectedOption.val();
                var salesTaxPerc = parseFloat(selectedOption.text()) || 0;
                $('#hdnSalesTaxID').val(salesTaxID);
                $('#hdnSalesTaxPercentage').val(salesTaxPerc);

                var baseNetPayable = 0;
                if ($('#hdnBaseNetPayable').val() && $('#hdnBaseNetPayable').val() != '0' && $('#hdnBaseNetPayable').val() != '') {
                    baseNetPayable = parseFloat($('#hdnBaseNetPayable').val());
                } else {
                    var totalPayable = parseFloat($('#txtTotalPayable').val()) || 0;
                    var discountAmt = parseFloat($('#txtDisAmt').val()) || 0;
                    baseNetPayable = totalPayable - discountAmt;
                    $('#hdnBaseNetPayable').val(baseNetPayable.toFixed(0));
                }

                if (salesTaxPerc == 0) {
                    $('#txtNetPayable').val(baseNetPayable.toFixed(0));
                    $('#txtFinalAmount').val(baseNetPayable.toFixed(0));
                } else {
                    var salesTaxAmount = (baseNetPayable * salesTaxPerc) / 100;
                    var finalAmount = baseNetPayable + salesTaxAmount;
                    $('#txtNetPayable').val(finalAmount.toFixed(0));
                    $('#txtFinalAmount').val(finalAmount.toFixed(0));
                }
                CountBalance();
            }

            function OpenAppointmentModal() {
                debugger;
                $('#AppointmentSearchModel').modal({
                    backdrop: 'static'
                });
                LoadAllAppointments();
                $('#srchapt').text("Search Appointments:");
                $('#txtAppointmentSearch').val('');
            }

            function LoadAllAppointments() {
                debugger;
                PageMethods.SearchAppointment('', OnFilterAppointments, OnFailAppointments);
            }

            function SearchAppointments() {
                var text = $('#txtAppointmentSearch').val();
                PageMethods.SearchAppointment(text, OnFilterAppointments, OnFailAppointments);
            }

            function OnFilterAppointments(data) {
                ClearAppointmentResults();
                for (var i = 0; i < data.length; i++) {
                    AddAppointmentResult(
                        data[i].Appointment_ID,
                        data[i].Appointment_No,
                        data[i].App_Date,
                        data[i].Patient_Name,
                        data[i].Emp_name,
                        data[i].Age,
                        data[i].Phone,
                        data[i].pat_id
                    );
                }
            }

            function AddAppointmentResult(Appointment_ID, Appointment_No, App_Date, Patient_Name, Emp_name, Age, Phone, pat_id) {
                debugger;
                var tblLength = tblAppointmentResult.rows.length;
                var row = iAppointmentBody.insertRow(-1);
                var cell;
                cell = row.insertCell(-1);
                cell.innerHTML = '<span spnAptID' + tblLength + '>' + Appointment_ID + '</span>';
                cell.className = "hide";
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Appointment_No + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + App_Date + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Patient_Name + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Emp_name + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Age + '</span>';
                cell = row.insertCell(-1);
                cell.innerHTML = '<span class="HRcontent">' + Phone + '</span>';
                cell = row.insertCell(-1);
                var actions = '';
                actions += '<a style="color:#EFA63E;font-size:20px;margin-left: 30px !important;border-radius:5px;text-decoration:none;" ' +
                    'href="#" onclick="AddAppointmentDetail(' + Appointment_ID + ',' + pat_id + ')">' +
                    '<i class="fa fa-plus-circle"></i></a>';

                cell.innerHTML = actions;
            }

            function ClearAppointmentResults() {
                while (tblAppointmentResult.rows.length > 1) {
                    tblAppointmentResult.deleteRow(1);
                }
            }

            var isAdd = false;

            function AddAppointmentDetail(Appointment_ID, pat_id) {
                debugger;
                try {
                    isAdd = true;
                    window.location.href = "BillingProcess.aspx?Reg_ID=" + pat_id + "&isAdd=" + isAdd + "&Appointment_ID=" + Appointment_ID;

                    sessionStorage.setItem('Appointment_ID', Appointment_ID);
                } catch (err) {
                    alert(err.message);
                }
            }

            function ViewAppointmentDetail(Appointment_ID) {
                debugger;
                alert('View Appointment: ' + Appointment_ID);
            }

            function OnFailAppointments(exc) {
                alert(exc.get_message());
            }

            function LoadDermaAppointmentServices(Appointment_ID) {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "BillingProcess.aspx/GetDermaAppointmentServices",
                    data: JSON.stringify({ "Appointment_ID": Appointment_ID }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var data = response.d;
                        var result = JSON.parse(data);

                        if (result.success === true && result.service) {
                            var service = result.service;
                            var appointment = result.appointment;
                            if (appointment.Doctor_Id) {
                                $('#hdn_docid').val(appointment.Doctor_Id);
                                setTimeout(function () {
                                    $('.ddlDoctor').val(appointment.Doctor_Id).trigger('change');
                                }, 500);
                            }
                            AddServiceFromAppointment(service, appointment);
                        }
                    },
                    error: function (xhr, status, error) {
                        console.error("Error loading appointment services:", error);
                    }
                });
            }

            function AddServiceFromAppointment(service, appointment) {
                debugger;

                var existingRow = $('#tblDetails tbody tr').find('input[name="hdnItemID"][value="' + service.Item_ID + '"]');
                if (existingRow.length > 0) {
                    console.log('Service already exists in table, skipping...');
                    return;
                }

                var rowIndex = parseInt($('#tblDetails tbody tr').length);
                var dateValue = '<%= DateTime.Now.ToString("dd MMM yyyy") %>';
                var itemtype = service.Services === true ? 'Service' : 'Item';
                var isMajorMinors = (service.Procedure_types == null || service.Procedure_types == 0) ? "" : service.Procedure_types;
                var remarks = appointment.Appointment_No ? "Appointment: " + appointment.Appointment_No : "";

                var row = '<tr>' +
                    '<td style="text-align:left;">' + (rowIndex + 1) + '</td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                    '<td style="text-align:left;">' +
                    '<input type="hidden" name="hdnParentTrans_ID" value="0" />' +
                    '<input type="hidden" name="hdnParentTrans_Name" value="DermaAppointment" />' +
                    '<input type="hidden" name="hdnParentTrans_Type" value="Appointment" />' +
                    '<input type="hidden" name="hdnItemID" value="' + service.Item_ID + '" />' +
                    '<input type="hidden" name="hdnItemName" value="' + (service.Description || '').replace(/"/g, '&quot;') + '" />' +
                    '<input type="hidden" name="hdnProcedure" value="' + (isMajorMinors || '').replace(/"/g, '&quot;') + '" />' +
                    '<input type="hidden" name="hdnDisPer" value="0" />' +
                    '<input type="hidden" name="hdnDisAmount" value="0.00" />' +
                    '<input type="hidden" name="hdnNet_Amount" value="' + (service.Sale_Rate || 0) + '" />' +
                    '<input type="hidden" name="hdnItemType" value="' + itemtype + '" />' +
                    '<input type="hidden" name="hdnRecommendedByDoctor" value="true" />' +
                    '<input type="hidden" name="Main_Department" value="007" />' +
                    (service.Description || '') +
                    '</td>' +
                    '<td>' + remarks.replace(/</g, '&lt;').replace(/>/g, '&gt;') + '</td>' +
                    '<td>' +
                    '<input type="text" name="txtQty" value="1" style="width: 45px !important;" ' +
                    'onkeyup="CulculateAmonutWithQty(this, true, false)"/>' +
                    '<input type="hidden" name="txtActualAmount" value="' + (service.Sale_Rate || 0) + '" />' +
                    '</td>' +
                    '<td style="text-align:right;" id="amnt' + rowIndex + '" name="amnt">' + (service.Sale_Rate || 0).toFixed(2) + '</td>' +
                    '<td><input type="text" name="DisPer" value="0" style="width: 37px !important;" ' +
                    'onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + ')"/></td>' +
                    '<td><input type="text" name="DisAmount" value="0.00" style="width: 75px !important;" disabled ' +
                    'onkeyup="CalculateSummarieDiscountAmountWise(' + rowIndex + ')"/></td>' +
                    '<td style="text-align:right;">' + (service.Sale_Rate || 0).toFixed(2) + '</td>' +
                    '<td><input type="number" id="ds' + rowIndex + '" name="DocShare" value="0" ' +
                    'style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                    '<td><input type="number" id="HocShare' + rowIndex + '" name="HocShare" value="0" ' +
                    'style="width: 75px !important;" onkeyup="calculateDoctorShare()"/></td>' +
                    '<td><select id="ddldoctor' + (rowIndex + 1) + '" name="ddlDoctor" class="ddlDoctor">' +
                    (typeof doctors !== 'undefined' ? doctors : '') + '</select></td>' +
                    '<td><input type="hidden" name="hdnTestCreatedDate" id="hdnTestCreatedDate" value="' + dateValue + '"/>' + dateValue + '</td>' +
                    '</tr>';

                $('#tblDetails tbody').append(row);
                $('.ddlDoctor').select2();

                setTimeout(function () {
                    CalculateSummarieDiscountPerWise(rowIndex);
                    CalculateSummariesMaster(false);
                }, 500);
            }


        </script>
        <asp:HiddenField runat="server" ID="hdfPatient_ID" ClientIDMode="Static" />
         <asp:HiddenField runat="server" ID="hndopdid" ClientIDMode="Static" />
         <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />
         <input type="hidden" name="hdnOpd_id" value="0" id="hdnOpd_id" />
         <input type="hidden" name="hdn_pkgname" value="0" id="hdn_pkgname" />
         <input type="hidden" name="hdn_pkgtype" value="0" id="hdn_pkgtype" />
         <input type="hidden" name="hdn_PatienttypeId" value="0" id="hdn_PatienttypeId" />
         <input type="hidden" name="hdn_InPatienttype" value="0" id="hdn_InPatienttype" />
         <input type="hidden" name="hdn_opd_procedure" value="0" id="hdn_opd_procedure" />
         <input type="hidden" name="hdn_docid" value="0" id="hdn_docid" />
         <input type="hidden" name="hdn_finalBill"  id="hdn_finalBill" />
        <input type="hidden" name="hdnAppointment_ID" value="0" id="hdnAppointment_ID" />
       <div class="row">
           <div class="col-md-2 text-end">
            <input type="button" value="Add Patient" id="btnSearchPatient" onclick="OpenModal()" class="btn-primry" style="border-radius: 28px; width: 100%;" />
        </div>
           <div class="col-md-2 text-end">
               <input type="button" class="btn-primry" value="Queue" onclick="openQueue()" />
        </div>
           <div class="col-md-2 text-end">
    <input type="button" value="Appointment" id="btnAppointment" onclick="OpenAppointmentModal()" 
           class="btn-primry" style="border-radius: 28px; width: 100%;" />
</div>
       </div>

<div class="row">
    <!-- Left Card -->
    <div class="col-lg-5 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row">
                    <div class="col-lg-4 col-md-5 col-sm-6 text-center">
                        <div class="image-container">
                            <img src="~../../../../wwwroot/ASsiratTheme/images/dashboard_Icons/billing2.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
                        </div>
                    </div>
                    <div class="col-lg-8 col-md-7 col-sm-6">
                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6  ">
                                <label>Patient Name:</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblPatienName"></label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Contact No:</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblContactNo"></label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Gender:</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblGender"></label>
                            </div>
                        </div>
                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Age Years:</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblAgeYears"></label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Reg Date</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblRegDate"></label>
                            </div>
                        </div>

                        <div class="row mb-3 mtt">
                            <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                                <label>Address:</label>
                            </div>
                            <div class="col-lg-7 col-md-7 col-sm-6">
                                <label id="lblAddress"></label>
                            </div>
                        </div>
                        <div class="row">
                          <div class="col-md-5 formrgn">
                                <label for="txtBillDate">Bill Date:</label>
                            </div>
                            <div class="col-md-6">
                                <input type="text" id="txtBillDate" class="form-control" disabled />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Right Card -->
    <div class="col-lg-7 col-md-5 col-sm-12">
        <div class="card">
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn">
                          <label for="txtMRNo">MR No *:</label>
                        <input type="text" id="txtMRNo" class="form-control"  />
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn">
                        <label for="txtBillNo">Bill No:</label>
                        <input type="text" id="txtBillNo" class="form-control" disabled="disabled" value="New" />
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn">
                        <label>Patient Category:</label>
                 
                        <input type="text" id="lblPatientCategory"  disabled="disabled" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn">
                        <label>Department:</label>
                      
                        <input type="text" id="lblDepartment" disabled="disabled" class="form-control" />
                    </div>
                </div>  

                <div class="row mb-3">
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn3">
                        <label>Category</label>
                        <select id="txtMaindepartment"  class="form-select">
                            <option></option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn3">
                        <label>Companies:</label>
                   
                        <select  disabled="disabled" id="lblOPDpnl" class="form-select">
                            <option></option>
                        </select>
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn3">
                        <label>Admit Date</label>
                        <input type="text" id="txtadmitdate" disabled="disabled" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn3">
                        <label>Discharge Date</label>
                        <input type="text" id="txtdischargedate" disabled="disabled" class="form-control" />
                    </div>
                <div class="row mb-3">
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn2">
                        <label>Ward Type</label>
                        <input type="text" id="wardtype" disabled="disabled" class="form-control" />
                    </div>

                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn2">
                        <label>Bed No</label>
                        <input type="text" id="bedno" disabled="disabled" class="form-control" />
                    </div>

                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn2">
                        <label>Room Type</label>
                        <input type="text" id="txtroomtype" disabled="disabled" class="form-control" />
                    </div>
                    <div class="col-lg-3 col-md-5 col-sm-6 formrgn2">
                        <label>Room No</label>
                        <input type="text" id="txtroomno"  disabled="disabled" class="form-control" />
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
        </div>

    <!-- Eighth Row -->
    <div class="row mb-2 align-items-center">
        <div class="col-md-2">
            <label for="ddlChargePolicy">Charge Policy: *</label>
             <select id="ddlChargePolicy" class="form-select">
                <option>Cash Patient</option>
                <!-- Other options -->
            </select>
        </div>
           <div class="col-md-2">
            <label for="ddlReffered_By">Referred By:</label>
               <select id="ddlReffered_By" class="form-select">
                <!-- Doctor options -->
            </select>
        </div>
        <div class="col-md-2">
        <label for="ddlcasher">Cashier:</label>
              <select id="ddlcasher" class="form-select">
                <option>Please Select</option>
                <!-- Other options -->
            </select>
        </div>
        <div class="col-md-2">
           <label for="txtBillAmountToday">Total Bill Amount Today:</label>
              <input type="text" id="txtBillAmountToday" class="form-control" disabled />
        </div>        
        <div class="col-lg-2">

            <label>Procedure Description:</label>
            <asp:DropDownList ID="ddlpro_dis" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
            <%--a--%>
        </div>
                <div class="col-md-2">
        <label for="ddlpanel">Panel:</label>
              <select id="ddlpanel" class="form-select">
                <%--<option>Please Select</option>--%>
                <!-- Other options -->
            </select>
        </div>
    </div>
    
        <div class="row">
              <div class="col-lg-2 col-md-3">
            <label for="txtRemarks">Remarks:</label>
                  <input type="text" id="txtRemarks" />
        </div>
              <div class="col-lg-2">
                  <label>Bill Department</label>
                  <select id="BillDepartment">
                   
                  </select>
              </div>
              <div class="col-lg-2">
                  <label>Bill Category</label>
                  <select id="BillCategory" ></select>
              </div>
                <div class="col-lg-2">
                    <label>Package Type</label>
                    <input id="PackageType" type="text" readonly="readonly" />
                </div>
                <div class="col-lg-2">
                    <label>Package Name</label>
                    <input id="PackageName" type="text" readonly="readonly" />
                </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlUserBranch">Branch</label>
                <select id="ddlUserBranch" class="form-control">
                    <option value="">Loading...</option>
                </select>
            </div>

        
        </div>
        
        <div class="row mtop">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-3">
                        <input type="text" id="txtAddService" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button"  class="btn-primry" value="Add Srvc / Itm" id="btnAddServiceOrItem" onclick="AddServiceOrItem()" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button"  class="btn-primry" value="Add Test" onclick="Populate()" id="btnAddTestAll" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button"  class="btn-primry" value="View Package" onclick="PopulatePackage()" id="btnrecoomendpackage" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button"  class="btn-primry" value="View Bills" onclick="PopulateDetails()" id="btnbilldetail" />
                    </div>
                </div>
            </div>
        </div>

        <div class="row">
            <div style="display: none;">
                <input style="display: none;" type="text" id="txtAddPackage" />
                <input type="button" style="width: auto; display: none;" value="Add Package" onclick="AddPackage()" id="btnAddPackage" />
            </div>
            <div class="col-lg-6" style="display: none;">
                <label>Doctor Share Distribution</label>
                <a href="javascript:void(0)" style="float: right; display: none;" onclick="Share_Doctor()">Add More</a>
            </div>
        </div>
            <div class="row">
                <div class="col-lg-9 table-container" style="overflow-y:scroll;height:300px">
                    <table class="table blank"  id="tblDetails">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 53px; text-align: left;">Action </th>
                            <th style="text-align: left;width: 352px;">Description </th>
                            <th style="text-align: left;width: 352px;">Remarks </th>
                             <th style="width: 65px; text-align: left;">Qty </th>
                            <th style="width: 60px; text-align: left;">Amount </th>
                            <th style="width: 70px; text-align: left;">Dis % </th>
                            <th style="width: 95px; text-align: left;">Dis Amount </th>
                            <th style="width: 100px; text-align: left;">Net Amount </th>
                            <th style="width: 100px; text-align: left;">Doc Share </th>
                            <th style="width: 100px; text-align: left;">Hos Share </th>
                            <th style="width: 170px; text-align: left;">Doctor </th>
                            <th style="width: 170px; text-align: left;">Issue Date </th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
                </div>
                <div class="col-lg-3">
                        <div class="row" >
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Total Amount</label>
            </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
             <input type="text" id="txtTotalAmount" style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
            </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Previous Amount</label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtprevious_Amount" style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Previous Paid</label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtprevious_paid" style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Previous Balance</label>
        </div>
            <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txt_balance" style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
        </div>
    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Total Payable: </label>
            </div>

          <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtTotalPayable" style="height: 30px;text-align: right; font-size: 22px;"  disabled="disabled" />
         </div>
   </div>
     <div class="row">
          <div class="col-lg-5 col-md-4 col-sm-6">
             <label>Over and Above </label>
             </div>
         <div class="col-lg-6 col-md-4 col-sm-6">
             <input type="text" id="txtOver_and_Above " style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
         </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label class="summary-label">Discount :</label>
        </div>
        <div class="col-lg-6 col-md-8 col-sm-12 discount-section">
            <input type="text" id="txtDisPer" class="summary-input" style="width: 30% !important;height: 30px; text-align: right; font-size: 22px;" onkeyup="CalculateSummariesMaster(false)" />
            
            <input type="text" id="txtDisAmt" class="summary-input" style="width: 33% !important;height: 30px; text-align: right; font-size: 22px;" readonly onkeyup="CalculateSummariesMaster(true)" />
            <label>%</label>
        </div>
        </div>
                    <div class="row">
                        <div class="col-lg-5 col-md-4 col-sm-6">
                            <label class="summary-label">Sales Tax :</label>
                        </div>
                        <div class="col-lg-6 col-md-8 col-sm-12 discount-section">
                            <select id="ddlSalesTax" class="form-control" style="text-align: right; font-size: 19px;" onchange="CalculateSalesTax()">
                                <option value="0">Select Tax</option>
                            </select>
                        </div>
                    </div>

<input type="hidden" id="hdnSalesTaxID" value="0" />
<input type="hidden" id="txtFinalAmount" value="0" />
<input type="hidden" id="hdnBaseNetPayable" value="0" />
<input type="hidden" id="hdnSalesTaxPercentage" value="0" />

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Net Payable:  </label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtNetPayable" style="height: 30px; text-align: right; font-size: 22px; color: red !important;" disabled="disabled" />
        </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>C. In Hand</label>
            </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <select id="ddlCashInHand" class="form-control">
                <option value="0">Select</option>
            </select>
            </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <input type="text" value="0" id="txtcashinhand" style="height: 30px;  text-align: right; font-size: 22px;" onkeyup="SumTotalAmountrecived()"/>
            </div>
    </div>

     <div class="row">
          <div class="col-lg-5 col-md-4 col-sm-6">
             <label>Bank Amt</label>
             </div>
         <div class="col-lg-3 col-md-4 col-sm-6">
             <select id="ddl_Bank" class="form-control" >
               
             </select>
             </div>
         <div class="col-lg-3 col-md-4 col-sm-6">
             <input type="text" id="txtbankcash" value="0" style="height: 30px; text-align: right; font-size: 22px;" onkeyup="SumTotalAmountrecived()" />
             </div>
         </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Amount Received:</label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtAmountReceived" style="height: 30px; text-align: right; font-size: 22px;" onkeyup="CountBalance()" disabled="disabled" />
        </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Advance Amount</label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtadvance_amount"  style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
    </div>

    <div class="row" style="display:none;">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Advance Amount</label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtRefund_amount"  style="height: 30px; text-align: right; font-size: 22px;" disabled="disabled" />
        </div>
    </div>

    <div class="row">
         <div class="col-lg-5 col-md-4 col-sm-6">
            <label>Balance:  </label>
        </div>
        <div class="col-lg-6 col-md-4 col-sm-6">
            <input type="text" id="txtBalances" style="height: 30px; text-align: right; font-size: 22px; color: red;" disabled="disabled" />
            <input type="hidden" id="txtPreviousBlnc" style="height: 30px; text-align: right; font-size: 22px; color: red;" disabled="disabled" />
        </div>
    </div>
                </div>

                         </div>
                        <div class="row mtop"  style="display:none;">
                            <div class="col-lg-10" ></div>
                            <div class="col-lg-1">
                                Doctors Distribution
                            </div> 
                            <div class="col-lg-1">
                             <input type="text" id="txtDoctorTotalDistribution"   disabled="disabled"/>
                            </div>
                        </div>                                                                                            
              
      
        <div class="row" style="display:none;" id="dvSummary">
            <div class="col-lg-6 col-md-8 col-sm-9"></div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label style="margin-top:11%" >Total Doctor Share</label>
                </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="text" id="txtTotalDoctorShare" style="height: 30px; text-align: right; font-size: 22px;margin-top:11%" disabled="disabled" />
            </div>
        </div>

    
            </div>
   
                    <div class="col-lg-6 table-container" style="overflow-y: scroll; height: 300px; display: none;">
                        <table class="table table-container table-responsive" id="Doctor_Share_Table">
                            <thead>
                                <tr>
                                    <th>Doctor Name</th>
                                    <th>Share Type</th>
                                    <th>Amount</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>


        <div class="row">
            <div class="col-lg-8 mtop">
                <div class="row">
                    <div class="col-lg-2">
                        <input type="button" class="btn-primry" value="Save & Print" onclick="SaveRecord()" id="btnSave" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'BillingProcess.aspx'" />
                    </div>
                    <div class="col-lg-2" id="btnPrint">
                        <input type="button" class="btn-primry" value="Print" name="name" onclick="PrintCRV();"  style="width: 100px;" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button" class="btn-primry" value="Print-1" onclick="PrintCRV1();"  style="width: 100px;" />
                    </div>
                            <div class="col-lg-2">
                        <input type="button" class="btn btn-gray" value="List View" onclick="window.open('BillingProcessView.aspx')" />
                    </div>
                     <div class="col-lg-2">
                        <input type="button" class="btn btn-primry"  style="width: 110px; display: none;" value="Approve" id="btnApprove"   onclick="ApproveBill()" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button" style="width: 110px; display: none;" id="btnPrintVoucher" class="btn btn-primry" value="Print Voucher" onclick="PrintVoucher();" />
                        <input type="button" style="width: 110px; display: none;" value="Hospital Print" onclick="PrintHospital();" />
                        <input type="button" style="width: 110px; display: none;" value="Consult Print" onclick="PrintConsultant();" />
                        <input type="button" style="width: 110px; display: none;" value="Patient Copy" name="name" onclick="BackToPrintPatient();" style="width: 100px;" />
                    
                    </div>
                </div>
            </div>
        </div>
        <%--modal here--%>

    
        <div id="PatientsSearchModel" data-backdrop="static" class="modal fade-in" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -306px; height: 604px; position: relative;">
                    <fieldset style="padding-top: 20px; padding-left: 14px;">
                        <div class="col-lg-2 col-md-4 col-sm-6">                           
                        <label id="srchpat">Search Your Patients: </label>
                            <input type="text" id="txtSearch" style="margin-left: 2px;" autocomplete="off" />
                        </div>
                        <div class="col-lg-3 col-md-4 col-sm-6">  
                        <label>Search</label>
                        <input type="text" id="txtPatientSearch"  placeholder="Name / MR No / CNIC / Phone" onkeyup="SearchPatients()" />
                            </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label></label>
                            <input type="button" class="btn btn-primry" id="addNewbtn" onclick="addfunc()" value="Add New" />
                        </div>
                        
                    </fieldset>
                    <div style="overflow: scroll; height: 460px; padding: 10px;">
                        <table class="table table-hover table-striped table-bordered" id="tblPatientsResult" style="overflow: scroll; height: auto;">
                            <thead id="Thead1">
                                <tr>
                                    <th style="display: none;">Patient ID</th>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>CNIC</th>
                                    <th>Contact No</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>

                            <tbody id="iPatientsBody">
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <input type="button" style="width:13% !important" id="ClosePatientsSearchModel" class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
                    </div>

                </div>

            </div>

        </div>

    <%--Patient Que Start--%>
    <div id="queueModal" class="modal fade scrollable-modal" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="QueueList">
                        <div class="row" style="margin-bottom: 15px">
                           
                            <div class="col-lg-2 text-end">
                                <a onclick="fillPendingPatientsList()">
                                    <i class="fa fa-refresh fa-2x"></i>
                                </a>
                            </div>

                        </div>


                        <div class="table-responsive previewTable" style="overflow:auto;" >
                            <table class="table table-bordered table-custom" id="tblPendingPatients">
                                <thead id="ihead">
                                    <tr>
                                        <th>MR No</th>
                                        <th>Patient Name</th>
                                        <th>Age</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>

                        </div>
                    </div>


                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>


    <%--Patient Que Ends--%>
        <%--patient modal here--%>

          <div id="PatientModel" class="modal fade-in" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content modalSize" style="width: 1104px; margin-left: -302px; height: 300px; margin-top: 117px; /* 316px */">

                    <form>
                        <div class="container-fluid">
                            <div class="row" style="margin-top: 40px!important;">
                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <label>MR No</label>
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input type="text" id="txt_Mrno" value="New" disabled style="width: 232px !important;" />
                                </div>


                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-2 col-md-3 col-sm-4"></div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <label>Gender<span style="color:red;">*</span></label>
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <select id="ddl_Gender" tabindex="4" style="width: 197px;">
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <label>Name<span style="color:red;">*</span></label>
                                </div>

                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <select class="impo-drop1 fcux" name="name" id="ddl_name">
                                        <option value="Mr.">Mr.</option>
                                        <option value="Mrs.">Mrs.</option>
                                        <option value="Ms.">Ms.</option>
                                        <option value="B/O.">B/O.</option>
                                    </select>
                                </div>


                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input name="dob"  type="text" id="txt_name" tabindex="1" style="margin-left: -12px !important" />
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-4"></div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <label>Martial Status<span style="color:red;">*</span></label>
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <select  tabindex="5" id="ddl_status" style="width: 197px;">
                                        <option></option>
                                    </select>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <label>Relation<span style="color:red;">*</span></label>
                                </div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <select class="impo-drop fcux" name="name" id="ddlRelation">
                                        <option value="S/O">S/O</option>
                                        <option value="W/O">W/O</option>
                                        <option value="D/O">D/O</option>
                                    </select>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input type="text" id="txt_relation" tabindex="2" style="margin-left: -12px !important" />
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4"></div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <label>Mobile<span style="color:red;">*</span></label>
                                </div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input type="text" tabindex="6" id="txt_mobile" style="width: 197px !important;" />
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <label>Age/DOB<span style="color:red;">*</span></label>
                                </div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <select name="name" id="PrefixAge" >
                                        <option value="Year">Year</option>
                                        <option value="Month">Month</option>
                                        <option value="Day">Day</option>
                                    </select>
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input type="text" id="txt_dob" tabindex="3" style="width: 35% !important; margin-left: -15px!important" onchange="CalculateDateOfBirth();" />
                                    <input class="fcux" type="text" id="txtAge_yearss" style="display: inline; width: 65% !important" placeholder="mm ddyy" />
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4"></div>
                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <label>CNIC<span style="color:red;">*</span></label>
                                </div>

                                <div class="col-lg-2 col-md-3 col-sm-4">
                                    <input tabindex="7"  type="text" id="txt_cnic" style="width: 200px !important" />
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-lg-1 col-md-3 col-sm-4"></div>
                                <div class="col-lg-1 col-md-3 col-sm-4">
                                    <label>Address<span style="color:red;">*</span></label>
                                </div>

                                <div class="col-lg-6 col-md-3 col-sm-4">
                                    <input type="text" tabindex="8" id="txt_Address"  />
                                </div>
                            </div>
                        </div>
                    </form>


                    <div class="modal-footer" style="margin-top: 6%;">
                        <input type="button"  id="SavePatient_Data" class="btn btn-primry" tabindex="9" name="savePatient_Data" value="Save" style="width:10% !important" onclick="SavePatient();" />
                        <%-- <input type="button" id="RevistPat" name="RevistPat" value="Revist" onclick="SaveRevist_Patient();" />--%>
                        <input type="button" id="updatePatient_Data" class="btn btn-primry"  name="updatePatient_Data" style="text-transform: capitalize;width:10% !important" value="Update" onclick="SavePatient();" tabindex="23" />
                        <input type="button" id="CloseSearchModel" class="btn-gray" style="width:10% !important" name="saveENT" value="Close" data-dismiss="modal" />
                    </div>
                </div>
            </div>
        </div>


    </div>
    <div id="TestModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add Test</h4>
                </div>
                <table style="margin-left: 60px;">
                    <tr>
                        <td>
                             <div style="margin-top: 2px;">
                    <h2>Main Tests Department : </h2>
                </div>
                        </td>
                    </tr>
                    </table>
                <table  style="margin-left: 60px;">
                    <tr>
                        <td>
                         <select id="ddlMainTestDepartment" tabindex="" onchange="LoadTestByDepartment()" autofocus="autofocus" style="width: 180px !important;">
                                    <option value="">Select Department</option>
                                </select>
                        </td>
                         <td style="width: 205px;">
                             <span class="paper_help_note" tabindex="1" onFocus="document.querySelector('.autofocus2').focus()"></span>
                            <select id="ddlTestList" class="paper_update autofocus1" tabindex="1" >
                                </select>
                             <div id="divRotation">
                                    <select id="ddlRotation" style="display: none; width: 100px">
                                    </select>
                                </div>
                                <div id="divX_Ray">
                                    <select id="ddlXRayLF" style="display: none;width: 73px !important;margin-left: 101px;margin-top: -28px;height: 28px;">
                                      <option value="0"></option>
                                        <option value="L">Left</option>
                                        <option value="R">Right</option>
                                    </select>
                                </div>
                        </td>
                         <td>
                                <input type="button"  style="border: 3px solid white !important;height: 42px !important;" value="Add Test" tabindex="2" class="paper_update autofocus2 Faddbtn btn btn-primry" id="btnAddAllTest" onclick="AddAllTest()"/>
                             <span class="paper_help_note" tabindex="2" onFocus="document.querySelector('.autofocus1').focus()"></span>
                            </td>
                    </tr>
                    <tr>
                    <td>Remarks:
                            <input type="text" id="Remarks" tabindex="3" />
                            </td>
                        </tr>
                </table>
           
                 <div style="width: 742px; overflow: scroll; height: 250px !important; height: auto;margin-left: 60px;margin-top: 20px;">
                <table class="table blank" style="width: 724px; height: 146px !important; height: auto; overflow: scroll;" id="tbltestModelTable">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 53px; text-align: left;">Action </th>
                            <th style="text-align: left;width: 352px;">Description </th>
                            <th style="text-align: left;width: 352px;">Remarks </th>
                             <th style="width: 65px; text-align: left;">Qty </th>
                            <th style="width: 60px; text-align: left;">Amount </th>
                          
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
             <div class="modal-footer">
                    <input type="button" class="btn btn-primry" style="width:14% !important" id="Button1" name="saveENT" value="Save" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>

     <div id="PackageModel" class="modal fade" role="dialog">
     <div class="modal-dialog">
         <!-- Modal content-->
         <div class="modal-content" style="margin-left: -270px; height: 505px;">
             <div class="modal-header">
                 <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>              
             </div>

  
        
              <div style="width: 600px; overflow: scroll; height: 350px !important; height: auto;margin-left: 145px;margin-top: 20px;">
             <table class="table blank" style="width: 580px; height: 146px !important; height: auto; overflow: scroll;" id="tblPackageModelTable">
                 <thead>
                     <tr>
                         <th style="width: 50px; text-align: left;">Sr. </th>
                         <th style="text-align: left;width: 352px;">Description </th>
                         <th style="width: 60px; text-align: left;">Amount </th>
                       
                     </tr>
                 </thead>
                 <tbody>
                 </tbody>
             </table>
         </div>
          <div class="modal-footer">
               
             </div>
         </div>
     </div>
 </div>
    <div id="DetailModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <!-- Modal content-->
            <div class="modal-content" style="margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                </div>



                <div style="width: 600px; overflow: scroll; height: 350px !important; height: auto; margin-left: 145px; margin-top: 20px;">
                    <table class="table blank" style="width: 580px; height: 146px !important; height: auto; overflow: scroll;" id="tblDetailModelTable">
                        <thead>
                            <tr>
                                <th style="width: 70px; text-align: left;">Sr. </th>
                                <th style="width: 800px; text-align: left;">Bill No </th>
                                <th style="text-align: left;">Total Amount </th>
                                <th style="width: 100px; text-align: left;">Discount Amount </th>
                                <th style="width: 100px; text-align: left;">Recevied Amount </th>
                                <th style="width: 100px; text-align: left;">Balance Amount </th>
                                <th style="width: 100px; text-align: left;">Action </th>

                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>

    <div id="BillingDetailModel" class="modal fade" role="dialog">
    <div class="modal-dialog">
        <!-- Modal content-->
        <div class="modal-content" style="margin-left: -270px; height: 505px;">
            <div class="modal-header">
                <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
            </div>



            <div style="width: 600px; overflow: scroll; height: 350px !important; height: auto; margin-left: 145px; margin-top: 20px;">
                <table class="table blank" style="width: 580px; height: 146px !important; height: auto; overflow: scroll;" id="tblBillingDetailModelTable">
                    <thead>
                        <tr>
                            <th style="width: 50px; text-align: left;">Sr. </th>
                            <th style="width: 50px; text-align: left;">Bill No </th>
                            <th style="text-align: left; width: 352px;">Description </th>
                            <th style="text-align: left; ">Item Type </th>
                            <th style="text-align: left;">Qty </th>
                            <th style="width: 60px; text-align: left;">Total Amount </th>
                            <th style="width: 60px; text-align: left;">Discount Amount </th>
                            <th style="width: 60px; text-align: left;">Received Amount </th>
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
            </div>
        </div>
    </div>
</div>
<!-- =============== BOM SECTION (INTERNAL) =============== -->
<div id="bomSection" style=" display:none; margin-top:20px; padding:12px; background:#f8f9fa; border-radius:6px; border:1px solid #dee2e6;">
  <h5 style="margin-top:0; color:#333; font-weight:600;">
    <i class="fa fa-cogs"></i> BOM Components (Internal Costing)
  </h5>
  
  <table id="tblBOM" class="table table-bordered table-sm" style="font-size:0.875rem; margin-bottom:8px;">
    <thead class="thead-light">
      <tr>
        <th>#</th>
        <th>Item</th>
        <th>Description</th>
        <th>Qty</th>
        <th>Unit</th>
        <th><abbr title="From BOM setup">Recipe<br>Cost/Unit</abbr></th>
        <th><abbr title="Weighted Avg Cost (real-time)">Avg<br>Cost/Unit</abbr></th>
        <th><abbr title="Avg Cost × Qty">Runtime<br>Cost</abbr></th>

      </tr>
    </thead>
    <tbody>
      <tr><td colspan="9" class="text-center text-muted">Loading BOM...</td></tr>
    </tbody>
  </table>


  <div id="bomTotal" style="font-weight:bold; color:#1e7e34; font-size:1.1em;">
    <i class="fa fa-calculator"></i> 
    Total BOM Runtime Cost: 
    <input type="text" id="bomTotalValue" style="color:#d9534f;" disabled="disabled" />
  </div>
</div>


<!-- Optional: Hidden container for form submission (uncomment if needed for Save) -->
<!-- <div id="bomContainer" style="display:none;"></div> -->
     <div id="PrintBillingReport" style="display:none;">
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">
            <div style="padding: 5px; margin-left: -30px">
              <%--  <img height="105" width="120" src="images/HMIS_Icons/rlmc-logo.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    Arif Memorial Hospital Lahore
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
                        <span id="lvlMRno"></span>
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
               
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Gender:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: left; margin-left: -15px; margin-top: -20px; font-size: 14px;">
                        <span id="lblGenderb"></span>
                    </h6>
                </td>
                  <td>
                    <h6 style="width: 70px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Ward/Room</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -10px; margin-top: -20px; font-size: 14px;">
                        <span id="wardroom"></span>
                    </h6>
                </td>

            </tr>
              <tr>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td></td>
                <td>                    
                     <h6 style="width: 80px; text-align: left; font-size: 20px; font-size: 14px; margin-top: -25px;font-family:Calibri">Charge Policy</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 120px; text-align: left; margin-left: -10px; margin-top: -20px; font-size: 14px;">
                        <span id="lblchargePolicyb"></span>
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
                     <th style="width: 100px; text-align: center; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray;font-family:Calibri;font-size:18px">Report Timing </th>
                </tr>
            </thead>
            <tbody id="Billtbody" >
            </tbody>
        </table>
                 </div>
         <div>
            <span id="spnLabDesc" style="display:none;font-size: 14px;margin-left:30px;">I allow the AMLab staff for phlebotomy procedure for mentioned lab investigation(s).</span>
         
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

    <%--Appointment Search Modal--%>
<div id="AppointmentSearchModel" data-backdrop="static" class="modal fade-in" role="dialog">
    <div class="modal-dialog">
        <div class="modal-content" style="width: 1140px !important; margin-top: 116px; margin-left: -306px; height: 604px; position: relative;">
            <fieldset style="padding-top: 20px; padding-left: 14px;">
                <div class="col-lg-3 col-md-4 col-sm-6">
                    <label id="srchapt">Search Appointments: </label>
                    <input type="text" id="txtAppointmentSearch" style="margin-left: 2px;" autocomplete="off" 
                           placeholder="Appointment No / Patient Name / Doctor / Phone" 
                           onkeyup="SearchAppointments()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label></label>
                    <input type="button" class="btn btn-primry" id="btnRefreshAppointment" 
                           onclick="LoadAllAppointments()" style="display:none" value="Refresh" />
                </div>
            </fieldset>
            <div style="overflow: scroll; height: 460px; padding: 10px;">
                <table class="table table-hover table-striped table-bordered" id="tblAppointmentResult" 
                       style="overflow: scroll; height: auto;">
                    <thead id="AppointmentThead">
                        <tr>
                            <th style="display: none;">Appointment ID</th>
                            <th>Appointment No</th>
                            <th>Date</th>
                            <th>Patient Name</th>
                            <th>Doctor</th>
                            <th>Age</th>
                            <th>Phone</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="iAppointmentBody">
                    </tbody>
                </table>
            </div>
            <div class="modal-footer">
                <input type="button" style="width:13% !important" id="CloseAppointmentSearchModel" 
                       class="btn-gray" name="saveENT" value="Close" data-dismiss="modal" />
            </div>
        </div>
    </div>
</div>

</asp:Content>

