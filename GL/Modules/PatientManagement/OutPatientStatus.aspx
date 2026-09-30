<%@ Page Title="Out Patient Status" Language="C#"  MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="OutPatientStatus.aspx.cs" Inherits="PMS.OutPatientStatus" %>



<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script src="Scripts/bootstrap.min.js"  type="text/css"></script>

     <script type="text/javascript">
         $(document).ready(function () {
             $('#ctl00_MainContent_txtsDate').datepicker({ dateFormat: 'dd M yy' });
             $('#ctl00_MainContent_txteDate').datepicker({ dateFormat: 'dd M yy' });
             $('#btnPreview').click(function () {
                 var error = 0;
                 if ($('#ctl00_MainContent_txtsDate').val() == '' && error == 0) {
                     alert('Please Select Start Date');
                     error = 1;
                 }
                 else if ($('#ctl00_MainContent_txteDate').val() == '' && error == 0) {
                     alert('Please Select End Date');
                     error = 1;
                 }
                 else if ($('#chkSummary')[0].checked)
                 {
                     window.location.href = 'ReportViewer.aspx?ReportName=OPDStatusSummary&ReportTitle=Out Patient Status Summary from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val();
                 }
                 else {
                     window.location.href = 'ReportViewer.aspx?ReportName=OPDStatus&ReportTitle=Out Patient Status from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Status=' + $('#ctl00_MainContent_ddlStatus').val() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val();
                 }   
             });
             $('#btnReset').click(function () {

                 $('#Elements').find('input:text').each(function () {
                     $('select option:nth-child(1)').attr('selected', 'selected')
                     $(':text, textarea').val('');
                     $(':checkbox,:radio').attr('checked', '');
                 });
             });
         });
        </script>
      <style type="text/css">
        .gap {
            width: 100px;
        }
        .Data {
            text-align: left;
            width: 200px;
            padding: 2px;
            font-size: 16px;
        }
    </style>

   </asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">  
     <h3>
        <asp:Label ID="lblHeading" runat="server"></asp:Label>
    </h3>
   <div style="margin-top: 50px;" id="Elements">
        <table>
            <tr>
                <td class="Data">Department </td>
                <td>
                    <asp:DropDownList runat="server" ID="ddlDepartments" AppendDataBoundItems="true"></asp:DropDownList>
                </td>
                <td class="gap"></td>
                <td class="Data">Status </td>
                <td>
                    <asp:DropDownList runat="server" ID="ddlStatus" AppendDataBoundItems="true">
                     <asp:ListItem Text="All Status" Value="0"></asp:ListItem>
                     <asp:ListItem Text="Checked" Value="1"></asp:ListItem>
                     <asp:ListItem Text="Un Checked" Value="2"></asp:ListItem>
                    </asp:DropDownList>
                </td>
            </tr>
            <tr>
                <td class="Data">Start Date </td>
                <td>
                    <asp:TextBox runat="server" ID="txtsDate"></asp:TextBox>
                </td>
                <td class="gap"></td>
                <td class="Data">End Date </td>
                <td>
                    <asp:TextBox runat="server" ID="txteDate"></asp:TextBox>
                </td>
            </tr>
             <tr>
                <td class="Data">Summary </td>
                <td>
                    <input type="checkbox" value="Summary" id="chkSummary" />
                </td>                
            </tr>
        </table>
        <br />
       <div class="row">
           <div class="col-lg-1 col-md-1 col-sm-1">
               <input type="button" value="Preview" class="btn-primry" id="btnPreview" />
           </div>
           <div class="col-lg-1 col-md-1 col-sm-1">
               <input type="button" value="Reset" class="btn-primry" id="btnReset" />
           </div>
       </div>
   </div>
     </asp:Content>