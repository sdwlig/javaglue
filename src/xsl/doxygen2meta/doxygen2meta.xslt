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
	
	Author: Hubert Rung			<hubert.rung@netallied.de>
	Christoph Nenning
	Frank Bielig
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc" 
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:str="http://exslt.org/strings"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:java="java:org.javaglue.xsltext.XsltExt" 
	extension-element-prefixes="java">

	<xsl:import href="../util/metaTypeInfo.xslt" />
	<xsl:import href="../exslt/str.split.template.xsl" />

	<xd:doc type="stylesheet">
		<xd:author>Hubert Rung</xd:author>
		<xd:copyright>netAllied GmbH</xd:copyright>
		<xd:short>
			Transforms the Doxygen output to better readable meta layer.
		</xd:short>
		<xd:detail>
			This Stylesheet generates a XML file from the Doxygen
			output.
			<br />
			The XML file contains all informations of the source
			library.
			<br />
			In a second step this XML file can be used to generate
			wrappers for the library.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:output method="xml" version="1.0" encoding="iso-8859-1"
		indent="yes" />


	<!-- global Parameters -->
	<xd:doc>
		File in meta format which contains additional classes. Per
		default, it contains the C++ STL
	</xd:doc>
	<xsl:param name="externalTypes" />
	<xd:doc>config.xml file.</xd:doc>
	<xsl:param name="config" />

	<!-- ############################## MAIN - calls namespace ############################## -->
	<xd:doc>
		<xd:short>Generate the root node of the XML file.</xd:short>
		<xd:detail>
			Calls template
			<b>namespace</b>
			for every namespace compound in the Doxygen output.
			<br />
			Generates a
			<code>libraryfile</code>
			element for each header file of the source library. These
			file names will be used to include them in the precompiled
			header file
			<b>Precompiled.h</b>
			.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:template match="/">
		<xsl:element name="meta"
			namespace="http://javaglue.sourceforge.net/XBiG">
			<xsl:attribute name="schemaLocation" select="'http://javaglue.sourceforge.net/XBiG http://xbig.sourceforge.net/XMLSchema/xsd/meta.xsd'"/>

			<xsl:element name="namespace">
				<xsl:attribute name="name" select="''" />
				<xsl:attribute name="fullName" select="''" />
				<xsl:for-each
					select="doxygen/compounddef[@kind='namespace']">
					<!-- because doxygen has a flat structure -->
					<xsl:choose>
						<xsl:when
							test="not(root()//compounddef
									[@kind='namespace']/innernamespace/@refid = @id)">
							<xsl:call-template name="namespace" />
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<!-- classes -->
				<xsl:for-each
					select="doxygen/compounddef[@kind='class']">
					<!-- because doxygen has a flat structure -->
					<xsl:choose>
						<xsl:when
							test="not(root()//compounddef
									[@kind='class' or @kind='struct' or @kind='namespace']
									/innerclass/@refid = @id)">
							<xsl:call-template name="class">
								<xsl:with-param name="refid"
									select="@id" />
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<!-- structs -->
				<xsl:for-each
					select="doxygen/compounddef[@kind='struct']">
					<!-- because doxygen has a flat structure -->
					<xsl:choose>
						<xsl:when
							test="not(root()//compounddef
									[@kind='class' or @kind='struct' or @kind='namespace']
									/innerclass/@refid = @id)">
							<xsl:call-template name="struct">
								<xsl:with-param name="refid"
									select="@id" />
							</xsl:call-template>
						</xsl:when>
					</xsl:choose>
				</xsl:for-each>

				<!-- global typedefs -->
				<!-- <xsl:for-each select="doxygen/compounddef[@kind='typedef']"> -->
				<!-- check doxygen version -->
				<xsl:choose>
					<xsl:when
						test="/doxygen/@version='1.5.1-p1'
									or 
									(number(substring(/doxygen/@version, 3, 1)) = 5 and
									 number(substring(/doxygen/@version, 5, 1)) >= 2)
									or
									number(substring(/doxygen/@version, 3, 1)) >= 6">
						<xsl:for-each
							select="doxygen/compounddef[@kind='file']/sectiondef[@kind='typedef']">
							<xsl:call-template name="typedef" />
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each
							select="doxygen/compounddef[@kind='file']/sectiondef[@kind='']">
							<xsl:choose>
								<!-- if there are more than one entries in all.xml -->
								<xsl:when test="last() > 1">
									<xsl:if test="position() = 1">
										<xsl:call-template
											name="typedef" />
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template name="typedef" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>

				<!-- global enums -->
				<!-- <xsl:for-each select="doxygen/compounddef[@kind='enum']"> -->
				<!-- check doxygen version -->
				<xsl:choose>
					<xsl:when
						test="/doxygen/@version='1.5.1-p1'
									or 
									(number(substring(/doxygen/@version, 3, 1)) = 5 and
									 number(substring(/doxygen/@version, 5, 1)) >= 2)
									or
									number(substring(/doxygen/@version, 3, 1)) >= 6">
						<xsl:for-each
							select="doxygen/compounddef[@kind='file']/
								sectiondef[@kind='enum']/memberdef[@kind='enum']">
							<xsl:call-template name="enumeration" />
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<xsl:for-each
							select="doxygen/compounddef[@kind='file']/
								sectiondef[@kind='']/memberdef[@kind='enum']">
							<xsl:choose>
								<!-- if there are more than one entries in all.xml -->
								<xsl:when test="last() > 1">
									<xsl:if test="position() = 1">
										<xsl:call-template
											name="enumeration" />
									</xsl:if>
								</xsl:when>
								<xsl:otherwise>
									<xsl:call-template
										name="enumeration" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:for-each>
					</xsl:otherwise>
				</xsl:choose>

				<!-- global functions -->
				<!-- <xsl:for-each select="doxygen/compounddef[@kind='func']"> -->
				<!--<xsl:for-each
					select="doxygen/compounddef[@kind='file']/sectiondef[@kind='func']">
					<xsl:if test="not(memberdef/templateparamlist)">
						<xsl:call-template name="function" />
					</xsl:if>
				</xsl:for-each>-->

				<!-- variables in the global namespace -->
				<!-- create unique list of variables because of a bug in doxygen -->
				<!--<xsl:variable name="unique-variable-list"
					select="doxygen/compounddef[@kind='file']/sectiondef[@kind='']/memberdef[@kind='variable']/definition[not(.=following::definition)]/.." />
				<xsl:for-each select="$unique-variable-list">
					<xsl:call-template name="variable" />
				</xsl:for-each>-->

				<!-- global functions and variables with no namespace-->
				<xsl:if test="count(doxygen/compounddef[@kind='file']/
								sectiondef[@kind='func']/memberdef[@kind='function']) > 0
								or count(doxygen/compounddef[@kind='file']/
								sectiondef[@kind='var']/memberdef[@kind='variable']) > 0">
					<xsl:call-template name="globalUtility" />
				</xsl:if>
				
				<!-- external types, like C++ STL -->
				<xsl:for-each
					select="$externalTypes/external/types/*">
					<xsl:copy-of select="." />
				</xsl:for-each>

			</xsl:element>

			<!-- documentation -->
			<xsl:call-template name="documentation" />

			<!-- header files of the source library -->
			<xsl:for-each select="doxygen/compounddef[@kind='file']">
				<xsl:element name="libraryfile">
					<xsl:value-of select="compoundname" />
				</xsl:element>
			</xsl:for-each>

		</xsl:element>
	</xsl:template>

	<!-- ############### NAMESPACE - calls class; globals - calls typedef, enum, function, variable ################# -->
	<!-- cursor on doxygen/compounddef -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>namespace</b>
			element for each namespace.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>name</b>
			with it's name. Inner namespaces will be seperated by
			<code>::</code>
			symbols.
			<br />
			Calls template
			<b>class</b>
			for each class of the current namespace.
			<br />
			Calls template
			<b>variable</b>
			for global variables of the current namespace.
			<br />
			Calls template
			<b>typedef</b>
			for global typedefs of the current namespace.
			<br />
			Calls template
			<b>enumeration</b>
			for global enumerations of the current namespace.
			<br />
			Calls template
			<b>function</b>
			for global functions of the current namespace.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:template name="namespace">
		<xsl:element name="namespace">

			<xsl:variable name="name">
				<xsl:variable name="nameTokens">
					<xsl:call-template name="str:split">
						<xsl:with-param name="string"
							select="compoundname" />
						<xsl:with-param name="pattern" select="'::'" />
					</xsl:call-template>
				</xsl:variable>
				<xsl:value-of select="$nameTokens/token[last()]" />
			</xsl:variable>
			<xsl:attribute name="name" select="$name" />
			<xsl:attribute name="fullName" select="compoundname" />

			<!-- inner namespace -->
			<xsl:variable name="innernamespaceRefID"
				select="innernamespace/@refid" />
			<xsl:for-each
				select="root()//compounddef[@id=$innernamespaceRefID]">
				<xsl:call-template name="namespace" />
			</xsl:for-each>

			<!-- classes -->
			<xsl:for-each select="innerclass">
				<xsl:call-template name="class">
					<xsl:with-param name="refid" select="@refid" />
				</xsl:call-template>
			</xsl:for-each>

			<!-- global typedefs -->
			<!-- <xsl:for-each select="doxygen/compounddef[@kind='typedef']"> -->
			<!-- check doxygen version -->
			<xsl:choose>
				<xsl:when
					test="/doxygen/@version='1.5.1-p1'
								or 
								(number(substring(/doxygen/@version, 3, 1)) = 5 and
								 number(substring(/doxygen/@version, 5, 1)) >= 2)
								or
								number(substring(/doxygen/@version, 3, 1)) >= 6">
					<xsl:for-each
						select="sectiondef[@kind='typedef']">
						<xsl:call-template name="typedef" />
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="sectiondef[@kind='']">
						<xsl:choose>
							<!-- if there are more than one entries in all.xml -->
							<xsl:when test="last() > 1">
								<xsl:if test="position() = 1">
									<xsl:call-template name="typedef" />
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="typedef" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

			<!-- global enums -->
			<!-- <xsl:for-each select="doxygen/compounddef[@kind='enum']"> -->
			<!-- check doxygen version -->
			<xsl:choose>
				<xsl:when
					test="/doxygen/@version='1.5.1-p1'
								or 
								(number(substring(/doxygen/@version, 3, 1)) = 5 and
								 number(substring(/doxygen/@version, 5, 1)) >= 2)
								or
								number(substring(/doxygen/@version, 3, 1)) >= 6">
					<xsl:for-each
						select="sectiondef[@kind='enum']/memberdef[@kind='enum']">
						<xsl:call-template name="enumeration" />
					</xsl:for-each>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each
						select="sectiondef[@kind='']/memberdef[@kind='enum']">
						<xsl:choose>
							<!-- if there are more than one entries in all.xml -->
							<xsl:when test="last() > 1">
								<xsl:if test="position() = 1">
									<xsl:call-template
										name="enumeration" />
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="enumeration" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>

			<!-- global variables in the namespace -->
			<!-- create unique list of variables because of a bug in doxygen -->
			<!--<xsl:variable name="unique-variable-list"
				select="sectiondef[@kind='']/memberdef[@kind='variable']/definition[not(.=following::definition)]/.." />
			<xsl:for-each select="$unique-variable-list">
				<xsl:call-template name="variable" />
			</xsl:for-each>-->

			<!-- global functions -->
			<!--<xsl:for-each select="sectiondef[@kind='func']">
				<xsl:if test="not(memberdef/templateparamlist)">
					<xsl:call-template name="function" />
				</xsl:if>
			</xsl:for-each>-->

			<!-- global variables in the namespace -->
			<xsl:if test="count(./sectiondef[@kind='func']/memberdef[@kind='function']) > 0
							or count(./sectiondef[@kind='var']/memberdef[@kind='variable']) > 0">
				<xsl:call-template name="globalUtility">
					<xsl:with-param name="namespace" select="compoundname" />
				</xsl:call-template>
			</xsl:if>			
			
			<!-- documentation -->
			<xsl:call-template name="documentation" />

		</xsl:element>
	</xsl:template>


	<!-- ############### CLASS - calls struct, derivation, enumeration, typedef, function ################## -->
	<!-- cursor on doxygen/compounddef/innerclass -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>class</b>
			element for each class of the current namespace.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>name</b>
			with it's name.
			<br />
			Sets the attribute
			<b>fullName</b>
			with it's fully qualified name.
			<br />
			Sets the attribute
			<b>template</b>
			set to
			<code>true</code>
			if the current class is a template.
			<br />
			Sets the attribute
			<b>templateType</b>
			with it's type if the current class is a template.
			<br />
			Sets the attribute
			<b>templateDeclaration</b>
			with it's declaration type if the current class is a
			template.
			<br />
			Sets the attribute
			<b>templateName</b>
			with it's template name if the current class is a template.
			<br />
			Calls template
			<b>struct</b>
			for each public struct of the current class.
			<br />
			Calls template
			<b>derivation</b>
			for subclasses and baseclasses of the current class.
			<br />
			Calls template
			<b>enumeration</b>
			for enumerations of the current class.
			<br />
			Calls template
			<b>typedef</b>
			for typedefs of the current class.
			<br />
			Calls template
			<b>variable</b>
			for public variables of the current class.
			<br />
			Calls template
			<b>function</b>
			for public functions and public static functions of the
			current class.
			<br />
			Calls template
			<b>class</b>
			for inner classes of the current class.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
		<xd:param name="refid">
			ID of the class inside the Doxygen XML
		</xd:param>
	</xd:doc>

	<xsl:template name="class">
		<xsl:param name="refid" />

		<!-- structs -->
		<!-- 
		<xsl:for-each
			select="root()//compounddef[@id=$refid and @kind='struct' and @prot='public']">
		 -->
		<xsl:for-each
			select="root()//compounddef[@id=$refid and @kind='struct']">
			<!-- select="root()//compounddef[@id=$refid and @kind='struct' and @prot='public']/sectiondef[@kind='public-attrib']"> -->
			<xsl:call-template name="struct" />
		</xsl:for-each>

		<!-- classes -->
		<!-- 
		<xsl:for-each
			select="root()//compounddef[@id=$refid and @kind='class' and @prot='public']">
		 -->
		<xsl:for-each
			select="root()//compounddef[@id=$refid and @kind='class']">
			<xsl:element name="class">
				<xsl:attribute name="protection" select="@prot" />
				<xsl:call-template name="classAndStructBody">
					<xsl:with-param name="refid" select="@id" />
				</xsl:call-template>

			</xsl:element>
		</xsl:for-each>
	</xsl:template>


	<!-- ##################### DERIVATION ######################### -->
	<!-- cursor on doxygen/compounddef -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>derives</b>
			element if the current class has got one or more subclasses.
			<br />
			Generates a
			<b>inherits</b>
			element if the current class has got one or more
			baseclasses.
			<br />
		</xd:short>
		<xd:detail>
			Below the
			<b>derives</b>
			element there will be one
			<b>subClass</b>
			element for each subclass of the current class with it's
			name.
			<br />
			Subclasses are unimportant for the wrapper generation and
			won't be used.
			<br />
			Below the
			<b>inherits</b>
			element there will be one
			<b>baseClass</b>
			element for each subclass of the current class with it's
			name.
			<br />
			Non template classes will be shown first, as this is
			important for the derivation order in Java.
			<br />
		</xd:detail>
		<xd:param name="refid">
			ID of the class inside the Doxygen XML
		</xd:param>
	</xd:doc>
	<xsl:template name="derivation">
		<xsl:param name="refid" />
		<xsl:if test="derivedcompoundref">
			<xsl:element name="derives">
				<xsl:for-each select="derivedcompoundref">
					<xsl:element name="subClass">
						<xsl:choose>
							<!-- if there is no namespace -->
							<xsl:when
								test="not(contains(@refid,'_1_1'))">
								<xsl:value-of select="." />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="substring-after(@refid,'_1_1')" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
		<xsl:if test="basecompoundref">
			<xsl:element name="inherits">
				<xsl:for-each
					select="inheritancegraph/node[link/@refid=$refid]">
					<xsl:for-each select="childnode">
						<xsl:variable name="childid" select="@refid" />
						<!-- non templates first -->
						<xsl:if
							test="not(contains(substring-after(../../node[@id=$childid]/label,'::'),'&lt;'))">

							<xsl:element name="baseClass">

								<!-- remember the full name of base classes -->
								<xsl:attribute name="fullBaseClassName"
									select="../../node[@id=$childid]/label" />

								<xsl:variable name="baseClass"
									select="substring-after(../../node[@id=$childid]/label,'::')" />
								<xsl:choose>
									<!-- if there is no namespace -->
									<xsl:when
										test="substring-after(../../node[@id=$childid]/label,'::') = ''">
										<xsl:value-of
											select="../../node[@id=$childid]/label" />
									</xsl:when>
									<xsl:when
										test="contains($baseClass,'::')">
										<xsl:value-of
											select="replace($baseClass,'::','.')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="$baseClass" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
					<xsl:for-each select="childnode">
						<xsl:variable name="childid" select="@refid" />
						<!-- templates -->
						<xsl:if
							test="contains(substring-after(../../node[@id=$childid]/label,'::'),'&lt;')">
							<xsl:element name="baseClass">

								<!-- remember the full name of base classes -->
								<xsl:attribute name="fullBaseClassName"
									select="../../node[@id=$childid]/label" />

								<xsl:variable name="baseClass"
									select="substring-after(../../node[@id=$childid]/label,'::')" />
								<xsl:choose>
									<xsl:when
										test="contains($baseClass,'::')">
										<xsl:value-of
											select="replace($baseClass,'::','.')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of
											select="$baseClass" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
						</xsl:if>
					</xsl:for-each>
				</xsl:for-each>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- ##################### ENUMERATION ######################### -->
	<!-- cursor on doxygen/compounddef/sectiondef -->
	<xd:doc>
		<xd:short>
			Generates an
			<b>enumeration</b>
			element for each enumeration of the current class.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>name</b>
			with the name of the enumeration.
			<br />
			Below the
			<b>enumeration</b>
			element there will be one
			<b>enum</b>
			element for each value of the current enumeration.
			<br />
			The
			<b>enum</b>
			element retains the attribute
			<b>name</b>
			with the name of the value.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:template name="enumeration">

		<!-- check if we are inside a class -->
		<xsl:choose>

			<!-- global or inside namespace -->
			<!-- see bug 1721154 -->
			<xsl:when test="@kind='enum' and not(starts-with(name, '@'))">
				<xsl:element name="enumeration">
					<xsl:attribute name="protection" select="if (not(@prot)) 
														then 'public' else @prot" />
					<xsl:attribute name="name" select="name" />
					<xsl:attribute name="fullName">
						<xsl:choose>
							<xsl:when
								test="../../@kind = 'namespace'">
								<xsl:value-of
									select="concat(../../compoundname, '::', name)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="name" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<xsl:for-each select="enumvalue">
						<xsl:element name="enum">
							<xsl:attribute name="name" select="name" />
							<xsl:if test="initializer">
								<xsl:attribute name="initializer"
									select="normalize-space(initializer)" />
							</xsl:if>
						</xsl:element>
					</xsl:for-each>

					<!-- copy all includes into meta output -->
					<xsl:element name="includes">
						<xsl:attribute name="local" select="'yes'" />
						<xsl:value-of select="location/@file" />
