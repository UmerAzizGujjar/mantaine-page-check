<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsIssuanceReturn.aspx.cs" Inherits="PMS.Inventory.GoodsIssuanceReturn" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <style>
                 .sidebar.h-sidebar .nav-list > li > a {
           text-align: center !important;
    	   line-height: 22px !important;
           height: auto !important;
	   font-family: Arial, sans-serif !important;
           padding: 10px 14px !important;
           font-weight: bold !important;
        }



.nav-list > li .submenu > li.hover > a {
		font-size: 13px !important;
		font-family: Arial, sans-serif !important;
		font-weight: bold !important;
}
         .ErrorAlert { 
            border: 1px solid red !important;
        }
          .responstable td {
             height:0px!important;
        padding:0!important;
        }
        label {
        font-size:10px;
        }
        select {
         font-size:10px;
           border-radius: 5px !important;
             }
        textarea {
          font-size:10px;
             }
         td {
          font-size:10px;
         }
         th {
             font-size: 10px;
         }
         input[type="text"] {
             font-size: 13px;
             border-radius: 5px !important;
         } 
</style>
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>
     <script type="text/javascript">
         var selectedOptions = '';
         $(document).ready(function () {
             $('#ddlMIR').select2();
             LoadDepartments();
             LoadOrganizations();
             var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
             if (SI_ID != "") {
                 LoadDetail(SI_ID);
                 setTimeout(function () {
                     $.each(selectedOptions, function (key, value) {
                         debugger;
                         $('#ddlBatchNum' + (key + 1) + '').val(selectedOptions[key].BatchNum);
                     });
                 }, 5000)
                 setTimeout(function () { LoadMaster(SI_ID); }, 1000);
                 $("#btnSave").val('Update');
             }
             getMIR();
             if (SI_ID == "") {
                 $('#btn_Print').hide();
                 $('#btnApprove').hide();
                 $('#btnUnApprove').hide();
                 $('#btnVoucher').hide();
             }
             else {
                 setTimeout(function () {
                     var status = $('#txtStatus').val();
                     if (status == "Approved") {
                         $('#btnSave').attr("disabled", 'disabled');
                         $('#btnApprove').attr("disabled", 'disabled');
                         $('#btnUnApprove').attr("disabled", false);
                         $('#btnVoucher').show();
                     }
                     if (status == "Created") {
                         $('#btnApprove').attr("disabled", false);
                         $('#btnUnApprove').attr("disabled", 'disabled');
                         $('#btnVoucher').hide();
                     }
                 }, 2000);
             }
             $('[id*=checkHeader]').click(function () {
                 var isTrue = $('#checkHeader').is(':checked');
                 if (isTrue) {
                     $('.chktd').prop('checked', true);
                     setTimeout(function () {
                         $("#tblMIRItemstModelTable tr:gt(0) input[type=checkbox]:checked ").each(function (key, value) {
                             var row = $(this);
                             append(row);
                         });
                     }, 1000);
                 }
                 else {
                     $('.chktd').prop('checked', false);
                 }
             });
             $('#btnAdd').on('click', function () {
                 var MIR_id = $("#ddlMIR").val();
                 LoadMIRDetail(MIR_id);
             });
             $('#ddlInventoryOrg').on('change', function () {
                 var id = $('#ddlInventoryOrg').val();
                 var table = $('#tblStoreIssueReturn');
                 table.find('tr:gt(0)').each(function (key, value) {
                     var item_id = $(value).find('td input[name=txtItemId]').val().trim();
                     var batcNo = '';
                     $.ajax({
                         type: "POST",
                         url: "GoodsIssuanceReturn.aspx/GetStock",
                         data: JSON.stringify({
                             'itemCode': item_id,
                             'batchNo': batcNo,

                             'wareHouse': id,
                         }),
                         contentType: "application/json; charset=utf-8",
                         dataType: "json",
                         success: function (response) {
                             $(value).find('td input[name=txtStoreStock]').val(response.d);
                         },
                         error: function (msg) {
                             alert("Could not load available stock");
                         }
                     });
                 });
             });
             $('#btnSave').on('click', function () {
                 debugger;
                 var checkstock = false;
                 var status;
                 var btnSave = $('#btnSave').val();
                 var table = $('#tblStoreIssueReturn');
                 var comapny_id = '0';
                 var department_id = $('#ddlDepartment').val();
                 var inventory_id = $('#ddlInventoryOrg').val();
                 var store_no = $('#txtStoreissueNo').val();
                 var StoreIssue_id = '0';
                 var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
                 if (SI_ID != "") {
                     StoreIssue_id = SI_ID;
                 }
                 else {
                     StoreIssue_id = '0';
                 }
                 var Item_list = [];
                 table.find('tr:gt(0)').each(function (key, value) {
                     var StoreStock = $(value).find('td input[name=txtStoreStock]').val();
                     var IssueQty = $(value).find('td input[name=txtIssueQty]').val();
                     var MIRQty = $(value).find('td input[name=txtmirQty]').val();
                     var Batch = $(value).find('td input[name=txtBatch]').val();
                     var BatchNum = $(value).find('td select[name=ddlBatchNum]').val();
                     if (parseFloat(IssueQty) > parseFloat(StoreStock)) {
                         alert('Issue Qty Must Be Less Than Total Stock');
                         checkstock = true;
                         return false;
                     }
                     if (Batch == "true") {
                         if (BatchNum == "0" || BatchNum == "") {
                             status = "errorBatch";
                         }
                     }
                     if (StoreStock == "" || StoreStock == 0 || StoreStock < 0) {
                         status = false;
                     }
                     else if (IssueQty == "" || IssueQty == 0 || IssueQty < 0 || parseInt(MIRQty) < parseInt(IssueQty)) {
                         status = "error";
                     }
                     else {
                         Item_list.push({
                             'mirDetailId': $(value).find('td:eq(0)').text(), 'mir_id': $(value).find('td:eq(1)').text(), 'ItemId': $(value).find('td input[name=txtItemId]').val(), 'Unit': $(value).find('td:eq(6)').text(), 'StoreStock': $(value).find('td input[name=txtStoreStock]').val(), 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'Qty': $(value).find('input[name=txtmirQty]').val(), 'IssueQty': $(value).find('input[name=txtIssueQty]').val(), 'BalanceQty': $(value).find('input[name=txtBlncQty]').val(), 'Department': $(value).find('td:eq(3)').text()
                         });
                     }
                 });
                 if (status == false) {
                     alert("Stock store Must Be Greater than 0");
                     return false;
                 }
                 else if (status == "error") {
                     alert("Issue Must Be Greater than 0 OR SIN Qty not greater than MIR Qty");
                     return false;
                 }
                 else if (status == "errorBatch") {
                     alert("Please Enter Batch Number");
                     return false;
                 }
                 else {
                     if (checkstock == true) {
                         return false;
                     }
                     var AllItemDetail = { 'StoreIssue_id': StoreIssue_id,'Store_Issue_No': store_no, 'comapny_id': comapny_id, 'department_id': department_id, 'inventory_id': inventory_id, 'ItemList': Item_list };
                     var department_id = $('#ddlDepartment').val();
                     var inventory_id = $('#ddlInventoryOrg').val();
                     var length = $("#tblStoreIssueReturn tr:gt(0)").length;
                     if (department_id == '0') $('#ddlDepartment').addClass('ErrorAlert'); else $('#ddlDepartment').removeClass('ErrorAlert');
                     if (inventory_id == '0') $('#ddlInventoryOrg').addClass('ErrorAlert'); else $('#ddlInventoryOrg').removeClass('ErrorAlert');
                     if (length == "0") $('#tblStoreIssueReturn').addClass('ErrorAlert'); else $('#tblStoreIssueReturn').removeClass('ErrorAlert');
                     if (!$('#ddlDepartment').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#ddlInventoryOrg').hasClass('ErrorAlert') && !$('#tblStoreIssueReturn').hasClass('ErrorAlert')) {
                         $(this).attr('disabled', true);
                         PageMethods.Save(btnSave, JSON.stringify(AllItemDetail), function (res) {
                             alert('Data Save Successfully');
                             $('#btnSave').val("Update");
                             window.location = "GoodsIssuanceNote.aspx?SI_ID=" + res;
                             $('#btnSave').val("Update");
                         });
                     }
                 }
             });
         });
         function GetNewSINNo() {
             PageMethods.GetNewSINNo(function (resp) {
                 $('#txtStoreissueNo').val(resp);
             },
                 function (error) {
                     alert(error.get_message());
                 })
         }
         function loadstock() {
             var id = $('#ddlInventoryOrg').val();
             var table = $('#tblStoreIssueReturn');
             table.find('tr:gt(0)').each(function (key, value) {
                 var item_id = $(value).find('td input[name=txtItemId]').val().trim();
                 var batcNo = '';
                 $.ajax({
                     type: "POST",
                     url: "GoodsIssuanceNote.aspx/GetStock",
                     data: JSON.stringify({
                         'itemCode': item_id,
                         'batchNo': batcNo,
                         'wareHouse': id,
                     }),
                     contentType: "application/json; charset=utf-8",
                     dataType: "json",
                     success: function (response) {
                         $(value).find('td input[name=txtStoreStock]').val(response.d);
                     },
                     error: function (msg) {
                         alert("Could not load available stock");
                     }
                 });
             });
         }
         function LoadDepartments() {
             PageMethods.LoadDepartments(function (res) {
                 var parsed_Date = JSON.parse(res);
                 var option = '<option value="0"> Please Select </option>';
                 $(parsed_Date).each(function (key, index) {
                     option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                 });
                 $('#ddlDepartment').html(option);
             });
         }
         function LoadOrganizations() {
             PageMethods.LoadOrganizations(function (res) {
                 var parsed_Date = JSON.parse(res);
                 var option = '<option value="0"> Please Select </option>';
                 $(parsed_Date).each(function (key, index) {
                     option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                 });
                 $('#ddlInventoryOrg').html(option);
             });
         }       
         var count = 0;
         function makeDropDown(itemID, IsBatch, rowIndex) {
             count++;
             var SI_ID = '<%= Request.QueryString["SI_ID"]%>';
             if (SI_ID != "") {
                 var wareHouse = $('#ddlInventoryOrg').val();
                 var ddlHTML = '';
                 if (IsBatch == "True" || IsBatch == "true") {
                     if (wareHouse != null) {
                         PageMethods.LoadItemBatches(itemID, wareHouse, function (res) {

                             var parsed_Date = JSON.parse(res);
                             var option = '<option value="0"> Please Select </option>';
                             $(parsed_Date).each(function (key, index) {
                                 option += '<option value=' + parsed_Date[key].Batch_No + '>' + parsed_Date[key].Batch_No + '</option>'
                             });

                             ddlHTML = option;

                             var tblData = document.getElementById('tblStoreIssueReturn');
                             var index = tblData.rows.length - 1;
                             $('#ddlBatchNum' + rowIndex).append(ddlHTML);

                         });
                     }
                     else {
                         alert("Please Select Ware House");
                     }
                 }
             }
             else {
                 if (count == 1) {
                     var wareHouse = $('#ddlInventoryOrg').val();
                     var ddlHTML = '';
                     if (IsBatch == "True" || IsBatch == "true") {
                         if (wareHouse != null) {
                             PageMethods.LoadItemBatches(itemID, wareHouse, function (res) {
                                 var parsed_Date = JSON.parse(res);
                                 var option = '<option value="0"> Please Select </option>';
                                 $(parsed_Date).each(function (key, index) {
                                     option += '<option value=' + parsed_Date[key].Batch_No + '>' + parsed_Date[key].Batch_No + '</option>'
                                 });

                                 ddlHTML = option;

                                 var tblData = document.getElementById('tblStoreIssueReturn');
                                 var index = tblData.rows.length - 1;
                                 $('#ddlBatchNum' + rowIndex).append(ddlHTML);
                             });
                         }
                         else {
                             alert("Please Select Ware House");
                         }
                     }
                 }
             }
             return ddlHTML;
         }
         function append(anchor) {
             debugger;
             count = 0;
             var rows = '';
             var row = $(anchor).parents('tr')[0];
             var mir_id = $($(row).find('td')[1]).text();
             var item_id = $($(row).find('td')[2]).text();
             var item_name = $($(row).find('td')[3]).text();
             var unit = $($(row).find('td')[6]).text();
             var mir_detail_id = $($(row).find('td')[7]).text();
             var mir_date = $($(row).find('td')[8]).text();
             var length = $("#tblStoreIssueReturn tr").length;
             var Qty = $($(row).find('td')[4]).text();
             var itemcode = $($(row).find('td')[5]).text();
             var department = $($(row).find('td')[9]).text();
             var IsBatch = $($(row).find('td')[10]).text();
             var Stock = $($(row).find('td')[11]).text();
             var balance = $($(row).find('td')[12]).text();
             if (balance == "null" || balance == "") {
                 balance = 0
             }
             if (unit == "null")
                 unit = "";
             if (Qty == "null") {
                 Qty = 0;
             }
             if (Stock == null || Stock == 0) {
                 Stock = 0;
             }
             if (IsBatch == "true" || IsBatch == "True") {
                 Stock = 0;
             }
             var length = $("#tblStoreIssueReturn tr:gt(0)").length;
             if (length > 0) {
                 length = length + 1;
             }
             else {
                 length = 1;
             }
             var test_array = $('#tblStoreIssueReturn').find('input[name=txtItemCode][value=' + itemcode + ']');
             if (test_array.length > 0) {
                 alert('This Item already added!');
                 return false;
             }
             else {
                 rows = '<tr>' +
                     '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_detail_id + ' </td>' +
                     '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + mir_id + ' </td>' +
                     '<td  style="padding-top: 2px;height: 27px !important;"><input type="text" style="  font-size: 10px;width: 75px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left:4px;" id="txtmirdate' + length + '" name="txtmirdate" value="' + $.datepicker.formatDate('dd M yy', new Date(parseInt(mir_date.substring(6, 19)))) + '" disabled/></td>' +
                     '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + department + '</td>' +
                     '<td  style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + itemcode + '<input type="text" name="txtItemCode" value=' + itemcode + ' style="display:none;"/></td>' +
                     '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + item_name + '</td>' +
                     '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + unit + '</td>' +
                     '<td><select id="ddlBatchNum' + length + '" name="ddlBatchNum" onChange="CheckBatch(this)" style="width: 75px !IMPORTANT;" ></select></td>' +
                     '<td style="padding-top: 9px;text-align: center;padding-top: 2px !important;"  ><input type="text" id="txtStoreStock' + length + '" name="txtStoreStock" readonly=true value="' + Stock + '" style="height: 22px!important;width: 70px !important;" ></td>' +
                     '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px;  width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtmirQty' + length + '" name="txtmirQty" value="' + Qty + '" disabled/></td>' +
                     '<td style="paddin g-top: 2px;"><input type="text" style=" font-size: 10px; width: 64px!important;                                        height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtIssueQty' + length + '" name="txtIssueQty" value="0" onkeyup="calculateBalanceQty(this)"/></td>' +
                     '<td style="padding-top: 2px;"> <input type="text" value="' + balance + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBlncQty' + length + '" name="txtBlncQty" readonly="readonly"/></td>' +
                     '<td style="padding-top: 2px;"><input type="text" id="txtRemarks' + length + '" name="txtRemarks" style="height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;"/> </td>' +
                     '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + item_id + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtItemId' + length + '" name="txtItemId"/></td>' +
                     '<td style="padding-top: 2px;display:none;"><input type="hidden" value="' + IsBatch + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBatch' + length + '" name="txtBatch"/></td>'
                     + '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td></tr>';
                 $("#tblStoreIssueReturn tbody").append(rows);
                 loadstock();
                 length++;
             }
         }
         var departmentid = '';
         var warehouseid = '';
         function LoadMIRDetail(MIR_id) {
             PageMethods.getStoreIssueByID(MIR_id, function (data) {
                 var parsed_Date = JSON.parse(data);
                 departmentid = parsed_Date[0].Department;
                 warehouseid = parsed_Date[0].InventoryOrganization;               
                 $('#tblMIRItemstModelTable tbody tr').remove();
                 var rows = "";
                 for (var i = 0; i < parsed_Date.length; i++) {
                     rows =
                         '<tr>' +
                         '<td><input class="chktd" id="chktd" name="chktd" type="checkbox" style=" margin-top: -2px; margin-left: 1px;" onclick="append(this)"/></td>' +
                         '<td style="display:none;">' + parsed_Date[i].MaterialRequest_Id + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].Item_Id + '</td>' +
                         '<td>' + parsed_Date[i].Description + '</td>' +
                         '<td style="display:none;">' + parseFloat(parsed_Date[i].MIRQty).toFixed(2) + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].Item_Code + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].Unit + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].MaterialRequestDetail_Id + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].MIRDate + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].Department + '</td>' +
                         '<td style="display:none;">' + parsed_Date[i].IsBatch + '</td>' +
                         '<td style="display:none;">' + parseFloat(parsed_Date[i].Stock).toFixed(2) + '</td>' +
                         '<td style="display:none;">' + parseFloat(parsed_Date[i].Balance).toFixed(2) + '</td>' +
                         '<td style="display:none;">StoreStock</td>' +
                         '</tr>';
                     $('#tblMIRItemstModelTable tbody').append(rows);
                 }
                 $('#POItemsModel').modal({
                     backdrop: 'static'
                 });
             });
         }
         function CheckBatch(anchor) {
             var row = $(anchor).parents('tr')[0];
             var Item_code = $($(row).find('input[name=txtItemCode]')).val();
             var batchNum = $($(row).find('select[name=ddlBatchNum]')).val();
             var invOrg = $('#ddlInventoryOrg').val();
             PageMethods.CheckBatch(Item_code, batchNum, invOrg, function (res) {
                 var parsed_stock = JSON.parse(res);
                 if (parsed_stock != "") {
                     $($(row).find('input[name=txtStoreStock]')).val(parseInt(parsed_stock));
                 }
                 else {
                     $($(row).find('input[name=txtStoreStock]')).val(0);
                 }
             });
         }
         function getMIR() {
             $.ajax({
                 type: "POST",
                 url: "GoodsIssuanceReturn.aspx/getMIR",
                 data: "",
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     var parsed_Date = JSON.parse(response.d);
                     var options = '<option value="0">Select</option>';
                     $(parsed_Date).each(function (key, index) {
                         options += '<option value=' + parsed_Date[key].MIR + '>' + parsed_Date[key].MIR_No + '</option>';
                     })
                     $("#ddlMIR").html(options);
                 },
                 failure: function (response) {
                     alert("In failure method");
                 }
             });
         }
         function calculateBalanceQty(anchor) {
             var row = $(anchor).parents('tr')[0];
             var Item_qty = $($(row).find('input[name=txtmirQty]')).val();
             var Issue_Qty = $($(row).find('input[name=txtIssueQty]')).val();
             var Balance = parseInt(Item_qty) - parseInt(Issue_Qty);
             $($(row).find('input[name=txtBlncQty]')).val(Balance);
         }
         function LoadMaster(SI_ID) {
             PageMethods.LoadMaster(SI_ID, function (res) {
                 var result = JSON.parse(res);
                 $('#txtStoreissueNo').val(result[0].Store_Issue_No);
                 $('#txtStatus').val(result[0].Status);
                 setTimeout(function () { $('#ddlInventoryOrg').val(result[0].Organization_Id); }, 2000);
                 setTimeout(function () { $('#ddlDepartment').val(result[0].Department_Id); }, 2000);
             });
         }
         function ExcludeFromPayment(anchor) {
             var a = confirm("Are you sure You want to delete");
             if (a == true) {
                 console.clear();
                 var row = $(anchor).parents('tr')[0];
                 row.remove();
             }
         }
         function LoadDetail(SI_ID) {
             PageMethods.LoadDetail(SI_ID, function (res) {
                 debugger;
                 var result = JSON.parse(res);
                 selectedOptions = result;
                 var rows = '';
                 $(result).each(function (key, value) {
                     if (result[key].BatchNum == null) {
                         result[key].BatchNum = "";
                     }
                     if (result[key].Unit == null) {
                         result[key].Unit = ";"
                     }
                     rows += '<tr>' +
                         '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + result[key].MIR_Detail_Id + ' </td>' +
                         '<td style="padding-top: 9px;height: 27px !important;text-align: center;padding-top: 6px !important;">' + result[key].MIR_Id + ' </td>' +
                         '<td  style="padding-top: 2px;height: 27px !important;"><input type="text" style=" font-size: 10px;width: 75px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left:4px;" id="txtmirdate' + key + '" name="txtmirdate" value="' + result[key].Mir_Date + '" disabled/></td>' +
                         '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Department + '</td>' +
                         '<td  style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Item_code + '<input type="text" name="txtItemCode" value=' + result[key].Item_code + ' style="display:none;"/></td>' +
                         '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Description + '</td>' +
                         '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"> ' + result[key].Unit + '</td>' +
                         '<td><select style="width:80px!important;" id="ddlBatchNum' + (key + 1) + '" name="ddlBatchNum" onChange="CheckBatch(this)"></select></td>' +
                         '<td style="padding-top: 9px;text-align: center;padding-top: 6px !important;"  ><input style="width:47px!important;" type="text" id="txtStoreStock' + length + '" name="txtStoreStock" readonly=true value="' + parseFloat(result[key].Store_Stock).toFixed(2) + '"></td>' +
                         '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px;  width: 64px!important;height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtmirQty' + key + '" name="txtmirQty" value="' + parseFloat(result[key].MIR_Qty).toFixed(2) + '" disabled/></td>' +
                         '<td style="padding-top: 2px;"><input type="text" style="font-size: 10px; width: 64px!important;                                        height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtIssueQty' + key + '" name="txtIssueQty" value="' + parseFloat(result[key].Issue_Qty).toFixed(2) + '" onkeyup="calculateBalanceQty(this)"/></td>' +
                         '<td style="padding-top: 2px;"> <input type="text" value="' + parseFloat(result[key].Balance_Qty).toFixed(2) + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtBlncQty' + key + '" name="txtBlncQty"/></td>' +
                         '<td style="padding-top: 2px;"><input type="text" id="txtRemarks' + key + '" style="height: 22px;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" name="txtRemarks" value="' + result[key].Remarks + '"/> </td>' +
                         '<td style="display:none;padding-top: 2px;"><input type="hidden" value=" ' + result[key].Item_Id + '" style=" font-size: 10px;height: 22px;  width: 64px!important;margin-top: 2px;margin-bottom: 0px;margin-left: 4px;" id="txtItemId' + length + '" name="txtItemId"/></td>' +
                         '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td></tr>';
                 });
                 $("#tblStoreIssueReturn tbody").append(rows);
                 setTimeout(function () {
                     $.each(selectedOptions, function (key, value) {
                         makeDropDown(result[key].Item_Id, result[key].IsBatch, (key + 1));
                     });
                 }, 7000);
             });
         }
         function Approve() {
             var SINId = '<% =Request.QueryString["SI_ID"] %>';
                var user_id = '<% =AppConfig.UserID %>';
                PageMethods.ApproveSIN(SINId,user_id, function (Tests) {
                  debugger
                  var message = JSON.parse(Tests);
                  if (message[0].Column1 != null || message[0].Column1 != "")
                  {
                      alert(message[0].Column1);
                      location.reload();
                  }
              });
          }

          function UnApprove() {              
              var SINId = '<% =Request.QueryString["SI_ID"] %>';
              PageMethods.UnApproveSIN(SINId, function (Tests) {
                  debugger
                  var message = JSON.parse(Tests);
                  if (message[0].Column1 !="" || message[0].Column1 !=null) {
                      alert(message[0].Column1);
                      location.reload();
                  }
              });
          }
                function PrintVoucher()
                {
                var id = '<% =Request.QueryString["SI_ID"] %>';
                var locationInfo = window.location;
                var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SIN Voucher&TransID=' + id + '&TransType=SIN';
                if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=SIN Voucher&TransID=' + id + '&TransType=SIN';
             }
             window.open(url, '_blank');
         }
         function btn_Print() {
             var id = '<% =Request.QueryString["SI_ID"] %>';
             var locationInfo = window.location;
             var url = '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + id;
             if (!locationInfo.origin.includes('localhost')) {
                 var urlInfo = window.location.href.split('/');
                 var ip = urlInfo[2];
                 var foldername = urlInfo[3];
                 url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=StoreIssueBasePrint&ReportTitle=Store Issue Note&SI_ID=' + id;
             }
             window.open(url, '_blank');
         }
     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <form id="item"> 
     <div class="row">
   <input type="hidden" id="hditemID" />
	  <div class="col-lg-4 col-md-3 col-sm-4">
          <label class="">Store Return No</label>
          <input type="text" readonly="readonly" id="txtStorereturnNo" class="form-control" name="txtStorereturnNo" value="New" />
      </div>
         <div class="col-lg-3 col-md-3 col-sm-3">
                <label class="">Department</label>
                <select id="ddlDepartment" class="form-control">
                </select>
            </div>
         <div class="col-md-3">
             <label class="">Warehouse</label>
             <select id="ddlInventoryOrg" class="form-control">
             </select>
         </div>
	  </div>
        <br />
        <div class="row">
            <div class="col-lg-3 col-md-3 col-sm-4">
                <label>GIR#</label>
                <select id="ddlMIR"></select>
            </div>
            <div class="col-lg-1 col-md-3 col-sm-4">
                <input type="button" value="Add" id="btnAdd" class="form-control" style="margin-top: 20px; width: 71px" />
            </div>
            
            <div class="col-lg-3 col-md-3 col-sm-3">
                <label>Status</label>
                <input type="text" id="txtStatus" class="form-control" name="txtStatus" readonly="readonly" />
            </div>
             
          </div>
        <br />
    </form>

  <div class="row"  style="width: 1078px!important;overflow: scroll;height: 276px !important;height: auto;margin-top: 18px;">
