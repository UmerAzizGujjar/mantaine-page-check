<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Pharmacy_UserView.aspx.cs" Inherits="PMS.Pharmacy_UserView" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
            LoadPage();
        });

        function Edit(ID) {
            window.location.href = "Pharmacy_Users.aspx?ID=" + ID;
        }

        function LoadPage() {
            debugger;
            $.ajax({
                type: "POST",
                url: "Pharmacy_UserView.aspx/ViewList",
                data: JSON.stringify({
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (data) {
                    var length = $("#table_res tr:gt(0)").length;
                    if (data != '') {
                        var data = JSON.parse(data.d);
                        var rows = '';
                        $.each(data, function (i, item) {
                            debugger;
                            rows += '<tr><td>' + (i + 1) + '</td><td>' + data[i].User_Code + '</td><td>' + data[i].UserName + '</td><td style="width: 188px";><a href="#" onclick="Edit(' + data[i].UserID + ')" class="fa fa-pencil " style="color:#438eb9  !important;font-size:18px;" ></a></td></tr>';

                        });

                        $('#t_body').html(rows);
                    }

                    else {

                    }

                }
            });
        }






    </script>





</asp:Content>




<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="table-container">
        <div class="row row_4">

            <table class="table table-hover table-striped table-bordered" id="table_res" style="overflow: scroll; height: auto; width: 610px; margin: auto;">
                <thead>
                    <tr id="row_sample">
                        <th style="width: 75px;">SNo</th>
                        <th style="width: 100px;">User Code</th>
                        <th style="width: 413px;">User Name</th>
                        <th style="text-align: center;">ACTIONS</th>
                    </tr>
                </thead>


                <tbody id="t_body">
                </tbody>

            </table>

        </div>
    </div>

</asp:Content>
