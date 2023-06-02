puts 1.class
puts nil.class
puts true.class

5.times { puts("Hello World!") }

# interesting memory management implications

# RVALUE
# 40 bytes
# 8 bytes flags
# 8 bytes Class pointer
# 24 bytes for object fields

# Heap
# Heap page - 16KB or 409 slots
# --------------------------
# | S1 | S2 | S3 | S4 | S5 |
# --------------------------

# each slot's size is 40 bytes
# what happens when object is larger than 24 bytes???
# they are not actually stored in Ruby heap
# they are stored in system heap and memory is dynamically allocated via malloc
# this is very important because it adds a certain performance overhead

# there is an ongoing effort for Ruby 3 by Peter Zhu & team @Shopify
# variable width allocation
# Heap pages consists of different slot pools
# -------------------------- 40 bytes slots
# | S1 | S2 | S3 | S4 | S5 |
# --------------------------
# -------------------------- 80 bytes slots
# | S1      | S2      |       |
# ----------------------------
# 160 bytes

# this allows to store bigger objects in ruby heap without using malloc
# more efficient use of CPU cache because of data colocation

# Mark-Sweep-Compact garbage collection algorithm
# mark stage - color objects (tri-color algorithm white-grey-black)
# sweep stage - delete objects that are not referenced anymore
# compact stage - relocate objects so that they would be located in a sequential heap slots

# generational GC - old vs young generation
# old is an object that survived 3 GCs
# minor and major GC, minor looks only on young objects
# incremental GC - pauses and continues (stop-the-world)

puts GC.stat

class Foo
  attr_reader :bar

  def initialize(bar)
    @bar = bar
  end

  def foo
    "my bar is #{bar}"
  end

  class << self
    def cfoo
      "i am class method"
    end
  end
end

puts Foo.new("1").foo

# single inheritance

class Baz < Foo
  def foo
    "I am Baz and #{super}"
  end
end

puts Baz.new("2").foo
puts Baz.ancestors

puts Foo.cfoo
puts Baz.cfoo

# mixins support, include vs extend
# module is a collection of methods

module Loggable
  def log(query)
    "Your log is #{query}"
  end
end

class FooBar
  include Loggable
end

puts FooBar.ancestors
puts FooBar.new.log("cat")

class FooBaz
  extend Loggable
end

puts FooBaz.ancestors
puts FooBaz.log ("dog")

module LoggableBoth
  module ClassMethods
    def class_log(message)
      message
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end

  def log(message)
    message
  end
end

class FooBarBaz
  include LoggableBoth
end

# prepend - create aspects around a method

module FlowInstrumented
  def run
    puts "Before running"
    result = super
    puts "After running"
    result
  end
end

class CalculatePrice
  prepend FlowInstrumented

  def run
    "Your price is $9999,99"
  end
end

puts CalculatePrice.ancestors
puts CalculatePrice.new.run

# dynamic typing and duck typing
# unless sorbet

calculator = CalculatePrice.new
puts(calculator.respond_to?(:run))
puts(calculator.respond_to?(:call))

# monkey patching and refinement

# class String
#   def bark
#     "Woof"
#   end
# end

# puts "dog".bark

module BarkingString
  refine ::String do
    def bark
      "Woof"
    end
  end
end

class Dog
  using BarkingString

  def foo
    "dog".bark
  end
end

puts Dog.new.foo
# puts "dog".bark

# blocks procs lambdas

[1, 2, 3].each do |num|
  puts num
end

def run_twice
  2.times { yield }
end

run_twice { puts "Hello" }

def explicit(&block)
  block.call
end

explicit { puts "Hello" }

say_hello = ->(x) { puts "Hello #{x}" }
say_hello.call("World")
puts say_hello
puts say_hello.lambda?


say_goodbye = Proc.new { |x| puts "Goodbye, #{x}" }
say_goodbye.call("X")
say_goodbye.call
# benchmarks

require 'benchmark'
n = 5000000
Benchmark.bmbm(7) do |x|
  x.report("for:")   { for i in 1..n; a = "1"; end }
  x.report("times:") { n.times do   ; a = "1"; end }
  x.report("upto:")  { 1.upto(n) do ; a = "1"; end }
end

# memory

puts ObjectSpace.count_objects









# interview

module TestRunnable
  def run
    puts "before"
    result = super
    puts "after"
    result
  end
end

module StringRefinement
  refine ::String do
    def foo
      "foo"
    end
  end
end

class PriceCalculation
  prepend TestRunnable
  using StringRefinement

  def run
    "9,99".foo
  end
end

puts(PriceCalculation.ancestors)

Foo.class_eval do
  def foo
    "bar"
  end
end

fork {  }

data = {}
mutex = Mutex.new

thread = Thread.new {
  poll
  data[:der] = 1
  puts data[:fd] =  1
  sleep 1
}
# GIL
# C-extensions
# collections

Fiber.new # 4kB
fiber.resume

nil.class
true.class

RVALUE
40 bytes
8 bytes
8 bytes class popinter
24 byte

heap
40 bytes
80 bytes
160 bytes
800 bytes

malloc()

# in ruby object creation is not free

# page 16kb - 409 slots (RVALUE)
# GC
# Mark-Sweep-Compact GC
# foo.object_id
# generational
# old generation (survived 3 GCs)
# young generation

# minor GC - looks only on young
# major GC - looks on all objects

# stop-the-world

class Registration
  def call
    User.create
  end
end
