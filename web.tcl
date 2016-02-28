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

### WEB FETCHER

package require http

proc gethtml { url } {
    if { $url == "" } {
        #empty url, return an empty list.
        return [list]
    } else {
        set token [http::config -useragent "Mozilla/5.0 (X11; U; Linux i686; fr; rv:1.8.0.7) Gecko/20060909 Firefox/1.5.0.7"]
        set token [http::geturl "$url"]
        set data [split [http::data $token] "\n"]
        http::cleanup $token

        return $data
    }
}

proc urlencode {text} {
    set url ""
    foreach byte [split [encoding convertto utf-8 $text] ""] {
        scan $byte %c i
        if {[string match {[%<>"?=+&]} $byte] || $i <= 32 || $i > 127} {
            append url [format %%%02X $i]
        } else {
            append url $byte
        }
    }
    return $url
}
