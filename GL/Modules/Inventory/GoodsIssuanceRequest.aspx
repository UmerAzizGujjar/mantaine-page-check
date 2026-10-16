<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceRequest.aspx.cs" Inherits="PMS.Inventory.GoodsIssuanceRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/goods-issuance-request.css?v=20261019" rel="stylesheet" />
    <script src="../../wwwroot/lib/jquery/itemsearch.boost.js?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/wwwroot/lib/jquery/itemsearch.boost.js")).Ticks %>" type="text/javascript"></script>
    <script type="text/javascript">
        var counter = 1;
        var isReplicate = false;
        var replicateEnabled = '<%= ReplicateCode %>' === '01';
        var id = '<% =Request.QueryString["ID"] %>';
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
        
            $('#txtItem').tokenInput(function () {

                if (warehouseCond == '01') {
                    var warehouseVal = $('#ddlwarehouse').val();
                    if (!warehouseVal || warehouseVal === "0" || warehouseVal === "") {

                        return "";
                    }
                    return "../../json.aspx?Table=INV_ItemsForMIRByWarehouse&WarehouseID=" + encodeURIComponent(warehouseVal);
                }
                else {
                    return "../../json.aspx?Table=INV_ItemsForMIR"
                }

                
            }, {
                tokenLimit: 1,
                hintText: "Select a warehouse first...",
                noResultsText: "No items found.",
                searchingText: "Searching...",
                minChars: 2,          // no search on a single letter
                searchDelay: 200,     // wait for a short pause in typing instead of searching every key
                resultsLimit: 10,     // show only the top 10 (json.aspx also returns at most 10)
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
            GetWareHouseCondition();
            FillDepartments();
            FillWarehouses();
            $('#ddldept').select2();
            $('#ddlwarehouse').select2();
            $('#ddlPriority').select2();
            $('#ddlBranch').select2();
            loadUserBranch();
            BranchWareHouse.attach('#ddlBranch', '#ddlwarehouse');
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
            $('#btnReplicate').on('click', function () {
                isReplicate = true;
                SaveTest();
            });
            setTimeout(function () {
                var status = $('#txt_Status').val();
                if (status == "Approved") {
                    UserUnApproveButtonRights();
                    $('#btnsave').attr("disabled", 'disabled');
                    $('#btnReplicate').hide();
                }
                if (status == "Created") {
                }
                if (status == "Created" || status == "Pending") {
                    if (replicateEnabled) $('#btnReplicate').show();
                    if (id != "") {
                        CheckGIRApprovalRightsAndShowButton(id);
                    }
                }
            }, 1000);
        });
        var warehouseCond;
        function GetWareHouseCondition() {

            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {
                        //$('#warehouse').show();
                    }
                    else {
                       // $('#warehouse').hide();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function UserRights() {
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/UserEntryRights",
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
                    alert("Failed to retrieve user rights.");
                }
            });
        }



        function FillDepartments() {
            var optionsDPT = '';
            PageMethods.filldepartments(function (Tests) {
                optionsDPT = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddldept').html(optionsDPT);
            });
        }
        function FillWarehouses() {
            var optionsWarehouse = '';
            PageMethods.getwarehouseLlist(function (Tests) {
                optionsWarehouse = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsWarehouse += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlwarehouse').html(optionsWarehouse);
            });
        }

    

        function Delete(row) {
            $(row).closest('tr').remove();
        }
        function GetItemDetail() {
            var itemID = $("#hditemID").val();

            var deptID = $('#ddldept').val();
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/Getitem",
                data: JSON.stringify({
                    "ItemID": itemID,
                    "DeptID": deptID
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var find = false;
                    var parse = JSON.parse(response.d);
                    var length = $("#tblbodyPackage tr").length;
                    if (length > 0) {
                        length = length + 1;
                    }
                    else {
                        length = 1;
                    }
                    var selectedItemID = String(itemID).trim();

                    $('#tblbodyPackage tr').each(function () {
                        var existingItemID = String($(this).find('td:eq(9)').text()).trim();

                        if (existingItemID == selectedItemID) {
                            find = true;
                            return false;
                        }
                    });
                    if (find == true) {

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
                            var lastGIRDateValue = parse[0].Last_MIR_Date || '';

                            $("#tblbodyPackage").append("<tr>" +
                                "<td style='padding-top: 7px!important;'>" + length + "</td>" +
                                "<td style='padding-top: 7px!important;padding-right: 3px!important;'>" + parse[0].Item_Code + "</td>" +
                                "<td style='padding-left: 8px!important;padding-top: 7px!important;'>" + parse[0].Description + "</td>" +
                                "<td style='text-align:center;'>" + parse[0].Unit + "</td>" +
                                "<td style='text-align: center;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size: 11px;width: 100%!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty(this)'/></td>" +
                                "<td style='padding-top: 7px!important;text-align:center;padding-left: 8px!important;' >" + parse[0].Last_MIR_Qty + "</td>" +
                                "<td style='padding-top: 7px!important;text-align:center;padding-left: 8px!important;' >" + parse[0].Last_SIN_Qty + "</td>" +
                                "<td style='padding-top: 7px!important;padding-left: 8px!important' contenteditable></td>" +
                                "<td><label class='fileContainer' style='font-size: 13px;margin-top: -3px;'><i class='fa fa-paperclip'></i><input type='file' name='fileuploadlist' id='fileuploadlist" + length + "'></label></td>" +
                                "<td style='display:none'>" + parse[0].Item_ID + "</td>" +
                                "<td style='text-align:center;'>" + (parse[0].UOM_Qty || '0') + "</td>" +
                                "<td style='text-align:center;'>" +
                                (parse[0].Last_MIR_Date ? moment(parse[0].Last_MIR_Date).format('D-MMM-YYYY') : '') +
                                "</td>" +
                                "<td style='display:none'>" + lastGIRDateValue + "</td>" + 
                                "<td><a href='#' onclick='Delete(this)'><i class='fa fa-trash' style='font-size: 13px; margin-top: 5px; margin-left: 16px; color: #f30a0a;'></i></a></td>" +
                                "</tr>")
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
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/UserUnApproveEntryRights",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hasRights = response.d;
                    if (hasRights) {
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
        function callPageMethod(methodName, params, successCallback, errorCallback) {
            if (typeof params === 'function') {
                errorCallback = successCallback;
                successCallback = params;
                params = {};
            }
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/" + methodName,
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
        function CheckGIRApprovalRightsAndShowButton(girId) {
            callPageMethod('CheckGIRApprovalRights', function (hasRights) {
                if (hasRights) {
                    callPageMethod('GetGIRApprovalInfo', { GIRId: girId }, function (resp) {
                        var info = JSON.parse(resp);
                        if (info.CanApprove) {
                            $('#btnApprove').show();
                        }
                    });
                }
            });
        }
        function ApproveGIRFromEdit() {
            var girId = id;
            Swal.fire({
                title: 'Approve GIR?',
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
                    callPageMethod('ApproveSingleGIR', { GIRId: girId, approvalRemarks: remarks }, function (resp) {
                        if (resp === "Success") {
                            Swal.fire({ icon: 'success', title: 'Approved!', text: 'GIR has been approved successfully.', showConfirmButton: false, timer: 2000, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        } else {
                            Swal.fire({ icon: 'error', title: 'Error', text: resp, showConfirmButton: true, customClass: { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' } }).then(function () { location.reload(); });
                        }
                    });
                }
            });
        }
        function PrintGoodsIssuanceRequest() {
            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;


            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }

            var url = '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
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
            var MIRId = 0;
            if (!isReplicate && id != "") {
                MIRId = id;
            }
            var status = '';
            var MIRNum = $('#txtReq_Num').val();
            var MIRDate = $('#txtMIR_Date').val();
            var Pirority = $("#ddlPriority :selected").val();
            var dept = $('#ddldept :selected').val();
            var WareHouse = $('#ddlwarehouse :selected').val();
            var Branch = $('#ddlBranch').val();
            var remarks = $('#txtRemarks').val();
            var itemId = $('#hditemID').val();
            var btnValue = isReplicate ? "Replicate" : $("#btnsave").val();
            isReplicate = false;

            if (MIRNum == '') $('#txtReq_Num').addClass('ErrorAlert'); else $('#txtReq_Num').removeClass('ErrorAlert');
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

                // DISABLE SAVE BUTTON AFTER VALIDATION PASSES
                $('#btnsave').prop('disabled', true);

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
                    // RE-ENABLE BUTTON IF QTY VALIDATION FAILS
                    $('#btnsave').prop('disabled', false);

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter MIR Qty Or MIR Qty Must be Greater than zero',
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
                            "branch": Branch,
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var res = response.d;
                            var arr = res.split('-');
                            var msg = arr[0];
                            var id = arr[1];
                            sendFile(id, function () {
                                SaveMIRDetail(id);
                            });
                        },
                        failure: function (response) {
                            // RE-ENABLE BUTTON ON AJAX FAILURE
                            $('#btnsave').prop('disabled', false);
                            alert("In failure method");
                        }
                    });
                }
            }
        }
        function SaveMIRDetail(id) {
            var MIRDate = new Date($('#txtMIR_Date').val());
            var detailAry = [];
            var btnValue = $("#btnsave").val();
            $.each($("#tblPackage").find('tbody').find('tr'), function (index) {
                details = {};
                details.MIRQty = $(this).find('td:eq(4) input').val();
                details.Last_MIR_Qty = $(this).find('td:eq(5)').text();
                details.Last_SIN_Qty = $(this).find('td:eq(6)').text();
                details.Remarks = $(this).find('td:eq(7)').text();
                details.MIRId = id;
                details.itemId = $(this).find('td:eq(9)').text();
                var rawDate = $(this).find('td:eq(11)').text();
                if (rawDate && rawDate !== '' && rawDate !== 'null') {
                    var match = rawDate.match(/Date\((\d+)\)/);
                    if (match && match[1]) {
                        var timestamp = parseInt(match[1]);
                        var dateObj = new Date(timestamp);

                        if (!isNaN(dateObj.getTime())) {
                            details.Last_GIR_Date = dateObj.getFullYear() + '-' +
                                String(dateObj.getMonth() + 1).padStart(2, '0') + '-' +
                                String(dateObj.getDate()).padStart(2, '0');
                        } else {
                            details.Last_GIR_Date = null;
                        }
                    } else {
                        details.Last_GIR_Date = rawDate;
                    }
                } else {
                    details.Last_GIR_Date = null;
                }
                
                detailAry.push(details);
            });
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
                        var res = response.d;
                        var arr = res.split('-')[1];
            var btnValue = isReplicate ? "Replicate" : $("#btnsave").val();

                        // Upload per-row files after details saved
                        var getuploadlist = $('input[name=fileuploadlist]').get();
                        var hasPerRowFiles = false;
                        for (var i = 0; i < getuploadlist.length; i++) {
                            var filecomplete = getuploadlist[i].files;
                            if (filecomplete.length > 0) {
                                hasPerRowFiles = true;
                                var fd = new FormData();
                                fd.append('file', filecomplete[0]);
                                fd.append('MIRId', id);
                                fd.append('rowIndex', i);
                                $.ajax({
                                    type: 'post',
                                    url: '../../upload/UploadMIRDetailFiles.ashx',
                                    data: fd,
                                    async: false,
                                    processData: false,
                                    contentType: false
                                });
                            }
                        }

                        if (btnValue == "Save" || btnValue == "Replicate") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: btnValue == "Replicate" ? 'Data Replicated Successfully.' : 'Data Inserted Successfully.',
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
                                text: 'Data Updated Successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                        }
                        window.location.href = 'GoodsIssuanceRequestView.aspx';
                    },
                    failure: function (response) {
                        $('#btnsave').prop('disabled', false);
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
                    savedBranch = parse.Branch_Id;
                    if (savedBranch) {
                        $('#ddlBranch').val(savedBranch).trigger('change');
                    }
                    if (parse.Status == "Approved") {
                        $('#btnsave').attr("disabled", 'disabled');

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
            $.ajax({
                type: "POST",
                url: "GoodsIssuanceRequest.aspx/LoadMIRDetail",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var row = '';
                    $.each(parse, function (key, value) {
                        var len = key + 1;
                        var filePath = parse[key].FilePath || '';
                        var downloadLink = filePath ? '<a href="' + filePath + '" target="_blank" style="margin-right:4px;" title="Download"><i class="fa fa-download"></i></a>' : '';


                        var lastGIRDateDisplay = '';
                        if (parse[key].Last_GIR_Date && parse[key].Last_GIR_Date !== 'null' && parse[key].Last_GIR_Date !== '') {
                            try {
                                var dateStr = parse[key].Last_GIR_Date;
                                console.log('Raw Last_GIR_Date:', dateStr);
                                var cleanStr = dateStr.replace(/\s+/g, ' ').trim(); 
                                var parts = cleanStr.split(' ');
                                var datePart = parts[0] + ' ' + parts[1] + ' ' + parts[2];
                                console.log('Date part:', datePart);
                                var dateObj = new Date(datePart);
                                console.log('Date object:', dateObj);
                                if (!isNaN(dateObj.getTime())) {
                                    dateObj.setHours(0, 0, 0, 0);
                                    lastGIRDateDisplay = $.datepicker.formatDate('dd M yy', dateObj);
                                    console.log('Formatted date:', lastGIRDateDisplay);
                                } else {
                                    var altDate = new Date(parts[2], getMonthIndex(parts[0]), parseInt(parts[1]));
                                    if (!isNaN(altDate.getTime())) {
                                        altDate.setHours(0, 0, 0, 0);
                                        lastGIRDateDisplay = $.datepicker.formatDate('dd M yy', altDate);
                                    } else {
                                        lastGIRDateDisplay = dateStr;
                                    }
                                }
                            } catch (e) {
                                console.log('Error parsing date:', e);
                                lastGIRDateDisplay = parse[key].Last_GIR_Date;
                            }
                        }

                        row += '<tr><td style="padding-top: 7px!important;">' + len + '</td>' +
                            '<td style="padding-top: 7px!important;padding-right: 3px!important;">' + parse[key].itemCode + '</td>' +
                            '<td style="padding-left: 8px!important;padding-top: 7px!important;">' + parse[key].Description + '</td>' +
                            '<td style="text-align:center;">' + parse[key].Unit + '</td>' +
                            '<td style="text-align: center;"><input type="text" value="' + parseFloat(parse[key].MIRQty).toFixed(2) + '" name="Qty" id="txtQty' + counter + '" style="font-size: 9px;width: 52px!important;text-align: right;margin-top: 2px;" autocomplete="off" onkeyup="calcutaeQty(this)"/></td>' +
                            '<td style="padding-top: 7px!important;text-align:center;padding-left: 8px!important;" contenteditable>' + parse[key].Last_MIR_Qty + '</td>' +
                            '<td style="padding-top: 7px!important;text-align:center;padding-left: 8px!important;" contenteditable>' + parse[key].Last_SIN_Qty + '</td>' +
                            '<td style="padding-top: 7px!important;padding-left: 8px!important" contenteditable>' + parse[key].remarks + '</td>' +
                            '<td>' + downloadLink + '<label class="fileContainer" style="font-size: 13px;margin-top: -3px;"><i class="fa fa-paperclip"></i><input type="file" name="fileuploadlist" id="fileuploadlist' + key + '"></label></td>' +
                            '<td style="display:none">' + parse[key].itemId + '</td>' +
                            '<td style="text-align:center;">' + (parse[key].UOM_Qty || '0') + '</td>' +
                            '<td style="text-align:center;padding-left: 8px!important;">' + lastGIRDateDisplay + '</td>' +
                            '<td><a href="#" onclick="Delete(this)"><i class="fa fa-trash" style="font-size: 13px; margin-top: 5px; margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                            '</tr>';
                    });
                    $("#tblPackage").append(row);
                    calcutaeQty();
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function sendFile(ID, callback) {
            var fileInput = $('#choseGIRfile')[0];
            if (fileInput.files.length > 0) {
                var data = new FormData();
                data.append('file', $('#choseGIRfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '../../upload/UploadMaterialIssue.ashx',
                    data: data,
                    success: function (status) {
                        if (typeof callback === 'function') callback();
                    },
                    processData: false,
                    contentType: false,
                    error: function () {
                        alert("hehe");
                    }
                });
            } else {
                if (typeof callback === 'function') callback();
            }
        }
        function calcutaeQty() {
            var TotalQty = 0;
            $.each($('#tblPackage tbody tr'), function (key, value) {
                var inputElement = $(value).find('td input[name=Qty]')[0];
                var Qty = $(inputElement).val();

                console.log('Row:', key, 'Input element:', inputElement, 'Value:', Qty); // Debug log

                var parsedQty = parseFloat(Qty) || 0;
                TotalQty += parsedQty;
            });
            $('#totQty').val(TotalQty);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="gi-page">

        <!-- Title line: the master page puts the page title in the empty left side; the badges sit on the right -->
        <div class="pr-meta-bar">
            <div class="meta-left"></div>
            <div class="meta-right">
                <div class="gi-badge"><span class="gi-badge-label">Request #</span><span class="gi-badge-value" id="badgeGirNo">---</span></div>
                <div class="gi-badge"><span class="gi-badge-label">Date</span><span class="gi-badge-value" id="badgeGirDate">---</span></div>
                <div class="gi-badge"><span class="gi-badge-label">Priority</span><span class="gi-badge-value" id="badgeGirPriority">---</span></div>
                <div class="gi-badge"><span class="gi-badge-label">Status</span><span class="gi-badge-value" id="badgeGirStatus">---</span></div>
            </div>
        </div>

        <div id="item" class="gi-layout">

            <!-- Left: request details + item / remarks -->
            <div class="gi-col">
                <section class="gi-card">
                    <h5 class="gi-card-title"><i class="fa fa-file-text-o"></i> Request Details</h5>
                    <div class="gi-grid">
                        <div class="gi-field">
                            <label id="LblPr_Num" for="txtReq_Num">Request #</label>
                            <input type="text" class="form-control" id="txtReq_Num" value="New" name="txtReq_Num" placeholder="Request #" readonly="readonly" />
                        </div>
                        <div class="gi-field">
                            <label id="LblPR_Date" for="txtMIR_Date">GIR Date</label>
                            <input type="text" class="form-control" id="txtMIR_Date" name="txtMIR_Date" autocomplete="off" />
                        </div>
                        <div class="gi-field">
                            <label id="LblPriority" for="ddlPriority">Priority</label>
                            <select id="ddlPriority" class="form-control">
                                <option value="0">Please Select</option>
                                <option value="1">High</option>
                                <option value="2">Low</option>
                            </select>
                        </div>
                        <div class="gi-field">
                            <label id="LblBranch" for="ddlBranch">Branch</label>
                            <select id="ddlBranch" class="form-control"></select>
                        </div>
                        <div class="gi-field gi-span-2">
                            <label id="Lbldept" for="ddldept">Department <span class="gi-req">*</span></label>
                            <select id="ddldept" class="form-control">
                            </select>
                        </div>
                        <div id="warehouse" class="gi-field gi-span-2">
                            <label id="Lblwarehouse" for="ddlwarehouse">Ware House <span class="gi-req">*</span></label>
                            <select id="ddlwarehouse" class="form-control">
                                <option value="0">Please Select</option>
                            </select>
                        </div>
                    </div>
                </section>

                <section class="gi-card">
                    <h5 class="gi-card-title"><i class="fa fa-search"></i> Item, Remarks &amp; Attachments</h5>
                    <div class="gi-grid" style="align-items: start;">
                        <div class="gi-field gi-span-2">
                            <label for="txtItem">Item</label>
                            <input type="text" class="form-control" id="txtItem" name="txtItem" placeholder="item" />
                            <input type="hidden" id="hditemID" />
                        </div>
                        <div class="gi-field gi-span-2">
                            <label id="lblattach" for="choseGIRfile">Attachments</label>
                            <input type="file" id="choseGIRfile" name="choseGIRfile" class="form-control" />
                            <asp:HyperLink ID="HyperLink1" runat="server" CssClass="gi-link">Download</asp:HyperLink>
                        </div>
                        <div class="gi-field gi-span-all">
                            <label id="lblrem" for="txtRemarks">Remarks</label>
                            <input type="text" class="form-control" id="txtRemarks" name="txtRemarks" autocomplete="off" />
                        </div>
                    </div>
                </section>
            </div>

            <!-- Right: status + total -->
            <div class="gi-col">
                <section class="gi-card">
                    <h5 class="gi-card-title"><i class="fa fa-calculator"></i> Summary</h5>
                    <div class="gi-grid" style="grid-template-columns: minmax(0, 1fr);">
                        <div class="gi-field">
                            <label id="lbl_Status" for="txt_Status">Status</label>
                            <input type="text" class="form-control" id="txt_Status" name="txt_Status" readonly="readonly" />
                        </div>
                        <div class="gi-field gi-figure gi-figure-main">
                            <label for="totQty">Total Qty</label>
                            <input type="text" class="form-control" id="totQty" name="totQty" readonly="readonly" />
                        </div>
                    </div>
                </section>
            </div>
        </div>

        <!-- Items -->
        <section class="gi-card">
            <h5 class="gi-card-title"><i class="fa fa-list-alt"></i> Items</h5>
            <div class="gi-table-wrap">
                <table class="table table-hover gi-table" id="tblPackage">
                    <thead>
                        <tr>
                            <th style="width: 40px;">GIR No.</th>
                            <th style="width: 56px;">Item Code</th>
                            <th style="width: 205px;">Description</th>
                            <th style="width: 35px;">Unit</th>
                            <th style="width: 43px;">GIR Qty</th>
                            <th style="width: 43px;">Last GIR Qty</th>
                            <th style="width: 43px;">Last GIN Qty</th>
                            <th style="width: 112px; display: none;">Technical Specifications</th>
                            <th style="width: 126px;">Remarks</th>
                            <th style="width: 32px !important;">Attachment</th>
                            <th style="width: 43px;">UOM Qty</th>
                            <th style="width: 43px;">Last GIR Date</th>
                            <th style="width: 40px;">Delete</th>
                        </tr>
                    </thead>
                    <tbody id="tblbodyPackage"></tbody>
                </table>
            </div>
        </section>

        <!-- Actions -->
        <div class="purchaseOrderSubmitForm" style="margin-top: 21px;">
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
                        <%-- Replicate sits after Print (hidden until the status allows it) so the visible buttons stay side by side --%>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" class="btn btn-primry" value="Replicate" id="btnReplicate" style="display: none;" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" style="display: none;" class="btn btn-primry" value="Approve" id="btnApprove" onclick="ApproveGIRFromEdit()" />
                            &nbsp;
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6" id="btnUnApproveToBeHidden" style="display: none">
                            <input type="button" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                            &nbsp;
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <script type="text/javascript">
        // title-line badges follow the form fields (the page script fills them in after loading)
        function syncGirBadges() {
            $('#badgeGirNo').text($('#txtReq_Num').val() || '---');
            $('#badgeGirDate').text($('#txtMIR_Date').val() || '---');
            var pr = $('#ddlPriority option:selected').text();
            $('#badgeGirPriority').text((pr && pr.indexOf('Please Select') < 0) ? pr : '---');
            $('#badgeGirStatus').text($('#txt_Status').val() || '---');
        }
        $(function () {
            syncGirBadges();
            setInterval(syncGirBadges, 600);
        });
    </script>
</asp:Content>
