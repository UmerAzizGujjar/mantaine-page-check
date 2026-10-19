<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetSubsequentExpense.aspx.cs" Inherits="PMS.Modules.Administrator.AssetSubsequentExpense" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            var date = '<%= DateTime.Now%>';
            date = moment(date).format('LL');
            $("#txtDate").val(date);
            $("#ddl_year").hide();
            $("#ddl_month").hide();


            LoadAsset();
            LoadDebit();
            LoadCredit();
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $("#btnSave").val('Update');
                $('#ddl_Company').attr('disabled', true);
                //$('#ddlMonth').attr('disabled', true);
                //$('#txtReg_no').attr('disabled', true);
                //$('#txtRemarks').attr('disabled', true);
                //$('#btn_save').attr('disabled', true);


                getRecords(id);
            }
            else {

                $('#ddl_CrAccount').select2();
                $('#ddl_DrAccount').select2();
                $('#ddl_Asset').select2();
            }
        });
        function SaveRecord_Expense() {
            var btnSave = $("#btn_save").val();
            var Trans = $("#txttransaction").val();
            if (Trans == 0 || Trans == "0" || Trans == '0' || Trans == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Fill mandatory fields',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                 console.error("Error: Trans_No is required.");
                return;
            }

            var Asset_id = $("#ddl_Asset").val();

            var Date = $("#txtDate").val();
            var Asset_val = $("#txtassetValue").val();
            var Cr_Account = $("#ddl_CrAccount").val();
            var Dr_Account = $("#ddl_DrAccount").val();
            var Remarks = $("#txtremarks").val();
            var TotalExpense = $("#txtTotalExpenseAmount").val();
            var asset_name = $("#ddl_Asset").find('option:selected').text();
            var id = '<%=Request.QueryString["ID"]%>';
            console.log(id);

            var table = $('#tblexpense');
            var list = [];

            table.find('tr:gt(0)').each(function (key, value) {
                var ExpenseDate = $(value).find('input[name="ExpenseDate"]').val();
                var ExpenseRefrence = $(value).find('input[name="ExpenseReference"]').val();
                var ExpenseDetail = $(value).find('input[name="ExpenseDetails"]').val();
                var ExpenseAmount = $(value).find('input[name="ExpenseAmount"]').val();
                var IncreaseinLife = $(value).find('input[name="IncreaseInLife"]').val();
                var Asset_id = $(value).find('input[name="AssetId"]').val();


                var array = {
                    ExpenseDate: ExpenseDate,
                    ExpenseRefrence: ExpenseRefrence,
                    ExpenseDetail: ExpenseDetail,
                    ExpenseAmount: ExpenseAmount,
                    IncreaseinLife: IncreaseinLife,
                    Asset_id: Asset_id

                };

                list.push(array);
            });

            try {
                PageMethods.SaveRecord(
                    Trans,
                    Asset_id,
                    Date,
                    Asset_val,
                    Cr_Account,
                    Dr_Account,
                    btnSave,
                    Remarks,
                    TotalExpense,
                    asset_name,
                    id,
                    list,
                    function (response) {
                        var master_id = response;
                        if (master_id != '-1') {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Data has been saved successfully.',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                             window.location.href = "AssetSubsequentExpense.aspx";
                        }
                    }
                );
            } catch (error) {
                console.error("Error while saving record:", error);
            }


        }

        function getRecords(id) {
            $.ajax({
                type: "POST",
                url: "AssetSubsequentExpense.aspx/getRecords",
                data: JSON.stringify({ "id": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    var master = data.Master;
                    var detail = data.Detail;

                    console.log(response);

                    $("#hdnIsApproved").val(master.is_approved);


                    if (master.is_approved == 1) {
                     $("#approve-div").hide();
                     $("#unapprove-div").show();
                    } else {
                     $("#unapprove-div").hide();
                     $("#approve-div").show();
                    }

                    $("#txttransaction").val(master.Trans_no);
                    $("#ddl_Asset").val(master.Asset_ID).trigger('change');
                    $("#txtassetValue").val(master.Asset_Value);
                    $("#txtremarks").val(master.Remarks);
                    $("#txtTotalExpenseAmount").val(master.TotalExpenseAmount);

                    setTimeout(function () {
                        $("#ddl_CrAccount").val(master.Cr_Account).trigger('change');
                        $("#ddl_DrAccount").val(master.Dr_Account).trigger('change');
                    }, 4000);


                    var formattedDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(master.Date.substring(6, 19))));
                    $("#txtDate").val(formattedDate);


                    $("#btn_save").val('Update');
                    $('#ddl_Company').attr('disabled', true);


                    $('#tblexpense tbody').empty();
                    $.each(detail, function (index, item) {
                        var expenseDate = $.datepicker.formatDate('dd M yy', new Date(parseInt(item.Expense_Date.substring(6, 19))));

                        var row = '<tr>' +
                            '<td><input type="text" name="ExpenseDate" value="' + expenseDate + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" name="ExpenseReference" value="' + item.Expense_Reference + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" name="ExpenseDetails" value="' + item.Expense_Details + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" name="ExpenseAmount" value="' + item.Expense_Amount + '" style="width:122px!important;" /></td>' +
                            '<td><input type="text" name="IncreaseInLife" value="' + item.IncreaseInLife + '" style="width:122px!important;" /></td>' +
                            '<td style="display:none;"><input type="hidden" name="AssetId" value="' + item.Asset_ID + '" /></td>' +
                            '</tr>';

                        $('#tblexpense tbody').append(row);
                        $('#tblexpense tbody tr:last input[name="ExpenseDate"]').datepicker({ dateFormat: 'dd M yy' });
                    });
                },
                error: function (xhr, status, error) {
                    console.error("Error loading record:", error);
                }
            });
        }


        function LoadDebit() {
            $.ajax({
                type: "POST",
                url: "AssetSubsequentExpense.aspx/Load_Debit",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Account_ID + '" >' + value.Account_Name + '</option>';
                    });
                    $('#ddl_DrAccount').html(options);

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function LoadCredit() {
            $.ajax({
                type: "POST",
                url: "AssetSubsequentExpense.aspx/Load_Credit",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Account_ID + '" >' + value.Account_Name + '</option>';
                    });
                    $('#ddl_CrAccount').html(options);

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }

        function LoadAsset() {
            $.ajax({
                type: "POST",
                url: "AssetSubsequentExpense.aspx/Load_Asset",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var options = '<option value="0" >Please Select</option>';
                    var values = JSON.parse(data.d);
                    $.each(values, function (key, value) {
                        options += '<option value="' + value.Asset_Definition_Id + '" >' + value.Item_Description + '</option>';
                    });
                    $('#ddl_Asset').html(options);

                },
                failure: function (response) {
                    alert(response.d);
                }
            });

        }
        function getAssetValue() {
            var AssetId = $("#ddl_Asset").val();
            $.ajax({
                type: "POST",
                url: "AssetSubsequentExpense.aspx/GetAssetValues",
                data: JSON.stringify({ AssetId: AssetId }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var assetData = JSON.parse(data.d);

                    $('#txtassetValue').val(assetData.Capitilization_Cost);

                },
                failure: function (response) {
                    alert("Error: " + response.d);
                }
            });
        }
        var rowlength = '';
        function Addrow() {
            var Asset_id = $("#ddl_Asset").val();
            if (Asset_id == 0 || Asset_id == "0" || Asset_id == '0' || Asset_id == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Asset is a mandatory field',
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

            var rows = '';
            var rowIndex = parseInt($('#tblexpense tbody tr').length);

            rows += '<tr>' +
                '<td><input type="text" id="ExpenseDate' + (rowIndex + 1) + '" name="ExpenseDate" value="" style="width:122px!important;" /></td>' +
                '<td><input type="text" id="ExpenseRefrence' + (rowIndex + 1) + '" name="ExpenseReference" style="width:122px!important;" /></td>' +
                '<td><input type="text" id="ExpenseDetail' + (rowIndex + 1) + '" name="ExpenseDetails" style="text-align: right;width:122px!important;" /></td>' +
                '<td><input type="text" id="ExpenseAmount' + (rowIndex + 1) + '" name="ExpenseAmount" style="width:122px!important;" class="expense-amount" /></td>' +
                '<td><input type="text" id="IncreaseinLife' + (rowIndex + 1) + '" name="IncreaseInLife" style="width:122px!important;" /></td>' +
                '<td style="display:none;"><input type="hidden" name="AssetId" value="' + Asset_id + '" /></td>' +
                '</tr>';

            $('#tblexpense').append(rows);
            $('#ExpenseDate' + (rowIndex + 1)).datepicker({ dateFormat: 'dd M yy' });

            rowlength++;

            // Bind input event on the newly added ExpenseAmount field
            $('#ExpenseAmount' + (rowIndex + 1)).on('input', function () {
                calculateTotalExpenseAmount();
            });

            // Recalculate total when a new row is added
            calculateTotalExpenseAmount();
        }
        function calculateTotalExpenseAmount() {
            var total = 0;
            $('input[name="ExpenseAmount"]').each(function () {
                var val = parseFloat($(this).val());
                if (!isNaN(val)) {
                    total += val;
                }
            });
            $('#txtTotalExpenseAmount').val(total.toFixed(2)); // Add currency formatting if needed
        }

        function Approve_AssetExpense() {
            var expense_ID = '<% =Request.QueryString["ID"] %>';
  
            PageMethods.approveExpense(expense_ID, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {

                    alert(message[0].Message);
                    location.reload();
                }
            });
        }
        function UnApprove_AssetExpense() {
            var expense_ID = '<% =Request.QueryString["ID"] %>';
  
            PageMethods.UnapproveExpense(expense_ID, function (Tests) {
                var message = JSON.parse(Tests);
                if (message[0].Message != null || message[0].Message != "") {
                    alert(message[0].Message);
                    location.reload();
                }
            });
            window.location.href = 'AssetSubsequentExpenseView.aspx';
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="assetid" />
    <div class="row">

        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Transaction#:</label>
            <input type="text" name="Date" id="txttransaction" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Date</label>
            <input type="text" name="Date" disabled id="txtDate" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Asset:</label>
            <select id="ddl_Asset" onchange="getAssetValue()"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Asset Value:</label>
            <input type="text" name="txtassetValue" disabled id="txtassetValue" />
        </div>
    </div>
    <div class="row">
         <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Dr Account:</label>
            <select id="ddl_DrAccount"></select>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Cr Account:</label>
            <select id="ddl_CrAccount"></select>
        </div>
       
        <div class="col-lg-6 col-md-3 col-sm-4">
            <label>Remarks:</label>
            <input type="text" name="Date" id="txtremarks" />
        </div>
    </div>
    <div class="row">
        <div class="col-lg-11 col-md-3 col-sm-4">
        </div>
        <div class="col-lg-1 col-md-1 col-sm-1">
            <label></label>
            <input type="button" value="+" class="btn btn-primry" id="btnload" onclick="Addrow()" />
        </div>
    </div>


    <br />

    <table class="table" id="tblexpense">
        <thead>
            <tr>
                <th>Expense Date</th>
                <th>Expense Refference</th>
                <th>Expense Detail</th>
                <th>Expense Amount</th>
                <th>Increase In Life</th>
            </tr>
        </thead>
        <tbody>
        </tbody>
    </table>
    <div class="row">
        <div class="col-md-9 col-lg-9 col-sm-9">
        </div>
        <div class="col-lg-2 col-md-2 col-sm-2">

            <label><strong>Total Expense Amount:</strong></label>
            <input type="text" id="txtTotalExpenseAmount" readonly />
        </div>
    </div>
    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn_save" class="btn btn-yellow" value="Save" onclick="SaveRecord_Expense()" />
            </div>
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn-new" onclick="window.location = 'AssetSubsequentExpense.aspx'" class="btn btn-yellow" value="New" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" id="btn_back" class="btn btn-yellow" onclick="window.location = 'AssetSubsequentExpenseView.aspx'" value="View" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3" id="approve-div" style="display:none">
                <input type="button" id="btn_Approve" class="btn btn-yellow" onclick="Approve_AssetExpense()" value="Approve" />
            </div> 
            <div class="col-lg-2 col-md-2 col-sm-3" id="unapprove-div" style="display:none">
                <input type="button" id="btn_UnApprove" class="btn btn-yellow" onclick="UnApprove_AssetExpense()" value="UnApprove" />
            </div>
            <input type="hidden" id="hdnIsApproved" />
        </div>
    </div>
</asp:Content>
