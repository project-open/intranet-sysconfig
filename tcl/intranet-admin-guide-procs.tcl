# /packages/intranet-sysconfig/tcl/intranet-admin-guide-procs.tcl
#
# Copyright (c) 2006 ]project-open[
#
# All rights reserved. Please check
# http://www.project-open.com/license/ for details.

ad_library {
    Interactive Admin Guide
    @author frank.bergmann@project-open.com
    @author klaus.hofeditz@project-open.com
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

	set config_html "<a href='$link' target='_blank'><span class=\"btn-po-small\"
	    >[lang::message::lookup "" intranet-sysconfig.Do_This_Now "Do this now"]</span></a>"
	if {"" == $link} { set config_html "" }

	set help_html "<a href='$help_site/$help' target='_blank'><span class=\"btn-po-small\"
	    >[lang::message::lookup "" intranet-core.More_Info "More Info"]</span></a>"
	if {"" == $help} { set help_html "" }

	if {$indent > 0} {
	    # Normal line - Write out link
	    append html "
		<ul><li style=\"list-style-type: none;\"
		><input type=checkbox name=item value=$label title='$title'>&nbsp;$link_html:<br
		>$desc $config_html $help_html</li></ul>
	    "
	} else {
	    # ident=0: Title row
	    if { 0 != $ctr  } {	append html "</div>" }
	    append html "
		<span id=\"q_$ctr\">
			<div style='margin-left: 30px;'>
				<div style='float: right;width: 100%;'><h2 style=\"text-decoration:underline;cursor:hand;cursor:pointer;margin-bottom:4px;\"
				>$link_html</h2>$desc</div>
				<div id=\"gr_$ctr\" style='float: left;width: 20px;margin-left:-30px;margin-top: 18px;cursor:hand;cursor:pointer;'
				><img src='/intranet/images/collapse-blue-right-15x15.png' alt=''/></div>
				<div style='clear: both;'></div>
			</div>
		</span>
		<div id=\"a_$ctr\">
	    "	    
	    incr ctr;
	}
    }

    # -------------------------------------------------------------
    # Show services select
    #
    set system_id [im_system_id]
    set teaser_args [export_vars {{no_template_p 1} {no_title_p 1} {system_id $system_id}}]
    set page_html "
	    <script>
	    var onServiceChange = function(serviceId) {
		var url = 'https://www.project-open.net/en/service-teaser-'+serviceId+'?$teaser_args';
		var el = document.getElementsByName('serviceFrame')\[0\];
		if (el) el.src = url; 
	    }
	    </script>
    "

    append page_html "
	<style>.fullwidth-list .component table.taskboard td { vertical-align:top; } </style>

<table width=100% border=0>
<tr valign=center>
<td width='200'>
    <form action='https://www.project-open.net/intranet-crm-tracking/service-teaser-submit' method=GET>
"

set services {
    { free_demo "Free Demo" }
    { cloud_backup "Cloud Backup" }
    { saas_hosting "SaaS Hosting" }
    { security_patches "Security Patches" }
    { training "Training" }
    { consulting "Consulting" }
    { support_contract "Support Contract" }
}

set ttt {
    { online_documentation "Online Documentation" }
    { feature_updates "Feature Updates" }
    { workshop "Workshop" }
    { pro_edition "PRO Edition" }
    { enterprise_edition "Enterprise Edition" }
}

foreach tuple $services {
    set service_underscore [lindex $tuple 0]
    set pretty_name [lindex $tuple 1]
    regsub -all {_} $service_underscore "-" service_dash
    set pretty_name_l10n [lang::message::lookup "" intranet-sysconfig.Service_radio_$service_underscore $pretty_name]
    append page_html "<nobr><input type=radio name=service value=$service_dash onChange=\"onServiceChange('$service_dash')\">$pretty_name_l10n</nobr><br>\n"
}

    append page_html "
	<br>
	<input name=submit type=submit value='[lang::message::lookup "" intranet-sysconfig.Request_details "Request Details"]'>
    </form>
</td>
<td width='50%'>
<!--	<div id='serviceDiv'/> -->
<iframe name='serviceFrame' width=400 height=200 frameBorder=0 src=/intranet-sysconfig/admin-guide/service-teaser-default>Browser not compatible</iframe>
</td>
</tr>
</table>

	<form action='/intranet-sysconfig/admin-guide/admin-guide-action.tcl'>
	[export_vars -form {return_url}]

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
				if ( \$('\#gr_'+obj.id.substr(2)).html().indexOf('right') > -1 ) {
					\$('\#gr_'+obj.id.substr(2)).html(\"<img src='/intranet/images/collapse-blue-down-15x15.png' alt='' />\");
				} else {
					\$('\#gr_'+obj.id.substr(2)).html(\"<img src='/intranet/images/collapse-blue-right-15x15.png' alt='' />\");
				};
    			});
			\$('\#a_'+obj.id.substr(2)).slideToggle('slow');

		});
	});
	</script>
    "
    return $page_html
}


