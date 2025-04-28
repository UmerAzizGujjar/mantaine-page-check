<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Doctor_Apointment.aspx.cs" Inherits="PMS.Doctor_Apointment" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    
     <script type="text/javascript">
            function Save() {

           

             var department = $('#selDepartment').val();
             var Date = document.getElementById('ctl00_MainContent_txtAppointmentDate').value;
             var DocName = $('#txtDoctor').val();
             var PatientName = $('#txtPatientName').val();

             var age = $('#txtAge').val();


             var sex = $('#selSex').val();
             
             var contect = $('#txtContectNo').val();
             PageMethods.AddHeader(department, Date, DocName, PatientName, age, sex, contect, On_SaveHeader, OnFail);
            }
            function On_SaveHeader(iret, ctx) {

                status = ctx;
                var MustrollNo = iret;

                if (MustrollNo == -1) {
                    alert("Error saving requisiton request! Please try again");
                    return;
                }

                var tbody = document.getElementById('riBody');

                for (var i = 0; i < tbody.rows.length; i++) {
                    var rid = tbody.rows[i].id;

                    var labourID = parseInt($('#' + rid + 'LabourID').val());


                    var rateperday = $('#' + rid + 'txtRatePerDay').val();

                    var normalday = $('#' + rid + 'txtNormalDays').val();
                    var overtimeday = $('#' + rid + 'txtOverTimeDays').val();
                    var totaldays = $('#' + rid + 'txtTotalWorkDays').val();
                    var Amount = removeCommas($('#' + rid + 'txtAmountOfWages').val());
                    var remarks = $('#' + rid + 'txtRemarks').val();
                    var totalamount = $(".tdcls").text();
                    if (normalday != "" && overtimeday != "") {

                        PageMethods.AddRow(iret, labourID, rateperday, normalday, overtimeday, totaldays, Amount, remarks, periodto, status, function (rret) { }, OnFail);
                    }
                }
                if (ctx == '0') {
                    alert("Mustroll No is Save:" + MustrollNo + "\nTotal Amount: " + footerAmount.innerHTML);
                    var newloc = "LabourMustroll.aspx?view&rr=" + MustrollNo;
                    document.location = newloc;
                }
                else {
                    alert("Mustroll No is Submitted:" + MustrollNo + "\nTotal Amount: " + footerAmount.innerHTML);
                    var newloc = "LabourMustroll.aspx?view&rr=" + MustrollNo;
                    document.location = newloc;
                }
            }
      </script>
    <style type="text/css">
        .auto-style1 {
            width: 80px;
            padding-bottom: 8px;
        }

        .auto-style3 {
            padding-bottom: 8px;
        }

        .auto-style2 {
            padding-bottom: 8px;
        }

            .auto-style2 input {
                width: 177px;
            }

        .purchaseOrder {
            text-align: center;
            padding-right: 30px;
        }

            .purchaseOrder .auto-style2 {
                width: 177px;
                padding-right: 24px;
            }

        .auto-style4 {
            width: 181px;
        }

        .purchaseOrderSubmitForm input {
            text-align: right;
        }

        table.tabclss tr td {
            padding: 5px;
        }

        .table th {
            border: 1px solid #FFF;
            background-color: #438eb9;
            color: #FFF;
            padding: 1em;
        }

        .table thead th {
            display: table-cell;
            text-align: center;
        }
        .table tbody tr td {
            border:none !important;
        }
        .table tr td input {
            height:25px !important;
            width:100% !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
     <table>
           
            <tr>
                <td style="width: 100px;"><span class="formLabel">Appointment No.</span></td>
                 <td>
                    <input id="txtAppointmentNo" type="text" style="width: 100px;" disabled="disabled"  /></td>
                <td></td>
                <td style="width: 100px;"><span class="formLabel">Appointment Date</span></td>
                <td>
                        <asp:TextBox ID="txtAppointmentDate" runat="server" disabled="disabled" Width="115px"></asp:TextBox></td>
               
             
               
            </tr>
            <tr >
                <td style="width: 130px;"><span class="formLabel">Department</span></td>
                
                <td>
                   <select id="selDepartment" style="width: 130px;">
                        <%=LookupResultsToOption(GetWareHouse("Patient Main Category"))%>
                    </select>
                </td>
                     <td></td>
                   <td style="width: 120px;"><span class="formLabel">Doctor Name</span></td>
                <td>
                     <input id="txtDoctor" type="text" style="width: 100px;"  value="" /></td>
                
               
            </tr>
            <tr>
                 <td style="width: 130px;"><span class="formLabel">Patient Name</span></td>
                 <td>
                   <input id="txtPatientName" type="text" style="width: 100px;"  value="" /></td>
                    <td></td>
                <td><span class="formLabel">Age</span></td>
                 <td>
                     <input id="txtAge" type="text" style="width: 100px;"  value="" /></td>
              
             
            </tr>
            <tr>
                 <td><span class="formLabel">Sex</span></td>
                
             
                <td>
                    <select id="Select1" style="width: 130px;">
                       <option value="M">Male</option>
                         <option value="F">Female</option>
                    </select></td>
                    <td></td>
                <td><span class="formLabel">Contect No.</span></td>
                <td>
                    <input id="txtContectNo" type="text" style="width: 233px;" value="" /></td>
               
               
            </tr>
        

            
           
         
        </table>
     <div style="padding-left: 70px; padding-top: 20px;">
                    <table>

                        <tr>
                            <td>
                                <asp:Button Text="Back" Width="95px" runat="server" ID="btnBack" CausesValidation="false" PostBackUrl="~/InPatientView.aspx" />
                                &nbsp;&nbsp;
                                  <input id="btnsave" type="button" value="Save" onclick="Save()" />
                                &nbsp;&nbsp;
                                <asp:Button ID="btnNew" Width="95px" runat="server" Text="New" CausesValidation="false" />
                                &nbsp;&nbsp;
                                <input type="button" width="95px" value="Print" onclick="Print()" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:ValidationSummary ID="ValidationSummary1" runat="server" ForeColor="Red" HeaderText="Page Errors" ShowSummary="true" DisplayMode="List" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblMessage" runat="server"></asp:Label>
                            </td>
                        </tr>
                    </table>
                </div>
</asp:Content>
