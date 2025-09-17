<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Subj_Definition.aspx.cs" Inherits="PMS.Modules.StudentAffair.Subj_Definition" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">

    <style type="text/css">
.custom-card {
  border: 1px solid #ddd;
  border-radius: 12px;
  box-shadow: 0 4px 10px rgba(0,0,0,0.08);
  overflow: hidden;
  margin: 20px 0;
  background: #fff;
  transition: transform 0.2s ease-in-out;
}

.custom-card:hover {
  transform: translateY(-3px);
}

.custom-card-header {
  background: linear-gradient(90deg, #007bff, #0056b3);
  padding: 12px 20px;
  color: #fff;
}

.custom-card-header h5 {
  margin: 0;
  font-size: 1.1rem;
  font-weight: 600;
}

.custom-card-body {
  padding: 20px;
}

.custom-card-body label {
  font-weight: 500;
  color: #333;
  margin-bottom: 6px;
  display: block;
}

.custom-card-body select {
  width: 100%;
  border-radius: 8px;
  padding: 6px 10px;
  border: 1px solid #ccc;
  font-size: 0.95rem;
  transition: all 0.2s ease-in-out;
}

.custom-card-body select:focus {
  border-color: #007bff;
  box-shadow: 0 0 6px rgba(0,123,255,0.4);
  outline: none;
}
.custom-card-body .row {
  margin-bottom: 1rem;
}

.tblscroll {
    height:227px !important;
    overflow-y:auto;
}
    </style>
    <script type="text/javascript">
        $(document).ready(function () {
            var dropdowns = [
                { id: '#ddlProgram', method: 'GetPrograms' },
                { id: '#ddlClass', method: 'GetStudentClass' },
                { id: '#ddlBlock', method: 'GetAcademicBlock' },
                { id: '#ddlModule', method: 'GetAcademicModule' }
            ];

            dropdowns.forEach(item => {
                const $element = $(item.id);
                $element.select2();
                $element.off('select2:open').on('select2:open', function () {
                    fillDropdown($element, item.method);
                });
            });

            // Initialize ddlClass on load
            fillDropdown($('#ddlClass'), 'GetStudentClass');

            $('#ddlProgram').on('change', Selectfunc);

            // Add subject field
            $('#btnAddSubject').on('click', addSubjectField);
            $('#newSubject').on('keypress', function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    addSubjectField();
                }
            });

            // Save button
            $('#btnSave').on('click', saveSubjectDefinition);
        });

        let subjectCounter = 0;

        function addSubjectField() {
            const subjectName = $('#newSubject').val().trim();
            if (!subjectName) {
                alert('Please enter a subject name.');
                $('#newSubject').focus();
                return;
            }

            subjectCounter++;
            const subjectId = 'subject_' + subjectCounter;

            const subjectHtml = `
        <div class="row mb-2 align-items-center" id="${subjectId}">
            <div class="col-lg-5 col-md-4 col-sm-12">
                <input type="text" class="form-control subject-name" value="${escapeHtml(subjectName)}" readonly />
            </div>
            <div class="col-lg-1 col-md-4 col-sm-12">
                <i class="fa fa-trash text-danger" style="cursor: pointer; font-size: 2.3rem;" title="Remove"></i>
            </div>
        </div>
    `;

            $('#noSubjectsMessage').hide();
            $('#subjectRowsContainer').append(subjectHtml);
            $('#newSubject').val('').focus();

            $(`#${subjectId} .fa-trash`).on('click', function () {
                $(this).closest('.row').remove();
                if ($('.fa-trash').length === 0) {
                    $('#noSubjectsMessage').show();
                }
            });
        }

        function escapeHtml(text) {
            const div = document.createElement('div');
            div.textContent = text;
            return div.innerHTML;
        }

        function getSubjects() {
            const subjects = [];
            $('.subject-name').each(function () {
                subjects.push($(this).val());
            });
            return subjects;
        }

        function fillDropdown($dropdown, methodName, callback) {
            if ($dropdown.data('filled')) {
                if (callback) callback();
                return;
            }

            var currentValue = $dropdown.val();

            $.ajax({
                type: "POST",
                url: "Subj_Definition.aspx/" + methodName,
                data: '{}',
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    try {
                        const data = JSON.parse(response.d);
                        const allOptions = [{ DataValue_Name: "", DataValue_Description: "Select" }].concat(data);

                        $dropdown.data('allOptions', allOptions);

                        let optionsHtml = '';
                        allOptions.forEach(opt => {
                            const sel = opt.DataValue_Name === currentValue ? ' selected="selected"' : '';
                            optionsHtml += `<option value="${opt.DataValue_Name}"${sel}>${opt.DataValue_Description}</option>`;
                        });

                        $dropdown.html(optionsHtml).data('filled', true).trigger('change.select2');

                        if (callback) callback();
                    } catch (e) {
                        console.error("Error parsing dropdown data:", e);
                        $dropdown.data('filled', false);
                    }
                },
                error: function (xhr, status, error) {
                    console.error("Ajax failed for dropdown:", error);
                    $dropdown.data('filled', false);
                }
            });
        }

        function Selectfunc() {
            var currentYear = new Date().getFullYear();
            var slct_value = $("#ddlProgram").val() || "";
            var pid = slct_value.replace(/^0+/, '') || slct_value;
            var $ddlClass = $('#ddlClass');
            var all = $ddlClass.data('allOptions') || [];

            if (!all.length) {
                fillDropdown($ddlClass, 'GetStudentClass', Selectfunc);
                return;
            }

            var allowedIndexes;
            switch (pid) {
                case '2':
                    allowedIndexes = [1, 2, 3, 4, 5];
                    $('#txtSession').val(currentYear + '-' + (currentYear + 5));
                    break;
                case '1':
                    allowedIndexes = [1];
                    $('#txtSession').val(currentYear + '-' + (currentYear + 2));
                    break;
                case '3':
                    allowedIndexes = [1, 2, 3, 4];
                    $('#txtSession').val(currentYear + '-' + (currentYear + 1));
                    break;
                default:
                    allowedIndexes = [];
                    for (var i = 1; i < all.length; i++) allowedIndexes.push(i);
                    $('#txtSession').val('');
            }

            let newHtml = `<option value="${all[0].DataValue_Name}">${all[0].DataValue_Description}</option>`;
            allowedIndexes.forEach(idx => {
                if (all[idx]) {
                    newHtml += `<option value="${all[idx].DataValue_Name}">${all[idx].DataValue_Description}</option>`;
                }
            });

            $ddlClass.html(newHtml).val('').trigger('change.select2');
        }

        function saveSubjectDefinition() {
            debugger;
            const program = $('#ddlProgram').val();
            const studentClass = $('#ddlClass').val();
            const block = $('#ddlBlock').val();
            const module = $('#ddlModule').val();
            const subjects = getSubjects();
            const masterId = $('#hfMasterId').val(); // Hidden field for ID
            debugger;
            if (!program || !studentClass) {
                alert('Please select Program and Class.');
                return;
            }

            if (subjects.length === 0) {
                alert('Please add at least one subject.');
                return;
            }

            const btnsave = masterId ? "Update" : "Insert";
            debugger;
            const data = {
                btnsave: btnsave,
                AllItemDetail: JSON.stringify({
                    SubjectId: masterId || "",
                    Program: program,
                    StudentClass: studentClass,
                    Block: block || null,
                    Module: module || null,
                    Subjects: subjects.map(name => ({ SubjectName: name.trim() }))
                })
            };

            $.ajax({
                type: "POST",
                url: "Subj_Definition.aspx/SaveSubjectDefinition",
                data: JSON.stringify(data),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (response.d && response.d !== "0") {
                        alert('Saved successfully!');
                        // Optionally reload or redirect
                        loadSubjectDefinition(parseInt(response.d));
                    } else {
                        alert('Failed to save. Please check inputs.');
                    }
                },
                error: function () {
                    alert('Server error. Please try again.');
                }
            });
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
     <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <div class="custom-card">
                <div class="custom-card-body">
                    <div class="row">
                        <div class="col-lg-10 col-md-12 col-sm-12">
                            <label>Program</label>
                            <select id="ddlProgram" class="form-control">
                                <option value="">Select Program</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-10 col-md-12 col-sm-12">
                            <label>Class/Year</label>
                            <select id="ddlClass" class="form-control">
                                <option value="">Select Class</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-10 col-md-12 col-sm-12">
                            <label>Block</label>
                            <select id="ddlBlock" class="form-control">
                                <option value="">Select Block</option>
                            </select>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-lg-10 col-md-12 col-sm-12">
                            <label>Module</label>
                            <select id="ddlModule" class="form-control">
                                <option value="">Select Module</option>
                            </select>
                        </div>
                    </div>
                </div>
            </div>
        </div>

         <div class="col-lg-5 col-md-6 col-sm-12">
             <div class="custom-card">
                 <div class="custom-card-body">
                     <div class="row mb-3">
                         <div class="col-lg-5 col-md-6 col-sm-12 ">
                             <input type="text" id="newSubject" class="form-control" placeholder="Enter subject name" />
                         </div>
                         <div class="col-lg-2 col-md-4 col-sm-12">
                             <i id="btnAddSubject" class="fa fa-plus-circle" style="cursor: pointer; font-size: 2.3rem;" title="Add Subject"></i>
                         </div>
                     </div>

                     <div id="subjectRowsContainer" class="tblscroll">
                     </div>
                 </div>
             </div>
         </div>       
    </div>
    <div class="row">
        <div class="col-lg-8 col-md-8 col-sm-12">
            <div class="row">
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <input type="button" id="btnSave" class="btn btn-primry" onclick="saveSubjectDefinition()" value="Save" />
                </div>
            </div>
        </div>
    </div>
<input type="hidden" id="hfMasterId" />
<input type="hidden" id="hfCurrentPath" />
</asp:Content>
