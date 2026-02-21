> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# File Upload API Quickstart

> Get started with the File Upload API in minutes, supporting multiple upload methods

## Welcome to File Upload API

The File Upload API provides flexible and efficient file upload services, supporting multiple upload methods to meet diverse business needs. Whether it's remote file migration, large file transmission, or quick small file uploads, our API offers the best solutions for your requirements.

<CardGroup cols={3}>
  <Card title="Base64 Upload" icon="code" href="/file-upload-api/upload-file-base-64">
    Base64 encoded file upload, suitable for small files
  </Card>

  <Card title="File Stream Upload" icon="upload" href="/file-upload-api/upload-file-stream">
    Efficient binary file stream upload, ideal for large files
  </Card>

  <Card title="URL File Upload" icon="link" href="/file-upload-api/upload-file-url">
    Automatically download and upload files from remote URLs
  </Card>
</CardGroup>

<Info>
  **File uploads are free** - No charges apply for uploading files to our service. You can upload files without worrying about upload costs or fees.
</Info>

<Warning>
  **Important Notice**: Uploaded files are temporary and will be **automatically deleted after 3 days**. Please download or migrate important files promptly.
</Warning>

## Authentication

All API requests require authentication using Bearer tokens. Please obtain your API key from the [API Key Management Page](https://kie.ai/api-key).

<Warning>
  Please keep your API key secure and never share it publicly. If you suspect your key has been compromised, reset it immediately.
</Warning>

### API Base URL

```
https://kieai.redpandaai.co
```

### Authentication Header

```http  theme={null}
Authorization: Bearer YOUR_API_KEY
```

## Quick Start Guide

### Step 1: Choose Your Upload Method

Select the appropriate upload method based on your needs:

<Tabs>
  <Tab title="URL File Upload">
    Suitable for downloading and uploading files from remote servers:

    <CodeGroup>
      ```bash cURL theme={null}
      curl -X POST "https://kieai.redpandaai.co/api/file-url-upload" \
        -H "Authorization: Bearer YOUR_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "fileUrl": "https://example.com/sample-image.jpg",
          "uploadPath": "images",
          "fileName": "my-image.jpg"
        }'
      ```

      ```javascript JavaScript theme={null}
      const response = await fetch('https://kieai.redpandaai.co/api/file-url-upload', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          fileUrl: 'https://example.com/sample-image.jpg',
          uploadPath: 'images',
          fileName: 'my-image.jpg'
        })
      });

      const result = await response.json();
      console.log('Upload successful:', result);
      ```

      ```python Python theme={null}
      import requests

      url = "https://kieai.redpandaai.co/api/file-url-upload"
      headers = {
          "Authorization": "Bearer YOUR_API_KEY",
          "Content-Type": "application/json"
      }

      payload = {
          "fileUrl": "https://example.com/sample-image.jpg",
          "uploadPath": "images",
          "fileName": "my-image.jpg"
      }

      response = requests.post(url, json=payload, headers=headers)
      result = response.json()

      print(f"Upload successful: {result}")
      ```
    </CodeGroup>
  </Tab>

  <Tab title="File Stream Upload">
    Suitable for directly uploading local files, especially large files:

    <CodeGroup>
      ```bash cURL theme={null}
      curl -X POST "https://kieai.redpandaai.co/api/file-stream-upload" \
        -H "Authorization: Bearer YOUR_API_KEY" \
        -F "file=@/path/to/your-file.jpg" \
        -F "uploadPath=images/user-uploads" \
        -F "fileName=custom-name.jpg"
      ```

      ```javascript JavaScript theme={null}
      const formData = new FormData();
      formData.append('file', fileInput.files[0]);
      formData.append('uploadPath', 'images/user-uploads');
      formData.append('fileName', 'custom-name.jpg');

      const response = await fetch('https://kieai.redpandaai.co/api/file-stream-upload', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY'
        },
        body: formData
      });

      const result = await response.json();
      console.log('Upload successful:', result);
      ```

      ```python Python theme={null}
      import requests

      url = "https://kieai.redpandaai.co/api/file-stream-upload"
      headers = {
          "Authorization": "Bearer YOUR_API_KEY"
      }

      files = {
          'file': ('your-file.jpg', open('/path/to/your-file.jpg', 'rb')),
          'uploadPath': (None, 'images/user-uploads'),
          'fileName': (None, 'custom-name.jpg')
      }

      response = requests.post(url, headers=headers, files=files)
      result = response.json()

      print(f"Upload successful: {result}")
      ```
    </CodeGroup>
  </Tab>

  <Tab title="Base64 Upload">
    Suitable for Base64 encoded file data:

    <CodeGroup>
      ```bash cURL theme={null}
      curl -X POST "https://kieai.redpandaai.co/api/file-base64-upload" \
        -H "Authorization: Bearer YOUR_API_KEY" \
        -H "Content-Type: application/json" \
        -d '{
          "base64Data": "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...",
          "uploadPath": "images",
          "fileName": "base64-image.png"
        }'
      ```

      ```javascript JavaScript theme={null}
      const response = await fetch('https://kieai.redpandaai.co/api/file-base64-upload', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer YOUR_API_KEY',
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          base64Data: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAA...',
          uploadPath: 'images',
          fileName: 'base64-image.png'
        })
      });

      const result = await response.json();
      console.log('Upload successful:', result);
      ```

      ```python Python theme={null}
      import requests
      import base64

      # Read file and convert to base64
      with open('/path/to/your-file.jpg', 'rb') as f:
          file_data = base64.b64encode(f.read()).decode('utf-8')
          base64_data = f'data:image/jpeg;base64,{file_data}'

      url = "https://kieai.redpandaai.co/api/file-base64-upload"
      headers = {
          "Authorization": "Bearer YOUR_API_KEY",
          "Content-Type": "application/json"
      }

      payload = {
          "base64Data": base64_data,
          "uploadPath": "images",
          "fileName": "base64-image.jpg"
      }

      response = requests.post(url, json=payload, headers=headers)
      result = response.json()

      print(f"Upload successful: {result}")
      ```
    </CodeGroup>
  </Tab>
</Tabs>

### Step 1.1: Understanding fileName Parameter

<Info>
  The `fileName` parameter is optional in all upload methods and behaves as follows:
</Info>

<ParamField body="fileName" type="string" optional>
  **File name behavior:**

  * If not provided, a random file name will be automatically generated
  * If the same file name is uploaded again, the old file will be overwritten
  * Due to caching, changes may not take effect immediately when overwriting files

  **Examples:**

  ```javascript  theme={null}
  // Without fileName - random name generated
  { uploadPath: "images" } // → generates "abc123.jpg"

  // With fileName - uses specified name
  { uploadPath: "images", fileName: "my-photo.jpg" }

  // Overwriting - replaces existing file (with caching delay)
  { uploadPath: "images", fileName: "my-photo.jpg" } // overwrites previous
  ```
</ParamField>

### Step 2: Handle Response

Upon successful upload, you'll receive a response containing file information:

```json  theme={null}
{
  "success": true,
  "code": 200,
  "msg": "File uploaded successfully",
  "data": {
    "fileId": "file_abc123456",
    "fileName": "my-image.jpg",
    "originalName": "sample-image.jpg",
    "fileSize": 245760,
    "mimeType": "image/jpeg",
    "uploadPath": "images",
    "fileUrl": "https://kieai.redpandaai.co/files/images/my-image.jpg",
    "downloadUrl": "https://kieai.redpandaai.co/download/file_abc123456",
    "uploadTime": "2025-01-15T10:30:00Z",
    "expiresAt": "2025-01-18T10:30:00Z"
  }
}
```

## Upload Method Comparison

Choose the most suitable upload method for your needs:

<CardGroup cols={3}>
  <Card title="URL File Upload" icon="link">
    **Best for**: File migration, batch processing

    **Advantages**:

    * No local file required
    * Automatic download handling
    * Supports remote resources

    **Limitations**:

    * Requires publicly accessible URL
    * 30-second download timeout
    * Recommended ≤100MB
  </Card>

  <Card title="File Stream Upload" icon="upload">
    **Best for**: Large files, local files

    **Advantages**:

    * High transmission efficiency
    * Supports large files
    * Binary transmission

    **Limitations**:

    * Requires local file
    * Server processing time
  </Card>

  <Card title="Base64 Upload" icon="code">
    **Best for**: Small files, API integration

    **Advantages**:

    * JSON format transmission
    * Easy integration
    * Supports Data URL

    **Limitations**:

    * Data size increases by 33%
    * Not suitable for large files
    * Recommended ≤10MB
  </Card>
</CardGroup>

## Practical Examples

### Batch File Upload

Using file stream upload to handle multiple files:

<Tabs>
  <Tab title="JavaScript">
    ```javascript  theme={null}
    class FileUploadAPI {
      constructor(apiKey) {
        this.apiKey = apiKey;
        this.baseUrl = 'https://kieai.redpandaai.co';
      }
      
      async uploadFile(file, uploadPath = '', fileName = null) {
        const formData = new FormData();
        formData.append('file', file);
        if (uploadPath) formData.append('uploadPath', uploadPath);
        if (fileName) formData.append('fileName', fileName);
        
        const response = await fetch(`${this.baseUrl}/api/file-stream-upload`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.apiKey}`
          },
          body: formData
        });
        
        if (!response.ok) {
          throw new Error(`Upload failed: ${response.statusText}`);
        }
        
        return response.json();
      }
      
      async uploadFromUrl(fileUrl, uploadPath = '', fileName = null) {
        const response = await fetch(`${this.baseUrl}/api/file-url-upload`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            fileUrl,
            uploadPath,
            fileName
          })
        });
        
        if (!response.ok) {
          throw new Error(`Upload failed: ${response.statusText}`);
        }
        
        return response.json();
      }
      
      async uploadBase64(base64Data, uploadPath = '', fileName = null) {
        const response = await fetch(`${this.baseUrl}/api/file-base64-upload`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${this.apiKey}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            base64Data,
            uploadPath,
            fileName
          })
        });
        
        if (!response.ok) {
          throw new Error(`Upload failed: ${response.statusText}`);
        }
        
        return response.json();
      }
    }

    // Usage example
    const uploader = new FileUploadAPI('YOUR_API_KEY');

    // Batch upload files
    async function uploadMultipleFiles(files) {
      const results = [];
      
      for (let i = 0; i < files.length; i++) {
        try {
          const result = await uploader.uploadFile(
            files[i], 
            'user-uploads', 
            `file-${i + 1}-${files[i].name}`
          );
          results.push(result);
          console.log(`File ${i + 1} uploaded successfully:`, result.data.fileUrl);
        } catch (error) {
          console.error(`File ${i + 1} upload failed:`, error.message);
        }
      }
      
      return results;
    }

    // Batch upload from URLs
    async function uploadFromUrls(urls) {
      const results = [];
      
      for (let i = 0; i < urls.length; i++) {
        try {
          const result = await uploader.uploadFromUrl(
            urls[i], 
            'downloads', 
            `download-${i + 1}.jpg`
          );
          results.push(result);
          console.log(`URL ${i + 1} uploaded successfully:`, result.data.fileUrl);
        } catch (error) {
          console.error(`URL ${i + 1} upload failed:`, error.message);
        }
      }
      
      return results;
    }
    ```
  </Tab>

  <Tab title="Python">
    ```python  theme={null}
    import requests
    import base64
    import os
    from typing import List, Optional

    class FileUploadAPI:
        def __init__(self, api_key: str):
            self.api_key = api_key
            self.base_url = 'https://kieai.redpandaai.co'
            self.headers = {
                'Authorization': f'Bearer {api_key}'
            }
        
        def upload_file(self, file_path: str, upload_path: str = '', 
                       file_name: Optional[str] = None) -> dict:
            """File stream upload"""
            files = {
                'file': (os.path.basename(file_path), open(file_path, 'rb'))
            }
            
            data = {}
            if upload_path:
                data['uploadPath'] = upload_path
            if file_name:
                data['fileName'] = file_name
            
            response = requests.post(
                f'{self.base_url}/api/file-stream-upload',
                headers=self.headers,
                files=files,
                data=data
            )
            
            if not response.ok:
                raise Exception(f'Upload failed: {response.text}')
            
            return response.json()
        
        def upload_from_url(self, file_url: str, upload_path: str = '', 
                           file_name: Optional[str] = None) -> dict:
            """URL file upload"""
            payload = {
                'fileUrl': file_url,
                'uploadPath': upload_path,
                'fileName': file_name
            }
            
            response = requests.post(
                f'{self.base_url}/api/file-url-upload',
                headers={**self.headers, 'Content-Type': 'application/json'},
                json=payload
            )
            
            if not response.ok:
                raise Exception(f'Upload failed: {response.text}')
            
            return response.json()
        
        def upload_base64(self, base64_data: str, upload_path: str = '', 
                         file_name: Optional[str] = None) -> dict:
            """Base64 file upload"""
            payload = {
                'base64Data': base64_data,
                'uploadPath': upload_path,
                'fileName': file_name
            }
            
            response = requests.post(
                f'{self.base_url}/api/file-base64-upload',
                headers={**self.headers, 'Content-Type': 'application/json'},
                json=payload
            )
            
            if not response.ok:
                raise Exception(f'Upload failed: {response.text}')
            
            return response.json()

    # Usage example
    def main():
        uploader = FileUploadAPI('YOUR_API_KEY')
        
        # Batch upload local files
        file_paths = [
            '/path/to/file1.jpg',
            '/path/to/file2.png',
            '/path/to/document.pdf'
        ]
        
        print("Starting batch file upload...")
        for i, file_path in enumerate(file_paths):
            try:
                result = uploader.upload_file(
                    file_path, 
                    'user-uploads', 
                    f'file-{i + 1}-{os.path.basename(file_path)}'
                )
                print(f"File {i + 1} uploaded successfully: {result['data']['fileUrl']}")
            except Exception as e:
                print(f"File {i + 1} upload failed: {e}")
        
        # Batch upload from URLs
        urls = [
            'https://example.com/image1.jpg',
            'https://example.com/image2.png'
        ]
        
        print("\nStarting batch URL upload...")
        for i, url in enumerate(urls):
            try:
                result = uploader.upload_from_url(
                    url, 
                    'downloads', 
                    f'download-{i + 1}.jpg'
                )
                print(f"URL {i + 1} uploaded successfully: {result['data']['fileUrl']}")
            except Exception as e:
                print(f"URL {i + 1} upload failed: {e}")

    if __name__ == '__main__':
        main()
    ```
  </Tab>
</Tabs>

## Error Handling

Common errors and handling methods:

<AccordionGroup>
  <Accordion title="401 Unauthorized">
    ```javascript  theme={null}
    // Check if API key is correct
    if (response.status === 401) {
      console.error('Invalid API key, please check Authorization header');
      // Retrieve or update API key
    }
    ```
  </Accordion>

  <Accordion title="400 Bad Request">
    ```javascript  theme={null}
    // Check request parameters
    if (response.status === 400) {
      const error = await response.json();
      console.error('Request parameter error:', error.msg);
      // Check if required parameters are provided
      // Check if file format is supported
      // Check if URL is accessible
    }
    ```
  </Accordion>

  <Accordion title="500 Server Error">
    ```javascript  theme={null}
    // Implement retry mechanism
    async function uploadWithRetry(uploadFunction, maxRetries = 3) {
      for (let i = 0; i < maxRetries; i++) {
        try {
          return await uploadFunction();
        } catch (error) {
          if (i === maxRetries - 1) throw error;
          
          // Exponential backoff
          const delay = Math.pow(2, i) * 1000;
          await new Promise(resolve => setTimeout(resolve, delay));
        }
      }
    }
    ```
  </Accordion>
</AccordionGroup>

## Best Practices

<AccordionGroup>
  <Accordion title="File Size Optimization">
    * **Small files** (≤1MB): Recommended to use Base64 upload
    * **Medium files** (1MB-10MB): Recommended to use file stream upload
    * **Large files** (>10MB): Must use file stream upload
    * **Remote files**: Use URL upload, note 100MB limit
  </Accordion>

  <Accordion title="Performance Optimization">
    * Implement concurrency control to avoid uploading too many files simultaneously
    * Consider chunked upload strategies for large files
    * Use appropriate retry mechanisms to handle network issues
    * Monitor upload progress and provide user feedback
  </Accordion>

  <Accordion title="Security Considerations">
    * Keep API keys secure and rotate them regularly
    * Validate file types and sizes
    * Consider encrypted transmission for sensitive files
    * Download important files promptly to avoid 3-day deletion
  </Accordion>

  <Accordion title="Error Handling">
    * Implement comprehensive error handling logic
    * Log uploads for troubleshooting
    * Provide user-friendly error messages
    * Offer retry options for failed uploads
  </Accordion>
</AccordionGroup>

## File Storage Information

<Warning>
  **Important Notice**: All uploaded files are temporary and will be **automatically deleted after 3 days**.
</Warning>

* Files are immediately accessible and downloadable after upload
* File URLs remain valid for 3 days
* The system provides an `expiresAt` field in the response indicating expiration time
* It's recommended to download or migrate important files before expiration
* Use the `downloadUrl` field to get direct download links

## Status Codes

<ResponseField name="200" type="Success">
  Request processed successfully, file upload completed
</ResponseField>

<ResponseField name="400" type="Bad Request">
  Request parameters are incorrect or missing required parameters
</ResponseField>

<ResponseField name="401" type="Unauthorized">
  Authentication credentials are missing or invalid
</ResponseField>

<ResponseField name="405" type="Method Not Allowed">
  Request method is not supported, please check HTTP method
</ResponseField>

<ResponseField name="500" type="Server Error">
  An unexpected error occurred while processing the request, please retry or contact support
</ResponseField>

## Next Steps

<CardGroup cols={3}>
  <Card title="URL File Upload" icon="link" href="/file-upload-api/upload-file-url">
    Learn how to upload files from remote URLs
  </Card>

  <Card title="File Stream Upload" icon="upload" href="/file-upload-api/upload-file-stream">
    Master efficient file stream upload methods
  </Card>

  <Card title="Base64 Upload" icon="code" href="/file-upload-api/upload-file-base-64">
    Understand Base64 encoded file uploads
  </Card>
</CardGroup>

## Support

<Info>
  Need help? Our technical support team is here to assist you.

  * **Email**: [support@kie.ai](mailto:support@kie.ai)
  * **Documentation**: [docs.kie.ai](https://docs.kie.ai)
  * **API Status**: Check our status page for real-time API health
</Info>

***

Ready to start uploading files? [Get your API key](https://kie.ai/api-key) and begin using the file upload service immediately!
