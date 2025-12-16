<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Token_List.aspx.cs" Inherits="PMS.Modules.Administrator.Token_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
    $(document).ready(function () {
        debugger;
        privatecheck();
        setTimeout(function () {
            checkprivateorgeneral();
        },800)
       


    });
    debugger;
    function checkprivateorgeneral() {
        debugger;
    
            GetLatest_doc_Token();
            GetLatestToken();
    }
  
    var doc;
    var doc_check;
    function getdoctor() {
            debugger;
            $.ajax({
                type: "POST",
                url: 'Token_List.aspx/getdoctor',
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async: true,
                success: function (data) {
                    debugger;
                    doc = data.d;
                   
                    var parsedData = JSON.parse(doc);
                   
                    doc_check = parsedData[0].Id;
                },


                failure: function () {

                    alert(bi);
                }
            });
        }
   
 
    function GetLatestToken() {
        $.ajax({
            url: 'Token_List.aspx/LoadTokenPatient',
            type: 'post',
            contentType: 'application/json;charset=utf-8',
            dataType: 'json',
            success: function (_data) {
                debugger;
                _data = JSON.parse(_data.d);
                var mdTable = $('#tbloutPatients');
                $('#tbl tr:gt(0)').remove();
                table = $('#ibody');
                var rows = '';
                table.empty();
                debugger;
              
                /*$('#Filter_List').text('Filter Clininc')*/
             
                $.each(_data, function (key, value) {
                    bill_id = value.Bill_ID;
                    debugger;

                    var rowColor = ''; 

                    if (value.fc == "001") {
                        rowColor = 'background: linear-gradient(to Right, #f5c5f6, #e4c1fa);'
                    } else if (value.fc == "002") {
                        rowColor = 'background: linear-gradient(to Right, #ff9190,#fdc094 );'
                    } else if (value.fc == "003") {
                        rowColor = 'background: linear-gradient(to Right, #7BE495, #CFF4D2);'
                    }

                    $("#ibody").append('<tr style="' + rowColor + '"><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.tokenNo + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Full_Name + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.filter_clinic + '</td></tr>');
                    length++;
              
                    return true;
                });

            },
            error: function () {
                alert("Get Error");
            }
        });
    }
    setInterval(function () {
        location.reload(); 
    }, 15000);
    
    var rowColors;

    function GetLatest_doc_Token() {
        $.ajax({
            url: 'Token_List.aspx/LoadDocTokenPatient',
            type: 'post',
            contentType: 'application/json;charset=utf-8',
            dataType: 'json',
            success: function (_data) {
                debugger;
                _data = JSON.parse(_data.d);
                var mdTable = $('#tblprivatepatient');
                $('#tbl tr:gt(0)').remove();
                table = $('#ibody_pvt');
                var rows = '';
                table.empty();
                debugger;

                //$('#forfilter').hide();

                var isFirstRowAppended = false; 

                $.each(_data, function (key, value) {
                    //var a = value.doc_name;
                    //$('#Filter_List').html('<span style="font-size:50px;" class="highlight blink">' + a + '</span> Patient List');

                    debugger;

                    var rowColors = '';
                    if (!isFirstRowAppended) {
                        rowColors = 'background: linear-gradient(to Right, #f66e6e, white)';
                        isFirstRowAppended = true; 
                    } else {
                        rowColors = 'background: linear-gradient(to Right, #7beafd, #e1fdf0)';
                    }


                    $("#ibody_pvt").append('<tr style="' + rowColors + '"><td style="display:none;"><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.Patient_ID + '" /><input id="Bil_id" name="patientid" class="patientid" type="hidden" value="' + value.filter_clinic + '" /></td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Doc_Token + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.Full_Name + '</td><td  style="font-size:25px;font-weight:bold;text-align: center;">' + value.doc_name + '</td></tr>');
                    length++;
                  
                    return true;
                });
            },
            error: function () {
                alert("Get Error");
            }
        });
    }

    setInterval(function () {
        location.reload();
    }, 15000); 

    var isprivate;
    function privatecheck() {
        debugger;
        $.ajax({
            type: "POST",
            url: "Token_List.aspx/isprivate",
            data: "",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            async: true,
            success: function (data) {
                debugger;
                isprivate = data.d;

            },
            failure: function () {

                alert(bi);
            }
        });
    }







    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">
        <form id="form1" runat="server">
        <div>
            <h1 style="text-align: center"><span id="Filter_List"></span>Token List</h1>
            <hr style="font-weight:bold;" />
        </div>
   
            <br />
            <br />


        <div class="row">
            <div class="col-lg-6 col-md-6 col-sm-6">
                  <h3 style="font-weight:bold">General Patients</h3>
                 <table class="table table-hover table-striped table-bordered" id="tbloutPatients" style="">
                <thead id="ihead" style="background: linear-gradient(to bottom, #bdc3c7, #2c3e50) !important;">
                    <tr style="">
                    
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Token No</th>
                        <%--<th style="font-size: 20px; font-weight: bold;text-align: center;">Mr No</th>--%>
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Patient Name</th>
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Filter Clinic</th>
                      
                    </tr>
                </thead>
                <tbody id="ibody">
                </tbody>
            </table>
            </div>
           <div class="col-lg-6 col-md-6 col-sm-6">
                <h3>Private Patients</h3>
               <table class="table table-hover table-striped table-bordered" id="tblprivatepatient" style="">
                <thead id="ihead_pvt" style="background: linear-gradient(to bottom, #bdc3c7, #2c3e50) !important;">
                    <tr style="">
                    
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Token No</th>
                        <%--<th style="font-size: 20px; font-weight: bold;text-align: center;">Mr No</th>--%>  
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Patient Name</th>
                        <th style="font-size: 20px; font-weight: bold;text-align: center;">Consultant</th>
                      
                    </tr>
                </thead>
                <tbody id="ibody_pvt">
                </tbody>
            </table>
           </div>
        </div>
       

    </form>
</div>
</asp:Content>
