<?xml version="1.0" encoding="UTF-8"?>

<!--
	
	This source file is part of XBiG
	(XSLT Bindings Generator)
	For the latest info, see http://sourceforge.net/projects/javaglue
	
	Copyright (c) 2006 The XBiG Development Team
	Also see acknowledgements in Readme.html
	
	This program is free software; you can redistribute it and/or modify it under
	the terms of the GNU Lesser General Public License as published by the Free Software
	Foundation; either version 2 of the License, or (at your option) any later
	version.
	
	This program is distributed in the hope that it will be useful, but WITHOUT
	ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
	FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
	
	You should have received a copy of the GNU Lesser General Public License along with
	this program; if not, write to the Free Software Foundation, Inc., 59 Temple
	Place - Suite 330, Boston, MA 02111-1307, USA, or go to
	http://www.gnu.org/copyleft/lesser.txt.
	
	Author: Frank Bielig
	Christoph Nenning
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:str="http://exslt.org/strings"
	xmlns:java="java:org.javaglue.xsltext.XsltExt" 
	extension-element-prefixes="java">


	<xsl:import href="createMetaParameterElement.xslt" />
	<xsl:import href="../exslt/str.split.template.xsl" />


	<xd:doc type="stylesheet">
		<xd:short>Templates and function to handle types.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Obtains types from config. For internal usage.
		</xd:short>
		<xd:param name="root">Subtree of config.</xd:param>
		<xd:param name="param">
			parameter or method to be processed.
		</xd:param>
		<xd:param name="typeName">Fully qualified typename.</xd:param>
	</xd:doc>
	<xsl:template name="metaTypeInfo">
		<xsl:param name="root" />
		<xsl:param name="param" />
		<xsl:param name="typeName" />

		<!-- shortcut for meta type -->
		<xsl:variable name="meta_type"
			select="if($typeName) then $typeName else 'long'" />

		<!-- shortcut for param passing type -->
		<xsl:variable name="pass_type" select="$param/@passedBy" />

		<!-- shortcut for const type -->
		<xsl:variable name="const_type" select="$param/type/@const" />

		<!-- extract jni type depending on meta type, const/non-const, pass type -->


		<!-- iterator through all entries for given type -->
		<xsl:for-each select="$root/type">

			<!-- build a element which contains all types from config as children -->
			<xsl:if test="@meta eq $meta_type">
				<xsl:element name="types">
					<xsl:copy-of select="." />
				</xsl:element>
			</xsl:if>

		</xsl:for-each>

	</xsl:template>


	<xd:doc type="template">
		<xd:short>
			Returns first type found in config. Does not care about
			PassedBy or const.
		</xd:short>
		<xd:param name="root">Subtree of config.</xd:param>
		<xd:param name="param">
			parameter or method to be processed.
		</xd:param>
		<xd:param name="typeName">Fully qualified typename.</xd:param>
	</xd:doc>
	<xsl:template name="metaFirstTypeInfo">
		<xsl:param name="root" />
		<xsl:param name="param" />
		<xsl:param name="typeName" />

		<!-- calculate all suitable type informations -->
		<xsl:variable name="type_infos">
			<xsl:call-template name="metaTypeInfo">
				<xsl:with-param name="root" select="$root" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$typeName" />
			</xsl:call-template>
		</xsl:variable>

		<!-- ensure valid signature -->
		<xsl:if test="count($type_infos) = 0">
			<xsl:message terminate="yes">
				ERROR: no type info for meta type '
				<xsl:value-of select="$typeName" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- take first type info-->
		<xsl:copy-of select="$type_infos/types/type[1]" />

	</xsl:template>



	<xd:doc type="template">
		<xd:short>
			Returns type found in config. Does care about PassedBy and const.
		</xd:short>
		<xd:param name="root">Subtree of config.</xd:param>
		<xd:param name="param">
			parameter or method to be processed.
		</xd:param>
		<xd:param name="typeName">Fully qualified typename.</xd:param>
	</xd:doc>
	<xsl:template name="metaExactTypeInfo">
		<xsl:param name="root" />
		<xsl:param name="param" />
		<xsl:param name="typeName" />

		<!-- calculate all suitable type informations -->
		<xsl:variable name="type_infos">
			<xsl:call-template name="metaTypeInfo">
				<xsl:with-param name="root" select="$root" />
				<xsl:with-param name="param" select="$param" />
				<xsl:with-param name="typeName" select="$typeName" />
			</xsl:call-template>
		</xsl:variable>

		<!-- ensure valid signature -->
		<xsl:if test="count($type_infos) = 0">
			<xsl:message terminate="yes">
				ERROR: no type info for meta type '
				<xsl:value-of select="$typeName" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- find exact type info-->
		<xsl:for-each select="$type_infos/types/type">

			<xsl:choose>

				<!-- when passed by value, the pass attribute is missing in config.xml -->
				<xsl:when
					test="not(@pass)
					      and $param/@passedBy eq 'value'">
					<xsl:copy-of select="." />
				</xsl:when>
				
				<!-- if pass is declared in config and const not and param is not const -->
				<xsl:when test="@pass eq 'pointer'
				                and $param/@passedBy eq 'pointer'">
					<xsl:copy-of select="." />
				</xsl:when>
				
				<!-- if pass is declared in config and const not and param is not const -->
				<xsl:when test="@pass eq $param/@passedBy
								and not(@const)
				                and not(xbig:isTypeConst($param))">
					<xsl:copy-of select="." />
				</xsl:when>
				
				<!-- if pass and const is declared in config -->
				<xsl:when test="@pass eq $param/@passedBy
				                and @const eq xbig:isTypeConst($param)">
					<xsl:copy-of select="." />
				</xsl:when>

				<!-- if pass is declared in config and passby is const (see bug 1712709) -->
				<xsl:when test="@pass eq $param/@passedBy
				                and xbig:isTypeConst($param)">
					<xsl:copy-of select="." />
				</xsl:when>

			</xsl:choose>
		</xsl:for-each>

	</xsl:template>



	<xd:doc type="function">
		<xd:short>Checks if a type is an enum.</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isEnum" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//enumeration[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>Checks if a string is an enum constant.</xd:short>
		<xd:param name="type">
			String to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isEnumConstant" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//enum[@name = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>Returns enum type for an enum constant.</xd:short>
		<xd:param name="enumConstant">
			Enum constant to find type for.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getEnumTypeForEnumConstant" as="xs:string">
		<xsl:param name="enumConstant" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$enumConstant" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//enum[@name = $fullName])">
				<xsl:value-of select="$inputTreeRoot//enum[@name = $fullName]/../@fullName" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$fullName" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>Checks if a type is a typedef.</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isTypedef" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//typedef[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>Checks if a type is a class.</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isClass" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//class[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>

			<!-- typedef for template with inner class -->
			<xsl:when test="boolean($currentNode/typeparameters)">
				<!-- TODO make this general, to handle multiple levels of inner inner classes -->
				<xsl:variable name="originalTemplateNode">
					<xsl:copy-of
						select="$inputTreeRoot//*
												[@fullName = $currentNode/@originalTemplateFullName]" />
				</xsl:variable>
				<xsl:choose>
					<xsl:when
						test="boolean($originalTemplateNode/*/@name = substring-after($type, '::'))">
						<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>Checks if a type is a struct.</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isStruct" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//struct[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>

			<!-- typedef for template with inner class -->
			<xsl:when test="boolean($currentNode/typeparameters)">
				<!-- TODO make this general, to handle multiple levels of inner inner classes -->
				<xsl:variable name="originalTemplateNode">
					<xsl:copy-of
						select="$inputTreeRoot//*
												[@fullName = $currentNode/@originalTemplateFullName]" />
				</xsl:variable>
				<xsl:choose>
					<xsl:when
						test="boolean($originalTemplateNode/*/@name = substring-after($type, '::'))">
						<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Checks if a type is a class or a struct. These are handled
			equal.
		</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isClassOrStruct" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />

		<xsl:choose>
			<xsl:when
				test="boolean($inputTreeRoot//class[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:when
				test="boolean($inputTreeRoot//struct[@fullName = $fullName])">
				<xsl:value-of select="true()" />
			</xsl:when>

			<!-- typedef for template with inner class -->
			<xsl:when test="boolean($currentNode/typeparameters)">
				<!-- TODO make this general, to handle multiple levels of inner inner classes -->
				<xsl:variable name="originalTemplateNode">
					<xsl:copy-of
						select="$inputTreeRoot//*
												[@fullName = $currentNode/@originalTemplateFullName]" />
				</xsl:variable>
				<xsl:choose>
					<xsl:when
						test="boolean($originalTemplateNode/*/@name = substring-after($type, '::'))">
						<xsl:value-of select="true()" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="false()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Checks if a type is a typedef for a template.
		</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isTemplateTypedef" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName" select="$type" />
		<xsl:variable name="typedefNode"
			select="$inputTreeRoot//typedef[@fullName = $fullName]" />

		<xsl:choose>
			<xsl:when test="contains($typedefNode/@basetype, '&lt;')">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Checks if a type is a template if it doesn't have type parameters.
		</xd:short>
		<xd:param name="type">
			Fully qualified type name to be checked.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isTemplate" as="xs:boolean">
		<xsl:param name="type" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="node"
			select="$inputTreeRoot//*[@fullName = $type]" />

		<xsl:choose>
			<xsl:when test="$node/@template = 'true'">
				<xsl:value-of select="true()" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Resolves full meta name of a type. It may be already complete, or contain '::'.
		</xd:short>
		<xd:param name="type">type name to be completed.</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace which contains type.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullTypeName" as="xs:string">
		<xsl:param name="type" as="xs:string" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:choose>

			<!-- if the type contains a namespace -->
			<xsl:when test="contains($type, '::')">
				<xsl:choose>

					<!-- if we have an absolute namespace path -->
					<xsl:when test="starts-with($type, '::')">
						<xsl:value-of
							select="substring-after($type, '::')" />
					</xsl:when>

					<!-- namespace path could be absolute or relative -->
					<xsl:otherwise>
						<xsl:variable name="relPathFirstPart"
							select="substring-before($type, '::')" />
						<xsl:variable name="typeContainingNodeName"
							select="xbig:getNodeNameWhichContainsType
									  ($relPathFirstPart, $currentNode, $inputTreeRoot)" />
						<xsl:variable name="typeContainingNodeDots">
							<xsl:choose>
								<xsl:when
									test="$typeContainingNodeName != ''">
									<xsl:value-of
										select="concat($typeContainingNodeName, '::')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of
										select="$typeContainingNodeName" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:value-of
							select="concat($typeContainingNodeDots, $type)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- type does not contain a namespace -->
			<xsl:otherwise>
				<xsl:variable name="typeContainingNodeName"
					select="xbig:getNodeNameWhichContainsType
							  ($type, $currentNode, $inputTreeRoot)" />
				<xsl:choose>
					<xsl:when test="$typeContainingNodeName = ''">
						<xsl:value-of select="$type" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="concat($typeContainingNodeName, '::', $type)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Finds the namespace / class / struct in which a type is declared.
		</xd:short>
		<xd:param name="type">type name to be searched.</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace to check.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getNodeNameWhichContainsType"
		as="xs:string">
		<xsl:param name="type" as="xs:string" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:choose>

			<!-- to avoid a live lock -->
			<xsl:when test="not($currentNode/..)">
				<!-- <xsl:value-of select="''" /> -->
				<xsl:sequence select="''" />
			</xsl:when>

			<!-- if found, return node -->
			<xsl:when test="$currentNode/*[@name = $type]">
				<xsl:value-of select="$currentNode/@fullName" />
			</xsl:when>

			<!-- special case: a typedef for a template -> generated meta class -> not in input tree -->
			<xsl:when test="$currentNode/typeparameters">
				<!-- TODO check if this could be made more general -->
				<xsl:variable name="originalTypedefNode"
					select="$inputTreeRoot//*[@fullName = $currentNode/@originalTypedefFullName]" />
				<xsl:choose>
					<!-- if found, return node -->
					<xsl:when
						test="$originalTypedefNode/*[@name = $type]">
						<xsl:value-of
							select="$originalTypedefNode/@fullName" />
					</xsl:when>
					<!-- else check the parent node -->
					<xsl:otherwise>
						<xsl:value-of
							select="xbig:getNodeNameWhichContainsType
											  ($type, $originalTypedefNode/.., $inputTreeRoot)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- else if the current node is the root return an empty string -->
			<xsl:when test="$inputTreeRoot is $currentNode">
				<xsl:sequence select="''" />
			</xsl:when>

			<!-- check if type is defined in a baseclass -->
			<xsl:when test="boolean($currentNode/inherits) eq true()">
				<xsl:variable name="baseClassResults">
					<xsl:for-each
						select="$currentNode/inherits/baseClass">
						<xsl:element name="result">
							<xsl:variable name="baseClassNode"
								select="$inputTreeRoot//*[@fullName = current()/@fullBaseClassName]" />
							<xsl:value-of
								select="xbig:getNodeNameWhichContainsType
											  ($type, $baseClassNode, $inputTreeRoot)" />
						</xsl:element>
					</xsl:for-each>
				</xsl:variable>

				<!-- check if type was found in a base class -->
				<xsl:choose>
					<!-- see bugs 1711313 and 1724323 -->
					<!-- if type was found in 1 base class -->
					<xsl:when
						test="$baseClassResults/*[text() != ''] and 
							count($baseClassResults/*[text() != '']) = 1">
						<xsl:value-of
							select="$baseClassResults/*[text() != '']" />
					</xsl:when>

					<!-- if type was found in more than one base classes -->
					<!-- TODO check if the results differ and choose the right one -->
					<xsl:when test="count($baseClassResults/*[text() != '']) > 1">
						<xsl:value-of
							select="$baseClassResults/*[1]" />
					</xsl:when>

					<!-- else check the parent node -->
					<xsl:otherwise>
						<xsl:value-of
							select="xbig:getNodeNameWhichContainsType
									  ($type, $currentNode/.., $inputTreeRoot)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- else check the parent node -->
			<xsl:otherwise>
				<xsl:value-of
					select="xbig:getNodeNameWhichContainsType
									  ($type, $currentNode/.., $inputTreeRoot)" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Resolves a typedef. Finds out full name of passed type
			and returns full name of resolved type.
		</xd:short>
		<xd:param name="type">type name to be resolved.</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace to check. Usually node that contains type in a method.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:resolveTypedef" as="xs:string">
		<xsl:param name="type" as="xs:string" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<xsl:variable name="fullName"
			select="xbig:getFullTypeName($type, $currentNode, $inputTreeRoot)" />

		<xsl:choose>
			<xsl:when
				test="xbig:isTypedef($fullName, $currentNode, $inputTreeRoot)">
				<xsl:variable name="typedefNode" select="$inputTreeRoot//typedef[@fullName eq $fullName]" />

				<xsl:choose>
					<!-- if this is a typedef for a template, there is a class -->
					<xsl:when test="contains($typedefNode/@basetype, '&lt;')">
						<xsl:value-of select="$fullName" />
					</xsl:when>

					<xsl:otherwise>
						<xsl:value-of
							select="xbig:resolveTypedef(
										$typedefNode/@basetype, $typedefNode/.., $inputTreeRoot)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$fullName" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Finds full name of a template and for all of it's parameters.
			Adds type modifiers like 'const' or '*' to type parameters.
		</xd:short>
		<xd:param name="type">type name to be resolved. Contains unresolved type parameters.</xd:param>
		<xd:param name="currentNode">
			Meta class, struct or namespace to check. Usually node that contains type in a method.
		</xd:param>
		<xd:param name="inputTreeRoot">
			Root of input tree. Usually selected with '/'.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:getFullTemplateName" as="xs:string">
		<xsl:param name="type" as="xs:string" />
		<xsl:param name="currentNode" />
		<xsl:param name="inputTreeRoot" />

		<!-- get fullname of the template itself (the A in A<B>) -->
		<xsl:variable name="templateBaseType">
			<xsl:value-of
				select="xbig:getFullTypeName(normalize-space(substring-before($type, '&lt;'))
									, $currentNode, $inputTreeRoot)" />
		</xsl:variable>

		<!-- handle type parameters -->
		<xsl:variable name="templateBracket">
			<xsl:variable name="insideBracketResolved">

				<!-- get list of type parameters -->
				<xsl:variable name="tokens">
				 	<xsl:call-template name="xbig:getListOfTypeParameters">
						<xsl:with-param name="type" select="$type" />
					</xsl:call-template>
				</xsl:variable>

				<!-- iterate through type parameters -->
				<xsl:for-each select="$tokens/*">
					<xsl:variable name="normalizedToken"
						select="normalize-space(.)" />

					<!-- check for const and ptr -->
					<xsl:variable name="paraElement">
						<xsl:call-template name="createMetaParameterElement">
							<xsl:with-param name="type" select="$normalizedToken" />
						</xsl:call-template>
					</xsl:variable>

					<xsl:variable name="const" select="if 
											($paraElement/*[1]/type/@const eq 'true') 
											then 'const ' else ''"/>
					<xsl:variable name="passedBy" select="if 
											($paraElement/*[1]/@passedBy eq 'value') 
											then ''
											else if($paraElement/*[1]/@passedBy eq 'reference')
											then '&amp;'
											else '*'"/>

					<xsl:variable name="resolvedToken">
						<xsl:choose>
							<xsl:when test="contains(., '&lt;')">
								<xsl:value-of select="xbig:getFullTemplateName($paraElement/*[1]/type,
																	$currentNode, $inputTreeRoot)" />
							</xsl:when>
							<xsl:otherwise>
								 <xsl:value-of select="xbig:resolveTypedef($paraElement/*[1]/type,
																	$currentNode, $inputTreeRoot)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<xsl:value-of select="concat($const, $resolvedToken, $passedBy)" />

					<xsl:if test="position() != last()">
						<xsl:value-of select="', '" />
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:value-of
				select="concat('&lt; ', $insideBracketResolved, ' &gt;')" />
		</xsl:variable>

		<!-- return -->
		<xsl:value-of
			select="concat($templateBaseType, $templateBracket)" />
	</xsl:function>



	<xd:doc type="template">
		<xd:short>
			Takes a type containing type parameters. Returns a list of it's parameters.
			Does not fully qualify them.
			E.g. std::vector &lt; std::pair &lt; String, String &gt; &gt; 
			becomes std::pair &lt; String, String &gt;.
			or
			std::map &lt; String, A &gt; becomes String and A.
		</xd:short>
		<xd:param name="type">type name to be resolved. Contains unresolved type parameters.</xd:param>
	</xd:doc>
	<xsl:template name="xbig:getListOfTypeParameters">
		<xsl:param name="type" as="xs:string" />

		<xsl:variable name="bracket"
			select="substring-after($type, '&lt;')" />
		<xsl:variable name="insideBracket">
			<xsl:for-each select="tokenize($bracket, '&gt;')[position() != last()]">
				<xsl:value-of select="."/>
				<xsl:if test="position() != last()">
					<xsl:value-of select="' &gt;'"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>

		<xsl:choose>
			<!-- easiest case: no further templates as type parameters -->
			<xsl:when test="not(contains($insideBracket, '&lt;'))">
				<xsl:for-each select="tokenize($insideBracket, ',')">
					<xsl:element name="typeParameter">
						<xsl:sequence select="normalize-space(.)"/>
					</xsl:element>
				</xsl:for-each>
			</xsl:when>

			<!-- templates as type parameters: ',' could be inside one type parameter -->
			<xsl:otherwise>

				<xsl:call-template name="xbig:parseTemplateContainingTypeParameters">
					<xsl:with-param name="remainingString" select="$insideBracket" />
				</xsl:call-template>

			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>



	<xd:doc type="template">
		<xd:short>
			Takes care of templates as type parameters, 
			to be called by xbig:getListOfTypeParameters only!
		</xd:short>
		<xd:param name="remainingString">Unprocessed part of type parameter string.</xd:param>
	</xd:doc>
	<xsl:template name="xbig:parseTemplateContainingTypeParameters">
		<xsl:param name="remainingString" as="xs:string" />

		<xsl:choose>
			<!-- recursion end on part after last ',' -->
			<xsl:when test="not(contains($remainingString, ','))">
				<xsl:element name="typeParameter">
					<xsl:sequence select="normalize-space($remainingString)"/>
				</xsl:element>
			</xsl:when>

			<!-- template as type parameter -->
			<xsl:when test="contains(substring-before($remainingString, ','), '&lt;')">
				<xsl:variable name="tokensByComma">
					<xsl:for-each select="tokenize($remainingString, ',')">
						<xsl:element name="token">
							<xsl:sequence select="normalize-space(.)"/>
						</xsl:element>
					</xsl:for-each>
				</xsl:variable>

				<xsl:choose>
					<!-- type parameter is a template and has only one parameter itself -->
					<xsl:when test="java:countOccurrencesInString($tokensByComma/*[1], '&lt;') = 
									 java:countOccurrencesInString($tokensByComma/*[1], '&gt;')">
						<xsl:element name="token">
							<xsl:sequence select="$tokensByComma/*[1]"/>
						</xsl:element>
						<xsl:call-template name="xbig:parseTemplateContainingTypeParameters">
							<xsl:with-param name="remainingString" 
								select="normalize-space(substring-after($remainingString, ','))" />
						</xsl:call-template>
					</xsl:when>

					<!-- type parameter is a template and has more than one parameter itself -->
					<xsl:otherwise>
						<xsl:call-template name="xbig:compareTokensByCommaWithLessThan">
							<xsl:with-param name="firstString" select="$tokensByComma/*[1]" />
							<xsl:with-param name="tokensByComma" select="$tokensByComma" />
							<xsl:with-param name="tokenToCompare" select="2" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<!-- no template as type parameter -->
			<xsl:otherwise>
				<xsl:element name="typeParameter">
					<xsl:sequence select="normalize-space(substring-before($remainingString, ','))"/>
				</xsl:element>
				<xsl:call-template name="xbig:parseTemplateContainingTypeParameters">
					<xsl:with-param name="remainingString" 
						select="normalize-space(substring-after($remainingString, ','))" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>



	<xd:doc type="template">
		<xd:short>
			Takes care of templates as type parameters which have more than one parameter themselfs, 
			to be called by xbig:parseTemplateContainingTypeParameters only!
		</xd:short>
		<xd:param name="firstString">Part of type parameter string before a ','.</xd:param>
		<xd:param name="tokensByComma">List of type parameter string parts splitted by ','.</xd:param>
		<xd:param name="tokenToCompare">Number of part to compare firstString to.</xd:param>
	</xd:doc>
	<xsl:template name="xbig:compareTokensByCommaWithLessThan">
		<xsl:param name="firstString" as="xs:string"/>
		<xsl:param name="tokensByComma"/>
		<xsl:param name="tokenToCompare" as="xs:integer"/>

			<xsl:choose>
				<!-- found corresponding token -->
				<xsl:when test="(java:countOccurrencesInString($firstString, '&lt;') + 
								 java:countOccurrencesInString($tokensByComma/*[$tokenToCompare], '&lt;')
								) -
								(java:countOccurrencesInString($firstString, '&gt;') + 
								 java:countOccurrencesInString($tokensByComma/*[$tokenToCompare], '&gt;')
								)
								= 0">
					<xsl:element  name="typeParameter">
						<xsl:sequence
							select="concat($firstString, ',', $tokensByComma/*[$tokenToCompare])"/>
					</xsl:element>

					<!-- next recursion step ('outer loop') -->
					<xsl:choose>
						<xsl:when test="count($tokensByComma/*) &gt;= $tokenToCompare+2">
							<xsl:call-template name="xbig:parseTemplateContainingTypeParameters">
								<xsl:with-param name="remainingString" select="
									xbig:rebuildRemainingStringFromTokens(
									$tokensByComma/*[$tokenToCompare+1],
									$tokensByComma, $tokenToCompare+2)" />
							</xsl:call-template>
						</xsl:when>
						<xsl:when test="count($tokensByComma/*) &gt;= $tokenToCompare+1">
							<xsl:call-template name="xbig:parseTemplateContainingTypeParameters">
								<xsl:with-param name="remainingString"
									select="$tokensByComma/*[$tokenToCompare+1]" />
							</xsl:call-template>
						</xsl:when>
						<xsl:otherwise>
							<!-- nothing, string already fully parsed -->
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>

				<!-- recursion end ('inner loop') -->
				<xsl:when test="count($tokensByComma/*) &lt; $tokenToCompare">
					<xsl:variable name="rebuildRemainingString" select="
						xbig:rebuildRemainingStringFromTokens($tokensByComma/*[1], $tokensByComma, 2)"/>
					<xsl:message>ERROR parsing template parameter string: <xsl:value-of select="$rebuildRemainingString"/>!</xsl:message>
					<xsl:element name="typeParameter">
						<xsl:sequence select="$rebuildRemainingString"/>
					</xsl:element>
				</xsl:when>

				<!-- check next token (recursion of 'inner loop') -->
				<xsl:otherwise>
					<xsl:call-template name="xbig:compareTokensByCommaWithLessThan">
						<xsl:with-param name="firstString"
							select="concat($firstString, $tokensByComma/*[$tokenToCompare])" />
						<xsl:with-param name="tokensByComma" select="$tokensByComma" />
						<xsl:with-param name="tokenToCompare" select="$tokenToCompare+1" />
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>

	</xsl:template>



	<xd:doc type="template">
		<xd:short>
			Builds rest of a type parameter string from tokens which has been splitted by ',', 
			to be called by xbig:compareTokensByCommaWithLessThan only!
		</xd:short>
		<xd:param name="baseString">Part of type parameter string after a complete parameter.</xd:param>
		<xd:param name="tokensByComma">List of type parameter string parts splitted by ','.</xd:param>
		<xd:param name="tokenToStartAt">Number of part to concat to baseString.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:rebuildRemainingStringFromTokens" as="xs:string">
		<xsl:param name="baseString" as="xs:string"/>
		<xsl:param name="tokensByComma"/>
		<xsl:param name="tokenToStartAt" as="xs:integer"/>

		<xsl:choose>
			<xsl:when test="count($tokensByComma) &gt; $tokenToStartAt">
				<xsl:sequence select="xbig:rebuildRemainingStringFromTokens(concat(
					$baseString, ',', $tokensByComma/*[$tokenToStartAt]),
					$tokensByComma, $tokenToStartAt+1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="concat($baseString, ',', $tokensByComma/*[$tokenToStartAt])"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>



	<xd:doc type="function">
		<xd:short>Helper function to check if a param or return value is const. Return <b>true</b> if param const, otherwise false.</xd:short>
		<xd:param name="param">The parameter to check.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:isTypeConst">
		<xsl:param name="param"/>
		<xsl:choose>
		<xsl:when test="$param/type/@const eq 'true'">
			<xsl:sequence select="true()"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:sequence select="false()"/>
		</xsl:otherwise>
		</xsl:choose>
	</xsl:function>


	<xd:doc type="function">
		<xd:short>
			Returns a string representing a C++ namespace.
		</xd:short>
		<xd:detail>
			Doxygen option INLINE_INHERITED_MEMB causes inherited typedefs to appear
			nearly as normal ones. This function is needed to find out if a typedef is
			defined in this class or in a base class. Typedefs from base classes shall not
			be included in meta.xml.
			Used for other things where a full name must be split up, too.
		</xd:detail>
		<xd:param name="baseString">
			String to add '::' and next token. Should be '' (empty string) at first call.
		</xd:param>
		<xd:param name="tokens">
			Tokens to add to string. The last one will be ignored.
		</xd:param>
		<xd:param name="position">
			Position of token to add. Should be 1 at first call.
		</xd:param>
	</xd:doc>	
	<xsl:function name="xbig:buildNamespaceNameTypeIsDefinedIn" as="xs:string">
		<xsl:param name="baseString" as="xs:string" />
		<xsl:param name="tokens" />
		<xsl:param name="position" as="xs:integer" />

		<xsl:variable name="currentToken" select="if(contains($tokens[$position], '&lt;'))
								then normalize-space(substring-before($tokens[$position], '&lt;'))
								else $tokens[$position]"/>

		<xsl:choose>
			<xsl:when test="$position = 1">
				<xsl:sequence select="xbig:buildNamespaceNameTypeIsDefinedIn(
							concat($baseString, $currentToken), $tokens, $position + 1)"/>
			</xsl:when>
			<xsl:when test="$position &lt; count($tokens)">
				<xsl:sequence select="xbig:buildNamespaceNameTypeIsDefinedIn(
							concat($baseString, '::', $currentToken), $tokens, $position + 1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="$baseString"/>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>



</xsl:stylesheet>
