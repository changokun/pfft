<cfcomponent extends="sites.Application">
	<!--- having an applicaiton.cfc for the site itself is optional. not sure what we would change in here. --->
	<!--- maybe turn off sessions and what not --->
	<cfset this.name='fairhope'>
	<cfset this.clien_name='kutzy'>

	<cfoutput>
		<h2>#getCurrentTemplatePath()#</h2>
	</cfoutput>
</cfcomponent>
