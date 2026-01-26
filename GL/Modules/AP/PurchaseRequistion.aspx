<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseRequistion.aspx.cs" Inherits="PMS.AP.PurchaseRequistion" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <link href="../../wwwroot/Tibbit_theme/css/CustomCss/PR.css" rel="stylesheet" />

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        var counter = 1;
        var append_data = '';

        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            GetWareHouseCondition();

            $("#CreatedByRow").hide();
           
                $('#txtItem').tokenInput(function () {
                    if (warehouseCond == '01') {
                        var warehouseVal = $('#ddlWarehouse').val();
                        debugger;
                        if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {
                            return "";
                        }
                        return "../../json.aspx?Table=INV_ItemsForPRwithWarehouse&WarehouseID=" + encodeURIComponent(warehouseVal);
                    }
                    else {
                        return "../../json.aspx?Table=INV_ItemsForPR"
                    }
                     
                }, {
                    tokenLimit: 1,
                    hintText: "Select a warehouse first...",
                    noResultsText: "No items found.",
                    searchingText: "Searching...",

                    onAdd: function (item) {

                        $("#hditemID").val(item.id);
                        GetItemDetail();
                        $('#btnGIR').attr('disabled', true);
                        $('#btnGIR').css('pointer-events', 'none');
                        $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                        $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
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
            //var currentDate = new Date();
            //var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            //$("#txtPR_Date").val(formattedDate);
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtPR_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            //loadtokenInputsDefaultitem();
            if (id != "") {
                LoadPurchaseRequistionMaster(id);
                LoadPurchaseRequistionDetail(id);
                $("#btnsave").val('Update');
                $("#CreatedByRow").show();
            }
            setTimeout(function () {
                var status = $('#txt_Status').val();
                if (status == "Approved") {

                    UserUnApproveButtonRights();
                    $('#btnsave').attr("disabled", 'disabled');
                }
                if (status == "Cancelled") {

                    $('#btnsave').attr("disabled", 'disabled');
                    $('#btnsave').hide();
                }
                if (status == "Created") {
                }
            }, 1500);

            $('#btnGetAllItems').on('click', function () {
                LoadAllitem('');
            });
            function LoadAllitem(searchText) {
                var warehouse = $('#ddlWarehouse').val();
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
                        $.each(items, function (index, item) {
                            var row = '<tr>' +
                                '<td><input type="checkbox" class="itemCheckbox" onclick="append(this)"></td>' +
                                '<td>' + item.Item_ID + '</td>' +
                                '<td>' + item.Item_Code + '</td>' +
                                '<td>' + item.Description + '</td>' +
                                '<td>' + item.Unit + '</td>' +
                                '</tr>';
                            tableBody.append(row);
                            $('#btnGIR').attr('disabled', true);
                            $('#btnGIR').css('pointer-events', 'none');
                            $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                            $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
                        });
                        $('#itemsModal').modal('show');
                    },
                    error: function (error) {
                        console.error("Error fetching items", error);
                    }
                });
            }
            $('#searchInput').on('keyup', function () {

                var searchText = $(this).val().trim();
                LoadAllitem(searchText);


            });



            function LoadGIRNoDetail(Gir_id) {
                PageMethods.getGIRByID(Gir_id, function (data) {
                    var details = JSON.parse(data);
                    var tbody = $('#tblGIRDetails tbody');
                    tbody.empty();
                    $.each(details, function (index, detail) {
                        var row = $('<tr></tr>');
                        var checkbox = $('<td></td>').append(
                            $('<input type="checkbox" class="select_GIR_row" />').val(detail.MaterialRequestDetail_Id)
                        );
                        row.append(checkbox);
                        row.append($('<td style="display:none;"></td>').text(detail.MaterialRequestDetail_Id));
                        row.append($('<td style="display:none;"></td>').text(detail.MaterialRequest_Id));
                        row.append($('<td></td>').text(detail.Req_Num));
                        row.append($('<td style="display:none;"></td>').text(detail.Item_Id));
                        row.append($('<td></td>').text(detail.Item_Code));
                        row.append($('<td></td>').text(detail.Description));
                        row.append($('<td></td>').text(detail.Unit));
                        row.append($('<td></td>').text(detail.QTY));
                        row.append($('<td></td>').text(detail.Rate));
                        tbody.append(row);
                    });
                    $('.select_GIR_row').change(function () {
                        if (this.checked) {

                            appendGIRROW($(this).closest('tr'));

                            $('#btnGetAllItems').attr('disabled', true);
                            $('#faGetAllItems').attr('disabled', true);
                            $('#faGetAllItems').css('pointer-events', 'none');
                            $('#btnGetAllItems').css('pointer-events', 'none');
                            $('#token-input-txtItem').attr('disabled', true);
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
            var Qty = $(row).find('td:eq(8)').text();
            var Rate = $(row).find('td:eq(9)').text();
            var stock = "0";
            var exists = false;
            $('#tblbodyPackage tr').each(function () {
                var existingItemCode = $(this).find('td:eq(1)').text();
                if (existingItemCode === Item_Code) {
                    exists = true;
                    return false;
                }
            });
            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already Exists in the table.',
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
            var length = $("#tblPackage tr").length;
            length++;

            $("#tblPackage").append("<tr data-itemid='" + Item_ID + "'><td style='padding-top: 7px!important;'>" + length + "</td><td style='padding-top: 7px!important;padding-right: 3px!important;'>" + Item_Code + "</td><td style='padding-left: 8px!important;padding-top: 7px!important;'>" + Item_name + "</td><td style='text-align: center;padding-top:7px !important;'>" + stock + "</td><td style='text-align: center;'><input type='text' value='" + Qty + "' name='Qty' id='txtQty" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td><td style='text-align: center;padding-top:7px !important;'>" + unit + "</td><td style='text-align: center;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' value='" + Rate + "' onkeyup='calcutaeEstimCost(this)'/></td><td style='text-align: center;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' /></td><td style='text-align: center;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size: 9px;width: 73px!important;margin-top: 2px;' autocomplete='off'/></td><td style='text-align: center;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size: 9px;width: 167px!important;margin-top: 2px;'/></td><td style='display:none'>" + Item_ID + "</td><td><a href='#' onclick='Delete(this)'><i class='glyphicon glyphicon-trash' style='font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;'></i></a></td><td style='display:none'>" + MaterialRequestDetail_Id + "</td><td style='display:none'>" + MaterialRequest_Id + "</td><td style='display:none'>" + Req_Num + "</td></tr>");

            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
            calcutaeCost(length);
            calcutaeQty();
        }
        function UserRights() {

            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {

                    var hasRights = response.d;

                    if (hasRights) {

                        $('#btnsave').show();
                    } else {
                        $('#btnsave').hide();
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'd to retrieve user rights.',
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

        function append(anchor) {

            var row = $(anchor).closest('tr');
            var Item_ID = $(row).find('td:eq(1)').text();
            var Item_Code = $(row).find('td:eq(2)').text();
            var Item_name = $(row).find('td:eq(3)').text();
            var unit = $(row).find('td:eq(4)').text();
            var stock = "0";
            var exists = false;
            $('#tblbodyPackage tr').each(function () {
                var existingItemCode = $(this).find('td:eq(1)').text();
                if (existingItemCode === Item_Code) {
                    exists = true;
                    return false;
                }
            });
            if (exists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Item already Exists in the table.',
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
            var length = $("#tblbodyPackage tr").length;
            length++;
            $("#tblbodyPackage").append("<tr data-itemid='" + Item_ID + "'><td style='padding-top: 7px!important;'>" + length + "</td><td style='padding-top: 7px!important;padding-right: 3px!important;'>" + Item_Code + "</td><td style='padding-left: 8px!important;padding-top: 7px!important;'>" + Item_name + "</td><td style='text-align: center;padding-top:7px !important;'>" + stock + "</td><td style='text-align: center;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td><td style='text-align: center;padding-top:7px !important;'>" + unit + "</td><td style='text-align: center;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeEstimCost(this)'/></td><td style='text-align: center;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' /></td><td style='text-align: center;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size: 9px;width: 73px!important;margin-top: 2px;' autocomplete='off'/></td><td style='text-align: center;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size: 9px;width: 167px!important;margin-top: 2px;'/></td><td style='display:none'>" + Item_ID + "</td><td><a href='#' onclick='Delete(this)'><i class='glyphicon glyphicon-trash' style='font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;'></i></a></td><td style='display:none'>" + 0 + "</td><td style='display:none'>" + 0 + "</td><td style='display:none'>" + 0 + "</td></tr>");
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
        }
        function FillDepartments() {

            var optionDept = '';
            PageMethods.filldepartments(function (Tests) {

                optionDept = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionDept += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddldept').html(optionDept);
            });
        }
        function FillPriority() {

            var optionInv = '';
            PageMethods.fillpriorities(function (Tests) {

                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {

                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlPriority').html(optionInv);
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
/*        function loadtokenInputsDefaultitem()*/ {
            debugger
            $('#txtItem').tokenInput("../../json.aspx?Table=INV_ItemsForPR",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        debugger
                        try {
                            $("#hditemID").val(item.id);
                            GetItemDetail();
                            $('#btnGIR').attr('disabled', true);
                            $('#btnGIR').css('pointer-events', 'none');
                            $('#ctl00_MainContent_ddlGIR').css('pointer-events', 'none');
                            $('#ctl00_MainContent_ddlGIR').attr('disabled', true);
                        }
                        catch (err) {
                            alert(err.message);
                        }
                    }
                });
            $('#txtItem').focus();
        }
        function Delete(row) {

            $(row).closest('tr').remove();
        }
        function GetItemDetail() {
            debugger
            var itemID = $("#hditemID").val();
            var PRDate = $("#txtPR_Date").val();

            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/Getitem",
                data: JSON.stringify({
                    "ItemID": itemID,
                    "PRDate": PRDate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var find = false;

                    var parse = JSON.parse(response.d);
                    var length = $("#tblPackage tr").length;
                    if (length > 0) {
                        length = length + 1;
                    }
                    else {
                        length = 1;
                    }
                    var test_array = $('#tblPackage').find('input[name=txtItemID][value=' + itemID + ']');
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

                        if (parse[0].Active == true) {
                            $("#tblPackage").append("<tr><td style='padding-top: 7px!important;'>" + length + "</td><td style='padding-top: 7px!important;padding-right: 3px!important; */'>" + parse[0].Item_Code + "</td><td style='padding-left: 8px!important;padding-top: 7px!important;'>" + parse[0].Description + "</td><td style='text-align: center;padding-top:7px !important;'>" + parse[0].Stock + "</td><td style='text-align: center;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty();calcutaeEstimatedCost(this)'/></td><td style='text-align: center;padding-top:7px !important;'>" + parse[0].Unit + "</td><td style='text-align: center;'><input type='text' name='txtUnitPrice' id='txtUnitPrice" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeEstimCost(this)'/></td><td style='text-align: center;'><input readonly type='text' name='txtEstimCost' id='txtEstimCost" + length + "' style='font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;' /></td><td style='text-align: center;'><input type='text' name='txtrdate' id='txtrdate" + length + "' style='font-size: 9px;width: 73px!important;margin-top: 2px;' autocomplete='off'/></td><td style='text-align: center;'><input type='text' name='remarks' id='remarks" + length + "' style='font-size: 9px;width: 167px!important;margin-top: 2px;'/></td><td style='display:none'><input type='hidden' name='txtItemID' value='" + parse[0].Item_ID + "'  style='width:50px!important;text-align:right;font-size:9px;height:20px;'/>" + parse[0].Item_ID + "</td><td><a href='#' onclick='Delete(this)'><i class='glyphicon glyphicon-trash' style='font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;'></i></a></td><td style='display:none'>" + 0 + "</td><td style='display:none'>" + 0 + "</td><td style='display:none'>" + 0 + "</td></tr>")
                            var currentDate = new Date();
                            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
                            $('#txtrdate' + length).val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });
                            $('#txtItem').val('');
                            $("#txtItem").tokenInput("clear");

                            length++;
                        }
                        else {
                            swal("You have selected InActive items");
                            $("#txtItem").tokenInput("clear");
                        }
                    }
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
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
        function GetPRNum() {
            $.ajax({
                type: "post",
                url: "PurchaseRequistion.aspx/GetPR",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var id = response.d;
                    $("#txtPr_Num").val(id);
                },
                failure: function (response) {
                    alert("In failure method");
                }
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
        function SaveTest() {
            debugger
            $("#btnSave").prop("disabled", true);
            var qtyOrAmtChck = false;
            var datecheck = '';

            var PRId = 0;
            if (id == "") {
                PRId = 0;
            }
            else {
                PRId = id
            }
            var PrNum = $('#txtPr_Num').val();
            var PrDate = $('#txtPR_Date').val();
            var Pirority = $("#ddlPriority").val();
            var Warehouse = $("#ddlWarehouse").val();
            var RefNum = $('#txtRef_Num').val();
            var remarks = $('#txtRemarks').val();
            var btnValue = $("#btnsave").val();
            var totCost = $("#totCost").val() || 0;
            var dept = $('#ddldept').val();


            if (warehouseCond == "01") {
                if (Warehouse == '0') {
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
                    return false;
                }
            }
            if (Pirority == '0') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Priority',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false);
                $('#ddlPriority').select2().focus();
                $('#ddlPriority').select2('open');
                return false;
            }
            if (dept == '0') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Department',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false);
                $('#ddldept').select2().focus();
                $('#ddldept').select2('open');
                return false;
            }
            var tblLength = $("#tblPackage tr:gt(0)").length;
            if (tblLength == '0') {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Items',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#tblPackage').addClass('ErrorAlert');
                $("#btnSave").prop("disabled", false);
                return false;
            } else {
                $('#tblPackage').removeClass('ErrorAlert');
            }
            if (!$('#txtPr_Num').hasClass('ErrorAlert') && !$('#txtPR_Date').hasClass('ErrorAlert') && !$('#ddldept').hasClass('ErrorAlert') && !$('#ddlPriority').hasClass('ErrorAlert') && !$('#tblPackage').hasClass('ErrorAlert')) {
                $.each($("#tblPackage").find('tbody').find('tr'), function (index) {
                    var RequiredDate = new Date($(this).find('input[name=txtrdate]').val()).setHours(0, 0, 0, 0);
                    var rateValue = $('#txtPR_Date').val();
                    var PRDate = new Date(rateValue).setHours(0, 0, 0, 0);
                    var RDate = $(this).find('input[name=txtrdate]').val();
                    var Qty = $(this).find('td:eq(4) input').val();
                    var unitprice = $(this).find('td:eq(6) input').val();
                    var estimatecost = $(this).find('td:eq(7) input').val();
                    if (PRDate > RequiredDate) {
                        datecheck = false;
                    }
                    else {
                        datecheck = true;
                    }
                    if (RDate == "") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Required Date',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        $("#btnSave").prop("disabled", false);
                        qtyOrAmtChck = true;
                        return false;

                    }
                    if (Qty == "" || Qty == 0 || Qty < 0) {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Enter Qty Or Qty Must be Greater than zero',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        qtyOrAmtChck = true;
                        $("#btnSave").prop("disabled", false);
                        return false;
                    }
                    //if (unitprice == "" || unitprice == 0 || unitprice < 0) {
                    //    Swal.fire({
                    //        icon: 'error',
                    //        title: 'Error!',
                    //        text: 'Please Enter UnitPrice Or UnitPrice Must be Greater than zero',
                    //        showConfirmButton: false,
                    //        timer: 2000,
                    //        customClass: {
                    //            popup: 'swal-big-popup',
                    //            title: 'swal-big-title',
                    //            htmlContainer: 'swal-big-text'
                    //        }
                    //    });

                    //    $("#btnSave").prop("disabled", false);
                    //    qtyOrAmtChck = true;
                    //    return false;
                    //}


                    //if (estimatecost == "" || estimatecost == 0 || estimatecost < 0) {
                    //    Swal.fire({
                    //        icon: 'error',
                    //        title: 'Error!',
                    //        text: 'Please Enter EstimateCost Or EstimateCost Must be Greater than zero',
                    //        showConfirmButton: false,
                    //        timer: 2000,
                    //        customClass: {
                    //            popup: 'swal-big-popup',
                    //            title: 'swal-big-title',
                    //            htmlContainer: 'swal-big-text'
                    //        }
                    //    });

                    //    $("#btnSave").prop("disabled", false);
                    //    qtyOrAmtChck = true;
                    //    return false;
                    //}
                });
                var totalamt = parseFloat(totCost);
                if (totalamt > 50000 && Pirority === '004') {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'For Low Priority Total Amount Must be Less then 50000',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $("#btnSave").prop("disabled", false);
                    return false;
                }
                if (datecheck == false) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Required Date must be greater than Purchase Date',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $("#btnSave").prop("disabled", false);
                    return false;
                }
                else if (qtyOrAmtChck == true) {
                    $("#btnSave").prop("disabled", false);
                    return false;
                }
                else {
                    $.ajax({
                        type: "post",
                        url: "PurchaseRequistion.aspx/SavePurchaseRequistion",
                        data: JSON.stringify({
                            "PRid": PRId,
                            "PrNum": PrNum,
                            "PrDate": PrDate,
                            "Pirority": Pirority,
                            "Warehouse": Warehouse,
                            "dept": dept,
                            "RefNum": RefNum,
                            "remarks": remarks,
                            "btnValue": btnValue
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var res = response.d;
                            var arr = res.split('-');
                            var msg = arr[0];
                            var id = arr[1];
                            sendFile(id);
                            SaveDetailPurchaseRequestion(id);
                        },
                        failure: function (response) {
                            alert("In failure method");
                        }
                    });
                }
            }
        }

        function SaveDetailPurchaseRequestion(id) {
            debugger;
            var detailAry = [];
            var btnValue = $("#btnsave").val();
            $.each($("#tblPackage").find('tbody').find('tr'), function (index, row) {
                var Qty = $(row).find('td:eq(4) input').val();
                var UnitPrice = $(row).find('td:eq(6) input').val();
                var EstimateCost = $(row).find('td:eq(7) input').val();
                var RDate = $(row).find('input[name=txtrdate]').val();
                var Remarks = $(row).find('td:eq(9) input').val();
                var itemId = $(row).find('td:eq(10)').text();
                var MaterialRequestDetail_Id = $(row).find('td:eq(12)').text();
                var MaterialRequest_Id = $(row).find('td:eq(13)').text();
                var Req_Num = $(row).find('td:eq(14)').text();

                if (Qty &&  RDate && itemId) {
                    var details = {
                        Qty: Qty,
                        UnitPrice: UnitPrice,
                        EstimateCost: EstimateCost,
                        RDate: RDate,
                        Remarks: Remarks,
                        PRId: id,
                        itemId: itemId,
                        MaterialRequestDetail_Id: MaterialRequestDetail_Id,
                        MaterialRequest_Id: MaterialRequest_Id,
                        Req_Num: Req_Num
                    };
                    detailAry.push(details);
                }
            });
            if (detailAry.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'No Valid Rows to Save.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $("#btnSave").prop("disabled", false);
                return false;
            }
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/SavePurchaseRequistionDetails",
                data: JSON.stringify({
                    "PRid": id,
                    "btnValue": btnValue,
                    'PurchaseRequistionDetails': detailAry
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var res = response.d;
                    if (res.startsWith("Success")) {
                        var arr = res.split('-')[1];
                        if (btnValue == "Save") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Inserted Successfully',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                        } else {
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
                        window.location = 'PurchaseRequistion.aspx?ID=' + id;
                        $("#btnsave").prop("disabled", true);
                    } else {
                        alert("Error In Purchase Requisition details: " + res);
                    }
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function LoadPurchaseRequistionMaster(id) {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/LoadPurchaseRequistion",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    $('#txtPr_Num').val(parse.PR_Num);
                    $('#txt_Status').val(parse.Status);
                    $('#txtRef_Num').val(parse.Ref_Num);
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse.PR_Date.substring(6, 19))))
                    $('#txtPR_Date').val(datetime);
                    $('#txtCreatedBy').val(parse.Created_By);
                    $('#txtUpatedBy').val(parse.UpdatedBy);

                    var Createdtime = moment(parseInt(parse.Creation_Date.substring(6, 19))).format('DD-MMM-YYYY h:mm A');

                    $('#txtCreatedTime').val(Createdtime);

                    if (parse.Update_Date == null || parse.Update_Date == undefined) {

                        $('#txtUpatedTime').val('');
                    }
                    else {
                        var Updatedtime = moment(parseInt(parse.Update_Date.substring(6, 19))).format('DD-MMM-YYYY h:mm A');
                        $('#txtUpatedTime').val(Updatedtime);
                    }

                    setTimeout(function () {
                        $('#ddlPriority').val(parse.Priority).trigger('change');
                        $('#ddldept').val(parse.Department).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlWarehouse').val(parse.Warehouse).trigger('change');
                    }, 1500);

                    
                    $('#txtRemarks').val(parse.Remarks);
                    debugger;
                    if (parse.GIRCreatedBy && parse.GIRCreatedBy.trim() !== "") {
                        $('#txtGirCreatedBy').val(parse.GIRCreatedBy).show();
                        $('#lblGirCreatedBy').show();
                    } else {
                        $('#txtGirCreatedBy').hide();
                        $('#lblGirCreatedBy').hide();
                    }

                    if (parse.GIRApprovedBy && parse.GIRApprovedBy.trim() !== "") {
                        $('#txtGirApprovedBy').val(parse.GIRApprovedBy).show();
                        $('#lblGirApprovedBy').show();
                    } else {
                        $('#txtGirApprovedBy').hide();
                        $('#lblGirApprovedBy').hide();
                    }

                    if (parse.GIRNum && parse.GIRNum !== 0) {
                        $('#txtGIRNum').val(parse.GIRNum).show();
                        $('#lblGIRNum').show();
                    } else {
                        $('#txtGIRNum').hide();
                        $('#lblGIRNum').hide();
                    }
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function removeDuplicates() {
            var seen = {};
            $('#tblPackage tr').each(function () {
                var item_id = $("td:nth-child(11)", $(this)).text();
                if (seen[item_id]) alert('duplicate');
                else {
                    seen[item_id] = true;
                }
            });
        }
        function LoadPurchaseRequistionDetail(id) {
            var counter = 1;
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/LoadPurchaseRequistionDetail",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var row = '';
                    $.each(parse, function (key, value) {
                        var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse[key].RDate.substring(6, 19))));
                        var len = key + 1;
                        var uom = parse[key].UOM;
                        if (uom == null || uom == 'NULL' || uom == 'null') {
                            uom = "";
                        }
                        row += '<tr><td style="padding-top: 7px!important;">' + len + '</td><td style="padding-top: 7px!important;padding-right: 3px!important; */">' + parse[key].itemCode + '</td><td style="padding-left: 8px!important;padding-top: 7px!important;">' + parse[key].Description + '</td><td style="text-align: center; padding-top: 7px!important;">' + parse[key].stock + '</td><td style="text-align: center;"><input type="text"  value="' + parseFloat(parse[key].Qty).toFixed(2) + '" name="Qty" id="txtQty' + counter + '" style="font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;" autocomplete="off" onkeyup="calcutaeQty();calcutaeEstimatedCost(this)"/></td><td style="text-align: center; padding-top: 7px!important;">' + uom + '</td><td style="text-align: center;"><input type="text"  value="' + parseFloat(parse[key].UnitPrice).toFixed(2) + '" name="txtUnitPrice" id="txtUnitPrice' + counter + '" style="font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;" autocomplete="off" onkeyup="calcutaeEstimCost(this)"/></td><td style="text-align: center;"><input readonly type="text"  value="' + parseFloat(parse[key].EstimateCost).toFixed(2) + '" name="txtEstimCost" id="txtEstimCost' + counter + '" style="font-size: 9px;width: 58px!important;text-align: right;margin-top: 2px;" autocomplete="off"/></td><td style="text-align: center;"><input type=text  name="txtrdate" id="txtrdate' + counter + '" style="font-size: 9px; width: 73px!important;margin-top: 2px;" value="' + datetime + '"/></td><td style="text-align: center;"><input type=text  name="remarks" id="remarks' + counter + '" style="font-size: 9px; width: 167px!important;margin-top: 2px;" value="' + parse[key].Remarks + '"/></td><td style="display:none">' + parse[key].itemId + '</td><td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td><td style="display:none">' + parse[key].MaterialRequestDetail_Id + '</td><td style="display:none">' + parse[key].MaterialRequest_Id + '</td><td style="display:none">' + parse[key].Req_Num + '</td></tr>';
                        $('#txtrdate' + counter).datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                        counter++;
                    });
                    $("#tblPackage").append(row);
                    $('input[name="txtrdate"]').datepicker({ dateFormat: 'dd M yy' }).attr('readonly', 'readonly');
                    calcutaeQty();
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function calcutaeQty() {
            var TotalQty = parseInt(0);
            var Qty = 0;
            var sum = 0;
            var totEstcost = parseInt(0);
            var unitPr = 0;
            var totalEsitamt = 0;
            var tot = 0;
            $.each($('#tblPackage tbody tr'), function (key, value) {
                Qty = $($(value).find('td input[name=Qty]')[0]).val() || 0;
                unitPr = $($(value).find('td input[name=txtUnitPrice]')[0]).val() || 0;
                totEstcost = parseFloat(Qty * unitPr);

                TotalQty += parseFloat(Qty);
                totalEsitamt += parseFloat(totEstcost);
            });
            sum = parseFloat(TotalQty).toFixed(2);
            tot = parseFloat(totalEsitamt).toFixed(2);
            $('#totQty').val(sum);
            $('#totCost').val(tot);
        }
        function calcutaeEstimCost(input) {
            var selectId = $(input).attr('id');
            var idParts = selectId.match(/([a-zA-Z]+)(\d+)/);
            var totcost = parseInt(0);
            var cost = 0;
            var totalamt = 0;
            if (idParts && idParts.length === 3) {
                var prefix = idParts[1];
                var counter = idParts[2];
                var Qty = parseFloat($('#txtQty' + counter).val()) || 0;
                var unitprice = parseFloat($(input).val()) || 0;
                var totalQty = (Qty * unitprice).toFixed(2);
                $('#txtEstimCost' + counter).val(totalQty);
                $.each($('#tblPackage tbody tr'), function (key, value) {
                    cost = $($(value).find('td input[name=txtEstimCost]')[0]).val() || 0;
                    totcost += parseFloat(cost);
                });
                totalamt = parseFloat(totcost).toFixed(2);
                $('#totCost').val(totalamt);
            } else {
                console.error('Invalid id format at UnitPrice: ' + selectId);
            }
        }
        function calcutaeEstimatedCost(input) {
            var selectId = $(input).attr('id');
            var idParts = selectId.match(/([a-zA-Z]+)(\d+)/);
            if (idParts && idParts.length === 3) {
                var prefix = idParts[1];
                var counter = idParts[2];
                var Qty = parseFloat($(input).val()) || 0;
                var unitprice = parseFloat($('#txtUnitPrice' + counter).val()) || 0;
                var totalQty = (Qty * unitprice).toFixed(2);
                $('#txtEstimCost' + counter).val(totalQty);
            } else {
                console.error('Invalid id format at QTY: ' + selectId);
            }
        }
        function calcutaeCost(rowIndex) {
            var Qty = parseFloat($('#txtQty' + rowIndex).val()) || 0;
            var unitprice = parseFloat($('#txtUnitPrice' + rowIndex).val()) || 0;
            var totalQty = (Qty * unitprice).toFixed(2);
            $('#txtEstimCost' + rowIndex).val(totalQty);
        }
        function PrintPurchaseRequisitionDetail() {

            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition&PRid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition&PRid=' + id;
            }
            window.open(url, '_blank');
        }
        function sendFile(ID) {

            var fileInput = $('#chosePrfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#chosePrfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadPRFiles.ashx',
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

        function UserUnApproveButtonRights() {
            $.ajax({
                type: "POST",
                url: "PurchaseRequistion.aspx/UserUnApproveEntryRights",
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
                        text: 'Failed to retrieve User UnApprove Button Rights',
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

    </script>
    <form id="item">
        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-12 col-xs-12">
                <label id="LblPr_Num">PR #</label>
                <input type="text" class="form-control" id="txtPr_Num" name="txtPr_Num" placeholder="PR #" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12 col-xs-12">
                <label id="LblPR_Date">PR Date</label>
                <input type="text" class="form-control"  id="txtPR_Date" name="txtPR_Date" autocomplete="off" />
            </div>
            <div class="col-lg-4 col-md-6 col-sm-12 col-xs-12">
                <label id="LblPriority">Priority <span style="color: red">*</span></label>
                <select id="ddlPriority" class="form-select">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-4 col-md-6 col-sm-12 col-xs-12">
                <label id="Lbldepartment">Department <span style="color: red">*</span></label>
                <select id="ddldept" class="form-select"></select>
            </div>

        </div>
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12 col-xs-12">
                <label id="item">Item</label>
                <input style="" type="text" class="form-control" id="txtItem" name="txtItem" placeholder="item" />
            </div>
            <div class="col-lg-1 col-md-6 col-sm-12 col-xs-12">
                <span class="btn-item" id="btnGetAllItems"><i id="faGetAllItems" class="fa fa-check-square btn-gray btntop">Items</i></span>
            </div>
            <div id="warehouse" class="col-lg-2 col-md-6 col-sm-12 col-xs-12">
                <label id="LblWarehouse">WareHouse<span style="color: red">*</span></label>
                <select id="ddlWarehouse" class="form-select">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12 col-xs-12">
                <label id="lblGIR">GIR</label>
                <asp:DropDownList runat="server" ID="ddlGIR" class="form-select"></asp:DropDownList>
            </div>
            
            <div class="col-lg-1 col-md-6 col-sm-12 col-xs-12">
                <span class="btn-item" id="btnGIR"><i id="fabtnGIR" class="fa fa-plus btn-gray btntop">GIR</i></span>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12 col-xs-12">
                <label id="LblRef_Num">Ref #</label>
                <input type="text" class="form-control" id="txtRef_Num" name="txtRef_Num" placeholder="Ref #" autocomplete="off" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-12 col-xs-12">
                <label id="lbl_Status">Status</label>
                <input type="text" class="form-control" id="txt_Status" name="txt_Status" readonly="readonly" />
            </div>
            <div class="col-lg-6 col-md-8 col-sm-12">
                <label id="lblrem">Remarks</label>
                <input id="txtRemarks" type="text" class="form-control" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label class="col-form-label">Attachment</label>
                <input type="file" id="chosePrfile" name="chosePrfile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
            </div>
        </div>
        <div class="row" id="CreatedByRow">
            <div class="col-lg-2 col-md-3 col-sm-3">
                <label id="lblCreatedBy">Created By</label>
                <input id="txtCreatedBy" type="text" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-3">
                <label id="lblCreatedTime">Created Date</label>
                <input id="txtCreatedTime" type="text" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-3">
                <label id="lblUpatedBy">Updated By</label>
                <input id="txtUpatedBy" type="text" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-3 col-sm-3">
                <label id="lblUpatedTime">Updated Date</label>
                <input id="txtUpatedTime" type="text" class="form-control" readonly="readonly" />
            </div>
        </div>
        <div class="row">
            <div class="col-lg-2 col-md-3 col-sm-4">
                <input type="hidden" id="hditemID" />
            </div>
        </div>
    </form>
    <div class="row">
        <div class="col-lg-4 col-md-4 col-sm-4">
            <label style="display: none;" id="lblGIRNum">GIR #</label>
            <input id="txtGIRNum" readonly="readonly" type="text" class="form-control" style="display: none" />
        </div>
        <div class="col-lg-4 col-md-4 col-sm-4">
            <label style="display: none;" id="lblGirCreatedBy">GIR Created By</label>
            <input id="txtGirCreatedBy" readonly="readonly" type="text" class="form-control" style="display: none" />
        </div>
        <div class="col-lg-4 col-md-4 col-sm-4">
            <label style="display: none;" id="lblGirApprovedBy">GIR Approved By</label>
            <input id="txtGirApprovedBy" readonly="readonly" type="text" class="form-control" style="display: none" />
        </div>
    </div>

    <div id="ITEMTable" style="overflow: scroll; height: 276px !important; margin-bottom: 13px !important;">
        <table class="table table-bordered table-striped" id="tblPackage" style="margin-top: 13px; font-size: 10px !important; width: 100%; overflow: scroll">
            <tr>
                <th style="width: 7%; text-align: center;">Sr No.</th>
                <th style="width: 7%; text-align: center; font-size: 10px;">Item Code</th>
                <th style="width: 20%; text-align: center;">Description</th>
                <th style="width: 10%; text-align: center;">Stock</th>
                <th style="width: 5%; text-align: center;">Qty</th>
                <th style="width: 5%; text-align: center;">MOU</th>
                <th style="width: 10%; text-align: center;">Unit Price</th>
                <th style="width: 10%; text-align: center;">Estimated Cost</th>
                <th style="width: 10%; text-align: center;">Required Date</th>
                <th style="width: 10%; text-align: center;">Remarks</th>
                <th style="width: 6%; text-align: center;">Action</th>
                <th style="width: 0%; display: none">MaterialRequestDetail Id</th>
                <th style="width: 0%; display: none">MaterialRequest Id</th>
                <th style="width: 0%; display: none">Req Num</th>
            </tr>
            <tbody id="tblbodyPackage"></tbody>
        </table>
    </div>

    <div class="row">
        <div class="col-lg-8 col-md-4"></div>
        <div class="col-lg-2 col-md-4 col-sm-6">

            <label>Total Qty</label>
            <input type="text" id="totQty" name="totQty" readonly="readonly" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label>Total</label>
            <input type="text" id="totCost" name="totCost" readonly="readonly" />
        </div>
    </div>






    <div class="col-lg-8">
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-primry" value="Save" id="btnsave" onclick="SaveTest()" />
        </div>

        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-gray" value="List" onclick="window.location = 'PurchaseRequistionView.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn btn-yellow"  value="New" onclick="window.location = 'PurchaseRequistion.aspx'" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" value="Print"  class="btn-primry" id="btn_Print" onclick="PrintPurchaseRequisitionDetail();" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-12">
            <input type="button" class="btn-primry" value="Unnaprove" style="display: none" id="btnUnApprove" onclick="UnApprovePR()" />
        </div>
    </div>




    <div class="modal fade" id="itemsModal" tabindex="-1" aria-labelledby="itemsModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-md">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title" id="itemsModalLabel">Item Details</h3>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="margin-top: -11px !important">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <input type="text" id="searchInput" class="form-control search-input" placeholder="Search items..." />
                    <table class="table table-bordered table-striped table-responsive-md table-responsive-lg">
                        <thead>
                            <tr>
                                <th>Select</th>
                                <th>Item ID</th>
                                <th>Item Code</th>
                                <th>Description</th>
                                <th>Unit</th>
                            </tr>
                        </thead>
                        <tbody id="itemsTableBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <div class="col-lg-10 col-md-10 col-sm-10"> </div>
                        <div class="col-lg-2 col-md-2 col-sm-2 float-end">
                            <input type="button" value="Close" class="btn-gray" data-dismiss="modal" />
                        </div>                   
                </div>
            </div>
        </div>
    </div>

    <div id="GIRModal" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog custom-modal-width" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title">GIR Items Details</h3>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close" style="margin-top: -11px !important">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <table class="table table-bordered table-responsive-lg table-responsive-md" id="tblGIRDetails">
                        <thead>
                            <tr>
                                <th>Select</th>
                                <th style="display: none">MaterialRequestDetail Id</th>
                                <th style="display: none">MaterialRequest Id</th>
                                <th>Request Num</th>
                                <th style="display: none">Item Id</th>
                                <th>Item Code</th>
                                <th>Description</th>
                                <th>Unit</th>
                                <th>QTY</th>
                                <th>Last Purchase Rate</th>
                            </tr>
                        </thead>
                        <tbody id="GIRItemTableBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <div class="col-lg-10 col-md-10 col-sm-10"></div>
                        <div class="col-lg-2 col-md-2 col-sm-2 float-end">
                            <input type="button" value="Close" class="btn btn-primry" data-dismiss="modal" />
                        </div>                   
                </div>
            </div>
        </div>
        </div>
</asp:Content>
