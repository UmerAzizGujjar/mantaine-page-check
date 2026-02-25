<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TestDefinationList.aspx.cs" Inherits="PMS.TestDefinationList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
            GetMainDepartments();
            GetGroup();
            GroupDepartment();
        });

        function ShowReport(Test_ID) {
            debugger;
            window.open('../../ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + Test_ID);
        }

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "TestDefinationList.aspx/GetUserColumnPreferences",
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
            $('#tblresult').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'TestDefination.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
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
                    // ✅ Get current filter values from dropdowns
                    var mainDept = $('#main-departments').val() || '';
                    var groupCat = $('#Group_Category').val() || '';
                    var groupDept = $('#Group_department').val() || '';

                    $.ajax({
                        type: "POST",
                        url: "TestDefinationList.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            mainDepartmentId: mainDept,
                            groupCategoryId: groupCat,
                            groupDepartmentId: groupDept
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
                            console.error("AJAX Error:", error);
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Test_ID", "name": "Test_ID", "visible": false, "width": "0%" },
                    { "data": "Test_Name", "name": "Test_Name", "orderable": true },
                    { "data": "Main_Department", "name": "Main_Department", "orderable": true },
                    { "data": "Group_Category", "name": "Group_Category", "orderable": true },
                    { "data": "Group_Department", "name": "Group_Department", "orderable": true },
                    { "data": "Unit", "name": "Unit", "orderable": false },
                    { "data": "Rate", "name": "Rate", "orderable": false },
                    { "data": "Active", "name": "Active", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var res = '<a href="TestDefination.aspx?id=' + full.Test_ID + '" class="editListBtn" style="border-radius: 4px; margin-right: 4px; padding: 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Delete = '<a class="delListBtn" style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px;" href="#" data-id="' + full.Test_ID + '" onclick="DeleteTest(this)"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" style="border-radius: 4px; margin-left: 4px; color: white; padding: 5px 8px;" href="#" onclick="ShowReport(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            return res + Delete + print;
                        },
                        "width": "13%",
                        "orderable": false
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
                    }
                }
            });
        }
        
        function GetMainDepartments(d) {
            var options = '<option value="">Select Department</option>';
            PageMethods.GetMainDepartments(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#main-departments').html(options);
            });
        }
        function GetGroup(d) {
            var options = '<option value="">Select Group Catagory</option>';
            PageMethods.GetTestGroups(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#Group_Category').html(options);
            });
        }
        function GroupDepartment(d) {
            var options = '<option value="">Select Group Department</option>';
            PageMethods.GroupDepartment(function (departments) {
                $.each(JSON.parse(departments), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" ' + (d == value.DataValue_Name ? 'selected' : '') + ' >' + value.DataValue_Description + '</option>';
                });
                $('#Group_department').html(options);
            });
        }
        
        function viewTestRateList() {
            debugger;
            window.open('../../ReportViewer.aspx?ReportName=TestRateList&ReportTitle=Test Rate List');
            //window.open('ReportViewer.aspx?ReportName=TestRateList&ReportTitle=Test Rate List');
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
        function FilterTestsDetail() {
            var table = $('#tblresult').DataTable();
            // Use ajax.reload() with custom params
            table.ajax.reload(function (json) {
                // optional callback after reload
            }, false); // false = keep current paging
        }

        function changeActiveStatus(row) {
            debugger;
            var testID = $(row).parents('tr:first').children('td').first().next().text();
            var status = $('#chk' + testID + '')[0].checked;
            PageMethods.changeActiveStatus(testID, status);
        }

        function PrintTest(row) {
            debugger;
            //var Test_ID = $(row).parents('tr:first').children('td').first().next().text();
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + row);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6" style="margin-bottom: 1%;">
            <input type="button" class="btn btn-gray" id="btnViewRateList"  value="View Rate List" onclick="viewTestRateList()" />
        </div>
          <div class="col-md-2 col-lg-2 col-sm-6">
      <select id="main-departments" onchange="FilterTestsDetail()" >
          <option value="">Select Department</option>
      </select>
  </div>
  <div class="col-md-2 col-lg-2 col-sm-6">
      <select id="Group_Category" onchange="FilterTestsDetail()" >
          <option value="">Select Group</option>
      </select>
  </div>
  <div class="col-md-2 col-lg-2 col-sm-6">
      <select id="Group_department" onchange="FilterTestsDetail()" >
          <option value="">Group Department</option>
      </select>
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
                    <th>Rate</th>
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
