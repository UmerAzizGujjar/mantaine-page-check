<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterUser.aspx.cs" Inherits="PMS.Modules.Accounts.RegisterUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/registeruser.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <style type="text/css">
        /* ===== User Rights modal: small, scrolls, toggle switches (uses theme colours, works in dark mode) ===== */
        .rights-modal .modal-dialog { width: min(860px, 94vw); margin: 4vh auto; }
        .rights-modal .modal-content { border-radius: 14px; overflow: hidden; border: 0; box-shadow: 0 24px 60px rgba(15, 23, 42, .35); }
        .rights-modal .modal-header { padding: 12px 18px; border-bottom: 1px solid rgba(127, 127, 127, .25); background: var(--theme-accent, #EFA63E); color: var(--theme-on-accent, #1b2a41); }
        .rights-modal .modal-title { margin: 0; font-size: 16px; font-weight: 700; color: inherit; }
        .rights-modal .modal-header { display: flex; align-items: center; justify-content: space-between; }
        .rights-modal .modal-header:before, .rights-modal .modal-header:after { content: none; display: none; }
        .rights-modal .modal-header .close { position: static !important; float: none !important; width: auto !important; height: auto !important; margin: 0 !important; padding: 0 2px !important; background: transparent !important; border: 0 !important; box-shadow: none !important; font-size: 26px; line-height: 1; color: inherit; opacity: .8; text-shadow: none; }
        .rights-modal .modal-header .close:hover { opacity: 1; }
        .rights-modal .modal-body { max-height: min(54vh, 420px); overflow-y: auto; overflow-x: hidden; padding: 14px 18px; overscroll-behavior: contain; }
        .rights-modal .modal-footer { padding: 10px 18px; border-top: 1px solid rgba(127, 127, 127, .25); text-align: right; }

        .rights-modal .rt-fields { display: grid; grid-template-columns: minmax(0, 300px) minmax(0, 1fr); gap: 10px 16px; align-items: end; margin-bottom: 14px; padding-bottom: 14px; border-bottom: 1px dashed rgba(127, 127, 127, .35); }
        .rights-modal .rt-field label { display: block; margin: 0 0 4px; font-size: 12px; font-weight: 700; letter-spacing: .3px; text-transform: uppercase; opacity: .75; }
        .rights-modal .rt-field .rt-input { display: block; width: 100% !important; height: 36px; margin: 0 !important; padding: 0 12px; border: 1px solid rgba(127, 127, 127, .45); border-radius: 8px; background: transparent; color: inherit; }
        .rights-modal .rt-field select:not(.select2-hidden-accessible) { width: 100% !important; height: 36px; }
        .rights-modal .rt-field .select2-container { width: 100% !important; }
        .rights-modal .select2-search:after { content: none !important; display: none !important; }   /* styleMaster adds a 2nd magnifier that wraps under the search box */
        .rights-modal .select2-container--open .select2-dropdown { z-index: 1060; }

        .rights-modal .rt-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 8px 12px; }
        .rights-modal .rt-item { position: relative; display: flex; align-items: center; justify-content: space-between; gap: 12px; margin: 0; padding: 8px 12px; border: 1px solid rgba(127, 127, 127, .28); border-radius: 10px; background: rgba(127, 127, 127, .06); font-weight: 600; cursor: pointer; user-select: none; transition: background-color .15s ease, border-color .15s ease; }
        .rights-modal .rt-item:hover { background: rgba(127, 127, 127, .13); }
        .rights-modal .rt-item:has(input:checked) { border-color: var(--theme-accent, #EFA63E); background: var(--theme-accent-soft, rgba(239, 166, 62, .14)); }
        .rights-modal .rt-text { min-width: 0; font-size: 13px; line-height: 1.3; color: inherit; }

        /* the toggle: the real checkbox sits invisibly on top, so clicks / keyboard / .prop('checked') all keep working */
        .rights-modal .rt-switch { position: relative; flex: 0 0 auto; width: 40px; height: 22px; }
        .rights-modal .rt-switch input[type="checkbox"] { position: absolute; z-index: 2; top: 0; left: 0; width: 100% !important; height: 100% !important; margin: 0 !important; padding: 0; opacity: 0; cursor: pointer; }
        .rights-modal .rt-slider { position: absolute; inset: 0; border-radius: 999px; background: #cbd5e1; transition: background-color .18s ease; }
        .rights-modal .rt-slider:before { content: ""; position: absolute; top: 3px; left: 3px; width: 16px; height: 16px; border-radius: 50%; background: #fff; box-shadow: 0 1px 3px rgba(0, 0, 0, .35); transition: transform .18s ease; }
        .rights-modal .rt-switch input:checked + .rt-slider { background: var(--theme-accent, #EFA63E); }
        .rights-modal .rt-switch input:checked + .rt-slider:before { transform: translateX(18px); }
        .rights-modal .rt-switch input:focus-visible + .rt-slider { box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(239, 166, 62, .35)); }
        html[data-theme="dark"] .rights-modal .rt-slider { background: #475569; }
        html[data-theme="dark"] .rights-modal .rt-switch input:checked + .rt-slider { background: var(--theme-accent, #0f9488); }

        /* search box (filters the toggles by their label) */
        .rights-modal .rt-search { display: flex; align-items: center; gap: 8px; height: 36px; padding: 0 6px 0 12px; border: 1px solid rgba(127, 127, 127, .45); border-radius: 999px; transition: border-color .15s ease, box-shadow .15s ease; }
        .rights-modal .rt-search:focus-within { border-color: var(--theme-accent, #EFA63E); box-shadow: 0 0 0 3px var(--theme-accent-ring, rgba(239, 166, 62, .3)); }
        .rights-modal .rt-search .fa { opacity: .6; }
        .rights-modal .rt-search input[type="text"] { flex: 1 1 auto; width: auto !important; min-width: 0; height: 32px !important; margin: 0 !important; padding: 0 !important; border: 0 !important; outline: 0 !important; background: transparent !important; box-shadow: none !important; color: inherit; }
        .rights-modal .rt-count { flex: 0 0 auto; font-size: 11px; font-weight: 700; opacity: .7; white-space: nowrap; }
        .rights-modal .rt-search .rt-clear { display: none; position: static !important; width: 24px !important; height: 24px !important; left: auto !important; margin: 0 !important; padding: 0 !important; border: 0 !important; border-radius: 50% !important; background: rgba(127, 127, 127, .2) !important; color: inherit !important; font-size: 16px; line-height: 22px; text-align: center; cursor: pointer; }
        .rights-modal .rt-search:has(input:not(:placeholder-shown)) .rt-clear { display: block; }
        .rights-modal .rt-item.rt-hide { display: none !important; }
        .rights-modal .rt-empty { padding: 26px 0; text-align: center; font-weight: 600; opacity: .65; }

        @media (max-width: 575px) {
            .rights-modal .rt-fields { grid-template-columns: minmax(0, 1fr); }
            .rights-modal .modal-dialog { margin: 2vh auto; }
            .rights-modal .modal-body { max-height: 66vh; padding: 12px; }
            .rights-modal .rt-grid { grid-template-columns: 1fr; }
        }
        @media (prefers-reduced-motion: reduce) { .rights-modal .rt-slider, .rights-modal .rt-slider:before, .rights-modal .rt-item { transition: none; } }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var UserID = '<%= Request.QueryString["UserID"] %>';
            fillCashInHand();
            fillCasher();
            if (UserID != "") {
                populate_data(UserID);
            }
        });
        function showmodal() {
            $("#UserModel").modal('show');
        }

        // ----- User Rights modal: the search box filters the toggles by their label -----
        $(function () {
            var $m = $('#UserModel'), $q = $('#rtSearch');
            function applyFilter() {
                var t = $.trim($q.val()).toLowerCase(), shown = 0, total = 0;
                $m.find('.rt-item').each(function () {
                    var hit = !t || $(this).find('.rt-text').text().toLowerCase().indexOf(t) > -1;
                    $(this).toggleClass('rt-hide', !hit);
                    total++;
                    if (hit) { shown++; }
                });
                $('#rtEmpty').toggle(shown === 0);
                $('#rtCount').text(t ? shown + ' of ' + total : '');
            }
            $q.on('input keyup search', applyFilter);
            $q.on('keydown', function (e) { if (e.which === 13) { e.preventDefault(); } });   // Enter must not submit the page
            $('#rtClear').on('click', function () { $q.val('').trigger('input'); $q.trigger('focus'); });
            $m.on('shown.bs.modal', function () {
                if (window.matchMedia && window.matchMedia('(hover: hover)').matches) { $q.trigger('focus'); }
            });
            $m.on('hidden.bs.modal', function () { $q.val(''); applyFilter(); $m.find('.modal-body').scrollTop(0); });
        });

        function populate_data(UserID) {
            $.ajax({
                type: "POST",
                url: "RegisterUser.aspx/Populate_Data",
                data: JSON.stringify({ UserID: UserID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    $('#saveBtn').val('Update User');
                    // Disable password fields
                    $('#Password').prop('disabled', true);
                    $('#ConfirmPassword').prop('disabled', true);
                    // Text inputs
                    $('#UserName').val(data.UserName);
                    $('#Email').val(data.Email);
                    $('#Mobile').val(data.mobileno);
                    $('#EmpCode').val(data.EmpCode);
                    setTimeout(function () {
                        $('#ddlCashInHand').val(data.Accounts).trigger('change');
                    }, 200);
                    setTimeout(function () {
                        $('#ddlcasher').val(data.casher).trigger('change');
                    }, 200);
                    // Checkboxes
                    $('#AllowPatientEdit').prop('checked', data.AllowPatientEdit);
                    $('#Allow_ReglistPrint').prop('checked', data.AllowRegListPrint);
                    $('#AllowPatientDelete').prop('checked', data.AllowPatientDelete);
                    $('#AllPatientRecords').prop('checked', data.AllPatientRecords);
                    $('#AllowUnapproveVouchers').prop('checked', data.AllowUnapproveVoucher);
                    $('#OTPUsers').prop('checked', data.OTPUsers);
                    $('#AllowBillDelete').prop('checked', data.AllowBillDelete);
                    $('#AllowTestRate').prop('checked', data.AllowTestRate);
                    $('#AllowOPD').prop('checked', data.OpdAllow);
                    $('#AllowLab').prop('checked', data.allow_lab);
                    $('#AllowUltra').prop('checked', data.allow_ultra);
                    $('#AllowCtscan').prop('checked', data.allow_ctscan);
                    $('#AllowXray').prop('checked', data.allow_xray);
                    $('#AllowB_Bank').prop('checked', data.allow_b_bank);
                    $('#AllowPharmacy').prop('checked', data.AllowPharmacy);
                    $('#GeneralItems').prop('checked', data.AllowGeneralItems);
                    $('#ShowBudgetBtn').prop('checked', data.IsShowBudget);
                    $('#InventoryUnApprove').prop('checked', data.IsInventoryUnApprove);
                    $('#PurchaseUnApprove').prop('checked', data.PurchaseUnApprove);
                    $('#PRFsNotifications').prop('checked', data.IsNotificationViewed);
                    $('#RateBox').prop('checked', data.allowtestbox);
                    $('#AllowToAccessAllTest').prop('checked', data.AllowToAccessAllTest);
                    $('#AllowCardio').prop('checked', data.allow_cardio);
                    $('#IsAnonymous').prop('checked', data.IsAnonymous);
                    $('#AllowEditEmergency').prop('checked', data.EditEmergency);
                    $('#AllowBillUpdate').prop('checked', data.Allow_bill_edit);
                    $('#AllowEmergency_adm_dis').prop('checked', data.Emergency_adm_dis);
                    $('#BlockUser').prop('checked', data.BlockUser);
                    $('#AllowemergencyDiscount').prop('checked', data.Allow_emer_disc);
                    $('#AllowRadiologylist').prop('checked', data.AllowRadiologylist);
                    $('#AllowReferIPD').prop('checked', data.AllowReferIPD);
                    $('#AllowRecipe').prop('checked', data.Allow_Recipe);
                    $('#AllowActiveItems').prop('checked', data.AllowActiveItems);
                    $('#AllowBirthCertificate').prop('checked', data.AllowBirthCertificate);
                    $('#AllowDeathDetails').prop('checked', data.AllowDeathDetails);
                    $('#AllowSaleReturn').prop('checked', data.AllowSaleReturn);
                    $('#AllowStudentUpdate').prop('checked', data.AllowStudentUpdate);
                    $('#RadiologyAllList').prop('checked', data.RadiologyAllList);
                    $('#AllowRadiologyApproval').prop('checked', data.Radiology_result_Approval);
                    $('#AllowAdjustment').prop('checked', data.AllowAdjustment);
                    $('#Allowradiologyapprove').prop('checked', data.Allowradiologyapprove);
                    $('#Rejectradiology').prop('checked', data.Rejectradiology);
                    $('#AlllowPAtientAdd').prop('checked', data.AllowAddPatient);
                    $('#AllowSamplelist').prop('checked', data.AllowSamplelist);
                    $('#AllowRegisterRefund').prop('checked', data.AllowRegisterRefund);
                    $('#Allow_Return_Queue').prop('checked', data.Allow_Return_Queue);
                    
                    $('#AllowRateEdit').prop('checked', data.AllowRateEdit);
                    $('#AllowUndischarge').prop('checked', data.AllowUndischarge);
                    $('#AllDoctorTemplate').prop('checked', data.AllDoctorTemplate);
                    $('#AllowDiscountAssign').prop('checked', data.AllowDiscountAssign);
                    $('#AllowTill').prop('checked', data.AllowTill);
                    $('#AllowLineDiscount').prop('checked', data.AllowLineDiscount);
                    $('#AllowApprovalitem').prop('checked', data.AllowApprovalitem);
                    $('#AllowTestlistDoctor').prop('checked', data.AllowTestlistDoctor);
                    $('#Allow_Medication_Edit').prop('checked', data.Allow_Medication_Edit);
                    $('#Allow_Pending_Approval_List').prop('checked', data.AllowPendingApprovalList);
                },
                error: function (xhr, status, error) {
                    alert("Error: " + xhr.responseText);
                }
            });
        }

        function CreateUser() {
            var Valid = true;
            var UserIDfromURL = '<%= Request.QueryString["UserID"] %>';
            var UserName = $('#UserName').val();
            var Email = $('#Email').val();
            var Password = $('#Password').val();
            var ConfirmPassword = $('#ConfirmPassword').val();
            var Mobile = $('#Mobile').val();
            var Accounts = $('#ddlCashInHand :selected').val();
            var AllowPatientEdit = $('#AllowPatientEdit').prop('checked');
            var AllowPatientDelete = $('#AllowPatientDelete').prop('checked');
            var AllPatientRecords = $('#AllPatientRecords').prop('checked');
            var AllowUnapproveVouchers = $('#AllowUnapproveVouchers').prop('checked');
            var OTPUsers = $('#OTPUsers').prop('checked');
            var AllowBillDelete = $('#AllowBillDelete').prop('checked');
            var AllowTestRate = $('#AllowTestRate').prop('checked');
            var AllowOPD = $('#AllowOPD').prop('checked');
            var AllowLab = $('#AllowLab').prop('checked');
            var AllowUltra = $('#AllowUltra').prop('checked');
            var AllowCtscan = $('#AllowCtscan').prop('checked');
            var AllowXray = $('#AllowXray').prop('checked');
            var AllowB_Bank = $('#AllowB_Bank').prop('checked');
            var AllowPharmacy = $('#AllowPharmacy').prop('checked');
            var GeneralItems = $('#GeneralItems').prop('checked');
            var ShowBudgetBtn = $('#ShowBudgetBtn').prop('checked');
            var InventoryUnApprove = $('#InventoryUnApprove').prop('checked');
            var PurchaseUnApprove = $('#PurchaseUnApprove').prop('checked');
            var PRFsNotifications = $('#PRFsNotifications').prop('checked');
            var RateBox = $('#RateBox').prop('checked');
            var AllowToAccessAllTest = $('#AllowToAccessAllTest').prop('checked');
            var AllowCardio = $('#AllowCardio').prop('checked');
            var IsAnonymous = $('#IsAnonymous').prop('checked');
            var EditEmergency = $('#AllowEditEmergency').prop('checked');
            var AllowEmergency_adm_dis = $('#AllowEmergency_adm_dis').prop('checked');
            var AllowRadiologylist = $('#AllowRadiologylist').prop('checked');
            var AllowBillUpdate = $('#AllowBillUpdate').prop('checked');
            var BlockUser = $('#BlockUser').prop('checked');
            var AllowemergencyDiscount = $('#AllowemergencyDiscount').prop('checked');
            var AllowReferIPD = $('#AllowReferIPD').prop('checked');
            var AllowRecipe = $('#AllowRecipe').prop('checked');
            var AllowActiveItems = $('#AllowActiveItems').prop('checked');
            var AllowBirthCertificate = $('#AllowBirthCertificate').prop('checked');
            var AllowDeathDetails = $('#AllowDeathDetails').prop('checked');
            var AllowSaleReturn = $('#AllowSaleReturn').prop('checked');
            var AllowStudentUpdate = $('#AllowStudentUpdate').prop('checked');
            var RadiologyAllList = $('#RadiologyAllList').prop('checked');
            var AllowRadiologyApproval = $('#AllowRadiologyApproval').prop('checked');
            var AllowAdjustment = $('#AllowAdjustment').prop('checked');
            var Allowradiologyapprove = $('#Allowradiologyapprove').prop('checked');
            var Rejectradiology = $('#Rejectradiology').prop('checked');
            var AlllowPAtientAdd = $('#AlllowPAtientAdd').prop('checked');
            var AllowSamplelist = $('#AllowSamplelist').prop('checked');
            var AllowRegisterRefund = $('#AllowRegisterRefund').prop('checked');
            var Allow_Return_Queue = $('#Allow_Return_Queue').prop('checked');
            var AllowRateEdit = $('#AllowRateEdit').prop('checked');
            var AllowUndischarge = $('#AllowUndischarge').prop('checked');
            var AllDoctorTemplate = $('#AllDoctorTemplate').prop('checked');
            var AllowDiscountAssign = $('#AllowDiscountAssign').prop('checked');
            var AllowTill = $('#AllowTill').prop('checked');
            var AllowLineDiscount = $('#AllowLineDiscount').prop('checked');
            var AllowApprovalitem = $('#AllowApprovalitem').prop('checked');
            var AllowTestlistDoctor = $('#AllowTestlistDoctor').prop('checked');
            var Allow_Medication_Edit = $('#Allow_Medication_Edit').prop('checked');
            var AllowPendingApprovalList = $('#Allow_Pending_Approval_List').prop('checked');
            var AllowReglistPrint = $('#Allow_ReglistPrint').prop('checked');
            
            var EmpCode = $('#EmpCode').val();
            var ddlcasher = $('#ddlcasher').val();
            var hasMinLength = Password.length >= 6;
            var hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(Password);
            if (UserName == "" || Email == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Fill UserName/Email',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            else if ((Password == "" || ConfirmPassword == "") && UserIDfromURL == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Password Fields cannot be Empty.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            else if ((!hasMinLength || !hasSpecialChar) && UserIDfromURL == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Password must be at least 6 characters long and contain at least one special character.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            else if ((Password != ConfirmPassword) && UserIDfromURL == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Password and Confirm Password does not match.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }

            if (!Accounts || Accounts === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select a Account.',
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

            var dataObj = {
                "UserIDfromURL": UserIDfromURL,
                "UserName": UserName,
                "Email": Email,
                "Password": Password,
                "ConfirmPassword": ConfirmPassword,
                "Mobile": Mobile,
                "Accounts": Accounts,
                "AllowPatientEdit": AllowPatientEdit,
                "AllowPatientDelete": AllowPatientDelete,
                "AllPatientRecords": AllPatientRecords,
                "AllowUnapproveVouchers": AllowUnapproveVouchers,
                "OTPUsers": OTPUsers,
                "AllowBillDelete": AllowBillDelete,
                "AllowTestRate": AllowTestRate,
                "AllowOPD": AllowOPD,
                "AllowLab": AllowLab,
                "AllowUltra": AllowUltra,
                "AllowCtscan": AllowCtscan,
                "AllowXray": AllowXray,
                "AllowB_Bank": AllowB_Bank,
                "AllowPharmacy": AllowPharmacy,
                "GeneralItems": GeneralItems,
                "ShowBudgetBtn": ShowBudgetBtn,
                "InventoryUnApprove": InventoryUnApprove,
                "PurchaseUnApprove": PurchaseUnApprove,
                "PRFsNotifications": PRFsNotifications,
                "RateBox": RateBox,
                "EmpCode": EmpCode,
                "AllowToAccessAllTest": AllowToAccessAllTest,
                "AllowCardio": AllowCardio,
                "IsAnonymous": IsAnonymous,
                "EditEmergency": EditEmergency,
                "AllowEmergency_adm_dis": AllowEmergency_adm_dis,
                "AllowRadiologylist": AllowRadiologylist,
                "AllowBillUpdate": AllowBillUpdate,
                "BlockUser": BlockUser,
                "AllowemergencyDiscount": AllowemergencyDiscount,
                "AllowReferIPD": AllowReferIPD,
                "AllowRecipe": AllowRecipe,
                "AllowActiveItems": AllowActiveItems,
                "AllowBirthCertificate": AllowBirthCertificate,
                "AllowDeathDetails": AllowDeathDetails,
                "AllowSaleReturn": AllowSaleReturn,
                "AllowStudentUpdate": AllowStudentUpdate,
                "RadiologyAllList": RadiologyAllList,
                "AllowRadiologyApproval": AllowRadiologyApproval,
                "AllowAdjustment": AllowAdjustment,
                "Allowradiologyapprove": Allowradiologyapprove,
                "Rejectradiology": Rejectradiology,
                "AlllowPAtientAdd": AlllowPAtientAdd,
                "AllowSamplelist": AllowSamplelist,
                "AllowRegisterRefund": AllowRegisterRefund,
                "Allow_Return_Queue": Allow_Return_Queue,
                "AllowRateEdit": AllowRateEdit,
                "ddlcasher": ddlcasher,
                "AllowUndischarge": AllowUndischarge,
                "AllDoctorTemplate": AllDoctorTemplate,
                "AllowDiscountAssign": AllowDiscountAssign,
                "AllowTill": AllowTill,
                "AllowLineDiscount": AllowLineDiscount,
                "AllowApprovalitem": AllowApprovalitem,
                "AllowReglistPrint": AllowReglistPrint,
                "AllowTestlistDoctor": AllowTestlistDoctor,
                "Allow_Medication_Edit": Allow_Medication_Edit,
                "AllowPendingApprovalList": AllowPendingApprovalList

            };

            var data = JSON.stringify({ data: dataObj });
            console.log(data);
            if (Valid) {
                $.ajax({
                    type: "POST",
                    url: "RegisterUser.aspx/Create_User",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var response = data.d;
                        if (response == "User Created Successfully" || response == "User Updated Successfully") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: response,
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            setTimeout(function () {
                                window.location.href = "../Accounts/UserList.aspx";
                            }, 2000);
                        }
                        else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: response,
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log("XHR:", xhr);
                        console.log("Status:", status);
                        console.log("Error:", error);

                        if (xhr.responseText) {
                            alert("Server Error: " + xhr.responseText);
                        } else {
                            alert("AJAX Error: " + error);
                        }
                    }
                });
            }

        }
        function fillCasher() {
            var options = '<option value="0">Please Select</option>';
            PageMethods.GetCasher(function (data) {
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlcasher').html(options);
                // dropdownParent: inside the modal, otherwise Bootstrap's focus trap blocks typing in the search field
                $('#ddlcasher').select2({ dropdownParent: $('#UserModel'), width: '100%' });
            });
            return options;
        }
        function fillCashInHand() {
            var options = '<option value="0">Please Select</option>';
            $.ajax({
                url: 'RegisterUser.aspx/GetGLAccounts',
                type: 'POST',
                contentType: 'application/json; charset=utf-8',
                dataType: 'json',
                success: function (response) {
                    var data = response.d ? JSON.parse(response.d) : response;
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
                    });
                    $('#ddlCashInHand').html(options);
                    $('#ddlCashInHand').select2({
                    });
                },
                error: function (xhr, status, error) {
                    console.error('Error fetching area data:', error);
                }
            });
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-4"></div>
        <div class="col-lg-4">
            <div class="card">
                <div class="card-body">
                    <div class="accountInfo">
                        <!-- User Name -->
                        <div class="label-field">
                            <label for="UserName" style="font-size: 16px;">User Name:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="text" id="UserName" name="UserName" class="textEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Email -->
                        <div class="label-field">
                            <label for="Email" style="font-size: 16px;">E-mail:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="text" id="Email" name="Email" class="textEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Password -->
                        <div class="label-field">
                            <label for="Password" style="font-size: 16px;">Password:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="password" id="Password" name="Password" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Confirm Password -->
                        <div class="label-field">
                            <label for="ConfirmPassword" style="font-size: 16px;">Confirm Password:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="password" id="ConfirmPassword" name="ConfirmPassword" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>
                        <!-- Mobile -->
                        <div>
                            <div class="label-field">
                                <label for="Mobile" style="font-size: 16px;">Mobile:</label>
                            </div>
                            <div class="input-field">
                                <input autocomplete="off" type="text" id="Mobile" name="UserName" class="textEntry" style="border-radius: 10px !important; margin-right: 5px" />
                            </div>
                        </div>
                        <div>
                            <div class="row">
                                <div class="col-lg-11 col-md-4 col-sm-6">
                                    <div class="label-field">
                                        <label for="ddlCashInHand" style="font-size: 16px;">Accounts</label>
                                    </div>
                                    <div class="input-field">
                                        <select id="ddlCashInHand">
                                            <option value="0">Select</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <!-- Buttons -->
                                <input type="button" value="User Rights" class="btn-primry" onclick="showmodal()" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <input id="saveBtn" class="btn-primry" type="button" value="Create User" onclick="CreateUser()" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <input type="button" class="btn-primry" value="View" onclick="window.location.href='UserList.aspx'" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                        </div>
                            <%--user rights modal: compact, scrolling, toggle switches (inputs keep their original ids / names)--%>
                            <div id="UserModel" class="modal fade rights-modal" tabindex="-1" role="dialog" aria-labelledby="UserModelTitle">
                                <div class="modal-dialog modal-lg" role="document">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title" id="UserModelTitle">User Rights</h5>
                                            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                                <span aria-hidden="true">&times;</span>
                                            </button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="rt-fields">
                                                <div class="rt-field" style="display: none;">   <%-- Employee Code hidden on purpose; the input stays so saving / loading still work --%>
                                                    <label for="EmpCode">Employee Code</label>
                                                    <input type="text" class="rt-input" id="EmpCode" name="EmpCode" />
                                                </div>
                                                <div class="rt-field">
                                                    <label for="ddlcasher">Casher</label>
                                                    <select id="ddlcasher"></select>
                                                </div>
                                                <div class="rt-field">
                                                    <label for="rtSearch">Search rights</label>
                                                    <div class="rt-search">
                                                        <i class="fa fa-search" aria-hidden="true"></i>
                                                        <input type="text" id="rtSearch" placeholder="Type to filter, e.g. lab, bill, radiology" autocomplete="off" />
                                                        <span id="rtCount" class="rt-count"></span>
                                                        <button type="button" id="rtClear" class="rt-clear" aria-label="Clear search">&times;</button>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="rt-grid">
                                                <label class="rt-item" for="AllowPatientEdit"><span class="rt-text">Edit Patient</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowPatientEdit" name="AllowPatientEdit" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowPatientDelete"><span class="rt-text">Cancel Patient</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowPatientDelete" name="AllowPatientDelete" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllPatientRecords"><span class="rt-text">All Patients</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllPatientRecords" name="AllPatientRecords" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowBillDelete"><span class="rt-text">Allow Bill Delete</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowBillDelete" name="AllowBillDelete" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowTestRate"><span class="rt-text">Allow Test Rate</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowTestRate" name="AllowTestRate" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowOPD"><span class="rt-text">Allow OPD</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowOPD" name="AllowOPD" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowLab"><span class="rt-text">Allow Lab</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowLab" name="AllowLab" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowUltra"><span class="rt-text">Allow Ultra</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowUltra" name="AllowUltra" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowCtscan"><span class="rt-text">Allow CT Scan</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowCtscan" name="AllowCtscan" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowXray"><span class="rt-text">Allow X-ray</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowXray" name="AllowXray" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowToAccessAllTest"><span class="rt-text">Allow To Access All Test</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowToAccessAllTest" name="AllowToAccessAllTest" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowCardio"><span class="rt-text">Allow Cardio</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowCardio" name="AllowCardio" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowBillUpdate"><span class="rt-text">Allow Bill Update</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowBillUpdate" name="AllowBillUpdate" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowEmergency_adm_dis"><span class="rt-text">Emergency Adm_Dis</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowEmergency_adm_dis" name="AllowEmergency_adm_dis" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowRadiologylist"><span class="rt-text">Radiology List</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowRadiologylist" name="AllowRadiologylist" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowRateEdit"><span class="rt-text">Edit Rate</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowRateEdit" name="AllowRateEdit" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowActiveItems"><span class="rt-text">Allow Active Items</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowActiveItems" name="AllowActiveitem" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowBirthCertificate"><span class="rt-text">Allow Birth Certificate</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowBirthCertificate" name="AllowBirthCertificate" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowDeathDetails"><span class="rt-text">Allow Death Details</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowDeathDetails" name="AllowDeathDetails" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowUndischarge"><span class="rt-text">Allow Undischarge</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowUndischarge" name="AllowUndischarge" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllDoctorTemplate"><span class="rt-text">All Doctor Template</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllDoctorTemplate" name="AllDoctorTemplate" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowTill"><span class="rt-text">Allow Till</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowTill" name="AllowTill" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowLineDiscount"><span class="rt-text">Allow Bill Discount</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowLineDiscount" name="AllowLineDiscount" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowApprovalitem"><span class="rt-text">Allow Approval Item</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowApprovalitem" name="AllowApprovalitem" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowTestlistDoctor"><span class="rt-text">Allow Testlist Doctor</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowTestlistDoctor" name="AllowTestlistDoctor" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowDiscountAssign"><span class="rt-text">Allow Approve Discount</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowDiscountAssign" name="AllowDiscountAssign" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowB_Bank"><span class="rt-text">Allow B_Bank</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowB_Bank" name="AllowB_Bank" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowPharmacy"><span class="rt-text">Allow Pharmacy</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowPharmacy" name="AllowPharmacy" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowUnapproveVouchers"><span class="rt-text">Voucher Approval</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowUnapproveVouchers" name="AllowUnapproveVouchers" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="GeneralItems"><span class="rt-text">General Items</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="GeneralItems" name="GeneralItems" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="ShowBudgetBtn"><span class="rt-text">Show Budget Btn</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="ShowBudgetBtn" name="ShowBudgetBtn" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="InventoryUnApprove"><span class="rt-text">Inventory UnApprove</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="InventoryUnApprove" name="InventoryUnApprove" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="PurchaseUnApprove"><span class="rt-text">Purchase UnApprove</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="PurchaseUnApprove" name="PurchaseUnApprove" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="PRFsNotifications"><span class="rt-text">PRFs Notifications</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="PRFsNotifications" name="PRFsNotifications" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="OTPUsers"><span class="rt-text">OTP User</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="OTPUsers" name="OTPUsers" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="RateBox"><span class="rt-text">Rate Box</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="RateBox" name="RateBox" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="BlockUser"><span class="rt-text">Block User</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="BlockUser" name="OTPUsers" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="IsAnonymous"><span class="rt-text">IsAnonymous</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="IsAnonymous" name="RateBox" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowEditEmergency"><span class="rt-text">Edit Emergency</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowEditEmergency" name="EditEmergency" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowemergencyDiscount"><span class="rt-text">Discount Emergency</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowemergencyDiscount" name="AllowemergencyDiscount" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowReferIPD"><span class="rt-text">Refer IPD</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowReferIPD" name="AllowReferIPD" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowRecipe"><span class="rt-text">Allow Receipe</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowRecipe" name="AllowRecipe" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowSaleReturn"><span class="rt-text">Allow Sale Return</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowSaleReturn" name="AllowSaleReturn" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowStudentUpdate"><span class="rt-text">Student Update</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowStudentUpdate" name="AllowStudentUpdate" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="RadiologyAllList"><span class="rt-text">Radiology Doctor Rights</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="RadiologyAllList" name="RadiologyAllList" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowRadiologyApproval"><span class="rt-text">Radiology Approval List</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowRadiologyApproval" name="AllowRadiologyApproval" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowAdjustment"><span class="rt-text">Adjustment Allow</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowAdjustment" name="AllowAdjustment" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Allowradiologyapprove"><span class="rt-text">Approve Radiology</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Allowradiologyapprove" name="Allowradiologyapprove" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Rejectradiology"><span class="rt-text">Reject Radiology</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Rejectradiology" name="Rejectradiology" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AlllowPAtientAdd"><span class="rt-text">Allow Add Patient</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AlllowPAtientAdd" name="AlllowPAtientAdd" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowSamplelist"><span class="rt-text">Allow Sample List</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowSamplelist" name="AllowSamplelist" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="AllowRegisterRefund"><span class="rt-text">Allow Register Refund</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="AllowRegisterRefund" name="AllowRegisterRefund" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Allow_Return_Queue"><span class="rt-text">Allow Return Queue</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Allow_Return_Queue" name="Allow_Return_Queue" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Allow_ReglistPrint"><span class="rt-text">Reg List Print</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Allow_ReglistPrint" name="Allow_ReglistPrint" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Allow_Medication_Edit"><span class="rt-text">Allow Medication Edit</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Allow_Medication_Edit" name="Allow_Medication_Edit" /><span class="rt-slider"></span></span></label>
                                                <label class="rt-item" for="Allow_Pending_Approval_List"><span class="rt-text">Pending Approval List</span><span class="rt-switch"><input type="checkbox" class="form-check-input" id="Allow_Pending_Approval_List" name="Allow_Pending_Approval_List" /><span class="rt-slider"></span></span></label>
                                            </div>
                                            <div id="rtEmpty" class="rt-empty" style="display: none;">No rights match your search.</div>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" class="btn btn-primry" data-dismiss="modal">Ok</button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>



</asp:Content>
