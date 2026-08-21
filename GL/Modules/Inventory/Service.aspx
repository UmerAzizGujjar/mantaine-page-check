<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Service.aspx.cs" Inherits="PMS.Modules.Inventory.Service" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
      <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Service.css" rel="stylesheet" />
    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            FillDepartments();
            GetDepartments();
            GetSubcategory();
            FillAccountCategory();
            FillAccounts();
            ActiveCheckRights();
            $("#lblProcedure_Time").hide();
            $("#Procedure_Time").hide();
            if (id != "") {
                LoadItemInventory(id);
                $("#btnValue").val('Update');
            }
            else {
                GetitemNum();
                $("#Active").prop('checked', true);
            }
            $('select').select2();
            $('#ddlAccount').select2();
        });
        $(function () {
            $("#tabs").tabs();

        });
        function NewPage() {
            window.location = "Service.aspx";
        }
        function ListView() {
            window.location = "ServiceView.aspx";
        }
        function GetDepartments() {
            debugger;
            var optionsDepth = '';

            PageMethods.GetDepartments(function (Tests) {
                debugger
                optionsDepth = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "Dept") {
                        optionsDepth += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddldepartment').html(optionsDepth);
                if ($('#ddldepartment').data('select2')) {
                    $('#ddldepartment').select2('destroy').select2();
                } else {
                    $('#ddldepartment').select2();
                }
            });
        }

        function GetSubcategory() {

            PageMethods.GetSubCategory(function (data) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlSubcategory').html(options);
                if ($('#ddlSubcategory').data('select2')) {
                    $('#ddlSubcategory').select2('destroy').select2();
                } else {
                    $('#ddlSubcategory').select2();
                }
            });
        }


        function ActiveCheckRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "Service.aspx/CheckActiveAllow",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    var checkActive = data.d;

                    if (checkActive == "true") {
                        $('#Active').attr('disabled', false)
                    }
                    else {
                        $('#Active').attr('disabled', true)
                    }

                },
                failure: function () {
                    alert(bi);
                }
            });
        }
        function FillDepartments() {
            debugger;
            var optionsManu = '<option value="0">Please Select</option>';
            var optionPUnit = '<option value="0">Select</option>';
            var optionItemTyp = '<option value="0">Please Select</option>';
            var optionProcType = '<option value="0">Please Select</option>';
            var optionItemTyp = '<option value="0">Please Select</option>';
            var optionAconst = '<option value="0">Please Select</option>';
            var optionItemsurg = '<option value="0">Please Select</option>';
            var optionItemCategory = '<option value="0">Please Select</option>';
            var optionItemGroup = '<option value="0">Please Select</option>';
            var optionInvOrg = '<option value="0">Please Select</option>';
            PageMethods.getDDLlist(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    if (value.Type == "Manu") {
                        optionsManu += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "PUnit") {
                        optionPUnit += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "ItemTyp") {
                        optionItemTyp += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "ProcType") {
                        optionProcType += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "Aconst") {
                        optionAconst += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "item Category") {
                        optionItemCategory += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "ItmGrp") {
                        optionItemGroup += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "Warehouse") {
                        optionInvOrg += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionItemsurg += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddlmanu').html(optionsManu);
                $('#ddlpack_unit').html(optionPUnit);
                $('#ddlitem_type').html(optionItemTyp);
                $('#ddlitem_type').val('001');
                $('#ddlProcedureTypes').html(optionProcType);
                $('#ddlitem_Qty').html(optionItemCategory);
                $('#ddlItemGroup').html(optionItemGroup);
                $('#ddlwareHouse').html(optionInvOrg);

                var select2Selectors = ['#ddlmanu', '#ddlpack_unit', '#ddlitem_type', '#ddlProcedureTypes', '#ddlitem_Qty', '#ddlItemGroup', '#ddlwareHouse'];
                $.each(select2Selectors, function (i, sel) {
                    if ($(sel).data('select2')) {
                        $(sel).select2('destroy').select2();
                    } else {
                        $(sel).select2();
                    }
                });
            });
        }
        function FillAccountCategory() {
            debugger;
            var optionsAccCategory = '<option value="0">Please Select</option>';
            PageMethods.getAccountCategory(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsAccCategory += '<option value="' + value.Account_Category_Id + '" >' + value.CategoryName + '</option>';
                });
                $('#ddlfiance_integration').html(optionsAccCategory);
                if ($('#ddlfiance_integration').data('select2')) {
                    $('#ddlfiance_integration').select2('destroy').select2();
                } else {
                    $('#ddlfiance_integration').select2();
                }
            });
        }
        function FillAccounts() {
            $.ajax({
                type: "POST",
                url: "Service.aspx/GetAccounts",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    var options = '<option value="0">Please Select</option>';
                    $.each(JSON.parse(response.d), function (key, value) {
                        options += '<option value="' + value.Account_ID + '">' + value.Account_Code + ' - ' + value.Account_Name + '</option>';
                    });
                    $('#ddlAccount').html(options);
                    if ($('#ddlAccount').data('select2')) {
                        $('#ddlAccount').select2('destroy').select2();
                    } else {
                        $('#ddlAccount').select2();
                    }
                }
            });
        }
        function validateSave() {
            debugger;
            var proceed = true;
            var TotalShare = 0;
            var Desc = $('#txtDescription').val();
            var itemType = $('#ddlitem_type').val();
            var locator = $('#Locator').prop('checked');
            var PharmacyItem = $('#PharmacyItem').prop('checked');
            var uomqty = $('#UOMQty').val();
            doctor_share = $('#txtDocShare').val();
            hospital_Share = $('#txtHospitalShare').val();
            var isShareService = $('#chkIsShareService').prop('checked');
            var TotalShare = parseInt(doctor_share) + parseInt(hospital_Share);
            if (Desc == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Items',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            if (isShareService == true) {

            }
            else {
                if ((TotalShare > 100) || (TotalShare < 100)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Add Share equal to 100%"',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                     proceed = false;
                }

            }

            var locatorAddress = $('#txtlocatorAddress').val();
            var fianceIntegration = $('#ddlfiance_integration').val();
            if (Desc == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Write Item Name in Item Description Filed',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            if (locator && locatorAddress === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Locator Address',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            if (PharmacyItem && (uomqty <= 0 || uomqty === "")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter UOM Quantity that Must be Greater then Zero',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            if (itemType == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Item Type',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            if (fianceIntegration == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Account Category',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 proceed = false;
            }
            return proceed;
        }
        function Saveitem() {
            if (validateSave()) {
                debugger;
                var item_Code = $("#item_code").val();
                var desc = $("#txtDescription").val();
                var active = $('#Active').prop('checked');
                var packUnit = $('#ddlpack_unit').val();
                var uomQty = $('#UOMQty').val();
                var menu = $('#ddlmanu').val();
                var itemType = $('#ddlitem_type').val();
                var itemCategory = $("#ddlitem_Qty").val();
                var fianceIntegration = $('#ddlfiance_integration').val();
                var locatorAddress = $('#txtlocatorAddress').val();
                var lenght = $('#txtLength').val();
                var width = $('#txtwidth').val();
                var heigth = $('#txtheight').val();
                var salesRate = $('#sales_Rate').val();
                var purchRate = $('#purch_rate').val();
                var itemGroup = $('#ddlItemGroup').val();
                var warehouse = $('#ddlwareHouse').val();
                var remarks = $('#txtremarks').val();
                var finshProduct = $('#Finished_Product').prop('checked');
                var consumable = $('#Consumable').prop('checked');
                var NonStockItem = $('#IsNonStockItem').prop('checked');
                var Fixasset = $('#Isfixasset').prop('checked');
                var Batch = $('#IsBatch').prop('checked');
                var locator = $('#Locator').prop('checked');
                var saleable = $('#Saleable').prop('checked');
                var purchaseable = $('#Purchaseable').prop('checked');
                var minimumStock = $('#minimum_stock').val();
                var reorderStock = $('#Reorder_Stock').val();
                var maximumStock = $('#Maximum_Stock').val();
                var aTC = $('#ATC').val();
                var genericName = $('#GenericName').val();
                var controllerDrug = $('#controller_drug').prop('checked');
                var narcotics = $('#Narcotics').prop('checked');
                var PharmacyItem = $('#PharmacyItem').prop('checked');
                var refregrator = $('#Refregrator').prop('checked');
                var procedureTypes = $('#ddlProcedureTypes').val();
                var notes = $('#Note').val();
                var DoctorShare = $('#txtDocShare').val();
                var HospitalShare = $('#txtHospitalShare').val();
              /*  var isShareService = $('#chkIsShareService').prop('checked');*/
                var radioCharges = $('#radio_charges').prop('checked');
                var dentalItem = $('#Dental_Item').prop('checked');
                var procedure = $('#Procedure').prop('checked');
                var lensRequired = $('#chkLensRequired').prop('checked');
                var BedServices = $('#ckhBedServices').prop('checked');
                var labRequired = $('#chkLabRequired').prop('checked');
                var pattHistoryRequired = $('#chkPattHistorRequired').prop('checked');
                var fitnessCertificate = $('#chkFitnessCertificate').prop('checked');
                var OtherServices = $('#chkOtherServices').prop('checked');
                var billing = $('#chkBillingRequired').prop('checked');
                var OTProcedure = $("#chkOTProcedure").prop("checked");
                var IsService = $("#chkIsService").prop("checked");
                var fluid = $("#chckfluid").prop("checked");
                var Procedure_Time = $('#Procedure_Time').val();
                var btnValue = $('#btnValue').val();
                var DepartmentId = $('#ddldepartment').val();
                var Subcategory = $('#ddlSubcategory').val();
                var isHospitalchk = $('#chkIsHospital').prop('checked');
                var isPharmacyBilling = $('#chkIsPharmacyBilling').prop('checked');
                var doctorCompulsory = $('#chkDoctorCompulsory').prop('checked');
                var account = $('#ddlAccount').val();
                var Id = 0;
                if (id == "") {
                    Id = 0;
                }
                else {
                    Id = id
                }
                $('#btnValue').attr('disabled', true);
                $.ajax({
                    type: "POST",
                    url: "Service.aspx/SaveItem",
                    data: JSON.stringify({
                        "Item_Code": item_Code,
                        "Desc": desc,
                        "Active": active,
                        "PackUnit": packUnit,
                        "UomQty": uomQty,
                        "Menu": menu,
                        "ItemType": itemType,
                        "ItemCategory": itemCategory,
                        "FianceIntegration": fianceIntegration,
                        "locatorAddress": locatorAddress,
                        "Lenght": lenght,
                        "Width": width,
                        "Heigth": heigth,
                        "SalesRate": salesRate,
                        "PurchRate": purchRate,
                        "ItemGroup": itemGroup,
                        "Warehouse": warehouse,
                        "Remarks": remarks,
                        "FinshProduct": finshProduct,
                        "Consumable": consumable,
                        "Saleable": saleable,
                        "Purchaseable": purchaseable,
                        "NonStockItem": NonStockItem,
                        "Fixasset": Fixasset,
                        "Batch": Batch,
                        "Locator": locator,
                        "MinimumStock": minimumStock,
                        "ReorderStock": reorderStock,
                        "MaximumStock": maximumStock,
                        "ATC": aTC,
                        "GenericName": genericName,
                        "ControllerDrug": controllerDrug,
                        "Narcotics": narcotics,
                        "Refregrator": refregrator,
                        "PharmacyItem": PharmacyItem,
                        "ProcedureTypes": procedureTypes,
                        "Notes": notes,
                        "RadioCharges": radioCharges,
                        "DentalItem": dentalItem,
                        "Procedure": procedure,
                        "LensRequired": lensRequired,
                        "BedServices": BedServices,
                        "LabRequired": labRequired,
                        "PattHistoryRequired": pattHistoryRequired,
                        "FitnessCertificate": fitnessCertificate,
                        "OtherServices": OtherServices,
                        "Billing": billing,
                        "OTProcedure": OTProcedure,
                        "DoctorShare": DoctorShare,
                        "HospitalShare": HospitalShare,
                        "fluid": fluid,
                        "Procedure_Time": Procedure_Time,
                        "IsService": IsService,
                        "btnValue": btnValue,
                        "ItemId": Id,
                        "DepartmentId": DepartmentId,
                        "Subcategory": Subcategory,
                        "IsHospital": isHospitalchk,
                        "IsPharmacyBilling": isPharmacyBilling,
                        "Doctor_Compulsory": doctorCompulsory,
                        "Account": account,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var msg = response.d;
                        var Split = msg.split("-");
                        if (Split[0] == "Success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data added Successfully.',
                                showConfirmButton: false,
                                timer: 2500
                            });
                             window.location.href = 'Service.aspx?ID=' + Split[1];
                        }
                        else if (Split[0] == "Update") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Updated Successfully.',
                                showConfirmButton: false,
                                timer: 2500
                            });
                             window.location.href = 'Service.aspx?ID=' + Split[1];
                        }
                        else {
                            $('#btnValue').attr('disabled', false);
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: msg,
                                showConfirmButton: false,
                                timer: 3000
                            });
                        }
                    },
                    failure: function (response) {
                        $('#btnValue').attr('disabled', false);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'In failure method',
                            showConfirmButton: false,
                            timer: 3000
                        });
                     }
                });
            }
        }
        function ShowProcTime() {
            var proc = $('#Procedure').prop('checked');
            if (proc == 'True' || proc == true) {
                $("#lblProcedure_Time").show();
                $("#Procedure_Time").show();
            }
            else {
                $("#lblProcedure_Time").hide();
                $("#Procedure_Time").hide();
            }

        }
        function GetitemNum() {
            $.ajax({
                type: "post",
                url: "Service.aspx/GetitemNum",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var id = response.d;
                    $("#item_code").val(id);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function syncServiceMeta() {
            var code = $('#item_code').val();
            if (code) {
                $('#serviceCodeDisplay').text(code);
            }
        }

        $(document).ready(function () {
            var originalVal = $.fn.val;
            $.fn.val = function (value) {
                var res = originalVal.apply(this, arguments);
                if (this.attr('id') === 'item_code' && arguments.length >= 1) {
                    syncServiceMeta();
                }
                return res;
            };

            $('#Active').change(function () {
                if ($(this).is(':checked')) {
                    $('#serviceActiveBadge').removeClass('badge-inactive').addClass('badge-active');
                    $('#serviceActiveIcon').removeClass('fa-times-circle').addClass('fa-check-circle');
                    $('#serviceActiveText').text('Active');
                } else {
                    $('#serviceActiveBadge').removeClass('badge-active').addClass('badge-inactive');
                    $('#serviceActiveIcon').removeClass('fa-check-circle').addClass('fa-times-circle');
                    $('#serviceActiveText').text('Inactive');
                }
            });
            $('#Active').trigger('change');
        });
        function LoadItemInventory(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "Service.aspx/LoadItemInventory",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    $('#item_code').val(parse.Item_Code);
                    $('#txtDescription').val(parse.Description);
                    if (parse.Active == 1) {
                        $("#Active").prop('checked', true);
                    }
                    setTimeout(function () {
                        $('#ddlpack_unit').val(parse.Unit).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlmanu').val(parse.Manufacture_Company).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlitem_type').val(parse.Item_Type).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlitem_Qty').val(parse.Item_Category).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlfiance_integration').val(parse.Item_Account_category).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlProcedureTypes').val(parse.Procedure_Type).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlItemGroup').val(parse.ItemGroupId).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        debugger;
                        $('#ddlwareHouse').val(parse.InventoryOrg).trigger('change');
                    }, 2000);
                    setTimeout(function () {
                        $('#ddldepartment').val(parse.DepartmentId).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#ddlSubcategory').val(parse.Service_Sub_Category).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#ddlAccount').val(parse.Account_ID).trigger('change');
                    }, 1000);
                    $('#txtlocatorAddress').val(parse.locatorAddress);
                    $('#txtLength').val(parse.Length);
                    $('#txtwidth').val(parse.Width);
                    $('#txtheight').val(parse.Height);
                    $('#UOMQty').val(parse.UOM_Qty);
                    $('#txtDocShare').val(parse.Doctor_Share);
                    $('#txtHospitalShare').val(parse.Hospital_Share);
                    $('#chkIsOpenBill').val(parse.Is_OpenBill);
                    $('#chkIsShareService').val(parse.Is_ShareService);
                    $('#sales_Rate').val(parse.Sale_Rate);
                    $('#purch_rate').val(parse.Purchase_Rate);
                    $('#txtremarks').val(parse.Remarks);
                    $('#minimum_stock').val(parse.Mini_Stock);
                    $('#Reorder_Stock').val(parse.Reorder_Stock);
                    $('#Procedure_Time').val(parse.Procedure_Time);
                    $('#Maximum_Stock').val(parse.Max_Stock);
                    $('#ATC').val(parse.ATC);
                    $('#GenericName').val(parse.Generic_Name);
                    $('#Note').val(parse.Notes);
                    if (parse.Finished_Product == 1) {
                        $("#Finished_Product").prop('checked', true);
                    }
                    if (parse.Consumable == 1) {
                        $("#Consumable").prop('checked', true);
                    }
                    if (parse.Saleable == 1) {
                        $("#Saleable").prop('checked', true);
                    }
                    if (parse.Locator == 1) {
                        $("#Locator").prop('checked', true);
                    }
                    if (parse.IsBatch == 1) {
                        $("#IsBatch").prop('checked', true);
                    }
                    if (parse.Purchaseable == 1) {
                        $("#Purchaseable").prop('checked', true);
                    }
                    if (parse.IsNonStockItem == 1) {
                        $("#IsNonStockItem").prop('checked', true);
                    }
                    if (parse.Isfixasset == 1) {
                        $("#Isfixasset").prop('checked', true);
                    }
                    if (parse.Refregrator == 1) {
                        $("#Refregrator").prop('checked', true);
                    }
                    if (parse.LabOR_RadiologyCharges == 1) {
                        $("#radio_charges").prop('checked', true);
                    }
                    if (parse.Dental_Item == 1) {
                        $("#Dental_Item").prop('checked', true);
                    }
                    if (parse.Procedure_Required == 1) {
                        $("#Procedure").prop('checked', true);
                        $("#lblProcedure_Time").show();
                        $("#Procedure_Time").show();
                    }
                    if (parse.Lense_Required == 1) {
                        $("#Lens_Required").prop('checked', true);
                    }
                    if (parse.Bed_Services == 1) {
                        $("#ckhBedServices").prop('checked', true);
                    }
                    if (parse.Fitness_Certificate == 1) {
                        $("#chkFitnessCertificate").prop('checked', true);
                    }
                    if (parse.Lab_Required == 1) {
                        $("#chkLabRequired").prop('checked', true);
                    }
                    if (parse.Pat_History_Required == 1) {
                        $("#chkPattHistorRequired").prop('checked', true);
                    }
                    if (parse.Other_Services == 1) {
                        $("#chkOtherServices").prop('checked', true);
                    }
                    if (parse.Billing_Required == 1) {
                        $("#chkBillingRequired").prop('checked', true);
                    }
                    if (parse.OTProcedure == 1) {
                        $("#chkOTProcedure").prop("checked", true);
                    }
                    if (parse.Controller_Drug == 1) {
                        $("#controller_drug").prop('checked', true);
                    }
                    if (parse.Narcotics == 1) {
                        $("#Narcotics").prop('checked', true);
                    }
                    if (parse.IsPharmacyItem == 1) {
                        $("#PharmacyItem").prop('checked', true);
                    }
                    if (parse.Hospital_Services == 1) {
                        $("#chkIsHospital").prop('checked', true);
                    }
                    if (parse.IsPharmacyBilling == 1) {
                        $("#chkIsPharmacyBilling").prop('checked', true);
                    }
                    if (parse.Doctor_Compulsory == 1) {
                        $("#chkDoctorCompulsory").prop('checked', true);
                    }
                    if (parse.Services == 1) {
                        $("#chkIsService").prop('checked', true);
                    }
                    if (parse.Infusion_Fluid == 1) {
                        $("#chckfluid").prop('checked', true);
                    }
                    setTimeout(function () { $('#Active').trigger('change'); }, 100);
                    setTimeout(function () { syncServiceMeta(); }, 200);

                },
                failure: function (response) {
                    alert("In failure method");
                }

            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <!-- Meta Bar -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-stethoscope"></i> Service Item</span>
        </div>
        <div class="meta-right">
            <div class="meta-badge">
                <span class="badge-label">Code:</span>
                <span class="badge-value" id="serviceCodeDisplay">---</span>
            </div>
            <div class="meta-badge" id="serviceActiveBadge" style="cursor: pointer;" onclick="$('#Active').click();">
                <i class="fa fa-check-circle" id="serviceActiveIcon"></i> <span id="serviceActiveText">Active</span>
            </div>
            <!-- Hidden inputs to retain logic -->
            <input type="hidden" id="item_code" name="item_code" />
            <input type="checkbox" id="Active" name="Active" style="display:none;" />
        </div>
    </div>

    <form id="item">
        <div class="row">
            <!-- Left Column: Basic & Procedure -->
            <div class="col-lg-6 col-md-12 pr-cards-column">
                <!-- Card 1: Basic Information -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-info-circle"></i> Basic Information</h5>
                    <div class="row">
                        <div class="col-md-12">
                            <label id="LblDescription">Service / Item Description</label>
                            <div class="input-group">
                                <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-tag"></i></span></div>
                                <input type="text" class="form-control" id="txtDescription" name="txtDescription" autocomplete="off" placeholder="Enter service or item name" />
                            </div>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4 col-sm-12">
                            <label id="Lblitem_type">Item Type</label>
                            <select id="ddlitem_type" class="form-control"></select>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="LblItemGroup">Item Group</label>
                            <select id="ddlItemGroup" name="ddlItemGroup" class="form-control"></select>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="LblAccount">Account</label>
                            <select id="ddlAccount" class="form-control"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-8 col-sm-12">
                            <label id="Lblpack_unit">UOM (Pack Unit)</label>
                            <select id="ddlpack_unit" class="form-control"></select>
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="lbl_UOMQty">UOM Qty</label>
                            <input type="text" class="form-control" id="UOMQty" name="UOMQty" placeholder="e.g. 1" />
                        </div>
                    </div>
                </div>

                <!-- Card 2: Procedure Details -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-medkit"></i> Procedure Details</h5>
                    <div class="row">
                        <div class="col-md-6 col-sm-12">
                            <label id="levl">Procedure Type</label>
                            <select id="ddlProcedureTypes" class="form-control"></select>
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="lblddldepartment">Department</label>
                            <select id="ddldepartment" class="form-control"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-12">
                            <label id="lblSubcategory">Sub Category</label>
                            <select id="ddlSubcategory" class="form-control"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-12">
                            <label id="Notes">Notes</label>
                            <textarea rows="2" id="Note" name="Note" class="form-control" style="height:60px !important; resize:vertical;" placeholder="Procedure notes"></textarea>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Right Column: Pricing, Inventory & Account -->
            <div class="col-lg-6 col-md-12 pr-cards-column">
                <!-- Card 3: Pricing & Inventory -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-money"></i> Pricing & Inventory</h5>
                    <div class="row">
                        <div class="col-md-6 col-sm-12">
                            <label id="Lblsales_Rate">Sale Rate</label>
                            <input type="text" class="form-control" id="sales_Rate" name="sales_Rate" placeholder="0.00" />
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="Lblpurch_rate">Purchase Rate</label>
                            <input type="text" class="form-control" id="purch_rate" name="purch_rate" placeholder="0.00" />
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6 col-sm-12">
                            <label id="Lblfiance_integration">Account Category</label>
                            <select id="ddlfiance_integration" class="form-control"></select>
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="LblwareHouse">Warehouse</label>
                            <select id="ddlwareHouse" class="form-control"></select>
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-6 col-sm-12">
                            <label id="Lblitem_Qty">Item Main Category</label>
                            <select id="ddlitem_Qty" class="form-control" name="ddlitem_Qty"></select>
                        </div>
                        <div class="col-md-6 col-sm-12">
                            <label id="Lblmanufacturer">Manufacturer</label>
                            <select id="ddlmanu" class="form-control"></select>
                        </div>
                    </div>
                </div>

                <!-- Card 4: Dimensions, Stock & Remarks -->
                <div class="pr-primary-settings">
                    <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-cube"></i> Dimensions, Stock & Remarks</h5>
                    <div class="row">
                        <div class="col-md-4 col-sm-12">
                            <label id="LbllocatorAddress">Locator</label>
                            <input type="text" class="form-control" id="txtlocatorAddress" name="locatorAddress" placeholder="Locator address" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="LblLength">Length</label>
                            <input type="text" class="form-control" id="txtLength" name="txtLength" placeholder="L" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label id="Lblwidth">Width</label>
                            <input type="text" class="form-control" id="txtwidth" name="txtwidth" placeholder="W" />
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4 col-sm-12">
                            <label id="Lblheight">Height</label>
                            <input type="text" class="form-control" id="txtheight" name="txtheight" placeholder="H" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label>Minimum Stock</label>
                            <input type="text" class="form-control" id="minimum_stock" name="minimum_stock" placeholder="0" />
                        </div>
                        <div class="col-md-4 col-sm-12">
                            <label>Reorder Stock</label>
                            <input type="text" class="form-control" id="Reorder_Stock" name="Reorder_Stock" placeholder="0" />
                        </div>
                    </div>
                    <div class="row mt-2">
                        <div class="col-md-4 col-sm-12">
                            <label>Maximum Stock</label>
                            <input type="text" class="form-control" id="Maximum_Stock" name="Maximum_Stock" placeholder="0" />
                        </div>
                        <div class="col-md-8 col-sm-12">
                            <label id="Lblremarks">Remarks</label>
                            <input type="text" class="form-control" id="txtremarks" name="txtremarks" placeholder="Any additional remarks" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div id="tabs" style="margin-top: 20px;">
            <ul>
                <li><a href="#Tab-Hospital"><i class="fa fa-hospital-o"></i> Hospital</a></li>
                <li style="display:none;"><a href="#Tab-Pharmacy"><i class="fa fa-medkit"></i> Pharmacy</a></li>
                <li style="display:none;"><a href="#Tab-ItemTags"><i class="fa fa-tags"></i> Item Tags</a></li>
                <li><a href="#Tab-ProcedureExtras"><i class="fa fa-clock-o"></i> Procedure Extras</a></li>
            </ul>

            <!-- Tab: Hospital Settings -->
            <div id="Tab-Hospital">
                <div class="pr-tab-card">
                    <div class="pr-tab-card-grid">
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkIsHospital" name="chkIsHospital" />
                            <label for="chkIsHospital">Is Hospital Required</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkIsService" name="chkIsService" />
                            <label for="chkIsService">Services Item</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkIsPharmacyBilling" name="chkIsPharmacyBilling" />
                            <label for="chkIsPharmacyBilling">Pharmacy Billing</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="radio_charges" name="radio_charges" />
                            <label for="radio_charges">Lab / Radiology Charges</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Dental_Item" name="Dental_Item" />
                            <label for="Dental_Item">Dental Item</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="ckhBedServices" name="ckhBedServices" />
                            <label for="ckhBedServices">Bed Services</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkOTProcedure" name="chkOTProcedure" />
                            <label for="chkOTProcedure">OT Procedure</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chckfluid" name="chkIsfluid" />
                            <label for="chckfluid">Infusion Fluid</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkLabRequired" name="chkLabRequired" />
                            <label for="chkLabRequired">Lab Required</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkOtherServices" name="chkOtherServices" />
                            <label for="chkOtherServices">Other Services</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkLensRequired" name="chkLensRequired" />
                            <label for="chkLensRequired">Lens Required</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkFitnessCertificate" name="chkFitnessCertificate" />
                            <label for="chkFitnessCertificate">Fitness Certificates</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkPattHistorRequired" name="chkPattHistorRequired" />
                            <label for="chkPattHistorRequired">Pat History Required</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkBillingRequired" name="chkBillingRequired" />
                            <label for="chkBillingRequired">Billing Required</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="chkDoctorCompulsory" name="chkDoctorCompulsory" />
                            <label for="chkDoctorCompulsory">Doctor Compulsory Name</label>
                        </div>
                    </div>
                    <div class="pr-divider"></div>
                    <div class="row pr-share-row">
                        <div class="col-md-3 col-sm-12">
                            <label id="Label1">D. Share</label>
                            <input type="text" id="txtDocShare" name="txtDocShare" autocomplete="off" class="form-control" placeholder="0" />
                        </div>
                        <div class="col-md-3 col-sm-12">
                            <label id="Label2">H. Share</label>
                            <input type="text" id="txtHospitalShare" name="txtHospitalShare" autocomplete="off" class="form-control" placeholder="0" />
                        </div>
                        <div class="col-md-6 col-sm-12 pr-share-hint">
                            <i class="fa fa-info-circle"></i>
                            Doctor Share + Hospital Share must equal <strong>100</strong> when Service is enabled.
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab: Pharmacy -->
            <div id="Tab-Pharmacy">
                <div class="pr-tab-card">
                    <div class="pr-tab-card-grid">
                        <div class="pr-check-row">
                            <input type="checkbox" id="PharmacyItem" name="PharmacyItem" />
                            <label for="PharmacyItem">Pharmacy Item</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="controller_drug" name="controller_drug" />
                            <label for="controller_drug">Controller Drug</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Narcotics" name="Narcotics" />
                            <label for="Narcotics">Narcotics</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Refregrator" name="Refregrator" />
                            <label for="Refregrator">Refrigerator</label>
                        </div>
                    </div>
                    <div class="pr-divider"></div>
                    <div class="row pr-pharmacy-row">
                        <div class="col-md-3 col-sm-12">
                            <label>ATC</label>
                            <input type="text" id="ATC" name="ATC" class="form-control" placeholder="ATC code" />
                        </div>
                        <div class="col-md-9 col-sm-12">
                            <label>Generic Name</label>
                            <input type="text" id="GenericName" name="GenericName" class="form-control" placeholder="Enter generic name" />
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab: Item Tags -->
            <div id="Tab-ItemTags">
                <div class="pr-tab-card">
                    <div class="pr-tab-card-grid">
                        <div class="pr-check-row">
                            <input type="checkbox" id="Finished_Product" name="Finished_Product" />
                            <label for="Finished_Product">Finished Product</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Consumable" name="Consumable" />
                            <label for="Consumable">Consumable</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Saleable" name="Saleable" />
                            <label for="Saleable">Saleable</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Purchaseable" name="Purchaseable" />
                            <label for="Purchaseable">Purchaseable</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="IsNonStockItem" name="IsNonStockItem" />
                            <label for="IsNonStockItem">Non Stock Item</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Isfixasset" name="Isfixasset" />
                            <label for="Isfixasset">Fix Asset</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="Locator" name="Locator" />
                            <label for="Locator">Locator</label>
                        </div>
                        <div class="pr-check-row">
                            <input type="checkbox" id="IsBatch" name="IsBatch" />
                            <label for="IsBatch">Batch</label>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Tab: Procedure Extras (Procedure flag + Procedure Time) -->
            <div id="Tab-ProcedureExtras">
                <div class="pr-tab-card">
                    <div class="pr-tab-card-grid">
                        <div class="pr-check-row">
                            <input type="checkbox" id="Procedure" name="Procedure" onchange="ShowProcTime();" />
                            <label for="Procedure">Procedure</label>
                        </div>
                        <div class="pr-check-row" id="lblProcedure_Time">
                            <label for="Procedure_Time">Procedure Time</label>
                            <input type="text" id="Procedure_Time" name="Procedure_Time" class="form-control" placeholder="e.g. 30 min" style="max-width:200px;" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </form>

    <div class="pr-action-buttons">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry w-100" value="Save" id="btnValue" onclick="Saveitem()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-gray w-100" value="View" onclick="ListView()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow w-100" value="New" onclick="NewPage()" />
            </div>
        </div>
    </div>

</asp:Content>
