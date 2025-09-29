# frozen_string_literal: true

require "hanami_helper"

RSpec.describe "/api/models", :db do
  include_context "with JWT"

  let(:model) { Factory[:model] }

  let :attributes do
    {
      name: "test",
      label: "Test",
      description: "A test.",
      kind: "terminus",
      mime_type: "image/bmp",
      colors: 4,
      bit_depth: 2,
      rotation: 90,
      offset_x: 10,
      offset_y: 15,
      width: 800,
      height: 480,
      published_at: Time.utc(2025, 1, 1, 1, 1, 1)
    }
  end

  it "answers models" do
    model

    get routes.path(:api_models),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: [
        {
          id: model.id,
          label: model.label,
          name: model.name,
          description: nil,
          kind: "terminus",
          mime_type: "image/png",
          colors: 2,
          bit_depth: 1,
          rotation: 0,
          offset_x: 0,
          offset_y: 0,
          width: 800,
          height: 480,
          published_at: match_rfc_3339,
          created_at: match_rfc_3339,
          updated_at: match_rfc_3339
        }
      ]
    )
  end

  it "answers empty array when no records exist" do
    get routes.path(:api_models),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(data: [])
  end

  it "answers existing model" do
    get routes.path(:api_model, id: model.id),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: model.id,
        label: model.label,
        name: model.name,
        description: nil,
        kind: "terminus",
        mime_type: "image/png",
        colors: 2,
        bit_depth: 1,
        rotation: 0,
        offset_x: 0,
        offset_y: 0,
        width: 800,
        height: 480,
        published_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers not found error with invalid ID" do
    get routes.path(:api_model, id: 666),
        {},
        "HTTP_AUTHORIZATION" => access_token,
        "CONTENT_TYPE" => "application/json"

    expect(json_payload).to eq(Petail[status: :not_found].to_h)
  end

  it "creates model when valid" do
    post routes.path(:api_models),
         {model: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: kind_of(Integer),
        label: "Test",
        name: "test",
        description: "A test.",
        kind: "terminus",
        mime_type: "image/bmp",
        colors: 4,
        bit_depth: 2,
        rotation: 90,
        offset_x: 10,
        offset_y: 15,
        width: 800,
        height: 480,
        published_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error when creation fails" do
    attributes.delete :width

    post routes.path(:api_models),
         {model: attributes}.to_json,
         "HTTP_AUTHORIZATION" => access_token,
         "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#model_payload",
      status: :unprocessable_entity,
      detail: "Validation failed.",
      instance: "/api/models",
      extensions: {
        errors: {
          model: {
            width: ["is missing"]
          }
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "patches model when valid" do
    patch routes.path(:api_model_patch, id: model.id),
          {model: attributes}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: model.id,
        label: "Test",
        name: "test",
        description: "A test.",
        kind: "terminus",
        mime_type: "image/bmp",
        colors: 4,
        bit_depth: 2,
        rotation: 90,
        offset_x: 10,
        offset_y: 15,
        width: 800,
        height: 480,
        published_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers error when patch fails" do
    patch routes.path(:api_model_patch, id: model.id),
          {model: {}}.to_json,
          "HTTP_AUTHORIZATION" => access_token,
          "CONTENT_TYPE" => "application/json"

    problem = Petail[
      type: "/problem_details#model_payload",
      status: :unprocessable_entity,
      detail: "Validation failed.",
      instance: "/api/models",
      extensions: {
        errors: {
          model: ["must be filled"]
        }
      }
    ]

    expect(json_payload).to match(problem.to_h)
  end

  it "deletes existing record" do
    delete routes.path(:api_model_delete, id: model.id),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(
      data: {
        id: model.id,
        label: model.label,
        name: model.name,
        description: nil,
        kind: "terminus",
        mime_type: "image/png",
        colors: 2,
        bit_depth: 1,
        rotation: 0,
        offset_x: 0,
        offset_y: 0,
        width: 800,
        height: 480,
        published_at: match_rfc_3339,
        created_at: match_rfc_3339,
        updated_at: match_rfc_3339
      }
    )
  end

  it "answers empty payload with invalid ID" do
    delete routes.path(:api_model_delete, id: 666),
           {},
           "HTTP_AUTHORIZATION" => access_token,
           "CONTENT_TYPE" => "application/json"

    expect(json_payload).to match(data: {})
  end
end
