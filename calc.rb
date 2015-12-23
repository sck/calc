
def human_readable_time(t)
  ts_signed = t
  ts = ts_signed.abs
  #s = ["sec", "min", "hour", "day", "week", "month", "year"]
  s = ["sec", "min", "hour", "day", "week", "month", "year"]
  div = [60.0, 60.0, 24.0, 7, 4, 12, 999]
  d = div.first
  i = 0
  while ts > (d * 2) && i <= 2
    ts /= d
    i += 1
    d = div[i]
  end
  sign = ts_signed > -1 ? "" : "-"
  m = ts > 1 ? "s" : ""
  sprintf "#{sign}%d #{s[i]}#{m}", ts
end


def human_readable_size(s)
  h = ["", "kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
  i = 0
  while s >= 1000 && i < h.size
    i += 1
    s /= 1000.0
  end
  sprintf "%d#{h[i]}", s
end

def human_readable_size_i(s)
  h = ["", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"]
  i = 0
  while s >= 1024 && i < h.size
    i += 1
    s /= 1024.0
  end
  sprintf "%d#{h[i]}", s
end

def human_readable_size_b(s)
  h = ["", "K", "M", "G", "T", "P", "E", "Z", "Y"]
  i = 0
  while s >= 1000 && i < h.size
    i += 1
    s /= 1000.0
  end
  sprintf "%d#{h[i]}", s
end

def output(v)
  if $seconds
    puts human_readable_time(v)
    return
  end
  if $kind == -1
    puts human_readable_size_b(v)
    return
  end
  v = ($kind == 0) ? v.inspect : ($kind == 1 ? human_readable_size(v) : 
      human_readable_size_i(v)) 
  puts v.nil? ? "" : v
end


$v = {}

$kind = 0

def process(l)
  $kind = 0
  $seconds = false
  units = [
    [{:s=>"YB", :l=>"yottabyte", :v=>1e25},
    {:s=>"YiB", :l=>"yobibyte", :v=>1024**8}],

    [{:s=>"ZB", :l=>"zettabyte", :v=>1e21},
    {:s=>"ZiB", :l=>"zebibyte", :v=>1024**7}],

    [{:s=>"EB", :l=>"exabyte", :v=>1e18},
    {:s=>"EiB", :l=>"exbibyte", :v=>1024**6}],

    [{:s=>"PB", :l=>"petabyte", :v=>1e15},
    {:s=>"PiB", :l=>"pebibyte", :v=>1024**5}],

    [{:s=>"TB", :l=>"terabyte", :v=>1e12},
    {:s=>"TiB", :l=>"tebibyte", :v=>1024**4}],

    [{:s=>"GB", :l=>"gigabyte", :v=> 1e9},
    {:s=>"GiB", :l=>"gibibyte", :v=>1024**3}],

    [{:s=>"MB", :l=>"megabyte", :v=>1e6},
    {:s=>"MiB", :l=>"mebibyte", :v=>1024**2}],

    [{:s=>"KB", :l =>"kilobyte", :v => 1e3},
    {:s=>"KiB", :l => "kibibyte", :v => 1024}]
  ]
  units_bit = [
    [{:s=>"Ybit", :l=>"yottabit", :v=>1e24},
    {:s=>"Yibit", :l=>"yobibit", :v=>(1024**8)/8}],

    [{:s=>"Zbit", :l=>"zettabit", :v=>1e20},
    {:s=>"Zibit", :l=>"zebibit", :v=>(1024**7)/8}],

    [{:s=>"Ebit", :l=>"exabit", :v=>1e17},
    {:s=>"Eibit", :l=>"exbibit", :v=>(1024**6)/8}],

    [{:s=>"Pbit", :l=>"petabit", :v=>1e14},
    {:s=>"Pibit", :l=>"pebibit", :v=>(1024**5)/8}],

    [{:s=>"Tbit", :l=>"terabit", :v=>1e11},
    {:s=>"Tibit", :l=>"tebibit", :v=>(1024**4)/8}],

    [{:s=>"Gbit", :l=>"gigabit", :v=> 1e8},
    {:s=>"Gibit", :l=>"gibibit", :v=>(1024**3)/8}],

    [{:s=>"Mbit", :l=>"megabit", :v=>1e5},
    {:s=>"Mibit", :l=>"mebibit", :v=>(1024**2)/8}],

    [{:s=>"kbit", :l =>"kilobit", :v => 1e2},
    {:s=>"Kibit", :l => "kibibit", :v => 1024/8}]
  ]
  [units].each {|uu|
    uu.each {|kinds|
      reversed = $kind < 2 ? 0  : 1
      k = reversed > 0 ? 2 : 1
      (reversed > 1 ? kinds.reverse: kinds).each {|u|
        re = /(?<=\D|^)(\d+)(#{u[:l]}|#{u[:s]}|#{u[:s][0]})(s|\/s|)(?=\W|$)/i
        l.gsub!(re) {|m|
          number = $1
          $seconds = $3 != ""
          $kind = $2.length == 1 ? -1 : k
          u[:v] * number.to_f
        }
        k = reversed > 0 ? 2 : 1
      }
    }
  }
  [units_bit].each {|uu|
    uu.each {|kinds|
      reversed = $kind < 2 ? 0  : 1
      k = reversed > 0 ? 2 : 1
      (reversed > 1 ? kinds.reverse: kinds).each {|u|
        re = /(?<=\D|^)(\d+)(#{u[:l]}|#{u[:s]})(s|\/s|)(?=\W|$)/i
        l.gsub!(re) {|m|
          number = $1
          $seconds = $3 != ""
          $kind = $2.length == 1 ? -1 : k
          u[:v] * number.to_f
        }
        k = reversed > 0 ? 2 : 1
      }
    }
  }
  l = l.sub(/(^.*)\s*\*\s*(\d+)%/, '(\1/100)*\2')
  op_res = ["*", "+", "%", "/", "^"]
  op_re = "\\" + op_res.join("|\\")
  r = l.gsub(/(?<=^|#{op_re}|\s)([a-zA-Z]+)/) {|v|
    "$v[#{v.inspect}]"
  }
  r2 = r.gsub(/(\d)[\sa-zA-Z$]+(?!\+)/, '\1').gsub(/[\sa-zA-Z$]+(\d)/, '\1')
  r2
end

def interpret(line)
  begin
    output(eval(process line))
  rescue Exception => e
    puts "e: #{e}"
  end
end

more = true

begin
  $stdout.write "> "
  line = STDIN.gets
  more = line && line != ""
  interpret(line) if more
end while more
