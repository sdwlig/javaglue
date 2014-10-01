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


	<xd:doc type="stylesheet">
		<xd:short>Takes file header from config and puts it into current result document.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Takes comment for header files from config.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
	</xd:doc>
	<xsl:template name="cppFileHeader">
		<xsl:param name="config" />

		<!-- shortcut for original file header -->
		<xsl:variable name="org_header"
			select="$config/config/cpp/format/file/header" />

		<!-- normalize header (stripping white spaces from beginning and end -->
		<xsl:variable name="header"
			select="replace(replace($org_header, '^[ \t\s\r]+', ''), '[ \t\s\r]+$', '')" />

		<!-- write header -->
		<xsl:value-of  select="$header" />
		<xsl:text>&#10;&#10;</xsl:text>

	</xsl:template>
</xsl:stylesheet>
