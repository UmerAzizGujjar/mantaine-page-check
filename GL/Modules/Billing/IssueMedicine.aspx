<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IssueMedicine.aspx.cs" Inherits="PMS.IssueMedicine" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Pharmacy.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.2/underscore-min.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {          
            if (!$('#chkbatch').prop("checked")) {
                $('#chkbatch').prop("checked", true);
            }
            BalanceAmountCondition();
            CheckSaleReturnAllow();
            $('#chkbatch').on('change', function () {
                var btch = $('#chkbatch').prop("checked");
                if (btch == false) {
                    $('.batchdiv').hide();
                }
                else {
                    $('.batchdiv').show();
                }
                loadmed();
            });
            $(document).on('click', '.btnEdit', function (e) {
                e.preventDefault();

                var patId = $(this).data('patid');
                var mrNo = $(this).data('mrno');

                hideModel(patId, mrNo);
            });
            loadmed();
            LoadWarehouses();
            LoadWarehousesforSaleReturn();
            
             LoadPatientNo();

        });
        window.addEventListener('keydown', function (event) {
            if (event.altKey && event.code === 'KeyS') {
                debugger;
                event.preventDefault();
                $('#medName').select2('close');
                $('#btnSave').attr('style', 'background: green !important;margin-top: -5px;').focus();
                //SearchPop();
                GetPharmacyUser();
               
                $('#txtuserCode').focus();
            }
            else if (event.altKey && event.code === 'KeyR') {
                event.preventDefault();
                $('#medName').select2('close');
                $('#txtAmountReceived').focus().select();
                $('#btnSave').attr('style', 'margin-top: -5px;').focusout();
                $('#CloseSearchModel').click();
            }
            else if (event.altKey && event.code === 'KeyE') {
                event.preventDefault();
                $('#medName').select2('close');
                $('#btnSave').attr('style', 'margin-top: -5px;').focusout();
                $('#CloseSearchModel').click();
            }
            else if (event.altKey && event.code === 'KeyD') {
                event.preventDefault();
                $('#medName').select2('close');
                $('#txtDisPer').focus().select();
                $('#btnSave').attr('style', 'margin-top: -5px;').focusout();
                $('#CloseSearchModel').click();
            }
            else if (event.altKey && event.code === 'KeyQ') {
                event.preventDefault();
                $('#medName').select2('open');
                $('#btnSave').attr('style', 'margin-top: -5px;').focusout();
                $('#CloseSearchModel').click();
            }
            else if (event.altKey && event.code === 'KeyA') {
                event.preventDefault();
                $('#medName').select2('close');
                $('#txtFlatDisc').focus().select();
                $('#btnSave').attr('style', 'margin-top: -5px;').focusout();
                $('#CloseSearchModel').click();
            }
            else {
                $('#btnSave').attr('style', 'margin-top: -5px;')
            }
        });

        $(document).keydown(function (e) {
            switch (e.which) {
                case 40:
                    var checkTable = $(e.target).parent().parent().parent().closest('table').attr('id');
                    if (checkTable == "tblDetails") {
                        e.preventDefault();
                        setTimeout(function () {
                            $(e.target).parent().parent().next().children().eq($(e.target).parent().index()).find('input[name=txtQty]').focus().select();
                        }, 5);

                        setTimeout(function () {
                            $(e.target).parent().parent().next().children().eq($(e.target).parent().index()).find('input[name=DisPer]').focus().select();
                        }, 5);
                    }
                    break;
                case 38:
                    var checkTable = $(e.target).parent().parent().parent().closest('table').attr('id');
                    if (checkTable == "tblDetails") {
                        e.preventDefault();
                        setTimeout(function () {
                            $(e.target).parent().parent().prev().children().eq($(e.target).parent().index()).find('input[name=txtQty]').focus().select();
                        }, 5);
                        setTimeout(function () {
                            $(e.target).parent().parent().prev().children().eq($(e.target).parent().index()).find('input[name=DisPer]').focus().select();
                        }, 5);
                    }
                    break;
                case 13:
                    var checkTable = $(e.target).parent().parent().parent().closest('table').attr('id');
                    if (checkTable == "tblDetails") {
                        var attr_name = $(e.target).attr('name');
                        if (attr_name == 'txtQty') {
                            $('#medName').select2('open');
                        }
                    }
                    break;
                default:
                    return;
            }


            $("#CloseSearchReturnModel").on('click', function (e) {
                $('#btnSave').attr('style', 'margin-top: -5px;')
                $('#txtReturnuserCode').val('');
                $('#txtReturnpass').val('');
                $('#lblReturnUsername').text('');
                //  $('#SaleReturnModal').hide();

            });
            $("#txtReturnuserCode").on('change', function (e) {
                debugger;
                var userCode = $('#txtReturnuserCode').val();
                var Nusername;
                breakout = false;
                $(arr).filter(function (i, n) {
                    debugger;
                    if (userCode == n.User_Code) {
                        $('#lblReturnUsername').text(n.Username).css("color", "black");
                        breakout = true;
                        Nusername = n.Username;
                        return false;
                    }


                });
                if (breakout == true) {
                    $('#lblReturnUsername').text(Nusername).css("color", "black");
                }
                else {
                    $('#lblReturnUsername').text("invalid User").css("color", "red");
                }

            });
        });
        debugger;
        $(function () {
            debugger;
            items = []
            loadmed();
            loadDepartment();
            loadDoctors();
            debugger;
            pageSize = 50
            jQuery.fn.select2.amd.require(["select2/data/array", "select2/utils"],

                function (ArrayData, Utils) {
                    function CustomData($element, options) {
                        debugger;
                        CustomData.__super__.constructor.call(this, $element, options);
                    }
                    Utils.Extend(CustomData, ArrayData);
                    CustomData.prototype.query = function (params, callback) {
                        results = [];
                        if (params.term && params.term !== '') {
                            results = _.filter(items, function (e) {
                                return e.text.toUpperCase().indexOf(params.term.toUpperCase()) >= 0;
                            });
                        } else {
                            results = items;
                        }
                        if (!("page" in params)) {
                            params.page = 1;
                        }
                        var data = {};
                        data.results = results.slice((params.page - 1) * pageSize, params.page * pageSize);
                        data.pagination = {};
                        data.pagination.more = params.page * pageSize < results.length;
                        callback(data);
                    };
                    $(document).ready(function () {
                        debugger;
                        $("#medName").select2({
                            ajax: {},
                            dataAdapter: CustomData,

                        });
                    });
                })
        });
        var ItemNames;
        var arr = [];
        function GetAllCashierUsers() {
            PageMethods.GetAllCashierUsers(function (data) {
                var Parsed = JSON.parse(data);
                $.each(Parsed, function (key, value) {
                    arr.push
                        ({
                            User_Code: value.User_Code,
                            Username: value.UserName,
                        });
                });
            });
        }
        debugger
        function loadDoctors() {
     
            PageMethods.loadDoctors(function (data) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                 
                    options += '<option value="' + value.Emp_ID + '" >' + value.name + '</option>';
                });
                $('#ddlDoctor').html(options);
                $('#ddlDoctor').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        debugger
        function loadDepartment() {
            
            PageMethods.GetDepartment(function (data) {
                var options = '<option value="0" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                  
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlDepartment').html(options);
                $('#ddlDepartment').select2();
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        var ItemName;
        var breakout = false;
        $(document).ready(function () {
            GetAllCashierUsers();
            $("#CloseSearchModel").on('click', function (e) {
                $('#btnSave').attr('style', 'margin-top: -5px;')
                $('#txtuserCode').val('');
                $('#txtpass').val('');
                $('#lblUsername').text('');
            });
            $("#txtuserCode").on('change', function (e) {
                debugger;
                var userCode = $('#txtuserCode').val();
                var Nusername;
                breakout = false;
                $(arr).filter(function (i, n) {
                    debugger;
                    if (userCode == n.User_Code) {
                        $('#lblUsername').text(n.Username).css("color", "black");
                        breakout = true;
                        Nusername = n.Username;
                        return false;
                    }
                });
                if (breakout == true) {
                    $('#lblUsername').text(Nusername).css("color", "black");
                }
                else {
                    $('#lblUsername').text("invalid User").css("color", "red");
                }
            });
            $("#chkprint").prop("checked", true);
            $("#chkbatch").prop("checked", true);
            debugger;
            var btch = $('#chkbatch').prop("checked");
            if (btch == false) {
                $('.batchdiv').hide();
            }
            else {
                $('.batchdiv').show();
            }
            $('#CustomerName').focus();
            $("#chkprint").prop("checked", true);
            $('#row22').hide();
            LoadTokenInputsDefaultMRNo();
            $("#chkprint").on('change', function (e) {
                debugger;
                var checkPrint = $('#chkprint').is(":checked");
                if (checkPrint == false) {
                    $('#btnSave').val("Save").css("width", "8.333%");
                } else {
                    $('#btnSave').val("Save & Print").css("width", "");
                }
            });
            $("#medName").on('change', function (e) {
                debugger;
                setTimeout(function () {
                    $('input[name="txtQty"]').focus().select();
                }, 5);
            });
            $('input[name="rbtn"]').on('change', function (e) {
                debugger;
                var chkbtn = $('input[name="rbtn"]:checked').val();
                if (chkbtn == 'rbtnHospital') {
                    $('#txtDisPer').attr("disabled", true);
                    $('#txtDisAmt').attr("disabled", true);
                    $('#txtFlatDisc').attr("disabled", true);
                    $('#txtAmountReceived').attr("disabled", true);
                }
                else {
                    $('#txtDisPer').attr("disabled", false);
                    $('#txtDisAmt').attr("disabled", false);
                    $('#txtFlatDisc').attr("disabled", false);
                    $('#txtAmountReceived').attr("disabled", false);
                }
            });
            $('#SearchModel').on('keypress', function (event) {
                debugger;
                var keycode = (event.keyCode ? event.keyCode : event.which);
                if (keycode == '13') {
                    $('#SaveVal').focus().click();
                    $('#txtpass').focus().select();
                }
            });
            $(document).on('keydown', '.select2-search__field', function (event) {
                if (event.keyCode === 13) {
                    $('#medname').select2('close');
                }
            });
            $(document).on('keyup', '.select2-search__field', function () {
                ItemNames = $(this).val();
                loadmed();
            });
            $('.select2').select2();

            // Open the modal for Sale Return
            $('#btnSaleReturn').click(function () {
                debugger
                $('#SaleReturnModal').modal('show');
                loadInvoiceNumbers();
                loadSaleReturnItems();
            });

            // Function to load Sale Return Invoice Number into the dropdown

            $('#SaleReturnModal').on('hide.bs.modal', function () {
                $(this).find('input[type="text"]').val('');
                $(this).find('select').val(null).trigger('change');
                $('#saleReturnTableBody').empty();
            });

        });
        // Function to load Sale Return Inovice Items Data
        function loadInvoiceNumbers() {
            var optionInv = '';
            PageMethods.AllInvoiceNumbers(function (Tests) {
                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionInv += '<option value="' + value.Bill_ID + '" >' + value.Seq_InvoiceNo + '</option>';
                });
                $('#ddlInvoiceNumber').html(optionInv);
            });
        }
        // Function to load Sale Return Items into the dropdown
        function loadSaleReturnItems() {
            var optionInv = '';
            PageMethods.SaleReturnItems(function (Tests) {
                optionInv = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionInv += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                });
                $('#ddlSaleReturnItems').html(optionInv);
                $('#ddlSaleReturnItems').select2();
            });
        }
        function AddSaleReturnInvoiceMaster() {
            debugger
            var invNo = $('#ddlInvoiceNumber').val();
            if (invNo) {
                $.ajax({
                    type: "post",
                    url: "IssueMedicine.aspx/SaleReturnInvoiceMaster",
                    data: JSON.stringify({ "invNo": invNo }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        debugger
                        var data = JSON.parse(msg.d);
                        $('#txtSaleReturnTotalPayable').val(data[0].Total_Amount);
                        $('#txtSaleReturnDisPer').val(data[0].Discount_Percentage);
                        $('#txtSaleReturnDisAmt').val(data[0].Discount_Amount);
                        $('#txtSaleReturnLineDisc').val(data[0].Line_Wise_Discount);
                        $('#txtSaleReturnFlatDisc').val(0);
                        $('#txtSaleReturnTotal').val(data[0].Received_Amount);
                        $('#ddlSaleReturnItems').val(0);
                        $('#ddlSaleReturnItems').prop('disabled', true);
                        AddSaleReturnInvoiceDetails(invNo);
                    },
                });
            }

        }
        function RefreshSaleReturnModal() {
            debugger;
            $('#ddlInvoiceNumber').prop('disabled', false);
            $('#ddlpat_no').prop('disabled', false);
            $('#ddlSaleReturnItems').prop('disabled', false);
            $('#txtSaleReturnTotalPayable').val('');
            $('#txtSaleReturnLineDisc').val('');
            $('#txtSaleReturnDisPer').val('');
            $('#txtSaleReturnDisAmt').val('');
            $('#txtSaleReturnFlatDisc').val('');
            $('#txtSaleReturnTotal').val('');
            $('#saleReturnTableBody').empty();
            $('#ddlInvoiceNumber').val(0).trigger('change');
            $('#ddlSaleReturnItems').val(0).trigger('change');

        }
        function CalculateSaleReturnAdj() {
            debugger;
            var total = parseFloat($('#txtSaleReturnTotalPayable').val()) || 0;
            var disamt = parseFloat($('#txtSaleReturnDisAmt').val()) || 0;
            var linedisamt = parseFloat($('#txtSaleReturnLineDisc').val()) || 0;
            var adjustamt = parseFloat($('#txtSaleReturnFlatDisc').val()) || 0;
            var net = total - disamt - linedisamt - adjustamt;
            if (net < 0) {
                net = 0;
            }
            $('#txtSaleReturnTotal').val(net.toFixed());
            debugger;
        }

        function AddSaleReturnInvoiceDetails(invNo) {
            debugger
            var BillId = invNo;
            if (BillId) {
                $('#saleReturnTableBody').empty();
                $.ajax({
                    type: "post",
                    url: "IssueMedicine.aspx/SaleReturnInvoiceDetail",
                    data: JSON.stringify({ "BillId": BillId }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        var data = JSON.parse(msg.d);
                        data.forEach(function (item, index) {
                            var rowIndex = index + 1;
                            var row = '<tr>' +
                                '<td>' + rowIndex + '</td>' +
                                '<td style="display:none"><input type="text" value="' + item.Bill_Details_ID + '" name="txtRBill_Details_ID" id="txtRBill_Details_ID"></td>' +
                                '<td><input type="hidden" value="' + item.Description + '" name="txtRItemDescription" id="txtRItemDescription">' + item.Description + '</td>' +
                                '<td style="display:none"><input type="text" name="txtRCheckQty" id="txtRCheckQty"  value="' + item.Qty + '" style="width: 100% !important; height: 22px; text-align: right;" ></td>' +
                                '<td><input type="text" name="txtRQty" value="' + item.Qty + '"  style="width: 100% !important; height: 22px; text-align: right;" autocomplete="off"></td>' +
                                '<td><input type="text" name="txtRStock" value="' + item.Total_Stock + '" style="width: 100% !important; height: 22px; text-align: center;" readonly></td>' +
                                '<td><input type="text" name="txtRSalerate" value="' + item.Amount + '" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td><input type="text" name="txtRDisPer" value="' + item.Discount_Percentage + '" style="width: 100% !important; height: 22px; text-align: right;" readonly autocomplete="off"></td>' +
                                '<td><input type="text" name="txtRDisAmount" value="' + item.Discount_Amount + '" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td><input type="text" name="txtRnet" value="' + item.Net_Amount + '" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td ><input type="text" name="txtRBatch_No" value="' + item.Batch_No + '" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td style="display: none"><input type="hidden" value="' + item.Item_ID + '" name="txtRItemID" id="txtRItemID"></td>' +
                                '<td style="display: none"><input type="hidden" value="' + item.CGSRate + '" name="txtRCGSRate" id="txtRCGSRate"></td>' +
                                '<td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="hdnItemID" id="hdnItemID" > ' + data[0].Item_ID + '</td>' + 
                                '<td style="text-align: center;"><a href="javascript:void(0)" onclick="ExcludeFromSaleReturn(this)"><i class="fa fa-trash-o" style="font-size:17px"></i></a></td>' +
                                '</tr>';
                            $('#saleReturnTableBody').append(row);
                        });
                        $('#saleReturnTableBody').on('change keyup', 'input[name="txtRQty"], input[name="txtRSalerate"], input[name="txtRDisPer"]', function () {
                            var $row = $(this).closest('tr');
                            calculateNetAmount($row);
                            $('#txtSaleReturnFlatDisc').val(0)

                        });
                        setTimeout(function () {
                            $('#ddlSaleReturnItems').select2('close');
                            $('input[name="txtRQty"]').focus().select();
                        }, 5);
                    },
                });
            }
        }
        // Function to load Simple Sale Return Items Data
        function AddSaleReturnMedicineDetail() {
            var itemId = $('#ddlSaleReturnItems').val();
            if (itemId) {
                var rowIndex = $('#saleReturnTable tbody tr').length;
                var rows;
                var exists = false;
                $('#saleReturnTable tr').each(function () {
                    var existingItemId = $(this).find('input[name="txtRItemID"]').val();
                    if (existingItemId == itemId) {
                        exists = true;
                        return false;
                    }
                });
                if (exists) {
                    swal("Item already exists");
                    $("#ddlSaleReturnItems").val(0);
                    return;
                } else {
                    $.ajax({
                        type: "post",
                        url: "IssueMedicine.aspx/SaleReturnMedicineDetail",
                        data: JSON.stringify({ "itemId": itemId }),
                        dataType: 'JSON',
                        contentType: "application/json; charset=utf-8",
                        async: false,
                        success: function (msg) {
                            var data = JSON.parse(msg.d);
                            rows = '<tr>' +
                                '<td style="display:none"><input type="hidden" value="' + data[0].Item_ID + '" name="txtRItemIDs" id="txtRItemIDs">' + data[0].Item_ID + '</td>' +
                                '<td><input type="hidden" value="' + data[0].Item_ID + '" name="txtRItemID" id="txtRItemID">' + (rowIndex + 1) + '</td>' +
                                '<td style="display:none"><input type="text" value="0" name="txtRBill_Details_ID" id="txtRBill_Details_ID"></td>' +
                                '<td><input type="hidden" value="' + data[0].Description + '" name="txtRItemDescription" id="txtRItemDescription">' + data[0].Description + '</td>' +
                                '<td style="display:none"><input type="text" name="txtRCheckQty" id="txtRCheckQty" value="0" style="width: 100% !important; height: 22px; text-align: right;" ></td>' +
                                '<td><input type="text" name="txtRQty" value="0" style="width: 100% !important; height: 22px; text-align: right;" autocomplete="off" ></td>' +
                                '<td><input type="text" name="txtRStock" id="txtRStock' + (rowIndex + 1) + '" value="0" style="width: 100% !important; height: 22px; text-align: center;" readonly></td>' +
                                '<td><input type="text" name="txtRSalerate" value="' + data[0].Sale_Rate + '" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td><input type="text" name="txtRDisPer" value="0" style="width: 100% !important; height: 22px; text-align: right;"  autocomplete="off"></td>' +
                                '<td><input type="text" name="txtRDisAmount" style="width: 100% !important; height: 22px; text-align: right;"></td>' +
                                '<td><input type="text" name="txtRnet" style="width: 100% !important; height: 22px; text-align: right;" readonly></td>' +
                                '<td><select id="txtRBatch_Nos' + (rowIndex + 1) + '" name="txtRBatch_Nos" onchange="updateReturnStock(this)" ></select></td>' +
                                '<td style="display:none;"><input type="text"  id="txtRBatch_No' + (rowIndex + 1) + '" name="txtRBatch_No"  value=""/> </td>' +
                                '<td  style="display:none;"><input type="hidden"  name="txtRCGSRate" alue="' + data[0].CGSRate + '" id="txtRCGSRate' + (rowIndex + 1) + '"></td>' +
                                '<td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="hdnItemID" id="hdnItemID" > ' + data[0].Item_ID + '</td>' + 
                                //'<td><input type="text" name="txtRBatch_No" style="width: 100% !important; height: 22px; text-align: right;" ></td>' +
                                '<td style="text-align: center;"><a href="javascript:void(0)" onclick="ExcludeFromSaleReturn(this)"><i class="fa fa-trash-o" style="font-size:17px"></i></a></td>' +
                                '</tr>';
                        },
                    });
                    $('#saleReturnTableBody').append(rows);
                    $('#ddlInvoiceNumber').val(0);
                    $('#ddlInvoiceNumber').prop('disabled', true);
                    $("#txtSaleReturnDisPer").prop('readonly', false);
                    PageMethods.GetBatchNumbersforReturn(itemId, function (data) {
                        var parsedData = JSON.parse(data);
                        var options = '<option value="0" >Please Select</option>';
                        $.each(parsedData.GRN_Details, function (key, value) {
                            options += '<option value="' + value.BatchNum + '" >' + value.BatchNum + '</option>';
                        });

                        // Process Stock_Adjustment_Details
                        $.each(parsedData.Stock_Adjustment_Details, function (key, value) {
                            options += '<option value="' + value.BatchNum + '" >' + value.BatchNum + '</option>';
                        });
                        $('#txtRBatch_Nos' + (rowIndex + 1)).html(options);
                    }, function (error) {
                        alert(error.get_message());
                    })


                    $('#saleReturnTableBody').on('change keyup', 'input[name="txtRQty"], input[name="txtRSalerate"], input[name="txtRDisPer"]', function () {
                        var $row = $(this).closest('tr');
                        calculateNetAmount($row);
                    });

                    setTimeout(function () {
                        $('#ddlSaleReturnItems').select2('close');
                        $('input[name="txtRQty"]').focus().select();
                    }, 5);
                }
            }
        }


        function updateReturnStock(anchors) {
            debugger;
            var row = $(anchors).closest('tr');
            var rowIndex = row.index();
            debugger;
            var selectId = $(anchors).attr('id');
            var idParts = selectId.split('txtRBatch_Nos');
            if (idParts.length > 1) {
                var counter = idParts[1];
            } else {
                var counter = null;
            }
            var itemId = $(row).find('td:eq(0)').text().trim();
            var batchNumber = $(anchors).find('option:selected').text().trim();
            var warehouse = $('#ddl_Warehouse').find('option:selected').val();
            var hdndiscountType = $('#hdndiscountType').val();

            $('#txtRBatch_No' + counter).val(batchNumber);
            $.ajax({
                type: "post",
                url: "IssueMedicine.aspx/GetStockByBatch",
                data: JSON.stringify({
                    "itemId": itemId,
                    "hdndiscountType": hdndiscountType,                                  
                    "batchNumber": batchNumber,
                    "warehouse": warehouse
                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (stockMsg) {
                    debugger;
                    var stockData = JSON.parse(stockMsg.d);
                    var stock = stockData[0].Total_Stock || 0;
                    var rate = stockData[0].Sale_Rate || 0;
                    var CGSRate = stockData[0].CGSRate || 0;
                    var date = stockData[0].ExpiryDate;
                    var Mini_Stocks = stockData[0].Mini_stock;

                    date = moment(date).format('D-MMM-YYYY');
                    debugger;
                    $('#txtRStock' + counter).val(stock);
                    $('#txtRCGSRate' + counter).val(CGSRate);
                },
                error: function (xhr, status, error) {
                    console.log("Error fetching stock: " + error);
                }
            });
        }
        function calculateNetAmount($row) {
            var CheckQty = parseFloat($row.find('input[name="txtRCheckQty"]').val()) || 0;
            var qty = parseFloat($row.find('input[name="txtRQty"]').val()) || 0;
            var saleRate = parseFloat($row.find('input[name="txtRSalerate"]').val()) || 0;
            var disPer = parseFloat($row.find('input[name="txtRDisPer"]').val()) || 0;
            if (CheckQty > 0 && qty > CheckQty) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Quantity Must Be Less Than Or Equal To Sold Quantity',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $row.find('input[name="txtRQty"]').val(CheckQty);
                qty = CheckQty;
                return;
            }
            if (isNaN(qty) || qty <= 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Quantity Must Be Greater Than 0',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $row.find('input[name="txtRQty"]').val(1);
                return;
            }
            if (isNaN(saleRate) || saleRate <= 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Sale Rate Must Be Greater Than 0',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $row.find('input[name="txtRSalerate"]').val(1);
                return;
            }
            if (isNaN(disPer) || disPer < 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Discount Percentage Must Be Positive or 0',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $row.find('input[name="txtRSalerate"]').val(0);
                return;
            }
            var discountAmount = (qty * saleRate * disPer) / 100;
            var netAmount = (qty * saleRate) - discountAmount;
            $row.find('input[name="txtRDisAmount"]').val(discountAmount.toFixed(2));
            $row.find('input[name="txtRnet"]').val(netAmount.toFixed(2));
            CalculateSaleReturnHeader();
            CalCulateReturnDisc();
            CalculateSaleReturnAdj();
        }

        function CalculateSaleReturnHeader() {
            var totalPayable = 0;
            var totalDiscount = 0;

            $('#saleReturnTableBody tr').each(function () {
                var $row = $(this);
                var qty = parseFloat($row.find('input[name="txtRQty"]').val()) || 0;
                var saleRate = parseFloat($row.find('input[name="txtRSalerate"]').val()) || 0;
                var disAmount = parseFloat($row.find('input[name="txtRDisAmount"]').val()) || 0;
                totalPayable += qty * saleRate;
                totalDiscount += disAmount;
            });
            $('#txtSaleReturnTotalPayable').val(totalPayable.toFixed());
            $('#txtSaleReturnLineDisc').val(totalDiscount.toFixed(2));
        }



        function CalCulateReturnDisc() {
            var total = $('#txtSaleReturnTotalPayable').val() || 0;
            var linedisamt = $('#txtSaleReturnLineDisc').val() || 0;
            var disper = $('#txtSaleReturnDisPer').val() || 0;
            var disamt = ((total - linedisamt) * disper) / 100;
            $('#txtSaleReturnDisAmt').val(disamt.toFixed(2));
            var adjustamt = $('#txtSaleReturnFlatDisc').val() || 0;
            var net = parseFloat(total - disamt - linedisamt - adjustamt).toFixed();
            if (net > -1) {
                net = Math.abs(net);
                $('#txtSaleReturnTotal').val(net);
            }
        }


        function ExcludeFromSaleReturn(anchor) {
            var $row = $(anchor).closest('tr');
            $row.remove();
            var rowCount = $("#saleReturnTable tbody tr").length;
            if (rowCount > 0) {
                $("#saleReturnTable tbody tr").each(function (index) {
                    $(this).children("td").first().text(index + 1);
                    calculateNetAmount($(this));
                });
            } else {
            }
        }

        function validateSaleReturn() {
            debugger
            var proceed = true;
            var total = $('#txtSaleReturnTotalPayable').val() || 0;

            if (!total || total <= 0) {
                proceed = false;
                $('#btnSaveSaleReturn').attr('disabled', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please check the total amount.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            if ($('#saleReturnTable tbody tr').length === 0) {
                proceed = false;
                $('#btnSaveSaleReturn').attr('disabled', false);
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Items list should have at least one item.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }

            $('#saleReturnTable tbody tr').each(function () {
                var qty = $(this).find('input[name="txtRQty"]').val();
                var rate = $(this).find('input[name="txtRSalerate"]').val();

                if (!qty || qty <= 0) {
                    proceed = false;
                    $('#btnSaveSaleReturn').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please check the quantity. It must be greater than zero.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }

                if (!rate || rate <= 0) {
                    proceed = false;
                    $('#btnSaveSaleReturn').attr('disabled', false);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please check the rate. It must be greater than zero.',
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
            return proceed;
        }

        function SearchReturnPop() {
            debugger;
            $('#SearchReturnModel').modal({
                backdrop: 'static'
            });
            $('#txtReturnuserCode').focus();
            $('#txtReturnuserCode').val('');
            $('#btnSaveSaleReturn').attr('disabled', false);
            $('#lblReturnUsername').text('');
            $('#txtReturnpass').text('');
        }
        debugger;
        function SaveSaleReturn() {
            debugger;
            $('#btnSaveSaleReturn').attr('disabled', true);
            var userC = $('#txtReturnuserCode').val();
            var userP = $('#txtReturnpass').val();
            var userCode;
            var UserPass;
            var UserId;
            PageMethods.loadData(userC, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                if (data.length != 0) {
                    userCode = data[0].User_Code;
                    UserPass = data[0].Password;
                    UserId = data[0].UserID;
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid User',
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
                if (userC == userCode && userP == UserPass) {
                    if (validateSaleReturn()) {
                        var BillId = $('#ddlInvoiceNumber').val() || 0;
                        var Patient_id = $('#ddlpat_no').val() || 0;
                        var warehouse = $("#ddl_Warehouse").val();
                        var InvNo = $('#ddlInvoiceNumber option:selected').text() || '';
                        var TotalPayable = $('#txtSaleReturnTotalPayable').val() || 0;
                        var TotalLineDisc = $('#txtSaleReturnLineDisc').val() || 0;
                        var DisPer = $('#txtSaleReturnDisPer').val() || 0;
                        var TotalDisAmt = $('#txtSaleReturnDisAmt').val() || 0;
                        var AdjustmentAmt = $('#txtSaleReturnFlatDisc').val() || 0;
                        var Total = $('#txtSaleReturnTotal').val() || 0;
                        var table = $('#saleReturnTableBody');
                        var Item_list = [];
                        var isValid = true;
                        table.find('tr').each(function () {
                            debugger;
                            var itemID = $(this).find('input[name="txtRItemID"]').val() || 0;
                            var billDetailsID = $(this).find('input[name="txtRBill_Details_ID"]').val() || 0;
                            var itemName = $(this).find('input[name="txtRItemDescription"]').val() || 0;
                            var qty = $(this).find('input[name="txtRQty"]').val() || 0;
                            var rate = $(this).find('input[name="txtRSalerate"]').val() || 0;
                            var disPer = $(this).find('input[name="txtRDisPer"]').val() || 0;
                            var disAmt = $(this).find('input[name="txtRDisAmount"]').val() || 0;
                            var netAmt = $(this).find('input[name="txtRnet"]').val() || 0;
                            var Batch_No = $(this).find('input[name="txtRBatch_No"]').val();
                            var CGSRate = $(this).find('input[name="txtRCGSRate"]').val() || 0;

                            debugger;
                            var CGSAmount = CGSRate * qty;

                            if (Batch_No == 'Please Select' || Batch_No == '0' || Batch_No == "") {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Please Select Batch Number',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });

                                isValid = false;
                                $('#btnSaveSaleReturn').attr('disabled', false);
                                return false;
                            }
                            Item_list.push({
                                'ItemID': itemID,
                                'Bill_Details_ID': billDetailsID,
                                'ItemName': itemName,
                                'Qty': qty,
                                'Rate': rate,
                                'DisPer': disPer,
                                'DisAmt': disAmt,
                                'NetAmt': netAmt,
                                'Batch_No': Batch_No,
                                'CGSAmount': CGSAmount
                            });
                        });
                        if (!isValid) {
                            return; // Stop execution of SaveSaleReturn function
                        }
                        $('#btnSaveSaleReturn').attr('disabled', true);
                        var AllItemDetail = {
                            'BillId': BillId,
                            'Patient_id': Patient_id,
                            'InvNo': InvNo,
                            'warehouse': warehouse,
                            'TotalPayable': TotalPayable,
                            'TotalLineDisc': TotalLineDisc,
                            'DisPer': DisPer,
                            'TotalDisAmt': TotalDisAmt,
                            'AdjustmentAmt': AdjustmentAmt,
                            'Total': Total,
                            'ItemList': Item_list
                        };

                        PageMethods.SaveSaleReturnData(JSON.stringify(AllItemDetail), UserId, function (res) {
                            var btnSave = $('#SSearchReturnPop').val();
                          /*  if (btnSave == 'Save & Print' || btnSave == "Save & Print") {*/
                                window.open('../../ReportViewer.aspx?ReportName=PharmacyReturnSlip&ReportTitle=Pharmacy Return Slip&Return_ID=' + JSON.parse(res));
                            //}
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Saved Successfully',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                            window.location = "IssueMedicine.aspx";
                        });
                    }
                }
            });

        }

        debugger;
        var addedItemIDs = [];
        var items = [];
        var addedItemIDs = [];
        var items = [];

        function loadmed() {
            var ItemName = ItemNames || '';

            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/loadMedicine",
                data: JSON.stringify({ "ItemName": ItemName }),
                dataType: 'json',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    var data = JSON.parse(msg.d);
                    items = [];
                    addedItemIDs = [];

                    $.each(data, function (key, value) {
                        // Skip if already added (prevents duplicates)
                        if (addedItemIDs.indexOf(value.Item_ID) !== -1) return;

                        // Build display text: prefer Description, fallback to Generic_Name
                        let displayText = value.Description && value.Description.trim() !== ''
                            ? value.Description
                            : (value.Generic_Name && value.Generic_Name.trim() !== ''
                                ? value.Generic_Name
                                : 'No Name');

                        // Optional: Highlight if Generic_Name matched the search
                        if (value.Generic_Name && value.Generic_Name.toLowerCase().includes(ItemName.toLowerCase())) {
                            displayText = `[${value.Generic_Name}] ${displayText}`;
                        }

                        // Final display: Item_Code - DisplayText
                        let fullText = `${value.Item_Code} - ${displayText}`;

                        items.push({ id: value.Item_ID, text: fullText });
                        addedItemIDs.push(value.Item_ID);
                    });

                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                }
            });
        }
        
        function OnHoldBill() {
            var CheckVisting = $('#chkHold:checked').val();
            if (CheckVisting == "on") {
                window.open('IssueMedicine.aspx');
            }
        }
      
        var counts = 0;
        var NegQty = false;
        function CulculateAmonutWithQty(anchor) {
            debugger;
            counts = counts + 1;
            var row = $(anchor).parents('tr')[0];
            var CalAmount = $($(row).find('td')[8]).text();
            var Qty = $($(row).find('td input[name=txtQty]')[0]).val();
            var Stock = $($(row).find('td input[name=txtStock]')[0]).val();
            if (Qty > 0) {
                $('#Inv_No').hide();
                $('#btnpreview').hide();
            }
            else {
                $('#Inv_No').show();
                $('#btnpreview').show();
            }
            if (Qty == "" || Qty == '') {
                Qty = 0;
            }
            if (parseInt(Qty) > parseInt(Stock)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'QTY Should Not Be Greater Than Stock',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                var Qty = $($(row).find('td input[name=txtQty]')[0]).val(1);
                if (Stock == 0 || Stock == "0") {
                    var Qty = $($(row).find('td input[name=txtQty]')[0]).val(0);
                }
                CulculateAmonutWithQty(anchor);
                return false;
            }
            if (Qty <= 0) {
                NegQty = true;
            }
            var totalamount = (CalAmount) * (Qty)
            $($(row).find('td')[11]).text(totalamount);
            var getrowindex = row.rowIndex;
            var excatrowindex = parseInt(getrowindex) - parseInt(1);
            CalculateSummarieDiscountPerWise(excatrowindex);
        }
        function Invoice() {
            debugger;
            var search = $('#Inv_No').val();
            $.ajax({
                url: 'IssueMedicine.aspx/Preview',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                data: JSON.stringify({
                    "search": search,
                }),
                success: function (result) {
                    debugger;
                    var result1 = JSON.parse(result.d);
                    if (result.d == '[]') {
                        alert('No Result Found')
                    }
                    else {
                        var BillID = JSON.stringify(result1[0].BillId);

                        window.open('ReportViewer.aspx?ReportName=PharmacySlip&ReportTitle=PharmacySlip&Bill_ID=' + BillID);
                    }
                },
            });
        }
        function ExcludeFromPayment(anchor) {
            console.clear();
            var row = $(anchor).parents('tr')[0];
            row.remove();
            CalculateTotals();
            debugger;
            $("#tblDetails tbody tr").each(function (key) {
                debugger;
                $(this).children("td")[0].innerHTML = key + 1;
                $(this).find('.orderchange').find('input').attr("onkeyup", "CalculateSummarieDiscountPerWise(" + (key) + ")");
                $(this).find('td:eq(1)').text(key + 1);
            })
        }

        function CalculateTotals() {
            debugger;
            var Amount = 0;
            var DisAmt = 0;
            var AmntFinal = 0;
            var NetAmount = 0;
            var Qty = 0;
            var ttlDisAmnt = 0;
            $.each($('#tblDetails tbody tr'), function (key, value) {
                debugger;
                Amount = parseFloat($($(value).find('td')[8]).text());
                DisAmt = parseFloat($(value).find('input[name="DisAmount"]').val());
                Qty = parseFloat($(value).find('input[name="txtQty"]').val());
                NetAmount += (Amount * Qty) - DisAmt;
                AmntFinal += (Amount * Qty);
                ttlDisAmnt += DisAmt
            });
            debugger;
            Math.round($('#txtTotalPayable').val((AmntFinal).toFixed(0)), 0);

            $('#txtDisAmt').val(parseInt(Math.round(ttlDisAmnt)));
            var Disc = $('#txtDisAmt').val();

            if (Disc == 0) {
                $('#txtDisPer').val(0);
            }
            $('#txtNetPayable').val(Math.round(NetAmount));
            $('#txtBalances').val(Math.round(NetAmount));
            if (blnceCondition == 'true') {
                var AmtReceived = $('#txtAmountReceived').val();

                if ($('#txtTotalPayable').val() != '') {
                    if (AmtReceived != '') {
                        debugger;
                        var balance = parseFloat(NetAmount - AmtReceived);

                        $('#txtBalances').val(Math.round(parseFloat(balance)));
                    }
                    else
                        $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
                }
                else {
                    $('#txtBalances').val(Math.round(parseFloat(NetAmount)));
                }
            }
            else {
                $('#txtAmountReceived').val(Math.round(NetAmount));
            }

        }

        function toasterMessage(isError = false, title, message) {
            debugger;
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "preventDuplicates": false,
                "positionClass": "toast-top-right",
                "onclick": null,
                "showDuration": "400",
                "hideDuration": "1000",
                "timeOut": "4000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut",
                onclick: function () {
                    $('#right-sidebar').toggleClass('sidebar-open');
                }
            };
            if (isError)
                toastr.error(message, title);
            else
                toastr.success(message, title);
        }
        function CountBalance() {
            debugger;
            var TtlPayable = $('#txtTotalPayable').val();
            if (TtlPayable == "") {
                TtlPayable = 0;
            }
            var ttlDisc = $('#txtDisAmt').val();
            var tllDisc = $('#txtLineDisc').val();
            var AmtReceived = $('#txtAmountReceived').val();
            var flatdisc = $('#txtFlatDisc').val();
            if (flatdisc == "" || flatdisc == "visionplus") {
                flatdisc = 0;
            }
            if (TtlPayable != '' || TtlPayable != 0) {
                if (AmtReceived != '') {
                    $('#txtBalances').val((Math.round(parseFloat(TtlPayable) - parseFloat(ttlDisc) - parseFloat(tllDisc) - parseFloat(flatdisc) - parseFloat(AmtReceived))).toFixed(0));
                }
                else
                    $('#txtBalances').val(TtlPayable.toFixed(0));
            }
            else {
                $('#txtBalances').val(TtlPayable.toFixed(0));
            }
        }
        function sumdiscount() {
            debugger;
            var txtLineDisc = parseFloat($('#txtLineDisc').val()) || 0;
            var txtDisAmt = parseFloat($('#txtDisAmt').val()) || 0;
            var txtAmountReceived = parseFloat($('#txtAmountReceived').val()) || 0;
            var totalDisc = $('#txttotalDisc').val() || 0;
            totalDisc = txtLineDisc + txtDisAmt;
            totalDisc = Math.round(totalDisc); 
            $('#txttotalDisc').val(totalDisc);
        }
        function CalculateSummarieDiscountAmountWise(rowIndex) {
            debugger;
            isMax = 0;
            AssignValue(txtDisPer, 0);
            AssignValue(txtDisAmt, 0);
            AssignValue(txtAmountReceived, 0);
            var Amount = 0;
            var TotalAmount = 0;
            var DisPer = 0;
            var DisAmt = 0;
            var NetAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            $.each($('#tblDetails tbody tr'), function (key, value) {
                TDis = 0;
                var Qty = $($(value).find('td input[name=txtQty]')[0]).val().trim();
                if (rowIndex == parseInt(key)) {
                    Amount = $($(value).find('td')[8]).text();
                    if (Amount.trim() < 1 || Amount == "" || Amount.trim() == "0") {
                        return false;
                    }
                    DisAmt = $(value).find('input[name="DisAmount"]').val();
                    DisPer = 100 / (Amount * Qty) * DisAmt;
                    var NtAmt = (Amount * Qty);
                    TDis = DisAmt;
                    $(value).find('input[name="DisPer"]').val(DisPer.toFixed(2));
                    NetAmount = (Amount * Qty) - DisAmt;
                    $($(value).find('td')[11]).text(NetAmount.toFixed(2));
                }
                if (parseInt(TDis) > NtAmt) {
                    isMax = 1;
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Discount Percentage Should not be greater than 100%',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                    $(value).find('input[name="DisAmount"]').val('0');
                    $(value).find('input[name="DisPer"]').val('0');
                    $($(value).find('td')[11]).text(Amount);
                }
                debugger;
                Amount = $($(value).find('td')[8]).text();
                TotalAmount += parseFloat(Amount * Qty);
                TotalDiscountAmount += Math.round(parseFloat($(value).find('input[name="DisAmount"]').val()));
                if (isNaN(TotalDiscountAmount)) {
                    $(value).find('input[name="DisAmount"]').val(0);
                    TotalDiscountAmount = 0;
                }
                TotalNetAmount += parseFloat($($(value).find('td')[11]).text());
            });
            debugger;
            $('#txtTotalPayable').val(TotalAmount.toFixed());
            $('#txtDisAmt').val(TotalDiscountAmount.toFixed(2));
            if (blnceCondition == 'true') {
                var ReceivedAmount = $('#txtAmountReceived').val();
                $('#txtBalances').val(parseFloat(TotalNetAmount.toFixed(2)) - parseFloat(ReceivedAmount));
            }
            else {
                $('#txtAmountReceived').val(parseFloat(TotalNetAmount.toFixed(2)));
            }
        }
        function CalculateSummariesMasterDiscount(AmtWise) {
            debugger
            if (!AmtWise) {
                debugger
                var disper = $('#txtDisPer').val() || 0;
                var totalpayable = $('#txtTotalPayable').val() || 0;
                var txtLineDisc = $('#txtLineDisc').val() || 0;
                var netamt = parseFloat(totalpayable - txtLineDisc).toFixed(2);
                var disAmt = 0;
                if (disper > 0) {
                    disAmt = (netamt * disper) / 100;
                    disAmt = Math.round(disAmt);
                }
                else {
                    disAmt = 0;
                }
                $('#txtDisAmt').val(parseFloat(disAmt).toFixed(2));
            }
            if (AmtWise) {
                debugger
                var txtDisAmt = $('#txtDisAmt').val() || 0;
                var totalpayable = $('#txtTotalPayable').val() || 0;
                var txtLineDisc = $('#txtLineDisc').val() || 0;
                var netamt = parseFloat(totalpayable - txtLineDisc).toFixed(2);
                var disper = 0;
                if (txtDisAmt > 0) {
                    disper = (txtDisAmt / netamt) * 100;
                }
                else {
                    disper = 0;
                }
                $('#txtDisPer').val(parseFloat(disper).toFixed(2));
            }
            var txtDisAmt = $('#txtDisAmt').val();
            TotalAmount = $('#txtTotalPayable').val();
            var txtLineDisc = parseFloat($('#txtLineDisc').val()) || 0;
            var flatdisc = $('#txtFlatDisc').val();
            if (flatdisc == "") {
                flatdisc = 0;
            }
            var totamourcvd = $('#txtAmountReceived').val();
            var finalbalance = parseFloat(TotalAmount) - parseFloat(txtLineDisc) - parseFloat(txtDisAmt).toFixed(2) - parseFloat(flatdisc);
            if (blnceCondition == 'true') {
                $('#txtBalances').val((finalbalance).toFixed());
            }
            else {
                $('#txtAmountReceived').val((finalbalance).toFixed());
            }
        }

        function Print_Prescription() {
            var id = $('#ddlPatient_No').val();
            var PatNo = $('#ddlPatient_No option:selected').text();
            var parts = PatNo.split('-');
            var prefix = parts[0];
            var number = parts[1];
            if (prefix == 'OPD') {
                window.open('../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + id);
            }
            if (prefix == 'IPD') {
                window.open('../../ReportViewer.aspx?ReportName=InpatientDetail&Title=In Patient Detail Print&InPatient_ID=' + id);
            }
            if (prefix == 'Emergency') {
                window.open('../../ReportViewer.aspx?ReportName=Emergencypatient&Title=Emergency Patient Report&Emergency_ID=' + id);
            }
        }
        function AssignValue(ControlID, value) {
            if (ControlID.value == '')
                ControlID.value = value;
        }
        var isMax = 0;
        var TDis = 0;
        function CalculateSummarieDiscountPerWise(rowIndex) {
            debugger;
            isMax = 0;
            AssignValue(txtDisPer, 0);
            AssignValue(txtDisAmt, 0);
            AssignValue(txtLineDisc, 0);
            AssignValue(txtAmountReceived, 0);
            var Amount = 0;
            var DisPer = 0;
            var DisAmt = 0;
            var NetAmount = 0;
            var TotalAmount = 0;
            var TotAmount = 0;
            var TotalDiscountAmount = 0;
            var TotalNetAmount = 0;
            $.each($('#tblDetails tbody tr'), function (key, value) {
                TDis = 0;
                var Qty = $($(value).find('td input[name=txtQty]')[0]).val().trim();
                if (rowIndex == parseInt(key)) {
                    debugger;
                    var Amountsss = $($(value).find('td input[name=txtSalerate]')[0]).val();
                    console.log(Amountsss)
                    Amount = $($(value).find('td input[name=txtSalerate]')[0]).val().trim();
                    //Amount = ($(value).find('input[name="txtSalerate"]').val() === "" || $(value).find('input[name="txtSalerate"]').val() === "undefined" || $(value).find('input[name="txtSalerate"]').val() < 1) ? $(value).find('input[name="txtSalerate"]').val() : $(value).find('input[name="txtSalerate"]').val();
                    DisPer = $(value).find('input[name="DisPer"]').val();
                    if (DisPer > 100 || DisPer > "100") {
                        NegQty = false;
                    }
                    DisAmt = Qty * Amount * DisPer / 100;
                    var NtAmt = (Amount * Qty);
                    TDis = DisAmt;
                    $(value).find('input[name="DisAmount"]').val(DisAmt.toFixed(2));
                    NetAmount = (Amount * Qty) - DisAmt;
                    $($(value).find('td')[11]).text(NetAmount.toFixed(2));
                }
                if (parseInt(TDis) >= NtAmt && NegQty == false) {
                    isMax = 1;
                    debugger;
                    $(value).find('input[name="DisAmount"]').val('0');
                    $(value).find('input[name="DisPer"]').val('0');
                    $($(value).find('td')[11]).text(NtAmt);
                }
                Amount = $($(value).find('td input[name=txtSalerate]')[0]).val().trim();
                TotalAmount += parseFloat(Amount * Qty);
                DisAmt = $(value).find('input[name="DisAmount"]').val();
                if (DisAmt == "") {
                    DisAmt = 0;
                }
                TotalDiscountAmount += parseFloat(DisAmt);
                NetAmount = (Amount * Qty) - DisAmt;
                TotalNetAmount += NetAmount;
            });
            debugger;
            $('#txtTotalPayable').val(TotalAmount.toFixed());
            $('#txtBalances').val(TotAmount);

            var discper = $('#txtDisPer').val();
            var FlatDisc = $('#txtFlatDisc').val();
            if (FlatDisc == "") {
                FlatDisc = 0;
            }
            var ReceivedAmount = $('#txtAmountReceived').val();
            TotalDiscountAmount = Math.round(TotalDiscountAmount); 
            $('#txtLineDisc').val(TotalDiscountAmount);
            //$('#txtLineDisc').val(TotalDiscountAmount.toFixed(2));
            var discfinalAmnt = $('#txtLineDisc').val() || 0;
            //$('#txtAmountReceived').val(parseFloat(TotalAmount.toFixed()) - parseFloat(discfinalAmnt) - parseFloat(FlatDisc));
            console.log(blnceCondition)
            if (blnceCondition == 'true') {
                $('#txtBalances').val((parseFloat(TotalAmount) - parseFloat(discfinalAmnt) - parseFloat(FlatDisc)).toFixed());
            }
            else {
                $('#txtAmountReceived').val((parseFloat(TotalAmount) - parseFloat(discfinalAmnt) - parseFloat(FlatDisc)).toFixed());
            }
        }
        function CheckSaleReturnAllow() {
            debugger;
            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/CheckSaleReturnAllow",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    var checkActive = data.d;

                    if (checkActive == "true") {
                        $('#SSearchReturnPop').attr('disabled', false)
                    }
                    else {
                        $('#SSearchReturnPop').attr('disabled', true)
                    }

                },
                failure: function () {
                    alert(bi);
                }
            });
        }
        function getOPDandIPDNO(pat_id) {
            PageMethods.GetOPDandIPDNO(pat_id, function (data) {
                var parsedData = JSON.parse(data);
                var options = '<option value="0" >Please Select</option>';

                // Process GRN_Details
                $.each(parsedData.OPD_NO, function (key, value) {
                    options += '<option value="' + value.Patient_ID + '" >' + value.Patient_No + '</option>';
                });

                // Process Stock_Adjustment_Details
                $.each(parsedData.IPD_NO, function (key, value) {
                    options += '<option value="' + value.Patient_ID + '" >' + value.Patient_No + '</option>';
                });

                // Process Stock_Adjustment_Details
                $.each(parsedData.Emergency_NO, function (key, value) {
                    options += '<option value="' + value.Patient_ID + '" >' + value.Patient_No + '</option>';
                });

                $('#ddlPatient_No').html(options);
                $('#ddlPatient_No').select2();
            })
        }
        function getbatchfrom_grn() {
            debugger;

            var Inv_batch = $('#chkbatch').prop("checked");

            if (Inv_batch == false) {
                $('#batchno').hide();
                $('#batchno').prop('disabled', true);

                AddnonBatchItems();
            }
            else {
                var med_id = $('#medName').find('option:selected').val();

                PageMethods.GetinvBatch(med_id, function (dataa) {
                    debugger;
                    var parsedDataa = JSON.parse(dataa);
                    if (parsedDataa == true) {
                        debugger
                        var warehouse = $("#ddlWarehouse").val()

                        if (warehouse == "0") {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Please Select Warehouse First.',
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
                        PageMethods.Getbatch_grn(med_id, warehouse, function (data) {
                            debugger;                          
                            var parsedData = JSON.parse(data);
                            console.log(parsedData)
                            var options = '<option value="0" >Please Select</option>';
                            debugger;
                            $.each(parsedData, function (key, value) {
                                console.log(value)
                                options += '<option value="' + value.BatchNum + '" >' + value.BatchNum + '</option>';
                            });
                            $('#batchno').html(options);
                            $('#batchno').select2();
                            var isbatch = $('#chkbatch').prop("checked");
                            debugger;
                            if (isbatch == true) {
                                $('#batchno').show();
                                $('#batchno').prop('disabled', false);

                                setTimeout(function () {
                                    $('#batchno').focus();
                                }, 100);
                            } else {
                                $('#batchno').hide();
                                $('#batchno').prop('disabled', true);
                            }
                        }, function (error) {
                            alert(error.get_message());
                        });
                    }
                    else {
                        AddnonBatchItems();
                    }
                });

            }
        }
        function AddnonBatchItems() {
            debugger;
            var itemId = $('#medName').val();

            var rowIndex = parseInt($('#tblDetails tbody tr').length);
            let rows;
            var expdate = '';

            // Check if the item with the same batch number already exists
            var itemExists = false;
            $('#tblDetails tbody tr').each(function () {
                var existingItemId = $(this).find('input[name="ItemID"]').val();

            });



            $.ajax({
                type: "post",
                url: "IssueMedicine.aspx/MedicineDetailgetfromOPD",
                data: JSON.stringify({
                    "itemId": itemId

                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    var length = $("#tblDetails tr:gt(0)").length;
                    $('#Table_1 tr:gt(0)').remove();
                    var data = JSON.parse(msg.d);
                    debugger;
                    var Uomqty = data[0].UOM_Qty;
                    if (Uomqty == null) {
                        Uomqty = 0;
                    } else {
                        Uomqty = data[0].UOM_Qty;
                    }
                    var date = data[0].ExpiryDate
                    date = moment(date).format('D-MMM-YYYY');

                    debugger;
                    rows = '<tr><td> ' + parseInt(parseInt(rowIndex) + 1) + '</td>' +

                        '<td style="display:none;"><input type="hidden" value="' + data[0].Item_Code + '" name="ItemIDcode" id="ItemIDcode" ></td>' +

                        ' <td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="ItemID" id="ItemID" ></td>' +

                        '<td><input type="hidden" value="' + data[0].Description + '" name="Itemdesc" id="Itemdesc" >' + data[0].Description + '</td>' +

                        '<td style="display:none"><input type="hidden" value="' + data[0].Unit + '" name="txtUom" id="txtUom" >' + data[0].Unit + '</td>' +

                        '<td><input type="hidden" value="' + Uomqty + '" name="UomQty" id="UomQty"  >' + Uomqty + '</td>' +

                        '<td><input type="number" name="txtQty" value="1" style="width: 62px !important;margin-left: -7px;position: absolute;height:22px;text-align: right;" class="height_height" onkeyup="CulculateAmonutWithQty(this)" onblur="CulculateAmonutWithQty(this)" autocomplete="off" onclick="this.select();" /></td>' +

                        '<td><input type="number" name="txtStock" value="' + data[0].Total_Stock + '" style="width: 73px !important;margin-left: -2px;position: absolute;height:22px;text-align: right;" class="height_height" disabled/></td>' +

                        '<td style="text-align: right;" ><input type="hidden" value="' + data[0].Sale_Rate + '" name="txtSalerate" id="txtSalerate" >' + data[0].Sale_Rate + '</td>' +

                        '<td><input type="number" name="DisPer" value="0" class="height_height orderchange" style="width: 75px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + '),sumdiscount()" autocomplete="off" onclick="this.select();" /> </td>' +

                        '<td><input type="text" disabled name="DisAmount" class="height_height orderchangeDiscount" value="" style="width: 100px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;"  /></td>' +

                        '<td style="text-align:Right;"></td>' +
                        '<td><input type="text" disabled name="BatchNo" class="" value="' + data[0].BatchNum + '" style="width: 103px !important;text-align: center;margin-left: -4px;position: absolute;height:22px;" /></td>' +
                        '<td><input type="text" disabled name="exp_date" class="" value="' + date + '" style="width: 103px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" /></td>' +
                        '<td style="display:none;"><input type="text"  id="txtCGSRate' + (rowIndex + 1) + '" name="txtCGSRate" class="" value="' + data[0].CGSRate + ' "/> </td>' +
                        '<td style="display:none;"><input type="text"  id="txtCGSAmount' + (rowIndex + 1) + '" name="txtCGSAmount" class="" value="' + data[0].CGSRate + ' " /> </td>' +
                        ' <td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="hdnItemID" id="hdnItemID" ></td>' +
                        '<td style="text-align: center;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash-o" style="font-size:17px"></i></a> </td>' +

                        '</tr>';

                    $('#tblDetails #tblbody').append(rows);

                    setTimeout(function () {
                        $('#medName').select2('close');
                        $('input[name="txtQty"]').focus().select();
                    }, 5);

                    CalculateSummarieDiscountPerWise(rowIndex);
                }
            });
        }
        debugger;
        function AddMedicineDetail() {
            debugger;
            var itemId = $('#medName').find('option:selected').val();
            var Batch = $('#batchno').find('option:selected').val();
            var warehouse = $('#ddlWarehouse').find('option:selected').val();
            var hdndiscountType = $('#hdndiscountType').val();
            var rowIndex = parseInt($('#tblDetails tbody tr').length);
            let rows;
            var expdate = '';
            var itemExists = false;

            

            $('#tblDetails tbody tr').each(function () {
                var existingItemId = $(this).find('input[name="ItemID"]').val();
                var existingBatchNo = $(this).find('input[name="BatchNo"]').val();
                if (existingItemId == itemId && existingBatchNo == Batch) {
                    itemExists = true;
                    return false;
                }
            });
            if (itemExists) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'This item with the same batch number already exists.',
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

            $.ajax({
                type: "post",
                url: "IssueMedicine.aspx/MedicineDetail",
                data: JSON.stringify({
                    "itemId": itemId,
                    "hdndiscountType": hdndiscountType,
                    "Batch": Batch,
                    "warehouse": warehouse
                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (msg) {
                    var length = $("#tblDetails tr:gt(0)").length;
                    $('#Table_1 tr:gt(0)').remove();
                    var data = JSON.parse(msg.d);
                    debugger;
                    var Uomqty = data[0].UOM_Qty;
                    if (Uomqty == null) {
                        Uomqty = 0;
                    } else {
                        Uomqty = data[0].UOM_Qty;
                    }
                    var date = data[0].ExpiryDate
                    date = moment(date).format('D-MMM-YYYY');
                    var discountBlock = data[0].Discount_Block;
                    var isDiscountDisabled = (discountBlock == 1 || discountBlock === true);
                    var disDisabledAttr = isDiscountDisabled ? 'disabled' : '';
                   
                    debugger;
                    rows = '<tr><td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="ItemID" id="ItemID" ></td>' +

                        '<td> ' + parseInt(parseInt(rowIndex) + 1) + '</td>' +

                        '<td style="display:none;"><input type="hidden" value="' + data[0].Item_Code + '" name="ItemIDcode" id="ItemIDcode" ></td>' +

                        '<td><input type="hidden" value="' + data[0].Description + '" name="Itemdesc" id="Itemdesc" >' + data[0].Description + '</td>' +

                        '<td style="display:none"><input type="hidden" value="' + data[0].Unit + '" name="txtUom" id="txtUom" >' + data[0].Unit + '</td>' +

                        '<td><input type="hidden" value="' + Uomqty + '" name="UomQty" id="UomQty"  >' + Uomqty + '</td>' +

                        '<td><input type="text" name="txtQty" value="1" min="1" style="width: 62px !important;margin-left: -7px;position: absolute;height:22px;text-align: right;" class="height_height" onkeyup="CulculateAmonutWithQty(this)" autocomplete="off" onclick="this.select();" /></td>' +

                        '<td><input type="number" name="txtStock" value="' + data[0].Total_Stock + '" style="width: 73px !important;margin-left: -2px;position: absolute;height:22px;text-align: right;" class="height_height" readonly/></td>' +

                        '<td style="text-align: right;" ><input type="hidden" value="' + data[0].Sale_Rate + '" name="txtSalerate" id="txtSalerate" >' + data[0].Sale_Rate + '</td>' +

                        '<td><input type="number" name="DisPer" min="0" value="0"' + disDisabledAttr + ' class="height_height orderchange" style="width: 95px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + '),sumdiscount()" autocomplete="off" onclick="this.select();" /> </td>' +
                        '<td><input type="text" readonly name="DisAmount"' + disDisabledAttr + ' class="height_height orderchangeDiscount" value="" style="width: 103px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;"  /></td>' +

                        '<td style="text-align:Right;"></td>' +
                        '<td><input type="text" disabled name="BatchNo" class="" value="' + data[0].BatchNum + '" style="width: 103px !important;text-align: center;margin-left: -4px;position: absolute;height:22px;" /></td>' +
                        '<td><input type="text" disabled name="exp_date" class="" value="' + date + '" style="width: 103px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" /></td>' +
                        '<td style="display:none;"><input type="text"  id="txtCGSRate' + (rowIndex + 1) + '" name="txtCGSRate" class="" value="' + data[0].CGSRate + ' "/> </td>' +
                        '<td style="display:none;"><input type="text"  id="txtCGSAmount' + (rowIndex + 1) + '" name="txtCGSAmount" class="" value="' + data[0].CGSRate + ' " /> </td>' +
                        ' <td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="hdnItemID" id="hdnItemID" ></td>' +
                        '<td style="text-align: center;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash-o" style="font-size:17px"></i></a> </td>' +
                        '</tr>';
                    $('#tblDetails #tblbody').append(rows);
                    setTimeout(function () {
                        $('#medName').select2('close');
                        $('input[name="txtQty"]').focus().select();

                        if (isDiscountDisabled) {
                            $('input[name="DisPer"]:last').val(0);
                            $('input[name="DisAmount"]:last').val(0);
                        }
                    }, 5);
                    CalculateSummarieDiscountPerWise(rowIndex);
                }
            });
        }
        function adjustment() {
            debugger;
            var ttlpayable = $('#txtTotalPayable').val();
            if (ttlpayable == "") {
                ttlpayable = 0;
            }
            var tllDisc = $('#txtLineDisc').val();
            var ttlDisc = $('#txtDisAmt').val();
            if (ttlDisc == "") {
                ttlDisc = 0;
            }
            var flatdisc = $('#txtFlatDisc').val();
            if (flatdisc == "") {
                flatdisc = 0;
            }
            var finlblce = parseFloat(ttlpayable) - parseFloat(ttlDisc) - parseFloat(tllDisc) - parseFloat(flatdisc);

            
            if (blnceCondition == 'true') {
                if (finlblce > -1) {
                    finlblce = Math.abs(finlblce);
                    $('#txtBalances').val(finlblce.toFixed());
                }
                else {
                    $('#txtBalances').val(ttlpayable.toFixed());
                }
            }
            else {
                $('#txtAmountReceived').val(finlblce.toFixed());
            }
        }
        function SaveDataWithoutUser() {
            debugger;
            $('#SaveVal').attr('disabled', true);
            var userC = $('#txtuserCode').val();
            var userP = $('#txtpass').val();
            var userCode;
            var UserPass;
            var UserId = 0


            debugger;
            var Bill_ID = '';
            Bill_ID = '<%= Request.QueryString["Bill_ID"]%>'
            if (Bill_ID == '')
                Bill_ID = 0
            var Patient_ID = $('#hdPatientID').val();
            if (Patient_ID == "" || Patient_ID == '') {
                Patient_ID = "";
            }
            var CustomerName = $('#CustomerName').val();
            var warehouse = $("#ddlWarehouse").val();
            var TransType = $("#txtTransType").val();
            var ReferBy = $('#ddlDoctor').val();
            var Dept = $('#ddlDepartment').val();
            var totalPayable = $('#txtTotalPayable').val();
            var DiscPercent = $('#txtDisPer').val();
            var MasterDiscount = $('#txtDisAmt').val();
            var flatdisc = $('#txtFlatDisc').val();
            if (flatdisc == "" || flatdisc == "visionplus") {
                flatdisc = 0;
            }
            var AmntReceived = $('#txtAmountReceived').val();
            var BalanceAmount = $('#txtBalances').val();
            if (BalanceAmount == "") {
                BalanceAmount = 0;
            }
            if (warehouse == "0") {
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
                $('#SaveVal').attr('disabled', false);
                return;
            }
            
            var linediscount = $('#txtLineDisc').val();
            var DiscAmnt = $('#txttotalDisc').val();
            if (DiscAmnt == '') {
                DiscAmnt = 0.00;
            }
            var Rbtn = $('input[name="rbtn"]:checked').val();
            var patId = out_Patient_Id;
            var invNumber = $("#Inv_No").val();
            var Save_list = [];
            var hasInvalidStock = false;
            var Save_list = [];
            $.each($('#tblDetails tbody tr'), function (key, value) {
                debugger;
                var Itemid = $($(value).find('td input[name=ItemID]')[0]).val();
                var ItemName = $($(value).find('td input[name=Itemdesc]')[0]).val();
                var Qty = $($(value).find('td input[name=txtQty]')[0]).val();
                var Stock = $($(value).find('td input[name=txtStock]')[0]).val();
                var Amount = $($(value).find('td input[name=txtSalerate]')[0]).val();
                var DiscPer = $($(value).find('td input[name=DisPer]')[0]).val();
                var DiscAmount = $($(value).find('td input[name=DisAmount]')[0]).val();
                var batchno = $($(value).find('td input[name=BatchNo]')[0]).val();
                var expdate = $($(value).find('td input[name=exp_date]')[0]).val();
                var CGSRate = $($(value).find('td input[name=txtCGSRate]')[0]).val();
                var hdnItemid = $($(value).find('td input[name=hdnItemID]')[0]).val();
                var CGSAmount = CGSRate * Qty;
                if (batchno == null) {
                    batchno = '';
                }
               

                if (parseFloat(Stock) <= 0 && parseFloat(Qty) > 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Quantity must be greater than zero.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    hasInvalidStock = true;
                    return false;
                }
                if (parseFloat(Qty) <= 0) {
                    alert('Quantity must be greater than zero.');
                    hasInvalidStock = true;
                    return false;
                }
                if (parseFloat(Stock) < parseFloat(Qty)) {
                    alert('Quantity must be less than or equal to stock.');
                    hasInvalidStock = true;
                    return false;
                }
                var NetAmount = $($(value).find('td')[11]).text();
                Save_list.push({
                    Itemid: Itemid, ItemName: ItemName, Qty: Qty, Stock: Stock, Amount: Amount, DiscPer: DiscPer, DiscAmount: DiscAmount, NetAmount: NetAmount, batchno: batchno, CGSAmount: CGSAmount, hdnItemid: hdnItemid,
                });
            });
            debugger;
            if (hasInvalidStock) {
                return;
            }
            debugger;
            var Parameters = {
                "Bill_ID": Bill_ID,
                "Patient_ID": Patient_ID,
                "CustomerName": CustomerName,
                "warehouse": warehouse,
                "TransType": TransType,
                "ReferBy": ReferBy,
                "Dept": Dept,
                "totalPayable": totalPayable,
                "DiscPercent": DiscPercent,
                "MasterDiscount": MasterDiscount,               
                "flatdisc": flatdisc,
                "AmntReceived": AmntReceived,
                "BalanceAmount": BalanceAmount,
                "linediscount": linediscount,
                "DiscAmnt": DiscAmnt,
                "Save_list": Save_list,
                "invNumber": invNumber
            };
            if (patId == undefined) {
                debugger;
                patId = 0;
            }
            PageMethods.SaveRecord(JSON.stringify(Parameters), Rbtn, UserId, patId, function (res) {
                debugger;
                var btnSave = $('#btnSave').val();
                if (btnSave == 'Save & Print(Alt+S)' || btnSave == "Save & Print(Alt+S)") {
                    window.open('../../ReportViewer.aspx?ReportName=PharmacySlip&ReportTitle=PharmacySlip&Bill_ID=' + JSON.parse(res));
                }
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Saved Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                window.location.href = 'IssueMedicine.aspx';
            });

        }

        function SaveData() {
            debugger;
            $('#SaveVal').attr('disabled', true);
            var userC = $('#txtuserCode').val();
            var userP = $('#txtpass').val();
            var userCode;
            var UserPass;
            var UserId;
            PageMethods.loadData(userC, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                if (data.length != 0) {
                    userCode = data[0].User_Code;
                    UserPass = data[0].Password;
                    UserId = data[0].UserID;
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid User',
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
                if (userC == userCode && userP == UserPass) {
                    debugger;
                    var Bill_ID = '';
                    Bill_ID = '<%= Request.QueryString["Bill_ID"]%>'
                    if (Bill_ID == '')
                        Bill_ID = 0
                    var Patient_ID = $('#hdPatientID').val();
                    if (Patient_ID == "" || Patient_ID == '') {
                        Patient_ID = "";
                    }
                    var CustomerName = $('#CustomerName').val();
                    var warehouse = $("#ddlWarehouse").val();
                    var TransType = $("#txtTransType").val();
                    var ReferBy = $('#ddlDoctor').val();
                    var Dept = $('#ddlDepartment').val();
                    var totalPayable = $('#txtTotalPayable').val();
                    var DiscPercent = $('#txtDisPer').val();
                    var MasterDiscount = $('#txtDisAmt').val();

                    var flatdisc = $('#txtFlatDisc').val();
                    if (flatdisc == "" || flatdisc == "visionplus") {
                        flatdisc = 0;
                    }
                    var AmntReceived = $('#txtAmountReceived').val();
                    var BalanceAmount = $('#txtBalances').val();
                    if (BalanceAmount == "") {
                        BalanceAmount = 0;
                    }
                    var linediscount = $('#txtLineDisc').val();
                    var DiscAmnt = $('#txttotalDisc').val();
                    if (DiscAmnt == '') {
                        DiscAmnt = 0.00;
                    }
                    var Rbtn = $('input[name="rbtn"]:checked').val();
                    var patId = out_Patient_Id;
                    var invNumber = $("#Inv_No").val();
                    var Save_list = [];
                    var hasInvalidStock = false;
                    var Save_list = [];

                    $.each($('#tblDetails tbody tr'), function (key, value) {
                        debugger;
                        
                        var ItemName = $($(value).find('td input[name=Itemdesc]')[0]).val();
                        var Qty = $($(value).find('td input[name=txtQty]')[0]).val();
                        var Stock = $($(value).find('td input[name=txtStock]')[0]).val();
                        var Amount = $($(value).find('td input[name=txtSalerate]')[0]).val();
                        var DiscPer = $($(value).find('td input[name=DisPer]')[0]).val();
                        var DiscAmount = $($(value).find('td input[name=DisAmount]')[0]).val();
                        var batchno = $($(value).find('td input[name=BatchNo]')[0]).val();
                        var expdate = $($(value).find('td input[name=exp_date]')[0]).val();
                        var CGSRate = $($(value).find('td input[name=txtCGSRate]')[0]).val();
                        var Itemid = $($(value).find('td input[name=ItemID]')[0]).val();
                        var hdnItemid = $($(value).find('td input[name=hdnItemID]')[0]).val();
                        var CGSAmount = CGSRate * Qty;
                       
                        if (batchno == null) {
                            batchno = '';
                        }

                        if (parseFloat(Stock) <= 0 && parseFloat(Qty) > 0) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Quantity must be greater than zero.',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            hasInvalidStock = true;
                            return false;
                        }
                        if (parseFloat(Qty) <= 0) {
                            alert('Quantity must be greater than zero.');
                            hasInvalidStock = true;
                            return false;
                        }
                        if (parseFloat(Stock) < parseFloat(Qty)) {
                            alert('Quantity must be less than or equal to stock.');

                            hasInvalidStock = true;
                            return false;
                        }
                        var NetAmount = $($(value).find('td')[11]).text();
                        Save_list.push({
                            Itemid: Itemid, ItemName: ItemName, Qty: Qty, Stock: Stock, Amount: Amount, DiscPer: DiscPer, DiscAmount: DiscAmount, NetAmount: NetAmount, batchno: batchno, CGSAmount: CGSAmount, hdnItemid: hdnItemid,
                        });
                    });
                    debugger;
                    if (hasInvalidStock) {
                        return;
                    }
                    debugger;
                    var Parameters = {
                        "Bill_ID": Bill_ID,
                        "Patient_ID": Patient_ID,
                        "CustomerName": CustomerName,
                        "warehouse": warehouse,
                        "TransType": TransType,
                        "ReferBy": ReferBy,
                        "Dept": Dept,
                        "totalPayable": totalPayable,
                        "DiscPercent": DiscPercent,
                        "MasterDiscount": MasterDiscount,
                        "flatdisc": flatdisc,
                        "AmntReceived": AmntReceived,
                        "BalanceAmount": BalanceAmount,
                        "linediscount": linediscount,
                        "DiscAmnt": DiscAmnt,
                        "Save_list": Save_list,
                        "invNumber": invNumber
                    };
                    if (patId == undefined) {
                        debugger;
                        patId = 0;
                    }
                    PageMethods.SaveRecord(JSON.stringify(Parameters), Rbtn, UserId, patId, function (res) {
                        debugger;
                        var btnSave = $('#btnSave').val();
                        if (btnSave == 'Save & Print(Alt+S)' || btnSave == "Save & Print(Alt+S)") {
                            window.open('../../ReportViewer.aspx?ReportName=PharmacySlip&ReportTitle=PharmacySlip&Bill_ID=' + JSON.parse(res));
                        }
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Saved Successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location.href = 'IssueMedicine.aspx';
                    });
                }
                else {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Invalid User',
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
            });
        }
        debugger;
        var out_Patient_Id;
        var MrNo;
        var ItemCode;
        var Opd_ID;
        var pat_id;
        function LoadTokenInputsDefaultMRNo() {
            debugger;

            $("#txtMRNo").tokenInput("../../json.aspx?Table=PatientsForPharmacy", {
                tokenLimit: 1,
                onAdd: function (item) {
                    debugger;
                    try {
                        pat_id = item.id;
                        /*  LoadPriscription();*/
                        out_Patient_Id = pat_id
                        getOPDID(pat_id);
                        getIPDID(pat_id);
                        getOPDandIPDNO(pat_id)

                    } catch (err) {
                        alert(err.message);
                    }
                }
            });
        }
        var opdId;
        function getOPDID(pat_id) {
            debugger;

            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/CheckOPDPatient",
                data: JSON.stringify({ patid: pat_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var opdId = response.d;

                    if (opdId && opdId !== "") {

                        //getitem_code(opdId);
                        $("#txtTransType").val('OPD Patient');

                    }
                    else {
                        console.log("? No active OPD visit for Pat_id:", pat_id);


                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX Error:", error);
                    alert("Failed to check OPD status.");
                }
            });
        }
        function GetPharmacyUser() {
            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/GetUserFromSysParams",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    debugger;
                    var data = JSON.parse(msg.d);
                    if (data == '001') {
                        SearchPop()
                    }
                    else {
                        SaveDataWithoutUser()
                    }

                },
                error: function (xhr, status, error) {
                    console.error("Error in getWardAndBed: ", error);
                }
            });
        }
        var blnceCondition;
        function BalanceAmountCondition() {
            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/GetBalanceAmountCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    debugger;
                    var data = JSON.parse(msg.d);
                    if (data == '01') {
                        blnceCondition = 'true'
                    }
                    else {
                        blnceCondition = 'false'
                        $('#divBalance').hide();
                        $('#txtAmountReceived').attr("disabled", true);


                    }

                },
           
            });
        }
        //function getIPDID(pat_id) {
        //    debugger;

        //    $.ajax({
        //        type: "POST",
        //        url: "IssueMedicine.aspx/CheckSehatCardPatient",
        //        data: JSON.stringify({ patid: pat_id }),
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        success: function (response) {
        //            debugger;
        //            var result = response.d;
        //            if (result === "10") {
        //                $("#txtTransType").val('IPD Sehat Patient');


        //            }

        //            else {
        //                $("#txtTransType").val('IPD Patient');

        //            }
        //        },
        //        error: function (xhr, status, error) {
        //            alert("Error: " + error);
        //        }
        //    });
        //}

        function getIPDID(pat_id) {
            debugger;

            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/CheckSehatCardPatient",
                data: JSON.stringify({ patid: pat_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var result = JSON.parse(response.d);
                    var discountType = result.DiscountType;
                    var typeName = result.TypeName;
                    if (discountType === "10" && typeName === "Sehat Sahulat Card") {
                        $("#txtTransType").val('IPD Sehat Patient');
                        $("#hdndiscountType").val(discountType);

                        $('#txtDisPer').attr("disabled", true);
                        $('#txtDisAmt').attr("disabled", true);
                        $('#txtFlatDisc').attr("disabled", true);
                        $('#txtAmountReceived').attr("disabled", true);
                    } else {
                        $("#txtTransType").val('IPD Patient');
                    }
                },
                error: function (xhr, status, error) {
                    alert("Error: " + error);
                }
            });
        }


        function GetPatientDetail() {
            debugger;
            var Patient_ID = $('#hdPatientID').val();
            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/LoadPatientDetails",
                data: "{'PatientID':" + Patient_ID + "}",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: OnSuccess,
                failure: function (response) {
                    alert(response.d);
                }
            });
        }
        function openQueue() {
            debugger;
            fillPendingPatientsLists();
            $('#queueModal').modal('show');
        }

        //function fillPendingPatientsLists() {
        //    PageMethods.PendingPatients(function (data) {
        //        debugger;
        //        var parsedData = JSON.parse(data);
        //        var rows = '';
        //        $.each(parsedData, function (key, value) {
        //            debugger;
        //            var TrnsDate = new Date(parseInt(value.Medicine_Date.substr(6)));
        //            var retdate = moment(TrnsDate).format('LLLL');
        //            var status = '';
        //            rows += '<tr> <td>' + value.mr_no_sequence + '</td> ' + '<td>' + value.Full_Name + '</td> ' + '<td>' + retdate + '</td> ' + ' <td> <a href="javascript:void(0)" onclick=hideModel(' + value.pat_id + ', \'' + value.mr_no_sequence + '\')><i class="fa fa-plus-circle fa-2x" ></i></a> </td> </tr>';
        //        });
        //        debugger;
        //        $('#tblPendingPatients tbody').html(rows);
        //        $(".se-pre-con").fadeOut("slow");

        //    }, function (exec) { })
        //}
        function fillPendingPatientsLists() {
            PageMethods.PendingPatients(function (data) {

                var parsedData = JSON.parse(data);
                var rows = '';

                $.each(parsedData, function (key, value) {

                    var TrnsDate = new Date(parseInt(value.Medicine_Date.substr(6)));
                    var retdate = moment(TrnsDate).format('LLLL');

                    rows += '<tr>' +
                        '<td>' + value.mr_no_sequence + '</td>' +
                        '<td>' + value.Full_Name + '</td>' +
                        '<td>' + retdate + '</td>' +
                        '<td>' +
                        '<a href="#" class="btnEdit" ' +
                        'data-patid="' + value.pat_id + '" ' +
                        'data-mrno="' + value.mr_no_sequence + '">' +
                        '<i class="fa fa-edit fa-2x"></i>' +
                        '</a>' +
                        '</td>' +
                        '</tr>';
                });

                $('#tblPendingPatients tbody').html(rows);
                $(".se-pre-con").fadeOut("slow");

            }, function (err) {
                console.log(err);
            });
        }

        debugger;
        function hideModel(pat_id, mr_no_sequence) {
            debugger;
            console.log(pat_id, mr_no_sequence);
            $('#queueModal').modal('hide');
            $('#token-input-txtMRNo').val(mr_no_sequence)
            getOPDandIPDNO(pat_id)

        }
        function OnSuccess(data) {
            debugger;
            if (data.d !== '') {
                $('#row22').show();
                $('#lblPatienName').text(ReplaceNullWith_Space(data.d.Name));
                $('#lblContactNo').text(ReplaceNullWith_Space(data.d.Mobile));
                $('#CustomerName').attr("disabled", true);
            }
        }

        function ReplaceNullWith_Space(Data) {
            if (Data == "null")
                return " ";
            else
                return Data;
        }
        debugger;
        var itemIds;
        function getitem_code() {
            debugger;
            var warehouse = $("#ddlWarehouse").val()
            if (warehouse == "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Warehouse First.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                $('#ddlPatient_No').val('0');
                return;
            }
            else {
                $('#ddlPatient_No').select2('close');
                var pat_Id = $('#ddlPatient_No').val();
                var PatNo = $('#ddlPatient_No option:selected').text();
                var parts = PatNo.split('-');
                var prefix = parts[0];
                var number = parts[1];


                var Pat_Id = pat_Id
                itemIds = [];
                if (prefix == 'OPD') {
                    $.ajax({
                        type: "post",
                        url: "IssueMedicine.aspx/GetItemCodesOPD",
                        data: JSON.stringify({
                            Pat_Id: Pat_Id
                        }),
                        dataType: 'JSON',
                        contentType: "application/json; charset=utf-8",
                        async: false,
                        success: function (msg) {
                            debugger;

                            var data = JSON.parse(msg.d);
                            var doctorId = data.DoctorInfo?.Doctor_ID || 0;
                            var department = data.DoctorInfo?.Patient_Main_Category || '';
                            $('#ddlDoctor').val(doctorId).trigger('change')
                            $('#ddlDepartment').val(department).trigger('change')
                            $('#ddlDoctor').attr('disabled', true);
                            $('#ddlDepartment').attr('disabled', true);
                            $.each(data.ItemCodes, function (index, value) {
                                debugger;
                                itemIds.push(value);
                            });
                        }
                    });
                }
                if (prefix == 'IPD') {
                    $.ajax({
                        type: "post",
                        url: "IssueMedicine.aspx/GetItemCodesIPD",
                        data: JSON.stringify({
                            "Pat_Id": Pat_Id,
                        }),
                        dataType: 'JSON',
                        contentType: "application/json; charset=utf-8",
                        async: false,
                        success: function (msg) {
                            debugger;
                            var data = JSON.parse(msg.d);
                            var doctorId = data.DoctorInfo?.Doctor || 0;
                            var department = data.DoctorInfo?.Department || '';
                            $('#ddlDoctor').val(doctorId).trigger('change')
                            
                            $('#ddlDepartment').val(department).trigger('change')
                            $('#ddlDoctor').attr('disabled', true);
                            $('#ddlDepartment').attr('disabled', true);
                            getWardAndBed(pat_Id)
                            debugger;
                            $.each(data.ItemCodes, function (key, value) {
                                debugger;
                                itemIds.push(value);

                            });
                        }
                    });

                }
                if (prefix == 'EMR') {
                    $.ajax({
                        type: "post",
                        url: "IssueMedicine.aspx/GetItemCodesEMR",
                        data: JSON.stringify({
                            "Pat_Id": Pat_Id,
                        }),
                        dataType: 'JSON',
                        contentType: "application/json; charset=utf-8",
                        async: false,
                        success: function (msg) {
                            debugger;
                            var data = JSON.parse(msg.d);
                            // getWardAndBed(pat_Id)
                            debugger;
                            $.each(data, function (key, value) {
                                debugger;
                                itemIds.push(value);

                            });
                        }
                    });

                }
                AddMedicineDetailFormOPD(itemIds)
            }
        }
        function getWardAndBed(pat_Id) {
            $.ajax({
                type: "POST",
                url: "IssueMedicine.aspx/GetWardAndBed",
                data: JSON.stringify({ Pat_Id: pat_Id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    debugger;

                    var data = JSON.parse(msg.d);

                    // Set values in fields
                    $('#Ward_Name').val(data.Ward_Name || "");
                    $('#BedName').val(data.Bed_No || "");
                    $('#txtPatientType').val(data.Patient_Discount_Type || "");
                },
                error: function (xhr, status, error) {
                    console.error("Error in getWardAndBed: ", error);
                }
            });
        }
        debugger;
        function AddMedicineDetailFormOPD(itemIds) {
            debugger;
            itemIds.forEach(function (itemCode) {
                debugger;
                var itemId = itemCode;
                var rowIndex = parseInt($('#tblDetails tbody tr').length);
                var rows;
                $.ajax({
                    type: "post",
                    url: "IssueMedicine.aspx/MedicineDetailgetfromOPD",
                    data: JSON.stringify({
                        "itemId": itemId,
                    }),
                    dataType: 'JSON',
                    contentType: "application/json; charset=utf-8",
                    async: false,
                    success: function (msg) {
                        var length = $("#tblDetails tr:gt(0)").length;
                        $('#Table_1 tr:gt(0)').remove();
                        var data = JSON.parse(msg.d);
                        
                        debugger;
                        var Uomqty = data[0].UOM_Qty;
                        if (Uomqty == null) {
                            Uomqty = 0;
                        } else {
                            Uomqty = data[0].UOM_Qty;
                        }
                        var SaleRate = data[0].Sale_Rate;
                        if (SaleRate == null) {
                            SaleRate = 0;
                        } else {
                            SaleRate = data[0].Sale_Rate;
                        }
                        var date = data[0].ExpiryDate
                        var discountBlock = data[0].Discount_Block;
                        var isDiscountDisabled = (discountBlock == 1 || discountBlock === true);
                        var warehouse = $("#ddlWarehouse").val()
                        var disDisabledAttr = isDiscountDisabled ? 'disabled' : '';
                        date = moment(date).format('D-MMM-YYYY');
                        rows =
                            '<tr><td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="ItemID" id="ItemID" > ' + data[0].Item_ID + '</td>' +
                            '<td> ' + (rowIndex + 1) + '</td>' +
                            '<td style="display:none;"><input type="hidden" value="' + data[0].Item_Code + '" name="ItemIDcode" id="ItemIDcode" > ' + data[0].Item_Code + '</td>' +
                            '<td><input type="hidden" value="' + data[0].Description + '" name="Itemdesc" id="Itemdesc" >' + data[0].Description + '</td>' +
                            '<td style="display:none"><input type="hidden" value="' + data[0].Unit + '" name="txtUom" id="txtUom" >' + data[0].Unit + '</td>' +
                            '<td><input type="hidden" value="' + Uomqty + '" name="UomQty" id="UomQty"  >' + Uomqty + '</td>' +
                            '<td><input type="text" name="txtQty" value="1" min="1" style="width: 62px !important;margin-left: -7px;position: absolute;height:22px;text-align: right;" class="height_height" onkeyup="CulculateAmonutWithQty(this)" autocomplete="off" onclick="this.select();" /></td>' +
                            '<td><input type="number" name="txtStock" id="txtStock' + (rowIndex + 1) + '" value="0" style="width: 73px !important;margin-left: -2px;position: absolute;height:22px;text-align: right;" class="height_height" readonly/></td>' +
                            '<td style="text-align: right;" ><input type="text" value="' + SaleRate + '" name="txtSalerate" id="txtSalerate' + (rowIndex + 1) + '" ></td>' +
                        '<td><input type="number" name="DisPer" value="0"' + disDisabledAttr + ' min="0" class="height_height orderchange" style="width: 95px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" onkeyup="CalculateSummarieDiscountPerWise(' + rowIndex + '),sumdiscount()" autocomplete="off" onclick="this.select();" /> </td>' +
                            '<td><input type="text" readonly name="DisAmount"' + disDisabledAttr + ' class="height_height orderchangeDiscount" value="" style="width: 103px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;"  /></td>' +
                            '<td style="text-align:Right;"></td>' +
                            '<td><select id="ddlbatch' + (rowIndex + 1) + '" name="ddlbatch" onchange="updateStock(this)" Tabindex="' + (12 + (rowIndex * 3)) + '"></select></td>' +
                            '<td style="display:none;"><input type="text"  id="txtCGSRate' + (rowIndex + 1) + '" value="' + data[0].CGSRate + '" name="txtCGSRate" class="" /> </td>' +
                            '<td><input type="text" disabled name="exp_date" id="exp_date' + (rowIndex + 1) + '" class=""  style="width: 103px !important;text-align: right;margin-left: -4px;position: absolute;height:22px;" /></td>' +
                            '<td style="display:none;"><input type="text" disabled id="BatchNo' + (rowIndex + 1) + '" name="BatchNo" class="" value="' + data[0].BatchNum + ' "/> </td>' +
                            '<td style="display:none;"><input type="text"  id="txtCGSAmount' + (rowIndex + 1) + '" name="txtCGSAmount" class="" value="0"/> </td>' +
                            '<td style="display:none;"><input type="hidden" value="' + data[0].Item_ID + '" name="hdnItemID" id="hdnItemID" > ' + data[0].Item_ID + '</td>' + 
                            '<td style="text-align: center;"><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="fa fa-trash-o" style="font-size:17px"></i></a> </td>' +
                            '</tr>';                            
                        $('#tblDetails tbody').append(rows);
                        //onkeyup = "CalculateSummarieDiscountAmountWise(' + rowIndex + ')"
                        PageMethods.GetBatchNumbers(itemId, warehouse, function (data) {
                            debugger;
                            var parsedData = JSON.parse(data);
                            var options = '<option value="0" >Please Select</option>';

                            $.each(parsedData, function (key, value) {
                                options += '<option value="' + value.BatchNum + '" >' + value.BatchNum + '</option>';
                            });
                            $('#ddlbatch' + (rowIndex + 1)).html(options);
                        }, function (error) {
                            alert(error.get_message());
                        });
                        setTimeout(function () {
                            $('#medName').select2('close');
                            $('input[name="txtQty"]').focus().select();
                        }, 5);
                        CalculateSummarieDiscountPerWise(rowIndex);
                    },
                    error: function (xhr, status, error) {
                        console.log("Error fetching medicine details: " + error);
                    }
                });
            });
        }
        function updateStock(anchors) {
            debugger;
            var row = $(anchors).closest('tr');
            var rowIndex = row.index();
            var hdndiscountType = $('#hdndiscountType').val();
            var warehouse = $('#ddlWarehouse').find('option:selected').val();
            debugger;
            var selectId = $(anchors).attr('id');
            var idParts = selectId.split('ddlbatch');
            if (idParts.length > 1) {
                var counter = idParts[1];
            } else {
                var counter = null;
            }
            var itemId = $(row).find('td:eq(0)').text().trim();
            var batchNumber = $(anchors).find('option:selected').text().trim();
            $.ajax({
                type: "post",
                url: "IssueMedicine.aspx/GetStockByBatch",
                data: JSON.stringify({
                    "itemId": itemId,
                    "hdndiscountType": hdndiscountType,
                    "batchNumber": batchNumber,
                    "warehouse": warehouse

                }),
                dataType: 'JSON',
                contentType: "application/json; charset=utf-8",
                async: false,
                success: function (stockMsg) {
                    debugger;
                    var stockData = JSON.parse(stockMsg.d);
                    var stock = stockData[0].Total_Stock || 0;
                    var rate = stockData[0].Sale_Rate || 0;
                    var CGSrate = stockData[0].CGSRate || 0;
                    var date = stockData[0].ExpiryDate;
                    var Mini_Stocks = stockData[0].Mini_stock;

                    if (stock <= Mini_Stocks) {
                        alert("Minimum Stock Alert");
                    }
                    date = moment(date).format('D-MMM-YYYY');
                    debugger;
                    console.log(rate)
                    $('#txtStock' + counter).val(stock);
                    $('#txtSalerate' + counter).val(rate);
                    //$(row).find('td:eq(8)').text(rate);
                    $(row).find('td:eq(11)').text(rate);
                    $('#exp_date' + counter).val(date);
                    $('#BatchNo' + counter).val(batchNumber);
                    $('#txtCGSRate' + counter).val(CGSrate);
                },
                error: function (xhr, status, error) {
                    console.log("Error fetching stock: " + error);
                }
            });
        }
        function SearchPop() {
            debugger;
            $('#SearchModel').modal({
                backdrop: 'static'
            });
            $('#txtuserCode').focus();
            $('#txtuserCode').val('');
            $('#SaveVal').attr('disabled', false);
            $('#lblUsername').text('');
            $('#txtpass').text('');

        }

        function LoadWarehouses() {
            var $dropdown = $('#ddlWarehouse');
            $dropdown.empty();

            PageMethods.GetUserWarehouses(
                function (response) {
                    if (response && Array.isArray(response)) {
                        if (response.length === 1) {
                            // Only one warehouse: skip "Please Select" and auto-select it
                            var item = response[0];
                            $dropdown.append('<option value="' + item.Value + '" selected="selected">' + item.Text + '</option>');
                            $("#ddlWarehouse").attr("disabled", true);
                        } else {
                            // Multiple or zero warehouses: show "Please Select"
                            $dropdown.append('<option value="0">Please Select</option>');
                            $.each(response, function (index, item) {
                                $dropdown.append(
                                    '<option value="' + item.Value + '">' +
                                    item.Text +
                                    '</option>'
                                );
                            });
                        }
                    } else {
                        // Handle case where response is not an array or is null
                        $dropdown.append('<option value="0">Please Select</option>');
                    }

                    // Reinitialize Select2 after populating
                    $dropdown.select2();
                },
                function (error) {
                    console.log('Error loading warehouses:', error);
                    // On error, default to "Please Select"
                    $dropdown.append('<option value="0">Please Select</option>');
                    $dropdown.select2();
                }
            );
        }


        function LoadWarehousesforSaleReturn() {
            var $dropdown = $('#ddl_Warehouse');
            $dropdown.empty();

            PageMethods.GetUserWarehouses(
                function (response) {
                    if (response && Array.isArray(response)) {
                        if (response.length === 1) {
                            // Only one warehouse: skip "Please Select" and auto-select it
                            var item = response[0];
                            $dropdown.append('<option value="' + item.Value + '" selected="selected">' + item.Text + '</option>');
                            $("#ddl_Warehouse").attr("disabled", true);
                        } else {
                            // Multiple or zero warehouses: show "Please Select"
                            $dropdown.append('<option value="0">Please Select</option>');
                            $.each(response, function (index, item) {
                                $dropdown.append(
                                    '<option value="' + item.Value + '">' +
                                    item.Text +
                                    '</option>'
                                );
                            });
                        }
                    } else {
                        // Handle case where response is not an array or is null
                        $dropdown.append('<option value="0">Please Select</option>');
                    }

                    // Reinitialize Select2 after populating
                    $dropdown.select2();
                },
                function (error) {
                    console.log('Error loading warehouses:', error);
                    // On error, default to "Please Select"
                    $dropdown.append('<option value="0">Please Select</option>');
                    $dropdown.select2();
                }
            );
        }
        debugger;
        function DisableWareHouse() {
            debugger;

            var mro = $("#txtMRNo").val();

            if (!mro) {   // handles "", null, undefined
                getbatchfrom_grn();
            }

            $("#ddlWarehouse").prop('disabled', true);
        }


        
         function LoadPatientNo() 
        {
              var optionpat = '';
              PageMethods.AllPharmaPatients(function (Tests) {
                  optionpat = '<option value="0">Please Select</option>';
                  $.each(JSON.parse(Tests), function (key, value) {
                      optionpat += '<option value="' + value.id + '" >' + value.mr_no_sequence + '</option>';
                  });
                  $('#ddlpat_no').html(optionpat);
                  $('#ddlpat_no').select2();
              });
         }
         function getInvoiceNo_PatWise() 
         {
             
            var reg_id = $('#ddlpat_no').val();

            if (reg_id == "" || reg_id == null) {
              //  alert("Please select a patient");
               // return;
            }

                $.ajax({
                    type: "POST",
                    url: "IssueMedicine.aspx/GetInvoiceNoByPatient",
                    data: JSON.stringify({ reg_id: parseInt(reg_id) }),  // Ensure it's an integer
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        console.log("Response:", response.d);  // Check this in console

                        // Clear existing options
                        $('#ddlInvoiceNumber').empty();
                        $('#ddlInvoiceNumber').append('<option value="">--Select Invoice--</option>');

                        // Populate invoice dropdown
                        if (response.d && response.d.length > 0) {
                            $.each(response.d, function (index, item) {
                                console.log("Item:", item);  // Debug: check property names
                                $('#ddlInvoiceNumber').append(
                                    '<option value="' + item.bill_id + '">' + 
                                    item.Seq_InvoiceNo + '</option>'
                                );
                            });
                        } else {
                            $('#ddlInvoiceNumber').append('<option value="">No Invoices Found</option>');
                        }
                    },
                    error: function (xhr, status, error) {
                       // console.error("AJAX Error:", error);
                        //console.error("Response Text:", xhr.responseText);
                        //alert("Error loading invoices: " + error);
                    }
                });
            }



    </script>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row d-flex align-items-stretch">
        <!-- Left Section -->
        <div class="col-lg-9 col-md-12">
            <!-- Patient Details -->
            <div class="row mb-3" style="display: none;">
                <div class="col-12 col-sm-6 col-md-4">
                    <label>Patient Name:</label>
                    <label id="lblPatienName"></label>
                </div>
                <div class="col-12 col-sm-6 col-md-4">
                    <label>Contact:</label>
                    <label id="lblContactNo"></label>
                </div>
            </div>

            <!-- Input Fields -->
            <div class="row mb-3">
                <div class="col-sm-12 col-md-4 col-lg-3">
                    <label>MR No:</label>
                    <input type="hidden" id="hdPatientID" />
                    <input type="hidden" id="hdndiscountType" />
                    <input type="text" id="txtMRNo" tabindex="1" class="form-control" />
                    <input type="text" id="txtTransType" style="display: none" tabindex="1" class="form-control" />
                </div>
                <div class="col-sm-12 col-md-4 col-lg-3">
                    <label id="LblCustomerName">Walk-in Customer:</label>
                    <input type="text" id="CustomerName" tabindex="2" autocomplete="off" class="form-control" />
                </div>
                <div class="col-sm-12 col-md-4 col-lg-3">
                    <label>Referred By:</label>
                    <select class="form-control" tabindex="3" id="ddlDoctor">
                        <option></option>
                    </select>
                </div>
                <div class="col-sm-6 col-md-4 col-lg-3">
                    <label id="lblDepartment">Department:</label>
                    <select class="form-control depName" tabindex="4" id="ddlDepartment">
                        <option></option>
                    </select>
                </div>
            </div>
            <div class="row mb-3">
                <div class="col-sm-12 col-md-4 col-lg-2">
                    <label>Patient NO</label>
                    <select class="form-control depName" tabindex="4" id="ddlPatient_No" onchange="getitem_code();">
                        <option></option>
                    </select>

                </div>
                <div class="col-sm-12 col-md-4 col-lg-1">
                    <label></label>
                    <input type="button" class="btn-primry" onclick="Print_Prescription()" value="Print" />

                </div>
                <div class="col-sm-12 col-md-4 col-lg-3">
                    <label id="LblPatientType">Patient Type</label>
                    <input type="text" id="txtPatientType" tabindex="2" autocomplete="off" class="form-control" />
                </div>
                <div class="col-sm-12 col-md-4 col-lg-3">
                    <label id="LblWard">Ward Name</label>
                    <input type="text" id="Ward_Name" tabindex="2" autocomplete="off" class="form-control" />
                </div>

                <div class="col-sm-6 col-md-4 col-lg-3">
                    <label id="lblBed">Bed No:</label>
                    <input type="text" id="BedName" tabindex="2" autocomplete="off" class="form-control" />
                </div>
            </div>

            <!-- OPD Prescription & Batch -->
            <div class="row mb-3">
                <div class="col-lg-3 col-md-7 col-sm-6">
                    <label id="lblmedName">Medicine:</label>
                    <label class="small">(Alt+Q)</label>
                    <select id="medName" class="form-control" tabindex="6" onchange="getbatchfrom_grn()">
                        <option></option>
                    </select>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label>WareHouse</label>
                    <select id="ddlWarehouse" class="form-select" onchange="DisableWareHouse()">
                        <option value="0">Please Select</option>
                        <!-- other options -->
                    </select>
                </div>

                <div class="col-lg-2 col-md-4 col-sm-6">
                    <label class="batchdiv">Batch No:</label>
                    <select id="batchno" class="form-control batchdiv" tabindex="7" onchange="AddMedicineDetail()"></select>
                </div>

                <div class="col-lg-1 col-sm-3 col-md-1 text-center" style="margin-top: 2%;">
                    <label id="lblbatch">Batch</label>
                </div>
                <div class="col-lg-1 col-sm-3 col-md-1 text-center" style="margin-top: 2%; margin-left: -5%;">
                    <input type="checkbox" id="chkbatch" tabindex="8" onchange="loadmed();" />
                </div>
                <div class="col-sm-2 col-md-2 col-lg-1 text-center" style="margin-top: 2%;">
                    <label class="me-3">Print</label>
                </div>
                <div class="col-sm-2 col-md-2 col-lg-1 text-center" style="margin-top: 2%; margin-left: -4%;">
                    <input type="checkbox" tabindex="9" id="chkprint" />
                </div>
                <div class="col-sm-2 col-md-2 col-lg-2" style="margin-top: 2%">
                    <input type="button" class="btn btn-primry" id="btnSave" tabindex="10" value="Save & Print(Alt+S)" onclick="GetPharmacyUser()" />
                </div>
            </div>



            <!-- Checkboxes and Radio Buttons -->
            <div class="row mb-3 align-items-center" style="margin-top: 1%; margin-bottom: 1%">
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <input type="radio" name="rbtn" id="chkcash" tabindex="11" value="rbtncash" checked />
                </div>
                <div class="col-lg-1 col-sm-6 col-md-4 margin">
                    <label for="lblcash">Cash</label>
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <input type="radio" name="rbtn" tabindex="12" id="chkBank" value="rbtnbank" />
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6 margin">
                    <label for="lblbank">Card</label>
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <input type="radio" name="rbtn" tabindex="13" id="chkHospital" value="rbtnHospital" />
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6 margin">
                    <label for="lblPanel">Panel</label>
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6">
                    <input type="checkbox" tabindex="14" onchange="OnHoldBill()" id="chkHold" />
                </div>
                <div class="col-lg-1 col-md-4 col-sm-6 margin">
                    <label id="lblHold">Hold</label>
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" tabindex="15" title="Sale Return" class="btn btn-primry" value="Sale Return" id="btnSaleReturn" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn-primry" value="Queue" id="Queue" onclick="openQueue()" />
                </div>
            </div>

        </div>

        <!-- Right Section -->
        <div class="col-lg-3 col-md-12 d-flex flex-column" style="border: 1px solid; border-radius: 10px; padding: 9px">
            <div id="dvSummary" class="border p-3 rounded h-100">
                <!-- Total Payable -->
                <div class="row mb-2 align-items-center left-right-margin">
                    <div class="col-lg-6">
                        <label>Total Payable</label>
                        <input type="text" id="txtTotalPayable" tabindex="16" class="form-control text-end text-danger" disabled />
                    </div>
                    <div class="col-lg-6 col-md-6 col-sm-12">
                        <label>Line Discount</label>
                        <input type="text" id="txtLineDisc" tabindex="17" onkeyup="sumdiscount();" autocomplete="off" class="form-control me-2" onkeypress='return event.charCode >= 48 && event.charCode <= 57' readonly="readonly" />
                    </div>

                </div>
                <div class="row mb-2 align-items-center left-right-margin">
                    <div class="col-lg-6">
                        <label>Disc %</label>

                        <input type="text" tabindex="18" id="txtDisPer" class="form-control me-2" onkeyup="CalculateSummariesMasterDiscount(false),sumdiscount()" />
                    </div>
                    <div class="col-lg-6 col-md-6 col-sm-12">
                        <label>Disc (Alt+D)</label>
                        <input type="text" id="txtDisAmt" tabindex="19" class="form-control ms-2" onkeyup="CalculateSummariesMasterDiscount(true),sumdiscount()" />

                    </div>

                </div>
                <div class="row mb-2 align-items-center left-right-margin">
                    <div class="col-lg-6">
                        <label>Total Discount</label>
                        <input type="text" id="txttotalDisc" tabindex="20" class="form-control text-end" readonly="readonly" />
                    </div>
                    <div class="col-lg-6 col-md-6 col-sm-12">
                        <label>Adjustment (Alt+A)</label>
                        <input type="text" id="txtFlatDisc" tabindex="21" value="0" class="form-control text-end" onkeyup="adjustment()" />
                    </div>

                </div>
                <!-- Amount Received -->
                <div class="row mb-2 align-items-center  left-right-margin">
                    <div class="col-lg-6">
                        <label>Amount Received</label>
                        <input type="text" id="txtAmountReceived" tabindex="20" class="form-control text-end" onkeyup="CountBalance()" />
                    </div>
                    <div class="col-lg-6 d-flex align-items-center" id="divBalance">
                        <label class="ms-3">Balance</label>
                        <input type="text" id="txtBalances" tabindex="22" class="form-control text-end text-primary" disabled />
                    </div>
                </div>

            </div>
        </div>
    </div>

    <div class="table-responsive">
        <table class="table table-bordered table-striped" id="tblDetails">
            <thead>
                <tr>
                    <th style="width: 32px; text-align: left;">Sr. </th>
                    <th style="text-align: left; width: 220px;">Description </th>
                    <th style="text-align: left; width: 43px;">Pack Qty </th>
                    <th style="width: 25px; text-align: left;">Qty </th>
                    <th style="width: 25px; text-align: left;">Stock</th>
                    <th style="width: 60px; text-align: right;">Rate </th>
                    <th style="width: 60px; text-align: left;">Dis % </th>
                    <th style="width: 60px; text-align: left;">Dis Amount </th>
                    <th style="width: 60px; text-align: left;">Net Amount </th>
                    <th style="width: 60px; text-align: left;">BatchNo</th>
                    <th style="width: 70px; text-align: left;">Expiry Date </th>
                    <th style="width: 53px; text-align: left;">Action </th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>


    <div id="SearchModel" class="modal fade-in" role="dialog">
        <div class="modal-dialog">
            <div class="modal-content" style="width: 345px; margin-left: 80px; margin-top: 317px; height: 200px;">
                <div class="modal-header">
                    <h2 class="modal-title">Login</h2>
                </div>

                <div class="modal-body" style="background-color: white">
                    <input type="text" id="Inv_No" style="margin-left: 0px !important;" placeholder="Invoice Number" />
                    <input type="button" id="btnpreview" value="Preview" onclick=" Invoice()" style="width: 30% !important; margin-left: 69%;" class="btn btn-primry" />
                    <input type="text" id="txtuserCode" placeholder="UserCode" style="margin-top: 5px" autocomplete="off" />
                    <label id="lblUsername"></label>
                    <input type="password" id="txtpass" placeholder="Password" style="margin-left: 0px;" autocomplete="off" />
                </div>

                <div class="modal-footer">
                    <input type="button" id="SaveVal" class="btn btn-primry" onclick="SaveData()" value="Save" style="width: 30% !important;" />
                    <input type="button" id="CloseSearchModel" class="btn-gray" value="Close" data-dismiss="modal" style="width: 30% !important;" />
                </div>
            </div>
        </div>
    </div>

    <%--Patient Que Start--%>
    <div id="queueModal" class="modal fade scrollable-modal" data-backdrop="static" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable" role="document">
            <div class="modal-content">
                <div class="modal-body">
                    <div id="QueueList">
                        <div class="row" style="margin-bottom: 15px">

                            <div class="col-lg-2 text-end">
                                <a onclick="fillPendingPatientsList()">
                                    <i class="fa fa-refresh fa-2x"></i>
                                </a>
                            </div>

                        </div>


                        <div class="table-responsive previewTable">
                            <table class="table table-bordered table-custom" id="tblPendingPatients" style="overflow: auto;">
                                <thead id="ihead">
                                    <tr>
                                        <th>MR No</th>
                                        <th>Patient Name</th>
                                        <th style="width: 173px;">Created Time</th>
                                        <th>Select</th>
                                    </tr>
                                </thead>
                                <tbody id="ibody">
                                </tbody>
                            </table>

                        </div>
                    </div>


                </div>
                <div class="modal-footer">

                    <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>
    </div>


    <%--Patient Que Ends--%>
    <!-- Modal Sale Return -->
    <div id="SaleReturnModal" class="modal fade" role="dialog">
        <!-- Updated: Changed to modal-xl and forced width to 95% -->
        <div class="modal-dialog modal-xl" role="document" style="width: 95% !important; max-width: 65% !important;">
            <div class="modal-content">
                <div class="modal-header">
                    <h1 class="modal-title">Sale Return</h1>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="form-row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label>Mr No</label>
                            <select id="ddlpat_no" onchange="getInvoiceNo_PatWise();"></select>

                        </div>
                        <div class="form-group col-lg-2 col-md-2 col-sm-3">
                            <label for="ddlInvoiceNumber">Invoice #</label>
                            <select id="ddlInvoiceNumber" style="width: 180px !important;" onchange="AddSaleReturnInvoiceMaster()" class="form-control select2"></select>
                        </div>

                        <div class="form-group col-lg-2 col-md-5 col-sm-3">
                            <label for="ddlSaleReturnItems">Items</label>
                            <select id="ddlSaleReturnItems" onchange="AddSaleReturnMedicineDetail()" style="width: 380px !important;" class="form-control select2"></select>
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <label>WareHouse</label>
                            <select id="ddl_Warehouse" class="form-select" onchange="DisableWareHouse()">
                                <option value="0">Please Select</option>
                                <!-- other options -->
                            </select>
                        </div>

                        <%--<div class="form-group col-lg-1 col-md-2 col-sm-0"></div>--%>

                        <div class="form-group col-lg-4 col-md-3 col-sm-6">
                            <table style="width: auto !important">
                                <tr>
                                    <td style="font-size: 13px; font-weight: bold">Total Payable:</td>
                                    <td>
                                        <input type="text" id="txtSaleReturnTotalPayable" style="width: 211px!important; height: 25px; text-align: right; font-size: 22px; color: #cd1818 !important;" readonly="readonly" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="font-size: 13px; font-weight: bold">Total Line Disc :</td>
                                    <td>
                                        <input type="text" id="txtSaleReturnLineDisc" style="width: 211px !important; height: 25px; text-align: right; font-size: 22px; margin-top: -3px;" readonly="readonly" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="font-size: 13px; font-weight: bold">Disc :  </td>
                                    <td>
                                        <input type="text" id="txtSaleReturnDisPer" onkeyup="CalCulateReturnDisc()" readonly="readonly" style="width: 73px !important; height: 25px; text-align: right; font-size: 22px; margin-top: -3px;" />
                                        &nbsp;%
                                        <input type="text" id="txtSaleReturnDisAmt" readonly="readonly" style="width: 116px !important; height: 25px; text-align: right; font-size: 22px; margin-top: -3px;" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="font-size: 13px; font-weight: bold">Adjustment :</td>
                                    <td>
                                        <input type="text" id="txtSaleReturnFlatDisc" onkeyup="CalculateSaleReturnAdj()" style="width: 211px !important; height: 25px; text-align: right; font-size: 22px; margin-top: -3px;" autocomplete="off" />
                                    </td>
                                </tr>
                                <tr>
                                    <td style="font-size: 13px; font-weight: bold">Total:  </td>
                                    <td>
                                        <input type="text" id="txtSaleReturnTotal" style="width: 211px !important; height: 25px; text-align: right; font-size: 22px; margin-top: -3px;" readonly="readonly" />
                                    </td>
                                </tr>
                            </table>
                        </div>
                    </div>
                    <table id="saleReturnTable" class="table table-bordered table-responsive-lg table-responsive-md">
                        <thead>
                            <tr>
                                <th style="width: 5%;">Sr.</th>
                                <th style="display: none; width: 0%">Billing Detail ID</th>
                                <th style="width: 25%;">Description</th>
                                <th style="display: none; width: 0%">Check Qty</th>
                                <th style="width: 10%;">Qty</th>
                                <th style="width: 10%;">Stock</th>
                                <th style="width: 7%;">Rate</th>
                                <th style="width: 7%;">Dis%</th>
                                <th style="width: 13%;">Dis Amount</th>
                                <th style="width: 13%;">Net Amount</th>
                                <th style="width: 15%;">Batch_No</th>
                                <th style="width: 10%;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="saleReturnTableBody">
                        </tbody>
                    </table>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-primry" id="SSearchReturnPop" onclick="SearchReturnPop()">Save & Print</button>
                    <%--<input type="button" class="btn btn-primry" id="SSearchReturnPop" onclick="SearchReturnPop()" value="Save & Print" style="width: 110px;" />--%>
                    <button type="button" class="btn btn-primry" onclick="RefreshSaleReturnModal()">Refresh</button>
                    <button type="button" class="btn btn-primry" data-dismiss="modal">Close</button>
                </div>
            </div>
        </div>

        <div id="SearchReturnModel" data-backdrop="static" class="modal fade-in" role="dialog">
            <div class="modal-dialog">
                <div class="modal-content" style="width: 345px; margin-left: 80px; margin-top: 317px; height: 200px;">
                    <div class="modal-header">
                        <h2 class="modal-title">Login</h2>

                    </div>
                    <div class="modal-body">
                        <input type="text" id="txtReturnuserCode" placeholder="UserCode" style="margin-left: 0;" autocomplete="off" />
                        <label id="lblReturnUsername"></label>
                        <input type="password" id="txtReturnpass" placeholder="Password" style="margin-left: 0;" autocomplete="off" />
                    </div>
                    <div class="modal-footer">

                        <input type="button" class="btn btn-primry" id="btnSaveSaleReturn" onclick="SaveSaleReturn()" value="Save" style="width: 30% !important;" />
                        <input type="button" class="btn-gray" id="CloseSearchReturnModel" value="Close" data-dismiss="modal" style="width: 30% !important;" />
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
