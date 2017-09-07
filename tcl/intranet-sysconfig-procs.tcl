# /packages/intranet-sysconfig/tcl/intranet-sysconfig-procs.tcl
#
# Copyright (c) 2006 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_library {
    SysConfig Configuration Wizard
    @author frank.bergmann@project-open.com
    @author klaus.hofeditz@project-open.com
}

# ----------------------------------------------------------------------
# 
# ----------------------------------------------------------------------

ad_proc -public im_package_sysconfig_id {} {
    Returns the package id of the intranet-sysconfig module
} {
    return [util_memoize [list im_package_sysconfig_id_helper]]
}

ad_proc -private im_package_sysconfig_id_helper {} {
    return [db_string im_package_core_id {
        select package_id from apm_packages
        where package_key = 'intranet-sysconfig'
    } -default 0]
}


# ----------------------------------------------------------------------
# 
# ----------------------------------------------------------------------

ad_proc -public im_sysconfig_component { } {
    Returns a formatted HTML block as the very first page
    of a freshly installed V3.2 and higher system, allowing
    the user to configure the system
} {
    set bg ""
    set po "<span class=brandsec>&\#93;</span><span class=brandfirst>project-open</span><span class=brandsec>&\#91;</span>"

    set wizard "
	<h2>License Agreement</h2>

	<p>
	This software has been developed by $po<br>
	(<a href=http://www.project-open.com/>http://www.project-open.com/</a>) 
	based on the work of <br>
	several open-source projects and other contributors.
	</p>
	<table cellpadding=2>
	<tr>
		<td>CentOS</td>	
		<td>https://www.centos.org/</td>
	</tr>
	<tr>
		<td>&\#93;project-open&\#91;</td>	
		<td>http://www.project-open.com/en/project-open-license</td>
	</tr>
	<tr>
		<td>NaviServer</td>		
		<td>https://www.mozilla.org/en-US/MPL/1.1/</td>
	</tr>
	<tr>
		<td>OpenACS</td>		
		<td>http://openacs.org/about/licensing/</td>
	</tr>
	<tr>
		<td>VMWare Tools</td>	
		<td>http://www.vmware.com/support/</td>
	</tr>
	</table>

	<p>By using this software, you are agreeing with the author's licensing terms.</p>
"

    set progress "
	<form action='/intranet-sysconfig/segment/sector' method=POST>
	<table cellspacing=0 cellpadding=4 border=0>
	<tr>
		<td></td>
		<td><input type=submit value='Next &gt;&gt;'></td>
	</tr>
	</table>
	</form>
    "

    return "
	<table height=400 width=600 cellspacing=0 cellpadding=0 border=0 background='$bg'>
	<tr valign=top><td>$wizard</td></tr>
	<tr align=center valign=bottom><td>$progress<br>&nbsp;</td></tr>
	</table>
    "
}





# ----------------------------------------------------------------------
# 
# ----------------------------------------------------------------------

ad_proc -public im_sysconfig_admin_guide { 
    {-show_items "open"}
} {
    Returns a formatted HTML block with a wizard tht
    guides new users through the configuration of PO
    @param show_items {"open","all"}
} {
    # Only show to administrators
    set user_id [ad_conn user_id]
    set user_is_admin_p [im_is_user_site_wide_or_intranet_admin $user_id]
    if {!$user_is_admin_p} { return "" }

    # Skip if the very first SysConfig wizard is active
    # (directly after running a PO system for the first time)
    set base_config_wizard_enabled_p [db_string base_en "select enabled_p from im_component_plugins where plugin_name = 'System Configuration Wizard'" -default ""]
    if {"f" ne $base_config_wizard_enabled_p} { return "" }

    set po "<span class=brandsec>&\#93;</span><span class=brandfirst>po</span><span class=brandsec>&\#91;</span>"
    set project_open "<span class=brandsec>&\#93;</span><span class=brandfirst>project-open</span><span class=brandsec>&\#91;</span>"
    set title "Guide to $po Configuration"
    set main_menu_id [im_menu_id_from_label "main"]
    set return_url [im_url_with_query]
    set help_site "http://www.project-open.net/en"
    set serverroot [acs_root_dir]
    set package_intranet_core [db_string cost "select min(package_id) from apm_packages where package_key = 'intranet-core'" -default ""]
    set package_intranet_cost [db_string cost "select min(package_id) from apm_packages where package_key = 'intranet-cost'" -default ""]
    set internal_company_id [db_string internal_company "select min(company_id) from im_companies where company_path = 'internal'" -default ""]
    set forum_url "http://sourceforge.net/p/project-open/discussion/295937/"

    # Get a list of the labesl of already processed items
    set items_done [parameter::get_from_package_key -package_key "intranet-sysconfig" -parameter "AdminGuideItemsDone" -default ""]


    # Get the CSV file
    set csv_file "$serverroot/packages/intranet-sysconfig/www/admin-guide/admin-guide-items.csv"
    if {[catch {
	set fl [open $csv_file]
	set content [read $fl]
	close $fl
    } err]} {
	ad_return_complaint 1 "Unable to open file $csv_file:<br><pre>\n$err</pre>"
	ad_script_abort
    }

    # Split the CSV file into lines
    set html ""
    set items [split $content "\n"]
    set ctr 0
    foreach line $items {

    	ns_log Notice "im_sysconfig_admin_guide: line=$line"

	# Split each line into a list based on tabs ("\t")
	set item [split $line ";"]
	if {[llength $item] < 3} { continue }

	set label [lindex $item 0]
	set indent [lindex $item 1]
	set title [lindex $item 2]
	set a ""
	set link [eval set a "[lindex $item 3]"]
	set help [lindex $item 4]
	set desc [lindex $item 5]

	# Replace quoted (double) quotes by simple quotes
	regsub -all {"""} $desc "\"" desc
	regsub -all {""} $desc "\"" desc
	regsub -all {\[} $desc "\\\[" desc
	regsub -all {\]} $desc "\\\]" desc

	regsub -all {"""} $title "\"" title
	regsub -all {""} $title "\"" title


	set cmd "set desc \"$desc\""
	eval $cmd

	if {[lsearch $items_done $label] >= 0} {
	    # The label is in the list of already processed items
	    continue
	}

	set link_html "<b>$title</b>"

	set config_html "<a href='$link' target='_blank'><span class=\"btn-po-small\">[lang::message::lookup "" intranet-sysconfig.Do_This_Now "Do this now"]</span></a>"
	if {"" == $link} { set config_html "" }

	set help_html "<a href='$help_site/$help' target='_blank'><span class=\"btn-po-small\">[lang::message::lookup "" intranet-core.More_Info "More Info"]</span></a>"
	if {"" == $help} { set help_html "" }

	if {$indent > 0} {
	    # Normal line - Write out link
	    append html "
		<ul><li style=\"list-style-type: none;\"><input type=checkbox name=item value=$label title='$title'>&nbsp;$link_html:<br>$desc $config_html $help_html</li></ul>
	    "
	} else {
	    # ident=0: Title row
	    if { 0 != $ctr  } {	append html "</div>" }
	    append html "
		<span id=\"q_$ctr\">
			<div style='margin-left: 30px;'>
				<div style='float: right;width: 100%;'><h2 style=\"text-decoration:underline;cursor:hand;cursor:pointer;margin-bottom:4px;\">$link_html</h2>$desc</div>
				<div id=\"gr_$ctr\" style='float: left;width: 20px;margin-left:-30px;margin-top: 18px;cursor:hand;cursor:pointer;'><img src='/intranet/images/plus_blue_15_15.gif' alt=''/></div>
				<div style='clear: both;'></div>
			</div>
		</span>
		<div id=\"a_$ctr\">
	    "	    
	    incr ctr;
	}
    }

    set html "
	<style>.fullwidth-list .component table.taskboard td { vertical-align:top; } </style>
	<form action='/intranet-sysconfig/admin-guide/admin-guide-action.tcl'>
	[export_vars -form {return_url}]
<table cellpadding=\"3\" cellspacing=\"3\" border=\"0\">
    <tr>
        <td valign=\"top\">
            <table cellpadding=\"3\" cellspacing=\"3\" border=\"0\">
                <tr>
                    <td colspan=\"2\"><span style=\"font-size: 16px; font-weight:bold; color:#666666\">Professional Support</span></td>
                </tr>
                <tr>
                    <td valign=\"top\"><img src=\"/intranet/images/conf_wizard_professional_support.png\" alt=\"\" /></td>
                    <td valign=\"top\">The <span class=brandsec>\]</span><span class=brandfirst>project-open</span><span class=brandsec>\[</span> 
                                       Team offers a wide range of <a href=\"http://www.project-open.com/en/services/index.html\" target=\"_blank\">professional services</a> 
                                       in order to help you with the installation, configuration and operation of 
                                       <span class=brandsec>\]</span><span class=brandfirst>po</span><span class=brandsec>\[<br /></span>
                                        &nbsp;<br/>
                                        Get in toch us to learn more using our <a href=\"http://www.project-open.com/en/company/project-open-contact.html\" target=\"_blank\">contact form</a>. 
                    </td>
                </tr>
            </table>
        </td>
        <td valign=\"top\">
            <table cellpadding=\"3\" cellspacing=\"3\" border=\"0\">
                <tr>
                    <td colspan=\"2\"><span style=\"font-size: 16px; font-weight:bold; color:#666666\">Online Documentation</span></td>
                </tr>
                <tr>
                    <td valign=\"top\"><img src=\"/intranet/images/conf_wizard_help.png\" alt=\"\"/></td>
                    <td valign=\"top\">
                        Comprehensive Online Documentation is available at <a href=\"http://www.project-open.com/en/\" target=\"_blank\">www.project-open.com/en/</a><br />
                        <br />
                        For Community Support please refer to our Forum hosted at <a href=\"https://sourceforge.net/p/project-open/discussion/295937/\" target=\"_blank\">sourceforge.net</a>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td valign=\"top\">
            <table cellpadding=\"3\" cellspacing=\"3\" border=\"0\">
                <tr>
                    <td colspan=\"2\"><span style=\"font-size: 16px; font-weight:bold; color:#666666\">Professional Editions</span></td>
                </tr>
                <tr>
                    <td valign=\"top\"><img src=\"/intranet/images/conf_wizard_professional_versions.png\" alt=\"\"/></td>
                    <td valign=\"top\">
                        Our professional editions offer features and extended support options for customers with higher demands. 
                        <br />
                        <br />
                        Get an complete overview about the additional modules and services included on our PRO editions 
                        <a href=\"http://www.project-open.com/en/products/editions.html\" target=\"_blank\">here</a>.
                    </td>
                </tr>
            </table>
        </td>
        <td valign=\"top\">
            <table cellpadding=\"3\" cellspacing=\"3\" border=\"0\">
                <tr>
                    <td colspan=\"2\"><span style=\"font-size: 16px; font-weight:bold; color:#666666\">Saas Server</span></td>
                </tr>
                <tr>
                    <td valign=\"top\"><img src=\"/intranet/images/conf_wizard_saas.png\" alt=\"\" /></td>
                    <td valign=\"top\">
                        Running <span class=brandsec>\]</span><span class=brandfirst>project-open</span><span class=brandsec>\[</span> 
                        over the internet helps business owners to focus on their business activities while we handle the IT support role.
                        <br /><br />
                        For additional information about our SaaS offers please refer to <a href=\"http://www.project-open.com/en/services/project-open-hosting-saas.html\" target=\"_blank\">this site</a>.
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<br/>
<h1>Configure your system:</h1>
<p>Click on the '+' symbol of each category to find more information and links to relevant configuration pages. </p>
     	<div id=\"q_and_a\">
		$html
		</div> <!-- closing -->
        </div>
	<br>
	<table class=taskboard>	
	<tr><td colspan=2>
		<select name=action2>
			<option value=mark_as_done>Mark as done</option>
			<option value=reset>Reset to Initial State</option><
		</select>
		<input type=submit name=action_submit2 value=Action>
	</td></tr>

	</table>
	</form>

  	<script>
    	\$(document).ready(function(){
		\$(\"#q_and_a\").find('span\[id^=\"q_\"\]').each(function(i, obj) {
    			\$(obj).click(function() {
				\$('#a_'+obj.id.substr(2)).slideToggle('slow', function() {});
				if ( \$('\#gr_'+obj.id.substr(2)).html().indexOf('plus') > -1 ) {
					\$('\#gr_'+obj.id.substr(2)).html(\"<img src='/intranet/images/minus_blue_15_15.gif' alt='' />\");
				} else {
					\$('\#gr_'+obj.id.substr(2)).html(\"<img src='/intranet/images/plus_blue_15_15.gif' alt='' />\");
				};
    			});
			\$('\#a_'+obj.id.substr(2)).slideToggle('slow');

		});
	});
	</script>
    "
    return $html
}




ad_proc -public im_sysconfig_parse_groups { group_list } {
    Takes a komma separated list of groups and returns a 
    TCL list with group_ids.
} {
    set groups [split $group_list ","]
    set result [list]
    foreach g $groups {
	set gid [im_profile::profile_id_from_name -profile [string trim $g]]
	if {[string is integer $gid]} { lappend result $gid }
    }
    return $result
}


ad_proc -public im_sysconfig_load_configuration { file } {
    Reads the content of the configuration file and applies the
    configuration to the current server.
} {
    set current_user_id [auth::require_login]

    set csv_files_content [fileutil::cat $file]
    set csv_files [split $csv_files_content "\n"]
    
    set separator [im_csv_guess_separator $csv_files]
    set separator ";"

    ns_log Notice "import-conf-2: trying with separator=$separator"
    # Split the header into its fields
    set csv_header [string trim [lindex $csv_files 0]]

    set csv_header_fields [im_csv_split $csv_header $separator]
    set csv_header_len [llength $csv_header_fields]
    set values_list_of_lists [im_csv_get_values $csv_files_content $separator]

    # Privileges are granted on a "magic object" in the system
    set privilege_grant_object_id [db_string priv_grant_object "
	select min(object_id)
	from acs_objects
	where object_type = 'apm_service'
    "]


    # ------------------------------------------------------------
    # Loop through the CSV lines
    
    set html ""
    set type ""
    set key ""
    set value ""
    set package_key ""
    
    set cnt 1
    foreach csv_line_fields $values_list_of_lists {
	incr cnt
	
	# Write columns to local variables
	for {set i 0} {$i < [llength $csv_header_fields]} {incr i} {
	    set var [lindex $csv_header_fields $i]
	    set val [lindex $csv_line_fields $i]
	    if {"" != $var} { set $var $val }
	}
	
	append html "<li>\n"
	append html "<li>line: $cnt\n"
	append html "<li>line=$cnt, type='$type', key='$key', package_key='$package_key', value='$value'\n"
	
	switch [string tolower $type] {
	    category {
		set type_name [split $key "."]
		set category_type [string tolower [lindex $type_name 0]]
		set category [string tolower [lindex $type_name 1]]
		set category_ids [db_list cat "select category_id from im_categories where lower(category_type) = :category_type and lower(category) = :category"]
		if {[llength $category_ids] > 1} {
		    append html "<li>line=$cnt, $type: found more the one category matching category_type='$category_type' and category='$category'."
		    continue
		}
		if {[llength $category_ids] < 1} {
		    append html "<li>line=$cnt, $type: Did not find a category matching category_type='$category_type' and category='$category'."
		    continue
		}
		set old_value [db_string old_cat "select enabled_p from im_categories where category_id = :category_ids" -default ""]
		if {$value != $old_value} {
		    db_dml menu_en "update im_categories set enabled_p = :value where category_id = :category_ids"
		    append html "<li>line=$cnt, $type: Successfully update category_type='$category_type' and category='$category'."
		} else {
		    append html "<li>line=$cnt, $type: No update necessary."
		}
	    }
	    menu {
		set menu_id [db_string menu "select menu_id from im_menus where label = :key" -default 0]
		if {0 != $menu_id} {
		    set old_value [db_string old_value "select enabled_p from im_menus where label = :key" -default ""]
		    if {$value != $old_value} {
			db_dml menu_en "update im_menus set enabled_p = :value where label = :key"
			append html "<li>line=$cnt, $type: Successfully update menu label='$value'.\n"
		    } else {
			append html "<li>line=$cnt, $type: No update necessary."
		    }
		} else {
		    append html "<li>line=$cnt, $type: Did not find menu label='$key'.\n"
		}
	    }
	    privilege {
		set privilege_exists_p [db_string priv "select count(*) from acs_privileges where privilege = :key" -default 0]
		if {0 != $privilege_exists_p} {
		    set old_value [db_string old_value "select im_sysconfig_display_privileges(:key)"]
		    if {1 || $value != $old_value} {

			set group_list [im_sysconfig_parse_groups $value]
			foreach g $group_list {
			    db_string grant_perms "select acs_permission__grant_permission(:privilege_grant_object_id, :g, :key)"
			    append html "<li>line=$cnt, $type: Granted privilege '$key' to group \#$g.\n"
			}

		    } else {
			append html "<li>line=$cnt, $type: No update necessary."
		    }
		} else {
		    append html "<li>line=$cnt, $type: Did not find menu label='$key'.\n"
		}
	    }
	    portlet {
		set portlet_id [db_string portlet "select plugin_id from im_component_plugins where plugin_name=:key and package_name=:package_key" -default 0]
		if {0 != $portlet_id} {
		    set old_value [db_string old_value "select enabled_p from im_component_plugins where plugin_name=:key and package_name=:package_key" -default ""]
		    if {$value != $old_value} {
			db_dml portlet "update im_component_plugins set enabled_p = :value where plugin_name=:key and package_name=:package_key"
			append html "<li>line=$cnt, $type: Successfully update portlet '$value'.\n"
		    } else {
			append html "<li>line=$cnt, $type: No update necessary."
		    }
		} else {
		    append html "<li>line=$cnt, $type: Did not find portlet '$value'.\n"
		}
	    }
	    parameter {

		set exclude_p 0

		# Exclude parameters including "PathUnix" in their name
		if {[regexp {PathUnix} $key match]} { set exclude_p 1 }
		
		# Exclude parameters for specified packages entirely
		if {"acs-mail-lite" == $package_key} { set exclude_p 1 }

		# Parameter specific to LDAP and Authentication
		set ldap_parameters {
		    RegisterAuthority
		    EnableUsersAuthorityP
		    EnableUsersUsernameP
		}
		if {[lsearch $ldap_parameters $key] >= 0} { set exclude_p 1 }

		# Parameters related to the operating system
		set os_parameters {
		    ImageMagickConvertBinary
		    SystemCommandPaths
		    HtmlDocBin
		    graphviz_dot_path
		    tmp_path
		    ArchiveCommand
		    FindCmd
		    GzipCmd
		    TarCmd
		    CvsPath
		    UtilCurrentLocationRedirect
		    FilenameCharactersSupported
		    SuppressHttpPort
		}
		if {[lsearch $os_parameters $key] >= 0} { set exclude_p 1 }

		# Ownership related parameters
		set owner_parameters {
		    OutgoingSender
		    PublisherName
		    AdminOwner
		    HostAdministrator
		    SystemName
		    SystemOwner
		    SystemURL
		    SystemTimezone
		    SiteWideLocale
		    NewRegistrationEmailAddress
		    SystemLogo
		    SystemLogoLink
		    HelpdeskOwner
		}
		if {[lsearch $owner_parameters $key] >= 0} { set exclude_p 1 }

		# Performance related parameters
		set performance_parameters {
		    DBCacheSize
		    PerformanceModeP
		    TestDemoDevServer
		}
		if {[lsearch $performance_parameters $key] >= 0} { set exclude_p 1 }

		if {$exclude_p} { 
		    append html "<li>line=$cnt, type='$type', key='$key': Excluded parameter because it is a system, performance, authorization or ownership related parameter\n"
		    continue
		}

		set parameter_id [db_string param "select parameter_id from apm_parameters where package_key = :package_key and lower(parameter_name) = lower(:key)" -default 0]
		if {0 == $parameter_id} {
		    append html "<li>line=$cnt, $type: Did not find parameter with package_key='$package_key' and name='$key'.\n"
		    continue
		}
		set old_value [db_string old_val "select min(attr_value) from apm_parameter_values where parameter_id = :parameter_id" -default ""]
		if {$value != $old_value} {
		    db_dml param "update apm_parameter_values set attr_value = :value where parameter_id = :parameter_id"
		    append html "<li>line=$cnt, $type: Successfully update parameter='$key'.\n"
		} else {
		    append html "<li>line=$cnt, $type: No update necessary."
		}
	    }
	    default {
		append html "<li>line=$cnt, type='$type' not implemented yet.\n"
	    }
	}
    }

    # Force recalculation of cached menus etc
    im_permission_flush

    return $html
}


# ------------------------------------------------------------
# Timeshift
# ------------------------------------------------------------

ad_proc -public im_sysconfig_timeshift { 
    { -offset "" }
} {
    Checks the demo-data for age and updated demo-data
} {
    if {"" eq $offset} {
	set now_julian [db_string av "select to_char(now()::date, 'J')"]
	set project_start_julian [db_string av "select round(avg(to_char(start_date, 'J')::integer)) from im_projects"]

	# Check if the data are already up to date
	set offset [expr $now_julian - $project_start_julian]
	if {$offset <= 0} { return $offset }
    }

    db_dml up "update acs_logs set log_date = log_date + '$offset days'::interval"

    db_dml up "update acs_objects set creation_date = creation_date + '$offset days'::interval"
    db_dml up "update acs_objects set last_modified = last_modified + '$offset days'::interval"

    db_dml up "update cr_revisions set publish_date = publish_date + '$offset days'::interval"

    db_dml up "update im_audits set audit_date = audit_date + '$offset days'::interval"

    db_dml up "update im_costs set effective_date = effective_date + '$offset days'::interval"
    db_dml up "update im_costs set last_modified = last_modified + '$offset days'::interval"
    db_dml up "update im_costs set start_block = start_block + '$offset days'::interval"

    db_dml up "update im_forum_topics set posting_date = posting_date + '$offset days'::interval"
    db_dml up "update im_forum_topics set due_date = due_date + '$offset days'::interval"

    db_dml up "update im_gantt_assignment_timephases set timephase_end = timephase_end + '$offset days'::interval, timephase_start = timephase_start + '$offset days'::interval"

    db_dml up "update im_hours set day = day + '$offset days 1 second'::interval, creation_date = creation_date + '$offset days'::interval"

    db_dml up "update im_indicator_results set result_date = result_date + '$offset days'::interval"

    db_dml up "update im_invoices set deadline_start_date = deadline_start_date + '$offset days'::interval"

    db_dml up "update im_payments set received_date = received_date + '$offset days'::interval"

    db_dml up "update im_planning_items set item_date = item_date + '$offset days'::interval"

    db_dml up "update im_prices set end_date = end_date + '$offset days'::interval"
    db_dml up "update im_prices set start_date = start_date + '$offset days'::interval"

    db_dml up "update im_projects set end_date = end_date + '$offset days'::interval, start_date = start_date + '$offset days'::interval"

    db_dml up "update im_repeating_costs set start_date = start_date + '$offset days'::interval, end_date = end_date + '$offset days'::interval"

    db_dml up "update im_user_absences set start_date = start_date + '$offset days'::interval, end_date = end_date + '$offset days'::interval"
    db_dml up "update im_user_absences set last_modified = last_modified + '$offset days'::interval"

    db_dml up "update im_tickets set ticket_alarm_date = ticket_alarm_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_creation_date = ticket_creation_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_reaction_date = ticket_reaction_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_confirmation_date = ticket_confirmation_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_done_date = ticket_done_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_signoff_date = ticket_signoff_date + '$offset days'::interval"
    db_dml up "update im_tickets set ticket_customer_deadline = ticket_customer_deadline + '$offset days'::interval"

    db_dml up "update im_prices set start_date = start_date + '$offset days'::interval"

    db_dml up "update im_timesheet_conf_objects set start_date = start_date + '$offset days'::interval, end_date = end_date + '$offset days'::interval"

    db_dml up "update im_timesheet_invoices set invoice_period_start = invoice_period_start + '$offset days'::interval"
    db_dml up "update im_timesheet_invoices set invoice_period_end = invoice_period_end + '$offset days'::interval"

    db_dml up "update im_timesheet_prices set valid_through = valid_through + '$offset days'::interval"
    db_dml up "update im_timesheet_prices set valid_from = valid_from + '$offset days'::interval"

    db_dml up "update im_timesheet_tasks set scheduling_constraint_date = scheduling_constraint_date + '$offset days'::interval"
    db_dml up "update im_timesheet_tasks set deadline_date = deadline_date + '$offset days'::interval"

    db_dml up "update survsimp_question_responses set date_answer = date_answer + '$offset days'::interval"

    return $offset
}
