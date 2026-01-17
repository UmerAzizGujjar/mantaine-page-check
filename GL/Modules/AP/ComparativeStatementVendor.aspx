<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ComparativeStatementVendor.aspx.cs" Inherits="PMS.AP.ComparativeStatementVendor" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/CRV.css" rel="stylesheet" />
    <script type="text/javascript">
        var amount1 = 0;
        var amount2 = 0;
        var amount3 = 0;
        var amount4 = 0;
        var amount5 = 0;

        var findlow1 = 0;
        var findlow2 = 0;
        var findlow3 = 0;
        var findlow4 = 0;
        var findlow5 = 0;

        var values1 = [];
        var values2 = [];
        var values3 = [];
        var values4 = [];
        var values5 = [];

        var lowrate = parseInt(0);

        var _gloabal = '';
        function Filltaxtype() {
            debugger;
            var optionsVen = '';
            PageMethods.gettaxtype(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsVen += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                _gloabal = optionsVen;
            });
        }

        function FillWarehouse() {

            var optionInv = '';
            PageMethods.fillWarehouse(function (Tests) {

                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlWarehouse').html(optionInv);
            });
        }

        $(document).ready(function () {
            UserRights();
            
            FillWarehouse();
            GetWareHouseCondition();
            setTimeout(function () {
                $('#ddlWarehouse').select2();
            }, 2500);
            $('[id*=checkHeader]').click(function () {
                var isTrue = $('#checkHeader').is(':checked');
                if (isTrue) {
                    debugger;
                    $('.chktd').prop('checked', true);
                    setTimeout(function () {
                        $("#tblPRItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            debugger;
                            var row = $(this);
                            appendrow(row);
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            $('#ddlWarehouse').change(function () {

                $("#ddlWarehouse").attr('disabled', true);
            });
            setTimeout(function () {
                Filltaxtype();
            }, 200);
            debugger;
            <% if (Request.QueryString["CM_ID"] != null)
            { %>
                var CM_ID = '<%= Request.QueryString["CM_ID"]%>'
                LoadVenData(CM_ID);
         <% } %>
            var CM_ID = '<%= Request.QueryString["CM_ID"]%>'

            if (CM_ID == '') {
                $('#ctl00_MainContent_hyperlink1').hide();
                GetNewCSNo();
            }
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txt_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });

            FillVendors();
            getallPaymentTerms();
            getallDeliveryTerms();
            getallSalesTax();
            $("#ctl00_MainContent_ddlPrNo").select2();
            $("#ctl00_MainContent_ddlterms").select2();
            $('#txt_vendorName_vendor1').select2();
            $('#txt_vendorName_vendor2').select2();
            $('#txt_vendorName_vendor3').select2();
            $('#txt_vendorName_vendor4').select2();
            $('#txt_vendorName_vendor5').select2();

            $('#txt_DeliveryTerms_vendor1').select2();
            $('#txt_DeliveryTerms_vendor2').select2();
            $('#txt_DeliveryTerms_vendor3').select2();
            $('#txt_DeliveryTerms_vendor4').select2();
            $('#txt_DeliveryTerms_vendor5').select2();

            $('#txt_paymentTerms_vendor1').select2();
            $('#txt_paymentTerms_vendor2').select2();
            $('#txt_paymentTerms_vendor3').select2();
            $('#txt_paymentTerms_vendor4').select2();
            $('#txt_paymentTerms_vendor5').select2();
        });

        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "ComparativeStatementVendor.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btn_Save').show();
                    } else {
                        $('#btn_Save').hide();
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
        var warehouseCond;
        function GetWareHouseCondition() {
            debugger;
            $.ajax({
                type: "POST",
                url: "ComparativeStatementVendor.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#warehouserow').show();
                    }
                    else {
                        $('#warehouserow').hide();
                        getprNoBy_WareHouseCS()
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });

        }

        function ddlPrNoChanged() {
            debugger
            var pr_id = $("#<%= ddlPrNo.ClientID %>").val();
            LoadPrNoDetail(pr_id);
            $('#PRItemsModel').modal('show');
            $('#txt_remarks').focus();
        }
        function LoadPrNoDetail(pr_id) {
            debugger;
            PageMethods.getPRByID(pr_id, function (data) {
                debugger;
                var Test = JSON.parse(data);
                $('#tblPRItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    debugger;
                    rows = '<tr><td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 1px;" onclick="appendrow(this)"/></td><td style="display:none;">' + Test[i].PR_ID + '</td><td style="display:none;">' + Test[i].PR_Num + '</td><td style="display:none;">' + Test[i].Item_ID + '</td><td style="text-align:left">' + Test[i].Description + '</td><td style="text-align:center;">' + parseFloat(Test[i].Qty).toFixed(2)
                        + '</td><td style="display:none;">' + Test[i].Item_Code + '</td><td style="text-align:center">' + Test[i].Unit + '</td><td style="display:none;">' + Test[i].Required_Date + '</td><td style="display:none;">' + Test[i].PR_Detail_ID + '</td></tr>';
                    $('#tblPRItemstModelTable tbody').append(rows);
                }
                $('#PRItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }

        function appendrow(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            var prid = $($(row).find('td')[1]).text();
            var prnum = $($(row).find('td')[2]).text();
            var item_id = $($(row).find('td')[3]).text();
            var item_name = $($(row).find('td')[4]).text();
            var Qty = $($(row).find('td')[5]).text();
            var itemcode = $($(row).find('td')[6]).text();
            var unit = $($(row).find('td')[7]).text();
            var reqdate = $($(row).find('td')[8]).text();
            var pr_detail_id = $($(row).find('td')[9]).text();
            var length = $("#tblItemDescription tr").length;
            if (unit == "null")
                unit = "";
            if (Qty == "null")
                Qty = "0";
            if (Qty == "NaN")
                Qty = "0";
            var length = $("#tblItemDescription tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }
            var timestamp = parseInt(reqdate.match(/\d+/)[0]);
            var date = new Date(timestamp);
            var formattedDateForDatepicker = $.datepicker.formatDate('dd M yy', date);

            var test_array = $('#tblItemDescription').find('input[name=txt_itemcode][value=' + itemcode + ']');
            if (test_array.length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'This Item already added!',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            else {
                $("#tblItemDescription").append('<tr>' +
                    '<td style="display:none"><input type="hidden" name="txt_pr_id" id="txt_pr_id' + length + '"  value="' + prid + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + prid + '</td>' +
                    '<td style="padding-top: 7px!important;"><input type="hidden" name="txt_prnum" id="txt_prnum' + length + '"  value="' + prnum + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + prnum + '</td>' +
                    '<td style="display:none;"><input type="hidden" name="txtItemId" id="txtItemId' + length + '"  value="' + item_id + '" /> ' + item_id + ' </td>' +
                    '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:center!important;"><input type="hidden" name="txt_itemcode" id="txt_itemcode' + length + '"  value="' + itemcode + '"  style="width:50px !important;text-align:center;font-size:9px;height:20px;"/> ' + itemcode + ' </td>' +
                    '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '"  value="' + item_name + '"/> ' + item_name + ' </td>' +
                    '<td style="text-align:center!important;"><input type="hidden" name="txtUnit" id="txtUnit' + length + '"  value="' + unit + '" />' + unit + ' </td>' +
                    '<td><input type="hidden" readonly id="txt_qty' + length + '"  value="' + Qty + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px" name="txt_qty" /> ' + Qty + '</td>' +
                    '<td style="width: 63px;"><input type="hidden" readonly name="txt_reqdate" id="txt_reqdate' + length + '" value="' + formattedDateForDatepicker + '" style="width:62px !important;text-align:center;font-size:9px;height:20px;" />' + formattedDateForDatepicker + '</td>' +
                    '<td style="display:none"><input type="hidden" id="txt_prdetail_id' + length + '" name="txt_prdetail_id" value="' + pr_detail_id + '" style="width: 75px !important;text-align:right" />' + pr_detail_id + '</td></tr>');
                $('#txt_reqdate' + length).datepicker({ dateFormat: 'dd M yy', }).attr('readonly', 'readonly').datepicker('setDate', formattedDateForDatepicker);
                $('#txt_reqdate' + length).datepicker('destroy');
                length++;
                $('input[name="txt_reqdate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                
                debugger
                var prid = $($(row).find('td')[1]).text();
                var prnum = $($(row).find('td')[2]).text();
                var itemid = $($(row).find('td')[3]).text();
                var itemcode = $($(row).find('td')[6]).text();
                var Description = $($(row).find('td')[4]).text();
                var Qty = $($(row).find('td')[5]).text();
                var prdetailid = $($(row).find('td')[9]).text();
                var grnnum = $($(row).find('td')[10]).text();
                var grnrate = $($(row).find('td')[11]).text();
                rows = '<tr>' +
                    '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                    '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + itemcode + '" readonly="readonly"></td>' +
                    '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="0"></td>' +
                    '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value=""></td>' +
                    '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                    '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="" readonly="readonly"></td>' +
                    '<td style="display:none;">' + grnnum + '</td>' +
                    '<td style="display:none;">' + grnrate + '</td>' +
                    '<td style="display:none;">' + itemid + '</td>' +
                    '<td style="display:none;">' + Description + '</td>' +
                    '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_prdetail_id" name="txt_prdetail_id" value="' + prdetailid + '" readonly="readonly"></td>' +
                    '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_pr_id" name="txt_pr_id" value="' + prid + '" readonly="readonly"></td>' +
                    '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_prnum" name="txt_prnum" value="' + prnum + '" readonly="readonly"></td>' +
                    '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_reqdate" name="txt_reqdate" value="' + formattedDateForDatepicker + '" readonly="readonly"></td>' +
                    '</tr>'
                $("#tblItemDescription11").append(rows);
                $("#tblItemDescription21").append(rows);
                $("#tblItemDescription31").append(rows);
                $("#tblItemDescription41").append(rows);
                $("#tblItemDescription51").append(rows);

                var lastAppendedRow = $('#tblItemDescription1 tbody tr:last');
                var itemcode = $(lastAppendedRow).find('td input[name=txt_itemcode]').val();
                var Qty = $(lastAppendedRow).find('td input[name=txt_qty]').val();
                var amount = $(lastAppendedRow).find('td input[name=txt_amount]').val();
                var grnnum = $(lastAppendedRow).find('td:eq(5)').text();
                var grnrate = $(lastAppendedRow).find('td:eq(6)').text();
                var descrip = $(lastAppendedRow).find('td:eq(8)').text();
                rows = '<tr>' +
                    '<td style="display:none;"><input style="width:80px!important;text-align:right;" type="text" id="txt_grnitemcode" name="txt_grnitemcode" value="' + itemcode + '" readonly="readonly"></td>' +
                    '<td><input style="width:80px!important;text-align:right;" type="text" id="txt_grnappamount" name="txt_grnappamount" value="' + amount + '" readonly="readonly"></td>' +
                    '<td style="display:none;">' + grnnum + '</td>' +
                    '<td style="text-align:right;">' + grnrate + '</td>' +
                    '<td style="display:none;">' + descrip + '</td>' +
                    '</tr>'
                $("#grntable tbody").append(rows);               
            }
        }

        function LoadVenData(CM_ID) {
            debugger
            PageMethods.LoadVenHeader(CM_ID, function (resp) {
                var data = JSON.parse(resp);
                $('#txt_CSno').val(data.CS_Ven_No);
                $('#ddlWarehouse').val(data.Ware_House);
                $('#txt_Cs_Validity').val(data.CS_Validity);
                $('#txtSTAmount_Vend1').val(data.TotalSalesTax1);
                $('#txtSTAmount_Vend2').val(data.TotalSalesTax2);
                $('#txtSTAmount_Vend3').val(data.TotalSalesTax3);
                $('#txtSTAmount_Vend4').val(data.TotalSalesTax4);
                $('#txtSTAmount_Vend5').val(data.TotalSalesTax5);
                $('#txt_remarks').val(data.Remarks);
                $('#txt_status').val(data.Status);
                $('#ctl00_MainContent_ddlterms').val(data.Term_Id);
                var status = $('#txt_status').val();
                setTimeout(function () {
                    $('#ddlWarehouse').val(data.Ware_House).trigger('change');
                }, 1000);
                if (status == "Approved") {
                    UserUnApproveButtonRights();
                    $('#btn_Save').attr("disabled", true);
                }
                if (status == "Cancelled") {
                    $('#btn_Save').attr("disabled", 'disabled');
                    $('#btn_Save').hide();
                    $('#btncancel').hide();

                }
                if (status == "Created") {
                }

                setTimeout(function () {
                    $('#txt_vendorName_vendor1').val(data.Vendor1).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_vendorName_vendor2').val(data.Vendor2).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_vendorName_vendor3').val(data.Vendor3).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_vendorName_vendor4').val(data.Vendor4).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_vendorName_vendor5').val(data.Vendor5).trigger('change');
                }, 1500);

                setTimeout(function () {
                    $('#txt_paymentTerms_vendor1').val(data.Payment_Terms1).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_paymentTerms_vendor2').val(data.Payment_Terms2).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_paymentTerms_vendor3').val(data.Payment_Terms3).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_paymentTerms_vendor4').val(data.Payment_Terms4).trigger('change');
                }, 1500);
                setTimeout(function () {
                    $('#txt_paymentTerms_vendor5').val(data.Payment_Terms5).trigger('change');
                }, 1500);

                setTimeout(function () {
                    $('#txt_DeliveryTerms_vendor1').val(data.Delivery_Terms1).trigger('change');
                }, 2000);
                setTimeout(function () {
                    $('#txt_DeliveryTerms_vendor2').val(data.Delivery_Terms2).trigger('change');
                }, 2000);
                setTimeout(function () {
                    $('#txt_DeliveryTerms_vendor3').val(data.Delivery_Terms3).trigger('change');
                }, 2000);
                setTimeout(function () {
                    $('#txt_DeliveryTerms_vendor4').val(data.Delivery_Terms4).trigger('change');
                }, 2000);
                setTimeout(function () {
                    $('#txt_DeliveryTerms_vendor5').val(data.Delivery_Terms5).trigger('change');
                }, 2000);
                $('#txt_amount_vendor1').val(data.Amount1);
                $('#txt_amount_vendor2').val(data.Amount2);
                $('#txt_amount_vendor3').val(data.Amount3);
                $('#txt_amount_vendor4').val(data.Amount4);
                $('#txt_amount_vendor5').val(data.Amount5);

                $('#txt_Freight_vendor1').val(data.Freight1);
                $('#txt_Freight_vendor2').val(data.Freight2);
                $('#txt_Freight_vendor3').val(data.Freight3);
                $('#txt_Freight_vendor4').val(data.Freight4);
                $('#txt_Freight_vendor5').val(data.Freight5);

                $('#txt_TotalAmount_vendor1').val(data.Total_Amount1);
                $('#txt_TotalAmount_vendor2').val(data.Total_Amount2);
                $('#txt_TotalAmount_vendor3').val(data.Total_Amount3);
                $('#txt_TotalAmount_vendor4').val(data.Total_Amount4);
                $('#txt_TotalAmount_vendor5').val(data.Total_Amount5);

                LoadVenDetails(CM_ID);
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function LoadVenDetails(CM_ID) {
            debugger
            PageMethods.LoadVenDetail(CM_ID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                var rowsitem = '';
                var rows1 = '';
                var rows2 = '';
                var rows3 = '';
                var rows4 = '';
                var rows5 = '';
                var rows6 = '';
                var grnnum = 0;
                var grnrate = 0;
                selectedOptions = data;
                $.each(data, function (key, value) {
                    debugger;
                    var checkrate1 = value.Rate1;
                    if (checkrate1 != null) {
                        var rate1 = value.Rate1;
                    }
                    else {
                        rate1 = '';
                    }
                    var checkvenamount1 = value.Vendor_Amount1;
                    if (checkvenamount1 != null) {
                        var venamount1 = value.Vendor_Amount1;
                    }
                    else {
                        venamount1 = '';
                    }
                    var timestamp = parseInt(value.ReqDate.match(/\d+/)[0]);
                    var date = new Date(timestamp);
                    var formattedDateForDatepicker = $.datepicker.formatDate('dd M yy', date);

                    rows1 += '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + value.Item_Code + '"      readonly="readonly"></   td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="' + value.Qty1 + '"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value="' + rate1 + '"></td>' +
                        '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="' + venamount1 + '" readonly="readonly"></td>' +
                        '<td style="display:none;">' + grnnum + '</td>' +
                        '<td style="display:none;">' + grnrate + '</td>' +
                        '<td style="display:none;">' + value.Item_ID + '</td>' +
                        '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_prdetail_id" name="txt_prdetail_id" value="' + value.PR_Detail_ID + '" readonly="readonly"></   td>' +
                        '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_pr_id" name="txt_pr_id" value="' + value.PRID + '" readonly="readonly"></td>' +
                        '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_prnum" name="txt_prnum" value="' + value.PRNUM + '" readonly="readonly"></td>' +
                        '<td style="display:none;"><input style="width:100%!important;" type="text" id="txt_reqdate" name="txt_reqdate" value="' + formattedDateForDatepicker + '" readonly="readonly"></td>' +
                        '</tr>'

                    rowsitem += '<tr>' +
                        '<td style="display:none"><input type="hidden" name="txt_pr_id" id="txt_pr_id"  value="' + value.PRID + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + value.PRID + '</td>' +
                        '<td style="padding-top: 7px!important;"><input type="hidden" name="txt_prnum" id="txt_prnum"  value="' + value.PRNUM + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + value.PRNUM + '</td>' +
                        '<td style="display:none;"> ' + value.Item_ID + ' </td>' +
                        '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:center!important;"><input type="hidden" name="txt_itemcode" id="txt_itemcode"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:center;font-size:9px;height:20px;"/>' + value.Item_Code + '</td>' +
                        '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName"  value="' + value.Description + '"/>' + value.Description + '</td>' +
                        '<td style="text-align:center!important;"><input type="hidden" name="txtUnit" id="txtUnit"  value="' + value.UOM + '" />' + value.UOM + '</td>' +
                        '<td><input type="hidden" readonly id="txtItemQty"  value="' + value.PRQty + '"  style="text-align:right ;width:50px !important;font-size:9px;height:20px" name="txtItemQty" />' + value.PRQty + '</td>' +
                        '<td style="width: 63px;"><input type="hidden" readonly name="txt_reqdate" id="txt_reqdate" value="' + formattedDateForDatepicker + '" style="width:62px !important;text-align:center;font-size:9px;height:20px;" />' + formattedDateForDatepicker + '</td>' +
                        '<td style="display:none"><input type="hidden" id="txt_pr_id" name="txt_pr_id" value="' + value.PR_Detail_ID + '" style="width: 75px !important;text-align:right" />' + value.PR_Detail_ID + '</td></tr>'
                    length++;
                });
                $("#tblItemDescription").append(rowsitem);
                $("#tblItemDescription11").append(rows1);

                $("#tblItemDescription11").each(function (key, value) {
                    debugger;
                    var row = $(this);
                    $.each(selectedOptions, function (key, value) {
                        var checkbit1 = value.Vendor_bit_1;
                        if (checkbit1 == true) {
                            $($(row).find('tr').find('input[type="checkbox"]')[key]).prop('checked', true);
                        }
                        setTimeout(function () {
                            $($(row).find('td select[name=ddlItemSTAX]')).val(value.SalesTaxPer1);
                        }, 2000); 
                    });
                });

                $.each(data, function (key, value) {
                    debugger
                    var checkrate2 = value.Rate2;
                    if (checkrate2 != null) {
                        var rate2 = value.Rate2;
                    }
                    else {
                        rate2 = '';
                    }
                    var checkvenamount2 = value.Vendor_Amount2;
                    if (checkvenamount2 != null) {
                        var venamount2 = value.Vendor_Amount2;
                    }
                    else {
                        venamount2 = '';
                    }
                    rows2 += '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + value.Item_Code + '" readonly="readonly"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="' + value.Qty2 + '"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value="' + rate2 + '"></td>' +
                        '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="' + venamount2 + '" readonly="readonly"></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription21").append(rows2);
                $("#tblItemDescription21").each(function (key, value) {
                    debugger;
                    var row = $(this);
                    $.each(selectedOptions, function (key, value) {
                        var checkbit2 = value.Vendor_bit_2;
                        if (checkbit2 == true) {
                            $($(row).find('tr').find('input[type="checkbox"]')[key]).prop('checked', true);
                        }
                        setTimeout(function () {
                            $($(row).find('td select[name=ddlItemSTAX]')).val(value.SalesTaxPer2);
                        }, 2000); 
                    });
                });
                $.each(data, function (key, value) {
                    debugger
                    var checkrate3 = value.Rate3;
                    if (checkrate3 != null) {
                        var rate3 = value.Rate3;
                    }
                    else {
                        rate3 = '';
                    }
                    var checkvenamount3 = value.Vendor_Amount3;
                    if (checkvenamount3 != null) {
                        var venamount3 = value.Vendor_Amount3;
                    }
                    else {
                        venamount3 = '';
                    }
                    rows3 += '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + value.Item_Code + '" readonly="readonly"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="' + value.Qty3 + '"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value="' + rate3 + '"></td>' +
                        '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="' + venamount3 + '" readonly="readonly"></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription31").append(rows3);

                $("#tblItemDescription31").each(function (key, value) {
                    debugger;
                    var row = $(this);
                    $.each(selectedOptions, function (key, value) {
                        var checkbit3 = value.Vendor_bit_3;
                        if (checkbit3 == true) {
                            $($(row).find('tr').find('input[type="checkbox"]')[key]).prop('checked', true);
                        }
                        setTimeout(function () {
                            $($(row).find('td select[name=ddlItemSTAX]')).val(value.SalesTaxPer3);
                        }, 2000); 
                    });
                });
                $.each(data, function (key, value) {
                    debugger
                    var checkrate4 = value.Rate4;
                    if (checkrate4 != null) {
                        var rate4 = value.Rate4;
                    }
                    else {
                        rate4 = '';
                    }
                    var checkvenamount4 = value.Vendor_Amount4;
                    if (checkvenamount4 != null) {
                        var venamount4 = value.Vendor_Amount4;
                    }
                    else {
                        venamount4 = '';
                    }
                    rows4 += '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + value.Item_Code + '" readonly="readonly"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="' + value.Qty4 + '"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value="' + rate4 + '"></td>' +
                        '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="' + venamount4 + '" readonly="readonly"></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription41").append(rows4);

                $("#tblItemDescription41").each(function (key, value) {
                    debugger;
                    var row = $(this);
                    $.each(selectedOptions, function (key, value) {
                        var checkbit4 = value.Vendor_bit_4;
                        if (checkbit4 == true) {
                            $($(row).find('tr').find('input[type="checkbox"]')[key]).prop('checked', true);
                        }
                        setTimeout(function () {
                            $($(row).find('td select[name=ddlItemSTAX]')).val(value.SalesTaxPer4);
                        }, 2000); 
                    });
                });

                $.each(data, function (key, value) {
                    debugger
                    var checkrate5 = value.Rate5;
                    if (checkrate5 != null) {
                        var rate5 = value.Rate5;
                    }
                    else {
                        rate5 = '';
                    }
                    var checkvenamount5 = value.Vendor_Amount5;
                    if (checkvenamount5 != null) {
                        var venamount5 = value.Vendor_Amount5;
                    }
                    else {
                        venamount5 = '';
                    }
                    rows5 += '<tr>' +
                        '<td><input name="chkselect" type="checkbox" class="chktd" id="chktd" name="chktd" onclick="appendtogrn(this)" style=" margin-top: -2px; margin-left: 0px;height: 36px;"/></td>' +
                        '<td style="display:none;"><input style="width:100%!important;text-align:right;" type="text" id="txt_itemcode" name="txt_itemcode" value="' + value.Item_Code + '" readonly="readonly"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_qty" name="txt_qty" onchange="CalculateAmonut(this)" value="' + value.Qty5 + '"></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_rate" name="txt_rate" onchange="CalculateAmonut(this)" value="' + rate5 + '"></td>' +
                        '<td><select id="ddlItemSTAX" name="ddlItemSTAX" onchange="CalculateAmonut(this)" style="text-align:right;width:100%!important"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td><input style="width:100%!important;text-align:right;" type="text" id="txt_amount" name="txt_amount" value="' + venamount5 + '" readonly="readonly"></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription51").append(rows5);

                $("#tblItemDescription51").each(function (key, value) {
                    debugger;
                    var row = $(this);
                    $.each(selectedOptions, function (key, value) {
                        var checkbit5 = value.Vendor_bit_5;
                        if (checkbit5 == true) {
                            $($(row).find('tr').find('input[type="checkbox"]')[key]).prop('checked', true);
                        }
                        setTimeout(function () {
                            $($(row).find('td select[name=ddlItemSTAX]')).val(value.SalesTaxPer5);
                        }, 2000); 
                    });
                });

                $.each(data, function (key, value) {
                    debugger
                    document.getElementById("grntable").style.marginTop = "145px";
                    var chktotappamount = value.Total_App_Amount;
                    if (chktotappamount != null) {
                        var TotalappAmou = value.Total_App_Amount;
                    }
                    else {
                        TotalappAmou = '';
                    }
                    var chklstgrnnum = value.Last_GRN_No;
                    if (chklstgrnnum != null) {
                        var lastgrnum = value.Last_GRN_No;
                    }
                    else {
                        lastgrnum = '';
                    }
                    var chklstgrnrate = value.Last_GRN_Rate;
                    if (chklstgrnrate != null) {
                        var lastgrnrate = value.Last_GRN_Rate;
                    }
                    else {
                        lastgrnrate = '';
                    }                   
                        debugger
                        rows6 += '<tr>' +
                            '<td style="display:none;" ><input style="width:80px!important;text-align:right;" type="text" id="txt_grnitemcode" name="txt_grnitemcode" value="' + value.Item_Code + '" readonly="readonly"></td>' +
                            '<td><input style="width:80px!important;text-align:right;" type="text" id="txt_grnappamount" name="txt_grnappamount" value="' + TotalappAmou + '" readonly="readonly"></td>' +
                            '<td style="display:none;">' + lastgrnum + '</td>' +
                            '<td style="text-align:right;">' + lastgrnrate + '</td>' +
                            '<td style="display:none;">' + value.Description + '</td>' +
                            '</tr>'         
                });
                debugger
                $("#grntablebody").append(rows6);

                $('#btn_Save').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function GetNewCSNo() {
            PageMethods.GetNewCSNo(function (resp) {
                $('#txt_CSno').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function getallPaymentTerms() {
            PageMethods.GetPaymentTerms(function (Tests) {
                var optionfed = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionfed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';

                });
                $('#txt_paymentTerms_vendor1').html(optionfed);
                $('#txt_paymentTerms_vendor2').html(optionfed);
                $('#txt_paymentTerms_vendor3').html(optionfed);
                $('#txt_paymentTerms_vendor4').html(optionfed);
                $('#txt_paymentTerms_vendor5').html(optionfed);
            });
        }

        function getallDeliveryTerms() {
            PageMethods.GetDeliveryTerms(function (Tests) {
                var optionfed = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionfed += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#txt_DeliveryTerms_vendor1').html(optionfed);
                $('#txt_DeliveryTerms_vendor2').html(optionfed);
                $('#txt_DeliveryTerms_vendor3').html(optionfed);
                $('#txt_DeliveryTerms_vendor4').html(optionfed);
                $('#txt_DeliveryTerms_vendor5').html(optionfed);
            });
        }

        function getallSalesTax() {
            PageMethods.GetSalesTax(function (Tests) {
                var optionfed = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionfed += '<option value="' + value.Sales_Tax_ID + '" >' + value.Sales_Tax_Perc + '</option>';
                });
                $('#txt_SalesTax_vendor1').html(optionfed);
                $('#txt_SalesTax_vendor2').html(optionfed);
                $('#txt_SalesTax_vendor3').html(optionfed);
                $('#txt_SalesTax_vendor4').html(optionfed);
                $('#txt_SalesTax_vendor5').html(optionfed);
            });
        }      

        function CalculateAmonut($this) {
            debugger;         

            var vendors = [
                $('#txt_vendorName_vendor1').val(),
                $('#txt_vendorName_vendor2').val(),
                $('#txt_vendorName_vendor3').val(),
                $('#txt_vendorName_vendor4').val(),
                $('#txt_vendorName_vendor5').val()
            ];

            var selectedVendorsCount = vendors.filter(function (vendor) {
                return vendor !== '0';
            }).length;
            if (selectedVendorsCount < 2) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $($this).val(''); 
                return false;
            }

            var index = $($this).closest('tr').index() + 1;                        
            
            var totalqty = $('#tblDetails tr:eq(' + index + ') input[name=txt_qty]').val();
            var qty1 = $('#tblItemDescription1 tr:eq(' + index + ') input[name=txt_qty]').val();
            var qty2 = $('#tblItemDescription2 tr:eq(' + index + ') input[name=txt_qty]').val();
            var qty3 = $('#tblItemDescription3 tr:eq(' + index + ') input[name=txt_qty]').val();
            var qty4 = $('#tblItemDescription4 tr:eq(' + index + ') input[name=txt_qty]').val();
            var qty5 = $('#tblItemDescription5 tr:eq(' + index + ') input[name=txt_qty]').val();           

            if (qty1 > parseFloat(totalqty)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Vendor 1 Item Quantity cannot be greater than Total Item Quantity.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return false;
            }
            if (qty2 > parseFloat(totalqty)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Vendor 2 Item Quantity cannot be greater than Total Item Quantity.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return false;
            }
            if (qty3 > parseFloat(totalqty)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Vendor 3 Item Quantity cannot be greater than Total Item Quantity.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return false;
            }
            if (qty4 > parseFloat(totalqty)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Vendor 4 Item Quantity cannot be greater than Total Item Quantity.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (qty5 > parseFloat(totalqty)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Vendor 5 Item Quantity cannot be greater than Total Item Quantity.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }

         
            var tableid = $($this).closest('table').attr('id');
            var Amount = 0;
            var STAmount = 0;
            var totaltaxamount = 0;
            var amtwithtaxprice = 0;
            var TotalAmount = 0;

            $.each($('#' + tableid + ' tbody tr'), function (key, value) {
                debugger

                var qty = $($(value).find('td input[name=txt_qty]')).val();
                var rate = $($(value).find('td input[name=txt_rate]')).val();
                Amount = parseFloat(qty * rate);
                var STpercent = 0;
                if ($(value).find('td select[name=ddlItemSTAX]').val() !== '0') {
                    STpercent = parseFloat($(value).find('td select[name=ddlItemSTAX] :selected').text()) || 0;
                }
                STAmount = (STpercent / 100) * Amount;
                amtwithtaxprice = parseFloat(Amount + STAmount);
                $($(value).find('td input[name=txt_amount]')).val(amtwithtaxprice);

                if ($(value).find('input[name=chkselect]').is(':checked')) {
                    var getamount = $($(value).find('td input[name=txt_amount]')).val();
                    TotalAmount += parseFloat(getamount);
                    totaltaxamount += parseFloat(STAmount);
                }
            });              

            if (tableid == 'tblItemDescription1') {
                if ($('#txt_vendorName_vendor1').val() == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor 1',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#tblItemDescription1 tr:eq(' + index + ') input[name=txt_qty]').val(0);
                    return false;
                }
                $('#txt_amount_vendor1').val(TotalAmount);
                var getfinalamount = $('#txt_amount_vendor1').val();
                var getfreightamount = $('#txt_Freight_vendor1').val();
                if (getfreightamount == "") {
                    getfreightamount = 0;
                }
                $('#txtSTAmount_Vend1').val(totaltaxamount);
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor1').val(newtotalamount);
            }

            if (tableid == 'tblItemDescription2') {
                if ($('#txt_vendorName_vendor2').val() == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor 2',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#tblItemDescription2 tr:eq(' + index + ') input[name=txt_qty]').val(0);
                    return false;                    
                }
                $('#txt_amount_vendor2').val(TotalAmount);
                var getfinalamount = $('#txt_amount_vendor2').val();
                var getfreightamount = $('#txt_Freight_vendor2').val();
                if (getfreightamount == "") {
                    getfreightamount = 0;
                }
                $('#txtSTAmount_Vend2').val(totaltaxamount);
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor2').val(newtotalamount);
            }

            if (tableid == 'tblItemDescription3') {
                if ($('#txt_vendorName_vendor3').val() == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor 3',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#tblItemDescription3 tr:eq(' + index + ') input[name=txt_qty]').val(0);
                    return false;
                }
                $('#txt_amount_vendor3').val(TotalAmount);
                var getfinalamount = $('#txt_amount_vendor3').val();
                var getfreightamount = $('#txt_Freight_vendor3').val();
                if (getfreightamount == "") {
                    getfreightamount = 0;
                }
                $('#txtSTAmount_Vend3').val(totaltaxamount);
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor3').val(newtotalamount);
            }

            if (tableid == 'tblItemDescription4') {
                if ($('#txt_vendorName_vendor4').val() == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor 4',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#tblItemDescription4 tr:eq(' + index + ') input[name=txt_qty]').val(0);
                    return false;
                }
                $('#txt_amount_vendor4').val(TotalAmount);
                var getfinalamount = $('#txt_amount_vendor4').val();
                var getfreightamount = $('#txt_Freight_vendor4').val();
                if (getfreightamount == "") {
                    getfreightamount = 0;
                }
                $('#txtSTAmount_Vend4').val(totaltaxamount);
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor4').val(newtotalamount);
            }
            if (tableid == 'tblItemDescription5') {
                if ($('#txt_vendorName_vendor5').val() == 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor 5',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $('#tblItemDescription5 tr:eq(' + index + ') input[name=txt_qty]').val(0); 
                    return false;
                }
                $('#txt_amount_vendor5').val(TotalAmount);
                var getfinalamount = $('#txt_amount_vendor5').val();
                var getfreightamount = $('#txt_Freight_vendor5').val();
                if (getfreightamount == "") {
                    getfreightamount = 0;
                }
                $('#txtSTAmount_Vend5').val(totaltaxamount);
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor5').val(newtotalamount);
            }
        }

        function calculate2($this) {
            debugger
            var tableid = $($this).closest('table').attr('id');

            if (tableid == 'bottomtable1') {
                var getfinalamount = $('#txt_amount_vendor1').val();
                var getfreightamount = $('#txt_Freight_vendor1').val();
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor1').val(newtotalamount);
            }

            if (tableid == 'bottomtable2') {
                var getfinalamount = $('#txt_amount_vendor2').val();
                var getfreightamount = $('#txt_Freight_vendor2').val();
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor2').val(newtotalamount);
            }

            if (tableid == 'bottomtable3') {
                var getfinalamount = $('#txt_amount_vendor3').val();
                var getfreightamount = $('#txt_Freight_vendor3').val();
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor3').val(newtotalamount);
            }

            if (tableid == 'bottomtable4') {
                var getfinalamount = $('#txt_amount_vendor4').val();
                var getfreightamount = $('#txt_Freight_vendor4').val();
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor4').val(newtotalamount);
            }

            if (tableid == 'bottomtable5') {
                var getfinalamount = $('#txt_amount_vendor5').val();
                var getfreightamount = $('#txt_Freight_vendor5').val();
                var newtotalamount = parseFloat(getfinalamount) + parseFloat(getfreightamount);
                $('#txt_TotalAmount_vendor5').val(newtotalamount);
            }
        }

        function FillVendors() {
            PageMethods.getVendorDDLlist(function (Tests) {
                debugger
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsVen += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                });
                $('#txt_vendorName_vendor1').html(optionsVen);
                $('#txt_vendorName_vendor2').html(optionsVen);
                $('#txt_vendorName_vendor3').html(optionsVen);
                $('#txt_vendorName_vendor4').html(optionsVen);
                $('#txt_vendorName_vendor5').html(optionsVen);
            });
        }
        
        function appendtogrn(anchor) {
            debugger;
            var row = $(anchor).closest('tr');
            var Qty = row.find('input[name=txt_qty]').val();
            var Rate = row.find('input[name=txt_rate]').val();

            var amount1 = 0;
            var amount2 = 0;
            var amount3 = 0;
            var amount4 = 0;
            var amount5 = 0;
            var itemcodevendor = row.find('input[name=txt_itemcode]').val();

            if (Rate == null || Rate <= 0 || Rate == '') {
                row.find('input[name=chkselect]').prop('checked', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Rate to select Vendor for Item',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }

            if (Qty == null || Qty <= 0 || Qty == '') {
                row.find('input[name=chkselect]').prop('checked', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Qty to select Vendor for Item',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            var rowIndex =row.index() + 1;

             if ($('#tblItemDescription1 tr:eq(' + rowIndex + ') input[name=chkselect]').is(':checked')) {
                 amount1 = parseFloat($('#tblItemDescription1 tr:eq(' + rowIndex + ') input[name=txt_amount]').val()) || 0;
             }
             if ($('#tblItemDescription2 tr:eq(' + rowIndex + ') input[name=chkselect]').is(':checked')) {
                 amount2 = parseFloat($('#tblItemDescription2 tr:eq(' + rowIndex + ') input[name=txt_amount]').val()) || 0;
             }
             if ($('#tblItemDescription3 tr:eq(' + rowIndex + ') input[name=chkselect]').is(':checked')) {
                 amount3 = parseFloat($('#tblItemDescription3 tr:eq(' + rowIndex + ') input[name=txt_amount]').val()) || 0;
             }
             if ($('#tblItemDescription4 tr:eq(' + rowIndex + ') input[name=chkselect]').is(':checked')) {
                 amount4 = parseFloat($('#tblItemDescription4 tr:eq(' + rowIndex + ') input[name=txt_amount]').val()) || 0;
             }
             if ($('#tblItemDescription5 tr:eq(' + rowIndex + ') input[name=chkselect]').is(':checked')) {
                 amount5 = parseFloat($('#tblItemDescription5 tr:eq(' + rowIndex + ') input[name=txt_amount]').val()) || 0;
             }
            var totalamt = parseFloat(amount1 + amount2 + amount3 + amount4 + amount5); 
            var checkboxChecked = row.find('input[name=chkselect]').is(':checked');
            debugger;
            $('#grntable tbody tr').each(function () {
                var grnitemcode = $(this).find('input[name=txt_grnitemcode]').val();
                if (grnitemcode == itemcodevendor) {
                    if (!checkboxChecked) {
                        $(this).find('input[name=txt_grnappamount]').val(totalamt);
                    } else {
                        $(this).find('input[name=txt_grnappamount]').val(totalamt);
                    }
                }
            });
            debugger
            CalculateAmonut($(anchor));
        }

        function SaveAllRecord() {
            debugger;
            var btnSave = $('#btn_Save').val();
            var csno = $('#txt_CSno').val();
            var date = $('#txt_Date').val();
            var csvalidity = $('#txt_Cs_Validity').val();
            var remarks = $('#txt_remarks').val();
            var Warehouse = $('#ddlWarehouse').val();
            var txtstatus = $('#txt_status').val();
            var Term_Id =$('#ctl00_MainContent_ddlterms').val();

            var txt_vendorName_vendor1 = $('#txt_vendorName_vendor1').val() || 0;
            var txt_vendorName_vendor2 = $('#txt_vendorName_vendor2').val() || 0;
            var txt_vendorName_vendor3 = $('#txt_vendorName_vendor3').val() || 0;
            var txt_vendorName_vendor4 = $('#txt_vendorName_vendor4').val() || 0;
            var txt_vendorName_vendor5 = $('#txt_vendorName_vendor5').val() || 0;

            if (txt_vendorName_vendor1 == 0 && txt_vendorName_vendor2 == 0 && txt_vendorName_vendor3 == 0 && txt_vendorName_vendor4 == 0 && txt_vendorName_vendor5 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (txt_vendorName_vendor2 == 0 && txt_vendorName_vendor3 == 0 && txt_vendorName_vendor4 == 0 && txt_vendorName_vendor5 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return false;
            }
            if (txt_vendorName_vendor1 == 0 && txt_vendorName_vendor3 == 0 && txt_vendorName_vendor4 == 0 && txt_vendorName_vendor5 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (txt_vendorName_vendor1 == 0 && txt_vendorName_vendor2 == 0 && txt_vendorName_vendor4 == 0 && txt_vendorName_vendor5 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (txt_vendorName_vendor1 == 0 && txt_vendorName_vendor2 == 0 && txt_vendorName_vendor3 == 0 && txt_vendorName_vendor5 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }
            if (txt_vendorName_vendor1 == 0 && txt_vendorName_vendor2 == 0 && txt_vendorName_vendor3 == 0 && txt_vendorName_vendor4 == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select at least Two Vendors for CS',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }


            if ($('#tblItemDescription11 tr').length === 0 || $('#tblItemDescription21 tr').length === 0 || $('#tblItemDescription31 tr').length === 0 || $('#tblItemDescription41 tr').length === 0 || $('#tblItemDescription51 tr').length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please add at Least one Row',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return false;
            }

            var txt_paymentTerms_vendor1 = $('#txt_paymentTerms_vendor1').val() || 0;
            var txt_paymentTerms_vendor2 = $('#txt_paymentTerms_vendor2').val() || 0;
            var txt_paymentTerms_vendor3 = $('#txt_paymentTerms_vendor3').val() || 0;
            var txt_paymentTerms_vendor4 = $('#txt_paymentTerms_vendor4').val() || 0;
            var txt_paymentTerms_vendor5 = $('#txt_paymentTerms_vendor5').val() || 0;

            var txt_DeliveryTerms_vendor1 = $('#txt_DeliveryTerms_vendor1').val() || 0;
            var txt_DeliveryTerms_vendor2 = $('#txt_DeliveryTerms_vendor2').val() || 0;
            var txt_DeliveryTerms_vendor3 = $('#txt_DeliveryTerms_vendor3').val() || 0;
            var txt_DeliveryTerms_vendor4 = $('#txt_DeliveryTerms_vendor4').val() || 0;
            var txt_DeliveryTerms_vendor5 = $('#txt_DeliveryTerms_vendor5').val() || 0;

            var TotalSalesTax1 = $('#txtSTAmount_Vend1').val() || 0;
            var TotalSalesTax2 = $('#txtSTAmount_Vend2').val() || 0;
            var TotalSalesTax3 = $('#txtSTAmount_Vend3').val() || 0;
            var TotalSalesTax4 = $('#txtSTAmount_Vend4').val() || 0;
            var TotalSalesTax5 = $('#txtSTAmount_Vend5').val() || 0;

            var txt_amount_vendor1 = $('#txt_amount_vendor1').val() || 0;
            var txt_amount_vendor2 = $('#txt_amount_vendor2').val() || 0;
            var txt_amount_vendor3 = $('#txt_amount_vendor3').val() || 0;
            var txt_amount_vendor4 = $('#txt_amount_vendor4').val() || 0;
            var txt_amount_vendor5 = $('#txt_amount_vendor5').val() || 0;

            var txt_Freight_vendor1 = $('#txt_Freight_vendor1').val() || 0;
            var txt_Freight_vendor2 = $('#txt_Freight_vendor2').val() || 0;
            var txt_Freight_vendor3 = $('#txt_Freight_vendor3').val() || 0;
            var txt_Freight_vendor4 = $('#txt_Freight_vendor4').val() || 0;
            var txt_Freight_vendor5 = $('#txt_Freight_vendor5').val() || 0;

            var txt_TotalAmount_vendor1 = $('#txt_TotalAmount_vendor1').val() || 0;
            var txt_TotalAmount_vendor2 = $('#txt_TotalAmount_vendor2').val() || 0;
            var txt_TotalAmount_vendor3 = $('#txt_TotalAmount_vendor3').val() || 0;
            var txt_TotalAmount_vendor4 = $('#txt_TotalAmount_vendor4').val() || 0;
            var txt_TotalAmount_vendor5 = $('#txt_TotalAmount_vendor5').val() || 0;

            var table1 = $('#tblItemDescription11');
            var table2 = $('#tblItemDescription21');
            var table3 = $('#tblItemDescription31');
            var table4 = $('#tblItemDescription41');
            var table5 = $('#tblItemDescription51');
            var table6 = $('#grntablebody');

            var Item_list1 = [];
            var Item_list2 = [];
            var Item_list3 = [];
            var Item_list4 = [];
            var Item_list5 = [];
            var GRNItem_list = [];

            table1.find('tr').each(function (key, value) {
                debugger;
                    Item_list1.push({
                        'vendbit1': $(value).find('input[name="chkselect"]').prop('checked'),
                        'prno': $(value).find('td input[name=txt_prnum]').val(),
                        'prid': $(value).find('td input[name=txt_pr_id]').val(),
                        'reqdate': $(value).find('td input[name=txt_reqdate]').val(),
                        'itemid': $($(value).find('td')[8]).text(),
                        'itemcode': $(value).find('td input[name=txt_itemcode]').val(),
                        'qty1': $(value).find('td input[name=txt_qty]').val(),
                        'rate1': $(value).find('td input[name=txt_rate]').val(),
                        'salesperc1': $(value).find('td select[name=ddlItemSTAX]').val(),
                        'vendoramount1': $(value).find('td input[name=txt_amount]').val(),
                        'prdet_id': $(value).find('td input[name=txt_prdetail_id]').val(),
                    });
            });


            table2.find('tr').each(function (key, value) {               
                    debugger;
                    Item_list2.push({
                        'vendbit2': $(value).find('input[name="chkselect"]').prop('checked'),
                        'qty2': $(value).find('td input[name=txt_qty]').val(),
                        'rate2': $(value).find('td input[name=txt_rate]').val(),
                        'salesperc2': $(value).find('td select[name=ddlItemSTAX]').val(),
                        'vendoramount2': $(value).find('td input[name=txt_amount]').val(),
                    });               
            });

            table3.find('tr').each(function (key, value) {                
                    debugger;
                    Item_list3.push({
                        'vendbit3': $(value).find('input[name="chkselect"]').prop('checked'),
                        'qty3': $(value).find('td input[name=txt_qty]').val(),
                        'rate3': $(value).find('td input[name=txt_rate]').val(),
                        'salesperc3': $(value).find('td select[name=ddlItemSTAX]').val(),
                        'vendoramount3': $(value).find('td input[name=txt_amount]').val(),
                    });              
            });

            table4.find('tr').each(function (key, value) {
                debugger;              
                    Item_list4.push({
                        'vendbit4': $(value).find('input[name="chkselect"]').prop('checked'),
                        'qty4': $(value).find('td input[name=txt_qty]').val(),
                        'rate4': $(value).find('td input[name=txt_rate]').val(),
                        'salesperc4': $(value).find('td select[name=ddlItemSTAX]').val(),
                        'vendoramount4': $(value).find('td input[name=txt_amount]').val(),
                    });               
            });

            table5.find('tr').each(function (key, value) {
                debugger;               
                    Item_list5.push({
                        'vendbit5': $(value).find('input[name="chkselect"]').prop('checked'),
                        'qty5': $(value).find('td input[name=txt_qty]').val(),
                        'rate5': $(value).find('td input[name=txt_rate]').val(),
                        'salesperc5': $(value).find('td select[name=ddlItemSTAX]').val(),
                        'vendoramount5': $(value).find('td input[name=txt_amount]').val(),
                    });                
            });

            table6.find('tr').each(function (key, value) {
                debugger;
                GRNItem_list.push({
                    'lastgrnnumber': $($(value).find('td')[2]).text(),
                    'lastgrnrate': $($(value).find('td')[3]).text(),
                    'grnappamount': $(value).find('td input[name=txt_grnappamount]').val(),
                });
            });

            var AllItemDetail = {
                'txt_vendorName_vendor1': txt_vendorName_vendor1,
                'txt_vendorName_vendor2': txt_vendorName_vendor2,
                'txt_vendorName_vendor3': txt_vendorName_vendor3,
                'txt_vendorName_vendor4': txt_vendorName_vendor4,
                'txt_vendorName_vendor5': txt_vendorName_vendor5,

                'txt_paymentTerms_vendor1': txt_paymentTerms_vendor1,
                'txt_paymentTerms_vendor2': txt_paymentTerms_vendor2,
                'txt_paymentTerms_vendor3': txt_paymentTerms_vendor3,
                'txt_paymentTerms_vendor4': txt_paymentTerms_vendor4,
                'txt_paymentTerms_vendor5': txt_paymentTerms_vendor5,

                'txt_DeliveryTerms_vendor1': txt_DeliveryTerms_vendor1,
                'txt_DeliveryTerms_vendor2': txt_DeliveryTerms_vendor2,
                'txt_DeliveryTerms_vendor3': txt_DeliveryTerms_vendor3,
                'txt_DeliveryTerms_vendor4': txt_DeliveryTerms_vendor4,
                'txt_DeliveryTerms_vendor5': txt_DeliveryTerms_vendor5,

                'TotalSalesTax1': TotalSalesTax1,
                'TotalSalesTax2': TotalSalesTax2,
                'TotalSalesTax3': TotalSalesTax3,
                'TotalSalesTax4': TotalSalesTax4,
                'TotalSalesTax5': TotalSalesTax5,

                'txt_amount_vendor1': txt_amount_vendor1,
                'txt_amount_vendor2': txt_amount_vendor2,
                'txt_amount_vendor3': txt_amount_vendor3,
                'txt_amount_vendor4': txt_amount_vendor4,
                'txt_amount_vendor5': txt_amount_vendor5,

                'txt_Freight_vendor1': txt_Freight_vendor1,
                'txt_Freight_vendor2': txt_Freight_vendor2,
                'txt_Freight_vendor3': txt_Freight_vendor3,
                'txt_Freight_vendor4': txt_Freight_vendor4,
                'txt_Freight_vendor5': txt_Freight_vendor5,

                'txt_TotalAmount_vendor1': txt_TotalAmount_vendor1,
                'txt_TotalAmount_vendor2': txt_TotalAmount_vendor2,
                'txt_TotalAmount_vendor3': txt_TotalAmount_vendor3,
                'txt_TotalAmount_vendor4': txt_TotalAmount_vendor4,
                'txt_TotalAmount_vendor5': txt_TotalAmount_vendor5,

                'csno': csno,
                'date': date,
                'csvalidity': csvalidity,
                'remarks': remarks,
                'txtstatus': txtstatus,
                'Term_Id': Term_Id,
                'Warehouse': Warehouse,

                'Item_list1': Item_list1,
                'Item_list2': Item_list2,
                'Item_list3': Item_list3,
                'Item_list4': Item_list4,
                'Item_list5': Item_list5,
                'GRNItem_list': GRNItem_list,
            };
            PageMethods.SaveCSData(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
                var ID = res;
                sendFile(ID);
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

                $('#btn_Save').val("Update");
                window.location = "ComparativeStatementVendorView.aspx";
                $('#btn_Save').val("Update");
            });
        }    


     

        function UnApprove() {
            debugger;
            var cm_id = '<% =Request.QueryString["CM_ID"] %>';
            PageMethods.UnApprovecsven(cm_id, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }

        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "ComparativeStatementVendor.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#Unapprovebtn').show();
                    } else {
                        $('#Unapprovebtn').hide();
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
            debugger;
            var fileInput = $('#uploadcsfile')[0];
            if (fileInput.files.length > 0) {
            var data = new FormData();
            data.append('file', $('#uploadcsfile')[0].files[0]);
            data.append('ID', ID);
            $.ajax({
                type: 'post',
                url: '../../UploadCSFiles.ashx',
                data: data,
                success: function (status) {
                },
                processData: false,
                contentType: false,
                error: function () {
                }
            });
            }
        }
        function getprNoBy_WareHouseCS() {
            debugger;
            var optionsRFQ = '';
            var Warehouse = $("#ddlWarehouse").val();
           // Warehouse = item.value;
            if (typeof Warehouse == "undefined" || Warehouse == "") {
                Warehouse = '0';
            }
            PageMethods.GetPRNoByWarehouse_CS(Warehouse, function (res) {
                debugger;
                var item = JSON.parse(res);
                optionsRFQ = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsRFQ += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsRFQ);
            });
        }
        function Print() {
            var CS_ID = '<%= Request.QueryString["CM_ID"]%>'
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=ComparativeStatementVendor&ReportTitle=Comparative Statement Vendor Print' + '&CM_ID=' + CS_ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=ComparativeStatementVendor&ReportTitle=Comparative Statement Vendor Print' + '&CM_ID=' + CS_ID;
            }
            window.open(url, '_blank');
        }

        function Cancel() {
            var CS_ID = '<%= Request.QueryString["CM_ID"]%>'
            PageMethods.CancelEntry(CS_ID, function (response) {
                  try {
                      var message = JSON.parse(response);
                      if (message.error) {
                          alert("Error Occurred While Cancelling: " + message.error);
                      } else if (message[0].Column1 == "1") {
                          Swal.fire({
                              icon: 'success',
                              title: 'Success!',
                              text: 'CS Cancelled Successfully',
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <input type="hidden" id="txtSTAmount_Vend1" name="txtSTAmount_Vend1" />
    <input type="hidden" id="txtSTAmount_Vend2" name="txtSTAmount_Vend2" />
    <input type="hidden" id="txtSTAmount_Vend3" name="txtSTAmount_Vend3" />
    <input type="hidden" id="txtSTAmount_Vend4" name="txtSTAmount_Vend4" />
    <input type="hidden" id="txtSTAmount_Vend5" name="txtSTAmount_Vend5" />

    <div class="row" style="overflow: scroll;">
        <div class="col-lg-5 col-md-5 col-sm-5">
            <div class="row">
                <div class="col-xs-9 col-lg-9 col-md-5 col-sm-9">
                    <div class="row">
                        <div class="col-lg-4 col-md-5 col-sm-6">
                            <label class="Fleft"  id="lb_CSno">CS#</label>
                            </div>
                        <div class="col-lg-6 col-md-8 col-sm-5">
                            <input class="Fleft"  type="text" name="txt_CSno" id="txt_CSno" readonly="readonly" />
                            </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-4 col-md-5 col-sm-6">
                            <label class="Fleft m_top_3"  id="lb_Date">Date</label>
                            </div>
                        <div class="col-lg-6 col-md-8 col-sm-6">
                            <input class="Fleft m_top_3"  type="text" name="txt_Date" id="txt_Date" /> 
                    </div>
                        </div>
                    <div class="row">
                         <div class="col-lg-4 col-md-4 col-sm-6">
                             <label class="Fleft m_top_3"  id="lb_Cs_Validity">CS Validity</label>
                             </div>
                        <div class="col-lg-6 col-md-4 col-sm-6">
                            <input class="Fleft m_top_3"  type="text" name="txt_Cs_Validity" id="txt_Cs_Validity" /> 
                            </div>
                    </div>
                     <div class="row">
                         <div class="col-lg-4 col-md-4 col-sm-6">
                             <label class="Fleft m_top_3"  id="lb_Pr_No">PR No</label>
                             </div>
                         <div class="col-lg-6 col-md-4 col-sm-6 mt-1">
                             <asp:DropDownList runat="server" ID="ddlPrNo" class="Fleft" onchange="ddlPrNoChanged()">
                                 <asp:ListItem Value="0">Please Select</asp:ListItem>
                             </asp:DropDownList>
                         </div>
                     </div>
                    <div class="row">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                            <label class="Fleft m_top_3"  id="lb_remarks">Remarks</label>
                            </div>
                        <div class="col-lg-6 col-md-4 col-sm-6">
                            <input type="text" style="width: 100% !important" class="m_top_3" id="txt_remarks" />
                            </div>
                        </div>
                    <div class="row">
                         <div class="col-lg-4 col-md-4 col-sm-6">
                             <label class="Fleft m_top_3"  id="lbl_status">Status</label>
                             </div>
                        <div class="col-lg-6 col-md-4 col-sm-6">
                            <input class="Fleft m_top_3"  type="text" name="txt_status" id="txt_status" value="Created" readonly="readonly" />
                            </div>
                    </div>
                           <div class="row">
                               <div class="col-lg-4 col-md-4 col-sm-6">
                                   <label class="Fleft m_top_3"  id="lbl_termid">Term & Conditions</label>
                                   </div>
                               <div class="col-lg-6 col-md-4 col-sm-6 mt-1">
                                   <asp:DropDownList runat="server" ID="ddlterms" class="Fleft">
                                       <asp:ListItem Value="0">Please Select</asp:ListItem>
                                   </asp:DropDownList>
                               </div>
                           </div>  
                    <div class="row" id="warehouserow">
                        <div class="col-lg-4 col-md-4 col-sm-6">
                            <label id="LblWarehouse">WareHouse<span style="color: red">*</span></label>
                        </div>
                        <div class="col-lg-6 col-md-4 col-sm-6 mt-1">
                            <select id="ddlWarehouse" onchange="getprNoBy_WareHouseCS()" style="width:100% !important">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                    <label id="lb_vendorName" class="padding_b_3" style="margin-top: 45px;">Vendor Name</label>
                    <label id="lb_paymentTerms" class="" style=" margin-top: 60px;">Mode of Payment</label>
                    <label id="lb_DeliveryTerms" class="" style="margin-top: 50px;">Delivery Terms</label>
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-lg-12 col-md-12">
                    <table class="table table-bordered" id="tblDetails" style="margin-top: 4px;">
                        <thead>
                            <tr>
                                <th style="display: none">PR ID</th>        
                                <th>PR No</th>
                                <th style="display: none">Item ID</th>
                                <th>Item Code</th>
                                <th style="width: 220px !important;">Item Description</th>
                                <th>UOM</th>
                                <th>Qty</th>
                                <th style="width: 50px !important;">Req Date</th>
                                <th style="display: none">Pr Detail Id</th>
                                <th style="display: none">GrnNum</th>
                                <th style="display: none">GrnRate</th>
                            </tr>
                        </thead>
                        <tbody id="tblItemDescription">
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-xs-5 col-sm-5 col-lg-5 col-md-5">
            <div style="margin-left:-10px; float: left; width: 100%; min-width: 50px; overflow-x: auto!important; white-space: nowrap;">
                <table class="table" border="1">
                    <tr>
                        <td>
                            <table   border="1" cellpadding="0" cellspacing="0" style="width: 253px !important; height: 239px !important;line-height:0.5px !important" id="toptable1">
                                <tr style="background-color: #449777db !important;color: white;">
                                    <th style="padding-top:7px !important" colspan="2">All Items</th>
                                    <th style="padding-top:7px !important">Vendor 1</th>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_vendorName_vendor1" id="txt_vendorName_vendor1" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_paymentTerms_vendor1" id="txt_paymentTerms_vendor1" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_DeliveryTerms_vendor1" id="txt_DeliveryTerms_vendor1" /></td>
                                </tr>
                            </table>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important" id="tblItemDescription1">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th style="padding-bottom:6px !important">Qty</th>
                                        <th style="padding-bottom:6px !important">Rate</th>
                                        <th style="width: 75px;padding-bottom:6px !important">S.Tax</th>
                                        <th style="padding-bottom:6px !important">Amount</th>


                                    </tr>
                                </thead>
                                <tbody id="tblItemDescription11">
                                </tbody>
                            </table>
                            <table id="bottomtable1">
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_amount_vendor1" style="width: 65px;">Amount</label>
                                        <input type="text" name="txt_amount_vendor1" id="txt_amount_vendor1" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_Freight_vendor1" style="width: 65px;">Freight</label>
                                        <input type="text" name="txt_Freight_vendor1" id="txt_Freight_vendor1" style="width: 97px !important; text-align: right; float: right" onchange="calculate2(this)" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_TotalAmount_vendor1" style="width: 65px;">Total Amount</label>
                                        <input type="text" name="txt_TotalAmount_vendor1" id="txt_TotalAmount_vendor1" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>

                            </table>
                        </td>
                        <td>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important; height: 239px !important;" id="toptable2">
                                <tr style="height:21px !important">
                                    <th style="padding-top:7px !important" colspan="2">All Items</th>
                                    <th style="padding-top:7px !important">Vendor 2</th>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_vendorName_vendor2" id="txt_vendorName_vendor2" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_paymentTerms_vendor2" id="txt_paymentTerms_vendor2" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_DeliveryTerms_vendor2" id="txt_DeliveryTerms_vendor2" /></td>
                                </tr>
                            </table>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important;" id="tblItemDescription2">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th style="padding-bottom:6px !important">Qty</th>
                                        <th style="padding-bottom:6px !important">Rate</th>
                                        <th style="width: 75px;padding-bottom:6px !important">S.Tax</th>
                                        <th style="padding-bottom:6px !important">Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="tblItemDescription21">
                                </tbody>
                            </table>
                            <table id="bottomtable2">
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_amount_vendor2" style="width: 65px;">Amount</label>
                                        <input type="text" name="txt_amount_vendor2" id="txt_amount_vendor2" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_Freight_vendor2" style="width: 65px;">Freight</label>
                                        <input type="text" name="txt_Freight_vendor2" id="txt_Freight_vendor2" style="width: 97px !important; text-align: right; float: right" onchange="calculate2(this)" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_TotalAmount_vendor2" style="width: 65px;">Total Amount</label>
                                        <input type="text" name="txt_TotalAmount_vendor2" id="txt_TotalAmount_vendor2" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important; height: 239px !important;" id="toptable3">
                                <tr>
                                    <th style="padding-top:7px !important" colspan="2">All Items</th>
                                    <th style="padding-top:7px !important">Vendor 3</th>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_vendorName_vendor3" id="txt_vendorName_vendor3" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_paymentTerms_vendor3" id="txt_paymentTerms_vendor3" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_DeliveryTerms_vendor3" id="txt_DeliveryTerms_vendor3" /></td>
                                </tr>
                            </table>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important;" id="tblItemDescription3">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th style="padding-bottom:6px !important">Qty</th>
                                        <th style="padding-bottom:6px !important">Rate</th>
                                        <th style="width: 75px;padding-bottom:6px !important">S.Tax</th>
                                        <th style="padding-bottom:6px !important">Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="tblItemDescription31">
                                </tbody>
                            </table>
                            <table id="bottomtable3">
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_amount_vendor3" style="width: 65px;">Amount</label>
                                        <input type="text" name="txt_amount_vendor3" id="txt_amount_vendor3" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_Freight_vendor3" style="width: 65px;">Freight</label>
                                        <input type="text" name="txt_Freight_vendor3" id="txt_Freight_vendor3" style="width: 97px !important; text-align: right; float: right" onchange="calculate2(this)" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_TotalAmount_vendor3" style="width: 65px;">Total Amount</label>
                                        <input type="text" name="txt_TotalAmount_vendor3" id="txt_TotalAmount_vendor3" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important; height: 239px !important;" id="toptable4">
                                <tr>
                                    <th style="padding-top:7px !important" colspan="2">All Items</th>
                                    <th style="padding-top:7px !important">Vendor 4</th>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_vendorName_vendor4" id="txt_vendorName_vendor4" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_paymentTerms_vendor4" id="txt_paymentTerms_vendor4" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_DeliveryTerms_vendor4" id="txt_DeliveryTerms_vendor4" /></td>
                                </tr>
                            </table>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important;" id="tblItemDescription4">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th style="padding-bottom:6px !important">Qty</th>
                                        <th style="padding-bottom:6px !important">Rate</th>
                                        <th style="width: 75px;padding-bottom:6px !important">S.Tax</th>
                                        <th style="padding-bottom:6px !important">Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="tblItemDescription41">
                                </tbody>
                            </table>
                            <table id="bottomtable4">
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_amount_vendor4" style="width: 65px;">Amount</label>
                                        <input type="text" name="txt_amount_vendor4" id="txt_amount_vendor4" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_Freight_vendor4" style="width: 65px;">Freight</label>
                                        <input type="text" name="txt_Freight_vendor4" id="txt_Freight_vendor4" style="width: 97px !important; text-align: right; float: right" onchange="calculate2(this)" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_TotalAmount_vendor4" style="width: 65px;">Total Amount</label>
                                        <input type="text" name="txt_TotalAmount_vendor4" id="txt_TotalAmount_vendor4" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                        <td>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important; height: 239px !important;" id="toptable5">
                                <tr>
                                    <th style="padding-top:7px !important" colspan="2">All Items</th>
                                    <th style="padding-top:7px !important">Vendor 5</th>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_vendorName_vendor5" id="txt_vendorName_vendor5" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_paymentTerms_vendor5" id="txt_paymentTerms_vendor5" /></td>
                                </tr>
                                <tr>
                                    <td colspan="3" style="height:60px !important">
                                        <select class="width_input_ver" name="txt_DeliveryTerms_vendor5" id="txt_DeliveryTerms_vendor5" /></td>
                                </tr>
                            </table>
                            <table border="1" cellpadding="0" cellspacing="0" style="width: 253px !important;" id="tblItemDescription5">
                                <thead>
                                    <tr>
                                        <th></th>
                                        <th style="padding-bottom:6px !important">Qty</th>
                                        <th style="padding-bottom:6px !important">Rate</th>
                                        <th style="width: 75px;padding-bottom:6px !important">S.Tax</th>
                                        <th style="padding-bottom:6px !important">Amount</th>
                                    </tr>
                                </thead>
                                <tbody id="tblItemDescription51">
                                </tbody>
                            </table>
                            <table id="bottomtable5">
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_amount_vendor5" style="width: 65px;">Amount</label>
                                        <input type="text" name="txt_amount_vendor5" id="txt_amount_vendor5" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_Freight_vendor5" style="width: 65px;">Freight</label>
                                        <input type="text" name="txt_Freight_vendor5" id="txt_Freight_vendor5" style="width: 97px !important; text-align: right; float: right" onchange="calculate2(this)" />
                                    </td>
                                </tr>
                                <tr>
                                    <td colspan="4">
                                        <label id="lb_TotalAmount_vendor5" style="width: 65px;">Total Amount</label>
                                        <input type="text" name="txt_TotalAmount_vendor5" id="txt_TotalAmount_vendor5" style="width: 97px !important; text-align: right; float: right" />
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2">
            <div class="row">
                <div class="col-lg-12">
                    <label id="lb_Attachments" class="Fleft">Attachments</label>
                    <input type="file" name="txt_attachments" id="uploadcsfile" class="Fleft" />
                    <br />
                    <asp:HyperLink ID="hyperlink1" runat="server">Download</asp:HyperLink>
                    <br />
                    <input type="button" id="marklowratebtn" style="margin-left: 80px; display: none; margin-top: 5px; width: 172px; margin-bottom: 15px" onclick="getlowrate()" value="Mark Low Rate" />
                </div>
            </div>
            <div class="row">
                <div class="col-xs-12 col-sm-12 col-lg-12 col-md-12">
                    <table class="table table-bordered" id="grntable" style="margin-top: 202px;">
                        <thead>
                            <tr>
                                <th>Total App Amt</th>
                                <th>Last GRN Rate</th>
                            </tr>
                        </thead>
                        <tbody id="grntablebody">
                        </tbody>
                    </table>
                </div>

            </div>
        </div>
    </div>

    <div class="row" style="margin-top:10px">     
        <div class="col-lg-8">
            <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-8">
            <input type="button" class="btn btn-primry" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
             </div>
        <div class="col-lg-2 col-md-4 col-sm-8">
            <input type="button" class="btn btn-gray" id="btnList" value="List" onclick="window.location = 'ComparativeStatementVendorView.aspx'" />
            </div>
       
        <div class="col-lg-2 col-md-4 col-sm-8">         
            <input type="button" class="btn btn-primry" id="Printbtn" value="Print" onclick="Print()"  />
            </div>
        <div class="col-lg-2 col-md-4 col-sm-8">
            <input type="button" class="btn btn-gray"  value="Cancel" id="btncancel" onclick="Cancel()" />
       </div>
         <div class="col-lg-2 col-md-4 col-sm-8">
      <input type="button" id="Unapprovebtn" class="btn btn-primry"  value="UnApprove" onclick="UnApprove()" style="display:none;" />
         </div>
            </div>
        </div>
    </div>
<div id="PRItemsModel" class="modal fade" role="dialog">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                  <h3 class="modal-title">Add PR Items</h3>
                <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="margin-top: -11px !important">
                      <span aria-hidden="true">&times;</span>
                  </button>              
            </div>

            <input type="hidden" id="txthiddentr" name="txthidddentr" />
            <div class="modal-body">
                <div class="table-container">
                    <table class="table Modal-Table table-striped" id="tblPRItemstModelTable">
                        <thead>
                            <tr class="modal-tR">
                                <th class="modal-thead" style="width: 32px;">
                                    <input type="checkbox" id="checkHeader" value="false" />
                                </th>
                                <th class="modal-thead" style="display: none;">Pr ID</th>
                                <th class="modal-thead" style="display: none;">Pr Num</th>
                                <th class="modal-thead" style="display: none;">Item ID</th>
                                <th class="modal-thead">Item Name</th>
                                <th class="modal-thead">Qty</th>
                                <th class="modal-thead" style="display: none;">Item Code</th>
                                <th class="modal-thead">MOU</th>
                                <th class="modal-thead" style="display: none;">Required_Date</th>
                                <th class="modal-thead" style="display: none;">PR_Detail_ID</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <input type="button" id="PRItem" value="Close"  class="btn btn-gray"  name="PRItem" data-dismiss="modal" style="width:20% !important" />
                </div>
        </div>
    </div>
</div>


</asp:Content>
