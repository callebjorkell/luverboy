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


###########################################################################################
#                                                                                         #
# Luverboy 1.0.1 by NRGizeR (NRGizeR/#lovemessengers @ QuakeNET)                          #
#                                                                                         #
# The script requires mysqltcl (loaded in helper.tcl), it will quite possibly work with   #
# different versions, just change the "load" line and try :)                              #
#                                                                                         #
# Updated 01.10.2008                                                                      #
#                                                                                         #
###########################################################################################
#                                                                                         #
# Credit goes out to the creators of similar projects, whose code helped me alot when I   #
# started the Luverboy project:                                                           #
#                                                                                         #
# mick@rebel.net.nz (mick/#nzhondas @ undernet)                                           #
# Dragoneye^ and z0                                                                       #
#                                                                                         #
###########################################################################################

#load dependencies - there are more dependencies specified in the individual modules.
#However, sha256 and mysqltcl are crucial for luverboy to work at all.
package require sha256
package require mysqltcl

#load the individual parts of the luverboy script(s). Some of these parts depend on one
#another, so it is not possible to disable all modules (trial and error will show the way :) )

#username is set in the .conf file!!
source ${username}/config.tcl
source ${username}/helper.tcl
source ${username}/help.tcl
source ${username}/general.tcl
source ${username}/privmsg.tcl
source ${username}/administration.tcl
source ${username}/vote.tcl
source ${username}/reminder.tcl
source ${username}/cwspy.tcl
source ${username}/restricted.tcl
source ${username}/basicdb.tcl
source ${username}/weather.tcl
source ${username}/oneliner.tcl
source ${username}/tells.tcl
source ${username}/protection.tcl
source ${username}/matchquality.tcl
source ${username}/learn.tcl
source ${username}/8ball.tcl
source ${username}/google.tcl


set extensions [glob ${username}/ext/*.tcl]
foreach ext $extensions {
    source $ext
}
