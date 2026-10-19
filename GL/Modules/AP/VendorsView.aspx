<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="VendorView.aspx.cs" Inherits="PMS.AP.VendorView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
         <link href="css/stock.css" rel="stylesheet" />
        
        <link rel="stylesheet" href="table-style/bootstrap.css">
            <link rel="stylesheet" href="table-style/jquery-ui.css">
             <link rel="stylesheet" href="table-style/dataTables.jqueryui.min.css">
             <link rel="stylesheet" href="table-style/buttons.jqueryui.min.css">
       <link href="Styles/jquery.datetimepicker.css" rel="stylesheet" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.1.1/css/all.min.css" integrity="sha512-KfkfwYDsLkIlwQp6LFnl8zNdLGxu9YAA1QvwINks4PhcElQSvqcyVLLD9aMhXd13uQjoXtEKNosOWaZqXgel0g==" crossorigin="anonymous" referrerpolicy="no-referrer" />



<script src="table-style/jquery.dataTables.min.js"></script>
<script src="table-style/dataTables.jqueryui.min.js" ></script>

    <script src="table-style/datatables.buttons.min.js"></script>
    <script src="table-style/buttons.jqueryui.min.js"></script>
    <script src="table-style/jszip.min.js"></script>
    <script src="table-style/pdfmake.min.js"></script>
    <script src ="https://cdn.datatables.net/buttons/2.2.3/js/datatables.buttons.min.js"></script>
    <script src="table-style/vfs_fonts.js" ></script>
    <script src="table-style/buttons.html5.min.js" ></script>
    <script src="table-style/buttons.print.min.js" ></script>
    <script src="table-style/buttons.colvis.min.js"></script>
     <script src="table-style/buttons.print.min.js" ></script>
    
    <script src="http://datatables.net/reference/option/dom" ></script>
     <style type="text/css">


        .sidebar.h-sidebar .nav-list > li > a {
text-align: center !important;
line-height: 22px !important;
height: auto !important;
font-family: Arial, sans-serif !important;
padding: 10px 14px !important;
font-weight: bold !important;
}

