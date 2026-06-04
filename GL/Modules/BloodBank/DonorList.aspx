<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DonorList.aspx.cs" Inherits="PMS.DonorList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/lib/sweetalert/tablestyle.css" rel="stylesheet" />

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
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "DonorList.aspx/GetUserColumnPreferences",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: false,
                success: function (response) {
                    if (response.d && response.d !== "") {
                        try {
                            savedVisibility = JSON.parse(response.d);
                        } catch (e) {
                            console.warn("Invalid column visibility JSON");
                        }
                    }
                },
                error: function () {
                    console.error("Failed to load column preferences");
                }
            });

            $("#tblDonorList").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf',
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
                        url: "DonorList.aspx/ViewList",
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
                    { "data": "Donor_Id", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "width": "10%", "orderable": false },
                    { "data": "Donor_Name", "name": "Donor_Name", "width": "10%", "orderable": false },
                    {
                        "data": "D_Date", "name": "D_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.D_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    { "data": "Donor_Address", "name": "Donor_Address", "width": "10%", "orderable": false },
                    { "data": "D_Cell", "name": "D_Cell", "width": "10%", "orderable": false },
                    { "data": "ABO", "name": "ABO", "width": "10%", "orderable": false },
                    { "data": "RH_Type", "name": "RH_Type", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Donor_Id + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="prints(' + full.Donor_Id + ')" id="btnprint"><i class="fa fa-print"></i></a>';

                            var result;
                            result = res + print;
                            return result;
                        }, "width": "10%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    const api = this.api();
                    if (savedVisibility && Array.isArray(savedVisibility)) {
                        if (savedVisibility.length === api.columns().count()) {
                            api.columns().every(function (index) {
                                this.visible(savedVisibility[index]);
                            });
                        }
                    }
                    api.on('column-visibility.dt', function (e, settings, column, state) {
                        let currentVis = [];
                        api.columns().every(function () {
                            currentVis.push(this.visible());
                        });
                        PageMethods.SaveUserColumnPreferences(
                            JSON.stringify(currentVis),
                            function () {
                                console.log("Column preferences saved");
                            },
                            function (error) {
                                console.error("Failed to save preferences:", error);
                            }
                        );
                    });

                    var lengthContainer = document.querySelector('#tblDonorList_length');
                    var lengthDropdown = document.querySelector('#tblDonorList_length select');
                    var label = document.querySelector('#tblDonorList_length label');

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
                    }
                }
            });
        }

        function Edit(ID) {
            window.location.href = "Donors.aspx?ID=" + ID;
        }


        function Delete(anchorTag) {
            debugger;

            var row = $(anchorTag).parents('tr')[0];
            var id = $($(row).find('td')[0]).text();
            if (confirm('Are you sure want to Cancel Donor No:- ' + id)) {
                PageMethods.CancelPatient(id, function (msg) {

                    if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this Donor, because Bag against this donor is Saved  ')
                    }
                }

                )
            }

            //window.location.href = "PatientsView.aspx";
        }


    </script>



</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    


    <div class="table-container">
    <div class="table-responsive-custom">
        <table id="tblDonorList" class="table table-bordered table-striped">
            <thead>
                <tr>
                    <th style="display:none">Donor Id</th>
                    <th>MR No</th>
                    <th>Patient Name</th>
                    <th>Donor Name</th>
                    <th>Donation Date</th>
                    <th>Address</th>
                    <th>Phone No</th>
                    <th>Blood Group</th>
                    <th>RH Type</th>
                    <th>Actions</th>
                </tr>
            </thead>
            </table>
        </div>
        </div>

</asp:Content>
