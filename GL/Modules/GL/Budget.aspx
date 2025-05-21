<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Budget.aspx.cs" Inherits="PMS.Budget" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">

        .card {
            border: 1px solid #C4C4C4;
            background-color: #f9f9f9;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            height: 210px !important;
            width: 100%;
            overflow: hidden;
            margin-top: 24px;
        }

        .card-body p {
            margin-bottom: 10px;
            font-size: 14px;
        }

        #token-input-txtAccountName {
    box-shadow: 2px -3px 5px rgba(0, 0, 0, 0.2) !important;
}


    </style>

    <script type="text/javascript">
        $(function () {
            $("#tabs").tabs();
        });

        var serialnum = '';
        $(document).ready(function () {
            debugger
            $('#txt_debitamount').on('focus', function () {
                debugger
                $('#txt_creditamount').prop('readonly', true).val('');
                $(this).prop('readonly', false);
            });

            $('#txt_creditamount').on('focus', function () {
                debugger
                $('#txt_debitamount').prop('readonly', true).val('');
                $(this).prop('readonly', false);
            });

            $('#txt_debitamount').on('input', function () {
                debugger
                $('#txt_creditamount').prop('readonly', true).val('');
            });

            $('#txt_creditamount').on('input', function () {
                debugger
                $('#txt_debitamount').prop('readonly', true).val('');
            });


            $("#btnsave").click(function () {
                SaveAllRecord();
            });
            $('#ddlcostcenter').select2();
            $('#ddldepartment').select2();
            $('#ctl00_lblMessage').hide();
            FillCostCenter();
            FillDepartment();
        <% if (Request.QueryString["VID"] != null)
        { %>
            var VID = '<%= Request.QueryString["VID"]%>'
            LoadVoucherHeader(VID);
     <% } %>
            var VIDN = '<%= Request.QueryString["VID"]%>'
            if (VIDN == '') {
                $('#btnunapprove').hide();
            }
            var voucher_type = 'BJV';
            $('#txt_vcher_type').val(voucher_type);
            var date = '<%= DateTime.Now%>';
            $("#txt_date").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_date").val(date);
            debugger;
            var accountid = 0;
            loadtokenInputsByAccount_ID();
        });
        function FillCostCenter() {
            debugger;
            var optionInv = '';
            optionInv = '<option value="0">Please Select</option>';
            PageMethods.fillcostcenterss(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optionInv += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlcostcenter').html(optionInv);
            });
        }
        function FillDepartment() {
            debugger;
            var optiondep = '';
            optiondep = '<option value="0">Please Select</option>';
            PageMethods.filldepartments(function (Tests) {
                debugger
                $.each(JSON.parse(Tests), function (key, value) {
                    debugger;
                    optiondep += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddldepartment').html(optiondep);
            });
        }
        function submitText(row) {
            debugger;
            var current_narration = $(row).closest('tr').find('td input[name=txtnarration]').val();
            $("#bodyModal").html(current_narration);
        }
        function LoadVoucherHeader(VID) {
            debugger
            PageMethods.LoadVoucherMaster(VID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var txtdate = new Date(parseInt(data.Budget_Date.substr(6)));
                txtdate = moment(txtdate).format('L');
                $('#txt_vcher_type').val(data.Budget_Type);
                $('#txt_date').val(txtdate);
                $('#txt_descrip_master').val(data.Remarks);
                $('#txt_debit').val(data.Total_Debit);
                $('#txt_credit').val(data.Total_Credit);
                $('#voucher_no').val(data.Budget_No);
                $('#txtstatus').val(data.Budget_Status);
                if (data.Budget_Status == 'Approved') {
                    $('#btnunapprove').show();
                    $('#btnsave').attr("disabled", 'disabled');
                    $('#btnsave').hide();
                }
                else {
                    $('#btnunapprove').hide();
                }
                LoadVoucherDetail(VID)
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function LoadVoucherDetail(VID) {
            debugger
            PageMethods.LoadVoucherChild(VID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tbldescription tbody tr').length)));
                rowIndex = rowIndex + 1;
                selectedOptions = data;
                $.each(data, function (key, value) {
                    var debside = value.DR;
                    if (debside == null) {
                        debside = '';
                    }
                    var credside = value.CR;
                    if (credside == null) {
                        credside = '';
                    }
                    var costcentername = value.CostCenterName;
                    if (costcentername == null) {
                        costcentername = '';
                    }
                    var departmentname = value.DepartmentName;
                    if (departmentname == null) {
                        departmentname = '';
                    }
                    var narration = value.Narration;
                    if (narration == null) {
                        narration = '';
                    }
                    var CostCenter = value.Cost_Center;
                    if (CostCenter == null) {
                        CostCenter = 0;
                    }

                    var departmentId = value.DepartmentId;
                    if (departmentId == null) {
                        departmentId = 0;
                    }
                    debugger;
                    rows += '<tr>' +
                        '<td>' + rowIndex + '</td>' +
                        '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="rowid' + rowIndex + '" name="rowid" value="' + rowIndex + '" /></td>' +
                        '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtaccountcodeee' + rowIndex + '" name="txtaccountcodeee" value="' + value.AccountCode + '" /></td>' +
                        '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtaccountcode' + rowIndex + '" name="txtaccountcode" value="' + value.Account_ID + '" /></td>' +
                        '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtaccountname' + rowIndex + '" name="txtaccountname" value="' + value.AccountCode + ' - ' + value.AccountName + '" /></td>' +
                        '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddlcostcentername' + rowIndex + '" name="ddlcostcentername" value="' + costcentername + '" /></td>' +
                        '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddlcostcenterid' + rowIndex + '" name="ddlcostcenterid" value="' + CostCenter + '" /></td>' +

                        '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddldepartmentname' + rowIndex + '" name="ddldepartmentname" value="' + departmentname + '" /></td>' +
                        '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddldepartmentid' + rowIndex + '" name="ddldepartmentid" value="' + departmentId + '" /></td>' +

                        '<td data-toggle="modal" data-target="#exampleModalLong" value="Show" onClick="submitText(this)"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtnarration' + rowIndex + '" name="txtnarration" value="' + narration + '" /></td>' +
                        '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txt_debitamount' + rowIndex + '" name="txt_debitamount" value="' + debside + '" /></td>' +
                        '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txt_creditamount' + rowIndex + '" name="txt_creditamount" value="' + credside + '" /></td>' +
                        '<td><a onclick="editchildrow(this)" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;   cursor:pointer!important;">Edit</a><a onclick="Delete(this)" style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;cursor:pointer!important;">Delete</a></td>'
                    '</tr>'
                    rowIndex++;
                });
                $("#tbldescriptionbody").append(rows);
                calculatedifference();
                $('#btnsave').val('Update');
                debugger;
                var data = $('#tbldescriptionbody');
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function redirecttonew() {
            window.location.href = "BudgetView.aspx";
        }
        function redirecttonew2() {
            window.location.href = "Budget.aspx";
        }
        function loadtokenInputsByAccount_ID() {
            debugger;
            var tokendata;
            try {
                $("#txtAccountName").tokenInput("../json.aspx",
                    {
                        tokenLimit: 1,
                        onAdd: function (item) {
                            try {
                                debugger;
                                var account_id = item.id;
                                var account_name = item.name;
                                $("#hdfAccount_Code").val(account_id);
                                $("#txtAccountName").val(account_name);
                            } catch (exp) {
                                alert(exp.message);
                            }
                        },
                    });
            } catch (e) {
                alert(e.message);
            }
        }
        function httpGet(theUrl) {
            var xmlHttp = null;
            xmlHttp = new XMLHttpRequest();
            xmlHttp.open("GET", theUrl, false);
            xmlHttp.send(null);
            return xmlHttp.responseText;
        }
        function append() {
            debugger;
            var rows = '';
            var txtaccountscode = $('#hdfAccount_Code').val();
            var txtaccountsname = $('#txtAccountName').val();
            var ddlcostcentername = $('#ddlcostcenter :selected').text();
            var ddlcostcenterid = $('#ddlcostcenter :selected').val();
            if (ddlcostcentername == "Please Select") ddlcostcentername = '';

            var ddldepartmentname = $('#ddldepartment :selected').text();
            var ddldepartmentid = $('#ddldepartment :selected').val();
            if (ddldepartmentname == "Please Select") ddldepartmentname = '';

            debugger;
            var txtnarration = $('#txtnarration').val();
            var getype = 'BJV'
            var debitamount = $('#txt_debitamount').val();
            var creditamount = $('#txt_creditamount').val();
            if (txtaccountsname == "") {
                alert('Please Select Account');
                return false;
            }
            if (debitamount != "" && creditamount != "") {
                alert('Enter Only Debit Or Credit Amount in Single Entry');
                return false;
            }
            if (debitamount == "" && creditamount == "") {
                alert('Please Enter Debit Or Credit Amount');
                return false;
            }
            $('#txtAccountName').tokenInput('clear');
            $('#txtnarration').val('');
            $('#txt_debitamount').val('');
            $('#txt_creditamount').val('');
            var rowlength = tbldescriptionbody.rows.length;
            rowlength = rowlength + 1;
            rows = '<tr>' +
                '<td>' + rowlength + '</td>' +
                '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="rowid' + rowlength + '" name="rowid" value="' + rowlength + '" /></td>' +
                '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtaccountcode' + rowlength + '" name="txtaccountcode" value="' + txtaccountscode + '" /></td>' +
                '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtaccountname' + rowlength + '" name="txtaccountname" value="' + txtaccountsname + '" /></td>' +
                '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddlcostcentername' + rowlength + '" name="ddlcostcentername" value="' + ddlcostcentername + '" /></td>' +
                '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddlcostcenterid' + rowlength + '" name="ddlcostcenterid" value="' + ddlcostcenterid + '" /></td>' +

                '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddldepartmentname' + rowlength + '" name="ddldepartmentname" value="' + ddldepartmentname + '" /></td>' +
                '<td style="display:none!important;"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="ddldepartmentid' + rowlength + '" name="ddldepartmentid" value="' + ddldepartmentid + '" /></td>' +

                '<td data-toggle="modal" data-target="#exampleModalLong" value="Show" onClick="submitText(this)"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtnarration' + rowlength + '" name="txtnarration" value="' + txtnarration + '" />   </td>' +
                '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txt_debitamount' + rowlength + '" name="txt_debitamount" value="' + debitamount + '" /></td>' +
                '<td><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txt_creditamount' + rowlength + '" name="txt_creditamount" value="' + creditamount + '" /></td>' +
                '<td><a onclick="editchildrow(this)" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;   cursor:pointer!important;">Edit</a><a onclick="Delete(this)" style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;   cursor:pointer!important;">Delete</a></td>'
            '</tr>'
            debugger;
            if (serialnum > 0) {
                debugger;
                $('#txtaccountcode' + serialnum + '').val(txtaccountscode);
                $('#txtaccountname' + serialnum + '').val(txtaccountsname);
                $('#ddlcostcentername' + serialnum + '').val(ddlcostcentername);
                $('#ddlcostcenterid' + serialnum + '').val(ddlcostcenterid);
                $('#ddldepartmentname' + serialnum + '').val(ddldepartmentname);
                $('#ddldepartmentid' + serialnum + '').val(ddldepartmentid);
                $('#txtnarration' + serialnum + '').val(txtnarration);
                $('#txt_debitamount' + serialnum + '').val(debitamount);
                $('#txt_creditamount' + serialnum + '').val(creditamount);
                serialnum = '';
            }
            else {
                $("#tbldescriptionbody").append(rows);
            }
            var data = $('#tbldescriptionbody');
            var rowlength = tbldescriptionbody.rows.length;

            calculatedifference();
            rowlength++;
        }
        function Delete(row) {
            debugger;
            $(row).closest('tr').remove();
            calculatedifference();
        }
        function calculatedifference() {
            debugger;
            var debitside = 0;
            var creditside = 0;
            var balance = 0;
            var totaldebit = 0;
            var totalcredit = 0;
            $.each($('#tbldescription tbody tr'), function (key, value) {
                debugger;
                debitside = $($(value).find('td input[name=txt_debitamount]')[0]).val();
                creditside = $($(value).find('td input[name=txt_creditamount]')[0]).val();
                if (debitside == "") {
                    debitside = 0;
                }
                if (creditside == "") {
                    creditside = 0;
                }
                totaldebit += parseFloat(debitside);
                totalcredit += parseFloat(creditside);
                balance = parseFloat(totaldebit) - parseFloat(totalcredit);
            });
            $('#txt_debit').val(parseFloat(totaldebit));
            $('#txt_credit').val(parseFloat(totalcredit));
            $('#txt_diff').val(parseFloat(balance));
        }
        function SaveAllRecord() {
            debugger
            elementIsClicked = true;
            debugger;
            var status;
            var btnSave = $('#btnsave').val();
            var type = $('#txt_vcher_type').val();
            var budgetno = $('#voucher_no').val();
            var status = $('#txtstatus').val();
            if (status == 'Cancalled') {
                debugger;
                status = 'Created'
            }
            if (status == '') {
                debugger;
                status = 'Created'
            }
            var txtdate = $('#txt_date').val();
            var descriptionmaster = $('#txt_descrip_master').val();
            var totaldebit = $('#txt_debit').val();
            var totalcredit = $('#txt_credit').val();
            var difference = $('#txt_diff').val();
            if (difference > 0 || difference < 0) {
                alert('Difference Should Be Zero');
                return false;
            }
            var editmode_budgetID = '<% =Request.QueryString["VID"] %>';
            var table = $('#tbldescriptionbody');
            var Item_list = [];
            debugger;
            table.find('tr').each(function (key, value) {
                debugger;
                Item_list.push({
                    'accountcode': $(value).find('td input[name=txtaccountcode]').val(),
                    'txtdebamount': $(value).find('td input[name=txt_debitamount]').val(),
                    'txtcredamount': $(value).find('td input[name=txt_creditamount]').val(),
                    'ddlcostcentername': $(value).find('td input[name=ddlcostcentername]').val(),
                    'ddlcostcenterid': $(value).find('td input[name=ddlcostcenterid]').val(),
                    'ddldepartmentname': $(value).find('td input[name=ddldepartmentname]').val(),
                    'ddldepartmentid': $(value).find('td input[name=ddldepartmentid]').val(),
                    'txtnarration': $(value).find('td input[name=txtnarration]').val(),
                    'txtaccountname': $(value).find('td input[name=txtaccountname]').val(),
                });
            });
            debugger;
            var AllItemDetail = { 'Item_list': Item_list, 'editmode_budgetID': editmode_budgetID, 'budgetno': budgetno, 'type': type, 'txtdate': txtdate, 'descriptionmaster': descriptionmaster, 'totaldebit': totaldebit, 'totalcredit': totalcredit, 'status': status };
            PageMethods.Savealldata(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
                if (res == "Period closed for this month. You cannot add or edit Voucher.") {
                    alert('Period closed for this month. You cannot add or edit Voucher.');
                    return false;
                }
                alert('Data Save Successfully');
                var getype = 'BJV';
                window.location.href = "Budget.aspx?VoucherType=" + getype + "&VID=" + res;
            });
        }

        function UnApprove() {
            elementIsClicked = true;
            debugger;
            var VID = '<% =Request.QueryString["VID"] %>';
            PageMethods.UnApproveVoucher(VID, function (Tests) {
                debugger
                alert('UnApproved Done Successfully');
                location.reload();
            });
        }
        function loadtokenInputsForPRNo(elementId, data) {
            if (elementId == "#txtAccountName") {
                $(elementId).tokenInput("json.aspx",
                    {
                        prePopulate: data,
                        tokenLimit: 1,
                    });
            }
        }
        function editchildrow(anchorTag) {
            debugger
            var values = [];
            var one = '';
            var two = '';
            debugger;
            var table = $('#tbldescriptionbody');
            var row = $(anchorTag).parents('tr')[0];
            serialnum = $($(row).find('td')[0]).text();
            var accountname = $($(row).find('td')[2]).text();
            var accountcodename = $($(row).find('td input[name="txtaccountname"]')).val();
            var accountid = $($(row).find('td input[name="txtaccountcode"]')).val();
            var accnCode = $($(row).find('td input[name="txtaccountcodeee"]')).val();
            var accComplete = accountcodename;
            values = accountcodename.split('-');
            one = values[0];
            two = values[1];
            var costcenterid = $($(row).find('td input[name="ddlcostcenterid"]')).val();
            var costcentername = $($(row).find('td input[name="ddlcostcentername"]')).val();
            var departmentid = $($(row).find('td input[name="ddldepartmentid"]')).val();
            var departmentname = $($(row).find('td input[name="ddldepartmentname"]')).val();
            var txtnarration = $($(row).find('td input[name="txtnarration"]')).val();
            var debtitvalue = $($(row).find('td input[name="txt_debitamount"]')).val();
            var creditvalue = $($(row).find('td input[name="txt_creditamount"]')).val();
            debugger
            $('#txtAccountName').tokenInput('clear');
            $('#txtAccountName').tokenInput("add", { id: accountid, name: accComplete });
            $('#ddlcostcenter').val(costcenterid).trigger('change');
            $('#ddldepartment').val(departmentid).trigger('change');
            $('#txtnarration').val(txtnarration);
            $('#txt_debitamount').val(debtitvalue);
            $('#txt_creditamount').val(creditvalue);
            calculatedifference();
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div>
        <div class="row" >
            <div class="col-lg-6">
                <div class="row">
                    <div class="col-lg-4">
                        <div class="form-group">
                            <label >Type</label>
                            <input class="form-control" value="BCR" type="text" id="txt_vcher_type" readonly="readonly" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="form-group">
                            <label>No</label>
                            <input class="form-control" type="text" value="New" id="voucher_no" readonly="readonly" />
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="form-group">
                            <label>Status</label>
                            <input class="form-control" type="text" id="txtstatus" readonly="readonly" />
                        </div>
                    </div>
                </div>
                <div class="row">
                    <div class="col-lg-4">
                        <div class="form-group">
                            <label>Date</label>
                            <input class="form-control" type="text" id="txt_date" />
                        </div>
                    </div>
                    <div class="col-lg-8">
                        <div class="form-group">
                            <label>Description</label>
                            <textarea class="form-control" id="txt_descrip_master" rows="1" cols="20"></textarea>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3">
                <div class="card">
                    <div style="border-bottom-style: double;" class="card-header">
                        <h4>Currency Exchange</h4>
                    </div>
                    <div class="card-body">
                        <div class="col-lg-6 md-6 sm-6">
                            <div class="form-group">
                                <label>Currency</label>
                                <select class="form-control" id="ddl_currency">
                                    <option>PKR</option>
                                    <option>USD</option>
                                    <option>AUD</option>
                                </select>
                            </div>
                        </div>
                        <div class="col-lg-6 md-6 sm-6">
                            <div class="form-group">
                                <label>Exchange Rate</label>
                                <input class="form-control" type="text" id="txt_exg_rate" value="1.00" readonly="readonly" />
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-lg-3 ">
                <div class="card">
                    <div style="border-bottom-style: double;" class="card-header">
                        <h4>Voucher Summary</h4>
                    </div>
                    <div class="card-body">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Debit</label>
                                    <input class="form-control" type="text" id="txt_debit" readonly="readonly" />
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Credit</label>
                                    <input class="form-control" type="text" id="txt_credit" readonly="readonly" />
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label>Diff</label>
                                    <input class="form-control" type="text" id="txt_diff" readonly="readonly" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="table-container">
            <table class="table table-bordered" id="tbldescription">
                <thead>
                    <tr>
                        <th id="seq" style="width: 5%;">Seq</th>
                        <th id="th_acc" style="width: 20%;">Account No.</th>
                        <th style="width: 10%;">Cost Center</th>
                        <th style="width: 10%;">Department</th>
                        <th id="th-nar" style="width: 30%;">Naration</th>
                        <th id="deb" style="width: 10%;">Debit</th>
                        <th id="cre" style="width: 10%;">Credit</th>
                        <th id="plus" style="width: 5%;"></th>
                    </tr>
                    <tr>
                        <td style="width: 5%;">
                            <div >
                            </div>
                        </td>
                        <td style="width: 15%;">
                            <div >
                                <input class="form-control" type="text" id="txtAccountName" name="txtAccountName" placeholder="Search for a GL Accounts" />
                                <input type="hidden" id="hdfAccount_Code" name="hdfAccount_Code" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div >
                                <select class="form-control" id="ddlcostcenter" name="ddlcostcenter">
                                    <option></option>
                                </select>
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div >
                                <select class="form-control" id="ddldepartment" name="ddldepartment">
                                    <option></option>
                                </select>
                            </div>
                        </td>
                        <td style="width: 20%;">
                            <div >
                                <input class="form-control" type="text" id="txtnarration" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div >
                                <input class="form-control" type="text" id="txt_debitamount" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div >
                                <input class="form-control" type="text" id="txt_creditamount" />
                            </div>
                        </td>
                        <td style="width: 5%;">
                            <i class="fa fa-plus fa-1x text-light" aria-hidden="true" id="addbtn" onclick="append()"></i>
                        </td>
                    </tr>
                </thead>
                <tbody id="tbldescriptionbody">
                </tbody>
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-12">
        <input type="button" class="btn btn-gray" id="btnList" value="List" onclick="redirecttonew()" />
            </div>
        <div class="col-lg-1 col-md-4 col-sm-12">
        <input type="button" class="btn btn-primry" id="btnsave" value="Save" onclick="this.disabled = true;" />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12">
        <input type="button" class="btn btn-yellow" id="btnnew" value="New" onclick="redirecttonew2()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-12">
        <input type="button" class="btn btn-success" id="btnunapprove" value="UnApprove" onclick="UnApprove()" />
                    </div>
    </div>
    <div class="modal fade" id="exampleModalLong" tabindex="-1" role="dialog" aria-labelledby="exampleModalLongTitle" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="exampleModalLongTitle">Narration</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                    </button>
                </div>
                <div class="modal-body" id="bodyModal">
                </div>
                <div class="modal-footer">
                </div>
            </div>
        </div>
    </div>
</asp:Content>
