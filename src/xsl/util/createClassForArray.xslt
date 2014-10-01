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
	
	Author: Kai Klesatschke
	
-->

<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes"
	xmlns:xd="http://www.pnp-software.com/XSLTdoc"
	xmlns:xbig="http://xbig.sourceforge.net/XBiG"
	xmlns:str="http://exslt.org/strings">

	<xsl:import href="../exslt/str.split.template.xsl" />

	<xd:doc type="stylesheet">
		<xd:short>Creates a meta class element for a type that is passed or returned by array somewhere.
		</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>see stylesheet.
		</xd:short>
		<xd:param name="typeName">Type which is needed as array.</xd:param>
	</xd:doc>
	<xsl:template name="createClassForArray">
		<xsl:param name="typeName" />		
		<xsl:param name="fullName" />
		
		<xsl:variable name="className" select="concat($typeName,'Array')"/>
		<xsl:variable name="fullclassName" select="concat($fullName,'Array')"/>
		<xsl:message>create array wrapper <xsl:value-of select="$className"/></xsl:message>

		<!-- generate the class element -->		
		<xsl:element name="class">
			<xsl:attribute name="name" select="$className"/>
			<xsl:attribute name="fullName" select="$fullclassName"/>
			
			<!-- ctor <className>(long size) -->
			<xsl:element name="function">
            	<xsl:attribute name="virt">non-virtual</xsl:attribute>
                <xsl:attribute name="visibility">public</xsl:attribute>
                <xsl:attribute name="static">false</xsl:attribute>
                <xsl:attribute name="const">false</xsl:attribute>
                <xsl:attribute name="passedBy">value</xsl:attribute>
                <xsl:element name="definition"><xsl:value-of select="$className"/>::<xsl:value-of select="$className"/></xsl:element>
                <xsl:element name="name"><xsl:value-of select="$className"/></xsl:element>
                <xsl:element name="parameters">
                	<xsl:element name="parameter">
                		<xsl:attribute name="passedBy">value</xsl:attribute>
	               		<xsl:element name="type">long</xsl:element>
                		<xsl:element name="name">size</xsl:element>
                	</xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- getter -->
            <xsl:element name="function">
            	<xsl:attribute name="virt">non-virtual</xsl:attribute>
                <xsl:attribute name="visibility">public</xsl:attribute>
                <xsl:attribute name="static">false</xsl:attribute>
                <xsl:attribute name="const">true</xsl:attribute>
                <xsl:attribute name="passedBy">value</xsl:attribute>
                <xsl:element name="type"><xsl:value-of select="$typeName"/></xsl:element>
                <xsl:element name="definition"><xsl:value-of select="$className"/>::get</xsl:element>                
                <xsl:element name="name">get</xsl:element>
                <xsl:element name="parameters">
                	<xsl:element name="parameter">
                		<xsl:attribute name="passedBy">value</xsl:attribute>
                		<xsl:element name="type">long</xsl:element>
                		<xsl:element name="name">index</xsl:element>                		
                	</xsl:element>
                </xsl:element>
            </xsl:element>
            
            <!-- setter -->
            <xsl:element name="function">
            	<xsl:attribute name="virt">non-virtual</xsl:attribute>
                <xsl:attribute name="visibility">public</xsl:attribute>
                <xsl:attribute name="static">false</xsl:attribute>
                <xsl:attribute name="const">false</xsl:attribute>
                <xsl:attribute name="passedBy">value</xsl:attribute>
                <xsl:element name="type">void</xsl:element>
                <xsl:element name="definition"><xsl:value-of select="$className"/>::set</xsl:element>
                <xsl:element name="name">set</xsl:element>
                <xsl:element name="parameters">
                	<xsl:element name="parameter">
                		<xsl:attribute name="passedBy">value</xsl:attribute>
                		<xsl:element name="type">long</xsl:element>
                		<xsl:element name="name">index</xsl:element>                		
                	</xsl:element>
                	<xsl:element name="parameter">
                		<xsl:attribute name="passedBy">value</xsl:attribute>
                		<xsl:element name="type"><xsl:value-of select="$typeName"/></xsl:element>
                		<xsl:element name="name">value</xsl:element>                		
                	</xsl:element>                	
                </xsl:element>
            </xsl:element>
		</xsl:element>
	</xsl:template>
</xsl:stylesheet>
