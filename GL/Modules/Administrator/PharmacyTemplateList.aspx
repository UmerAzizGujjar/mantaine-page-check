<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PharmacyTemplateList.aspx.cs" Inherits="PMS.PharmacyTemplateList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
        function LoadPage() {
            var table = $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'PharmacyTemplate.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PharmacyTemplateList.aspx/ViewList",
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
                "scrollX": false,
                "autoWidth": false,
                "columns": [
                    { "data": "TemplateName", "name": "TemplateName", "orderable": true },
                    { "data": "MedicineCount", "name": "MedicineCount", "orderable": true },
                    { "data": "CreatedByName", "orderable": false },
                    {
                        "data": "CreatedTime",
                        "name": "CreatedTime",
                        "orderable": true,
                        "render": function (data) {
                            return formatDateTime(data);
                        }
                    },
                    { "data": "UpdatedByName", "orderable": false },
                    {
                        "data": "UpdatedTime",
                        "name": "UpdatedTime",
                        "orderable": true,
                        "render": function (data) {
                            return formatDateTime(data);
                        }
                    },
                    {
                        render: function (data, type, full) {
                            var edit = '<a class="editListBtn" href="#" onclick="Edit(' + full.TemplateID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var del = '<a class="printListBtn" href="#" onclick="deleteConfirm(' + full.TemplateID + ')" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-trash"></i></a>';
                            return edit + del;
                        }, "width": "10%", "orderable": false
                    }

                ],
                "createdRow": function (row, data) {
                    $(row).attr('data-template-id', data.TemplateID);
                },
                "initComplete": function (settings, json) {
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });

            $('#example tbody').off('click', 'tr').on('click', 'tr', function (e) {
                if ($(e.target).closest('a').length) {
                    return;
                }
                var row = table.row(this);
                if (!row.data()) {
                    return;
                }
                if (row.child.isShown()) {
                    row.child.hide();
                    $(this).removeClass('shown');
                    return;
                }
                table.rows().every(function () {
                    if (this.child.isShown()) {
                        this.child.hide();
                        $(this.node()).removeClass('shown');
                    }
                });
                var items = row.data().Items || [];
                var html = '<div style="padding: 10px;"><strong>Medicines:</strong><ul style="margin: 5px 0 0 15px;">';
                if (items.length === 0) {
                    html += '<li>No medicines</li>';
                } else {
                    $.each(items, function (i, name) {
                        html += '<li>' + name + '</li>';
                    });
                }
                html += '</ul></div>';
                row.child(html).show();
                $(this).addClass('shown');
            });
        }

        function Edit(ID) {
            window.location.href = "PharmacyTemplate.aspx?ID=" + ID;
        }
        function deleteConfirm(ID) {
            var itemID = ID;
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'Are you sure you want to delete this record?',
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
                if (result.isConfirmed) {
                    PageMethods.DeleteRecord(itemID, function () {
                        location.reload();
                    });
                }
            });
        }
        function redirecttonew() {
            window.location.href = "PharmacyTemplate.aspx";
        }

        function formatDateTime(value) {
            if (!value) {
                return '';
            }
            var date;
            if (typeof value === 'string' && value.indexOf('/Date(') === 0) {
                var match = /\/Date\((\d+)\)\//.exec(value);
                if (match) {
                    date = new Date(parseInt(match[1], 10));
                }
            }
            if (!date) {
                date = new Date(value);
            }
            if (isNaN(date.getTime())) {
                return value;
            }
            var day = ('0' + date.getDate()).slice(-2);
            var month = ('0' + (date.getMonth() + 1)).slice(-2);
            var year = date.getFullYear();
            var hours = ('0' + date.getHours()).slice(-2);
            var minutes = ('0' + date.getMinutes()).slice(-2);
            return day + '-' + month + '-' + year + ' ' + hours + ':' + minutes;
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 
    <div class="table-container" style="overflow-x: hidden;">        
                <table id="example" class="table table-hover table-bordered">
                    <thead>
                        <tr>
                            <th>Template Name</th>
                            <th>Medicines</th>
                            <th>Created By</th>
                            <th>Created Time</th>
                            <th>Updated By</th>
                            <th>Updated Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody"></tbody>
                </table>    
                 </div>
</asp:Content>
