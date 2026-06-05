<%@ Page Title="User's Roles" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Roles.aspx.cs" Inherits="PMS.Account.Roles" Theme="Default_Theme" %>

<%@ Register Src="~/LookupControl.ascx" TagName="LookupControl" TagPrefix="uc1" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <link href="../../wwwroot/lib/sweetalert/swalalert.css" rel="stylesheet" />
    <style type="text/css">
       /* 1. Force perfect vertical alignment inside the TreeView tables */
#ctl00_MainContent_tvMenus td {
    vertical-align: middle !important;
    line-height: normal !important;
}

#ctl00_MainContent_tvMenus img {
    vertical-align: middle !important;
    display: inline-block !important;
}

/* 2. Override your global 20% checkbox width specifically for the TreeView */
#ctl00_MainContent_tvMenus input[type="checkbox"] {
    width: auto !important;           /* Kills the 20% width rule */
    vertical-align: middle !important;
    margin: 0 4px 0 0 !important;     /* Small gap between checkbox and text */
    display: inline-block !important;
}

/* 3. Align the text labels */
#ctl00_MainContent_tvMenus a, 
#ctl00_MainContent_tvMenus span {
    vertical-align: middle !important;
    display: inline-block !important;
    margin-top: 1px !important;       /* Minor optical adjustment */
}
/* 4. Fix Child Node Indentation (Horizontal Alignment) - CORRECTED */
#ctl00_MainContent_tvMenus table {
    width: auto !important; /* Stops modern CSS from stretching nested tables */
}

/* We target ONLY the empty spacer divs used for indentation, 
   allowing the wrapper divs to expand/collapse normally */
