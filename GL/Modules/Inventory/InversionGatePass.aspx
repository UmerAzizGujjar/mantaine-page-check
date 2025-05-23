<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InversionGatePass.aspx.cs" Inherits="PMS.Inventory.InversionGatePass" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/IITH_Theme/css/CustomCss/IGP.css" rel="stylesheet" />
    <script type="text/javascript">
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
                debugger;
                SaveAllRecord();
            });
            $('select').select2();
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
            debugger;
            $.ajax({
                type: "POST",
                url: "InversionGatePass.aspx/UserEntryRights",
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


        debugger;
        function LoadIGPData(IGP_ID) {
            debugger;
            PageMethods.LoadIGPHeaderDetail(IGP_ID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var TrnsDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data.Igp_date.substring(6, 19))));
                $('#IGP_Num').val(data.Igp_num);
                $('#txtDate').val(TrnsDate);
                setTimeout(function () {
                    $('#ddlVendor').val(data.Vendor).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlInv_Org').val(data.InvOrgId).trigger('change');
                }, 1000);
                debugger;
                $('#DriverName').val(data.DriverName);
                $('#txtVehiclenum').val(data.VehicleNum);
                $('#txtBility_No').val(data.BilityNum);
                $('#txtRemarks').val(data.Remarks);
                $('#txtStatus').val(data.Status);
                $('#txtStatusInspec').val(data.Inspec_Status);
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
                    debugger;
                    UserUnApproveButtonRights();
                    $('#btnSave').attr("disabled", 'disabled');
                    $('#btnSave').hide();
                }
                if (status == "Created" || status == "Pending") {
                    debugger;
                    $('#btnPrintInspec').hide();
                    $('#btnPrintInspec').attr("disabled", 'disabled');
                    $('#btnInspec').hide();
                    $('#btnInspec').attr("disabled", 'disabled');
                    $('#btnUnInspec').hide();
                    $('#btnUnInspec').attr("disabled", 'disabled');
                    $('#btnSave').attr("disabled", false);
                    $('#btnSave').show();
                }
                $('#ddlVendor').attr("disabled", 'disabled');
                getPONumByVendor(data.Vendor);
                LoadIGPDetail(IGP_ID);
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
                debugger;
                var data = (JSON.parse(resp));
                var rows = '';
                var ExpiryDate = '';
                var MfgDate = '';
                var datetime = '';
                selectedOptions = data;
                $.each(data, function (key, value) {
                    debugger;
                    $('#ddlPONo').val(value.PO_ID);
                    if (data[key].Delivery_Date != null) {
                        datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Delivery_Date.substring(6, 19))));
                    }
                    debugger;
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
                    var test_array = $('#tblItemDescription').find('input[name=txtItemCode][value=' + value.itemcode + ']');
                    if (test_array.length > 0) {
                        alert('This Item already added!');
                        $('#ctl00_MainContent_txtPRNo').tokenInput("clear");
                        return false;
                    }
                    else {
                        debugger;
                        rows += '<tr>' +
                            '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtPODetailId' + (key + 1) + '" name="txtPODetailId" value="' + value.PO_Item_ID + '" style="width:50px !important;text-align:right" />' + (key + 1) + '</td>' +
                            '<td align="right !important" style="padding-right: 3px!important;"><input type="hidden" name="txtPONO" id="txtPONO' + (key + 1) + '"  value="' + value.PO_No + '"  style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/>' + value.PO_No + '</td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + (key + 1) + '"  value="' + value.Item_Code + '"  style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                            '<td style="padding-left: 3px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '"  value="' + value.Description + '" style="width:50px !important;text-align:left;font-size:9px;height:10px;!important"/> ' + value.Description + ' </td>' +
                            '<td style="padding-left: 3px!important;"><input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '"  value="' + value.Unit_ID + '" />' + value.UOM + ' </td>' +
                            '<td><input type="text" name="BatchNo" id="BatchNo' + rowlength + '"  value="' + value.BatchNum + '" style="width:50px !important;text-align:left;font-size:9px;height:21px !important;" onkeyup="BatchValidation(this)"/></td>' +
                            '<td><input type="text" style="width:65px !important;text-align:center;font-size:9px;height:21px !important;" name="txtdeliverydate" id="txtdeliverydate' + (key + 1) + '"  value="' + datetime + '" readonly="readonly" /></td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" value="' + value.POQty + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important;  id="POQty' + (key + 1) + '" name="POQty" style="width:50px !important;"></input>' + value.POQty + '</td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;" value="' + value.Received_Qty + '"  id="RcvQty' + (key + 1) + '" name="RcvQty" ></input>' + value.Received_Qty + '</td>' +
                            '<td style="padding-right: 3px!important;" style="text-align:right"><input type="hidden" value="' + value.Balance + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important;"  id="blncQty' + (key + 1) + '" name="blncQty" ></input>' + value.Balance + '</td>' +
                            '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height: 21px !important;position: relative;" value="' + value.IGPQty + '"  id="IgpQty' + (key + 1) + '" name="IgpQty"></input></td>' +

                            '<td style="padding-right: 3px!important;"><input type="hidden" value="' + value.InspecQty + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important;  id="InspQty' + (key + 1) + '" name="InspQty" style="width:50px !important;"></input>' + value.InspecQty + '</td>' +

                            '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:21px !important;position: relative;" value="' + value.BounusQty + '" autocomplete="off" id="BounusQty' + (key + 1) + '" name="BounusQty"></input></td>' +


                            '<td><input type="text" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="txtMfgdate" id="txtMfgdate' + rowlength + '"  value="' + MfgDate + '" readonly="readonly"/></td>' +
                            '<td><input type="text" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="Expdate" id="Expdate' + rowlength + '"  value="' + ExpiryDate + '" readonly="readonly"/></td>' +
                            '<td style="display:none"><input type="hidden" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="Isbatch" id="Isbatch' + rowlength + '" value="' + value.IsBatch + '" readonly="readonly"/></td>' +
                            '<td style="display:none;width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:21px !important;position: relative;" value="0"  id="RejQty' + rowlength + '" name="RejQty"></input></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px;color: #f30a0a;position:relative;" i=""></i></a></td>' +
                            '</tr>';
                    }
                });
                $('#tblItemDescription tbody').html(rows);
                BatchValidation2();
                $('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                $('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
                $.each(selectedOptions, function (key, value) {
                    debugger;
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
            debugger;
            var _this = $(row).closest('tr')[0];
            var batch = $(_this).find('td input[name="Isbatch"]').val();
            var batch_no = $(_this).find('td input[name="BatchNo"]').val();
            if (batch == "false" || batch == 'null' || batch == null) {
                if (batch_no != "") {
                    alert("Please enable Batch checkbox from item form");
                    $(_this).find('td input[name=BatchNo]').val('');
                    $(_this).find('td input[name=BatchNo]').prop('readonly', true);
                }
            }
        }
        function BatchValidation2() {
            debugger;
            $.each($('#tblItemDescription tbody tr'), function (key, value) {
                debugger;
                var batch = $($(value).find('td input[name=Isbatch]')[0]).val();
                debugger;
                if (batch == "false" || batch == 'null' || batch == null) {
                    debugger;
                    $($(value).find('td input[name=BatchNo]')[0]).prop('readonly', true);
                    $($(value).find('td input[name=txtMfgdate]')[0]).attr('disabled', true);
                    $($(value).find('td input[name=Expdate]')[0]).attr('disabled', true);
                }
            });
            disablepo();
        }
        function validateSave() {
            debugger
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
                alert("Please Add items");
                proceed = false;
            }
            else {
                $('#tblItemDescription').removeClass('ErrorAlert');
            }
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                debugger
                $.each($('#tblItemDescription tbody tr'), function (key, value) {
                    debugger
                    var GRNdate = new Date(date).setHours(0, 0, 0, 0);
                    var ExpDateValue = $($(value).find('td input[name=Expdate]')[0]).val();
                    var MfgDateValue = $($(value).find('td input[name=txtMfgdate]')[0]).val();
                    var ExpDate = ExpDateValue ? new Date(ExpDateValue).setHours(0, 0, 0, 0) : null;
                    var MfgDate = MfgDateValue ? new Date(MfgDateValue).setHours(0, 0, 0, 0) : null;
                    var BatchNo = $($(value).find('td input[name=BatchNo]')[0]).val();
                    var Isbatch = $($(value).find('td input[name=Isbatch]')[0]).val();
                    var item_code = $($(value).find('td input[name=txtItemCode]')[0]).val();
                    var igpQTy = parseFloat($($(value).find('td input[name=IgpQty]')[0]).val()) || 0;
                    var poQty = parseFloat($(value).find('input[name="POQty"]').val()) || 0;


                    if (igpQTy <= 0) {
                        proceed = false;
                        alert("IGP Quantity must be greater then 0");
                    }
                    if (igpQTy == "") {
                        proceed = false;
                        alert("Please Enter Igp Quantity");
                    }
                    if (igpQTy > poQty) {
                        proceed = false;
                        alert("IGP Quantity must be less then or Equal to PO Quantity");
                    }
                    debugger;
                    if (Isbatch == "true") {
                        if (BatchNo == "") {
                            proceed = false;
                            alert("Please Enter Batch No");
                        }
                        if (!MfgDate) {
                            proceed = false;
                            alert("Please Enter Mfg Date");
                        }
                        if (!ExpDate) {
                            proceed = false;
                            alert("Please Enter Expiry Date");
                        }
                        if (ExpDate && GRNdate > ExpDate) {
                            proceed = false;
                            alert("Exp Date must not be less than GRN date");
                        }
                    }
                    if (Isbatch == "false" || Isbatch == 'null' || Isbatch == null) {
                        debugger;
                        if (BatchNo != "") {
                            alert("Batch is false,You can't enter batch number against Item Code " + item_code + ",Please check batch to true in items");
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
            debugger;
            if (validateSave()) {
                debugger
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
                var table = $('#tblItemDescriptionDetail');
                debugger;
                var Item_list = [];
                debugger;
                table.find('tr').each(function (key, value) {
                    debugger;
                    Item_list.push({ 'PODetailId': $(value).find('td input[name=txtPODetailId]').val(), 'ItemCode': $(value).find('td input[name=txtItemCode]').val(), 'RcvQty': $(value).find('td input[name=RcvQty]').val(), 'POQty': $(value).find('td input[name=POQty]').val(), 'BatchNo': $(value).find('td input[name=BatchNo]').val(), 'BlncQty': $(value).find('td input[name=blncQty]').val(), 'IgpQty': $(value).find('td input[name=IgpQty]').val(), 'InspecQty': $(value).find('td input[name=InspQty]').val(), 'BounusQty': $(value).find('td input[name=BounusQty]').val(), 'Mfgdate': $(value).find('td input[name=txtMfgdate]').val(), 'Expdate': $(value).find('td input[name=Expdate]').val(), });
                });
                var AllItemDetail = { 'Igp_num': IgpNo, 'Date': date, 'Vendor': Vendor, 'DriverName': DriverName, 'VehicleNum': VehicleNum, 'BilityNum': Bility_No, 'remarks': Remarks, 'InvOrg': InvOrg, 'ItemList': Item_list };
                PageMethods.SaveIgpDetail(btnSave, JSON.stringify(AllItemDetail), function (res) {
                    debugger;
                    alert('Data Save Successfully');
                    sendFile(res);
                    $('#btnSave').val("Update");
                    window.location = "InversionGatePass.aspx?IGP_ID=" + res;
                    $('#btnSave').val("Update");
                });
            }
        }
        function sendFile(ID) {
            debugger;
            var fileInput = $('#fileUpload1')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#fileUpload1')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../UploadIGP.ashx',
                    data: data,
                    success: function (status) {
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert("Whoops something went wrong!");
                    }
                });
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
        debugger;
        function getPONumByVendor(item) {
            debugger;
            var optionsPO = '';
            var VendorId;
            VendorId = item.value;
            if (typeof VendorId == "undefined" || VendorId == "") {
                VendorId = item;
            }
            PageMethods.GetPONoByVendor(VendorId, function (res) {
                var item = JSON.parse(res);
                optionsPO = '<option value="0">Please Select</option>';
                $.each(item, function (key, value) {
                    optionsPO += '<option value="' + value.PO_ID + '" >' + value.PO_No + '</option>';
                });
                $("#ddlPONo option").remove();
                $('#ddlPONo').html(optionsPO);
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
                    var iteration = 0;
                    var datetime = '';
                    $.each(item, function (key, value) {
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

                        if (item[key].Delivery_Date != null) {
                            datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(item[key].Delivery_Date.substring(6, 19))));
                        }
                        iteration++;
                        var rowlength = (document.getElementById("tblItemDescription").rows.length + iteration) - 1;
                        rows += '<tr>' +
                            '<td style=" border: 1px solid #D9E4E6;"><input type="hidden" id="txtPODetailId' + rowlength + '" name="txtPODetailId" value="' + value.PO_Item_ID + '" style="width:50px !important;text-align:right" />' + rowlength + '</td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" name="txtPONO" id="txtPONO' + rowlength + '" value="" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/>' + PONum + '</td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" name="txtItemCode" id="txtItemCode' + rowlength + '" value="' + value.Item_Code + '" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"/> ' + value.Item_Code + ' </td>' +
                            '<td style="padding-left: 3px!important;"><input type="hidden" name="txtItemName" id="txtItemName' + rowlength + '" value="' + value.Description + '" style="width:50px !important;text-align:left;font-size:9px;height:10px !important ;"/> ' + value.Description + ' </td>' +
                            '<td style="padding-left: 3px!important;"><input type="hidden" name="txtUnit" id="txtUnit' + rowlength + '" value="' + value.Unit + '" />' + value.UnitName + ' </td>' +
                            '<td><input type="text" name="BatchNo" id="BatchNo' + rowlength + '" value="" style="width:50px !important;text-align:left;font-size:9px;height:21px !important ;" onkeyup="BatchValidation(this)"/></td>' +
                            '<td><input type="text" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="txtdeliverydate" id="txtdeliverydate' + rowlength + '" value="' + datetime + '" readonly="readonly"/></td>' +
                            '<td style="padding-right: 3px!important;"><input type="hidden" value="' + parseFloat(value.Qty).toFixed(2) + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important; id="POQty' + rowlength + '" name="POQty" style="width:50px !important;"></input>' + parseFloat(value.Qty).toFixed(2) + '</td>' +

                            '<td style="padding-right: 3px!important;"><input type="hidden" style="width:50px !important;text-align:right;font-size:9px;height:10px !important;" value="' + parseFloat(recqty).toFixed(2) + '" id="RcvQty' + rowlength + '" name="RcvQty" ></input>' + parseFloat(recqty).toFixed(2) + '</td>' +

                            '<td style="text-align:right;padding-right: 3px!important;><input type="hidden" value="' + parseFloat(blncQty).toFixed(2) + '" style="width: 50px !important;text-align:right;font-size:9px;height:10px; !important" id="blncQty' + rowlength + '" name="blncQty" ></input>' + parseFloat(blncQty).toFixed(2) + '</td>' +

                            '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:21px !important;position: relative;" value="0" id="IgpQty' + rowlength + '" name="IgpQty"></input></td>' +

                            '<td style="padding-right: 3px!important;"><input type="hidden" style="width: 50px !important;text-align:right;font-size:9px;height:10px !important; id="InspQty' + rowlength + '" value="0" name="InspQty" style="width:50px !important;"></input>' + 0 + '</td>' +
                            '<td style="width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:21px !important;position: relative;" value="0" id="BounusQty' + rowlength + '" name="BounusQty" autocomplete="off" class="bonusQtyField" data-toggle="tooltip" data-placement="top" title="Enter Bounus quantity in Loose" ></input></td>' +

                            '<td><input type="text" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="txtMfgdate" id="txtMfgdate' + rowlength + '" value="" readonly="readonly"/></td>' +
                            '<td><input type="text" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="Expdate" id="Expdate' + rowlength + '" value="" readonly="readonly"/></td>' +
                            '<td style="display:none"><input type="hidden" style="width:61px !important;text-align:center;font-size:9px;height:21px !important;" name="Isbatch" id="Isbatch' + rowlength + '" value="' + value.IsBatch + '" readonly="readonly"/></td>' +
                            '<td style="display:none;width:50px !important;text-align:right;font-size:9px;height:10px !important;"><input type="text" style="width:50px !important;text-align:right;font-size:9px;height:21px !important;position: relative;" value="0" id="RejQty' + rowlength + '" name="RejQty"></input></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="font-size:11px;color: #f30a0a;position:relative;"></i></a> </td>' +
                            '</tr>';
                    });
                    $('#tblItemDescription').append(rows);
                    BatchValidation2();
                    $('input[name="txtMfgdate"]').datepicker({ dateFormat: 'dd M yy' });
                    $('input[name="Expdate"]').datepicker({ dateFormat: 'dd M yy' });
                });
            }
            else {
                alert("Please Select PR Number");
            }
        }
        function ExcludeFromPayment(anchor) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                console.clear();
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
        function PrintInwardGatePassDetail() {
            debugger;
            var id = '<% =Request.QueryString["IGP_ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=InwardGatePassList&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            }
            window.open(url, '_blank');
        }
        debugger;
        function disablepo() {
            debugger;
            var POField = $('#ddlPONo').val();
            if (POField != "0") {
                $('#AdvddlPONo').attr('disabled', true);
            }
            else {
                $('#AdvddlPONo').attr('disabled', false);
            }
        }
        function PrintInspection() {
            debugger;
            var id = '<% =Request.QueryString["IGP_ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=Inspection&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Inspection&ReportTitle=Inward Gate Pass List&Igpid=' + id;
            }
            window.open(url, '_blank');
        }
       

        function ApproveInspecModal() {
            debugger;
            if ($('#tblItemDescription tbody tr').length === 0) {
                alert('Please select items first.');
                return;
            }
            $('#InspmodalItemDescription tbody').empty();
            debugger;
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
            debugger;
            var isValid = true;
            var tblLength = $("#InspmodalItemDescription tr:gt(0)").length;

            if (tblLength == '0') {
                $('#InspmodalItemDescription').addClass('ErrorAlert');
                alert("Please Add items");
                isValid = false;
                return false;
            } else {
                $('#InspmodalItemDescription').removeClass('ErrorAlert');
            }
            if (document.getElementById('InspmodalItemDescription').rows.length > 1) {
                debugger;
                $.each($('#InspmodalItemDescription tbody tr'), function (key, value) {
                    var igpQty = parseFloat($(value).find('td input[name=IgpQty]').val());
                    var inspQty = parseFloat($(value).find('td input[name=InspQty]').val());

                    if (isNaN(inspQty) || inspQty <= 0 || inspQty > igpQty) {
                        alert("Please enter a valid Inspection Quantity for Item in Row " + (key + 1));
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
                    debugger;
                    if (res == 1) {
                        PageMethods.ApproveIgpInspec(IgpId, function (Tests) {
                            debugger;
                            var message = JSON.parse(Tests);
                            if (message[0].Column1 == "1" || message[0].Column1 === "1") {
                                alert("Inspection Approved Done Successfully");
                                location.reload();
                            } else {
                                if (message == "1") {
                                    alert("Inspection Approved Done Successfully");
                                    location.reload();
                                }
                                else {
                                    alert("An error occurred while Approving Inspection.");
                                }

                            }
                        });
                    } else {
                        alert("An error occurred while Updating Inspection details.");
                    }
                });
            }
        }

        function UnApproveInspec() {
            debugger;
            var IgpId = '<% =Request.QueryString["IGP_ID"] %>';
            PageMethods.UnApproveIgpInspec(IgpId, function (Tests) {
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
                url: "InversionGatePass.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
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
            debugger;
            var IgpId = '<% =Request.QueryString["IGP_ID"] %>';
            PageMethods.UnApproveIgP(IgpId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert(message[0].Column1);
                    location.reload();
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
            <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="LblIGP_Num" class="labelIGP">IGP No</label>
                    <input type="text" class="form-control" id="IGP_Num" name="IGP_Num" readonly="readonly" />
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="Lbl_Date" class="labelIGP">Date</label>
                    <input type="text" class="form-control" id="txtDate" name="txtDate" />
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12  mb-3">
                    <label id="lbltxtVendor" class="labelIGP">Vendor <span>*</span></label>
                    <select class="form-control" id="ddlVendor" name="ddlVendor" onchange="getPONumByVendor(this)">
                    </select>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="lblPO_No" class="labelIGP">Po No</label>
                    <select class="form-control" id="ddlPONo" name="ddlPONo" onchange="PerformPOSearch()">
                    </select>
                </div>
                </div>
                <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="lblInvorg" class="labelIGP">Warehouse<span>*</span></label>
                    <select class="form-control" id="ddlInv_Org"></select>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="LblDriverName" class="labelIGP">Driver Name</label>
                    <input type="text" class="form-control" id="DriverName" name="DriverName" />
                </div>

                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="Lbl_Vehiclenum" class="labelIGP">Vehicle #</label>
                    <input type="text" class="form-control" id="txtVehiclenum" name="txtVehiclenum" />
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="lblBility_No" class="labelIGP">Bility #</label>
                    <input type="text" class="form-control" id="txtBility_No" name="txtBility_No" />
                </div>
                </div>
                <div class="row">
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label style="width: 78px !important;" id="lblStatus" class="labelIGP">Status</label>
                    <input type="text" class="form-control" id="txtStatus" name="txtStatus" readonly="readonly" />
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label style="width: 78px !important;" id="lblStatusinpec" class="labelIGP">Inspec Status</label>
                    <input type="text" class="form-control" id="txtStatusInspec" name="txtStatusInspec" readonly="readonly" />
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="lblRemarks" class="labelIGP">Remarks</label>
                    <textarea class="form-control" id="txtRemarks " style="height: 33px;"></textarea>
                </div>
                <div class="col-lg-3 col-md-6 col-sm-12 mb-3">
                    <label id="lblAttachments" class="labelIGP">Attachments</label>
                    <input type="file" id="fileUpload1" name="fileUpload1" />
                    <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
                </div>
            </div>

    </form>
        <div class="row">
            <div class="table-responsive">
                <table class="table" id="tblItemDescription" style="overflow-x: scroll !important;">
                    <thead>
                        <tr>
                            <th style="width: 30px; text-align: center;">Sr No.</th>
                            <th style="width: 30px; text-align: center;">PO #</th>
                            <th style="width: 40px; text-align: center; font-size: 10px;">Item Code</th>
                            <th style="width: 195px; text-align: center;">Item Description</th>
                            <th style="width: 35px; text-align: center;">Unit</th>
                            <th style="width: 40px; text-align: center;">Batch No</th>
                            <th style="width: 62px; text-align: center;">PO Delivery Date</th>
                            <th style="width: 40px; text-align: center;">PO Qty</th>
                            <th style="width: 40px; text-align: center;">Rcv Qty</th>
                            <th style="width: 40px; text-align: center;">Blnc Qty</th>
                            <th style="width: 40px; text-align: center;">IGP Qty</th>
                            <th style="width: 40px; text-align: center;">Insp Qty</th>
                            <th style="width: 40px; text-align: center;">Bounus Qty</th>
                            <th style="width: 30px; text-align: center;">Mfg Date</th>
                            <th style="width: 30px; text-align: center;">Exp Date</th>
                            <th style="width: 40px; display: none; text-align: center;">Rej Qty</th>
                            <th style="width: 40px; text-align: center;">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail" style="height: 25px;">
                    </tbody>
                </table>
            </div>
        </div>
   

        <div class="row">
             <div class="col-lg-8">
            <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" value="Save" id="btnSave"  />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-primry" value="Print" name="name" onclick="PrintInwardGatePassDetail();" />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn-gray"  value="List" onclick="window.location = 'InversionGatePassView.aspx'" />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'InversionGatePass.aspx'" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class=" btn-primry" style="width: 103px; display: none" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
            </div>

            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button"  class="btn-primry" value="Inspec UnApproval" id="btnUnInspec" onclick="UnApproveInspec()" />
                &nbsp;
            </div>

            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" class="btn-primry" value="Print Inspec" id="btnPrintInspec" onclick="PrintInspection()" />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button"  class="btn btn-primry" value="Inspec Approval" id="btnInspec" onclick="ApproveInspecModal()" />
                &nbsp;
            </div>
            </div>
        </div>
        </div>


    <div id="inspecModal" class="modal" tabindex="-1" role="dialog">
        <div class="modal-dialog" role="document">
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <h5 class="modal-title">Inspec Approval</h5>
                    <button type="button" class="close" data-dismiss="modal" style="margin-top: -27px !important; margin-right: -30px !important;" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body" style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table" style="width: 953px; height: 80px !important; height: auto; overflow: scroll;" id="InspmodalItemDescription">
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


</asp:Content>
