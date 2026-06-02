<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ReportViewer.aspx.cs" Inherits="PMS.ReportViewer" EnableViewState="true" %>

<%@ Register Assembly="CrystalDecisions.Web, Version=13.0.2000.0, Culture=neutral, PublicKeyToken=692fbea5521e1304" Namespace="CrystalDecisions.Web" TagPrefix="CR" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
   <%-- <script src='<%=ResolveUrl("~/crystalreportviewers13/js/crviewer/crv.js")%>' type="text/javascript"></script>--%>
</head>
<body>
    <form id="form1" runat="server">
        <div id="dvReport">
            <CR:CrystalReportViewer ID="CrystalReportViewer1" runat="server" PrintMode="Pdf" AutoDataBind="true" OnDisposed="CrystalReportViewer1_Disposed" OnUnload="CrystalReportViewer1_Unload" BestFitPage="True" SeparatePages="True" ViewStateMode="Inherit" ValidateRequestMode="Inherit" />
        </div>
        
    </form>
</body>
</html>