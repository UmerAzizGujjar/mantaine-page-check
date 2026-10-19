<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Department_Packages_List.aspx.cs" Inherits="PMS.Modules.Inventory.Department_Packages_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

         <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">
    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });
    function PrintTest(id) {
        window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
    }
    function LoadPage() {
        let savedVisibility = null;

        $.ajax({
            type: "POST",
            url: "Department_Packages_List.aspx/GetUserColumnPreferences",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (response) {
                if (response.d && response.d !== "") {
                    try {
                        savedVisibility = JSON.parse(response.d);
                    } catch (e) {
                        console.warn("Invalid column visibility JSON");
                    }
                }
            },
            error: function () {
                console.error("Failed to load column preferences");
            }
        });
        $("#example").DataTable({
            "processing": true,
            "serverSide": true,
            "dom": 'lBfrtip',
            "lengthChange": true,
            "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddDepartment_Packages.aspx'; } }, 'copy', 'excel', 'pdf',
                {
                    extend: 'colvis',
                    text: '<i class="fa fa-columns"></i> Columns',
                    className: 'dt-button buttons-colvis',
                    collectionLayout: 'fixed two-column',
                    postfixButtons: ['colvisRestore']
                }
            ],
            "filter": true,
            "ajax": function (data, callback, settings) {
                $.ajax({
                    type: "POST",
                    url: "Department_Packages_List.aspx/ViewList",
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
                { "data": "Package_ID", "name": "Package_ID", "orderable": true },
                { "data": "Package_name", "name": "Package_name", "orderable": true },
                { "data": "Department", "name": "Companyname" , "orderable": false },                
                { "data": "Duration", "orderable": false },
                { "data": "Remarks", "orderable": false },                
                {
                    render: function (data, type, full) {
                        var res = '<a href="#" onclick="editOpen(' + full.Package_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'
                        var del = '<a href="#" onclick="delete_package(' + full.Package_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-trash"></i></a>'

                        var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Package_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';

                        var result;
                        result = res  + print;
                        return result;
                    }, "orderable": false
                }
            ],
            "initComplete": function (settings, json) {
                const api = this.api();
                if (savedVisibility && Array.isArray(savedVisibility)) {
                    if (savedVisibility.length === api.columns().count()) {
                        api.columns().every(function (index) {
                            this.visible(savedVisibility[index]);
                        });
                    }
                }
                api.on('column-visibility.dt', function (e, settings, column, state) {
                    let currentVis = [];
                    api.columns().every(function () {
                        currentVis.push(this.visible());
                    });
                    PageMethods.SaveUserColumnPreferences(
                        JSON.stringify(currentVis),
                        function () {
                            console.log("Column preferences saved");
                        },
                        function (error) {
                            console.error("Failed to save preferences:", error);
                        }
                    );
                });

                var lengthContainer = document.querySelector('#example_length');
                var lengthDropdown = document.querySelector('#example_length select');
                var label = document.querySelector('#example_length label');

                if (lengthDropdown && label && lengthContainer) {
                    var labelText = document.createElement('span');
                    labelText.textContent = 'Show entries ';
                    labelText.style.marginTop = '10px';
                    labelText.style.display = 'inline-block';

                    lengthDropdown.style.width = '60px';
                    label.innerHTML = '';
                    label.style.display = 'inline-flex';
                    label.style.marginTop = '17px';
                    label.appendChild(labelText);
                    label.appendChild(lengthDropdown);
                }
            }
        });
    }
    function editOpen(id) {
        window.open("AddDepartment_Packages.aspx?Dep_Package_id=" + id + "");
    }
    function delete_package(id) {
        Swal.fire({
            icon: 'warning',
            title: 'Are you sure?',
            text: 'This action will delete the Package!',
            showCancelButton: true,
            confirmButtonColor: '#d33',
            cancelButtonColor: '#3085d6',
            confirmButtonText: 'Yes, delete it!',
            cancelButtonText: 'Cancel',
            customClass: {
                popup: 'swal-big-popup',
                title: 'swal-big-title',
                htmlContainer: 'swal-big-text'
            }
        }).then((result) => {
            $.ajax({
                type: "POST",
                url: "Department_Packages_List.aspx/DeletePackage",
                data: JSON.stringify({ Package_ID: id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d == "Package cancelled successfully.") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Your Package has been Deleted successfully.',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        }); LoadPage();
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error Deleting Package',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.log(xhr.responseText);
                }
            });

        });
    }

</script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    

     <div class="table-container">
        <table id="example" class="table table-hover table-bordered" style="width:100% !important">
            <thead>
                <tr>
                    <th>Package Id</th>
                    <th>Package Name</th>
                    <th>Department</th>
                    <th>Duration</th>
                    <th>Remarks</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody id="tblbody">
            </tbody>
        </table>
    </div>
</asp:Content>
