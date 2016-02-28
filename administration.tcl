###
#
#  Copyright (c) 2008 Carl-Magnus "NRGizeR" Björkell
#
#
#  This file is part of the Luverboy eggdrop script.
#
#  The Luverboy eggdrop script is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  The Luverboy eggdrop script is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with the Luverboy eggdrop script.  If not, see <http://www.gnu.org/licenses/>.
#
###


### ADMINISTER YOUR "ACCOUNT"
bind pub -|- !resetpass resetpass
bind pub -|- !setphone setphone

registerhelp "resetpass" "Resets your password (or creates a new one). NOTE: Works both in a private message to me, and as a public command." \
            "!resetpass" \
            "!resetpass" 3 "pub" "pass"
registerhelp "op" "This ops you on the public and private channel. NOTE: this message has to be sent as a PRIVATE message. Make sure you don't type your password in the channel :)" \
            "!op <password>" \
            "/msg $botnick !op mysecretandverygoodpass" 1 "priv"
registerhelp "setpass" "This sets your password (for example after you've reset it with !resetpass) NOTE: this message has to be sent as a PRIVATE message. Make sure you don't type your password in the channel :)" \
            "!setpass <oldpass> <newpass>" \
            "/msg $botnick !setpass mysecretOLDpass mysecretNEWpass" 3 "priv" "pass"
registerhelp "setphone" "This sets your phone number. It will only be sent to other ${myprefix}s via the !{myprefix}phone command. NOTE: Works both in a private message to me, and as a public command." \
            "!setphone <phone number>" \
            "/msg $botnick !setphone 0505553181" 3 "pub" "members"

proc changepassword { nick host hand arg } {
    global pchan privchan hashsalt
    set arg [getargs $arg 2]
    if { [hasaccess $nick "setpass"] } {
        if { [llength $arg] > 1 } {
            set db [getdb]

            set membername [mysqlescape [translateirc $nick $db]]
            set password [mysqlsel $db "select password from members where name like '$membername'" -flatlist]
            if { [llength $password] < 1 } {
                luvmsg $nick "setpass" "Do I know you?"
            } elseif { [lindex $password 0] == "" } {
                luvmsg $nick "setpass" "You haven't created your password! Reset your password with !resetpass after you get ops."
            } elseif { [string length [lindex $arg 1]] < 6 } {
                luvmsg $nick "setpass" "The new password is too short. Your password needs to have a length of at least 6 characters."
            } else {
                set givenpass [string tolower [sha2::sha256 -hex "${hashsalt}[lindex $arg 0]"]]

                if { $givenpass == [lindex $password 0] } {
                    set newpass [string tolower [sha2::sha256 -hex "${hashsalt}[lindex $arg 1]"]]
                    mysqlexec $db "update members set password = '$newpass' where name like '$membername'"
                    luvmsg $nick "setpass" "Set your password to [lindex $arg 1]."
                } else {
                    luvmsg $nick "setpass" "No can do. The password is wrong."
                }
            }
        } else {
            luvnotc $nick "setpass" "syntax: [gethelpsyntax setpass]"
        }
    }
}

proc setphone {nick uhost hand chan arg} {
    global myprefix
    if { [hasaccess $nick "setphone"] } {
        set arg [getargs $arg 1]
        set output $chan
        if { $chan == "" } {
            set output $nick
        }

        set db [getdb]
        set membernick [mysqlescape [translateirc $nick $db]]
        set memberid [mysqlsel $db "SELECT id from members where name like '$membernick'" -flatlist]

        if {[llength $memberid] < 1} {
            luvnotc $output "setphone" "Do I know you?"
        } else {
            if { [llength $arg] > 0 && [regexp "^\[0-9\]+$" [lindex $arg 0]] } {
                set id [lindex $memberid 0]
                if { ![mysqlexec $db "update members set phone = '[lindex $arg 0]' where id = '$id'"] } {
                    set phone [mysqlsel $db "select phone from members where id = '$id'" -flatlist]
                    if { [llength $phone] > 0 && [lindex $phone 0] == [lindex $arg 0] } {
                        luvmsg $output "setphone" "Your phone number is already set to \2[lindex $arg 0]\2."
                    } else {
                        luvmsg $output "setphone" "I couldn't update your number for some reason :<"
                    }
                } else {
                    luvmsg $output "setphone" "Your phone number was set to \2[lindex $arg 0]\2. This is the number I will give other ${myprefix}s in a private message if they request it via !{myprefix}phone."
                }
            } else {
                luvnotc $output "setphone" "syntax: [gethelpsyntax setphone]"
            }
        }
    }
}

proc resetpass {nick uhost hand chan arg} {
    global privchan mypage
    if { [hasaccess $nick "resetpass"] } {

        set db [getdb]
        set membernick [mysqlescape [translateirc $nick $db]]
        set memberid [mysqlsel $db "SELECT id from members where name like '$membernick'" -flatlist]

        if {[llength $memberid] < 1} {
            luvnotc $nick "resetpass" "Do I know you?"
        } else {
            set id [lindex $memberid 0]
            set pwhash [generatepass]
            set pw [lindex $pwhash 0]
            set hash [lindex $pwhash 1]
            if { ![mysqlexec $db "update members set password = '$hash' where id = '$id'"] } {
                luvmsg $nick "resetpass" "Failed to reset the password"
            } else {
                luvmsg $nick "resetpass" "Password reset, new password is: $pw"
                luvmsg $nick "resetpass" "You better remember it, because I'll forget it now :)"
                luvmsg $nick "resetpass" "You can now use your new password to login to the member section of the webpages (${mypage}) or use my !op function to get opped in the channel. The password can be changed by using !setpass or on the website."
            }
        }
    }
}

proc giveops { nick host hand arg } {
    global pchan privchan hashsalt
    set arg [getargs $arg 1]
    if { [llength $arg] > 0 } {
        set db [getdb]

        set membername [mysqlescape [translateirc $nick $db]]
        set password [mysqlsel $db "select password from members where name like '$membername'" -flatlist]
        if { [llength $password] < 1 } {
            luvmsg $nick "op" "Do I know you?"
        } elseif { [lindex $password 0] == "" } {
            luvmsg $nick "op" "You haven't created your password! Reset your password with !resetpass after you get ops."
        } else {
            set givenpass [string tolower [sha2::sha256 -hex "${hashsalt}[lindex $arg 0]"]]

            if { $givenpass == [lindex $password 0] } {
                pushmode $pchan +o $nick
                pushmode $privchan +o $nick
                luvmsg $nick "op" "Opped you on $pchan and $privchan."
                flushmode $pchan
                flushmode $privchan
            } else {
                luvmsg $nick "op" "No can do. The password is wrong."
            }
        }
    } else {
        luvnotc $nick "op" "syntax: [gethelpsyntax op]"
    }
}

proc generatepass { } {
    global hashsalt
    set randstr ""
    for { set i 0 } { $i < 7 } { incr i } {
        set randnum [expr int(rand()*62)]
        if { $randnum < 10 } {
            append randstr $randnum
        } elseif { $randnum < 36 } {
            append randstr [to_char [expr $randnum + 55]]
        } else {
            append randstr [to_char [expr $randnum + 61]]
        }
    }
    return [list "$randstr" "[string tolower [sha2::sha256 -hex ${hashsalt}${randstr}]]"]
}

proc to_char { value } {
    return [format %c $value]
}
