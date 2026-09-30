<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="OutPatientsView.aspx.cs" Inherits="PMS.WebForm12" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">


        $(document).ready(function () {
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });

        function PrintoutPatient(Out_Patient_ID) {
            var url = '../../ReportViewer.aspx?ReportName=OutPatient&Title=Out Patient Report&outPatientID=' + Out_Patient_ID;
            window.open(url, '_blanks');
        }


        function Edit(id) {
            var newWin = window.open('', '_blank');
            $.ajax({
                type: "POST",
                url: "OutPatientsView.aspx/GetOutPatientNewFormRedirectPermission",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = JSON.parse(response.d);
                    var url = result.useNewForm
                        ? "NewOutPatient.aspx?ID=" + id
                        : "OutPatients.aspx?ID=" + id;
                    if (newWin) {
                        newWin.location.href = url;
                    } else {
                        window.open(url, '_blank');
                    }
                },
                error: function () {
                    if (newWin) newWin.close();
                    window.open("NewOutPatient.aspx?ID=" + id + "");
                }
            });
        }

        function deleteConfirm(anchorTag) {
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


        function PrintVoucher(id) {

            var locationInfo = window.location;
            var url = '../../ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' + id + '&TransType=OPDShare';

            if (!locationInfo.origin.includes('localhost') || locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername +
                    '/ReportViewer.aspx?ReportName=Voucher&ReportTitle=OPD Voucher&TransID=' +
                    id + '&TransType=OPDShare';
            }

            window.open(url, '_blank');
        }



        function LoadPage() {
            let savedVisibility = null;

            $.ajax({
                type: "POST",
                url: "OutPatientsView.aspx/GetUserColumnPreferences",
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
            const table = $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () {
                            window.location = '/Modules/PatientManagement/NewOutPatient.aspx';
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
                            var date = full.Created_Time;
                            return moment(date).format('DD-MMM-YYYY');
                        },
                        "width": "10%"
                    },
                    {
                        render: function (data, type, full) {

                            var res = '<a href="#" class="editListBtn" onclick="Edit(' + full.Out_Patient_ID + ')" style="border-radius:4px;margin-right:4px;padding:5px 8px;"><i class="fa fa-pencil"></i></a>';
                            var Del = '<a class="delListBtn" href="#" data-id="' + full.Out_Patient_ID + '" onclick="deleteConfirm(this)" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;"><i class="fa fa-trash"></i></a>';
                            var print = '<a class="printListBtn" href="#" onclick="PrintoutPatient(' + full.Out_Patient_ID + ')" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px;"><i class="fa fa-print"></i></a>';
                            var voucher = "";
                            if (full.Status === "Approved") {
                                voucher = '<a class="printListBtn" href="#" onclick="PrintVoucher(' + full.Out_Patient_ID + ')" title="Print Voucher" style="border-radius:4px;margin-left:4px;color:black;padding:5px 8px;"><i class="fa fa-money"></i></a>';
                            }
                            return res + Del + print + voucher;
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
