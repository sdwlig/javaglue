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
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xsl:import href="cppClass.xslt" />
	<xsl:import href="cppEnum.xslt" />
	<xsl:import href="../meta2java/javaUtil.xslt" />
	<xsl:import href="../../util/createClassFromTemplateTypedef.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generation of types inside a namespace</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Calls templates for types inside a namespace.
		</xd:short>
		<xd:param name="meta_ns_name">
			java package prefix from config. For inner namespaces it contains also namespaces.
		</xd:param>
		<xd:param name="include_dir">Directory for include files.</xd:param>
		<xd:param name="lib_dir">Directory for source files.</xd:param>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:template name="cppNamespace">
		<xsl:param name="meta_ns_name" />
		<xsl:param name="include_dir" />
		<xsl:param name="lib_dir" />
		<xsl:param name="config" />

		<!-- iterate over child namespaces -->
		<xsl:for-each select="namespace">
			<xsl:call-template name="cppNamespace">
				<xsl:with-param name="meta_ns_name" select="xbig:getJavaPackageName(@fullName, $config)" />
				<xsl:with-param name="include_dir" select="$include_dir" />
				<xsl:with-param name="lib_dir" select="$lib_dir" />
				<xsl:with-param name="config" select="$config" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- shortcut for java configuration -->
		<xsl:variable name="java_config" select="$config/config/java" />

		<!-- extract Java namespace from configuration -->
		<!-- <xsl:variable name="java_ns_name"
			select="$java_config/namespaces/namespace[@name=$meta_ns_name]" /> -->
		<xsl:variable name="java_ns_name">
			<xsl:choose>
				<xsl:when test="not($meta_ns_name) or $meta_ns_name = ''">
					<xsl:value-of select="$config/config/java/namespaces/packageprefix/text()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($config/config/java/namespaces/packageprefix/text(),
						   '.', replace($meta_ns_name,'::', '.'))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- if no mapping in Java configuration vailable -->
		<xsl:if test="empty($java_ns_name)">
			<xsl:message terminate="yes">
				ERROR: no package name for
				<xsl:value-of select="$meta_ns_name" />
			</xsl:message>
		</xsl:if>

		<!-- transform Java namespace to unique prefix -->
		<xsl:variable name="ns_prefix"
			select="replace($java_ns_name,'\.', '_')" />

		<!-- iteration over all classes & structs inside current namespace -->
		<xsl:for-each select="class">
			<xsl:call-template name="cppClass">
				<xsl:with-param name="ns_prefix" select="$ns_prefix" />
				<xsl:with-param name="include_dir" select="$include_dir" />
				<xsl:with-param name="lib_dir" select="$lib_dir" />
				<xsl:with-param name="config" select="$config" />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:for-each select="struct">
			<xsl:call-template name="cppClass">
				<xsl:with-param name="ns_prefix" select="$ns_prefix" />
				<xsl:with-param name="include_dir" select="$include_dir" />
				<xsl:with-param name="lib_dir" select="$lib_dir" />
				<xsl:with-param name="config" select="$config" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- enums -->
		<xsl:for-each select="enumeration">
			<xsl:call-template name="cppEnum">
				<xsl:with-param name="enum" select="." />
				<xsl:with-param name="ns_prefix" select="$ns_prefix" />
				<xsl:with-param name="include_dir" select="$include_dir" />
				<xsl:with-param name="lib_dir" select="$lib_dir" />
				<xsl:with-param name="config" select="$config" />
			</xsl:call-template>
		</xsl:for-each>

		<!-- check if we have to generate a class for a typedef -->
		<xsl:for-each select="typedef">
			<xsl:if test="contains(./@basetype, '&lt;')">
				<xsl:variable name="templateBaseName"
						select="normalize-space(substring-before(./@basetype, '&lt;'))"/>
				<xsl:variable name="fullTemplateBaseName"
						select="xbig:getFullTypeName($templateBaseName, ., $root)"/>
				<xsl:variable name="templateNode" select="$root//*[@fullName = $fullTemplateBaseName]"/>
				<xsl:variable name="generatedClass">
					<xsl:call-template name="createClassFromTemplateTypedef">
						<xsl:with-param name="template" select="$templateNode"/>
						<xsl:with-param name="typedef" select="."/>
						<xsl:with-param name="isInnerClass" select="false()"/>
					</xsl:call-template>
				</xsl:variable>

				<!-- generate the class -->
				<xsl:for-each select="$generatedClass/*">
					<xsl:call-template name="cppClass">
						<xsl:with-param name="ns_prefix" select="$ns_prefix" />
						<xsl:with-param name="include_dir" select="$include_dir" />
						<xsl:with-param name="lib_dir" select="$lib_dir" />
						<xsl:with-param name="config" select="$config" />
					</xsl:call-template>
				</xsl:for-each>
			</xsl:if>
		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
