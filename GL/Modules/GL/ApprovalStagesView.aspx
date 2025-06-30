<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovalStagesView.aspx.cs" Inherits="PMS.GL.ApprovalStagesView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
        
    
    <script type="text/javascript">
        $(document).ready(function () {
            LoadViewData();
            $('#btnNew').on('click', function () {
                window.location.href = "ApprovalStages.aspx";
            });
        });
        function Edit(id) {
            window.location.href = "ApprovalStages.aspx?ID=" + id;
        }
        function Delete(id) {
            $.ajax({
                type: "POST",
                url: "ApprovalStagesView.aspx/Delete",
                data: JSON.stringify({ "id": id }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d === "success") {
                        alert("Record has been deleted successfully");
                        window.location.href = "ApprovalStagesView.aspx";
                    }
                },
                error: function () { }
            });
        }
        function LoadViewData() {
            $.ajax({
                type: "POST",
                url: "ApprovalStagesView.aspx/LoadApprovalData",
                data: "",
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_data = JSON.parse(response.d);
                    var row = '';
                    $(parsed_data).each(function (key, index) {
                        var finalcheckbox = parsed_data[key].IsFinalApproval ? '<input type="checkbox" checked disabled>' : '<input type="checkbox" disabled>';
                        row +=
                            '<tr>' +
                            '<td>' + parsed_data[key].StageID + '</td>' +
                            '<td>' + parsed_data[key].StageName + '</td>' +
                            '<td>' + parsed_data[key].StageDescription + '</td>' +
                           
                            '<td>' + finalcheckbox + '</td>' +
                            '<td>' + parsed_data[key].CompanyName + '</td>' +
                        '<td class="actions"><a href="javascript:void(0)" style="border-radius: 4px; margin-right: 4px; background-color: #EFA63E !important; color: white; padding: 5px 8px;" onclick="Edit(' + parsed_data[key].StageID + ')"><i style="color:white !important;" class="fa fa-pencil"></a><a href="javascript:void(0)" style="border-radius: 4px; margin-right: 4px; background-color: #ad170c !important; color: white; padding: 5px 8px;" onclick="Delete(' + parsed_data[key].StageID + ')"><i style="color:white !important;" class="fa fa-trash"></i></a></td>' +
                            '</tr>';
                    });
                    $('#tblApprovalStagesView tbody').append(row);
                },
                error: function () { }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">   
    <div class="col-lg-2 col-md-4 col-sm-6">
           <input type="button" id="btnNew" value="New" />
    </div>
    
    <div>
        <table id="tblApprovalStagesView" class="table table-bordered">
            <thead>
                <tr>
                    <th>No #</th>
                    <th>Stage Name</th>
                    <th>Stage Description</th>
                  
                    <th>Final Approval</th>
                    <th>Company</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
            </tbody>
        </table>
    </div>
</asp:Content>