module Frepl
  class Subroutine < MultilineStatement
    def terminal_regex
      /end subroutine\s?#{Frepl::Classifier::VARIABLE_NAME_REGEX}/
    end

    def accept(visitor)
      visitor.visit_subroutine(self)
    end

    def name
      @name ||= lines.first.match(Frepl::Classifier::SUBROUTINE_REGEX)[1]
    end

    def ==(other)
      if other.is_a?(Subroutine)
        self.name == other.name
      else
        super(other)
      end
    end

    private

    def starting_regex
      Frepl::Classifier::SUBROUTINE_REGEX
    end
  end
end
