<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BOM.aspx.cs" Inherits="PMS.Inventory.BOM" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        table thead th {
            background-color: #e9ecef;
        }

        .total-box {
            background-color: #f8f9fa;
            padding: 12px;
            border-radius: 6px;
            margin-top: 15px;
            font-weight: bold;
        }

        .toast-center-screen {
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            width: fit-content;
        }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            var items = [];  // ✅ Global scope for deleteRow compatibility

            LoadProcedures();
            LoadItems();
            Loadunit();
            LoadWareHouse();
            $('#addItemBtn').click(function (e) {
                debugger;
                e.preventDefault();
                var itemId = $('#ddlitem').val();
                var itemName = $('#ddlitem :selected').text().trim();
                var qtyInBaseUnits = $('#itemQuantity').val().trim(); // e.g., 50ml
                var txtCalculatedPieces = $('#txtCalculatedPieces').val().trim(); // e.g., 50ml
                var unit = $('#itemUnit').val();
                var cost = $('#itemCost').val().trim();
                var baseUnitQtyPerPiece = $('#txtbaseunitqty').val().trim(); // e.g., 120ml/tube
                var weightedAvg = $('#txtWeightedAVG').val().trim();
                var batchNo = $('#ddlbatchno').val();

                if (!itemId || !qtyInBaseUnits || !cost || isNaN(qtyInBaseUnits) || isNaN(cost) || parseFloat(qtyInBaseUnits) <= 0) {
                    Swal.fire({ icon: 'warning', title: 'Warning!', text: 'Select item & enter valid qty/cost.', timer: 2000 });
                    return;
                }

                var total = (parseFloat(qtyInBaseUnits) * parseFloat(txtCalculatedPieces)).toFixed(2);
                var baseUnitQtyPerPieceValue = parseFloat(baseUnitQtyPerPiece) || 0;
                var quantityInPieces = (baseUnitQtyPerPieceValue > 0) ? (parseFloat(qtyInBaseUnits) / baseUnitQtyPerPieceValue) : 0;

                items.push({
                    ItemID: parseInt(itemId),
                    ItemName: itemName,
                    Qty: quantityInPieces, // pieces (for display)
                    Unit: unit,
                    CostPerUnit: parseFloat(cost),
                    Total: parseFloat(total),
                    Batch_No: batchNo,
                    BaseUnitQty: parseFloat(qtyInBaseUnits) // actual ml for deduction
                });
                debugger;
                var row = '<tr>' +
                    '<td><input type="text" name="ItemName" class="form-control" value="' + itemName + '" readonly /></td>' +
                    '<td><input type="text" name="Qty" class="form-control" value="' + quantityInPieces.toFixed(2) + '" readonly /></td>' +
                    '<td><input type="text" name="Unit" class="form-control" value="' + unit + '" readonly /></td>' +
                    '<td><input type="text" name="BatchNo" class="form-control" value="' + batchNo + '" readonly /></td>' +
                    '<td><input type="text" name="CostPerUnit" class="form-control" value="' + parseFloat(cost).toFixed(2) + '" readonly /></td>' +
                    '<td><input type="text" name="Total" class="form-control" value="' + total + '" readonly /></td>' +
                    '<td><small>Base: ' + parseFloat(qtyInBaseUnits).toFixed(2) + 'ml</small></td>' +
                    '<td>' +
                    '<input type="hidden" name="ItemID" value="' + itemId + '" />' +
                    '<input type="hidden" name="BaseUnitQty" value="' + parseFloat(qtyInBaseUnits).toFixed(2) + '" />' +
                    '<a href="javascript:void(0);" onclick="deleteRow(this)" style="cursor:pointer; border-radius:4px; background:#d91212; color:white; padding:4px 8px;">' +
                    '<i class="fa fa-trash"></i></a>' +
                    '</td>' +
                    '</tr>';

                $('#itemsTableBody').append(row);
                debugger;

                var grandTotal = items.reduce((sum, i) => sum + i.Total, 0);
                $('#grandTotal').text(grandTotal.toFixed(2));

                // Reset inputs
                $('#itemQuantity, #itemCost').val('');
                $('#txtCalculatedBaseQty, #txtCalculatedPieces').val('');
            });

            $('#btnSave').click(function (e) {
                e.preventDefault();
                var procedureId = $('#ddlprocedure').val();
                var category = $('#recipeCategory').val().trim();

                if (!procedureId) {
                    toasterMessage(true, 'Error!', 'Select Procedure.');
                    return;
                }
                if (items.length === 0) {
                    toasterMessage(true, 'Error!', 'Add at least one item.');
                    return;
                }

                var list = [];
                $('#itemsTableBody tr').each(function () {
                    var $row = $(this);
                    var item = {
                        ItemID: $row.find('input[name="ItemID"]').val(),
                        ItemName: $row.find('input[name="ItemName"]').val(),
                        Qty: $row.find('input[name="Qty"]').val(),
                        Unit: $row.find('input[name="Unit"]').val(),
                        CostPerUnit: $row.find('input[name="CostPerUnit"]').val(),
                        Total: $row.find('input[name="Total"]').val(),
                        Batch_No: $row.find('input[name="BatchNo"]').val() || $('#ddlbatchno').val(), // fallback if not in row
                        BaseUnitQty: $row.find('input[name="BaseUnitQty"]').val()
                    };
                    list.push(item);
                });

                PageMethods.SaveBOM(
                    procedureId,
                    category,
                    list,
                    function (response) {
                        if (response.startsWith("DUPLICATE:")) {
                            toasterMessage(true, 'Duplicate!', response.replace("DUPLICATE:", ""));
                            return;
                        }
                        if (response === "-1") {
                            toasterMessage(true, 'Failed!', 'Save failed. Check logs.');
                            return;
                        }
                        toasterMessage(false, 'Success!', 'BOM saved. ID: ' + response);
                        setTimeout(function () {
                            window.location.reload();
                        }, 2000);
                    },
                    function (error) {
                        toasterMessage(true, 'Error!', 'AJAX call failed.');
                    }
                );
            });
        });

        function toasterMessage(isError = false, title, message) {
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "preventDuplicates": false,
                "positionClass": "toast-center-screen",
                "onclick": null,
                "showDuration": "300",
                "hideDuration": "1000",
                "timeOut": "4000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut"
            };

            if (isError)
                toastr.error(message, title);
            else
                toastr.success(message, title);
        }

        function deleteRow(elem) {
            var $row = $(elem).closest('tr');
            var itemId = $row.find('input[name="ItemID"]').val();

            // Remove from items array
            items = items.filter(item => item.ItemID != itemId);

            $row.remove();

            var grandTotal = items.reduce((sum, i) => sum + i.Total, 0);
            $('#grandTotal').text(grandTotal.toFixed(2));
        }

        function Loadunit() {
            $.ajax({
                type: "POST",
                url: "BOM.aspx/GetUnitSize",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="">Select unit</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (i, v) {
                        options += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                    });
                    $('#itemUnit').html(options);
                    $('#itemUnit').select2();
                },
                error: function (xhr, status, err) {
                    console.error('Loadunit failed', err);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load units.' });
                }
            });
        }
        function LoadWareHouse() {
            $.ajax({
                type: "POST",
                url: "BOM.aspx/GetWareHouse",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="">Select Warehouse</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (i, v) {
                        options += '<option value="' + v.DataValue_Name + '">' + v.DataValue_Description + '</option>';
                    });
                    $('#ddlWarehouse').html(options);
                    $('#ddlWarehouse').select2();
                },
                error: function (xhr, status, err) {
                    console.error('Loadunit failed', err);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load units.' });
                }
            });
        }

        function LoadProcedures() {
            $.ajax({
                type: "POST",
                url: "BOM.aspx/LoadProcedures",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="">Select Procedure</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (i, v) {
                        options += '<option value="' + v.Item_ID + '">' + v.Description + '</option>';
                    });
                    $('#ddlprocedure').html(options);
                    $('#ddlprocedure').select2();
                },
                error: function (xhr, status, err) {
                    console.error('LoadProcedures failed', err);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load procedures.' });
                }
            });
        }

        function LoadItems() {
            $.ajax({
                type: "POST",
                url: "BOM.aspx/LoadItems",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="">Select Item</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (i, v) {
                        options += '<option value="' + v.Item_ID + '" data-cost="' + (v.Purchase_Rate || 0) + '">' + v.Description + '</option>';
                    });
                    $('#ddlitem').html(options);
                    $('#ddlitem').select2();
                },
                error: function (xhr, status, err) {
                    console.error('LoadItems failed', err);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load items.' });
                }
            });
        }

        // ✅ Renamed for clarity: when batch changes, fetch item details *for that batch*
        function onBatchSelectionChanged(selectElement) {
            var batchNo = selectElement.value;
            var itemId = $('#ddlitem').val();
            if (!itemId || batchNo === "0") {
                $('#txtpr_rate, #txtStock, #itemCost, #txtWeightedAVG, #txtbaseunitqty').val('');
                $('#itemUnit').html('<option value="">Select unit</option>');
                return;
            }

            $.ajax({
                type: "POST",
                url: "BOM.aspx/GetItemDetails",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ itemId: parseInt(itemId), batchNo: batchNo }),
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data && !data.error) {
                        var purchaseRate = parseFloat(data.Purchase_Rate) || 0;
                        $('#txtpr_rate').val(purchaseRate.toFixed(2));
                        $('#txtStock').val(data.StockDisplay || '');
                        $('#txtWeightedAVG').val((data.weighted_avg || 0).toFixed(2));
                        $('#txtbaseunitqty').val(data.Base_Unit_Qty || '');

                        // Update unit dropdown with base unit (disable since it's fixed per item)
                        var $unitSelect = $('#itemUnit');
                        $unitSelect.empty().append(
                            $('<option>', { value: data.baseUnit, text: data.baseUnitName })
                        );
                        $unitSelect.prop('disabled', true); // still disabled — it's informational
                    } else {
                        Swal.fire({ icon: 'warning', title: 'Not Found', text: data.error || 'Item details unavailable.' });
                        $('#txtpr_rate, #txtStock, #itemCost, #txtWeightedAVG, #txtbaseunitqty').val('');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Failed to load item details.' });
                    $('#txtpr_rate, #txtStock, #itemCost').val('');
                }
            });
        }

        function getbatchfrom_grn() {
            var med_id = $('#ddlitem').val();
            if (!med_id || isNaN(med_id)) {
                Swal.fire({ icon: 'warning', title: 'Select Item', text: 'Please select a valid item.' });
                return;
            }

            $.ajax({
                type: "POST",
                url: "BOM.aspx/Getbatch_grn",
                data: JSON.stringify({ med_id: parseInt(med_id) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var $batchSelect = $('#ddlbatchno');
                    $batchSelect.empty().append('<option value="0">-- Select Batch --</option>');

                    if (response.d) {
                        var result = JSON.parse(response.d);
                        var existingBatches = ['0'];

                        // Add GRN batches
                        if (result.GRN_Details && result.GRN_Details.length > 0) {
                            $.each(result.GRN_Details, function (i, item) {
                                if (item.BatchNum && existingBatches.indexOf(item.BatchNum) === -1) {
                                    $batchSelect.append('<option value="' + item.BatchNum + '">' + item.BatchNum + '</option>');
                                    existingBatches.push(item.BatchNum);
                                }
                            });
                        }

                        // Add Stock Adjustment batches (avoid dupes)
                        if (result.Stock_Adjustment_Details && result.Stock_Adjustment_Details.length > 0) {
                            $.each(result.Stock_Adjustment_Details, function (i, item) {
                                if (item.BatchNum && existingBatches.indexOf(item.BatchNum) === -1) {
                                    $batchSelect.append('<option value="' + item.BatchNum + '">' + item.BatchNum + '</option>');
                                }
                            });
                        }
                    }
                    if ($batchSelect.children().length === 1) {
                        $batchSelect.append('<option value="">No batches</option>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Failed to load batch numbers.' });
                }
            });
        }

        function getPerBaseUnitCost() {
            var baseUnitQtyPerPiece = parseFloat($('#txtbaseunitqty').val()) || 0; // e.g., 120 ml/tube
            var weightedAvg = parseFloat($('#txtWeightedAVG').val()) || 0;        // e.g., Rs. 2400/tube
            var qtyInBaseUnits = parseFloat($('#itemQuantity').val()) || 0;       // e.g., 50 ml

            if (baseUnitQtyPerPiece <= 0 || qtyInBaseUnits <= 0) {
                $('#itemCost').val('0.00');
                $('#txtCalculatedBaseQty').val(qtyInBaseUnits.toFixed(2));
                $('#txtCalculatedPieces').val('0.0000');
                return;
            }

            // Cost per ml = weighted_avg / baseUnitQtyPerPiece
            var costPerBaseUnit = (weightedAvg / baseUnitQtyPerPiece) * qtyInBaseUnits;

            $('#itemCost').val(costPerBaseUnit.toFixed(2));
            $('#txtCalculatedBaseQty').val(qtyInBaseUnits.toFixed(2));
            $('#txtCalculatedPieces').val((qtyInBaseUnits / baseUnitQtyPerPiece).toFixed(4));
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
  
        <input type="hidden" id="txtbaseunitqty" />

        <div class="col-lg-12">
            <div class="row mb-3">
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="ddlprocedure">Procedure Name <span class="text-danger">*</span></label>
                    <select id="ddlprocedure" class="form-control"></select>
                </div>
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="recipeCategory">Category</label>
                    <input type="text" id="recipeCategory" class="form-control" placeholder="e.g., Skincare" />
                </div>
                 <div class="col-lg-2 col-md-3 col-sm-3">
                     <label for="ddlWarehouse">WareHouse <span class="text-danger">*</span></label>
                     <select id="ddlWarehouse" class="form-control"></select>
                 </div>
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="txtWeightedAVG">Weighted Avg /Unit</label>
                    <input type="text" id="txtWeightedAVG" class="form-control" disabled="disabled" />
                </div>
                 <div class="col-lg-1 col-md-1 col-sm-1">
                     <label>Last P. Rate</label>
                     <input type="text" id="txtpr_rate" class="form-control" disabled="disabled" />
                 </div>
            </div>
            <hr />

            <div class="row mb-3 align-items-end">
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="ddlitem">Item Name <span class="text-danger">*</span></label>
                    <select id="ddlitem" class="form-control" onchange="getbatchfrom_grn()"></select>
                </div>
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="ddlbatchno">Batch No <span class="text-danger">*</span></label>
                    <select id="ddlbatchno" class="form-control" onchange="onBatchSelectionChanged(this)">
                        <option value="0">-- Select Batch --</option>
                    </select>
                </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                    <label for="itemQuantity">Qty (ml/g) <span class="text-danger">*</span></label>
                    <input type="number" step="0.01" min="0.01" id="itemQuantity" class="form-control" placeholder="e.g., 50" onchange="getPerBaseUnitCost();" />
                </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                    <label>Base Qty (ml)</label>
                    <input type="text" id="txtCalculatedBaseQty" class="form-control" readonly />
                </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                    <label>Eq. Pieces</label>
                    <input type="text" id="txtCalculatedPieces" class="form-control" readonly />
                </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                    <label>Base Unit</label>
                    <select id="itemUnit" class="form-control" disabled="disabled">
                        <option value="">Select unit</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label for="itemCost">Cost <span class="text-danger">*</span></label>
                    <input type="text" id="itemCost" class="form-control" disabled="disabled" placeholder="Auto" />
                </div>
                <div class="col-md-1">
                    <input type="button" id="addItemBtn" value="Add" class="btn btn-primry" style="margin-top: 20px;" />
                       
                  
                </div>
               
                <div class="col-md-2">
                    <label>Current Stock</label>
                    <input type="text" id="txtStock" class="form-control" readonly />
                </div>
            </div>

            <table class="table table-sm table-bordered mt-3" id="itemsTable">
                <thead>
                    <tr>
                        <th>Item</th>
                        <th>Qty (Pieces)</th>
                        <th>Unit</th>
                        <th>Batch</th>
                        <th>Cost/Unit</th>
                        <th>Total</th>
                        <th>Base Qty</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="itemsTableBody">
                    <!-- filled dynamically -->
                </tbody>
            </table>

            <div class="total-box">
                Total Cost: <span id="grandTotal">0.00</span>
            </div>
        </div>
    </div>

    <div class="row mt-3">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2 col-sm-2">
                <input type="button" id="btnSave" value="Save" class="btn btn-primry" />

            </div>
            <div class="col-lg-2 col-md-2 col-sm-2">
                <input type="button" id="btnNew" value="NEw" class="btn btn-primry" />
            </div>
        </div>
    </div>
</asp:Content>
