<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AssetRetirement.aspx.cs" Inherits="PMS.Modules.Administrator.AssetRetirement" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <script type="text/javascript">
       $(document).ready(function () {
           //$('#btn_Approve').hide();
           //$('#btn_UnApprove').hide();

                var date = '<%= DateTime.Now%>';
                  date = moment(date).format('LL');
                  $("#txtDate").val(date);
           LoadTransType();
           
            var id = '<%=Request.QueryString["ID"]%>';
            if (id != "") {
                $("#btnSave").val('Update');
                $('#ddl_transType').attr('disabled', true);
                $('#ddlMonth').attr('disabled', true);
                $('#txtReg_no').attr('disabled', true);
                $('#txtRemarks').attr('disabled', true);
               
        /*        $('#btn_save').attr('disabled', true);*/


                getRecords(id);
            }
            else {
                $('#ddl_transType').select2();
                //$('#ddlYears').select2();
                //$('#ddlMonth').select2();
           }
         
       });

       function getRecords(id) {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/getRecords",
               data: JSON.stringify({ "id": id }),

               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (response) {
                   var parsed_data = JSON.parse(response.d);
                   console.log(parsed_data);
                   $("#ddl_transType").val(parsed_data[0].TransType);
                   $("#transactionno").val(parsed_data[0].TransNo);
                  
                   $("#txtRemarks").val(parsed_data[0].Remarks);

                   var Reg_Date = parsed_data[0].created_time;

                   if (Reg_Date == null || Reg_Date == "null" || Reg_Date == "" || Reg_Date == '') {
                   }
                   else {
                       var date = parsed_data[0].Date;
                       date = moment(date).format('DD-MMM-YYYY');
                       $("#txtDate").val(date);
                   }

                   var isApproved = parsed_data[0].isapprove;
                   console.log("Is Aprroved" + isApproved);

                   if (isApproved == 1) {
                       $("#approve-div").hide();
                       $("#unapprove-div").show();
                   } else {
                       $("#unapprove-div").hide();
                       $("#approve-div").show();
                   }



                  

                   setTimeout(function () {
                       GetRetirement_Result(id)

                       /*$("#btn_approve").show();*/
                   }, 2000)




               }

           });
       }
       function GetRetirement_Result(id) {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/GetRetirement_Result",
               data: JSON.stringify({ "id": id }),
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (response) {
                   var arrData = JSON.parse(response.d);
                   $('#tblRetirement tbody').empty(); // optional: clear previous data
                   $.each(arrData, function (key, value) {
                       rowIndexCounter++;
                       var rows = '<tr>' +
                           '<td><select id="ddl_Asset' + rowIndexCounter + '" name="ddl_Asset" onchange="getValues(this);" class="form-control" style="width:122px!important;"></select></td>' +
                           '<td><input type="text" id="Asset_Value' + rowIndexCounter + '" name="Asset_Value" value="' + value.AssetValue + '" Readonly style="width:122px!important;height: 32px" /></td>' +
                           '<td><input type="text" id="Asset_Depreciation' + rowIndexCounter + '" value="' + value.Depreciation_Amount + '" name="Asset_Depreciation" Readonly style="text-align: right;width:122px!important;height: 32px" /></td>' +
                           '<td><input type="text" id="Remaining_value' + rowIndexCounter + '" value="' + value.Remaing_Amount + '" name="Remaining_value" Readonly style="width:122px!important;height: 32px" /></td>' +
                           '<td><input type="text" id="Retirement_Value' + rowIndexCounter + '" value="' + value.Retirement_Value + '" name="Retirement_Value" style="width:122px!important;height: 32px" /></td>' +
                           '<td><select id="ddl_CrAccount' + rowIndexCounter + '" name="ddl_CrAccount" class="form-control" style="width:122px!important;"></select></td>' +
                           '<td><select id="ddl_DrAccount' + rowIndexCounter + '" name="ddl_DrAccount" class="form-control" style="width:122px!important;"></select></td>' +
                           '<td style="display:none;"><input type="text" id="Ret_detail_id' + rowIndexCounter + '" value="' + value.Asset_Ret_Detail_ID + '" name="Ret_detail_id" style="width:122px!important;height: 32px" /></td>'+
                           '</tr>';

                       $('#tblRetirement tbody').append(rows);
                       LoadAsset(rowIndexCounter, value.Asset_id);
                       LoadCreditAccount(rowIndexCounter, value.Cr_Account);
                       LoadDebitAccount(rowIndexCounter, value.Dr_Account);
                       rowIndexCounter++; 

                   });

                   $("#btn_save").val('Update');
               },
               error: function () {
                   Swal.fire({
                       icon: 'error',
                       title: 'Error!',
                       text: 'Error fetching retirement result',
                       showConfirmButton: false,
                       timer: 2000,
                       customClass: {
                           popup: 'swal-big-popup',
                           title: 'swal-big-title',
                           htmlContainer: 'swal-big-text'
                       }
                   });

                }
           });
       }

       function SaveRecord_Retirement() {
           var btnSave = $("#btn_save").val();
           var Trans_Type = $("#ddl_transType").val();

           if (Trans_Type == 0 || Trans_Type == "0" || Trans_Type == '0' || Trans_Type == "") {
               Swal.fire({
                   icon: 'error',
                   title: 'Error!',
                   text: 'Fill mandatory fields',
                   showConfirmButton: false,
                   timer: 2000,
                   customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               });

                console.error("Error: Trans_Type is required.");
               return;
           }

           var Date = $("#txtDate").val();
           var Trans_no = $("#transactionno").val();
           var Remarks = $("#txtRemarks").val();
           var id = '<%=Request.QueryString["ID"]%>';


      
           function parseDecimal(value) {
               if (!value) return 0;
               value = value.toString().replace(/,/g, '').trim(); // Remove commas and trim
               var parsed = parseFloat(value);
               return isNaN(parsed) ? 0 : parsed;
           }

           var table = $('#tblRetirement');
           var list = [];

           table.find('tr:gt(0)').each(function (key, value) {
               var assetId = $(value).find('select[name="ddl_Asset"]').val();
               var assetText = $(value).find('select[name="ddl_Asset"] option:selected').text();
               var Asset_Value = $(value).find('input[name="Asset_Value"]').val();
               var Asset_Depreciation = $(value).find('input[name="Asset_Depreciation"]').val();
               var Remaining_value = $(value).find('input[name="Remaining_value"]').val();
               var Retirement_Value = $(value).find('input[name="Retirement_Value"]').val();
               var Cr_Account = $(value).find('select[name="ddl_CrAccount"] option:selected').val();
               var Dr_account = $(value).find('select[name="ddl_DrAccount"] option:selected').val();

               var array = {
                   assetId: parseInt(assetId),
                   assetText:assetText,
                   Asset_Value: parseDecimal(Asset_Value),
                   Asset_Depreciation: parseDecimal(Asset_Depreciation),
                   Remaining_value: parseDecimal(Remaining_value),
                   Retirement_Value: parseDecimal(Retirement_Value),
                   Cr_Account: Cr_Account,
                   Dr_account: Dr_account
               };
             
               list.push(array);
           });

        

           try {
               PageMethods.SaveRetirementRecord(
                   Trans_Type, Trans_no, Remarks, Date, btnSave, id, list,
                   function (response) {
                       var master_id = response;
                       if (master_id != '-1') {
                           Swal.fire({
                               icon: 'success',
                               title: 'Success!',
                               text: 'Data has been saved successfully.',
                               showConfirmButton: false,
                               timer: 2500,
                               customClass: {
                                   popup: 'swal-big-popup',
                                   title: 'swal-big-title',
                                   htmlContainer: 'swal-big-text'
                               }
                           });
                           window.location.href = "AssetRetirement.aspx";
                       }
                   }
               );
           } catch (error) {
               console.error("Error while saving record:", error);
           }
       }

       function LoadTransType() {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/LoadTransType",
               data: "",
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data) {
                   var options = '<option value="0" >Please Select</option>';
                   var values = JSON.parse(data.d);
                   $.each(values, function (key, value) {
                       options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                   });
                   $('#ddl_transType').html(options);

               },
               failure: function (response) {
                   alert(response.d);
               }
           });

       }

       let rowIndexCounter = 0;

       function Addrow() {

           rowIndexCounter++;

           //console.log("Adding row with rowIndex:", rowIndexCounter);

           var rows = '<tr>' +
               '<td><select id="ddl_Asset' + rowIndexCounter + '" name="ddl_Asset" onchange="getValues(this);" class="form-control" style="width:122px!important;"></select></td>' +
               '<td><input type="text" id="Asset_Value' + rowIndexCounter + '" name="Asset_Value" Readonly style="width:122px!important;height: 32px" /></td>' +
               '<td><input type="text" id="Asset_Depreciation' + rowIndexCounter + '" name="Asset_Depreciation" Readonly style="text-align: right;width:122px!important;height: 32px" /></td>' +
               '<td><input type="text" id="Remaining_value' + rowIndexCounter + '" name="Remaining_value" Readonly style="width:122px!important;height: 32px" /></td>' +
               '<td><input type="text" id="Retirement_Value' + rowIndexCounter + '" name="Retirement_Value"  style="width:122px!important;height: 32px" /></td>' +
               '<td><select id="ddl_CrAccount' + rowIndexCounter + '" name="ddl_CrAccount" class="form-control" style="width:122px!important;"></select></td>' +
               '<td><select id="ddl_DrAccount' + rowIndexCounter + '" name="ddl_DrAccount" class="form-control" style="width:122px!important;"></select></td>' +
               '</tr>';
  

           setTimeout(function () {
               $('#tblRetirement tbody').append(rows);
               LoadAsset(rowIndexCounter);
               LoadCreditAccount(rowIndexCounter);
               LoadDebitAccount(rowIndexCounter);
           },1000)
           

    
       }

       function LoadAsset(rowIndex, selectedId) {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/LoadAssets",
               data: "", // keep as is
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data) {
                   var options = '<option value="0">Please Select</option>';
                   var values = JSON.parse(data.d);
                   $.each(values, function (key, value) {
                       options += '<option value="' + value.Asset_Definition_Id + '">' + value.Item_Description + '</option>';
                   });

                   var $ddl = $('#ddl_Asset' + rowIndex);
                   $ddl.html(options);

                   if (selectedId) {
                       // Set the selected value after populating options
                       $ddl.val(selectedId);
                   }

                   $ddl.select2(); // apply Select2 after value is set
               },
               failure: function (response) {
                   alert(response.d);
               }
           });
       }

       function LoadCreditAccount(rowIndex, selectedId) {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/LoadCreditAccounts",
               data: "",
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data) {
                   var options = '<option value="0">Please Select</option>';
                   var values = JSON.parse(data.d);
                   $.each(values, function (key, value) {
                       options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
                   });

                   var $ddl = $('#ddl_CrAccount' + rowIndex);
                   $ddl.html(options);

                   if (selectedId) {
                       $ddl.val(selectedId);
                   }

                   $ddl.select2();
               },
               failure: function (response) {
                   alert(response.d);
               }
           });
       }

       function LoadDebitAccount(rowIndex, selectedId) {
           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/LoadDebitAccounts",
               data: "",
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data) {
                   var options = '<option value="0">Please Select</option>';
                   var values = JSON.parse(data.d);
                   $.each(values, function (key, value) {
                       options += '<option value="' + value.Account_ID + '">' + value.Account_Name + '</option>';
                   });

                   var $ddl = $('#ddl_DrAccount' + rowIndex);
                   $ddl.html(options);

                   if (selectedId) {
                       $ddl.val(selectedId);
                   }

                   $ddl.select2();
               },
               failure: function (response) {
                   alert(response.d);
               }
           });
       }





       function getValues(selectElement) {
           var AssetId = $(selectElement).val();
           var rowIndex = $(selectElement).attr('id').replace('ddl_Asset', ''); // Extract the row index from the select element's ID

           $.ajax({
               type: "POST",
               url: "AssetRetirement.aspx/GetAssetValues",
               data: JSON.stringify({ AssetId: AssetId }),
               contentType: "application/json; charset=utf-8",
               dataType: "json",
               success: function (data) {
                   var assetData = JSON.parse(data.d);

                   // Populate the fields dynamically using the row index
                   $('#Asset_Value' + rowIndex).val(assetData.Capitilization_Cost);
                   $('#Asset_Description' + rowIndex).val(assetData.Item_Description);
                   $('#Asset_Depreciation' + rowIndex).val(assetData.Depereciation_Amount_charge);

                   var capCost = parseFloat(assetData.Capitilization_Cost) || 0;
                   var depCharge = parseFloat(assetData.Depereciation_Amount_charge) || 0;

                   var RemainingValue = capCost - depCharge;
                   //console.log(RemainingValue);

                   $('#Remaining_value' + rowIndex).val(RemainingValue); // Optional: round to 2 decimals

               },
               failure: function (response) {
                   alert("Error: " + response.d);
               }
           });
       }


       function ApproveRetirement() {
           $('#tblRetirement tbody tr').each(function (key, value) {
               var assetRetId = $(value).find('td input[name="Ret_detail_id"]').val();
               PageMethods.approveAssetRetirement(assetRetId, function (response) {
                   var data = response;
                   if (data == "Success") {
                       Swal.fire({
                           icon: 'success',
                           title: 'Success!',
                           text: 'Approve Retirement Successfully.',
                           showConfirmButton: false,
                           timer: 2500,
                           customClass: {
                               popup: 'swal-big-popup',
                               title: 'swal-big-title',
                               htmlContainer: 'swal-big-text'
                           }
                       });
                   }
               });
           });

           window.location.href = 'AssetRetirementView.aspx';
       }
       function UnApproveRetirement() {
           $('#tblRetirement tbody tr').each(function (key, value) {
               var assetRetId = $(value).find('td input[name="Ret_detail_id"]').val();
               PageMethods.UnapproveAssetRetirement(assetRetId, function (response) {
                   var data = response;
                   if (data == "Success") {
                       Swal.fire({
                           icon: 'success',
                           title: 'Success!',
                           text: 'Approve Retirement Successfully.',
                           showConfirmButton: false,
                           timer: 2500,
                           customClass: {
                               popup: 'swal-big-popup',
                               title: 'swal-big-title',
                               htmlContainer: 'swal-big-text'
                           }
                       });
                    }
               });
           });

           window.location.href = 'AssetRetirementView.aspx';
       }

   </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">


    <div class="row">
        <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Transaction Type:</label>
            <select id="ddl_transType"></select>
        </div>
         <div class="col-lg-3 col-md-3 col-sm-4">
            <label>Date</label>
            <input type="text" name="Date" disabled id="txtDate" />
        </div>
        <div class="col-lg-3 col-md-3 col-sm-4" id="ddl_year">
            <label>Transaction #:</label>
             <input type="text" name="Date"  id="transactionno" />
        </div>

       


        <div class="col-lg-9 col-md-3 col-sm-4">
            <label>Remarks</label>
            <input type="text" id="txtRemarks" />
        </div>
        <div class="col-lg-2 col-md-2 col-sm-2">
            <label></label>
            <input type="button" value="+" class="btn btn-primry"  id="btnload" onclick="Addrow()" />
        </div>


    </div>

     <table class="table" id="tblRetirement">
            <thead>
                <tr>
                    <th>Asset</th>
                    <th>Asset Value</th>
                    <th>Asset Depereciation</th>
                    <th>Remaining Value</th>
                    <th>Retirement Value</th>
                    <th>Cr Account</th>
                    <th>Dr Account</th>
                </tr>
            </thead>
            <tbody>

            </tbody>
        </table>
    

    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-8">
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn_save" class="btn btn-yellow" value="Save" onclick="SaveRecord_Retirement()" />
            </div>
            <div class="col-lg-2 col-md-2  col-sm-3">
                <input type="button" id="btn-new" onclick="window.location = 'AssetRetirement.aspx'" class="btn btn-yellow" value="New" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3">
                <input type="button" id="btn_back" class="btn btn-yellow" onclick="window.location = 'AssetRetirementView.aspx'" value="View" />
            </div>
            <div class="col-lg-2 col-md-2 col-sm-3" id="approve-div" style="display:none">
                <input type="button" id="btn_Approve"  class="btn btn-yellow" value="Approve" onclick="ApproveRetirement()" />
            </div>

            <div class="col-lg-2 col-md-2 col-sm-3" id="unapprove-div" style="display:none">
                <input type="button" id="btn_UnApprove"  class="btn btn-yellow" value="UnApprove" onclick="UnApproveRetirement()" />
            </div>

        </div>
    </div>
</asp:Content>
