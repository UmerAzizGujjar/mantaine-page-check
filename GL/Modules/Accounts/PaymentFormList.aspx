<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="PaymentFormList.aspx.cs" Inherits="PMS.PaymentFormList" %>
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
            $("#tbloutPatients_length").hide();
            $("#tbloutPatients_filter").hide();
        });
        
        function SearchByParameter() {
            var MrNo = $('#txtMRNo').val();
            var TransactionNo = $('#txtTransactionNo').val();
            var Date = $('#txtDate').val();
            PageMethods.Search(TransactionNo, MrNo, Date, OnFilter, OnFail);
        }

        function FillList() {
            var CheckDate = false;
            var TransactionNo = '';
            var MrNo = '';
            var Date = '';
            /* destroy the datatable before filtering */

            //if ($.fn.DataTable.isDataTable('#tbloutPatients')) {
            //    $('#tblResult').DataTable().destroy();
            //}
            $('#tbloutPatients tbody').empty();
            var SearchString = '';
            PageMethods.Search(TransactionNo, MrNo, Date, OnFilter, OnFail);

            $("#tbloutPatients tr").find('th:eq(14)').hide();
            $("#tbloutPatients tr").find('td:eq(14)').hide();
        }

        function OnFilter(data) {

            ClearResults();

            for (var i = 0; i < data.length; i++) {
                AddResult(data[i].PaymentForm_ID, data[i].PaymentForm_No, data[i].PaymentForm_Date, data[i].Remarks, data[i].Discount_Percentage, data[i].Discount_Amount, data[i].Net_Amount, data[i].Received_Amount, data[i].Total_Amount, data[i].Balance_Amount, data[i].Full_Name, data[i].MR_No, data[i].Operator);
            }
          $("#loadingimage").hide();
           // ShowDataTable();
        }

        function AddResult(Payment_ID, Payment_No, Payment_Date, Remarks, Discount_Percentage, Discount_Amount, Net_Amount, Received_Amount, Total_Amount, Balance_Amount, Full_Name, MR_No, Operator) {

            tblLength = tbloutPatients.rows.length;

            var row = ibody.insertRow(-1);
            var cell;

            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Payment_ID + '</span>';
            cell.className = "hide";


            cell = row.insertCell(-1);
            cell.innerHTML = '<span spnPatID' + tblLength + '>' + Payment_No + '</span>';
            //cell.className = "hide";
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Payment_Date + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + MR_No + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Full_Name + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Remarks + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Total_Amount + '</span>';
            cell = row.insertCell(-1);
            //cell.innerHTML = '<span class="HRcontent">' + Discount_Percentage  + '</span>';
            //cell = row.insertCell(-1);
            //cell.innerHTML = '<span class="HRcontent">' + Discount_Amount + '</span>';
            //cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Net_Amount + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Received_Amount + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Balance_Amount + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="HRcontent">' + Operator + '</span>';
            cell = row.insertCell(-1);
            cell.innerHTML = '<a class="HRlink" href="#" onclick=editOpen(' + Payment_ID + ')>Edit</a>';
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
            window.open("PaymentForm.aspx?ID=" + id + "");
        }
        function CancelConfirm(anchorTag) {


            var row = $(anchorTag).parents('tr')[0];
            var Bill_ID = $($(row).find('td')[0]).text();
            var BillNo = $($(row).find('td')[1]).text();

            $("#tbloutPatients tr").find('th:eq(14)').show();
            $("#tbloutPatients tr").find('td:eq(14)').show();
            cell = row.insertCell(-1);
            cell.innerHTML = '<span class="show" style="width:100px;"><input type="text" id="txtCancel" onchange="cancelPatient(this)"/></span>';

        }
        function cancelPatient(anchorTag) {

            var row = $(anchorTag).parents('tr')[0];
            var Bill_ID = $($(row).find('td')[0]).text();
            var BillNo = $($(row).find('td')[1]).text();
            var reason = $(row).find($("input[type=text]")).val();
            if (confirm('Are you sure want to Cancel this Bill:- ' + BillNo)) {
                PageMethods.CancelPatient(Bill_ID, reason, function (msg) {
                    if (msg == "Allowdlt") {
                        alert('You have no right to Cancel. ')

                    }
                    else if (msg == "success") {

                        row.remove();
                    }
                    else {
                        alert('Unable to Cancel this patient, because this patient has uncanceled Reciept ')
                    }

                },

                OnFail);
            }

            window.location.href = "BillingProcessView.aspx";
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
            <a class="btn red btn-outline sbold" style="text-align: center" href="PaymentForm.aspx">Add New</a>

        </fieldset>
       <div id="loadingimage" style="margin-left: -1081px;display:none">
                                                     <asp:Image ID="image2" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                                                </div>
         <fieldset>
              <input type="button" id="btnSearch" style="margin-left:910px; display:none;" class="btn red btn-outline sbold" value="Search"/>            
              <label style="margin-left: 267px;">Search By MR No: </label> 
            <input type="text" id="txtMRNo"  onchange="SearchByParameter()"/>
              <label >Search By Transaction No: </label> 
             <input type="text" id="txtTransactionNo"  onchange="SearchByParameter()"/>
              <label >Search By Date: </label> 
             <input type="text" id="txtDate"  onchange="SearchByParameter()" placeholder ="dd-Mon-yyyy"/>
             <%--<input type="button" value="Search" onclick="SearchByParameter()"/>--%>

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
                             <th class="hide">Transaction ID</th>
                            <th>Transaction No</th>
                            <th>Transaction Date</th>
                            <th>MR NO</th>
                            <th>Patient Name</th>
                            <th>Remarks</th>
                            <th>Total Amount</th>
                         <%--   <th>Discount Percentage</th>
                            <th>Discount Amount</th>--%>
                            <th>Net Amount</th>
                            <th>Received Amount</th>
                            <th>Balance Amount</th>
                            <th>Operator</th>    
                            <th style="width: 68px;">Actions</th>
                            <%--<th>Cancel remarks</th>--%>
                        </tr>
                    </thead>
                    <tbody id="ibody">
                    </tbody>
                </table>
        </div>
        </div>
</asp:Content>
