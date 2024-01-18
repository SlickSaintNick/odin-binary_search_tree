class Food
  attr_accessor :protein

  def initialize(protein)
    @protein = protein
  end
end

test = Food.new('chicken')
p test.protein
