class PostParser
  def initialize(entity)
    @entity = entity
    @body   = entity.body.clone
  end

  def parsed_body
    escape_scripts
    convert_video_links
    @body
  end

  def escape_scripts
    @body.gsub!(/<script/, '&lt;script')
  end

  def convert_video_links
    pattern = /<p>{video:(?<url>[^}]{1,100})}<\/p>/i
    @body.gsub! pattern do |chunk|
      iframe = video_url_to_iframe(pattern.match(chunk)[:url])
      "<div class=\"proportional-container r-16x9\">#{iframe}</div>"
    end
  end

  private

  def video_url_to_iframe(url)
    if url =~ /\Ahttps?:\/\/vimeo\.com/
      src = process_vimeo_link(url)
    elsif url =~ /\Ahttps?:\/\/www\.youtube\.com\/watch/
      src = process_youtube_link(url)
    elsif url =~ /\Ahttps?:\/\/youtu\.be\/.+/
      src = process_youtu_be_link(url)
    else
      src = ''
    end

    if src.blank?
      url
    else
      "<iframe src=\"#{src}\" allowfullscreen></iframe>"
    end
  end

  def process_vimeo_link(url)
    video_id  = url.gsub(/\A\D+\/(\d+)\/?/, "\\1")
    api_url   = "https://vimeo.com/api/v2/video/#{video_id}.json"
    json_data = JSON.load(open(api_url)).first

    json_data.blank? ? '' : "https://player.vimeo.com/video/#{json_data['id']}"
  end

  def process_youtube_link(url)
    video_id = CGI.parse(URI.parse(url).query)['v'].first
    "//www.youtube.com/embed/#{video_id}"
  end

  def process_youtu_be_link(url)
    video_id = URI.parse(url).path.gsub('/', '')
    "//www.youtube.com/embed/#{video_id}"
  end
end
