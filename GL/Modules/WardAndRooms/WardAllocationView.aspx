<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="WardAllocationView.aspx.cs" Inherits="PMS.WardAllocationView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/StandardTheme/css/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">
      $(document).ready(function () {
      LoadPage();

  });

  function LoadPage() {
      $('#tbl').DataTable({
          "processing": true,
          "serverSide": true,
          "dom": 'lBfrtip',
          "lengthChange": true,
          "buttons": ['copy', 'excel', 'pdf'],
          "filter": true,
          "ajax": function (data, callback, settings) {
              $.ajax({
                  type: "POST",
                  url: "WardAllocationView.aspx/ViewList",
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
              { "data": "Ward_Allocation_ID", "name": "Ward_Allocation_ID", visible: false, "width": "0%" },
              { "data": "Ward_No", "name": "Ward_No", "orderable": true },
              { "data": "Full_Name", "name": "Full_Name", "orderable": false },
              { "data": "Ward", "orderable": false },
              { "data": "Bed_No_Assigned","name":"Bed_No_Assigned","orderable":true },
              {
                  "data": "From_TimeDate", "name": "From_TimeDate",
                  "render": function (data, type, full) {
                      debugger;
                      var date = full.From_TimeDate;
                      date = moment(date).format('DD-MMM-YYYY');
                      return date;
                  }, "width": "15%", "orderable": false
              },
              {
                  "data": "To_TimeDate", "name": "To_TimeDate",
                  "render": function (data, type, full) {
                      debugger;
                      var date = full.To_TimeDate;
                      date = moment(date).format('DD-MMM-YYYY');
                      return date;
                  }, "width": "15%", "orderable": false
              },
              {
                  render: function (data, type, full) {
                      debugger;
                      var res = '<a href="#" class="editListBtn" onclick="Edit(\'' + full.Ward_Allocation_ID + '\')" style="border-radius: 4px; margin-right: 4px; color: white; padding: 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>';
                      var Delete = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Ward_Allocation_ID + '" onclick="deleteConfirm(this)"><i class="fa fa-trash"style="color:white !important;"></i></a>';
                      var result;
                      result = res + Delete;
                      return result;
                  }, "width": "10%", "orderable": false
              }
          ],
          "initComplete": function (settings, json) {
              var lengthContainer = document.querySelector('#tbl_length');
              var lengthDropdown = document.querySelector('#tbl_length select');
              var label = document.querySelector('#tbl_length label');

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

  debugger;
  function Edit(id) {
      window.open("WardAllocation.aspx?ID=" + id + "");
    }

    function deleteConfirm(anchorTag) {
        debugger;
        var WardAllocationID = $(anchorTag).data('id');
        if (confirm('Are you sure you want to delete this record?')) {
            PageMethods.DeleteRecord(WardAllocationID, function (msg) {
                $(anchorTag).closest('tr').remove();
            });
        }
    }


</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">
            <input type="button" value="Add New" " class="btn-primry" onclick="window.location = 'WardAllocation.aspx'" />
        </div>
    </div>
<br />
<div class="row">
        <div class="table-container">
        <table id="tbl"  class="table table-bordered table-hover table-striped">
            <thead id="ihead">
                <tr>
                    <th>WardID</th>
                    <th>Ward No</th>
                    <th>Patient Name</th>
                    <th>Ward</th>
                    <th>Bed Assigned</th>
                    <th>From Date</th>
                    <th>To Date</th>
                    <th>View</th>
                </tr>
            </thead>
            <tbody id="tbody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>
