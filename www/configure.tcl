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


# ---------------------------------------------------------------
# Defaults & Security
# ---------------------------------------------------------------

set current_user_id [auth::require_login]
set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $current_user_id]
if {!$user_is_admin_p} {
    ad_return_complaint 1 "<li>[_ intranet-core.lt_You_need_to_be_a_syst]"
    return
}

# Default value if profiles_array wasn't specified in a default call
if {![info exists profiles_array]} {
    array set profiles_array {employees,all_projects on project_managers,all_projects on project_managers,all_companies on}
}

if {"other" eq $sector} { set sector "other_sector" }
if {"other" eq $deptcomp} { set deptcomp "other_deptcomp" }
if {"other" eq $features} { set features "maximum" }



# ---------------------------------------------------------------
# Output headers
# Allows us to write out progress info during the execution
# ---------------------------------------------------------------

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
ns_write "done<br><pre>$err</pre>"

ns_write "<li>Enabling categories ... "
catch {db_dml enable_categories "update im_categories set enabled_p = 't'"}  err
ns_write "done<br><pre>$err</pre>"

ns_write "<li>Enabling portlets ... "
catch {db_dml enable_components "update im_component_plugins set enabled_p = 't'"}  err
ns_write "done<br><pre>$err</pre>"

ns_write "<li>Enabling projects ... "
catch {db_dml enable_projects "update im_projects set project_status_id = [im_project_status_open] where project_status_id = [im_project_status_deleted]"}  err
ns_write "done<br><pre>$err</pre>"


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

ns_write "<li>setting SystemUrl ... "
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
# Default configuration
# Starts with everything enabled and then disables packages not 
# needed by certain business sectors or organization types.
# ---------------------------------------------------------------

set disable(intranet-agile) 0
set disable(intranet-audit) 0
set disable(intranet-baseline) 0
set disable(intranet-big-brother) 0
set disable(intranet-bug-tracker) 0
set disable(intranet-calendar) 0
set disable(intranet-chat) 0
set disable(intranet-checklist) 0
set disable(intranet-confdb) 0
set disable(intranet-core) 0
set disable(intranet-cost) 0
set disable(intranet-cost-center) 0
set disable(intranet-crm-opportunities) 0
set disable(intranet-csv-import) 0
set disable(intranet-cvs-integration) 0
set disable(intranet-department-planner) 0
set disable(intranet-dw-light) 0
set disable(intranet-dynfield) 0
set disable(intranet-earned-value-management) 0
set disable(intranet-estimate-to-complete) 0
set disable(intranet-exchange-rate) 0
set disable(intranet-expenses) 0
set disable(intranet-expenses-workflow) 0
set disable(intranet-filestorage) 0
set disable(intranet-forum) 0
set disable(intranet-gantt-editor) 0
set disable(intranet-ganttproject) 0
set disable(intranet-helpdesk) 0
set disable(intranet-hr) 0
set disable(intranet-idea-management) 0
set disable(intranet-invoices) 0
set disable(intranet-mail-import) 0
set disable(intranet-material) 0
set disable(intranet-milestone) 0
set disable(intranet-nagios) 0
set disable(intranet-notes) 0
set disable(intranet-payments) 0
set disable(intranet-planning) 0
set disable(intranet-portfolio-management) 0
set disable(intranet-portfolio-planner) 0
set disable(intranet-project-scoring) 0
set disable(intranet-release-mgmt) 0
set disable(intranet-reporting) 0
set disable(intranet-reporting-cubes) 0
set disable(intranet-reporting-dashboard) 0
set disable(intranet-reporting-finance) 0
set disable(intranet-reporting-indicators) 0
set disable(intranet-reporting-openoffice) 0
set disable(intranet-reporting-tutorial) 0
set disable(intranet-resource-management) 0
set disable(intranet-rest) 0
set disable(intranet-riskmanagement) 0
set disable(intranet-rule-engine) 0
set disable(intranet-scrum) 0
set disable(intranet-search-pg) 0
set disable(intranet-search-pg-files) 0
set disable(intranet-security-update-client) 0
set disable(intranet-sharepoint) 0
set disable(intranet-simple-survey) 0
set disable(intranet-sla-management) 0
set disable(intranet-slack) 0
set disable(intranet-soap-lite-server) 0
set disable(intranet-sql-selectors) 0
set disable(intranet-sysconfig) 0
set disable(intranet-task-management) 0
set disable(intranet-timesheet2) 0
set disable(intranet-timesheet2-invoices) 0
set disable(intranet-timesheet2-task-popup) 0
set disable(intranet-timesheet2-tasks) 0
set disable(intranet-timesheet2-workflow) 0
set disable(intranet-wiki) 0
set disable(intranet-workflow) 0
set disable(sencha-core) 0
set disable(sencha-filestorage) 0
set disable(sencha-member-portlet) 0
set disable(sencha-reporting-portfolio) 0
set disable(sencha-task-editor) 0
set disable(senchatouch-notes) 0
set disable(senchatouch-timesheet) 0