#th-brnch{
    width:200px !important;
}
.nav-list > li .submenu > li.hover > a {
font-size: 13px !important;
font-family: Arial, sans-serif !important;
font-weight: bold !important;
}


      .table{
          width:100%;
          font-size:small;
          line-height:1.5px;
          font-weight:400 !important;
      }
      .table>tbody>tr>td{
          line-height: 1.75;
      }
      .table>thead>tr>th{
          line-height: 0.75;
      }
      .dataTables_wrapper .dataTables_paginate {
    font-size: small;
    width:300px;
}
      .main input {
    margin-bottom: -5px !important;
}
      .buttons-copy{
          width:20%;
          border-radius:12px;
              background-color: #8b8f8c !important;
              color: white !important;
      }
      .buttons-excel{
          width:20%;
          border-radius:12px;
              background-color: #5e8a6a !important;
              color: white !important;
      }
      .buttons-pdf{
          width:20%;
          border-radius:12px;
              background-color: #e04343 !important;
              color: white !important;
      }
      .buttons-colvis{
          width:38%;
          border-radius:12px;
              background-color: #4052a1 !important;
              color: white !important;
      }
      div.dt-buttons {
    position: center;
    float: left;
    width: 34%;
    margin-top:15px;
    margin-left:150px;
}
        .ui-button-text-only .ui-button-text {
            font-weight: 900;
        }
        .dataTables_info {
    font-size: 14px;
    font-weight: 700 !important;
}



        .dataTables_wrapper .ui-toolbar {
    padding: 3px;
}
        table.dataTable thead th div.DataTables_sort_wrapper span {
    display: none;
}
        #txt_date{
            height:32px;
        }
        #example_wrapper{
            background-color: #e7e7e7;
               /* width: 1125px !important;*/
        }
        #check{
            width:5% !important;
        }
        .info_btn{
            border-radius: 12px;
            width: 7%;
            margin-bottom:7px;
              font-size: 14px;
               font-weight: 700;
}
        .dataTables_filter input{
            border-radius:15px !important;
           

        }
        .dataTables_filter {
            margin-top:20px;
        }
        body{
            font-weight:700;

        }

        #ui-datepicker-div{

            width:20%!important;
        }

        .btn-addnew{
            top: -5px !important;
        }
        .fa-pencil{
            color: green !important;
        } 
        .fa-print{
            color: darkblue !important;
        }
        /* .odd:nth-child(1) {

             text-align:right;
         }*/
         td:first-child { 
             text-align: center ;
         }
         td:nth-child(5){
             text-align: right ;
         }

    </style>

    <script type="text/javascript">
        var isDele = '';
        $(document).ready(function () {
            /* LoadPage();*/
            //isDeleteAllow();
            $('#tblResult').DataTable(
                {
                    "processing": true,

                    dom: 'lBfrtip',



                    lengthChange: true,
                    buttons: ['copy', 'excel', 'pdf'],
                    "serverSide": true,
                    "ajax":
                    {
                        "url": "VendorView.aspx/getlist",
                        "contentType": "application/json",
                        "type": "GET",
                        "dataType": "JSON",
                        "data": function (d) {

                            return d;
                        },

                        "dataSrc": function (json) {
                            json.draw = json.d.draw;
                            json.recordsTotal = json.d.recordsTotal;
                            json.recordsFiltered = json.d.recordsFiltered;
                            json.data = json.d.data;
                            var return_data = json;
                            return return_data.data;
                        }
                    },

                    "columns": [
                        { "data": "Vendor_Name" },
                        { "data": "Contact_Person" },
                        { "data": "Vendor_Phone1" },
                        { "data": "Vendor_Address" },
                        { "data": "City" },
                        { "data": "Vendor_NTN" },
                        
                        {
                            render: function (data, type, full) {
                                var res = '<a href="#" onclick="Edit(' + full.Vendor_ID + ')" style="border-radius: 4px;margin-right: 4px; background-color: #5399af; color: white; padding: 5px 8px 5px 8px;"><i class="fa-solid fa-eye"></i></a>';

                              /*  var del = '<a style="border-radius: 4px; background-color: red; color: white; padding: 5px 8px 5px 8px;" href="#" onclick="deleteConfirm(' + full.Vendor_ID+')" id="btnDel' + (full + 1) + '"><i class="fa-solid fa-trash"></i></a>';*/

                                



                                var result;

                                if (isDele == true) {
                                    if (full.Status == "Approved") {
                                        result = res ;
                                    }
                                    else {
                                        result = res  ;
                                    }
                                }
                                else {
                                    result = res;
                                }



                                return result;
                            }
                        },
                        




                    ]
                });

        });




        function OnFail(exc) {
            alert(exc.get_message());
        }
        //function isDeleteAllow() {
        //    $.ajax({
        //        type: "POST",
        //        contentType: "application/json; charset=utf-8",
        //        url: "VendorView.aspx/isDeleteAllow",
        //        data: "",
        //        success: function (resp) {
        //            if (resp.d == true) {
        //                isDele = true;
        //            }
        //            else {
        //                isDele = false;
        //            }

        //        }, error: function () { }


        //    })

        //}
        function Edit(ID) {
            window.location.href = "Vendor.aspx?ID=" + ID;

        }

        //function AutoGRN(ID)
        //{
           
        //      var IgpId=ID;
        //      PageMethods.AutoGRN(IgpId, function (Tests) {
        //          var message = JSON.parse(Tests);
        //          if (message[0].Column1 != "" || message[0].Column1 != null) {
                     
        //              location.reload();
        //          }

        //      });
 
        //}

        //function EditGRN(ID) {
        //    window.location.href = "GRN.aspx?GRN_ID=" + ID;

        //}

        function deleteConfirm(Vendor_ID) {
            //var row = $(anchorTag).parents('tr')[0];


           // var Vendor_ID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Vendor_ID, function (msg) {
                    $(row).remove();
                  
                }, OnFail);
            }
            window.location.href = "VendorsView.aspx?";
        }

    </script>

    <div id="PurchaseRequistiondetails" style="margin-top: 15px;">
        <div class="row">
             <div class="col-md-1">
           <input type="button" id="aadnew" value="Add New" onclick="location.href = 'Vendor.aspx';" style="margin-left: 16px;" />
       </div>
        </div>
         <div>
        <table class="table table-hover table-striped table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>                    
                    <th>Vendor Name</th>
                    <th>Contact Person</th>
                    <th>Phone No:</th>
                    <th>City</th>
                    <th>Email</th>                                          
                    <%-- <th>VehicleNum</th>  --%>
                    <th>NTN</th>
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody id="ibody">
            </tbody>
        </table>
        </div>
         </div>
</asp:Content>
