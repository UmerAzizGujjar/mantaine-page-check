<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.RegisterPatient" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/RegPatient.js?v=<%= System.IO.File.GetLastWriteTime(Server.MapPath("~/wwwroot/THEME_TIBBIT/CustomJs/RegPatient.js")).Ticks %>" type="text/javascript"></script>
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/RegPat.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <style>
        /* ===================== Compact form layout ===================== */
        .reg-page { padding-bottom: 16px; }

        .reg-page .pr-meta-bar { margin-bottom: 16px; padding: 6px 16px; }
        .reg-page .pr-primary-settings { margin-bottom: 16px; }
        .reg-page .pr-section-title {
            margin: 0 -20px 12px -20px !important;
            padding: 9px 20px !important;
        }

        /* kill the 1.5rem gap RegPat.css adds between rows */
        .reg-page .row + .row { margin-top: 0 !important; }
        .reg-page .pr-primary-settings .row { margin-bottom: 10px; }
        .reg-page .pr-primary-settings .row:last-child { margin-bottom: 0; }

        .reg-page .pr-primary-settings label {
            font-size: 11px !important;
            font-weight: 700 !important;
            color: #555 !important;
            text-transform: uppercase;
            letter-spacing: .03em;
            display: block;
            margin-bottom: 3px !important;
            min-height: 15px;
            line-height: 1.2;
        }
        .reg-page .pr-primary-settings input[type="text"],
        .reg-page .pr-primary-settings select {
            font-size: 12px !important;
            height: 32px !important;
            padding: 5px 10px !important;
            border: 1px solid #e0e0e0 !important;
            border-radius: 4px !important;
            background: #fff !important;
            box-shadow: none !important;
            width: 100% !important;
        }
        .reg-page .pr-primary-settings input[type="text"]:focus,
        .reg-page .pr-primary-settings select:focus {
            border-color: #EFA63E !important;
            box-shadow: 0 0 0 3px #EFA63E25 !important;
            outline: none !important;
        }
        .reg-page .pr-primary-settings input[type="text"][disabled],
        .reg-page .pr-primary-settings input[type="text"][readonly] {
            background: #f5f6f8 !important;
            color: #8a8f98 !important;
        }

        /* ── Select2 to match ── */
        .reg-page .pr-primary-settings .select2-container { width: 100% !important; }
        .reg-page .pr-primary-settings .select2-selection {
            height: 32px !important;
            border: 1px solid #e0e0e0 !important;
            border-radius: 4px !important;
            padding: 3px 8px !important;
            font-size: 12px !important;
            background: #fff !important;
        }
        .reg-page .pr-primary-settings .select2-selection__rendered { line-height: 24px !important; }
        .reg-page .pr-primary-settings .select2-selection__arrow { height: 30px !important; }
        .reg-page .pr-primary-settings .select2-container--focus .select2-selection,
        .reg-page .pr-primary-settings .select2-container--open .select2-selection {
            border-color: #EFA63E !important;
            box-shadow: 0 0 0 3px #EFA63E25 !important;
        }

        /* ── Inline validation text ── */
        .reg-page .span_txt {
            color: #c5221f !important;
            font-size: 11px !important;
            font-weight: 600;
            margin-top: 3px !important;
            display: block;
        }

        /* ── Checkbox pill ── */
        .reg-page .lab-check {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            height: 32px;
            padding: 0 13px;
            background: #fdf7ef;
            border: 1px solid #f0e0c8;
            border-radius: 16px;
            font-size: 11px;
            font-weight: 700;
            color: #7a6530;
            text-transform: uppercase;
            letter-spacing: .03em;
            cursor: pointer;
            white-space: nowrap;
        }
        .reg-page .lab-check input[type="checkbox"] {
            margin: 0 !important;
            position: static !important;
            width: 15px;
            height: 15px;
        }

        /* ── Action row ── */
        .reg-page .reg-actions {
            margin-top: 16px;
            padding-top: 14px;
            border-top: 1px solid #fdf2e2;
        }
        .reg-page .reg-actions .row > [class*="col-"] { margin-bottom: 8px; }
        .reg-page .reg-actions input[type="button"] { width: 100%; }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            loadCardfee();
            checkMonitoringVisibility();
            AllowRefund();
            var reg_id = '<%= Request.QueryString["Reg_id"] %>'
            if (reg_id != "") {
                Get_Pat_Info(reg_id);
                $('#SavePatient_Data').val('Update');
            }
            else {
                $('#btnPrint').hide();
                $('#btnVoucher').hide();
                $('#divcardfront').hide();
                $('#divcardback').hide();
                fillmrno();
                $('#ddl_status').select2();
                $('#ddl_bloodGroup').select2();
                $('#ddlCountry').select2();
                $('#ddlstate').select2();
                $('#txtcity').select2();
                $('#txtarea').select2();
                $('#ddlRelation').select2();
                $('#ddl_name').select2();
                $('#PrefixAge').select2();
            }
            $('#ddlbankcash').select2();
            $('#ddlbank').select2();
        // Bind change event
        $('#ddlbankcash').on('change', function () {
            loadBankAccounts($(this).val());
        });

        // Initialize bank dropdown based on default payment method
        loadBankAccounts($('#ddlbankcash').val());
        });

       function loadBankAccounts(paymentType, selectedId) {
    var $bank = $('#ddlbank');

    $bank.select2('destroy');

    if (paymentType !== "02") { // Cash
        $bank.empty().append('<option value="">Select Account</option>')
             .prop('disabled', true);
        $bank.select2();
        return;
    }

    // Bank – disable initially while loading
    $bank.empty().append('<option value="">Select Account</option>')
         .prop('disabled', true);
    $bank.select2();

    $.ajax({
        type: "POST",
        url: "RegisterPatient.aspx/GetBankAccounts",
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var accounts = JSON.parse(response.d);
            $bank.select2('destroy');
            $bank.empty().append('<option value="">Select Account</option>');
            if (accounts && accounts.length) {
                $.each(accounts, function (i, acc) {
                    $bank.append('<option value="' + acc.id + '">' + acc.name + '</option>');
                });
            } else {
                $bank.append('<option value="">No bank accounts found</option>');
            }
            $bank.prop('disabled', false);
            $bank.select2();
            if (selectedId) {
                $bank.val(selectedId).trigger('change');
            }
        },
        error: function () {
            $bank.select2('destroy')
                .empty().append('<option value="">Error loading accounts</option>')
                .prop('disabled', false);
            $bank.select2();
            if (selectedId) {
                $bank.val(selectedId).trigger('change');
            }
        }
    });
}
     
       
    
        var refund;
        function AllowRefund() {
            $.ajax({
                type: "POST",
                url: "RegisterPatient.aspx/checkRightsForRefund",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    refund = data.d;
                    if (refund == "true") {
                        $('#btnRefund').show();
                    }
                    else {
                        $('#btnRefund').hide();
                    }
                },
                failure: function () {
                    alert("Error");
                }
            });
        }
        function PrintPatientCard() {

            Patient_ID = '<%= Request.QueryString["Reg_id"]%>';
            var url = "/ReportViewer.aspx?ReportName=PrinRegtPatientCard&ReportTitle=Patient Registration Front Card&Reg_id=" + Patient_ID;
          window.open(url);
      }

       function PrintPatientBackCard() {
          
            Patient_ID = '<%= Request.QueryString["Reg_id"]%>';
           var url = "/ReportViewer.aspx?ReportName=PrintRegPatientBackCard&ReportTitle=Patient Registration Back Card&Reg_id=" + Patient_ID;
            window.open(url);
        }



        function PrintVoucher() {
            var id = '<%= Request.QueryString["Reg_id"] %>';
            var locationInfo = window.location;
            var url;
            if (locationInfo.hostname === 'localhost') {
                url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=CardFee';
            } else {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                var appPath = foldername ? '/' + foldername : '';
                url = 'http://' + ip + appPath + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD%20Voucher&TransID=' + id + '&TransType=CardFee';
            }
            window.open(url, '_blank');
        }

        <%--function PrintReceipt() {
            var reg_id = '<%= Request.QueryString["Reg_id"] %>'
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
            }
            window.open(url, '_blank');
        }--%>

        function PrintReceipt() {
            var reg_id = '<%= Request.QueryString["Reg_id"] %>';

            if (!reg_id || reg_id == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'No patient registration found to print!'
                });
                return;
            }
            Swal.fire({
                title: 'Preparing Print...',
                text: 'Please wait',
                allowOutsideClick: false,
                didOpen: () => {
                    Swal.showLoading();
                }
            });
            $.ajax({
                type: "POST",
                url: "RegisterPatient.aspx/IncrementReprintCount",
                contentType: "application/json; charset=utf-8",
                data: JSON.stringify({ regId: reg_id }),
                dataType: "json",
                success: function (response) {

                    Swal.close();

                    if (response.d.startsWith("SUCCESS")) {
                        var locationInfo = window.location;
                        var url = "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
                        if (!locationInfo.origin.includes('localhost')) {
                            var urlInfo = window.location.href.split('/');
                            var ip = urlInfo[2];
                            var foldername = urlInfo[3];
                            url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=Reg_Patient_Print&Title=Register Patient Print &Patient_ID=" + reg_id;
                        }
                        window.open(url, '_blank');
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error',
                            text: response.d
                        });
                    }
                },
                error: function (xhr, status, error) {
                    Swal.close();
                    Swal.fire({
                        icon: 'error',
                        title: 'Error',
                        text: 'Failed to track print. Please try again.'
                    });
                    console.error("Print tracking error:", error);
                }
            });
        }

            

        function loadCardfee() {
            $.ajax({
                type: "POST",
                url: "RegisterPatient.aspx/GetCardFee",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d !== null && !isNaN(response.d)) {
                        $('#txtCardFee').val(response.d);
                        $('#txtCardFee').attr('disabled', true);
                    } else {
                        console.error("Invalid fee received:", response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error loading card fee:", error);
                }
            });
        }

        function checkMonitoringVisibility() {
            $.ajax({
                type: "POST",
                url: "RegisterPatient.aspx/MonitoringCheckbox",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "01") {
                        $('#MonitoringDiv').show();
                    } else {
                        $('#MonitoringDiv').hide();
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error checking Monitoring checkbox:", error);
                    $('#MonitoringDiv').hide();
                }
            });
        }

        function RefundRegisterFee() {
            var reg_id = '<%= Request.QueryString["Reg_id"] %>';
            if (!reg_id || reg_id == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error',
                    text: 'No patient registration found to refund!'
                });
                return;
            }
            Swal.fire({
                title: 'Are you sure?',
                text: "You want to refund the card fee for this patient?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, Refund it!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Processing...',
                        text: 'Please wait while processing refund',
                        allowOutsideClick: false,
                        didOpen: () => {
                            Swal.showLoading();
                        }
                    });
                    $.ajax({
                        type: "POST",
                        url: "RegisterPatient.aspx/ProcessRefund",
                        contentType: "application/json; charset=utf-8",
                        data: JSON.stringify({ regId: reg_id }),
                        dataType: "json",
                        success: function (response) {
                            if (response.d.success) {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Refund Successful!',
                                    text: response.d.message,
                                    confirmButtonColor: '#3085d6'
                                }).then(() => {
                                    location.reload();
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Refund Failed!',
                                    text: response.d.message
                                });
                            }
                        },
                        error: function (xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'An error occurred while processing refund. Please try again.'
                            });
                            console.error("Refund error:", error);
                        }
                    });
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="reg-page">

        <input type="hidden" id="hfAntiForgery" runat="server" />
        <input type="hidden" id="hdfPatient_ID" />
        <input type="hidden" id="hdn_regid" />

        <div class="pr-meta-bar">
            <div class="meta-left">
                <%--<span class="meta-title"><i class="fa fa-user-plus"></i> Patient Registration</span>--%>
            </div>
            <div class="meta-right"></div>
        </div>

        <!-- Patient Details -->
        <div class="pr-primary-settings">
            <h5 class="pr-section-title"><i class="fa fa-user"></i> Patient Information</h5>

            <!-- Row 1: MR No, Name (prefix + text), Relation (prefix + text), Age (unit + value + DOB) -->
            <div class="row">
                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label for="txt_Mrno">MR No</label>
                    <input type="text" id="txt_Mrno" class="form-control" disabled />
                </div>

                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label for="ddl_name">Name<span style="color: red;">*</span></label>
                    <select id="ddl_name" class="form-control">
                    </select>
                </div>

                <div class="col-lg-3 col-md-6 col-sm-9">
                    <label>&nbsp;</label>
                    <input name="dob" type="text" id="txt_name" class="form-control" placeholder="First Name" />
                    <span id="firstname-error" class="span_txt" style="display: none;">Please Enter First Name</span>
                </div>

                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label for="ddlRelation">Relation<span style="color: red;">*</span></label>
                    <select id="ddlRelation" class="form-control">
                        <option value="S/O">S/O</option>
                        <option value="W/O">W/O</option>
                        <option value="D/O">D/O</option>
                    </select>
                </div>

                <div class="col-lg-3 col-md-6 col-sm-9">
                    <label>&nbsp;</label>
                    <input type="text" id="txt_relation" class="form-control" placeholder="Relation Name" />
                    <span id="relation-error" class="span_txt" style="display: none;">Please Enter Last Name</span>
                </div>

                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label>&nbsp;</label>
                    <select onchange="CalculateDateOfBirth();" id="PrefixAge" class="form-control">
                        <option value="Year">Year</option>
                        <option value="Month">Month</option>
                        <option value="Day">Day</option>
                    </select>
                </div>

                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label for="txt_dob">DOB<span style="color: red;">*</span></label>
                    <input type="text" id="txt_dob" class="form-control" placeholder="Enter Age" onchange="CalculateDateOfBirth();" />
                </div>

                <div class="col-lg-1 col-md-3 col-sm-6">
                    <label>&nbsp;</label>
                    <input type="text" id="txtAge_yearss" class="form-control" placeholder="dd/mm/yy" />
                    <span id="age-error" class="span_txt" style="display: none;">Enter Age</span>
                </div>
            </div>

            <!-- Row 2: Gender, Marital Status, Mobile, Blood Group, CNIC, Other CNIC -->
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddl_Gender">Gender<span style="color: red;">*</span></label>
                    <select id="ddl_Gender" class="form-control">
                        <option value="0">Select Gender</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddl_status">Marital Status<span style="color: red;">*</span></label>
                    <select id="ddl_status" class="form-control">
                        <option value="0">Select Martial Status</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="txt_mobile">Mobile<span style="color: red;">*</span></label>
                    <input type="text" id="txt_mobile" class="form-control" placeholder="03xx-xxxxxxx" />
                    <span id="mobile-error" class="span_txt" style="display: none;">Please Enter Phone Number</span>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddl_bloodGroup">Blood Group</label>
                    <select id="ddl_bloodGroup" class="form-control">
                        <option value="0">Select Blood Group</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="txt_cnic">CNIC<span style="color: red;">*</span></label>
                    <input type="text" id="txt_cnic" class="form-control" placeholder="xxxxx-xxxxxxx-x" />
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="txt_OtherCnic">Other CNIC</label>
                    <input type="text" id="txt_OtherCnic" class="form-control" placeholder="xxxxx-xxxxxxx-x" />
                </div>
            </div>
        </div>

        <!-- Contact, Address & Payment -->
        <div class="pr-primary-settings">
            <h5 class="pr-section-title"><i class="fa fa-map-marker"></i> Contact, Address &amp; Payment</h5>

            <!-- Row 3: Country, Province, City, Area, Payment method, Bank/Cash -->
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>Country</label>
                    <select id="ddlCountry" class="form-control">
                        <option value="0">Select Country</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddlstate">Province</label>
                    <select id="ddlstate" class="form-control">
                        <option value="0">Select Province</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="txtcity">City</label>
                    <select id="txtcity" class="form-control">
                        <option value="0">Select City</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="txtarea">Area</label>
                    <select id="txtarea" class="form-control">
                        <option value="0">Select Area</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddlbankcash">Payment method</label>
                    <select id="ddlbankcash" class="form-control" name="payment">
                        <option value="02">Bank</option>
                        <option value="01" selected>Cash</option>
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddlbank">Bank/Cash</label>
                    <select id="ddlbank" class="form-control">
                    </select>
                </div>
            </div>

            <!-- Row 4: Address, Fee, Monitoring -->
            <div class="row">
                <div class="col-lg-6 col-md-6 col-sm-12">
                    <label for="txt_Address">Address<span style="color: red;">*</span></label>
                    <input type="text" id="txt_Address" class="form-control" placeholder="House / Street / Town" />
                    <span id="address-error" class="span_txt" style="display: none;">Please Enter Address</span>
                </div>

                <div class="col-lg-2 col-md-3 col-sm-6">
                    <label for="lblfee">Fee<span style="color: red;">*</span></label>
                    <input type="text" id="txtCardFee" class="form-control" />
                </div>

                <!-- Monitoring (hidden by default) -->
                <div class="col-lg-4 col-md-3 col-sm-6" id="MonitoringDiv">
                    <label>Monitoring</label>
                    <label class="lab-check"><input type="checkbox" id="chkMonitoring" /> Enable Monitoring</label>
                </div>
            </div>
        </div>

        <!-- Buttons -->
        <div class="row reg-actions">
            <div class="col-12">
                <div class="col-lg-8">
                    <div class="row">
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="SavePatient_Data" class="btn-primry" onclick="SavePatient();" value="Save&Print" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnlist" class="btn-gray" onclick="window.location = 'RegList.aspx'" value="View" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintReceipt()" value="Print" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6" id="divcardfront">
                        <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCardFront" onclick="PrintPatientCard()" value="Front Card" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6" id="divcardback">
                        <input type="button" name="btnPrintCard" class="btn-primry" id="btnPrintCardBack" onclick="PrintPatientBackCard()" value="Back Card" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnRefund" class="btn btn-primry" onclick="RefundRegisterFee()" value="Refund" />
                    </div>
                    <div class="col-lg-2 col-md-3 col-sm-6">
                        <input type="button" id="btnVoucher" class="btn btn-primry" onclick="PrintVoucher()" value="Voucher" />
                    </div>
                </div>
                </div>
                
            </div>
        </div>

    </div>
</asp:Content>