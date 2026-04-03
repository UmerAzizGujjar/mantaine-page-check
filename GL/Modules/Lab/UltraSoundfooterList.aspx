<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UltraSoundfooterList.aspx.cs" Inherits="PMS.Modules.Lab.UltraSoundfooterList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" /> 

     <script type="text/javascript">
         $(document).ready(function () {
             $('#ctl00_lblMessage').hide();
             LoadPage();
         });

         function editOpen(id) {
             window.open("UltrasoundFooter.aspx?id=" + id);
         }

         function LoadPage() {

             var table = $("#example").DataTable({
                 processing: true,
                 serverSide: true,
                 destroy: true,
                 dom: 'lBfrtip',
                 lengthChange: true,

                 buttons: [
                     {
                         text: '<i class="fa fa-plus"></i> Add',
                         className: 'dt-button buttons-copy buttons-html5',
                         action: function () {
                             window.location = 'RegisterPatient.aspx';
                         }
                     },
                     {
                         extend: 'copy',
                         text: '<i class="fa fa-copy"></i> Copy',
                         className: 'dt-button buttons-copy'
                     },
                     {
                         extend: 'excel',
                         text: '<i class="fa fa-file-excel"></i> Excel',
                         className: 'dt-button buttons-excel'
                     },
                     {
                         extend: 'pdf',
                         text: '<i class="fa fa-file-pdf"></i> PDF',
                         className: 'dt-button buttons-pdf'
                     }
                 ],

                 order: [[3, "desc"]], // TemplateId desc (matches backend default)

                 ajax: function (data, callback) {
                     $.ajax({
                         type: "POST",
                         url: "UltraSoundfooterList.aspx/ViewList", // your method
                         data: JSON.stringify({
                             draw: data.draw,
                             start: data.start,
                             length: data.length,
                             sortColumn: data.columns[data.order[0].column].data,
                             sortColumnDirection: data.order[0].dir,
                             searchValue: data.search.value || ""
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

                         error: function (xhr) {
                             console.log("Error:", xhr.responseText);
                         }
                     });
                 },

                 columns: [
                     { data: "TemplateName", title: "Template Name" },
                     { data: "DoctorName", title: "Doctor Name" },
                     { data: "DoctorId", title: "Doctor ID" },
                    // { data: "TemplateId", title: "Template ID" },
                     {
                       data: "TemplateId",
                       title: "Action",
                         render: function (data, type, full) {
                           return `
                                 <button class="btn btn-sm btn-primary" onclick="editOpen(${full.DoctorId})">Edit</button>
                                 <button class="btn btn-sm btn-danger" onclick="Delete(${full.DoctorId})">Delete</button>
                           `;
                       },
                        orderable: false
                     }
                 ]
             });
         }

         //function updateColumnHeaders(table) {
         //    var api = table;
         //    var headers = api.columns().header();

         //    api.columns().every(function (index) {
         //        var column = api.column(index);
         //        var header = $(headers[index]);
         //        var isVisible = column.visible();

         //        if (isVisible) {
         //            header.removeClass('hidden-col');
         //        } else {
         //            header.addClass('hidden-col');
         //        }
         //    });
         //}

     </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display" style="width:100%">
    <thead>
        <tr>
            <th>Template Name</th>
            <th>Doctor Name</th>
            <th>Doctor ID</th>
            <th>Action</th>
        </tr>
    </thead>
</table>
        </div>
    </div>

</asp:Content>
