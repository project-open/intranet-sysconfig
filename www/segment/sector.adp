<!-- packages/intranet-sysconfig/sector/index.adp -->
<!-- @author Frank Bergmann (frank.bergmann@project-open.com) -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<master src="master">
<property name="doc(title)">Business Sector</property>

<h2>Business Sector</h2>

<table border="0" width="80%">
<tr><td colspan="3">

	<p>
	The following pages allow you to configure @po;noquote@ 
	according to your needs. You can change these settings at 
	any time without rebooting or reinstalling the system.
	</p>
	
	<p>
	My department/company provides services in the
	following areas:
	</p>

</td></tr>
<tr valign="top">
  <td>
	<input type="radio" name="sector" value="it_consulting" <if @sector@ eq "it_consulting">checked</if>>
  </td>
  <td colspan="2">
	<b>Information Technology</b><br>
	IT Operations, Software Development, IT Consulting, Software Testing, ...
  </td>
</tr>

<tr valign="top">
  <td>
  <input type="radio" name="sector" value="biz_consulting" <if @sector@ eq "biz_consulting">checked</if>>
  </td>
  <td colspan="2">
	<b>Business Consulting</b><br>
	Strategic Consulting, Financial Consulting, Organizational Development, ...
  </td>
</tr>

<!--
<tr valign="top">
  <td>
  <input type="radio" name="sector" value="translation" <if @sector@ eq "translation">checked</if>>
  </td>
  <td colspan="2">
	<b>Translation and Localization</b><br>
	Translation, Software Localization, Technical Documentation, ...
  </td>
</tr>
-->

<tr valign="top">
  <td><input type="radio" name="sector" value="advertizing" <if @sector@ eq "advertizing">checked</if>></td>
  <td colspan="2">
	<b>Advertising &amp; Web Development</b><br>
	Advertising or Interactive Media Development...
  </td>
</tr>

<tr valign="top">
  <td>
  <input type="radio" name="sector" value="engineering" <if @sector@ eq "engineering">checked</if>>
  </td>
  <td colspan="2">
	<b>Product Development & Engineering</b><br>
	Mechanical Engineering, Electrical Engineering, Marketing, ...
  </td>
</tr>

<tr valign="top">
  <td>
  <input type="radio" name="sector" value="other" <if @sector@ eq "other">checked</if>>
  </td>
  <td>
	<b>Other / Everything</b><br>
	None of the above fits my company or department. Please install everything.
	
  </td>
</tr>

</table>

