
system.
<h3><cfoutput>#timeFormat(now(), 'long')# #dateFormat(now(), 'long')#</cfoutput></h3>

<cfdump var="#server#" label="SERVER" expand="false">
<cfdump var="#application#" label="this.clien_name">

<!--- this is an interesting way to get into some server admin stuffffffff 
<cfinvoke component="CFIDE.adminapi.administrator" method="login" adminpassword="XXXXX" returnVariable="result">
<cfinvoke component="CFIDE.adminapi.servermonitoring" method="getAllApplicationScopesMemoryUsed" returnVariable="ascopes">
<cfdump var="#ascopes#" label="ascopes">--->

