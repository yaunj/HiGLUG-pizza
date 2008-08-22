#!/usr/bin/tclsh
puts "HiGLUG Pappas Pizza Ordering script.";
puts "The picko TCL-implementation version 0.1\n\n";

set max_price     1200
set regular_price  149
set meal           0.4
set man_eaters     [lindex $argv 0]

set f00dz {
    {"Pappas spesial"      4  10  -20}
    {"Texas"               3   0  -20}
    {"Blue Hawai"          7   0  -20}
    {"Floriad"             4   0  -20}
    {"Buffalo"             4   0  -20}
    {"Chicken"             4   0  -20}
    {"New York"            0   0  -20}
    {"Las Vegas"           6   0  -20}
    {"Vegetarianer"        0   0  -20}
    {"FILADELFIA"          4   0  -20}
    {"Hot Chicago"         7   0  -20}
    {"Hot Express"         5   0  -20}
    {"Kebab pizza spesial" 3  20  -20}
    {"Egenkomponert, Pepperoni, Biff, Bacon, Skinke, løk"       9  10  -20}
    {"Egenkomponert, Biff, Pepperoni, Bacon, Skinke, Tacokjøtt" 9  10  -20}
}

# http://wiki.tcl.tk/941
proc shuffle { list } {
     set n [llength $list]
     for { set i 1 } { $i < $n } { incr i } {
         set j [expr { int( rand() * $n ) }]
         set temp [lindex $list $i]
         lset list $i [lindex $list $j]
         lset list $j $temp
     }
return $list
}

foreach {n} $f00dz {
     for {set i 0} {$i < [lindex $n 1]} {incr i} {
         lappend buf [lindex $n 0]
    }
}

if {[clock format [clock seconds] -format %u] == 3} {
    set offset_index 3
} else { set offset_index 2 }

set buf [shuffle $buf]
set total 0
set nom_nom {}

for {set i 0} {$i < [expr ceil($meal * $man_eaters)]} {incr i} {
     set next_pizza [lindex $buf $i]
     set next_price [expr $regular_price + [lindex [lindex $f00dz 
[lsearch $f00dz *$next_pizza*] ] $offset_index]]

     if {$total + $next_price >= $max_price} {
         break
     } else {
         set total [expr $total + $next_price]
         lappend nom_nom $next_pizza
         puts "$next_pizza ($next_price)"
     }
}

puts "\nSum: $total"

# First make it work, then give a fcuk.
