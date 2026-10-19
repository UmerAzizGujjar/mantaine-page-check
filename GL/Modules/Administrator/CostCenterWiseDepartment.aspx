<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="CostCenterWiseDepartment.aspx.cs" Inherits="PMS.CostCenterWiseDepartment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            $('#ddlCostCenter').select2();
            $('#ddlDepartment').select2();
            FillCostCenter();
            fillDepartment();
            if (id != '') {
                LoadDetail(id);
                $("#btn_Save").val('Update');
                $('#ddlCostCenter').attr('disabled', 'disabled');
            }
        });

        function FillCostCenter() {
            PageMethods.FillCostCenter(function (result) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlCostCenter').html(options);
            });
        }
        function fillDepartment() {
            PageMethods.fillDepartment(function (result) {
                var options = '<option value="0">Please Select</option>';
                $.each(JSON.parse(result), function (key, value) {
                    options += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddlDepartment').html(options);
            });
        }
        function LoadDetail(id) {
            var rows = '';
            PageMethods.LoadDetail(id, function (res) {
                var result = JSON.parse(res);
                $.each(result, function (key, value) {
                    setTimeout(function () {
                        $("#ddlCostCenter").val(value.CostCenter);
                        $("#ddlCostCenter").trigger('change');
                        $('#ddlCostCenter').attr('disabled', 'disabled');
                    }, 1000);
                    rows +=
                        '<tr>' +
                        '<td class="th_Sp_Color" style="display:none;">' + value.CostCenter + '</td>' +
                        '<td class="th_Sp_Color" style="display:none;">' +
                        '<input type="text" name="txt_dept_id" id="txt_dept_id' + (key + 1) + '" value="' + value.Department + '" />' + value.Department +
                        '</td>' +
                        '<td class="th_Sp_Color">' +
                        '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + (key + 1) + '" value="' + value.Department_name + '" readonly="readonly" />' +
                        ' </td>' +
                        '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px; margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                        '</tr>'
                });
                $('#tblItemDescriptionDetail').append(rows);
            });
        }
        function Delete(row) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                $(row).closest('tr').remove();
            }
        }
        function Addrow() {
            var costCenter = $('#ddlCostCenter').val();
            var department_id = $('#ddlDepartment').val();
            var department = $('#ddlDepartment :selected').text();
            if (costCenter == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Cost Center',
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
            if (department_id == 0) {
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
                var existingDept = $(this).find('td input[name=txt_dept_id]').val();
                if (existingDept == department_id) {
                    exists = true;
                    return false;
                }
            });

            if (exists) {
                Swal.fire({
                    icon: 'warning',
                    title: 'Warning!',
                    text: 'This department is already added',
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
                '<td class="th_Sp_Color" style="display:none;">' + costCenter + '</td>' +
                '<td class="th_Sp_Color" style="display:none;">' +
                '<input type="text" name="txt_dept_id" id="txt_dept_id' + rowlength + '" value="' + department_id + '" />' + department_id +
                '</td>' +
                '<td class="th_Sp_Color">' +
                '<input type="text" name="txt_dept" style="width: 100%;" id="txt_dept' + rowlength + '" value="' + department + '" readonly="readonly" />' +
                ' </td>' +
                '<td><a href="#" onclick="Delete(this)"><i class="glyphicon glyphicon-trash" style="font-size: 13px; margin-top: 5px; margin-left: 16px; color: #f30a0a;"></i></a></td>' +
                '</tr>'
            $('#tblItemDescriptionDetail').append(rows);
            $('#ddlCostCenter').attr('disabled', 'disabled');
        }
        function SaveAllRecord() {
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

            if ($('#ddlCostCenter').val() == 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Select Cost Center',
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

            if (document.getElementById('tblItemDescription').rows.length == 1) {
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
                return false;
            }

            var AllItemDetail = [];
            tableItems.find('tr:gt(0)').each(function (key, value) {
                var arr = {};
                arr.costcenter = $('#ddlCostCenter').val();
                arr.department = $(value).find('td input[name=txt_dept_id]').val();
                AllItemDetail.push(arr);
            });

            var costcenter = $("#ddlCostCenter").val();
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "CostCenterWiseDepartment.aspx/SaveSegment",
                data: JSON.stringify({
                    "costcenter": costcenter,
                    "btnSave": btnSave,
                    "EditId": idParam,
                    "AllItemDetail": AllItemDetail
                }),
                success: function (data) {
                    var resId = data.d;
                    if (resId == "-1") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Cost Center already Exists',
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

                        window.location.href = "CostCenterWiseDepartment.aspx";
                    }
                }, error: function () {
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="mt-4">
        <div class="row mb-3">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlCostCenter" id="lblCostCenter">Cost Center</label>
                <select id="ddlCostCenter" class="form-control"></select>
            </div>

            <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlDepartment" id="lblDepartment">Department</label>
                <select id="ddlDepartment" class="form-control"></select>
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
                        <th class="td_bcolor col-md-2 col-lg-2">Department</th>
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
                            <input type="button" name="btn_listView" id="btn_listView" class="btn btn-gray" value="List view" onclick="window.location = 'CostCenterWiseDepartmentList.aspx'" />
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
