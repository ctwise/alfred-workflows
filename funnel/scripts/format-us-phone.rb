input = STDIN.read
digits = input.gsub(/[^0-9]/, '')
result = input
if digits.length >= 10
	if digits.length > 10
		result = "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}, #{digits[10..-1]}"
	else
		result = "(#{digits[0..2]}) #{digits[3..5]}-#{digits[6..9]}"
	end
end
print result