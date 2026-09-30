using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Diagnostics.Eventing.Reader;
using System.Linq;
using System.Net.PeerToPeer;
using System.Text;
using System.Web;
using System.Web.Routing;
using System.Web.Script.Serialization;
using System.Web.Security;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using Telerik.Web.UI;


namespace PMS
{
    public partial class SiteMaster : System.Web.UI.MasterPage
    {

       

        public void LoadMenus()
        {
            try
            {
                if (Session["UserID"] != null)
                {
                    string userId = Session["UserID"].ToString();
                    string allowTill = DBClass.getField("select isnull(user_till,0) from aspnet_Users where UserId='" + userId + "'");
                    bool isTillUser = allowTill == "1" || allowTill.Equals("true", StringComparison.OrdinalIgnoreCase);
                    Session["AllowTill"] = isTillUser;
                    if (!isTillUser)
                    {
                        goto SkipTillRestriction;
                    }

                    bool hasActiveTill = Session["TillIsActive"] != null && Convert.ToBoolean(Session["TillIsActive"]);
                    bool hasEndedTill = Session["TillEnded"] != null && Convert.ToBoolean(Session["TillEnded"]);
                    string startedAt = Session["TillStartedAt"] != null ? Session["TillStartedAt"].ToString() : string.Empty;
                    string endedAt = Session["TillEndedAt"] != null ? Session["TillEndedAt"].ToString() : string.Empty;

                    // Uncomment when table exists
                    string scheduleDate = DateTime.Now.ToString("yyyy-MM-dd");
                    string tillSql = "SELECT TOP 1 start_time, close_time FROM user_tills WHERE user_id='" + userId + "' AND schedule_date='" + scheduleDate + "' ORDER BY id DESC";
                    DataTable tillDt = DBClass.getDataTable(tillSql);
                    if (tillDt.Rows.Count > 0)
                    {
                        bool hasClose = tillDt.Rows[0]["close_time"] != DBNull.Value && tillDt.Rows[0]["close_time"].ToString() != "";
                        hasActiveTill = !hasClose;
                        hasEndedTill = hasClose;
                        startedAt = tillDt.Rows[0]["start_time"].ToString();
                        endedAt = hasClose ? tillDt.Rows[0]["close_time"].ToString() : string.Empty;
                    }

                    string currentPage = Request.Url.AbsolutePath.ToLower();
                    bool isDefaultPage = currentPage.EndsWith("/default.aspx") || currentPage.EndsWith("default.aspx");
                    bool isTillApiCall = currentPage.EndsWith("/patientmanagementsection.aspx") || currentPage.EndsWith("patientmanagementsection.aspx");

                    if (!hasActiveTill && !isDefaultPage && !isTillApiCall)
                    {
                        Response.Redirect("~/Default.aspx", false);
                        return;
                    }

                SkipTillRestriction:
                    ;
                }
            }
            catch
            {
            }

            string UserName = Session["UserName"].ToString().Trim();
            lblCompanyNameCenter.Text = AppConfig.Company_Name;
            IHome.Title = AppConfig.Company_Name;
            LoginName.Text = AppConfig.UserName.ToUpper().Trim();
            HeadLoginStatus.LoginText = "Log Out";

            List<string> navigateURL = new List<string>();
            string[] roles = System.Web.Security.Roles.GetRolesForUser(UserName);
            string roleName = "";
            foreach (string role in roles)
            {
                if (roleName != "")
                    roleName += ",";
                roleName += "'" + role + "'";
            }
            string cmd = "";
            if (roleName != "")
            {
                cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                       " INNER JOIN aspnet_roles r on rm.roleID=r.roleID inner join aspnet_UsersInRoles userinroles on r.roleID=userinroles.roleid" +
                       " where r.roleName in(" + roleName + ") AND IsActive=1  and (userinroles.company_id=" + AppConfig.Company_ID + " or userinroles.allCompany=1)order by Order_by ";
            }
            else
            {
                cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                           " INNER JOIN aspnet_roles r on rm.roleID=r.roleID" +
                           " where r.roleName='user' AND IsActive=1 order by Order_by ";
            }
            DataTable dt;
            dt = DBClass.getDataTable(cmd);
            foreach (DataRow item in dt.Rows)
            {
                navigateURL.Add(item["URL"].ToString());
            }

            DataRow[] dr = dt.Select("Parent_Id=" + 0);
            foreach (DataRow item in dr)
            {
                MenuItem mi = new MenuItem(Convert.ToString(item["Menu_Description"]),
                              Convert.ToString(item["Menu_Id"]),
                              "", Convert.ToString(item["URL"]));
            }

            String pageName = Request.Url.AbsolutePath;
            string requestedPage = pageName.Substring(pageName.LastIndexOf("/") + 1);

            string query = "select URL from Menus m inner join aspnet_RolesInMenus rm on m.Menu_ID=rm.Menu_Id " +
                "where rm.RoleId in (select RoleId from aspnet_UsersInRoles ur inner join aspnet_Users u  " +
                "on ur.UserId=u.UserId where UserName='" + UserName + "' and ((ur.Company_ID=" + AppConfig.Company_ID + " AND AllCompany=0)or (ur.Company_ID=0 AND AllCompany=1))) " +
                "and ( URL like '%" + requestedPage + "%')";
            DataTable dtMenus = DBClass.getDataTable(query);
            if (dtMenus.Rows.Count < 1)
            {
                if (requestedPage != "Default.aspx")
                    Response.Redirect("~/Default.aspx", false);
            }



            string PageName = GetMenuName();
            Page.Title = AppConfig.Company_Name + " - " + PageName;
            lblCompanyNameCenter.Text = AppConfig.Company_Name;
            IHome.Title = AppConfig.Company_Name;
        }



