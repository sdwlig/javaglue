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
	xmlns:xd="http://www.pnp-software.com/XSLTdoc">

	<xsl:import href="metaParameterSignature.xslt" />

	<xd:doc type="stylesheet">
		<xd:short>Iterats over all parameters of a method.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Just iterates over all parameters and calls metaParameterSignature.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="method">method to be processed.</xd:param>
	</xd:doc>
	<xsl:template name="metaParameterListSignature">
		<xsl:param name="config" />
		<xsl:param name="method" />

		<!-- iterate through all parameters -->
		<xsl:for-each select="$method/parameters/parameter">

			<!-- write signature of parameter type -->
			<xsl:call-template name="metaParameterSignature">
				<xsl:with-param name="config" select="$config" />
				<xsl:with-param name="param" select="." />
			</xsl:call-template>

		</xsl:for-each>

	</xsl:template>

</xsl:stylesheet>
