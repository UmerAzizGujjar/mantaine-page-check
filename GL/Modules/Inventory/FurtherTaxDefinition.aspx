<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FurtherTaxDefinition.aspx.cs" Inherits="PMS.Modules.Inventory.FurtherTaxDefinition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        var _global_payable = '';
        var _global_receiveable = '';

        $(document).ready(function () {
            loadItemList();
            loadrecvablaccountegl();
            loadpayableaccountgl();
            setTimeout(function () { LoadAccount(); }, 2000);
        });

        function SaveAllRecord() {
            var btnSave = 'Update';
            var tableItems = $('#tblItemDescription');
            var Furtherlist = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {
                var taxType = $(value).find('td input[name=Tax_Type]').val();
                var taxPerc = $(value).find('td input[name=Further_Tax_Perc]').val();
                if (taxType && taxPerc) {
                    Furtherlist.push({
                        'Further_Tax_ID': $(value).find('td input[name=Further_Tax_ID]').val(),
                        'Tax_Type': $(value).find('td input[name=Tax_Type]').val(),
                        'Further_Tax_Perc': $(value).find('td input[name=Further_Tax_Perc]').val(),
                        'Account_ID_Payable': $(value).find('td select[name=Account_ID_Payable] :selected').val(),
                        'Description_Payable': $(value).find('td input[name=Description_Payable]').val(),
                        'Account_Code_Recvable': $(value).find('td select[name=Account_Code_Recvable] :selected').val(),
                        'Description_Recvable': $(value).find('td input[name=Description_Recvable]').val(),
                        'Activechk': $(value).find('input[name="chk_Active"]').prop('checked'),
                        'STWH': $(value).find('input[name="chk_STWH"]').prop('checked')
                    });
                }
            });
            var AllItemDetail = { 'btnSave': btnSave, 'Furtherlist': Furtherlist };
            PageMethods.saveFurtherTax(btnSave, JSON.stringify(AllItemDetail), function (res) {
                Swal.fire({
                    icon: 'success',
                    title: 'Success!',
                    text: 'Data Saved Successfully',
                    showConfirmButton: false,
                    timer: 2500,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                window.location.href = 'FurtherTaxDefinition.aspx';
            });
        }

        function LoadAccount() {
            var rows = '';
            PageMethods.LoadAccount(function (resp) {
                var data = JSON.parse(resp);
                $.each(data, function (key, value) {
                    var chk_STWH_checked = value.S_W_H_Tax ? 'checked="checked"' : '';
                    var chk_Active_checked = value.Active ? 'checked="checked"' : '';
                    var rowIndex = key + 1;

                    rows += '<tr>' +
                        '<td style="display:none"><input type="text" id="Further_Tax_ID' + rowIndex + '" name="Further_Tax_ID" value="' + value.Further_Tax_ID + '"/></td>' +
                        '<td><input style="width:175px!important;" type="text" id="Tax_Type' + rowIndex + '" name="Tax_Type" value="' + value.Tax_Type + '" readonly /></td>' +
                        '<td><input style="width:55px!important;" type="text" id="Further_Tax_Perc' + rowIndex + '" name="Further_Tax_Perc" value="' + value.Further_Tax_Perc + '" readonly /></td>' +
                        '<td style="display:none">' +
                        '<select style="width:175px!important;" id="Account_ID_Payable' + rowIndex + '" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' +
                        _global_payable +
                        '</select>' +
                        '</td>' +
                        '<td style="display:none"><input style="width:165px!important;" type="text" id="Description_Payable' + rowIndex + '" name="Description_Payable" value="' + value.Description_Payable + '" readonly /></td>' +
                        '<td>' +
                        '<select style="width:175px!important;" id="Account_Code_Recvable' + rowIndex + '" name="Account_Code_Recvable" onchange="loadrecvablaccountegl(this)">' +
                        _global_receiveable +
                        '</select>' +
                        '</td>' +
                        '<td><input style="width:195px!important;" type="text" id="Description_Recvable' + rowIndex + '" name="Description_Recvable" value="' + value.Description_Recvable + '" readonly /></td>' +
                        '<td><input type="checkbox" style="display:none" id="chk_STWH' + rowIndex + '" name="chk_STWH" ' + chk_STWH_checked + ' /></td>' +
                        '<td><input type="checkbox" style="margin-left:-159px" id="chk_Active' + rowIndex + '" name="chk_Active" ' + chk_Active_checked + ' /></td>' +
                        '<td><a href="javascript:void(0)" style="margin-left:-113px" onclick="EditRow(' + rowIndex + ')">' +
                        '<i class="glyphicon glyphicon-edit" style="color:#f30a0a;"></i>' +
                        '</a></td>' +
                        '</tr>';
                });

                $('#tblItemDescriptionDetail').append(rows);
                $('input, select').attr('autocomplete', 'off');
                $('select').select2();

                $.each(data, function (key, value) {
                    var idx = key + 1;
                    setTimeout(function () {
                        $('#Account_ID_Payable' + idx)
                            .val(value.Account_ID_Payable)
                            .prop("disabled", true)
                            .trigger('change');

                        $('#Account_Code_Recvable' + idx)
                            .val(value.Account_Code_Recvable)
                            .prop("disabled", true)
                            .trigger('change');
                    }, 3000); 
                });
            });
        }

        function Addrow() {
            var rowlength = $('#tblItemDescription tr').length;
            var rows = '<tr>' +
                '<td><input style="width:175px!important;" type="text" name="Tax_Type"/></td>' +
                '<td><input style="width:35px!important;" type="text" name="Further_Tax_Perc"/></td>' +
                '<td style="display:none"><select style="width:175px!important;" name="Account_ID_Payable" onchange="loadpayableaccountgl(this)">' + _global_payable + '</select></td>' +
                '<td style="display:none"><input style="width:165px!important;" type="text" name="Description_Payable"/></td>' +
                '<td><select style="width:175px!important;" name="Account_Code_Recvable" onchange="loadrecvablaccountegl(this)">' + _global_receiveable + '</select></td>' +
                '<td><input style="width:165px!important;" type="text" name="Description_Recvable"/></td>' +
                '<td><input type="checkbox" style="display:none" name="chk_STWH"/></td>' +
                '<td><input type="checkbox" style="margin-left:-154px" name="chk_Active"/></td>' +
                '<td><a href="javascript:void(0)" style="margin-left:-109px" onclick="EditRow(' + rowlength + ')"><i class="glyphicon glyphicon-edit" style="color:#f30a0a;"></i></a></td>' +
                '</tr>';
            $('#tblItemDescription').append(rows);
            $('#tblItemDescription select').select2();
        }

        function EditRow(index) {
            $('#Tax_Type' + index).prop('readonly', false);
            $('#Further_Tax_Perc' + index).prop('readonly', false);
            $('#Description_Payable' + index).prop('readonly', false);
            $('#Description_Recvable' + index).prop('readonly', false);
            $('#Account_ID_Payable' + index).prop('disabled', false);
            $('#Account_Code_Recvable' + index).prop('disabled', false);
        }

        function loadItemList() {
            var optionsitem = '';
            $('#Account_ID_Payable').select2();
            $('#Account_Code_Recvable').select2();

            PageMethods.loadAccountList(function (resp) {
                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    $('select').select2();
                    optionsitem += '<option value="' + value.Account_ID + '">' + value.name + '</option>';
                });
                $('#Account_ID_Payable').html(optionsitem);
                $('#Account_Code_Recvable').html(optionsitem);
                _global_payable = optionsitem;
                _global_receiveable = optionsitem;
            }, function (error) {
                alert("Error loading account list: " + error.get_message());
            });
        }

        function loadpayableaccountgl(row) {
            var ID = $(row).val();
            PageMethods.loadpayablegl(ID, function (res) {
                $(row).closest('tr').find('input[name="Description_Payable"]').val(JSON.parse(res)[0]?.name || '');
            });
        }

        function loadrecvablaccountegl(row) {
            var ID = $(row).val();
            PageMethods.loadrecvablegl(ID, function (res) {
                $(row).closest('tr').find('input[name="Description_Recvable"]').val(JSON.parse(res)[0]?.name || '');
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="row">
        <div class="col-lg-10"></div>
        <div class="col-lg-1">
            <input type="button" onclick="Addrow()" value="+" class="btn btn-primry" style="width:44px; float:right;" />
        </div>
    </div>

    <div style="overflow: auto; max-height: 350px; width: 100%;">
        <table class="table responstable" id="tblItemDescription" style="margin-top:13px; font-size:10px; width:100%;">
            <thead>
                <tr>
                    <th>Tax Type</th>
                    <th>Tax %</th>
                    <th style="display:none">Payable Account</th>
                    <th style="display:none">Payable Desc</th>
                    <th>Receivable Account</th>
                    <th>Receivable Desc</th>
                    <th style="display:none">S.T.W.H</th>
                    <th>Active</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblItemDescriptionDetail"></tbody>
        </table>
    </div>

    <div class="col-lg-8 col-md-1 col-sm-6">
        <div class="row">
            <div class="row" style="margin-top: 15px;">
                <div class="col-lg-2">
                    <input type="button" value="Save" class="btn btn-primry" onclick="SaveAllRecord()" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>