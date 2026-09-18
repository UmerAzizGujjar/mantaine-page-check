<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MRNoLookup.aspx.cs" Inherits="PMS.Modules.Administrator.MRNoLookup" %>

<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <script type="text/javascript" src="../../wwwroot/THEME_TIBBIT/js/swalalert.js"></script>

    <style type="text/css">
        .mr-card {
            max-width: 1200px;
            margin: 0 auto;
        }

        .mr-search-box {
            max-width: 480px;
            margin: 0 auto 20px auto;
        }

        #tblPatient th {
            white-space: nowrap;
        }
    </style>

    <script type="text/javascript">
        var mrTable;

        $(document).ready(function () {
            mrTable = $('#tblPatient').DataTable({
                "paging": true,
                "pageLength": 10,
                "lengthMenu": [10, 25, 50, 100],
                "searching": true,
                "ordering": true,
                "info": true,
                "order": [[0, 'asc']],
                "language": {
                    "emptyTable": "No record found"
                },
                "columns": [
                    { "data": "MRNo", "defaultContent": "" },
                    { "data": "Full_Name", "defaultContent": "" },
                    { "data": "Father_Name", "defaultContent": "" },
                    { "data": "Gender", "defaultContent": "" },
                    { "data": "Age", "defaultContent": "" },
                    { "data": "Mobile", "defaultContent": "" },
                    { "data": "NIC", "defaultContent": "" },
                    { "data": "Blood_Group", "defaultContent": "" },
                    { "data": "Address", "defaultContent": "" }
                ]
            });

            $('#txtMRNo').on('keypress', function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    SearchMR();
                }
            });
        });

        function SearchMR() {
            var mrNo = $('#txtMRNo').val().trim();

            if (mrNo === '') {
                Swal.fire({
                    icon: 'warning',
                    title: 'Required',
                    text: 'Please enter MR No Seq.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            $('#btnSearch').prop('disabled', true).val('Searching...');

            $.ajax({
                type: "POST",
                url: "MRNoLookup.aspx/SearchByMRNo",
                data: JSON.stringify({ mrNo: mrNo }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var list = response.d || [];
                    mrTable.clear();
                    mrTable.rows.add(list);
                    mrTable.draw();

                    if (list.length === 0) {
                        Swal.fire({
                            icon: 'info',
                            title: 'Not Found',
                            text: 'No patient found in National Hospital for MR No Seq: ' + mrNo,
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    console.log("XHR:", xhr);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to fetch data from National Hospital database.',
                        showConfirmButton: true,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                },
                complete: function () {
                    $('#btnSearch').prop('disabled', false).val('Search');
                }
            });
        }
    </script>
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div class="row">
        <div class="col-lg-12">
            <div class="card mr-card">
                <div class="card-body">
                    <h2 style="text-align: center; margin-bottom: 20px;">MR No Lookup - National Hospital</h2>
                    <p style="text-align: center; color: #888; margin-bottom: 20px;">
                        Read-only search of patient records from the <strong>H_P_National_Hospital</strong> database.
                    </p>

                    <div class="mr-search-box">
                        <div class="label-field">
                            <label for="txtMRNo" style="font-size: 16px;">MR No Seq:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="text" id="txtMRNo" name="txtMRNo" class="textEntry" style="border-radius: 10px !important;" placeholder="e.g. NH-43362" />
                        </div>
                    </div>

                    <div style="text-align: center; margin-bottom: 20px;">
                        <input class="btn-primry" type="button" id="btnSearch" value="Search" onclick="SearchMR()" style="border-radius: 50px; width: 170px;" />
                    </div>

                    <div class="table-container">
                        <table id="tblPatient" class="table table-bordered table-striped" style="width: 100%;">
                            <thead>
                                <tr>
                                    <th>MR No</th>
                                    <th>Patient Name</th>
                                    <th>Father Name</th>
                                    <th>Gender</th>
                                    <th>Age</th>
                                    <th>Mobile</th>
                                    <th>NIC</th>
                                    <th>Blood Group</th>
                                    <th>Address</th>
                                </tr>
                            </thead>
                            <tbody></tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
