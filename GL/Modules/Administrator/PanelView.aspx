<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PanelView.aspx.cs" Inherits="PMS.PanelView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();

        });
        function Edit(panel_id) {
            window.location.href = "panelagreement.aspx?ID=" + panel_id;
        }
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function Delete(anchorTag) {
            var panel_id = $(anchorTag).attr("data-id"); 
            $.ajax({
                type: "POST",
                url: "PanelView.aspx/Delete",
                data: JSON.stringify({ "panel_id": panel_id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    if (response.d == "success") {
                        alert("Record has been deleted successfully");
                        window.location.href = "PanelView.aspx";
                    } else {
                        alert("Error deleting the record: " + response.d); 
                    }
                },
                error: function (xhr, status, error) {
                    alert("An error occurred while processing the request: " + error);
                }
            });
        }

        
        function LoadPage() {
            let savedVisibility = null;
            let savedPageIndex = 0;
            let filterValue = 'all';

            $.ajax({
                type: "POST",
                url: "PanelView.aspx/GetPageState",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d !== null && response.d !== undefined) {
                        savedPageIndex = response.d;
                    }
                },
                error: function () {
                    console.error("Failed to load page state");
                }
            });

            $.ajax({
                type: "POST",
                url: "PanelView.aspx/GetFilterState",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d !== null && response.d !== undefined) {
                        filterValue = response.d;
                        $('#filterStatus').val(filterValue);
                    }
                },
                error: function () {
                    console.error("Failed to load filter state");
                }
            });

            $.ajax({
                type: "POST",
                url: "PanelView.aspx/GetUserColumnPreferences",
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

            var table = $("#tblPanel").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "pageLength": 10,
                "displayStart": savedPageIndex * 10,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'panelagreement.aspx'; }
                    },
                    'copy',
                    'excel',
                    'pdf',
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
                    var filter = $('#filterStatus').val() || 'all';

                    $.ajax({
                        type: "POST",
                        url: "PanelView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterStatus: filter
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
                    { "data": "Panel_ID", "name": "Panel_ID", "visible": false, "width": "0%" },
                    { "data": "Company_Name", "name": "Company_Name", "orderable": true, "width": "20%" },
                    { "data": "No_Of_Employees", "name": "No_Of_Employees", "orderable": true, "width": "10%" },
                    { "data": "Email", "name": "Email", "orderable": false, "width": "10%" },
                    { "data": "Contact_No", "name": "Contact_No", "orderable": false, "width": "10%" },
                    { "data": "Address", "name": "Address", "orderable": false, "width": "10%" },
                    { "data": "Discount", "name": "Discount", "orderable": false, "width": "10%" },
                    { "data": "AccountID", "name": "AccountID", "orderable": false, "width": "10%" },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Panel_ID + ')" style="border-radius: 4px; margin-right: 4px;padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Delete = '<a class="delListBtn" style="border-radius: 4px; margin-left: 4px;padding: 5px 8px;" href="#" data-id="' + full.Panel_ID + '" onclick="Delete(this)"><i class="fa fa-trash"></i></a>';
                            var result = res + Delete;
                            return result;
                        }, "width": "10%", "orderable": false
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

                    api.on('page.dt', function () {
                        var page = api.page.info();
                        var pageIndex = page.page;
                        $.ajax({
                            type: "POST",
                            url: "PanelView.aspx/SavePageState",
                            data: JSON.stringify({ pageIndex: pageIndex }),
                            contentType: "application/json; charset=utf-8",
                            dataType: "json",
                            success: function () {
                                console.log("Page state saved: " + pageIndex);
                            },
                            error: function () {
                                console.error("Failed to save page state");
                            }
                        });
                    });
                    var lengthContainer = document.querySelector('#tblPanel_length');
                    var lengthDropdown = document.querySelector('#tblPanel_length select');
                    var label = document.querySelector('#tblPanel_length label');

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

            if (savedPageIndex > 0) {
                setTimeout(function () {
                    table.page(savedPageIndex).draw('page');
                }, 100);
            }
            $('#filterStatus').on('change', function () {
                var filterValue = $(this).val();

                $.ajax({
                    type: "POST",
                    url: "PanelView.aspx/SaveFilterState",
                    data: JSON.stringify({ filterValue: filterValue }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function () {
                        console.log("Filter state saved: " + filterValue);
                    },
                    error: function () {
                        console.error("Failed to save filter state");
                    }
                });

                $('#tblPanel').DataTable().ajax.reload();
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   <div class="row">
    <div class="col-lg-2 col-md-6 col-sm-12">
        <label for="filterStatus">Filter by Account Status:</label>
        <select id="filterStatus" style="padding: 5px 10px; border-radius: 4px; border: 1px solid #ccc;">
            <option value="all">All</option>
            <option value="mapped">Mapped (Has Account)</option>
            <option value="unmapped">Unmapped (No Account)</option>
        </select>
    </div>
</div>
   <div class="table-container">
       <table id="tblPanel" class="table table-hover table-bordered">
           <thead>
               <tr>
                   <th>Panel_ID</th>
                   <th>Customer Name</th>
                   <th>Employee #</th>
                   <th>Email</th>
                   <th>Contact No</th>
                   <th>Address</th>
                   <th>Discount</th>
                   <th>Account</th>
                   <th>Action</th>
               </tr>
           </thead>
           <tbody></tbody>
       </table>
</div>
          
</asp:Content>
