<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InversionGatePass.aspx.cs" Inherits="PMS.Inventory.InversionGatePass" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/gate-pass.css?v=20261017" rel="stylesheet" />
    <script type="text/javascript">
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

        $(document).ready(function () {
            UserRights();
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtDate").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            GetWareHouse();
            // Initialize tooltips
            $('[data-toggle="tooltip"]').tooltip({ trigger: 'manual' });
        <% if (Request.QueryString["IGP_ID"] != null)
        { %>
            var IGP_ID = '<%= Request.QueryString["IGP_ID"]%>';
            LoadVendorsAfterApprove();
            setTimeout(function () {
                LoadIGPData(IGP_ID);
            }, 1000);
        <% }
        else
        { %> 
            GetNewIgpNo();
            FillVendors();
        <% } %>

            $('#btnSave').click(function () {
                SaveAllRecord();
            });
            $('select').select2();
            loadUserBranch();
            BranchWareHouse.attach('#ddlBranch', '#ddlInv_Org');
            var IgpID = '<%= Request.QueryString["IGP_ID"] %>';
            if (IgpID == '') {
                $('#btn_Print').hide();

                $('#btnPrintInspec').hide();
                $('#btnInspec').hide();
                $('#btnUnInspec').hide();
            }

            // Show tooltip when BonusQty input is clicked
            $(document).on('click', '.bonusQtyField', function () {
                var $this = $(this);
                $this.tooltip('show');

                // Hide tooltip after 2 seconds
                setTimeout(function () {
                    $this.tooltip('hide');
                }, 2000);
            });

        });


        function UserRights() {
            $.ajax({
                type: "POST",
                url: "InversionGatePass.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
                        $('#SaveButtonToBeHidden').show();
                    } else {
                        $('#SaveButtonToBeHidden').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }



        function LoadIGPData(IGP_ID) {
            PageMethods.LoadIGPHeaderDetail(IGP_ID, function (resp) {
                var data = JSON.parse(resp);
                var TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Igp_date.substring(6, 19))));
                $('#IGP_Num').val(data.Igp_num);
                $('#txtDate').val(TrnsDate);
                setTimeout(function () {
                    $('#ddlVendor').val(data.Vendor).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlInv_Org').val(data.InvOrgId).trigger('change');
                }, 1000);

                //setTimeout(function () {
                //    $('#ddlPONo').val(data.PO_ID).trigger('change');
                //}, 1000);
                $('#DriverName').val(data.DriverName);
                $('#txtVehiclenum').val(data.VehicleNum);
                $('#txtBility_No').val(data.BilityNum);
                $('#txtRemarks').val(data.Remarks);
                $('#txtStatus').val(data.Status);
                $('#txtStatusInspec').val(data.Inspec_Status);
                savedBranch = data.Branch_Id;
                if (savedBranch) {
                    $('#ddlBranch').val(savedBranch).trigger('change');
                }
                var status = $('#txtStatus').val();
                var inspstatus = $('#txtStatusInspec').val();
                if (inspstatus == "Approved") {
                    $('#btnInspec').attr("disabled", 'disabled');
                    $('#btnUnInspec').show();
                    $('#btnInspec').hide();
                }
                if (inspstatus == 'Created' || inspstatus == 'Pending') {
                    $('#btnUnInspec').attr("disabled", 'disabled');
                    $('#btnUnInspec').hide();
                    $('#btnPrintInspec').attr("disabled", 'disabled');
                    $('#btnPrintInspec').hide();
                    $('#btnInspec').show();
                }
                if (inspstatus == '') {
                    $('#btnUnInspec').attr("disabled", 'disabled');
                    $('#btnUnInspec').hide();
                    $('#btnPrintInspec').attr("disabled", 'disabled');
                    $('#btnPrintInspec').hide();
                    $('#btnInspec').show();
                }
                if (status == "Approved") {
                    UserUnApproveButtonRights();
                    $('#SaveButtonToBeHidden').attr("disabled", 'disabled');
                    $('#SaveButtonToBeHidden').hide();
                }
                if (status == "Created" || status == "Pending") {
                    $('#btnPrintInspec').hide();
                    $('#btnPrintInspec').attr("disabled", 'disabled');
                    $('#btnInspec').hide();
                    $('#btnInspec').attr("disabled", 'disabled');
                    $('#btnUnInspec').hide();
                    $('#btnUnInspec').attr("disabled", 'disabled');
                    $('#SaveButtonToBeHidden').attr("disabled", false);
                    $('#SaveButtonToBeHidden').show();
                    if (IGP_ID != "") {
                        CheckIGPApprovalRightsAndShowButton(IGP_ID);
                    }
                }
                $('#ddlVendor').attr("disabled", 'disabled');
                getPONumByVendor(data.Vendor);
                // getPONumByVendor(data.Vendor, function () {
                //setTimeout(function () {
                //    $('#ddlPONo').val(data.PO_ID).trigger('change.select2');
                //}, 1500);
                LoadIGPDetail(IGP_ID);
                // });

            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function GetWareHouse() {
            PageMethods.GetWareHouses(function (Tests) {
                optionsInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "WareHouse") {
                        optionsInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                });
                $('#ddlInv_Org').html(optionsInv);
            });
        }
        function LoadIGPDetail(IGP_ID) {
            PageMethods.LoadIGPetail(IGP_ID, function (resp) {
                var data = (JSON.parse(resp));
                var rows = '';
                var ExpiryDate = '';
                var MfgDate = '';
                var datetime = '';
                selectedOptions = data;
                $.each(data, function (key, value) {
                    // $('#ddlPONo').val(value.PO_ID);
                    if (data[key].Delivery_Date != null) {
                        datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Delivery_Date.substring(6, 19))));
                    }
                    var rowlength = tblItemDescription.rows.length;
                    if (value.Unit_ID == null)
                        value.Unit_ID = "";
                    if (value.UOM == null)
                        value.UOM = "";
                    if (value.ExpiryDate != null) {
                        ExpiryDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.ExpiryDate.substring(6, 19))));
                    }
                    else {
                        ExpiryDate = '';
                    }
                    if (value.ExpiryDate != null) {
                        MfgDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.MfgDate.substring(6, 19))));
                    }
                    else {
                        MfgDate = '';
                    }
                    var saleRateValue = '';
                    if (value.SaleRate != null && value.SaleRate != '') {
                        saleRateValue = value.SaleRate;
                    } else if (value.Sale_Rate != null && value.Sale_Rate != '') {
                        saleRateValue = value.Sale_Rate;
                    }
                    var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value=' + value.itemcode + ']');
                    if (test_array.length > 0) {

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'This Item already added',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                        return false;
                    }
                    else {
                        rows += '<tr>' +
                            '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtPODetailId' + (key + 1) + '" name="txtPODetailId" value="' + value.PO_Item_ID + '" style="width:100%!important;text-align:right" />' + (key + 1) + '</td>' +
                            '<td align="right !important" style=""><input type="hidden" name="txtPONO" id="txtPONO' + (key + 1) + '"  value="' + value.PO_No + '"  style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"/>' + value.PO_No + '</td>' +
                            '<td style=""><input type="hidden" name="txtItemCode" id="txtItemCode' + (key + 1) + '"  value="' + value.Item_Code + '"  style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                            '<td style=""><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:10px;!important"/> ' + value.Description + ' </td>' +
                            '<td><input type="text" disabled="disable" name="txtuomqty" id="txtuomqty' + rowlength + '"  value="' + value.UOM_Qty + '" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:28px;" /></td>' +
                            '<td style=""><input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '"  value="' + value.Unit_ID + '" />' + value.UOM + ' </td>' +
                            '<td><input type="text" name="BatchNo" id="BatchNo' + rowlength + '"  value="' + value.BatchNum + '" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:28px;" onkeyup="BatchValidation(this)"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="txtdeliverydate" id="txtdeliverydate' + (key + 1) + '"  value="' + datetime + '" readonly="readonly" /></td>' +
                            '<td style=""><input type="hidden" value="' + value.POQty + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;  id="POQty' + (key + 1) + '" name="POQty" style="width:100%!important;"></input>' + value.POQty + '</td>' +
                            '<td style=""><input type="hidden" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;" value="' + value.Received_Qty + '"  id="RcvQty' + (key + 1) + '" name="RcvQty" ></input>' + value.Received_Qty + '</td>' +
                            '<td style="" style="text-align:right"><input type="hidden" value="' + value.Balance + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"  id="blncQty' + (key + 1) + '" name="blncQty" ></input>' + value.Balance + '</td>' +
                            '<td style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="' + value.IGPQty + '"  id="IgpQty' + (key + 1) + '" name="IgpQty"></input></td>' +

                            '<td style=""><input type="hidden" value="' + value.InspecQty + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;  id="InspQty' + (key + 1) + '" name="InspQty" style="width:100%!important;"></input>' + value.InspecQty + '</td>' +

                            '<td style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="' + value.BounusQty + '" autocomplete="off" id="BounusQty' + (key + 1) + '" name="BounusQty"></input></td>' +


                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="txtMfgdate" id="txtMfgdate' + (key + 1) + '"  value="' + MfgDate + '" readonly="readonly"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="Expdate" id="Expdate' + (key + 1) + '"  value="' + ExpiryDate + '" readonly="readonly"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" name="SaleRate" id="SaleRate' + (key + 1) + '"  value="' + saleRateValue + '"/></td>' +
                            '<td style="display:none"><input type="hidden" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="Isbatch" id="Isbatch' + rowlength + '" value="' + value.IsBatch + '" readonly="readonly"/></td>' +
                            '<td style="display:none;width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="0"  id="RejQty' + rowlength + '" name="RejQty"></input></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size: 13px;color: #f30a0a;position:relative;" i=""></i></a></td>' +
                            '</tr>';
                    }
                });
                $('#tblItemDescription tbody').html(rows);
                BatchValidation2();

                //$('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                $(document).off('focus.igpdate', 'input[name="txtMfgdate"], input[name="Expdate"]').on('focus.igpdate', 'input[name="txtMfgdate"], input[name="Expdate"]', function () {
                    $(this).datepicker({
                        changeMonth: true,
                        changeYear: true,
                        constrainInput: false,
                        yearRange: "1950:2050",
                        dateFormat: 'dd M yy'
                    });
                });

                //$('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
                $.each(selectedOptions, function (key, value) {
                    $("#ddlFed" + (key + 1)).val(value.FedPercent_Id);
                    $("#ddlSTAX" + (key + 1)).val(value.SalTax_Id);
                });
                $('#btnSave').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function BatchValidation(row) {
            var _this = $(row).closest('tr')[0];
            var batch = $(_this).find('td input[name="Isbatch"]').val();
            var batch_no = $(_this).find('td input[name="BatchNo"]').val();
            var item_code = $(_this).find('td input[name="txtItemCode"]').val();
            var igp_id = '<%= Request.QueryString["IGP_ID"] %>';

            if (batch == "false" || batch == 'null' || batch == null) {
                if (batch_no != "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please enable Batch checkbox from item form',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $(_this).find('td input[name=BatchNo]').val('');
                    $(_this).find('td input[name=BatchNo]').prop('readonly', true);
                }
            } else if (batch == "true" && batch_no != "") {
                PageMethods.BatchValidation(function (result) {
                    var batchValidationCode = result;

                    if (batchValidationCode == "01") {
                        PageMethods.CheckBatchExists(parseInt(item_code), batch_no, igp_id ? parseInt(igp_id) : 0, function (exists) {
                            if (exists) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Batch number "' + batch_no + '" already exists for Item Code "' + item_code + '". Please use a different batch number.',
                                    showConfirmButton: false,
                                    timer: 3000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                $(_this).find('td input[name=BatchNo]').val('');
                            }
                        });
                    }
                });
            }
        }
        // Flexible date entry for Mfg / Expiry date. Whatever the user types, it is converted to the
        // system format "dd Mon yyyy" (for example 01 Feb 2028) before it is read or saved.
        // Accepted: 010228, 01022028, 01-0228, 1-2-28, 01/02/28, 01.02.2028, 01 02 28, 28-02-01 style
        // (year first, 4-digit year), 20280201, 01 Feb 28, 1-feb-2028, Feb 1 2028 ...
        // Order is always day, month, year. Two-digit years mean 20yy.
        var igpMonths = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
        function parseQuickDate(v) {
            v = $.trim(v);
            if (v === '') return undefined;                 // empty: nothing to do
            var d, mo, y, i;
            var parts = v.match(/[A-Za-z]+|\d+/g) || [];
            var words = [], nums = [];
            for (i = 0; i < parts.length; i++) { (/^\d+$/.test(parts[i]) ? nums : words).push(parts[i]); }
            if (/[^A-Za-z0-9\s\/\-\.,\\_:]/.test(v)) return null;
            if (words.length > 1) return null;
            if (words.length === 1) {                       // month written as a word
                mo = -1;
                var w = words[0].toLowerCase();
                for (i = 0; i < 12; i++) { if (w.length >= 3 && igpMonths[i].indexOf(w.substring(0, 3)) === 0 && ('january february march april may june july august september october november december').indexOf(w) >= 0) { mo = i + 1; break; } }
                if (mo < 1 || nums.length !== 2) return null;
                if (nums[0].length === 4) { y = parseInt(nums[0], 10); d = parseInt(nums[1], 10); }
                else if (nums[1].length === 4) { y = parseInt(nums[1], 10); d = parseInt(nums[0], 10); }
                else { d = parseInt(nums[0], 10); y = parseInt(nums[1], 10); }
            } else {
                var digits = nums.join('');
                if (nums.length === 3) {
                    if (nums[0].length === 4) { y = parseInt(nums[0], 10); mo = parseInt(nums[1], 10); d = parseInt(nums[2], 10); }   // yyyy-mm-dd
                    else { d = parseInt(nums[0], 10); mo = parseInt(nums[1], 10); y = parseInt(nums[2], 10); }
                    if (nums[0].length > 2 && nums[0].length !== 4) return null;
                    if (nums[2].length !== 2 && nums[2].length !== 4 && nums[0].length !== 4) return null;
                } else if (nums.length === 1 || nums.length === 2) {
                    if (digits.length === 6) { d = parseInt(digits.substr(0, 2), 10); mo = parseInt(digits.substr(2, 2), 10); y = parseInt(digits.substr(4, 2), 10); }
                    else if (digits.length === 8) {
                        if (parseInt(digits.substr(0, 4), 10) >= 1900) { y = parseInt(digits.substr(0, 4), 10); mo = parseInt(digits.substr(4, 2), 10); d = parseInt(digits.substr(6, 2), 10); }   // yyyymmdd
                        else { d = parseInt(digits.substr(0, 2), 10); mo = parseInt(digits.substr(2, 2), 10); y = parseInt(digits.substr(4, 4), 10); }
                    } else return null;
                } else return null;
            }
            if (y < 100) y += 2000;
            var dt = new Date(y, mo - 1, d);
            if (dt.getFullYear() !== y || dt.getMonth() !== mo - 1 || dt.getDate() !== d) return null;   // impossible date
            return dt;
        }
        // Returns true when the box was handled (converted or rejected), false when there was nothing to do.
        function applyQuickDate(el) {
            var dt = parseQuickDate($(el).val());
            if (dt === undefined) return false;
            if (dt === null) {
                $(el).val('');
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Invalid date. Type day, month and year, for example 010228, 01-02-28 or 01 Feb 2028.',
                    showConfirmButton: false,
                    timer: 3000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return true;
            }
            $(el).val($.datepicker.formatDate('dd M yy', dt));
            if ($(el).hasClass('hasDatepicker')) { $(el).datepicker('setDate', dt); }
            return true;
        }
        // Enter / Tab right after typing: convert FIRST. Otherwise the date picker (which highlights today
        // while the box has no valid date) picks today's date on Enter before the conversion runs.
        // This listener runs in the capture phase, ahead of the date picker's own key handling.
        document.addEventListener('keydown', function (e) {
            var t = e.target;
            if (!t || t.tagName !== 'INPUT' || (t.name !== 'Expdate' && t.name !== 'txtMfgdate') || t.readOnly) return;
            var isEnter = (e.key === 'Enter' || e.keyCode === 13), isTab = (e.key === 'Tab' || e.keyCode === 9);
            if (!isEnter && !isTab) return;
            clearTimeout($(t).data('igpT'));
            var handled = applyQuickDate(t);
            if (isEnter && handled) {
                e.preventDefault();
                e.stopImmediatePropagation();
                if ($(t).hasClass('hasDatepicker')) { $(t).datepicker('hide'); }
            }
        }, true);
        // While typing: once exactly 6 digits are in the box and the user pauses, convert it (so 010228 is
        // enough). The short pause lets someone who keeps typing 8 digits (01022028) finish first.
        // Any other format is converted when the user leaves the box (Tab / Enter / click away).
        $(document).on('input.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function () {
            var el = this;
            clearTimeout($(el).data('igpT'));
            if (/^\d{6}$/.test($.trim($(el).val()))) {
                $(el).data('igpT', setTimeout(function () {
                    if (/^\d{6}$/.test($.trim($(el).val()))) { applyQuickDate(el); }
                }, 900));
            }
        });
        $(document).on('focusout.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function () {
            clearTimeout($(this).data('igpT'));
            applyQuickDate(this);
        });
        // Clicking into a date box selects the whole text, so typing replaces the old value
        // (the Mfg date comes pre-filled with today's date; without this the digits get inserted inside it).
        $(document).on('focusin.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function () {
            var el = this;
            if (!el.readOnly && el.value) {
                setTimeout(function () { try { el.select(); } catch (e) { } }, 0);
            }
        });
        $(document).on('mouseup.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function (e) {
            // the click that gave the box focus: select everything and keep it selected
            if (!this.readOnly && $(this).data('igpFirstClick') === this) {
                $(this).data('igpFirstClick', null);
                if (this.value) { this.select(); }
                e.preventDefault();
            }
        });
        $(document).on('mousedown.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function () {
            // only the click that gives the box focus selects everything; later clicks place the caret as usual
            $(this).data('igpFirstClick', document.activeElement === this ? null : this);
        });
        $(document).on('focusin.igpquick', 'input[name="Expdate"], input[name="txtMfgdate"]', function () {
            if (!this.readOnly && !this.getAttribute('placeholder')) { this.setAttribute('placeholder', 'ddmmyy'); }
        });
        function BatchValidation2() {
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var batch = $($(value).find('td input[name=Isbatch]')[0]).val();
                if (batch == "false" || batch == 'null' || batch == null) {
                    $($(value).find('td input[name=BatchNo]')[0]).prop('readonly', true);
                    $($(value).find('td input[name=txtMfgdate]')[0]).removeAttr('disabled').removeAttr('readonly');
                    $($(value).find('td input[name=Expdate]')[0]).removeAttr('disabled').removeAttr('readonly');
                    $($(value).find('td input[name=SaleRate]')[0]).removeAttr('readonly').prop('readonly', false);
                } else {
                    $($(value).find('td input[name=BatchNo]')[0]).prop('readonly', false);
                    $($(value).find('td input[name=txtMfgdate]')[0]).removeAttr('disabled').prop('readonly', false);
                    $($(value).find('td input[name=Expdate]')[0]).removeAttr('disabled').prop('readonly', false);
                    $($(value).find('td input[name=SaleRate]')[0]).prop('readonly', false);
                }
            });
            disablepo();
        }
        function validateSave() {
            var proceed = true;
            var date = $('#txtDate').val();
            var Vendor = $('#ddlVendor').val();
            var InvOrg = $('#ddlInv_Org').val();
            if (Vendor == '0') {
                $("#ddlVendor").addClass('ErrorAlert');
                $('#select2-ddlVendor-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddlVendor").removeClass('ErrorAlert');
                $('#select2-ddlVendor-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            if (InvOrg == '0') {
                $("#ddlInv_Org").addClass('ErrorAlert');
                $('#select2-ddlInv_Org-container').parent().css('border-color', 'red');
                proceed = false;
            }
            else {
                $("#ddlInv_Org").removeClass('ErrorAlert');
                $('#select2-ddlInv_Org-container').parent().css('border-color', ' rgb(206, 191, 191)');
            }
            var tblLength = $("#tblItemDescription tr:gt(0)").length;
            if (tblLength == '0') {
                $('#tblItemDescription').addClass('ErrorAlert');

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add items',
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
            else {
                $('#tblItemDescription').removeClass('ErrorAlert');
            }
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                if (!validateBatchDuplicates()) {
                    return false;
                }
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    var GRNdate = new Date(date).setHours(0, 0, 0, 0);
                    var ExpDateValue = $($(value).find('td input[name=Expdate]')[0]).val();
                    var MfgDateValue = $($(value).find('td input[name=txtMfgdate]')[0]).val();
                    var ExpDate = ExpDateValue ? new Date(ExpDateValue).setHours(0, 0, 0, 0) : null;
                    var MfgDate = MfgDateValue ? new Date(MfgDateValue).setHours(0, 0, 0, 0) : null;
                    var BatchNo = $($(value).find('td input[name=BatchNo]')[0]).val();
                    var txtuomqty = $($(value).find('td input[name=txtuomqty]')[0]).val();
                    var Isbatch = $($(value).find('td input[name=Isbatch]')[0]).val();
                    var item_code = $($(value).find('td input[name=txtItemCode]')[0]).val();
                    var igpQTy = parseFloat($($(value).find('td input[name=IgpQty]')[0]).val()) || 0;
                    var poQty = parseFloat($(value).find('input[name="POQty"]').val()) || 0;


                    if (txtuomqty == "" || txtuomqty == null) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please enter UOM Qty for Item Code "' + item_code + '"',
                            showConfirmButton: false,
                            timer: 3000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $($(value).find('td input[name=txtuomqty]')[0]).css('border-color', 'red');
                        return false;
                    } else {
                        $($(value).find('td input[name=txtuomqty]')[0]).css('border-color', '');
                    }

                    if (isNaN(parseFloat(txtuomqty)) || parseFloat(txtuomqty) <= 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please enter a valid UOM Qty (must be a positive number) for Item Code "' + item_code + '"',
                            showConfirmButton: false,
                            timer: 3000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        $($(value).find('td input[name=txtuomqty]')[0]).css('border-color', 'red');
                        return false;
                    } else {
                        $($(value).find('td input[name=txtuomqty]')[0]).css('border-color', '');
                    }

                    if (igpQTy <= 0) {
                        proceed = false;

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'IGP Quantity must be greater then 0',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                    if (igpQTy == "") {
                        proceed = false;

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Igp Quantity',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                    if (igpQTy > poQty) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'IGP Quantity must be less then or Equal to PO Quantity',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                    if (Isbatch == "true") {
                        if (BatchNo == "") {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Please Enter Batch No',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        if (!MfgDate) {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Please Enter Mfg Date',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        if (!ExpDate) {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Please Enter Expiry Date',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        if (ExpDate && GRNdate > ExpDate) {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Exp Date must not be less than GRN date',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        var saleRateVal = $($(value).find('td input[name=SaleRate]')[0]).val();
                        if (saleRateVal == "" || saleRateVal == null || parseFloat(saleRateVal) <= 0) {
                            proceed = false;
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Sale Rate is compulsory for batch items. Please enter Sale Rate for Item Code ' + item_code,
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

                    if (Isbatch == "false" || Isbatch == 'null' || Isbatch == null) {
                        var message = "Batch is false,You can't enter batch number against Item Code " + item_code + ",Please check batch to true in items";
                        if (BatchNo != "") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: message,
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            $($(value).find('td input[name=BatchNo]')[0]).val('');
                            $($(value).find('td input[name=BatchNo]')[0]).prop('readonly', true);
                            proceed = false;
                        }
                    }
                });
            }
            return proceed;
        }

        function SaveAllRecord() {
            if (validateSave()) {
                $('#ddlVendor').prop('disabled', false);
                var btnSave = $('#btnSave').val();
                var IgpNo = $('#IGP_Num').val();
                var date = $('#txtDate').val();
                var Vendor = $('#ddlVendor').val();
                var DriverName = $('#DriverName').val();
                var VehicleNum = $('#txtVehiclenum').val();
                var Bility_No = $('#txtBility_No').val();
                var Remarks = $('#txtRemarks').val();
                var InvOrg = $('#ddlInv_Org').val();
                var Branch = $('#ddlBranch').val();
                if (!InvOrg || InvOrg === "0") {
                    Swal.fire({
                        icon: 'warning',
                        title: 'Warehouse Required',
                        text: 'Please select a warehouse.',
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return;
                }
                var table = $('#tblItemDescriptionDetail');
                var Item_list = [];
                table.find('tr').each(function (key, value) {
                    Item_list.push({ 'PODetailId': $(value).find('td input[name=txtPODetailId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'RcvQty': $(value).find('td input[name=RcvQty]').val(), 'POQty': $(value).find('td input[name=POQty]').val(), 'BatchNo': $(value).find('td input[name=BatchNo]').val(), 'txtuomqty': $(value).find('td input[name=txtuomqty]').val(), 'BlncQty': $(value).find('td input[name=blncQty]').val(), 'IgpQty': $(value).find('td input[name=IgpQty]').val(), 'InspecQty': $(value).find('td input[name=InspQty]').val(), 'BounusQty': $(value).find('td input[name=BounusQty]').val(), 'Mfgdate': $(value).find('td input[name=txtMfgdate]').val(), 'Expdate': $(value).find('td input[name=Expdate]').val(), 'SaleRate': $(value).find('td input[name=SaleRate]').val(), });
                });
                var AllItemDetail = { 'Igp_num': IgpNo, 'Date': date, 'Vendor': Vendor, 'DriverName': DriverName, 'VehicleNum': VehicleNum, 'BilityNum': Bility_No, 'remarks': Remarks, 'InvOrg': InvOrg, 'Branch': Branch, 'ItemList': Item_list };
                // Block double clicks while the save runs (a large IGP takes a while) and show progress
                $('#btnSave').prop('disabled', true);
                var saveCompleted = false;
                // Safety net: never leave the button disabled / modal open forever if the server hangs
                var saveWatchdog = setTimeout(function () {
                    if (saveCompleted) return;
                    saveCompleted = true;
                    Swal.close();
                    $('#btnSave').prop('disabled', false);
                    Swal.fire({
                        icon: 'warning',
                        title: 'Still saving...',
                        text: 'The server is taking longer than expected. Please check the IGP list before saving again, to avoid a duplicate.',
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
                PageMethods.SaveIgpDetail(btnSave, JSON.stringify(AllItemDetail), function (res) {
                    saveCompleted = true;
                    clearTimeout(saveWatchdog);
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Data Save Successfully.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    // Navigation must run even if the attachment upload fails, otherwise the page stays stuck
                    sendFile(res, function () {
                        $('#btnSave').val("Update");
                        window.location = "InversionGatePass.aspx?IGP_ID=" + res;
                    });
                }, function (error) {
                    // Without this a failed or timed-out save showed nothing and the button looked dead
                    saveCompleted = true;
                    clearTimeout(saveWatchdog);
                    Swal.close();
                    $('#btnSave').prop('disabled', false);
                    var msg = error && error.get_timedOut && error.get_timedOut()
                        ? 'The server is taking longer than expected. Please check the IGP list before saving again, to avoid a duplicate.'
                        : (error && error.get_message ? error.get_message() : 'Unknown error');
                    Swal.fire({ icon: 'error', title: 'Save failed', text: msg, confirmButtonText: 'OK' });
                });
            }
        }
        function sendFile(ID, callback) {
            var fileInput = $('#fileUpload1')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#fileUpload1')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadIGP.ashx',
                    data: data,
                    success: function (status) {
                        if (typeof callback === 'function') callback();
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        // Never block the post-save navigation on an attachment failure
                        console.error("Attachment upload failed.");
                        if (typeof callback === 'function') callback();
                    }
                });
            } else {
                if (typeof callback === 'function') callback();
            }
        }
        function GetNewIgpNo() {
            PageMethods.GetNewIgpNo(function (resp) {
                $('#IGP_Num').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function GetPONo() {
            PageMethods.PONo(function (resp) {
                $('#IGP_Num').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function LoadVendorsAfterApprove() {
            var optionsVen = '';
            PageMethods.getVendorAfterApproveDDLlist(function (Tests) {
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    if (value.Active == true) {
                        optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                    }
                    else {
                        optionsVen += '<option value="' + value.VendorID + '"  disabled>' + value.VendorName + '</option>';
                    }
                });
                $('#ddlVendor').html(optionsVen);
            });
        }
        function FillVendors() {
            var optionsVen = '';
            PageMethods.getVendorDDLlist(function (Tests) {
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    if (value.Active == true) {
                        optionsVen += '<option value="' + value.VendorID + '" >' + value.VendorName + '</option>';
                    }
                    else {
                        optionsVen += '<option value="' + value.VendorID + '"  disabled>' + value.VendorName + '</option>';
                    }
                });
                $('#ddlVendor').html(optionsVen);
            });
        }
        //function getPONumByVendor(item) {
        //    var optionsPO = '';
        //    var VendorId;
        //    VendorId = item.value;
        //    if (typeof VendorId == "undefined" || VendorId == "") {
        //        VendorId = item;
        //    }
        //    PageMethods.GetPONoByVendor(VendorId, function (res) {
        //        var item = JSON.parse(res);
        //        optionsPO = '<option value="0">Please Select</option>';
        //        $.each(item, function (key, value) {
        //            optionsPO += '<option value="' + value.PO_ID + '" >' + value.PO_No + '</option>';
        //        });
        //        $("#ddlPONo option").remove();
        //        $('#ddlPONo').html(optionsPO);
        //    });
        //}
        function getPONumByVendor(item, callback) {
            var VendorId = (typeof item === "object" && item.value) ? item.value : item;

            PageMethods.GetPONoByVendor(VendorId, function (res) {
                var list = JSON.parse(res);
                var optionsPO = '<option value="0">Please Select</option>';

                $.each(list, function (key, value) {
                    optionsPO += '<option value="' + value.PO_ID + '">' + value.PO_No + '</option>';
                });

                $('#ddlPONo').empty().html(optionsPO);
                $('#ddlPONo').select2();

                if (typeof callback === 'function') {
                    callback();
                }
            });
        }

        function PerformPOSearch() {
            $('#ddlVendor').prop('disabled', true);
            var POId = $('#ddlPONo').val();
            var PONum = $("#ddlPONo option:selected").text();
            var blncQty = 0;
            var recqty = 0;
            var totalqty = 0
            if (POId != "") {
                PageMethods.getPurchaseOrderByID(POId, function (res) {
                    var item = JSON.parse(res);
                    var rows = '';
                    var warehouse = item.WareHouse;
                    console.log("WareHoueeee " + warehouse)
                    var iteration = 0;
                    var datetime = '';
                    var currentDate = new Date();
                    var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
                    var hasDuplicate = false;
                    var duplicateItemCode = "";

                    $.each(item.PurchaseOrderDetails, function (key, value) {
                        var existingRow = $('#tblItemDescription').find('input[name=txtItemCode][value="' + value.Item_Code + '"]');

                        if (existingRow.length > 0) {
                            hasDuplicate = true;
                            duplicateItemCode = value.Item_Code;
                            return false;
                        }
                    });

                    if (hasDuplicate) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'This PO is already added to the list.',
                            showConfirmButton: false,
                            timer: 3000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        return; 
                    }
                    $.each(item.PurchaseOrderDetails, function (key, value) {
                        if (value.Unit == null)
                            value.Unit = "";
                        if (value.UnitName == null)
                            value.UnitName = "";

                        if (value.BlncQty == undefined)
                            value.BlncQty = 0
                        if (value.Qty == undefined)
                            value.Qty = 0

                        totalqty = value.Qty;
                        blncQty = value.BlncQty;
                        recqty = totalqty - blncQty;

                        if (value.Delivery_Date != null) {
                            datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.Delivery_Date.substring(6, 19))));
                        }
                        iteration++;
                        var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                        rows += '<tr>' +
                            '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtPODetailId' + rowlength + '" name="txtPODetailId" value="' + value.PO_Item_ID + '" style="width:100%!important;text-align:right" />' + rowlength + '</td>' +
                            '<td style=""><input type="hidden" name="txtPONO" id="txtPONO' + rowlength + '" value="" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"/>' + PONum + '</td>' +
                            '<td style=""><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '" value="' + value.Item_Code + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                            '<td style=""><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '" value="' + value.Description + '" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:10px !important ;"/> ' + value.Description + ' </td>' +
                            '<td><input type="text" name="txtuomqty" id="txtuomqty' + rowlength + '" value="' + value.UOM_Qty + '" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:28px;" /></td>' +
                            '<td style=""><input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '" value="' + value.Unit + '" />' + value.UnitName + ' </td>' +

                            '<td><input type="text" name="BatchNo" id="BatchNo' + rowlength + '" value="" style="width:100%!important;text-align:left;font-size:12px;font-weight:700;height:28px;" onkeyup="BatchValidation(this)"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="txtdeliverydate" id="txtdeliverydate' + rowlength + '" value="' + datetime + '" readonly="readonly"/></td>' +
                            '<td style=""><input type="hidden" value="' + parseFloat(value.Qty).toFixed(2) + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important; id="POQty' + rowlength + '" name="POQty" style="width:100%!important;"></input>' + parseFloat(value.Qty).toFixed(2) + '</td>' +

                            '<td style=""><input type="hidden" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;" value="' + parseFloat(recqty).toFixed(2) + '" id="RcvQty' + rowlength + '" name="RcvQty" ></input>' + parseFloat(recqty).toFixed(2) + '</td>' +

                            '<td style="text-align:right;><input type="hidden" value="' + parseFloat(blncQty).toFixed(2) + '" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px; !important" id="blncQty' + rowlength + '" name="blncQty" ></input>' + parseFloat(blncQty).toFixed(2) + '</td>' +

                            '<td style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="0" id="IgpQty' + rowlength + '" name="IgpQty"></input></td>' +

                            '<td style=""><input type="hidden" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important; id="InspQty' + rowlength + '" value="0" name="InspQty" style="width:100%!important;"></input>' + 0 + '</td>' +

                            '<td style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="' + (value.Bonus_Qty != null ? parseFloat(value.Bonus_Qty).toFixed(2) : '0') + '" id="BounusQty' + rowlength + '" name="BounusQty" autocomplete="off" class="bonusQtyField" data-toggle="tooltip" data-placement="top" title="Enter Bounus quantity in Loose" ></input></td>' +

                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="txtMfgdate" id="txtMfgdate' + (key + 1) + '" value="' + formattedDate + '"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:center;font-size:12px;font-weight:700;height:28px;" name="Expdate" id="Expdate' + (key + 1) + '" value="" readonly="readonly"/></td>' +
                            '<td><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;" name="SaleRate" id="SaleRate' + rowlength + '" value="' + (value.SaleRate ? parseFloat(value.SaleRate).toFixed(2) : '') + '"/></td>' +
                            '<td style="display:none"><input type="hidden" name="Isbatch" id="Isbatch' + rowlength + '" value="' + value.IsBatch + '" readonly="readonly"/></td>' +
                            '<td style="display:none;width:100%!important;text-align:right;font-size:12px;font-weight:700;height:10px !important;"><input type="text" style="width:100%!important;text-align:right;font-size:12px;font-weight:700;height:28px;position: relative;" value="0" id="RejQty' + rowlength + '" name="RejQty"></input></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash" style="font-size:11px;color: #f30a0a;position:relative;"></i></a> </td>' +
                            '</tr>';
                    });
                    $('#tblItemDescription').append(rows);
                    BatchValidation2();
                    $(document).off('blur.igpbatch', 'input[name="BatchNo"]').on('blur.igpbatch', 'input[name="BatchNo"]', function () {
                        BatchValidation(this);
                    });
                    //$('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                    //$('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
                    $(document).off('focus.igpdate', 'input[name="txtMfgdate"], input[name="Expdate"]').on('focus.igpdate', 'input[name="txtMfgdate"], input[name="Expdate"]', function () {
                        $(this).datepicker({
                            changeMonth: true,
                            changeYear: true,
                            constrainInput: false,
                            yearRange: "1950:2050",
                            dateFormat: 'dd M yy'
                        });
                    });
                    
                    $('#ddlInv_Org').val(warehouse).trigger('change');
                    //$('#ddlInv_Org').attr('disabled', true);

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
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function PrintInwardGatePassDetail() {
            var id = '<% =Request.QueryString["IGP_ID"] %>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            }
            window.open(url, '_blank');
        }
        function disablepo() {
            var POField = $('#ddlPONo').val();
            if (POField != "0") {
                $('#AdvddlPONo').attr('disabled', true);
            }
            else {
                $('#AdvddlPONo').attr('disabled', false);
            }
        }
        function PrintInspection() {
            var id = '<% =Request.QueryString["IGP_ID"] %>';
            var locationInfo = window.location;

            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=Inspection&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Inspection&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            }
            window.open(url, '_blank');
        }


        function ApproveInspecModal() {
            if ($('#tblItemDescription tbody tr').length === 0) {

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select items first',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }
            $('#InspmodalItemDescription tbody').empty();
            $('#tblItemDescription tbody tr').each(function (index) {
                var poDetailId = $(this).find('input[name="txtPODetailId"]').val();
                var poQty = $(this).find('input[name="POQty"]').val();
                var igpQty = $(this).find('input[name="IgpQty"]').val();
                var itemDescription = $(this).find('input[name="txtItemName"]').val();
                var itemCode = $(this).find('input[name="txtItemCode"]').val();
                var newRow = '<tr>' +
                    '<td style="display:none;"><input type="hidden" name="txtPODetailId" value="' + poDetailId + '"></td>' +
                    '<td style="display:none;"><input type="hidden" name="txtItemCode" value="' + itemCode + '">' + itemCode + '</td>' +
                    '<td style="width:40%"><input type="hidden" name="txtItemName" value="' + itemDescription + '">' + itemDescription + '</td>' +
                    '<td style="width:8%"><input type="hidden" name="POQty" value="' + poQty + '">' + poQty + '</td>' +
                    '<td style="width:8%"><input type="hidden" name="IgpQty" value="' + igpQty + '">' + igpQty + '</td>' +
                    '<td style="width:8%"><input style="width:68px" type="text" name="InspQty"></td>' +
                    '<td style="width:40%"><input style="width:312px" type="text" name="InspRemarks"></td>' +
                    '</tr>';
                $('#InspmodalItemDescription tbody').append(newRow);
            });
            $('#inspecModal').modal('show');
        }
        function ApproveInspec() {
            var isValid = true;
            var tblLength = $("#InspmodalItemDescription tr:gt(0)").length;

            if (tblLength == '0') {
                $('#InspmodalItemDescription').addClass('ErrorAlert');

                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add items',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                isValid = false;
                return false;
            } else {
                $('#InspmodalItemDescription').removeClass('ErrorAlert');
            }
            if (document.getElementById('InspmodalItemDescription').rows.length > 1) {
                $.each($('#InspmodalItemDescription tbody tr'), function (key, value) {
                    var igpQty = parseFloat($(value).find('td input[name=IgpQty]').val());
                    var inspQty = parseFloat($(value).find('td input[name=InspQty]').val());

                    if (isNaN(inspQty) || inspQty <= 0 || inspQty > igpQty) {
                        var message = "Please enter a valid Inspection Quantity for Item in Row " + (key + 1);

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: message,
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        isValid = false;
                        return false;
                    }
                });
            }

            if (!isValid) {
                return false;
            }
            else {
                var IgpId = '<% =Request.QueryString["IGP_ID"] %>';
                var table = $('#InspmodalItemDescription');
                var Item_list = [];
                table.find('tr:gt(0)').each(function (key, value) {
                    Item_list.push({
                        'PODetailId': $(value).find('td input[name=txtPODetailId]').val(),
                        'ItemCode': $(value).find('td input[name=txtItemCode]').val(),
                        'InspQty': $(value).find('td input[name=InspQty]').val(),
                        'InspRemarks': $(value).find('td input[name=InspRemarks]').val()
                    });
                });

                var AllItemDetail = { 'IgpId': IgpId, 'ItemList': Item_list };

                PageMethods.SaveIgpInspectonDetail(JSON.stringify(AllItemDetail), function (res) {
                    if (res == 1) {
                        PageMethods.ApproveIgpInspec(IgpId, function (Tests) {
                            var message = JSON.parse(Tests);
                            if (message[0].Column1 == "1" || message[0].Column1 === "1") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Inspection Approved Done Successfully.',
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
                                if (message == "1") {
                                    Swal.fire({
                                        icon: 'success',
                                        title: 'Success!',
                                        text: 'Inspection Approved Done Successfully.',
                                        showConfirmButton: false,
                                        timer: 2500,
                                        customClass: {
                                            popup: 'swal-big-popup',
                                            title: 'swal-big-title',
                                            htmlContainer: 'swal-big-text'
                                        }
                                    });
                                    location.reload();
                                }
                                else {

                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Error!',
                                        text: 'An error occurred while Approving Inspection',
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
                        });
                    } else {

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'An error occurred while Updating Inspection details',
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

        function UnApproveInspec() {
            var IgpId = '<% =Request.QueryString["IGP_ID"] %>';
            PageMethods.UnApproveIgpInspec(IgpId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }
        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "InversionGatePass.aspx/UserUnApproveEntryRights",
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
        function UnApprove() {
            var IgpId = '<% =Request.QueryString["IGP_ID"] %>';
            PageMethods.UnApproveIgP(IgpId, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
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
                url: "InversionGatePass.aspx/" + methodName,
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
        function CheckIGPApprovalRightsAndShowButton(igpId) {
            callPageMethod('CheckIGPApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetIGPApprovalInfo', { IgpId: igpId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                        }
                    });
                }
            });
        }
        function ApproveIGPFromEdit() {
            var IgpId = '<%= Request.QueryString["IGP_Id"] %>';
            Swal.fire({
                title: 'Approve IGP?',
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
                    callPageMethod('ApproveSingleIGP', { IgpId: IgpId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'IGP has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }

        function validateBatchDuplicates() {
            var isValid = true;
            var batches = [];

            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                var item_code = $($(value).find('td input[name=txtItemCode]')[0]).val();
                var batch_no = $($(value).find('td input[name=BatchNo]')[0]).val();
                var isBatch = $($(value).find('td input[name=Isbatch]')[0]).val();

                if (isBatch == "true" && batch_no && batch_no != "") {
                    var key = item_code + '|' + batch_no;
                    if (batches.indexOf(key) !== -1) {
                        isValid = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Duplicate batch number "' + batch_no + '" found for Item Code "' + item_code + '". Please use unique batch numbers.',
                            showConfirmButton: false,
                            timer: 3000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        return false;
                    }
                    batches.push(key);
                }
            });

            return isValid;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="gp-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="gp-badge"><span class="gp-badge-label">IGP No</span><span class="gp-badge-value" id="badgeIgpNo">---</span></div>
                <div class="gp-badge"><span class="gp-badge-label">Date</span><span class="gp-badge-value" id="badgeIgpDate">---</span></div>
                <div class="gp-badge"><span class="gp-badge-label">Status</span><span class="gp-badge-value" id="badgeIgpStatus">---</span></div>
                <div class="gp-badge"><span class="gp-badge-label">Inspec</span><span class="gp-badge-value" id="badgeIgpInspec">---</span></div>
            </div>
        </div>

        <div id="igpHeader" class="gp-layout">

            <!-- Left: gate pass details + remarks / attachments -->
            <div class="gp-col">
                <section class="gp-card">
                    <h5 class="gp-card-title"><i class="fa fa-truck"></i> Gate Pass Details</h5>
                    <div class="gp-grid">
                        <div class="gp-field">
                            <label id="LblIGP_Num" for="IGP_Num">IGP No</label>
                            <input type="text" class="form-control" id="IGP_Num" name="IGP_Num" readonly="readonly" />
                        </div>
                        <div class="gp-field">
                            <label id="Lbl_Date" for="txtDate">Date</label>
                            <input type="text" class="form-control" id="txtDate" name="txtDate" autocomplete="off" />
                        </div>
                        <div class="gp-field">
                            <label id="lbltxtVendor" for="ddlVendor">Vendor <span class="gp-req">*</span></label>
                            <select class="form-control" id="ddlVendor" name="ddlVendor" onchange="getPONumByVendor(this)">
                            </select>
                        </div>
                        <div class="gp-field">
                            <label id="lblPO_No" for="ddlPONo">Po No</label>
                            <select class="form-control" id="ddlPONo" name="ddlPONo" onchange="PerformPOSearch()">
                            </select>
                        </div>
                        <div class="gp-field">
                            <label id="lblInvorg" for="ddlInv_Org">Warehouse <span class="gp-req">*</span></label>
                            <select class="form-control" id="ddlInv_Org"></select>
                        </div>
                        <div class="gp-field">
                            <label id="LblBranch" for="ddlBranch">Branch</label>
                            <select class="form-control" id="ddlBranch" name="ddlBranch"></select>
                        </div>
                        <div class="gp-field">
                            <label id="LblDriverName" for="DriverName">Driver Name</label>
                            <input type="text" class="form-control" id="DriverName" name="DriverName" autocomplete="off" />
                        </div>
                        <div class="gp-field">
                            <label id="Lbl_Vehiclenum" for="txtVehiclenum">Vehicle #</label>
                            <input type="text" class="form-control" id="txtVehiclenum" name="txtVehiclenum" autocomplete="off" />
                        </div>
                        <div class="gp-field">
                            <label id="lblBility_No" for="txtBility_No">Bility #</label>
                            <input type="text" class="form-control" id="txtBility_No" name="txtBility_No" autocomplete="off" />
                        </div>
                    </div>
                </section>

                <section class="gp-card">
                    <h5 class="gp-card-title"><i class="fa fa-paperclip"></i> Remarks &amp; Attachments</h5>
                    <div class="gp-grid" style="align-items: start;">
                        <div class="gp-field gp-span-2">
                            <label id="lblRemarks" for="txtRemarks">Remarks</label>
                            <textarea class="form-control" id="txtRemarks" rows="2"></textarea>
                        </div>
                        <div class="gp-field gp-span-2">
                            <label id="lblAttachments" for="fileUpload1">Attachments</label>
                            <input type="file" id="fileUpload1" name="fileUpload1" class="form-control" />
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="gp-link">Download</asp:HyperLink>
                        </div>
                    </div>
                </section>
            </div>

            <!-- Right: status -->
            <div class="gp-col">
                <section class="gp-card">
                    <h5 class="gp-card-title"><i class="fa fa-check-square-o"></i> Status</h5>
                    <div class="gp-grid" style="grid-template-columns: minmax(0, 1fr);">
                        <div class="gp-field">
                            <label id="lblStatus" for="txtStatus">Status</label>
                            <input type="text" class="form-control" id="txtStatus" name="txtStatus" readonly="readonly" />
                        </div>
                        <div class="gp-field">
                            <label id="lblStatusinpec" for="txtStatusInspec">Inspec Status</label>
                            <input type="text" class="form-control" id="txtStatusInspec" name="txtStatusInspec" readonly="readonly" />
                        </div>
                    </div>
                </section>
            </div>
        </div>

        <!-- Items -->
        <section class="gp-card">
            <h5 class="gp-card-title"><i class="fa fa-list-alt"></i> Items</h5>
            <div class="gp-table-wrap" id="igpItemTable">
                <table class="table gp-table" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th style="width: 40px;">Sr No.</th>
                            <th style="width: 70px;">PO #</th>
                            <th style="width: 86px;">Item Code</th>
                            <th>Item Description</th>
                            <th style="width: 76px;">UOM_QTY</th>
                            <th style="width: 56px;">Unit</th>
                            <th style="width: 100px;">Batch No</th>
                            <th style="width: 108px;">PO Delivery Date</th>
                            <th style="width: 76px;">PO Qty</th>
                            <th style="width: 76px;">Rcv Qty</th>
                            <th style="width: 76px;">Blnc Qty</th>
                            <th style="width: 84px;">IGP Qty</th>
                            <th style="width: 76px;">Insp Qty</th>
                            <th style="width: 84px;">Bounus Qty</th>
                            <th style="width: 108px;">Mfg Date</th>
                            <th style="width: 108px;">Exp Date</th>
                            <th style="width: 90px;">Sale Rate</th>
                            <th style="width: 40px; display: none;">Rej Qty</th>
                            <th style="width: 54px;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>
            </div>
        </section>

        <!-- Actions -->
        <div class="row">
            <div class="col-lg-10">
                <div class="row">
                    <div class="col-lg-2 col-md-4 col-sm-12" id="SaveButtonToBeHidden">
                        <input type="button" class="btn btn-primry" value="Save" id="btnSave" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-primry" value="Print" name="name" onclick="PrintInwardGatePassDetail();" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn-gray" value="List" onclick="window.location = 'InversionGatePassView.aspx'" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'InversionGatePass.aspx'" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12">
                        <input type="button" style="display: none;" class="btn btn-primry" value="Approve" id="btnApprove" onclick="ApproveIGPFromEdit()" />
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12" id="btnUnApproveToBeHidden">
                        <input type="button" class=" btn-primry" style="width: 103px; display: none" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                    </div>

                    <div class="col-lg-2 col-md-4 col-sm-12" id="btnUnInspecToBeHidden">
                        <input type="button" class="btn-primry" value="Inspec UnApproval" id="btnUnInspec" onclick="UnApproveInspec()" />
                        &nbsp;
                    </div>

                    <div class="col-lg-2 col-md-4 col-sm-12" id="btnPrintInspecToBeHidden">
                        <input type="button" class="btn-primry" value="Print Inspec" id="btnPrintInspec" onclick="PrintInspection()" />
                        &nbsp;
                    </div>
                    <div class="col-lg-2 col-md-4 col-sm-12" id="btnInspecToBeHidden">
                        <input type="button" class="btn btn-primry" value="Inspec Approval" id="btnInspec" onclick="ApproveInspecModal()" />
                        &nbsp;
                    </div>
                </div>
            </div>
        </div>

        <!-- Inspection approval window -->
        <div id="inspecModal" class="modal gp-modal" tabindex="-1" role="dialog">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                        <h5 class="modal-title">Inspec Approval</h5>
                    </div>
                    <div class="gp-modal-scroll">
                        <table class="table" id="InspmodalItemDescription">
                            <thead>
                                <tr>
                                    <th style="display: none;">PO Detail ID</th>
                                    <th style="display: none;">Item Code</th>
                                    <th style="width: 40%;">Item Name</th>
                                    <th style="width: 8%;">PO Qty</th>
                                    <th style="width: 8%;">IGP Qty</th>
                                    <th style="width: 8%;">Insp Qty</th>
                                    <th style="width: 40%;">Remarks</th>
                                </tr>
                            </thead>
                            <tbody>
                            </tbody>
                        </table>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-primry" onclick="ApproveInspec()">Save</button>
                        <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript">
        // title-line badges follow the form fields (the page script fills them in after loading)
        function syncGatePassBadges() {
            $('#badgeIgpNo').text($('#IGP_Num').val() || '---');
            $('#badgeIgpDate').text($('#txtDate').val() || '---');
            $('#badgeIgpStatus').text($('#txtStatus').val() || '---');
            $('#badgeIgpInspec').text($('#txtStatusInspec').val() || '---');
        }
        $(function () {
            syncGatePassBadges();
            setInterval(syncGatePassBadges, 600);
        });
    </script>
</asp:Content>
