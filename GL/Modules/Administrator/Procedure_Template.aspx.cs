using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS.Modules.Administrator
{
    public partial class Procedure_Template : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        [WebMethod]
        public static void SaveProcedureTemplate(List<ProcedureValue> procedure_values)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                foreach (var item in procedure_values)
                {
                    if (!string.IsNullOrEmpty(item.ProcedureLevelID))
                    {
                        var itemToUpdate = db.ProcedureLevels.FirstOrDefault(i => i.ProcedureLevel_ID == Convert.ToInt32(item.ProcedureLevelID));
                        if (itemToUpdate != null)
                        {
                            itemToUpdate.TemplateName = item.TemplateName;
                            itemToUpdate.FixValues = item.FixValues;
                            itemToUpdate.Updated_By = AppConfig.UserID;
                            itemToUpdate.Updated_Time = DateTime.Now;
                        }
                    }
                    else
                    {
                        ProcedureLevel obj = new ProcedureLevel();
                        obj.Created_By = AppConfig.UserID;
                        obj.TemplateName = item.TemplateName;
                        obj.FixValues = item.FixValues;
                        obj.Created_Time = DateTime.Now;
                        db.ProcedureLevels.InsertOnSubmit(obj);
                    }
                }
                db.SubmitChanges();
            }
        }


        public class ProcedureValue
        {
            public string ProcedureLevelID { get; set; } 
            public string TemplateName { get; set; }
            public string FixValues { get; set; }
        }

        [WebMethod]
        public static ProcedureValue GetProcedureTemplate(int id)
        {
            using (DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString()))
            {
                var template = db.ProcedureLevels.FirstOrDefault(p => p.ProcedureLevel_ID == id);
                if (template != null)
                {
                    return new ProcedureValue
                    {
                        ProcedureLevelID = template.ProcedureLevel_ID.ToString(),
                        TemplateName = template.TemplateName,
                        FixValues = template.FixValues
                    };
                }
                return null;
            }
        }
    }
}