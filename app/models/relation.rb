class Relation
  include Positionable
  attr_accessor :from, :to, :name
  def initialize(from, to, name)
    @from = from
    @to = to
    @name = name
  end
  def self.unique?(relation)
    %w(MADRE PADRE).include? relation.to_s
  end

  def self.decremental?(relation)
    %w(MADRE PADRE).include? relation.to_s
  end
end
