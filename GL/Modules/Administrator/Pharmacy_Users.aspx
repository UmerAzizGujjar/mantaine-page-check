<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Pharmacy_Users.aspx.cs" Inherits="PMS.Pharmacy_Users" %>


<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
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

    <div class="row g-3">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="txtUserCode">UserCode:</label>
            <input type="text" id="txtUserCode" class="form-control" autocomplete="off" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="txtUserPass">Password:</label>
            <div class="input-group">
                <input type="password" id="txtUserPass" class="form-control" autocomplete="off" />
                <button class="btn btn-outline-secondary" type="button" id="togglePassword">
                    <i class="fa fa-eye" aria-hidden="true"></i>
                </button>
            </div>
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label for="txtName">Name:</label>
            <input type="text" id="txtName" class="form-control" autocomplete="off" />
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12 d-flex align-items-center">
            <label for="ChkActive" class="me-2">Active:</label>
            <input type="checkbox" id="ChkActive" />
        </div>
    </div>

    <!-- Row 2 -->
    <div class="row g-3">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <label id="lblUsername" class="form-label"></label>
        </div>
    </div>

    <!-- Row 3 -->
    <div class="row g-3">
        <div class="col-lg-1 col-md-6 col-sm-12">
            <input type="button" id="btnSave" class="btn btn-primry w-100" onclick="SaveRecord()" value="Save" />
        </div>
    </div>


</asp:Content>