# ---------------------------------------------------------------
# Business Sector:
# A number of packages are specific to IT organizations:
# - Configuration Database
# - Release Management
# - Scrum and Agile PM
#
if {"it_consulting" ne $sector} {
    set disable(intranet-scrum) 1
    set disable(intranet-agile) 1
    set disable(intranet-big-brother) 1
    set disable(intranet-confdb) 1
    set disable(intranet-cvs-integration) 1
    set disable(intranet-helpdesk) 1
    set disable(intranet-nagios) 1
    set disable(intranet-icinga2) 1
    set disable(intranet-release-mgmt) 1
    set disable(intranet-scrum) 1
    set disable(intranet-sla-management) 1
}

# The other sectors are generic:
# 
# - biz_consulting
# - advertizing
# - engineering
# - other_sector


# ---------------------------------------------------------------
# Department or Company:
# - Departments don't need CRM
# - Companies don't need Portfolio Management
#

if {"dept" eq $deptcomp} {
    set disable(intranet-crm-opportunities) 1
}

if {"sme" eq $deptcomp} {
    # Portfolio Planner is useful also for companies:
    # set disable(intranet-portfolio-planner) 1
    set disable(intranet-portfolio-management) 1
    set disable(sencha-reporting-portfolio) 1

}

# Other organization types:
# We'll just enable everything.
# - subsidary
# - other_deptcomp



# ---------------------------------------------------------------
# Hierarchical Levels don't have any impact yet
# - one
# - two
# - three
# - four


# ---------------------------------------------------------------
# Features=minimum and =maximum
# ---------------------------------------------------------------

# Default
db_dml menu "update im_menus set url = '/intranet/projects/index' where label = 'projects'"

if {"minimum" eq $features} {
    # Disable all packages
    foreach pack [array names disable] { set disable($pack) 1  }

    # Work with Portfolio Planner instead of project list
    # Fraber 170503: not yet...
    # db_dml menu "update im_menus set url = '/intranet-portfolio-planner/index' where label = 'projects'"
    
    # Just enable the bare minimum
    set disable(intranet-core) 0
    set disable(intranet-gantt-editor) 0
    set disable(intranet-portfolio-planner) 0
    set disable(intranet-reporting) 0
    set disable(intranet-reporting-cubes) 0
    set disable(intranet-reporting-dashboard) 0
    set disable(intranet-reporting-finance) 0
    set disable(intranet-reporting-indicators) 0
    set disable(intranet-reporting-openoffice) 0
    set disable(intranet-search-pg) 0
    set disable(intranet-security-update-client) 0
    set disable(intranet-timesheet2) 0
    set disable(intranet-timesheet2-tasks) 0
    set disable(sencha-core) 0

    # Disable some portlets for bare minimum
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Project Finance Summary Component'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Gantt Tasks'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Indicator Component'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Page Project Component'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Last Projects'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'User Related Objects'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Page Help Blurb'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Home Calendar Component'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Project Finance Summary Component'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Vacation Balance'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Customers worked for'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'User Offices'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'User Notifications'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Project Hierarchy'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Project Timesheet Tasks'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'Top Customers'"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"
    db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = ''"

    # Set some parameters for minimum complexity
    parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableCloneProjectLinkP" -value "0"
    parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableExecutionProjectLinkP" -value "0"
    parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableNestedProjectsP" -value "0"
    parameter::set_from_package_key -package_key "intranet-core" -parameter "EnableNewFromTemplateLinkP" -value "0"
    # disable Timesheet workflow
    parameter::set_from_package_key -package_key "intranet-timesheet2-workflow" -parameter "DefaultWorkflowKey" -value ""

    # Disable some menus for bare minimum
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'timesheet2_absences'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'project_finance'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'openoffice_project_phases_risks_pptx'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'openoffice_project_phases_risks_odp'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'project_programs'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'programs_list'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'projects_profit_loss'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-finance%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-budget%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-program%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-ticket%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-confdb%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-csv%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-survimp%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting_survsimp%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label like 'reporting-tutorial%'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'reporting-sales'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'reporting-forum'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'indicators'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = 'dashboard'"
    db_dml menu "update im_menus set enabled_p = 'f' where label = ''"
    db_dml menu "update im_menus set enabled_p = 'f' where label = ''"
    db_dml menu "update im_menus set enabled_p = 'f' where label = ''"
    db_dml menu "update im_menus set enabled_p = 'f' where label = ''"
    db_dml menu "update im_menus set enabled_p = 'f' where label = ''"

}

