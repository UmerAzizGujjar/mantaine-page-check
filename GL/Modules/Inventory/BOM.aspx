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

            $('#ddlitem').change(function () {
                var cost = $(this).find(':selected').data('cost') || 0;
                $('#itemCost').val(parseFloat(cost).toFixed(2));
            });

            $('#addItemBtn').click(function () {
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

                // Reset
                $('#ddlitem').val('');
                $('#itemQuantity, #itemCost').val('');
                $('#ddlitem').focus();
            });

            $('#btnSave').click(function () {
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
                            window.location.reload(); // or redirect as needed
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
                "showDuration": "551500",
                "hideDuration": "2000",
                "timeOut": "4000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut",
                onclick: function () {
                    $('#right-sidebar').toggleClass('sidebar-open');
                }
            };

            if (isError)
                toastr.error(message, title);
            else
                toastr.success(message, title);
        }

        function deleteRow(elem) {
            $(elem).closest('tr').remove();
            // Recalculate total (optional — can also recompute on save)
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
                    var options = '<option value="">Select<option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (i, v) {
                        options += '<option value="' + v.Item_ID + '">' + v.Description + '</option>';
                    });
                    $('#ddlprocedure').html(options);
                    $('#ddlprocedure').select2();
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
                        options += '<option value="' + v.Item_ID + '">' + v.Description + '</option>';
                    });
                    $('#ddlitem').html(options);
                    $('#ddlitem').select2();
                }
            });
        }

        function onItemSelectionChanged(selectElement) {
            var itemId = selectElement.value;
            $.ajax({
                type: "POST",
                url: "BOM.aspx/GetItemDetails",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ itemId: parseInt(itemId) }),
                success: function (response) {
                    var data = JSON.parse(response.d);
                    if (data && data !== null) {
                        $('#txtpr_rate').val(data.P_Rate ? parseFloat(data.P_Rate).toFixed(2) : '');
                        $('#txtStock').val(data.CurrentStock ? parseFloat(data.CurrentStock).toFixed(2) : '');
                    }
                },
                error: function () {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Failed to load item details.' });
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
                    <label>Procedure Name <span class="text-danger">*</span></label>
                    <select id="ddlprocedure" class="form-control"></select>
                </div>
                <div class="col-lg-3">
                    <label>Category</label>
                    <input type="text" id="recipeCategory" class="form-control" placeholder="e.g., Skincare" />
                </div>
            </div>
            <hr />

            <div class="row mb-3 align-items-end">
                <div class="col-lg-3 col-md-3 col-sm-3">
                    <label>Item Name <span class="text-danger">*</span></label>
                   <select id="ddlitem" class="form-control" onchange="onItemSelectionChanged(this)"></select>
                </div>
                <div class="col-lg-1 col-md-1 col-sm-1">
                    <label>Qty <span class="text-danger">*</span></label>
                    <input type="number" id="itemQuantity" step="0.01" min="0.01" class="form-control" />
                </div>
                <div class="col-lg-1 col-md-2 col-sm-1">
                    <label>Unit</label>
                    <select id="itemUnit" class="form-control">
                        <option value="g">g</option>
                        <option value="ml">ml</option>
                        <option value="pcs">pcs</option>
                        <option value="oz">oz</option>
                        <option value="cup">cup</option>
                    </select>
                </div>
                <div class="col-md-1">
                    <label>Cost/Unit <span class="text-danger">*</span></label>
                    <input type="number" id="itemCost" step="0.01" min="0" class="form-control" />
                </div>
               
                <div class="col-md-1">
                    <button id="addItemBtn" class="btn btn-primry">
                        <i ></i>Add
                    </button>
                </div>
                 <div class="col-md-1">
                     <label>P_Rate  <span class="text-danger">*</span></label>
                     <input type="text" disabled="disabled" id="txtpr_rate" step="0.01" min="0" class="form-control" />
                 </div>
                 <div class="col-md-1">
                     <label>Current Stock <span class="text-danger">*</span></label>
                     <input type="number" id="txtStock" step="0.01" min="0" class="form-control" />
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
