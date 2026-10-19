<%@ Page Title="" Language="C#" EnableSessionState="ReadOnly" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Inv_OriginatorTempelates.aspx.cs" Inherits="PMS.GL.Inv_OriginatorTempelates" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />

    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/inv_org.css" rel="stylesheet" />
    <script type="text/javascript">   
        $(document).ready(function () {
            $('select').select2();
            var id = '<% =Request.QueryString["ID"] %>';
            if (id != "") {
                $('#btnSave').val('Update');
                LoadMasterData(id);
                LoadOriginators(id);
                LoadFormIds(id);
            }
            $('#btnNew').on('click', function () {
                window.location.href = "Inv_OriginatorTempelates.aspx";
            });
            $('#btnList').on('click', function () {
                window.location.href = "Inv_OriginatorTempelatesView.aspx";
            });
            $('#btnSave').on('click', function () {
                var id = $('#txtOrignatorTempelateID').val();
                if (id == "") {
                    id = "";
                }
                var btnValue = $("#btnSave").val();
                var txttempelateName = $("#txtOrignatorTempName").val();
                var txttempelateDescription = $("#txtOrignatorTempelateDescription").val();
                var chkIsActive = $("#chkIsActive").prop('checked');
                if (txttempelateName == "") {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please Enter Tempelate Name',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return false;
                }
                var UserList = new Array();
                var list = document.getElementById('Originatorlist');
                if (list.rows.length <= 1) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: 'Please add User',
                        showConfirmButton: false,
                        timer: 2000,
                        customClass: {
                            popup: 'swal-big-popup',
                            title: 'swal-big-title',
                            htmlContainer: 'swal-big-text'
                        }
                    });
                    return false;
                }
                $('#appusers select').each(function (key) {
                    var ddlUser = $(this).val();
                    if (ddlUser == "") {
                        Swal.fire({
                            icon: 'error',
                            title: 'Error!',
                            text: 'Please Select User',
                            showConfirmButton: false,
                            timer: 2000,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        return false;
                    }
                    UserList[key + 1] = new Array(ddlUser);
                });
                var checkedPurchasesFormIDs = [];
                var checkedPurchasesCheckBoxIDs = [];
                $("#<%=chkPurchases.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_PurchasehidFormID_" + index).val();
                    checkedPurchasesFormIDs.push(formID);
                    checkedPurchasesCheckBoxIDs.push(checkboxID);
                });

                var checkedInventoryFormIDs = [];
                var checkedInventoryCheckBoxIDs = [];
                $("#<%=chkInventory.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_InventoryhidFormID_" + index).val();
                    checkedInventoryFormIDs.push(formID);
                    checkedInventoryCheckBoxIDs.push(checkboxID);
                });

                var checkedAccountPayableFormIDs = [];
                var checkedAccountPayableCheckBoxIDs = [];
                $("#<%=chkAccountPayable.ClientID%> input[type='checkbox']:checked").each(function () {
                    var checkboxID = $(this).attr('id');
                    var index = checkboxID.split('_').pop();
                    var formID = $("#ctl00_MainContent_AccountPayablehidFormID_" + index).val();
                    checkedAccountPayableFormIDs.push(formID);
                    checkedAccountPayableCheckBoxIDs.push(checkboxID);
                });

                $.ajax({
                    type: "POST",
                    url: "Inv_OriginatorTempelates.aspx/Save",
                    data: JSON.stringify({
                        "btnValue": btnValue,
                        "id": id,
                        "txttempelateName": txttempelateName,
                        "txttempelateDescription": txttempelateDescription,
                        "chkIsActive": chkIsActive,
                        "UserDetail": UserList,
                        "CheckedPurchasesFormIDs": checkedPurchasesFormIDs,
                        "CheckedPurchasesCheckBoxIDs": checkedPurchasesCheckBoxIDs,
                        "CheckedInventoryFormIDs": checkedInventoryFormIDs,
                        "CheckedInventoryCheckBoxIDs": checkedInventoryCheckBoxIDs,
                        "CheckedAccountPayableFormIDs": checkedAccountPayableFormIDs,
                        "CheckedAccountPayableCheckBoxIDs": checkedAccountPayableCheckBoxIDs
                    }),
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (response) {
                        var data = response.d;
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data has been saved successfully',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });

                        window.location.href = "Inv_OriginatorTempelates.aspx?ID=" + data;
                    }, error: function () { }
                });
            });
        });
        $(function () {
            $("#tabs").tabs();
        });
        function LoadMasterData(id) {
            $.ajax({
                type: "POST",
                url: "Inv_OriginatorTempelates.aspx/LoadMasterData",
                data: JSON.stringify({
                    "id": id
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var parsed_Data = JSON.parse(response.d);
                    $("#txtOrignatorTempelateID").val(parsed_Data.OrignatorTempelate_ID);
                    $("#txtOrignatorTempName").val(parsed_Data.OrignatorTempelate_Name);
                    $("#txtOrignatorTempelateDescription").val(parsed_Data.OrignatorTempelate_Description);
                    if (parsed_Data.IsActive == true) {
                        $("#chkIsActive").prop('checked', true);
                    }
                }, error: function () { }
            });
        }

        // One shared user list for the whole page (loaded once, not once per row)
        var userOptionsHtml = null;
        var userNameMap = {};
        function escHtml(s) {
            return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
        }
        function getUsers(callback) {
            if (userOptionsHtml !== null) { callback(); return; }
            PageMethods.loadUser(function (resp) {
                var html = '<option value="0">Please Select</option>';
                $.each(JSON.parse(resp), function (k, v) {
                    userNameMap[String(v.UserId).toLowerCase()] = v.UserName;
                    html += '<option value="' + v.UserId + '">' + escHtml(v.UserName) + '</option>';
                });
                userOptionsHtml = html;
                callback();
            }, function (error) {
                alert(error.get_message());
            });
        }
        // Rows are drawn with only their own selected user; the full list and select2 are attached
        // the first time the user clicks the dropdown, so 250+ rows open instantly.
        $(document).on('mousedown focus', 'select.lazyUser', function (e) {
            var $s = $(this);
            if (!$s.hasClass('lazyUser')) return;
            $s.removeClass('lazyUser');
            var cur = $s.val();
            var isClick = (e.type === 'mousedown');
            if (isClick) e.preventDefault();
            getUsers(function () {
                $s.html(userOptionsHtml).val(cur).select2();
                // swapping in select2 drops keyboard focus; put it back so Tab / arrow keys keep working
                var $box = $s.next('.select2-container').find('.select2-selection');
                $s.on('select2:close', function () { setTimeout(function () { $box.trigger('focus'); }, 0); });
                if (isClick) { $s.select2('open'); } else { $box.trigger('focus'); }
            });
        });
        function LoadOriginators(id) {
            PageMethods.LoadOriginators(id, function (resp) {
                var data = JSON.parse(resp);
                getUsers(function () {
                    var rows = [];
                    $.each(data, function (key, value) {
                        var uid = String(value).toLowerCase();
                        var name = userNameMap[uid] || uid;
                        rows.push('<tr>' +
                            '<td><select class="form-control ddlUser lazyUser" id="tblddlUser' + (key + 1) + '" name="tblddlUser" style="width:100% !important"><option value="' + uid + '" selected>' + escHtml(name) + '</option></select></td>' +
                            '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" ></i></a>' +
                            '</td>' +
                            '</tr>');
                    });
                    $('#appusers').append(rows.join(''));
                });
            });
        }

        function LoadFormIds(id) {
            PageMethods.LoadFormIds(id, function (resp) {
                var data = JSON.parse(resp);
                data.forEach(function (checkboxId) {
                    $('#' + checkboxId).prop('checked', true);
                });
            });
        }
        function AppendUser() {
            var NoUserselect = false;
            $('#appusers select').each(function () {
                if ($(this).val() === "0") {
                    NoUserselect = true;
                    return false;
                }
            });
            if (NoUserselect) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select a user.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

            } else {
                var rows = '';
                var rowlength = Originatorlist.rows.length;
                rows = '<tr>' +
                    '<td>' +
                    '<select name="tblddlUser" style="width:100% !important" id="tblddlUser' + rowlength + '">' +
                    '</select>' +
                    '</td>' +
                    '<td><a href="javascript:void(0)" onclick="ExcludeFromPayment(this)"><i class="glyphicon glyphicon-trash" style="width:15px !important;font-size: 13px;color:#f30a0a;position:relative;" i=""></i></a>' +
                    '</td>' +
                    '</tr>'
                $('#appusers').append(rows);
                loadItemList(rowlength);
            }
        }
        function loadItemList(rowlength) {
            getUsers(function () {
                $('#tblddlUser' + rowlength).html(userOptionsHtml).select2();
            });
        }


        function ExcludeFromPayment(anchor) {
            Swal.fire({
                icon: 'warning',
                title: 'Are you sure?',
                text: 'This action will delete ',
                showCancelButton: true,
                confirmButtonColor: '#d33',
                cancelButtonColor: '#3085d6',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel',
                customClass: {
                    popup: 'swal-big-popup',
                    title: 'swal-big-title',
                    htmlContainer: 'swal-big-text'
                }
            }).then((result) => {
                if (result.isConfirmed) {
                    var row = $(anchor).parents('tr')[0];
                    row.remove();
                }
            });
            
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="hidden" id="txtOrignatorTempelateID" name="txtOrignatorTempelateID" />
    <div class="row">
        <div class="col-lg-4 col-md-5 col-sm-10">

            <label for="txtOrignatorTempName">Orignator Tempelate Name</label>
            <input type="text" name="txtOrignatorTempName" class="form-control" id="txtOrignatorTempName" placeholder="Enter OrignatorTempelate Name" />

        </div>
        <div class="col-lg-4 col-md-5 col-sm-10">

            <label for="txtOrignatorTempelateDescription">Orignator Tempelate Description</label>
            <input type="text" name="txtOrignatorTempelateDescription" class="form-control" id="txtOrignatorTempelateDescription" placeholder="Enter OrignatorTempelate Description" />

        </div>
        <div class="col-lg-1 col-md-2 col-sm-12" style="margin-top: 30px; width: 40px !important;">

     <input type="checkbox" id="chkIsActive" name="chkIsActive" />

 </div>
 <div class="col-lg-1 col-md-2 col-sm-12" style="margin-top: 30px;">
     <label id="lblchkIsActive">Active</label>

 </div>
    </div>


    <div style="width: 100%">
        <div id="tabs">
            <ul>
                <li><a href="#Tab-1">Originator</a></li>
                <li><a href="#Tab-2">Documents / Forms</a></li>
            </ul>

            <div id="Tab-1" style="width: 100%;">
                <div style="overflow-x: auto; overflow-y: auto; height: 200px;">
                  <div class="row">
                      <div class="col-lg-11"></div>
                      <div class="col-lg-1 col-md-1 col-sm-1">
                            <input type="button" class="btn-primry" onclick="AppendUser()" value="+" id="AddUser" style="" />
                      </div>
                  </div>
                    <table class="table table-bordered" id="Originatorlist" style="font-size: 10px!important; width: 100% !important; overflow: unset;">
                        <thead>
                            <tr>
                                <th style="width: 90%;">User Name</th>
                                <th style="text-align: center; width: 10%;">Action</th>
                            </tr>
                        </thead>
                        <tbody id="appusers">
                        </tbody>
                    </table>
                </div>
            </div>

            <div id="Tab-2" style="display: flex">
                <div class="checkbox-list-container">
                    <label class="double-underline">Purchase:</label>
                    <asp:CheckBoxList ID="chkPurchases" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                    <div id="PurchasehiddenFieldsContainer" runat="server"></div>
                </div>
                <div class="checkbox-list-container">
                    <label class="double-underline">Inventory:</label>
                    <asp:CheckBoxList ID="chkInventory" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                    <div id="InventoryhiddenFieldsContainer" runat="server"></div>
                </div>
                <div class="checkbox-list-container">
                    <label class="double-underline">Account Payable:</label>
                    <asp:CheckBoxList ID="chkAccountPayable" runat="server" CssClass="checkbox-item"></asp:CheckBoxList>
                    <div id="AccountPayablehiddenFieldsContainer" runat="server"></div>
                </div>
            </div>
        </div>
    </div>

    <br />
    <div class="row">
        <div class="col-lg-8">
            <div class="row">
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-primry" id="btnSave" value="Save" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-yellow" id="btnNew" value="New" />
                </div>
                <div class="col-lg-2 col-md-4 col-sm-6">
                    <input type="button" class="btn btn-gray" id="btnList" value="View" />
                </div>
            </div>
        </div>







    </div>
</asp:Content>
