class Person

  attr_accessor :children,:id

  def initialize(id,name,father=nil,mother=nil,children=[])
    attr_accessor :id, :name, :father, :mother, :children

    # unless father==nil
    #   father.children.append(self)
    # end
    # unless mother==nil
    #   mother.children.append(self)
    # end
  end
end