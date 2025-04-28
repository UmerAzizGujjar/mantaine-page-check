<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="AdministrationSection.aspx.cs" Inherits="PMS.AdministrationSection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container">

        <div class="row">
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="Employee.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Employee.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Add Employee</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="WardDefinition.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Ward_Definition.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Ward Definition</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="WardAllocation.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Ward_Allotment.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Ward Re-Allocation</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="Hostel.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Hostel.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Hostel</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="Room.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Room_Hostle.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Room Definition</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="RoomAllocation.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Room_Allocation.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Room Re-Allocation</h5>
                </a>
            </div>
        </div>
        <div class="row">
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="AP/Vendor.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Supplier.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Supplier</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="Inventory/Items.aspx">
                    <img class="center-block" src="images/HMIS_Icons/PhamacyProduct.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Pharmacy Product</h5>
                </a>
            </div>
            <div class="col-sm-2 cc">
                <a class="btn btn-coco radius-4" href="AR/Customer.aspx">
                    <img class="center-block" src="images/HMIS_Icons/Customer.jpg" width="80px" alt="" />
                    <h5 class="cocotxt">Customer</h5>
                </a>
            </div>
        </div>

    </div>
</asp:Content>
