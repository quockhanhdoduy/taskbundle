const { ResponseHandler, StatusCodes } = require('../utils');
const { FileUploadService } = require('../services/file-upload.service');

class UploadMiddleware {
    static uploadSingleFile(req, res, next) {
        const upload = FileUploadService.uploadSingleFile();

        upload(req, res, (error) => {
            if (error) {
                console.error('Upload error:', error);

                // Handle different types of errors
                if (error.code === 'LIMIT_FILE_SIZE') {
                    return ResponseHandler.error(
                        res,
                        StatusCodes.BAD_REQUEST,
'File too large! Maximum size is 10MB.'
                    );
                }

                if (error.code === 'LIMIT_UNEXPECTED_FILE') {
                    return ResponseHandler.error(
                        res,
                        StatusCodes.BAD_REQUEST,
'Wrong file field name! Use "file".'
                    );
                }

                return ResponseHandler.error(
                    res,
                    StatusCodes.INTERNAL_SERVER_ERROR,
                    `Lỗi upload file: ${error.message}`
                );
            }

            // Check if file is uploaded
            if (!req.file) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.BAD_REQUEST,
'No file uploaded!'
                );
            }

            try {
                // Transform upload result to match schema
                req.uploadResult = FileUploadService.transformUploadResult(req.file);
                console.log('File uploaded successfully:', req.uploadResult.originalName);
                next();
            } catch (transformError) {
                return ResponseHandler.error(
                    res,
                    StatusCodes.INTERNAL_SERVER_ERROR,
                    `Lỗi xử lý file upload: ${transformError.message}`
                );
            }
        });
    }

    static uploadMultipleFiles(maxCount = 5) {
        return (req, res, next) => {
            const upload = FileUploadService.uploadMultipleFiles(maxCount);

            upload(req, res, (error) => {
                if (error) {
                    console.error('Upload error:', error);

                    if (error.code === 'LIMIT_FILE_SIZE') {
                        return ResponseHandler.error(
                            res,
                            StatusCodes.BAD_REQUEST,
                            'One or more files are too large! Maximum size is 10MB per file.'
                        );
                    }

                    if (error.code === 'LIMIT_FILE_COUNT') {
                        return ResponseHandler.error(
                            res,
                            StatusCodes.BAD_REQUEST,
                            `Too many files! Maximum is ${maxCount} files.`
                        );
                    }

                    return ResponseHandler.error(
                        res,
                        StatusCodes.INTERNAL_SERVER_ERROR,
                        `Error uploading files: ${error.message}`
                    );
                }

                if (!req.files || req.files.length === 0) {
                    return ResponseHandler.error(
                        res,
                        StatusCodes.BAD_REQUEST,
    'No file uploaded!'
                    );
                }

                try {
                    // Transform upload result for multiple files
                    req.uploadResults = req.files.map(file =>
                        FileUploadService.transformUploadResult(file)
                    );
                    console.log(`${req.files.length} files uploaded successfully`);
                    next();
                } catch (transformError) {
                    return ResponseHandler.error(
                        res,
                        StatusCodes.INTERNAL_SERVER_ERROR,
                        `Error processing files upload: ${transformError.message}`
                    );
                }
            });
        };
    }
}

module.exports = { UploadMiddleware };
