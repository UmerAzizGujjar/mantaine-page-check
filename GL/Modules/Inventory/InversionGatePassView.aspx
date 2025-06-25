<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InversionGatePassView.aspx.cs" Inherits="PMS.Inventory.InversionGatePassView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
 
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "InversionGatePass.aspx?IGP_Id=" + ID;
        }

        function AutoGRN(ID) {
            var IgpId = ID;
            PageMethods.AutoGRN(IgpId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    location.reload();
                }
            });
        }


        function EditGRN(ID) {
            window.location.href = "GRN.aspx?GRN_ID=" + ID;
        }
        function advautogrn(ID) {
            var IgpId = ID;
            PageMethods.AdvAutoGRN(IgpId, function (Tests) {
                debugger
                var message = JSON.parse(Tests);
                if (message[0].Column1 != "" || message[0].Column1 != null) {
                    location.reload();
                }
            });
        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var IgpID = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(IgpID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }



        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "InversionGatePassView.aspx/ViewList",
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
                    { "data": "Igp_Id", "visible": false },
                    { "data": "Igp_num", "name": "Igp_num","orderable": true },
                    {
                        "data": "Igp_date",
                        "render": function (data, type, full) {
                            var date = full.Igp_date;
                            date = moment(date).format(' D-MMM-YYYY');
                            return date;
                        }, "orderable": false
                    },
                    { "data": "VendorName", "orderable": false },
                    { "data": "PONum", "name": "PONum", "orderable": true },
                    { "data": "Remarks", "orderable": false },
                    { "data": "Status", "orderable": false },
                    { "data": "Inspec_Status", "orderable": false },
                    {
                        "render": function (data, type, full) {
                            var inspecstatus = full.Inspec_Status != null ? full.Inspec_Status : "";
                            var btnAutoGRNVisible = 'style="display:none;"';                          
                            if (inspecstatus === "Approved") {
                                console.log("Inspection Status :" + inspecstatus);
                                console.log("IsAuto :" + full.IsAuto);
                                if (full.IsAuto != "True") {
                                    btnAutoGRNVisible = '';
                                }
                            }

                            var actionButtons = '<a href="#" onclick="Edit(' + full.Igp_Id + ')" style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px 4px 11px;">View</a> <a href="#" onclick="AutoGRN(' + full.Igp_Id + ')" ' + btnAutoGRNVisible + ' style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px 4px 11px;" name="btnAutoGRN" id="btnAutoGRN' + full.Igp_Id + '">Auto GRN</a>';
                           

                            return actionButtons;
                        }, "width": "15%", "orderable": false
                    },
                    {
                        "render": function (data, type, full) {
                            var inspecstatus = full.Inspec_Status != null ? full.Inspec_Status : "";    
                            var viewGRNVisible = 'style="display:none;"';

                            if (inspecstatus === "Approved") {
                                console.log("Inspection Status :" + inspecstatus);
                                console.log("IsAuto :" + full.IsAuto);
                                if (full.IsAuto == "True") {
                                    viewGRNVisible = '';
                                }
                            }                           
                            var grnbtn = '<a href="#" id="viewgrn' + full.Igp_Id + '" ' + viewGRNVisible + ' onclick="EditGRN(' + full.Grn_ID + ')" style="border-radius: 4px; background-color: #438eb9 ; color: white; padding: 4px 11px 4px 11px;">View</a>';

                            return grnbtn;
                        }, "orderable": false
                    }
                ],
                     "rowCallback": function (row, data, index) {                  
                    if (data.Status === "Created") {
                        $(row).css('background-color', 'white'); 
                    } else if (data.Status === "Approved") {
                        $(row).css('background-color', '#ABEBC6');
                    } else if (data.Status === "Cancelled") {
                        $(row).css('background-color', 'rgba(251, 181, 181, 0.87)');
                    }
                },
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
 

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12" style="margin-bottom:1%">
                <input type="button" class="btn btn-primry" id="aadnew" value="Add New" onclick="location.href = 'InversionGatePass.aspx';" />
            </div>
    </div>
    <div class="table-container">
        <table class="table table-responsive-lg table-hover table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>
                    <th style="display:none">Igp Id</th>
                    <th>Igp #</th>
                    <th>Igp Date</th>
                    <th>Vendor Name</th>
                    <th>PO #</th>
                    <th>Remarks</th>
                    <th>Status</th>
                    <th>Inspec</th>
                    <th>Actions</th>
                    <th>GRN View</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>


</asp:Content>

