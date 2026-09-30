<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientsDepartmentWise.aspx.cs" Inherits="PMS.PatientsDepartmentWise" %>

<%@ MasterType VirtualPath="~/Site.master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <script type="text/javascript">

        function FillAnalysisTests() {
            var options = '<option value="All">All</option>';
            PageMethods.GetLabTestsForAnalysis(function (data) {
                var testsData = JSON.parse(data);
                $.each(testsData, function (key, value) {
                    options += '<option value="' + value.TestID + '">' + value.TestName + '</option>';
                });
                $('#ctl00_MainContent_ddlDepartments').html(options);
                $('#ctl00_MainContent_ddlDepartments').select2(); // Reinitialize select2 if needed
            });
        }

        function populateYears() {
            debugger;
            var currentYear = new Date().getFullYear();
            var yearSelect = $('#<%= ddlYear.ClientID %>');
            yearSelect.find('option').not(':first').remove();
            for (var year = currentYear; year >= currentYear - 10; year--) {
                yearSelect.append($('<option></option>')
                    .attr('value', year)
                    .text(year));
            }
            yearSelect.val(currentYear);
            $('#ctl00_MainContent_ddlYear').select2();
        }
        function populateMonths() {
            var monthNames = [
                "January", "February", "March", "April",
                "May", "June", "July", "August",
                "September", "October", "November", "December"
            ];
            var monthSelect = $('#<%= ddlMonth.ClientID %>');
            monthSelect.find('option').not(':first').remove();
            $.each(monthNames, function (index, name) {
                monthSelect.append($('<option></option>')
                    .attr('value', index + 1)
                    .text(name));
            });
            // Default to current month
            monthSelect.val(new Date().getMonth() + 1);
            $('#ctl00_MainContent_ddlMonth').select2();
        }

        function FillCardioTests() {

            var dpt = $('#ctl00_MainContent_ddlDepartments').val();

            var options = '<option value="0">All</option>';
            PageMethods.GetCardioTests(function (data) {
                var testsData = JSON.parse(data);
                debugger;
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ctl00_MainContent_ddlDepartments').html(options);
                //$('#ddlDepartments').select2();

            });
            return options;
        }
        function loaddoctor() {
            debugger;
            var dpt = $('#ctl00_MainContent_ddlDepartments').val();
            PageMethods.LoadDoctor(dpt, function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >All Doctor</option>';
                //var rowsText = '';

                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ctl00_MainContent_ddlDoctor').html(options)
                DisableFilterClinic();
            });
        }
        debugger;
        function loadmed() {
            debugger
            var med_Name = $('#ctl00_MainContent_ddlMedName').val();
            if (med_Name == "0" || med_Name == null || med_Name == "null") {
                med_Name = "";
            }

            var options = '<option value="0">All</option>';

            PageMethods.loadMedicine(med_Name, function (data) {
                debugger;
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                });
                $('#ctl00_MainContent_ddlMedName').html(options);
            });

            return options;
        }
        var patid;
        function loadMRNo() {

            $("#ctl00_MainContent_txtMRNo").tokenInput("json.aspx?Table=PatientsByMr",

                {

                    tokenLimit: 1,

                    onAdd: function (item) {

                        try {

                            $("#ctl00_MainContent_txtMRNo").val(item.name);

                            patid = item.id;

                        }

                        catch (err) {

                            alert(err.message);

                        }

                    }

                });

            $('#ctl00_MainContent_txtMRNo').focus();

        }


        function LoadInvNo() {
            var ItemName = $('#ctl00_MainContent_ddlInvForm').val();
            var options = '<option value="0">All</option>';
            $('#ctl00_MainContent_ddlInvNo').html(options);
            PageMethods.LoadFormNo(ItemName, function (data) {
                debugger;
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.ID + '" >' + value.NO + '</option>';
                });
                $('#ctl00_MainContent_ddlInvNo').html(options);
            }, function (error) {
                console.error(error.get_message()); // Log any errors for debugging
            });
            return options;
        }
        function FillLabTests() {

            var dpt = $('#ctl00_MainContent_ddlDepartments').val();

            var options = '<option value="0">All</option>';
            PageMethods.GetLabTests(function (data) {
                var testsData = JSON.parse(data);

                debugger;

                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                });
                $('#ctl00_MainContent_ddlDepartments').html(options);

            });
            return options;
        }
        function DisableDepartmentDoctor() {
            debugger;
            var filter = $('#ctl00_MainContent_ddlFilterClinic').val();
            if (filter == 0) {
                $('#ctl00_MainContent_ddlDoctor').prop('disabled', false);
                $('#ctl00_MainContent_ddlDepartments').prop('disabled', false);
            } else {
                $('#ctl00_MainContent_ddlDoctor').prop('disabled', true);
                $('#ctl00_MainContent_ddlDepartments').prop('disabled', true);
            }
        }
        function DisableFilterClinic() {
            debugger;
            var department = $('#ctl00_MainContent_ddlDepartments').val();

            if (department == "All") {
                $('#ctl00_MainContent_ddlFilterClinic').prop('disabled', false);
            } else {
                $('#ctl00_MainContent_ddlFilterClinic').prop('disabled', true);
            }
        }



        $(document).ready(function () {

            debugger;
            var ReportTitle = '<%= Request.QueryString["rptTitle"]%>';
            //if (ReportTitle == "Lab_Cash_Collection") {
            //    FillLabTests();
            //}
            loadMRNo();
            LoadInvNo();
            loadmed();


            if (ReportTitle == "YearlyPharmacyOverallSummary") {
                $('#<%= YearDiv.ClientID %>').show();
            $('#<%= DateDiv.ClientID %>').hide();
            $('#<%= Time_Row.ClientID %>').hide();

                setTimeout(function () {
                    populateYears();
                }, 100);
            }
            if (ReportTitle == "DailyPharmacyOverallSummary" || ReportTitle == "DailyCashCollectionSummaryReport") {
                $('#<%= YearDiv.ClientID %>').show();
            $('#<%= MonthDiv.ClientID %>').show();
            $('#<%= DateDiv.ClientID %>').hide();
            $('#<%= Time_Row.ClientID %>').hide();

                setTimeout(function () {
                    populateYears();
                    populateMonths();
                }, 100);
            }



            var bool = '<%= Convert.ToBoolean(AllowPatientRecord)%>'
            debugger;
            if (bool == "False") {
                $('#ctl00_MainContent_trAllPatients').hide();
            }
            $("#ctl00_MainContent_txtStart_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
            $("#ctl00_MainContent_txtEnd_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());

            if (ReportTitle == "Stock_In_Hand_Detail") {
                $("#ctl00_MainContent_txtStart_Date").datepicker("setDate", new Date(2020, 0, 1));
                $("#ctl00_MainContent_txtEnd_Date").datepicker("setDate", new Date());
            } else {
                $("#ctl00_MainContent_txtStart_Date").datepicker("setDate", new Date());
                $("#ctl00_MainContent_txtEnd_Date").datepicker("setDate", new Date());
            }

            $('#ctl00_MainContent_txtSTime').ptTimeSelect({});
            $('#ctl00_MainContent_txtETime').ptTimeSelect({});
            $('#ctl00_MainContent_txtSTime').val('12:00 AM');
            $('#ctl00_MainContent_txtETime').val('11:59 PM');

            // "As On" checkbox: hide Start Date and use default date (add more reports with ||)
            if (ReportTitle == "CathLabStockInHand" /* || ReportTitle == "OtherReport" */) {
                $('#cbHideStartDate').on('change', function () {
                    var hidden = this.checked;
                    $('#<%= sttDate.ClientID %>').toggle(!hidden);
                    $('#<%= txtStart_Date.ClientID %>').toggle(!hidden);
                });
            }

            $('#ctl00_MainContent_ddlDepartments').select2();
            $('#ctl00_MainContent_ddlPaymentType').select2();
            $('#ctl00_MainContent_ddlPatientType').select2();
            $('#ctl00_MainContent_ddlwareHouse').select2();
            $('#ctl00_MainContent_ddlReportType').select2();
            $('#ctl00_MainContent_ddlcatagory').select2();
            $('#ctl00_MainContent_ddlMainDepartment').select2();
            $('#ctl00_MainContent_ddlMedicalSubsidy').select2();
            $('#ctl00_MainContent_ddlSubDepartment').select2();
            $('#ctl00_MainContent_ddlStock').select2();
            $('#ctl00_MainContent_ddlPaymentType').select2();
            $('#ctl00_MainContent_ddlMovementType').select2();
            $('#ctl00_MainContent_ddlVendor').select2();
            $('#ctl00_MainContent_ddOPDIPDdiv').select2();
            $('#ctl00_MainContent_ddlItemCategory').select2();
            $('#ctl00_MainContent_ddloprators').select2();
            $('#ctl00_MainContent_ddlTestName').select2();
            $('#ctl00_MainContent_ddlDoctor').select2();
            $('#ctl00_MainContent_ddlInvForm').select2();
            $('#ctl00_MainContent_ddlInvNo').select2();
            $('#ctl00_MainContent_ddlItemName').select2();
            $('#ctl00_MainContent_ddlActive').select2();
            $('#ctl00_MainContent_ddlcashier').select2();
            $('#ctl00_MainContent_ddlProcedure').select2();
            $('#ctl00_MainContent_ddlStatus').select2();
            $('#ctl00_MainContent_ddlYear').select2();
            $('#ctl00_MainContent_ddlMonth').select2();



            $('#btnReset').click(function () {

                $('#Elements').find('input:text').each(function () {
                    $('select option:nth-child(1)').attr('selected', 'selected')
                    $(':text, textarea').val('');
                    $(':checkbox,:radio').attr('checked', '');
                });
            });
            $(document).ready(function () {
                var ReportTitle = '<%= Request.QueryString["rptTitle"]%>';
                if (ReportTitle === "Operator_Wise_Billing_Report" || ReportTitle === "Receipt_Operator_Wise_Report") {
                    $('#lblAllPatientRecord').text("Detailed Summary");
                }
            });

            //$('#btnPreview').click(function () {
            $('#<%= btnPreview.ClientID %>').click(function () {
                debugger;
                var ary = [];
                $('#ctl00_MainContent_lblMultiSelect').children().each(function () {
                    ary.push($(this).val());
                });
                var Allvalues = ary;
                var error = 0;

                $('#ctl00_MainContent_txtSTime').val();
                $('#ctl00_MainContent_txtETime').val();


                var asOn = $('#cbHideStartDate').is(':checked');
                if ($('#ctl00_MainContent_txtStart_Date').val() == '' && !asOn && error == 0) {
                    alert('Please Select Start Date');
                    error = 1;
                }
                else if ($('#ctl00_MainContent_txtEnd_Date').val() == '' && error == 0) {
                    alert('Please Select End Date');
                    error = 1;
                }
                else {
                    var rptTitle = '<%= Request.QueryString["rptTitle"]%>'

                    if (rptTitle == "Doctotr_Receiptss") {
                   //     var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                       // var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DoctorWisePatients&ReportTitle=Doctor Wise Patient from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked;  // + '&ExportPDF=' + exporttopdf
                        window.open(url, '_blank');
                    }

<%--                    else if (rptTitle == "Doctotr_Receipts") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var allPatientRecord = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DoctorWisePatients&ReportTitle=Department Wise and Patient Wise Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + allPatientRecord + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }--%>



                    else if (rptTitle == "InPatients_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var allPatientRecord = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=InPatients_Detail&ReportTitle=Department Wise And InPatient Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&TransType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&AllPatientsRecords=' + allPatientRecord + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");   // excluded  '&ExportPDF=' + exporttopdf +     '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked +
                        console.log(url);
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "ComponentBloodBankStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Component = $("#ctl00_MainContent_ddlMainDepartment").val();
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ComponentBloodBankStockLedger&ReportTitle=  ' + $("#ctl00_MainContent_ddlMainDepartment option:selected ").text() + '    summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&Component=' + Component + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "YearlyPharmacyOverallSummary") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        $('#<%= YearDiv.ClientID %>').show();
                        $('#<%= DateDiv.ClientID %>').hide();
                        $('#<%= Time_Row.ClientID %>').hide();
                        var selectedYear = $('#ctl00_MainContent_ddlYear').val();

                        if (selectedYear === "0") {
                            alert('Please select a year');
                            return;
                        }
                        var url = 'ReportViewer.aspx?ReportName=YearlyPharmacyOverallSummaryReport&ReportTitle=Pharmacy Overall Summary Report FY' + '&Year=' + selectedYear + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DailyPharmacyOverallSummary") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        $('#<%= YearDiv.ClientID %>').show();
                        $('#<%= MonthDiv.ClientID %>').show();
                        $('#<%= DateDiv.ClientID %>').hide();
                        $('#<%= Time_Row.ClientID %>').hide();
                        var selectedYear = $('#ctl00_MainContent_ddlYear').val();
                        var selectedMonth = $('#ctl00_MainContent_ddlMonth').val();

                        if (selectedYear === "0") {
                            alert('Please select a year');
                            return;
                        }
                        if (selectedMonth === "0") {
                            alert('Please select a month');
                            return;
                        }
                        var url = 'ReportViewer.aspx?ReportName=DailyPharmacyOverallSummaryReport&ReportTitle=Pharmacy Overall Summary Report FY' + '&Year=' + selectedYear + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Month=' + selectedMonth + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "SAR") {
                        debugger;
                        // var exporttopdf = $('#chkExportPDF')[0].checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var sDate = ($("#ctl00_MainContent_txtStart_Date").val());
                        var eDate = ($("#ctl00_MainContent_txtEnd_Date").val());
                        var department = ($("#ctl00_MainContent_ddlDepartments").val());
                        var url = 'ReportViewer.aspx?ReportName=StockAdjustment&ReportTitle= ' + rptTitle + '&startDate=' + sDate + '&endDate=' + eDate + '&Department=' + department + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "STM") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=StockBalance&ReportTitle=Item Wise Stock Balance Report ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&itemCode=' + ((typeof ($("#txtItemCode").val()) != 'undefined' && $("#txtItemCode").val().toString() != "") ? $("#txtItemCode").val().toString().split('-')[0] : '') + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    //else if (rptTitle == "STM") {
                    //    debugger;
                    //    var url = 'ReportViewer.aspx?ReportName=StockBalance&ReportTitle=Item Wise Stock Balance Report ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&itemCode=' + ((typeof ($("#txtItemCode").val()) != 'undefined' && $("#txtItemCode").val().toString() != "") ? $("#txtItemCode").val().toString().split('-')[0] : '');
                    //    window.open(url, '_blank');
                    //}
                    else if (rptTitle == "IWPOS") {
                        debugger;
                        var oprator = ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");
                        var Items = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        var Procedure = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0");
                        var url = 'ReportViewer.aspx?ReportName=ItemWosePOSummary&ReportTitle=Item Wise PO Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Items=' + Items + '&ItemGroup=' + oprator + '&Vendor_ID=' + Procedure;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "MIR_summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=MIR_summary&ReportTitle=MIR Summary Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "SIN_summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=SIN_summary&ReportTitle=SIN Summary Report From   ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "MSR") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=MinimumStock&ReportTitle=Minimum Stock Report ' + '&Item=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == 'GRN_and_Item_Wise_Report') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GRN_and_Item_Wise_Report&ReportTitle= GRN & Item Wise Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepetID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DailyCashCollectionSummaryReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        $('#<%= YearDiv.ClientID %>').show();
                        $('#<%= MonthDiv.ClientID %>').show();
                        $('#<%= DateDiv.ClientID %>').hide();
                        $('#<%= Time_Row.ClientID %>').hide();
                        var selectedYear = $('#ctl00_MainContent_ddlYear').val();
                        var selectedMonth = $('#ctl00_MainContent_ddlMonth').val();

                        if (selectedYear === "0") {
                            alert('Please select a year');
                            return;
                        }
                        if (selectedMonth === "0") {
                            alert('Please select a month');
                            return;
                        }
                        var url = 'ReportViewer.aspx?ReportName=DailyCashCollectionSummary&ReportTitle=Pharmacy Overall Summary Report FY' + '&Year=' + selectedYear + '&Month=' + selectedMonth + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "PharmacySaleReport") {
                        debugger;
                        //var summary = $('#chkSummary').prop('checked') ? "true" : "false";
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val());
                        var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());
                        var sSDate = sDate.getDay();
                        var eEDate = eDate.getDay();
                        var url = 'ReportViewer.aspx?ReportName=PharmacySaleReport&ReportTitle=Pharmacy Sale Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' + eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Summary=' + summary + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');

                    }

                    else if (rptTitle == "InPatientPharmacySaleReport") {
                         debugger;
                         
                         
                         var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                         var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val());
                         var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());
                         var sSDate = sDate.getDay();
                         var eEDate = eDate.getDay();
                         var url = 'ReportViewer.aspx?ReportName=InPatientPharmacySaleReport&ReportTitle=Pharmacy Sale Report from ' +
                             $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' +
                             sSDate + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' +
                             eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() +
                             '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() +
                             '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") +
                             '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                             '&ExportPDF=' + exporttopdf;
                         window.open(url, '_blank');

                           }

                    else if (rptTitle == "PharmacySaleReport_PaymentWise") {
                        debugger;
                        var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val());
                        var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());
                        var sSDate = sDate.getDay();
                        var eEDate = eDate.getDay();
                        var url = 'ReportViewer.aspx?ReportName=PharmacySaleReport_PaymentWise&ReportTitle=Pharmacy Sale Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' + eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Payment_Type=' + $('#ctl00_MainContent_ddlPaymentType').val();
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "ManufacturerWiseStockInHand") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var manufacturer = $('#ctl00_MainContent_ddlDepartments').val();
                        var itemName = $('#ctl00_MainContent_ddlItemName').val();
                        var warehouse = $('#ctl00_MainContent_ddlwareHouse').val();
                        var url = 'ReportViewer.aspx?ReportName=ManufacturerWiseStockInHand&ReportTitle=' + encodeURIComponent('Manufacturer Wise Stock in Hand as on ' + endDate) + '&ItemName=' + encodeURIComponent(itemName) + '&Manufacturer=' + encodeURIComponent(manufacturer) + '&Warehouse=' + encodeURIComponent(warehouse) + '&EndDate=' + encodeURIComponent(endDate) + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "CathLabStockInHand") {
                        var stock = $("#ctl00_MainContent_ddlStock").val();
                        debugger;
                        var asOn = $('#cbHideStartDate').is(':checked');
                        var startDateTime = asOn ? '01-Jul-2020 12:00 AM' : ($('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val());
                        var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val());
                        var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());
                        var sSDate = sDate.getDay();
                        var eEDate = eDate.getDay();
                        var url = 'ReportViewer.aspx?ReportName=CathLabStockDetail&ReportTitle=Cath Lab Stock in Hand ' + (asOn ? 'as on ' : 'Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + ' to ') + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' + eEDate + '&StartDateTime=' + startDateTime + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&stock=' + stock + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val();
                        window.open(url, '_blank');

                    }

                    else if (rptTitle == "GroupTestsRateList") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        //var pat_type = $('#ctl00_MainContent_ddlPatientType').val();
                        var pat_type = ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != '0') ? $("#ctl00_MainContent_ddlPatientType").val() : "0");
                        var url = 'ReportViewer.aspx?ReportName=GroupMainTestDepartments&ReportTitle=Group Main Test Departments from ' + '&Main_Department=' + timeLine + '&Patient_Type=' + pat_type + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "OutPatientsINP") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OutPatientsINP&ReportTitle=BloodIssuanceReport from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "BloodBankStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodBankStockLedger&ReportTitle=Blood Bank Stock Ledger  summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Patient_Trans_SehatSahulatCard") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail_SehatSahulatCard&ReportTitle= Sehat Sahulat Card Patient Invoice &MRNo=' + $('#ctl00_MainContent_txtMR_No').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }


                    else if (rptTitle == "WholeBloodStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=WholeBloodStockLedger&ReportTitle=Whole Blood Stock Ledger Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "TestsRateList") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var NewLine = $('#ctl00_MainContent_ddlProcedure').val();
                        var url = 'ReportViewer.aspx?ReportName=MainTestDepartments&ReportTitle=Main Test Departments from ' + '&Main_Department=' + timeLine + '&Patient_Type=' + NewLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Procedure_Service_List') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var url = 'ReportViewer.aspx?ReportName=Procedure_Service_List&ReportTitle=Procedure Service List &Report_Type=' + "01" + '&Company=' + ((typeof ($("#ctl00_MainContent_ddlCompdrop option:selected").val()) != 'undefined') ? $("#ctl00_MainContent_ddlCompdrop option:selected").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "Blood_Bank_Cash_Collection_Details") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Blood_Bank_Cash_Collection_Details&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'TotalOpdDischargeReport') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TotalOpdDischargeReport&ReportTitle=Total Opd Discharge Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Non_Cash_Blood_Bank_Revenue") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=NonCashBloodBankRevenue&ReportTitle=LabCashReceivingCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect").val()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Patient_Wise_Panel') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=InsuranceCompanies&ReportTitle=Patient Wise Insurance Companies Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + timeLine + '&PanelCompanies=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "ComponentBloodStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Component = $("#ctl00_MainContent_ddlMainDepartment").val();
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ComponentBloodStockLedger&ReportTitle=Blood Bank Present Patient Stock Record from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&Component=' + Component + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "LabResultPending") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=LabResultPending&ReportTitle=Lab Result Pending from ' + $('#ctl00_MainContent_txtStart_Date').val() + '  ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '  ' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Bed_Occupancy') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BedOccupancy&ReportTitle=Bed Occupancy from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'TotalpatientsandRevisitpatientsreport') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var url = 'ReportViewer.aspx?ReportName=TotalpatientsandRevisitpatientsreport&ReportTitle=Total Patients and Rvisit Patients from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "StudentAttendanceList") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=StudentAttendanceList&ReportTitle=Student Attendance List Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Program=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&Class=' + $('#ctl00_MainContent_ddlMedicalSubsidy').val() + '&Batch=' + $('#ctl00_MainContent_ddlTestResult').val() + '&Group=' + $('#ctl00_MainContent_ddlProcedure').val() + '&Subject=' + $('#ctl00_MainContent_ddlDepartments').val() + '&SubSubject=' + $('#ctl00_MainContent_oprators').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "SubjectWiseAttendance") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=SubjectWiseAttendance&ReportTitle=Subject Wise Student Attendance List Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Program=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&Class=' + $('#ctl00_MainContent_ddlMedicalSubsidy').val() + '&Batch=' + $('#ctl00_MainContent_ddlTestResult').val() + '&Group=' + $('#ctl00_MainContent_ddlProcedure').val() + '&Subject=' + $('#ctl00_MainContent_ddlDepartments').val() + '&SubSubject=' + $('#ctl00_MainContent_oprators').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "AttendancePercentage") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=AttendancePercentage&ReportTitle=Student Attendance Percentage Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Program=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&Class=' + $('#ctl00_MainContent_ddlMedicalSubsidy').val() + '&Batch=' + $('#ctl00_MainContent_ddlTestResult').val() + '&Group=' + $('#ctl00_MainContent_ddlProcedure').val() + '&Subject=' + $('#ctl00_MainContent_ddlDepartments').val() + '&SubSubject=' + $('#ctl00_MainContent_oprators').val();
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "PatientsTypesDetails") {
                        debugger;

                       // var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        //Mohsin: 25 JULY WEDNESDAY, the report doesnot exists front and back end donot match.
                        //var url = 'ReportViewer.aspx?ReportName=PatientsTypesDetails&ReportTitle=Patients Category Wise OPD Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&PatientType=' + $('#ctl00_MainContent_lblMultiSelect').val() + '&ALLValues=' + Allvalues + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        var url = 'ReportViewer.aspx?ReportName=PatientsTypesDetails&ReportTitle=Patients Category Wise OPD Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val();
                        //Mohsin
                        window.open(url, '_blank');
                    }


                    else if (rptTitle == 'SehatSahulatWise') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=SehatSahulatWise&ReportTitle=Patient Sehat Sahulat Card Receivable Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'SehatSahulatWiseExpensive') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=SehatSahulatWiseExpensive&ReportTitle=Patient Sehat Sahulat Card Expense Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "CBloodBankStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Component = $("#ctl00_MainContent_ddlMainDepartment").val();
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=CBloodBankStockLedger&ReportTitle=  ' + $("#ctl00_MainContent_ddlMainDepartment option:selected ").text() + '    summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&Component=' + Component + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }




                    else if (rptTitle == "Lab_Test_Investigation") {
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Investigation&ReportTitle=Lab Test Investigation from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&TestCatagory=' + $('#ctl00_MainContent_ddlcatagory').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    // inserting the investigation delay report 

                    else if (rptTitle == "BloodResultPending") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=BloodResultPending&ReportTitle=Blood  Bank Result Pending from ' + $('#ctl00_MainContent_txtStart_Date').val() + '  ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '  ' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Services_List") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Services_List&Show_Rate=' + $('#chkShowRate').is(':checked') + '&ExportPDF=' + exporttopdf + '';
                        window.open(url, '_blank');
                    }


                    else if (rptTitle == 'AverageLengthOfStay') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=AverageLengthOfStay&ReportTitle=Average Length Of Stay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'TestWiseMonthly') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthly&ReportTitle=Test Wise Monthly from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
