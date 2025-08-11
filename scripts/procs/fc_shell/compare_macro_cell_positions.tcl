proc compare_cell_positions {before_file after_file} {

    proc read_positions {filename} {
        set fh [open $filename r]
        while {[gets $fh line] >= 0} {
            if {[regexp {^([^,]+),\"([0-9\.]+) ([0-9\.]+)\"} $line -> name x y]} {
                set positions($name) "$x $y"
            }
        }
        close $fh
        return [array get positions]
    }


    array set before [read_positions $before_file]
    array set after  [read_positions $after_file]


    set moved_count 0
    set moved_cells {}
    foreach name [array names before] {
        if {![info exists after($name)]} {
            puts "⚠️ Warning: $name exists in before but not in after"
            continue
        }
        if {$before($name) ne $after($name)} {
            incr moved_count
            lappend moved_cells "$name: $before($name) → $after($name)"
        }
    }

    puts "\n$moved_count cells moved."
    if {$moved_count > 0} {
        puts "Moved cells:"
        foreach cell $moved_cells {
            puts $cell
        }
    }
    return $moved_count
}

