<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TokenList.aspx.cs" Inherits="PMS.TokenList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        $(document).ready(function () {
            debugger;
        
            GetLatestToken();

            $('[id*="Getrow"]').on('click', function () {
                debugger; var isTrue = $('#Getrow').is(':checked');
                if (isTrue) {
                    debugger; $('.chckrow').prop('checked', true);
                } else {
                    debugger; $('.chckrow').prop('checked', false);
                }
            });

            $('#btnApproved').on('click', function () {
                debugger;

                $.each($('#tbloutPatients tbody tr'), function (key, value) {
                    debugger;
                    var chck = $($(value).find('td input[name=Getrow]')[0]).prop("checked");
                    var Billid = $($(value).find('td input[name=Bil_id]')[0]).val();
                    var department = $('#ddldepartment').val();
                    debugger;
                    if (chck == "true" || chck == true) {
                        debugger;
                        PageMethods.Approvebilling(Billid, function (response) {
                            debugger;
                            var data = response;
                            if (data == "Success") {
                                // alert("Bill has been approved successfully");

                            }



                        });

                    }
                    else {

                    }





                });
                window.location.href = 'TokenList.aspx';
            });


        });
        var rowColor;
        // Define the function to get the latest token
        // Define the function to get the latest token
        function GetLatestToken() {
            $.ajax({
                url: 'TokenList.aspx/LoadTokenPatient',
                type: 'post',
                contentType: 'application/json;charset=utf-8',
                dataType: 'json',
                success: function (_data) {
                    debugger;
                    _data = JSON.parse(_data.d);
                    var mdTable = $('#tbloutPatients');
                    $('#tbl tr:gt(0)').remove();
                    table = $('#ibody');
                    table.empty();
                    debugger;
                    $.each(_data, function (key, value) {
                        bill_id = value.Bill_ID;
                        debugger;

                        var rowColor = '';
                        if (value.filter_clinic == "001" && value.Id == "001") {
                            rowColor = 'background: linear-gradient(to Right, #f5c5f6, #e4c1fa);';
                            $("#ibody").append('<tr style="' + rowColor + '"><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td  style="font-size:22px;font-weight:bold;">' + value.tokenNo + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Opd_No + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Full_Name + '</td></tr>');
                            length++;
                            return true;
                            
                        } else if (value.filter_clinic == "002" && value.Id == "002") {
                            rowColor = 'background: linear-gradient(to Right, #ff9190,#fdc094 );';
                            $("#ibody").append('<tr style="' + rowColor + '"><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td  style="font-size:22px;font-weight:bold;">' + value.tokenNo + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Opd_No + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Full_Name + '</td></tr>');
                            length++;
                            return true;
                        }
                        else if (value.filter_clinic == "003" && value.Id == "003")
                        {
                            rowColor = 'background: linear-gradient(to Right, #7BE495, #CFF4D2);';
                            $("#ibody").append('<tr style="' + rowColor + '"><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td  style="font-size:22px;font-weight:bold;">' + value.tokenNo + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Opd_No + '</td><td  style="font-size:22px;font-weight:bold;">' + value.Full_Name + '</td></tr>');
                            length++;
                            return true;
                        }

                    
                    });
                },
                error: function () {
                    alert("Get Error");
                }
            });
        }
        setInterval(function () {
       
            location.reload(); // Refresh the page
        }, 10000);



       


    </script>
    <style type="text/css">
        .table-header th {
          font-size: 23px;
          font-weight: bold;
    }
        .table > thead > tr {
             background: linear-gradient(to Right, #c046aa, #2c3e50) !important;

             color:white;
        }

    </style>
</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<div class="row">
    <div class="col-lg-1">
     
        <h4>Clinic1</h4>
    </div>
    <div class="col-lg-1" style="background-color: #85efc8;width: 20px; height: 20px;margin-top: 8px;">
     
         <span style="width: 20px; height: 20px;display:inline"></span>
    </div> 
     <div class="col-lg-1"></div>
    <div class="col-lg-1">
     
        <h4>Clinic2</h4>
    </div>
   
    <div class="col-lg-1" style="background-color: #ff9f59;width: 20px; height: 20px;margin-top: 8px;">
     
         <span style="background-color: yellow;width: 20px; height: 20px;display:inline;"></span>
    </div> 
     <div class="col-lg-1"></div>
    <div class="col-lg-1">
     
        <h4>Clinic3</h4>
    </div>
    <div class="col-lg-1" style="background-color: #ff5f5f;width: 20px; height: 20px;margin-top: 8px;">
     
         <span style="background-color: yellow;width: 20px; height: 20px;display:inline;"></span>
    </div>
</div>



    <input type="button" value="Remove Selected Patients" style="width:168px;" id="btnApproved" />
    <div class="row">
        <table class="table table-hover table-striped table-bordered" id="tbloutPatients" style="overflow: scroll; height: auto;">
            <thead id="ihead" style="background: linear-gradient(to bottom, #bdc3c7, #2c3e50) !important;">
                <tr style="">
                    <th style="width: 8%;">
                        <input id="Getrow" class="chckrow" type="checkbox" /></th>
                    <th style="font-size:22px;font-weight:bold;">Token No</th>
                    <th  style="font-size:22px;font-weight:bold;">Mr No</th>
                    <th  style="font-size:22px;font-weight:bold;">Patient Name</th>
                  

                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>


</asp:Content>

