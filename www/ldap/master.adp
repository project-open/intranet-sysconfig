<%      if {![info exists title] && [info exists doc(title)]} { set title $doc(title) } %>

<%
    #
    # Add the content security policy. Since this is the blank master, we
    # are defensive and check, if the system has already support for it
    # via the CSPEnabledP kernel parameter. Otherwise users would be
    # blocked out.
    #
    if {[parameter::get -parameter CSPEnabledP -package_id [ad_acs_kernel_id] -default 0]
	&& [info commands ::security::csp::render] ne ""
    } {
	set csp [::security::csp::render]
	if {$csp ne ""} {

	    set ua [ns_set iget [ns_conn headers] user-agent]
	    if {[regexp {Trident/.*rv:([0-9]{1,}[\.0-9]{0,})} $ua]} {
		set field X-Content-Security-Policy
	    } else {
		set field Content-Security-Policy
	    }

	    ns_set put [ns_conn outputheaders] $field $csp
	}
    }

%>


<%= [im_header "[lang::message::lookup "" intranet-sysconfig.LDAP_Wizard "LDAP Wizard:"] $title"] %>
<%= [im_navbar "admin"] %>



<script type="text/javascript" <if @::__csp_nonce@ not nil>nonce="@::__csp_nonce;literal@"</if>>
window.addEventListener('load', function() { 
    var prev = document.getElementById('ldap_button_prev');
    if (!!prev) prev.addEventListener('click', function() { 
	window.document.wizard.action='@prev_page;noquote@'; 
	window.document.wizard.submit();	
    });
    var next = document.getElementById('ldap_button_next');
    if (!!next) next.addEventListener('click', function() { 
	window.document.wizard.action='@next_page;noquote@'; 
	window.document.wizard.submit();	
    });
    var test = document.getElementById('ldap_button_test');
    if (!!test) test.addEventListener('click', function() { 
	window.document.wizard.action='@test_page;noquote@'; 
	window.document.wizard.submit();	
    });
});
</script>

<img src="/intranet/images/cleardot.gif" width="2" height=2>
<table cellpadding="2" cellspacing="0" border="1" frame=void class='tablePortletElement'>
<thead>
<tr><td class=tableheader>

	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
	    <td class=tableheader width="25">
		<%= [im_gif "arrow_comp_minimize"] %>
	    </td>
	    <td class=tableheader align="left">@title@</td>
	    <td class=tableheader width="100" align="right"><nobr></td>
	</tr>
    	</table>

</td></tr>
</thead>
<form name="wizard" method="POST">
@export_vars;noquote@
<tbody>
<tr><td class=tablebody colspan="3"><font size=-1>
	<table height=400 width="600" cellspacing="0" cellpadding="0" border="0">
	<tr valign="top"><td>
		<table border="0" align="right">
		<tr>
		<td>
		<b>Progress</b><br>
		@advance_component;noquote@
		</td>
		</tr>
		</table>

<!-- Start of "slave" in www/ldap/master.adp -->
		<slave>
<!-- End of "slave" in www/ldap/master.adp -->

	</td></tr>
        <tr align="center" valign="bottom"><td>@navbar;noquote@<br>&nbsp;</td></tr>
	</table>
</td></tr>
</tbody>
</form>
</table>

<%= [im_footer] %>
