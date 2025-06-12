<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Menu.aspx.cs" Inherits="PMS.Menu" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(document).ready(function () {
            fillParentMenu();
            $('#ddlParent_Menu').select2();
            var id = '<%= Request.QueryString["ID"] %>';
        if (id != "") {
            cleartext();
            populatemenudata(id);
        }
    });
        function cleartext() {
            $('#txtMenu_Name').val("");
            $('#txtMenu_Discription').val("");
            $('#txtMenu_Url').val("");
            $('#ddlParent_Menu').val("");
            $('#txtOrder_By').val("");
            $('#cbActive').prop("checked", false);
        }
        function fillParentMenu() {
            $.ajax({
                type: "POST",
                url: "Menu.aspx/BindParentMenu", 
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var options = '<option value="0">Please Select</option>';
                    var data = JSON.parse(response.d);
                    $.each(data, function (key, value) {
                        options += '<option value="' + value.ParentID + '">' + value.ParentName + '</option>';
                    });
                    $('#ddlParent_Menu').html(options);
                },
                error: function (xhr, status, error) {
                    console.log("Error: " + error);
                }
            });
        }
        function populatemenudata(id) {
            $.ajax({
                type: "POST",
                url: "Menu.aspx/PopulateMenuData", 
                data: JSON.stringify({ id: parseInt(id) }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    var MenuData = JSON.parse(response.d);
                    $('#txtMenu_Name').val(MenuData.MenuName);
                    $('#txtMenu_Discription').val(MenuData.MenuDescription);
                    $('#txtMenu_Url').val(MenuData.URL);
                    $('#txtOrder_By').val(MenuData.OrderBy);
                    $('#cbActive').prop("checked", MenuData.IsActive);
                    $('#btnSave').val(MenuData.BtnText);
                    setTimeout(function () {
                        $('#ddlParent_Menu').val(MenuData.ParentID);
                    }, 2500);
                },
                error: function (xhr, status, error) {
                    alert("Error: " + xhr.responseText);
                }
            });
        }
        function savedata() {
            var valid = true;
            var MenuName = $('#txtMenu_Name').val();
            var MenuDescription = $('#txtMenu_Discription').val();
            var URL = $('#txtMenu_Url').val();
            var ParentID = $('#ddlParent_Menu').val();
            var OrderBy = $('#txtOrder_By').val();
            var IsActive = $('#cbActive').is(':checked');
            var BtnText = $('#btnSave').val();
            var id = '<%= Request.QueryString["ID"] %>';
            if (MenuName == "") {
                $('#txtMenu_Name-error').show();
                valid = false;
            }
            if (MenuDescription == "") {
                $('#txtMenu_Discription-error').show();
                valid = false;
            }
            if (URL == "") {
                $('#txtMenu_Url-error').show();
                valid = false;
            }
            if (ParentID == 0) {
                $('#ddlParent_Menu-error').show();
                valid = false;
            }
            if (OrderBy == "") {
                $('#txtOrder_By-error').show();
                valid = false;
            }
            var dataObj = {
                "MenuName": MenuName,
                "MenuDescription": MenuDescription,
                "URL": URL,
                "ParentID": ParentID,
                "OrderBy": OrderBy,
                "IsActive": IsActive,
                "BtnText": BtnText,
                "updateID": id,
            };
            var data = JSON.stringify({ data: dataObj });
            if (valid) {
                $.ajax({
                    type: "POST",
                    url: "Menu.aspx/btnSave_Click",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {

                        window.location.href = "/Modules/Administrator/MenuView.aspx";

                    },
                    error: function (xhr, status, error) {
                        console.log("XHR:", xhr);
                        console.log("Status:", status);
                        console.log("Error:", error);

                        if (xhr.responseText) {
                            alert("Server Error: " + xhr.responseText);
                        } else {
                            alert("AJAX Error: " + error);
                        }
                    }
                });
            }
        }
        function redirect() {
            window.location.href = "MenuView.aspx";
        }
    </script>
  

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        <div class="row">
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="txtMenu_Name">Menu Name *</label>
        <input type="text" id="txtMenu_Name" name="txtMenu_Name" class="form-control"  />
        <span id="txtMenu_Name-error" class="span_txt" style="display: none;color: red;">Please Enter Menu Name</span>
    </div>
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="txtMenu_Discription">Menu Description *</label>
        <input type="text" id="txtMenu_Discription" name="txtMenu_Discription" class="form-control"  />
        <span id="txtMenu_Discription-error" class="span_txt" style="display: none;color: red;">Please Enter Menu Description</span>
    </div>
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="txtMenu_Url">URL *</label>
        <input type="text" id="txtMenu_Url" name="txtMenu_Url" class="form-control"  />
        <span id="txtMenu_Url-error" class="span_txt" style="display: none;color: red;">Please Enter URL</span>
    </div>
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="ddlParent_Menu">Parent Menu *</label>
        <select id="ddlParent_Menu" name="ddlParent_Menu" class="form-control"></select>
        <span id="ddlParent_Menu-error" class="span_txt" style="display: none;color: red;">Please Select Parent Menu</span>
    </div>
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="txtOrder_By">Order By *</label>
        <input type="text" id="txtOrder_By" name="txtOrder_By" class="form-control"  />
        <span " id="txtOrder_By-error" class="span_txt" style=" display: none;color: red;">Please Enter Order By</span>
    </div>
    <div class="col-lg-2 col-md-6 col-sm-6">
        <label for="cbActive" class="ml-2 wdth">Active</label>
        <input type="checkbox" id="cbActive" name="cbActive" />
    </div>
</div>
    <div class="row">
    <div class="col-lg-8">
        <div class="row">
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-gray" onclick="redirect()"  value="View" />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <input type="button" class="btn btn-primry" onclick="savedata()" id="btnSave" value="Save" />
            </div>
        </div>
    </div>
</div>
</asp:Content>
