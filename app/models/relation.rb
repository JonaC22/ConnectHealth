class Relation
	attr_accessor :id, :from, :to, :name
  def initialize(from,to,name)
    @from = from
    @to=to
    @name=name
  end

  def add_to(pedigree) 
	pedigree.add_relation(self)
  end
end