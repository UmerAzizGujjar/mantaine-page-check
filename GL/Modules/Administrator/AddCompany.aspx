<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddCompany.aspx.cs" Inherits="PMS.Modules.Administrator.AddCompany" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .card {
            border: 1px solid #ccc;
            transition: all 0.3s ease;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            }
            .drop-area {
            height: 199px;
            cursor: pointer;
            position: relative;
            overflow: hidden;
        }

        .drop-area img#previewImage {
            z-index: 1;
            display: block;
            width: 100%;
            height: 50%;
            object-fit: contain;
            opacity: 0.25;
            /* Add border */
    border: 2px dashed #999; /* or solid, dotted, etc. */
    border-radius: 10px;      /* Optional: rounded corners */
        }

        .drop-area i#deleteIcon {
            top: 10px;
            right: 10px;
            z-index: 4;
            cursor: pointer;
            font-size: 1.2rem;
            display: block;
            position: absolute;
            color: red;
        }

        .drop-area input[type="file"] {
            position: absolute;
            width: 100%;
            height: 100%;
            opacity: 0;
            top: 0;
            left: 0;
            z-index: 3;
            cursor: pointer;
        }
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            const id = new URLSearchParams(window.location.search).get('ID');
            if (id) {
                $.ajax({
                    url: 'AddGame/GetGameById', // 🔁 Replace with your actual controller name
                    type: 'GET',
                    data: { id: id },
                    success: function (data) {
                        // Fill inputs using name (asp-for generates id same as property name)
                        $('#GameName').val(data.gameName);
                        $('#MinPlayers').val(data.minplayers);
                        $('#MaxPlayers').val(data.maxplayers);
                        $('#RegistrationAmount').val(data.regAmount);
                        $('#CreatedBy').val(data.createdBy);
                        $('#MatchDate').val(data.matchDate.split('T')[0]); // ✅ Keep only date part
                        $('#Venue').val(data.venue);

                        // Set image preview
                        $('#previewImage')
                            .attr('src', data.imgURL)
                            .css({
                                opacity: '1',
                                width: '100%',
                                height: '100%'
                            });

                        $('#deleteIcon').show();
                    },
                    error: function (xhr, status, error) {
                        console.error("Error loading game data:", error);
                    }
                });
            }
        });
        const imageInput = document.getElementById('imageInput');
        const previewImage = document.getElementById('previewImage');
        const imageName = document.getElementById('imageName');
        deleteIcon.style.display = 'none';
        imageInput.addEventListener('change', function (event) {
            const file = event.target.files[0];

            if (file && file.type.startsWith('image/')) {
                const reader = new FileReader();

                reader.onload = function (e) {
                    deleteIcon.style.display = 'block';
                    previewImage.src = e.target.result; // Replace the image
                    previewImage.style.opacity = '1';
                    previewImage.style.width = '100%';
                    previewImage.style.height = '100%';

                };

                reader.readAsDataURL(file);
                imageName.textContent = "Selected Image: " + file.name;
            } else {
                deleteIcon.style.display = 'block';
                previewImage.src = "@Url.Content("~/CustomImages/image.png")"; // fallback
                previewImage.style.opacity = '0.25';
                previewImage.style.width = '50px';     // ✅ Mini size
                previewImage.style.height = '50px';    // ✅ Mini size

                imageName.textContent = "Can't display image due to unsupported format";

            }
            deleteIcon.addEventListener('click', function () {

                imageInput.value = '';
                imageName.textContent = '';
                deleteIcon.style.display = 'none';
                previewImage.src = "@Url.Content("~/CustomImages/image.png")"; // fallback

                previewImage.style.opacity = '0.25';
                previewImage.style.width = '50px';     // ✅ Mini size
                previewImage.style.height = '50px';    // ✅ Mini size
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-7">
            <div class="card">
                <div class="card-body">
                    <div class="row">
                        <div class="col-lg-6">
                            <label>Company Name</label>
                            <input type="text" class="form-control" />
                        </div>
                        <div class="col-lg-6">
                            <label>Company Email</label>
                            <input type="text" class="form-control" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-4">
                            <label>Phone#01</label>
                            <input type="text" class="form-control" />
                        </div>
                        <div class="col-lg-4">
                            <label>Phone#02</label>
                            <input type="text" class="form-control" />
                        </div>
                        <div class="col-lg-4">
                            <label>Sales Tax No.</label>
                            <input type="text" class="form-control" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-4">
                            <label>NTN No.</label>
                            <input type="text" class="form-control" />
                        </div>
                        <div class="col-lg-4">
                            <label>Fiscal Year</label>
                            <input type="text" class="form-control" />
                        </div>
                        <div class="col-lg-4">
                            <label>Company Code</label>
                            <input type="text" class="form-control" />
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-lg-12">
                            <label>Address</label>
                            <input type="text" class="form-control" />
                        </div>

                    </div>
                </div>
            </div>

        </div>
        <div class="col-lg-1"></div>
        <div class="col-lg-4">
            <div class="card">
                <div class="card-body">
                    <div id="drop-area" class="drop-area d-flex flex-column justify-content-center align-items-center border border-2 rounded-4 bg-light mb-3">
    <!-- Image Preview -->
    <img id="previewImage" src="../../../wwwroot/Tibbit_theme/images/dashboard_Icons/appointmentStats.png" class="position-absolute top-50 start-50 translate-middle" alt="Preview Image"/>

    <!-- Delete Icon -->
    <i id="deleteIcon" class="bi bi-trash"></i>

    <!-- File Input -->
    <input type="file" name="ImageFile" id="imageInput" accept="image/*"/>
</div>
                </div>
            </div>
        </div>
    </div>








</asp:Content>
