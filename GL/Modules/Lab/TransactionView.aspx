<%@ Page Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TransactionView.aspx.cs" Inherits="PMS.TransactionView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        var tag;
        $(document).ready(function () {
            debugger;
            $("#myInput").on("keyup", function () {
                var value = $(this).val().toLowerCase();
                $("#ibody tr").filter(function () {
                    $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1)
                });
            });
            $("#btnProceed").hide();
            $("#ShowHideSampleRowHeader").hide();
            $("#ShowHideExpenseRowHeader").hide();
            $("#ShowHideLoadExpenseRowHeader").hide();
            $("#showHideScheduleHeadr").hide();
            $("#ShowHideOutSourceTestStatusList").show();
            $('#btnProceed').show();
            $("#VULookup").hide();
            tag = '<%= Request.QueryString["Tag"]%>';
            searchbuton();
            $('#btnProceed').on('click', function () {
                debugger;
                var status = '';
                var dataList = new Array();
                var table = document.getElementById('ibody');

                if (tag == 'OutSourceTestStatusList') {

                    for (var i = 0; i < table.rows.length; i++) {
                        var testDetailID = $('#Lab_Test_Detail_ID' + i).text();
                        var dispatchDate = $('#DispatchDate' + i).val();
                        var receiveDate = $('#ReceiveDate' + i).val();
                        if (dispatchDate != '' && receiveDate != '') {
                            debugger;
                            dataList[i] = new Array(testDetailID, dispatchDate, receiveDate);
                        }
                        status = 'Pending';
                    }
                    console.log(dataList);
                }
                else if (tag == 'DispatchedTestList') {

                    debugger;
                    for (var i = 0; i < table.rows.length; i++) {
                        var testDetailID = $('#Lab_Test_Detail_ID' + i).text();
                        var isChecked = $('#chk' + testDetailID).prop("checked");
                        if (isChecked) {
                            dataList[i] = new Array(testDetailID);
                        }
                    }
                    status = 'DispatchedTestList'
                }
                $.ajax(
                    {
                        type: "post",
                        url: "TransactionView.aspx/proceed",
                        data: JSON.stringify({
                            "testStatus": status,
                            "dataList": dataList
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",

                        success: function (response) { },
                        failure: function (response) { }
                    });
                window.location.href = 'TransactionView.aspx?tag=' + tag + '';



            });

        });

        function clickonnsearch() {
            debugger;
            var patient_No = $('#pickSearch').val();
            
            $.ajax(
                       {
                           type: "post",
                           url: "TransactionView.aspx/btnsearch",
                           data: JSON.stringify({

                               "patient_No": patient_No
                             
                           }),
                           contentType: "application/json; charset=utf-8",
                           dataType: "json",

                           success: function (response) {
                               debugger;

                               var parse = JSON.parse(response.d);
                               var length = parse.length;
                               var rows = '';
                               var columnsName = '';
                               debugger;
                               Clear();

                               if (tag == "SampleView") {
                                   debugger;
                                   $("#ctl00_lbl2").text("Sample View");
                                   $("#ctl00_lbl1").text("Transaction View");
                                   for (var i = 0; i < length; i++) {
                                       columnsName += '<tr><td style="display:none">' + parse[i].Sample_ID + '</td><td>' + parse[i].Sample_No + '</td><td>' + parse[i].Sample_Collected_Date + '</td><td>' + parse[i].Patient_No + '</td><td>' + parse[i].Full_Name + '</td><td><a class="editListBtn" style="border-radius: 4px;color: black; padding: 4px 11px 4px 11px;" href="SampleCollectionFrom.aspx?SampleId=' + parse[i].Sample_ID + '&SampleNo=' + parse[i].Sample_No + '">Edit</a> | <a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="DeleteTest(this)">Delete</a></td></tr>';
                                   }
                               }

                               $("#ibody").append(columnsName);
                           },

                           failure: function (response) { }
                       });


        };
        function ClearResults() {
            debugger
            while (ibody.rows.length > 0) {

                ibody.deleteRow(1);

            }

        }
        function Clear() {
            debugger


            $('#tblResult tbody').empty();

        }
        function searchbuton() {
            $("#btnProceed").hide();
            $("#ShowHideSampleRowHeader").hide();
            $("#ShowHideExpenseRowHeader").hide();
            $("#ShowHideLoadExpenseRowHeader").hide();
            $("#showHideScheduleHeadr").hide();
            $("#ShowHideOutSourceTestStatusList").hide();
            tag = '<%= Request.QueryString["Tag"]%>';

            $("#VULookup").show();

            GetColumnNames();





           
            function GetColumnNames() {
                debugger;
                $.ajax({
                    type: "post",
                    url: "TransactionView.aspx/GetColumns",
                    data: JSON.stringify({
                        "Tag": tag
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                      

                        if (response.d == "No") {
                            alert("No Record Exist");
                            if (tag == "SampleView") {
                                $("#ctl00_lbl2").text("Sample View");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideSampleRowHeader").show();
                            }
                            else if (tag == "Expense") {
                                $("#ctl00_lbl2").text("Expense");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideExpenseRowHeader").show();
                            }
                            else if (tag == "DailyExpense") {
                                $("#ctl00_lbl2").text("Daily Expense");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideLoadExpenseRowHeader").show();
                            }
                            else if (tag == "Schedule") {
                                $("#ctl00_lbl2").text("Schedule");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#showHideScheduleHeadr").show();
                            }
                               
                            else if (tag == "OutSourceTestStatusList") {
                                $("#btnProceed").show();
                                $("#ctl00_lbl2").text("Pending Test List");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideOutSourceTestStatusList").show();
                            }
                            else if (tag == "DispatchedTestList") {
                                $("#btnProceed").show();
                                $("#ctl00_lbl2").text("Dispatch Test List");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideOutSourceTestStatusList").show();
                            }

                            $("#VULookup").hide();
                        }
                        else {
                            var parse = JSON.parse(response.d);
                            var columnsName;
                            if (tag == "SampleView") {
                                $("#ctl00_lbl2").text("Sample View");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideSampleRowHeader").hide();
                                columnsName += '<tr><th>' + parse[0].replace(/_/g, ' ') + '</th><th>' + parse[1].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th>' + parse[4].replace(/_/g, ' ') + '</th><th>' + parse[5].replace(/_/g, ' ') + '</th><th>Action</th></tr>';
                            }
                            else if (tag == "Expense") {
                                $("#ctl00_lbl2").text("Expense");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideExpenseRowHeader").hide();
                                columnsName += '<tr><th style="display:none">' + parse[0].replace(/_/g, ' ') + '</th><th>' + parse[1].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th>' + parse[3].replace(/_/g, ' ') + '</th><th>Action</th></tr>';
                            }
                            else if (tag == "DailyExpense") {
                                $("#ctl00_lbl2").text("Daily Expense");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideLoadExpenseRowHeader").hide();
                                columnsName += '<tr><th style="display:none">' + parse[0].replace(/_/g, ' ') + '</th><th>' + parse[1].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th>' + parse[3].replace(/_/g, ' ') + '</th><th>' + parse[4].replace(/_/g, ' ') + '</th><th>Action</th>'
                            }
                            else if (tag == "Schedule") {
                                debugger;
                                $("#ctl00_lbl2").text("Schedule");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#showHideScheduleHeadr").hide();
                                console.log(parse);
                               
                                columnsName += '<tr><th style="display:none">' + parse[0].replace(/_/g, ' ') + '</th><th>' + parse[4].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th>' + parse[3].replace(/_/g, ' ') + '</th><th>Action</th></tr>';
                            }
                            else if (tag == "OutSourceTestStatusList") {
                                debugger;
                                $("#ctl00_lbl2").text("Pending Test List");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideOutSourceTestStatusList").hide();
                                $("#btnProceed").show();
                                columnsName += '<tr><th>' + parse[1].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th style="display:none;">' + parse[3].replace(/_/g, ' ') + '</th><th>' + parse[4].replace(/_/g, ' ') + '</th><th>' + parse[5].replace(/_/g, ' ') + '</th><th>' + parse[6].replace(/_/g, ' ') + '</th><th>Dispatch Date</th><th>Receive Date</th></tr>'
                            }
                            else if (tag == "DispatchedTestList") {
                                debugger;
                                $("#ctl00_lbl2").text("Dispatch Test List");
                                $("#ctl00_lbl1").text("Transaction View");
                                $("#ShowHideOutSourceTestStatusList").hide();
                                $("#btnProceed").show();
                                columnsName += '<tr>' +
                                    '<th></th>' +
                                    '<th>' + parse[1].replace(/_/g, ' ') + '</th><th>' + parse[2].replace(/_/g, ' ') + '</th><th style="display:none;">' + parse[3].replace(/_/g, ' ') + '</th><th>' + parse[4].replace(/_/g, ' ') + '</th><th>' + parse[5].replace(/_/g, ' ') + '</th><th>Dispatch Date</th><th>Receive Date</th></tr>'
                            }

                            $("#ihead").append(columnsName);
                            $("#ihead").find('tr:eq(6)').hide();
                            GetTableData();

                        }

                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
            }


            function GetTableData() {
                debugger;
                $.ajax({
                    type: "post",
                    url: "TransactionView.aspx/GetData",
                    data: JSON.stringify({
                        "Tag": tag
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        debugger;
                        var parse = JSON.parse(response.d);
                        var length = parse.length;

                        var rows;

                        if (tag == "SampleView") {
                            $("#ctl00_lbl2").text("Sample View");
                            $("#ctl00_lbl1").text("Transaction View");
                            for (var i = 0; i < length; i++) {
                                rows += '<tr><td>' + parse[i].Sample_ID + '</td><td>' + parse[i].Sample_No + '</td><td>' + parse[i].Sample_Collected_Date + '</td><td>' + parse[i].MR_No + '</td><td>' + parse[i].Full_Name + '</td><td><a style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;" href="SampleCollectionFrom.aspx?SampleId=' + parse[i].Sample_ID + '&SampleNo=' + parse[i].Sample_No + '">Edit</a> | <a style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;" href="#" onclick="PrintSample(' + parse[i].Sample_ID + ')">Print</a></td></tr>';
                                
                            }
                        }
                        else if (tag == "Expense") {
                            $("#ctl00_lbl2").text("Expense");
                            $("#ctl00_lbl1").text("Transaction View");
                            for (var i = 0; i < length; i++) {
                                rows += '<tr><td style="display:none">' + parse[i].Expense_ID + '</td><td>' + parse[i].Expense_Type + '</td><td>' + parse[i].Expense_Name + '</td><td>' + parse[i].Rate + '</td><td><a style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;"href="ExpenseDefination.aspx?ExpenseID=' + parse[i].Expense_ID + '">Edit</a></td></tr>';
                            }
                        }
                        else if (tag == "DailyExpense") {
                            $("#ctl00_lbl2").text("Daily Expense");
                            $("#ctl00_lbl1").text("Transaction View");
                            for (var i = 0; i < length; i++) {
                                rows += '<tr><td style="display:none">' + parse[i].Expense_ID + '</td><td>' + parse[i].Expense_Date + '</td><td>' + parse[i].Expense_Type + '</td><td>' + parse[i].Expense_Name + '</td><td>' + parse[i].Expense_Amount + '</td><td><a style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;" href="LoadExpense.aspx?ExpenseID=' + parse[i].Expense_ID + '">Edit</a> </td></tr>';
                            }
                        }
                        else if (tag == "Schedule") {
                            $("#ctl00_lbl2").text("Schedule");
                            $("#ctl00_lbl1").text("Transaction View");
                            debugger;
                            for (var i = 0; i < length; i++) {
                                debugger;
                             
                                rows += '<tr><td style="display:none">' + parse[i].schedule_id + '</td><td>' + parse[i].schedule_no + '</td><td>' + parse[i].Days + '</td><td>' + parse[i].Emp_Name + '</td><td><a style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;" href="Schedule.aspx?ScheduleID=' + parse[i].schedule_id + '">Edit</a> </td></tr>';
                            }
                        }
                           
                        else if (tag == "DispatchedTestList") {
                            debugger;
                            $("#ctl00_lbl2").text("Dispatch Test List");
                            $("#ctl00_lbl1").text("Transaction View");
                            $("#btnProceed").show();

                            for (var i = 0; i < length; i++) {
                                rows += '<tr>' +
                                    '<td> <input type="checkbox" id = "chk' + parse[i].Lab_Test_Detail_ID + '"> </td>' +
                                    '<td>' + parse[i].Patient_No + '</td><td>' + parse[i].Full_Name + '</td><td  id="Lab_Test_Detail_ID' + i + '" style="display:none;">' + parse[i].Lab_Test_Detail_ID + '</td><td>' + parse[i].Test_NAme + '</td><td>' + parse[i].Rate + '</td><td><input type="text" id="DispatchDate' + i + '"  value="' + parse[i].Dispatch_Date + '"/></td><td><input type="text" id="ReceiveDate' + i + '"  value="' + parse[i].Dispatch_Date + '"/></td></tr>'
                            }
                        }
                        debugger;
                        $("#ibody").append(rows).find('input[id^=DispatchDate],input[id^=ReceiveDate]').datepicker(
            { dateFormat: 'dd/mm/yy' });
                       
                        $("#VULookup").hide();
                    },
                    failure: function (response) {
                        alert("In failure method");
                    }
                });
            }

            function DeleteTest(RowReference) {
                debugger;
                var row = $(RowReference).parents('tr')[0];
                var id = $($(row).find('td')[0]).text();
                if (confirm('Are you sure want to delete this record')) {
                    debugger;
                    $.ajax({
                        type: "post",
                        url: "TransactionView.aspx/DeleteRecord",
                        data: JSON.stringify({
                            "ID": id,
                            "Tag": tag
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            debugger;
                            if (JSON.parse(response.d) == "Deleted" || JSON.parse(response.d) == true) {
                                $("#VULookup").show();
                                $("#ibody tr").remove();
                                GetTableData();
                            }

                            else {
                                alert("Not deleted");
                            }
                        },
                        failure: function (response) {
                            alert("In failure method");
                        }
                    });
                }
            }
        }
        debugger;
        function PrintSample(Sample_ID) {
            debugger;
            var sampleID = Sample_ID;
            window.open('../../ReportViewer.aspx?ReportName=LabSlip&ReportTitle=Department Of Pathology&Lab_ID=' + sampleID);
        }
    </script>

    <style type="text/css">
         #ctl00_lblMessage {
       display:none;
             }
        fieldset {
            border: 1px groove #ddd !important;
            padding: 0 1.4em 1.4em 1.4em !important;
            margin: 0 0 1.5em 0 !important;
            -webkit-box-shadow: 0px 0px 0px 0px #000;
            box-shadow: 0px 0px 0px 0px #000;
        }

        legend {
            font-size: 1.2em !important;
            font-weight: bold !important;
            text-align: left !important;
            width: auto;
            padding: 0 10px;
            border-bottom: none;
            margin-bottom: 0px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
            border: 1px solid #167F92;
        }

            .table tr {
                border: 1px solid #D9E4E6;
            }

                .table tr:nth-child(even) {
                    background-color: #EAF3F3;
                }

            .table th {
                display: none;
                border: 1px solid #FFF;
                background-color: #438eb9;
                color: #FFF;
                padding: 1em;
            }

            .table thead th {
                display: table-cell;
                text-align: center;
            }

        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        .table td {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }

            .table td:first-child {
                display: table-cell;
                text-align: center;
                border-right: 1px solid #D9E4E6;
            }

        @media (min-width: 480px) {
            .table td {
                border: 1px solid #D9E4E6;
            }
        }

        .table th, .table td {
            text-align: center;
            margin: .5em 1em;
        }

        @media (min-width: 480px) {
            .table th, .table td {
                display: table-cell;
                padding: 1em;
            }
        }

        #test_id {
            width: 60px !important;
            text-align: center;
            font-weight: bold;
        }

        .ErrorAlert {
            border: 1px solid red !important;
        }
    </style>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-2 col-md-4 col-sm-6">            
       <input type="text"  id="pickSearch"/>
        </div>
        <div class="col-lg-1 col-md-4 col-sm-6">            
            <input class="btn btn-primry" type="button" id="hide" onclick="clickonnsearch();"  value="Search" />
            <input type="hidden" id="tagss" value="OutSourceTestStatusList" />&nbsp;&nbsp;
        </div>
        </div>
   


    <div style="margin-top: 15px;">
     
         <div id="VULookup">
            <img src="images/loading.gif" height="25" width="25" alt="Loading..." />&nbsp;            
            <span style="vertical-align: top;" class="stdText">Loading...</span>
        </div>
      
       
          <div>
        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow:scroll; height:auto;">
            <thead id="ihead">
               <tr id="ShowHideSampleRowHeader">
                   <th>Sample ID</th>
                   <th>Sample No</th>
                   <th>Sample Collected Date</th>
                   <th>MR No</th>
                   <th>Full Name</th>
                   <th>Action</th>
               </tr>
                <tr id="ShowHideExpenseRowHeader">
                   <th style="display:none">Expense ID </th>
                   <th>Expense Type</th>
                   <th>Expense Name</th>
                   <th>Rate</th>
                   <th>Action</th>
               </tr>
                <tr id="ShowHideLoadExpenseRowHeader">
                   <th style="display:none">Expense ID </th>
                    <th>Expense Date</th>
                   <th>Expense Type</th>
                   <th>Expense Name</th>
                   <th>Amount</th>
                   <th>Action</th>
               </tr>
                <tr id="showHideScheduleHeadr">
                   <th style="display:none">Schedule ID </th>
                   <th>Schedule No</th>
                   <th>Day</th>
                   <th>Doctor Name</th>
                   <th>Action</th>
                </tr>
                <tr id="ShowHideOutSourceTestStatusList">
                    <th>Mr #</th>
                    <th>Patient Name</th>
                    <th>Out Source Lab Name</th>
                    <th>Test Name</th>
                    <th>Rate</th>
                    <th>Sample Dispatch Date</th>
                    <th>Receive Date</th>
                    
                </tr>
            </thead>

            <tbody id="ibody">
            </tbody>
        </table>
        </div>

         </div>
</asp:Content>

