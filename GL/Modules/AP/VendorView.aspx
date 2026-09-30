<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VendorView.aspx.cs" Inherits="PMS.AP.VendorView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
       
        function printPerson(Vendor_ID) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + Vendor_ID;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '../../ReportViewer.aspx?ReportName=VendorPerson&ReportTitle=Vendor Person&ID=' + Vendor_ID;
            }
            window.open(url, '_blank');
        }

        function LoadPage() {
            let savedVisibility = null;
            let savedPageIndex = 0;
            let filterValue = 'all';

            $.ajax({
                type: "POST",
                url: "VendorView.aspx/GetPageState",
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
                url: "VendorView.aspx/GetFilterState",
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
                url: "VendorView.aspx/GetUserColumnPreferences",
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

            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "pageLength": 50,
                "displayStart": savedPageIndex * 50,
                "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'Vendor.aspx'; }
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
                    // Get the current filter value from dropdown
                    var filter = $('#filterStatus').val() || 'all';

                    $.ajax({
                        type: "POST",
                        url: "VendorView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterStatus: filter  // <-- THIS IS THE KEY CHANGE
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
                    { "data": "Vendor_ID", "visible": false, "width": "0%" },
                    { "data": "Vendor_Name", "name": "Vendor_Name", "width": "13%", "orderable": true },
                    { "data": "Contact_Person", "width": "8%", "orderable": false },
                    { "data": "Vendor_Phone1", "width": "9%", "orderable": false },
                    { "data": "Vendor_Address", "width": "16%", "orderable": false },
                    { "data": "City", "width": "10%", "orderable": false },
                    { "data": "Vendor_NTN", "width": "10%", "orderable": false },
                    { "data": "Vendor_Type", "width": "10%", "orderable": false },
                    { "data": "AccountID", "width": "15%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Vendor_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="printPerson(' + full.Vendor_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + print;
                            return result;
                        }, "width": "15%", "orderable": false
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
                            url: "VendorView.aspx/SavePageState",
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

                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

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
                    url: "VendorView.aspx/SaveFilterState",
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

                $('#tblResult').DataTable().ajax.reload();
            });
        }




        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "Vendor.aspx?ID=" + ID;
        }
        function deleteConfirm(Vendor_ID) {
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Vendor_ID, function (msg) {
                    $(row).remove();

                }, OnFail);
            }
            window.location.href = "VendorsView.aspx?";
        }

    </script>

    

    <div class="table-container">
        <div class="row">
            <div class="col-lg-2 col-md-6 col-sm-12">
                <label for="filterStatus">Filter by Account Status:</label>
                <select id="filterStatus" style="padding: 5px 10px; border-radius: 4px; border: 1px solid #ccc;">
                    <option value="all">All Vendors</option>
                    <option value="mapped">Mapped (Has Account)</option>
                    <option value="unmapped">Unmapped (No Account)</option>
                </select>
            </div>
        </div>
        <table class="table table-hover table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>
                    <th>Vendor_ID</th>
                    <th>Vendor Name</th>
                    <th>Contact Person</th>
                    <th>Phone#</th>
                    <th>Address</th>
                    <th>City</th>
                    <th>NTN</th>
                    <th>Vendor Type</th>
                    <th>Account</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>
</asp:Content>
