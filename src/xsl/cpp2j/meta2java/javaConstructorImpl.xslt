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
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="../../util/metaMethodName.xslt" />
	<xsl:import href="javaMethodParameterList.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Generate body of constructors.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Generates java constructors which can be found in meta.
				Calls native method and stores InstancePointer in super class.
				Handles parameters, too.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="class">class which contains current constructor.</xd:param>
		<xd:param name="method">constructor to be generated.</xd:param>
	</xd:doc>
	<xsl:template name="javaConstructorImpl">
		<xsl:param name="config" />
		<xsl:param name="class" />
		<xsl:param name="method" />

		<!-- write native method call -->
		
		<!-- start base constructor call -->
		<xsl:text>&#32;super(</xsl:text>
		
		<!-- start creating new instance pointer -->
		<xsl:text>&#32;new&#32;</xsl:text>		
		<xsl:value-of select="$config/config/java/class/pointer" />
		<xsl:text>(</xsl:text>		
		
		<!-- write native method name -->
		<xsl:call-template name="metaMethodName">
			<xsl:with-param name="config" select="$config" />
			<xsl:with-param name="method" select="$method" />
		</xsl:call-template>
		
		<!-- open parameter list -->
		<xsl:text>(</xsl:text>

		<!-- write paremeters -->
		<xsl:call-template name="javaMethodParameterList">
			<xsl:with-param name="config" select="$config" />
			<xsl:with-param name="class" select="$class" />
			<xsl:with-param name="method" select="$method" />
			<xsl:with-param name="writingNativeMethod" select="false()" />
			<xsl:with-param name="callingNativeMethod" select="true()" />
		</xsl:call-template>

		<!-- close parameter list -->
		<xsl:text>)</xsl:text>
		
		<!-- close creating new instance pointer -->
		<xsl:text>)</xsl:text>
		
		<!-- close base constructor call -->
		<xsl:text>, false);</xsl:text>
	</xsl:template>

</xsl:stylesheet>
