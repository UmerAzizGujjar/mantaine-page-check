<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddDoctor_Packages.aspx.cs" Inherits="PMS.Modules.Inventory.AddDoctor_Packages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/Tibbit_theme/css/CustomCss/swalalert.css" rel="stylesheet" />
     <script type="text/javascript">
 $(document).ready(function () {
     debugger;
     var Item_Code = $("#hdfItem_Code").val();
     FillLabTests();
     GetPanelItems();
     LoadDetailDoctor();

     $('#btnSave').click(function () {
         debugger;
         var btnSave = $('#btnSave').val();
         var PAckID = $('#hdnPackage_ID').val();

         var table = $('#tblbodyPackage');
         var tableDoc = $('#tblDoc');
         var Pkg_list = [];
         var Doc_list = [];
         var Package = $('#ctl00_MainContent_txtPackage_Name').val();
         var Remarks = $('#ctl00_MainContent_txtRemarks').val();
         var PackageType = $('#ctl00_MainContent_ddlPackageType').val();
         var duration = $('#ctl00_MainContent_txtDuration').val();
         var PerDay_Charges = $('#ctl00_MainContent_txtPerDayCharges').val();
         if (PerDay_Charges == '' || PerDay_Charges == "") {
             PerDay_Charges = 0.00
         }
         table.find('tr').each(function (key, value) {
             debugger;
             var Amount = $(value).find('td input[name=txAmount]').val();
             if (Amount == "" || Amount == null) Amount = 0;

             Pkg_list.push({ 'Item': $(value).find('td input[name=txtDes]').val(), 'QTy': $(value).find('td input[name=txtQTy]').val(), 'Price': $(value).find('td input[name=txPrice]').val(), 'Amount': Amount, 'ItemType': $(value).find('td input[name=ItemType]').val() });

         });
         var PAKg = { 'PKDetail': Pkg_list };

         $('#tblDoc tr').each(function () {
             var Doctor_Id = $(this).find('[name="Dcotor"]').val();
             var Department_Id = $(this).find('[name="Departments"]').val();
             if (Doctor_Id || Department_Id) {
                 Doc_list.push({
                     Doctor_Id: Doctor_Id,
                     Department_Id: Department_Id
                 });
             }
         });
         if (Doc_list.length === 0) {
             Swal.fire({
                 icon: 'error',
                 title: 'Error!',
                 text: 'Please select at least one Doctor.',
                 showConfirmButton: false,
                 timer: 2000,
                 customClass: {
                     popup: 'swal-big-popup',
                     title: 'swal-big-title',
                     htmlContainer: 'swal-big-text'
                 }
             });

             return;
         }
         var PAKrate = { 'PKRateDetail': Doc_list };
         PageMethods.SavePackage(btnSave, PAckID, Package, Remarks, PackageType, duration, JSON.stringify(PAKg), JSON.stringify(PAKrate), PerDay_Charges, function (res) {
             Swal.fire({
                 icon: 'success',
                 title: 'Success!',
                 text: 'Record Saved Successfully.',
                 showConfirmButton: false,
                 timer: 2500,
                 customClass: {
                     popup: 'swal-big-popup',
                     title: 'swal-big-title',
                     htmlContainer: 'swal-big-text'
                 }
             });

             $('#btnSave').val("Update");
             window.location = "AddDoctor_Packages.aspx?Doc_Package_id=" + res;
         });
     });
     var id = '<% =Request.QueryString["Doc_Package_id"] %>';
     if (id != "") {
         debugger;
         PopulatePackage(id);
         LoadDoctor();
         $('#btnSave').val('Update');
     }
     $('#add-new-testDirect').click(function () {
         PageMethods.GetLabTestDDLDetails(ddlLabTest.value, function (res) {
             console.clear();
             $.each(JSON.parse(res), function (key, value) {

                 var Result = 'Result';
                 var test = $('#ddlLabTest').val();
                 var date = '<%= DateTime.Now %>';
                 var TestMainDepartmentName;
                 var lenght = tblbodyPackage.rows.length + 1;
                 if (lenght >= 2) {
                     var tbody = document.getElementById('tblbodyPackage');
                     var rowlenth = tbody.rows.length;
                     var total = 0.00;
                     for (var i = 1; i <= rowlenth; i++) {
                         var id;

                         id = $('#txtDes' + i + '').val();
                         if (id == value.TestID) {
                         }
                     }
                 }

                 if (value.Rate == null || value.Rate == "")
                     value.Rate = 0;

                 var row = '<tr><td>' + lenght + '</td>  <td><input type="hidden" name="txtDes" id="txtDes' + lenght + '" value="' + value.TestID + '" /> <input type="hidden" name="txtRotation" value="0"> ' + (value.MainDepartmentName == null ? '' : value.MainDepartmentName + ', ') + ' ' + value.TestName + ' ' + (value.GroupName == null ? ' ' : ', ' + value.GroupName) + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + value.Rate + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td></td> <td> <input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td><td><input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="Test"/> <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';

                 $('#tblPackage').append(row);
                 $('#TestModel').modal('hide');
                 var qty = $('#txtQty' + lenght + '').val();
                 var price = $('#txPrice' + lenght + '').val();
                 var amount = qty * price;
                 $('#Amountspan' + lenght + '').text(amount);
                 $('#txAmount' + lenght + '').val(amount);
                 var tbody = document.getElementById('tblbodyPackage');
                 var rowlenth = tbody.rows.length;
                 var total = 0.00;
                 for (var i = 0; i <= rowlenth; i++) {
                     var samt;
                     samt = $('#txAmount' + i + '').val();
                     if (samt != '') {
                         var amt = parseFloat(samt);
                         if (isNaN(amt) == false) {
                             total += amt;
                         }
                     }
                 }
                 if (total == 0 || isNaN(total)) {
                     $('#txttotalAMount').text("0");
                 }
                 else {
                     $('#txttotalAMount').text(total.toFixed(2));
                 }
             });
         }, function (err) { });
     });
     $('#ctl00_MainContent_ddlDoctor').select2();
     $('#ctl00_MainContent_ddlPanel').select2();
     $('#ctl00_MainContent_ddlPatient_Main_Category').select2();
     $('#ctl00_MainContent_ddlSubDepartment').select2();
 });
         function PopulatePackage(id) {

             PageMethods.GetPopulatePackage(id, function (res) {
                 var data = JSON.parse(res);
                 $('#ctl00_MainContent_txtPackage_Name').val(data.Package_Name);
                 $('#hdnPackage_ID').val(data.Doc_Packages_ID);
                 $('#ctl00_MainContent_txtDuration').val(data.Duration);
                 $('#ctl00_MainContent_txtPerDayCharges').val(data.PerDay_Charges);
                 $('#ctl00_MainContent_txtRemarks').val(data.Remarks);
                 setTimeout(function () {
                     $('#ctl00_MainContent_ddlPackageType').val(data.Package_Type).trigger('change');
                 }, 1000)
                 setTimeout(function () {
                     $('#ctl00_MainContent_ddlDoctor').val(data.Doctor_Id).trigger('change');
                 }, 1000)
                 setTimeout(function () {
                     $('#ctl00_MainContent_ddlPatient_Main_Category').val(data.Department).trigger('change');
                 }, 1000)
                 setTimeout(function () {
                     $('#ctl00_MainContent_ddlSubDepartment').val(data.Sub_Department).trigger('change');
                 }, 1000)
                 PopulatePackageDetail(id);
             },
                 function (error) {
                     alert(error.get_message());
                 })
         }
         function value_delete(row) {
             $(row).closest('tr').remove();
         }
         function PopulatePackageDetail(id) {
             debugger;
             PageMethods.GetPackageDetail(id, function (res) {

                 var item = JSON.parse(res);
                 var rows = '';
                 var result;
                 $.each(item, function (key, value) {
                     debugger;
                     var checked = "false";
                     var isFixed = value.IsFixed;
                     if (isFixed == true) {
                         checked = "true";
                     }
                     var lenght = tblbodyPackage.rows.length + 1;
                     var desc = (value.Item_Type != 'Test') ? value.Item_Code + "-" + value.itemanme : " " + value.itemanme;
                     var rows = '<tr><td>' + lenght + ' </td><td> <input type="hidden" name="txtDes" id="txtDes' + lenght + '" style="width: 189px !important;" value="' + value.Item_Code + '"/>' + value.itemanme + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="' + value.QTY + '" onkeyup="UpdateAmount(' + lenght + ') "/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + value.Price + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td> <td> <input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="' + value.Item_Type + '"/> <a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
                     $('#tblPackage').append(rows);
                     var qty = $('#txtQty' + lenght + '').val();
                     var price = $('#txPrice' + lenght + '').val();
                     var amount = qty * price;
                     $('#Amountspan' + lenght + '').text(amount);
                     $('#txAmount' + lenght + '').val(amount);
                     if (value.IsFixed == true) {
                         $('#checkbox' + lenght + '').prop('checked', true);
                     }
                     var tbody = document.getElementById('tblbodyPackage');
                     var rowlenth = tbody.rows.length;
                     var total = 0.00;
                     for (var i = 0; i <= rowlenth; i++) {
                         var samt;
                         samt = $('#txAmount' + i + '').val();
                         if (samt != '') {
                             var amt = parseFloat(samt);
                             if (isNaN(amt) == false) {
                                 total += amt;
                             }
                         }
                     }
                     if (total == 0 || isNaN(total)) {
                         $('#txttotalAMount').text("0");
                     }
                     else {
                         $('#txttotalAMount').text(total.toFixed(2));
                     }
                 });
             });
             $('#btnSave').val("Update");
         }
         function GetDepartment(doc_id, rowID) {
             var options = '';
             PageMethods.GetDepartment(doc_id,function (Tests) {
                 $.each(JSON.parse(Tests), function (key, value) {
                     options += '<option value="' + value.DataValue_Name + '" >' + value.DataValue_Description + '</option>';
                 });       
                 var departmentsDropdown = $('#Departments' + rowID);
                 departmentsDropdown.empty(); 
                 departmentsDropdown.append(options);
             });
         }
         function GetPanelItems() {
             var Panel_id = $('#ctl00_MainContent_ddlPanel').val();
             if (Panel_id == "" || Panel_id == undefined || Panel_id == null) {
                 Panel_id = 0;
             }
             var options = "<option value='0'>Please Select</option>";
             $.ajax({
                 type: "POST",
                 url: "AddDoctor_Packages.aspx/GetPanelItems",
                 data: JSON.stringify({ Panel_id: Panel_id }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (data) {
                     debugger;
                     $.each(JSON.parse(data.d), function (key, value) {
                         options += '<option value="' + value.Item_ID + '" Rate="' + value.Sale_Rate + '" >' + value.Description + '</option>';
                     });
                     $('#ddlItems').html(options);
                     $('#ddlItems').select2();
                 }, error: function () {
                 }
             });
         }

         function FillLabTests() {
             var options = "<option value='0'>Please Select</option>";
             PageMethods.GetLabTests(function (Tests) {
                 $.each(JSON.parse(Tests), function (key, value) {
                     options += '<option value="' + value.SerialNo + '" >' + value.TestName + '</option>';
                 });
                 $('#ddlLabTest').html(options);
                 $('#ddlLabTest').select2();
                 localStorage.TestForCategoryWiseSelections = options;
             });
         }
       
         function new_value() {

             var discount = $('#ctl00_MainContent_txtDiscount').val();
             var item = $('#ddlItems').val();
             var Rate = $('#ddlItems').find('option:selected').attr('Rate');
             PageMethods.AddItem(item, function (res) {
                 var item = JSON.parse(res);
                 var rows = '';
                 var result;
                 $.each(item, function (key, value) {
                     var lenght = tblbodyPackage.rows.length + 1;
                     if (lenght >= 2) {
                         var tbody = document.getElementById('tblbodyPackage');
                         var rowlenth = tbody.rows.length;
                         var total = 0.00;
                         for (var i = 1; i <= rowlenth; i++) {
                             var id;
                             id = $('#txtDes' + i + '').val();
                             if (id == value.Item_ID) {
                             }
                         }
                     }
                     var ItemType;
                     if (value.Services == true)
                         ItemType = "Service";
                     else
                         ItemType = "Item";
                     var rows = '<tr><td>' + lenght + ' </td><td> <input type="hidden" name="txtDes" id="txtDes' + lenght + '" style="width: 189px !important;" value="' + value.Item_ID + '"/>' + value.Description + '</td><td><input type="text" name="txtQTy" id="txtQty' + lenght + '" style="width:  57px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="text" name="txPrice" id="txPrice' + lenght + '" value="' + Rate + '" style="width:  75px !important;    height: 28px;" value="1" onkeyup="UpdateAmount(' + lenght + ')"/></td><td><input type="hidden" name="txAmount" id="txAmount' + lenght + '"/><span id="Amountspan' + lenght + '"></span></td> <td><input type="hidden" name="ItemType" id="ItemType' + lenght + '"  value="' + ItemType + '"/><a href="javascript:void(0)" onclick="value_delete(this)">Delete</a></td></tr>';
                     $('#tblPackage').append(rows);
                     var qty = $('#txtQty' + lenght + '').val();
                     var price = $('#txPrice' + lenght + '').val();
                     var amount = qty * price;
                     $('#Amountspan' + lenght + '').text(amount);
                     $('#txAmount' + lenght + '').val(amount);
                     var tbody = document.getElementById('tblbodyPackage');
                     var rowlenth = tbody.rows.length;
                     var total = 0.00;
                     for (var i = 0; i <= rowlenth; i++) {
                         var samt;
                         samt = $('#txAmount' + i + '').val();
                         if (samt != '') {
                             var amt = parseFloat(samt);
                             if (isNaN(amt) == false) {
                                 total += amt;
                             }
                         }
                     }
                     if (total == 0 || isNaN(total)) {
                         $('#txttotalAMount').text("0");
                     }
                     else {
                         $('#txttotalAMount').text(total.toFixed(2));
                     }
                 });
             });
         }
         function OpenNewForm() {
             window.location = "AddDoctor_Packages.aspx";
         }

         function LoadDoctor() {

             debugger;
             var id = '<% =Request.QueryString["Doc_Package_id"] %>';
             $.ajax({
                 type: "POST",
                 url: "AddDoctor_Packages.aspx/LoadDoctor",
                 data: JSON.stringify({
                     "Id": id
                 }),
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     var parsed_Data = JSON.parse(response.d);
                     debugger;
                     var rows = '';
                     for (var i = 1; i <= parsed_Data.length; i++) {
                         generateRows();
                         debugger;
                         $('#Select' + i + '').val(parsed_Data[i - 1].Doctor_Id);
                         $('#Departments' + i + '').val(parsed_Data[i - 1].Department_Id);
                     }
                 },
                 error: function () {
                     alert("Error");
                 }
             });
         }
         function DeleteRate(row) {
             $(row).closest('tr').remove();
         }
         function generateRows() {
             var rowID = $('#tblDoc tr').length - 1;
             var html = '<tr id="Row' + rowID + '">' +
                 '<td><select style="width: 145px !important;" name="Dcotor" id="Select' + rowID + '">' + Doctors + '</select></td>' +
                 '<td><select style="width: 145px !important;" name="Departments" id="Departments' + rowID + '"></select></td>' +
                 '<td><a href="javascript:void(0)" onclick="DeleteRate(this)">Delete</a></td>' +
                 '</tr>';
             $('#tblDoc').append(html);
             setTimeout(function () {
                 $('#Select' + rowID).select2().trigger('change');
                 $('#Departments' + rowID).select2().trigger('change');
             }, 1000);
             $('#Select' + rowID).change(function () {
                 var doc_id = $(this).val();
                 GetDepartment(doc_id, rowID);
             });
         }
         function LoadDetailDoctor() {
             debugger;
             var options = '<option value="0">Select Doctor</option>';
             $.ajax({
                 type: "post",
                 url: "AddDoctor_Packages.aspx/GetDoctors",
                 data: "",
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 async: false,
                 success: function (response) {
                     debugger;
                     $.each(JSON.parse(response.d), function (key, value) {

                         options += '<option value="' + value.Emp_ID + '">' + value.Emp_Name + '</option>';
                     });
                     Doctors = options;
                 },
                 failure: function (response) {
                     alert("Error!!!");
                 }
             });
         }
     </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

     <form id="Items">
     <div class="row">
         <div class="col-lg-3 col-md-4 col-sm-6">
             <asp:Label ID="LbPackage_Name" runat="server" Text="Package Name"></asp:Label>
             <asp:HiddenField ID="hdfItem_Code" runat="server" ClientIDMode="Static" />
             <asp:TextBox ID="txtPackage_Name" runat="server"></asp:TextBox>
             <asp:HiddenField ID="hdnPackage_ID" runat="server" ClientIDMode="Static" />
         </div>
         <div class="col-lg-3 col-md-4 col-sm-6">
             <asp:Label ID="Label3" runat="server" Text="Package Type"></asp:Label>
             <asp:DropDownList ID="ddlPackageType" runat="server" AppendDataBoundItems="true"></asp:DropDownList>
         </div>

           <div class="col-lg-3 col-md-4 col-sm-6">
          <asp:Label ID="Label1" runat="server" Text="Duration"></asp:Label>
          <asp:TextBox ID="txtDuration" runat="server"></asp:TextBox>
      </div>
               <div class="col-lg-3 col-md-4 col-sm-6">
          <asp:Label ID="Label5" runat="server" Text="Per Day Charges"></asp:Label>
          <asp:TextBox ID="txtPerDayCharges" runat="server"></asp:TextBox>
      </div>

     </div>
     <div class="row">
            <div class="col-lg-3 col-md-4 col-sm-6">
             <asp:Label ID="Label4" runat="server" Text="Remarks"></asp:Label>
             <asp:TextBox ID="txtRemarks" runat="server" TextMode="MultiLine" Style="width: 100%; height: 38px !important; border-radius: 5px !important"></asp:TextBox>
         </div>
         <div class="col-lg-2 col-md-4 col-sm-6">
             <asp:Label ID="Label2" runat="server" Text="Services"></asp:Label>
             <select id="ddlItems">
                 <option value="">Select Item </option>
             </select>
         </div>
         <div class="col-lg-1 col-md-4 col-sm-6">
             <input type="button" value="Add" class="btn btn-primry" id="add-new-test" onclick="new_value()" style="margin-top:19px !important" />
         </div>
         <div class="col-lg-2 col-md-4 col-sm-6">
              <asp:Label ID="Label6" runat="server" Text="Select Test"></asp:Label>
             <select id="ddlLabTest">
                 <option value="">Select Test </option>
             </select>
         </div>
         <div class="col-lg-1 col-md-4 col-sm-6">
             <input type="button" value="Add Test" class="btn btn-primry" id="add-new-testDirect" style="margin-top: 23px !important" />
         </div>


     </div>

 </form>

    <div id="PatientDetail" class="row" style="width: 100%">
        <div class="col-lg-8 col-md-6 col-sm-12">
            <div class="row">
            <table class="table" id="tblPackage" style="width: 100%;">
                <thead>
                    <th style="width: 56px">Sr No.</th>
                    <th style="width: 200px">Description</th>
                    <th style="width: 63px;">Qty</th>
                    <th style="width: 57px">Charges</th>
                    <th style="width: 38px">Amount</th>
                    <th style="width: 56px">Action</th>
                </thead>
                <tbody id="tblbodyPackage"></tbody>
            </table>
                </div>
                 <div class="row">
             <div style="margin-left: 226px;"><b>Total Amount:</b> &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp<span id="txttotalAMount"></span></div>
     </div>
        </div>
        <div id="doc_div" class="col-lg-4 col-md-6 col-sm-12" style="overflow: scroll; height: 200px;">
            <table id="tblDoc" class="table" style="width: 100%!important;">
                <thead>
                    <tr><a href="javascript:void(0)" id="doc_btn" onclick="generateRows()">Add More</a></tr>
                    <tr>
                        <th style="width: 145px;">Doctor</th>
                        <th style="width: 145px;">Department</th>

                        <th style="width: 70px;">Action</th>
                    </tr>
                </thead>

                <tbody id="tblDocbody"></tbody>

            </table>
        </div>
    </div>


 
     <div class="row">
         <div class="col-lg-1 col-md-3 col-sm-6">
             <input type="button" class="btn btn-primry" style="width: 93px" id="btnSave" value="Save" />
         </div>
         <div class="col-lg-1 col-md-3 col-sm-6">
             <input type="button" id="new" class="btn btn-yellow" onclick="OpenNewForm();" value="New" />
         </div>
         <div class="col-lg-1 col-md-3 col-sm-6">
             <input type="button" id="listview" class="btn btn-primry" onclick="window.open('Doctor_Packages_List.aspx');" value="List View" />
         </div>
         <div class="col-lg-1 col-md-3 col-sm-6">
             <input type="button" value="Print" class="btn btn-gary" name="name" id="btn_Print" onclick="PrintGRNDetail();" style="width: 81px;" />
         </div>
     </div>
                 <asp:Label ID="lblMessage" Text="" runat="server" />

</asp:Content>
