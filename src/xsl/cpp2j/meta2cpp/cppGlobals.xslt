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

	<xsl:import href="cppClass.xslt" />
	<xsl:import href="cppEnum.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Deprecated.</xd:short>
	</xd:doc>

	<xsl:template name="cppGlobals">
		<xsl:param name="meta_ns_name" />
		<xsl:param name="include_dir" />
		<xsl:param name="lib_dir" />
		<xsl:param name="config" />

		<!-- compute java package name -->
		<xsl:variable name="java_ns_name"
				select="replace($config/config/java/namespaces/packageprefix/text(), '\.', '_')" />

		<!-- transform Java namespace to unique prefix -->
		<xsl:variable name="ns_prefix"
			select="replace($java_ns_name,'\.', '_')" />

		<!-- generate files -->
		<xsl:choose>
			<xsl:when test="./name() = 'enumeration'">
				<xsl:call-template name="cppEnum">
					<xsl:with-param name="enum" select="." />
					<xsl:with-param name="ns_prefix" select="$ns_prefix" />
					<xsl:with-param name="include_dir" select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="cppClass">
					<xsl:with-param name="ns_prefix" select="$ns_prefix" />
					<xsl:with-param name="include_dir" select="$include_dir" />
					<xsl:with-param name="lib_dir" select="$lib_dir" />
					<xsl:with-param name="config" select="$config" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:template>
</xsl:stylesheet>
