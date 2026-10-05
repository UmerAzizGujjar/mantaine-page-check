<%@ Page Title="Chart of Accounts" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="True"
    CodeBehind="ChartofAccounts.aspx.cs" Inherits="Salon.GL.ChartofAccounts" Theme="Default_Theme" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="asp" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <script type="text/javascript">
        window.skipDevToolsCheck = true;
    </script>
    <style type="text/css">
        /* -- Tokens: follow the active THEME_* accent (theme-colors.css) and dark mode -- */
        .coa-page {
            --coa-accent: var(--theme-accent, #438eb9);
            --coa-accent-light: var(--theme-accent-light, #5aa0c8);
            --coa-accent-deep: color-mix(in srgb, var(--coa-accent) 78%, #000);
            --coa-on-accent: var(--theme-on-accent, #ffffff);
            --coa-soft: var(--theme-accent-soft, #e5f1f8);
            --coa-accent-ink: var(--theme-accent-ink, #2b6a90);
            --coa-ring: var(--theme-accent-ring, rgba(67, 142, 185, .25));
            --coa-text: var(--theme-ink, #1b2a41);
            --coa-surface: #ffffff;
            --coa-surface-alt: #f6f8fa;
            --coa-input-bg: #ffffff;
            --coa-border: #e3e8ee;
            --coa-muted: #6b7a8c;
            --coa-danger: #c0392b;
            --coa-shadow: 0 1px 3px rgba(20, 35, 55, .08);
            --coa-shadow-hover: 0 6px 16px rgba(20, 35, 55, .12);
            padding: 14px 4px 24px;
            color: var(--coa-text);
        }

        html[data-theme="dark"] .coa-page {
            --coa-surface: var(--dk-surface, #151b25);
            --coa-surface-alt: #1b2330;
            --coa-input-bg: var(--dk-bg, #0e131b);
            --coa-border: var(--dk-border, #2a3547);
            --coa-muted: var(--dk-text-dim, #a9b4c4);
            --coa-danger: #ed5a5a;
            --coa-shadow: 0 1px 3px rgba(0, 0, 0, .4);
            --coa-shadow-hover: 0 6px 16px rgba(0, 0, 0, .5);
        }

        /* Title bar + badge: shared .pm-bar / .pm-badge classes (wwwroot/lib/theme/table-modern.css) */

        .coa-page .coa-progress {
            font-size: 12px;
            color: var(--coa-muted);
        }

            .coa-page .coa-progress i {
                color: var(--coa-accent);
            }

        /* -- Layout -- */
        .coa-page .coa-grid {
            display: grid;
            grid-template-columns: minmax(300px, 420px) minmax(0, 1fr);
            gap: 16px;
            align-items: start;
        }

        .coa-page .coa-col {
            display: flex;
            flex-direction: column;
            gap: 16px;
            min-width: 0;
        }

        @media (max-width: 900px) {
            .coa-page .coa-grid {
                grid-template-columns: minmax(0, 1fr);
            }
        }

        /* -- Cards -- */
        .coa-page .coa-card {
            background: var(--coa-surface);
            border: 1px solid var(--coa-border);
            border-left: 3px solid var(--coa-accent);
            border-radius: 6px;
            box-shadow: var(--coa-shadow);
            overflow: hidden;
            transition: box-shadow .2s ease, transform .2s ease;
        }

            .coa-page .coa-card:hover {
                box-shadow: var(--coa-shadow-hover);
                transform: translateY(-1px);
            }

        .coa-page .coa-title {
            display: flex;
            align-items: center;
            gap: 8px;
            margin: 0;
            padding: 10px 18px;
            font-size: 12px;
            font-weight: 700;
            letter-spacing: .08em;
            text-transform: uppercase;
            color: var(--coa-on-accent);
            background: linear-gradient(135deg, var(--coa-accent) 0%, var(--coa-accent-deep) 100%);
        }

            .coa-page .coa-title .coa-sub {
                margin-left: auto;
                font-weight: 500;
                letter-spacing: 0;
                text-transform: none;
                opacity: .9;
            }

                .coa-page .coa-title .coa-sub:empty {
                    display: none;
                }

        .coa-page .coa-body {
            padding: 16px 18px;
        }

        /* -- Tree -- */
        .coa-page .coa-tree-tools {
            display: flex;
            justify-content: flex-end;
            padding: 8px 12px 0;
        }

        .coa-page .coa-icon-btn {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            height: 28px;
            padding: 0 10px;
            font-size: 12px;
            color: var(--coa-muted);
            background: var(--coa-surface-alt);
            border: 1px solid var(--coa-border);
            border-radius: 4px;
            cursor: pointer;
            transition: all .15s ease;
        }

            .coa-page .coa-icon-btn:hover {
                color: var(--coa-accent-ink);
                border-color: var(--coa-accent);
                background: var(--coa-soft);
            }

        .coa-page .coa-tree-scroll {
            height: 540px;
            padding: 8px 10px 12px;
        }

        /* Telerik's own CSS is switched off (see RadTreeView1 note), so the tree is fully styled here */
        .coa-page .RadTreeView {
            font-size: 13px;
            color: var(--coa-text);
        }

            .coa-page .RadTreeView .rtUL {
                list-style: none;
                margin: 0;
                padding: 0;
            }

                .coa-page .RadTreeView .rtUL .rtUL {
                    margin-left: 9px;
                    padding-left: 12px;
                    border-left: 1px dashed var(--coa-border);
                }

            .coa-page .RadTreeView .rtLI {
                list-style: none;
                margin: 0;
                padding: 0;
            }

            .coa-page .RadTreeView .rtTop,
            .coa-page .RadTreeView .rtMid,
            .coa-page .RadTreeView .rtBot {
                display: flex;
                align-items: center;
                padding: 1px 0;
            }

            .coa-page .RadTreeView .rtSp {
                display: none;
            }

                .coa-page .RadTreeView .rtSp + .rtIn {
                    margin-left: 20px;
                }

            .coa-page .RadTreeView .rtPlus,
            .coa-page .RadTreeView .rtMinus {
                flex: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 20px;
                height: 22px;
                cursor: pointer;
                color: var(--coa-muted);
                font-family: FontAwesome;
                font-size: 14px;
            }

                .coa-page .RadTreeView .rtPlus::before {
                    content: "\f105";
                }

                .coa-page .RadTreeView .rtMinus::before {
                    content: "\f107";
                }

                .coa-page .RadTreeView .rtPlus:hover,
                .coa-page .RadTreeView .rtMinus:hover {
                    color: var(--coa-accent);
                }

            .coa-page .RadTreeView .rtLoadingIcon,
            .coa-page .RadTreeView .rtLoading {
                color: var(--coa-accent);
            }

            .coa-page .RadTreeView .rtIn {
                display: inline-block;
                padding: 3px 9px;
                border: 1px solid transparent;
                border-radius: 4px;
                color: var(--coa-text);
                cursor: pointer;
                line-height: 1.4;
                transition: background .12s ease, color .12s ease;
            }

            /* Telerik puts rtHover / rtSelected / rtDisabled on the row div, not on the text span */
            .coa-page .RadTreeView .rtHover > .rtIn {
                background: var(--coa-soft);
                color: var(--coa-accent-ink);
            }

            .coa-page .RadTreeView .rtSelected > .rtIn {
                background: var(--coa-accent);
                color: var(--coa-on-accent);
                font-weight: 600;
            }

            .coa-page .RadTreeView .rtDisabled > .rtIn {
                opacity: .5;
                cursor: not-allowed;
            }

            .coa-page .RadTreeView input.rtEdit {
                height: 26px !important;
                width: auto !important;
            }

        /* -- Form fields -- */
        .coa-page .coa-row {
            margin-bottom: 14px;
        }

        .coa-page .coa-label {
            display: block;
            margin-bottom: 4px;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: var(--coa-muted);
        }

        .coa-page input[type="text"] {
            width: 100% !important;
            height: 36px !important;
            padding: 6px 12px !important;
            margin: 0 !important;
            font-size: 13px !important;
            color: var(--coa-text) !important;
            background: var(--coa-input-bg) !important;
            border: 1px solid var(--coa-border) !important;
            border-radius: 4px !important;
            box-shadow: none !important;
            box-sizing: border-box;
            transition: border-color .15s ease, box-shadow .15s ease;
        }

            .coa-page input[type="text"]:focus {
                border-color: var(--coa-accent) !important;
                box-shadow: 0 0 0 3px var(--coa-ring) !important;
                outline: none !important;
            }

            .coa-page input[type="text"][readonly] {
                background: var(--coa-surface-alt) !important;
                color: var(--coa-muted) !important;
            }

        .coa-page .coa-code-group {
            display: grid;
            grid-template-columns: minmax(90px, 2fr) minmax(90px, 3fr);
            gap: 0;
        }

            .coa-page .coa-code-group input[type="text"]:first-child {
                border-top-right-radius: 0 !important;
                border-bottom-right-radius: 0 !important;
                border-right: 0 !important;
                font-weight: 600;
            }

            .coa-page .coa-code-group input[type="text"]:last-child {
                border-top-left-radius: 0 !important;
                border-bottom-left-radius: 0 !important;
            }

        .coa-page .coa-hint-text {
            margin-top: 5px;
            font-size: 12px;
            color: var(--coa-muted);
        }

            .coa-page .coa-hint-text b {
                color: var(--coa-accent-ink);
                letter-spacing: .03em;
            }

        .coa-page .coa-radios {
            display: flex;
            gap: 10px;
        }

            /* asp:RadioButton renders a bare input + label: the label is the pill, the input is hidden */
            .coa-page .coa-radios input[type="radio"] {
                position: absolute;
                opacity: 0;
                width: 0;
                height: 0;
                margin: 0;
            }

            .coa-page .coa-radios label {
                display: inline-flex !important;
                align-items: center;
                gap: 8px;
                float: none !important;
                width: auto !important;
                margin: 0 !important;
                padding: 6px 16px;
                font-size: 13px;
                font-weight: 600;
                text-align: left !important;
                color: var(--coa-text);
                background: var(--coa-surface-alt);
                border: 1px solid var(--coa-border);
                border-radius: 999px;
                cursor: pointer;
                transition: all .15s ease;
            }

                .coa-page .coa-radios label::before {
                    content: "";
                    width: 14px;
                    height: 14px;
                    border: 2px solid var(--coa-muted);
                    border-radius: 50%;
                    box-sizing: border-box;
                    transition: all .15s ease;
                }

                .coa-page .coa-radios label:hover {
                    border-color: var(--coa-accent);
                }

            .coa-page .coa-radios input[type="radio"]:checked + label {
                color: var(--coa-accent-ink);
                background: var(--coa-soft);
                border-color: var(--coa-accent);
            }

                .coa-page .coa-radios input[type="radio"]:checked + label::before {
                    border-color: var(--coa-accent);
                    background: radial-gradient(circle, var(--coa-accent) 0 38%, transparent 42%);
                }

            .coa-page .coa-radios input[type="radio"]:focus-visible + label {
                box-shadow: 0 0 0 3px var(--coa-ring);
            }

        .coa-page .coa-empty {
            display: none;
            align-items: center;
            gap: 8px;
            margin-bottom: 14px;
            padding: 10px 12px;
            font-size: 12px;
            color: var(--coa-accent-ink);
            background: var(--coa-soft);
            border-radius: 4px;
        }

        .coa-page[data-mode=""] .coa-empty {
            display: flex;
        }

        .coa-page .coa-msg {
            display: block;
            margin-top: 10px;
            font-size: 12px;
            color: var(--coa-danger);
        }

            .coa-page .coa-msg:empty {
                display: none;
            }

        /* -- Buttons (icon sits after the input so :disabled / :hover can style it) -- */
        .coa-page .coa-actions {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }

        .coa-page .coa-btn {
            position: relative;
            display: inline-flex;
        }

            .coa-page .coa-btn input[type="submit"] {
                height: 38px !important;
                width: auto !important;
                min-width: 0 !important;
                margin: 0 !important;
                padding: 0 18px 0 38px !important;
                font-size: 13px !important;
                font-weight: 600 !important;
                letter-spacing: .02em;
                border-radius: 6px !important;
                border: 1px solid transparent !important;
                box-shadow: none !important;
                opacity: 1;
                cursor: pointer;
                transition: all .15s ease !important;
            }

            .coa-page .coa-btn i {
                position: absolute;
                left: 14px;
                top: 50%;
                transform: translateY(-50%);
                font-size: 14px;
                pointer-events: none;
            }

        .coa-page .coa-btn--primary input[type="submit"] {
            background: linear-gradient(135deg, var(--coa-accent-light) 0%, var(--coa-accent) 100%) !important;
            color: var(--coa-on-accent) !important;
        }

            .coa-page .coa-btn--primary input[type="submit"]:hover:enabled {
                background: linear-gradient(135deg, var(--coa-accent) 0%, var(--coa-accent-deep) 100%) !important;
                box-shadow: 0 4px 10px var(--coa-ring) !important;
            }

        .coa-page .coa-btn--primary i {
            color: var(--coa-on-accent);
        }

        .coa-page .coa-btn--danger input[type="submit"] {
            background: transparent !important;
            color: var(--coa-danger) !important;
            border-color: var(--coa-danger) !important;
        }

            .coa-page .coa-btn--danger input[type="submit"]:hover:enabled {
                background: var(--coa-danger) !important;
                color: #ffffff !important;
            }

        .coa-page .coa-btn--danger i {
            color: var(--coa-danger);
        }

        .coa-page .coa-btn--danger input[type="submit"]:hover:enabled + i {
            color: #ffffff;
        }

        .coa-page .coa-btn--ghost input[type="submit"] {
            background: var(--coa-surface-alt) !important;
            color: var(--coa-text) !important;
            border-color: var(--coa-border) !important;
        }

            .coa-page .coa-btn--ghost input[type="submit"]:hover:enabled {
                border-color: var(--coa-accent) !important;
                color: var(--coa-accent-ink) !important;
            }

        .coa-page .coa-btn--ghost i {
            color: var(--coa-muted);
        }

        .coa-page .coa-btn input[type="submit"]:disabled {
            background: var(--coa-surface-alt) !important;
            color: var(--coa-muted) !important;
            border-color: var(--coa-border) !important;
            opacity: .6;
            cursor: not-allowed;
        }

            .coa-page .coa-btn input[type="submit"]:disabled + i {
                color: var(--coa-muted);
            }

        .coa-page .coa-footer {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            margin-top: 6px;
            padding-top: 14px;
            border-top: 1px solid var(--coa-border);
        }

        @media (max-width: 600px) {
            .coa-page .coa-code-group {
                grid-template-columns: minmax(0, 1fr);
            }

                .coa-page .coa-code-group input[type="text"]:first-child {
                    border-radius: 4px 4px 0 0 !important;
                    border-right: 1px solid var(--coa-border) !important;
                    border-bottom: 0 !important;
                }

                .coa-page .coa-code-group input[type="text"]:last-child {
                    border-radius: 0 0 4px 4px !important;
                }
        }
    </style>

    <script type="text/javascript">
        // No <% %> code blocks allowed in this head content: Telerik injects its skin CSS into <head>.
        // Swal confirmation for a postback button: first click asks, confirmed click lets the postback through.
        var coaConfirmed = false;
        function coaConfirmDelete(btn) {
            if (coaConfirmed) { coaConfirmed = false; return true; }
            Swal.fire({
                icon: 'warning',
                title: 'Delete account?',
                text: 'Are you sure you want to delete this account?',
                showCancelButton: true,
                confirmButtonText: 'Yes, delete',
                cancelButtonText: 'Cancel',
                confirmButtonColor: '#c0392b'
            }).then(function (r) {
                if (r.isConfirmed) { coaConfirmed = true; btn.click(); }
            });
            return false;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <script type="text/javascript">
        function enableAllNodes() {
            var treeView = $find("<%= RadTreeView1.ClientID %>");
            var allNodes = treeView.get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                allNodes[i].enable();
            }
            return false;
        }

        function disableAllNodes() {
            var treeView = $find("<%= RadTreeView1.ClientID %>");
            var allNodes = treeView.get_allNodes();
            for (var i = 0; i < allNodes.length; i++) {
                allNodes[i].disable();
            }
            return false;
        }

        function coaCollapseAll() {
            var treeView = $find("<%= RadTreeView1.ClientID %>");
            if (treeView) treeView.collapseAllNodes();
            return false;
        }

        var xPos, yPos, coaSource = '';
        var prm = Sys.WebForms.PageRequestManager.getInstance();

        function BeginRequestHandler(sender, args) {
            var el = args.get_postBackElement();
            coaSource = el ? el.id : '';
            var panel = $get('<%= Panel1.ClientID %>');
            if (panel) {
                xPos = panel.scrollLeft;
                yPos = panel.scrollTop;
            }
        }

        function EndRequestHandler(sender, args) {
            var panel = $get('<%= Panel1.ClientID %>');
            if (panel) {
                panel.scrollLeft = xPos;
                panel.scrollTop = yPos;
            }
        }

        prm.add_beginRequest(BeginRequestHandler);
        prm.add_endRequest(EndRequestHandler);

        // Runs on first load and after every partial postback.
        function coaRefresh() {
            var root = document.getElementById('coaPage');
            if (!root) return;

            var mode = $get('<%= hdnAddOrEdit.ClientID %>');
            mode = mode ? mode.value : '';
            root.setAttribute('data-mode', mode);

            var labels = { '': 'No account selected', 'Edit': 'Editing account', 'Add': 'New sibling account', 'Add Child': 'New child account' };
            var badge = document.getElementById('coaModeText');
            if (badge) badge.textContent = labels[mode] || mode;
            var badgeBox = document.getElementById('coaBadge');
            if (badgeBox) badgeBox.classList.toggle('is-active', mode !== '');

            // Bank / Cash options only exist for level-4 accounts
            var typeRow = document.getElementById('coaTypeRow');
            if (typeRow) typeRow.style.display = typeRow.querySelector('input[type=radio]') ? '' : 'none';

            // Nothing selected (first load, after Cancel / Delete): the actions would hit a null SelectedNode on the server
            if (mode === '') {
                ['<%= btnAdd.ClientID %>', '<%= btnAddChild.ClientID %>', '<%= btnDelete.ClientID %>',
                 '<%= btnCancel.ClientID %>', '<%= btnEditSave.ClientID %>'].forEach(function (id) {
                    var b = document.getElementById(id);
                    if (b) b.disabled = true;
                });
            }

            coaPreview();

            // Server validation message -> Swal (only for the request that produced it)
            var msg = $get('<%= lblMessage.ClientID %>');
            if (msg && msg.textContent.replace(/\s+/g, '') !== '') {
                if (coaSource === '<%= btnEditSave.ClientID %>') {
                    Swal.fire({ icon: 'warning', title: 'Unable to save', text: msg.textContent.trim() });
                }
                msg.textContent = '';
            }
        }

        function coaPreview() {
            var p = $get('<%= txtParent_Code.ClientID %>');
            var c = $get('<%= txtAccount_Code.ClientID %>');
            var out = document.getElementById('coaFullCode');
            if (!p || !c || !out) return;
            out.textContent = ((p.value || '') + (c.value || '')) || '\u2014';
        }

        $(document).on('input', '#<%= txtAccount_Code.ClientID %>', coaPreview);
        Sys.Application.add_load(coaRefresh);
    </script>

    <div class="coa-page" id="coaPage" data-mode="">

        <div class="pm-bar">
            <span class="pm-bar-title"><i class="fa fa-sitemap"></i>Chart of Accounts</span>
            <div class="pm-bar-right">
                <asp:UpdateProgress ID="UpdateProgress1" runat="server">
                    <ProgressTemplate>
                        <span class="coa-progress"><i class="fa fa-spinner fa-spin"></i> Working&hellip;</span>
                    </ProgressTemplate>
                </asp:UpdateProgress>
                <span class="pm-badge" id="coaBadge"><i class="fa fa-info-circle"></i><span id="coaModeText">No account selected</span></span>
            </div>
        </div>

        <asp:UpdatePanel runat="server" ID="UpChartofAccounts" UpdateMode="Conditional">
            <ContentTemplate>
                <div class="coa-grid">

                    <%-- Left: account tree --%>
                    <div class="coa-col">
                        <asp:UpdatePanel runat="server" UpdateMode="Conditional" ID="upRadTreeview">
                            <ContentTemplate>
                                <div class="coa-card">
                                    <h5 class="coa-title">
                                        <i class="fa fa-sitemap"></i>
                                        <asp:Label ID="Label5" runat="server" Text="Account Tree" />
                                    </h5>
                                    <div class="coa-tree-tools">
                                        <button type="button" class="coa-icon-btn" onclick="return coaCollapseAll();" title="Collapse all nodes">
                                            <i class="fa fa-compress"></i>Collapse all
                                        </button>
                                    </div>
                                    <asp:Panel runat="server" ID="Panel1" CssClass="coa-tree-scroll" ScrollBars="Auto">
                                        <%-- Embedded CSS is off: Site.Master's <head> has <% %> blocks, so Telerik cannot add its skin link there. The tree is styled by .coa-page CSS above. --%>
                                        <telerik:RadTreeView ID="RadTreeView1" ShowLineImages="false" runat="server" AllowNodeEditing="True"
                                            EnableEmbeddedSkins="false" EnableEmbeddedBaseStylesheet="false" Skin=""
                                            OnNodeEdit="RadTreeView1_NodeEdit" OnNodeExpand="RadTreeView1_NodeExpand" OnNodeClick="RadTreeView1_NodeClick">
                                        </telerik:RadTreeView>
                                    </asp:Panel>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="btnEditSave" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnCancel" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>
                    </div>

                    <%-- Right: actions + account details --%>
                    <div class="coa-col">

                        <asp:UpdatePanel runat="server" ID="upOptions" UpdateMode="Conditional">
                            <ContentTemplate>
                                <div class="coa-card">
                                    <h5 class="coa-title">
                                        <i class="fa fa-bolt"></i>Account Actions
                                        <asp:Label ID="lblHeading" runat="server" CssClass="coa-sub" />
                                    </h5>
                                    <div class="coa-body">
                                        <div class="coa-actions">
                                            <span class="coa-btn coa-btn--primary">
                                                <asp:Button ID="btnAdd" CssClass="btn-primry" runat="server" Text="Add Sibling" OnClick="btnAdd_Click" ClientIDMode="Static" OnClientClick="disableAllNodes();" /><i class="fa fa-plus"></i>
                                            </span>
                                            <span class="coa-btn coa-btn--primary">
                                                <asp:Button ID="btnAddChild" CssClass="btn-primry" runat="server" Text="Add Child" OnClick="btnAddChild_Click" ClientIDMode="Static" OnClientClick="disableAllNodes();" /><i class="fa fa-level-down"></i>
                                            </span>
                                            <span style="display: none;">
                                                <asp:Button ID="btnEditAccount" CssClass="btn-primry" runat="server" Text="Edit" OnClick="btnEditAccount_Click" />
                                            </span>
                                            <span class="coa-btn coa-btn--danger">
                                                <asp:Button ID="btnDelete" CssClass="btn-primry" runat="server" Text="Delete" OnClick="btnDelete_Click" OnClientClick="return coaConfirmDelete(this);" /><i class="fa fa-trash"></i>
                                            </span>
                                            <span class="coa-btn coa-btn--ghost">
                                                <asp:Button ID="btnCancel" CssClass="btn-primry" runat="server" Text="Cancel" SkinID="btnAutoWidth" OnClick="btnCancel_Click" /><i class="fa fa-times"></i>
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="RadTreeView1" EventName="NodeClick" />
                            </Triggers>
                        </asp:UpdatePanel>

                        <asp:UpdatePanel ID="UpAccountInformation" runat="server" UpdateMode="Conditional">
                            <ContentTemplate>
                                <div class="coa-card">
                                    <h5 class="coa-title">
                                        <i class="fa fa-file-text-o"></i>
                                        <asp:Label ID="Label2" runat="server" Text="Account Information" />
                                        <asp:Label ID="lblHeading1" runat="server" CssClass="coa-sub" />
                                    </h5>
                                    <div class="coa-body">

                                        <div class="coa-empty">
                                            <i class="fa fa-hand-o-left"></i>
                                            Select an account in the tree to view or edit it, or choose Add Sibling / Add Child.
                                        </div>

                                        <div class="coa-row">
                                            <asp:Label ID="Label1" runat="server" Text="Account Code" CssClass="coa-label" AssociatedControlID="txtAccount_Code" />
                                            <div class="coa-code-group">
                                                <asp:TextBox ID="txtParent_Code" runat="server" ReadOnly="True" placeholder="Parent" ToolTip="Parent account code" />
                                                <asp:TextBox ID="txtAccount_Code" runat="server" placeholder="Serial" />
                                            </div>
                                            <div class="coa-hint-text">Full code: <b id="coaFullCode">&mdash;</b></div>
                                        </div>

                                        <div class="coa-row">
                                            <asp:Label ID="Label4" runat="server" Text="Account Name" CssClass="coa-label" AssociatedControlID="txtAccount_Name" />
                                            <asp:TextBox ID="txtAccount_Name" EnableTheming="false" runat="server" placeholder="Enter account name" />
                                        </div>

                                        <div class="coa-row" id="coaTypeRow">
                                            <span class="coa-label">Account Type</span>
                                            <div class="coa-radios">
                                                <asp:RadioButton Text="Bank" runat="server" GroupName="a" ID="rbtnBank" Visible="false" />
                                                <asp:RadioButton Text="Cash" runat="server" GroupName="a" ID="rbtnCash" Visible="false" />
                                            </div>
                                        </div>

                                        <div class="coa-footer">
                                            <span class="coa-btn coa-btn--primary">
                                                <asp:Button ID="btnEditSave" runat="server" CssClass="btn-primry" Text="Update" OnClick="btnEditSave_Click" /><i class="fa fa-floppy-o"></i>
                                            </span>
                                            <asp:Button ID="btnEditCancel" runat="server" Visible="false" Text="Cancel" CssClass="popupButton"
                                                OnClick="btnEditCancel_Click" OnClientClick="return enableAllNodes()" ClientIDMode="Static" />
                                        </div>

                                        <asp:Label Text="" ID="lblMessage" runat="server" CssClass="errorMessage coa-msg" />
                                        <asp:HiddenField ID="hdnEditOk" runat="server" />
                                        <asp:HiddenField ID="hdnEditCancel" runat="server" />
                                        <asp:HiddenField ID="hdnAddOrEdit" runat="server" />
                                        <asp:HiddenField ID="hdnParentId" runat="server" />
                                        <asp:HiddenField ID="hdnAccountId" runat="server" />
                                        <asp:HiddenField ID="hdnLevel" runat="server" />
                                    </div>
                                </div>
                            </ContentTemplate>
                            <Triggers>
                                <asp:AsyncPostBackTrigger ControlID="RadTreeView1" EventName="NodeClick" />
                                <asp:AsyncPostBackTrigger ControlID="btnAdd" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnAddChild" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnCancel" EventName="Click" />
                                <asp:AsyncPostBackTrigger ControlID="btnDelete" EventName="Click" />
                            </Triggers>
                        </asp:UpdatePanel>

                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
</asp:Content>
