<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountDefination_List.aspx.cs" Inherits="PMS.DiscountDefination_List" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

 <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script src="Scripts/moment.js"></script>
    <script src="Scripts/moment.min.js"></script>
    <script type="text/javascript">




        $(document).ready(function () {
            LoadPage();
         
            });



        function LoadPage() {
         
            //Append data from data base table

            $.ajax({
                type: "POST",
                url: "DiscountDefination_List.aspx/Discount_Defination_list",
                data: JSON.stringify({

                }),


                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (data) {
                    abc = false;
                    var Priority = '';

                    var length = $("#Table_Def tr:gt(0)").length;
                    
                    if (data != '') {
                        var data = JSON.parse(data.d);
                        var rows = '';
                        

                        $.each(data, function (i, item) {
                            var date_Cat = moment(data[i].Created_Time).format('L');
                   
                            rows += '<tr><td>' + data[i].Discount_Definition_Id + '</td><td>' + data[i].Discount_Category_Id + '</td><td>' + date_Cat + '</td><td style ="width: 100px;"><a href="#" onclick="Edit(' + data[i].Discount_Definition_Id + ')" style="border-radius: 4px; background-color: #428bca; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;">Edit</a></td></tr>';

                        });

                        $('#t_body').html(rows);

                    }

                    else {

                    }

                }
            });
        }


        function Edit(DID) {
            window.location.href = "DiscountDefinition.aspx?ID=" + DID;

        }


    </script>

       
   <style type="text/css">
        #Table_Def th{
            position:sticky;
            top:0px;
            background-color:#167f92;
            color:white;
        }
   </style>


</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col">
            <input type="button" />
        </div>
    </div>
    <div class="container">
               
               <table class="table table-hover table-striped table-bordered" id="Table_Def" style="overflow: scroll; height: auto;">
               
                    <tr id="row_sample">
                        <th>ID</th>
                        <th>Discount Category</th>
                        <th>Create Time</th>
            
                        <th style="text-align:center;">ACTION</th>


                    </tr>

                <tbody id="t_body">
                </tbody>

            </table>





    </div>



</asp:Content>
