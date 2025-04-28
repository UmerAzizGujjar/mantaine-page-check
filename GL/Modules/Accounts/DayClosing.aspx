<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="DayClosing.aspx.cs" Inherits="PMS.DayClosing" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript">
        $(function(){
            $("#txtDate").datepicker({ dateFormat: 'mm/dd/yy' });
        });
    
        function ProcessDay() {
            var date = $("#txtDate").val();
            

            $.ajax({
                type: "POST",
                url: "DayClosing.aspx/ProcessDay",
                data: JSON.stringify({
                    'date': date
                }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    alert('Voucher # ' + response.d + ' Inserted');
                    
                },
                error: function (e,x) {
                    alert(e.responseJSON.Message);
                }
            });

        }
        
        
    </script>




</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <input type="text" name="txtDate" value="<%=DateTime.Now.Date.ToString(AppConfig.DateFormat)%>" id="txtDate" />
    <br />
    <% if(OracleConnected==true){ %>
            <input type="button" name="name" value="Process" onclick="ProcessDay();" />
    <%} %>
    <br />
    <asp:Label ID="lblMessage" Text="" runat="server" />
</asp:Content>
