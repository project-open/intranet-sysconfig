<!-- packages/intranet-sysconfig/www/segment/name.adp -->
<!-- @author Christof Damian (christof.damian@project-open.com) -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<master src="master">
<property name="doc(title)">System Configuration Wizard</property>

<input type="hidden" name="name" value="1">

<h2>Organization Name and Default Email</h2>

<p>
Please enter your organization name. This name appears in emails,<br>
invoices and other financial documents. Example: "ABC Consulting, Inc."
</p><br>
<p>
<input type="text" name="name_name" value="@name_name@" size="40">
</p>

<p>
Please enter the email of the support team in charge of @po;noquote@.<br>
This email appears in the "Contact" footer of every page.
</p><br>
<p>
<input type="text" name="name_email" value="@name_email@" size="40">
</p>
