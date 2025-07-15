$(function () {
 
    $('#btnimageUpload').fileupload({
     
        url: 'FileUploadHandler.ashx?upload=start',
        add: function (e, data) {
            console.log('add', data);
            $('#progressbar').show();
            data.submit();
        },
        progress: function (e, data) {
            var progress = parseInt(data.loaded / data.total * 100, 10);
            $('#progressbar div').css('width', progress + '%');
        },
        success: function (response, status) {
            $('#progressbar').hide();
            $('#progressbar div').css('width', '0%');
            console.log('success', response);
            var returnVal = response.split(":");
            var fileName = returnVal[0];
            var serverfileName = returnVal[1];

            $("#fileUploader").append("<tr><td colspan='2'>" + fileName + "</td></tr>");
            var newfiles = $("#hdnNewFiles").val();
            if (newfiles == "") {
                newfiles = response;
            }
            else {
                newfiles = newfiles + "|" + response; //  | splitter means new file. : means uploader file name & actual name
            }
            $("#hdnNewFiles").val(newfiles);

            
        },
        error: function (error) {
            $('#progressbar').hide();
            $('#progressbar div').css('width', '0%');
            console.log('error', error);
        }
    });
   
});


