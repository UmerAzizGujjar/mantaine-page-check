<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Doctor_Payable.aspx.cs" Inherits="PMS.Modules.PatientManagement.Doctor_Payable" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
    $(document).ready(function () {
        debugger;
        FillPackageType();
        var date = '<%= DateTime.Now%>';
        $("#StartDate").datepicker({
            dateFormat: 'MM d,yy',

        }).attr('readonly', 'readonly');

        $("#EndDate").datepicker({
            dateFormat: 'MM d,yy',

        }).attr('readonly', 'readonly');

        date = moment(date).format('LL');
        $("#StartDate").val(date);
        $("#EndDate").val(date);

        
        $('#ctl00_lblMessage').hide();
        setTimeout(function () {
            LoadPage();
        }, 500);


        $('#ddlPackageType').change(function () {
            LoadPage();
        });
    });
        function SearchDate() {
            LoadPage();
        }

        function LoadPage() {
            var Packagetype = $("#ddlPackageType").val()
            $("#example").DataTable({
                "processing": true,
                "serverSide": true,
                "destroy": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "Doctor_Payable.aspx/ViewList",
                        data: JSON.stringify({
                            draw: data.draw,
                            start: data.start,
                            length: data.length,
                            sortColumn: data.columns[data.order[0].column].name,
                            sortColumnDirection: data.order[0].dir,
                            searchValue: data.search.value,
                            startDate: $("#StartDate").val(), 
                            endDate: $("#EndDate").val(),    
                            packageType: Packagetype
                        }),
                        contentType: "application/json; charset=utf-8",
                        dataType: "json",
                        success: function (response) {
                            callback({
                                draw: response.d.draw,
                                recordsTotal: response.d.recordsTotal,
                                recordsFiltered: response.d.recordsFiltered,
                                data: response.d.data
                            });
                        },
                        error: function (xhr, status, error) {
                            console.log(xhr.responseText);
                        }
                    });
                },
                "columns": [
                    { "data": "Bill_No", "name": "Bill_No", "orderable": true },
                    { "data": "Creation_Date", "name": "Creation_Date", "orderable": true },
                    { "data": "MR_No", "name": "MR_No", "orderable": true },
                    { "data": "Full_Name", "name": "Full_Name", "orderable": true },
                    { "data": "Package_Name", "name": "Package_Name", "orderable": true },
                    { "data": "Bill_Net_Amount", "name": "Bill_Net_Amount", "orderable": true },
                    { "data": "Total_Expense", "name": "Total_Expense", "orderable": true },
                    { "data": "Net_Amount", "name": "Net_Amount", "orderable": true },
                    { "data": "Doctor_Share", "name": "Doctor_Share", "orderable": true },
                    { "data": "Hospital_Share", "name": "Hospital_Share", "orderable": true },
                    { "data": "Services_Tests", "name": "Services_Tests", "orderable": true },
                    {
                        "data": "DoctorName",
                        "name": "DoctorName",
                        "orderable": true,
                        "render": function (data, type, row) {
                            return '<a href="#" onclick="showmodal(\'' + row.Bill_ID + '\', \'' + row.Doctorid + '\')"> Assign ' + data + '</a>';
                        }
                    }

                ],
                "order": [[0, 'asc']],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#example_length');
                    var lengthDropdown = document.querySelector('#example_length select');
                    var label = document.querySelector('#example_length label');

                    if (lengthDropdown && label && lengthContainer) {
                        var labelText = document.createElement('span');
                        labelText.textContent = 'Show entries ';
                        labelText.style.marginTop = '10px';
                        labelText.style.display = 'inline-block';

                        lengthDropdown.style.width = '60px';
                        label.innerHTML = '';
                        label.style.display = 'inline-flex';
                        label.style.marginTop = '17px';
                        label.appendChild(labelText);
                        label.appendChild(lengthDropdown);
                    } else {
                        console.log("Length dropdown, label, or container not found");
                    }
                }
            });
        }
        function showmodal(Bill_Id, Doctorid) {
            $("#DetailModel").modal('show');
            GetBillDetailsPackageWise(Bill_Id)
        }

        function GetBillDetailsPackageWise(Bill_Id) {
            console.log(Bill_Id);
            $.ajax({
                type: "POST",
                url: "Doctor_Payable.aspx/GetBillDetailPackageWise",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                data: JSON.stringify({ Bill_Id: Bill_Id }),
                success: function (response) {
                    debugger;
                    var data = JSON.parse(response.d);
                    console.log(data);
                    var tableBody = $("#example1 tbody");
                    tableBody.empty(); 
                    var expenseTotal = 0;
                    var netTotal = 0;
                    var totalBill = 0;
                    var DocShare = 0;
                    var HosShare = 0;

                    if (data && data.length > 0) {
                        $.each(data, function (index, item) {
                            if (index === 0) {
                                $("#hdnDocId").val(item.Doctor_Id);
                                $("#hdnBillid").val(item.Bill_ID);
                                $("#hdnPatient_Id").val(item.Patient_ID);
                            }
                            if (item.is_expense) {
                                expenseTotal += parseFloat(item.Net_Amount);
                            } else {
                                netTotal += parseFloat(item.Net_Amount);
                                var DosShares = ((item.Net_Amount * item.Doctor_Share) / 100)
                                DocShare += DosShares
                                var HosShares = ((item.Net_Amount * item.Hospital_Share) / 100)
                                HosShare += HosShares
                            }
                            totalBill += parseFloat(item.Net_Amount);
                           

                            var row = `
                        <tr>
                            <td>${item.Bill_No}</td>
                            <td>${item.Item_ID}</td>
                            <td>${item.Item_Name}</td>
                            <td>${item.Item_Type}</td>
                            <td>${parseFloat(item.Amount).toFixed(2)}</td>
                            <td>${parseFloat(item.Discount_Amount).toFixed(2)}</td>
                            <td>${parseFloat(item.Net_Amount).toFixed(2)}</td>
                            <td>
                                <input type="checkbox" class="isExpense" ${item.is_expense ? 'checked' : ''} disabled  />
                            </td>
                            <td>${parseFloat(item.Doctor_Share).toFixed(2)}</td>
                            <td>${parseFloat(item.Hospital_Share).toFixed(2)}</td>
                        </tr>
                    `;

                            tableBody.append(row);
                        });
                        $("#txtexpense").val(expenseTotal.toFixed(2));
                        $("#txtNet").val(netTotal.toFixed(2));
                        $("#txtTotalAmount").val(totalBill.toFixed(2));
                        $("#HosShare").val(HosShare.toFixed(2));
                        $("#DocShare").val(DocShare.toFixed(2));
                    } else {
                        tableBody.append('<tr><td colspan="10" class="text-center">No data available</td></tr>');
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Error fetching data:", error);
                }
            });
        }


        function FillPackageType() {
            PageMethods.GetPackageType(function (data) {
                var options = '<option value="All" >Please Select</option>';
                $.each(JSON.parse(data), function (key, value) {
                    options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                });
                $('#ddlPackageType').html(options);
            });
        }
        
        function SaveShare() {
            debugger;
            var PatientID = $('#hdnPatient_Id').val();
            var Doctor_ID = $('#hdnDocId').val();
            var Bill_Id = $('#hdnBillid').val();
            var Total_Bill_Amount = $('#txtTotalAmount').val();
            var Total_Expense = $('#txtexpense').val();
            var Aftre_Expense_Amount = $('#txtNet').val();
            var DoctorShare = $('#DocShare').val();
            var HospitalShare = $('#HosShare').val();
            var AssignAmount = $('#txtAssignAmount').val();

            var data = JSON.stringify({
                "PatientID": PatientID,
                "Doctor_ID": Doctor_ID,                   
                "Bill_Id": Bill_Id,
                "Total_Bill_Amount": Total_Bill_Amount,
                "Total_Expense": Total_Expense,
                "Aftre_Expense_Amount": Aftre_Expense_Amount,
                "DoctorShare": DoctorShare,
                "HospitalShare": HospitalShare,
                "AssignAmount": AssignAmount
            });

            $.ajax({
                type: "POST",
                url: "Doctor_Payable.aspx/SaveShare",
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    debugger;
                    var result = response.d;  

                    if (result.startsWith("success")) {
                        alert('Your record has been saved successfully');
                        $('#PatientModel').modal('hide');
                    } else {
                        alert('Error while saving: ' + result);
                    }
                },
                error: function (xhr, status, error) {
                    alert("Unexpected error: " + error);
                }
            });
        }

    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-3 col-md-4 col-sm-8">
            <label>Package Type</label>
            <select id="ddlPackageType"></select>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-8">
            <label>From Date:</label>
            <input type="text" id="StartDate" class="form-control"/>
        </div>

        <div class="col-lg-2 col-md-4 col-sm-8">
            <label>To Date:</label>
            <input type="text" id="EndDate" class="form-control"/>
        </div>
        <div class="col-lg-2 col-md-4 col-sm-8">
            <button type="button" id="btnSearch" class="btn btn-primry form-control" onclick="SearchDate()">Search</button>
        </div>

    </div>
    <br />
     <div class="table-container">
            <table id="example" class="table table-hover table-bordered" style="width:100% !important">
                <thead>
                    <tr>
                        <th>Bill No</th>
                        <th>date</th>
                        <th>MR_No</th>
                        <th>Patient Name</th>                     
                        <th>Package Name</th>
                        <th>Total Bill Amount</th>
                        <th>Total Expense</th>
                        <th>Net Amount</th>
                        <th>Doctor Share</th>
                        <th>Hospital Share</th>
                        <th>Services/Tests</th>
                        <th>Doctor</th>                          
                    </tr>
                </thead>
                <tbody id="tblbody">
                </tbody>
            </table>
    </div>

   <div id="DetailModel" class="modal fade" tabindex="-1" role="dialog">
        <div class="modal-dialog modal-lg" role="document">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Assign Doctor</h5>
                    <button type="button" class="close" data-dismiss="modal" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>

                <div class="modal-body">
                    <div class="container-fluid">
                        <div class="row">
                            <div class="table-container">

                                <table id="example1" class="table table-bordered table-striped">
                                    <thead>
                                        <tr>
                                            <th>Bill No</th>
                                            <th>Item ID</th>
                                            <th>Item Name</th>
                                            <th>Item Type</th>
                                            <th>Amount</th>
                                            <th>Discount</th>
                                            <th>Net Amount</th>
                                            <th>Is Expense</th>
                                            <th>Doctor Share</th>
                                            <th>Hospital Share</th>
                                        </tr>
                                    </thead>
                                    <tbody></tbody>
                                </table>
                            </div>
                            <div class="row">
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Total Amount</label>
                                    <input type="text" id="txtTotalAmount" readonly="readonly" />
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Total Expense</label>
                                    <input type="text" id="txtexpense" readonly="readonly"/>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Net Amount</label>
                                    <input type="text" id="txtNet" readonly="readonly" />
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Doctor Share</label>
                                    <input type="text" id="DocShare" readonly="readonly"/>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Hospital Share</label>
                                    <input type="text" id="HosShare" readonly="readonly"/>
                                </div>
                                <div class="col-lg-3 col-md-6 col-sm-6">
                                    <label>Assign Amount</label>
                                    <input type="text" id="txtAssignAmount" />
                                </div>
                                                                <div class="col-lg-3 col-md-6 col-sm-6">

                                    <input type="hidden" id="hdnDocId" />
                                    <input type="hidden" id="hdnBillid" />
                                    <input type="hidden" id="hdnPatient_Id" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-primry" data-dismiss="modal" onclick="SaveShare()">Save</button>
                <button type="button" class="btn btn-primry" data-dismiss="modal">Ok</button>
            </div>
        </div>
    </div>
</asp:Content>


