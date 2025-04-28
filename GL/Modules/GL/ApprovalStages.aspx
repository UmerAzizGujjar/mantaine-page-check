<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ApprovalStages.aspx.cs" Inherits="PMS.GL.ApprovalStages" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../css/stock.css" rel="stylesheet" />
    <script src="../CssJs/select2.min.js"></script>
    <link href="../CssJs/select2.min.css" rel="stylesheet" />
    <style type="text/css">
       
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                LoadMasterData(id);
                Loaddetail(id);
            }
            $('#btnNew').on('click', function () {
                window.location.href = "ApprovalStages.aspx";
            });
            $('#btnList').on('click', function () {
                window.location.href = "ApprovalStagesView.aspx";
            });
            $('#btnSave').on('click', function () {
                var id = $('#txtStageID').val();
                if (id == "") {
                    id = "";
                }
                var btnValue = $("#btnSave").val();
                var txtStageName = $("#txtStageName").val();
                var txtStageDescription = $("#txtStageDescription").val();
                var txtNoOfApproval = $("#txtNoOfApproval").val();
                var txtNoOfUnApproval = $("#txtNoOfUnApproval").val();
                var chkFinalApproval = $("#chkFinalApproval").prop('checked');
                if (txtStageName == "") {
                    alert("Please Enter Stage Name");
                    return false;
                }
                if (txtNoOfApproval !== "" && (!txtNoOfApproval.match(/^\d+$/) || txtNoOfApproval < 0 || txtNoOfApproval > 10)) {
                    alert("Please Enter a valid number between 0 and 9 for No Of Approvals Required");
                    return false;
                }
                if (txtNoOfUnApproval !== "" && (!txtNoOfUnApproval.match(/^\d+$/) || txtNoOfUnApproval < 0 || txtNoOfUnApproval > 10)) {
                    alert("Please Enter a valid number between 0 and 9 for No Of UnApprovals Required");
                    return false;
                }
                var approvalList = new Array();
                var list = document.getElementById('tblItemDescription');
                if (list.rows.length <= 1) {
                    alert("Please add User");
                    return false;
                }
                var table = $('#tblItemDescriptionDetail');
                table.find('tr').each(function (key, value) {
                    var ddlUser = $("#tblddlUser" + (key + 1) + " option:selected").val();
                    if (ddlUser == "") {
                        alert("Please Select User");
                        return false;
                    }
                    approvalList[key + 1] = new Array(ddlUser);
                });
                $.ajax({
                    type: "POST",
                    url: "ApprovalStages.aspx/Save",
                    data: JSON.stringify({
                        "btnValue": btnValue,
                        "id": id,
                        "txtStageName": txtStageName,
                        "txtStageDescription": txtStageDescription,
                        "txtNoOfApproval": txtNoOfApproval,
                        "txtNoOfUnApproval": txtNoOfUnApproval,
                        "chkFinalApproval": chkFinalApproval,
                        "approvalDetail": approvalList
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;
                        alert("Data has been saved successfully");
                        window.location.href = "ApprovalStages.aspx?ID=" + data;
                    }, error: function () { }
                });
            })
        });
        function LoadMasterData(id) {
            $.ajax({
                type: "POST",
                url: "ApprovalStages.aspx/LoadMasterData",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    $("#txtStageID").val(parsed_Data.Stage_ID);
                    $("#txtStageName").val(parsed_Data.Stage_Name);
                    $("#txtStageDescription").val(parsed_Data.Stage_Description);
                    $("#txtNoOfApproval").val(parsed_Data.NoOfApprovalRequire);
                    $("#txtNoOfUnApproval").val(parsed_Data.NoOfUnApprovalRequire);
                    if (parsed_Data.IsFinalApproval == true) {
                        $("#chkFinalApproval").prop('checked', true);
                    }
                }, error: function () { }
            });
        }
        function Loaddetail(id) {
            var rows = '';
            PageMethods.LoadDetails(id, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                var rowIndex = $('#tblItemDescriptionDetail tbody tr').length;
                $.each(data, function (key, value) {
                    rows += '<tr>' +
                        '<td><select class="form-control ddlUser" id="tblddlUser' + (key + 1) + '" name="tblddlUser" style="width:100% !important"></select></td>' +
                        '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                        '</td>' +
                        '</tr>';
                });
                $('#tblItemDescriptionDetail').append(rows);
                loaddetailItemList(data);
            });
        }
        function loaddetailItemList(selectedOptions) {
            var optionsUser = '';
            var ddlPromises = [];
            $('.ddlUser').each(function (index) {
                var ddl = $(this);
                ddl.select2();
                var ddlPromise = new Promise(function (resolve, reject) {
                    PageMethods.loadUser(function (resp) {
                        optionsUser = '<option value="0">Please Select</option>';
                        $.each(JSON.parse(resp), function (key, value) {
                            optionsUser += '<option value="' + value.UserId + '" >' + value.UserName + '</option>';
                        });
                        ddl.html(optionsUser);
                        resolve();
                    }, function (error) {
                        reject(error);
                    });
                });
                ddlPromises.push(ddlPromise);
            });
            Promise.all(ddlPromises).then(function () {
                $('.ddlUser').each(function (index) {
                    var selectedValue = selectedOptions[index];
                    selectedValue = selectedValue.toLowerCase();
                    if (selectedValue) {
                        $('#tblddlUser' + (index + 1)).val(selectedValue).trigger('change');
                    }
                });
            }).catch(function (error) {
                console.error('Error loading dropdowns:', error);
            });
        }
        function AddRow() {
            var rows = '';
            var rowlength = tblItemDescription.rows.length;
            rows = '<tr>' +
                '<td>' +
                '<select name="tblddlUser" style="width:100% !important" id="tblddlUser' + rowlength + '">' +
                '</select>' +
                '</td>' +
                '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                '</td>' +
                '</tr>'
            $('#tblItemDescriptionDetail').append(rows);
            loadItemList(rowlength);
        }
        function loadItemList(rowlength) {
            var optionsUser = '';
            var length = rowlength;
            $('#tblddlUser' + length + '').select2();
            PageMethods.loadUser(function (resp) {
                optionsUser = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (key, value) {
                    optionsUser += '<option value="' + value.UserId + '" >' + value.UserName + '</option>';
                });
                $('#tblddlUser' + length + '').html(optionsUser);
            },
                function (error) {
                    alert(error.get_message());
                });
        }
        function ExcludeFromPayment(anchor) {
            var a = confirm("Are you sure You want to delete");
            if (a == true) {
                var row = $(anchor).parents('tr')[0];
                row.remove();
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtStageID" name="txtStageID" />
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
          
                <label for="txtStageName">Stage Name</label>
                <input type="text" name="txtStageName" class="form-control" id="txtStageName" placeholder="Enter Stage Name" />
            
        </div>
        <div class="col-lg-3 col-md-6 col-sm-12">
            
                <label for="txtStageDescription">Stage Description</label>
                <input type="text" name="txtStageDescription" class="form-control" id="txtStageDescription" placeholder="Enter Stage Description" />

        </div>
         <div class="col-lg-2 col-md-3 col-sm-4">
                    <input type="checkbox" id="chkFinalApproval" name="chkFinalApproval" />
                    <label id="lblchkFinalApproval">Final Approval</label>
                </div>        
        <div class="col-lg-2 col-md-3 col-sm-4">
                        <label ></label>
                      <input type="button" class="btn-primry" onclick="AddRow()" value="Add"  />
                    
                </div>
    </div>
    <div class="row" style="display:none">
        <div class="col-md-6">
            <div class="form-group">
                <label for="txtNoOfApproval">No Of Approvals Required</label>
                <input type="text" name="txtNoOfApproval" class="form-control" id="txtNoOfApproval" placeholder="Enter No Of Approvals Required" />
            </div>
        </div>
        <div class="col-md-6">
            <div class="form-group">
                <label for="txtNoOfUnApproval">No Of UnApprovals Required</label>
                <input type="text" name="txtNoOfUnApproval" class="form-control" id="txtNoOfUnApproval" placeholder="Enter No Of UnApprovals Required" />
            </div>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-10 col-md-10 col-sm-12">
            <div class="form-group">
               
             
                <table class="table table-bordered" id="tblItemDescription">
                    <thead>
                        <tr>
                            <th style="width: 65%;">User Name</th>
                            <th style="width: 10%">Action</th>
                        </tr>
                    </thead>
                    <tbody id="tblItemDescriptionDetail">
                    </tbody>
                </table>

            </div>
        </div>
    </div>
    <div class="row">
          <div class="col-lg-1 col-md-4 col-sm-6">
                <input type="button" id="btnSave" class="btn btn-primry" value="Save"  />
            </div>
              <div class="col-lg-1 col-md-4 col-sm-6">
                  <input type="button" id="btnNew" value="New" class="btn btn-yellow" />
              </div>
              <div class="col-lg-1 col-md-4 col-sm-6">
                   
                <input type="button" id="btnList" value="List view" class="btn btn-gray" />
               </div>
      
              
               
        </div>
</asp:Content>
