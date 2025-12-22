<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OutPatientsView.aspx.cs" Inherits="PMS.WebForm12" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">


        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function PrintoutPatient(Out_Patient_ID) {
            debugger;
            var url = '../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + Out_Patient_ID;
            window.open(url, '_blanks');
        }


        function Edit(id) {
            window.open("NewOutPatient.aspx?ID=" + id + "");
        }

        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];
            var OutPatientID = $(anchorTag).data('id');

            if (confirm('Are you sure you want to delete this record?')) {
                PageMethods.DeleteRecord(OutPatientID, function (msg) {
                    if (msg === "Delete") {
                        $(row).remove();
                    } else {
                        alert("This Patient is in Billing Process");
                    }
                }, function (error) {
                    console.error(error);
                    alert("An error occurred while deleting the record.");
                });
            }
        }



        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [{ text: 'Add', className: 'dt-button buttons-copy buttons-html5', action: function () { window.location = 'NewOutPatients.aspx'; } }, 'copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "OutPatientsView.aspx/ViewList",
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
                    { "data": "Out_Patient_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%" },
                    { "data": "Full_Name", "width": "15%", "orderable": false },
                    { "data": "Father_Name", "width": "15%", "orderable": false },
                    { "data": "Category", "width": "20%", "orderable": false },
                    { "data": "Mobile1", "width": "10%", "orderable": false },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%"
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Out_Patient_ID + ')" style="border-radius: 4px;margin-right: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Out_Patient_ID + '" onclick="deleteConfirm(this)"><i class="fa fa-trash" ></i></a>';

                            var print = '<a class="printListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" onclick="PrintoutPatient(' + full.Out_Patient_ID + ')" id="btnprint"><i class="fa fa-print" ></i></a>';
                            var result;
                            result = res + Del+ print;
                            return result;
                        }, "width": "10%", "orderable": false
                    }

                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblResult_length');
                    var lengthDropdown = document.querySelector('#tblResult_length select');
                    var label = document.querySelector('#tblResult_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        label.innerHTML = 'Show entries ';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '15px';

                        lengthDropdown.style.marginLeft = '5px';
                        lengthDropdown.style.marginTop = '-13px';

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
    <div id="OutPatdetails" >

        <div class="row">
            
            <div class="table-container col-lg-12 col-md-12 col-sm-10" style="margin-top: 15px;">
                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                    <thead id="ihead">
                        <tr>
                            <th style="display: none; width: 0%;">OPD ID</th>
                            <th>MR No.</th>
                            <th>Full_Name</th>
                            <th>Father_Name</th>
                            <th>Category</th>
                            <th>Mobile#</th>
                            <th>Created_Time</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
