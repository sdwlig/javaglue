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
	
	Author: Kai Klesatschke <kai.klesatschke@netallied.de>
			Christoph Nenning
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG">

	<xd:doc type="stylesheet">
		<xd:short>Utility template to manipulate strings.</xd:short>
	</xd:doc>
	

	<xd:doc type="template">
		<xd:short>Takes a string and translates it's first letter to upper case.
		</xd:short>
		<xd:param name="name">string to be manipulated.</xd:param>
	</xd:doc>
	<xsl:template name="firstLetterToUpperCase">
		<xsl:param name="name"/>

		<xsl:variable name="firstLetter">
			<xsl:value-of select="substring($name,1,1)"/>
		</xsl:variable>

		<xsl:variable name="rest">
			<xsl:value-of select="substring($name,2)"/>
		</xsl:variable>

		<xsl:variable name="upperFirstLetter">
			<xsl:value-of select="translate($firstLetter,'abcdefghijklmnopqrstuvwxyz',
																 'ABCDEFGHIJKLMNOPQRSTUVWXYZ')"/>
		</xsl:variable>

		<xsl:value-of select="concat($upperFirstLetter,$rest)"/>

	</xsl:template>


	<xd:doc type="function">
		<xd:short>Checks if given string contains CDATA and removes it.</xd:short>
		<xd:param name="input">
			String to be manipulated.
		</xd:param>
	</xd:doc>
	<xsl:function name="xbig:removeCDATA" as="xs:string">
		<xsl:param name="input" as="xs:string" />

		<xsl:choose>
			<xsl:when test="contains($input, 'CDATA')">
				<xsl:value-of select="substring-before(substring-after($input, '![CDATA['), ']]')" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$input" />
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>

</xsl:stylesheet>
