<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="WebForm1.aspx.cs" Inherits="PMS.WebForm1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="http://localhost:49792/Styles/Site.css" rel="stylesheet" type="text/css" />
    <script src="http://localhost:18121/Scripts/jquery-1.8.0.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#checkbox1").attr("change", function () {
                    var isCheck = $("#checkbox1").attr("checked") ? true : false;
                    if (!isCheck)
                        $("#txtToggle").attr("disabled", "disabled");
                    else
                        $("#txtToggle").removeAttr("disabled");
                });

                $("#checkbox1").click(function () {
                    var isCheck = $("#checkbox1").attr("checked") ? true : false;
                    if (!isCheck)
                        $("#txtToggle").attr("disabled", "disabled");
                    else
                        $("#txtToggle").removeAttr("disabled");                
                });
            });
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
    </div>
    <asp:Button Text="Insert dummy data" ID="btn1" runat="server" OnClick="btn1_Click" />
    <br />
        <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <asp:UpdatePanel ID="UpdatePanel1" runat="server">    
    <ContentTemplate>
    <asp:CheckBox ID="checkbox1" Text="check box" runat="server" />
    <asp:TextBox ID="txtToggle" Text="Some value" runat="server" />
    <br />
    <asp:Button Text="Toggle checkbox" ID="btnToggleCheckBox" runat="server" OnClick="btnToggleCheckBox_Click" />
    </ContentTemplate>
    <Triggers>        
        <asp:AsyncPostBackTrigger ControlID="btnToggleCheckBox" EventName="Click" />
    </Triggers>
    </asp:UpdatePanel>
    </form>
</body>
</html>
