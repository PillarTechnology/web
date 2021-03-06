
class ForkerController < ApplicationController

  def fork
    result = { forked: false }
    error = false

    if !error && kata.nil?
      error = true
      result[:reason] = "dojo(#{id})"
    end

    if !error && kata.language.nil?
      error = true
      result[:reason] = "language(#{kata.manifest['language']})"
    end

    if !error && avatar.nil?
      error = true
      result[:reason] = "avatar(#{avatar_name})"
    end

    #tag = avatar.tags[params['tag']]
    if !error # && !light.exists?
      is_tag = params['tag'].match(/^\d+$/)
      tag = params['tag'];
      if !is_tag || tag.to_i <= 0 || tag.to_i > avatar.lights.count
        error = true
        result[:reason] = "traffic_light(#{tag})"
      end
    end

    if !error
      language = kata.language
      tag = params['tag'].to_i
      # don't use kata.instructions.name because
      # the instructions might have been renamed
      manifest = {
                         id: unique_id,
                    created: time_now,
                   language: language.name,
                   exercise: kata.manifest['exercise'],
        unit_test_framework: language.unit_test_framework,
                   tab_size: language.tab_size,
              visible_files: avatar.tags[tag].visible_files
      }
      forked_kata = katas.create_kata_from_kata_manifest(manifest)

      result[:forked] = true
      result[:id] = forked_kata.id
    end

    respond_to do |format|
      format.json { render json: result }
      format.html { redirect_to controller: 'enter',
                                    action: 'show',
                                        id: result[:id] }
    end
  end

  private

  include TimeNow
  include UniqueId

end

