# Class to fix errors in CSV parsing with some reason codes
class CSVFixer
  require 'csv'
  
  REGEX = /(x1|x2|x3|x4|10|[1-9])/

  def initialize(input, output)
    @input_file = input
    @output_file = output
  end

  # Method to convert the file to valid codes
  def convert
    output = CSV.open(@output_file, 'wb', headers: %w(id retoure_reason), write_headers: true)
    CSV.read(@input_file, headers: true).each do |row|
      reason_code = fix_code(row['retoure_reason'])
      output << [row['id'], reason_code]
    end
    output.close
  end
 
  # Method for code fix logic
  def fix_code(code)
    return '8' if code.to_i >= 1_000_000 # condition for error code
    code.gsub(/[\/|,]/, '').scan(REGEX).flatten.join(',')
  end

end

input = 'input.csv'
output = 'output.csv'
csv_fixer = CSVFixer.new(input, output)
csv_fixer.convert
