<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="TokenListIITH.aspx.cs" Inherits="PMS.Modules.Administrator.TokenListIITH" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
  <script type="text/javascript">
      $(document).ready(function () {
          LoadDoctorName();
          GetLatestDoctorToken();
      });

      function LoadDoctorName() {
          $.ajax({
              url: 'TokenListIITH.aspx/GetCurrentDoctorName',
              type: 'POST',
              contentType: 'application/json; charset=utf-8',
              dataType: 'json',
              success: function (response) {
                  var data = response.d ? JSON.parse(response.d) : response;
                  $('#lblDoctorName').text(data.doctorName);
                  $('#pageHeader').text(data.doctorName + "'s Patient Queue");
              },
              error: function (xhr, status, error) {
                  console.error('Error loading doctor name:', error);
                  $('#lblDoctorName').text('Doctor');
              }
          });
      }

      function GetLatestDoctorToken() {
          $.ajax({
              url: 'TokenListIITH.aspx/LoadDoctorTokenPatients',
              type: 'POST',
              contentType: 'application/json; charset=utf-8',
              dataType: 'json',
              success: function (_data) {
                  try {
                      var data = _data.d ? JSON.parse(_data.d) : _data;
                      if (data.error) {
                          console.error('Server error:', data.error);
                          $('#ibody').html('<tr><td colspan="3" class="text-center text-danger">Error loading patients</td></tr>');
                          return;
                      }

                      var tableBody = $('#ibody');
                      tableBody.empty();

                      if (data.length === 0) {
                          tableBody.html('<tr><td colspan="3" class="text-center text-muted">No patients in queue</td></tr>');
                          $('#patientCount').text('0');
                          return;
                      }

                      $('#patientCount').text(data.length);

                      $.each(data, function (key, value) {
                          var rowColor = getRowColor(value.filter_clinic);

                          var row = '<tr style="' + rowColor + '">' +
                              '<td style="font-size:22px;font-weight:bold;text-align:center;">' + escapeHtml(value.tokenNo) + '</td>' +
                              '<td style="font-size:22px;font-weight:bold;text-align:center;">' + escapeHtml(value.mr_no_sequence) + '</td>' +
                              '<td style="font-size:22px;font-weight:bold;">' + escapeHtml(value.Full_Name) + '</td>' +
                              '</tr>';
                          tableBody.append(row);
                      });
                  } catch (e) {
                      console.error('Error parsing data:', e);
                      $('#ibody').html('<tr><td colspan="3" class="text-center text-danger">Error displaying patients</td></tr>');
                  }
              },
              error: function (xhr, status, error) {
                  console.error('AJAX Error:', error);
                  $('#ibody').html('<tr><td colspan="3" class="text-center text-danger">Failed to load patients</td></tr>');
              }
          });
      }

      // Helper: Get row color based on clinic ID (matching your original gradient scheme)
      function getRowColor(clinicId) {
          switch (clinicId) {
              case "001": return 'background: linear-gradient(to Right, #f5c5f6, #e4c1fa);';
              case "002": return 'background: linear-gradient(to Right, #ff9190, #fdc094);';
              case "003": return 'background: linear-gradient(to Right, #7BE495, #CFF4D2);';
              default: return '';
          }
      }

      function escapeHtml(text) {
          if (!text) return '';
          var map = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#039;' };
          return text.toString().replace(/[&<>"']/g, function (m) { return map[m]; });
      }

      
      setInterval(function () {
          location.reload(); 
      }, 10000);
  </script>

    <style type="text/css">
        .table-header th {
            font-size: 23px;
            font-weight: bold;
        }
        .table > thead > tr {
            background: linear-gradient(to Right, #c046aa, #2c3e50) !important;
            color: white;
        }
        .doctor-badge {
            background: linear-gradient(to Right, #667eea, #764ba2);
            color: white;
            padding: 8px 20px;
            border-radius: 25px;
            font-weight: bold;
            display: inline-block;
            margin-bottom: 15px;
        }
        .patient-count {
            font-size: 18px;
            color: #666;
            margin-left: 10px;
        }
        #tbloutPatients {
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .refresh-indicator {
            font-size: 12px;
            color: #999;
            margin-top: 5px;
        }
        .page-header {
            display:none;
        }
        #ctl00_sidebar, .page-header {
    display: none !important
}
        #navbar{
            display:none !important;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid">
        <!-- Header Section -->
        <%--<div class="row mb-3">
            <div class="col-12">
                <div class="d-flex align-items-center justify-content-between">
                    <h3 id="pageHeader" class="mb-0">Doctor's Patient Queue</h3>
                    <div>
                        <span class="doctor-badge">
                            <i class="fa fa-user-md"></i> <span id="lblDoctorName">Loading...</span>
                        </span>
                        <span class="patient-count">Patients: <strong id="patientCount">0</strong></span>
                    </div>
                </div>
                <div class="refresh-indicator">
                    <i class="fa fa-refresh"></i> Auto-refreshing every 10 seconds
                </div>
            </div>
        </div>--%>

        <!-- Patient Table -->
        <div class="row">
            <div class="col-12">
                <div class="table-responsive">
                    <table class="table table-hover table-striped table-bordered" id="tbloutPatients">
                        <thead id="ihead">
                            <tr>
                                <th style="width: 25%; font-size:22px;font-weight:bold;text-align:center;">Token No</th>
                                <th style="width: 25%; font-size:22px;font-weight:bold;text-align:center;">MR No</th>
                                <th style="font-size:22px;font-weight:bold;">Patient Name</th>
                            </tr>
                        </thead>
                        <tbody id="ibody">
                            <tr>
                                <td colspan="3" class="text-center text-muted">Loading patients...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>


    </div>

</asp:Content>
