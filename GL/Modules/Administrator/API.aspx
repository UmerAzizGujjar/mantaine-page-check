<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="API.aspx.cs" Inherits="PMS.Modules.Administrator.API" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        body {
            align-items: center;
            justify-content: center;
            height: 100vh;
            margin: 0;
        }
        .login-card {
            background:rgb(123 2 2 / 68%);
            border-radius: 20px;
            padding: 30px;
            width: 100%;
            max-width: 400px;
            color: #fff;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            position: relative;
            left:30% !important ;
        }
        .login-card img {
            width: 80px;
            display: block;
            margin: 0 auto 20px;
        }
        .login-card h2 {
            font-size: 1.5rem;
            text-align: center;
            margin-bottom: 0.5rem;
        }
        .login-card h2 span {
            color: #f8d42d;
        }
        .login-card p {
            font-size: 0.9rem;
            text-align: center;
            margin-bottom: 1.5rem;
        }
        .login-card .form-control {
            background-color: #fff;
            border: none;
            border-radius: 5px;
            margin-bottom: 1rem;
            color: #333;
        }
        .login-card .btn-login {
            background-color: #e63946;
            border: none;
            border-radius: 5px;
            width: 100%;
            padding: 0.75rem;
            font-size: 1rem;
            color: #fff;
            margin-top: 1rem;
        }
        .login-card .support-info {
            text-align: center;
            font-size: 0.8rem;
            margin-top: 1rem;
        }
        .login-card .support-info a {
            color: #fff;
        }
        .login-card .support-info p {
            margin: 0;
        }
    </style>
    <script type="text/javascript">
        
            $(document).ready(function () {
                $('#Accessbtn').click(function () {
                    debugger;
                    var username = $('#username').val();
                    var password = $('#password').val();
                    if (username === "" || password === "") {
                        alert("Please fill in both fields.");
                        return;
                    }

                    $.ajax({
                        type: "POST",
                        url: "API.aspx/SaveApiCredentials", 
                        data: JSON.stringify({ username: username, password: password }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                                alert("Access Granted")
                                window.location.reload();
                              
                        },
                        error: function (xhr, status, error) {
                            console.error(xhr.responseText);
                            alert("An error occurred. Please try again.");
                        }
                    });
                });
    });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <div class="login-card">
        <img src="../../wwwroot/images/HMIS_Icons/TibbITLogo_1.png" alt="Logo"> 
        <h2>TibbIT By <span>Garaj</span></h2>
        <p>@Health Tech Platform</p>
      
            <div class="form-group">
                <label>API User</label>
                <input type="text" id="username" class="form-control">
            </div>
            <div class="form-group">
                <label>API Password</label>
                <input type="password" id="password" class="form-control">
            </div>
            <input type="button" id="Accessbtn" class="col-lg-2 col-md-4 col-sm-6" value="Access Granted" />
     
        <div class="support-info">
            <p>Our 24/7 support:</p>
            <p>Email: <a href="mailto:cloud.support@jazz.com.pk">cloud.support@jazz.com.pk</a></p>
            <p>Contact: 0304 111 0365</p>
        </div>
    </div>
</asp:Content>
