<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorAgreementView.aspx.cs" Inherits="PMS.Inventory.DoctorAgreementView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;          
            LoadPage();
        });
        function PrintTest(id) {
            window.open('ReportViewer.aspx?ReportName=TestDefination&ReportTitle= Test Defination&Test_IDs=' + id);
        }
        function LoadPage() {
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddDoctorAgreement.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "order": [[1, "desc"]],
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "DoctorAgreementView.aspx/ViewList",
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
                    { "data": "doc_id", "name": "doc_id", "width": "10%", "orderable": true },
                    { "data": "Doc_name", "name": "Doc_name", "width": "20%", "orderable": true },
                    { "data": "Doc_Account", "width": "20%", "orderable": false },
                    {
                        "data": "Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn"  href="#" onclick="Edit(' + full.doc_id + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var print = '<a style="border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Test_ID + ')" id="btnprint"><i class="fa fa-print" style="color:white !important;"></i></a>';
                            var result;
                            result = res  + print;
                            return result;
                        }, "width": "4%", "orderable": false
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
   
        function Edit(ID) {
            window.location.href = "AddDoctorAgreement.aspx?doc_id=" + ID;
        }    
       
        function redirecttonew() {
            window.location.href = "AddDoctorAgreement.aspx";
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">   

     
    <div class="row">
        <div class="table-container col-lg-12 col-md-12 col-sm-12">
            <table id="example" class="table table-striped table-bordered display">
                <thead>
                    <tr>
                        <th>Doctor Id</th>
                        <th>Doctor</th>                       
                        <th>Account</th>
                         <th>Date</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
        </div>
    </div>


</asp:Content>
