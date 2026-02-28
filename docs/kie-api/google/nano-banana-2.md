> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Google - Nano Banana 2

> Image generation using Google's Nano Banana 2 model

## Query Task Status

After submitting a task, use the unified task query endpoint to check progress and retrieve results:

<Card title="Get Task Details" icon="magnifying-glass" href="/market/common/get-task-detail">
  Learn how to query task status and retrieve generation results
</Card>

<Tip>
  For production use, we recommend using the callBackUrl parameter to receive automatic notifications when generation completes, rather than polling the status endpoint.
</Tip>

## Related Resources

<CardGroup cols={2}>
  <Card title="Market Overview" icon="store" href="/market/quickstart">
    Explore and compare all available models
  </Card>

  <Card title="Common API" icon="gear" href="/common-api/get-account-credits">
    Check account credits and usage
  </Card>
</CardGroup>


## OpenAPI

````yaml market/google/nano-banana-2.json post /api/v1/jobs/createTask
openapi: 3.0.0
info:
  title: Nano Banana 2 API
  description: kie.ai Nano Banana 2 API Documentation
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
      summary: Generate content using nano-banana-2
      operationId: nano-banana-2
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
                    - nano-banana-2
                  default: nano-banana-2
                  description: |-
                    The model name to use for generation. Required field.

                    - Must be `nano-banana-2` for this endpoint
                  example: nano-banana-2
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

                    - To ensure callback security, see [Webhook Verification
                    Guide](/common-api/webhook-verification) for signature
                    verification implementation
                  example: https://your-domain.com/api/callback
                input:
                  type: object
                  description: Input parameters for the generation task
                  properties:
                    aspect_ratio:
                      description: Aspect ratio of the generated image
                      type: string
                      enum:
                        - auto
                        - '1:1'
                        - '1:4'
                        - '16:9'
                        - '1:8'
                        - '21:9'
                        - '2:3'
                        - '3:2'
                        - '3:4'
                        - '4:1'
                        - '4:3'
                        - '4:5'
                        - '5:4'
                        - '8:1'
                        - '9:16'
                      default: auto
                      example: auto
                    google_search:
                      description: >-
                        Google Search，Use Google Web Search grounding to
                        generate images based on real-time information (e.g.
                        weather, sports scores, recent events).
                      type: boolean
                      example: false
                    image_input:
                      description: >-
                        Input images to transform or use as reference (supports
                        up to 14 images) (File URL after upload, not file
                        content; Accepted types: image/jpeg, image/png,
                        image/webp; Max size: 30.0MB)
                      type: array
                      items:
                        type: string
                        format: uri
                      maxItems: 14
                      example: []
                    output_format:
                      description: Format of the output image
                      type: string
                      enum:
                        - jpg
                        - png
                      default: jpg
                      example: jpg
                    prompt:
                      description: >-
                        A text description of the image you want to generate
                        (Max length: 20000 characters)
                      type: string
                      maxLength: 20000
                      example: >-
                        Highly detailed illustration of a futuristic
                        banana-shaped spacecraft flying over a neon city at
                        night, ultra realistic lighting, cinematic, 4K
                    resolution:
                      description: Resolution of the generated image
                      type: string
                      enum:
                        - 1K
                        - 2K
                        - 4K
                      default: 1K
                      example: 1K
                  required:
                    - prompt
            example:
              model: nano-banana-2
              callBackUrl: https://your-domain.com/api/callback
              input:
                prompt: >-
                  Highly detailed illustration of a futuristic banana-shaped
                  spacecraft flying over a neon city at night, ultra realistic
                  lighting, cinematic, 4K
                aspect_ratio: auto
                resolution: 2K
                output_format: jpg
                google_search: false
                image_input: []
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
                            example: task_nano-banana-2_1765178625768
              example:
                code: 200
                msg: success
                data:
                  taskId: task_nano-banana-2_1765178625768
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