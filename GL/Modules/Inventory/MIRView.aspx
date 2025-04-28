<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MIRView.aspx.cs" Inherits="PMS.Inventory.MIRView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        
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
            /*   LoadPage();*/
            isDeleteAllow();
            $('#tblResult').DataTable(
                {
                    "processing": true,

                    dom: 'lBfrtip',



                    lengthChange: true,
                    buttons: ['copy', 'excel', 'pdf'],
                    "serverSide": true,
                    "ajax":
                    {
                        "url": "MIRView.aspx/MIR_Master",
                        "contentType": "application/json",
                        "type": "GET",
                        "dataType": "JSON",
                        "data": function (d) {
                            debugger;

                            return d;
                        },

                        "dataSrc": function (json) {
                            debugger;
                            json.draw = json.d.draw;
                            json.recordsTotal = json.d.recordsTotal;
                            json.recordsFiltered = json.d.recordsFiltered;
                            json.data = json.d.data;
                            var return_data = json;
                            return return_data.data;
                        }
                    },

                    "columns": [
                        { "data": "Request_No" },
                        {
                            "data": "Priority",
                            "render": function (data, type, full) {                                debugger;                                var Priority = full.Priority;                                if (Priority == 1) {
                                    Priority = "High";
                                } else {
                                    Priority = "Low";
                                }                                return Priority;                            }
                        },
                        { "data": "Department" },
                    /*    { "data": "InventoryOrganization" },*/
                        { "data": "Remarks" },
               

                        {
                            render: function (data, type, full) {
                                debugger;
                                var res = ' <a href="#" onclick="Edit(' + full.MaterialRequest_Id + ')" style="border-radius: 4px;margin-right: 4px; background-color: #1f1fe3; color: white; padding: 5px 8px 5px 8px;"><i class="fa-solid fa-pen"></i>'

                                var del ='</a><a  href="#"  onclick="deleteConfirm(this)" id="btnDel' + (full + 1) + '"style="border-radius: 4px; background-color: red; color: white; padding: 5px 8px 5px 8px;"><i class="fa-solid fa-trash"></i></a>';

                                var print = '<a style = "border-radius: 4px;background-color:#387024;margin-left: 4px;color: white;padding: 5px 8px 5px 8px;" href = "#" onclick = "Print(' + full.MaterialRequest_Id + ')" id = "btnprint" ><i class="fa-solid fa-print"style="color:white !important;"></i></a >';





                                var result;



                                if (isDele == true) {
                                    if (full.Status == "Approved") {
                                        result = res + print;
                                    }
                                    else {
                                        result = res + del + print;
                                    }
                                }
                                else {
                                    result = res + print
                                }

                                return result;




                            }
                        }




                    ]
                });
        })


        function Print(id) {
            debugger;
            var locationInfo = window.location;
            var url = '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            if (!locationInfo.origin.includes('localhost')) {
                var urlInfo = window.location.href.split('/');
                var ip = urlInfo[2];
                var foldername = urlInfo[3];

                url = 'http://' + ip + '/' + foldername + '/ReportViewer.aspx?ReportName=MaterialIssueRequestList&ReportTitle=Material IssueRequest List&MIRId=' + id;
            }
            window.location.href = url;
        }


        function OnFail(exc) {
            alert(exc.get_message());
        }

        function Edit(ID) {
            window.location.href = "MaterialIssueRequest.aspx?ID=" + ID;

        }
        function isDeleteAllow() {
            $.ajax({
                type: "POST",
                contentType: "application/json; charset=utf-8",
                url: "MIRView.aspx/isDeleteAllow",
                data: "",
                success: function (resp) {
                    debugger;
                    if (resp.d == true) {
                        isDele = true;
                    }
                    else {
                        isDele = false;
                    }

                }, error: function () { }


            })

        }
        function deleteConfirm(anchorTag) {
            debugger;
            var row = $(anchorTag).parents('tr')[0];


            var PRID = $($(row).find('td')[0]).text();


            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(MIRID, function (msg) {
                    debugger
                    $(row).remove();
                }, OnFail);
            }
        }

    </script>

    <div id="PurchaseRequistiondetails" style="margin-top: 15px;">

        <input type="button" id="aadnew" value="Add New" onclick="location.href = 'InversionGatePass.aspx';" style="margin-left: 16px;" />
         <%-- <fieldset>
            <a class="btn red btn-outline sbold" style="text-align: center" href="MaterialIssueRequest.aspx">Add New</a>
              </fieldset>--%>
         <div>
        <table class="table table-hover table-striped table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>                    
                    <th style="width: 63px;">Request_No</th>
                    <th style="width: 63px;">Pirority</th>   
                    <th style="width: 200px;">Department</th>   
                     <%--<th>Inventory Organizations</th>--%>
                     <th>Remarks</th>                               
                    <th style="width: 81px;">Actions</th>
                </tr>

            </thead>

            <tbody id="ibody">
            </tbody>
        </table>
        </div>
         </div>
</asp:Content>
