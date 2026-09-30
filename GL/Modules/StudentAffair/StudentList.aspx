<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="StudentList.aspx.cs" Inherits="PMS.Modules.StudentAffair.StudentList" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
            <link href="css/stock.css" rel="stylesheet" />

           <link href="../js/select2.min.css" rel="stylesheet" />
<script src="../js/select2.min.js"></script>
<link href="js/select2.min.css" rel="stylesheet" />
<script src="Scripts/jquery.tokeninput.js"></script>

<script type="text/javascript">
    $(document).ready(function () {
        LoadPage();
    })

    function LoadPage() {
        $.ajax({
            type: "POST",
            url: "StudentList.aspx/Student_Master",
            data: '',
            contentType: "application/json; charset=utf-8",
            dataType: "json",
            success: function (response) {
                var parsedData = JSON.parse(response.d);
                var row = '';
                var Priority = '';
                var selectedOptions = parsedData;
                $.each(parsedData, function (key, index) {
                    //
                //    var InvocieDate = new Date(parseInt(parsedData[key].InvoiceDate.substr(6)));
                    //  InvocieDate = moment(InvocieDate).format('L');

                    var StDate = '';

                    if (parsedData[key].Date != null)

                    {

                        StDate = new Date(parseInt(parsedData[key].Date.substr(6)));
                        StDate = moment(StDate).format('L');

                    }



                    row += '<tr><td style="display:none">' + parsedData[key].Student_ID + '</td><td>' + parsedData[key].Student_Code + '</td><td>' + StDate + '</td><td>' + parsedData[key].Student_Name + '</td><td>' + parsedData[key].Roll_No + '</td><td>' + parsedData[key].Phone + '</td><td>' + parsedData[key].Address + '</td><td><a href="#" onclick="Edit(' + parsedData[key].Student_ID + ')" style="border-radius: 4px; background-color: #d4b7e7; color: black; padding: 4px 11px 4px 11px;">View</a></td></tr>';

   //                        <a style="border-radius: 4px;background-color: #e98383;color: white;padding: 4px 11px 4px 11px;" href="#" onclick="deleteConfirm(this)" id="btnDel' + (key + 1) + '">Delete</a>

                });
                $("#tblResult").append(row);
                //$.each(selectedOptions, function (key, value) {
                //    if (selectedOptions[key].Status == "Approved") {
                //        $('#btnDel' + (key + 1) + '').hide();
                //    }
                //});

            },
            failure: function (response) { }
        });

    }
    function OnFail(exc) {
        alert(exc.get_message());
    }

    function Edit(ID) {
        window.location.href = "Student.aspx?Stu_ID=" + ID;

    }

    function deleteConfirm(anchorTag) {
        var row = $(anchorTag).parents('tr')[0];


        var stuid = $($(row).find('td')[0]).text();


        if (confirm('Are you sure want to delete this record')) {
            PageMethods.DeleteRecord(stuid, function (msg) {
                $(row).remove();
            }, OnFail);
        }
    }

</script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div id="PurchaseRequistiondetails" style="margin-top: 15px;">
  <fieldset>
    <a class="btn red btn-outline sbold" style="text-align: center" href="Student.aspx">Add New</a>
      </fieldset>
 <div>
<table class="table table-hover table-striped table-bordered" id="tblResult">
    <thead id="ihead">
        <tr>                    
            <th>Student Code</th>
            <th>Date</th>
            <th>Student Name</th>
            <th>Student Roll No</th>                     
             <th>Contact</th>
             <th>Address</th>                               
            <th>Actions</th>
        </tr>

    </thead>

    <tbody id="ibody">
    </tbody>
</table>
</div>
 </div>
</asp:Content>
