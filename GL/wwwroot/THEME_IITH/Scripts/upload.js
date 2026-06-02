$(function () {

    $('#FileUpload1').fileupload({

        url: 'FileUploadHandler.ashx?upload=start',
        add: function (e, data) {
            console.log('add', data);
            data.submit();
        },
        progress: function (e, data) {
            //var progress = parseInt(data.loaded / data.total * 100, 10);
            //$('#progressbar div').css('width', progress + '%');
        },
        success: function (response, status) {
   
            //$('#progressbar').hide();
            //$('#progressbar div').css('width', '0%');
           
            console.log('success', response);
            var returnVal = response.split(":");
            var fileName = returnVal[1];
            var testDID = $('#testDetailID').val();
            //var image = $("#hdnNewFiles").val();
            var TestID = $("#mTestID").val();

            var ParentTransactionType = $("#ParentTransactionType").val();
            var Parent_Transaction_Type_ID = $("#ParentTransactionType_ID").val();
            // var Patient_ID = $("#<%= hdnPatient_ID.ClientID %>").val();
            if (fileName != null) {
                var data = JSON.stringify({ TestDetailID: testDID, filename: fileName, TestID: TestID, ParentTransactionType: ParentTransactionType, Parent_Transaction_Type_ID: Parent_Transaction_Type_ID });

                $.ajax({
                    type: "POST",
                    url: "LabTestResult.aspx/SaveTestImages",
                    data: data,
                    contentType: "application/json; charset=utf-8",
                    dataType: "json",
                    success: function (data) {
                        //SaveImages();
                        //$('#mTestValue').val('');
                        //$('#mTestTemplate').val('');
                        //$('#mTestDiagnosis').val('');
                        //$('#mTestNotes').val('');
                        //$('#myModal').modal('hide');
                    },
                    failure: function (response) {
                        alert(response.d);
                    }
                });
            }
        },
        error: function (error) {
            $('#progressbar').hide();
            $('#progressbar div').css('width', '0%');
            console.log('error', error);
        }
    });

});