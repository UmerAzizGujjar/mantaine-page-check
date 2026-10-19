<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddCompany.aspx.cs" Inherits="PMS.Modules.Administrator.AddCompany" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .table_card table.dataTable thead > tr > th.sorting_desc::after {
            content: "▼";
            color: #000;
            position: absolute;
            top: 50%;
            right: 8px;
            transform: translateY(-50%);
        }

        .table_card .dataTable > thead > tr > th.sorting_desc,
        .table_card .dataTable > thead > tr > th.sorting_asc {
            background-repeat: repeat-x;
            background-image: linear-gradient(to bottom, #EFA63E 0, #EFA63E 100%) !important;
        }

        .table_card table.dataTable thead > tr > th.sorting_asc:before,
        .table_card table.dataTable thead > tr > th.sorting_desc:after,
        .table_card table.dataTable thead > tr > td.sorting_asc:before,
        .table_card table.dataTable thead > tr > td.sorting_desc:after {
            opacity: 1 !important;
            color: white;
        }

        .table_card #tblResult {
            width: 100% !important;
        }

        .table_card .dataTables_filter label {
            display: flex;
            align-items: center;
            background: white;
            padding: 0px 10px;
            width: 300px;
        }

        .table_card .dataTables_filter input {
            border: none;
            outline: none;
            padding: 8px 12px;
            flex-grow: 1;
            border-radius: 3px !important;
        }

        .table_card .dataTables_filter label::before {
            content: "\1F50D";
            font-size: 16px;
            margin-right: 8px;
            color: #888;
        }

        .table_card .dataTables_filter input::placeholder {
            color: #aaa;
            font-style: italic;
        }

        .table_card .dataTables_wrapper .dataTables_length select {
            border-radius: 3px;
            padding: 5px;
            background-color: transparent !important;
            padding: 0px !important;
            height: 40px !important;
        }

        .table_card .dataTables_filter {
            margin-top: 16px;
        }

        .table_card .table > tbody > tr > td {
            line-height: 0.75;
        }

        .table_card .table > thead > tr > th {
            line-height: 1.0;
        }

        .table_card .dataTables_wrapper .dataTables_paginate {
            font-size: small;
            width: 50%;
        }

        .table_card .mrg {
            margin-left: 11px !important;
        }

        .table_card .table th:hover {
            background-color: #EFA63E !important;
            color: black !important;
        }

        .table_card .main input {
            margin-bottom: -5px !important;
        }

        .table_card input {
            width: auto !important;
        }

        .table_card .buttons-copy {
            background-color: #EFA63E !important;
            border: none !important;
            color: Black !important;
            font-weight: bold;
            padding: 10px 20px !important;
            font-weight: bold !important;
            border-radius: 8px !important;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2) !important;
            transition: all 0.3s ease-in-out !important;
            width: 13% !important;
        }

        .table_card .buttons-excel {
            background-color: #EFA63E !important;
            border: none !important;
            color: Black !important;
            font-weight: bold;
            padding: 10px 20px !important;
            font-weight: bold !important;
            border-radius: 8px !important;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2) !important;
            transition: all 0.3s ease-in-out !important;
            width: 13% !important;
        }

        .table_card .buttons-pdf {
            background-color: #EFA63E !important;
            border: none !important;
            color: Black !important;
            font-weight: bold;
            padding: 10px 20px !important;
            font-weight: bold !important;
            border-radius: 8px !important;
            box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.2) !important;
            transition: all 0.3s ease-in-out !important;
            width: 13% !important;
        }

            .table_card .buttons-copy:hover,
            .table_card .buttons-excel:hover,
            .table_card .buttons-pdf:hover {
                background-color: black !important;
                color: white !important;
            }

        .table_card .buttons-colvis {
            width: 38%;
            border-radius: 12px;
            background-color: #4052a1 !important;
            color: white !important;
        }

        .table_card .sorting :hover {
            color: yellow !important;
        }

        .table_card div.dt-buttons {
            position: relative;
            float: left;
            width: 50% !important;
            margin-left: 2%;
        }

        .table_card .ui-button-text-only .ui-button-text {
            font-weight: 900;
        }

        .table_card .dataTables_info {
            font-size: 14px;
            font-weight: 700 !important;
        }

        .table_card .dataTables_wrapper .ui-toolbar {
            padding: 3px;
        }

        .table_card table.dataTable thead th div.DataTables_sort_wrapper span {
            display: none;
        }

        .table_card #txt_date {
            height: 32px;
        }

        .table_card #check {
            width: 5% !important;
        }

        .table_card .info_btn {
            border-radius: 12px;
            width: 7%;
            margin-bottom: 7px;
            font-size: 14px;
            font-weight: 700;
        }

        .table_card .dataTables_filter input {
            border-radius: 15px !important;
        }

        .table_card body {
            font-weight: 700;
        }

        .table_card #ui-datepicker-div {
            width: 20% !important;
        }

        .table_card .btn-addnew {
            top: -5px !important;
        }

        .table_card .fa-pencil {
            color: black !important;
            font-weight: bold;
            font-size: 15px;
        }

        .table_card .fa-print {
            color: Black !important;
            font-weight: bold;
            font-size: 15px;
        }

        .table_card td {
            line-height: 15px !important;
        }

        .table_card #th-descptn {
            width: 200px !important;
        }

        .table_card .table-container {
            overflow-x: auto;
            max-height: 600px;
            height: 100%;
            box-sizing: border-box;
        }
    </style>
    <style type="text/css">
        .card {
            border: 1px solid #ccc;
            transition: all 0.3s ease;
            border-radius: 10px;
            padding: 20px;
        }

        .image-upload-body {
            display: flex;
            flex-direction: column; /* Stack children vertically */
            align-items: center; /* Center horizontally */
            justify-content: center; /* Optional: center vertically in card */
            gap: 10px; /* Optional: spacing between drop-area and text */
            min-height: 250px;
        }



        .card:hover {
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
        }

        .drop-area {
            position: relative;
            border: 2px dashed #999;
            border-radius: 10px;
            overflow: hidden;
            display: inline-block;
            max-width: 100%; /* Don't go outside card */
            max-height: 300px; /* Limit height */
            width: auto; /* Let JS set this */
            height: auto; /* Let JS set this */
        }

            /* Image stays scaled inside */
            .drop-area img#previewImage {
                display: block;
                width: 100%;
                height: 100%;
                object-fit: contain;
            }

            /* Delete icon */
            .drop-area i#deleteIcon {
                position: absolute;
                top: 10px;
                right: 10px;
                z-index: 10;
                font-size: 22px;
                color: red;
                cursor: pointer;
                display: none;
            }



            /* Transparent file input */
            .drop-area input[type="file"] {
                position: absolute;
                top: 0;
                left: 0;
                z-index: 5;
                width: 100%;
                height: 100%;
                opacity: 0;
                cursor: pointer;
            }
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            LoadPage();
            var ID = '<%= Request.QueryString["ID"] %>'
            if (ID != "") {
                loadCompanyDetail(ID);

                //$('#btn-opdprint').show();
            }
        });
        function loadCompanyDetail(ID) {
            $('#btnSave').val('Update');



            $.ajax({
                type: "POST",
                url: "AddCompany.aspx/GetCompanyDetail",
                data: JSON.stringify({ ID: ID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (resp) {
                    var data = JSON.parse(resp.d);

                    // Assign values to input fields
                    $('#name').val(data.companyName);
                    $('#email').val(data.companyEmail);
                    $('#phone1').val(data.phone1);
                    $('#phone2').val(data.phone2);
                    $('#salestax').val(data.salesTax);
                    $('#ntn').val(data.ntn);
                    $('#fiscalyear').val(data.fiscalYear);
                    $('#companycode').val(data.companyCode);
                    $('#address').val(data.address);

                    // Set image source
                    $('#previewImage').attr('src', data.imageURL);

                },
                error: function (response) {
                    alert("Error: " + response.responseText);
                    console.error("AJAX Error: ", response);
                }
            });
        }
        function deleteCompany(ID) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete the user permanently!',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    $.ajax({
                        type: "POST",
                        url: "AddCompany.aspx/DeleteCompany",
                        data: JSON.stringify({ ID: ID }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (resp) {
                            var data = JSON.parse(resp.d);
                            if (data == "1") {
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Company Deleted Successfully.',
                                    showConfirmButton: false,
                                    timer: 2500,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            } else {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Failed to Delete Company',
                                    showConfirmButton: false,
                                    timer: 2000,
                                    customClass: {
                                        popup: 'swal-big-popup',
                                        title: 'swal-big-title',
                                        htmlContainer: 'swal-big-text'
                                    }
                                });
                            }
                            window.location.reload();
                        },
                        error: function (response) {
                            alert("Error: " + response.responseText);
                            console.error("AJAX Error: ", response);
                        }
                    });

                }
            });
        }
        document.addEventListener('DOMContentLoaded', function () {
            var fileInput = document.getElementById("imageInput");
            console.log(fileInput);
            const imageInput = document.getElementById('imageInput');
            const previewImage = document.getElementById('previewImage');
            const deleteIcon = document.getElementById('deleteIcon');
            const dropArea = document.getElementById('drop-area');
            const imageName = document.getElementById('imageName');

            const fallbackSrc = "";
            const MAX_WIDTH = 200;
            const MAX_HEIGHT = 300;

            function resetDropArea() {
                dropArea.style.width = '199px';
                dropArea.style.height = '199px';
                previewImage.src = fallbackSrc;

                deleteIcon.style.display = 'none';
                imageName.textContent = "Drag image here or Click Above (.HEIC images won't preview)";
            }

            resetDropArea();

            imageInput.addEventListener('change', function (event) {
                const file = event.target.files[0];

                if (file && file.type.startsWith('image/')) {
                    const reader = new FileReader();

                    reader.onload = function (e) {
                        const img = new Image();
                        img.onload = function () {
                            let width = img.naturalWidth;
                            let height = img.naturalHeight;

                            const widthRatio = MAX_WIDTH / width;
                            const heightRatio = MAX_HEIGHT / height;
                            const scale = Math.min(widthRatio, heightRatio, 1);

                            width = width * scale;
                            height = height * scale;

                            dropArea.style.width = width + 'px';
                            dropArea.style.height = height + 'px';

                            previewImage.src = e.target.result;
                            previewImage.style.opacity = '1';
                            deleteIcon.style.display = 'block';
                            imageName.textContent = file.name;
                        };
                        img.src = e.target.result;
                    };

                    reader.readAsDataURL(file);
                } else {
                    imageName.textContent = "Drag image here or Click Above (.HEIC images won't preview)";
                }
            });

            deleteIcon.addEventListener('click', function () {
                imageInput.value = '';
                resetDropArea();
            });

            console.log(fileInput.value);
        });
        function LoadPage() {
            $("#tblResult").DataTable({
                "processing": true,
                "serverSide": true,

                "lengthChange": true,

                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "AddCompany.aspx/ViewList",
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
                    { "data": "Company_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Company_Name", "name": "Company_Name", "width": "30%", "orderable": true },
                    { "data": "Company_Email", "name": "Company_Email", "width": "30%", "orderable": false },
                    { "data": "CompanyCode", "width": "15%", "orderable": false },


                    {
                        render: function (data, type, full) {
                            var res = '<a href="#" onclick="editOpen(' + full.Company_ID + ')" class="editListBtn" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'

                            var Del = '<a class="delListBtn" style="border-radius: 4px;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href="#" data-id="' + full.Company_ID + '" onclick="deleteCompany( ' + full.Company_ID + ', \'' + full.Full_Name + '\')"><i class="fa fa-trash"></i></a>';

                            var result;
                            result = res + Del;
                            return result;


                        }, "width": "15%", "orderable": false
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
            window.location.href = "AddCompany.aspx?ID=" + id;
        }
        function saveData() {
            var ID = '<%= Request.QueryString["ID"] %>'
            var valid = true;
            var data = {
                urlID: ID,
                companyName: $('#name').val(),
                companyEmail: $('#email').val(),
                phone1: $('#phone1').val(),
                phone2: $('#phone2').val(),
                salesTax: $('#salestax').val(),
                ntn: $('#ntn').val(),
                fiscalYear: $('#fiscalyear').val(),
                companyCode: $('#companycode').val(),
                address: $('#address').val()
            };
            if ($('#name').val() == "") {
                valid = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Company Name',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            if ($('#email').val() == "") {
                valid = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Company E-mail',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            if ($('#phone1').val() == "") {
                valid = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Company Phone',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }
            if ($('#companycode').val() == "") {
                valid = false;
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Enter Company Code',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
            }


            if (valid) {
                $.ajax({
                    url: 'AddCompany.aspx/SaveCompany',
                    type: 'POST',
                    data: JSON.stringify({ companyData: data }),
                    contentType: 'application/json; charset=utf-8',
                    dataType: 'json',
                    success: function (response) {
                        console.log('Success:', response.d);

                        uploadImage(); // Call image upload after saving
                    },
                    error: function (xhr, status, error) {
                        console.error('Error:', error);
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Error occurred while saving',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                    }
                });
}
        }
        function uploadImage() {
            var fileInput = $('#imageInput')[0];
            var ID = '<%= Request.QueryString["ID"] %>';
            if (ID == "") {
                if (!fileInput || fileInput.files.length === 0) {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Company saved. No image uploaded.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    window.location.href = "AddCompany.aspx";
                    return;
                }
            }



            var formData = new FormData();
            formData.append('file', fileInput.files[0]);

            $.ajax({
                // the server reads the company ID from this request's query string; without it the
                // upload is treated as a new company and lands on the highest company ID
                url: 'AddCompany.aspx' + (ID !== '' ? '?ID=' + encodeURIComponent(ID) : ''),
                type: 'POST',
                data: formData,
                contentType: false,
                processData: false,
                success: function (res) {
                    console.log('File upload response:', res);
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Company and file saved successfully.',
                        showConfirmButton: false,
                        timer: 2500,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    window.location.href = "AddCompany.aspx";

                },
                error: function (xhr, status, error) {
                    console.error('File upload error:', error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'File upload failed but Company Data Saved!!',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });

                }
            });
        }
        function ClearForm() {
            window.location.href = "AddCompany.aspx";
        }
    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <div class="row">
        <div class="col-lg-7">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-8">
                            <div class="row">
                                <div class="col-lg-12">
                                    <label>Company Name</label>
                                    <input id="name" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-12">
                                    <label>Company Email</label>
                                    <input id="email" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>Phone#01</label>
                                    <input id="phone1" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>Phone#02</label>
                                    <input id="phone2" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>Sales Tax No.</label>
                                    <input id="salestax" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>NTN No.</label>
                                    <input id="ntn" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>Fiscal Year</label>
                                    <input id="fiscalyear" type="text" class="form-control" />
                                </div>
                                <div class="col-lg-6">
                                    <label>Company Code</label>
                                    <input id="companycode" type="text" class="form-control" />
                                </div>
                            </div>

                        </div>
                        <div class="col-lg-4">
                            <div class="card">
                                <div class="card-body image-upload-body">
                                    <div id="drop-area" class="drop-area">
                                        <img src="" id="previewImage" />
                                        <i id="deleteIcon" class="fa fa-trash"></i>
                                        <input type="file" name="ImageFile" id="imageInput" accept="image/*" />
                                    </div>
                                    <!-- File Name Display -->
                                    <div>
                                        <p id="imageName" class="text-muted text-center small mt-1">Drag image here or Click Above (.HEIC images won't preview)</p>

                                    </div>

                                </div>
                            </div>
                        </div>


                    </div>


                    <div class="row">
                        <div class="col-lg-12">
                            <label>Address</label>
                            <input id="address" type="text" class="form-control" />
                        </div>

                    </div>
                    <div class="row" style="margin-top:10px">
                        <div class="col-lg-2">
                            <input id="btnSave" type="button" class="btn-primry" value="Save" onclick="saveData()" style="width: 30px" />

                        </div>
                        <div class="col-lg-2">
                            <input id="btnNew" type="button" class="btn-gray" value="New" onclick="ClearForm()" style="width: 30px" />

                        </div>
                    </div>
                </div>

            </div>

        </div>

        <div class="col-lg-5">
            <div class="card table_card">
                <div class="card-body">
                    <div id="POdetails" style="margin-top: 15px;">
                        <div class="row">
                            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                                <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow: scroll; height: auto;">
                                    <thead id="ihead">
                                        <tr>
                                            <th style="display: none;">Company ID</th>
                                            <th>Company Name</th>
                                            <th>E-mail</th>
                                            <th>Code</th>
                                            <th>Action</th>

                                        </tr>
                                    </thead>
                                    <tbody id="ibody">
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>








</asp:Content>
