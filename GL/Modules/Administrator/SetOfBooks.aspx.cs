using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace PMS
{
    public partial class SetOfBooks : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
           
            if (!IsPostBack)
            {
                if (Request.QueryString["ID"] != null)
                {
                    FillForm(Convert.ToInt32(Request.QueryString["ID"]));
                }
                else
                    txtBook_ID.Text = "(New)";
            }
        }

        private void FillForm(int Book_ID)
        {
            DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
            GL_SetOfBook setOfBook = (from tbl in db.GL_SetOfBooks
                                      where tbl.Book_ID == Book_ID
                                      select tbl).FirstOrDefault();
            if (setOfBook != null)
            {
                txtBook_ID.Text = Book_ID.ToString();
                txtName.Text = setOfBook.Name;
                btnSave.Text = "Update";
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                DataBaseDataContext db = new DataBaseDataContext(DBClass.ConnectionString());
                GL_SetOfBook setOfBook;
                int book_ID = 0;
                if (txtBook_ID.Text == "(New)")
                {
                    setOfBook = (from tbl in db.GL_SetOfBooks
                                 where tbl.Name == txtName.Text
                                 select tbl).FirstOrDefault();
                }
                else
                {
                    book_ID = Convert.ToInt32(txtBook_ID.Text);
                    setOfBook = (from tbl in db.GL_SetOfBooks
                                 where tbl.Name == txtName.Text && tbl.Book_ID != book_ID
                                 select tbl).FirstOrDefault();
                }
                if (setOfBook != null)
                {
                    lblMessage.Text = "Set of book already exists.";
                    lblMessage.CssClass = "errorMessage";
                }
                else
                {
                    if (txtBook_ID.Text == "(New)")
                    {
                        setOfBook = new GL_SetOfBook();
                        db.GL_SetOfBooks.InsertOnSubmit(setOfBook);
                        lblMessage.Text = "Data has been saved sucessfully";
                    }
                    else
                    {
                        setOfBook = (from tbl in db.GL_SetOfBooks
                                     where  tbl.Book_ID == book_ID
                                     select tbl).FirstOrDefault();
                        lblMessage.Text = "Data has been updated sucessfully";
                    }
                    setOfBook.Name = txtName.Text;
                    db.SubmitChanges();
                    lblMessage.CssClass = "sucessfullMessage";
                }
            }
            catch (Exception ex)
            {
                lblMessage.Text = ex.ToString();
                lblMessage.CssClass = "errorMessage";
                throw;
            }
        }
    }
}