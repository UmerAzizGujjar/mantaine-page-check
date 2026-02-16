<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsRerturnNote.aspx.cs" Inherits="PMS.Modules.Inventory.GoodsRerturnNote" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ddlGIN').select2();
            GetWareHouseCondition();
            LoadDepartments();
            LoadOrganizations();
            var SR_ID = '<%= Request.QueryString["SR_ID"]%>';
            if (SR_ID != "") {


                setTimeout(function () { LoadGRNMaster(SR_ID); }, 1000);
                setTimeout(function () { LoadGRNDetail(SR_ID); }, 2500);
                $("#btnSave").val('Update');
            }


            $('#ddlInventoryOrg').change(function () {
                if (warehouseCond == "01") {
                    GetGIN();
                    $("#ddlInventoryOrg").attr('disabled', true);
                }

            });

            $('#btnAdd').on('click', function () {
                debugger;
                var GIN_id = $("#ddlGIN").val();
                LoadGINMaster(GIN_id);
            });
        });
        var departmentid = '';
        var warehouseid = '';
       
        function LoadGRNMaster(SR_ID) {
            debugger
            PageMethods.LoadMaster(SR_ID, function (res) {
                debugger
                var result = JSON.parse(res);
                $('#txtStoreReturnNo').val(result[0].Store_Return_NO);
                $('#txtStatus').val(result[0].Status);
                var organizationId = result[0].WareHouse;
                setTimeout(function () {
                    $('#ddlInventoryOrg').val(organizationId).trigger('change');
                    $('#ddlInventoryOrg').attr('disabled', 'disabled');
                }, 2000);
                setTimeout(function () {
                    $('#ddlDepartment').val(result[0].Department_Id).trigger('change');
                    $('#ddlDepartment').attr('disabled', 'disabled');
                }, 2000);
               //initializeMRNoDropdown(result.query.MR_No);
                //$('#ddlMRNo').val(result.query.MR_No).trigger('change');
            });
        }
        function LoadGRNDetail(GIN_id) {
            debugger
            PageMethods.LoadDetail(GIN_id, function (data) {
                debugger
                var parsed_Date = JSON.parse(data);
                var rows = "";
                for (var i = 0; i < parsed_Date.length; i++) {
                    var length = $("#tblGINItems tr:gt(0)").length;
                    if (length > 0) {
                        length = length + 1;
                    }
                    else {
                        length = 1;
                    }
                    rows =
                        '<tr>' +
                        '<td><input type="hidden" id="SIN_No" name= "SIN_No" value="' + parsed_Date[i].SIN_No + '"/>' + parsed_Date[i].SIN_No + '</td>' +
                        '<td style="display:none;"><input type="hidden" id="item_Id" name= "item_Id" value="' + parsed_Date[i].Item_Id + '"/>' + parsed_Date[i].Item_Id + '</td>' +
                        '<td><input type="hidden" id="Approvedate" name= "Approvedate" value="' + parsed_Date[i].Approvedate + '"/>' + parsed_Date[i].Approvedate + '</td>' +
                        '<td><input type="hidden" id="txtDepartment" name= "txtDepartment" value="' + parsed_Date[i].Department + '"/>' + parsed_Date[i].Department + '</td>' +
                        '<td><input type="hidden" id="Item_code" name= "Item_code" value="' + parsed_Date[i].Item_code + '"/>' + parsed_Date[i].Item_code + '</td>' +
                        '<td><input type="hidden" id="item_Name" name= "item_Name" value="' + parsed_Date[i].Description + '"/>' + parsed_Date[i].Description + '</td>' +
                        '<td><input type="hidden" id="Unit" name= "Unit" value="' + parsed_Date[i].Unit + '"/>' + parsed_Date[i].Unit + '</td>' +
                    '<td><input type="hidden" id="BatchNum' + length +'" name= "BatchNum" value="' + parsed_Date[i].Batch_Number + '"/>' + parsed_Date[i].Batch_Number + '</td>' +
                        '<td><input type="hidden" id="SaveTimeStock" name= "SaveTimeStock" value="' + parseFloat(parsed_Date[i].Store_Stock).toFixed(2) + '"/>' + parseFloat(parsed_Date[i].Store_Stock).toFixed(2) + '</td>' +
                    '<td><input type="hidden" id="Issue_Qty' + length +'" name= "Issue_Qty" value="' + parseFloat(parsed_Date[i].Store_Issue_Qty).toFixed(2) + '"/>' + parseFloat(parsed_Date[i].Store_Issue_Qty).toFixed(2) + '</td>' +
                    '<td><input type="text" id="Return_Qty' + length +'" name= "Return_Qty" value="' + parseFloat(parsed_Date[i].Stock_Return_Qty).toFixed(2) + '"/></td>' +
                    '<td><input type="text" readonly id="Balance_Stock' + length + '" name= "Balance_Stock" onkeyup="CalculateBlance(this)" value="' + parseFloat(parsed_Date[i].BalanceStock).toFixed(2) + '"/></td>' +
                    '<td><input type="text" id="txtRemarks" name= "txtRemarks" value=""/></td>' +
                    '<td style="display:none;"><input type="hidden" id="txtBalance_Stock' + length + '" name= "txtBalance_Stock" readonly value="' + parseFloat(parsed_Date[i].BalanceStock).toFixed(2) + '"/></td>' +
                    '<td style="display:none;"><input type="hidden" id="txtRate" name= "txtRate" value="' + parseFloat(parsed_Date[i].Rate).toFixed(2) + '"/></td>' +
                    '<td style="display:none;"><input type="hidden" id="Store_Issue_Detail_Id" name= "Store_Issue_Detail_Id" value="' + parsed_Date[i].SIN_Details + '"/></td>' +
                        '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                        '</tr>';
                    $('#tblGINItems tbody').append(rows);
                }

            });
        }
        var warehouseCond;
        function GetWareHouseCondition() {
            debugger;
            $.ajax({
                type: "POST",
                url: "GoodsRerturnNote.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {

                    }
                    else {
                      
                        GetGIN();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function GetNewSRNNo() {
            PageMethods.GetNewSRNNo(function (resp) {
                $('#txtStoreReturnNo').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function LoadDepartments() {
            PageMethods.LoadDepartments(function (res) {
                var parsed_Date = JSON.parse(res);
                var option = '<option value="0"> Please Select </option>';
                $(parsed_Date).each(function (key, index) {
                    option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                });
                $('#ddlDepartment').html(option);
                $('#ddlDepartment').select2();
                $('#ddlDepartment').addClass('readonly');
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
                $('#ddlInventoryOrg').select2();
                $('#ddlInventoryOrg').addClass('readonly');
            });
        }

        function GetGIN() {
            debugger;
            var warehouse = $("#ddlInventoryOrg").val();
            if (warehouse == null || warehouse == undefined) {
                warehouse = '0';
            }
            $.ajax({
                type: "POST",
                url: "GoodsRerturnNote.aspx/GetGIN",
                data: JSON.stringify({ warehouse: warehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Date = JSON.parse(response.d);
                    var options = '<option value="0">Select</option>';
                    $(parsed_Date).each(function (key, index) {
                        options += '<option value=' + parsed_Date[key].S_Id + '>' + parsed_Date[key].S_No + '</option>';
                    });
                    $("#ddlGIN").html(options);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
        function LoadGINMaster(GIN_id) {
            debugger
            PageMethods.LoadSINMaster(GIN_id, function (data) {
                debugger
                var parsed_Date = JSON.parse(data);
                departmentid = parsed_Date[0].Department_Id;
                warehouseid = parsed_Date[0].Organization_Id;
                $('#ddlDepartment').val(parsed_Date[0].Department_Id).trigger('change');
                $('#ddlDepartment').attr('disabled', true);
                $('#ddlInventoryOrg').val(parsed_Date[0].Organization_Id).trigger('change');
                $("#ddlInventoryOrg").attr('disabled', true);
                $('#tblMIRItemstModelTable tbody tr').remove();
                LoadGINDetail(GIN_id);
            });
        }
        function LoadGINDetail(GIN_id) {
            debugger
            PageMethods.LoadSINDetail(GIN_id, function (data) {
                debugger
                var parsed_Date = JSON.parse(data);
                var rows = "";
                for (var i = 0; i < parsed_Date.length; i++) {
                    var length = $("#tblGINItems tr:gt(0)").length;
                    if (length > 0) {
                        length = length + 1;
                    }
                    else {
                        length = 1;
                    }
                    rows =
                        '<tr>' +
                    '<td><input type="hidden" id="SIN_No' + length +'" name= "SIN_No" value="' + parsed_Date[i].SIN_No + '"/>' + parsed_Date[i].SIN_No + '</td>' +
                    '<td style="display:none;"><input type="hidden" id="item_Id' + length +'" name= "item_Id" value="' + parsed_Date[i].Item_Id + '"/>' + parsed_Date[i].Item_Id + '</td>' +
                    '<td><input type="hidden" id="Approvedate' + length +'" name= "Approvedate" value="' + parsed_Date[i].Approvedate + '"/>' + parsed_Date[i].Approvedate + '</td>' +
                    '<td><input type="hidden" id="txtDepartment' + length +'" name= "txtDepartment" value="' + parsed_Date[i].Department + '"/>' + parsed_Date[i].Department + '</td>' +
                    '<td><input type="hidden" id="Item_code' + length +'" name= "Item_code" value="' + parsed_Date[i].Item_code + '"/>' + parsed_Date[i].Item_code + '</td>' +
                    '<td><input type="hidden" id="item_Name' + length +'" name= "item_Name" value="' + parsed_Date[i].Description + '"/>' + parsed_Date[i].Description + '</td>' +
                    '<td><input type="hidden" id="Unit' + length +'" name= "Unit" value="' + parsed_Date[i].Unit + '"/>' + parsed_Date[i].Unit + '</td>' +
                    '<td><input type="hidden" id="BatchNum' + length +'" name= "BatchNum" value="' + parsed_Date[i].BatchNum + '"/>' + parsed_Date[i].BatchNum + '</td>' +
                    '<td><input type="hidden" id="SaveTimeStock' + length +'" name= "SaveTimeStock" value="' + parseFloat(parsed_Date[i].SaveTimeStock).toFixed(2) + '"/>' + parseFloat(parsed_Date[i].SaveTimeStock).toFixed(2) + '</td>' +
                    '<td><input type="hidden" id="Issue_Qty' + length +'" name= "Issue_Qty" value="' + parseFloat(parsed_Date[i].Issue_Qty).toFixed(2) + '"/>' + parseFloat(parsed_Date[i].Issue_Qty).toFixed(2) + '</td>' +
                    '<td><input type="text" id="Return_Qty' + length +'" name= "Return_Qty" onkeyup="CalculateBlance(this)" value="0"/></td>' +
                    '<td><input type="text" id="Balance_Stock' + length +'" name= "Balance_Stock" readonly value="' + parseFloat(parsed_Date[i].Balance_Stock).toFixed(2) + '"/></td>' +
                    
                    '<td><input type="text" id="txtRemarks' + length +'" name= "txtRemarks" value=""/></td>' +
                    '<td style="display:none;"><input type="hidden" id="txtBalance_Stock' + length + '" name= "txtBalance_Stock" readonly value="' + parseFloat(parsed_Date[i].Balance_Stock).toFixed(2) + '"/></td>' +
                    '<td style="display:none;"><input type="hidden" id="txtRate' + length +'" name= "txtRate" value="' + parseFloat(parsed_Date[i].Rate).toFixed(2) + '"/></td>' +
                    '<td style="display:none;"><input type="hidden" id="Store_Issue_Detail_Id' + length +'" name= "Store_Issue_Detail_Id" value="' + parsed_Date[i].Store_Issue_Detail_Id + '"/></td>' +
                        '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                        '</tr>';
                    $('#tblGINItems tbody').append(rows);
                }

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
        debugger;
        function CalculateBlance(anchor) {
            debugger;
            var row = $(anchor).parents('tr')[0];
            var Return_Qty = $($(row).find('input[name=Return_Qty]')).val();
            var Issue_Qty = $($(row).find('input[name=Issue_Qty]')).val();
            var Balance_Stock = $($(row).find('input[name=txtBalance_Stock]')).val();
      

            var Balance = parseInt(Issue_Qty) - (parseInt(Return_Qty))  ;
            $($(row).find('input[name=Balance_Stock]')).val(Balance);
           
        }
        function SaveRecord() {
            debugger;
            var checkstock = false;
            var btnSave = $('#btnSave').val();
            var table = $('#tblGINItems');
            var department_id = $('#ddlDepartment').val();
            var inventory_id = $('#ddlInventoryOrg').val();
            var GIN = $('#ddlGIN').val();
            var Store_Return_No = $('#txtStoreReturnNo').val();
            var StoreReturn_id = '0';
            var SR_ID = '<%= Request.QueryString["SR_ID"]%>';
            if (SR_ID != "") {
                StoreReturn_id = SR_ID;
            }
            else {
                StoreReturn_id = '0';
            }
            var Item_list = [];
            table.find('tr:gt(0)').each(function (key, value) {
                debugger;
                var StoreStock = $(value).find('td input[name=SaveTimeStock]').val();
                var item_Id = $(value).find('td input[name=item_Id]').val();
                var Store_Issue_Detail_Id = $(value).find('td input[name=Store_Issue_Detail_Id]').val();
                var txtDepartment = $(value).find('td input[name=txtDepartment]').val();
                var IssueQty = $(value).find('td input[name=Issue_Qty]').val();
                var Return_Qty = $(value).find('td input[name=Return_Qty]').val();
                var BatchNum = $(value).find('td input[name=BatchNum]').val();
                var txtRate = $(value).find('td input[name=txtRate]').val();
                var txtSaveTimeStock = $(value).find('td input[name=txtSaveTimeStock]').val();
                var balance_Qty = $(value).find('td input[name=Balance_Stock]').val();
                var total_amount = txtRate * Return_Qty

                if (( parseFloat(balance_Qty) < 0 )) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Return Qty Must Be Equal Or Less Than Issue Stock',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    checkstock = true;
                    return false;
                }

                if ((parseFloat(Return_Qty) <= 0)) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Return Qty Must Be Greate Than Zero Stock',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    checkstock = true;
                    return false;
                }
            Item_list.push({
                'item_Id': item_Id, 'Store_Issue_Detail_Id': Store_Issue_Detail_Id, 'txtDepartment': txtDepartment, 'Return_Qty': Return_Qty, 'IssueQty': IssueQty, 'Remarks': $(value).find('input[name=txtRemarks]').val(), 'BatchNum': BatchNum, 'txtRate': txtRate, 'total_amount': total_amount, 'balance_Qty': balance_Qty
});
            });
            if (checkstock == true) {
                return false;
            }

            var AllItemDetail = { 'StoreReturn_id': StoreReturn_id, 'Store_Return_No': Store_Return_No, 'GIN': GIN, 'department_id': department_id, 'inventory_id': inventory_id, 'ItemList': Item_list };
            PageMethods.Save(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
               // sendFile(res);
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully.',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                $('#btnSave').val("Update");
                window.location = "GoodsRerturnNote.aspx?SR_ID=" + res;
                $('#btnSave').val("Update");
            });
        }
        function PrintVoucher() {
            var id = '<% =Request.QueryString["SI_ID"] %>';
            var locationInfo = window.location;


                    var user_name = '<% =AppConfig.Company_Name %>';
                    if (user_name == 'As-Siraat Serving Humanity') {
                        reportPath = '../../ReportViewer.aspx';
                    } else {
                        reportPath = 'ReportViewer.aspx'; // same folder
                    }

                    var url = '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
                    if (!locationInfo.origin.includes('localhost')) {
                        var urlInfo = window.location.href.split('/');
                        var ip = urlInfo[2];
                        var foldername = urlInfo[3];
                        url = 'http://' + ip + '/' + foldername + '/' + reportPath + '?ReportName=Voucher&ReportTitle=GRN Voucher&TransID=' + id + '&TransType=GRN';
                    }
                    window.open(url, '_blank');
                }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <form id="item">
        <div class="row">
            <input type="hidden" id="hdiemID" />
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label class="">Store Return no</label>
                <input type="text" readonly="readonly" id="txtStoreReturnNo" class="form-control" name="txtStoreReturnNo" value="New" />
            </div>
                        <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Status</label>
                <input type="text" id="txtStatus" class="form-control" name="txtStatus" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label class="">Department</label>
                <select id="ddlDepartment" class="form-control">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label class="">Warehouse</label>
                <select id="ddlInventoryOrg"  class="form-control">
                </select>
            </div>
        
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>GIN#</label>
                <select id="ddlGIN"  class="form-select"></select>
            </div>
            <div class="col-lg-1 col-md-2 col-sm-6">
                <input type="button" value="Add" id="btnAdd" class="btn btn-primry" style="margin-top: 20px;" />
            </div>

            </div>

    </form>
    <div class="row" style="margin-top:10px !important;">
                    <table class="table table-hover table-striped table-bordered" id="tblGINItems">
                        <thead>
                            <tr>
                                <th>GIN No </th>
                                <th style="display:none;">Item ID</th>
                                <th>GIN App Date</th>
                                <th>Department</th>
                                <th>ItemCode</th>
                                <th>Item Description</th>
                                <th>UOM</th>
                                <th>Batch#</th>
                                <th>Store Stock</th>
                                <th>Issue Qty</th>
                                <th>Return Qty</th>
                                <th>Blnc Qty</th>
                                <th>Remarks</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
    </div>

        <div class="row">
         <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-primry" id="btnSave" value="Save" onclick="SaveRecord()" />
            &nbsp;
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" name="" value="Print" class="btn btn-primry" onclick="btn_Print()" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn-gray" value="List" onclick="window.location = 'GoodsRerturnNoteView.aspx'" />
            &nbsp;
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-yellow" value="New" onclick="window.location = 'GoodsRerturnNote.aspx'" />
            &nbsp;
        </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
    <input type="button" class="btn btn-primry" value="Voucher" id="btnVoucher" onclick="PrintVoucher()" />
</div>
        <div class="col-lg-2 col-md-4 col-sm-6" id="btnUnApproveToBeHidden">
            <input type="button" style="display: none" class="btn btn-primry" value="UnApprove" id="btnUnApprove" onclick="UnApprove()" />
            &nbsp;
        </div>
        
            </div>
        </div>
    </div>
</asp:Content>
