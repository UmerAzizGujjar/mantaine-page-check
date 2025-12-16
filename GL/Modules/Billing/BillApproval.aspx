<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BillApproval.aspx.cs" Inherits="PMS.BillApproval" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
      <script type="text/javascript">
          $(document).ready(function () {
              debugger;

              setTimeout(function () {
                  GetBillToApproveList();
              }, 1000)


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

                  $.each($('#tblBillPatients tbody tr'), function (key, value) {
                      debugger;
                      var chck = $($(value).find('td input[name=Getrow]')[0]).prop("checked");
                      var billid = $($(value).find('td input[name=bill_id]')[0]).val();
                      var Pat_Category = $($(value).find('td input[name=pat_type]')[0]).val();

                      debugger;
                      if (chck == "true" || chck == true) {
                          debugger;
                          PageMethods.ApproveBill(billid, function (response) {
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
                  window.location.href = 'BillApproval.aspx';
              });


          });

          function GetBillToApproveList() {
          
              var search = $('#txtsearch').val();

              $.ajax({
                  url: 'BillApproval.aspx/LoadBillsToApprove',
                  type: 'post',
                  contentType: 'application/json;charset=utf-8',
                  dataType: 'json',
                  data: JSON.stringify({ "search": search }),
                  success: function (_data) {
                      debugger;
                      _data = JSON.parse(_data.d);
                      console.log(_data);
                      var mdTable = $('#tblBillPatients');
                      $('#tbl tr:gt(0)').remove();
                      table = $('#ibody');
                      table.empty();
                      debugger;
                      $.each(_data, function (key, value) {


                          debugger;
                          $("#ibody").append('<tr><td style="display:none;"><input id="bill_id" name="bill_id" class="bill_id" type="hidden" value="' + value.Bill_ID + '" /></td><td><input id="Getrow" name="Getrow" class="chckrow" type="checkbox" /></td><td>' + value.mr_no_sequence + '</td><td>' + value.Bill_No + '</td><td>' + value.Full_Name + '</td><td>' + value.Total_Amount + '</td><td>' + value.Received_Amount + '</td><td>' + value.Status + '</td></tr>');
                          length++;


                          return true;
                      });
                  },
                  error: function () {
                      alert("Get Error");
                  }
              });
          }

      </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

 <div class="row">
     <div class="col-lg-2 col-md-2 col-sm-4">
      <div>
     <label>Search</label>
       <input type="text"  id="txtsearch" onkeyup ="GetBillToApproveList()"  />
 </div>
  
     </div>
     <div class="col-lg-2 col-md-2 col-sm-4">
         <label></label>
          <input type="button" value="Approve Selected Bills" class="btn btn-primry" id="btnApproved" />
     </div>
 </div>
    <div class="row">
        <table class="table table-hover table-striped table-bordered" id="tblBillPatients" style="overflow: scroll; height: auto;">
            <thead id="ihead">
                <tr>
                    <th style="width: 8%;">
                        <input id="Getrow" class="chckrow" type="checkbox" /></th>
                    <th class="hide">Bill ID</th>
                    <th>MR No</th>
                    <th>Bill No</th>
                    <th>Patient Name</th>
                    <th>Total Amount</th>
                    <th style="width: 8%;">Recieved Amount</th>
                    <th style="width: 8%;">Bill Status</th>


                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
    </div>


</asp:Content>
