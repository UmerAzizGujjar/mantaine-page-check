<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetSubCategory.aspx.cs" Inherits="PMS.AssetSubCategory" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/CustomCss/AssetCategoryCss.css" rel="stylesheet" />


    <script type="text/javascript">  
        var currentRow = null;
        $(document).ready(function () {
            LoadAssetSubCategoryDetailData();
            FillAssetSubCategory();

            $("#btnAdd").click(function (event) {
                event.preventDefault();
                AppendRow();
            });

            $("#btnSave").click(function (event) {
                event.preventDefault();
                SaveDetailAssetSubCategory();
            });
        });
        function FillAssetSubCategory() {
            debugger
            var optionDepriciation = '';
            PageMethods.fillAssetSubCategories(function (Tests) {
                optionDepriciation = '<option value="0">Please Select</option>';
                $.each(JSON.parse(Tests), function (key, value) {
                    optionDepriciation += '<option value="' + value.Asset_Category_Id + '" >' + value.Asset_Cat_Name + '</option>';
                });
                $('#ddl_AssetCategory').html(optionDepriciation);
            });
        }

        function LoadAssetSubCategoryDetailData() {
            debugger
            $.ajax({
                type: "POST",
                url: "AssetSubCategory.aspx/LoadDetailAssetSubCategories",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parse = JSON.parse(response.d);
                    var row = '';
                    $.each(parse, function (key, value) {
                        var len = key + 1;
                        row += `
                    <tr>
                        <td>${len}</td>
                        <td style="display:none;">${value.Asset_Cat_ID}</td>
                        <td>${value.Asset_Cat_Name}</td>
                        <td>${value.Asset_SubCat_Name}</td>                      
                        <td>${value.Asset_SubCat_Description}</td>                      
                        <td>
                        <a href="#" onclick="editRow(this);" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>
                        <a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="removeRow(this);" ><i class="fa fa-trash"style="color:white !important;"></i></a>
                         </td>
                    </tr>`;
                    });
                    $("#tblDetials tbody").html(row);
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to load asset category details.',
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

        function AppendRow() {
            debugger
            var assetCategoryValue = $('#ddl_AssetCategory').val() || 0;
            var assetCategoryText = $('#ddl_AssetCategory option:selected').text();
            var assetSubCategoryName = $('#txtAssetSubCategoryName').val().trim();
            var assetSubCategoryDescription = $('#txtAssetSubCategoryDescription').val().trim();

            if (assetCategoryValue === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Asset Category is required.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }
            if (assetSubCategoryName === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Asset Sub Category Name is required.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }
            if (assetSubCategoryDescription === "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Asset Sub Category Description is required.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }      
         
            var duplicateFound = false;
            $('#tblDetials tbody tr').each(function () {              
                var existingassetCategory = $(this).find('td:eq(2)').text();
                var existingassetSubCategoryName = $(this).find('td:eq(3)').text();
                var existingassetSubCategoryDescription = $(this).find('td:eq(4)').text();             
              
                if (existingassetCategory === assetCategoryText && existingassetSubCategoryName === assetSubCategoryName && existingassetSubCategoryDescription == assetSubCategoryDescription) {
                    duplicateFound = true;
                    return false;
                }
            });

            if (duplicateFound) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Asset Category with the same Asset Sub Category Description and Name already exists.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }

            if (currentRow) {
                currentRow.find('td:eq(1)').text(assetCategoryText);
                currentRow.find('td:eq(2)').text(assetCategoryValue);
                currentRow.find('td:eq(3)').text(assetSubCategoryName);
                currentRow.find('td:eq(4)').text(assetSubCategoryDescription);
                currentRow = null;
            } else {
                var $tableBody = $('#tblDetials tbody');
                var rowCount = $tableBody.children().length + 1;

                var newRow = `<tr>
                                <td>${rowCount}</td>        
                                <td style="display:none;">${assetCategoryValue}</td>
                                <td>${assetCategoryText}</td>
                                <td>${assetSubCategoryName}</td>                                
                                <td>${assetSubCategoryDescription}</td>
                                <td>
                                    <a href="#" onclick="editRow(this);" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>
                                    <a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="removeRow(this);" ><i class="fa fa-trash"style="color:white !important;"></i></a>
                                </td>
                            </tr>`;
                $tableBody.append(newRow);
            }
            $('#txtAssetSubCategoryName').val('');
            $('#ddl_AssetCategory').val(0).trigger('change');
            $('#txtAssetSubCategoryDescription').val('');
        }


        function editRow(button) {
            debugger
            var $row = $(button).closest('tr');
            var assetCategoryValue = $row.find('td:eq(1)').text();
            var assetCategoryText = $row.find('td:eq(2)').text(); 
            var assetSubCategoryName = $row.find('td:eq(3)').text();
            var assetSubCategoryDescription = $row.find('td:eq(4)').text();
            $('#ddl_AssetCategory').val(assetCategoryValue).trigger('change');
            $('#txtAssetSubCategoryName').val(assetSubCategoryName);
            $('#txtAssetSubCategoryDescription').val(assetSubCategoryDescription);
            currentRow = $row;
        }
        function removeRow(button) {
            $(button).closest('tr').remove();
            updateRowNumbers();
        }

        function updateRowNumbers() {
            $('#tblDetials tbody tr').each(function (index) {
                $(this).find('td:first').text(index + 1);
            });
        }
        function SaveDetailAssetSubCategory() {
            debugger
            var detailAry = [];
            $("#tblDetials tbody tr").each(function (index, row) {
              
              
                var assetCategoryID = $(row).find('td:eq(1)').text();
                var assetCategoryName = $(row).find('td:eq(2)').text();
                var assetSubCategoryName = $(row).find('td:eq(3)').text();
                var assetSubCategoryDescription = $(row).find('td:eq(4)').text();

                if (assetSubCategoryName && assetSubCategoryDescription && assetCategoryID) {
                    var details = {                       
                        Asset_Cat_ID: assetCategoryID,
                        Asset_SubCat_Name: assetSubCategoryName,
                        Asset_SubCat_Description: assetSubCategoryDescription,
                    };
                    detailAry.push(details);
                }
            });
            if (detailAry.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'No valid rows to save.',
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
            $.ajax({
                type: "POST",
                url: "AssetSubCategory.aspx/SaveAssetSubCategoryDetails",
                data: JSON.stringify({
                    'AssetSubCategoryDetails': detailAry
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var res = response.d;
                    if (res.startsWith("Success")) {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Inserted Successfully',
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
                    alert("Error: Failed to save asset category details. " + error);
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="col-lg-12">
        <div class="row">

            <div class="col-lg-4 col-md-6 col-sm-12">
                <label>Asset Category</label>
                <select id="ddl_AssetCategory"></select>
            </div>
            <div class="col-lg-4 col-md-6 col-sm-12">
                <label>Asset Sub Category Name</label>
                <input type="text" id="txtAssetSubCategoryName" />
            </div>
            <div class="col-lg-3 col-md-6 col-sm-12">
                <label>Asset Sub Category Description</label>
                <input type="text" id="txtAssetSubCategoryDescription" />
            </div>
            <div class="col-lg-1 col-md-1 col-sm-1 text-right">
                <button id="btnAdd" class="btn btn-primry btn-xs CustomeAddBtn">
                    <i class="fa fa-plus"></i>
                </button>
            </div>
        </div>
        <br />

        <div class="table-container" style="overflow: scroll; height: 300px;">
            <table class="table table-hover table-striped table-bordered" id="tblDetials">
                <thead id="ihead">
                    <tr>
                        <th>Sr #</th>
                        <th style="display: none">Asset Category Id</th>
                        <th>Asset Category</th>
                        <th>Asset Sub Category Name</th>                       
                        <th>Asset Sub Category Description</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
        <br />
        <div class="row btn-row">
            <div class="col-lg-1 col-md-1 col-sm-1">
                <input type="button" id="btnSave" class="btn btn-primry" value="Save" />
            </div>                   
        </div>
    </div>
</asp:Content>
