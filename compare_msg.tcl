#!/usr/bin/env tcl

#########################################################
# Program Name: compare_msg
# Purpose: compare_msg program compares messages from two files that have
#           same sequence of messages stored as new line terminated messages.
#           if the sequence is out of order, all messages comparison may be 
#           wrong. This progam compares example hl7 by every field and displays
#           fields that are differen.
#   
#           if the output file is given results will be written to file as csv.
#
#
#
#Parameters:
#   input_file1 : first file name
#   input_file2 :second file name
#   output_file : optional, if given it will write to file otherwise to stdout
#
#
#$Author:$ Dinakar Desai (Please do not remove author name or modify it)
#$Date:$ Sat Dec 22 09:39:19 CST 2007
#
#
#
#############################################################

proc usage {program_name} {
    puts "Usage: $program_name  input_file1 input_file2 \[output_file <optional>]"
    puts "Example\n$program_name test1 prod1 test_prod"
    puts "Above example compares test1 file contents to prod1 contents and puts results"
    puts "in test_prod file\n[string repeat * 76]\n"

    exit
}
if {[llength $argv] < 2 } {
    usage $argv0
}
set input_file1 ""
set input_file2 ""
set output_file ""
if {[llength $argv] == 2 } {
    lassign $argv input_file1 input_file2
} elseif {[llength $argv] == 3 } {
    lassign $argv input_file1 input_file2 output_file
}
if {! [file exist $input_file1] || ! [file exists $input_file2] } {
    puts "[string repeat * 76]\n"
    puts "Please make sure $input_file1 and $input_file2 files exist and are readable"
    puts "[string repeat * 76]\n"
    usage $argv0
}


if {[catch {set input_fh1 [open $input_file1 r]} error_msg]} {
    puts "[string repeat * 76]\n Unable to open $input_file1 for reading: $error_msg\n[string repeat * 76]\n"
    usage $argv0
}
if {[catch { set input_fh2 [open $input_file2 r]} error_msg]} {
     puts "[string repeat * 76]\n Unable to open $input_file2 for reading: $error_msg\n[string repeat * 76]\n"
    close $input_fh1
    usage $argv0

}
set line_num 0
array set diffs {}
set is_different 0
set diff_index 0
while { ( [gets $input_fh1 line1] >= 0 ) && ([gets $input_fh2 line2] >= 0) } {
    incr line_num
    set segments1 [split $line1 \r]
    set segments2 [split $line2 \r]
    set index 0
    foreach segment $segments1 {
        set fields1 [split $segment |]
        set fields2 [split [lindex $segments2 $index ] |]
        set frag_index 0
        foreach field1 $fields1 {
            set field2 [lindex $fields2 $frag_index ]
            if {! [string equal $field1 $field2]} {
                set sub_field_exist [string first "^" $field1 ]
                incr is_different
                if {$sub_field_exist >= 0 } {
                    set sub_fields1 [split $field1 ^]
                    set sub_fields2 [split $field2 ^]
                    set sub_field_index 0
                    foreach sub_field1 $sub_fields1 {
                        set sub_field2 [lindex $sub_fields2 $sub_field_index]
                        incr sub_field_index
                        if {![string equal $sub_field1 $sub_field2] } {
                            set diffs($diff_index) "${line_num},[string range $segment 0 2],${frag_index},${sub_field1},${sub_field2}"
                            incr diff_index
   
                        }
                    }
                } else {
                    set diffs($diff_index) "${line_num},[string range $segment 0 2],${frag_index},${field1},${field2}"
                    incr diff_index
                }
            }
            incr frag_index
        }
        incr index
    }
}
close $input_fh1
close $input_fh2

set format "%-8s%-13s%-13s%-20s%-20s"
if {[string length $output_file] > 0 } {
   if {[catch {set out_fh [open $output_file w] } error_msg ]} {
        echo "Unable to open $output_file for writing because $error_msg"
        exit
   }
    puts $out_fh "Msg_num,Segment_name,Field_number,Field1,Field2]"
    foreach name [lsort -integer [array names diffs] ] {
        puts $out_fh $diffs($name)
    }
    close $out_fh
}
if {$is_different > 0 } {
    puts "[format $format Msg_num Segment_name Field_number Field1 Field2]"
}
foreach name [lsort -integer  [array names diffs] ] {
    set input "$diffs($name)"
    set words [split $input ,]
    set msg_num [lindex $words 0]
    set segment [lindex $words 1]
    set field_num [lindex $words 2]
    set field1 [lindex $words 3]
    set field2 [lindex $words 4]
    puts "[format $format $msg_num $segment $field_num $field1 $field2]"
}