<div class="col-12">
     <table class="table table-bordered responstable" id="tblStoreIssueReturn" style="margin-left: 7px;">
        <thead style="font-size: 10px;">
          <tr>          
            <th>Request #</th>
	        <th>GIR #</th>
	        <th>GIR App Date</th>
	        <th>Department</th>
	        <th>Item Code</th>
	        <th>Item Description</th>
	        <th>UOM</th>
            <th>Batch Num</th>
	        <th>Store Stock</th>
	        <th>GIR Qty</th>
	        <th>Return Qty</th>
	        <th>Balance Qty</th>
	        <th>Remarks</th>
            <th>Action</th>
          </tr>
        </thead>
         <tbody>
       </tbody>
      </table>  
    </div>
  </div>
  <div class="col-.5"></div>
    	<br>
	<div class="row">
		<div class="col-md-12" style="margin-left:117px;">
            <input type="button" class="returnbtn" id="btnSave" value="Save" style="font-size: 10px;width: 93px;height: 34px !important;" />
             &nbsp;<input type="button" name="" value="Print" style="height:32px !important;" onclick="btn_Print()" />
            <input type="button" value="View List" onclick="window.location = 'GoodsIssuanceReturnView.aspx'" />
            &nbsp;<input type="button" value="New" onclick="window.location = 'GoodsIssuanceReturn.aspx'" />
            &nbsp;<input type="button" style="width: 93px" value="Approve" id="btnApprove"  onclick="Approve()" />           
            &nbsp;<input type="button" style="width: 93px" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
            &nbsp;<input type="button" style="width: 93px" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
		</div>
    </div>
      <div id="POItemsModel" class="modal fade" role="dialog">
        <div class="modal-dialog">           
            <div class="modal-content" style="width: 1000px; margin-left: -270px; height: 505px;">
                <div class="modal-header">
                    <button type="button" style="width: auto;" class="close" data-dismiss="modal">&times;</button>
                    <h4 class="modal-title">Add GIR Items</h4>
                </div>
               <input type="hidden" id="txthiddentr" name="txthidddentr" />
                 <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                <table class="table" style="width: 953px; height: 146px !important; height: auto; overflow: scroll;" id="tblMIRItemstModelTable">
                    <thead>
                        <tr>
                            <th style="width: 32px;"><input type="checkbox" id="checkHeader" value="false"/></th>
                            <th style="display:none;">MIR ID </th>
                            <th style="display:none;" >Item ID</th>
                            <th>Item Name</th>
                             <th style="display:none;"></th>
                             <th style="display:none;"></th>
                             <th style="display:none;"></th>                               
                        </tr>
                    </thead>
                    <tbody>
                    </tbody>
                </table>
            </div>
             <div class="modal-footer">
                    <input type="button" id="PoItem" name="PoItem" value="Done" style="background-color:green!important;" data-dismiss="modal"/>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
