<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="BloodBankView.aspx.cs" Inherits="PMS.BloodBankView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
   <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">

        $(document).ready(function () {
            debugger;
            $('#ctl00_lblMessage').hide();
            LoadPage();


        });


        function LoadPage() {
            $("#tblBankList").DataTable({
                "processing": true,
                "serverSide": true,
                "dom": 'lBfrtip',
                "lengthChange": true,
                "buttons": ['copy', 'excel', 'pdf'],
                "filter": true,
                "ajax": function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "BloodBankView.aspx/ViewList",
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
                    { "data": "Blood_ID", "visible": false, "width": "0%", "orderable": false },
                    { "data": "Blood_Group", "name": "Blood_Group", "width": "5%", "orderable": false },
                    { "data": "RH_Type", "name": "RH_Type", "width": "5%", "orderable": false },
                    { "data": "Empty_Bag_Status", "name": "Empty_Bag_Status", "width": "8%", "orderable": false },
                    { "data": "Bag_No", "name": "Bag_No", "width": "5%", "orderable": false },
                    { "data": "Patient_Name", "name": "Patient_Name", "width": "11%", "orderable": false },
                    { "data": "Mrno", "name": "Mrno", "width": "8%", "orderable": true },
                    { "data": "No_Of_Bags", "name": "No_Of_Bags", "width": "5%", "orderable": false },
                    {
                        "data": "Receiving_Date", "name": "Receiving_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Receiving_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "8%", "orderable": true
                    },
                    {
                        "data": "Blood_Issuance_Date_Time", "name": "Blood_Issuance_Date_Time",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Blood_Issuance_Date_Time;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "10%", "orderable": false
                    },
                    {
                        "data": "Expiry_Date", "name": "Expiry_Date",
                        "render": function (data, type, full) {
                            debugger;
                            var date = full.Expiry_Date;
                            date = moment(date).format('DD-MMM-YYYY');
                            return date;
                        }, "width": "8%", "orderable": false
                    },
                    {
                        render: function (data, type, full) {
                            debugger;
                            var res = '<a class="editListBtn" href="#" onclick="Edit(' + full.Blood_ID + ')" style="border-radius: 4px;padding: 5px 8px 5px 8px;"><i class="fa fa-pencil"></i></a>'


                            var result;
                            result = res;
                            return result;
                        }, "width": "5%", "orderable": false
                    }
                ],
                "initComplete": function (settings, json) {
                    var lengthContainer = document.querySelector('#tblBankList_length');
                    var lengthDropdown = document.querySelector('#tblBankList_length select');
                    var label = document.querySelector('#tblBankList_length label');

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


        function Edit(ID) {
            window.location.href = "BloodBank.aspx?ID=" + ID;
        }

    </script>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

     <div class="row table-container">
     <table class="table table-bordered" id="tblBankList">
         <thead>
             <tr>
                 <th style="display:none;">Blood ID</th>
                 <th>Blood Group</th>
                 <th>RH Type</th>
                 <th>Bag Status</th>
                 <th>Bag No</th>
                 <th>Patient Name</th>
                 <th>MR No.</th>
                 <th>No Of Bags</th>
                 <th>Receiving Date</th>
                 <th>Blood Issuance_Date_Time</th>
                 <th>Expiry Date</th>
                 <th>Actions</th>
             </tr>
         </thead>
         <tbody>
         </tbody>
     </table>
 </div>


    <%--<table style="width: 100%;">
        <tr>
            <td>
                
            </td>
        </tr>

        <tr>
            <td colspan="2">
                <asp:UpdatePanel runat="server" ID="upList" UpdateMode="Conditional">
                    <ContentTemplate>
                        <ig:webhierarchicaldatagrid id="whdgList" autogeneratecolumns="false" runat="server" height="100%"
                            width="100%" datasourceid="whdsList" datakeyfields="Blood_ID" onitemcommand="whdgList_ItemCommand" onrowislandspopulating="whdgList_RowIslandsPopulating">
                            <GroupingSettings EnableColumnGrouping="True">
                            </GroupingSettings>
                            <Behaviors>
                                <ig:ColumnMoving Enabled="true"></ig:ColumnMoving>
                                <ig:Filtering Enabled="true"></ig:Filtering>
                                
                                <ig:Sorting Enabled="true" SortingMode="Single"></ig:Sorting>
                            </Behaviors>
                            <Columns>
                                <ig:TemplateDataField  Key="Edit" Width="80px">
                                    <ItemTemplate>
                                        <asp:HyperLink ToolTip="Edit" ID="LinkButton3" runat="server" NavigateUrl='<%# Eval("Blood_ID","~/BloodBank.aspx?ID={0}") %>' Text="Edit" />
                                       <asp:LinkButton Text="Delete" ToolTip="Delete" ID="lbtnDelete" CommandName="Remove" CommandArgument='<%# Eval("Blood_ID") %>' runat="server"
                                            OnClientClick="javascript:return confirm('Are you sure, you want to delete this record?');" />


                            <asp:LinkButton Text="Bag Return" ToolTip="Cancel" ID="LinkButton1" CommandName="Cancel" CommandArgument='<%# Eval("Bag_No") +"-"+Eval("Blood_ID")+"-"+Eval("Component") %>' runat="server" />

                                    </ItemTemplate>
                                </ig:TemplateDataField>

                                <ig:BoundDataField Key="Blood_ID" DataFieldName="Blood_ID"  Header-Text="ID"></ig:BoundDataField>
                                  <ig:BoundDataField Key="Patient_No" DataFieldName="Patient_No"  Header-Text="Mr No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Patient_Name" DataFieldName="Patient_Name"   Header-Text="Patient Name"></ig:BoundDataField>
                                    <ig:BoundDataField Key="Bag_No" DataFieldName="Bag_No"   Header-Text="Bag No"></ig:BoundDataField>
                                <ig:BoundDataField Key="Blood_Group" DataFieldName="Blood_Group"  Header-Text="Blood Group"></ig:BoundDataField>
                                <ig:BoundDataField Key="RH Type" DataFieldName="RH Type"   Header-Text="RH Type"></ig:BoundDataField>

                                <ig:BoundDataField Key="No_Of_Bags" DataFieldName="No_Of_Bags"  Header-Text="Bags Qty"></ig:BoundDataField>
                                <ig:BoundDataField Key="Empty Bag Status" DataFieldName="Empty Bag Status"  Header-Text="Empty Bag Status" ></ig:BoundDataField>
                                <ig:BoundDataField Key="Blood Issuance Date & Time" DataFieldName="Blood Issuance Date & Time"    Header-Text="Blood Issuance Date & Time" DataFormatString="{0:MM/dd/yyyy hh:mm:ss tt}"></ig:BoundDataField>
                                <ig:BoundDataField Key="Receiving_Date" DataFieldName="Receiving_Date"   Header-Text="Receive Date"></ig:BoundDataField>
                                <ig:BoundDataField Key="Expiry_Date" DataFieldName="Expiry_Date"   Header-Text="Expiry Date"> </ig:BoundDataField>

                            </Columns>
                        </ig:webhierarchicaldatagrid>
                        <ig:webhierarchicaldatasource id="whdsList" runat="server">
                            <DataViews>
                                <ig:DataView DataSourceID="sqlList" DataMember="DefaultView" ID="dvList" />
                            </DataViews>
                        </ig:webhierarchicaldatasource>
                        <asp:SqlDataSource ID="sqlList" runat="server"></asp:SqlDataSource>
                    </ContentTemplate>
                </asp:UpdatePanel>

            </td>
        </tr>

    </table>--%>

</asp:Content>



