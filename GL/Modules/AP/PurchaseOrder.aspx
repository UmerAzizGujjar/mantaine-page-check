<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseOrder.aspx.cs" Inherits="PMS.AP.PurchaseOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/PO.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/custom-modals.css" rel="stylesheet" />
    <style type="text/css">
        .tooltip-inner {
            background-color: #ffc107 !important;
            color: #000 !important;
            font-size: 12px;
            font-weight: bold;
        }

        .tooltip-arrow::before {
            border-top-color: #ffc107 !important;
            border-bottom-color: #ffc107 !important;
        }

        #ui-datepicker-div{
        z-index: 1000 !important;
        }
        /* ========== PAGE LOADER STYLES ========== */
/* Enhanced PAGE LOADER STYLES */
#page-loader {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(255, 255, 255, 0.95);
    z-index: 9999;
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    /* Add these to ensure full coverage */
    right: 0;
    bottom: 0;
}

/* Optional: Add a container to center content better */
#page-loader .loader-container {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    text-align: center;
}

#page-loader .loader-spinner {
    border: 5px solid #f3f3f3;
    border-top: 5px solid #3498db;
    border-radius: 50%;
    width: 60px;
    height: 60px;
    animation: spin 1s linear infinite;
    margin-bottom: 20px;
}

#page-loader .loader-text {
    font-size: 16px;
    color: #333;
    font-weight: bold;
    margin-top: 10px;
}

/* Progress bar styles */
#page-loader .loader-progress {
    width: 300px;
    height: 6px;
    background: #e0e0e0;
    border-radius: 3px;
    margin-top: 20px;
    overflow: hidden;
}

#page-loader .loader-progress-bar {
    height: 100%;
    background: #3498db;
    width: 0%;
    transition: width 0.3s ease;
    border-radius: 3px;
}

@keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
}

#page-loader.hidden {
    display: none;
}

/* Ensure the loader is always on top and centered */
#page-loader.show {
    display: flex !important;
}
    </style>

    <script type="text/javascript">
        var poid = '<% =Request.QueryString["PO_ID"] %>';
        var replicateEnabled = '<%= ReplicateCode %>' === '01';
        var qtyFieldDisabled = false;
        var savedBranch = null;

        function loadUserBranch() {
            callPageMethod('GetUserBranch', function (result) {
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

        /* ── PageMethod → AJAX helper ─────────────────────────── */
        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/" + methodName,
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

        /* ─── Meta-bar sync helper ─── */
        function syncMetaBar() {
            var poNum = $('#ctl00_MainContent_txtPurchase_No').val() || '\u2014';
            var poDate = $('#ctl00_MainContent_txtPurchase_Date').val() || '\u2014';
            var status = $('#ctl00_MainContent_txtStatus').val() || 'Draft';
            $('#poMetaDisplay').html(
                'PO\u00a0#\u00a0<strong>' + poNum + '</strong>' +
                '\u00a0\u00a0|\u00a0\u00a0Date:\u00a0<strong>' + poDate + '</strong>' +
                '\u00a0\u00a0|\u00a0\u00a0Status:\u00a0<strong>' + status + '</strong>'
            );
        }

        /* ─── Source-type toggle (Item | PR) ─── */
        function initSourceToggle() {
            $('input[name="poSourceType"]').on('change', function () {
                if ($(this).val() === 'item') {
                    $('#itemInputSection').show();
                    $('#prInputSection').hide();
                } else {
                    $('#itemInputSection').hide();
                    $('#prInputSection').show();
                }
            });
        }

        // Function to append a single vendor item
        function appendVendorItem(item) {
            var length = $("#tblItemDescription tr:gt(0)").length + 1;

            var newRow = buildNewRow(
                length,
                "", // PR_Num (empty for direct vendor items)
                item.Item_Code,
                item.Description,
                item.Unit,
                item.Qty || 1,
                item.UOM_Qty || 1,
                item.Purchase_Rate || 0,
                0, // pr_detail_id (0 for direct items)
                item.TotalStock || 0,
                item.Purchase_Rate || 0,
                 item.LastVendorName || "",
                 false
            );

            $("#tblItemDescription tbody").append(newRow);

            // Populate dropdowns for the new row
            var staxLoaded = false;
            var advTaxLoaded = false;

            function checkBothLoaded() {
                if (staxLoaded && advTaxLoaded) {
                    CulculateAmonutWithQty(length);
                    $('[data-toggle="tooltip"]').tooltip();
                    $('#txtddate' + length).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                    calcTotal();
                }
            }

            // Populate Sales Tax dropdown
            callPageMethod('getwtaxtype', function (response) {
                var options = '<option value="0">0</option>';
                try {
                    var taxData = JSON.parse(response);
                    $.each(taxData, function (key, value) {
                        options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                    });
                } catch (e) {
                    console.error('Error parsing tax data:', e);
                }
                $('#ddlSTAX' + length).html(options);
                staxLoaded = true;
                checkBothLoaded();
            }, function (error) {
                console.error('Error loading Sales Tax:', error);
                staxLoaded = true;
                checkBothLoaded();
            });

            // Populate Advance Tax dropdown
            callPageMethod('getAdvanceTaxType', function (response) {
                var options = '<option value="0">0</option>';
                try {
                    var taxData = JSON.parse(response);
                    $.each(taxData, function (key, value) {
                        options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                    });
                } catch (e) {
                    console.error('Error parsing advance tax data:', e);
                }
                $('#ddlAdvanceTax' + length).html(options);
                advTaxLoaded = true;
                checkBothLoaded();
            }, function (error) {
                console.error('Error loading Advance Tax:', error);
                advTaxLoaded = true;
                checkBothLoaded();
            });
        }
        function FillStaxtype() {
            var options = '<option value="0">0</option>';
            callPageMethod('getwtaxtype', function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                $('.ddlSTAX').html(options);

            });
        }
        function FillAdvancetaxtype() {
            var options = '<option value="0">0</option>';
            callPageMethod('getAdvanceTaxType', function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    options += '<option value="' + value.Advance_Tax_ID + '" >' + value.Advance_Tax_Perc + '</option>';
                });
                $('.ddlAdvanceTax').html(options);
            });
        }
        function FillFurtherTaxType() {
            var options = '<option value="0">0</option>';
            callPageMethod('getFurtherTaxType', function (res) {
                $.each(JSON.parse(res), function (key, value) {
                    options += '<option value="' + value.Further_Tax_ID + '">' + value.Further_Tax_Perc + '</option>';
                });
                $('.ddlFurtherTax').html(options);
            });
        }
        // Add this function at the beginning of your JavaScript section
        var loaderTimeout = null;

        function showLoader(message, showProgressBar = false) {
            // Clear any pending hide timeout
            if (loaderTimeout) {
                clearTimeout(loaderTimeout);
                loaderTimeout = null;
            }

            var $loader = $('#page-loader');
            var $loaderText = $('.loader-text');
            var $progressBar = $('.loader-progress');
            var $progressBarFill = $('.loader-progress-bar');

            // Reset progress bar
            if ($progressBarFill.length) {
                $progressBarFill.css('width', '0%');
            }

            // Show or hide progress bar based on parameter
            if (showProgressBar) {
                $progressBar.show();
            } else {
                $progressBar.hide();
            }

            // Set message
            if (message) {
                $loaderText.text(message);
            } else {
                $loaderText.text('Loading...');
            }

            // Show loader
            $loader.removeClass('hidden').addClass('show').show();
        }

        function hideLoader() {
            var $loader = $('#page-loader');

            // Set timeout to ensure loader doesn't flash
            if (loaderTimeout) {
                clearTimeout(loaderTimeout);
            }

            loaderTimeout = setTimeout(function () {
                $loader.addClass('hidden').removeClass('show').hide();
                loaderTimeout = null;
            }, 300);
        }

        function updateLoaderProgress(percentage, message) {
            var $progressBarFill = $('.loader-progress-bar');
            var $loaderText = $('.loader-text');

            if ($progressBarFill.length) {
                $progressBarFill.css('width', percentage + '%');
            }

            if (message) {
                $loaderText.text(message);
            } else if (percentage < 100) {
                $loaderText.text('Loading tax rates... ' + percentage + '%');
            } else {
                $loaderText.text('Finalizing...');
            }
        }
        var selectedOptions = '';
        var fedcounter = 1;
        var taxcounter = 1;
        var Counter = 1;
        function PrintPurchseOrderReport() {
            var contents = $("#PrintPurchseOrderReport").html();
            var frame1 = $('<iframe />');
            frame1[0].name = "frame1";
            frame1.css({ "position": "absolute", "top": "-1000000px" });
            $("body").append(frame1);
            var frameDoc = frame1[0].contentWindow;
            frameDoc.document.open();
            frameDoc.document.write('<html>');
            frameDoc.document.write('<body>');
            frameDoc.document.write(contents);
            frameDoc.document.write('</body></html>');
            frameDoc.document.close();
            setTimeout(function () {
                window.frames["frame1"].focus();
                window.frames["frame1"].print();
                frame1.remove();
                window.close();
            }, 500);
        }
        function CurrencyFormatted(num) {
            num = num.toString().replace(/\$|\,/g, '');
            if (isNaN(num))
                num = "0";
            sign = (num == (num = Math.abs(num)));
            num = Math.floor(num * 100 + 0.50000000001);
            cents = num % 100;
            num = Math.floor(num / 100).toString();
            if (cents < 10)
                cents = "0" + cents;
            for (var i = 0; i < Math.floor((num.length - (1 + i)) / 3); i++)
                num = num.substring(0, num.length - (4 * i + 3)) + ',' +
                    num.substring(num.length - (4 * i + 3));
            return (((sign) ? '' : '-') + num);
        }
        function GetDetail(PO_No) {
            callPageMethod('GetPODetail', { PO_No: PO_No }, function (res) {
                var Test = JSON.parse(res);

                var rows = '';
                var SrNo = 0;
                $('#Billtbody tr').remove();
                $.each(Test, function (key, value) {
                    SrNo += 1;
                    rows += '<tr ><td valign="top" style="border: 1px solid black;  border-collapse: collapse;height:30px;border-color:lightgrey;text-align:center;margin-left: 45px;">' + SrNo + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Item_Name + '</td><td style="border: 1px solid black; border-collapse: collapse;height:10px;border-color:lightgrey;margin-left: 45px;" valign="top">' + value.Unit + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + value.Qty + '</td><td style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;" valign="top"> ' + value.Rate + '</td><td valign="top" style=" border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + value.Discount_Amount + '</td><td valign="top" style="border: 1px solid black; border-collapse: collapse;height:10px;text-align: center;border-color:lightgrey;text-align:Right;margin-left: 45px;">' + value.Amount + '</td></tr>';
                });
                $('#Billtbody').html(rows);
                PrintPurchseOrderReport();
            });
        }
        function removeCommas(str) {
            while (str.search(",") >= 1) {
                str = (str + "").replace(',', '');
            }
            return str;
        };

        function PrintPurchaseOrderDetail() {
            var id = '<% =Request.QueryString["PO_ID"] %>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=PurchaseOrderList&ReportTitle=Purchase Order List&POid=' + id;
            }
            window.open(url, '_blank');
        }
        function PrintPurchaseOrderDetail2() {
            var id = '<% =Request.QueryString["PO_ID"] %>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=PurchaseOrderList2&ReportTitle=Purchase Order List&POid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=PurchaseOrderList2&ReportTitle=Purchase Order List&POid=' + id;
            }
            window.open(url, '_blank');
        }

        function append(anchor, isBulk = false) {

            if (typeof anchor === 'string' || typeof anchor === 'number') {
                var itemId = anchor;
                if (!itemId) {
                    console.warn("No item ID found for token input addition.");
                    return;
                }

                callPageMethod('SearchItem', { ItemCode: parseInt(itemId) }, function (response) {
                    var items = JSON.parse(response);
                    if (items && items.length > 0) {
                        var itm = items[0];
                        var length = $("#tblItemDescription tr:gt(0)").length + 1;

                        var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value="' + itm.Item_Code + '"]');
                        if (test_array.length > 0) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'This Item already added!',
                                showConfirmButton: false,
                                timer: 2000
                            });
                            return;
                        }

                        var newRow = buildNewRow(
                            length,
                            "",
                            itm.Item_Code,
                            itm.Description,
                            itm.UnitName || itm.Unit,
                            1,
                            itm.Pack_Quantity || 1,
                            itm.Sale_Rate || 0,
                            0,
                            0,
                            itm.Sale_Rate || 0,
                            itm.LastVendorName || "",
                            false
                        );

                        $("#tblItemDescription tbody").append(newRow);

                        
                        var staxLoaded = false;
                        var advTaxLoaded = false;
                        function checkBothLoaded() {
                            if (staxLoaded && advTaxLoaded) {
                                CulculateAmonutWithQty(length);
                                $('[data-toggle="tooltip"]').tooltip();
                                $('#txtddate' + length).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                                calcTotal();
                            }
                        }

                        callPageMethod('getwtaxtype', function (response) {
                            var options = '<option value="0">0</option>';
                            try {
                                var taxData = JSON.parse(response);
                                $.each(taxData, function (key, value) {
                                    options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                                });
                            } catch (e) { console.error('Error parsing tax data:', e); }
                            $('#ddlSTAX' + length).html(options);
                            staxLoaded = true;
                            checkBothLoaded();
                        });

                        callPageMethod('getAdvanceTaxType', function (response) {
                            var options = '<option value="0">0</option>';
                            try {
                                var taxData = JSON.parse(response);
                                $.each(taxData, function (key, value) {
                                    options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                                });
                            } catch (e) { console.error('Error parsing advance tax data:', e); }
                            $('#ddlAdvanceTax' + length).html(options);
                            advTaxLoaded = true;
                            checkBothLoaded();
                        });
                    }
                });
                return;
            }

            
            var row = $(anchor).parents('tr')[0];

            
            if (!row) return;

            var PR_Num = $($(row).find('td')[1]).text();
            var item_name = $($(row).find('td')[3]).text();
            var unit = $($(row).find('td')[6]).text();
            var Rate = $($(row).find('td')[8]).text();
            var pr_detail_id = $($(row).find('td')[9]).text();
            var Qty = $($(row).find('td')[4]).text();
            var itemcode = $($(row).find('td')[5]).text();
            var UOM_Qty = $($(row).find('td')[10]).text();

            var total_stock = $($(row).find('td')[11]).text() || '0';
            var last_po_rate = $($(row).find('td')[12]).text() || '0';
            var last_vendor_name = $($(row).find('td')[13]).text() || '';

            if (unit == "null") unit = "";
            if (Rate == "null" || Rate == "NaN") Rate = "0";
            if (UOM_Qty == "null" || UOM_Qty == "") UOM_Qty = "0";
            if (last_po_rate == "null" || last_po_rate == "NaN") last_po_rate = "0";

            var length = $("#tblItemDescription tr:gt(0)").length + 1;

            
            var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value="' + itemcode + '"]');
            if (test_array.length > 0) {
                if (!isBulk) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'This Item already added!',
                        showConfirmButton: false,
                        timer: 2000
                    });
                }
                return false;
            } else {
                
                var newRow = buildNewRow(length, PR_Num, itemcode, item_name, unit, Qty, UOM_Qty, Rate, pr_detail_id, total_stock, last_po_rate, last_vendor_name, qtyFieldDisabled);
                $("#tblItemDescription tbody").append(newRow);

                
                var staxLoaded = false;
                var advTaxLoaded = false;

                function checkBothLoaded() {
                    if (staxLoaded && advTaxLoaded) {
                        if (!isBulk) {
                            CulculateAmonutWithQty(length);
                            $('[data-toggle="tooltip"]').tooltip();
                            $('#txtddate' + length).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                            calcTotal();
                        }
                    }
                }

                
                callPageMethod('getwtaxtype', function (response) {
                    var options = '<option value="0">0</option>';
                    try {
                        var taxData = JSON.parse(response);
                        $.each(taxData, function (key, value) {
                            options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                        });
                    } catch (e) {
                        console.error('Error parsing tax data:', e);
                    }
                    $('#ddlSTAX' + length).html(options);
                    staxLoaded = true;
                    checkBothLoaded();
                }, function (error) {
                    console.error('Error loading Sales Tax:', error);
                    staxLoaded = true;
                    checkBothLoaded();
                });

                
                callPageMethod('getAdvanceTaxType', function (response) {
                    var options = '<option value="0">0</option>';
                    try {
                        var taxData = JSON.parse(response);
                        $.each(taxData, function (key, value) {
                            options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                        });
                    } catch (e) {
                        console.error('Error parsing advance tax data:', e);
                    }
                    $('#ddlAdvanceTax' + length).html(options);
                    advTaxLoaded = true;
                    checkBothLoaded();
                }, function (error) {
                    console.error('Error loading Advance Tax:', error);
                    advTaxLoaded = true;
                    checkBothLoaded();
                });
            }
        }

        // Helper function to build row HTML
