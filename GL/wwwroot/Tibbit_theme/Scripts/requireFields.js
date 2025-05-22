function fn_init() {
            $("#aspnetForm").validate({
                rules: {
                    <%=txtPatient_No.UniqueID %>: {
                        required: true
                    },
                    <%=txtFirst_Name.UniqueID %>: {
                        required: true
                    },
                    <%=txtLast_Name.UniqueID %>: {
                        required: true
                    },

                     <%=txtEmail.UniqueID %>: {                                                
                        email: true
                    },
                    <%=txtEntry_Date.UniqueID %> : {
                        required: true,
                        date: true
                    },
                    <%=txtHome_Phone.UniqueID %> : {
                        required:true
                    },
                    <%=txtCell_Phone.UniqueID %> : {
                        required:true
                    },
                    <%=txtAddress.UniqueID %> : {
                        required:true
                    },
                    <%=txtBirth_Date.UniqueID %>:{
                        date: true
                    },
                    <%=txtVocations_In_Past_Two_Years.UniqueID %>:{
                        number: true
                    },
                    <%=txtNo_Of_Hours_Sleep_Per_Day.UniqueID %>:{
                        number: true
                    },
                    <%=txtWorking_Hours_Per_Week.UniqueID %>:{
                        number:true
                    }
                    
              }
            });
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_initializeRequest(onEachRequest);
        }

        function onEachRequest(sender, args) {
            if ($("#aspnetForm").valid() == false) {
                args.set_cancel(true);
            }
        } 
        
        function _valid(){
            var p = Sys.WebForms.PageRequestManager.getInstance();
            p.add_initializeRequest(onOtherRequest);
        }
        function onOtherRequest(sender, args) {
                args.set_cancel(false);
        }	