<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee_Roster_List.aspx.cs" Inherits="PMS.Employee_Roster_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">


        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });



        function LoadPage() {
            debugger
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "Employee_Roster_List.aspx/ViewList",
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
                    { "data": "RousterID", "visible": false, "width": "0%" },
                    { "data": "Month", width: "12%" },
                    { "data": "Doctor_Id", },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn"  href="#" onclick="editOpen(' + full.RousterID + ')" style="border-radius: 4px;margin-right: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                                ;

                            var result;
                            result = res;
                            return result;
                        }, "width": "10%"
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

        function editOpen(Rouster_id) {
            window.open("Employee_Roster.aspx?ID=" + Rouster_id);
        }

        debugger;
        function deleteConfirm(anchorTag) {
            debugger;


            var row = $(anchorTag).parents('tr')[0];

            var AppID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(AppID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div >
        <div class="row mb-3">
            <div class="col-lg-1 col-md-3 col-sm-4" style="margin-bottom:1%">
                <input type="button" value="Add New" id="btnnew" class="btn-primry"  tabindex="14" onclick="window.location = 'Employee_Roster.aspx'" />
            </div>
        </div>
        <div class="row">
         
                <table id="example" class="table table-striped table-bordered table-responsive-md w-100">
                    <thead>
                        <tr>
                            <th>Rouster ID</th>
                            <th>Rouster Month</th>
                            <th>Employee Name</th>
                            <th>Actions</th>
                       </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>

                </table>
            </div>
        
    </div>

</asp:Content>
