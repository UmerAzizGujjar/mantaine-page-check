<%@ Page Title="In Patient Status" Language="C#"  MasterPageFile="~/Site.master" AutoEventWireup="true" CodeBehind="In_PatientsStatus.aspx.cs" Inherits="PMS.In_PatientsStatus" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script src="Scripts/bootstrap.min.js"  type="text/css"></script>
     <link href="wwwroot/js/select2.min.css" rel="stylesheet" />
    <script src="wwwroot/js/select2.min.js"></script>
    <link href="wwwroot/Styles/jquery.ptTimeSelect.css" rel="stylesheet" />
    <script src="wwwroot/Scripts/jquery.ptTimeSelect.js"></script>
     <script type="text/javascript">

         $(document).ready(function () {
            // $('#ctl00_MainContent_txtsDate').datepicker({ dateFormat: 'dd M yy' });
             //$('#ctl00_MainContent_txteDate').datepicker({ dateFormat: 'dd M yy' });
             $("#ctl00_MainContent_txtsDate").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
             $("#ctl00_MainContent_txteDate").datepicker({ dateFormat: "dd M yy" }).datepicker("setDate", new Date());
             $('#ctl00_MainContent_ddlDepartments').select2();
             $('#ctl00_MainContent_ddlStatus').select2();

             $('#<%= btnPreview.ClientID %>').click(function () {

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
                     var url = '../../ReportViewer.aspx?ReportName=IPDStatusSummary&ReportTitle=In Patient Status Summary from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val();
                     window.open(url, '_blanks');
                 }
                 else {
                     var url = '../../ReportViewer.aspx?ReportName=IPDStatus&ReportTitle=In Patient Status from ' + $('#ctl00_MainContent_txtsDate').val() + ' to ' + $('#ctl00_MainContent_txteDate').val() + '&DepartmentID=' + $('#ctl00_MainContent_ddlDepartments').val() + '&Status=' + $("#ctl00_MainContent_ddlStatus option:selected").text() + '&sDate=' + $('#ctl00_MainContent_txtsDate').val() + '&eDate=' + $('#ctl00_MainContent_txteDate').val();
                     window.open(url, '_blanks');
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
                     <asp:ListItem Text="All" Value="0"></asp:ListItem>
                     <asp:ListItem Text="Admission" Value="1"></asp:ListItem>
                     <asp:ListItem Text="Discharge" Value="3"></asp:ListItem>
                     <asp:ListItem Text="Recieved" Value="4"></asp:ListItem>
                     <asp:ListItem Text="Discharge and Recieved" Value="5"></asp:ListItem>
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
             <tr style="display:none">
                <td class="Data">Summary </td>
                <td>
                    <input type="checkbox" value="Summary" id="chkSummary" style="margin-left:-110px;" />
                </td>                
            </tr>
        </table>
        <br />
        <%--<div style="margin-left: 202px;">

            <input type="button" value="Preview" id="btnPreview" style="width: 90px;" />
            &nbsp;&nbsp;
                        <input type="button" value="Reset" id="btnReset" style="width: 90px;" />

        </div>--%>
       <div class="row">
                <div class="col-lg-1">
                    <asp:Button Text="Preview" CssClass="btn btn-primry" ID="btnPreview" runat="server" />
                </div>
                <div class="col-lg-1">
                    <asp:Button Text="Cancel" ID="btnReset" CssClass="btn btn-gray" runat="server" CausesValidation="false" />
                </div>
       </div>

    </div>






     </asp:Content>