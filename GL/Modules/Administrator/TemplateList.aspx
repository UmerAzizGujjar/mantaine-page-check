<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TemplateList.aspx.cs" Inherits="PMS.TemplateList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            $('#example').DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'MedicineTemplate.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "TemplateList.aspx/ViewList",
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
                    { "data": "ItemCode", "name": "ItemCode", "orderable": true },
                    { "data": "MedicineName", "name": "MedicineName", "orderable": true },
                    { "data": "Frequency", "orderable": false },
                    { "data": "Oral", "orderable": false },
                    { "data": "DosageFrom", "orderable": false },
                    { "data": "Dosage_Qty", "orderable": false },
                    { "data": "AttendingParamedical_Staff", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn"  href="#" onclick="Edit(' + full.TemplateID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'
                                ;
                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + print;
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
        debugger;

        function Edit(ID) {
            debugger;
            window.location.href = "MedicineTemplate.aspx?ID=" + ID;
           
        }
        function deleteConfirm(ID) {
            debugger;
            var itemID = ID;
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(itemID, function (msg) {
                    debugger;
                    location.reload();
                });
            }
        }
        function redirecttonew() {
            window.location.href = "MedicineTemplate.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
 
    <div class="table-container">        
                <table id="example" class="table table-hover table-bordered">
                    <thead>
                        <tr>
                            <th>Item Code</th>
                            <th>Item Name</th>
                            <th>Frequency</th>
                            <th>Routes</th>
                            <th>Dosage Form</th>
                            <th>Dosage Qty</th>
                            <th>Special Instruction</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblbody"></tbody>
                </table>    
                 </div>
</asp:Content>
