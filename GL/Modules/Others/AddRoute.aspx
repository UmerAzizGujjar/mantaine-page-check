<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AddRoute.aspx.cs" Inherits="PMS.AddRoute" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
     <script type="text/javascript" src="../Scripts/jquery.tokeninput.js"></script>
    <link rel="stylesheet" type="text/css" href="../Styles/jquery.datetimepicker.css"/>
    <script src="../Scripts/jquery.datetimepicker.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(function () {
            Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
                $("#ctl00_MainContent_txtStop_Time").datetimepicker({ datepicker: false, format: 'H:i:s' });
                $("#ctl00_MainContent_txtStart_Time").datetimepicker({ datepicker: false, format: 'H:i:s' });
                $("#ctl00_MainContent_txtEnd_Time").datetimepicker({ datepicker: false, format: 'H:i:s' });
            });
        });

</script>

       <style type="text/css" >
        .mg {
           padding-left: 20px;
           /*..*/
        }
        .auto-style1 {
            height: 24px;
        }
        .auto-style2 {
            padding-left: 20px;
            height: 24px;
        }
    </style>

</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
        
      <div style="width: 90%">
       <h1>Add Route</h1>

        <table style="padding: 20px">

            <tr>
                <td>
                    <asp:Label ID="lblRoute_Name" runat="server" Text="Route Name *"></asp:Label>
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
                <td>
                    <asp:Button ID="btnAdd_Stop" runat="server" Width="100px" Text="Add Stop" OnClick="btnAdd_Stop_Click" />
                </td>
              </tr>
              
        </table>

          <table>
               <tr>
                            <td colspan="2">
                                <div style="padding-left:60px; float: left">
                                    <div>
                                        <asp:UpdatePanel runat="server" ID="upGridList" UpdateMode="Always">
                                            
                                            <ContentTemplate>
                                                <asp:GridView ID="GRD" runat="server" BorderStyle="None" AutoGenerateColumns="False"
                                                    CellPadding="3" Style="z-index: -1" OnRowDataBound="GRD_RowDataBound" OnRowDeleting="GRD_RowDeleting">
                                                    <Columns>                                                 
                                                      
                                                        <asp:CommandField ShowDeleteButton="True" ButtonType="Button" />
                                                       <%-- <asp:BoundField DataField="Route_ID" HeaderText="Route ID">
                                                            <ItemStyle Width="200px" />
                                                        </asp:BoundField>--%>
                                                        <asp:BoundField DataField="Stop_Name" HeaderText="Stop Name">
                                                            <ItemStyle Width="180px" />
                                                        </asp:BoundField>
                                                        <asp:BoundField DataField="Stop_Time" HeaderText="Stop Time">
                                                            <ItemStyle Width="180px" />
                                                        </asp:BoundField>
                                                    </Columns>
                                                </asp:GridView>
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </div>
                                </div>
                            </td>
                        </tr>
              </table>

    </div>

     <div style="padding-top: 45px">
         <table>

             <tr>
                 <td>
                     <asp:Button ID="btnBack" runat="server" Width="100px" Text="Back" CausesValidation="false" PostBackUrl="~/RouteView.aspx" />
                     &nbsp;
                     <asp:Button ID="btnSave" runat="server" Width="100px" Text="Add Route" OnClick="btnSave_Click" />
                     &nbsp;
                     <asp:Button ID="btnClear" runat="server" Width="100px" Text="Reset" CausesValidation="false" OnClick="btnClear_Click"  />
                    
                 </td>
                
             </tr>

             <tr>
                 <td>
                     <asp:Label ID="lblMessage" runat="server"></asp:Label>
                 </td>
             </tr>
         </table>
     </div>
</asp:Content>
