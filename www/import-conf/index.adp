<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">@context_bar;literal@</property>
<property name="main_navbar_label">companies</property>

<form enctype="multipart/form-data" method=POST action="import-conf-2">
<%= [export_vars -form {return_url}] %>
    <table border="0">
      <tr> 
	<td>Filename</td>
	<td> 
	  <input type="file" name="upload_file" size="30">
	<%= [im_gif help "Use the &quot;Browse...&quot; button to locate your file, then click &quot;Open&quot;."] %>
	</td>
      </tr>
      <tr> 
	<td></td>
	<td> 
	  <input type="submit" value="Submit and Upload">
	</td>
      </tr>
    </table>
</form>

