<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="EndoscopyList.aspx.cs" Inherits="PMS.EndoscopyList" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    <%--<script type="text/javascript" src="Scripts/jquery.tokeninput.js"></script>--%>

    <script type="text/javascript">
        $(document).ready(function () {
            GetEndoscopies();
        });
        
        function GetEndoscopies() {
            var rows = '';
            PageMethods.GetEndoscopies(function (endoscopies) {
                $.each(JSON.parse(endoscopies), function (key, value) {
                    var Performed = '';
                    var Reported = '';
                    if (value.Performed != null) {
                        Performed = moment.unix(parseInt(value.Performed.substr(6, 10))).format('MM/DD/YYYY');
                    }
                    if (value.Reported != null) {
                        Reported = moment.unix(parseInt(value.Reported.substr(6, 10))).format('MM/DD/YYYY');
                    }
                    rows += '<tr><td>' + value.Endoscopy_ID + '</td><td>' + value.Type + '</td><td>' + value.Patient_ID + '</td><td>' + Performed + '</td><td>' + Reported + '</td><td><a href="Endoscopy.aspx?id=' + value.Endoscopy_ID + '">Edit</a> | <a href="javascript:void(0)" onclick="DeleteEndoscopy(this)">Delete</a></td></tr>';
                });
                $('.table tbody').html(rows);
            });
        }

        function DeleteEndoscopy(row) {
            var id = $(row).closest('tr').children('td:first').text();
            PageMethods.DeleteEndoscopy(id, function () {
                $(row).parents('tr:first').remove();
            });
        }
    </script>
    
    <style type="text/css">
        fieldset {
            border: 1px groove #ddd !important;
            padding: 0 1.4em 1.4em 1.4em !important;
            margin: 0 0 1.5em 0 !important;
            -webkit-box-shadow: 0px 0px 0px 0px #000;
            box-shadow: 0px 0px 0px 0px #000;
        }

        legend {
            font-size: 1.2em !important;
            font-weight: bold !important;
            text-align: left !important;
            width: auto;
            padding: 0 10px;
            border-bottom: none;
            margin-bottom: 0px;
        }

        .table {
            margin: 1em 0;
            width: 100%;
            overflow: hidden;
            background: #FFF;
            color: #024457;
            border: 1px solid #167F92;
        }

            .table tr {
                border: 1px solid #D9E4E6;
            }

                .table tr:nth-child(even) {
                    background-color: #EAF3F3;
                }

            .table th {
                display: none;
                border: 1px solid #FFF;
                background-color: #438eb9;
                color: #FFF;
                padding: 1em;
            }

            .table thead th {
                display: table-cell;
                text-align: center;
            }

        @media (min-width: 480px) {
            .table th:nth-child(2) span {
                display: block;
            }

            .table th:nth-child(2):after {
                display: none;
            }
        }

        .table td {
            display: block;
            word-wrap: break-word;
            max-width: 7em;
        }

            .table td:first-child {
                display: table-cell;
                text-align: center;
                border-right: 1px solid #D9E4E6;
            }

        @media (min-width: 480px) {
            .table td {
                border: 1px solid #D9E4E6;
            }
        }

        .table th, .table td {
            text-align: center;
            margin: .5em 1em;
        }

        @media (min-width: 480px) {
            .table th, .table td {
                display: table-cell;
                padding: 1em;
            }
        }

        #test_id {
            width: 60px !important;
            text-align: center;
            font-weight: bold;
        }

        .ErrorAlert {
            border: 1px solid red !important;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="button" id="aadnew" value="Add New" onclick="location.href='Endoscopy.aspx';">
    <div id="PatientDetail" style="width: 100%">
        <ContentTemplate>
            <table class="table table-even-striped">
                <thead>
                    <th>Endoscopy ID</th>
                    <th>Type</th>
                    <th>Patient ID</th>
                    <th>Performed</th>
                    <th>Reported</th>
                    <th>Action</th>
                </thead>
                <tbody></tbody>
            </table>
        </ContentTemplate>
    </div>
</asp:Content>