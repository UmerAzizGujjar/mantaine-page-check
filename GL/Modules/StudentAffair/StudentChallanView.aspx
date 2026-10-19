<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentChallanView.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentChallanView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();

        });
        function PrintTest(id) {
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=ChallanPrint&ReportTitle=Student Challan Print&TransID=' + id + '';
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=ChallanPrint&ReportTitle=Student Challan Print&TransID=' + id + '';
            }
            window.open(url, '_blank');

        }

        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'AddStudentChallan.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "StudentChallanView.aspx/ViewList",
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
                    { "data": "Challan_ID", "visible": false, "width": "0%" },
                    { "data": "Challan_No", "name": "Challan_No", "width": "10%", "orderable": true },
                    {
                        "data": "IssueDate", "name": "IssueDate",
                        "render": function (data, type, full) { 
                            var date = full.IssueDate;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },
                    {
                        "data": "DueDate", "name": "DueDate",
                        "render": function (data, type, full) {
                            var date = full.DueDate;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },

                    { "data": "Seq_Challan_No", "width": "10%", "orderable": false },
                    { "data": "RollNo","name":"RollNo", "width": "10%", "orderable": true },
                    { "data": "StudentName", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Challan_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a href="#" class="delListBtn" style="border-radius: 4px;margin-left: 4px;padding: 5px 8px;" onclick="cancelChallan(' + full.Challan_ID + ')"><i class="fa fa-trash"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintTest(' + full.Challan_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res + Del + print;
                            return result;
                        }, "width": "10%", "orderable": false
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

        function cancelChallan(challanId) {
            if (confirm("Are you sure you want to cancel this challan?")) {
                $.ajax({
                    type: "POST",
                    url: "StudentChallanView.aspx/CancelChallan",
                    data: JSON.stringify({ challanId: challanId }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        if (response.d) {
                            alert("Challan cancelled successfully!");
                            $('#tblResult').DataTable().ajax.reload();
                        } else {
                            alert("Failed to cancel the challan.");
                        }
                    },
                    error: function (xhr, status, error) {
                        console.log(xhr.responseText);
                    }
                });
            }
        }


        function Edit(ID) {
            window.location.href = "AddStudentChallan.aspx?Challan_ID=" + ID;

        }

        function deleteConfirm(ID) {
            var ChallanID = ID;

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ChallanID, function (msg) {
                   
                    location.reload();
                    $(row).remove();
                }, OnFail);
            }
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
             <div id="PurchaseRequistiondetails" style="margin-top: 15px;">
          <fieldset>
            <a class="btn btn-primry" style="text-align: center" href="AddStudentChallan.aspx">Add New</a>
              </fieldset>
         <div>
        <table class="table table-hover table-striped table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>                    
                    <th style="display:none">Challan_ID</th>
                    <th>Challan No</th>
                    <th>Issue Date</th>   
                    <th>Due Date</th>                                       
                    <th>Seq Challan No</th>                                       
                    <th>Roll No</th>    
                    <th>Student Name</th>                                          
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
        </div>
         </div>

</asp:Content>
