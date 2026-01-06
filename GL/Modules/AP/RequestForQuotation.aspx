<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RequestForQuotation.aspx.cs" Inherits="PMS.AP.RequestForQuotation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 
    <script type="text/javascript">
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
        

        $(document).ready(function () {
            $('#btnSelectVendor').on('click', function () {
                debugger
                $('#VendorModal').modal('show');
            });
            GetWareHouseCondition();

            getprNoBy_WareHouseRFQ();
            $('#ctl00_MainContent_ddlWareHouse').change(function () {

                $("#ctl00_MainContent_ddlWareHouse").attr('disabled', true);
            });
            $('[id*=checkHeader]').click(function () {
                var isTrue = $('#checkHeader').is(':checked');
                if (isTrue) {
                    debugger;
                    $('.chktd').prop('checked', true);
                    setTimeout(function () {
                        $("#tblRFQItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            debugger;
                            var row = $(this);
                            append(row);
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            Filltaxtype();

            $('select').select2();
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtRFQ_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#ctl00_MainContent_txtRFQ_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });

            $("#txtDue_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#ctl00_MainContent_txtDue_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
             <% if (Request.QueryString["RFQ_ID"] != null)
             { %>
            var RFQ_ID = '<%= Request.QueryString["RFQ_ID"]%>'
            LoadRFQData(RFQ_ID);
            $('#btnSave').val('Update');
            <% }else { %>
            GetNewRFQNo();
            <% } %>
            $('#btnPRSave').on('click', function () {
                var pr_id = $("#ctl00_MainContent_ddlPrNo").val();
                LoadPrNoDetail(pr_id);
                $('#ctl00_MainContent_txtRemarks').focus();
            });
            setTimeout(function () {
                var status = $('#ctl00_MainContent_txtStatus').val();
                if (status == "Approved") {
                    debugger;
                    $('#btnSave').attr("disabled", 'disabled');
                }
                if (status == "Created") {
                }
            }, 1000);
        });
        var warehouseCond;
        function GetWareHouseCondition() {

            $.ajax({
                type: "POST",
                url: "RequestForQuotation.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        $('#warehouse').show();
                    }
                    else {
                        $('#warehouse').hide();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function GetNewRFQNo() {
            PageMethods.GetNewRFQNo(function (resp) {
                $('#ctl00_MainContent_txtRFQ_No').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function getprNoBy_WareHouseRFQ() {
            debugger;
         
            PageMethods.GetPRNoByWarehouse_RFQ(function (res) {
                var item = JSON.parse(res);
                optionsRFQ = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsRFQ += '<option value="' + value.PR_Id + '" >' + value.PR_Num + '</option>';
                });
                $("#ctl00_MainContent_ddlPrNo option").remove();
                $('#ctl00_MainContent_ddlPrNo').html(optionsRFQ);
            });
        }
       
        function LoadRFQData(RFQ_ID) {
            PageMethods.LoadRFQHeaderDetail(RFQ_ID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.RFQ_Date.substring(6, 19))));
                $('#ctl00_MainContent_txtRFQ_Date').val(TrnsDate);
                var Due_Date = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.DueDate.substring(6, 19))));
                $('#ctl00_MainContent_txtDue_Date').val(Due_Date);

                $('#hdnRFQ_ID').val(data.RFQ_ID);
                $('#ctl00_MainContent_txtRFQ_No').val(data.RFQ_No);
                $("#ctl00_MainContent_txtRFQ_Reference").val(data.Ref_No);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlTerm').val(data.Term_ID).trigger('change');
                }, 1000);


                setTimeout(function () {
                    $('#ctl00_MainContent_ddlPaymentTerms').val(data.PaymentTerms).trigger('change');
                }, 1000);
                $('#ctl00_MainContent_txtRemarks').val(data.Remarks);
                $('#ctl00_MainContent_txtStatus').val(data.Status);
                $('#ctl00_MainContent_txtquotationValidty').val(data.QuotationValidty);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlWareHouse').val(data.Ware_House).trigger('change');
                }, 1500);
                LoadRFQItemDetail(RFQ_ID);
                setTimeout(function () {
                    LoadRFQVendor(RFQ_ID);
                }, 1500);
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function LoadRFQItemDetail(RFQ_ID) {
            PageMethods.LoadRFQItemDetail(RFQ_ID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rows = '';
                var TrnsDate = '';
                $.each(data, function (key, value) {
                    debugger;
                    if (value.Required_Date != null) {
                        TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Required_Date.substring(6, 19))));
                    }
                    else {
                        TrnsDate = ""
                    }
                    if (value.Unit == null)
                        value.Unit = "";
                    if (value.UnitPrice == null)
                        value.UnitPrice = 0;
                    if (value.PRDetailId == null)
                        value.PRDetailId = 0;
                    var rowlength = tblItemDescription.rows.length;
                    rows += '<tr>' +
                        '<td style="padding-top:7px!important;"><input type="hidden" style="width: 75px !important;text-align:right" />' + (key + 1) + '</td>' +
                        '<td style="display:none"><input type="hidden" id="txtPRID' + (key + 1) + '" name="txtPRID" value="' + value.PR_ID + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;" />' + value.PR_ID + '</td>' +
                        '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + (key + 1) + '"  value="' + value.PR_Num + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + value.PR_Num + '</td>' +
                        '<td style="display:none;"><input type="hidden" name="txtItemId" id="txtItemId' + (key + 1) + '"  value="' + value.ItemID + '" /> ' + value.ItemID + ' </td>' +
                        '<td style="padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + (key + 1) + '"  value="' + value.Item_Code + '" style="width:50px !important;text-align:center;font-size:9px;height:20px;" /> ' + value.Item_Code + ' </td>' +
                        '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:right!important;"><input type="hidden" name="txtItemName" id="txtItemName' + (key + 1) + '"  value="' + value.Item_Name + '" /> ' + value.Item_Name + ' </td>' +
                        '<td><input type="text" readonly="readonly" id="txtQty' + (key + 1) + '" name="txtQty" style="text-align:right ;width:74px !important;font-size:9px;height:20px" onchange="calcTotal()" value=' + parseFloat(value.Qty).toFixed(2) + '></input></td>' +
                        '<td style="text-align:center!important;"><input type="hidden" name="txtUnit" readonly id="txtUnit' + (key + 1) + '"  value="' + value.Unit + '" />' + value.Unit + ' </td>' +
                        '<td><input type="text" readonly="readonly" name="txtreqdate" id="txtreqdate' + rowlength + '" value="' + TrnsDate + '" style="width:95px !important;text-align:center;font-size:9px;height:20px;" /></td>' +
                        '<td><input type="text" onchange="calcTotal()" name="txtUnitPrice" style="text-align:right ;width:78px !important;font-size:9px;height:20px;" id="txtUnitPrice' + (key + 1) + '"  value="' + parseFloat(value.UnitPrice).toFixed(2) + '" /></td>' +
                        '<td><select id="ddlSTAX' + (key + 1) + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:86px !important;font-size:9px;height:20px;margin-left: 9px;"><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                        '<td style="text-align:right;width:75px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:75px !important;text-align:right;font-size:9px;height:20px;"  value="' + parseFloat(value.TotalPrice).toFixed(2) + '" readonly="readonly" id="txtTotalPrice' + length + '" name="txtTotalPrice"></td>' +
                        '<td style="display:none"><input style="width: 75px !important;text-align:right" type="hidden" id="txtPRDId' + (key + 1) + '" name="txtPRDId" value="' + value.PRDetailId + '" />' + (key + 1) + '</td></tr>';
                });
                $('#tblItemDescription tbody').html(rows);
                $.each(selectedOptions, function (key, value) {
                    debugger;
                    $("#ddlSTAX" + (key + 1)).val(value.SalTax_Id);
                });
                $('input[name="txtreqdate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                $('#btnSave').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }

        function GetWareHouse() {
            debugger;
            var prno = $("#ctl00_MainContent_ddlPrNo").val();
            PageMethods.GetwarehousebyPrno(prno, function (res) {
                var item = JSON.parse(res);
                setTimeout(function () {
                    $('#ctl00_MainContent_ddlWareHouse').val(item.Warehouse).trigger('change');
                }, 1000);
            });
        }
        function LoadRFQVendor(RFQ_ID) {
            debugger;
            PageMethods.LoadRFQVendors(RFQ_ID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rows = '';
                $.each(data, function (key, value) {
                    debugger;
                    rows += '<tr style="height: 20px !important">' +
                        '<td style="display:none;height: 20px !important;"><input type="text" name="txt_Vendor_id" id="txt_Vendor_id' + (key + 1) + '" value="' + value.VendorId + '""/>' + value.VendorId + '</td>' +
                        '<td><input type="text" readonly="readonly" id="txt_vendorName' + (key + 1) + '" name="txt_vendorName" style="width:100%;" value=' + value.VendorName + '></input></td>' +
                        '<td style="height: 20px !important;"><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size:13px;margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td></tr>';
                });
                $('#tblVendorDetails tbody').html(rows);
                $('#btnSave').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function validateSave() {
            debugger;
            var proceed = true;
            var table = $('#tblItemDescriptionDetail');
            var DueDate = $('#ctl00_MainContent_txtDue_Date').val();
            var RFQDate = $('#ctl00_MainContent_txtRFQ_Date').val();

            if ($('#tblItemDescription tr').length <= 1) {
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

            }
            else {
                table.find('tr').each(function (key, value) {
                    var Qty = $(value).find('td input[name=txtQty]').val();
                    if (Qty == 0 || Qty == "" || Qty < 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Check Qty it must be Greater than zero',
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
            if (new Date(DueDate) < new Date(RFQDate)) {
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Due Date must be greater than RFQ Date.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            if ($('#tblVendorDetails tr').length <= 1) {
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

            }
            return proceed;
        }
        function SaveAllRecord() {
            debugger
            if (validateSave()) {
                debugger;
                var status;
                var btnSave = $('#btnSave').val();
                var RefNo = $('#ctl00_MainContent_txtRFQ_Reference').val();
                var Remarks = $('#ctl00_MainContent_txtRemarks').val();
                var RFQ_No = $('#ctl00_MainContent_txtRFQ_No').val();
                var RFQ_Date = $('#ctl00_MainContent_txtRFQ_Date').val();
                var DueDate = $('#ctl00_MainContent_txtDue_Date').val();
                var PaymentTerms = $('#ctl00_MainContent_ddlPaymentTerms').val();
                var wareHouse = $('#ctl00_MainContent_ddlWareHouse').val();
                var Term_ID = $('#ctl00_MainContent_ddlTerm').val();
                var QuotationValidty = $('#ctl00_MainContent_txtquotationValidty').val();
                var table1 = $('#tblItemDescriptionDetail');
                var table2 = $('#VendorTableBody');
                var RFQ_ID = $('#hdnRFQ_ID').val();
                var Item_list = [];
                var Vendor_list = [];
                debugger;
                if (RFQ_No == "(New)" || RFQ_No == "")
                    RFQ_No = "0";
                table1.find('tr').each(function (key, value) {
                    debugger;
                    Item_list.push({ 'PRDetailId': $(value).find('td input[name=txtPRDId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'ItemName': $(value).find('td input[name=txtItemName]').val(), 'Unit': $(value).find('td input[name=txtUnit]').val(), 'Qty': $(value).find('td input[name=txtQty]').val(), 'UnitPrice': $(value).find('td input[name=txtUnitPrice]').val(), 'TotalPrice': $(value).find('td input[name=txtTotalPrice]').val(), 'SalTax_Id': $("#ddlSTAX" + (key + 1) + " option:selected").val(), 'Required_Date': $(value).find('td input[name=txtreqdate]').val() });
                });
                table2.find('tr').each(function (key, value) {
                    debugger;
                    Vendor_list.push({ 'VendorID': $(value).find('td input[name=txt_Vendor_id]').val(), 'VendorName': $(value).find('td input[name=txt_vendorName]').val() });
                });
                if (status == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Required Date must be greater than Request For Quotation Date',
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
                    $('#btnsave').attr('disabled', true);
                    var AllItemDetail = { 'RFQ_ID': RFQ_ID, 'RFQ_Date': RFQ_Date, 'RFQ_No': RFQ_No, 'RefNo': RefNo, 'DueDate': DueDate, 'Term_ID': Term_ID, 'PaymentTerms': PaymentTerms, 'wareHouse': wareHouse, 'QuotationValidty': QuotationValidty, 'Remarks': Remarks, 'ItemList': Item_list, 'Vendorlist': Vendor_list };
                    PageMethods.SaveRFQItemDetail(btnSave, JSON.stringify(AllItemDetail), function (res) {
                        debugger;
                        if (btnSave == "Update") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Updated Successfully',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        }
                        else {
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

                        }
                        sendFile(res);
                        window.location = "RequestForQuotation.aspx?RFQ_ID=" + res;
                    });
                }
            }
        }
        function LoadPrNoDetail(pr_id) {
            debugger;
            PageMethods.getPRByID(pr_id, function (data) {
                debugger;
                var Test = JSON.parse(data);
                $('#tblRFQItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    debugger;
                    rows = '<tr><td style="width:50px !important"><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 1px;" onclick="append(this)"/></td><td style="display:none;">' + Test[i].PR_ID + '</td><td style="display:none;">' + Test[i].PR_Num + '</td><td style="display:none;">' + Test[i].Item_ID + '</td><td style="text-align:left">' + Test[i].Description + '</td><td style="width: 80px;text-align:right">' + parseFloat(Test[i].Qty).toFixed(2)
                        + '</td><td style="display:none;">' + Test[i].Item_Code + '</td><td style="width: 100px;text-align:center">' + Test[i].Unit + '</td><td style="display:none;">' + parseFloat(Test[i].UnitPrice).toFixed(2) + '</td><td style="display:none;">' + Test[i].Required_Date + '</td><td style="display:none;">' + Test[i].PR_Detail_ID + '</td></tr>';
                    $('#tblRFQItemstModelTable tbody').append(rows);
                }
                $('#RFQItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }
        function append(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            var prid = $($(row).find('td')[1]).text();
            var prnum = $($(row).find('td')[2]).text();
            var item_id = $($(row).find('td')[3]).text();
            var item_name = $($(row).find('td')[4]).text();
            var Qty = $($(row).find('td')[5]).text();
            var itemcode = $($(row).find('td')[6]).text();
            var unit = $($(row).find('td')[7]).text();
            var unitprice = $($(row).find('td')[8]).text();
            var reqdate = $($(row).find('td')[9]).text();
            var pr_detail_id = $($(row).find('td')[10]).text();
            var length = $("#tblItemDescription tr").length;
            if (unit == "null")
                unit = "";
            if (Qty == "null")
                Qty = "0";
            if (Qty == "NaN")
                Qty = "0";
            unitprice = "0";
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

            var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value=' + itemcode + ']');
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
                    '<td style="padding-top:7px!important;"><input type="hidden" style="width: 75px !important;text-align:right" />' + length + '</td>' +
                    '<td style="display:none"><input type="hidden" name="txtPRID" id="txtPRID' + length + '"  value="' + prid + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + prid + '</td>' +
                    '<td style="padding-top: 7px!important;"><input type="hidden" name="txtPRNo" id="txtPRNO' + length + '"  value="' + prnum + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px;padding-top: 7px!important;padding-right: 3px!important;"/>' + prnum + '</td>' +
                    '<td style="display:none"><input type="hidden" name="txtItemId" id="txtItemId' + length + '"  value="' + item_id + '"  style="width:50px !important;text-align:center;font-size:9px;height:20px;"/> ' + item_id + ' </td>' +
                    '<td style="padding-top: 7px!important;padding-right: 3px!important;text-align:center!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + length + '"  value="' + itemcode + '"  style="width:50px !important;text-align:center;font-size:9px;height:20px;"/> ' + itemcode + ' </td>' +
                    '<td style="padding-left: 8px!important;padding-top: 7px!important;text-align:left!important;"><input type="hidden" name="txtItemName" id="txtItemName' + length + '"  value="' + item_name + '"/> ' + item_name + ' </td>' +
                    '<td><input type="text" readonly="readonly" id="txtQty' + length + '" style="text-align:right ;width:50px !important;font-size:9px;height:20px" name="txtQty" value="' + Qty + '"/></td>' +
                    '<td style="text-align:center!important;"><input type="hidden" name="txtUnit" id="txtUnit' + length + '"  value="' + unit + '" />' + unit + ' </td>' +
                    '<td><input type="text" readonly="readonly" name="txtreqdate" id="txtreqdate' + length + '" style="width:95px !important;text-align:center;font-size:9px;height:20px;" value="' + reqdate + '" /></td>' +
                    '<td><input type="text" style="text-align:right ;width:78px !important;font-size:9px;height:20px;" onchange="calcTotal()" name="txtUnitPrice" id="txtUnitPrice' + length + '"  value="' + unitprice + '" /></td>' +
                    '<td><select id="ddlSTAX' + length + '" name="ddlSTAX" onchange="calcTotal()" style="text-align:right ;width:86px !important;font-size:9px;height:20px;margin-left: 9px;" class="duplicate" ><option value="0">Please Select</option>' + _gloabal + '</select></td>' +
                    '<td style="text-align:right;width:75px !important;font-size:9px;height:20px;padding-top: 7px!important;"><input type="text" style="width:75px !important;text-align:right;font-size:9px;height:20px;" value="0" readonly id="txtTotalPrice' + length + '" name="txtTotalPrice"></td>' +
                    '<td style="display:none"><input type="hidden" id="txtPRDId' + length + '" name="txtPRDId" value="' + pr_detail_id + '" style="width: 75px !important;text-align:right" /></td></tr>');
                $('#txtreqdate' + length).datepicker({ dateFormat: 'dd M yy', }).attr('readonly', 'readonly').datepicker('setDate', formattedDateForDatepicker);
                calcTotal();
                length++;
                $('input[name="txtreqdate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
            }
        }


        function calcTotal() {
            debugger
            var totprice = 0;
            var amtwithtaxprice = 0;
            var STpercent = 0;
            var STAmount = 0;
            var tbl = document.getElementById('tblItemDescription');
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var Rate = $($(value).find('td input[name=txtUnitPrice]')[0]).val();
                var Qty = $($(value).find('td input[name=txtQty]')[0]).val();
                if (Qty != undefined || Rate != undefined) {
                    totprice = Qty * Rate;
                }
                if ($($(value).find('td select[name=ddlSTAX] :selected')[0]).val() != 0) {
                    STpercent = $($(value).find('td select[name=ddlSTAX] :selected')[0]).text();
                }
                else {
                    STpercent = 0;
                }
                STAmount = (STpercent / 100) * totprice;
                amtwithtaxprice = totprice + STAmount;
                $($(value).find('td input[name=txtTotalPrice]').val(amtwithtaxprice.toFixed()));
            });
        }

        function PrintRFQDetail() {
            debugger;
            var id = '<% =Request.QueryString["RFQ_ID"] %>';
            if (id != '' && id != null && id != undefined) {
                PageMethods.GetVendorsforReports(id, function (Tests) {
                    debugger
                    var message = JSON.parse(Tests);
                    for (var i = 0; i < message.length; i++) {
                        debugger;
                        var locationInfo = window.location;
                        var url = '/ReportViewer.aspx?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        if (!locationInfo.origin.includes('localhost')) {
                            var urlInfo = window.location.href.split('/');
                            var ip = urlInfo[2];
                            var foldername = urlInfo[3];
                            url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=RequestForQuotationList&ReportTitle=Request For Quotation&RFQid=' + id + '&Venderid=' + message[i].VendorId;
                        }
                        window.open(url, '_blank');
                    }
                }
                )
            }
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }

        function Addrow() {
            debugger;
            var vendorName = $('#ctl00_MainContent_ddlVendors :selected').text();
            var Vendor_id = $('#ctl00_MainContent_ddlVendors').val();
            if (Vendor_id == 0) {
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

                return false;
            }

            var test_array = $('#tblVendorDetails').find('input[name=txt_Vendor_id][value=' + Vendor_id + ']');
            if (test_array.length > 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'This Vendor Already Added!',
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
                var rows = '';
                var rowlength = tblVendorDetails.rows.length;
                debugger
                rows += '<tr style="height: 20px !important">' +
                    '<td style="display:none;height: 20px !important;"><input type="text" name="txt_Vendor_id" id="txt_Vendor_id' + rowlength + '" value=' + Vendor_id + ' />' + Vendor_id + '</td>' +
                    '<td style="height:20px !important;">' +
                    '<input type="text" name="txt_vendorName" style="width: 100%;" id="txt_vendorName' + rowlength + '" value="' + vendorName + '" readonly="readonly"/>' +
                    ' </td>' +
                    '<td style="height: 20px !important;"><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                    '</tr>'
                $('#VendorTableBody').append(rows);
                $('#ctl00_MainContent_ddlVendors').val(0).trigger('change');
            }
        }
        function sendFile(ID) {
            debugger;
            var fileInput = $('#choseRFQfile')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#choseRFQfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../UploadRFQFiles.ashx',
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

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="LabelRFQ_No" runat="server" Text="RFQ No."></asp:Label>
            <asp:TextBox runat="server" ID="txtRFQ_No" class="form-control" ReadOnly="true" />
            <asp:HiddenField ID="hdnRFQ_ID" runat="server" ClientIDMode="Static" />
            <asp:TextBox runat="server" ID="txtRFQ_ID" Visible="false" ReadOnly="true" Width="0" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="LabelRFQ_Date" runat="server" Text="RFQ Date"></asp:Label>
            <asp:RequiredFieldValidator ID="rfvRFQDate" runat="server" InitialValue="0" ControlToValidate="txtRFQ_Date" ErrorMessage="*" Display="Dynamic"></asp:RequiredFieldValidator>
            <asp:TextBox runat="server" ID="txtRFQ_Date" class="form-control" />
        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <asp:Label ID="lblStatus" runat="server" Text="Status"></asp:Label>
            <asp:TextBox runat="server" ReadOnly="true" ID="txtStatus" class="form-control" />
        </div>
        <div class="col-lg-1 col-md-2 col-sm-4">
            <input type="button" id="btnSelectVendor"  value="Vendor" class="btn btn-primry" style="margin-top: 16px" />

        </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <asp:Label ID="lblPrNo" runat="server" Text="Pr.No"> </asp:Label>
            <asp:DropDownList runat="server" ID="ddlPrNo" onchange="GetWareHouse()" class="form-control"></asp:DropDownList>
        </div>
        <div class="col-lg-1 col-md-2 col-sm-4">
            <input type="button" value="Add" id="btnPRSave" class="btn btn-primry" style="margin-top: 16px;" />
        </div>
        </div>

        <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="LabelpaymentTerm" runat="server" Text="Mode of Payment"></asp:Label>
            <asp:DropDownList runat="server" ID="ddlPaymentTerms" class="form-control"></asp:DropDownList>
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="LabelDue_Date" runat="server" Text="Due Date"></asp:Label>
            <asp:RequiredFieldValidator ID="rfvdueDate" runat="server" InitialValue="0" ControlToValidate="txtDue_Date" ErrorMessage="*" Display="Dynamic"></asp:RequiredFieldValidator>
            <asp:TextBox runat="server" ID="txtDue_Date" class="form-control" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12" style="display: none">
            <asp:Label ID="lblReference" runat="server" Text="Ref. No"></asp:Label>
            <asp:TextBox runat="server" ID="txtRFQ_Reference" class="form-control" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="lblquotationValidty" runat="server" Text="Quotation Validty"></asp:Label>
            <asp:TextBox runat="server" ID="txtquotationValidty" class="form-control" />
        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <asp:Label ID="lblTerm_ID" runat="server" Text="Payment Terms"></asp:Label>
            <asp:DropDownList runat="server" ID="ddlTerm" class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
        </div>

    </div>
 
    <div class="row">
           <div class="col-lg-3 col-md-6 col-sm-12" id="warehouse">
            <asp:Label ID="lblwarehouse" runat="server" Text="Ware House"></asp:Label>
            <asp:DropDownList runat="server" ID="ddlWareHouse"  class="form-control" AppendDataBoundItems="true"></asp:DropDownList>
        </div>
        <div class="col-lg-7 col-md-12 col-sm-12">
            <asp:Label ID="lblRemarks" runat="server" Text="Remarks"></asp:Label>
            <asp:TextBox runat="server" ID="txtRemarks" class="form-control" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="col-form-label">Attachment</label>
            <input type="file" id="choseRFQfile" name="choseRFQfile" />
            <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
        </div>
    </div>

    <div class="row" style="overflow: scroll; height: 276px !important;">
        <table class="table" id="tblItemDescription" style="width: 100% !important; font-size: 9px !important; overflow: scroll;">
            <thead>
                <tr>
                    <th style="width: 29px;">No</th>
                    <th style="display: none">P.R ID</th>
                    <th style="width: 50px; text-align: center; font-size: 10px;">P.R No</th>
                    <th style="display: none">Item ID</th>
                    <th style="width: 66px; text-align: center; font-size: 10px;">Item Code</th>
                    <th style="width: 218px; text-align: center;">Item Description</th>
                    <th style="width: 60px;">Qty</th>
                    <th style="width: 73px;">MOU</th>
                    <th style="width: 75px;">Required Date</th>
                    <th style="width: 56px;">Unit Price</th>
                    <th style="width: 80px;">General S.Tax %</th>
                    <th style="width: 66px;">Total Price</th>
                    <th style="display: none">PR Detail ID</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
    </div>
                    <div class="col-lg-8" style="margin-top:1%">
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" class="btn btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" class="btn btn-primry" id="btnPrint" value="Print" name="name" onclick="PrintRFQDetail();" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" class="btn-gray" value="View List" onclick="window.location = 'RequestForQuotationView.aspx'" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-12">
                            <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'RequestForQuotation.aspx'" />
                        </div>
                    </div>
   
    <div id="RFQItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <h4 class="modal-title">Add PR Items</h4>
                    <button type="button" style="width: auto; margin-top: 0px !important" class="close" data-dismiss="modal">&times;</button>
                    
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table" style="width: 953px; height: auto; overflow: scroll;" id="tblRFQItemstModelTable">
                        <thead>
                            <tr>
                                <th style="width: 50px;"><input type="checkbox" id="checkHeader" value="false" /></th>
                                <th style="display: none;">Pr ID</th>
                                <th style="display: none;">Pr Num</th>
                                <th style="display: none;">Item ID </th>
                                <th>Item Name</th>
                                <th>Qty</th>
                                <th style="display: none;">Item Code</th>
                                <th>MOU</th>
                                <th style="display: none;">UnitPrice</th>
                                <th style="display: none;">Required_Date</th>
                                <th style="display: none;">PR_Detail_ID</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" id="PoItem" style="width:20% !important" name="PoItem" value="Done" class="btn-gray" data-dismiss="modal" />
                </div>
            </div>
        </div>
    </div>


    <!-- Modal for displaying Vendors -->
    <div id="VendorModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">Vendors</h3>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="col-lg-12">
                        <label id="lblVendor">Vendor</label>
                        <asp:DropDownList runat="server" ID="ddlVendors" style="width:250px !important" CssClass="form-control" AppendDataBoundItems="true"></asp:DropDownList>
                        <input type="button" class="btn btn-primry" onclick="Addrow()" value="+" id="AddVendor" style=" float: right;width:20% !important;margin-top:1%" />
                    </div>
                    <table class="table" style="width: 100%; overflow: scroll;" id="tblVendorDetails">
                        <thead>
                            <tr>
                                <th style="display: none; width: 10%">Vendor Id</th>
                                <th style="width: 80%">Vendor Name</th>
                                <th style="width: 80%">Action</th>
                            </tr>
                        </thead>
                        <tbody id="VendorTableBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input style="width:20% !important;margin-left:80%" class="btn-gray" type="button" value="Close" data-dismiss="modal"  />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
