<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorAppointment.aspx.cs" Inherits="PMS.DoctorAppointment" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .pagination-container {
            margin-top: 10px;
            text-align: right;
        }

        .page-link {
            display: inline-block;
            margin: 0 5px;
            padding: 5px 10px;
            border: 1px solid #ddd;
            cursor: pointer;
            color: #007bff;
        }

            .page-link:hover {
                background-color: #f1f1f1;
            }

            .page-link.active {
                background-color: #007bff;
                color: white;
                border-color: #007bff;
            }
    </style>
    <script type="text/javascript">



        $(document).ready(function () {
            loaddoctor();
            var date = '<%= DateTime.Now%>';
            $("#txt_dateto").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_dateto").val(date);



            $("#txt_datefrom").datepicker({ dateFormat: 'mm/dd/yy', changeMonth: true, changeYear: true, yearRange: "-50:+50" }).attr('readonly', 'readonly');
            date = moment(date).format('L');
            $("#txt_datefrom").val(date);


            var checkeditmode_startdate = '<%= Request.QueryString["stDate"]%>';

            var checkeditmode_enddate = '<%= Request.QueryString["endDate"]%>';


            if (checkeditmode_startdate != '') {

                $('#txt_datefrom').val(checkeditmode_startdate);
            }

            if (checkeditmode_enddate != '') {

                $('#txt_dateto').val(checkeditmode_enddate);
            }
            $('#btnSearch').click(function () {
                getpage();


            });

        });
        function toTitleCase(str) {
            return str.replace(/[^a-zA-Z0-9]+(.)/g, function (match) {
                return match.toUpperCase();
            });
        }
        function getpage() {            debugger;            var stDate = $('#txt_datefrom').val() || "";            var endDate = $('#txt_dateto').val() || "";            var doc_id = $('#chk_Doc').find('option:selected').val();            if (doc_id == "0") {                stDate = "";                endDate = "";            }            PageMethods.getlist(stDate, endDate, doc_id, function (data) {                debugger;                if (data.length === 0) {                    $("#table_res tbody").empty();                    $("#pagination").empty(); // Clear pagination if no data                    return false;                }                var parsedData = JSON.parse(data);                const rowsPerPage = 10;  // Adjust this value as needed                let currentPage = 1;                function displayTable(page) {                    $('#t_body').empty();                    const start = (page - 1) * rowsPerPage;                    const end = start + rowsPerPage;                    const paginatedData = parsedData.slice(start, end);                    let rows = '';                    paginatedData.forEach((item, i) => {                        var App_Date = moment(item.App_Date).format('LL');                        var time = moment(item.Time).format('h:mm a');                        rows += `<tr>                            <td>${start + i + 1}</td>                            <td>${item.Appointment_No}</td>                            <td>${toTitleCase(item.Patient_Name.replace("_", " "))}</td>                            <td>${item.emp_name}</td>                            <td>${App_Date}</td>                            <td>${time}</td>                            <td>${item.Status}</td>                         </tr>`;                    });                    $('#t_body').html(rows);                    applyRowStyles();                }                function applyRowStyles() {                    $('#t_body tr').each(function () {                        var status = $(this).find('td:eq(6)').text();                        if (status === "Visited") {                            $(this).css('background-color', 'rgba(26, 255, 26, 0.44)');                        } else if (status === "Not Visited") {                            $(this).css('background-color', '#ff7c7c69');                        }                    });                }                function setupPagination(totalRows) {                    const totalPages = Math.ceil(totalRows / rowsPerPage);                    let paginationHTML = '';                    for (let i = 1; i <= totalPages; i++) {                        paginationHTML += `<span class="page-link" data-page="${i}">${i}</span>`;                    }                    $('#pagination').html(paginationHTML);                    $('.page-link').on('click', function () {                        currentPage = $(this).data('page');                        displayTable(currentPage);                    });                }                setupPagination(parsedData.length);                displayTable(currentPage);            });            return false;        }


        var Doctors;
        var options;
        function loaddoctor() {
            PageMethods.LoadDoctor(function (res) {
                var doctor = JSON.parse(res);

                var rowsText = '';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                Doctors = options

                $('#ddl_colstnt').html(options).trigger('change');

                $('#chk_Doc').html(options).select2().trigger('change');
                $('#chk_Doc').attr('disabled', true);

            });
        }

        function ddldocchange() {
            debugger;
            var DocChk = $('#chk_Doc').find('option:selected').text();
            getpage();
            if (DocChk == "Select Doctor") {
                acc = true;

            }
            else {
                var tbl = document.getElementById('table_res');
                if (DocChk.trim() != '') {

                    for (var i = 1; i < tbl.rows.length; i++) {
                        if (tbl.rows[i].cells[3].innerText != DocChk) {
                            var row = tbl.rows[i];
                            row.style.display = 'none';
                        }
                        else {
                            var row = tbl.rows[i];
                            row.style.display = '';
                        }
                    }
                }
                else {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }
                }
            }

        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>Doctor</label>
            <select id="chk_Doc" onchange="ddldocchange()">
            </select>
        </div>

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>From</label>
            <input type="text" id="txt_datefrom" />
        </div>

        <div class=" col-lg-3 col-md-6 col-sm-12">
            <label>To</label>
            <input type="text" id="txt_dateto" />
        </div>

        <div class=" col-lg-2 col-md-6 col-sm-12">
            <input type="button" id="btnSearch" class="btn btn-primry mar-btn" style="top: 26px;" value="Search" />
        </div>
    </div>

    <div class="table-container">
        <table class="table table-hover table-striped table-bordered" id="table_res">
            <tr id="row_sample">
                <th>S No.</th>
                <th>APPT NO</th>
                <th>PATIENT NAME</th>
                <th>DOCTOR NAME</th>
                <th>DATE</th>
                <th>TIME</th>
                <th>STATUS</th>
            </tr>
            <tbody id="t_body"></tbody>
        </table>
    </div>
    <!-- Pagination Controls -->
    <div id="pagination" class="pagination-container"></div>




</asp:Content>
