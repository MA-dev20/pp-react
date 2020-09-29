class Teaser < ApplicationRecord
  mount_uploader :logo, LogoUploader
  
  after_update do
    if self.previous_changes[:color_hex]
      red_string = self.color_hex[1] + self.color_hex[2]
      green_string = self.color_hex[3] + self.color_hex[4]
      blue_string = self.color_hex[5] + self.color_hex[6]
      self.color1[0] = red_string.hex.to_i
      self.color1[1] = green_string.hex.to_i
      self.color1[2] = blue_string.hex.to_i
      self.color2[0] = red_string.hex.to_i
      self.color2[1] = green_string.hex.to_i
      self.color2[2] = blue_string.hex.to_i
      self.save
    end
  end
end
