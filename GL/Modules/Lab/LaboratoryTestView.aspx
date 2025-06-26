<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="LaboratoryTestView.aspx.cs" Inherits="PMS.LaboratoryTestView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Tibbit_theme/css/tablestyle.css" rel="stylesheet" />
<script type="text/javascript">
    $(document).ready(function () {
        $('#ctl00_lblMessage').hide();
        LoadPage();


    });
       
    
    function LoadPage() {
        $("#tblResult").DataTable({
            "processing": true,
            "serverSide": true,
            "dom": 'lBfrtip',
            "lengthChange": true,
            "buttons": ['copy', 'excel', 'pdf'],
            "filter": true,
            "ajax": function (data, callback, settings) {
                $.ajax({
                    type: "POST",
                    url: "LaboratoryTestView.aspx/ViewList",
                    data: JSON.stringify({
                        draw: data.draw,
                        start: data.start,
                        length: data.length,
                        sortColumn: data.columns[data.order[0].column].name,
                        sortColumnDirection: data.order[0].dir,
                        searchValue: data.search.value
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        callback({
                            draw: response.d.draw,
                            recordsTotal: response.d.recordsTotal,
                            recordsFiltered: response.d.recordsFiltered,
                            data: response.d.data
                        });
                    },
                    error: function (xhr, status, error) {
                        console.log(xhr.responseText);
                    }
                });
            },
            "columns": [
                { "data": "Lab_Test_ID", visible: false, "width": "0%" },
                { "data": "Lab_Test_ID", "name": "Lab_Test_ID", "width": "10%", "orderable": true },
                { "data": "mr_no_sequence", "name": "mr_no_sequence", "width": "10%", "orderable": true },
                { "data": "Full_Name", "width": "20%", "orderable": false },              
                {
                    "data": "Created_Time", "name": "Created_Time",
                    "render": function (data, type, full) {
                        debugger;
                        var date = full.Created_Time;
                        date = moment(date).format('DD-MMM-YYYY');
                        return date;
                    }, "width": "10%","orderable": false
                },
                
                {
                    render: function (data, type, full) {
                        debugger;
                        var res = '<a class="editListBtn" href="#" onclick="editOpen(' + full.Lab_Test_ID + ')" style="border-radius: 4px;color: white; padding: 5px 8px 5px 8px;"><i style="color:white !important;" class="fa fa-pencil" ></i></a>'
                       

                        var result;
                        result = res;
                        return result;
                    }, "width": "10%", "orderable": false
                }
            ],
            "initComplete": function (settings, json) {
                var lengthContainer = document.querySelector('#tblResult_length');
                var lengthDropdown = document.querySelector('#tblResult_length select');
                var label = document.querySelector('#tblResult_length label');

                if (lengthDropdown && label && lengthContainer) {
                    var labelText = document.createElement('span');
                    labelText.textContent = 'Show entries ';
                    labelText.style.marginTop = '10px';
                    labelText.style.display = 'inline-block';

                    lengthDropdown.style.width = '60px';
                    label.innerHTML = '';
                    label.style.display = 'inline-flex';
                    label.style.marginTop = '17px';
                    label.appendChild(labelText);
                    label.appendChild(lengthDropdown);
                } else {
                    console.log("Length dropdown, label, or container not found");
                }
            }
        });
    }

    function editOpen(Lab_Test_ID, Lab_Test_Detail_ID) {
        window.open("LaboratoryTest.aspx?ID=" + Lab_Test_ID );
    }

    function deleteConfirm(anchorTag) {    
        var row = $(anchorTag).parents('tr')[0];
        var labID = $($(row).find('td')[0]).text();
        if (confirm('Are you sure want to delete this record')) {
            PageMethods.DeleteRecord(labID, function (msg) {
                FillList();
            }, OnFail);
        }
    }  
    function gotolab() {
        window.location.href = "LaboratoryTest.aspx";
    }
</script>     
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div id="OutPatdetails" > 
         <div class="row">
              <div class="col-lg-2 col-md-3 col-sm-4" style="margin-bottom: 1%;">
             <input type="button" class="btn btn-primry" name="name"  value="Add New" onclick="gotolab();" />
                  </div>        
                </div>
           <div class="row">
        <div class="table-container">
        <table class="table table-hover table-striped table-bordered" id="tblResult" style="overflow:scroll; height:auto;">
            <thead id="ihead">
                <tr>                    
                    <th>Lab_Test_ID</th> 
                    <th>Lab_Test_ID</th> 
                     <th>MR No</th>   
                     <th>Patient Name</th>   
                    <th>Date</th> 
                    <th>Actions</th>
                    </tr>
                   </thead>
            <tbody id="ibody">
            </tbody>
        </table>
        </div>
        </div>
        </div>
</asp:Content>
