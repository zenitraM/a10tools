#!/usr/bin/env ruby

# script2fex.rb - converts a script.bin for Allwinner A10 into a .fex ini file which can be compiled back
# by using the closed-source script tool.
# Usage: ./script2fex.rb script.bin > script.fex

file = open(ARGV[0], 'rb')
sec_count = file.read(4).unpack('v')[0]
#puts "Sections: #{sec_count}"
file.seek(16)
sections = []
count = 0
sec_count.times do |s|
  name = file.read(32).unpack("A32")[0]
  elem = file.read(4).unpack('v')[0]
  data2 = file.read(4).unpack('v')[0]
  sections << [name, elem, data2]
  count += elem
end
#puts "Elements: #{count}"
elements = []
count.times do |s|
  name = file.read(32).unpack("A32")[0]
  pos = file.read(4).unpack('v')[0]
  size = file.read(2).unpack('v')[0]
  type = file.read(2).unpack('v')[0]
  
  elements << [name, pos, size, type, 0, 0]
end

elements.each do |e|
  e[4] = file.read(4*e[2])
end

elements.each do |e|
  if(e[3] == 2)
    str_repr = '"'+e[4].unpack("A#{e[2]*4}")[0]+'"'
  elsif e[3] == 1
    str_repr = e[4].unpack("V")[0]
  elsif e[3] == 4
    p = []
    type = e[4][0..3].unpack("V")[0]

    port = e[4][4..7].unpack("V")[0]

    p[0] = e[4][8..11].unpack("V")[0]
    p[1] = e[4][12..15].unpack("V")[0]
    p[2] = e[4][16..19].unpack("V")[0]
    p[3] = e[4][20..23].unpack("V")[0]
    q = []
    p.each_index do |i|
      if p[i] == 0xffffffff
        q[i] = "<default>"
      else
        q[i] = "<#{p[i]}>"
      end
    end
    str_repr = "port:P#{(64+type).chr}#{port}#{q.join}"
    
  end
  e[5] = str_repr
end

cur = 0
sections.each do |s|
  puts "[#{s[0]}]"
  s[1].times do
    puts "#{elements[cur][0]} = #{elements[cur][5]}"
    cur += 1
  end
end