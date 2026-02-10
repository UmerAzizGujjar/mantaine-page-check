<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OPD_Refund_List.aspx.cs" Inherits="PMS.Modules.PatientManagement.OPD_Refund_List" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });
  

   
        function LoadPage() {
            let savedVisibility = null;
            $.ajax({
                type: "POST",
                url: "OPD_Refund_List.aspx/GetUserColumnPreferences",
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
            const table = $("#tblOPDRefund").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'OPD_Refund.aspx';
                        }
                    },
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
                        url: "OPD_Refund_List.aspx/ViewList",
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
                    { "data": "Refund_ID", "visible": false, "width": "0%" },
                    { "data": "OPD_No", "name": "OPD_No", "width": "10%", "orderable": true },
                    { "data": "Full_Name", "width": "10%", "orderable": false },
                    {
                        "data": "Refund_Date", "name": "Refund_Date",
                        "render": function (data, type, full) {
                            var date = full.Refund_Date;
                            return moment(date).format('DD-MMM-YYYY');
                        },
                        "width": "10%",
                        "orderable": true
                    },
                    { "data": "Refund_Amount", "width": "10%", className: "text-right", "orderable": false },
                    { "data": "Hospital_Refund", "name": "Hospital_Refund", "width": "10%", "orderable": false },
                    { "data": "Doctor_Refund", "width": "10%", "orderable": false },
                    { "data": "Remarks", "width": "10%", "orderable": false },
                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="EditOPDRefund(' + full.Refund_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a href="#" class="delListBtn" onclick="cancelRefund(' + full.Refund_ID + ')" style="border-radius: 4px; margin-left: 4px; color: white; background-color: red; padding: 5px 8px; text-decoration: none;"><i class="fa fa-trash"></i></a>';
                            return res + Del;
                        },
                        "width": "10%",
                        "orderable": false
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
                    var lengthContainer = document.querySelector('#tblOPDRefund_length');
                    var lengthDropdown = document.querySelector('#tblOPDRefund_length select');
                    var label = document.querySelector('#tblOPDRefund_length label');

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

        function EditOPDRefund(RefundID) {
            debugger;
            window.open("OPD_Refund.aspx?RefundID=" + RefundID);
        }


        function cancelRefund(RefundID) {
            Swal.fire({
                title: 'Are you sure?',
                text: 'Do you want to cancel this OPD Refund?',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonText: 'Yes, cancel it!',
                cancelButtonText: 'No, keep it',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "OPD_Refund_List.aspx/CancelRefund",
                        data: JSON.stringify({ RefundID: RefundID }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            var resultText = response.d;
                            if (resultText && resultText.startsWith("Error")) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Failed!',
                                    text: resultText,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            } else {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Canceled!',
                                    text: 'The OPD Refund has been canceled.',
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                                $('#tblOPDRefund').DataTable().ajax.reload();
                            }
                        },
                        error: function (xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'AJAX call failed. Check console.',
                                timer: 2000
                            });
                            console.error("Cancel Refund error:", error, xhr.responseText);
                        }
                    });
                }
            });
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div>
    <table id="tblOPDRefund" class="table table-hover table-striped table-bordered">
        <thead>
              <tr>
                 <th>Refund_ID</th>
                 <th>OPD No</th>
                 <th>Full_Name</th>
                 <th>Refund Date</th>
                 <th>Refund_Amount</th>
                 <th>Hospital Refund</th>
                 <th>Doctor Refund</th>
                 <th>Remarks</th>
                 <th>Action</th>
             </tr>
        </thead>
           
         </table>
</div>

</asp:Content>
