<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmployeeView.aspx.cs" Inherits="PMS.EmployeeView" %>

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
        function editOpen(Emp_ID) {
            window.open("Employee.aspx?ID=" + Emp_ID);
        }
    
        function deleteConfirm(ID) {
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ID, function (msg) {
                    location.reload();
                });

            }
        }


        function LoadPage() {
            let savedVisibility = null;
            let savedPageIndex = 0;
            let filterValue = 'all';

            $.ajax({
                type: "POST",
                url: "EmployeeView.aspx/GetFilterState",
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
                url: "EmployeeView.aspx/GetUserColumnPreferences",
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

            $.ajax({
                type: "POST",
                url: "EmployeeView.aspx/GetPageState",
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

            var table = $("#example").DataTable({
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
                        action: function () {
                            window.location = 'Employee.aspx';
                        }
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
                    var filter = $('#filterStatus').val() || "all";
                    $.ajax({
                        type: "POST",
                        url: "EmployeeView.aspx/ViewList",
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
                    { "data": "Emp_id", "name": "Emp_id", "visible": false, "width": "0%" },
                    { "data": "Emp_No", "name": "Emp_No", "width": "12%", "orderable": true },
                    { "data": "Emp_Name", "name": "Emp_Name", "orderable": true },
                    { "data": "Department", "name": "Department", "orderable": false },
                    { "data": "Designation", "name": "Designation", "orderable": false },
                    { "data": "Mobile1", "name": "Mobile1", "orderable": false },
                    { "data": "Email", "name": "Email", "orderable": false },
                    { "data": "AccountID", "name": "AccountID", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="editOpen(' + full.Emp_id + ')" style="border-radius:4px;margin-right:4px;padding:5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Delete = '<a class="delListBtn" href="#" onclick="deleteConfirm(' + full.Emp_id + ')" style="border-radius:4px;margin-left:4px;padding:5px 8px;"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" href="#" onclick="PrintTest(' + full.Emp_id + ')" id="btnprint" style="border-radius:4px;margin-left:4px;padding:5px 8px;"><i class="fa fa-print"></i></a>';
                            return res + Delete + print;
                        },
                        "width": "10%",
                        "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var api = this.api();

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
                            url: "EmployeeView.aspx/SavePageState",
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

            if (savedPageIndex > 0) {
                setTimeout(function () {
                    table.page(savedPageIndex).draw('page');
                }, 100);
            }

            $('#filterStatus').on('change', function () {
                var filterValue = $(this).val();

                $.ajax({
                    type: "POST",
                    url: "EmployeeView.aspx/SaveFilterState",
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

                table.ajax.reload();
            });
        }


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-6 col-sm-12">
            <label for="filterStatus">Filter by Account Status:</label>
            <select id="filterStatus" style="padding: 5px 10px; border-radius: 4px; border: 1px solid #ccc;">
                <option value="all">All Employees</option>
                <option value="mapped">Mapped (Has Account)</option>
                <option value="unmapped">Unmapped (No Account)</option>
            </select>
        </div>
    </div>
       
        <div class="row">
                <table id="example" class="table table-striped table-bordered display table-responsive-sm table-responsive-md table-responsive-lg w-100">
                    <thead>
                        <tr>
                            <th>Employee ID</th>
                            <th>Employee Code</th>
                            <th>Employee Name</th>
                            <th>Department</th>
                            <th>Designation</th>
                            <th>Phone No.</th>
                            <th>Email</th>
                            <th>Acount</th>
                            <th>Actions</th>

                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>

                </table>
            </div>



</asp:Content>