function buildNewRow(length, PR_Num, itemcode, item_name, unit, Qty, UOM_Qty, Rate, pr_detail_id, total_stock, lastPORate, last_vendor_name, disableQty) {
            return '<tr>' +
                '<td style=""><input type="hidden" id="txtPRDId' + length + '" name="txtPRDId" value="' + pr_detail_id + '" style="width: 75px !important;text-align:right" />' + length + '</td>' +
                '<td style=""><input type="hidden" name="txtPRNo" id="txtPRNO' + length + '" value="' + PR_Num + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"/>' + PR_Num + '</td>' +
                '<td style="text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + length + '" value="" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"/></td>' +
                '<td style="text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + length + '" value="' + itemcode + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;"/> ' + itemcode + '  </td>' +
                '<td style="text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '" value="' + item_name + '"/> ' + item_name + '  </td>' +
                '<td style="text-align:left!important;"> <input type="hidden" name="txtUnit" id="txtUnit' + length + '" value="' + unit + '" />' + unit + '  </td>' +
                '<td><input type="text" id="txtQty' + length + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="' + Qty + '" ' + (disableQty ? 'disabled="disabled"' : '') + '/></td>' +
                '<td><input type="text" id="txtUOMQty' + length + '" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtUOMQty" value="' + UOM_Qty + '" /></td>' +
                '<td><input type="text" id="txtBonusQty' + length + '" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtBonusQty" value="0" data-toggle="tooltip" data-placement="bottom" title="Enter Bonus quantity in Loose"/></td>' +
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + length + '" value="' + Rate + '" /></td>' +
                /*'<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtDisPer" readonly="readonly" id="txtDisPer' + length + '" value="0" /></td>' +*/
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtDisPer" onchange="calculateDiscountFromPercent(this)" onkeyup="calculateDiscountFromPercent(this)" id="txtDisPer' + length + '" value="0" /></td>' +
                '<td style="text-align:right;"><input type="text" onkeyup="calcTotal()" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;text-align:right!important;" id="txtDisAmount' + length + '" name="txtDisAmount" value="0"></input></td>' +
                '<td><select id="ddlSTAX' + length + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><option value="0">0</option></select></td>' +
                '<td style="text-align:right!important"><input type="text" style="text-align:right!important; width:100%!important;font-size:12px;font-weight:700;height:28px;" value="0" readonly="readonly" id="txtSalAmount' + length + '" name="txtSalAmount" /></td>' +
                '<td><input type="text" id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" value="0" /></td>' +
                '<td><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount" onkeyup="calcFurtherTaxFromAmount(this)" data-manual="false"></td>' +
                '<td><select id="ddlAdvanceTax' + length + '" name="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"></select></td>' +
                '<td><input type="text" readonly="readonly" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtAdvanceTaxAmount' + length + '" name="txtAdvanceTaxAmount"></td>' +
                '<td style="display:none;"><select id="ddlFed' + length + '" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;margin-left: 6px;"><option value="0">0</option></select></td>' +
                '<td style="display:none;"><input type="text" value="0" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" id="txtFedAmount' + length + '" name="txtFedAmount"></input></td>' +
                '<td><input type="text" readonly style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtBonusAmount' + length + '" name="txtBonusAmount" /></td>' +
                '<td style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" readonly="readonly" id="txtTotalAmount' + length + '" name="txtTotalAmount"></input></td>' +
                '<td><input type="text" name="txtddate" id="txtddate' + length + '" class="row-date-picker" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" /></td>' +
                '<td style="text-align:center; font-weight:bold; color:#555;">' + total_stock + '</td>' +
                '<td style=" text-align:right;">' +
                '<input type="text" readonly="readonly" id="txtLastPORate' + length + '" name="txtLastPORate" ' +
                'style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + parseFloat(lastPORate).toFixed(2) + '" />' +
                '<td style=" text-align:center; font-size:12px;font-weight:700;"><input type="hidden" name="txtLastVendorName" value="' + (last_vendor_name || '') + '" />' + (last_vendor_name || '') + '</td>' +
                '<td style=""><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"></i></a>  </td>' +
                '</tr>';
        }
        var dropdownsPopulated = false;

        function populateTaxddl(rowId) {
            var $ddl = $('#ddlSTAX' + rowId);
            // Don't check if already populated - always populate to ensure data is loaded
            callPageMethod('getwtaxtype', function (response) {
                var options = '<option value="0">0</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                });
                $ddl.html(options);
            });
        }

        function populateAdvanceTaxddl(rowId, callback) {
            var $ddl = $('#ddlAdvanceTax' + rowId);
            // Don't check if already populated - always populate to ensure data is loaded
            PageMethods.getAdvanceTaxType(function (response) {
                var options = '<option value="0">0</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                });
                $ddl.html(options);
                if (typeof callback === 'function') {
                    callback();
                }
            });
        }
        function populateFurtherTaxddl(rowId) {
            callPageMethod('getFurtherTaxType', function (response) {
                var options = '<option value="0">0</option>';
                $.each(JSON.parse(response), function (key, value) {
                    options += '<option value="' + value.Further_Tax_ID + '">' + value.Further_Tax_Perc + '</option>';
                });
                $('#ddlFurtherTax' + rowId).html(options);
            });
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function LoadPrNoDetail(pr_id) {
            callPageMethod('getPurchaseByID', { PRID: pr_id }, function (data) {
                var Test = JSON.parse(data);
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    rows = '<tr>' +
                        '<td><input class="chktd" type="checkbox" onclick="append(this)"/></td>' +
                        '<td style="display:none;">' + Test[i].PR_Num + '</td>' +
                        '<td style="display:none;">' + Test[i].Item_ID + '</td>' +
                        '<td>' + Test[i].Description + '</td>' +
                        '<td>' + parseFloat(Test[i].Qty).toFixed(2) + '</td>' +
                        '<td style="display:none;">' + Test[i].Item_Code + '</td>' +
                        '<td style="display:none;">' + Test[i].Unit + '</td>' +
                        '<td style="display:none;">' + parseFloat(Test[i].Pack_Quantity).toFixed(2) + '</td>' +
                        '<td style="display:none;">' + parseFloat(Test[i].UnitPrice).toFixed(2) + '</td>' +
                        '<td style="display:none;">' + Test[i].PR_Detail_ID + '</td>' +
                        '<td style="display:none;">' + (Test[i].UOM_Qty != null ? Test[i].UOM_Qty : '0') + '</td>' +
                        '<td>' + (Test[i].TotalStock != null ? Test[i].TotalStock : '0') + '</td>' +
                        '<td style="display:none;">' + (Test[i].LastPORate != null ? parseFloat(Test[i].LastPORate).toFixed(2) : '0.00') + '</td>' +
                        '<td style="display:none;">' + (Test[i].LastVendorName != null ? Test[i].LastVendorName : '') + '</td>' + 
                        '</tr>';
                    $('#tblPOItemstModelTable tbody').append(rows);
                }
                $('#POItemsModel').modal({ backdrop: 'static' });
            });
        }
        var optionsList = '';
        function loaddata() {
            callPageMethod('getDDLlist', function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "Sal") {
                        optionsList += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionsList += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
            });
        }
        $(document).ready(function () {

            // GetPRQty - determine if qty field should be disabled (code "01" = disabled)
            callPageMethod('GetPRQty', function (res) {
                try {
                    var code = JSON.parse(res);
                    qtyFieldDisabled = (code === "01");
                } catch (e) {
                    qtyFieldDisabled = false;
                }
            });

            // Show loader immediately
            showLoader('Initializing...', false);

            // Initialize page
            UserRights();
            GetWareHouseCondition();
            GetprojectionCondition();
            $('#ctl00_MainContent_ddlprojection').change(function () {

                currentProjectionType = $(this).val();
                $('#ctl00_MainContent_ddlprojection').attr('disabled', true);
                if (currentProjectionType === '002') {
                    var projectionDate = $('#ctl00_MainContent_txtProjection_Date').val();
                    var warehouseId = $('#ddlWarehouse').val();

                    if (!projectionDate || projectionDate.trim() === '') {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Projection Date Required',
                            text: 'Please select a Projection Date for Type item wise projection. This date will be used to calculate consumption.',
                            confirmButtonText: 'Select Date',
                            showCancelButton: true,
                            cancelButtonText: 'Cancel'
                        }).then((result) => {
                            if (result.isConfirmed) {
                                $('#ctl00_MainContent_txtProjection_Date').focus();
                                $('#ctl00_MainContent_txtProjection_Date').datepicker('show');
                            }
                        });
                    } else if (!warehouseId || warehouseId === '0') {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warehouse Required',
                            text: 'Please select a Warehouse for Projection Type 002.',
                            confirmButtonText: 'OK'
                        });
                    } else {
                        Swal.fire({
                            icon: 'info',
                            title: 'Projection Type 002: Consumption Based',
                            html: 'Quantities will be automatically calculated based on:<br/>' +
                                '• Consumption data from <strong>' + projectionDate + '</strong><br/>' +
                                '• To current date<br/>' +
                                '• For selected warehouse',
                            timer: 3000,
                            showConfirmButton: false
                        });
                    }
                }
            });
            $('#ctl00_MainContent_ddlVendor').change(function () {
                if (vendorChanging) return;

                var vendorId = $(this).val();
                if (!vendorId || vendorId === '0') return;

                // Edit mode - skip everything
                var existingPOId = '<%= Request.QueryString["PO_ID"] %>';
                if (existingPOId !== null && existingPOId !== '') {
                    loadVendorItems(vendorId);
                    return;
                }

                // Not answered yet - wait
                if (!projectionAnswered) {
                    setTimeout(function () {
                        vendorChanging = true;
                        $('#ctl00_MainContent_ddlVendor').val('0').trigger('change');
                        vendorChanging = false;
                        Swal.fire({
                            icon: 'info',
                            title: 'Please wait',
                            text: 'Please answer the projection question first.',
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }, 100);
                    return;
                }
                // User said NO - load directly
                if (!projectionChosen) {
                    loadVendorItems(vendorId);
                    return;
                }
                var projTypes = $('#ctl00_MainContent_ddlprojection').val();
                if (projTypes == "001") {
                    if (warehouseCond === '01') {
                        var warehouse = $('#ddlWarehouse').val();
                        if (!warehouse || warehouse === '0') {
                            Swal.fire({
                                icon: 'warning',
                                title: 'Warning!',
                                text: 'Please select Warehouse first.',
                                timer: 2500,
                                showConfirmButton: false
                            });
                            vendorChanging = true;
                            $('#ctl00_MainContent_ddlVendor').val('0').trigger('change');
                            vendorChanging = false;
                            return;
                        }
                    }

                    // Validate projection date
                    var projDate = $('#ctl00_MainContent_txtProjection_Date').val();
                    if (!projDate || projDate.trim() === '') {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warning!',
                            text: 'Please select Projection Date first.',
                            timer: 2500,
                            showConfirmButton: false
                        });
                        vendorChanging = true;
                        $('#ctl00_MainContent_ddlVendor').val('0').trigger('change');
                        vendorChanging = false;
                        return;
                    }

                    // Validate projection type
                    var projType = $('#ctl00_MainContent_ddlprojection').val();
                    if (!projType || projType === '0' || projType === '') {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warning!',
                            text: 'Please select Projection Type first.',
                            timer: 2500,
                            showConfirmButton: false
                        });
                        vendorChanging = true;
                        $('#ctl00_MainContent_ddlVendor').val('0').trigger('change');
                        vendorChanging = false;
                        return;
                    }
                }
                // User said YES - validate warehouse

                // All good
                if (projType == "001") {
                    loadVendorItems(vendorId);
                }
                else if (projType == "002") {
                    return;
                }

            });
            $('#ddlWarehouse').change(function () {
                <% if (Request.QueryString["PO_ID"] == null) { %>
                $("#ddlWarehouse").attr('disabled', true);
                <% } %>
            });

            $('[id*=checkHeader]').click(function () {
                var isTrue = $(this).is(':checked');
                $('.chktd').prop('checked', isTrue);
                if (isTrue) {
                    showLoader('Adding items...', false);
                    var $rows = $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked");
                    var index = 0;
                    function processBatch() {
                        var batchSize = 50;
                        var end = Math.min(index + batchSize, $rows.length);
                        for (; index < end; index++) {
                            append($rows[index], true);
                        }
                        if (index < $rows.length) {
                            requestAnimationFrame(processBatch);
                        } else {
                            $('.row-date-picker').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                            $('[data-toggle="tooltip"]').tooltip();
                            calcTotal();
                            hideLoader();
                            Swal.fire({
                                icon: 'success',
                                title: 'Success',
                                text: 'Items processed successfully.',
                                timer: 1500,
                                showConfirmButton: false
                            });
                        }
                    }
                    processBatch();
                }
            });

            $('#ddlWarehouse').select2();

            // Load dropdowns
            loaddata();
            FillWarehouse();
            FillStaxtype();
            FillAdvancetaxtype();
            FillFurtherTaxType();
            $('#ddlBranch').select2();
            loadUserBranch();

            // Set default dates
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            var dueDate = new Date(currentDate);
            dueDate.setDate(dueDate.getDate() + 7);
            var formattedDueDate = $.datepicker.formatDate('dd M yy', dueDate);
            $("#ctl00_MainContent_txtPurchase_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#ctl00_MainContent_txtProjection_Date").val('').datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#ctl00_MainContent_txtdueDate").val(formattedDueDate).datepicker({ dateFormat: 'dd M yy' });

            syncMetaBar();
            initSourceToggle();

            // Load PO data ONLY if PO_ID exists in query string
     <% if (Request.QueryString["PO_ID"] != null) { %>
            var PO_ID = '<%= Request.QueryString["PO_ID"]%>';
             showLoader('Loading Purchase Order...', true);
             $('#btnSave').hide();

             // Wait for dropdowns to populate
             setTimeout(function () {
                 LoadPurchaseOrderData(PO_ID);
                 $('#btnSave').val('Update');
             }, 500);
    <% } else { %>
            // No PO_ID - hide loader after initialization
            setTimeout(function () {
                hideLoader();
            }, 500);
    <% } %>
    
    $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
            var PO_Id = '<%= Request.QueryString["PO_ID"] %>';
            if (PO_Id == "") {
                $('#btnPrint').hide();
                GetNewPurchaseNo();
            }

            $('select').select2();

            $('#btnPRSave').on('click', function () {
                var pr_id = $("#ctl00_MainContent_ddlPrNo").val();
                LoadPrNoDetail(pr_id);
                $('#ctl00_MainContent_txtRemarks').focus();
            });

            $('#txtItem').tokenInput("../../json.aspx?Table=INV_ItemsForPR", {
                tokenLimit: 1,
                onResult: function (results) {
                    if (warehouseCond === '01') {
                        var warehouseVal = $('#ddlWarehouse').val();
                        if (!warehouseVal || warehouseVal === '0' || warehouseVal === '') {
                            if (typeof Swal !== 'undefined' && !Swal.isVisible()) {
                                Swal.fire({
                                    icon: 'warning',
                                    title: 'Warning!',
                                    text: 'Please select warehouse first',
                                    timer: 3000,
                                    showConfirmButton: false
                                });
                            }
                            $('#ddlWarehouse').focus();
                            return [];
                        }
                    }
                    return results;
                },
                onAdd: function (item) {
                    try {
                        append(item.id);
                        $('#btnGIR').attr('disabled', true);
                        $('#btnGIR').css('pointer-events', 'none');
                        $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                        $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
                    } catch (err) {
                        alert(err.message);
                    }
                }
            });

            $('#txtItem').focus();

            $('#btnGetAllItems').on('click', function () {
                if (warehouseCond === '01') {
                    var warehouseVal = $('#ddlWarehouse').val();
                    if (!warehouseVal || warehouseVal === '0' || warehouseVal === '') {
                        Swal.fire({
                            icon: 'warning',
                            title: 'Warning!',
                            text: 'Please select warehouse first',
                            showConfirmButton: true,
                            timer: 3000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $('#ddlWarehouse').focus();
                        return false;
                    }
                }
                $('#ctl00_MainContent_ddlPrNo').prop('disabled', true);
                LoadAllitem('');
            });

            $('#searchInput').on('keyup', function () {
                var searchText = $(this).val().trim();
                LoadAllitem(searchText);
            });

            $('#chkByDefault').prop('checked', true); 
        });
