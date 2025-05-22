<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DepartmentWiseUserList.aspx.cs" Inherits="PMS.DepartmentWiseUserList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
  
    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
        });

        function LoadPage() {
            $('#tblResult').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "DepartmentWiseUserList.aspx/ViewList",
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
                    { "data": "Dept_Wise_User_Id", "name": "Dept_Wise_User_Id", visible: false, "width": "0%" },
                    { "data": "UserName", "name": "UserName" },                   
                    {
                        "data": "Created_Time", "name": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%"
                    },                 
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="Edit(\'' + full.Dept_Wise_User_Id + '\')" style="border-radius: 4px; margin-right: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                            var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Dept_Wise_User_Id + '" onclick="deleteConfirm(this)"><i class="fa fa-trash"style="color:white !important;"></i></a>';
                            var result;
                            result = res + Delete;
                            return result;
                        }, "width": "10%"
                    }
                ],
                "initComplete": function (settings, json) {
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
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }
        function Edit(ID) {
            window.location.href = "DepartmentWiseUser.aspx?ID=" + ID;
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var DeptWiseUserId = $(anchorTag).data('id');
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(DeptWiseUserId, function (msg) {
                    debugger;
                    $(anchorTag).closest('tr').remove();
                }, OnFail);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PurchaseRequistiondetails" style="margin-top: 15px;">
        <fieldset>
           <div class="row">
                 <div class="col-lg-2 col-md-4 col-sm-6">
                      <input type="button" name="btn_Add" id="btn_Add" class="btn-primry" value="Add New" onclick="window.location = 'DepartmentWiseUser.aspx'" />
                     </div>
                     </div>
        </fieldset>
        <br />
        <div class="table-container">
            <div class="table-responsive">
                <table class="table table-hover table-striped table-bordered" id="tblResult">
                    <thead id="ihead">
                        <tr>
                            <th>Dept_Wise_User_Id</th>
                            <th>Username</th>
                            <th>Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</asp:Content>
