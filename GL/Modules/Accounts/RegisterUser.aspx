<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterUser.aspx.cs" Inherits="PMS.Modules.Accounts.RegisterUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <link href="../../wwwroot/StandardTheme/css/CustomCss/registeruser.css" rel="stylesheet" />
        <link href="../../wwwroot/StandardTheme/css/CustomCss/swalalert.css" rel="stylesheet" />

        <script type="text/javascript">
        $(document).ready(function () {
            
        });
            function showmodal() {
                $("#UserModel").modal('show');
            }
        function CreateUser() {
            var Valid = true;
            var UserName = $('#UserName').val();
            var Email = $('#Email').val();
            var Password = $('#Password').val();
            var ConfirmPassword = $('#ConfirmPassword').val();
            var AllowPatientEdit = $('#AllowPatientEdit').prop('checked');
            var AllowPatientDelete = $('#AllowPatientDelete').prop('checked');
            var AllPatientRecords = $('#AllPatientRecords').prop('checked');
            var AllowUnapproveVouchers = $('#AllowUnapproveVouchers').prop('checked');
            var OTPUsers = $('#OTPUsers').prop('checked');

            var hasMinLength = Password.length >= 6;
            var hasSpecialChar = /[!@#$%^&*(),.?":{}|<>]/.test(Password);
            if (UserName == "" || Email == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please Fill UserName/Email',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            else if (Password == "" || ConfirmPassword == "") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Password Fields cannot be Empty.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            else if (!hasMinLength || !hasSpecialChar) {
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
            }
            else if (Password != ConfirmPassword) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Password and Confirm Password does not match.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                Valid = false;
            }
            
            var dataObj = {
                "UserName": UserName,
                "Email": Email,
                "Password": Password,
                "ConfirmPassword": ConfirmPassword,
                "AllowPatientEdit": AllowPatientEdit,
                "AllowPatientDelete": AllowPatientDelete,
                "AllPatientRecords": AllPatientRecords,
                "AllowUnapproveVouchers": AllowUnapproveVouchers,
                "OTPUsers": OTPUsers,

            };

            var data = JSON.stringify({ data: dataObj });
            console.log(data);
            if (Valid) {
                $.ajax({
                    type: "POST",
                    url: "Register.aspx/Create_User",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var response = data.d;  
                        if (response == "success") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'User Created!',
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            setTimeout(function () {
                                window.location.href = "../Accounts/Login.aspx";
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
        
        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
                <div class="row">
                    <div class="col-lg-3"></div>
                    <div class="col-lg-8">
                                        <div class="card">
                <div class="card-body">
                    <div class="accountInfo">
                        <!-- User Name -->
                        <div class="label-field">
                            <label for="UserName" style="font-size: 16px;">User Name:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="text" id="UserName" name="UserName" class="textEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Email -->
                        <div class="label-field">
                            <label for="Email" style="font-size: 16px;">E-mail:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="text" id="Email" name="Email" class="textEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Password -->
                        <div class="label-field">
                            <label for="Password" style="font-size: 16px;">Password:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="password" id="Password" name="Password" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Confirm Password -->
                        <div class="label-field">
                            <label  for="ConfirmPassword" style="font-size: 16px;">Confirm Password:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="password" id="ConfirmPassword" name="ConfirmPassword" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>

                        <!-- Checkboxes -->
                        

                        <!-- Buttons -->

                        <input type="button" value="Create User" class="mybutton" onclick="CreateUser()" style="border-radius: 50px; width: 150px; margin-top:10px;" />

                        <input type="button" value="Back" onclick="window.location.href='UserView.aspx'" class="mybutton" style="border-radius: 50px; width: 150px; margin-top:10px"/>

                        <input type="button" value="Create User" class="mybutton" onclick="showmodal()" style="border-radius: 50px; width: 150px; margin-top:10px;" />



                        <%--patient modal--%>
                        <div id="UserModel" class="modal fade" tabindex="-1" role="dialog">
                            <div class="modal-dialog modal-lg" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Assign Roles</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>

                                    <div class="modal-body">
                                        <div style="margin-top: 10px;">
                                            <input type="checkbox" id="AllowPatientEdit" name="AllowPatientEdit" />
                                            <label for="AllowPatientEdit" class="inline">Edit Patient</label>&nbsp;&nbsp;

                                             <input type="checkbox" id="AllowPatientDelete" name="AllowPatientDelete" />
                                            <label for="AllowPatientDelete" class="inline">Cancel Patient</label>&nbsp;&nbsp;

    <input type="checkbox" id="AllPatientRecords" name="AllPatientRecords" />
                                            <label for="AllPatientRecords" class="inline">All Patients</label>&nbsp;&nbsp;

    <input type="checkbox" id="OTPUsers" name="OTPUsers" />
                                            <label for="OTPUsers" class="inline">OTP Users</label>

                                            <input type="checkbox" id="AllowUnapproveVouchers" name="AllowUnapproveVouchers" />
                                            <label for="AllowUnapproveVouchers" class="inline">Unapprove Voucher</label>


                                        </div>


                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-primry" id="SavePatient_Data" onclick="SavePatient();">Save</button>
                                        <button type="button" class="btn btn-secondary" id="updatePatient_Data" onclick="SavePatient();">Update</button>
                                        <button type="button" class="btn btn-gray" data-dismiss="modal">Close</button>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

                    </div>
                </div>

</asp:Content>
