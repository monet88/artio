> ## Documentation Index
> Fetch the complete documentation index at: https://docs.kie.ai/llms.txt
> Use this file to discover all available pages before exploring further.

# Google - imagen4-fast

> Image generation by Google imagen4-fast

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

````yaml market/google/imagen4-fast.json post /api/v1/jobs/createTask
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
      summary: Generate content using google/imagen4-fast
      operationId: google-imagen4-fast
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
                    - google/imagen4-fast
                  default: google/imagen4-fast
                  description: |-
                    The model name to use for generation. Required field.

                    - Must be `google/imagen4-fast` for this endpoint
                  example: google/imagen4-fast
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
                        The text prompt describing what you want to see (Max
                        length: 5000 characters)
                      type: string
                      maxLength: 5000
                      example: >-
                        Create a cinematic, photorealistic medium shot capturing
                        the nostalgic warmth of a late 90s indie film. The focus
                        is a young woman with brightly dyed pink hair (slightly
                        faded) and freckled skin, looking directly and intently
                        into the camera lens with a hopeful yet slightly
                        uncertain smile. She wears an oversized, vintage band
                        t-shirt (slightly worn, with the faintly cracked white
                        text “KIE AI” across the chest) layered over a
                        long-sleeved striped top, along with simple silver stud
                        earrings. The lighting is soft, golden hour sunlight
                        streaming through a slightly dusty window, creating lens
                        flare and illuminating dust motes in the air. The
                        background shows a blurred, cluttered bedroom with
                        posters on the wall and fairy lights, rendered with a
                        shallow depth of field. Natural film grain, a warm,
                        slightly muted color palette, and sharp focus on her
                        expressive eyes enhance the intimate, authentic feel.
                    negative_prompt:
                      description: >-
                        A description of what to discourage in the generated
                        images (Max length: 5000 characters)
                      type: string
                      maxLength: 5000
                      example: ''
                    aspect_ratio:
                      description: The aspect ratio of the generated image
                      type: string
                      enum:
                        - '1:1'
                        - '16:9'
                        - '9:16'
                        - '3:4'
                        - '4:3'
                      default: '16:9'
                      example: '16:9'
                    num_images:
                      description: Select description
                      type: string
                      enum:
                        - '1'
                        - '2'
                        - '3'
                        - '4'
                      default: '1'
                      example: '1'
                    seed:
                      description: Random seed for reproducible generation
                      type: integer
                  required:
                    - prompt
            example:
              model: google/imagen4-fast
              callBackUrl: https://your-domain.com/api/callback
              input:
                prompt: >-
                  Create a cinematic, photorealistic medium shot capturing the
                  nostalgic warmth of a late 90s indie film. The focus is a
                  young woman with brightly dyed pink hair (slightly faded) and
                  freckled skin, looking directly and intently into the camera
                  lens with a hopeful yet slightly uncertain smile. She wears an
                  oversized, vintage band t-shirt (slightly worn, with the
                  faintly cracked white text “KIE AI” across the chest) layered
                  over a long-sleeved striped top, along with simple silver stud
                  earrings. The lighting is soft, golden hour sunlight streaming
                  through a slightly dusty window, creating lens flare and
                  illuminating dust motes in the air. The background shows a
                  blurred, cluttered bedroom with posters on the wall and fairy
                  lights, rendered with a shallow depth of field. Natural film
                  grain, a warm, slightly muted color palette, and sharp focus
                  on her expressive eyes enhance the intimate, authentic feel.
                negative_prompt: ''
                aspect_ratio: '16:9'
                num_images: '1'
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
                            example: task_google_1765172332800
              example:
                code: 200
                msg: success
                data:
                  taskId: task_google_1765172332800
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