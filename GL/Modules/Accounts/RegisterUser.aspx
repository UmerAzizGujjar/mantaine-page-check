<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="RegisterUser.aspx.cs" Inherits="PMS.Modules.Accounts.RegisterUser" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/registeruser.css" rel="stylesheet" />
    <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />

    <script type="text/javascript">
        $(document).ready(function () {
            var UserID = '<%= Request.QueryString["UserID"] %>';
            fillCashInHand();
            if (UserID != "") {
                populate_data(UserID);
            }
        });
        function showmodal() {
            $("#UserModel").modal('show');
        }

        function populate_data(UserID) {
            $.ajax({
                type: "POST",
                url: "RegisterUser.aspx/Populate_Data",
                data: JSON.stringify({ UserID: UserID }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var data = JSON.parse(response.d);
                    $('#saveBtn').val('Update User');
                    // Disable password fields
                    $('#Password').prop('disabled', true);
                    $('#ConfirmPassword').prop('disabled', true);
                    // Text inputs
                    $('#UserName').val(data.UserName);
                    $('#Email').val(data.Email);
                    $('#Mobile').val(data.mobileno);
                    $('#EmpCode').val(data.EmpCode);
                    setTimeout(function () {
                        $('#ddlCashInHand').val(data.Accounts).trigger('change');
                    }, 200);
                    // Checkboxes
                    $('#AllowPatientEdit').prop('checked', data.AllowPatientEdit);
                    $('#AllowPatientDelete').prop('checked', data.AllowPatientDelete);
                    $('#AllPatientRecords').prop('checked', data.AllPatientRecords);
                    $('#AllowUnapproveVouchers').prop('checked', data.AllowUnapproveVoucher);
                    $('#OTPUsers').prop('checked', data.OTPUsers);
                    $('#AllowBillDelete').prop('checked', data.AllowBillDelete);
                    $('#AllowTestRate').prop('checked', data.AllowTestRate);
                    $('#AllowOPD').prop('checked', data.OpdAllow);
                    $('#AllowLab').prop('checked', data.allow_lab);
                    $('#AllowUltra').prop('checked', data.allow_ultra);
                    $('#AllowCtscan').prop('checked', data.allow_ctscan);
                    $('#AllowXray').prop('checked', data.allow_xray);
                    $('#AllowB_Bank').prop('checked', data.allow_b_bank);
                    $('#AllowPharmacy').prop('checked', data.AllowPharmacy);
                    $('#GeneralItems').prop('checked', data.AllowGeneralItems);
                    $('#ShowBudgetBtn').prop('checked', data.IsShowBudget);
                    $('#InventoryUnApprove').prop('checked', data.IsInventoryUnApprove);
                    $('#PRFsNotifications').prop('checked', data.IsNotificationViewed);
                    $('#RateBox').prop('checked', data.allowtestbox);
                    $('#AllowToAccessAllTest').prop('checked', data.AllowToAccessAllTest);
                    $('#AllowCardio').prop('checked', data.allow_cardio);
                    $('#IsAnonymous').prop('checked', data.IsAnonymous);
                    $('#AllowEditEmergency').prop('checked', data.EditEmergency);
                    $('#AllowBillUpdate').prop('checked', data.Allow_bill_edit);
                    $('#AllowEmergency_adm_dis').prop('checked', data.Emergency_adm_dis);
                    $('#BlockUser').prop('checked', data.BlockUser);
                },
                error: function (xhr, status, error) {
                    alert("Error: " + xhr.responseText);
                }
            });
        }

        function CreateUser() {
            debugger;
            var Valid = true;
            var UserIDfromURL = '<%= Request.QueryString["UserID"] %>';
            var UserName = $('#UserName').val();
            var Email = $('#Email').val();
            var Password = $('#Password').val();
            var ConfirmPassword = $('#ConfirmPassword').val();
            var Mobile = $('#Mobile').val();
            var Accounts = $('#ddlCashInHand :selected').val();
            var AllowPatientEdit = $('#AllowPatientEdit').prop('checked');
            var AllowPatientDelete = $('#AllowPatientDelete').prop('checked');
            var AllPatientRecords = $('#AllPatientRecords').prop('checked');
            var AllowUnapproveVouchers = $('#AllowUnapproveVouchers').prop('checked');
            var OTPUsers = $('#OTPUsers').prop('checked');
            var AllowBillDelete = $('#AllowBillDelete').prop('checked');
            var AllowTestRate = $('#AllowTestRate').prop('checked');
            var AllowOPD = $('#AllowOPD').prop('checked');
            var AllowLab = $('#AllowLab').prop('checked');
            var AllowUltra = $('#AllowUltra').prop('checked');
            var AllowCtscan = $('#AllowCtscan').prop('checked');
            var AllowXray = $('#AllowXray').prop('checked');
            var AllowB_Bank = $('#AllowB_Bank').prop('checked');
            var AllowPharmacy = $('#AllowPharmacy').prop('checked');
            var GeneralItems = $('#GeneralItems').prop('checked');
            var ShowBudgetBtn = $('#ShowBudgetBtn').prop('checked');
            var InventoryUnApprove = $('#InventoryUnApprove').prop('checked');
            var PRFsNotifications = $('#PRFsNotifications').prop('checked');
            var RateBox = $('#RateBox').prop('checked');
            var AllowToAccessAllTest = $('#AllowToAccessAllTest').prop('checked');
            var AllowCardio = $('#AllowCardio').prop('checked');
            var IsAnonymous = $('#IsAnonymous').prop('checked');
            var EditEmergency = $('#AllowEditEmergency').prop('checked');
            var AllowEmergency_adm_dis = $('#AllowEmergency_adm_dis').prop('checked');
            var AllowBillUpdate = $('#AllowBillUpdate').prop('checked');
            var BlockUser = $('#BlockUser').prop('checked');
            var EmpCode = $('#EmpCode').val();
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
            else if ((Password == "" || ConfirmPassword == "") && UserIDfromURL == "") {
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
            else if ((!hasMinLength || !hasSpecialChar) && UserIDfromURL == "") {
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
            else if ((Password != ConfirmPassword) && UserIDfromURL == "") {
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

                if (!Accounts || Accounts === "0") {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select a Account.',
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
                "UserIDfromURL": UserIDfromURL,
                "UserName": UserName,
                "Email": Email,
                "Password": Password,
                "ConfirmPassword": ConfirmPassword,
                "Mobile": Mobile,
                "Accounts": Accounts,
                "AllowPatientEdit": AllowPatientEdit,
                "AllowPatientDelete": AllowPatientDelete,
                "AllPatientRecords": AllPatientRecords,
                "AllowUnapproveVouchers": AllowUnapproveVouchers,
                "OTPUsers": OTPUsers,
                "AllowBillDelete": AllowBillDelete,
                "AllowTestRate": AllowTestRate,
                "AllowOPD": AllowOPD,
                "AllowLab": AllowLab,
                "AllowUltra": AllowUltra,
                "AllowCtscan": AllowCtscan,
                "AllowXray": AllowXray,
                "AllowB_Bank": AllowB_Bank,
                "AllowPharmacy": AllowPharmacy,
                "GeneralItems": GeneralItems,
                "ShowBudgetBtn": ShowBudgetBtn,
                "InventoryUnApprove": InventoryUnApprove,
                "PRFsNotifications": PRFsNotifications,
                "RateBox": RateBox,
                "EmpCode": EmpCode,
                "AllowToAccessAllTest": AllowToAccessAllTest,
                "AllowCardio": AllowCardio,
                "IsAnonymous": IsAnonymous,
                "EditEmergency": EditEmergency,
                "AllowEmergency_adm_dis": AllowEmergency_adm_dis,
                "AllowBillUpdate": AllowBillUpdate,
                "BlockUser": BlockUser

            };

            var data = JSON.stringify({ data: dataObj });
            console.log(data);
            if (Valid) {
                $.ajax({
                    type: "POST",
                    url: "RegisterUser.aspx/Create_User",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        var response = data.d;
                        if (response == "User Created Successfully" || response == "User Updated Successfully") {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: response,
                                showConfirmButton: false,
                                timer: 2500,
                                customClass: {
                                    popup: 'swal-big-popup',
                                    title: 'swal-big-title',
                                    htmlContainer: 'swal-big-text'
                                }
                            });
                            setTimeout(function () {
                                window.location.href = "../Accounts/UserList.aspx";
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

    function fillCashInHand() {
    var options = '<option value="0">Please Select</option>';
    $.ajax({
        url: 'RegisterUser.aspx/GetGLAccounts',
        type: 'POST',
        contentType: 'application/json; charset=utf-8',
        dataType: 'json',
        success: function (response) {
            var data = response.d ? JSON.parse(response.d) : response;
            $.each(data, function (key, value) {
                options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
            });
            $('#ddlCashInHand').html(options);
            $('#ddlCashInHand').select2({
            });
        },
        error: function (xhr, status, error) {
            console.error('Error fetching area data:', error);
        }
    });
}


    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-4"></div>
        <div class="col-lg-4">
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
                            <label for="ConfirmPassword" style="font-size: 16px;">Confirm Password:</label>
                        </div>
                        <div class="input-field">
                            <input autocomplete="off" type="password" id="ConfirmPassword" name="ConfirmPassword" class="passwordEntry" style="border-radius: 10px !important;" />
                        </div>
                        <!-- Mobile -->
                        <div>
                            <div class="label-field">
                                <label for="Mobile" style="font-size: 16px;">Mobile:</label>
                            </div>
                            <div class="input-field">
                                <input autocomplete="off" type="text" id="Mobile" name="UserName" class="textEntry" style="border-radius: 10px !important; margin-right: 5px" />
                            </div>
                        </div>
                        <div>
                            <div class="row">
                                <div class="col-lg-11 col-md-4 col-sm-6">
                                    <div class="label-field">
                                        <label for="ddlCashInHand" style="font-size: 16px;">Accounts</label>
                                    </div>
                                    <div class="input-field">
                                        <select id="ddlCashInHand">
                                            <option value="0">Select</option>
                                        </select>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <!-- Buttons -->
                                <input type="button" value="User Rights" class="btn-primry" onclick="showmodal()" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <input id="saveBtn" class="btn-primry" type="button" value="Create User" onclick="CreateUser()" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-lg-5 col-md-4 col-sm-6">
                                <input type="button" class="btn-primry" value="View" onclick="window.location.href='UserList.aspx'" style="border-radius: 50px !important; margin-top: 10px;" />
                            </div>
                        </div>
                        <%--patient modal--%>
                        <div id="UserModel" class="modal fade" tabindex="-1" role="dialog">
                            <div class="modal-dialog modal-lg" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">UserRights</h5>
                                        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                                            <span aria-hidden="true">&times;</span>
                                        </button>
                                    </div>

                                    <div class="modal-body">
                                        <div class="container-fluid">
                                            <div class="row">
                                                <div class="col-md-1">
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowPatientEdit" name="AllowPatientEdit" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowPatientDelete" name="AllowPatientDelete" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllPatientRecords" name="AllPatientRecords" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowBillDelete" name="AllowBillDelete" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowTestRate" name="AllowTestRate" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowOPD" name="AllowOPD" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowLab" name="AllowLab" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowUltra" name="AllowUltra" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowCtscan" name="AllowCtscan" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowXray" name="AllowXray" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowToAccessAllTest" name="AllowToAccessAllTest" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowCardio" name="AllowCardio" />
                                                    </div>
                                                     <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowBillUpdate" name="AllowBillUpdate" />
                                                    </div> 
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowEmergency_adm_dis" name="AllowEmergency_adm_dis" />
                                                    </div>
                                                </div>

                                                <div class="col-md-3">
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowPatientEdit">Edit Patient</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowPatientDelete">Cancel Patient</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllPatientRecords">All Patients</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowBillDelete">Allow Bill Delete</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowTestRate">Allow Test Rate</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowOPD">Allow OPD</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowLab">Allow Lab</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowUltra">Allow Ultra</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowCtscan">Allow CT Scan</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowXray">Allow X-ray</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowToAccessAllTest">Allow To Access All Test</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowCardio">Allow Cardio</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowCardio">Allow Bill Update</label>
                                                    </div> 
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowAdmissionDischarge">Emergency Adm_Dis </label>
                                                    </div>
                                                </div>
                                                <div class="col-md-2"></div>
                                                <div class="col-md-1">
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowB_Bank" name="AllowB_Bank" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowPharmacy" name="AllowPharmacy" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowUnapproveVouchers" name="AllowUnapproveVouchers" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="GeneralItems" name="GeneralItems" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="ShowBudgetBtn" name="ShowBudgetBtn" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="InventoryUnApprove" name="InventoryUnApprove" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="PRFsNotifications" name="PRFsNotifications" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="OTPUsers" name="OTPUsers" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="RateBox" name="RateBox" />
                                                    </div>

                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="BlockUser" name="OTPUsers" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="IsAnonymous" name="RateBox" />
                                                    </div> 
                                                    <div class="form-check">
                                                        <input type="checkbox" class="form-check-input" id="AllowEditEmergency" name="EditEmergency" />
                                                    </div>
                                                    <div class="form-check">
                                                        <input type="text" class="form-check-input" id="EmpCode" name="EmpCode" style="" />
                                                    </div>

                                                </div>
                                                <div class="col-md-3">
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowB_Bank">Allow B_Bank</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowPharmacy">Allow Pharmacy</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="AllowUnapproveVouchers">Voucher Approval</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="GeneralItems">General Items</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="ShowBudgetBtn">Show Budget Btn</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="InventoryUnApprove">Inventory UnApprove</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="PRFsNotifications">PRFs Notifications</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="OTPUsers">OTP User</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="RateBox">Rate Box</label>
                                                    </div>

                                                    <div class="form-check">
                                                        <label class="form-check-label" for="BlockUser">Block User</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="IsAnonymous">IsAnonymous</label>
                                                    </div>
                                                     <div class="form-check">
                                                        <label class="form-check-label" for="AllowEditEmergency">Edit Emergency</label>
                                                    </div>
                                                    <div class="form-check">
                                                        <label class="form-check-label" for="EmpCode">Employee Code</label>
                                                    </div>
                                                </div>

                                                <div class="col-md-2"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-primry" data-dismiss="modal">Ok</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>



</asp:Content>
