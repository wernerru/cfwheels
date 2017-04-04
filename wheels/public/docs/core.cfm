<cfscript>
// Core API embedded documentation

	param name="params.type" default="core";
	param name="params.format" default="html";

	docs={
		"sections"=[],
		"functions"=[]
	}; 

	// Array/Loop order is important: 
	temp=[
		{
			"name": "controller",
			"scope": createObject("component", "app.controllers.Controller") 
		},
		{
			"name": "model",
			"scope": createObject("component", "app.models.Model") 
		},
		{
			"name": "mapper",
			"scope": application.wheels.mapper 
		},
		{
			"name": "migrator",
			"scope": application.wheels.dbmigrate  
		}
	];
	 
	// Array of functions to ignore
	ignore = ["init"];

	// Merge
	for(doctype in temp){
		doctype["functions"]=listSort(StructKeyList(doctype.scope), "textnocase");
		// Populate A-Z function List
		for(local.functionName in listToArray(doctype.functions) ){

			// Check this is actually a function: dbmigrate stores a struct for instance
			// Don't display internal functions, duplicates or anything in the ignore list
			if(left(local.functionName, 1) != "$"
				&& !ArrayFindNoCase(ignore, local.functionName)
				&& !isStruct(doctype.scope[local.functionName])
			){
				// Get metadata
				local.meta=$parseMetaData(GetMetaData(doctype.scope[local.functionName]), doctype.name, local.functionName);
				local.hint=local.meta.hint;

				// Look for identically named functions: just looking for name isn't enough, we need to compare the hint too 
				local.match=arrayFind(docs.functions, function(struct){
					return (struct.name == functionName && struct.hint == hint);
				});

				if(local.match){ 
					arrayAppend(docs.functions[local.match]["availableIn"], doctype.name);
				} else {
					arrayAppend(docs.functions, local.meta);  
				} 
			}
		}
		docs.functions = $arrayOfStructsSort(docs.functions, "name");
	}
	 
	// Look for section & category:
	for(doc in docs.functions){
		if(structKeyExists(doc.tags, "section") && len(doc.tags.section)){
			if( !ArrayFind(docs.sections, function(struct){
				   return struct.name == doc.tags.section;
			})){
				arrayAppend(docs.sections, {
					"name": doc.tags.section,
					"categories": []
				});
			}
			for(subsection in docs.sections){
				if(subsection.name == doc.tags.section
					&& len(doc.tags.category)
					&& !arrayFind(subsection.categories, doc.tags.category)){
						arrayAppend(subsection.categories, doc.tags.category);
				}
				arraySort(subsection.categories, "textnocase");
			}
		}
	}
	docs.sections = $arrayOfStructsSort(docs.sections, "name");

	include "layouts/#params.format#.cfm";
</cfscript>