#ctl00_MainContent_tvMenus td > div {
    box-sizing: content-box !important; 
}
        input[type="text"] {
        width: 300px !important;
    margin-left: 10px;
}
        select{
                width: 300px !important;
margin-left: 10px;
        }
        #ctl00_MainContent_btnSave,#ctl00_MainContent_btnBack{
            width:100px !important;

            margin-top:10px;
        }

        .card {
            border: 1px solid #ccc;
            transition: all 0.3s ease;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            width: 460px;
        }

            .card:hover {
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
            }
    </style>
    <script type="text/javascript">

        $(document).ready(function () {
            //fillDepts();
            $('#ddlDepartment').removeAttr('style');
            $('#ctl00_MainContent_txtRoleId').removeAttr('style');
            $('#ctl00_MainContent_txtRoleName').removeAttr('style');
            $('#ctl00_MainContent_btnBack').removeAttr('style');
            
            
        });
        function fillDepts() {

            PageMethods.FillDepts(function (data) {
                var parsedData = JSON.parse(data);
                var options = '<option value="">Please Select</option>';
                $.each(parsedData, function (key, value) {
                    options += '<option value=' + value.DataValue_Name + '> ' + value.DataValue_Description + '</option>';
                });

                $('#ddlDepartment').html(options);

            }, function (exec) { alert(exec.getmessage()); })
        }

        //************************** Treeview Parent-Child check behaviour ****************************// 
        function OnTreeClick(evt) {
            var src = window.event != window.undefined ? window.event.srcElement : evt.target;
            var isChkBoxClick = (src.tagName.toLowerCase() == "input" && src.type == "checkbox");
            if (isChkBoxClick) {
                var parentTable = GetParentByTagName("table", src);
                var nxtSibling = parentTable.nextSibling;
                if (nxtSibling && nxtSibling.nodeType == 1)//check if nxt sibling is not null & is an element node
                {
                    if (nxtSibling.tagName.toLowerCase() == "div") //if node has children
                    {
                        //check or uncheck children at all levels
                        CheckUncheckChildren(parentTable.nextSibling, src.checked);
                    }
                }
                //check or uncheck parents at all levels
                CheckUncheckParents(src, src.checked);
            }
        }
        function CheckUncheckChildren(childContainer, check) {
            var childChkBoxes = childContainer.getElementsByTagName("input");

            // childChkBoxes[0].parentNode.checked = check;
            var childChkBoxCount = childChkBoxes.length;
            for (var i = 0; i < childChkBoxCount; i++) {
                childChkBoxes[i].checked = check;
            }
        }
        function CheckUncheckParents(srcChild, check) {
            console.log(srcChild);
            var parentDiv = GetParentByTagName("div", srcChild);
            var parentNodeTable = parentDiv.previousSibling;
            //srcChild.parentNode.checked = true;

            if (parentNodeTable) {
                var checkUncheckSwitch;

                if (check) //checkbox checked
                {
                    var isAllSiblingsChecked = AreAllSiblingsChecked(srcChild);
                    if (isAllSiblingsChecked)
                        checkUncheckSwitch = true;
                    else
                        checkUncheckSwitch = false; //do not need to check parent if any child is not checked
                }
                else //checkbox unchecked
                {
                    //checkUncheckSwitch = false;
                    checkUncheckSwitch = true;
                }

                var inpElemsInParentTable = parentNodeTable.getElementsByTagName("input");
                if (inpElemsInParentTable.length > 0) {
                    var parentNodeChkBox = inpElemsInParentTable[0];
                    parentNodeChkBox.checked = checkUncheckSwitch;
                    //do the same recursively
                    CheckUncheckParents(parentNodeChkBox, checkUncheckSwitch);
                }
            }
        }
        function AreAllSiblingsChecked(chkBox) {
            var parentDiv = GetParentByTagName("div", chkBox);
            var childCount = parentDiv.childNodes.length;
            for (var i = 0; i < childCount; i++) {
                if (parentDiv.childNodes[i].nodeType == 1) //check if the child node is an element node
                {
                    if (parentDiv.childNodes[i].tagName.toLowerCase() == "table") {
                        var prevChkBox = parentDiv.childNodes[i].getElementsByTagName("input")[0];
                        //if any of sibling nodes are not checked, return false
                        if (prevChkBox.checked) {
                            return true;
                        }
                    }
                }
            }
            return false;
        }
        //utility function to get the container of an element by tagname
        function GetParentByTagName(parentTagName, childElementObj) {
            var parent = childElementObj.parentNode;
            while (parent.tagName.toLowerCase() != parentTagName.toLowerCase()) {
                parent = parent.parentNode;
            }
            return parent;
        }
    </script>
    <script type="text/javascript">
        //validate form input controls                
        function fn_init() {
            $("#aspnetForm").validate({
                rules: {
            '<%= txtRoleName.UniqueID %>': {
                        required: true
                    }
                }
            });
        }


        var prm = Sys.WebForms.PageRequestManager.getInstance();
        prm.add_initializeRequest(onEachRequest)


        function onEachRequest(sender, args) {
            if ($("#aspnetForm").valid() == false) {
                args.set_cancel(true);
            }
        }
        function _valid() {
            var p = Sys.WebForms.PageRequestManager.getInstance();
            p.add_initializeRequest(onOtherRequest);
        }
        function onOtherRequest(sender, args) {
            args.set_cancel(false);
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">

        <div class="col-lg-1"></div>

        <div class="col-lg-5">
            <div class="card">
    <div class="card-body">
        <table style="padding: 20px; width: 100%">
            <tr>
                <td>
                    <asp:Label ID="Label3" Text="Role ID" runat="server" />
                </td>
                <td>
                    <asp:TextBox ID="txtRoleId" Text="(New)" runat="server" Enabled="False" />
                </td>
                <td></td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="Label1" Text="Role Name *" runat="server" />
                </td>
                <td>
                    <asp:TextBox ID="txtRoleName" Text="" runat="server" />
                    <asp:HiddenField ID="hdfOldRoleName" runat="server" />
                </td>
                <td>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="Label2" Text="Department" runat="server" />
                    &nbsp
                </td>
                <td>
                    <asp:DropDownList runat="server" Style="width: 100% !important" ID="ddlDepartment" AppendDataBoundItems="true" ClientIDMode="Static" CausesValidation="false"></asp:DropDownList>
                </td>
            </tr>

        </table>
        <div class="row">
            <div class="col-lg-3 col-md-4 col-sm-6" >
                <asp:Button Text="Back" CssClass="btn btn-gray" ID="btnBack" PostBackUrl="~/Modules/Accounts/RolesView.aspx" CausesValidation="false" runat="server"  />
            </div>
            <div class="col-lg-2 col-md-4 col-sm-6">
                <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" CssClass="btn btn-primry"  />
            </div>
        </div>
    </div>
</div>
        </div>
        <div class="col-lg-5">
            <div class="card">
                <div class="card-header" style="font-weight:bold; font-size:2rem">
                    Menu Rights:
                </div>
    <div class="card-body">

        <asp:TreeView ID="tvMenus" runat="server" ShowLines="True" ExpandDepth="0"
            LineImagesFolder="~/TreeLineImages" ShowCheckBoxes="All" onclick="OnTreeClick(event)">
        </asp:TreeView>

        <asp:Label ID="lblMessage" runat="server"   />
    </div>
</div></div>

        <div class="col-lg-1"></div>
    </div>
    
    


</asp:Content>
