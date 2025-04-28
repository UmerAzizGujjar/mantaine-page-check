<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserDoctorControl.aspx.cs" Inherits="PMS.Account.UserDoctorControl" %>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        th {
            background-image: linear-gradient(to bottom, #f8f8f8 0, #6EA3CC 100%);
            background-color: #F2F2F2;
            position: sticky;
            top: 0; /* Don't forget this, required for the stickiness */
            box-shadow: 0 2px 2px -1px rgba(0, 0, 0, 0.4);
        }
        select{
           border-radius:5px !important;
        }
    </style>

    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            FillUsers();
            filldoctors();
            if (id != '') {
                LoadDetail(id);
                $("#btn_Save").val('Update');
                $('#ddl_maintype').attr('disabled', 'disabled');
            }
        });
        function LoadDetail(id) {

            $('#AddAccount').attr('disabled', true);
            var rows = '';
            PageMethods.LoadDetails(id, function (res) {
                debugger;
                var result = JSON.parse(res);
                $.each(result, function (key, value) {
                    debugger;
                    setTimeout(function () {
                        $("#ddl_users").val(value.User_id);
                        $('#ddl_users').attr('disabled', 'disabled');
                    }, 2000);
                    if (value.ware_house_id == null || value.ware_house_id == 'null') {
                        value.ware_house_id = "0";
                    }
                    value.Branchnme = 0;
                    if (value.warehouse_name == null) {
                        value.warehouse_name = "";
                    }
                    rows += '<tr>' +
                        '<td class="th_Sp_Color" style="display:none;">' + value.User_id + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_UserName" id="txt_UserName' + (key + 1) + '" readonly="readonly" value="' + value.user_name + '"  />' +
                        '</td>' +
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Branch_id" id="txt_Branch_id' + (key + 1) + '" value=' + value.Branch_Id + ' />' + value.Branch_Id + '</td>' +
                      
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_Warehouse_id" id="txt_Warehouse_id' + (key + 1) + '" value=' + value.ware_house_id + ' />' + value.ware_house_id + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_Warehouse" id="txt_Warehouse' + (key + 1) + '"  value="' + value.warehouse_name + '" disabled/>' +
                        ' </td>' +
                        '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>';
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
        function filldoctors() {
            var options = '';
            PageMethods.filldoctor(function (result) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ddlwarehouse').html(options);
            });
        }
        function Addrow() {
            $('#AddAccount').attr('disabled', true);

            debugger;
            var main_type = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();
            var Branchname = $('#ddlBranch :selected').text();
            var branch_id = $('#ddlBranch').val();
            var warehouse_id = $('#ddlwarehouse').val();
            var warehouse_name = $('#ddlwarehouse :selected').text();
            if (warehouse_id == 0) warehouse_name = '';
            if (main_type == 0) {
                alert("Please Select User ");
                return false;
            }
            if (branch_id == 0) {
                alert("Please Select Branch ");
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
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
        }
        function validateSave() {
            debugger;
            // var table = $('#tblItemDescriptionDetail');
            var proceed = true;
            var main_type = $('#ddl_users').val();
            if (main_type == '0')
                $('#ddl_users').addClass('ErrorAlert');
            else
                $('#ddl_users').removeClass('ErrorAlert');
            if (document.getElementById('tblItemDescription').rows.length == 1) {
                proceed = false;
                alert('Please Add Sub Type Defination.');
            }
            //if (document.getElementById('tblItemDescription').rows.length > 1) {
            //    table.find('tr').each(function (key, value) {
            //        var Desc = $(value).find('td input[name=txt_Branch]').val();
            //        var branchid = $(value).find('td input[name=txt_Branch_id]').val();
            //        if (branchid == "" || branchid == 0) {
            //            proceed = false;
            //            alert("Please add Branch");
            //        }
            //    });
            //}
            return proceed;
        }
        function SaveAllRecord() {
            if (validateSave()) {
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
                    arr.Branch_id = 0;
                    arr.ware_house = $(value).find('td input[name=txt_Warehouse_id]').val();
                    AllItemDetail.push(arr);
                });
                var userid = $("#ddl_users").val();
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "UserDoctorControl.aspx/SaveSegments",
                    data: JSON.stringify({
                        "userid": userid,
                        "btnSave": btnSave,
                        "EditId": idParam,
                        "AllItemDetail": AllItemDetail
                    }),
                    success: function (data) {
                        var id = data.d;
                        if (id == "-1") {
                            alert("User already Exists");
                        } else {
                            alert("Date has been saved successfully");
                            window.location.href = "UserDoctorControl.aspx";
                        }
                    }, error: function () {
                    }
                });
            }
        }
    </script>

</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

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
                <label id="Label1">Doctor</label>
                <select id="ddlwarehouse">
                </select>

            </div>

        </div>
    </div>
    <div class="row">
        <div class="col-md-9">
            <input type="button" onclick="Addrow()" value="+" id="AddAccount" style="width: 44px; float: right;" />
        </div>

    </div>
    <div class="row">
        <div class="col-xs-1 col-sm-1 col-lg-1 col-md-1"></div>
        <div class="col-xs-8 col-sm-8 col-lg-8 col-md-8" style="overflow: scroll; height: 223px;">
            <table class="table table-bordered" id="tblItemDescription">

                <thead>
                    <tr>
                        <th style="display: none;"></th>
                        <th style="width: 185px;" class="td_bcolor">User Name</th>
                        
                        <th class="td_bcolor">Doctor</th>
                        <th style="width: 62px;" class="td_bcolor">Actions</th>
                    </tr>

                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>
        </div>
    </div>
    <div class="row">
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2"></div>
        <div class="col-xs-10 col-sm-10 col-lg-10 col-md-10">
            <input type="button" name="btn_Save" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
            <input type="button" name="btn_listView" id="btn_listView" value="List view" style="margin-left: 10PX;" onclick="window.location = 'UserDoctorControlList.aspx'" />
            <input type="button" name="btn_listView" id="btn_new" value="New" style="margin-left: 10PX;" onclick="window.location = 'UserDoctorControl.aspx'" />
        </div>
        <div class="col-xs-2 col-sm-2 col-lg-2 col-md-2"></div>
    </div>

</asp:Content>