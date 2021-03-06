module Frepl
  class MultiDeclaration < SinglelineStatement
    attr_reader :variable_names

    def accept(visitor)
      visitor.visit_multi_declaration(self)
    end

    def declarations
      @declarations ||= @variable_parts.map do |varpart|
        str = "#{@type}"
        str << "#{@kind_len}" if @kind_len
        str << "#{@parameter}" if @parameter
        str << "#{@dimension}" if @dimension
        str << "#{@target}" if @target
        str << "#{@pointer}" if @pointer
        str << " :: #{varpart}"
        Declaration.new(str)
      end
    end

    private 

    # TODO regex needs better parameter/dimension parsing
    def parse
      match_data = line.match(Frepl::Classifier::DECLARATION_REGEX)
      @type = match_data[1]
      kind_len = match_data[2]
      if @kind_len
        if @kind_len.match(/len/)
          @len = @kind_len.match(/=(\d+)/)[1]
        else
          @kind = @kind_len.match(/=(\d+)/)[1]
        end
      end
      @parameter = match_data[3]
      @dimension = match_data[4]
      @target = match_data[5]
      @pointer = match_data[6]
      @variable_names = match_data[7].gsub(/\s*=\s*/, '=').scan(Frepl::Classifier::VARIABLE_NAME_REGEX)
      @variable_assignments = match_data[7].gsub(/\s*=\s*/, '=').
        split(Frepl::Classifier::VARIABLE_NAME_REGEX)[1..-1].
        map { |a| a.gsub(/,\s*$/, '') }
      if @variable_assignments && @variable_assignments.any?
        if @variable_assignments.size < @variable_names.size
          # e.g., integer :: a = 1, b, c
          mask = match_data[7].gsub(/\s*=\s*/, '=').
            scan(/#{Frepl::Classifier::VARIABLE_NAME_REGEX}[=,$\z]?/).
            map { |x| x.match(/=/) ? '=' : '' }
          arr = []
          # pad var assignments array, determine correct locations
          mask.each do |m|
            if m == '='
              arr.push(@variable_assignments.shift)
            else
              arr.push('')
            end
          end
          @variable_assignments = arr
        end
        # should be something like [['a', 'b'], ['=1', '']]
        @variable_parts = [@variable_names, @variable_assignments].transpose.map do |variable_parts|
          variable_parts.join('')
        end
      else
        @variable_parts = @variable_names
      end
    end
  end
end
