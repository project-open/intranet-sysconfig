<%      
	if {![info exists title] && [info exists doc(title)]} { set title $doc(title) } 
%>
<%= [im_header "[lang::message::lookup "" intranet-sysconfig.SysConfig_Wizard "SysConfig Wizard:"] $title"] %>
<%= [im_navbar "admin"] %>

<img src="/intranet/images/cleardot.gif" width=2 height=2>
<table cellpadding="2" cellspacing="0" border="1" frame=void class='tablePortletElement'>
<thead>
<tr><td class=tableheader>

	<table cellpadding="0" cellspacing="0" width="100%">
	<tr>
	    <td class=tableheader width=25>
		<%= [im_gif "arrow_comp_minimize"] %>
	    </td>
	    <td class=tableheader align="left">@title@</td>
	    <td class=tableheader width=100 align="right"><nobr></td>
	</tr>
    	</table>

</td></tr>
</thead>
<% if {$page=="logo"} { %>
<form name="wizard" method="POST" enctype="multipart/form-data">
<% } else { %>
<form name="wizard" method="GET">
<% } %>
@export_vars;noquote@
<tbody>
<tr><td class=tablebody colspan="3"><font size=-1>

	<table height=400 width=600 cellspacing="0" cellpadding="0" border="0">
	<tr valign="top"><td>

		<table border="0" align="right">
		<tr>
		<td>
		<b>Progress</b><br>
		@advance_component;noquote@
		</td>
		</tr>
		</table>

		<slave>

	</td></tr>
        <tr align="center" valign="bottom"><td>@navbar;noquote@<br>&nbsp;</td></tr>
	</table>

</td></tr>
</tbody>
</form>
</table>

    <script type="text/javascript">
    <!--
	function sendForm()
        {
		if (validate()) {
		   window.document.wizard.action='@next_page@';
		   window.document.wizard.submit();
	        }
	}
    --> 
    </script>

<if @page@ eq sector>
    <script type="text/javascript">
    <!--
        function validate() {
            if( window.document.wizard.sector.value == "" )
            {
                alert( "Please select an option!" );
                window.document.wizard.sector.focus() ;
                return false;
            }
            return true;
        }
    --> 
    </script>
</if>

<elseif @page@ eq deptcomp>
    <script type="text/javascript">
    <!--
        function validate() {
            if( window.document.wizard.deptcomp.value == "" )
            {
                alert( "Please select an option!" );
                window.document.wizard.deptcomp.focus() ;
                return false;
            }
            return true;
        }
    -->
    </script>
</elseif>

<elseif @page@ eq features>
    <script type="text/javascript">
    <!--
        function validate() {
            if( window.document.wizard.features.value == "" )
            {
                alert( "Please select an option!" );
                window.document.wizard.features.focus() ;
                return false;
            }
            return true;
        }
    -->
    </script>
</elseif>


<elseif @page@ eq orgsize>
    <script type="text/javascript">
    <!--
        function validate() {
            if( window.document.wizard.orgsize.value == "" )
            {
                alert( "Please select an option!" );
                window.document.wizard.features.focus() ;
                return false;
            }
            return true;
        }
    -->
    </script>
</elseif>

<elseif @page@ eq name>
    <script type="text/javascript">
    <!--
        function validate()
        {
            if( window.document.wizard.name_name.value == "" )
            {
                alert( "Please provide a name of your company!" );
                window.document.wizard.name_name.focus() ;
                return false;
            }

            if( window.document.wizard.name_email.value == "" )
            {
                alert( "Please provide an email to have important system messages sent to you." );
                window.document.wizard.name_email.focus() ;
                return false;
            } else {
               atpos =  window.document.wizard.name_email.value.indexOf("@");
               dotpos = window.document.wizard.name_email.value.lastIndexOf(".");
               if (atpos < 1 || ( dotpos - atpos < 2 )) {
                  alert("Please enter a correct email to have important system messages sent to you.")
                  window.document.wizard.name_email.focus() ;
                  return false;
               }
            }


            return(true);
       }

       function validateEmail()
       {
         var emailID = document.myForm.EMail.value;
         atpos = emailID.indexOf("@");
         dotpos = emailID.lastIndexOf(".");

         if (atpos < 1 || ( dotpos - atpos < 2 ))
         {
            alert("Please enter correct email ID")
            document.myForm.EMail.focus() ;
            return false;
         }
         return( true );
       }

       //-->
       </script>
</elseif>

<elseif @page@ eq profiles>
    <script type="text/javascript">
    <!--
        function validate() {

            if( 
	    	!window.document.wizard.elements["profiles_array.employees,all_projects"].checked &&
		!window.document.wizard.elements["profiles_array.employees,all_companies"].checked &&
		!window.document.wizard.elements["profiles_array.employees,finance"].checked
            )
            {
                alert( "Please select at least one option for line 'Employees'!" );
                window.document.wizard.features.focus() ;
                return false;
            }
            if(
                !window.document.wizard.elements["profiles_array.project_managers,all_projects"].checked &&
                !window.document.wizard.elements["profiles_array.project_managers,all_companies"].checked &&
                !window.document.wizard.elements["profiles_array.project_managers,finance"].checked
            )
            {
                alert( "Please select at least one option for line 'Project Managers'!" );
                window.document.wizard.features.focus() ;
                return false;
            }
            return true;
        }
    -->
    </script>
</elseif>

<else>
    <script type="text/javascript">
    <!--
	function validate() { 
	     return true; 
	}
    --> 
    </script>
</else>

<%= [im_footer] %>
