<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EmergencyCaseView.aspx.cs" Inherits="PMS.EmergencyCaseView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });


        function PrintEmergencyPatient(Emergency_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=Emergencypatient&Title=Emergency Patient Report&Emergency_ID=' + Emergency_ID;
             window.open(url, '_blank');
         }

        function LoadPage() {
            var table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = 'EmergencyCase.aspx';
                        }
                    },
                    'copy', 'excel', 'pdf',                 
                ],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "EmergencyCaseView.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            filterStatus: $('#filterStatus').val()
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
                    { "data": "Emergency_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%" },
                    { "data": "Full_Name", "width": "18%", "orderable": false },
                    { "data": "Father_Name", "width": "18%", "orderable": false },
                    {
                        "data": "Admission_Date", "name": "Admission_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Admission_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%", "orderable": false
                    },
                    {
                        "data": "Discharge_On", "name": "Discharge_On",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Discharge_On;
                            if (!date) {
                                return ""; 
                            }
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        },
                        "width": "10%"
                    },

                    { "data": "AdmitDays", "width": "10%", "orderable": false },
                    {
                        "data": "Patinet_Condition","width": "10%", "orderable": false, "render": function (data, type, full) {
                            if (data === "Urgent") {
                                return "Short Stay";
                            }
                            else if (data === "Non Urgent") {
                                return "OPD";
                            }
                            else {
                                return data;
                            }
                        }
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="editOpen(' + full.Emergency_ID + ')" class="editListBtn" style="border-radius: 4px; color: white; padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" href="#" style="border-radius: 4px;margin-left: 4px; color: white; padding: 5px 8px 5px 8px;" onclick=deleteConfirm(this)><i class="fa fa-trash" aria-hidden="true"></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintEmergencyPatient(' + full.Emergency_ID + ')" id="btnprint"><i class="fa fa-print"></i></a>';
                            var result;
                            result = res +Del + print;
                            return result;
                        }, "width": "15%", "orderable": false
                    }

                ],
                "createdRow": function (row, data, dataIndex) {
                    if (data.AdmitDays >= 1 && (data.Discharge_ON == null || data.Discharge_ON === "")) {
                        $(row).css({
                            "background-color": "#f8d7da",
                           // "color": "#721c24",
                            "font-weight": "bold"
                        });
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
            $('#filterStatus').on('change', function () {
                table.ajax.reload();
            });
        }



        function editOpen(id) {
            window.open("EmergencyCase.aspx?ID=" + id + "");
        }

        function deleteConfirm(anchorTag) {
            debugger;
            var table = $('#tblResult').DataTable();
            var row = $(anchorTag).closest('tr');
            var rowData = table.row(row).data();
            var Emergency_PatientID = rowData.Emergency_ID;
            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(Emergency_PatientID, function (msg) {
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
    <div class="row">
        <div class="col-lg-1 col-md-4 col-sm-6">
    <select id="filterStatus" class="form-control" >
        <option value="">All</option>
        <option value="Admitted">Admitted</option>
        <option value="Discharged">Discharged</option>
    </select>
            </div>
        </div>
    <div class="row">
         <div class="col-lg-12 col-md-12 col-sm-12">
    <table style="width: 100%;">
        <tr>
            <td>
                <div id="POdetails" style="margin-top: 15px;">
                    <div>
                        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                            <thead id="ihead">
                                <tr>
                                    <th>Admission Date</th>
                                    <th>MR No.</th>
                                    <th>Patient Name</th>
                                    <th>Father/Husband Name</th>
                                    <th>Admission Date</th>
                                    <th>Discharge Date</th>
                                    <th>No Of Days</th>
                                    <th>Patient Type</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="ibody">
                            </tbody>
                        </table>
                    </div>
                </div>
            </td>
        </tr>
    </table>
        </div>
        </div>
</asp:Content>