<%--                    else if (rptTitle == 'IPD_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=IPDTimeLine&ReportTitle=IPD Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }--%>
                    else if (rptTitle == "IPD_Time_Line") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=IPDTimeLine' +
                            '&ReportTitle=' + encodeURIComponent('IPD Time Line from ' + startDateTime + ' to ' + endDateTime) +
                            '&Report_Type=' + encodeURIComponent(timeLine) +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime);

                        window.open(url, '_blank');
                    }
                <%--    else if (rptTitle == 'TestWiseMonthlyLabTestDepartment') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthlyLabTestDepartment&ReportTitle=Test Wise Monthly from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepetID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }--%>
                    else if (rptTitle == 'ReceiptCollectionReport') {
                        window.location.href = 'ReportViewer.aspx?ReportName=ReceiptCollectionReport&ReportTitle=Receipt Collection Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                    }
                    else if (rptTitle == 'CancelBill') {
                        window.location.href = 'ReportViewer.aspx?ReportName=CancelBill&ReportTitle=Cancel Bills from ' + $('#ctl00_MainContent_txtsDate').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                    }
                    else if (rptTitle == 'AdvanceReport') {
                        window.location.href = 'ReportViewer.aspx?ReportName=AdvanceReport&ReportTitle=Advance Payment Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                    }
                    else if (rptTitle == 'RefundReport') {

                        var deptValue = $("#ctl00_MainContent_ddlMedicalSubsidy").val();

                        var url = 'ReportViewer.aspx?ReportName=RefundReport&ReportTitle=Refund Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Department=' + deptValue + '&DoctorID=' + $("#ctl00_MainContent_ddlDoctor").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
            <%--        else if (rptTitle == 'Discharge_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DischargeTimeLine&ReportTitle=Discharge Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }--%>
                    else if (rptTitle == 'Ward_Allocation_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=WardAllocationTimeLine&ReportTitle=Ward Allocation Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Procedure_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ProcedureTimeLine&ReportTitle=Procedure Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'DepartmentWiseProcedureTimeLine') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentWiseProcedureTimeLine&ReportTitle=Department Wise Procedure Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Patient_Trans_Detail") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail&ReportTitle=Patient Transaction Detail From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MRNo=' + patid;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Patient_Trans_Detail_Type") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail_Type&ReportTitle=Insurance Patient Invoice&MRNo=' + $('#ctl00_MainContent_txtMR_No').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Lab_Test_Investigation_Delay") {
                        var deptValue = $("#ctl00_MainContent_ddlDepartments").val();
                        //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Investigation_Delay&ReportTitle=Lab Test Investigation Delay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + deptValue; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Radiology_Investigation_Delay") {
                        //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var deptValue = $("#ctl00_MainContent_ddlDepartments").val();
                        var url = 'ReportViewer.aspx?ReportName=Radiology_Investigation_Delay&ReportTitle=Radiology Investigation Delay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + deptValue; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Lab_Cash_Collection") {
                       //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=LabCashCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Service_Wise_Summary_Report") {
                       //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=Service_Wise_Summary_Report&ReportTitle=Service Wise Summary from  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ($("#ctl00_MainContent_ddlDepartments").val() || "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Receipt_Operator_Wise_Report") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var DetailedSummary = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Receipt_Operator_Wise_Report&ReportTitle=Operator Wise Receipts Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&AllPatientsRecords=' + DetailedSummary + '&ExportPDF=' + exporttopdf; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Operator_Wise_Billing_Report") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var DetailedSummary = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Operator_Wise_Billing_Report&ReportTitle=Operator Wise Billing Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&AllPatientsRecords=' + DetailedSummary + '&ExportPDF=' + exporttopdf; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Operator_Wise_Final_Billing_Report") {
                        
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        
                        var url = 'ReportViewer.aspx?ReportName=Operator_Wise_Final_Billing_Report&ReportTitle=Operator Wise Final IPD Billing Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Excessive_Amount_Billing_Report") {
                        
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Excessive_Amount_Billing_Report&ReportTitle=Operator Wise Billing Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&ExportPDF=' + exporttopdf; //+ '&Summary=' + summary ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Blood_Bank_Lab_Test_Details") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=BloodBankLabTest_Details&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "BloodIssuance") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodIssuance&ReportTitle=BloodIssuanceReport from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Lab_Test_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=LabTestDetailCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Summary=' + summary + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                   <%-- else if (rptTitle == "RadiologyReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }--%>
                    else if (rptTitle == "RadiologyReport") {
                        debugger;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        //var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var testname = $("#ctl00_MainContent_ddlTestName").val() || "0";
                        testname = encodeURIComponent(testname);
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Extended_RadiologyReport") {
                        debugger;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        //var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var testname = $("#ctl00_MainContent_ddlTestName").val() || "0";
                        testname = encodeURIComponent(testname);
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Extended_RadiologyReport_Panel") {
                        debugger;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        //var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var testname = $("#ctl00_MainContent_ddlTestName").val() || "0";
                        testname = encodeURIComponent(testname);
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport_Panel&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Panel=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Panel_wise_Billing_Report") {
                        debugger;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        //var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var testname = $("#ctl00_MainContent_ddlTestName").val() || "0";
                        testname = encodeURIComponent(testname);
                        var url = 'ReportViewer.aspx?ReportName=Panel_wise_Billing_Report&ReportTitle=Panel Wise Billing Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Panel=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "AnalysisReport") {
                        debugger;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var url = 'ReportViewer.aspx?ReportName=AnalysisReport&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&testName=' + testname + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    //else if (rptTitle == "AnalysisReport") {
                    //    var tests = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0");
                    //    var url = 'ReportViewer.aspx?ReportName=AnalysisReport&ReportTitle=Analysis Report from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_oprators").val()) != 'undefined') ? $("#ctl00_MainContent_oprators").val() : "0") + '&Tests=' + tests + '&ExportPDF=' + exporttopdf;
                    //    window.open(url, '_blank');
                    //}
                    else if (rptTitle == "Sale_Return_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Sale_Return_Report&ReportTitle=Sale Return Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Sale_Report_Summary") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Sale_Report_Summary&ReportTitle=Sale Report Summary From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Lab_Test_Wise_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Wise_Summary&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Patient_Wise_Lab_Test_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Patient_Wise_Lab_Test_Summary&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&MRNo=' + (patid || 0) + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Radiology_Test_Wise_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Radiology_Test_Wise_Summary&ReportTitle=Radiology Test Wise Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + $("#ctl00_MainContent_ddlMainDepartment").val() + '&testName=' + $('#ctl00_MainContent_ddlTestName').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Lab_Test_Patient_Wise") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Patient_Wise&ReportTitle=Lab Tests Patient Wise from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Dischare_Revd") {
                        debugger;
                        var ddlShift = ((typeof ($("#ctl00_MainContent_ddlShift").val()) != 'undefined') ? $("#ctl00_MainContent_ddlShift").val() : "0");
                        var ddlDoctor = ((typeof ($("#ctl00_MainContent_ddlDoctor").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDoctor").val() : "0");
                        var Procedure = ((typeof ($("#ctl00_MainContent_oprators").val()) != 'undefined') ? $("#ctl00_MainContent_oprators").val() : "0");

                        //var sDate = new Date($("#ctl00_MainContent_txtsDate").val());
                        //var eDate = new Date($("#ctl00_MainContent_txteDate").val());
                        //var sSDate = weekday[sDate.getDay()];
                        //var eEDate = weekday[eDate.getDay()];

                        var url = 'ReportViewer.aspx?ReportName=DischargeReceived&ReportTitle= Discharge Received Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Shift=' + ddlShift + '&Doctor=' + ddlDoctor + '&Procedure=' + Procedure;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "Lab_Department_Wise_Summary") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=LabDepartmentWiseSummary&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Patient_Type=' + $('#ctl00_MainContent_ddlPatientType').val();   //'&testName=' + 'All' +
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Test_Result_Status") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestResultStatus&ReportTitle=Test Result Status from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&serviceID=' + ((typeof ($("#ctl00_MainContent_ddlTestResult").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestResult").val() : "0") + '&ExportPDF=' + exporttopdf; /*+ '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked*/
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Total_Income') {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=TotalIncome&ReportTitle=Report Total Income from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Lab_Log_Report') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Lab_Log_Report&ReportTitle=Lab Log Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Final_Sign_By=' + ((typeof ($("#ctl00_MainContent_ddlDoctor").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDoctor").val() : "0") + '&BillingDoctor=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&PerformingDoctor=' + ((typeof ($("#ctl00_MainContent_ddlcashier").val()) != 'undefined') ? $("#ctl00_MainContent_ddlcashier").val() : "0") + '&Category=' + $("#ctl00_MainContent_ddlMainDepartment").val() + '&Acknowledged_By=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&Prelim_BY=' + ((typeof ($("#ctl00_MainContent_ddlcatagory").val()) != 'undefined') ? $("#ctl00_MainContent_ddlcatagory").val() : "0") + '&Referring_Consultant=' + ((typeof ($("#ctl00_MainContent_ddlReportType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlReportType").val() : "0") + '&Test_Departement=' + ((typeof ($("#ctl00_MainContent_ddlSubDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlSubDepartment").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Student_Fee_Details_Report') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Fee_Details_Report&ReportTitle=Student Wise Receivable from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Roll_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Fee_Details_Class_Report') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Fee_Details_Class_Report&ReportTitle=Student Wise Receivable from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Class_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Fee_Details_Session_Report') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Fee_Details_Session_Report&ReportTitle=Student Session Wise Fee Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Session=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Details_Report_Received') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Details_Report_Received&ReportTitle=Student Wise Receipts from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Roll_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Details_Report_Balance') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Details_Report_Balance&ReportTitle=Student Wise Receipts Details Balance from' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Roll_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Class_Details_Report_Received') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Class_Details_Report_Received&ReportTitle=Student Class Wise Receipts Details from' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Class_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Class_Details_Report_Balance') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Class_Details_Report_Balance&ReportTitle=Student Receipt Class Wise Details Balance from' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Class_No=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Session_Details_Report_Received') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Session_Details_Report_Received&ReportTitle=Student Session Wise Fee Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Session=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Student_Receipt_Session_Details_Report_Balance') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Student_Receipt_Session_Details_Report_Balance&ReportTitle=Student Session Wise Fee Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Session=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Pharmacy_Profit_and_Loss_Report') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        //    window.location.href = 'ReportViewer.aspx?ReportName=Pharmacy_Profit_and_Loss_Report&ReportTitle=Pharmacy Profit and Loss from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        var url = 'ReportViewer.aspx?ReportName=Pharmacy_Profit_and_Loss_Report&ReportTitle=Pharmacy Profit and Loss from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Lab_Cash_Receiving_Collection") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=LabCashReceivingCollection&ReportTitle=LabCashReceivingCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect").val()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Service_Charges_Detail') {

                        var url = 'ReportViewer.aspx?ReportName=ServiceChargesDetail&ReportTitle=Service Charges Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlTestName').val() + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");// + '&Summary=' + summary + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'ConsolidateMedicalSubsidy') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var AllPatientRecords = $('#AllPatientsRecords')[0].checked;
                        var url = 'ReportViewer.aspx?ReportName=ConsolidateMedicalSubsidy&ReportTitle=Consolidate Medical Subsidy from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&PatientType=' + $('#ctl00_MainContent_lblMultiSelect').val() + '&ALLValues=' + Allvalues + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&AllPatientRecords=' + AllPatientRecords + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlTestName').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "Procedure_List") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var transType = '';
                        var ProcedureType = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        if ($('#chkOPD').is(':checked') == true && $('#chkIPD').is(':checked') == true) {
                            transType = '0';
                        }
                        else {
                            if ($('#chkOPD').is(':checked') == true) {
                                transType = 'OPD';
                            }
                            else {
                                transType = 'IPD';
                            }
                        }
                        var url = 'ReportViewer.aspx?ReportName=Procedure_Detail&Trans_Type=' + transType + '&Procedure_Type=' + ProcedureType + '&Show_Rate=' + $('#chkShowRate').is(':checked') + '&ExportPDF=' + exporttopdf + '';
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Private_Procedure_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PrivateProcedureDetail&ReportTitle=Private Procedure Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'OPDPrivateDetail') {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var AllPatientRecords = $('#AllPatientsRecords')[0].checked;
                        var url = 'ReportViewer.aspx?ReportName=OPDPrivateDetail&ReportTitle=OPD Private Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&ExportPDF=' + exporttopdf + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&AllPatientRecords=' + AllPatientRecords + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'HospitalServices') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=HospitalServices&ReportTitle=Hospital Services from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Patient_Type=' + $("#ctl00_MainContent_ddlDepartments").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlPatientType').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Daily_Revenue') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DailyRevenue&ReportTitle=Daily Revenue from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Department_Wise_Cash_Summary') {
                        var url = 'ReportViewer.aspx?ReportName=DepartmentWiseCashSummary&ReportTitle=Department Wise Cash Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0");
                        window.open(url, '_blank');
                    }
                    <%--else if (rptTitle == "OPD_Detail_Report") {
                        debugger;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OPDDetailReport&ReportTitle=OPD Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Summary=' + summary + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }--%>
                    else if (rptTitle == "OPD_Detail_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var filterclinic = $("#ctl00_MainContent_ddlFilterClinic").val();
                        // Combine date + time into single strings (as your backend expects)
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var doc = $('#ctl00_MainContent_ddlDoctor').val();

                        var url = 'ReportViewer.aspx?ReportName=OPDDetailReport' +
                            '&ReportTitle=OPD Detail Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&Summary=' + summary +
                            '&FilterClinic=' + filterclinic +
                            '&DoctorID=' + doc + 
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0")
                            + '&ExportPDF=' + exporttopdf;

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Emergency_Detail_Report") {
                        debugger;

                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        // Combine date + time
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var doc = $('#ctl00_MainContent_ddlDoctor').val();

                        var url = 'ReportViewer.aspx?ReportName=EmergencyDetailReport' +
                            '&ReportTitle=Emergency Detail Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&Summary=' + summary +
                            '&DoctorID=' + doc +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlOperator").val()) != 'undefined')
                                ? $("#ctl00_MainContent_ddlOperator").val()
                                : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined')
                                ? $("#ctl00_MainContent_ddlDepartments").val()
                                : "All") +
                            '&ExportPDF=' + exporttopdf;

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "OPD_Department_Wise_Report") {
                        debugger;
                        //   var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                     var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var ddlShift = $("#ctl00_MainContent_ddlShift option:selected").text();
                        // Combine date + time into single strings (as your backend expects)
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=OPD_Department_Wise_Report' +
                            '&ReportTitle=Department Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                       //     '&Summary=' + summary +
                            '&Summary=' + summary +
                            '&Shift=' + encodeURIComponent(ddlShift) +
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0")+
                            '&PatientType=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0")+
                            '&ExportPDF=' + exporttopdf;

                            window.open(url, '_blank');
                    }
                    else if (rptTitle == "PCRS") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var Procedure = ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        var url = 'ReportViewer.aspx?ReportName=PCRS&ReportTitle=Pharmacy Cash Report Summary from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) + '&Item=' + $("#ctl00_MainContent_ddlMainDepartment").val() + '&Operator=' + Procedure + '&Company=' + $("#ctl00_MainContent_ddlDepartments").val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val();// + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Consultant_Wise_Statistics") {

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Consultant_Wise_Statistics' +
                            '&ReportTitle=Consultant Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val();
                      
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Counsltant_Day_Wise_report") {

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Counsltant_Day_Wise_report' +
                            '&ReportTitle=Consultant Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val();
                      
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Department_Wise_Statistics") {

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Department_Wise_Statistics' +
                            '&ReportTitle=Department Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime);
        
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "DoctorWiseUltrasoundReport") {
                        debugger;
                     //   var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        // Combine date + time into single strings (as your backend expects)
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=DoctorWiseUltrasoundReport' +
                            '&ReportTitle=Department Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&DoctorID=' + $('#ctl00_MainContent_ddloprators').val();

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Over_Summary_Shift_Wise") {
                        debugger;
                     //   var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var ddlShift = $("#ctl00_MainContent_ddlShift option:selected").text();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Over_Summary_Shift_Wise' +
                            '&ReportTitle=Over Summary Shift Wise Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                       //     '&Summary=' + summary +
                            '&Shift=' + encodeURIComponent(ddlShift) +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "ActiveItems") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var status = $('#ctl00_MainContent_ddlStatus').val();
                        var itemFilter = $('#ctl00_MainContent_ddlItemFilter').val();


                        var url = 'ReportViewer.aspx?ReportName=ActiveItems' +
                            '&ReportTitle=Active Inventory Items Report from ' +
                            '&Status=' + status +
                            '&ItemFilter=' + itemFilter +
                            '&ExportPDF=' + exporttopdf;

                        window.open(url, '_blank');
                    }

                    //else if (rptTitle == "DepartmentWiseReport") {
                    //    debugger;
                    //    var ddlShift = $("#ctl00_MainContent_ddlShift option:selected").text();
                    //    var ddDoctor = $("#ctl00_MainContent_ddlDoctor").val();
                    //    var sDate = new Date($("#ctl00_MainContent_txtsDate").val());
                    //    var eDate = new Date($("#ctl00_MainContent_txteDate").val());
                    //    var sSDate = weekday[sDate.getDay()];
                    //    var eEDate = weekday[eDate.getDay()];
                    //    window.location.href = 'ReportViewer.aspx?ReportName=DepartmentWiseReport&ReportTitle=OPD Detail Report from ' + $('#ctl00_MainContent_txtsDate').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + '  to ' + $('#ctl00_MainContent_txteDate').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '  ' + eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtsDate').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txteDate').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + $('#chkSummary')[0].checked + '&Shift=' + ddlShift + '&DoctorName=' + ddDoctor + '&Operator=' + ((typeof ($("#ctl00_MainContent_oprators").val()) != 'undefined') ? $("#ctl00_MainContent_oprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");
                    //}
                    else if (rptTitle == "DepartmentWiseReport") {
                        debugger;
                        var weekday = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]; // Define weekday
                        var ddlShift = $("#ctl00_MainContent_ddlShift option:selected").text();
                        var ddDoctor = $("#ctl00_MainContent_ddlDoctor").val();
                        var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val()); // Fixed ID
                        var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());   // Fixed ID
                        var sSDate = weekday[sDate.getDay()];
                        var eEDate = weekday[eDate.getDay()];
                        window.location.href = 'ReportViewer.aspx?ReportName=DepartmentWiseReport&ReportTitle=OPD Detail Report from ' +
                            $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + '  to ' +
                            $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '  ' + eEDate +
                            '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() +
                            '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() +
                            '&Summary=' + $('#chkSummary')[0].checked +
                            '&Shift=' + encodeURIComponent(ddlShift) +
                            '&DoctorName=' + encodeURIComponent(ddDoctor) +
                            '&Operator=' + ($("#ctl00_MainContent_ddloprators").val() || "0") + // Fixed ID
                            '&Department=' + ($("#ctl00_MainContent_ddlDepartments option:selected").text() || "0") +
                            '&Discount=' + ($("#ctl00_MainContent_ddlMedicalSubsidy").val() || "0");
                    }
 <%--                   else if (rptTitle == "IPD_Detail_Report") {
                        debugger;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=IPDDetailReport&ReportTitle=IPD Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }--%>

                    else if (rptTitle == "IPD_Detail_Report") {
                        debugger;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        // Combine date + time into single strings (as your backend expects)
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=IPDDetailReport' +
                            '&ReportTitle=IPD Detail Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&Summary=' + summary +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&ExportPDF=' + exporttopdf;

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Emer_Detail_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=EmerDetailReport&ReportTitle=Emergency Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Emergency_Reg_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Emergency_Reg_Report&ReportTitle=Emergency Registration Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "OPD_Time_Line") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=OPD_Time_Line' +
                            '&ReportTitle=' + encodeURIComponent('OPD Time Line from ' + startDateTime + ' to ' + endDateTime) +
                            '&Report_Type=' + encodeURIComponent(timeLine) +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime);

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Emergency_Time_Line") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Emergency_Time_Line' +
                            '&ReportTitle=' + encodeURIComponent('Emergency Time Line from ' + startDateTime + ' to ' + endDateTime) +
                            '&Report_Type=' + encodeURIComponent(timeLine) +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime);

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Discharge_Time_Line") {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=DischargeTimeLine' +
                            '&ReportTitle=' + encodeURIComponent('Discharge Time Line from ' + startDateTime + ' to ' + endDateTime) +
                            '&Report_Type=' + encodeURIComponent(timeLine) +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime);

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "APL") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ActivePatientList&ReportTitle=Active Patient List Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + $("#ctl00_MainContent_ddlDepartments option:selected").val() + '&FilterClinic=' + $("#ctl00_MainContent_ddlFilterClinic").val() + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "APLS") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ActivePatientListSummary&ReportTitle=Active Patient List Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + $("#ctl00_MainContent_ddlDepartments option:selected").val() + '&FilterClinic=' + $("#ctl00_MainContent_ddlFilterClinic").val() + '&Doctor=' + $("#ctl00_MainContent_ddlDoctor").val() + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "AL") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=AppointmentList&ReportTitle=Appointment List Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Doctor=' + $("#ctl00_MainContent_ddlDoctor").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "PatientLedger") {
                        debugger;    // excluded : + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() 
                        var url = 'ReportViewer.aspx?ReportName=PatientLedger&ReportTitle=Patient Ledger Report fr+om ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + $("#ctl00_MainContent_ddlDepartments option:selected").val() + '&FilterClinic=' + $("#ctl00_MainContent_ddlFilterClinic").val() + '&Doctor=' + $("#ctl00_MainContent_ddlDoctor").val() + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "SinglePatientLedger") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=SinglePatientLedger&ReportTitle=Single Patient Ledger Report ' + '&MrNo=' + patid;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'RDW') {
                        ////////var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=RevenueDepartmentWise&ReportTitle=Revenue Department Wise Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Cashier=' + $("#ctl00_MainContent_ddlcashier").val() + '&Patient_Type=' + $("#ctl00_MainContent_ddlDepartments option:selected").val();  // + '&Summary=' + summary 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "RevenuseSummary") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=RevenuseSummary&ReportTitle=Revenuse Department Wise Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "RevenuseCardFee") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=RevenuseCardFee&ReportTitle=Patient Reg Fee Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Head_Wise_Discount_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Head_Wise_Discount_Report&ReportTitle=Head Wise Discount from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "TimeAndMotion") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=TimeAndMotion&ReportTitle=Time and Motion Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DailySaleSummary") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Daily_Sale_Summary&ReportTitle=Daily Sale Summary Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Item_Wise_Gross_Profit_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Item_Wise_Gross_Profit&ReportTitle=Item Wise Gross Profit Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Category_Wise_Profitability_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Category_Wise_Profitability_Report&ReportTitle=Category Wise Profit Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Category=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Fast_Slow_Non_Moving_Stock") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var movementType = $("#ctl00_MainContent_ddlMovementType").val();
                        var Item = $("#ctl00_MainContent_ddlMainDepartment").val();
                        var url = 'ReportViewer.aspx?ReportName=FastSlow_Non_Moving_Stock&ReportTitle=Stock Movement Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&ItemID=' + Item + '&MovementType=' + movementType + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf ;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "PharmacyStockDetail") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=PharmacyStockDetail&ReportTitle=Pharmacy Stock in Hand Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Pharmacy_Customer_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Pharmacy_Customer_Report&ReportTitle=Customer Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf; 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Physiotherapy_Cash_Collection") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Physiotherapy_Cash_Collection&ReportTitle=Physiotherapy Cash Collection Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Item_Wise_Margin_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Item_Wise_Margin_Report&ReportTitle=Item Wise Margin Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Item_Wise_Purchase_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Item_Wise_Purchase_Report&ReportTitle=Item Wise Purchase Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Cardiology_Cash_Collection") {
                        debugger;
                        var selectedName = $("#<%= ddlDepartments.ClientID %>").val();
                        //var selectedTestID = $("#<%= ddlDepartments.ClientID %>").val();
                        var url = 'ReportViewer.aspx?ReportName=Cardiology_Cash_Collection&ReportTitle=Cardiology Cash Collection Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&TestName=' + encodeURIComponent(selectedName); // ← Sending NAME //'&TestID=' + encodeURIComponent(selectedTes;  //  //  // '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "PCR") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=PCR&ReportTitle=Pharmacy Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MRNo=' + (patid || 0) + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val();   
                        window.open(url, '_blank');
                    }
                    //else if (rptTitle == "PCRS") {
                    //    debugger;
                    //    var url = 'ReportViewer.aspx?ReportName=PCRS&ReportTitle=Pharmacy Cash Report Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                    //    window.open(url, '_blank');
                    //}
                    else if (rptTitle == "DoctorMS") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=DoctorMS&ReportTitle=Doctorwise Medicine Sales Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Doctor=' + $("#ctl00_MainContent_ddlDoctor").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DoctorMSS") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=DoctorMSS&ReportTitle=Doctorwise Medicine Sales Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Dept=' + $("#ctl00_MainContent_ddlDoctor").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DMS") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=DMS&ReportTitle=Department Wise Medicine Sales Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Dept=' + $("#ctl00_MainContent_ddlDepartments").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DMSS") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=DMSS&ReportTitle=Department Wise Medicine Sales Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Dept=' + $("#ctl00_MainContent_ddlDepartments").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "ITR") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ITR&ReportTitle=Inventory Track Report ' + '&invForm=' + $("#ctl00_MainContent_ddlInvForm").val() + '&invNo=' + $("#ctl00_MainContent_ddlInvNo").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "MER") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=MER&ReportTitle=Medicine Expiry Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "CathLab_MER") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=CathLab_MER&ReportTitle=Cath Lab Medicine Expiry Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "StockValuationReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var itemgroup = ($("#ctl00_MainContent_ddlPatientType").val());
                        var url = 'ReportViewer.aspx?ReportName=StockCategoryValuationReport&ReportTitle=Stock Valuation Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&itemgroup=' + itemgroup + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "IGP_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Inward_Gate_Pass_Report&ReportTitle=Inward Gate Pass Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Asset_Register_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Asset_Register_Report&ReportTitle=Fixed Asset Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&AssetName=' + ($("#ctl00_MainContent_ddlProcedure").val() || "0") + '&Department=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Category=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Asset_Ageing_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Asset_Ageing_Report&ReportTitle=Asset Ageing Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&AssetName=' + ($("#ctl00_MainContent_ddlProcedure").val() || "0") + '&Status=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Category=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Asset_Depreciation_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Asset_Depreciation_Report&ReportTitle=Asset Depreciation Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&AssetName=' + ($("#ctl00_MainContent_ddlProcedure").val() || "0") + '&Category=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Asset_Acquisition_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Asset_Acquisition_Report&ReportTitle=Asset Acquisition Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&AssetName=' + ($("#ctl00_MainContent_ddlProcedure").val() || "0") + '&Category=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Stock_Transfer_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Stock_Transfer_Report&ReportTitle=Stock Transfer Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&FromWarehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ToWarehouse=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "PurchaseReturnReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PurchaseReturnReport&ReportTitle=Purchase Return Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Department_Conversion') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentConversion&ReportTitle=Department Conversion from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '' + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Departmentwise_Cash_Summary') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentwiseCashSummary&ReportTitle=Departmentwise Cash Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Bed_Allocation_Report') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BedAllocationReport&ReportTitle=Bed Allocation Report&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '';
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Package_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PackageDetailReport&ReportTitle=Package Detail Procedures Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&MedicalSubsidy=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "OutSourceTestDetail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OutSourceTestDetail&ReportTitle=Out Sourcer From ' + $('#ctl00_MainContent_txtStart_Date').val() + '&tetsDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }


                    else if (rptTitle == "Blood_Bank_Cash_Collection") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodBankCashCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Procedure_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ProcedureDetail&ReportTitle=Procedure Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&MedicalSubsidy=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
  <%--                  else if (rpttitle == 'Procedure_Time_Line_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'reportviewer.aspx?reportname=proceduretimelinedetail&reporttitle=procedure time line detail report from ' + $('#ctl00_maincontent_txtstart_date').val() + ' to ' + $('#ctl00_maincontent_txtend_date').val() + '&startdatetime=' + $('#ctl00_maincontent_txtstart_date').val() + '&enddatetime=' + $('#ctl00_maincontent_txtend_date').val() + '&department=' + $("#ctl00_maincontent_ddldepartments").val() + '&procedurename=' + $("#ctl00_maincontent_ddlitemname").val() + '&proceduretype=' + $("#ctl00_maincontent_ddlprocedure").val() + '&maindepartment=' + $("#ctl00_maincontent_ddopdipddiv").val() + '&patienttype=' + ((typeof ($("#ctl00_maincontent_ddlpatienttype option:selected").text()) != 'undefined') ? $("#ctl00_maincontent_ddlpatienttype option:selected").text() : "0") + '&exportpdf=' + exporttopdf;
                        window.open(url, '_blank');
                    }--%>
                   else if (rptTitle == 'Procedure_Time_Line_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        //var mainDept = ($("#ctl00_MainContent_ddOPDIPDdiv").val() || "0");  // ✅ Safe fallback
                        var url = 'ReportViewer.aspx?ReportName=ProcedureTimeLineDetail' +
                            '&ReportTitle=Procedure Time Line Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() +
                            '&Department=' + ($("#ctl00_MainContent_ddlDepartments").val() || "0") +
                            '&ProcedureName=' + ($("#ctl00_MainContent_ddlItemName").val() || "0") +
                            '&ProcedureType=' + ($("#ctl00_MainContent_ddlProcedure").val() || "0") +
                            //'&MainDepartment=' + mainDept +
                            '&PatientType=' + (($("#ctl00_MainContent_ddlPatientType").val() != undefined) ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');  // ✅ Fixed: '_blank' not '_blank'
                    }
                    else if (rptTitle == 'PrivateAdmition_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PrivateAdmitionDetail&ReportTitle=Private Admition Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&ExportPDF=' + exporttopdf + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0");
                        window.open(url, '_blank');
                    }


                    else if (rptTitle == "Discharge_Time_Line_Detail") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Discharge Time Line Detail&ReportTitle=Discharge Time Line Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "ChargePolicyWiseSummary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ChargePolicyWiseSummary&ReportTitle=Charge Policy Wise Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Charge_Policy=' + ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == 'Admission_Detail') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var Patient_Type = ((typeof ($("#ctl00_MainContent_ddlProcedureoption:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlProcedure option:selected").text() : "0");
                        var url = 'ReportViewer.aspx?AdmissionDetail&ReportName=AdmissionDetail&ReportTitle=Admission Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&ExportPDF=' + exporttopdf + '&Patient_Type=' + Patient_Type + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Advance_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=AdvanceDetail&ReportTitle= Advance Detail Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'ReportVoucher') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ReportVoucher&ReportTitle= Report Voucher Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Patient_Count_Department_Wise') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Count_Department_Wise&ReportTitle= Department Wise Patients Count From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'TestWiseMonthlyLabTestDepartment') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthlyLabTestDepartment&ReportTitle=Lab Test Department Wise Monthly From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Stock_In_Hand_Detail') {
                        debugger;
                        var stock = $("#ctl00_MainContent_ddlStock").val();     // stock new 
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Stock_In_Hand_Detail&ReportTitle=Stock in Hand Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&stock=' + stock;    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Discharge_Detail") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Discharge_Detail&ReportTitle=Discharge Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '' + '&Patient_Type=' + $("#ctl00_MainContent_lblMultiSelect").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&MedicalSubsidy=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "DoctorShare_Report") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DoctorShare_Report&ReportTitle=Doctor Share Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&Operator=' + $("#ctl00_MainContent_ddloprators").val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val() + '&Summary=' + summary + '&ExportPDF=' + exporttopdf;  // excluded: + '&ExportPDF=' + exporttopdf    + '&Summary=' + summary 
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "IPDDoctorShareReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                       
                        var url = 'ReportViewer.aspx?ReportName=IPDDoctorShareReport&ReportTitle=Doctor Share Report from ' +
                            $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() +
                            ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() +
                            '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' +
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() +
                            '&Operator=' + $("#ctl00_MainContent_ddloprators").val() +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") +
                            '&PatientType=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0")+
                            '&ExportPDF=' + exporttopdf;  // excluded: + '&ExportPDF=' + exporttopdf    + '&Summary=' + summary 
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Patients_Investigation") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=rptPatientInvestigationBilling&ReportTitle=Department And Patient Investigation  Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&MainDeptID=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&TestID=' + $('#ctl00_MainContent_ddlTestName').val() + '&TransType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Doctor_ID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                     else if (rptTitle == "Patients_Receipts") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var allPatientRecord = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DeptWisePatients&ReportTitle=Department Wise and Patient Wise Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Shift=' + ddlShift  + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + allPatientRecord + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Doctotr_Receipts") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var allPatientRecord = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DoctorWisePatients&ReportTitle=Doctor Wise Patient from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Shift=' + ddlShift  + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + allPatientRecord + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                         
                    else if (rptTitle == "AllCash_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=AllCashReport&ReportTitle=All Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Hospital_Cash_Report') {
                        var url = 'ReportViewer.aspx?ReportName=HospitalCashReport&ReportTitle=Hospital Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blank');
                    }

                    if (rptTitle == "StockBalnce_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PO_Summarry&ReportTitle=Item Wise Stock Balance Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "VandorWise_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OppeningReport&ReportTitle=Recieving Item Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "VendorLedger") {

                        var url = 'ReportViewer.aspx?ReportName=VendorLedger&ReportTitle=Vendor Ledger From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Vendor_Wise_Transaction_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Vendor_Wise_Transaction_Detail&ReportTitle=Vendor Wise Transaction Detail From  '
                            + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val()
                            + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Vendor_Wise_Payment_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Vendor_Wise_Payment_Summary&ReportTitle=Vendor Wise Payment Summary From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Bonus_Medicine_Detail_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Bonus_Medicine_Detail_Report&ReportTitle=Bonus Medicine Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "GRN_Report") {

                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GRN_Report&ReportTitle=GRN Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val()  + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "GRN_PO_Reconciliation_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GRN_PO_Reconciliation_Report&ReportTitle=GRN Vs PO Reconciliation Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Inventory_Reconciliation_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Inventory_Reconciliation_Report&ReportTitle=GRN Vs PO Vs IGP Vs PR Reconciliation Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Purchase_Register_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Purchase_Register_Report&ReportTitle=Purchase Register Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "AdmitPatientList") {

                        var url = 'ReportViewer.aspx?ReportName=AdmitPatientList&ReportTitle=Admit Patient List From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Purchase_Order_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Purchase_Order_Report&ReportTitle=Purchase Order Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&Status=' + $('#ctl00_MainContent_ddlStatus').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Payment_to_Supplier_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Payment_to_Supplier_Report&ReportTitle=Payment to Supplier Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Pending_Payment_Request_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Pending_Payment_Request_Report&ReportTitle=Pending Payment Request Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                     if (rptTitle == "VendorWiseLedger") {
                         var url = 'ReportViewer.aspx?ReportName=VendorWiseLedger&ReportTitle=Vendor Ledger From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&PatientType=' + $('#ctl00_MainContent_ddlDepartments').val() ;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "VPDR") {

                        var url = 'ReportViewer.aspx?ReportName=VPDR&ReportTitle=Vendor Profile Detail Report ' + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Status=' + $('#ctl00_MainContent_ddloprators').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "BER") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BER&ReportTitle=Expiry Batch Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Warehouse=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "InvoiceAging") {

                        var url = 'ReportViewer.aspx?ReportName=InvoiceAging&ReportTitle=Invoice Aging Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "ApAgingDetail") {

                        var url = 'ReportViewer.aspx?ReportName=ApAgingDetail&ReportTitle=Ap Aging Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "ApAgingSummary") {

                        var url = 'ReportViewer.aspx?ReportName=ApAgingSummary&ReportTitle=Ap Aging Summary Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Birth_Certificate_Detail_Report") {

                        var url = 'ReportViewer.aspx?ReportName=Birth_Certificate_Detail_Report&ReportTitle=Birth Certificate Detail Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Death_Certificate_Detail_Report") {

                        var url = 'ReportViewer.aspx?ReportName=Death_Certificate_Detail_Report&ReportTitle=Death Certificate Detail Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Patient_Quality_Check_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Quality_Check_Report&ReportTitle=Patient Quality Check Detail Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "LCP") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=LCP&ReportTitle=LCP Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Gir_To_Po_Heirarchy") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Gir_To_Po_Heirarchy&ReportTitle=Gir To Po Heirarchy Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Cath_Lab_Billing_Detail_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Cath_Lab_Billing_Detail_Report&ReportTitle=Cath Lab Billing Detail Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime) + '&MRNo=' + (patid || 0) + '&DoctorID=' + $("#ctl00_MainContent_ddlDoctor").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() ;
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Cath_Lab_Billing_Detail_Vendor_Wise_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Cath_Lab_Billing_Detail_Vendor_Wise_Report&ReportTitle=Cath Lab Billing Detail Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime) + '&MRNo=' + (patid || 0) + '&DoctorID=' + $("#ctl00_MainContent_ddlDoctor").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&VendorId=' + $('#ctl00_MainContent_ddlVendor').val();
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "High_Risk_Medicine_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=High_Risk_Medicine_Report&ReportTitle=High Risk Medicine Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Narcotic_Medicine_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val()
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Narcotic_Medicine_Report&ReportTitle=Narcotic Medicine Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Narcotic_Medicine_Register_Report") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val()
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Narcotic_Medicine_Register_Report&ReportTitle=Narcotic Medicine Report From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime);
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "Lab_Test_Result_Culture") {
                        debugger;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Result_Culture&ReportTitle=Lab Test Result Report For Culture Tests From  ' + startDateTime + ' to ' + endDateTime + '&StartDateTime=' + encodeURIComponent(startDateTime) + '&EndDateTime=' + encodeURIComponent(endDateTime) + '&Department=' + ($("#ctl00_MainContent_ddlDepartments").val() || "0");
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "GOP_Patient_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GOP_Details&ReportTitle=OPD Patient Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    if (rptTitle == "GOP_Patient_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GOP_Summary&ReportTitle=OPD Patient Summary From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "PARLR") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Items = ($("#ctl00_MainContent_ddlMainDepartment").val() !== undefined) ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0";
                        var hideZeroBalance = document.getElementById('<%= chkZeroRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PARLR&ReportTitle=Par and Reorder Level Report' + '&AccountCategory=' + $('#ctl00_MainContent_ddlTestName').val() + '&Items=' + Items + '&wareh=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&HideZeroBalance=' + hideZeroBalance + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "SIH") {
                        var stock = $("#ctl00_MainContent_ddlStock").val();
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=SIH&ReportTitle=Stock In Hand ' + '&stock=' + stock + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Overall_Stock_Consumption_Details") {
                        debugger;
                        var stock = $("#ctl00_MainContent_ddlStock").val();    
                        var url = 'ReportViewer.aspx?ReportName=Overall_Stock_Consumption_Details&ReportTitle=Stock Consumption Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&startDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&endDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&stock=' + stock + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'TotalPatientRegsreport') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TotalPatientRegsreport&ReportTitle=Total Patient Register from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                }
            });
        });

    </script>


    <div class="container mt-4">
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="MRDiv" visible="false" runat="server">
                <asp:Label runat="server" ID="lblMRNo" Text="Mr No"></asp:Label>
                <asp:TextBox runat="server" ID="txtMRNo"></asp:TextBox>
            </div>
        </div>
        <%-- newly inserted div for MR_No --%>
        <div class="col-lg-3 col-md-4 col-sm-12" id="PatientDiv" visible="false" runat="server">
            <asp:Label runat="server" ID="lblPatient" Text="Patient"></asp:Label>
            <asp:DropDownList runat="server" ID="ddlPatient" AppendDataBoundItems="true">
                <asp:ListItem Text="Select Patient" Value="0" />
            </asp:DropDownList>
        </div>
        </div>

        <div class="col-lg-3 col-md-4 col-sm-12" runat="server" id="trDepartmentType" visible="false">
  <div class="form-group">
        <asp:Label runat="server" ID="lblDepartmentDiv" Text="OPD / IPD" AssociatedControlID="ddOPDIPDdiv"></asp:Label>
        <asp:DropDownList runat="server" ID="ddOPDIPDdiv" AppendDataBoundItems="true" CssClass="form-control">
            <asp:ListItem Text="All" Value="0"></asp:ListItem>
            <asp:ListItem Text="OPD" Value="01"></asp:ListItem>
            <asp:ListItem Text="IPD" Value="03"></asp:ListItem>
        </asp:DropDownList>
    </div>
