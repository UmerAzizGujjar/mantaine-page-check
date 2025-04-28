<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MaterialIssueRequest.aspx.cs" Inherits="PMS.Inventory.MaterialIssueRequest" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="Scripts/bootstrap.min.js" type="text/css"></script>
    <link href="../css/stock.css" rel="stylesheet" />
    <link href="../Styles/token-input.css" rel="stylesheet" />
    <link href="../js/select2.min.css" rel="stylesheet" />
    <script src="../js/select2.min.js"></script>


    <script type="text/javascript">
        var counter = 1;
        var append_data = '';
        debugger;
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            GetReqNum();
            $('#chckreceived').hide();
            $('#lblchckreceived').hide();

            stockRights();
            approveright();
            debugger;
            FillDepartments();
            var date = '<%= DateTime.Now%>';
              $("#txtMIR_Date").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
              $("#txtMIR_Date").val(date);
              $('.token-input-list').css('width', '666px !important', 'margin-left: 1px;');
              FillEmployeeList();
              loadtokenInputsDefaultitem();
              debugger;

              if (id != "") {
                  checkstoreissueapprove(id);
                  LoadMIRMaster(id);
                  LoadLoadMIRDetail(id);
                  $("#btnsave").val('Update');
                  $('#btn_Print').show();

              }
              setTimeout(function () {
                  Inventory_Approval();
              }, 1500);
              setTimeout(function () {
                  manager_approval();
              }, 1500);

          });
        var stockchck;
        function stockRights() {
            debugger;

            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/stockrights",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    stockchck = data.d;

                },
                failure: function () {

                    alert(bi);
                }
            });
        }

        var InvApproval;

        function Inventory_Approval() {
            debugger;
            var status = $("#txt_Status").val();
            if (status == "Approved") {
                $.ajax({
                    type: "POST",
                    url: "MaterialIssueRequest.aspx/Inventory_approvals",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        InvApproval = data.d;
                        debugger;
                        if ((InvApproval === true || InvApproval == "true")) {
                            debugger;
                            if ((Inv_approval === true || Inv_approval == "true") && id != "") {
                                $('#btnUnApprove').show();
                                $('#btnApprove').hide();
                            }
                            if ((Inv_approval === false || Inv_approval == "false") && id != "") {
                                $('#btnUnApprove').hide();
                                $('#btnApprove').show();
                            }
                        }
                        else {
                            $('#btnUnApprove').hide();
                            $('#btnApprove').hide();
                        }
                    },
                    failure: function () {
                        alert(bi);
                    }
                });
            }
            //else {
            //    $('#btnUnApprove').hide();
            //    $('#btnApprove').show();
            //}
        }
        var approvmanager;
        function manager_approval() {
            var status = $("#txt_Status").val();
            if (status == "Approved") {
                debugger;
                $.ajax({
                    type: "POST",
                    url: "MaterialIssueRequest.aspx/manager_approvals",
                    data: "",
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    async: true,
                    success: function (data) {
                        debugger;
                        approvmanager = data.d;
                        if ((approvmanager == "true" || approvmanager === true)) {
                            debugger;
                            if ((managerialapprove === true || managerialapprove == "true") && id != "") {
                                $('#btnmanagerial_unapprove').show();
                                $('#btnmanagerial_approve').hide();
                            }
                            if ((managerialapprove === false || managerialapprove == "false") && id != "") {
                                $('#btnmanagerial_unapprove').hide();
                                $('#btnmanagerial_approve').show();
                            }
                        }
                        else {
                            $('#btnmanagerial_unapprove').hide();
                            $('#btnmanagerial_approve').hide();
                        }
                      if (rcv === true) {
                        $('#btnrcvd').hide();
                       }
                    },
                    failure: function () {
                        alert(bi);
                    }
                });
            }
            else {
                $('#btnmanagerial_unapprove').hide();
                $('#btnmanagerial_approve').hide();
            }
        }
        //function manager_approval() {
        //    debugger;

        //    $.ajax({
        //        type: "POST",
        //        url: "MaterialIssueRequest.aspx/manager_approvals",
        //        data: "",
        //        contentType: "application/json; charset=utf-8",
        //        dataType: "json",
        //        async: true,
        //        success: function (data) {
        //            debugger;
        //            approvmanager = data.d;
        //            debugger;
        //            if (managerialapprove === true && approvmanager == "true" && filt_status === "Approved" && id != "") {

        //                $('#btnmanagerial_unapprove').show();
        //                $('#btnmanagerial_approve').hide();
        //            }
        //            if (filt_status === "Approved" && approvmanager == "true") {
        //                $('#btnmanagerial_approve').hide();
        //                $('#btnmanagerial_unapprove').show();
        //            }
        //            if (filt_status == "Created" && id != "") {
        //                $('#btnUnApprove').hide();
        //                $('#btnApprove').show();
        //                $('#btnmanagerial_approve').hide();
        //                $('#btnmanagerial_unapprove').hide();

        //            }
        //            if (managerialapprove === false && filt_status === "Approved") {
        //                $('#btnmanagerial_unapprove').hide();
        //                $('#btnmanagerial_approve').show();
        //            }
        //            //else {
        //            //    $('#btnUnApprove').show();
        //            //    $('#btnApprove').hide();
        //            //}
        //            if (id == "") {
        //                $('#btnmanagerial_approve').hide();
        //                $('#btnmanagerial_unapprove').hide();
        //                $('#btnUnApprove').hide();
        //            }
        //            debugger;
        //            if (rcv === true) {
        //                $('#btnmanagerial_approve').hide();
        //                $('#btnmanagerial_unapprove').hide();
        //                $('#btnUnApprove').hide();
        //                $('#btnrcvd').hide();
        //            }
        //        },
        //        failure: function () {
        //            alert(bi);
        //        }
        //    });
        //}

        function FillDepartments() {
            debugger;
            var optionsDPT = '';
            var optionInv = '';

            PageMethods.getDDLlist(function (Tests) {

                optionsDPT = '<option value="0">Please Select</option>';
                optionInv = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    if (value.Type == "DPT") {
                        optionsDPT += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }
                    else if (value.Type == "InvOrg") {
                        optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                    }

                });
                $('#ddldept').html(optionsDPT);
                $('#ddlInv_Org').html(optionInv);



            });

        }

        var userupdate;
        function approveright() {


            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/approverights",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {

                    userupdate = data.d;

                },
                failure: function () {

                    alert(bi);
                }
            });
        }

        function FillEmployeeList() {
            var optionEmployee = '';
            PageMethods.GetEmployee(function (Tests) {
                debugger
                optionEmployee = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionEmployee += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ddlEmployee').html(optionEmployee);

            })
        }

        function loadtokenInputsDefaultitem() {
            debugger;
            $('#txtItem').tokenInput("../json.aspx?Table=INV_Items",
                {
                    tokenLimit: 1,
                    onAdd: function (item) {
                        try {
                            $("#hditemID").val(item.id);
                            $("#txtItem").val(item.name);
                            GetItemDetail();
                        }
                        catch (err) {
                            alert(err.message);
                        }

                    }
                });

            $('#token-input-txtMR_No').focus();
        }
        function Delete(row) {
            debugger;
            $(row).closest('tr').remove();

        }
        function GetItemDetail() {
            debugger;

            var itemID = $("#hditemID").val();

            debugger;
            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/Getitem",
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
                        alert("item already exists");
                        $("#txtItem").tokenInput("clear");
                    }
                    else {
                        if (parse[0].Active == true) {
                            $("#tblbodyPackage").append("<tr><td style='padding-top: 7px!important;'>" + length + "</td><td style='padding-top: 7px!important;padding-right: 3px!important; */'>" + parse[0].Item_Code + "</td><td style='padding-left: 8px!important;padding-top: 7px!important;'>" + parse[0].Description + "</td><td style='text-align:center;'>" + parse[0].Unit + "</td><td style='text-align: center;'><input type='text' name='Qty' id='txtQty" + length + "' style='font-size: 9px;width: 52px!important;text-align: right;margin-top: 2px;' autocomplete='off' onkeyup='calcutaeQty(this)'/></td><td id='tdstock' style='padding-left: 8px!important;padding-top: 7px!important;'>" + parse[0].Stock + "</td><td style='padding-top: 7px!important;padding-left: 8px!important;display:none;' contenteditable></td><td style='padding-top: 7px!important;padding-left: 8px!important' contenteditable></td><td><label class='fileContainer' style='font-size: 13px;margin-top: -3px;'><i class='glyphicon glyphicon-paperclip'></i><input type='file' name='fileuploadlist' id='fileuploadlist" + length + "'></label></td><td style='display:none'>" + parse[0].Item_ID + "</td><td><a href='#' onclick='Delete(this)'><i class='glyphicon glyphicon-trash' style='font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;'></i></a></td></tr>")
                            debugger;
                            if (stockchck == "true" || stockchck == true) {
                                $('#tdstock').show();
                                $('#thstock').show();
                            }
                            else {
                                $('#tdstock').hide();
                                $('#thstock').hide();
                            }
                            //<td><i class='glyphicon glyphicon-plus' style='font-size: 13px;margin-top: 5px;margin-left: 20px;'></i></td>
                            length++;
                            $("#txtItem").tokenInput("clear");
                            $('input').attr('autocomplete', 'off');
                        }
                        else {
                            alert("You have selected InActive items");
                            $("#txtItem").tokenInput("clear");
                        }
                    }
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function Approve() {
            debugger;

            //       elementIsClicked = true;



            var rowsnow = tblbodyPackage.rows.length;


            debugger;

            if (rowsnow < rowsoneditmode || rowsoneditmode < rowsnow) {

                debugger;

                alert("You have modified MIR ! Please Update before Approving");


                return false;


            }
            if (userupdate == false || userupdate == "False" || userupdate == 'False') {
                alert("You Dont Have Rights To Approve");
                $('#btnApprove').attr('disabled', true);
                $('#btnApprove').hide();
                return false;


            }


            var MIRId = '<% =Request.QueryString["ID"] %>';
              var user_id = '<% =AppConfig.UserID %>';
            PageMethods.ApproveMIR(MIRId, user_id, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 == "1") {
                    alert("Approved Done Successfully");
                    //                      location.reload();
                    location.reload();
                    //window.location.href = 'MaterialIssueRequest.aspx';

                }

            });
        }

        function UnApprove() {

            //      elementIsClicked = true;
            if (userupdate == false || userupdate == "False" || userupdate == 'False') {
                alert("You Dont Have Rights To unApprove");
                $('#btnUnApprove').attr('disabled', true);
                return false;


            }
            debugger;
            var MIRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.UnApproveMIR(MIRId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert("Un Approved Done Successfully");
                    location.reload();

                }
            });
        }


        function manupproval() {
            debugger;
            var MIRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.managerapproval(MIRId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert("managerial Approved Done Successfully");
                    location.reload();

                }
            });
        }
        function manunpproval() {
            debugger;
            var MIRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.managerunapproval(MIRId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert("managerial UnApproved Done Successfully");
                    location.reload();

                }
            });
        }
        debugger;
        function rcvdmir() {
            debugger;
            var MIRId = '<% =Request.QueryString["ID"] %>';
            PageMethods.recievemir(MIRId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    alert("Received Done Successfully");
                    location.reload();

                }
            });
        }

        function PrintMaterialIssueRequest() {
            debugger;
            var id = '<% =Request.QueryString["ID"] %>';
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            }
            window.location.href = url;
           // window.open = (url);
        }


        function GetReqNum() {
            $.ajax({
                type: "post",
                url: "MaterialIssueRequest.aspx/GetRequestNo",
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

            //       elementIsClicked = true;
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
            var Pirority = $("#ddlPriority").val();
            var InvOrg = $('#ddlInv_Org').val();
            var dept = $('#ddldept :selected').val();
            var Employee = $('#ddlEmployee :selected').val();
            var remarks = $('#txtRemarks').val();
            var chckreceived = $('#chckreceived').prop("checked");
            var itemId = $('#hditemID').val();
            var btnValue = $("#btnsave").val();
            //              var branch = $('#ddlBranch :selected').val();
            if (MIRNum == '') $('#txtReq_Num').addClass('ErrorAlert'); else $('#txtPr_Num').removeClass('ErrorAlert');
            if (MIRDate == '') $('#txtMIR_Date').addClass('ErrorAlert'); else $('#txtMIR_Date').removeClass('ErrorAlert');
            //if (Pirority == '0') $('#ddlPriority').addClass('ErrorAlert'); else $('#ddlPriority').removeClass('ErrorAlert');
            if (InvOrg == '0') $('#ddlInv_Org').addClass('ErrorAlert'); else $('#ddlInv_Org').removeClass('ErrorAlert');
            if (dept == '0') $('#ddldept').addClass('ErrorAlert'); else $('#ddldept').removeClass('ErrorAlert');
            //if (Employee == '0') $('#ddlEmployee').addClass('ErrorAlert'); else $('#ddlEmployee').removeClass('ErrorAlert');

            var tblLength = $("#tblPackage tr:gt(0)").length;
            if (tblLength == '0') {
                alert("Please Add Items")
                $('#tblPackage').addClass('ErrorAlert');
            } else {
                $('#tblPackage').removeClass('ErrorAlert');
            }

            //if (PrNum == '') $('#txtPr_Num').addClass('ErrorAlert'); else $('#txtPr_Num').removeClass('ErrorAlert');

            if (!$('#txtReq_Num').hasClass('ErrorAlert') && !$('#txtMIR_Date').hasClass('ErrorAlert') && !$('#txtRemarks').hasClass('ErrorAlert') && !$('#ddldept').hasClass('ErrorAlert') && !$('#tblPackage').hasClass('ErrorAlert') && !$('#ddlInv_Org').hasClass('ErrorAlert')) {

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
                    alert("Please Enter MIR Qty Or MIR  Qty Must be Greater than zero");
                    return false;
                }
                else {

                    $('#btnsave').attr('disabled', true);
                    $.ajax({
                        type: "post",
                        url: "MaterialIssueRequest.aspx/SaveMIR",
                        data: JSON.stringify({
                            "MIRId": MIRId,
                            "MIRNum": MIRNum,
                            "MIRDate": MIRDate,
                            "Pirority": Pirority,
                            "InvOrg": InvOrg,
                            "dept": dept,
                            "remarks": remarks,
                            "chckreceived": chckreceived,
                            "Employee": Employee,
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
                //details.TechSpec = $(this).find('td:eq(5)').text();
                details.Remarks = $(this).find('td:eq(6)').text();
                details.MIRId = id;
                details.itemId = $(this).find('td:eq(9)').text();
                detailAry.push(details);


            });
            var getuploadlist = $('input[name=fileuploadlist]').get();

            append_data = new FormData();

            for (var i = 0; i < getuploadlist.length; i++) {
                debugger;
                var filecomplete = getuploadlist[i].files;
                if (filecomplete.length > 0) {
                    append_data.append(filecomplete[0].name, filecomplete[0]);
                }


            }

            debugger;
            if (detailAry.length > 0) {
                $.ajax({
                    type: "POST",
                    url: "MaterialIssueRequest.aspx/SaveMIRDetails",
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
                        options.error = function (err) { alert(err.statusText); };
                        $.ajax(options);
                        //window.location.href = 'MaterialIssueRequest.aspx';

                        window.location = "MaterialIssueRequest.aspx?ID=" + id;

                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
            }

        }

        function checkstoreissueapprove(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/checkapproval",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    if (parse != undefined) {
                        var approvalcheck = parse.status;
                        if (approvalcheck === "Approved") {
                            $('#chckreceived').show();
                            $('#lblchckreceived').show();
                            $('#btnrcvd').show();
                            //$('#btnUnApprove').hide();
                            //$('#btnmanagerial_unapprove').hide();
                            //$('#btnrcvd').show();
                            //$('#btnrcvd').show();
                            //$('#btnrcvd').show();
                            //$('#btnrcvd').show();
                        }
                        if (rcv === true) {
                            $('#btnrcvd').hide();
                        }
                    }
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        var filt_status;
        var managerialapprove;
        var Inv_approval;
        var rcv;
        function LoadMIRMaster(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/LoadMIR",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    /* $("#chckreceived").attr('disabled', true);*/
                    var parse = JSON.parse(response.d);
                    $('#txtReq_Num').val(parse.Request_No);
                    var datetime = $.datepicker.formatDate('dd M yy', new Date(parseInt(parse.MIRDate.substring(6, 19))))
                    $('#txtMIR_Date').val(datetime);
                    filt_status = parse.Status;
                    managerialapprove = parse.managerial_approval;
                    rcv = parse.received;
                    setTimeout(function () {
                        $('#ddlPriority').val(parse.Priority);

                        $('#ddldept').val(parse.Department);
                        $('#ddlEmployee').val(parse.Employee);
                    }, 1000);
                    $('#txtRemarks').val(parse.Remarks);
                    $('#txt_Status').val(parse.Status);
                    $('#chckreceived').val(parse.received);
                    if (parse.received === true) {
                        $("#chckreceived").prop('checked', true);
                    }
                    else {
                        $("#chckreceived").prop('checked', false);
                    }
                    var checkstatusss = $('#txt_Status').val();
                    if (checkstatusss == 'Approved') {
                        $('#btnsave').hide();
                    }

                    if (parse.managerial_approval === true) {
                        $("#btnmanagerial_approve").hide();
                        $("#btnmanagerial_unapprove").show();
                        $('#btnApprove').hide();
                        $('#btnUnApprove').hide();

                    }
                    else {
                        $("#btnmanagerial_approve").show();
                        $("#btnmanagerial_unapprove").hide();
                        $('#btnApprove').hide();
                        $('#btnUnApprove').show();
                    }



                    setTimeout(function () {
                        // $('#ddlVendor').val(data.Vendor);
                        $('#ddlInv_Org').val(parse.InventoryOrganization);
                    }, 2000);
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


        var rowsoneditmode = '';
        function LoadLoadMIRDetail(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "MaterialIssueRequest.aspx/LoadMIRDetail",
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
                        //<div class="upload-btn-wrapper-custom"><button class="btn" style=height:36px>Attachments</button><input type="file"/></div>                         
                        var len = key + 1;
                        row += '<tr><td style="padding-top: 7px!important;">' + len + '</td><td style="padding-top: 7px!important;padding-right: 3px!important; */">' + parse[key].itemCode + '</td><td style="padding-left: 8px!important;padding-top: 7px!important;">' + parse[key].Description + '</td><td style="text-align:center;">' + parse[key].Unit + '</td><td style="text-align: center;"><input type="text"  value="' + parseInt(parse[key].MIRQty) + '" name="Qty" id="txtQty ' + counter + '" style="font-size: 9px;width: 52px!important;text-align: right;margin-top: 2px;" autocomplete="off" onkeyup="calcutaeQty(this)"/></td><td id="tdstock"></td><td style="padding-top: 7px!important;padding-left: 8px!important;display:none;" contenteditable></td><td style="padding-top: 7px!important;padding-left: 8px!important" contenteditable>' + parse[key].remarks + '</td><td> <label class="fileContainer" style="font-size: 13px;margin-top: -3px;"><i class="glyphicon glyphicon-paperclip"></i><input type="file" name="fileuploadlist" id="fileuploadlist' + key + '"></label></td><td style="display:none">' + parse[key].itemId + '</td><td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td></tr>';
                        //<td><i class="glyphicon glyphicon-plus" style="font-size: 13px;margin-top: 5px;;margin-left: 20px;"></i></td>
                    });

                    $("#tblPackage").append(row);
                    $('input').attr('autocomplete', 'off');
                    rowsoneditmode = tblbodyPackage.rows.length;
                    calcutaeQty();
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }

        function sendFile(ID) {
            debugger;
            var data = new FormData();
            data.append('file', $('#PR_UploadImage')[0].files[0]);
            data.append('ID', ID);
            $.ajax({
                type: 'post',
                url: '../UploadMaterialIssue.ashx',
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


    <style>
        .responstable th {
        }

        .responstable td {
            height: 0px !important;
            padding: 0 !important;
        }

        .table tr td:nth-child(2) {
            text-align: right !important;
        }

        input[type="text"] {
            font-size: 10px;
        }

        label {
            font-size: 10px;
        }

        select {
            font-size: 10px;
        }

        textarea {
            font-size: 10px;
        }

        .upload-btn-wrapper-custom {
            position: relative;
            overflow: hidden;
            display: inline-block;
        }

        ul.token-input-list {
            height: 23px !important;
            width: 692px !important;
        }

        div.token-input-dropdown {
            overflow: auto;
            max-height: 150px;
        }

        ul.token-input-list {
            width: 484px !important;
        }


        .btn-custom {
            border: 2px solid #3c8dbc;
            color: #3c8dbc;
            background-color: white;
            padding: 8px 20px;
            border-radius: 8px;
            font-size: 20px;
            font-weight: bold;
        }
        /*#0084ff87*/
        .fileContainer {
            height: 34px;
            background: #6fb3e0;
            border-radius: 0;
            float: left;
            padding: .5em;
            width: 21px;
            color: black;
            font-size: 13px;
            background-color: Transparent;
            background-repeat: no-repeat;
            border: none;
            cursor: pointer;
            overflow: hidden;
            outline: none;
            margin-left: 32px;
        }

        .fileContainer {
            overflow: hidden;
            position: relative;
        }

            .fileContainer [type=file] {
                cursor: inherit;
                display: block;
                font-size: 999px;
                filter: alpha(opacity=0);
                min-height: 100%;
                min-width: 100%;
                opacity: 0;
                position: absolute;
                right: 0;
                text-align: right;
                top: 0;
            }

        .ErrorAlert {
            border: 1px solid red !important;
        }
        /* Example stylistic flourishes */

        .fileContainer [type=file] {
            cursor: pointer;
        }


        .upload-btn-wrapper-custom input[type=file] {
            font-size: 100px;
            position: absolute;
            left: 0;
            top: 0;
            opacity: 0;
        }

        .btn {
            background-color: #6fb3e0 !important;
            border: 2px solid #6fb3e0;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <input type="hidden" id="hditemID" />
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="LblPr_Num">Request #</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="text" class="form-control" id="txtReq_Num" style="height: 22px;" name="txtReq_Num" value="New" readonly="readonly" />
            </div>
        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="LblPR_Date">MIR Date</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="text" class="form-control" style="height: 22px;" id="txtMIR_Date" name="txtMIR_Date" autocomplete="off" />
            </div>
        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="LblPriority">Priority</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <select id="ddlPriority">
                    <option value="0">Please Select</option>
                    <option value="1">High</option>
                    <option value="2">Medium</option>
                    <option value="3">Low</option>
                </select>
            </div>
        </div>
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2"></div>
    </div>


    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="Lbldept">Department<span style="color: red;">*</span></label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <select id="ddldept">
                    <%--<option value="0">Please Select</option>
<option value="002">Accounts</option>
<option value="003">IT</option>
<option value="004">Transport</option>
<option value="005">HR</option>--%>
                </select>
            </div>
        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="lblEmployee">Employee<span style="color: red;"></span></label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <select id="ddlEmployee">
                </select>
            </div>
        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="lbl_Status">Status</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="text" class="form-control" style="height: 22px;" id="txt_Status" name="txt_Status" readonly="readonly" />
            </div>
        </div>
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2"></div>
    </div>


    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-6 col-sm-6 col-lg-6 col-md-6">
            <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1" style="margin-right: 23px;">
                <label id="lblrem">Remarks</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <textarea id="txtRemarks" rows="2" cols="20" style="width: 483px;">
</textarea>
            </div>
        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="lblattach">Attachments</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="file" id="PR_UploadImage" />
            </div>
        </div>
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2"></div>
    </div>



    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-6 col-sm-6 col-lg-6 col-md-6">
            <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1" style="margin-right: 23px;">
                <label id="item">Item</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="text" class="form-control" id="txtItem" name="txtItem" placeholder="item" />
            </div>

        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1" style="margin-right: 23px; margin-top: -28px;">
                <%--<label id="Label1">Branch</label>--%>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <%--<select id="ddlBranch" onchange="GetWareHouseByBranch(this)" style="
    margin-top: -25px;
    margin-left: 73px;
"><option value="1">Main Branch Johar Town</option><option value="3">Green Town Branch</option></select>--%>
            </div>

        </div>
        <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="lblwarehouse">Warehouse<span style="color: red;">*</span></label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <select id="ddlInv_Org">
                </select>
            </div>
            <div class="col-xs-3 col-sm-3 col-lg-3 col-md-3">
                <label id="lblchckreceived">Received</label>
            </div>
            <div class="col-xs-9 col-sm-9 col-lg-9 col-md-9">
                <input type="checkbox" id="chckreceived" />

            </div>
        </div>
    </div>

    <%-- <tr>--%>

    <div style="/* width: 1293px; */overflow: scroll; height: 276px !important; height: auto;">
        <table class="table responstable" id="tblPackage" style="margin-top: 13px; font-size: 10px!important; width: 92% !important; overflow: scroll; height: auto">
            <thead>
                <th style="width: 40px; text-align: center;">MIR No.</th>
                <th style="width: 56px; text-align: center; font-size: 10px;">Item Code</th>
                <th style="width: 205px; text-align: center;">Description</th>
                <th style="width: 35px; text-align: center;">Unit</th>
                <th style="width: 43px; text-align: center;">MIR Qty</th>
                <th id="thstock" style="width: 43px; text-align: center;">Stock</th>
                <th style="width: 112px; text-align: center; display: none;">Technical Specifications</th>
                <th style="width: 126px; text-align: center;">Remarks</th>
                <th style="width: 32px!important; text-align: center;">Attachment</th>
                <%--<th style="width: 43px;text-align:center;">Stats</th>--%>
                <th style="width: 40px; text-align: center;">Delete</th>

            </thead>

            <tbody id="tblbodyPackage"></tbody>
        </table>


    </div>

    <table>
        <tr>
            <label style="margin-left: 462px;">Total Qty</label>
            <input type="text" id="totQty" name="totQty" readonly="readonly" style="width: 50px !important;" />
        </tr>
    </table>
    <%--    </tr>--%>
    <div class="purchaseOrderSubmitForm" style="margin-left: 47px; margin-top: 21px;">
        <table style="width: 1200px; font-size: 11px !important;">
            <tr>
                <td>
                    <div style="width: 1010px;">




                        <input type="button" value="Save" id="btnsave" onclick="SaveTest()" <%--style="font-size: 9px;"--%> />
                        &nbsp;
                        <input type="button" value="View List" onclick="window.location = 'MIRView.aspx'" />
                        &nbsp;
                        <input type="button" value="New" onclick="window.location = 'MaterialIssueRequest.aspx'" />
                        &nbsp;
                        <input type="button" style="width: 93px" value="Approve" id="btnApprove" onclick="Approve()" />
                        &nbsp;
                        <input type="button" style="width: 100px" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
                        &nbsp;
                        <input type="button" style="width: 174px; display: none;" value="Management Approve" id="btnmanagerial_approve" onclick="manupproval()" />
                        &nbsp;
                        <input type="button" style="width: 183px; display: none;" value="Management UnApprove" id="btnmanagerial_unapprove" onclick="manunpproval()" />
                        <input type="button" value="Print" name="btn_Print" id="btn_Print" onclick="PrintMaterialIssueRequest();" style="width: 81px;" />
                        <input type="button" value="Received" name="btnrcvd" id="btnrcvd" onclick="rcvdmir();" style="width: 100px; display: none;" />



                    </div>
                </td>
            </tr>
        </table>

    </div>


</asp:Content>
