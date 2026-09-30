<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Subj_Definition.aspx.cs" Inherits="PMS.Modules.StudentAffair.Subj_Definition" %>

<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <link href="../../wwwroot/THEME_TIBBIT/CustomCSS/SubjDefinintion.css" rel="stylesheet" />
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

                $element.off('select2:opening').on('select2:opening', function (e) {
                    if (!$element.data('filled')) {
                        e.preventDefault();
                        $element.data('shouldReopen', true);
                        fillDropdown($element, item.method);
                    }
                });
            });


            const subjectId = getParameterByName('ID');
            if (subjectId) {
                loadSubjectDefinition(parseInt(subjectId));
                $("#btnSave").val('Update');
            } else {
                fillDropdown($('#ddlClass'), 'GetStudentClass');
            }

            $('#ddlProgram').on('change', Selectfunc);

            $('#btnAddSubject').on('click', addSubjectField);
            $('#newSubject').on('keypress', function (e) {
                if (e.which === 13) {
                    e.preventDefault();
                    addSubjectField();
                }
            });

        });

        function getParameterByName(name, url = window.location.href) {
            name = name.replace(/[\[\]]/g, '\\$&');
            var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)'),
                results = regex.exec(url);
            if (!results) return null;
            if (!results[2]) return '';
            return decodeURIComponent(results[2].replace(/\+/g, ' '));
        }
        let subjectCounter = 0;

        function addSubjectField() {
            const subjectName = $('#newSubject').val().trim();
            if (!subjectName) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please enter a subject name.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                $('#newSubject').focus();
                return;
            }

            subjectCounter++;
            const subjectId = 'subject_' + subjectCounter;

            const subjectHtml = `
        <div class="row mb-2 align-items-center" id="${subjectId}">
            <div class="col-lg-6 col-md-4 col-sm-12">
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
            $('#subjectRowsContainer .row').each(function () {
                const $row = $(this);
                const subjectName = $row.find('.subject-name').val().trim();
                const isActive = $row.find('.subject-active').length ? $row.find('.subject-active').is(':checked') : true;

                if (subjectName) {
                    subjects.push({
                        SubjectName: subjectName,
                        IsActive: isActive
                    });
                }
            });
            return subjects;
        }


        function fillDropdown($dropdown, methodName, callback) {
            if ($dropdown.data('filled')) {
                if (callback) callback();
                return;
            }


            $dropdown.html('<option value="">Loading...</option>').trigger('change.select2');

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

                        if ($dropdown.data('shouldReopen')) {
                            $dropdown.data('shouldReopen', false);
                            setTimeout(() => {
                                $dropdown.select2('open');
                            }, 50);
                        }

                        if (callback) callback();
                    } catch (e) {
                        $dropdown.data('filled', false);
                        $dropdown.html('<option value="">Error loading</option>').trigger('change.select2');
                    }
                },
                error: function (xhr, status, error) {
                    $dropdown.data('filled', false);
                    $dropdown.html('<option value="">Load failed</option>').trigger('change.select2');
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

            if (pid === '2') {
                allowedIndexes = [1, 2, 3, 4, 5];
                $('#txtSession').val(currentYear + '-' + (currentYear + 5));
            }
            else if (pid === '1') {
                allowedIndexes = [1];
                $('#txtSession').val(currentYear + '-' + (currentYear + 2));
            }
            else if (pid === '3') {
                allowedIndexes = [1, 2, 3, 4];
                $('#txtSession').val(currentYear + '-' + (currentYear + 1));
            }
            else {
                allowedIndexes = [];
                for (var i = 1; i < all.length; i++) {
                    allowedIndexes.push(i);
                }
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
            const program = $('#ddlProgram').val();
            const studentClass = $('#ddlClass').val();
            const block = $('#ddlBlock').val();
            const module = $('#ddlModule').val();
            const subjects = getSubjects();
            const masterId = $('#hfMasterId').val();
            if (!program) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select Program and Class.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });

                return;
            }

            if (!studentClass) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select Class.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }
            if (studentClass !== "04" && studentClass !== "05" && (!block || !module)) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please select Block or Module first.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }



            if (subjects.length === 0) {
                Swal.fire({
                    icon: 'error',
                    title: 'Error!',
                    text: 'Please add at least one subject.',
                    showConfirmButton: false,
                    timer: 2000,
                    customClass: {
                        popup: 'swal-big-popup',
                        title: 'swal-big-title',
                        htmlContainer: 'swal-big-text'
                    }
                });
                return;
            }

            const btnsave = masterId ? "Update" : "Insert";
            const data = {
                btnsave: btnsave,
                AllItemDetail: JSON.stringify({
                    SubjectId: masterId || "",
                    Program: program,
                    StudentClass: studentClass,
                    Block: block || null,
                    Module: module || null,
                    Subjects: subjects.map(item => ({
                        SubjectName: item.SubjectName.trim(),
                        IsActive: item.IsActive
                    }))
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
                        Swal.fire({
                            icon: 'success',
                            title: 'Success!',
                            text: 'Data Saved successfully!',
                            showConfirmButton: false,
                            timer: 2500,
                            customClass: {
                                popup: 'swal-big-popup',
                                title: 'swal-big-title',
                                htmlContainer: 'swal-big-text'
                            }
                        });
                        window.location.href = "SubjectList.aspx";
                    } else {
                        alert('Failed to save. Please check inputs.');
                    }
                },
                error: function () {
                    alert('Server error. Please try again.');
                }
            });
        }

        function loadSubjectDefinition(subjectId) {
            $.ajax({
                type: "POST",
                url: "Subj_Definition.aspx/GetSubjectDefinitionById",
                data: JSON.stringify({ id: subjectId.toString() }),
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                success: function (response) {
                    if (!response.d) {
                        alert('Failed to load subject definition.');
                        return;
                    }

                    const data = JSON.parse(response.d);

                    $('#hfMasterId').val(data.SubjectId);

                    $('#ddlProgram').html(
                        $('<option>', {
                            value: data.Program,
                            text: data.Program_Text
                        })
                    );


                    $('#ddlClass').html(
                        $('<option>', {
                            value: data.StudentClass,
                            text: data.StudentClass_Text
                        })
                    );

                    $('#ddlBlock').html(
                        $('<option>', {
                            value: data.Block,
                            text: data.Block_Text
                        })
                    );

                    $('#ddlModule').html(
                        $('<option>', {
                            value: data.Module,
                            text: data.Module_Text
                        })
                    );

                    $('#subjectRowsContainer').empty();
                    if (data.Subjects && data.Subjects.length > 0) {
                        $('#noSubjectsMessage').hide();
                        data.Subjects.forEach(subject => {
                            addSubjectFieldFromData(subject.SubjectName, subject.IsActive, true);
                        });
                    } else {
                        $('#noSubjectsMessage').show();
                    }

                },
                error: function () {
                    alert('Error loading subject definition.');
                }
            });
        }

        function addSubjectFieldFromData(subjectName, isActive = true, isEditMode = false) {
            subjectCounter++;
            const subjectId = 'subject_' + subjectCounter;

            let checkboxHtml = '';
            if (isEditMode) {
                checkboxHtml = `
            <div class="col-lg-1 col-md-2 col-sm-12 d-flex align-items-center">
                <label class="form-check mb-0">
                    <input type="checkbox" class="form-check-input subject-active" ${isActive ? 'checked' : ''} />
                    <span class="form-check-label ms-1" style="font-size: 0.9rem;">Active</span>
                </label>
            </div>
        `;
            }

            const subjectHtml = `
