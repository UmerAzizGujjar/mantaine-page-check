<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PasswordChange.aspx.cs" Inherits="PMS.Modules.Accounts.PasswordChange" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/changePassword.css" rel="stylesheet" />
  <link href="../../wwwroot/Tibbit_theme/css/CustomCss/Toaster.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {

        });
        function changepassword() {
            var valid = true;
            var OldPassword = $('#CurrentPassword').val();
            var NewPassword = $('#NewPassword').val();
            var ConfirmNewPassword = $('#ConfirmNewPassword').val();


            
            var dataObj = {
                "OldPassword": OldPassword,
                "NewPassword": NewPassword,
                "ConfirmNewPassword": ConfirmNewPassword,
            };
            var data = JSON.stringify({ data: dataObj });
            console.log(data);
            debugger;
            if (ConfirmNewPassword == null || ConfirmNewPassword == "") {
                $("#failureNotification2").show();
                valid = false;
            }
            else if (NewPassword != ConfirmNewPassword) {
                valid = false;
                $("#failureNotification1").show();
            }

            if (valid) {
                $.ajax({
                    type: "POST",
                    url: "PasswordChange.aspx/ChangePassword",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var result = data.d;
                        if (result == "Password changed successfully!") {
                            toasterMessage(false, result);
                        }
                        else {
                            toasterMessage(true, result);
                        }
                        window.location.reload();




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

        function toasterMessage(isError = false, title, message) {
            debugger;
            toastr.options = {
                "closeButton": true,
                "debug": false,
                "preventDuplicates": false,
                "positionClass": "toast-center-screen",
                "onclick": null,
                "showDuration": "551500",
                "hideDuration": "2000",
                "timeOut": "4000",
                "extendedTimeOut": "1000",
                "showEasing": "swing",
                "hideEasing": "linear",
                "showMethod": "fadeIn",
                "hideMethod": "fadeOut",
                onclick: function () {
                    $('#right-sidebar').toggleClass('sidebar-open');
                }
            };

            if (isError)
                toastr.error(message, title);
            else
                toastr.success(message, title);
        }

        function redirect() {
            window.location.href = "../Dashboards/ShortCuts.aspx";
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <div class="row justify-content-center">
        <div class="col-lg-4"></div>
        <div class="col-lg-4">
            <div class="card shadow">

                <div class="card-body">
                    <div class="accountInfo">
                        <div class="label-field">
                            <label for="CurrentPassword" style="font-size: 16px; border-radius: 10px !important;">Old Password:</label>
                        </div>
                        <div class="input-field">
                            <input type="password" id="CurrentPassword" class="passwordEntry" style="border-radius: 10px !important;"
                                title="Old Password is ." />
                            <span class="failureNotification" id="currentPasswordError" style="display: none;">*</span>
                        </div>

                        <div class="label-field">
                            <label for="NewPassword" style="font-size: 16px;">New Password:</label>
                        </div>
                        <div class="input-field">
                            <input type="password" id="NewPassword" class="passwordEntry" style="border-radius: 10px !important;"
                                title="New Password is ." />
                            <span class="failureNotification" id="newPasswordError" style="display: none;">*</span>
                        </div>

                        <div class="label-field">
                            <label for="ConfirmNewPassword" style="font-size: 16px;">Confirm New Password:</label>
                        </div>
                        <div class="input-field">
                            <input type="password" id="ConfirmNewPassword" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>
                        <span id="failureNotification1" class="span_txt" style="display: none; color: red;">New Password and Confirm New Password does not match</span>
                        <span id="failureNotification2" class="span_txt" style="display: none; color: red;">New Password cannot be empty</span>
                        <div class="submitButton">
                            <button class="btn btn-primry" type="button" id="ChangePasswordPushButton" onclick="changepassword()">Change Password</button>
                            <button class="btn btn-primry" type="button" id="CancelPushButton" onclick="redirect()" >Cancel</button>

                        </div>
                    </div>
                </div>

            </div>
        </div>
    </div>
</asp:Content>
