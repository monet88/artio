> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Seedream4.5 - Text to Image

> High-quality photorealistic image generation powered by Seedream's advanced AI model

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

````yaml market/seedream/4.5-text-to-image.json post /api/v1/jobs/createTask
openapi: 3.0.0
info:
  title: Seedream API
  description: kie.ai Seedream API Documentation - Text to Image
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
      summary: Generate images using seedream/4.5-text-to-image
      operationId: seedream-4-5-text-to-image
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
                    - seedream/4.5-text-to-image
                  default: seedream/4.5-text-to-image
                  description: |-
                    The model name to use for generation. Required field.

                    - Must be `seedream/4.5-text-to-image` for this endpoint
                  example: seedream/4.5-text-to-image
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
                    prompt:
                      description: >-
                        A text description of the image you want to generate
                        (Max length: 3000 characters)
                      type: string
                      maxLength: 3000
                      example: >-
                        A full-process cafe design tool for entrepreneurs and
                        designers. It covers core needs including store layout,
                        functional zoning, decoration style, equipment
                        selection, and customer group adaptation, supporting
                        integrated planning of "commercial attributes +
                        aesthetic design." Suitable as a promotional image for a
                        cafe design SaaS product, with a 16:9 aspect ratio.
                    aspect_ratio:
                      description: >-
                        Width-height ratio of the image, determining its visual
                        form.
                      type: string
                      enum:
                        - '1:1'
                        - '4:3'
                        - '3:4'
                        - '16:9'
                        - '9:16'
                        - '2:3'
                        - '3:2'
                        - '21:9'
                      default: '1:1'
                      example: '1:1'
                    quality:
                      description: Basic outputs 2K images, while High outputs 4K images.
                      type: string
                      enum:
                        - basic
                        - high
                      default: basic
                      example: basic
                  required:
                    - prompt
                    - aspect_ratio
                    - quality
            example:
              model: seedream/4.5-text-to-image
              callBackUrl: https://your-domain.com/api/callback
              input:
                prompt: >-
                  A full-process cafe design tool for entrepreneurs and
                  designers. It covers core needs including store layout,
                  functional zoning, decoration style, equipment selection, and
                  customer group adaptation, supporting integrated planning of
                  "commercial attributes + aesthetic design." Suitable as a
                  promotional image for a cafe design SaaS product, with a 16:9
                  aspect ratio.
                aspect_ratio: '1:1'
                quality: basic
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
                            example: task_seedream_1765166238715
              example:
                code: 200
                msg: success
                data:
                  taskId: task_seedream_1765166238716
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