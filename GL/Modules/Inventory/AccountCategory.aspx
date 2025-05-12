<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AccountCategory.aspx.cs" Inherits="PMS.Inventory.AccountCategory" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style type="text/css">
        .select2-selection__rendered
        {
            line-height: 18px !important;
        }
        .main input 
        {
            margin-bottom: 0px !important;
        }
        .select2-container .select2-selection--single 
        {
            height: 20px !important;
        }
        .select2-selection__arrow 
        {
            height: 20px !important;
        }
        input[type="text"] 
        {
            height: 20px !important;
        }
        #ctl00_MainContent_Label2 
        {
            position: relative;
            left: 7px;
        }
        li.token-input-token p 
        {
            margin: -3px !important;
        }
        input[type="number"] 
        {
            height: 20px !important;
        }
        textarea 
        {
            font-size: 10px !important;
        }
        select 
        {
            height: 20px !important;
            
        }
        ul.token-input-list 
        {
            height: 23px !important;
            width: 692px !important;
        }
        div.token-input-dropdown 
        {
            overflow: auto;
            max-height: 150px;
        }
        ul.token-input-list 
        {
            width: 168px;
        }
        .table
        {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
        }
        .table tr 
        {
            border: 1px solid #D9E4E6;
        }
        .table tr:nth-child(even) 
        {
            background-color: #EAF3F3;
        }
        .table th 
        {
            display: none;
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            padding: 1em;
        }
        .table thead th 
        {
            display: table-cell;
            text-align: center;
        }
        @media (min-width: 480px) 
        {
        .table th:nth-child(2) span
        {
            display: block;
        }
        .table th:nth-child(2):after 
        {
            display: none;
        }
        }
        .table td 
        {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }
        .table td:first-child 
        {
            display: table-cell;
            text-align: center;
            border-right: 1px solid #D9E4E6;
        }
        @media (min-width: 480px) 
        {
        .table td 
        {
            border: 1px solid #D9E4E6;
        }
        }
        .table th, .table td 
        {
         text-align: center;
         margin: .5em 1em;
        }
        @media (min-width: 480px) 
        {
        .table th, .table td 
        {
          display: table-cell;
          padding: 1em;
        }
        }
        select option 
        {
         background: #f5f5f5;
         font-weight: bold;
         color: #000000;
         font-size: 10px !important;
        }
        .responstable td 
        {
            height: 0px !important;
            padding: 0 !important;
        }
        .labelIGP 
        {
            font-size: 11px !important;
        }
        .select2
        {
            width:123px !important;
        }

    </style>
    <script type="text/javascript">
        function Addrow() {
            debugger;
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td style="display:none;">' + rowlength + '</td>' +
                '<td ><input type=text class="form-control" id="AcId' + rowlength + '" name="AcId" style="width:123px !important;font-size: 10px !important;height:20px!important;"  value=' + rowlength + ' readonly=readonly /></td>' +
                '<td><input type=text class="form-control" id="AccountCategoryName' + rowlength + '" name="AccountCategoryName" style="width:123px !important;font-size: 10px !important;height:20px!important;"  /></td>' +
                '<td><select class="form-control" id="txtAccountCode' + rowlength + '" name="txtAccountCode" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtConsumptionAccount' + rowlength + '" name="txtConsumptionAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtsalAccount' + rowlength + '" name="txtsalAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtCgsAccount' + rowlength + '" name="txtCgsAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtworkProgress' + rowlength + '" name="txtworkProgress" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><select class="form-control" id="txtCapitalConsumption' + rowlength + '" name="txtCapitalConsumption" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a></td>'
            '</tr>';
            $('#tblItemDescriptionDetail').append(rows);
            loadItemList(rowlength);
        }
        $(document).ready(function () {
            $('select').select2();
            LoadAccount();
            $('#btnSave').attr('disabled', true);
        });
        function loadItemList(rowlength) {
            debugger;
            var optionsitem = '';
            var length = rowlength;
            $('#txtAccountCode' + length + '').select2();
            $('#txtConsumptionAccount' + length + '').select2();
            $('#txtsalAccount' + length + '').select2();
            $('#txtCgsAccount' + length + '').select2();
            $('#txtworkProgress' + length + '').select2();
            $('#txtCapitalConsumption' + length + '').select2();
            PageMethods.loadAccountList(function (resp) {
                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsitem += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });
                $('#txtAccountCode' + length + '').html(optionsitem);
                $('#txtConsumptionAccount' + length + '').html(optionsitem);
                $('#txtsalAccount' + length + '').html(optionsitem);
                $('#txtCgsAccount' + length + '').html(optionsitem);
                $('#txtworkProgress' + length + '').html(optionsitem);
                $('#txtCapitalConsumption' + length + '').html(optionsitem);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function SaveAllRecord() {
            debugger;
            var btnSave = 'Update';
            var tableItems = $('#tblItemDescription');
            var Account_list = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {

                var cataName = $(value).find('td input[name=AccountCategoryName]').val();
                var assetAccount = $(value).find('td select[name=txtAccountCode]').val();
                var consumptionAccount = $(value).find('td select[name=txtConsumptionAccount]').val();
                var salAccount = $(value).find('td select[name=txtsalAccount]').val();
                var cgsAccount = $(value).find('td select[name=txtCgsAccount]').val();
                var workProgressAccount = $(value).find('td select[name=txtworkProgress]').val();
                var capitalConsumptionAccount = $(value).find('td select[name=txtCapitalConsumption]').val();

                if ((assetAccount !== '0' || consumptionAccount !== '0' || salAccount !== '0' || cgsAccount !== '0' || workProgressAccount !== '0' || capitalConsumptionAccount !== '0') && cataName) {
                    Account_list.push({
                        'Account_Category_Id': $(value).find('td input[name=AccountId]').val(), 'CategoryName': $(value).find('td input[name=AccountCategoryName]').val(), 'AssetAccount': $(value).find('td select[name=txtAccountCode]').val(), 'ConsumptionAccount': $(value).find('td select[name=txtConsumptionAccount]').val(), 'SalAccount': $(value).find('td select[name=txtsalAccount]').val(), 'CgsAccount': $(value).find('td select[name=txtCgsAccount]').val(), 'WorkProgressAccount': $(value).find('td select[name=txtworkProgress]').val(), 'CapitalConsumptionAccount': $(value).find('td select[name=txtCapitalConsumption]').val(),
                    });              
                }
            });
            var AllItemDetail = { 'btnSave': btnSave, 'AccountList': Account_list };
            PageMethods.SaveAccount(btnSave, JSON.stringify(AllItemDetail), function (res) {
                alert('Data Save Successfully');
                $('#btnSave').val("Update");
                location.reload();
            });
        }
        function LoadAccount() {
            var rows = '';
            PageMethods.LoadAccount(function (resp) {
                debugger;
                var data = (JSON.parse(resp));
                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescriptionDetail tbody tr').length)));
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td style="display:none"><input type=text class="form-control" id="AccountId' + (key + 1) + '" name="AccountId" style="width:164px !important;font-size: 10px !important;height:20px!important;"  value=' + data[key].Account_Category_Id + ' readonly=readonly /></td>' +
                        '<td><input type=text class="form-control" id="Id' + (key + 1) + '" name="Id" style="width:123px !important;font-size: 10px !important;height:20px!important;"  value=' + (key + 1) + ' readonly=readonly /></td>' +
                        '<td><input type=text class="form-control" id="AccountCategoryName' + (key + 1) + '" name="AccountCategoryName" style="font-size: 10px !important;height:20px!important;"  value="' + value.CategoryName + '" readonly=readonly /></td>' +
                        '<td><select class="form-control" id="txtAccountCode' + (key + 1) + '" name="txtAccountCode" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtConsumptionAccount' + (key + 1) + '" name="txtConsumptionAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtsalAccount' + (key + 1) + '" name="txtsalAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtCgsAccount' + (key + 1) + '" name="txtCgsAccount" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtworkProgress' + (key + 1) + '" name="txtworkProgress" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><select class="form-control" id="txtCapitalConsumption' + (key + 1) + '" name="txtCapitalConsumption" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +
                        '<td><a href="javascript:void(0)" onclick="EditRow(' + (key + 1) + ')"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i="">' +
                        '</td>'
                    '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
                $.each(selectedOptions, function (key, value) {
                    loadItemList(key + 1);
                    setTimeout(function () {
                        $('#txtAccountCode' + (key + 1)).val(value.Asset_Account).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#txtConsumptionAccount' + (key + 1)).val(value.Consumption_Account).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#txtsalAccount' + (key + 1)).val(value.Sal_Account).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#txtCgsAccount' + (key + 1)).val(value.CgsAccount).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#txtworkProgress' + (key + 1)).val(value.Work_Progress_Account).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#txtCapitalConsumption' + (key + 1)).val(value.Capital_Consumption_Account).prop("disabled", true).trigger('change');
                    }, 4000);
                });
                setTimeout(function () {
                    $('#btnSave').attr('disabled', false);
                }, 6000);

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
        function EditRow(rowlength) {
            var length = rowlength;
            $('#AccountCategoryName' + length).attr("readonly", false);
            $('#txtAccountCode' + length).prop("disabled", false).trigger('change');
            $('#txtConsumptionAccount' + length).prop("disabled", false).trigger('change');
            $('#txtsalAccount' + length).prop("disabled", false).trigger('change');
            $('#txtCgsAccount' + length).prop("disabled", false).trigger('change');
            $('#txtworkProgress' + length).prop("disabled", false).trigger('change');
            $('#txtCapitalConsumption' + length).prop("disabled", false).trigger('change');
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
     <input type="button" class="btn-primry" onclick="Addrow()" value="+" id="AddAccount" />
 </div>
        </div>
    <div class="row">
        <div class="col-lg-12 col-md-12- col-sm-12" style="overflow-x:scroll;height:600px">
        <table class="table" id="tblItemDescription" style="margin-top: 13px; font-size: 10px!important;">
            <thead >
                <tr>
                    <th style="display: none;">Account Category Id</th>
                    <th style="width: 70px !important; text-align: center; font-size: 10px;">Id</th>
                    <th style="width: 50px; text-align: center; font-size: 10px;">Category Name</th>
                    <th style="width: 50px; text-align: center; font-size: 10px;">Asset Account</th>
                    <th style="width: 70px; text-align: center;">Consumption Account</th>
                    <th style="width: 30px; text-align: center;">Sale Account</th>
                    <th style="width: 30px; text-align: center;">Cost of Sale</th>
                    <th style="width: 35px; text-align: center;">Work in Process</th>
                    <th style="width: 40px; text-align: center;">Capital Consumption</th>
                    <th style="width: 20px; text-align: center;" id="thaction">Action</th>
                </tr>
               
            </thead>
            <tbody id="tblItemDescriptionDetail">
            </tbody>
        </table>
        </div>
        </div>
    <div class="purchaseOrderSubmitForm" style=" margin-top: 21px;">
      <div class="row">
            <div class="col-lg-1 col-md-4 col-sm-12">
                            <input type="button" class="btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave" />
                        </div>
      </div>
                      
              
    </div>
</asp:Content>
