require '../ext/randomStream/randomStream.so'
stream = RandomStream.new

10_000_000.times do
  stream.getrandom
end
