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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="../../util/createFunctionsForPublicAttribute.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Creation of meta elements for additional methods, like d-tors</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Creates meta function elements for destructors and getters / setters for public attributes.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">meta class to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="cppCreateHelperMethods">
		<xsl:param name="config" />
		<xsl:param name="class" />
		
		<!-- if we call a global method, the destructor is unnecessary -->
		<xsl:if test="not($class/@name = normalize-space($config/config/meta/globalmember/classNameForGlobalMember))">
			<!-- compose destructor name -->
			<xsl:variable name="destructor_name"
				select="$config/config/meta/destructor/name/text()" />

			<xsl:element name="function">

				<!-- d-tor -->
				<xsl:attribute name="destructor">
					<xsl:text>true</xsl:text>
				</xsl:attribute>
				<xsl:attribute name="virt">
					<xsl:text>virtual</xsl:text>
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
				<xsl:element name="type">
					<xsl:text>void</xsl:text>
				</xsl:element>
				<xsl:element name="name">
					<xsl:value-of select="$destructor_name" />
				</xsl:element>
				<xsl:element name="definition">
					<xsl:value-of
						select="concat(@fullName, '::', $destructor_name)" />
				</xsl:element>
			</xsl:element>
		</xsl:if>

		<!-- create getters and setters for public attributes -->
		<!-- must be done later because of inheritance -->
		<!-- 
		<xsl:for-each select="variable">
			<xsl:call-template name="createFunctionsForPublicAttribute">
				<xsl:with-param name="variable" select="."/>
			</xsl:call-template>
		</xsl:for-each>
		 -->

	</xsl:template>
</xsl:stylesheet>
