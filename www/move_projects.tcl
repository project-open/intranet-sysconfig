# /packages/intranet-sysconfig/www/move_projects.tcl
#
# Copyright (c) 2003-2006 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Move projects
} {
    { offset:integer "" }
}

set current_user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "<li>[_ intranet-core.lt_You_need_to_be_a_syst]"
    return
}


# ---------------------------------------------------------------
# 
# ---------------------------------------------------------------

im_sysconfig_timeshift -offset $offset

