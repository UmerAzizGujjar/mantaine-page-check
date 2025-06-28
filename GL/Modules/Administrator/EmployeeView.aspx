<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmployeeView.aspx.cs" Inherits="PMS.EmployeeView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">


      
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function editOpen(Emp_ID) {
            window.open("Employee.aspx?ID=" + Emp_ID);
        }
    
        function deleteConfirm(ID) {
            debugger;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ID, function (msg) {
                    location.reload();
                });

            }
        }


        function LoadPage() {
            debugger
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Employee.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "EmployeeView.aspx/ViewList",
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
                    { "data": "Emp_id", "visible": false, "width": "0%" },
                    { "data": "Emp_No", "name": "Emp_No", width: "12%", "orderable": true },
                    { "data": "Emp_Name", "name": "Emp_Name", "orderable": true },
                    { "data": "Department", "orderable": false },
                    { "data": "Designation", "orderable": false },
                    { "data": "Mobile1", "orderable": false },
                    { "data": "Email", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn"  href="#" onclick="editOpen(' + full.Emp_id + ')" style="border-radius: 4px;margin-right: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#"  onclick="deleteConfirm(' + full.Emp_id + ')"><i class="fa fa-trash"style="color:white !important;"></i></a>';

                            var result;
                            result = res + Delete;
                            return result;
                        }, "width": "10%", "orderable": false
                    }

                ],
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
        }


    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="">
       
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
                            <th>Actions</th>

                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>

                </table>
            </div>
    </div>



</asp:Content>
