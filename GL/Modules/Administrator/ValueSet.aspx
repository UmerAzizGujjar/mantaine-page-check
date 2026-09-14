<%@ Page Title="Value Set Definition" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="ValueSet.aspx.cs" Inherits="PMS.Modules.Administrator.ValueSet" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />


    <style type="text/css">
        .vs-badge-yes { background: #2e7d32 !important; color: #fff !important; padding: 2px 10px !important; border-radius: 10px !important; font-size: 10px !important; font-weight: 700 !important; text-transform: uppercase; letter-spacing: 0.04em; display: inline-block; }
        .vs-badge-no  { background: #c5221f !important; color: #fff !important; padding: 2px 10px !important; border-radius: 10px !important; font-size: 10px !important; font-weight: 700 !important; text-transform: uppercase; letter-spacing: 0.04em; display: inline-block; }

        #<%= GRD.ClientID %> thead th,
        #<%= GRD.ClientID %> thead td,
        #<%= GRD.ClientID %> .dv-th th,
        #<%= GRD.ClientID %> .dv-th td {
            padding: 8px 10px !important;
            font-size: 10px !important;
            font-weight: 700 !important;
            line-height: 1.1 !important;
            min-height: 22px !important;
        }

        .dv-page-row {
            align-items: flex-start !important;
            margin-bottom: 60px !important;
        }
        .dv-page-row .pr-cards-column .pr-primary-settings {
            flex: 0 0 auto !important;
        }
        .dv-table-col {
            align-self: flex-start !important;
        }
        .dv-table-col .pr-primary-settings {
            display: flex !important;
            flex-direction: column !important;
            height: 100% !important;
            max-height: 300px !important;
            min-height: 0 !important;
        }
        .dv-table-col .dv-table-wrap {
            flex: 1 1 0 !important;
            min-height: 0 !important;
            max-height: 200px !important;
            overflow-y: auto !important;
            overflow-x: auto !important;
        }

        .pr-primary-settings .checkbox {
            margin: 0 !important;
            padding-top: 4px;
        }
        .pr-primary-settings .checkbox label {
            font-size: 12px !important;
            font-weight: 700 !important;
            text-transform: uppercase;
            letter-spacing: 0.04em;
            color: #555;
            margin-bottom: 0 !important;
            padding-left: 0 !important;
            display: inline-flex !important;
            align-items: center !important;
            gap: 8px;
            line-height: 16px;
            min-height: 16px;
            vertical-align: middle;
        }
        .pr-primary-settings .checkbox label i {
            color: #2e7d32;
            line-height: 1;
            vertical-align: middle;
        }
        .pr-primary-settings .checkbox label img,
        .pr-primary-settings .checkbox label input[type="checkbox"] {
            vertical-align: middle !important;
            margin: 0 6px 0 0 !important;
            position: relative;
            top: 0;
        }
    </style>

   <script type="text/javascript">

       function showVsToast(icon, title) {
           if (typeof Swal !== 'undefined') {
               Swal.fire({
                   icon: icon,
                   title: title,
                   showConfirmButton: false,
                   timer: 1800,
                   customClass: {
                       popup: 'swal-big-popup',
                       title: 'swal-big-title',
                       htmlContainer: 'swal-big-text'
                   }
               });
           }
       }

       function clearVsForm() {
           $("#<%= txtName.ClientID %>").val('');
        $("#<%= txtDescription.ClientID %>").val('');
        $("#<%= txtMaxLength.ClientID %>").val('');
        $("#<%= ddlDataType.ClientID %>").val('Numeric');
        $("#<%= chkActive.ClientID %>").prop('checked', true);
        $("#<%= hfValueSet_ID.ClientID %>").val('');
        $("#<%= btnSave.ClientID %>").val('Save');
        $("#<%= txtName.ClientID %>").focus();
    }

    function confirmInactive(button) {

        // Get ASP.NET generated postback
        var postBackUrl = button.getAttribute("href");

        Swal.fire({
            icon: 'warning',
            title: 'Are you sure?',
            text: 'Are you sure you want to mark this record as inactive?',
            showCancelButton: true,
            confirmButtonText: 'Yes, Inactive',
            cancelButtonText: 'No',
            reverseButtons: true
        }).then(function (result) {

            if (result.isConfirmed) {

                // Continue original ASP.NET postback
                if (postBackUrl) {
                    eval(postBackUrl.replace(/^javascript:/, ''));
                }
            }
        });

        // Stop normal postback
        return false;
    }

    function filterVSTable() {
        var grid = document.getElementById('<%= GRD.ClientID %>');

           if (!grid || !grid.tBodies || grid.tBodies.length === 0)
               return;

           var rows = grid.tBodies[0].rows;

           var filter = document
               .getElementById('txtSearchVS')
               .value
               .toLowerCase()
               .trim();

           for (var i = 0; i < rows.length; i++) {

               if (filter === '') {
                   rows[i].style.display = '';
                   continue;
               }

               var nameCell = (rows[i].cells[0]
                   ? rows[i].cells[0].textContent
                   : '').toLowerCase();

               var descCell = (rows[i].cells[1]
                   ? rows[i].cells[1].textContent
                   : '').toLowerCase();

               var match =
                   nameCell.indexOf(filter) > -1 ||
                   descCell.indexOf(filter) > -1;

               rows[i].style.display = match ? '' : 'none';
           }
     }

       function confirmReactivate(button) {
           var postBackUrl = button.getAttribute("href");

           Swal.fire({
               icon: 'question',
               title: 'Are you sure?',
               text: 'Are you sure you want to reactivate this record?',
               showCancelButton: true,
               confirmButtonText: 'Yes, Reactivate',
               cancelButtonText: 'No',
               reverseButtons: true
           }).then(function (result) {
               if (result.isConfirmed) {
                   if (postBackUrl) {
                       eval(postBackUrl.replace(/^javascript:/, ''));
                   }
               }
           });

           return false; // stop normal postback
       }

</script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Meta Bar -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-list-alt"></i> Value Set Definition</span>
        </div>
        <div class="meta-right">
        </div>
    </div>

    <!-- Row 1 : Form (left) + Table (right) -->
    <div class="row dv-page-row">
        <div class="col-md-12">
            <div class="row">
                <!-- LEFT: Add / Edit form -->
                <div class="col-lg-6 col-md-12 pr-cards-column">
                    <div class="pr-primary-settings">
                        <h5 class="pr-section-title"><i class="fa fa-plus-square"></i> Add / Edit Value Set</h5>
                        <asp:Label ID="lblMessage" runat="server" CssClass="dv-message" Style="display:none;" />
                        <asp:HiddenField ID="hfValueSet_ID" runat="server" />
                        <asp:HiddenField ID="hfSystem" runat="server" Value="false" />

                        <div class="row">
                            <div class="col-md-6">
                                <label for="<%= txtName.ClientID %>">Name <span class="dv-required">*</span></label>
                                <asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="50" placeholder="e.g. Gender" />
                            </div>
                            <div class="col-md-6">
                                <label for="<%= txtDescription.ClientID %>">Description <span class="dv-required">*</span></label>
                                <asp:TextBox ID="txtDescription" runat="server" CssClass="form-control" MaxLength="50" placeholder="e.g. Patient Gender Codes" />
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6">
                                <label for="<%= txtMaxLength.ClientID %>">Max Length <span class="dv-required">*</span></label>
                                <asp:TextBox ID="txtMaxLength" runat="server" CssClass="form-control" TextMode="Number" min="1" placeholder="e.g. 50" />
                            </div>
                            <div class="col-md-6">
                                <label for="<%= ddlDataType.ClientID %>">Data Type <span class="dv-required">*</span></label>
                                <asp:DropDownList runat="server" ID="ddlDataType" CssClass="form-control">
                                    <asp:ListItem Value="Numeric">Numeric</asp:ListItem>
                                    <asp:ListItem Value="Text">Text</asp:ListItem>
                                </asp:DropDownList>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <div class="checkbox" style="margin-top: 8px;">
                                    <label>
                                        <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                                         Active
                                    </label>
                                </div>
                            </div>
                        </div>

                        <div class="dv-action-row">
                            <div class="dv-action-group">
                                <asp:Button CssClass="dv-btn dv-btn-primary" SkinID="Custom"
                                    Text="Save" ID="btnSave" runat="server" OnClick="btnSave_Click" />
                                <input type="button" class="dv-btn dv-btn-primary" value="Clear" onclick="clearVsForm();" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- RIGHT: Records table -->
                <div class="col-lg-6 col-md-12 pr-cards-column dv-table-col">
                    <div class="pr-primary-settings">
                        <div style="display: flex; justify-content: space-between; align-items: center; gap: 12px; margin: 0 -20px 10px -20px; padding: 6px 20px; background: linear-gradient(90deg, #438eb910, #fff); border-bottom: 1px solid #438eb930; border-radius: 6px 6px 0 0;">
                            <h5 class="pr-section-title" style="margin: 0; padding: 0; background: none; border: none; flex: 0 0 auto; font-size: 12px;"><i class="fa fa-table"></i> Value Set Records</h5>
                            <input type="text" id="txtSearchVS" class="form-control" placeholder="Search records..." style="width: 200px; flex: 0 0 200px; height: 26px; padding: 2px 8px; font-size: 11px;" onkeyup="filterVSTable();" />
                        </div>
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <div class="dv-table-wrap">
                                    <asp:GridView ID="GRD" runat="server" SkinID="Custom" EmptyDataText="No value sets found" Width="100%" AutoGenerateColumns="False"
                                        DataKeyNames="ValueSet_ID"
                                        Style="margin-right: 1px"
                                        OnRowCommand="GRD_RowCommand"
                                        CellPadding="0" CellSpacing="0" GridLines="None"
                                        CssClass="dv-table"
                                        HeaderStyle-CssClass="dv-th"
                                        RowStyle-CssClass="dv-tr"
                                        AlternatingRowStyle-CssClass="dv-tr-alt"
                                        UseAccessibleHeader="True">
                                        <Columns>
                                            <asp:TemplateField HeaderText="Name">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblVSName" runat="server" Text='<%# Bind("ValueSet_Name") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Description">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblVSDesc" runat="server" Text='<%# Bind("ValueSet_Description") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Max Len">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblVSMax" runat="server" Text='<%# Bind("Max_Length") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" Width="80px" />
                                                <ItemStyle HorizontalAlign="Left" Width="80px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Type">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblVSType" runat="server" Text='<%# Bind("Data_Type") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" Width="90px" />
                                                <ItemStyle HorizontalAlign="Left" Width="90px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Active">
                                                <ItemTemplate>
                                                    <span class='<%# (Eval("Active") != null && (bool)Eval("Active")) ? "vs-badge-yes" : "vs-badge-no" %>'>
                                                        <%# (Eval("Active") != null && (bool)Eval("Active")) ? "Yes" : "No" %>
                                                    </span>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Center" Width="90px" />
                                                <ItemStyle HorizontalAlign="Center" Width="90px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Actions">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lnkEdit" runat="server" CommandName="EditRec" CommandArgument='<%# Eval("ValueSet_ID") %>'
                                                        CssClass="dv-action-btn" ToolTip="Edit record">
                                                        <i class="fa fa-pencil"></i>
                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="lnkInactive" runat="server"
                                                        CommandName="InactiveRec"
                                                        CommandArgument='<%# Eval("ValueSet_ID") %>'
                                                        CssClass="dv-action-btn"
                                                        ToolTip="Mark as inactive"
                                                        Visible='<%# (bool)Eval("Active") %>'
                                                        OnClientClick="return confirmInactive(this);">

                                                        <i class="fa fa-toggle-on"></i>

                                                    </asp:LinkButton>
                                                    <asp:LinkButton ID="lnkReactivate" runat="server"
                                                        CommandName="ReactivateRec"
                                                        CommandArgument='<%# Eval("ValueSet_ID") %>'
                                                        CssClass="dv-action-btn" ToolTip="Reactivate"
                                                        Visible='<%# !(bool)Eval("Active") %>'
                                                        OnClientClick="return confirmReactivate(this);">   <!-- ADD THIS -->

                                                         <i class="fa fa-toggle-off"></i>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Center" Width="140px" />
                                                <ItemStyle HorizontalAlign="Center" Width="140px" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </ContentTemplate>
                              <Triggers>
        <asp:PostBackTrigger ControlID="GRD" />
    </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
