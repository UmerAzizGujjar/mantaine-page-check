<%@ Page Title="Basic Data Definations" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="DataValue.aspx.cs" Inherits="PMS.DataValue" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/Pakred/css/CustomCss/Datavalue.css" rel="stylesheet" />

    <script type="text/javascript" clientidmode="Predictable">
        $(document).ready(function () {
            $("select").searchable({
            });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <div class="row">
            <div class="col-lg-2">
                <asp:Label ID="Label2" Text="Value Set Name:" runat="server" />
                <asp:DropDownList runat="server" ID="ddlValueSet" AutoPostBack="true" OnSelectedIndexChanged="ddlValueSet_SelectedIndexChanged" AppendDataBoundItems="True">
                </asp:DropDownList>
            </div>
        </div>
        <div class="row">
            <div class="col-lg-8">
                <div class="row">
                    <div class="col-lg-2">
                        <asp:Button Text="Save" CssClass="btn-primry" runat="server" ID="btnSave" OnClick="btnSave_Click" />

                    </div>
                </div>
            </div>

        </div>

        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
            <ContentTemplate>
                <div class="table-container">
                    <table class="table table-bordered" style="color: white !important">
                        <thead style="color: white !important">
                            <tr>
                                <td class="white">Name
                                </td>
                                <td class="white">Description
                                </td>
                                <td class="white">User Value 
                                </td>
                                <td class="white">
                                    <asp:Label ID="roomNo" runat="server" Text="Segment 2" />
                                </td>
                            </tr>
                        </thead>
                        <tr>
                            <td>
                                <asp:TextBox ID="txtDataValue_Name" runat="server" Width="90px" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtDataValue_Description" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtSegment1" runat="server" />
                            </td>
                            <td>
                                <asp:TextBox ID="txtSegment2" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Button CssClass="btn-primry" Text="Add" ID="btnAdd" runat="server" OnClick="btnAdd_Click" />
                                &nbsp;
                            &nbsp;
                           
                            </td>
                            <td>
                                <asp:Button Text="Delete" CssClass="btn-primry" ID="btnDelete" runat="server" OnClick="btnDelete_Click" />
                            </td>
                            <td colspan="2">
                                <asp:Label ID="lblMessage" runat="server" ForeColor="Red" />
                                <asp:HiddenField ID="hfDataValue_ID" runat="server" />
                                <asp:HiddenField ID="hfData_Type" runat="server" />
                                <asp:HiddenField ID="HfMax_Length" runat="server" />
                                <asp:HiddenField ID="Trans_Type" runat="server" />
                            </td>
                        </tr>

                    </table>
                </div>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
            </Triggers>

        </asp:UpdatePanel>


        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
            <ProgressTemplate>
                <div class="loadingimage">
                    <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px" />
                </div>
            </ProgressTemplate>
        </asp:UpdateProgress>
        <asp:UpdatePanel ID="UpdatePanel2" runat="server">
            <ContentTemplate>
                <asp:GridView ID="GRD" runat="server" EmptyDataText="No record" Width="400px" AutoGenerateColumns="False"
                    Style="margin-right: 1px" OnSelectedIndexChanging="GRD_SelectedIndexChanging"
                    CellPadding="4">
                    <Columns>
                        <%--<asp:CommandField ShowSelectButton="True" />--%>
                        <asp:TemplateField>
                            <ItemTemplate>
                                <asp:LinkButton ID="lbselect" CommandName="select" runat="server">Select</asp:LinkButton>
                            </ItemTemplate>
                            <ItemStyle HorizontalAlign="Center" Width="50px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Index" SortExpression="Index" Visible="False">
                            <ItemTemplate>
                                <asp:Label ID="lblIndex" runat="server" Text='<%# Bind("Index") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="DataValue_ID" SortExpression="DataValue_ID" Visible="False">
                            <ItemTemplate>
                                <asp:Label ID="lblDataValue_Id" runat="server" Text='<%# Bind("DataValue_ID") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Name" SortExpression="DataValue_Name">
                            <ItemTemplate>
                                <asp:Label ID="lblDataValue_Name" runat="server" Text='<%# Bind("DataValue_Name") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle Width="200px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description" SortExpression="DataValue_Description">
                            <ItemTemplate>
                                <asp:Label ID="lblDataValue_Description" runat="server" Text='<%# Bind("DataValue_Description") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle Width="300px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="User Value" SortExpression="Segment1">
                            <ItemTemplate>
                                <asp:Label ID="lblSegment1" runat="server" Text='<%# Bind("Segment1") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle Width="300px" />
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Segment 2" SortExpression="Segment2">
                            <ItemTemplate>
                                <asp:Label ID="lblSegment2" runat="server" Text='<%# Bind("Segment2") %>'></asp:Label>
                            </ItemTemplate>
                            <HeaderStyle HorizontalAlign="Left" />
                            <ItemStyle Width="300px" />
                        </asp:TemplateField>

                    </Columns>
                </asp:GridView>
            </ContentTemplate>
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="ddlValueSet" EventName="SelectedIndexChanged" />
                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
            </Triggers>
        </asp:UpdatePanel>

    </div>
</asp:Content>
