<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Inv_OriginatorTempelatesView.aspx.cs" Inherits="PMS.GL.Inv_OriginatorTempelatesView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
         
<style type="text/css">
   
</style>
<script type="text/javascript">
    $(document).ready(function () {
        LoadViewData();
        $('#btnNew').on('click', function () {
            window.location.href = "Inv_OriginatorTempelates.aspx";
        });
    });
    function Edit(id) {
        window.location.href = "Inv_OriginatorTempelates.aspx?ID=" + id;
    }
    function Delete(id) {
        $.ajax({
            type: "POST",
            url: "Inv_OriginatorTempelatesView.aspx/Delete",
            data: JSON.stringify({ "id": id }),
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                if (response.d === "success") {
                    alert("Record has been deleted successfully");
                    window.location.href = "Inv_OriginatorTempelatesView.aspx";
                }
            },
            error: function () { }
        });
    }
    function LoadViewData() {
        $.ajax({
            type: "POST",
            url: "Inv_OriginatorTempelatesView.aspx/LoadApprovalData",
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
                    '<td class="actions"><a href="javascript:void(0)" onclick="Edit(' + parsed_data[key].TempelateID + ')">Edit</a>|<a href="javascript:void(0)" onclick="Delete(' + parsed_data[key].TempelateID + ')">Delete</a></td>' +
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
 <input type="button" class="col-lg-2" id="btnNew" value="New" />
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
