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


	<xd:doc type="stylesheet">
		<xd:short>finds signature for single parameters.</xd:short>
	</xd:doc>

	<xd:doc type="template">
		<xd:short>Gets signature from config for primitive types. Uses name of other types.
			If a typename contains special characters (e.g. '::' or '&lt;') it is masked with '_'.
			Uses JNI character masking.
		</xd:short>
		<xd:param name="config">config file.</xd:param>
		<xd:param name="meta_type">meta type to find signature to.</xd:param>
		<xd:param name="escape">Whether JNI character masking should be used.</xd:param>
		<xd:param name="class">meta class which contains method.</xd:param>
	</xd:doc>
	<xsl:template name="jniParameterSignature">
		<xsl:param name="config" />
		<xsl:param name="meta_type" />
		<xsl:param name="escape" />
		<xsl:param name="class" />

		<xsl:variable name="fullTypeName" select="xbig:resolveTypedef($meta_type, $class, $root)"/>

		<!-- map type to signature with mapping table from configuration -->
		<xsl:variable name="signature">
			<xsl:choose>
				<xsl:when test="$config/config/cpp/jni/signatures/type[@meta=$meta_type]/@signature">
					<xsl:value-of select="$config/config/cpp/jni/signatures/type
								[@meta=$meta_type]/@signature" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="replace(replace(replace(replace(replace(
								$fullTypeName, ' ', '_'), '::', '_'), '&lt;', '_'), '&gt;', '_'), ',', '_')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<!-- ensure valid signature -->
		<xsl:if test="empty($signature)">
			<xsl:message terminate="no">
				ERROR: no signature for type '
				<xsl:value-of select="$meta_type" />
				' found.
			</xsl:message>
		</xsl:if>

		<!-- write plain signature -->
		<xsl:if test="not($escape)">
			<xsl:value-of select="$signature" />
		</xsl:if>
		
		<!-- write escaped signature -->
		<xsl:if test="$escape">
			<xsl:value-of select="replace(replace(replace(replace(
									$signature, '_','_1'),'/','_'),';', '_2'),'\[','_3')" />
		</xsl:if>
		
		
	</xsl:template>

</xsl:stylesheet>
