<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetCategory.aspx.cs" Inherits="PMS.AssetCategory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/CustomCss/AssetCategoryCss.css" rel="stylesheet" />
    <link href="../../wwwroot/Pakred/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">  
        $(document).ready(function () {
            debugger
            LoadPage();
            FillDepreciationMethod();

            $("#btnSave").click(function (event) {
                event.preventDefault();
                SaveAsset();
            });
        });
        var currentRow = null;
        function FillDepreciationMethod() {
            debugger
            var optionDepriciation = '';
            PageMethods.filldepreciationMethods(function (Tests) {
                optionDepriciation = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionDepriciation += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_Depreciation_Method').html(optionDepriciation);
            });
        }

        function EditAsset(Asset_Category_Id, Asset_Cat_Name, Depreciation_Method_Name, Depreciation_Percentage) {
            $("#txtAsset_Category_Id").val(Asset_Category_Id);
            $("#txtAsset_Cat_Name").val(Asset_Cat_Name);
            $("#txtDepreciation_Per").val(Depreciation_Percentage);

            $("#ddl_Depreciation_Method option").filter(function () {
                return $(this).text() === Depreciation_Method_Name;
            }).prop("selected", true);

            $("#btnSave").val("Update");
            $('#addNewModal').modal('show');
        }



        function LoadPage() {
            debugger
            $("#tblDetials").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add New',
                        className: 'btn-primry btn-white-text',
                        action: function (e, dt, node, config) {
                            $('#addNewModal').modal('show');
                        }
                    },
                    'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AssetCategory.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                        }
                    }); debugger
                },
                "columns": [
                    { "data": "Asset_Category_Id", "visible": false, "width": "0%" },
                    { "data": "Asset_Cat_Name", "width": "40%" },
                    { "data": "Depreciation_Method_Name", "width": "40%" },
                    { "data": "Depreciation_Percentage", "width": "40%" },
                    {
                        "render": function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="EditAsset(' + full.Asset_Category_Id + ', \'' + full.Asset_Cat_Name + '\', \'' + full.Depreciation_Method_Name + '\', ' + full.Depreciation_Percentage + ')" style="border-radius: 4px;margin-right: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';

                            var result;
                            result = res;
                            return result;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#tblDetials_length select');
                    var label = document.querySelector('#tblDetials_length label');
                    if (lengthDropdown && label) {
                        label.innerHTML = 'Show entries ';
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown or label not found");
                    }
                }
            });
        }



        let isSaving = false;
        function SaveAsset() {
            console.log("SaveAsset function triggered");
            if (isSaving) return;
            isSaving = true;

            var Asset_Category_Id = $('#txtAsset_Category_Id').val();
            var Asset_Cat_Name = $('#txtAsset_Cat_Name').val();
            var Depreciation_Method_Id = $('#ddl_Depreciation_Method').val();
            var Depreciation_Method_Name = $('#ddl_Depreciation_Method option:selected').text(); 
            var Depreciation_Percentage = parseInt($('#txtDepreciation_Per').val(), 10) || 0;
            var btnValue = $("#btnSave").val();

            if (!Asset_Cat_Name) {
                
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter Asset Category Name.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                
                isSaving = false;
                return false;
            }

            $.ajax({
                type: "POST",
                url: "AssetCategory.aspx/SaveAsset",
                data: JSON.stringify({
                    "Asset_Category_Id": Asset_Category_Id,
                    "Asset_Cat_Name": Asset_Cat_Name,
                    "Depreciation_Method_Id": Depreciation_Method_Id,
                    "Depreciation_Method_Name": Depreciation_Method_Name,
                    "Depreciation_Percentage": Depreciation_Percentage,
                    "btnValue": btnValue
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    console.log("Response received:", response);
                    var res = response.d;
                    if (res.startsWith("Success")) {
                        var message = (btnValue === "Update") ? "Data updated successfully" : "Data saved successfully";
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: message,
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        window.location.reload();
                    } else {
                        alert("Error: " + res);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("AJAX error: ", xhr, status, error);
                   
                    alert("Error: Failed to Save Asset. " + error);
                },
                complete: function () {
                    isSaving = false;
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="col-lg-12">

        <div class="table-container" style="overflow: scroll; height: 500px;">
            <table class="table  table-hover table-bordered" id="tblDetials" style="width:100% !important">
                <thead id="ihead">
                    <tr>
                        <th>Asset Category ID</th>
                        <th>Asset Category Name</th>
                        <th>Depreciation Method</th>
                        <th style="display: none">Depreciation Method Id</th>
                        <th>Depreciation Percentage</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
        <br />
        <div class="modal" id="addNewModal" tabindex="-1" role="dialog" aria-labelledby="addNewModalLabel" aria-hidden="true">
            <div class="modal-dialog" role="document">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addNewModalLabel">Add New Asset Category</h5>
                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                            <span aria-hidden="true">&times;</span>
                        </button>
                    </div>
                    <div class="modal-body">
                        <div class="row">
                            <input type="hidden" id="txtAsset_Category_Id"  />
                        <div class="form-group col-lg-12 col-md-12 col-sm-12">
                            <label for="txtAsset_Cat_Name">Asset Category Name</label>
                            <input type="text" class="form-control" style="width:100% !important" id="txtAsset_Cat_Name" />
                        </div>
                            <div class="form-group col-lg-12 col-md-12 col-sm-12">
                                <label for="ddl_Depreciation_Method">Depreciation Method</label>
                                <select id="ddl_Depreciation_Method" style="width: 100% !important" class="form-control"></select>
                            </div>
                            <div class="form-group col-lg-12 col-md-12 col-sm-12">
                                <label for="txtDepreciation_Per">Depreciation Percentage</label>
                                <input type="text" class="form-control" style="width: 100% !important" id="txtDepreciation_Per" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <input type="button" id="btnBack" class="btn-primry" data-dismiss="modal" value="Close" />
                        <input type="button" id="btnSave" onclick="SaveAsset()" class="btn-primry" value="Save" />
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
