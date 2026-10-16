<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BranchWiseWareHouse.aspx.cs" Inherits="PMS.Modules.Administrator.BranchWiseWareHouse" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        var id = '<%= Request.QueryString["ID"] %>';
        var swalClass = { popup: 'swal-big-popup', title: 'swal-big-title', htmlContainer: 'swal-big-text' };

        $(document).ready(function () {
            $('#ddlBranch').select2();
            $('#ddlWareHouse').select2();
            fillBranch(function () {
                if (id != '') {
                    $('#ddlBranch').val(id).trigger('change').attr('disabled', 'disabled');
                    $("#btn_Save").val('Update');
                    LoadDetail(id);
                }
            });
            fillWareHouse();
        });

        function showError(msg) {
            Swal.fire({ icon: 'error', title: 'Error!', text: msg, timer: 2500, showConfirmButton: false, customClass: swalClass });
        }

        function fillBranch(done) {
            PageMethods.fillBranch(function (result) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.Branch_ID + '">' + value.Branch_Name + '</option>';
                });
                $('#ddlBranch').html(options);
                if (done) done();
            });
        }

        function fillWareHouse() {
            PageMethods.fillWareHouse(function (result) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.WareHouse + '">' + value.WareHouse_Name + '</option>';
                });
                $('#ddlWareHouse').html(options);
            });
        }

        function LoadDetail(branchId) {
            PageMethods.LoadDetail(branchId, function (res) {
                $.each(JSON.parse(res), function (key, value) {
                    appendRow(value.Branch_Name, value.WareHouse, value.WareHouse_Name);
                });
            });
        }

        function appendRow(branchName, wareHouse, wareHouseName) {
            var row = '<tr>' +
                '<td><input type="text" name="txt_branch" style="width:100%;" readonly /></td>' +
                '<td style="display:none;"><input type="text" name="txt_warehouse_id" /></td>' +
                '<td><input type="text" name="txt_warehouse" style="width:100%;" readonly /></td>' +
                '<td><a href="#" onclick="Delete(this); return false;"><i class="glyphicon glyphicon-trash" style="color:#f30a0a;"></i></a></td>' +
                '</tr>';
            var $row = $(row);
            $row.find('input[name=txt_branch]').val(branchName);
            $row.find('input[name=txt_warehouse_id]').val(wareHouse);
            $row.find('input[name=txt_warehouse]').val(wareHouseName);
            $('#tblWareHouseDetail').append($row);
        }

        function Addrow() {
            var branch_id = $('#ddlBranch').val();
            var wareHouse = $('#ddlWareHouse').val();

            if (branch_id == "0" || branch_id == null) { showError('Please Select Branch'); return; }
            if (wareHouse == "0" || wareHouse == null) { showError('Please Select Ware House'); return; }

            var exists = false;
            $('#tblWareHouseDetail input[name=txt_warehouse_id]').each(function () {
                if ($(this).val() == wareHouse) exists = true;
            });
            if (exists) { showError('Ware House already added'); return; }

            appendRow($('#ddlBranch :selected').text(), wareHouse, $('#ddlWareHouse :selected').text());
            $('#ddlBranch').attr('disabled', 'disabled');
            $('#ddlWareHouse').val('0').trigger('change');
        }

        function Delete(row) {
            if (confirm("Are you sure you want to delete?")) {
                $(row).closest('tr').remove();
            }
        }

        function SaveAllRecord() {
            var branchId = $('#ddlBranch').val();
            if (branchId == "0" || branchId == null) { showError('Please Select Branch'); return; }

            var wareHouses = [];
            $('#tblWareHouseDetail input[name=txt_warehouse_id]').each(function () {
                wareHouses.push($(this).val());
            });
            if (wareHouses.length == 0) { showError('Please Add Ware House'); return; }

            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "BranchWiseWareHouse.aspx/SaveRecord",
                data: JSON.stringify({ branchId: parseInt(branchId), isEdit: id != '', wareHouses: wareHouses }),
                success: function (data) {
                    var res = data.d;
                    if (res == "OK") {
                        Swal.fire({ icon: 'success', title: 'Success!', text: 'Data saved successfully', showConfirmButton: false, timer: 1500, customClass: swalClass })
                            .then(function () { window.location.href = "BranchWiseWareHouseList.aspx"; });
                    } else {
                        showError(res);
                    }
                },
                error: function () { showError('An error occurred.'); }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mt-4">
        <div class="row mb-3">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlBranch">Branch</label>
                <select id="ddlBranch" class="form-control"></select>
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlWareHouse">Ware House</label>
                <select id="ddlWareHouse" class="form-control"></select>
            </div>
            <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" onclick="Addrow()" value="+" class="btn btn-primry" style="margin-top: 20px;" />
            </div>
        </div>
    </div>

    <div class="table-container">
        <div class="col-12">
            <table class="table Container" id="tblWareHouse" style="width:45%">
                <thead>
                    <tr>
                        <th class="td_bcolor">Branch</th>
                        <th style="display:none;"></th>
                        <th class="td_bcolor">Ware House</th>
                        <th class="td_bcolor">Actions</th>
                    </tr>
                </thead>
                <tbody id="tblWareHouseDetail"></tbody>
            </table>

            <div class="row mt-3">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-2">
                            <input type="button" class="btn btn-primry" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
                        </div>
                        <div class="col-lg-2">
                            <input type="button" class="btn btn-primry" value="View" onclick="window.location='BranchWiseWareHouseList.aspx'" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
