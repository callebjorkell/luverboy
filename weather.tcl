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


### WEATHER MODULE

source ${username}/web.tcl

set baseurl_weather "http://mobile.wunderground.com"
set basepath_weather "/cgi-bin/findweather/getForecast?brand=mobile&query="

bind pub -|- !weather showweather
bind pub -|- !forecast showforecast

registerhelp "weather" "Shows the weather at the given location. If you are a ${myprefix} and you don't give a location, the weather for your location is showed." \
            "!weather \[location\]" \
            "!weather Turku" 1 "pub" "weather"
registerhelp "forecast" "Shows the current forecast for the given location. If you are a ${myprefix} and you don't give a location, the forecast for your location is showed." \
            "!forecast \[location\]" \
            "!forecast Saarijärvi" 1 "pub" "weather"

proc showforecast { nick host hand chan arg } {
    if { [hasaccess $nick "forecast"] } {
        set arg [getargs $arg 1]

        set location ""
        if { [llength $arg] > 0 } {
            set location [string tolower [lindex $arg 0]]
        } else {
            set location [get_default_location $nick]
        }

        if { $location != "" } {
            set cleanloc $location
            set location [string map {å a ä a ö o \  %20} $location]
            set html [get_weather_html $location]

            if { [llength $html] > 0} {
                set html [join $html]
                set tomorrow [clock format [expr [clock seconds] + 86400] -format "%A"]

                set daystatus ""
                set high ""
                set low ""
                set nightstatus ""
                set place ""

                regsub -all -- {\s+} $html { } html
                regexp -nocase -- "<b>${tomorrow}</b><br /> \(\[a-z\\s\]*\)\\.? High: \(\[0-9\\.-\]+\)&deg; C\\. </td>" $html all daystatus high
                regexp -nocase -- "<b>${tomorrow} night</b><br /> \(\[a-z\\s\]*\)\\.? Low: \(\[0-9\\.-\]+\)&deg; C\\. </td>" $html all nightstatus low
                regexp -nocase -- {Observed at\s*<b>([^<]*)</b>} $html all place

                if { $daystatus != "" && $high != "" && $nightstatus != "" && $low != ""} {
                    if { $place == "" } {
                        set place $cleanloc
                    }
                    set daystatus [capitalize $daystatus]

                    luvmsg $chan "forecast" "Forecast for \2${place}\2 on ${tomorrow}: $daystatus with a high of ${high}°C and in the evening [string tolower $nightstatus] with a low of ${low}°C."
                } else {
                    luvmsg $chan "forecast" "Forecast for $cleanloc not found or parsed incorrectly"
                    putlog "Weather module error: One or more of : $daystatus : $high : $nightstatus : $low : is empty"
                }
            } else {
                luvmsg $chan "forecast" "No forecast found (HTML was empty)"
            }
        } else {
            luvnotc $nick "forecast" "syntax: [gethelpsyntax forecast]"
        }
    }
}

