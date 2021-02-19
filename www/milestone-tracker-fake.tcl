# /packages/intranet-sysconfig/www/milestone-tracker-fake.tcl
#
# Copyright (c) 2003-2006 ]project-open[
#
# All rights reserved. Please check
# https://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Disables all components and menus and enables the SysConfig
    component on the "Home" page to prepare a users's configuration
    session
} {

}

# ---------------------------------------------------------------
# Output headers
# Allows us to write out progress info during the execution
# ---------------------------------------------------------------

set current_user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "<li>[_ intranet-core.lt_You_need_to_be_a_syst]"
    return
}


set content_type "text/html"
set http_encoding "iso8859-1"
append content_type "; charset=$http_encoding"
set all_the_headers "HTTP/1.0 200 OK
MIME-Version: 1.0
Content-Type: $content_type\r\n"
util_WriteWithExtraOutputHeaders $all_the_headers
ReturnHeaders $content_type
ns_write "[im_header] [im_navbar]"


# ---------------------------------------------------------------
# Create history for the Milestone Slip Tracker
# ---------------------------------------------------------------

ns_write "<h2>Fake Milestone Slip Tracker History</h2>\n"

set main_ps [db_list main_ps "
	select	project_id
	from	im_projects p
	where	parent_id is null and 
		-- project_status_id in (select * from im_sub_categories([im_project_status_open])) and 
		project_type_id in (select * from im_sub_categories([im_project_type_gantt]))
	order by project_id
"]

db_dml loosen_last_audit_ids "update im_audits set audit_last_id = null"
db_dml loosen_last_audit_ids_objects "update acs_objects set last_audit_id = null where last_audit_id is not null"

foreach pid $main_ps {

    ns_write "<li>Project info for project #$pid</li>\n"
    ns_log Notice "milestone-tracker-fake: project_id=$pid"
    db_1row project_info "
	select	start_date::date as project_start_date,
		end_date::date as project_end_date,
		end_date::date - start_date::date as project_duration_days
	from	im_projects
	where	project_id = :pid
    "

    ns_write "<li>Deleting audit history of project #$pid</li>\n"
    db_dml del_trail "
	delete from im_audits where audit_id in (
		select	audit_id from im_audits
		where	audit_object_id in (
				select	p.project_id
				from	im_projects p,
					im_projects main_p
				where	p.tree_sortkey between main_p.tree_sortkey and tree_right(main_p.tree_sortkey) and 
					p.parent_id = main_p.project_id and	   -- only 2nd level projects are tracked...
					main_p.project_id = :pid
			)
	)
    "

    # Get the list of project phases, together with their start- and end-date
    set phases [db_list_of_lists phases "
	select phase.project_id,
	       phase.start_date::date,
	       phase.end_date::date
	from   im_projects phase
	where  phase.parent_id = :pid
    "]

    # All dates for writing audit logs
    set dates [db_list dates "select im_day_enumerator from im_day_enumerator(:project_start_date::date, least(:project_end_date::date, :project_end_date::date)) order by im_day_enumerator DESC"]
    if {[llength $dates] > 100} {
	set dates [db_list dates "select im_week_enumerator from im_week_enumerator(:project_start_date::date, least(:project_end_date::date, :project_end_date::date)) order by im_week_enumerator DESC"]
    }
    if {[llength $dates] > 100} {
	set dates [db_list dates "select im_month_enumerator from im_month_enumerator(:project_start_date::date, least(:project_end_date::date, :project_end_date::date)) order by im_month_enumerator DESC"]
    }

    # Select a few dates for "delaying" the project
    set rand_dates [list]
    for {set i 0} {$i < 5} {incr i} { lappend rand_dates [util::random_list_element $dates] }

    # Write information about project phases into hashes
    set phase_ids [list]
    foreach phase_tuple $phases {
	set phase_id [lindex $phase_tuple 0]
	set phase_start_date [lindex $phase_tuple 1]
	set phase_end_date [lindex $phase_tuple 2]

	lappend phase_ids $phase_id

	set phase_start_date_hash($phase_id) $phase_start_date
	set phase_end_date_hash($phase_id) $phase_end_date

	set phase_org_start_date_hash($phase_id) $phase_start_date
	set phase_org_end_date_hash($phase_id) $phase_end_date
    }
    # ad_return_complaint 1 "dates=$dates, phase_end_hash=[array get phase_end_date_hash]";  ad_script_abort

    # Write audit for $date
    foreach date $dates {
	foreach phase_tuple $phases {
	    set phase_id [lindex $phase_tuple 0]
	    set phase_start_date [lindex $phase_tuple 1]
	    set phase_end_date [lindex $phase_tuple 2]

	    ns_log Notice "milestone-tracker-fake: checking: phase_id=$phase_id, phase_start_date=$phase_start_date, date=$date, phase_end_date=$phase_end_date"
#	    if {$date < $phase_start_date} { continue }
#	    if {$date > $phase_end_date} { continue }
	    ns_log Notice "milestone-tracker-fake: writing: phase_id=$phase_id, phase_start_date=$phase_start_date, date=$date, phase_end_date=$phase_end_date"

	    db_dml up "update im_projects set start_date = '$phase_start_date_hash($phase_id)', end_date = '$phase_end_date_hash($phase_id)' where project_id = :phase_id"
	    set audit_id [im_audit -object_id $phase_id]
	    db_dml update_audit_date "
		update im_audits set 
			audit_date = :date
		where audit_id = :audit_id
	    "
	}

	if {$date in $rand_dates} {
	    set delay_days [expr round(10.0 * rand() * $project_duration_days * 0.1) / 10.0]
	    set delay_phase_id [util::random_list_element $phase_ids]
	    ns_log Notice "milestone-tracker-fake: delaying project: phase=$delay_phase_id, date=$date, delay_days=$delay_days"
	    
	    # fraber 2020-03-28: Not using the delay_phase_id at the moment
	    # Just delaying all phases

	    foreach pid [array names phase_start_date_hash] {
		set phase_start_date_hash($pid) [db_string delay "select '$phase_start_date_hash($pid)'::date - '$delay_days days'::interval"]
		set phase_end_date_hash($pid) [db_string delay "select '$phase_end_date_hash($pid)'::date - '$delay_days days'::interval"]
	    }
	}

    }

    # Restore original start- and end-dates
    foreach phase_tuple $phases {
	set phase_id [lindex $phase_tuple 0]
	db_dml up2 "update im_projects set start_date = '$phase_org_start_date_hash($phase_id)', end_date = '$phase_org_end_date_hash($phase_id)' where project_id = :phase_id"
    }   
}

# ---------------------------------------------------------------
# Finish off page
# ---------------------------------------------------------------

# Remove all permission related entries in the system cache
util_memoize_flush_regexp ".*"
im_permission_flush


ns_write "[im_footer]\n"


