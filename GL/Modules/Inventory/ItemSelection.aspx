<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemSelection.aspx.cs" Inherits="PMS.Modules.Inventory.ItemSelection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        let currentSelectionID = 0;
        let currentGRNData = null;


        function showToast(message, type = 'success') {
            const toast = $('#toast');
            toast.removeClass('toast-success toast-error toast-info toast-warning')
                .addClass(`toast-${type}`)
                .html(`<i class="fas fa-${type === 'success' ? 'check-circle' : (type === 'error' ? 'exclamation-circle' : 'info-circle')}"></i> ${message}`)
                .fadeIn(300);

            setTimeout(() => {
                toast.fadeOut(300);
            }, 3500);
        }

        function showLoading(show, message = 'Processing...') {
            if (show) {
                $('#loadingMessage').text(message);
                $('#loadingOverlay').fadeIn(200);
            } else {
                $('#loadingOverlay').fadeOut(200);
            }
        }

        function loadGRNDropdown() {
            showLoading(true, 'Loading GRN list...');
            $.ajax({
                url: 'ItemSelection.aspx/GetGRNList',
                type: 'POST',
                contentType: 'application/json',
                dataType: 'json',
                success: function (response) {
                    const result = JSON.parse(response.d);
                    if (result.Success) {
                        const grns = result.Data;
                        const ddl = $('#ddlGRNNumber');
                        ddl.empty().append('<option value="">Select GRN Number</option>');

                        $.each(grns, function (i, grn) {
                            ddl.append(`<option value="${grn.GRN_ID}">${grn.GRN_Num} - ${grn.VendorName}</option>`);
                        });
                    } else {
                        showToast(result.Message || 'Error loading GRN list', 'error');
                    }
                    showLoading(false);
                },
                error: function (xhr, status, error) {
                    showLoading(false);
                    showToast('Error loading GRN list: ' + error, 'error');
                }
            });
        }

        function loadGRNDetails(grnId) {
            if (!grnId) {
                $('#tblItemsBody').html('<tr><td colspan="8" style="text-align: center; padding: 40px;"><i class="fas fa-info-circle" style="font-size: 24px; color: #cbd5e0;"></i><br/>Please select a GRN number to load items</td></tr>');
                $('#txtWarehouse, #txtVendor').val('');
                $('#btnSaveSelection').prop('disabled', true);
                return;
            }

            showLoading(true, 'Loading GRN details...');
            $.ajax({
                url: 'ItemSelection.aspx/GetGRNDetails',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ grnId: grnId }),
                dataType: 'json',
                success: function (response) {
                    const result = JSON.parse(response.d);
                    if (result.Success) {
                        currentGRNData = result.Data;

                        $('#txtWarehouse').val(result.Data.WarehouseName || result.Data.InvOrgId || 'N/A');
                        $('#txtVendor').val(result.Data.VendorName || 'N/A');

                        loadItemsTable(result.Data.Items);
                        $('#btnSaveSelection').prop('disabled', false);
                    } else {
                        showToast(result.Message || 'Error loading GRN details', 'error');
                    }
                    showLoading(false);
                },
                error: function (xhr, status, error) {
                    showLoading(false);
                    showToast('Error loading GRN details: ' + error, 'error');
                }
            });
        }

        function loadItemsTable(items) {
            const tbody = $('#tblItemsBody');

            if (!items || items.length === 0) {
                tbody.html('<tr><td colspan="9" style="text-align: center; padding: 40px;"><i class="fas fa-box-open" style="font-size: 24px; color: #cbd5e0;"></i><br/>No items found in this GRN</td></tr>');
                return;
            }

            let html = '';
            $.each(items, function (i, item) {
                let statusClass = 'badge-success';
                let statusText = 'IN STOCK';
                let maxSelectableQty = item.CurrentStock; 

                if (item.CurrentStock <= 0) {
                    statusClass = 'badge-danger';
                    statusText = 'OUT OF STOCK';
                    maxSelectableQty = 0;
                } else if (item.CurrentStock < 10) {
                    statusClass = 'badge-warning';
                    statusText = 'LOW STOCK';
                }

                let stockDisplay = `<span class="${item.CurrentStock <= 0 ? 'text-danger' : (item.CurrentStock < 10 ? 'text-warning' : 'text-success')}">
                                <strong>${parseFloat(item.CurrentStock).toFixed(2)}</strong> ${escapeHtml(item.Unit || '')}
                            </span>`;

                html += `<tr data-grndetailid="${item.GRN_Detail_Id}" data-itemid="${item.Item_Id}" data-maxqty="${maxSelectableQty}">
                    <td><strong>${escapeHtml(item.ItemCode || '-')}</strong></td>
                    <td>${escapeHtml(item.ItemName || '-')}</td>
                    <td>${stockDisplay}</td>
                    <td>${parseFloat(item.GRNQty).toFixed(2)}</td>
                    <td><span class="badge badge-info">${escapeHtml(item.BatchNum || '-')}</span></td>
                    <td>${escapeHtml(item.Unit || '-')}</td>
                    <td>${parseFloat(item.Rate || 0).toFixed(2)}</td>
                    <td>
                        <input type="number" class="qty-input" value="0" min="0" max="${maxSelectableQty}" step="any" 
                               onchange="updateQuantity(this, ${item.GRN_Detail_Id}, ${maxSelectableQty})" />
                    </td>
                    <td><span class="badge ${statusClass}">${statusText}</span></td>
                 </tr>`;
            });
            tbody.html(html);
        }

        function escapeHtml(text) {
            if (!text) return '';
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        window.updateQuantity = function (input, grnDetailId, maxQty) {
            let value = parseFloat($(input).val());
            if (isNaN(value)) value = 0;
            if (value < 0) value = 0;
            if (value > maxQty) {
                $(input).val(maxQty);
                showToast(`Maximum quantity is ${maxQty}`, 'warning');
            }
        };

        function saveSelection() {
            const selectionDate = $('#txtSelectionDate').val();
            const grnId = $('#ddlGRNNumber').val();
            const remarks = $('#txtRemarks').val();

            if (!selectionDate) {
                showToast('Please select selection date', 'error');
                return;
            }

            if (!grnId) {
                showToast('Please select GRN number', 'error');
                return;
            }

            const selectedItems = [];
            let hasSelection = false;
            let totalSelectedQty = 0;

            $('#tblItemsBody tr').each(function () {
                const grnDetailId = $(this).data('grndetailid');
                const itemId = $(this).data('itemid');
                const maxQty = $(this).data('maxqty');
                const qtyInput = $(this).find('.qty-input');
                const selectedQty = parseFloat(qtyInput.val()) || 0;

                if (selectedQty > 0) {
                    hasSelection = true;
                    totalSelectedQty += selectedQty;
                    selectedItems.push({
                        GRN_Detail_Id: grnDetailId,
                        Item_Id: itemId,
                        Selected_Qty: selectedQty,
                        Max_Qty: maxQty
                    });
                }
            });

            if (!hasSelection) {
                showToast('Please select at least one item with quantity greater than 0', 'error');
                return;
            }

            showLoading(true, 'Saving selection...');
            $.ajax({
                url: 'ItemSelection.aspx/SaveSelection',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({
                    selectionDate: selectionDate,
                    grnId: grnId,
                    remarks: remarks,
                    selectedItems: selectedItems
                }),
                dataType: 'json',
                success: function (response) {
                    const result = JSON.parse(response.d);
                    if (result.Success) {
                        currentSelectionID = result.Data.SelectionID;
                        $('#txtSelectionNum').val(result.Data.SelectionNum);
                        $('#summarySection').show();
                        $('#lblSelectionID').text(result.Data.SelectionID);
                        $('#lblTotalItems').text(result.Data.TotalItems);
                        $('#lblTotalSelectedQty').text(result.Data.TotalSelectedQty);
                        $('#lblStatus').text('Saved').removeClass().addClass('badge badge-success');
                        $('#btnGenerateBarcodes').prop('disabled', false);
                        showToast('Selection saved successfully!', 'success');
                    } else {
                        showToast(result.Message || 'Error saving selection', 'error');
                    }
                    showLoading(false);
                },
                error: function (xhr, status, error) {
                    showLoading(false);
                    showToast('Error saving selection: ' + error, 'error');
                }
            });
        }

        function generateBarcodes() {
            if (!currentSelectionID) {
                showToast('Please save selection first', 'error');
                return;
            }

            showLoading(true, 'Generating barcodes...');
            $.ajax({
                url: 'ItemSelection.aspx/GenerateBarcodes',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ selectionId: currentSelectionID }),
                dataType: 'json',
                success: function (response) {
                    const result = JSON.parse(response.d);
                    if (result.Success) {
                        displayBarcodes(result.Data.Barcodes);
                        $('#btnPrintBarcodes').prop('disabled', false);
                        $('#lblStatus').text('Barcodes Generated').removeClass().addClass('badge badge-info');
                        showToast(`${result.Data.TotalBarcodes} barcodes generated successfully!`, 'success');
                    } else {
                        showToast(result.Message || 'Error generating barcodes', 'error');
                    }
                    showLoading(false);
                },
                error: function (xhr, status, error) {
                    showLoading(false);
                    showToast('Error generating barcodes: ' + error, 'error');
                }
            });
        }

        function displayBarcodes(barcodes) {
            const section = $('#barcodesSection');
            const grid = $('#barcodesGrid');

            if (!barcodes || barcodes.length === 0) {
                grid.html('<p style="text-align: center; padding: 40px;"><i class="fas fa-barcode" style="font-size: 48px; color: #cbd5e0;"></i><br/>No barcodes generated</p>');
                return;
            }

            let html = `
        <div class="table-responsive">
            <table class="table table-bordered table-hover" id="barcodesTable" style="width: 100%;">
                <thead style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white;">
                    <tr>
                        <th style="text-align: center; padding: 12px;">#</th>
                        <th style="text-align: center; padding: 12px;">Barcode Number</th>
                        <th style="text-align: center; padding: 12px;">Item Code</th>
                        <th style="text-align: center; padding: 12px;">Item Name</th>
                        <th style="text-align: center; padding: 12px;">Serial #</th>
                        <th style="text-align: center; padding: 12px;">Quantity</th>
                        <th style="text-align: center; padding: 12px;">Generation Date</th>
                        <th style="text-align: center; padding: 12px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
    `;

            $.each(barcodes, function (i, barcode) {
                let formattedDate = 'Invalid Date';
                let generationDate = barcode.Generation_Date;

                if (generationDate) {
                    let dateObj = null;

                    if (typeof generationDate === 'string') {
                        if (generationDate.indexOf('/Date(') === 0) {
                            let milliseconds = parseInt(generationDate.match(/\d+/)[0]);
                            dateObj = new Date(milliseconds);
                        }
                        else {
                            dateObj = new Date(generationDate);
                        }
                    }
                    else if (typeof generationDate === 'number') {
                        dateObj = new Date(generationDate);
                    }

                    if (dateObj && !isNaN(dateObj.getTime())) {
                        formattedDate = dateObj.toLocaleString('en-PK', {
                            year: 'numeric',
                            month: '2-digit',
                            day: '2-digit',
                            hour: '2-digit',
                            minute: '2-digit',
                            second: '2-digit',
                            hour12: false
                        });
                    }
                }

                html += `
            <tr style="cursor: pointer;" onclick="copyToClipboard('${barcode.Barcode_Number}')">
                <td style="text-align: center; padding: 10px;">${i + 1}</td>
                <td style="text-align: center; padding: 10px;">
                    <code style="background: #f4f4f4; padding: 4px 8px; border-radius: 4px; font-size: 12px;">${escapeHtml(barcode.Barcode_Number)}</code>
                </td>
                <td style="padding: 10px;"><strong>${escapeHtml(barcode.ItemCode || '-')}</strong></td>
                <td style="padding: 10px;">${escapeHtml(barcode.ItemName || '-')}</td>
                <td style="text-align: center; padding: 10px;">
                    <span class="badge badge-primary">${barcode.Serial_Number || '-'}</span>
                </td>
                <td style="text-align: center; padding: 10px;">
                    <span class="badge badge-success">${barcode.Quantity || 0}</span>
                </td>
                <td style="text-align: center; padding: 10px; font-size: 12px;">
                    <i class="fas fa-calendar-alt" style="color: #667eea;"></i> ${formattedDate}
                </td>
                <td style="text-align: center; padding: 10px;">
                    <button class="btn btn-sm btn-info" onclick="event.stopPropagation(); copyToClipboard('${barcode.Barcode_Number}')">
                        <i class="fas fa-copy"></i> Copy
                    </button>
                </td>
            </tr>
        `;
            });

            html += `
                </tbody>
            </table>
        </div>
        <div style="margin-top: 15px; text-align: right; padding: 10px;">
            <small class="text-muted">
                <i class="fas fa-info-circle"></i> Click on any row or click "Copy" to copy barcode number
            </small>
        </div>
    `;

            grid.html(html);
            $('#barcodeCount').text(`(${barcodes.length} barcodes)`);
            section.fadeIn(300);

            if ($.fn.DataTable) {
                $('#barcodesTable').DataTable({
                    "pageLength": 10,
                    "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
                    "order": [[0, "asc"]],
                    "language": {
                        "search": "Search:",
                        "lengthMenu": "Show _MENU_ entries",
                        "info": "Showing _START_ to _END_ of _TOTAL_ barcodes"
                    }
                });
            }
        }

        window.copyToClipboard = function (barcode) {
            navigator.clipboard.writeText(barcode).then(function () {
                showToast(`✓ Barcode "${barcode}" copied to clipboard!`, 'success');
                event.stopPropagation();
            }).catch(function () {
                showToast('Failed to copy barcode', 'error');
            });
        };

        window.copyToClipboard = function (barcode) {
            navigator.clipboard.writeText(barcode).then(function () {
                showToast(`Barcode ${barcode} copied to clipboard!`, 'success');
            }).catch(function () {
                showToast('Failed to copy barcode', 'error');
            });
        };

        function printBarcodes() {
            const printContent = $('#barcodesSection').clone();
            printContent.find('.btn-group, button').remove();

            const printWindow = window.open('', '_blank');
            printWindow.document.write(`
                <html>
                <head>
                    <title>Print Barcodes - Selection #${$('#txtSelectionNum').val()}</title>
                    <style>
                        * { margin: 0; padding: 0; box-sizing: border-box; }
                        body { font-family: 'Segoe UI', Arial, sans-serif; padding: 20px; }
                        h2 { color: #333; margin-bottom: 10px; }
                        .print-header { margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #667eea; }
                        .print-header p { color: #666; margin-top: 5px; }
                        .barcode-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-top: 20px; }
                        .barcode-card { border: 1px solid #ddd; padding: 15px; text-align: center; border-radius: 8px; page-break-inside: avoid; }
                        .barcode-number { font-family: 'Courier New', monospace; font-size: 16px; font-weight: bold; letter-spacing: 2px; margin: 10px 0; }
                        .barcode-info { font-size: 11px; color: #666; }
                        .barcode-icon { font-size: 40px; color: #667eea; }
                        @media print {
                            .barcode-grid { grid-template-columns: repeat(3, 1fr); }
                            .barcode-card { break-inside: avoid; }
                        }
                    </style>
                </head>
                <body>
                    <div class="print-header">
                        <h2>Item Selection Barcodes</h2>
                        <p>Selection #: ${$('#txtSelectionNum').val()} | Date: ${$('#txtSelectionDate').val()} | GRN: ${$('#ddlGRNNumber option:selected').text()}</p>
                    </div>
                    ${printContent.html()}
                    <script>
                        window.onload = function() { 
                            setTimeout(function() {
                                window.print();
                                setTimeout(function() { window.close(); }, 1000);
                            }, 500);
                        };
                    <\/script>
                </body>
                </html>
            `);
            printWindow.document.close();
        }

        function resetForm() {
            if (confirm('Are you sure you want to reset the form? All unsaved data will be lost.')) {
                currentSelectionID = 0;
                currentGRNData = null;
                const today = new Date().toISOString().split('T')[0];
                $('#txtSelectionDate').val(today);
                $('#txtSelectionNum').val('');
                $('#ddlGRNNumber').val('');
                $('#txtWarehouse').val('');
                $('#txtVendor').val('');
                $('#txtRemarks').val('');
                $('#summarySection').hide();
                $('#barcodesSection').hide();
                $('#btnSaveSelection').prop('disabled', true);
                $('#btnGenerateBarcodes').prop('disabled', true);
                $('#btnPrintBarcodes').prop('disabled', true);
                loadGRNDropdown();
                showToast('Form reset successfully', 'info');
            }
        }

        $(document).ready(function () {
            const today = new Date().toISOString().split('T')[0];
            $('#txtSelectionDate').val(today);

            loadGRNDropdown();

            $('#ddlGRNNumber').change(function () {
                loadGRNDetails($(this).val());
            });

            $('#btnSaveSelection').click(saveSelection);
            $('#btnGenerateBarcodes').click(generateBarcodes);
            $('#btnPrintBarcodes').click(printBarcodes);
            $('#btnReset').click(resetForm);
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div id="loadingOverlay" class="loading-overlay">
            <div class="loading-content">
                <div class="spinner"></div>
                <div id="loadingMessage">Processing...</div>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>SELECTION DATE <span class="required">*</span></label>
                <input type="date" id="txtSelectionDate" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>SELECTION NUMBER</label>
                <input type="text" id="txtSelectionNum" class="form-control" readonly="readonly" placeholder="Auto-generated on save" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>GRN NUMBER</label>
                <select id="ddlGRNNumber" class="form-control">
                    <option value="">Select GRN Number</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>WAREHOUSE / STORE LOCATION</label>
                <input type="text" id="txtWarehouse" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>VENDOR</label>
                <input type="text" id="txtVendor" class="form-control" readonly="readonly" />
            </div>
        </div>
    <div class="row">
        <div class="col-lg-4 col-md-8 col-sm-12">
            <label>REMARKS</label>
            <textarea id="txtRemarks" class="form-control" cols="2" rows="2" placeholder="Optional remarks..."></textarea>
        </div>

    </div>
        <div id="toast" class="toast-notification"></div>    
        <div class="form-card">        
            <div id="summarySection" class="summary-section" style="display: none;">
                <div class="summary-item">
                    <span class="summary-label"><i class="fas fa-hashtag"></i> Selection ID:</span>
                    <span class="summary-value" id="lblSelectionID">-</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label"><i class="fas fa-box"></i> Total Items:</span>
                    <span class="summary-value" id="lblTotalItems">0</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label"><i class="fas fa-calculator"></i> Selected Quantity:</span>
                    <span class="summary-value" id="lblTotalSelectedQty">0</span>
                </div>
                <div class="summary-item">
                    <span class="summary-label"><i class="fas fa-chart-line"></i> Status:</span>
                    <span class="badge badge-info" id="lblStatus">Pending</span>
                </div>
            </div>
            
            <div class="table-responsive">
                <table class="table" id="tblItems">
                    <thead>
                        <tr>
                            <th>Item Code</th>
                            <th>Item Name</th>
                            <th>Current Stock</th>
                            <th>GRN Quantity</th>
                            <th>Batch Number</th>
                            <th>Unit</th>
                            <th>Rate</th>
                            <th>Qty to Select</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemsBody">
                        <tr>
                            <td colspan="8" style="text-align: center; padding: 40px;">
                                <i class="fas fa-info-circle" style="font-size: 24px; color: #cbd5e0;"></i><br/>
                                Please select a GRN number to load items
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
            <div class="row">
                <div class="col-lg-9 col-md-10 col-sm-12">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" id="btnSaveSelection" class="btn btn-primry" value="SAVE" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" id="btnGenerateBarcodes" class="btn btn-primry" value="BARCODES" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" id="btnReset" class="btn btn-primry" value="RESET" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <div id="barcodesSection" class="form-card" style="display: none;">
            <div class="card-title">
                <i class="fas fa-qrcode"></i> Generated Barcodes 
                <span id="barcodeCount" style="font-size: 12px; color: #667eea;"></span>
            </div>
            <div id="barcodesContainer" class="barcode-container">
                <div class="barcode-grid" id="barcodesGrid"></div>
            </div>
        </div>
</asp:Content>
