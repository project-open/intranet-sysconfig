# /packages/intranet-sysconfig/www/sector/sector.tcl
#
# Copyright (c) 2003-2006 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    
} {

}


# ---------------------------------------------------------------
# Frequently used variables
# ---------------------------------------------------------------

set current_user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "<li>[_ intranet-core.lt_You_need_to_be_a_syst]"
    return
}

set bg ""
set po "<span class=brandsec>&\#93;</span><span class=brandfirst>project-open</span><span class=brandsec>&\#91;</span>"
set po_short "<span class=brandsec>&\#93;</span><span class=brandfirst>po</span><span class=brandsec>&\#91;</span>"

#set w 175; set h 148; set fh 16; # 100%, original GIF size, too large
#set w 105; set h 87; # 60%, a bit to small
set w 140; set h 118; # 80%

set base [expr round($w / 2.0)]; # Base of triangle, half of width = 88
set hyp [expr round(sqrt($base*$base - $base*$base/4))]; # Hypotonuse of base triangle = 76

set x0 0
set x1 [expr $base*1.5 + 4]
set x2 [expr $base*3 + 8]

set y0 0
set y1 $hyp
set y2 [expr $hyp*2.0]
set y3 [expr $hyp*3.0]
set y4 [expr $hyp*4.0]


set bg100 "/intranet-sysconfig/images/hexagon-100.png"