        protected void Page_Load(object sender, EventArgs e)
        {
         

            if (Session["UserName"] == null || Session["Company_Name"] == null || Session["Company_ID"] == null || Session["Book_ID"] == null)
            {
                Session.Abandon();
                Response.Redirect("~/Login.aspx");

            }

            string sessionUserName = Convert.ToString(Session["UserName"]);
            string sessionPwdStamp = Convert.ToString(Session["PwdStamp"]);
            using (DataBaseDataContext stampDb = new DataBaseDataContext())
            {
                string currentPwdStamp = (from u in stampDb.aspnet_Users
                                          join m in stampDb.aspnet_Memberships on u.UserId equals m.UserId
                                          where u.UserName == sessionUserName
                                          select m.Password).FirstOrDefault();

                if (currentPwdStamp == null || currentPwdStamp != sessionPwdStamp)
                {
                    FormsAuthentication.SignOut();

                    HttpCookie expiredAuthCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
                    expiredAuthCookie.Expires = DateTime.Now.AddYears(-1);
                    expiredAuthCookie.Path = "/";
                    Response.Cookies.Add(expiredAuthCookie);

                    Session.Clear();
                    Session.Abandon();
                    Response.Redirect("~/Login.aspx");
                }
            }

            if (!IsPostBack)
            {
                LoadMenus();
                CalculateNotifications();
                RightsForNotification();
              
            }
            generateDynamicMenu();
        

        }

       

