<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DiscountAssigned_List.aspx.cs" Inherits="PMS.DiscountAssigned_List" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script type="text/javascript" src="Scripts/jquery.ptTimeSelect.js"></script>
    <script src="Scripts/moment.js"></script>
    <script src="Scripts/moment.min.js"></script>
    <script type="text/javascript"> 


       $(document).ready(function () {
            debugger;
            LoadPage();
            $('#myInput').on('keyup',function (e) {
                debugger;
                //var CheckAll = $('#chkTodayAll').checked;

                var MRno = $('#myInput').val();

                var tbl = document.getElementById('Table_Ass');
                if (MRno != "") {
                    if (MRno.trim() != '') {

                        for (var i = 1; i < tbl.rows.length; i++) {
                            if (tbl.rows[i].cells[1].innerText != MRno) {
                                var row = tbl.rows[i];
                                row.style.display = 'none';
                            }
                            else {
                                var row = tbl.rows[i];
                                row.style.display = '';
                            }
                        }
                    }
                }

                else {
                    for (var i = 1; i < tbl.rows.length; i++) {
                        var row = tbl.rows[i];
                        row.style.display = '';
                    }

                }
            });
            });



        function LoadPage() {
            debugger;
         
            //Append data from data base table

            debugger;
            $.ajax({
                type: "POST",
                url: "DiscountAssigned_List.aspx/Discount_Assigned_list",
                data: JSON.stringify({

                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (data) {
                    debugger;
                    abc = false;
                    var Priority = '';

                    var length = $("#Table_Ass tr:gt(0)").length;
                    
                    if (data != '') {
                        var data = JSON.parse(data.d);
                        var rows = '';
                        

                        $.each(data, function (i, item) {
                            var date_Cat = moment(data[i].Created_Time).format('L');
                   
                            debugger;
                            rows += '<tr><td>' + data[i].Discount_Assigned_Patient_Id + '</td><td>' + data[i].Patient_No + '</td><td>' + data[i].Patient_Name + '</td><td>' + data[i].Discount_Category_Id + '</td><td>' + date_Cat + '</td><td style ="width: 100px;"><a href="#" onclick="Edit(' + data[i].Discount_Assigned_Patient_Id + ')" style="border-radius: 4px; background-color: #428bca; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;">Edit</a></td></tr>';

                        });

                        $('#t_body').html(rows);

                    }

                    else {

                    }

                    debugger;
                }
            });
        }



        function Edit(AID) {
            window.location.href = "DiscountAssigned.aspx?ID=" + AID;

        }


    </script>

           
   <style type="text/css">
        #Table_Ass th{
            position:sticky;
            top:0px;
            background-color:#167f92;
            color:white;
        }
   </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <div class="container">
            <input type="text" id="myInput" placeholder="Search..."/>
               <table class="table table-hover table-striped table-bordered" id="Table_Ass" style="overflow: scroll; height: auto;">
               
                    <tr id="row_sample">
                        <th>ID</th>
                        <th>MR No</th>
                         <th>Patient Name</th>
                        <th>Discount Category</th>
                        <th>Create Time</th>
            
                        <th style="text-align:center;">ACTION</th>


                    </tr>

                <tbody id="t_body">
                </tbody>

            </table>





    </div>
</asp:Content>