<!--						<xsl:value-of select="tokenize(location/@file, '/')[last()]" /> -->
					</xsl:element>

					<!-- documentation -->
					<xsl:call-template name="documentation" />
				</xsl:element>
			</xsl:when>

			<!-- inside class -->
			<!-- see bug 1721154 -->
			<xsl:otherwise>
				<xsl:for-each select="memberdef[@kind='enum' and not(starts-with(name, '@'))]">
					<!-- test if enum belongs to actual class -->
					<xsl:if test="starts-with(@id,../../@id)">
						<xsl:element name="enumeration">
							<xsl:attribute name="protection" select="if (not(@prot)) 
																		then 'public' else @prot" />
							<xsl:attribute name="name" select="name" />
							<xsl:attribute name="fullName"
								select="concat(../../compoundname, '::', name)" />
							<xsl:for-each select="enumvalue">
								<xsl:element name="enum">
									<xsl:attribute name="name"
										select="name" />
									<xsl:if test="initializer">
										<xsl:attribute
											name="initializer" select="normalize-space(initializer)" />
									</xsl:if>
								</xsl:element>
							</xsl:for-each>

							<!-- copy all includes into meta output -->
							<xsl:element name="includes">
								<xsl:attribute name="local" select="'yes'" />
								<xsl:value-of select="location/@file" />
