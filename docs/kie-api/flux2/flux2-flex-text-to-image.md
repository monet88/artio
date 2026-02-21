> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Flux-2 - Text to Image

> High-quality photorealistic image generation powered by Flux-2's advanced AI model

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

````yaml market/flux2/flex-text-to-image.json post /api/v1/jobs/createTask
openapi: 3.0.0
info:
  title: Flux-2 API
  description: kie.ai Flux-2 API Documentation - Text to Image
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
      summary: Generate image using flux-2/flex-text-to-image
      operationId: flux-2-flex-text-to-image
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
                    - flux-2/flex-text-to-image
                  default: flux-2/flex-text-to-image
                  description: >-
                    Model name for the generation task. Required field.


                    - This endpoint must use the `flux-2/flex-text-to-image`
                    model
                  example: flux-2/flex-text-to-image
                callBackUrl:
                  type: string
                  format: uri
                  description: >-
                    Callback URL to receive notifications when the generation
                    task is completed. Optional configuration, recommended for
                    production environments.


                    - After the task is generated, the system will POST task
                    status and results to this URL

                    - The callback content includes the generated resource URL
                    and task-related information

                    - Your callback endpoint needs to support receiving POST
                    requests with JSON payloads

                    - Alternatively, you can call the task details endpoint to
                    actively poll task status

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
                        Generation prompt, length must be between 3-5000
                        characters. (Maximum length: 5000 characters)
                      type: string
                      maxLength: 5000
                      example: >-
                        A humanoid figure with a vintage television set for a
                        head, featuring a green-tinted screen displaying a
                        `Hello FLUX.2` writing in ASCII font. The figure is
                        wearing a yellow raincoat, and there are various wires
                        and components attached to the television. The
                        background is cloudy and indistinct, suggesting an
                        outdoor setting
                    aspect_ratio:
                      description: >-
                        Aspect ratio of the generated image. When `auto` is
                        selected, it will match the ratio of the first input
                        image (requires input image to be provided).
                      type: string
                      enum:
                        - '1:1'
                        - '4:3'
                        - '3:4'
                        - '16:9'
                        - '9:16'
                        - '3:2'
                        - '2:3'
                        - auto
                      default: '1:1'
                      example: '1:1'
                    resolution:
                      description: Output image resolution.
                      type: string
                      enum:
                        - 1K
                        - 2K
                      default: 1K
                      example: 1K
                  required:
                    - prompt
                    - aspect_ratio
                    - resolution
            example:
              model: flux-2/flex-text-to-image
              callBackUrl: https://your-domain.com/api/callback
              input:
                prompt: >-
                  A humanoid figure with a vintage television set for a head,
                  featuring a green-tinted screen displaying a `Hello FLUX.2`
                  writing in ASCII font. The figure is wearing a yellow
                  raincoat, and there are various wires and components attached
                  to the television. The background is cloudy and indistinct,
                  suggesting an outdoor setting
                aspect_ratio: '1:1'
                resolution: 1K
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
                              Task ID, can be used to call the task details
                              endpoint to query task status
                            example: task_flux-2_1765175490366
              example:
                code: 200
                msg: success
                data:
                  taskId: task_flux-2_1765175490366
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

            - **402**: Insufficient Credits - Account credits are insufficient
            to perform this operation

            - **404**: Not Found - The requested resource or endpoint does not
            exist

            - **422**: Validation Error - Request parameters failed validation

            - **429**: Rate Limit - Request frequency limit for this resource
            has been exceeded

            - **455**: Service Unavailable - System is under maintenance

            - **500**: Server Error - An unexpected error occurred while
            processing the request

            - **501**: Generation Failed - Content generation task execution
            failed

            - **505**: Feature Disabled - The requested feature is currently
            unavailable
        msg:
          type: string
          description: Response message, error description when request fails
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

        1. Visit the [API Key Management Page](https://kie.ai/api-key) to get
        your API Key


        Usage:

        Add to request headers:

        Authorization: Bearer YOUR_API_KEY


        Notes:

        - Keep your API Key secure and do not share it with others

        - If you suspect your API Key has been compromised, reset it immediately
        on the management page

````