# Integer Class extension
class Integer
  # Generates a random integer with a given number of digits
  # @param length [Integer] number of digits of random integer. Default is 1.
  # @return [Integer]
  # @since 1.2.0
  def self.random(length=1)
    raise(ArgumentError, 'Argument should be an Integer!') unless length.is_a?(Integer)
    elements = (0..9).to_a
    [(1..9).to_a.sample, (length-1).times.map { elements.sample }].flatten.join.to_i
  end
end