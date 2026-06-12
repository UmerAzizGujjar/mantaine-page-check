<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IPDMedicineHistory.aspx.cs" Inherits="PMS.Modules.Billing.IPDMedicineHistory" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        LoadPage();
    });

    function LoadPage() {
        let savedVisibility = null;
        $.ajax({
            type: "POST",
            url: "IPDMedicineHistory.aspx/GetUserColumnPreferences",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: false,
            success: function (response) {
                if (response.d && response.d !== "") {
                   try {
                        savedVisibility = JSON.parse(response.d);
                    }
                    catch (e) {
                        console.warn("Invalid column visibility JSON");
                    }
                }
            },
            error: function () {
                console.error("Failed to load column preferences");
            }
        });
        $("#tbl").DataTable({

            "processing": true,
            "serverSide": true,
            "destroy": true,
            "filter": true,
            "lengthChange": true,

            "dom": 'lBfrtip',

            buttons: [
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

            "ajax": function (data, callback, settings) {

                $.ajax({
                    type: "POST",
                    url: "IPDMedicineHistory.aspx/ViewList",

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
                {
                    "data": "In_Patient_Medicine_ID", "visible": false,"width": "0%"
                },
                {
                    "data": "Medicine_Date", "name": "Medicine_Date", "render": function (data, type, full) {
                        if (full.Medicine_Date != null) {
                            return moment(full.Medicine_Date).format('DD-MMM-YYYY');
                        }
                        return '';
                    },
                    "width": "8%",
                    "orderable": true
                },
                {
                    "data": "mr_no_sequence", "name": "mr_no_sequence","width": "6%",
                    "orderable": true
                },
                {"data": "Full_Name","name": "Full_Name", "width": "8%", "orderable": true},
                {"data": "Father_Name","width": "8%","orderable": false },
                { "data": "Ward_Name", "width": "8%", "orderable": false },
                { "data": "Medicine_Name", "width": "12%", "orderable": false },
                { "data": "Bed_No","width": "6%", "orderable": false },
                { "data": "Rcv_Qty", "width": "6%", "orderable": false },
                { "data": "Req_Qty", "width": "6%", "orderable": false },
                { "data": "Rtn_Qty", "width": "6%", "orderable": false },
                {
                    render: function (data, type, full) {
                        var btn =
                            '<a href="#" class="btn btn-primary btn-sm" onclick="ViewDetails(' + full.In_Patient_Medicine_ID + ')">' +
                            '<i class="fa fa-eye"></i></a>';

                        return btn;
                    },
                    "width": "6%",
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

                var lengthContainer = document.querySelector('#tbl_length');
                var lengthDropdown = document.querySelector('#tbl_length select');
                var label = document.querySelector('#tbl_length label');

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

    function ViewDetails(id) {

        alert("Selected Medicine ID : " + id);

        // window.location.href = "IPDMedicineDetail.aspx?ID=" + id;
    }

</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
    <div class="table-container">
        <table id="tbl" class="table table-bordered table-hover table-striped">
            <thead id="ihead">
                <tr>
                    <th style="display:none;">Medicine_ID</th>
                    <th>Medicine Date</th>
                    <th>MR No</th>
                    <th>Patient Name</th>
                    <th>Father Name</th>
                    <th>Ward</th>
                    <th>Medicine Name</th>
                    <th>Bed No</th>
                    <th>Receive Qty</th>                
                    <th>Request Qty</th>
                    <th>Return Qty</th>
                    <th>View</th>
                </tr>
            </thead>
            <tbody id="tbody">
            </tbody>
        </table>
    </div>
</div>
</asp:Content>

