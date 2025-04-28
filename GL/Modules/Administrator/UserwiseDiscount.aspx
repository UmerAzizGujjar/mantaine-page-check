<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserwiseDiscount.aspx.cs" Inherits="PMS.UserwiseDiscount" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript" src="Scripts/moment.js"></script>
    <script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>
    <script type="text/javascript" src="Scripts/moment.min.js"></script>
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script src="Scripts/jquery.ptTimeSelect.js" type="text/javascript"></script>
    <script type="text/javascript" src="<%=Page.ResolveUrl("~/Scripts/jquery.tokeninput.js")%>"></script>
    <link rel="stylesheet" type="text/css" href="<%=Page.ResolveUrl("~/Styles/jquery.datetimepicker.css")%>" />
    <script src="<%=Page.ResolveUrl("~/Scripts/jquery.datetimepicker.js")%>" type="text/javascript"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/css/select2.min.css" rel="stylesheet" />
    <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.3/js/select2.min.js"></script>
       <script type="text/javascript">
           $(document).ready(function ()
           {
               //function calls
               FillUsers();
               //Events
               $('#btnSave').on('click', function ()
               {
                   var _userid = $('#ddlUser').val();
                   if (_userid == "0")
                   {
                       alert("Please Select User");
                       return true;
                   }
                   var _discount = $('#txtDiscount').val();
                   var _discount_Amt = $('#txtDiscountAmt').val();
                   if (_discount == "") _discount = 0;
                   if (_discount_Amt == "") _discount_Amt = 0;
                   Save(_userid, _discount, _discount_Amt);

               });
               $('#ddlUser').on('change', function ()
               {
                   debugger;
                   var user = $(this).val();
                   var disc = $(this).find('option:selected').attr('Discount');
                   var disc_amt = $(this).find('option:selected').attr('discountamt');
                   if (disc == "") disc = 0;
                   if (disc_amt == "") disc_amt = 0;
                   $('#txtDiscount').val(disc);
                   $('#txtDiscountAmt').val(disc_amt);

               });
               $('#txtDiscount').on('keyup', function () {
                   var value = $(this).val();
                   if (parseInt(value) > 100)
                   {
                      // $('#txtDiscount').val(100);

                   }


               });

           });
           function Save(_userid, _discount, _discount_Amt)
           {
               $.ajax({
                   type: "Post",
                   contentType: "application/json; charset=utf-8",
                   url: "UserwiseDiscount.aspx/Save",
                   data: JSON.stringify({
                       "User_Id": _userid,
                       "Discount": _discount,
                       "Discount_Amt": _discount_Amt
                   }),
                 
                   success: function (response)
                   {
                       debugger;
                       if (response.d == "success")
                       {
                           alert("Data has been saved successfully");
                           window.location.href = "UserwiseDiscount.aspx";

                       }
                  },
                   error: function ()
                   {


                   }
               });
}
           
           function FillUsers()
           {
               debugger;
               var options = '';
               $.ajax({
                   type: "Post",
                   contentType: "application/json; charset=utf-8",
                   url: "UserwiseDiscount.aspx/FillUsers",
                   data: "",
               
                   success: function (resp)
                   {
                       debugger;
                       options = '<option value="0">Please Select</option>';
                       var users=JSON.parse(resp.d);
                       $.each(JSON.parse(resp.d), function (key, value)
                       {
                          

                           options += '<option value="' + value.UserId + '" Discount="' + value.Discount + '" DiscountAmt="' + value.Discount_Amt + '">' + value.UserName + '</option>';

                       });
                       $('#ddlUser').html(options);
                       $('#ddlUser').select2();
                       debugger;
                       var userid=  '<% =AppConfig.UserID %>';
                       var record = users.find(x=>x.UserId == userid);
                       $('#ddlUser').val(record.UserId).trigger('change');
                       $('#txtDiscount').val(record.Discount);
                       $('#txtDiscountAmt').val(record.Discount_Amt);
                       //var user_discount = users.find(x=>x.Discount == userid);

                     },
                   error: function ()
                    {


                    },

               });
           }
           </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <style>
        .float-left-child {
  float: left;
  margin-left: 10px;
}
    </style>
    <div class='parent'>
  <div class='child float-left-child'>   <label style="font-size:medium">User</label> </div>
  <div class='child float-left-child'> <select id="ddlUser" name="ddlUser" class="ddlUser"></select></div>
        
  <div class='child float-left-child'> Discount % <input type="number" id="txtDiscount" name="txtDiscount" class="txtDiscount" style="width: 27%!important;text-align:right;" placeholder="%" max="100"></div> 
        <div class='child float-left-child' style="margin-left: -87px!important;"> Discount Amount <input type="number" id="txtDiscountAmt" name="txtDiscountAmt" class="txtDiscountAmt" style="width: 24%!important;text-align:right;" placeholder="" max="100"></div> 
         <div class='child float-left-child' style="margin-left: -79px;"> <input type="button" id="btnSave" name="btnSave" class="btnSave" style="" value="Save"/></div>
</div>

   
</asp:Content>
