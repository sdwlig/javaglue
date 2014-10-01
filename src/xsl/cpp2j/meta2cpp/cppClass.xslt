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
	
	Author: Christoph Nenning
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="cppClassFileHeader.xslt" />
	<xsl:import href="cppClassFileImpl.xslt" />
	<xsl:import href="cppCreateHelperMethods.xslt" />
	<xsl:import href="cppEnum.xslt" />
	<xsl:import href="../../util/path.xslt" />
	<xsl:import href="../../util/metaInheritedMethods.xslt" />
	<xsl:import href="../../util/createClassFromTemplateTypedef.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>
			Generation of jni functions for java classes.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>
			Creates path names of cpp files and calls templates to
			create files.
		</xd:short>
		<xd:param name="ns_prefix">
			Name prefix. Usually java package from config.
		</xd:param>
		<xd:param name="include_dir">
			Directory for include files.
		</xd:param>
		<xd:param name="lib_dir">Directory for source files.</xd:param>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:template name="cppClass">
		<xsl:param name="ns_prefix" />
		<xsl:param name="include_dir" />
		<xsl:param name="lib_dir" />
		<xsl:param name="config" />

		<!-- do not generate files if type is on ignore list -->
		<xsl:if
			test="not($ignore_list/ignore_list/item[. = current()/@fullName])">

			<xsl:message>Generating C code for class <xsl:value-of select="./@fullName" /></xsl:message>
			<!-- we cannot create JNI functions for templates -->
			<xsl:if test="not(./@template)">

				<!-- find out if we create an inner class -->
				<xsl:variable name="isInnerClass"
					select="../name() eq 'class' or ../name() eq 'struct' or @isInnerClass = 'true'" />

				<!-- compose filename of current class without suffix -->
				<!-- the 00024 is for the $ of inner classes -->
				<xsl:variable name="class_prefix">
					<xsl:choose>
						<xsl:when test="$isInnerClass">
							<xsl:value-of
								select="concat($ns_prefix, '_', '00024', replace(@name, '_', '_1'))" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of
								select="concat($ns_prefix, '_', replace(@name, '_', '_1'))" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<!-- compose filename of current class without suffix -->
				<xsl:variable name="main_filename"
					select="concat('class_', $class_prefix)" />

				<!-- compose basic header filename of current class -->
				<xsl:variable name="basic_header_filename"
					select="concat($main_filename,'.h')" />

				<!-- compose full header filename of current class -->
				<xsl:variable name="header_filename"
					select="concat($include_dir, '/', $basic_header_filename)" />

				<!-- compose implementation filename of current class -->
				<xsl:variable name="impl_filename"
					select="concat($lib_dir, '/', $main_filename,'.cpp')" />

				<!-- check if this class is abstract -->
				<!--
					<xsl:if test="not(xbig:areThereUnimplementedAbstractMethods(.))">
				-->
				<!-- generate description for helper methods -->
				<xsl:variable name="helper_methods">
					<xsl:for-each select=".">
						<xsl:call-template
							name="cppCreateHelperMethods">
							<xsl:with-param name="config" select="$config" />
							<xsl:with-param name="class" select="." />
						</xsl:call-template>
					</xsl:for-each>
				</xsl:variable>

				<!-- open header file -->
				<xsl:result-document
					href="{xbig:toFileURL($header_filename)}" format="textOutput">

					<!-- write header file -->
					<xsl:call-template name="cppClassFileHeader">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="." />
						<xsl:with-param name="class_prefix"
							select="$class_prefix" />
						<xsl:with-param name="helper_methods"
							select="$helper_methods" />
					</xsl:call-template>

				</xsl:result-document>

				<!-- open implementation file -->
				<xsl:result-document
					href="{xbig:toFileURL($impl_filename)}" format="textOutput">

					<!-- write file header with copyright information -->
					<xsl:call-template name="cppClassFileImpl">
						<xsl:with-param name="config" select="$config" />
						<xsl:with-param name="class" select="." />
						<xsl:with-param name="class_prefix"
							select="$class_prefix" />
						<xsl:with-param name="header_filename"
							select="$basic_header_filename" />
						<xsl:with-param name="helper_methods"
							select="$helper_methods" />
					</xsl:call-template>

				</xsl:result-document>

				<!-- inner classes & structs -->
				<xsl:for-each select="class[@protection = 'public']">
					<xsl:call-template name="cppClass">
						<xsl:with-param name="ns_prefix"
							select="$class_prefix" />
						<xsl:with-param name="include_dir"
							select="$include_dir" />
						<xsl:with-param name="lib_dir"
							select="$lib_dir" />
						<xsl:with-param name="config" select="$config" />
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="struct[@protection = 'public']">
					<xsl:call-template name="cppClass">
						<xsl:with-param name="ns_prefix"
							select="$class_prefix" />
						<xsl:with-param name="include_dir"
							select="$include_dir" />
						<xsl:with-param name="lib_dir"
							select="$lib_dir" />
						<xsl:with-param name="config" select="$config" />
					</xsl:call-template>
				</xsl:for-each>

				<!-- check if we have to generate a class for a typedef -->
				<xsl:for-each
					select="typedef[@protection eq 'public']">
					<xsl:if test="contains(./@basetype, '&lt;')">
						<xsl:variable name="templateBaseName"
							select="normalize-space(substring-before(./@basetype, '&lt;'))" />
						<xsl:variable name="fullTemplateBaseName"
							select="xbig:getFullTypeName($templateBaseName, ., $root)" />
						<xsl:variable name="templateNode"
							select="$root//*[@fullName = $fullTemplateBaseName]" />
						<xsl:variable name="generatedClass">
							<xsl:call-template
								name="createClassFromTemplateTypedef">
								<xsl:with-param name="template"
									select="$templateNode" />
								<xsl:with-param name="typedef"
									select="." />
								<xsl:with-param name="isInnerClass"
									select="true()" />
							</xsl:call-template>
						</xsl:variable>

						<!-- generate the class -->
						<xsl:for-each select="$generatedClass/*">
							<xsl:call-template name="cppClass">
								<xsl:with-param name="ns_prefix"
									select="$class_prefix" />
								<xsl:with-param name="include_dir"
									select="$include_dir" />
								<xsl:with-param name="lib_dir"
									select="$lib_dir" />
								<xsl:with-param name="config"
									select="$config" />
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>

				<!-- end of abstract class check -->
				<!-- 
					</xsl:if>
				-->
				<!-- inner enums -->
				<xsl:for-each select="enumeration[@protection = 'public']">
					<xsl:call-template name="cppEnum">
						<xsl:with-param name="enum" select="." />
						<xsl:with-param name="ns_prefix"
							select="$class_prefix" />
						<xsl:with-param name="include_dir"
							select="$include_dir" />
						<xsl:with-param name="lib_dir"
							select="$lib_dir" />
						<xsl:with-param name="config" select="$config" />
					</xsl:call-template>
				</xsl:for-each>

			</xsl:if>
			<!-- template -->

			<!-- ignore list -->
		</xsl:if>

	</xsl:template>
</xsl:stylesheet>
