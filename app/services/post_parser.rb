# frozen_string_literal: true

# Parser for post body
class PostParser
  # @param [Post] entity
  def initialize(entity)
    @entity = entity
    @body   = entity.body.clone
  end

  def parsed_body
    unless @entity.avoid_parsing?
      @body = escape_scripts
      @body = convert_video_links
      @body = convert_asides
    end

    @body
  end

  def escape_scripts
    @body.gsub(/<script/, '&lt;script')
  end

  def convert_video_links
    pattern = %r(<p>{video:(?<url>[^}]{1,100})}</p>)i
    @body.gsub(pattern) do
      iframe = video_url_to_iframe($LAST_MATCH_INFO[:url])
      %(<div class="proportional-container r-16x9">#{iframe}</div>)
    end
  end

  def convert_asides
    pattern = %r{<p>~~\s*(.+?)</p>}i
    @body.gsub(pattern) do
      "<aside>#{$LAST_MATCH_INFO[1]}</aside>"
    end
  end

  private

  # @param [String] url
  def video_url_to_iframe(url)
    src = video_iframe_url(url)

    src.blank? ? url : %(<iframe src="#{src}" allowfullscreen></iframe>)
  end

  # @param [String] url
  def video_iframe_url(url)
    if url.match?(%r{\Ahttps?://vimeo\.com})
      process_vimeo_link(url)
    elsif url.match?(%r{\Ahttps?://www\.youtube\.com/watch})
      process_youtube_link(url)
    elsif url.match?(%r{\Ahttps?://youtu\.be/.+})
      process_youtu_be_link(url)
    end
  end

  # @param [String] url
  def process_vimeo_link(url)
    video_id  = url.gsub(%r{\A\D+/(\d+)/?}, '\\1')
    api_url   = "https://vimeo.com/api/v2/video/#{video_id}.json"
    json_data = JSON.parse(URI.open(api_url)).first

    json_data.blank? ? '' : "https://player.vimeo.com/video/#{json_data['id']}"
  end

  # @param [String] url
  def process_youtube_link(url)
    video_id = CGI.parse(URI.parse(url).query)['v'].first
    "//www.youtube.com/embed/#{video_id}"
  end

  # @param [String] url
  def process_youtu_be_link(url)
    video_id = URI.parse(url).path.delete('/')
    "//www.youtube.com/embed/#{video_id}"
  end
end
