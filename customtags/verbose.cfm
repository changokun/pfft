<cfif not thisTag.hasEndTag>
	<cfthrow message="verbose out put must be wrapped or self closing? <you know: />">
</cfif>
<cfif thisTag.executionMode eq 'start'>
	<!--- the tag is beginning. should we waste our time on it? --->
	<cfif not isDefined('url.verbose')>
		<cfexit method="exittag">
	</cfif>
	<!--- it may be of an obscure nature. --->
	<cfparam name="attributes.type" default="any">
	<cfparam name="attributes.level" default="42">
	<cfif attributes.type neq 'any'>
		<!--- for output, url.verbose needs to specify a type and level. --->
		<cfif attributes.type does not contain url.verbose>
			<cfexit method="exittag">
		</cfif>
	</cfif>
	<!--- starting a timer, for fun. assuming we cannot nest these. --->
	<cfset thisTag['cf_verbose_start_tick_count'] = getTickCount()>

	<!--- maybe we need to eval? for sure we need to stop blocking output. --->

<cfelse>

	<!--- closing the tag up - we do dumps and what not here, so that inline stuff will appear above and sort of be labels. --->
	<cfparam name="attributes.expand" default="true">
	<cfset thisTag['label'] = arrayNew(1)>
	<cfset thisTag['label_base'] = ''>
	<cfset thisTag['caller'] = 'an unknown caller'>
	<cfif structKeyExists(attributes, 'label')>
		<cfset thisTag['label_base'] = attributes.label>
	</cfif>
	<cfif structKeyExists(caller, 'this') and isObject(caller.this)>
		<cfset thisTag.caller = getMetaData(caller.this).name>
	</cfif>

	<cfloop collection="#attributes#" item="key">
		<cfswitch expression="#key#">
			<cfcase value="level,type,label,expand">
				<!--- skip output on these control vars --->
			</cfcase>
			<cfcase value="form,url">
				<!--- if you pass the name of a known scope as an attribute, it will get dumped. the value of the attribute will become the label, but you can also omit. --->
				<cfset thisTag.label = arrayNew(1)>
				<cfset arrayAppend(thisTag.label, thisTag.label_base)>
				<cfset arrayAppend(thisTag.label, attributes[key])>
				<cfset arrayAppend(thisTag.label, uCase(key & ' scope'))>
				<cfset arrayAppend(thisTag.label, 'verbose output called by ' & thisTag.caller)>
				<cfdump var="#evaluate(key)#" label="#arrayToList(thisTag.label, ' | ')#" expand="#attributes.expand#">
			</cfcase>
			<cfdefaultcase>
				<cfset thisTag.label = arrayNew(1)>
				<cfset arrayAppend(thisTag.label, thisTag.label_base)>
				<cfset arrayAppend(thisTag.label, key)>
				<cfset arrayAppend(thisTag.label, 'verbose output called by ' & thisTag.caller)>
				<cfif isSimpleValue(attributes[key])>
					<cfoutput>
						<div style="padding:2px; border:1px solid grey;">#arrayToList(thisTag.label, ' | ')#: #attributes[key]#</div>
					</cfoutput>
				<cfelse>
					<cfdump var="#attributes[key]#" label="#arrayToList(thisTag.label, ' | ')#" expand="#attributes.expand#">
				</cfif>
			</cfdefaultcase>
		</cfswitch>
	</cfloop>

	<cfset thisTag.generatedContent = trim(thisTag.generatedContent)>

	<cfset elapsed_ms = 0>
	<cfset timer_phrase = ''>
	<cfif structKeyExists(thisTag, "cf_verbose_start_tick_count")>
		<cfset elapsed_ms = getTickCount() - thisTag.cf_verbose_start_tick_count>
	</cfif>
	<cfif elapsed_ms gt 9>
		<cfset timer_phrase = "This verbose block took #elapsed_ms# ms to generate!">
	</cfif>

	<cfif isDefined('url.verbose') and url.verbose eq 'inline'>
		<cfif len(thisTag.generatedContent)>
			<cfset thisTag.generatedContent = '<div style="border:1px solid darkGrey; background-color:grey; color:white; padding:3px; margin:2px; font-family:arial; font-size:12px">#thisTag.generatedContent#'>
			<cfif len(timer_phrase)>
				<cfset thisTag.generatedContent &= ' <span style="font-size:10px; text-transform:uppercase">#timer_phrase#</span>'>
			</cfif>
			<cfset thisTag.generatedContent &= '</div>'>
		<cfelse>
			<cfif elapsed_ms gt 0>
				<cfset thisTag.generatedContent = '<!-- a verbose tag produced no output iand took #elapsed_ms# ms to do it (#structKeyList(attributes)#). -->'>
			<cfelse>
				<cfset thisTag.generatedContent = '<!-- a verbose tag produced no output in no time at all (#structKeyList(attributes)#). -->'>
			</cfif>
		</cfif>
	<cfelse>
		<cfif len(thisTag.generatedContent)>
			<cfset thisTag.generatedContent = '<!-- #thisTag.generatedContent#'>
			<cfif len(timer_phrase)>
				<cfset thisTag.generatedContent &= ' (#timer_phrase#)'>
			</cfif>
			<cfset thisTag.generatedContent &= ' -->'>
		<cfelse>
			<cfset thisTag.generatedContent = '<!-- a verbose tag produced no output -->'>
		</cfif>
	</cfif>
	
	<cfset thisTag.generatedContent = '#chr(10)##thisTag.generatedContent##chr(10)#'>
</cfif>

