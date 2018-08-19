<!-- packages/intranet-sysconfig/sector/index.adp -->
<!-- @author Frank Bergmann (frank.bergmann@project-open.com) -->

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN">
<master src="master">
<property name="doc(title)">System Configuration Wizard</property>
<property name="page">sector</property>


<!--
<div id=hexagon_container style="position:relative; height:400px; width:600px">
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:0px; left:135px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:76px; left:0px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:76px; left:270px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/blue-100.png" 
style="position:absolute; top:152px; left:135px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:228px; left:0px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:228px; left:270px; width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute; top:304px; left:135px; width:@w@px; height:@h@px; border:none;"/>
</div>
-->

<!--
<div style="position:relative; height:400px; width:600px;"> 
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:0px;			left:<%=[expr $base*1.5 + 4]%>px;	width:@w@px; height:@h@px;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:@hyp@px;			left:0px;				width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:@hyp@px;			left:<%=[expr $base*3 + 8]%>px;		width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/blue-100.png" 
style="position:absolute;	top:<%=[expr $hyp*2.0]%>px;	left:<%=[expr $base*1.5 + 4]%>px;	width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:<%=[expr $hyp*3.0]%>px;	left:0px;				width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:<%=[expr $hyp*3.0]%>px;	left:<%=[expr $base*3 + 8]%>px;		width:@w@px; height:@h@px; border:none;"/>
<img src="/intranet-sysconfig/images/hexagon-100.png" 
style="position:absolute;	top:<%=[expr $hyp*4.0]%>px;	left:<%=[expr $base*1.5 + 4]%>px;	width:@w@px; height:@h@px; border:none;"/>
</div>
-->


<style>
div.hexagon_cell {
    display: table-cell;
    text-align: center;
    vertical-align: middle;
    font-size: 18px;
}
</style>

<div style="position:relative; height:400px; width:600px;"> 



<div style="position:absolute;	top:@y0@px; left:@x1@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">Collabo-<br>ration</div>
</div>

<div style="position:absolute;	top:@y1@px; left:@x0@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">CRM</div>
</div>

<div style="position:absolute;	top:@y1@px; left:@x2@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">ITSM</div>
</div>

<div style="position:absolute;	top:@y2@px; left:@x1@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('/intranet-sysconfig/images/blue-100.png'); display: table;"/>
<div class="hexagon_cell">PM</div>
</div>

<div style="position:absolute;	top:@y3@px; left:@x0@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">PPM</div>
</div>

<div style="position:absolute;	top:@y3@px; left:@x2@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">Agile<br>PM</div>
</div>

<div style="position:absolute;	top:@y4@px; left:@x1@px; width:@w@px; height:@h@px; background-size: cover; background-image: url('@bg100@'); display: table;"/>
<div class="hexagon_cell">Finance</div>
</div>


</div>



<!--
<ul>
<li>height <%= [expr $h] %>
<li>base=  <%= [expr $base] %>
<li>hyp=   <%= [expr $hyp] %>
<li>expr $base*1.5 = <%= [expr $base*1.5] %>
</ul>
-->
