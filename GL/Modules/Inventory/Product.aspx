<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Product.aspx.cs" Inherits="PMS.Inventory.Product" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<link href="../../wwwroot/THEME_TIBBIT/CustomCSS/product-item.css" rel="stylesheet" />
    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
           
            $("#Active").prop("checked", true);
            $("#lblProcedure_Time").hide();
            $("#Procedure_Time").hide();
            var dropdowns = [
                { id: '#ddlmanu', method: 'GetManufacturers' },
                { id: '#ddlpack_unit', method: 'GetPackUnits' },
                { id: '#ddlitem_type', method: 'GetItemTypes' },
                { id: '#ddlProcedureTypes', method: 'GetProcedureTypes' },
                { id: '#ddlAconst', method: 'GetAConstant' },
                { id: '#ddlitem_Qty', method: 'GetCategories' },
                { id: '#ddlItemGroup', method: 'GetItemGroups' },
                { id: '#ddlwareHouse', method: 'GetWarehouses' },
                { id: '#ddlPatient_type', method: 'GetPatientType' },
                { id: '#ddlunitsize', method: 'GetUnitSize' },
                { id: '#ddlfiance_integration', method: 'getAccountCategory' },
                { id: '#ddldepartment', method: 'GetDepartments' },

            ];

            dropdowns.forEach(item => {
                const $element = $(item.id);
                $element.select2();
                $element.off('select2:open').on('select2:open', function () {
                    fillDropdown($element, item.method);
                });
            });
            GetDiscountItem();
            ActiveCheckRights();
            LoadBatchWarehouseDropdown();
            $(document).on('change', '#ddlBatchWarehouse', function () {
                LoadBatchesForWarehouse();
            });
            if (id != "") {
                LoadItemInventory(id);

                $("#btnValue").val('Update');
                setTimeout(function () {
                    LoadWarehouseBatchesForItem(id);
                }, 1000);
            }
            else {
                GetitemNum();

            }

            document.getElementById('chkSehatSahulat').addEventListener('change', function () {
                const container = document.getElementById('sehatCardRateContainer');
                if (this.checked) {
                    container.style.display = 'block';
                } else {
                    container.style.display = 'none'; 
                }
            });

            LoadAssignWarehouseDropdown();
            CheckMultipleWarehouse();
            CheckMultipleBatches();

            $('#ddlwareHouse').change(function () {

                var selected = $(this).val();

                if ($('#tbodyAssignedWarehouses input[name="wh_value"][value="' + selected + '"]').length > 0) {

                    Swal.fire({
                        icon: 'warning',
                        text: 'This warehouse is already selected in the Multiple Warehouse list.',
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $(this).val("0").trigger("change");
                }
            });

        });
        $(function () {
            $("#tabs").tabs();

        });
        function NewPage() {
            window.location = "Product.aspx";
        }
        function ListView() {
            window.location = "ProductsView.aspx";
        }

        function ActiveCheckRights() {
            $.ajax({
                type: "POST",
                url: "Product.aspx/CheckActiveAllow",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
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
        function fillDropdown($dropdown, methodName) {
            if ($dropdown.data('filled')) return;

            var currentValue = $dropdown.val();
            var currentText = $dropdown.find('option:selected').text();

            $.ajax({
                type: "POST",
                url: "Product.aspx/" + methodName,
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        var options = '<option value="0">Please Select</option>';
                        var valueFound = false;

                        $.each(data, function (key, value) {
                            var isSelected = (value.DataValue_Name == currentValue);
                            if (isSelected) valueFound = true;

                            options += `<option value="${value.DataValue_Name}" ${isSelected ? 'selected="selected"' : ''}>
                            ${value.DataValue_Description}
                        </option>`;
                        });

                        $dropdown.html(options)
                            .data('filled', true)
                            .trigger('change');

                        if (currentValue && currentValue !== "0" && !valueFound) {
                            $dropdown.prepend(`<option value="${currentValue}" selected="selected">
                            ${currentText}
                        </option>`);
                            $dropdown.trigger('change');
                        }

                        if ($dropdown.hasClass('select2-hidden-accessible')) {
                            $dropdown.select2('close').select2('open');
                        }
                    } catch (e) {
                        $dropdown.data('filled', false);
                    }
                },
                error: function (xhr, status, error) {
                    $dropdown.data('filled', false);
                }
            });
        }

        function validateSave() {
            var proceed = true;
            var Desc = $('#txtDescription').val();
            var itemType = $('#ddlitem_type').val();
            var locator = $('#Locator').prop('checked');
            var PharmacyItem = $('#PharmacyItem').prop('checked');
            var uomqty = $('#UOMQty').val();

            var locatorAddress = $('#txtlocatorAddress').val();
            var fianceIntegration = $('#ddlfiance_integration').val();
            var consumable = $('#Consumable').prop('checked');
            var Fixasset = $('#Isfixasset').prop('checked');
            var saleable = $('#Saleable').prop('checked');
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
            if (!consumable && !Fixasset && !saleable) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select at least one: Consumable, Fixed Asset, or Saleable.',
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

        function LoadPatientTypeWiseRate(id) {
            $.ajax({
                type: "POST",
                url: "Product.aspx/LoadRateCategory",
                data: JSON.stringify({ id: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    const data = JSON.parse(response.d);

                    const tbody = document.getElementById('tbodypatientRateList');
                    if (!tbody) {
                        console.error("Error: #tbodypatientRateList not found in DOM.");
                        return;
                    }

                    tbody.innerHTML = '';

                    data.forEach(item => {
                        addRateRow(item.Patient_Type, item.Patient_Type_text, item.Item_Sale_Rate, item.Item_Rate_Id);
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading rate category:", error);
                    alert("Error loading rate category data. Please try again.");
                }
            });
        }

        function addRateRow(selectedValue, selectedText, rate, itemRateId = null) {
            const tbody = document.getElementById('tbodypatientRateList');
            if (!tbody) {
                console.error("Error: #tbodypatientRateList not found in DOM.");
                return;
            }

            const tr = document.createElement('tr');
            const rowId = itemRateId || new Date().getTime();

            tr.innerHTML = `
        <!-- Patient Type (Display) -->
        <td style="padding: 10px; border-bottom: 1px solid #eee;">
            <input type="text" id="patientType_${rowId}" name="patient_type" value="${selectedText}"
                   style="width: 100%; padding: 6px; border: none; background: #f0f0f0; border-radius: 4px; cursor: default;" 
                   disabled />
        </td>

        <!-- Rate -->
        <td style="padding: 10px; border-bottom: 1px solid #eee;">
            <input type="text" id="txtsalerate_${rowId}" name="txtsalerate" value="${rate}"
                   style="width: 100%; padding: 6px; border: none; background: #f0f0f0; border-radius: 4px; cursor: default;" 
                   disabled />
        </td>

        <!-- Hidden Input for Form Submission -->
        <td style="display: none;">
            <input type="hidden" name="patient_type_value" value="${selectedValue}" />
            <input type="hidden" name="item_rate_id" value="${rowId}" />
        </td>

        <!-- Action: Edit and Delete Buttons -->
        <td style="padding: 10px; text-align: center; white-space: nowrap;">
         <a href="javascript:void(0)"
   onclick="editRateRow(this, '${selectedValue}', '${selectedText}', '${rate}', '${rowId}')"
   class="editListBtn" 
   style="border-radius: 4px; padding: 5px 8px 5px 8px;">
    <i class="fa fa-pencil"></i>
</a>

<a href="javascript:void(0)" 
   onclick="removeRateEntry(this, '${selectedValue}', '${selectedText}', '${rate}')"
   class="delListBtn"
   style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px 5px 8px;">
    <i class="fa fa-trash"></i>
</a>


        </td>
    `;

            tbody.appendChild(tr);
        }

        function editRateRow(button, selectedValue, selectedText, rate, rowId) {
            const tr = button.closest('tr');
            tr.remove();
            const ddlPatientType = document.getElementById('ddlPatient_type');
            const txtRate = document.getElementById('txtRate');

            if (ddlPatientType && txtRate) {
                const option = document.createElement('option');
                option.value = selectedValue;
                option.textContent = selectedText;
                ddlPatientType.appendChild(option);
                ddlPatientType.value = selectedValue;
                txtRate.value = rate;
            }
        }

        function removeRateEntry(button, selectedValue, selectedText, rate) {
            if (confirm('Are you sure you want to remove this rate entry?')) {
                const tr = button.closest('tr');
                tr.remove();


            }
        }


        function LoadBatchData(id) {
            PageMethods.LoadBatchsRate(id, function (resp) {
                var datas = JSON.parse(resp);
                $.each(datas, function (key, data) {
                    var Batch_Num = data.Batch_Num || '';
                    var Item_Sale_Rate = data.Item_Sale_Rate || '0';
                    var Sehat_card_rate_batch = data.Sehat_card_rate_batch || '0';
                    var Uom_Qty = data.Uom_Qty || '0';
                    var rows = '';
                    var rowlength = BatchTable.rows.length;

                    rows = '<tr>' +
                        '<td>' +
                        '<input type="hidden" name="ddlBatch_' + rowlength + '" value="' + Batch_Num + '" />' +
                        Batch_Num +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="txtBatchRate_' + rowlength + '" value="' + Item_Sale_Rate + '" />' +
                        Item_Sale_Rate +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="txtsehatcardrate_' + rowlength + '" value="' + Sehat_card_rate_batch + '" />' +
                        Sehat_card_rate_batch +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden"  name="txtUom_Qty_' + rowlength + '" value="' + Uom_Qty + '" />' +
                        Uom_Qty +
                        '</td>' +
                        '<td>' +
                        '<a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">' +
                        '<i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;"></i>' +
                        '</a>' +
                        '</td>' +
                        '</tr>';
                    $('#BatchTable_body').append(rows);
                });
            });
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function getbatchfrom_grn() {
            var item_id = '<% =Request.QueryString["ID"] %>';
            var warehouse = $('#ddlWare').val();
            //var item_id = id
            PageMethods.Getbatch_grn(item_id, warehouse, function (data) {
                var parsedData = JSON.parse(data);
                var options = '<option value="0" >Please Select</option>';
                $.each(parsedData.GRN_Details, function (key, value) {
                    options += '<option value="' + value.BatchNum +
                        '" data-uomqty="' + value.uomqty + '">' +
                        value.BatchNum + '</option>';
                });

                $.each(parsedData.Stock_Adjustment_Details, function (key, value) {
                    options += '<option value="' + value.BatchNum +
                        '" data-uomqty="0">' +   
                        value.BatchNum + '</option>';
                });
                $('#ddlBatchNum').html(options);
                $('#ddlBatchNum').select2();
                $('.select2-container--default').css('width', "150px")
            }, function (error) {
                alert(error.get_message());
            });
        }
        function AppendBatch() {
            var selectedOption = $('#ddlBatchNum option:selected');
            var selectedValue = selectedOption.val();
            var selectedText = selectedOption.text();
            var uomqty = selectedOption.data('uomqty') || 0;

            if (selectedValue && selectedValue !== "0") {
                var rowlength = document.getElementById('BatchTable_body').rows.length;

                var rows = '<tr>' +
                    '<td>' +
                    '<input type="hidden" name="ddlBatch_' + rowlength + '" value="' + selectedText + '" />' +
                    selectedText +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtBatchRate_' + rowlength + '" value="0" />' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtsehatcardrate_' + rowlength + '" value="0" />' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtUom_Qty_' + rowlength + '" value="' + uomqty + '" />' +
                    '</td>' +
                    '<td>' +
                    '<a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">' +
                    '<i class="glyphicon glyphicon-trash"></i>' +
                    '</a>' +
                    '</td>' +
                    '</tr>';
                $('#BatchTable_body').append(rows);
            }
        }


        function GetDiscountItem() {
            $.ajax({
                type: "POST",
                url: "Product.aspx/GetDiscountSysParams",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    var data = JSON.parse(msg.d);
                    if (data == '001') {
                        $(".DiscountBlock").show();
                    }
                    else {
                        $(".DiscountBlock").hide();
                    }

                },
                error: function (xhr, status, error) {
                    console.error("Error in getWardAndBed: ", error);
                }
            });


        }
        function FillWarehouseForBatch() {
            PageMethods.GetWarehouses(function (Dosage) {
                var options = '<option value=""> Select</option>'
                $.each(JSON.parse(Dosage), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '"> ' + value.DataValue_Description + ' </option>';
                });
                $('#ddlWare').html(options);
            });
        }
        function Saveitem() {
            if (validateSave()) {
                var item_Code = $("#item_code").val();
                var desc = $("#txtDescription").val();
                var active = $('#Active').prop('checked');
                var packUnit = $('#ddlpack_unit').val();
                var uomQty = $('#UOMQty').val();
                var menu = $('#ddlmanu').val();
                if (menu === "Please select" || menu === "Please Select" || menu === "" || menu === null) {
                    menu = "0";
                }
                var itemType = $('#ddlitem_type').val();
                var itemCategory = $("#ddlitem_Qty").val();
                var fianceIntegration = $('#ddlfiance_integration').val();
                var locatorAddress = $('#txtlocatorAddress').val();
                var lenght = $('#txtLength').val();
                var width = $('#txtwidth').val();
                var heigth = $('#txtheight').val();
                var basesize = $('#ddlunitsize').val();
                var baseqty = $('#txtunitqty').val();
                if (baseqty === null || baseqty.trim() === '') {
                    baseqty = 0; 
                } else {
                    baseqty = parseFloat(baseqty);
                }
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
                var Procedure_Time = $('#Procedure_Time').val();
                var aTC = $('#ATC').val();
                var genericName = $('#GenericName').val();
                var controllerDrug = $('#controller_drug').prop('checked');
                var narcotics = $('#Narcotics').prop('checked');
                var PharmacyItem = $('#PharmacyItem').prop('checked');
                var InfusionFluid = $('#InfusionFluid').prop('checked');
                var refregrator = $('#Refregrator').prop('checked');
                var procedureTypes = $('#ddlProcedureTypes').val();
                if (procedureTypes === "Please select" || procedureTypes === "Please Select" || procedureTypes === "0") {
                    procedureTypes = "0";
                }
                var notes = $('#Note').val();
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
                var ShortItem = $("#chkShortItem").prop("checked");
                var CathLabItems = $('#chkCathLab').prop('checked');
                var HighRisk = $('#chkHighRisk').prop('checked');
                var IsService = $("#chkIsService").prop("checked");
                var SehatSahulat = $("#chkSehatSahulat").prop("checked");
                var btnValue = $('#btnValue').val();
                var DepartmentId = $('#ddldepartment').val();
                var SehatCardRate = $('#txtSehatCardRate').val();
                var isHospitalchk = $('#chkIsHospital').prop('checked');
                var Discount_Block = $('#Discount_Block').prop('checked');
                var Id = 0;
                var batchList = [];
                var PatientTypeList = [];
                if (id == "") {
                    Id = 0;
                }
                else {
                    Id = id
                }

                $('#BatchTable_body tr').each(function (index) {
                    var $row = $(this);
                    var ddlBatch = $row.find('input[type="hidden"]').first().val();
                    var txtBatchRate = $row.find('input[type="text"]').eq(0).val();
                    var txtSCRate = $row.find('input[type="text"]').eq(1).val();
                    var txtUom_Qty = $row.find('input[type="text"]').eq(2).val();
                    if (!txtBatchRate) {
                        txtBatchRate = $row.find('input[type="hidden"]').eq(1).val();
                    }
                    if (!txtSCRate) {
                        txtSCRate = $row.find('input[type="hidden"]').eq(2).val();
                    }
                    if (!txtUom_Qty) {
                        txtUom_Qty = $row.find('input[type="hidden"]').eq(3).val();
                    }

                    if (ddlBatch && ddlBatch !== '') {
                        batchList.push({
                            txtBatchRate: txtBatchRate || '0',
                            txtSCRate: txtSCRate || '0',
                            ddlBatch: ddlBatch,
                            txtUom_Qty: txtUom_Qty || '0'
                        });
                    }
                });
                $('#tbodypatientRateList tr').each(function (key, value) {
                    var pat_type = $(this).find('input[name="patient_type_value"]').val();
                    var SaleRate = $(this).find('input[name="txtsalerate"]').val();
                    var rateId = $(this).find('input[name="item_rate_id"]').val(); 
                    PatientTypeList.push({
                        pat_type: pat_type,
                        SaleRate: SaleRate,
                        Item_Rate_Id: rateId || null  
                    });
                });
                var WarehouseList = [];
                $('#tbodyAssignedWarehouses tr').each(function () {
                    var whVal = $(this).find('input[name="wh_value"]').val();
                    if (whVal && whVal !== "0") {
                        WarehouseList.push({ WarehouseId: whVal });
                    }
                });
                var warehouseBatchList = [];
                $('#tbodyWarehouseBatches tr').each(function () {
                    var warehouseId = $(this).find('input[name="wh_batch_warehouse"]').val();
                    var batchNumber = $(this).find('input[name="wh_batch_batch"]').val();
                    var isBlocked = $(this).find('input[name="wh_batch_isblocked"]').val() == '1' ? true : false;

                    if (warehouseId && warehouseId !== "0" && batchNumber && batchNumber !== "0") {
                        warehouseBatchList.push({
                            WarehouseId: warehouseId,
                            BatchNumber: batchNumber,
                            IsBlocked: isBlocked
                        });
                    }
                });
                $('#btnValue').attr('disabled', true);
                $.ajax({
                    type: "POST",
                    url: "Product.aspx/AddItems",
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
                        "basesize": basesize,
                        "baseqty": baseqty,
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
                        "Procedure_Time": Procedure_Time,
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
                        "ShortItem": ShortItem,
                        "CathLabItems": CathLabItems,
                        "HighRisk": HighRisk,
                        "IsService": IsService,
                        "SehatSahulat": SehatSahulat,
                        "btnValue": btnValue,
                        "ItemId": Id,
                        "DepartmentId": DepartmentId,
                        "IsHospital": isHospitalchk,
                        "SehatCardRate": SehatCardRate,
                        "Discount_Block": Discount_Block,
                        "batchList": batchList,
                        "PatientTypeList": PatientTypeList,
                        "InfusionFluid": InfusionFluid,
                        "WarehouseList": WarehouseList,
                        "WarehouseBatchList": warehouseBatchList
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var msg = response.d;
                        var Split = msg.split("-");
                        if (Split[0] == "Success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data added Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            window.location.href = 'Product.aspx?ID=' + Split[1];
                        }
                        if (Split[0] == "Update") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Updated Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            window.location.href = 'Product.aspx?ID=' + Split[1];
                        }
                    },
                    failure: function (response) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'In failure method',
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
                url: "Product.aspx/GetitemNum",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var id = response.d;
                    $("#item_code").val(id);
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
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
        function LoadItemInventory(id) {
            $.ajax({
                type: "POST",
                url: "Product.aspx/LoadItemInventory",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    $('#item_code').val(parse.Item_Code);
                    $('#txtDescription').val(parse.Description);
                    if (parse.Active == 1) {
                        $("#Active").prop('checked', true);
                    }

                    $('#ddlpack_unit').html(
                        $('<option>', {
                            value: parse.Unit,
                            text: parse.Unit_Text
                        })
                    );

                    $('#ddlmanu').html(
                        $('<option>', {
                            value: parse.Manufacture_Company == 0 ? 0 : parse.Manufacture_Company,
                            text: (!parse.Manufacture_Text || parse.Manufacture_Company == 0)
                                ? 'Please Select'
                                : parse.Manufacture_Text
                        })
                    );


                    $('#ddlitem_type').html(
                        $('<option>', {
                            value: parse.Item_Type,
                            text: parse.Itemtype_Text
                        })
                    );

                    $('#ddlItemGroup').html(
                        $('<option>', {
                            value: parse.ItemGroupId,
                            text: parse.ItemGroup_Text
                        })
                    );

                    $('#ddlfiance_integration').html(
                        $('<option>', {
                            value: parse.Item_Account_category,
                            text: parse.AccountCategory_Text
                        })
                    );

                    $('#ddlwareHouse').html(
                        $('<option>', {
                            value: parse.InventoryOrg,
                            text: parse.InventoryOrg_Text
                        })
                    );

                    $('#ddlitem_Qty').html(
                        $('<option>', {
                            value: parse.Item_Category == 0 ? 0 : parse.Item_Category,
                            text: (!parse.Item_Category_Text || parse.Item_Category == 0)
                                ? 'Please Select'
                                : parse.Item_Category_Text
                        })
                    );


                    $('#ddlProcedureTypes').html(
                        $('<option>', {
                            value: parse.Procedure_Type == 0 ? 0 : parse.Procedure_Type,
                            text: (!parse.Procedure_Type_Text || parse.Procedure_Type == 0)
                                ? 'Please Select'
                                : parse.Procedure_Type_Text
                        })
                    );

                    $('#ddldepartment').html(
                        $('<option>', {
                            value: parse.DepartmentId == 0 ? 0 : parse.DepartmentId,
                            text: (!parse.DepartmentId_Text || parse.DepartmentId == 0)
                                ? 'Please Select'
                                : parse.DepartmentId_Text
                        })
                    );

                    $('#ddlunitsize').html(
                        $('<option>', {
                            value: parse.Base_Unit,
                            text: parse.Base_Unit_Text
                        })
                    );
                    $('#txtunitqty').val(parse.Base_Unit_Qty);


                    $('#txtlocatorAddress').val(parse.locatorAddress);
                    $('#txtLength').val(parse.Length);
                    $('#txtwidth').val(parse.Width);
                    $('#txtheight').val(parse.Height);
                    $('#UOMQty').val(parse.UOM_Qty);
                    $('#sales_Rate').val(parse.Sale_Rate);
                    $('#purch_rate').val(parse.Purchase_Rate);
                    $('#txtremarks').val(parse.Remarks);
                    $('#minimum_stock').val(parse.Mini_Stock);
                    $('#Reorder_Stock').val(parse.Reorder_Stock);
                    $('#Maximum_Stock').val(parse.Max_Stock);
                    $('#Procedure_Time').val(parse.Procedure_Time);
                    $('#ATC').val(parse.ATC);
                    $('#GenericName').val(parse.Generic_Name);
                    $('#Note').val(parse.Notes);
                    //$('#Active').val(parse.Active);
                    if (parse.Active == 1) {

                        $("#Active").prop('checked', true);
                    }
                    else
                    {
                        $("#Active").prop('checked', false);
                    }
                    $("#Active").trigger('change');

                    if (parse.issehatCard_item == 1) {
                        $("#chkSehatSahulat").prop('checked', true);
                    }
                    $('#txtSehatCardRate').val(parse.sehatCard_Rate || '');
                    var shouldShow = ($('#chkSehatSahulat').is(':checked')) ||
                        (parse.sehatCard_Rate && parseFloat(parse.sehatCard_Rate) > 0);
                    if (shouldShow) {
                        $('#sehatCardRateContainer').show();
                    } else {
                        $('#sehatCardRateContainer').hide();
                    }
                    if (parse.Finished_Product == 1) {
                        $("#Finished_Product").prop('checked', true);
                    }
                    if (parse.Discount_Block == 1) {
                        $("#Discount_Block").prop('checked', true);
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
                        /*getbatchfrom_grn(id);*/
                        FillWarehouseForBatch()
                        LoadBatchData(id)
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
                    if (parse.Short_Item == 1) {
                        $("#chkShortItem").prop("checked", true);
                    }
                    if (parse.Is_CathLab == 1) {
                        $("#chkCathLab").prop("checked", true);
                    }
                    if (parse.High_risk == 1) {
                        $("#chkHighRisk").prop("checked", true);
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
                    if (parse.Infusion_Fluid == 1) {
                        $("#InfusionFluid").prop('checked', true);
                    }
                    
                    if (parse.Hospital_Services == 1) {
                        $("#chkIsHospital").prop('checked', true);
                    }
                    if (parse.Services == 1) {
                        $("#chkIsService").prop('checked', true);
                    }

                    if (parse.issehatCard_item == 1) {
                        $("#chkSehatSahulat").prop('checked', true);
                    }
                    LoadPatientTypeWiseRate(id);

                    $.ajax({
                        type: "POST",
                        url: "Product.aspx/GetItemWarehouses",
                        data: JSON.stringify({ ItemId: id }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (resp) {
                            try {
                                var whData = JSON.parse(resp.d);
                                $('#tbodyAssignedWarehouses').empty();
                                $.each(whData, function (k, v) {
                                    var rowHtml = `
                                        <tr>
                                            <td>
                                                ${v.WarehouseName}
                                                <input type="hidden" name="wh_value" value="${v.WarehouseId}" />
                                            </td>
                                            <td style="text-align:center;">
                                                <a href="javascript:void(0)" onclick="RemoveWarehouseRow(this)" style="color:red;">
                                                    <i class="fa fa-trash"></i> Remove
                                                </a>
                                            </td>
                                        </tr>
                                    `;
                                    $('#tbodyAssignedWarehouses').append(rowHtml);
                                });
                            } catch (e) { console.error(e); }
                        }
                    });

                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
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
        function AddRateCategory() {
            const $dropdown = $('#ddlPatient_type');
            const selectedValue = $dropdown.val();
            const selectedText = $dropdown.find('option:selected').text().trim();
            const rateInput = document.getElementById('txtRate');
            const rate = rateInput.value.trim();

            const tbodyCheck = document.getElementById('tbodypatientRateList');
            if (tbodyCheck) {
                const rows = tbodyCheck.querySelectorAll('tr');
                for (let row of rows) {
                    const patientTypeInput = row.querySelector('input[name="patient_type"]');
                    if (patientTypeInput && patientTypeInput.value.trim() === selectedText) {
                        alert(`${selectedText} is already present.`);
                        return;
                    }
                }
            }


            if (!selectedValue || selectedValue === "0") {
                alert("Please select a valid Patient Type.");
                return;
            }
            if (!rate || isNaN(rate) || rate <= 0) {
                alert("Please enter a valid rate (positive number).");
                return;
            }

            let entries = [];
            const hiddenField = document.getElementById('patientRatesData');
            if (hiddenField.value) {
                try {
                    entries = JSON.parse(hiddenField.value);
                } catch (e) {
                    console.error("Error parsing JSON:", e);
                    entries = [];
                }
            }

            if (entries.some(e => e.type === selectedValue)) {
                alert(`${selectedText} is already added.`);
                return;
            }

            entries.push({ type: selectedValue, description: selectedText, rate: rate });
            hiddenField.value = JSON.stringify(entries);


            const tbody = document.getElementById('tbodypatientRateList');
            if (!tbody) {
                console.error("Error: #patientRateList not found in DOM.");
                return;
            }


            const tr = document.createElement('tr');

            tr.innerHTML = `
        <!-- Patient Type (Display) -->
        <td style="padding: 10px; border-bottom: 1px solid #eee;">
            <input type="text" id="patientType"  name="patient_type" value="${selectedText}"
                   style="width: 100%; padding: 6px; border: none; background: #f0f0f0; border-radius: 4px; cursor: default;" 
                   disabled />
        </td>

        <!-- Rate -->
        <td style="padding: 10px; border-bottom: 1px solid #eee;">
            <input type="text"  id="txtsalerate"  name="txtsalerate" value="${rate}"
                   style="width: 100%; padding: 6px; border: none; background: #f0f0f0; border-radius: 4px; cursor: default;" 
                   disabled />
        </td>

        <!-- Hidden Input for Form Submission -->
        <td style="display: none;">
            <input type="hidden" name="patient_type_value" value="${selectedValue}" />
        </td>

        <!-- Action: Delete Button -->
        <td style="padding: 10px; text-align: center;">
            <button type="button" onclick="removeRateEntry(this, '${selectedValue}')" 
                    style="color: red; background: none; border: none; cursor: pointer; font-size: 18px;">
                ✕
            </button>
        </td>
    `;


            tbody.appendChild(tr);

            rateInput.value = '';
        }


        function removeRateEntry(button, type) {
            const tr = button.closest('tr');
            const tbody = document.getElementById('tbodypatientRateList');
            const hiddenField = document.getElementById('tbodypatientRateList');

            tbody.removeChild(tr);

            let entries = [];
            if (hiddenField.value) {
                try {
                    entries = JSON.parse(hiddenField.value);
                } catch (e) {
                    entries = [];
                }
            }

            entries = entries.filter(e => e.type !== type);
            hiddenField.value = JSON.stringify(entries);
        }


        function LoadAssignWarehouseDropdown() {
            $.ajax({
                type: "POST",
                url: "Product.aspx/GetWarehouses", 
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        var options = '<option value="0">Select Warehouse</option>';
                        $.each(data, function (key, value) {
                            options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                        });
                        $('#ddlAssignWarehouse').html(options);
                    } catch (e) { console.error(e); }
                }
            });
        }

        function AddWarehouseRow() {

            var ddl = $('#ddlAssignWarehouse');
            var selectedVal = ddl.val();
            var selectedText = ddl.find('option:selected').text();

            if (selectedVal == "0" || selectedVal == "") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning',
                    text: 'Please select a warehouse.'
                });
                return;
            }

            if ($("#ddlwareHouse").val() == selectedVal) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warehouse Already Selected',
                    text: 'This warehouse is already selected as the main warehouse.',
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            var exists = false;
            $('#tbodyAssignedWarehouses tr').each(function () {
                if ($(this).find('input[name="wh_value"]').val() == selectedVal) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Already Added',
                    text: 'This warehouse is already added.'
                });
                return;
            }

            var rowHtml = `
        <tr>
            <td>
                ${selectedText}
                <input type="hidden" name="wh_value" value="${selectedVal}" />
            </td>
            <td style="text-align:center;">
                <a href="javascript:void(0)" onclick="RemoveWarehouseRow(this)" style="color:red;">
                    <i class="fa fa-trash"></i> Remove
                </a>
            </td>
        </tr>
    `;

            $('#tbodyAssignedWarehouses').append(rowHtml);
            ddl.val("0").trigger("change"); 
        }

        function RemoveWarehouseRow(btn) {
            $(btn).closest('tr').remove();
        }

        function CheckMultipleWarehouse() {

            $.ajax({
                type: "POST",
                url: "Product.aspx/MultipleWareHouse",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    if (response.d === "01") {
                        $("#divMultipleWarehouse").show();
                    } else {
                        $("#divMultipleWarehouse").hide();
                    }

                },
                error: function () {
                    $("#divMultipleWarehouse").hide();
                }
            });

        }

        function CheckMultipleBatches() {

            $.ajax({
                type: "POST",
                url: "Product.aspx/MultipleBatches",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    if (response.d === "01") {
                        $("#divWarehouseBatches").show();
                    } else {
                        $("#divWarehouseBatches").hide();
                    }

                },
                error: function () {
                    $("#divWarehouseBatches").hide();
                }
            });

        }


        function LoadBatchWarehouseDropdown() {
            $.ajax({
                type: "POST",
                url: "Product.aspx/GetWarehouses",
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        var options = '<option value="0">Select Warehouse</option>';
                        $.each(data, function (key, value) {
                            options += `<option value="${value.DataValue_Name}">${value.DataValue_Description}</option>`;
                        });
                        $('#ddlBatchWarehouse').html(options);
                        $('#ddlBatchWarehouse').val("0").trigger('change');
                    } catch (e) { console.error(e); }
                }
            });
        }

        function LoadBatchesForWarehouse() {
            var warehouseId = $('#ddlBatchWarehouse').val();
            var itemId = id; 

            //if (!warehouseId || warehouseId == "0") {
            //    Swal.fire({
            //        icon: 'warning',
            //        title: 'Warning',
            //        text: 'Please select a warehouse first.'
            //    });
            //    return;
            //}

            //if (!itemId || itemId == "") {
            //    Swal.fire({
            //        icon: 'warning',
            //        title: 'Warning',
            //        text: 'Please save the item first before assigning batches.'
            //    });
            //    return;
            //}

            $.ajax({
                type: "POST",
                url: "Product.aspx/GetBatchesForItemAndWarehouse",
                data: JSON.stringify({
                    itemId: itemId,
                    warehouseId: warehouseId
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        var options = '<option value="0">Select Batch</option>';
                        $.each(data, function (key, value) {
                            options += `<option value="${value.BatchNum}">${value.BatchNum}</option>`;
                        });
                        $('#ddlBatchNumber').html(options);
                        $('#ddlBatchNumber').val("0").trigger('change');
                    } catch (e) { console.error(e); }
                }
            });
        }

        // Add warehouse-batch row
        function AddWarehouseBatchRow() {
            var warehouseId = $('#ddlBatchWarehouse').val();
            var warehouseText = $('#ddlBatchWarehouse option:selected').text();
            var batchNumber = $('#ddlBatchNumber').val();
            var batchText = $('#ddlBatchNumber option:selected').text();

            // Validate selections
            if (warehouseId == "0" || warehouseId == "") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning',
                    text: 'Please select a warehouse.'
                });
                return;
            }

            if (batchNumber == "0" || batchNumber == "") {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning',
                    text: 'Please select a batch.'
                });
                return;
            }

            // Check for duplicates
            var exists = false;
            $('#tbodyWarehouseBatches tr').each(function () {
                var existingWarehouse = $(this).find('input[name="wh_batch_warehouse"]').val();
                var existingBatch = $(this).find('input[name="wh_batch_batch"]').val();
                if (existingWarehouse == warehouseId && existingBatch == batchNumber) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Already Added',
                    text: 'This warehouse-batch combination is already added.'
                });
                return;
            }

            // Add row
            var rowHtml = `
        <tr>
            <td>
                ${warehouseText}
                <input type="hidden" name="wh_batch_warehouse" value="${warehouseId}" />
            </td>
            <td>
                ${batchText}
                <input type="hidden" name="wh_batch_batch" value="${batchNumber}" />
                <input type="hidden" name="wh_batch_isblocked" value="0" />
            </td>
            <td style="text-align:center;">
                <span class="badge badge-success" style="background-color: #28a745; color: white; padding: 5px 10px; border-radius: 3px;">Active</span>
            </td>
            <td style="text-align:center;">
                <a href="javascript:void(0)" onclick="RemoveWarehouseBatchRow(this)" style="color:red;">
                    <i class="fa fa-trash"></i>
                </a>
                <a href="javascript:void(0)" onclick="ToggleWarehouseBatchStatus(this)" style="color:orange; margin-left: 8px;">
                    <i class="fa fa-ban"></i>
                </a>
            </td>
        </tr>
    `;

            $('#tbodyWarehouseBatches').append(rowHtml);

            // Reset dropdowns
            $('#ddlBatchNumber').val("0").trigger('change');
        }

        // Remove warehouse-batch row
        function RemoveWarehouseBatchRow(btn) {
            Swal.fire({
                title: 'Are you sure?',
                text: "You want to remove this warehouse-batch assignment?",
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, remove it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    $(btn).closest('tr').remove();
                }
            });
        }

        // Toggle block status
        function ToggleWarehouseBatchStatus(btn) {
            var $row = $(btn).closest('tr');
            var $statusBadge = $row.find('.badge');
            var $hiddenStatus = $row.find('input[name="wh_batch_isblocked"]');

            if ($statusBadge.text().trim() === 'Active') {
                $statusBadge.text('Blocked').css('background-color', '#dc3545');
                $statusBadge.removeClass('badge-success').addClass('badge-danger');
                $hiddenStatus.val('1');
                $(btn).html('<i class="fa fa-check"></i>');
            } else {
                $statusBadge.text('Active').css('background-color', '#28a745');
                $statusBadge.removeClass('badge-danger').addClass('badge-success');
                $hiddenStatus.val('0');
                $(btn).html('<i class="fa fa-ban"></i>');
            }
        }

        function LoadWarehouseBatchesForItem(itemId) {
            $.ajax({
                type: "POST",
                url: "Product.aspx/GetItemWarehouseBatches",
                data: JSON.stringify({ itemId: itemId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        console.log("Data received:", data); 

                        $('#tbodyWarehouseBatches').empty();
                        $.each(data, function (k, v) {
                            var statusText = v.IsBlocked ? 'Blocked' : 'Active';
                            var statusClass = v.IsBlocked ? 'badge-danger' : 'badge-success';
                            var statusColor = v.IsBlocked ? '#dc3545' : '#28a745';
                            var actionIcon = v.IsBlocked ? '<i class="fa fa-check"></i>' : '<i class="fa fa-ban"></i>';

                            var warehouseDisplay = v.WarehouseName || v.Warehouse_Id || 'Unknown';
                            var batchDisplay = v.Batch_Number || 'Unknown';

                            var rowHtml = `
                        <tr>
                            <td>
                                ${warehouseDisplay}
                                <input type="hidden" name="wh_batch_warehouse" value="${v.Warehouse_Id}" />
                            </td>
                            <td>
                                ${batchDisplay}
                                <input type="hidden" name="wh_batch_batch" value="${v.Batch_Number}" />
                                <input type="hidden" name="wh_batch_isblocked" value="${v.IsBlocked ? 1 : 0}" />
                            </td>
                            <td style="text-align:center;">
                                <span class="badge ${statusClass}" style="background-color: ${statusColor}; color: white; padding: 5px 10px; border-radius: 3px;">${statusText}</span>
                            </td>
                            <td style="text-align:center;">
                                <a href="javascript:void(0)" onclick="RemoveWarehouseBatchRow(this)" style="color:red;">
                                    <i class="fa fa-trash"></i>
                                </a>
                                <a href="javascript:void(0)" onclick="ToggleWarehouseBatchStatus(this)" style="color:orange; margin-left: 8px;">
                                    ${actionIcon}
                                </a>
                            </td>
                        </tr>
                    `;
                            $('#tbodyWarehouseBatches').append(rowHtml);
                        });
                    } catch (e) {
                        console.error("Error loading warehouse batches:", e);
                        console.log("Response data:", response.d);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error:", error);
                }
            });
        }

        // ── Meta Bar sync (visual only — does not change any save/load logic) ──
        function syncProductMeta() {
            var code = $('#item_code').val();
            if (code) {
                $('#productCodeDisplay').text(code);
            }
        }
        $(document).ready(function () {
            var originalVal = $.fn.val;
            $.fn.val = function (value) {
                var res = originalVal.apply(this, arguments);
                if (this.attr('id') === 'item_code' && arguments.length >= 1) {
                    syncProductMeta();
                }
                return res;
            };
            $('#Active').change(function () {
                if ($(this).is(':checked')) {
                    $('#productActiveBadge').removeClass('badge-inactive').addClass('badge-active');
                    $('#productActiveIcon').removeClass('fa-times-circle').addClass('fa-check-circle');
                    $('#productActiveText').text('Active');
                } else {
                    $('#productActiveBadge').removeClass('badge-active').addClass('badge-inactive');
                    $('#productActiveIcon').removeClass('fa-check-circle').addClass('fa-times-circle');
                    $('#productActiveText').text('Inactive');
                }
            });
            $('#Active').trigger('change');
            syncProductMeta();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<input type="hidden" name="item_rate_id" value="${rowId}" />

    <!-- Title line: the master adds the page title on the left; code + status badges sit on the right -->
    <div class="pr-meta-bar">
        <div class="meta-left"></div>
        <div class="meta-right">
            <div class="pd-badge">
                <span class="pd-badge-label">Code</span>
                <span class="pd-badge-value" id="productCodeDisplay">---</span>
            </div>
            <div class="pd-badge pd-status badge-active" id="productActiveBadge" onclick="$('#Active').click();">
                <i class="fa fa-check-circle" id="productActiveIcon"></i> <span id="productActiveText">Active</span>
            </div>
            <!-- Hidden inputs to retain logic -->
            <input type="hidden" id="item_code" name="item_code" />
            <input type="checkbox" id="Active" name="Active" style="display:none;" />
        </div>
    </div>

    <div class="pd-page">
        <div id="item">
            <div class="pd-layout2">
                <!-- Basic Information -->
                <div class="pd-card">
                    <h5 class="pd-card-title"><i class="fa fa-info-circle"></i> Basic Information</h5>
                    <div class="pd-grid">
                        <div class="pd-field pd-s6">
                            <label id="LblDescription" for="txtDescription">Description</label>
                            <input type="text" class="pd-input" id="txtDescription" name="txtDescription" autocomplete="off" placeholder="Enter product description" />
                        </div>
                        <div class="pd-field pd-s3">
                            <label id="Lblitem_type">Item Type</label>
                            <select id="ddlitem_type" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s3">
                            <label id="LblItemGroup">Item Group</label>
                            <select id="ddlItemGroup" name="ddlItemGroup" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s4">
                            <label id="Lblpack_unit">UOM / Pack Size</label>
                            <select id="ddlpack_unit" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="lbl_UOMQty" for="UOMQty">UOM Qty</label>
                            <input type="text" class="pd-input" id="UOMQty" name="UOMQty" placeholder="0" />
                        </div>
                    </div>
                </div>

                <!-- Pricing & Packaging -->
                <div class="pd-card">
                    <h5 class="pd-card-title"><i class="fa fa-money"></i> Pricing &amp; Packaging</h5>
                    <div class="pd-grid">
                        <div class="pd-field pd-s3">
                            <label id="Lblsales_Rate" for="sales_Rate">Sale Rate</label>
                            <input type="text" class="pd-input" id="sales_Rate" name="sales_Rate" placeholder="0.00" />
                        </div>
                        <div class="pd-field pd-s3">
                            <label id="Lblpurch_rate" for="purch_rate">PR Rate</label>
                            <input type="text" class="pd-input" id="purch_rate" name="purch_rate" placeholder="0.00" />
                        </div>
                        <div class="pd-field pd-s3">
                            <label id="lblunitSize">Unit Size</label>
                            <select id="ddlunitsize" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s3">
                            <label id="lblunitsizeqty" for="txtunitqty">Unit Size QTY</label>
                            <input type="text" class="pd-input" id="txtunitqty" name="purch_rate" placeholder="0" />
                        </div>
                        <div class="pd-field pd-s6">
                            <label id="Lblremarks" for="txtremarks">Remarks</label>
                            <input type="text" class="pd-input" id="txtremarks" name="txtremarks" placeholder="Any additional remarks" />
                        </div>
                    </div>
                </div>

                <!-- Inventory & Account -->
                <div class="pd-card pd-wide">
                    <h5 class="pd-card-title"><i class="fa fa-cubes"></i> Inventory &amp; Account</h5>
                    <div class="pd-grid">
                        <div class="pd-field pd-s2">
                            <label id="Lblfiance_integration">Account Category</label>
                            <select id="ddlfiance_integration" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="LblwareHouse">WareHouse</label>
                            <select id="ddlwareHouse" class="pd-input"></select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="LbllocatorAddress" for="txtlocatorAddress">Locator</label>
                            <input type="text" class="pd-input" id="txtlocatorAddress" name="locatorAddress" placeholder="Locator" />
                        </div>
                    </div>
                </div>

                <!-- Sehat Card & hidden dimensions (kept for the page script; the card itself stays hidden as before) -->
                <div class="pd-card" style="display:none;">
                    <h5 class="pd-card-title"><i class="fa fa-heartbeat"></i> Sehat Card &amp; Dimensions</h5>
                    <div class="pd-grid">
                        <div class="pd-field pd-s6" id="sehatCardRateContainer" style="display: none;">
                            <label id="LblsehatCardrate" for="txtSehatCardRate">Sehat Card Rate</label>
                            <input type="text" class="pd-input" id="txtSehatCardRate" name="txtSehatCardRate" placeholder="0.00" />
                        </div>
                        <div class="pd-hint pd-s6">
                            <i class="fa fa-info-circle"></i>
                            <span>The Sehat Card Rate field appears automatically when <strong>Sehat Sahulat</strong> is checked in the Hospital tab.</span>
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="LblLength" for="txtLength">Length</label>
                            <input type="text" class="pd-input" id="txtLength" name="txtLength" />
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="Lblwidth" for="txtwidth">Width</label>
                            <input type="text" class="pd-input" id="txtwidth" name="txtwidth" />
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="Lblheight" for="txtheight">Height</label>
                            <input type="text" class="pd-input" id="txtheight" name="txtheight" />
                        </div>
                    </div>
                </div>
            </div>

            <div id="tabs" class="pd-tabs" style="margin-top: 16px;">
                <ul>
                    <li><a href="#Tab-3"><i class="fa fa-cubes"></i> General</a></li>
                    <li><a href="#Tab-4"><i class="fa fa-medkit"></i> Pharmacy</a></li>
                    <li><a href="#Tab-1"><i class="fa fa-stethoscope"></i> Procedure</a></li>
                    <li><a href="#Tab-5"><i class="fa fa-tags"></i> Item Tags</a></li>
                    <li><a href="#Tab-6"><i class="fa fa-hospital-o"></i> Hospital</a></li>
                </ul>

                <!-- Tab: Procedure -->
                <div id="Tab-1" class="table-container">
                    <div id="procedureTypes">
                        <div class="pd-grid">
                            <div class="pd-field pd-s2">
                                <label id="levl">Level1</label>
                                <select id="ddlProcedureTypes" class="pd-input">
                                    <option value="0">Please Select</option>
                                </select>
                            </div>
                            <div class="pd-field pd-s2">
                                <label id="lblddldepartment">Department</label>
                                <select id="ddldepartment" class="pd-input">
                                    <option value="0">Please Select</option>
                                </select>
                            </div>
                            <div class="pd-field pd-s2">
                                <label id="Notes" for="Note">Notes</label>
                                <textarea rows="2" cols="3" id="Note" name="Note" class="pd-input"></textarea>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab: General (stock level + patient-type rates) -->
                <div id="Tab-3">
                    <div class="pd-split">
                        <div class="pd-sub">
                            <h6 class="pd-sub-title"><i class="fa fa-sort-amount-asc"></i> Stock Level</h6>
                            <div class="pd-grid">
                                <div class="pd-field pd-s6">
                                    <label for="minimum_stock">Minimum Stock</label>
                                    <input type="text" id="minimum_stock" name="minimum_stock" class="pd-input" />
                                </div>
                                <div class="pd-field pd-s6">
                                    <label for="Reorder_Stock">Reorder Stock</label>
                                    <input type="text" id="Reorder_Stock" name="Reorder_Stock" class="pd-input" />
                                </div>
                                <div class="pd-field pd-s6">
                                    <label for="Maximum_Stock">Maximum Stock</label>
                                    <input type="text" id="Maximum_Stock" name="Maximum_Stock" class="pd-input" />
                                </div>
                            </div>
                        </div>

                        <div class="pd-sub">
                            <h6 class="pd-sub-title"><i class="fa fa-users"></i> Rate by Patient Type</h6>
                            <div class="pd-addrow">
                                <div class="pd-field">
                                    <label for="ddlPatient_type">Patient_type</label>
                                    <select id="ddlPatient_type" class="pd-input">
                                        <option value="0">Please Select</option>
                                    </select>
                                </div>
                                <div class="pd-field">
                                    <label for="txtRate">Rate</label>
                                    <input type="number" id="txtRate" class="pd-input" placeholder="Enter rate" />
                                </div>
                                <input type="button" value="+" class="btn-primry" onclick="AddRateCategory()" />
                            </div>
                            <div class="pd-table-wrap">
                                <table class="table pd-table">
                                    <thead>
                                        <tr>
                                            <th>Patient_type</th>
                                            <th>Rate</th>
                                            <th style="text-align: center;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tbodypatientRateList">

                                    </tbody>
                                </table>
                            </div>
                            <input type="hidden" id="patientRatesData" name="patientRatesData" value="" />
                        </div>
                    </div>
                </div>

                <!-- Tab: Pharmacy -->
                <div id="Tab-4" class="table-container">
                    <div class="pd-checks">
                        <div class="pd-check"><input type="checkbox" id="Narcotics" name="Narcotics" /><label for="Narcotics">Narcotics</label></div>
                        <div class="pd-check"><input type="checkbox" id="Refregrator" name="Refregrator" /><label for="Refregrator">Refregrator</label></div>
                        <div class="pd-check DiscountBlock"><input type="checkbox" id="Discount_Block" name="Discount_Block" /><label for="Discount_Block">Discount Block</label></div>
                        <div class="pd-check"><input type="checkbox" id="controller_drug" name="controller_drug" /><label for="controller_drug">Controller Drug</label></div>
                        <div class="pd-check"><input type="checkbox" id="PharmacyItem" name="PharmacyItem" /><label for="PharmacyItem">Pharmacy Item</label></div>
                        <div class="pd-check"><input type="checkbox" id="InfusionFluid" name="InfusionFluid" /><label for="InfusionFluid">Infusion Fluid</label></div>
                    </div>
                    <div class="pd-divider"></div>
                    <div class="pd-grid">
                        <div class="pd-field pd-s2">
                            <label for="ATC">ATC</label>
                            <input type="text" id="ATC" name="ATC" class="pd-input" />
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="Lblmanufacturer">Manufacturer</label>
                            <select id="ddlmanu" class="pd-input">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label id="Lblitem_Qty">Item Main Category</label>
                            <select id="ddlitem_Qty" class="pd-input" name="ddlitem_Qty">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label for="GenericName">Generic Name</label>
                            <input type="text" id="GenericName" name="GenericName" class="pd-input" />
                        </div>
                        <div class="pd-field pd-s2">
                            <label for="ddlWare">WareHouse</label>
                            <select id="ddlWare" class="pd-input" onchange="getbatchfrom_grn();"></select>
                        </div>
                        <div class="pd-field pd-s2">
                            <label for="ddlBatchNum">Batch Number</label>
                            <div class="pd-addrow" style="margin-bottom:0;">
                                <select id="ddlBatchNum" class="pd-input"></select>
                                <input type="button" onclick="AppendBatch()" value="+" id="AddBatch" />
                            </div>
                        </div>
                    </div>

                    <div class="pd-trio">
                        <div class="pd-sub">
                            <h6 class="pd-sub-title"><i class="fa fa-barcode"></i> Batches</h6>
                            <div class="pd-table-wrap">
                                <table class="table table-bordered pd-table" id="BatchTable">
                                    <thead>
                                        <tr id="row_sample">
                                            <th>Batch Number</th>
                                            <th>Rate</th>
                                            <th>Sehat Card Rate</th>
                                            <th>Uom Qty</th>
                                            <th style="text-align: center;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody id="BatchTable_body">
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div id="divMultipleWarehouse" class="pd-sub">
                            <h6 class="pd-sub-title"><i class="fa fa-building-o"></i> Assign Multiple Warehouses</h6>
                            <div class="pd-addrow">
                                <div class="pd-field">
                                    <select id="ddlAssignWarehouse" class="pd-input">
                                        <option value="0">Select Warehouse</option>
                                    </select>
                                </div>
                                <input type="button" value="+" onclick="AddWarehouseRow()" />
                            </div>
                            <div class="pd-table-wrap">
                                <table class="table table-bordered pd-table">
                                    <thead>
                                        <tr>
                                            <th>Warehouse Name</th>
                                            <th style="width: 80px; text-align: center;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tbodyAssignedWarehouses">
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <div id="divWarehouseBatches" class="pd-sub">
                            <h6 class="pd-sub-title"><i class="fa fa-th-list"></i> Assign Batches to Warehouse</h6>
                            <div class="pd-addrow">
                                <div class="pd-field">
                                    <label for="ddlBatchWarehouse">Warehouse</label>
                                    <select id="ddlBatchWarehouse" class="pd-input">
                                        <option value="0">Select Warehouse</option>
                                    </select>
                                </div>
                                <div class="pd-field">
                                    <label for="ddlBatchNumber">Batch</label>
                                    <select id="ddlBatchNumber" class="pd-input">
                                        <option value="0">Select Batch</option>
                                    </select>
                                </div>
                                <input type="button" value="+" onclick="AddWarehouseBatchRow()" />
                                <input type="button" value="Refresh Batches" onclick="LoadBatchesForWarehouse()" style="display:none;" />
                            </div>
                            <div class="pd-table-wrap">
                                <table class="table table-bordered pd-table">
                                    <thead>
                                        <tr>
                                            <th style="width: 35%;">Warehouse Name</th>
                                            <th style="width: 35%;">Batch Number</th>
                                            <th style="width: 20%; text-align: center;">Status</th>
                                            <th style="width: 10%; text-align: center;">Action</th>
                                        </tr>
                                    </thead>
                                    <tbody id="tbodyWarehouseBatches">
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tab: Item Tags -->
                <div id="Tab-5">
                    <div class="pd-checks">
                        <div class="pd-check"><input type="checkbox" id="Finished_Product" name="Finished_Product" /><label for="Finished_Product">Finished Product</label></div>
                        <div class="pd-check"><input type="checkbox" id="Consumable" name="Consumable" /><label for="Consumable">Consumable</label></div>
                        <div class="pd-check"><input type="checkbox" id="Purchaseable" name="Purchaseable" /><label for="Purchaseable">Purchaseable</label></div>
                        <div class="pd-check"><input type="checkbox" id="Saleable" name="Saleable" /><label for="Saleable">Saleable</label></div>
                        <div class="pd-check"><input type="checkbox" id="IsNonStockItem" name="IsNonStockItem" /><label for="IsNonStockItem">Non Stock Item</label></div>
                        <div class="pd-check"><input type="checkbox" id="Isfixasset" name="Isfixasset" /><label for="Isfixasset">Fix Asset</label></div>
                        <div class="pd-check"><input type="checkbox" id="Locator" name="Locator" /><label for="Locator">Locator</label></div>
                        <div class="pd-check"><input type="checkbox" id="IsBatch" name="IsBatch" /><label for="IsBatch">Batch</label></div>
                    </div>
                </div>

                <!-- Tab: Hospital -->
                <div id="Tab-6">
                    <div class="pd-checks">
                        <div class="pd-check"><input type="checkbox" id="radio_charges" name="radio_charges" /><label for="radio_charges">Lab/Radiology Charges</label></div>
                        <div class="pd-check"><input type="checkbox" id="Dental_Item" name="Dental_Item" /><label for="Dental_Item">Dental Item</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkCathLab" name="chkCathLab" /><label for="chkCathLab">Cath Lab</label></div>
                        <div class="pd-check"><input type="checkbox" id="Procedure" name="Procedure" onchange="ShowProcTime();" /><label for="Procedure">Procedure</label></div>
                        <div class="pd-check"><input type="checkbox" id="ckhBedServices" name="ckhBedServices" /><label for="ckhBedServices">Bed Services</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkHighRisk" name="chkHighRisk" /><label for="chkHighRisk">High Risk</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkLabRequired" name="chkLabRequired" /><label for="chkLabRequired">Lab Required</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkOtherServices" name="chkOtherServices" /><label for="chkOtherServices">Other Services</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkLensRequired" name="chkLensRequired" /><label for="chkLensRequired">Lens Required</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkFitnessCertificate" name="chkFitnessCertificate" /><label for="chkFitnessCertificate">Fitness Certificates</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkPattHistorRequired" name="chkPattHistorRequired" /><label for="chkPattHistorRequired">Pat History Required</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkBillingRequired" name="chkBillingRequired" /><label for="chkBillingRequired">Billing Required</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkIsHospital" name="chkIsHospital" /><label for="chkIsHospital">Is Hospital Required</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkOTProcedure" name="chkOTProcedure" /><label for="chkOTProcedure">OT Procedure</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkIsService" name="chkIsService" /><label for="chkIsService">Services Item</label></div>
                        <div class="pd-check"><input type="checkbox" id="chkShortItem" name="chkShortItem" /><label for="chkShortItem">Short Item</label></div>
                        <div class="pd-check" style="display:none;"><input type="checkbox" id="chkSehatSahulat" name="chkSehatSahulat" /><label for="chkSehatSahulat">Sehat Sahulat</label></div>
                    </div>
                    <div class="pd-divider"></div>
                    <div class="pd-grid">
                        <div class="pd-field pd-s2">
                            <label id="lblProcedure_Time" for="Procedure_Time">Procedure Time</label>
                            <input type="text" id="Procedure_Time" class="pd-input" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="pd-actions">
            <div>
                <input type="button" class="btn btn-primry w-100" value="Save" id="btnValue" onclick="Saveitem()" />
            </div>
            <div>
                <input type="button" class="btn btn-gray w-100" value="View" id="btnBack" onclick="window.location = 'ProductsView.aspx'" />
            </div>
            <div>
                <input type="button" class="btn btn-yellow w-100" value="New" onclick="NewPage()" />
            </div>
        </div>
    </div>

</asp:Content>