<div class="row mb-2 align-items-center" id="${subjectId}">
    <div class="col-lg-5 col-md-4 col-sm-12">
        <input type="text" class="form-control subject-name" value="${escapeHtml(subjectName)}" readonly />
    </div>
    ${checkboxHtml}
    <div class="col-lg-1 col-md-2 col-sm-12">
        <i class="fa fa-trash text-danger" style="cursor: pointer; font-size: 2.3rem;" title="Remove"></i>
    </div>
</div>`;

            $('#noSubjectsMessage').hide();
            $('#subjectRowsContainer').append(subjectHtml);

            $(`#${subjectId} .fa-trash`).on('click', function () {
                $(this).closest('.row').remove();
                if ($('.fa-trash').length === 0) {
                    $('#noSubjectsMessage').show();
                }
            });
        }

        function redirect() {
            window.location.href = "SubjectList.aspx";
        }

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    <div class="row">
        <div class="col-lg-3 col-md-6 col-sm-12">
            <div class="custom-card">
                <div class="custom-card-header">
                    <h4>Academic Configuration</h4>
                </div>
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

        <div class="col-lg-4 col-md-6 col-sm-12">
            <div class="custom-card">
                <div class="custom-card-header">
                    <h4>Subject Management</h4>
                </div>
                <div class="custom-card-body">
                    <div class="row mb-3">
                        <div class="col-lg-6 col-md-6 col-sm-12 ">
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
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <input type="button" id="btnView" class="btn btn-primry" onclick="redirect()" value="View" />
                </div>
                <div class="col-lg-2 col-md-6 col-sm-12">
                    <input type="button" class="btn-gray" value="New" id="btnBack" onclick="window.location = 'Subj_Definition.aspx'" />
                </div>
            </div>
        </div>
    </div>
    <input type="hidden" id="hfMasterId" />
    <input type="hidden" id="hfCurrentPath" />
</asp:Content>
