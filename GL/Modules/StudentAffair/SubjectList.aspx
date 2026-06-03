<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SubjectList.aspx.cs" Inherits="PMS.SubjectList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">   
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
       <script type="text/javascript">
           $(document).ready(function () {
               debugger;
               $('#ctl00_lblMessage').hide();
               

               loadFilterOptions();


           });

           var dataTable; 

           function loadFilterOptions() {
               $.ajax({
                   type: "POST",
                   url: "SubjectList.aspx/GetFilterOptions",
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (response) {
                       var options = response.d;

                       populateDropdown('#ddlFilterClass', options.Classes);
                       populateDropdown('#ddlFilterBlock', options.Blocks);
                       populateDropdown('#ddlFilterModule', options.Modules);

                       initSelect2();
                       LoadPage();
                   },
                   error: function (xhr, status, error) {
                       console.log("Error loading filters:", error);
                       initSelect2();
                       LoadPage();
                   }
               });
           }
           function initSelect2() {
               $('#ddlFilterClass, #ddlFilterBlock, #ddlFilterModule').select2({
                   placeholder: "Select...",
                   allowClear: true,
                   width: 'resolve',
                   dropdownAutoWidth: true
               });

               $('#ddlFilterClass, #ddlFilterBlock, #ddlFilterModule').on('select2:select select2:unselect', function (e) {
                   if (dataTable) {
                       dataTable.ajax.reload();
                   }
               });
           }

           function populateDropdown(selector, data) {
               var $select = $(selector);
               $select.empty();
               $select.append('<option value="All">All</option>');
               if (data && data.length > 0) {
                   $.each(data, function (index, item) {
                       if (item) {
                           $select.append('<option value="' + item + '">' + item + '</option>');
                       }
                   });
               }
           }


           function LoadPage() {
               dataTable = $("#example").DataTable({
                   "processing": true,
                   "serverSide": true,
                   "dom": 'lBfrtip',
                   "lengthChange": true,
                   "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'Subj_Definition.aspx'; } }, 'copy', 'excel', 'pdf'],
                   "filter": true,
                   "ajax": function (data, callback, settings) {
                       var filterClass = $('#ddlFilterClass').val();
                       var filterBlock = $('#ddlFilterBlock').val();
                       var filterModule = $('#ddlFilterModule').val();

                       $.ajax({
                           type: "POST",
                           url: "SubjectList.aspx/ViewList",
                           data: JSON.stringify({
                               draw: data.draw,
                               start: data.start,
                               length: data.length,
                               sortColumn: data.columns[data.order[0].column].name,
                               sortColumnDirection: data.order[0].dir,
                               searchValue: data.search.value,
                               filterClass: filterClass,
                               filterBlock: filterBlock,
                               filterModule: filterModule
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
                               callback({ data: [] }); 
                           }
                       });
                   },
                   "columns": [
                       { "data": "subject_Id", "visible": false, "width": "0%" },
                       {
                           "data": null, "orderable": false, "width": "10%",
                           "render": function (data, type, row, meta) {
                               return meta.row + 1 + meta.settings._iDisplayStart;
                           }
                       },
                       { "data": "Program", "name": "Program", "width": "15%", "orderable": true },
                       { "data": "Class", "name": "Class", "width": "15%", "orderable": true },
                       { "data": "Block", "name": "Block", "width": "15%", "orderable": true },
                       { "data": "Module", "name": "Module", "width": "15%", "orderable": true },
                       {
                           render: function (data, type, full) {
                               var res = '<a class="editListBtn" href="#" onclick="editOpen(' + full.subject_Id + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a> ';
                               res += '<a class="deleteListBtn" href="#" onclick="DeleteData(' + full.subject_Id + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;color:red;"><i class="fa fa-trash"></i></a>';
                               return res;
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

               $('#ddlFilterClass, #ddlFilterBlock, #ddlFilterModule').on('change', function () {
                   dataTable.ajax.reload();
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
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
                    <label for="ddlFilterClass">Class:</label>
                    <select id="ddlFilterClass" class="form-control">
                        <option value="All">Loading...</option>
                    </select>
                </div>
        <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlFilterBlock">Block:</label>
                <select id="ddlFilterBlock" class="form-control">
                    <option value="All">Loading...</option>
                </select>
            </div>
         <div class="col-lg-2 col-md-4 col-sm-6">
                <label for="ddlFilterModule">Module:</label>
                <select id="ddlFilterModule" class="form-control">
                    <option value="All">Loading...</option>
                </select>
    </div>
        </div>

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
