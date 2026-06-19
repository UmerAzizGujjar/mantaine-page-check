<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DoctorPayables.aspx.cs" Inherits="PMS.Modules.Billing.DoctorPayables" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
               <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script src="https://cdn.datatables.net/buttons/2.4.2/js/buttons.colVis.min.js"></script>
    <style type="text/css">
  
        .no-skin .nav-list > li .submenu > li > a {
  
            font-size: 14px!important;
        }
        #Table_1 thead{
                font-size: 20px;

        }
        #Table_1{
            line-height: 14.5px;
        }
        .table.table-bordered > thead > tr > th {
                line-height: 12.5px;
        }



        .table-striped>tbody>tr:nth-child(odd)>td, .table-striped>tbody>tr:nth-child(odd)>th{
            background-color:#dfe9f1;
        }
        table[name="SameTable"] {
            margin-left:10px;
        }

        table[name="SameTable"] th {
            font-size: 13px;
            background-color:#438eb9 !important;
            color:#fff;

        }
        .table.table-bordered > thead > tr > th:first-child {

            line-height: 19.5px;

        }
        #lblPayble
        {
            color: blue;
            font-size: 25px;
            margin-left: 11px;
        }
        #totalamt {
            font-size: 23px;
        
            margin-left: 10px;
            background-color: yellow;
        }

        td {
            font-size: 16px;
        }
    </style>


     <script type="text/javascript">


         $(document).ready(function () {
             LoadPage();
             loadDoc();
         });


         function OpenList(id) {
             debugger;
             window.open("DoctorPayables_Services.aspx?ID=" + id);

         }

         function calculateall() {

             debugger;
             var totalamt = 0;

             $.each($('#Table_1 tbody tr'), function (key, value) {
                 debugger;

                 var txtamount = $($(value).find('td input[name=txtamount]')[0]).val();

                 totalamt += parseFloat(txtamount);
             });

             $('#totalamt').text(totalamt.toLocaleString('en'));

         }




         function loadDoc() {

             var optionsDepth = '';

             $.ajax({
                 type: "post",
                 url: "DoctorPayables.aspx/loadDoctors",
                 dataType: 'JSON',
                 contentType: "application/json; charset=utf-8",
                 async: false,
                 success: function (msg) {
                     optionsDepth = '<option value="0">Please Select</option>';
                     var data = JSON.parse(msg.d);
                     $.each(data, function (key, value) {

                         optionsDepth += '<option value="' + value.Emp_ID + '" >' + value.name + '</option>';
                     });

                     $('#ddlDoctor').html(optionsDepth);
                     $('#ddlDoctor').select2();
                 },
                 
             });
         }



         var abc = false;
         function testddlchange() {
             debugger;

             var Statusddl = $('#ddlDoctor').find('option:selected').text();

             if (Statusddl == "Please Select") {
                 abc = true;
                 LoadPage();
             }
             else {
                 var tbl = document.getElementById('Table_1');
                 if (Statusddl.trim() != '') {

                     for (var i = 1; i < tbl.rows.length; i++) {
                         if (tbl.rows[i].cells[3].innerText != Statusddl) {
                             var row = tbl.rows[i];
                             row.style.display = 'none';
                         }
                         else {
                             var row = tbl.rows[i];
                             row.style.display = '';
                         }
                     }
                 }
                 else {
                     for (var i = 1; i < tbl.rows.length; i++) {
                         var row = tbl.rows[i];
                         row.style.display = '';
                     }
                 }
             }
         }
         function LoadPage() {
             debugger;
             async: false;
             $.ajax({
                 async: false,
                 type: "POST",
                 url: "DoctorPayables.aspx/ViewList",
                 data: JSON.stringify({

                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",

                 success: function (data) {
                     debugger;
                     var Priority = '';
                     var length = $("#Table_1 tr:gt(0)").length;

                     if (data != '') {
                         var data = JSON.parse(data.d);
                         $('#Table_1 tr:gt(0)').remove();

                         var rows = '';
                         $.each(data, function (i, item) {

                             var bl = data[i].Balance;

                             rows += '<tr><td style="display:none;"><input type="hidden" value="' + data[i].Doctor_Id + '" name="DocID" id="DocID" ></td><td>' + (i + 1) + '</td><td style="display:none;"><input type="hidden" value="' + data[i].Balance + '" name="txtamount" id="txtamount" ></td> <td>' + data[i].Name + '</td> <td>' + '<a class="HRlink" style="text-decoration-line: underline ; float: right; " href="#" onclick=OpenList(' + data[i].Doctor_Id + ')>' + bl.toLocaleString('en') + '</a>' + '</td></tr>';
                         });
                         $('#Table_1 #tblbody').append(rows);
                         calculateall();
                         $('#Table_1 th:eq(0)').css('background-color', '#438eb9 !important');
                         $('#Table_1 th:eq(1)').css('background-color', '#438eb9 !important');
                         $('#Table_1 th:eq(2)').css('background-color', '#438eb9 !important');

                         $('#Table_1 th:eq(0)').css('color', '#fff !important');
                         $('#Table_1 th:eq(1)').css('color', '#fff !important');
                         $('#Table_1 th:eq(2)').css('color', '#fff !important');

                     }

                     else {

                     }
                 }
             });
         }



     </script>


</asp:Content>
<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">

           <div class="container-fluid">
        <div class="row" style="margin-bottom:14px; margin-top:28px;">

            <div class="col-md-2">

            </div>

            <div class="col-md-4" style="margin-left:-15px;">

                <select id="ddlDoctor" onchange="testddlchange()">

                </select>

            </div>


              <div class="col-md-4" style="margin-left:97px;">
            <label id="lblPayble" >Total Payable:</label>
        <label  id="totalamt" for="fname"> </label>
            </div>

        </div>
<%--        <label id="totalamt"> </label>--%>
        <div class="row">
            <div>
                <table id="Table_1" class="table table-striped table-bordered" style="font-size:13px; font-weight:600;width: 70%;margin-left: 185px;">
                    <thead>
                        <tr >
                            <th>Sr No</th>
                            <th>Doctor Name</th>
                            <th style="text-align: right;">Amount</th>

                        </tr>
                    </thead>
                    <tbody id="tblbody">
                    </tbody>

                </table>
            </div>
</asp:Content>
