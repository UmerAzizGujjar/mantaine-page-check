<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StoreStockTransfer.aspx.cs" Inherits="PMS.Inventory.StoreStockTransfer" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
    .textarea, input[type="text"] {
        box-shadow: none !important;
    }

    .token-input-dropdown {
        z-index: 9999 !important;
        position: absolute !important;
        background-color: #fff;
        border: 1px solid #ccc;
        box-shadow: 0 2px 8px rgba(0,0,0,0.15);
    }

    .token-input-dropdown ul {
        list-style: none;
        padding: 0;
        margin: 0;
        max-height: 200px;
        overflow-y: auto;
    }

    .token-input-dropdown ul li {
        padding: 5px 10px;
        cursor: pointer;
    }

    .token-input-dropdown ul li.token-input-selected-item {
        background-color: #007bff;
        color: white;
    }

    .token-input-dropdown ul li.token-input-selected-item2 {
        background-color: #0056b3;
        color: white;
    }

    .modal {
        z-index: 1050 !important;
    }

    .token-input-dropdown {
        z-index: 10000 !important;
    }
</style>


    <script type="text/javascript">
        var stID = "";
        var wareHouses = [];

        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "StoreStockTransfer.aspx/" + methodName,
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

        function InitStock() {
        }
        function getstockdetailnum() {
            debugger;
           // var itemid = $("#txtItemCode").val().toString().split('-')[0];
            var itemid = itmid;
            var wareHousefrom = $("#ctl00_MainContent_Select_wareHouseFrom").val();
            var date = $("#StockTransferDate").val();
            var batcNo = $('#batchnoddl :selected').text();
            debugger;
            if (itemid != "" && wareHousefrom != "" && date != "") {
                $.ajax({
                    type: "POST",
                    url: "StoreStockTransfer.aspx/PerformBatchNoSearch",
                    data: JSON.stringify({
                        'ItemId': itemid,
                        'batchNo': batcNo,
                        'dateTime': date,
                        'wareHouse': wareHousefrom,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var data = JSON.parse(response.d);
                        $("#Textstock").val(data.StockAvailable);
                        $("#TextRate").val(data.ItemRate);
                    },
                    error: function (msg) {
                        alert("Could not load available stock");
                    }
                });
                return true;
            }
            else if (itmCode == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide Item code',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            else if (wareHousefrom == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide warehouse from',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            else if (date == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide date',
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
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide batch number',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            return false;
        }
        var _gloabal = '';
        function fillbatchno(itemid) {
            debugger;
            var warehouse = $('#ctl00_MainContent_Select_wareHouseFrom').val();
            var transferdate = $('#StockTransferDate').val();

            if (warehouse == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select WareHouse From',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                $('#txtItemCode').tokenInput('clear');
                $("#batchnoddl").empty();
                $("#txttrnsfer_qty").val('');
                $("#Textquantity").val('');
                $("#Textstock").val('');
                $("#TextRate").val('');
                $("#TextAmount").val('');
                return false;
            }

            if (transferdate == '' || transferdate == null) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Stock Transfer Date',
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

            debugger;
            var optionsVen = '';
            var addedBatches = new Set();

            PageMethods.getbatchno(itemid, warehouse, transferdate, function (Tests) {
                debugger;
                var data = JSON.parse(Tests);
                optionsVen = '<option value="0">Please Select</option>';

                debugger;
                $.each(data, function (key, value) {
                    debugger;
                    if (value.Batch_No == "Non-Batch" && value.IsBatch == 0) {
                        return;
                    }
                    if (!addedBatches.has(value.Batch_No)) {
                        optionsVen += '<option value="' + value.Batch_No + '" >' + value.Batch_No + '</option>';
                        addedBatches.add(value.Batch_No);
                    }
                });

                _gloabal = optionsVen;
                $('#batchnoddl').html(_gloabal);
            });

            //loadStock(itemid);
        }
        //function fillbatchno(itemid) {
        //    debugger;
        //    var warehouse = $('#ctl00_MainContent_Select_wareHouseFrom').val();
        //    var transferdate = $('#StockTransferDate').val();
        //    if (warehouse == "0") {

        //        Swal.fire({
        //            icon: 'error',
        //            title: 'Error!',
        //            text: 'Please Select WareHouse From',
        //            showConfirmButton: false,
        //            timer: 2000,
        //            customClass: {
        //                popup: 'swal-big-popup',
        //                title: 'swal-big-title',
        //                htmlContainer: 'swal-big-text'
        //            }
        //        });
        //        $('#txtItemCode').tokenInput('clear');
        //        $("#batchnoddl").empty();
        //        $("#txttrnsfer_qty").val('');
        //        $("#Textquantity").val('');
        //        $("#Textstock").val('');
        //        return false;
        //    }
        //    if (transferdate == '' || transferdate == null) {
        //        Swal.fire({
        //            icon: 'error',
        //            title: 'Error!',
        //            text: 'Please Enter Stock Transfer Date',
        //            showConfirmButton: false,
        //            timer: 2000,
        //            customClass: {
        //                popup: 'swal-big-popup',
        //                title: 'swal-big-title',
        //                htmlContainer: 'swal-big-text'
        //            }
        //        });
        //    }
        //    debugger;
        //    var optionsVen = '';
        //    PageMethods.getbatchno(itemid, warehouse, transferdate, function (Tests) {
        //        debugger
        //        var data = JSON.parse(Tests);
        //        if (data.Batch_No == "") {
        //            getstockdetailnum();
        //        }
        //        optionsVen = '<option value="0">Please Select</option>';
        //        debugger;
        //        $.each(JSON.parse(Tests), function (key, value) {
        //            debugger;
        //            if (value.Batch_No == "Non-Batch" && value.IsBatch == 0) {
        //            }
        //            else {
        //                optionsVen += '<option value="' + value.Batch_No + '" >' + value.Batch_No + '</option>';
        //            }
        //        });
        //        _gloabal = optionsVen;
        //        $('#batchnoddl').html(_gloabal);
        //    });
        //    loadStock($("#txtItemCode").val());
        //}

        function PrintStoreTransfer() {
            debugger;
            var stID = '<% =Request.QueryString["stID"] %>';
            var locationInfo = window.location;
            var url = "/ReportViewer.aspx?ReportName=StoreTransferPrint&Title=Store Transfer Print &Store_TransferID=" + stID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + "/ReportViewer.aspx?ReportName=StoreTransferPrint&Title=Store Transfer Print &Store_TransferID=" + stID;
            }
            window.open(url, '_blank');
        }
        function GetWareHouseByBranch(b) {
            debugger;
            var optionsPO = '<option value="0">Please Select</option>';
            var BranchId;
            BranchId = b.value;
            if (BranchId == undefined) {
                BranchId = b;
            }
            var user_id = '<% =AppConfig.UserID %>';
            PageMethods.GetWHByBranchId(BranchId, user_id, function (res) {
                debugger;
                var b = JSON.parse(res);
                amountonedit = $('#ctl00_MainContent_txtAmount').val();
                debugger;
                $.each(b, function (key, value) {
                    optionsPO += '<option value="' + value.Id + '" >' + value.name + '</option>';
                })
                debugger;
                $("#ctl00_MainContent_Select_wareHouseFrom option").remove();
                $('#ctl00_MainContent_Select_wareHouseFrom').html(optionsPO);
                $("#ctl00_MainContent_Select_wareHouseFrom option").val(function (idx, val) {
                    $(this).siblings('[value="' + val + '"]').remove();
                    return val;
                });
            });
        }
        function GetWareHouseByBranchtooo(b) {
            debugger;
            var optionsPO = '<option value="0">Please Select</option>';
            var BranchId;
            BranchId = b.value;
            if (BranchId == undefined) {
                BranchId = b;
            }
            var user_id = '<% =AppConfig.UserID %>';
            PageMethods.GetWHByBranchIdtoooo(BranchId, user_id, function (res) {
                debugger;
                var b = JSON.parse(res);
                amountonedit = $('#ctl00_MainContent_txtAmount').val();
                debugger;
                $.each(b, function (key, value) {
                    optionsPO += '<option value="' + value.Id + '" >' + value.name + '</option>';
                })
                debugger;
                $("#ctl00_MainContent_Select_wareHouseTo option").remove();
                $('#ctl00_MainContent_Select_wareHouseTo').html(optionsPO);
                $("#ctl00_MainContent_Select_wareHouseTo option").val(function (idx, val) {
                    $(this).siblings('[value="' + val + '"]').remove();
                    return val;
                });
            });
        }
        $(document).ready(function () {
            debugger;
            //UserRights();
            $("#lblstatus").hide();
            $("#txtstatus_trnsfer").hide();
            $("#ctl00_MainContent_Select_wareHouseFrom option").each(function () {
                wareHouses.push({ 'Value': $(this).val(), 'Name': $(this).text() });
            });
            $('select').select2();
            loadtokenInputsDefaultPRNo();
            if (window.location.href.indexOf("stID") != -1) {
                stID = '<% =Request.QueryString["stID"] %>';
                var stNo = '<% =Request.QueryString["stN"] %>';
                if (typeof (stID) != 'undefined' && stID != "") {
                    getFillStock(stID);
                }
            }
            else {
                $("#btnUpdate").hide();
            }
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#StockTransferDate").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            $("#StockTransferDate").attr('disabled', true);
            $("#BtnAdd").click(function () {
                addItemRow();
            });
            $("#Textquantity").bind('keypress', function (e) {
                if (e.which == 13) {
                    if ($("#Textquantity").val().trim() != "" && (/^[0-9]/.test($("#Textquantity").val())))
                        $("#BtnAdd").trigger('click');
                }
            });
            $("#btnSave").click(function () {
                if ($("#stocktable tbody tr").length > 0)
                    AddStockMain();
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Items not found',
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
            $("#btnUpdate").click(function () {
                AddStockDetails(true);
            });
        });

        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "StoreStockTransfer.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnSave').show();
                    } else {
                        $('#btnSave').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }
        function fillStockTrans(data) {
            if (typeof (data.d) != 'undefined') {
                $("#ctl00_MainContent_txtStock_No").val(data.d[0].stockTransferNo);
                $("#StockTransferDate").val($.datepicker.formatDate('dd M yy', new Date(parseInt(data.d[0].stockTransferDate.substring(6, 19)))));
                $("#Remarks").val(data.d[0].remarks);
                $("#txtstatus_trnsfer").val(data.d[0].Transfer_Status);
                debugger;
                setTimeout(function () {
                    $('#ctl00_MainContent_Select_wareHouseFrom').val(data.d[0].wareHouseFrom);
                    $('#ctl00_MainContent_Select_wareHouseFrom').trigger('change');
                    $('#ctl00_MainContent_Select_wareHouseTo').val(data.d[0].wareHouseTo);
                    $('#ctl00_MainContent_Select_wareHouseTo').trigger('change');
                }, 1500);

                var checkstat = $("#txtstatus_trnsfer").val();
                if (checkstat == 'Approved') {
                    $("#lbltransit").hide();
                    $("#txttrnsfer_qty").hide();
                    $("#lblstatus").show();
                    $("#txtstatus_trnsfer").show();
                    $("#btnSave").hide();

                }
                if (checkstat == 'Created' || checkstat == null || checkstat == '') {

                }
                $("#stocktable tbody").empty();
                $.each(data.d, function (i) {
                    if (i > 0)
                        $("#stocktable tbody").append("<tr id='" + data.d[i].itemCode + "^" + data.d[i].batchNo + "^" + data.d[i].quantity + "^" + data.d[i].Rate + "^" + data.d[i].Amount + "^" + data.d[i].expiryDate + "'>" +
                            "<td class='dn'><label class='srNo'>" + i + "</label></td>" +
                            "<td class=combat>" + data.d[i].itemCode + "</td><td class=combat>" + data.d[i].batchNo + "</td>" +
                            "<td class=combat>" + data.d[i].description + "</td><td class='stkAvbl combat'>" + data.d[i].stockAvailable + "</td><td class=combat><span class='val'>" + data.d[i].quantity + "</span><input class ='editQnty dn' type='text' value='" + data.d[i].quantity + "' /></td><td class=combat><span class='val'>" + data.d[i].Rate + "</span><input class ='' type='text' value='" + data.d[i].Rate + "' /></td><td class=combat><span class='val'>" + data.d[i].Amount + "</span><input class ='' type='text' value='" + data.d[i].Amount + "' /></td>" +
                            "<td><span class='editDelete'><a class='editQuantity' >Edit</a>  |  <a class='deleteStkItem' rel='" + data.d[0].stockTransferNo + "'>Delete</a></span><span class='dn' id='" + data.d[i].batchNo + "'><img src='/images/loading.gif' /></span></td></tr>"
                        );
                });
                $("#StockTransferDate").attr('disabled', true);
                debugger;
                $('#ctl00_MainContent_Select_wareHouseFrom').attr('disabled', true);
                $('#ctl00_MainContent_Select_wareHouseTo').attr('disabled', true);
                calculatequantity();
                CommonActions(data);
            }
        }
        function calculatequantity() {
            debugger;
            var totalquantity = 0;
            $.each($('#stocktable tbody tr'), function (key, value) {
                var quanty = $($(value).find('td')[5]).text();
                totalquantity += parseFloat(quanty);
                debugger;
                $('#txttrnsfer_qty').val(totalquantity);
            });
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function CommonActions(data) {
            var stkID = -1;
            if (typeof (data) != 'undefined')
                stkID = (data.d != null && !$.isEmptyObject(data.d)) ? data.d[0].stockTransferId : -1;
            $("#stocktable").find(".editQuantity").bind('click', function () {
                abcload(this);
                $(this).parent().parent().prev().find(".val").hide();
                $(this).parent().parent().prev().find(".editQnty").removeClass('dn');
            });
            $('.editQnty').bind('keypress', function (e) {
                if (e.which == 13) {
                    debugger;
                    var stock = $(this).parent().parent().find('.stkAvbl').text();
                    stock = (typeof (stock) != 'undefined' && stock != "") ? parseInt(stock) : 0;
                    var qty = (typeof ($(this).val()) != 'undefined' && $(this).val() != "") ? parseInt($(this).val()) : 0;
                    if (stock >= qty && qty > 0) {
                        $(this).addClass('dn');
                        $(this).prev().text($(this).val()).show();
                    }
                    else if (qty > 0) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Quantity must be less than from available Stock',
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
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Quantity must be greater than zero',
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
            $("#stocktable").find(".deleteStkItem").bind('click', function () {
                debugger;

                var checkstats = $("#txtstatus_trnsfer").val();
                if (checkstats == 'Approved') {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Cannot Delete Approved STN',
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
                if (typeof (data) != 'undefined') {
                    var id = $(this).closest("tr").attr('id');
                    var stn = $(this).attr('rel');
                    stkID = (data.d != null && !$.isEmptyObject(data.d)) ? data.d[0].stockTransferId : -1;
                    if (typeof (id) != 'undefined' && typeof (stn) != 'undefined' && typeof (stkID) != 'undefined' && id != "" && stn != "")
                        deleteStockItem(id, stn, stkID);
                    $(this).closest('tr').remove();
                }
                else
                    $(this).closest('tr').remove();
                var findrow = stocktablebody.rows.length;
                debugger;
                if (findrow == 0) {
                    $('#ctl00_MainContent_Select_wareHouseFrom').attr('disabled', false);
                    $('#ctl00_MainContent_Select_wareHouseTo').attr('disabled', false);
                }
                $("#txttrnsfer_qty").val('');
                $("#Textquantity").val('');
                $("#Textstock").val('');
                $("#TextRate").val('');
                $("#TextAmount").val('');
                $('#txtItemCode').tokenInput('clear');
                $("#Remarks").val('');
                $("#batchnoddl").empty();
            });
            return stkID;
        }
        function deleteStockItem(id, stn, stkID) {
            if (!confirm('Are you sure you want to delete ?'))
                return;
            debugger;
            var ids = id.split('^');
            var itmCode = ids[0];
            var batch = ids[1];
            $.ajax({
                url: "StoreStockTransfer.aspx/DeleteStockItem",
                data: JSON.stringify({
                    'itemcode': itmCode,
                    'batch': batch,
                    'stn': stn,
                    'stId': stkID,
                }),
                dataType: "json",
                type: "Post",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Successfully Deleted.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    $("#" + id).remove();
                },
                error: function (msg) {
                    alert("Could not deleted.");
                }
            });
        }
        function addItemRow() {
            debugger;
            var item = $("#txtItemCode").val();
            var itmCode = item.split('-')[0];
            var wareHousefrom = "";
            var wareHouseTo = "";
            if ($("#btnUpdate").css("display") == "none") {
                wareHousefrom = $("#ctl00_MainContent_Select_wareHouseFrom").val();
                wareHouseTo = $("#ctl00_MainContent_Select_wareHouseTo").val();
            }
            else {
                $.when(findValWare($("#ctl00_MainContent_Select_wareHouseFrom option:selected").text())).done(function (data) {
                    $("#ctl00_MainContent_Select_wareHouseFrom").val(data);
                    wareHousefrom = data;
                });
                $.when(findValWare($("#ctl00_MainContent_Select_wareHouseTo option:selected").text())).done(function (val) {
                    $("#ctl00_MainContent_Select_wareHouseTo").val(val);
                    wareHouseTo = val;
                });
            }
            if (wareHouseTo == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select WareHouse To',
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
            var batcNo = $("#batchnoddl :selected").text();
            if (batcNo == "Please Select") {
                batcNo = '';
            }
            var quantity = parseInt(($("#Textquantity").val() != "") ? $("#Textquantity").val() : 0);
            var stock = $("#Textstock").val();
            var Rate = $("#TextRate").val();
            var Amount = $("#TextAmount").val();
            var stkNo = $("#ctl00_MainContent_txtStock_No").val();
            var itemCodeDescription = item.split('-')[1];
            var parseStock = parseInt(stock);
            var concat = itmCode + batcNo;
            var expDate = $("#expiry").val();
            var find = false;
            if (parseStock < 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Stock Must be Greater then Zero',
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
            debugger;
            if (itmCode.trim() != "") {
                $.each($("#stocktable").find('tbody').find('tr'), function (index) {
                    var srNo = $(this).find($('.srNo')).text();
                    if (srNo == concat) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Item already exist',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        find = true;
                    }
                });
                if (!find) {
                    if ((quantity <= parseStock) && (quantity > 0)) {
                        if (wareHousefrom.indexOf(wareHouseTo) == -1) {
                            var html = "";
                            if ($("#btnUpdate").css("display") != "none") {
                                html = "<td class=combat>" + itemCodeDescription + "</td><td class='stkAvbl combat'>" + stock + "</td><td class=combat><span class='val'>" + quantity + "</span><input class ='editQnty dn' type='text' value='" + quantity + "' /></td><td class=combat><span class='val'>" + Rate + "</span><input class ='' type='text' value='" + Rate + "' /></td><td class=combat><span class='val'>" + Amount + "</span><input class ='' type='text' value='" + Amount + "' /></td>" +
                                    "<td><span class='editDelete'><a class='editQuantity' >Edit</a>  |  <a class='deleteStkItem' rel='" + stkNo + "'>Delete</a></span><span class='dn' id='" + batcNo + "'><img src='/images/loading.gif' /></span></td>";
                            }
                            else {
                                html = "<td class=combat>" + itemCodeDescription + "</td><td class='stkAvbl combat'>" + stock + "</td>" + "<td class=combat>" + quantity + "</td>" + "<td class=combat>" + Rate + "</td>" + "<td class=combat>" + Amount + "</td><td><a class='deleteStkItem'>Delete</a></td>";
                            }
                            var rowCount = $("#stocktable tbody tr").length + 1;
                            $("#stocktable tbody").append("<tr id='" + itmCode + "^" + batcNo + "^" + quantity + "^" + Rate + "^" + Amount + "^" + expDate + "'><td class='dn'><label class='srNo'>" + rowCount + "</label></td><td class=combat>" +
                                itmCode + "</td> <td class=combat>" +
                                batcNo + "</td>" + html + "</tr>"
                            );
                            $('#ctl00_MainContent_Select_wareHouseFrom').attr('disabled', true);
                            $('#ctl00_MainContent_Select_wareHouseTo').attr('disabled', true);
                            $("#StockTransferDate").attr('disabled', true);
                            calculatequantity();
                            CommonActions();
                            $("#Textquantity").val('');
                            $("#Textstock").val('');
                            $("#TextRate").val('');
                            $("#TextAmount").val('');
                            $('#txtItemCode').tokenInput('clear');
                            $("#Remarks").val('');
                            $("#batchnoddl").empty();
                        }
                        else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Ware house must not be same',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                            $("#ctl00_MainContent_Select_wareHouseTo").val(0);
                            $("#ctl00_MainContent_Select_wareHouseTo").trigger('change');
                            return false;
                        }
                    }
                    else {
                        $("#Textquantity").val(0); Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Quantity must be less than Stock and Greater then Zero',
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
                }
            }
            else {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide required fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            return false;
        }
        function AddStockMain() {
            debugger;
            var stockNo = 0;
            var stockDate = $("#StockTransferDate").val();
            var wareHouseFrom = $("#ctl00_MainContent_Select_wareHouseFrom").val();
            var wareHouseTo = $("#ctl00_MainContent_Select_wareHouseTo").val();
            var stnStatus = "Created";
            var trsnfrstatus = $('#txtstatus_trnsfer').val();
            var remarks = $("#Remarks").val();
            $.ajax({
                url: "StoreStockTransfer.aspx/AddStockMain",
                data: '{"stockTransferNo":"' + stockNo + '", "stockTransferDate":"' + stockDate + '","wareHouseFrom":"' + wareHouseFrom + '","wareHouseTo":"' + wareHouseTo + '","stnStatus":"' + stnStatus + '","remarks":"' + remarks + '","trsnfrstatus":"' + trsnfrstatus + '"}',
                dataType: "json",
                type: "Post",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    AddStockDetails();
                },
                error: function (msg) {
                    alert("Error while inserting data");
                }
            });
        }
        function AddStockDetails(isUpdate) {
            debugger;
            var details = {};
            var detailAry = [];
            var findInvalid = false;
            var actionUrl = "AddStockDetails";
            var stockID = -1;
            if (isUpdate) {
                actionUrl = "UpdateStockDetails";
                stockID = (typeof (stID) != 'undefined' && stID != "") ? stID : -1;
            }
            $.each($("#stocktable").find('tbody').find('tr'), function (index) {
                var itemCode = $(this).attr("id").split('^')[0];
                var batchNo = $(this).attr("id").split('^')[1];
                var quantity = parseInt($(this).attr("id").split('^')[2]);
                var Rate = parseFloat($(this).attr("id").split('^')[3]);
                var Amount = parseFloat($(this).attr("id").split('^')[4]);
                var expiry = $(this).attr("id").split('^')[4];
                if (isUpdate)
                    quantity = (typeof ($(this).find('.val').text()) != 'undefined' && $(this).find('.val').text() != "") ? parseInt($(this).find('.val').text()) : -1;
                var stock = /^[0-9]/.test($(this).find('.stkAvbl').text()) ? parseInt($(this).find('.stkAvbl').text()) : -1;
                debugger;
                if (stock >= quantity) {
                    details = {};
                    details.itemCode = itemCode;
                    details.batchNo = batchNo;
                    details.quantity = quantity;
                    details.Rate = Rate;
                    details.Amount = Amount;
                    details.stockTransferId = stockID;
                    details.expiryDate = expiry;
                    detailAry.push(details);
                }
                else {
                    findInvalid = true;
                    var msg = "Data could not be added due to Item Code = " + itemCode + ". \nQuatity must be less than from Stock !";
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: msg,
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
            if (!findInvalid) {
                $.ajax({
                    url: "StoreStockTransfer.aspx/" + actionUrl,
                    data: JSON.stringify({
                        'stk': detailAry
                    }),
                    dataType: "json",
                    type: "Post",
                    contentType: "application/json; charset=utf-8",
                    success: function (data) {
                        if (typeof (data.d) != 'undefined') {
                            if (data.d.toString().toLowerCase().indexOf("error") != -1) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Data could not be saved',
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
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Data Successfully saved.',
                                    showConfirmButton: false,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                window.location = "StoreStockTransferView.aspx";

                            }
                        }
                    },
                    error: function (msg) {

                        alert("Error while inserting data");
                    }
                });
            }
        }
        function loadstockTransferNo() {
            debugger;
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "StoreStockTransfer.aspx/GetMax",
                data: {},
                dataType: "json",
                success: function (data) {
                    $("#ctl00_MainContent_txtStock_No").val(data.d);
                },
                error: function (msg) {
                    debugger;
                    alert("Could not load Stock transfer number");
                }
            });
        }
        function loadStock(item) {
            debugger;
            var itmCode = item.split('-')[0];
            var wareHousefrom = $("#ctl00_MainContent_Select_wareHouseFrom").val();
            var date = $("#StockTransferDate").val();
            var batcNo = $("#batchnoddl :selected").text();
            debugger;
            if (itmCode != "" && wareHousefrom != "" && date != "") {
                $.ajax({
                    type: "POST",
                    url: "StoreStockTransfer.aspx/GetStock",
                    data: JSON.stringify({
                        'itemCode': itmCode,
                        'batchNo': batcNo,
                        'dateTime': date,
                        'wareHouse': wareHousefrom,
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        $("#Textstock").val(response.d.stockAvailable);
                    },
                    error: function (msg) {
                        alert("Could not load available stock");
                    }
                });
                return true;
            }

            else if (itmCode == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide Item code',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            else if (wareHousefrom == "") Swal.fire({
                icon: 'error',
                title: 'Error!',
                text: 'Please provide warehouse from',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
            else if (date == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please provide date',
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
                return true;
            }
            return false;
        }
        function LoadBatchNoDetail() {
            debugger;
            //var itemid = $("#txtItemCode").val().toString().split('-')[0];
            var itemid = itmid;
            var warehouse = $("#ctl00_MainContent_Select_wareHouseFrom").val();
            if (itemid.trim() != "") {
                PageMethods.PerformBatchNoSearch(itemid, warehouse, function (data) {
                    var rows = "";
                    debugger;
                    for (var i = 0; i < data.length; i++) {
                        debugger;
                        if (data[i].Batch_Balance != 0.00) {
                            $("#Textstock").val(Number(data[i].Batch_Balance));
                        }
                    }
                    $('#Textquantity').focus();
                });
            }
        }
        var itmid;
        function loadtokenInputsDefaultPRNo() {
            debugger
            $('#txtItemCode').tokenInput("../../json.aspx?Table=INV_Items",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#txtItemCode").val(item.name);
                             itmid = item.id;
                            fillbatchno(itmid);
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
        }
        function appendBatch(anchor) {
            var row = $(anchor).parents('tr')[0];
            var bethNo = $($(row).find('td')[1]).text();
            var expiry = $($(row).find('td')[2]).text();
            var Balnce = $($(row).find('td')[3]).text();
            $("#Textbatchno").val(bethNo);
            $("#Textstock").val(Number(Balnce));
            $("#expiry").val(expiry);
            $('#POItemsModel').modal('hide');
        }
        function getFillStock(stID) {
            debugger;
            $("#btnSave").hide();
            $("#btnUpdate").show();
            $(".actionClm").show();
            $("#ctl00_lbl2").text("Add / Update Stock");
            $.ajax({
                url: "StoreStockTransfer.aspx/FillStockdetails",
                data: JSON.stringify({
                    'Stock_Transfer_ID': stID,
                }),
                dataType: "json",
                type: "Post",
                contentType: "application/json; charset=utf-8",
                success: function (data) {
                    if (data != null && !$.isEmptyObject(data))
                        fillStockTrans(data);
                },
                error: function (msg) {
                    alert("Error while inserting data");
                }
            });
        }
        function findValWare(name) {
            var vals = "";
            $.map(wareHouses, function (e) {
                if (e.Name == name)
                    return vals = e.Value;
            });
            return vals;
        }

        function abcload(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var itemcode = $($(row).find('td')[1]).text();
            var qty = $($(row).find('td')[5]).text();
            $('#txtItemCode').tokenInput('clear');
            var tokenData = httpGet("../json.aspx?Table=INV_Items_STN&q=" + itemcode);
            $('#txtItemCode').tokenInput("add", { id: JSON.parse(tokenData)[0].id, name: JSON.parse(tokenData)[0].name });
            $('#Textquantity').val(qty);
            $(row).remove();
        }
        function CalculateAmount() {
            var TransferQty = $("#Textquantity").val();
            var Rate = $("#TextRate").val();
            var Amount = TransferQty * Rate;
            $("#TextAmount").val(Amount);
        }

        function CheckSTORESTOCKTRANSFERApprovalRightsAndShowButton(stId) {
            callPageMethod('CheckSTORESTOCKTRANSFERApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetSTORESTOCKTRANSFERApprovalInfo', { StockTransferId: stId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                        }
                    });
                }
            });
        }
        function ApproveSTORESTOCKTRANSFERFromEdit() {
            var transferId = stID;
            Swal.fire({
                title: 'Approve Stock Transfer?',
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
                    callPageMethod('ApproveSingleSTORESTOCKTRANSFER', { StockTransferId: transferId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'Stock Transfer has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }

        if (stID != "") {
            setTimeout(function() {
                var status = $("#txtstatus_trnsfer").val();
                if (status == "Created" || status == "" || status == null || status == "Pending") {
                    CheckSTORESTOCKTRANSFERApprovalRightsAndShowButton(stID);
                }
            }, 1500);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="stockno" style="font-weight: bold">Stock no:  </label>
            <input class="form-control" type="text" id="txtStock_No" value="New" runat="server" readonly="readonly" />
        </div>


        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="StockTransferDate">Date: </label>
            <input class="form-control" type="text" id="StockTransferDate" />
        </div>



   
        <div class="col-lg-3 col-md-6 col-sm-12">

            <label for="Whf">Ware House From:</label>
            <asp:DropDownList ID="Select_wareHouseFrom" class="form-select" runat="server"></asp:DropDownList>

        </div>

        <div class="col-lg-3 col-md-6 col-sm-12">
            <label id="lbltransit">In Transit:</label>
            <label id="lblstatus">Status:</label>
            <input class="form-control" type="text" id="txtstatus_trnsfer" name="txtstatus_trnsfer" readonly="readonly" />
            <input class="form-control" type="text" id="txttrnsfer_qty" name="txttrnsfer_qty" readonly="readonly" />
        </div>
        </div>
        <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            
                <label for="WHt">Ware House To:</label>
           
                <asp:DropDownList class="form-select" ID="Select_wareHouseTo" runat="server"></asp:DropDownList>
            </div>
        

        <div class="col-lg-3 col-md-6 col-sm-12">
            
                <label for="ItemCode">Item Code : </label>
            
                <input class="form-control" type="text" id="txtItemCode" />
            
        </div>


        <div class="col-lg-3 col-md-6 col-sm-12">
            
                <label for="BatchNo">Batch No:</label>
            
                <select id="batchnoddl" name="batchnoddl" onchange="getstockdetailnum();"></select>
            
        </div>




        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="Quantity">Quantity : </label>
            <input class="form-control" type="text" id="Textquantity" onkeyup="CalculateAmount();" />
        </div>
        </div>


        <div class="row">
        <div class="col-lg-3 col-md-8 col-sm-12">
            <label for="Stock">Stock :</label>
             <input class="form-control" type="text" id="Textstock" readonly="readonly" />
            
        </div>
        <div class="col-lg-3 col-md-8 col-sm-12">
            <label for="Stock">Rate :</label>
             <input class="form-control" type="text" id="TextRate" readonly="readonly" />
            
        </div>
        <div class="col-lg-3 col-md-8 col-sm-12">
            <label for="Stock">Amount :</label>
             <input class="form-control" type="text" id="TextAmount" readonly="readonly" />
            
        </div>
        <div class="col-lg-1 col-md-2 col-sm-4">           
            <input id="BtnAdd" class="btn btn-primry" type="button" value="+" style="margin-top:25px" />               
        </div>
        
       <div class="col-lg-8 col-md-12 col-sm-12">
            <label for="Remarks">Remarks :</label>
            <input class="form-control" type="text" id="Remarks" />
            
        </div>
        
    </div>


    <input type="hidden" id="expiry" />
   
        <div class="row">
            <div class="table-responsive">
    <table class="table" id="stocktable">
        <thead>
            <tr>
                <th class='dn'>Sr#</th>
                <th>Item Code</th>
                <th>Batch No</th>
                <th>Description</th>
                <th>Stock</th>
                <th>Quantity</th>
                <th>Rate</th>
                <th>Amount</th>
                <th class="actionClm">Action</th>
            </tr>
        </thead>
        <tbody id="stocktablebody"></tbody>
    </table>
                </div>
            </div>
       

    <div class="row">
         <div class="col-lg-8">
             <div class="row">
                 <div class="col-lg-2 col-md-4 col-sm-12">
                     <input id="btnSave" class="btn btn-primry" type="button" value="Save" />
                     <input id="btnUpdate" class="btn btn-primry" type="button" value="Update" />
                 </div>
                 <div class="col-lg-2 col-md-4 col-sm-12">
                     <input type="button" class="btn btn-yellow" value="New" onclick="window.open('StoreStockTransfer.aspx')" />
                 </div>
                 <div class="col-lg-2 col-md-4 col-sm-12">
                     <input type="button" value="View" class="btn-gray" onclick="window.location.href ='StoreStockTransferView.aspx'" />
                 </div>
                  <div class="col-lg-2 col-md-2 col-sm-3">
                    <input type="button" id="btnPrint" class="btn btn-primry" onclick="PrintStoreTransfer()" value="Print" />
                </div>
                <div class="col-lg-2 col-md-2 col-sm-3">
                    <input type="button" style="display:none" class="btn btn-primry" value="Approve" id="btnApprove" onclick="ApproveSTORESTOCKTRANSFERFromEdit()" />
                </div>
             </div>
        </div>
    </div>
    <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add PO Items</h4>
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table" style="width: 953px; height: 146px !important; height: auto; overflow: scroll;" id="tblPOItemstModelTable">
                        <thead>
                            <tr>
                                <th style="width: 32px;"></th>
                                <th>Batch No </th>
                                <th>Expiry Date </th>
                                <th>Balance</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <input type="button" id="PoItem" name="PoItem" value="Done" onclick="appendBatch()" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
