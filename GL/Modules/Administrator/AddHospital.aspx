<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddHospital.aspx.cs" Inherits="PMS.Modules.Administrator.AddHospital" %>


<asp:Content ID="HeaderContent" runat="server" ContentPlaceHolderID="HeadContent">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/registeruser.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script type="text/javascript" src="../../wwwroot/Tibbit_theme/js/swalalert.js"></script>

    <script type="text/javascript">
        $(document).ready(function () {
            var urlParams = new URLSearchParams(window.location.search);
            var hospitalId = urlParams.get('id');
            
            if (hospitalId) {
                $('#pageTitle').text('Edit Hospital');
                $('#btnSave').val('Update Hospital');
                LoadHospitalData(hospitalId);
            } else {
                $('#pageTitle').text('Add Hospital');
                $('#btnSave').val('Add Hospital');
            }
        });

        function LoadHospitalData(hospitalId) {
            var dataObj = { "hospitalId": hospitalId };
            var data = JSON.stringify({ data: dataObj });

            $.ajax({
                type: "POST",
                url: "AddHospital.aspx/GetHospitalById",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var hospital = response.d;
                    if (hospital) {
                        $('#HospitalId').val(hospital.Id);
                        $('#HospitalName').val(hospital.HospitalName);
                        $('#ServerName').val(hospital.ServerName);
                        $('#DatabaseName').val(hospital.DatabaseName);
                        $('#UserID').val(hospital.UserID);
                        $('#IsActive').prop('checked', hospital.IsActive);
                        // Don't load password for security reasons
                    }
                },
                error: function (xhr, status, error) {
                    console.log("Error loading hospital data:", error);
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to load hospital data.',
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

        function SaveHospital() {
            var Valid = true;
            var HospitalId = $('#HospitalId').val();
            var HospitalName = $('#HospitalName').val();
            var ServerName = $('#ServerName').val();
            var DatabaseName = $('#DatabaseName').val();
            var UserID = $('#UserID').val();
            var Password = $('#Password').val();
            var ConfirmPassword = $('#ConfirmPassword').val();
            var IsActive = $('#IsActive').prop('checked');

            // Validation
            if (HospitalName == "" || ServerName == "" || DatabaseName == "" || UserID == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please fill all required fields.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
                return;
            }

            // Password validation (only required for new hospitals)
            if (!HospitalId || HospitalId == "") {
                if (Password == "" || ConfirmPassword == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Password fields cannot be empty.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    Valid = false;
                    return;
                }
            }

            // If password is provided, validate it
            if (Password != "") {
                var hasMinLength = Password.length >= 6;
                var hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(Password);

                if (!hasMinLength || !hasSpecialChar) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Password must be at least 6 characters long and contain at least one special character.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    Valid = false;
                    return;
                }

                if (Password != ConfirmPassword) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Password and Confirm Password do not match.',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    Valid = false;
                    return;
                }
            }

            var dataObj = {
                "Id": HospitalId ? parseInt(HospitalId) : 0,
                "HospitalName": HospitalName,
                "ServerName": ServerName,
                "DatabaseName": DatabaseName,
                "UserID": UserID,
                "Password": Password,
                "IsActive": IsActive
            };

            var data = JSON.stringify({ data: dataObj });
            console.log(data);

            if (Valid) {
                $.ajax({
                    type: "POST",
                    url: "AddHospital.aspx/SaveHospital",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var response = data.d;
                        if (response == "success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: HospitalId ? 'Hospital Updated!' : 'Hospital Added!',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            setTimeout(function () {
                                window.location.href = "HospitalView.aspx";
                            }, 2000);
                        }
                        else {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: response,
                                showConfirmButton: false,
                                timer: 2000,
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
                        console.log("Status:", status);
                        console.log("Error:", error);

                        if (xhr.responseText) {
                            alert("Server Error: " + xhr.responseText);
                        } else {
                            alert("AJAX Error: " + error);
                        }
                    }
                });
            }
        }

        function TestConnection() {
            var ServerName = $('#ServerName').val();
            var DatabaseName = $('#DatabaseName').val();
            var UserID = $('#UserID').val();
            var Password = $('#Password').val();

            if (ServerName == "" || DatabaseName == "" || UserID == "" || Password == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please fill Server, Database, UserID and Password fields to test connection.',
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

            var dataObj = {
                "ServerName": ServerName,
                "DatabaseName": DatabaseName,
                "UserID": UserID,
                "Password": Password
            };

            var data = JSON.stringify({ data: dataObj });

            $.ajax({
                type: "POST",
                url: "AddHospital.aspx/TestDatabaseConnection",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var result = response.d;
                    if (result == "success") {
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Database connection successful!',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    } else {
                        Swal.fire({
                            icon: 'error',
                            title: 'Connection Failed!',
                            text: result,
                            showConfirmButton: true,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                    }
                },
                error: function (xhr, status, error) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Failed to test connection.',
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
    </script>
</asp:Content>

<asp:Content ID="BodyContent" runat="server" ContentPlaceHolderID="MainContent">
    <div class="row">
        <div class="col-lg-4"></div>
         <div class="col-lg-4">
                 <div class="card">
        <div class="card-body">
            <h2 id="pageTitle" style="text-align: center; margin-bottom: 20px;">Add Hospital</h2>
            <div class="accountInfo">
                <!-- Hidden field for Hospital ID -->
                <input type="hidden" id="HospitalId" name="HospitalId" />

                <!-- Hospital Name -->
                <div class="label-field">
                    <label for="HospitalName" style="font-size: 16px;">Hospital Name:<span style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="text" id="HospitalName" name="HospitalName" class="textEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- Server Name -->
                <div class="label-field">
                    <label for="ServerName" style="font-size: 16px;">Server Name:<span style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="text" id="ServerName" name="ServerName" class="textEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- Database Name -->
                <div class="label-field">
                    <label for="DatabaseName" style="font-size: 16px;">Database Name:<span style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="text" id="DatabaseName" name="DatabaseName" class="textEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- User ID -->
                <div class="label-field">
                    <label for="UserID" style="font-size: 16px;">User ID:<span style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="text" id="UserID" name="UserID" class="textEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- Password -->
                <div class="label-field">
                    <label for="Password" style="font-size: 16px;">Password:<span id="passwordRequired" style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="password" id="Password" name="Password" class="passwordEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- Confirm Password -->
                <div class="label-field">
                    <label for="ConfirmPassword" style="font-size: 16px;">Confirm Password:<span id="confirmPasswordRequired" style="color:red;">*</span></label>
                </div>
                <div class="input-field">
                    <input autocomplete="off" type="password" id="ConfirmPassword" name="ConfirmPassword" class="passwordEntry" style="border-radius: 10px !important;" />
                </div>

                <!-- IsActive Checkbox -->
                <div style="margin-top: 10px;">
                    <div class="row">
                        <div class="col-lg-2">
                              <input type="checkbox" id="IsActive" name="IsActive" checked />
                        </div>
                         <div class="col-lg-10">
<label for="IsActive" class="inline">Active</label>
 </div>
                    </div>
                  
                    
                </div>

                <!-- Buttons -->
                <div style="margin-top: 20px;">
                    <input class="btn-primry" type="button" id="btnSave" value="Add Hospital" class="mybutton" onclick="SaveHospital()" style="border-radius: 50px; width: 170px; margin-right: 10px;" />
                
                    <input class="btn-primry" type="button" value="Back" onclick="window.location.href='HospitalView.aspx'" class="mybutton" style="border-radius: 50px; width: 150px;" />
                </div>
            </div>
        </div>
    </div>
         </div>
         <div class="col-lg-4"></div>
    </div>
    
</asp:Content>