        int i = 1;
        string Menu_Name = "";
        string Menu_id;
        public void CalculateNotifications()
        {
            string PRCount = "select COUNT(*) from Purchase_Requisition where Status in ('Created','Pending') and IsDeleted=0";
            string PR = DBClass.getField(PRCount);
            if (PR != null && PR != "There is no row at position 0.")
            {
                lblPR.Text = "+" + PR;
            }
            else
            {
                PR = "0";
                lblPR.Text = "0";
            }

            string RFQCount = "select COUNT(*) from AP_RequestForQuotations where Status in ('Created','Pending') and IsDeleted=0";
            string RFQ = DBClass.getField(RFQCount);
            if (RFQ != null && RFQ != "There is no row at position 0.")
            {
                lblRFQ.Text = "+" + RFQ;
            }
            else
            {
                RFQ = "0";
                lblRFQ.Text = "0";
            }


            string CSCount = "select COUNT(*) from CS_Vendor_Master where Status in ('Created','Pending') and IsDeleted=0";
            string CS = DBClass.getField(CSCount);
            if (CS != null && CS != "There is no row at position 0.")
            {
                lblCS.Text = "+" + CS;
            }
            else
            {
                CS = "0";
                lblCS.Text = "0";
            }


            string PO_count = "select COUNT(*) from AP_Purchase_Orders where Status in ('Created','Pending') and IsDeleted=0";
            string PO = DBClass.getField(PO_count);
            if (PO != null && PO != "There is no row at position 0.")
            {
                lblpo.Text = "+" + PO;
            }
            else
            {
                PO = "0";
                lblpo.Text = "0";
            }

            string IGP_count = "select COUNT(*) from Igp_master where Status in ('Created','Pending') or (Inspec_Status is null) and IsDeleted=0";
            string IGP = DBClass.getField(IGP_count);
            if (IGP != null && IGP != "There is no row at position 0.")
            {
                lbligp.Text = "+" + IGP;
            }
            else
            {
                IGP = "0";
                lbligp.Text = "0";
            }

            string GRN_count = "select COUNT(*) from GRN_Master where Status in ('Created','Pending')";
            string GRN = DBClass.getField(GRN_count);
            if (GRN != null && GRN != "There is no row at position 0.")
            {
                lblgrn.Text = "+" + GRN;
            }
            else
            {
                GRN = "0";
                lblgrn.Text = "0";
            }

            string GIR_count = "select COUNT(*) from MaterialIssueRequest where Status in ('Created','Pending')";
            string GIR = DBClass.getField(GIR_count);
            if (GIR != null && GIR != "There is no row at position 0.")
            {
                lblGIR.Text = "+" + GIR;
            }
            else
            {
                GIR = "0";
                lblGIR.Text = "0";
            }

           
            string GIN_count = "select COUNT(*) from Store_Issue where Status in ('Created','Pending')";
            string GIN = DBClass.getField(GIN_count);
            if (GIN != null && GIN != "There is no row at position 0.")
            {
                lblGIN.Text = "+" + GIN;
            }
            else
            {
                GIN = "0";
                lblGIN.Text = "0";
            }


            string StockAdj_count = "select COUNT(*) from INV_Stock_Adjustment where Status in ('Created','Pending')";
            string StockAdj = DBClass.getField(StockAdj_count);
            if (StockAdj != null && StockAdj != "There is no row at position 0.")
            {
                lblStockAdj.Text = "+" + StockAdj;
            }
            else
            {
                StockAdj = "0";
                lblStockAdj.Text = "0";
            }

            string StockTransfer_count = "select COUNT(*) from Stock_Transfer where Status in ('Created','Pending')";
            string StockTransfer = DBClass.getField(StockTransfer_count);
            if (StockTransfer != null && StockTransfer != "There is no row at position 0.")
            {
                lblstorestocktransfer.Text = "+" + StockTransfer;
            }
            else
            {
                StockTransfer = "0";
                lblstorestocktransfer.Text = "0";
            }

            string MI_count = "select COUNT(*) from Manual_Invoice where Status in ('Created','Pending') and IsDeleted=0;";
            string MI = DBClass.getField(MI_count);
            if (MI != null && MI != "There is no row at position 0.")
            {
                lblManualInvoice.Text = "+" + MI;
            }
            else
            {
                MI = "0";
                lblManualInvoice.Text = "0";
            }

            string PI_count = "select COUNT(*) from Purchase_Invoice_Master where Status in ('Created','Pending')";
            string PI = DBClass.getField(PI_count);
            if (PI != null && PI != "There is no row at position 0.")
            {
                lblPurchaseInvoice.Text = "+" + PI;
            }
            else
            {
                PI = "0";
                lblPurchaseInvoice.Text = "0";
            }

            string Payment_count = "select COUNT(*) from Payment_Invoice where Status in ('Created','Pending')";
            string Payment = DBClass.getField(Payment_count);
            if (Payment != null && Payment != "There is no row at position 0.")
            {
                lblPayment.Text = "+" + Payment;
            }
            else
            {
                Payment = "0";
                lblPayment.Text = "0";
            }
            string advance_count = "select COUNT(*) from Advance_Payment where Status in ('Created','Pending')";
            string advance = DBClass.getField(advance_count);
            if (advance != null && advance != "There is no row at position 0.")
            {
                lblAdvance.Text = "+" + advance;
            }
            else
            {
                advance = "0";
                lblAdvance.Text = "0";
            }
         

            int totalnoitification = Convert.ToInt32(PR) + Convert.ToInt32(RFQ)+ Convert.ToInt32(CS) + Convert.ToInt32(PO) + Convert.ToInt32(IGP)+ Convert.ToInt32(GRN) + Convert.ToInt32(GIR) + Convert.ToInt32(GIN) + Convert.ToInt32(StockAdj) +Convert.ToInt32(StockTransfer) + Convert.ToInt32(MI) +Convert.ToInt32(PI) + Convert.ToInt32(Payment) + Convert.ToInt32(advance);            
            lblTotal_Notifs.Text = totalnoitification.ToString();
            if (lblTotal_Notifs.Text == "0")
                blink_notify.Visible = false;
        }
        public string Get_URL()
        {
            string filter_URL = "";

            try
            {
                if (Request.QueryString["ID"] != null && Request.QueryString["VoucherType"] != null)
                {
                    string URL = HttpContext.Current.Request.RawUrl;
                    int a = URL.IndexOf("&");
                    filter_URL = URL.Substring(0, a);
                }
                else
                {
                    filter_URL = VirtualPathUtility.ToAppRelative(HttpContext.Current.Request.RawUrl);

                    if (filter_URL.Contains("?rptTitle="))
                    {

                    }
                    else if (filter_URL.Contains("?Type="))
                    {

                    }
                    else if (filter_URL.Contains("?"))
                    {
                        filter_URL = filter_URL.Split('?')[0];
                    }
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "The following error occured: " + ex.Message;
            }

            return filter_URL;
        }
        // Public property to expose lbl2
        public Label Label2
        {
            get { return lbl2; }
            set { lbl2 = value; }
        }
        public string GetMenuName()
        {
            string x = "";
            try
            {
                string result = Get_URL();
                int a = Get_URL().Length;
                int b = 6;
                int c = a - b;
                string menuName = Get_URL().Substring(1, c);
                string qury3 = "";
                string qury1 = "";
                string qury2 = "";

                int findTiled = result.IndexOf("~");

                if (findTiled == -1)
                    result = string.Concat("~", result.ToString());

                //qury1 = DBClass.getField("select Parent_ID from menus where URL='" + result + "' ");
                //qury2 = DBClass.getField("select Menu_ID from menus where URL='" + result + "' ");  
                qury1 = DBClass.getField("select Parent_ID from menus where URL = '" + result + "'");
                qury2 = DBClass.getField("select Menu_ID from menus where URL = '" + result + "'");
                if (qury1 == "There is no row at position 0." || qury2 == "There is no row at position 0.")
                {
                    // fall back to a suffix match on the full URL (query string included)
                    qury1 = DBClass.getField("select Parent_ID from menus where URL LIKE '%" + result + "'");
                    qury2 = DBClass.getField("select Menu_ID from menus where URL LIKE '%" + result + "'");
                }
                if (qury1 == "There is no row at position 0." || qury2 == "There is no row at position 0.")
                {
                    // URL with its query string is not registered in menus - leave the parent name blank
                    qury1 = "";
                    qury2 = "";
                }
                else if (qury1 == "0")
                {
                    qury3 = DBClass.getField("select Menu_Description from menus where Menu_ID='" + Convert.ToInt32(qury2) + "' ");
                }
                else
                {
                    qury3 = DBClass.getField("select Menu_Description from menus where Menu_ID='" + Convert.ToInt32(qury1) + "' ");
                }
                string qury = "";

                //qury = "select Menu_Description from menus where URL='" + result + "' ";
                qury = "select Menu_Description from menus where URL = '" + result + "' ";
                x = DBClass.getField(qury);
                if (x == "There is no row at position 0.")
                {
                    qury = "select Menu_Description from menus where URL LIKE '%" + result + "' ";
                    x = DBClass.getField(qury);
                }
                if (x == "There is no row at position 0.")
                    x = "";
                if (qury3 == "There is no row at position 0.")
                    qury3 = "";
                lbl1.Text = qury3;
                string rptTitle = Request.QueryString["rptTitle"] ?? "";
                if (rptTitle.StartsWith("Student", StringComparison.OrdinalIgnoreCase))
                    lbl1.Text = "Student";
                if (!Get_URL().Contains("PatientsDepartmentWise.aspx"))
                {
                    // Update lbl2 only if it's not set by PatientsDepartmentWise
                    lbl2.Text = x;
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = "The following error occured: " + ex.Message;
            }
                return x;
        }

        public void selectMenu()
        {
            string result = string.Concat("~", Get_URL());
            string cmd1 = "select Parent_ID from menus where URL like '" + result + "' ";
            string Parent_id = DBClass.getField(cmd1);
            if (Parent_id == "0")
            {
                string cmd3 = "select Menu_ID from menus where URL like'" + result + "' ";
                Menu_id = DBClass.getField(cmd3);
                search_id(Parent_id);
                string M_Name = Menu_Name;
            }
            else
            {
                Menu_id = Parent_id;
                search_id(Parent_id);
                string M_Name = Menu_Name;
            }
        }

        public void search_id(string p_id)
        {
            string cmd2;
            string cmd3;
            if (p_id != "0")
            {
                cmd2 = "select Parent_ID from menus where menu_id='" + p_id + "' ";
                cmd3 = "select Menu_ID from menus where menu_id='" + p_id + "' ";
                Menu_id = DBClass.getField(cmd3);
                p_id = DBClass.getField(cmd2);
                search_id(p_id);
            }
            else
            {
                cmd2 = "select Menu_Description from menus where menu_id='" + Menu_id + "' ";
                Menu_Name = DBClass.getField(cmd2);
            }
        }
        public void generateDynamicMenu()
        {
            StringBuilder sbMenu = new StringBuilder();
            sbMenu.Append(" <ul class='nav nav-list'>");
            string childItems = getMenuItems(0);
            sbMenu.Append(childItems);
            sbMenu.Append(" </ul>");
            sidebar.InnerHtml = sbMenu.ToString();
        }

        StringBuilder sbMenu = new StringBuilder();

        int childCount = 0;

        public string getMenuItems(int parentId)
        {
            string UserName = Session["UserName"].ToString();
            string[] roles = System.Web.Security.Roles.GetRolesForUser(UserName);
            string roleName = "";
            string cmd = "";
            foreach (string role in roles)
            {
                if (roleName != "")
                    roleName += ",";
                roleName += "'" + role + "'";
            }
            using (DataBaseDataContext context = new DataBaseDataContext())
            {
                if (roleName != "")
                {
                    cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                                " INNER JOIN aspnet_roles r on rm.roleID=r.roleID inner join aspnet_UsersInRoles userinroles on r.roleID=userinroles.roleid" +
                                " where r.roleName in(" + roleName + ") AND Parent_ID=" + parentId + " AND IsActive=1 and (userinroles.company_id=" + AppConfig.Company_ID + " or userinroles.allCompany=1) order by Order_by ";
                }
                else
                {
                    cmd = "select distinct(m.Menu_ID),Menu_Name,Menu_Description,URL,Parent_ID,order_By,Isactive from menus m inner join aspnet_rolesinmenus rm on m.Menu_ID=rm.Menu_ID" +
                                  " INNER JOIN aspnet_roles r on rm.roleID=r.roleID" +
                                  " where r.roleName='user' AND IsActive=1 order by Order_by ";
                }
                DataTable dt = DBClass.getDataTable(cmd);

                foreach (DataRow dr in dt.Rows)
                {
                    string href = Page.ResolveUrl(Convert.ToString(dr["URL"]));
                    childCount = context.Menus.Count(r => r.Parent_ID == Convert.ToInt32(dr["Menu_Id"]));
                    if (childCount > 0)
                    {
                        if (Convert.ToString(dr["Menu_Description"]) == Menu_Name)
                        {

                            sbMenu.Append("<li class='active open hover hsub'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><i class='menu-icon fa'></i>" + Convert.ToString(dr["Menu_Description"]) + "</a><ul>");

                            getMenuItems(Convert.ToInt32(dr["Menu_ID"]));

                        }
                        else
                        {
                            if (haveParent(Convert.ToInt32(dr["Menu_ID"])))
                                sbMenu.Append("<li class='hover'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><i class='menu-icon fa'></i><b class='arrow fa fa-angle-down'></b>" + Convert.ToString(dr["Menu_Description"]) + "</a><ul>");
                            else
                                sbMenu.Append("<li class='hover'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><i class='menu-icon fa'></i>" + Convert.ToString(dr["Menu_Description"]) + "</a><ul>");
                            getMenuItems(Convert.ToInt32(dr["Menu_ID"]));
                            i++;
                        }

                    }
                    else
                    {
                        if (Convert.ToString(dr["Menu_Description"]) == Menu_Name)
                        {
                            sbMenu.Append("<li class='active open hover hsub'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><i class='menu-icon fa'></i>" + Convert.ToString(dr["Menu_Description"]) + "</a><ul>");
                            getMenuItems(Convert.ToInt32(dr["Menu_ID"]));
                            i++;
                        }
                        else
                        {
                            if (haveParent(Convert.ToInt32(dr["Menu_ID"])))
                                sbMenu.Append("<li class='active open hover hsub'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><b class='arrow fa fa-angle-down'></b>" + Convert.ToString(dr["Menu_Description"]) + "</a><ul>");
                            else
                                sbMenu.Append("<li class='hover'><a href=" + Page.ResolveUrl(Convert.ToString(dr["URL"])) + "><i class='menu-icon fa'></i>" + Convert.ToString(dr["Menu_Description"]) + "</a></li>");
                        }
                    }
                }

            }
            sbMenu.Append("</ul>");
            return sbMenu.ToString();
        }

        private bool haveParent(int menuId)
        {
            bool returnVal = false;
            string sql = "select count(*) from menus where parent_id=" + menuId + "";
            DataTable dt = DBClass.getDataTable(sql);
            if (dt.Rows[0][0].ToString() == "0")
                returnVal = false;
            else
                returnVal = true;

            return returnVal;
        }

        protected void HeadLoginStatus_LoggedOut(object sender, EventArgs e)
        {
            FormsAuthentication.SignOut();
            Session.Abandon();
            Session.Clear();

            // Clear .ASPXAUTH
            HttpCookie newAuthCookie = new HttpCookie(FormsAuthentication.FormsCookieName, "");
            newAuthCookie.Expires = DateTime.Now.AddYears(-1);
            newAuthCookie.Path = "/";
            Response.Cookies.Add(newAuthCookie);

            // Clear .ASPXFORMSAUTH (legacy)
            HttpCookie legacyAuthCookie = new HttpCookie(".ASPXFORMSAUTH", "");
            legacyAuthCookie.Expires = DateTime.Now.AddYears(-1);
            legacyAuthCookie.Path = "/";
            Response.Cookies.Add(legacyAuthCookie);

            Response.Redirect("~/Login.aspx", true);
        }
        protected void RightsForNotification()
        {
            DataBaseDataContext db = new DataBaseDataContext();
            var uid = AppConfig.UserID;
            var userId = (from SASD in db.Sys_Approval_Stage_Details
                          join SASM in db.Sys_Approval_Stage_Masters on SASD.Stage_ID equals SASM.Stage_ID
                          join SATD in db.Sys_Approval_Tempelate_Detail_Stages on SASM.Stage_ID equals SATD.StageId
                          where SASD.UserId == uid && SASM.IsDeleted==false
                          select SASD.UserId).FirstOrDefault();
            if (userId == null)
            {
                notification.Visible = false;
            }
            else
            {
                var formShortNames = (from sf in db.Sys_Forms
                                      where db.Sys_Approval_Tempelate_Detail_Forms
                                     .Where(tdf => db.Sys_Approval_Tempelate_Detail_Stages
                                     .Where(tds => db.Sys_Approval_Stage_Details
                                     .Where(sd => sd.UserId == userId)
                                     .Select(sd => sd.Stage_ID)
                                     .Contains(tds.StageId))
                                     .Select(tds => tds.Tempelate_ID)
                                     .Contains(tdf.Tempelate_ID))
                                     .Select(tdf => tdf.FormId)
                                     .Contains(sf.Form_ID)
                                      select sf.Form_ShortName).ToList();

                PurchaseRequisition.Visible = false;
                RFQ.Visible = false;
                CS.Visible = false;
                PO.Visible = false;
                IGP.Visible = false;
                GRN.Visible = false;
                GIR.Visible = false;
                GIN.Visible = false;
                StockAdj.Visible = false;
                StoreStockTransfer.Visible = false;
                MI.Visible = false;
                PI.Visible = false;
                Payment.Visible = false;
                advance.Visible = false;
                if (formShortNames.Any())
                {
                    notification.Visible = true;                    
                    foreach (var fsm in formShortNames)
                    {
                        switch (fsm)
                        {
                            case "PR":
                                PurchaseRequisition.Visible = true;
                                break;
                            case "RFQ":
                                RFQ.Visible = true;
                                break;
                            case "CS":
                                CS.Visible = true;
                                break;
                            case "PO":
                                PO.Visible = true;
                                break;
                            case "IGP":
                                IGP.Visible = true;
                                break;
                            case "GRN":
                                GRN.Visible = true;
                                break;
                            case "GIR":
                                GIR.Visible = true;
                                break;
                            case "GIN":
                                GIN.Visible = true;
                                break;
                            case "StockAdj":
                                StockAdj.Visible = true;
                                break;
                            case "StoreStockTransfer":
                                StoreStockTransfer.Visible = true;
                                break;
                            case "MI":
                                MI.Visible = true;
                                break;
                            case "PI":
                                PI.Visible = true;
                                break;
                            case "Payment":
                                Payment.Visible = true;
                                break;
                            case "Advance":
                                advance.Visible = true;
                                break;
                        }
                    }
                }
            }
        }
    }
}
