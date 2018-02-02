require 'byebug'
require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns

  return @column_name[0].map{|el| el = el.to_sym} unless @column_name.nil?
  @column_name =  DBConnection.execute2(<<-SQL)
  SELECT
    *
  FROM
    #{self.table_name}
    SQL
    @column_name[0].map{|el| el = el.to_sym}
  end

  def self.finalize!
    self.columns.each do |column|
      define_method (column) do # {}"#{column}"
         self.attributes[column]
      end
      define_method ("#{column}=") do |val|
         self.attributes[column] = val
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    self.to_s.downcase + 's'
  end

  def self.all
    obj = DBConnection.execute(<<-SQL)
    SELECT
      *
    FROM
      #{self.table_name}
      SQL
      self.parse_all(obj)
  end

  def self.parse_all(results)
      arr = []
      results.each do
        |obj| arr << self.new(obj)
      end
      arr
  end

  def self.find(id)

    obj = DBConnection.execute(<<-SQL, id)
    SELECT
      *
    FROM
      #{self.table_name}
    WHERE
      #{self.table_name}.id = ?
    LIMIT
     1
      SQL
    return self.new(obj.first) unless obj.empty?
    nil
  end

  def initialize(params = {})
    params.each do |key, value|
      symbolized = key.to_sym
      raise "unknown attribute '#{key}'" unless self.class.columns.include?(symbolized)
      self.send("#{symbolized}=", value)
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    arr = []
    self.attributes.each {|k,v| arr << v }
      arr
  end

  def insert
    arr_of_commas = []
    col_names = self.class.columns.join(",") #takes the first row with id names and else
    col_names.length.times do
    arr_of_qm << ['?']
    arr_of_commas.join(",")
    end
    DBConnection.execute(<<-SQL)
      INSERT INTO
        #{self.table_name}(col_names)
      VALUES
        arr_of_qm


    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