<!--								<xsl:value-of select="tokenize(location/@file, '/')[last()]" /> -->
							</xsl:element>

							<!-- documentation -->
							<xsl:call-template name="documentation" />

						</xsl:element>
					</xsl:if>
				</xsl:for-each>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- ##################### TYPEDEF - calls typeMap ######################### -->
	<!-- cursor on doxygen/compounddef/sectiondef -->
	<xd:doc>
		<xd:short>
			Generates an
			<b>typedef</b>
			element for each typedef of the current class.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>name</b>
			with the name of the typedef.
			<br />
			Sets the attribute
			<b>protection</b>
			with values:
			<ul>
				<li>public</li>
				<li>protected</li>
				<li>private</li>
			</ul>
			<br />
			Sets the attribute
			<b>name</b>
			with the name of the typedef.
			<br />
			Sets the attribute
			<b>basetype</b>
			with the definition of the typedef.
			<br />
			Sets the attribute
			<b>type</b>
			with the value of the template parameter, if the
			<b>basetype</b>
			is a template.
			<br />
			Calls template
			<b>typeMap</b>
			for the mapping of the template parameter, if the
			<b>basetype</b>
			is a template.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:template name="typedef">
		<xsl:for-each select="memberdef[@kind='typedef']">

			<!-- do not include inherited typedefs -->
			<xsl:variable name="definitionFullNameTokens" select="tokenize(tokenize(replace(replace(
							./definition, '&lt; ', '&lt;'), ' &gt;', '&gt;'), ' ')[last()], '::')"/>
			<xsl:variable name="namespaceDefinedIn" select="if (count($definitionFullNameTokens) = 1)
						then ../../compoundname
						else xbig:buildNamespaceNameTypeIsDefinedIn('', $definitionFullNameTokens, 1)" />
			<xsl:if test="$namespaceDefinedIn = ../../compoundname">

				<xsl:element name="typedef">
					<xsl:attribute name="name" select="name" />
					<xsl:attribute name="fullName">
						<xsl:choose>
							<xsl:when
								test="../../@kind = 'namespace' 
											or ../../@kind = 'class' 
											or ../../@kind = 'struct'">
								<xsl:value-of
									select="concat(../../compoundname, '::', name)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="name" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="protection" select="@prot" />
					<xsl:attribute name="basetype">
						<xsl:choose>
							<xsl:when test="count(./type/ref) = 1 and contains(./definition, 'typedef') and contains(./definition, 'struct')">
								<!-- e.g. typedef struct, but no template typedefs -->
								<xsl:value-of select="normalize-space(//compounddef[@id = current()/type/ref/@refid]/compoundname)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="normalize-space(./type)" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:attribute>

					<!-- copy all includes into meta output -->
					<xsl:choose>
						<xsl:when
							test="../../@kind = 'class' or ../../@kind = 'struct'">
							<xsl:copy-of copy-namespaces="no"
								select="../../includes" />
						</xsl:when>

						<!-- typedef inside a namespace -->
						<xsl:when
							test="../../@kind = 'namespace'">
							<xsl:element name="includes">
								<xsl:attribute name="local" select="'yes'" />
								<xsl:value-of select="location/@file" />
