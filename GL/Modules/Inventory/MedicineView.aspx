<%@ Page EnableSessionState="ReadOnly" Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="MedicineView.aspx.cs" Inherits="PMS.MedicineView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
       <script type="text/javascript" src="javascripts/DataTable/jquery-2.2.3.js"></script>
    <script type="text/javascript" src="javascripts/DataTable/jquery-2.2.3.min.js"></script>
    <link rel="stylesheet" type="text/css" href="javascripts/DataTable/datatables.min.css" />
    <script type="text/javascript" src="javascripts/DataTable/datatables.min.js"></script>
    <script type="text/javascript" src="javascripts/DataTable/ColReorderWithResize.js"></script>
    <script type="text/javascript" src="stylesheets/bootstrap/js/bootstrap.js"></script>
    <link rel="stylesheet" type="text/css" href="stylesheets/bootstrap/css/bootstrap.css" />

    <link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.12/css/jquery.dataTables.min.css" />
    <script type="text/javascript" src="//code.jquery.com/jquery-1.12.3.js"></script>
    <script type="text/javascript" src="https://cdn.datatables.net/1.10.12/js/jquery.dataTables.min.js"></script>
      <style type="text/css">


            div.token-input-dropdown {
    overflow: auto;
    max-height: 150px;
}
            ul.token-input-list {
                width: 168px;
            }
             .HRcontentRight {

            float:right
        }
        .HRcontentCenter {

            text-align:center
        }

            .table {
                margin: 1em 0;
                width: 100%;
                overflow: hidden;
                background: #FFF;
                color: #024457;
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
        </style>
      <script type="text/javascript">
          $(document).ready(function () {
             // $('#loadingimage').show();
              FillList();


              $("#txtSearch").keypress(function (event) {
                  var SearchString = $('#txtSearch').val();
                  if (event.which == 13) {
                      {
                          event.preventDefault();
                          $("#VULookup").show();
                          if (SearchString != '') {
                              PageMethods.Search(SearchString, OnFilter, OnFail);
                          }
                      }
                      if (SearchString === '') {
                          FillList();
                      }
                  }
              });

              $("#txtSearch").keyup(function (event) {
                  var SearchString = $('#txtSearch').val();
                  event.preventDefault();
                  if (SearchString === '')
                      FillList();
              });
          });

          function FillList() {
              /* destroy the datatable before filtering */

              //if ($.fn.DataTable.isDataTable('#tbloutPatients')) {
              //    $('#tblResult').DataTable().destroy();
              //}
              $('#tbloutPatients tbody').empty();
              var SearchString = '';

              PageMethods.Search(SearchString,OnFilter, OnFail);
          }


          function OnFilter(data) {

              ClearResults();

              for (var i = 0; i < data.length; i++) {
                  AddResult(data[i].Item_ID, data[i].Item_Code, data[i].Description, data[i].UOM, data[i].Sale_Rate, data[i].Category_Name, data[i].Item_Type);
              }

              //$("#VULookup").hide();
              //$("#loadingimage").hide();
             // ShowDataTable();
          }

          function ClearResults() {
              while (tbloutPatients.rows.length > 1) {
                  tbloutPatients.deleteRow(1);
              }
          }

          function OnFail(exc) {
              alert(exc.get_message());
          }

          function AddResult(Item_ID, Item_Code, Description, UOM, Sale_Rate, Category_Name, Item_Type) {
              tblLength = tbloutPatients.rows.length;

              var row = ibody.insertRow(-1);
              var cell;

              cell = row.insertCell(-1);
              cell.innerHTML = '<span spnPatID' + tblLength + '>' + Item_ID + '</span>';
              cell.className = "hide";

              cell = row.insertCell(-1);
              cell.innerHTML = '<span spnPatID' + tblLength + '>' + Item_Code + '</span>';

              cell = row.insertCell(-1);
              cell.innerHTML = '<span class="HRcontent">' + Description + '</span>';
              cell = row.insertCell(-1);
              cell.innerHTML = '<span class="HRcontent">' + UOM + '</span>';
              cell = row.insertCell(-1);
              cell.innerHTML = '<span class="HRcontent">' + Sale_Rate + '</span>';
              cell = row.insertCell(-1);
              cell.innerHTML = '<span class="HRcontent">' + Category_Name + '</span>';
              //cell = row.insertCell(-1);
              //cell.innerHTML = '<span class="HRcontent">' + Item_Type + '</span>';

              cell = row.insertCell(-1);
              cell.innerHTML = '<a class="HRlink" href="#" onclick=editOpen(' + Item_ID + ')>Edit</a> | <a href="#" onclick=deleteConfirm(this)>Delete</a>';
          }

          function editOpen(id) {

              window.location.href = "PharmacyItems.aspx?ID=" + id + "";

          }

          function deleteConfirm(anchorTag) {

              var row = $(anchorTag).parents('tr')[0];
              var ItemID = $($(row).find('td')[0]).text();

              if (confirm('Are you sure want to delete this record')) {
                  PageMethods.DeleteRecord(ItemID, function (msg) {
                      row.remove();
                  }, OnFail);
              }
          }

          function ShowDataTable() {
              $(document).ready(function () {

                  $('#tbloutPatients').DataTable({

                  });

              });
          }
</script>     
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <fieldset>
            <a class="btn red btn-outline sbold" style="text-align: center" href="PharmacyItems.aspx">Add New</a>

        </fieldset>
       
         <fieldset>
              <input type="button" id="btnSearch" style="margin-left:1014px; display:none;" class="btn red btn-outline sbold" value="Search"/>            
              <label style="margin-left:1014px;">Search: </label> 
             <input type="text" id="txtSearch" style="margin-left:2px;" />

        </fieldset>
      <div style="overflow:scroll; height:600px;">
        <table class="table" id="tbloutPatients">
            <thead id="ihead">
                <tr>                  
                    <th style="display:none;">Item ID</th>  
                    <th>Item Code</th>
                    <th style="width: 500px;">Description</th>
                    <th>UOM</th>
                    <th style="text-align:right">Purchase Rate</th>  
                    <th>Item Category Name</th>  
                    <th style="display:none">Item Type</th>                                          
                    <th>Actions</th>
                </tr>

            </thead>

            <tbody id="ibody">
            </tbody>
        </table>
          </div>
</asp:Content>
