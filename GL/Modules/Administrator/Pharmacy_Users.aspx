<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Pharmacy_Users.aspx.cs" Inherits="PMS.Pharmacy_Users" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Service.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.3.1/css/bootstrap.min.css" />
    <link rel="stylesheet" href="https://pro.fontawesome.com/releases/v5.10.0/css/all.css" integrity="sha384-AYmEC3Yw5cVb3ZcuHtOA93w35dYTsvhLPVnYs9eStHfGJvOvKxVfELGroGkvsg+p" crossorigin="anonymous"/>


    <script type="text/javascript">

        var arr = [];
        function GetAllCashierUsers() {

            PageMethods.GetAllCashierUsers(function (data) {
                var Parsed = JSON.parse(data);
                $.each(Parsed, function (key, value) {
                    arr.push
                        ({
                            User_Code: value.User_Code,

                        });
                });
            });
        }
        var breakout = false;
        $(document).ready(function () {

            $("#txtUserCode").focus();
            GetAllCashierUsers();
            $("#txtUserCode").on('change', function (e) {
                debugger;
                var userCode = $('#txtUserCode').val();
                breakout = false;
                $(arr).filter(function (i, n) {
                    debugger;
                    if (userCode == n.User_Code) {
                        $('#lblUsername').text("Code Already Exist").css("color", "Red");
                        breakout = true;
                        return false;
                    }

                });
                if (breakout == true) {
                    $('#lblUsername').text("Code Already Exist").css("color", "Red");

                }
                else {
                    $('#lblUsername').text("Success").css("color", "green");
                }

            });


            $("#togglePassword").click(function () {
                debugger;
                $(this).toggleClass("fa-eye fa-eye-slash");

                var x = document.getElementById("txtUserPass");
                if (x.type === "password") {
                    x.type = "text";
                } else {
                    x.type = "password";
                }
            });
            debugger;
            var ID = '<%= Request.QueryString["ID"]%>';
            if (ID != "" || ID != '') {
                setTimeout(function () {
                    loadappt(ID);
                }, 500);
            }
        });

        function syncPharmacyUserMeta() {
            var code = $('#txtUserCode').val();
            if (code) {
                $('#pharmacyUserCodeDisplay').text(code);
            }
        }
        $(document).ready(function () {
            var originalVal = $.fn.val;
            $.fn.val = function (value) {
                var res = originalVal.apply(this, arguments);
                if (this.attr('id') === 'txtUserCode' && arguments.length >= 1) {
                    syncPharmacyUserMeta();
                }
                return res;
            };

            $('#ChkActive').change(function () {
                if ($(this).is(':checked')) {
                    $('#pharmacyActiveBadge').removeClass('badge-inactive').addClass('badge-active');
                    $('#pharmacyActiveIcon').removeClass('fa-times-circle').addClass('fa-check-circle');
                    $('#pharmacyActiveText').text('Active');
                } else {
                    $('#pharmacyActiveBadge').removeClass('badge-active').addClass('badge-inactive');
                    $('#pharmacyActiveIcon').removeClass('fa-check-circle').addClass('fa-times-circle');
                    $('#pharmacyActiveText').text('Inactive');
                }
            });
            $('#ChkActive').trigger('change');
            syncPharmacyUserMeta();
        });



        function SaveRecord()
        {
            debugger;
            var UserID = '';
            UserID = '<%= Request.QueryString["ID"]%>'
            if (UserID == '' || UserID == "" || UserID == null || UserID == 'null') {
                UserID = 0;
            }

            var btnsave = $('#btnSave').val();
            var UserCode = $('#txtUserCode').val();
            if (UserCode == "" || UserCode == '') {
                alert("Enter User Code");
                $('#txtUserCode').focus();
                return;

            }
            var Password = $('#txtUserPass').val();

            if (Password == "" || Password == '') {
                alert("Enter Password");
                $('#txtUserPass').focus();
                return;

            }
            var Name = $('#txtName').val();
            var chkActive = $('#ChkActive').is(":checked")

            $.ajax({
                type: "POST",
                url: "Pharmacy_Users.aspx/Save",
                data: JSON.stringify({
                    "UserID": UserID,
                    "btnsave": btnsave,
                    "UserCode": UserCode,
                    "Password": Password,
                    "Name": Name,
                    "chkActive": chkActive
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (msg) {
                    window.location.href = 'Pharmacy_Users.aspx';
                },
                Error: function (x, e) {
                    alert(e)
                }
            });

        }

        function loadappt(ID) {
            debugger;
            PageMethods.loadData(ID, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                $('#btnSave').val("Update")
                $('#txtUserCode').val(data[0].User_Code);
                $('#txtUserPass').val(data[0].Password);
                $('#txtName').val(data[0].UserName);
                if (data[0].IsActive == true) {
                    $('#ChkActive').prop("checked", true)
                }
                else {
                    $('#ChkActive').prop("checked", false)

                }

            },

                function (error) {
                    alert(error.get_message());
                });
        }



    </script>

</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Meta Bar -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-user-md"></i> Pharmacy User</span>
        </div>
        <div class="meta-right">
            <div class="meta-badge">
                <span class="badge-label">Code:</span>
                <span class="badge-value" id="pharmacyUserCodeDisplay">---</span>
            </div>
            <div class="meta-badge" id="pharmacyActiveBadge" style="cursor: pointer;" onclick="$('#ChkActive').click();">
                <i class="fa fa-check-circle" id="pharmacyActiveIcon"></i> <span id="pharmacyActiveText">Active</span>
            </div>
            <!-- Hidden checkbox to retain logic -->
            <input type="checkbox" id="ChkActive" style="display:none;" />
        </div>
    </div>

    <div class="row">
        <!-- Left Column: User Credentials -->
        <div class="col-lg-6 col-md-12 pr-cards-column">
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-key"></i> User Credentials</h5>
                <div class="row">
                    <div class="col-md-12">
                        <label for="txtUserCode">User Code *</label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-user"></i></span></div>
                            <input type="text" id="txtUserCode" class="form-control" autocomplete="off" placeholder="Enter user code" />
                        </div>
                    </div>
                </div>
                <div class="row mt-2">
                    <div class="col-md-12">
                        <label for="txtUserPass">Password *</label>
                        <div class="input-group">
                            <input type="password" id="txtUserPass" class="form-control" autocomplete="off" placeholder="Enter password" />
                            <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                                <i class="fa fa-eye" aria-hidden="true"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right Column: User Profile -->
        <div class="col-lg-6 col-md-12 pr-cards-column">
            <div class="pr-primary-settings">
                <h5 class="pr-section-title" style="margin-top:0;"><i class="fa fa-id-card"></i> User Profile</h5>
                <div class="row">
                    <div class="col-md-12">
                        <label for="txtName">Name</label>
                        <div class="input-group">
                            <div class="input-group-prepend"><span class="input-group-text"><i class="fa fa-tag"></i></span></div>
                            <input type="text" id="txtName" class="form-control" autocomplete="off" placeholder="Enter user name" />
                        </div>
                    </div>
                </div>
                <div class="row mt-2">
                    <div class="col-md-12">
                        <label id="lblUsername" class="form-label" style="color:green; font-weight:600;"></label>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="pr-action-buttons">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" id="btnSave" class="btn btn-primry w-100" onclick="SaveRecord()" value="Save" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" id="btnview" class="btn btn-gray w-100" onclick="window.location = 'Pharmacy_UserView.aspx'" value="List View" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-12">
                <input type="button" id="btnnew" class="btn btn-yellow w-100" onclick="window.location = 'Pharmacy_Users.aspx'" value="New" />
            </div>
        </div>
    </div>


</asp:Content>
