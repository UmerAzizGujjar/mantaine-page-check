<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LocationAsset.aspx.cs" Inherits="PMS.LocationAsset" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style>
    label {
        font-size: 1rem;
    }
    .btn-row {
        margin-top: 20px;
    }
    
</style>
    <script>
        var id = '<% =Request.QueryString["ID"] %>';
        $(document).ready(function () {
            debugger
            $("#btnSave").click(function (event) {
                event.preventDefault();
                SaveLocation();
            });
            $("#btnBack").click(function () {
                window.location.href = "LocationAssetView.aspx";
            });
            if (id != "") {
                Loadlocation(id);
                $("#btnSave").val('Update');
            }
            else {
                GetLocationNo();
            }
        });
        function GetLocationNo() {
            debugger
            $.ajax({
                type: "post",
                url: "LocationAsset.aspx/GetLocationNo",
                data: '',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger
                    var id = response.d;
                    $("#txtLocation_No").val(id);
                },
                failure: function (response) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
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
        function SaveLocation() {
            debugger;
            var Location_No = $('#txtLocation_No').val();
            var Location_Code = $('#txtLocation_Code').val();
            var Location_Description = $('#txtLocation_Description').val();
            var btnValue = $("#btnSave").val();
            if (!Location_Code) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Location Code.',
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
                url: "LocationAsset.aspx/Savelocation",
                data: JSON.stringify({
                    "Location_No": Location_No,
                    "Location_Code": Location_Code,
                    "Location_Description": Location_Description,
                    "btnValue": btnValue
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
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
                    alert("Error: Failed to Save Location. " + error);
                }
            });
        }
        function Loadlocation(id) {
            debugger;
            $.ajax({
                type: "POST",
                url: "LocationAsset.aspx/Loadlocation",
                data: JSON.stringify({
                    "ID": id,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var parse = JSON.parse(response.d);
                    $('#txtLocation_No').val(parse.Location_No);
                    $('#txtLocation_Code').val(parse.Location_Code);
                    $('#txtLocation_Description').val(parse.Location_Description);
                },
                failure: function (response) {

                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'In failure method',
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
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class=" p-1">
        <div class="row mb-3">
            <div class="col-lg-1 col-md-1 col-sm-1">
                <label class="font-weight-bold">Location #</label>
                <input type="text" id="txtLocation_No" class="form-control" readonly="readonly" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-2">
                <label class="font-weight-bold">Location Code <span class="text-danger">*</span></label>
                <input type="text" id="txtLocation_Code" class="form-control" />
            </div>
            <div class="col-lg-8 col-md-8 col-sm-8">
                <label class="font-weight-bold">Description</label>
                <input type="text" id="txtLocation_Description" class="form-control" />
            </div>
        </div>

        <div class="row justify-content-start mt-5">
            <div class="col-lg-1 col-md-1 col-sm-1">
                <input type="button" id="btnSave" class="btn-primry" value="Save" />
            </div>
            <div class="col-lg-1 col-md-1 col-sm-1">
                <input type="button" id="btnBack" class="btn-primry" value="List" />
            </div>
        </div>
    </div>    
    </asp:Content>
