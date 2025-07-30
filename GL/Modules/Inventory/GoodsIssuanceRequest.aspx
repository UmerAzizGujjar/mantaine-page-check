<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceRequest.aspx.cs" Inherits="PMS.Inventory.GoodsIssuanceRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 
    <script type="text/javascript">
        var counter = 1;
        var append_data = '';
        debugger;
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
        
            $('#txtItem').tokenInput(function () {
                var warehouseVal = $('#ddlwarehouse').val();
                debugger;
                if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {

                    return "";
                }


                return "../../json.aspx?Table=INV_ItemsForMIR&WarehouseID=" + encodeURIComponent(warehouseVal);
            }, {
                tokenLimit: 1,
                hintText: "Select a warehouse first...",
                noResultsText: "No items found.",
                searchingText: "Searching...",

                onAdd: function (item) {

                    $("#hditemID").val(item.id);
                    $("#txtItem").val(item.name);
                    GetItemDetail();
                }
            });
          
         
            $('#ddlwarehouse').change(function () {

                $("#ddlwarehouse").attr('disabled', true);
            });
            UserRights();
            FillDepartments();
            FillWarehouses();
            $('#ddldept').select2();
            $('#ddlwarehouse').select2();
            $('#ddlPriority').select2();
            var currentDate = new Date();
            var formattedDate = $.datepicker.formatDate('dd M yy', currentDate);
            $("#txtMIR_Date").val(formattedDate).datepicker({ dateFormat: 'dd M yy', readOnly: true });

            $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
           
            if (id == '') {
                $('#btn_Print').hide();
            }
            if (id != "") {
                LoadMIRMaster(id);
                LoadLoadMIRDetail(id);
                $("#btnsave").val('Update');
                $('#btn_Print').show();
            }
            setTimeout(function () {
                var status = $('#txt_Status').val();
                if (status == "Approved") {
                    debugger;
                    UserUnApproveButtonRights();
                    $('#btnsave').attr("disabled", 'disabled');
                }
                if (status == "Created") {
                    debugger;
                }
            }, 1000);
        });

        function UserRights() {
            debugger;
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/UserEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnsave').show();
                    } else {
                        $('#btnsave').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve user rights.");
                }
            });
        }



        function FillDepartments() {
            debugger;
            var optionsDPT = '';
            PageMethods.filldepartments(function (Tests) {
                debugger
                optionsDPT = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddldept').html(optionsDPT);
            });
        }
        function FillWarehouses() {
            debugger;
            var optionsWarehouse = '';
            PageMethods.getwarehouseLlist(function (Tests) {
                debugger
                optionsWarehouse = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionsWarehouse += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlwarehouse').html(optionsWarehouse);
            });
        }

    

        function Delete(row) {
            $(row).closest('tr').remove();
        }
        function GetItemDetail() {
            debugger
            var itemID = $("#hditemID").val();
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/Getitem",
                data: JSON.stringify({
                    "ItemID": itemID,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var find = false;
                    debugger;
                    var parse = JSON.parse(response.d);
                    var length = $("#tblbodyPackage tr").length;
                    if (length > 0) {
                        length = length + 1;
                    }
                    else {
                        length = 1;
                    }
                    $('#tblbodyPackage tr').each(function () {
                        debugger;
                        var $projectName = $(this).find('td:eq(9)').text();
                        if ($projectName == itemID) {
                            debugger;
                            find = true;
                        }
                    });
                    if (find == true) {
                        debugger;

                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'item already exists',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });


                         $("#txtItem").tokenInput("clear");
                    }
                    else {
                        if (parse[0].Active == true) {
                            $("#tblbodyPackage").append("<tr><td style='padding-top: 7px!important;'>" + length + "</td><td style='padding-top: 7px!important;padding-right: 3px!important; */'>" + parse[0].Item_Code + "</td><td style='padding-left: 8px!important;padding-top: 7px!important;'>" + parse[0].Description + "</td><td style='text-align:center;'>" + parse[0].Unit + "</td><td style='text-align: center;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size: 11px;width: 100%!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty(this)'/></td><td style='padding-top: 7px!important;padding-left: 8px!important;display:none;' contenteditable></td><td style='padding-top: 7px!important;padding-left: 8px!important' contenteditable></td><td><label class='fileContainer' style='font-size: 13px;margin-top: -3px;'><i class='glyphicon glyphicon-paperclip'></i><input type='file' name='fileuploadlist' id='fileuploadlist" + length + "'></label></td><td style='display:none'>" + parse[0].Item_ID + "</td><td><a href='#' onclick='Delete(this)'><i class='glyphicon glyphicon-trash' style='font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;'></i></a></td></tr>")
                            length++;
                            $("#txtItem").tokenInput("clear");
                        }
                        else {

                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'You have selected InActive items',
                                showConfirmButton: false,
                                timer: 2000,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });


                             $("#txtItem").tokenInput("clear");
                        }
                    }
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function UnApprove() {
            var MIRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.UnApproveMIR(MIRId, function (Tests) {
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
                url: "GoodsIssuanceRequest.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var hasRights = response.d;
                    debugger;
                    if (hasRights) {
                        debugger;
                        $('#btnUnApproveToBeHidden').show();
                    } else {
                        $('#btnUnApproveToBeHidden').hide();
                    }
                },
                failure: function (response) {
                    alert("Failed to retrieve User UnApprove Button Rights.");
                }
            });
        }
        function PrintGoodsIssuanceRequest() {
            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            }
            window.open(url, '_blank');
        }
        function GetReqNum() {
            $.ajax({
                type: "post",
                url: "GoodsIssuanceRequest.aspx/GetRequestNo",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var id = response.d;
                    $("#txtReq_Num").val(id);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function SaveTest() {
            debugger;
            var MIRId = 0;
            if (id == "") {
                MIRId = 0;
            }
            else {
                MIRId = id
            }
            var status = '';
            var MIRNum = $('#txtReq_Num').val();
            var MIRDate = $('#txtMIR_Date').val();
            var Pirority = $("#ddlPriority :selected").val();
            var dept = $('#ddldept :selected').val();
            var WareHouse = $('#ddlwarehouse :selected').val();
            var remarks = $('#txtRemarks').val();
            var itemId = $('#hditemID').val();
            var btnValue = $("#btnsave").val();
            if (MIRNum == '') $('#txtReq_Num').addClass('ErrorAlert'); else $('#txtPr_Num').removeClass('ErrorAlert');
            if (MIRDate == '') $('#txtMIR_Date').addClass('ErrorAlert'); else $('#txtMIR_Date').removeClass('ErrorAlert');
            if (dept == '0') $('#ddldept').addClass('ErrorAlert'); else $('#ddldept').removeClass('ErrorAlert');
            if (WareHouse == '0') $('#ddlwarehouse').addClass('ErrorAlert'); else $('#ddlwarehouse').removeClass('ErrorAlert');
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
            } else {
                $('#tblPackage').removeClass('ErrorAlert');
            }
            if (!$('#txtReq_Num').hasClass('ErrorAlert') && !$('#txtMIR_Date').hasClass('ErrorAlert') && !$('#txtRemarks').hasClass('ErrorAlert') && !$('#ddldept').hasClass('ErrorAlert') && !$('#ddlwarehouse').hasClass('ErrorAlert') && !$('#tblPackage').hasClass('ErrorAlert')) {
                $.each($("#tblPackage").find('tbody').find('tr'), function (index) {
                    var MIRQty = $(this).find('td input[name=Qty]').val();
                    if (MIRQty == "" || MIRQty == 0 || MIRQty < 0) {
                        status = "QtyError";
                        return false;
                    }
                    else {
                        status = true;
                    }
                })
                if (status == "QtyError") {
                    debugger;

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter MIR Qty Or MIR  Qty Must be Greater than zero',
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
                    $.ajax({
                        type: "post",
                        url: "GoodsIssuanceRequest.aspx/SaveMIR",
                        data: JSON.stringify({
                            "MIRId": MIRId,
                            "MIRNum": MIRNum,
                            "MIRDate": MIRDate,
                            "Pirority": Pirority,
                            "dept": dept,
                            "remarks": remarks,
                            "WareHouse": WareHouse,
                            "btnValue": btnValue,
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            debugger;
                            var res = response.d;
                            var arr = res.split('-');
                            var msg = arr[0];
                            var id = arr[1];
                            sendFile(id);
                            SaveMIRDetail(id);
                        },
                        failure: function (response) {
                            alert("In failure method");
                        }
                    });

                }
            }
        }
        function SaveMIRDetail(id) {
            var MIRDate = new Date($('#txtMIR_Date').val());
            debugger;
            var detailAry = [];
            var btnValue = $("#btnsave").val();
            $.each($("#tblPackage").find('tbody').find('tr'), function (index) {
                debugger
                details = {};
                details.MIRQty = $(this).find('td:eq(4) input').val();
                details.Remarks = $(this).find('td:eq(6)').text();
                details.MIRId = id;
                details.itemId = $(this).find('td:eq(8)').text();
                detailAry.push(details);
            });
            var getuploadlist = $('input[name=fileuploadlist]').get();
            append_data = new FormData();
            for (var i = 0; i < getuploadlist.length; i++) {
                var filecomplete = getuploadlist[i].files;
                if (filecomplete.length > 0) {
                    append_data.append(filecomplete[0].name, filecomplete[0]);
                }
            }
            if (detailAry.length > 0) {
                $.ajax({
                    type: "POST",
                    url: "GoodsIssuanceRequest.aspx/SaveMIRDetails",
                    data: JSON.stringify({
                        "MIRId": id,
                        "btnValue": btnValue,
                        'MIRDetails': detailAry
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var res = response.d;
                        var arr = res.split('-')[1];
                        var btnValue = $("#btnsave").val();
                        if (btnValue == "Save") {
                            append_data.append('ID', 0);
                        }
                        else {
                            append_data.append('ID', arr);
                        }
                        var options = {};
                        options.url = "../UploadPurchaseRequsitionDetail.ashx";
                        options.type = "POST";
                        options.data = append_data;
                        options.contentType = false;
                        options.processData = false;
                        options.success = function (result) { alert(result) };
                        options.error = function (err) { };
                        $.ajax(options);
                        if (btnValue == "Save") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Inserted Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                             $("#btnsave").prop("disabled", true);
                        }
                        else {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data Updated Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                             $("#btnsave").prop("disabled", true);
                        }
                        window.location.href = 'GoodsIssuanceRequestView.aspx';
                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
            }
        }
        function LoadMIRMaster(id) {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/LoadMIR",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    $('#txtReq_Num').val(parse.Request_No);
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse.MIRDate.substring(6, 19))))
                    $('#txtMIR_Date').val(datetime);
                    setTimeout(function () {
                        $('#ddlPriority').val(parse.Priority).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddldept').val(parse.Department).trigger('change');
                    }, 1000);
                    setTimeout(function () {
                        $('#ddlwarehouse').val(parse.InventoryOrganization).trigger('change');
                    }, 1000);
                    $('#txtRemarks').val(parse.Remarks);
                    $('#txt_Status').val(parse.Status);
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
                if (seen[item_id]) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'duplicate',
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
                    seen[item_id] = true;
                }
            });
        }
        function LoadLoadMIRDetail(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/LoadMIRDetail",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    var row = '';
                    $.each(parse, function (key, value) {
                        debugger;
                        var len = key + 1;
                        row += '<tr><td style="padding-top: 7px!important;">' + len + '</td><td style="padding-top: 7px!important;padding-right: 3px!important; */">' + parse[key].itemCode + '</td><td style="padding-left: 8px!important;padding-top: 7px!important;">' + parse[key].Description + '</td><td style="text-align:center;">' + parse[key].Unit + '</td><td style="text-align: center;"><input type="text"  value="' + parseFloat(parse[key].MIRQty).toFixed(2) + '" name="Qty" id="txtQty ' + counter + '" style="font-size: 9px;width: 52px!important;text-align: right;margin-top: 2px;" autocomplete="off" onkeyup="calcutaeQty(this)"/></td><td style="padding-top: 7px!important;padding-left: 8px!important;display:none;" contenteditable></td><td style="padding-top: 7px!important;padding-left: 8px!important" contenteditable>' + parse[key].remarks + '</td><td> <label class="fileContainer" style="font-size: 13px;margin-top: -3px;"><i class="glyphicon glyphicon-paperclip"></i><input type="file" name="fileuploadlist" id="fileuploadlist' + key + '"></label></td><td style="display:none">' + parse[key].itemId + '</td><td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td></tr>';
                    });
                    $("#tblPackage").append(row);
                    calcutaeQty();
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function sendFile(ID) {
            debugger;
            var fileInput = $('#choseGIRfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#choseGIRfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../UploadMaterialIssue.ashx',
                    data: data,
                    success: function (status) {
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert("hehe");
                    }
                });
            }
        }
        function calcutaeQty() {
            debugger;
            var TotalQty = 0;
            $.each($('#tblPackage tbody tr'), function (key, value) {
                debugger;
                var Qty = $($(value).find('td input[name=Qty]')[0]).val();
                TotalQty += parseFloat(Qty);
            });
            debugger;
            $('#totQty').val(TotalQty);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item">
        <div class="row">
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="LblPr_Num">Request #</label>
                <input type="text" class="form-control" id="txtReq_Num" value="New" name="txtReq_Num" placeholder="Request #" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="LblPR_Date">GIR Date</label>
                <input type="text" class="form-control" id="txtMIR_Date" name="txtMIR_Date" autocomplete="off" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="LblPriority">Priority</label>
                <select id="ddlPriority">
                    <option value="0">Please Select</option>
                    <option value="1">High</option>
                    <option value="2">Low</option>
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="Lbldept">Department<span>*</span></label>
                <select id="ddldept">
                </select>
            </div>
        </div>
        <div class="row">

            <div class="col-lg-3 col-md-6 col-sm-12">
                <label>Item</label>
                <input type="text" class="form-control" id="txtItem"  name="txtItem" placeholder="item" />
            </div>

            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="Lblwarehouse">Ware House <span style="color: red">*</span></label>
                <select id="ddlwarehouse">
                    <option value="0">Please Select</option>
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label id="lbl_Status">Status</label>
                <input type="text" class="form-control" id="txt_Status" name="txt_Status" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <div class="col-lg-12 col-md-12 col-sm-12">
                    <label id="lblattach">Attachments</label>
                    <input type="file" id="choseGIRfile" name="choseGIRfile" />
                    <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
                </div>
                <div class="col-lg-0 col-md-3 col-sm-4">
                    <input type="hidden" id="hditemID" />
                </div>
            </div>



        </div>
        <div class="row">
            <div class="col-lg-12 col-md-12 col-sm-12">
                <label id="lblrem">Remarks</label>
                <input type="text" class="form-control" id="txtRemarks" name="txtRemarks" />
            </div>
        </div>
    </form>
  

    <div class="table-container">
        <div class="table-responsive">
            <table class="table table-hover table-striped table-bordered" id="tblPackage" style="margin-top: 13px; font-size: 10px!important; width: 100% !important; overflow: scroll; height: auto">
                <thead>
                    <tr>
                    <th style="width: 40px; text-align: center;">GIR No.</th>
                    <th style="width: 56px; text-align: center; font-size: 10px;">Item Code</th>
                    <th style="width: 205px; text-align: center;">Description</th>
                    <th style="width: 35px; text-align: center;">Unit</th>
                    <th style="width: 43px; text-align: center;">GIR Qty</th>
                    <th style="width: 112px; text-align: center; display: none;">Technical Specifications</th>
                    <th style="width: 126px; text-align: center;">Remarks</th>
                    <th style="width: 32px!important; text-align: center;">Attachment</th>
                    <th style="width: 40px; text-align: center;">Delete</th>
                        </tr>
                </thead>
                <tbody id="tblbodyPackage"></tbody>
            </table>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
        </div>
        <div class="col-lg-1 col-md-6 col-sm-12">
            <label style="margin-left: 62px">Total Qty</label>
            </div>
        <div class="col-lg-2 col-md-6 col-sm-12">
            <input type="text" id="totQty" name="totQty" readonly="readonly" />
        </div>
    </div>

    <div class="purchaseOrderSubmitForm" style=" margin-top: 21px;">
        <div class="row">
             <div class="col-lg-8">
            <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-primry" value="Save" id="btnsave" onclick="SaveTest()" />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn-gray" value="List" onclick="window.location = 'GoodsIssuanceRequestView.aspx'" />
                &nbsp;
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" value="New" class="btn btn-yellow" onclick="window.location = 'GoodsIssuanceRequest.aspx'" />
                &nbsp;
            </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
    <input type="button" value="Print" class="btn btn-primry" name="btn_Print" id="btn_Print" onclick="PrintGoodsIssuanceRequest();" style="width: 81px;" />
</div>
            <div class="col-lg-2 col-md-4 col-sm-6" id="btnUnApproveToBeHidden">
                <input type="button" style="display: none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />            
                        &nbsp;
            </div>
            
            </div>
        </div>
        </div>
    </div>
</asp:Content>