proc showweather { nick host hand chan arg } {
    if { [hasaccess $nick "weather"] } {
        set arg [getargs $arg 1]

        set location ""
        if { [llength $arg] > 0 } {
            set location [string tolower [lindex $arg 0]]
        } else {
            set location [get_default_location $nick]
        }

        if { $location != "" } {
            set cleanloc $location
            set location [string map {å a ä a ö o \  %20} $location]
            set html [get_weather_html $location]

            if { [llength $html] > 0} {
                set html [join $html]

                set place ""
                set sunrise ""
                set sunset ""
                set date ""
                set thetime ""
                set ampm ""
                set temperature ""
                set humidity ""
                set pressure ""
                set pressurestatus ""
                set humidity ""
                set winddirection ""
                set windspeed ""
                set windchill ""
                set conditions ""

                regexp -nocase -- {Updated: <b>([0-9:]+) (PM|AM) [A-Z]+ on ([A-Z0-9\ ,]+)</b>} $html all thetime ampm date
                regexp -nocase -- {Observed at\s*<b>([^<]*)</b>} $html all place
                regexp -nocase -- {<td>Temperature</td>\s*<td>\s*<span class=\"nowrap\"><b>[0-9\.-]+</b>&deg;F</span>\s*/\s*<span class=\"nowrap\"><b>([0-9\.-]+)</b>} $html all temperature
                regexp -nocase -- {<td>Humidity</td>\s*<td>\s*<b>([0-9\.%-]+)</b>} $html all humidity
                regexp -nocase -- {<td>Wind</td>\s*<td>\s*<b>([A-Z]+)</b> at\s*<span class=\"nowrap\"><b>[0-9\.]+</b>&nbsp;mph</span>\s*/\s*<span class=\"nowrap\"><b>([0-9\.]+)</b>} $html all winddirection windspeed
                regexp -nocase -- {<td>Pressure</td>\s*<td>\s*<span class=\"nowrap\"><b>[0-9\.]+</b>&nbsp;in</span>\s*/\s*<span class=\"nowrap\"><b>([0-9\.]+)</b>&nbsp;hPa</span>\s*<b>\(([A-Z]+)\)</b>} $html all pressure pressurestatus
                regexp -nocase -- {<td>Conditions</td>\s*<td><b>([A-Za-z\ ]+)</b></td>} $html all conditions
                regexp -nocase -- {<td>Sunrise</td><td><b>([0-9]+:[0-9]+ (?:A|P)M)[^<]*</b>} $html all sunrise
                regexp -nocase -- {<td>Sunset</td><td><b>([0-9]+:[0-9]+ (?:A|P)M)[^<]*</b>} $html all sunset
                #needs work if reinstated
                #regexp -nocase -- {<td>Windchill</td>\s*<td>\s*<span class=\"nowrap\"><b>([0-9\.-]+)</b>} $html all windchill

                if { $place == "" || $temperature == "" || $date == ""} {
                    putlog "Weather module error: One or more of : $place : $temperature : $date : is empty"
                    luvmsg $chan "weather" "Weather for $cleanloc not found or parsed incorrectly"
                } else {
                    set thetimehour 0
                    set thetimeminute 0
                    regexp -nocase -- {([0-9]+):([0-9]+)} $thetime all thetimehour thetimeminute
                    if { $thetimehour == 12 } {
                        if { [string tolower $ampm] == "am" } {
                        }
                    } elseif { [string tolower $ampm] == "pm" } {
                        set thetimehour [expr $thetimehour + 12]
                    } elseif { $thetimehour < 10 } {
                        set thetimehour "0${thetimehour}"
                    }

                    set thetime "${thetimehour}:${thetimeminute}"

                    luvmsg $chan "weather" "Weather conditions at \2$place\2 on $date $thetime:"

                    if { $conditions != "" } {
                        set outstring "${conditions}, "
                    } else {
                        set outstring ""
                    }

                    if { $windchill != "" } {
                        append outstring "${temperature}°C (windchill: ${windchill}°C)"
                    } else {
                        append outstring "${temperature}°C"
                    }
                    if { $humidity != "" } {
                        append outstring ", a humidity of ${humidity}"
                    }
                    if { $windspeed != "" } {
                        #convert to m/s instead of km/h.
                        set windspeed [expr round((double($windspeed) * 1000.0) / 3600.0)]
                        if { $winddirection == "South" || $winddirection == "North" || $winddirection == "East" || $winddirection == "West" } {
                            set winddirection "the [string tolower $winddirection]"
                        }
                        append outstring ", a ${windspeed}m/s wind from $winddirection"
                    }
                    if { $pressure != "" } {
                        append outstring " and a pressure of ${pressure}hPa ($pressurestatus)"
                    }
                    append outstring ". "

                    if { $sunrise != "" && $sunset != "" } {
                        set sunrise [translatetime $sunrise]
                        set sunset [translatetime $sunset]
                        if { $sunrise != "" && $sunset != "" } {
                            append outstring "The sun rises at $sunrise and sets $sunset. "

                            set daylen [daylength $sunrise $sunset]
                            append outstring "The day length is $daylen."
                        }
                    }
                    luvmsg $chan "weather" "$outstring"
                }
            } else {
                luvmsg $chan "weather" "No weather found (HTML was empty)"
            }
        } else {
            luvnotc $nick "weather" "syntax: [gethelpsyntax weather]"
        }
    }
}

proc daylength { sunrise sunset } {
    set riseh ""
    set risem ""
    set seth ""
    set setm ""

    regexp -- {0?([0-9]+?):0?([0-9]+?)} $sunrise all riseh risem
    regexp -- {0?([0-9]+?):0?([0-9]+?)} $sunset all seth setm

    if { $riseh != "" && $risem != "" && $seth != "" && $setm != "" } {
        set lenh [expr $seth - $riseh]
        set lenm [expr $setm - $risem]
        if { $lenm < 0 } {
            set lenm [expr $lenm + 60]
            set lenh [expr $lenh - 1]
        }
        return "${lenh}h ${lenm}min"
    } else {
        return ""
    }
}

proc translatetime { ampm } {
    if { [regexp -- {([0-9]+):([0-9]+) (AM|PM)} $ampm all hours minutes modifier] } {
        if { $hours == 12 } {
            if { $modifier == "AM" } {
                $hours = "0"
            }
        } elseif { $modifier == "PM" } {
            set hours [expr $hours + 12]
        }
        if { $hours < 10 } {
            set hours "0${hours}"
        }
        return ${hours}:${minutes}
    } else {
        return ""
    }
}

proc get_weather_html { location } {
    global baseurl_weather basepath_weather
    set html [gethtml ${baseurl_weather}${basepath_weather}${location}]
    if { [regexp -nocase -- {<th>Place: Temperature</th></tr>\s*<tr[^>]*>\s*<td\s*>\s*<a href=\"([^\"]*)\">[^<]*</a>} [join $html] all url] } {
        if { [string first " usa" $location] == -1 && [regexp -nocase -- {<td>\s*<a href=\"(/auto/mobile_metric/global/stations/[0-9]+.html)\">} [join $html] all globalurl] } {
            #we favor non-US cities if such a city exists.
            return [gethtml ${baseurl_weather}${globalurl}]
        }
        return [gethtml ${baseurl_weather}${url}]
    } else {
        return $html
    }
}

proc get_default_location { nick } {
    set db [getdb]

    set location [mysqlsel $db "select place from members where name collate utf8_bin like '[translateirc $nick $db]' limit 1" -flatlist]

    return [lindex $location 0]
}
