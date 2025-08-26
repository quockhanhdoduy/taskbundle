const cloudinary = require('../config/cloudinary');
const multer = require('multer');
const { CloudinaryStorage } = require('multer-storage-cloudinary');

class FileUploadService {
    constructor() {
        // Configure Cloudinary storage for multer
        this.storage = new CloudinaryStorage({
            cloudinary: cloudinary,
            params: {
                folder: 'taskbundle/attachments',
                resource_type: 'auto', // Support all file types
                public_id: (req, file) => {
                    // Generate unique public_id
                    const timestamp = Date.now();
                    const randomStr = Math.random().toString(36).substring(2, 15);
                    return `${timestamp}_${randomStr}`;
                },
                // File size limit: 10MB
                transformation: [{ quality: 'auto' }]
            },
        });

        // Configure multer
        this.upload = multer({
            storage: this.storage,
            limits: {
                fileSize: 10 * 1024 * 1024, // 10MB
            },
            fileFilter: (req, file, cb) => {
                // Allow all file types
                // Can add filter if needed
                cb(null, true);
            },
        });
    }

    /**
     * Middleware upload single file
     */
    uploadSingleFile() {
        return this.upload.single('file');
    }

    /**
     * Middleware upload multiple files
     */
    uploadMultipleFiles(maxCount = 5) {
        return this.upload.array('files', maxCount);
    }

    /**
     * Delete file from Cloudinary
     * @param {string} publicId - Public ID of file on Cloudinary
     * @returns {Promise<Object>} Result of deletion
     */
    async deleteFileFromCloudinary(publicId) {
        try {
            const result = await cloudinary.uploader.destroy(publicId);
            return result;
        } catch (error) {
            throw new Error(`Error deleting file from Cloudinary: ${error.message}`);
        }
    }

    /**
     * Get file information from Cloudinary
     * @param {string} publicId - Public ID of file
     * @returns {Promise<Object>} File information
     */
    async getFileInfo(publicId) {
        try {
            const result = await cloudinary.api.resource(publicId);
            return result;
        } catch (error) {
            throw new Error(`Error getting file info: ${error.message}`);
        }
    }

    /**
     * Transform upload result to match card attachment schema
     * @param {Object} file - File object from multer
     * @returns {Object} Attachment data
     */
    transformUploadResult(file) {
        if (!file) {
            throw new Error('No file uploaded');
        }

        return {
            url: file.path,
        };
    }
}

module.exports = { FileUploadService: new FileUploadService() };