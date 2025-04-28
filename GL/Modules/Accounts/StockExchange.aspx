<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StockExchange.aspx.cs" Inherits="PMS.StockExchange" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
    <div>
         <div style="width: 90%">
       <h1>Stock Exchange</h1>
        
        <table style="padding: 20px">

            <tr>
                <td>
                    <asp:Label ID="lblRoute_Name" runat="server" Text="St.No *"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtRoute_Name" runat="server" ></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rvValidator1" runat="server" ControlToValidate="txtRoute_Name" Text="*"></asp:RequiredFieldValidator>
                </td>
                <td class="mg">
                     <asp:Label ID="lbDestination" runat="server" Text="Destination *"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDestination" runat="server"></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rvValidator2" runat="server" ControlToValidate="txtDestination" Text="*"></asp:RequiredFieldValidator>
                </td>
                <td>
                    <asp:Label ID="lblRoute_ID" runat="server" Visible="false"></asp:Label>
                   
                </td>
            </tr>
              <tr>
                <td>
                    <asp:Label ID="lblRoute_Type" runat="server" Text="Route Type"></asp:Label>
                </td>
                <td>
                    <asp:DropDownlist ID="ddlRoute_Type" runat="server" AppendDataBoundItems="true" Width="173px" ></asp:DropDownlist>
                   <%--<asp:RequiredFieldValidator ID="rvValidator6" runat="server" ControlToValidate="ddlRoute_Type" Text="*"></asp:RequiredFieldValidator>--%>
                </td>
             

            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblStart_Time" runat="server" Text="Start Time *"></asp:Label>

                </td>
                <td>
                    <asp:TextBox ID="txtStart_Time" runat="server" Width="100px" ></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rvValidator8" runat="server" ControlToValidate="txtStart_Time" Text="*"></asp:RequiredFieldValidator>

                </td>

                <td class="mg">
                    <asp:Label ID="lblEnd_Time" runat="server" Text="End Time *"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtEnd_Time" runat="server" Width="100px" ></asp:TextBox>
                    <asp:RequiredFieldValidator ID="rvValidator9" runat="server" ControlToValidate="txtEnd_Time" Text="*"></asp:RequiredFieldValidator>
                </td>
            </tr>
             <tr>
                <td>
                    <asp:Label ID="lblStop_Name" runat="server" Text="Bus Stop Name"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtStop_Name" runat="server"></asp:TextBox>
                    <%--<asp:RequiredFieldValidator ID="rfvStop_Name" runat="server" ControlToValidate="txtStop_Name" Text="*"></asp:RequiredFieldValidator>--%>
                </td>
                  <td class="mg">
                    <asp:Label ID="lblStop_Time" runat="server" Text="Stop Time"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtStop_Time" runat="server" Width="100px" ></asp:TextBox>
                    <%--<asp:RequiredFieldValidator ID="rfvStop_Time" runat="server" ControlToValidate="txtStop_Time" Text="*"></asp:RequiredFieldValidator>--%>
                </td>
               
              </tr>
              
        </table>

        </div>
    </div>
    </form>
</body>
</html>
