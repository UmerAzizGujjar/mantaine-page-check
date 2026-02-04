<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="InPatientsDischargeList.aspx.cs" Inherits="PMS.InPatientsDischargeList" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function InpatientDischargePrint(In_Patient_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=DischargePrint&InPatientId=' + In_Patient_ID;
            window.open(url, '_blank');

        }


        function LoadPage() {
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
                            window.location = 'InPatientsDischarge.aspx';
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
                        url: "InPatientsDischargeList.aspx/ViewList",
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
                    { "data": "In_Patient_ID", "visible": false, "width": "0%" },
                    {
                        "data": "Admission_Date", "name": "Admission_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Admission_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "8%", "orderable": false
                    },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "8%", "orderable": true },
                    { "data": "Full_Name", "width": "12%", "orderable": false },
                    { "data": "Father_Name", "width": "12%", "orderable": false },
                    { "data": "Patient_Type", "name": "Patient_Type", "width": "10%", "orderable": true },
                    { "data": "Department", "name": "Department", "width": "10%", "orderable": true },
                    
                    {
                        "data": "Discharge_On", "name": "Discharge_On",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Discharge_On;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": true
                    },
                    { "data": "Discharge_By", "name": "Discharge_By", "width": "15%", "orderable": true },
                    { "data": "AdmitDays", "name": "AdmitDays", "width": "8%", "orderable": true },
                    
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="editOpen(' + full.In_Patient_ID + ')" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            /* var Del = '<a href="#" style="border-radius: 4px; background-color: #ad170c;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';*/

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="InpatientDischargePrint(' + full.In_Patient_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + print;
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

        function editOpen(id) {

            
            window.open("InPatientsDischarge.aspx?ID=" + id + "");

        }
    
        function deleteConfirm(anchorTag) {
            debugger;
            var table = $('#tblResult').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var In_PatientID = rowData.In_Patient_ID;
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(In_PatientID, function (msg) {
                    if (msg == "Delete") {
                        table.row(row).remove().draw();
                    } else {
                        alert("This Patient is in Billing Process");
                    }
                });
            }
        }
       
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="POdetails">
        <div>
            <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                <thead id="ihead">
                    <tr>
                        <th>In_Patient_ID</th>
                        <th>Admission Date</th>
                        <th>MR No #</th>
                        <th>Patient Name</th>
                        <th>Father / Husband Name</th>
                        <th>Patient Category</th>
                        <th>Department.</th>
                        <th>Discharge Date</th>
                        <th>Discharge By</th>
                        <th>Days Occupied</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
        </div>
    </div>

</asp:Content>
