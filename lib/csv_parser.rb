module CsvParser

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    mattr_accessor :attr_parsable

    def import_csv(file, bank="POSB")
      all = []
      CSV.foreach(file.path) do |row|
        obj = self.new 
        @@attr_parsable.each_with_index do |attr, i|
          obj.send("#{attr}=".to_sym, row[i])
        end
        all << obj  if obj.valid?
      end
      self.transaction do
        all.each(&:save!)
      end
    end

    def export_csv(file, bank)
      raise NotImplementedError
    end
  end
end
