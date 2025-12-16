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
            var med_Name = $('#ctl00_MainContent_ddlItemName').val();
            if (med_Name == "0" || med_Name == null || med_Name == "null") {
                med_Name = "";
            }

            var options = '<option value="0">All</option>';

            PageMethods.loadMedicine(med_Name, function (data) {
                debugger;
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.Item_ID + '">' + value.Description + '</option>';
                });
                $('#ctl00_MainContent_ddlItemName').html(options);
            });

            return options;
        }
        var patid;
        function loadMRNo() {

            $("#ctl00_MainContent_txtMRNo").tokenInput("../../json.aspx?Table=PatientsByMr",

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
            var bool = '<%= Convert.ToBoolean(AllowPatientRecord)%>'
            debugger;
            if (bool == "False") {
                $('#ctl00_MainContent_trAllPatients').hide();
            }
            $("#ctl00_MainContent_txtStart_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
            $("#ctl00_MainContent_txtEnd_Date").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());

            $('#ctl00_MainContent_txtSTime').ptTimeSelect({});
            $('#ctl00_MainContent_txtETime').ptTimeSelect({});
            $('#ctl00_MainContent_txtSTime').val('12:00 AM');
            $('#ctl00_MainContent_txtETime').val('11:59 PM');
            $('#ctl00_MainContent_ddlDepartments').select2();
            $('#ctl00_MainContent_ddlPatientType').select2();
            $('#ctl00_MainContent_ddlwareHouse').select2();
            $('#ctl00_MainContent_ddlMainDepartment').select2();
            $('#ctl00_MainContent_ddlStock').select2();
            $('#ctl00_MainContent_ddlItemCategory').select2();
            $('#ctl00_MainContent_ddloprators').select2();
            $('#ctl00_MainContent_ddlTestName').select2();
            $('#ctl00_MainContent_ddlDoctor').select2();
            $('#ctl00_MainContent_ddlInvForm').select2();
            $('#ctl00_MainContent_ddlInvNo').select2();
            $('#ctl00_MainContent_ddlItemName').select2();
            $('#ctl00_MainContent_ddlActive').select2();
            $('#ctl00_MainContent_ddlcashier').select2();

            $('#btnReset').click(function () {

                $('#Elements').find('input:text').each(function () {
                    $('select option:nth-child(1)').attr('selected', 'selected')
                    $(':text, textarea').val('');
                    $(':checkbox,:radio').attr('checked', '');
                });
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


                if ($('#ctl00_MainContent_txtStart_Date').val() == '' && error == 0) {
                    alert('Please Select Start Date');
                    error = 1;
                }
                else if ($('#ctl00_MainContent_txtEnd_Date').val() == '' && error == 0) {
                    alert('Please Select End Date');
                    error = 1;
                }
                else {
                    var rptTitle = '<%= Request.QueryString["rptTitle"]%>'
                    if (rptTitle == "Doctotr_Receipts") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DoctorWisePatients&ReportTitle=Doctor Wise Patient from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked;
                        window.open(url, '_blanks');
                    }

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
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "STM") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=StockBalance&ReportTitle=Item Wise Stock Balance Report ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&itemCode=' + ((typeof ($("#txtItemCode").val()) != 'undefined' && $("#txtItemCode").val().toString() != "") ? $("#txtItemCode").val().toString().split('-')[0] : '');
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "IWPOS") {
                        debugger;
                        var oprator = ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");
                        var Items = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        var Procedure = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0");
                        var url = 'ReportViewer.aspx?ReportName=ItemWosePOSummary&ReportTitle=Item Wise PO Summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Items=' + Items + '&ItemGroup=' + oprator + '&Vendor_ID=' + Procedure;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "MIR_summary") {

                        var url = 'ReportViewer.aspx?ReportName=MIR_summary&ReportTitle=MIR Summary Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "SIN_summary") {
                        var url = 'ReportViewer.aspx?ReportName=SIN_summary&ReportTitle=SIN Summary Report From   ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val() + '&WareHouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blanks');

                    }
                    else if (rptTitle == "MSR") {
                        var url = 'ReportViewer.aspx?ReportName=MinimumStock&ReportTitle=Minimum Stock Report ' + '&Item=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemCategory=' + $('#ctl00_MainContent_ddlItemCategory').val();
                        window.open(url, '_blanks');

                    }
                    else if (rptTitle == 'GRN_and_Item_Wise_Report') {
                        var url = 'ReportViewer.aspx?ReportName=GRN_and_Item_Wise_Report&ReportTitle= GRN & Item Wise Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepetID=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "PharmacySaleReport") {
                        debugger;
                        //var summary = $('#chkSummary').prop('checked') ? "true" : "false";
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var sDate = new Date($("#ctl00_MainContent_txtStart_Date").val());
                        var eDate = new Date($("#ctl00_MainContent_txtEnd_Date").val());
                        var sSDate = sDate.getDay();
                        var eEDate = eDate.getDay();
                        var url = 'ReportViewer.aspx?ReportName=PharmacySaleReport&ReportTitle=Pharmacy Sale Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '  ' + sSDate + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' + eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val() + '&Summary=' + summary;
                        window.open(url, '_blank');

                    }

                    else if (rptTitle == "GroupTestsRateList") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var NewLine = $('#ctl00_MainContent_ddlProcedure').val();
                        var url = 'ReportViewer.aspx?ReportName=GroupMainTestDepartments&ReportTitle=Group Main Test Departments from ' + '&Main_Department=' + timeLine + '&Patient_Type=' + NewLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "OutPatientsINP") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OutPatientsINP&ReportTitle=BloodIssuanceReport from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "BloodBankStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodBankStockLedger&ReportTitle=Blood Bank Stock Ledger  summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Patient_Trans_SehatSahulatCard") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail_SehatSahulatCard&ReportTitle= Sehat Sahulat Card Patient Invoice &MRNo=' + $('#ctl00_MainContent_txtMR_No').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == "WholeBloodStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=WholeBloodStockLedger&ReportTitle=Whole Blood Stock Ledger Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "TestsRateList") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var NewLine = $('#ctl00_MainContent_ddlProcedure').val();
                        var url = 'ReportViewer.aspx?ReportName=MainTestDepartments&ReportTitle=Main Test Departments from ' + '&Main_Department=' + timeLine + '&Patient_Type=' + NewLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == 'Procedure_Service_List') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var url = 'ReportViewer.aspx?ReportName=Procedure_Service_List&ReportTitle=Procedure Service List &Report_Type=' + "01" + '&Company=' + ((typeof ($("#ctl00_MainContent_ddlCompdrop option:selected").val()) != 'undefined') ? $("#ctl00_MainContent_ddlCompdrop option:selected").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');

                    }
                    else if (rptTitle == "Blood_Bank_Cash_Collection_Details") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Blood_Bank_Cash_Collection_Details&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'TotalOpdDischargeReport') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TotalOpdDischargeReport&ReportTitle=Total Opd Discharge Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Non_Cash_Blood_Bank_Revenue") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=NonCashBloodBankRevenue&ReportTitle=LabCashReceivingCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect").val()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Patient_Wise_Panel') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=InsuranceCompanies&ReportTitle=Patient Wise Insurance Companies Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + timeLine + '&PanelCompanies=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "ComponentBloodStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Component = $("#ctl00_MainContent_ddlMainDepartment").val();
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=ComponentBloodStockLedger&ReportTitle=Blood Bank Present Patient Stock Record from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&Component=' + Component + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "LabResultPending") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=LabResultPending&ReportTitle=Lab Result Pending from ' + $('#ctl00_MainContent_txtStart_Date').val() + '  ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '  ' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Bed_Occupancy') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BedOccupancy&ReportTitle=Bed Occupancy from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == 'TotalpatientsandRevisitpatientsreport') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();

                        var url = 'ReportViewer.aspx?ReportName=TotalpatientsandRevisitpatientsreport&ReportTitle=Total Patients and Rvisit Patients from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == "PatientsTypesDetails") {
                        debugger;

                       // var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        //Mohsin: 25 JULY WEDNESDAY, the report doesnot exists front and back end donot match.
                        //var url = 'ReportViewer.aspx?ReportName=PatientsTypesDetails&ReportTitle=Patients Category Wise OPD Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&PatientType=' + $('#ctl00_MainContent_lblMultiSelect').val() + '&ALLValues=' + Allvalues + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        var url = 'ReportViewer.aspx?ReportName=PatientsTypesDetails&ReportTitle=Patients Category Wise OPD Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val();
                        //Mohsin
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == 'SehatSahulatWise') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=SehatSahulatWise&ReportTitle=Patient Sehat Sahulat Card Receivable Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'SehatSahulatWiseExpensive') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlDepartments').val();
                        var url = 'ReportViewer.aspx?ReportName=SehatSahulatWiseExpensive&ReportTitle=Patient Sehat Sahulat Card Expense Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&ExportPDF=' + exporttopdf + '&Departments_ID=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "CBloodBankStockLedger") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var Component = $("#ctl00_MainContent_ddlMainDepartment").val();
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=CBloodBankStockLedger&ReportTitle=  ' + $("#ctl00_MainContent_ddlMainDepartment option:selected ").text() + '    summary Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&Component=' + Component + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }




                    else if (rptTitle == "Lab_Test_Investigation") {
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Investigation&ReportTitle=Lab Test Investigation from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&TestCatagory=' + $('#ctl00_MainContent_ddlcatagory').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    // inserting the investigation delay report 

                    else if (rptTitle == "BloodResultPending") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var url = 'ReportViewer.aspx?ReportName=BloodResultPending&ReportTitle=Blood  Bank Result Pending from ' + $('#ctl00_MainContent_txtStart_Date').val() + '  ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '  ' + $('#ctl00_MainContent_txtETime').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Result=' + timeLine + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "Services_List") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Services_List&Show_Rate=' + $('#chkShowRate').is(':checked') + '&ExportPDF=' + exporttopdf + '';
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == 'AverageLengthOfStay') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=AverageLengthOfStay&ReportTitle=Average Length Of Stay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'TestWiseMonthly') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthly&ReportTitle=Test Wise Monthly from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'IPD_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=IPDTimeLine&ReportTitle=IPD Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                <%--    else if (rptTitle == 'TestWiseMonthlyLabTestDepartment') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthlyLabTestDepartment&ReportTitle=Test Wise Monthly from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepetID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
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
                        window.location.href = 'ReportViewer.aspx?ReportName=RefundReport&ReportTitle=Refund Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                    }
                    else if (rptTitle == 'Discharge_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DischargeTimeLine&ReportTitle=Discharge Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Ward_Allocation_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=WardAllocationTimeLine&ReportTitle=Ward Allocation Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Procedure_Time_Line') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ProcedureTimeLine&ReportTitle=Procedure Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'DepartmentWiseProcedureTimeLine') {
                        debugger;
                        var timeLine = $('#ctl00_MainContent_ddlMedicalSubsidy').val();
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentWiseProcedureTimeLine&ReportTitle=Department Wise Procedure Time Line from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Report_Type=' + timeLine + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "Patient_Trans_Detail") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail&ReportTitle=Patient Transaction Detail&MRNo=' + $('#ctl00_MainContent_txtMR_No').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Patient_Trans_Detail_Type") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Transaction_Detail_Type&ReportTitle=Insurance Patient Invoice&MRNo=' + $('#ctl00_MainContent_txtMR_No').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Lab_Test_Investigation_Delay") {
                        //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Investigation_Delay&ReportTitle=Lab Test Investigation Delay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Radiology_Investigation_Delay") {
                        //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=Radiology_Investigation_Delay&ReportTitle=Radiology Investigation Delay from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Lab_Cash_Collection") {
                       //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=LabCashCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Service_Wise_Summary_Report") {
                       //<%-- var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;--%>
                        var url = 'ReportViewer.aspx?ReportName=Service_Wise_Summary_Report&ReportTitle=Service Wise Summary from  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Operator_Wise_Billing_Report") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Operator_Wise_Billing_Report&ReportTitle=Operator Wise Billing Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0"); //+ '&Summary=' + summary ;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Blood_Bank_Lab_Test_Details") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=BloodBankLabTest_Details&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "BloodIssuance") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodIssuance&ReportTitle=BloodIssuanceReport from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "Lab_Test_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=LabTestDetailCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                   <%-- else if (rptTitle == "RadiologyReport") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }--%>
                    else if (rptTitle == "RadiologyReport") {
                        debugger;
                        var main_department = ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var url = 'ReportViewer.aspx?ReportName=RadiologyReport&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&MainDepartment=' + main_department + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "AnalysisReport") {
                        debugger;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0")
                        var url = 'ReportViewer.aspx?ReportName=AnalysisReport&ReportTitle=Radiology Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&testName=' + testname  + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    //else if (rptTitle == "AnalysisReport") {
                    //    var tests = ((typeof ($("#ctl00_MainContent_ddlTestName").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName").val() : "0");
                    //    var url = 'ReportViewer.aspx?ReportName=AnalysisReport&ReportTitle=Analysis Report from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_oprators").val()) != 'undefined') ? $("#ctl00_MainContent_oprators").val() : "0") + '&Tests=' + tests + '&ExportPDF=' + exporttopdf;
                    //    window.open(url, '_blanks');
                    //}
                    else if (rptTitle == "Sale_Return_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Sale_Return_Report&ReportTitle=Sale Return Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Sale_Report_Summary") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Sale_Report_Summary&ReportTitle=Sale Report Summary From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Lab_Test_Wise_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Wise_Summary&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Lab_Test_Patient_Wise") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var testname = ((typeof ($("#ctl00_MainContent_ddlTestName option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlTestName option:selected").text() : "0")
                        var url = 'ReportViewer.aspx?ReportName=Lab_Test_Patient_Wise&ReportTitle=Lab Tests Patient Wise from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&testName=' + testname + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "Dischare_Revd") {
                        debugger;
                        var ddlShift = ((typeof ($("#ctl00_MainContent_ddlShift").val()) != 'undefined') ? $("#ctl00_MainContent_ddlShift").val() : "0");
                        var ddlDoctor = ((typeof ($("#ctl00_MainContent_ddlDoctor").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDoctor").val() : "0");
                        var Procedure = ((typeof ($("#ctl00_MainContent_oprators").val()) != 'undefined') ? $("#ctl00_MainContent_oprators").val() : "0");

                        var sDate = new Date($("#ctl00_MainContent_txtsDate").val());
                        var eDate = new Date($("#ctl00_MainContent_txteDate").val());
                        var sSDate = weekday[sDate.getDay()];
                        var eEDate = weekday[eDate.getDay()];

                        var url = 'ReportViewer.aspx?ReportName=DischargeReceived&ReportTitle= Discharge Received Report from ' + $('#ctl00_MainContent_txtsDate').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' ' + sSDate + ' to ' + $('#ctl00_MainContent_txteDate').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + ' ' + eEDate + '&StartDateTime=' + $('#ctl00_MainContent_txtsDate').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txteDate').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Shift=' + ddlShift + '&Doctor=' + ddlDoctor + '&Procedure=' + Procedure;
                        window.open(url, '_blank');

                    }
                    else if (rptTitle == "Lab_Department_Wise_Summary") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=LabDepartmentWiseSummary&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;   //'&testName=' + 'All' +
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "Test_Result_Status") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestResultStatus&ReportTitle=Test Result Status from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&serviceID=' + ((typeof ($("#ctl00_MainContent_ddlTestResult").val()) != 'undefined') ? $("#ctl00_MainContent_ddlTestResult").val() : "0") + '&ExportPDF=' + exporttopdf; /*+ '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked*/
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Total_Income') {
                        debugger;
                        window.location.href = 'ReportViewer.aspx?ReportName=TotalIncome&ReportTitle=Report Total Income from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                    }


                    else if (rptTitle == 'Pharmacy_Profit_and_Loss_Report') {
                        debugger;
                    //    window.location.href = 'ReportViewer.aspx?ReportName=Pharmacy_Profit_and_Loss_Report&ReportTitle=Pharmacy Profit and Loss from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        var url = 'ReportViewer.aspx?ReportName=Pharmacy_Profit_and_Loss_Report&ReportTitle=Pharmacy Profit and Loss from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "Lab_Cash_Receiving_Collection") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=LabCashReceivingCollection&ReportTitle=LabCashReceivingCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Summary=' + summary + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect").val()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Service_Charges_Detail') {

                        var url = 'ReportViewer.aspx?ReportName=ServiceChargesDetail&ReportTitle=Service Charges Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlTestName').val() + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0");// + '&Summary=' + summary + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'ConsolidateMedicalSubsidy') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var AllPatientRecords = $('#AllPatientsRecords')[0].checked;
                        var url = 'ReportViewer.aspx?ReportName=ConsolidateMedicalSubsidy&ReportTitle=Consolidate Medical Subsidy from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&PatientType=' + $('#ctl00_MainContent_lblMultiSelect').val() + '&ALLValues=' + Allvalues + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&AllPatientRecords=' + AllPatientRecords + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlTestName').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');

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
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Private_Procedure_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PrivateProcedureDetail&ReportTitle=Private Procedure Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'OPDPrivateDetail') {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var AllPatientRecords = $('#AllPatientsRecords')[0].checked;
                        var url = 'ReportViewer.aspx?ReportName=OPDPrivateDetail&ReportTitle=OPD Private Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&ExportPDF=' + exporttopdf + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&AllPatientRecords=' + AllPatientRecords + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'HospitalServices') {
                        var url = 'ReportViewer.aspx?ReportName=HospitalServices&ReportTitle=Hospital Services from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Patient_Type=' + $("#ctl00_MainContent_ddlDepartments").val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&ServiceID=' + $('#ctl00_MainContent_ddlPatientType').val();
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Daily_Revenue') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DailyRevenue&ReportTitle=Daily Revenue from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
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
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        // Combine date + time into single strings (as your backend expects)
                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=OPDDetailReport' +
                            '&ReportTitle=OPD Detail Report from ' + startDateTime + ' to ' + endDateTime +
                            '&StartDateTime=' + encodeURIComponent(startDateTime) +
                            '&EndDateTime=' + encodeURIComponent(endDateTime) +
                            '&Summary=' + summary +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "OPD_Department_Wise_Report") {
                        debugger;
                     //   var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
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
                            '&Shift=' + encodeURIComponent(ddlShift) +
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() +
                            '&Operator=' + ((typeof ($("#ctl00_MainContent_ddlPatientType").val()) != 'undefined') ? $("#ctl00_MainContent_ddlPatientType").val() : "0") +
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");

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
                            '&EndDateTime=' + encodeURIComponent(endDateTime) + '&Item=' + $("#ctl00_MainContent_ddlMainDepartment").val() + '&Operator=' + Procedure + '&Company=' + $("#ctl00_MainContent_ddlDepartments").val();// + '&ExportPDF=' + exporttopdf;
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
                    else if (rptTitle == "Consultant_Day_Wise_report") {

                        var startDate = $('#ctl00_MainContent_txtStart_Date').val();
                        var startTime = $('#ctl00_MainContent_txtSTime').val();
                        var endDate = $('#ctl00_MainContent_txtEnd_Date').val();
                        var endTime = $('#ctl00_MainContent_txtETime').val();

                        var startDateTime = startDate + ' ' + startTime;
                        var endDateTime = endDate + ' ' + endTime;

                        var url = 'ReportViewer.aspx?ReportName=Consultant_Day_Wise_report' +
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
                            '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val();

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
                        var status = $('#ctl00_MainContent_ddlStatus').val();
                        var itemFilter = $('#ctl00_MainContent_ddlItemFilter').val();


                        var url = 'ReportViewer.aspx?ReportName=ActiveItems' +
                            '&ReportTitle=Active Inventory Items Report from ' +
                            '&Status=' + status +
                            '&ItemFilter=' + itemFilter;

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
                            '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");

                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Emer_Detail_Report") {
                        debugger;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=EmerDetailReport&ReportTitle=Emergency Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
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
                    else if (rptTitle == "Head_Wise_Discount_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Head_Wise_Discount_Report&ReportTitle=Head Wise Discount from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "TimeAndMotion") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=TimeAndMotion&ReportTitle=Time and Motion Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Pharmacy_Customer_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Pharmacy_Customer_Report&ReportTitle=Customer Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Physiotherapy_Cash_Collection") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Physiotherapy_Cash_Collection&ReportTitle=Physiotherapy Cash Collection Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Item_Wise_Margin_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Item_Wise_Margin_Report&ReportTitle=Item Wise Margin Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val();
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == "Item_Wise_Purchase_Report") {
                        debugger;
                        var url = 'ReportViewer.aspx?ReportName=Item_Wise_Purchase_Report&ReportTitle=Item Wise Purchase Report From ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&warehouse=' + $('#ctl00_MainContent_ddlwareHouse').val() + '&ItemID=' + $('#ctl00_MainContent_ddlItemName').val();
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
                        var url = 'ReportViewer.aspx?ReportName=PCR&ReportTitle=Pharmacy Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val();
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
                        var url = 'ReportViewer.aspx?ReportName=MER&ReportTitle=Medicine Expiry Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blank');
                    }



                    else if (rptTitle == 'Department_Conversion') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentConversion&ReportTitle=Department Conversion from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '' + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Departmentwise_Cash_Summary') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DepartmentwiseCashSummary&ReportTitle=Departmentwise Cash Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '';
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Bed_Allocation_Report') {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BedAllocationReport&ReportTitle=Bed Allocation Report&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '';
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Package_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PackageDetailReport&ReportTitle=Package Detail Procedures Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&MedicalSubsidy=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "OutSourceTestDetail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=OutSourceTestDetail&ReportTitle=Out Sourcer From ' + $('#ctl00_MainContent_txtStart_Date').val() + '&tetsDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == "Blood_Bank_Cash_Collection") {
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=BloodBankCashCollection&ReportTitle=LabCashCollection from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&Discount=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&Patient_Type=' + ((typeof ($("#ctl00_MainContent_lblMultiSelect option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_lblMultiSelect option:selected").text() : "0") + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == 'Procedure_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ProcedureDetail&ReportTitle=Procedure Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&MedicalSubsidy=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Procedure_Time_Line_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ProcedureTimeLineDetail&ReportTitle=Procedure Time Line Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ProcedureName=' + ((typeof ($("#ctl00_MainContent_ddlProcedureoption:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlProcedure option:selected").text() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0") + '&PatientType=' + ((typeof ($("#ctl00_MainContent_ddlMedicalSubsidy option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlMedicalSubsidy option:selected").text() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'PrivateAdmition_Detail') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=PrivateAdmitionDetail&ReportTitle=Private Admition Detail Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDateTime=' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + '&EndDateTime=' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&Summary=' + summary + '&ExportPDF=' + exporttopdf + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments option:selected").text()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments option:selected").text() : "0");
                        window.open(url, '_blanks');
                    }


                    else if (rptTitle == "Discharge_Time_Line_Detail") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Discharge Time Line Detail&ReportTitle=Discharge Time Line Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == "ChargePolicyWiseSummary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ChargePolicyWiseSummary&ReportTitle=Charge Policy Wise Summary from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Charge_Policy=' + ((typeof ($("#ctl00_MainContent_ddlMainDepartment").val()) != 'undefined') ? $("#ctl00_MainContent_ddlMainDepartment").val() : "0");
                        window.open(url, '_blanks');
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
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'ReportVoucher') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=ReportVoucher&ReportTitle= Report Voucher Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Patient_Count_Department_Wise') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Patient_Count_Department_Wise&ReportTitle= Department Wise Patients Count From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'TestWiseMonthlyLabTestDepartment') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TestWiseMonthlyLabTestDepartment&ReportTitle=Lab Test Department Wise Monthly From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0");    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'Stock_In_Hand_Detail') {
                        debugger;
                        var stock = $("#ctl00_MainContent_ddlStock").val();     // stock new 
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=Stock_In_Hand_Detail&ReportTitle=Stock in Hand Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&ALLValues=' + Allvalues + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&stock=' + stock;    // excluded:'&Patient_Type=' + $("#ctl00_MainContent_ddlPatientType").val() + 
                        window.open(url, '_blanks');
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
                        var url = 'ReportViewer.aspx?ReportName=DoctorShare_Report&ReportTitle=Hospital Admission Detail from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0") + '&Department=' + ((typeof ($("#ctl00_MainContent_ddlDepartments").val()) != 'undefined') ? $("#ctl00_MainContent_ddlDepartments").val() : "0") + '&PatientType=' + $("#ctl00_MainContent_ddlPatientType").val();  // excluded: + '&ExportPDF=' + exporttopdf    + '&Summary=' + summary 
                        window.open(url, '_blank');
                    }

                    else if (rptTitle == "Patients_Cards") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DeptWisePatientsCardDetails&ReportTitle=Department And Patient Type Wise Patients Card Details from' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blanks');
                    }

                    else if (rptTitle == "Patients_Investigation") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=rptPatientInvestigationBilling&ReportTitle=Department And Patient Investigation  Details from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&MainDeptID=' + $('#ctl00_MainContent_ddlMainDepartment').val() + '&TestID=' + $('#ctl00_MainContent_ddlTestName').val() + '&TransType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&Doctor_ID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + $('#AllPatientsRecords')[0].checked + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blanks');
                    }
                     else if (rptTitle == "Patients_Receipts") {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var summary = document.getElementById('<%= chkSummary.ClientID %>').checked;
                        var allPatientRecord = document.getElementById('<%= chkAllPatientRecord.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=DeptWisePatients&ReportTitle=Department Wise and Patient Wise Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&DoctorID=' + $('#ctl00_MainContent_ddlDoctor').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Shift=' + ddlShift  + '&PatientType=' + $('#ctl00_MainContent_ddlPatientType').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf + '&Summary=' + summary + '&AllPatientsRecords=' + allPatientRecord + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blanks');
                    }
                         
                    else if (rptTitle == "AllCash_Report") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=AllCashReport&ReportTitle=All Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&STime=' + $('#ctl00_MainContent_txtSTime').val() + '&ETime=' + $('#ctl00_MainContent_txtETime').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blank');
                    }
                    else if (rptTitle == 'Hospital_Cash_Report') {
                        var url = 'ReportViewer.aspx?ReportName=HospitalCashReport&ReportTitle=Hospital Cash Report from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' ' + $('#ctl00_MainContent_txtSTime').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + ' ' + $('#ctl00_MainContent_txtETime').val() + '&StartDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&EndDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&StartTime=' + $('#ctl00_MainContent_txtSTime').val() + '&EndTime=' + $('#ctl00_MainContent_txtETime').val() + '' + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blank');
                    }

                    if (rptTitle == "StockBalnce_Report") {

                        var url = 'ReportViewer.aspx?ReportName=PO_Summarry&ReportTitle=Item Wise Stock Balance Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "VandorWise_Report") {

                        var url = 'ReportViewer.aspx?ReportName=OppeningReport&ReportTitle=Recieving Item Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "VendorLedger") {

                        var url = 'ReportViewer.aspx?ReportName=VendorLedger&ReportTitle=Vendor Ledger From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "Vendor_Wise_Transaction_Detail") {

                        var url = 'ReportViewer.aspx?ReportName=Vendor_Wise_Transaction_Detail&ReportTitle=Vendor Wise Transaction Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "Vendor_Wise_Payment_Summary") {

                        var url = 'ReportViewer.aspx?ReportName=Vendor_Wise_Payment_Summary&ReportTitle=Vendor Wise Payment Summary From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "VPDR") {

                        var url = 'ReportViewer.aspx?ReportName=VPDR&ReportTitle=Vendor Profile Detail Report ' + '&Vendor=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Status=' + $('#ctl00_MainContent_ddloprators').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "BER") {

                        var url = 'ReportViewer.aspx?ReportName=BER&ReportTitle=Expiry Batch Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&Warehouse=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Item=' + $('#ctl00_MainContent_ddlPatientType').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "InvoiceAging") {

                        var url = 'ReportViewer.aspx?ReportName=InvoiceAging&ReportTitle=Invoice Aging Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "ApAgingDetail") {

                        var url = 'ReportViewer.aspx?ReportName=ApAgingDetail&ReportTitle=Ap Aging Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "ApAgingSummary") {

                        var url = 'ReportViewer.aspx?ReportName=ApAgingSummary&ReportTitle=Ap Aging Summary Report From  ' + $('#ctl00_MainContent_txtStart_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&VendorId=' + $('#ctl00_MainContent_ddlDepartments').val();
                        window.open(url, '_blanks');
                    }

                    if (rptTitle == "GOP_Patient_Detail") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GOP_Details&ReportTitle=OPD Patient Detail From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blanks');
                    }
                    if (rptTitle == "GOP_Patient_Summary") {
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=GOP_Summary&ReportTitle=OPD Patient Summary From  ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf + '&Operator=' + ((typeof ($("#ctl00_MainContent_ddloprators").val()) != 'undefined') ? $("#ctl00_MainContent_ddloprators").val() : "0");
                        window.open(url, '_blanks');
                    }
                    else if (rptTitle == 'TotalPatientRegsreport') {
                        debugger;
                        var exporttopdf = document.getElementById('<%= chkExportPDF.ClientID %>').checked;
                        var url = 'ReportViewer.aspx?ReportName=TotalPatientRegsreport&ReportTitle=Total Patient Register from ' + $('#ctl00_MainContent_txtStart_Date').val() + ' to ' + $('#ctl00_MainContent_txtEnd_Date').val() + '&sDate=' + $('#ctl00_MainContent_txtStart_Date').val() + '&eDate=' + $('#ctl00_MainContent_txtEnd_Date').val() + '&ExportPDF=' + exporttopdf;
                        window.open(url, '_blanks');
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

        <div class="row mb-3">
            <div class="col-lg-3 col-md-4 col-sm-12" id="MainDeptDiv" visible="false" runat="server">
                <asp:Label runat="server" ID="lblMainDepartment" Text="Main Department"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlMainDepartment" AppendDataBoundItems="true"></asp:DropDownList>
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
        <div class="row mb-3" id="DateDiv" runat="server" visible="false">
            <div class="col-lg-3 col-md-3 col-sm-12">
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

    <div class="col-lg-3 col-md-4 col-sm-12" id="trItemFilter" runat="server" visible="false">
        <asp:Label ID="lblItemFilter" Text="Item Filter" runat="server"></asp:Label>
        <asp:DropDownList style="width:205px !important;" runat="server" ID="ddlItemFilter" AppendDataBoundItems="true">
            <asp:ListItem Text="Both" Value="0"></asp:ListItem>
            <asp:ListItem Text="Pharmacy" Value="1"></asp:ListItem>
            <asp:ListItem Text="Hospital" Value="2"></asp:ListItem>
        </asp:DropDownList>
    </div>
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
                    <label class="form-check-label" id="lblAllPatientRecord" for="flexCheckDefault" style="margin-left: 8px; white-space: nowrap;">All Patients Records</label>
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
