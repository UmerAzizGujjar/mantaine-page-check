<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SalesTaxDefinition.aspx.cs" Inherits="PMS.SalesTaxDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        var _global_payable = '';
        var _global_receiveable = '';
        var _global_taxtypeddl = '';
        var _global_taxnature = '';
        $(document).ready(function () {
            loadItemList();
            loadrecvablaccountegl();
            loadpayableaccountgl();
            setTimeout(function () { LoadAccount(); }, 2000);
        });
        function SaveAllRecord() {
            debugger;
            var btnSave = 'Update';
            var tableItems = $('#tblItemDescription');
            var Account_list = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {
                debugger;
                var taxType = $(value).find('td input[name=Tax_Type]').val();
                var salesTaxPerc = $(value).find('td input[name=Sales_Tax_Perc]').val();
                if (taxType && salesTaxPerc) {
                    Account_list.push({
                        'Sales_Tax_ID': $(value).find('td input[name=Sales_Tax_ID]').val(),
                        'Tax_Type': $(value).find('td input[name=Tax_Type]').val(),
                        'Sales_Tax_Perc': $(value).find('td input[name=Sales_Tax_Perc]').val(),
                        'Account_ID_Payable': $(value).find('td select[name=Account_ID_Payable] :selected').val(),
                        'Description_Payable': $(value).find('td input[name=Description_Payable]').val(),
                        'Account_Code_Recvable': $(value).find('td select[name=Account_Code_Recvable] :selected').val(),
                        'Description_Recvable': $(value).find('td input[name=Description_Recvable]').val(),
                        'Activechk': $(value).find('input[name="chk_Active"]').prop('checked'),
                        'STWH': $(value).find('input[name="chk_STWH"]').prop('checked')
                    });
                }
            });
            var AllItemDetail = { 'btnSave': btnSave, 'AccountList': Account_list };
            PageMethods.savewithholdtaxinfo(btnSave, JSON.stringify(AllItemDetail), function (res) {
                debugger;
                alert('Data Save Successfully');
                window.location.href = 'SalesTaxDefinition.aspx';
                $('#btnSave').val("Update");
            });
        }

        function LoadAccount() {
            debugger
            var rows = '';
            PageMethods.LoadAccount(function (resp) {
                debugger
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescription tbody tr').length)));
                $.each(data, function (key, value) {
                    debugger
                    var chk_STWH_checked = value.S_W_H_Tax ? 'checked="checked"' : '';
                    var chk_Active_checked = value.Active ? 'checked="checked"' : '';
                    rows += '<tr>' +
                        '<td style="display:none"><input type=text id="Sales_Tax_ID" name="Sales_Tax_ID" value="' + data[key].Sales_Tax_ID + '"/></td>' +
                        '<td><input style="width: 175px !important;" type=text id="Tax_Type' + (key + 1) + '" name="Tax_Type"  value="' + value.Tax_Type + '" readonly="readonly" /></td>' +
                        '<td><input style="width: 65px !important;" type=text class="form-control" id="Sales_Tax_Perc' + (key + 1) + '" name="Sales_Tax_Perc" value="' + value.Sales_Tax_Perc + '" readonly="readonly"/></td>' +
                        '<td style="display:none"><select style="width: 175px !important;" readonly="readonly" id="Account_ID_Payable' + (key + 1) + '" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' + _global_payable + '</select></td>' +
                        '<td style="display:none"><input style="width: 165px !important;" type=text id="Description_Payable' + (key + 1) + '" readonly="readonly" name="Description_Payable"  value="' + value.Description_Payable + '"/></td>' +
                        '<td><select style="width: 175px !important;" id="Account_Code_Recvable' + (key + 1) + '" name="Account_Code_Recvable" readonly="readonly" onchange="loadrecvablaccountegl(this)" >' + _global_receiveable + '</select></td>' +
                        '<td><input style="width: 165px !important;" type=text id="Description_Recvable' + (key + 1) + '" readonly="readonly" name="Description_Recvable"  value="' + value.Description_Recvable + '" /></td>' +
                        '<td><input type="checkbox" style="margin-left:-30px" id="chk_STWH' + (key + 1) + '" name="chk_STWH" ' + chk_STWH_checked + ' /></td>' +
                        '<td><input type="checkbox" style="margin-left:-20px" id="chk_Active' + (key + 1) + '" name="chk_Active" ' + chk_Active_checked + ' /></td>' +
                        '<td><a href="javascript:void(0)" onclick="EditRow(' + (key + 1) + ')"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i="">'
                    '</td>' +
               '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
                $('input').attr('autocomplete', 'off');
                $('select').select2();
                $.each(selectedOptions, function (key, value) {
                    setTimeout(function () {
                        $('#Account_ID_Payable' + (key + 1) + '').val(value.Account_ID_Payable).prop("disabled", true).trigger('change');
                    }, 3000);
                    setTimeout(function () {
                        $('#Account_Code_Recvable' + (key + 1) + '').val(value.Account_Code_Recvable).prop("disabled", true).trigger('change');
                    }, 3000);
                });
            });
        }
        function Addrow() {
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td><input  style="width: 175px !important;" type=text id="Tax_Type" name="Tax_Type"  value=""  /></td>' +
                '<td><input  style="width: 65px !important;" type=text id="Sales_Tax_Perc" name="Sales_Tax_Perc" /></td>' +
                '<td style="display:none"><select style="width: 175px !important;" id="Account_ID_Payable" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' + _global_payable + '</select></td>' +
                '<td style="display:none"><input style="width: 165px !important;" type=text id="Description_Payable" name="Description_Payable" /></td>' +
                '<td><select style="width: 175px !important;" id="Account_Code_Recvable' + rowlength + '" name="Account_Code_Recvable" onchange="loadrecvablaccountegl(this)">' + _global_receiveable + '</select></td>' +
                '<td><input style="width: 165px !important;" type=text id="Description_Recvable" name="Description_Recvable"  /></td>' +
                '<td><input style="margin-left:-30px !important" type="checkbox" id="chk_STWH' + rowlength + '" name="chk_STWH" /></td>' +
                '<td><input style="margin-left:-20px !important" type="checkbox" id="chk_Active' + rowlength + '" name="chk_Active" /></td>' +
                '<td><a href="javascript:void(0)" onclick="EditRow()"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i="">'
            '</td>' +
            '</tr>';
            $('#tblItemDescription').append(rows);
            $('input').attr('autocomplete', 'off');
            $('select').select2();
        }
        function loadItemList() {
            var optionsitem = '';
            $('#Account_ID_Payable').select2();
            $('#Account_Code_Recvable').select2();
            PageMethods.loadAccountList(function (resp) {
                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    $('select').select2();
                    optionsitem += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#Account_ID_Payable').html(optionsitem);
                _global_payable = optionsitem;
                _global_receiveable = optionsitem;
                $('#Account_Code_Recvable').html(optionsitem);
            },
           function (error) {
               alert(error.get_message());
           });
        }

        function EditRow(rowlength) {
            var length = rowlength;
            $('#Tax_Type' + length).attr("readonly", false);
            $('#Sales_Tax_Perc' + length).attr("readonly", false);
            $('#Description_Payable' + length).attr("readonly", false);
            $('#Description_Recvable' + length).attr("readonly", false);
            $('#Account_ID_Payable' + length).prop("disabled", false).trigger('change');
            $('#Account_Code_Recvable' + length).prop("disabled", false).trigger('change');
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
         <div class="col-lg-1 col-md-4 col-sm-6" >
                    <input type="button" onclick="Addrow()" class="btn btn-primry" value="+" id="AddAccount"  />
                </div>
    </div>
    <div class="row">
    <div class="col-lg-9 col-md-9 col-sm-9" style="overflow: scroll; height: 600px !important; position: relative;">
        <table class="table responstable" id="tblItemDescription" style="margin-top: 13px; width: 100% !important; overflow: unset; height: auto; overflow: scroll">
            <thead>
                <tr>
                    <th id="tax_th">Tax Type</th>
                    <th>Tax %</th>
                    <th style="display:none">Payable Account Code</th>
                    <th style="display:none">Payable Description</th>
                    <th>Receivable Account Code</th>
                    <th>Receivable Description</th>
                    <th>S.T.W.H</th>
                    <th>Active</th>
                    <th style="z-index: 5000;">Action</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
    </div>
        </div>
    <div class="col-lg-1 col-md-4 col-sm-12">
    <input type="button" name="Save" class="btn btn-primry" value="Save" id="Savebtn" onclick="SaveAllRecord()" />
        </div>
</asp:Content>