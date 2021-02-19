<master src="master">
<property name="doc(title)">@page_title;literal@</property>

<if @installed_p@ lt 1>
<font color=red>
<h2>LDAP Driver Not Installed</h2>
<p>The package 'auth-ldap-adldapsearch' is not installed on this system.<br>
Starting with ]po[ V5.0, this driver is only available as part of the <br>
<a href="https://www.project-open.com/en/products/editions.html" target="_blank"
>Professional or Enterprise editions</a> of ]project-open[. <br>
</font>
</if>

<h2>@page_title@</h2>
<p>
This wizard will help you to identify and connect to<br>
a corporate LDAP server including Microsoft Active<br>
Directory or OpenLDAP.<br>

<h2>IP Address of the LDAP Server</h2>

<p>
Please enter the IP address and port of your LDAP server
and press "Next" below.<br>
</p>
<br>

<input type="hidden" name="ldap_type" value="@ldap_type;noquote@">
<input type="hidden" name="domain" value="@domain;noquote@">
<input type="hidden" name="binddn" value="@binddn;noquote@">
<input type="hidden" name="bindpw" value="@bindpw;noquote@">
<input type="hidden" name="system_binddn" value="@system_binddn;noquote@">
<input type="hidden" name="system_bindpw" value="@system_bindpw;noquote@">
<input type="hidden" name="authority_id" value="@authority_id@">
<input type="hidden" name="authority_name" value="@authority_name@">
<input type="hidden" name="group_map" value="@group_map;noquote@">


<table>
<tr>
<td>IP/Host:</td>
<td><input type="text" name="ip_address" value="@ip_address@" size="16" maxsize="16"></td>
</tr>
<tr>
<td>Port:</td>
<td><input type="text" name="port" value="@port@" size="5" maxsize="5"></td>
</tr>
</table>
