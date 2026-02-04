<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Product.aspx.cs" Inherits="PMS.Inventory.Product" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Product.css" rel="stylesheet" />
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
            if (id != "") {
                LoadItemInventory(id);

                $("#btnValue").val('Update');
            }
            else {
                GetitemNum();

            }

            document.getElementById('chkSehatSahulat').addEventListener('change', function () {
                const container = document.getElementById('sehatCardRateContainer');
                if (this.checked) {
                    container.style.display = 'block'; // Show the field
                } else {
                    container.style.display = 'none';  // Hide the field
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
            debugger;
            $.ajax({
                type: "POST",
                url: "Product.aspx/CheckActiveAllow",
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
            debugger;
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
            debugger;
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
            debugger;
            PageMethods.LoadBatchsRate(id, function (resp) {
                debugger;
                var datas = JSON.parse(resp);
                $.each(datas, function (key, data) {

                    var Batch_Num = data.Batch_Num || [];
                    var Item_Sale_Rate = data.Item_Sale_Rate || [];
                    var Sehat_card_rate_batch = data.Sehat_card_rate_batch || [];
                    var Uom_Qty = data.Uom_Qty || [];
                    var rows = '';
                    var rowlength = BatchTable.rows.length;
                    rows = '<tr>' +
                        '<td>' +
                        '<input type="hidden" name="ddlmed" id="ddlmed' + rowlength + '" value="' + Batch_Num + '" />' + Batch_Num +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="txtBatchRate" id="txtBatchRate' + rowlength + '" value="' + Item_Sale_Rate + '" />' + Item_Sale_Rate +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="txtsehatcardrate" id="txtsehatcardrate' + rowlength + '" value="' + Sehat_card_rate_batch + '" />' + Sehat_card_rate_batch +
                        '</td>' +
                        '<td>' +
                        '<input type="hidden" name="txtBatchRate" id="txtUom_Qty' + rowlength + '" value="' + Uom_Qty + '" />' + Uom_Qty +
                        '</td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                        '</td>' +
                        '</tr>'
                    $('#BatchTable_body').append(rows);

                });
            });
        }
        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function getbatchfrom_grn(id) {
            debugger;

            var item_id = id
            PageMethods.Getbatch_grn(item_id, function (data) {
                var parsedData = JSON.parse(data);
                var options = '<option value="0" >Please Select</option>';
                debugger;
                $.each(parsedData.GRN_Details, function (key, value) {
                    debugger;
                    options += '<option value="' + value.BatchNum +
                        '" data-uomqty="' + value.uomqty + '">' +
                        value.BatchNum + '</option>';
                });

                $.each(parsedData.Stock_Adjustment_Details, function (key, value) {
                    options += '<option value="' + value.BatchNum +
                        '" data-uomqty="0">' +   // no uomqty available here
                        value.BatchNum + '</option>';
                });
                debugger;
                $('#ddlBatchNum').html(options);
                $('#ddlBatchNum').select2();
                $('.select2-container--default').css('width', "150px")
            }, function (error) {
                alert(error.get_message());
            });
        }
        function AppendBatch() {
            debugger;

            var selectedOption = $('#ddlBatchNum option:selected');
            var selectedValue = selectedOption.val();
            var selectedText = selectedOption.text();
            var uomqty = selectedOption.data('uomqty') || 0;

            if (selectedValue && selectedValue !== "0") {
                var rowlength = BatchTable.rows.length;

                var rows = '<tr>' +
                    '<td>' +
                    '<input type="hidden" name="ddlBatch" id="ddlBatch' + rowlength + '" value="' + selectedText + '" />' +
                    selectedText +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtBatchRate" id="txtBatchRate' + rowlength + '" value="0" />' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtsehatcardrate" id="txtsehatcardrate' + rowlength + '" value="0" />' +
                    '</td>' +
                    '<td>' +
                    '<input type="text" name="txtUom_Qty" id="txtUom_Qty' + rowlength + '" value="' + uomqty + '" />' +
                    '</td>' +
                    '<td>' +
                    '<a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">' +
                    '<i class="glyphicon glyphicon-trash" style="width:15px;font-size:13px;color:#f30a0a;"></i>' +
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
                    debugger;
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
                var refregrator = $('#Refregrator').prop('checked');
                var procedureTypes = $('#ddlProcedureTypes').val();
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
                $('#BatchTable_body tr').each(function (key, value) {
                    var txtBatchRate = $(this).find('input[name="txtBatchRate"]').val();
                    var txtSCRate = $(this).find('input[name="txtsehatcardrate"]').val();
                    var txtUom_Qty = $(this).find('input[name="txtUom_Qty"]').val();
                    var ddlBatch = $(this).find('input[name="ddlBatch"]').val();
                    batchList.push({ txtBatchRate: txtBatchRate, txtSCRate: txtSCRate, ddlBatch: ddlBatch, txtUom_Qty: txtUom_Qty });
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
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var msg = response.d;
                        var Split = msg.split("-");
                        if (Split[0] == "Success") {
                            debugger;
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
                            debugger;
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
                    debugger;
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
            debugger;
            $.ajax({
                type: "POST",
                url: "Product.aspx/LoadItemInventory",
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
                        getbatchfrom_grn(id);
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

                    if (parse.issehatCard_item == 1) {
                        $("#chkSehatSahulat").prop('checked', true);
                    }
                    LoadPatientTypeWiseRate(id);

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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" name="item_rate_id" value="${rowId}" />
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
                      <option value="0">Please Select</option>
                </select>
                     </div>
               </div>
         </div>

         <div class="row">
                  <div class="col-lg-2 col-md-6 col-sm-12">
                    <label id="Lblpack_unit">UOM</label>
                    <select id="ddlpack_unit">
                       <option>Please Select</option>
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
                  <option value="0">Please Select</option>
                  <option value="Yes">Yes</option>
                  <option value="No">No</option>
                </select>
           </div>
             </div>  
         <div class="col-lg-3 col-md-6 col-sm-12">
                   <div class="form-group">
              <label id="LblwareHouse" style="width: 146px">WareHouse</label>
                <select id="ddlwareHouse"  class="form-control">
                     <option value="0">Please Select</option>
                </select>
                </div>       
             </div> 
         <div class="col-lg-3 col-md-6 col-sm-12 p-5" style="margin-top: 25px;">
                 
             <div class="form-group form-check">
                  <input type="checkbox" class="form-check-input" style="width:auto !important" id="Active" name="Active" />
               <label class="form-check-label" id="LblActive" for="Active">Active</label>
           
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
            <div class="col-lg-1 col-md-6 col-sm-12" >       
                  <label id="Lblpurch_rate">PR Rate</label>
                  <input type="text" class="form-control" id="purch_rate" name="purch_rate" />
             </div>
              <div class="col-lg-1 col-md-6 col-sm-12">
                  <label id="lblunitSize">Unit Size</label>
                  <select id="ddlunitsize"></select>
              </div>
               <div class="col-lg-1 col-md-6 col-sm-12" >       
                   <label id="lblunitsizeqty">Unit Size QTY</label>
                   <input type="text" class="form-control" id="txtunitqty" name="purch_rate" />
              </div>
             <div class="col-lg-1 col-md-6 col-sm-12">

            </div>
              <div class="col-lg-1 col-md-6 col-sm-12" id="sehatCardRateContainer" style="display: none;">
                <label id="LblsehatCardrate">Sehat Card Rate</label>
                <input type="text" class="form-control" id="txtSehatCardRate" name="txtSehatCardRate" />
            </div> 
           
           <div class="col-lg-5 col-md-12 col-sm-12">
             <label id="Lblremarks">Remarks</label>
              <input type="text" class="form-control" id="txtremarks" name="txtremarks" />           
           </div>
            </div>
            <div class="col-lg-1 col-md-6 col-sm-12"  style="display:none">
                    <label id="LblLength">Length</label>
                    <input type="text" class="form-control" id="txtLength" name="txtLength" />
                </div> 
                <div class="col-lg-1 col-md-6 col-sm-12"  style="display:none">
                     <label id="Lblwidth">Width</label>
                       <input type="text" class="form-control" id="txtwidth" name="txtwidth" />
                </div> 
                <div class="col-lg-1 col-md-6 col-sm-12"  style="display:none">
                    <label id="Lblheight">Height</label>
                    <input type="text" class="form-control" id="txtheight" name="txtheight" />
            </div> 
         </form>


    <table style="width: 100% !important">
    </table>       
    <div id="tabs">
        <ul>
            <li><a href="#Tab-3">General</a></li>
            <li><a href="#Tab-4">Pharmacy</a></li>
            <li><a href="#Tab-1">Procedure</a></li>
            <li><a href="#Tab-5">Item Tags</a></li>
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
                                            <option value="0">Please Select</option>
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
                                        <select id="ddldepartment" >
                                            <option value="0">Please Select</option>
                                        </select>          
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </td>
                </tr>
            </table>
        </div>        
   <div id="Tab-3" style="display: flex; gap: 40px; align-items: flex-start; padding: 20px;">

    <!-- LEFT: Stock Level Section -->
    <div style="flex: 1; border: 1px solid #ddd; padding: 15px; border-radius: 6px; background-color: #f9f9f9;">
        <span style="font-size: 15px; font-weight: bold;">Stock Level</span>
        <table class="table-responsive-lg table-responsive-md" style="width: 100%; margin-top: 10px;">
            <tr>
                <td style="width: 120px;">Minimum Stock</td>
                <td><input type="text" id="minimum_stock" name="minimum_stock" style="width: 100%;" /></td>
            </tr>
            <tr>
                <td>Reorder Stock</td>
                <td><input type="text" id="Reorder_Stock" name="Reorder_Stock" style="width: 100%;" /></td>
            </tr>
            <tr>
                <td>Maximum Stock</td>
                <td><input type="text" id="Maximum_Stock" name="Maximum_Stock" style="width: 100%;" /></td>
            </tr>
        </table>
    </div>

   <div style="flex: 1; padding: 20px; border: 1px solid #ddd; border-radius: 8px; background-color: white;">
    <!-- Input Row -->
    <div style="display: flex; gap: 15px; margin-bottom: 15px; align-items: center;">
        <div style="flex: 1;">
            <label style="font-weight: bold; display: block; margin-bottom: 5px;">Patient_type</label>
            <select id="ddlPatient_type" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px;">
              <option value="0">Please Select</option>
            </select>
        </div>

        <div style="flex: 1;">
            <label style="font-weight: bold; display: block; margin-bottom: 5px;">Rate</label>
            <input type="number" id="txtRate" placeholder="Enter rate" style="width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-size: 14px;" />
        </div>
          <input type="button" style="width:25px !important" value="+" class="btn-primry" onclick="AddRateCategory()" />


    </div>


  

    <!-- Table for Appended Entries -->
    <div style="margin-top: 15px; border: 1px solid #ddd; border-radius: 6px; overflow: hidden;">
        <table class="table">
            <thead style="background-color: #f5f5f5; border-bottom: 1px solid #ddd;">
                <tr>
                    <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 14px;">Patient_type</th>
                    <th style="padding: 12px; text-align: left; font-weight: 600; font-size: 14px;">Rate</th>
                    <th style="padding: 12px; text-align: center; font-weight: 600; font-size: 14px;">Action</th>
                </tr>
            </thead>
            <tbody id="tbodypatientRateList">
               
            </tbody>
        </table>
    </div>

    <!-- Hidden field for form submission -->
    <input type="hidden" id="patientRatesData" name="patientRatesData" value="" />
</div>

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
                    <td style="width: 21px;" class="DiscountBlock">
                        <input type="checkbox" id="Discount_Block" name="Discount_Block" /></td>
                    <td class="DiscountBlock" style="width: 84px;">Discount Block</td>
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
                            <option value="0">Please Select</option>
                        </select>
                    </td>
                    <td><label id="Lblitem_Qty" style="display: inline-block; float: left; position: relative; width: 150px !important;margin-left: 33px;margin-bottom: 10px">Item Main Category</label></td>

                    <td  style="width: 170px !important;min-width:170px !important;">
                        
                        <select id="ddlitem_Qty" style="height: 33px !important" name="ddlitem_Qty">
                             <option value="0">Please Select</option>
                        </select>
                    </td>
                </tr>
            </table>
            <table style="margin-left:0px">
                <tr>
                    <td style="width: 66px;">Generic Name</td>
                    <td>
                        <input type="text" id="GenericName" name="GenericName" style="width: 166px!Important; margin-left: 8px" /></td>
                    <td style="width: 66px;">
                        <label style="margin-right: 40px;margin-left: 15px;">Batch Number</label></td>
                    <td >
                        <select id="ddlBatchNum" style="width: 170px;"></select>

                    </td>
                    <td>
                        <input type="button" onclick="AppendBatch()" value="+" id="AddBatch" style="width: 44px; margin-left: 10px !important;" /></td>
                </tr>
            </table>
            <table class="table table-bordered" id="BatchTable" style="overflow: scroll; width: 550px; height: auto;">

                <tr id="row_sample">
                    <th style="width: 40%;">Batch Number</th>
                    <th style="width: 30%;">Rate</th>
                    <th style="width: 30%;">Sehat Card Rate</th>
                    <th style="width: 20%;">Uom Qty</th>
                    <th style="text-align: center; width: 10%;">ACTIONS</th>
                </tr>
                <tbody id="BatchTable_body">
                </tbody>
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
                        <input type="checkbox" id="Procedure" name="Procedure" onchange="ShowProcTime();" />
                    </td>
                    <td style="width: 84px;">Procedure</td>
                    <td style="width: 5px;">
                        <input type="checkbox" id="ckhBedServices" name="ckhBedServices" /></td>
                    <td style="width: 84px;">Bed Services</td>
                    <td><label id="lblProcedure_Time" >Procedure Time</label></td>
                    <td><input type="text" id="Procedure_Time"  /></td>
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
                    <td style="display:none;">
                        <input type="checkbox" id="chkSehatSahulat" name="chkSehatSahulat" />
                    </td>
                    <td style="width: 84px;display:none;">
                        <label for="chkSehatSahulat">Sehat Sahulat</label>
                    </td>
                </tr>
            </table>
        </div>
    </div>

    <div class="row" style="margin-top:1%">
         <div class="col-lg-8">
            <div class="row">
                  <div class="col-lg-2 col-md-4 col-sm-12">
     <input type="button" class="btn-gray" value="View" id="btnBack" onclick="window.location = 'ProductsView.aspx'" />
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

