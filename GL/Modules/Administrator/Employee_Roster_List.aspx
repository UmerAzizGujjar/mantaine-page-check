<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee_Roster_List.aspx.cs" Inherits="PMS.Employee_Roster_List" %>

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
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Employee_Roster.aspx'; } }, 'copy', 'excel', 'pdf',
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
                    { "data": "Month", width: "12%", "name": "Month", "orderable": true },
                    { "data": "Doctor_Id", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a class="editListBtn"  href="#" onclick="editOpen(' + full.RousterID + ')" style="border-radius: 4px;margin-right: 4px; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'
                                ;

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res  + print;
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

        function editOpen(Rouster_id) {
            window.open("Employee_Roster.aspx?ID=" + Rouster_id);
        }

        function deleteConfirm(anchorTag) {


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
