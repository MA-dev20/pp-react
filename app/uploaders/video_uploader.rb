class VideoUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Video
  include CarrierWave::Video::Thumbnailer
  include CarrierWave::FFmpeg

  # Choose what kind of storage to use for this uploader:
  storage :file

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  version :video, :if => :video? do
    process :encode
  end
  
  version :thumb do
    process thumbnail: [{format: 'jpg', quality: 8, size: 360, logger: Rails.logger, square: false}]
    def full_filename for_file
      jpg_name for_file, version_name
    end
  end
  
  def encode
    video = FFMPEG::Movie.new(@file.path)
    video_transcode = video.transcode(@file.path)
  end
  
  version :image, :if => :image? do
    process :resize_to_fit => [740, 300]
  end
  
  def jpg_name for_file, version_name
    %Q{#{version_name}_#{for_file.chomp(File.extname(for_file))}.jpg}
  end

  # def extension_whitelist
  #   %w(mp4)
  # end
  
  protected
  
  def image?(new_file)
    new_file.content_type.include? 'image'
  end

  def video?(new_file)
    new_file.content_type.include? 'video'
  end
end
