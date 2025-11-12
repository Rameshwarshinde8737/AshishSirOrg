import { api, LightningElement, track } from 'lwc';
import getAssociatedFiles from '@salesforce/apex/KanbanController.getAssociatedFiles';
import deleteAssociatedFile from '@salesforce/apex/KanbanController.deleteAssociatedFile';
import saveFile from '@salesforce/apex/FileUploadController.saveFile';
import uploadFileAura from '@salesforce/apex/FilesConnect.uploadFileAura';
import kanbanStateChange from '@salesforce/apex/realTimeController.kanbanStateChange';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import labels from 'c/leankorLabels';

export default class MyWorkFileUpload extends LightningElement {
    @api recordId;
    @api sessionId;
    @api child;
    @track fileRecords = [];
    @track selectedFile;
    @track isUploading = false;
    @track isLoading = false;
    @track selectedFileName = '';
    @track filteredRecords = [];
    @track filterText = '';

    get labels() {
        return labels;
    }

    // Select file from input
    handleFileSelected(event) {
        const file = event.target.files[0];
        if (file) {
            this.selectedFile = file;
            this.selectedFileName = file.name;
        } else {
            this.selectedFile = null;
            this.selectedFileName = '';
        }
    }

    openFileDialog() {
        const fileInput = this.template.querySelector('.hidden-file-input');
        if (fileInput) {
            fileInput.click(); // simulate Browse file click
        }
    }

    // Upload on button click
    async handleUploadClick() {
        if (!this.selectedFile) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.NoFileSelected,
                    message: labels.PleaseSelectFile,
                    variant: 'warning'
                })
            );
            return;
        }

        const file = this.selectedFile;
        const MAX_SIZE = 3 * 1024 * 1024; // 3MB
        if (file.size > MAX_SIZE) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.FileTooLarge,
                    message: labels.LimitIs3MB,
                    variant: 'error'
                })
            );
            return;
        }

        this.isUploading = true;
        this.isLoading = true;
        const reader = new FileReader();
        reader.onloadend = async (e) => {
            const base64String = e.target.result.split(',')[1];
            try {
                const contentVersionId = await saveFile({
                    fileName: file.name,
                    base64Data: base64String,
                    contentType: file.type
                });

                const result = await uploadFileAura({
                    uploadRequest: { parentId: this.recordId, contentVersionId }
                });

                const payload = JSON.stringify({
                    Id: this.child.Id,
                    GUID: this.child.GUID,
                    ChatterComments: this.child.ChatterCount + 1,
                    chattersCount: this.child.ChatterCount + 1,
                    filesCount: this.child.filesCount + 1,
                    riskCount: 0,
                    ValueStream: this.child.ValueStream,
                });

                await kanbanStateChange({
                    valueStreamId: this.child.ValueStream,
                    verb: 'NewChatterComments',
                    sessionId: this.sessionId,
                    jsonData: payload
                });

                const now = new Date();
                const readableDate = now.toLocaleString('en-US', {
                    year: 'numeric', month: 'short', day: '2-digit',
                    hour: 'numeric', minute: '2-digit', hour12: true
                });

                this.filteredRecords = [
                    ...this.filteredRecords,
                    { Title: result.Title, LastModifiedDate: readableDate, ...result }
                ];

                this.dispatchEvent(new CustomEvent('refreshrecordcount', {
                    detail: { childId: this.child.Id, action: 'add' }
                }));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: labels.Success,
                        message: labels.FileUploadedSuccessfully,
                        variant: 'success'
                    })
                );

                this.selectedFile = null;
                this.template.querySelector('input[type=file]').value = '';
            } catch (err) {
                console.error(err);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: labels.UploadFailed,
                        message: err.body?.message || labels.SomethingWentWrong,
                        variant: 'error'
                    })
                );
            } finally {
                this.isUploading = false;
                this.isLoading = false;
                this.selectedFileName = '';
            }
        };

        reader.readAsDataURL(file);
    }


    // Fetch existing files
    async connectedCallback() {
        await this.fetchFiles();
    }

    async fetchFiles() {
        this.isLoading = true;
        try {
            const fileInputData = { filePublishLocation: 'KanbanCard', publishLocationIds: [this.recordId] };
            const data = await getAssociatedFiles({ fileInputData });
            this.fileRecords = data.map(record => {
                const date = new Date(record.LastModifiedDate);
                const readableDate = date.toLocaleString('en-US', {
                    year: 'numeric', month: 'short', day: '2-digit',
                    hour: 'numeric', minute: '2-digit', hour12: true
                });
                return { ...record, LastModifiedDate: readableDate };
                
            });
            this.filteredRecords = [...this.fileRecords];
        } catch (err) {
            console.error('Error fetching files', err);
        } finally {
            this.isLoading = false;
        }
    }

    // Delete file
    async handleDeleteFile(event) {
        const recordId = event.target.dataset.id;
        const index = this.filteredRecords.findIndex(rec => rec.Id === recordId);
        const file = this.filteredRecords[index];
        if (!file) return;

        try {
            const result = await LightningConfirm.open({
                message: `${labels.AreYouSureDelete} ${file.Title}?`,
                theme: 'warning', // 'success', 'info', 'error', 'warning'
                label: labels.ConfirmDeletion
            });

            if (result) {
                await deleteAssociatedFile({
                    jsonString: JSON.stringify({
                        relatedRecordId: file.RelatedRecordId,
                        parentId: file.ParentId
                    })
                });

                this.filteredRecords.splice(index, 1);
                this.filteredRecords = [...this.filteredRecords];

                this.dispatchEvent(new CustomEvent('refreshrecordcount', {
                    detail: { childId: this.child.Id, action: 'remove' }
                }));

                this.dispatchEvent(
                    new ShowToastEvent({
                        title: labels.Success,
                        message: labels.FileDeletedSuccessfully,
                        variant: 'success'
                    })
                );
            }
        } catch (err) {
            console.error(err);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: labels.Error,
                    message: labels.DeleteFailed,
                    variant: 'error'
                })
            );
        }
    }


    // Open file
    handleOpenFile(event) {
        const recordId = event.target.dataset.id;
        const file = this.filteredRecords.find(rec => rec.Id === recordId);
        window.open(`/lightning/r/ContentDocument/${file.ContentDocumentId}/view`, '_blank');
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleFilterChange(event) {
        this.filterText = event.target.value.toLowerCase();
        if (this.filterText) {
            this.filteredRecords = this.fileRecords.filter(rec =>
                rec.Title && rec.Title.toLowerCase().startsWith(this.filterText)
            );
        } else {
            this.filteredRecords = [...this.fileRecords];
        }
    }
}