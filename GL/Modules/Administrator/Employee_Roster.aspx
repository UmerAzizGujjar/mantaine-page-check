<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Employee_Roster.aspx.cs" Inherits="PMS.Employee_Roster" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">


    <script type="text/javascript">
        $(document).ready(function () {
            loaddoctor();
            LoadMonth();
            var Rouster_id = '<%= Request.QueryString["ID"]%>';
            if (Rouster_id !=""){
            setTimeout(function () {
                LoadRousterData(Rouster_id);
                $('#btnSave').val('Update');
            }, 1000);
            }

        });  
        function loaddoctor() {
            PageMethods.LoadDoctor(function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';
                var rowsText = '';
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Emp_ID + '" >' + value.Emp_Name + '</option>';
                });
                $('#ddlDoctor').html(options)
                $('#ddlDoctor').select2();
            });
        }

        function LoadMonth() {
            PageMethods.getMonth(function (res) {
                var doctor = JSON.parse(res);
                var options = '<option value="0" >Please Select </option>';               
                $.each(doctor, function (key, value) {
                    options += '<option value="' + value.Period_ID + '" >' + value.Period_Description + '</option>';
                });
                $('#Month_id').html(options)
                $('#Month_id').select2();
            });
        }
        function LoadRousterData(Rouster_id) {
            debugger;
            PageMethods.LoadRousterData(Rouster_id, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                console.log(data)
                $('#Month_id').val(data.Period_Id).trigger('change');
                $('#ddlDoctor').val(data.Doctor_Id).trigger('change');
            });
            setTimeout(function () {
                LoadRousterDetailsData(Rouster_id);
            },2000)
          
        }
        function LoadRousterDetailsData(Rouster_id) {
            PageMethods.LoadRousterDetailsData(Rouster_id, function (resp) {
                debugger;
                var data = JSON.parse(resp);
                var tbody = $('#dtShifts tbody');
                var idCounter = 1;
                for (var i = 0; i < data.length; i++) {
                    var shift = data[i];
                    var day = shift.Week_Days;
                   var timein = moment(shift.Time_In).format('HH:mm');
                   var timeout = moment(shift.Time_Out).format('HH:mm');
                  var slot = shift.Slot;
                    $('#Time_In' + day).val(timein);
                    $('#Time_Out' + day).val(timeout);
                    $('#Slot' + day).val(slot);
                }
            });
        }
      
        function generateRoster() {
            const monthYearText = $('#Month_id option:selected').text();
            const [monthText, yearText] = monthYearText.split('-');
            const month = new Date(`${monthText} 1, 2000`).getMonth() + 1;
            const year = parseInt(yearText.trim());

            function daysInMonth(month, year) {
                return new Date(year, month, 0).getDate();
            }

            const daysInMonthCount = daysInMonth(month, year);
            const firstDayOfMonth = new Date(year, month - 1, 1);
            const firstDayWeekday = firstDayOfMonth.getDay();
            const daysInWeek = 7;

            const tbody = $('#dtShifts tbody');
            tbody.empty();

    //        const $applyRow = $(`
    //    <tr class="apply-all-row">
    //        <td colspan="7" style="background:#f8f9fa; padding:8px;">
    //            <strong>Apply to All Days:</strong> &nbsp;
    //            <label>Time In:</label>
    //            <input type="time" id="InTimeAll" style="width:120px; margin-right:10px;">
    //            <label>Time Out:</label>
    //            <input type="time" id="OutTimeAll" style="width:120px; margin-right:10px;">
    //            <label>Slot:</label>
    //            <input type="number" id="SlotAll" min="1" max="60" style="width:80px; margin-right:10px;">
    //            <button type="button" id="btnApplyAll" class="btn btn-sm btn-primary">Apply to All</button>
    //        </td>
    //    </tr>
    //`);

    //        tbody.append($applyRow);

            let $currentRow = $('<tr>');
            for (let i = 0; i < firstDayWeekday; i++) {
                $currentRow.append('<td></td>');
            }

            for (let day = 1; day <= daysInMonthCount; day++) {
                const formattedDate = formatDate(day, month, year);
                const Time_In_Id = 'Time_In' + day;
                const Time_Out_Id = 'Time_Out' + day;
                const Slot_Id = 'Slot' + day;

                const $cell = $('<td>');
                $cell.append(`<input type="hidden" id="Date_${day}" name="Date_${day}" value="${formattedDate}">`);
                $cell.append(`<label>${day}</label><br>`);
                $cell.append(`<label>Time In</label><br><input type="time" id="${Time_In_Id}" style="width:100%;"><br>`);
                $cell.append(`<label>Time Out</label><br><input type="time" id="${Time_Out_Id}" style="width:100%;"><br>`);
                $cell.append(`<label>Slot</label><br><input type="number" id="${Slot_Id}" min="1" max="60" style="width:100%;">`);

                $currentRow.append($cell);

                if ((day + firstDayWeekday) % daysInWeek === 0 || day === daysInMonthCount) {
                    tbody.append($currentRow);
                    $currentRow = $('<tr>');
                }
            }

            if ($currentRow.children().length > 0) {
                tbody.append($currentRow);
            }

            $(document).off('click', '#btnApplyAll').on('click', '#btnApplyAll', function () {
                const inTimeAll = $('#InTimeAll').val();
                const outTimeAll = $('#OutTimeAll').val();
                const slotAll = $('#SlotAll').val();

                for (let day = 1; day <= daysInMonthCount; day++) {
                    if (inTimeAll) $('#Time_In' + day).val(inTimeAll);
                    if (outTimeAll) $('#Time_Out' + day).val(outTimeAll);
                    if (slotAll) $('#Slot' + day).val(slotAll);
                }
            });
        }

        function formatDate(day, month, year) {
            const d = String(day).padStart(2, '0');
            const m = String(month).padStart(2, '0');
            return `${year}-${m}-${d}`;
        }



        function formatDate(day, month, year) {
            const d = String(day).padStart(2, '0');
            const m = String(month).padStart(2, '0');
            return `${year}-${m}-${d}`;
        }

        function MonthChage() {
            setTimeout(function () { generateRoster(); })
        }


        debugger
        function SaveAllRecord() {
            debugger;
            var Rouster_id = '<%= Request.QueryString["ID"] %>';
            if (Rouster_id == '') {
                Rouster_id = 0;
            }
            var btnSave = $('#btnSave').val();
            var Details = [];
            var Period_Id = $('#Month_id').val();
            var month = $('#Month_id option:selected').text();
            var Emp_id = $('#ddlDoctor').val();
            if (month == '0' || month == "0") {
                alert('Please Select Month');
                return
            }
            if (Emp_id == '0' || Emp_id == "0") {
                alert('Please Select Doctor');
                return
            }
            if (btnSave == 'Save') {
                PageMethods.CheckDoctorRoster(Emp_id, Period_Id, function (exists) {
                    if (exists) {
                        alert('This Doctor already has a Roster for the Selected Month.');
                        return;
                    } else {
                        $('#dtShifts tbody tr').each(function () {
                            $(this).find('td').each(function () {
                                debugger;
                                const dayLabel = $(this).find('label[for^="Day"]').text();
                                const dateLabels = $(this).find('input[name^="Date_"]');
                                const timeInInput = $(this).find('input[name^="Time_In"]');
                                const timeOutInput = $(this).find('input[name^="Time_Out"]');
                                const slotInput = $(this).find('input[name^="Slot"]');
                                const dateLabel = dateLabels.val();
                                const time_in = timeInInput.val();
                                const time_out = timeOutInput.val();
                                const slot = slotInput.val();
                                if (dayLabel && time_in && time_out && slot) {
                                    Details.push({
                                        dayLabel: dayLabel,
                                        time_in: time_in,
                                        time_out: time_out,
                                        slot: slot,
                                        dateLabel: dateLabel
                                    });
                                }
                            });
                        });
                        var AllRecord = {
                            btnSave: btnSave,
                            Rouster_id: Rouster_id,
                            month: month,
                            Emp_id: Emp_id,
                            Details: Details,
                            Period_Id: Period_Id
                        };
                        debugger;
                        PageMethods.SaveRecord(JSON.stringify(AllRecord), function (resp) {
                            debugger;
                            alert('Data Successfully Saved');
                            window.location = "Employee_Roster.aspx"
                        }, function (error) {
                            alert(error.get_message());
                        });
                    }
                });
            }
            else {
                $('#dtShifts tbody tr').each(function () {
                    $(this).find('td').each(function () {
                        debugger;
                        const dayLabel = $(this).find('label[for^="Day"]').text();
                        const dateLabels = $(this).find('input[name^="Date_"]');
                        const timeInInput = $(this).find('input[name^="Time_In"]');
                        const timeOutInput = $(this).find('input[name^="Time_Out"]');
                        const slotInput = $(this).find('input[name^="Slot"]');
                        const dateLabel = dateLabels.val();
                        const time_in = timeInInput.val();
                        const time_out = timeOutInput.val();
                        const slot = slotInput.val();
                        if (dayLabel && time_in && time_out && slot) {
                            Details.push({
                                dayLabel: dayLabel,
                                time_in: time_in,
                                time_out: time_out,
                                slot: slot,
                                dateLabel: dateLabel
                            });
                        }
                    });
                });
                var AllRecord = {
                    btnSave: btnSave,
                    Rouster_id: Rouster_id,
                    month: month,
                    Emp_id: Emp_id,
                    Details: Details,
                    Period_Id: Period_Id
                };
                debugger;
                PageMethods.SaveRecord(JSON.stringify(AllRecord), function (resp) {
                    debugger;
                    alert('Data Successfully Saved');
                    window.location = "Employee_Roster.aspx?ID=" + Rouster_id
                }, function (error) {
                    alert(error.get_message());
                });
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">

    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12">
                <div class="ibox-content to_in_put_bor_der">
                    <form class="form-horizontal" asp-controller="Create" method="post">
                        <div asp-validation-summary="ModelOnly" class="text-danger"></div>
                        <div class="row">
                            <div class="col-lg-2 col-md-4 cols-m-6">                                                            
                                <div class="md-form md-outline form-sm">
                                <label  class="control-label" >Month</label>                                
                                     <select id="Month_id" onchange="MonthChage()">
                                        </select>
                                </div>
                            </div>
                           
                            <div class="col-lg-2 col-md-4 cols-m-6">
                                <label  class="control-label">Doctor Name</label>
                                <div class="md-form md-outline form-sm">
                                    <Select  id="ddlDoctor" name="ddlDoctor">
                                    </Select>
                                </div>
                            </div>
                           
                         <div class="col-lg-2 col-md-4 cols-m-6">
                                <label  class="control-label">Time In</label>
                                <div class="md-form md-outline form-sm">
                               <input type="time" id="InTimeAll" />
                                </div>
                            </div>
                           
                            <div class="col-lg-2 col-md-4 cols-m-6">
                                <label  class="control-label">Time Out</label>
                                <div class="md-form md-outline form-sm">
                               <input type="time" id="OutTimeAll" />
                                </div>
                            </div>
                           
                            <div class="col-lg-2 col-md-4 cols-m-6">
                                <label  class="control-label">Slot</label>
                                <div class="md-form md-outline form-sm">
                               <input type="number" id="SlotAll" />
                                </div>
                            </div>
                            <div class="col-lg-2 col-md-4 col-sm-6">
                                <label></label>
                                <input type="button" class="btn btn-primry" value="Apply to All"  id="btnApplyAll" />
                            </div>
                        </div>
                          <div id="roster" class="roster"></div>
                        <div class="row">
                            <div class="col-lg-12 col-md-24 cols-m-12">
                                <table class="table table-resposnive table-striped to_giv_wid" style="margin-top:30px; width:100% !important;" id="dtShifts">
                                    <thead>
                                        <tr>                                    
                                            <th class="bg-info">Sunday</th>
                                            <th class="bg-success">Monday</th>
                                            <th class="bg-primary">Tuesday</th>
                                            <th class="bg-warning">Wednesday</th>
                                            <th class="bg-danger">Thursday</th>
                                            <th class="bg-primary">Friday</th>
                                            <th class="bg-success">Saturday</th>
                                        </tr>
                                    </thead>
                                    <tbody id="calendarContainer" class="calendar">                                                       
                                    </tbody>
                                </table>
                            </div>
                            <div class="row">
                               <div class="col-lg-8">
                                    
                                <div class="col-lg-2 col-md-2 col-sm-3">
                                   <input type="button" class="btn btn-primry" value="Save" onclick="SaveAllRecord()" id="btnSave" />
                                </div>
                                  <div class="col-lg-2 col-md-2 col-sm-3">
                                   <input type="button" value="Add New" class="btn btn-yellow" onclick="window.location = 'Employee_Roster.aspx'" id="btnAddNew" />
                                </div>
                                 <div class="col-lg-2 col-md-2 col-sm-3">
                                   <input type="button" value="View List" class="btn-gray" onclick="window.location = 'Employee_Roster_List.aspx'" id="btnlist" />
                                </div>
                               </div>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

</asp:Content>
