<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="SampleView.aspx.cs" Inherits="PMS.Modules.Lab.SampleView" %>
<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

       
        function Edit(ID) {
            debugger;
            window.location.href = "SampleCollectionFrom.aspx?ID=" + ID;
        }

        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'SampleCollectionFrom.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "SampleView.aspx/ViewList",
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
                    { "data": "Sample_ID", "visible": false, "width": "0%" },
                    { "data": "Sample_No", "name": "Sample_No", width:"12%" },
                    {
                        "data": "Sample_Collected_Date",
                        "render": function (data, type, full) {
                            var date = full.Sample_Collected_Date;
                            date = moment(date).format('D-MMM-YYYY');
                            return date;
                        }, width:"17%"
                    },
                    { "data": "mr_no_sequence", width:"13%" },
                    { "data": "Full_Name", width:"25%" },
                    {
                        "render": function (data, type, full) {
                            return '<a href="SampleCollectionFrom.aspx?SampleId=' + full.Sample_ID + '&SampleNo=' + full.Sample_No + '" style="border-radius: 4px; background-color: #1f1fe3; color: black; padding: 4px 11px 4px 11px;"><i class="fa fa-pencil" style="color:white !important;"></i></a>';
                        }, width:"10%"
                    }
                ]
            });
        }

    </script>
   
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="table-container">       
      <table class="table table-responsive-lg table-hover table-bordered" id="tblResult">
   <thead id="ihead">
       <tr>
          <th style="display:none">Sample ID</th>
          <th>Sample No</th>
          <th>Sample Collected Date</th>
          <th>MR No</th>
          <th>Full Name</th>
          <th>Action</th>
           </tr>
          </thead>
          </table>
      </div>
</asp:Content>
