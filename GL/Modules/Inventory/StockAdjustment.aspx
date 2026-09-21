<%@ Page Title="Stock Adjustment" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StockAdjustment.aspx.cs" Inherits="PMS.WebForm5" EnableEventValidation="false" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/stockadjustment.css" rel="stylesheet" />

    <script type="text/javascript">
        var Stock_ID = 0;
        var warehouseCond;
        var gridItems = [];
        var savedBranch = null;

        function loadUserBranch() {
            PageMethods.GetUserBranch(function (result) {
                if (!result || result === "null") {
                    $('#ddlBranch').empty().append('<option value="0">No Branch Assigned</option>');
                    return;
                }
                var branches = JSON.parse(result);
                $('#ddlBranch').empty();
                branches.forEach(function (branch) {
                    $('#ddlBranch').append('<option value="' + branch.branch_ID + '">' + branch.branch_Name + '</option>');
                });
                if (branches.length === 1) {
                    $('#ddlBranch').val(branches[0].branch_ID);
                } else {
                    $('#ddlBranch').prepend('<option value="0">Please Select</option>').val('0');
                }
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
            });
        }

        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/" + methodName,
                data: JSON.stringify(params || {}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (typeof successCallback === 'function') successCallback(response.d);
                },
                error: function (xhr, status, error) {
                    console.error('Error calling ' + methodName + ':', xhr.status, error);
                    if (typeof errorCallback === 'function') errorCallback(error);
                }
            });
        }

        $(document).ready(function () {
            // Batch input changes
            $('#ctl00_MainContent_txtBatchNo').on('change keyup', function () {
                DisableDropdownOnTextInput();

                if ($(this).val() != '') {
                    $(this).removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(0);
                    $('#ctl00_MainContent_hdallowblank').val(0);
                } else {
                    $(this).addClass('ErrorAlert');
                    $('#ctl00_MainContent_hdbatch').val(1);
                    $('#ctl00_MainContent_hdallowblank').val(1);
                }
            });

            // Initialize Select2 for Dropdown Batch
            $('#ctl00_MainContent_ddlBatchNo').select2({
                width: '100%',
                placeholder: '-- Select Batch --',
                allowClear: true,
                closeOnSelect: true,
                dropdownParent: $('#<%= pnlForm.ClientID %>')
            });

            $('#ctl00_MainContent_ddlBatchNo').on('change select2:close', function () {
                DisableTextOnDropdownChange();
                var $ddl = $(this);
                setTimeout(function () {
                    $ddl.select2('close');
                }, 100);
            });

            // Expire date change event
            $('#ctl00_MainContent_txtExpiredate').on('change', function () {
                if ($(this).val() != '') {
                    $(this).removeClass('ErrorAlert');
                    $('#ctl00_MainContent_hdDate').val(0);
                } else {
                    $(this).addClass("ErrorAlert");
                    $('#ctl00_MainContent_hdDate').val(1);
                }
            });

            $('#ctl00_MainContent_ddl_Ware_House').on('change', function () {
                var itemId = $('#ctl00_MainContent_hdfItem_ID').val();
                var warehouseVal = $(this).val();
                if (itemId && itemId !== "" && itemId !== "0" && warehouseVal && warehouseVal !== "0") {
                    LoadPurchaseRate(itemId, warehouseVal);
                }
            });
            GetWareHouseCondition();
            GetMultipleBatchCondition();
            UserRights();
            savedBranch = $('#<%= hdnBranch_Id.ClientID %>').val();
            $('#ddlBranch').select2({ width: '100%' });
            loadUserBranch();

            // Initialize TokenInput for Item Selection
            $('#ctl00_MainContent_txtItem_Code').tokenInput(function () {
                if (warehouseCond == '01') {
                    var warehouseVal = $('#ctl00_MainContent_ddl_Ware_House').val();
                    if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Select Warehouse',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        return "";
                    }
                    return "../../json.aspx?Table=INV_ItemsforStockAdjWareHouse&WarehouseID=" + encodeURIComponent(warehouseVal);
                }
                else {
                    return "../../json.aspx?Table=INV_ItemsforStockAdj";
                }
            },
                {
                    tokenLimit: 1,
                    hintText: "Select a warehouse first...",
                    noResultsText: "No items found.",
                    searchingText: "Searching...",
                    onAdd: function (item) {
                        $('#ctl00_MainContent_hdfItem_ID').val(item.id);
                        $('#ctl00_MainContent_hdnDescription').val(item.name);
                        LoadBatches(item.id);
                        calculatecurrentstock(item.id);
                        var warehouseVal = $('#ctl00_MainContent_ddl_Ware_House').val();
                        if (warehouseVal && warehouseVal !== "0" && warehouseVal !== "") {
                            LoadPurchaseRate(item.id, warehouseVal);
                        } else {
                            $('#ctl00_MainContent_txtRate').val('');
                        }

                        if (item.Type === "True") {
                            $('#ctl00_MainContent_hdbatch').val(1);
                            $('#ctl00_MainContent_hdDate').val(1);
                            $('#ctl00_MainContent_hdallowblank').val(1);

                            $('#ctl00_MainContent_txtBatchNo').addClass("ErrorAlert");
                            $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");

                            $('#ctl00_MainContent_hdbatch').val(1);
                            $('#ctl00_MainContent_hdDate').val(1);
                            $('#ctl00_MainContent_hdallowblank').val(0);
                        }
                        return false; 
                    },
                    onDelete: function (item) {
                        $('#ctl00_MainContent_hdfItem_ID').val('');
                        $('#ctl00_MainContent_hdnDescription').val('');
                        return false;
                    }
                });

            <% if (Request.QueryString["ID"] != null) { %>
            Stock_ID = '<%= Request.QueryString["ID"]%>';
            <% } %>

            if (Stock_ID == 0) {
                $('#btnVoucher').hide();
            }

            var status = $('#ctl00_MainContent_txt_status').val();
            if (status == "Approved") {
                $('#ctl00_MainContent_btnSave').prop("disabled", true);
                $('#btnVoucher').show();
                UserUnApproveButtonRights();
            }
            if (status == "Created" || status == "Pending") {
                $('#ctl00_MainContent_btnSave').prop("disabled", false);
                $('#btnVoucher').hide();
            }
            if (Stock_ID != "") {
                CheckSTOCKADJApprovalRightsAndShowButton(Stock_ID);
            }

            // Datepicker configs
            var ad_ID = '<%= Request.QueryString["ID"] %>';
            var $adjustDate = $('#ctl00_MainContent_txtAdustment_date');
            var $expireDate = $('#ctl00_MainContent_txtExpiredate');
            var dateFormat = "dd M yy";

            $adjustDate.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: dateFormat
            });

            $expireDate.datepicker({
                changeMonth: true,
                changeYear: true,
                yearRange: "-50:+50",
                dateFormat: dateFormat
            });

            if (ad_ID === "") {
                var currentDate = $.datepicker.formatDate(dateFormat, new Date());
                $adjustDate.val(currentDate);
                $expireDate.val(currentDate);
            }

            var AdjustmentID = $('#<%=txtAdjustment_ID.ClientID%>').val();
            var Item_Code = $("#ctl00_MainContent_txtItem_Code").val();
            var Item_ID = $("#ctl00_MainContent_hdfItem_ID").val();
            var Item_Name = $("#ctl00_MainContent_hdnDescription").val();

            if (AdjustmentID != "(New)") {
                var tokendata = [{ "id": Item_ID, "name": Item_Code + '-' + Item_Name, "Type": "", "Amount": '+0+' }];
                loadtokenInputsForPRNo("#ctl00_MainContent_txtItem_Code", tokendata);
              //  calculatecurrentstock(Item_ID);

                var warehouseVal = $('#ctl00_MainContent_ddl_Ware_House').val();
                // if (Item_ID && Item_ID !== "" && Item_ID !== "0" && warehouseVal && warehouseVal !== "0") {
                //     LoadPurchaseRate(Item_ID, warehouseVal);
                // }
            }
            $('.token-input-list').css('width', '368px');
        });


        function LoadPurchaseRate(itemId, warehouseId) {
            if (!itemId || itemId === "" || itemId === "0") return;
            if (!warehouseId || warehouseId === "" || warehouseId === "0") {
                $('#ctl00_MainContent_txtRate').val('');
                return;
            }

            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/GetPurchaseRate",
                data: JSON.stringify({ itemId: itemId, warehouseId: warehouseId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var rate = response.d;
                    if (rate && rate !== "") {
                        $('#ctl00_MainContent_txtRate').val(rate);
                        onchange();
                    } else {
                        $('#ctl00_MainContent_txtRate').val('');
                    }
                },
                error: function (error) {
                    console.error("Error loading purchase rate:", error);
                    $('#ctl00_MainContent_txtRate').val('');
                }
            });
        }
        function hiddenVal(hiddenDate, hiddenbatch, hiddenallowblank) {
            if (hiddenDate == "1") $('#ctl00_MainContent_txtExpiredate').addClass("ErrorAlert");
            if (hiddenbatch == "1") $('#ctl00_MainContent_txtBatchNo').addClass("ErrorAlert");
        }

        function GetWareHouseCondition() {
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#divWarehouse').show();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }

        function loadtokenInputsForPRNo(elementId, data) {
            if (elementId == "#ctl00_MainContent_txtItem_Code") {
                $(elementId).tokenInput("../../json.aspx?Table=INV_ItemsforStockAdj&q=", {
                    prePopulate: data,
                    tokenLimit: 1,
                });
            }
        }

        function UserRights() {
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#ctl00_MainContent_btnSave').show();
                    } else {
                        $('#ctl00_MainContent_btnSave').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }

        function onchange() {
            var num1 = parseFloat(document.getElementById('<%= txtQuantity.ClientID %>').value);
            var num2 = parseFloat(document.getElementById('<%= txtRate.ClientID %>').value);
            if (isNaN(num1)) num1 = 0;
            if (isNaN(num2)) num2 = 0;
            var totalresult = num1 * num2;
            document.getElementById('<%= txtAmount.ClientID %>').value = parseFloat(totalresult).toFixed();
        }

        function New() {
            window.location = "StockAdjustment.aspx";
        }

        function Validate() {
            var val = document.getElementById("hdnDuplicateCheck").value;

            if (!checkRemarksBeforeSave()) {
                return false;
            }

            // Bind grid JSON data right before validation postback triggers
            var activeItems = gridItems.filter(function (item) { return item !== null; });
            $('#ctl00_MainContent_hdnGridData').val(JSON.stringify(activeItems));

            if (val == "0") {
                document.getElementById("hdnDuplicateCheck").value = "1";
                return true; 
            } else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Processing Please Wait',
                    showConfirmButton: false,
                    timer: 2000
                });
                return false;
            }
        }

        function UnApprove() {
            PageMethods.UnApproveStock(Stock_ID, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" && message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }

        function CheckSTOCKADJApprovalRightsAndShowButton(stockId) {
            callPageMethod('CheckSTOCKADJApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetSTOCKADJApprovalInfo', { AdjustmentId: stockId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                        }
                    });
                }
            });
        }
        function ApproveSTOCKADJFromEdit() {
            var adjustmentId = Stock_ID;
            Swal.fire({
                title: 'Approve Stock Adjustment?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Approve',
                cancelButtonText: 'Cancel',
                input: 'textarea',
                inputPlaceholder: 'Approval remarks (optional)...',
                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
            }).then((result) => {
                if (result.isConfirmed) {
                    var remarks = result.value || '';
                    callPageMethod('ApproveSingleSTOCKADJ', { AdjustmentId: adjustmentId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'Stock Adjustment has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }

        function PrintVoucher() {
            var id = '<%= Request.QueryString["ID"]%>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            var reportPath = (user_name == 'As-Siraat Serving Humanity') ? '../../ReportViewer.aspx' : 'ReportViewer.aspx';

            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + id + '&TransType=Adj';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Voucher&ReportTitle=Adj Voucher&TransID=' + id + '&TransType=Adj';
            }
            window.open(url, '_blank');
        }

        function PrintStockAdjustment() {
            var id = '<%= Request.QueryString["ID"]%>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            var reportPath = (user_name == 'As-Siraat Serving Humanity') ? '../../ReportViewer.aspx' : 'ReportViewer.aspx';

            var url = '/ReportViewer.aspx?ReportName=StockAdjustmentPrint&ReportTitle=Stock Adjustment&StockAdjustmentID=' + id ;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=StockAdjustmentPrint&ReportTitle=Stock Adjustment&StockAdjustmentID=' + id;
            }
            window.open(url, '_blank');
        }

        function calculatecurrentstock(item_id) {
            //$('#ctl00_MainContent_ddl_Ware_House').prop('disabled', true);
            var itemID = '';
            if (item_id > 0) {
                itemID = item_id;
                checkbatchitem(item_id);
            } else {
                itemID = $('#ctl00_MainContent_txtItem_Code').val();
            }
            var wareHouse = $('#ctl00_MainContent_ddl_Ware_House').val();
            if (itemID > 0 && wareHouse != "0") {
                PageMethods.calculateStock(itemID, wareHouse, function (res) {
                    $('#ctl00_MainContent_txtcurrentStock').val(res);
                });

                var itemId = $('#ctl00_MainContent_hdfItem_ID').val();
                if (itemId && itemId !== "" && itemId !== "0") {
                    LoadPurchaseRate(itemId, wareHouse);
                }
            }
        }



        function checkbatchitem(batchitem) {
            PageMethods.checkbatch(batchitem, function (res) {
                $('#ctl00_MainContent_hndcheckbatch').val(res);
            });
        }

        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#btnUnApprove').show();
                    } else {
                        $('#btnUnApprove').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve User UnApprove Button Rights.");
                }
            });
        }

        function showTooltip(input) {
            var tooltip = document.getElementById("tooltipQuantity");
            tooltip.style.display = "inline";
            var rect = input.getBoundingClientRect();
            tooltip.style.left = rect.left + "px";
            tooltip.style.top = (rect.bottom + window.scrollY + 5) + "px";
        }

        function hideTooltip() {
            document.getElementById("tooltipQuantity").style.display = "none";
        }

        function LoadBatches(item_id) {
            if (!item_id || item_id == "") return;
            EnableBothFields();

            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/Getbatch_grn",
                data: JSON.stringify({ item_id: item_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);

                    $('#ctl00_MainContent_ddlBatchNo').empty();
                    $('#ctl00_MainContent_ddlBatchNo').append('<option value="0">-- Select Batch --</option>');

                    if (result.GRN_Details && result.GRN_Details.length > 0) {
                        $.each(result.GRN_Details, function (i, batch) {
                            var displayText = batch.BatchNum;
                            if (batch.ReferenceNumber && batch.ReferenceNumber != "") {
                                displayText = batch.BatchNum + ' - ' + batch.ReferenceNumber;
                            }
                            $('#ctl00_MainContent_ddlBatchNo').append('<option value="' + batch.BatchNum + '">' + displayText + ' (GRN)</option>');
                        });
                    }

                    if (result.Stock_Adjustment_Details && result.Stock_Adjustment_Details.length > 0) {
                        $.each(result.Stock_Adjustment_Details, function (i, batch) {
                            var displayText = batch.BatchNum;
                            if (batch.ReferenceNumber && batch.ReferenceNumber != "") {
                                displayText = batch.BatchNum + ' - ' + batch.ReferenceNumber;
                            }
                            $('#ctl00_MainContent_ddlBatchNo').append('<option value="' + batch.BatchNum + '">' + displayText + ' (Adjustment)</option>');
                        });
                    }
                },
                error: function (error) {
                    console.log("Error loading batches: " + error);
                }
            });
        }

        function DisableDropdownOnTextInput() {
            var txtBatchNo = $('#ctl00_MainContent_txtBatchNo');
            var ddlBatchNo = $('#ctl00_MainContent_ddlBatchNo');
            var hdnBatch = $('#ctl00_MainContent_hdnSelectedBatchValue');

            if (txtBatchNo.val().trim() !== '') {
                ddlBatchNo.prop('disabled', true);
                ddlBatchNo.val('0');
                hdnBatch.val(txtBatchNo.val().trim());
            } else {
                ddlBatchNo.prop('disabled', false);
                hdnBatch.val('');
            }
        }

        function DisableTextOnDropdownChange() {
            var txtBatchNo = $('#ctl00_MainContent_txtBatchNo');
            var ddlBatchNo = $('#ctl00_MainContent_ddlBatchNo');
            var hdnBatch = $('#ctl00_MainContent_hdnSelectedBatchValue');

            if (ddlBatchNo.val() !== '0' && ddlBatchNo.val() !== null && ddlBatchNo.val() !== '') {
                txtBatchNo.prop('disabled', true);
                txtBatchNo.val('');
                hdnBatch.val(ddlBatchNo.val());

                txtBatchNo.removeClass('ErrorAlert');
                $('#ctl00_MainContent_hdbatch').val(0);
                $('#ctl00_MainContent_hdallowblank').val(0);
            } else {
                txtBatchNo.prop('disabled', false);
                if (txtBatchNo.val() === '') {
                    hdnBatch.val('');
                }
            }
        }

        function EnableBothFields() {
            $('#ctl00_MainContent_txtBatchNo').prop('disabled', false);
            $('#ctl00_MainContent_ddlBatchNo').prop('disabled', false).val('0');
        }

        function checkRemarksBeforeSave() {
            var remarksCode = '<%= ReamrksValidation() %>';
            var remarks = $('#ctl00_MainContent_txtRemarks').val();

            if (remarksCode === "01" && (!remarks || remarks.trim() === "")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter remarks.',
                    confirmButtonText: 'OK'
                });
                return false;
            }
            return true;
        }

        function AddItemToTable() {
            var itemId = $('#ctl00_MainContent_hdfItem_ID').val();
            var itemCode = $('#ctl00_MainContent_txtItem_Code').val();
            var itemName = $('#ctl00_MainContent_hdnDescription').val();
            var batchNo = $('#ctl00_MainContent_hdnSelectedBatchValue').val() || $('#ctl00_MainContent_txtBatchNo').val() || '';
            var expireDate = $('#ctl00_MainContent_txtExpiredate').val() || '';
            var qty = parseFloat($('#ctl00_MainContent_txtQuantity').val()) || 0;
            var rate = parseFloat($('#ctl00_MainContent_txtRate').val()) || 0;
            var amount = qty * rate;
            var warehouse = $('#ctl00_MainContent_ddl_Ware_House').val() || '';
            var warehouseText = $('#ctl00_MainContent_ddl_Ware_House option:selected').text() || '';

            if (!itemId || itemId === '0' || itemId === '') {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please select an item.', showConfirmButton: false, timer: 2000 });
                return false;
            }

         

            var rowObj = {
                ItemId: itemId,
                ItemCode: itemCode,
                ItemName: itemName,
                BatchNo: batchNo,
                ExpireDate: expireDate,
                Qty: qty,
                Rate: rate,
                Amount: amount,
                Warehouse: warehouse
            };

            gridItems.push(rowObj);
            var rowIndex = gridItems.length - 1;

            var newRow = '<tr id="row_' + rowIndex + '">' +
                '<td>' + itemCode + '</td>' +
                '<td>' + itemName + '</td>' +
                '<td>' + batchNo + '</td>' +
                '<td>' + expireDate + '</td>' +
                '<td>' + qty + '</td>' +
                '<td>' + rate + '</td>' +
                '<td>' + amount.toFixed(2) + '</td>' +
                '<td>' + warehouseText + '</td>' +
                '<td><a href="javascript:void(0);" onclick="RemoveRow(' + rowIndex + ')" style="color:red;">Remove</a></td>' +
                '</tr>';

            $('#tblStockItemsBody').append(newRow);

            // Clean input boxes
            $('#ctl00_MainContent_txtQuantity').val('');
            $('#ctl00_MainContent_txtRate').val('');
            $('#ctl00_MainContent_txtAmount').val('');
            $('#ctl00_MainContent_txtBatchNo').val('');
            $('#ctl00_MainContent_ddlBatchNo').val('0');
            $('#ctl00_MainContent_hdnSelectedBatchValue').val('');

            EnableBothFields();
            $('#ctl00_MainContent_hdnGridData').val(JSON.stringify(gridItems.filter(Boolean)));

            return false;
        }

        function RemoveRow(index) {
            gridItems[index] = null;
            $('#row_' + index).remove();
            $('#ctl00_MainContent_hdnGridData').val(JSON.stringify(gridItems.filter(Boolean)));
        }

        function GetMultipleBatchCondition() {
            $.ajax({
                type: "POST",
                url: "StockAdjustment.aspx/MultipleBatchValidation",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var batchCond = response.d;
                    if (batchCond == '01') {
                        $('#divAddButton').show();
                        $('#divGridContainer').show();
                    } else {
                        $('#divAddButton').hide();
                        $('#divGridContainer').hide();
                    }
                },
                error: function (error) {
                    console.error("Error fetching multiple batch condition", error);
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <asp:HiddenField runat="server" ID="hdnSelectedBatchValue" />
    
    <!-- CHANGED FROM FORM TO DIV to stop broken nested form submissions -->
    <div id="divStockItemForm">
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Transaction ID" runat="server" ID="lblAdjustment_ID" />
                <asp:TextBox runat="server" ID="txtAdjustment_ID" ReadOnly="true" Text="(New)" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Transaction Date" runat="server" ID="lblAdustment_date" />
                <asp:TextBox runat="server" ID="txtAdustment_date" />
                <asp:RequiredFieldValidator ID="rfvAdjustment_date" ErrorMessage="Date is required."
                    ControlToValidate="txtAdustment_date" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Status" runat="server" ID="lbl_Status" />
                <asp:TextBox runat="server" ID="txt_status" ReadOnly="true" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Batch No" runat="server" ID="Label2" />
                <asp:TextBox runat="server" ID="txtBatchNo" />
                <asp:RequiredFieldValidator ID="RequiredFieldValidator2" ErrorMessage="BatchNo is required."
                    ControlToValidate="txtBatchNo" runat="server" SetFocusOnError="true" Display="Dynamic" InitialValue="0" />
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label Text="Item Code & Description" runat="server" ID="lblItem_Code" />
                <asp:TextBox runat="server" ID="txtItem_Code" />
                <asp:RequiredFieldValidator ErrorMessage="Item Code is required." ID="rfvItemCode"
                    ControlToValidate="txtItem_Code" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Expire Date" runat="server" ID="Label1" />
                <asp:TextBox runat="server" ID="txtExpiredate" />
                <asp:RequiredFieldValidator ID="RequiredFieldValidator1" ErrorMessage="Date is required."
                    ControlToValidate="txtExpiredate" runat="server" SetFocusOnError="true"  Display="Dynamic" InitialValue="0" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Quantity" runat="server" ID="Label4" />
                <asp:TextBox runat="server" ID="txtQuantity" onchange="return onchange();" autocomplete="off" onfocus="showTooltip(this);" onblur="hideTooltip(this);" />
                <asp:RequiredFieldValidator ID="rfvQuantity" ErrorMessage="Quantity is required."
                    ControlToValidate="txtQuantity" runat="server" SetFocusOnError="true" Display="Dynamic" />
                <span id="tooltipQuantity" class="tooltip-style" style="display:none;">Enter quantity in loose.</span>
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Purchase Rate" runat="server" ID="lblRate" />
                <asp:TextBox runat="server" ID="txtRate" onchange="return onchange();"  />
                <asp:RequiredFieldValidator ID="rfvRate" ErrorMessage="Rate is required."
                    ControlToValidate="txtRate" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Amount" runat="server" ID="lblAmount" />
                <asp:TextBox runat="server" ID="txtAmount" ReadOnly="True" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4" id="divWarehouse">
                <asp:Label ID="Label3" runat="server" Text="WareHouse"></asp:Label>
                <asp:DropDownList runat="server" ID="ddl_Ware_House" AppendDataBoundItems="true" onchange="calculatecurrentstock()">
                </asp:DropDownList>
                <asp:RequiredFieldValidator ID="rfvddl_Ware_House" ErrorMessage="Ware House is required."
                    ControlToValidate="ddl_Ware_House" InitialValue="0" runat="server" SetFocusOnError="true" Display="Dynamic" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label ID="lb_currentStock" runat="server" Text="Current Stock"></asp:Label>
                <asp:TextBox runat="server" ID="txtcurrentStock" ReadOnly="True" />               
                <asp:HiddenField ID="hndcheckbatch" runat="server" />                 
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <label id="LblBranch">Branch</label>
                <select id="ddlBranch" name="ddlBranch" class="form-control" style="width: 100%; height: 35px;"></select>
                <asp:HiddenField runat="server" ID="hdnBranch_Id" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <asp:Label Text="Batch No" runat="server" ID="Label5" />
                <asp:DropDownList runat="server" ID="ddlBatchNo" Style="width: 100%; height: 35px;">
                    <asp:ListItem Text="-- Select Batch --" Value="0" />
                </asp:DropDownList>
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label ID="lbl_Reason_Needed" runat="server" Text="Reason Needed"></asp:Label>
                <asp:DropDownList runat="server" ID="ddlReasonNeeded" Style="height: 35px;" AppendDataBoundItems="true">
                </asp:DropDownList>
            </div>
            <div class="col-lg-4 col-md-3 col-sm-4">
                <asp:Label Text="Remarks" runat="server" ID="lblremarks" />
                <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Style="width: 100%; border-radius: 5px; height: 35px !important"></asp:TextBox>
            </div>
            <div class="col-lg-1 col-md-3 col-sm-4" id="divAddButton" style="display:none;">
                <label></label>
                <input type="button" class="btn btn-primry" value="Add" id="btnAddToTable" onclick="return AddItemToTable();" />
            </div>
        </div>
        
        <div class="row" style="margin-top:10px;display:none" id="divGridContainer">
            <div class="col-lg-12">
                <div class="table-responsive">
                    <table id="tblStockItems" class="table table-bordered table-striped"  style="width:100%;">
                        <thead>
                            <tr>
                                <th>Item Code</th>
                                <th>Description</th>
                                <th>Batch No</th>
                                <th>Expire Date</th>
                                <th>Qty</th>
                                <th>Rate</th>
                                <th>Amount</th>
                                <th>Warehouse</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody id="tblStockItemsBody">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <asp:HiddenField runat="server" ID="hdnGridData" />
        <div class="row">
            <div class="col-lg-0 col-md-3 col-sm-4">
                <input type="hidden" name="hdnDuplicateCheck" value="0" id="hdnDuplicateCheck" />            
                <asp:TextBox runat="server" ID="hdfItem_Code" Style="display: none" />
            </div>
        </div>
    </div>

    <asp:Panel runat="server" ID="pnlForm">
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-6">               
                        <input type="button" class="btn-gray" name="back" value="View" onclick="location.href = 'StockAdjustmentView.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <asp:Button Text="Save" Class="btn btn-primry" ID="btnSave" runat="server" OnClick="btnSave_Click" OnClientClick="return Validate();" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" value="New" id="btnNew" onclick="New()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-yellow" value="Print" id="btnStockAdjustmentPrint" onclick="PrintStockAdjustment();" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" style="display:none" class="btn btn-primry" value="Approve" id="btnApprove" onclick="ApproveSTOCKADJFromEdit()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-6">
                        <input type="button" style="display:none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                    </div>
                </div>
            </div>
        </div>
        <asp:Label ID="lblMessage" runat="server" />
    </asp:Panel>
    <asp:HiddenField runat="server" ID="hdbatch" />
    <asp:HiddenField runat="server" ID="hdDate" />
    <asp:HiddenField runat="server" ID="hdallowblank" />
    <asp:HiddenField runat="server" ID="hdnDescription" />
    <asp:HiddenField runat="server" ID="hdfItem_ID" />
</asp:Content>