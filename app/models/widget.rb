# == Schema Information
#
# Table name: widgets
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text
#  stock       :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Widget < ActiveRecord::Base
end