/*        $(document).ready*/(function () {
            // ✅ Show page loader immediately
            $('#page-loader').removeClass('hidden').show();

            // Initialize page
            UserRights();
            GetWareHouseCondition();

            $('#ddlWarehouse').change(function () {
                <% if (Request.QueryString["PO_ID"] == null) { %>
                $("#ddlWarehouse").attr('disabled', true);
                <% } %>
            });

            $('[id*=checkHeader]').click(function () {
                var isTrue = $(this).is(':checked');
                $('.chktd').prop('checked', isTrue);
                if (isTrue) {
                    var $rows = $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked");
                    var index = 0;
                    function processBatch() {
                        var batchSize = 50;
                        var end = Math.min(index + batchSize, $rows.length);
                        for (; index < end; index++) {
                            append($rows[index], true);
                        }
                        if (index < $rows.length) {
                            requestAnimationFrame(processBatch);
                        } else {
                            $('.row-date-picker').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                            $('[data-toggle="tooltip"]').tooltip();
                            calcTotal();
                            Swal.fire({
                                icon: 'success',
                                title: 'Success',
                                text: 'Items processed successfully.',
                                timer: 1500,
                                showConfirmButton: false
                            });
                        }
                    }
                    processBatch();
                }
            });

            $('#ddlWarehouse').select2();

            // ✅ Load dropdowns IMMEDIATELY (NO setTimeout delay!)
            loaddata();
            FillWarehouse();
            FillStaxtype();
            FillAdvancetaxtype();
            FillFurtherTaxType();

            // Set default dates
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            var dueDate = new Date(currentDate);
            dueDate.setDate(dueDate.getDate() + 7);
            var formattedDueDate = $.datepicker.formatDate('dd M yy', dueDate);
            $("#ctl00_MainContent_txtPurchase_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#ctl00_MainContent_txtdueDate").val(formattedDueDate).datepicker({ dateFormat: 'dd M yy' });

        // Hide loader after initialization (data loaded from first ready block)
        setTimeout(function() {
            $('#page-loader').addClass('hidden').fadeOut(300);
        }, 1500);
    
    $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
    var PO_Id = '<%= Request.QueryString["PO_ID"] %>';
    if (PO_Id == "") {
        $('#btnPrint').hide();
        GetNewPurchaseNo();
    }
    
    $('select').select2();
    
    $('#btnPRSave').on('click', function () {
        var pr_id = $("#ctl00_MainContent_ddlPrNo").val();
        LoadPrNoDetail(pr_id);
        $('#ctl00_MainContent_txtRemarks').focus();
    });
    
    $('#txtItem').tokenInput("../../json.aspx?Table=INV_ItemsForPR", {
        tokenLimit: 1,
        onAdd: function (item) {
            try {
                $("#hditemID").val(item.id);
                append();
                $('#btnGIR').attr('disabled', true);
                $('#btnGIR').css('pointer-events', 'none');
                $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
            } catch (err) {
                alert(err.message);
            }
        }
    });
    
    $('#txtItem').focus();
    
    $('#btnGetAllItems').on('click', function () {
        $('#ctl00_MainContent_ddlPrNo').prop('disabled', true);
        LoadAllitem('');
    });
    
    $('#searchInput').on('keyup', function () {
        var searchText = $(this).val().trim();
        LoadAllitem(searchText);
    });
});



        function UserRights() {
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#btnSave').show();
                    } else {
                        $('#btnSave').hide();
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to retrieve user rights.',
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
 function loadVendorItems(vendorId) {
    if (!vendorId || vendorId === '0') return;

    if (!projectionChosen) {
        return;
    }

    $.ajax({
        type: "POST",
        url: "PurchaseOrder.aspx/GetVendorItems",
        data: JSON.stringify({ vendorId: vendorId }),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        success: function (response) {
            var items = JSON.parse(response.d);

            if (!items || items.length === 0) {
                console.log('No vendor items returned for vendorId: ' + vendorId);
                return;
            }

            // Append all vendor items
            $.each(items, function (index, item) {
                appendVendorItem(item);
            });

            var projType = $('#ctl00_MainContent_ddlprojection').val();
            var projDate = $('#ctl00_MainContent_txtProjection_Date').val();
            var warehouseId = $('#ddlWarehouse').val();

            // For projection type 002, fetch consumed quantities
            if (projType === '002' && projDate && projDate.trim() !== '' && warehouseId && warehouseId !== '0') {
                var itemIds = [];
                $.each(items, function (index, item) {
                    if (item.Item_ID && item.Item_ID !== 0) {
                        itemIds.push(item.Item_ID);
                    }
                });

                if (itemIds.length === 0) return;

                $.ajax({
                    type: "POST",
                    url: "PurchaseOrder.aspx/GetProjectedConsumptionForItems",
                    data: JSON.stringify({
                        itemIdsJson: JSON.stringify(itemIds),
                        projectionDate: projDate,
                        warehouseId: warehouseId
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (projResponse) {
                        var consumedQtys = JSON.parse(projResponse.d);

                        $('#tblItemDescription tbody tr').each(function () {
                            var $row = $(this);
                            var itemCode = $row.find('input[name=txtItemCode]').val();

                            $.each(items, function (index, item) {
                                if (item.Item_Code === itemCode) {
                                    var itemIdStr = item.Item_ID.toString();
                                    if (consumedQtys.hasOwnProperty(itemIdStr) && consumedQtys[itemIdStr] > 0) {
                                        // Convert to integer (remove decimal places)
                                        var intQty = Math.floor(consumedQtys[itemIdStr]);
                                        $row.find('input[name=txtQty]').val(intQty);
                                        CulculateAmonutWithQty($row.find('input[name=txtQty]')[0]);
                                    }
                                    return false;
                                }
                            });
                        });

                        calcTotal();
                    },
                    error: function (error) {
                        console.error("Error loading projected quantities", error);
                    }
                });
            } else if (projType === '001' && projDate && warehouseId && warehouseId !== '0') {
                // For type 001, use existing GetBatchProjectedQuantities
                var itemIds = [];
                $.each(items, function (index, item) {
                    if (item.Item_ID && item.Item_ID !== 0) {
                        itemIds.push(item.Item_ID);
                    }
                });

                if (itemIds.length === 0) return;

                $.ajax({
                    type: "POST",
                    url: "PurchaseOrder.aspx/GetBatchProjectedQuantities",
                    data: JSON.stringify({
                        itemIdsJson: JSON.stringify(itemIds),
                        projectionDate: projDate,
                        warehouseId: warehouseId
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (projResponse) {
                        var projQtys = JSON.parse(projResponse.d);

                        $('#tblItemDescription tbody tr').each(function () {
                            var $row = $(this);
                            var itemCode = $row.find('input[name=txtItemCode]').val();

                            $.each(items, function (index, item) {
                                if (item.Item_Code === itemCode) {
                                    var itemIdStr = item.Item_ID.toString();
                                    if (projQtys.hasOwnProperty(itemIdStr) && projQtys[itemIdStr] > 0) {
                                        // For type 001, keep as is (might be decimal)
                                        $row.find('input[name=txtQty]').val(projQtys[itemIdStr].toFixed(2));
                                    }
                                    return false;
                                }
                            });
                        });

                        calcTotal();
                    },
                    error: function (error) {
                        console.error("Error loading projected quantities", error);
                    }
                });
            }
        },
        error: function (error) {
            console.error("Error loading vendor items", error);
        }
    });
}
        function GetNewPurchaseNo() {
            callPageMethod('GetNewPurchaseNo', function (resp) {
                $('#ctl00_MainContent_txtPurchase_No').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function LoadPurchaseOrderData(PO_ID) {
            callPageMethod('LoadPOHeaderDetail', { PO_ID: PO_ID }, function (resp) {
                var data = JSON.parse(resp);
                var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.PO_Date.substring(6, 19))));
                $('#ctl00_MainContent_txtPurchase_Date').val(datetime);
                if (data.Due_Date != null || data.Due_Date != undefined) {
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Due_Date.substring(6, 19))));
                    $('#ctl00_MainContent_txtdueDate').val(datetime);
                }
                $('#hdnPurchase_ID').val(data.PO_ID);
                $('#txttranstype').val(data.Transaction_Type);
                $('#txtcsmasterid').val(data.CS_Master_ID);
                $('#ctl00_MainContent_txtPurchase_No').val(data.PO_No);
                $("#ctl00_MainContent_txtPurchase_Reference").val(data.Ref_No);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlTerm').val(data.Term_ID).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlVendor').val(data.Vendor_ID).trigger('change');
                }, 1000);
                $('#ctl00_MainContent_txtRemarks').val(data.Remarks);
                $('#ctl00_MainContent_txtWarranty').val(data.Warranty);
                $('#ctl00_MainContent_txtDisclaimer').val(data.Disclaimer);
                $('#ctl00_MainContent_Freight').val(data.Frieght_Charges);
                $('#txtfreight_charges').val(data.Frieght_Charges);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlPOType').val(data.PO_Type).trigger('change');
                }, 1000)
                $('#ctl00_MainContent_ddlWorkOrder').val(data.Work_Order || '001').prop('disabled', data.Status === 'Approved');

                setTimeout(function () {
                    $('#ctl00_MainContent_ddlpayment').val(data.Payment_Terms).trigger('change');
                }, 1000)
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlDelivery').val(data.Delivery_Terms).trigger('change');
                }, 1000)
                $('#txtSub_Total').val(data.Sub_Total);
                $('#txtTotalDiscAmt').val(data.Discount);
                $('#ctl00_MainContent_txtTotalDiscAmt').val(data.Discount);
                $('#ctl00_MainContent_Net_Amount').val(data.PO_Amount);
                $('#txtst_amou').val(data.Total_ST_Amount);
                $('#ctl00_MainContent_txtStatus').val(data.Status);
                $('#chkManual').prop('checked', data.IsManual === true);
                $('#chkByDefault').prop('checked', data.IsByDefault === true);                
                $('#IsadvancewithTax').prop('checked', data.IsAdvancewithTax == 'true' || data.IsAdvancewithTax === true);
                LoadPOItemDetail(PO_ID);
                syncMetaBar();
                checkStatusButtons();

                if (data.IsEditableAfterApproval === true) {
                    $('#btnSave').prop('disabled', true);
                }
                $('#txtAdv_amou').val(data.Total_Adv_Amt);
                $('#txtFurther_amou').val(data.Total_Further_Amt);
                lastLoadedWarehouse = data.Ware_House || '';
                if ($('#ddlWarehouse option[value="' + lastLoadedWarehouse + '"]').length === 0) {
                    $('#ddlWarehouse').append($('<option>', {
                        value: data.Ware_House,
                        text: data.Ware_HouseText
                    }));
                }
                $('#ddlWarehouse').val(lastLoadedWarehouse).trigger('change');
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function checkStatusButtons() {
            var status = $('#ctl00_MainContent_txtStatus').val().trim();
            if (status == "Approved") {
                UserUnApproveButtonRights();
                $('#btnSave').attr("disabled", "disabled").hide();
                $('#btncancel').hide();
                $('#btnReplicate').hide();
            } else if (status == "Cancelled") {
                $('#btnSave').attr("disabled", "disabled").hide();
                $('#btncancel').hide();
                $('#btnReplicate').hide();
            } else if (status == "Created" || status == "Pending") {
                $('#btnSave').show();
                if (replicateEnabled) $('#btnReplicate').show();
                $('#btnUnApprove').hide();
                if (poid != "") {
                    CheckPOApprovalRightsAndShowButton(poid);
                }
            }
        }
      // ============================================================================
// HELPER FUNCTIONS (define once at top of your JS file)
// ============================================================================

        // ============================================================================
        // OPTIONAL: Chunked rendering for 500+ items (uncomment if needed)
        // ============================================================================
        /*
        function LoadPOItemDetail_Chunked(PO_ID, chunkSize = 50) {
            console.time('LoadPOItemDetail_Chunked');
            
            callPageMethod('getDDLlist', function (Tests) {
                var testsData = (typeof Tests === "string") ? JSON.parse(Tests) : Tests;
                var optionsSal = '', optionFed = '';
                if (testsData && testsData.forEach) {
                    testsData.forEach(function (item) {
                        var opt = '<option value="' + item.DataValueName + '">' + item.DataValueDescription + '</option>';
                        if (item.Type === "Sal") optionsSal += opt;
                        else optionFed += opt;
                    });
                }
        
                callPageMethod('LoadPOItemDetail', { PO_ID: PO_ID }, function (resp) {
                    var data = (typeof resp === "string") ? JSON.parse(resp) : resp;
                    if (!data || !data.forEach || data.length === 0) {
                        console.timeEnd('LoadPOItemDetail_Chunked');
                        return;
                    }
        
                    var tbody = $('#tblItemDescription tbody');
                    tbody.empty();
                    var index = 0;
        
                    function renderChunk() {
                        var end = Math.min(index + chunkSize, data.length);
                        var rowsHTML = [];
                        
                        for (; index < end; index++) {
                            var value = data[index];
                            var key = index;
                            var idx = key + 1;
                            
                            var TrnsDate = "";
                            if (value.Delivery_Date) {
                                try {
                                    var ms = parseInt(value.Delivery_Date.substring(6, 19));
                                    TrnsDate = $.datepicker.formatDate('dd M yy', new Date(ms));
                                } catch (e) { TrnsDate = ""; }
                            }
                            var pr_id = sanitizePrId(safeVal(value.pr_id, ""));
                            
                            // Build row (same structure as main function)
                            var row = '<tr data-index="' + idx + '">...</tr>'; // Reuse full row HTML from above
                            rowsHTML.push(row);
                        }
                        
                        tbody.append(rowsHTML.join(''));
                        
                        if (index < data.length) {
                            requestAnimationFrame(renderChunk); // Non-blocking
                        } else {
                            // Finalize after all chunks
                            data.forEach(function (value, key) {
                                var idx = key + 1;
                                $('#ddlSTAX' + idx).val(safeVal(value.SalTax_Id, 0));
                                $('#ddlFurtherTax' + idx).val(safeVal(value.FurtherTax_Percentage, 0));
                                $('#ddlAdvanceTax' + idx).val(safeVal(value.AdvanceTax_ID, 0));
                                $('#ddlFed' + idx).val(safeVal(value.FedPercent_Id, 0));
                            });
                            $('input.txtddate').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                            if (typeof calcTotal === 'function') calcTotal();
                            $('#btnSave').val('Update');
                            console.timeEnd('LoadPOItemDetail_Chunked');
                        }
                    }
                    renderChunk();
                }, function(error) {
                    console.timeEnd('LoadPOItemDetail_Chunked');
                    alert(error.get_message ? error.get_message() : error);
                });
            });
        }
        */
        //oldPOcode 16 march 


        //function LoadPOItemDetail(PO_ID) {
        //    var optionsSal = '';
        //    var optionFed = '';
        //    callPageMethod('getDDLlist', function (Tests) {
        //        $.each(JSON.parse(Tests), function (key, value) {
        //            if (value.Type == "Sal") {
        //                optionsSal += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
        //            }
        //            else {
        //                optionFed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
        //            }
        //        });
        //    });
        //    callPageMethod('LoadPOItemDetail', { PO_ID: PO_ID }, function (resp) {
        //        var data = (JSON.parse(resp));
        //        selectedOptions = data;
        //        var TrnsDate = '';
        //        $.each(data, function (key, value) {

        //            if (value.Delivery_Date != null) {
        //                TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Delivery_Date.substring(6, 19))));
        //            }
        //            else {
        //                TrnsDate = ""
        //            }
        //            if (value.Unit == null) value.Unit = "";
        //            if (value.UnitName == null) value.UnitName = "";
        //            if (value.SalTax_Id == null) value.SalTax_Id = 0;
        //            if (value.SalTax_Amount == null) value.SalTax_Amount = 0;
        //            if (value.Fed_Percentage == null) value.Fed_Percentage = 0;
        //            if (value.Discount_Amount == null) value.Discount_Amount = 0;
        //            if (value.Discount_Percentage == null) value.Discount_Percentage = 0;
        //            if (value.pr_id.includes("ERROR") || value.pr_id.includes("Execute") || value.pr_id.includes("There")) value.pr_id = "";
        //            if (value.CS_Ven_No == null) value.CS_Ven_No = "";
        //            if (value.PRDetailId == null) value.PRDetailId = 0;
        //            if (value.UOM_Qty == null) value.UOM_Qty = 0;

        //            var rowlength = $('#tblItemDescription tr').length;
        //            var row = '<tr>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" id="txtPRDId' + (key + 1) + '" name="txtPRDId" value="' + value.PRDetailId + '" />' + (key + 1) + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + (key + 1) + '"  value="' + value.pr_id + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + value.pr_id + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + (key + 1) + '"  value="' + value.CS_Ven_No + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px;"/>' + value.CS_Ven_No + '</td>' +
        //                '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + (key + 1) + '"  value="' + value.Item_Code + '" /> ' + value.Item_Code + ' </td>' +
        //                '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + (key + 1) + '"  value="' + value.Item_Name + '" /> ' + value.Item_Name + ' </td>' +
        //                '<td style="text-align:left!important;"><input type="hidden" name="txtUnit" id="txtUnit' + (key + 1) + '"  value="' + value.Unit + '" />' + value.Unit + ' </td>' +
        //                '<td><input type="text"  id="txtQty' + (key + 1) + '" name="txtQty" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" onkeyup="CulculateAmonutWithQty(this)" value=' + parseFloat(value.Qty).toFixed(2) + '></input></td>' +
        //                '<td><input type="text" id="txtUOMQty' + (key + 1) + '" name="txtUOMQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.UOM_Qty != null ? parseFloat(value.UOM_Qty).toFixed(2) : '0') + '" /></td>' +
        //                '<td><input type="text" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.Bonus_Qty != null ? parseFloat(value.Bonus_Qty).toFixed(2) : '0') + '" id="txtBonusQty' + (key + 1) + '" name="txtBonusQty" /></td>' +
        //                '<td><input type="text" name="txtRate" style="text-align:right ;width:50px !important;font-size:9px;height:20px" onkeyup="CulculateAmonutWithQty(this)" id="txtRate' + (key + 1) + '"  value="' + parseFloat(value.Rate).toFixed(2) + '" /></td>' +
        //                '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" readonly="readonly"  name="txtDisPer" id="txtDisPer' + (key + 1) + '"  value="' + value.Discount_Percentage + '" /></td>' +
        //                '<td style="text-align:right;padding-top: 7px!important;"><input type="text"  onkeyup="calcTotal()" value="' + value.Discount_Amount + '" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;"  id="txtDisAmount' + (key + 1) + '" name="txtDisAmount" ></input></td>' +
        //                '<td><select id="ddlSTAX' + (key + 1) + '" name="ddlSTAX" class="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"></select></td>' +
        //                '<td style="padding-top: 7px!important;"><input type="text" style="text-align:right!important;width:50px !important;font-size:9px;height:20px;" readonly="readonly" value="' + value.SalTax_Amount + '"  id="txtSalAmount' + (key + 1) + '" name="txtSalAmount" ></input></td>' +
        //            /*'<td><select id="ddlFurtherTax' + (key + 1) + '" name="ddlFurtherTax" class="ddlFurtherTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"><option value="0">0</option></select></td>' +*/
        //                '<td><input type="text" id="ddlFurtherTax' + (key + 1) + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;" value="' + (value.FurtherTax_Percentage != null ? value.FurtherTax_Percentage : '0') + '" /></td>' +
        //                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + (value.FurtherTax_Amount !== null && value.FurtherTax_Amount !== undefined ? value.FurtherTax_Amount : '0') + '" id="txtFurtherTaxAmount' + (key + 1) + '" name="txtFurtherTaxAmount"></td>' +
        //                '<td style="display:none;"><select id="ddlFed' + (key + 1) + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 9px;" ><option value="0">0</option>' + optionFed + '</select></td>' +
        //                '<td><select id="ddlAdvanceTax' + (key + 1) + '" name="ddlAdvanceTax" class="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;">' +
        //                '<option value="0">0</option>' +
        //                '</select></td>' +
        //                '<td><input type="text" readonly="readonly" style="width:50px !important;text-align:right;font-size:9px;height:20px;" ' +
        //                'value="' + value.AdvanceTax_Amount + '" id="txtAdvanceTaxAmount' + (key + 1) + '" name="txtAdvanceTaxAmount"></td>' +

        //                '<td style="padding-top: 7px!important;display:none;"><input type="hidden" value="' + value.Fed_Percentage + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;"  id="txtFedAmount' + (key + 1) + '" name="txtFedAmount" style="text-align:right ;width:59px !important;font-size:9px;height:20px;"></input>' + value.Fed_Percentage + '</td>' +
        //                '<td><input type="text" readonly style="width:50px!important;text-align:right;font-size:9px;height:20px;" value="' + (value.Bonus_Tax != null ? parseFloat(value.Bonus_Tax).toFixed(2) : '0') + '" id="txtBonusAmount' + (key + 1) + '" name="txtBonusAmount" /></td>' +
        //                '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="' + value.Amount + '" readonly="readonly"  id="txtTotalAmount' + (key + 1) + '" name="txtTotalAmount"></input></td>' +
        //                '<td><input type="text" name="txtddate" id="txtddate' + (key + 1) + '" value="' + TrnsDate + '" style="text-align:right ;width:64px !important;font-size:9px;height:20px;" /></td>' +
        //                '<td style="padding-top: 7px!important;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;" i=""></i></a> </td></tr>';
        //            $('#tblItemDescription tbody').append(row);

        //        });

        //        setTimeout(function () {
        //            $.each(selectedOptions, function (key, value) {
        //                $('#ddlSTAX' + (key + 1)).val(value.SalTax_Id).trigger('change');
        //                // $('#ddlFurtherTax' + (key + 1)).val(value.FurtherTax_Id).trigger('change');
        //                $('#ddlFurtherTax' + (key + 1)).val(value.FurtherTax_Percentage != null ? value.FurtherTax_Percentage : '0');
        //                $('#ddlAdvanceTax' + (key + 1)).val(value.AdvanceTax_ID).trigger('change');
        //                $("#ddlFed" + (key + 1)).val(value.FedPercent_Id);
        //                calcTotal();
        //            });
        //        }, 4500);
        //        setTimeout(function () {
        //            $.each(selectedOptions, function (key, value) {
        //                $('#txtAdvanceTaxAmount' + (key + 1)).val(value.AdvanceTax_Amount);
        //            });
        //        }, 4500);
        //        var count = $('#tblItemDescription tr').length - 1;
        //        for (i = 1; i <= count; i++) {
        //            $('#txtExpirDate' + i).datepicker();
        //        }
        //        $('input[name="txtddate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
        //        $('#btnSave').val('Update');
        //    },
        //        function (error) {
        //            alert(error.get_message());
        //        })
        //}
