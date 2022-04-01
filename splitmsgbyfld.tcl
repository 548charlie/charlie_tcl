#!/usr/bin/env tcl
#


proc processLine { line } {

}

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
     
    set outfile [get_newFilename $filename ]
    set of [open $outfile w ]
    if { [file exists $filename] } {
        set infile [open $filename r ]
        while {[gets $infile line ] >= 0 } {
            set line [string trim $line ]
            if {[string equal $line "" ] } {
                continue 
            }
            set segments [split $line \r ]
            foreach seg $segments {
                set seg [string trim $seg ]
                set fldsep [string index $seg 3 ]
                set cmpsep [string index $seg 4 ]
                set fields [split $seg $fldsep ]
                set segName [string range $seg 0 2 ]
                set fldcnt 0
                foreach field $fields {
                    set aline "${segName}_${fldcnt}$fldsep${field} "
                    puts $of $aline
                    incr fldcnt
                }
            }

        }
        close $infile
        close $of
        puts "$outfile create with all fields"
    } else {
        puts "File $filename does not exits" 
    }
 }

if {$argc > 0 } { 
    set filename [lindex $argv 0  ]
    set f [open $filename r ]
    set text [read $f ]
    close $f

    set mshs [llength [regexp -inline -all  MSH $text] ]
    if { $mshs == 1 } {
        readFile $filename
    } else {
        puts "More than one message in $filename" 
    }
}
