$(function () {

    //default date on page load
    $("#ctl00_MainContent_txtEntry_Date").val($.datepicker.formatDate('dd.mm.yy', new Date()));
    $("#ctl00_MainContent_txtIntake_Date").val($.datepicker.formatDate('dd.mm.yy', new Date()));

    //jquery tabs control 
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
        $("#tabs").tabs();
    });

    //attach calender to datetime picker
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
        $("#ctl00_MainContent_txtEntry_Date").datepicker({ dateFormat: 'dd.mm.yy' });
        $("#ctl00_MainContent_txtBirth_Date").datepicker({ dateFormat: 'dd.mm.yy' });
        $("#ctl00_MainContent_txtIntake_Date").datepicker({ dateFormat: 'dd.mm.yy' }); 
    });

    //check box to disable/enable textbox of issurer name
    Sys.WebForms.PageRequestManager.getInstance().add_pageLoaded(function (evt, args) {
        //Issurer check box
        $("#ctl00_MainContent_chkInsured").change(function () {
            var isCheck = $("#ctl00_MainContent_chkInsured").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtInsurer").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtInsurer").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkInsured").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkInsured").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtInsurer").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtInsurer").removeAttr("disabled");
        });

        //Smoke check box
        $("#ctl00_MainContent_chkSmoke").change(function () {
            var isCheck = $("#ctl00_MainContent_chkSmoke").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtSmoke_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtSmoke_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkSmoke").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkSmoke").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtSmoke_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtSmoke_Description").removeAttr("disabled");
        });

        //Alcohol check box
        $("#ctl00_MainContent_chkAlcohol").click(function () {
            var isCheck = $("#ctl00_MainContent_chkAlcohol").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtAlcohol_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtAlcohol_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkAlcohol").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkAlcohol").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtAlcohol_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtAlcohol_Description").removeAttr("disabled");
        });

        //Narcotics check box
        $("#ctl00_MainContent_chkNarcotics").click(function () {
            var isCheck = $("#ctl00_MainContent_chkNarcotics").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtNarcotics_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtNarcotics_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkNarcotics").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkNarcotics").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtNarcotics_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtNarcotics_Description").removeAttr("disabled");
        });

        //Amalgam_Filling check box
        $("#ctl00_MainContent_chkAmalgam_Filling").click(function () {
            var isCheck = $("#ctl00_MainContent_chkAmalgam_Filling").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtAmalgam_Filling_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtAmalgam_Filling_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkAmalgam_Filling").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkAmalgam_Filling").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtAmalgam_Filling_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtAmalgam_Filling_Description").removeAttr("disabled");
        });

        //Bite_Adjusted check box
        $("#ctl00_MainContent_chkBite_Adjusted").click(function () {
            var isCheck = $("#ctl00_MainContent_chkBite_Adjusted").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtBite_Adjusted_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtBite_Adjusted_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkBite_Adjusted").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkBite_Adjusted").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtBite_Adjusted_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtBite_Adjusted_Description").removeAttr("disabled");
        });

        //Root_Canals check box
        $("#ctl00_MainContent_chkRoot_Canals").click(function () {
            var isCheck = $("#ctl00_MainContent_chkRoot_Canals").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtRoot_Canals_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtRoot_Canals_Description").removeAttr("disabled");
        });
        $("#ctl00_MainContent_chkRoot_Canals").attr("change", function () {
            var isCheck = $("#ctl00_MainContent_chkRoot_Canals").attr("checked") ? true : false;
            if (!isCheck)
                $("#ctl00_MainContent_txtRoot_Canals_Description").attr("disabled", "disabled");
            else
                $("#ctl00_MainContent_txtRoot_Canals_Description").removeAttr("disabled");
        });
    });

});