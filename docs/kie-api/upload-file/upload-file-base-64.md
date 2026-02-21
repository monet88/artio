curl --request POST \
  --url https://kieai.redpandaai.co/api/file-base64-upload \
  --header 'Authorization: Bearer <token>' \
  --header 'Content-Type: application/json' \
  --data '
{
  "base64Data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==",
  "uploadPath": "images/base64",
  "fileName": "test-image.png"
}
'

{
  "success": true,
  "code": 200,
  "msg": "File uploaded successfully",
  "data": {
    "fileName": "uploaded-image.png",
    "filePath": "images/user-uploads/uploaded-image.png",
    "downloadUrl": "https://tempfile.redpandaai.co/xxx/images/user-uploads/uploaded-image.png",
    "fileSize": 154832,
    "mimeType": "image/png",
    "uploadedAt": "2025-01-01T12:00:00.000Z"
  }
}

> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Base64 File Upload

> Upload temporary files via Base64 encoded data. Note: Uploaded files are temporary and automatically deleted after 3 days.

<Info>
  Upload temporary files via Base64 encoded data. Note: Uploaded files are temporary and automatically deleted after 3 days.
</Info>

### Features

* Supports Base64 encoded data and data URL format
* Automatic MIME type recognition and file extension inference
* Support for custom file names or auto-generation (overwrites existing files with same name, may have caching delays)
* Returns complete file information and download links
* API Key authentication protection
* Uploaded files are temporary and automatically deleted after 3 days

### Supported Formats

* **Pure Base64 String**: `iVBORw0KGgoAAAANSUhEUgAA...`
* **Data URL Format**: `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...`

### Usage Recommendations

* Recommended for small files like images
* For large files (>10MB), use the file stream upload API
* Base64 encoding increases data transmission by approximately 33%


## OpenAPI

````yaml file-upload-api/file-upload-api.json post /api/file-base64-upload
openapi: 3.0.0
info:
  title: File Upload API
  description: >-
    File Upload Service API Documentation - Supporting multiple file upload
    methods, uploaded files are temporary and automatically deleted after 3 days
  version: 1.0.0
  contact:
    name: Technical Support
    email: support@kie.ai
servers:
  - url: https://kieai.redpandaai.co
    description: API Server
security:
  - BearerAuth: []
paths:
  /api/file-base64-upload:
    post:
      summary: Base64 File Upload
      operationId: upload-file-base64
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/Base64UploadRequest'
            examples:
              with_data_url:
                summary: Using data URL format
                value:
                  base64Data: >-
                    data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==
                  uploadPath: images/base64
                  fileName: test-image.png
              with_pure_base64:
                summary: Using pure Base64 string
                value:
                  base64Data: >-
                    iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==
                  uploadPath: documents/uploads
      responses:
        '200':
          $ref: '#/components/responses/SuccessResponse'
        '400':
          $ref: '#/components/responses/BadRequestError'
        '401':
          $ref: '#/components/responses/UnauthorizedError'
        '500':
          $ref: '#/components/responses/ServerError'
components:
  schemas:
    Base64UploadRequest:
      type: object
      properties:
        base64Data:
          type: string
          description: >-
            Base64 encoded file data. Supports pure Base64 strings or data URL
            format
          example: data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...
        uploadPath:
          type: string
          description: File upload path, without leading or trailing slashes
          example: images/base64
        fileName:
          type: string
          description: >-
            File name (optional), including file extension. If not provided, a
            random file name will be generated. If the same file name is
            uploaded again, the old file will be overwritten, but changes may
            not take effect immediately due to caching
          example: my-image.png
      required:
        - base64Data
        - uploadPath
    FileUploadResult:
      type: object
      properties:
        fileName:
          type: string
          description: File name
          example: uploaded-image.png
        filePath:
          type: string
          description: Complete file path in storage
          example: images/user-uploads/uploaded-image.png
        downloadUrl:
          type: string
          format: uri
          description: File download URL
          example: >-
            https://tempfile.redpandaai.co/xxx/images/user-uploads/uploaded-image.png
        fileSize:
          type: integer
          description: File size in bytes
          example: 154832
        mimeType:
          type: string
          description: File MIME type
          example: image/png
        uploadedAt:
          type: string
          format: date-time
          description: Upload timestamp
          example: '2025-01-01T12:00:00.000Z'
      required:
        - fileName
        - filePath
        - downloadUrl
        - fileSize
        - mimeType
        - uploadedAt
    ApiResponse:
      type: object
      properties:
        success:
          type: boolean
          description: Whether the request was successful
        code:
          $ref: '#/components/schemas/StatusCode'
        msg:
          type: string
          description: Response message
          example: File uploaded successfully
      required:
        - success
        - code
        - msg
    StatusCode:
      type: integer
      enum:
        - 200
        - 400
        - 401
        - 405
        - 500
      description: >-
        Response Status Code


        | Code | Description |

        |------|-------------|

        | 200 | Success - Request has been processed successfully |

        | 400 | Bad Request - Request parameters are incorrect or missing
        required parameters |

        | 401 | Unauthorized - Authentication credentials are missing or invalid
        |

        | 405 | Method Not Allowed - Request method is not supported |

        | 500 | Server Error - An unexpected error occurred while processing the
        request |
  responses:
    SuccessResponse:
      description: File uploaded successfully
      content:
        application/json:
          schema:
            type: object
            properties:
              success:
                type: boolean
                description: Whether the request was successful
              code:
                type: integer
                enum:
                  - 200
                  - 400
                  - 401
                  - 405
                  - 500
                description: >-
                  Response Status Code


                  | Code | Description |

                  |------|-------------|

                  | 200 | Success - Request has been processed successfully |

                  | 400 | Bad Request - Request parameters are incorrect or
                  missing required parameters |

                  | 401 | Unauthorized - Authentication credentials are missing
                  or invalid |

                  | 405 | Method Not Allowed - Request method is not supported |

                  | 500 | Server Error - An unexpected error occurred while
                  processing the request |
              msg:
                type: string
                description: Response message
                example: File uploaded successfully
              data:
                $ref: '#/components/schemas/FileUploadResult'
            required:
              - success
              - code
              - msg
              - data
          example:
            success: true
            code: 200
            msg: File uploaded successfully
            data:
              fileName: uploaded-image.png
              filePath: images/user-uploads/uploaded-image.png
              downloadUrl: >-
                https://tempfile.redpandaai.co/xxx/images/user-uploads/uploaded-image.png
              fileSize: 154832
              mimeType: image/png
              uploadedAt: '2025-01-01T12:00:00.000Z'
    BadRequestError:
      description: Request parameter error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ApiResponse'
          examples:
            missing_parameter:
              summary: Missing required parameter
              value:
                success: false
                code: 400
                msg: 'Missing required parameter: uploadPath'
            invalid_format:
              summary: Format error
              value:
                success: false
                code: 400
                msg: 'Base64 decoding failed: Invalid Base64 format'
    UnauthorizedError:
      description: Unauthorized access
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ApiResponse'
          example:
            success: false
            code: 401
            msg: 'Authentication failed: Invalid API Key'
    ServerError:
      description: Internal server error
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ApiResponse'
          example:
            success: false
            code: 500
            msg: Internal server error
  securitySchemes:
    BearerAuth:
      type: http
      scheme: bearer
      bearerFormat: API Key
      description: >-
        All APIs require authentication via Bearer Token.


        Get API Key:

        1. Visit [API Key Management Page](https://kie.ai/api-key) to get your
        API Key


        Usage:

        Add to request header:

        Authorization: Bearer YOUR_API_KEY

````