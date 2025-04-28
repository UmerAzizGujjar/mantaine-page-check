<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PatientsView.aspx.cs" Inherits="PMS.PatientsView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function editOpen(id) {

            window.open("Patients.aspx?ID=" + id + "");
        }

        function cancelPatient(patid , patname) {
            debugger;
            var PatID = patid;
            var PatNo = patname;

            if (confirm('Are you sure want to Cancel Mr No:- ' + PatNo )) {
                PageMethods.CancelPatient(PatID, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept and Bills ')
                    }
                },


                    );
            }

            window.location.href = "PatientsView.aspx";
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
                        url: "PatientsView.aspx/ViewList",
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
                    { "data": "Patient_ID", "visible": false, "width": "0%" },
                    { "data": "mr_no_sequence", "width": "12%" },
                    { "data": "Opd_No", "width": "5%" },
                    { "data": "Full_Name", "width": "15%" },
                    { "data": "Patient_Type", "width": "5%" },
                    { "data": "Department", "width": "10%" },
                    { "data": "NIC", "width": "16%" },
                    { "data": "Mobile1", "width": "10%" },
                    { "data": "Age", "width": "5%" },
                    { "data": "Doctor_Id", "width": "10%" },
                    {
                        "data": "Created_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Created_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "15%"
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a href="#" onclick="editOpen(' + full.Patient_ID + ')" style="border-radius: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil"></i></a>'
                            var print = '<a style="border-radius: 4px;background-color:#ad170c;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Patient_ID + '" onclick="cancelPatient( ' + full.Patient_ID + ', \'' + full.Full_Name + '\')"><i class="fa fa-trash"style="color:white !important;"></i></a>';

                            var result;
                            result = res + print;
                            return result;
                        }, "width": "100%"
                    }

                ]
            });
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="POdetails" style="margin-top: 15px;">    

        <div class="container">
            <div class="row">
                <div class="table-container col-lg-12 col-md-12 col-sm-10" style="overflow: scroll">
                    <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                        <thead id="ihead">
                            <tr>
                                <th style="display: none;">Patient ID</th>                           
                                <th>MR No</th>
                                <th>OPD</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Department</th>
                                 <th>CNIC</th>
                                 <th>Mobile</th>
                                 <th>Age</th>
                                 <th>Doctor</th>
                                <th>Date</th>                                
                                <th>Actions</th>                            
                            </tr>
                        </thead>
                        <tbody id="ibody">
                        </tbody>
                    </table>


                </div>
            </div>

        </div>

    </div>

</asp:Content>
