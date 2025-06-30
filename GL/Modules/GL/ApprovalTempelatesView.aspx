<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovalTempelatesView.aspx.cs" Inherits="PMS.GL.ApprovalTempelatesView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


<script type="text/javascript">
    $(document).ready(function () {
        LoadViewData();
        $('#btnNew').on('click', function () {
            window.location.href = "ApprovalTempelates.aspx";
        });
    });
    function Edit(id) {
        window.location.href = "ApprovalTempelates.aspx?ID=" + id;
    }
    function Delete(id) {
        $.ajax({
            type: "POST",
            url: "ApprovalTempelatesView.aspx/Delete",
            data: JSON.stringify({ "id": id }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === "success") {
                    alert("Record has been deleted successfully");
                    window.location.href = "ApprovalTempelatesView.aspx";
                }
            },
            error: function () { }
        });
    }
    function LoadViewData() {
        $.ajax({
            type: "POST",
            url: "ApprovalTempelatesView.aspx/LoadApprovalData",
            data: "",
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var parsed_data = JSON.parse(response.d);
                var row = '';
                $(parsed_data).each(function (key, index) {
                    row +=
                        '<tr>' +
                    '<td>' + parsed_data[key].TempelateID + '</td>' +
                    '<td>' + parsed_data[key].TempelateName + '</td>' +
                    '<td>' + parsed_data[key].TempelateDescription + '</td>' +
                        '<td>' + parsed_data[key].CompanyName + '</td>' +
                    '<td class="actions"><a href="javascript:void(0)" style="border-radius: 4px; margin-right: 4px; background-color: #EFA63E !important; color: white; padding: 5px 8px;" onclick="Edit(' + parsed_data[key].TempelateID + ')"><i style="color:white !important;" class="fa fa-pencil"></i></a><a href="javascript:void(0)" style="border-radius: 4px; margin-right: 4px; background-color: #ad170c !important; color: white; padding: 5px 8px;" onclick="Delete(' + parsed_data[key].TempelateID + ')"><i style="color:white !important;" class="fa fa-trash"></i></a></td>' +
                        '</tr>';
                });
                $('#tblApprovalTempelateView tbody').append(row);
            },
            error: function () { }
        });
    }
</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="row">
         <div class="col-lg-1 col-md-4 col-sm-6">
              <input type="button" class="btn btn-primry" id="btnNew" value="New" />
         </div>
     </div>
  <br />
  <div>
      <table id="tblApprovalTempelateView" class="table table-bordered">
          <thead>
              <tr>
                  <th>No #</th>
                  <th>Tempelate Name</th>
                  <th>Tempelate Description</th>
                  <th>Company</th>
                  <th>Action</th>
              </tr>
          </thead>
          <tbody>
          </tbody>
      </table>
  </div>
</asp:Content>
