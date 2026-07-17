<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Voucher.aspx.cs" Inherits="PMS.Voucher" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/voucher.css" rel="stylesheet" />

    <script type="text/javascript">
        $(function () {
            $("#tabs").tabs();
        });
        var _global_branch = '';
        var _global_segment = '';
        var _global_subsegment = '';
        var _global_cost_center = '';
        var _global_department = '';
        var serialnum = '';
        $(document).ready(function () {
            debugger
            $('#txt_debitamount').on('focus', function () {
                debugger
                $('#txt_creditamount').prop('readonly', true).val(0);
                $(this).prop('readonly', false);
            });

            $('#txt_creditamount').on('focus', function () {
                debugger
                $('#txt_debitamount').prop('readonly', true).val(0);
                $(this).prop('readonly', false);
            });

            $('#txt_debitamount').on('input', function () {
                debugger
                $('#txt_creditamount').prop('readonly', true).val(0);
            });

            $('#txt_creditamount').on('input', function () {
                debugger
                $('#txt_debitamount').prop('readonly', true).val(0);
            });
            $("#btnsave").click(function () {
                SaveAllRecord();
            });
            $('#ddlcostcenter').select2();
            $('#ddldepartment').select2();
            $('#ctl00_lblMessage').hide();
            $('#lblptn').hide();
            $('#lblname').hide();
            $('#lbldocno').hide();
            $('#lblreference').hide();
            FillCostCenter();
            FillDepartment();
            FillVendors();
        <% if (Request.QueryString["VID"] != null)
        { %>
            var VID = '<%= Request.QueryString["VID"]%>'
            LoadVoucherHeader(VID);
     <% } %>
            var VIDN = '<%= Request.QueryString["VID"]%>'
            if (VIDN == '') {
                $('#btnunapprove').hide();
                $('#btnprint').hide();
            }
            var Vtype = '<%= Request.QueryString["VoucherType"]%>'
            if (Vtype == 'CPV') {
                $('#lblptn').show();                
                debugger;
                $('#txtheader_cheqno').hide();
                $('#txtheader_cheqdate').hide();
                $('#td_txtcheqno').hide();
                $('#td_txtcheqdate').hide();
                $('#ctl00_lbl1').text('Cash Payment Voucher');
            }
            if (Vtype == 'DRV') {
                $('#lblptn').show();
            }
            if (Vtype == 'CRV') {
                $('#lblname').show();
                $('#txtheader_cheqno').hide();
                $('#txtheader_cheqdate').hide();
                $('#td_txtcheqno').hide();
                $('#td_txtcheqdate').hide();
                $('#ctl00_lbl1').text('Cash Receipt Voucher');
            }
            if (Vtype == 'BPV') {
                $('#lbldocno').show();
                $('#lblptn').hide();
                $('#txtheader_cheqdate').hide();
                $('#td_txtcheqdate').hide();
                $('#ctl00_lbl1').text('Bank Payment Voucher');
            }
            if (Vtype == 'BRV') {
                $('#lbldocno').show();
                $('#txtheader_cheqdate').hide();
                $('#td_txtcheqdate').hide();
                $('#ctl00_lbl1').text('Bank Receipt Voucher');

            }
            if (Vtype == 'JV') {
                $('#lblreference').show();
                $('#txtheader_cheqno').hide();
                $('#txtheader_cheqdate').hide();
                $('#td_txtcheqno').hide();
                $('#td_txtcheqdate').hide();
                $('#ctl00_lbl1').text('Journal Voucher');
            }
            $('#ddl_brnch').select2();
            var voucher_type = '<% =Request.QueryString["VoucherType"] %>';
            $('#txt_vcher_type').val(voucher_type);
            var date = '<%= DateTime.Now%>';
            $("#txt_date").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            $("#txtcheqdate").datepicker({ dateFormat: 'mm/dd/yy' }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_date").val(date);
            $("#txtcheqdate").val(date);
            debugger;
            var accountid = 0;
            loadtokenInputsByAccount_ID();
            $("input[name='rbtn']").change(function () {
                $("#txtAccountName").prev(".token-input-list").remove();
                $("#txtAccountName").show().val("");
                // Recreate it with the new AccountType
                loadtokenInputsByAccount_ID();
            });

        });
        function FillCostCenter() {
            debugger;
            var optionInv = '';
          
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
            PageMethods.LoadVoucherMaster(VID, function (resp) {
                var data = JSON.parse(resp);
                debugger;
                var txtdate = new Date(parseInt(data.Voucher_Date.substr(6)));
                txtdate = moment(txtdate).format('L');
                setTimeout(function () {
                    $('#ddl_brnch').val(data.Branch_DDL).trigger('change');
                }, 1000);
                setTimeout(function () {
                    $('#ddlVendor').val(data.Vendor_ID).trigger('change');
                }, 1000);
                $('#txt_vcher_type').val(data.Voucher_Type);
                $('#txt_date').val(txtdate);
                $('#txt_Ptn').val(data.Pay_To_Name);
                $('#txt_descrip_master').val(data.Remarks);
                $('#txt_ref_no').val(data.Ref_Num);
                $('#txt_debit').val(data.Total_Debit);
                $('#txt_credit').val(data.Total_Credit);
                $('#voucher_no').val(data.Voucher_No);
                $('#txtstatus').val(data.Voucher_Status);
                if (data.Voucher_Status == 'Approved') {
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
        function FillVendors() {
            PageMethods.getVendorDDLlist(function (Tests) {
                debugger
                optionsVen = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionsVen += '<option value="' + value.Vendor_ID + '" >' + value.Vendor_Name + '</option>';
                });
                $('#ddlVendor').html(optionsVen);
                $('#ddlVendor').select2();
            });
        }
        function LoadVoucherDetail(VID) {
            PageMethods.LoadVoucherChild(VID, function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                var rows = '';
                var rowIndex = parseInt((parseInt($('#tbldescription tbody tr').length)));
                rowIndex = rowIndex + 1;
                selectedOptions = data;
                $.each(data, function (key, value) {
                    if (data[key].Cheque_Date != null) {
                        var cheqdate = $.datepicker.formatDate('dd M yy', new Date(parseInt(data[key].Cheque_Date.substring(6, 19))));
                    }
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
                    var chequeno = value.Cheque_No;
                    if (chequeno == null) {
                        chequeno = '';
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
                        '<td id="td_child_txtcheqnoload' + rowIndex + '"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtcheqno' + rowIndex + '" name="txtcheqno" value="' + chequeno + '" /></td>' +
                        '<td id="td__child_txtcheqdateload' + rowIndex + '"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtcheqdate' + rowIndex + '" name="txtcheqdate" value="' + cheqdate + '" /></td>' +
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
                var rowlength = tbldescriptionbody.rows.length;
                for (i = 0; i <= rowlength; i++) {
                    var Vtype2 = '<%= Request.QueryString["VoucherType"]%>'
                    if (Vtype2 == 'CPV' || Vtype2 == 'CRV' || Vtype2 == 'JV') {
                        var rowlength = tbldescriptionbody.rows.length;
                        $('#td__child_txtcheqdateload' + (i + 1) + '').hide();
                        $('#td_child_txtcheqnoload' + (i + 1) + '').hide();
                    }
                }
                for (i = 0; i <= rowlength; i++) {
                    var Vtype3 = '<%= Request.QueryString["VoucherType"]%>'
                    if (Vtype3 == 'BRV' || Vtype3 == 'BPV') {
                        var rowlength = tbldescriptionbody.rows.length;
                        $('#td__child_txtcheqdateload' + (i + 1) + '').hide();
                    }
                }
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function redirecttonew() {
            var getype = '<%= Request.QueryString["VoucherType"]%>'
            window.location.href = "VoucherView.aspx?VoucherType=" + getype;
        }
        function redirecttonew2() {
            var getype = '<%= Request.QueryString["VoucherType"]%>'
            window.location.href = "Voucher.aspx?VoucherType=" + getype;
        }
        function loadtokenInputsByAccount_ID() {
            debugger;
            var accountType = $("input[name='rbtn']:checked").val();
            var tokendata;
            try {
                $("#txtAccountName").tokenInput("../../json.aspx?Table=VoucherByAccountType&AccountType=" + accountType,
                    {
                        tokenLimit: 1,
                        cacheResults: false,   // if supported
                        preventDuplicates: true,
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
            var txtchequeno = $('#txtcheqno').val();
            var txtdatechild = $('#txtcheqdate').val();
            var getype = '<%= Request.QueryString["VoucherType"]%>'
            var debitamount = $('#txt_debitamount').val();
            var creditamount = $('#txt_creditamount').val();
            if (txtaccountsname == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Account',
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
            if ((debitamount !== "" && debitamount !== "0") && (creditamount !== "" && creditamount !== "0")) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Enter Only Debit Or Credit Amount in Single Entry',
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
            if (debitamount == "" && creditamount == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Debit Or Credit Amount',
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
            $('#txtAccountName').tokenInput('clear');
            $('#txtnarration').val('');
            $('#txtcheqno').val('');
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
                '<td id="td_child_txtcheqno' + rowlength + '"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtcheqno' + rowlength + '" name="txtcheqno" value="' + txtchequeno + '" /></td>' +
                '<td id="td__child_txtcheqdate' + rowlength + '"><input style="background: #fff !important; border: 0px solid #fff !important;" type="text" readonly="readonly" id="txtcheqdate' + rowlength + '" name="txtcheqdate" value="' + txtdatechild + '" /></td>' +
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
                $('#txtcheqno' + serialnum + '').val(txtchequeno);
                $('#txtcheqdate' + serialnum + '').val(txtdatechild);
                $('#txt_debitamount' + serialnum + '').val(debitamount);
                $('#txt_creditamount' + serialnum + '').val(creditamount);
                serialnum = '';
            }
            else {
                $("#tbldescriptionbody").append(rows);
            }
            var data = $('#tbldescriptionbody');
            var rowlength = tbldescriptionbody.rows.length;
            for (i = 0; i <= rowlength; i++) {
                var Vtype2 = '<%= Request.QueryString["VoucherType"]%>'
                if (Vtype2 == 'CPV' || Vtype2 == 'CRV' || Vtype2 == 'JV') {
                    var rowlength = tbldescriptionbody.rows.length;
                    $('#td__child_txtcheqdate' + (i + 1) + '').hide();
                    $('#td_child_txtcheqno' + (i + 1) + '').hide();
                }
            }
            for (i = 0; i <= rowlength; i++) {
                var Vtype3 = '<%= Request.QueryString["VoucherType"]%>'
                if (Vtype3 == 'BPV' || Vtype3 == 'BRV') {
                    var rowlength = tbldescriptionbody.rows.length;
                    $('#td__child_txtcheqdate' + (i + 1) + '').hide();
                }
            }
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
            elementIsClicked = true;
            debugger;
            var status;
            var btnSave = $('#btnsave').val();
            var type = $('#txt_vcher_type').val();
            var voucherno = $('#voucher_no').val();
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
            var txtptn = $('#txt_Ptn').val();
            var descriptionmaster = $('#txt_descrip_master').val();
            var refnum = $('#txt_ref_no').val();
            var totaldebit = $('#txt_debit').val();
            var totalcredit = $('#txt_credit').val();
            var difference = $('#txt_diff').val();
            var vendorID = $('#ddlVendor').val();
            if (difference > 0 || difference < 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Difference Should Be Zero',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                $('#btnsave').attr('disabled', false);
                return false;
            }
            var editmode_voucherID = '<% =Request.QueryString["VID"] %>';
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
                    'txtcheqno': $(value).find('td input[name=txtcheqno]').val(),
                    'txtcheqdate': $(value).find('td input[name=txtcheqdate]').val(),
                    'txtaccountname': $(value).find('td input[name=txtaccountname]').val(),
                });
            });
            debugger;
            var AllItemDetail = { 'Item_list': Item_list, 'editmode_voucherID': editmode_voucherID, 'voucherno': voucherno, 'type': type, 'txtdate': txtdate, 'txtptn': txtptn, 'descriptionmaster': descriptionmaster, 'refnum': refnum, 'totaldebit': totaldebit, 'totalcredit': totalcredit, 'status': status, 'vendorID': vendorID };
            PageMethods.Savealldata(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
                if (res == "Period closed for this month. You cannot add or edit Voucher.") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Period closed for this month. You cannot add or edit Voucher.',
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
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Save Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                sendFile(res);
           
                var getype = '<% =Request.QueryString["VoucherType"] %>';
                window.location.href = "Voucher.aspx?VoucherType=" + getype + "&VID=" + res;
            });
        }
        function PrintReport() {
            var id = '<% =Request.QueryString["VID"] %>';
            var locationInfo = window.location;
            var user_name = '<% =AppConfig.Company_Name %>';
            if (user_name == 'As-Siraat Serving Humanity') {
                reportPath = '../../ReportViewer.aspx';
            } else {
                reportPath = 'ReportViewer.aspx'; // same folder
            }
            var url = '/ReportViewer.aspx?ReportName=Voucher_GL&Voucher_ID=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/' + reportPath +  '?ReportName=Voucher_GL&Voucher_ID=' + id;
            }
            window.open(url, '_blanks');
        }
        function UnApprove() {
            elementIsClicked = true;
            debugger;
            var VID = '<% =Request.QueryString["VID"] %>';
            PageMethods.UnApproveVoucher(VID, function (Tests) {
                debugger
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'UnApproved Done Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                location.reload();
            });
        }
        function loadtokenInputsForPRNo(elementId, data) {
            var accountType = $("input[name='rbtn']:checked").val();
            if (elementId == "#txtAccountName") {

                $(elementId).tokenInput("../../json.aspx?Table=VoucherByAccountType&AccountType=" + accountType,
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
        function sendFile(ID) {
            debugger;
            var fileInput = $('#ChoseVoucherfile')[0];
            if (fileInput.files.length > 0) {
                debugger;
                var data = new FormData();
                data.append('file', $('#ChoseVoucherfile')[0].files[0]);
                data.append('ID', ID);
                $.ajax({
                    type: 'post',
                    url: '/../upload/UploadVoucherFiles.ashx',
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <!-- Left Column -->
        <div class="col-lg-6">
            <div class="row">
                <div class="col-lg-4">
                    <label>Type</label>
                    <input class="form-control" value="BCR" type="text" id="txt_vcher_type" readonly="readonly" />
                </div>
                <div class="col-lg-4">
                    <label>No</label>
                    <input class="form-control" type="text" value="New" id="voucher_no" readonly="readonly" />
                </div>
                <div class="col-lg-4">
                    <label>Date</label>
                    <input class="form-control" type="text" id="txt_date" />
                </div>
               
            </div>
            <div class="row mt-3" style="margin-top:15px">
                <div class="col-lg-4">
                    <label>Ref Num</label>
                    <input class="form-control" type="text" id="txt_ref_no" />
                </div>
                <div class="col-lg-4">
                    <%--<label id="lblptn">Pay to Name</label>--%>
                    <label id="lblptn" style="display: none;">Pay to Name</label>
                    <label id="lblname" style="display: none;">Name</label>
                    <label id="lbldocno" style="display: none;">Document #</label>
                    <label id="lblreference" style="display: none;">Reference</label>
                    <input class="form-control" type="text" id="txt_Ptn" />
                </div>
                <div class="col-lg-4">
                    <label>Status</label>
                    <input class="form-control" type="text" id="txtstatus" readonly="readonly" />
                </div>
            </div>
            <div class="row mt-3" style="margin-top:16px">
                 <div class="col-lg-4 col-md-4 col-sm-4">
                       <label>Vendor Name</label>
                      <select id="ddlVendor" class="form-control form-control-sm">
                          <option value="0">Please Select</option>
                      </select>
                 </div>
                <div class="col-lg-5 col-md-5 col-sm-5">
                    <label>Description</label>
                    <textarea class="form-control" id="txt_descrip_master" rows="1" cols="20"></textarea>
                </div>
                <div class="col-lg-3">
                     <label id="lb_Attachments" class="w115 fleft">Attachments</label>
                     <input id="ChoseVoucherfile" type="file" name="ChoseVoucherfile" />
                     <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>
                 </div>
            </div>
            <div class="row">
                <div class="col-lg-1 col-md-2 col-sm-2">
                <%--<input type="checkbox" id="Cash" />--%> 
                    <input type="radio" name="rbtn" id="chkAll" tabindex="11" value="rbtnAll" checked />

                </div>
                     <div class="col-lg-2 col-md-4 col-sm-4">
                <label>All</label>
                    </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                <%--<input type="checkbox" id="Cash" />--%> 
                    <input type="radio" name="rbtn" id="chkcash" tabindex="11" value="rbtncash"  />

                </div>
                     <div class="col-lg-2 col-md-4 col-sm-4">
                <label>Cash</label>
                    </div>
                <div class="col-lg-1 col-md-2 col-sm-2">
                <%--<input type="checkbox" id="Bank" />--%> 
                     <input type="radio" name="rbtn" tabindex="12" id="chkBank" value="rbtnbank" />

                </div>
                     <div class="col-lg-2 col-md-4 col-sm-4">
                <label>Bank</label>
                    </div>
            </div>
        </div>

        <!-- Right Column -->
        <div class="col-lg-6">
            <div class="row">
                <!-- Currency Exchange Card -->
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header" style="border-bottom-style: double;">
                            <h4>Currency Exchange</h4>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-lg-6 col-md-6 col-sm-6">
                            <label>Currency</label>
                            <select class="form-control" id="ddl_currency">
                                <option>PKR</option>
                                <option>USD</option>
                                <option>AUD</option>
                            </select>
                            </div>
                            <div class="col-lg-6 col-md-6 col-sm-6">
                            <label class="mt-3">Exchange Rate</label>
                            <input class="form-control" type="text" id="txt_exg_rate" value="1.00" readonly="readonly" />
                        </div>
                                </div>
                        </div>
                    </div>
                </div>

                <!-- Voucher Summary Card -->
                <div class="col-md-6">
                    <div class="card">
                        <div class="card-header" style="border-bottom-style: double;">
                            <h4>Voucher Summary</h4>
                        </div>
                        <div class="card-body">
                            <div class="row">
                                <div class="col-md-6">
                                    <label>Debit</label>
                                    <input class="form-control" type="text" id="txt_debit" readonly="readonly" />
                                </div>
                                <div class="col-md-6">
                                    <label>Credit</label>
                                    <input class="form-control" type="text" id="txt_credit" readonly="readonly" />
                                </div>
                            </div>
                            <div class="row mt-2">
                                <div class="col-md-6">
                                    <label>Diff</label>
                                      <input class="form-control" type="text" id="txt_diff" readonly="readonly" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="col-12">
        <div class="table-container" style="margin-top: 15px;">
            <table class="table table-bordered" id="tbldescription">
                <thead class="thead-light">
                    <tr style="color: black">
                        <th id="seq" style="width: 5%;">Seq</th>
                        <th id="th_acc" style="width: 15%;">Account No.</th>
                        <th style="width: 10%;">Cost Center</th>
                        <th style="width: 10%;">Department</th>
                        <th id="th-nar" style="width: 20%;">Naration</th>
                        <th id="txtheader_cheqno" style="width: 10%;">Chq No.</th>
                        <th id="txtheader_cheqdate" style="width: 10%;">Chq Date</th>
                        <th id="deb" style="width: 10%;">Debit</th>
                        <th id="cre" style="width: 10%;">Credit</th>
                        <th id="plus" style="width: 5%;"></th>
                    </tr>
                    <tr>
                        <td style="width: 5%;">
                            <div>
                            </div>
                        </td>
                        <td style="width: 15%;">
                            <div>
                                <input class ="form-control" type="text" id="txtAccountName"  name="txtAccountName" placeholder="Search for a GL Accounts" />
                                <input type="hidden"  id="hdfAccount_Code" name="hdfAccount_Code" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div>
                                <select class="form-control" id="ddlcostcenter" name="ddlcostcenter">
                                    <option></option>
                                </select>
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div>
                                <select class="form-control" id="ddldepartment" name="ddldepartment">
                                    <option></option>
                                </select>
                            </div>
                        </td>
                        <td style="width: 20%;">
                            <div>
                                <input class="form-control" type="text" id="txtnarration" />
                            </div>
                        </td>
                        <td style="width: 10%;" id="td_txtcheqno">
                            <div>
                                <input class="form-control" type="text" id="txtcheqno" />
                            </div>
                        </td>
                        <td style="width: 10%;" id="td_txtcheqdate">
                            <div>
                                <input class="form-control" type="text" id="txtcheqdate" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div>
                                <input class="form-control" type="text" id="txt_debitamount" />
                            </div>
                        </td>
                        <td style="width: 10%;">
                            <div>
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
                <div class="col-lg-1 col-md-4 col-sm-12">
                    <input type="button" class="btn btn-primry" id="btnunapprove" value="UnApprove" onclick="UnApprove()" />
                </div>
                <div class="col-lg-1 col-md-4 col-sm-12">
                    <input type="button" class="btn btn-primry" id="btnprint" value="Print" onclick="PrintReport()" />
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