<!--								<xsl:value-of select="tokenize(location/@file, '/')[last()]" /> -->
							</xsl:element>
						</xsl:when>

						<!-- inside a file -->
						<xsl:otherwise>
							<xsl:element name="includes">
								<xsl:attribute name="local" select="'yes'" />
								<xsl:value-of select="../../compoundname" />
							</xsl:element>
						</xsl:otherwise>
					</xsl:choose>

					<!-- documentation -->
					<xsl:call-template name="documentation" />

				</xsl:element>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>


	<!-- ##################### STRUCT - calls typeMap ######################### -->
	<!-- cursor on doxygen/compounddef/sectiondef -->
	<xd:doc>
		<xd:short>
			Generates an
			<b>struct</b>
			element for each struct of the current class.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>name</b>
			with the name of the struct.
			<br />
			Sets the attribute
			<b>protection</b>
			with values:
			<ul>
				<li>public</li>
				<li>protected</li>
				<li>private</li>
			</ul>
			<br />
			Sets the attribute
			<b>name</b>
			with the name of the typedef.
			<br />
			Sets the attribute
			<b>template</b>
			set to
			<code>true</code>
			if the current struct is a template.
			<br />
			Sets the attribute
			<b>templateType</b>
			with it's type if the current struct is a template.
			<br />
			Sets the attribute
			<b>templateDeclaration</b>
			with it's declaration type if the current struct is a
			template.
			<br />
			Sets the attribute
			<b>templateName</b>
			with it's template name if the current struct is a template.
			<br />
			Below the
			<b>struct</b>
			element there will be one
			<b>param</b>
			element for each variable of the current struct.
			<br />
			Name and type of the variable will be stored in the elements
			<b>name</b>
			and
			<b>type</b>
			below the
			<b>param</b>
			element.
			<br />
			Calls template
			<b>typeMap</b>
			for the mapping of the type of the variable.
			<br />
			Calls template
			<b>function</b>
			for public functions of the struct.
			<br />
			Calls template
			<b>structattributes</b>
			for public attributes of the struct.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
	</xd:doc>

	<xsl:template name="struct">
		<xsl:param name="refid" />

		<xsl:element name="struct">
			<xsl:attribute name="protection" select="@prot" />

			<xsl:call-template name="classAndStructBody">
				<xsl:with-param name="refid" select="@id" />
			</xsl:call-template>

		</xsl:element>
	</xsl:template>


	<!-- ############## FUNCTION - calls type ############## -->
	<!-- cursor on doxygen/compounddef/sectiondef -->
	<xd:doc>
		<xd:short>
			Generates an
			<b>function</b>
			element for each function of the current namespace, class or
			struct.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>virt</b>
			to differ abstract functions, with values:
			<ul>
				<li>non-virtual</li>
				<li>virtual</li>
				<li>pure-virtual</li>
			</ul>
			<br />
			Sets the attribute
			<b>const</b>
			to differ constant and non-constant functions, with values:
			<ul>
				<li>true</li>
				<li>false</li>
			</ul>
			<br />
			Sets the attribute
			<b>template</b>
			set to
			<code>true</code>
			if the current function is a template.
			<br />
			Sets the attribute
			<b>templateType</b>
			with it's type if the current function is a template.
			<br />
			Sets the attribute
			<b>templateDeclaration</b>
			with it's declaration type if the current function is a
			template.
			<br />
			Sets the attribute
			<b>templateName</b>
			with it's template name if the current function is a
			template.
			<br />
			Name and type of the function will be stored in the elements
			<b>name</b>
			and
			<b>type</b>
			below the
			<b>function</b>
			element.
			<br />
			The element
			<b>definition</b>
			below the
			<b>function</b>
			element is for debugging only.
			<br />
			Below the
			<b>function</b>
			element there will be one
			<b>parameters</b>
			element if the function has got parameters.
			<br />
			Name and type of the parameters will be stored in the
			elements
			<b>name</b>
			and
			<b>type</b>
			below the
			<b>parameters</b>
			element.
			<br />
			Calls template
			<b>type</b>
			for the elements
			<b>name</b>
			and
			<b>type</b>
			.
			<br />
			Calls template
			<b>documentation</b>
			for itself.
			<br />
		</xd:detail>
		<xd:param name="ifGlobal" select="false()">
			A boolean value to identify if it's a global function.
		</xd:param>
	</xd:doc>
	<xsl:template name="function">
		<xsl:param name="ifGlobal" select="false()"/>
		<!-- ignore template functions (bug 1666887) -->
		<xsl:for-each select="memberdef[not(./templateparamlist)]">
			<!-- test if function belongs to actual class (the location test could be deleted)  -->
			<!-- 
				<xsl:if
				test="ends-with(location/@file,../../includes) and starts-with(@id,../../@id)">
			-->

			<!-- do not include inherited methods -->
			<xsl:variable name="definitionTokensBySpace" select="tokenize(replace(replace(
						normalize-space(./definition), '&lt; ', '&lt;'), ' &gt;', '&gt;'), ' ')"/>
			<xsl:variable name="definitionFullNameTokens" select="if (not(contains(
						$definitionTokensBySpace[last()], '::')))
						then tokenize($definitionTokensBySpace[last()-1], '::')
						else tokenize($definitionTokensBySpace[last()], '::')"/>
			<xsl:variable name="namespaceDefinedIn" select="if (count($definitionFullNameTokens) = 1)
						then ../../compoundname
						else xbig:buildNamespaceNameTypeIsDefinedIn('', $definitionFullNameTokens, 1)" />
			<xsl:if test="$namespaceDefinedIn = ../../compoundname">

				<xsl:choose>
					<!-- destructor - do nothing -->
					<xsl:when test="starts-with(name,'~')" />
					<xsl:otherwise>
						<xsl:element name="function">
							<xsl:attribute name="virt" select="@virt" />
							<xsl:attribute name="visibility" select="@prot" />
							<xsl:attribute name="static">
								<xsl:choose>
									<xsl:when test="@static='yes' or $ifGlobal">
										<xsl:value-of select="'true'" />
									</xsl:when>
									<xsl:when test="@static='no'">
										<xsl:value-of select="'false'" />
									</xsl:when>
								</xsl:choose>
							</xsl:attribute>
							<xsl:attribute name="const">
								<xsl:choose>
									<xsl:when test="@const='yes'">
										<xsl:value-of select="'true'" />
									</xsl:when>
									<xsl:when test="@const='no'">
										<xsl:value-of select="'false'" />
									</xsl:when>
								</xsl:choose>
							</xsl:attribute>
							<!-- template attributes -->
							<xsl:if test="templateparamlist">
								<xsl:variable name="refid"
									select="../../@id" />
								<xsl:attribute name="template"
									select="'true'" />
								<xsl:attribute name="templateType"
									select="templateparamlist/param/type" />
								<xsl:attribute name="templateDeclaration"
									select="templateparamlist/param/declname" />
								<xsl:for-each
									select="inheritancegraph/node">
									<xsl:if test="link/@refid=$refid">
										<xsl:variable name="childnode"
											select="childnode/@refid" />
										<xsl:for-each select="../node">
											<xsl:if test="@id=$childnode">
												<xsl:attribute
													name="templateName">
													<xsl:variable
														name="string" select="substring-before(label,' &gt;')" />
													<xsl:value-of
														select="substring-after($string,'&lt; ')" />
												</xsl:attribute>
											</xsl:if>
										</xsl:for-each>
									</xsl:if>
								</xsl:for-each>
							</xsl:if>
							<!-- type of the function -->
							<xsl:if test="type and type!='virtual'">
								<xsl:call-template name="type" />
							</xsl:if>
							<xsl:element name="definition">
								<xsl:choose>
									<xsl:when test="$ifGlobal">
										<xsl:value-of select="concat('static ', definition)" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="definition" />
									</xsl:otherwise>
								</xsl:choose>
							</xsl:element>
							<!-- name of the function -->
							<xsl:element name="name">
								<!-- <xsl:choose>
									<xsl:when
									test="contains(name,'::')">
									<xsl:value-of
									select="substring-after(name,'::')" />
									</xsl:when>
									<xsl:otherwise> -->
								<xsl:value-of select="name" />
								<!-- </xsl:otherwise>
									</xsl:choose> -->
							</xsl:element>
							<!-- parameter of the function -->
							<xsl:if
								test="(param/type!='' or param/declname!='') and not(param/type='void')">
								<xsl:element name="parameters">
									<xsl:for-each select="param">
										<xsl:element name="parameter">
											<xsl:call-template name="type" />
										</xsl:element>
									</xsl:for-each>
								</xsl:element>
							</xsl:if>

							<!-- documentation -->
							<xsl:call-template name="documentation" />

						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<!-- 
				</xsl:if>
			-->
		</xsl:for-each>
	</xsl:template>
	<!-- ##################### TYPE - calls typeMap ##################### -->
	<!-- cursor on doxygen/compounddef/sectiondef/memberdef/param -->
	<xd:doc>
		<xd:short>
			Sets the attributes for a function parameter or a variable.
			Generates an
			<b>name</b>
			element for a function parameter or a variable.
		</xd:short>
		<xd:detail>
			Sets the attribute
			<b>passedBy</b>
			with values:
			<ul>
				<li>reference</li>
				<li>pointer</li>
				<li>value</li>
			</ul>
			<br />
			Calls template
			<b>typeMap</b>
			for the type of a function parameter or a variable.
			<br />
		</xd:detail>
	</xd:doc>
	<xsl:template name="type">
		<xsl:choose>
			<!-- passed by reference -->
			<xsl:when test="contains(type,'&amp;')">
				<xsl:attribute name="passedBy" select="'reference'" />
				<xsl:call-template name="typeMap">
					<xsl:with-param name="type"
						select="substring-before(type,' &amp;')" />
				</xsl:call-template>
				<!-- 
					<xsl:choose>
				-->
				<!-- current class is a template -->
				<!-- 
					<xsl:when
						test="../../templateparamlist or ../../../templateparamlist">
					<xsl:call-template name="typeMap">
					<xsl:with-param name="type"
								select="substring-before(type,' &amp;')" />
					</xsl:call-template>
					</xsl:when>
					<xsl:when test="type/ref">
					<xsl:call-template name="typeMap">
				-->
				<!-- don't put the select instruction into the "with-param" element,will cause multiple select of type/ref -->
				<!-- 
							<xsl:with-param name="type">
					<xsl:value-of select="type/ref" />
					</xsl:with-param>
					</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
					<xsl:call-template name="typeMap">
					<xsl:with-param name="type"
								select="substring-before(type,' &amp;')" />
					</xsl:call-template>
					</xsl:otherwise>
					</xsl:choose>
				-->
			</xsl:when>
			<!-- passed by pointer -->
			<xsl:when test="contains(type,'*')">
				<xsl:variable name="typeAfterLastGT" select="if (contains(type, '&gt;')) then
														  tokenize(type, '&gt;')[last()] else type"/>
				<xsl:attribute name="passedBy" select="if(contains($typeAfterLastGT, '*'))
														then 'pointer' else 'value'" />
				<xsl:call-template name="typeMap">
					<xsl:with-param name="type" select="type" />
				</xsl:call-template>
				<!-- 
					<xsl:variable name="type"
					select="substring-before(type,' *')" />
				-->
				<!-- 
					<xsl:choose>
				-->
				<!-- current class is a template -->
				<!-- 
					<xsl:when
						test="../../templateparamlist or ../../../templateparamlist">
					<xsl:call-template name="typeMap">
				-->
				<!-- 
					<xsl:with-param name="type"
					select="substring-before(type,' *')" />
				-->
				<!-- 
							<xsl:with-param name="type" select="type" />
					</xsl:call-template>
					</xsl:when>
					<xsl:when test="type/ref">
					<xsl:call-template name="typeMap">
					<xsl:with-param name="type">
					<xsl:value-of select="type/ref" />
					</xsl:with-param>
					</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
					<xsl:call-template name="typeMap">
				-->
				<!-- 
					<xsl:with-param name="type"
					select="substring-before(type,' *')" />
				-->
				<!-- 
							<xsl:with-param name="type" select="type" />
					</xsl:call-template>
					</xsl:otherwise>
					</xsl:choose>
				-->
			</xsl:when>
			<!-- passed by value -->
			<xsl:otherwise>
				<xsl:attribute name="passedBy" select="'value'" />
				<xsl:choose>
					<!-- current class is a template -->
					<xsl:when
						test="../../templateparamlist or ../../../templateparamlist">
						<xsl:call-template name="typeMap">
							<xsl:with-param name="type" select="type" />
						</xsl:call-template>
					</xsl:when>
					<xsl:when test="count(type/ref)=1">
						<xsl:call-template name="typeMap">
							<xsl:with-param name="type">
								<!-- <xsl:value-of select="type/ref" /> -->
								<xsl:value-of select="type" />
							</xsl:with-param>
						</xsl:call-template>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="typeMap">
							<xsl:with-param name="type" select="type" />
						</xsl:call-template>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
		<!-- name -->

		<xsl:if test="declname!=''">
			<xsl:element name="name">
				<xsl:value-of select="if ($config/config/meta/parameter/rename
											[text() = current()/declname])
										then $config/config/meta/parameter/rename
											[. = current()/declname]/@meta
										else declname" />
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- ######################## TYPEMAP ######################## -->
	<!-- cursor on doxygen/compounddef/sectiondef/memberdef/param -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>type</b>
			element for a function parameter or a variable.
		</xd:short>
		<xd:detail>
			The typemap template a mapping for primitive types. It also
			removes unwanted symbols.
			<br />
			Sets the attribute
			<b>const</b>
			to
			<code>true</code>
			if the current parameter is constant.
			<br />
			Sets the attribute
			<b>array</b>
			with the array arguments.
			<br />
			Sets the attribute
			<b>passedBy</b>
			for the type, with values:
			<ul>
				<li>reference</li>
				<li>pointer</li>
				<li>value</li>
			</ul>
			<br />
		</xd:detail>
		<xd:param name="type">
			type of function, parameter or variable
		</xd:param>
		<xd:param name="passedBy">reference, pointer or value</xd:param>
	</xd:doc>
	<xsl:template name="typeMap">
		<xsl:param name="type" />
		<xsl:param name="passedBy" />

		<xsl:if test="type!=''">
			<xsl:element name="type">

				<!-- find out if first child of $type is a text node (for bug 1714365) -->
				<xsl:variable name="isFirstChildTextNode">
					<xsl:choose>
						<xsl:when test="type/child::node()[position()=1] = type/child::text()[position()=1]">
							<xsl:sequence select="true()"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:sequence select="false()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- check for const, take care of const pointer or const data
					 (const int* vs int* const) 
					 only if type is not a template -->
				<xsl:if test="not(contains(type, '&lt;'))">
					<xsl:choose>
						<!-- <xsl:when test="$passedBy = 'pointer'"> -->
						<xsl:when test="contains(type, '*')">
							<!-- const data -->
							<xsl:if
								test="contains(substring-before(type, '*'), 'const')">
								<xsl:attribute name="const" select="'true'" />
							</xsl:if>
							<!-- const pointer -->
							<xsl:if
								test="contains(substring-after(type, '*'), 'const')">
								<xsl:attribute name="constPointer"
									select="'true'" />
							</xsl:if>
						</xsl:when>
						<xsl:otherwise>
							<!-- see Ogre::AlignedAllocator::address(const_reference), t37, bug 1714365 -->
							<xsl:if
								test="$isFirstChildTextNode = true() and starts-with(type, 'const')">
								<xsl:attribute name="const" select="'true'" />
							</xsl:if>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>

				<xsl:if test="array">
					<xsl:attribute name="array" select="array" />
				</xsl:if>
				<xsl:if test="$passedBy">
					<xsl:attribute name="passedBy" select="$passedBy" />
				</xsl:if>

				<!-- remove const prefix or postfix, take care of bugs 1714365 and 1723314 -->
				<xsl:variable name="non_const_type">
					<xsl:choose>
						<xsl:when test="$isFirstChildTextNode = true() and starts-with($type, 'const')">
							<xsl:value-of select="replace($type, '[ \t]*^const[ \t]', '')"/>
						</xsl:when>
						<xsl:when test="type/child::text()[contains(.,'const')]">
							<xsl:choose>
								<!-- bug 1719121 -->
								<xsl:when test="type/child::text()[contains(.,'::const')]">
									<xsl:value-of select="$type" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:choose>
										<!-- if just type parameter is const -->
										<xsl:when test="contains($type, '&lt;')">
											<xsl:choose>
												<xsl:when test="contains(substring-before(
																	$type, '&lt;'), 'const')">
													<xsl:value-of
														select="substring-after($type, 'const')" />
												</xsl:when>
												<xsl:otherwise>
													<xsl:value-of
														select="$type" />
												</xsl:otherwise>
											</xsl:choose>
										</xsl:when>

										<!-- it's not a type parameter that is const -->
										<xsl:otherwise>
											<xsl:value-of
												select="substring-before($type, 'const')" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<xsl:otherwise>
							<xsl:value-of select="$type" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- remove parameter passing modifiers -->
				<!-- 
					<xsl:variable name="stripped_type" select="replace($non_const_type, '[\*&amp;\[].*$', '')"/>
				-->

				<!-- see bug 1666898 -->
				<xsl:variable name="typeWithoutInline" select="
					if (contains($non_const_type, '__inline')) 
					then substring-after($non_const_type, '__inline') else $non_const_type" />
				
				<!-- remove keyword struct -->
				<xsl:variable name="typeWithoutStruct" select="
					if (contains($typeWithoutInline, 'struct ')) 
					then substring-after($typeWithoutInline, 'struct ') else $typeWithoutInline" />

				<!-- remove keyword enum -->
				<xsl:variable name="typeWithoutEnum" select="
					if (contains($typeWithoutStruct, 'enum ')) 
					then substring-after($typeWithoutStruct, 'enum ') else $typeWithoutStruct" />
				
				<xsl:variable name="typeWithoutRef"
					select="replace($typeWithoutEnum, '[&amp;\[].*$', '')" />

				<xsl:variable name="pointerPointerToken"
					select="'#POINTER_POINTER_TOKEN#'" />
				<xsl:variable name="stripped_type">
					<xsl:choose>
						<xsl:when
							test="contains($typeWithoutRef, '*') and not(contains(type, '&lt;'))">
							<xsl:choose>
								<!-- recognize pointer pointer -->
								<xsl:when
									test="contains(substring-after($typeWithoutRef, '*'), '*')">
									<!-- keep some '*' to recognize pointer pointer -->
									<!-- 
										<xsl:value-of select="concat(substring-before($typeWithoutRef, 
										'*'), substring-after($typeWithoutRef, '*'))"/>
									-->

									<xsl:value-of
										select="concat(substring-before($typeWithoutRef, '*'),
															$pointerPointerToken)" />
								</xsl:when>
								<xsl:otherwise>
									<!-- whole type is a Ptr (there are no type parameters) -->
									<xsl:value-of
										select="substring-before($typeWithoutRef, '*')" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<!-- remove '*' if type is a template -->
						<xsl:when test="contains(type, '&lt;')">
							<xsl:variable name="typeAfterLastGT" 
								select="tokenize($typeWithoutRef, '&gt;')[last()]"/>
							
							<xsl:choose>
								<xsl:when test="contains($typeAfterLastGT, '*')">
									<xsl:for-each
										select="tokenize($typeWithoutRef, '\*')[position() != last()]">
										<xsl:value-of select="."/>
										<xsl:if test="position() != last()">
											<xsl:value-of select="'* '"/>
										</xsl:if>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$typeWithoutRef" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

						<xsl:otherwise>
							<xsl:value-of select="$typeWithoutRef" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:if
					test="contains($stripped_type, $pointerPointerToken)">
					<xsl:attribute name="pointerPointer"
						select="'true'" />
				</xsl:if>

				<xsl:choose>
					<xsl:when
						test="contains($stripped_type, $pointerPointerToken)">
						<xsl:value-of
							select="normalize-space(substring-before($stripped_type,
												$pointerPointerToken))" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of
							select="normalize-space($stripped_type)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:element>
		</xsl:if>
	</xsl:template>
	<!-- ############ VARIABLE ############ -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>variable</b>
			element for a global or in-class variable.
		</xd:short>
		<xd:detail>
			Calls template
			<b>type</b>
			for the type of the variable.
			<br />
			The element
			<b>argsstring</b>
			below the
			<b>variable</b>
			element is for array types.
			<br />
			The element
			<b>definition</b>
			below the
			<b>variable</b>
			element is for debugging only.
			<br />
			The element
			<b>name</b>
			below the
			<b>variable</b>
			element contains the name of the variable.
			<br />
		</xd:detail>
		<xd:param name="type">
			type of function, parameter or variable
		</xd:param>
		<xd:param name="passedBy">reference, pointer or value</xd:param>
		<xd:param name="ifGlobal" select="false()">
			A boolean value to identify if it's a global function.
		</xd:param>
	</xd:doc>
	<!-- cursor on doxygen/compounddef/sectiondef -->
	<xsl:template name="variable">
		<xsl:param name="ifGlobal" select="false()"/>

		<!-- see bug 1719159 and 1728987 -->
		<xsl:for-each select="memberdef[@kind='variable']
								[not(starts-with(name, '@'))][not(contains(type, '@'))]">

			<!-- do not include inherited attributes (because of template handling) -->
			<xsl:variable name="definitionFullNameTokens" select="tokenize(tokenize(replace(replace(
							./definition, '&lt; ', '&lt;'), ' &gt;', '&gt;'), ' ')[last()], '::')"/>
			<xsl:variable name="namespaceDefinedIn" select="if (count($definitionFullNameTokens) = 1)
						then ../../compoundname
						else xbig:buildNamespaceNameTypeIsDefinedIn('', $definitionFullNameTokens, 1)" />
			<xsl:if test="$namespaceDefinedIn = ../../compoundname">

				<xsl:element name="variable">
					<!--
						<xsl:attribute name="static">
						<xsl:choose>
						<xsl:when test="starts-with(type,'const')">
						<xsl:value-of select="'true'"/>
						</xsl:when>
						<xsl:otherwise>
						<xsl:value-of select="'false'"/>
						</xsl:otherwise>
						</xsl:choose>
						</xsl:attribute>
					-->
					<xsl:attribute name="visibility" select="@prot" />
					<xsl:attribute name="static">
						<xsl:choose>
							<xsl:when test="@static='yes' or $ifGlobal">
								<xsl:value-of select="'true'" />
							</xsl:when>
							<xsl:when test="@static='no'">
								<xsl:value-of select="'false'" />
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>
					<xsl:attribute name="const">
						<xsl:choose>
							<xsl:when test="@const='yes'">
								<xsl:value-of select="'true'" />
							</xsl:when>
							<xsl:when test="@const='no' or not(@const)">
								<xsl:value-of select="'false'" />
							</xsl:when>
						</xsl:choose>
					</xsl:attribute>

					<xsl:if test="type and type!='virtual'">
						<xsl:call-template name="type" />
					</xsl:if>
					<xsl:if test="argsstring!=''">
						<xsl:element name="argsstring">
							<xsl:value-of select="argsstring" />
						</xsl:element>
					</xsl:if>
					<xsl:element name="definition">
						<xsl:choose>
							<xsl:when test="$ifGlobal">
								<xsl:value-of select="concat('static ', definition)" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="definition" />
							</xsl:otherwise>
						</xsl:choose>	
					</xsl:element>
					<xsl:element name="name">
						<xsl:value-of select="name" />
					</xsl:element>
				</xsl:element>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!-- ############ DOCUMENTATION ############ -->
	<xd:doc>
		<xd:short>
			Generates a
			<b>briefdescription</b>
			and a
			<b>detaileddescription</b>
			element.
		</xd:short>
		<xd:detail>
			This template just copys the existing documentation from
			all.xml to meta.xml.
		</xd:detail>
	</xd:doc>
	<xsl:template name="documentation">
		<xsl:if test="briefdescription/*">
			<xsl:copy-of select="briefdescription" />
		</xsl:if>
		<xsl:if test="detaileddescription/*">
			<xsl:copy-of select="detaileddescription" />
		</xsl:if>
	</xsl:template>

	<!-- ############ STRUCT ATTRIBUTES ############ -->
	<xd:doc>
		<xd:short>
			Generates elements for attributes of structs.
		</xd:short>
		<xd:detail>
			It is needed for two cases in template struct
		</xd:detail>
	</xd:doc>
	<xsl:template name="structattributes">
		<xsl:for-each select="memberdef[@kind='variable']">
			<xsl:element name="param">
				<xsl:choose>
					<xsl:when test="contains(type, '&amp;')">
						<xsl:attribute name="passedBy">
							reference
						</xsl:attribute>
					</xsl:when>
					<xsl:when test="contains(type, '*')">
						<xsl:attribute name="passedBy">
							pointer
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>
				<xsl:element name="name">
					<xsl:value-of select="name" />
				</xsl:element>
				<xsl:call-template name="typeMap">
					<xsl:with-param name="type"
						select="normalize-space(type)" />
				</xsl:call-template>
				<xsl:if test="argsstring!=''">
					<xsl:element name="argsstring">
						<xsl:value-of select="argsstring" />
					</xsl:element>
				</xsl:if>
			</xsl:element>
		</xsl:for-each>
	</xsl:template>



	<xsl:template name="createDefaultConstructor">
		<xsl:param name="className" />

		<!-- generate default c-tor if necessary -->
		<xsl:if
			test="xbig:haveToGenerateDefaultCtor(., $className, /)">
			<xsl:element name="function">
				<xsl:attribute name="virt">
					<xsl:text>non-virtual</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="visibility">
					<xsl:text>public</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="static">
					<xsl:text>false</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="const">
					<xsl:text>false</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="passedBy">
					<xsl:text>value</xsl:text>
				</xsl:attribute>
				<xsl:element name="name">
					<xsl:value-of select="$className" />
				</xsl:element>
				<xsl:element name="definition">
					<xsl:value-of
						select="concat(compoundname, '::', $className)" />
				</xsl:element>

			</xsl:element>
		</xsl:if>
	</xsl:template>


	<xd:doc type="function">
		<xd:short>
			Takes a compounddef node representing a class and checks if it is necessary to
			generate a default c-tor for that class. Checks base classes, too.
		</xd:short>
		<xd:param name="node">compounddef node representing class to check.</xd:param>
		<xd:param name="className">name of class to check.</xd:param>
		<xd:param name="root">root node of input tree.</xd:param>
	</xd:doc>
	<xsl:function name="xbig:haveToGenerateDefaultCtor" as="xs:boolean">
		<xsl:param name="node" />
		<xsl:param name="className" />
		<xsl:param name="root" />

		<xsl:choose>
			<xsl:when test="not($node/sectiondef[@kind='public-func']/memberdef/name=$className) and
					  not($node/sectiondef[@kind='private-func']/memberdef/name=$className) and
					  not($node/sectiondef[@kind='protected-func']/memberdef/name=$className)">
				<xsl:choose>
					<!-- check base classes -->
					<!-- see tests t5_4 and t69 -->
					<xsl:when test="count($node/inheritancegraph/node[not(childnode) or link[@refid = $node/@id]]) > 0">
						<xsl:variable name="baseClassesResults">
							<xsl:for-each select="$node/inheritancegraph/node[not(childnode) and link[@refid != $node/@id]]">
								<xsl:variable name="currentInheritanceNode" select="current()" />
								<xsl:element name="result">
									<xsl:attribute name="result">
										<xsl:variable name="currentInheritanceNodeID" select="$currentInheritanceNode/link/@refid" />
										<xsl:variable name="nodeForCall" select="$root//compounddef[@id = $currentInheritanceNodeID]" />
										<xsl:variable name="classNameForCall" select="tokenize($currentInheritanceNode/label, '::')[last()]" />
										<xsl:value-of select="xbig:haveToGenerateDefaultCtor($nodeForCall, $classNameForCall, $root)" />
									</xsl:attribute>
								</xsl:element>
							</xsl:for-each>
						</xsl:variable>
						<xsl:choose>
							<xsl:when test="count($baseClassesResults/result[@result = false()]) > 0">
								<xsl:value-of select="false()" />
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="true()" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>

					<xsl:otherwise>
						<xsl:value-of select="true()" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>

			<xsl:otherwise>
				<xsl:value-of select="false()" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>



	<xsl:template name="classAndStructBody">
		<xsl:param name="refid" />

		<xsl:variable name="className">
			<xsl:choose>

				<!-- if this class is inside a namespace -->
				<xsl:when test="contains(compoundname,'::')">
					<xsl:variable name="compoundNameTokens">
						<xsl:call-template name="str:split">
							<xsl:with-param name="string"
								select="compoundname" />
							<xsl:with-param name="pattern"
								select="'::'" />
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of
						select="$compoundNameTokens/token[last()]">
					</xsl:value-of>
				</xsl:when>

				<xsl:otherwise>
					<xsl:value-of select="compoundname" />
				</xsl:otherwise>

			</xsl:choose>
		</xsl:variable>
		<xsl:attribute name="name" select="$className" />
		<xsl:attribute name="fullName" select="compoundname" />

		<!-- check if this class is abstract, this is not right in every case
			 (base classes need to be checked if listofallmembers is not present) -->
		<xsl:choose>
			<xsl:when test="listofallmembers">
				<xsl:attribute name="abstract" select="if (listofallmembers/member[@virt='pure-virtual'])
														then 'true' else 'false'" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="abstract" select="if (sectiondef/memberdef
														[@kind='function' and @virt='pure-virtual'])
														then 'true' else 'false'" />
			</xsl:otherwise>
		</xsl:choose>

		<!-- template attributes -->
		<xsl:if test="templateparamlist">
			<xsl:attribute name="template" select="'true'" />

			<xsl:element name="templateparameters">
				<xsl:for-each select="templateparamlist/param">
					<xsl:element name="templateparameter">
						<xsl:attribute name="templateType"
							select="type" />
						<xsl:attribute name="templateDeclaration"
							select="declname" />
					</xsl:element>
				</xsl:for-each>
			</xsl:element>
