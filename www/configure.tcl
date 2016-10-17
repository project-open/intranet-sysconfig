# /packages/intranet-sysconfig/www/configure.tcl
#
# Copyright (c) 2003-2006 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

# ---------------------------------------------------------------
# Page Contract
# ---------------------------------------------------------------

ad_page_contract {
    Configures the system according to Wizard variables.
    
    @author frank.bergmann@project-open.com
} {
    { sector "default" }
    { deptcomp "" }
    { features "default" }
    { orgsize "" }
    { prodtest "test" }
    { name "Tigerpond" }
    { name_name "Tigerpond, Inc." }
    { name_email "sysadmin@tigerpond.com" }
    { logo_file "" }
    { logo_url "http://www.project-open.com" }
    profiles_array:array,optional
}

global tcl_platform
set platform [lindex $tcl_platform(platform) 0]

# Default value if profiles_array wasn't specified in a default call
if {![info exists profiles_array]} {
    array set profiles_array {employees,all_projects on project_managers,all_projects on project_managers,all_companies on}
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
# Enabling everything
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Resetting System to Default</h2>\n"

ns_write "<li>Enabling menus ... "
catch {db_dml enable_menus "update im_menus set enabled_p = 't'"}  err
ns_write "done<br><pre>$err</pre>\n"

ns_write "<li>Enabling categories ... "
catch {db_dml enable_categories "update im_categories set enabled_p = 't'"}  err
ns_write "done<br><pre>$err</pre>\n"

ns_write "<li>Enabling portlets ... "
catch {db_dml enable_components "update im_component_plugins set enabled_p = 't'"}  err
ns_write "done<br><pre>$err</pre>\n"

ns_write "<li>Enabling projects ... "
catch {db_dml enable_projects "update im_projects set project_status_id = [im_project_status_open] where project_status_id = [im_project_status_deleted]"}  err
ns_write "done<br><pre>$err</pre>\n"


# ---------------------------------------------------------------
# Set Name, Email, Logo
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Setting Name='$name_name', Email='$name_email', Logo</h2>\n";

ns_write "<li>setting name ... "
catch {db_dml set_name "update im_companies set company_name = :name_name where company_path='internal' "} err
ns_write "done<br><pre>$err</pre>\n"

ns_write "<li>setting email ... "
parameter::set_from_package_key -package_key "acs-kernel" -parameter "HostAdministrator" -value $name_email
parameter::set_from_package_key -package_key "acs-kernel" -parameter "OutgoingSender" -value $name_email
parameter::set_from_package_key -package_key "acs-kernel" -parameter "AdminOwner" -value $name_email
parameter::set_from_package_key -package_key "acs-kernel" -parameter "SystemOwner" -value $name_email
parameter::set_from_package_key -package_key "acs-mail-lite" -parameter "NotificationSender" -value $name_email
parameter::set_from_package_key -package_key "acs-subsite" -parameter "NewRegistrationEmailAddress" -value $name_email
ns_write "done<br>\n"

ns_write "<li>setting url ... "
parameter::set_from_package_key -package_key "acs-kernel" -parameter "SystemURL" -value "http://[ad_host]:[ad_port]/" 
ns_write "done<br>\n"

if {$logo_file ne ""} {
    ns_write "<li>setting logo... "
    set logo_path logo[file extension $logo_file]
    catch {
	file rename -force [acs_root_dir]/www/sysconf-logo.tmp [acs_root_dir]/www/$logo_path
	parameter::set_from_package_key -package_key "intranet-core" -parameter "SystemLogo" -value "/$logo_path"
	parameter::set_from_package_key -package_key "intranet-core" -parameter "SystemLogoLink" -value $logo_url
	parameter::set_from_package_key -package_key "intranet-core" -parameter "SystemCSS" -value ""
    } err_msg
    ns_write "done<br>\n"
}



# ---------------------------------------------------------------
# Check if the AOLDIR environment variable is set to something
# different from C:\project-open for Windows
# ---------------------------------------------------------------

set aoldir_exists_p [env exists aoldir]
if {"windows" == $platform && $aoldir_exists_p} {
    # Something like D:\project-open\blabla
    set aoldir [string tolower [env get aoldir]]
    # Replace backslash by forward slash
    regsub -all {\\} $aoldir "/" aoldir
    # Split by forward slash
    set aoldir_pieces [split $aoldir "/"]
    set aoldir_len [llength $aoldir_pieces]
    # Extract only the first path
    set aoldir [join [lrange $aoldir_pieces 0 1] "/"]
    # Now it's D:/project-open (without trailing slash)

    if {$aoldir_len >= 2} {
        ns_write "<li>setting pathes ... "
        parameter::set_from_package_key -package_key "acs-workflow" -parameter "graphviz_dot_path" -value "$aoldir/bin/dot.bat"
        parameter::set_from_package_key -package_key "intranet-core" -parameter "BackupBasePathUnix" -value "$aoldir/servers/projop/filestorage/backup"
        parameter::set_from_package_key -package_key "intranet-invoices" -parameter "InvoiceTemplatePathUnix" -value "$aoldir/servers/projop/filestorage/templates"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "BackupBasePathUnix" -value "$aoldir/servers/projop/filestorage/backup"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "BugBasePathUnix" -value "$aoldir/servers/projop/filestorage/bugs"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "CompanyBasePathUnix" -value "$aoldir/servers/projop/filestorage/projects"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "HomeBasePathUnix" -value "$aoldir/servers/projop/filestorage/home"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "ProjectBasePathUnix" -value "$aoldir/servers/projop/filestorage/projects"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "TicketBasePathUnix" -value "$aoldir/servers/projop/filestorage/tickets"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "ProjectSalesBasePathUnix" -value "$aoldir/servers/projop/filestorage/project_sales"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "UserBasePathUnix" -value "$aoldir/servers/projop/filestorage/users"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "CostBasePathUnix" -value "$aoldir/servers/projop/filestorage/costs"
        parameter::set_from_package_key -package_key "intranet-filestorage" -parameter "TmpPathUnix" -value "$aoldir/tmp"
        ns_write "done<br>\n"
    }
}


# ---------------------------------------------------------------
# Profile Configuration
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Configuring Trust Model</h2>\n";

set subsite_id [ad_conn subsite_id]

array set group_ids [list \
		     employees        [db_string emp "select group_id from groups where group_name = 'Employees'"] \
		     project_managers [db_string emp "select group_id from groups where group_name = 'Project Managers'"] \
		     senior_managers  [db_string emp "select group_id from groups where group_name = 'Senior Managers'"] \
]

foreach i [array names group_ids] {
    ns_write "<li>"
    ns_write [lang::message::lookup "" "intranet-sysconfig.profiles_$i" $i] 

    set party_id $group_ids($i)

    if {[info exists profiles_array($i,all_companies)] || $i=="senior_managers"} {
	if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, 'edit_companies_all')" } err]} { ns_write $err }
	if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, 'view_companies_all')" } err]} { ns_write $err }
    }	  

    if {[info exists profiles_array($i,all_projects)] || $i=="senior_managers"} {
	if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, 'edit_projects_all')" } err]} { ns_write $err }
	if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, 'view_projects_all')" } err]} { ns_write $err }
	if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, 'view_timesheet_tasks_all')" } err]} {	ns_write $err }
	
    }
    if {[info exists profiles_array($i,finance)] || $i=="senior_managers"} {
	foreach j [list add_budget add_budget_hours add_costs add_finance add_invoices add_payments fi_read_all fi_write_all view_costs view_expenses_all view_finance view_hours_all view_invoices view_payments] {
	    if {[catch { db_string setting_profiles "select acs_permission__grant_permission(:subsite_id, :party_id, :j)" } err]} {	    ns_write $err }
	}
    }
    ns_write "...done<br>\n"
}

