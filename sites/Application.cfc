<cfcomponent extends="application_proxy">
	<!--- this is probably not interactive, no stores, no deals, but press releases are not uncommon, no ifeatures, no op messages, etc. --->

	<cfset this.SessionManagement = false />
	<cfoutput>
		<h2>#getCurrentTemplatePath()#</h2>
	</cfoutput>

</cfcomponent>