</div>

                <%--newly inserted div for Movement_type--%>
<div class="col-lg-3 col-md-4 col-sm-12" runat="server" id="trMovementType" visible="false">
  <div class="form-group">
        <asp:Label runat="server" ID="lblMovementType" Text="Movement Type" AssociatedControlID="ddlMovementType"></asp:Label>
        <asp:DropDownList runat="server" ID="ddlMovementType" AppendDataBoundItems="true" CssClass="form-control">
            <asp:ListItem Text="All" Value="0"></asp:ListItem>
            <asp:ListItem Text="Fast-Moving" Value="FastMoving"></asp:ListItem>
            <asp:ListItem Text="Slow-Moving" Value="SlowMoving"></asp:ListItem>
            <asp:ListItem Text="Non-Moving" Value="NonMoving"></asp:ListItem>
        </asp:DropDownList>
    </div>

</div>
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="MainDeptDiv" visible="false" runat="server">
                <asp:Label runat="server" ID="lblMainDepartment" Text="Main Department"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlMainDepartment" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <!-- Year Dropdown for Pharmacy Overall Summary Report -->
        <div class="row mb-3" id="YearDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12">
                <asp:Label ID="lblYear" runat="server" Text="Financial Year" CssClass="form-label"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlYear" CssClass="form-control">
                    <asp:ListItem Text="Select Year" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
            <%--new yearly div placed--%>
            <!-- Month Dropdown -->
        <div class="row mb-3" id="MonthDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12">
                <asp:Label ID="lblMonth" runat="server" Text="Month" CssClass="form-label"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlMonth" CssClass="form-control">
                    <asp:ListItem Text="Select Month" Value="0"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

            <div class="col-lg-3 col-md-4 col-sm-12" id="trTestResult1" visible="false" runat="server">
                <asp:Label runat="server" ID="lblTestName" Text="Test Name"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlTestName" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-lg-1 col-md-4 col-sm-12" id="tr1ChkOPD" visible="false" runat="server">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" value="" id="chkOPD" />
                    <label class="form-check-label" id="OPD" for="flexCheckDefault" style="margin-left: 8px;">OPD</label>
                </div>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12" runat="server" visible="false" id="tr1ChkIPD">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" value="" id="chkIPD" />
                    <label class="form-check-label" id="IPD" for="flexCheckDefault" style="margin-left: 8px;">IPD</label>
                </div>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12" id="tr1ShowRate" visible="false" runat="server">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" checked="checked" value="" id="chkShowRate" />
                    <label class="form-check-label" id="showRate" for="flexCheckDefault" style="margin-left: 8px;">Rate</label>
                </div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="tr1MedicalSubsidy" visible="false" runat="server">
                <asp:Label ID="lblMedical" runat="server" Text="Medical Subsidy" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="ddlMedicalSubsidy" runat="server" AppendDataBoundItems="true" CssClass="form-control">
                    <asp:ListItem Text="Both" Value="0"></asp:ListItem>
                    <asp:ListItem Text="Yes" Value="1"></asp:ListItem>
                    <asp:ListItem Text="No" Value="2"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" id="trServiceName" visible="false" runat="server">
                <asp:Label ID="lblService" runat="server" Text="Service Name" CssClass="form-label"></asp:Label>
                <asp:DropDownList ID="ddlTestResult" runat="server" AppendDataBoundItems="true" CssClass="form-control">
                    <asp:ListItem Text="---Please Select---" Value="0"></asp:ListItem>
                    <asp:ListItem Text="X-Ray" Value="003"></asp:ListItem>
                    <asp:ListItem Text="Ultra Sound" Value="002"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server">
            <div class="col-lg-3 col-md-4 col-sm-12" id="trProcedure1" visible="false" runat="server">
                <asp:Label runat="server" ID="lbProcedure" Text="Procedure Name"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlProcedure" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" id="trSearch1" visible="false" runat="server">
                <asp:Label runat="server" ID="td11" Text="Item Name"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlItemName" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server">
            <div class="col-lg-3 col-md-4 col-sm-12" id="trMedicineDiv" visible="false" runat="server">
                <asp:Label runat="server" ID="tdMedName" Text="Item Name"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlMedName" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server">
            <div class="col-lg-3 col-md-4 col-sm-12" id="trPayment" visible="false" runat="server">
                <asp:Label runat="server" ID="lblPaymentType" Text="Payment Type"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlPaymentType" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" id="dpROw" runat="server" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblDepartment" Text="Department"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlDepartments" AppendDataBoundItems="true" onchange="loaddoctor();">
                </asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblPatientType" Text="Patient Type"></asp:Label>
                <asp:ListBox runat="server" ID="lblMultiSelect" SelectionMode="multiple" Style="height: 61px !important"></asp:ListBox>
                <asp:DropDownList runat="server" ID="ddlPatientType" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" id="optRw" runat="server" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lboperator" Text="Operators"></asp:Label>
                <asp:DropDownList runat="server" ID="ddloprators" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lbShift" Text="Shift"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlShift" AppendDataBoundItems="true" onchange="changeshift(); DisableFilterClinic();"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server" visible="false" id="op_PanelCompany">
                <asp:Label runat="server" ID="lbPanelCompany" Text="Panel Company"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlPanelCompany" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server" visible="false" id="op_FilterClinic">
                <asp:Label runat="server" ID="lbFilterClinic" Text="Filter Clinic"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlFilterClinic" AppendDataBoundItems="true" onchange="DisableDepartmentDoctor();"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server" visible="false" id="CashierRow">
                <asp:Label runat="server" ID="lblCashier" Text="Cashier"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlcashier" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server" visible="false" id="test_Cat">
                <asp:Label runat="server" ID="lblTestCategory" Text="Test Catagory"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlcatagory" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div> 
        <div class="row mb-3" runat="server" id="trDoctor" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblDoctor" Text="Doctor"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlDoctor" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lbservieType" Visible="false" Text="Service Type"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlReportType" Visible="false" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="tr_Inv" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="Label1" Text="Inventory Form"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlInvForm" AppendDataBoundItems="true" onchange="LoadInvNo();"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lbnvNo" Text="Inventory No"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlInvNo" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="Stock_Movement" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblWarehouse" Text="Ware House"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlwareHouse" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lbItemCategory" Text="Item Category"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlItemCategory" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblItemCode" Visible="false" Text="Select Item Code"></asp:Label>
                <asp:TextBox runat="server" ID="txtItemCode" Visible="false"></asp:TextBox>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="rowStock" visible="false">

            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblStock" Text="Stock"></asp:Label>
                    <asp:DropDownList ID="ddlStock" runat="server">
                        <asp:ListItem Value="All" Text="All"></asp:ListItem>
                        <asp:ListItem Value="0" Text="Zero"></asp:ListItem>
                        <asp:ListItem Value="1" Text="Greater Than Zero"></asp:ListItem>
                        <asp:ListItem Value="2" Text="Less Than Zero"></asp:ListItem>
                    </asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="compDiv" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblCompanies" Text="Companies"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlCompdrop" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="row_Vendor" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblVendor" Text="Vendor"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlVendor" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" runat="server" id="SubDepartment" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12" runat="server">
                <asp:Label runat="server" ID="lblSubDepartment" Text="Vendor"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlSubDepartment" AppendDataBoundItems="true"></asp:DropDownList>
            </div>
        </div>
        <div class="row mb-3" id="DateDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-3 col-sm-12" id="startDateColumn" runat="server">
                <asp:Label ID="sttDate" runat="server" Text="Start Date" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtStart_Date" CssClass="form-control datepicker"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-12">
                <asp:Label ID="endDate" runat="server" Text="End Date" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtEnd_Date" CssClass="form-control datepicker"></asp:TextBox>
            </div>
        </div>
        <div class="row mb-3" id="Time_Row" runat="server" visible="false">
            <div class="col-lg-3 col-md-3 col-sm-12">
                <asp:Label ID="sttTime" runat="server" Text="Start Time" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtSTime" CssClass="form-control"></asp:TextBox>
            </div>
            <div class="col-lg-3 col-md-3 col-sm-12">
                <asp:Label ID="endTime" runat="server" Text="End Time" CssClass="form-label"></asp:Label>
                <asp:TextBox runat="server" ID="txtETime" CssClass="form-control"></asp:TextBox>
            </div>
        </div>
        <div class="row mb-3" id="hideStartDateRow" runat="server" visible="false">
            <div class="col-lg-3 col-md-4 col-sm-12">
                <div class="form-check" style="display: inline-flex;">
                    <input runat="server" class="form-check-input" type="checkbox" id="cbHideStartDate" ClientIDMode="Static" />
                    <label class="form-check-label" for="cbHideStartDate" style="margin-left: 8px; white-space: nowrap;">As On</label>
                </div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="tr_Export" runat="server" visible="false">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" id="chkExportPDF" visible="true" />
                    <label class="form-check-label" id="lblExport" for="flexCheckDefault" style="margin-left: 8px; white-space: nowrap;">Export to Excel</label>
                </div>
            </div>
        </div>
        <div class="row mb-3" id="trStatus" runat="server" visible="false">
    <div class="col-lg-3 col-md-4 col-sm-12">
        <asp:Label ID="lblStatus" Text="Status" runat="server"></asp:Label>
        <asp:DropDownList style="width:205px !important;" runat="server" ID="ddlStatus" AppendDataBoundItems="true">
            <asp:ListItem Text="Both" Value="0"></asp:ListItem>
            <asp:ListItem Text="Active" Value="1"></asp:ListItem>
            <asp:ListItem Text="Inactive" Value="2"></asp:ListItem>
        </asp:DropDownList>
    </div>
