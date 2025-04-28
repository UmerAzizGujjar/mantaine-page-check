<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="UserDoctorControlList.aspx.cs" Inherits="PMS.Account.UserDoctorControlList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        <script type="text/javascript">
         $(document).ready(function () {
             LoadPage();
         });
         function LoadPage() {
             debugger;
             $.ajax({
                 type: "POST",
                 url: "UserDoctorControlList.aspx/LoadMaster",
                 data: '',
                 contentType: "application/json; charset=utf-8",
                 dataType: "json",
                 success: function (response) {
                     debugger;
                     var parsedData = JSON.parse(response.d);
                     var row = '';
                     var Priority = '';
                     var selectedOptions = parsedData;
                     $.each(parsedData, function (key, index) {
                         debugger;
                         var tDate = new Date(parseInt(parsedData[key].Created_Time.substr(6)));
                         tDate = moment(tDate).format('L');
                         row += '<tr><td>' + (key + 1) + '</td><td style="display:none">' + parsedData[key].User_Branch_Master_Id + '</td><td>' + parsedData[key].user_name + '</td><td>' + tDate + '</td><td><a href="#" onclick="Edit(' + parsedData[key].User_Branch_Master_Id + ')" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;">View</a></td></tr>';
                     });
                     $("#tblResult").append(row);
                 },
                 failure: function (response) { }
             });
         }
         function OnFail(exc) {
             alert(exc.get_message());
         }
         function Edit(ID) {
             window.location.href = "UserDoctorControl.aspx?ID=" + ID;

         }
         function deleteConfirm(User_Branch_Master_Id) {
             debugger;
             var ID = User_Branch_Master_Id;
             if (confirm('Are you sure want to delete this record')) {
                 PageMethods.DeleteRecord(ID, function (msg) {
                     debugger
                     window.location.href = 'UserControlList.aspx';
                 }, OnFail);
             }
         }

        </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
      <div id="PurchaseRequistiondetails" style="margin-top: 15px;">
          <fieldset>
            <a class="btn red btn-outline sbold" style="text-align: center" href="UserDoctorControl.aspx">Add New</a>
              </fieldset>
         <div>
        <table class="table table-hover table-striped table-bordered" id="tblResult">
            <thead id="ihead">
                <tr>                    
                    <th>Sr #</th>
                    <th>Username</th>                     
                     <th>Date</th>                                              
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody id="ibody">
            </tbody>
        </table>
        </div>
         </div>
</asp:Content>
