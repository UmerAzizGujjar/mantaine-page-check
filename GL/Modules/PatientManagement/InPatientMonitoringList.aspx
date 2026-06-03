<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientMonitoringList.aspx.cs" Inherits="PMS.InPatientMonitoringList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function AddPrint(InPatient_Mon_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=InPatientMonitoring&ReportTitle=Clinical Summary Report' + '&In_Patient_ID=' + InPatient_Mon_ID;
            window.open(url, '_blank');
           
        }
   

        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "InPatientMonitoringList.aspx/GetUserColumnPreferences",
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
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'InPatientMonitoring.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',
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
                        url: "InPatientMonitoringList.aspx/ViewList",
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
                    { "data": "InPatient_Mon_ID", "visible": false, "width": "0%" },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "12%", "orderable": true },
                    { "data": "Full_Name", "width": "20%", "orderable": false },
                    { "data": "Father_Name", "width": "20%", "orderable": false },                   
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#"  class="editListBtn"  onclick="Edit(' + full.InPatient_Mon_ID + ')" style="border-radius: 4px;  color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="AddPrint(' + full.InPatient_Mon_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';

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
                    }
                }
            });
        }

        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];


            var InvID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(InvID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }

        function Edit(ID) {
            window.location.href = "InPatientMonitoring.aspx?ID=" + ID;

        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="IpMonitoring" style="margin-top: 15px;">
        <table class="table table-hover table-striped table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>                    
                    <th>In-Patient Monitoring Id</th>
                    <th>MR No</th>                                            
                    <th>Patient Name</th>                                            
                    <th>Father Name</th>                                            
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
       </div>
    </div>

</asp:Content>
