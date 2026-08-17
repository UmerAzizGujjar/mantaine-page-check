<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseRequistion.aspx.cs" Inherits="PMS.AP.PurchaseRequistion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/PR.css" rel="stylesheet" />
       <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var counter = 1;
        var append_data = '';
        var isSaving = false;
        var isReplicate = false;
        var replicateEnabled = '<%= ReplicateCode %>' === '01';

        var id = '<% =Request.QueryString["ID"] %>';

        /* ─── Meta-bar sync helper ─── */
        function syncMetaBar() {
            var prNum  = $('#txtPr_Num').val()  || '—';
            var prDate = $('#txtPR_Date').val() || '—';
            var status = $('#txt_Status').val() || 'Draft';
            $('#prMetaDisplay').html(
                'PR&nbsp;#&nbsp;<strong>' + prNum + '</strong>' +
                '&nbsp;&nbsp;|&nbsp;&nbsp;Date:&nbsp;<strong>' + prDate + '</strong>' +
                '&nbsp;&nbsp;|&nbsp;&nbsp;Status:&nbsp;<strong>' + status + '</strong>'
            );
        }

        /* ─── Source-type toggle ─── */
        function initSourceToggle() {
            $('input[name="sourceType"]').on('change', function () {
                if ($(this).val() === 'item') {
                    $('#itemInputSection').show();
                    $('#girInputSection').hide();
                } else {
                    $('#itemInputSection').hide();
                    $('#girInputSection').show();
                }
            });
        }

        /* ─── Lock / unlock toggle based on table rows ─── */
        function checkToggleLock() {
            var rowCount = $('#tblbodyPackage tr').length;
            if (rowCount > 0) {
                // Lock: disable radios and dim the pill
                $('input[name="sourceType"]').prop('disabled', true);
                $('#sourceTogglePill').addClass('toggle-locked');
            } else {
                // Unlock: re-enable radios
                $('input[name="sourceType"]').prop('disabled', false);
                $('#sourceTogglePill').removeClass('toggle-locked');
            }
        }

        /* ─── Global AJAX error logger — shows which URL failed ─── */
        $(document).ajaxError(function (event, jqxhr, settings, thrownError) {
            console.warn('AJAX FAILED — URL:', settings.url, '| Status:', jqxhr.status, '| Error:', thrownError);
            console.warn('Response preview:', jqxhr.responseText.substring(0, 300));
        });

        $(document).ready(function () {
            GetWareHouseCondition();

            // ── Sanitize JSON from json.aspx endpoints before jQuery parses it.
            // Fixes "Bad escaped character" errors caused by raw backslashes in item names.
            // This converter intercepts ALL requests whose dataType includes 'json' and
            // whose URL targets json.aspx, cleaning the text before JSON.parse runs.
            $.ajaxSetup({
                converters: {
                    "text json": function (data) {
                        // Only sanitize json.aspx responses (token-input, select2 etc.)
                        var cleaned = data
                            .replace(/\\(?!["\\/bfnrtu])/g, '\\\\')   // lone backslash → \\
                            .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, function (ch) {
                                return '\\u' + ('0000' + ch.charCodeAt(0).toString(16)).slice(-4);
                            });
                        try {
                            return JSON.parse(cleaned);
                        } catch (e) {
                            return JSON.parse(data); // fallback: try original
                        }
                    }
                }
            });

            $("#CreatedByRow").hide();
            $("#girInfoGroup").hide();
           
                $('#txtItem').tokenInput(function () {
                    if (warehouseCond == '01') {
                        var warehouseVal = $('#ddlWarehouse').val();
                        if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {
                            // No warehouse selected — return dummy URL; onResult will intercept and return []
                            return "../../json.aspx?Table=INV_ItemsForPR&ReturnEmpty=1";
                        }
                        return "../../json.aspx?Table=INV_ItemsForPRwithWarehouse&WarehouseID=" + encodeURIComponent(warehouseVal);
                    } else {
                        return "../../json.aspx?Table=INV_ItemsForPR";
                    }
                }, {
                    tokenLimit: 1,
                    hintText: "Type to search items...",
                    noResultsText: "No items found.",
                    searchingText: "Searching...",
                    minChars: 1,
                    onResult: function (results) {
                        // If warehouse is required but not selected, force empty results
                        // and swap the noResultsText to the warehouse warning
                        if (warehouseCond == '01') {
                            var warehouseVal = $('#ddlWarehouse').val();
                            if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {
                                $('#txtItem').data('settings').noResultsText = '\u26a0 Please select a Warehouse first';
                                return [];
                            }
                        }
                        // Restore default for normal searches
                        $('#txtItem').data('settings').noResultsText = 'No items found.';
                        return results;
                    },
                    onAdd: function (item) {
                        $("#hditemID").val(item.id);
                        GetItemDetail();
                        $('#rdoItem').prop('checked', true).trigger('change');
                    }
                });
                $('#ddlWarehouse').change(function () {
                    if ($(this).val() !== "" && $(this).val() !== "0") {
                        $(this).prop('disabled', true);
                    }
                });
            
            FillPriority();
            FillWarehouse();
            UserRights();

            FillDepartments();
            $('#ddlWarehouse').select2();
            $('#ddldept').select2();
            $('#ddlPriority').select2();
            $('#ctl00_MainContent_ddlGIR').select2();

            initSourceToggle();

            if (id == '') {
                $('#btn_Print').hide();
                GetPRNum();
            }

            $('#btnGIR').on('click', function () {
                var Gir_id = $("#ctl00_MainContent_ddlGIR").val();
                LoadGIRNoDetail(Gir_id);
                $('#txtRemarks').focus();
            });

            $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
     
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtPR_Date").val(formattedDate);
            syncMetaBar();

            if (id != "") {
                LoadPurchaseRequistionMaster(id);
                LoadPurchaseRequistionDetail(id);
                $("#btnsave").val('Update');
                $("#CreatedByRow").css("display", "flex");
            }
            $('#btnReplicate').on('click', function () {
                isReplicate = true;
                SaveTest();
            });
            setTimeout(function () {
                var status = $('#txt_Status').val();
                if (status == "Approved") {
                    UserUnApproveButtonRights();
                    $('#btnsave').attr("disabled", 'disabled');
                    $('#btnReplicate').hide();
                }
                if (status == "Cancelled") {
                    $('#btnsave').attr("disabled", 'disabled');
                    $('#btnsave').hide();
                    $('#btnReplicate').hide();
                }
                if (status == "Created" || status == "Pending") {
                    if (replicateEnabled) $('#btnReplicate').show();
                    if (id != "") {
                        CheckApprovalRightsAndShowButton(id);
                    }
                }
            }, 1500);

            $('#btnGetAllItems').on('click', function () {
                // Guard: warehouse required and not selected
                if (warehouseCond == '01') {
                    var wh = $('#ddlWarehouse').val();
                    if (!wh || wh === '0' || wh === '') {
                        Swal.fire({ icon: 'warning', title: 'Select Warehouse', text: 'Please select a Warehouse before browsing items.', showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                        return;
                    }
                }
                LoadAllitem('');
            });

            function LoadAllitem(searchText) {
                debugger;
                var warehouse = $('#ddlWarehouse').val();
                // Guard: if warehouse is mandatory and not selected, block the browse
                if (warehouseCond == '01' && (!warehouse || warehouse === '0' || warehouse === '')) {
                    Swal.fire({ icon: 'warning', title: 'Select Warehouse', text: 'Please select a Warehouse before browsing items.', showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                    return;
                }
                $.ajax({
                    type: "POST",
                    url: "PurchaseRequistion.aspx/GetAllitem",
                    data: JSON.stringify({ searchText: searchText, warehouse: warehouse }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var items = JSON.parse(response.d);
                        var tableBody = $('#itemsTableBody');
                        tableBody.empty();
                        if (items.length === 0) {
                            tableBody.html('<tr><td colspan="5" class="text-center text-muted" style="padding:18px;">No items found.</td></tr>');
                        } else {
                            $.each(items, function (index, item) {
                                debugger;
                                var lastReqDateDisplay = '';
                                if (item.LastRequiredDate) {
                                    try {
                                        var dateObj = new Date(item.LastRequiredDate);
                                        if (!isNaN(dateObj.getTime())) {
                                            lastReqDateDisplay = $.datepicker.formatDate('dd M yy', dateObj);
                                        }
                                    } catch (e) {
                                        lastReqDateDisplay = '';
                                    }
                                }
                                var row = '<tr class="item-modal-row">' +
                                    '<td style="text-align:center;width:50px;"><button type="button" class="btn-item-pick" onclick="append(this)"><i class="fa fa-plus"></i></button></td>' +
                                    '<td style="display:none">' + item.Item_ID + '</td>' +
                                    '<td>' + item.Item_Code + '</td>' +
                                    '<td>' + item.Description + '</td>' +
                                    '<td>' + item.Unit + '</td>' +
                                    '<td style="text-align:right;">' + (item.UOM_Qty || '0') + '</td>' +
                                    '<td style="display:none">' + (item.Stock || '0') + '</td>' +
                                    '<td style="display:none">' + (item.LastQty || '') + '</td>' +
                                    '<td style="display:none">' + (item.LastRequiredDate || '') + '</td>' +
                                    '<td style="display:none">' + (item.Last_PurchaseRate || '') + '</td>' +
                                    '</tr>';
                                tableBody.append(row);
                            });
                        }
                        $('#itemsModal').modal('show');
                    },
                    error: function (error) {
                        console.error("Error fetching items", error);
                    }
                });
            }
            function renumberRows() {
                $('#tblbodyPackage tr').each(function (index) {
                    $(this).find('td:first').text(index + 1);
                });
            }
            $('#searchInput').on('keyup', function () {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });

            function LoadGIRNoDetail(Gir_id) {
                PageMethods.getGIRByID(Gir_id, function (data) {
                    var details = JSON.parse(data);
                    var tbody = $('#GIRItemTableBody');
                    tbody.empty();
                    if (details.length === 0) {
                        tbody.html('<tr><td colspan="8" class="text-center text-muted" style="padding:18px;">No GIR items found.</td></tr>');
                    } else {
                        $.each(details, function (index, detail) {
                            var row = $('<tr></tr>');
                            row.append($('<td style="text-align:center;"></td>').append(
                                $('<button type="button" class="btn-item-pick"></button>')
                                    .html('<i class="fa fa-plus"></i>')
                                    .on('click', function () {
                                        appendGIRROW($(this).closest('tr'));
                                        $('#rdoGIR').prop('checked', true).trigger('change');
                                        checkToggleLock();
                                        //$('#GIRModal').modal('hide');
                                    })
                            ));
                            row.append($('<td style="display:none;"></td>').text(detail.MaterialRequestDetail_Id));
                            row.append($('<td style="display:none;"></td>').text(detail.MaterialRequest_Id));
                            row.append($('<td></td>').text(detail.Req_Num));
                            row.append($('<td style="display:none;"></td>').text(detail.Item_Id));
                            row.append($('<td></td>').text(detail.Item_Code));
                            row.append($('<td></td>').text(detail.Description));
                            row.append($('<td></td>').text(detail.Unit));
                            row.append($('<td style="text-align:right;"></td>').text(detail.UOM_Qty || '0'));
                            row.append($('<td style="text-align:right;"></td>').text(detail.QTY));
                            row.append($('<td style="text-align:right;"></td>').text(detail.Rate));
                            tbody.append(row);
                        });
                    }

                    $('#GIRallItemsUpload').off('click').on('click', function () {
                        var allRows = $('#GIRItemTableBody tr');

                        if (allRows.length > 0) {
                            allRows.each(function (index, row) {
                                appendGIRROW($(row));
                            });
                            renumberRows();

                            $('#rdoGIR').prop('checked', true).trigger('change');
                            checkToggleLock();

                        }
                    });

                    $('#GIRModal').modal('show');

                });
            }

            

            $(document).on('change', '.select-row', function () {
                var row = $(this).closest('tr');
                if ($(this).is(':checked')) {
                    var newRow = row.clone();
                    newRow.find('input[type="checkbox"]').remove();
                    $('#tblbodyPackage tbody').append(newRow);
                } else {
                    var id = $(this).val();
                    $('#tblbodyPackage tbody tr').filter(function () {
                        return $(this).find('td:first').text() == id;
                    }).remove();
                }
            });

            
        });

        function appendGIRROW(anchor) {
            var row = $(anchor).closest('tr');
            var MaterialRequestDetail_Id = $(row).find('td:eq(1)').text();
            var MaterialRequest_Id = $(row).find('td:eq(2)').text();
            var Req_Num = $(row).find('td:eq(3)').text();
            var Item_ID = $(row).find('td:eq(4)').text();
            var Item_Code = $(row).find('td:eq(5)').text();
            var Item_name = $(row).find('td:eq(6)').text();
            var unit = $(row).find('td:eq(7)').text();
            var UOM_Qty = $(row).find('td:eq(8)').text() || '0';
            var Qty = $(row).find('td:eq(9)').text();
            var Rate = $(row).find('td:eq(10)').text();
            var stock = "0";
            var exists = false;
            $('#tblbodyPackage tr').each(function () {
                var existingItemCode = $(this).find('td:eq(1)').text();
                if (existingItemCode === Item_Code) { exists = true; return false; }
            });
            if (exists) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Item already Exists in the table.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                return;
            }
            var length = $("#tblPackage tr").length;
            length++;
            $("#tblbodyPackage").append(
                "<tr data-itemid='" + Item_ID + "'>" +
                "<td style='text-align:center;padding-top:7px!important;'>" + length + "</td>" +
                "<td style='text-align:left;padding-top:7px!important;padding-right:3px!important;'>" + Item_Code + "</td>" +
                "<td style='text-align:left;padding-left:8px!important;padding-top:7px!important;'>" + Item_name + "</td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + stock + "</td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + UOM_Qty + "</td>" +
                "<td style='text-align:right;'><input type='text' value='" + Qty + "' name='Qty' id='txtQty" + length + "' style='font-size:9px;width:58px!important;text-align:right;margin-top:2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td>" +
                "<td style='text-align:left;padding-top:7px!important;'>" + unit + "</td>" +
                "<td style='text-align:right;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' style='font-size:9px;width:68px!important;text-align:right;margin-top:2px;' autocomplete='off' value='" + Rate + "' onkeyup='calcutaeEstimCost(this)'/></td>" +
                "<td style='text-align:right;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size:9px;width:78px!important;text-align:right;margin-top:2px;' /></td>" +
                "<td style='text-align:left;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size:9px;width:80px!important;margin-top:2px;' autocomplete='off'/></td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + "</td>" +
                "<td style='text-align:left;padding-top:7px!important;'>" + "</td>" +
                "<td style='text-align:left;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size:9px;width:100%;margin-top:2px;'/></td>" +
                "<td style='display:none'>" + Item_ID + "</td>" +
                "<td style='text-align:center;'><a href='#' onclick='Delete(this)'><i class='fa fa-trash' style='font-size:13px;margin-top:5px;color:#f30a0a;'></i></a></td>" +
                "<td style='display:none'>" + MaterialRequestDetail_Id + "</td>" +
                "<td style='display:none'>" + MaterialRequest_Id + "</td>" +
                "<td style='display:none'>" + Req_Num + "</td>" +
                "</tr>"
            );
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            calcutaeCost(length);
            calcutaeQty();
            checkToggleLock();
        }

        function UserRights() {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) { $('#btnsave').show(); } else { $('#btnsave').hide(); }
                },
                failure: function (response) {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'd to retrieve user rights.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                }
            });
        }

        function append(anchor) {
            debugger;
            var row = $(anchor).closest('tr');
            var Item_ID   = $(row).find('td:eq(1)').text();
            var Item_Code = $(row).find('td:eq(2)').text();
            var Item_name = $(row).find('td:eq(3)').text();
            var unit      = $(row).find('td:eq(4)').text();
            var uomQty = $(row).find('td:eq(5)').text() || '0';
            var stock = $(row).find('td:eq(6)').text() || '0';
            var LastRate = $(row).find('td:eq(9)').text() || '0';
            var lastQty = $(row).find('td:eq(7)').text() || '';
            var lastReqDate = $(row).find('td:eq(8)').text() || '';
            console.log(lastReqDate);
            var exists = false;
            $('#tblbodyPackage tr').each(function () {
                var existingItemCode = $(this).find('td:eq(1)').text();
                if (existingItemCode === Item_Code) { exists = true; return false; }
            });
            if (exists) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Item already Exists in the table.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                return;
            }
            var length = $("#tblbodyPackage tr").length;
            length++;

            var formattedLastReqDate = '';
            if (lastReqDate && lastReqDate !== '' && lastReqDate !== 'null') {
                try {
                    var dateValue = lastReqDate;
                    var timestamp = null;

                    if (typeof dateValue === 'string' && dateValue.match(/\/Date\((\d+)\)\//)) {
                        var matches = dateValue.match(/\/Date\((\d+)\)\//);
                        if (matches && matches.length > 1) {
                            timestamp = parseInt(matches[1]);
                        }
                    }
                    else if (!isNaN(dateValue) && dateValue.toString().length > 10) {
                        timestamp = parseInt(dateValue);
                    }

                    if (timestamp !== null) {
                        var dateObj = new Date(timestamp);
                        if (!isNaN(dateObj.getTime())) {
                            formattedLastReqDate = $.datepicker.formatDate('dd M yy', dateObj);
                        }
                    } else {
                        var dateObj = new Date(dateValue);
                        if (!isNaN(dateObj.getTime())) {
                            formattedLastReqDate = $.datepicker.formatDate('dd M yy', dateObj);
                        }
                    }
                } catch (e) {
                    console.warn('Error parsing date:', lastReqDate, e);
                    formattedLastReqDate = '';
                }
            }

            console.log('Formatted Last Required Date:', formattedLastReqDate);
            $("#tblbodyPackage").append(
                "<tr data-itemid='" + Item_ID + "'>" +
                "<td style='text-align:center;padding-top:7px!important;'>" + length + "</td>" +
                "<td style='text-align:left;padding-top:7px!important;padding-right:3px!important;'>" + Item_Code + "</td>" +
                "<td style='text-align:left;padding-left:8px!important;padding-top:7px!important;'>" + Item_name + "</td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + stock + "</td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + uomQty + "</td>" +
                "<td style='text-align:right;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size:9px;width:58px!important;text-align:right;margin-top:2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td>" +
                "<td style='text-align:left;padding-top:7px!important;'>" + unit + "</td>" +
                "<td style='text-align:right;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' value='" + LastRate + "' style='font-size:9px;width:68px!important;text-align:right;margin-top:2px;' autocomplete='off' onkeyup='calcutaeEstimCost(this)'/></td>" +
                "<td style='text-align:right;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size:9px;width:78px!important;text-align:right;margin-top:2px;' /></td>" +
                "<td style='text-align:left;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size:9px;width:80px!important;margin-top:2px;' autocomplete='off'/></td>" +
                "<td style='text-align:right;padding-top:7px!important;'>" + lastQty + "</td>" +
                "<td style='text-align:left;padding-top:7px!important;'>" + formattedLastReqDate + "</td>" +
                "<td style='text-align:left;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size:9px;width:100%;margin-top:2px;'/></td>" +
                "<td style='display:none'>" + Item_ID + "</td>" +
                "<td style='text-align:center;'><a href='#' onclick='Delete(this)'><i class='fa fa-trash' style='font-size:13px;margin-top:5px;color:#f30a0a;'></i></a></td>" +
                "<td style='display:none'>0</td><td style='display:none'>0</td><td style='display:none'>0</td>" +
                "</tr>"
            );
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $('#rdoItem').prop('checked', true).trigger('change');
            //$('#itemsModal').modal('hide');
            checkToggleLock();
        }

        var savedPriority = null;
        var savedDept = null;
        var savedWarehouse = null;

        function FillDepartments() {
            PageMethods.filldepartments(function (Tests) {
                var optionDept = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionDept += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddldept').html(optionDept);
                if (savedDept) {
                    $('#ddldept').val(savedDept).trigger('change');
                }
            });
        }

        function FillPriority() {
            PageMethods.fillpriorities(function (Tests) {
                var optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlPriority').html(optionInv);
                if (savedPriority) {
                    $('#ddlPriority').val(savedPriority).trigger('change');
                }
            });
        }

        function FillWarehouse() {
            PageMethods.fillWarehouse(function (Tests) {
                var optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlWarehouse').html(optionInv);
                if (savedWarehouse) {
                    $('#ddlWarehouse').val(savedWarehouse).trigger('change');
                }
            });
        }

        function Delete(row) {
            $(row).closest('tr').remove();
            calcutaeQty();
            checkToggleLock();
        }

        function GetItemDetail() {
            debugger;
            var itemID = $("#hditemID").val();
            var PRDate = $("#txtPR_Date").val();
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/Getitem",
                data: JSON.stringify({ "ItemID": itemID, "PRDate": PRDate }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var length = $("#tblbodyPackage tr").length + 1;
                    var test_array = $('#tblPackage').find('input[name=txtItemID][value=' + itemID + ']');
                    if (test_array.length > 0) {
                        Swal.fire({ icon: 'error', title: 'Error!', text: 'This Item already added!', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                        return false;
                    }
                    if (parse[0].Active == true) {
                        var lastQty = (parse[0].LastQty != null && parse[0].LastQty !== '' && parse[0].LastQty !== 'null') ? parseFloat(parse[0].LastQty).toFixed(2) : '0';
                        var lastReqDate = '';
                        if (parse[0].LastRequiredDate != null && parse[0].LastRequiredDate !== '' && parse[0].LastRequiredDate !== 'null') {
                            try {
                                var dateVal = parse[0].LastRequiredDate;
                                if (typeof dateVal === 'string' && dateVal.indexOf('/Date(') !== -1) {
                                    lastReqDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(dateVal.substring(6, 19))));
                                } else {
                                    var d = new Date(dateVal);
                                    if (!isNaN(d.getTime())) {
                                        lastReqDate = $.datepicker.formatDate('dd M yy', d);
                                    }
                                }
                            } catch (e) { lastReqDate = ''; }
                        }
                        $("#tblbodyPackage").append(
                            "<tr>" +
                            "<td style='text-align:center;padding-top:7px!important;'>" + length + "</td>" +
                            "<td style='text-align:left;padding-top:7px!important;padding-right:3px!important;'>" + parse[0].Item_Code + "</td>" +
                            "<td style='text-align:left;padding-left:8px!important;padding-top:7px!important;'>" + parse[0].Description + "</td>" +
                            "<td style='text-align:right;padding-top:7px!important;'>" + parse[0].Stock + "</td>" +
                            "<td style='text-align:right;padding-top:7px!important;'>" + (parse[0].UOM_Qty || '0') + "</td>" +
                            "<td style='text-align:right;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size:9px;width:58px!important;text-align:right;margin-top:2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td>" +
                            "<td style='text-align:left;padding-top:7px!important;'>" + parse[0].Unit + "</td>" +
                            "<td style='text-align:right;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' value = '" + parse[0].Last_PurchaseRate + "' style='font-size:9px;width:68px!important;text-align:right;margin-top:2px;' autocomplete='off' onkeyup='calcutaeEstimCost(this)'/></td>" +
                            "<td style='text-align:right;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size:9px;width:78px!important;text-align:right;margin-top:2px;' /></td>" +
                            "<td style='text-align:left;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size:9px;width:80px!important;margin-top:2px;' autocomplete='off'/></td>" +
                            "<td style='text-align:right;padding-top:7px!important;'>" + lastQty + "</td>" +
                            "<td style='text-align:left;padding-top:7px!important;'>" + lastReqDate + "</td>" +
                            "<td style='text-align:left;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size:9px;width:100%;margin-top:2px;'/></td>" +
                            "<td style='display:none'><input type='hidden' name='txtItemID' value='" + parse[0].Item_ID + "'/>" + parse[0].Item_ID + "</td>" +
                            "<td style='text-align:center;'><a href='#' onclick='Delete(this)'><i class='fa fa-trash' style='font-size:13px;margin-top:5px;color:#f30a0a;'></i></a></td>" +
                            "<td style='display:none'>0</td><td style='display:none'>0</td><td style='display:none'>0</td>" +
                            "</tr>"
                        );
                        var currentDate = new Date();
                        var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
                        $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
                        $('#txtItem').val('');
                        $("#txtItem").tokenInput("clear");
                        checkToggleLock();
                    } else {
                        swal("You have selected InActive items");
                        $("#txtItem").tokenInput("clear");
                    }
                },
                failure: function (response) {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'In failure method', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                }
            });
        }

        function GetPRNum() {
            $.ajax({
                type: "post",
                url: "PurchaseRequistion.aspx/GetPR",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    $("#txtPr_Num").val(response.d);
                    syncMetaBar();
                },
                failure: function (response) { alert("In failure method"); }
            });
        }

        var warehouseCond;
        function GetWareHouseCondition() {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') { $('#warehouse').show(); }
                    else { $('#warehouse').hide(); }
                },
                error: function (error) { console.error("Error fetching items", error); }
            });
        }

        function SaveTest() {
            debugger;
            if (isSaving) return false;
            isSaving = true;
            $("#btnsave").prop("disabled", true);
            var qtyOrAmtChck = false;
            var datecheck = '';
            var PRId = 0;
            if (!isReplicate && id != "") {
                PRId = id;
            }
            var PrNum    = $('#txtPr_Num').val();
            var PrDate   = $('#txtPR_Date').val();
            var Pirority = $("#ddlPriority").val();
            var Warehouse = $("#ddlWarehouse").val();
            var RefNum   = $('#txtRef_Num').val();
            var remarks  = $('#txtRemarks').val();
            var btnValue = isReplicate ? "Replicate" : $("#btnsave").val();
            isReplicate = false;
            var totCost  = $("#totCost").val() || 0;
            var dept     = $('#ddldept').val();

            if (warehouseCond == "01" && Warehouse == '0') {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Select Warehouse', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                return false;
            }
            if (Pirority == '0') {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Select Priority', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                isSaving = false; $("#btnsave").prop("disabled", false);
                $('#ddlPriority').select2().focus(); $('#ddlPriority').select2('open');
                return false;
            }
            if (dept == '0') {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Select Department', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                isSaving = false; $("#btnsave").prop("disabled", false);
                $('#ddldept').select2().focus(); $('#ddldept').select2('open');
                return false;
            }
            var tblLength = $("#tblPackage tr:gt(0)").length;
            if (tblLength == '0') {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Add Items', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                $('#tblPackage').addClass('ErrorAlert');
                isSaving = false; $("#btnsave").prop("disabled", false);
                return false;
            } else { $('#tblPackage').removeClass('ErrorAlert'); }

            if (!$('#txtPr_Num').hasClass('ErrorAlert') && !$('#txtPR_Date').hasClass('ErrorAlert') && !$('#ddldept').hasClass('ErrorAlert') && !$('#ddlPriority').hasClass('ErrorAlert') && !$('#tblPackage').hasClass('ErrorAlert')) {
                $.each($("#tblPackage").find('tbody').find('tr'), function (index) {
                    var RequiredDate = new Date($(this).find('input[name=txtrdate]').val()).setHours(0, 0, 0, 0);
                    var PRDate = new Date($('#txtPR_Date').val()).setHours(0, 0, 0, 0);
                    var RDate = $(this).find('input[name=txtrdate]').val();
                    var Qty = $(this).find('td:eq(5) input').val();
                    datecheck = (PRDate > RequiredDate) ? false : true;
                    if (RDate == "") {
                        Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Enter Required Date', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                        isSaving = false; $("#btnsave").prop("disabled", false); qtyOrAmtChck = true; return false;
                    }
                    if (Qty == "" || Qty == "0" || Qty === 0 || Qty < 0) {
                        Swal.fire({ icon: 'error', title: 'Error!', text: 'Please Enter Qty Or Qty Must be Greater than zero', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                        qtyOrAmtChck = true; isSaving = false; $("#btnsave").prop("disabled", false); return false;
                    }
                });
                if (parseFloat(totCost) > 50000 && Pirority === '004') {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'For Low Priority Total Amount Must be Less then 50000', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                    isSaving = false; $("#btnsave").prop("disabled", false); return false;
                }
                if (datecheck == false) {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Required Date must be greater than Purchase Date', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                    isSaving = false; $("#btnsave").prop("disabled", false); return false;
                } else if (qtyOrAmtChck == true) {
                    isSaving = false; $("#btnsave").prop("disabled", false); return false;
                } else {
                    $.ajax({
                        type: "post",
                        url: "PurchaseRequistion.aspx/SavePurchaseRequistion",
                        data: JSON.stringify({ "PRid": PRId, "PrNum": PrNum, "PrDate": PrDate, "Pirority": Pirority, "Warehouse": Warehouse, "dept": dept, "RefNum": RefNum, "remarks": remarks, "btnValue": btnValue }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var res = response.d;
                            var arr = res.split('-');
                            var msg = arr[0];
                            var id = arr[1];
                            sendFile(id, function () {
                                SaveDetailPurchaseRequestion(id, btnValue);
                            });
                        },
                        failure: function (response) { isSaving = false; alert("In failure method"); }
                    });
                }
            }
        }

        function SaveDetailPurchaseRequestion(id, btnValue) {
            debugger;
            var detailAry = [];
            $.each($("#tblPackage").find('tbody').find('tr'), function (index, row) {
                var Qty = $(row).find('td:eq(5) input').val();
                var UnitPrice = $(row).find('td:eq(7) input').val();
                var EstimateCost = $(row).find('td:eq(8) input').val();
                var RDate = $(row).find('input[name=txtrdate]').val();
                var Remarks = $(row).find('td:eq(12) input').val();
                var itemId = $(row).find('td:eq(13)').text();
                var MaterialRequestDetail_Id = $(row).find('td:eq(15)').text();
                var MaterialRequest_Id = $(row).find('td:eq(16)').text();
                var Req_Num = $(row).find('td:eq(17)').text();
                var Last_PR_Qty = $(row).find('td:eq(10)').text() || '0';
                var Last_PR_Date = $(row).find('td:eq(11)').text() || '';
                if (Qty && RDate && itemId) {
                    detailAry.push({ Qty: Qty, UnitPrice: UnitPrice, EstimateCost: EstimateCost, RDate: RDate, Remarks: Remarks, PRId: id, itemId: itemId, MaterialRequestDetail_Id: MaterialRequestDetail_Id, MaterialRequest_Id: MaterialRequest_Id, Req_Num: Req_Num, Last_PR_Qty: Last_PR_Qty, Last_PR_Date: Last_PR_Date });
                }
            });
            if (detailAry.length === 0) {
                Swal.fire({ icon: 'error', title: 'Error!', text: 'No Valid Rows to Save.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                isSaving = false; $("#btnsave").prop("disabled", false); return false;
            }
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/SavePurchaseRequistionDetails",
                data: JSON.stringify({ "PRid": id, "btnValue": btnValue, 'PurchaseRequistionDetails': detailAry }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var res = response.d;
                    if (res.startsWith("Success")) {
                        var msg = (btnValue == "Replicate") ? 'Data Replicated Successfully' : (btnValue == "Save") ? 'Data Inserted Successfully' : 'Data Updated Successfully';
                        Swal.fire({ icon: 'success', title: 'Success!', text: msg, showConfirmButton: false, timer: 2500, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                        window.location = 'PurchaseRequistion.aspx?ID=' + id;
                        $("#btnsave").prop("disabled", true);
                    } else {
                        isSaving = false;
                        alert("Error In Purchase Requisition details: " + res);
                    }
                },
                failure: function (response) { isSaving = false; alert("In failure method"); }
            });
        }

        function LoadPurchaseRequistionMaster(id) {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/LoadPurchaseRequistion",
                data: JSON.stringify({ "ID": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    $('#txtPr_Num').val(parse.PR_Num);
                    $('#txt_Status').val(parse.Status);


                    
                    $('#txtRef_Num').val(parse.Ref_Num);
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse.PR_Date.substring(6, 19))));
                    $('#txtPR_Date').val(datetime);
                    syncMetaBar();

                    $('#lblCreatedBy').text(parse.Created_By || '-');
                    $('#lblUpatedBy').text(parse.UpdatedBy || '-');
                    $('#lblCreatedTime').text(moment(parseInt(parse.Creation_Date.substring(6, 19))).format('DD-MMM-YYYY h:mm A'));
                    if (parse.Update_Date == null || parse.Update_Date == undefined) {
                        $('#lblUpatedTime').text('-');
                    } else {
                        $('#lblUpatedTime').text(moment(parseInt(parse.Update_Date.substring(6, 19))).format('DD-MMM-YYYY h:mm A'));
                    }
                    if (parse.Status == "Approved") {
                        debugger;
                        $('#btnsave').attr("disabled", 'disabled');
                    } 
                    // Save values globally for async dropdown loaders to pick up
                    savedPriority = parse.Priority;
                    savedDept = parse.Department;
                    savedWarehouse = parse.Warehouse;

                    // Fallback: also try setting them right away in case dropdowns loaded fast
                    if ($('#ddlPriority option[value="' + savedPriority + '"]').length) {
                        $('#ddlPriority').val(savedPriority).trigger('change');
                    }
                    if ($('#ddldept option[value="' + savedDept + '"]').length) {
                        $('#ddldept').val(savedDept).trigger('change');
                    }
                    if ($('#ddlWarehouse option[value="' + savedWarehouse + '"]').length) {
                        $('#ddlWarehouse').val(savedWarehouse).trigger('change');
                    }

                    $('#txtRemarks').val(parse.Remarks);
                    debugger;
                    if (parse.GIRNum && parse.GIRNum !== 0 && parse.GIRNum !== "0") {
                        $('#lblGIRNum').text(parse.GIRNum);
                        $('#lblGirCreatedBy').text(parse.GIRCreatedBy || '-');
                        $('#lblGirApprovedBy').text(parse.GIRApprovedBy || '-');
                        $('#girInfoGroup').show();
                        
                        // Auto-select GIR radio and trigger
                        setTimeout(function() {
                            $('#rdoGIR').prop('checked', true).trigger('change');
                            checkToggleLock();
                        }, 500);
                    } else {
                        $('#girInfoGroup').hide();
                    }
                },
                failure: function (response) { alert("In failure method"); }
            });
        }

        function LoadPurchaseRequistionDetail(id) {
            var counter = 1;
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/LoadPurchaseRequistionDetail",
                data: JSON.stringify({ "ID": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var row = '';
                    $.each(parse, function (key, value) {
                        var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse[key].RDate.substring(6, 19))));
                        var len = key + 1;
                        var uom = parse[key].UOM;
                        if (uom == null || uom == 'NULL' || uom == 'null') { uom = ""; }

                        var lastReqDateDisplay = '';
                        if (parse[key].Last_PR_Date) {
                            try {
                                var dateVal = parse[key].Last_PR_Date;
                                if (typeof dateVal === 'string' && dateVal.indexOf('/Date(') !== -1) {
                                    var lastDateObj = new Date(parseInt(dateVal.substring(6, 19)));
                                    lastReqDateDisplay = $.datepicker.formatDate('dd M yy', lastDateObj);
                                } else {
                                    var d = new Date(dateVal);
                                    if (!isNaN(d.getTime())) {
                                        lastReqDateDisplay = $.datepicker.formatDate('dd M yy', d);
                                    } else {
                                        lastReqDateDisplay = dateVal;
                                    }
                                }
                            } catch (e) {
                                lastReqDateDisplay = '';
                            }
                        }

                        row +=
                            '<tr>' +
                            '<td style="text-align:center;padding-top:7px!important;">' + len + '</td>' +
                            '<td style="text-align:left;padding-top:7px!important;padding-right:3px!important;">' + parse[key].itemCode + '</td>' +
                            '<td style="text-align:left;padding-left:8px!important;padding-top:7px!important;">' + parse[key].Description + '</td>' +
                            '<td style="text-align:right;padding-top:7px!important;">' + parse[key].stock + '</td>' +
                            '<td style="text-align:right;padding-top:7px!important;">' + (parse[key].UOM_Qty || '0') + '</td>' +
                            '<td style="text-align:right;"><input type="text" value="' + parseFloat(parse[key].Qty).toFixed(2) + '" name="Qty" id="txtQty' + counter + '" style="font-size:9px;width:58px!important;text-align:right;margin-top:2px;" autocomplete="off" onkeyup="calcutaeQty();calcutaeEstimatedCost(this)"/></td>' +
                            '<td style="text-align:left;padding-top:7px!important;">' + uom + '</td>' +
                            '<td style="text-align:right;"><input type="text" value="' + parseFloat(parse[key].UnitPrice).toFixed(2) + '" name="txtUnitPrice" id="txtUnitPrice' + counter + '" style="font-size:9px;width:68px!important;text-align:right;margin-top:2px;" autocomplete="off" onkeyup="calcutaeEstimCost(this)"/></td>' +
                            '<td style="text-align:right;"><input readonly type="text" value="' + parseFloat(parse[key].EstimateCost).toFixed(2) + '" name="txtEstimCost" id="txtEstimCost' + counter + '" style="font-size:9px;width:78px!important;text-align:right;margin-top:2px;" autocomplete="off"/></td>' +
                            '<td style="text-align:left;"><input type="text" name="txtrdate" id="txtrdate' + counter + '" style="font-size:9px;width:80px!important;margin-top:2px;" value="' + datetime + '"/></td>' +
                            '<td style="text-align:right;padding-top:7px!important;">' + (parse[key].Last_PR_Qty || 0) + '</td>' +
                            '<td style="text-align:left;padding-top:7px!important;">' + lastReqDateDisplay + '</td>' +
                            '<td style="text-align:left;"><input type="text" name="remarks" id="remarks' + counter + '" style="font-size:9px;width:100%;margin-top:2px;" value="' + parse[key].Remarks + '"/></td>' +
                            '<td style="display:none">' + parse[key].itemId + '</td>' +
                            '<td style="text-align:center;"><a href="#" onclick="Delete(this)"><i class="fa fa-trash" style="font-size:13px;margin-top:5px;color:#f30a0a;"></i></a></td>' +
                            '<td style="display:none">' + parse[key].MaterialRequestDetail_Id + '</td>' +
                            '<td style="display:none">' + parse[key].MaterialRequest_Id + '</td>' +
                            '<td style="display:none">' + parse[key].Req_Num + '</td>' +
                            '</tr>';
                        counter++;
                    });
                    $("#tblbodyPackage").append(row);
                    $('input[name="txtrdate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                    calcutaeQty();
                    checkToggleLock();
                },
                failure: function (response) { alert("In failure method"); }
            });
        }

        function calcutaeQty() {
            var TotalQty = 0, totalEsitamt = 0;
            $.each($('#tblPackage tbody tr'), function (key, value) {
                var Qty = $($(value).find('td input[name=Qty]')[0]).val() || 0;
                var unitPr = $($(value).find('td input[name=txtUnitPrice]')[0]).val() || 0;
                TotalQty += parseFloat(Qty);
                totalEsitamt += parseFloat(Qty * unitPr);
            });
            $('#totQty').val(parseFloat(TotalQty).toFixed(2));
            $('#totCost').val(parseFloat(totalEsitamt).toFixed(2));
        }

        function calcutaeEstimCost(input) {
            var selectId = $(input).attr('id');
            var idParts = selectId.match(/([a-zA-Z]+)(\d+)/);
            var totcost = 0;
            if (idParts && idParts.length === 3) {
                var counter = idParts[2];
                var Qty = parseFloat($('#txtQty' + counter).val()) || 0;
                var unitprice = parseFloat($(input).val()) || 0;
                $('#txtEstimCost' + counter).val((Qty * unitprice).toFixed(2));
                $.each($('#tblPackage tbody tr'), function (key, value) {
                    totcost += parseFloat($($(value).find('td input[name=txtEstimCost]')[0]).val() || 0);
                });
                $('#totCost').val(parseFloat(totcost).toFixed(2));
            }
        }

        function calcutaeEstimatedCost(input) {
            var selectId = $(input).attr('id');
            var idParts = selectId.match(/([a-zA-Z]+)(\d+)/);
            if (idParts && idParts.length === 3) {
                var counter = idParts[2];
                var Qty = parseFloat($(input).val()) || 0;
                var unitprice = parseFloat($('#txtUnitPrice' + counter).val()) || 0;
                $('#txtEstimCost' + counter).val((Qty * unitprice).toFixed(2));
            }
        }

        function calcutaeCost(rowIndex) {
            var Qty = parseFloat($('#txtQty' + rowIndex).val()) || 0;
            var unitprice = parseFloat($('#txtUnitPrice' + rowIndex).val()) || 0;
            $('#txtEstimCost' + rowIndex).val((Qty * unitprice).toFixed(2));
        }

        function PrintPurchaseRequisitionDetail() {
            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            var reportPath = (user_name == 'As-Siraat Serving Humanity') ? '../../ReportViewer.aspx' : 'ReportViewer.aspx';
            var url = '/ReportViewer.aspx?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition&PRid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                url = 'http://' + urlInfo[2] + '/' + urlInfo[3] + '/' + reportPath + '?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition&PRid=' + id;
            }
            window.open(url, '_blank');
        }

        function sendFile(ID, callback) {
            var fileInput = $('#chosePrfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', fileInput.files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadPRFiles.ashx',
                    data: data,
                    success: function (status) {
                        if (typeof callback === 'function') callback();
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert(" something went wrong!");
                    }
                });
            } else {
                if (typeof callback === 'function') callback();
            }
        }

        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) { $('#btnUnApprove').show(); } else { $('#btnUnApprove').hide(); }
                },
                failure: function (response) {
                    Swal.fire({ icon: 'error', title: 'Error!', text: 'Failed to retrieve User UnApprove Button Rights', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } });
                }
            });
        }

        function UnApprovePR() {
            var PRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.UnApprovePR(PRId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload(true);
                }
            });
        }

        function CheckApprovalRightsAndShowButton(prId) {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/CheckApprovalRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d) {
                        $.ajax({
                            type: "POST",
                            url: "PurchaseRequistion.aspx/GetApprovalInfo",
                            data: JSON.stringify({ PRId: prId }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function (resp) {
                                var info = JSON.parse(resp.d);
                                if (info.CanApprove) {
                                    $('#btnApprove').show();
                                    $('#btnApprove').data('pr-amount', info.PRAmount);
                                    $('#btnApprove').data('remaining-amount', info.RemainingAmount);
                                    $('#btnApprove').data('budget-enabled', info.BudgetEnabled);
                                }
                            }
                        });
                    }
                }
            });
        }

        function ApprovePRFromEdit() {
            var prId = id;
            var prAmount = $('#btnApprove').data('pr-amount');
            var remainingAmount = $('#btnApprove').data('remaining-amount');
            var budgetEnabled = $('#btnApprove').data('budget-enabled');

            var confirmHtml = 'Are you sure you want to approve PR #' + $('#txtPr_Num').val() + '?';
            if (budgetEnabled) {
                confirmHtml += '<br><br>PR Amount: <strong>' + parseFloat(prAmount).toFixed(2) + '</strong>';
                confirmHtml += '<br>Remaining Budget: <strong>' + parseFloat(remainingAmount).toFixed(2) + '</strong>';
            }

            Swal.fire({
                title: 'Approve PR?',
                html: confirmHtml,
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, Approve',
                cancelButtonText: 'Cancel',
                input: 'textarea',
                inputPlaceholder: 'Approval remarks (optional)...',
                inputAttributes: { 'aria-label': 'Approval remarks' },
                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
            }).then((result) => {
                if (result.isConfirmed) {
                    var remarks = result.value || '';
                    $.ajax({
                        type: "POST",
                        url: "PurchaseRequistion.aspx/ApproveSinglePR",
                        data: JSON.stringify({ PRId: prId, approvalRemarks: remarks }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            if (response.d === "Success") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Approved!',
                                    text: 'PR has been approved successfully.',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                                }).then(function () {
                                    location.reload();
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error',
                                    text: response.d,
                                    showConfirmButton: true,
                                    customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                                }).then(function () {
                                    location.reload();
                                });
                            }
                        },
                        error: function () {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error',
                                text: 'Something went wrong during approval.',
                                showConfirmButton: true,
                                customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' }
                            }).then(function () {
                                location.reload();
                            });
                        }
                    });
                }
            });
        }

    </script>

    <!-- Hidden inputs — JS still reads/writes these for all data ops -->
    <input type="hidden" id="txtPr_Num"  name="txtPr_Num"  />
    <input type="hidden" id="txtPR_Date" name="txtPR_Date" />
    <input type="hidden" id="txt_Status" name="txt_Status" />
    <input type="hidden" id="hditemID" />

    <!-- ══════════════════════════════════════════════════════════
         SYSTEM META-DATA BAR  (top-right, read-only badge strip)
    ════════════════════════════════════════════════════════════ -->
    <div class="pr-meta-bar">
        <span id="prMetaDisplay" class="pr-meta-text">
            PR&nbsp;#&nbsp;<strong>—</strong>&nbsp;&nbsp;|&nbsp;&nbsp;Date:&nbsp;<strong>—</strong>&nbsp;&nbsp;|&nbsp;&nbsp;Status:&nbsp;<strong>Draft</strong>
        </span>
    </div>

    <form id="item">

        <!-- ══════════════════════════════════════════════════════
             ROW 1: Warehouse | Department | Priority | Ref # | Remarks
        ════════════════════════════════════════════════════════ -->
        <div class="row pr-primary-settings">
            <div id="warehouse" class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                <label id="LblWarehouse">WareHouse <span class="req-star">*</span></label>
                <select id="ddlWarehouse" class="form-select">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                <label id="Lbldepartment">Department <span class="req-star">*</span></label>
                <select id="ddldept" class="form-select"></select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                <label id="LblPriority">Priority <span class="req-star">*</span></label>
                <select id="ddlPriority" class="form-select">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                <label id="LblRef_Num">Ref #</label>
                <input type="text" class="form-control" id="txtRef_Num" name="txtRef_Num" placeholder="Reference no." autocomplete="off" />
            </div>
            <div class="col-lg-4 col-md-8 col-sm-12 col-xs-12">
                <label id="lblrem">Remarks</label>
                <input id="txtRemarks" type="text" class="form-control" placeholder="Enter any remarks..." />
            </div>
        </div>

        <!-- ══════════════════════════════════════════════════════
             ROW 2: Source toggle + selector (left) | Attachment (right)
        ════════════════════════════════════════════════════════ -->
        <div class="pr-source-attach-row">

            <!-- LEFT: toggle pill + item/GIR selector -->
            <div class="pr-source-left">

                <!-- Radio toggle pill -->
                <div class="source-toggle-pill" id="sourceTogglePill">
                    <label class="source-radio-option">
                        <input type="radio" name="sourceType" id="rdoItem" value="item" checked="checked" />
                        <span class="source-pill-label">Item</span>
                    </label>
                    <label class="source-radio-option">
                        <input type="radio" name="sourceType" id="rdoGIR" value="gir" />
                        <span class="source-pill-label">GIR</span>
                    </label>
                </div>

                <!-- Item selector (shown by default) -->
                <div class="source-input-wrap" id="itemInputSection">
                    <div class="source-inline-group">
                        <input type="text" class="form-control source-select-input" id="txtItem" name="txtItem" placeholder="Search and select item..." />
                        <span class="btn-item source-action-btn" id="btnGetAllItems">
                            <i class="fa fa-th-list"></i> Browse
                        </span>
                    </div>
                </div>

                <!-- GIR selector (hidden by default) -->
                <div class="source-input-wrap" id="girInputSection" style="display:none;">
                    <div class="source-inline-group">
                        <asp:DropDownList runat="server" ID="ddlGIR" class="form-select source-gir-select"></asp:DropDownList>
                        <span class="btn-item source-action-btn" id="btnGIR">
                            <i class="fa fa-plus"></i> Add GIR
                        </span>
                    </div>
                </div>

            </div>

            <!-- RIGHT: fancy attachment card -->
            <div class="pr-attachment-card">
                <div class="pr-attachment-icon">
                    <i class="fa fa-paperclip"></i>
                </div>
                <div class="pr-attachment-body">
                    <span class="pr-attachment-label">Attachment</span>
                    <input type="file" id="chosePrfile" name="chosePrfile" class="pr-file-input" />
                </div>
                <div class="pr-attachment-download">
                    <asp:HyperLink ID="HyperLink1" runat="server" CssClass="pr-download-btn">
                        <i class="fa fa-download"></i> Download
                    </asp:HyperLink>
                </div>
            </div>

        </div>

        <!-- ----------------------------------------------------------
         AUDIT BAR (Edit Mode only)
    ------------------------------------------------------------ -->
    <div class="pr-audit-bar" id="CreatedByRow" style="display:none;">
        <div class="pr-audit-group">
            <div class="pr-audit-chip" title="Created By">
                <i class="fa fa-user-plus" style="color:#aaa;"></i> <span id="lblCreatedBy" class="pr-audit-chip-value">-</span>
            </div>
            <div class="pr-audit-chip" title="Created Date">
                <i class="fa fa-calendar-plus-o" style="color:#aaa;"></i> <span id="lblCreatedTime" class="pr-audit-chip-value">-</span>
            </div>
            <div class="pr-audit-chip" title="Updated By">
                <i class="fa fa-edit" style="color:#aaa;"></i> <span id="lblUpatedBy" class="pr-audit-chip-value">-</span>
            </div>
            <div class="pr-audit-chip" title="Updated Date">
                <i class="fa fa-calendar-check-o" style="color:#aaa;"></i> <span id="lblUpatedTime" class="pr-audit-chip-value">-</span>
            </div>
        </div>
        
        <div class="pr-gir-card" id="girInfoGroup" style="display:none;">
            <div class="pr-gir-card-left">
                <i class="fa fa-link"></i> GIR <span id="lblGIRNum">-</span>
            </div>
            <div class="pr-gir-card-right">
                <div class="pr-gir-stat" title="GIR Prepared By">
                    <i class="fa fa-user-circle"></i> <span id="lblGirCreatedBy">-</span>
                </div>
                <div class="pr-gir-stat" title="GIR Approved By">
                    <i class="fa fa-check-circle"></i> <span id="lblGirApprovedBy">-</span>
                </div>
            </div>
        </div>
    </div>

    </form>

    <!-- ══════════════════════════════════════════════════════════
         ITEMS TABLE
    ════════════════════════════════════════════════════════════ -->
    <div id="ITEMTable" style="overflow-x:auto; overflow-y:auto; max-height:310px; margin-top:14px; margin-bottom:0; border:1px solid #dee2e6; border-radius:4px 4px 0 0;">
        <table class="table table-bordered table-striped" id="tblPackage" style="font-size:10px !important; width:100%; min-width:860px; margin-bottom:0;">
            <thead>
                <tr>
                    <th style="width:4%;  text-align:center;">Sr No.</th>
                    <th style="width:8%;  text-align:left;">Item Code</th>
                    <th style="width:20%; text-align:left;">Description</th>
                    <th style="width:7%;  text-align:right;">Stock</th>
                    <th style="width:6%;  text-align:right;">UOM Qty</th>
                    <th style="width:6%;  text-align:right;">Qty</th>
                    <th style="width:5%;  text-align:left;">MOU</th>
                    <th style="width:9%;  text-align:right;">Unit Price</th>
                    <th style="width:10%; text-align:right;">Estimated Cost</th>
                    <th style="width:10%; text-align:left;">Required Date</th>
                    <th style="width:6%;  text-align:right;">Last Qty</th>   
                    <th style="width:10%; text-align:left;">Last PR Date</th>
                    <th style="width:15%; text-align:left;">Remarks</th>
                    <th style="width:6%;  text-align:center;">Action</th>
                    <th style="display:none;">MaterialRequestDetail Id</th>
                    <th style="display:none;">MaterialRequest Id</th>
                    <th style="display:none;">Req Num</th>
                </tr>
            </thead>
            <tbody id="tblbodyPackage"></tbody>
        </table>
    </div>

    <!-- ══════════════════════════════════════════════════════════
         TOTALS BAR  (outside table, below the scrollable area)
    ════════════════════════════════════════════════════════════ -->
    <div class="pr-totals-bar">
        <span class="pr-totals-bar-label">Totals</span>
        <div class="pr-totals-bar-fields">
            <div class="pr-totals-bar-item">
                <label>Total Qty</label>
                <input type="text" id="totQty" name="totQty" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Total Cost</label>
                <input type="text" id="totCost" name="totCost" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
        </div>
    </div>

    <!-- ══════════════════════════════════════════════════════════
         ACTION BUTTONS
    ════════════════════════════════════════════════════════════ -->
    <div class="row pr-action-buttons">
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" value="Save" id="btnsave" onclick="SaveTest()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" value="Replicate" id="btnReplicate" style="display:none;" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-gray" value="List" onclick="window.location = 'PurchaseRequistionView.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'PurchaseRequistion.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" value="Print" class="btn-primry" id="btn_Print" onclick="PrintPurchaseRequisitionDetail();" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-primry" value="Approve" style="display:none;" id="btnApprove" onclick="ApprovePRFromEdit()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-primry" value="Unnaprove" style="display:none;" id="btnUnApprove" onclick="UnApprovePR()" />
        </div>
    </div>

    <!-- ══════════════════════════════════════════════════════════
         MODAL: Browse Items
    ════════════════════════════════════════════════════════════ -->
    <div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel">
        <div class="modal-dialog modal-lg custom-modal-dialog">
            <div class="modal-content custom-modal-content">
                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                        <h4 class="modal-title custom-modal-title" id="itemsModalLabel">Browse Items</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
                <div class="modal-body custom-modal-body">
                    <div class="custom-modal-search-wrap">
                        <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                        <input type="text" id="searchInput" class="custom-modal-search" placeholder="Search by code or description..." />
                    </div>
                    <div class="custom-modal-table-wrap">
                        <table class="table custom-modal-table" id="itemsTable">
                            <thead>
                                <tr>
                                    <th style="width:50px;">Add</th>
                                    <th style="display:none;">ID</th>
                                    <th>Item Code</th>
                                    <th>Description</th>
                                    <th style="width:80px;">Unit</th>
                                    <th style="width:80px; text-align:right;">UOM Qty</th>
                                    <th style="display:none;">Last Qty</th>
                                    <th style="display:none;">Last PR Date</th>
                                </tr>
                            </thead>
                            <tbody id="itemsTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ══════════════════════════════════════════════════════════
         MODAL: GIR Items
    ════════════════════════════════════════════════════════════ -->
    <div id="GIRModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog custom-modal-dialog custom-modal-dialog-xl" role="document">
            <div class="modal-content custom-modal-content">
                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-list-alt"></i></span>
                        <h4 class="modal-title custom-modal-title">GIR Items</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close">
                        <i class="fa fa-times"></i>
                    </button>
                </div>
                <div class="modal-body custom-modal-body">
                    <div class="custom-modal-table-wrap">
                        <table class="table custom-modal-table" id="tblGIRDetails">
                            <thead>
                                <tr>
                                    
                                    <th style="width: 50px;">
                                        <button type="button" id="GIRallItemsUpload" class="btn-item-pick" title="Select All">
                                            <i class="fa fa-plus-circle"></i>
                                        </button>
                                    </th>
                                    <th style="display:none;">MaterialRequestDetail Id</th>
                                    <th style="display:none;">MaterialRequest Id</th>
                                    <th>Request #</th>
                                    <th style="display:none;">Item Id</th>
                                    <th>Item Code</th>
                                    <th>Description</th>
                                    <th style="width:70px;">Unit</th>
                                    <th style="width:70px; text-align:right;">UOM Qty</th>
                                    <th style="width:70px; text-align:right;">QTY</th>
                                    <th style="width:110px; text-align:right;">Last Rate</th>
                                </tr>
                            </thead>
                            <tbody id="GIRItemTableBody"></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
