<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PurchaseRequistionView.aspx.cs" Inherits="PMS.AP.PurchaseRequistionView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
<link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <script type="text/javascript">

        var isDele = '';
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });



        function OnFail(exc) {
            alert(exc.get_message());
        }


        function Edit(ID) {
            window.location.href = "PurchaseRequistion.aspx?ID=" + ID;
        }

        function Print(PR_Id) {

            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition List&PRid=' + PR_Id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];
                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=PurchaseRequsitionList&ReportTitle=Purchase Requsition List&PRid=' + PR_Id;
            }
            window.open(url, '_blank');
        }
        function isDeleteAllow() {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "PurchaseRequistionView.aspx/isDeleteAllow",
                data: "",
                success: function (resp) {

                    if (resp.d == true) {
                        isDele = true;
                    }
                    else {
                        isDele = false;
                    }
                }, error: function () { }
            })
        }


        function deleteConfirm(PR_Id) {

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(PR_Id, function (msg) {
                    location.reload();
                }, OnFail);
            }
        }



        function LoadPage() {
            debugger
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'PurchaseRequistion.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "PurchaseRequistionView.aspx/ViewList",
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
                    { "data": "PR_Id", "visible": false, "width": "0%" },
                    { "data": "PR_Num", "name": "PR_Num", "orderable": true },
                    {
                        "data": "PR_Date",
                        "render": function (data, type, full) {
                            var date = full.PR_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "orderable": true
                    },
                    { "data": "Priority", "orderable": false },
                    { "data": "Department", "orderable": false },
                    { "data": "TotalQty", className: "text-right", "orderable": false },
                    { "data": "CreatedBY", "orderable": false },
                    { "data": "Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.PR_Id + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';

                            var del = '<a href="#" class="delListBtn" onclick="deleteConfirm(' + full.PR_Id + ')" style="border-radius: 4px;padding: 5px 8px; display: inline-block;" class="btnDel"><i class="fa fa-trash"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="Print(' + full.PR_Id + ')" id="btnprint"><i class="fa fa-print"></i></a>';

                            var result;

                            if (full.Status == "Approved" || full.Status == "Pending" || full.Status == "Cancelled") {
                                result = res + print;
                            }
                            else if (full.Status == "Created") {
                                result = res + del + print;
                            }
                            else {
                                result = res + del + print;
                            }

                            return result;
                        }, "orderable": false
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
                },
                "rowCallback": function (row, data, index) {
                    if (data.Status === "Cancelled") {
                        $(row).css('background-color', '#rgba(251, 181, 181, 0.87)');
                        $(row).find('td').css('background-color', '#rgba(251, 181, 181, 0.87)');
                    } else if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                        $(row).find('td').css('background-color', '#ABEBC6');
                    }
                }
            });
        }

                
       
      
       
    </script>
      
      <div class="table-container">
        <table class="table table-hover  table-bordered" id="example" >
            <thead id="ihead">
                <tr>
                    <th style="display:none">PRID</th>
                    <th>PRNum</th>
                    <th>PR Date</th>
                    <th>Pirority</th>
                    <th>Department</th>
                    <th>TotalQty</th>
                    <th>CreatedBY</th>                 
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
          </div>
</asp:Content>
