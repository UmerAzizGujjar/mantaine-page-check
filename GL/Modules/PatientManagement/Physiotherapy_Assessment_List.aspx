<%@ Page Title="Physiotherapy Assessment List" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Physiotherapy_Assessment_List.aspx.cs" Inherits="PMS.Modules.PatientManagement.Physiotherapy_Assessment_List" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />
    <script type="text/javascript">
        $(document).ready(function () {
            $('#tblList').DataTable({
                processing: true,
                serverSide: true,
                dom: 'lBfrtip',
                lengthChange: true,
                buttons: [
                    {
                        text: 'Add',
                        className: 'dt-button buttons-copy buttons-html5',
                        action: function () { window.location = 'Physiotherapy_Assessment.aspx'; }
                    },
                    'copy',
                    'excel',
                    'pdf',
                    {
                        extend: 'colvis',
                        text: '<i class="fa fa-columns"></i> Columns',
                        className: 'dt-button buttons-colvis',
                        collectionLayout: 'fixed two-column',
                        postfixButtons: ['colvisRestore']
                    }
                ],
                ajax: function (data, callback, settings) {
                    $.ajax({
                        type: "POST",
                        url: "Physiotherapy_Assessment_List.aspx/GetAssessmentList",
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
                        error: function (xhr) { console.log(xhr.responseText); }
                    });
                },
                columns: [
                    { data: 'MR', name: 'MR', width: '10%' },
                    { data: 'PatientName', name: 'PatientName', width: '20%' },
                    {
                        data: 'AssessmentDate', name: 'AssessmentDate', width: '12%',
                        render: function (data, type, full) {
                            return full.AssessmentDate ? moment(full.AssessmentDate, 'DD/MM/YYYY').format('DD-MMM-YYYY') : '';
                        }
                    },
                    { data: 'Department', name: 'Department', width: '15%' },
                    {
                        data: null, width: '14%', orderable: false, searchable: false,
                        render: function (data, type, full) {
                            return '<a href="#" onclick="window.open(\'Physiotherapy_Assessment.aspx?ID=' + full.OutPatientId + '\',\'_blank\')" class="editListBtn" style="border-radius:4px;padding:5px 8px"><i class="fa fa-pencil"></i></a>' +
                                   '<a href="#" onclick="window.open(\'Physiotherapy_Assessment.aspx?ID=' + full.OutPatientId + '&print=1\',\'_blank\')" class="printListBtn" style="border-radius:4px;margin-left:4px;color:white;padding:5px 8px"><i class="fa fa-print"></i></a>';
                        }
                    }
                ]
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div id="POdetails" style="margin-top: 15px;">
        <div class="row">
            <div class="table-container col-lg-12 col-md-12 col-sm-10">
                <table class="table table-hover table-striped table-bordered" id="tblList" style="overflow: scroll; height: auto;">
                    <thead>
                        <tr>
                            <th>MR #</th>
                            <th>Patient Name</th>
                            <th>Date</th>
                            <th>Department</th>
                            <th style="width:14%">Actions</th>
                        </tr>
                    </thead>
                </table>
            </div>
        </div>
    </div>

</asp:Content>