</div>

    <div class="col-lg-3 col-md-4 col-sm-12" id="trItemFilter" runat="server" visible="false">
        <asp:Label ID="lblItemFilter" Text="Item Filter" runat="server"></asp:Label>
        <asp:DropDownList style="width:205px !important;" runat="server" ID="ddlItemFilter" AppendDataBoundItems="true">
            <asp:ListItem Text="Both" Value="0"></asp:ListItem>
            <asp:ListItem Text="Pharmacy" Value="1"></asp:ListItem>
            <asp:ListItem Text="Hospital" Value="2"></asp:ListItem>
        </asp:DropDownList>
    </div>

        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="tr_Summary" runat="server" visible="false">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" value="Summary" id="chkSummary" name="chkSummary" />
                    <label class="form-check-label" id="lblSummary" for="flexCheckDefault" style="margin-left: 8px; white-space: nowrap;">Summary</label>
                </div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="tr_AllPatientRecord" runat="server" visible="false">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" value="Summary" id="chkAllPatientRecord" name="chkAllPatientRecord" />
     <%--<label class="form-check-label" id="lblAllPatientRecord" runat="server" for="flexCheckDefault" style="margin-left: 8px; white-space: nowrap;">All Patients Records</label>--%>
     <asp:Label ID="lblAllPatientRecord" Text="All Patients Records" runat="server"></asp:Label>                
                </div>
            </div>
        </div>
        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="trZeroRecord" runat="server" visible="false">
                <div class="form-check" style="display: inline-flex; width: 26px;">
                    <input runat="server" class="form-check-input" type="checkbox" value="Summary" id="chkZeroRecord" name="chkZeroRecord" />
                    <label class="form-check-label" id="lblZeroRecord" for="flexCheckDefault" style="margin-left: 8px; white-space: nowrap;">Hide Zero Balance</label>
                </div>
            </div>
        </div>
        &nbsp;&nbsp;
         <div class="row">
             <div class="col-lg-2">

                 <asp:Button Text="Preview" CssClass="btn btn-primry" ID="btnPreview" runat="server" OnClientClick="return false;" />

             </div>
             <div class="col-lg-2">
                 <asp:Button Text="Reset" ID="btnReset" CssClass="btn btn-gray" runat="server" CausesValidation="false" />
             </div>
         </div>
    </div>


</asp:Content>

