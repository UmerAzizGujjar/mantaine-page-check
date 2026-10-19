<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Fluid_Electrolyte_Infusion.aspx.cs" Inherits="PMS.Fluid_Electrolyte_Infusion" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     
    
    
    <link href="../js/select2.min.css" rel="stylesheet"/>
    <link href="Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
        <script src="Scripts/moment.js"></script>
    <script src="Scripts/moment.min.js"></script>
    <script type="text/javascript">



        $(document).ready(function () {

            InfusionVOL();
            AdditiveDose();
            InfusionRate();
            Routes();
            InfussionPharmacy();
            additive();
            LoadPage();

<%--            var Order_ID = '<%= Request.QueryString["ID"]%>'
            setTimeout(function () {
                loadData_ddl(Order_ID);

            }, 3000);--%>
            
        });

        function InfusionVOL() {
            
            var infVol = '';

            PageMethods.InfusionVOL(function (Tests) {
                optionsInf = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    
                        optionsInf += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_InsVol').html(optionsInf);

            });
        }


        function AdditiveDose() {

            var optionsAdd = '';

            PageMethods.AdditiveDose(function (Tests) {
                optadd = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optadd += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_addtiveDose').html(optadd);

            });
        }


        function InfusionRate() {

            var optionsRate = '';

            PageMethods.InfusionRate(function (Tests) {
                optRate = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optRate += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_InsRate').html(optRate);

            });
        }


        function Routes() {

            var optionsRate = '';

            PageMethods.Routes(function (Tests) {
                optRoute = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    optRoute += '<option value="' + value.DataValueName + '" >' + value.DataValueDescription + '</option>';
                });
                $('#ddl_route').html(optRoute);

            });
        }


        function InfussionPharmacy() {

            var optionsRate = '';

            PageMethods.InfussionPharmacy(function (Tests) {
                opt_Pharm = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {
                    opt_Pharm += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                });
                $('#ddl_InsFluid').html(opt_Pharm);

            });
        }



        function additive() {


            PageMethods.additive(function (Tests) {
                opt_additive = '<option value="0">Please Select</option>';

                $.each(JSON.parse(Tests), function (key, value) {

                    opt_additive += '<option value="' + value.Item_ID + '" >' + value.Description + '</option>';
                });
                $('#ddl_addtive').html(opt_additive);

            });
        }



        function SaveAllRecord() {


            var btnSave = $('#btnSave').val();
            var ddl_Infs_fluid = $('#ddl_InsFluid').val();
            var ddl_Additive = $('#ddl_addtive').val();
            var ddl_inf_Vol = $('#ddl_InsVol').val();
            var ddl_add_Dose = $('#ddl_addtiveDose').val();

            var ddl_infs_Rate = $('#ddl_InsRate').val();
            var ddl_Route = $('#ddl_route').val();

            var editmode_ID = txt_primaaryid;

<%--            var editmode_ID = '<%= Request.QueryString["ID"]%>'--%>

            $('#btnSave').attr('disabled', true);
            var AllItemDetail = {
                'Infusion_Fluid': ddl_Infs_fluid, 'Additive': ddl_Additive,
                'Infusion_Volume': ddl_inf_Vol, 'Additive_Dose': ddl_add_Dose, 'Infusion_Rate': ddl_infs_Rate,
                'Route': ddl_Route, 'Infusion_Order_ID': editmode_ID
            };
            PageMethods.SaveInfs(btnSave, JSON.stringify(AllItemDetail), function (res) {
                  
                    alert('Data Save Successfully');

                window.location = "Fluid_Electrolyte_Infusion.aspx";
              
               
            });

        }

        //function loadData_ddl(Order_ID) {
        //    PageMethods.LoadData(Order_ID, function (resp) {
        //        var data = JSON.parse(resp);


        //        $('#ddl_InsFluid').val(data.Infusion_Fluid).change();
        //        $('#ddl_addtive').val(data.Additive).change();
        //        $('#ddl_InsVol').val(data.Infusion_Volume).change();
        //        $('#ddl_addtiveDose').val(data.Additive_Dose).change();
        //        $('#ddl_InsRate').val(data.Infusion_Rate).change();
        //        $('#ddl_route').val(data.Route).change();


        //    },



        //        function (error) {

        //        })
        //}



        //function Efghjkdit(ID) {


        //    window.location.href = "Fluid_Electrolyte_Infusion.aspx?ID=" + ID;
            
        //}


        var txt_primaaryid = 0;

        function Edit(row) {

            txt_primaaryid = $(row).closest('tr').find('td input[name=txt_primaaryid]').val();

            var txt_infusionfluid = $(row).closest('tr').find('td input[name=txt_infusionfluid]').val();
            $('#ddl_InsFluid').val(txt_infusionfluid).trigger('change');

            var txt_additive = $(row).closest('tr').find('td input[name=txt_additive]').val();
            $('#ddl_addtive').val(txt_additive).trigger('change');

            var txt_infusionVol = $(row).closest('tr').find('td input[name=txt_infusionVol]').val();
            $('#ddl_InsVol').val(txt_infusionVol).trigger('change');

            var txt_add_Dose = $(row).closest('tr').find('td input[name=txt_add_Dose]').val();
            $('#ddl_addtiveDose').val(txt_add_Dose).trigger('change');

            var txt_infRate = $(row).closest('tr').find('td input[name=txt_infRate]').val();
            $('#ddl_InsRate').val(txt_infRate).trigger('change');

            var txt_Route = $(row).closest('tr').find('td input[name=txt_Route]').val();
            $('#ddl_route').val(txt_Route).trigger('change');

           
            $('#btnSave').val("Update");
         
        }



        function LoadPage() {
        
            //Append data from data base table

            $.ajax({
                type: "POST",
                url: "Fluid_Electrolyte_Infusion.aspx/ViewList",

                data: JSON.stringify({

                }),

                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (data) {
                    var Priority = '';
                    var length = $("#table_res tr:gt(0)").length;

                    if (data != '') {
                        var data = JSON.parse(data.d);
                        var rows = '';

                        $.each(data, function (i, item) {
                            var C_date = moment(data[i].Create_Time).format('ll');
                            var C_Time = moment(data[i].Create_Time).format('LT');
                            
                            //<input type="text" readonly id="txt_infusionfluid_name' + (i + 1) + '" name="txt_infusionfluid_name" value="' + data[i].Infusion_Fluidname + '" />

                            rows += '<tr><td>' + (i + 1) + '</td><td style="display:none;"><input type="hidden" id="txt_primaaryid' + (i + 1) + '" name="txt_primaaryid" value="' + data[i].Infusion_Order_ID + '"/></td><td>' + C_date + ' ' + C_Time + '</td><td>' + data[i].Infusion_Fluidname + '</td><td style="display:none;"><input type="hidden" id="txt_infusionfluid' + (i + 1) + '" name="txt_infusionfluid" value="' + data[i].Infusion_Fluid + '"/></td><td>' + data[i].AdditiveName + '</td><td style="display:none;"><input type="hidden" id="txt_additive' + (i + 1) + '" name="txt_additive" value="' + data[i].Additive + '"/></td><td>' + data[i].Infusion_VolumeName + '</td><td style="display:none;"><input type="hidden" id="txt_infusionVol' + (i + 1) + '" name="txt_infusionVol" value="' + data[i].Infusion_Volume + '"/></td><td>' + data[i].Additive_DoseName + '</td><td style="display:none;"><input type="hidden" id="txt_add_Dose' + (i + 1) + '" name="txt_add_Dose" value="' + data[i].Additive_Dose + '"/></td><td>' + data[i].Infusion_RateName + '</td><td style="display:none;"><input type="hidden" id="txt_infRate' + (i + 1) + '" name="txt_infRate" value="' + data[i].Infusion_Rate + '"/></td><td>' + data[i].RouteName + '</td><td style="display:none;"><input type="hidden" id="txt_Route' + (i + 1) + '" name="txt_Route" value="' + data[i].Route + '"/></td><td><a href="#" onclick="Edit(this)" style="border-radius: 4px; background-color: #167f92d1; color: white; padding: 4px 11px 4px 11px; margin-left: 9px;">Edit</a></td></tr>';

                        });

                        $('#t_body').html(rows);
                    }

                    else {

                    }
                }
            });
        }




    </script>

    <style type="text/css">

   #table_res th{
            position:sticky;
            top:0px;
            background-color:#167f92;
            color:white;
            font-size: 14px;
        }
      /*  input[type="button"], [type="submit"] {
            background-color: #167f92d9 !important;
           border: 5px solid #3992a2;
        }*/



    </style>


