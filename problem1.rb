# You will write a method in ruby that takes in a sentence as a string and returns all the letters that it is missing from the alphabet. You will ignore the case of the letters in the input sentence and any other characters that are not in the alphabet.  Your return should be all lower case characters in alphabetical order. You may use methods introduced by Rails if you wish
print "Enter your sentence: "
sentence = gets
puts (('a'..'z').to_a - sentence.split("")).join("")