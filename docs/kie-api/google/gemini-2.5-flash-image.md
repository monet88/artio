> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Google - Nano Banana Edit

> Image editing using Google's Nano Banana Edit model

## Query Task Status

After submitting a task, use the unified query endpoint to check progress and retrieve results:

<Card title="Get Task Details" icon="magnifying-glass" href="/market/common/get-task-detail">
  Learn how to query task status and retrieve generation results
</Card>

<Tip>
  For production use, we recommend using the `callBackUrl` parameter to receive automatic notifications when generation completes, rather than polling the status endpoint.
</Tip>

## Related Resources

<CardGroup cols={2}>
  <Card title="Market Overview" icon="store" href="/market/quickstart">
    Explore all available models
  </Card>

  <Card title="Common API" icon="gear" href="/common-api/get-account-credits">
    Check credits and account usage
  </Card>
</CardGroup>


## OpenAPI

````yaml market/google/nano-banana-edit.json post /api/v1/jobs/createTask
openapi: 3.0.0
info:
  title: Google API
  description: kie.ai Google API Documentation
  version: 1.0.0
  contact:
    name: Technical Support
    email: support@kie.ai
servers:
  - url: https://api.kie.ai
    description: API Server
security:
  - BearerAuth: []
paths:
  /api/v1/jobs/createTask:
    post:
      summary: Generate content using google/nano-banana-edit
      operationId: google-nano-banana-edit
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              required:
                - model
              properties:
                model:
                  type: string
                  enum:
                    - google/nano-banana-edit
                  default: google/nano-banana-edit
                  description: |-
                    The model name to use for generation. Required field.

                    - Must be `google/nano-banana-edit` for this endpoint
                  example: google/nano-banana-edit
                callBackUrl:
                  type: string
                  format: uri
                  description: >-
                    The URL to receive generation task completion updates.
                    Optional but recommended for production use.


                    - System will POST task status and results to this URL when
                    generation completes

                    - Callback includes generated content URLs and task
                    information

                    - Your callback endpoint should accept POST requests with
                    JSON payload containing results

                    - Alternatively, use the Get Task Details endpoint to poll
                    task status
                  example: https://your-domain.com/api/callback
                input:
                  type: object
                  description: Input parameters for the generation task
                  properties:
                    prompt:
                      description: >-
                        The prompt for image editing (Max length: 5000
                        characters)
                      type: string
                      maxLength: 5000
                      example: >-
                        turn this photo into a character figure. Behind it,
                        place a box with the character’s image printed on it,
                        and a computer showing the Blender modeling process on
                        its screen. In front of the box, add a round plastic
                        base with the character figure standing on it. set the
                        scene indoors if possible
                    image_urls:
                      description: >-
                        List of URLs of input images for editing,up to 10
                        images. (File URL after upload, not file content;
                        Accepted types: image/jpeg, image/png, image/webp; Max
                        size: 10.0MB)
                      type: array
                      items:
                        type: string
                        format: uri
                      maxItems: 10
                      example:
                        - >-
                          https://file.aiquickdraw.com/custom-page/akr/section-images/1756223420389w8xa2jfe.png
                    output_format:
                      description: Output format for the images
                      type: string
                      enum:
                        - png
                        - jpeg
                      default: png
                      example: png
                    image_size:
                      description: Radio description
                      type: string
                      enum:
                        - '1:1'
                        - '9:16'
                        - '16:9'
                        - '3:4'
                        - '4:3'
                        - '3:2'
                        - '2:3'
                        - '5:4'
                        - '4:5'
                        - '21:9'
                        - auto
                      default: '1:1'
                      example: '1:1'
                  required:
                    - prompt
                    - image_urls
            example:
              model: google/nano-banana-edit
              callBackUrl: https://your-domain.com/api/callback
              input:
                prompt: >-
                  turn this photo into a character figure. Behind it, place a
                  box with the character’s image printed on it, and a computer
                  showing the Blender modeling process on its screen. In front
                  of the box, add a round plastic base with the character figure
                  standing on it. set the scene indoors if possible
                image_urls:
                  - >-
                    https://file.aiquickdraw.com/custom-page/akr/section-images/1756223420389w8xa2jfe.png
                output_format: png
                image_size: '1:1'
      responses:
        '200':
          description: Request successful
          content:
            application/json:
              schema:
                allOf:
                  - $ref: '#/components/schemas/ApiResponse'
                  - type: object
                    properties:
                      data:
                        type: object
                        properties:
                          taskId:
                            type: string
                            description: >-
                              Task ID, can be used with Get Task Details
                              endpoint to query task status
                            example: task_google_1765178615729
              example:
                code: 200
                msg: success
                data:
                  taskId: task_google_1765178615729
        '500':
          $ref: '#/components/responses/Error'
components:
  schemas:
    ApiResponse:
      type: object
      properties:
        code:
          type: integer
          enum:
            - 200
            - 401
            - 402
            - 404
            - 422
            - 429
            - 455
            - 500
            - 501
            - 505
          description: >-
            Response status code


            - **200**: Success - Request has been processed successfully

            - **401**: Unauthorized - Authentication credentials are missing or
            invalid

            - **402**: Insufficient Credits - Account does not have enough
            credits to perform the operation

            - **404**: Not Found - The requested resource or endpoint does not
            exist

            - **422**: Validation Error - The request parameters failed
            validation checks

            - **429**: Rate Limited - Request limit has been exceeded for this
            resource

            - **455**: Service Unavailable - System is currently undergoing
            maintenance

            - **500**: Server Error - An unexpected error occurred while
            processing the request

            - **501**: Generation Failed - Content generation task failed

            - **505**: Feature Disabled - The requested feature is currently
            disabled
        msg:
          type: string
          description: Response message, error description when failed
          example: success
  responses:
    Error:
      description: Server Error
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


        Note:

        - Keep your API Key secure and do not share it with others

        - If you suspect your API Key has been compromised, reset it immediately
        in the management page

````