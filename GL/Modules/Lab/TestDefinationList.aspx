<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TestDefinationList.aspx.cs" Inherits="PMS.TestDefinationList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });


        function LoadPage() {
            $('#tblresult').DataTable({
                "processing": true,
                "serverSide": true,
                   "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "TestDefinationList.aspx/ViewList",
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
                    { "data": "Test_ID", "name": "Test_ID", visible: false, "width": "0%" },                   
                    { "data": "Test_Name", "name": "Test_Name" },
                    { "data": "Main_Department", "name": "Main_Department" },
                    { "data": "Group_Category", "name": "Group_Category" },
                    { "data": "Group_Department", "name": "Group_Department" },
                    { "data": "Unit", "name": "Unit" },
                    { "data": "Active", "name": "Active" },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="TestDefination.aspx?id=' + full.Test_ID + '" class="editListBtn" style="border-radius: 4px; margin-right: 4px;color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Test_ID + '" onclick="DeleteTest(this)"><i class="fa fa-trash"style="color:white !important;"></i></a>';
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result;
                            result = res + Delete + print;
                            return result;
                        }, "width": "13%"
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblresult_length');
                    var lengthDropdown = document.querySelector('#tblresult_length select');
                    var label = document.querySelector('#tblresult_length label');

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
        

        
        function viewTestRateList() {
            debugger;
            window.open('ReportViewer.aspx?ReportName=TestRateList&ReportTitle=Test Rate List');
        }

        function viewGroupTest(row) {
            debugger;
            var groupName = $(row).parents('tr:first').find("td:eq(4)").text();
            window.open('ReportViewer.aspx?ReportName=GroupTestDefinition&ReportTitle=Group Test&GroupCategoryName=' + groupName.trim() + '');
        }

        function DeleteTest(anchorTag) {
            var id = $(anchorTag).data('id'); 
            if (confirm('Are you sure want to delete Test ID:- ' + id)) {
                PageMethods.DeleteTest(id, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Delete. ')
                    } else if (msg == "success") {
                        $(anchorTag).parents('tr').remove();
                    }
                });
            }
            
        }
     

        function changeActiveStatus(row) {
            debugger;
            var testID = $(row).parents('tr:first').children('td').first().next().text();
            var status = $('#chk' + testID + '')[0].checked;
            PageMethods.changeActiveStatus(testID, status);
        }

        function PrintTest(row) {
            debugger;
            var Test_ID = $(row).parents('tr:first').children('td').first().next().text();
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + Test_ID);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6" style="margin-bottom: 1%;">
            <input type="button" class="btn btn-primry" id="aadnew"  value="Add New" onclick="location.href = 'TestDefination.aspx';" />
        </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" class="btn btn-gray" id="btnViewRateList"  value="View Rate List" onclick="viewTestRateList()" />
    </div>
    </div>
    <div id="PatientDetail" style="width: 100%">
        <contenttemplate>
            <table id="tblresult" class="table table-hover table-striped table-bordered">
                <thead>
                    <tr>
                    <th>Test ID</th>
                    <th>Test Name</th>
                    <th>Main Department</th>
                    <th>Group Category</th>
                    <th>Group Department</th>
                    <th>Unit</th>
                    <th>Active</th>
                    <th>Action</th>
                        </tr>
                </thead>
                <tbody>
                </tbody>
            </table>
        </contenttemplate>
    </div>
</asp:Content>