// ============================================================================
// HELPER FUNCTIONS (define once at top of your JS file)
// ============================================================================
// ============================================================================
// HELPER FUNCTIONS (Define once at top of your JS file)
// ============================================================================

// Safe value getter - handles null/undefined
// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
function safeVal(v, def) {
    return (v == null || v === undefined) ? def : v;
}

function sanitizePrId(val) {
    if (!val) return "";
    if (val.includes("ERROR") || val.includes("Execute") || val.includes("There")) {
        return "";
    }
    return val;
}

var calcTotalTimer = null;
var calcTotalRaf = null;
var CALC_TOTAL_TYPING_PAUSE_MS = 450;

function scheduleCalcTotal(delay) {
    var wait = (typeof delay === 'number') ? delay : CALC_TOTAL_TYPING_PAUSE_MS;

    if (calcTotalTimer) {
        clearTimeout(calcTotalTimer);
    }

    calcTotalTimer = setTimeout(function () {
        calcTotalTimer = null;

        if (window.requestAnimationFrame) {
            if (calcTotalRaf) {
                cancelAnimationFrame(calcTotalRaf);
            }
            calcTotalRaf = requestAnimationFrame(function () {
                calcTotalRaf = null;
                runCalcTotalCore();
            });
        } else {
            runCalcTotalCore();
        }
    }, wait);
}

        function calcTotal(forceNow) {
            if (forceNow === true) {
        runCalcTotalCore();
        return;
    }

    scheduleCalcTotal();
}

