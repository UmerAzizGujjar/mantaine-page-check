<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonorReceivingList.aspx.cs" Inherits="PMS.DonorReceivingList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function prints(Donor_Id) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=BasePrintDonor&ReportTitle=Department Of Pathology&Donor_ID=' + Donor_Id;
            window.open(url, '_blank');

        }

        function LoadPage() {
            $("#tblDonorReceivingList").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "DonorReceivingList.aspx/ViewList",
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
                    { "data": "Blood_Division_Id", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Donor_No", "name": "Donor_No", "width": "10%", "orderable": true },
                    { "data": "donor_name", "name": "donor_name", "width": "10%", "orderable": false },
                    { "data": "Bag_Number", "name": "Bag_Number", "width": "10%", "orderable": false },
                    { "data": "Whole_Blood", "name": "Whole_Blood", "width": "10%", "orderable": false },



                    {
                        "data": "WholeBlood_Expiry", "name": "WholeBlood_Expiry",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.WholeBlood_Expiry;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    {
                        "data": "PCVExpiry", "name": "PCVExpiry",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.PCVExpiry;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%","orderable": true
                    },
                    {
                        "data": "FFPsExpiry", "name": "FFPsExpiry",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.FFPsExpiry;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": false
                    },
                    {
                        "data": "Platelets_Expiry", "name": "Platelets_Expiry",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Platelets_Expiry;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "6%", "orderable": false
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Blood_Division_Id + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'


                            var result;
                            result = res;
                            return result;
                        }, "width": "5%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblDonorReceivingList_length');
                    var lengthDropdown = document.querySelector('#tblDonorReceivingList_length select');
                    var label = document.querySelector('#tblDonorReceivingList_length label');

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


        function Delete(anchorTag) {
            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var id = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to Delete:- ' + id)) {
                PageMethods.DeleteStock(id, function (msg) {

                    if (msg == true) {

                        row.remove();
                    }

                }

               )
            }


        }

        function Edit(ID) {
            window.location.href = "DonorReceivingForm.aspx?ID=" + ID;
        }

    </script>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row table-container">
            
        <table class="table table-bordered" id="tblDonorReceivingList">
            <thead>
                <tr>
                    <th>Blood Processing #</th>
                    <th>Donor #</th>
                    <th>Donor Name</th>
                    <th>Bag No</th>
                    <th>Whole Blood</th>
                    <th>Whole Blood Expiry</th>
                    <th>PCV's Expiry</th>
                    <th>FFP's Expiry</th>
                    <th>Platelets Expiry</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
    
</asp:Content>

