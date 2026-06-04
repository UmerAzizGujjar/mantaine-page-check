<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ZakatDonationForm.aspx.cs" Inherits="PMS.Modules.Billing.ZakatDonationForm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/Toaster.css" rel="stylesheet" />
    <script src="../../wwwroot/THEME_TIBBIT/CustomJs/RegPatient.js" type="text/javascript"></script>
    <link href="../../wwwroot/lib/sweetalert/RegPat.css" rel="stylesheet" />
    <style>
        .required-field::after {
            content: " *";
            color: red;
        }
        .validation-error {
            color: red;
            font-size: 12px;
            display: none;
        }
        .form-group {
            margin-bottom: 10px;
        }
    </style>
    <script type="text/javascript">
        var currentRecordId = 0;

        $(document).ready(function () {
            initializeForm();
            loadNextIds();
            loadDropdowns();

            initializeSelect2();

            $('#ddlPaymentType').change(function () {
                var val = $(this).val();
                if (val === 'Cheque') {
                    $('#divChequeNo').show();
                    $('#txtChequeNo').attr('required', 'required');
                } else {
                    $('#divChequeNo').hide();
                    $('#txtChequeNo').removeAttr('required');
                    $('#txtChequeNo').val('');
                }
            });

            var urlParams = new URLSearchParams(window.location.search);
            var recordId = urlParams.get('recordId');
            if (recordId) {
                currentRecordId = parseInt(recordId);
                $('#txtRecordID').val(currentRecordId);
                setTimeout(function () {
                    LoadForEdit(currentRecordId);
                }, 500);
            } else {
                setCurrentDateTime();
            }
        });

        function initializeSelect2() {
            if ($.fn.select2) {
                $('#ddlProjectName,#ddlDonationType,#ddlPaymentType').select2({ width: '100%' });
            }
        }

        function refreshSelect2(id) {
            if ($.fn.select2 && $(id).hasClass('select2-hidden-accessible')) {
                $(id).trigger('change.select2');
            }
        }

        function initializeForm() {
            // Set default datetime to now
            var now = new Date();
            var yyyy = now.getFullYear();
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var dd = String(now.getDate()).padStart(2, '0');
            var hh = String(now.getHours()).padStart(2, '0');
            var min = String(now.getMinutes()).padStart(2, '0');
            $('#txtDateTime').val(yyyy + '-' + mm + '-' + dd + 'T' + hh + ':' + min);
        }

        function setCurrentDateTime() {
            var now = new Date();
            var yyyy = now.getFullYear();
            var mm = String(now.getMonth() + 1).padStart(2, '0');
            var dd = String(now.getDate()).padStart(2, '0');
            var hh = String(now.getHours()).padStart(2, '0');
            var min = String(now.getMinutes()).padStart(2, '0');
            $('#txtDateTime').val(yyyy + '-' + mm + '-' + dd + 'T' + hh + ':' + min);
        }

        function loadNextIds() {
            // Only load next IDs if creating new record
            if (currentRecordId === 0) {
                $.ajax({
                    type: "POST",
                    url: "ZakatDonationForm.aspx/GetNextDonorID",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#txtDonorID').val(response.d);
                    },
                    error: function () {
                        $('#txtDonorID').val(1);
                        showError('Failed to load Donor ID');
                    }
                });

                $.ajax({
                    type: "POST",
                    url: "ZakatDonationForm.aspx/GetNextReceiptNo",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $('#txtReceiptNo').val(response.d);
                    },
                    error: function () {
                        $('#txtReceiptNo').val(1);
                        showError('Failed to load Receipt No');
                    }
                });
            }
        }

        function loadDropdowns() {
            // Load Project Names
            $.ajax({
                type: "POST",
                url: "ZakatDonationForm.aspx/GetProjectNames",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        // Parse the JSON string from response.d
                        var data = response.d;
                        if (typeof data === 'string') {
                            data = JSON.parse(data);
                        }
                        
                        if (data && data.length > 0) {
                            var html = '<option value="">-- Select Project --</option>';
                            $.each(data, function (i, item) {
                                html += '<option value="' + escapeHtml(item.DataValue_Name) + '">' + 
                                        escapeHtml(item.DataValue_Description || item.DataValue_Name) + '</option>';
                            });
                            $('#ddlProjectName').html(html);
                            refreshSelect2('#ddlProjectName');
                        } else {
                            $('#ddlProjectName').html('<option value="">-- No Projects Available --</option>');
                            refreshSelect2('#ddlProjectName');
                        }
                    } catch (e) {
                        console.error('Error parsing Project Names:', e);
                        $('#ddlProjectName').html('<option value="">-- Error Loading --</option>');
                        refreshSelect2('#ddlProjectName');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('AJAX Error loading Project Names:', error, xhr.responseText);
                    $('#ddlProjectName').html('<option value="">-- Error Loading --</option>');
                    refreshSelect2('#ddlProjectName');
                }
            });

            // Load Donation Types
            $.ajax({
                type: "POST",
                url: "ZakatDonationForm.aspx/GetDonationTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        // Parse the JSON string from response.d
                        var data = response.d;
                        if (typeof data === 'string') {
                            data = JSON.parse(data);
                        }
                        
                        if (data && data.length > 0) {
                            var html = '<option value="">-- Select Type --</option>';
                            $.each(data, function (i, item) {
                                html += '<option value="' + escapeHtml(item.DataValue_Name) + '">' + 
                                        escapeHtml(item.DataValue_Description || item.DataValue_Name) + '</option>';
                            });
                            $('#ddlDonationType').html(html);
                            refreshSelect2('#ddlDonationType');
                        } else {
                            $('#ddlDonationType').html('<option value="">-- No Types Available --</option>');
                            refreshSelect2('#ddlDonationType');
                        }
                    } catch (e) {
                        console.error('Error parsing Donation Types:', e);
                        $('#ddlDonationType').html('<option value="">-- Error Loading --</option>');
                        refreshSelect2('#ddlDonationType');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('AJAX Error loading Donation Types:', error, xhr.responseText);
                    $('#ddlDonationType').html('<option value="">-- Error Loading --</option>');
                    refreshSelect2('#ddlDonationType');
                }
            });

            // Load Payment Types
            $.ajax({
                type: "POST",
                url: "ZakatDonationForm.aspx/GetPaymentTypes",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        // Parse the JSON string from response.d
                        var data = response.d;
                        if (typeof data === 'string') {
                            data = JSON.parse(data);
                        }
                        
                        if (data && data.length > 0) {
                            var html = '<option value="">-- Select Type --</option>';
                            $.each(data, function (i, item) {
                                html += '<option value="' + escapeHtml(item.DataValue_Name) + '">' + 
                                        escapeHtml(item.DataValue_Description || item.DataValue_Name) + '</option>';
                            });
                            $('#ddlPaymentType').html(html);
                            refreshSelect2('#ddlPaymentType');
                        } else {
                            // Provide default payment types if none found
                            $('#ddlPaymentType').html('<option value="">-- Select Type --</option><option value="Cash">Cash</option><option value="Cheque">Cheque</option>');
                            refreshSelect2('#ddlPaymentType');
                        }
                    } catch (e) {
                        console.error('Error parsing Payment Types:', e);
                        // Provide default payment types on error
                        $('#ddlPaymentType').html('<option value="">-- Select Type --</option><option value="Cash">Cash</option><option value="Cheque">Cheque</option>');
                        refreshSelect2('#ddlPaymentType');
                    }
                },
                error: function (xhr, status, error) {
                    console.error('AJAX Error loading Payment Types:', error, xhr.responseText);
                    // Provide default payment types on error
                    $('#ddlPaymentType').html('<option value="">-- Select Type --</option><option value="Cash">Cash</option><option value="Cheque">Cheque</option>');
                    refreshSelect2('#ddlPaymentType');
                }
            });
        }

        function escapeHtml(text) {
            if (!text) return '';
            return $('<div>').text(text).html();
        }

        function validateForm() {
            var name = $('#txtDonorName').val().trim();
            var amount = $('#txtAmount').val().trim();
            var phone = $('#txtPhone').val().trim();
            var address = $('#txtAddress').val().trim();
            var donationType = $('#ddlDonationType').val();
            var paymentType = $('#ddlPaymentType').val();
            var cheque = $('#txtChequeNo').val().trim();
            var details = $('#txtDetails').val().trim();

            // Clear previous errors
            $('.validation-error').hide();

            // Required field validations
            if (name === '') {
                showError('Donor Name is required');
                return false;
            }
            if (!/^[a-zA-Z\s\.\-']+$/.test(name) || name.length > 255) {
                showError('Name must contain only letters, spaces, dots or hyphens (max 255 chars)');
                return false;
            }

            if (amount === '' || isNaN(amount) || Number(amount) <= 0) {
                showError('Enter a valid positive Amount');
                return false;
            }

            if (phone !== '' && !/^\+?92?[0-9]{10}$|^[0-9\-\s\(\)]{10,20}$/.test(phone)) {
                showError('Enter a valid Phone Number (e.g., +923001234567)');
                return false;
            }

            if (address !== '' && address.length > 500) {
                showError('Address must be 500 characters or less');
                return false;
            }

            if (donationType === '') {
                showError('Donation Type is required');
                return false;
            }

            if (paymentType === '') {
                showError('Payment Type is required');
                return false;
            }

            if (paymentType === 'Cheque' && cheque === '') {
                showError('Cheque No is required for Cheque payments');
                return false;
            }

            if (cheque !== '' && !/^\d{6,20}$/.test(cheque)) {
                showError('Cheque No must be 6-20 digits');
                return false;
            }

            if (details !== '' && details.length > 1000) {
                showError('Details must be 1000 characters or less');
                return false;
            }

            return true;
        }

        function showError(message) {
            Swal.fire({ icon: 'error', title: 'Error', text: message });
        }

        function showSuccess(message, cb) {
            Swal.fire({ icon: 'success', title: 'Success', text: message }).then(function () {
                if (cb) cb();
            });
        }

        function SaveDonation() {
            if (!validateForm()) return;

            var recordId = parseInt($('#txtRecordID').val() || '0');
            var dto = {
                RecordID: recordId,
                DonorID: parseInt($('#txtDonorID').val() || '0'),
                DonorReceiptNo: parseInt($('#txtReceiptNo').val() || '0'),
                DonorName: $('#txtDonorName').val(),
                PhoneNo: $('#txtPhone').val(),
                DonorAddress: $('#txtAddress').val(),
                ProjectName: $('#ddlProjectName').val(),
                DonationType: $('#ddlDonationType').val(),
                PaymentType: $('#ddlPaymentType').val(),
                ChequeNo: $('#txtChequeNo').val(),
                DonorDetail: $('#txtDetails').val(),
                ReceiptAmount: parseFloat($('#txtAmount').val()),
                TransactionDateTime: $('#txtDateTime').val()
            };

            var antiForgeryToken = '<%= Session["AntiForgeryToken"] %>';

            $.ajax({
                type: "POST",
                url: "ZakatDonationForm.aspx/SaveDonation",
                data: JSON.stringify({ donation: dto, AntiForgeryToken: antiForgeryToken }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    if (typeof result === 'string') result = JSON.parse(result);

                    if (result && result.Success) {
                        showSuccess(result.Message + ' RecordID: ' + result.RecordID, function () {
                            window.location = 'ZakatDonationForm.aspx';
                        });
                    } else {
                        showError(result.Message || 'Save failed');
                    }
                },
                error: function (xhr, status, error) {
                    showError('Error while saving: ' + error);
                    console.log(xhr.responseText);
                }
            });
        }

        function clearForm() {
            $('#txtDonorName').val('');
            $('#txtPhone').val('');
            $('#txtAddress').val('');
            $('#ddlProjectName').val('').trigger('change');
            $('#ddlDonationType').val('').trigger('change');
            $('#ddlPaymentType').val('').trigger('change');
            $('#txtChequeNo').val('');
            $('#txtDetails').val('');
            $('#txtAmount').val('');
            $('#divChequeNo').hide();
            setCurrentDateTime();
        }

        function LoadForEdit(recordId) {
            $.ajax({
                type: "POST",
                url: "ZakatDonationForm.aspx/GetDonation",
                data: JSON.stringify({ recordId: recordId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var d = response.d;
                    if (typeof d === 'string') d = JSON.parse(d);
                    if (!d) {
                        showError('Record not found');
                        return;
                    }

                    $('#txtRecordID').val(d.RecordID);
                    $('#txtDonorID').val(d.DonorID);
                    $('#txtReceiptNo').val(d.DonorReceiptNo);
                    $('#txtDonorName').val(d.DonorName);
                    $('#txtPhone').val(d.PhoneNo);
                    $('#txtAddress').val(d.DonorAddress);
                    $('#ddlProjectName').val(d.ProjectName).trigger('change');
                    $('#ddlDonationType').val(d.DonationType).trigger('change');
                    $('#ddlPaymentType').val(d.PaymentType).trigger('change');

                    if (d.PaymentType === 'Cheque') {
                        $('#divChequeNo').show();
                        $('#txtChequeNo').val(d.ChequeNo);
                    } else {
                        $('#divChequeNo').hide();
                    }

                    $('#txtDetails').val(d.DonorDetail);
                    $('#txtAmount').val(d.ReceiptAmount);
                    $('#txtDateTime').val(formatDateForInput(d.TransactionDateTime));
                },
                error: function () {
                    showError('Error loading record');
                }
            });
        }

        function formatDateForInput(d) {
            var dt = parseServerDate(d);
            if (!dt) return '';
            var yyyy = dt.getFullYear();
            var mm = (dt.getMonth() + 1).toString().padStart(2, '0');
            var dd = dt.getDate().toString().padStart(2, '0');
            var hh = dt.getHours().toString().padStart(2, '0');
            var min = dt.getMinutes().toString().padStart(2, '0');
            return yyyy + '-' + mm + '-' + dd + 'T' + hh + ':' + min;
        }

        function parseServerDate(value) {
            if (!value) return null;

            if (Object.prototype.toString.call(value) === '[object Date]') {
                return isNaN(value.getTime()) ? null : value;
            }

            if (typeof value === 'string') {
                var msJson = /\/Date\((\d+)\)\//.exec(value);
                if (msJson && msJson[1]) {
                    var fromMs = new Date(parseInt(msJson[1], 10));
                    return isNaN(fromMs.getTime()) ? null : fromMs;
                }
            }

            var parsed = new Date(value);
            return isNaN(parsed.getTime()) ? null : parsed;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12">
            <div class="card">
             
                
                <!-- Hidden field to track edit mode -->
                <input type="hidden" id="txtRecordID" value="0" />
                
                <div class="row">
                    <div class="col-lg-1">
                        <label>Donor ID</label>
                        <input type="text" id="txtDonorID" class="form-control" disabled />
                    </div>
                    <div class="col-lg-2">
                        <label>Receipt No</label>
                        <input type="text" id="txtReceiptNo" class="form-control" disabled />
                    </div>
                    <div class="col-lg-3">
                        <label class="required-field">Donor Name</label>
                        <input type="text" id="txtDonorName" class="form-control" placeholder="Enter donor name" maxlength="255" />
                    </div>
                    <div class="col-lg-2">
                        <label>Phone</label>
                        <input type="text" id="txtPhone" class="form-control" placeholder="+923001234567" />
                    </div>
                    <div class="col-lg-4">
                        <label>Address</label>
                        <input type="text" id="txtAddress" class="form-control" placeholder="Enter address" maxlength="500" />
                    </div>
                </div>
                
                <div class="row" style="margin-top:10px;">
                    <div class="col-lg-3">
                        <label class="required-field">Project Name</label>
                        <select id="ddlProjectName" class="form-control">
                            <option value="">-- Loading --</option>
                        </select>
                    </div>
                    <div class="col-lg-2">
                        <label class="required-field">Donation Type</label>
                        <select id="ddlDonationType" class="form-control">
                            <option value="">-- Loading --</option>
                        </select>
                    </div>
                    <div class="col-lg-2">
                        <label class="required-field">Payment Type</label>
                        <select id="ddlPaymentType" class="form-control">
                            <option value="">-- Loading --</option>
                        </select>
                    </div>
                    <div class="col-lg-2" id="divChequeNo" style="display:none;">
                        <label>Cheque No</label>
                        <input type="text" id="txtChequeNo" class="form-control" placeholder="Enter cheque number" />
                    </div>
                    <div class="col-lg-3">
                        <label class="required-field">Amount</label>
                        <input type="text" id="txtAmount" class="form-control" placeholder="Enter amount" />
                    </div>
                </div>
                
                <div class="row" style="margin-top:10px;">
                    <div class="col-lg-8">
                        <label>Details / Notes</label>
                        <textarea id="txtDetails" class="form-control" rows="3" placeholder="Enter additional details" maxlength="1000"></textarea>
                    </div>
                    <div class="col-lg-4">
                        <label class="required-field">Transaction Date/Time</label>
                        <input type="datetime-local" id="txtDateTime" class="form-control" disabled="disabled" />
                    </div>
                </div>
                
                <div class="row" style="margin-top:15px;">
                    <div class="col-lg-2">
                        <input type="button" class="btn btn-primry" value="Save" onclick="SaveDonation();" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button" class="btn btn-gray" value="View List" onclick="window.location='ZakatDonationList.aspx'" />
                    </div>
                    <div class="col-lg-2">
                        <input type="button" class="btn btn-primry" value="New" onclick="window.location='ZakatDonationForm.aspx'" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>