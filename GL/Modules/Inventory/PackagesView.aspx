<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PackagesView.aspx.cs" Inherits="PMS.PackaageView" %>
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



    <script type="text/javascript">
        $(document).ready(function () {
            FillList();
        });

        function FillList() {

            $("#VULookup").show();

            /* destroy the datatable before filtering */

            if ($.fn.DataTable.isDataTable('#tblPackage')) {
                $('#tblResult').DataTable().destroy();
            }
            $('#tblPackage tbody').empty();

            PageMethods.Search(OnFilter, OnFail);
        }


        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].Packages_ID, data[i].Package_Name, data[i].Package_Type, data[i].Department, data[i].Duration, data[i].Remarks);
            }

            $("#VULookup").hide();

            ShowDataTable();



        }

        function ClearResults() {
            while (tblPackage.rows.length > 1) {
                tblPackage.deleteRow(1);
            }
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }

        function AddResult(Packages_ID, Package_Name, Package_Type, Department, Duration, Remarks) {
            
            tblLength = tblPackage.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Packages_ID + '</span>';
            //cell.className = "hide";
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Package_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Package_Type + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Department + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Duration + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Remarks + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<a class="HRlink" href="#" onclick=editOpen(' + Packages_ID + ')>Edit</a> | <a href="#" onclick=deleteConfirm(this)>Delete</a>';
        }

        function editOpen(id) {

            window.location="Packages.aspx?ID=" + id + "";

        }

        function deleteConfirm(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];


            var PakgID = $($(row).find('td')[0]).text();            

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(PakgID, function (msg) {
                    row.remove();
                }, OnFail);
            }
        }

        function ShowDataTable() {
            $(document).ready(function () {

                $('#tblPackage').DataTable({

                });

            });
        }
</script>     
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <table style="width:100%;">
        <tr>
            <td>
                <asp:Button Text="Add New" ID="Button1" runat="server" PostBackUrl="~/Inventory/Packages.aspx" CausesValidation="false" />
            </td>
        </tr>
           </table>
        <table class="table table-hover table-striped table-bordered" id="tblPackage">
            <thead id="ihead">
                <tr>     
                    <th>Package ID</th>               
                    <th>Package Name</th>
                    <th>Package Type</th>
                    <th>Department</th>
                     <th>Duration</th>
                     <th>Remarks</th>           
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody id="ibody">
            </tbody>
        </table>
</asp:Content>
