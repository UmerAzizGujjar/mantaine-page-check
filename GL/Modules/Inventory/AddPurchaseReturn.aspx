<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddPurchaseReturn.aspx.cs" Inherits="PMS.Inventory.AddPurchaseReturn" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   

    <script type="text/javascript">

        var elementIsClicked = false;

        window.onbeforeunload = function (event, args) {
            var isPostBack = '<% =Convert.ToString(Page.IsPostBack).ToLower() %>';
            if (((window.event.clientX || event.clientX) < 0) || ((window.event.clientY || event.clientY) < 0)) 
            {
                event = window.event;
                event.returnValue = msg;
                return msg;
            }
            if ((window.event.clientX < 0) || (window.event.clientY < 0)) 
            {
                event = window.event;
                event.returnValue = msg;
                return msg;
            }
            else if (window.event.altKey == true || window.event.ctrlKey == true) 
            {
                event = window.event;
                event.returnValue = msg;
                return msg;
            }
            else if (elementIsClicked == true) {
            }
            else {
                if ($("#txt_Purchase_Return").val() != "") {
                    return true;
                    return msg;
                }
                else {
                    return msg;
                }
            }
        }
        $(document).ready(function () {
            $('[id*=checkHeader]').click(function () {
                var isTrue = $('#checkHeader').is(':checked');
                if (isTrue) {

                    $('.chktd').prop('checked', true);
                    setTimeout(function () {
                        $("#tblPOItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                            var row = $(this);
                            append(row);

                            $('input').attr('autocomplete', 'off');
                        });
                    }, 1000);
                }
                else {
                    $('.chktd').prop('checked', false);
                }
            });
            $('select').select2();
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txt_Purchase_Return_date").datepicker({ dateFormat: 'dd M yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', false);
            $("#txt_Purchase_Return_date").val(formattedDate);
            FillWareHousess();
            FillVendors();
              <% if (Request.QueryString["ID"] != null)
        { %>
            var ID = '<%= Request.QueryString["ID"]%>'
            LoadPurchaseData(ID);
            <% } %>
            var ID = '<%= Request.QueryString["ID"]%>'
            if (ID == '') {
                $('#btn_Print').hide();
                $('#btnApprove').hide();
                $('#btnUnApprove').hide();
                $('#btnVoucher').hide();
            }
            $('#btn_GRN').on('click', function () {
                debugger;
                var vendorId = $("#ddl_VendorName").val();
                var ddltype = $('#ddl_type').val();
                var InvOrgId = $("#ddl_ReturnFormInventoryOrg").val();

                if (vendorId != "0" && InvOrgId != "0" && ddltype != "0") {
                    LoadGRNDetail(vendorId, ddltype, InvOrgId)
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Vendor,Type and WareHouse',
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
        });
        function LoadGRNDetail(vendorId, ddltype, InvOrgId) {
            debugger
            PageMethods.GetGRNDetail(vendorId, ddltype, InvOrgId, function (data) {
                debugger;
                var Test = JSON.parse(data);
                $('#tblPOItemstModelTable tbody tr').remove();
                var rows = "";
                for (var i = 0; i < Test.length; i++) {
                    debugger;
                    rows = '<tr>' +
                        '<td><input name="chkselect" class="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 0px;height: 36px;" onclick="append(this)"/></td>' +
                        '<td>' + Test[i].Item_Code + '</td> ' +
                        '<td>' + Test[i].Description + '</td> ' +
                        '<td style="display:none">' + Test[i].UOM + '</td> ' +
                        '<td style="display:none">' + Test[i].Batch_No + '</td> ' +
                        '<td style="display:none">' + Test[i].Batch_Balance + '</td> ' +
                        '<td>' + Test[i].GRNQty + '</td> ' +
                        '<td style="display:none"></td>' +
                        '<td style="display:none">' + Test[i].GRN_Num + '</td> ' +
                        '<td style="display:none">' + Test[i].TransType + '</td> ' +
                        '<td style="display:none">' + Test[i].GRN_ID + '</td> ' +
                        '<td style="display:none">' + Test[i].GRN_detail_Id + '</td> ' +
                        '<td style="display:none">' + Test[i].Item_ID + '</td> ' +
                        '<td style="display:none">' + Test[i].Rate + '</td> ' +
                        '<td style="display:none">' + Test[i].GRN_Date + '</td> ' +
                        '</tr>';
                    $('#tblPOItemstModelTable tbody').append(rows);
                    $('input').attr('autocomplete', 'off');
                }
                $('#POItemsModel').modal({
                    backdrop: 'static'
                });
            });
        }

        function LoadPurchaseData(ID) {
            PageMethods.LoadPurchaseReturnInvocieDetail(ID, function (resp) {
                var data = JSON.parse(resp);

                var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Purchase_Return_Date.substring(6, 19))))
                $('#ctl00_MainContent_txtPurchase_Date').val(datetime);

                setTimeout(function () {
                    $('#ddl_ReturnFormInventoryOrg').val(data.WareHouse).trigger('change');
                }, 1500);

                setTimeout(function () {
                    $('#ddl_VendorName').val(data.Vendor_ID).trigger('change');
                    $('#ddl_type').val(data.Invoice_Type).trigger('change');
                }, 1000);

                $('#txt_Purchase_Return').val(data.Purchase_Return_No);
                $('#txt_Remarks').val(data.Remarks);
                $('#txtstatus').val(data.Status);
                var status = $('#txtstatus').val();
                if (status == "Deleted") {
                    $('#btn_Save').attr("disabled", 'disabled');
                    
                    $('#btn_Save').hide();
                    $('#btnVoucher').hide();
                }
                if (status == "Approved") {
                    $('#btn_Save').attr("disabled", 'disabled');
                    UserUnApproveButtonRights();

                    $('#btnVoucher').show();
                    $('#btn_Save').hide();
                }
                if (status == "Created") {

                    $('#btnVoucher').hide();
                }
                LoadPurchaseDetail(ID);
                setTimeout(function () {
                    $('#ddl_ReturnFormInventoryOrg').val(data.Inventory_Org).trigger('change');
                }, 1000);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        var iteration = 0;
        function LoadPurchaseDetail(ID) {
            PageMethods.LoadPurchaseReturn_Detail(ID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tblDetails tbody tr').length)));
                var data = (JSON.parse(resp));
                selectedOptions = data;
                iteration++;
                var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                $.each(data, function (key, value) {
                    debugger;
                    if (value.BatchNum != null || value.BatchNum != '') {
                        value.BatchNum = '';
                    }
                    var GRNDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(value.GRN_Date.substring(6, 19))));
                    rows += '<tr>' +
                        '<td><input type="hidden" id="txtitemcode' + rowlength + '" name="txtitemcode" value="' + value.Item_Code + '"/>' + value.Item_Code + '</td>' +
                        '<td><input type="hidden" id="txtitemDesc' + rowlength + '" name="txtitemDesc" value="' + value.Description + '"/>' + value.Description + '</td> ' +
                        '<td><input type="hidden" id="txtUOM' + rowlength + '" name="txtUOM" value="' + value.UOM + '"/>' + value.UOM + '</td> ' +
                        '<td class="headcol_2"><input type="hidden" id="txtBatchNum' + rowIndex + '" name="txtBatchNum" value="' + value.Batch_No + '"/>' + value.Batch_No + '</td> ' +
                        '<td><input type="hidden" id="txtBatchBalnce' + rowlength + '" name="txtBatchBalnce" value="' + value.Batch_Balance + '"/>' + value.Batch_Balance + '</td>' +
                        '<td><input type="hidden" id="txtQty' + rowlength + '" name="txtQty" value="' + value.GRNQty + '"/>' + value.GRNQty + '</td>' +
                        '<td><input type="text" id="txtTransQty' + rowlength + '" name="txtTransQty" value="' + value.Qty + '"/></td>' +
                        '<td><input type="hidden" id="txtTransNum' + rowlength + '" name="txtTransNum" value="' + value.GRN_Num + '"/>' + value.GRN_Num + '</td>' +
                        '<td><input type="hidden" id="txtTransType' + rowlength + '" name="txtTransType" value="' + value.Trans_Type + '"/>' + value.Trans_Type + '</td>' +
                        '<td style="display:none"><input type="hidden" id="GRNId' + rowlength + '" name="GRNId" value="' + value.GRN_ID + '"/></td>' +
                        '<td style="display:none"><input id="txtGRNDetailId' + rowlength + '" name="txtGRNDetailId" value="' + value.GRN_Detail_ID + '" type="text" style="width: 31px!important;border: none;"/></td>' +
                        '<td style="display:none"><input type="hidden" id="txtItemId' + rowlength + '" name="txtItemId" value="' + value.Item_ID + '"/></td>' +
                        '<td><input type="hidden" id="txtGRNDate' + rowlength + '" name="txtGRNDate" value="' + GRNDate + '"/>' + GRNDate + '</td>' +

                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: 1px;" i=""></i></a></td>' +
                        '</tr>'
                    length++;
                });
                $("#tblItemDescription").append(rows);
                $('input').attr('autocomplete', 'off');
                $('#btn_Save').val('Update');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function FillWareHousess() {
            debugger;
            var optionInv = '';
            PageMethods.getDDLlist(function (Tests) {
                debugger
                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_ReturnFormInventoryOrg').html(optionInv);
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
                $('#ddl_VendorName').html(optionsVen);
            });
        }
        function toggle(source) {
            var checkboxes = document.querySelectorAll('input[type="checkbox"]');
            for (var i = 0; i < checkboxes.length; i++) {
                if (checkboxes[i] != source)
                    checkboxes[i].checked = source.checked;
            }
        }
        function append(anchor) {
            debugger;
            var rows = '';
            var row = $(anchor).parents('tr')[0];
            console.log(row);
            var itemCode = $($(row).find('td')[1]).text();
            var itemDescription = $($(row).find('td')[2]).text();
            var UOM = $($(row).find('td')[3]).text();
            var BatchNum = $($(row).find('td')[4]).text();
            var BatchBalance = $($(row).find('td')[5]).text();
            var Qty = $($(row).find('td')[6]).text();
            var TransQty = $($(row).find('td')[7]).text();
            var GRNNum = $($(row).find('td')[8]).text();
            var TransType = $($(row).find('td')[9]).text();
            var GRNId = $($(row).find('td')[10]).text();
            var GRNDetailId = $($(row).find('td')[11]).text();
            var ItemId = $($(row).find('td')[12]).text();
            var Rate = $($(row).find('td')[13]).text();
            var GRNDate = $($(row).find('td')[14]).text();

            var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(GRNDate.substring(6, 19))));


            var length = $("#tblItemDescription tr:gt(0)").length;
            if (length > 0) {
                length = length + 1;
            }
            else {
                length = 1;
            }
            var test_array = $('#tblItemDescription').find('input[name=txtitemcode][value=' + itemCode + ']');
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

                $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                return false;
            }
            rows += '<tr>' +
                '<td><input type="hidden" id="txtitemcode' + length + '" name="txtitemcode" value="' + itemCode + '"/>' + itemCode + '</td>' +
                '<td><input type="hidden" id="txtitemDesc' + length + '" name="txtitemDesc" value="' + itemDescription + '"/>' + itemDescription + '</td> ' +
                '<td><input type="hidden" id="txtUOM' + length + '" name="txtUOM" value="' + UOM + '"/>' + UOM + '</td> ' +
                '<td class="headcol_2"><input type="hidden" id="txtBatchNum' + length + '" name="txtBatchNum" value="' + BatchNum + '"/>' + BatchNum + '</td> ' +
                '<td><input type="hidden" id="txtBatchBalnce' + length + '" name="txtBatchBalnce" value="' + BatchBalance + '"/>' + BatchBalance + '</td>' +
                '<td><input type="hidden" id="txtQty' + length + '" name="txtQty" value="' + Qty + '"/>' + Qty + '</td>' +
                '<td><input type="text" id="txtTransQty' + length + '" name="txtTransQty"/></td>' +
                '<td><input type="hidden" id="txtTransNum' + length + '" name="txtTransNum" value="' + GRNNum + '"/>' + GRNNum + '</td>' +
                '<td><input type="hidden" id="txtTransType' + length + '" name="txtTransType" value="' + TransType + '"/>' + TransType + '</td>' +
                '<td><input type="hidden" id="txtRate' + length + '" name="txtRate" value="' + Rate + '"/>' + Rate + '</td>' +
                '<td style="display:none"><input type="hidden" id="GRNId' + length + '" name="GRNId" value="' + GRNId + '"/></td>' +
                '<td style="display:none"><input id="txtGRNDetailId' + length + '" name="txtGRNDetailId" value="' + GRNDetailId + '" type="text" style="width: 31px!important;border: none;"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtItemId' + length + '" name="txtItemId" value="' + ItemId + '"/></td>' +
                '<td style="display:none"><input type="hidden" id="txtGrnDate' + length + '" name="txtGrnDate" value="' + datetime + '" /></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;margin-left: 16px; color: #f30a0a;position:relative;left: 1px;" i=""></i></a></td>' +
                '</tr>'
            debugger;
            $("#tblItemDescription").append(rows);
            $('input').attr('autocomplete', 'off');
            length++;
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function SaveAllRecord() {
            elementIsClicked = true;
            debugger;
            if (validateSave()) {
                var btnSave = $('#btn_Save').val();
                var VendorId = $('#ddl_VendorName').val();
                var PurchaseReturnNum = $('#txt_Purchase_Return').val();
                var PurchaseReturndate = $('#txt_Purchase_Return_date').val();
                var ReturnFormInventoryOrg = $('#ddl_ReturnFormInventoryOrg').val();
                var InvoiceType = $('#ddl_type').val();
                var Remarks = $('#txt_Remarks').val();
                var table = $('#tblItemDescriptionDetail');
                var Item_list = [];
                debugger;
                table.find('tr').each(function (key, value) {
                    debugger;
                    Item_list.push({ 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'BatchNum': $(value).find('td input[name=txtBatchNum]').val(), 'Qty': $(value).find('td input[name=txtTransQty]').val(), 'TransType': $(value).find('td input[name=txtTransType]').val(), 'GRNId': $(value).find('td input[name=GRNId]').val(), 'GRNDetailId': $(value).find('td input[name=txtGRNDetailId]').val(), 'GRNNum': $(value).find('td input[name=txtTransNum]').val(), 'GRNDate': $(value).find('td input[name=txtGrnDate]').val() });
                });
                $('#btn_Save').attr('disabled', true);
                var AllItemDetail = { 'VendorId': VendorId, 'PurchaseReturnNum': PurchaseReturnNum, 'PurchaseReturndate': PurchaseReturndate, 'ReturnFormInventoryOrg': ReturnFormInventoryOrg, 'InvoiceType': InvoiceType, 'Remarks': Remarks, 'ItemList': Item_list };
                PageMethods.SavePurchaseReturn(btnSave, JSON.stringify(AllItemDetail), function (res) {
                    debugger;
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

                    window.location = "PurchaseReturnList.aspx";
                });
            }
        }
        function validateSave() {
            debugger;
            var table = $('#tblItemDescriptionDetail');
            var proceed = true;
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

            }
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                table.find('tr').each(function (key, value) {
                    var Qty = $(value).find('td input[name=txtBatchBalnce]').val();
                    debugger;
                    var TransQty = $(value).find('td input[name=txtTransQty]').val();
                    if (!TransQty) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Qty',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }


                    if (parseFloat(TransQty) > parseFloat(Qty)) {
                        debugger;
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Qty Must Be Less Than Total Stock',
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
            return proceed;
        }
        function Approve() {
            debugger;
            elementIsClicked = true;
            debugger;
            var PRTId = '<% =Request.QueryString["ID"] %>';
            PageMethods.ApprovePurchaseReturn(PRTId, function (Tests) {
                debugger;
                var message = JSON.parse(Tests);
                if (message[0].Column1 != null || message[0].Column1 != "") {
                    debugger;
                    alert(message[0].Column1);
                    window.location = "PurchaseReturnList.aspx";
                }
            });
        }

        function UserUnApproveButtonRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "AddPurchaseReturn.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnApprove').show();
                        $('#btnUnApprove').show();
                    } else {
                        $('#btnApprove').hide();
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
      
        debugger;
        function PrintVoucher() {
            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=Purchase Return Voucher&TransID=' + id + '&TransType=PURR';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher&ReportTitle=Purchase Return Voucher&TransID=' + id + '&TransType=PURR';
            }
            window.open(url, '_blank');
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lb_Purchase_Return">Purchase Return #</label>
            <input class="w281" type="text" value="New" readonly="readonly" name="txt_Purchase_Return" id="txt_Purchase_Return" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lb_Purchase_Return_Date">Purchase Return Date</label>
            <input class="w281" type="text" name="txt_Purchase_Return_date" id="txt_Purchase_Return_date" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lbl_status">Status</label>
            <input type="text" readonly="readonly" id="txtstatus" value="Created" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lb_VendorName">Vendor</label>
            <select id="ddl_VendorName"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lb_ReturnFormInventoryOrg">Return Form WareHouse</label>
            <select id="ddl_ReturnFormInventoryOrg"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label class="lb_fixWidth_120" id="lbl_ddl_type">Return Type</label>
            <select id="ddl_type">
                <option value="0">Please Select</option>
                <option value="1">Before Invoice</option>
                <option value="2">After Invoice</option>
            </select>
        </div>
    </div>
    <div class="row"> 
        
        <div class="col-lg-4 col-md-6 col-sm-8">
            <label class="lb_fixWidth_120" id="lb_Remarks" style="float: left;">Remarks</label>
            <textarea cols="4" rows="2" name="txt_Remarks" id="txt_Remarks" style="width: 100%;height:35px"></textarea>
        </div>
        <div class="col-sm-6 col-lg-1 col-md-6">
            <input type="button" class="col-lg-1" name="btn_Purchase" value="Purchase" id="btn_Purchase" style="display: none;" />
            <input type="button" class="btn btn-primry" name="btn_GRN" value="Select" id="btn_GRN" style="margin-top: 25px" />
        </div>
    </div>


    <div>
        <div class="row">
            <div class="col-lg-12">
                <table class="table table-bordered" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th>Item Code</th>
                            <th>Item Description</th>
                            <th>UOM</th>
                            <th>Batch#</th>
                            <th>Total Stock</th>
                            <th>GRN Qty</th>
                            <th style="width:8%">Qty</th>
                            <th>GRN #</th>
                            <th>Trans Type</th>
                            <th>Rate</th>
                            <th style="display: none">GRNID</th>
                            <th style="display: none">GRNdetail</th>
                            <th style="display: none">GRNNum</th>
                            <th style="display: none">GRNDate</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    <div class="row">
        <div class=" col-lg-6 col-md-10 col-sm-12">
            <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input class="btn btn-primry" type="button" name="btn_Save" value="Save" id="btn_Save" onclick="SaveAllRecord()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input class="btn-gray" type="button" name="btnlist" value="List" id="btnlist" onclick="window.location = 'PurchaseReturnList.aspx'" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input class="btn btn-yellow" type="button" name="btn_New" value="New" id="btn_New" onclick="window.location = 'AddPurchaseReturn.aspx'" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" value="Approve" class="btn btn-primry" id="btnApprove" onclick="Approve()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-primry" style="display: none" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" value="Voucher" class="btn btn-primry" id="btnVoucher" onclick="PrintVoucher()" />
            </div>
        </div>
    </div>
    </div>

    <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto; float: right;" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add GRN Items </h4>
                </div>
                <input type="hidden" id="txthiddentr" name="txthidddentr" />
                <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table table-bordered" style="width: 953px; height: 0px !important; height: auto; overflow: scroll;" id="tblPOItemstModelTable">
                        <thead>
                            <tr>
                                <th style="width: 40px !important;">
                                    <input type="checkbox" class="chktd" id="checkHeader" value="false" /></th>
                                <th style="display: none">GRN Id</th>
                                <th style="display: none">GRN Detail Id</th>
                                <th style="display: none">Item Id</th>
                                <th style="width: 100px !important;">Item Code</th>
                                <th>Description</th>
                                <th style="display: none">Invoice Amount</th>
                                <th style="display: none">PO No</th>
                                <th style="display: none">PO Date</th>
                                <th style="display: none">IGP #</th>
                                <th style="display: none">PO Date</th>
                                <th style="display: none">IGP #</th>
                                <th style="display: none">IGP Date</th>
                                <th style="display: none">GRN #</th>
                                <th style="display: none">Accepted Qty</th>
                                <th style="display: none">Received Qty</th>
                                <th style="display: none">Rejected Qty</th>
                                <th style="display: none">Department</th>
                                <th>Qty</th>
                                <th style="display: none">Rate</th>
                                <th style="display: none">Value</th>
                                <th style="display: none">Total Amount</th>
                                <th style="display: none">GRN Date</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button id="btn_done" type="button" name="PoItem" class="btn btn-primry" data-dismiss="modal">Done</button>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
