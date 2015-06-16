class Person

  attr_accessor :id, :name, :gender, :father, :mother, :children

  def initialize(id,name, gender, father=nil,mother=nil,children=[])
    
    @id = id
    @name = name
    @gender = gender
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

  def add_to(pedigree) 
    unless pedigree.get_persons_ids.include? @id
        pedigree.add_person(self)
    end
  end

end