# ---------------------------------------------------------------
# Sector Configuration
# ---------------------------------------------------------------

switch $sector {
    biz_consulting - advertizing - engineering {
	set install_consulting_p 1
	set install_translation_p 0
	set install_itsm_p 0
    }
    it_consulting {
	set install_consulting_p 1
	set install_translation_p 0
	set install_itsm_p 1
    }
    translation {
	set install_consulting_p 0
	set install_translation_p 1
	set install_itsm_p 0
    }
    default {
	set install_consulting_p 1
	set install_translation_p 1
	set install_itsm_p 1
    }
}

# ---------------------------------------------------------------
# Disable Consulting Stuff

if {!$install_consulting_p} {
    ns_write "<br>&nbsp;<h2>Disabling 'Consulting' Portlets</h2>"

    # ToDo
    ns_write "<li>Disabling 'Consulting' Categories ... "
    set project_type_gantt_id [db_string t "select category_id from im_categories where category = 'Gantt Project'"]
    catch {db_dml disable_trans_cats "
	update im_categories 
	set enabled_p = 'f'
	where category_id in ([join [im_sub_categories -include_disabled_p 1 $project_type_gantt_id] ","])
    "}  err
    ns_write "done<br><pre>$err</pre>\n"
  
    ns_write "<li>Disabling 'Consulting' Projects ... "
    catch {db_dml disable_trans_cats "
	update im_projects
	set project_status_id = [im_project_status_deleted]
	where project_type_id in ([join [im_sub_categories -include_disabled_p 1 $project_type_gantt_id] ","])
    "}  err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'Consulting' Menus ... "
    catch {db_dml disable_trans_cats "
	update im_menus
	set enabled_p = 'f'
	where menu_id in (
		select menu_id from im_menus where lower(name) like '%timesheet task%'
	UNION	select menu_id from im_menus where lower(name) like '%wiki%%'
	)
    "}  err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'Consulting' Portlets ... "
    catch {db_dml disable_trans_cats "
	update im_component_plugins
	set enabled_p = 'f'
	where plugin_id in (
		select plugin_id from im_component_plugins where package_name in (
			'timesheet2-invoices', 'intranet-timesheet2-tasks',
			'intranet-ganttproject', 'intranet-wiki'
		)
	)
    "}  err
    ns_write "done<br><pre>$err</pre>\n"
}



# ---------------------------------------------------------------
# Disable Translation Stuff

if {!$install_translation_p} {
    ns_write "<br>&nbsp;<h2>Disabling 'Translation' Portlets</h2>\n"

    ns_write "<li>Disabling 'Translation' Categories ... "
    set project_type_translation_id [db_string t "select category_id from im_categories where category = 'Translation Project'" -default 0]
    catch {db_dml disable_trans_cats "
	update im_categories 
	set enabled_p = 'f'
	where category_id in ([join [im_sub_categories -include_disabled_p 1 $project_type_translation_id] ","])
    "}  err
    ns_write "done<br><pre>$err</pre>\n"


    ns_write "<li>Disabling 'Translation' Projects ... "
    catch {db_dml disable_trans_cats "
	update im_projects
	set project_status_id = [im_project_status_deleted]
	where project_type_id in ([join [im_sub_categories -include_disabled_p 1 $project_type_translation_id] ","])
    "}  err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'Translation' Menus ... "
    catch {db_dml disable_trans_cats "
	update im_menus
	set enabled_p = 'f'
	where menu_id in (
		select menu_id from im_menus where label like '%_trans_%'
	UNION	select menu_id from im_menus where lower(name) like '%trans%'
	)
    "}  err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'Translation' Portlets ... "
    catch {db_dml disable_trans_cats "
	update im_component_plugins
	set enabled_p = 'f'
	where plugin_id in (
		select plugin_id from im_component_plugins where package_name like '%trans%'
	)
    "}  err
    ns_write "done<br><pre>$err</pre>\n"
}




# ---------------------------------------------------------------
# Disable ITSM Stuff

if {!$install_itsm_p} {

    ns_write "<br>&nbsp;<h2>Disabling 'ITSM' Portlets</h2>\n"
    ns_write "<li>Disabling 'ITSM' Categories ... "
    catch {
	db_dml disable_itsm_cats "
		update im_categories 
		set enabled_p = 'f'
		where category_id in (
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_sla]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_software_release]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_software_release_item]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_bt_container]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_bt_task]] ","]
		)
        "
    } err
    ns_write "done<br><pre>$err</pre>\n"


    ns_write "<li>Disabling 'ITSM' Projects ... "
    catch {db_dml disable_itsm_cats "
	update im_projects
	set project_status_id = [im_project_status_deleted]
	where project_type_id in (
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_sla]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_software_release]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_software_release_item]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_bt_container]] ","],
			[join [im_sub_categories -include_disabled_p 1 [im_project_type_bt_task]] ","]
	)
    "} err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'ITSM' Menus ... "
    catch {db_dml disable_itsm_cats "
	update im_menus
	set enabled_p = 'f'
	where menu_id in (
		select menu_id from im_menus where label like '%_itsm_%'
	UNION	select menu_id from im_menus where lower(name) like '%itsm%'
	UNION	select menu_id from im_menus where label = 'helpdesk'
	UNION	select menu_id from im_menus where label = 'conf_items'
	)
    "} err
    ns_write "done<br><pre>$err</pre>\n"

    ns_write "<li>Disabling 'ITSM' Portlets ... "
    catch {db_dml disable_itsm_cats "
	update im_component_plugins
	set enabled_p = 'f'
	where plugin_id in (
		select plugin_id from im_component_plugins where package_name like '%itsm%'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-helpdesk'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-confdb'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-bug-tracker'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-big-brother'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-nagios'
	UNION	select plugin_id from im_component_plugins where package_name = 'intranet-release-mgmt'
	)
    "} err
    ns_write "done<br><pre>$err</pre>\n"
}



# ---------------------------------------------------------------
# Feature Simplifications
#
# Disable these features _in_addition_ to the simplifications
# above for business sectors.
# ---------------------------------------------------------------

set disable(intranet-bug-tracker) 0
set disable(intranet-chat) 0
set disable(intranet-big-brother) 0
set disable(intranet-expenses) 0
set disable(intranet-filestorage) 0
set disable(intranet-forum) 0
set disable(intranet-freelance) 0
set disable(intranet-freelance-invoices) 0
set disable(intranet-ganttproject) 0
set disable(intranet-search-pg) 0
set disable(intranet-search-pg-files) 0
set disable(intranet-simple_survey) 0
set disable(intranet-sysconfig) 0
set disable(intranet-timesheet2) 0
set disable(intranet-timesheet2-invoices) 0
set disable(intranet-timesheet2-tasks) 0
set disable(intranet-timesheet2-task-popup) 1
set disable(intranet-translation) 0
set disable(intranet-trans-rfq) 0
set disable(intranet-trans-quality) 0
set disable(intranet-wiki) 0
set disable(intranet-workflow) 0
set disable(intranet-milestone) 0
set disable(intranet-audit) 0
set disable(intranet-freelance) 0
set disable(intranet-freelance-invoices) 0
set disable(intranet-freelance-rfqs) 0
set disable(intranet-freelance-translation) 0
set disable(intranet-simple-survey) 0
set disable(intranet-notes) 0
set disable(intranet-calendar) 0


switch $features {
    minimum {
	set disable(intranet-bug-tracker) 1
	set disable(intranet-chat) 1
	set disable(intranet-big-brother) 1
	set disable(intranet-expenses) 1
	set disable(intranet-forum) 1
	set disable(intranet-filestorage) 1
	set disable(intranet-freelance) 1
	set disable(intranet-freelance-invoices) 1
	set disable(intranet-ganttproject) 1
	set disable(intranet-simple_survey) 1
	set disable(intranet-timesheet2) 1
	set disable(intranet-timesheet2-invoices) 1
	set disable(intranet-timesheet2-tasks) 1
	set disable(intranet-timesheet2-task-popup) 1
	set disable(intranet-trans-rfq) 1
	set disable(intranet-trans-quality) 1
	set disable(intranet-wiki) 1
	set disable(intranet-workflow) 1
	set disable(intranet-milestone) 1
	set disable(intranet-milestone) 1
	set disable(intranet-audit) 1
	set disable(intranet-freelance) 1
	set disable(intranet-freelance-invoices) 1
	set disable(intranet-freelance-rfqs) 1
	set disable(intranet-freelance-translation) 1
	set disable(intranet-simple-survey) 1
	set disable(intranet-notes) 1
	set disable(intranet-calendar) 1

        db_dml fincomp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Project Finance Summary Component'"
	
	parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableCloneProjectLinkP" -value "0"
	parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableExecutionProjectLinkP" -value "0"
	parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableNestedProjectsP" -value "0"
	parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableNewFromTemplateLinkP" -value "0"
    }
    frequently_used {
	set disable(intranet-bug-tracker) 1
	set disable(intranet-chat) 1
	set disable(intranet-big-brother) 1
	set disable(intranet-forum) 1
	set disable(intranet-ganttproject) 1
	set disable(intranet-simple_survey) 1
	set disable(intranet-trans-rfq) 1
	set disable(intranet-wiki) 1
    }
    default { 
	set disable(intranet-big-brother) 1
    }
}



# ---------------------------------------------------------------
# Disable Modules

foreach package [array names disable] {
    
    set dis $disable($package)
    if {$dis} {
	ns_write "<br>&nbsp;<h2>Disabling '$package'</h2>\n"
	
	ns_write "<li>Disabling '$package' Menus ... "
	catch {db_dml disable_trans_cats "
		update	im_menus
		set	enabled_p = 'f'
		where	package_name = :package
        "} err
	ns_write "done<br><pre>$err</pre>\n"

	ns_write "<li>Disabling '$package' Portlets ... "
	catch {db_dml disable_trans_cats "
		update	im_component_plugins
		set	enabled_p = 'f'
		where	package_name = :package
        "} err
	ns_write "done<br><pre>$err</pre>\n"
    }
}


# ---------------------------------------------------------------
# Disabling portlets
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Disabling Portlets</h2>\n"
ns_write "<li>Disabling 'intranet-sysconfig' Portlets ... "
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = 'System Configuration Wizard'"


ns_write "<li>Disabling Home Gantt Tasks Portlets ... "
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Gantt Tasks'"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Page Help Blurb'"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Calendar Component'"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"




# ---------------------------------------------------------------
# Set the ASUS verbosity level to "-1" = User needs to choose.
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Reseting ASUS Verbosity Level</h2>\n"
ns_write "<li>Resetting ASUS Verbosity ... "

set verbosity -1
set package_key "intranet-security-update-client"
set package_id [db_string package_id "select package_id from apm_packages where package_key=:package_key" -default 0]

parameter::set_value \
        -package_id $package_id \
        -parameter "SecurityUpdateVerboseP" \
        -value $verbosity

ns_write "done<br><pre>$err</pre>\n"

# ---------------------------------------------------------------
# Disable the 100 - Task category
# This disable is overwritten by the enable all above
# ---------------------------------------------------------------

db_dml disable_task_project_type "update im_categories set enabled_p = 'f' where category_id = 100"




# ---------------------------------------------------------------
# Delete Security Tokens
# ---------------------------------------------------------------


# Update the security tokensof the local server
# Users might be a way to gain access if the tokens are
# publicly known (from the default installation)

ns_write "<br>&nbsp;<h2>Deleting Security Tokens</h2>\n"
ns_write "<li>Deleting tokens...\n"

db_dml del_sec_tokens "delete from secret_tokens"
db_string reset_sect_token_seq "SELECT pg_catalog.setval('t_sec_security_token_id_seq', 1, true)"
ns_write "done\n"

ns_write "<li>Resetting SystemID...\n"
im_system_id -clear
ns_write "done\n"



# ---------------------------------------------------------------
# Finish off page
# ---------------------------------------------------------------


ns_write "<p>&nbsp;</p><hr><p>&nbsp;</p>\n"
ns_write "<h1>Configuration Successful</h1>\n"
ns_write "<blockquote><b>Please <a href='/acs-admin/server-restart'>restart your server now</a></b>.</blockquote>\n"
ns_write "<p>&nbsp;</p>\n"




# Remove all permission related entries in the system cache
util_memoize_flush_regexp ".*"
im_permission_flush


ns_write "[im_footer]\n"


