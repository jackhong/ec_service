class Experiment < Sequel::Model
  def validate
    validates_unique :name
  end
end
