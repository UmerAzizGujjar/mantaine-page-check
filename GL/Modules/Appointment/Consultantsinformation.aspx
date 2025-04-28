<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Consultantsinformation.aspx.cs" Inherits="PMS.Consultantsinformation" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link rel="stylesheet" type="text/css" href="Styles/jquery.datetimepicker.css" />
    <script src="Scripts/jquery.datetimepicker.js" type="text/javascript"></script>
       <script type="text/javascript" src="stylesheets/bootstrap/js/moment.js"></script>


 

       <script type="text/javascript">
           //           setInterval(time, 1000);
           ////import * as a from "./Scripts/jquery.datetimepicker";
           //           function time() {
           //               debugger;
           //               var d = new Date();
           //               var h = d.getHours();
           //               var m = d.getMinutes();
           //               var s = d.getSeconds();
           //               if (h == 17 && m == 36 && s == 59)
           //               {
           //                   alert();
           //               }
           //           }
           var chkID = 0;

           $(document).ready(function () {

               LoadPage();

               $("#btn-Book").click(function () {
                   debugger;
                   window.open("Appointment.aspx?ID=" + chkID + "");
               });


           });

           function AttendanceChange(row) {
               debugger;
               // var status = $(row).val();

               var present_Status = $(row).val();
               if (present_Status == "0") {
                   return false;
               }

               var doctor_Id = $(row).closest('tr').find('td:eq(1)').text();

               // alert(Value);

               $.ajax({
                   type: "POST",
                   url: "Consultantsinformation.aspx/SaveDoctorStatus",
                   data:JSON.stringify({
                       "present_Status": present_Status,
                       "doctor_Id": doctor_Id
                   
                   }),
                   contentType : "application/json; charset=utf-8",
                   dataType : "json",
                   async : false,
                   success: function (data)
                   {
                       if (data.d == "success")
                       {
                           // alert("Record has been saved successfully");
                           alert("Status has been changed successfully");
                           location.reload();
                       }
                       debugger;
                   }, error: function () {
                   }
               });



           }


           function RemarksChanges(row)
           {
               debugger;
               var remarks = $(row).val();
               var doctor_id = $(row).closest('tr').find('td:Eq(1)').text();
               $.ajax({
                   type: "POST",
                   url: "Consultantsinformation.aspx/SaveRemarks",
                   data:JSON.stringify({
                       "remarks":remarks,
                       "doctor_id":doctor_id
                   
                   }),
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   async:false,
                   success: function (data)
                   {
                       if (data.d == "success")
                       {
                           alert("Remarks has been saved successfully");
                           location.reload();
                       }
                       debugger;
                   }, error: function () {
                   }
               });
           }


          

          

           function selectchk(ID) {
               debugger;

               onlyOne(ID);

               chkID = $(ID).closest('tr').find('td:eq(1)').text()

           }


           function onlyOne(checkbox) {
               var checkboxes = document.getElementsByName('alerted')
               checkboxes.forEach((item) => {
                   if (item !== checkbox) item.checked = false
               })
           }



           function LoadPage() {
               var checkBox_Display = "";
               var row_Color = "";
               var present_Selected = "selected";
               var absent_Selected = "";
               debugger;
               $.ajax({
                   type: "POST",
                   url: "Consultantsinformation.aspx/ViewList",
                   contentType: "application/json; charset=utf-8",
                   dataType: "json",
                   success: function (data) {
                       debugger;
                       // var table;
                       var Priority = '';
                       // table = $('#tblRes').table();
                       var length = $("#tblRes tr:gt(0)").length;
                       if (data != '')
                       {
                           var data = JSON.parse(data.d);
                           var rows = '';
                           $.each(data, function (i, item)
                           {
                               debugger;
                              
                               var Today = '<%= DateTime.Now.ToString("ddd", new System.Globalization.CultureInfo("en-US")) %>';

                               if (data[i].Off_Days_Names != null && data[i].Off_Days_Names.includes(Today) || 
                                   data[i].TodayStatus == "Absent" || data[i].TodayStatus == "absent"){
                                   // alert(Today);

                                   checkBox_Display = "disabled";
                                   row_Color = "#e04b4b";
                                   present_Selected = "";
                                   absent_Selected = "selected";
                                   // $('#ddl_DoctorStatus option[value=Absent]').attr('selected','selected');

                               }


                               // return false;

                               var time_in = '';
                               var time_out = '';
                               var CompleteTime = '';
                               if (data[i].Timings_In == null || data[i].Timings_In == "null")
                               {

                               }
                               else
                               {
                                   var time_in = moment(data[i].Timings_In).format('HH:mm A');
                               }
                               if (data[i].Timings_Out == null || data[i].Timings_Out=='null')
                               {
                               
                               }
                               else
                               {
                                   time_out = moment(data[i].Timings_In).format('HH:mm A');
                               }
                               if (time_in == '' && time_out == '') { CompleteTime = ''; }
                               else
                               {
                                   CompleteTime = time_in + ' , ' + time_out;
                               }
                               if (data[i].Govt_Hospital == "null" || data[i].Govt_Hospital == null) data[i].Govt_Hospital = '';
                               if (data[i].Off_Days_Names == "null" || data[i].Off_Days_Names == null) data[i].Off_Days_Names = '';
                               if (data[i].Designation == "null" || data[i].Designation == null) data[i].Designation = '';
                               if (data[i].Room_No == "null" || data[i].Room_No == null) data[i].Room_No = '';
                               if (data[i].Floor_No == "null" || data[i].Floor_No == null) data[i].Floor_No = '';
                               if (data[i].Extension_No == "null" || data[i].Extension_No == null) data[i].Extension_No = '';
                               if (data[i].Patient_Type == "null" || data[i].Patient_Type == null) data[i].Patient_Type = '';
                               if (data[i].Remarks == "null" || data[i].Remarks == null) data[i].Remarks = '';
                               rows += '<tr style="background-color :' + row_Color + '"><td><input type="checkbox" id="chk_box" name="alerted" onclick="selectchk(this)" ' + checkBox_Display + '/></td>' + '<td style="display:none;">' + data[i].Emp_ID + '</td> <td>' + (i + 1) + '</td> <td>' + data[i].Emp_Name + '</td>  <td>' + data[i].Designation + '</td> <td>' + data[i].Govt_Hospital + '</td> <td>' + data[i].Patient_Type + '</td> <td>' + data[i].Consultant_Charges + '</td> <td>' + CompleteTime + '</td> <td>' + data[i].Off_Days_Names + '</td> <td>' + data[i].Mobile + '</td> <td>' + data[i].Room_No + ' , ' + data[i].Floor_No + '</td>  <td>' + data[i].Extension_No + '</td><td style=" width: 14%;"><input style="width: 150px !important; margin-left: -4px !important;" type="text" id = "txt_box" name="RemarksChange" onchange="RemarksChanges(this)" value="' + data[i].Remarks + '" /></td><td style="width: 130px;"><select id="ddl_DoctorStatus" style="width: 79px !important;" onchange="AttendanceChange(this);"><option value="0">Please Select</option><option ' + present_Selected + ' value="Present">Present</option><option ' + absent_Selected + ' value="Absent">Absent</option></select></td></tr>';
                               

                               //if (data[i].TodayStatus == "Absent" || data[i].TodayStatus == "absent")
                               //{
                               //    $('#ddl_DoctorStatus option[value=Absent]').attr('selected','selected');    
                               //}


                               checkBox_Display = "";
                               row_Color = "";
                               present_Selected = "selected";
                               absent_Selected = "";

                           });

                           $('#tblRes').append(rows);
                       }
                       else {

                       }
                       //tblRes.draw();

                       debugger;
                   }
               });

           }

           //search in table column

           function myFunction() {
               var input, filter, table, tr, td, i, txtValue;
               input = document.getElementById("pickSearch");
               filter = input.value.toUpperCase();
               table = document.getElementById("tblRes");
               tr = table.getElementsByTagName("tr");
               for (i = 0; i < tr.length; i++) {
                   td = tr[i].getElementsByTagName("td")[3];
                   if (td) {
                       txtValue = td.textContent || td.innerText;
                       if (txtValue.toUpperCase().indexOf(filter) > -1) {
                           tr[i].style.display = "";
                       } else {
                           tr[i].style.display = "none";
                       }
                   }
               }
           }



       </script>






