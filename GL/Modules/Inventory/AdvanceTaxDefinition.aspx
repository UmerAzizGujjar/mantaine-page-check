<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdvanceTaxDefinition.aspx.cs" Inherits="PMS.Modules.Inventory.AdvanceTaxDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script src="../../wwwroot/lib/jquery/accountlist.lazy.js?v=<%= System.IO.File.GetLastWriteTimeUtc(Server.MapPath("~/wwwroot/lib/jquery/accountlist.lazy.js")).Ticks %>" type="text/javascript"></script>
    <script type="text/javascript">
var _global_payable = '';
var _global_receiveable = '';
var _global_taxtypeddl = '';
var _global_taxnature = '';
$(document).ready(function () {
            withAccountList(function () { });   // start loading the account list at once, in parallel with the tax rows
            LoadAccount();
        });
function SaveAllRecord() {
    var btnSave = 'Update';
    var tableItems = $('#tblItemDescription');
    var Advancelist = [];
    tableItems.find('tr:gt(0)').each(function (key, value) {
        var taxType = $(value).find('td input[name=Tax_Type]').val();
        var taxPerc = $(value).find('td input[name=Advance_Tax_Perc]').val();
        if (taxType && taxPerc) {
            Advancelist.push({
                'Advance_Tax_ID': $(value).find('td input[name=Advance_Tax_ID]').val(),
                'Tax_Type': $(value).find('td input[name=Tax_Type]').val(),
                'Advance_Tax_Perc': $(value).find('td input[name=Advance_Tax_Perc]').val(),
                'Account_ID_Payable': $(value).find('td select[name=Account_ID_Payable] :selected').val(),
                'Description_Payable': $(value).find('td input[name=Description_Payable]').val(),
                'Account_Code_Recvable': $(value).find('td select[name=Account_Code_Recvable] :selected').val(),
                'Description_Recvable': $(value).find('td input[name=Description_Recvable]').val(),
                'Activechk': $(value).find('input[name="chk_Active"]').prop('checked'),
                'STWH': $(value).find('input[name="chk_STWH"]').prop('checked')
            });
        }
    });
    var AllItemDetail = { 'btnSave': btnSave, 'Advancelist': Advancelist };
    PageMethods.savewithholdAdvancetax(btnSave, JSON.stringify(AllItemDetail), function (res) {
        alert('Data Save Successfully');
        window.location.href = 'AdvanceTaxDefinition.aspx';
        $('#btnSave').val("Update");
    });
}

        function LoadAccount() {
            var rows = '';
            PageMethods.LoadAccount(function (resp) {
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescription tbody tr').length)));
                $.each(data, function (key, value) {
                    var chk_STWH_checked = value.S_W_H_Tax ? 'checked="checked"' : '';
                    var chk_Active_checked = value.Active ? 'checked="checked"' : '';
                    rows += '<tr>' +
                        '<td style="display:none"><input type="text" id="Advance_Tax_ID" name="Advance_Tax_ID" value="' + value.Advance_Tax_ID + '"/></td>' +
                        '<td><input style="width: 175px !important;" type="text" id="Tax_Type' + (key + 1) + '" name="Tax_Type" value="' + value.Tax_Type + '" readonly="readonly" /></td>' +
                        '<td><input style="width: 35px !important;" type="text" class="form-control" id="Advance_Tax_Perc' + (key + 1) + '" name="Advance_Tax_Perc" value="' + value.Advance_Tax_Perc + '" readonly="readonly"/></td>' +
                        '<td style="display:none"><select style="width: 175px !important;" readonly="readonly" id="Account_ID_Payable' + (key + 1) + '" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' + '</select></td>' +
                        '<td style="display:none"><input style="width: 165px !important;" type="text" id="Description_Payable' + (key + 1) + '" readonly="readonly" name="Description_Payable" value="' + value.Description_Payable + '"/></td>' +
                        '<td><select style="width: 175px !important;" id="Account_Code_Recvable' + (key + 1) + '" name="Account_Code_Recvable" readonly="readonly" onchange="loadrecvablaccountegl(this)">' + '</select></td>' +
                        '<td><input style="width: 165px !important;" type="text" id="Description_Recvable' + (key + 1) + '" readonly="readonly" name="Description_Recvable" value="' + value.Description_Recvable + '" /></td>' +
                        '<td><input type="checkbox" style="display:none" id="chk_STWH' + (key + 1) + '" name="chk_STWH" ' + chk_STWH_checked + ' /></td>' +
                        '<td><input type="checkbox" style="margin-left:-159px" id="chk_Active' + (key + 1) + '" name="chk_Active" ' + chk_Active_checked + ' /></td>' +
                        '<td><a href="javascript:void(0)" style="margin-left:-113px" onclick="EditRow(' + (key + 1) + ')"><i class="fa fa-pencil-square-o" style="font-size:16px;color:var(--theme-accent, #EFA63E) !important;"></i></a></td>' +
                        '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
                $('input').attr('autocomplete', 'off');
                // show each row's saved accounts; the full account list is only added when the row is edited (see EditRow)
                withAccountList(function () {
                    $.each(data, function (key, value) {
                        var idx = key + 1;
                        var payable = $('#Account_ID_Payable' + idx), receivable = $('#Account_Code_Recvable' + idx);
                        showSavedAccount(payable, value.Account_ID_Payable);
                        showSavedAccount(receivable, value.Account_Code_Recvable);
                        payable.prop('disabled', true);
                        receivable.prop('disabled', true);
                    });
                });
            });
        }

        function Addrow() { withAccountList(AddrowCore); }

        function AddrowCore() {
            var rows = '';
            var rowlength = $('#tblItemDescription tr').length;

            rows += '<tr>' +
                '<td><input style="width:175px!important;" type="text" id="Tax_Type' + rowlength + '" name="Tax_Type" value=""/></td>' +
                '<td><input style="width:35px!important;" type="text" id="Advance_Tax_Perc' + rowlength + '" name="Advance_Tax_Perc"/></td>' +
                '<td style="display:none"><select style="width:175px!important;" id="Account_ID_Payable' + rowlength + '" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' + accountOptions() + '</select></td>' +
                '<td style="display:none"><input style="width:165px!important;" type="text" id="Description_Payable' + rowlength + '" name="Description_Payable"/></td>' +
                '<td><select style="width:175px!important;" id="Account_Code_Recvable' + rowlength + '" name="Account_Code_Recvable" onchange="loadrecvablaccountegl(this)">' + accountOptions() + '</select></td>' +
                '<td><input style="width:165px!important;" type="text" id="Description_Recvable' + rowlength + '" name="Description_Recvable"/></td>' +
                '<td><input type="checkbox" style="display:none" id="chk_STWH' + rowlength + '" name="chk_STWH"/></td>' +
                '<td><input type="checkbox"  style="margin-left:-154px" id="chk_Active' + rowlength + '" name="chk_Active"/></td>' +
                '<td><a href="javascript:void(0)"  style="margin-left:-109px" onclick="EditRow(' + rowlength + ')"><i class="fa fa-pencil-square-o" style="font-size:16px;color:var(--theme-accent, #EFA63E) !important;"></i></a></td>' +
                '</tr>';

            $('#tblItemDescription').append(rows);
            $('#tblItemDescription input').attr('autocomplete', 'off');
            $('#tblItemDescription tr:last select').select2();
        }

// loadItemList removed: the account list now loads once via withAccountList() (accountlist.lazy.js)

function EditRow(rowlength) {
    var length = rowlength;
    $('#Tax_Type' + length).attr("readonly", false);
    $('#Advance_Tax_Perc' + length).attr("readonly", false);
    $('#Description_Payable' + length).attr("readonly", false);
    $('#Description_Recvable' + length).attr("readonly", false);
            // this row is being edited: give its two account dropdowns the full list (the saved account stays selected)
            withAccountList(function () {
                $.each(['Account_ID_Payable', 'Account_Code_Recvable'], function (i, id) {
                    var el = $('#' + id + length);
                    fillAllAccounts(el);
                    if (!el.hasClass('select2-hidden-accessible')) { el.select2(); }
                    el.prop('disabled', false);
                });
            });
        }
function loadpayableaccountgl(row) {
    var ID = $(row).closest('tr').find('td select[name=Account_ID_Payable] :selected').val();
    PageMethods.loadpayablegl(ID, function (Tests) {
        $.each(JSON.parse(Tests), function (key, value) {
            $(row).closest('tr').find('td input[name=Description_Payable]').val(value.name);
        });
    });
}
function loadrecvablaccountegl(row) {
    var ID = $(row).closest('tr').find('td select[name=Account_Code_Recvable] :selected').val();
    PageMethods.loadrecvablegl(ID, function (Tests) {
        $.each(JSON.parse(Tests), function (key, value) {
            $(row).closest('tr').find('td input[name=Description_Recvable]').val(value.name);
        });
    });
}

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
       <div class="col-lg-10">
       </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" onclick="Addrow()" value="+" id="AddAccount" class="btn btn-primry" style="width: 44px; float: right;" />
        </div>
    </div>
        <div style="overflow: scroll; height: 350px !important; height: auto; width: 100%; position: relative;">
    <table class="table responstable" id="tblItemDescription" style="margin-top: 13px; font-size: 10px!important; width: 100% !important; overflow: unset; height: auto; overflow: scroll">
        <thead>
            <tr>
                <th id="tax_th">Tax Type</th>
                <th>Tax %</th>
                <th style="display:none">Payable Account Code</th>
                <th style="display:none">Payable Description</th>
                <th>Receivable Account Code</th>
                <th>Receivable Description</th>
                <th style="display:none">S.T.W.H</th>
                <th>Active</th>
                <th style="z-index: 5000;">Action</th>
            </tr>
        </thead>
        <tbody id="tblItemDescriptionDetail">
        </tbody>
    </table>
</div>
    <div class="row">
        <div class="col-lg-8 col-md-10 col-sm-12">
            <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" name="Save" value="Save" class="btn btn-primry" id="Savebtn" onclick="SaveAllRecord()" />
            </div>
        </div>
    </div>
    </div>
</asp:Content>
