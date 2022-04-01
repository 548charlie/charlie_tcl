#!/usr/bin/env tcl
#

proc get_newFilename { name } {
    set ext [file extension $name ]
    set basename [file rootname $name ]
    set words [split $basename _ ]

    if {[llength $words ] == 1 } {
        set basename "${basename}_dd_0"
    } elseif {[llength $words ] == 2 } {
        set inits [lindex $words end ]
        set name [lindex $words 0 ]
        set basename "${name}_${inits}_0"
    } else { 
        set inits [lindex $words end-1 ] 
        set num [lindex $words end ]
        if {[string is integer $num ] } {
            incr num 
        } else {
            set num "${num}_0" 
        }
        set name [join [lrange $words 0 end-2  ] _ ] 
        set  alist [list $name $inits $num ]
        set basename [join $alist _ ]
    }
    set outfile "${basename}${ext}"


    return $outfile
}


 proc readFile {filename} {
    set outfile [get_newFilename $filename]
     
    puts "Created a new file $outfile"
    set of [open $outfile w ]
    set msg {}
    set seg {}
    set preseg "MSH"
    set startSeg 0
    set fldsep {}
    set segment {}
    set segFields {}
    set idx 0
    if { [file exists $filename] } {
        set infile [open $filename r ]
        while {[gets $infile line ] >= 0 } {
            set line [string trim $line ]
            if { [string equal $line "" ] } {
                continue 
            }
            set fields  [split $line |]
            set seg [string range [lindex $fields  0] 0 2 ]
            set idx [string index [lindex $fields 0 ] 4 ]
            set field [string trim [lindex $fields 1 ]]
            if { $seg == $preseg && $idx > 0} {
                lappend segFields $field
            } else { 
                set preseg $seg 
                set segment [join $segFields | ]
                lappend msg $segment
                set segFields [list $seg ]
            } 
        }
        set segment [join $segFields | ]
        lappend msg $segment
        set msg [join $msg \r ]
        set msg [string trim $msg ]
        puts $of $msg
        close $infile
        close $of
    }
 }

if {$argc > 0 } { 
    set filename [lindex $argv 0  ]
    readFile $filename
}
