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
		<xd:short>
			Utility templates to print an XML tree.
		</xd:short>
	</xd:doc>

	<xsl:template name="xmlWriteStartTag">
		<xsl:text>&lt;</xsl:text>
		<xsl:value-of select="name()" />
		<xsl:for-each select="@*">
			<xsl:call-template name="xmlWriteAttribute" />
		</xsl:for-each>
		<xsl:if
			test="not(*|text()|comment()|processing-instruction())">
			/
		</xsl:if>
		<xsl:text>></xsl:text>
	</xsl:template>

	<xsl:template name="xmlWriteEndTag">
		<xsl:text>&lt;/</xsl:text>
		<xsl:value-of select="name()" />
		<xsl:text>></xsl:text>
	</xsl:template>

	<xsl:template name="xmlWriteAttribute">
		<xsl:text>&#32;</xsl:text>
		<xsl:value-of select="name()" />
		<xsl:text>="</xsl:text>
		<xsl:value-of select="." />
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template name="xmlWriteElement">
		<xsl:param name="indent-string" select="''" />
		<xsl:param name="element" />

		<xsl:value-of select="$indent-string" />
		<xsl:call-template name="xmlWriteStartTag" />
		<xsl:if test="*">
			<xsl:text>&#10;</xsl:text>
		</xsl:if>
		<xsl:for-each select="*">
			<xsl:call-template name="xmlWriteElement">
				<xsl:with-param name="indent-string"
					select="concat($indent-string, '  ')" />
				<xsl:with-param name="element" select="." />
			</xsl:call-template>
		</xsl:for-each>
		<xsl:if test="*">
			<xsl:value-of select="$indent-string" />
		</xsl:if>
		<xsl:value-of select="text()" />
		<xsl:if test="*|text()|comment()|processing-instruction()">
			<xsl:call-template name="xmlWriteEndTag" />
		</xsl:if>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>


	<xsl:template name="xmlWriteTree">
		<xsl:param name="root" />

		<xsl:for-each select="$root/*">
			<xsl:call-template name="xmlWriteElement">
				<xsl:with-param name="element" select="." />
			</xsl:call-template>

		</xsl:for-each>
	</xsl:template>

</xsl:stylesheet>
