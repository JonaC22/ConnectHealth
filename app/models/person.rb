class Person

  attr_accessor :id, :name, :father, :mother, :children

  def initialize(id,name,father=nil,mother=nil,children=[])
    
    @id = id
    @name = name
    @father = father
    @mother = mother
    @children = children
    # unless father==nil
    #   father.children.append(self)
    # end
    # unless mother==nil
    #   mother.children.append(self)
    # end
  end
end