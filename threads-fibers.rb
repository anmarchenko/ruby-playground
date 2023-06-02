class AddOneTask
  @@total = 0
  def initialize
    puts "Scheduling task"
    @performed = false
  end
  def performed?
    @performed
  end
  def perform
    unless performed?
      @@total += 1
      @performed = true
    end
    puts "Task performed, state #{@@total}"
    self
  end
  def self.state
    @@total
  end
end


# require 'thread'
# scheduled = []; performed = []; producers = []; consumers = []

# 5.times do
#   producers << Thread.new do
#     scheduled.push AddOneTask.new
#   end
# end

# 5.times do
#   consumers << Thread.new do
#     loop do
#       task = scheduled.pop
#       performed << task.perform unless task.nil?
#       break if scheduled.empty?
#     end
#   end
# end

# (producers).each { |t| t.join }
# sleep 1
# (consumers).each { |t| t.join }

require 'fiber'
scheduled = []; performed = []
consumers = []; scheduler = nil
producer = Fiber.new do
  5.times do
    scheduled.push AddOneTask.new
    scheduler.transfer
  end
end
5.times do
  consumers << Fiber.new do
    task = scheduled.pop
    performed << task.perform unless task.nil?
    Fiber.yield
  end
end
scheduler = Fiber.new do
  consumers.each do |c|
    c.resume
    producer.transfer
  end
end
producer.resume