<!-- 
			<xsl:for-each select="inheritancegraph/node">
				<xsl:if test="link/@refid=$refid">
					<xsl:variable name="childnode"
						select="childnode/@refid" />
					<xsl:for-each select="../node">
						<xsl:if test="@id=$childnode">
							<xsl:attribute name="templateName">
								<xsl:variable name="string"
									select="substring-before(label,' &gt;')" />
								<xsl:value-of
									select="substring-after($string,'&lt; ')" />
							</xsl:attribute>
						</xsl:if>
					</xsl:for-each>
				</xsl:if>
			</xsl:for-each>
 -->
		</xsl:if><!-- template -->

		<!-- getting the right name of inner classes -->
		<xsl:variable name="name"
			select="substring-after(compoundname,'::')" />

		<!-- copy all includes into meta output -->
		<xsl:copy-of copy-namespaces="no" select="includes" />


		<!-- cursor on doxygen/compounddef[@kind="class"] -->
		<!-- derivation -->
		<xsl:call-template name="derivation">
			<xsl:with-param name="refid" select="$refid" />
		</xsl:call-template>
		<!-- enumerations -->
		<!-- see bug 1724320
		<xsl:for-each select="sectiondef[@kind='public-type']">
		 -->
			<!-- or @kind='protected-type'-->
		<xsl:for-each select="sectiondef">
			<xsl:choose>
				<xsl:when test="memberdef[@kind='enum']">
					<xsl:call-template name="enumeration" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!-- typedefs -->
		<!-- 
		<xsl:for-each
			select="sectiondef[@kind='public-type' or @kind='protected-type']">
		 -->
		<xsl:for-each select="sectiondef">
			<xsl:choose>
				<xsl:when test="memberdef[@kind='typedef']">
					<xsl:call-template name="typedef" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!-- public variables -->
		<xsl:for-each
			select="sectiondef[@kind='public-attrib' or @kind='public-static-attrib']">
			<xsl:call-template name="variable" />
		</xsl:for-each>
		<!-- public functions -->
		<xsl:for-each select="sectiondef[@kind='public-func']">
			<xsl:choose>
				<xsl:when test="memberdef[@kind='function']">
					<xsl:call-template name="function" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>
		<!-- static functions -->
		<xsl:for-each select="sectiondef[@kind='public-static-func']">
			<xsl:choose>
				<xsl:when test="memberdef[@kind='function']">
					<xsl:call-template name="function" />
				</xsl:when>
			</xsl:choose>
		</xsl:for-each>

		<xsl:call-template name="createDefaultConstructor">
			<xsl:with-param name="className">
				<xsl:value-of select="$className" />
			</xsl:with-param>
		</xsl:call-template>

		<!-- recursion for inner classes -->
		<xsl:for-each select="innerclass">
			<xsl:call-template name="class">
				<xsl:with-param name="refid" select="@refid" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- documentation -->
		<xsl:call-template name="documentation" />
	</xsl:template>

	<xd:doc>
		<xd:short>
			Generates elements for global functions and variable.
		</xd:short>
		<xd:detail>
			In every namespace, a class whose name is specified by 
			$config/config/meta/globalmember/classNameForGlobalMember 
			will be created to contain the global functions and variables
			within this namespace.
		</xd:detail>
		<xd:param name="namespace">
			specify the namespace
		</xd:param>		
	</xd:doc>	
	<xsl:template name="globalUtility">
		<xsl:param name="namespace" select="''"/>
		<xsl:element name="class">
			<xsl:attribute name="protection" select="'public'" />
			<xsl:attribute name="name" select="normalize-space($config/config/meta/globalmember/classNameForGlobalMember)" />
			<xsl:attribute name="fullName">
				<xsl:choose>
					<xsl:when test="$namespace=''">
						<xsl:value-of select="normalize-space($config/config/meta/globalmember/classNameForGlobalMember)" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="concat($namespace, '::', normalize-space($config/config/meta/globalmember/classNameForGlobalMember))" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>

			<!-- header files-->
			<xsl:for-each select="/doxygen/compounddef[@kind='file']">
			  <xsl:for-each select="./compoundname" >
			    <xsl:variable name="includePath">
			      <xsl:choose>
				<xsl:when test="../incdepgraph/node/label[fn:ends-with(.,concat('/',current()))]">
				  <xsl:value-of select="../incdepgraph/node/label[fn:ends-with(.,concat('/',current()))]"/>
				</xsl:when>
				<xsl:when test="../incdepgraph/node/label[fn:ends-with(.,current())]">
				  <xsl:value-of select="../incdepgraph/node/label[fn:ends-with(.,current())]"/>
				</xsl:when>
				<xsl:when test="../invincdepgraph/node/label[fn:ends-with(.,concat('/',current()))]">
				  <xsl:value-of select="../invincdepgraph/node/label[fn:ends-with(.,concat('/',current()))]"/>
				</xsl:when>
				<xsl:otherwise>
				  <xsl:value-of select="../invincdepgraph/node/label[fn:ends-with(.,current())]"/>
				</xsl:otherwise>
			      </xsl:choose>
			    </xsl:variable>
			    <xsl:if test="string($includePath)">
				<xsl:element name="includes">
				  <xsl:attribute name="local" select="no" />
				  <xsl:value-of select="$includePath"/>
				</xsl:element>
			    </xsl:if>
			    </xsl:for-each>
			</xsl:for-each>
			
			<xsl:variable name="root">
				<xsl:choose>
					<xsl:when test="$namespace=''">
						<xsl:copy-of select="doxygen/compounddef[@kind='file']" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="." />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>	

			<!--<xsl:message>####### DEBUG #######</xsl:message>
			<xsl:message>####### root=<xsl:copy-of select="$root" /> #######</xsl:message>
			<xsl:message>####### no.=<xsl:value-of select="count($root/compounddef/sectiondef[@kind='var']/memberdef[@kind='variable'])" /> #######</xsl:message>
			<xsl:message>####### DEBUG #######</xsl:message>-->
			<!-- global functions-->
			<xsl:if test="count($root/compounddef/sectiondef[@kind='func']/memberdef[@kind='function']) > 0">
				<xsl:for-each select="$root/compounddef/sectiondef[@kind='func']">
					<xsl:call-template name="function">
						<xsl:with-param name="ifGlobal" select="true()" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
						
			<!-- global variables-->
			<xsl:if test="count($root/compounddef/sectiondef[@kind='var']/memberdef[@kind='variable']) > 0">			
				<xsl:for-each select="$root/compounddef/sectiondef[@kind='var']">
					<xsl:call-template name="variable">
						<xsl:with-param name="ifGlobal" select="true()" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
						
		</xsl:element>
		
	</xsl:template>


</xsl:stylesheet>
<!--
	How to use the version from the old generator project:
	
	Using the Stylesheet with version 2.0 with Saxon:
	java -jar bin/saxon8_2.jar -o build/meta.xml build/all.xml xslt/input.xslt
	memory problems, try this:
	java -Xmx512M -jar bin/saxon8_2.jar -o build/meta.xml build/all.xml xslt/input.xslt
-->
