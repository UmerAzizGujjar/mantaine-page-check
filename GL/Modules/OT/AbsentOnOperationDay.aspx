<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AbsentOnOperationDay.aspx.cs" Inherits="PMS.AbsentOnOperationDay" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <script type="text/javascript">
           var optionsList = '';
           $(document).ready(function () {
               GetDoctors();
               get_ot_fitnes_list();
               $('[id*=chckHead]').click(function () {
                   var isTrue = $('#chckHead').is(':checked');
                   if (isTrue) {
                       $('.chcktbl').prop('checked', true);
                   }
                   else {
                       $('.chcktbl').prop('checked', false);
                   }
               });

            

           });
           function update_call(detailAry) {
               $.ajax({
                   type: "POST",
                   url: "AbsentOnOperationDay.aspx/update_call",
                   data: JSON.stringify({
                       "detailAry": detailAry
                   }),
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (response) {
                       if (response.d == "success") {
                           window.location = "OperationBookingView.aspx";
                       }

                   }, error: function () {


                   }

               });

           }
           var get_row = '';
           function Save(row) {
               get_row = row;
               var fitness_id = $($(row).closest('tr')[0]).find('td:eq(0)').text();

               $.ajax({
                   type: "POST",
                   url: "AbsentOnOperationDay.aspx/StatusUpdate",
                   data: JSON.stringify({ "fitness_id": fitness_id }),
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (response) {
                       if (response.d == "Prepared") {
                           $($(row).closest('tr')[0]).find('td input[name="btnSave"]').attr('disabled', true);
                       }

                   }, error: function () {


                   }

               });

           }
           function GetDoctors() {
               $.ajax({
                   type: "POST",
                   url: "AbsentOnOperationDay.aspx/GetDoctors",
                   data: '',
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (response) {
                       var result = JSON.parse(response.d);
                       optionsList = "<option value=0>Please Select</option>"
                       for (var i = 0; i <= result.length; i++) {

                           optionsList += '<option value=' + result[i].Emp_ID + '>' + result[i].Emp_Name + ' </option>';


                       }

                   }, error: function () {


                   }

               });

           }
           function get_ot_fitnes_list() {
               var jsonParsedData = '';
               $.ajax
                   ({
                       type: "POST",
                       url: "AbsentOnOperationDay.aspx/get_ot_fitnes_list",
                       data: "",
                       contentType: "application/json; charset=utf-8",
                       dataType: "json",
                       success: function (data) {
                           var row = '';
                           var parsed_data = JSON.parse(data.d);
                           jsonParsedData = parsed_data;
                           $.each(parsed_data, function (key, index) {
                           
                               row += '<tr><td style="display:none">' + parsed_data[key].In_Patient_ID + '</td><td style="display:none;"><input type="checkbox" class ="chcktbl" id="chcktbl" name="chkReport" value="false"/></td><td>' + parsed_data[key].Sr_No + '</td><td>' + parsed_data[key].Patient_No + '</td><td>' + parsed_data[key].Full_Name + '</td><td>' + parsed_data[key].Age_years + '</td><td>' + parsed_data[key].Gender + '</td><td>' + parsed_data[key].Bill_No + '</td><td> <select name="ddltestperfomedBy" id="ddldoc' + key + '" style="width: 124px!important;">' + optionsList + '</select></td><td><input type="text" name="txtrdate" id="txtot' + key + '" style="width: 128px!important;" autocomplete="off" value=""/></td></tr>';

                           });

                           $('#tblotlist tbody').append(row);
                           $.each(jsonParsedData, function (key, value) {

                               $('#ddldoc' + key + '').val(jsonParsedData[key].Referred_Doctor);
                           });
                       },

                       error: function () {
                       }
                   });

           }
           </script>
 
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
   
    <table style="width:100%;" id="tblotlist" class="table">
        <thead>
            <tr>
            <th style="display:none;"></th>
            <th style="display:none;"><input type="checkbox"  id ="chckHead"  name="chkReport" /></th>
            <th>Sr.No</th>
            <th>MR No</th>
            <th>Patient Name</th>
            <th>Age</th>
            <th>Gender</th>         
            <th>Bill No</th>        
            <th>Doctor Name</th>
            <th>O.T Date</th>         
            </tr>       
        </thead>      
        </table>

</asp:Content>
