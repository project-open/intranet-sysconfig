<!-- packages/intranet-sysconfig/sector/index.adp -->
<!-- @author Frank Bergmann (frank.bergmann@project-open.com) -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<master src="master">
<property name="doc(title)">System Configuration Wizard</property>

<h2>Simplified or Complete Install?</h2>

<table border="0" width="80%">
<tr><td colspan="3">

	<p>
	@po_small;noquote@ offers nearly 100 distinct packages which can be individually<br>
	enabled or disabled. Please select your start configuration now. <br>
	You can change the configuration at any time by running this wizard again.<br>&nbsp;
	</p>
	
</td></tr>
<tr valign="top">
  <td><input type="radio" name="features" value="minimum" <if @features@ eq "minimum">checked</if>></td>
  <td colspan="2">
	<b>Simplified System</b><br>
	Install a minimal system with projects and timesheet.<br>
	This option is useful for first time @po;noquote@ users.
	<br>&nbsp;
  </td>
</tr>

<tr valign="top">
  <td><input type="radio" name="features" value="frequently_used" <if @features@ eq "frequently_used">checked</if>></td>
  <td colspan="2">
    <div style="border:0px solid; background:#eee;">
	<b>Default System</b><br>
	Install packages suitable for business sector and organization type.
    </div>
	<br>
  </td>
</tr>

<tr valign="top">
  <td><input type="radio" name="features" value="other" <if @features@ eq "other">checked</if>></td>
  <td colspan="2">
	<b>Complete / Full Installation</b><br>
	Install everything. You will have to manually disable unsuitable packages.<br>
	This option is useful for advanced @po;noquote@ users.
	<br>&nbsp;
  </td>
</tr>
</table>
