<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="IssueMedicineView.aspx.cs" Inherits="PMS.IssueMedicineView" %>
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



            $("#txtSearch").keypress(function (event) {
                var CheckDate = false;
                var SearchString = $('#txtSearch').val();
                if (SearchString.indexOf('-') > -1) {
                    CheckDate = true;
                }
                if (event.which == 13) {
                    {
                        event.preventDefault();
                        $("#VULookup").show();
                        if (SearchString != '') {
                            PageMethods.Search(CheckDate, SearchString, OnFilter, OnFail);
                        }
                    }
                    if (SearchString === '') {
                        FillList();
                    }
                }
            });
            $("#txtSearch").keyup(function (event) {
                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillList();
            });

            //////
            $("#txtSearch").keypress(function (event) {
                var CheckDate = false;
                var SearchString = $('#txtSearch').val();
                if (SearchString.indexOf('-') > -1) {
                    CheckDate = true;
                }
                if (event.which == 13) {
                    {
                        event.preventDefault();
                        $("#VULookup").show();
                        if (SearchString != '') {
                            PageMethods.Search(CheckDate, SearchString, OnFilter, OnFail);
                        }
                    }
                    if (SearchString === '') {
                        FillList();
                    }
                }
            });
            $("#txtSearch").keyup(function (event) {
                var SearchString = $('#txtSearch').val();
                event.preventDefault();
                if (SearchString === '')
                    FillList();
            });
            //////////
            $("#txtSearch").keypress(function (event) {
                var CheckDate = false;
                var SearchString = $('#txtSearch').val();
                if (SearchString.indexOf('-') > -1) {
                    CheckDate = true;
                }
                if (event.which == 13) {
                    {
                        event.preventDefault();
                        $("#VULookup").show();
                        if (SearchString != '') {
                            PageMethods.Search(CheckDate, SearchString, OnFilter, OnFail);
                        }
                    }
                    if (SearchString === '') {
                        FillList();
                    }
                }
            });
            $("#txtMRNo").keyup(function (event) {
                var SearchString = $('#txtMRNo').val();
                event.preventDefault();
                if (SearchString === '')
                    FillList();
            });
        });

        function SearchByParameter() {
            var MrNo = $('#txtMRNo').val();
            var billNo = $('#txtBIllNo').val();
            var Date = $('#txtDate').val();
            PageMethods.Search(billNo, MrNo, Date, OnFilter, OnFail);
        }

        function FillList() {
            var CheckDate = false;
            var billNo = '';
            var MrNo = '';
            var Date = '';
            /* destroy the datatable before filtering */

            //if ($.fn.DataTable.isDataTable('#tbloutPatients')) {
            //    $('#tblResult').DataTable().destroy();
            //}
            $('#tbloutPatients tbody').empty();
            var SearchString = '';
            PageMethods.Search(billNo, MrNo, Date, OnFilter, OnFail);
        }

        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].Bill_ID, data[i].Bill_No, data[i].Bill_Date, data[i].Remarks, data[i].Full_Name, data[i].MR_No);
            }
            $("#loadingimage").hide();
            // ShowDataTable();
        }

        function AddResult(Bill_ID, Bill_No, Bill_Date, Remarks,Full_Name, MR_No) {

            tblLength = tbloutPatients.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Bill_ID + '</span>';
            cell.className = "hide";


            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Bill_No + '</span>';
            //cell.className = "hide";
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Bill_Date + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + MR_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Remarks + '</span>';
          
            cell = row.insertCell(-1);
            cell.innerHTML = '<a class="HRlink" href="#" onclick=editOpen(' + Bill_ID + ')>Edit</a> | <a href="#" onclick=deleteConfirm(this)>Delete</a>';
        }

        function ClearResults() {
            while (tbloutPatients.rows.length > 1) {
                tbloutPatients.deleteRow(1);
            }
        }

        function OnFail(exc) {
            alert(exc.get_message());
        }



        function editOpen(id) {
            window.open("IssuMedicine.aspx?Bill_ID=" + id + "");
        }

        function deleteConfirm(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];

            var Bill_ID = $($(row).find('td')[0]).text();

            if (confirm('Are you sure want to delete this record')) {
                PageMethods.DeleteRecord(Bill_ID, function (msg) {
                    if (msg == '')
                        row.remove();
                    else
                        alert(msg);
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
     <div id="POdetails" style="margin-top: 15px;">
    
        <fieldset>
            <a class="btn red btn-outline sbold" style="text-align: center" href="IssuMedicine.aspx">Add New</a>

        </fieldset>
       <div id="loadingimage" style="margin-left: -1081px;display:none">
                                                     <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                                                </div>
         <fieldset>
              <input type="button" id="btnSearch" style="margin-left:910px; display:none;" class="btn red btn-outline sbold" value="Search"/>            
              <label style="margin-left: 267px;">Search By MR No: </label> 
            <input type="text" id="txtMRNo"  onchange="SearchByParameter()"/>
              <label >Search By Bill No: </label> 
             <input type="text" id="txtBIllNo"  onchange="SearchByParameter()"/>
              <label >Search By Date: </label> 
             <input type="text" id="txtDate"  onchange="SearchByParameter()" placeholder ="dd-Mon-yyyy"/>
             <input type="button" value="Search" onclick="SearchByParameter()"/>

        </fieldset>
        <%--<tr>
            <td>
                <asp:Button Text="Add New" ID="btnNew" runat="server" PostBackUrl="~/BillingProcess.aspx" CausesValidation="false" />
            </td>
            <td><div id="loadingimage" style="margin-left: -1081px;display:none">
                                                     <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                                                </div></td>
        </tr>--%>
       <%-- <tr>
            <td>--%>
    <div style="overflow:scroll; height:600px;">
               
                    <table class="table table-hover table-striped table-bordered" id="tbloutPatients" style="overflow:scroll; height:auto;">
                    <thead id="ihead">
                        <tr>
                             <th class="hide">Bill ID</th>
                            <th>Bill No</th>
                            <th>Bill Date</th>
                            <th>MR NO</th>
                            <th>Patient Name</th>
                            <th>Remarks</th>
                           <%-- <th>Total Amount</th>
                           <th>Discount Percentage</th>
                            <th>Discount Amount</th>
                            <th>Net Amount</th>
                            <th>Received Amount</th>
                            <th>Balance Amount</th>--%>
                            <th style="width: 68px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
        </div>
        </div>
</asp:Content>
