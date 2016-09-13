require '../ext/randomStream/randomStream'

def rand
  @stream ||= RandomStream.new
  @stream.getrandom
end
