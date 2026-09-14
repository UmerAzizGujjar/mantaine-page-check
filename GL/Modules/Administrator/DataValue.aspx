<%@ Page Title="Basic Data Definations" Language="C#" MasterPageFile="~/Site.master" AutoEventWireup="true"
    CodeBehind="DataValue.aspx.cs" Inherits="PMS.DataValue" Theme="Default_Theme" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/vendor.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/Datavalue.css" rel="stylesheet" />
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/tablestyle.css" rel="stylesheet" />

    <style type="text/css">
        .dv-select-wrap .select2-container { width: 100% !important; }
        .dv-select-wrap .select2-container--default .select2-selection { width: 100% !important; box-sizing: border-box !important; }
        .dv-select-wrap .select2-dropdown { width: auto !important; min-width: 100% !important; box-sizing: border-box !important; }
        .dv-select-wrap .select2-search--dropdown { width: 100% !important; padding: 4px !important; box-sizing: border-box !important; }
        .dv-select-wrap .select2-search--dropdown .select2-search__field { width: 100% !important; box-sizing: border-box !important; padding: 4px 8px !important; appearance: none !important; -webkit-appearance: none !important; }
        .dv-select-wrap .select2-search__field::-webkit-search-decoration,
        .dv-select-wrap .select2-search__field::-webkit-search-cancel-button,
        .dv-select-wrap .select2-search__field::-webkit-search-results-button,
        .dv-select-wrap .select2-search__field::-webkit-search-results-decoration {
            -webkit-appearance: none !important;
            display: none !important;
        }
        .dv-select-wrap .select2-results__options { width: 100% !important; }

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

        .pr-primary-settings .dv-table-wrap {
            height: 600px !important;
            max-height: 600px !important;
            overflow-y: auto !important;
            overflow-x: auto !important;
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
            max-height: 480px !important;
            min-height: 0 !important;
        }
        .dv-table-col .dv-table-wrap {
            flex: 1 1 0 !important;
            min-height: 0 !important;
            max-height: 240px !important;
            overflow-y: auto !important;
            overflow-x: auto !important;
        }

        .select2-search--dropdown .select2-search__field {
    
              width: 100% !important;
        }
    </style>

    <script type="text/javascript" clientidmode="Predictable">
        $(document).ready(function () {
            $("#<%= ddlValueSet.ClientID %>").select2({
                width: '100%',
                placeholder: 'Select a value set...',
                allowClear: false,
                dropdownAutoWidth: false
            });

            var $ddl = $("#<%= ddlValueSet.ClientID %>");
            function syncMeta() {
                var txt = $ddl.find('option:selected').text();
                $('#dvValueSetName').text(txt || '---');
            }
            $ddl.on('change', syncMeta);
            syncMeta();

            $("#<%= btnAdd.ClientID %>").text('Add');
        });

        function showDvToast(icon, title) {
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

        function clearAddFields() {
            $("#<%= txtDataValue_Name.ClientID %>").val('');
            $("#<%= txtDataValue_Description.ClientID %>").val('');
            $("#<%= txtSegment1.ClientID %>").val('');
            $("#<%= txtSegment2.ClientID %>").val('');
            $("#<%= hfDataValue_ID.ClientID %>").val('');
            $("#<%= btnAdd.ClientID %>").val('Add');
            $("#<%= txtDataValue_Name.ClientID %>").focus();
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <!-- Meta Bar -->
    <div class="pr-meta-bar">
        <div class="meta-left">
            <span class="meta-title"><i class="fa fa-list-alt"></i> Data Value Definition</span>
        </div>
        <div class="meta-right">
            <div class="meta-badge">
                <span class="badge-label">Active Set:</span>
                <span class="badge-value" id="dvValueSetName">---</span>
            </div>
        </div>
    </div>

    <!-- Row 1 : Left col (Search + Form stacked) + Right col (Table) -->
    <div class="row dv-page-row">
        <div class="col-md-12">
            <div class="row">
                <!-- LEFT: Search card (top) + Edit/Delete card (bottom) -->
                <div class="col-lg-6 col-md-12 pr-cards-column">
                    <!-- Selector card -->
                    <div class="pr-primary-settings">
                        <h5 class="pr-section-title"><i class="fa fa-layer-group"></i> Value Set Selector</h5>
                        <div class="row">
                            <div class="col-md-7 dv-select-wrap">
                                <label for="<%= ddlValueSet.ClientID %>">Value Set Name <span class="dv-required">*</span></label>
                                <asp:DropDownList runat="server" ID="ddlValueSet"
                                    AutoPostBack="true"
                                    OnSelectedIndexChanged="ddlValueSet_SelectedIndexChanged"
                                    AppendDataBoundItems="True" />
                                <asp:Label ID="Label2" runat="server" Text="Value Set Name:" Style="display:none;" />
                            </div>
                            <div class="col-md-3">
                                <label>&nbsp;</label>
                                <asp:Button CssClass="dv-btn dv-btn-primary dv-btn-block" SkinID="Custom"
                                    Text="Save All" ID="btnSave" runat="server" OnClick="btnSave_Click" />
                            </div>
                        </div>
                    </div>
                    <!-- Form card -->
                    <div class="pr-primary-settings">
                        <h5 class="pr-section-title"><i class="fa fa-plus-square"></i> Add / Edit Data Item</h5>
                        <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                            <ContentTemplate>
                                <div class="row">
                                    <div class="col-md-6">
                                        <label for="<%= txtDataValue_Name.ClientID %>">Name / Code <span class="dv-required">*</span></label>
                                        <asp:TextBox ID="txtDataValue_Name" runat="server" CssClass="form-control" placeholder="e.g. M, F, C" />
                                    </div>
                                    <div class="col-md-6">
                                        <label for="<%= txtDataValue_Description.ClientID %>">Description <span class="dv-required">*</span></label>
                                        <asp:TextBox ID="txtDataValue_Description" runat="server" CssClass="form-control" placeholder="e.g. Male, Female, New Born" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-6">
                                        <label for="<%= txtSegment1.ClientID %>">User Value</label>
                                        <asp:TextBox ID="txtSegment1" runat="server" CssClass="form-control" placeholder="e.g. M-01" />
                                    </div>
                                    <div class="col-md-6">
                                        <label for="<%= txtSegment2.ClientID %>"><asp:Label ID="roomNo" runat="server" Text="Segment 2" /></label>
                                        <asp:TextBox ID="txtSegment2" runat="server" CssClass="form-control" placeholder="e.g. Pediatric, General" />
                                    </div>
                                </div>

                                <asp:HiddenField ID="hfDataValue_ID" runat="server" />
                                <asp:HiddenField ID="hfData_Type" runat="server" />
                                <asp:HiddenField ID="HfMax_Length" runat="server" />
                                <asp:HiddenField ID="Trans_Type" runat="server" />
                                <asp:Label ID="lblMessage" runat="server" CssClass="dv-message" Style="display:none;" />

                                <div class="dv-action-row">
                                    <div class="dv-action-group">
                                        <asp:Button CssClass="dv-btn dv-btn-primary" SkinID="Custom"
                                            Text="Add" ID="btnAdd" runat="server" OnClick="btnAdd_Click" />
                                        <input type="button" class="dv-btn dv-btn-primary" value="Clear" onclick="clearAddFields();" />
                                        <asp:Button CssClass="dv-btn dv-btn-primary" SkinID="Custom"
                                            Text="Delete" ID="btnDelete" runat="server" OnClick="btnDelete_Click" />
                                    </div>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="GRD" EventName="SelectedIndexChanging" />
                                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>

                <!-- RIGHT: Records table (stretches to match left column height) -->
                <div class="col-lg-6 col-md-12 pr-cards-column dv-table-col">
                    <div class="pr-primary-settings">
                        <h5 class="pr-section-title"><i class="fa fa-table"></i> Data Value Records</h5>
                        <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                            <ProgressTemplate>
                                <div class="loadingimage">
                                    <asp:Image ID="image1" ImageUrl="~/images/loading.gif" runat="server" Width="32px"  Style="display:none;" />
                                </div>
                            </ProgressTemplate>
                        </asp:UpdateProgress>
                        <asp:UpdatePanel ID="UpdatePanel2" runat="server">
                            <ContentTemplate>
                                <div class="dv-table-wrap">
                                    <asp:GridView ID="GRD" runat="server" SkinID="Custom" EmptyDataText="No records found" Width="100%" AutoGenerateColumns="False"
                                        Style="margin-right: 1px" OnSelectedIndexChanging="GRD_SelectedIndexChanging"
                                        CellPadding="0" CellSpacing="0" GridLines="None"
                                        CssClass="dv-table"
                                        HeaderStyle-CssClass="dv-th"
                                        RowStyle-CssClass="dv-tr"
                                        AlternatingRowStyle-CssClass="dv-tr-alt"
                                        UseAccessibleHeader="True">
                                        <Columns>
                                            <asp:TemplateField HeaderText="">
                                                <ItemTemplate>
                                                    <asp:LinkButton ID="lbselect" CommandName="select" runat="server"
                                                        CssClass="dv-action-btn" ToolTip="Select / edit row">
                                                        <i class="fa fa-pencil"></i>
                                                    </asp:LinkButton>
                                                </ItemTemplate>
                                                <ItemStyle HorizontalAlign="Center" Width="50px" CssClass="dv-td-center" />
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
                                            <asp:TemplateField HeaderText="Name / Code" SortExpression="DataValue_Name">
                                                <ItemTemplate>
                                                    <span class="dv-code-chip"><asp:Label ID="lblDataValue_Name" runat="server" Text='<%# Bind("DataValue_Name") %>'></asp:Label></span>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle Width="180px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Description" SortExpression="DataValue_Description">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblDataValue_Description" runat="server" Text='<%# Bind("DataValue_Description") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle Width="280px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="User Value" SortExpression="Segment1">
                                                <ItemTemplate>
                                                    <asp:Label ID="lblSegment1" runat="server" Text='<%# Bind("Segment1") %>'></asp:Label>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle Width="200px" />
                                            </asp:TemplateField>
                                            <asp:TemplateField HeaderText="Segment 2" SortExpression="Segment2">
                                                <ItemTemplate>
                                                    <span class="dv-seg-chip"><asp:Label ID="lblSegment2" runat="server" Text='<%# Bind("Segment2") %>'></asp:Label></span>
                                                </ItemTemplate>
                                                <HeaderStyle HorizontalAlign="Left" />
                                                <ItemStyle Width="200px" />
                                            </asp:TemplateField>
                                        </Columns>
                                    </asp:GridView>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="ddlValueSet" EventName="SelectedIndexChanged" />
                                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
