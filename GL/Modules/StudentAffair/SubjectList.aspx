<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SubjectList.aspx.cs" Inherits="PMS.SubjectList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">   
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
       <script type="text/javascript">
           $(document).ready(function () {
               debugger;
               $('#ctl00_lblMessage').hide();
               LoadPage();


           });


            function LoadPage() {
                $("#example").DataTable({
                    "processing": true,
                    "serverSide": true,
                    "dom": 'lBfrtip',
                    "lengthChange": true,
                    "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Subj_Definition.aspx'; } }, 'copy', 'excel', 'pdf'],
                    "filter": true,
                    "ajax": function (data, callback, settings) {
                        $.ajax({
                            type: "POST",
                            url: "SubjectList.aspx/ViewList",
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
                        { "data": "subject_Id", "visible": false, "width": "0%" },
                        {"data": null,"orderable": false,"width": "10%",
                            "render": function (data, type, row, meta) {
                                return meta.row + 1 + meta.settings._iDisplayStart;
                            }
                        },
                        { "data": "Program", "name": "Program", "width": "15%", "orderable": true },
                        { "data": "Class", "name": "Class", "width": "15%", "orderable": false },                                           
                        { "data": "Block", "name": "Class", "width": "15%", "orderable": false },                                           
                        { "data": "Module", "name": "Class", "width": "15%", "orderable": false },                                           
                        {
                            render: function (data, type, full) {
                                debugger;
                                var res = '<a  class="editListBtn" href="#" onclick="editOpen(' + full.subject_Id + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                                var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.subject_Id + '" onclick="DeleteData( ' + full.subject_Id + ', \'' + full.subject_Id + '\')"><i class="fa fa-trash" ></i></a>';

                                var result;
                                result = res + Del;
                                return result;
                            }, "width": "15%", "orderable": false
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




            function editOpen(id) {             
                window.location.href = "Subj_Definition.aspx?ID=" + id + ""
            }

            function DeleteData(id) {
                debugger;
                $.ajax({
                    url: 'SubjectList.aspx/DeleteSubject',
                    type: 'post',
                    contentType: 'application/json;charset=utf-8',
                    dataType: 'json',

                    data: JSON.stringify({
                        "Id": id,
                    }),
                    success: function () {
                        debugger;
                        alert('delete success !!');
                        window.location.reload();
                        
                    },
                    error: function () {
                        alert('delete error !!');
                    }
                });
            }

            function FormOpen() {
                window.location.href = "SubjectDefinition.aspx";
            }

       </script> 


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <table id="example" class="table table-striped table-bordered display" >
        <thead>
            <tr>
                     <th>subject_Id</th>
                     <th>Sr#</th>
                    <th>Program</th>
                    <th>Class</th>
                    <th>Block</th>
                    <th>Module</th>
                    <th>Actions</th>
            </tr>
        </thead>
        <tbody id="tblbody">
        </tbody>    
    </table> 



</asp:Content>