</asp:Content>





<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="container-fluid">
        <div class="row row-1">

            <div class="col-md-2">
                <label>Infusion Fluid</label>
            </div>
            <div class="col-md-4">
                <select class="ddlInsFluid" id="ddl_InsFluid">
                    <option></option></select>
            </div>
            <div class="col-md-2">
                <label>Additive</label>
            </div>
            <div class="col-md-2">
                <select class="ddladdtive" id="ddl_addtive">
                    <option></option></select>
            </div>
        </div>



               <div class="row row-2">

            <div class="col-md-2">
                <label>Infusion Volume</label>
            </div>
            <div class="col-md-4">
                <select class="ddlInsVol" id="ddl_InsVol">
                    <option></option></select>
            </div>
            <div class="col-md-2">
                <label>Additive Dose</label>
            </div>
            <div class="col-md-2">
                <select class="ddladdtive" id="ddl_addtiveDose">
                    <option></option></select>
            </div>
        </div>


               <div class="row row-3">

            <div class="col-md-2">
                <label>Infusion Rate</label>
            </div>
            <div class="col-md-4">
                <select class="ddlInsRate" id="ddl_InsRate">
                    <option></option></select>
            </div>
            <div class="col-md-2">
                <label>Route</label>
            </div>
            <div class="col-md-2">
                <select class="ddlroute" id="ddl_route">
                    <option></option></select>
            </div>
        </div>

        <div class="row row-4">
            <div class="col-md-2">
                
                
            </div>
            <input type="button" id="btnSave" value="Save" onclick="SaveAllRecord()" style="margin-top: 30px; margin-left: 13px;"/>
        </div>


                <div class="row row_5">

            <table class="table table-hover table-striped table-bordered" id="table_res" style="overflow: scroll; height: auto; margin-top: 20px;">
               
                    <tr id="row_sample">
                        <th>S No.</th>
                        <th>Date & Time</th>
                        <th>Infusion Fluid</th>
                        <th>Additive</th>
                        <th>Infusion Volume</th>
                        <th>Additive Dose</th>
                        <th>Infsuion Rate</th>
                        <th>Route</th>
                        <th >Action</th>


                    </tr>

                <tbody id="t_body">
                </tbody>

            </table>



        </div>


    </div>





</asp:Content>
