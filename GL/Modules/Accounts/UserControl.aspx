<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserControl.aspx.cs" Inherits="PMS.Account.UserControl" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
       
    </style>

    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            FillUsers();
            fillWareHouse();
            if (id != '') {
                LoadDetail(id);
                $("#btn_Save").val('Update');
                $('#ddl_maintype').attr('disabled', 'disabled');
            }
        });
        function LoadDetail(id) {

            $('#AddAccount').attr('disabled', true);
            var rows = '';
            PageMethods.LoadDetail(id, function (res) {
                var result = JSON.parse(res);
                $.each(result, function (key, value) {
                    setTimeout(function () {
                        $("#ddl_users").val(value.User_id);
                        $('#ddl_users').attr('disabled', 'disabled');
                    }, 2000);
                    if (value.ware_house_id == null || value.ware_house_id == 'null') {
                        value.ware_house_id = "0";
                    }
                    value.Branchnme = 0;
                    if (value.warehouseame == null) {
                        value.warehouseame = "";
                    }
                    rows += '<tr>' +
                        '<td class="th_Sp_Color" style="display:none;">' + value.User_id + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_UserName" id="txt_UserName' + (key + 1) + '" readonly="readonly" value="' + value.user_name + '"  />' +
                        '</td>' +
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Branch_id" id="txt_Branch_id' + (key + 1) + '" value=' + value.Branch_Id + ' />' + value.Branch_Id + '</td>' +
                      
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Warehouse_id" id="txt_Warehouse_id' + (key + 1) + '" value=' + value.ware_house_id + ' />' + value.ware_house_id + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_Warehouse" id="txt_Warehouse' + (key + 1) + '"  value="' + value.warehouseame + '" disabled/>' +
                        ' </td>' +
                        '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
            });
        }
        function FillUsers() {
            var options = '';
            PageMethods.FillUsers(function (result) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.UserId + '" >' + value.UserName + '</option>';
                });
                $('#ddl_users').html(options);
            });
        }
        function fillWareHouse() {
            var options = '';
            PageMethods.FillFilterClinic(function (result) {
          
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlwarehouse').html(options);
            });
        }
        function Addrow() {
            $('#AddAccount').attr('disabled', true);

            var main_type = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();
            var Branchname = $('#ddlBranch :selected').text();
            var branch_id = $('#ddlBranch').val();
            var warehouse_id = $('#ddlwarehouse').val();
            var warehouse_name = $('#ddlwarehouse :selected').text();
            if (warehouse_id == 0) warehouse_name = '';
            if (main_type == 0) {
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
            if (branch_id == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Branch',
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
                    '<td class="th_Sp_Color" style="display:none;">' + main_type + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_UserName" id="txt_UserName' + rowlength + '" readonly="readonly" value="' + username + '"  />' +
                    '</td>' +
                    '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Branch_id" id="txt_Branch_id' + rowlength + '" value=' + branch_id + ' />' + branch_id + '</td>' +
                   
                   
                    '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Warehouse_id" id="txt_Warehouse_id' + rowlength + '" value=' + warehouse_id + ' />' + warehouse_id + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_Warehouse" id="txt_Warehouse' + rowlength + '" value="' + warehouse_name + '" readonly="readonly"/>' +
                    ' </td>' +
                    '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                    '</tr>'
                $('#tblItemDescriptionDetail').append(rows);
                $('#ddl_users').attr('disabled', 'disabled');
            }
        }
        function Delete(row) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
        }
        function validateSave() {
         
            var proceed = true;
            var main_type = $('#ddl_users').val();
            if (main_type == '0')
                $('#ddl_users').addClass('ErrorAlert');
            else
                $('#ddl_users').removeClass('ErrorAlert');
            if (document.getElementById('tblItemDescription').rows.length == 1) {
                proceed = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Add Sub Type Defination',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
         
            return proceed;
        }
        function SaveAllRecord() {
            if (validateSave()) {
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
                    arr = {};
                    arr.userid = $('#ddl_users').val();
                    arr.Branch_id = 0;
                    arr.ware_house = $(value).find('td input[name=txt_Warehouse_id]').val();
                    AllItemDetail.push(arr);
                });
                var userid = $("#ddl_users").val();
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "UserControl.aspx/SaveSegment",
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
                                text: 'Date has been saved successfully',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });

                            window.location.href = "UserControl.aspx";
                        }
                    }, error: function () {
                    }
                });
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div style="margin-left: 30px; margin-bottom: 30px;">

        <div class="row">
             <div class="col-lg-1 col-md-2 col-sm-1"></div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label id="lbluser">User Name</label>
                <select id="ddl_users">
                    <option>Please Select</option>
                </select>

            </div>
            <div class="col-xs-3 col-sm-3 col-lg-2 col-md-3">
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label id="Label1">Filter Clinic</label>
                <select id="ddlwarehouse">
                </select>

            </div>  
            <div class="col-lg-1 col-md-6 col-sm-12">
                <label></label>
                 <input type="button" class="btn-primry" onclick="Addrow()" value="+" id="AddAccount" />

            </div>

        </div>
    </div>

    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-8 col-sm-8 col-lg-8 col-md-8" style="overflow: scroll; height: 223px;">
            <table class="table table-bordered" id="tblItemDescription">

                <thead>
                    <tr>
                        <th style="display: none;"></th>
                        <th style="width: 185px;" class="td_bcolor">Main type Name</th>
                        
                        <th class="td_bcolor">Filter Clinic</th>
                        <th style="width: 62px;" class="td_bcolor">Actions</th>
                    </tr>

                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-2 col-sm-2 col-lg-1 col-md-2"></div>
        <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" class="btn btn-primry" name="btn_Save" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
        </div> 
        <div class="col-lg-1 col-md-4 col-sm-6">
             <input type="button" name="btn_listView" class="btn btn-gray" id="btn_listView" value="View"  onclick="window.location = '/Modules/Accounts/UserControlList.aspx'" />
        </div>  
        <div class="col-lg-1 col-md-4 col-sm-6">
             <input type="button" name="btn_listView"  class="btn btn-yellow" id="btn_new" value="New" onclick="window.location = '/Modules/Accounts/UserControlList.aspx'" />
        </div>  
      
    </div>

           
           
</asp:Content>
