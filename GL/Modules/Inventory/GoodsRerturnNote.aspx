<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="GoodsRerturnNote.aspx.cs" Inherits="PMS.Modules.Inventory.GoodsRerturnNote" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            GetWareHouseCondition();
            LoadDepartments();
            LoadOrganizations();



            $('#ddlInventoryOrg').change(function () {
                if (warehouseCond == "01") {
                    GetGIN();
                    $("#ddlInventoryOrg").attr('disabled', true);
                }

            });

            $('#btnAdd').on('click', function () {
                debugger;
                var GIN_id = $("#ddlGIN").val();
                LoadGINMaster(GIN_id);
            });
        });
        var departmentid = '';
        var warehouseid = '';
        function LoadGINMaster(GIN_id) {
            debugger
            PageMethods.LoadSINMaster(GIN_id, function (data) {
                debugger
                var parsed_Date = JSON.parse(data);
                departmentid = parsed_Date[0].Department_Id;
                warehouseid = parsed_Date[0].Organization_Id;
                $('#ddlDepartment').val(parsed_Date[0].Department_Id).trigger('change');
                $('#ddlDepartment').attr('disabled', true);
                $('#ddlInventoryOrg').val(parsed_Date[0].Organization_Id).trigger('change');
                $("#ddlInventoryOrg").attr('disabled', true);
                $('#tblMIRItemstModelTable tbody tr').remove();
                LoadGINDetail(GIN_id);
            });
        }
        function LoadGINDetail(GIN_id) {
            debugger
            PageMethods.LoadSINDetail(GIN_id, function (data) {
                debugger
                var parsed_Date = JSON.parse(data);
                var rows = "";
                for (var i = 0; i < parsed_Date.length; i++) {
                    rows =
                        '<tr>' +
                        '<td><input type="hidden" id="SIN_No" name= "SIN_No" value="' + parsed_Date[i].SIN_No+'"/>' + parsed_Date[i].SIN_No + '</td>' +
                        '<td style="display:none;"><input type="hidden" id="item_Id" name= "item_Id" value="' + parsed_Date[i].Item_Id +'"/>' + parsed_Date[i].Item_Id + '</td>' +
                        '<td><input type="hidden" id="Approvedate" name= "Approvedate" value="' + parsed_Date[i].Approvedate +'"/>' + parsed_Date[i].Approvedate + '</td>' +
                        '<td><input type="hidden" id="txtDepartment" name= "txtDepartment" value="' + parsed_Date[i].Department +'"/>' + parsed_Date[i].Department + '</td>' +
                        '<td><input type="hidden" id="Item_code" name= "Item_code" value="' + parsed_Date[i].Item_code +'"/>' + parsed_Date[i].Item_code + '</td>' +
                        '<td><input type="hidden" id="item_Name" name= "item_Name" value="' + parsed_Date[i].Description + '"/>' + parsed_Date[i].Description + '</td>' +
                        '<td><input type="hidden" id="Unit" name= "Unit" value="' + parsed_Date[i].Unit +'"/>' + parsed_Date[i].Unit + '</td>' +
                        '<td><input type="hidden" id="BatchNum" name= "BatchNum" value="' + parsed_Date[i].BatchNum +'"/>' + parsed_Date[i].BatchNum + '</td>' +
                        '<td><input type="hidden" id="SaveTimeStock" name= "SaveTimeStock" value="' + parseFloat(parsed_Date[i].SaveTimeStock).toFixed(2) + '"/>' + parseFloat(parsed_Date[i].SaveTimeStock).toFixed(2) + '</td>' +
                        '<td><input type="hidden" id="Issue_Qty" name= "Issue_Qty" value="' + parseFloat(parsed_Date[i].Issue_Qty).toFixed(2) +'"/>' + parseFloat(parsed_Date[i].Issue_Qty).toFixed(2) + '</td>' +
                        '<td><input type="text" id="Return_Qty" name= "Return_Qty" value="0"/></td>' +
                        '<td><input type="text" id="txtRemarks" name= "" value="txtRemarks"/></td>' +
                        '<td style="padding-top: 9px;padding-top: 6px !important;"> <a href="#" onclick="ExcludeFromPayment(this)">Delete</a></td>' +
                        '</tr>';
                    $('#tblGINItems tbody').append(rows);
                }

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


        var warehouseCond;
        function GetWareHouseCondition() {
            debugger;
            $.ajax({
                type: "POST",
                url: "GoodsRerturnNote.aspx/GetWareHouseCondition",
                data: JSON.stringify({}),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    warehouseCond = JSON.parse(response.d);
                    if (warehouseCond == '01') {

                    }
                    else {
                      
                        GetGIN();
                    }
                },
                error: function (error) {
                    console.error("Error fetching items", error);
                }
            });
        }
        function GetNewSRNNo() {
            PageMethods.GetNewSRNNo(function (resp) {
                $('#txtStoreissueNo').val(resp);
            },
                function (error) {
                    alert(error.get_message());
                })
        }
        function LoadDepartments() {
            PageMethods.LoadDepartments(function (res) {
                var parsed_Date = JSON.parse(res);
                var option = '<option value="0"> Please Select </option>';
                $(parsed_Date).each(function (key, index) {
                    option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                });
                $('#ddlDepartment').html(option);
                $('#ddlDepartment').select2();
                $('#ddlDepartment').addClass('readonly');
            });
        }
        function LoadOrganizations() {
            PageMethods.LoadOrganizations(function (res) {
                var parsed_Date = JSON.parse(res);
                var option = '<option value="0"> Please Select </option>';
                $(parsed_Date).each(function (key, index) {
                    option += '<option value=' + parsed_Date[key].DataValueName + '>' + parsed_Date[key].DataValueDescription + '</option>'
                });
                $('#ddlInventoryOrg').html(option);
                $('#ddlInventoryOrg').select2();
                $('#ddlInventoryOrg').addClass('readonly');
            });
        }

        function GetGIN() {
            debugger;
            var warehouse = $("#ddlInventoryOrg").val();
            if (warehouse == null || warehouse == undefined) {
                warehouse = '0';
            }
            $.ajax({
                type: "POST",
                url: "GoodsRerturnNote.aspx/GetGIN",
                data: JSON.stringify({ warehouse: warehouse }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Date = JSON.parse(response.d);
                    var options = '<option value="0">Select</option>';
                    $(parsed_Date).each(function (key, index) {
                        options += '<option value=' + parsed_Date[key].S_Id + '>' + parsed_Date[key].S_No + '</option>';
                    });
                    $("#ddlGIN").html(options);
                },
                failure: function (response) {
                    alert("In failure method");
                }
            });
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <form id="item">
        <div class="row">
            <input type="hidden" id="hdiemID" />
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label class="">Store issue no</label>
                <input type="text" readonly="readonly" id="txtStoreissueNo" class="form-control" name="txtStoreissueNo" value="New" />
            </div>
                        <div class="col-lg-2 col-md-6 col-sm-12">
                <label>Status</label>
                <input type="text" id="txtStatus" class="form-control" name="txtStatus" readonly="readonly" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label class="">Department</label>
                <select id="ddlDepartment" class="form-control">
                </select>
            </div>
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label class="">Warehouse</label>
                <select id="ddlInventoryOrg"  class="form-control">
                </select>
            </div>
        
            <div class="col-lg-2 col-md-4 col-sm-12">
                <label>GIR#</label>
                <select id="ddlGIN"  class="form-select"></select>
            </div>
            <div class="col-lg-1 col-md-2 col-sm-6">
                <input type="button" value="Add" id="btnAdd" class="btn btn-primry" style="margin-top: 20px;" />
            </div>

            </div>
            <%--            <div class="row">
                            <div class="col-lg-2 col-md-6 col-sm-12">
                <label class="">MR #</label>
                <select id="ddlMRNo" class="form-control">
                </select>
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label class="col-form-label">Attachment</label>
                <input type="file" id="choseGINfile" name="choseGINfile" />
                <asp:HyperLink ID="HyperLink1" runat="server">Download</asp:HyperLink>

            </div>
        </div>--%>
    </form>
    <div class="row">
                        <div style="width: 970px; overflow: scroll; height: 401px  !important; height: auto;">
                    <table class="table table-hover table-striped table-bordered" id="tblGINItems">
                        <thead>
                            <tr>
                                <th>SIN No </th>
                                <th style="display:none;">Item ID</th>
                                <th>GIN App Date</th>
                                <th>Department</th>
                                <th>ItemCode</th>
                                <th>Item Description</th>
                                <th>UOM</th>
                                <th>Batch#</th>
                                <th>Store Stock</th>
                                <th>Issue Qty</th>
                                <th>Return Qty</th>
                                <th>Remarks</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                        </tbody>
                    </table>
                </div>

    </div>
</asp:Content>
