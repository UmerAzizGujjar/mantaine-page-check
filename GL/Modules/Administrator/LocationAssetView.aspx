<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LocationAssetView.aspx.cs" Inherits="PMS.LocationAssetView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <style type="text/css">
        .btn-white-text{
            color:white !important;
        }

    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            debugger
            LoadPage();

            $("#btnSave").click(function (event) {
                event.preventDefault();
                SaveLocation();
            });

        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }


        function Edit(Location_ID, Location_Code, Location_Description) {
            $("#txtLocation_No").val(Location_ID);
            $("#txtLocation_Code").val(Location_Code);
            $("#txtLocation_Description").val(Location_Description);

            $("#btnSave").val("Update");
            $('#addNewModal').modal('show');
        }


       


        //function Edit(ID) {
        //    window.location.href = "LocationAsset.aspx?ID=" + ID;
        //}
        //function redirecttonew() {
        //    window.location.href = "LocationAsset.aspx";
        //}
        function LoadPage() {
            debugger
            $("#example").DataTable({
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
                        url: "LocationAssetView.aspx/ViewList",
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
                    });
                },
                "columns": [
                    { "data": "Location_ID", "visible": false, "width": "0%" },
                    { "data": "Location_Code", "width": "20%" },
                    { "data": "Location_Description", "width": "50%" },
                    {
                        "render": function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Location_ID + ', \'' + full.Location_Code + '\', \'' + full.Location_Description + '\')" style="border-radius: 4px;margin-right: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Location_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result;
                            result = res + print;
                            return result;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');
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
        function SaveLocation() {
            debugger;
            if (isSaving) return;
            isSaving = true;

            var Location_ID = $('#txtLocation_No').val();
            var Location_Code = $('#txtLocation_Code').val();
            var Location_Description = $('#txtLocation_Description').val();
            var btnValue = $("#btnSave").val(); 

            if (!Location_Code) {
                alert("Please Enter Location Code.");
                isSaving = false;
                return false;
            }

            Location_ID = Location_ID ? Location_ID : "0";

            $.ajax({
                type: "POST",
                url: "LocationAssetView.aspx/Savelocation",
                data: JSON.stringify({
                    "Location_ID": Location_ID,
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
                        var message = (btnValue === "Update") ? "Data updated successfully" : "Data saved successfully";
                        alert(message);
                        window.location.reload();
                    } else {
                        alert("Error: " + res);
                    }
                },
                error: function (xhr, status, error) {
                    alert("Error: Failed to Save Location. " + error);
                },
                complete: function () {
                    isSaving = false;
                }
            });
        }






    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <br />
    <div class="table-container">
        <table class="table  table-hover table-bordered" id="example">
            <thead>
                <tr>
                    <th style="display: none;">Location ID</th>
                    <th>Location Code</th>
                    <th>Location Description</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>


    <div class="modal fade" id="addNewModal" tabindex="-1" role="dialog" aria-labelledby="addNewModalLabel" aria-hidden="true">
        <div class="modal-dialog" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h3 class="modal-title" id="addNewModalLabel">Add New Location</h3>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <input type="hidden" id="txtLocation_No" />
                    <!-- Add your form elements here -->
                    <form id="addNewForm">
                        <div class="row">
                            <div class="form-group col-lg-12 col-md-12 col-sm-12">
                                <label for="locationCode">Location Code</label>
                                <input type="text" class="form-control" style="width:100% !important" id="txtLocation_Code" placeholder="Enter Location Code" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="form-group col-lg-12 col-md-12 col-sm-12">
                                <label for="locationDescription">Location Description</label>
                                <textarea class="form-control" id="txtLocation_Description" placeholder="Enter Description"></textarea>
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer">
                    <input type="button" id="btnBack" class="btn-primry" data-dismiss="modal" value="Close" />
                    <input type="button" id="btnSave" onclick=" SaveLocation()" class="btn-primry" value="Save" />
                </div>
            </div>
        </div>
    </div>
</asp:Content>
