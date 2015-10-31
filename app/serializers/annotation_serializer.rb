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
# Indexes
#
#  index_annotations_on_pedigree_id  (pedigree_id)
#

class AnnotationSerializer < ActiveModel::Serializer
  attributes :id, :text
end