// ============================================================================
// MAIN: LoadPOItemDetail - FIXED for dropdown timing + calculations
// ============================================================================
// ============================================================================
// MAIN: LoadPOItemDetail - FIXED for Advance Tax loading in Edit Mode
// ============================================================================
        function LoadPOItemDetail(PO_ID) {
            console.time('LoadPOItemDetail');
            $('#tblItemDescription tbody').empty();

            // Show loader with progress bar
            showLoader('Loading Purchase Order Items...', true);

            callPageMethod('LoadPOItemDetail', { PO_ID: PO_ID },
                function (resp) {
                    var data = (typeof resp === "string") ? JSON.parse(resp) : resp;
                    if (!data || !Array.isArray(data) || data.length === 0) {
                        console.timeEnd('LoadPOItemDetail');
                        $('#btnSave').val('Update');
                        hideLoader();
                        return;
                    }

                    console.log('Loading ' + data.length + ' PO items...');
                    updateLoaderProgress(0, 'Building table with ' + data.length + ' items...');

                    // Build ALL rows in memory
                    var rowsHTML = [];
                    data.forEach(function (value, key) {
                        var idx = key + 1;

                        // Format date
                        var TrnsDate = "";
                        if (value.Delivery_Date) {
                            try {
                                var ms = parseInt(value.Delivery_Date.substring(6, 19));
                                TrnsDate = $.datepicker.formatDate('dd M yy', new Date(ms));
                            } catch (e) { TrnsDate = ""; }
                        }

                        var pr_id = sanitizePrId(safeVal(value.pr_id, ""));

                        // Build row
                        var row = '<tr data-index="' + idx + '">' +
                            '<td style=""><input type="hidden" id="txtPRDId' + idx + '" name="txtPRDId" value="' + safeVal(value.PRDetailId, 0) + '" />' + idx + '<\/td>' +
                            '<td style=""><input type="hidden" name="txtPRNo" id="txtPRNO' + idx + '" value="' + pr_id + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"/>' + pr_id + '<\/td>' +
                            '<td style="text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + idx + '" value="' + safeVal(value.CS_Ven_No, "") + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"/>' + safeVal(value.CS_Ven_No, "") + '<\/td>' +
                            '<td style="text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + idx + '" value="' + safeVal(value.Item_Code, "") + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;"/> ' + safeVal(value.Item_Code, "") + '  <\/td>' +
                            '<td style="text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + idx + '" value="' + safeVal(value.Item_Name, "") + '"/> ' + safeVal(value.Item_Name, "") + '  <\/td>' +
                            '<td style="text-align:left!important;"><input type="hidden" name="txtUnit" id="txtUnit' + idx + '" value="' + safeVal(value.Unit, "") + '" />' + safeVal(value.Unit, "") + '  <\/td>' +
                            '<td><input type="text" id="txtQty' + idx + '" name="txtQty" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" onkeyup="CulculateAmonutWithQty(this)" value="' + parseFloat(safeVal(value.Qty, 0)).toFixed(2) + '"/><\/td>' +
                            '<td><input type="text" id="txtUOMQty' + idx + '" name="txtUOMQty" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" value="' + parseFloat(safeVal(value.UOM_Qty, 0)).toFixed(2) + '" /><\/td>' +
                            '<td><input type="text" id="txtBonusQty' + idx + '" name="txtBonusQty" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" value="' + parseFloat(safeVal(value.Bonus_Qty, 0)).toFixed(2) + '" data-toggle="tooltip" data-placement="bottom" title="Enter Bonus quantity in Loose"/><\/td>' +
                            '<td><input type="text" name="txtRate" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" onkeyup="CulculateAmonutWithQty(this)" id="txtRate' + idx + '" value="' + parseFloat(safeVal(value.Rate, 0)).toFixed(2) + '" /><\/td>' +
                        /*'<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" readonly="readonly" name="txtDisPer" id="txtDisPer' + idx + '" value="' + safeVal(value.Discount_Percentage, 0) + '" /><\/td>' +*/
                            '<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtDisPer" onchange="calculateDiscountFromPercent(this)" onkeyup="calculateDiscountFromPercent(this)" id="txtDisPer' + idx + '" value="' + safeVal(value.Discount_Percentage, 0) + '" /><\/td>' +
                            '<td style="text-align:right;"><input type="text" onkeyup="calcTotal()" value="' + safeVal(value.Discount_Amount, 0) + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;text-align:right!important;" id="txtDisAmount' + idx + '" name="txtDisAmount"><\/input><\/td>' +
                            '<td><select id="ddlSTAX' + idx + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><option value="0">0</option><\/select><\/td>' +
                            '<td style=""><input type="text" style="text-align:right!important;width:100%!important;font-size:12px;font-weight:700;height:28px;" readonly="readonly" value="" id="txtSalAmount' + idx + '" name="txtSalAmount"><\/input><\/td>' +
                            '<td><input type="text" id="ddlFurtherTax' + idx + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" value="' + safeVal(value.FurtherTax_Percentage, 0) + '" /><\/td>' +
                            /*'<td><input type="text" readonly="readonly" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + safeVal(value.FurtherTax_Amount, 0) + '" id="txtFurtherTaxAmount' + idx + '" name="txtFurtherTaxAmount"><\/td>' +*/
                            '<td><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + safeVal(value.FurtherTax_Amount, 0) + '" id="txtFurtherTaxAmount' + idx + '" name="txtFurtherTaxAmount" onkeyup="calcFurtherTaxFromAmount(this)" data-manual="false"><\/td>' +
                            '<td><select id="ddlAdvanceTax' + idx + '" name="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><option value="0">0</option><\/select><\/td>' +
                            '<td><input type="text" readonly="readonly" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="" id="txtAdvanceTaxAmount' + idx + '" name="txtAdvanceTaxAmount"><\/td>' +
                            '<td style="display:none;"><select id="ddlFed' + idx + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;margin-left: 9px;" ><option value="0">0</option><\/select><\/td>' +
                            '<td style="display:none;"><input type="hidden" value="' + safeVal(value.Fed_Percentage, 0) + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" id="txtFedAmount' + idx + '" name="txtFedAmount"><\/input><\/td>' +
                            '<td><input type="text" readonly style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + parseFloat(safeVal(value.Bonus_Tax, 0)).toFixed(2) + '" id="txtBonusAmount' + idx + '" name="txtBonusAmount" /><\/td>' +
                            '<td style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + safeVal(value.Amount, 0) + '" readonly="readonly" id="txtTotalAmount' + idx + '" name="txtTotalAmount"><\/input><\/td>' +
                            '<td><input type="text" name="txtddate" id="txtddate' + idx + '" value="' + TrnsDate + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" /><\/td>' +
                            '<td style="text-align:center; font-weight:bold; color:#555;">' + (value.TotalStock != null ? value.TotalStock : '0') + '</td>' +
                            '<td style=" text-align:right;">' +
                            '<input type="text" readonly="readonly" id="txtLastPORate' + idx + '" name="txtLastPORate" ' +
                            'style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + parseFloat(safeVal(value.LastPORate, 0)).toFixed(2) + '" />' +
                            '</td>' +
                            '<td style=" text-align:center; font-size:12px;font-weight:700;"><input type="hidden" name="txtLastVendorName" value="' + (value.LastVendorName || '') + '" />' + (value.LastVendorName || '') + '</td>' + 
                            '<td style=""><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"><\/i><\/a>  <\/td>' +
                            '<\/tr>';
                        rowsHTML.push(row);
                    });

                    // SINGLE DOM insertion
                    $('#tblItemDescription tbody').html(rowsHTML.join(''));
                    console.log('DOM rendered, populating dropdowns...');
                    updateLoaderProgress(10, 'Loading tax rates for ' + data.length + ' items...');

                    // Track completion
                    let totalOperations = data.length * 2;
                    let completedOperations = 0;
                    let allValuesSet = false;

                    function checkAllComplete() {
                        completedOperations++;
                        var percentage = 10 + Math.floor((completedOperations / totalOperations) * 80);
                        updateLoaderProgress(percentage);

                        if (completedOperations >= totalOperations && !allValuesSet) {
                            allValuesSet = true;
                            console.log('All dropdowns populated, setting values...');
                            updateLoaderProgress(95, 'Setting values...');

                            // Set all dropdown values
                            data.forEach(function (value, key) {
                                var idx = key + 1;

                                // Set Sales Tax
                                var salTaxId = safeVal(value.SalTax_Id, "0") + "";
                                var $ddlSTAX = $('#ddlSTAX' + idx);
                                if ($ddlSTAX.length && $ddlSTAX.find('option[value="' + salTaxId + '"]').length > 0) {
                                    $ddlSTAX.val(salTaxId);
                                    $ddlSTAX.trigger('change');
                                }

                                // Set Advance Tax
                                var advTaxId = safeVal(value.AdvanceTax_ID, "0") + "";
                                var $ddlAdv = $('#ddlAdvanceTax' + idx);
                                if ($ddlAdv.length && $ddlAdv.find('option[value="' + advTaxId + '"]').length > 0) {
                                    $ddlAdv.val(advTaxId);
                                    $ddlAdv.trigger('change');
                                }

                                // Set other values
                                $('#ddlFurtherTax' + idx).val(safeVal(value.FurtherTax_Percentage, 0));
                                $('#txtFurtherTaxAmount' + idx).val(safeVal(value.FurtherTax_Amount, 0));
                                $('#ddlFed' + idx).val(safeVal(value.FedPercent_Id, 0));
                                $('#txtBonusAmount' + idx).val(parseFloat(safeVal(value.Bonus_Tax, 0)).toFixed(2));
                                $('#txtSalAmount' + idx).val(safeVal(value.SalTax_Amount, 0));
                                $('#txtAdvanceTaxAmount' + idx).val(safeVal(value.AdvanceTax_Amount, 0));
                                $('#txtTotalAmount' + idx).val(safeVal(value.Amount, 0));
                            });

                            // Initialize datepickers
                            $('input[name="txtddate"]').datepicker({
                                dateFormat: 'dd M yy'
                            }).attr('readonly', 'readonly');

                            $('[data-toggle="tooltip"]').tooltip();

                            // Final calculation
                            setTimeout(function () {
                                updateLoaderProgress(100, 'Finalizing...');
                                calcTotal();
                                $('#btnSave').val('Update');

                                setTimeout(function () {
                                    hideLoader();
                                    console.timeEnd('LoadPOItemDetail');
                                }, 500);
                            }, 300);
                        }
                    }

                    // Populate dropdowns
                    data.forEach(function (value, key) {
                        var idx = key + 1;
                        populateTaxddlWithProgress(idx, checkAllComplete);
                        populateAdvanceTaxddlWithProgress(idx, checkAllComplete);
                    });

                    // Safety timeout
                    setTimeout(function () {
                        if (!allValuesSet) {
                            console.warn('Loader timeout - forcing completion');
                            hideLoader();
                        }
                    }, 15000);
                },
                function (error) {
                    console.timeEnd('LoadPOItemDetail');
                    hideLoader();
                    alert(error.get_message ? error.get_message() : error);
                }
            );
        }

        function calculateDiscountFromPercent(anchor) {
            var $row = null;
            
            if (anchor && anchor.nodeType === 1) {
                $row = $(anchor).closest('tr');
            } else if (anchor !== undefined && anchor !== null) {
                var idx = (anchor + '').replace(/[^0-9]/g, '');
                if (idx) {
                    $row = $('#txtDisPer' + idx).closest('tr');
                }
            }

            if ($row && $row.length > 0) {
                var rawPer = $row.find('input[name=txtDisPer]').val();

                
                if (rawPer === '' || rawPer === null) {
                    $row.find('input[name=txtDisAmount]').val('');
                    scheduleCalcTotal();
                    return;
                }

                var rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var disPer = parseFloat(rawPer) || 0;
                var totalLineAmount = rate * qty;
                var disAmount = (totalLineAmount * disPer) / 100;
                $row.find('input[name=txtDisAmount]').val(disAmount.toFixed(2));
                scheduleCalcTotal();
            }
        }

        function populateTaxddlWithProgress(rowId, onComplete) {
            callPageMethod('getwtaxtype', function (response) {
                var options = '<option value="0">0</option>';
                try {
                    var taxData = JSON.parse(response);
                    $.each(taxData, function (key, value) {
                        options += '<option value="' + value.Sales_Tax_ID + '">' + value.Sales_Tax_Perc + '</option>';
                    });
                } catch (e) {
                    console.error('Error parsing tax data:', e);
                }
                $('#ddlSTAX' + rowId).html(options);
                if (onComplete && typeof onComplete === 'function') {
                    onComplete();
                }
            }, function (error) {
                console.error('Error loading Sales Tax:', error);
                if (onComplete && typeof onComplete === 'function') {
                    onComplete();
                }
            });
        }

        function populateAdvanceTaxddlWithProgress(rowId, onComplete) {
            callPageMethod('getAdvanceTaxType', function (response) {
                var options = '<option value="0">0</option>';
                try {
                    var taxData = JSON.parse(response);
                    $.each(taxData, function (key, value) {
                        options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                    });
                } catch (e) {
                    console.error('Error parsing advance tax data:', e);
                }
                $('#ddlAdvanceTax' + rowId).html(options);
                if (onComplete && typeof onComplete === 'function') {
                    onComplete();
                }
            }, function (error) {
                console.error('Error loading Advance Tax:', error);
                if (onComplete && typeof onComplete === 'function') {
                    onComplete();
                }
            });
        }

        function populateAdvanceTaxddl(rowId, callback) {
            populateAdvanceTaxddlWithPromise(rowId, callback);
        }
        function httpGet(theUrl) {
     
            
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function GetAccountCodeAndName() {
            var name = '';
            $.each($("#ctl00_MainContent_txtItem_Description").tokenInput('get'), function () {
                if (name != '') {
                    name += ",";
                }
                name += this.name;
            });
            $("#hdfitem_name").val(name);
        }
        function getprNoBy_WareHouse(item) {
            var optionsPR = '';
            var Warehouse;
            Warehouse = item.value;
            if (typeof Warehouse == "undefined" || Warehouse == "") {
                VendorId = item;
            }
            callPageMethod('GetPRNoByWarehouse', { Warehouse: Warehouse }, function (res) {
                var item = JSON.parse(res);
                optionsPR = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsPR += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsPR);
            });
        }
        function getprNoBy() {
            var optionsPR = '';
            var Warehouse;

            callPageMethod('GetPRNoBy', function (res) {
                var item = JSON.parse(res);
                optionsPR = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsPR += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsPR);
            });
        }
        var warehouseCond;
        var ProjCond;
        var projectionAnswered = false;
        var projectionChosen = false;
        var vendorChanging = false;

        function GetWareHouseCondition() {

            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#warehouse').show();
                    }
                    else {
                        $('#warehouse').hide();
                        getprNoBy();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }

        function GetprojectionCondition() {
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/Getprojection",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    ProjCond = JSON.parse(response.d);
                    if (ProjCond === '01') {
                        $('#projectiontype').show();
                        $('#projectiondate').show();

                        var existingPOId = '<%= Request.QueryString["PO_ID"] %>';
                if (existingPOId === '' || existingPOId === null) {
                    setTimeout(function () {
                        Swal.fire({
                            icon: 'question',
                            title: 'Projection',
                            text: 'Do you want to add a projection?',
                            showCancelButton: true,
                            confirmButtonText: 'Yes',
                            cancelButtonText: 'No',
                            confirmButtonColor: '#3085d6',
                            cancelButtonColor: '#aaa',
                            allowOutsideClick: false,
                            allowEscapeKey: false
                        }).then(function (result) {
                            projectionChosen = result.isConfirmed;
                            projectionAnswered = true;
                            if (!projectionChosen) {
                                // User said NO - hide projection fields
                                $('#projectiontype').hide();
                                $('#projectiondate').hide();
                            }
                        });
                    }, 800);
                } else {
                    projectionAnswered = true;
                    projectionChosen = false;
                }
            } else {
                $('#projectiontype').hide();
                $('#projectiondate').hide();
                projectionAnswered = true;
                projectionChosen = false;
            }
        },
        error: function (error) {
            console.error("Error fetching items", error);
            projectionAnswered = true;
            projectionChosen = false;
        }
    });
      }




    </script>
    <script type="text/javascript">
        function HideItemPopup() {
            document.getElementById('oItemPopup').style.display = "none";
            document.getElementById('oDarkScreen').style.display = "none";
        }
        function PerformPRSearch() {
            var PRId = $('#ctl00_MainContent_ddlPrNo').val();
            var optionFed = '';
            callPageMethod('getDDLlist', function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "Sal") {
                        optionsSal += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionFed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
            });
            if (PRId != "") {
                callPageMethod('getPurchaseByID', { PRID: PRId }, function (res) {
                    var item = JSON.parse(res);
                    var rows = '';
                    var iteration = 0;
                    $.each(item, function (key, value) {
                        if (value.Unit == null)
                            value.Unit = "";
                        if (value.UnitName == null)
                            value.UnitName = "";
                        if (value.Pack_Quantity == null)
                            value.Pack_Quantity = "";
                        if (value.Purchase_Rate == null) {
                            value.Purchase_Rate = 0;
                        }
                        iteration++;
                        var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                        rows += '<tr>' +
                            '<td style="padding-top:7px!important;""><input type="hidden" id="txtPRDId' + rowlength + '" name="txtPRDId" value="' + value.PR_Detail_ID + '" style="width: 75px !important;text-align:right" />' + rowlength + '</td>' +
                            '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + rowlength + '"  value="' + value.PR_ID + '"style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + value.PR_ID + '</td>' +
                            '<td style="padding-top: 7px!important;padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:right;font-size:9px;height:20px;"/> ' + value.Item_Code + ' </td>' +
                            '<td style="padding-left: 8px!important;padding-top: 7px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '"/> ' + value.Description + ' </td>' +
                            '<td> <input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '"  value="' + value.Unit + '" />' + value.UnitName + ' </td>' +
                            '<td><input type="text"  id="txtQty' + rowlength + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="' + value.Qty + '"/></input></td>' +
                            '<td><input type="text" id="txtUOMQty' + rowlength + '" name="txtUOMQty" style="text-align:right;width:50px!important;font-size:9px;height:20px;" value="' + (value.UOM_Qty != null ? parseFloat(value.UOM_Qty).toFixed(2) : '0') + '" /></td>' +
                            '<td>' + value.Pack_Quantity + '</td>' +
                            '<td><input type="text" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + rowlength + '"  value="' + value.Purchase_Rate + '" /></td>' +

                            '<td><input type="text" autocomplete="off" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" onkeyup="calcTotal()" name="txtDisPer" id="txtDisPer' + rowlength + '"  value="0" /></td>' +
                            '<td style="text-align:right;padding-top: 7px!important;"><input type="text" readonly="readonly" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;text-align:right!important;"  id="txtDisAmount' + rowlength + '" name="txtDisAmount" ></input></td>' +

                            '<td><select id="ddlSTAX' + rowlength + '" name="ddlSTAX" class="ddlSTAX" onchange="calcTotal()" style="margin-top: 4px;;text-align:right ;width:50px !important;font-size:9px;height:20px;margin-left: 9px;" ></select></td>' +
                            '<td style="padding-top: 7px!important;"><input type="text" readonly="readonly" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;" value="0"  id="txtSalAmount' + rowlength + '" name="txtSalAmount" ></input></td>' +
                            '<td style="display:none;"><select id="ddlFed' + rowlength + '" onchange="calcTotal()" style="text-align:right ;width:50px !important;font-size:9px;height:20px;margin-top: 4px;    margin-left: 6px;"><option value="0">0</option>' + optionFed + '</select></td>' +
                            '<td style="padding-top: 7px!important;display:none;"><input type="text" value="0" style="width: 50px !important;text-align:right;font-size:9px;height:20px;  id="txtFedAmount' + rowlength + '" name="txtFedAmount" style="width:50px !important;"></input></td>' +

                            '<td style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:20px;" value="0" readonly="readonly"  id="txtTotalAmount' + rowlength + '" name="txtTotalAmount"></input></td>' +
                            '<td><input type="text" name="txtddate" id="txtddate' + rowlength + '" style="width:50px !important;text-align:center;font-size:9px;height:20px;" /></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)">Delete</a> </td></tr>';
                    });
                    $('#tblItemDescription').append(rows);
                    $('input[name="txtddate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');

                    calcTotal();
                });
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select PR Number',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
        }
        
        function CulculateAmonut() {
            var amtwithdis = 0;
            var TotalAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var DisPer = 0;
                var Rate = parseFloat($($(value).find('td input[name=txtRate]')[0]).val()) || 0;
                var Qty = parseFloat($($(value).find('td input[name=txtQty]')[0]).val()) || 0;
                var DisAmt = parseFloat($($(value).find('td input[name=txtDisAmount]')[0]).val()) || 0;

                var Amount = Rate * Qty;
                if (DisAmt > 0 && Amount > 0) {
                    DisPer = parseFloat((DisAmt / Amount) * 100).toFixed(2);
                } else {
                    DisPer = 0;
                }
                $($(value).find('td input[name=txtDisPer]')[0]).val(DisPer);

                var finalNetAmount = Amount - DisAmt;

                TotalAmount += Amount;
                TotalNetAmount += finalNetAmount;
                TotalDiscountAmount += DisAmt;
            });

            amtwithdis = parseFloat(TotalAmount);
            $('#txtSub_Total').val(amtwithdis.toFixed(2));
            $('#ctl00_MainContent_Net_Amount').val(TotalNetAmount.toFixed(2));
            $('#ctl00_MainContent_txtTotalDiscAmt').val(TotalDiscountAmount.toFixed(2));
            $('#txtTotalDiscAmt').val(TotalDiscountAmount.toFixed(2));
        }

        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
                CulculateAmonut();
            }
        }
        function FillDepartments() {
            var optionsDPT = '';
            var optionInv = '';
            callPageMethod('getDDLlist', function (Tests) {
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "DPT") {
                        optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else {
                        optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddldept').html(optionsDPT);
                $('#ddlInv_org').html(optionInv);
            });
        }


        var lastLoadedWarehouse = '';
        function FillWarehouse() {

            var optionInv = '';
            callPageMethod('fillWarehouse', function (Tests) {

                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlWarehouse').html(optionInv);
                if (lastLoadedWarehouse) {
                $('#ddlWarehouse').val(lastLoadedWarehouse).trigger('change');
                savedBranch = data.Branch_Id;
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
                }
            });
        }

        function runCalcTotalCore() {
            var netAmount = 0;
            var totalstamount = 0;
            var totalAdvAmount = 0;
            var totalFurtherAmount = 0;
            var totamount = 0;
            var subtotal = 0;
            var totalfinalamount = 0;
            var TotalDiscAmount = 0;
            var totalBonusTax = 0;

            $('#tblItemDescription tbody tr').each(function (key, value) {
                var $row = $(value);


                //var DiscAmount = parseFloat($row.find('input[name=txtDisAmount]').val()) || 0;
                //if (DiscAmount < 0) {
                //    DiscAmount = 0;
                //    $row.find('input[name=txtDisAmount]').val(DiscAmount);
                //}

                var rawDisVal = $row.find('input[name=txtDisAmount]').val();
                var DiscAmount = (rawDisVal === '' || rawDisVal === null) ? 0 : (parseFloat(rawDisVal) || 0);

                
                if (DiscAmount < 0) {
                    DiscAmount = 0;
                    $row.find('input[name=txtDisAmount]').val('0.00');
                }
                //else if (rawDisVal !== '' && rawDisVal !== null) {
                    
                //    $row.find('input[name=txtDisAmount]').val(DiscAmount.toFixed(2));
                //}
                

                var Rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var Qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var amountExclusiveTaxes = Qty * Rate;
                var UomQty = parseFloat($row.find('input[name=txtUOMQty]').val()) || 1;
                var PerPice = Rate / UomQty;

                var rawPerVal = $row.find('input[name=txtDisPer]').val();
                var discpercent = 0;

                if (amountExclusiveTaxes > 0) {
                    discpercent = parseFloat((DiscAmount / amountExclusiveTaxes) * 100).toFixed(2);
                }

                if (rawPerVal !== '' && rawPerVal !== null) {
                    $row.find('input[name=txtDisPer]').val(discpercent);
                } else if (DiscAmount > 0) {
                    $row.find('input[name=txtDisPer]').val(discpercent);
                } else {
                    
                    $row.find('input[name=txtDisPer]').val('');
                }
                subtotal += amountExclusiveTaxes;

                // Get Sales Tax for THIS ROW - CRITICAL: Use the dropdown's selected value
                var $staxDropdown = $row.find('select[name=ddlSTAX]');
                var selectedSTAXText = $staxDropdown.find('option:selected').text();
                var STpercent = selectedSTAXText ? parseFloat(selectedSTAXText) || 0 : 0;

                // Get Advance Tax for THIS ROW - CRITICAL: Use the dropdown's selected value
                var $advTaxDropdown = $row.find('select[name=ddlAdvanceTax]');
                var selectedAdvTaxText = $advTaxDropdown.find('option:selected').text();
                var AdvPercent = selectedAdvTaxText ? parseFloat(selectedAdvTaxText) || 0 : 0;

                // Get Further Tax for THIS ROW
                var selectedFurtherTax = $row.find('input[name=ddlFurtherTax]').val() || 0;
                var FurtherPercent = parseFloat(selectedFurtherTax) || 0;

                // Calculate base amount after discount
                var baseAmount = amountExclusiveTaxes - DiscAmount;

                // Calculate Further Tax Amount
                //var FurtherAmount = parseFloat((FurtherPercent / 100) * baseAmount);
                //$row.find('input[name=txtFurtherTaxAmount]').val(FurtherAmount.toFixed(2));
                //totalFurtherAmount += FurtherAmount;

                
                var rawFurtherVal = $row.find('input[name=txtFurtherTaxAmount]').val();
                var FurtherAmount = parseFloat((FurtherPercent / 100) * baseAmount);

                
                if (rawFurtherVal !== '' && rawFurtherVal !== null) {
                    $row.find('input[name=txtFurtherTaxAmount]').val(FurtherAmount.toFixed(2));
                } else if (FurtherPercent > 0) {
                    $row.find('input[name=txtFurtherTaxAmount]').val(FurtherAmount.toFixed(2));
                } else {
                    $row.find('input[name=txtFurtherTaxAmount]').val('');
                    FurtherAmount = 0; 
                }
                totalFurtherAmount += FurtherAmount;


                var STAmount = parseFloat((STpercent / 100) * baseAmount);
                $row.find('input[name=txtSalAmount]').val(STAmount.toFixed(2));
                totalstamount += STAmount;
                var IsadvancewithTax = $('#IsadvancewithTax').is(':checked');
                var basamountwithStax = (baseAmount + STAmount);
                 if (IsadvancewithTax == 1){
                        var AdvAmount = parseFloat((AdvPercent / 100) * basamountwithStax);
                            $row.find('input[name=txtAdvanceTaxAmount]').val(AdvAmount.toFixed(2));
                            totalAdvAmount += AdvAmount;
                     }
                  else{
                         var AdvAmount = parseFloat((AdvPercent / 100) * baseAmount);
                             $row.find('input[name=txtAdvanceTaxAmount]').val(AdvAmount.toFixed(2));
                             totalAdvAmount += AdvAmount;
                      }
              



                var BonusQty = parseFloat($row.find('input[name=txtBonusQty]').val()) || 0;
                var bonusTaxTotal = 0;
                var isByDefault = $('#chkByDefault').is(':checked');

                if (BonusQty > 0 && !isByDefault) {
                    var bonusBase = BonusQty * PerPice;
                    var bonusST = (STpercent / 100) * bonusBase;
                    var bonusAdv = (AdvPercent / 100) * bonusBase;
                    bonusTaxTotal = bonusST + bonusAdv;
                }
                $row.find('input[name=txtBonusAmount]').val(bonusTaxTotal.toFixed(2));
                totalBonusTax += bonusTaxTotal;
                netAmount = parseFloat(amountExclusiveTaxes + STAmount + AdvAmount + FurtherAmount + bonusTaxTotal - DiscAmount);

                $row.find('input[name=txtTotalAmount]').val(netAmount.toFixed(2));
                totamount += netAmount;
                TotalDiscAmount += DiscAmount;
                totalfinalamount = totamount;
            });
            $('#txtSub_Total').val(subtotal.toFixed(2));
            $('#txtst_amou').val((totalstamount + totalAdvAmount + totalFurtherAmount).toFixed(2));
            $('#txtAdv_amou').val(totalAdvAmount.toFixed(2));
            $('#txtFurther_amou').val(totalFurtherAmount.toFixed(2));
            $('#txtBonusTaxTotal').val(totalBonusTax.toFixed(2));
            var freightTotal = parseFloat($('#ctl00_MainContent_Freight').val()) || 0;
            var totalFinalAmt = totalfinalamount + freightTotal;

            $('#ctl00_MainContent_Net_Amount').val(totalFinalAmt.toFixed(2));
            $('#ctl00_MainContent_txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtfreight_charges').val(freightTotal);
        }
        {
            var netAmount = 0;
            var STpercent = 0;
            var totalstamount = 0;
            var STAmount = 0;
            var DiscAmount = 0;
            var TotalDiscAmount = 0;
            var totamount = 0;
            var subtotal = 0;
            var totalfinalamount = 0;
            var totalAdvAmount = 0;
            var FurtherPercent = 0;
            var FurtherAmount = 0;
            var totalFurtherAmount = 0;
            var totalBonusTax = 0;

            // Loop through each row individually
            $('#tblItemDescription tbody tr').each(function (key, value) {
                var $row = $(value);

                // Get values for THIS SPECIFIC ROW only
                var DiscAmount = parseFloat($row.find('input[name=txtDisAmount]').val()) || 0;
                if (DiscAmount < 0) {
                    DiscAmount = 0;
                    $row.find('input[name=txtDisAmount]').val(DiscAmount);
                }

                var discpercent = 0;
                var Rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var Qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var amountExclusiveTaxes = Qty * Rate;
                var UomQty = parseFloat($row.find('input[name=txtUOMQty]').val()) || 1;
                var PerPice = Rate / UomQty;

                if (amountExclusiveTaxes > 0) {
                    discpercent = parseFloat((DiscAmount / amountExclusiveTaxes) * 100).toFixed(2);
                }
                $row.find('input[name=txtDisPer]').val(discpercent);
                subtotal += amountExclusiveTaxes;

                // Get Sales Tax for THIS ROW - CORRECTED
                var selectedSTAX = $row.find('select[name=ddlSTAX] option:selected').text();
                STpercent = selectedSTAX ? parseFloat(selectedSTAX) || 0 : 0;

                // Get Advance Tax for THIS ROW - CORRECTED
                var selectedAdvTax = $row.find('select[name=ddlAdvanceTax] option:selected').text();
                var AdvPercent = selectedAdvTax ? parseFloat(selectedAdvTax) || 0 : 0;

                // Get Further Tax for THIS ROW - CORRECTED
                var selectedFurtherTax = $row.find('input[name=ddlFurtherTax]').val() || 0;
                FurtherPercent = parseFloat(selectedFurtherTax) || 0;

                // Calculate Further Tax Amount
                var furtherAmountField = $row.find('input[name=txtFurtherTaxAmount]');
                var currentFieldValue = furtherAmountField.val();
                var calculatedAmount = parseFloat((FurtherPercent / 100) * (amountExclusiveTaxes - DiscAmount));

                if (FurtherPercent > 0 && (currentFieldValue === '' || currentFieldValue === '0' || currentFieldValue === '0.00')) {
                    furtherAmountField.val(calculatedAmount.toFixed(2));
                    FurtherAmount = calculatedAmount;
                } else if (FurtherPercent === 0) {
                    FurtherAmount = 0;
                } else {
                    FurtherAmount = parseFloat(currentFieldValue) || calculatedAmount;
                }
                totalFurtherAmount += FurtherAmount;

                // Calculate Advance Tax Amount
                var AdvAmount = parseFloat((AdvPercent / 100) * (amountExclusiveTaxes - DiscAmount));
                $row.find('input[name=txtAdvanceTaxAmount]').val(AdvAmount.toFixed(2));

                // Calculate Sales Tax Amount
                STAmount = parseFloat((STpercent / 100) * (amountExclusiveTaxes - DiscAmount));
                $row.find('input[name=txtSalAmount]').val(STAmount.toFixed(2));

                // Calculate Bonus Tax
                var BonusQty = parseFloat($row.find('input[name=txtBonusQty]').val()) || 0;
                var bonusTaxTotal = 0;
                var isByDefault = $('#chkByDefault').is(':checked');

                if (BonusQty > 0 && !isByDefault) {
                    var bonusBase = BonusQty * PerPice;
                    var bonusST = (STpercent / 100) * bonusBase;
                    var bonusAdv = (AdvPercent / 100) * bonusBase;
                    bonusTaxTotal = bonusST + bonusAdv;
                }
                $row.find('input[name=txtBonusAmount]').val(bonusTaxTotal.toFixed(2));
                totalBonusTax += bonusTaxTotal;

                // Calculate Net Amount for this row
                netAmount = parseFloat(amountExclusiveTaxes + STAmount + AdvAmount + FurtherAmount - DiscAmount);
                $row.find('input[name=txtTotalAmount]').val(netAmount.toFixed(2));

                // Accumulate totals
                totamount += netAmount;
                totalstamount += STAmount;
                totalAdvAmount += AdvAmount;
                TotalDiscAmount += DiscAmount;
                totalfinalamount = totamount;
            });

            // Update totals
            $('#txtSub_Total').val(subtotal.toFixed(2));
            $('#txtst_amou').val((totalstamount + totalAdvAmount + totalFurtherAmount).toFixed(2));
            $('#txtAdv_amou').val(totalAdvAmount.toFixed(2));
            $('#txtFurther_amou').val(totalFurtherAmount.toFixed(2));
            $('#txtBonusTaxTotal').val(totalBonusTax.toFixed(2));

            // Calculate final total with freight
            var freightTotal = parseFloat($('#ctl00_MainContent_Freight').val()) || 0;
            var totalFinalAmt = totalfinalamount + totalBonusTax + freightTotal;

            $('#ctl00_MainContent_Net_Amount').val(totalFinalAmt.toFixed(2));
            $('#ctl00_MainContent_txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtTotalDiscAmt').val(TotalDiscAmount.toFixed(2));
            $('#txtfreight_charges').val(freightTotal);
        }

        function calcFurtherTaxFromAmount(anchor) {
            var row = $(anchor).closest('tr');
            $(anchor).attr('data-manual', 'true');

            var Rate = parseFloat(row.find('input[name=txtRate]').val()) || 0;
            var Qty = parseFloat(row.find('input[name=txtQty]').val()) || 0;
            var DiscAmount = parseFloat(row.find('input[name=txtDisAmount]').val()) || 0;
            var enteredAmount = parseFloat($(anchor).val()) || 0;

            var base = (Qty * Rate) - DiscAmount;
            var calculatedPercent = 0;

            if (base > 0 && enteredAmount >= 0) {
                calculatedPercent = parseFloat((enteredAmount / base) * 100).toFixed(2);
            }

            row.find('input[name=ddlFurtherTax]').val(calculatedPercent);
            row.find('input[name=txtFurtherTaxAmount]').attr('data-manual', 'false');

            scheduleCalcTotal();
        }

        function CulculateAmonutWithQty(anchor) {
            var $row = null;

            if (anchor && anchor.nodeType === 1) {
                $row = $(anchor).closest('tr');
            } else if (anchor !== undefined && anchor !== null) {
                var idx = (anchor + '').replace(/[^0-9]/g, '');
                if (idx) {
                    $row = $('#txtQty' + idx).closest('tr');
                }
            }

            if ($row && $row.length > 0) {
                var rawDisAmount = $row.find('input[name=txtDisAmount]').val();
                var disAmount = (rawDisAmount === '' || rawDisAmount === null) ? 0 : (parseFloat(rawDisAmount) || 0);

                var rate = parseFloat($row.find('input[name=txtRate]').val()) || 0;
                var qty = parseFloat($row.find('input[name=txtQty]').val()) || 0;
                var amount = rate * qty;
                var disPer = 0;

                if (amount > 0) {
                    disPer = parseFloat((disAmount / amount) * 100).toFixed(2);
                }

                $row.find('input[name=txtDisPer]').val(disPer);
            }

            scheduleCalcTotal();
        }


        function validateSave() {
            $("#btnSave").prop("disabled", true);
            var proceed = true;
            var table = $('#tblItemDescriptionDetail');
            var Vendor = $('#ctl00_MainContent_ddlVendor').val();
            var Warehouse = $('#ddlWarehouse').val();
            var PaymentTerms = $('#ctl00_MainContent_ddlpayment').val();
            var PDate = $('#ctl00_MainContent_txtPurchase_Date').val();
            var dueDate = $('#ctl00_MainContent_txtdueDate').val();
            var PurchaseDate = new Date(PDate).setHours(0, 0, 0, 0);
            var DueDate = new Date(dueDate).setHours(0, 0, 0, 0);
            if (PurchaseDate > DueDate) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Due Date must be greater than Purchase Date',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }

            //if (Warehouse == '0') {
            //    Swal.fire({
            //        icon: 'error',
            //        title: 'Error!',
            //        text: 'Please Select Warehouse',
            //        showConfirmButton: false,
            //        timer: 2000,
            //        customClass: {
            //            popup: 'swal-big-popup',
            //            title: 'swal-big-title',
            //            htmlContainer: 'swal-big-text'
            //        }
            //    });
            //    return false;
            //}

            if (Vendor == '0') {
                $("#ctl00_MainContent_ddlVendor").addClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlVendor-container').parent().css('border-color', 'red');
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Vendor',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#ctl00_MainContent_ddlVendor').select2().focus();
                $('#ctl00_MainContent_ddlVendor').select2('open');

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }
            else {
                $("#ctl00_MainContent_ddlVendor").removeClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlVendor-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (PaymentTerms == '0') {
                $("#ctl00_MainContent_ddlpayment").addClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlpayment-container').parent().css('border-color', 'red');
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Mode of Payment',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#ctl00_MainContent_ddlpayment').select2().focus();
                $('#ctl00_MainContent_ddlpayment').select2('open');

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                proceed = false;
                return false;
            }
            else {
                $("#ctl00_MainContent_ddlpayment").removeClass('ErrorAlert');
                $('#select2-ctl00_MainContent_ddlpayment-container').parent().css('border-color', 'rgb(206, 191, 191)');
            }
            if (document.getElementById('tblItemDescription').rows.length == 1) {
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Items List Should have Items.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false).removeAttr("disabled");
                return false;
            }
            else if (document.getElementById('tblItemDescription').rows.length > 1) {
                table.find('tr').each(function (key, value) {
                    var Qty = $(value).find('td input[name=txtQty]').val();
                    var Rate = $(value).find('td input[name=txtRate]').val();
                    var UOM_Qty = $(value).find('td input[name=txtUOMQty]').val();

                    if (Qty == 0 || Qty == "" || Qty < 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Qty or Qty Greater than zero',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    }
                    else if (Rate == 0 || Rate == "" || Rate < 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Rate or Rate Greater than zero',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        
                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    }
                    if (UOM_Qty == "0" || UOM_Qty == "" || parseFloat(UOM_Qty) <= 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please add UOM_Qty',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $("#btnSave").prop("disabled", false).removeAttr("disabled");
                        return false;
                    }
                });
            }


            return proceed;
        }
        function SaveAllRecord() {
            $("#btnSave").prop("disabled", true);
            calcTotal(true);
            if (validateSave()) {
                var status;
                var btnSave = $('#btnSave').val();
                var RefNo = $('#ctl00_MainContent_txtPurchase_Reference').val();
                var VendorName = $('#ctl00_MainContent_ddlVendor').val();
                var Remarks = $('#ctl00_MainContent_txtRemarks').val();
                var Warranty = $('#ctl00_MainContent_txtWarranty').val();
                var Disclaimer = $('#ctl00_MainContent_txtDisclaimer').val();
                var Purchase_No = $('#ctl00_MainContent_txtPurchase_No').val();
                var Purchase_Date = $('#ctl00_MainContent_txtPurchase_Date').val();
                var Due_Date = $('#ctl00_MainContent_txtdueDate').val();
                var table = $('#tblItemDescriptionDetail');
                var SubTotal = $('#txtSub_Total').val();
                var DiscountAmount = $('#txtTotalDiscAmt').val();
                var NetAmount = $('#ctl00_MainContent_Net_Amount').val();
                var PaymentTerms = $('#ctl00_MainContent_ddlpayment').val();
                var Warehouse = $('#ddlWarehouse').val();
                var Branch = $('#ddlBranch').val();
                var Term_ID = $('#ctl00_MainContent_ddlTerm').val();
                var DeliveryTerms = $('#ctl00_MainContent_ddlDelivery').val();
                var Freight = $('#ctl00_MainContent_Freight').val();
                var POType = $('#ctl00_MainContent_ddlPOType').val();
                var WorkOrder = $('#ctl00_MainContent_ddlWorkOrder').val() || '001';
                var PO_ID = $('#hdnPurchase_ID').val();
                var transtype = $('#txttranstype').val();
                var txtcsmasterid = $('#txtcsmasterid').val();
                var txtst_amou = $('#txtst_amou').val();
                var Adv_amount = $('#txtAdv_amou').val();
                var Further_amount = $('#txtFurther_amou').val();
                var ProjectionDate = $('#ctl00_MainContent_txtProjection_Date').val();
                var ProjectionType = $('#ctl00_MainContent_ddlprojection').val();
                var IsManual = $('#chkManual').is(':checked');
                var IsAdvanceWithTax = $('#IsadvancewithTax').is(':checked');
                var IsByDefault = $('#chkByDefault').is(':checked');
                var Item_list = [];
                if (Purchase_No == "(New)" || Purchase_No == "")
                    Purchase_No = "0";
                table.find('tr').each(function (key, value) {
                    var PurchaseDate = new Date(Purchase_Date).setHours(0, 0, 0, 0);
                    var DeliveryDate = new Date($(value).find('td input[name=txtddate]').val()).setHours(0, 0, 0, 0);
                    if (PurchaseDate > DeliveryDate) {
                        status = false;
                    }
                    else {
                        Item_list.push({
                            'PRDetailId': $(value).find('td input[name=txtPRDId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'ItemName': $(value).find('td input[name=txtItemName]').val(), 'Unit': $(value).find('td input[name=txtUnit]').val(), 'BonusQty': $(value).find('td input[name=txtBonusQty]').val(), 'Qty': $(value).find('td input[name=txtQty]').val(), 'UOM_Qty': $(value).find('td input[name=txtUOMQty]').val(), 'Rate': $(value).find('td input[name=txtRate]').val(), 'DisPer': $(value).find('td input[name=txtDisPer]').val(), 'DisAmount': $(value).find('td input[name=txtDisAmount]').val(), 'Amount': $(value).find('td input[name=txtTotalAmount]').val(), 'FedPercentId': $("#ddlFed" + (key + 1) + " option:selected").val(), 'Fed_Percentage': $($(value).find('td')[11]).text(), 'SalTax_Id': $("#ddlSTAX" + (key + 1) + " option:selected").val(), 'AdvanceTax_ID': $("#ddlAdvanceTax" + (key + 1) + " option:selected").val(), 'SalTax_Amount': $(value).find('td input[name=txtSalAmount]').val(), 'DateTime': $(value).find('td input[name=txtddate]').val(), 'AdvanceTax_Amount': $(value).find('td input[name=txtAdvanceTaxAmount]').val(), 'FurtherTax_Id': 0, 'FurtherTax_Percentage': $($(value).find('td input[name=ddlFurtherTax]')[0]).val() || 0, 'BonusTax': $(value).find('td input[name=txtBonusAmount]').val(),
                            'FurtherTax_Amount': $(value).find('td input[name=txtFurtherTaxAmount]').val(),
                            'LastPORate': $(value).find('td input[name=txtLastPORate]').val(), 'LastVendorName': $(value).find('td input[name=txtLastVendorName]').val(),

                        });
                    }
                });

                if (status == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Delivery Date must be greater than Purchase Date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $("#btnSave").prop("disabled", false).removeAttr("disabled");
                    return false;
                }
                else {
                    var AllItemDetail = {
                        'txtst_amou': txtst_amou, 'Adv_amount': Adv_amount, 'transtype': transtype, 'txtcsmasterid': txtcsmasterid, 'PO_ID': PO_ID, 'SubTotal': SubTotal, 'DiscountAmount': DiscountAmount, 'NetAmount': NetAmount, 'Purchase_Date': Purchase_Date, 'Purchase_No': Purchase_No, 'RefNo': RefNo, 'VendorName': VendorName, 'Remarks': Remarks, 'Warranty': Warranty, 'Disclaimer': Disclaimer, 'PaymentTerms': PaymentTerms, 'Term_ID': Term_ID, 'DeliveryTerms': DeliveryTerms, 'FreightCharges': Freight, 'POType': POType, 'WorkOrder': WorkOrder, 'Due_Date': Due_Date, 'ItemList': Item_list, 'Warehouse': Warehouse, 'Branch': Branch, 'Further_amount': Further_amount, 'ProjectionDate': ProjectionDate,'ProjectionType': ProjectionType, 'IsManual': IsManual,
                        'IsByDefault': IsByDefault, 'IsAdvanceWithTax': IsAdvanceWithTax };
                    var saveCompleted = false;
                    // Safety net: never leave the button disabled / modal open forever if the server hangs
                    var saveWatchdog = setTimeout(function () {
                        if (saveCompleted) return;
                        saveCompleted = true;
                        Swal.close();
                        $('#btnSave').prop('disabled', false).removeAttr('disabled');
                        Swal.fire({
                            icon: 'warning',
                            title: 'Still saving...',
                            text: 'The server is taking longer than expected. Please check the Purchase Order list before saving again, to avoid a duplicate.',
                            confirmButtonText: 'OK'
                        });
                    }, 90000);
                    Swal.fire({
                        title: 'Saving...',
                        text: 'Please wait, do not close or refresh the page.',
                        allowOutsideClick: false,
                        allowEscapeKey: false,
                        showConfirmButton: false,
                        didOpen: function () { Swal.showLoading(); }
                    });
                    callPageMethod('SavePurchaseItemDetail', { btnSave: btnSave, AllItemDetail: JSON.stringify(AllItemDetail) }, function (res) {
                        saveCompleted = true;
                        clearTimeout(saveWatchdog);
                        // Attachment upload must never block the redirect, or the form appears frozen
                        try { sendFile(res); } catch (e) { console.error(e); }
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Save Successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location = "PurchaseOrder.aspx?PO_ID=" + res;
                    }, function (error) {
                        // Without this, a failed/timed-out save left the button disabled and the page unresponsive
                        saveCompleted = true;
                        clearTimeout(saveWatchdog);
                        Swal.close();
                        $('#btnSave').prop('disabled', false).removeAttr('disabled');
                        Swal.fire({ icon: 'error', title: 'Save failed', text: 'An error occurred while saving. Please check the Purchase Order list before saving again.', confirmButtonText: 'OK' });
                    });
                }
            }
        }

        function UnApprove() {
            var POid = '<% =Request.QueryString["PO_ID"] %>';
            callPageMethod('UnApprovePO', { POid: POid }, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }

        function CheckPOApprovalRightsAndShowButton(poId) {
            callPageMethod('CheckPOApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetPOApprovalInfo', { POId: poId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                            $('#btnApprove').data('po-amount', info.POAmount);
                            $('#btnApprove').data('remaining-amount', info.RemainingAmount);
                            $('#btnApprove').data('budget-enabled', info.BudgetEnabled);
                        }
                    });
                }
            });
        }

        function ApprovePOFromEdit() {
            var poId = poid;
            var poAmount = $('#btnApprove').data('po-amount');
            var remainingAmount = $('#btnApprove').data('remaining-amount');
            var budgetEnabled = $('#btnApprove').data('budget-enabled');

            var confirmHtml = 'Are you sure you want to approve PO #' + $('#ctl00_MainContent_txtPurchase_No').val() + '?';
            if (budgetEnabled) {
                confirmHtml += '<br><br>PO Amount: <strong>' + parseFloat(poAmount).toFixed(2) + '</strong>';
                confirmHtml += '<br>Remaining Budget: <strong>' + parseFloat(remainingAmount).toFixed(2) + '</strong>';
            }

            Swal.fire({
                title: 'Approve PO?',
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
                    callPageMethod('ApproveSinglePO', { POId: poId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Approved!',
                                text: 'PO has been approved successfully.',
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
                                text: resp,
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

        function Cancel() {
            var POid = '<%= Request.QueryString["PO_ID"] %>';
            callPageMethod('CancelEntry', { POid: POid }, function (response) {
                try {
                    var message = JSON.parse(response);
                    if (message.error) {
                        alert("Error Occurred While Cancelling: " + message.error);
                    } else if (message[0].Column1 == "1") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'PO Cancelled Successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        location.reload();
                    } else {
                        alert("Unexpected response format");
                    }
                } catch (error) {
                    alert("Error parsing server response: " + error.message);
                }
            });
        }


        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/UserUnApproveEntryRights",
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
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to retrieve User UnApprove Button Rights.',
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
        function sendFile(ID) {
            var fileInput = $('#chosePofile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#chosePofile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadPOFiles.ashx',
                    data: data,
                    success: function (status) {

                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert(" something went wrong!");
                    }
                });
            }
        }

        // Load items from INV_Items table into search modal
        function LoadAllitem(searchText) {
            var warehouseId = $("#ddlWarehouse").val();
            $.ajax({
                type: "POST",
                url: "PurchaseOrder.aspx/GetAllitem",
                data: JSON.stringify({ searchText: searchText, warehouseId: warehouseId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var items = JSON.parse(response.d);
                    var tableBody = $('#itemsTableBody');
                    tableBody.empty();
                    $.each(items, function (index, item) {
                        var row = '<tr>' +
                            '<td><input type="checkbox" class="itemCheckbox" onclick="appendSearchItem(this)"></td>' +
                            '<td style="display:none;">' + item.Item_ID + '</td>' +
                            '<td>' + item.Item_Code + '</td>' +
                            '<td>' + item.Description + '</td>' +
                            '<td>' + item.Unit + '</td>' +
                            '<td style="display:none;">' + (item.Purchase_Rate || 0) + '</td>' +
                            '<td style="display:none;">' + (item.UOM_Qty || 1) + '</td>' +
                            '<td style="">' + (item.Last_PO_Rate) + '</td>' +
                            '<td>' + (item.TotalStock || 0) + '</td>' +
                            '<td>' + (item.Last_Vendor_Name || '') + '</td>' + 
                            '</tr>';
                        tableBody.append(row);
                    });
                    $('#itemsModal').modal('show');
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                    Swal.fire({ icon: 'error', title: 'Error', text: 'Failed to load items.' });
                }
            });
        }

        var currentProjectionType = '';

        // Call this when projection type changes
        var currentProjectionType = '';
        var isProcessingProjection002 = false;

        // Call this when projection type changes
        function onProjectionTypeChange() {
            currentProjectionType = $('#ctl00_MainContent_ddlprojection').val();

            if (currentProjectionType === '002') {
                var projectionDate = $('#ctl00_MainContent_txtProjection_Date').val();
                var warehouseId = $('#ddlWarehouse').val();

                if (!projectionDate || projectionDate.trim() === '') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Projection Date Required',
                        text: 'Please select a Projection Date before adding items for Projection Type 002.',
                        confirmButtonText: 'Select Date',
                        showCancelButton: true,
                        cancelButtonText: 'Cancel'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            $('#ctl00_MainContent_txtProjection_Date').focus();
                            $('#ctl00_MainContent_txtProjection_Date').datepicker('show');
                        }
                    });
                } else if (!warehouseId || warehouseId === '0') {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Warehouse Required',
                        text: 'Please select a Warehouse before adding items for Projection Type 002.',
                        confirmButtonText: 'OK'
                    });
                } else {
                    // Optional: Show info message that projection type 002 is active
                    Swal.fire({
                        icon: 'info',
                        title: 'Projection Type 002 Active',
                        text: 'Quantities will be auto-loaded from consumption data between Projection Date and current date.',
                        timer: 2000,
                        showConfirmButton: false
                    });
                }
            }
        }
        // Modified appendSearchItem function with projection type 002 support
        function appendSearchItem(anchor) {

            // Check for projection type 002 requirements before adding item
            var projectionType = $('#ctl00_MainContent_ddlprojection').val();
            var projectionDate = $('#ctl00_MainContent_txtProjection_Date').val();
            var warehouseId = $('#ddlWarehouse').val();

            if (projectionType === '002') {
                if (!projectionDate || projectionDate.trim() === '') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Cannot Add Item!',
                        text: 'Please select a Projection Date first before adding items.',
                        confirmButtonText: 'Select Date',
                        showCancelButton: true,
                        cancelButtonText: 'Cancel'
                    }).then((result) => {
                        if (result.isConfirmed) {
                            $('#ctl00_MainContent_txtProjection_Date').focus();
                            $('#ctl00_MainContent_txtProjection_Date').datepicker('show');
                        }
                    });
                    $(anchor).prop('checked', false);
                    return false;
                }

                if (!warehouseId || warehouseId === '0') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Cannot Add Item!',
                        text: 'Please select a Warehouse first before adding items for Projection Type 002.',
                        confirmButtonText: 'OK'
                    });
                    $(anchor).prop('checked', false);
                    return false;
                }
            }

            var row = $(anchor).closest('tr');
            var item_id = $(row).find('td:eq(1)').text().trim();
            var item_code = $(row).find('td:eq(2)').text().trim();
            var item_name = $(row).find('td:eq(3)').text().trim();
            var unit = $(row).find('td:eq(4)').text().trim();
            var rate = $(row).find('td:eq(5)').text().trim() || '0';
            var uom_qty = $(row).find('td:eq(6)').text().trim() || '1';
            var last_po_rate = $(row).find('td:eq(7)').text().trim() || '0';


            var total_stock = $(row).find('td:eq(8)').text().trim() || '0';
            var last_vendor_name = $(row).find('td:eq(9)').text().trim() || '';
            var isChecked = $(anchor).prop('checked');

            if (!isChecked) {
                $('#tblItemDescription tbody tr').each(function () {
                    if ($(this).find('input[name=txtItemCode]').val() === item_code) {
                        $(this).remove();
                    }
                });
                calcTotal();
                return;
            }

            var exists = false;
            $('#tblItemDescription tbody tr').each(function () {
                if ($(this).find('input[name=txtItemCode]').val() === item_code) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already added!',
                    timer: 2000,
                    showConfirmButton: false
                });
                $(anchor).prop('checked', false);
                return;
            }

            var length = $("#tblItemDescription tr:gt(0)").length + 1;
            var defaultQty = '1';

            // For projection type 002, set default to 0 and show loading indicator
            if (projectionType === '002' && projectionDate && warehouseId && warehouseId !== '0') {
                defaultQty = '0';

                // Show loading indicator in the quantity field
                Swal.fire({
                    title: 'Loading...',
                    text: 'Fetching consumption data for this item...',
                    allowOutsideClick: false,
                    allowEscapeKey: false,
                    showConfirmButton: false,
                    didOpen: () => {
                        Swal.showLoading();
                    }
                });
            }

            var newRow = '<tr>' +
                '<td style=""><input type="hidden" id="txtPRDId' + length + '" name="txtPRDId" value="0" />' + length + '</td>' +
                '<td style=""><input type="hidden" name="txtPRNo" id="txtPRNO' + length + '" value="" /></td>' +
                '<td style="text-align:right!important;"><input type="hidden" name="txtcsno" id="txtcsno' + length + '" value="" /></td>' +
                '<td style="text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + length + '" value="' + item_code + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;"/> ' + item_code + '   </td>' +
                '<td style="text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '" value="' + item_name + '"/> ' + item_name + '   </td>' +
                '<td style="text-align:left!important;"> <input type="hidden" name="txtUnit" id="txtUnit' + length + '" value="' + unit + '" />' + unit + '   </td>' +
                '<td><input type="text" id="txtQty' + length + '" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtQty" onkeyup="CulculateAmonutWithQty(this)" value="' + defaultQty + '"/></td>' +
                '<td><input type="text" id="txtUOMQty' + length + '" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtUOMQty" value="' + uom_qty + '" /></td>' +
                '<td><input type="text" id="txtBonusQty' + length + '" style="text-align:right;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtBonusQty" value="0" data-toggle="tooltip" data-placement="bottom" title="Enter Bonus quantity in Loose"/></td>' +
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" onkeyup="CulculateAmonutWithQty(this)" name="txtRate" id="txtRate' + length + '" value="' + rate + '" /></td>' +
                /*'<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtDisPer" readonly="readonly" id="txtDisPer' + length + '" value="0" /></td>' +*/
                '<td><input type="text" autocomplete="off" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" name="txtDisPer" onchange="calculateDiscountFromPercent(this)" onkeyup="calculateDiscountFromPercent(this)" id="txtDisPer' + length + '" value="0" /></td>' +
                '<td style="text-align:right;"><input type="text" onkeyup="calcTotal()" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;text-align:right!important;" id="txtDisAmount' + length + '" name="txtDisAmount" value="0"></input></td>' +
                '<td><select id="ddlSTAX' + length + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><option value="0">0</option></select></td>' +
                '<td style="text-align:right!important"><input type="text" style="text-align:right!important; width:100%!important;font-size:12px;font-weight:700;height:28px;" value="0" readonly="readonly" id="txtSalAmount' + length + '" name="txtSalAmount" /></td>' +
                '<td><input type="text" id="ddlFurtherTax' + length + '" name="ddlFurtherTax" onkeyup="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;" value="0" /></td>' +
                /*'<td><input type="text" readonly="readonly" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount"></td>' +*/
                '<td><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtFurtherTaxAmount' + length + '" name="txtFurtherTaxAmount" onkeyup="calcFurtherTaxFromAmount(this)" data-manual="false"></td>' +
                '<td><select id="ddlAdvanceTax' + length + '" name="ddlAdvanceTax" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><option value="0">0</option></select></td>' +
                '<td><input type="text" readonly="readonly" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtAdvanceTaxAmount' + length + '" name="txtAdvanceTaxAmount"></td>' +
                '<td style="display:none;"><select id="ddlFed' + length + '" onchange="calcTotal()" style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;margin-left: 6px;"><option value="0">0</option></select></td>' +
                '<td style="display:none;"><input type="text" value="0" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" id="txtFedAmount' + length + '" name="txtFedAmount"></input></td>' +
                '<td><input type="text" readonly style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" id="txtBonusAmount' + length + '" name="txtBonusAmount" /></td>' +
                '<td style="text-align:right ;width:100%!important;font-size:12px;font-weight:700;height:28px;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="0" readonly="readonly" id="txtTotalAmount' + length + '" name="txtTotalAmount"></input></td>' +
                '<td><input type="text" name="txtddate" id="txtddate' + length + '" class="row-date-picker" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" /></td>' +
                '<td style="text-align:center; font-weight:bold; color:#555;">' + total_stock + '</td>' +
                '<td style=" text-align:right;">' +
                '<input type="text" readonly="readonly" id="txtLastPORate' + length + '" name="txtLastPORate" ' +
                'style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" value="' + last_po_rate + '" />' +
                '</td>' +
                '<td style=" text-align:center; font-size:12px;font-weight:700;"><input type="hidden" name="txtLastVendorName" value="' + (last_vendor_name || '') + '" />' + last_vendor_name + '</td>' +
                '</td>' +
                '<td style=""><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: -10px;"></i></a>   </td>' +
                '</tr>';

            $('#tblItemDescription tbody').append(newRow);

            initializeDatePickers();
            populateTaxddl(length);

            // Populate Advance Tax dropdown
            PageMethods.getAdvanceTaxType(function (response) {
                var options = '<option value="0">0</option>';
                try {
                    var taxData = JSON.parse(response);
                    $.each(taxData, function (key, value) {
                        options += '<option value="' + value.Advance_Tax_ID + '">' + value.Advance_Tax_Perc + '</option>';
                    });
                } catch (e) {
                    console.error('Error parsing advance tax data:', e);
                }
                $('#ddlAdvanceTax' + length).html(options);
            }, function (error) {
                console.error('Error loading Advance Tax:', error);
            });

            populateFurtherTaxddl(length);
            $('[data-toggle="tooltip"]').tooltip();

            setTimeout(function () {
                $('#txtddate' + length).datepicker({
                    dateFormat: 'dd M yy',
                    changeMonth: true,
                    changeYear: true,
                    showButtonPanel: true
                }).attr('readonly', 'readonly').focus(function () {
                    $(this).datepicker('show');
                });
            }, 100);

            // If projection type is 002, fetch consumed quantity
            if (projectionType === '002' && projectionDate && warehouseId && warehouseId !== '0') {
                var itemIdsArray = [parseInt(item_id)];

                $.ajax({
                    type: "POST",
                    url: "PurchaseOrder.aspx/GetProjectedConsumptionForItems",
                    data: JSON.stringify({
                        itemIdsJson: JSON.stringify(itemIdsArray),
                        projectionDate: projectionDate,
                        warehouseId: warehouseId
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        Swal.close(); // Close the loading Swal

                        var consumedQtys = JSON.parse(response.d);
                        var consumedQty = consumedQtys[item_id] || 0;

                        if (consumedQty > 0) {
                            // Convert to integer (remove decimal places)
                            var intQty = Math.floor(consumedQty);
                            $('#txtQty' + length).val(intQty);
                            CulculateAmonutWithQty(length);
                            calcTotal();

                            // Show success notification
                            Swal.fire({
                                icon: 'success',
                                title: 'Quantity Loaded',
                                html: '<strong>' + item_name + '</strong><br/>Quantity: <strong>' + intQty + '</strong><br/>Loaded from consumption data between ' + projectionDate + ' and today.',
                                timer: 2000,
                                showConfirmButton: false
                            });
                        } else {
                            // No consumption data found
                            Swal.fire({
                                icon: 'info',
                                title: 'No Consumption Data',
                                html: '<strong>' + item_name + '</strong><br/>No consumption records found for this item between ' + projectionDate + ' and today.<br/>Quantity set to 0.',
                                timer: 2500,
                                showConfirmButton: false
                            });
                        }
                    },
                    error: function (error) {
                        Swal.close();
                        console.error("Error fetching projected consumption", error);

                        Swal.fire({
                            icon: 'error',
                            title: 'Error Loading Data',
                            text: 'Failed to fetch consumption data for this item. Quantity set to 0.',
                            timer: 2000,
                            showConfirmButton: false
                        });
                    }
                });
            }

            CulculateAmonutWithQty(length);
            calcTotal();
        }

        function initializeDatePickers() {
            $('.row-date-picker').not('.hasDatepicker').datepicker({
                dateFormat: 'dd M yy',
                changeMonth: true,
                changeYear: true,
                showButtonPanel: true
            }).attr('readonly', 'readonly').on('focus', function () {
                $(this).datepicker('show');
            });
        }


    </script>
    <style>
        #txtfreight_charges{
            text-align:right;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtcsmasterid" name="txtcsmasterid" />
    <input type="hidden" id="txtcsno" name="txtcsno" />
    <input type="hidden" id="txttranstype" name="txttranstype" />

    <div class="pr-meta-bar">
        <span class="pr-meta-text" id="poMetaDisplay">PO&nbsp;#&nbsp;<strong>\u2014</strong>&nbsp;&nbsp;|&nbsp;&nbsp;Date:&nbsp;<strong>\u2014</strong>&nbsp;&nbsp;|&nbsp;&nbsp;Status:&nbsp;<strong>Draft</strong></span>
    </div>

    <form id="item">

        <!-- PAGE LOADER - Make sure this is right after the form tag or at the top of content -->
        <div id="page-loader" style="display: none;">
            <div class="loader-spinner"></div>
            <div class="loader-text">Loading Purchase Order...</div>
            <div class="loader-progress">
                <div class="loader-progress-bar"></div>
            </div>
        </div>

        <div class="pr-primary-settings">

            <div style="display:none;">
                <asp:Label ID="LabelPurchase_Date" runat="server" Text="Date"></asp:Label>
                <asp:RequiredFieldValidator ID="rfvPurchaseDate" runat="server" InitialValue="0" ControlToValidate="txtPurchase_Date" ErrorMessage="*" Display="Dynamic"></asp:RequiredFieldValidator>
                <asp:TextBox runat="server" ID="txtPurchase_Date" class="form-control" />
                <asp:Label ID="lblStatus" runat="server" Text="Status"></asp:Label>
                <asp:TextBox runat="server" ReadOnly="true" ID="txtStatus" class="form-control" />
            </div>

            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="LabelPurchase_No" runat="server" Text="PO No."></asp:Label>
                    <asp:TextBox runat="server" ID="txtPurchase_No" class="form-control" ReadOnly="true" />
                    <asp:HiddenField ID="hdnPurchase_ID" runat="server" ClientIDMode="Static" />
                    <asp:TextBox runat="server" ID="txtPurchase_ID" Visible="false" ReadOnly="true" Width="0" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblDueDate" runat="server" Text="Due Date"></asp:Label>
                    <asp:TextBox runat="server" ID="txtdueDate" class="form-control" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12" id="projectiondate">
                    <asp:Label ID="lblprojectiondate" runat="server" Text="Projection Date"></asp:Label>
                    <asp:TextBox runat="server" ID="txtProjection_Date" class="form-control" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12" id="projectiontype">
                    <asp:Label ID="lblddlprojection" runat="server" Text="Projection" Style="">Projection<span style="color: red">*</span></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlprojection" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblSupplier_ID" runat="server" Text="Vendor">Vendor <span style="color: red;">*</span></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlVendor" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblPOType" runat="server" Text="P.O Type"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlPOType" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblWorkOrder" runat="server" Text="Work Order"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlWorkOrder" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
            </div>

            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblpayment" runat="server" Text="Payment Mode" Style="">Mode of Payment<span style="color: red">*</span></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlpayment" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12" id="warehouse">
                    <label id="LblWarehouse">WareHouse<span style="color: red">*</span></label>
                    <select id="ddlWarehouse" onchange="getprNoBy_WareHouse(this)" class="form-select">
                        <option value="0">Please Select</option>
                    </select>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblReference" runat="server" Text="Ref. No"></asp:Label>
                    <asp:TextBox runat="server" ID="txtPurchase_Reference" class="form-control" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblTerm_ID" runat="server" Text="Payment Terms"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlTerm" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblDelivery" runat="server" Text="Delivery Terms"></asp:Label>
                    <asp:DropDownList runat="server" ID="ddlDelivery" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblFreight" runat="server" Text="Freight Amount"></asp:Label>
                    <asp:TextBox runat="server" ID="Freight" onkeyup="calcTotal()" class="form-control" />
                </div>
            </div>

            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
                    <asp:TextBox runat="server" ID="txtRemarks" class="form-control" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="lblWarranty" runat="server" Text="Warranty"></asp:Label>
                    <asp:TextBox runat="server" ID="txtWarranty" class="form-control" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <label id="LblBranch">Branch</label>
                    <select id="ddlBranch" class="form-select">
                        <option value="0">Please Select</option>
                    </select>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6 col-xs-12">
                    <asp:Label ID="LblDisclaimer" runat="server" Text="Disclaimer"></asp:Label>
                    <asp:TextBox runat="server" ID="txtDisclaimer" class="form-control" />
                </div>
            </div>

        </div>

        <!-- Source toggle + Attachment -->
        <div class="pr-source-attach-row">
            <div class="pr-source-left">
                <div class="source-toggle-pill" id="poSourceTogglePill">
                    <label class="source-radio-option">
                        <input type="radio" name="poSourceType" id="rdoPOItem" value="item" checked="checked" />
                        <span class="source-pill-label">Item</span>
                    </label>
                    <label class="source-radio-option">
                        <input type="radio" name="poSourceType" id="rdoPOPR" value="pr" />
                        <span class="source-pill-label">PR</span>
                    </label>
                </div>
                <div id="itemInputSection" class="source-input-wrap">
                    <div class="source-inline-group">
                        <input type="text" id="txtItem" class="source-select-input" placeholder="Search items..." />
                        <button type="button" class="source-action-btn" id="btnGetAllItems" ><i class="fa fa-search"></i> Items</button>
                    </div>
                </div>
                <div id="prInputSection" class="source-input-wrap" style="display:none;">
                    <div class="source-inline-group">
                        <asp:DropDownList runat="server" ID="ddlPrNo" class="source-select-input"></asp:DropDownList>
                        <button type="button" class="source-action-btn" id="btnPRSave" onclick="LoadPrNoDetail($('#ctl00_MainContent_ddlPrNo').val())"><i class="fa fa-plus"></i> Add</button>
                    </div>
                </div>
                <div class="source-checkbox-group">
                    <div class="pr-checkbox-wrap pr-checkbox-inline">
                        <input type="checkbox" id="chkByDefault" />
                        <label for="chkByDefault">By Default</label>
                    </div>
                    <div class="pr-checkbox-wrap pr-checkbox-inline">
                        <input type="checkbox" id="chkManual" />
                        <label for="chkManual">Manual</label>
                    </div>
                    <div class="pr-checkbox-wrap pr-checkbox-inline" >
                        <input type="checkbox" id="IsadvancewithTax" />
                        <label for="IsadvancewithTax">Adv Tax Including GST</label>
                    </div>
                </div>
            </div>
            <div class="pr-attachment-card">
                <div class="pr-attachment-icon"><i class="fa fa-paperclip"></i></div>
                <div class="pr-attachment-body">
                    <span class="pr-attachment-label">Attachment</span>
                    <input type="file" id="chosePofile" name="chosePofile" class="pr-file-input" />
                    <div class="pr-attachment-download">
                        <asp:HyperLink ID="HyperLink1" runat="server" CssClass="pr-download-btn"><i class="fa fa-download"></i> Download</asp:HyperLink>
                    </div>
                </div>
            </div>
        </div>
    </form>
    <asp:HiddenField ID="hdfItem_ID" runat="server" ClientIDMode="Static" />
    <div id="ITEMTable">
        <table class="table table-bordered table-striped" id="tblItemDescription">
            <thead>
                <tr style="position: sticky; top: 0px; z-index: 10;">
                    <th style="width: 34px;">No</th>
                    <th style="width: 54px; text-align: center;">P.R No</th>
                    <th style="width: 54px; text-align: center;">CS NO</th>
                    <th style="width: 80px; text-align: center;">Item Code</th>
                    <th style="text-align: center;">Item Description</th>
                    <th style="width: 48px;">Unit</th>
                    <th style="width: 66px;">Qty</th>
                    <th style="width: 70px;">UOM / P Size Qty </th>
                    <th style="width: 64px;">Bonus Qty</th>
                    <th style="width: 72px;">Rate</th>
                    <th style="width: 52px;">Dis %</th>
                    <th style="width: 70px;">Dis Amount</th>
                    <th style="width: 64px;">S.Tax %</th>
                    <th style="width: 70px;">ST Amount</th>
                    <th style="width: 56px;">F.Tax %</th>
                    <th style="width: 70px;">F.Tax Amount</th>
                    <th style="width: 64px;">A.Tax %</th>
                    <th style="width: 72px;">Adv Amount</th>
                    <th style="width: 58px; display: none;">Fed%</th>
                    <th style="width: 70px; display: none;">Fed Amount</th>
                    <th style="width: 70px;">Bonus Tax</th>
                    <th style="width: 84px;">Total</th>
                    <th style="width: 104px;">Delivery Date</th>
                    <th style="width: 54px; text-align: center;">Stock</th>
                    <th style="width: 74px; text-align: center;">Last PO Rate</th>
                    <th style="width: 110px; text-align: center;">Last Vendor</th>
                    <th style="width: 48px;">Action</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
    </div>

    <!-- Totals Bar -->
    <div class="pr-totals-bar">
        <span class="pr-totals-bar-label">Totals</span>
        <div class="pr-totals-bar-fields">
            <div class="pr-totals-bar-item">
                <label>Sub Total</label>
                <input type="text" id="txtSub_Total" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Discount</label>
                <input type="text" id="txtTotalDiscAmt" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Tax</label>
                <input type="text" id="txtst_amou" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Bonus Tax</label>
                <input type="text" id="txtBonusTaxTotal" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Freight</label>
                <input type="text" id="txtfreight_charges" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item">
                <label>Net Amount</label>
                <input type="text" id="ctl00_MainContent_Net_Amount" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item" style="display: none;">
                <label>Adv Tax</label>
                <input type="text" id="txtAdv_amou" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
            <div class="pr-totals-bar-item" style="display: none;">
                <label>Further Tax</label>
                <input type="text" id="txtFurther_amou" readonly="readonly" class="pr-total-input" placeholder="0.00" />
            </div>
        </div>
    </div>

    <!-- Action Buttons -->
    <div class="pr-action-buttons">
        <div>
            <input type="button" class="btn btn-primry w-100" onclick="this.disabled=true;SaveAllRecord()" value="Save" id="btnSave" />
        </div>
        <div>
            <input type="button" class="btn-gray w-100" value="List" onclick="window.location = 'PurchaseOrderView.aspx'" />
        </div>
        <div>
            <input type="button" class="btn btn-yellow w-100" value="New" onclick="window.location = 'PurchaseOrder.aspx'" />
        </div>
        <div>
            <input style="text-align: center" type="button" value="Cancel" id="btncancel" class="btn btn-primry w-100" onclick="Cancel()" />
        </div>
        <div>
            <input type="button" id="btnPrint" value="Print" class="btn btn-primry w-100" name="name" onclick="PrintPurchaseOrderDetail();" />
        </div>
        <div>
            <input type="button" id="btnPrint2" value="Print2" class="btn btn-primry w-100" name="name" onclick="PrintPurchaseOrderDetail2();" />
        </div>
        <div>
            <input type="button" style="display:none;" class="btn btn-primry w-100" value="Approve" id="btnApprove" onclick="ApprovePOFromEdit()" />
        </div>
        <div>
            <input type="button" style="display:none;" class="btn btn-primry w-100" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
        </div>
        <div>
            <input type="button" style="display:none;" class="btn btn-primry w-100" value="Replicate" id="btnReplicate" onclick="this.disabled=true;$('#tblItemDescription tbody tr').each(function(){var $prd=$(this).find('input[name=txtPRDId]');if($prd.val()&&$prd.val()!='0'&&$prd.val()!=''){$prd.val('0');$(this).find('input[name=txtPRNo]').val('');$(this).find('input[name=txtcsno]').val('');}});$('#btnSave').val('Save');$('#hdnPurchase_ID').val('');SaveAllRecord()" />
        </div>
    </div>

    <div id="PrintPurchseOrderReport" style="display: none;">
        <div style="height: 110px; -webkit-print-color-adjust: exact; width: 750px; margin-left: 100px">
            <div style="padding: 5px; margin-left: -30px">
                <%--<img height="105" width="120" src="../images/HMIS_Icons/CPHLogoLatest.png" style="margin-top: -1px;">--%>
            </div>
            <div style="width: 350px; height: 110px; margin-top: -113px; margin-left: 177px;">
                <div style="padding-top: 75px; font-size: 20px; font-weight: bold; text-align: center; margin-top: -150px;">
                    As Siraat Serving Humanity
                 
                    <b style="font-size: 14px">(Project of Health & Education Foundaion)</b>
                </div>
            </div>
        </div>
        <div style="margin-left: 360px;">
            <b style="text-align: center; font-size: 26px">PURCHASE ORDER</b>
        </div>
        <table cellpadding="0" cellspacing="0" border="1" bordercolor="white" style="margin-top: 30px; margin-left: 50px; height: 200px; width: 769px">
            <tr>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px; font-family: Calibri">PO No:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 88px; text-align: center; margin-left: -60px; margin-top: -17px; font-size: 14px">
                        <span id="lvlPOno"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 100px; text-align: left; font-size: 14px; margin-top: -10px; font-family: Calibri">Vendor Name:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 160px !important; text-align: center; margin-top: -17px; font-size: 14px;">
                        <span id="lblVendorName"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 70px; text-align: left; font-size: 14px; margin-top: -8px; font-family: Calibri">Po Date:</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-top: -16px; font-size: 14px;">
                        <span id="lvlPoDate"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Ref No</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-left: -60px; margin-top: -43px; font-size: 14px;">
                        <span id="lvlRefNo"></span>
                    </h6>
                </td>

                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Terms</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 160px; text-align: center; margin-top: -43px; font-size: 14px;">
                        <span id="lblTerms"></span>
                    </h6>
                </td>
                <td>
                    <h6 style="width: 108px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri;">Ware House</h6>
                </td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 100px; text-align: center; margin-top: -43px; font-size: 14px;">
                        <span id="lblWareHouse"></span>
                    </h6>
                </td>
            </tr>
            <tr>
                <td>
                    <h6 style="width: 78px; text-align: left; margin-top: -40px; font-size: 14px; font-family: Calibri">Remarks:</h6>
                </td>
                <td colspan="5">
                    <h6 style="border-bottom: 1px dotted #000; width: 580px; text-align: center; margin-left: -61px; margin-top: -45px; font-size: 14px;">
                        <span id="txtRemarksrpt"></span>
                    </h6>
                </td>
            </tr>
        </table>
        <div style="border: 2px solid black; border-collapse: collapse; border-color: gray; margin-top: -20px; margin-left: 52px; width: 733px; min-height: 556px" cellpadding="5" cellspacing="5">
            <table class="table" style="overflow: scroll; width: 734px; margin-top: -5px; font-family: Calibri;" id="tblBilling">
                <thead>
                    <tr>
                        <th style="width: 40px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Sr.</th>
                        <th style="width: 300px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Description</th>
                        <th style="width: 30px; text-align: left; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Unit</th>
                        <th style="width: 33px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Qty</th>
                        <th style="width: 76px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Rate</th>
                        <th style="width: 100px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Dis Amount</th>
                        <th style="width: 100px; text-align: right; border: 2px solid black; border-collapse: collapse; border-bottom-color: gray; border-color: gray; font-family: Calibri; font-size: 18px">Amount</th>
                    </tr>
                </thead>
                <tbody id="Billtbody">
                </tbody>
            </table>
        </div>
        <table class="table" style="width: 305px; margin-left: 490px;" id="tblBillingDetail" cellpadding="5" cellspacing="5">
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Total Amount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblTotalAmount" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Discount:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblDisAmount" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tr>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; font-family: Calibri"><b>Net Payable:</b></td>
                <td></td>
                <td style="border: 1px solid black; border-collapse: collapse; border-color: gray; text-align: Right;">
                    <span id="lblNetPayable" class="lede" style="font-weight: bold; text-align: Right;"></span>
                </td>
            </tr>
            <tbody>
            </tbody>
        </table>
        <table class="table" style="margin-left: 50px; margin-top: 20px">
            <tr>
                <td style="font-family: Calibri"><b>Prepared By:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left; font-family: Calibri; margin-left: -19px; margin-top: 15px; font-size: 14px;">
                        <span id="lblOperatorNameb"></span>
                    </h6>
                </td>
                <td style="font-family: Calibri"><b>Checked By:</b></td>
                <td style="width: 30px"></td>
                <td>
                    <h6 style="border-bottom: 1px dotted #000; width: 230px; text-align: left; font-family: Calibri; margin-left: -19px; margin-top: 17px; font-size: 14px;">
                        <span id="Span1"></span>
                    </h6>
                </td>
            </tr>
            <tbody>
            </tbody>
        </table>
    </div>
    <div id="POItemsModel" class="modal fade" role="dialog" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg custom-modal-dialog">
            <div class="modal-content custom-modal-content">
                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-list"></i></span>
                        <h4 class="modal-title custom-modal-title">Add PR Items</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal"><i class="fa fa-times"></i></button>
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div class="modal-body custom-modal-body">
                    <div class="custom-modal-table-wrap">
                        <table class="table custom-modal-table" id="tblPOItemstModelTable">
                            <thead>
                                <tr>
                                    <th style="width: 32px;">
                                        <input type="checkbox" id="checkHeader" value="false" /></th>
                                    <th style="display: none;">Pr ID </th>
                                    <th style="display: none;">Item ID </th>
                                    <th>Item Name</th>
                                    <th>Qty</th>
                                    <th style="display: none;"></th>
                                    <th style="display: none;"></th>
                                    <th style="display: none;"></th>
                                    <th style="display: none;"></th>
                                    <th>Stock</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <input type="button" id="PoItem" name="PoItem" value="Close" class="btn btn-gray" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
    <!-- Add this NEW modal for Item Search -->
    <div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg custom-modal-dialog">
            <div class="modal-content custom-modal-content">
                <div class="modal-header custom-modal-header">
                    <div class="custom-modal-title-wrap">
                        <span class="custom-modal-icon"><i class="fa fa-cubes"></i></span>
                        <h4 class="modal-title custom-modal-title" id="itemsModalLabel">Item Details</h4>
                    </div>
                    <button type="button" class="custom-modal-close" data-dismiss="modal" aria-label="Close"><i class="fa fa-times"></i></button>
                </div>
                <div class="modal-body custom-modal-body">
                    <div class="custom-modal-search-wrap">
                        <span class="custom-modal-search-icon"><i class="fa fa-search"></i></span>
                        <input type="text" id="searchInput" class="custom-modal-search" placeholder="Search items..." />
                    </div>
                    <div class="custom-modal-table-wrap">
                        <table class="table custom-modal-table">
                            <thead>
                                <tr>
                                    <th>Select</th>
                                    <!-- td:eq(0) -->
                                    <th style="display: none;">Item ID</th>
                                    <!-- td:eq(1) -->
                                    <th>Item Code</th>
                                    <!-- td:eq(2) -->
                                    <th>Description</th>
                                    <!-- td:eq(3) -->
                                    <th>Unit</th>
                                    <!-- td:eq(4) -->
                                    <th style="display: none;">Rate</th>
                                    <!-- td:eq(5) -->
                                    <th style="display: none;">UOM Qty</th>

                                    <th>Last Purchase Rate</th>                               
                                    <!-- td:eq(6) -->
                                    <th>Stock</th>
                                    <th>Last Vendor</th>
                                </tr>
                            </thead>
                            <tbody id="itemsTableBody">
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
