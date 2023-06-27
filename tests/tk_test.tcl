package require Tk


proc menu_clicked { no opt } {
	tk_messageBox -message \
		"You have clicked $opt.\nThis function is not implanted yet."
}

#Declare that there is a menu
menu .mbar
. config -menu .mbar

#The Main Buttons
.mbar add cascade -label "File" -underline 0 \
      -menu [menu .mbar.file -tearoff 0]
.mbar add cascade -label "Others" \
      -underline 0 -menu [menu .mbar.oth -tearoff 1]
.mbar add cascade -label "Help" -underline 0 \
      -menu [menu .mbar.help -tearoff 0]

## File Menu ##
set m .mbar.file
$m add command -label "New" -underline 0 \
	  -command { .txt delete 1.0 end } ;# A new item called New is added.
$m add checkbutton -label "Open" -underline 0 -command { menu_clicked 1 "Open" }
$m add command -label "Save" -underline 0 -command { menu_clicked 1 "Save" }
$m add separator
$m add command -label "Exit" -underline 1 -command exit

## Others Menu ##
set m .mbar.oth
$m add cascade -label "Insert" -underline 0 -menu [menu $m.mnu -title "Insert"] 
  $m.mnu add command -label "Name" \
       -command { .txt insert end "Name : Binny V A\n"}
  $m.mnu add command -label "Website" -command { \
     .txt insert end "Website: http://www.bin-co.com/\n"}
  $m.mnu add command -label "Email" \
	   -command { .txt insert end "E-Mail : binnyva@hotmail.com\n"}
$m add command -label "Insert All" -underline 7 \
	-command { .txt insert end {Name : Binny V A
	  Website : http://www.bin-co.com/
	  E-Mail : binnyva@hotmail.com}
	  }

## Help ##
set m .mbar.help
$m add command -label "About" -command { 
	.txt delete 1.0 end
	.txt insert end {
	About
	----------
	This script created to make a menu for a tcl/tk tutorial.
	Made by Binny V A
	Website : http://www.bin-co.com/
	E-Mail : binnyva@hotmail.com
	}
	}

#Making a text area
text .txt -width 50
pack .txt

# wm title . "Feet to Meters"
# after 3000
# grid [ttk::frame .c -padding "3 3 12 12"] -column 0 -row 0 -sticky nwes
# grid columnconfigure . 0 -weight 1; grid rowconfigure . 0 -weight 1

# grid [ttk::entry .c.feet -width 7 -textvariable feet] -column 2 -row 1 -sticky we
# grid [ttk::label .c.meters -textvariable meters] -column 2 -row 2 -sticky we
# grid [ttk::button .c.calc -text "Calculate" -command calculate] -column 3 -row 3 -sticky w

# grid [ttk::label .c.flbl -text "feet"] -column 3 -row 1 -sticky w
# grid [ttk::label .c.islbl -text "is equivalent to"] -column 1 -row 2 -sticky e
# grid [ttk::label .c.mlbl -text "meters"] -column 3 -row 2 -sticky w


# foreach w [winfo children .c] {grid configure $w -padx 5 -pady 5}
# focus .c.feet
# bind . <Return> {calculate}

# puts $tk_patchLevel

# proc calculate {} {  
#    if {[catch {
#        set ::meters [expr {round($::feet*0.3048*10000.0)/10000.0}]
#    }]!=0} {
#        set ::meters ""
#    }
# }

# vwait forever