<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DialysisView.aspx.cs" Inherits="PMS.Modules.PatientManagement.DialysisView" %>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">

    $(document).ready(function () {
        debugger;
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });
    
    function editOpen(Dialysis_ID) {
        window.open("DialysisForm.aspx?ID=" + Dialysis_ID);
    }

    function deleteConfirm(ID) {
        debugger;
        if (confirm('Are you sure want to delete this record')) {
            PageMethods.DeleteRecord(ID, function (msg) {
                location.reload();
            });
        }
    }

    function LoadPage() {
        debugger
        $("#example").DataTable({
            "processing": true,
            "serverSide": true,
            "dom": 'lBfrtip',
            "lengthChange": true,
            "buttons": [
                { text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'DialysisForm.aspx'; } }, 
                'copy', 
                'excel', 
                'pdf',
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
                    url: "DialysisView.aspx/ViewList",
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
                { "data": "Dialysis_ID", "visible": false, "width": "0%" },
                { "data": "Dialysis_No", "name": "Dialysis_No", width: "20%", "orderable": true },
                { "data": "MRNo", "name": "MRNo", width: "20%", "orderable": true },
                { "data": "Patient_Name", "name": "Patient_Name", width: "30%", "orderable": true },
                { "data": "Date", width: "20%", "orderable": false },
                {
                    render: function (data, type, full) {
                        debugger;
                        var res = '<a class="editListBtn"  href="#" onclick="editOpen(\'' + full.Dialysis_ID + '\')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                        var Delete = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#"  onclick="deleteConfirm(\'' + full.Dialysis_ID + '\')"><i class="fa fa-trash"></i></a>';

                        var result = res + Delete;
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

</script>
</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
      <div class="">
     
      <div class="row">
              <table id="example" class="table table-striped table-bordered display table-responsive-sm table-responsive-md table-responsive-lg w-100">
                  <thead>
                      <tr>
                          <th>Dialysis ID</th>
                          <th>Dialysis No.</th>
                          <th>MR No.</th>
                          <th>Name</th>
                          <th>Date</th>
                          <th>Actions</th>
                      </tr>
                  </thead>
                  <tbody id="tblbody">
                  </tbody>
              </table>
          </div>
  </div>
</asp:Content>
