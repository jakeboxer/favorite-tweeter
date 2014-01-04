class Tweeter < ActiveRecord::Base
  def to_param
    screen_name
  end
end
