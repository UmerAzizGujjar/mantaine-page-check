<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Inventory_ProcurementDashboard.aspx.cs" Inherits="PMS.Modules.Dashboards.Inventory_ProcurementDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     
         <script src="../../wwwroot/Tibbit_theme/Scripts/jquery.canvasjs.min.js"  type="text/javascript"></script>

    <link href="../../wwwroot/StandardTheme/css/CustomCss/swalalert.css" rel="stylesheet" />
    <script src="../../wwwroot/Tibbit_theme/js/apexchart.js" type="text/javascript"></script>
    
     <style type="text/css">
      span {
          font-size: 13px;
      }

      .card {
          background-color: #fff;
          border-radius: 10px;
          border: none;
          position: relative;
          margin-bottom: 30px;
          box-shadow: 0 0.46875rem 2.1875rem rgba(90,97,105,0.1), 0 0.9375rem 1.40625rem rgba(90,97,105,0.1), 0 0.25rem 0.53125rem rgba(90,97,105,0.12), 0 0.125rem 0.1875rem rgba(90,97,105,0.1);
      }

      .l-bg-cherry {
          background: linear-gradient(to right, #493240, #ae9ba6) !important;
          color: #fff;
      }    
      .l-bg-cherry-N {
          background: linear-gradient(to right, #bb0975db, #705565d1) !important;
          color: #fff;
      }

      .l-bg-lun {
          background: linear-gradient(to right, #2da77c, #a1c7c0) !important;
          color: #fff;
      }

      .l-bg-ten {
          background: linear-gradient(to right, #373b44, #43cddd) !important;
          color: #fff;
      }

      .l-bg-room {
          background: linear-gradient(to right, #373b44, rgb(0 0 0 / 44%));
          color: #fff;
      }

      .l-bg-blue-dark {
          background: linear-gradient(to right, #373b44, #4286f4) !important;
          color: #fff;
      }

      .l-bg-green-dark {
          background: linear-gradient(to right, #3d1919, #d83240) !important;
          color: #fff;
      }

      .l-bg-orange-dark {
          background: linear-gradient(to right, #61513d, #439cfff2) !important;
          color: #fff;
      }

      .l-bg-yellow {
          background: linear-gradient(to right, #ec3131, #e6711d) !important;
          color: #fff;
      }

      .l-bg-purple {
          background: linear-gradient(to right, #493240, #4bb97b) !important;
          color: #fff;
      }

      .card .card-statistic-3 .card-icon-large .fas, .card .card-statistic-3 .card-icon-large .far, .card .card-statistic-3 .card-icon-large .fab, .card .card-statistic-3 .card-icon-large .fal {
          font-size: 110px;
      }

      .card .card-statistic-3 .card-icon {
          text-align: center;
          line-height: 50px;
          margin-left: 15px;
          color: #000;
          position: absolute;
          right: -5px;
          top: 20px;
          opacity: 0.1;
      }

      .l-bg-cyan {
          background: linear-gradient(135deg, #289cf5, #84c0ec) !important;
          color: #fff;
      }

      .l-bg-green {
          background: linear-gradient(135deg, #23bdb8 0%, #43e794 100%) !important;
          color: #fff;
      }

      .l-bg-orange {
          background: linear-gradient(to right, #f9900e, #ffba56) !important;
          color: #fff;
      }

      .l-bg-cyan {
          background: linear-gradient(135deg, #289cf5, #84c0ec) !important;
          color: #fff;
      }

      .progress-bar {
          display: none;
      }

      .progress {
          display: none;
      }
  </style>

    <script type="text/javascript">

        $(document).ready(function () {

            var date = '<%= DateTime.Now%>';
            $("#txtsdate").datepicker({
                dateFormat: 'MM d,yy',

            }).attr('readonly', 'readonly');

            $("#txtedate").datepicker({
                dateFormat: 'MM d,yy',

            }).attr('readonly', 'readonly');

            date = moment(date).format('LL');
            $("#txtsdate").val(date);
            $("#txtedate").val(date);

            LoadInventoryDashboard(date, date);

        });

        function search() {
            var dt = $('#txtsdate').val();
            var dts = $('#txtedate').val();
            LoadInventoryDashboard(dt, dts)
        }

        function LoadInventoryDashboard(startDate, endDate) {
            debugger;
            var txt_sdate = startDate;
            var txt_edate = endDate;
            async: false;
            $.ajax({
                async: false,
                type: "POST",
                url: "Inventory_ProcurementDashboard.aspx/LaodDashBoard",
                data: JSON.stringify({
                    'txt_sdate': txt_sdate,
                    'txt_edate': txt_edate,
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",

                success: function (data) {
                    debugger;

                    var data = JSON.parse(data.d);

                    debugger;
                    for (var i = 0; i < data.length; i++) {
                        debugger;
                        var Category = data[i].Category;
                        if (Category == "Total_PR") {
                            $('#total_PR').text(data[i].CountValue);
                        }
                        if (Category == "Total_PR_Created") {
                            $('#total_PR_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_PR_Approved") {
                            $('#total_PR_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_PR_Cancelled") {
                            $('#total_PR_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_PO") {
                            $('#total_PO').text(data[i].CountValue);
                        }
                        if (Category == "Total_PO_Created") {
                            $('#total_PO_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_PO_Approved") {
                            $('#total_PO_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_PO_Cancelled") {
                            $('#total_PO_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_CS") {
                            $('#total_CS').text(data[i].CountValue);
                        }
                        if (Category == "Total_CS_Created") {
                            $('#total_CS_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_CS_Approved") {
                            $('#total_CS_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_CS_Cancelled") {
                            $('#total_CS_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_IGP") {
                            $('#total_IGP').text(data[i].CountValue);
                        }

                        if (Category == "Total_Created_IGP") {
                            $('#total_IGP_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_Approved_IGP") {
                            $('#total_IGP_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_Cancelled_IGP") {
                            $('#total_IGP_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_GRN") {
                            $('#total_GRN').text(data[i].CountValue);
                        }
                        if (Category == "Total_GRN_Created") {
                            $('#total_GRN_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_GRN_Approved") {
                            $('#total_GRN_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_GRN_Cancelled") {
                            $('#total_GRN_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIR") {
                            $('#total_GIR').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIR_Created") {
                            $('#total_GIR_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIR_Approved") {
                            $('#total_GIR_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIR_Cancelled") {
                            $('#total_GIR_Cancelled').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIN") {
                            $('#total_GIN').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIN_Created") {
                            $('#total_GIN_Created').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIN_Approved") {
                            $('#total_GIN_Approved').text(data[i].CountValue);
                        }
                        if (Category == "Total_GIN_Cancelled") {
                            $('#total_GIN_Cancelled').text(data[i].CountValue);
                        }

                    }

                }
            });
        }

        function GotoGIRList() {
            window.location = "Inventory/GoodsIssuanceRequestView.aspx"
        }
        function GotoGINList() {
            window.location = "Inventory/GoodsIssuanceNoteView.aspx"
        }
        function GotoPRList() {
            window.location = "AP/PurchaseRequistionView.aspx"
        }
        function GotoPOList() {
            window.location = "AP/PurchaseOrderView.aspx"
        }
        function GotoCSList() {
            window.location = "AP/PurchaseRequistionView.aspx"
        }
        function GotoIGPList() {
            window.location = "Inventory/InversionGatePassView.aspx"
        }
        function GotoGRNList() {
            window.location = "Inventory/GRNView.aspx"
        }

    </script>


</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

        <div class="row" style="justify-content: center;">
        <h1 class="card-title mb-0 font-weight-bold ml-5 p-3">Inventory & Procurement Dashboard</h1>
    </div>
    <hr />
    <br />
    <br />
        <div class="row">

        <div class="col-lg-3">
            <label>
                Start Date:
            </label>
            <input type="text" id="txtsdate" />
        </div>

        <div class="col-lg-3">
            <label>
                End Date:
            </label>
            <input type="text" id="txtedate" />
        </div>
        <div class="col-lg-2">

            <input type="button" id="serach" value="Search" onclick="search()" />
        </div>
    </div>
     <br />
     <br />
     <br />
    <div class="container-fluid">
        <div class="col-md-12">
            <div class="row">
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-orange-dark" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">
                            <div class="card-icon card-icon-large"><i class="fas fa-solid fa-registered" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">GIR</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGIRList()">Total GIR</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIR"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGIRList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIR_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGIRList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIR_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGIRList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIR_Cancelled"></span>
                                </div>

                            </div>

                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">
                    <div class="card l-bg-yellow" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">
                            <div class="card-icon card-icon-large"><i class="fas fa-store" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">GIN</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGINList()">Total GIN</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIN"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGINList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIN_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGINList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIN_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGINList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GIN_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>

                </div>

                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-cherry" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-clipboard" style="margin-right: 20px; margin-top: 70px;"></i>
<%--                               <i class="fa-thin fa-clipboard-question"></i>   --%>
                            </div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Purchase Requisition</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoPRList()">Total PR</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PR"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoPRList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PR_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoPRList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PR_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoPRList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PR_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5" data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-cherry-N" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-clipboard-list" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Comparative Statement</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoCSList()">Total CS</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_CS"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoCSList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_CS_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoCSList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_CS_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoCSList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_CS_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5" data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <div class="row">

                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-lun" style="height: 230px; width: 240px;">
                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large">
                                <i class="fas fa-solid fa-boxes" style="margin-right: 20px; margin-top: 70px;"></i>

                            </div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">Purchase Orders</h3>
                            </div>

                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoPOList();">Total PO</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PO"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoPOList();">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PO_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoPOList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PO_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0"><a style="text-decoration: none; cursor: pointer;" onclick="GotoPOList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_PO_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-blue-dark" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-box-check" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">IGP</h3>
                            </div>

                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoIGPList()">Total IGP</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_IGP"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoIGPList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_IGP_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoIGPList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_IGP_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoIGPList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_IGP_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-xl-3 col-lg-6">

                    <div class="card l-bg-green-dark" style="height: 230px; width: 240px;">

                        <div class="card-statistic-3 p-4">

                            <div class="card-icon card-icon-large"><i class="fas fa-regular fa-clipboard-list-check" style="margin-right: 20px; margin-top: 70px;"></i></div>
                            <div class="mb-4">
                                <h3 class="card-title mb-0 font-weight-bold">GRN</h3>
                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGRNList()">Total GRN</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GRN"></span>
                                </div>

                            </div>

                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGRNList()">Created</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GRN_Created"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGRNList()">Approved</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GRN_Approved"></span>
                                </div>

                            </div>
                            <div class="row align-items-center mb-2 d-flex">
                                <div class="col-8">
                                    <h3 class="d-flex align-items-center mb-0">
                                        <a style="text-decoration: none; cursor: pointer;" onclick="GotoGRNList()">Cancelled</a>
                                    </h3>
                                </div>
                                <div class="col-4 text-right">
                                    <span id="total_GRN_Cancelled"></span>
                                </div>

                            </div>
                            <div class="progress mt-5 " data-height="8" style="height: 8px;">
                                <div class="progress-bar l-bg-cyan" role="progressbar" data-width="25%" aria-valuenow="25" aria-valuemin="0" aria-valuemax="100" style="width: 25%;"></div>
                            </div>
                        </div>

                    </div>
                </div>

            </div>

        </div>
    </div>

</asp:Content>
