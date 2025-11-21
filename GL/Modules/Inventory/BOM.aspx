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
            LoadProcedures();
            LoadItems();

            var items = [];

         

            $('#addItemBtn').click(function (e) {
                e.preventDefault(); // ✅ Prevent accidental form submission
                var itemId = $('#ddlitem').val();
                var itemName = $('#ddlitem :selected').text().trim();
                var qty = $('#itemQuantity').val().trim();
                var unit = $('#itemUnit').val();
                var cost = $('#itemCost').val().trim();

                if (!itemId || !qty || !cost || isNaN(qty) || isNaN(cost) || parseFloat(qty) <= 0) {
                    Swal.fire({ icon: 'warning', title: 'Warning!', text: 'Select item & enter valid qty/cost.', timer: 2000 });
                    return;
                }

                var total = (parseFloat(qty) * parseFloat(cost)).toFixed(2);

                items.push({
                    ItemID: parseInt(itemId),
                    ItemName: itemName,
                    Qty: parseFloat(qty),
                    Unit: unit,
                    CostPerUnit: parseFloat(cost),
                    Total: parseFloat(total)
                });

                var row = '<tr>' +
                    '<td><input type="text" name="ItemName" class="form-control" value="' + itemName + '" readonly /></td>' +
                    '<td><input type="text" name="Qty" class="form-control" value="' + qty + '" readonly /></td>' +
                    '<td><input type="text" name="Unit" class="form-control" value="' + unit + '" readonly /></td>' +
                    '<td><input type="text" name="CostPerUnit" class="form-control" value="' + parseFloat(cost).toFixed(2) + '" readonly /></td>' +
                    '<td><input type="text" name="Total" class="form-control" value="' + total + '" readonly /></td>' +
                    '<td><input type="hidden" name="ItemID" value="' + itemId + '" />' +
                    '<a href="javascript:void(0);" onclick="deleteRow(this)" style="cursor:pointer; border-radius:4px; background:#d91212; color:white; padding:4px 8px;">' +
                    '<i class="fa fa-trash"></i></a></td>' +
                    '</tr>';
                $('#itemsTableBody').append(row);

                var grandTotal = items.reduce((sum, i) => sum + i.Total, 0);
                $('#grandTotal').text(grandTotal.toFixed(2));

                // Reset inputs
                $('#itemQuantity, #itemCost').val('');
            });

            $('#btnSave').click(function (e) {
                e.preventDefault(); // ✅ Prevent accidental form submission
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
                        Total: $row.find('input[name="Total"]').val()
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
            $(elem).closest('tr').remove();
            var total = 0;
            $('#itemsTableBody input[name="Total"]').each(function () {
                total += parseFloat($(this).val()) || 0;
            });
            $('#grandTotal').text(total.toFixed(2));
        }

        function LoadProcedures() {
            $.ajax({
                type: "POST",
                url: "BOM.aspx/LoadProcedures",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    // ✅ Fixed: typo in first option: </option> → </option>
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
                        // ✅ Store cost in data-cost for easy access
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

        function onItemSelectionChanged(selectElement) {
            var batchno = selectElement.value;
            var itemId = $('#ddlitem').find('option:selected').val();
            if (!itemId) {
                $('#txtpr_rate, #txtStock, #itemCost').val('');
                return;
            }

            $.ajax({
                type: "POST",
                url: "BOM.aspx/GetItemDetails",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({
                    itemId: parseInt(itemId),
                    batchNo: batchno  
                }),
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data && !data.error) {
                        var purchaseRate = parseFloat(data.Purchase_Rate) || 0;
                        $('#txtpr_rate').val(purchaseRate.toFixed(2));
                        $('#itemCost').val(purchaseRate.toFixed(2)); // ✅ Auto-fill cost from PR
                        $('#txtStock').val(data.StockDisplay || '');

                        // Auto-set unit if match exists
                        if (data.BaseUnit) {
                            var $unitDropdown = $('#itemUnit');
                            if ($unitDropdown.find('option[value="' + data.BaseUnit + '"]').length) {
                                $unitDropdown.val(data.BaseUnit).trigger('change');
                            }
                        }
                    } else {
                        Swal.fire({ icon: 'warning', title: 'Not Found', text: data.error || 'Item details unavailable.' });
                        $('#txtpr_rate, #txtStock, #itemCost').val('');
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
            debugger;

            var med_id = $('#ddlitem').find('option:selected').val();

            if (!med_id || isNaN(med_id)) {
                alert("Please select a valid medicine.");
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
                    // Always show default option first
                    $batchSelect.empty().append('<option value="0">-- Select Batch --</option>');

                    if (response.d) {
                        var result = JSON.parse(response.d);

                        // Append GRN batches
                        if (result.GRN_Details && result.GRN_Details.length > 0) {
                            $.each(result.GRN_Details, function (i, item) {
                                if (item.BatchNum) {
                                    $batchSelect.append('<option value="' + item.BatchNum + '">' + item.BatchNum + '</option>');
                                }
                            });
                        }

                        // Append Stock Adjustment batches (avoid duplicates)
                        if (result.Stock_Adjustment_Details && result.Stock_Adjustment_Details.length > 0) {
                            var existingBatches = $batchSelect.find('option').map(function () { return $(this).val(); }).get();

                            $.each(result.Stock_Adjustment_Details, function (i, item) {
                                if (item.BatchNum && existingBatches.indexOf(item.BatchNum) === -1) {
                                    $batchSelect.append('<option value="' + item.BatchNum + '">' + item.BatchNum + '</option>');
                                    existingBatches.push(item.BatchNum);
                                }
                            });
                        }
                    } else {
                        $batchSelect.append('<option value="">No batches found</option>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    alert("Failed to load batch numbers. Please try again.");
                }
            });
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-12">
            <div class="row mb-3">
                <div class="col-lg-3">
                    <label for="ddlprocedure">Procedure Name <span class="text-danger">*</span></label>
                    <select id="ddlprocedure" class="form-control"></select>
                </div>
                <div class="col-lg-3">
                    <label for="recipeCategory">Category</label>
                    <input type="text" id="recipeCategory" class="form-control" placeholder="e.g., Skincare" />
                </div>
            </div>
            <hr />

            <div class="row mb-3 align-items-end">
                <div class="col-lg-2 col-md-3 col-sm-3">
                    <label for="ddlitem">Item Name <span class="text-danger">*</span></label>
                    <select id="ddlitem" class="form-control" onchange="getbatchfrom_grn()" ></select>
                </div>
                 <div class="col-lg-2 col-md-3 col-sm-3">
                         <label for="ddlbatchno">Batch no <span class="text-danger">*</span></label>
                         <select id="ddlbatchno" onchange="onItemSelectionChanged(this)" class="form-control"></select>
                     </div>
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <label for="itemQuantity">Qty <span class="text-danger">*</span></label>
                    <input type="number" id="itemQuantity" step="0.01" min="0.01" class="form-control" placeholder="Qty" />
                </div>
                <div class="col-lg-1 col-md-2 col-sm-1">
                    <label for="itemUnit">Unit</label>
                    <select id="itemUnit" class="form-control">
                        <option value="g">g</option>
                        <option value="ml">ml</option>
                        <option value="pcs">pcs</option>
                        <option value="oz">oz</option>
                        <option value="cup">cup</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label for="itemCost">Cost/Unit <span class="text-danger">*</span></label>
                    <input type="number" id="itemCost" step="0.01" min="0" class="form-control" placeholder="Cost" />
                </div>
                <div class="col-md-1">
                    <!-- ✅ Fixed: button type="button" to prevent postback -->
                    <button type="button" id="addItemBtn" class="btn btn-primary">
                        <i class="fa fa-plus"></i>Add
                    </button>
                </div>
                <div class="col-md-1">
                    <label>P_Rate</label>
                    <input type="text" disabled="disabled" id="txtpr_rate" class="form-control" />
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
                        <th>Qty</th>
                        <th>Unit</th>
                        <th>Cost/Unit</th>
                        <th>Total</th>
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

    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2 col-sm-2">
                <input type="button" id="btnSave" class="btn btn-primry" value="Save" />

            </div>
            <div class="col-lg-2 col-md-2 col-sm-2">
                <input type="button" class="btn btn-primry" value="New" onclick="window.location='BOM.aspx'" />

            </div>

        </div>
    </div>
</asp:Content>
