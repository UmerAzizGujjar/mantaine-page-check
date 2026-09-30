<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentAccountDefinition.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentAccountDefinition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
    <script type="text/javascript">
        function Addrow() {
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td style="display:none;">' + rowlength + '</td>' +
                '<td ><input type=text class="form-control" id="AcId' + rowlength + '" name="AcId" style="width:164px !important;font-size: 10px !important;height:10px!important;"  value=' + rowlength + ' readonly=readonly /></td>' +


                '<td><input type"text" class="form-control" id="txtCategory' + rowlength + '" name="txtCategory" style="width:164px !important;font-size: 10px !important;height:10px!important;"></td>' +

                '<td><select class="form-control" id="AccruedIncome' + rowlength + '" name="AccruedIncome" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +

                '<td><select class="form-control" id="NetIncome' + rowlength + '" name="NetIncome" style="width:164px !important;font-size: 10px !important;height:10px!important;"></select></td>' +

                '<td><input type"text" class="form-control" id="txtReceivaleFee' + rowlength + '" name="txtReceivaleFee" style="width:164px !important;font-size: 10px !important;height:10px!important;"></td>' +


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
            var optionsitem = '';
            var length = rowlength;
            $('#AccruedIncome' + length + '').select2();
            $('#NetIncome' + length + '').select2();

            PageMethods.loadAccountList(function (resp) {
                optionsitem = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsitem += '<option value="' + value.Account_ID + '" >' + value.name + '</option>';
                });

                $('#AccruedIncome' + length + '').html(optionsitem);
                $('#NetIncome' + length + '').html(optionsitem);


            },
                function (error) {
                    alert(error.get_message());
                });


        }



        function SaveAllRecord() {
            var btnSave = 'Update';
            var tableItems = $('#tblItemDescription');
            var Account_list = [];

            tableItems.find('tr:gt(0)').each(function (key, value) {
                Account_list.push({
                    'Account_Category_Id': $(value).find('td input[name=AccountId]').val(),
                    'txtCategory': $(value).find('td input[name=txtCategory]').val(),
                    'AccruedIcnome': $(value).find('td select[name=AccruedIncome]').val(),
                    'NetIncome': $(value).find('td select[name=NetIncome]').val(),
                    'ReceivableFee': $(value).find('td input[name=txtReceivaleFee]').val(),


                });

            });
            var AllItemDetail = { 'btnSave': btnSave, 'AccountList': Account_list };
            PageMethods.SaveAccount(btnSave, JSON.stringify(AllItemDetail), function (res) {

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

                $('#btnSave').val("Update");
                location.reload();
            });
        }

        function LoadAccount() {
            var rows = '';
            PageMethods.LoadAccount(function (resp) {

                var data = (JSON.parse(resp));

                selectedOptions = data;
                var rowIndex = parseInt((parseInt($('#tblItemDescriptionDetail tbody tr').length)));

                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td style="display:none"><input type=text class="form-control" id="AccountId' + (key + 1) + '" name="AccountId" style="width:164px !important;font-size: 10px !important;height:10px!important;"  value=' + data[key].Account_Category_Id + ' readonly=readonly /></td>' +

                        '<td><input type=text class="form-control" id="Id' + (key + 1) + '" name="Id" style="width:164px !important;font-size: 10px !important;height:30px!important;"  value=' + (key + 1) + ' readonly=readonly /></td>' +

                        //                        '<td><select type=text class="form-control" id="AccruedIncome' + (key + 1) + '" name="AccruedIncome" style="width:164px !important;font-size: 10px !important;height:10px!important;"  value="' + value.Accrued_Income + '" readonly=readonly /></td>' +

                        '<td><input type="text" class="form-control" id="txtCategory' + (key + 1) + '" name="txtCategory" value="' + value.Category_Name + '" style="width:164px !important;font-size: 10px !important;height:30px!important;" readonly=readonly ></td>' +


                        '<td><select class="form-control" id="AccruedIncome' + (key + 1) + '" name="AccruedIncome" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +


                        '<td><select class="form-control" id="NetIncome' + (key + 1) + '" name="NetIncome" style="width:164px !important;font-size: 10px !important;height:10px!important;" readonly=readonly ></select></td>' +


                        '<td><input type="text" class="form-control" id="txtReceivaleFee' + (key + 1) + '" name="txtReceivaleFee" value="' + value.Receivable_Fee + '" style="width:164px !important;font-size: 10px !important;height:30px!important;" readonly=readonly ></td>' +

                        '<td><a href="javascript:void(0)" onclick="EditRow(' + (key + 1) + ')"><i class="glyphicon glyphicon-edit" style="width:15px !important;font-size: 13px;color:#438eb9 ;position:relative;" i="">' +
                        '</td>'
                    '</tr>';

                });
                $('#tblItemDescriptionDetail').append(rows);
                $.each(selectedOptions, function (key, value) {
                    loadItemList(key + 1);
                    setTimeout(function () {
                        $('#AccruedIncome' + (key + 1)).val(value.Accrued_Income).prop("disabled", true).trigger('change');
                    }, 4000);
                    setTimeout(function () {
                        $('#NetIncome' + (key + 1)).val(value.Net_Income).prop("disabled", true).trigger('change');
                    }, 4000);



                    setTimeout(function () {
                        $('#btnSave').attr('disabled', false);
                    }, 6000);
                });
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
            $('#txtCategory' + length).attr("readonly", false);
            $('#AccruedIncome' + length).prop("disabled", false).trigger('change');
            $('#NetIncome' + length).prop("disabled", false).trigger('change');
            $('#txtReceivaleFee' + length).attr("readonly", false);


        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div  style="text-align: right; margin-top: 5px; margin-right: 5%;">
            <input type="button" class="btn btn-primry" onclick="Addrow()" value="+" id="AddAccount" style="width: 44px !important;"/>
        </div>
    </div>
    <div class="row">
        <div style="overflow: auto; height: 276px !important;">
            <table class="table responstable" id="tblItemDescription" style="margin-top: 13px; font-size: 10px !important; width: 95% !important;">
                <thead>
                    <tr>
                        <th style="display: none;">Student Account Category Id</th>
                        <th style="width: 50px; text-align: center; font-size: 10px;">Id</th>
                        <th style="width: 50px; text-align: center; font-size: 10px;">Category Name</th>
                        <th style="width: 50px; text-align: center; font-size: 10px;">Accrued Income</th>
                        <th style="width: 50px; text-align: center; font-size: 10px;">Net Income</th>
                        <th style="width: 70px; text-align: center;">Receivable Fee</th>
                        <th style="width: 20px; text-align: center;" id="thaction">Action</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail"></tbody>
            </table>

        </div>

    </div>

    <div class="row">
        <div class="purchaseOrderSubmitForm" style="margin-left: 47px; margin-top: 21px; width: 1200px;">
        </div>
        <div class="row">
            <div class="col-lg-8">

                <div class="col-lg-2 col-md-2 col-sm-3">
                    <input type="button" class="btn btn-primry" onclick="SaveAllRecord()" value="Save" id="btnSave">
                </div>
            </div>

        </div>
        </div>
</asp:Content>