<style type="text/css">
    #ctl00_lblMessage {
        display: none;
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
            font-size: 12px;
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

    #tblRes th {
        position: sticky;
        top: 0px;
    }

    #test_id {
        width: 60px !important;
        text-align: center;
        font-weight: bold;
    }

    .ErrorAlert {
        border: 1px solid red !important;
    }


    #txt_box {
        width: 95px !important;
        height: 43px !important;
        margin-left: -9px !important;
        margin-bottom: -5px !important;
        margin-top: -4px !important;
    }
</style>

</asp:Content>


<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
  

    
    
    <%--<div style="overflow:scroll; height:auto;">--%>
    
    <div class ="Container">
    <div class ="row"> 
   <div class ="col-md-4">
    <p style="padding-right:940px;padding-bottom:-600px"></p><input type="text" id="pickSearch" placeholder="DR NAME" onkeyup="myFunction()" /></div>
       <div class ="col-md-4">
                
            &nbsp;&nbsp;<input type="button" id="btn-Book" value="Book An Appointment" onclick="bookapt()"; style="margin-left: 0px;width :200px ; margin-top: 12px;"/>&nbsp;&nbsp;
        </div>
        </div>
        <div class ="row">
            
    </div>
    
        <div id="tab">
        <table class="table table-hover table-striped table-bordered" id="tblRes" style="overflow:scroll; height:auto;">
          
               <tr id="SampleRowHeader">
                 
                   <th></th>
                   <th style="display:none"></th>
                   <th style="width: 53px;">Sr No.</th>
                   <th>CONSULTANT NAME</th>
                   <th>DESIGNATION</th>
                   <th>GOVT. HOSPITAL</th>
                   <th>PANEL / PVT</th>
                   <th>FEE</th>
                   <th>TIMING</th>
                   <th>OFF DAYS</th>
                   <th>PHONE NUMBER</th>
                   <th>ROOM NO / FLOOR</th>
                   <th>EXTENSION</th>
                   <th>REMARKS</th>
                   <th>Status</th>
               </tr>

            <tbody id="tbdy">
             
            </tbody>
            
            </table>
        </div>

</div>
</asp:Content>

