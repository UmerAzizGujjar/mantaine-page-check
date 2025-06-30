<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WareHouseWiseUser.aspx.cs" Inherits="PMS.WareHouseWiseUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            $("#ddl_users").select2();
            $('#ddlWareHouse').select2();
            FillUsers();
            GetWareHouseByUserId();
            if (id != '') {
                LoadDetail(id);
                $("#btn_Save").val('Update');
            }
        });

        function SaveAllRecord() {
            debugger;
            var tableItems = $('#tblItemDescription');
            var btnSave = $('#btn_Save').val();
            var idParam = '';
            var id = '<% =Request.QueryString["ID"] %>';
            if (id == "") {
                idParam = 0;
            }
            else {
                idParam = id;
            }
            var AllItemDetail = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {
                debugger;
                arr = {};
                arr.userid = $('#ddl_users').val();
                arr.WareHouse = $(value).find('td input[name=Warehouse_wise_User_id]').val();
                AllItemDetail.push(arr);
            });
            var userid = $("#ddl_users").val();
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "WareHouseWiseUser.aspx/SaveSegment",
                data: JSON.stringify({
                    "userid": userid,
                    "btnSave": btnSave,
                    "EditId": idParam,
                    "AllItemDetail": AllItemDetail
                }),
                success: function (data) {
                    var id = data.d;
                    if (id == "-1") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'User already Exists',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    } else {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data has been saved successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location.href = "WareHouseWiseUser.aspx";
                    }
                }, error: function () {
                }
            });
        }
        function LoadDetail(id) {
            var rows = '';
            PageMethods.LoadDetail(id, function (res) {
                debugger;
                var result = JSON.parse(res);
                $.each(result, function (key, value) {
                    debugger;
                    setTimeout(function () {
                        debugger;
                        $("#ddl_users").val(value.User_Id);
                        $("#ddl_users").trigger('change');
                        $('#ddl_users').attr('disabled', 'disabled');
                    }, 1000);
                    rows +=
                        '<tr>' +
                        '<td class="th_Sp_Color" style="display:none;">' + value.User_Id + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_UserName" style="width: 100%;" id="txt_UserName' + (key + 1) + '" readonly="readonly" value="' + value.user_name + '"  />' +
                        '</td>' +
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="Warehouse_wise_User_id" id="Warehouse_wise_User_id' + (key + 1) + '" value=' + value.WareHouse + ' />' + value.WareHouse + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + (key + 1) + '" value="' + value.WareHouse_name + '" readonly="readonly"/>' +
                        ' </td>' +
                        '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>'
                });
                $('#tblItemDescriptionDetail').append(rows);
            });
        }

        function FillUsers() {
            debugger;
            var options = '';
            PageMethods.FillUsers(function (result) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.UserId + '" >' + value.UserName + '</option>';
                });
                $('#ddl_users').html(options);
            });
        }
        function GetWareHouseByUserId() {
            debugger;
            var optionsPO = '';
            PageMethods.GetWHByUserId(function (res) {
                debugger;
                var b = JSON.parse(res);
                optionsPO = '<option value="0">Please Select</option>';
                $.each(b, function (key, value) {
                    optionsPO += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                })
                $('#ddlWareHouse').html(optionsPO);
            });
        }
        function Addrow() {
            debugger;
            var user_id = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();
            var WareHouse = $('#ddlWareHouse :selected').text();
            var WareHouse_Id = $('#ddlWareHouse').val();
            if (user_id == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select User',
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
            if (WareHouse_Id == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select WareHouse',
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
            else {
                var rows = '';
                var rowlength = tblItemDescription.rows.length;
                rows += '<tr>' +
                    '<td class="th_Sp_Color" style="display:none;">' + user_id + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_UserName" style="width: 100%;" id="txt_UserName' + rowlength + '" readonly="readonly" value="' + username + '"  />' +
                    '</td>' +
                    '<td class="th_Sp_Color" style="display:none;"><input type="text" name="Warehouse_wise_User_id" id="Warehouse_wise_User_id' + rowlength + '" value=' + WareHouse_Id + ' />' + WareHouse_Id + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + rowlength + '" value="' + WareHouse + '" readonly="readonly"/>' +
                    ' </td>' +
                    '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                    '</tr>'
                $('#tblItemDescriptionDetail').append(rows);
                $('#ddl_users').attr('disabled', 'disabled');
            }
        }
        function Delete(row) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mt-4">
        <div class="row mb-3">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddl_users" id="lbluser">User Name</label>
                <select id="ddl_users" class="form-control"></select>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlWareHouse" id="lblWareHouse">Warehouse</label>
                <select id="ddlWareHouse" class="form-control"></select>
            </div>

            <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" onclick="Addrow()" value="+" id="AddAccount" class="btn-primry" style="margin-top: 20px;" />
            </div>
        </div>
    </div>




    <div class="table-container">
        <div class="col-12">
            <table class="table Container" id="tblItemDescription" style="width: 45%">
                <thead>
                    <tr>
                        <th style="display: none;"></th>
                        <th class="td_bcolor col-md-2 col-lg-2">Username</th>
                        <th class="td_bcolor col-md-2 col-lg-2">WareHouse</th>
                        <th class="td_bcolor col-md-2 col-lg-2">Actions</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>

            <div class="row">
                <div class="col-lg-8">
                    <div class="row">
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" name="btn_Save" id="btn_Save" class="btn btn-primry" value="Save" onclick="SaveAllRecord()" />
                        </div>
                        <div class="col-lg-2 col-md-4 col-sm-6">
                            <input type="button" name="btn_listView" id="btn_listView" class="btn btn-gray" value="List view" onclick="window.location = 'WareHouseWiseUserList.aspx'" />
                        </div>
                    </div>
                </div>



            </div>
        </div>
    </div>

</asp:Content>
