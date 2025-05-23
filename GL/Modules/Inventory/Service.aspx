<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Service.aspx.cs" Inherits="PMS.Modules.Inventory.Service" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <link href="../../wwwroot/IITH_Theme/css/CustomCss/Product.css" rel="stylesheet" />
    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            FillDepartments();
            GetDepartments();
            FillAccountCategory();
            if (id != "") {
                LoadItemInventory(id);
                $("#btnValue").val('Update');
            }
            else {
                GetitemNum();
            }
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
                alert("Please Add Items");
                proceed = false;
            }
            if (isShareService == true) {

            }
            else {
                if ((TotalShare > 100) || (TotalShare < 100)) {
                    alert("Please Add Share equal to 100%");
                    proceed = false;
                }

            }
           
            var locatorAddress = $('#txtlocatorAddress').val();
            var fianceIntegration = $('#ddlfiance_integration').val();
            if (Desc == "") {
                alert("Please Write Item Name in Item Description Filed");
                proceed = false;
            }
            if (locator && locatorAddress === "") {
                alert("Please Add Locator Address");
                proceed = false;
            }
            if (PharmacyItem && (uomqty <= 0 || uomqty === "")) {
                alert("Please Enter UOM Quantity that Must be Greater then Zero");
                proceed = false;
            }
            if (itemType == "0") {
                alert("Please Select Item Type");
                proceed = false;
            }
            if (fianceIntegration == "0") {
                alert("Please Select Account Category");
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
                var btnValue = $('#btnValue').val();
                var DepartmentId = $('#ddldepartment').val();
                var isHospitalchk = $('#chkIsHospital').prop('checked');
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
                        "IsService": IsService,
                        "btnValue": btnValue,
                        "ItemId": Id,
                        "DepartmentId": DepartmentId,
                        "IsHospital": isHospitalchk,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var msg = response.d;
                        var Split = msg.split("-");
                        if (Split[0] == "Success") {
                            debugger;
                            alert("Data added Successfully");
                            window.location.href = 'Service.aspx?ID=' + Split[1];
                        }
                        if (Split[0] == "Update") {
                            debugger;
                            alert("Data Updated Successfully");
                            window.location.href = 'Service.aspx?ID=' + Split[1];
                        }
                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
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
                    if (parse.Services == 1) {
                        $("#chkIsService").prop('checked', true);
                    }
                    if (parse.Infusion_Fluid == 1) {
                        $("#chckfluid").prop('checked', true);
                    }

                },
                failure: function (response) {
                    alert("In failure method");
                }

            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <form  id="item">
     <div class="row">
         <div class="col-lg-3 col-md-6 col-sm-12 ">
             <div class="form-group">
                <label id="Lblitem_code">Item Code</label>
                <input style="" type="text" class="form-control" id="item_code" name="item_code" placeholder="(New) " readonly="readonly" />
             </div>
         </div>

         <div class="col-lg-3 col-md-6 col-sm-12">
             <div class="form-group">
                <label id="LblDescription">Description</label>   
                <input type="text" class="form-control" id="txtDescription" name="txtDescription" autocomplete="off" style=""; />
                 </div>
            </div> 

         <div class="col-lg-3 col-md-6 col-sm-12">
               <div class="form-group">
                <label id="Lblitem_type">Item Type</label>
                 <select id="ddlitem_type"  class="form-control">
                    <option>Please Select</option>
                 </select>
                   </div>
            </div>

         <div class="col-lg-3 col-md-6 col-sm-12">
                 <div class="form-group">
                  <label id="LblItemGroup">Item Group </label>
                 <select id="ddlItemGroup" name="ddlItemGroup" class="form-control">
                </select>
                     </div>
               </div>
         </div>

         <div class="row">
                  <div class="col-lg-2 col-md-6 col-sm-12">
                    <label id="Lblpack_unit">UOM</label>
                    <select id="ddlpack_unit">
                       <option>Select</option>
                   </select>    
                 </div>    
               
                 <div class="col-lg-1 col-md-6 col-sm-12">
                     <label id="lbl_UOMQty">UOM Qty</label>
                     <input type="text" class="form-control" id="UOMQty" name="UOMQty" />
                </div>
          <div class="col-lg-3 col-md-6 col-sm-12">
       <div class="form-group">
                <label id="Lblfiance_integration">Account Category</label> 
                 <select id="ddlfiance_integration" class="form-control">
                  <option>Please Select</option>
                  <option value="Yes">Yes</option>
                  <option value="No">No</option>
                </select>
           </div>
             </div>  
         <div class="col-lg-3 col-md-6 col-sm-12">
                   <div class="form-group">
              <label id="LblwareHouse" style="width: 146px">WareHouse</label>
                <select id="ddlwareHouse"  class="form-control"></select>
                </div>       
             </div> 
         <div class="col-lg-3 col-md-6 col-sm-12 p-5">
                 
             <div class="form-group form-check">
               <label class="form-check-label" id="LblActive" for="Active">Active</label>
            <input type="checkbox" class="form-check-input" style="width:auto !important" id="Active" name="Active" />
            </div>
            </div>
            </div>
           
          <div class="row">
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label id="LbllocatorAddress">Locator</label>
                <input type="text" class="form-control" id="txtlocatorAddress" name="locatorAddress" />
            </div>
           
            <div class="col-lg-1 col-md-6 col-sm-21">
                  <label id="Lblsales_Rate">Sale Rate</label> 
                 <input type="text" class="form-control" id="sales_Rate" name="sales_Rate" />
            </div> 
            <div class="col-lg-1 col-md-6 col-sm-12">       
                  <label id="Lblpurch_rate">PR Rate</label>
                  <input type="text" class="form-control" id="purch_rate" name="purch_rate" />
             </div>
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label id="LblLength">Length</label>
                <input type="text" class="form-control" id="txtLength" name="txtLength" />
            </div> 
            <div class="col-lg-1 col-md-6 col-sm-12">
                 <label id="Lblwidth">Width</label>
                   <input type="text" class="form-control" id="txtwidth" name="txtwidth" />
            </div> 
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label id="Lblheight">Height</label>
                <input type="text" class="form-control" id="txtheight" name="txtheight" />
            </div> 
           
           <div class="col-lg-6 col-md-12 col-sm-12">
             <label id="Lblremarks">Remarks</label>
              <input type="text" class="form-control" id="txtremarks" name="txtremarks" />           
           </div>
            </div>
            
         </form>


    <table style="width: 100% !important">
    </table>       
    <div id="tabs">
        <ul>
            <li><a href="#Tab-3" style="display:none;">General</a></li>
            <li><a href="#Tab-4" style="display:none;">Pharmacy</a></li>
            <li><a href="#Tab-1">Procedure</a></li>
            <li><a href="#Tab-5" style="display:none;">Item Tags</a></li>
            <li><a href="#Tab-6">Hospital</a></li>
        </ul>
        <div id="Tab-1" class="table-container">
            <table style="padding: 20px; width: 900px; height: 94px;" class="table-responsive-lg table-responsive-md table-responsive-sm">
                <tr>
                    <td style="font-size: 15px;">Procedure Type:</td>
                    <td>
                        <div id="procedureTypes">
                            <table>
                                <tr>
                                    <td class="col-lg-1 col-md-1 col-sm-2">
                                        <label id="levl">Level1</label>
                                    </td>
                                    <td class="col-lg-3 col-md-3 col-sm-2">
                                        <select id="ddlProcedureTypes">
                                        </select>
                                    </td>
                                    <td class="col-lg-1 col-md-1 col-sm-2">
                                        <label id="Notes">Notes</label>
                                    </td>
                                    <td class="col-lg-2 col-md-2 col-sm-2">
                                        <textarea rows="2" cols="3" id="Note" name="Note" style="margin-left: 30px;width: 194px;margin-top: 3px;height: 30px;"></textarea>
                                    </td>
                                    <td class="col-lg-2 col-md-2 col-sm-2">
                                        <label id="lblddldepartment">Department</label>
                                    </td>
                                    <td class="col-lg-3 col-md-3 col-sm-2">
                                        <select id="ddldepartment" ></select>          
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </div>        
        <div id="Tab-3">      
            <table style="padding: 20px; width: 318px;" class="table-responsive-lg table-responsive-md">
                <span style="font-size: 15px;">Stock Level</span>
                <tr>
                    <td>Minimum Stock</td>
                    <td>
                        <input type="text" id="minimum_stock" name="minimum_stock" /></td>
                </tr>
                <tr>
                    <td>Reorder Stock</td>
                    <td>
                        <input type="text" id="Reorder_Stock" name="Reorder_Stock" /></td>
                </tr>
                <tr>
                    <td>Maximum Stock</td>
                    <td>
                        <input type="text" id="Maximum_Stock" name="Maximum_Stock" /></td>
                </tr>
            </table>

        </div>
        <div id="Tab-4" class="table-container">
            
            <table style="padding: 20px;" class="table-responsive-lg table-responsive-md table-responsive-sm">
                <tr>
                    <td style="width: 21px;">
                        <input type="checkbox" id="Narcotics" name="Narcotics" />
                    </td>
                    <td style="width: 145px;">Narcotics</td>
                    <td style="width: 21px;">
                        <input type="checkbox" id="Refregrator" name="Refregrator" /></td>
                    <td style="width: 84px;">Refregrator</td>
                </tr>
                <tr>
                    <td style="width: 21px;">
                        <input type="checkbox" id="controller_drug" name="controller_drug" />
                    </td>
                    <td style="width: 145px;">Controller Drug</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="PharmacyItem" name="PharmacyItem" /></td>
                    <td style="width: 93px;">Pharmacy Item</td>
                </tr>
            </table>
            <table>
                <tr>
                    <td>
                        <label style="width: 71px;">ATC</label>
                        <input style="width:auto !important" type="text" id="ATC" name="ATC" />
                    </td>
                    <td>
                       <label id="Lblmanufacturer" style=" float: left; position: relative; width: 80px;margin-right: 14px; margin-bottom : 10px;margin-left: 16px">Manufacturer</label>
                    </td>
                    <td style="width: 170px !important;min-width:170px !important;" >  
                        <select id="ddlmanu" style="height: 33px !important">
                            <option>Please Select</option>
                        </select>
                    </td>
                    <td><label id="Lblitem_Qty" style="display: inline-block; float: left; position: relative; width: 150px !important;margin-left: 33px;margin-bottom: 10px">Item Main Category</label></td>

                    <td  style="width: 170px !important;min-width:170px !important;">
                        
                        <select id="ddlitem_Qty" style="height: 33px !important" name="ddlitem_Qty"></select>
                    </td>
                </tr>
            </table>
            <table style="margin-left:20px">
                <tr>
                    <td style="width: 71px;">Generic Name</td>
                    <td>
                        <input type="text" id="GenericName" name="GenericName" style="width: 775px!Important;margin-left: 7px" /></td>
                </tr>
            </table>            
        </div>
        <div id="Tab-5" >
            <table>
                <tr>
                    <td style="width: 23px;">
                        <input type="checkbox" id="Finished_Product" name="Finished_Product" /></td>
                    <td style="width: 162px;">Finished Product</td>
                    <td style="width: 23px;">
                        <input type="checkbox" id="Consumable" name="Consumable" /></td>
                    <td style="width: 84px;">Consumable</td>
                </tr>
                <tr>                   
                    <td>
                        <input type="checkbox" id="Purchaseable" name="Purchaseable" /></td>
                    <td style="width: 84px;">Purchaseable</td>
                    <td>
                        <input type="checkbox" id="Saleable" name="Saleable" /></td>
                    <td style="width: 84px;">Saleable</td>
                </tr>   
                <tr>
                    <td>
                        <input type="checkbox" id="IsNonStockItem" name="IsNonStockItem" /></td>
                    <td style="width: 84px;">Non Stock Item</td>
                    <td>
                        <input type="checkbox" id="Isfixasset" name="Isfixasset" /></td>
                    <td style="width: 84px;">Fix Asset</td>
                </tr>
                <tr>
                    <td><input type="checkbox" id="Locator" name="Locator" /></td>
                    <td style="width: 84px;">Locator</td>
                    <td><input type="checkbox" id="IsBatch" name="IsBatch" /></td>
                    <td style="width: 84px;">Batch</td>
                </tr>
            </table>
        </div>
        <div id="Tab-6">
            <div class="row">
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <label id="Label1">D.Share</label>
                    <input type="text" id="txtDocShare" name="txtDocShare" autocomplete="off" />
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6" style="margin-left:1%">
                    <label id="Label2">H.Share</label>
                    <input type="text" id="txtHospitalShare" name="txtHospitalShare" autocomplete="off"/>
                    </div>
            </div>

            <table>
                <tr>
                    <td style="width: 20px;">
                        <input type="checkbox" id="radio_charges" name="radio_charges" />
                    </td>
                    <td style="width: 145px;" >Lab/Radiology Charges</td>
                    <td style="width: 20px;">
                        <input type="checkbox" id="Dental_Item" name="Dental_Item" /></td>
                    <td style="width: 84px;">Dental Item</td>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" id="Procedure" name="Procedure" />
                    </td>
                    <td style="width: 84px;">Procedure</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="ckhBedServices" name="ckhBedServices" /></td>
                    <td style="width: 84px;">Bed Services</td>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" id="chkLabRequired" name="chkLabRequired" />
                    </td>
                    <td style="width: 84px;">Lab Required</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="chkOtherServices" name="chkOtherServices" /></td>
                    <td style="width: 84px;">Other Services</td>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" id="chkLensRequired" name="chkLensRequired" />
                    </td>
                    <td style="width: 84px;">Lens Required</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="chkFitnessCertificate" name="chkFitnessCertificate" /></td>
                    <td style="width:133px;">Fitness Certificates</td>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" id="chkPattHistorRequired" name="chkPattHistorRequired" />
                    </td>
                    <td style="width: 84px;">Pat History Required</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="chkBillingRequired" name="chkBillingRequired" /></td>
                    <td style="width: 84px;">Billing Required</td>
                </tr>
                <tr>
                    <td>
                        <input type="checkbox" id="chkIsHospital" name="chkIsHospital" />
                    </td>
                    <td style="width: 84px;">Is Hospital Required</td>
                    <td>
                        <input type="checkbox" id="chkOTProcedure" name="chkOTProcedure" />
                    </td>
                    <td style="width: 84px;">
                        <label for="chkOTProcedure">OT Procedure</label>
                    </td>
                </tr>
                <tr>
                    <td>
                         <input type="checkbox" id="chkIsService" name="chkIsService" />
                    </td>
                    <td style="width: 84px;">
                         <label for="chkOTProcedure">Services Item</label> 
                    </td>    
                    <td>
                         <input type="checkbox" id="chckfluid" name="chkIsfluid" />
                    </td>
                    <td style="width: 84px;">
                         <label for="chkOTProcedure">Fluid</label> 
                    </td>                   
                </tr>
            </table>
        </div>
    </div>

    <div class="row" style="margin-top:1%">
         <div class="col-lg-8">
            <div class="row">
                  <div class="col-lg-2 col-md-4 col-sm-12">
     <input type="button" class="btn-gray" value="View" id="btnBack" onclick="window.location = 'ServiceView.aspx'" />
         </div>
    <div class="col-lg-2 col-md-4 col-sm-12">
     <input type="button" class="btn btn-primry" value="Save" id="btnValue" onclick="Saveitem()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
    <input type="button" class="btn btn-yellow" value="New" onclick="NewPage()" />
            </div>
        </div>
            </div>
        </div>

</asp:Content>
