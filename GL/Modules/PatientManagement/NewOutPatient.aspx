<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="NewOutPatient.aspx.cs" Inherits="PMS.Modules.PatientManagement.NewOutPatient" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
         .card {
     border: 1px solid #ccc;
     transition: all 0.3s ease;
     border-radius: 10px;
     padding: 20px;
     
 }




 .card:hover {
     box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
 }
       .page-header{
           display:none;
       }
        .no-submenu {
            color: #495057;
            font-weight: 500;
            font-size: 15px
        }

            .no-submenu:hover {
                background-color: #d1ecf1;
                color: #0c5460;
            }

      
      .sidebarr {
    background-color: #f8f9fa;
    border-right: 1px solid #dee2e6;
    padding: 0;
    /* Remove overflow-y and height */
}
        .menu-item {
            cursor: pointer;
            padding: 15px 20px;
            border-bottom: 1px solid #dee2e6;
            transition: background-color 0.3s;
            font-size: 15px
        }

            .menu-item:hover {
                background-color: #e9ecef;
            }

        .menu-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .submenu {
            max-height: 0;
            overflow: hidden;
            transition: max-height 0.3s ease-out;
            background-color: #fff;
        }

        .submenu-item {
            padding: 12px 20px 12px 40px;
            border-bottom: 1px solid #f1f1f1;
            cursor: pointer;
        }

            .submenu-item:hover {
                background-color: #f1f1f1;
            }

        .menu-item.active .submenu {
            max-height: 500px;
        }

        .menu-item.active .toggle-icon::after {
            content: "−";
        }

        .toggle-icon::after {
            content: "+";
            font-weight: bold;
        }
    </style>

    <script>
        // Toggle submenu for items with dropdowns
        function toggleMenu(element) {
            // Toggle active class (expand/collapse submenu)
            element.classList.toggle('active');
        }

        // Handle click for items without submenu (e.g., navigation, actions)
        function navigateAction(element) {
            const menuText = element.querySelector('.menu-title span').textContent;

            // Example action: show alert
            alert(`${menuText} clicked! This item has no submenu.`);

            // You can replace this with actual navigation:
            // Example: 
            // if (menuText === 'Profile') {
            //     window.location.href = '/profile';
            // } else if (menuText === 'Help & Support') {
            //     window.location.href = '/help';
            // }
        }

        // Optional: Close all open submenus when clicking outside the sidebarr
        document.addEventListener('click', function (e) {
            const sidebarr = document.querySelector('.sidebarr');
            if (!sidebarr.contains(e.target)) {
                // Only close expandable menus (skip no-submenu items)
                document.querySelectorAll('.menu-item').forEach(item => {
                    if (!item.classList.contains('no-submenu')) {
                        item.classList.remove('active');
                    }
                });
            }
        });
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-6">
            <div class="card">
                <div class="card-body">
                     <div class="row">
     <div class="col-lg-4 col-md-5 col-sm-6 text-center">
         <div class="image-container">
             <img src="~../../../../wwwroot/Tibbit_theme/images/dashboard_Icons/Patient.png" alt="Patient Image" class="img-fluid rounded-circle patient-image" />
         </div>
     </div>
     <div class="col-lg-8 col-md-7 col-sm-6">
         <asp:TextBox ID="txtOut_Patient_ID" runat="server" ReadOnly="True" style="display:none;"></asp:TextBox>

         <div class="row mb-3">
             <div class="col-lg-5 col-md-5 col-sm-6 top">
                 <asp:Label ID="lblPatient_Name" runat="server" Text="Patient Name:"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="vlblPatients_Name" CssClass="md" runat="server"></asp:Label>
             </div>
         </div>

         <div class="row mb-3 mtt">
             <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                 <asp:Label ID="lblAge_Years" runat="server" Text="Age (Years):"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="vLbl_Age" CssClass="md" runat="server"></asp:Label>
             </div>
         </div>

         <div class="row mb-3 mtt">
             <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                 <asp:Label ID="lblContactNo" runat="server" Text="Contact No:"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="vLbl_Contact" CssClass="md" runat="server"></asp:Label>
             </div>
         </div>

         <div class="row mb-3 mtt">
             <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                 <asp:Label ID="lblGender" runat="server" Text="Gender:"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="vLbl_Gender" CssClass="md" runat="server"></asp:Label>
             </div>
         </div>

         <div class="row mb-3 mtt">
             <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                 <asp:Label ID="Label10" runat="server" Text="Category:"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="lblPatient_Category" CssClass="md" runat="server"></asp:Label>
             </div>
         </div>

         <div class="row mb-3">
             <div class="col-lg-5 col-md-5 col-sm-6 formrgn">
                 <asp:Label ID="lblAdress" runat="server" Text="Address:"></asp:Label>
             </div>
             <div class="col-lg-7 col-md-7 col-sm-6 top">
                 <asp:Label ID="vLbl_Adress" CssClass="md" runat="server"></asp:Label>
             </div>                          
         </div>
     </div>
 </div>
                </div>
            </div>
        </div>
         <div class="col-6">
     <div class="card">
         <div class="card-body">

         </div>
     </div>
 </div>
    </div>
    <div class="row">
       
                <div class="col-lg-2 col-md-2 col-sm-2 p-0">
                    <div class="sidebarr">

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Symptoms</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>History</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Examination</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">General</div>
                                <div class="submenu-item">Systematic</div>
                                <div class="submenu-item">Special</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Refer To</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Tests</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">By Template</div>
                                <div class="submenu-item">Add New</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Services</span>
                            </div>
                        </div>

                        <div class="menu-item" onclick="toggleMenu(this)">
                            <div class="menu-title">
                                <span>Medication</span>
                                <span class="toggle-icon"></span>
                            </div>
                            <div class="submenu">
                                <div class="submenu-item">By Template</div>
                                <div class="submenu-item">Add New</div>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Follow Up</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Disposal</span>
                            </div>
                        </div>

                        <div class="menu-item no-submenu" onclick="navigateAction(this)">
                            <div class="menu-title">
                                <span>Test Results</span>
                            </div>
                        </div>


                    </div>
                </div>
        <div class="col-lg-4">
            <div class="card">
    <div class="card-body">

    </div>
</div>
        </div>
        <div class="col-lg-6">
             <div class="card">
     <div class="card-body">

     </div>
 </div>
        </div>
            </div>

      

</asp:Content>
