<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DepartmentWiseUser.aspx.cs" Inherits="PMS.DepartmentWiseUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">



    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            FillUsers();
            fillDepartment();
            $('#ddl_users').select2();
            $('#ddlDepartment').select2();
            if (id != '') {
                LoadDetail(id);
                $("#btn_Save").val('Update');
                $('#ddl_maintype').attr('disabled', 'disabled');
            }

        });
        function fillDepartment() {
            var options = '';
            PageMethods.fillDepartment(function (result) {
                options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlDepartment').html(options);
            });
        }
        function validateSave() {
            debugger;
            var table = $('#tblItemDescriptionDetail');
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
                    text: 'Please Add Details',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            }
            if (document.getElementById('tblItemDescription').rows.length > 1) {
                table.find('tr').each(function (key, value) {
                    var dept = $(value).find('td input[name=txt_deptwisedoc_id]').val();

                    if (dept == "" || dept == 0) {
                        proceed = false;
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please add Department',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                });
            }
            return proceed;
        }
        function LoadDetail(id) {
            debugger
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
                        '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_deptwisedoc_id" id="txt_deptwisedoc_id' + (key + 1) + '" value=' + value.Department + ' />' + value.Department + '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + (key + 1) + '" value="' + value.Department_name + '" readonly="readonly"/>' +
                        ' </td>' +
                        '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>'

                });

                $('#tblItemDescriptionDetail').append(rows);
            });
        }
        function Delete(row) {
            debugger;
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
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
                    arr.dept = $(value).find('td input[name=txt_deptwisedoc_id]').val();
                    AllItemDetail.push(arr);
                });
                var userid = $("#ddl_users").val();
                $.ajax({
                    type: "POST",
                    contentType: "application/json; charset=utf-8",
                    url: "DepartmentWiseUser.aspx/SaveSegment",
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

                            window.location.href = "DepartmentWiseUser.aspx";
                        }
                    }, error: function () {
                    }
                });
            }
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
        function Addrow() {
            debugger;
            var user_id = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();
            var Department = $('#ddlDepartment :selected').text();
            var Department_id = $('#ddlDepartment').val();
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
            if (Department_id == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Department',
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

            var exists = false;
            $('#tblItemDescriptionDetail tr').each(function () {
                var existingDept = $(this).find('td input[name=txt_deptwisedoc_id]').val();
                if (existingDept == Department_id) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'This department is already added for this user',
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

            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows += '<tr>' +
                '<td class="th_Sp_Color" style="display:none;">' + user_id + '</td>' +
                '<td class="th_Sp_Color">' +
                '<input type="text" name="txt_UserName" style="width: 100%;" id="txt_UserName' + rowlength + '" readonly="readonly" value="' + username + '"  />' +
                '</td>' +
                '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_deptwisedoc_id" id="txt_deptwisedoc_id' + rowlength + '" value=' + Department_id + ' />' + Department_id + '</td>' +
                '<td class="th_Sp_Color">' +
                '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + rowlength + '" value="' + Department + '" readonly="readonly"/>' +
                '  </td>' +
                '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                '</tr>'
            $('#tblItemDescriptionDetail').append(rows);
            $('#ddl_users').attr('disabled', 'disabled');
        }

        function AddAllDepartments() {
            debugger;
            var user_id = $('#ddl_users').val();
            var username = $('#ddl_users :selected').text();

            if (user_id == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select User First',
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

            var allDepartments = [];
            $('#ddlDepartment option').each(function () {
                var deptId = $(this).val();
                var deptName = $(this).text();
                if (deptId != '0') {
                    allDepartments.push({ id: deptId, name: deptName });
                }
            });

            if (allDepartments.length == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'No Departments Available',
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
            $('#tblItemDescriptionDetail').empty();
            var rows = '';

            $.each(allDepartments, function (key, dept) {
                rows += '<tr>' +
                    '<td class="th_Sp_Color" style="display:none;">' + user_id + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_UserName" style="width: 100%;" id="txt_UserName' + (key + 1) + '" readonly="readonly" value="' + username + '"  />' +
                    '</td>' +
                    '<td class="th_Sp_Color" style="display:none;"><input type="text" name="txt_deptwisedoc_id" id="txt_deptwisedoc_id' + (key + 1) + '" value="' + dept.id + '" />' + dept.id + '</td>' +
                    '<td class="th_Sp_Color">' +
                    '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + (key + 1) + '" value="' + dept.name + '" readonly="readonly"/>' +
                    '  </td>' +
                    '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px;  margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                    '</tr>';
            });

            $('#tblItemDescriptionDetail').append(rows);
            $('#ddl_users').attr('disabled', 'disabled');

            Swal.fire({
                icon: 'success',
                title: 'Success!',
                text: 'All departments have been added successfully',
                showConfirmButton: false,
                timer: 2000,
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   <div class="mt-4">
    <div class="row mb-3">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="ddl_users" id="lbluser">User Name</label>
            <select id="ddl_users"  class="form-control"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <label for="ddlDepartment" id="lblDepartment">Department</label>
            <select id="ddlDepartment"  class="form-control"></select>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" onclick="Addrow()" value="+" id="AddAccount" class="btn-primry" style="margin-top: 20px;" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" onclick="AddAllDepartments()" value="All Dept" id="btnAllDepartment" class="btn-primry" style="margin-top: 20px;" />
        </div>
    </div>
</div>



    <div class="table-container">
        <div class="col-12">
            <table class="table Container" id="tblItemDescription" style ="width:45%">
                <thead>
                    <tr>
                        <th style="display: none;"></th>
                        <th class="td_bcolor col-md-2 col-lg-2">Username</th>
                        <th class="td_bcolor col-md-2 col-lg-2" >Department</th>
                        <th class="td_bcolor col-md-2 col-lg-1">Actions</th>
                    </tr>
                </thead>
                <tbody id="tblItemDescriptionDetail">
                </tbody>
            </table>



            <div class="row">
                 <div class="col-lg-8">
            <div class="row">
                     <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" name="btn_Save" id="btn_Save" value="Save" onclick="SaveAllRecord()" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" name="btn_listView" class="btn btn-gray" id="btn_listView" value="View" onclick="window.location = 'DepartmentWiseUserList.aspx'" />
                </div>
            </div>
        </div>


           
            </div>
        </div>
    </div>

</asp:Content>
