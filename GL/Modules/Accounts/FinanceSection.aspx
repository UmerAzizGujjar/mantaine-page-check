lll<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="FinanceSection.aspx.cs" Inherits="PMS.FinanceSection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">

        <div class="row">
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="AR/Invoice.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Invoice.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Sale Invoice</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="AP/PurchaseOrder.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Purchase_Invoice.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Purchase Invoice</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="GL/ChartofAccounts.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Chart_Of_Accounts.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Chart Of Accounts</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="Billing.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Billing.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Patient Billing</h5>
                </a>
            </div>
        </div>

    </div>
</asp:Content>
