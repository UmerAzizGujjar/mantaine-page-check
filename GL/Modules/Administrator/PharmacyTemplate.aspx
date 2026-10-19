<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyTemplate.aspx.cs" Inherits="PMS.GL.PharmacyTemplate" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <link href="../css/stock.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <style type="text/css">
       
    </style>
    <script type="text/javascript">
        var deletedDetailIds = [];

        function FillPharmacyItem() {
            $('#txtPharmacyItem').select2({
                width: '100%',
                dropdownAutoWidth: false,
                placeholder: 'Select Medicine',
                allowClear: true,
                minimumInputLength: 2, // Replaces your custom length check
                ajax: {
                    type: "POST",
                    url: "PharmacyTemplate.aspx/getpharmacyitems",
                    contentType: "application/json; charset=utf-8",
                    dataType: 'json',
                    delay: 250, // Built-in debounce to prevent spamming your database
                    data: function (params) {
                        // Send the typed text to the server
                        return JSON.stringify({ searchString: params.term });
                    },
                    processResults: function (response) {
                        // Map the C# properties to Select2's expected 'id' and 'text'
                        var mappedData = $.map(response.d, function (item) {
                            return {
                                id: item.Item_ID,
                                text: item.Description
                            };
                        });

                        return {
                            results: mappedData
                        };
                    },
                    cache: true
                }
            });
        }

        function AddMedicineRow(itemId, itemName, detailId) {
            var safeId = detailId || 0;
            var row = '<tr data-detail-id="' + safeId + '" data-item-id="' + itemId + '">' +
                '<td>' + itemName + '</td>' +
                '<td><a href="javascript:void(0)" class="btn-remove-item"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                '</td>' +
                '</tr>';
            $('#tblItemDescriptionDetail').append(row);
        }

        function CheckTemplateName() {
            var templateName = $('#txtTemplateName').val().trim();
            var id = $('#txtTemplateID').val();
            if (templateName === '') {
                $('#lblTemplateExists').hide();
                return;
            }
            PageMethods.CheckTemplateNameExists(templateName, id, function (resp) {
                var exists = JSON.parse(resp);
                if (exists) {
                    $('#lblTemplateExists').text('Template Name already exists').show();
                } else {
                    $('#lblTemplateExists').hide();
                }
            });
        }

        $(document).ready(function () {
            FillPharmacyItem();
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                $('#txtTemplateID').val(id);
                LoadMasterData(id);
                Loaddetail(id);
            }
            $('#txtTemplateName').on('blur', function () {
                CheckTemplateName();
            });
            $('#btnAddItem').on('click', function () {
                var itemId = $('#txtPharmacyItem').val();
                var itemName = $('#txtPharmacyItem option:selected').text();
                if (!itemId) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Select Medicine',
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
                var exists = $('#tblItemDescriptionDetail tr[data-item-id="' + itemId + '"]').length > 0;
                if (exists) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Medicine already added',
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
                AddMedicineRow(itemId, itemName, 0);
                $('#txtPharmacyItem').val('').trigger('change');
            });
            $('#tblItemDescriptionDetail').on('click', '.btn-remove-item', function () {
                var row = $(this).closest('tr');
                var detailId = parseInt(row.data('detail-id'), 10);
                if (detailId > 0) {
                    deletedDetailIds.push(detailId);
                }
                row.remove();
            });
            $('#btnNew').on('click', function () {
                window.location.href = "PharmacyTemplate.aspx";
            });
            $('#btnList').on('click', function () {
                window.location.href = "PharmacyTemplateView.aspx";
            });
            $('#btnSave').on('click', function () {
                var id = $('#txtTemplateID').val();
                if (id == "") {
                    id = "";
                }
                var btnValue = $("#btnSave").val();
                var templateName = $("#txtTemplateName").val().trim();
                if (templateName == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Template Name',
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
                if ($('#lblTemplateExists').is(':visible')) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Template Name already exists',
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
                var details = [];
                $('#tblItemDescriptionDetail tr').each(function () {
                    var row = $(this);
                    var detailId = parseInt(row.data('detail-id'), 10) || 0;
                    var itemId = parseInt(row.data('item-id'), 10) || 0;
                    var itemName = row.find('td').eq(0).text().trim();
                    details.push({
                        DetailId: detailId,
                        ItemId: itemId,
                        ItemName: itemName,
                        IsDeleted: false
                    });
                });
                if (details.length === 0) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please add Medicine',
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
                $.each(deletedDetailIds, function (index, detailId) {
                    details.push({
                        DetailId: detailId,
                        ItemId: 0,
                        ItemName: '',
                        IsDeleted: true
                    });
                });
                $.ajax({
                    type: "POST",
                    url: "PharmacyTemplate.aspx/Save",
                    data: JSON.stringify({
                        "btnValue": btnValue,
                        "id": id,
                        "templateName": templateName,
                        "details": details
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;
                        if (data === 'EXISTS') {
                            $('#lblTemplateExists').text('Template Name already exists').show();
                            return;
                        }
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data has been saved successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        window.location.href = "PharmacyTemplate.aspx?ID=" + data;
                    }, error: function () { }
                });
            })
        });
        function LoadMasterData(id) {
            $.ajax({
                type: "POST",
                url: "PharmacyTemplate.aspx/LoadMasterData",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    if (!parsed_Data) {
                        return;
                    }
                    $("#txtTemplateID").val(parsed_Data.ID);
                    $("#txtTemplateName").val(parsed_Data.TemplateName);
                }, error: function () { }
            });
        }
        function Loaddetail(id) {
            PageMethods.LoadDetails(id, function (resp) {
                var data = JSON.parse(resp);
                $.each(data, function (key, value) {
                    AddMedicineRow(value.ItemId, value.ItemName, value.DetailId);
                });
            });
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtTemplateID" name="txtTemplateID" />
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">

            <label for="txtTemplateName">Template Name</label>
            <input type="text" name="txtTemplateName" class="form-control" id="txtTemplateName" placeholder="Enter Template Name" />
            <span id="lblTemplateExists" style="display: none; color: red;"></span>

        </div>
        <div class="col-lg-5 col-md-6 col-sm-12">

            <label for="txtPharmacyItem">Medicine</label>
            <select id="txtPharmacyItem" name="txtPharmacyItem" class="form-control"></select>

        </div>
        <div class="col-lg-2 col-md-3 col-sm-4">
            <label></label>
            <input type="button" id="btnAddItem" class="btn-primry" value="Add" />

        </div>
    </div>

    <div class="row">
        <div class="col-lg-10 col-md-10 col-sm-12">
            <div class="form-group">


                <table class="table table-bordered" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th style="width: 80%;">Medicine</th>
                            <th style="width: 20%">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>

            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" id="btnSave" class="btn btn-primry" value="Save" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">
            <input type="button" id="btnNew" value="New" class="btn btn-yellow" />
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">

            <input type="button" id="btnList" value="List view" class="btn btn-gray" />
        </div>



    </div>
</asp:Content>
