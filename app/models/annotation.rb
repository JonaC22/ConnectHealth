# == Schema Information
#
# Table name: annotations
#
#  id          :integer          not null, primary key
#  pedigree_id :integer
#  pos_x       :integer
#  pos_y       :integer
#  text        :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Annotation < ActiveRecord::Base
  include Positionable
  belongs_to :pedigree
  attr_accessor :text
end
