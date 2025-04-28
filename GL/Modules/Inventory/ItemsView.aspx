<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ItemsView.aspx.cs" Inherits="PMS.WebForm4" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <script type="text/javascript" src="javascripts/DataTable/jquery-2.2.3.js"></script>
    <script type="text/javascript" src="javascripts/DataTable/jquery-2.2.3.min.js"></script>
    <link rel="stylesheet" type="text/css" href="javascripts/DataTable/datatables.min.css" />
    <script type="text/javascript" src="javascripts/DataTable/datatables.min.js"></script>
    <script type="text/javascript" src="javascripts/DataTable/ColReorderWithResize.js"></script>
    <script type="text/javascript" src="stylesheets/bootstrap/js/bootstrap.js"></script>
    <link rel="stylesheet" type="text/css" href="stylesheets/bootstrap/css/bootstrap.css" />

    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css" />
    <script type="text/javascript" src="//code.jquery.com/jquery-1.12.3.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>

    <style type="text/css">
       
        table.tabclss tr td {
            padding: 5px;
        }

        .table th {
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            padding: 1em;
        }

        .table thead th {
            display: table-cell;
            text-align: center;
        }

        .table tbody tr td {
            border: none !important;
        }

        .table tr td input {
            height: 25px !important;
            width: 100% !important;
        }

        .hide {
            display: none;
        }
        .alignCenter {
            text-align:center;
        }
       
    </style>

    <script type="text/javascript">
        $(document).ready(function () {
            $('#loadingimage').show();
            FillList();
        });

        function FillList() {

            $("#VULookup").show();

            /* destroy the datatable before filtering */

            if ($.fn.DataTable.isDataTable('#tbloutPatients')) {
                $('#tblResult').DataTable().destroy();
            }
            $('#tbloutPatients tbody').empty();

            PageMethods.Search(OnFilter, OnFail);
        }


        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].Item_ID, data[i].Item_Code, data[i].Description, data[i].UOM, data[i].Sale_Rate, data[i].Category_Name, data[i].Item_Type);
            }

            $("#VULookup").hide();
            $("#loadingimage").hide();
            ShowDataTable();



        }

        function ClearResults() {
            while (tbloutPatients.rows.length > 1) {
                tbloutPatients.deleteRow(1);
            }
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }

        function AddResult(Item_ID, Item_Code, Description, UOM, Sale_Rate, Category_Name, Item_Type) {
            tblLength = tbloutPatients.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Item_ID + '</span>';
            cell.className = "hide";

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Item_Code + '</span>';
           
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Description + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + UOM + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Sale_Rate + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Category_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Item_Type + '</span>';
          
            cell = row.insertCell(-1);
            cell.innerHTML = '<a class="fa fa-pencil" style="color:#0a32a0db;font-size:18px;" href="#" onclick=editOpen(' + Item_ID + ')></a> | <a href="#" style="color:indianred;font-size:18px;" onclick=deleteConfirm(this)> <i class="fa fa-trash" aria-hidden="true"></i></a>';
        }

        function editOpen(id) {
           
            window.location.href="Items.aspx?ID=" + id + "";

        }

        function deleteConfirm(anchorTag)
        {

            var row = $(anchorTag).parents('tr')[0];
            var ItemID = $($(row).find('td')[0]).text();

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(ItemID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }

        function ShowDataTable() {
            $(document).ready(function () {

                $('#tbloutPatients').DataTable({

                });

            });
        }
    </script>     
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

     <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/Inventory/Items.aspx" CausesValidation="false" />
            </td>
            <td><div id="loadingimage" style="margin-left: -1081px;display:none">
                                                     <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                                                </div></td>
        </tr>
           </table>
        <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
            <thead id="ihead">
                <tr>                  
                    <th style="display:none;">Item ID</th>  
                    <th>Item Code</th>
                    <th>Description</th>
                    <th>UOM</th>
                    <th>Sales Rate</th>  
                    <th>Item Category Name</th>  
                    <th>Item Type</th>                                          
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody id="ibody">
            </tbody>
        </table>

</asp:Content>