(function () {
    $(function () {
        $(".attachmentForm").each(function () {

            var _$attachmentTable = $(this).find('.AttachmentTable');
            var _CreateNewAttachment = $(this).find('.CreateNewAttachment');
            var _CreateNewMultipleAttachment = $(this).find('.CreateNewMultipleAttachment');
            var _DownloadMultipleAttachment = $(this).find('.DownloadMultipleAttachment');
            var _DeleteMultipleAttachment = $(this).find('.DeleteMultipleAttachment');
            var _selectAll = $(this).find('.selectAll');

            var refrenceId = _$attachmentTable.data("refrenceid");
            var attachmentType = _$attachmentTable.data("attachmenttype");
            var IsCreate = _$attachmentTable.data("iscreate");
            var actions = _$attachmentTable.data("actions");
            var colunmPermissions = (actions === undefined || actions === null || actions === "") ? [] : (actions.split) ? actions.split(",").map(function (ele) { return parseInt(ele) }) : [actions];

            var attachActionconsts = {
                add: 1,
                edit: 2,
                delete: 3,
                preview: 4,
                download: 5,
                show: 6
            };
            var _attachmentService = abp.services.app.attachmentInfo;

            var _permissions = {
                preview: colunmPermissions.indexOf(attachActionconsts.preview) != -1,
                edit: colunmPermissions.indexOf(attachActionconsts.edit) != -1,
                download: colunmPermissions.indexOf(attachActionconsts.download) != -1,
                delete: colunmPermissions.indexOf(attachActionconsts.delete) != -1,
                show: colunmPermissions.indexOf(attachActionconsts.show) != -1,
            };

            var _createOrEditAttachment = new app.ModalManager({
                viewUrl: abp.appPath + 'App/Attachment/CreateOrEditModal',
                scriptUrl: abp.appPath + 'view-resources/Areas/App/Views/Attachment/_CreateOrEditModal.js',
                modalClass: 'CreateOrEditAttachmentModal'
            });

            var _createOrEditMultipleAttachment = new app.ModalManager({
                viewUrl: abp.appPath + 'App/Attachment/CreateOrEditMultipleModal',
                scriptUrl: abp.appPath + 'view-resources/Areas/App/Views/Attachment/_CreateOrEditMultipleModal.js',
                modalClass: 'CreateOrEditMultipleAttachmentModal'
            });

            var dataTable = _$attachmentTable.DataTable({
                paging: true,
                serverSide: true,
                processing: true,
                listAction: {
                    ajaxFunction: _attachmentService.getAttachmentByReferenceAndType,
                    inputFilter: function () {
                        return {
                            referenceId: refrenceId,
                            attachmentType: attachmentType,
                            isDeleted: IsCreate
                        };
                    }
                },
                columnDefs: [
                    {
                        targets: 0,
                        data: null,
                        orderable: false,
                        render: function (row) {

                            if (!attachmentViewOnly) {
                                return '<input type="checkbox" class="form-check-input checkItem " data-id="' + row.binaryObjectId + '" data-type="' + row.extension + '" data-name="' + row.attachmentName + '" data-attachmentId="' + row.id + '"' + 'data-refrenceId="' + row.refrenceId + '"data-attachmentType="' + row.attachmentType + '">';
                            } else {
                                return '<p></p>';
                            }
                        },
                        orderable: false

                    },
                    {
                        className: 'noWrapping',
                        targets: 1,
                        data: "attachmentName",
                        render: function (data, row) {
                            return "<div>" + getAttachmentImagePreview(data.split('.').pop()) + '<span class="d-inline-block ms-1" data-toggle="tooltip" title="' + data + '">' + data + '</span>'
                        },
                        orderable: false

                    },
                    {
                        className: 'noWrapping',
                        targets: 2,
                        data: "title",
                        render: function (title) {
                            return '<span data-toggle="tooltip" title="' + title + '">' + title + '</span>';
                        },
                        orderable: false

                    },
                    //{
                    //    targets: 3,
                    //    //orderable: false,
                    //    data: "creationTime"
                    //},
                    //{
                    //    targets: 4,
                    //    data: "size",
                    //    render: function (data) {
                    //        return parseFloat(data / 1000) + "  " + app.localize("KiloByte");
                    //    }
                    //},
                    {
                        className: 'text-center d-none',
                        targets: 3,
                        data: null,
                        orderable: false,
                        render: function (row) {
                            return '<input type="checkbox" class="form-check-input SetDefault" ' + (row.isDefault ? "checked" : "") + ' data-id="' + row.binaryObjectId + '" data-type="' + row.extension + '" data-name="' + row.attachmentName + '" data-attachmentId="' + row.id + '"' + 'data-refrenceId="' + row.refrenceId + '"data-attachmentType="' + row.attachmentType + '">';
                        }
                    },
                    {
                        targets: 4,
                        data: null,
                        orderable: false,
                        render: function (row) {
                            var drawactions = "";
                            try {


                            
                          
                            if (_permissions.download)
                                drawactions += "<a href='/File/DownloadBinaryFile?id=" + row.binaryObjectId + "&contentType=" + row.extension + "&fileName=" + encodeURIComponent( row.attachmentName) + "' class='btn btn-link p-0 text-primary'><i class='fa fa-download' title='" + app.localize('Download') + "'></i></a>";

                            if (!attachmentViewOnly) {

                                if ((_permissions.edit || row.isCreator) && !_permissions.show)
                                    drawactions += "&nbsp;&nbsp;<button class='btn btn-link p-0 text-primary editFile'><i class='fa fa-edit' title='" + app.localize('Edit') + "'></i></button>";
                                if ((_permissions.delete || row.isCreator) && !_permissions.show) {
                                    drawactions += "&nbsp;&nbsp;<button class='btn btn-link p-0 text-danger deleteAttachment'><i class='fa fa-trash'  title='" + app.localize('Delete') + "'></i></button>";
                                }
                            }

                            } catch (e) {

                            }
                            return drawactions;
                        }
                    }
                ]
            });

            _$attachmentTable.on('draw.dt', function () {
                $(_selectAll).prop('checked', false);
                $(_DownloadMultipleAttachment).attr("disabled", "disabled");
                $(_DeleteMultipleAttachment).attr("disabled", "disabled");
                $('[data-toggle="tooltip"]').tooltip();
                var countElement = $("#AttachmentCount");

                // Check if the DataTable is empty
                if (_$attachmentTable.find("tbody .dataTables_empty").length > 0) {
                    countElement.text("0");
                } else {
                    var rowCount = _$attachmentTable.find("tbody tr").length;
                    countElement.text(rowCount);
                }

            });

            abp.event.on('app.createOrEditAttachmentModelSaved', function () {
                getAttachments();
            });

            abp.event.on('app.createOrEditMultipleAttachmentModelSaved', function () {
                getAttachments();
            });



            $(_CreateNewAttachment).click(function () {
              
                _createOrEditAttachment.open({ id: "", ReferenceId: refrenceId, attachType: attachmentType, isCreate: IsCreate });
            });

            $(_CreateNewMultipleAttachment).click(function () {
                _createOrEditMultipleAttachment.open({ id: "", ReferenceId: refrenceId, attachType: attachmentType, isCreate: IsCreate });
                
            });

            //$("#selectAll").click(function () {
            //    var status = $("#selectAll").prop("checked");
            //    var elements = $('input[type="checkbox"].checkItem');
            //    elements.each(function (i, element) {
            //        $(element).prop('checked', status);
            //    });
            //    if (status && elements.length > 1) {
            //        $("#DownloadMultipleAttachment").removeAttr("disabled");
            //        $("#DeleteMultipleAttachment").removeAttr("disabled");
            //    } else {
            //        $("#DownloadMultipleAttachment").attr("disabled", "disabled");
            //        $("#DeleteMultipleAttachment").attr("disabled", "disabled");
            //    }
            //});
            $('body').on('change', '.SetDefault', function () {
                var model = {
                    attachmentId: $(this).closest('tr').find('.SetDefault').attr('data-attachmentId'),
                    refrenceId: $(this).closest('tr').find('.SetDefault').attr('data-refrenceId'),
                    attachmentType: $(this).closest('tr').find('.SetDefault').attr('data-attachmentType'),
                    isDefault: $(this).is(":checked"),
                    isDeleted: _$attachmentTable.data("iscreate")
                };

                $.ajax({
                    url: abp.appPath + 'App/Attachment/SetAttachmentAsDefault',
                    type: "post",
                    beforeSend: function () {
                        abp.ui.setBusy();
                    },
                    data: { input: model },
                    success: function () {
                        abp.ui.clearBusy();
                        abp.event.trigger('app.createOrEditAttachmentModelSaved');
                    },

                });
            });

            //$(document).on('click', 'input[type="checkbox"].checkItem', function () {
            //    var length = $('input[type="checkbox"].checkItem:checked').length;
            //    if (length > 1) {
            //        $("#DownloadMultipleAttachment").removeAttr("disabled");
            //        $("#DeleteMultipleAttachment").removeAttr("disabled");
            //    }
            //    else {
            //        $("#DownloadMultipleAttachment").attr("disabled", "disabled");
            //        $("#DeleteMultipleAttachment").attr("disabled", "disabled");
            //    }
            //});

            $(_selectAll).change(function () {
                if (this.checked) {
                    $(".checkItem").each(function () {
                        this.checked = true;
                    });
                    $(_DownloadMultipleAttachment).removeAttr("disabled");
                    $(_DeleteMultipleAttachment).removeAttr("disabled");
                } else {
                    $(".checkItem").each(function () {
                        this.checked = false;
                    });
                    $(_DownloadMultipleAttachment).attr("disabled", "disabled");
                    $(_DeleteMultipleAttachment).attr("disabled", "disabled");
                }
            });

            $(document).on('click', 'input[type="checkbox"].checkItem', function () {
                if ($(this).is(":checked")) {
                    var isAllChecked = 0;

                    $(".checkItem").each(function () {
                        if (!this.checked)
                            isAllChecked = 1;
                    });

                    if (isAllChecked == 0) {
                        $(_selectAll).prop("checked", true);
                        $(_DownloadMultipleAttachment).removeAttr("disabled");
                        $(_DeleteMultipleAttachment).removeAttr("disabled");
                    }
                }
                else {
                    $(_selectAll).prop("checked", false);
                    $(_DownloadMultipleAttachment).attr("disabled", "disabled");
                    $(_DeleteMultipleAttachment).attr("disabled", "disabled");
                }
            });

            $(_DownloadMultipleAttachment).click(function () {
                abp.ui.setBusy();
                var checked = $('input[type="checkbox"].checkItem:checked');

                var obj = new Object();
                obj.ids = new Array();
                obj.names = new Array();

                checked.each(function (i, v) {
                    obj.ids.push($(v).attr('data-id'));
                    obj.names.push($(v).attr('data-name'));
                });
                $.ajax({
                    url: "/File/DownloadBinaryFiles",
                    type: "POST",
                    data: JSON.stringify(obj),
                    datatype: "json",
                    contentType: 'application/json; charset=utf-8'
                }).done(function (data) {
                    if (data.result.isSuccess) {
                        window.location = '/File/DownloadTempFile?fileType=application/zip' + '&fileToken=' + data.result.zipFileId + '&fileName=files.zip';
                    }
                }).always(function () {
                    abp.ui.clearBusy();
                });
            });

            $(_DeleteMultipleAttachment).click(function () {
                debugger
                var checked = $('input[type="checkbox"].checkItem:checked');
                var obj = new Object();
                obj.ids = new Array();
                obj.binaryIds = new Array();

                checked.each(function (i, v) {
                    obj.ids.push($(v).attr('data-attachmentId'));
                    obj.binaryIds.push($(v).attr('data-id'));
                });
                abp.message.confirm(
                    app.localize('AttachmentsDeleteWarningMessage'),
                    app.localize('AreYouSure'),
                    function (isConfirmed) {
                        debugger
                        if (isConfirmed) {
                            debugger
                            abp.ui.setBusy();
                            _attachmentService.deleteAttachments({ ids: obj.ids, binaryIds: obj.binaryIds }).done(function (notDeletedAttachments) {
                                debugger
                                abp.ui.clearBusy();
                                getAttachments();
                                abp.notify.success(app.localize('SuccessfullyDeleted'));
                            });
                        }
                    }
                );
            });


            _$attachmentTable.on("click", ".deleteAttachment", function (event) {
                debugger
                event.preventDefault();
                var tr = $(this).closest('tr');
                var data = dataTable.row(tr).data();
                deleteFile(data.id, data.binaryObjectId, data.title);
            });

            _$attachmentTable.on("click", ".editFile", function (event) {
                $('#Viewattachment').modal('hide');
                $('#ViewattachmentFlight').modal('hide');
                $('#ViewattachmentTransportation').modal('hide');
                $('#ViewattachmentService').modal('hide');
                event.preventDefault();
                var tr = $(this).closest('tr');
                var data = dataTable.row(tr).data();
                _createOrEditAttachment.open({ id: data.id, ReferenceId: refrenceId, attachType: attachmentType, isCreate: IsCreate });
            });

            _$attachmentTable.on("click", ".previewFile", function (event) {
                event.preventDefault();
                var tr = $(this).closest('tr');
                var data = dataTable.row(tr).data();
                alert("Preview");
            });

            function getAttachments() {
                dataTable.ajax.reload();
                $("#selectAll").prop("checked", false);
                $("#DownloadMultipleAttachment").attr("disabled", "disabled");
                checkStatus = true;
            }

            function getAttachmentImagePreview(filetype) {
                var image = "";
                switch (filetype.toLocaleLowerCase()) {
                    case "video":
                        image = "fa-file-video"
                        break;
                    case "jpg":
                    case "png":
                    case "gif":
                    case "jpeg":
                        image = "fa-file-image"
                        break;
                    case "txt":
                        image = "fa-file-alt"
                        break;
                    case "avi":
                    case "flv":
                    case "mp4":
                        image = "fa-file-video"
                        break;
                    case "mp3":
                        image = "fa-file-audio"
                        break;
                    case "html":
                        image = "fa-file-invoice"
                        break;
                    case "ppt":
                    case "pptx":
                        image = "fa-file-powerpoint"
                        break;
                    case "excel":
                    case "xls":
                    case "xlsx":
                        image = "fa-file-excel"
                        break;
                    case "word":
                    case "doc":
                    case "docx":
                        image = "fa-file-word"
                        break;
                    case "pdf":
                        image = "fa-file-pdf"
                        break;
                    default:
                        image = "fa-file"
                        break;
                }
                return "<em class='fa " + image + "' ></em>";
                //var image = "";
                //switch (filetype.toLocaleLowerCase()) {
                //    case "video":
                //        image = "video.png"
                //        break;
                //    case "jpg":
                //    case "png":
                //    case "gif":
                //    case "jpeg":
                //        image = "image.png"
                //        break;
                //    case "txt":
                //        image = "txt.png"
                //        break;
                //    case "avi":
                //    case "flv":
                //    case "mp4":
                //        image = "video.png"
                //        break;
                //    case "mp3":
                //        image = "voice.png"
                //        break;
                //    case "html":
                //        image = "web.png"
                //        break;
                //    case "ppt":
                //    case "pptx":
                //        image = "ppt.png"
                //        break;
                //    case "excel":
                //    case "xls":
                //    case "xlsx":
                //        image = "excel.png"
                //        break;
                //    case "word":
                //    case "doc":
                //    case "docx":
                //        image = "word.png"
                //        break;
                //    case "pdf":
                //    default:
                //        image = "pdf.png"
                //        break;
                //}
                //return "<img src='/common/Images/fileType-imageeditFiles/" + image + "' width='20px' height='20px' />";
            }

            function deleteFile(id, binaryId, attachName) {
                abp.message.confirm(
                    app.localize(attachName),
                    app.localize('AreYouSure'),
                    function (isConfirmed) {
                        debugger
                        if (isConfirmed) {
                            _attachmentService.deleteAttachment({ id: id, binaryId: binaryId }).done(function () {
                                getAttachments();
                                abp.notify.success(app.localize('SuccessfullyDeleted'));
                            });
                        }
                    }
                );
            }
        });
    });
})();
 