if {"maximum" eq $features} {
    # Enable all packages
    foreach pack [array names disable] { set disable($pack) 0  }

    # Enable all categories
    db_dml enable_all_categories "update im_categories set enabled_p = 't'"

    # Enable all menus
    db_dml enable_all_menus "update im_menus set enabled_p = 't'"

    # Enable all portlets
    db_dml enable_all_portlets "update im_component_plugins set enabled_p = 't'"
}



# ---------------------------------------------------------
# Disable the following menus and plugins for all configurations
#
db_dml disable_menus "
	update im_menus set enabled_p = 'f' where label in (
		'home_summary','projects_open','resource_management_home','expenses_dashboard',
		'dashboard','customers_potential','customers_inactive','customers_active',
		'projects_potential','projects_closed', 'project_gantt', 'project_resources'
	)
"

db_dml disable_plugins "
	update im_component_plugins set enabled_p = 'f' where plugin_name in (
		'Home Gantt Tasks', 			-- replaced by intranet-task-management portlet
		'Home Page Help Blurb',			-- replaced by interactive configuration wizard
		'Project Finance Summary Component',	-- details shown in finance tab
		'System Configuration Wizard',		-- _this_ wizard. Not necessary anymore after config.
		'Home Calendar Component'		-- rarely used
	)
"


# ---------------------------------------------------------------
# Disable ITSM Stuff
#
if {$disable(intranet-helpdesk)} {

    ns_write "<li>Disabling Helpdesk Categories ... "
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

    ns_write "<li>Disabling Helpdesk Demo Projects ... "
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
}






# ---------------------------------------------------------------
# Disable Packages
#
foreach package [lsort [array names disable]] {
    set dis $disable($package)
    if {$dis} {
	ns_write "<br>&nbsp;<h2>Disabling '$package'</h2>\n"
	
	ns_write "<li>Disabling '$package' Menus ... "
	catch {db_dml disable_menus "
		update	im_menus
		set	enabled_p = 'f'
		where	package_name = :package
        "} err
	ns_write "done<br><pre>$err</pre>\n"

	ns_write "<li>Disabling '$package' Portlets ... "
	catch {db_dml disable_plugins "
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

ns_write "<br>&nbsp;<h2>Disabling SysConfig Portlets</h2>\n"
ns_write "<li>Disabling 'intranet-sysconfig' Portlets ... "
db_dml dis "update im_component_plugins set enabled_p = 'f' where plugin_name = 'System Configuration Wizard'"




# ---------------------------------------------------------------
# Generic fixes for disabled stuff etc.
#
# Don't show skins, while there is only one!
db_dml comp "update im_component_plugins set enabled_p = 'f' where plugin_name = 'User Skin Information'"




# ---------------------------------------------------------------
# Set the ASUS verbosity level to "-1" = User needs to choose.
# ---------------------------------------------------------------

ns_write "<br>&nbsp;<h2>Reseting ASUS Verbosity Level</h2>\n"
ns_write "<li>Resetting ASUS Verbosity ... "

set err ""
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

db_dml disable_task_project_type "update im_categories set enabled_p = 'f' where category_id = [im_project_type_task]"


# ---------------------------------------------------------------
# Delete Security Tokens
# ---------------------------------------------------------------

# Update the security tokens of the local server
# Users can gain access if the tokens are publicly known 
# (from the default installation)

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
